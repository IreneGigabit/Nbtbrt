<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Data.SqlClient"%>

<script runat="server">
    protected string HTProgCap = HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "brt52";//程式檔名前綴
    protected string HTProgCode = "brt52";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";
    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";
    protected string formFunction = "";
    protected string drawFilename = "";

    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected Dictionary<string, string> ColMap = new Dictionary<string, string>();

    DBHelper conn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    DBHelper connm = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    private void Page_Unload(System.Object sender, System.EventArgs e) {
        if (conn != null) conn.Dispose();
        if (connm != null) connm.Dispose();
    }

    protected string SQL = "";
    Sys sfile = new Sys();
    protected int ixi = 0;
    protected string intflg = "N";
    protected string inttran_flag = "N";
    protected string lapnum = "", field_ap = "", ofield_ap = "";//申請人欄位
    protected int subX=1;//子案入檔從第N筆開始

    protected StringBuilder strOut = new StringBuilder();

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
        connm = new DBHelper(Conn.MG).Debug(Request["chkTest"] == "TEST");

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
        try {
            string in_no = (Request["in_no"] ?? "");
            //申請人欄位
            if ((Request["tfy_arcase"] ?? "").IN("FC1,FC10,FC11,FC5,FC7,FC9,FCA,FCB,FCF,FCH")) {
                lapnum = "0" + Request["fc2_apnum"];
                field_ap = "dbmn1_new_no_";
                ofield_ap = "dbmn1_o_apcust_no_";
            } else if ((Request["tfy_arcase"] ?? "").IN("FC2,FC20,FC21,FC6,FC8,FC0,FCC,FCD,FCG,FCI")) {
                lapnum = "0" + Request["fc0_apnum"];
                field_ap = "dbmn_new_no_";
                ofield_ap = "dbmn_o_apcust_no_";
            } else {
                lapnum = "0" + Request["apnum"];
                field_ap = "apcust_no_";
                ofield_ap = "o_apcust_no_";
            }
            
            //子案入檔從第N筆開始
            if (Request["ar_form"] == "A5") {
                subX=1;
            } else if (Request["ar_form"] == "A6") {
                subX=2;
            } else if (Request["ar_form"] == "A7") {
                subX=2;
            } else if (Request["ar_form"] == "A8") {
                subX=2;
            }

            //交辦內容欄位畫面
            if (Request["ar_form"] == "A3") {
                editA3(in_no);
            } else if (Request["ar_form"] == "A4") {
                editA4(in_no);
            } else if (Request["ar_form"] == "A5") {
                editA5(in_no);
            } else if (Request["ar_form"] == "A6") {
                editA6(in_no);
            } else if (Request["ar_form"] == "A7") {
                editA7(in_no);
            } else if (Request["ar_form"] == "A8") {
                editA8(in_no);
            } else if (Request["ar_form"] == "A9") {
                editA9(in_no);
            } else if (Request["ar_form"] == "AA") {
                editAA(in_no);
            } else if (Request["ar_form"] == "AB") {
                editAB(in_no);
            } else if (Request["ar_form"] == "AC") {
                editAC(in_no);
            } else if (Request["ar_form"].Left(1) == "B") {
                editB(in_no);
            } else {
                editZZ(in_no);
            }

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
        finally {
            conn.Dispose();
        }
    }
    
    /// <summary>
    /// 寫入Log檔
    /// </summary>
    private void log_table() {
        if (ReqVal.TryGet("in_scode") != ReqVal.TryGet("F_tscode")
            || ReqVal.TryGet("osource") != ReqVal.TryGet("tfy_source")
            || ReqVal.TryGet("ocontract_no") != ReqVal.TryGet("tfy_contract_no")
            || ReqVal.TryGet("o_cust_area") != ReqVal.TryGet("F_cust_area")
            || ReqVal.TryGet("o_cust_seq") != ReqVal.TryGet("F_cust_seq")
            || ReqVal.TryGet("oatt_sql") != ReqVal.TryGet("tfy_att_sql")
            ) {
                Sys.insert_log_table(conn, "U", prgid, "case_dmt", "in_scode;in_no", Request["in_scode"] + ";" + Request["in_no"], "Brt52國內案交辦資料維護作業");
                Sys.insert_log_table(conn, "U", prgid, "caseitem_dmt", "in_scode;in_no", Request["in_scode"] + ";" + Request["in_no"], "");
                Sys.insert_log_table(conn, "U", prgid, "dmt_temp", "in_no;in_scode", Request["in_no"] + ";" + Request["in_scode"], "");
            if (ReqVal.TryGet("update_dmt") == "dmt") {
                Sys.insert_log_table(conn, "U", prgid, "dmt", "seq;seq1", Request["tseq"] + ";" + Request["tseq1"], "Brt52國內案交辦資料維護作業");
                Sys.insert_log_table(conn, "U", prgid, "ndmt", "seq;seq1", Request["tseq"] + ";" + Request["tseq1"], "Brt52國內案交辦資料維護作業");
            }
            intcasetran_brt();
            intflg = "Y";
        }

        if (ReqVal.TryGet("tseq1") != "M" && intflg == "N" && ReqVal.TryGet("xar_curr") == "0") {
            if (ReqVal.TryGet("tfy_ar_code") != ReqVal.TryGet("ochkar_code")) {
                Sys.insert_log_table(conn, "U", prgid, "case_dmt", "in_scode;in_no", Request["in_scode"] + ";" + Request["in_no"], "Brt52國內案交辦資料維護作業");
                Sys.insert_log_table(conn, "U", prgid, "caseitem_dmt", "in_scode;in_no", Request["in_scode"] + ";" + Request["in_no"], "");
                Sys.insert_log_table(conn, "U", prgid, "dmt_temp", "in_no;in_scode", Request["in_no"] + ";" + Request["in_scode"], "");
                if (ReqVal.TryGet("update_dmt") == "dmt") {
                    Sys.insert_log_table(conn, "U", prgid, "dmt", "seq;seq1", Request["tseq"] + ";" + Request["tseq1"], "Brt52國內案交辦資料維護作業");
                    Sys.insert_log_table(conn, "U", prgid, "ndmt", "seq;seq1", Request["tseq"] + ";" + Request["tseq1"], "Brt52國內案交辦資料維護作業");
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

        SQL = "select count(1) from dmt_temp_ap where in_no=" + ReqVal.TryGet("in_no").Trim() + " and case_sqlno='0'";
        int rs_apnum = Convert.ToInt32(conn.ExecuteScalar(SQL) ?? "0");
        if (rs_apnum > 0) {
            //當案件temp的申請人和輸入的申請人不同筆數時，要入casetran
            if (Convert.ToInt32(lapnum) != rs_apnum) {
                if (intflg == "N") {
                    intcasetran_brt();
                    intflg = "Y";
                }
                for (int i = 1; i <= Convert.ToInt32(lapnum); i++) {
                    //筆數不同入，要入casetrand
                    int_casetrand_brt("dmt_temp", "I37", "apcust_no", ReqVal.TryGet("Apcust_no_" + i), ref ixi);
                }
                inttran_flag = "Y";
            }
        }

        if (inttran_flag == "N") {
            for (int i = 1; i <= Convert.ToInt32(lapnum); i++) {
                //當案件temp的申請人和輸入的申請人號碼不同時，要入casetran
                if (ReqVal.TryGet(ofield_ap + i) != ReqVal.TryGet(field_ap + i)) {
                    if (intflg == "N") {
                        intcasetran_brt();
                        intflg = "Y";
                    }
                    int_casetrand_brt("dmt_temp", "I37", "apcust_no", ReqVal.TryGet(field_ap + i), ref ixi);
                }
            }
            inttran_flag = "Y";
        }


        //商品入log_table
        Sys.insert_log_table(conn, "U", prgid, "casedmt_good", "in_no;in_scode", Request["in_no"] + ";" + Request["in_scode"], "");
        SQL = "delete from casedmt_good where in_no='" + Request["in_no"] + "' and in_scode='" + Request["in_scode"] + "'";
        conn.ExecuteNonQuery(SQL);

        //展覽優先權入log_table
        Sys.insert_log_table(conn, "U", prgid, "casedmt_show", "in_no;case_sqlno", Request["in_no"] + ";0", "");
        SQL = "delete from casedmt_show where in_no='" + Request["in_no"] + "' and case_sqlno=0";
        conn.ExecuteNonQuery(SQL);

        //異動檔入dmt_tran_log
        Sys.insert_log_table(conn, "U", prgid, "dmt_tran", "in_no;in_scode", Request["in_no"] + ";" + Request["in_scode"], "");
        SQL = "delete from dmt_tran where in_no='" + Request["in_no"] + "' and in_scode='" + Request["in_scode"] + "'";
        conn.ExecuteNonQuery(SQL);

        //異動明細檔入dmt_tranlist_log
        Sys.insert_log_table(conn, "U", prgid, "dmt_tranlist", "in_no;in_scode", Request["in_no"] + ";" + Request["in_scode"], "");
        SQL = "delete from dmt_tranlist where in_no='" + Request["in_no"] + "' and in_scode='" + Request["in_scode"] + "'";
        conn.ExecuteNonQuery(SQL);

        if (ReqVal.TryGet("update_dmt") == "dmt") {
            //商品入log_table(主案)
            Sys.insert_log_table(conn, "U", prgid, "dmt_good", "seq;seq1", Request["tfzb_seq"] + ";" + Request["tfzb_seq1"], "");
            SQL = "delete from dmt_good where seq='" + Request["tfzb_seq"] + "' and seq1='" + Request["tfzb_seq1"] + "'";
            conn.ExecuteNonQuery(SQL);

            //展覽優先權入log_table(主案)
            Sys.insert_log_table(conn, "U", prgid, "dmt_show", "seq;seq1", Request["tfzb_seq"] + ";" + Request["tfzb_seq1"], "");
            SQL = "delete from dmt_show where seq='" + Request["tfzb_seq"] + "' and seq1='" + Request["tfzb_seq1"] + "'";
            conn.ExecuteNonQuery(SQL);

            for (int x = subX; x <= Convert.ToInt32("0" + Request["nfy_tot_num"]); x++) {
                //子案商品
                SQL = "delete from dmt_good ";
                switch (ReqVal.TryGet("tfy_arcase")) {
                    case "FD1":
                        Sys.insert_log_table(conn, "U", prgid, "dmt_good", "seq;seq1", Request["FD1_seqa_" + x] + ";" + Request["FD1_seq1a_" + x], "");
                        SQL += " where seq='" + Request["FD1_seqa_" + x] + "' and seq1='" + Request["FD1_seq1a_" + x] + "'";
                        conn.ExecuteNonQuery(SQL);
                        break;
                    case "FD2":
                    case "FD3":
                        Sys.insert_log_table(conn, "U", prgid, "dmt_good", "seq;seq1", Request["FD2_seqb_" + x] + ";" + Request["FD2_seq1b_" + x], "");
                        SQL += " where seq='" + Request["FD2_seqb_" + x] + "' and seq1='" + Request["FD2_seq1b_" + x] + "'";
                        conn.ExecuteNonQuery(SQL);
                        break;
                }

                //子案展覽優先權
                SQL = "delete from dmt_show ";
                switch (ReqVal.TryGet("tfy_arcase")) {
                    case "FD1":
                        Sys.insert_log_table(conn, "U", prgid, "dmt_show", "seq;seq1", Request["FD1_seqa_" + x] + ";" + Request["FD1_seq1a_" + x], "");
                        SQL += " where seq='" + Request["FD1_seqa_" + x] + "' and seq1='" + Request["FD1_seq1a_" + x] + "'";
                        conn.ExecuteNonQuery(SQL);
                        break;
                    case "FD2":
                    case "FD3":
                        Sys.insert_log_table(conn, "U", prgid, "dmt_show", "seq;seq1", Request["FD2_seqb_" + x] + ";" + Request["FD2_seq1b_" + x], "");
                        SQL += " where seq='" + Request["FD2_seqb_" + x] + "' and seq1='" + Request["FD2_seq1b_" + x] + "'";
                        conn.ExecuteNonQuery(SQL);
                        break;
                }
            }
        }
    }

    private void intcasetran_brt() {
        //---insert casetrand_brt
        SQL = "select isnull(max(sqlno),0) from case_dmt_log where in_no=" + ReqVal.TryGet("in_no").Trim() + " and in_scode='" + Request["in_scode"] + "'";
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
    
    /// <summary>
    /// 寫入接洽記錄檔(case_dmt)
    /// </summary>
    private void update_case_dmt() {
        if (intflg == "N") {
            //入case_dmt_log
            Sys.insert_log_table(conn, "U", prgid, "case_dmt", "in_scode;in_no", Request["in_scode"] + ";" + Request["in_no"], "brt52國內案交辦維護作業");
        }
        SQL = "UPDATE case_dmt SET ";
        ColMap.Clear();
        if (ReqVal.TryGet("F_tscode").Trim() != "") ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
        if (ReqVal.TryGet("tfy_source").Trim() != "") ColMap["source"] = Util.dbchar(Request["tfy_source"]);
        if (ReqVal.TryGet("tfy_contract_type").Trim() != "") ColMap["contract_type"] = Util.dbchar(Request["tfy_contract_type"]);
        if (ReqVal.TryGet("tfy_contract_no").Trim() != "") ColMap["contract_no"] = Util.dbchar(Request["tfy_contract_no"]);
        ColMap["cust_date"] = Util.dbnull(Request["dfy_cust_date"]);
        ColMap["pr_date"] = Util.dbnull(Request["dfy_pr_date"]);
        if (ReqVal.TryGet("tfy_remark").Trim() != "") ColMap["remark"] = Util.dbnull(Request["tfy_remark"]);
        if (ReqVal.TryGet("tfy_att_sql").Trim() != "") ColMap["att_sql"] = Util.dbchar(Request["tfy_att_sql"]);
        if (ReqVal.TryGet("tfy_cust_area").Trim() != "") ColMap["cust_area"] = Util.dbchar(Request["tfy_cust_area"]);
        if (ReqVal.TryGet("tfy_cust_seq").Trim() != "") ColMap["cust_seq"] = Util.dbchar(Request["tfy_cust_seq"]);
        if (ReqVal.TryGet("tfy_div_arcase").Trim() != "") ColMap["div_arcase"] = Util.dbchar(Request["tfy_div_arcase"]);
        //****後續交辦作業序號
        if (ReqVal.TryGet("grconf_sqlno").Trim() != "") ColMap["grconf_sqlno"] = Util.dbnull(Request["grconf_sqlno"]);
        //****結案註記
        if (ReqVal.TryGet("oend_flag").Trim() != ReqVal.TryGet("tfy_end_flag").Trim()) {
            ColMap["end_flag"] = Util.dbchar(Request["tfy_end_flag"]);
        }
        ColMap["end_type"] = Util.dbchar(Request["tfy_end_type"]);
        ColMap["end_remark"] = Util.dbchar(Request["tfy_end_remark"]);
        //****復案註記
        if (ReqVal.TryGet("oback_flag").Trim() != ReqVal.TryGet("tfy_back_flag").Trim()){
            ColMap["back_flag"] = Util.dbchar(Request["tfy_back_flag"]);
        }
        ColMap["back_remark"] = Util.dbchar(Request["tfy_back_remark"]);
        //2011/9/28維護與請款可能同時，且有請款費用，不於此維護作業修改
        //ColMap["ar_code"] = Util.dbchar(Request["tfy_ar_code"]);
        ColMap["tran_date"] = "getdate()";
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
        if (intflg == "N") {
            //入dmt_temp_log 
            Sys.insert_log_table(conn, "U", prgid, "dmt_temp", "in_no;in_scode", Request["in_no"] + ";" + Request["in_scode"], "");
        }

        string aa = Request["draw_file"] ?? "";
        //*****若為新案則新增至案件檔,舊案則不用
        SQL = "UPDATE dmt_temp SET ";
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
        ColMap["draw_file"] = Util.dbchar(Sys.Path2Btbrt(aa));
        ColMap["tr_date"] = "getdate()";
        ColMap["tr_scode"] = "'" + Session["scode"] + "'";
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
        ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
        ColMap["case_sqlno"] = "0";
        if ((Request["tfy_arcase"] ?? "").Left(3).IN("FD1,FD2,FD3")) {//分割案才寫入母案編號
            ColMap["Mseq"] = Util.dbnull(Request["tfzb_seq"]);
            ColMap["Mseq1"] = Util.dbnull(Request["tfzb_seq1"]);
        }
        SQL += ColMap.GetUpdateSQL();
        SQL += " where in_scode = '" + Request["in_scode"] + "' and in_no = '" + Request["In_no"] + "'";
        conn.ExecuteNonQuery(SQL);

        //子案
        if ((Request["ar_form"] ?? "") == "A5") {
            for (int x = subX; x <= Convert.ToInt32("0" + Request["nfy_tot_num"]); x++) {
                string sqlWhere = " where in_scode = '" + Request["in_scode"] + "' and in_no = '" + Request["In_no"] + "'";

                SQL = "UPDATE dmt_temp SET ";
                ColMap["in_scode"] = Util.dbnull(Request["F_tscode"]);
                ColMap["s_mark"] = Util.dbnull(Request["tfzd_S_mark"]);
                ColMap["pul"] = Util.dbnull(Request["tfzd_pul"]);
                ColMap["appl_name"] = Util.dbnull(Request["tfzd_Appl_name"]);
                ColMap["cappl_name"] = Util.dbnull(Request["tfzd_cappl_name"]);
                ColMap["eappl_name"] = Util.dbnull(Request["tfzd_eappl_name"]);
                ColMap["eappl_name1"] = Util.dbnull(Request["tfzd_eappl_name1"]);
                ColMap["eappl_name2"] = Util.dbnull(Request["tfzd_eappl_name2"]);
                ColMap["jappl_name"] = Util.dbnull(Request["tfzd_jappl_name"]);
                ColMap["jappl_name1"] = Util.dbnull(Request["tfzd_jappl_name1"]);
                ColMap["jappl_name2"] = Util.dbnull(Request["tfzd_jappl_name2"]);
                ColMap["zappl_name1"] = Util.dbnull(Request["tfzd_zappl_name1"]);
                ColMap["zappl_name2"] = Util.dbnull(Request["tfzd_zappl_name2"]);
                ColMap["zname_type"] = Util.dbnull(Request["tfzd_zname_type"]);
                ColMap["oappl_name"] = Util.dbnull(Request["tfzd_oappl_name"]);
                ColMap["Draw"] = Util.dbnull(Request["tfzd_Draw"]);
                ColMap["symbol"] = Util.dbnull(Request["tfzd_symbol"]);
                ColMap["color"] = Util.dbnull(Request["tfzd_color"]);
                ColMap["agt_no"] = Util.dbnull(Request["tfzd_agt_no"]);
                ColMap["prior_date"] = Util.dbnull(Request["pfzd_prior_date"]);
                ColMap["prior_no"] = Util.dbnull(Request["tfzd_prior_no"]);
                ColMap["prior_country"] = Util.dbnull(Request["tfzd_prior_country"]);
                ColMap["ref_no"] = Util.dbnull(Request["tfzd_ref_no"]);
                ColMap["ref_no1"] = Util.dbnull(Request["tfzd_ref_no1"]);
                ColMap["apply_date"] = Util.dbnull(Request["tfzd_apply_date"]);//2014/4/15增加寫入申請日，因分割子案申請日與母案相同
                switch ((Request["tfy_arcase"] ?? "").Left(3)) {
                    case "FD1":
                        ColMap["class_count"] = Util.dbnull(Request["FD1_class_count_" + x]);
                        ColMap["class"] = Util.dbnull(Request["FD1_class_" + x]);
                        ColMap["class_type"] = Util.dbnull(Request["FD1_class_type_" + x]);
                        ColMap["mark"] = Util.dbnull(Request["FD1_Marka_" + x]);
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
                        sqlWhere += " and case_sqlno='" + Request["FD1_case_sqlno_" + x] + "'";
                        break;
                    case "FD2":
                    case "FD3":
                        ColMap["class_count"] = Util.dbnull(Request["FD2_class_count_" + x]);
                        ColMap["class"] = Util.dbnull(Request["FD2_class_" + x]);
                        ColMap["class_type"] = Util.dbnull(Request["FD2_class_type_" + x]);
                        ColMap["mark"] = Util.dbnull(Request["FD2_Markb_" + x]);
                        ColMap["s_mark2"] = Util.dbnull(Request["tfzd_s_mark2"]);
                        sqlWhere += " and case_sqlno='" + Request["FD2_case_sqlno_" + x] + "'";
                        break;
                }
                ColMap["tr_date"] = "getdate()";
                ColMap["tr_scode"] = "'" + Session["scode"] + "'";
                SQL += ColMap.GetUpdateSQL();
                SQL += sqlWhere;
                conn.ExecuteNonQuery(SQL);
            }
        } else if ((Request["ar_form"] ?? "") == "A6") {
            if ((Request["tfy_arcase"] ?? "").IN("FC11,FC5,FC7,FCH,FC21,FC6,FC8,FCI")) {
                for (int x = subX; x <= Convert.ToInt32("0" + Request["nfy_tot_num"]); x++) {
                    SQL = "UPDATE dmt_temp SET ";
                    ColMap["in_scode"] = Util.dbnull(Request["F_tscode"]);
                    ColMap["ap_cname"] = Util.dbnull(Request["tfzp_ap_cname"]);
                    ColMap["ap_cname1"] = Util.dbnull(Request["tfzp_ap_cname1"]);
                    ColMap["ap_cname2"] = Util.dbnull(Request["tfzp_ap_cname2"]);
                    ColMap["ap_ename"] = Util.dbnull(Request["tfzp_ap_ename"]);
                    ColMap["ap_ename1"] = Util.dbnull(Request["tfzp_ap_ename1"]);
                    ColMap["ap_ename2"] = Util.dbnull(Request["tfzp_ap_ename2"]);
                    ColMap["apsqlno"] = Util.dbchar(Request["tfzp_apsqlno"]);
                    SQL += ColMap.GetUpdateSQL();
                    if ((Request["tfy_arcase"] ?? "").IN("FC11,FC5,FC7,FCH")) {
                        SQL += "where seq='" + Request["dseqa_" + x] + "'";
                        SQL += " and seq1='" + Request["dseqa1_" + x] + "'";
                    } else if ((Request["tfy_arcase"] ?? "").IN("FC21,FC6,FC8,FCI")) {
                        SQL += "where seq='" + Request["dseqb_" + x] + "'";
                        SQL += " and seq1='" + Request["dseqb1_" + x] + "'";
                    }
                    SQL += " and in_no='" + Request["in_no"] + "'";
                    SQL += " and in_scode='" + Request["in_scode"] + "'";
                    conn.ExecuteNonQuery(SQL);
                }
            }
        }
    }

    /// <summary>
    /// 寫入交辦申請人檔(dmt_temp_ap)
    /// </summary>
    private void insert_dmt_temp_ap(string case_sqlno) {
        //申請人入log_table
        Sys.insert_log_table(conn, "U", prgid, "dmt_temp_ap", "in_no", Request["in_no"] , "");
        SQL = "delete from dmt_temp_ap where in_no='" + Request["in_no"] + "' and case_sqlno=" + case_sqlno;
        conn.ExecuteNonQuery(SQL);

        if ((Request["tfy_arcase"] ?? "").IN("FC1,FC10,FC11,FC5,FC7,FC9,FCA,FCB,FCF,FCH")) {
            insert_dmt_temp_ap_FC2(case_sqlno);
        } else if ((Request["tfy_arcase"] ?? "").IN("FC2,FC20,FC21,FC6,FC8,FC0,FCC,FCD,FCG,FCI")) {
            insert_dmt_temp_ap_FC0(case_sqlno);
        } else {
            insert_dmt_temp_ap0(case_sqlno);
        }

        //子案申請人
        SQL="Delete dmt_temp_ap where in_no='"+Request["in_no"]+"' and case_sqlno<>0";
        conn.ExecuteNonQuery(SQL);
        for (int x = subX; x <= Convert.ToInt32("0" + Request["nfy_tot_num"]); x++) {
            if ((Request["tfy_arcase"] ?? "") == "FD1") {
                insert_dmt_temp_ap0(Request["FD1_case_sqlno_" + x]);
            } else if ((Request["tfy_arcase"] ?? "").IN("FD2,FD3")) {
                insert_dmt_temp_ap0(Request["FD2_case_sqlno_" + x]);
            } else if ((Request["tfy_arcase"] ?? "").IN("FL5,FL6")) {
                if (Request["case_stat1b_" + x] == "NN") {
                    insert_dmt_temp_ap0(Request["case_sqlnob_" + x]);
                }
            }
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
            ColMap["ap_fcname"] = Util.dbchar(Request["ap_fcname_" + i]);
            ColMap["ap_lcname"] = Util.dbchar(Request["ap_lcname_" + i]);
            ColMap["ap_fename"] = Util.dbchar(Request["ap_fename_" + i]);
            ColMap["ap_lename"] = Util.dbchar(Request["ap_lename_" + i]);
            ColMap["tran_date"] = "getdate()";
            ColMap["tran_scode"] = "'" + Session["scode"] + "'";
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
    private void insert_dmt_temp_ap_FC2( string case_sqlno) {
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
    private void insert_caseitem_dmt() {
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
    private void insert_casedmt_good() {
        //****商品類別
        if ((Request["ar_form"] ?? "") == "A4") {
            //延展以交辦內容為準
            for (int i = 1; i <= Convert.ToInt32("0" + Request["tfzd_class_count"]); i++) {
                //2015/10/21增加判斷若有商品也入，因證明標章及團體標章無類別但會有證明內容
                if ((Request["class2_" + i] ?? "") != "" || (Request["good_name2_" + i] ?? "") != "") {
                    SQL = "insert into casedmt_good ";
                    ColMap.Clear();
                    ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
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
                    ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
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
                    ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
                    ColMap["in_no"] = Util.dbchar(Request["in_no"]);
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

        for (int x = subX; x <= Convert.ToInt32("0" + Request["nfy_tot_num"]); x++) {
            switch ((Request["tfy_arcase"] ?? "").Left(3)) {
                case "FD1":
                    //分割子案商品類別入檔
                    for (int p = 1; p <= Convert.ToInt32("0" + Request["FD1_class_count_" + x]); p++) {
                        if ((Request["classa_" + x + "_" + p] ?? "") != "" || (Request["FD1_good_namea_" + x + "_" + p] ?? "") != "") {
                            SQL = "insert into casedmt_good ";
                            ColMap.Clear();
                            ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
                            ColMap["in_no"] = Util.dbchar(Request["In_no"]);
                            ColMap["case_sqlno"] = Util.dbchar(Request["FD1_case_sqlno_" + x]);
                            ColMap["class"] = Util.dbchar(Request["classa_" + x + "_" + p]);
                            ColMap["dmt_goodname"] = Util.dbchar(Request["FD1_good_namea_" + x + "_" + p]);
                            ColMap["dmt_goodcount"] = Util.dbchar(Request["FD1_good_counta_" + x + "_" + p]);
                            ColMap["tr_date"] = "getdate()";
                            ColMap["tr_scode"] = "'" + Session["scode"] + "'";
                            SQL += ColMap.GetInsertSQL();
                            conn.ExecuteNonQuery(SQL);
                        }
                    }
                    //分割子案展覽優先權入檔
                    //分割後案性除FA9,FAA,FAB,FAC外(因所列案性無展覽優先權)，再依母案展覽優先權資料入檔
                    if ((Request["tfy_div_arcase"] ?? "").Left(3) != "FA9" && (Request["tfy_div_arcase"] ?? "").Left(3) != "FAA"
                    && (Request["tfy_div_arcase"] ?? "").Left(3) != "FAB" && (Request["tfy_div_arcase"] ?? "").Left(3) != "FAC") {
                        //分割子案展覽優先權入檔
                        insert_casedmt_show((Request["FD1_case_sqlno_" + x]??"").ToString());
                    }
                    break;
                case "FD2":
                case "FD3":
                    //分割子案商品類別入檔
                    for (int p = 1; p <= Convert.ToInt32("0" + Request["FD2_class_count_" + x]); p++) {
                        if ((Request["classb_" + x + "_" + p] ?? "") != "" || (Request["FD2_good_nameb_" + x + "_" + p] ?? "") != "") {
                            SQL = "insert into casedmt_good ";
                            ColMap.Clear();
                            ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
                            ColMap["in_no"] = Util.dbchar(Request["In_no"]);
                            ColMap["case_sqlno"] = Util.dbchar(Request["FD2_case_sqlno_" + x]);
                            ColMap["class"] = Util.dbchar(Request["classb_" + x + "_" + p]);
                            ColMap["dmt_goodname"] = Util.dbchar(Request["FD2_good_nameb_" + x + "_" + p]);
                            ColMap["dmt_goodcount"] = Util.dbchar(Request["FD2_good_countb_" + x + "_" + p]);
                            ColMap["tr_date"] = "getdate()";
                            ColMap["tr_scode"] = "'" + Session["scode"] + "'";
                            SQL += ColMap.GetInsertSQL();
                            conn.ExecuteNonQuery(SQL);
                        }
                    }
                    //分割子案展覽優先權入檔
                    insert_casedmt_show((Request["FD2_case_sqlno_" + x]??"").ToString());
                    break;
            }
        }
    }

    /// <summary>
    /// 寫入展覽會優先權檔(casedmt_show)
    /// </summary>
    private void insert_casedmt_show(string case_sqlno) {
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
    /// 更新營洽官收確認紀錄檔(grconf_dmt.job_no)
    /// </summary>
    private void upd_grconf_job_no() {
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
    /// 當程序有修改復案或結案註記時通知營洽人員
    /// </summary>
    private void chk_end_back() {
        if (prgid == "brt51") {//客收確認
            string nback_flag = (Request["tfy_back_flag"] ?? "N").Trim();
            string oback_flag = (Request["oback_flag"] ?? "N").Trim();
            string nend_flag = (Request["tfy_end_flag"] ?? "N").Trim();
            string oend_flag = (Request["oend_flag"] ?? "N").Trim();
            if ((nback_flag != oback_flag) || (nend_flag != oend_flag)) {
                string Subject = "國內所國內商標管理系統－程序修改交辦案件結案/復案註記通知";
                string strFrom = Session["scode"] + "@saint-island.com.tw";
                List<string> strTo = new List<string>();
                List<string> strCC = new List<string>();
                List<string> strBCC = new List<string>();
                switch (Sys.Host) {
                    case "web08": case "localhost":
                        strTo.Add(Session["scode"] + "@saint-island.com.tw");
                        Subject = "(web08)" + Subject;
                        break;
                    case "web10":
                        strTo.Add(Session["scode"] + "@saint-island.com.tw");
                        Subject = "(web10)" + Subject;
                        break;
                    default:
                        strTo.Add(Request["in_scode"] + "@saint-island.com.tw");
                        strBCC.Add("m1583@saint-island.com.tw");
                        break;
                }

                string fseq = Sys.formatSeq(Request["tfzb_seq"], Request["tfzb_seq1"], "", Sys.GetSession("seBranch"), "T");
                string body = "【接洽序號】 : <B>" + Request["in_scode"] + "-" + Request["in_no"] + "</B><br>" +
                    "【本所編號】 : <B>" + fseq + "</B><br>" +
                    "【案件名稱】 : <B>" + Request["tfzd_Appl_name"] + "</B><br>" +
                    "【修改內容】 : <B>";
                if (nback_flag != oback_flag) {
                    body += "洽案時復案註記：";
                    if (oback_flag == "N") body += "不復案";
                    else if (oback_flag == "Y") body += "要復案";
                    
                    body += "，修改後復案註記：";
                    if (nback_flag == "N") body += "不復案";
                    else if (nback_flag == "Y") body += "要復案";
                }

                if (nend_flag != oend_flag) {
                    body += "洽案時結案註記：";
                    if (oend_flag == "N") body += "不結案";
                    else if (oend_flag == "Y") body += "要結案";
                    
                    body += "，修改後結案註記：";
                    if (nend_flag == "N") body += "不結案";
                    else if (nend_flag == "Y") body += "要結案";
                }
                Sys.DoSendMail(Subject, body, strFrom, strTo, strCC, strBCC);
            }
        }
    }
    
    /// <summary>
    /// 結案/復案註記維護,通知總管處
    /// </summary>
    private void update_todo() {
        //2011/2/15結案註記維護由N改為Y，程序結案處理
        if ((ReqVal.TryGet("oend_flag") == "N" || ReqVal.TryGet("oend_flag") == "") && ReqVal.TryGet("tfy_end_flag") == "Y") {
            string job_team = "T210";
            string job_scode = Sys.getCodeName(conn, "sysctrl.dbo.scode_group", "scode", "where grpclass='" + Session["se_branch"] + "' and grpid='T210' and grptype='F'");
            string in_team = Sys.getCodeName(conn, "sysctrl.dbo.scode_group", "grpid", "where grpclass='" + Session["se_branch"] + "' and scode='" + Request["in_scode"] + "'");
            SQL = "insert into todo_dmt ";
            ColMap.Clear();
            ColMap["syscode"] = "'" + Session["syscode"] + "'";
            ColMap["apcode"] = HTProgCode;
            ColMap["from_flag"] = "'END'";
            ColMap["branch"] = "'" + Session["seBranch"] + "'";
            ColMap["seq"] = Util.dbnull(Request["tfzb_seq"]);
            ColMap["seq1"] = Util.dbchar(Request["tfzb_seq1"]);
            ColMap["step_grade"] = Util.dbnull(Request["attach_step_grade"]);
            ColMap["in_team"] = Util.dbchar(in_team);
            ColMap["case_in_scode"] = Util.dbchar(Request["in_scode"]);
            ColMap["in_no"] = Util.dbchar(Request["in_no"]);
            ColMap["br_end_reason"] = Util.dbchar(Request["in_scode"]);
            ColMap["case_no"] = Util.dbchar(Request["tcase_no"]);
            ColMap["in_scode"] = "'" + Session["scode"] + "'";
            ColMap["in_date"] = "getdate()";
            ColMap["dowhat"] = "'DC_END1'";
            ColMap["job_scode"] = Util.dbchar(job_scode);
            ColMap["job_team"] = Util.dbchar(job_team);
            ColMap["job_status"] = "'NN'";
            SQL += ColMap.GetInsertSQL();
            conn.ExecuteNonQuery(SQL);

            string tctrl_date = DateTime.Today.AddMonths(1).ToShortDateString();
            //抓取進度流水號rs_no
            SQL = "select rs_no from step_dmt where seq=" + Request["tfzb_seq"] + " and seq1='" + Request["tfzb_seq1"] + "' and step_grade=" + Request["attach_step_grade"];
            string rs_no = (conn.ExecuteScalar(SQL) ?? "").ToString();

            SQL = "insert into ctrl_dmt ";
            ColMap.Clear();
            ColMap["rs_no"] = "'" + rs_no + "'";
            ColMap["branch"] = "'" + Session["seBranch"] + "'";
            ColMap["seq"] = Util.dbnull(Request["tfzb_seq"]);
            ColMap["seq1"] = Util.dbchar(Request["tfzb_seq1"]);
            ColMap["step_grade"] = Util.dbnull(Request["attach_step_grade"]);
            ColMap["ctrl_type"] = Util.dbchar("B6");
            ColMap["ctrl_remark"] = Util.dbchar("結案處理期限");
            ColMap["ctrl_date"] = Util.dbchar(tctrl_date);
            ColMap["tran_date"] = "getdate()";
            ColMap["tran_scode"] = "'" + Session["scode"] + "'";
            SQL += ColMap.GetInsertSQL();
            conn.ExecuteNonQuery(SQL);
        }

        //2011/2/15復案註記維護由N改為Y，通知總管處復案
        if ((ReqVal.TryGet("oback_flag") == "N" || ReqVal.TryGet("oback_flag") == "") && ReqVal.TryGet("tfy_back_flag") == "Y") {
            //檢查有無結案進行中
            bool chkflag = false;
            SQL = "select * from todo_dmt where seq=" + Request["tfzb_seq"] + " and seq1='" + Request["tfzb_seq1"] + "' and job_status='NN' and dowhat like '%END%' ";
            using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
                while (dr.Read()) {
                    chkflag = true;
                    //銷管結案期限
                    SQL = "insert into resp_dmt(sqlno,rs_no,branch,seq,seq1,step_grade,resp_grade,ctrl_type,ctrl_remark,ctrl_date,resp_date,resp_type,resp_remark,tran_date,tran_scode) ";
                    SQL += "select sqlno,rs_no,branch,seq,seq1,step_grade,0,ctrl_type,ctrl_remark,ctrl_date,'" + DateTime.Today.ToShortDateString() + "','','復案取消結案',getdate(),'" + Session["scode"] + "' ";
                    SQL += "from ctrl_dmt where sqlno in(";
                    SQL += "select sqlno from ctrl_dmt where seq=" + Request["tfzb_seq"] + " and seq1='" + Request["tfzb_seq1"] + "' and step_grade='" + dr["step_grade"] + "' andc ctrl_type in ('B6','B61') ";
                    SQL += ")";
                    conn.ExecuteNonQuery(SQL);

                    SQL = "delete from ctrl_dmt where sqlno in(";
                    SQL += "select sqlno from ctrl_dmt where seq=" + Request["tfzb_seq"] + " and seq1='" + Request["tfzb_seq1"] + "' and step_grade='" + dr["step_grade"] + "' andc ctrl_type in ('B6','B61') ";
                    SQL += ")";
                    conn.ExecuteNonQuery(SQL);

                    //更新結案流程狀態
                    SQL = "update todo_dmt set job_status = 'XX' ";
                    SQL += " ,approve_scode = '" + Session["scode"] + "' ";
                    SQL += " ,approve_desc = '復案取消結案流程'";
                    SQL += " ,resp_date=getdate() ";
                    SQL += " where sqlno in(";
                    SQL += "select sqlno from ctrl_dmt where seq=" + Request["tfzb_seq"] + " and seq1='" + Request["tfzb_seq1"] + "' and step_grade='" + dr["step_grade"] + "' andc ctrl_type in ('B6','B61') ";
                    SQL += ")";
                    conn.ExecuteNonQuery(SQL);
                }
            }

            //復案註記且已結案完成(無結案進行中)要通知總管處
            if (chkflag == false) {
                //抓取進度流水號
                SQL = "select rs_sqlno from step_dmt where seq=" + Request["tfzb_seq"] + " and seq1='" + Request["tfzb_seq1"] + "' and step_grade=" + Request["attach_step_grade"];
                string br_rs_sqlno = (conn.ExecuteScalar(SQL) ?? "0").ToString();

                SQL = "insert into brend_mgt ";
                ColMap.Clear();
                ColMap["br_step_grade"] = Util.dbchar(Request["attach_step_grade"]);
                ColMap["br_rs_sqlno"] = Util.dbchar(br_rs_sqlno);
                ColMap["seq_area"] = "'" + Session["seBranch"] + "'";
                ColMap["seq"] = Util.dbnull(Request["tfzb_seq"]);
                ColMap["seq1"] = Util.dbchar(Request["tfzb_seq1"]);
                ColMap["end_flag"] = "'back'";
                ColMap["in_scode"] = "'" + Session["scode"] + "'";
                ColMap["in_date"] = "getdate()";
                ColMap["br_end_reason"] = Util.dbchar(Request["tfy_back_remark"]);
                SQL += ColMap.GetInsertSQL();
                connm.ExecuteNonQuery(SQL);

                //抓insert後的流水號
                SQL = "SELECT SCOPE_IDENTITY() AS Current_Identity";
                string Getrs_sqlno = (connm.ExecuteScalar(SQL) ?? "0").ToString();

                SQL = "insert into todo_mgt ";
                ColMap.Clear();
                ColMap["syscode"] = "'" + Session["syscode"] + "'";
                ColMap["apcode"] = "'brt52'";
                ColMap["temp_rs_sqlno"] = Util.dbchar(Getrs_sqlno);
                ColMap["br_rs_sqlno"] = Util.dbchar(br_rs_sqlno);
                ColMap["seq_area"] = "'" + Session["seBranch"] + "'";
                ColMap["seq"] = Util.dbchar(Request["tfzb_seq"]);
                ColMap["seq1"] = Util.dbchar(Request["tfzb_seq1"]);
                ColMap["in_date"] = "getdate()";
                ColMap["in_scode"] = "'" + Session["scode"] + "'";
                ColMap["dowhat"] = "'back'";
                ColMap["job_status"] = "'NN'";
                SQL += ColMap.GetInsertSQL();
                connm.ExecuteNonQuery(SQL);
            }
        }
    }
    
    /// <summary>
    /// 修改國內商標案件主檔相關欄位dmt/ndmt/dmt_good/dmt_show/dmt_ap
    /// </summary>
    private void update_dmt() {
        string aa = Request["draw_file"] ?? "";
        if (Request["update_dmt"] == "dmt") {
            //國內商標案件主檔dmt
            if (intflg == "N") {
                //dmt入log檔
                Sys.insert_log_table(conn, "U", prgid, "dmt", "seq;seq1", Request["tfzb_seq"] + ";" + Request["tfzb_seq1"], "Brt52國內交辦資料維護");
            }

            SQL = "UPDATE dmt SET ";
            ColMap.Clear();
            ColMap["scode"] = Util.dbnull(Request["F_tscode"]);
            ColMap["s_mark"] = Util.dbnull(Request["tfzd_s_mark"]);
            ColMap["cust_prod"] = Util.dbnull(Request["tfzd_cust_prod"]);
            ColMap["s_mark2"] = Util.dbnull(Request["tfzd_s_mark2"]);
            if ((Request["ar_form"] ?? "") == "A4") {
                ColMap["class"] = Util.dbnull(Request["tfzd_class"]);
                ColMap["class_count"] = Util.dbnull(Request["tfzd_class_count"]);
                ColMap["class_type"] = Util.dbnull(Request["tfzd_class_type"]);
            } else {
                ColMap["class"] = Util.dbnull(Request["tfzr_class"]);
                ColMap["class_count"] = Util.dbnull(Request["tfzr_class_count"]);
                ColMap["class_type"] = Util.dbnull(Request["tfzr_class_type"]);
            }
            ColMap["appl_name"] = Util.dbnull(Request["tfzd_Appl_name"]);
            ColMap["cust_area"] = Util.dbnull(Request["tfy_cust_area"]);
            ColMap["cust_seq"] = Util.dbnull(Request["tfy_cust_seq"]);
            ColMap["att_sql"] = Util.dbnull(Request["tfy_att_sql"]);
            ColMap["agt_no"] = Util.dbnull(Request["tfzd_agt_no"]);
            ColMap["apply_date"] = Util.dbnull(Request["tfzd_apply_date"]);
            ColMap["apply_no"] = Util.dbnull(Request["tfzd_apply_no"]);
            ColMap["issue_date"] = Util.dbnull(Request["tfzd_issue_date"]);
            ColMap["issue_no"] = Util.dbnull(Request["tfzd_issue_no"]);
            ColMap["open_date"] = Util.dbnull(Request["tfzd_open_date"]);
            ColMap["rej_no"] = Util.dbnull(Request["tfzd_rej_no"]);
            ColMap["prior_date"] = Util.dbnull(Request["pfzd_prior_date"]);
            ColMap["prior_no"] = Util.dbnull(Request["tfzd_prior_no"]);
            ColMap["prior_country"] = Util.dbnull(Request["tfzd_prior_country"]);
            ColMap["term1"] = Util.dbnull(Request["tfzd_dmt_term1"]);
            ColMap["term2"] = Util.dbnull(Request["tfzd_dmt_term2"]);
            ColMap["pul"] = Util.dbnull(Request["tfzd_pul"]);
            ColMap["tcn_ref"] = Util.dbnull(Request["tfzd_tcn_ref"]);
            ColMap["tcn_class"] = Util.dbnull(Request["tfzd_tcn_class"]);
            ColMap["tcn_name"] = Util.dbnull(Request["tfzd_tcn_name"]);
            ColMap["tcn_mark"] = Util.dbnull(Request["tfzd_tcn_mark"]);
            if (Request["tfy_back_flag"] == "Y") {//改為要復案
                ColMap["end_date"] = "NULL";
                ColMap["end_code"] = Util.dbchar("");
                ColMap["end_type"] = Util.dbchar("");
                ColMap["end_remark"] = Util.dbchar("");
            }
            if (Request["tfy_end_flag"] == "Y") {//改為要結案
                ColMap["end_type"] = Util.dbchar(Request["tfy_end_type"]);
                ColMap["end_remark"] = Util.dbchar(Request["tfy_end_remark"]);
            }
            ColMap["renewal"] = Util.dbnull(Request["tfzd_renewal"]);
            SQL += ColMap.GetUpdateSQL();
            SQL += " where seq = '" + Request["tfzb_seq"] + "' and seq1 = '" + Request["tfzb_seq1"] + "'";
            conn.ExecuteNonQuery(SQL);

            //修改子案案件主檔
            if ((Request["ar_form"] ?? "") == "A5") {
                for (int x = subX; x <= Convert.ToInt32("0" + Request["nfy_tot_num"]); x++) {
                    string sqlWhere = "";

                    SQL = "UPDATE dmt SET ";
                    switch ((Request["tfy_arcase"] ?? "").Left(3)) {
                        case "FD1":
                            ColMap["class_count"] = Util.dbnull(Request["FD1_class_count_" + x]);
                            ColMap["class"] = Util.dbnull(Request["FD1_class_" + x]);
                            ColMap["class_type"] = Util.dbnull(Request["FD1_class_type_" + x]);
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
                            sqlWhere = " where seq = '" + Request["FD1_seqa_" + x] + "' and seq1 = '" + Request["FD1_seq1a_" + x] + "'";
                            break;
                        case "FD2":
                        case "FD3":
                            ColMap["class_count"] = Util.dbnull(Request["FD2_class_count_" + x]);
                            ColMap["class"] = Util.dbnull(Request["FD2_class_" + x]);
                            ColMap["class_type"] = Util.dbnull(Request["FD2_class_type_" + x]);
                            ColMap["s_mark2"] = Util.dbnull(Request["tfzd_s_mark2"]);
                            sqlWhere = " where seq = '" + Request["FD2_seqb_" + x] + "' and seq1 = '" + Request["FD2_seq1b_" + x] + "'";
                            break;
                    }
                    ColMap["scode"] = Util.dbnull(Request["F_tscode"]);
                    ColMap["appl_name"] = Util.dbnull(Request["tfzd_Appl_name"]);
                    ColMap["cust_area"] = Util.dbnull(Request["tfy_cust_area"]);
                    ColMap["cust_seq"] = Util.dbnull(Request["tfy_cust_seq"]);
                    ColMap["att_sql"] = Util.dbnull(Request["tfy_att_sql"]);
                    ColMap["agt_no"] = Util.dbnull(Request["tfzd_agt_no"]);
                    ColMap["prior_date"] = Util.dbnull(Request["pfzd_prior_date"]);
                    ColMap["prior_no"] = Util.dbnull(Request["tfzd_prior_no"]);
                    ColMap["prior_country"] = Util.dbnull(Request["tfzd_prior_country"]);
                    ColMap["pul"] = Util.dbnull(Request["tfzd_pul"]);
                    ColMap["tcn_ref"] = Util.dbnull(Request["tfzd_tcn_ref"]);
                    ColMap["tcn_class"] = Util.dbnull(Request["tfzd_tcn_class"]);
                    ColMap["tcn_name"] = Util.dbnull(Request["tfzd_tcn_name"]);
                    ColMap["tcn_mark"] = Util.dbnull(Request["tfzd_tcn_mark"]);
                    ColMap["apply_date"] = Util.dbnull(Request["tfzd_apply_date"]);//2014/4/15增加寫入申請日，因分割子案申請日與母案相同
                    ColMap["tr_date"] = "getdate()";
                    ColMap["tr_scode"] = "'" + Session["scode"] + "'";
                    SQL += ColMap.GetUpdateSQL();
                    SQL += sqlWhere;
                    conn.ExecuteNonQuery(SQL);
                }
            } else if ((Request["tfy_arcase"] ?? "").IN("FC11,FC5,FC7,FCH")) {
                for (int x = subX; x <= Convert.ToInt32("0" + Request["nfy_tot_num"]); x++) {
                    //dmt入log檔
                    Sys.insert_log_table(conn, "U", prgid, "dmt", "seq;seq1", Request["dseqa_" + x] + ";" + Request["dseq1a_" + x], "Brt52國內交辦資料維護");
                    SQL = "UPDATE dmt SET ";
                    ColMap.Clear();
                    ColMap["scode"] = Util.dbnull(Request["F_tscode"]);
                    ColMap["cust_area"] = Util.dbnull(Request["tfy_cust_area"]);
                    ColMap["cust_seq"] = Util.dbnull(Request["tfy_cust_seq"]);
                    ColMap["att_sql"] = Util.dbnull(Request["tfy_att_sql"]);
                    SQL += " where seq = '" + Request["dseqa_" + x] + "' and seq1 = '" + Request["dseq1a_" + x] + "'";
                    conn.ExecuteNonQuery(SQL);
                }
            } else if ((Request["tfy_arcase"] ?? "").IN("FT2,FL5,FL6,FC21,FC6,FC8,FCI")) {
                for (int x = subX; x <= Convert.ToInt32("0" + Request["nfy_tot_num"]); x++) {
                    //dmt入log檔
                    Sys.insert_log_table(conn, "U", prgid, "dmt", "seq;seq1", Request["dseqb_" + x] + ";" + Request["dseq1b_" + x], "Brt52國內交辦資料維護");
                    SQL = "UPDATE dmt SET ";
                    ColMap.Clear();
                    ColMap["scode"] = Util.dbnull(Request["F_tscode"]);
                    ColMap["cust_area"] = Util.dbnull(Request["tfy_cust_area"]);
                    ColMap["cust_seq"] = Util.dbnull(Request["tfy_cust_seq"]);
                    ColMap["att_sql"] = Util.dbnull(Request["tfy_att_sql"]);
                    SQL += " where seq = '" + Request["dseqb_" + x] + "' and seq1 = '" + Request["dseq1b_" + x] + "'";
                    conn.ExecuteNonQuery(SQL);
                }
            }

            //國內商標案件主檔ndmt
            if (intflg == "N") {
                Sys.insert_log_table(conn, "U", prgid, "ndmt", "seq;seq1", Request["tfzb_seq"] + ";" + Request["tfzb_seq1"], "");
            }
            SQL = "UPDATE ndmt SET ";
            ColMap.Clear();
            ColMap["cappl_name"] = Util.dbnull(Request["tfzd_Cappl_name"]);
            ColMap["Eappl_name"] = Util.dbnull(Request["tfzd_Eappl_name"]);
            ColMap["eappl_name1"] = Util.dbnull(Request["tfzd_Eappl_name1"]);
            ColMap["eappl_name2"] = Util.dbnull(Request["tfzd_Eappl_name2"]);
            ColMap["jappl_name"] = Util.dbnull(Request["tfzd_jappl_name"]);
            ColMap["jappl_name1"] = Util.dbnull(Request["tfzd_jappl_name1"]);
            ColMap["jappl_name2"] = Util.dbnull(Request["tfzd_jappl_name2"]);
            ColMap["zappl_name1"] = Util.dbnull(Request["tfzd_zappl_name1"]);
            ColMap["zappl_name2"] = Util.dbnull(Request["tfzd_zappl_name2"]);
            ColMap["zname_type"] = Util.dbnull(Request["tfzd_Zname_type"]);
            ColMap["oappl_name"] = Util.dbnull(Request["tfzd_Oappl_name"]);
            ColMap["draw"] = Util.dbnull(Request["tfzd_Draw"]);
            ColMap["draw_file"] = Util.dbchar(Sys.Path2Btbrt(aa));
            ColMap["symbol"] = Util.dbnull(Request["tfzd_Symbol"]);
            ColMap["color"] = Util.dbnull(Request["tfzd_color"]);
            ColMap["tran_date"] = "getdate()";
            ColMap["tran_scode"] = "'" + Session["scode"] + "'";
            ColMap["in_scode"] = Util.dbnull(Request["F_tscode"]);
            ColMap["in_no"] = Util.dbnull(Request["in_no"]);
            SQL += ColMap.GetUpdateSQL();
            SQL += " where seq = '" + Request["tfzb_seq"] + "' and seq1 = '" + Request["tfzb_seq1"] + "'";
            conn.ExecuteNonQuery(SQL);

            //修改子案案件主檔
            if ((Request["ar_form"] ?? "") == "A5") {
                for (int x = subX; x <= Convert.ToInt32("0" + Request["nfy_tot_num"]); x++) {
                    //dmt入log檔
                    if ((Request["tfy_arcase"] ?? "").IN("FD1")) {
                        Sys.insert_log_table(conn, "U", prgid, "ndmt", "seq;seq1", Request["FD1_seqa_" + x] + ";" + Request["FD1_seq1a_" + x], "Brt52國內交辦資料維護");
                    } else if ((Request["tfy_arcase"] ?? "").IN("FD2,FD3")) {
                        Sys.insert_log_table(conn, "U", prgid, "ndmt", "seq;seq1", Request["FD2_seqb_" + x] + ";" + Request["FD2_seq1b_" + x], "Brt52國內交辦資料維護");
                    }

                    SQL = "UPDATE ndmt SET ";
                    ColMap.Clear();
                    ColMap["cappl_name"] = Util.dbnull(Request["tfzd_Cappl_name"]);
                    ColMap["Eappl_name"] = Util.dbnull(Request["tfzd_Eappl_name"]);
                    ColMap["eappl_name1"] = Util.dbnull(Request["tfzd_Eappl_name1"]);
                    ColMap["eappl_name2"] = Util.dbnull(Request["tfzd_Eappl_name2"]);
                    ColMap["jappl_name"] = Util.dbnull(Request["tfzd_jappl_name"]);
                    ColMap["jappl_name1"] = Util.dbnull(Request["tfzd_jappl_name1"]);
                    ColMap["jappl_name2"] = Util.dbnull(Request["tfzd_jappl_name2"]);
                    ColMap["zappl_name1"] = Util.dbnull(Request["tfzd_zappl_name1"]);
                    ColMap["zappl_name2"] = Util.dbnull(Request["tfzd_zappl_name2"]);
                    ColMap["zname_type"] = Util.dbnull(Request["tfzd_Zname_type"]);
                    ColMap["oappl_name"] = Util.dbnull(Request["tfzd_Oappl_name"]);
                    ColMap["draw"] = Util.dbnull(Request["tfzd_Draw"]);
                    ColMap["symbol"] = Util.dbnull(Request["tfzd_Symbol"]);
                    ColMap["color"] = Util.dbnull(Request["tfzd_color"]);
                    ColMap["in_scode"] = Util.dbnull(Request["F_tscode"]);
                    ColMap["tran_date"] = "getdate()";
                    ColMap["tran_scode"] = "'" + Session["scode"] + "'";
                    SQL += ColMap.GetUpdateSQL();
                    if ((Request["tfy_arcase"] ?? "").IN("FD1")) {
                        SQL += " where seq = '" + Request["FD1_seqa_" + x] + "' and seq1 = '" + Request["FD1_seq1a_" + x] + "'";
                    } else if ((Request["tfy_arcase"] ?? "").IN("FD2,FD3")) {
                        SQL += " where seq = '" + Request["FD2_seqb_" + x] + "' and seq1 = '" + Request["FD2_seq1b_" + x] + "'";
                    }
                    conn.ExecuteNonQuery(SQL);
                }
            } else if ((Request["tfy_arcase"] ?? "").IN("FC11,FC5,FC7,FCH")) {
                for (int x = subX; x <= Convert.ToInt32("0" + Request["nfy_tot_num"]); x++) {
                    //dmt入log檔
                    Sys.insert_log_table(conn, "U", prgid, "ndmt", "seq;seq1", Request["dseqa_" + x] + ";" + Request["dseq1a_" + x], "Brt52國內交辦資料維護");
                    SQL = "UPDATE ndmt SET ";
                    ColMap.Clear();
                    ColMap["in_scode"] = Util.dbnull(Request["F_tscode"]);
                    ColMap["tran_date"] = "getdate()";
                    ColMap["tran_scode"] = "'" + Session["scode"] + "'";
                    SQL += " where seq = '" + Request["dseqa_" + x] + "' and seq1 = '" + Request["dseq1a_" + x] + "'";
                    conn.ExecuteNonQuery(SQL);
                }
            } else if ((Request["tfy_arcase"] ?? "").IN("FT2,FL5,FL6,FC21,FC6,FC8,FCI")) {
                for (int x = subX; x <= Convert.ToInt32("0" + Request["nfy_tot_num"]); x++) {
                    //ndmt入log檔
                    Sys.insert_log_table(conn, "U", prgid, "ndmt", "seq;seq1", Request["dseqb_" + x] + ";" + Request["dseq1b_" + x], "");
                    SQL = "UPDATE ndmt SET ";
                    ColMap.Clear();
                    ColMap["in_scode"] = Util.dbnull(Request["F_tscode"]);
                    ColMap["tran_date"] = "getdate()";
                    ColMap["tran_scode"] = "'" + Session["scode"] + "'";
                    SQL += " where seq = '" + Request["dseqb_" + x] + "' and seq1 = '" + Request["dseq1b_" + x] + "'";
                    conn.ExecuteNonQuery(SQL);
                }
            }

            //商品類別
            if ((Request["ar_form"] ?? "") == "A4") {
                //延展以交辦內容為準
                for (int i = 1; i <= Convert.ToInt32("0" + Request["tfzd_class_count"]); i++) {
                    //2015/10/21增加判斷若有商品也入，因證明標章及團體標章無類別但會有證明內容
                    if ((Request["class2_" + i] ?? "") != "" || (Request["good_name2_" + i] ?? "") != "") {
                        SQL = "insert into dmt_good ";
                        ColMap.Clear();
                        ColMap["seq"] = Util.dbchar(Request["tfzb_seq"]);
                        ColMap["seq1"] = Util.dbchar(Request["tfzb_seq1"]);
                        ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
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
                        SQL = "insert into dmt_good ";
                        ColMap.Clear();
                        ColMap["seq"] = Util.dbchar(Request["tfzb_seq"]);
                        ColMap["seq1"] = Util.dbchar(Request["tfzb_seq1"]);
                        ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
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
                        SQL = "insert into dmt_good ";
                        ColMap.Clear();
                        ColMap["seq"] = Util.dbchar(Request["tfzb_seq"]);
                        ColMap["seq1"] = Util.dbchar(Request["tfzb_seq1"]);
                        ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
                        ColMap["in_no"] = Util.dbchar(Request["in_no"]);
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

            //子案案件商品類別
            if ((Request["ar_form"] ?? "") == "A5") {
                for (int x = subX; x <= Convert.ToInt32("0" + Request["nfy_tot_num"]); x++) {
                    switch ((Request["tfy_arcase"] ?? "").Left(3)) {
                        case "FD1":
                            //分割子案商品類別入檔
                            for (int p = 1; p <= Convert.ToInt32("0" + Request["FD1_class_count_" + x]); p++) {
                                if ((Request["classa_" + x + "_" + p] ?? "") != "" || (Request["FD1_good_namea_" + x + "_" + p] ?? "") != "") {
                                    SQL = "insert into dmt_good ";
                                    ColMap.Clear();
                                    ColMap["seq"] = Util.dbchar(Request["FD1_seqa_" + x]);
                                    ColMap["seq1"] = Util.dbchar(Request["FD1_seq1a_" + x]);
                                    ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
                                    ColMap["in_no"] = Util.dbchar(Request["In_no"]);
                                    ColMap["class"] = Util.dbchar(Request["classa_" + x + "_" + p]);
                                    ColMap["dmt_goodname"] = Util.dbchar(Request["FD1_good_namea_" + x + "_" + p]);
                                    ColMap["dmt_goodcount"] = Util.dbchar(Request["FD1_good_counta_" + x + "_" + p]);
                                    ColMap["tr_date"] = "getdate()";
                                    ColMap["tr_scode"] = "'" + Session["scode"] + "'";
                                    SQL += ColMap.GetInsertSQL();
                                    conn.ExecuteNonQuery(SQL);
                                }
                            }
                            //分割子案展覽優先權入檔
                            //分割後案性除FA9,FAA,FAB,FAC外(因所列案性無展覽優先權)，再依母案展覽優先權資料入檔
                            if ((Request["tfy_div_arcase"] ?? "").Left(3) != "FA9" && (Request["tfy_div_arcase"] ?? "").Left(3) != "FAA"
                            && (Request["tfy_div_arcase"] ?? "").Left(3) != "FAB" && (Request["tfy_div_arcase"] ?? "").Left(3) != "FAC") {
                                //分割子案展覽優先權入檔
                                insert_dmt_show(Request["FD1_seqa_" + x], Request["FD1_seq1a_" + x]);
                            }
                            break;
                        case "FD2":
                        case "FD3":
                            //分割子案商品類別入檔
                            for (int p = 1; p <= Convert.ToInt32("0" + Request["FD2_class_count_" + x]); p++) {
                                if ((Request["classb_" + x + "_" + p] ?? "") != "" || (Request["FD2_good_nameb_" + x + "_" + p] ?? "") != "") {
                                    SQL = "insert into dmt_good ";
                                    ColMap.Clear();
                                    ColMap["seq"] = Util.dbchar(Request["FD2_seqb_" + x]);
                                    ColMap["seq1"] = Util.dbchar(Request["FD2_seq1b_" + x]);
                                    ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
                                    ColMap["in_no"] = Util.dbchar(Request["In_no"]);
                                    ColMap["class"] = Util.dbchar(Request["classb_" + x + "_" + p]);
                                    ColMap["dmt_goodname"] = Util.dbchar(Request["FD2_good_nameb_" + x + "_" + p]);
                                    ColMap["dmt_goodcount"] = Util.dbchar(Request["FD2_good_countb_" + x + "_" + p]);
                                    ColMap["tr_date"] = "getdate()";
                                    ColMap["tr_scode"] = "'" + Session["scode"] + "'";
                                    SQL += ColMap.GetInsertSQL();
                                    conn.ExecuteNonQuery(SQL);
                                }
                            }
                            //分割子案展覽優先權入檔
                            insert_dmt_show(Request["FD2_seqb_" + x], Request["FD2_seq1b_" + x]);
                            break;
                    }
                }
            } else if ((Request["tfy_arcase"] ?? "").IN("FC11,FC5,FC7,FCH")) {
                for (int x = subX; x <= Convert.ToInt32("0" + Request["nfy_tot_num"]); x++) {
                    //dmt入log檔
                    Sys.insert_log_table(conn, "U", prgid, "dmt_good", "seq;seq1", Request["dseqa_" + x] + ";" + Request["dseq1a_" + x], "Brt52國內交辦資料維護");
                    SQL = "UPDATE dmt_good SET ";
                    ColMap.Clear();
                    ColMap["in_scode"] = Util.dbnull(Request["F_tscode"]);
                    ColMap["tr_date"] = "getdate()";
                    ColMap["tr_scode"] = "'" + Session["scode"] + "'";
                    SQL += " where seq = '" + Request["dseqa_" + x] + "' and seq1 = '" + Request["dseq1a_" + x] + "'";
                    conn.ExecuteNonQuery(SQL);
                }
            } else if ((Request["tfy_arcase"] ?? "").IN("FT2,FL5,FL6,FC21,FC6,FC8,FCI")) {
                for (int x = subX; x <= Convert.ToInt32("0" + Request["nfy_tot_num"]); x++) {
                    //ndmt入log檔
                    Sys.insert_log_table(conn, "U", prgid, "dmt_good", "seq;seq1", Request["dseqb_" + x] + ";" + Request["dseq1b_" + x], "Brt52國內交辦資料維護");
                    SQL = "UPDATE dmt_good SET ";
                    ColMap.Clear();
                    ColMap["in_scode"] = Util.dbnull(Request["F_tscode"]);
                    ColMap["tr_date"] = "getdate()";
                    ColMap["tr_scode"] = "'" + Session["scode"] + "'";
                    SQL += " where seq = '" + Request["dseqb_" + x] + "' and seq1 = '" + Request["dseq1b_" + x] + "'";
                    conn.ExecuteNonQuery(SQL);
                }
            }

            insert_dmt_show(Request["tfzb_seq"], Request["tfzb_seq1"]);

            insert_dmt_ap();
        }
    }

    /// <summary>
    /// 展覽優先權資料(dmt_show)
    /// </summary>
    private void insert_dmt_show(string seq, string seq1) {
        for (int i = 1; i <= Convert.ToInt32("0" + Request["shownum_dmt"]); i++) {
            if ((Request["show_date_dmt_" + i] ?? "") != "" || (Request["show_name_dmt_" + i] ?? "") != "") {
                SQL = "insert into dmt_show ";
                ColMap.Clear();
                ColMap["seq"] = Util.dbchar(seq);
                ColMap["seq1"] = Util.dbchar(seq1);
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
    /// 寫入案件申請人檔(dmt_ap)
    /// </summary>
    private void insert_dmt_ap() {
        //案件主檔申請人log_table(主案)
        Sys.insert_log_table(conn, "U", prgid, "dmt_ap", "seq;seq1;branch", Request["tfzb_seq"] + ";" + Request["tfzb_seq1"] + ";" + Session["seBranch"], "");
        SQL = "Delete dmt_ap where seq='" + Request["tfzb_seq"] + "' and seq1='" + Request["tfzb_seq1"] + "' and branch='" + Session["seBranch"] + "'";
        conn.ExecuteNonQuery(SQL);
        for (int i = 1; i <= Convert.ToInt32(lapnum); i++) {
            SQL = "insert into dmt_ap ";
            ColMap.Clear();
            ColMap["branch"] = Util.dbchar(Sys.GetSession("seBranch"));
            ColMap["seq"] = Util.dbchar(Request["tfzb_seq"]);
            ColMap["seq1"] = Util.dbchar(Request["tfzb_seq1"]);
            if ((Request["tfy_arcase"] ?? "").IN("FC1,FC10,FC11,FC5,FC7,FC9,FCA,FCB,FCF,FCH")) {
                ColMap["apsqlno"] = Util.dbchar(Request["dbmn1_apsqlno_" + i]);
                ColMap["Server_flag"] = Util.dbchar(Request["fc2_ap_server_flag_" + i]);
                ColMap["apcust_no"] = Util.dbchar(Request["dbmn1_new_no_" + i]);
                ColMap["ap_cname"] = Util.dbchar(Request["dbmn1_ap_cname_" + i]);
                ColMap["ap_ename"] = Util.dbchar(Request["dbmn1_ap_ename_" + i]);
                ColMap["ap_fcname"] = Util.dbchar(Request["dbmn1_fcname_" + i]);
                ColMap["ap_lcname"] = Util.dbchar(Request["dbmn1_lcname_" + i]);
                ColMap["ap_fename"] = Util.dbchar(Request["dbmn1_fename_" + i]);
                ColMap["ap_lename"] = Util.dbchar(Request["dbmn1_lename_" + i]);
            } else if ((Request["tfy_arcase"] ?? "").IN("FC2,FC20,FC21,FC6,FC8,FC0,FCC,FCD,FCG,FCI")) {
                ColMap["apsqlno"] = Util.dbchar(Request["dbmn_apsqlno_" + i]);
                ColMap["Server_flag"] = Util.dbchar(Request["fc0_ap_server_flag_" + i]);
                ColMap["apcust_no"] = Util.dbchar(Request["dbmn_new_no_" + i]);
                ColMap["ap_cname"] = Util.dbchar(Request["dbmn_ap_cname_" + i]);
                ColMap["ap_ename"] = Util.dbchar(Request["dbmn_ap_ename_" + i]);
                ColMap["ap_fcname"] = Util.dbchar(Request["dbmn_fcname_" + i]);
                ColMap["ap_lcname"] = Util.dbchar(Request["dbmn_lcname_" + i]);
                ColMap["ap_fename"] = Util.dbchar(Request["dbmn_fename_" + i]);
                ColMap["ap_lename"] = Util.dbchar(Request["dbmn_lename_" + i]);
            } else {
                ColMap["apsqlno"] = Util.dbchar(Request["apsqlno_" + i]);
                ColMap["Server_flag"] = Util.dbchar(Request["ap_server_flag_" + i]);
                ColMap["apcust_no"] = Util.dbchar(Request["apcust_no_" + i]);
                ColMap["ap_cname"] = Util.dbchar(Request["ap_cname_" + i]);
                ColMap["ap_ename"] = Util.dbchar(Request["ap_ename_" + i]);
                ColMap["ap_fcname"] = Util.dbchar(Request["ap_fcname_" + i]);
                ColMap["ap_lcname"] = Util.dbchar(Request["ap_lcname_" + i]);
                ColMap["ap_fename"] = Util.dbchar(Request["ap_fename_" + i]);
                ColMap["ap_lename"] = Util.dbchar(Request["ap_lename_" + i]);
            }
            ColMap["tran_date"] = "getdate()";
            ColMap["tran_scode"] = "'" + Session["scode"] + "'";
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

        //修改子案案件申請人檔
        for (int x = subX; x <= Convert.ToInt32("0" + Request["nfy_tot_num"]); x++) {
            if ((Request["ar_form"] ?? "") == "A5") {
                switch ((Request["tfy_arcase"] ?? "").Left(3)) {
                    case "FD1":
                        Sys.insert_log_table(conn, "U", prgid, "dmt_ap", "seq;seq1;branch", Request["FD1_seqa_" + x] + ";" + Request["FD1_seq1a_" + x] + ";" + Session["seBranch"], "");
                        SQL = "Delete dmt_ap where seq='" + Request["FD1_seqa_" + x] + "' and seq1='" + Request["FD1_seq1a_" + x] + "' and branch='" + Session["seBranch"] + "'";
                        conn.ExecuteNonQuery(SQL);
                        break;
                    case "FD2":
                    case "FD3":
                        Sys.insert_log_table(conn, "U", prgid, "dmt_ap", "seq;seq1;branch", Request["FD2_seqb_" + x] + ";" + Request["FD2_seq1b_" + x] + ";" + Session["seBranch"], "");
                        SQL = "Delete dmt_ap where seq='" + Request["FD2_seqb_" + x] + "' and seq1='" + Request["FD2_seq1b_" + x] + "' and branch='" + Session["seBranch"] + "'";
                        conn.ExecuteNonQuery(SQL);
                        break;
                }
                for (int i = 1; i <= Convert.ToInt32(lapnum); i++) {
                    SQL = "insert into dmt_ap ";
                    ColMap.Clear();
                    ColMap["branch"] = Util.dbchar(Sys.GetSession("seBranch"));
                    if ((Request["tfy_arcase"] ?? "").Left(3) == "FD1") {
                        ColMap["seq"] = Util.dbchar(Request["FD1_seqa_" + x]);
                        ColMap["seq1"] = Util.dbchar(Request["FD1_seq1a_" + x]);
                    } else if ((Request["tfy_arcase"] ?? "").Left(3).IN("FD2,FD3")) {
                        ColMap["seq"] = Util.dbchar(Request["FD2_seqb_" + x]);
                        ColMap["seq1"] = Util.dbchar(Request["FD2_seq1b_" + x]);
                    }
                    ColMap["apsqlno"] = Util.dbchar(Request["apsqlno_" + i]);
                    ColMap["Server_flag"] = Util.dbchar(Request["ap_server_flag_" + i]);
                    ColMap["apcust_no"] = Util.dbchar(Request["apcust_no_" + i]);
                    ColMap["ap_cname"] = Util.dbchar(Request["dbmn1_ap_cname_" + i]);
                    ColMap["ap_ename"] = Util.dbchar(Request["dbmn1_ap_ename_" + i]);
                    ColMap["tran_date"] = "getdate()";
                    ColMap["tran_scode"] = "'" + Session["scode"] + "'";
                    ColMap["ap_fcname"] = Util.dbchar(Request["ap_fcname_" + i]);
                    ColMap["ap_lcname"] = Util.dbchar(Request["ap_lcname_" + i]);
                    ColMap["ap_fename"] = Util.dbchar(Request["ap_fename_" + i]);
                    ColMap["ap_lename"] = Util.dbchar(Request["ap_lename_" + i]);
                    SQL += ColMap.GetInsertSQL();
                    conn.ExecuteNonQuery(SQL);
                }
            } else if ((Request["tfy_arcase"] ?? "").IN("FC11,FC5,FC7,FCH")) {
                Sys.insert_log_table(conn, "U", prgid, "dmt_ap", "seq;seq1;branch", Request["dseqa_" + x] + ";" + Request["dseq1a_" + x] + ";" + Session["seBranch"], "");
                SQL = "Delete dmt_ap where seq='" + Request["dseqa_" + x] + "' and seq1='" + Request["dseq1a_" + x] + "' and branch='" + Session["seBranch"] + "'";
                conn.ExecuteNonQuery(SQL);
                for (int i = 1; i <= Convert.ToInt32(lapnum); i++) {
                    SQL = "insert into dmt_ap ";
                    ColMap.Clear();
                    ColMap["branch"] = Util.dbchar(Sys.GetSession("seBranch"));
                    ColMap["seq"] = Util.dbchar(Request["dseqa_" + x]);
                    ColMap["seq1"] = Util.dbchar(Request["dseq1a_" + x]);
                    ColMap["apsqlno"] = Util.dbchar(Request["dbmn1_apsqlno_" + i]);
                    ColMap["Server_flag"] = Util.dbchar(Request["fc2_ap_server_flag_" + i]);
                    ColMap["apcust_no"] = Util.dbchar(Request["dbmn1_new_no_" + i]);
                    ColMap["ap_cname"] = Util.dbchar(Request["dbmn1_ap_cname_" + i]);
                    ColMap["ap_ename"] = Util.dbchar(Request["dbmn1_ap_ename_" + i]);
                    ColMap["tran_date"] = "getdate()";
                    ColMap["tran_scode"] = "'" + Session["scode"] + "'";
                    ColMap["ap_fcname"] = Util.dbchar(Request["dbmn1_fcname_" + i]);
                    ColMap["ap_lcname"] = Util.dbchar(Request["dbmn1_lcname_" + i]);
                    ColMap["ap_fename"] = Util.dbchar(Request["dbmn1_fename_" + i]);
                    ColMap["ap_lename"] = Util.dbchar(Request["dbmn1_lename_" + i]);
                    ColMap["ap_sql"] = Util.dbchar(Request["dbmn1_ap_sql_" + i]);
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
            } else if ((Request["tfy_arcase"] ?? "").IN("FT2,FC21,FC6,FC8,FCI")) {
                Sys.insert_log_table(conn, "U", prgid, "dmt_ap", "seq;seq1;branch", Request["dseqb_" + x] + ";" + Request["dseq1b_" + x] + ";" + Session["seBranch"], "");
                SQL = "Delete dmt_ap where seq='" + Request["dseqb_" + x] + "' and seq1='" + Request["dseq1b_" + x] + "' and branch='" + Session["seBranch"] + "'";
                conn.ExecuteNonQuery(SQL);
                for (int i = 1; i <= Convert.ToInt32(lapnum); i++) {
                    SQL = "insert into dmt_ap ";
                    ColMap.Clear();
                    ColMap["branch"] = Util.dbchar(Sys.GetSession("seBranch"));
                    ColMap["seq"] = Util.dbchar(Request["dseqb_" + x]);
                    ColMap["seq1"] = Util.dbchar(Request["dseq1b_" + x]);
                    ColMap["apsqlno"] = Util.dbchar(Request["dbmn_apsqlno_" + i]);
                    ColMap["Server_flag"] = Util.dbchar(Request["fc0_ap_server_flag_" + i]);
                    ColMap["apcust_no"] = Util.dbchar(Request["dbmn_new_no_" + i]);
                    ColMap["ap_cname"] = Util.dbchar(Request["dbmn_ap_cname_" + i]);
                    ColMap["ap_ename"] = Util.dbchar(Request["dbmn_ap_ename_" + i]);
                    ColMap["tran_date"] = "getdate()";
                    ColMap["tran_scode"] = "'" + Session["scode"] + "'";
                    ColMap["ap_fcname"] = Util.dbchar(Request["dbmn_fcname_" + i]);
                    ColMap["ap_lcname"] = Util.dbchar(Request["dbmn_lcname_" + i]);
                    ColMap["ap_fename"] = Util.dbchar(Request["dbmn_fename_" + i]);
                    ColMap["ap_lename"] = Util.dbchar(Request["dbmn_lename_" + i]);
                    ColMap["ap_sql"] = Util.dbchar(Request["dbmn_ap_sql_" + i]);
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
            } else if ((Request["tfy_arcase"] ?? "").IN("FL5,FL6")) {
                if (Request["case_stat1b_" + x] == "NN") {
                    Sys.insert_log_table(conn, "U", prgid, "dmt_ap", "seq;seq1;branch", Request["dseqb_" + x] + ";" + Request["dseq1b_" + x] + ";" + Session["seBranch"], "");
                    SQL = "Delete dmt_ap where seq='" + Request["dseqb_" + x] + "' and seq1='" + Request["dseq1b_" + x] + "' and branch='" + Session["seBranch"] + "'";
                    conn.ExecuteNonQuery(SQL);
                    for (int i = 1; i <= Convert.ToInt32(lapnum); i++) {
                        SQL = "insert into dmt_ap ";
                        ColMap.Clear();
                        ColMap["branch"] = Util.dbchar(Sys.GetSession("seBranch"));
                        ColMap["seq"] = Util.dbchar(Request["dseqb_" + x]);
                        ColMap["seq1"] = Util.dbchar(Request["dseq1b_" + x]);
                        ColMap["apsqlno"] = Util.dbchar(Request["dbmn_apsqlno_" + i]);
                        ColMap["Server_flag"] = Util.dbchar(Request["fc0_ap_server_flag_" + i]);
                        ColMap["apcust_no"] = Util.dbchar(Request["dbmn_new_no_" + i]);
                        ColMap["ap_cname"] = Util.dbchar(Request["dbmn_ap_cname_" + i]);
                        ColMap["ap_ename"] = Util.dbchar(Request["dbmn_ap_ename_" + i]);
                        ColMap["tran_date"] = "getdate()";
                        ColMap["tran_scode"] = "'" + Session["scode"] + "'";
                        ColMap["ap_fcname"] = Util.dbchar(Request["dbmn_fcname_" + i]);
                        ColMap["ap_lcname"] = Util.dbchar(Request["dbmn_lcname_" + i]);
                        ColMap["ap_fename"] = Util.dbchar(Request["dbmn_fename_" + i]);
                        ColMap["ap_lename"] = Util.dbchar(Request["dbmn_lename_" + i]);
                        ColMap["ap_sql"] = Util.dbchar(Request["dbmn_ap_sql_" + i]);
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
            }
        }

        /////////////////////////////////////////////////////////////////////
        //案件主檔申請人log_table(主案)
        Sys.insert_log_table(conn, "U", prgid, "dmt_ap", "seq;seq1;branch", Request["tfzb_seq"] + ";" + Request["tfzb_seq1"] + ";" + Session["seBranch"], "");
        SQL = "Delete dmt_ap where seq='" + Request["tfzb_seq"] + "' and seq1='" + Request["tfzb_seq1"] + "' and branch='" + Session["seBranch"] + "'";
        conn.ExecuteNonQuery(SQL);
        if ((Request["tfy_arcase"] ?? "").IN("FC1,FC10,FC11,FC5,FC7,FC9,FCA,FCB,FCF,FCH")) {
            insert_dmt_ap_FC2(Request["tfzb_seq"], Request["tfzb_seq1"]);
        } else if ((Request["tfy_arcase"] ?? "").IN("FC2,FC20,FC21,FC6,FC8,FC0,FCC,FCD,FCG,FCI")) {
            insert_dmt_ap_FC0(Request["tfzb_seq"], Request["tfzb_seq1"]);
        } else {
            insert_dmt_ap_ap0(Request["tfzb_seq"], Request["tfzb_seq1"]);
        }

        //修改子案案件申請人檔
        for (int x = subX; x <= Convert.ToInt32("0" + Request["nfy_tot_num"]); x++) {
            if ((Request["ar_form"] ?? "") == "A5") {
                if ((Request["tfy_arcase"] ?? "").Left(3) == "FD1") {
                    Sys.insert_log_table(conn, "U", prgid, "dmt_ap", "seq;seq1;branch", Request["FD1_seqa_" + x] + ";" + Request["FD1_seq1a_" + x] + ";" + Session["seBranch"], "");
                    SQL = "Delete dmt_ap where seq='" + Request["FD1_seqa_" + x] + "' and seq1='" + Request["FD1_seq1a_" + x] + "' and branch='" + Session["seBranch"] + "'";
                    conn.ExecuteNonQuery(SQL);

                    insert_dmt_ap_FC2(Request["FD1_seqa_" + x], Request["FD1_seq1a_" + x]);
                } else if ((Request["tfy_arcase"] ?? "").Left(3).IN("FD2,FD3")) {
                    Sys.insert_log_table(conn, "U", prgid, "dmt_ap", "seq;seq1;branch", Request["FD2_seqb_" + x] + ";" + Request["FD2_seq1b_" + x] + ";" + Session["seBranch"], "");
                    SQL = "Delete dmt_ap where seq='" + Request["FD2_seqb_" + x] + "' and seq1='" + Request["FD2_seq1b_" + x] + "' and branch='" + Session["seBranch"] + "'";
                    conn.ExecuteNonQuery(SQL);

                    insert_dmt_ap_FC2(Request["FD2_seqb_" + x], Request["FD2_seq1b_" + x]);
                }
            } else if ((Request["tfy_arcase"] ?? "").IN("FC11,FC5,FC7,FCH")) {
                Sys.insert_log_table(conn, "U", prgid, "dmt_ap", "seq;seq1;branch", Request["dseqa_" + x] + ";" + Request["dseq1a_" + x] + ";" + Session["seBranch"], "");
                SQL = "Delete dmt_ap where seq='" + Request["dseqa_" + x] + "' and seq1='" + Request["dseq1a_" + x] + "' and branch='" + Session["seBranch"] + "'";
                conn.ExecuteNonQuery(SQL);

                insert_dmt_ap_FC2(Request["dseqa_" + x], Request["dseq1a_" + x]);
            } else if ((Request["tfy_arcase"] ?? "").IN("FT2,FC21,FC6,FC8,FCI")) {
                Sys.insert_log_table(conn, "U", prgid, "dmt_ap", "seq;seq1;branch", Request["dseqb_" + x] + ";" + Request["dseq1b_" + x] + ";" + Session["seBranch"], "");
                SQL = "Delete dmt_ap where seq='" + Request["dseqb_" + x] + "' and seq1='" + Request["dseq1b_" + x] + "' and branch='" + Session["seBranch"] + "'";
                conn.ExecuteNonQuery(SQL);

                insert_dmt_ap_FC0(Request["dseqb_" + x], Request["dseq1b_" + x]);
            } else if ((Request["tfy_arcase"] ?? "").IN("FL5,FL6")) {
                if (Request["case_stat1b_" + x] == "NN") {
                    Sys.insert_log_table(conn, "U", prgid, "dmt_ap", "seq;seq1;branch", Request["dseqb_" + x] + ";" + Request["dseq1b_" + x] + ";" + Session["seBranch"], "");
                    SQL = "Delete dmt_ap where seq='" + Request["dseqb_" + x] + "' and seq1='" + Request["dseq1b_" + x] + "' and branch='" + Session["seBranch"] + "'";
                    conn.ExecuteNonQuery(SQL);

                    insert_dmt_ap_FC0(Request["dseqb_" + x], Request["dseq1b_" + x]);
                }
            }
        }
    }
    
    /// <summary>
    /// 寫入案件申請人檔(dmt_ap)(Apcust_form)
    /// </summary>
    private void insert_dmt_ap_ap0(string seq,string seq1) {
        for (int i = 1; i <= Convert.ToInt32("0" + Request["apnum"]); i++) {
            SQL = "insert into dmt_ap ";
            ColMap.Clear();
            ColMap["branch"] = Util.dbchar(Sys.GetSession("seBranch"));
            ColMap["seq"] = Util.dbchar(seq);
            ColMap["seq1"] = Util.dbchar(seq1);
            ColMap["apsqlno"] = Util.dbchar(Request["apsqlno_" + i]);
            ColMap["Server_flag"] = Util.dbchar(Request["ap_server_flag_" + i]);
            ColMap["apcust_no"] = Util.dbchar(Request["apcust_no_" + i]);
            ColMap["ap_cname"] = Util.dbchar(Request["ap_cname_" + i]);
            ColMap["ap_ename"] = Util.dbchar(Request["ap_ename_" + i]);
            ColMap["ap_fcname"] = Util.dbchar(Request["ap_fcname_" + i]);
            ColMap["ap_lcname"] = Util.dbchar(Request["ap_lcname_" + i]);
            ColMap["ap_fename"] = Util.dbchar(Request["ap_fename_" + i]);
            ColMap["ap_lename"] = Util.dbchar(Request["ap_lename_" + i]);
            ColMap["tran_date"] = "getdate()";
            ColMap["tran_scode"] = "'" + Session["scode"] + "'";
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
    /// 寫入案件申請人檔(dmt_ap)(Apcust_FC_RE_form)
    /// </summary>
    private void insert_dmt_ap_FC0(string seq, string seq1) {
        for (int i = 1; i <= Convert.ToInt32("0" + Request["FC0_apnum"]); i++) {
            SQL = "insert into dmt_ap ";
            ColMap.Clear();
            ColMap["branch"] = Util.dbchar(Sys.GetSession("seBranch"));
            ColMap["seq"] = Util.dbchar(seq);
            ColMap["seq1"] = Util.dbchar(seq1);
            ColMap["apsqlno"] = Util.dbchar(Request["dbmn_apsqlno_" + i]);
            ColMap["Server_flag"] = Util.dbchar(Request["fc0_ap_server_flag_" + i]);
            ColMap["apcust_no"] = Util.dbchar(Request["dbmn_new_no_" + i]);
            ColMap["ap_cname"] = Util.dbchar(Request["dbmn_ap_cname_" + i]);
            ColMap["ap_ename"] = Util.dbchar(Request["dbmn_ap_ename_" + i]);
            ColMap["ap_fcname"] = Util.dbchar(Request["dbmn_fcname_" + i]);
            ColMap["ap_lcname"] = Util.dbchar(Request["dbmn_lcname_" + i]);
            ColMap["ap_fename"] = Util.dbchar(Request["dbmn_fename_" + i]);
            ColMap["ap_lename"] = Util.dbchar(Request["dbmn_lename_" + i]);
            ColMap["tran_date"] = "getdate()";
            ColMap["tran_scode"] = "'" + Session["scode"] + "'";
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
    /// 寫入案件申請人檔(dmt_ap)(Apcust_FC_RE1_form)
    /// </summary>
    private void insert_dmt_ap_FC2(string seq, string seq1) {
        for (int i = 1; i <= Convert.ToInt32("0" + Request["FC2_apnum"]); i++) {
            SQL = "insert into dmt_ap ";
            ColMap.Clear();
            ColMap["branch"] = Util.dbchar(Sys.GetSession("seBranch"));
            ColMap["seq"] = Util.dbchar(seq);
            ColMap["seq1"] = Util.dbchar(seq1);
            ColMap["apsqlno"] = Util.dbchar(Request["dbmn1_apsqlno_" + i]);
            ColMap["Server_flag"] = Util.dbchar(Request["fc2_ap_server_flag_" + i]);
            ColMap["apcust_no"] = Util.dbchar(Request["dbmn1_new_no_" + i]);
            ColMap["ap_cname"] = Util.dbchar(Request["dbmn1_ap_cname_" + i]);
            ColMap["ap_ename"] = Util.dbchar(Request["dbmn1_ap_ename_" + i]);
            ColMap["ap_fcname"] = Util.dbchar(Request["dbmn1_fcname_" + i]);
            ColMap["ap_lcname"] = Util.dbchar(Request["dbmn1_lcname_" + i]);
            ColMap["ap_fename"] = Util.dbchar(Request["dbmn1_fename_" + i]);
            ColMap["ap_lename"] = Util.dbchar(Request["dbmn1_lename_" + i]);
            ColMap["tran_date"] = "getdate()";
            ColMap["tran_scode"] = "'" + Session["scode"] + "'";
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
    /// 修改洽案營洽資料要update的table
    /// </summary>
    private void update_in_scode() {
        //修改洽案營洽資料要update的table(case_dmt,dmt_temp,caseitem_dmt,dmt_tran,dmt_tranlist,ndmt)
        if (ReqVal.TryGet("in_scode") != ReqVal.TryGet("F_tscode")) {
            SQL = "update caseitem_dmt set in_scode='" + ReqVal.TryGet("F_tscode").Trim() + "' where in_no='" + ReqVal.TryGet("in_no") + "'";
            conn.ExecuteNonQuery(SQL);
        }
    }
    
    /// <summary>
    /// 記錄log
    /// </summary>
    private void insert_rec_log() {
        string note = "";
        if (ReqVal.TryGet("update_dmt") == "dmt") {
            note = "修改洽案資料_" + ReqVal.TryGet("in_scode").Trim() + "-" + ReqVal.TryGet("in_no").Trim() + ";本所編號:" + Request["tfzb_seq"] + "-" + Request["tfzb_seq1"] + ";";
            //共同申請人
            for (int i = 1; i <= Convert.ToInt32(lapnum); i++) {
                if (ReqVal.TryGet(ofield_ap + i) != ReqVal.TryGet(field_ap + i)) {
                    note += "原申請人Oapcust_no" + i + "::" + ReqVal.TryGet(ofield_ap + i).Trim() + ";";
                }
            }
        } else {
            note = "修改洽案資料_" + ReqVal.TryGet("in_scode").Trim() + "-" + ReqVal.TryGet("in_no").Trim() + ";";
            //共同申請人
            for (int i = 1; i <= Convert.ToInt32(lapnum); i++) {
                if (ReqVal.TryGet(ofield_ap + i) != ReqVal.TryGet(field_ap + i)) {
                    note += "原申請人Oapcust_no" + i + ":" + ReqVal.TryGet(ofield_ap + i).Trim() + ";";
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
        if (ReqVal.TryGet("O_cust_seq") != ReqVal.TryGet("tfy_cust_seq")) {
            string note1 = "";
            if ((Request["tfy_arcase"] ?? "").IN("FC11,FC5,FC7,FCH")) {
                for (int i = subX; i <= Convert.ToInt32("0" + Request["nfy_tot_num"]); i++) {
                    note1 += ReqVal.TryGet("dseqa_" + i).Trim() + "-" + ReqVal.TryGet("dseq1a_" + i).Trim() + ",";
                }
                note += "一件多件變更" + "客戶" + "本所編號:" + note1;
            } else if ((Request["tfy_arcase"] ?? "").IN("FC21,FC6,FC8,FCI")) {
                for (int i = subX; i <= Convert.ToInt32("0" + Request["nfy_tot_num"]); i++) {
                    note1 += ReqVal.TryGet("dseqb_" + i).Trim() + "-" + ReqVal.TryGet("dseq1b_" + i).Trim() + ",";
                }
                note += "一件多件變更" + "客戶" + "本所編號:" + note1;
            }
        }
        SQL += "'" + Session["scode"] + "',getdate(),'" + note + "')";
        conn.ExecuteNonQuery(SQL);
    }
    
    /// <summary>
    /// 重建暫存檔(一案多件)
    /// </summary>
    private void rebuil_change(string mark) {
        using (DBHelper conn1 = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST")) {
            SQL = "delete from dmt_temp_change where in_scode='" + Request["F_tscode"] + "' and cust_area='" + Request["F_cust_area"] + "' and cust_seq='" + Request["F_cust_seq"] + "' and mark='" + mark + "'";
            conn1.ExecuteNonQuery(SQL);
            SQL = "delete from casedmt_good_change where in_scode='" + Request["F_tscode"] + "' and cust_area='" + Request["F_cust_area"] + "' and cust_seq='" + Request["F_cust_seq"] + "' and mark='" + mark + "'";
            conn1.ExecuteNonQuery(SQL);
            SQL = "delete from casedmt_show_change where in_scode='" + Request["F_tscode"] + "' and cust_area='" + Request["F_cust_area"] + "' and cust_seq='" + Request["F_cust_seq"] + "' and mark='" + mark + "'";
            conn1.ExecuteNonQuery(SQL);

            DataTable dt = new DataTable();
            SQL = "select * from case_dmt1 where in_no= '" + Request["in_no"] + "'";
            conn1.DataTable(SQL, dt);
            for (int i = 0; i < dt.Rows.Count; i++) {
                SQL = "insert into dmt_temp_change(s_mark,s_mark2,pul,appl_name,cappl_name,eappl_name";
                SQL += ",eappl_name1,eappl_name2,jappl_name,jappl_name1,jappl_name2,zappl_name1 ";
                SQL += ",zappl_name2,zname_type,oappl_name,Draw,symbol,color,prior_date,prior_no ";
                SQL += ",prior_country,ref_no,ref_no1,tcn_ref,tcn_class,tcn_name,tcn_mark ";
                SQL += ",apply_date,apply_no,issue_date,issue_no,open_date,rej_no,end_date ";
                SQL += ",end_code,dmt_term1,dmt_term2,renewal,seq,seq1,draw_file,class_type ";
                SQL += ",class_count,class ";
                SQL += ",in_scode,cust_area,cust_seq,num,tr_date,tr_scode,mark) ";
                SQL += "Select s_mark,s_mark2 as ts_mark,pul,appl_name,cappl_name,eappl_name ";
                SQL += ",eappl_name1,eappl_name2,jappl_name,jappl_name1,jappl_name2,zappl_name1 ";
                SQL += ",zappl_name2,zname_type,oappl_name,Draw,symbol,color,prior_date,prior_no ";
                SQL += ",prior_country,ref_no,ref_no1,tcn_ref,tcn_class,tcn_name,tcn_mark ";
                SQL += ",apply_date,apply_no,issue_date,issue_no,open_date,rej_no,end_date ";
                SQL += ",end_code,dmt_term1,dmt_term2,renewal,seq,seq1,draw_file,class_type ";
                SQL += ",class_count,class ";
                SQL += ",'" + Request["F_tscode"] + "','" + Request["F_cust_area"] + "','" + Request["F_cust_seq"] + "','" + (i + 1) + "' ";
                SQL += ",getdate(),'" + Session["scode"] + "','" + mark + "' ";
                SQL += "from dmt_temp where in_no='" + Request["in_no"] + "' and case_sqlno=" + dt.Rows[i]["case_sqlno"] + "";
                conn1.ExecuteNonQuery(SQL);

                SQL = "INSERT INTO casedmt_good_change(in_scode,cust_area,cust_seq,num,class,dmt_grp_code";
                SQL += ",dmt_goodname,dmt_goodcount,tr_date,tr_scode,mark) ";
                SQL += "select '" + Request["F_tscode"] + "','" + Request["F_cust_area"] + "','" + Request["F_cust_seq"] + "','" + (i + 1) + "'";
                SQL += ",class,dmt_grp_code,dmt_goodname,dmt_goodcount,getdate(),'" + Session["scode"] + "','" + mark + "' ";
                SQL += "from casedmt_good where in_no='" + Request["in_no"] + "' and case_sqlno=" + dt.Rows[i]["case_sqlno"] + "";
                conn1.ExecuteNonQuery(SQL);

                SQL = "INSERT INTO casedmt_show_change(in_scode,cust_area,cust_seq,num,show_no,show_date";
                SQL += ",show_name,tr_date,tr_scode,mark) ";
                SQL += "select '" + Request["F_tscode"] + "','" + Request["F_cust_area"] + "','" + Request["F_cust_seq"] + "','" + (i + 1) + "'";
                SQL += ",ROW_NUMBER() OVER(ORDER BY show_sqlno),show_date,show_name,getdate()";
                SQL += ",'" + Session["scode"] + "','" + mark + "' ";
                SQL += "from casedmt_show where in_no='" + Request["in_no"] + "' and case_sqlno=" + dt.Rows[i]["case_sqlno"] + " order by show_sqlno";
                conn1.ExecuteNonQuery(SQL);
            }
            conn1.Commit();
        }
    }
    
    /// <summary>
    /// 註冊費
    /// </summary>
    private void editA3( string RSno) {
    }
    
    /// <summary>
    /// 延展
    /// </summary>
    private void editA4( string RSno) {
    }
    
    /// <summary>
    /// 分割
    /// </summary>
    private void editA5( string RSno) {
    }
    
    /// <summary>
    /// 變更
    /// </summary>
    private void editA6( string RSno) {
    }
    
    /// <summary>
    /// 授權
    /// </summary>
    private void editA7( string RSno) {
    }
    
    /// <summary>
    /// 移轉
    /// </summary>
    private void editA8( string RSno) {
    }
    
    /// <summary>
    /// 質權
    /// </summary>
    private void editA9( string RSno) {
    }
    
    /// <summary>
    /// 質權
    /// </summary>
    private void editAA( string RSno) {
    }
    
    /// <summary>
    /// 補(換)發證
    /// </summary>
    private void editAB( string RSno) {
    }
    
    /// <summary>
    /// 閱案
    /// </summary>
    private void editAC( string RSno) {
    }
    
    /// <summary>
    /// 爭議案
    /// </summary>
    private void editB( string RSno) {
    }
    
    /// <summary>
    /// 其他
    /// </summary>
    private void editZZ( string RSno) {
    }
</script>

<%Response.Write(strOut.ToString());%>
