<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>

<script runat="server">
    protected string HTProgCap = "承辦註冊費電子送件批次入檔";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "brt63";//程式檔名前綴
    protected string HTProgCode = "brt63";//HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";

    protected string submitTask = "";
    protected string SQL = "";
    protected object objResult = null;
    protected string logReason="brt63承辦交辦批次註冊費作業";
        
    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected Dictionary<string, string> ColMap = new Dictionary<string, string>();

    string[] arr_chk,arr_seq,arr_seq1,arr_todo_sqlno,arr_eappl_name,arr_eappl_name1;
    string[] arr_zname_type,arr_dmt_pay_times,arr_spe_ctrl_4,arr_fees,arr_case_fees;
    string[] arr_step_date,arr_mp_date,arr_send_sel,arr_apply_no,arr_pay_times,arr_pay_date,arr_pr_scode;

    string[] arr_send_way,arr_case_no,arr_send_cl,arr_send_cl1,arr_in_scode,arr_in_no;
    string[] arr_rs_type,arr_rs_class,arr_rs_code,arr_act_code,arr_rs_detail,arr_agt_no;
    string[] arr_fees_stat,arr_opt_branch,arr_contract_flag,arr_rs_agt_no,arr_rs_agt_nonm;

    string[] arr_receipt_type,arr_receipt_title,arr_rectitle_name,arr_tmprectitle_name;

    string[] arr_signid;

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

        arr_chk = Request["rows_chk"].Split('\f');
        arr_seq = Request["rows_seq"].Split('\f');
        arr_seq1 = Request["rows_seq1"].Split('\f');
        arr_todo_sqlno = Request["rows_todo_sqlno"].Split('\f');
        arr_eappl_name = Request["rows_eappl_name"].Split('\f');
        arr_eappl_name1 = Request["rows_eappl_name1"].Split('\f');
        arr_zname_type = Request["rows_zname_type"].Split('\f');
        arr_dmt_pay_times = Request["rows_dmt_pay_times"].Split('\f');
        arr_spe_ctrl_4 = Request["rows_spe_ctrl_4"].Split('\f');
        arr_fees = Request["rows_fees"].Split('\f');
        arr_case_fees = Request["rows_case_fees"].Split('\f');
        arr_step_date = Request["rows_step_date"].Split('\f');
        arr_mp_date = Request["rows_mp_date"].Split('\f');
        arr_send_sel = Request["rows_send_sel"].Split('\f');
        arr_apply_no = Request["rows_apply_no"].Split('\f');
        arr_pay_times = Request["rows_pay_times"].Split('\f');
        arr_pay_date = Request["rows_pay_date"].Split('\f');
        arr_pr_scode = Request["rows_pr_scode"].Split('\f');

        arr_send_way = Request["rows_send_way"].Split('\f');
        arr_case_no = Request["rows_case_no"].Split('\f');
        arr_send_cl = Request["rows_send_cl"].Split('\f');
        arr_send_cl1 = Request["rows_send_cl1"].Split('\f');
        arr_in_scode = Request["rows_in_scode"].Split('\f');
        arr_in_no = Request["rows_in_no"].Split('\f');
        arr_rs_type = Request["rows_rs_type"].Split('\f');
        arr_rs_class = Request["rows_rs_class"].Split('\f');
        arr_rs_code = Request["rows_rs_code"].Split('\f');
        arr_act_code = Request["rows_act_code"].Split('\f');
        arr_rs_detail = Request["rows_rs_detail"].Split('\f');
        arr_agt_no = Request["rows_agt_no"].Split('\f');
        arr_fees_stat = Request["rows_fees_stat"].Split('\f');
        arr_opt_branch = Request["rows_opt_branch"].Split('\f');
        arr_contract_flag = Request["rows_contract_flag"].Split('\f');
        arr_rs_agt_no = Request["rows_rs_agt_no"].Split('\f');
        arr_rs_agt_nonm = Request["rows_rs_agt_nonm"].Split('\f');

        arr_receipt_type = Request["rows_receipt_type"].Split('\f');
        arr_receipt_title = Request["rows_receipt_title"].Split('\f');
        arr_rectitle_name = Request["rows_rectitle_name"].Split('\f');
        arr_tmprectitle_name = Request["rows_tmprectitle_name"].Split('\f');

        arr_signid = Request["rows_signid"].Split('\f');

        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        HTProgCap = myToken.Title;
        DebugStr = myToken.DebugStr;
        if (HTProgRight >= 0) {
            try {
                conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");

                doUpdateDB();
                strOut.AppendLine("<div align='center'><h1>承辦交辦發文成功!!!</h1></div>");
                conn.Commit();
                //conn.RollBack();
            }
            catch (Exception ex) {
                conn.RollBack();
                Sys.errorLog(ex, conn.exeSQL, prgid);
                throw;
            }
            finally {
                conn.Dispose();
            }
            this.DataBind();
        }
    }

    private void doUpdateDB() {
        if (ReqVal.TryGet("task") == "conf") {
            //新增attcase_dmt交辦發文檔
            string sign_stat = "SN";

            for (int i = 1; i < arr_chk.Length; i++) {
                if (arr_chk[i] == "Y") {//有打勾
                    string todo_sqlno = arr_todo_sqlno[i];
                    Sys.showLog("<font color=red>﹝" + i + "﹞</font>todo_sqlno=" + todo_sqlno);
                    //判斷狀態是否已異動,防止開雙視窗
                    SQL = "select count(*) from todo_dmt where sqlno='" + todo_sqlno + "' and job_status='NN'";
                    object objResult = conn.ExecuteScalar(SQL);
                    int cnt = (objResult == DBNull.Value || objResult == null) ? 0 : Convert.ToInt32(objResult);
                    if (cnt == 0) {
                        throw new Exception("接洽序號" + arr_in_no[i] + "-入檔失敗(流程狀態已異動，請重新整理畫面)");
                    } else {
                        //更新收據種類&收據抬頭
                        Sys.insert_log_table(conn, "U", prgid, "case_dmt", "in_scode;in_no", arr_in_scode[i] + ";" + arr_in_no[i], logReason);
                        SQL = "UPDATE case_dmt SET ";
                        SQL += " receipt_type = '" + arr_receipt_type[i] + "' ";
                        SQL += ",receipt_title = " + Util.dbchar(arr_receipt_title[i]) + " ";
                        SQL += ",rectitle_name = " + Util.dbchar(arr_rectitle_name[i]) + " ";
                        SQL += " where in_scode = '" + arr_in_scode[i] + "' and in_no = '" + arr_in_no[i] + "'";
                        conn.ExecuteNonQuery(SQL);

                        //再抓一次交辦流水號,防止多個視窗同時存檔
                        string Getatt_sqlno = "0";
                        SQL = "select att_sqlno,0 ord from attcase_dmt where in_no='" + arr_in_no[i] + "' and sign_stat='SN' ";
                        SQL += "union all ";
                        SQL += "select att_sqlno,1 ord from attcase_dmt where in_no='" + arr_in_no[i] + "' and sign_stat='NN' ";
                        SQL += "order by ord ";
                        using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
                            if (dr.Read()) {
                                Getatt_sqlno = dr.SafeRead("att_sqlno", "0");
                            }
                        }

                        if (Convert.ToInt32(Getatt_sqlno) > 0) {
                            //入attcase_dmt_log
                            Sys.insert_log_table(conn, "U", prgid, "attcase_dmt", "att_sqlno", Getatt_sqlno, logReason);

                            SQL = "update attcase_dmt set ";
                            ColMap.Clear();
                            ColMap["pr_scode"] = Util.dbchar(arr_pr_scode[i]);//承辦人員
                            ColMap["step_date"] = Util.dbchar(arr_step_date[i]);//發文日期
                            ColMap["mp_date"] = Util.dbchar(arr_mp_date[i]);//總管處發文日期
                            ColMap["send_cl"] = Util.dbchar(arr_send_cl[i]);//收發單位
                            ColMap["send_cl1"] = Util.dbchar(arr_send_cl1[i]);//副本單位
                            ColMap["send_sel"] = Util.dbchar(arr_send_sel[i]);//官方號碼
                            ColMap["rs_class"] = Util.dbchar(arr_rs_class[i]);//發文代碼結構分類
                            ColMap["rs_code"] = Util.dbchar(arr_rs_code[i]);//發文代碼
                            ColMap["act_code"] = Util.dbchar(arr_act_code[i]);//處理事項代碼
                            ColMap["rs_detail"] = Util.dbchar(arr_rs_detail[i]);//發文內容
                            ColMap["fees"] = Util.dbzero(arr_fees[i]);//規費
                            ColMap["fees_stat"] = Util.dbchar(arr_fees_stat[i]);//規費狀態
                            ColMap["rs_agt_no"] = Util.dbchar(arr_rs_agt_no[i]);//出名代理人
                            ColMap["opt_branch"] = Util.dbchar(arr_opt_branch[i]);//發文單位
                            ColMap["sign_stat"] = Util.dbchar(sign_stat);
                            ColMap["send_way"] = Util.dbchar(arr_send_way[i]);//發文方式
                            SQL += ColMap.GetUpdateSQL();
                            SQL += " where att_sqlno=" + Getatt_sqlno;
                            conn.ExecuteNonQuery(SQL);
                        } else {
                            SQL = "insert into attcase_dmt ";
                            ColMap.Clear();
                            ColMap["in_scode"] = Util.dbchar(arr_in_scode[i]);
                            ColMap["in_no"] = Util.dbchar(arr_in_no[i]);
                            ColMap["case_no"] = Util.dbchar(arr_case_no[i]);
                            ColMap["pr_scode"] = Util.dbchar(arr_pr_scode[i]);
                            ColMap["in_date"] = Util.dbchar(DateTime.Today.ToShortDateString());
                            ColMap["seq"] = Util.dbnull(arr_seq[i]);
                            ColMap["seq1"] = Util.dbchar(arr_seq1[i]);
                            ColMap["step_date"] = Util.dbchar(arr_step_date[i]);
                            ColMap["mp_date"] = Util.dbchar(arr_mp_date[i]);
                            ColMap["send_cl"] = Util.dbchar(arr_send_cl[i]);
                            ColMap["send_cl1"] = Util.dbchar(arr_send_cl1[i]);
                            ColMap["send_sel"] = Util.dbchar(arr_send_sel[i]);
                            ColMap["rs_type"] = Util.dbchar(arr_rs_type[i]);
                            ColMap["rs_class"] = Util.dbchar(arr_rs_class[i]);
                            ColMap["rs_code"] = Util.dbchar(arr_rs_code[i]);
                            ColMap["act_code"] = Util.dbchar(arr_act_code[i]);
                            ColMap["rs_detail"] = Util.dbchar(arr_rs_detail[i]);
                            ColMap["fees"] = Util.dbzero(arr_fees[i]);
                            ColMap["fees_stat"] = Util.dbchar(arr_fees_stat[i]);
                            ColMap["rs_agt_no"] = Util.dbchar(arr_rs_agt_no[i]);
                            ColMap["opt_branch"] = Util.dbchar(arr_opt_branch[i]);
                            ColMap["remark"] = Util.dbchar(Request["job_remark"]);
                            ColMap["tot_num"] = "1";
                            ColMap["sign_stat"] = Util.dbchar(sign_stat);
                            ColMap["todo_sqlno"] = Util.dbnull(todo_sqlno);
                            ColMap["send_way"] = Util.dbchar(arr_send_way[i]);
                            SQL += ColMap.GetInsertSQL();
                            conn.ExecuteNonQuery(SQL);

                            //抓insert後的流水號
                            SQL = "SELECT SCOPE_IDENTITY() AS Current_Identity";
                            object objResult1 = conn.ExecuteScalar(SQL);
                            Getatt_sqlno = objResult1.ToString();
                        }

                        //更新todo_dmt承辦交辦發文
                        update_todolist(todo_sqlno, "YY");

                        string in_team = Sys.getCodeName(conn, "sysctrl.dbo.scode_group", "grpid", "where grpclass='" + Session["seBranch"] + "' and scode='" + arr_in_scode[i] + "'");
                        if (arr_contract_flag[i] == "Y") {//尚有契約書需後補，先經主管簽核
                            string job_team = Sys.getCodeName(conn, "sysctrl.dbo.scode_group", "grpid", "where grpclass='" + Session["seBranch"] + "' and scode='" + arr_signid[i] + "'");

                            SQL = "insert into todo_dmt ";
                            ColMap.Clear();
                            ColMap["pre_sqlno"] = Util.dbnull(todo_sqlno);
                            ColMap["syscode"] = "'" + Session["syscode"] + "'";
                            ColMap["apcode"] = "'" + prgid + "'";
                            ColMap["temp_rs_sqlno"] = Util.dbnull(Getatt_sqlno);
                            ColMap["branch"] = "'" + Session["seBranch"] + "'";
                            ColMap["seq"] = Util.dbnull(arr_seq[i]);
                            ColMap["seq1"] = Util.dbchar(arr_seq1[i]);
                            ColMap["in_team"] = Util.dbchar(in_team);
                            ColMap["case_in_scode"] = Util.dbchar(arr_in_scode[i]);
                            ColMap["in_no"] = Util.dbchar(arr_in_no[i]);
                            ColMap["case_no"] = Util.dbchar(arr_case_no[i]);
                            ColMap["from_flag"] = Util.dbchar("CGRS");
                            ColMap["in_date"] = "getdate()";
                            ColMap["in_scode"] = "'" + Session["scode"] + "'";
                            ColMap["dowhat"] = Util.dbchar("DB_GS");//主管發文簽核,ref:cust_code.code_type='Ttodo'
                            ColMap["job_team"] = Util.dbchar(job_team);
                            ColMap["job_scode"] = Util.dbchar(arr_signid[i]);
                            ColMap["job_status"] = Util.dbchar("NN");
                            SQL += ColMap.GetInsertSQL();
                            conn.ExecuteNonQuery(SQL);
                        } else {
                            //新增todo_dmt程序官發確認，無契約書後補或已後補完成
                            string job_scode = Sys.getCodeName(conn, "sysctrl.dbo.scode_group", "scode", "where grpclass='" + Session["seBranch"] + "' and grpid='T210' and grptype='F'");

                            SQL = "insert into todo_dmt ";
                            ColMap.Clear();
                            ColMap["pre_sqlno"] = Util.dbnull(todo_sqlno);
                            ColMap["syscode"] = "'" + Session["syscode"] + "'";
                            ColMap["apcode"] = "'" + prgid + "'";
                            ColMap["temp_rs_sqlno"] = Util.dbnull(Getatt_sqlno);
                            ColMap["branch"] = "'" + Session["seBranch"] + "'";
                            ColMap["seq"] = Util.dbnull(arr_seq[i]);
                            ColMap["seq1"] = Util.dbchar(arr_seq1[i]);
                            ColMap["in_team"] = Util.dbchar(in_team);
                            ColMap["case_in_scode"] = Util.dbchar(arr_in_scode[i]);
                            ColMap["in_no"] = Util.dbchar(arr_in_no[i]);
                            ColMap["case_no"] = Util.dbchar(arr_case_no[i]);
                            ColMap["from_flag"] = Util.dbchar("CGRS");
                            ColMap["in_date"] = "getdate()";
                            ColMap["in_scode"] = "'" + Session["scode"] + "'";
                            ColMap["dowhat"] = Util.dbchar("DC_GS");//程序官發確認,ref:cust_code.code_type='Ttodo'
                            ColMap["job_team"] = Util.dbchar("T210");
                            ColMap["job_scode"] = Util.dbchar(job_scode);
                            ColMap["job_status"] = Util.dbchar("NN");
                            SQL += ColMap.GetInsertSQL();
                            conn.ExecuteNonQuery(SQL);
                        }
                    }
                }
            }
        }
    }
    
    //更新todolist
    private void update_todolist(string todo_sqlno, string tstatus) {
        SQL = "update todo_dmt set approve_scode='" + Session["scode"] + "'";
        SQL += ",resp_date=getdate()";
        SQL += ",job_status='" + tstatus + "'";
        SQL += ",approve_desc=" + Util.dbchar(ReqVal.TryGet("job_remark"));
        SQL += " where sqlno=" + todo_sqlno + " and job_status='NN' ";
        conn.ExecuteNonQuery(SQL);
    }
</script>

<%Response.Write(strOut.ToString());%>
