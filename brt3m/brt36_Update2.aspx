<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Linq"%>

<script runat="server">
    protected string HTProgCap = HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "brt36";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";

    protected string submitTask = "";
    protected string SQL = "";

    protected int tot = 0;
    protected string row = "";
    protected string qs_dept = "";
    protected string dept = "";
    protected string tblname = "";
    protected string att_tblname = "";
    protected string dowhat = "";
    protected string status = "";
    protected bool contract_flag_mail = false;
    
    protected string msg = "";
    protected List<string> tin_no = new List<string>();
    protected List<string> tappl_name = new List<string>();
    protected List<string> tcase_name = new List<string>();
    protected List<string> tseq = new List<string>();
    protected List<string> email_pr_scode = new List<string>();
    protected List<string> email_scode = new List<string>();

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

        row = (Request["row"] ?? "").Trim();
        qs_dept = (Request["qs_dept"] ?? "").Trim();
        status = (Request["status"] ?? "").Trim();

        if (qs_dept == "t") {
            HTProgCode = "brt36";
            HTProgCap = "國內案官發簽核作業";
            tblname = "todo_dmt";
            att_tblname = "attcase_dmt";
            dowhat = "DP_GS";//承辦交辦發文,ref:cust_code.code_type='Ttodo'
            dept = "t";
       } else {
           HTProgCode = "ext36";
            HTProgCap = "出口案發文簽核作業";
            tblname = "todo_ext";
            dept = "e";
            dowhat = "DP_TS";//承辦交辦國外所,ref:cust_code.code_type='TEtodo'
            att_tblname = "attcase_ext";
        }
        
        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        HTProgCap = myToken.Title;
        DebugStr = myToken.DebugStr;
        if (HTProgRight >= 0) {
            try {
                conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");

                bool task = doUpdateDB();
                if (task) {
                    strOut.AppendLine("<div align='center'><h1>資料更新成功</h1></div>");
                    CreateMail();
                } else {
                    if (msg == "")
                        strOut.AppendLine("<div align='center'><h1>資料更新失敗</h1></div>");
                    else
                        strOut.AppendLine("<div align='center'><h1>部分資料更新失敗" + msg + "</h1></div>");
                }
                conn.Commit();
                //conn.RollBack();
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
            this.DataBind();
        }
    }

    //'****簽核狀態為轉下一單位簽核或簽准
    private bool doUpdateDB() {
        string job_team = "", job_grplevel = "";
        Sys.getScodeGrpid(Sys.GetSession("seBranch"), Request["signidnext"], ref job_team, ref job_grplevel);

        for (int i = 1; i <= Convert.ToInt32("0" + row); i++) {
            if (Request["C_" + i] == "Y") {
                string tsqlno = ReqVal.TryGet("code_" + i);//todo.sqlno
                string Min_no = ReqVal.TryGet("In_no_" + i);
                string asqlno = ReqVal.TryGet("acode_" + i);//att_sqlno
                string Mscode = ReqVal.TryGet("In_scode_" + i);
                string pre_sqlno = ReqVal.TryGet("pre_sqlno_" + i);
                string work_opt = ReqVal.TryGet("work_opt_" + i);
                string seq = ReqVal.TryGet("seq_" + i);
                string seq1 = ReqVal.TryGet("seq1_" + i);
                string country = ReqVal.TryGet("country_" + i);
                string pr_scode = ReqVal.TryGet("pr_scode_" + i);
                string tdept = "";
                string fseq = "";
                if (country == "")
                    tdept = "T";
                else
                    tdept = "TE";

                fseq = Sys.formatSeq(seq, seq1, country, Sys.GetSession("seBranch"), tdept);

                //判斷狀態是否已異動,防止開雙視窗
                //SQL = "select count(*) from " + tblname + " where in_no='20200203001' and Job_status<>'NN'";
                SQL = "select count(*) from " + tblname + " where sqlno='" + tsqlno + "' and Job_status='NN'";
                object objResult = conn.ExecuteScalar(SQL);
                int cnt = (objResult == DBNull.Value || objResult == null) ? 0 : Convert.ToInt32(objResult);

                if (cnt == 0) {
                    msg = "案件 " + fseq + " 簽核失敗<BR>(流程狀態已異動，請重新整理畫面)";
                    return false;
                } else {
                    //更新todo
                    SQL = "UPDATE " + tblname + " SET";
                    SQL += " Job_status = 'XS' ";
                    SQL += ",resp_date = getdate() ";
                    SQL += ",approve_scode = '" + Session["scode"] + "' ";
                    SQL += ",approve_desc = " + Util.dbnull(Request["signdetail"]) + " ";
                    SQL += " WHERE sqlno='" + tsqlno + "'";
                    conn.ExecuteNonQuery(SQL);

                    //更新交辦狀態
                    if (work_opt != "P") {//新增交辦發文，不用修改客收交辦之最近狀態,2015/5/7修改
                        SQL = "Insert Into " + tblname + "(Branch,Syscode,Apcode,In_team,case_In_scode,In_no,Case_no,in_scode,in_date,dowhat,Job_scode,job_team,Job_status,from_flag,seq,seq1,step_grade)";
                        SQL += " select branch,syscode,'" + HTProgCode + "',in_team,case_in_scode,in_no,case_no,'" + Session["scode"] + "',getdate(),'" + dowhat + "','" + pr_scode + "','','NN',from_flag,seq,seq1,step_grade ";
                        SQL += " from " + tblname + " where sqlno = '" + pre_sqlno + "'";
                        conn.ExecuteNonQuery(SQL);
                        if (dept == "e") {
                            //更新交辦檔最近狀態case_ext.stat_code
                            SQL = "update Case_ext set stat_code = 'YZ' where in_no = '" + Min_no + "'";
                            conn.ExecuteNonQuery(SQL);
                        }
                    }

                    //更新聯絡交辦單最近狀態attcase_ext.sign_stat
                    SQL = "update " + att_tblname + " set sign_stat = 'SX' where att_sqlno = " + asqlno;
                    conn.ExecuteNonQuery(SQL);

                    if (dept == "e") {
                        SQL = "UPDATE license_br SET";
                        SQL += " case_flag = 'X'";
                        SQL += ", cancel_date = '" + DateTime.Today.ToShortDateString() + "'";
                        SQL += ", tran_scode = '" + Session["scode"] + "'";
                        SQL += ", tran_date = GETDATE()";
                        SQL += " OUTPUT 'U', GETDATE(), '" + Session["scode"] + "', '" + prgid + "', DELETED.* INTO license_br_log";
                        SQL += " WHERE seq = '" + seq + "'";
                        SQL += " AND seq1 = '" + seq1 + "'";
                        SQL += " AND att_sqlno = '" + asqlno + "'";
                        conn.ExecuteNonQuery(SQL);
                    }

                    if (Request["contract_flag_" + i] == "Y") {
                        contract_flag_mail = true;

                        tin_no.Add(Min_no);
                        tappl_name.Add(Request["appl_name_" + i]);
                        tcase_name.Add(Request["case_arcase_" + i] + "_" + Request["case_name_" + i]);
                        tseq.Add(fseq);
                        email_pr_scode.Add(pr_scode);
                        email_scode.Add(Mscode);

                        tot += 1;
                    }
                }
            }
        }
        
        return true;
    }

    private void CreateMail() {
        if (contract_flag_mail == true) {
            string Subject = "";
            string strFrom = Session["sc_name"] + "<" + Session["scode"] + "@saint-island.com.tw>";
            List<string> strTo = new List<string>();
            List<string> strCC = new List<string>();
            List<string> strBCC = new List<string>();
            switch (Sys.Host) {
                case "web08":
                case "localhost":
                    strTo.Add(Session["scode"] + "@saint-island.com.tw");
                    break;
                case "web10":
                    strTo.Add(Session["scode"] + "@saint-island.com.tw");
                    strBCC.Add("m1583@saint-island.com.tw");
                    break;
                default:
                    strCC.Add(Request["prscode"] + "@saint-island.com.tw");///副本-程序人員
                    foreach (var s in email_pr_scode) {
                        strTo.Add(s + "@saint-island.com.tw");//正本-承辦
                    }
                    foreach (var s in email_scode) {
                        strTo.Add(s + "@saint-island.com.tw");//正本-營洽
                        //直屬主管
                        string master_scode = Sys.getSignMaster(Sys.GetSession("SeBranch"), s, false);
                        if (master_scode != s && !email_scode.Contains(s)) {
                            strCC.Add(master_scode + "@saint-island.com.tw");//檢查直屬主管與營洽不同且不在正本裡則加到副本
                        }
                    }

                    //抓取副本通知人員-商標部門主管
                    string master_scode1 = Sys.getSignList(Sys.GetSession("seBranch"), "", "", "", "grplevel=2").Select()[0]["master_scode"].ToString();
                    if (master_scode1 != "" && !strCC.Contains(master_scode1)) {
                        strCC.Add(master_scode1 + "@saint-island.com.tw");
                    }

                    //抓取副本通知人員-區所主管
                    string master_scode2 = Sys.getSignList(Sys.GetSession("seBranch"), "", "", "", "grplevel=1").Select()[0]["master_scode"].ToString();
                    if (master_scode2 != "" && !strCC.Contains(master_scode2)) {
                        strCC.Add(master_scode2 + "@saint-island.com.tw");
                    }
                    break;
            }

            string qs_deptnm = "", qs_dept_title = "";
            if (qs_dept == "t") {
                qs_deptnm = "國內案";
                qs_dept_title = "國內案交辦發文";
            } else if (qs_dept == "e") {
                qs_deptnm = "出口案";
                qs_dept_title = "國外所出口案交辦";
            }

            string body = dobody();
            body += "<br><font color=blue>◎請先通知相關人員至" + qs_deptnm + "契約書後補作業，完成契約書相關文件上傳。<br>";
            body += "◎再請至：商標網路作業系統－＞";
            string tsub = "退回";
            body += "承辦作業－＞" + qs_dept_title + "作業，重新進行交辦作業。</font>";
            Subject = "商標網路作業系統~契約書後補先行發文之主管" + tsub + "通知";

            Sys.DoSendMail(Subject, body, strFrom, strTo, strCC, strBCC);
        }
    }
    
    //信件內容
    private string dobody() {
        string tbody = "";
        tbody += "區所 : " + Sys.bName(Sys.GetSession("seBranch")) + "<br>";
        tbody += "本所編號 : " + string.Join("、", tseq.ToArray()) + "<br>";
        tbody += "接洽序號 : " + string.Join("、", tin_no.ToArray()) + "<br>";
        tbody += "案件名稱 : " + string.Join("、", tappl_name.ToArray()) + "<br>";
        tbody += "發文案性 : " + string.Join("、", tcase_name.ToArray()) + "<br>";
        tbody += "退回件數 : 共  " + tot + " 件<br>";
        if ((Request["signdetail"] ?? "") != "") {
            tbody += "主管簽核說明 :  " + Request["signdetail"] + " <br>";
        }
        tbody += "<br>主管不同意上述契約書後補之交辦案件可先行發文。<br>";
        return tbody;
    }
</script>

<%Response.Write(strOut.ToString());%>
