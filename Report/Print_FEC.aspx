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
				ReportCode = "FEC",
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
		string docFileName = "[立體團體標章註冊]-" + ipoRpt.Seq + ".docx";
		
		Dictionary<string, string> _tplFile = new Dictionary<string, string>(){
			{"apply", Server.MapPath("~/ReportTemplate/申請書/207立體團體標章註冊申請書FEC.docx")},
			{"base", Server.MapPath("~/ReportTemplate/申請書/00基本資料表.docx")}
		};
		ipoRpt.CloneFromFile(_tplFile, true);
		
		DataTable dmt = ipoRpt.Dmt;
		if (dmt.Rows.Count > 0) {
			//標題區塊
			ipoRpt.CopyBlock("b_title");
			//事務所或申請人案件編號
			ipoRpt.ReplaceBookmark("seq", ipoRpt.Seq + "(" + DateTime.Today.ToString("yyyyMMdd")+")");
			//標章名稱
			ipoRpt.ReplaceBookmark("appl_name", dmt.Rows[0]["appl_name"].ToString().ToXmlUnicode());
			//圖樣顏色
			ipoRpt.ReplaceBookmark("color", dmt.Rows[0]["colornm"].ToString());
			//標章圖樣
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
			//聲明不專用
			ipoRpt.CopyBlock("b_oappl");
            ipoRpt.ReplaceBookmark("oappl_name", dmt.Rows[0]["oappl_name"].ToString().Trim().ToXmlUnicode(), true);
			//標章描述
			ipoRpt.CopyBlock("b_draw_desc");
			ipoRpt.ReplaceBookmark("draw_mark4", dmt.Rows[0]["remark4"].ToString().Trim());
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
			//表彰內容
			ipoRpt.CopyBlock("b_good");
			ipoRpt.ReplaceBookmark("good_name", dmt.Rows[0]["good_name"].ToString());
			//繳費資訊
			ipoRpt.CreateFees();
			//附送書件
			ipoRpt.CreateAttach();
			//具結
			ipoRpt.CopyBlock("b_sign");
			//視圖
			ipoRpt.CopyBlock("b_view1");
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
			ipoRpt.CopyBlock("b_view2");

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
