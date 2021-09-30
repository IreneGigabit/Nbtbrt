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
				ReportCode = "FL5",
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
        DataTable dmt = ipoRpt.Dmt;
        if (dmt.Rows.Count > 0) {
            string docFileName = "", tplName = "";
            if (dmt.Rows[0].SafeRead("arcase", "").Left(3) == "FL5") {
                docFileName = "[授權]-" + ipoRpt.Seq + ".docx";
                tplName = Server.MapPath("~/ReportTemplate/申請書/紙本/FL5_授權登記申請書(一文多案).docx");
            } else if (dmt.Rows[0].SafeRead("arcase", "").Left(3) == "FL6") {
                docFileName = "[再授權]-" + ipoRpt.Seq + ".docx";
                tplName = Server.MapPath("~/ReportTemplate/申請書/紙本/FL6_再授權登記申請書(一文多案).docx");
            }
            Dictionary<string, string> _tplFile = new Dictionary<string, string>(){
			    {"apply", tplName},
		    };
            ipoRpt.CloneFromFile(_tplFile, true);

            //標題區塊
            ipoRpt.CopyBlock("b_title");
            //金額
            if (Convert.ToInt32(dmt.Rows[0].SafeRead("fees", "")) > 0) {
                string strfees = Util.gfsTrnCurrencyNumToChineseText(dmt.Rows[0].SafeRead("fees", "0")).Replace("元整", "");
                ipoRpt.ReplaceBookmark("fees", strfees);
            }
            //日期
            ipoRpt.ReplaceBookmark("tyear", (DateTime.Today.Year - 1911).ToString());
            ipoRpt.ReplaceBookmark("tyear2", (DateTime.Today.Year - 1911).ToString());
            //主案
            //商標或標章種類
            ipoRpt.ReplaceBookmark("smark1", GetSmarknm(dmt.Rows[0].SafeRead("s_mark", "")));
            //註冊號數
            ipoRpt.ReplaceBookmark("issue_no1", dmt.Rows[0].SafeRead("issue_no", ""));
            //商標或標章名稱
            ipoRpt.ReplaceBookmark("appl_name1", dmt.Rows[0].SafeRead("appl_name", "").ToXmlUnicode());

            //子案上半部(只顯示4筆,第1筆是主案)
            using (DataTable dtDmt1 = ipoRpt.Dmt1) {
                if (dtDmt1.Rows.Count > 4) {//超過5件
                    ipoRpt.ReplaceBookmark("over_5", "Ｖ");
                }
                for (int i = 0; i < Math.Min(dtDmt1.Rows.Count, 4); i++) {
                    DataRow dr = dtDmt1.Rows[i];
                    //商標或標章種類
                    ipoRpt.ReplaceBookmark("smark" + (i + 2), GetSmarknm(dr.SafeRead("s_mark", "")));
                    //註冊號數
                    ipoRpt.ReplaceBookmark("issue_no" + (i + 2), dr.SafeRead("issue_no", ""));
                    //商標或標章名稱
                    ipoRpt.ReplaceBookmark("appl_name" + (i + 2), dr.SafeRead("appl_name", "").ToXmlUnicode());
                }
            }
            //申請人種類
            if (dmt.Rows[0].SafeRead("mark", "") != "") {
                ipoRpt.ReplaceBookmark("mark_" + dmt.Rows[0]["mark"], "Ｖ");
            }

            if (dmt.Rows[0].SafeRead("mark", "") == "A") {//申請人商標權人
                //商標權人
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
                        ipoRpt.ReplaceBookmark("ap_cname", drdap.SafeRead("Cname_string", "").Replace(",", "").ToXmlUnicode());
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

                //商標權人之代理人
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
                        //e-mail
                        ipoRpt.ReplaceBookmark("Email1", "siiplo@mail.saint-island.com.tw");
                    }
                }

                //被授權人(關係人)
                ipoRpt.CopyBlock("b_tran_ap");
                using (DataTable dtAp = ipoRpt.TranListAP) {
                    for (int i = 0; i < dtAp.Rows.Count; i++) {
                        DataRow drdap = dtAp.Rows[i];
                        ipoRpt.CopyTable("tbl_tranap");

                        //國籍
                        if (drdap["oap_country"].ToString() != "" && drdap["oap_country"].ToString() != "T") {
                            if (drdap["oap_country"].ToString() != "CM" && drdap["oap_country"].ToString() != "HO" && drdap["oap_country"].ToString() != "MC") {
                                ipoRpt.ReplaceBookmark("ocountry_OTH", "Ｖ");
                                if (drdap["oapcountry"].ToString() != "") {
                                    ipoRpt.ReplaceBookmark("oapcountry", drdap["oapcountry"].ToString());
                                }
                            } else {
                                ipoRpt.ReplaceBookmark("ocountry_CM0", "Ｖ");
                                if (drdap["oap_country"].ToString() == "CM") {
                                    ipoRpt.ReplaceBookmark("ocountry_CM", "Ｖ");
                                } else if (drdap["oap_country"].ToString() == "HO") {
                                    ipoRpt.ReplaceBookmark("ocountry_HO", "Ｖ");
                                } else if (drdap["oap_country"].ToString() == "MC") {
                                    ipoRpt.ReplaceBookmark("ocountry_MC", "Ｖ");
                                }
                            }
                        } else {
                            ipoRpt.ReplaceBookmark("ocountry_T", "Ｖ");
                        }

                        //身分種類
                        if (drdap["oapclass_name"].ToString() == "法人公司機關學校") {
                            ipoRpt.ReplaceBookmark("oapclass_BX", "Ｖ");
                        } else if (drdap["oapclass_name"].ToString() == "商號行號工廠") {
                            ipoRpt.ReplaceBookmark("oapclass_AD", "Ｖ");
                        } else if (drdap["oapclass_name"].ToString() == "自然人") {
                            ipoRpt.ReplaceBookmark("oapclass_B", "Ｖ");
                        }

                        ipoRpt.ReplaceBookmark("old_no", drdap["o_id"].ToString());
                        ipoRpt.ReplaceBookmark("ocname1", drdap.SafeRead("Cname_string", "").Replace(",", "").ToXmlUnicode());
                        ipoRpt.ReplaceBookmark("oename1", drdap.SafeRead("ename_string", "").Replace(",", "").ToXmlUnicode());
                        ipoRpt.ReplaceBookmark("ocrep", drdap["ocrep"].ToString().ToXmlUnicode());
                        ipoRpt.ReplaceBookmark("oerep", drdap["oerep"].ToString().ToXmlUnicode());
                        ipoRpt.ReplaceBookmark("ocaddr", drdap["c_addr"].ToString().ToXmlUnicode());
                        ipoRpt.ReplaceBookmark("oeaddr", drdap["e_addr"].ToString().ToXmlUnicode());

                        //把沒填到的bookmark清空
                        string[] arrAP = { 
                            "ocountry_T", "ocountry_CM0", "ocountry_CM", "ocountry_HO", "ocountry_MC" , "ocountry_OTH" , "oapcountry"
                            ,"oapclass_B","oapclass_BX","oapclass_AD"
                        };
                        foreach (string r in arrAP) {
                            ipoRpt.ReplaceBookmark(r, "");
                        }
                    }
                }
                //被授權人之代理人(免填)
                ipoRpt.CopyBlock("b_agent2");
            } else if (dmt.Rows[0].SafeRead("mark", "") == "B") {//申請人為被授權人
                //商標權人
                using (DataTable dtAp = ipoRpt.TranListAP) {
                    for (int i = 0; i < dtAp.Rows.Count; i++) {
                        DataRow drdap = dtAp.Rows[i];
                        ipoRpt.CopyTable("tbl_apply");
                        ipoRpt.ReplaceBookmark("apply_num", (i + 1).ToString());

                        //國籍
                        if (drdap["oap_country"].ToString() != "" && drdap["oap_country"].ToString() != "T") {
                            if (drdap["oap_country"].ToString() != "CM" && drdap["oap_country"].ToString() != "HO" && drdap["oap_country"].ToString() != "MC") {
                                ipoRpt.ReplaceBookmark("country_OTH", "Ｖ");
                                if (drdap["oapcountry"].ToString() != "") {
                                    ipoRpt.ReplaceBookmark("apcountry", drdap["oapcountry"].ToString());
                                }
                            } else {
                                ipoRpt.ReplaceBookmark("country_CM0", "Ｖ");
                                if (drdap["oap_country"].ToString() == "CM") {
                                    ipoRpt.ReplaceBookmark("country_CM", "Ｖ");
                                } else if (drdap["oap_country"].ToString() == "HO") {
                                    ipoRpt.ReplaceBookmark("country_HO", "Ｖ");
                                } else if (drdap["oap_country"].ToString() == "MC") {
                                    ipoRpt.ReplaceBookmark("country_MC", "Ｖ");
                                }
                            }
                        } else {
                            ipoRpt.ReplaceBookmark("country_T", "Ｖ");
                        }

                        //身分種類
                        if (drdap["oapclass_name"].ToString() == "法人公司機關學校") {
                            ipoRpt.ReplaceBookmark("apclass_BX", "Ｖ");
                        } else if (drdap["oapclass_name"].ToString() == "商號行號工廠") {
                            ipoRpt.ReplaceBookmark("apclass_AD", "Ｖ");
                        } else if (drdap["oapclass_name"].ToString() == "自然人") {
                            ipoRpt.ReplaceBookmark("apclass_B", "Ｖ");
                        }

                        ipoRpt.ReplaceBookmark("apcust_no", drdap["o_id"].ToString());
                        ipoRpt.ReplaceBookmark("ap_cname", drdap.SafeRead("Cname_string", "").Replace(",", "").ToXmlUnicode());
                        ipoRpt.ReplaceBookmark("ap_ename", drdap.SafeRead("ename_string", "").Replace(",", "").ToXmlUnicode());
                        ipoRpt.ReplaceBookmark("ap_crep", drdap["ocrep"].ToString().ToXmlUnicode());
                        ipoRpt.ReplaceBookmark("ap_erep", drdap["oerep"].ToString().ToXmlUnicode());
                        ipoRpt.ReplaceBookmark("ap_caddr", drdap["c_addr"].ToString().ToXmlUnicode());
                        ipoRpt.ReplaceBookmark("ap_eaddr", drdap["e_addr"].ToString().ToXmlUnicode());

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

                //商標權人之代理人(免填)
                ipoRpt.CopyBlock("b_agent");

                //被授權人(關係人)
                ipoRpt.CopyBlock("b_tran_ap");
                using (DataTable dtAp = ipoRpt.Apcust) {
                    for (int i = 0; i < dtAp.Rows.Count; i++) {
                        DataRow drdap = dtAp.Rows[i];
                        ipoRpt.CopyTable("tbl_tranap");

                        //國籍
                        if (drdap["ap_country"].ToString() != "" && drdap["ap_country"].ToString() != "T") {
                            if (drdap["ap_country"].ToString() != "CM" && drdap["ap_country"].ToString() != "HO" && drdap["ap_country"].ToString() != "MC") {
                                ipoRpt.ReplaceBookmark("ocountry_OTH", "Ｖ");
                                if (drdap["apcountry"].ToString() != "") {
                                    ipoRpt.ReplaceBookmark("oapcountry", drdap["apcountry"].ToString());
                                }
                            } else {
                                ipoRpt.ReplaceBookmark("ocountry_CM0", "Ｖ");
                                if (drdap["ap_country"].ToString() == "CM") {
                                    ipoRpt.ReplaceBookmark("ocountry_CM", "Ｖ");
                                } else if (drdap["ap_country"].ToString() == "HO") {
                                    ipoRpt.ReplaceBookmark("ocountry_HO", "Ｖ");
                                } else if (drdap["ap_country"].ToString() == "MC") {
                                    ipoRpt.ReplaceBookmark("ocountry_MC", "Ｖ");
                                }
                            }
                        } else {
                            ipoRpt.ReplaceBookmark("ocountry_T", "Ｖ");
                        }

                        //身分種類
                        if (drdap["apclass_name"].ToString() == "法人公司機關學校") {
                            ipoRpt.ReplaceBookmark("oapclass_BX", "Ｖ");
                        } else if (drdap["apclass_name"].ToString() == "商號行號工廠") {
                            ipoRpt.ReplaceBookmark("oapclass_AD", "Ｖ");
                        } else if (drdap["apclass_name"].ToString() == "自然人") {
                            ipoRpt.ReplaceBookmark("oapclass_B", "Ｖ");
                        }

                        ipoRpt.ReplaceBookmark("old_no", drdap["c_id"].ToString());
                        ipoRpt.ReplaceBookmark("ocname1", drdap.SafeRead("Cname_string", "").Replace(",", "").ToXmlUnicode());
                        ipoRpt.ReplaceBookmark("oename1", drdap.SafeRead("ename_string", "").Replace(",", "").ToXmlUnicode());
                        ipoRpt.ReplaceBookmark("ocrep", drdap["ap_crep"].ToString().ToXmlUnicode());
                        ipoRpt.ReplaceBookmark("oerep", drdap["ap_erep"].ToString().ToXmlUnicode());
                        ipoRpt.ReplaceBookmark("ocaddr", drdap["c_addr"].ToString().ToXmlUnicode());
                        ipoRpt.ReplaceBookmark("oeaddr", drdap["e_addr"].ToString().ToXmlUnicode());

                        //把沒填到的bookmark清空
                        string[] arrAP = { 
                            "ocountry_T", "ocountry_CM0", "ocountry_CM", "ocountry_HO", "ocountry_MC" , "ocountry_OTH" , "oapcountry"
                            ,"oapclass_B","oapclass_BX","oapclass_AD"
                        };
                        foreach (string r in arrAP) {
                            ipoRpt.ReplaceBookmark(r, "");
                        }
                    }
                }

                //被授權人之代理人
                ipoRpt.CopyBlock("b_agent2");
                using (DataTable dtAgt = ipoRpt.Agent) {
                    if (dtAgt.Rows.Count > 0) {
                        DataRow dragt = dtAgt.Rows[0];
                        //ID
                        string agt_id1 = "";
                        if (dragt.SafeRead("agt_id1", "") != "") {
                            agt_id1 += dragt.SafeRead("agt_id1", "");
                            if (dragt.SafeRead("agt_id2", "") != "") agt_id1 += "、" + dragt.SafeRead("agt_id2", "");
                        }
                        ipoRpt.ReplaceBookmark("agt_id2", agt_id1);
                        //姓名
                        string agt_name = "";
                        agt_name = dragt.SafeRead("agt_name1", "");
                        if (dragt.SafeRead("agt_name2", "") != "") {
                            agt_name += "、" + dragt.SafeRead("agt_name2", "");
                        }
                        ipoRpt.ReplaceBookmark("agt_name2", agt_name.Replace(",", ""));
                        //地址
                        if (dragt.SafeRead("agt_addr", "") != "") {
                            ipoRpt.ReplaceBookmark("agt_addr2", dragt.SafeRead("agt_zip", "") + dragt.SafeRead("agt_addr", ""));
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
                        ipoRpt.ReplaceBookmark("agt_tel2", strtel);
                        //傳真
                        ipoRpt.ReplaceBookmark("agt_fax2", dragt.SafeRead("agt_fax", ""));
                        //e-mail
                        ipoRpt.ReplaceBookmark("Email2", "siiplo@mail.saint-island.com.tw");
                    }
                }
            }

            //授權期間
            ipoRpt.CopyBlock("b_tran");
            using (DataTable dtTran = ipoRpt.Tran) {
                if (dtTran.Rows.Count > 0) {
                    //授權期間
                    if (dtTran.Rows[0]["mod_claim1"].ToString().Trim() == "B") {//區間
                        ipoRpt.ReplaceBookmark("mod_claim1B", "Ｖ");
                        if (dtTran.Rows[0].SafeRead("term1", "") != "") {
                            DateTime term1 = Convert.ToDateTime(dtTran.Rows[0]["term1"]);
                            ipoRpt.ReplaceBookmark("term1Y", (term1.Year - 1911).ToString());
                            ipoRpt.ReplaceBookmark("term1M", (term1.Month).ToString());
                            ipoRpt.ReplaceBookmark("term1D", (term1.Day).ToString());
                        }
                        if (dtTran.Rows[0].SafeRead("term2", "") != "") {
                            DateTime term2 = Convert.ToDateTime(dtTran.Rows[0]["term2"]);
                            ipoRpt.ReplaceBookmark("term2Y", (term2.Year - 1911).ToString());
                            ipoRpt.ReplaceBookmark("term2M", (term2.Month).ToString());
                            ipoRpt.ReplaceBookmark("term2D", (term2.Day).ToString());
                        }
                    } else if (dtTran.Rows[0]["mod_claim1"].ToString().Trim() == "E") {
                        ipoRpt.ReplaceBookmark("mod_claim1E", "Ｖ");
                        if (dtTran.Rows[0].SafeRead("term1", "") != "") {
                            DateTime term1 = Convert.ToDateTime(dtTran.Rows[0]["term1"]);
                            ipoRpt.ReplaceBookmark("term1YE", (term1.Year - 1911).ToString());
                            ipoRpt.ReplaceBookmark("term1ME", (term1.Month).ToString());
                            ipoRpt.ReplaceBookmark("term1DE", (term1.Day).ToString());
                        }
                        ipoRpt.ReplaceBookmark("tran_term2", dtTran.Rows[0].SafeRead("other_item1", ""));
                    }

                    //授權性質
                    if (dtTran.Rows[0]["mod_claim2"].ToString().Trim() == "A") {
                        ipoRpt.ReplaceBookmark("mod_claim2A", "Ｖ");
                    } else if (dtTran.Rows[0]["mod_claim2"].ToString().Trim() == "B") {
                        ipoRpt.ReplaceBookmark("mod_claim2B", "Ｖ");
                    }
                    //授權區域
                    var mod_oitem2 = ipoRpt.Tran.Rows[0].SafeRead("other_item2", "").Split(',');
                    if (mod_oitem2[0] == "T") {
                        ipoRpt.ReplaceBookmark("other_item2T", "Ｖ");
                    } else if (mod_oitem2[0] == "O") {
                        ipoRpt.ReplaceBookmark("other_item2O", "Ｖ");
                        ipoRpt.ReplaceBookmark("other_item2Ot", (mod_oitem2.Length > 1 ? mod_oitem2[1] : ""));
                    }
                }
            }

            //授權商品或服務
            ipoRpt.CopyBlock("b_class1");
            using (DataTable dtClass = ipoRpt.TranListClass) {
                if (dtClass.Rows.Count > 0) {
                    if (dtClass.Rows[0]["mod_type"].ToString() == "All") {
                        ipoRpt.ReplaceBookmark("All", "Ｖ");
                        ipoRpt.CopyTable("tbl_trangood");
                    } else if (dtClass.Rows[0]["mod_type"].ToString() == "Part") {
                        ipoRpt.ReplaceBookmark("Part", "Ｖ");
                        for (int i = 0; i < dtClass.Rows.Count; i++) {
                            ipoRpt.CopyTable("tbl_trangood");
                            ipoRpt.ReplaceBookmark("new_no1", dtClass.Rows[i]["new_no"].ToString());
                            ipoRpt.ReplaceBookmark("list_remark", dtClass.Rows[i]["list_remark"].ToString().Trim(), true);
                        }
                    }
                }
            }

            //具結
            ipoRpt.CopyBlock("b_sign");
            //附件
            ipoRpt.CopyBlock("b_remark");
            if (dmt.Rows[0].SafeRead("remark1", "") != "") {
                string[] arr_remark1 = dmt.Rows[0].SafeRead("remark1", "").Split('|');
                for (int I = 0; I < arr_remark1.Length; I++) {
                    if (Regex.IsMatch(arr_remark1[I], @"(Z1|Z1C|Z4|Z4C|Z5|Z5C|Z9)")) {
                        ipoRpt.ReplaceBookmark(arr_remark1[I], "Ｖ");
                        if (arr_remark1[I].IndexOf("Z9-") > -1) {
                            MatchCollection Matches = Regex.Matches(dmt.Rows[0]["remark1"].ToString().Trim(), @"\|Z9-(?<reason>.*)-Z9\|", RegexOptions.IgnoreCase);
                            string reason = "";
                            foreach (Match match in Matches) {
                                reason += (Matches.Count > 1 ? "\n" : "") + match.Groups["reason"].Value;
                            }
                            ipoRpt.ReplaceBookmark("Z9t", reason);
                        }
                    }
                }
            }

            //子案下半部(從第5筆開始)
            using (DataTable dtDmt1 = ipoRpt.Dmt1) {
                for (int i = 4; i < dtDmt1.Rows.Count; i++) {
                    ipoRpt.CopyTable("tbl_dmt1");
                    DataRow dr = dtDmt1.Rows[i];
                    //序號
                    ipoRpt.ReplaceBookmark("dmt1_seq", (i + 2).ToString());
                    //商標或標章種類
                    ipoRpt.ReplaceBookmark("dmt1_smark", GetSmarknm(dr.SafeRead("s_mark", "")));
                    //註冊號數
                    ipoRpt.ReplaceBookmark("dmt1_issue_no", dr.SafeRead("issue_no", ""));
                    //商標或標章名稱
                    ipoRpt.ReplaceBookmark("dmt1_appl_name", dr.SafeRead("appl_name", "").ToXmlUnicode());
                }

                if (dtDmt1.Rows.Count <= 4) {//子案不到5筆就顯示空白行
                    ipoRpt.CopyTable("tbl_dmt1");
                    ipoRpt.ReplaceBookmark("dmt1_appl_name", "");
                }
            }

            ipoRpt.CopyPageFoot("apply", false);//申請書頁尾

            ipoRpt.Flush(docFileName);
            ipoRpt.SetPrint();
        }
    }

    protected string GetSmarknm(string s_mark) {
        switch (s_mark.ToUpper()) {
            case "S": return "Ｓ";
            case "L": return "７";
            case "M": return "８";
            case "N": return "Ｇ";
            default: return "Ｔ";
        }
    }
</script>
