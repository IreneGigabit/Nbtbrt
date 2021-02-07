<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Collections.Generic"%>

<script runat="server">
    protected string HTProgCap = HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "brt52";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";
    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";
    protected string formFunction = "";

    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected Dictionary<string, string> ColMap = new Dictionary<string, string>();

    
    protected string SQL = "";

    protected StringBuilder strOut = new StringBuilder();

    protected string logReason = "brt52國內案交辦資料維護作業";

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
                //conn.Commit();
                conn.RollBack();
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

    private void intcasetran_brt() {
        //---insert casetrand_brt
        SQL = "select isnull(max(sqlno),0) from case_dmt_log where in_no=" + ReqVal.TryGet("in_no").Trim()+ " and in_scode='" + Request["in_scode"] + "'";
        string maxsqlno_case_dmt_log = (conn.ExecuteScalar(SQL) ?? "").ToString();

        SQL = "select arcase_class from case_dmt where in_no=" + ReqVal.TryGet("in_no").Trim() + " and in_scode='" + Request["in_scode"] + "'";
        string case_dmt_arcase_class = (conn.ExecuteScalar(SQL) ?? "").ToString();

        //****主委辦案性
        ColMap.Clear();
        SQL = "insert into casetran_brt ";
        ColMap["input_scode"] = Util.dbnull(Sys.GetSession("scode"));
        ColMap["input_date"] = "getdate()";
        ColMap["in_scode"] = Util.dbnull(Request["in_scode"]);
        ColMap["in_no"] = Util.dbnull(Request["in_no"]);
        ColMap["case_no"] = Util.dbnull(Request["tcase_no"]);
        ColMap["seq"] = Util.dbnull(Request["tseq"]);
        ColMap["seq1"] = Util.dbnull(Request["tseq1"]);
        ColMap["country"] = "'T'";
        ColMap["cust_area"] = Util.dbnull(Request["F_cust_area"]);
        ColMap["cust_seq"] = Util.dbnull(Request["F_cust_seq"]);
        ColMap["att_sql"] = Util.dbnull(Request["tfy_att_sql"]);
        ColMap["ap_seq"] = "1";
        ColMap["arcase_type"] = Util.dbnull(Request["code_type"]);
        ColMap["arcase_class"] = Util.dbnull(case_dmt_arcase_class);
        ColMap["arcase"] = Util.dbnull(Request["tfy_arcase"]);
        ColMap["tot_case"] = Util.dbnull(Request["nfy_tot_case"]);
        ColMap["tot_service"] = Util.dbnull(Request["nfy_service"]);
        ColMap["tot_fees"] = Util.dbnull(Request["nfy_fees"]);
        ColMap["oth_arcase"] = Util.dbnull(Request["tfy_oth_arcase"]);
        ColMap["tr_dept"] = Util.dbnull(Request["tfy_oth_code"]);
        ColMap["oth_money"] = Util.dbnull(Request["nfy_oth_money"]);
        ColMap["ar_service"] = Util.dbnull(Request["xar_service"]);
        ColMap["ar_fees"] = Util.dbnull(Request["xar_fees"]);
        ColMap["discount"] = Util.dbnull(Request["nfy_Discount"]);
        ColMap["discount_chk"] = Util.dbnull(Request["tfy_discount_chk"]);
        ColMap["contract_no"] = Util.dbnull(Request["tfy_Contract_no"]);
        ColMap["case_status"] = "'C'";
        ColMap["tran_class"] = "'CY'";
        ColMap["tran_remark"] = "'brt52國內案交辦資料維護作業'";
        ColMap["tran_status"] = "'CZ'";
        ColMap["source_ap"] = "'brt52'";
        ColMap["case_sqlno"] = Util.dbnull(maxsqlno_case_dmt_log);
        ColMap["tran_scode"] = Util.dbnull(Sys.GetSession("scode"));
        ColMap["tran_date"] = "getdate()";
        SQL += ColMap.GetInsertSQL();
        conn.ExecuteNonQuery(SQL);

        //抓insert後的流水號
        SQL = "SELECT SCOPE_IDENTITY() AS Current_Identity";
        string maxtrancase_sqlno_log = (conn.ExecuteScalar(SQL) ?? "").ToString();

        SQL = "UPDATE case_dmt set trancase_sqlno='" + maxtrancase_sqlno_log + "'";
        SQL += " where in_scode = '" + Request["in_scode"] + "' and in_no = '" + ReqVal.TryGet("in_no").Trim() + "'";
        conn.ExecuteNonQuery(SQL);

        if (Request["update_dmt"] == "dmt") {
            SQL = "select max(sqlno) from dmt_log where seq = '" + Request["tseq"] + "' and seq1 = '" + Request["tseq1"] + "'";
            string maxsqlno_dmt_log = (conn.ExecuteScalar(SQL) ?? "").ToString();

            SQL = "update dmt_log set trancase_sqlno='" + maxtrancase_sqlno_log + "'";
            SQL += " where seq = '" + Request["tseq"] + "' and seq1 = '" + Request["tseq1"] + "' and sqlno='" + maxsqlno_dmt_log + "'";
            conn.ExecuteNonQuery(SQL);
        }
    }

    private void int_casetrand_brt(string pcor_table, string pcor_item, string pcor_field, string pcor_content, ref int ixi) {
        SQL = "select max(sqlno) from casetran_brt where case_no = '" + Request["tcase_no"] + "'";
        string tran_sqlno = (conn.ExecuteScalar(SQL) ?? "").ToString();

        //****主委辦案性
        ColMap.Clear();
        SQL = "insert into casetrand_brt ";
        ColMap["tran_sqlno"] = Util.dbnull(tran_sqlno);
        ColMap["pr_step"] = "'01'";
        ColMap["pr_meth"] = "'update'";
        ColMap["item_seq"] = Util.dbzero(ixi.ToString());
        ColMap["cor_table"] = Util.dbnull(pcor_table);
        ColMap["cor_item"] = Util.dbnull(pcor_item);
        ColMap["cor_field"] = Util.dbnull(pcor_field);
        ColMap["cor_content"] = Util.dbnull(pcor_content);
        SQL += ColMap.GetInsertSQL();
        conn.ExecuteNonQuery(SQL);

        ixi += 1;
    }

    private void doUpdateDB() {
        Sys sfile = new Sys();
        sfile.getFileServer(Sys.GetSession("SeBranch"), prgid);//檔案上傳相關設定

        int ixi = 0;
        string intflg = "N";

        if (ReqVal.TryGet("in_scode") != ReqVal.TryGet("F_tscode")
            || ReqVal.TryGet("osource") != ReqVal.TryGet("tfy_source")
            || ReqVal.TryGet("ocontract_no") != ReqVal.TryGet("tfy_contract_no")
            || ReqVal.TryGet("o_cust_area") != ReqVal.TryGet("F_cust_area")
            || ReqVal.TryGet("o_cust_seq") != ReqVal.TryGet("F_cust_seq")
            || ReqVal.TryGet("oatt_sql") != ReqVal.TryGet("tfy_att_sql")
            ) {
                Sys.insert_log_table(conn, "U", prgid, "case_dmt", "in_scode;in_no", Request["in_scode"] + ";" + Request["in_no"], logReason);
                Sys.insert_log_table(conn, "U", prgid, "caseitem_dmt", "in_scode;in_no", Request["in_scode"] + ";" + Request["in_no"], logReason);
                Sys.insert_log_table(conn, "U", prgid, "dmt_temp", "in_no;in_scode", Request["in_no"] + ";" + Request["in_scode"], logReason);
            if (ReqVal.TryGet("update_dmt") == "dmt") {
                Sys.insert_log_table(conn, "U", prgid, "dmt", "seq;seq1", Request["tseq"] + ";" + Request["tseq1"], logReason);
                Sys.insert_log_table(conn, "U", prgid, "ndmt", "seq;seq1", Request["tseq"] + ";" + Request["tseq1"], logReason);
            }
            intcasetran_brt();
            intflg = "Y";
        }

        if (ReqVal.TryGet("tseq1") != "M" && intflg == "N" && ReqVal.TryGet("xar_curr") == "0") {
            if (ReqVal.TryGet("tfy_ar_code") != ReqVal.TryGet("ochkar_code")) {
                Sys.insert_log_table(conn, "U", prgid, "case_dmt", "in_scode;in_no", Request["in_scode"] + ";" + Request["in_no"], logReason);
                Sys.insert_log_table(conn, "U", prgid, "caseitem_dmt", "in_scode;in_no", Request["in_scode"] + ";" + Request["in_no"], logReason);
                Sys.insert_log_table(conn, "U", prgid, "dmt_temp", "in_no;in_scode", Request["in_no"] + ";" + Request["in_scode"], logReason);
                if (ReqVal.TryGet("update_dmt") == "dmt") {
                    Sys.insert_log_table(conn, "U", prgid, "dmt", "seq;seq1", Request["tseq"] + ";" + Request["tseq1"], logReason);
                    Sys.insert_log_table(conn, "U", prgid, "ndmt", "seq;seq1", Request["tseq"] + ";" + Request["tseq1"], logReason);
                }
                intcasetran_brt();
                intflg = "Y";
            }
        }

        if (ReqVal.TryGet("in_scode") != ReqVal.TryGet("F_tscode")) int_casetrand_brt("case_dmt", "I21", "scode", ReqVal.TryGet("F_tscode"), ref ixi);
        if (ReqVal.TryGet("ocontract_no") != ReqVal.TryGet("tfy_contract_no")) int_casetrand_brt("case_dmt", "I27", "contract_no", ReqVal.TryGet("tfy_contract_no"), ref ixi);
        if (ReqVal.TryGet("osource") != ReqVal.TryGet("tfy_source")) int_casetrand_brt("case_dmt", "I28", "source", ReqVal.TryGet("tfy_source"), ref ixi);
        if (ReqVal.TryGet("tseq1") != "M" && ReqVal.TryGet("xar_curr") == "0") {
            if (ReqVal.TryGet("tfy_ar_code") != ReqVal.TryGet("ochkar_code")) int_casetrand_brt("case_dmt", "I29", "ar_code", ReqVal.TryGet("tfy_ar_code"), ref ixi);
        }
        if (ReqVal.TryGet("o_cust_seq") != ReqVal.TryGet("F_cust_seq")) int_casetrand_brt("case_dmt", "I31", "cust_seq", ReqVal.TryGet("F_cust_seq"), ref ixi);
        if (ReqVal.TryGet("oatt_sql") != ReqVal.TryGet("tfy_att_sql")) int_casetrand_brt("case_dmt", "I34", "att_sql", ReqVal.TryGet("tfy_att_sql"), ref ixi);

        //申請人異動入檔
        string inttran_flag = "N";
        SQL = "select count(1) from dmt_temp_ap where in_no=" + ReqVal.TryGet("in_no").Trim() + " and case_sqlno='0'";
        int rs_apnum = Convert.ToInt32(conn.ExecuteScalar(SQL) ?? "0");
        if (rs_apnum > 0) {
            //當案件temp的申請人和輸入的申請人不同筆數時，要入casetran
            if (Convert.ToInt32("0" + Request["apnum"]) != rs_apnum) {
                if (intflg == "N") {
                    intcasetran_brt();
                    intflg = "Y";
                }
                for (int i = 1; i <= Convert.ToInt32("0" + Request["apnum"]); i++) {
                    //筆數不同入，要入casetrand
                    int_casetrand_brt("dmt_temp", "I37", "apcust_no", ReqVal.TryGet("Apcust_no_" + i), ref ixi);
                }
                inttran_flag = "Y";
            }
        }

        if (inttran_flag == "N") {
            for (int i = 1; i <= Convert.ToInt32("0" + Request["apnum"]); i++) {
                //當案件temp的申請人和輸入的申請人號碼不同時，要入casetran
                if (ReqVal.TryGet("o_apcust_no_" + i) != ReqVal.TryGet("Apcust_no_" + i)) {
                    if (intflg == "N") {
                        intcasetran_brt();
                        intflg = "Y";
                    }
                    int_casetrand_brt("dmt_temp", "I37", "apcust_no", ReqVal.TryGet("Apcust_no_" + i), ref ixi);
                }
            }
            inttran_flag = "Y";
        }

        //商品入log_table
        Sys.insert_log_table(conn, "U", prgid, "casedmt_good", "in_no;in_scode", Request["in_no"] + ";" + Request["in_scode"], logReason);
        SQL = "delete from casedmt_good where in_no='" + Request["in_no"] + "' and in_scode='" + Request["in_scode"] + "'";
        conn.ExecuteNonQuery(SQL);

        //展覽優先權入log_table
        Sys.insert_log_table(conn, "U", prgid, "casedmt_show", "in_no;case_sqlno", Request["in_no"] + ";0", logReason);
        SQL = "delete from casedmt_show where in_no='" + Request["in_no"] + "' and case_sqlno=0";
        conn.ExecuteNonQuery(SQL);

        if (ReqVal.TryGet("update_dmt") == "dmt") {
            //商品入log_table
            Sys.insert_log_table(conn, "U", prgid, "dmt_good", "seq;seq1", Request["tfzb_seq"] + ";" + Request["tfzb_seq1"], logReason);
            SQL = "delete from dmt_good where seq='" + Request["tfz1_seq"] + "' and seq1='" + Request["tfz1_seq1"] + "'";
            conn.ExecuteNonQuery(SQL);

            //展覽優先權入log_table
            Sys.insert_log_table(conn, "U", prgid, "dmt_show", "seq;seq1", Request["tfzb_seq"] + ";" + Request["tfzb_seq1"], logReason);
            SQL = "delete from dmt_show where seq='" + Request["tfz1_seq"] + "' and seq1='" + Request["tfz1_seq1"] + "'";
            conn.ExecuteNonQuery(SQL);
        }
        
        if (intflg == "N") {
            //入case_dmt_log
            Sys.insert_log_table(conn, "U", prgid, "case_dmt", "in_scode;in_no", Request["in_scode"] + ";" + Request["in_no"], logReason);
        }
        SQL = "UPDATE case_dmt SET ";
        ColMap.Clear();
        if (ReqVal.TryGet("F_tscode").Trim() != "") ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
        if (ReqVal.TryGet("tfy_source").Trim() != "") ColMap["source"] = Util.dbchar(Request["tfy_source"]);
        if (ReqVal.TryGet("tfy_contract_type").Trim() != "") ColMap["contract_type"] = Util.dbchar(Request["tfy_contract_type"]);
        if (ReqVal.TryGet("tfy_contract_no").Trim() != "") ColMap["contract_no"] = Util.dbchar(Request["tfy_contract_no"]);
        if (ReqVal.TryGet("dfy_cust_date").Trim() != "") ColMap["cust_date"] = Util.dbchar(Request["dfy_cust_date"]);
        if (ReqVal.TryGet("dfy_pr_date").Trim() != "") ColMap["pr_date"] = Util.dbchar(Request["dfy_pr_date"]);
        if (ReqVal.TryGet("tfy_remark").Trim() != "") ColMap["remark"] = Util.dbnull(Request["tfy_remark"]);
        if (ReqVal.TryGet("tfy_att_sql").Trim() != "") ColMap["att_sql"] = Util.dbchar(Request["tfy_att_sql"]);
        if (ReqVal.TryGet("tfy_cust_area").Trim() != "") ColMap["cust_area"] = Util.dbchar(Request["tfy_cust_area"]);
        if (ReqVal.TryGet("tfy_cust_seq").Trim() != "") ColMap["cust_seq"] = Util.dbchar(Request["tfy_cust_seq"]);
        SQL += ColMap.GetUpdateSQL();
        SQL += " where in_scode = '" + Request["in_scode"] + "' and in_no = '" + ReqVal.TryGet("In_no").Trim() + "'";
        conn.ExecuteNonQuery(SQL);

        if (intflg == "N") {
            //入dmt_temp_log 
            Sys.insert_log_table(conn, "U", prgid, "dmt_temp", "in_no;in_scode", Request["in_no"] + ";" + Request["in_scode"], logReason);
        }
        string aa = Request["draw_file1"] ?? "";
        SQL = "UPDATE dmt_temp SET ";
        ColMap.Clear();
        foreach (var key in Request.Form.Keys) {
            string colkey = key.ToString().ToLower();
            string colValue = Request[colkey];

            //取2~5碼(直接用substr若欄位名稱太短會壞掉)
            if (colkey.Left(5).Substring(1) == "fz1_") {
                if (colkey.Left(1) == "d") {
                    ColMap[colkey.Substring(5)] = Util.dbnull(colValue);
                } else if (colkey.Left(1) == "n") {
                    ColMap[colkey.Substring(5)] = Util.dbzero(colValue);
                } else {
                    ColMap[colkey.Substring(5)] = Util.dbnull(colValue);
                }
            }
        }
        ColMap["draw_file"] = Util.dbchar(Sys.Path2Btbrt(aa));
        ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
        ColMap["tr_date"] = "getdate()";
        ColMap["tr_scode"] = "'" + Session["scode"] + "'";
        SQL += ColMap.GetUpdateSQL();
        SQL += " where in_scode = '" + Request["in_scode"] + "' and in_no = '" + Request["In_no"] + "'";
        conn.ExecuteNonQuery(SQL);

        //****商品類別
        for (int i = 1; i <= Convert.ToInt32("0" + Request["num1"]); i++) {
            if ((Request["class1_" + i] ?? "") != "") {
                SQL = "insert into casedmt_good ";
                ColMap.Clear();
                ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
                ColMap["in_no"] = Util.dbchar(Request["In_no"]);
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

        //****新增展覽優先權資料
        for (int i = 1; i <= Convert.ToInt32("0" + Request["shownum"]); i++) {
            if ((Request["show_date_" + i] ?? "") != "" || (Request["show_name_" + i] ?? "") != "") {
                SQL = "insert into casedmt_show ";
                ColMap.Clear();
                ColMap["in_no"] = Util.dbchar(Request["In_no"]);
                ColMap["case_sqlno"] = "0";
                ColMap["show_date"] = Util.dbnull(Request["show_date_" + i]);
                ColMap["show_name"] = Util.dbnull(Request["show_name_" + i]);
                ColMap["tr_date"] = "getdate()";
                ColMap["tr_scode"] = "'" + Session["scode"] + "'";
                SQL += ColMap.GetInsertSQL();
                conn.ExecuteNonQuery(SQL);
            }
        }

        //申請人入log_table
        Sys.insert_log_table(conn, "U", prgid, "dmt_temp_ap", "in_no;case_sqlno", Request["in_no"] + ";0", logReason);
        SQL = "Delete dmt_temp_ap where in_no='" + Request["in_no"] + "' and case_sqlno=0";
        conn.ExecuteNonQuery(SQL);

        //交辦申請人
        for (int i = 1; i <= Convert.ToInt32("0" + Request["apnum"]); i++) {
            SQL = "insert into dmt_temp_ap ";
            ColMap.Clear();
            ColMap["in_no"] = Util.dbchar(Request["In_no"]);
            ColMap["case_sqlno"] = "0";
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

        //*****文件上傳
        Sys.updmt_attach_forcase(Context, conn, prgid, (Request["in_no"] ?? ""));

        if (Request["update_dmt"] == "dmt") {
            //國內商標案件主檔dmt
            if (intflg == "N") {
                //dmt入log檔
                Sys.insert_log_table(conn, "U", prgid, "dmt", "seq;seq1", Request["tfz1_seq"] + ";" + Request["tfz1_seq1"], logReason);
            }

            SQL = "UPDATE dmt SET ";
            ColMap.Clear();
            ColMap["cust_prod"] = Util.dbnull(Request["tfz1_cust_prod"]);
            ColMap["s_mark2"] = Util.dbnull(Request["tfz1_s_mark2"]);
            ColMap["class"] = Util.dbnull(Request["tfz1_class"]);
            ColMap["class_count"] = Util.dbnull(Request["tfz1_class_count"]);
            ColMap["appl_name"] = Util.dbnull(Request["tfz1_Appl_name"]);
            ColMap["cust_area"] = Util.dbnull(Request["tfy_cust_area"]);
            ColMap["cust_seq"] = Util.dbnull(Request["tfy_cust_seq"]);
            ColMap["att_sql"] = Util.dbnull(Request["tfy_att_sql"]);
            ColMap["agt_no"] = Util.dbnull(Request["tfz1_agt_no"]);
            ColMap["scode"] = Util.dbnull(Request["F_tscode"]);
            ColMap["prior_date"] = Util.dbnull(Request["pfz1_prior_date"]);
            ColMap["prior_no"] = Util.dbnull(Request["tfz1_prior_no"]);
            ColMap["prior_country"] = Util.dbnull(Request["tfz1_prior_country"]);
            SQL += ColMap.GetUpdateSQL();
            SQL += " where seq = '" + Request["tfz1_seq"] + "' and seq1 = '" + Request["tfz1_seq1"] + "'";
            conn.ExecuteNonQuery(SQL);

            //國內商標案件主檔ndmt
            if (intflg == "N") {
                Sys.insert_log_table(conn, "U", prgid, "ndmt", "seq;seq1", Request["tfz1_seq"] + ";" + Request["tfz1_seq1"], logReason);
            }
            SQL = "UPDATE ndmt SET ";
            ColMap.Clear();
            ColMap["cappl_name"] = Util.dbnull(Request["tfz1_Cappl_name"]);
            ColMap["Eappl_name"] = Util.dbnull(Request["tfz1_Eappl_name"]);
            ColMap["eappl_name1"] = Util.dbnull(Request["tfz1_Eappl_name1"]);
            ColMap["eappl_name2"] = Util.dbnull(Request["tfz1_Eappl_name2"]);
            ColMap["jappl_name"] = Util.dbnull(Request["tfz1_jappl_name"]);
            ColMap["jappl_name1"] = Util.dbnull(Request["tfz1_jappl_name1"]);
            ColMap["jappl_name2"] = Util.dbnull(Request["tfz1_jappl_name2"]);
            ColMap["zappl_name1"] = Util.dbnull(Request["tfz1_zappl_name1"]);
            ColMap["zappl_name2"] = Util.dbnull(Request["tfz1_zappl_name2"]);
            ColMap["zname_type"] = Util.dbnull(Request["tfz1_Zname_type"]);
            ColMap["oappl_name"] = Util.dbnull(Request["tfz1_Oappl_name"]);
            ColMap["draw"] = Util.dbnull(Request["tfz1_Draw"]);
            ColMap["draw_file"] = Util.dbchar(Sys.Path2Btbrt(aa));
            ColMap["symbol"] = Util.dbnull(Request["tfz1_Symbol"]);
            ColMap["color"] = Util.dbnull(Request["tfz1_color"]);
            ColMap["in_no"] = Util.dbnull(Request["in_no"]);
            ColMap["in_scode"] = Util.dbnull(Request["F_tscode"]);
            ColMap["tran_date"] = "getdate()";
            ColMap["tran_scode"] = "'" + Session["scode"] + "'";
            ColMap["mark"] = Util.dbnull(Request["mark"]);
            SQL += ColMap.GetUpdateSQL();
            SQL += " where seq = '" + Request["tfz1_seq"] + "' and seq1 = '" + Request["tfz1_seq1"] + "'";
            conn.ExecuteNonQuery(SQL);

            for (int i = 1; i <= Convert.ToInt32("0" + Request["num1"]); i++) {
                if ((Request["class1_" + i] ?? "") != "") {
                    SQL = "insert into dmt_good ";
                    ColMap.Clear();
                    ColMap["seq"] = Util.dbchar(Request["tfz1_seq"]);
                    ColMap["seq1"] = Util.dbchar(Request["tfz1_seq1"]);
                    ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
                    ColMap["in_no"] = Util.dbchar(Request["In_no"]);
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

            //****新增展覽優先權資料
            for (int i = 1; i <= Convert.ToInt32("0" + Request["shownum"]); i++) {
                if ((Request["show_date_" + i] ?? "") != "" || (Request["show_name_" + i] ?? "") != "") {
                    SQL = "insert into dmt_show ";
                    ColMap.Clear();
                    ColMap["seq"] = Util.dbchar(Request["tfz1_seq"]);
                    ColMap["seq1"] = Util.dbchar(Request["tfz1_seq1"]);
                    ColMap["show_date"] = Util.dbnull(Request["show_date_" + i]);
                    ColMap["show_name"] = Util.dbnull(Request["show_name_" + i]);
                    ColMap["tr_date"] = "getdate()";
                    ColMap["tr_scode"] = "'" + Session["scode"] + "'";
                    SQL += ColMap.GetInsertSQL();
                    conn.ExecuteNonQuery(SQL);
                }
            }

            //案件主檔申請人log_table
            Sys.insert_log_table(conn, "U", prgid, "dmt_ap", "seq;seq1;branch", Request["tfz1_seq"] + ";" + Request["tfz1_seq1"] + ";" + Session["seBranch"], logReason);
            SQL = "Delete dmt_ap where seq='" + Request["tfz1_seq"] + "' and seq1='" + Request["tfz1_seq1"] + "' and branch='" + Session["seBranch"] + "'";
            conn.ExecuteNonQuery(SQL);
            for (int i = 1; i <= Convert.ToInt32("0" + Request["apnum"]); i++) {
                SQL = "insert into dmt_ap ";
                ColMap.Clear();
                ColMap["branch"] = Util.dbchar(Sys.GetSession("seBranch"));
                ColMap["seq"] = Util.dbchar(Request["tfz1_seq"]);
                ColMap["seq1"] = Util.dbchar(Request["tfz1_seq1"]);
                ColMap["apsqlno"] = Util.dbchar(Request["apsqlno_" + i]);
                ColMap["Server_flag"] = Util.dbchar(Request["ap_server_flag_" + i]);
                ColMap["apcust_no"] = Util.dbchar(Request["apcust_no_" + i]);
                ColMap["ap_cname"] = Util.dbchar(Request["ap_cname_" + i]);
                ColMap["ap_ename"] = Util.dbchar(Request["ap_ename_" + i]);
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

        //修改洽案營洽資料要update的table(case_dmt,dmt_temp,caseitem_dmt,dmt_tran,dmt_tranlist,ndmt)
        if (ReqVal.TryGet("in_scode") != ReqVal.TryGet("F_tscode")) {
            SQL = "update caseitem_dmt set in_scode='" + ReqVal.TryGet("F_tscode").Trim() + "' where in_no='" + ReqVal.TryGet("in_no") + "'";
            conn.ExecuteNonQuery(SQL);
        }

        //記錄log
        string note = "";
        if (ReqVal.TryGet("update_dmt") == "dmt") {
            note = "修改洽案資料_" + ReqVal.TryGet("in_scode").Trim() + "-" + ReqVal.TryGet("in_no").Trim() + ";本所編號:" + Request["tfz1_seq"] + "-" + Request["tfz1_seq1"] + ";";
            //共同申請人
            for (int i = 1; i <= Convert.ToInt32("0" + Request["apnum"]); i++) {
                if (ReqVal.TryGet("o_apcust_no_" + i) != ReqVal.TryGet("Apcust_no_" + i)) {
                    note += "原申請人Oapcust_no" + i + "::" + ReqVal.TryGet("o_apcust_no_" + i).Trim() + ";";
                }
            }
        } else {
            note = "修改洽案資料_" + ReqVal.TryGet("in_scode").Trim() + "-" + ReqVal.TryGet("in_no").Trim() + ";";
            //共同申請人
            for (int i = 1; i <= Convert.ToInt32("0" + Request["apnum"]); i++) {
                if (ReqVal.TryGet("o_apcust_no_" + i) != ReqVal.TryGet("Apcust_no_" + i)) {
                    note += "原申請人Oapcust_no" + i + ":" + ReqVal.TryGet("o_apcust_no_" + i).Trim() + ";";
                }
            }
        }
        SQL = " insert into rec_log(tableid,prgid,in_no,";
        if (ReqVal.TryGet("O_cust_seq") != ReqVal.TryGet("tfy_cust_seq")) {
            SQL += "Ocust_area,Ocust_seq,";
        }
        if (ReqVal.TryGet("in_scode") != ReqVal.TryGet("F_tscode")) {
            SQL += "Oscode,";
        }
        SQL += "scode,tran_date,note) values('case_dmt|dmt_temp|casedmt_good|dmt|ndmt|dmt_good','Brt52','" + ReqVal.TryGet("in_no").Trim() + "',";
        if (ReqVal.TryGet("O_cust_seq") != ReqVal.TryGet("tfy_cust_seq")) {
            SQL += "'" + Request["O_cust_area"] + "','" + Request["O_cust_seq"] + "',";
        }
        if (ReqVal.TryGet("in_scode") != ReqVal.TryGet("F_tscode")) {
            SQL += "'" + ReqVal.TryGet("in_scode").Trim() + "',";
        }
        SQL += "'" + Session["scode"] + "',getdate(),'" + note + "')";
        conn.ExecuteNonQuery(SQL);
        
    }
</script>

<%Response.Write(strOut.ToString());%>
