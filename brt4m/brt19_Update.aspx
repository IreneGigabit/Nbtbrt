<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Linq"%>

<script runat="server">
    protected string HTProgCap = "爭救案法定期限修改作業";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "brt19";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";

    protected string submitTask = "";
    protected string SQL = "";
    protected object objResult = null;

    protected string logReason = "brt19爭救案法定期限修改作業";

    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected Dictionary<string, string> ColMap = new Dictionary<string, string>();

    protected StringBuilder strOut = new StringBuilder();

    DBHelper conn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    DBHelper optconn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    DBHelper cnn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    private void Page_Unload(System.Object sender, System.EventArgs e) {
        if (conn != null) conn.Dispose();
        if (optconn != null) optconn.Dispose();
        if (cnn != null) cnn.Dispose();
    }

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");

        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        HTProgCap = myToken.Title;
        DebugStr = myToken.DebugStr;
        if (HTProgRight >= 0) {
            conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
            optconn = new DBHelper(Conn.optK).Debug(Request["chkTest"] == "TEST");
            try {
                doUpdate();
                CreateMail();

                optconn.Commit();
                conn.Commit();
                //optconn.RollBack();
                //conn.RollBack();
                strOut.AppendLine("<div align='center'><h1>爭救案法定期限資料維護成功!!</h1></div>");
            }
            catch (Exception ex) {
                optconn.RollBack();
                conn.RollBack();
                Sys.errorLog(ex, optconn.exeSQL, prgid);
                Sys.errorLog(ex, conn.exeSQL, prgid);
                //strOut.AppendLine("<div align='center'><h1>爭救案法定期限修改失敗("+ex.Message+")</h1></div>");
                throw;
            }
            finally {
                conn.Dispose();
            }
            this.DataBind();
        }
    }

    //入檔
    private void doUpdate() {
        SQL = "Insert into br_opt_log (prgid,opt_sqlno,Branch,BSeq,BSeq1,field_name,ovalue,nvalue,tran_date,tran_scode) Values";
        SQL += "('" + prgid + "'," + Util.dbchar(ReqVal.TryGet("opt_sqlno")) + "," + Util.dbchar(ReqVal.TryGet("Branch")) + "," + Util.dbchar(ReqVal.TryGet("Bseq"));
        SQL += "," + Util.dbchar(ReqVal.TryGet("Bseq1")) + ",'Last_date'," + Util.dbchar(ReqVal.TryGet("old_Last_date")) + "," + Util.dbchar(ReqVal.TryGet("Last_date"));
        SQL += ",getdate(),'" + Session["scode"] + "')";
        optconn.ExecuteNonQuery(SQL);

        SQL = "Update br_opt Set Last_date=" + Util.dbnull(ReqVal.TryGet("Last_date"));
        SQL += " Where opt_sqlno=" + Request["opt_sqlno"];
        optconn.ExecuteNonQuery(SQL);

        //修改區所客收進度法定期限
        if (ReqVal.TryGet("bstep_grade") != "" && ReqVal.TryGet("ctrl_date") != "") {
            //入ctrl_dmt_log
            Sys.insert_log_table(conn, "U", HTProgCode, "ctrl_dmt", "sqlno", ReqVal.TryGet("ctrl_sqlno"), logReason);

            SQL = "update ctrl_dmt set ";
            ColMap.Clear();
            ColMap["ctrl_date"] = Util.dbchar(ReqVal.TryGet("Last_date"));
            if (ReqVal.TryGet("from_flag") == "Y") {//重新抓取官收未銷法定期限，才更新官收進度及收文序號
                ColMap["from_rs_no"] = Util.dbnull(ReqVal.TryGet("from_rs_no"));
                ColMap["from_step_grade"] = Util.dbnull(ReqVal.TryGet("from_step_grade"));
            }
            ColMap["tran_date"] = "getdate()";
            ColMap["tran_scode"] = "'" + Session["scode"] + "'";
            SQL += ColMap.GetUpdateSQL();
            SQL += " where sqlno = " + Request["ctrl_sqlno"];
            conn.ExecuteNonQuery(SQL);
        }
    }

    private void CreateMail() {
        string fseq = Sys.formatSeq(Request["Bseq"], Request["Bseq1"], "", Sys.GetSession("seBranch"), Sys.GetSession("dept"));

        string Subject = "國內所商標爭救案件管理系統－爭救案件法定期限修改通知（區所編號：" + fseq + "）";
        string strFrom = Session["scode"] + "@saint-island.com.tw";
        List<string> strTo = new List<string>();
        List<string> strCC = new List<string>();
        List<string> strBCC = new List<string>();
        //爭救案人員
        SQL = "select scode from sysctrl.dbo.scode_roles where branch='" + Session["SeBranch"] + "' and dept='T' and roles='opt'";
        DataTable dt = new DataTable();
        optconn.DataTable(SQL, dt);

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
                strTo = dt.AsEnumerable().Select(r => r.Field<string>("scode") + "@saint-island.com.tw").ToList();
                break;
        }

        string body = "【區所案件編號】 : <B>" + fseq + "</B><br>";
        body += "【營洽】 : <B>" + ReqVal.TryGet("in_scode") + "-" + ReqVal.TryGet("scode_name") + "</B><br>";
        body += "【客戶名稱】 : <B>" + ReqVal.TryGet("cust_name") + "</B><br>";
        body += "【案件名稱】 : <B>" + ReqVal.TryGet("appl_name") + "</B><br>";
        body += "【案性】 : <B>" + ReqVal.TryGet("arcase_name") + "</B><br>";
        body += "【法定期限】 : <font color=red><B>" + ReqVal.TryGet("last_date") + "</font></B><br>";
        body += "◎區所修改本交辦案件之法定期限，請確認並進行後續作業。";

        Sys.DoSendMail(Subject, body, strFrom, strTo, strCC, strBCC);
    }
</script>

<%Response.Write(strOut.ToString());%>
