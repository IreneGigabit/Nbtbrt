﻿<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Linq"%>

<script runat="server">
    protected string HTProgCap = "國內案結案案件簽核";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "brt3f";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";

    protected string submitTask = "";
    protected string SQL = "";
    protected object objResult = null;

    protected int tot = 0;
    protected string row = "";
    protected string status = "";

    protected string msg = "";
    protected string todo = "",dowhat="";

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

        conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");

        row = (Request["row"] ?? "").Trim();
        status = (Request["status"] ?? "").Trim();

        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        HTProgCap = myToken.Title;
        DebugStr = myToken.DebugStr;
        if (HTProgRight >= 0) {
            try {
                bool task = false;

                if (status == "YY") {
                    todo = "send";
                    dowhat = "DC_END2";
                } else if (status == "YT") {
                    todo = "send";
                    dowhat = "DB_END";
                } else if (status == "NX") {
                    todo = "reject";
                    dowhat = "DC_END1";
                }

                if (todo == "send") {
                    task = insert_todo_dmt();//送主管簽核
                } else if (todo == "reject") {
                    task = update_todo_dmt();//退回程序
                }

                if (task) {
                    strOut.AppendLine("<div align='center'><h1>國內案主管結案簽核成功</h1></div>");
                } else {
                    if (msg == "")
                        strOut.AppendLine("<div align='center'><h1>國內案主管結案簽核失敗</h1></div>");
                    else
                        strOut.AppendLine("<div align='center'><h1>" + msg + "</h1></div>");
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

    //'****送主管簽核
    private bool insert_todo_dmt() {
        for (int i = 1; i <= Convert.ToInt32("0" + row); i++) {
            if (Request["C_" + i] == "Y") {
                string tmp_sqlno = ReqVal.TryGet("todo_sqlno_" + i);
                string tmp_seq = ReqVal.TryGet("seq_" + i);
                string tmp_seq1 = ReqVal.TryGet("seq1_" + i);
                string tmp_scode = ReqVal.TryGet("scode_" + i);
                string fseq = Sys.formatSeq(tmp_seq, tmp_seq1, "", Sys.GetSession("seBranch"), "T");

                //判斷狀態是否已異動,防止開雙視窗
                SQL = "select count(*) from todo_dmt where sqlno='" + tmp_sqlno + "' and Job_status='NN'";
                objResult = conn.ExecuteScalar(SQL);
                int cnt = (objResult == DBNull.Value || objResult == null) ? 0 : Convert.ToInt32(objResult);

                if (cnt == 0) {
                    msg = "案件 " + fseq + " 簽核失敗<BR>(流程狀態已異動，請重新整理畫面)";
                    return false;
                } else {
                    //更新主管簽核處理狀態
                    SQL = "update todo_dmt set job_status = '" + status + "' ";
                    SQL += " ,approve_scode = '" + Session["scode"] + "'";
                    SQL += " ,approve_desc = " + Util.dbchar(ReqVal.TryGet("signdetail"));
                    SQL += " ,resp_date=getdate() ";
                    SQL += " where sqlno = " + tmp_sqlno;
                    conn.ExecuteNonQuery(SQL);

                    //新增流程主管簽核YT,程序結案確認YY
                    string job_team = Sys.getCodeName(conn, "sysctrl.dbo.scode_group", "grpid", "where grpclass='" + Session["seBranch"] + "' and scode='" + Request["signidnext"] + "'");
                    SQL = "insert into todo_dmt(pre_sqlno,syscode,apcode,from_flag,branch,seq,seq1,step_grade,in_no,case_no,case_in_scode,in_scode,in_date";
                    SQL += ",dowhat,job_scode,job_team,job_status) ";
                    SQL += "select sqlno,syscode,'" + prgid + "','END','" + Session["SeBranch"] + "'," + tmp_seq + ",'" + tmp_seq1 + "'";
                    SQL += ",step_grade,in_no,case_no,'" + tmp_scode + "','" + Session["scode"] + "'";
                    SQL += ",getdate(),'" + dowhat + "','" + Request["signidnext"] + "','" + job_team + "','NN'";
                    SQL += " from todo_dmt where sqlno=" + tmp_sqlno;
                    conn.ExecuteNonQuery(SQL);
                }
            }
        }

        return true;
    }

    //'****退回程序
    private bool update_todo_dmt() {
        List<string> strTo = new List<string>();

        for (int i = 1; i <= Convert.ToInt32("0" + row); i++) {
            if (Request["C_" + i] == "Y") {
                string tmp_sqlno = ReqVal.TryGet("todo_sqlno_" + i);
                string tmp_seq = ReqVal.TryGet("seq_" + i);
                string tmp_seq1 = ReqVal.TryGet("seq1_" + i);
                string tmp_scode = ReqVal.TryGet("scode_" + i);
                string fseq = Sys.formatSeq(tmp_seq, tmp_seq1, "", Sys.GetSession("seBranch"), "T");

                //判斷狀態是否已異動,防止開雙視窗
                SQL = "select count(*) from todo_dmt where sqlno='" + tmp_sqlno + "' and Job_status='NN'";
                objResult = conn.ExecuteScalar(SQL);
                int cnt = (objResult == DBNull.Value || objResult == null) ? 0 : Convert.ToInt32(objResult);

                if (cnt == 0) {
                    msg = "案件 " + fseq + " 簽核失敗<BR>(流程狀態已異動，請重新整理畫面)";
                    return false;
                } else {
                    //更新主管結案簽核狀態
                    SQL = "update todo_dmt set job_status = 'NX' ";
                    SQL += " ,approve_scode = '" + Session["scode"] + "'";
                    SQL += " ,approve_desc = " + Util.dbchar(ReqVal.TryGet("signdetail"));
                    SQL += " ,resp_date=getdate() ";
                    SQL += " where sqlno = " + tmp_sqlno;
                    conn.ExecuteNonQuery(SQL);

                    //新增退回程序處理
                    string job_team = Sys.getCodeName(conn, "sysctrl.dbo.scode_group", "grpid", "where grpclass='" + Session["seBranch"] + "' and scode='" + Request["signidnext"] + "'");
                    SQL = "insert into todo_dmt(pre_sqlno,syscode,apcode,from_flag,branch,seq,seq1,step_grade,in_no,case_no,case_in_scode,in_scode,in_date";
                    SQL += ",dowhat,job_scode,job_team,job_status) ";
                    SQL += "select sqlno,syscode,'" + prgid + "','END_DB','" + Session["SeBranch"] + "'," + tmp_seq + ",'" + tmp_seq1 + "'";
                    SQL += ",step_grade,in_no,case_no,'" + tmp_scode + "','" + Session["scode"] + "'";
                    SQL += ",getdate(),'" + dowhat + "','" + Request["signidnext"] + "','" + job_team + "','NN'";
                    SQL += " from todo_dmt where sqlno=" + tmp_sqlno;
                    conn.ExecuteNonQuery(SQL);
                }
            }
        }

        return true;
    }
</script>

<%Response.Write(strOut.ToString());%>
