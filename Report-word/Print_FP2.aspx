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
				ReportCode = "FP2",
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
        string docFileName = "[質權消滅]-" + ipoRpt.Seq + ".docx";

        Dictionary<string, string> _tplFile = new Dictionary<string, string>(){
			{"apply", Server.MapPath("~/ReportTemplate/申請書/紙本/FP2_質權消滅登記申請書.docx")},
		};
        ipoRpt.CloneFromFile(_tplFile, true);

        DataTable dmt = ipoRpt.Dmt;
        if (dmt.Rows.Count > 0) {
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
            //註冊號數
            ipoRpt.ReplaceBookmark("issue_no", dmt.Rows[0].SafeRead("issue_no", ""));
            //商標或標章名稱
            ipoRpt.ReplaceBookmark("appl_name", dmt.Rows[0]["appl_name"].ToString().ToXmlUnicode());
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

                //質權人(關係人)
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
                //質權人之代理人(免填)
                ipoRpt.CopyBlock("b_agent2");
            } else if (dmt.Rows[0].SafeRead("mark", "") == "B") {//申請人為質權人
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

                //質權人(關係人)
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

                //質權人之代理人
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

            //質權消滅日期
            ipoRpt.CopyBlock("b_tran");
            using (DataTable dtTran = ipoRpt.Tran) {
                if (dtTran.Rows.Count > 0) {
                    if (dtTran.Rows[0].SafeRead("term1", "") != "") {
                        DateTime term1 = Convert.ToDateTime(dtTran.Rows[0]["term1"]);
                        ipoRpt.ReplaceBookmark("YY", (term1.Year - 1911).ToString());
                        ipoRpt.ReplaceBookmark("MM", (term1.Month).ToString());
                        ipoRpt.ReplaceBookmark("DD", (term1.Day).ToString());
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
                    if (Regex.IsMatch(arr_remark1[I], @"(Z1|Z1C|Z2|Z2C|Z9)")) {
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

            ipoRpt.CopyPageFoot("apply", false);//申請書頁尾
        }

        ipoRpt.Flush(docFileName);
        ipoRpt.SetPrint();
    }
</script>
