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
				ReportCode = "FT1",
				RectitleFlag = (Request["rectitle_flag"] ?? "").ToString(),//Y
				RectitleTitle = (Request["receipt_title"] ?? "").ToString(),//A
				RectitleName = (Request["rectitle_name"] ?? "").ToString(),//英業達股份有限公司
				BaseRptAPTag = "受讓人",
			};
			WordOut();
		}
		finally {
			if (ipoRpt != null) ipoRpt.Close();
		}
	}

	protected void WordOut() {
		string docFileName = "[移轉登記]-" + ipoRpt.Seq + ".docx";

		Dictionary<string, string> _tplFile = new Dictionary<string, string>(){
			{"apply", Server.MapPath("~/ReportTemplate/申請書/408移轉登記申請書FT1.docx")},
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
			//移轉登記原因
			ipoRpt.CopyBlock("b_content");
			string remark1 = "|" + dmt.Rows[0]["remark1"].ToString().Trim() + "|";
			if (remark1.IndexOf("Z3") > -1) {
				ipoRpt.ReplaceBookmark("remark1", "合意(買賣)移轉");
			} else if (remark1.IndexOf("Z4") > -1) {
				ipoRpt.ReplaceBookmark("remark1", "繼承移轉");
			} else if (remark1.IndexOf("Z5") > -1) {
				ipoRpt.ReplaceBookmark("remark1", "贈與移轉");
			} else if (remark1.IndexOf("Z6") > -1) {
				ipoRpt.ReplaceBookmark("remark1", "拍賣移轉");
			} else if (remark1.IndexOf("Z7") > -1) {
				ipoRpt.ReplaceBookmark("remark1", "公司合併移轉");
			} else if (remark1.IndexOf("Z8") > -1) {
				ipoRpt.ReplaceBookmark("remark1", "團體標章或團體商標或證明標章移轉");
			} else if (remark1.IndexOf("Z9") > -1) {
				ipoRpt.ReplaceBookmark("remark1", "其他");
			} else {
				ipoRpt.ReplaceBookmark("remark1", "");
			}
			//其他原因
			string reason = "";
			//string pattern = "\\|Z9-(.+?)-Z9\\|";
			MatchCollection Matches = Regex.Matches(dmt.Rows[0]["remark1"].ToString().Trim(), @"\|Z9-(?<reason>.*)-Z9\|", RegexOptions.IgnoreCase);
			foreach (Match match in Matches) {
				reason += (Matches.Count > 1 ? "\n" : "") + match.Groups["reason"].Value;
			}
			ipoRpt.ReplaceBookmark("remark1_z9", reason, true);
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
								case "FC1":
									remark += "變更案。";
									break;
								case "FR1":
									remark += "延展案。";
									break;
								case "FP1":
									remark += "質權案。";
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
            mapList.Add(new AttachMapping { mapValue = "*", docType = "06" });//移轉契約書(*表必備文件)
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
