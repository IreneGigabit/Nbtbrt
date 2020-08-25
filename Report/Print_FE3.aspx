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
				ReportCode = "FE3",
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
		string docFileName = "[聲音商標註冊]-" + ipoRpt.Seq + ".docx";
		
		Dictionary<string, string> _tplFile = new Dictionary<string, string>(){
			{"apply", Server.MapPath("~/ReportTemplate/申請書/104聲音商標註冊申請書FE3.docx")},
			{"base", Server.MapPath("~/ReportTemplate/申請書/00基本資料表.docx")}
		};
		ipoRpt.CloneFromFile(_tplFile, true);
		
		DataTable dmt = ipoRpt.Dmt;
		if (dmt.Rows.Count > 0) {
			//標題區塊
			ipoRpt.CopyBlock("b_title");
			//事務所或申請人案件編號
			ipoRpt.ReplaceBookmark("seq", ipoRpt.Seq + "(" + DateTime.Today.ToString("yyyyMMdd")+")");
			//商標名稱
			ipoRpt.ReplaceBookmark("appl_name", dmt.Rows[0]["appl_name"].ToString().ToXmlUnicode());
			//圖樣顏色
			ipoRpt.ReplaceBookmark("color", dmt.Rows[0]["colornm"].ToString());
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
			//商標描述及樣本
			ipoRpt.CopyBlock("b_draw_desc");
			ipoRpt.ReplaceBookmark("draw_mark4", dmt.Rows[0]["remark4"].ToString().Trim());
			ipoRpt.ReplaceBookmark("sound", ipoRpt.Sound);
			
			//主張優先權
			string ncountry = dmt.Rows[0]["ncountry"].ToString().Trim();
			string prior_no = dmt.Rows[0]["prior_no"].ToString().Trim();
			string prior_date = "";
			if (dmt.Rows[0]["prior_date"] != System.DBNull.Value && dmt.Rows[0]["prior_date"] != null) {
				prior_date = Convert.ToDateTime(dmt.Rows[0]["prior_date"]).ToShortTwDate();
			}
			if ((prior_date + ncountry + prior_no) != "") {
				ipoRpt.CopyBlock("b_prior");
				ipoRpt.ReplaceBookmark("prior_date", prior_date, true);
				ipoRpt.ReplaceBookmark("ncountry", ncountry, true);
				ipoRpt.ReplaceBookmark("prior_no", prior_no, true);
			}
			//主張展覽會優先權
			using (DataTable dtShow = ipoRpt.Show) {
				for (int i = 0; i < dtShow.Rows.Count; i++) {
					string show_date = "";
					if (dtShow.Rows[i]["show_date"] != System.DBNull.Value && dtShow.Rows[i]["show_date"] != null) {
						show_date = Convert.ToDateTime(dtShow.Rows[i]["show_date"]).ToShortTwDate();
					}
					ipoRpt.CopyBlock("b_show");
					ipoRpt.ReplaceBookmark("show_date", show_date, true);
					ipoRpt.ReplaceBookmark("show_name", dtShow.Rows[i]["show_name"].ToString(), true);
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
			//商品類別
			using (DataTable dtGoods = ipoRpt.Goods) {
				if (dtGoods.Rows.Count == 0) {
					ipoRpt.CopyBlock("b_goods");
					ipoRpt.ReplaceBookmark("good_num", "1");
					ipoRpt.ReplaceBookmark("class", "");
					ipoRpt.ReplaceBookmark("dmt_grp_code", "", true);
					ipoRpt.ReplaceBookmark("dmt_goodname", "");
				} else {
					for (int i = 0; i < dtGoods.Rows.Count; i++) {
						ipoRpt.CopyBlock("b_goods");
						ipoRpt.ReplaceBookmark("good_num", (i + 1).ToString());
						ipoRpt.ReplaceBookmark("class", dtGoods.Rows[i]["pclass"].ToString());
						ipoRpt.ReplaceBookmark("dmt_grp_code", dtGoods.Rows[i]["dmt_grp_code"].ToString().Trim(),true);
						ipoRpt.ReplaceBookmark("dmt_goodname", dtGoods.Rows[i]["dmt_goodname"].ToString().Trim(),true);
					}
				}
			}
			//繳費資訊
			ipoRpt.CreateFees();
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
