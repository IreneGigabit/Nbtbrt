<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>

<script runat="server">
    protected string HTProgCap = "國內案官方收文作業-入檔";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "brta21";//HttpContext.Current.Request["prgid"] ?? "";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";

    protected string submitTask = "";
    protected string SQL = "";
    protected object objResult = null;
    
    protected string logReason = "Brta2m國內案官收維護作業";
    protected string fseq = "", rs_no = "", cs_rs_no = "";
    
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
                    strOut.AppendLine("<div align='center'><h1>客戶發文新增成功!!!發文序號:(" + rs_no + ")</h1></div>");
                } else if (ReqVal.TryGet("submittask") == "U") {
                    doUpdate();
                    strOut.AppendLine("<div align='center'><h1>客戶發文維護成功!!!發文序號:(" + rs_no + ")</h1></div>");
                } else if (ReqVal.TryGet("submittask") == "D") {
                    doDel();
                    strOut.AppendLine("<div align='center'><h1>客戶發文刪除成功!!!發文序號:(" + rs_no + ")</h1></div>");
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
        //判斷是否需客戶報導 , 若需客戶報導則需新增一筆客發
        cs_rs_no = "";
        if (ReqVal.TryGet("csflg") == "Y") {
            //先取得客發序號. 新增完官收後再新增客發
            cs_rs_no = Sys.getRsNo(conn, "CS");
        }

        //收文序號
        rs_no = Sys.getRsNo(conn, "GR");

        //官收入step_dmt	
        SQL = "insert into step_dmt ";
        ColMap.Clear();
        ColMap["rs_no"] = Util.dbchar(rs_no);
        ColMap["branch"] = Util.dbchar(Sys.GetSession("seBranch"));
        ColMap["seq"] = Util.dbnull(Request["seq"]);
        ColMap["seq1"] = Util.dbchar(Request["seq1"]);
        ColMap["step_grade"] = Util.dbnull(Request["nstep_grade"]);
        ColMap["main_rs_no"] = Util.dbchar(rs_no);
        ColMap["step_date"] = Util.dbnull(Request["step_date"]);
        ColMap["mp_date"] = Util.dbnull(Request["mp_date"]);
        ColMap["cg"] = Util.dbchar(Request["cgrs"].Substring(0, 1));
        ColMap["rs"] = Util.dbchar(Request["cgrs"].Substring(1, 1));
        ColMap["send_cl"] = Util.dbnull(Request["send_cl"]);
        ColMap["rs_type"] = Util.dbnull(Request["rs_type"]);
        ColMap["rs_class"] = Util.dbchar(Request["rs_class"]);
        ColMap["rs_code"] = Util.dbchar(Request["rs_code"]);
        ColMap["act_code"] = Util.dbchar(Request["act_code"]);
        ColMap["rs_detail"] = Util.dbnull(Request["rs_detail"]);
        ColMap["doc_detail"] = Util.dbnull(Request["doc_detail"]);
        ColMap["receive_no"] = Util.dbnull(Request["receive_no"]);
        ColMap["cs_rs_no"] = Util.dbnull(cs_rs_no);
        ColMap["pr_status"] = Util.dbchar(ReqVal.TryGet("pr_scode") != "" ? "N" : "X");
        ColMap["pr_scode"] = Util.dbnull(Request["pr_scode"]);
        ColMap["new"] = Util.dbchar("N");
        ColMap["tot_num"] = Util.dbzero("1");
        ColMap["tran_date"] = "getdate()";
        ColMap["tran_scode"] = "'" + Session["scode"] + "'";
        ColMap["pr_scan"] = Util.dbchar(Request["pr_scan"]);
        ColMap["pr_scan_remark"] = Util.dbchar(Request["pr_scan_remark"]);
        ColMap["pr_scan_page"] = Util.dbzero(Request["pr_scan_page"]);
        SQL += ColMap.GetInsertSQL();
        conn.ExecuteNonQuery(SQL);

        //抓insert後的流水號
        SQL = "SELECT SCOPE_IDENTITY() AS Current_Identity";
        objResult = conn.ExecuteScalar(SQL);
        string Getrs_sqlno = objResult.ToString();
        Sys.showLog("進度流水號=" + Getrs_sqlno);

        //入ctrl_dmt
        for (int i = 1; i <= Convert.ToInt32("0" + Request["ctrlnum"]); i++) {
            if ((Request["ctrl_type_" + i] ?? "") != "" || (Request["ctrl_date_" + i] ?? "") != "") {
                SQL = "insert into ctrl_dmt ";
                ColMap.Clear();
                ColMap["rs_no"] = Util.dbchar(rs_no);
                ColMap["branch"] = Util.dbchar(Sys.GetSession("seBranch"));
                ColMap["seq"] = Util.dbnull(Request["seq"]);
                ColMap["seq1"] = Util.dbchar(Request["seq1"]);
                ColMap["step_grade"] = Util.dbnull(Request["nstep_grade"]);
                ColMap["ctrl_type"] = Util.dbchar(Request["ctrl_type_" + i]);
                ColMap["ctrl_remark"] = Util.dbnull(Request["ctrl_remark_" + i]);
                ColMap["ctrl_date"] = Util.dbnull(Request["ctrl_date_" + i]);
                ColMap["tran_date"] = "getdate()";
                ColMap["tran_scode"] = "'" + Session["scode"] + "'";
                SQL += ColMap.GetInsertSQL();
                conn.ExecuteNonQuery(SQL);
            }
        }

        //銷管制入檔
        //新增至 resp_dmt
        SQL = "insert into resp_dmt(sqlno,rs_no,branch,seq,seq1,step_grade,resp_grade,ctrl_type,ctrl_remark,ctrl_date,resp_date,tran_date,tran_scode) ";
        SQL += "select sqlno,rs_no,branch,seq,seq1,step_grade,'" + Request["nstep_grade"] + "',ctrl_type,ctrl_remark,ctrl_date,'" + Request["step_date"] + "',getdate(),'" + Session["scode"] + "' ";
        SQL += "from ctrl_dmt where sqlno in('" + Request["rsqlno"].Replace(";", "','") + "') and sqlno<>''";
        conn.ExecuteNonQuery(SQL);

        //由 ctrl_dmt 中刪除
        SQL = "delete from ctrl_dmt where sqlno in('" + Request["rsqlno"].Replace(";", "','") + "') and sqlno<>''";
        conn.ExecuteNonQuery(SQL);

        //案件主檔進度序號加一 & 相關欄位 Update
        Sys.insert_log_table(conn, "U", prgid, "dmt", "seq;seq1", Request["seq"] + ";" + Request["seq1"], logReason);
        SQL = "update dmt set step_grade=step_grade+1 ";
        SQL += ",apply_date = " + Util.dbnull(Request["apply_date"]);
        SQL += ",apply_no = " + Util.dbnull(Request["apply_no"]);
        SQL += ",issue_date = " + Util.dbnull(Request["issue_date"]);
        SQL += ",issue_no = " + Util.dbnull(Request["issue_no"]);
        SQL += ",open_date = " + Util.dbnull(Request["open_date"]);
        SQL += ",rej_no = " + Util.dbnull(Request["rej_no"]);
        SQL += ",term1 = " + Util.dbnull(Request["term1"]);
        SQL += ",term2 = " + Util.dbnull(Request["term2"]);
        //2011/9/22依需求2011/5/20李協理Email，增加update延展次數
        SQL += ",renewal = " + Util.dbzero(Request["renewal"]);
        if (ReqVal.TryGet("ncase_stat") != "") {
            SQL += ",now_arcase_type = " + Util.dbnull(Request["rs_type"]);
            SQL += ",now_arcase = " + Util.dbnull(Request["rs_code"]);
            SQL += ",now_stat = " + Util.dbnull(Request["ncase_stat"]);
            SQL += ",now_grade = " + Util.dbnull(Request["nstep_grade"]);
            SQL += ",now_arcase_class = " + Util.dbnull(Request["rs_class"]);
            SQL += ",now_act_code = " + Util.dbnull(Request["act_code"]);
        }
        SQL += ",pay_times = " + Util.dbnull(Request["hpay_times"]);
        SQL += ",pay_date = " + Util.dbnull(Request["pay_date"]);
        SQL += " where seq=" + Request["seq"] + " and seq1='" + Request["seq1"] + "'";
        conn.ExecuteNonQuery(SQL);

        //新增客發紀錄
        if (cs_rs_no != "") {
            //取得法定期限,2009/9/14法定期限抓取A*但A2客戶期限除外且管制日期最小者
            SQL = "select ctrl_date from ctrl_dmt where seq='" + Request["seq"] + "' and seq1='" + Request["seq1"] + "'";
            SQL += "  and step_grade = '" + Request["nstep_grade"] + "' ";
            SQL += "  and ctrl_type like 'A%' and ctrl_type<>'A2' ";
            SQL += "  order by ctrl_date ";
            objResult = conn.ExecuteScalar(SQL);
            string lctrl_date = (objResult == DBNull.Value || objResult == null) ? "" : Util.parseDBDate(objResult.ToString(), "yyyy/M/d");

            //取得取得客發代碼
            string lcsact_code = ReqVal.TryGet("act_code");
            SQL = "select csact_code from vcode_act where rs_type = '" + Request["rs_type"] + "'";
            SQL += "  and rs_class = '" + Request["rs_class"] + "' and rs_code = '" + Request["rs_code"] + "'";
            SQL += "  and act_code = '" + Request["act_code"] + "' and cg = 'G' and rs = 'R' ";
            using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
                if (dr.Read()) {
                    lcsact_code = dr.SafeRead("csact_code", "");
                }
            }

            SQL = "insert into cs_dmt(rs_no,step_date,rs_type,rs_class,rs_code,act_code,rs_detail,last_date,send_way,tran_date,tran_scode)";
            SQL += " values('" + cs_rs_no + "'," + Util.dbnull(Request["step_date"]) + "," + Util.dbnull(Request["rs_type"]);
            SQL += "," + Util.dbchar(Request["rs_class"]) + "," + Util.dbchar(Request["rs_code"]);
            SQL += ",'" + lcsact_code + "'," + Util.dbnull(Request["cs_detail"]) + "," + Util.dbnull(lctrl_date);
            SQL += "," + Util.dbnull(Request["send_way"]) + ",getdate(),'" + Session["scode"] + "')";
            conn.ExecuteNonQuery(SQL);

            SQL = "insert into csd_dmt(rs_no,branch,seq,seq1,cust_seq,att_sql)";
            SQL += "values('" + cs_rs_no + "','" + Session["seBranch"] + "'," + Request["seq"] + ",'" + Request["seq1"] + "'";
            SQL += "," + Util.dbnull(Request["cust_seq"]) + "," + Util.dbnull(Request["att_sql"]) + ")";
            conn.ExecuteNonQuery(SQL);
        }
    }

    //維護
    private void doUpdate() {
        rs_no = ReqVal.TryGet("rs_no");
        cs_rs_no = ReqVal.TryGet("cs_rs_no");
        string cs_stat = "";
        //判斷是否需新增客戶報導 , 若需客戶報導則需新增一筆客發
        if (ReqVal.TryGet("csflg") == "Y") {
            if (ReqVal.TryGet("cs_rs_no") == "") {
                //先取得客發序號. 新增完官收後再新增客發
                cs_rs_no = Sys.getRsNo(conn, "CS");
                cs_stat = "A";//原本沒客發, 修改後增加客發
            } else {
                cs_stat = "B";//原本有客發, 修改後維持原樣
                cs_rs_no = ReqVal.TryGet("cs_rs_no");
            }
        } else {
            if (ReqVal.TryGet("cs_rs_no") == "") {
                cs_stat = "C";//原本沒客發, 修改後維持原樣
            } else {
                cs_stat = "D";//原本有客發, 修改後刪除客發
            }
        }
        //新增 step_dmt_Log 檔
        Sys.insert_log_table(conn, "U", prgid, "step_dmt", "rs_no", Request["rs_no"], logReason);

        //修改 step_dmt
        SQL = "update step_dmt set ";
        ColMap.Clear();
        ColMap["step_date"] = Util.dbnull(Request["step_date"]);
        ColMap["mp_date"] = Util.dbnull(Request["mp_date"]);
        ColMap["send_cl"] = Util.dbnull(Request["send_cl"]);
        ColMap["rs_type"] = Util.dbnull(Request["rs_type"]);
        ColMap["rs_class"] = Util.dbchar(Request["rs_class"]);
        ColMap["rs_code"] = Util.dbchar(Request["rs_code"]);
        ColMap["act_code"] = Util.dbchar(Request["act_code"]);
        ColMap["rs_detail"] = Util.dbnull(Request["rs_detail"]);
        ColMap["doc_detail"] = Util.dbnull(Request["doc_detail"]);
        ColMap["receive_no"] = Util.dbnull(Request["receive_no"]);
        ColMap["cs_rs_no"] = Util.dbnull(cs_rs_no);
        ColMap["pr_status"] = Util.dbchar(ReqVal.TryGet("pr_scode") != "" ? "N" : "X");
        ColMap["pr_scode"] = Util.dbnull(Request["pr_scode"]);
        ColMap["pr_scan"] = Util.dbchar(Request["pr_scan"]);
        ColMap["pr_scan_remark"] = Util.dbchar(Request["pr_scan_remark"]);
        ColMap["pr_scan_page"] = Util.dbzero(Request["pr_scan_page"]);
        ColMap["csd_flag"] = Util.dbchar(Request["csd_flag"]);
        ColMap["cs_remark"] = Util.dbchar(Request["cs_remark"]);
        ColMap["pmail_date"] = Util.dbnull(Request["pmail_date"]);
        ColMap["tran_date"] = "getdate()";
        ColMap["tran_scode"] = "'" + Session["scode"] + "'";
        ColMap["receive_way"] = Util.dbchar(Request["receive_way"]);
        SQL += ColMap.GetUpdateSQL();
        SQL += " where rs_no = '" + Request["rs_no"] + "'";
        conn.ExecuteNonQuery(SQL);

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

        //案件主檔相關欄位 Update
        Sys.insert_log_table(conn, "U", prgid, "dmt", "seq;seq1", Request["seq"] + ";" + Request["seq1"], logReason);
        SQL = "update dmt set ";
        SQL += " apply_date = " + Util.dbnull(Request["apply_date"]);
        SQL += ",apply_no = " + Util.dbnull(Request["apply_no"]);
        SQL += ",issue_date = " + Util.dbnull(Request["issue_date"]);
        SQL += ",issue_no = " + Util.dbnull(Request["issue_no"]);
        SQL += ",open_date = " + Util.dbnull(Request["open_date"]);
        SQL += ",rej_no = " + Util.dbnull(Request["rej_no"]);
        SQL += ",pay_times = " + Util.dbnull(Request["hpay_times"]);
        SQL += ",pay_date = " + Util.dbnull(Request["pay_date"]);
        //2011/9/22依需求2011/5/20李協理Email，增加update延展次數
        SQL += ",renewal = " + Util.dbzero(Request["renewal"]);
        SQL += ",term1 = " + Util.dbnull(Request["term1"]);
        SQL += ",term2 = " + Util.dbnull(Request["term2"]);
        SQL += " where seq=" + Request["seq"] + " and seq1='" + Request["seq1"] + "'";
        conn.ExecuteNonQuery(SQL);

        //若案件主檔案件狀態進度序號小於等於進度序號，則修改案件狀態
        SQL = "select isnull(now_grade,0) as now_grade from dmt where seq=" + Request["seq"] + " and seq1='" + Request["seq1"] + "'";
        objResult = conn.ExecuteScalar(SQL);
        string now_grade0 = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();

        //案件主檔now_arcase,now_grade,now_stat
        if (Convert.ToInt32(Request["nstep_grade"]) >= Convert.ToInt32(now_grade0)) {
            if (Request["ncase_stat"] != "") {
                SQL = "update dmt set now_arcase_type=" + Util.dbnull(Request["rs_type"]);
                SQL += ",now_arcase=" + Util.dbchar(Request["rs_code"]);
                SQL += ",now_grade=" + Util.dbzero(Request["nstep_grade"]);
                SQL += ",now_stat=" + Util.dbchar(Request["ncase_stat"]);
                SQL += ",now_arcase_class=" + Util.dbchar(Request["rs_class"]);
                SQL += ",now_act_code=" + Util.dbchar(Request["act_code"]);
                SQL += " where seq = " + Request["seq"] + " and seq1='" + Request["seq1"] + "'";
                conn.ExecuteNonQuery(SQL);
            } else {
                //若本次收文案件狀態為 empty 且案件主檔案件狀態進度序號等於本次進度
                //則需找到之前最後一筆的案件狀態且 Update 案件主檔
                if (Convert.ToInt32(now_grade0) >= Convert.ToInt32(Request["nstep_grade"])) {
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
                    string now_arcase_type = "", now_arcase = "", now_stat = "", now_grade = "", now_arcase_class = "", now_act_code = "";
                    using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
                        if (dr.Read()) {
                            now_arcase_type = dr.SafeRead("rs_type", "");
                            now_arcase = dr.SafeRead("rs_code", "");
                            now_stat = dr.SafeRead("case_stat", "");
                            now_grade = dr.SafeRead("step_grade", "");
                            now_arcase_class = dr.SafeRead("rs_class", "");
                            now_act_code = dr.SafeRead("act_code", "");
                        }
                    }
                    SQL = " update dmt set seq = seq ";
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

        //客發處理
        string lctrl_date = "", lcsact_code = "";
        switch (cs_stat) {
            case "A"://原本沒客發, 修改後增加客發
                SQL = "select ctrl_date from ctrl_dmt where seq='" + Request["seq"] + "' and seq1='" + Request["seq1"] + "'";
                SQL += "  and step_grade = '" + Request["nstep_grade"] + "' ";
                SQL += "  and ctrl_type like 'A%' and ctrl_type<>'A2' ";
                SQL += "  order by ctrl_date ";
                objResult = conn.ExecuteScalar(SQL);
                lctrl_date = (objResult == DBNull.Value || objResult == null) ? "" : Util.parseDBDate(objResult.ToString(), "yyyy/M/d");

                //取得取得客發代碼
                lcsact_code = ReqVal.TryGet("act_code");
                SQL = "select csact_code from vcode_act where rs_type = '" + Request["rs_type"] + "'";
                SQL += "  and rs_class = '" + Request["rs_class"] + "' and rs_code = '" + Request["rs_code"] + "'";
                SQL += "  and act_code = '" + Request["act_code"] + "' and cg = 'G' and rs = 'R' ";
                using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
                    if (dr.Read()) {
                        lcsact_code = dr.SafeRead("csact_code", "");
                    }
                }

                SQL = "insert into cs_dmt(rs_no,step_date,rs_type,rs_class,rs_code,act_code,rs_detail,last_date,send_way,tran_date,tran_scode)";
                SQL += " values('" + cs_rs_no + "'," + Util.dbnull(Request["step_date"]) + "," + Util.dbnull(Request["rs_type"]);
                SQL += "," + Util.dbchar(Request["rs_class"]) + "," + Util.dbchar(Request["rs_code"]);
                SQL += ",'" + lcsact_code + "'," + Util.dbnull(Request["cs_detail"]) + "," + Util.dbnull(lctrl_date);
                SQL += "," + Util.dbnull(Request["send_way"]) + ",getdate(),'" + Session["scode"] + "')";
                conn.ExecuteNonQuery(SQL);

                SQL = "insert into csd_dmt(rs_no,branch,seq,seq1,cust_seq,att_sql)";
                SQL += "values('" + cs_rs_no + "','" + Session["seBranch"] + "'," + Request["seq"] + ",'" + Request["seq1"] + "'";
                SQL += "," + Util.dbnull(Request["cust_seq"]) + "," + Util.dbnull(Request["att_sql"]) + ")";
                conn.ExecuteNonQuery(SQL);

                //2009/9/14修改營洽官收確認檔之客戶報導、發文方式、報導主旨、客函法定期限、延期客發、延期原因、預計寄出日期、對應客發發文序號
                SQL = "update grconf_dmt set cs_flag='Y',cs_send_way=" + Util.dbnull(Request["send_way"]) + ",scs_detail=" + Util.dbnull(Request["cs_detail"]);
                SQL += ",last_date=" + Util.dbnull(lctrl_date) + ",csd_flag=" + Util.dbchar(Request["csd_flag"]) + ",csd_remark=" + Util.dbchar(Request["cs_remark"]);
                SQL += ",pstep_date=" + Util.dbchar(Request["pmail_date"]) + ",cs_rs_no=" + Util.dbnull(cs_rs_no);
                SQL += " where seq='" + Request["seq"] + "' and seq1='" + Request["seq1"] + "' and step_grade=" + Request["nstep_grade"];
                conn.ExecuteNonQuery(SQL);

                break;
            case "B"://原本有客發, 修改後仍有客發
                //新增 cs_dmt_Log 檔
                Sys.insert_log_table(conn, "U", HTProgCode, "cs_dmt", "rs_no", cs_rs_no, logReason);
                //SQL = " insert into cs_dmt_log(ud_flg,rs_no,branch,seq,seq1,cust_seq,att_sql,step_date,send_way";
                //SQL += ",rs_type,rs_class,rs_code,act_code,rs_detail,mark,tran_date,tran_scode";
                //SQL += ",print_date,mail_date,mail_scode,mwork_date)";
                //SQL += " select 'U',rs_no,branch,seq,seq1,cust_seq,att_sql,step_date,send_way";
                //SQL += ",rs_type,rs_class,rs_code,act_code,rs_detail,mark,getdate(),'" + Session["scode"] + "'";
                //SQL += ",print_date,mail_date,mail_scode,mwork_date";
                //SQL += " from vcs_dmt where rs_no = '" + cs_rs_no + "'";
                //conn.ExecuteNonQuery(SQL);

                SQL = "select ctrl_date from ctrl_dmt where seq='" + Request["seq"] + "' and seq1='" + Request["seq1"] + "'";
                SQL += "  and step_grade = '" + Request["nstep_grade"] + "' ";
                SQL += "  and ctrl_type like 'A%' and ctrl_type<>'A2' ";
                SQL += "  order by ctrl_date ";
                objResult = conn.ExecuteScalar(SQL);
                lctrl_date = (objResult == DBNull.Value || objResult == null) ? "" : Util.parseDBDate(objResult.ToString(), "yyyy/M/d");

                //取得取得客發代碼
                lcsact_code = ReqVal.TryGet("act_code");
                SQL = "select csact_code from vcode_act where rs_type = '" + Request["rs_type"] + "'";
                SQL += "  and rs_class = '" + Request["rs_class"] + "' and rs_code = '" + Request["rs_code"] + "'";
                SQL += "  and act_code = '" + Request["act_code"] + "' and cg = 'G' and rs = 'R' ";
                using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
                    if (dr.Read()) {
                        lcsact_code = dr.SafeRead("csact_code", "");
                    }
                }

                SQL = "update cs_dmt set step_date=" + Util.dbnull(Request["step_date"]);
                SQL += ",rs_type=" + Util.dbnull(Request["rs_type"]);
                SQL += ",rs_class=" + Util.dbnull(Request["rs_class"]);
                SQL += ",rs_code=" + Util.dbnull(Request["rs_code"]);
                SQL += ",act_code=" + Util.dbnull(lcsact_code);
                SQL += ",last_date=" + Util.dbnull(lctrl_date);
                SQL += ",rs_detail=" + Util.dbnull(Request["cs_detail"]);
                SQL += ",send_way = " + Util.dbnull(Request["send_way"]);
                SQL += ",tran_date=getdate(),tran_scode='" + Session["scode"] + "'";
                if (Request["csmail_flag"] == "Y") SQL += ",mail_date=null";
                SQL += " where rs_no='" + cs_rs_no + "'";
                conn.ExecuteNonQuery(SQL);

                //2009/9/14修改營洽官收確認檔之發文方式、報導主旨、客函法定期限、延期客發、延期原因、預計寄出日期
                SQL = "update grconf_dmt set cs_send_way=" + Util.dbnull(Request["send_way"]) + ",scs_detail=" + Util.dbnull(Request["cs_detail"]);
                SQL += ",last_date=" + Util.dbnull(lctrl_date) + ",csd_flag=" + Util.dbchar(Request["csd_flag"]) + ",csd_remark=" + Util.dbchar(Request["cs_remark"]);
                SQL += ",pstep_date=" + Util.dbchar(Request["pmail_date"]);
                SQL += " where seq='" + Request["seq"] + "' and seq1='" + Request["seq1"] + "' and step_grade=" + Request["nstep_grade"];
                conn.ExecuteNonQuery(SQL);

                break;
            case "C"://原本沒客發, 修改後維持原樣
                break;
            case "D"://原本有客發, 修改後刪除客發
                //新增 cs_dmt_Log 檔
                Sys.insert_log_table(conn, "U", HTProgCode, "cs_dmt", "rs_no", cs_rs_no, logReason);
                //SQL = " insert into cs_dmt_log(ud_flg,rs_no,branch,seq,seq1,cust_seq,att_sql,step_date,send_way";
                //SQL += ",rs_type,rs_class,rs_code,act_code,rs_detail,mark,tran_date,tran_scode";
                //SQL += ",print_date,mail_date,mail_scode,mwork_date)";
                //SQL += " select 'U',rs_no,branch,seq,seq1,cust_seq,att_sql,step_date,send_way";
                //SQL += ",rs_type,rs_class,rs_code,act_code,rs_detail,mark,getdate(),'" + Session["scode"] + "'";
                //SQL += ",print_date,mail_date,mail_scode,mwork_date";
                //SQL += " from vcs_dmt where rs_no = '" + cs_rs_no + "'";
                //conn.ExecuteNonQuery(SQL);

                //刪除 cs_dmt 客發進度
                SQL = " delete from cs_dmt where rs_no='" + cs_rs_no + "'";
                conn.ExecuteNonQuery(SQL);

                //刪除 csd_dmt 客發進度
                SQL = " delete from csd_dmt where rs_no='" + cs_rs_no + "'";
                conn.ExecuteNonQuery(SQL);

                //2009/10/14修改營洽官收確認檔之客戶報導、發文方式、報導主旨、客函法定期限、延期客發、延期原因、預計寄出日期、對應客發發文序號
                SQL = "update grconf_dmt set cs_flag='N',cs_send_way=" + Util.dbnull(Request["send_way"]) + ",scs_detail=" + Util.dbnull(Request["cs_detail"]);
                SQL += ",last_date=" + Util.dbnull(lctrl_date) + ",csd_flag=" + Util.dbchar(Request["csd_flag"]) + ",csd_remark=" + Util.dbchar(Request["cs_remark"]);
                SQL += ",pstep_date=" + Util.dbchar(Request["pmail_date"]) + ",cs_rs_no=" + Util.dbnull(cs_rs_no);
                SQL += " where seq='" + Request["seq"] + "' and seq1='" + Request["seq1"] + "' and step_grade=" + Request["nstep_grade"];
                conn.ExecuteNonQuery(SQL);

                break;
        }
    }
    
    //刪除
    private void doDel() {
        rs_no = ReqVal.TryGet("rs_no");
        cs_rs_no = ReqVal.TryGet("cs_rs_no");

        //刪除管制檔  新增 ctrl_dmt_log
        for (int i = 1; i <= Convert.ToInt32("0" + Request["ctrlnum"]); i++) {
            Sys.insert_log_table(conn, "D", HTProgCode, "ctrl_dmt", "sqlno", Request["sqlno_" + i], logReason);
        }

        //刪除 ctrl_dmt
        SQL = "delete from ctrl_dmt where rs_no='" + Request["rs_no"] + "'";
        conn.ExecuteNonQuery(SQL);

        //取消銷管,還原至ctrl_dmt
        //新增 resp_dmt_log
        Sys.insert_log_table(conn, "D,A", HTProgCode, "resp_dmt", "seq;seq1;resp_grade", Request["seq"] + ";" + Request["seq1"] + ";" + Request["nstep_grade"], logReason);
        //新增 ctrl_dmt
        SQL = "insert into ctrl_dmt(rs_no,branch,seq,seq1,step_grade,ctrl_type,ctrl_remark,ctrl_date,tran_date,tran_scode) ";
        SQL += "select rs_no,branch,seq,seq1,step_grade,ctrl_type,ctrl_remark,ctrl_date,getdate(),'" + Session["scode"] + "' ";
        SQL += "from resp_dmt where seq=" + Request["seq"] + " and seq1='" + Request["seq1"] + "' and step_grade='" + Request["nstep_grade"] + "'";
        conn.ExecuteNonQuery(SQL);
        //刪除 resp_dmt
        SQL = "delete from resp_dmt where seq=" + Request["seq"] + " and seq1='" + Request["seq1"] + "' and step_grade='" + Request["nstep_grade"] + "'";
        conn.ExecuteNonQuery(SQL);

        //取消被銷管
        //新增 resp_dmt_log
        Sys.insert_log_table(conn, "D,B", HTProgCode, "resp_dmt", "rs_no", rs_no, logReason);
        //刪除 resp_dmt
        SQL = "delete from resp_dmt where rs_no='" + rs_no + "'";
        conn.ExecuteNonQuery(SQL);

        //刪除收文主檔
        //新增 step_dmt_Log 檔
        Sys.insert_log_table(conn, "D", HTProgCode, "step_dmt", "rs_no", rs_no, logReason);
        //刪除 step_dmt
        SQL = "delete step_dmt where rs_no='" + rs_no + "'";
        conn.ExecuteNonQuery(SQL);

        //客發處理
        if (cs_rs_no != "") {
            //新增 cs_dmt_Log 檔
            Sys.insert_log_table(conn, "D", HTProgCode, "cs_dmt", "rs_no", cs_rs_no, logReason);
            //SQL = " insert into cs_dmt_log(ud_flg,rs_no,branch,seq,seq1,cust_seq,att_sql,step_date,send_way";
            //SQL += ",rs_type,rs_class,rs_code,act_code,rs_detail,mark,tran_date,tran_scode";
            //SQL += ",print_date,mail_date,mail_scode,mwork_date)";
            //SQL += " select 'D',rs_no,branch,seq,seq1,cust_seq,att_sql,step_date,send_way";
            //SQL += ",rs_type,rs_class,rs_code,act_code,rs_detail,mark,getdate(),'" + Session["scode"] + "'";
            //SQL += ",print_date,mail_date,mail_scode,mwork_date";
            //SQL += " from vcs_dmt where rs_no = '" + cs_rs_no + "'";
            //conn.ExecuteNonQuery(SQL);

            //刪除 cs_dmt 客發進度
            SQL = " delete from cs_dmt where rs_no='" + cs_rs_no + "'";
            conn.ExecuteNonQuery(SQL);

            //刪除 csd_dmt 客發進度
            SQL = " delete from csd_dmt where rs_no='" + cs_rs_no + "'";
            conn.ExecuteNonQuery(SQL);
        }

        //若案件主檔案件狀態進度序號小於等於進度序號，則修改案件狀態
        SQL = "select step_grade,isnull(now_grade,0) as now_grade from dmt where seq=" + Request["seq"] + " and seq1='" + Request["seq1"] + "'";
        string step_grade = "0", now_grade = "0";
        using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
            if (dr.Read()) {
                step_grade = dr.SafeRead("step_grade", "0");
                now_grade = dr.SafeRead("now_grade", "0");
            }
        }

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

        //營洽官收確認處理
        SQL = "update grconf_dmt set sales_status='XX',sconf_scode='" + Session["scode"] + "',sconf_date=getdate() where seq=" + Request["seq"] + " and seq1='" + Request["seq1"] + "' and step_grade=" + Request["nstep_grade"];
        conn.ExecuteNonQuery(SQL);

        SQL = "update todo_dmt set job_status='XX',approve_scode='" + Session["scode"] + "',approve_desc='官收進度刪除',resp_date=getdate() ";
        SQL += " where dowhat='SALES_GR' and job_status='NN' and seq=" + Request["seq"] + " and seq1='" + Request["seq1"] + "' and step_grade=" + Request["nstep_grade"];
        conn.ExecuteNonQuery(SQL);

        //掃描文件處理
        if (Request["pr_scan"] == "Y") {
            SQL = "update dmt_attach set attach_flag='D',chk_status='XX' where seq=" + Request["seq"] + " and seq1='" + Request["seq1"] + "' and step_grade=" + Request["nstep_grade"] + " and source='scan' ";
            conn.ExecuteNonQuery(SQL);

            SQL = "update todo_dmt set job_status='XX',approve_scode='" + Session["scode"] + "',approve_desc='官收進度刪除',resp_date=getdate() ";
            SQL += " where seq=" + Request["seq"] + " and seq1='" + Request["seq1"] + "' and step_grade=" + Request["nstep_grade"] + " and dowhat='scan' and job_status='NN' ";
            conn.ExecuteNonQuery(SQL);
        }
    }
</script>

<%Response.Write(strOut.ToString());%>
