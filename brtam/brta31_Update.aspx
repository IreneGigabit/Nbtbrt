<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>

<script runat="server">
    protected string HTProgCap = "官發確認入檔";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = HttpContext.Current.Request["prgid"] ?? "";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected string prgid1 = (HttpContext.Current.Request["prgid1"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";

    protected string submitTask = "";
    protected string SQL = "";
    protected object objResult = null;
    protected string logReason = "Brta38官發確認作業";
        
    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected Dictionary<string, string> ColMap = new Dictionary<string, string>();

    protected int tot_num = 1;
    protected int mtot_num = 1;
    protected string issue_type="";
    protected string receipt_type = "";
    protected string receipt_title ="";
    protected string rectitle_name = "";
        
    protected StringBuilder strOut = new StringBuilder();

    DBHelper conn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    DBHelper connm = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    DBHelper conni2 = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    DBHelper conniacc = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    private void Page_Unload(System.Object sender, System.EventArgs e) {
        if (conn != null) conn.Dispose();
        if (connm != null) connm.Dispose();
        if (conni2 != null) conni2.Dispose();
        if (conniacc != null) conniacc.Dispose();
    }

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        if (prgid1 == "brta81")
            logReason = "brta81爭救案發文回條確認";
        
        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");
        conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
        connm = new DBHelper(Conn.MG).Debug(Request["chkTest"] == "TEST");
        conni2 = new DBHelper(Conn.account).Debug(Request["chkTest"] == "TEST");
        conniacc = new DBHelper(Conn.iaccount).Debug(Request["chkTest"] == "TEST");

        //計算 tot_num區所發文件數,mtot_num寫入總收發文件數
        if (ReqVal.TryGet("rs_code").Left(2) == "FD") {
            tot_num = 0;
        }
        for (int i = 1; i <= Convert.ToInt32("0" + Request["tot_num"]); i++) {
            if (ReqVal.TryGet("dseqdel_" + i) != "D") {
                tot_num++;
                mtot_num++;
            }
        }

        //依官發確認時的申請人為準,寫入step_dmp的收據抬頭
        string dmtap_cname = "";
        SQL = "select apcust_no,ap_cname from dmt_ap where seq='" + Request["seq"] + "' and seq1='" + Request["seq1"] + "'";
        using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
            if (dr.Read()) {
                dmtap_cname += "、" + dr.SafeRead("ap_cname", "").Trim();
            }
            if (dmtap_cname != "") dmtap_cname = dmtap_cname.Substring(1);
        }

        receipt_type = ReqVal.TryGet("receipt_type");
        receipt_title = ReqVal.TryGet("receipt_title");
        rectitle_name = "";
        if (receipt_title == "A") {//{專利權人
            rectitle_name = dmtap_cname;
        } else if (receipt_title == "C") {//{專利權人(代繳人)
            rectitle_name = dmtap_cname + "(代繳人：聖島國際專利商標聯合事務所)";
        }

        //20180716 增加批次繳註冊費
        if (Request["rs_code"] == "FF0")
            issue_type = "0";//全期
        else if (Request["rs_code"] == "FF2")
            issue_type = "2";//二期
        else if (Request["rs_code"] == "FF3")
            issue_type = "3";//二期逾期加倍補繳

        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        HTProgCap = myToken.Title;
        DebugStr = myToken.DebugStr;
        if (HTProgRight >= 0) {
            try {
                if (ReqVal.TryGet("submitTask") == "A") {
                    string rs_no = doAdd();
                    if (prgid1 == "brta81") {
                        strOut.AppendLine("<div align='center'><h1>官方發文確認成功!!!(" + rs_no + ")</h1></div>");
                    } else {
                        strOut.AppendLine("<div align='center'><h1>官方發文成功!!!(" + rs_no + ")</h1></div>");
                    }
                } else if (ReqVal.TryGet("submitTask") == "U") {
                    string rs_no = doUpdate();
                    strOut.AppendLine("<div align='center'><h1>官方發文維護成功!!!(" + rs_no + ")</h1></div>");
                } else if (ReqVal.TryGet("submitTask") == "D") {
                    string rs_no = doUpdate();
                    strOut.AppendLine("<div align='center'><h1>官方發文維護成功!!!(" + rs_no + ")</h1></div>");
                } else if (ReqVal.TryGet("submitTask") == "R") {
                    doBack();
                    strOut.AppendLine("<div align='center'><h1>官方發文退回成功!!!</h1></div>");
                }

                //conn.Commit();
                //connm.Commit();
                //conni2.Commit();
                conn.RollBack();
                connm.RollBack();
                conni2.RollBack();
            }
            catch (Exception ex) {
                conn.RollBack();
                connm.RollBack();
                conni2.RollBack();
                Sys.errorLog(ex, conn.exeSQL, prgid);
                Sys.errorLog(ex, connm.exeSQL, prgid);
                Sys.errorLog(ex, conni2.exeSQL, prgid);
                throw;
            }
            finally {
                conn.Dispose();
                connm.Dispose();
                conni2.Dispose();
            }
            this.DataBind();
        }
    }

    //新增(submitTask=A)
    private string doAdd() {
        string rs_no = "", opt_branch = "";
        //發文序號
        if (prgid1 == "brta81") {
            rs_no = ReqVal.TryGet("rs_no");
            opt_branch = ReqVal.TryGet("send_dept");
        } else {
            rs_no = getRsNo();//取得新發文序號
            opt_branch = ReqVal.TryGet("opt_branch");
        }

        for (int i = 1; i <= Convert.ToInt32("0" + Request["arnum"]); i++) {
            if (ReqVal.TryGet("case_no_" + i) != "") {
                //新增 fees_dmt，2013/3/22因收入寫入智產系統增加支出次數
                SQL = "insert into fees_dmt ";
                ColMap.Clear();
                ColMap["rs_no"] = Util.dbchar(rs_no);
                ColMap["case_no"] = Util.dbchar(Request["case_no_" + i]);
                ColMap["fees"] = Util.dbzero(Request["gs_fees_" + i]);
                ColMap["service"] = Util.dbzero(Request["service_" + i]);
                ColMap["gs_curr"] = "" + (Convert.ToInt32(Request["gs_curr" + i]) + 1) + "";
                SQL += ColMap.GetInsertSQL();
                conn.ExecuteNonQuery(SQL);

                //將官發規費支出存入case_dmt
                //case_dmt.gs_fees加上畫面上的gs_fees
                SQL = "update case_dmt set gs_fees=gs_fees+" + Request["gs_fees_" + i] + ",gs_curr=gs_curr+1 where case_no='" + ReqVal.TryGet("case_no_" + i) + "'";
                conn.ExecuteNonQuery(SQL);

                //將規費資料寫入帳款系統plus_temp
                if (Convert.ToInt32(Request["gs_fees_" + i]) > 0) {
                    //取得案件主檔營洽
                    string dmt_scode = "";
                    SQL = "select scode from dmt where seq=" + Request["seq"] + " and seq1='" + Request["seq1"] + "'";
                    objResult = conn.ExecuteScalar(SQL);
                    dmt_scode = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();

                    //取得交辦案性及請款註記
                    string lcase_arcase = "", lar_mark = "";
                    SQL = "select arcase,ar_mark from case_dmt where case_no='" + Request["case_no_" + i] + "'";
                    using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
                        if (dr.Read()) {
                            lcase_arcase = dr.SafeRead("arcase", "");
                            lar_mark = dr.SafeRead("ar_mark", "");
                        }
                    }

                    SQL = "insert into plus_temp ";
                    ColMap.Clear();
                    ColMap["class"] = Util.dbchar("1");
                    ColMap["tr_date"] = Util.dbchar(DateTime.Today.ToShortDateString());
                    ColMap["tr_scode"] = "'" + Session["scode"] + "'";
                    ColMap["send_date"] = Util.dbchar(Request["step_date"]);
                    ColMap["branch"] = "'" + Session["seBranch"] + "'";
                    ColMap["dept"] = "'" + Sys.GetSession("dept").ToUpper() + "'";
                    ColMap["case_no"] = Util.dbchar(Request["case_no_" + i]);
                    ColMap["rs_no"] = Util.dbchar(rs_no);
                    ColMap["seq"] = Util.dbchar(Request["seq"]);
                    ColMap["seq1"] = Util.dbchar(Request["seq1"]);
                    ColMap["country"] = Util.dbchar("T");
                    ColMap["cust_seq"] = Util.dbchar(Request["cust_seq"]);
                    ColMap["scode"] = Util.dbchar(dmt_scode);
                    ColMap["case_arcase"] = Util.dbchar(lcase_arcase);
                    ColMap["arcase"] = Util.dbchar(Request["rs_code"]);
                    ColMap["ar_mark"] = Util.dbchar(lar_mark);
                    ColMap["tr_money"] = Util.dbzero(Request["gs_fees_" + i]);
                    ColMap["chk_type"] = Util.dbchar("N");
                    ColMap["chk_date"] = "null";
                    ColMap["mstat_flag"] = Util.dbchar("NN");
                    ColMap["mstat_date"] = "null";
                    SQL += ColMap.GetInsertSQL();
                    conni2.ExecuteNonQuery(SQL);
                }
            }
        }

        //入step_dmt	
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
        ColMap["rs_type"] = Util.dbnull(Request["rs_type"]);
        ColMap["rs_class"] = Util.dbchar(Request["rs_class"]);
        ColMap["rs_code"] = Util.dbchar(Request["rs_code"]);
        ColMap["act_code"] = Util.dbchar(Request["act_code"]);
        ColMap["rs_detail"] = Util.dbnull(Request["rs_detail"]);
        ColMap["send_cl"] = Util.dbnull(Request["send_cl"]);
        ColMap["send_cl1"] = Util.dbnull(Request["send_cl1"]);
        ColMap["send_sel"] = Util.dbnull(Request["send_sel"]);
        ColMap["fees"] = Util.dbzero(Request["fees"]);
        ColMap["fees_stat"] = Util.dbchar(Request["fees_stat"]);
        ColMap["send_way"] = Util.dbchar(Request["send_way"]);
        ColMap["pr_scode"] = Util.dbchar(Request["pr_scode"]);
        ColMap["opt_branch"] = Util.dbchar(opt_branch);
        ColMap["new"] = Util.dbchar("N");
        ColMap["tot_num"] = Util.dbzero(tot_num.ToString());
        ColMap["rs_agt_no"] = Util.dbchar(Request["rs_agt_no"]);
        ColMap["receipt_type"] = Util.dbchar(receipt_type);
        ColMap["receipt_title"] = Util.dbchar(receipt_title);
        ColMap["rectitle_name"] = Util.dbchar(rectitle_name);
        ColMap["tran_date"] = "getdate()";
        ColMap["tran_scode"] = "'" + Session["scode"] + "'";
        SQL += ColMap.GetInsertSQL();
        conn.ExecuteNonQuery(SQL);

        //抓insert後的流水號
        SQL = "SELECT SCOPE_IDENTITY() AS Current_Identity";
        objResult = conn.ExecuteScalar(SQL);
        string Getrs_sqlno = objResult.ToString();
        Sys.showLog("進度流水號=" + Getrs_sqlno);

        //入ctrl_dmt
        for (int c = 1; c <= Convert.ToInt32("0" + Request["ctrlnum"]); c++) {
            if (ReqVal.TryGet("ctrl_type_" + c) != "" && ReqVal.TryGet("ctrl_date_" + c) != "") {
                SQL = "insert into ctrl_dmt ";
                ColMap.Clear();
                ColMap["rs_no"] = Util.dbchar(rs_no);
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

        //銷管制入檔
        DataTable dtCtrl = new DataTable();
        if (Request["rsqlno"] != "") {
            //keep資料-寫入總收發銷管暫存檔用
            SQL = "select seq,seq1,(select rs_sqlno from step_dmt s where s.rs_no=c.rs_no)br_rs_sqlno ";
            SQL += ",step_grade,'" + Request["nstep_grade"] + "'br_resp_grade,ctrl_type,ctrl_remark ";
            SQL += ",ctrl_date,'" + Request["step_date"] + "' resp_date,convert(varchar,tran_date,120) ctrl_tran_date ";
            SQL += ",tran_scode ctrl_tran_scode ";
            SQL += "from ctrl_dmt c ";
            SQL += "where sqlno in('" + Request["rsqlno"].Replace(";", "','") + "') ";
            SQL += "and sqlno<>'' ";
            SQL += "and (ctrl_type='A1' or ctrl_type like 'A4%') ";//條件同官發回條列印
            conn.DataTable(SQL, dtCtrl);

            //新增至 resp_dmt
            SQL = "insert into resp_dmt(sqlno,rs_no,branch,seq,seq1,step_grade,resp_grade,ctrl_type,ctrl_remark,ctrl_date,resp_date,tran_date,tran_scode) ";
            SQL += "select sqlno,rs_no,branch,seq,seq1,step_grade,'" + Request["nstep_grade"] + "',ctrl_type,ctrl_remark,ctrl_date,'" + Request["step_date"] + "',getdate(),'" + Session["scode"] + "' ";
            SQL += "from ctrl_dmt where sqlno in('" + Request["rsqlno"].Replace(";", "','") + "') and sqlno<>''";
            conn.ExecuteNonQuery(SQL);

            //由 ctrl_dmt 中刪除
            SQL = "delete from ctrl_dmt where sqlno in('" + Request["rsqlno"].Replace(";", "','") + "') and sqlno<>''";
            conn.ExecuteNonQuery(SQL);
        }

        //案件主檔now_arcase,now_grade,now_stat
        Sys.insert_log_table(conn, "U", prgid, "dmt", "seq;seq1", Request["seq"] + ";" + Request["seq1"], logReason);
        SQL = "update dmt set ";
        ColMap.Clear();
        if (Convert.ToInt32(Request["step_grade"]) >= Convert.ToInt32(Request["now_grade"]) && Request["ncase_stat"] != "") {
            ColMap["now_arcase_type"] = Util.dbchar(Request["rs_type"]);
            ColMap["now_arcase"] = Util.dbchar(Request["rs_code"]);
            ColMap["now_grade"] = Util.dbchar(Request["nstep_grade"]);
            ColMap["now_stat"] = Util.dbchar(Request["ncase_stat"]);
            ColMap["now_arcase_class"] = Util.dbchar(Request["rs_class"]);
            ColMap["now_act_code"] = Util.dbchar(Request["act_code"]);
        }
        ColMap["step_grade"] = "step_grade+1";
        ColMap["pay_times"] = Util.dbnull(Request["pay_times"]);
        ColMap["pay_date"] = Util.dbnull(Request["pay_date"]);
        SQL += ColMap.GetUpdateSQL();
        SQL += " where seq=" + Request["seq"] + " and seq1='" + Request["seq1"] + "'";
        conn.ExecuteNonQuery(SQL);

        int mfees = 0;
        if (prgid1 != "brta81") {
            //入文件上傳dmt_attach
            Insert_dmt_attach(Request["seq"], Request["seq1"], Request["nstep_grade"], Request["att_sqlno"]);
            //入總收發文mgt_send
            //計算入總收發文之逐案規費
            if (mtot_num == 1) {
                mfees = Convert.ToInt32(Request["fees"]);//母案規費
            } else {
                if (Request["rs_code"].Left(2) == "FD") {
                    mfees = Convert.ToInt32(Request["fees"]);//母案規費
                } else {
                    mfees = Convert.ToInt32(Request["fees"]) / mtot_num;
                }
            }
            string Getmgt_send_sqlno = Insert_mgt_send(Request["seq"], Request["seq1"], Request["nstep_grade"], rs_no, Getrs_sqlno, rs_no, mtot_num.ToString(), mfees.ToString());
            //法定期限銷管資料寫入總收發
            Insert_brresp_mgt(Getmgt_send_sqlno, dtCtrl);
            //入總收發文todo_mgt
            Insert_todo_mgt(Request["seq"], Request["seq1"], rs_no, Getrs_sqlno);
        }

        //案性為變更時,相關案件存檔
        if (ReqVal.TryGet("rs_code").IN("FC11,FC21,FC5,FC6,FC7,FC8,FCH,FCI,FL5,FL6,FT2") || ReqVal.TryGet("rs_code").Left(2) == "FD") {
            int afees = Convert.ToInt32(Request["fees"]) - mfees;
            for (int z = 1; z <= Convert.ToInt32("0" + Request["tot_num"]); z++) {
                string dseq = ReqVal.TryGet("dseq_" + z);
                string dseq1A = ReqVal.TryGet("dseq1A_" + z);
                if (ReqVal.TryGet("dseqdel_" + z) != "D") {
                    string drs_no = getRsNo();//取得新發文序號

                    //取得案件進度
                    SQL = "select step_grade+1 step_grade,isnull(now_grade,0) as now_grade from dmt where seq=" + dseq + " and seq1='" + dseq1A + "'";
                    string dstep_grade = "0", dnow_grade = "0";
                    using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
                        if (dr.Read()) {
                            dstep_grade = dr.SafeRead("step_grade", "0");
                            dnow_grade = dr.SafeRead("now_grade", "0");
                        }
                    }
                    
                    //入step_dmt	
                    SQL = "insert into step_dmt ";
                    ColMap.Clear();
                    ColMap["rs_no"] = Util.dbchar(drs_no);
                    ColMap["branch"] = Util.dbchar(Sys.GetSession("seBranch"));
                    ColMap["seq"] = Util.dbnull(dseq);
                    ColMap["seq1"] = Util.dbchar(dseq1A);
                    ColMap["step_grade"] = Util.dbnull(dstep_grade);
                    ColMap["main_rs_no"] = Util.dbchar(rs_no);
                    ColMap["step_date"] = Util.dbnull(Request["step_date"]);
                    ColMap["mp_date"] = Util.dbnull(Request["mp_date"]);
                    ColMap["cg"] = Util.dbchar(Request["cgrs"].Substring(0, 1));
                    ColMap["rs"] = Util.dbchar(Request["cgrs"].Substring(1, 1));
                    ColMap["rs_type"] = Util.dbnull(Request["rs_type"]);
                    ColMap["rs_class"] = Util.dbchar(Request["rs_class"]);
                    ColMap["rs_code"] = Util.dbchar(Request["rs_code"]);
                    ColMap["act_code"] = Util.dbchar(Request["act_code"]);
                    ColMap["rs_detail"] = Util.dbnull(Request["rs_detail"]);
                    ColMap["send_cl"] = Util.dbnull(Request["send_cl"]);
                    ColMap["send_cl1"] = Util.dbnull(Request["send_cl1"]);
                    ColMap["send_sel"] = Util.dbnull(Request["send_sel"]);
                    ColMap["fees"] = Util.dbzero("0");
                    ColMap["fees_stat"] = Util.dbchar("X");
                    ColMap["send_way"] = Util.dbchar(Request["send_way"]);
                    ColMap["pr_scode"] = Util.dbchar(Request["pr_scode"]);
                    ColMap["new"] = Util.dbchar("N");
                    ColMap["tot_num"] = Util.dbzero(tot_num.ToString());
                    ColMap["rs_agt_no"] = Util.dbchar(Request["rs_agt_no"]);
                    ColMap["tran_date"] = "getdate()";
                    ColMap["tran_scode"] = "'" + Session["scode"] + "'";
                    ColMap["receipt_type"] = Util.dbchar(receipt_type);
                    ColMap["receipt_title"] = Util.dbchar(receipt_title);
                    ColMap["rectitle_name"] = Util.dbchar(rectitle_name);
                    SQL += ColMap.GetInsertSQL();
                    conn.ExecuteNonQuery(SQL);

                    //抓insert後的流水號
                    SQL = "SELECT SCOPE_IDENTITY() AS Current_Identity";
                    objResult = conn.ExecuteScalar(SQL);
                    string dGetrs_sqlno = objResult.ToString();
                    Sys.showLog("子案(" + z + ")進度流水號=" + dGetrs_sqlno);

                    //案件主檔now_arcase,now_grade,now_stat
                    Sys.insert_log_table(conn, "U", prgid, "dmt", "seq;seq1", dseq + ";" + dseq1A, logReason);
                    SQL = "update dmt set ";
                    ColMap.Clear();
                    if (Request["ncase_stat"] != "") {
                        ColMap["now_arcase_type"] = Util.dbchar(Request["rs_type"]);
                        ColMap["now_arcase"] = Util.dbchar(Request["rs_code"]);
                        ColMap["now_grade"] = Util.dbzero(dstep_grade);
                        ColMap["now_stat"] = Util.dbchar(Request["ncase_stat"]);
                        ColMap["now_arcase_class"] = Util.dbchar(Request["rs_class"]);
                        ColMap["now_act_code"] = Util.dbchar(Request["act_code"]);
                    }
                    ColMap["step_grade"] = "step_grade+1";
                    SQL += ColMap.GetUpdateSQL();
                    SQL += " where seq=" + dseq + " and seq1='" + dseq1A + "'";
                    conn.ExecuteNonQuery(SQL);

                    //入文件上傳dmt_attach
                    Insert_dseq_dmt_attach(Request["seq"], Request["seq1"], Request["nstep_grade"], dseq, dseq1A, dstep_grade, Request["att_sqlno"]);

                    //入總收發文mgt_send
                    int mdfees = 0;

                    if (Request["rs_code"].Left(2) != "FD") {
                        if ((afees - mfees) >= 0) {
                            mdfees = mfees;
                        } else {
                            mdfees = afees;
                        }
                        afees -= mdfees;
                    }
                    string Getmgt_send_sqlno = Insert_mgt_send(dseq, dseq1A, dstep_grade, drs_no, dGetrs_sqlno, rs_no, "1", mdfees.ToString());
                    //法定期限銷管資料寫入總收發
                    Insert_brresp_mgt(Getmgt_send_sqlno, dtCtrl);
                    //入總收發文todo_mgt
                    Insert_todo_mgt(dseq, dseq1A, drs_no, dGetrs_sqlno);
                }
            }
        }
        //爭救案發文確認
        if (prgid1 == "brta81") {
            SQL = "Update bstep_temp Set Mark='Y'";
            SQL += ",confirm_date=getdate()";
            SQL += ",confirm_scode='" + Session["scode"] + "'";
            SQL += " where rs_no='" + rs_no + "' and opt_sqlno='" + Request["opt_sqlno"] + "'";
            conn.ExecuteNonQuery(SQL);

            SQL = "Update step_dmt Set opt_over_date=getdate()";
            SQL += "where opt_sqlno='" + Request["opt_sqlno"] + "'";
            conn.ExecuteNonQuery(SQL);
        }

        //修改程序官發確認狀態attcase_dmt,todo_dmt
        if (prgid == "brta38") {
            //入attcase_dmt_log
            Sys.insert_log_table(conn, "U", prgid, "attcase_dmt", "att_sqlno", Request["att_sqlno"], logReason);
            SQL = "update attcase_dmt set ";
            ColMap.Clear();
            ColMap["pr_scode"] = Util.dbchar(Request["pr_scode"]);//承辦人員
            ColMap["step_date"] = Util.dbchar(Request["step_date"]);//發文日期
            ColMap["mp_date"] = Util.dbchar(Request["mp_date"]);//總管處發文日期
            ColMap["send_cl"] = Util.dbchar(Request["send_cl"]);//收發單位
            ColMap["send_cl1"] = Util.dbchar(Request["send_cl1"]);//副本單位
            ColMap["send_sel"] = Util.dbchar(Request["send_sel"]);//官方號碼
            ColMap["rs_class"] = Util.dbchar(Request["rs_class"]);//結構分類
            ColMap["rs_code"] = Util.dbchar(Request["rs_code"]);//案性
            ColMap["act_code"] = Util.dbchar(Request["act_code"]);//處理事項
            ColMap["rs_detail"] = Util.dbchar(Request["rs_detail"]);//發文內容
            ColMap["fees"] = Util.dbzero(Request["fees"]);//規費支出
            ColMap["fees_stat"] = Util.dbchar(Request["fees_stat"]);//收費管制
            ColMap["rs_agt_no"] = Util.dbchar(Request["rs_agt_no"]);//發文出名代理
            ColMap["opt_branch"] = Util.dbchar(Request["opt_branch"]);//發文單位
            ColMap["sign_stat"] = Util.dbchar("SZ");//交辦狀態SZ=程序確認
            ColMap["conf_scode"] = "'" + Session["scode"] + "'";//確認人員
            ColMap["conf_date"] = "getdate()";//確認日期
            ColMap["rs_sqlno"] = "" + Getrs_sqlno + "";//進度流水號
            SQL += ColMap.GetUpdateSQL();
            SQL += " where att_sqlno=" + Util.dbchar(Request["att_sqlno"]);
            conn.ExecuteNonQuery(SQL);

            //修改todo狀態
            SQL = "update todo_dmt set ";
            ColMap.Clear();
            ColMap["job_status"] = Util.dbchar("SZ");
            ColMap["approve_scode"] = "'" + Session["scode"] + "'";
            ColMap["resp_date"] = "getdate()";
            SQL += ColMap.GetUpdateSQL();
            SQL += " where sqlno='" + Request["todo_sqlno"] + "' and job_status='NN'";
            conn.ExecuteNonQuery(SQL);
        }

        return rs_no;
    }

    //維護(submitTask=U)
    private string doUpdate() {
        string rs_no = ReqVal.TryGet("rs_no");
        
        //新增 step_dmt_Log 檔
        Sys.insert_log_table(conn, "U", HTProgCode, "step_dmt", "rs_no", rs_no, logReason);

        //新增 fees_dmt_log
        Sys.insert_log_table(conn, "U", HTProgCode, "fees_dmt", "rs_no", rs_no, logReason);
        //刪除 fees_dmt
        SQL = "delete from fees_dmt where rs_no = '" + rs_no + "'";
        conn.ExecuteNonQuery(SQL);
        //恢復case_dmt.gs_fees
        for (int i = 1; i <= Convert.ToInt32("0" + Request["oldarnum"]); i++) {
            string hngs_fees = ReqVal.TryGet("hngs_fees_" + i);
            if (hngs_fees == "") hngs_fees = "0";
            SQL = "update case_dmt set gs_fees=gs_fees-" + hngs_fees + ",gs_curr=gs_curr-1 where case_no='" + ReqVal.TryGet("oldcase_no_" + i) + "'";
            conn.ExecuteNonQuery(SQL);
        }

        for (int i = 1; i <= Convert.ToInt32("0" + Request["arnum"]); i++) {
            if (ReqVal.TryGet("case_no_" + i) != "") {
                //新增 fees_dmt
                SQL = "insert into fees_dmt ";
                ColMap.Clear();
                ColMap["rs_no"] = Util.dbchar(rs_no);
                ColMap["case_no"] = Util.dbchar(Request["case_no_" + i]);
                ColMap["fees"] = Util.dbzero(Request["gs_fees_" + i]);
                ColMap["service"] = Util.dbzero(Request["service_" + i]);
                ColMap["gs_curr"] = "" + (Convert.ToInt32(Request["gs_curr" + i]) + 1) + "";
                SQL += ColMap.GetInsertSQL();
                conn.ExecuteNonQuery(SQL);

                //將官發規費支出存入case_dmt
                //case_dmt.gs_fees加上畫面上的gs_fees
                SQL = "update case_dmt set gs_fees=gs_fees+" + Request["gs_fees_" + i] + ",gs_curr=gs_curr+1 where case_no='" + ReqVal.TryGet("case_no_" + i) + "'";
                conn.ExecuteNonQuery(SQL);
            }
        }

        //更新step_dmt
        SQL = "update step_dmt set step_date=" + Util.dbnull(Request["step_date"]);
        SQL += ",rs_type=" + Util.dbnull(Request["rs_type"]);
        if (ReqVal.TryGet("hrs_code").IN("FC11,FC21,FC5,FC6,FC7,FC8,FCH,FCI,FL5,FL6,FT2") || ReqVal.TryGet("hrs_code").Left(2) == "FD") {
            SQL += ",rs_class='" + Request["hrs_class"] + "',rs_code='" + Request["hrs_code"] + "'";
            SQL += ",act_code='" + Request["hact_code"] + "'";
        } else {
            SQL += ",rs_class='" + Request["rs_class"] + "',rs_code='" + Request["rs_code"] + "'";
            SQL += ",act_code='" + Request["act_code"] + "'";
        }
        SQL += ",rs_detail=" + Util.dbnull(Request["rs_detail"]);
        SQL += ",mp_date=" + Util.dbnull(Request["mp_date"]) + ",send_cl=" + Util.dbnull(Request["send_cl"]);
        SQL += ",send_cl1=" + Util.dbnull(Request["send_cl1"]) + ",send_sel=" + Util.dbnull(Request["send_sel"]);
        SQL += ",send_way=" + Util.dbnull(Request["send_way"]);
        SQL += ",fees=" + Request["fees"] + ",fees_stat='" + Request["fees_stat"] + "'";
        SQL += ",pr_scode='" + Request["pr_scode"] + "',opt_branch='" + Request["opt_branch"] + "'";
        SQL += ",tot_num=" + tot_num + ",rs_agt_no='" + Request["rs_agt_no"] + "'";
        SQL += ",tran_date=getdate(),tran_scode='" + Session["scode"] + "'";
        SQL += ",receipt_type='" + receipt_type + "'";
        SQL += ",receipt_title='" + receipt_title + "'";
        SQL += ",rectitle_name=" + Util.dbchar(rectitle_name);
        SQL += " where rs_no='" + rs_no + "'";
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

        //更新ctrl_dmt
        SQL = "delete from ctrl_dmt where rs_no='" + rs_no + "'";
        conn.ExecuteNonQuery(SQL);
        //入ctrl_dmt
        for (int c = 1; c <= Convert.ToInt32("0" + Request["ctrlnum"]); c++) {
            if (Request["delchk_" + c] != "Y") {
                if (ReqVal.TryGet("ctrl_type_" + c) != "" && ReqVal.TryGet("ctrl_date_" + c) != "") {
                    SQL = "insert into ctrl_dmt ";
                    ColMap.Clear();
                    ColMap["rs_no"] = Util.dbchar(rs_no);
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
        DataTable dtCtrl = new DataTable();
        if (Request["rsqlno"] != "") {
            //keep資料-寫入總收發銷管暫存檔用
            SQL = "select seq,seq1,(select rs_sqlno from step_dmt s where s.rs_no=c.rs_no)br_rs_sqlno ";
            SQL += ",step_grade,'" + Request["nstep_grade"] + "'br_resp_grade,ctrl_type,ctrl_remark ";
            SQL += ",ctrl_date,'" + Request["step_date"] + "' resp_date,convert(varchar,tran_date,120) ctrl_tran_date ";
            SQL += ",tran_scode ctrl_tran_scode ";
            SQL += "from ctrl_dmt c ";
            SQL += "where sqlno in('" + Request["rsqlno"].Replace(";", "','") + "') ";
            SQL += "and sqlno<>'' ";
            SQL += "and (ctrl_type='A1' or ctrl_type like 'A4%') ";//條件同官發回條列印
            conn.DataTable(SQL, dtCtrl);

            //新增至 resp_dmt
            SQL = "insert into resp_dmt(sqlno,rs_no,branch,seq,seq1,step_grade,resp_grade,ctrl_type,ctrl_remark,ctrl_date,resp_date,tran_date,tran_scode) ";
            SQL += "select sqlno,rs_no,branch,seq,seq1,step_grade,'" + Request["nstep_grade"] + "',ctrl_type,ctrl_remark,ctrl_date,'" + Request["step_date"] + "',getdate(),'" + Session["scode"] + "' ";
            SQL += "from ctrl_dmt where sqlno in('" + Request["rsqlno"].Replace(";", "','") + "') and sqlno<>''";
            conn.ExecuteNonQuery(SQL);

            //由 ctrl_dmt 中刪除
            SQL = "delete from ctrl_dmt where sqlno in('" + Request["rsqlno"].Replace(";", "','") + "') and sqlno<>''";
            conn.ExecuteNonQuery(SQL);
        }

        //修改註冊費繳費次數
        SQL = "update dmt set pay_times = " + Util.dbnull(Request["hpay_times"]);
        SQL += ",pay_date = " + Util.dbnull(Request["pay_date"]);
        SQL += " where seq=" + Request["seq"] + " and seq1='" + Request["seq1"] + "'";
        conn.ExecuteNonQuery(SQL);

        //案件主檔now_arcase,now_grade,now_stat
        //若案件主檔案件狀態進度序號小於等於進度序號，則修改案件狀態
        if (Convert.ToInt32(Request["nstep_grade"]) >= Convert.ToInt32(Request["now_grade"])) {
            if (Request["ncase_stat"] != "") {
                SQL = "update dmt set now_arcase_type=" + Util.dbnull(Request["rs_type"]);
                SQL += ", now_arcase=" + Util.dbchar(Request["rs_code"]);
                SQL += ",now_grade=" + Util.dbzero(Request["nstep_grade"]);
                SQL += "now_stat=" + Util.dbchar(Request["ncase_stat"]);
                SQL += ",now_arcase_class=" + Util.dbchar(Request["rs_class"]);
                SQL += ",now_act_code=" + Util.dbchar(Request["act_code"]);
                SQL += " where seq=" + Request["seq"] + " and seq1='" + Request["seq1"] + "'";
            } else {
                //若本次收文案件狀態為 empty 且案件主檔案件狀態進度序號等於本次進度
                //則需找到之前最後一筆的案件狀態且 Update 案件主檔
                if (Convert.ToInt32(Request["now_grade"]) >= Convert.ToInt32(Request["nstep_grade"])) {
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
                }
            }
            conn.ExecuteNonQuery(SQL);
        }

        //計算入總收發文之逐案規費
        int mfees = 0;
        if (mtot_num == 1) {
            mfees = Convert.ToInt32(Request["fees"]);//母案規費
        } else {
            if (Request["rs_code"].Left(2) == "FD") {
                mfees = Convert.ToInt32(Request["fees"]);//母案規費
            } else {
                mfees = Convert.ToInt32(Request["fees"]) / mtot_num;
            }
        }
        string Getmgt_send_sqlno = Update_mgt_send(Request["seq"], Request["seq1"], rs_no, mtot_num.ToString(), mfees.ToString());
        //法定期限銷管資料寫入總收發
        Insert_brresp_mgt(Getmgt_send_sqlno, dtCtrl);

        //案性為變更時,相關案件存檔
        if (ReqVal.TryGet("rs_code").IN("FC11,FC21,FC5,FC6,FC7,FC8,FCH,FCI,FL5,FL6,FT2") || ReqVal.TryGet("rs_code").Left(2) == "FD"
            || ReqVal.TryGet("hrs_code").IN("FC11,FC21,FC5,FC6,FC7,FC8,FCH,FCI,FL5,FL6,FT2") || ReqVal.TryGet("hrs_code").Left(2) == "FD"
            ) {
            int afees = Convert.ToInt32(Request["fees"]) - mfees;
            for (int z = 1; z <= Convert.ToInt32("0" + Request["tot_num"]); z++) {
                string dseq = ReqVal.TryGet("dseq_" + z);
                string dseq1A = ReqVal.TryGet("dseq1A_" + z);
                if (dseq != "" && dseq1A != "") {
                    //判斷是否已存在 step_dmt 案件主檔
                    string dr_rs_no = "", dr_step_grade = "0";
                    SQL = " select * from step_dmt where main_rs_no = '" + rs_no + "' ";
                    SQL += " and seq=" + dseq + " and seq1 = '" + dseq1A + "' ";
                    using (SqlDataReader dr0 = conn.ExecuteReader(SQL)) {
                        if (dr0.Read()) {
                            dr_rs_no = dr0.SafeRead("rs_no", "");
                            dr_step_grade = dr0.SafeRead("step_grade", "0");
                        }
                    }

                    if (Request["dseqdel_" + z] != "D") {
                        //計算入總收發文子案的規費
                        int mdfees = 0;
                        if (Request["rs_code"].Left(2) != "FD") {
                            if ((afees - mfees) >= 0) {
                                mdfees = mfees;
                            } else {
                                mdfees = afees;
                            }
                            afees -= mdfees;
                        }

                        if (dr_rs_no != "") {//已存在進度檔, 修改即可
                            //新增 step_dmt_Log 檔
                            Sys.insert_log_table(conn, "D", HTProgCode, "step_dmt", "rs_no", dr_rs_no, logReason);
                            //更新step_dmt
                            SQL = "update step_dmt set step_date=" + Util.dbnull(Request["step_date"]);
                            SQL += ",rs_type=" + Util.dbnull(Request["rs_type"]);
                            SQL += ",rs_detail=" + Util.dbnull(Request["rs_detail"]);
                            SQL += ",mp_date=" + Util.dbnull(Request["mp_date"]) + ",send_cl=" + Util.dbnull(Request["send_cl"]);
                            SQL += ",send_cl1=" + Util.dbnull(Request["send_cl1"]) + ",send_sel=" + Util.dbnull(Request["send_sel"]);
                            SQL += ",send_way=" + Util.dbnull(Request["send_way"]);
                            SQL += ",pr_scode='" + Request["pr_scode"] + "'";
                            SQL += ",tot_num=" + tot_num;
                            SQL += ",tran_date=getdate(),tran_scode='" + Session["scode"] + "'";
                            SQL += ",receipt_type='" + receipt_type + "'";
                            SQL += ",receipt_title='" + receipt_title + "'";
                            SQL += ",rectitle_name=" + Util.dbchar(rectitle_name);
                            SQL += " where rs_no='" + dr_rs_no + "'";
                            conn.ExecuteNonQuery(SQL);
                            //修改總收發文資料
                            Getmgt_send_sqlno = Update_mgt_send(dseq, dseq1A, dr_rs_no, "1", mdfees.ToString());
                            //法定期限銷管資料寫入總收發
                            Insert_brresp_mgt(Getmgt_send_sqlno, dtCtrl);
                        } else {//新增加之子本所編號. 要新增案件進度檔
                            string drs_no = getRsNo();//取得新發文序號

                            //取得案件進度
                            //若案件主檔案件狀態進度序號等於進度序號，則修改案件狀態
                            SQL = "select step_grade+1 step_grade,isnull(now_grade,0) as now_grade from dmt where seq=" + dseq + " and seq1='" + dseq1A + "'";
                            string dstep_grade = "0", dnow_grade = "0";
                            using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
                                if (dr.Read()) {
                                    dstep_grade = dr.SafeRead("step_grade", "0");
                                    dnow_grade = dr.SafeRead("now_grade", "0");
                                }
                            }

                            //入step_dmt	
                            SQL = "insert into step_dmt ";
                            ColMap.Clear();
                            ColMap["rs_no"] = Util.dbchar(drs_no);
                            ColMap["branch"] = Util.dbchar(Sys.GetSession("seBranch"));
                            ColMap["seq"] = Util.dbnull(dseq);
                            ColMap["seq1"] = Util.dbchar(dseq1A);
                            ColMap["step_grade"] = Util.dbnull(dstep_grade);
                            ColMap["main_rs_no"] = Util.dbchar(rs_no);
                            ColMap["step_date"] = Util.dbnull(Request["step_date"]);
                            ColMap["mp_date"] = Util.dbnull(Request["mp_date"]);
                            ColMap["cg"] = Util.dbchar(Request["cgrs"].Substring(0, 1));
                            ColMap["rs"] = Util.dbchar(Request["cgrs"].Substring(1, 1));
                            ColMap["rs_type"] = Util.dbnull(Request["rs_type"]);
                            ColMap["rs_class"] = Util.dbchar(Request["hrs_class"]);
                            ColMap["rs_code"] = Util.dbchar(Request["hrs_code"]);
                            ColMap["act_code"] = Util.dbchar(Request["hact_code"]);
                            ColMap["rs_detail"] = Util.dbnull(Request["rs_detail"]);
                            ColMap["send_cl"] = Util.dbnull(Request["send_cl"]);
                            ColMap["send_cl1"] = Util.dbnull(Request["send_cl1"]);
                            ColMap["send_sel"] = Util.dbnull(Request["send_sel"]);
                            ColMap["fees"] = Util.dbzero("0");
                            ColMap["fees_stat"] = Util.dbchar("X");
                            ColMap["send_way"] = Util.dbchar(Request["send_way"]);
                            ColMap["pr_scode"] = Util.dbchar(Request["pr_scode"]);
                            ColMap["new"] = Util.dbchar("N");
                            ColMap["tot_num"] = Util.dbzero(tot_num.ToString());
                            ColMap["rs_agt_no"] = Util.dbchar(Request["rs_agt_no"]);
                            ColMap["tran_date"] = "getdate()";
                            ColMap["tran_scode"] = "'" + Session["scode"] + "'";
                            ColMap["receipt_type"] = Util.dbnull(receipt_type);
                            ColMap["receipt_title"] = Util.dbnull(receipt_title);
                            ColMap["rectitle_name"] = Util.dbnull(rectitle_name);
                            SQL += ColMap.GetInsertSQL();
                            conn.ExecuteNonQuery(SQL);

                            //抓insert後的流水號
                            SQL = "SELECT SCOPE_IDENTITY() AS Current_Identity";
                            objResult = conn.ExecuteScalar(SQL);
                            string dGetrs_sqlno = objResult.ToString();
                            Sys.showLog("子案(" + z + ")進度流水號=" + dGetrs_sqlno);

                            //案件主檔now_arcase,now_grade,now_stat
                            Sys.insert_log_table(conn, "U", prgid, "dmt", "seq;seq1", dseq + ";" + dseq1A, logReason);
                            SQL = "update dmt set ";
                            ColMap.Clear();
                            if (Convert.ToInt32(dstep_grade) >= Convert.ToInt32(dnow_grade) && Request["ncase_stat"] != "") {
                                ColMap["now_arcase_type"] = Util.dbchar(Request["rs_type"]);
                                ColMap["now_arcase"] = Util.dbchar(Request["hrs_code"]);
                                ColMap["now_grade"] = Util.dbzero(dstep_grade);
                                ColMap["now_stat"] = Util.dbchar(Request["ncase_stat"]);
                                ColMap["now_arcase_class"] = Util.dbchar(Request["hrs_class"]);
                                ColMap["now_act_code"] = Util.dbchar(Request["hact_code"]);
                            }
                            ColMap["step_grade"] = "step_grade+1";
                            SQL += ColMap.GetUpdateSQL();
                            SQL += " where seq=" + dseq + " and seq1='" + dseq1A + "'";
                            conn.ExecuteNonQuery(SQL);
                        }
                    } else {//子本所編號 的 刪除 checked	
                        //已存在進度檔, 將之刪除; 若為新增之本所編號又要刪除且與已存在之本所編號重覆 hrs_no 會是空的, 不做此判斷的話會把已存在的重覆本所編號一起刪除
                        if (dr_rs_no != "" && Request["hrs_no_" + z] != "") {
                            //刪除發文主檔
                            //新增 step_dmt_Log 檔
                            Sys.insert_log_table(conn, "D", HTProgCode, "step_dmt", "rs_no", dr_rs_no, logReason);

                            //刪除 step_dmt
                            SQL = "delete step_dmt where rs_no='" + dr_rs_no + "'";
                            conn.ExecuteNonQuery(SQL);

                            //刪除總收發文mgt_send,todo_mgt
                            Delete_mgt_send(dseq, dseq1A, dr_rs_no);

                            //若案件主檔案件狀態進度序號等於進度序號，則修改案件狀態
                            SQL = "select step_grade,isnull(now_grade,0) as now_grade from dmt where seq=" + dseq + " and seq1='" + dseq1A + "'";
                            string dstep_grade = "0", dnow_grade = "0";
                            using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
                                if (dr.Read()) {
                                    dstep_grade = dr.SafeRead("step_grade", "0");
                                    dnow_grade = dr.SafeRead("now_grade", "0");
                                }
                            }

                            if (dr_rs_no != "") {
                                //更新主檔進度序號
                                if (Convert.ToInt32(dstep_grade) == Convert.ToInt32(dr_step_grade)) {
                                    SQL = "select max(step_grade) as step_grade from vstep_dmt ";
                                    SQL += " where seq = " + dseq + " and seq1='" + dseq1A + "' and step_grade <> '" + dr_step_grade + "'";
                                    object objResult = conn.ExecuteScalar(SQL);
                                    string rstep_grade = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();

                                    SQL = " update dmt set seq = seq ";
                                    if (rstep_grade != "") SQL += " ,step_grade = '" + rstep_grade + "'";
                                    SQL += " where seq = " + dseq + " and seq1='" + dseq1A + "'";
                                    conn.ExecuteNonQuery(SQL);
                                }

                                //更新主檔 now_arcase, now_stat ..... 等欄位
                                if (Convert.ToInt32(dnow_grade) == Convert.ToInt32(dr_step_grade)) {
                                    SQL = "select * from vstep_dmt a, vcode_act b";
                                    SQL += " where a.seq = " + dseq;
                                    SQL += "   and a.seq1 = '" + dseq1A + "'";
                                    SQL += "   and a.rs_no <> '" + dr_rs_no + "'";
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
                                    SQL += " where seq = " + dseq + " and seq1='" + dseq1A + "'";
                                    conn.ExecuteNonQuery(SQL);
                                }
                            }
                        }
                    }
                }
            }
        }

        //入帳款 區所account.plus_temp
        for (int i = 1; i <= Convert.ToInt32("0" + Request["arnum"]); i++) {
            if (ReqVal.TryGet("case_no_" + i) != "") {
                //取得案件主檔營洽
                string dmt_scode = "";
                SQL = "select scode from dmt where seq=" + Request["seq"] + " and seq1='" + Request["seq1"] + "'";
                objResult = conn.ExecuteScalar(SQL);
                dmt_scode = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();

                //2012/12/18因電子申請的mstat_flag=YE，狀況等同一般送件mstat_flag=YY，所以增加判斷
                SQL = "select count(*) from plus_temp where branch='" + Session["seBranch"] + "' and dept='" + Session["dept"] + "'";
                SQL += " and rs_no='" + rs_no + "' and case_no='" + Request["case_no_" + i] + "' and (chk_type='Y' or mstat_flag='YY' or mstat_flag='YE')";
                objResult = conn.ExecuteScalar(SQL);
                int plus_temp_count = (objResult == DBNull.Value || objResult == null) ? 0 : Convert.ToInt32(objResult);
                string chk_type = "N";
                if (plus_temp_count > 0) chk_type = "Y";

                //將規費資料寫入帳款系統plus_temp
                if (chk_type == "N") {
                    if (Convert.ToInt32(Request["gs_fees_" + i]) > 0) {
                        //取得交辦案性及請款註記
                        string lcase_arcase = "", lar_mark = "";
                        SQL = "select arcase,ar_mark from case_dmt where case_no='" + Request["case_no_" + i] + "'";
                        using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
                            if (dr.Read()) {
                                lcase_arcase = dr.SafeRead("arcase", "");
                                lar_mark = dr.SafeRead("ar_mark", "");
                            }
                        }

                        SQL = "insert into plus_temp ";
                        ColMap.Clear();
                        ColMap["class"] = Util.dbchar("1");
                        ColMap["tr_date"] = Util.dbchar(DateTime.Today.ToShortDateString());
                        ColMap["tr_scode"] = "'" + Session["scode"] + "'";
                        ColMap["send_date"] = Util.dbchar(Request["step_date"]);
                        ColMap["branch"] = "'" + Session["seBranch"] + "'";
                        ColMap["dept"] = "'" + Sys.GetSession("dept").ToUpper() + "'";
                        ColMap["case_no"] = Util.dbchar(Request["case_no_" + i]);
                        ColMap["rs_no"] = Util.dbchar(rs_no);
                        ColMap["seq"] = Util.dbchar(Request["seq"]);
                        ColMap["seq1"] = Util.dbchar(Request["seq1"]);
                        ColMap["country"] = Util.dbchar("T");
                        ColMap["cust_seq"] = Util.dbchar(Request["cust_seq"]);
                        ColMap["scode"] = Util.dbchar(dmt_scode);
                        ColMap["case_arcase"] = Util.dbchar(lcase_arcase);
                        ColMap["arcase"] = Util.dbchar(Request["rs_code"]);
                        ColMap["ar_mark"] = Util.dbchar(lar_mark);
                        ColMap["tr_money"] = Util.dbzero(Request["gs_fees_" + i]);
                        ColMap["chk_type"] = Util.dbchar("N");
                        ColMap["chk_date"] = "null";
                        ColMap["mstat_flag"] = Util.dbchar("NN");
                        ColMap["mstat_date"] = "null";
                        SQL += ColMap.GetInsertSQL();
                        conni2.ExecuteNonQuery(SQL);
                    }
                }
            }
        }

        return rs_no;
    }

    //刪除(submitTask=D)
    private string doDelete() {
        string rs_no = ReqVal.TryGet("rs_no");
        
        //新增 ctrl_dmt_log
        for (int i = 1; i <= Convert.ToInt32("0" + Request["ctrlnum"]); i++) {
            Sys.insert_log_table(conn, "D", HTProgCode, "ctrl_dmt", "sqlno", Request["sqlno_" + i], logReason);
        }

        //刪除 ctrl_dmt
        SQL = "delete from ctrl_dmt where rs_no='" + rs_no + "'";
        conn.ExecuteNonQuery(SQL);

        //取消銷管,還原至ctrl_dmt
        //新增 resp_dmt_log
        Sys.insert_log_table(conn, "D,A", HTProgCode, "resp_dmt", "seq;seq1;resp_grade", Request["seq"] + ";" + Request["seq1"] + ";" + Request["nstep_grade"], logReason);
        //新增 ctrl_dmt
        SQL = "insert into ctrl_dmt(rs_no,branch,seq,seq1,step_grade,ctrl_type,ctrl_remark,ctrl_date,tran_date,tran_scode) ";
        SQL += "select rs_no,branch,seq,seq1,step_grade,ctrl_type,ctrl_remark,ctrl_date,getdate(),'" + Session["scode"] + "' ";
        SQL += "from resp_dmt where where seq=" + Request["seq"] + " and seq1='" + Request["seq1"] + "' and step_grade='" + Request["nstep_grade"] + "'";
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

        //新增 fees_dmt_log
        Sys.insert_log_table(conn, "D", HTProgCode, "fees_dmt", "rs_no", rs_no, logReason);
        //刪除 fees_dmt
        SQL = "delete from fees_dmt where rs_no = '" + rs_no + "'";
        conn.ExecuteNonQuery(SQL);
        for (int i = 1; i <= Convert.ToInt32("0" + Request["oldarnum"]); i++) {
            //恢復case_dmt.gs_fees
            string hngs_fees = ReqVal.TryGet("hngs_fees_" + i);
            if (hngs_fees == "") hngs_fees = "0";
            SQL = "update case_dmt set gs_fees=gs_fees-" + hngs_fees + ",gs_curr=gs_curr-1 where case_no='" + ReqVal.TryGet("case_no_" + i) + "'";
            conn.ExecuteNonQuery(SQL);
        }

        //刪除發文主檔
        //新增 step_dmt_Log 檔
        Sys.insert_log_table(conn, "D", HTProgCode, "step_dmt", "rs_no", rs_no, logReason);
        //刪除 step_dmt
        SQL = "delete step_dmt where rs_no=''" + rs_no + "'";
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

        //案性為變更時,相關案件存檔
        if (ReqVal.TryGet("hrs_code").IN("FC11,FC21,FC5,FC6,FC7,FC8,FCH,FCI,FL5,FL6,FT2") || ReqVal.TryGet("hrs_code").Left(2) == "FD") {
            for (int i = 1; i <= Convert.ToInt32("0" + Request["tot_num"]); i++) {
                string dseq = ReqVal.TryGet("dseq_" + i);
                string dseq1A = ReqVal.TryGet("dseq1A_" + i);
                if (dseq != "" && dseq1A != "") {
                    //判斷是否已存在 step_dmt 案件主檔
                    SQL = " select * from step_dmt where main_rs_no = '" + rs_no + "' ";
                    SQL += " and seq=" + dseq + " and seq1 = '" + dseq1A + "' ";
                    if (Request["hrs_no_"+i] !=""){
					    SQL+= " and rs_no = '" +Request["hrs_no_"+i]+ "'";
				    }
                    using (SqlDataReader dr0 = conn.ExecuteReader(SQL)) {
                        if (dr0.Read()) {//已存在進度檔, 將之刪除
                            //刪除發文主檔
                            //新增 step_dmt_Log 檔
                            Sys.insert_log_table(conn, "D", HTProgCode, "step_dmt", "rs_no", dr0.SafeRead("rs_no", ""), logReason);
                            //刪除 step_dmt
                            SQL = "delete step_dmt where rs_no=''" + dr0.SafeRead("rs_no", "") + "'";
                            conn.ExecuteNonQuery(SQL);

                            //若案件主檔案件狀態進度序號等於進度序號，則修改案件狀態
                            SQL = "select step_grade,isnull(now_grade,0) as now_grade from dmt where seq=" + dseq + " and seq1='" + dseq1A + "'";
                            string dstep_grade = "0", dnow_grade = "0";
                            using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
                                if (dr.Read()) {
                                    dstep_grade = dr.SafeRead("step_grade", "0");
                                    dnow_grade = dr.SafeRead("now_grade", "0");
                                }
                            }

                            //若主檔進度序號等與此進度序號則取得前一筆進度序號並 update 主檔 step_grade
                            if (Convert.ToInt32(dstep_grade) == Convert.ToInt32(dr0.SafeRead("step_grade", ""))) {
                                SQL = "select max(step_grade) as step_grade from vstep_dmt ";
                                SQL += " where seq = " + dseq + " and seq1='" + dseq1A + "' and step_grade <> '" + dr0.SafeRead("step_grade", "") + "'";
                                object objResult = conn.ExecuteScalar(SQL);
                                string rstep_grade = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();

                                SQL = " update dmt set seq = seq ";
                                if (rstep_grade != "") SQL += " ,step_grade = '" + rstep_grade + "'";
                                SQL += " where seq = " + dseq + " and seq1='" + dseq1A + "'";
                                conn.ExecuteNonQuery(SQL);
                            }

                            //更新主檔 now_arcase, now_stat ..... 等欄位
                            if (Convert.ToInt32(dnow_grade) == Convert.ToInt32(dr0.SafeRead("step_grade", ""))) {
                                SQL = "select * from vstep_dmt a, vcode_act b";
                                SQL += " where a.seq = " + dseq;
                                SQL += "   and a.seq1 = '" + dseq1A + "'";
                                SQL += "   and a.rs_no <> '" + dr0.SafeRead("rs_no", "") + "'";
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
                                SQL += " where seq = " + dseq + " and seq1='" + dseq1A + "'";
                                conn.ExecuteNonQuery(SQL);
                            }
                        }
                    }
                }
            }
        }

        //區所account db:刪除區所.account.plus_temp.chk_type='N'的資料
        Sys.insert_log_table(conni2, "D", prgid, "plus_temp", "branch;dept;rs_no;chk_type", Session["seBranch"] + ";" + Session["dept"] + ";" + rs_no + ";N", logReason);
        SQL = "delete from plus_temp where branch='" + Session["seBranch"] + "' and dept='" + Session["dept"] + "'";
        SQL += " and rs_no='" + rs_no + "' and chk_type='N'";
        conni2.ExecuteNonQuery(SQL);
        //2011/10/27總所iaccount刪除array.iaccount.iacct_gsin,iacct_gsinap資料seq_chk=NN and tax_chk=NN才能刪除
        //2013/3/22增加acc_chk=NN才能刪除
        SQL = "select seq_chk,tax_chk,acc_chk from iacct_gsin where branch='" + Session["seBranch"] + "' and dept='" + Session["dept"] + "' and rs_sqlno=" + Request["rs_sqlno"];
        using (SqlDataReader dr = conniacc.ExecuteReader(SQL)) {
            if (dr.Read()) {
                if (dr.SafeRead("seq_chk", "") == "NN" && dr.SafeRead("tax_chk", "") == "NN" && dr.SafeRead("acc_chk", "") == "NN") {
                    SQL = "delete from iacct_gsin where branch='" + Session["seBranch"] + "' and dept='" + Session["dept"] + "'";
                    SQL += " and rs_sqlno=" + Request["rs_sqlno"];
                    conniacc.ExecuteNonQuery(SQL);

                    SQL = "delete from iacct_gsinap where branch='" + Session["seBranch"] + "' and dept='" + Session["dept"] + "'";
                    SQL += " and rs_sqlno=" + Request["rs_sqlno"];
                    conniacc.ExecuteNonQuery(SQL);
                }
            }
        }

        return rs_no;
    }
    
    //20160901 增加[退回]功能(submitTask=R)
    private void doBack() {
        //入attcase_dmt_log
        Sys.insert_log_table(conn, "U", prgid, "attcase_dmt", "att_sqlno", Request["att_sqlno"], logReason);

        SQL = "update attcase_dmt set sign_stat='NN' ";//交辦狀態NN=未交辦
        SQL += ",todo_sqlno='" + Request["todo_sqlno"] + "' ";
        SQL += " where att_sqlno=" + Request["att_sqlno"];//流水號
        conn.ExecuteNonQuery(SQL);

        SQL = "update todo_dmt set job_status='XS' ";//作業狀態XS=程序退回
        SQL += ",approve_scode='" + Session["scode"] + "' ";
        SQL += ",approve_desc=" + Util.dbchar(Request["approve_desc"]) + " ";
        SQL += ",resp_date=getdate() ";
        SQL += " where sqlno=" + Request["todo_sqlno"] + " and job_status='NN' ";
        conn.ExecuteNonQuery(SQL);

        string in_team = Sys.getCodeName(conn, "sysctrl.dbo.scode_group", "grpid", "where grpclass='" + Session["seBranch"] + "' and scode='" + Request["in_scode"] + "'");
        string job_team = Sys.getCodeName(conn, "sysctrl.dbo.scode_group", "grpid", "where grpclass='" + Session["seBranch"] + "'  and scode='" + Request["pr_scode"] + "'");

        SQL = "insert into todo_dmt ";
        ColMap.Clear();
        ColMap["pre_sqlno"] = Util.dbnull(Request["todo_sqlno"]);
        ColMap["syscode"] = "'" + Session["syscode"] + "'";
        ColMap["apcode"] = "'" + HTProgCode + "'";
        ColMap["temp_rs_sqlno"] = Util.dbnull(Request["att_sqlno"]);
        ColMap["seq"] = Util.dbnull(Request["seq"]);
        ColMap["seq1"] = Util.dbchar(Request["seq1"]);
        ColMap["step_grade"] = Util.dbchar(Request["step_grade"]);
        ColMap["from_flag"] = Util.dbchar("CGRS");
        ColMap["in_date"] = "getdate()";
        ColMap["in_scode"] = "'" + Session["scode"] + "'";
        ColMap["dowhat"] = Util.dbchar("DP_GS");//承辦交辦發文,ref:cust_code.code_type='Ttodo'
        ColMap["job_scode"] = Util.dbchar(Request["pr_scode"]);
        ColMap["job_team"] = Util.dbchar(job_team);
        ColMap["job_status"] = Util.dbchar("NN");
        ColMap["branch"] = "'" + Session["seBranch"] + "'";
        ColMap["in_team"] = Util.dbchar(in_team);
        ColMap["case_in_scode"] = Util.dbchar(Request["in_scode"]);
        ColMap["in_no"] = Util.dbchar(Request["in_no"]);
        ColMap["case_no"] = Util.dbchar(Request["case_no"]);
        SQL += ColMap.GetInsertSQL();
        conn.ExecuteNonQuery(SQL);
    }
    
    //新增總收發文mgt_send
    private string Insert_mgt_send(string tseq, string tseq1, string tstep_grade, string trs_no, string tgetrs_sqlno, string tmrs_no, string add_count, string fees) {
        string Getmgt_send_sqlno = "";
        //判斷是否為第一次官發
        SQL = "select isnull(min(step_grade),0) as min_step_grade from step_dmt where seq=" + tseq + " and seq1='" + tseq1 + "' and cg='G' and rs='S'";
        objResult = conn.ExecuteScalar(SQL);
        string case_new = (Convert.ToInt32(objResult) == 0 || Convert.ToInt32(objResult) == Convert.ToInt32(tstep_grade)) ? "Y" : "N";

        //抓取案件主檔基本資料
        DataTable dtVDmtall = Sys.GetVDmtall(conn, tseq, tseq1);
        if (dtVDmtall.Rows.Count > 0) {
            DataRow dr = dtVDmtall.Rows[0];

            //當副碼為M時，國別為CM
            string tcountry = "T";
            if (tseq1.Left(1) == "M") tcountry = "CM";

            SQL = "insert into mgt_send(seq_area0,seq_area,seq,seq1,br_in_date,br_step_grade,br_rs_sqlno,mseq,mseq1";
            SQL += ",rs_no,mrs_no,rs_type,rs_class,rs_class_name,rs_code,rs_code_name,act_code,act_code_name,rs_detail,send_cl";
            SQL += ",send_cl1,class_count,add_count,case_new,fees,step_date,mp_date,cappl_name,eappl_name,s_mark1,country";
            SQL += ",apply_date,apply_no,issue_date,issue_no2,issue_no3,open_date,pay_times,pay_date,term1,term2,end_date";
            SQL += ",end_code,source,send_status,branch_date,branch_scode,tran_date,tran_scode,agt_no,send_way";
            SQL += ",receipt_type,receipt_title,issue_type";
            SQL += ") values (";
            SQL += "'" + Session["seBranch"] + "','" + Session["seBranch"] + "'," + tseq + ",'" + tseq1 + "'";
            SQL += "," + Util.dbnull(dr.GetDateTimeString("in_date", "yyyy/M/d")) + "," + tstep_grade + "," + tgetrs_sqlno + "," + Util.dbnull(dr.SafeRead("mseq", ""));
            SQL += "," + Util.dbchar(dr.SafeRead("mseq1", "")) + ",'" + trs_no + "','" + tmrs_no + "','" + Request["rs_type"] + "','" + Request["rs_class"] + "'";
            SQL += ",'" + Request["rs_class_name"] + "','" + Request["rs_code"] + "','" + Request["rs_code_name"] + "','" + Request["act_code"] + "'";
            SQL += ",'" + Request["act_code_name"] + "','" + Request["rs_detail"] + "','" + Request["send_cl"] + "','" + Request["send_cl1"] + "'";
            SQL += "," + Util.dbzero(dr.SafeRead("class_count", "")) + "," + add_count + ",'" + case_new + "'," + Util.dbzero(fees) + "," + Util.dbnull(Request["step_date"]);
            SQL += "," + Util.dbnull(Request["mp_date"]) + "," + Util.dbchar(dr.SafeRead("appl_name", "")) + "," + Util.dbchar(dr.SafeRead("eappl_name", ""));
            SQL += "," + Util.dbchar(dr.SafeRead("s_mark", "")) + ",'" + tcountry + "'," + Util.dbnull(dr.GetDateTimeString("apply_date", "yyyy/M/d"));
            SQL += "," + Util.dbchar(dr.SafeRead("apply_no", "")) + "," + Util.dbnull(dr.GetDateTimeString("issue_date", "yyyy/M/d"));
            SQL += "," + Util.dbchar(dr.SafeRead("issue_no", "")) + "," + Util.dbchar(dr.SafeRead("rej_no", ""));
            SQL += "," + Util.dbnull(dr.GetDateTimeString("open_date", "yyyy/M/d")) + "," + Util.dbchar(dr.SafeRead("pay_times", ""));
            SQL += "," + Util.dbnull(dr.GetDateTimeString("pay_date", "yyyy/M/d")) + "," + Util.dbnull(dr.GetDateTimeString("term1", "yyyy/M/d"));
            SQL += "," + Util.dbnull(dr.GetDateTimeString("term2", "yyyy/M/d")) + "," + Util.dbnull(dr.GetDateTimeString("end_date", "yyyy/M/d"));
            SQL += "," + Util.dbchar(dr.SafeRead("end_code", "")) + ",'B','NN'";
            SQL += ",getdate(),'" + Session["scode"] + "',getdate(),'" + Session["scode"] + "','" + Request["rs_agt_no"] + "','" + Request["send_way"] + "'";
            SQL += "," + Util.dbnull(Request["receipt_type"]) + "," + Util.dbnull(Request["receipt_title"]) + "," + Util.dbnull(issue_type);
            SQL += ")";
            connm.ExecuteNonQuery(SQL);

            //抓insert後的流水號
            SQL = "SELECT SCOPE_IDENTITY() AS Current_Identity";
            objResult = connm.ExecuteScalar(SQL);
            Getmgt_send_sqlno = objResult.ToString();
            Sys.showLog("總收發流水號=" + Getmgt_send_sqlno);
        }
        return Getmgt_send_sqlno;
    }
    
    //法定期限銷管資料寫入總收發
    private void Insert_brresp_mgt(string send_sqlno, DataTable dtCtrlDmt) {
        if (send_sqlno != "") {
            for (int i = 0; i < dtCtrlDmt.Rows.Count; i++) {
                DataRow dr = dtCtrlDmt.Rows[i];

                SQL = "insert into brresp_mgt ";
                ColMap.Clear();
                ColMap["send_sqlno"] = Util.dbchar(send_sqlno);
                ColMap["seq"] = Util.dbchar(dr.SafeRead("seq", ""));
                ColMap["seq1"] = Util.dbchar(dr.SafeRead("seq1", ""));
                ColMap["br_rs_sqlno"] = Util.dbchar(dr.SafeRead("br_rs_sqlno", ""));
                ColMap["br_step_grade"] = Util.dbchar(dr.SafeRead("step_grade", ""));
                ColMap["br_resp_grade"] = Util.dbchar(dr.SafeRead("br_resp_grade", ""));
                ColMap["ctrl_type"] = Util.dbchar(dr.SafeRead("ctrl_type", ""));
                ColMap["ctrl_remark"] = Util.dbchar(dr.SafeRead("ctrl_remark", ""));
                ColMap["ctrl_date"] = Util.dbchar(dr.GetDateTimeString("ctrl_date", "yyyy/M/d"));
                ColMap["resp_date"] = Util.dbchar(dr.GetDateTimeString("resp_date", "yyyy/M/d"));
                ColMap["ctrl_tran_date"] = Util.dbnull(dr.GetDateTimeString("ctrl_tran_date", "yyyy/M/d HH:mm:ss"));
                ColMap["ctrl_tran_scode"] = Util.dbchar(dr.SafeRead("ctrl_tran_scode", ""));
                ColMap["tran_date"] = "getdate()";
                ColMap["tran_scode"] = "'" + Session["scode"] + "'";
                SQL += ColMap.GetInsertSQL();
                connm.ExecuteNonQuery(SQL);
            }
        }
    }

    //新增總收發文todo_mgt
    private void Insert_todo_mgt(string tseq, string tseq1, string trs_no, string tgetrs_sqlno) {
        SQL = "insert into todo_mgt(syscode,apcode,br_rs_sqlno,seq_area,seq,seq1,rs,rs_no,in_date,in_scode,dowhat,job_status) values (";
        SQL += "'" + Session["syscode"] + "','" + prgid + "'," + tgetrs_sqlno + ",'" + Session["seBranch"] + "'," + Util.dbnull(tseq) + ",";
        SQL += "'" + tseq1 + "','S','" + trs_no + "',getdate(),'" + Session["scode"] + "','br_send','NN')";
        connm.ExecuteNonQuery(SQL);
    }
    
    //修改總收發文mgt_send
    private string Update_mgt_send(string tseq, string tseq1, string trs_no, string add_count, string fees) {
        //入mgt_send_log
        Sys.insert_log_table(connm, "U", prgid, "mgt_send", "seq_area;seq;seq1;rs_no", Session["seBranch"] + ";" + tseq + ";" + tseq1 + ";" + trs_no, logReason);

        //抓取案件主檔基本資料
        DataTable dtVDmtall = Sys.GetVDmtall(conn, tseq, tseq1);
        if (dtVDmtall.Rows.Count > 0) {
            DataRow dr = dtVDmtall.Rows[0];

            SQL = "update mgt_send set ";
            ColMap.Clear();
            ColMap["br_in_date"] = Util.dbnull(dr.GetDateTimeString("in_date", "yyyy/M/d"));
            ColMap["mseq"] = Util.dbnull(dr.SafeRead("mseq", ""));
            ColMap["mseq1"] = Util.dbchar(dr.SafeRead("mseq1", ""));
            ColMap["rs_type"] = Util.dbchar(ReqVal.TryGet("rs_type"));
            ColMap["rs_class"] = Util.dbchar(ReqVal.TryGet("rs_class"));
            ColMap["rs_class_name"] = Util.dbchar(ReqVal.TryGet("rs_class_name"));
            ColMap["rs_code"] = Util.dbchar(ReqVal.TryGet("rs_code"));
            ColMap["rs_code_name"] = Util.dbchar(ReqVal.TryGet("rs_code_name"));
            ColMap["act_code"] = Util.dbchar(ReqVal.TryGet("act_code"));
            ColMap["act_code_name"] = Util.dbchar(ReqVal.TryGet("act_code_name"));
            ColMap["rs_detail"] = Util.dbchar(ReqVal.TryGet("rs_detail"));
            ColMap["send_cl"] = Util.dbchar(ReqVal.TryGet("send_cl"));
            ColMap["send_cl1"] = Util.dbchar(ReqVal.TryGet("send_cl1"));
            ColMap["class_count"] = Util.dbchar(dr.SafeRead("class_count", ""));
            ColMap["add_count"] = Util.dbchar(add_count);
            ColMap["fees"] = Util.dbzero(fees);
            ColMap["step_date"] = Util.dbnull(ReqVal.TryGet("step_date"));
            ColMap["mp_date"] = Util.dbnull(ReqVal.TryGet("mp_date"));
            ColMap["cappl_name"] = Util.dbchar(dr.SafeRead("cappl_name", ""));
            ColMap["eappl_name"] = Util.dbchar(dr.SafeRead("eappl_name", ""));
            ColMap["s_mark1"] = Util.dbchar(dr.SafeRead("s_mark", ""));
            ColMap["apply_date"] = Util.dbnull(dr.GetDateTimeString("apply_date", "yyyy/M/d"));
            ColMap["apply_no"] = Util.dbchar(dr.SafeRead("apply_no", ""));
            ColMap["issue_date"] = Util.dbnull(dr.GetDateTimeString("issue_date", "yyyy/M/d"));
            ColMap["issue_no2"] = Util.dbchar(dr.SafeRead("issue_no", ""));
            ColMap["issue_no3"] = Util.dbchar(dr.SafeRead("rej_no", ""));
            ColMap["open_date"] = Util.dbnull(dr.GetDateTimeString("open_date", "yyyy/M/d"));
            ColMap["pay_times"] = Util.dbchar(dr.SafeRead("pay_times", ""));
            ColMap["pay_date"] = Util.dbnull(dr.GetDateTimeString("pay_date", "yyyy/M/d"));
            ColMap["term1"] = Util.dbnull(dr.GetDateTimeString("term1", "yyyy/M/d"));
            ColMap["term2"] = Util.dbnull(dr.GetDateTimeString("term2", "yyyy/M/d"));
            ColMap["end_date"] = Util.dbnull(dr.GetDateTimeString("end_date", "yyyy/M/d"));
            ColMap["end_code"] = Util.dbchar(dr.SafeRead("end_code", ""));
            ColMap["tran_date"] = "getdate()";
            ColMap["tran_scode"] = "'" + Session["scode"] + "'";
            ColMap["agt_no"] = Util.dbchar(ReqVal.TryGet("rs_agt_no"));
            ColMap["send_way"] = Util.dbchar(ReqVal.TryGet("send_way"));
            ColMap["receipt_type"] = Util.dbchar(receipt_type);
            ColMap["receipt_title"] = Util.dbchar(receipt_title);
            ColMap["issue_type"] = Util.dbchar(issue_type);
            SQL += ColMap.GetUpdateSQL();
            SQL += " where seq_area = '" + Session["seBranch"] + "' and seq=" + tseq + " and seq1='" + tseq1 + "' and rs_no='" + trs_no + "'";
            connm.ExecuteNonQuery(SQL);
        }

        SQL = "select ( ";
        SQL += "SELECT ';'+CONVERT(VARCHAR,tSend_sqlno) ";
        SQL += "FROM mgt_send as s2 ";
        SQL += "where seq_area = '" + Session["seBranch"] + "' and seq=" + tseq + " and seq1='" + tseq1 + "' and rs_no='" + trs_no + "'";
        SQL += "ORDER BY tSend_sqlno ";
        SQL += "FOR XML PATH('') ";
        SQL += ") ";
        SQL += "as tSend_sqlno ";
        objResult = connm.ExecuteScalar(SQL);
        string Getmgt_send_sqlno = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();

        return Getmgt_send_sqlno;
    }
    
   //刪除總收發文mgt_send
    private void Delete_mgt_send(string tseq, string tseq1, string trs_no) {
        //入mgt_send_log
        Sys.insert_log_table(connm, "D", prgid, "mgt_send", "seq_area;seq;seq1;rs_no", Session["seBranch"] + ";" + tseq + ";" + tseq1 + ";" + trs_no, logReason);

        SQL = "delete from mgt_send where seq_area='" + Session["seBranch"] + "' and seq=" + tseq + " and seq1='" + tseq1 + "' and rs_no='" + trs_no + "'";
        connm.ExecuteNonQuery(SQL);

        SQL = "delete from todo_mgt where seq_area='" + Session["seBranch"] + "' and seq=" + tseq + " and seq1='" + tseq1 + "' and rs_no='" + trs_no + "'";
        connm.ExecuteNonQuery(SQL);
    }
    
    //新增文件上傳dmt_attach
    private void Insert_dmt_attach(string pseq, string pseq1, string pstep_grade, string patt_sqlno) {
        string uploadfield = ReqVal.TryGet("uploadfield");
        string step_date = ReqVal.TryGet("step_date");

        //目前資料庫中有的最大值
        string maxAttach_no = ReqVal.TryGet(uploadfield + "_maxAttach_no");
        //目前畫面上的最大值
        string filenum = ReqVal.TryGet("maxattach_no");
        //本次上傳筆數
        int sqlnum = Convert.ToInt32("0" + ReqVal.TryGet(uploadfield + "_filenum"));
        //目前table的筆數
        string attach_cnt = ReqVal.TryGet(uploadfield + "_attach_cnt");

        for (int i = 1; i <= sqlnum; i++) {
            string dbflag = ReqVal.TryGet("attach_flag_" + i);
            string attach_sqlno = ReqVal.TryGet("attach_sqlno_" + i);

            //keep修改前資料
            SQL = "Select * from dmt_attach where seq='" + pseq + "' and seq1='" + pseq1 + "' and attach_sqlno='" + attach_sqlno + "'";
            DataTable dtO = new DataTable();
            conn.DataTable(SQL, dtO);

            if (dbflag == "A") {
                //當上傳路徑不為空的 and attach_sqlno為空的,才需要新增
                if (ReqVal.TryGet(uploadfield + "_" + i) != "" && attach_sqlno == "") {
                    //更換檔名
                    string attach_path = "", attach_name = "";
                    RenameFile(pseq, pseq1, pstep_grade, uploadfield, i, ref attach_path, ref attach_name);

                    SQL = "insert into dmt_attach ";
                    ColMap.Clear();
                    ColMap["Seq"] = Util.dbchar(pseq);
                    ColMap["seq1"] = Util.dbchar(pseq1);
                    ColMap["step_grade"] = Util.dbchar(pstep_grade);
                    ColMap["case_no"] = Util.dbchar(Request["attach_case_no"]);
                    ColMap["in_no"] = Util.dbchar(Request["in_no"]);
                    ColMap["Source"] = Util.dbchar("cgrs");
                    ColMap["in_date"] = "getdate()";
                    ColMap["in_scode"] = "'" + Session["scode"] + "'";
                    ColMap["Attach_no"] = Util.dbchar(Request["attach_no_" + i]);
                    ColMap["attach_path"] = Util.dbchar(attach_path);
                    ColMap["doc_type"] = Util.dbchar(Request["doc_type_" + i]);
                    ColMap["attach_desc"] = Util.dbnull(Request[uploadfield + "_desc_" + i]);
                    ColMap["Attach_name"] = Util.dbnull(attach_name);
                    ColMap["source_name"] = Util.dbnull(Request[uploadfield + "_name_" + i]);
                    ColMap["Attach_size"] = Util.dbnull(Request[uploadfield + "_size_" + i]);
                    ColMap["attach_flag"] = Util.dbchar("A");
                    ColMap["Mark"] = Util.dbchar("");
                    ColMap["tran_date"] = "getdate()";
                    ColMap["tran_scode"] = "'" + Session["scode"] + "'";
                    ColMap["att_sqlno"] = Util.dbchar(patt_sqlno);
                    ColMap["doc_flag"] = Util.dbchar(Request["doc_flag_" + i]);
                    SQL += ColMap.GetInsertSQL();
                    conn.ExecuteNonQuery(SQL);

                    iposend_attach(pseq, pseq1, pstep_grade, step_date, ReqVal.TryGet("rs_code_name"), "A", ReqVal.TryGet("doc_flag_" + i), attach_path, ReqVal.TryGet(uploadfield + "_name_" + i), dtO);
                }
            } else if (dbflag == "U") {
                //當attach_sqlno <> empty時 , 而且上傳的路徑又是空的時候,表示要刪除該筆資料,而非修改
                if (attach_sqlno != "" && ReqVal.TryGet(uploadfield + "_" + i) == "") {
                    Sys.insert_log_table(conn, "D", prgid, "dmt_attach", "attach_sqlno", attach_sqlno, logReason);

                    //當attach_sqlno <> empty時,表示db有值,必須刪除data(update attach_flag = 'D')
                    SQL = "update dmt_attach set attach_flag='D'";
                    SQL += ",tran_date=getdate(),tran_scode='" + Session["scode"] + "'";
                    SQL += " where attach_sqlno='" + attach_sqlno + "'";
                    conn.ExecuteNonQuery(SQL);

                    iposend_attach(pseq, pseq1, pstep_grade, step_date, ReqVal.TryGet("rs_code_name"), "D", "", "", "", dtO);
                } else {
                    Sys.insert_log_table(conn, "U", prgid, "dmt_attach", "attach_sqlno", attach_sqlno, logReason);

                    string old_attach_name = ReqVal.TryGet("old_" + uploadfield + "_name_" + i);//原檔案名稱
                    string attach_name = ReqVal.TryGet(uploadfield + "_name_" + i);//上傳檔名
                    string attach_path = ReqVal.TryGet(uploadfield + "_" + i);
                    string source_name = ReqVal.TryGet("source_name_" + i);

                    if (attach_name != old_attach_name) {//畫面上傳檔名與原檔案名稱不一樣，表示上傳新檔案
                        source_name = attach_name;
                    }
                    RenameFile(pseq, pseq1, pstep_grade, uploadfield, i, ref attach_path, ref attach_name);

                    SQL = "update dmt_attach set ";
                    ColMap.Clear();
                    ColMap["Source"] = Util.dbchar("cgrs");
                    ColMap["step_grade"] = Util.dbchar(pstep_grade);
                    ColMap["attach_path"] = Util.dbchar(Sys.Path2Btbrt(attach_path));
                    ColMap["attach_desc"] = Util.dbnull(Request[uploadfield + "_desc_" + i]);
                    ColMap["Attach_name"] = Util.dbnull(attach_name);
                    ColMap["Attach_size"] = Util.dbnull(Request[uploadfield + "_size_" + i]);
                    ColMap["source_name"] = Util.dbnull(source_name);
                    ColMap["doc_type"] = Util.dbchar(Request["doc_type_" + i]);
                    ColMap["attach_flag"] = Util.dbchar("U");
                    ColMap["attach_branch"] = Util.dbchar(Request[uploadfield + "_branch_" + i]);
                    ColMap["tran_date"] = "getdate()";
                    ColMap["tran_scode"] = "'" + Session["scode"] + "'";
                    ColMap["doc_flag"] = Util.dbchar(Request["doc_flag_" + i]);
                    SQL += ColMap.GetUpdateSQL();
                    SQL += " where attach_sqlno = '" + attach_sqlno + "'";
                    conn.ExecuteNonQuery(SQL);

                    iposend_attach(pseq, pseq1, pstep_grade, step_date, ReqVal.TryGet("rs_code_name"), "U", ReqVal.TryGet("doc_flag_" + i), attach_path, Request["source_name_" + i], dtO);
                }
            } else if (dbflag == "D") {
                Sys.insert_log_table(conn, "D", prgid, "dmt_attach", "attach_sqlno", attach_sqlno, logReason);

                //當attach_sqlno <> empty時,表示db有值,必須刪除data(update attach_flag = 'D')
                if (attach_sqlno != "") {
                    SQL = "update dmt_attach set attach_flag='D',tran_date=getdate(),tran_scode='" + Session["scode"] + "'";
                    SQL += " where attach_sqlno='" + attach_sqlno + "'";
                    conn.ExecuteNonQuery(SQL);
                }
            }
        }
    }

    //新增子案文件上傳dmt_attach
    private void Insert_dseq_dmt_attach(string pseq, string pseq1, string pstep_grade, string pdseq, string pdseq1, string pdstep_grade, string patt_sqlno) {
        Sys sfile = new Sys();
        sfile.getFileServer(Sys.GetSession("SeBranch"), Request["prgid"]);//檔案上傳相關設定

        DataTable dtAttach = new DataTable();
        SQL = "select * from dmt_attach where seq=" + pseq + " and seq1='" + pseq1 + "' and step_grade=" + pstep_grade + " and attach_flag<>'D' order by attach_no";
        conn.DataTable(SQL, dtAttach);
        for (int i = 0; i < dtAttach.Rows.Count; i++) {
            DataRow dr = dtAttach.Rows[i];
            string straa = dr.SafeRead("attach_name", "").Trim();//母案檔名
            //更換檔名
            string tseq = pdseq.PadLeft(Sys.DmtSeq, '0');
            string tseq1 = "-";
            if (pdseq1 != "_") tseq1 += pdseq1;
            string tstep_grade = pdstep_grade.PadLeft(4, '0');

            string attach_name = Session["seBranch"] + "T-" + tseq + tseq1 + "-" + tstep_grade + "-" + dr.SafeRead("attach_no", "").Trim() + System.IO.Path.GetExtension(straa);//重新命名檔名
            string strpath = sfile.gbrWebDir + "/doc/" + pdseq1 + "/" + tseq.Left(3) + "/" + tseq;
            string newattach_path = strpath + "/" + attach_name;//存在資料庫路徑
            Sys.RenameFile(Sys.Path2Nbtbrt(dr.SafeRead("attach_path", "").Trim()), strpath + "/" + attach_name, true);

            SQL = "insert into dmt_attach (Seq,seq1,step_grade,Source";
            SQL += ",in_date,in_scode,Attach_no,attach_path,doc_type,attach_desc";
            SQL += ",Attach_name,source_name,Attach_size,attach_flag,Mark,tran_date,tran_scode,att_sqlno";
            SQL += ") values (";
            SQL += "'" + pdseq.Trim() + "','" + pdseq1.Trim() + "','" + pdstep_grade.Trim() + "'";
            SQL += ",'cgrs',getdate(),'" + Session["scode"] + "'," + Util.dbchar(dr.SafeRead("attach_no", "")) + "," + Util.dbchar(Sys.Path2Btbrt(newattach_path));
            SQL += "," + Util.dbchar(dr.SafeRead("doc_type", "")) + "," + Util.dbchar(dr.SafeRead("attach_desc", "")) + "," + Util.dbchar(attach_name);
            SQL += "," + Util.dbchar(dr.SafeRead("source_name", "")) + "," + Util.dbchar(dr.SafeRead("attach_size", ""));
            SQL += ",'A','',getdate(),'" + Session["scode"] + "'," + patt_sqlno;
            SQL += ")";
            conn.ExecuteNonQuery(SQL);
        }
    }
    
    /// <summary>
    /// 更換檔名(單位-案號-副號-進度序號-attach_no,EX:NT-01234--0001-1.pdf)
    /// </summary>
    private void RenameFile(string seq, string seq1, string step_grade, string uploadfield, int nRow, ref string attach_path, ref string attach_name) {
        Sys sfile = new Sys();
        sfile.getFileServer(Sys.GetSession("SeBranch"), Request["prgid"]);//檔案上傳相關設定

        string fseq = seq.PadLeft(Sys.DmtSeq, '0');
        string aa = System.IO.Path.GetFileName(Request[uploadfield + "_name_" + nRow]);//上傳檔名
        string ar = System.IO.Path.GetExtension(aa);//副檔名
        string lname = string.Format("{0}-{1}-{2}-{3:0000}-{4}{5}"//新檔名
                                    , Sys.GetSession("SeBranch") + Sys.GetSession("dept").ToUpper()//0
                                    , fseq//1
                                    , seq1 != "_" ? seq1 : ""//2
                                    , Convert.ToInt32(step_grade)//3
                                    , Request["attach_no_" + nRow]//4
                                    , ar);

        string strpath = Request[uploadfield + "_" + nRow];//存檔路徑+檔名
        if (strpath.IndexOf(".") > -1) strpath = System.IO.Path.GetDirectoryName(strpath);//如果有含檔名則只取目錄
        Sys.RenameFile(Sys.Path2Nbtbrt(strpath + "/" + aa), Sys.Path2Nbtbrt(strpath + "/" + lname), true);

        attach_path = Sys.Path2Btbrt(strpath + "/" + lname);//存入資料庫路徑+新檔名
        attach_name = lname;//新檔名
    }
    
    //複製到iposend
    private void iposend_attach(string seq, string seq1, string step_grade, string step_date, string rs_detail, string dbflag, string doc_flag, string attach_path, string attach_name, DataTable oDT) {
        if (ReqVal.TryGet("send_way") == "E") {
            string branch = Sys.GetSession("SeBranch");
            //第一層目錄：發文日期+發文單位，如20210220-NT
            DateTime sdate = Util.str2Dateime(step_date);
            string tfoldername = String.Format("{0}-{1}", sdate.ToString("yyyyMMdd"), branch + Sys.GetSession("dept"));
            //第二層目錄：案號+副碼+進度+案性前6碼，如NT12345-_-2-申請商標註冊
            tfoldername += "/" + String.Format("{0}-{1}-{2}-{3}"
                , branch + Sys.GetSession("dept") + seq.PadLeft(Sys.DmtSeq, '0')
                , seq1
                , step_grade
                , rs_detail.ToUnicode().Left(6).Trim());
            //iposend存檔路徑
            string sendt_path = Sys.IPODir + "/" + tfoldername;

            Sys.CreateFolder(sendt_path);//電子送件目錄

            //備份舊檔案
            if (oDT.Rows.Count > 0) {
                if (oDT.Rows[0].SafeRead("doc_flag", "") == "E") {
                    Sys.CreateFolder(sendt_path);
                    Sys.CreateFolder(sendt_path + "/backup");//備份路徑

                    var sourceFile = Server.MapPath(sendt_path + "/" + oDT.Rows[0].SafeRead("source_name", ""));
                    var backupDir = Server.MapPath(sendt_path + "/backup");
                    string firstName = System.IO.Path.GetFileNameWithoutExtension(sourceFile);
                    string extName = System.IO.Path.GetExtension(sourceFile);
                    string stamp = DateTime.Now.ToString("yyyyMMddhhmmss") + "-" + Session["scode"];//備份註記(_時間-薪號)
                    if (Request["chkTest"] == "TEST") {
                        Response.Write("move..備份舊檔案..<BR>" + sourceFile + "<BR>" + backupDir + "\\" + firstName + "_" + stamp + extName + "<HR>");
                    }
                    if (System.IO.File.Exists(sourceFile)) {
                        System.IO.File.Move(sourceFile, backupDir + "\\" + firstName + "_" + stamp + extName);
                    }
                }
            }

            if ((dbflag == "A" || dbflag == "U") && doc_flag == "E") {//doc_flag=E:電子送件
                //要將檔案copy至sin07/iposend
                if (Request["chkTest"] == "TEST") {
                    Response.Write("copy..複製新檔案..<BR>" + Server.MapPath(Sys.Path2Nbtbrt(attach_path)) + "→" + Server.MapPath(sendt_path + "/" + attach_name) + "<HR>");
                }
                System.IO.File.Copy(Server.MapPath(Sys.Path2Nbtbrt(attach_path)), Server.MapPath(sendt_path + "/" + attach_name), true);
            }
        }
    }

    //取得發文序號
    private string getRsNo() {
        SQL = "select isnull(sql,0)+1 from cust_code where code_type='Z' and cust_code='" + Session["sebranch"] + Session["dept"] + Request["cgrs"] + "'";
        objResult = conn.ExecuteScalar(SQL);
        string nrs_no = (objResult == DBNull.Value || objResult == null) ? "1" : objResult.ToString();
        nrs_no = ReqVal.TryGet("cgrs").ToUpper() + nrs_no.PadLeft(8, '0');

        //流水號加一
        SQL = " update cust_code set sql=sql+1 where code_type='Z' and cust_code='" + Session["sebranch"] + Session["dept"] + Request["cgrs"] + "'";
        conn.ExecuteNonQuery(SQL);

        return nrs_no;
    }
</script>

<%Response.Write(strOut.ToString());%>
