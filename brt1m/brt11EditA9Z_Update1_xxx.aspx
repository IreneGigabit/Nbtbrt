<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data" %>
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

    protected string logReason = "brt52國內案交辦資料維護作業";//(未客收確認)

    DBHelper conn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    private void Page_Unload(System.Object sender, System.EventArgs e) {
        if (conn != null) conn.Dispose();
    }

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");

        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");

        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        HTProgCap = myToken.Title;
        DebugStr = myToken.DebugStr;
        if (HTProgRight >= 0) {
            try {
                doUpdateDB();
                conn.Commit();
                //conn.RollBack();
                strOut.AppendLine("<div align='center'><h1>資料更新成功</h1></div>");
            }
            catch (Exception ex) {
                conn.RollBack();
                Sys.errorLog(ex, conn.exeSQL, prgid);
                //strOut.AppendLine("<div align='center'><h1>資料更新失敗("+ex.Message+")</h1></div>");
                throw;
            }
            this.DataBind();
        }
    }

    private void doUpdateDB() {
        sfile.getFileServer(Sys.GetSession("SeBranch"), prgid);//檔案上傳相關設定

        string in_no = (Request["in_no"] ?? "");
        //交辦內容欄位畫面
        if (Request["ar_form"] == "A3") {
            editA3();
        } else if (Request["ar_form"] == "A4") {
            editA4();
        } else if (Request["ar_form"] == "A5") {
            editA5();
        } else if (Request["ar_form"] == "A6") {
            editA6();
        } else if (Request["ar_form"] == "A7") {
            editA7();
        } else if (Request["ar_form"] == "A8") {
            editA8();
        } else if (Request["ar_form"] == "A9") {
            editA9();
        } else if (Request["ar_form"] == "AA") {
            editAA();
        } else if (Request["ar_form"] == "AB") {
            editAB();
        } else if (Request["ar_form"] == "AC") {
            editAC();
        } else if (Request["ar_form"].Left(1) == "B") {
            editB();
        } else {
            editZZ();
        }
    }

    /// <summary>
    /// 寫入接洽記錄檔(case_dmt)
    /// </summary>
    private void update_case_dmt() {
        //入case_dmt_log
        Sys.insert_log_table(conn, "U", prgid, "case_dmt", "in_scode;in_no", Request["in_scode"] + ";" + Request["in_no"], logReason);
        
        SQL = "UPDATE case_dmt SET ";
        ColMap.Clear();
        if (ReqVal.TryGet("tfy_source").Trim() != "") ColMap["source"] = Util.dbchar(Request["tfy_source"]);
        if (ReqVal.TryGet("tfy_contract_no").Trim() != "") ColMap["contract_no"] = Util.dbchar(Request["tfy_contract_no"]);
        if (ReqVal.TryGet("dfy_cust_date").Trim() != "") ColMap["cust_date"] = Util.dbchar(Request["dfy_cust_date"]);
        if (ReqVal.TryGet("dfy_pr_date").Trim() != "") ColMap["pr_date"] = Util.dbchar(Request["dfy_pr_date"]);
        if (ReqVal.TryGet("tfy_remark").Trim() != "") ColMap["remark"] = Util.dbnull(Request["tfy_remark"]);
        if (ReqVal.TryGet("tfy_end_flag").Trim() == "" || ReqVal.TryGet("tfy_end_flag").Trim() == "N") {//'****結案註記
            ColMap["end_flag"] = Util.dbchar("N");
            ColMap["end_type"] = Util.dbchar("");
            ColMap["end_remark"] = Util.dbchar("");
        } else {
            ColMap["end_flag"] = Util.dbchar(Request["tfy_end_flag"]);
            ColMap["end_type"] = Util.dbchar(Request["tfy_end_type"]);
            ColMap["end_remark"] = Util.dbchar(Request["tfy_end_remark"]);
        }
        if (ReqVal.TryGet("tfy_back_flag").Trim() == "") {//'****復案註記
            ColMap["back_flag"] = Util.dbchar("N");
            ColMap["back_remark"] = Util.dbchar("");
        } else {
            ColMap["back_flag"] = Util.dbchar(Request["tfy_back_flag"]);
            ColMap["back_remark"] = Util.dbchar(Request["tfy_back_remark"]);
        }
        if (ReqVal.TryGet("grconf_sqlno").Trim() != "") ColMap["grconf_sqlno"] = Util.dbnull(Request["grconf_sqlno"]);
        //****會計檢核2013/9/16增加，不需請款或大陸進口案不在線上請款，不需會計檢核
        if (ReqVal.TryGet("tfy_ar_code").Trim() == "X" || ReqVal.TryGet("tfy_ar_code").Trim() == "M") {
            ColMap["acc_chk"] = Util.dbchar("X");
        }else{
            ColMap["acc_chk"] = Util.dbchar("N");
        }
        SQL += ColMap.GetUpdateSQL();
        SQL += " where in_scode = '" + Request["in_scode"] + "' and in_no = '" + ReqVal.TryGet("In_no").Trim() + "'";
        conn.ExecuteNonQuery(SQL);
    }

    /// <summary>
    /// 將檔案更改檔名
    /// </summary>
    private string move_file(string drawValue, string suffix, string Ofile) {
        if (drawValue.Trim() == "" || drawValue == null)
            return "";

        string in_no = Request["in_no"] ?? "";
        string aa = drawValue.ToLower();
        string oldfilename = Ofile.ToLower();//原先上傳檔名
        string newfilename = "";
        if (aa != oldfilename) {
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
        } else {
            newfilename=drawValue;
        }
        return newfilename;
    }

    /// <summary>
    /// 寫入接洽記錄主檔(dmt_temp)
    /// </summary>
    private void update_dmt_temp() {
        //入dmt_temp_log
        Sys.insert_log_table(conn, "U", prgid, "dmt_temp", "in_no;in_scode", Request["in_no"] + ";" + Request["in_scode"], logReason);
        //刪除子案dmt_temp
        SQL = "delete from dmt_temp where in_no='" + Request["in_no"] + "' and case_sqlno<>0";
        conn.ExecuteNonQuery(SQL);

        //將檔案更改檔名
        drawFilename = move_file(Request["draw_file"], "", Request["file"]);
        //*****若為新案則新增至案件檔,舊案則不用
        SQL = "UPDATE dmt_temp set ";
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
        if ((Request["ar_form"] ?? "") != "A4" && (Request["tfy_arcase"] ?? "") != "FC3") {
            if ((Request["tfzr_class_count"] ?? "") != "") {
                ColMap["class_type"] = Util.dbchar(Request["tfzr_class_type"]);
                ColMap["class_count"] = Util.dbchar(Request["tfzr_class_count"]);
                ColMap["class"] = Util.dbchar(Request["tfzr_class"]);
            }
        } else {
            if ((Request["tft3_class_count2"] ?? "") != "") {
                ColMap["class_type"] = Util.dbchar(Request["tft3_class_type2"]);
                ColMap["class_count"] = Util.dbchar(Request["tft3_class_count2"]);
                ColMap["class"] = Util.dbchar(Request["tft3_class2"]);
            }
        }
        ColMap["draw_file"] = Util.dbchar(Sys.Path2Btbrt(drawFilename));
        ColMap["tr_date"] = "getdate()";
        ColMap["tr_scode"] = "'" + Session["scode"] + "'";
        ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
        SQL += ColMap.GetUpdateSQL();
        SQL += " where in_scode = '" + Request["in_scode"] + "' and in_no = '" + Request["In_no"] + "' and case_sqlno=0";
        conn.ExecuteNonQuery(SQL);
    }

    /// <summary>
    /// 寫入交辦申請人檔(dmt_temp_ap)
    /// </summary>
    private void insert_dmt_temp_ap(string case_sqlno) {
        if ((Request["tfy_arcase"] ?? "").IN("FC1,FC10,FC11,FC5,FC7,FC9,FCA,FCB,FCF,FCH")) {
            insert_dmt_temp_ap_FC2(case_sqlno);
        } else if ((Request["tfy_arcase"] ?? "").IN("FC2,FC20,FC21,FC6,FC8,FC0,FCC,FCD,FCG,FCI")) {
            insert_dmt_temp_ap_FC0(case_sqlno);
        } else {
            insert_dmt_temp_ap0(case_sqlno);
        }
    }

    /// <summary>
    /// 寫入交辦申請人檔(dmt_temp_ap)(Apcust_form)
    /// </summary>
    private void insert_dmt_temp_ap0(string case_sqlno) {
        //交辦申請人
        for (int i = 1; i <= Convert.ToInt32("0" + Request["apnum"]); i++) {
            SQL = "insert into dmt_temp_ap ";
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
            SQL += ColMap.GetInsertSQL();
            conn.ExecuteNonQuery(SQL);
        }
    }

    /// <summary>
    /// 寫入交辦申請人檔(dmt_temp_ap)(Apcust_FC_RE_form)
    /// </summary>
    private void insert_dmt_temp_ap_FC0( string case_sqlno) {
        //交辦申請人
        for (int i = 1; i <= Convert.ToInt32("0" + Request["FC0_apnum"]); i++) {
            SQL = "insert into dmt_temp_ap ";
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
            SQL += ColMap.GetInsertSQL();
            conn.ExecuteNonQuery(SQL);
        }
    }

    /// <summary>
    /// 寫入交辦申請人檔(dmt_temp_ap)(Apcust_FC_RE1_form)
    /// </summary>
    private void insert_dmt_temp_ap_FC2( string case_sqlno) {
        //交辦申請人
        for (int i = 1; i <= Convert.ToInt32("0" + Request["FC2_apnum"]); i++) {
            SQL = "insert into dmt_temp_ap ";
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
            SQL += ColMap.GetInsertSQL();
            conn.ExecuteNonQuery(SQL);
        }
    }
    
   
    /// <summary>
    /// 寫入商品類別檔(casedmt_good)
    /// </summary>
    private void insert_casedmt_good() {
        if ((Request["ar_form"] ?? "") == "A4") {
            //延展以交辦內容為準
            for (int i = 1; i <= Convert.ToInt32("0" + Request["tfzd_class_count"]); i++) {
                //2015/10/21增加判斷若有商品也入，因證明標章及團體標章無類別但會有證明內容
                if ((Request["class2_" + i] ?? "") != "" || (Request["good_name2_" + i] ?? "") != "") {
                    SQL = "insert into casedmt_good ";
                    ColMap.Clear();
                    ColMap["in_scode"] = Util.dbchar(Request["in_scode"]);
                    ColMap["in_no"] = Util.dbchar(Request["in_no"]);
                    ColMap["class"] = Util.dbchar(Request["class2_" + i]);
                    ColMap["dmt_grp_code"] = Util.dbchar(Request["grp_code2_" + i]);
                    ColMap["dmt_goodname"] = Util.dbchar(Request["good_name2_" + i]);
                    ColMap["dmt_goodcount"] = Util.dbchar(Request["good_count2_" + i]);
                    ColMap["tr_date"] = "getdate()";
                    ColMap["tr_scode"] = "'" + Session["scode"] + "'";
                    SQL += ColMap.GetInsertSQL();
                    conn.ExecuteNonQuery(SQL);
                }
            }
        } else if ((Request["tfy_arcase"] ?? "") == "FC3") {
            for (int i = 1; i <= Convert.ToInt32("0" + Request["tft3_class_count2"]); i++) {
                //2015/10/21增加判斷若有商品也入，因證明標章及團體標章無類別但會有證明內容
                if ((Request["class32_" + i] ?? "") != "" || (Request["good_name32_" + i] ?? "") != "") {
                    SQL = "insert into casedmt_good ";
                    ColMap.Clear();
                    ColMap["in_scode"] = Util.dbchar(Request["in_scode"]);
                    ColMap["in_no"] = Util.dbchar(Request["in_no"]);
                    ColMap["class"] = Util.dbchar(Request["class32_" + i]);
                    ColMap["dmt_goodname"] = Util.dbchar(Request["good_name32_" + i]);
                    ColMap["dmt_goodcount"] = Util.dbchar(Request["good_count32_" + i]);
                    ColMap["tr_date"] = "getdate()";
                    ColMap["tr_scode"] = "'" + Session["scode"] + "'";
                    SQL += ColMap.GetInsertSQL();
                    conn.ExecuteNonQuery(SQL);
                }
            }
        } else {
            for (int i = 1; i <= Convert.ToInt32("0" + Request["tfzr_class_count"]); i++) {
                //2015/10/21增加判斷若有商品也入，因證明標章及團體標章無類別但會有證明內容
                if ((Request["class1_" + i] ?? "") != "" || (Request["good_name1_" + i] ?? "") != "") {
                    SQL = "insert into casedmt_good ";
                    ColMap.Clear();
                    ColMap["in_scode"] = Util.dbchar(Request["in_scode"]);
                    ColMap["in_no"] = Util.dbchar(Request["in_no"]);
                    ColMap["case_sqlno"] = Util.dbchar("0");
                    ColMap["class"] = Util.dbchar(Request["class1_" + i]);
                    ColMap["dmt_grp_code"] = Util.dbchar(Request["grp_code1_" + i]);
                    ColMap["dmt_goodname"] = Util.dbchar(Request["good_name1_" + i]);
                    ColMap["dmt_goodcount"] = Util.dbchar(Request["good_count1_" + i]);
                    ColMap["tr_date"] = "getdate()";
                    ColMap["tr_scode"] = "'" + Session["scode"] + "'";
                    SQL += ColMap.GetInsertSQL();
                    conn.ExecuteNonQuery(SQL);
                }
            }
        }
    }

    /// <summary>
    /// 寫入展覽會優先權檔(casedmt_show)
    /// </summary>
    private void insert_casedmt_show( string case_sqlno) {
        for (int i = 1; i <= Convert.ToInt32("0" + Request["shownum_dmt"]); i++) {
            if ((Request["show_date_dmt_" + i] ?? "") != "" || (Request["show_name_dmt_" + i] ?? "") != "") {
                SQL = "insert into casedmt_show ";
                ColMap.Clear();
                ColMap["in_no"] = Util.dbchar(Request["in_no"]);
                ColMap["case_sqlno"] = case_sqlno;
                ColMap["show_date"] = Util.dbnull(Request["show_date_dmt_" + i]);
                ColMap["show_name"] = Util.dbnull(Request["show_name_dmt_" + i]);
                ColMap["tr_date"] = "getdate()";
                ColMap["tr_scode"] = "'" + Session["scode"] + "'";
                SQL += ColMap.GetInsertSQL();
                conn.ExecuteNonQuery(SQL);
            }
        }
    }

    /// <summary>
    /// 後續交辦作業，更新營洽官收確認紀錄檔(grconf_dmt.job_no)
    /// </summary>
    private void upd_grconf_job_no() {
        if ((Request["grconf_sqlno"] ?? "") != "") {
            SQL = "update grconf_dmt set job_no = '" + Request["in_no"] + "' ";
            SQL += "finish_date = getdate() ";
            SQL += "where grconf_sqlno = '" + Request["grconf_sqlno"] + "' ";
            conn.ExecuteNonQuery(SQL);
        }
    }
    
    /// <summary>
    /// 註冊費
    /// </summary>
    private void editA3() {
        //商品入log_table
        Sys.insert_log_table(conn, "U", prgid, "casedmt_good", "in_no;in_scode", Request["in_no"] + ";" + Request["in_scode"], logReason);
        SQL = "delete from casedmt_good where in_no='" + Request["in_no"] + "' and in_scode='" + Request["in_scode"] + "'";
        conn.ExecuteNonQuery(SQL);

        //展覽優先權入log_table
        Sys.insert_log_table(conn, "U", prgid, "casedmt_show", "in_no;case_sqlno", Request["in_no"] + ";0", logReason);
        SQL = "delete from casedmt_show where in_no='" + Request["in_no"] + "' and case_sqlno=0";
        conn.ExecuteNonQuery(SQL);

        update_case_dmt();

        update_dmt_temp();

        insert_casedmt_good();

        insert_casedmt_show("0");

        //申請人入dmt_temp_ap_log
        Sys.insert_log_table(conn, "U", prgid, "dmt_temp_ap", "in_no;case_sqlno", Request["in_no"] + ";0", logReason);
        SQL = "delete from dmt_temp_ap where in_no='" + Request["in_no"] + "' and case_sqlno=0";
        conn.ExecuteNonQuery(SQL);
        insert_dmt_temp_ap("0");

        Sys.updmt_attach_forcase(Context, conn, prgid, (Request["in_no"] ?? ""));

        upd_grconf_job_no();
    }
    
    /// <summary>
    /// 延展
    /// </summary>
    private void editA4() {
        //商品入log_table
        Sys.insert_log_table(conn, "U", prgid, "casedmt_good", "in_no;in_scode", Request["in_no"] + ";" + Request["in_scode"], logReason);
        SQL = "delete from casedmt_good where in_no='" + Request["in_no"] + "' and in_scode='" + Request["in_scode"] + "'";
        conn.ExecuteNonQuery(SQL);

        //展覽優先權入log_table
        Sys.insert_log_table(conn, "U", prgid, "casedmt_show", "in_no;case_sqlno", Request["in_no"] + ";0", logReason);
        SQL = "delete from casedmt_show where in_no='" + Request["in_no"] + "' and case_sqlno=0";
        conn.ExecuteNonQuery(SQL);


        //dmt_tran入log_table
        Sys.insert_log_table(conn, "U", prgid, "dmt_tran", "in_no;in_scode", Request["in_no"] + ";" + Request["in_scode"], logReason);

        //dmt_tranlist入log_table
        Sys.insert_log_table(conn, "U", prgid, "dmt_tranlist", "in_no;in_scode", Request["in_no"] + ";" + Request["in_scode"], logReason);
        SQL = "delete from dmt_tranlist where in_no='" + Request["in_no"] + "' and in_scode='" + Request["in_scode"] + "'";
        conn.ExecuteNonQuery(SQL);

        update_case_dmt();

        update_dmt_temp();

        insert_casedmt_good();

        insert_casedmt_show("0");


        //***異動檔
        SQL = "UPDATE dmt_tran set ";
        ColMap.Clear();
        foreach (var key in Request.Form.Keys) {
            string colkey = key.ToString().ToLower();
            string colValue = Request[colkey];

            //取1~4碼
            if (colkey.Left(4) == "tfgp") {
                ColMap[colkey.Substring(5)] = Util.dbnull(colValue);
            }
        }

        ColMap["tr_date"] = "getdate()";
        ColMap["tr_scode"] = "'" + Session["scode"] + "'";
        SQL += ColMap.GetUpdateSQL();
        SQL += " where in_scode = '" + Request["in_scode"] + "' and in_no = '" + Request["In_no"] + "'";
        conn.ExecuteNonQuery(SQL);

        //*****異動明細
        if ((Request["tfgp_mod_dmt"] ?? "") == "Y") {//變更商標／標章名稱
            SQL = "insert into dmt_tranlist ";
            ColMap.Clear();
            ColMap["in_scode"] = Util.dbchar(Request["in_scode"]);
            ColMap["in_no"] = Util.dbchar(Request["In_no"]);
            ColMap["mod_field"] = "'mod_dmt'";
            ColMap["ncname1"] = Util.dbchar(Request["new_appl_name"]);
            SQL += ColMap.GetInsertSQL();
            conn.ExecuteNonQuery(SQL);
        }

        //申請人入dmt_temp_ap_log
        Sys.insert_log_table(conn, "U", prgid, "dmt_temp_ap", "in_no;case_sqlno", Request["in_no"] + ";0", logReason);
        SQL = "delete from dmt_temp_ap where in_no='" + Request["in_no"] + "' and case_sqlno=0";
        conn.ExecuteNonQuery(SQL);
        insert_dmt_temp_ap("0");

        Sys.updmt_attach_forcase(Context, conn, prgid, (Request["in_no"] ?? ""));

        upd_grconf_job_no();
    }
    
    /// <summary>
    /// 分割
    /// </summary>
    private void editA5() {
        //商品入log_table
        Sys.insert_log_table(conn, "U", prgid, "casedmt_good", "in_no;in_scode", Request["in_no"] + ";" + Request["in_scode"], logReason);
        SQL = "delete from casedmt_good where in_no='" + Request["in_no"] + "' and in_scode='" + Request["in_scode"] + "'";
        conn.ExecuteNonQuery(SQL);

        //展覽優先權入log_table
        Sys.insert_log_table(conn, "U", prgid, "casedmt_show", "in_no", Request["in_no"], logReason);
        SQL = "delete from casedmt_show where in_no='" + Request["in_no"] + "'";
        conn.ExecuteNonQuery(SQL);

        //dmt_tran入log_table
        Sys.insert_log_table(conn, "U", prgid, "dmt_tran", "in_no;in_scode", Request["in_no"] + ";" + Request["in_scode"], logReason);
        SQL = "delete from dmt_tran where in_no='" + Request["in_no"] + "' and in_scode='" + Request["in_scode"] + "'";
        conn.ExecuteNonQuery(SQL);

        update_case_dmt();

        update_dmt_temp();

        insert_casedmt_good();

        insert_casedmt_show("0");

        //***異動檔
        SQL = "insert into dmt_tran ";
        ColMap.Clear();
        switch ((Request["tfy_arcase"] ?? "").Left(3)) {
            case "FD1":
                ColMap["other_item"] = Util.dbchar(Request["O_item11"] + ";" + Request["O_item12"] + ";" + Request["O_item13"]);
                break;
            case "FD2":
            case "FD3":
                ColMap["other_item"] = Util.dbchar(Request["O_item21"] + ";" + Request["O_item22"] + ";" + Request["O_item23"]);
                break;
        }
        ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
        ColMap["in_no"] = Util.dbchar(Request["In_no"]);
        ColMap["tr_date"] = "getdate()";
        ColMap["tr_scode"] = "'" + Session["scode"] + "'";
        ColMap["seq"] = Util.dbnull(Request["tfzb_seq"]);
        ColMap["seq1"] = Util.dbnull(Request["tfzb_seq1"]);
        SQL += ColMap.GetInsertSQL();
        conn.ExecuteNonQuery(SQL);

        //申請人入dmt_temp_ap_log
        Sys.insert_log_table(conn, "U", prgid, "dmt_temp_ap", "in_no", Request["in_no"], logReason);
        SQL = "delete from dmt_temp_ap where in_no='" + Request["in_no"] + "'";
        conn.ExecuteNonQuery(SQL);
        insert_dmt_temp_ap("0");

        Sys.updmt_attach_forcase(Context, conn, prgid, (Request["in_no"] ?? ""));


        //件數
        for (int x = 1; x <= Convert.ToInt32("0" + Request["nfy_tot_num"]); x++) {
            string case_sqlno = "";

            switch ((Request["tfy_arcase"] ?? "").Left(3)) {
                case "FD1":
                    case_sqlno = Request["FD1_case_sqlno_" + x];
                    break;
                case "FD2":
                case "FD3":
                    case_sqlno = Request["FD2_case_sqlno_" + x];
                    break;
            }

            SQL = "UPDATE dmt_temp SET ";
            ColMap.Clear();
            if ((Request["tfzd_S_mark"] ?? "") != "") ColMap["s_mark"] = Util.dbchar(Request["tfzd_S_mark"]);
            if ((Request["tfzd_pul"] ?? "") != "") ColMap["pul"] = Util.dbchar(Request["tfzd_pul"]);
            if ((Request["tfzd_Appl_name"] ?? "") != "") ColMap["appl_name"] = Util.dbchar(Request["tfzd_Appl_name"]);
            if ((Request["tfzd_cappl_name"] ?? "") != "") ColMap["cappl_name"] = Util.dbchar(Request["tfzd_cappl_name"]);
            if ((Request["tfzd_eappl_name"] ?? "") != "") ColMap["eappl_name"] = Util.dbchar(Request["tfzd_eappl_name"]);
            if ((Request["tfzd_eappl_name1"] ?? "") != "") ColMap["eappl_name1"] = Util.dbchar(Request["tfzd_eappl_name1"]);
            if ((Request["tfzd_eappl_name2"] ?? "") != "") ColMap["eappl_name2"] = Util.dbchar(Request["tfzd_eappl_name2"]);
            if ((Request["tfzd_jappl_name"] ?? "") != "") ColMap["jappl_name"] = Util.dbchar(Request["tfzd_jappl_name"]);
            if ((Request["tfzd_jappl_name1"] ?? "") != "") ColMap["jappl_name1"] = Util.dbchar(Request["tfzd_jappl_name1"]);
            if ((Request["tfzd_jappl_name2"] ?? "") != "") ColMap["jappl_name2"] = Util.dbchar(Request["tfzd_jappl_name2"]);
            if ((Request["tfzd_zappl_name1"] ?? "") != "") ColMap["zappl_name1"] = Util.dbchar(Request["tfzd_zappl_name1"]);
            if ((Request["tfzd_zappl_name2"] ?? "") != "") ColMap["zappl_name2"] = Util.dbchar(Request["tfzd_zappl_name2"]);
            if ((Request["tfzd_zname_type"] ?? "") != "") ColMap["zname_type"] = Util.dbchar(Request["tfzd_zname_type"]);
            if ((Request["tfzd_oappl_name"] ?? "") != "") ColMap["oappl_name"] = Util.dbchar(Request["tfzd_oappl_name"]);
            if ((Request["tfzd_Draw"] ?? "") != "") ColMap["Draw"] = Util.dbchar(Request["tfzd_Draw"]);
            if ((Request["tfzd_symbol"] ?? "") != "") ColMap["symbol"] = Util.dbchar(Request["tfzd_symbol"]);
            if ((Request["tfzd_color"] ?? "") != "") ColMap["color"] = Util.dbchar(Request["tfzd_color"]);
            if ((Request["tfzd_agt_no"] ?? "") != "") ColMap["agt_no"] = Util.dbchar(Request["tfzd_agt_no"]);
            if ((Request["pfzd_prior_date"] ?? "") != "") ColMap["prior_date"] = Util.dbchar(Request["pfzd_prior_date"]);
            if ((Request["tfzd_prior_no"] ?? "") != "") ColMap["prior_no"] = Util.dbchar(Request["tfzd_prior_no"]);
            if ((Request["tfzd_prior_country"] ?? "") != "") ColMap["prior_country"] = Util.dbchar(Request["tfzd_prior_country"]);
            if ((Request["tfzd_ref_no"] ?? "") != "") ColMap["ref_no"] = Util.dbchar(Request["tfzd_ref_no"]);
            if ((Request["tfzd_ref_no1"] ?? "") != "") ColMap["ref_no1"] = Util.dbchar(Request["tfzd_ref_no1"]);
            //2014/4/15增加寫入申請日，因分割子案申請日與母案相同
            if ((Request["tfzd_apply_date"] ?? "") != "") ColMap["apply_date"] = Util.dbchar(Request["tfzd_apply_date"]);
            switch ((Request["tfy_arcase"] ?? "").Left(3)) {
                case "FD1":
                    ColMap["class_count"] = Util.dbchar(Request["FD1_class_count_" + x]);
                    ColMap["class"] = Util.dbchar(Request["FD1_class_" + x]);
                    ColMap["class_type"] = Util.dbchar(Request["FD1_class_type_" + x]);
                    ColMap["mark"] = Util.dbchar(Request["FD1_Marka_" + x]);
                    //分割後子案之商標種類2
                    string s_mark2 = "";
                    if ((Request["tfy_div_arcase"] ?? "").Substring(2, 1).IN("1,5,H")) s_mark2 = "A";
                    else if ((Request["tfy_div_arcase"] ?? "").Substring(2, 1).IN("4,8,C,G")) s_mark2 = "B";
                    else if ((Request["tfy_div_arcase"] ?? "").Substring(2, 1).IN("3,7,B,F")) s_mark2 = "C";
                    else if ((Request["tfy_div_arcase"] ?? "").Substring(2, 1).IN("2,6,A,E")) s_mark2 = "D";
                    else if ((Request["tfy_div_arcase"] ?? "").Substring(2, 1).IN("I")) s_mark2 = "E";
                    else if ((Request["tfy_div_arcase"] ?? "").Substring(2, 1).IN("J")) s_mark2 = "F";
                    else if ((Request["tfy_div_arcase"] ?? "").Substring(2, 1).IN("K")) s_mark2 = "G";
                    else s_mark2 = "A";
                    ColMap["s_mark2"] = Util.dbchar(s_mark2);
                    break;
                case "FD2":
                case "FD3":
                    ColMap["class_count"] = Util.dbchar(Request["FD2_class_count_" + x]);
                    ColMap["class"] = Util.dbchar(Request["FD2_class_" + x]);
                    ColMap["class_type"] = Util.dbchar(Request["FD2_class_type_" + x]);
                    ColMap["mark"] = Util.dbchar(Request["FD2_Markb_" + x]);
                    ColMap["s_mark2"] = Util.dbchar(Request["tfzd_s_mark2"]);
                    break;
            }
            ColMap["tr_date"] = "getdate()";
            ColMap["tr_scode"] = "'" + Session["scode"] + "'";
            SQL += ColMap.GetUpdateSQL();
            SQL += " where in_scode = '" + Request["in_scode"] + "' and in_no = '" + Request["In_no"] + "'";
            SQL += " and case_sqlno='" + case_sqlno + "'";
            conn.ExecuteNonQuery(SQL);


            switch ((Request["tfy_arcase"] ?? "").Left(3)) {
                case "FD1":
                    //分割子案商品類別入檔
                    for (int p = 1; p <= Convert.ToInt32("0" + Request["FD1_class_count_" + x]); p++) {
                        if ((Request["classa_" + x + "_" + p] ?? "") != "" || (Request["FD1_good_namea_" + x + "_" + p] ?? "") != "") {
                            ColMap.Clear();
                            ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
                            ColMap["in_no"] = Util.dbchar(Request["In_no"]);
                            ColMap["case_sqlno"] = "'" + Request["FD1_case_sqlno_" + x] + "'";
                            ColMap["class"] = Util.dbchar(Request["classa_" + x + "_" + p]);
                            ColMap["dmt_goodname"] = Util.dbchar(Request["FD1_good_namea_" + x + "_" + p]);
                            ColMap["dmt_goodcount"] = Util.dbchar(Request["FD1_good_counta_" + x + "_" + p]);
                            ColMap["tr_date"] = "getdate()";
                            ColMap["tr_scode"] = "'" + Session["scode"] + "'";
                            SQL = "insert into casedmt_good " + ColMap.GetInsertSQL();
                            conn.ExecuteNonQuery(SQL);
                        }
                    }
                    break;
                case "FD2":
                case "FD3":
                    //分割子案商品類別入檔
                    for (int p = 1; p <= Convert.ToInt32("0" + Request["FD2_class_count_" + x]); p++) {
                        if ((Request["classb_" + x + "_" + p] ?? "") != "" || (Request["FD2_good_nameb_" + x + "_" + p] ?? "") != "") {
                            ColMap.Clear();
                            ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
                            ColMap["in_no"] = Util.dbchar(Request["In_no"]);
                            ColMap["case_sqlno"] = "'" + Request["FD2_case_sqlno_" + x] + "'";
                            ColMap["class"] = Util.dbchar(Request["classb_" + x + "_" + p]);
                            ColMap["dmt_goodname"] = Util.dbchar(Request["FD2_good_nameb_" + x + "_" + p]);
                            ColMap["dmt_goodcount"] = Util.dbchar(Request["FD2_good_countb_" + x + "_" + p]);
                            ColMap["tr_date"] = "getdate()";
                            ColMap["tr_scode"] = "'" + Session["scode"] + "'";
                            SQL = "insert into casedmt_good " + ColMap.GetInsertSQL();
                            conn.ExecuteNonQuery(SQL);
                        }
                    }
                    break;
            }


            //分割子案展覽優先權入檔
            //分割後案性除FA9,FAA,FAB,FAC外(因所列案性無展覽優先權)，再依母案展覽優先權資料入檔
            if ((Request["tfy_div_arcase"] ?? "").Left(3) != "FA9" && (Request["tfy_div_arcase"] ?? "").Left(3) != "FAA"
            && (Request["tfy_div_arcase"] ?? "").Left(3) != "FAB" && (Request["tfy_div_arcase"] ?? "").Left(3) != "FAC") {
                //分割子案展覽優先權入檔
                insert_casedmt_show(case_sqlno);
            }

            //申請人_分割子案
            insert_dmt_temp_ap0(case_sqlno);
        }

        upd_grconf_job_no();
    }
    
    /// <summary>
    /// 變更
    /// </summary>
    private void editA6() {
        //商品入log_table
        Sys.insert_log_table(conn, "U", prgid, "casedmt_good", "in_no;in_scode", Request["in_no"] + ";" + Request["in_scode"], logReason);
        SQL = "delete from casedmt_good where in_no='" + Request["in_no"] + "' and in_scode='" + Request["in_scode"] + "' and case_sqlno=0";
        conn.ExecuteNonQuery(SQL);

        //展覽優先權入log_table
        Sys.insert_log_table(conn, "U", prgid, "casedmt_show", "in_no;case_sqlno", Request["in_no"] + ";0", logReason);
        SQL = "delete from casedmt_show where in_no='" + Request["in_no"] + "' and case_sqlno=0";
        conn.ExecuteNonQuery(SQL);

        //dmt_tran入log_table
        Sys.insert_log_table(conn, "U", prgid, "dmt_tran", "in_no;in_scode", Request["in_no"] + ";" + Request["in_scode"], logReason);

        //dmt_tranlist入log_table
        Sys.insert_log_table(conn, "U", prgid, "dmt_tranlist", "in_no;in_scode", Request["in_no"] + ";" + Request["in_scode"], logReason);
        SQL = "delete from dmt_tranlist where in_no='" + Request["in_no"] + "' and in_scode='" + Request["in_scode"] + "'";
        conn.ExecuteNonQuery(SQL);

        update_case_dmt();


        //清空暫存檔
        SQL = "delete from dmt_temp_change where in_scode='" + Request["F_tscode"] + "' and cust_area='" + Request["F_cust_area"] + "' and cust_seq='" + Request["F_cust_seq"] + "' and (mark='C' or mark is null)";
        conn.ExecuteNonQuery(SQL);
        SQL = "delete from casedmt_good_change where in_scode='" + Request["F_tscode"] + "' and cust_area='" + Request["F_cust_area"] + "' and cust_seq='" + Request["F_cust_seq"] + "' and (mark='C' or mark is null)";
        conn.ExecuteNonQuery(SQL);
        SQL = "delete from casedmt_show_change where in_scode='" + Request["F_tscode"] + "' and cust_area='" + Request["F_cust_area"] + "' and cust_seq='" + Request["F_cust_seq"] + "' and (mark='C' or mark is null)";
        conn.ExecuteNonQuery(SQL);


        update_dmt_temp();


        insert_casedmt_good();

        insert_casedmt_show("0");

        string Num = "";
        if ((Request["tfy_arcase"] ?? "").Left(3).IN("FC9,FC1,FC5,FC7,FCA,FCB,FCF,FCH")) {
            Num = "1";
        } else if ((Request["tfy_arcase"] ?? "").Left(3).IN("FC2,FC0,FC6,FC8,FCC,FCD,FCG,FCI")) {
            Num = "2";
        } else if ((Request["tfy_arcase"] ?? "").Left(3).IN("FC3")) {
            Num = "3";
        } else if ((Request["tfy_arcase"] ?? "").Left(3).IN("FC4")) {
            Num = "4";
        }

        SQL = "UPDATE dmt_tran set ";
        ColMap.Clear();
        foreach (var key in Request.Form.Keys) {
            string colkey = key.ToString().ToLower();
            string colValue = Request[colkey];

            //取2~5碼(直接用substr若欄位名稱太短會壞掉)
            if (colkey.Left(4).Substring(1) == "fg" + Num) {
                if (colkey.Left(1) == "d") {
                    ColMap[colkey.Substring(5)] = Util.dbnull(colValue);
                } else if (colkey.Left(1) == "n") {
                    ColMap[colkey.Substring(5)] = Util.dbzero(colValue);
                } else {
                    ColMap[colkey.Substring(5)] = Util.dbnull(colValue);
                }
            }
        }

        if ((Request["tfy_arcase"] ?? "").IN("FC21,FC6,FC8,FCI")) {
            if ((Request["O_item211"] ?? "") != "" || (Request["O_item221"] ?? "") != "") {
                ColMap["other_item"] = Util.dbchar(Request["O_item211"] + ";" + Request["O_item221"] + ";" + Request["O_item231"]);
            }
            if ((Request["tfop1_oitem1"] ?? "") == "Y") {
                ColMap["other_item1"] = Util.dbchar("Y," + Request["tfop1_oitem1c"]);
            }
            if ((Request["tfop1_oitem2"] ?? "") == "Y") {
                ColMap["other_item2"] = Util.dbchar("Y," + Request["tfop1_oitem2c"]);
            }
        } else if ((Request["tfy_arcase"] ?? "").IN("FC2,FC20,FC0,FCC,FCD,FCG")) {
            if ((Request["O_item21"] ?? "") != "" || (Request["O_item22"] ?? "") != "") {
                ColMap["other_item"] = Util.dbchar(Request["O_item21"] + ";" + Request["O_item22"] + ";" + Request["O_item23"]);
            }
            if ((Request["tfop_oitem1"] ?? "") == "Y") {
                ColMap["other_item1"] = Util.dbchar("Y," + Request["tfop_oitem1c"]);
            }
            if ((Request["tfop_oitem2"] ?? "") == "Y") {
                ColMap["other_item2"] = Util.dbchar("Y," + Request["tfop_oitem2c"]);
            } else {
                ColMap["other_item2"] = "null";
            }
        } else if ((Request["tfy_arcase"] ?? "").IN("FC3")) {
            if ((Request["O_item31"] ?? "") != "" || (Request["O_item32"] ?? "") != "") {
                ColMap["other_item"] = Util.dbchar(Request["O_item31"] + ";" + Request["O_item32"] + ";" + Request["O_item33"]);
            }
        }
        ColMap["tr_date"] = "getdate()";
        ColMap["tr_scode"] = "'" + Session["scode"] + "'";
        ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
        SQL += ColMap.GetUpdateSQL();
        SQL += " where in_scode = '" + Request["in_scode"] + "' and in_no = '" + Request["In_no"] + "'";
        conn.ExecuteNonQuery(SQL);

        string in_scode = Request["F_tscode"] ?? "";
        if (prgid == "brt52") {
            in_scode = Request["in_scode"] ?? "";
        }

        if ((Request["tfy_arcase"] ?? "").IN("FC1,FC10,FC11,FC5,FC7,FC9,FCA,FCB,FCF,FCH")) {
            //*****變更申請人(原申請人)(apcust_FC_RE1_form)
            if ((Request["tfg1_mod_ap"] ?? "") == "Y") {
                for (int k = 1; k <= Convert.ToInt32("0" + Request["FC1_apnum"]); k++) {
                    SQL = "insert into dmt_tranlist(in_scode,in_no,mod_field,old_no,ocname1,ocname2,oename1,oename2) values (";
                    SQL += "'" + in_scode + "'," + Util.dbchar(Request["In_no"]) + ",'mod_ap'";
                    SQL += "," + Util.dbchar(Request["tft1_old_no_" + k]) + "," + Util.dbchar(Request["tft1_ocname1_" + k]) + "";
                    SQL += "," + Util.dbchar(Request["tft1_ocname2_" + k]) + "," + Util.dbchar(Request["tft1_oename1_" + k]) + "";
                    SQL += "," + Util.dbchar(Request["tft1_oename2_" + k]) + ")";
                    conn.ExecuteNonQuery(SQL);
                }
            }
            //*****變更註冊申請案號數
            if ((Request["tfy_arcase"] ?? "").IN("FC1,FC10,FC9,FCA,FCB,FCF")) {
                for (int k = 1; k <= Convert.ToInt32("0" + Request["tft1_mod_count11"]); k++) {
                    SQL = "insert into dmt_tranlist(in_scode,in_no,mod_field,mod_count,new_no,ncname1) values (";
                    SQL += "'" + in_scode + "'," + Util.dbchar(Request["In_no"]) + ",'mod_tcnref'";
                    SQL += "," + Util.dbchar(Request["tft1_mod_count11"]) + "," + Util.dbchar(Request["new_no1" + k]) + "";
                    SQL += "," + Util.dbchar(Request["ncname11" + k]) + ")";
                    conn.ExecuteNonQuery(SQL);
                }
            }
            //*****增加代理人	 
            if ((Request["tfy_arcase"] ?? "") == "FCA") {
                SQL = "insert into dmt_tranlist(in_scode,in_no,mod_field,new_no) values (";
                SQL += "'" + in_scode + "'," + Util.dbchar(Request["In_no"]) + ",'mod_agt'";
                SQL += "," + Util.dbchar(Request["FC1_add_agt_no"]) + ")";
                conn.ExecuteNonQuery(SQL);
            }
        } else if ((Request["tfy_arcase"] ?? "").IN("FC2,FC20,FC21,FC0,FC6,FC8,FCC,FCD,FCG,FCI")) {
            //*****變更申請人
            if ((Request["tfg2_mod_ap"] ?? "") != "NNN") {
                for (int i = 1; i <= Convert.ToInt32("0" + Request["FC0_apnum"]); i++) {
                    ColMap.Clear();
                    ColMap["in_scode"] = Util.dbchar(in_scode);
                    ColMap["in_no"] = Util.dbchar(Request["In_no"]);
                    ColMap["mod_field"] = "'mod_ap'";
                    ColMap["new_no"] = Util.dbchar(Request["dbmn_new_no_" + i]);
                    if ((Request["tfg2_mod_ap"] ?? "").Substring(1, 1) == "Y") {
                        ColMap["ncname1"] = Util.dbchar(Request["dbmn_ncname1_" + i]);
                        ColMap["ncname2"] = Util.dbchar(Request["dbmn_ncname2_" + i]);
                    }
                    if ((Request["tfg2_mod_ap"] ?? "").Substring(2, 1) == "Y") {
                        ColMap["nename1"] = Util.dbchar(Request["dbmn_nename1_" + i]);
                        ColMap["nename2"] = Util.dbchar(Request["dbmn_nename2_" + i]);
                    }
                    SQL = "insert into dmt_tranlist " + ColMap.GetInsertSQL();
                    conn.ExecuteNonQuery(SQL);
                }
            }
            //*****變更申請人地址
            if ((Request["tfg2_mod_apaddr"] ?? "") != "NN") {
                for (int i = 1; i <= Convert.ToInt32("0" + Request["FC0_apnum"]); i++) {
                    ColMap.Clear();
                    ColMap["in_scode"] = Util.dbchar(in_scode);
                    ColMap["in_no"] = Util.dbchar(Request["In_no"]);
                    ColMap["mod_field"] = "'mod_apaddr'";
                    ColMap["new_no"] = Util.dbchar(Request["dbmn_new_no_" + i]);
                    if ((Request["tfg2_mod_apaddr"] ?? "").Substring(0, 1) == "Y") {
                        ColMap["nzip"] = Util.dbchar(Request["dbmn_nzip_" + i]);
                        ColMap["naddr1"] = Util.dbchar(Request["dbmn_naddr1_" + i]);
                        ColMap["naddr2"] = Util.dbchar(Request["dbmn_naddr2_" + i]);
                    }
                    if ((Request["tfg2_mod_apaddr"] ?? "").Substring(1, 1) == "Y") {
                        ColMap["neaddr1"] = Util.dbchar(Request["dbmn_neaddr1_" + i]);
                        ColMap["neaddr2"] = Util.dbchar(Request["dbmn_neaddr2_" + i]);
                        ColMap["neaddr3"] = Util.dbchar(Request["dbmn_neaddr3_" + i]);
                        ColMap["neaddr4"] = Util.dbchar(Request["dbmn_neaddr4_" + i]);
                    }
                    SQL = "insert into dmt_tranlist " + ColMap.GetInsertSQL();
                    conn.ExecuteNonQuery(SQL);
                }
            }
            //*****變更代表人
            if ((Request["tfg2_mod_aprep"] ?? "") != "NN") {
                for (int i = 1; i <= Convert.ToInt32("0" + Request["FC0_apnum"]); i++) {
                    ColMap.Clear();
                    ColMap["in_scode"] = Util.dbchar(in_scode);
                    ColMap["in_no"] = Util.dbchar(Request["In_no"]);
                    ColMap["mod_field"] = "'mod_aprep'";
                    ColMap["new_no"] = Util.dbchar(Request["dbmn_new_no_" + i]);
                    if ((Request["tfg2_mod_aprep"] ?? "").Substring(0, 1) == "Y") {
                        ColMap["ncrep"] = Util.dbchar(Request["dbmn_ncrep_" + i]);
                    }
                    if ((Request["tfg2_mod_aprep"] ?? "").Substring(1, 1) == "Y") {
                        ColMap["nerep"] = Util.dbchar(Request["dbmn_nerep_" + i]);
                    }
                    SQL = "insert into dmt_tranlist " + ColMap.GetInsertSQL();
                    conn.ExecuteNonQuery(SQL);
                }
            }
            //*****其他變更事項1
            if ((Request["tfg2_mod_dmt"] ?? "") == "Y") {
                ColMap.Clear();
                ColMap["in_scode"] = Util.dbchar(in_scode);
                ColMap["in_no"] = Util.dbchar(Request["In_no"]);
                ColMap["mod_field"] = "'mod_dmt'";
                if ((Request["tfy_arcase"] ?? "").IN("FC21,FC6,FC8,FCI")) {
                    ColMap["ncname1"] = Util.dbchar(Request["ttg21_ncname1"]);
                } else {
                    ColMap["ncname1"] = Util.dbchar(Request["ttg2_ncname1"]);
                }
                SQL = "insert into dmt_tranlist " + ColMap.GetInsertSQL();
                conn.ExecuteNonQuery(SQL);
            }
            //*****其他變更事項2
            if ((Request["tfg2_mod_claim1"] ?? "") == "Y") {
                ColMap.Clear();
                ColMap["in_scode"] = Util.dbchar(in_scode);
                ColMap["in_no"] = Util.dbchar(Request["In_no"]);
                ColMap["mod_field"] = "'mod_claim1'";
                if ((Request["tfy_arcase"] ?? "").IN("FC21,FC6,FC8,FCI")) {
                    ColMap["ncname1"] = Util.dbchar(Request["ttg21_ncname2"]);
                } else {
                    ColMap["ncname1"] = Util.dbchar(Request["ttg2_ncname2"]);
                }
                SQL = "insert into dmt_tranlist " + ColMap.GetInsertSQL();
                conn.ExecuteNonQuery(SQL);
            }
            //*****變更註冊申請案號數
            if ((Request["tfy_arcase"] ?? "").IN("FC2,FC20,FC0,FCC,FCD,FCG")) {
                if ((Request["tft2_mod_count2"] ?? "") != "") {
                    ColMap.Clear();
                    ColMap["in_scode"] = Util.dbchar(in_scode);
                    ColMap["in_no"] = Util.dbchar(Request["In_no"]);
                    ColMap["mod_field"] = "'mod_tcnref'";
                    ColMap["mod_count"] = Util.dbchar(Request["tft2_mod_count2"]);
                    ColMap["new_no"] = Util.dbchar(Request["new_no21"]);
                    ColMap["ncname1"] = Util.dbchar(Request["ncname121"]);

                    SQL = "insert into dmt_tranlist " + ColMap.GetInsertSQL();
                    conn.ExecuteNonQuery(SQL);
                }
            }
            //'*****變更註冊申請案號數
            for (int j = 1; j <= 5; j++) {
                if ((Request["tft2_mod_count2" + j] ?? "") != "") {
                    for (int i = 1; i <= Convert.ToInt32("0" + Request["tft2_mod_count2" + j]); i++) {
                        ColMap.Clear();
                        ColMap["in_scode"] = Util.dbchar(in_scode);
                        ColMap["in_no"] = Util.dbchar(Request["In_no"]);
                        ColMap["mod_field"] = "'mod_tcnref'";
                        ColMap["mod_type"] = Util.dbchar(Request["tft2_mod_type_" + j]);
                        ColMap["mod_count"] = Util.dbchar(Request["tft2_mod_count2_" + j]);
                        ColMap["new_no"] = Util.dbchar(Request["new_no2_" + j + "_" + i]);
                        ColMap["ncname1"] = Util.dbchar(Request["ncname12_" + j + "_" + i]);

                        SQL = "insert into dmt_tranlist " + ColMap.GetInsertSQL();
                        conn.ExecuteNonQuery(SQL);
                    }
                }
            }
            //*****新增代理人
            if ((Request["tfy_arcase"] ?? "") == "FCC") {
                ColMap.Clear();
                ColMap["in_scode"] = Util.dbchar(in_scode);
                ColMap["in_no"] = Util.dbchar(Request["In_no"]);
                ColMap["mod_field"] = "'mod_agt'";
                ColMap["new_no"] = Util.dbchar(Request["FC2_add_agt_no"]);

                SQL = "insert into dmt_tranlist " + ColMap.GetInsertSQL();
                conn.ExecuteNonQuery(SQL);
            }
        } else if ((Request["tfy_arcase"] ?? "").IN("FC3")) {
            //*****擬減縮商品(服務名稱)
            if ((Request["tfg3_mod_class"] ?? "") == "Y") {
                for (int i = 1; i <= Convert.ToInt32("0" + Request["tft3_class_count1"]); i++) {
                    if ((Request["class31_" + i] ?? "") != "") {
                        ColMap.Clear();
                        ColMap["in_scode"] = Util.dbchar(in_scode);
                        ColMap["in_no"] = Util.dbchar(Request["In_no"]);
                        ColMap["mod_field"] = "'mod_class'";
                        ColMap["mod_type"] = Util.dbchar(Request["tft3_mod_type"]);
                        ColMap["mod_dclass"] = Util.dbchar(Request["tft3_class1"]);
                        ColMap["mod_count"] = Util.dbchar(Request["tft3_class_count1"]);
                        ColMap["new_no"] = Util.dbchar(Request["class31_" + i]);
                        ColMap["list_remark"] = Util.dbchar(Request["good_name31_" + i]);

                        SQL = "insert into dmt_tranlist " + ColMap.GetInsertSQL();
                        conn.ExecuteNonQuery(SQL);
                    }
                }
            }
        } else if ((Request["tfy_arcase"] ?? "").IN("FC4")) {
            //*****變更註冊申請案號數
            for (int k = 1; k <= Convert.ToInt32("0" + Request["tft4_mod_count41"]); k++) {
                SQL = "insert into dmt_tranlist(in_scode,in_no,mod_field,mod_type,mod_count,new_no,ncname1) values (";
                SQL += "'" + in_scode + "','" + Request["in_no"] + "','mod_tcnref'";
                SQL += "," + Util.dbchar(Request["tft4_mod_type"]) + "," + Util.dbchar(Request["tft4_mod_count41"]) + "";
                SQL += "," + Util.dbchar(Request["new_no41_" + k]) + "," + Util.dbchar(Request["ncname141_" + k]) + ")";
                conn.ExecuteNonQuery(SQL);
            }
        }

        //申請人入dmt_temp_ap_log
        Sys.insert_log_table(conn, "U", prgid, "dmt_temp_ap", "in_no;case_sqlno", Request["in_no"] + ";0", logReason);
        SQL = "delete from dmt_temp_ap where in_no='" + Request["in_no"] + "' and case_sqlno=0";
        conn.ExecuteNonQuery(SQL);

        insert_dmt_temp_ap("0");

        Sys.updmt_attach_forcase(Context, conn, prgid, (Request["in_no"] ?? ""));

        upd_grconf_job_no();
    }
    
    /// <summary>
    /// 授權
    /// </summary>
    private void editA7() {
        //商品入log_table
        Sys.insert_log_table(conn, "U", prgid, "casedmt_good", "in_no;in_scode", Request["in_no"] + ";" + Request["in_scode"], logReason);
        SQL = "delete from casedmt_good where in_no='" + Request["in_no"] + "' and in_scode='" + Request["in_scode"] + "'";
        conn.ExecuteNonQuery(SQL);

        //展覽優先權入log_table
        Sys.insert_log_table(conn, "U", prgid, "casedmt_show", "in_no;case_sqlno", Request["in_no"] + ";0", logReason);
        SQL = "delete from casedmt_show where in_no='" + Request["in_no"] + "' and case_sqlno=0";
        conn.ExecuteNonQuery(SQL);

        //dmt_tran入log_table
        Sys.insert_log_table(conn, "U", prgid, "dmt_tran", "in_no;in_scode", Request["in_no"] + ";" + Request["in_scode"], logReason);

        //dmt_tranlist入log_table
        Sys.insert_log_table(conn, "U", prgid, "dmt_tranlist", "in_no;in_scode", Request["in_no"] + ";" + Request["in_scode"], logReason);
        SQL = "delete from dmt_tranlist where in_no='" + Request["in_no"] + "' and in_scode='" + Request["in_scode"] + "'";
        conn.ExecuteNonQuery(SQL);

        update_case_dmt();

        update_dmt_temp();

        insert_casedmt_good();

        insert_casedmt_show("0");

        SQL = "UPDATE dmt_tran set ";
        ColMap.Clear();
        foreach (var key in Request.Form.Keys) {
            string colkey = key.ToString().ToLower();
            string colValue = Request[colkey];

            //取1~4碼
            if (colkey.Left(4) == "tfg1") {
                ColMap[colkey.Substring(5)] = Util.dbnull(colValue);
            }
        }
        if ((Request["O_item1"] ?? "") != "" || (Request["O_item2"] ?? "") != "") {//附註
            ColMap["other_item"] = Util.dbchar(Request["O_item1"] + ";" + Request["O_item2"]);
        }
        if ((Request["other_item2"] ?? "") != "") {
            if ((Request["other_item2t"] ?? "") != "") {
                ColMap["other_item2"] = Util.dbchar(Request["other_item2"] + "," + Request["other_item2t"]);
            } else {
                ColMap["other_item2"] = Util.dbchar(Request["other_item2"]);
            }
        }
        ColMap["tr_date"] = "getdate()";
        ColMap["tr_scode"] = "'" + Session["scode"] + "'";
        ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
        SQL += ColMap.GetUpdateSQL();
        SQL += " where in_scode = '" + Request["in_scode"] + "' and in_no = '" + Request["In_no"] + "'";
        conn.ExecuteNonQuery(SQL);


        //*****新增案件異動明細檔，關係人資料
        for (int i = 1; i <= Convert.ToInt32("0" + Request["fl_apnum"]); i++) {
            SQL = "insert into dmt_tranlist ";
            ColMap.Clear();
            ColMap["in_scode"] = Util.dbchar(Request["in_scode"]);
            ColMap["in_no"] = Util.dbchar(Request["in_no"]);
            ColMap["mod_field"] = "'mod_ap'";
            ColMap["old_no"] = Util.dbchar(Request["tfr_old_no_" + i]);
            ColMap["ocname1"] = Util.dbchar(Request["tfr_ocname1_" + i]);
            ColMap["ocname2"] = Util.dbchar(Request["tfr_ocname2_" + i]);
            ColMap["oename1"] = Util.dbchar(Request["tfr_oename1_" + i]);
            ColMap["oename2"] = Util.dbchar(Request["tfr_oename2_" + i]);
            ColMap["ocrep"] = Util.dbchar(Request["tfr_ocrep_" + i]);
            ColMap["oerep"] = Util.dbchar(Request["tfr_oerep_" + i]);
            ColMap["ozip"] = Util.dbchar(Request["tfr_ozip_" + i]);
            ColMap["oaddr1"] = Util.dbchar(Request["tfr_oaddr1_" + i]);
            ColMap["oaddr2"] = Util.dbchar(Request["tfr_oaddr2_" + i]);
            ColMap["oeaddr1"] = Util.dbchar(Request["tfr_oeaddr1_" + i]);
            ColMap["oeaddr2"] = Util.dbchar(Request["tfr_oeaddr2_" + i]);
            ColMap["oeaddr3"] = Util.dbchar(Request["tfr_oeaddr3_" + i]);
            ColMap["oeaddr4"] = Util.dbchar(Request["tfr_oeaddr4_" + i]);
            ColMap["otel0"] = Util.dbchar(Request["tfr_otel0_" + i]);
            ColMap["otel"] = Util.dbchar(Request["tfr_otel_" + i]);
            ColMap["otel1"] = Util.dbchar(Request["otel1_" + i]);
            ColMap["ofax"] = Util.dbchar(Request["ofax_" + i]);
            ColMap["oapclass"] = Util.dbchar(Request["tfr_oapclass_" + i]);
            ColMap["oap_country"] = Util.dbchar(Request["tfr_oap_country_" + i]);
            ColMap["tran_code"] = "'N'";
            SQL += ColMap.GetInsertSQL();
            conn.ExecuteNonQuery(SQL);
        }

        //*****新增案件異動明細檔	
        if ((Request["tfy_arcase"] ?? "") == "FL1" || (Request["tfy_arcase"] ?? "") == "FL5") {
            for (int x = 1; x <= Convert.ToInt32("0" + Request["num2"]); x++) {
                SQL = "INSERT INTO dmt_tranlist(in_scode,in_no,mod_field,mod_type,mod_count,mod_dclass,new_no,list_remark)";
                SQL += "VALUES('" + Request["F_tscode"] + "','" + Request["in_no"] + "','mod_class'";
                SQL += "," + Util.dbchar(Request["tfl1_mod_type"]) + "," + Util.dbchar(Request["mod_count"]);
                SQL += "," + Util.dbchar(Request["mod_dclass"]) + "," + Util.dbchar(Request["new_no_" + x]);
                SQL += "," + Util.dbchar(Request["list_remark_" + x]) + ")";
                conn.ExecuteNonQuery(SQL);
            }
        } else if ((Request["tfy_arcase"] ?? "") == "FL2" || (Request["tfy_arcase"] ?? "") == "FL6") {
            for (int x = 1; x <= Convert.ToInt32("0" + Request["num2"]); x++) {
                SQL = "INSERT INTO dmt_tranlist(in_scode,in_no,mod_field,mod_type,mod_count,mod_dclass,new_no,list_remark)";
                SQL += "VALUES('" + Request["F_tscode"] + "','" + Request["in_no"] + "','mod_class'";
                SQL += "," + Util.dbchar(Request["tfl1_mod_type"]) + "," + Util.dbchar(Request["mod_count"]);
                SQL += "," + Util.dbchar(Request["mod_dclass"]) + "," + Util.dbchar(Request["new_no_" + x]);
                SQL += "," + Util.dbchar(Request["list_remark_" + x]) + ")";
                conn.ExecuteNonQuery(SQL);
            }

            for (int i = 1; i <= Convert.ToInt32("0" + Request["fl2_apnum"]); i++) {
                ColMap.Clear();
                ColMap["in_scode"] = Util.dbchar(Request["in_scode"]);
                ColMap["in_no"] = Util.dbchar(Request["in_no"]);
                ColMap["mod_field"] = "'mod_tap'";
                ColMap["new_no"] = Util.dbchar(Request["tfv_new_no_" + i]);
                ColMap["ncname1"] = Util.dbchar(Request["tfv_ncname1_" + i]);
                ColMap["ncname2"] = Util.dbchar(Request["tfv_ncname2_" + i]);
                ColMap["nename1"] = Util.dbchar(Request["tfv_nename1_" + i]);
                ColMap["nename2"] = Util.dbchar(Request["tfv_nename2_" + i]);
                ColMap["ncrep"] = Util.dbchar(Request["tfv_ncrep_" + i]);
                ColMap["nerep"] = Util.dbchar(Request["tfv_nerep_" + i]);
                ColMap["nzip"] = Util.dbchar(Request["tfv_nzip_" + i]);
                ColMap["naddr1"] = Util.dbchar(Request["tfv_naddr1_" + i]);
                ColMap["naddr2"] = Util.dbchar(Request["tfv_naddr2_" + i]);
                ColMap["neaddr1"] = Util.dbchar(Request["tfv_neaddr1_" + i]);
                ColMap["neaddr2"] = Util.dbchar(Request["tfv_neaddr2_" + i]);
                ColMap["neaddr3"] = Util.dbchar(Request["tfv_neaddr3_" + i]);
                ColMap["neaddr4"] = Util.dbchar(Request["tfv_neaddr4_" + i]);
                ColMap["ntel0"] = Util.dbchar(Request["tfv_ntel0_" + i]);
                ColMap["ntel"] = Util.dbchar(Request["tfv_ntel_" + i]);
                ColMap["ntel1"] = Util.dbchar(Request["tfv_ntel1_" + i]);
                ColMap["nfax"] = Util.dbchar(Request["tfv_nfax_" + i]);
                ColMap["napclass"] = Util.dbchar(Request["tfv_napclass_" + i]);
                ColMap["nap_country"] = Util.dbchar(Request["tfv_nap_country_" + i]);
                ColMap["tran_code"] = "'N'";

                SQL = "insert into dmt_tranlist " + ColMap.GetInsertSQL();
                conn.ExecuteNonQuery(SQL);
            }
        }

        //申請人入dmt_temp_ap_log
        Sys.insert_log_table(conn, "U", prgid, "dmt_temp_ap", "in_no;case_sqlno", Request["in_no"] + ";0", logReason);
        SQL = "delete from dmt_temp_ap where in_no='" + Request["in_no"] + "' and case_sqlno=0";
        conn.ExecuteNonQuery(SQL);

        insert_dmt_temp_ap("0");

        Sys.updmt_attach_forcase(Context, conn, prgid, (Request["in_no"] ?? ""));

        upd_grconf_job_no();
    }
    
    /// <summary>
    /// 移轉
    /// </summary>
    private void editA8() {
        //商品入log_table
        Sys.insert_log_table(conn, "U", prgid, "casedmt_good", "in_no;in_scode", Request["in_no"] + ";" + Request["in_scode"], logReason);
        SQL = "delete from casedmt_good where in_no='" + Request["in_no"] + "' and in_scode='" + Request["in_scode"] + "'";
        conn.ExecuteNonQuery(SQL);

        //dmt_tran入log_table
        Sys.insert_log_table(conn, "U", prgid, "dmt_tran", "in_no;in_scode", Request["in_no"] + ";" + Request["in_scode"], logReason);

        //dmt_tranlist入log_table
        Sys.insert_log_table(conn, "U", prgid, "dmt_tranlist", "in_no;in_scode", Request["in_no"] + ";" + Request["in_scode"], logReason);
        SQL = "delete from dmt_tranlist where in_no='" + Request["in_no"] + "' and in_scode='" + Request["in_scode"] + "'";
        conn.ExecuteNonQuery(SQL);

        update_case_dmt();

        update_dmt_temp();

        insert_casedmt_good();


        SQL = "UPDATE dmt_tran set ";
        ColMap.Clear();
        foreach (var key in Request.Form.Keys) {
            string colkey = key.ToString().ToLower();
            string colValue = Request[colkey];

            //取1~4碼
            if (colkey.Left(4) == "tfg1" || colkey.Left(4) == "tfzb") {
                ColMap[colkey.Substring(5)] = Util.dbnull(colValue);
            }
        }

        if ((Request["O_item1"] ?? "") != "" || (Request["O_item2"] ?? "") != "") {//附註
            ColMap["other_item"] = Util.dbchar(Request["O_item1"] + ";" + Request["O_item2"]);
        }

        ColMap["tr_date"] = "getdate()";
        ColMap["tr_scode"] = "'" + Session["scode"] + "'";
        SQL += ColMap.GetUpdateSQL();
        SQL += " where in_scode = '" + Request["in_scode"] + "' and in_no = '" + Request["In_no"] + "'";
        conn.ExecuteNonQuery(SQL);

        //*****新增案件異動明細檔，關係人資料
        for (int i = 1; i <= Convert.ToInt32("0" + Request["ft_apnum"]); i++) {
            SQL = "insert into dmt_tranlist ";
            ColMap.Clear();
            ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
            ColMap["in_no"] = Util.dbchar(Request["in_no"]);
            ColMap["mod_field"] = "'mod_ap'";
            ColMap["old_no"] = Util.dbchar(Request["tfr_old_no_" + i]);
            ColMap["ocname1"] = Util.dbchar(Request["tfr_ocname1_" + i]);
            ColMap["ocname2"] = Util.dbchar(Request["tfr_ocname2_" + i]);
            ColMap["oename1"] = Util.dbchar(Request["tfr_oename1_" + i]);
            ColMap["oename2"] = Util.dbchar(Request["tfr_oename2_" + i]);
            ColMap["ocrep"] = Util.dbchar(Request["tfr_ocrep_" + i]);
            ColMap["oerep"] = Util.dbchar(Request["tfr_oerep_" + i]);
            ColMap["ozip"] = Util.dbchar(Request["tfr_ozip_" + i]);
            ColMap["oaddr1"] = Util.dbchar(Request["tfr_oaddr1_" + i]);
            ColMap["oaddr2"] = Util.dbchar(Request["tfr_oaddr2_" + i]);
            ColMap["oeaddr1"] = Util.dbchar(Request["tfr_oeaddr1_" + i]);
            ColMap["oeaddr2"] = Util.dbchar(Request["tfr_oeaddr2_" + i]);
            ColMap["oeaddr3"] = Util.dbchar(Request["tfr_oeaddr3_" + i]);
            ColMap["oeaddr4"] = Util.dbchar(Request["tfr_oeaddr4_" + i]);
            ColMap["otel0"] = Util.dbchar(Request["tfr_otel0_" + i]);
            ColMap["otel"] = Util.dbchar(Request["tfr_otel_" + i]);
            ColMap["otel1"] = Util.dbchar(Request["otel1_" + i]);
            ColMap["ofax"] = Util.dbchar(Request["ofax_" + i]);
            ColMap["tran_code"] = "'N'";

            SQL += ColMap.GetInsertSQL();
            conn.ExecuteNonQuery(SQL);
        }

        //申請人入dmt_temp_ap_log
        Sys.insert_log_table(conn, "U", prgid, "dmt_temp_ap", "in_no;case_sqlno", Request["in_no"] + ";0", logReason);
        SQL = "delete from dmt_temp_ap where in_no='" + Request["in_no"] + "' and case_sqlno=0";
        conn.ExecuteNonQuery(SQL);
        insert_dmt_temp_ap("0");

        Sys.updmt_attach_forcase(Context, conn, prgid, (Request["in_no"] ?? ""));

        upd_grconf_job_no();
    }
    
    /// <summary>
    /// 質權
    /// </summary>
    private void editA9() {
        //商品入log_table
        Sys.insert_log_table(conn, "U", prgid, "casedmt_good", "in_no;in_scode", Request["in_no"] + ";" + Request["in_scode"], logReason);
        SQL = "delete from casedmt_good where in_no='" + Request["in_no"] + "' and in_scode='" + Request["in_scode"] + "'";
        conn.ExecuteNonQuery(SQL);

        //展覽優先權入log_table
        Sys.insert_log_table(conn, "U", prgid, "casedmt_show", "in_no;case_sqlno", Request["in_no"] + ";0", logReason);
        SQL = "delete from casedmt_show where in_no='" + Request["in_no"] + "' and case_sqlno=0";
        conn.ExecuteNonQuery(SQL);

        //dmt_tran入log_table
        Sys.insert_log_table(conn, "U", prgid, "dmt_tran", "in_no;in_scode", Request["in_no"] + ";" + Request["in_scode"], logReason);
        SQL = "delete from dmt_tran where in_no='" + Request["in_no"] + "' and in_scode='" + Request["in_scode"] + "'";
        conn.ExecuteNonQuery(SQL);

        //dmt_tranlist入log_table
        Sys.insert_log_table(conn, "U", prgid, "dmt_tranlist", "in_no;in_scode", Request["in_no"] + ";" + Request["in_scode"], logReason);
        SQL = "delete from dmt_tranlist where in_no='" + Request["in_no"] + "' and in_scode='" + Request["in_scode"] + "'";
        conn.ExecuteNonQuery(SQL);

        update_case_dmt();

        update_dmt_temp();

        insert_casedmt_good();

        insert_casedmt_show("0");

        string save1 = "";
        if ((Request["tfy_arcase"] ?? "") == "FP1") {
            save1 = "tfg1";//欄位開頭
        } else if ((Request["tfy_arcase"] ?? "") == "FP2") {
            save1 = "tfg2";
        }

        //***異動檔
        SQL = "insert into dmt_tran ";
        ColMap.Clear();
        foreach (var key in Request.Form.Keys) {
            string colkey = key.ToString().ToLower();
            string colValue = Request[colkey];

            //取1~4碼
            if (colkey.Left(4) == save1) {
                ColMap[colkey.Substring(5)] = Util.dbnull(colValue);
            }
        }
        ColMap["other_item"] = Util.dbchar(Request["O_item1"] + ";" + Request["O_item2"]);
        if ((Request["O_item3"] ?? "") != "") {
            ColMap["other_item1"] = Util.dbchar(Request["O_item3"] + ";" + Request["O_item4"]);
        }
        ColMap["seq"] = Util.dbnull(Request["tfzb_seq"]);
        ColMap["seq1"] = Util.dbchar(Request["tfzb_seq1"]);
        ColMap["in_scode"] = Util.dbchar(Request["in_scode"]);
        ColMap["in_no"] = Util.dbchar(Request["in_no"]);
        ColMap["tr_date"] = "getdate()";
        ColMap["tr_scode"] = "'" + Session["scode"] + "'";
        SQL += ColMap.GetInsertSQL();
        conn.ExecuteNonQuery(SQL);

        //*****新增案件異動明細檔,關係人
        for (int i = 1; i <= Convert.ToInt32("0" + Request["ft_apnum"]); i++) {
            SQL = "insert into dmt_tranlist ";
            ColMap.Clear();
            ColMap["in_scode"] = Util.dbchar(Request["in_scode"]);
            ColMap["in_no"] = Util.dbchar(Request["in_no"]);
            ColMap["mod_field"] = "'mod_ap'";
            ColMap["old_no"] = Util.dbchar(Request["tfr1_apcust_no_" + i]);
            ColMap["ocname1"] = Util.dbchar(Request["tfr1_ap_cname1_" + i]);
            ColMap["ocname2"] = Util.dbchar(Request["tfr1_ap_cname2_" + i]);
            ColMap["oename1"] = Util.dbchar(Request["tfr1_ap_ename1_" + i]);
            ColMap["oename2"] = Util.dbchar(Request["tfr1_ap_ename2_" + i]);
            ColMap["ocrep"] = Util.dbchar(Request["tfr1_ap_crep_" + i]);
            ColMap["oerep"] = Util.dbchar(Request["tfr1_ap_erep_" + i]);
            ColMap["ozip"] = Util.dbchar(Request["tfr1_ap_zip_" + i]);
            ColMap["oaddr1"] = Util.dbchar(Request["tfr1_ap_addr1_" + i]);
            ColMap["oaddr2"] = Util.dbchar(Request["tfr1_ap_addr2_" + i]);
            ColMap["oeaddr1"] = Util.dbchar(Request["tfr1_ap_eaddr1_" + i]);
            ColMap["oeaddr2"] = Util.dbchar(Request["tfr1_ap_eaddr2_" + i]);
            ColMap["oeaddr3"] = Util.dbchar(Request["tfr1_ap_eaddr3_" + i]);
            ColMap["oeaddr4"] = Util.dbchar(Request["tfr1_ap_eaddr4_" + i]);
            ColMap["otel0"] = Util.dbchar(Request["tfr1_apatt_tel0_" + i]);
            ColMap["otel"] = Util.dbchar(Request["tfr1_apatt_tel_" + i]);
            ColMap["otel1"] = Util.dbchar(Request["tfr1_apatt_tel1_" + i]);
            ColMap["ofax"] = Util.dbchar(Request["tfr1_apatt_fax_" + i]);
            ColMap["oapclass"] = Util.dbchar(Request["tfr1_oapclass_" + i]);
            ColMap["oap_country"] = Util.dbchar(Request["tfr1_oap_country_" + i]);
            ColMap["tran_code"] = "'N'";

            SQL += ColMap.GetInsertSQL();
            conn.ExecuteNonQuery(SQL);
        }

        //申請人入dmt_temp_ap_log
        Sys.insert_log_table(conn, "U", prgid, "dmt_temp_ap", "in_no;case_sqlno", Request["in_no"] + ";0", logReason);
        SQL = "delete from dmt_temp_ap where in_no='" + Request["in_no"] + "' and case_sqlno=0";
        conn.ExecuteNonQuery(SQL);
        insert_dmt_temp_ap("0");

        Sys.updmt_attach_forcase(Context, conn, prgid, (Request["in_no"] ?? ""));

        upd_grconf_job_no();
    }
    
    /// <summary>
    /// 質權
    /// </summary>
    private void editAA() {
        //商品入log_table
        Sys.insert_log_table(conn, "U", prgid, "casedmt_good", "in_no;in_scode", Request["in_no"] + ";" + Request["in_scode"], logReason);
        SQL = "delete from casedmt_good where in_no='" + Request["in_no"] + "' and in_scode='" + Request["in_scode"] + "'";
        conn.ExecuteNonQuery(SQL);

        //展覽優先權入log_table
        Sys.insert_log_table(conn, "U", prgid, "casedmt_show", "in_no;case_sqlno", Request["in_no"] + ";0", logReason);
        SQL = "delete from casedmt_show where in_no='" + Request["in_no"] + "' and case_sqlno=0";
        conn.ExecuteNonQuery(SQL);

        //dmt_tran入log_table
        Sys.insert_log_table(conn, "U", prgid, "dmt_tran", "in_no;in_scode", Request["in_no"] + ";" + Request["in_scode"], logReason);

        update_case_dmt();

        update_dmt_temp();

        insert_casedmt_good();

        insert_casedmt_show("0");


        //***異動檔
        SQL = "UPDATE dmt_tran set ";
        ColMap.Clear();
        foreach (var key in Request.Form.Keys) {
            string colkey = key.ToString().ToLower();
            string colValue = Request[colkey];

            //取2~4碼
            if (colkey.Left(4).Substring(1) == "fgd" || colkey.Left(4).Substring(1) == "fg3" || colkey.Left(4).Substring(1) == "fg2") {
                if (colkey.Left(1) == "d") {
                    ColMap[colkey.Substring(5)] = Util.dbnull(colValue);
                } else {
                    ColMap[colkey.Substring(5)] = Util.dbnull(colValue);
                }
            }
        }
        if ((Request["O_item1"] ?? "") != "" || (Request["O_item2"] ?? "") != "" || (Request["O_item21"] ?? "") != "") {//附註
            ColMap["other_item1"] = Util.dbchar(Request["O_item1"] + ";" + Request["O_item2"] + ";" + Request["O_item21"]);
        }
        if ((Request["O_item3"] ?? "") != "" || (Request["O_item31"] ?? "") != "") {//申請份數
            ColMap["other_item2"] = Util.dbchar(Request["O_item3"] + ";" + Request["O_item31"]);
        }
        if ((Request["O_item4"] ?? "") != "" || (Request["O_item41"] ?? "") != "") {//指定類別
            ColMap["other_item"] = Util.dbchar(Request["O_item4"] + ";" + Request["O_item41"]);
        }
        ColMap["tr_date"] = "getdate()";
        ColMap["tr_scode"] = "'" + Session["scode"] + "'";
        SQL += ColMap.GetUpdateSQL();
        SQL += " where in_scode = '" + Request["in_scode"] + "' and in_no = '" + Request["In_no"] + "'";
        conn.ExecuteNonQuery(SQL);

        //申請人入dmt_temp_ap_log
        Sys.insert_log_table(conn, "U", prgid, "dmt_temp_ap", "in_no;case_sqlno", Request["in_no"] + ";0", logReason);
        SQL = "delete from dmt_temp_ap where in_no='" + Request["in_no"] + "' and case_sqlno=0";
        conn.ExecuteNonQuery(SQL);
        insert_dmt_temp_ap("0");

        Sys.updmt_attach_forcase(Context, conn, prgid, (Request["in_no"] ?? ""));

        upd_grconf_job_no();
    }
    
    /// <summary>
    /// 補(換)發證
    /// </summary>
    private void editAB() {
        //商品入log_table
        Sys.insert_log_table(conn, "U", prgid, "casedmt_good", "in_no;in_scode", Request["in_no"] + ";" + Request["in_scode"], logReason);
        SQL = "delete from casedmt_good where in_no='" + Request["in_no"] + "' and in_scode='" + Request["in_scode"] + "'";
        conn.ExecuteNonQuery(SQL);

        //展覽優先權入log_table
        Sys.insert_log_table(conn, "U", prgid, "casedmt_show", "in_no;case_sqlno", Request["in_no"] + ";0", logReason);
        SQL = "delete from casedmt_show where in_no='" + Request["in_no"] + "' and case_sqlno=0";
        conn.ExecuteNonQuery(SQL);

        //dmt_tran入log_table
        Sys.insert_log_table(conn, "U", prgid, "dmt_tran", "in_no;in_scode", Request["in_no"] + ";" + Request["in_scode"], logReason);

        update_case_dmt();

        update_dmt_temp();

        insert_casedmt_good();

        insert_casedmt_show("0");

        SQL = "UPDATE dmt_tran set ";
        ColMap.Clear();
        foreach (var key in Request.Form.Keys) {
            string colkey = key.ToString().ToLower();
            string colValue = Request[colkey];

            //取1~4碼
            if (colkey.Left(4) == "tfg1") {
                ColMap[colkey.Substring(5)] = Util.dbnull(colValue);
            }
        }

        if ((Request["O_item1"] ?? "") != "" || (Request["O_item2"] ?? "") != "") {//附註
            ColMap["other_item"] = Util.dbchar(Request["O_item1"] + ";" + Request["O_item2"]);
        }
        if (ReqVal.TryGet("tfg1_mod_claim1") == "") {
            ColMap["mod_claim1"] = "'N'";
        }

        ColMap["tr_date"] = "getdate()";
        ColMap["tr_scode"] = "'" + Session["scode"] + "'";
        SQL += ColMap.GetUpdateSQL();
        SQL += " where in_scode = '" + Request["in_scode"] + "' and in_no = '" + Request["In_no"] + "'";
        conn.ExecuteNonQuery(SQL);

        //申請人入dmt_temp_ap_log
        Sys.insert_log_table(conn, "U", prgid, "dmt_temp_ap", "in_no;case_sqlno", Request["in_no"] + ";0", logReason);
        SQL = "delete from dmt_temp_ap where in_no='" + Request["in_no"] + "' and case_sqlno=0";
        conn.ExecuteNonQuery(SQL);
        insert_dmt_temp_ap("0");

        Sys.updmt_attach_forcase(Context, conn, prgid, (Request["in_no"] ?? ""));

        upd_grconf_job_no();
    }
    
    /// <summary>
    /// 閱案
    /// </summary>
    private void editAC() {
        //商品入log_table
        Sys.insert_log_table(conn, "U", prgid, "casedmt_good", "in_no;in_scode", Request["in_no"] + ";" + Request["in_scode"], logReason);
        SQL = "delete from casedmt_good where in_no='" + Request["in_no"] + "' and in_scode='" + Request["in_scode"] + "'";
        conn.ExecuteNonQuery(SQL);

        //dmt_tran入log_table
        Sys.insert_log_table(conn, "U", prgid, "dmt_tran", "in_no;in_scode", Request["in_no"] + ";" + Request["in_scode"], logReason);

        update_case_dmt();

        update_dmt_temp();

        insert_casedmt_good();


        SQL = "UPDATE dmt_tran set ";
        ColMap.Clear();
        foreach (var key in Request.Form.Keys) {
            string colkey = key.ToString().ToLower();
            string colValue = Request[colkey];

            //取2~4碼
            if (colkey.Left(4).Substring(1) == "fg1") {
                if (colkey.Left(1) == "d") {
                    ColMap[colkey.Substring(5)] = Util.dbnull(colValue);
                } else {
                    ColMap[colkey.Substring(5)] = Util.dbnull(colValue);
                }
            }
        }
        ColMap["tr_date"] = "getdate()";
        ColMap["tr_scode"] = "'" + Session["scode"] + "'";
        SQL += " where in_scode = '" + Request["in_scode"] + "' and in_no = '" + Request["In_no"] + "'";
        conn.ExecuteNonQuery(SQL);

        //申請人入dmt_temp_ap_log
        Sys.insert_log_table(conn, "U", prgid, "dmt_temp_ap", "in_no;case_sqlno", Request["in_no"] + ";0", logReason);
        SQL = "delete from dmt_temp_ap where in_no='" + Request["in_no"] + "' and case_sqlno=0";
        conn.ExecuteNonQuery(SQL);
        insert_dmt_temp_ap("0");

        Sys.updmt_attach_forcase(Context, conn, prgid, (Request["in_no"] ?? ""));

        upd_grconf_job_no();
    }
    
    /// <summary>
    /// 爭議案
    /// </summary>
    private void editB() {
        //商品入log_table
        Sys.insert_log_table(conn, "U", prgid, "casedmt_good", "in_no;in_scode", Request["in_no"] + ";" + Request["in_scode"], logReason);
        SQL = "delete from casedmt_good where in_no='" + Request["in_no"] + "' and in_scode='" + Request["in_scode"] + "'";
        conn.ExecuteNonQuery(SQL);


        //dmt_tran入log_table
        Sys.insert_log_table(conn, "U", prgid, "dmt_tran", "in_no;in_scode", Request["in_no"] + ";" + Request["in_scode"], logReason);
        SQL = "delete from dmt_tran where in_no='" + Request["in_no"] + "' and in_scode='" + Request["in_scode"] + "'";
        conn.ExecuteNonQuery(SQL);

        //dmt_tranlist入log_table
        Sys.insert_log_table(conn, "U", prgid, "dmt_tranlist", "in_no;in_scode", Request["in_no"] + ";" + Request["in_scode"], logReason);
        SQL = "delete from dmt_tranlist where in_no='" + Request["in_no"] + "' and in_scode='" + Request["in_scode"] + "'";
        conn.ExecuteNonQuery(SQL);

        update_case_dmt();

        update_dmt_temp();


        string in_scode = Request["F_tscode"] ?? "";
        if (prgid == "brt52") {
            in_scode = Request["in_scode"] ?? "";
        }
        //*****新增案件變更檔
        switch ((Request["tfy_arcase"] ?? "").Left(3)) {
            case "DR1":
                //--變換加附記使用後之商標/標章圖樣
                string DR1_mod_class_ncname1 = move_file(Request["ttg1_mod_class_ncname1"], "-C1", Request["old_file_ttg1c_1"]);
                string DR1_mod_class_ncname2 = move_file(Request["ttg1_mod_class_ncname2"], "-C2", Request["old_file_ttg1c_2"]);
                string DR1_mod_class_nename1 = move_file(Request["ttg1_mod_class_nename1"], "-C3", Request["old_file_ttg1c_3"]);
                string DR1_mod_class_nename2 = move_file(Request["ttg1_mod_class_nename2"], "-C4", Request["old_file_ttg1c_4"]);
                string DR1_mod_class_ncrep = move_file(Request["ttg1_mod_class_ncrep"], "-C5", Request["old_file_ttg1c_5"]);
                string DR1_mod_class_nerep = move_file(Request["ttg1_mod_class_nerep"], "-C6", Request["old_file_ttg1c_6"]);
                string DR1_mod_class_neaddr1 = move_file(Request["ttg1_mod_class_neaddr1"], "-C7", Request["old_file_ttg1c_7"]);
                string DR1_mod_class_neaddr2 = move_file(Request["ttg1_mod_class_neaddr2"], "-C8", Request["old_file_ttg1c_8"]);
                string DR1_mod_class_neaddr3 = move_file(Request["ttg1_mod_class_neaddr3"], "-C9", Request["old_file_ttg1c_9"]);
                string DR1_mod_class_neaddr4 = move_file(Request["ttg1_mod_class_neaddr4"], "-C10", Request["old_file_ttg1c_10"]);
                //--據以異議
                string DR1_mod_dmt_ncname1 = move_file(Request["ttg1_mod_dmt_ncname1"], "-O1", Request["old_file_ttg1_1"]);
                string DR1_mod_dmt_ncname2 = move_file(Request["ttg1_mod_dmt_ncname2"], "-O2", Request["old_file_ttg1_2"]);
                string DR1_mod_dmt_nename1 = move_file(Request["ttg1_mod_dmt_nename1"], "-O3", Request["old_file_ttg1_3"]);
                string DR1_mod_dmt_nename2 = move_file(Request["ttg1_mod_dmt_nename2"], "-O4", Request["old_file_ttg1_4"]);
                string DR1_mod_dmt_ncrep = move_file(Request["ttg1_mod_dmt_ncrep"], "-O5", Request["old_file_ttg1_5"]);
                string DR1_mod_dmt_nerep = move_file(Request["ttg1_mod_dmt_nerep"], "-O6", Request["old_file_ttg1_6"]);
                string DR1_mod_dmt_neaddr1 = move_file(Request["ttg1_mod_dmt_neaddr1"], "-O7", Request["old_file_ttg1_7"]);
                string DR1_mod_dmt_neaddr2 = move_file(Request["ttg1_mod_dmt_neaddr2"], "-O8", Request["old_file_ttg1_8"]);
                string DR1_mod_dmt_neaddr3 = move_file(Request["ttg1_mod_dmt_neaddr3"], "-O9", Request["old_file_ttg1_9"]);
                string DR1_mod_dmt_neaddr4 = move_file(Request["ttg1_mod_dmt_neaddr4"], "-O10", Request["old_file_ttg1_10"]);

                SQL = "insert into dmt_tran ";
                ColMap.Clear();
                foreach (var key in Request.Form.Keys) {
                    string colkey = key.ToString().ToLower();
                    string colValue = Request[colkey];

                    //取1~4碼
                    if (colkey.Left(4) == "tfz1") {
                        ColMap[colkey.Substring(5)] = Util.dbnull(colValue);
                    }
                }
                ColMap["seq"] = Util.dbnull(Request["tfzb_seq"]);
                ColMap["in_scode"] = Util.dbchar(in_scode);
                ColMap["in_no"] = Util.dbchar(Request["in_no"]);
                ColMap["tr_date"] = "getdate()";
                ColMap["tr_scode"] = "'" + Session["scode"] + "'";
                ColMap["seq1"] = Util.dbchar(Request["tfzb_seq1"]);
                SQL += ColMap.GetInsertSQL();
                conn.ExecuteNonQuery(SQL);

                //*****變更被申請撤銷人資料
                if (Convert.ToInt32("0" + Request["DR1_apnum"]) > 0) {
                    for (int k = 1; k <= Convert.ToInt32("0" + Request["DR1_apnum"]); k++) {
                        SQL = "insert into dmt_tranlist(in_scode,in_no,mod_field,ncname1,ncname2,ncrep,nzip,naddr1,naddr2) values (";
                        SQL += "'" + in_scode + "'," + Util.dbchar(Request["in_no"]) + ",'mod_ap'";
                        SQL += "," + Util.dbchar(Request["ttg1_mod_ap_ncname1_" + k]) + "," + Util.dbchar(Request["ttg1_mod_ap_ncname2_" + k]) + "";
                        SQL += "," + Util.dbchar(Request["ttg1_mod_ap_ncrep_" + k]) + "," + Util.dbchar(Request["ttg1_mod_ap_nzip_" + k]) + "";
                        SQL += "," + Util.dbchar(Request["ttg1_mod_ap_naddr1_" + k]) + "," + Util.dbchar(Request["ttg1_mod_ap_naddr2_" + k]) + ")";
                        conn.ExecuteNonQuery(SQL);
                    }
                    SQL = "update dmt_tran set mod_ap='Y' where in_scode='" + in_scode + "' and in_no = '" + Request["in_no"] + "'";
                    conn.ExecuteNonQuery(SQL);
                }

                //*****廢止聲明
                if ((Request["ttg11_mod_pul_new_no"] ?? "") != "" || (Request["ttg11_mod_pul_ncname1"] ?? "") != ""
                || (Request["ttg11_mod_pul_mod_type"] ?? "") != "") {
                    ColMap.Clear();
                    ColMap["in_scode"] = Util.dbchar(in_scode);
                    ColMap["in_no"] = Util.dbchar(Request["in_no"]);
                    ColMap["mod_field"] = "'mod_pul'";

                    string[] field = { "mod_type", "new_no", "ncname1" };
                    foreach (string f in field) {
                        ColMap[f] = Util.dbnull(Request["ttg11_mod_pul_" + f]);
                    }
                    SQL = "insert into dmt_tranlist " + ColMap.GetInsertSQL();
                    conn.ExecuteNonQuery(SQL);

                    SQL = "update dmt_tran set mod_pul='Y' where in_scode='" + in_scode + "' and in_no = '" + Request["in_no"] + "'";
                    conn.ExecuteNonQuery(SQL);
                }

                if ((Request["ttg12_mod_pul_mod_type"] ?? "") != "") {
                    ColMap.Clear();
                    ColMap["in_scode"] = Util.dbchar(in_scode);
                    ColMap["in_no"] = Util.dbchar(Request["in_no"]);
                    ColMap["mod_field"] = "'mod_pul'";

                    string[] field = { "mod_type" };
                    foreach (string f in field) {
                        ColMap[f] = Util.dbnull(Request["ttg12_mod_pul_" + f]);
                    }
                    SQL = "insert into dmt_tranlist " + ColMap.GetInsertSQL();
                    conn.ExecuteNonQuery(SQL);

                    SQL = "update dmt_tran set mod_pul='Y' where in_scode='" + in_scode + "' and in_no = '" + Request["in_no"] + "'";
                    conn.ExecuteNonQuery(SQL);
                }

                if ((Request["ttg13_mod_pul_new_no"] ?? "") != "" || (Request["ttg13_mod_pul_mod_dclass"] ?? "") != ""
                || (Request["ttg13_mod_pul_mod_type"] ?? "") != "") {
                    ColMap.Clear();
                    ColMap["in_scode"] = Util.dbchar(in_scode);
                    ColMap["in_no"] = Util.dbchar(Request["in_no"]);
                    ColMap["mod_field"] = "'mod_pul'";

                    string[] field = { "mod_type", "new_no", "mod_dclass" };
                    foreach (string f in field) {
                        ColMap[f] = Util.dbnull(Request["ttg13_mod_pul_" + f]);
                    }
                    SQL = "insert into dmt_tranlist " + ColMap.GetInsertSQL();
                    conn.ExecuteNonQuery(SQL);

                    SQL = "update dmt_tran set mod_pul='Y' where in_scode='" + in_scode + "' and in_no = '" + Request["in_no"] + "'";
                    conn.ExecuteNonQuery(SQL);
                }

                if ((Request["ttg14_mod_pul_new_no"] ?? "") != "" || (Request["ttg14_mod_pul_mod_dclass"] ?? "") != ""
                || (Request["ttg14_mod_pul_ncname1"] ?? "") != "" || (Request["ttg14_mod_pul_mod_type"] ?? "") != "") {
                    ColMap.Clear();
                    ColMap["in_scode"] = Util.dbchar(in_scode);
                    ColMap["in_no"] = Util.dbchar(Request["in_no"]);
                    ColMap["mod_field"] = "'mod_pul'";

                    string[] field = { "mod_type", "new_no", "mod_dclass", "ncname1" };
                    foreach (string f in field) {
                        ColMap[f] = Util.dbnull(Request["ttg14_mod_pul_" + f]);
                    }

                    SQL = "insert into dmt_tranlist " + ColMap.GetInsertSQL();
                    conn.ExecuteNonQuery(SQL);

                    SQL = "update dmt_tran set mod_pul='Y' where in_scode='" + in_scode + "' and in_no = '" + Request["in_no"] + "'";
                    conn.ExecuteNonQuery(SQL);
                }

                //據以異議商標/標章
                if ((Request["ttg1_mod_claim1_ncname1"] ?? "") != "") {
                    ColMap.Clear();
                    ColMap["in_scode"] = Util.dbchar(in_scode);
                    ColMap["in_no"] = Util.dbchar(Request["in_no"]);
                    ColMap["mod_field"] = "'mod_claim1'";

                    string[] field = { "ncname1" };
                    foreach (string f in field) {
                        ColMap[f] = Util.dbnull(Request["ttg1_mod_claim1_" + f]);
                    }
                    SQL = "insert into dmt_tranlist " + ColMap.GetInsertSQL();
                    conn.ExecuteNonQuery(SQL);

                    SQL = "update dmt_tran set mod_claim1='Y' where in_scode='" + in_scode + "' and in_no = '" + Request["in_no"] + "'";
                    conn.ExecuteNonQuery(SQL);
                }

                //變換使用商標圖樣
                if ((Request["ttg1_mod_class_ncname1"] ?? "") != "" || (Request["ttg1_mod_class_ncname2"] ?? "") != ""
                || (Request["ttg1_mod_class_nename1"] ?? "") != "" || (Request["ttg1_mod_class_nename2"] ?? "") != ""
                || (Request["ttg1_mod_class_ncrep"] ?? "") != "" || (Request["ttg1_mod_class_nerep"] ?? "") != ""
                || (Request["ttg1_mod_class_neaddr1"] ?? "") != "" || (Request["ttg1_mod_class_neaddr2"] ?? "") != ""
                || (Request["ttg1_mod_class_neaddr3"] ?? "") != "" || (Request["ttg1_mod_class_neaddr4"] ?? "") != ""
                ) {
                    SQL = "INSERT INTO dmt_tranlist(in_scode,in_no,mod_field,ncname1,ncname2,nename1,nename2,ncrep,nerep,neaddr1,neaddr2,neaddr3,neaddr4)";
                    SQL += "VALUES('" + in_scode + "'," + Util.dbchar(Request["in_no"]) + ",'mod_class'";
                    SQL += "," + Util.dbnull(Sys.Path2Btbrt(DR1_mod_class_ncname1)) + "," + Util.dbnull(Sys.Path2Btbrt(DR1_mod_class_ncname2));
                    SQL += "," + Util.dbnull(Sys.Path2Btbrt(DR1_mod_class_nename1)) + "," + Util.dbnull(Sys.Path2Btbrt(DR1_mod_class_nename2));
                    SQL += "," + Util.dbnull(Sys.Path2Btbrt(DR1_mod_class_ncrep)) + "," + Util.dbnull(Sys.Path2Btbrt(DR1_mod_class_nerep));
                    SQL += "," + Util.dbnull(Sys.Path2Btbrt(DR1_mod_class_neaddr1)) + "," + Util.dbnull(Sys.Path2Btbrt(DR1_mod_class_neaddr2));
                    SQL += "," + Util.dbnull(Sys.Path2Btbrt(DR1_mod_class_neaddr3)) + "," + Util.dbnull(Sys.Path2Btbrt(DR1_mod_class_neaddr4)) + ")";
                    conn.ExecuteNonQuery(SQL);

                    SQL = "update dmt_tran set mod_class='Y' where in_scode='" + in_scode + "' and in_no = '" + Request["in_no"] + "'";
                    conn.ExecuteNonQuery(SQL);
                }

                //變換撤銷商標圖樣
                if ((Request["ttg1_mod_dmt_ncname1"] ?? "") != "" || (Request["ttg1_mod_dmt_ncname2"] ?? "") != ""
                || (Request["ttg1_mod_dmt_nename1"] ?? "") != "" || (Request["ttg1_mod_dmt_nename2"] ?? "") != ""
                || (Request["ttg1_mod_dmt_ncrep"] ?? "") != "" || (Request["ttg1_mod_dmt_nerep"] ?? "") != ""
                || (Request["ttg1_mod_dmt_neaddr1"] ?? "") != "" || (Request["ttg1_mod_dmt_neaddr2"] ?? "") != ""
                || (Request["ttg1_mod_dmt_neaddr3"] ?? "") != "" || (Request["ttg1_mod_dmt_neaddr4"] ?? "") != ""
                ) {
                    SQL = "INSERT INTO dmt_tranlist(in_scode,in_no,mod_field,ncname1,ncname2,nename1,nename2,ncrep,nerep,neaddr1,neaddr2,neaddr3,neaddr4)";
                    SQL += "VALUES('" + in_scode + "'," + Util.dbchar(Request["in_no"]) + ",'mod_dmt'";
                    SQL += "," + Util.dbnull(Sys.Path2Btbrt(DR1_mod_dmt_ncname1)) + "," + Util.dbnull(Sys.Path2Btbrt(DR1_mod_dmt_ncname2));
                    SQL += "," + Util.dbnull(Sys.Path2Btbrt(DR1_mod_dmt_nename1)) + "," + Util.dbnull(Sys.Path2Btbrt(DR1_mod_dmt_nename2));
                    SQL += "," + Util.dbnull(Sys.Path2Btbrt(DR1_mod_dmt_ncrep)) + "," + Util.dbnull(Sys.Path2Btbrt(DR1_mod_dmt_nerep));
                    SQL += "," + Util.dbnull(Sys.Path2Btbrt(DR1_mod_dmt_neaddr1)) + "," + Util.dbnull(Sys.Path2Btbrt(DR1_mod_dmt_neaddr2));
                    SQL += "," + Util.dbnull(Sys.Path2Btbrt(DR1_mod_dmt_neaddr3)) + "," + Util.dbnull(Sys.Path2Btbrt(DR1_mod_dmt_neaddr4)) + ")";
                    conn.ExecuteNonQuery(SQL);

                    SQL = "update dmt_tran set mod_dmt='Y' where in_scode='" + in_scode + "' and in_no = '" + Request["in_no"] + "'";
                    conn.ExecuteNonQuery(SQL);
                }

                break;
            case "DO1":
                string DO1_mod_dmt_ncname1 = move_file(Request["ttg2_mod_dmt_ncname1"], "-O1", Request["old_file_ttg2_1"]);
                string DO1_mod_dmt_ncname2 = move_file(Request["ttg2_mod_dmt_ncname2"], "-O2", Request["old_file_ttg2_2"]);
                string DO1_mod_dmt_nename1 = move_file(Request["ttg2_mod_dmt_nename1"], "-O3", Request["old_file_ttg2_3"]);
                string DO1_mod_dmt_nename2 = move_file(Request["ttg2_mod_dmt_nename2"], "-O4", Request["old_file_ttg2_4"]);
                string DO1_mod_dmt_ncrep = move_file(Request["ttg2_mod_dmt_ncrep"], "-O5", Request["old_file_ttg2_5"]);
                string DO1_mod_dmt_nerep = move_file(Request["ttg2_mod_dmt_nerep"], "-O6", Request["old_file_ttg2_6"]);
                string DO1_mod_dmt_neaddr1 = move_file(Request["ttg2_mod_dmt_neaddr1"], "-O7", Request["old_file_ttg2_7"]);
                string DO1_mod_dmt_neaddr2 = move_file(Request["ttg2_mod_dmt_neaddr2"], "-O8", Request["old_file_ttg2_8"]);
                string DO1_mod_dmt_neaddr3 = move_file(Request["ttg2_mod_dmt_neaddr3"], "-O9", Request["old_file_ttg2_9"]);
                string DO1_mod_dmt_neaddr4 = move_file(Request["ttg2_mod_dmt_neaddr4"], "-O10", Request["old_file_ttg2_10"]);

                ColMap.Clear();
                foreach (var key in Request.Form.Keys) {
                    string colkey = key.ToString().ToLower();
                    string colValue = Request[colkey];

                    //取1~4碼
                    if (colkey.Left(4) == "tfz2") {
                        ColMap[colkey.Substring(5)] = Util.dbnull(colValue);
                    }
                }
                ColMap["seq"] = Util.dbnull(Request["tfzb_seq"]);
                ColMap["in_scode"] = Util.dbchar(in_scode);
                ColMap["in_no"] = Util.dbchar(Request["in_no"]);
                ColMap["tr_date"] = "getdate()";
                ColMap["tr_scode"] = "'" + Session["scode"] + "'";
                ColMap["seq1"] = Util.dbchar(Request["tfzb_seq1"]);
                SQL = "insert into dmt_tran " + ColMap.GetInsertSQL();
                conn.ExecuteNonQuery(SQL);

                //*****變更被申請撤銷人資料
                if (Convert.ToInt32("0" + Request["DO1_apnum"]) > 0) {
                    for (int k = 1; k <= Convert.ToInt32("0" + Request["DO1_apnum"]); k++) {
                        SQL = "insert into dmt_tranlist(in_scode,in_no,mod_field,ncname1,ncname2,ncrep,nzip,naddr1,naddr2) values (";
                        SQL += "'" + in_scode + "'," + Util.dbchar(Request["in_no"]) + ",'mod_ap'";
                        SQL += "," + Util.dbchar(Request["ttg2_mod_ap_ncname1_" + k]) + "," + Util.dbchar(Request["ttg2_mod_ap_ncname2_" + k]) + "";
                        SQL += "," + Util.dbchar(Request["ttg2_mod_ap_ncrep_" + k]) + "," + Util.dbchar(Request["ttg2_mod_ap_nzip_" + k]) + "";
                        SQL += "," + Util.dbchar(Request["ttg2_mod_ap_naddr1_" + k]) + "," + Util.dbchar(Request["ttg2_mod_ap_naddr2_" + k]) + ")";
                        conn.ExecuteNonQuery(SQL);
                    }
                    SQL = "update dmt_tran set mod_ap='Y' where in_scode='" + in_scode + "' and in_no = '" + Request["in_no"] + "'";
                    conn.ExecuteNonQuery(SQL);
                }

                //*****廢止聲明
                if ((Request["ttg21_mod_pul_new_no"] ?? "") != "" || (Request["ttg21_mod_pul_ncname1"] ?? "") != ""
                || (Request["ttg21_mod_pul_mod_type"] ?? "") != "") {
                    ColMap.Clear();
                    ColMap["in_scode"] = Util.dbchar(in_scode);
                    ColMap["in_no"] = Util.dbchar(Request["in_no"]);
                    ColMap["mod_field"] = "'mod_pul'";

                    string[] field = { "mod_type", "new_no", "ncname1" };
                    foreach (string f in field) {
                        ColMap[f] = Util.dbnull(Request["ttg21_mod_pul_" + f]);
                    }
                    SQL = "insert into dmt_tranlist " + ColMap.GetInsertSQL();
                    conn.ExecuteNonQuery(SQL);

                    SQL = "update dmt_tran set mod_pul='Y' where in_scode='" + in_scode + "' and in_no = '" + Request["in_no"] + "'";
                    conn.ExecuteNonQuery(SQL);
                }

                if ((Request["ttg22_mod_pul_mod_type"] ?? "") != "") {
                    ColMap.Clear();
                    ColMap["in_scode"] = Util.dbchar(in_scode);
                    ColMap["in_no"] = Util.dbchar(Request["in_no"]);
                    ColMap["mod_field"] = "'mod_pul'";

                    string[] field = { "mod_type" };
                    foreach (string f in field) {
                        ColMap[f] = Util.dbnull(Request["ttg22_mod_pul_" + f]);
                    }
                    SQL = "insert into dmt_tranlist " + ColMap.GetInsertSQL();
                    conn.ExecuteNonQuery(SQL);

                    SQL = "update dmt_tran set mod_pul='Y' where in_scode='" + in_scode + "' and in_no = '" + Request["in_no"] + "'";
                    conn.ExecuteNonQuery(SQL);
                }

                if ((Request["ttg23_mod_pul_new_no"] ?? "") != "" || (Request["ttg23_mod_pul_mod_dclass"] ?? "") != ""
                || (Request["ttg23_mod_pul_mod_type"] ?? "") != "") {
                    ColMap.Clear();
                    ColMap["in_scode"] = Util.dbchar(in_scode);
                    ColMap["in_no"] = Util.dbchar(Request["in_no"]);
                    ColMap["mod_field"] = "'mod_pul'";

                    string[] field = { "mod_type", "new_no", "mod_dclass" };
                    foreach (string f in field) {
                        ColMap[f] = Util.dbnull(Request["ttg23_mod_pul_" + f]);
                    }

                    SQL = "insert into dmt_tranlist " + ColMap.GetInsertSQL();
                    conn.ExecuteNonQuery(SQL);

                    SQL = "update dmt_tran set mod_pul='Y' where in_scode='" + in_scode + "' and in_no = '" + Request["in_no"] + "'";
                    conn.ExecuteNonQuery(SQL);
                }

                if ((Request["ttg24_mod_pul_new_no"] ?? "") != "" || (Request["ttg24_mod_pul_mod_dclass"] ?? "") != ""
                || (Request["ttg24_mod_pul_ncname1"] ?? "") != "" || (Request["ttg24_mod_pul_mod_type"] ?? "") != "") {
                    ColMap.Clear();
                    ColMap["in_scode"] = Util.dbchar(in_scode);
                    ColMap["in_no"] = Util.dbchar(Request["in_no"]);
                    ColMap["mod_field"] = "'mod_pul'";

                    string[] field = { "mod_type", "new_no", "mod_dclass", "ncname1" };
                    foreach (string f in field) {
                        ColMap[f] = Util.dbnull(Request["ttg24_mod_pul_" + f]);
                    }

                    SQL = "insert into dmt_tranlist " + ColMap.GetInsertSQL();
                    conn.ExecuteNonQuery(SQL);

                    SQL = "update dmt_tran set mod_pul='Y' where in_scode='" + in_scode + "' and in_no = '" + Request["in_no"] + "'";
                    conn.ExecuteNonQuery(SQL);
                }

                //據以異議商標/標章
                if (Convert.ToInt32("0" + Request["ttg2_mod_aprep_mod_count"]) > 0) {
                    for (int i = 1; i <= Convert.ToInt32("0" + Request["ttg2_mod_aprep_mod_count"]); i++) {
                        SQL = "insert into dmt_tranlist(in_scode,in_no,mod_field,mod_count,ncname1,new_no) values (";
                        SQL += "'" + in_scode + "','" + Request["in_no"] + "','mod_aprep'";
                        SQL += "," + Util.dbnull(Request["ttg2_mod_aprep_mod_count"]) + "," + Util.dbchar(Request["ttg2_mod_aprep_ncname1_" + i]) + "";
                        SQL += "," + Util.dbchar(Request["ttg2_mod_aprep_new_no_" + i]) + ")";
                        conn.ExecuteNonQuery(SQL);
                    }
                    SQL = "update dmt_tran set mod_aprep='Y' where in_scode='" + in_scode + "' and in_no = '" + Request["in_no"] + "'";
                    conn.ExecuteNonQuery(SQL);
                }

                //變換撤銷商標圖樣
                if ((Request["ttg2_mod_dmt_ncname1"] ?? "") != "" || (Request["ttg2_mod_dmt_ncname2"] ?? "") != ""
                || (Request["ttg2_mod_dmt_nename1"] ?? "") != "" || (Request["ttg2_mod_dmt_nename2"] ?? "") != ""
                || (Request["ttg2_mod_dmt_ncrep"] ?? "") != "" || (Request["ttg2_mod_dmt_nerep"] ?? "") != ""
                || (Request["ttg2_mod_dmt_neaddr1"] ?? "") != "" || (Request["ttg2_mod_dmt_neaddr2"] ?? "") != ""
                || (Request["ttg2_mod_dmt_neaddr3"] ?? "") != "" || (Request["ttg2_mod_dmt_neaddr4"] ?? "") != ""
                ) {
                    SQL = "INSERT INTO dmt_tranlist(in_scode,in_no,mod_field,ncname1,ncname2,nename1,nename2,ncrep,nerep,neaddr1,neaddr2,neaddr3,neaddr4)";
                    SQL += "VALUES('" + in_scode + "'," + Util.dbchar(Request["in_no"]) + ",'mod_dmt'";
                    SQL += "," + Util.dbnull(Sys.Path2Btbrt(DO1_mod_dmt_ncname1)) + "," + Util.dbnull(Sys.Path2Btbrt(DO1_mod_dmt_ncname2));
                    SQL += "," + Util.dbnull(Sys.Path2Btbrt(DO1_mod_dmt_nename1)) + "," + Util.dbnull(Sys.Path2Btbrt(DO1_mod_dmt_nename2));
                    SQL += "," + Util.dbnull(Sys.Path2Btbrt(DO1_mod_dmt_ncrep)) + "," + Util.dbnull(Sys.Path2Btbrt(DO1_mod_dmt_nerep));
                    SQL += "," + Util.dbnull(Sys.Path2Btbrt(DO1_mod_dmt_neaddr1)) + "," + Util.dbnull(Sys.Path2Btbrt(DO1_mod_dmt_neaddr2));
                    SQL += "," + Util.dbnull(Sys.Path2Btbrt(DO1_mod_dmt_neaddr3)) + "," + Util.dbnull(Sys.Path2Btbrt(DO1_mod_dmt_neaddr4)) + ")";
                    conn.ExecuteNonQuery(SQL);

                    SQL = "update dmt_tran set mod_dmt='Y' where in_scode='" + in_scode + "' and in_no = '" + Request["in_no"] + "'";
                    conn.ExecuteNonQuery(SQL);
                }

                break;
            case "DI1":
                string DI1_mod_dmt_ncname1 = move_file(Request["ttg3_mod_dmt_ncname1"], "-O1", Request["old_file_ttg3_1"]);
                string DI1_mod_dmt_ncname2 = move_file(Request["ttg3_mod_dmt_ncname2"], "-O2", Request["old_file_ttg3_2"]);
                string DI1_mod_dmt_nename1 = move_file(Request["ttg3_mod_dmt_nename1"], "-O3", Request["old_file_ttg3_3"]);
                string DI1_mod_dmt_nename2 = move_file(Request["ttg3_mod_dmt_nename2"], "-O4", Request["old_file_ttg3_4"]);
                string DI1_mod_dmt_ncrep = move_file(Request["ttg3_mod_dmt_ncrep"], "-O5", Request["old_file_ttg3_5"]);
                string DI1_mod_dmt_nerep = move_file(Request["ttg3_mod_dmt_nerep"], "-O6", Request["old_file_ttg3_6"]);
                string DI1_mod_dmt_neaddr1 = move_file(Request["ttg3_mod_dmt_neaddr1"], "-O7", Request["old_file_ttg3_7"]);
                string DI1_mod_dmt_neaddr2 = move_file(Request["ttg3_mod_dmt_neaddr2"], "-O8", Request["old_file_ttg3_8"]);
                string DI1_mod_dmt_neaddr3 = move_file(Request["ttg3_mod_dmt_neaddr3"], "-O9", Request["old_file_ttg3_9"]);
                string DI1_mod_dmt_neaddr4 = move_file(Request["ttg3_mod_dmt_neaddr4"], "-O10", Request["old_file_ttg3_10"]);

                ColMap.Clear();
                foreach (var key in Request.Form.Keys) {
                    string colkey = key.ToString().ToLower();
                    string colValue = Request[colkey];

                    //取1~4碼
                    if (colkey.Left(4) == "tfz3") {
                        ColMap[colkey.Substring(5)] = Util.dbnull(colValue);
                    }
                }
                ColMap["seq"] = Util.dbnull(Request["tfzb_seq"]);
                ColMap["in_scode"] = Util.dbchar(in_scode);
                ColMap["in_no"] = Util.dbchar(Request["in_no"]);
                ColMap["tr_date"] = "getdate()";
                ColMap["tr_scode"] = "'" + Session["scode"] + "'";
                ColMap["seq1"] = Util.dbchar(Request["tfzb_seq1"]);
                SQL = "insert into dmt_tran " + ColMap.GetInsertSQL();
                conn.ExecuteNonQuery(SQL);

                //*****變更被申請撤銷人資料
                if (Convert.ToInt32("0" + Request["DI1_apnum"]) > 0) {
                    for (int k = 1; k <= Convert.ToInt32("0" + Request["DI1_apnum"]); k++) {
                        SQL = "insert into dmt_tranlist(in_scode,in_no,mod_field,ncname1,ncname2,ncrep,nzip,naddr1,naddr2) values (";
                        SQL += "'" + in_scode + "'," + Util.dbchar(Request["in_no"]) + ",'mod_ap'";
                        SQL += "," + Util.dbchar(Request["ttg3_mod_ap_ncname1_" + k]) + "," + Util.dbchar(Request["ttg3_mod_ap_ncname2_" + k]) + "";
                        SQL += "," + Util.dbchar(Request["ttg3_mod_ap_ncrep_" + k]) + "," + Util.dbchar(Request["ttg3_mod_ap_nzip_" + k]) + "";
                        SQL += "," + Util.dbchar(Request["ttg3_mod_ap_naddr1_" + k]) + "," + Util.dbchar(Request["ttg3_mod_ap_naddr2_" + k]) + ")";
                        conn.ExecuteNonQuery(SQL);
                    }
                    SQL = "update dmt_tran set mod_ap='Y' where in_scode='" + in_scode + "' and in_no = '" + Request["in_no"] + "'";
                    conn.ExecuteNonQuery(SQL);
                }

                //*****廢止聲明
                if ((Request["ttg31_mod_pul_new_no"] ?? "") != "" || (Request["ttg31_mod_pul_ncname1"] ?? "") != ""
                || (Request["ttg31_mod_pul_mod_type"] ?? "") != "") {
                    ColMap.Clear();
                    ColMap["in_scode"] = Util.dbchar(in_scode);
                    ColMap["in_no"] = Util.dbchar(Request["in_no"]);
                    ColMap["mod_field"] = "'mod_pul'";

                    string[] field = { "mod_type", "new_no", "ncname1" };
                    foreach (string f in field) {
                        ColMap[f] = Util.dbnull(Request["ttg31_mod_pul_" + f]);
                    }

                    SQL = "insert into dmt_tranlist " + ColMap.GetInsertSQL();
                    conn.ExecuteNonQuery(SQL);

                    SQL = "update dmt_tran set mod_pul='Y' where in_scode='" + in_scode + "' and in_no = '" + Request["in_no"] + "'";
                    conn.ExecuteNonQuery(SQL);
                }

                if ((Request["ttg32_mod_pul_mod_type"] ?? "") != "") {
                    ColMap.Clear();
                    ColMap["in_scode"] = Util.dbchar(in_scode);
                    ColMap["in_no"] = Util.dbchar(Request["in_no"]);
                    ColMap["mod_field"] = "'mod_pul'";

                    string[] field = { "mod_type" };
                    foreach (string f in field) {
                        ColMap[f] = Util.dbnull(Request["ttg32_mod_pul_" + f]);
                    }
                    SQL = "insert into dmt_tranlist " + ColMap.GetInsertSQL();
                    conn.ExecuteNonQuery(SQL);

                    SQL = "update dmt_tran set mod_pul='Y' where in_scode='" + in_scode + "' and in_no = '" + Request["in_no"] + "'";
                    conn.ExecuteNonQuery(SQL);
                }

                if ((Request["ttg33_mod_pul_new_no"] ?? "") != "" || (Request["ttg33_mod_pul_mod_dclass"] ?? "") != ""
                || (Request["ttg33_mod_pul_mod_type"] ?? "") != "") {
                    ColMap.Clear();
                    ColMap["in_scode"] = Util.dbchar(in_scode);
                    ColMap["in_no"] = Util.dbchar(Request["in_no"]);
                    ColMap["mod_field"] = "'mod_pul'";

                    string[] field = { "mod_type", "new_no", "mod_dclass" };
                    foreach (string f in field) {
                        ColMap[f] = Util.dbnull(Request["ttg33_mod_pul_" + f]);
                    }

                    SQL = "insert into dmt_tranlist " + ColMap.GetInsertSQL();
                    conn.ExecuteNonQuery(SQL);

                    SQL = "update dmt_tran set mod_pul='Y' where in_scode='" + in_scode + "' and in_no = '" + Request["in_no"] + "'";
                    conn.ExecuteNonQuery(SQL);
                }

                if ((Request["ttg34_mod_pul_new_no"] ?? "") != "" || (Request["ttg34_mod_pul_mod_dclass"] ?? "") != ""
                || (Request["ttg34_mod_pul_ncname1"] ?? "") != "" || (Request["ttg34_mod_pul_mod_type"] ?? "") != "") {
                    ColMap.Clear();
                    ColMap["in_scode"] = Util.dbchar(in_scode);
                    ColMap["in_no"] = Util.dbchar(Request["in_no"]);
                    ColMap["mod_field"] = "'mod_pul'";

                    string[] field = { "mod_type", "new_no", "mod_dclass", "ncname1" };
                    foreach (string f in field) {
                        ColMap[f] = Util.dbnull(Request["ttg34_mod_pul_" + f]);
                    }

                    SQL = "insert into dmt_tranlist " + ColMap.GetInsertSQL();
                    conn.ExecuteNonQuery(SQL);

                    SQL = "update dmt_tran set mod_pul='Y' where in_scode='" + in_scode + "' and in_no = '" + Request["in_no"] + "'";
                    conn.ExecuteNonQuery(SQL);
                }

                //據以異議商標/標章
                if (Convert.ToInt32("0" + Request["ttg3_mod_aprep_mod_count"]) > 0) {
                    for (int i = 1; i <= Convert.ToInt32("0" + Request["ttg3_mod_aprep_mod_count"]); i++) {
                        SQL = "insert into dmt_tranlist(in_scode,in_no,mod_field,mod_count,ncname1,new_no) values (";
                        SQL += "'" + in_scode + "'," + Util.dbchar(Request["in_no"]) + ",'mod_aprep'";
                        SQL += "," + Util.dbnull(Request["ttg3_mod_aprep_mod_count"]) + "," + Util.dbchar(Request["ttg3_mod_aprep_ncname1_" + i]) + "";
                        SQL += "," + Util.dbchar(Request["ttg3_mod_aprep_new_no_" + i]) + ")";
                        conn.ExecuteNonQuery(SQL);
                    }
                    SQL = "update dmt_tran set mod_aprep='Y' where in_scode='" + in_scode + "' and in_no = '" + Request["in_no"] + "'";
                    conn.ExecuteNonQuery(SQL);
                }

                //變換撤銷商標圖樣
                if ((Request["ttg3_mod_dmt_ncname1"] ?? "") != "" || (Request["ttg3_mod_dmt_ncname2"] ?? "") != ""
                || (Request["ttg3_mod_dmt_nename1"] ?? "") != "" || (Request["ttg3_mod_dmt_nename2"] ?? "") != ""
                || (Request["ttg3_mod_dmt_ncrep"] ?? "") != "" || (Request["ttg3_mod_dmt_nerep"] ?? "") != ""
                || (Request["ttg3_mod_dmt_neaddr1"] ?? "") != "" || (Request["ttg3_mod_dmt_neaddr2"] ?? "") != ""
                || (Request["ttg3_mod_dmt_neaddr3"] ?? "") != "" || (Request["ttg3_mod_dmt_neaddr4"] ?? "") != ""
                ) {
                    SQL = "INSERT INTO dmt_tranlist(in_scode,in_no,mod_field,ncname1,ncname2,nename1,nename2,ncrep,nerep,neaddr1,neaddr2,neaddr3,neaddr4)";
                    SQL += "VALUES('" + in_scode + "'," + Util.dbchar(Request["in_no"]) + ",'mod_dmt'";
                    SQL += "," + Util.dbnull(Sys.Path2Btbrt(DI1_mod_dmt_ncname1)) + "," + Util.dbnull(Sys.Path2Btbrt(DI1_mod_dmt_ncname2));
                    SQL += "," + Util.dbnull(Sys.Path2Btbrt(DI1_mod_dmt_nename1)) + "," + Util.dbnull(Sys.Path2Btbrt(DI1_mod_dmt_nename2));
                    SQL += "," + Util.dbnull(Sys.Path2Btbrt(DI1_mod_dmt_ncrep)) + "," + Util.dbnull(Sys.Path2Btbrt(DI1_mod_dmt_nerep));
                    SQL += "," + Util.dbnull(Sys.Path2Btbrt(DI1_mod_dmt_neaddr1)) + "," + Util.dbnull(Sys.Path2Btbrt(DI1_mod_dmt_neaddr2));
                    SQL += "," + Util.dbnull(Sys.Path2Btbrt(DI1_mod_dmt_neaddr3)) + "," + Util.dbnull(Sys.Path2Btbrt(DI1_mod_dmt_neaddr4)) + ")";
                    conn.ExecuteNonQuery(SQL);

                    SQL = "update dmt_tran set mod_dmt='Y' where in_scode='" + in_scode + "' and in_no = '" + Request["in_no"] + "'";
                    conn.ExecuteNonQuery(SQL);
                }

                break;
            default:

                insert_casedmt_good();

                if ((Request["tfy_arcase"] ?? "").Left(3) == "DE1") {
                    SQL = "INSERT INTO dmt_tran(in_scode,in_no,other_item,other_item1,other_item2,tran_remark1,tran_mark,tr_date,tr_scode,seq,seq1)";
                    SQL += " values ('" + Request["F_tscode"] + "'," + Util.dbchar(Request["in_no"]) + "," + Util.dbchar(Request["fr4_other_item"]) + "";
                    SQL += "," + Util.dbchar(Request["fr4_other_item1"]) + "," + Util.dbchar(Request["fr4_other_item2"]) + "";
                    SQL += "," + Util.dbchar(Request["fr4_tran_remark1"]) + "," + Util.dbchar(Request["fr4_tran_mark"]) + "";
                    SQL += ",getdate(),'" + Session["scode"] + "',";
                    SQL += Util.dbnull(Request["tfzb_seq"]) + "," + Util.dbchar(Request["tfzb_seq1"]) + ")";
                    conn.ExecuteNonQuery(SQL);
                    //新增對照當事人資料
                    for (int k = 1; k <= Convert.ToInt32("0" + Request["de1_apnum"]); k++) {
                        SQL = "insert into dmt_tranlist(in_scode,in_no,mod_field,ncname1,naddr1) values (";
                        SQL += "'" + Request["F_tscode"] + "'," + Util.dbchar(Request["in_no"]) + ",'mod_client'";
                        SQL += "," + Util.dbchar(Request["tfr4_ncname1_" + k]) + "," + Util.dbchar(Request["tfr4_naddr1_" + k]) + ")";
                        conn.ExecuteNonQuery(SQL);
                    }
                } else if ((Request["tfy_arcase"] ?? "").Left(3) == "DE2") {
                    SQL = "INSERT INTO dmt_tran(in_scode,in_no,other_item,other_item1,other_item2,tran_remark1,tr_date,tr_scode,seq,seq1)";
                    SQL += " values ('" + Request["F_tscode"] + "'," + Util.dbchar(Request["in_no"]) + "," + Util.dbchar(Request["fr4_other_item"]) + ",";
                    SQL += "" + Util.dbchar(Request["fr4_other_item1"]) + "," + Util.dbchar(Request["fr4_other_item2"]) + ",";
                    SQL += "" + Util.dbchar(Request["fr4_tran_remark1"]) + ",getdate(),'" + Session["scode"] + "',";
                    SQL += Util.dbnull(Request["tfzb_seq"]) + "," + Util.dbchar(Request["tfzb_seq1"]) + ")";
                    conn.ExecuteNonQuery(SQL);
                } else {
                    SQL = "INSERT INTO dmt_tran(in_scode,in_no,tran_remark1,tr_date,tr_scode,seq,seq1,agt_no1)";
                    SQL += " values ('" + Request["F_tscode"] + "'," + Util.dbchar(Request["in_no"]) + "," + Util.dbchar(Request["tfg1_tran_remark1"]) + "";
                    SQL += ",getdate(),'" + Session["scode"] + "',";
                    SQL += Util.dbnull(Request["tfzb_seq"]) + "," + Util.dbchar(Request["tfzb_seq1"]) + "," + Util.dbnull(Request["tfg1_agt_no1"]) + ")";
                    conn.ExecuteNonQuery(SQL);
                }

                break;
        }

        //申請人入dmt_temp_ap_log
        Sys.insert_log_table(conn, "U", prgid, "dmt_temp_ap", "in_no;case_sqlno", Request["in_no"] + ";0", logReason);
        SQL = "delete from dmt_temp_ap where in_no='" + Request["in_no"] + "' and case_sqlno=0";
        conn.ExecuteNonQuery(SQL);
        insert_dmt_temp_ap("0");

        Sys.updmt_attach_forcase(Context, conn, prgid, (Request["in_no"] ?? ""));

        upd_grconf_job_no();
    }
    
    /// <summary>
    /// 其他
    /// </summary>
    private void editZZ() {
        //商品入log_table
        Sys.insert_log_table(conn, "U", prgid, "casedmt_good", "in_no;in_scode", Request["in_no"] + ";" + Request["in_scode"], logReason);
        SQL = "delete from casedmt_good where in_no='" + Request["in_no"] + "' and in_scode='" + Request["in_scode"] + "'";
        conn.ExecuteNonQuery(SQL);

        //展覽優先權入log_table
        Sys.insert_log_table(conn, "U", prgid, "casedmt_show", "in_no;case_sqlno", Request["in_no"] + ";0", logReason);
        SQL = "delete from casedmt_show where in_no='" + Request["in_no"] + "' and case_sqlno=0";
        conn.ExecuteNonQuery(SQL);

        //dmt_tran入log_table
        Sys.insert_log_table(conn, "U", prgid, "dmt_tran", "in_no;in_scode", Request["in_no"] + ";" + Request["in_scode"], logReason);

        //dmt_tranlist入log_table
        Sys.insert_log_table(conn, "U", prgid, "dmt_tranlist", "in_no;in_scode", Request["in_no"] + ";" + Request["in_scode"], logReason);
        SQL = "delete from dmt_tranlist where in_no='" + Request["in_no"] + "' and in_scode='" + Request["in_scode"] + "'";
        conn.ExecuteNonQuery(SQL);

        update_case_dmt();

        update_dmt_temp();

        insert_casedmt_good();

        insert_casedmt_show("0");

        if ((Request["tfy_arcase"] ?? "").Left(3) == "AD7") {
            ColMap.Clear();
            ColMap["other_item"] = Util.dbchar(Request["fr4_other_item"]);
            ColMap["other_item1"] = Util.dbchar(Request["fr4_other_item1"]);
            ColMap["other_item2"] = Util.dbchar(Request["fr4_other_item2"]);
            ColMap["tran_remark1"] = Util.dbchar(Request["fr4_tran_remark1"]);
            ColMap["tran_mark"] = Util.dbchar(Request["fr4_tran_mark"]);
            ColMap["tr_date"] = "getdate()";
            ColMap["tr_scode"] = "'" + Session["scode"] + "'";
            ColMap["seq"] = Util.dbnull(Request["tfzb_seq"]);
            ColMap["seq1"] = Util.dbchar(Request["tfzb_seq1"]);
            ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
            SQL = "UPDATE dmt_tran set " + ColMap.GetUpdateSQL();
            SQL += " where in_scode = '" + Request["in_scode"] + "' and in_no = '" + Request["In_no"] + "'";
            conn.ExecuteNonQuery(SQL);

            //新增對照當事人資料
            for (int k = 1; k <= Convert.ToInt32("0" + Request["de1_apnum"]); k++) {
                SQL = "insert into dmt_tranlist(in_scode,in_no,mod_field,ncname1,naddr1) values (";
                SQL += "'" + Request["in_scode"] + "'," + Util.dbchar(Request["in_no"]) + ",'mod_client'";
                SQL += "," + Util.dbchar(Request["tfr4_ncname1_" + k]);
                SQL += "," + Util.dbchar(Request["tfr4_naddr1_" + k]) + ")";
                conn.ExecuteNonQuery(SQL);
            }
        } else if ((Request["tfy_arcase"] ?? "").Left(3) == "AD8") {
            ColMap.Clear();
            ColMap["other_item"] = Util.dbchar(Request["fr4_other_item"]);
            ColMap["other_item1"] = Util.dbchar(Request["fr4_other_item1"]);
            ColMap["other_item2"] = Util.dbchar(Request["fr4_other_item2"]);
            ColMap["tran_remark1"] = Util.dbchar(Request["fr4_tran_remark1"]);
            ColMap["tr_date"] = "getdate()";
            ColMap["tr_scode"] = "'" + Session["scode"] + "'";
            ColMap["seq"] = Util.dbnull(Request["tfzb_seq"]);
            ColMap["seq1"] = Util.dbchar(Request["tfzb_seq1"]);
            ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
            SQL = "UPDATE dmt_tran set " + ColMap.GetUpdateSQL();
            SQL += " where in_scode = '" + Request["in_scode"] + "' and in_no = '" + Request["In_no"] + "'";
            conn.ExecuteNonQuery(SQL);
        } else if ((Request["tfy_arcase"] ?? "").Left(3) == "FOF") {
            ColMap.Clear();
            ColMap["other_item"] = Util.dbchar(Request["tfzf_other_item"]);
            ColMap["debit_money"] = Util.dbchar(Request["tfzf_debit_money"]);
            ColMap["other_item1"] = Util.dbchar(Request["tfzf_other_item1"]);
            ColMap["other_item2"] = Util.dbchar(Request["tfzf_other_item2"]);
            ColMap["tr_date"] = "getdate()";
            ColMap["tr_scode"] = "'" + Session["scode"] + "'";
            ColMap["seq"] = Util.dbnull(Request["tfzb_seq"]);
            ColMap["seq1"] = Util.dbchar(Request["tfzb_seq1"]);
            ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
            SQL = "UPDATE dmt_tran set " + ColMap.GetUpdateSQL();
            SQL += " where in_scode = '" + Request["in_scode"] + "' and in_no = '" + Request["In_no"] + "'";
            conn.ExecuteNonQuery(SQL);
        } else if ((Request["tfy_arcase"] ?? "").Left(3) == "FB7") {
            ColMap.Clear();
            ColMap["agt_no1"] = Util.dbchar(Request["tfb7_agt_no1"]);
            ColMap["other_item"] = Util.dbchar(Request["tfb7_other_item"]);
            ColMap["tr_date"] = "getdate()";
            ColMap["tr_scode"] = "'" + Session["scode"] + "'";
            ColMap["seq"] = Util.dbnull(Request["tfzb_seq"]);
            ColMap["seq1"] = Util.dbchar(Request["tfzb_seq1"]);
            ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
            SQL = "UPDATE dmt_tran set " + ColMap.GetUpdateSQL();
            SQL += " where in_scode = '" + Request["in_scode"] + "' and in_no = '" + Request["In_no"] + "'";
            conn.ExecuteNonQuery(SQL);
        } else if ((Request["tfy_arcase"] ?? "").Left(3) == "FW1") {
            ColMap.Clear();
            ColMap["agt_no1"] = Util.dbchar(Request["tfg1_agt_no1"]);
            ColMap["mod_claim1"] = Util.dbchar(Request["tfw1_mod_claim1"]);
            ColMap["tran_remark1"] = Util.dbchar(Request["tfw1_tran_remark1"]);
            ColMap["other_item"] = Util.dbchar(Request["tfw1_other_item"]);
            ColMap["tr_date"] = "getdate()";
            ColMap["tr_scode"] = "'" + Session["scode"] + "'";
            ColMap["seq"] = Util.dbnull(Request["tfzb_seq"]);
            ColMap["seq1"] = Util.dbchar(Request["tfzb_seq1"]);
            ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
            SQL = "UPDATE dmt_tran set " + ColMap.GetUpdateSQL();
            SQL += " where in_scode = '" + Request["in_scode"] + "' and in_no = '" + Request["In_no"] + "'";
            conn.ExecuteNonQuery(SQL);
        } else {
            ColMap.Clear();
            foreach (var key in Request.Form.Keys) {
                string colkey = key.ToString().ToLower();
                string colValue = Request[colkey];

                //取2~4碼
                if (colkey.Left(4).Substring(1) == "fg1") {
                    ColMap[colkey.Substring(5)] = Util.dbnull(colValue);
                }
            }

            ColMap["tr_date"] = "getdate()";
            ColMap["tr_scode"] = "'" + Session["scode"] + "'";
            ColMap["seq"] = Util.dbnull(Request["tfzb_seq"]);
            ColMap["seq1"] = Util.dbchar(Request["tfzb_seq1"]);
            ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
            SQL = "UPDATE dmt_tran set " + ColMap.GetUpdateSQL();
            SQL += " where in_scode = '" + Request["in_scode"] + "' and in_no = '" + Request["In_no"] + "'";
            conn.ExecuteNonQuery(SQL);
        }

        if ((Request["tfg1_other_item"] ?? "") != "") {
            for (int i = 2; i <= 11; i++) {
                if ((Request["ttz1_P" + i] ?? "") != "") {
                    SQL = "INSERT INTO dmt_tranlist(in_scode,in_no,mod_field,mod_type,mod_dclass,new_no) values (";
                    SQL += " '" + Request["F_tscode"] + "'," + Util.dbchar(Request["in_no"]) + ",'other_item'," + Util.dbchar(Request["ttz1_P" + i]) + "";
                    SQL += "," + Util.dbchar(Request["P" + i + "_mod_dclass"]) + "," + Util.dbchar(Request["P" + i + "_new_no"]) + ")";
                    conn.ExecuteNonQuery(SQL);
                }
            }
        }

        //申請人入dmt_temp_ap_log
        Sys.insert_log_table(conn, "U", prgid, "dmt_temp_ap", "in_no;case_sqlno", Request["in_no"] + ";0", logReason);
        SQL = "delete from dmt_temp_ap where in_no='" + Request["in_no"] + "' and case_sqlno=0";
        conn.ExecuteNonQuery(SQL);
        insert_dmt_temp_ap("0");

        Sys.updmt_attach_forcase(Context, conn, prgid, (Request["in_no"] ?? ""));

        upd_grconf_job_no();
    }
</script>

<%Response.Write(strOut.ToString());%>
