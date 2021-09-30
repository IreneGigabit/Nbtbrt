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
			ipoRpt = new IPOReport(Conn.btbrt, in_scode, in_no, case_sqlno)
			{
				ReportCode = "FL3",
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
        string docFileName = "[廢止授權]-" + ipoRpt.Seq + ".docx";

		Dictionary<string, string> _tplFile = new Dictionary<string, string>(){
			{"apply", Server.MapPath("~/ReportTemplate/申請書/403廢止授權登記申請書FL3.docx")},
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
            //申請人類別
            if (dmt.Rows[0]["mark"].ToString()=="A"){
                ipoRpt.BaseRptAPTag = "授權人";
                ipoRpt.BaseRptModTag = "被授權人";//關係人類別
                ipoRpt.ReplaceBookmark("mark", "授權人(商標權人)");
            } else if (dmt.Rows[0]["mark"].ToString() == "B") {
                ipoRpt.BaseRptAPTag = "被授權人";
                ipoRpt.BaseRptModTag = "授權人";//關係人類別
                ipoRpt.ReplaceBookmark("mark", "被授權人");
            }
			//申請人(依申請人類別判定)
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
            //代理人(依申請人類別判定)
			ipoRpt.CopyBlock("b_agent");
			using (DataTable dtAgt = ipoRpt.Agent) {
                ipoRpt.ReplaceBookmark("agent_type1", ipoRpt.BaseRptAPTag);
                ipoRpt.ReplaceBookmark("agent_type2", ipoRpt.BaseRptAPTag);
				ipoRpt.ReplaceBookmark("agt_name1", dtAgt.Rows[0]["agt_name1"].ToString());
				ipoRpt.ReplaceBookmark("agt_name2", dtAgt.Rows[0]["agt_name2"].ToString());
			}
            //關係人
            using (DataTable dtModAp = ipoRpt.TranListAP) {
                for (int i = 0; i < dtModAp.Rows.Count; i++) {
                    ipoRpt.CopyBlock("b_apply");
                    ipoRpt.ReplaceBookmark("apply_type", ipoRpt.BaseRptModTag);
                    ipoRpt.ReplaceBookmark("apply_num", (i + 1).ToString());
                    ipoRpt.ReplaceBookmark("ap_country", dtModAp.Rows[i]["Country_name"].ToString());
                    ipoRpt.ReplaceBookmark("ap_cname_title", dtModAp.Rows[i]["Title_cname"].ToString());
                    ipoRpt.ReplaceBookmark("ap_ename_title", dtModAp.Rows[i]["Title_ename"].ToString());
                    ipoRpt.ReplaceBookmark("ap_cname", dtModAp.Rows[i]["Cname_string"].ToString().ToXmlUnicode());
                    ipoRpt.ReplaceBookmark("ap_ename", dtModAp.Rows[i]["Ename_string"].ToString().ToXmlUnicode(true), true);
                }
            }
            ipoRpt.CopyBlock("b_tran");
            using (DataTable dtTran = ipoRpt.Tran) {
                if (dtTran.Rows.Count > 0) {
                    //廢止授權期間
                    string term1 = Convert.ToDateTime(dtTran.Rows[0]["term1"]).ToShortTwDate();
                    ipoRpt.ReplaceBookmark("tran_term1", term1);
                }
            }
            
			//繳費資訊
			ipoRpt.CreateFees();
            
			//附送書件
            //ipoRpt.CreateAttach();
            List<AttachMapping> mapList = new List<AttachMapping>();
            string remark1 = ipoRpt.Dmt.Rows[0]["remark1"].ToString();//文件勾選值
            mapList.Add(new AttachMapping { mapValue = "*", docType = "02" });//委任書(*表必備文件)
            mapList.Add(new AttachMapping { mapValue = "*", docType = "17" });//基本資料表(*表必備文件)
            mapList.Add(new AttachMapping { brColValue = remark1, mapValue = "Z4C", docType = "021" });//委任書中譯本
            mapList.Add(new AttachMapping { brColValue = remark1, mapValue = "Z1", docType = "E68" });//再授權契約書
            mapList.Add(new AttachMapping { brColValue = remark1, mapValue = "Z1C", docType = "E69" });//再授權契約書中文譯本
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
