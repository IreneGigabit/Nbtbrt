<%@ Page Language="C#"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Data.SqlClient" %>
<%@ Import Namespace = "System.IO"%>
<%@ Import Namespace = "System.Linq"%>
<%@ Import Namespace = "System.Collections.Generic"%>

<script runat="server">
	protected string in_scode = "";
	protected string in_no = "";
    protected string case_sqlno = "";
    protected string send_sel = "";

	protected IPOReport ipoRpt = null;

	private void Page_Load(System.Object sender, System.EventArgs e) {
		Response.CacheControl = "Private";
		Response.AddHeader("Pragma", "no-cache");
		Response.Expires = -1;
		Response.Clear();

		in_scode = (Request["in_scode"] ?? "").ToString();//n428
		in_no = (Request["in_no"] ?? "").ToString();//20160902001
		case_sqlno = (Request["case_sqlno"] ?? "").ToString();//16090001
        send_sel = (Request["send_sel"] ?? "").ToString();//4
		try {
			ipoRpt = new IPOReport(Session["btbrtdb"].ToString(), in_scode, in_no, case_sqlno)
			{
				ReportCode = "FOB",
				RectitleFlag = (Request["rectitle_flag"] ?? "").ToString(),//Y
				RectitleTitle = (Request["receipt_title"] ?? "").ToString(),//A
				RectitleName = (Request["rectitle_name"] ?? "").ToString(),//英業達股份有限公司
			};
			WordOut();
		}
		finally {
			if (ipoRpt != null) ipoRpt.Close();
		}
	}

	protected void WordOut() {
        string docFileName = "[影印]-" + ipoRpt.Seq + ".docx";
		
		Dictionary<string, string> _tplFile = new Dictionary<string, string>(){
			{"apply", Server.MapPath("~/Report-word/25影印申請書(FOB).docx")},
		};
		ipoRpt.CloneFromFile(_tplFile, true);

		DataTable dmt = ipoRpt.Dmt;
		if (dmt.Rows.Count > 0) {
			//標題區塊
            ipoRpt.CopyBlock("b_title0");
            ipoRpt.CopyBlock("b_title");
            
            //日期
            ipoRpt.ReplaceBookmark("tyear", (DateTime.Today.Year - 1911).ToString());
            ipoRpt.ReplaceBookmark("tyear2", (DateTime.Today.Year - 1911).ToString());
            //號數
            string[] mark = new string[] { "　", "　", "　" };
            if (dmt.Rows[0]["mark"].ToString() != "") {
                if (dmt.Rows[0]["mark"].ToString() == "A") {
                    mark[0] = "Ｖ";
                    ipoRpt.ReplaceBookmark("no", dmt.Rows[0].SafeRead("apply_no", "").Trim());
                } else if (dmt.Rows[0]["mark"].ToString() == "I") {
                    mark[1] = "Ｖ";
                    ipoRpt.ReplaceBookmark("no", dmt.Rows[0].SafeRead("issue_no", "").Trim());
                } else if (dmt.Rows[0]["mark"].ToString() == "R") {
                    mark[2] = "Ｖ";
                    ipoRpt.ReplaceBookmark("no", dmt.Rows[0].SafeRead("rej_no", "").Trim());
                }
            }
            for (int i = 0; i < mark.Length; i++) {
                ipoRpt.ReplaceBookmark("mark" + (i + 1), mark[i]);
            }
            //商標或標章種類
            string[] smark = new string[] { "　", "　", "　", "　", "　" };
            if (dmt.Rows[0]["s_mark"].ToString() != "") {
                if (dmt.Rows[0]["s_mark"].ToString() == "S") {
                    smark[1] = "Ｖ";
                } else if (dmt.Rows[0]["s_mark"].ToString() == "L") {
                    smark[2] = "Ｖ";
                } else if (dmt.Rows[0]["s_mark"].ToString() == "M") {
                    smark[3] = "Ｖ";
                } else if (dmt.Rows[0]["s_mark"].ToString() == "N") {
                    smark[4] = "Ｖ";
                }
            } else {
                smark[0] = "Ｖ";
            }
            for (int i = 0; i < smark.Length; i++) {
                ipoRpt.ReplaceBookmark("smark" + (i + 1), smark[i]);
            }
            
            //商標或標章名稱
            ipoRpt.ReplaceBookmark("appl_name", dmt.Rows[0]["appl_name"].ToString().ToXmlUnicode());

			//申請人
			using (DataTable dtAp = ipoRpt.Apcust) {
				for (int i = 0; i < dtAp.Rows.Count; i++) {
					ipoRpt.CopyBlock("b_apply");
					ipoRpt.ReplaceBookmark("apply_num", (i + 1).ToString());
                    ipoRpt.ReplaceBookmark("apcust_no", dtAp.Rows[i]["c_id"].ToString());
					ipoRpt.ReplaceBookmark("ap_cname", dtAp.Rows[i]["Cname_string"].ToString().ToXmlUnicode());
                    ipoRpt.ReplaceBookmark("ap_crep", dtAp.Rows[i]["ap_crep"].ToString().ToXmlUnicode());
                    if (dtAp.Rows[i]["server_flag"].ToString() == "Y") {
                        ipoRpt.ReplaceBookmark("server_flag", "V");
                    }
				}
                if (dtAp.Rows.Count > 0) {
                    ipoRpt.ReplaceBookmark("apcust_num", dtAp.Rows.Count.ToString());
                }
			}
            //具結
            ipoRpt.CopyBlock("b_sign");
            //代理人
			ipoRpt.CopyBlock("b_agent");
			using (DataTable dtAgt = ipoRpt.Agent) {
                if (dtAgt.Rows.Count > 0) {
                    string agt_name = "";
                    agt_name = dtAgt.Rows[0]["agt_name1"].ToString();
                    if (dtAgt.Rows[0]["agt_name2"].ToString() != "") {
                        agt_name += "、" + dtAgt.Rows[0]["agt_name2"].ToString();
                    }
                    ipoRpt.ReplaceBookmark("agt_name", agt_name.Replace(",",""));
                    ipoRpt.ReplaceBookmark("agt_tel", dtAgt.Rows[0]["agt_tel"].ToString());
                    string s_agatt_tel = "";
                    if (dtAgt.Rows[0]["agatt_tel0"].ToString().Trim() != "") s_agatt_tel += dtAgt.Rows[0]["agatt_tel0"].ToString().Trim();
                    if (dtAgt.Rows[0]["agatt_tel"].ToString().Trim() != "") s_agatt_tel += "-" + dtAgt.Rows[0]["agatt_tel"].ToString().Trim();
                    ipoRpt.ReplaceBookmark("s_agatt_tel", s_agatt_tel);
                    ipoRpt.ReplaceBookmark("agatt_tel1", dtAgt.Rows[0].SafeRead("agatt_tel1", ""));
                }
			}
			//申請內容
			ipoRpt.CopyBlock("b_content");

            if (ipoRpt.Tran.Rows[0].SafeRead("other_item", "") != "") {
                string[] arr_other_item = ipoRpt.Tran.Rows[0].SafeRead("other_item", "").Split('|');
                for (int I = 0; I < arr_other_item.Length; I++) {
                    var item_p = ipoRpt.TranListE.Where(a => a["mod_field"].ToString() == "other_item" && a["mod_type"].ToString().Trim() == arr_other_item[I]).FirstOrDefault();
                    string lmod_dclass = "", lnew_no = "";
                    if (item_p != null) {
                        lmod_dclass = item_p["mod_dclass"].ToString().Trim();
                        lnew_no = item_p["new_no"].ToString().Trim();
                    }
                    switch (arr_other_item[I]) {
                        case "P1":
                            ipoRpt.ReplaceBookmark("item_p1", "Ｖ");
                            break;
                        case "P2":
                            ipoRpt.ReplaceBookmark("item_p2", "Ｖ");
                            ipoRpt.ReplaceBookmark("mod_dclass_p2", lmod_dclass);
                            ipoRpt.ReplaceBookmark("new_no_p2", lnew_no);
                            break;
                        case "P3":
                            ipoRpt.ReplaceBookmark("item_p3", "Ｖ");
                            ipoRpt.ReplaceBookmark("mod_dclass_p3", lmod_dclass);
                            ipoRpt.ReplaceBookmark("new_no_p3", lnew_no);
                            break;
                        case "P4":
                            ipoRpt.ReplaceBookmark("item_p4", "Ｖ");
                            ipoRpt.ReplaceBookmark("mod_dclass_p4", lmod_dclass);
                            ipoRpt.ReplaceBookmark("new_no_p4", lnew_no);
                            break;
                        case "P5":
                            ipoRpt.ReplaceBookmark("item_p5", "Ｖ");
                            ipoRpt.ReplaceBookmark("mod_dclass_p5", lmod_dclass);
                            ipoRpt.ReplaceBookmark("new_no_p5", lnew_no);
                            break;
                        case "P6":
                            ipoRpt.ReplaceBookmark("item_p6", "Ｖ");
                            ipoRpt.ReplaceBookmark("new_no_p6", lnew_no);
                            break;
                        case "P7":
                            ipoRpt.ReplaceBookmark("item_p7", "Ｖ");
                            ipoRpt.ReplaceBookmark("new_no_p7", lnew_no);
                            break;
                        case "P8":
                            ipoRpt.ReplaceBookmark("item_p8", "Ｖ");
                            ipoRpt.ReplaceBookmark("new_no_p8", lnew_no);
                            break;
                        case "P9":
                            ipoRpt.ReplaceBookmark("item_p9", "Ｖ");
                            ipoRpt.ReplaceBookmark("new_no_p9", lnew_no);
                            break;
                        case "P10":
                            ipoRpt.ReplaceBookmark("item_p10", "Ｖ");
                            ipoRpt.ReplaceBookmark("new_no_p10", lnew_no);
                            break;
                        case "P11":
                            ipoRpt.ReplaceBookmark("item_p11", "Ｖ");
                            ipoRpt.ReplaceBookmark("new_no_p11", lnew_no);
                            break;
                        case "P12":
                            ipoRpt.ReplaceBookmark("item_p12", "Ｖ");
                            break;
                    }
                }
            }

			ipoRpt.CopyPageFoot("apply", false);//申請書頁尾
		}
		ipoRpt.Flush(docFileName);
		ipoRpt.SetPrint();
	}
</script>
