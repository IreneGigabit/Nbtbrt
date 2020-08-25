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
				ReportCode = "FD1",
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
		string docFileName = "[申請案分割]-" + ipoRpt.Seq + ".docx";
		
		Dictionary<string, string> _tplFile = new Dictionary<string, string>(){
			{"apply", Server.MapPath("~/ReportTemplate/申請書/503註冊申請案分割申請書FD1.docx")},
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
			//商標或標章樣態
			if (dmt.Rows[0]["s_mark2"].ToString().Trim() == "A") {
				ipoRpt.ReplaceBookmark("s_mark2", "平面");
			} else if (dmt.Rows[0]["s_mark2"].ToString().Trim() == "B") {
				ipoRpt.ReplaceBookmark("s_mark2", "立體");
			} else if (dmt.Rows[0]["s_mark2"].ToString().Trim() == "C") {
				ipoRpt.ReplaceBookmark("s_mark2", "聲音");
			} else if (dmt.Rows[0]["s_mark2"].ToString().Trim() == "C") {
				ipoRpt.ReplaceBookmark("s_mark2", "顏色");
			} else {
				ipoRpt.ReplaceBookmark("s_mark2", "平面/立體/聲音/顏色");
			}
			//商標或標章種類
			ipoRpt.ReplaceBookmark("s_mark", dmt.Rows[0]["s_marknm"].ToString());
			//分割件數
			ipoRpt.ReplaceBookmark("tot_num", dmt.Rows[0]["tot_num"].ToString());
			//商標圖樣
			if (dmt.Rows[0]["draw_file"].ToString() != "") {
                try {
                    ipoRpt.AppendImage(new ImageFile(Server.MapPath(dmt.Rows[0]["draw_file"].ToString())));
                }
                catch (FileNotFoundException) {
                    ipoRpt.AddParagraph();
                    ipoRpt.AddText("找不到檔案(" + dmt.Rows[0]["draw_file"].ToString() + ")！！", System.Drawing.Color.Red);
                    ipoRpt.AddParagraph();
                }
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
			//分割後類別
            //string SQL = "select t.case_sqlno,t.mark,g.* " +
            //"from dmt_temp t " +
            //"join casedmt_good g on t.in_no=g.in_no and t.in_scode=g.in_scode and t.case_sqlno=g.case_sqlno " +
            //"where t.in_no = '" + in_no + "' and t.in_scode='" + in_scode + "' and t.case_sqlno<>0 " +
            //"order by cast(g.class as int) ";
			string SQL = "select DENSE_RANK() OVER(ORDER BY t.case_sqlno) AS ROWID,t.case_sqlno,t.mark,g.* " +
            "from dmt_temp t " +
            "join casedmt_good g on t.in_no=g.in_no and t.in_scode=g.in_scode and t.case_sqlno=g.case_sqlno " +
            "where t.in_no = '" + in_no + "' and t.in_scode='" + in_scode + "' and t.case_sqlno<>0 " +
            "order by t.case_sqlno,cast(g.class as int) ";
			using (DataTable dtGoods = new DataTable()) {
				conn.DataTable(SQL, dtGoods);
				for (int i = 0; i < dtGoods.Rows.Count; i++) {
					ipoRpt.CopyBlock("b_goods");
                    //ipoRpt.ReplaceBookmark("good_num", (i + 1).ToString());
                    ipoRpt.ReplaceBookmark("good_num", "");
                    ipoRpt.ReplaceBookmark("good_seq", dtGoods.Rows[i]["ROWID"].ToString().Trim());
					if (dtGoods.Rows[i].SafeRead("mark", "") == "T") {
						string pclass = dtGoods.Rows[i]["class"].ToString().Trim();
						if (pclass.Length >= 3) pclass = pclass.Substring(1);
						ipoRpt.ReplaceBookmark("class", pclass);
						ipoRpt.ReplaceBookmark("good_type", "商品服務名稱");
					} else {
						ipoRpt.ReplaceBookmark("class", "", true);
						ipoRpt.ReplaceBookmark("good_type", "證明標的及內容");
					}
					ipoRpt.ReplaceBookmark("dmt_goodname", dtGoods.Rows[i]["dmt_goodname"].ToString().Trim(), true);
				}
			}
			//本案另涉有他案
			using (DataTable dtTran = ipoRpt.Tran) {
				if (dtTran.Rows.Count > 0) {
					string other_item = dtTran.Rows[0]["other_item"].ToString().Trim();
					if (other_item.IndexOf(";") > -1) {
						string[] oitem = other_item.Split(';');
						if (Regex.IsMatch(oitem[1], @"(DO1|DI1|FT1|FC1|FR1)")) {
							ipoRpt.CopyBlock("b_other");
							ipoRpt.ReplaceBookmark("other_date", Convert.ToDateTime(oitem[0]).ToShortTwDate());
							switch (oitem[1]) {
								case "DO1":
									ipoRpt.ReplaceBookmark("other_item", "異議案");
									break;
								case "DI1":
									ipoRpt.ReplaceBookmark("other_item", "評定案");
									break;
								case "FT1":
									ipoRpt.ReplaceBookmark("other_item", "移轉案");
									break;
								case "FC1":
									ipoRpt.ReplaceBookmark("other_item", "變更案");
									break;
								case "FR1":
									ipoRpt.ReplaceBookmark("other_item", "延展案");
									break;
							}
						}
					}
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
						if (oitem[1]=="ZZ") {//本案於Ｏ年Ｏ月Ｏ日，另案辦理XX案。
							remark = "本案於" + Convert.ToDateTime(oitem[0]).ToLongTwDate().Replace("民國","") + "，另案辦理";
							if (oitem[2] != null && oitem[2] != "")
								remark += oitem[2] + "案。";
							else
								remark += "__案。";
						}
					}
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
