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
				ReportCode = "FB7",
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
		string docFileName = "[申請案補送文件]-" + ipoRpt.Seq + ".docx";
		
		Dictionary<string, string> _tplFile = new Dictionary<string, string>(){
			{"apply", Server.MapPath("~/ReportTemplate/申請書/501註冊申請案補送文件申請書FB7.docx")},
			{"base", Server.MapPath("~/ReportTemplate/申請書/00基本資料表.docx")}
		};
		ipoRpt.CloneFromFile(_tplFile, true);

		DataTable dmt = ipoRpt.Dmt;
		if (dmt.Rows.Count > 0) {
			//標題區塊
			ipoRpt.CopyBlock("b_title");
			//申請號數
			ipoRpt.ReplaceBookmark("apply_no", dmt.Rows[0]["apply_no"].ToString().Trim());
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
				ipoRpt.ReplaceBookmark("agt_name1", dtAgt.Rows[0]["agt_name1"].ToString());
				ipoRpt.ReplaceBookmark("agt_name2", dtAgt.Rows[0]["agt_name2"].ToString());
			}
			//其他復申事項
			ipoRpt.CopyBlock("b_content");
			//繳費資訊
			ipoRpt.CreateFees();
            
			//附送書件
			//ipoRpt.CreateAttach();
            List<AttachMapping> mapList = new List<AttachMapping>();
            string other_item = ipoRpt.Tran.Rows[0]["other_item"].ToString();//補送文件勾選值
            mapList.Add(new AttachMapping { mapValue = "*", docType = "17" });//基本資料表(*表必備文件)
            mapList.Add(new AttachMapping { brColValue = other_item, mapValue = "Z4", docType = "02" });//委任書
            mapList.Add(new AttachMapping { brColValue = other_item, mapValue = "Z4C", docType = "021" });//委任書中譯本
            mapList.Add(new AttachMapping { brColValue = other_item, mapValue = "Z3", docType = "E23" });//商標陳述意見書
            mapList.Add(new AttachMapping { brColValue = other_item, mapValue = "Z5", docType = "E01" });//優先權文件
            mapList.Add(new AttachMapping { brColValue = other_item, mapValue = "Z5C", docType = "E02" });//優先權文件中譯本
            mapList.Add(new AttachMapping { brColValue = other_item, mapValue = "Z71", docType = "E03" });//展覽會文件
            mapList.Add(new AttachMapping { brColValue = other_item, mapValue = "Z71C", docType = "E04" });//展覽會文件中譯本
            mapList.Add(new AttachMapping { brColValue = other_item, mapValue = "Z7", docType = "E24" });//具結書
            mapList.Add(new AttachMapping { brColValue = other_item, mapValue = "Z8", docType = "E06" });//法人團體機關證明文件
            mapList.Add(new AttachMapping { brColValue = other_item, mapValue = "Z9", docType = "E14" });//證明之資格或能力之文件
            mapList.Add(new AttachMapping { brColValue = other_item, mapValue = "Z111", docType = "E09" });//團體商標申請人具代表性證明文件
            mapList.Add(new AttachMapping { brColValue = other_item, mapValue = "Z111", docType = "E15" });//證明標章申請人具代表性證明文件
            mapList.Add(new AttachMapping { brColValue = other_item, mapValue = "Z11", docType = "E18" });//聲明不從事商品之製造行銷或服務
            mapList.Add(new AttachMapping { brColValue = other_item, mapValue = "Z131", docType = "E10" });//團體商標使用規範書
            mapList.Add(new AttachMapping { brColValue = other_item, mapValue = "Z131C", docType = "E11" });//團體商標使用規範書中文譯本
            mapList.Add(new AttachMapping { brColValue = other_item, mapValue = "Z131", docType = "E12" });//團體標章使用規範書
            mapList.Add(new AttachMapping { brColValue = other_item, mapValue = "Z131C", docType = "E13" });//團體標章使用規範書中文譯本
            mapList.Add(new AttachMapping { brColValue = other_item, mapValue = "Z131", docType = "E16" });//證明標章使用規範書
            mapList.Add(new AttachMapping { brColValue = other_item, mapValue = "Z131C", docType = "E17" });//證明標章使用規範書中文譯本
            mapList.Add(new AttachMapping { brColValue = other_item, mapValue = "Z12", docType = "E05" });//法人資格證明文件
            mapList.Add(new AttachMapping { brColValue = other_item, mapValue = "Z15", docType = "E25" });//分割後之商標註冊申請書
            mapList.Add(new AttachMapping { brColValue = other_item, mapValue = "Z16", docType = "E21" });//變更證明文件
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
