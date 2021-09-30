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
				ReportCode = "FC11",
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
        string docFileName = "[註冊前變更(一案多件)]-" + ipoRpt.Seq + ".docx";

        Dictionary<string, string> _tplFile = new Dictionary<string, string>(){
			{"apply", Server.MapPath("~/ReportTemplate/申請書/紙本/FC11_註冊前變更申請書(一案多件).docx")},
		};
        ipoRpt.CloneFromFile(_tplFile, true);

        DataTable dmt = ipoRpt.Dmt;
        if (dmt.Rows.Count > 0) {
            //標題區塊
            ipoRpt.CopyBlock("b_title");

            //金額
            if (Convert.ToInt32(dmt.Rows[0].SafeRead("fees", "")) > 0) {
                string strfees = Util.gfsTrnCurrencyNumToChineseText(dmt.Rows[0].SafeRead("fees", "0")).Replace("元整","");
                ipoRpt.ReplaceBookmark("fees", strfees);
            }
            //日期
            ipoRpt.ReplaceBookmark("tyear", (DateTime.Today.Year - 1911).ToString());
            ipoRpt.ReplaceBookmark("tyear2", (DateTime.Today.Year - 1911).ToString());
            //主案
            //商標或標章種類
            ipoRpt.ReplaceBookmark("smark1", GetSmarknm(dmt.Rows[0].SafeRead("s_mark", "")));
            //申請號數
            ipoRpt.ReplaceBookmark("apply_no1", dmt.Rows[0].SafeRead("apply_no", ""));
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
                    //申請號數
                    ipoRpt.ReplaceBookmark("apply_no" + (i + 2), dr.SafeRead("apply_no", ""));
                    //商標或標章名稱
                    ipoRpt.ReplaceBookmark("appl_name" + (i + 2), dr.SafeRead("appl_name", "").ToXmlUnicode());
                }
            }
            //變更事項
            //申請人名稱
            var mod_ap = ipoRpt.Tran.Rows[0].SafeRead("mod_ap", "").ToCharArray();
            if (mod_ap.Length >= 1 && mod_ap[0] == 'Y') {
                ipoRpt.ReplaceBookmark("mod_ap", "Ｖ");
            }
            //申請人地址
            var mod_apaddr = ipoRpt.Tran.Rows[0].SafeRead("mod_apaddr", "").ToCharArray();
            if (mod_apaddr.Length >= 1 && mod_apaddr[0] == 'Y') {
                ipoRpt.ReplaceBookmark("mod_apaddr", "Ｖ");
            }
            //申請人印鑑
            var mod_oth = ipoRpt.Tran.Rows[0].SafeRead("mod_oth", "").ToCharArray();
            if (mod_oth.Length >= 1 && mod_oth[0] == 'Y') {
                ipoRpt.ReplaceBookmark("mod_oth", "Ｖ");
            }
            //代表人
            var mod_aprep = ipoRpt.Tran.Rows[0].SafeRead("mod_aprep", "").ToCharArray();
            if (mod_aprep.Length >= 1 && mod_aprep[0] == 'Y') {
                ipoRpt.ReplaceBookmark("mod_aprep", "Ｖ");
            }
            //代表人印鑑
            var mod_oth1 = ipoRpt.Tran.Rows[0].SafeRead("mod_oth1", "").ToCharArray();
            if (mod_oth1.Length >= 1 && mod_oth1[0] == 'Y') {
                ipoRpt.ReplaceBookmark("mod_oth1", "Ｖ");
            }
            //選定代表人
            var mod_claim1 = ipoRpt.Tran.Rows[0].SafeRead("mod_claim1", "").ToCharArray();
            if (mod_claim1.Length >= 1 && mod_claim1[0] == 'Y') {
                ipoRpt.ReplaceBookmark("mod_claim1", "Ｖ");
            }
            //代理人
            var mod_agt = ipoRpt.Tran.Rows[0].SafeRead("mod_agt", "").ToCharArray();
            if (mod_agt.Length >= 1 && mod_agt[0] == 'Y') {
                ipoRpt.ReplaceBookmark("mod_agt", "Ｖ");
            }
            //代理人地址
            var mod_agtaddr = ipoRpt.Tran.Rows[0].SafeRead("mod_agtaddr", "").ToCharArray();
            if (mod_agtaddr.Length >= 1 && mod_agtaddr[0] == 'Y') {
                ipoRpt.ReplaceBookmark("mod_agtaddr", "Ｖ");
            }
            //代理人印鑑
            var mod_oth2 = ipoRpt.Tran.Rows[0].SafeRead("mod_oth2", "").ToCharArray();
            if (mod_oth2.Length >= 1 && mod_oth2[0] == 'Y') {
                ipoRpt.ReplaceBookmark("mod_oth2", "Ｖ");
            }

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
            //代理人
            ipoRpt.CopyBlock("b_agent");
            ipoRpt.CopyTable("tbl_agent");
            using (DataTable dtAgt = ipoRpt.Agent) {
                if (dtAgt.Rows.Count > 0) {
                    DataRow dragt = dtAgt.Rows[0];
                    //代理人1
                    //ID
                    ipoRpt.ReplaceBookmark("agt_id1", dragt.SafeRead("agt_id1", ""));
                    //姓名
                    ipoRpt.ReplaceBookmark("agt_name", dragt.SafeRead("agt_name1", "").Replace(",", ""));
                    //地址
                    if (dragt.SafeRead("agt_addr", "") != "") {
                        ipoRpt.ReplaceBookmark("agt_addr", dragt.SafeRead("agt_zip", "") + dragt.SafeRead("agt_addr", ""));
                    } else {
                        ipoRpt.ReplaceBookmark("agt_addr", "");
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

                    //代理人2
                    if (dragt.SafeRead("agt_id2", "") != "") {
                        ipoRpt.CopyTable("tbl_agent");
                        //ID
                        ipoRpt.ReplaceBookmark("agt_id1", dragt.SafeRead("agt_id2", ""));
                        //姓名
                        ipoRpt.ReplaceBookmark("agt_name", dragt.SafeRead("agt_name2", "").Replace(",", ""));
                        //地址
                        if (dragt.SafeRead("agt_addr", "") != "") {
                            ipoRpt.ReplaceBookmark("agt_addr", dragt.SafeRead("agt_zip", "") + dragt.SafeRead("agt_addr", ""));
                        } else {
                            ipoRpt.ReplaceBookmark("agt_addr", "");
                        }
                        //聯絡電話及分機
                        ipoRpt.ReplaceBookmark("agt_tel", strtel);
                        //傳真
                        ipoRpt.ReplaceBookmark("agt_fax", dragt.SafeRead("agt_fax", ""));
                    }
                }
            }
            //原申請人
            ipoRpt.CopyBlock("b_mod_ap");
            if (mod_ap.Length >= 1 && mod_ap[0] == 'Y') {
                using (DataTable dtModAp = ipoRpt.TranListAP) {
                    for (int i = 0; i < dtModAp.Rows.Count; i++) {
                        ipoRpt.CopyTable("tbl_mod_ap");
                        ipoRpt.ReplaceBookmark("old_no", dtModAp.Rows[i]["old_no"].ToString().ToXmlUnicode());
                        ipoRpt.ReplaceBookmark("ocname1", dtModAp.Rows[i]["Cname_string"].ToString().ToXmlUnicode());
                        ipoRpt.ReplaceBookmark("oename1", dtModAp.Rows[i]["Ename_string"].ToString().ToXmlUnicode(true), true);
                    }
                    if (dtModAp.Rows.Count > 0) {
                        ipoRpt.ReplaceBookmark("oapcust_num", dtModAp.Rows.Count.ToString());
                    }
                }
            } else {
                ipoRpt.CopyTable("tbl_mod_ap");
            }

            //具結
            ipoRpt.CopyBlock("b_sign");

            //備註
            ipoRpt.CopyBlock("b_remark");
            if (dmt.Rows[0].SafeRead("remark1", "") != "") {
                string[] arr_remark1 = dmt.Rows[0].SafeRead("remark1", "").Split('|');
                for (int I = 0; I < arr_remark1.Length; I++) {
                    if (Regex.IsMatch(arr_remark1[I], @"(Z1|Z2|Z2C|Z3|Z4|Z5|Z6|Z7|Z8|Z9)")) {
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
                    //申請號數
                    ipoRpt.ReplaceBookmark("dmt1_apply_no", dr.SafeRead("apply_no", ""));
                    //商標或標章名稱
                    ipoRpt.ReplaceBookmark("dmt1_appl_name", dr.SafeRead("appl_name", "").ToXmlUnicode());
                }

                if (dtDmt1.Rows.Count <= 4) {//子案不到5筆就顯示空白行
                    ipoRpt.CopyTable("tbl_dmt1");
                    ipoRpt.ReplaceBookmark("dmt1_appl_name", "");
                }
            }

            ipoRpt.CopyPageFoot("apply", false);//申請書頁尾
        }

        ipoRpt.Flush(docFileName);
        ipoRpt.SetPrint();
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
