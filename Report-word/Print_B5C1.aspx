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
    protected DBHelper conn = null;

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
            conn = new DBHelper(Conn.btbrt, false).Debug(false);
            ipoRpt = new IPOReport(Conn.btbrt, in_scode, in_no, case_sqlno)
			{
				ReportCode = "B5C1",
				RectitleFlag = (Request["rectitle_flag"] ?? "").ToString(),//Y
				RectitleTitle = (Request["receipt_title"] ?? "").ToString(),//A
				RectitleName = (Request["rectitle_name"] ?? "").ToString(),//英業達股份有限公司
			};

			WordOut();
		}
		finally {
			if (ipoRpt != null) ipoRpt.Close();
            if (conn != null) conn.Dispose();
        }
	}

    protected void WordOut() {
        string docFileName = "[聽證]-" + ipoRpt.Seq + ".docx";

        Dictionary<string, string> _tplFile = new Dictionary<string, string>(){
			{"apply", Server.MapPath("~/ReportTemplate/申請書/紙本/B5C1_聽證申請書.docx")},
		};
        ipoRpt.CloneFromFile(_tplFile, true);

        DataTable dmt = ipoRpt.Dmt;
        if (dmt.Rows.Count > 0) {
            //標題區塊
            ipoRpt.CopyBlock("b_title");

            //日期
            ipoRpt.ReplaceBookmark("tyear", (DateTime.Today.Year - 1911).ToString());
            ipoRpt.ReplaceBookmark("tyear2", (DateTime.Today.Year - 1911).ToString());

            //註冊號數
            ipoRpt.ReplaceBookmark("issue_no", dmt.Rows[0].SafeRead("issue_no", ""));
            //商標或標章種類
            //空白:商標 S:服務 K:產地證明標章L:證明標章 M:團體標章 N:團體商標
            string[] smark = new string[] { "　", "　", "　", "　", "　" };
            if (dmt.Rows[0]["s_mark"].ToString() != "") {
                if (dmt.Rows[0]["s_mark"].ToString() == "S") {//92
                    smark[1] = "Ｖ";
                } else if (dmt.Rows[0]["s_mark"].ToString() == "L") {//證明標章
                    smark[2] = "Ｖ";
                } else if (dmt.Rows[0]["s_mark"].ToString() == "M") {//團體標章
                    smark[3] = "Ｖ";
                } else if (dmt.Rows[0]["s_mark"].ToString() == "N") {//團體商標
                    smark[4] = "Ｖ";
                }
            } else {
                smark[0] = "Ｖ";//商標
            }
            for (int i = 0; i < smark.Length; i++) {
                ipoRpt.ReplaceBookmark("smark" + (i + 1), smark[i]);
            }
            //案件種類
            if (dmt.Rows[0]["remark3"].ToString() != "") {
                ipoRpt.ReplaceBookmark("remark3_" + dmt.Rows[0]["remark3"], "Ｖ");
            }
            //商標或標章名稱
            ipoRpt.ReplaceBookmark("appl_name", dmt.Rows[0]["appl_name"].ToString().ToXmlUnicode());
            //申請人種類
            if (dmt.Rows[0]["mark"].ToString() != "") {
                ipoRpt.ReplaceBookmark("mark" + dmt.Rows[0]["mark"], "Ｖ");
            }

            //申請人
            using (DataTable dtAp = ipoRpt.Apcust) {
                for (int i = 0; i < dtAp.Rows.Count; i++) {
                    DataRow drdap = dtAp.Rows[i];
                    ipoRpt.CopyTable("tbl_apply");
                    ipoRpt.ReplaceBookmark("apply_num", (i + 1).ToString());

                    ipoRpt.ReplaceBookmark("apcust_no", drdap["c_id"].ToString());
                    ipoRpt.ReplaceBookmark("ap_cname", drdap.SafeRead("Cname_string", "").Replace(",", "").ToXmlUnicode());
                    ipoRpt.ReplaceBookmark("ap_ename", drdap.SafeRead("ename_string", "").Replace(",", "").ToXmlUnicode());
                    ipoRpt.ReplaceBookmark("ap_caddr", drdap["c_addr"].ToString().ToXmlUnicode());
                    ipoRpt.ReplaceBookmark("ap_crep", drdap["ap_crep"].ToString().ToXmlUnicode());
                    ipoRpt.ReplaceBookmark("ap_erep", drdap["ap_erep"].ToString().ToXmlUnicode());
                    if (drdap["server_flag"].ToString() == "Y") {
                        ipoRpt.ReplaceBookmark("server_flag", "V");
                    }
                }
                if (dtAp.Rows.Count > 0) {
                    ipoRpt.ReplaceBookmark("apcust_num", dtAp.Rows.Count.ToString());
                }
            }
            //代理人
            ipoRpt.CopyBlock("b_agent");
            using (DataTable dtAgt = ipoRpt.Agent) {
                if (dtAgt.Rows.Count > 0) {
                    DataRow dragt = dtAgt.Rows[0];
                    //ID
                    string agt_id1 = "";
                    if (dragt.SafeRead("agt_id1", "") != "") {
                        agt_id1 += dragt.SafeRead("agt_id1", "");
                        if (dragt.SafeRead("agt_id2", "") != "") agt_id1 += "、" + dragt.SafeRead("agt_id2", "");
                    }
                    ipoRpt.ReplaceBookmark("agt_id1", agt_id1);
                    //姓名
                    string agt_name = "";
                    agt_name = dragt.SafeRead("agt_name1", "");
                    if (dragt.SafeRead("agt_name2", "") != "") {
                        agt_name += "、" + dragt.SafeRead("agt_name2", "");
                    }
                    ipoRpt.ReplaceBookmark("agt_name", agt_name.Replace(",", ""));
                    //地址
                    if (dragt.SafeRead("agt_addr", "") != "") {
                        ipoRpt.ReplaceBookmark("agt_addr", dragt.SafeRead("agt_zip", "") + dragt.SafeRead("agt_addr", ""));
                    }
                    //電話
                    ipoRpt.ReplaceBookmark("agt_tel", dragt.SafeRead("agt_tel", ""));
                    //傳真
                    ipoRpt.ReplaceBookmark("agt_fax", dragt.SafeRead("agt_fax", ""));
                    //聯絡人電話
                    string strtel = dragt.SafeRead("agatt_tel0", "");
                    if (dragt.SafeRead("agatt_tel", "") != "") {
                        strtel += "-" + dragt.SafeRead("agatt_tel", "");
                    }
                    ipoRpt.ReplaceBookmark("agatt_tel", strtel);
                    //聯絡人分機
                    ipoRpt.ReplaceBookmark("agatt_tel1", dragt.SafeRead("agatt_tel1", ""));
                }
            }

            //對造當事人
            ipoRpt.CopyBlock("b_tran");
            DataTable dtTran = ipoRpt.Tran;
            if (dtTran.Rows.Count > 0) {
                string tran_mark = dtTran.Rows[0]["tran_mark"].ToString().Trim();
                ipoRpt.ReplaceBookmark("tran_mark" + tran_mark, "Ｖ");
            }
            var item_p = ipoRpt.TranListE.Where(a => a["mod_field"].ToString() == "mod_client");
            foreach (var r in item_p) {
                ipoRpt.CopyTable("tbl_tranlist");
                ipoRpt.ReplaceBookmark("ncname1", r.SafeRead("ncname1", "").ToXmlUnicode());
                ipoRpt.ReplaceBookmark("naddr1", r.SafeRead("naddr1", "").ToXmlUnicode());
            }

            //應舉行聽證之理由
            ipoRpt.CopyBlock("b_content");
            if (dtTran.Rows.Count > 0) {
                ipoRpt.ReplaceBookmark("tran_remark1", dtTran.Rows[0].SafeRead("tran_remark1", "").ToXmlUnicode());
            }

            ipoRpt.CopyPageFoot("apply", false);//申請書頁尾
        }

        ipoRpt.Flush(docFileName);
        ipoRpt.SetPrint();
    }
</script>
