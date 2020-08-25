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
	protected DBHelper conn = null;

	private void Page_Load(System.Object sender, System.EventArgs e) {
		Response.CacheControl = "Private";
		Response.AddHeader("Pragma", "no-cache");
		Response.Expires = -1;
		Response.Clear();

		in_scode = (Request["in_scode"] ?? "").ToString();//n428
		in_no = (Request["in_no"] ?? "").ToString();//20160902001
		case_sqlno = (Request["case_sqlno"] ?? "").ToString();//16090001
		try {
            conn = new DBHelper(Session["btbrtdb"].ToString(), false).Debug(false);
			ipoRpt = new IPOReport(Session["btbrtdb"].ToString(), in_scode, in_no, case_sqlno)
			{
				ReportCode = "FC1",
				RectitleFlag = (Request["rectitle_flag"] ?? "").ToString(),//Y
				RectitleTitle = (Request["receipt_title"] ?? "").ToString(),//A
				RectitleName = (Request["rectitle_name"] ?? "").ToString(),//英業達股份有限公司
				BaseRptAPTag = "申請變更人",
			};
			WordOut();
		}
		finally {
			if (ipoRpt != null) ipoRpt.Close();
			if (conn != null) conn.Dispose();
		}
	}

	protected void WordOut() {
		string docFileName = "[註冊前變更]-" + ipoRpt.Seq + ".docx";
		
		Dictionary<string, string> _tplFile = new Dictionary<string, string>(){
			{"apply", Server.MapPath("~/ReportTemplate/申請書/502註冊前變更申請書FC1.docx")},
			{"base", Server.MapPath("~/ReportTemplate/申請書/00基本資料表.docx")}
		};
		ipoRpt.CloneFromFile(_tplFile, true);

		DataTable dmt = ipoRpt.Dmt;
		if (dmt.Rows.Count > 0) {
			//標題區塊
			ipoRpt.CopyBlock("b_title");
			//註冊申請案號
			ipoRpt.ReplaceBookmark("apply_no", dmt.Rows[0]["apply_no"].ToString().Trim());
			//事務所或申請人案件編號
			ipoRpt.ReplaceBookmark("seq", ipoRpt.Seq + "(" + DateTime.Today.ToString("yyyyMMdd") + ")");
			//商標或標章名稱
			ipoRpt.ReplaceBookmark("appl_name", dmt.Rows[0]["appl_name"].ToString().ToXmlUnicode());
			//商標或標章種類
			ipoRpt.ReplaceBookmark("s_mark", dmt.Rows[0]["s_marknm"].ToString());
			//變更事項
			ipoRpt.CopyBlock("b_mod");
			//申請人名稱
			var mod_ap = ipoRpt.Tran.Rows[0].SafeRead("mod_ap", "").ToCharArray();
			if (mod_ap.Length >= 1 && mod_ap[0] == 'Y') {
				ipoRpt.ReplaceBookmark("mod_ap1", "是");
			} else {
				ipoRpt.ReplaceBookmark("mod_ap1", "", true);
			}
			//申請人地址
			var mod_apaddr = ipoRpt.Tran.Rows[0].SafeRead("mod_apaddr", "").ToCharArray();
			if (mod_apaddr.Length >= 1 && mod_apaddr[0] == 'Y') {
				ipoRpt.ReplaceBookmark("mod_apaddr1", "是");
			} else {
				ipoRpt.ReplaceBookmark("mod_apaddr1", "", true);
			}
			//代表人或負責人
			var mod_aprep = ipoRpt.Tran.Rows[0].SafeRead("mod_aprep", "").ToCharArray();
			if (mod_aprep.Length >= 1 && mod_aprep[0] == 'Y') {
				ipoRpt.ReplaceBookmark("mod_aprep1", "是");
			} else {
				ipoRpt.ReplaceBookmark("mod_aprep1", "", true);
			}
			//代理人
			var mod_agt = ipoRpt.Tran.Rows[0].SafeRead("mod_agt", "").ToCharArray();
			if (mod_agt.Length >= 1 && mod_agt[0] == 'Y') {
				ipoRpt.ReplaceBookmark("mod_agt1", "是");
			} else {
				ipoRpt.ReplaceBookmark("mod_agt1", "", true);
			}
			//代理人地址
			var mod_agtaddr = ipoRpt.Tran.Rows[0].SafeRead("mod_agtaddr", "").ToCharArray();
			if (mod_agtaddr.Length >= 1 && mod_agtaddr[0] == 'Y') {
				ipoRpt.ReplaceBookmark("mod_agtaddr1", "是");
			} else {
				ipoRpt.ReplaceBookmark("mod_agtaddr1", "", true);
			}

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
			//原申請人
			if (mod_ap.Length >= 1 && mod_ap[0] == 'Y') {
				using (DataTable dtModAp = ipoRpt.TranListAP) {
					for (int i = 0; i < dtModAp.Rows.Count; i++) {
						ipoRpt.CopyBlock("b_mod_ap");
						ipoRpt.ReplaceBookmark("mod_ap_num", (i + 1).ToString());
						ipoRpt.ReplaceBookmark("mod_ap_cname_title", dtModAp.Rows[i]["Title_cname"].ToString());
						ipoRpt.ReplaceBookmark("mod_ap_ename_title", dtModAp.Rows[i]["Title_ename"].ToString());
                        ipoRpt.ReplaceBookmark("mod_ap_cname", dtModAp.Rows[i]["Cname_string"].ToString().ToXmlUnicode());
                        ipoRpt.ReplaceBookmark("mod_ap_ename", dtModAp.Rows[i]["Ename_string"].ToString().ToXmlUnicode(true), true);
					}
				}
			}
			//繳費資訊
			ipoRpt.CreateFees();
			//備註(其他變更事項)
			using (DataTable dtTran = ipoRpt.Tran) {
				string remark = "";
				int o = 0;
				//代表人或負責人印鑑
				var mod_oth1 = ipoRpt.Tran.Rows[0].SafeRead("mod_oth1", "").ToCharArray();
				if (mod_oth1.Length >= 1 && mod_oth1[0] == 'Y') {
					remark += "\n" + (++o) + ".變更代表人印鑑。";
				}
				//申請人印鑑
				var mod_oth = ipoRpt.Tran.Rows[0].SafeRead("mod_oth", "").ToCharArray();
				if (mod_oth.Length >= 1 && mod_oth[0] == 'Y') {
					remark += "\n" + (++o) + ".變更申請人印鑑。";
				}
				//選定代表人
				var mod_claim1 = ipoRpt.Tran.Rows[0].SafeRead("mod_claim1", "").ToCharArray();
				if (mod_claim1.Length >= 1 && mod_claim1[0] == 'Y') {
					remark += "\n" + (++o) + ".變更選定代表人。";
				}
				//代理人印鑑
				var mod_oth2 = ipoRpt.Tran.Rows[0].SafeRead("mod_oth2", "").ToCharArray();
				if (mod_oth2.Length >= 1 && mod_oth2[0] == 'Y') {
					remark += "\n" + (++o) + ".變更代理人印鑑。";
				}

				if (remark != "") {
					ipoRpt.CopyBlock("b_remark");
					ipoRpt.ReplaceBookmark("remark", remark, true);
				}
			}
            
			//附送書件
            //ipoRpt.CreateAttach();
            List<AttachMapping> mapList = new List<AttachMapping>();
            mapList.Add(new AttachMapping { mapValue = "*", docType = "02" });//委任書(*表必備文件)
            mapList.Add(new AttachMapping { mapValue = "*", docType = "17" });//基本資料表(*表必備文件)
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
