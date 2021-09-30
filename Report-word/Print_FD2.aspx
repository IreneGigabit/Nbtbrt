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
    protected DBHelper conn = null;

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
            conn = new DBHelper(Conn.btbrt, false).Debug(false);
            ipoRpt = new IPOReport(Conn.btbrt, in_scode, in_no, case_sqlno)
			{
				ReportCode = "FD2",
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
        string docFileName = "[註冊分割]-" + ipoRpt.Seq + ".docx";

        Dictionary<string, string> _tplFile = new Dictionary<string, string>(){
			{"apply", Server.MapPath("~/ReportTemplate/申請書/紙本/FD2_註冊分割申請書.docx")},
		};
        ipoRpt.CloneFromFile(_tplFile, true);

        DataTable dmt = ipoRpt.Dmt;
        if (dmt.Rows.Count > 0) {
            //標題區塊
            ipoRpt.CopyBlock("b_title");

            //日期
            ipoRpt.ReplaceBookmark("tyear", (DateTime.Today.Year - 1911).ToString());
            ipoRpt.ReplaceBookmark("tyear2", (DateTime.Today.Year - 1911).ToString());

            //金額
            if (Convert.ToInt32(dmt.Rows[0].SafeRead("fees", "")) > 0) {
                string strfees = Util.gfsTrnCurrencyNumToChineseText(dmt.Rows[0].SafeRead("fees", "0")).Replace("元整", "");
                ipoRpt.ReplaceBookmark("fees", strfees);
            }
            //註冊號數
            ipoRpt.ReplaceBookmark("issue_no", dmt.Rows[0].SafeRead("issue_no", ""));
            //商標或標章名稱
            ipoRpt.ReplaceBookmark("appl_name", dmt.Rows[0]["appl_name"].ToString().ToXmlUnicode());
            //商標或標章種類
            string[] smark = new string[] { "　", "　", "　", "　", "　" };
            if (dmt.Rows[0]["s_mark"].ToString() != "") {
                if (dmt.Rows[0]["s_mark"].ToString() == "S") {//92
                    smark[1] = "Ｖ";
                } else if (dmt.Rows[0]["s_mark"].ToString() == "N") {//團體商標
                    smark[2] = "Ｖ";
                } else if (dmt.Rows[0]["s_mark"].ToString() == "L") {//證明標章
                    smark[3] = "Ｖ";
                } else if (dmt.Rows[0]["s_mark"].ToString() == "M") {//團體標章
                    smark[4] = "Ｖ";
                }
            } else {
                smark[0] = "Ｖ";//商標
            }
            for (int i = 0; i < smark.Length; i++) {
                ipoRpt.ReplaceBookmark("smark" + (i + 1), smark[i]);
            }

            //分割件數
            ipoRpt.ReplaceBookmark("tot_num", dmt.Rows[0]["tot_num"].ToString());

            //申請人
            using (DataTable dtAp = ipoRpt.Apcust) {
                for (int i = 0; i < dtAp.Rows.Count; i++) {
                    DataRow drdap = dtAp.Rows[i];
                    ipoRpt.CopyTable("tbl_apply");
                    ipoRpt.ReplaceBookmark("apply_num", (i + 1).ToString());

                    //國籍
                    if (drdap["ap_country"].ToString() != "" && drdap["ap_country"].ToString() != "T") {
                        if (drdap["ap_country"].ToString() != "CM" && drdap["ap_country"].ToString() != "HO" && drdap["ap_country"].ToString() != "MC") {
                            ipoRpt.ReplaceBookmark("country_OTH", "Ｖ");
                            if (drdap["apcountry"].ToString() != "") {
                                ipoRpt.ReplaceBookmark("apcountry", drdap["apcountry"].ToString());
                            }
                        } else {
                            ipoRpt.ReplaceBookmark("country_CM0", "Ｖ");
                            if (drdap["ap_country"].ToString() == "CM") {
                                ipoRpt.ReplaceBookmark("country_CM", "Ｖ");
                            } else if (drdap["ap_country"].ToString() == "HO") {
                                ipoRpt.ReplaceBookmark("country_HO", "Ｖ");
                            } else if (drdap["ap_country"].ToString() == "MC") {
                                ipoRpt.ReplaceBookmark("country_MC", "Ｖ");
                            }
                        }
                    } else {
                        ipoRpt.ReplaceBookmark("country_T", "Ｖ");
                    }

                    //身分種類
                    if (drdap["apclass_name"].ToString() == "法人公司機關學校") {
                        ipoRpt.ReplaceBookmark("apclass_BX", "Ｖ");
                    } else if (drdap["apclass_name"].ToString() == "商號行號工廠") {
                        ipoRpt.ReplaceBookmark("apclass_AD", "Ｖ");
                    } else if (drdap["apclass_name"].ToString() == "自然人") {
                        ipoRpt.ReplaceBookmark("apclass_B", "Ｖ");
                    }

                    ipoRpt.ReplaceBookmark("apcust_no", drdap["c_id"].ToString());
                    ipoRpt.ReplaceBookmark("ap_cname", drdap.SafeRead("Cname_string","").Replace(",", "").ToXmlUnicode());
                    ipoRpt.ReplaceBookmark("ap_ename", drdap.SafeRead("ename_string", "").Replace(",", "").ToXmlUnicode());
                    ipoRpt.ReplaceBookmark("ap_crep", drdap["ap_crep"].ToString().ToXmlUnicode());
                    ipoRpt.ReplaceBookmark("ap_erep", drdap["ap_erep"].ToString().ToXmlUnicode());
                    ipoRpt.ReplaceBookmark("ap_caddr", drdap["c_addr"].ToString().ToXmlUnicode());
                    ipoRpt.ReplaceBookmark("ap_eaddr", drdap["e_addr"].ToString().ToXmlUnicode());
                    if (drdap["server_flag"].ToString() == "Y") {
                        ipoRpt.ReplaceBookmark("server_flag", "V");
                    }

                    //把沒填到的bookmark清空
                    string[] arrAP = { 
                            "country_T", "country_CM0", "country_CM", "country_HO", "country_MC" , "country_OTH" , "apcountry"
                            ,"apclass_B","apclass_BX","apclass_AD","server_flag"
                        };
                    foreach (string r in arrAP) {
                        ipoRpt.ReplaceBookmark(r, "");
                    }
                }
                if (dtAp.Rows.Count > 0) {
                    ipoRpt.ReplaceBookmark("apcust_num", dtAp.Rows.Count.ToString());
                }
            }
            //代理人
            ipoRpt.CopyBlock("b_agent");
            using (DataTable dtAgt = ipoRpt.Agent) {
                if (dtAgt.Rows.Count > 0) {
                    DataRow dragt = dtAgt.Rows[0];
                    //ID
                    string agt_id1 = "";
                    if (dragt.SafeRead("agt_id1", "") != "") {
                        agt_id1 += dragt.SafeRead("agt_id1", "");
                        if (dragt.SafeRead("agt_id2", "") != "") agt_id1 += "、" + dragt.SafeRead("agt_id2", "");
                    }
                    ipoRpt.ReplaceBookmark("agt_id1", agt_id1);
                    //姓名
                    string agt_name = "";
                    agt_name = dragt.SafeRead("agt_name1", "");
                    if (dragt.SafeRead("agt_name2", "") != "") {
                        agt_name += "、" + dragt.SafeRead("agt_name2", "");
                    }
                    ipoRpt.ReplaceBookmark("agt_name", agt_name.Replace(",", ""));
                    //地址
                    if (dragt.SafeRead("agt_addr", "") != "") {
                        ipoRpt.ReplaceBookmark("agt_addr", dragt.SafeRead("agt_zip", "") + dragt.SafeRead("agt_addr", ""));
                    }
                    //聯絡電話及分機
                    string strtel = dragt["agt_tel"].ToString();
                    if (dragt.SafeRead("agatt_tel0", "") != "") {
                        strtel += "(承辦電話：" + dragt.SafeRead("agatt_tel0", "") + "-";
                    }
                    if (dragt.SafeRead("agatt_tel", "") != "") {
                        strtel += dragt.SafeRead("agatt_tel", "");
                    }
                    if (dragt.SafeRead("agatt_tel1", "") != "") {
                        strtel += " 分機：" + dragt.SafeRead("agatt_tel1", "") + ")";
                    }
                    ipoRpt.ReplaceBookmark("agt_tel", strtel);
                    //傳真
                    ipoRpt.ReplaceBookmark("agt_fax", dragt.SafeRead("agt_fax", ""));
                }
            }

            //分割後商品／服務類別、名稱、證明標的及內容
            ipoRpt.CopyBlock("b_class");
            if (dmt.Rows[0].SafeRead("class", "") != "") {
                string SQL = "select DENSE_RANK() OVER(ORDER BY t.case_sqlno) AS ROWID,t.case_sqlno,t.mark,g.* " +
                "from dmt_temp t " +
                "join casedmt_good g on t.in_no=g.in_no and t.in_scode=g.in_scode and t.case_sqlno=g.case_sqlno " +
                "where t.in_no = '" + in_no + "' and t.in_scode='" + in_scode + "' and t.case_sqlno<>0 " +
                "order by t.case_sqlno,cast(g.class as int) ";
                DataTable dtGoods = new DataTable();
                conn.DataTable(SQL, dtGoods);
                for (int i = 0; i < dtGoods.Rows.Count; i++) {
                    ipoRpt.CopyTable("tbl_good");
                    ipoRpt.ReplaceBookmark("good_seq", Util.NumberToCh(dtGoods.Rows[i].SafeRead("ROWID", "0")));
                    if (dtGoods.Rows[i].SafeRead("mark", "") == "T") {//商品服務名稱
                        ipoRpt.ReplaceBookmark("good_class", dtGoods.Rows[i].SafeRead("class", ""));
                        ipoRpt.ReplaceBookmark("good_typeT", "R");//商品服務名稱(R=Wingdings 2字型的打勾)
                        ipoRpt.ReplaceBookmark("good_typeS", Convert.ToChar(163).ToString());//證明標的及內容
                    } else {
                        ipoRpt.ReplaceBookmark("good_class", "");
                        ipoRpt.ReplaceBookmark("good_typeT", Convert.ToChar(163).ToString());//商品服務名稱
                        ipoRpt.ReplaceBookmark("good_typeS", "R");//證明標的及內容(R=Wingdings 2字型的打勾)
                    }
                    ipoRpt.ReplaceBookmark("dmt_goodname", dtGoods.Rows[i]["dmt_goodname"].ToString().Trim(), true);
                }
            }
            ipoRpt.CopyBlock("b_class1");
            //具結
            ipoRpt.CopyBlock("b_sign");
            //備註
            ipoRpt.CopyBlock("b_remark");
            //本案另涉有他案
            using (DataTable dtTran = ipoRpt.Tran) {
                if (dtTran.Rows.Count > 0) {
                    string other_item = dtTran.Rows[0]["other_item"].ToString().Trim();
                    if (other_item.IndexOf(";") > -1) {
                        string[] oitem = other_item.Split(';');
                        if (Regex.IsMatch(oitem[1], @"(DO1|DI1|FT1|FC1|FR1)")) {
                            Sys.showLog(other_item);
                            Sys.showLog(oitem[1]);
                            ipoRpt.ReplaceBookmark("O_item1", "Ｖ");//另案辦理
                            ipoRpt.ReplaceBookmark("other_date", Convert.ToDateTime(oitem[0]).ToLongTwDate().Replace("民國", ""));
                            ipoRpt.ReplaceBookmark(oitem[1], "Ｖ");
                        } else if (oitem[1] == "ZZ") {
                            ipoRpt.ReplaceBookmark("ZZ", "Ｖ");//其他
                            ipoRpt.ReplaceBookmark("ZZ_detail", oitem[2]);
                        }
                    }
                }
            }
            //附件
            if (dmt.Rows[0].SafeRead("remark1", "") != "") {
                string[] arr_remark1 = dmt.Rows[0].SafeRead("remark1", "").Split('|');
                for (int I = 0; I < arr_remark1.Length; I++) {
                    if (Regex.IsMatch(arr_remark1[I], @"(Z1|Z1C|Z2|Z4)")) {
                        ipoRpt.ReplaceBookmark(arr_remark1[I], "Ｖ");
                        if (arr_remark1[I].Left(2) == "Z2") {
                            ipoRpt.ReplaceBookmark("Z2", "Ｖ");
                            string[] remark1_detail = arr_remark1[I].Split(';');
                            ipoRpt.ReplaceBookmark("Z2C", remark1_detail[1]);//分割副本份數
                        }
                    }
                }
            }

            //浮貼處
            ipoRpt.CopyBlock("b_foot");

            ipoRpt.CopyPageFoot("apply", false);//申請書頁尾
        }
        
        ipoRpt.Flush(docFileName);
        ipoRpt.SetPrint();
    }
</script>
