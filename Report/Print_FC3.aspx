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
	
	protected IPOReport ipoRpt = null;

	private void Page_Load(System.Object sender, System.EventArgs e) {
		Response.CacheControl = "Private";
		Response.AddHeader("Pragma", "no-cache");
		Response.Expires = -1;
		Response.Clear();

        
		in_scode = (Request["in_scode"] ?? "").ToString();//n428
		in_no = (Request["in_no"] ?? "").ToString();//20160902001
		case_sqlno = (Request["case_sqlno"] ?? "").ToString();//16090001
        
		try {
			ipoRpt = new IPOReport(Session["btbrtdb"].ToString(), in_scode, in_no, case_sqlno)
			{
				ReportCode = "FC3",
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
        string docFileName = "[服務減縮]-" + ipoRpt.Seq + ".docx";

		Dictionary<string, string> _tplFile = new Dictionary<string, string>(){
			{"apply", Server.MapPath("~/ReportTemplate/申請書/407註冊指定使用商品服務減縮申請書FC3.docx")},
			{"base", Server.MapPath("~/ReportTemplate/申請書/00基本資料表.docx")}
		};
		ipoRpt.CloneFromFile(_tplFile, true);

		DataTable dmt = ipoRpt.Dmt;
		if (dmt.Rows.Count > 0) {
			//標題區塊
			ipoRpt.CopyBlock("b_title");
			//註冊號
			ipoRpt.ReplaceBookmark("issue_no", dmt.Rows[0]["issue_no"].ToString().Trim());
			//事務所或申請人案件編號
			ipoRpt.ReplaceBookmark("seq", ipoRpt.Seq + "(" + DateTime.Today.ToString("yyyyMMdd") + ")");
			//商標或標章名稱
			ipoRpt.ReplaceBookmark("appl_name", dmt.Rows[0]["appl_name"].ToString().ToXmlUnicode());
			//商標或標章種類
            ipoRpt.ReplaceBookmark("s_mark", dmt.Rows[0]["s_marknm"].ToString());
			//申請人
			using (DataTable dtAp = ipoRpt.Apcust) {
				for (int i = 0; i < dtAp.Rows.Count; i++) {
					ipoRpt.CopyBlock("b_apply");
                    ipoRpt.ReplaceBookmark("apply_type", ipoRpt.BaseRptAPTag);
                    ipoRpt.ReplaceBookmark("apply_num", (i + 1).ToString());
					ipoRpt.ReplaceBookmark("ap_country", dtAp.Rows[i]["Country_name"].ToString());
					ipoRpt.ReplaceBookmark("ap_cname_title", dtAp.Rows[i]["Title_cname"].ToString());
					ipoRpt.ReplaceBookmark("ap_ename_title", dtAp.Rows[i]["Title_ename"].ToString());
					ipoRpt.ReplaceBookmark("ap_cname", dtAp.Rows[i]["Cname_string"].ToString().ToXmlUnicode());
					ipoRpt.ReplaceBookmark("ap_ename", dtAp.Rows[i]["Ename_string"].ToString().ToXmlUnicode(true), true);
				}
			}
            //代理人
			ipoRpt.CopyBlock("b_agent");
			using (DataTable dtAgt = ipoRpt.Agent) {
                ipoRpt.ReplaceBookmark("agent_type1", ipoRpt.BaseRptAPTag);
                ipoRpt.ReplaceBookmark("agent_type2", ipoRpt.BaseRptAPTag);
				ipoRpt.ReplaceBookmark("agt_name1", dtAgt.Rows[0]["agt_name1"].ToString());
				ipoRpt.ReplaceBookmark("agt_name2", dtAgt.Rows[0]["agt_name2"].ToString());
			}

            //擬減縮商品或服務名稱
            var mod_class = ipoRpt.TranListE.Where(a => a["mod_field"].ToString() == "mod_class");
            //ipoRpt.Tran.Rows[0].SafeRead("other_item1", "")
            foreach (var r in mod_class) {
                ipoRpt.CopyBlock("b_mod_class");
                ipoRpt.ReplaceBookmark("new_no", r["new_no"].ToString());
                ipoRpt.ReplaceBookmark("list_remark", r["list_remark"].ToString().Trim().ToXmlUnicode());
            }
        
            //減縮後指定商品或服務名稱
            using (DataTable dtGoods = ipoRpt.Goods) {
                for (int i = 0; i < dtGoods.Rows.Count; i++) {
                    ipoRpt.CopyBlock("b_goods");
                    ipoRpt.ReplaceBookmark("class", dtGoods.Rows[i]["pclass"].ToString());
                    ipoRpt.ReplaceBookmark("goodname", dtGoods.Rows[i]["dmt_goodname"].ToString().Trim().ToXmlUnicode());
                }
            }

			//繳費資訊
			ipoRpt.CreateFees();
            
            //備註
            using (DataTable dtTran = ipoRpt.Tran) {
                string remark = "";
                if (dtTran.Rows.Count > 0) {
                    string other_item = dtTran.Rows[0]["other_item"].ToString().Trim();
                    if (other_item.IndexOf(";") > -1) {
                        string[] oitem = other_item.Split(';');
                        if (oitem[0] != "") {//本件商標(標章)於Ｏ年Ｏ月Ｏ日，另案辦理異議案／評定案／補證案／延展案。
                            remark = "本件商標(標章)於" + oitem[0] + "(年/月/日)，另案辦理";
                            switch (oitem[1]) {
                                case "DO1":
                                    remark += "異議案。";
                                    break;
                                case "DI1":
                                    remark += "評定案。";
                                    break;
                                case "FI1":
                                    remark += "補證案。";
                                    break;
                                case "FR1":
                                    remark += "延展案。";
                                    break;
                                case "ZZ":
                                    if (oitem[2] != null && oitem[2] != "")
                                        remark += oitem[2] + "案。";
                                    else
                                        remark += "___案。";
                                    break;
                            }
                        }
                        ipoRpt.CopyBlock("b_remark");
                        ipoRpt.ReplaceBookmark("remark", remark, true);
                    }
                }
            }
            
			//附送書件
            //ipoRpt.CreateAttach();
            List<AttachMapping> mapList = new List<AttachMapping>();
            string remark1 = ipoRpt.Dmt.Rows[0]["remark1"].ToString();//文件勾選值
            mapList.Add(new AttachMapping { mapValue = "*", docType = "02" });//委任書(*表必備文件)
            mapList.Add(new AttachMapping { mapValue = "*", docType = "17" });//基本資料表(*表必備文件)
            mapList.Add(new AttachMapping { brColValue = remark1, mapValue = "Z1C", docType = "021" });//委任書中譯本
            mapList.Add(new AttachMapping { brColValue = remark1, mapValue = "Z2", docType = "E33" });//全體共有人同意書
            mapList.Add(new AttachMapping { brColValue = remark1, mapValue = "Z2C", docType = "E331" });//全體共有人同意書中譯本
            mapList.Add(new AttachMapping { brColValue = remark1, mapValue = "Z3", docType = "E10" });//團體商標或證明標章使用規範書
            mapList.Add(new AttachMapping { brColValue = remark1, mapValue = "Z3C", docType = "E11" });//團體商標或證明標章使用規範書中譯本
            mapList.Add(new AttachMapping { brColValue = remark1, mapValue = "Z3", docType = "E16" });//團體商標或證明標章使用規範書
            mapList.Add(new AttachMapping { brColValue = remark1, mapValue = "Z3C", docType = "E17" });//團體商標或證明標章使用規範書中譯本
            ipoRpt.CreateAttach(mapList);
            
            //具結
			ipoRpt.CopyBlock("b_sign");

			bool baseflag = true;//是否產生基本資料表
			ipoRpt.CopyPageFoot("apply", baseflag);//申請書頁尾
			if (baseflag) {
				ipoRpt.AppendBaseData("base");//產生基本資料表
			}
		}
		ipoRpt.Flush(docFileName);
		ipoRpt.SetPrint();
	}
</script>
