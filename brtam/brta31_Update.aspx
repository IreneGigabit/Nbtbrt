<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>

<script runat="server">
    protected string HTProgCap = "官發確認入檔";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = HttpContext.Current.Request["prgid"] ?? "";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";

    protected string submitTask = "";
    protected string SQL = "";
    protected object objResult = null;
    protected string logReason = "Brta38官發確認作業";
        
    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected Dictionary<string, string> ColMap = new Dictionary<string, string>();

    string[] arr_chk,arr_cgrs,arr_todo_sqlno,arr_cust_seq,arr_seq,arr_seq1,arr_now_grade;
    string[] arr_step_grade,arr_nstep_grade,arr_rectitle_name,arr_tmprectitle_name,arr_att_sqlno,arr_send_way;
    string[] arr_case_no,arr_rs_type,arr_rs_agt_no,arr_rs_agt_nonm,arr_case_agt_no,arr_case_agt_name;
    string[] arr_fees_stat,arr_opt_branch,arr_dmt_pay_times,arr_rs_no,arr_spe_ctrl_4;

    string[] arr_ctrl_num,arr_rsqlno,arr_ctrl_type,arr_ctrl_date,arr_ctrl_remark;
    string[] arr_fees,arr_case_service,arr_case_fees,arr_case_gs_fees,arr_case_gs_curr;

    string[] arr_step_date,arr_mp_date,arr_send_cl,arr_send_cl1,arr_rs_class_name,arr_rs_code_name;
    string[] arr_act_code_name,arr_rs_class,arr_ncase_stat,arr_ncase_statnm,arr_rs_code,arr_act_code;
    string[] arr_pr_scode,arr_rs_detail,arr_receipt_type,arr_receipt_title,arr_send_sel,arr_apply_no;
    string[] arr_pay_times,arr_pay_date;
    
    protected StringBuilder strOut = new StringBuilder();

    DBHelper conn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    DBHelper connm = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    DBHelper conni2 = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    private void Page_Unload(System.Object sender, System.EventArgs e) {
        if (conn != null) conn.Dispose();
        if (connm != null) connm.Dispose();
        if (conni2 != null) conni2.Dispose();
    }

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");
        conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
        connm = new DBHelper(Conn.MG).Debug(Request["chkTest"] == "TEST");
        conni2 = new DBHelper(Conn.account).Debug(Request["chkTest"] == "TEST");

        arr_chk = Request["rows_chk"].Split('\f');
        arr_cgrs = Request["rows_cgrs"].Split('\f');
        arr_todo_sqlno = Request["rows_todo_sqlno"].Split('\f');
        arr_cust_seq = Request["rows_cust_seq"].Split('\f');
        arr_seq = Request["rows_seq"].Split('\f');
        arr_seq1 = Request["rows_seq1"].Split('\f');
        arr_now_grade = Request["rows_now_grade"].Split('\f');
        arr_step_grade = Request["rows_step_grade"].Split('\f');
        arr_nstep_grade = Request["rows_nstep_grade"].Split('\f');
        arr_rectitle_name = Request["rows_rectitle_name"].Split('\f');
        arr_tmprectitle_name = Request["rows_tmprectitle_name"].Split('\f');
        arr_att_sqlno = Request["rows_att_sqlno"].Split('\f');
        arr_send_way = Request["rows_send_way"].Split('\f');
        arr_case_no = Request["rows_case_no"].Split('\f');
        arr_rs_type = Request["rows_rs_type"].Split('\f');
        arr_rs_agt_no = Request["rows_rs_agt_no"].Split('\f');
        arr_rs_agt_nonm = Request["rows_rs_agt_nonm"].Split('\f');
        arr_case_agt_no = Request["rows_case_agt_no"].Split('\f');
        arr_case_agt_name = Request["rows_case_agt_name"].Split('\f');
        arr_fees_stat = Request["rows_fees_stat"].Split('\f');
        arr_opt_branch = Request["rows_opt_branch"].Split('\f');
        arr_dmt_pay_times = Request["rows_dmt_pay_times"].Split('\f');
        arr_rs_no = Request["rows_rs_no"].Split('\f');
        arr_spe_ctrl_4 = Request["rows_spe_ctrl_4"].Split('\f');

        arr_ctrl_num = Request["rows_ctrl_num"].Split('\f');
        arr_rsqlno = Request["rows_rsqlno"].Split('\f');
        arr_ctrl_type = Request["rows_ctrl_type"].Split('\f');
        arr_ctrl_date = Request["rows_ctrl_date"].Split('\f');
        arr_ctrl_remark = Request["rows_ctrl_remark"].Split('\f');

        arr_fees = Request["rows_fees"].Split('\f');
        arr_case_service = Request["rows_case_service"].Split('\f');
        arr_case_fees = Request["rows_case_fees"].Split('\f');
        arr_case_gs_fees = Request["rows_case_gs_fees"].Split('\f');
        arr_case_gs_curr = Request["rows_case_gs_curr"].Split('\f');

        arr_step_date = Request["rows_step_date"].Split('\f');
        arr_mp_date = Request["rows_mp_date"].Split('\f');
        arr_send_cl = Request["rows_send_cl"].Split('\f');
        arr_send_cl1 = Request["rows_send_cl1"].Split('\f');
        arr_rs_class_name = Request["rows_rs_class_name"].Split('\f');
        arr_rs_code_name = Request["rows_rs_code_name"].Split('\f');
        arr_act_code_name = Request["rows_act_code_name"].Split('\f');
        arr_rs_class = Request["rows_rs_class"].Split('\f');
        arr_ncase_stat = Request["rows_ncase_stat"].Split('\f');
        arr_ncase_statnm = Request["rows_ncase_statnm"].Split('\f');
        arr_rs_code = Request["rows_rs_code"].Split('\f');
        arr_act_code = Request["rows_act_code"].Split('\f');
        arr_pr_scode = Request["rows_pr_scode"].Split('\f');
        arr_rs_detail = Request["rows_rs_detail"].Split('\f');
        arr_receipt_type = Request["rows_receipt_type"].Split('\f');
        arr_receipt_title = Request["rows_receipt_title"].Split('\f');
        arr_send_sel = Request["rows_send_sel"].Split('\f');
        arr_apply_no = Request["rows_apply_no"].Split('\f');
        arr_pay_times = Request["rows_pay_times"].Split('\f');
        arr_pay_date = Request["rows_pay_date"].Split('\f');

        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        HTProgCap = myToken.Title;
        DebugStr = myToken.DebugStr;
        if (HTProgRight >= 0) {
            try {
                if (ReqVal.TryGet("submitTask") == "A") {
                    doUpdateDB();
                    strOut.AppendLine("<div align='center'><h1>官方發文成功!!!</h1></div>");
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

    private void doUpdateDB() {
        string rs_code = ReqVal.TryGet("rs_code");
        //計算 tot_num區所發文件數,mtot_num寫入總收發文件數
        int tot_num = 0;
        int mtot_num = 1;
        if (rs_code.IN("FC11,FC21,FC5,FC6,FC7,FC8,FCH,FCI,FL5,FL6,FT2")) {
            tot_num =1;
        }
        
        for (int i = 1; i <= Convert.ToInt32("0" + Request["tot_num"]); i++) {
            if (ReqVal.TryGet("dseqdel_" + i) != "D") {
                tot_num++;
                mtot_num++;
            }
        }

      
        
        //新增attcase_dmt交辦發文檔
        for (int i = 1; i < arr_chk.Length; i++) {
            if (arr_chk[i] == "Y") {//有打勾
                Sys.showLog("<font color=red>﹝" + i + "﹞</font>todo_sqlno=" + arr_todo_sqlno[i]);
                //判斷狀態是否已異動,防止開雙視窗
                SQL = "select count(*) from todo_dmt where sqlno='" + arr_todo_sqlno[i] + "' and job_status='NN'";
                object objResult = conn.ExecuteScalar(SQL);
                int cnt = (objResult == DBNull.Value || objResult == null) ? 0 : Convert.ToInt32(objResult);
                if (cnt == 0) {
                    throw new Exception("接洽序號" + arr_todo_sqlno[i] + "-官方發文失敗(流程狀態已異動，請重新整理畫面)");
                } else {

                    //發文序號
                    SQL = "select isnull(sql,0)+1 from cust_code where code_type='Z' and cust_code='" + Session["sebranch"] + "TGS'";
                    objResult = conn.ExecuteScalar(SQL);
                    string rs_no = (objResult == DBNull.Value || objResult == null) ? "1" : objResult.ToString();
                    rs_no = "GS" + rs_no.PadLeft(8, '0');

                    //流水號加一
                    SQL = " update cust_code set sql=sql+1 where code_type='Z' and cust_code='" + Session["seBranch"] + "TGS'";
                    conn.ExecuteNonQuery(SQL);

                    if (arr_case_no[i] != "") {
                        //新增 fees_dmt，2013/3/22因收入寫入智產系統增加支出次數
                        SQL = "insert into fees_dmt ";
                        ColMap.Clear();
                        ColMap["rs_no"] = Util.dbchar(rs_no);
                        ColMap["case_no"] = Util.dbchar(arr_case_no[i]);
                        ColMap["fees"] = Util.dbzero(arr_case_gs_fees[i]);
                        ColMap["service"] = Util.dbzero(arr_case_service[i]);
                        ColMap["gs_curr"] = "" + (Convert.ToInt32(arr_case_gs_curr[i]) + 1) + "";
                        SQL += ColMap.GetInsertSQL();
                        conn.ExecuteNonQuery(SQL);

                        //將官發規費支出存入case_dmt
                        SQL = "update case_dmt set ";
                        ColMap.Clear();
                        ColMap["gs_fees"] = "gs_fees+" + arr_case_gs_fees[i];
                        ColMap["gs_curr"] = "gs_curr+1";
                        SQL += ColMap.GetUpdateSQL();
                        SQL += " where case_no='" + arr_case_no[i] + "'";
                        conn.ExecuteNonQuery(SQL);

                        //將規費資料寫入帳款系統plus_temp
                        if (Convert.ToInt32(arr_case_gs_fees[i]) > 0) {
                            //取得案件主檔營洽
                            string dmt_scode = "";
                            SQL = "select scode from dmt where seq=" + arr_seq[i] + " and seq1='" + arr_seq1[i] + "'";
                            objResult = conn.ExecuteScalar(SQL);
                            dmt_scode = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();

                            //取得交辦案性及請款註記
                            string lcase_arcase = "", lar_mark = "";
                            SQL = "select arcase,ar_mark from case_dmt where case_no='" + arr_case_no[i] + "'";
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
                            ColMap["send_date"] = Util.dbchar(arr_step_date[i]);
                            ColMap["branch"] = "'" + Session["seBranch"] + "'";
                            ColMap["dept"] = "'" + Session["dept"] + "'";
                            ColMap["case_no"] = Util.dbchar(arr_case_no[i]);
                            ColMap["rs_no"] = Util.dbchar(rs_no);
                            ColMap["seq"] = Util.dbchar(arr_seq[i]);
                            ColMap["seq1"] = Util.dbchar(arr_seq1[i]);
                            ColMap["country"] = Util.dbchar("T");
                            ColMap["cust_seq"] = Util.dbchar(arr_cust_seq[i]);
                            ColMap["scode"] = Util.dbchar(dmt_scode);
                            ColMap["case_arcase"] = Util.dbchar(lcase_arcase);
                            ColMap["arcase"] = Util.dbchar(arr_rs_code[i]);
                            ColMap["ar_mark"] = Util.dbchar(lar_mark);
                            ColMap["tr_money"] = Util.dbzero(arr_case_gs_fees[i]);
                            ColMap["chk_type"] = Util.dbchar("N");
                            ColMap["chk_date"] = "null";
                            ColMap["mstat_flag"] = Util.dbchar("NN");
                            ColMap["mstat_date"] = "null";
                            SQL += ColMap.GetInsertSQL();
                            conni2.ExecuteNonQuery(SQL);
                        }
                    }

                    //依官發確認時的申請人為準,寫入step_dmp的收據抬頭
                    string dmtap_cname = "";
                    SQL = "select apcust_no,ap_cname from dmt_ap where seq='" + arr_seq[i] + "' and seq1='" + arr_seq1[i] + "'";
                    using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
                        if (dr.Read()) {
                            dmtap_cname += "、" + dr.SafeRead("ap_cname", "").Trim();
                        }
                        if (dmtap_cname != "") dmtap_cname = dmtap_cname.Substring(1);
                    }

                    string receipt_type = arr_receipt_type[i];
                    string receipt_title = arr_receipt_title[i];
                    string rectitle_name = "";
                    if (receipt_title == "A") {//{專利權人
                        rectitle_name = dmtap_cname;
                    } else if (receipt_title == "C") {//{專利權人(代繳人)
                        rectitle_name = dmtap_cname + "(代繳人：聖島國際專利商標聯合事務所)";
                    }

                    //入step_dmt	
                    SQL = "insert into step_dmt ";
                    ColMap.Clear();
                    ColMap["rs_no"] = Util.dbchar(rs_no);
                    ColMap["branch"] = Util.dbchar(Sys.GetSession("seBranch"));
                    ColMap["seq"] = Util.dbnull(arr_seq[i]);
                    ColMap["seq1"] = Util.dbchar(arr_seq1[i]);
                    ColMap["step_grade"] = Util.dbnull(arr_nstep_grade[i]);
                    ColMap["main_rs_no"] = Util.dbchar(rs_no);
                    ColMap["step_date"] = Util.dbnull(arr_step_date[i]);
                    ColMap["mp_date"] = Util.dbnull(arr_mp_date[i]);
                    ColMap["cg"] = Util.dbchar(arr_cgrs[i].Substring(0, 1));
                    ColMap["rs"] = Util.dbchar(arr_cgrs[i].Substring(1, 1));
                    ColMap["rs_type"] = Util.dbnull(arr_rs_type[i]);
                    ColMap["rs_class"] = Util.dbchar(arr_rs_class[i]);
                    ColMap["rs_code"] = Util.dbchar(arr_rs_code[i]);
                    ColMap["act_code"] = Util.dbchar(arr_act_code[i]);
                    ColMap["rs_detail"] = Util.dbnull(arr_rs_detail[i]);
                    ColMap["send_cl"] = Util.dbnull(arr_send_cl[i]);
                    ColMap["send_cl1"] = Util.dbnull(arr_send_cl1[i]);
                    ColMap["send_sel"] = Util.dbnull(arr_send_sel[i]);
                    ColMap["fees"] = Util.dbzero(arr_fees[i]);
                    ColMap["fees_stat"] = Util.dbchar(arr_fees_stat[i]);
                    ColMap["send_way"] = Util.dbchar(arr_send_way[i]);
                    ColMap["pr_scode"] = Util.dbchar(arr_pr_scode[i]);
                    ColMap["opt_branch"] = Util.dbchar(arr_opt_branch[i]);
                    ColMap["new"] = Util.dbchar("N");
                    ColMap["tot_num"] = Util.dbzero("1");
                    ColMap["rs_agt_no"] = Util.dbchar(arr_rs_agt_no[i]);
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
                    Sys.showLog("進度流水號="+Getrs_sqlno);
                    
                    //入ctrl_dmt
                    string[] arrCtrlType = arr_ctrl_type[i].Split('︿');
                    string[] arrCtrlDate = arr_ctrl_date[i].Split('︿');
                    string[] arrCtrlRemark = arr_ctrl_remark[i].Split('︿');
                    for (int c = 0; c < arrCtrlType.Length; c++) {
                        if (arrCtrlType[c] != "" && arrCtrlDate[c] != "") {
                            SQL = "insert into ctrl_dmt ";
                            ColMap.Clear();
                            ColMap["rs_no"] = Util.dbchar(rs_no);
                            ColMap["branch"] = Util.dbchar(Sys.GetSession("seBranch"));
                            ColMap["seq"] = Util.dbnull(arr_seq[i]);
                            ColMap["seq1"] = Util.dbchar(arr_seq1[i]);
                            ColMap["step_grade"] = Util.dbzero(arr_nstep_grade[i]);
                            ColMap["ctrl_type"] = Util.dbchar(arrCtrlType[c]);
                            ColMap["ctrl_remark"] = Util.dbnull(arrCtrlRemark[c]);
                            ColMap["ctrl_date"] = Util.dbnull(arrCtrlDate[c]);
                            ColMap["tran_date"] = "getdate()";
                            ColMap["tran_scode"] = "'" + Session["scode"] + "'";
                            SQL += ColMap.GetInsertSQL();
                            conn.ExecuteNonQuery(SQL);
                        }
                    }

                    //銷管制入檔
                    DataTable dtCtrl = new DataTable();
                    if (arr_rsqlno[i] != "") {
                        //keep資料-寫入總收發銷管暫存檔用
                        SQL = "select seq,seq1,(select rs_sqlno from step_dmt s where s.rs_no=c.rs_no)br_rs_sqlno ";
                        SQL += ",step_grade,'" + arr_nstep_grade[i] + "'br_resp_grade,ctrl_type,ctrl_remark ";
                        SQL += ",ctrl_date,'" + arr_step_date[i] + "' resp_date,convert(varchar,tran_date,120) ctrl_tran_date ";
                        SQL += ",tran_scode ctrl_tran_scode ";
                        SQL += "from ctrl_dmt c ";
                        SQL += "where sqlno in('" + arr_rsqlno[i].Replace(";", "','") + "') ";
                        SQL += "and sqlno<>'' ";
                        SQL += "and (ctrl_type='A1' or ctrl_type like 'A4%') ";//條件同官發回條列印
                        conn.DataTable(SQL, dtCtrl);

                        //新增至 resp_dmt
                        SQL = "insert into resp_dmt(sqlno,rs_no,branch,seq,seq1,step_grade,resp_grade,ctrl_type,ctrl_remark,ctrl_date,resp_date,tran_date,tran_scode) ";
                        SQL += "select sqlno,rs_no,branch,seq,seq1,step_grade,'" + arr_nstep_grade[i] + "',ctrl_type,ctrl_remark,ctrl_date,'" + arr_step_date[i] + "',getdate(),'" + Session["scode"] + "' ";
                        SQL += "from ctrl_dmt where sqlno in('" + arr_rsqlno[i].Replace(";", "','") + "') and sqlno<>''";
                        conn.ExecuteNonQuery(SQL);

                        //由 ctrl_dmt 中刪除
                        SQL = "delete from ctrl_dmt where sqlno in('" + arr_rsqlno[i].Replace(";", "','") + "') and sqlno<>''";
                        conn.ExecuteNonQuery(SQL);
                    }

                    //案件主檔now_arcase,now_grade,now_stat
                    Sys.insert_log_table(conn, "U", prgid, "dmt", "seq;seq1", arr_seq[i] + ";" + arr_seq1[i], logReason);
                    SQL = "update dmt set ";
                    ColMap.Clear();
                    if (Convert.ToInt32(arr_step_grade[i]) >= Convert.ToInt32(arr_now_grade[i]) && arr_ncase_stat[i] != "") {
                        ColMap["now_arcase_type"] = Util.dbchar(arr_rs_type[i]);
                        ColMap["now_arcase"] = Util.dbchar(arr_rs_code[i]);
                        ColMap["now_grade"] = Util.dbchar(arr_nstep_grade[i]);
                        ColMap["now_stat"] = Util.dbchar(arr_ncase_stat[i]);
                        ColMap["now_arcase_class"] = Util.dbchar(arr_rs_class[i]);
                        ColMap["now_act_code"] = Util.dbchar(arr_act_code[i]);
                    }
                    ColMap["step_grade"] = "step_grade+1";
                    ColMap["pay_times"] = Util.dbchar(arr_pay_times[i]);
                    ColMap["pay_date"] = Util.dbchar(arr_pay_date[i]);
                    SQL += ColMap.GetUpdateSQL();
                    SQL += " where seq=" + arr_seq[i] + " and seq1='" + arr_seq1[i] + "'";
                    conn.ExecuteNonQuery(SQL);

                    //入總收發文mgt_send
                    string Getmgt_send_sqlno = Insert_mgt_send(arr_seq[i], arr_seq1[i], arr_nstep_grade[i], rs_no, Getrs_sqlno, rs_no, "1", arr_fees[i], i);
                    //法定期限銷管資料寫入總收發
                    Insert_brresp_mgt(Getmgt_send_sqlno, dtCtrl);
                    //入總收發文todo_mgt
                    Insert_todo_mgt(arr_seq[i], arr_seq1[i], rs_no, Getrs_sqlno);

                    //修改程序官發確認狀態attcase_dmt,todo_dmt
                    //入attcase_dmt_log
                    Sys.insert_log_table(conn, "U", prgid, "attcase_dmt", "att_sqlno", arr_att_sqlno[i], logReason);
                    SQL = "update attcase_dmt set ";
                    ColMap.Clear();
                    ColMap["pr_scode"] = Util.dbchar(arr_pr_scode[i]);//承辦人員
                    ColMap["step_date"] = Util.dbchar(arr_step_date[i]);//發文日期
                    ColMap["mp_date"] = Util.dbchar(arr_mp_date[i]);//總管處發文日期
                    ColMap["send_cl"] = Util.dbchar(arr_send_cl[i]);//收發單位
                    ColMap["send_cl1"] = Util.dbchar(arr_send_cl1[i]);//副本單位
                    ColMap["send_sel"] = Util.dbchar(arr_send_sel[i]);//官方號碼
                    ColMap["rs_class"] = Util.dbchar(arr_rs_class[i]);//結構分類
                    ColMap["rs_code"] = Util.dbchar(arr_rs_code[i]);//案性
                    ColMap["act_code"] = Util.dbchar(arr_act_code[i]);//處理事項
                    ColMap["rs_detail"] = Util.dbchar(arr_rs_detail[i]);//發文內容
                    ColMap["fees"] = Util.dbzero(arr_fees[i]);//規費支出
                    ColMap["fees_stat"] = Util.dbchar(arr_fees_stat[i]);//收費管制
                    ColMap["rs_agt_no"] = Util.dbchar(arr_rs_agt_no[i]);//發文出名代理
                    ColMap["opt_branch"] = Util.dbchar(arr_opt_branch[i]);//發文單位
                    ColMap["sign_stat"] = Util.dbchar("SZ");//交辦狀態SZ=程序確認
                    ColMap["conf_scode"] = "'" + Session["scode"] + "'";//確認人員
                    ColMap["conf_date"] = "getdate()";//確認日期
                    ColMap["rs_sqlno"] = "" + Getrs_sqlno + "";//進度流水號
                    SQL += ColMap.GetUpdateSQL();
                    SQL += " where att_sqlno=" + Util.dbchar(arr_att_sqlno[i]);
                    conn.ExecuteNonQuery(SQL);

                    //修改todo狀態
                    SQL = "update todo_dmt set ";
                    ColMap.Clear();
                    ColMap["job_status"] = Util.dbchar("SZ");
                    ColMap["approve_scode"] = "'" + Session["scode"] + "'";
                    ColMap["resp_date"] = "getdate()";
                    SQL += ColMap.GetUpdateSQL();
                    SQL += " where sqlno='" + arr_todo_sqlno[i] + "' and job_status='NN'";
                    conn.ExecuteNonQuery(SQL);
                }
            }
        }
    }
    
    //新增總收發文mgt_send
    private string Insert_mgt_send(string tseq, string tseq1, string tstep_grade, string trs_no, string tgetrs_sqlno, string tmrs_no, string add_count, string fees, int pno) {
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

            //20180716 增加批次繳註冊費
            string issue_type = "";
            if (arr_rs_code[pno] == "FF0")
                issue_type = "0";//全期
            else if (arr_rs_code[pno] == "FF2")
                issue_type = "2";//二期
            else if (arr_rs_code[pno] == "FF3")
                issue_type = "3";//二期逾期加倍補繳

            SQL = "insert into mgt_send(seq_area0,seq_area,seq,seq1,br_in_date,br_step_grade,br_rs_sqlno,mseq,mseq1 ";
            SQL += ",rs_no,mrs_no,rs_type,rs_class,rs_class_name,rs_code,rs_code_name,act_code,act_code_name,rs_detail,send_cl ";
            SQL += ",send_cl1,class_count,add_count,case_new,fees,step_date,mp_date,cappl_name,eappl_name,s_mark1,country ";
            SQL += ",apply_date,apply_no,issue_date,issue_no2,issue_no3,open_date,pay_times,pay_date,term1,term2,end_date ";
            SQL += ",end_code,source,send_status,branch_date,branch_scode,tran_date,tran_scode,agt_no,send_way ";
            SQL += ",receipt_type,receipt_title,issue_type";
            SQL += ") values (";
            SQL += "'" + Session["seBranch"] + "','" + Session["seBranch"] + "'," + tseq + ",'" + tseq1 + "'";
            SQL += "," + Util.dbnull(dr.GetDateTimeString("in_date", "yyyy/M/d")) + "," + tstep_grade + "," + tgetrs_sqlno + "," + Util.dbnull(dr.SafeRead("mseq", ""));
            SQL += "," + Util.dbchar(dr.SafeRead("mseq1", "")) + ",'" + trs_no + "','" + tmrs_no + "','" + arr_rs_type[pno] + "','" + arr_rs_class[pno] + "'";
            SQL += ",'" + arr_rs_class_name[pno] + "','" + arr_rs_code[pno] + "','" + arr_rs_code_name[pno] + "','" + arr_act_code[pno] + "'";
            SQL += ",'" + arr_act_code_name[pno] + "','" + arr_rs_detail[pno] + "','" + arr_send_cl[pno] + "','" + arr_send_cl1[pno] + "'";
            SQL += "," + Util.dbzero(dr.SafeRead("class_count", "")) + "," + add_count + ",'" + case_new + "'," + Util.dbzero(fees) + "," + Util.dbnull(arr_step_date[pno]);
            SQL += "," + Util.dbnull(arr_mp_date[pno]) + "," + Util.dbchar(dr.SafeRead("appl_name", "")) + "," + Util.dbchar(dr.SafeRead("eappl_name", ""));
            SQL += "," + Util.dbchar(dr.SafeRead("s_mark", "")) + ",'" + tcountry + "'," + Util.dbnull(dr.GetDateTimeString("apply_date", "yyyy/M/d"));
            SQL += "," + Util.dbchar(dr.SafeRead("apply_no", "")) + "," + Util.dbnull(dr.GetDateTimeString("issue_date", "yyyy/M/d"));
            SQL += "," + Util.dbchar(dr.SafeRead("issue_no", "")) + "," + Util.dbchar(dr.SafeRead("rej_no", ""));
            SQL += "," + Util.dbnull(dr.GetDateTimeString("open_date", "yyyy/M/d")) + "," + Util.dbchar(dr.SafeRead("pay_times", ""));
            SQL += "," + Util.dbnull(dr.GetDateTimeString("pay_date", "yyyy/M/d")) + "," + Util.dbnull(dr.GetDateTimeString("term1", "yyyy/M/d"));
            SQL += "," + Util.dbnull(dr.GetDateTimeString("term2", "yyyy/M/d")) + "," + Util.dbnull(dr.GetDateTimeString("end_date", "yyyy/M/d"));
            SQL += "," + Util.dbchar(dr.SafeRead("end_code", "")) + ",'B','NN'";
            SQL += ",getdate(),'" + Session["scode"] + "',getdate(),'" + Session["scode"] + "','" + arr_rs_agt_no[pno] + "','" + arr_send_way[pno] + "'";
            SQL += "," + Util.dbnull(arr_receipt_type[pno]) + "," + Util.dbnull(arr_receipt_title[pno]) + "," + Util.dbnull(issue_type);
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
                    Sys.insert_log_table(conn, "D", prgid, "dmt_attach", "attach_sqlno", attach_sqlno, "");

                    //當attach_sqlno <> empty時,表示db有值,必須刪除data(update attach_flag = 'D')
                    SQL = "update dmt_attach set attach_flag='D'";
                    SQL += ",tran_date=getdate(),tran_scode='" + Session["scode"] + "'";
                    SQL += " where attach_sqlno='" + attach_sqlno + "'";
                    conn.ExecuteNonQuery(SQL);

                    iposend_attach(pseq, pseq1, pstep_grade, step_date, ReqVal.TryGet("rs_code_name"), "D", "", "", "", dtO);
                } else {
                    Sys.insert_log_table(conn, "U", prgid, "dmt_attach", "attach_sqlno", attach_sqlno, "");

                    string old_attach_name = ReqVal.TryGet("old_" + uploadfield + "_name_" + i);//原檔案名稱
                    string attach_name = ReqVal.TryGet(uploadfield + "_name_" + i);//上傳檔名
                    string attach_path = ReqVal.TryGet(uploadfield + "_" + i);
                    string source_name = ReqVal.TryGet("source_name_" + i);

                    if (attach_name != old_attach_name) {//畫面上傳檔名與原檔案名稱不一樣，表示上傳新檔案，所以要更名
                        source_name = attach_name;
                        RenameFile(pseq, pseq1, pstep_grade, uploadfield, i, ref attach_path, ref attach_name);
                    }

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
                    ColMap["doc_flag"] = Util.dbnull(Request["doc_flag_" + i]);
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

        SQL = "select * from dmt_attach where seq=" + pseq + " and seq1='" + pseq1 + "' and step_grade=" + pstep_grade + " and attach_flag<>'D' order by attach_no";
        using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
            while (dr.Read()) {
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
                SQL += ",'cgrs',getdate(),'" + Session["scode"] + "'," + Util.dbchar(dr.SafeRead("attach_no", "")) + "," + Util.dbchar(newattach_path);
                SQL += "," + Util.dbchar(dr.SafeRead("doc_type", "")) + "," + Util.dbchar(dr.SafeRead("attach_desc", "")) + "," + Util.dbchar(attach_name);
                SQL += "," + Util.dbchar(dr.SafeRead("source_name", "")) + "," + Util.dbchar(dr.SafeRead("attach_size", ""));
                SQL += ",'A','',getdate(),'" + Session["scode"] + "'," + patt_sqlno;
                SQL += ")";
                conn.ExecuteNonQuery(SQL);
            }
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

        string strpath = Request[uploadfield + "_" + nRow];//存檔路徑
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
</script>

<%Response.Write(strOut.ToString());%>
