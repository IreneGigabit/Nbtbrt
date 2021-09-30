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
				ReportCode = "FL2",
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
        string docFileName = "[再授權]-" + ipoRpt.Seq + ".docx";

		Dictionary<string, string> _tplFile = new Dictionary<string, string>(){
			{"apply", Server.MapPath("~/ReportTemplate/申請書/402再授權登記申請書FL2.docx")},
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
                ipoRpt.ReplaceBookmark("mark", "授權人(原授權登記案之被授權人)");
            } else if (dmt.Rows[0]["mark"].ToString() == "B") {
                ipoRpt.BaseRptAPTag = "被授權人";
                ipoRpt.BaseRptModTag = "授權人";//關係人類別
                ipoRpt.ReplaceBookmark("mark", "被授權人(再授權使用人)");
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
                    //授權期間
                    if (dtTran.Rows[0]["mod_claim1"].ToString().Trim() == "B") {//區間
                        string term1 = Convert.ToDateTime(dtTran.Rows[0]["term1"]).ToShortTwDate();
                        string term2 = Convert.ToDateTime(dtTran.Rows[0]["term2"]).ToShortTwDate();
                        ipoRpt.ReplaceBookmark("tran_term1", term1);
                        ipoRpt.ReplaceBookmark("tran_term2", term2);
                    } else if (dtTran.Rows[0]["mod_claim1"].ToString().Trim() == "E") {
                        string term1 = Convert.ToDateTime(dtTran.Rows[0]["term1"]).ToShortTwDate();
                        string term2 = dtTran.Rows[0]["other_item1"].ToString().Trim();
                        term2 = (term2 == "" ? "至本案商標權消滅" : term2);
                        ipoRpt.ReplaceBookmark("tran_term1", term1);
                        ipoRpt.ReplaceBookmark("tran_term2", term2);
                    }
                    //授權性質
                    if (dtTran.Rows[0]["mod_claim2"].ToString().Trim() == "A") {
                        ipoRpt.ReplaceBookmark("mod_claim2_type", "專屬再授權");
                    } else if (dtTran.Rows[0]["mod_claim2"].ToString().Trim() == "B") {
                        ipoRpt.ReplaceBookmark("mod_claim2_type", "非專屬再授權");
                    }
                    //授權區域
                    var mod_oitem2 = ipoRpt.Tran.Rows[0].SafeRead("other_item2", "").Split(',');
                    if (mod_oitem2[0] == "T") {
                        ipoRpt.ReplaceBookmark("other_item2_type", "中華民國全境");
                    } else if (mod_oitem2[0] == "O") {
                        ipoRpt.ReplaceBookmark("other_item2_type", (mod_oitem2.Length >= 2 ? mod_oitem2[1] : ""));
                    }
                }
            }

            //授權商品或服務
            ipoRpt.CopyBlock("b_class1");
            using (DataTable dtClass = ipoRpt.TranListClass) {
                if (dtClass.Rows.Count > 0) {
                    if (dtClass.Rows[0]["mod_type"].ToString() == "All") {
                        ipoRpt.CopyBlock("b_class2");
                    } else if (dtClass.Rows[0]["mod_type"].ToString() == "Part") {
                        for (int i = 0; i < dtClass.Rows.Count; i++) {
                            ipoRpt.CopyBlock("b_class3");
                            ipoRpt.ReplaceBookmark("good_num", (i + 1).ToString());
                            ipoRpt.ReplaceBookmark("mod_class", dtClass.Rows[i]["new_no"].ToString());
                            ipoRpt.ReplaceBookmark("mod_goodname", dtClass.Rows[i]["list_remark"].ToString().Trim(), true);
                        }
                    }
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
            mapList.Add(new AttachMapping { brColValue = remark1, mapValue = "Z5C", docType = "021" });//委任書中譯本
            mapList.Add(new AttachMapping { brColValue = remark1, mapValue = "Z1", docType = "E65" });//再授權契約書
            mapList.Add(new AttachMapping { brColValue = remark1, mapValue = "Z1C", docType = "E66" });//再授權契約書中文譯本
            mapList.Add(new AttachMapping { brColValue = remark1, mapValue = "Z4", docType = "E67" });//商標權人同意再授權證明文件
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
