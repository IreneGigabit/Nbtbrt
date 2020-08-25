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
				ReportCode = "FC2",
				RectitleFlag = (Request["rectitle_flag"] ?? "").ToString(),//Y
				RectitleTitle = (Request["receipt_title"] ?? "").ToString(),//A
				RectitleName = (Request["rectitle_name"] ?? "").ToString(),//英業達股份有限公司
				//申請人身分類別對應
				AP_marknm = new Dictionary<string, string>() { { "I", "商標(標章)權人" }, { "A", "被授權人" }, { "B", "再被授權人" }, { "C", "質權人" } }
			};
			WordOut();
		}
		finally {
			if (ipoRpt != null) ipoRpt.Close();
		}
	}

	protected void WordOut() {
		string docFileName = "[註冊變更]-" + ipoRpt.Seq + ".docx";
		
		Dictionary<string, string> _tplFile = new Dictionary<string, string>(){
			{"apply", Server.MapPath("~/ReportTemplate/申請書/406註冊變更申請書FC2.docx")},
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
			//變更事項
			ipoRpt.CopyBlock("b_mod");
			//商標權人中文名稱
			var mod_ap = ipoRpt.Tran.Rows[0].SafeRead("mod_ap", "").ToCharArray();
			if (mod_ap.Length >= 2 && mod_ap[1] == 'Y') {
				ipoRpt.ReplaceBookmark("mod_ap1", "是");
			} else {
				ipoRpt.ReplaceBookmark("mod_ap1", "", true);
			}
			//商標權人英文名稱
			if (mod_ap.Length >= 3 && mod_ap[2] == 'Y') {
				ipoRpt.ReplaceBookmark("mod_ap2", "是");
			} else {
				ipoRpt.ReplaceBookmark("mod_ap2", "", true);
			}
			//商標權人印章
			var mod_oth = ipoRpt.Tran.Rows[0].SafeRead("mod_oth", "").ToCharArray();
			if (mod_oth.Length >= 1 && mod_oth[0] == 'Y') {
				ipoRpt.ReplaceBookmark("mod_oth", "是");
			} else {
				ipoRpt.ReplaceBookmark("mod_oth", "", true);
			}
			//商標權人中文地址
			var mod_apaddr = ipoRpt.Tran.Rows[0].SafeRead("mod_apaddr", "").ToCharArray();
			if (mod_apaddr.Length >= 1 && mod_apaddr[0] == 'Y') {
				ipoRpt.ReplaceBookmark("mod_apaddr1", "是");
			} else {
				ipoRpt.ReplaceBookmark("mod_apaddr1", "", true);
			}
			//商標權人英文地址
			if (mod_apaddr.Length >= 2 && mod_apaddr[1] == 'Y') {
				ipoRpt.ReplaceBookmark("mod_apaddr2", "是");
			} else {
				ipoRpt.ReplaceBookmark("mod_apaddr2", "", true);
			}
			//代表人中文名稱
			var mod_aprep = ipoRpt.Tran.Rows[0].SafeRead("mod_aprep", "").ToCharArray();
			if (mod_aprep.Length >= 1 && mod_aprep[0] == 'Y') {
				ipoRpt.ReplaceBookmark("mod_aprep1", "是");
			} else {
				ipoRpt.ReplaceBookmark("mod_aprep1", "", true);
			}
			//代表人英文名稱
			if (mod_aprep.Length >= 2 && mod_aprep[1] == 'Y') {
				ipoRpt.ReplaceBookmark("mod_aprep2", "是");
			} else {
				ipoRpt.ReplaceBookmark("mod_aprep2", "", true);
			}
			//代表人印章
			var mod_oth1 = ipoRpt.Tran.Rows[0].SafeRead("mod_oth1", "").ToCharArray();
			if (mod_oth1.Length >= 1 && mod_oth1[0] == 'Y') {
				ipoRpt.ReplaceBookmark("mod_oth1", "是");
			} else {
				ipoRpt.ReplaceBookmark("mod_oth1", "", true);
			}
			//選定代表人
			var mod_claim1 = ipoRpt.Tran.Rows[0].SafeRead("mod_claim1", "").ToCharArray();
			if (mod_claim1.Length >= 1 && mod_claim1[0] == 'Y') {
				ipoRpt.ReplaceBookmark("mod_claim1", "是");
			} else {
				ipoRpt.ReplaceBookmark("mod_claim1", "", true);
			}
			//代理人異動
			var mod_agt = ipoRpt.Tran.Rows[0].SafeRead("mod_agt", "").ToCharArray();
			if (mod_agt.Length >= 1 && mod_agt[0] == 'Y') {
				if (ipoRpt.Tran.Rows[0].SafeRead("mod_agttype", "") == "C")
					ipoRpt.ReplaceBookmark("mod_agttype", "變更");
				else if (ipoRpt.Tran.Rows[0].SafeRead("mod_agttype", "") == "A")
					ipoRpt.ReplaceBookmark("mod_agttype", "新增");
				else if (ipoRpt.Tran.Rows[0].SafeRead("mod_agttype", "") == "D")
					ipoRpt.ReplaceBookmark("mod_agttype", "撤銷");
				else
					ipoRpt.ReplaceBookmark("mod_agttype", "");
			} else {
				ipoRpt.ReplaceBookmark("mod_agttype", "", true);
			}
			//變更商標或標章名稱
			var mod_dmt = ipoRpt.Tran.Rows[0].SafeRead("mod_dmt", "").ToCharArray();
			if (mod_dmt.Length >= 1 && mod_dmt[0] == 'Y') {
				string ncname1 = "";
				using (DataTable dtTranList = ipoRpt.TranList) {
					if (dtTranList.Rows.Count > 0) {
						ncname1 = dtTranList.Rows[0]["cname"].ToString().Trim().ToXmlUnicode();
					}
				}
				ipoRpt.ReplaceBookmark("mod_dmt", ncname1);
			} else {
				ipoRpt.ReplaceBookmark("mod_dmt", "", true);
			}
			//修正使用規範書
			var mod_oitem1 = ipoRpt.Tran.Rows[0].SafeRead("other_item1", "").Split(',');
			if (mod_oitem1.Length >= 2 && mod_oitem1[0] == "Y") {
				if (mod_oitem1[1] == "N")
					ipoRpt.ReplaceBookmark("mod_oitem1", "團體商標");
				else if (mod_oitem1[1] == "M")
					ipoRpt.ReplaceBookmark("mod_oitem1", "團體標章");
				else if (mod_oitem1[1] == "L")
					ipoRpt.ReplaceBookmark("mod_oitem1", "證明標章");
				else
					ipoRpt.ReplaceBookmark("mod_oitem1", "");
			} else {
				ipoRpt.ReplaceBookmark("mod_oitem1", "", true);
			}
			//質權人名稱變更
			var mod_claim2 = ipoRpt.Tran.Rows[0].SafeRead("mod_claim2", "").ToCharArray();
			if (mod_claim2.Length >= 1 && mod_claim2[0] == 'Y') {
				ipoRpt.ReplaceBookmark("mod_claim2", "是");
			} else {
				ipoRpt.ReplaceBookmark("mod_claim2", "", true);
			}
			//被授權人名稱變更
			ipoRpt.ReplaceBookmark("mod_unknown", "", true);
			//質權移轉
            var mod_oitem2 = ipoRpt.Tran.Rows[0].SafeRead("other_item2", "").Split(',');
			if (mod_oitem2.Length >= 2 && mod_oitem2[0] == "Y") {
				if (mod_oitem2[1] == "A")
					ipoRpt.ReplaceBookmark("mod_oitem2", "有償讓與");
				else if (mod_oitem2[1] == "B")
					ipoRpt.ReplaceBookmark("mod_oitem2", "無償讓與");
				else if (mod_oitem2[1] == "C")
					ipoRpt.ReplaceBookmark("mod_oitem2", "繼承");
				else if (mod_oitem2[1] == "D")
					ipoRpt.ReplaceBookmark("mod_oitem2", "其他法定移轉");
				else
					ipoRpt.ReplaceBookmark("mod_oitem2", "");
			} else {
				ipoRpt.ReplaceBookmark("mod_oitem2", "", true);
			}

			//申請人
			using (DataTable dtAp = ipoRpt.Apcust) {
				for (int i = 0; i < dtAp.Rows.Count; i++) {
					ipoRpt.CopyBlock("b_apply");
					ipoRpt.ReplaceBookmark("apply_num", (i + 1).ToString());
					if (ipoRpt.AP_marknm != null && ipoRpt.AP_marknm.ContainsKey(dmt.Rows[0]["mark"].ToString().Trim())) {
						ipoRpt.ReplaceBookmark("ap_mark", ipoRpt.AP_marknm[dmt.Rows[0]["mark"].ToString().Trim()]);
					} else {
						ipoRpt.ReplaceBookmark("ap_mark", "");
					}
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
			//繳費資訊
			ipoRpt.CreateFees();
			//備註
			using (DataTable dtTran = ipoRpt.Tran) {
				string remark = "";
				if (dtTran.Rows.Count > 0) {
					string other_item = dtTran.Rows[0]["other_item"].ToString().Trim();
					if (other_item.IndexOf(";") > -1) {
						string[] oitem = other_item.Split(';');
						if (oitem[0] != "") {//本件商標(標章)於Ｏ年Ｏ月Ｏ日，另案辦理移轉案 ／授權案／補證案。
							remark = "本件商標(標章)於" + oitem[0] + "，另案辦理";
							switch (oitem[1]) {
								case "FT1":
									remark += "移轉案。";
									break;
								case "FL1":
									remark += "授權案。";
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
										remark += "__案。";
									break;
							}
						}
					}
				}
				ipoRpt.CopyBlock("b_remark");
				ipoRpt.ReplaceBookmark("remark", remark, true);
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
