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
				ReportCode = "FR1",
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
		string docFileName = "[延展註冊]-" + ipoRpt.Seq + ".docx";
		
		Dictionary<string, string> _tplFile = new Dictionary<string, string>(){
			{"apply", Server.MapPath("~/ReportTemplate/申請書/405延展註冊申請書FR1.docx")},
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
			//變更事項
			string ncname1 = "";//變更商標/標章名稱
			string mod_pul = "";//防護商標/標章變更
			string mod_agttype = "";//代理人異動
			using (DataTable dtTranList = ipoRpt.TranList) {
				if (dtTranList.Rows.Count > 0) {
					ncname1 = dtTranList.Rows[0]["ncname1"].ToString().Trim().ToXmlUnicode();
				}
			}
			using (DataTable dtTran = ipoRpt.Tran) {
				if (dtTran.Rows.Count > 0) {
					if (dtTran.Rows[0]["mod_pul"].ToString().Trim() == "Y") {
						mod_pul = "是";
					}

					if (dtTran.Rows[0]["mod_agttype"].ToString().Trim() == "C") {
						mod_agttype = "變更";
					} else if (dtTran.Rows[0]["mod_agttype"].ToString().Trim() == "A") {
						mod_agttype = "新增";
					} else if (dtTran.Rows[0]["mod_agttype"].ToString().Trim() == "D") {
						mod_agttype = "撤銷";
					}
				}
			}
			if ((ncname1 + mod_pul + mod_agttype) != "") {
				ipoRpt.CopyBlock("b_tran");
				ipoRpt.ReplaceBookmark("ncname1", ncname1, true);
				ipoRpt.ReplaceBookmark("mod_pul", mod_pul, true);
				ipoRpt.ReplaceBookmark("mod_agttype", mod_agttype, true);
			}

			//延展商標權範圍及內容
			ipoRpt.CopyBlock("b_extend1");
			if (dmt.Rows[0]["mark"].ToString() == "N") {
				ipoRpt.CopyBlock("b_extend2");
			} else if (dmt.Rows[0]["mark"].ToString() == "Y") {
				using (DataTable dtGoods = ipoRpt.Goods) {
					for (int i = 0; i < dtGoods.Rows.Count; i++) {
						ipoRpt.CopyBlock("b_extend3");
						ipoRpt.ReplaceBookmark("good_num", (i + 1).ToString());
						ipoRpt.ReplaceBookmark("ext_class", dtGoods.Rows[i]["pclass"].ToString());
						ipoRpt.ReplaceBookmark("ext_goodname", dtGoods.Rows[i]["dmt_goodname"].ToString().Trim(), true);
					}
				}
			}
			//繳費資訊
			ipoRpt.CreateFees();
			//備註
			using (DataTable dtTran = ipoRpt.Tran) {
				string remark = "";
				if (dtTran.Rows.Count > 0) {
					if (dtTran.Rows[0]["other_item"].ToString().Trim() != "") {
						string[] arrRemark = dtTran.Rows[0]["other_item"].ToString().Trim().Split('|');
						int lineNo = 0;
						foreach (var arrItem in arrRemark) {
							if (arrItem.IndexOf(";") > -1) {
								string[] oitem = arrItem.Split(';');
								if (oitem[0].IndexOf(",") > -1) {//本案於Ｏ年Ｏ月Ｏ日，另案辦理移轉案 ／授權案／補證案。
									string tmp_remark = "";
									DateTime remarkdate;
									if (DateTime.TryParse(oitem[0].Split(',')[1], out remarkdate)) {
										tmp_remark = "本案於" + remarkdate.ToLongTwDate().Replace("民國", "") + "，另案辦理";
									}
									switch (oitem[1]) {
										case "FI1":
											tmp_remark += "補證案。";
											break;
										case "FT1":
											tmp_remark += "移轉案。";
											break;
										case "FL1":
											tmp_remark += "授權案。";
											break;
									}
									remark += "\n" + (++lineNo) + "." + tmp_remark;
								} else {//其他備註
									if (oitem[0] == "Z") {
										if (oitem[1].IndexOf(",") > -1) {//備註為ZZ且後面有接說明
											remark += "\n" + (++lineNo) + "." + oitem[1].Split(',')[1];
										}
									}
								}
							}
						}
					}
				}
				ipoRpt.CopyBlock("b_remark");
				ipoRpt.ReplaceBookmark("remark", remark, true);
			}

			//附送書件
			ipoRpt.CreateAttach();
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
