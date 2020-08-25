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
			ipoRpt = new IPOReport(Session["btbrtdb"].ToString(), in_scode, in_no, case_sqlno)
			{
				ReportCode = "FOF",
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
        string docFileName = "[退費]-" + ipoRpt.Seq + ".docx";
		
		Dictionary<string, string> _tplFile = new Dictionary<string, string>(){
			{"apply", Server.MapPath("~/ReportTemplate/申請書/608[商簡A]商標規費退費申請書FOF.docx")},
			{"base", Server.MapPath("~/ReportTemplate/申請書/00基本資料表.docx")}
		};
		ipoRpt.CloneFromFile(_tplFile, true);

		DataTable dmt = ipoRpt.Dmt;
		if (dmt.Rows.Count > 0) {
			//標題區塊
			ipoRpt.CopyBlock("b_title");
            //20180802依交辦的官方號碼決定
            if (dmt.Rows[0]["mark"].ToString() == "A") {
                ipoRpt.ReplaceBookmark("no_type", "申請案號");
                ipoRpt.ReplaceBookmark("apply_no", dmt.Rows[0]["apply_no"].ToString().Trim());
            } else if (dmt.Rows[0]["mark"].ToString() == "I") {
                ipoRpt.ReplaceBookmark("no_type", "註冊號");
                ipoRpt.ReplaceBookmark("apply_no", dmt.Rows[0]["issue_no"].ToString().Trim());
            }

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
			//申請內容
			ipoRpt.CopyBlock("b_content");
            var other_item2 = ipoRpt.Tran.Rows[0].SafeRead("other_item2", "").Split('|');
            if (other_item2.Length > 0) {
                ipoRpt.ReplaceBookmark("other_F_yy", other_item2[1]);
                if (other_item2[0] == "F1")
                    ipoRpt.ReplaceBookmark("other_F_type", "智商");
                else if (other_item2[0] == "F2")
                    ipoRpt.ReplaceBookmark("other_F_type", "慧商");
                else
                    ipoRpt.ReplaceBookmark("other_F_type", "");
                ipoRpt.ReplaceBookmark("other_F_word", other_item2[2]);
                ipoRpt.ReplaceBookmark("other_F_no", other_item2[3]);
                ipoRpt.ReplaceBookmark("debit_money", ipoRpt.Tran.Rows[0].SafeRead("debit_money", ""));
                ipoRpt.ReplaceBookmark("other_item1", ipoRpt.Tran.Rows[0].SafeRead("other_item1", ""));
                //4.	檢還之國庫支票抬頭請開：「#other_item#」。
                ipoRpt.ReplaceBookmark("other_item", ipoRpt.Tran.Rows[0].SafeRead("other_item", ""));
                //ipoRpt.ReplaceBookmark("other_item", "高玉駿");//20200206原依交辦內容帶,平淑測試後反應指定"高玉駿"
            } else {
                ipoRpt.ReplaceBookmark("other_F_yy", "");
                ipoRpt.ReplaceBookmark("other_F_type", "");
                ipoRpt.ReplaceBookmark("other_F_word", "");
                ipoRpt.ReplaceBookmark("other_F_no", "");
                ipoRpt.ReplaceBookmark("debit_money", "");
                ipoRpt.ReplaceBookmark("other_item1", "");
                ipoRpt.ReplaceBookmark("other_item", "");
            }

			//繳費資訊
			ipoRpt.CreateFees();
            
			//附送書件
			//ipoRpt.CreateAttach();
            List<AttachMapping> mapList = new List<AttachMapping>();
            mapList.Add(new AttachMapping { mapValue = "*", docType = "02" });//委任書(*表必備文件)
            mapList.Add(new AttachMapping { mapValue = "*", docType = "17" });//基本資料表(*表必備文件)
            mapList.Add(new AttachMapping { mapValue = "*", docType = "E72" });//電子收據
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
