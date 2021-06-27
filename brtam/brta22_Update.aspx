<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>

<script runat="server">
    protected string HTProgCap = "國內案客戶收文作業-入檔";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "brta22";//HttpContext.Current.Request["prgid"] ?? "";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";

    protected string submitTask = "";
    protected string SQL = "";
    protected object objResult = null;

    protected string logReason = "Brta22國內案客收維護作業";
    protected string fseq = "", rs_no = "";
    
    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected Dictionary<string, string> ColMap = new Dictionary<string, string>();

    protected StringBuilder strOut = new StringBuilder();

    DBHelper conn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    private void Page_Unload(System.Object sender, System.EventArgs e) {
        if (conn != null) conn.Dispose();
    }

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");
        conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");

        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        HTProgCap = myToken.Title;
        DebugStr = myToken.DebugStr;
        if (HTProgRight >= 0) {
            try {
                if (ReqVal.TryGet("submittask") == "A") {
                    doAdd();
                    strOut.AppendLine("<div align='center'><h1>客戶收文新增成功!!!發文序號:(" + rs_no + ")</h1></div>");
                } else if (ReqVal.TryGet("submittask") == "U") {
                    doUpdate();
                    strOut.AppendLine("<div align='center'><h1>客戶收文維護成功!!!發文序號:(" + rs_no + ")</h1></div>");
                } else if (ReqVal.TryGet("submittask") == "D") {
                    doDel();
                    strOut.AppendLine("<div align='center'><h1>客戶收文刪除成功!!!發文序號:(" + rs_no + ")</h1></div>");
                }
                conn.Commit();
                //conn.RollBack();
            }
            catch (Exception ex) {
                conn.RollBack();
                Sys.errorLog(ex, conn.exeSQL, prgid);
                throw;
            }
            this.DataBind();
        }
    }

    //新增
    private void doAdd() {
    }

    //維護
    private void doUpdate() {
        rs_no = ReqVal.TryGet("rs_no");
        //新增 step_dmt_Log 檔
        Sys.insert_log_table(conn, "U", prgid, "step_dmt", "rs_no", Request["rs_no"], logReason);

        //有異動過,才可以更改案件主檔的資料
        if (Request["change"] == "C") {
            Sys.insert_log_table(conn, "U", prgid, "dmt", "seq;seq1", Request["seq"] + ";" + Request["seq1"], logReason);
            
            //若案件主檔案件狀態進度序號小於等於進度序號，則修改案件狀態
            SQL = "select isnull(now_grade,0) as now_grade from dmt where seq=" + Request["seq"] + " and seq1='" + Request["seq1"] + "'";
            objResult = conn.ExecuteScalar(SQL);
            string now_grade0 = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();

            SQL = " update dmt set seq = seq ";
            if (Request["nstep_grade"] == "1") {
                SQL += " ,arcase_type = " + Util.dbnull(Request["rs_type"]);
                SQL += " ,arcase = " + Util.dbzero(Request["rs_code"]);
                SQL += " ,arcase_class = " + Util.dbzero(Request["rs_class"]);
            }

            //案件主檔now_arcase,now_grade,now_stat
            if (Convert.ToInt32(Request["nstep_grade"]) >= Convert.ToInt32(now_grade0)) {
                if (Request["ncase_stat"] != "") {
                    SQL += ",now_arcase_type=" + Util.dbnull(Request["rs_type"]);
                    SQL += ",now_arcase=" + Util.dbchar(Request["rs_code"]);
                    SQL += ",now_stat=" + Util.dbchar(Request["ncase_stat"]);
                    SQL += ",now_grade=" + Util.dbzero(Request["nstep_grade"]);
                    SQL += ",now_arcase_class=" + Util.dbchar(Request["rs_class"]);
                    SQL += ",now_act_code=" + Util.dbchar(Request["act_code"]);
                    SQL += " where seq = " + Request["seq"] + " and seq1='" + Request["seq1"] + "'";
                    conn.ExecuteNonQuery(SQL);
                } else {
                    //若本次收文案件狀態為 empty 且案件主檔案件狀態進度序號等於本次進度
                    //則需找到之前最後一筆的案件狀態且 Update 案件主檔
                    if (Convert.ToInt32(now_grade0) >= Convert.ToInt32(Request["nstep_grade"])) {
                        string SQL1 = "select * from vstep_dmt a, vcode_act b";
                        SQL1 += " where a.seq = " + Request["seq"];
                        SQL1 += "   and a.seq1 = '" + Request["seq1"] + "'";
                        SQL1 += "   and a.rs_no <> '" + rs_no + "'";
                        SQL1 += "   and a.rs_type = b.rs_type ";
                        SQL1 += "   and a.rs_class = b.rs_class ";
                        SQL1 += "   and a.rs_code = b.rs_code ";
                        SQL1 += "   and a.act_code = b.act_code ";
                        SQL1 += "   and b.cg = a.cg ";
                        SQL1 += "   and b.rs = a.rs ";
                        SQL1 += "   and b.case_stat is not null ";
                        SQL1 += " order by step_grade desc";
                        string now_arcase_type = "", now_arcase = "", now_stat = "", now_grade = "", now_arcase_class = "", now_act_code = "";
                        using (SqlDataReader dr = conn.ExecuteReader(SQL1)) {
                            if (dr.Read()) {
                                now_arcase_type = dr.SafeRead("rs_type", "");
                                now_arcase = dr.SafeRead("rs_code", "");
                                now_stat = dr.SafeRead("case_stat", "");
                                now_grade = dr.SafeRead("step_grade", "");
                                now_arcase_class = dr.SafeRead("rs_class", "");
                                now_act_code = dr.SafeRead("act_code", "");
                            }
                        }
                        SQL += " ,now_arcase_type = " + Util.dbnull(now_arcase_type);
                        SQL += " ,now_arcase = " + Util.dbnull(now_arcase);
                        SQL += " ,now_stat = " + Util.dbnull(now_stat);
                        SQL += " ,now_grade = " + Util.dbnull(now_grade);
                        SQL += " ,now_arcase_class = " + Util.dbnull(now_arcase_class);
                        SQL += " ,now_act_code = " + Util.dbnull(now_act_code);
                        SQL += " where seq = " + Request["seq"] + " and seq1='" + Request["seq1"] + "'";
                        conn.ExecuteNonQuery(SQL);
                    }
                }
            }
        }

        //修改 step_dmt
        SQL = "update step_dmt set ";
        ColMap.Clear();
        ColMap["step_date"] = Util.dbnull(Request["step_date"]);
        ColMap["receive_no"] = Util.dbnull(Request["receive_no"]);
        ColMap["rs_class"] = Util.dbnull(Request["rs_class"]);
        ColMap["rs_code"] = Util.dbchar(Request["rs_code"]);
        ColMap["rs_detail"] = Util.dbnull(Request["rs_detail"]);
        ColMap["doc_detail"] = Util.dbnull(Request["doc_detail"]);
        ColMap["send_sel"] = Util.dbnull(Request["send_sel"]);
        ColMap["pr_status"] = Util.dbchar(ReqVal.TryGet("pr_scode") != "" ? "N" : "X");
        ColMap["pr_scode"] = Util.dbnull(Request["pr_scode"]);
        if (Request["codemark"] == "B") {//爭救案需註記爭救案處理狀態
            ColMap["opt_stat"] = Util.dbchar(Request["opt_stat"]);
        }
        //有異動案性才會影響發文方式是否為電子送件
        if (Request["change"] == "C" || ReqVal.TryGet("send_way") != ReqVal.TryGet("old_send_way")) {
            ColMap["send_way"] = Util.dbnull(Request["send_way"]);
        }
        ColMap["tran_date"] = "getdate()";
        ColMap["tran_scode"] = "'" + Session["scode"] + "'";
        SQL += ColMap.GetUpdateSQL();
        SQL += " where rs_no = '" + Request["rs_no"] + "'";
        conn.ExecuteNonQuery(SQL);

        //20160923 修改發方式時,同步update case_dmt,case_dmt_log
        if (ReqVal.TryGet("send_way") != ReqVal.TryGet("old_send_way")
            || ReqVal.TryGet("receipt_type") != ReqVal.TryGet("old_receipt_type")
            || ReqVal.TryGet("receipt_title") != ReqVal.TryGet("old_receipt_title")) {
            Sys.insert_log_table(conn, "U", prgid, "case_dmt", "in_scode;in_no", Request["in_scode"] + ";" + Request["in_no"], logReason);
            SQL = "update case_dmt set ";
            ColMap.Clear();
            ColMap["send_way"] = Util.dbchar(Request["send_way"]);
            ColMap["receipt_type"] = Util.dbchar(Request["receipt_type"]);
            ColMap["receipt_title"] = Util.dbchar(Request["receipt_title"]);
            SQL += ColMap.GetUpdateSQL();
            SQL += " where seq = '" + Request["seq"] + "' and seq1='" + Request["seq1"] + "' and case_no='" + Request["case_no"] + "' ";
            conn.ExecuteNonQuery(SQL);
        }


        //2012/3/1修改因爭舊案抽件，區所要能後續承辦交辦發文，所以要入todo_dmt
        if (Request["change"] == "B" & Request["oldopt_stat"] == "D") {//爭救案且oldopt_stat=D
            string job_team = Sys.getCodeName(conn, "sysctrl.dbo.scode_group", "grpid", "where grpclass='" + Session["seBranch"] + "' and scode='" + Request["pr_scode"] + "'");
            SQL = "insert into todo_dmt ";
            ColMap.Clear();
            ColMap["syscode"] = "'" + Session["syscode"] + "'";
            ColMap["apcode"] = Util.dbchar(HTProgCode);
            ColMap["from_flag"] = Util.dbchar("CGRS");
            ColMap["branch"] = "'" + Session["seBranch"] + "'";
            ColMap["seq"] = Util.dbzero(Request["seq"]);
            ColMap["seq1"] = Util.dbchar(Request["seq1"]);
            ColMap["step_grade"] = Util.dbnull(Request["nstep_grade"]);
            ColMap["case_In_scode"] = Util.dbchar(Request["in_scode"]);
            ColMap["in_no"] = Util.dbchar(Request["in_no"]);
            ColMap["case_no"] = Util.dbchar(Request["case_no"]);
            ColMap["in_scode"] = "'" + Session["scode"] + "'";
            ColMap["in_date"] = "getdate()";
            ColMap["dowhat"] = Util.dbchar("DP_GS");
            ColMap["job_scode"] = Util.dbchar(Request["pr_scode"]);
            ColMap["job_team"] = Util.dbchar(job_team);
            ColMap["job_status"] = Util.dbchar("NN");
            SQL += ColMap.GetInsertSQL();
            conn.ExecuteNonQuery(SQL);
        }

        //管制資料有修改或刪除時, 入檔 ctrl_dmt_log
        for (int i = 1; i <= Convert.ToInt32("0" + Request["ctrlnum"]); i++) {
            if ((Request["octrl_type_" + i] != Request["ctrl_type_" + i] && Request["octrl_type_" + i] != "" && Request["ctrl_type_" + i] != "")
                || (Request["octrl_date_" + i] != Request["ctrl_date_" + i] && Request["octrl_date_" + i] != "" && Request["ctrl_date_" + i] != "")
                || (Request["octrl_remark_" + i] != Request["ctrl_remark_" + i] && Request["octrl_remark_" + i] != "" && Request["ctrl_remark_" + i] != "")
                || (Request["delchk_" + i] == "Y")
                ) {
                string ud_flg = "U";//修改
                if (Request["delchk_" + i] == "Y") {
                    ud_flg = "D";//刪除
                }
                Sys.insert_log_table(conn, ud_flg, HTProgCode, "ctrl_dmt", "sqlno", Request["sqlno_" + i], logReason);
            }
        }

        //管制入檔 更新ctrl_dmt
        SQL = "delete from ctrl_dmt where rs_no='" + Request["rs_no"] + "'";
        conn.ExecuteNonQuery(SQL);
        //入ctrl_dmt
        for (int c = 1; c <= Convert.ToInt32("0" + Request["ctrlnum"]); c++) {
            if (Request["delchk_" + c] != "Y" && Request["io_flg_" + c] == "Y") {
                if (ReqVal.TryGet("ctrl_type_" + c) != "" && ReqVal.TryGet("ctrl_date_" + c) != "") {
                    SQL = "insert into ctrl_dmt ";
                    ColMap.Clear();
                    ColMap["rs_no"] = Util.dbchar(Request["rs_no"]);
                    ColMap["branch"] = Util.dbchar(Sys.GetSession("seBranch"));
                    ColMap["seq"] = Util.dbnull(Request["seq"]);
                    ColMap["seq1"] = Util.dbchar(Request["seq1"]);
                    ColMap["step_grade"] = Util.dbzero(Request["nstep_grade"]);
                    ColMap["ctrl_type"] = Util.dbchar(Request["ctrl_type_" + c]);
                    ColMap["ctrl_remark"] = Util.dbnull(Request["ctrl_remark_" + c]);
                    ColMap["ctrl_date"] = Util.dbnull(Request["ctrl_date_" + c]);
                    ColMap["tran_date"] = "getdate()";
                    ColMap["tran_scode"] = "'" + Session["scode"] + "'";
                    SQL += ColMap.GetInsertSQL();
                    conn.ExecuteNonQuery(SQL);
                }
            }
        }

        //銷管制入檔
        if (Request["rsqlno"] != "") {
            //新增至 resp_dmt
            SQL = "insert into resp_dmt(sqlno,rs_no,branch,seq,seq1,step_grade,resp_grade,ctrl_type,ctrl_remark,ctrl_date,resp_date,tran_date,tran_scode) ";
            SQL += "select sqlno,rs_no,branch,seq,seq1,step_grade,'" + Request["nstep_grade"] + "',ctrl_type,ctrl_remark,ctrl_date,'" + Request["step_date"] + "',getdate(),'" + Session["scode"] + "' ";
            SQL += "from ctrl_dmt where sqlno in('" + Request["rsqlno"].Replace(";", "','") + "') and sqlno<>''";
            conn.ExecuteNonQuery(SQL);

            //由 ctrl_dmt 中刪除
            SQL = "delete from ctrl_dmt where sqlno in('" + Request["rsqlno"].Replace(";", "','") + "') and sqlno<>''";
            conn.ExecuteNonQuery(SQL);
        }


        //案性為變更時,相關案件存檔
        if (ReqVal.TryGet("hrs_code").IN("FC11,FC21,FC6,FC7,FC8")) {
            for (int i = 1; i <= Convert.ToInt32("0" + Request["tot_num"]); i++) {
                string dseq = ReqVal.TryGet("dseq_" + i);
                string dseq1A = ReqVal.TryGet("dseq1A_" + i);
                SQL = " select * from step_dmt where main_rs_no = '" + rs_no + "' ";
                SQL += " and seq=" + dseq + " and seq1 = '" + dseq1A + "' ";
                using (SqlDataReader dr0 = conn.ExecuteReader(SQL)) {
                    if (dr0.Read()) {
                        //新增 step_dmt_Log 檔
                        Sys.insert_log_table(conn, "U", HTProgCode, "step_dmt", "rs_no", dr0.SafeRead("rs_no", ""), logReason);

                        //有異動過,才可以更改案件主檔的資料
                        if (Request["change"] == "C") {
                            //若案件主檔案件狀態進度序號小於等於進度序號，則修改案件狀態
                            SQL = "select isnull(now_grade,0) as now_grade from dmt where seq=" + dseq + " and seq1='" + dseq1A + "'";
                            objResult = conn.ExecuteScalar(SQL);
                            string now_grade0 = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();

                            SQL = " update dmt set seq = seq ";
                            if (Request["nstep_grade"] == "1") {
                                SQL += " ,arcase_type = " + Util.dbnull(Request["rs_type"]);
                                SQL += " ,arcase = " + Util.dbzero(Request["rs_code"]);
                                SQL += " ,arcase_class = " + Util.dbzero(Request["rs_class"]);
                            }

                            if (Convert.ToInt32(now_grade0) <= Convert.ToInt32(dr0.SafeRead("step_grade", "0"))) {
                                //若本次收文案件狀態不為 empty 則 update 案件主檔
                                if (Request["ncase_stat"] != "") {
                                    SQL += ",now_arcase_type=" + Util.dbnull(Request["rs_type"]);
                                    SQL += ",now_arcase=" + Util.dbchar(Request["rs_code"]);
                                    SQL += ",now_stat=" + Util.dbchar(Request["ncase_stat"]);
                                    SQL += ",now_grade=" + Util.dbzero(Request["nstep_grade"]);
                                    SQL += ",now_arcase_class=" + Util.dbchar(Request["rs_class"]);
                                    SQL += ",now_act_code=" + Util.dbchar(Request["act_code"]);
                                    SQL += " where seq = " + dseq + " and seq1='" + dseq1A + "'";
                                    conn.ExecuteNonQuery(SQL);
                                } else {
                                    //若本次收文案件狀態為 empty 且案件主檔案件狀態進度序號等於本次進度
                                    //則需找到之前最後一筆的案件狀態且 Update 案件主檔
                                    if (Convert.ToInt32(now_grade0) == Convert.ToInt32(dr0.SafeRead("step_grade", "0"))) {
                                        string SQL1 = "select * from vstep_dmt a, vcode_act b";
                                        SQL1 += " where a.seq = " + Request["seq"];
                                        SQL1 += "   and a.seq1 = '" + Request["seq1"] + "'";
                                        SQL1 += "   and a.rs_type = b.rs_type ";
                                        SQL1 += "   and a.rs_class = b.rs_class ";
                                        SQL1 += "   and a.rs_code = b.rs_code ";
                                        SQL1 += "   and a.act_code = b.act_code ";
                                        SQL1 += "   and b.cg = a.cg ";
                                        SQL1 += "   and b.rs = a.rs ";
                                        SQL1 += "   and b.case_stat is not null ";
                                        SQL1 += " order by step_grade desc";
                                        string now_arcase_type = "", now_arcase = "", now_stat = "", now_grade = "", now_arcase_class = "", now_act_code = "";
                                        using (SqlDataReader dr = conn.ExecuteReader(SQL1)) {
                                            if (dr.Read()) {
                                                now_arcase_type = dr.SafeRead("rs_type", "");
                                                now_arcase = dr.SafeRead("rs_code", "");
                                                now_stat = dr.SafeRead("case_stat", "");
                                                now_grade = dr.SafeRead("step_grade", "");
                                                now_arcase_class = dr.SafeRead("rs_class", "");
                                                now_act_code = dr.SafeRead("act_code", "");
                                            }
                                        }

                                        SQL += " ,now_arcase_type = " + Util.dbnull(now_arcase_type);
                                        SQL += " ,now_arcase = " + Util.dbnull(now_arcase);
                                        SQL += " ,now_stat = " + Util.dbnull(now_stat);
                                        SQL += " ,now_grade = " + Util.dbnull(now_grade);
                                        SQL += " ,now_arcase_class = " + Util.dbnull(now_arcase_class);
                                        SQL += " ,now_act_code = " + Util.dbnull(now_act_code);
                                        SQL += " where seq = " + dseq + " and seq1='" + dseq1A + "'";
                                        conn.ExecuteNonQuery(SQL);
                                    }
                                }
                            }
                        }

                        //修改 step_dmp
                        SQL = "update step_dmt set ";
                        ColMap.Clear();
                        ColMap["step_date"] = Util.dbnull(Request["step_date"]);
                        ColMap["receive_no"] = Util.dbnull(Request["receive_no"]);
                        ColMap["rs_code"] = Util.dbnull(Request["rs_code"]);
                        ColMap["rs_detail"] = Util.dbnull(Request["rs_detail"]);
                        ColMap["doc_detail"] = Util.dbnull(Request["doc_detail"]);
                        ColMap["send_sel"] = Util.dbnull(Request["send_sel"]);
                        ColMap["pr_scode"] = Util.dbnull(Request["pr_scode"]);
                        ColMap["pr_status"] = Util.dbnull(ReqVal.TryGet("pr_scode") != "" ? "N" : "X");
                        ColMap["tran_date"] = "getdate()";
                        ColMap["tran_scode"] = "'" + Session["scode"] + "'";
                        SQL += ColMap.GetUpdateSQL();
                        SQL += " where rs_no = '" + Request["rs_no"] + "'";
                        conn.ExecuteNonQuery(SQL);
                    }
                }
            }
        }
    }
    
    //刪除
    private void doDel() {
        rs_no = ReqVal.TryGet("rs_no");

        //刪除管制檔  新增 ctrl_dmt_log
        Sys.insert_log_table(conn, "D", HTProgCode, "ctrl_dmt", "rs_no", rs_no, logReason);

        //刪除 ctrl_dmt
        SQL = "delete from ctrl_dmt where rs_no='" + rs_no + "'";
        conn.ExecuteNonQuery(SQL);

        //新增 step_dmt_Log 檔
        Sys.insert_log_table(conn, "D", HTProgCode, "step_dmt", "rs_no", rs_no, logReason);
        //刪除 step_dmt
        SQL = "delete step_dmt where rs_no='" + rs_no + "'";
        conn.ExecuteNonQuery(SQL);

        //若案件主檔案件狀態進度序號等於進度序號，則修改案件狀態
        SQL = "select step_grade,isnull(now_grade,0) as now_grade from dmt where seq=" + Request["seq"] + " and seq1='" + Request["seq1"] + "'";
        string step_grade = "0", now_grade = "0";
        using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
            if (dr.Read()) {
                step_grade = dr.SafeRead("step_grade", "0");
                now_grade = dr.SafeRead("now_grade", "0");
            }
        }

        //更新主檔進度序號
        //若主檔進度序號等與此進度序號則取得前一筆進度序號並 update 主檔 step_grade
        if (Convert.ToInt32(step_grade) == Convert.ToInt32(Request["nstep_grade"])) {
            SQL = "select max(step_grade) as step_grade from vstep_dmt ";
            SQL += " where seq = " + Request["seq"] + " and seq1='" + Request["seq1"] + "' and step_grade <> '" + Request["nstep_grade"] + "'";
            object objResult = conn.ExecuteScalar(SQL);
            string rstep_grade = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();

            SQL = " update dmt set seq = seq ";
            if (rstep_grade != "") SQL += " ,step_grade = '" + rstep_grade + "'";
            SQL += " where seq = " + Request["seq"] + " and seq1='" + Request["seq1"] + "'";
            conn.ExecuteNonQuery(SQL);
        }

        //更新主檔 now_arcase, now_stat ..... 等欄位
        if (Convert.ToInt32(now_grade) == Convert.ToInt32(Request["nstep_grade"])) {
            SQL = "select * from vstep_dmt a, vcode_act b";
            SQL += " where a.seq = " + Request["seq"];
            SQL += "   and a.seq1 = '" + Request["seq1"] + "'";
            SQL += "   and a.rs_no <> '" + rs_no + "'";
            SQL += "   and a.rs_type = b.rs_type ";
            SQL += "   and a.rs_class = b.rs_class ";
            SQL += "   and a.rs_code = b.rs_code ";
            SQL += "   and a.act_code = b.act_code ";
            SQL += "   and b.cg = a.cg ";
            SQL += "   and b.rs = a.rs ";
            SQL += "   and b.case_stat is not null ";
            SQL += " order by step_grade desc";
            string nnow_arcase_type = "", nnow_arcase = "", nnow_stat = "", nnow_grade = "", nnow_arcase_class = "", nnow_act_code = "";
            using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
                if (dr.Read()) {
                    nnow_arcase_type = dr.SafeRead("rs_type", "");
                    nnow_arcase = dr.SafeRead("rs_code", "");
                    nnow_stat = dr.SafeRead("case_stat", "");
                    nnow_grade = dr.SafeRead("step_grade", "");
                    nnow_arcase_class = dr.SafeRead("rs_class", "");
                    nnow_act_code = dr.SafeRead("act_code", "");
                }
            }
            SQL = " update dmt set seq = seq ";
            SQL += " ,now_arcase_type = " + Util.dbnull(nnow_arcase_type);
            SQL += " ,now_arcase = " + Util.dbnull(nnow_arcase);
            SQL += " ,now_stat = " + Util.dbnull(nnow_stat);
            SQL += " ,now_grade = " + Util.dbnull(nnow_grade);
            SQL += " ,now_arcase_class = " + Util.dbnull(nnow_arcase_class);
            SQL += " ,now_act_code = " + Util.dbnull(nnow_act_code);
            SQL += " where seq = " + Request["seq"] + " and seq1='" + Request["seq1"] + "'";
            conn.ExecuteNonQuery(SQL);
        }
    }
</script>

<%Response.Write(strOut.ToString());%>
