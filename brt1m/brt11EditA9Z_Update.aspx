<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Collections.Generic"%>

<script runat="server">
    protected string HTProgCap = HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "brt11";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";
    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";
    protected string formFunction = "";
    protected string drawFilename = "";

    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected Dictionary<string, string> ColMap = new Dictionary<string, string>();
    protected string SQL = "";
    Sys sfile = new Sys();

    protected StringBuilder strOut = new StringBuilder();

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");

        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        HTProgCap = myToken.Title;
        DebugStr = myToken.DebugStr;
        if (HTProgRight >= 0) {
            doUpdateDB();
            this.DataBind();
        }
    }

    private void doUpdateDB() {
        sfile.getFileServer(Sys.GetSession("SeBranch"), prgid);//檔案上傳相關設定

        using (DBHelper conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST")) {
            string in_no = (Request["in_no"]??"");
            //交辦內容欄位畫面
            if (Request["ar_form"] == "A3") {
                editA3(conn, in_no);
            } else if (Request["ar_form"] == "A4") {
                editA4(conn, in_no);
            } else if (Request["ar_form"] == "A5") {
                editA5(conn, in_no);
            } else if (Request["ar_form"] == "A6") {
                editA6(conn, in_no);
            } else if (Request["ar_form"] == "A7") {
                editA7(conn, in_no);
            } else if (Request["ar_form"] == "A8") {
                editA8(conn, in_no);
            } else if (Request["ar_form"] == "A9") {
                editA9(conn, in_no);
            } else if (Request["ar_form"] == "AA") {
                editAA(conn, in_no);
            } else if (Request["ar_form"] == "AB") {
                editAB(conn, in_no);
            } else if (Request["ar_form"] == "AC") {
                editAC(conn, in_no);
            } else if (Request["ar_form"] == "B") {
                editB(conn, in_no);
            } else {
                editZZ(conn, in_no);
            }

            conn.Commit();
            //conn.RollBack();

            strOut.AppendLine("<div align='center'><h1>資料更新成功</h1></div>");
        }
    }
    
    /// <summary>
    /// 寫入Log檔
    /// </summary>
    private void log_table(DBHelper conn) {
        //入case_dmt_log
        Sys.insert_log_table(conn, "U", prgid, "case_dmt", "in_scode;in_no", Request["in_scode"] + ";" + Request["in_no"], "brt12國內案編修暨交辦作業");

        //入caseitem_dmt_log
        Sys.insert_log_table(conn, "U", prgid, "caseitem_dmt", "in_scode;in_no", Request["in_scode"] + ";" + Request["in_no"], "");

        //商品入log_table
        Sys.insert_log_table(conn, "U", prgid, "casedmt_good", "in_no;in_scode", Request["in_no"] + ";" + Request["in_scode"], "");

        //展覽優先權入log_table
        Sys.insert_log_table(conn, "U", prgid, "casedmt_show", "in_no", Request["in_no"], "");

        //入dmt_temp_log
        Sys.insert_log_table(conn, "U", prgid, "dmt_temp", "in_no;in_scode", Request["in_no"] + ";" + Request["in_scode"], "");
        
        //申請人入dmt_temp_ap_log**********
        Sys.insert_log_table(conn, "U", prgid, "dmt_temp_ap", "in_no;case_sqlno", Request["in_no"] + ";0", "");

        //異動檔入dmt_tranlist_log
        Sys.insert_log_table(conn, "U", prgid, "dmt_tran", "in_no;in_scode", Request["in_no"] + ";" + Request["in_scode"], "");
        
        //異動明細檔入dmt_tranlist_log
        Sys.insert_log_table(conn, "U", prgid, "dmt_tranlist", "in_no;in_scode", Request["in_no"] + ";" + Request["in_scode"], "");
    }

    /// <summary>
    /// 寫入接洽記錄檔(case_dmt)
    /// </summary>
    private void update_case_dmt(DBHelper conn) {
        ColMap.Clear();
        foreach (var key in Request.Form.Keys) {
            string colkey = key.ToString().ToLower();
            string colValue = Request[colkey];

            //取2~4碼(直接用substr若欄位名稱太短會壞掉)
            if (colkey.Left(4).Substring(1) == "fy_") {
                if (colkey.Left(1) == "p") {
                    ColMap[colkey.Substring(4)] = Util.dbnull(colValue);
                } else if (colkey.Left(1) == "d") {
                    ColMap[colkey.Substring(4)] = Util.dbnull(colValue);
                } else if (colkey.Left(1) == "n") {
                    ColMap[colkey.Substring(4)] = Util.dbzero(colValue);
                } else {
                    ColMap[colkey.Substring(4)] = Util.dbnull(colValue);
                }
            }
        }

        //******折扣請核單
        if (Request["tfy_discount_chk"] == null) {
            ColMap["discount_chk"] = "'N'";
        }
        //******請款單 
        if (Request["tfy_ar_chk"] == null) {
            ColMap["ar_chk"] = "'N'";
        }
        if (Request["tfy_ar_chk1"] == null) {
            ColMap["ar_chk1"] = "'N'";
        }
        //****結案註記
        if (Request["tfy_end_flag"] == null) {
            ColMap["end_flag"] = "'N'";
        }
        //****復案註記
        if (Request["tfy_back_flag"] == null) {
            ColMap["back_flag"] = "'N'";
        }
        //****後續交辦作業序號
        ColMap["grconf_sqlno"] = Util.dbnull(Request["grconf_sqlno"]);
        
        //****會計檢核2013/9/16增加，不需請款或大陸進口案不在線上請款，不需會計檢核
        if (Request["tfy_ar_code"] == "X" || Request["tfy_ar_code"] == "M") {
            ColMap["acc_chk"] = "'X'";
        } else {
            ColMap["acc_chk"] = "'N'";
        }
        //****契約書後補註記
        if (Request["tfy_contract_flag"] == null) {
            ColMap["contract_flag"] = "'N'";
        }

        ColMap["seq"] = Util.dbnull(Request["tfzb_seq"]);
        ColMap["seq1"] = Util.dbchar(Request["tfzb_seq1"]);
        ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);

        SQL = "UPDATE case_dmt set " + ColMap.GetUpdateSQL();
        SQL += " where in_scode = '" + Request["in_scode"] + "' and in_no = '" + Request["In_no"] + "'";
        //Response.Write(SQL + "<HR>");
        conn.ExecuteNonQuery(SQL);
    }

    /// <summary>
    /// 將檔案更改檔名
    /// </summary>
    private string move_file(string in_no, string drawValue, string suffix) {
        if (drawValue.Trim() == "" || drawValue == null)
            return "";

        string aa = drawValue.ToLower();
        string newfilename = "";
        //20201127因舊案/母案複製常會檔名錯亂.檔名一律改為接洽序號
        //if ((Request["tfy_case_stat"] ?? "") != "OO") {
            if (aa != "") {
                //2013/11/26修改可以中文檔名上傳及虛擬路徑
                //string strpath = "/btbrt/" + Session["seBranch"] + "T/temp";
                string strpath = sfile.gbrWebDir + "/temp";
                //string attach_name = in_no + System.IO.Path.GetExtension(aa);//重新命名檔名
                //string attach_name = filename + System.IO.Path.GetExtension(aa);//重新命名檔名
                string attach_name = in_no + suffix + System.IO.Path.GetExtension(aa);//重新命名檔名
                newfilename = strpath + "/" + attach_name;//存在資料庫路徑
                if (aa.IndexOf("/") > -1 || aa.IndexOf("\\") > -1)
                    Sys.RenameFile(Sys.Path2Nbtbrt(aa), strpath + "/" + attach_name, true);
                else
                    Sys.RenameFile(strpath + "/" + aa, strpath + "/" + attach_name, true);
            }
        //} else {
        //    newfilename = Sys.Path2Nbtbrt(Request["draw_file"] ?? "");
        //}
        return newfilename;
    }

    /// <summary>
    /// 寫入接洽記錄主檔(dmt_temp)
    /// </summary>
    private void update_dmt_temp(DBHelper conn) {
        //將檔案更改檔名
        drawFilename = move_file((Request["in_no"] ?? ""), Request["draw_file"], "");

        //*****若為新案則新增至案件檔,舊案則不用
        ColMap.Clear();
        foreach (var key in Request.Form.Keys) {
            string colkey = key.ToString().ToLower();
            string colValue = Request[colkey];

            //取2~5碼(直接用substr若欄位名稱太短會壞掉)
            if (colkey.Left(4).Substring(1) == "fzd"
                || colkey.Left(4).Substring(1) == "fzp"
                ) {
                if (colkey.Left(1) == "d") {
                    ColMap[colkey.Substring(5)] = Util.dbnull(colValue);
                } else if (colkey.Left(1) == "n") {
                    ColMap[colkey.Substring(5)] = Util.dbzero(colValue);
                } else {
                    ColMap[colkey.Substring(5)] = Util.dbnull(colValue);
                }
            }
        }
        ColMap["draw_file"] = Util.dbchar(Sys.Path2Btbrt(drawFilename));
        ColMap["tr_date"] = "'" + DateTime.Today.ToShortDateString() + "'";
        ColMap["tr_scode"] = "'" + Session["scode"] + "'";
        if ((Request["ar_form"] ?? "") == "A4" || (Request["tfy_arcase"] ?? "") == "FC3") {
            ColMap["class"] = Util.dbchar(Request["tft3_class2"]);
            ColMap["class_count"] = Util.dbchar(Request["tft3_class_count2"]);
            ColMap["class_type"] = Util.dbchar(Request["tft3_class_type2"]);
        } else {
            ColMap["class"] = Util.dbchar(Request["tfzr_class"]);
            ColMap["class_count"] = Util.dbchar(Request["tfzr_class_count"]);
            ColMap["class_type"] = Util.dbchar(Request["tfzr_class_type"]);
        }
        ColMap["seq"] = Util.dbnull(Request["tfzb_seq"]);
        ColMap["seq1"] = Util.dbchar(Request["tfzb_seq1"]);
        ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
        ColMap["case_sqlno"] = "0";
        if ((Request["tfy_arcase"] ?? "").Left(3).IN("FD1,FD2,FD3")) {//分割案才寫入母案編號
            ColMap["Mseq"] = Util.dbnull(Request["tfzb_seq"]);
            ColMap["Mseq1"] = Util.dbnull(Request["tfzb_seq1"]);
        }
        SQL = "UPDATE dmt_temp set " + ColMap.GetUpdateSQL();
        SQL += " where in_scode = '" + Request["in_scode"] + "' and in_no = '" + Request["In_no"] + "'";
        conn.ExecuteNonQuery(SQL);
    }

    /// <summary>
    /// 寫入交辦申請人檔(dmt_temp_ap)
    /// </summary>
    private void insert_dmt_temp_ap(DBHelper conn,string case_sqlno) {
        SQL = "Delete dmt_temp_ap";
        SQL += " where in_no = '" + Request["In_no"] + "' and case_sqlno=" + case_sqlno + " ";
        conn.ExecuteNonQuery(SQL);
        
        //交辦申請人
        for (int i = 1; i <= Convert.ToInt32("0" + Request["apnum"]); i++) {
            ColMap.Clear();
            ColMap["in_no"] = Util.dbchar(Request["in_no"]);
            ColMap["case_sqlno"] = case_sqlno;
            ColMap["apsqlno"] = Util.dbchar(Request["apsqlno_" + i]);
            ColMap["Server_flag"] = Util.dbchar(Request["ap_server_flag_" + i]);
            ColMap["apcust_no"] = Util.dbchar(Request["apcust_no_" + i]);
            ColMap["ap_cname"] = Util.dbchar(Request["ap_cname_" + i]);
            ColMap["ap_cname1"] = Util.dbchar(Request["ap_cname1_" + i]);
            ColMap["ap_cname2"] = Util.dbchar(Request["ap_cname2_" + i]);
            ColMap["ap_ename"] = Util.dbchar(Request["ap_ename_" + i]);
            ColMap["ap_ename1"] = Util.dbchar(Request["ap_ename1_" + i]);
            ColMap["ap_ename2"] = Util.dbchar(Request["ap_ename2_" + i]);
            ColMap["tran_date"] = "getdate()";
            ColMap["tran_scode"] = "'" + Session["scode"] + "'";
            ColMap["ap_fcname"] = Util.dbchar(Request["ap_fcname_" + i]);
            ColMap["ap_lcname"] = Util.dbchar(Request["ap_lcname_" + i]);
            ColMap["ap_fename"] = Util.dbchar(Request["ap_fename_" + i]);
            ColMap["ap_lename"] = Util.dbchar(Request["ap_lename_" + i]);
            ColMap["ap_sql"] = Util.dbzero(Request["ap_sql_" + i]);
            ColMap["ap_zip"] = Util.dbchar(Request["ap_zip_" + i]);
            ColMap["ap_addr1"] = Util.dbchar(Request["ap_addr1_" + i]);
            ColMap["ap_addr2"] = Util.dbchar(Request["ap_addr2_" + i]);
            ColMap["ap_eaddr1"] = Util.dbchar(Request["ap_eaddr1_" + i]);
            ColMap["ap_eaddr2"] = Util.dbchar(Request["ap_eaddr2_" + i]);
            ColMap["ap_eaddr3"] = Util.dbchar(Request["ap_eaddr3_" + i]);
            ColMap["ap_eaddr4"] = Util.dbchar(Request["ap_eaddr4_" + i]);

            SQL = "insert into dmt_temp_ap " + ColMap.GetInsertSQL();
            conn.ExecuteNonQuery(SQL);
        }
    }

    /// <summary>
    /// 寫入交辦申請人檔(dmt_temp_ap)(Apcust_FC_RE_form)
    /// </summary>
    private void insert_dmt_temp_ap_FC0(DBHelper conn, string case_sqlno) {
        SQL = "Delete dmt_temp_ap";
        SQL += " where in_no = '" + Request["In_no"] + "' and case_sqlno=" + case_sqlno + " ";
        conn.ExecuteNonQuery(SQL);
        
        //交辦申請人
        for (int i = 1; i <= Convert.ToInt32("0" + Request["FC0_apnum"]); i++) {
            ColMap.Clear();
            ColMap["in_no"] = Util.dbchar(Request["in_no"]);
            ColMap["case_sqlno"] = case_sqlno;
            ColMap["apsqlno"] = Util.dbchar(Request["dbmn_apsqlno_" + i]);
            ColMap["Server_flag"] = Util.dbchar(Request["fc0_ap_server_flag_" + i]);
            ColMap["apcust_no"] = Util.dbchar(Request["dbmn_new_no_" + i]);
            ColMap["ap_cname"] = Util.dbchar(Request["dbmn_ap_cname_" + i]);
            ColMap["ap_cname1"] = Util.dbchar(Request["dbmn_ncname1_" + i]);
            ColMap["ap_cname2"] = Util.dbchar(Request["dbmn_ncname2_" + i]);
            ColMap["ap_ename"] = Util.dbchar(Request["dbmn_ap_ename_" + i]);
            ColMap["ap_ename1"] = Util.dbchar(Request["dbmn_nename1_" + i]);
            ColMap["ap_ename2"] = Util.dbchar(Request["dbmn_nename2_" + i]);
            ColMap["tran_date"] = "getdate()";
            ColMap["tran_scode"] = "'" + Session["scode"] + "'";
            ColMap["ap_fcname"] = Util.dbchar(Request["dbmn_fcname_" + i]);
            ColMap["ap_lcname"] = Util.dbchar(Request["dbmn_lcname_" + i]);
            ColMap["ap_fename"] = Util.dbchar(Request["dbmn_fename_" + i]);
            ColMap["ap_lename"] = Util.dbchar(Request["dbmn_lename_" + i]);
            ColMap["ap_sql"] = Util.dbzero(Request["dbmn_ap_sql_" + i]);
            ColMap["ap_zip"] = Util.dbchar(Request["dbmn_nzip_" + i]);
            ColMap["ap_addr1"] = Util.dbchar(Request["dbmn_naddr1_" + i]);
            ColMap["ap_addr2"] = Util.dbchar(Request["dbmn_naddr2_" + i]);
            ColMap["ap_eaddr1"] = Util.dbchar(Request["dbmn_neaddr1_" + i]);
            ColMap["ap_eaddr2"] = Util.dbchar(Request["dbmn_neaddr2_" + i]);
            ColMap["ap_eaddr3"] = Util.dbchar(Request["dbmn_neaddr3_" + i]);
            ColMap["ap_eaddr4"] = Util.dbchar(Request["dbmn_neaddr4_" + i]);

            SQL = "insert into dmt_temp_ap " + ColMap.GetInsertSQL();
            conn.ExecuteNonQuery(SQL);
        }
    }

    /// <summary>
    /// 寫入交辦申請人檔(dmt_temp_ap)(Apcust_FC_RE1_form)
    /// </summary>
    private void insert_dmt_temp_ap_FC2(DBHelper conn, string case_sqlno) {
        SQL = "Delete dmt_temp_ap";
        SQL += " where in_no = '" + Request["In_no"] + "' and case_sqlno=" + case_sqlno + " ";
        conn.ExecuteNonQuery(SQL);

        //交辦申請人
        for (int i = 1; i <= Convert.ToInt32("0" + Request["FC2_apnum"]); i++) {
            ColMap.Clear();
            ColMap["in_no"] = Util.dbchar(Request["in_no"]);
            ColMap["case_sqlno"] = case_sqlno;
            ColMap["apsqlno"] = Util.dbchar(Request["dbmn1_apsqlno_" + i]);
            ColMap["Server_flag"] = Util.dbchar(Request["fc2_ap_server_flag_" + i]);
            ColMap["apcust_no"] = Util.dbchar(Request["dbmn1_new_no_" + i]);
            ColMap["ap_cname"] = Util.dbchar(Request["dbmn1_ap_cname_" + i]);
            ColMap["ap_cname1"] = Util.dbchar(Request["dbmn1_ncname1_" + i]);
            ColMap["ap_cname2"] = Util.dbchar(Request["dbmn1_ncname2_" + i]);
            ColMap["ap_ename"] = Util.dbchar(Request["dbmn1_ap_ename_" + i]);
            ColMap["ap_ename1"] = Util.dbchar(Request["dbmn1_nename1_" + i]);
            ColMap["ap_ename2"] = Util.dbchar(Request["dbmn1_nename2_" + i]);
            ColMap["tran_date"] = "getdate()";
            ColMap["tran_scode"] = "'" + Session["scode"] + "'";
            ColMap["ap_fcname"] = Util.dbchar(Request["dbmn1_fcname_" + i]);
            ColMap["ap_lcname"] = Util.dbchar(Request["dbmn1_lcname_" + i]);
            ColMap["ap_fename"] = Util.dbchar(Request["dbmn1_fename_" + i]);
            ColMap["ap_lename"] = Util.dbchar(Request["dbmn1_lename_" + i]);
            ColMap["ap_sql"] = Util.dbzero(Request["dbmn1_ap_sql_" + i]);
            ColMap["ap_zip"] = Util.dbchar(Request["dbmn1_nzip_" + i]);
            ColMap["ap_addr1"] = Util.dbchar(Request["dbmn1_naddr1_" + i]);
            ColMap["ap_addr2"] = Util.dbchar(Request["dbmn1_naddr2_" + i]);
            ColMap["ap_eaddr1"] = Util.dbchar(Request["dbmn1_neaddr1_" + i]);
            ColMap["ap_eaddr2"] = Util.dbchar(Request["dbmn1_neaddr2_" + i]);
            ColMap["ap_eaddr3"] = Util.dbchar(Request["dbmn1_neaddr3_" + i]);
            ColMap["ap_eaddr4"] = Util.dbchar(Request["dbmn1_neaddr4_" + i]);

            SQL = "insert into dmt_temp_ap " + ColMap.GetInsertSQL();
            conn.ExecuteNonQuery(SQL);
        }
    }
    
    /// <summary>
    /// 寫入接洽費用檔(caseitem_dmt)
    /// </summary>
    private void insert_caseitem_dmt(DBHelper conn) {
        //****主委辦案性	
        ColMap.Clear();
        ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
        ColMap["in_no"] = Util.dbchar(Request["in_no"]);
        ColMap["item_sql"] = "'0'";
        ColMap["seq"] = Util.dbnull(Request["tfzb_seq"]);
        ColMap["seq1"] = Util.dbchar(Request["tfzb_seq1"]);
        ColMap["item_arcase"] = Util.dbchar(Request["tfy_arcase"]);
        ColMap["item_service"] = Util.dbchar(Request["nfyi_service"]);
        ColMap["item_fees"] = Util.dbchar(Request["nfyi_fees"]);
        ColMap["item_count"] = "'1'";
        SQL = "insert into caseitem_dmt " + ColMap.GetInsertSQL();
        //Response.Write(SQL + "<HR>");
        conn.ExecuteNonQuery(SQL);

        //****次委辦案性
        for (int i = 1; i <= Convert.ToInt32("0" + Request["TaCount"]); i++) {
            if ((Request["nfyi_item_Arcase_" + i] ?? "") != "") {
                ColMap.Clear();
                ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
                ColMap["in_no"] = Util.dbchar(Request["in_no"]);
                ColMap["item_sql"] = "'" + i + "'";
                ColMap["seq"] = Util.dbnull(Request["tfzb_seq"]);
                ColMap["seq1"] = Util.dbchar(Request["tfzb_seq1"]);
                ColMap["item_arcase"] = Util.dbchar(Request["nfyi_item_Arcase_" + i]);
                ColMap["item_service"] = Util.dbchar(Request["nfyi_Service_" + i]);
                ColMap["item_fees"] = Util.dbchar(Request["nfyi_fees_" + i]);
                ColMap["item_count"] = Util.dbchar(Request["nfyi_item_count_" + i]);

                SQL = "insert into caseitem_dmt " + ColMap.GetInsertSQL();
                //Response.Write(SQL + "<HR>");
                conn.ExecuteNonQuery(SQL);
            }
        }
    }
    
    /// <summary>
    /// 寫入商品類別檔(casedmt_good)
    /// </summary>
    private void insert_casedmt_good(DBHelper conn) {
        //****商品類別
        if ((Request["ar_form"] ?? "") == "A4") {
            //延展以交辦內容為準
            for (int i = 1; i <= Convert.ToInt32("0" + Request["tfzd_class_count"]); i++) {
                //2015/10/21增加判斷若有商品也入，因證明標章及團體標章無類別但會有證明內容
                if ((Request["class2_" + i] ?? "") != "" || (Request["good_name2_" + i] ?? "") != "") {
                    ColMap.Clear();
                    ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
                    ColMap["in_no"] = Util.dbchar(Request["in_no"]);
                    ColMap["class"] = Util.dbchar(Request["class2_" + i]);
                    ColMap["dmt_grp_code"] = Util.dbchar(Request["grp_code2_" + i]);
                    ColMap["dmt_goodname"] = Util.dbchar(Request["good_name2_" + i]);
                    ColMap["dmt_goodcount"] = Util.dbchar(Request["good_count2_" + i]);
                    ColMap["tr_date"] = "'" + DateTime.Today.ToShortDateString() + "'";
                    ColMap["tr_scode"] = "'" + Session["scode"] + "'";

                    SQL = "insert into casedmt_good " + ColMap.GetInsertSQL();
                    //Response.Write(SQL + "<HR>");
                    conn.ExecuteNonQuery(SQL);
                }
            }
        } else if ((Request["tfy_arcase"] ?? "") == "FC3") {
            for (int i = 1; i <= Convert.ToInt32("0" + Request["tft3_class_count2"]); i++) {
                //2015/10/21增加判斷若有商品也入，因證明標章及團體標章無類別但會有證明內容
                if ((Request["class32_" + i] ?? "") != "" || (Request["good_name32_" + i] ?? "") != "") {
                    ColMap.Clear();
                    ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
                    ColMap["in_no"] = Util.dbchar(Request["in_no"]);
                    ColMap["class"] = Util.dbchar(Request["class32_" + i]);
                    ColMap["dmt_goodname"] = Util.dbchar(Request["good_name32_" + i]);
                    ColMap["dmt_goodcount"] = Util.dbchar(Request["good_count32_" + i]);
                    ColMap["tr_date"] = "'" + DateTime.Today.ToShortDateString() + "'";
                    ColMap["tr_scode"] = "'" + Session["scode"] + "'";

                    SQL = "insert into casedmt_good " + ColMap.GetInsertSQL();
                    //Response.Write(SQL + "<HR>");
                    conn.ExecuteNonQuery(SQL);
                }
            }
        } else {
            for (int i = 1; i <= Convert.ToInt32("0" + Request["tfzr_class_count"]); i++) {
                //2015/10/21增加判斷若有商品也入，因證明標章及團體標章無類別但會有證明內容
                if ((Request["class1_" + i] ?? "") != "" || (Request["good_name1_" + i] ?? "") != "") {
                    ColMap.Clear();
                    ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
                    ColMap["in_no"] = Util.dbchar(Request["in_no"]);
                    ColMap["class"] = Util.dbchar(Request["class1_" + i]);
                    ColMap["dmt_grp_code"] = Util.dbchar(Request["grp_code1_" + i]);
                    ColMap["dmt_goodname"] = Util.dbchar(Request["good_name1_" + i]);
                    ColMap["dmt_goodcount"] = Util.dbchar(Request["good_count1_" + i]);
                    ColMap["tr_date"] = "'" + DateTime.Today.ToShortDateString() + "'";
                    ColMap["tr_scode"] = "'" + Session["scode"] + "'";

                    SQL = "insert into casedmt_good " + ColMap.GetInsertSQL();
                    //Response.Write(SQL + "<HR>");
                    conn.ExecuteNonQuery(SQL);
                }
            }
        }
    }

    /// <summary>
    /// 寫入展覽會優先權檔(casedmt_show)
    /// </summary>
    private void insert_casedmt_show(DBHelper conn, string case_sqlno) {
        for (int i = 1; i <= Convert.ToInt32("0" + Request["shownum_dmt"]); i++) {
            if ((Request["show_date_dmt_" + i] ?? "") != "" || (Request["show_name_dmt_" + i] ?? "") != "") {
                ColMap.Clear();
                ColMap["in_no"] = Util.dbchar(Request["in_no"]);
                ColMap["case_sqlno"] = case_sqlno;
                ColMap["show_date"] = Util.dbnull(Request["show_date_dmt_" + i]);
                ColMap["show_name"] = Util.dbnull(Request["show_name_dmt_" + i]);
                ColMap["tr_date"] = "getdate()";
                ColMap["tr_scode"] = "'" + Session["scode"] + "'";

                SQL = "insert into casedmt_show " + ColMap.GetInsertSQL();
                //Response.Write(SQL + "<HR>");
                conn.ExecuteNonQuery(SQL);
            }
        }
    }

    /// <summary>
    /// 更新營洽官收確認紀錄檔(grconf_dmt.job_no)
    /// </summary>
    private void upd_grconf_job_no(DBHelper conn) {
        //後續交辦作業，更新營洽官收確認紀錄檔grconf_dmt.job_no
        if ((Request["grconf_sqlno"] ?? "") != "") {
            SQL = "update grconf_dmt set job_no = '" + Request["in_no"] + "' ";
            SQL += "finish_date = getdate() ";
            SQL += "where grconf_sqlno = '" + Request["grconf_sqlno"] + "' ";
            //Response.Write(SQL + "<HR>");
            conn.ExecuteNonQuery(SQL);
        }
    }
    
    /// <summary>
    /// 註冊費
    /// </summary>
    private void editA3(DBHelper conn, string RSno) {
    }
    
    /// <summary>
    /// 延展
    /// </summary>
    private void editA4(DBHelper conn, string RSno) {
    }
    
    /// <summary>
    /// 分割
    /// </summary>
    private void editA5(DBHelper conn, string RSno) {
    }
    
    /// <summary>
    /// 變更
    /// </summary>
    private void editA6(DBHelper conn, string RSno) {
    }
    
    /// <summary>
    /// 授權
    /// </summary>
    private void editA7(DBHelper conn, string RSno) {
    }
    
    /// <summary>
    /// 移轉
    /// </summary>
    private void editA8(DBHelper conn, string RSno) {
    }
    
    /// <summary>
    /// 質權
    /// </summary>
    private void editA9(DBHelper conn, string RSno) {
    }
    
    /// <summary>
    /// 質權
    /// </summary>
    private void editAA(DBHelper conn, string RSno) {

    }
    
    /// <summary>
    /// 補(換)發證
    /// </summary>
    private void editAB(DBHelper conn, string RSno) {
    }
    
    /// <summary>
    /// 閱案
    /// </summary>
    private void editAC(DBHelper conn, string RSno) {
    }
    
    /// <summary>
    /// 爭議案
    /// </summary>
    private void editB(DBHelper conn, string RSno) {
    }
    
    /// <summary>
    /// 其他
    /// </summary>
    private void editZZ(DBHelper conn, string RSno) {
    }
</script>

<%Response.Write(strOut.ToString());%>
