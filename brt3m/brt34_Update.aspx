<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Linq"%>

<script runat="server">
    protected string HTProgCap = "爭救案交辦專案室抽件簽核作業";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "brt34";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";

    protected string submitTask = "";
    protected string SQL = "";
    protected object objResult = null;

    protected int tot = 0;
    protected string row = "";
    protected string qs_dept = "";

    protected string msg = "";

    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected Dictionary<string, string> ColMap = new Dictionary<string, string>();

    protected StringBuilder strOut = new StringBuilder();

    DBHelper conn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    DBHelper connopt = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    private void Page_Unload(System.Object sender, System.EventArgs e) {
        if (conn != null) conn.Dispose();
        if (connopt != null) connopt.Dispose();
    }

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
        connopt = new DBHelper(Conn.optK).Debug(Request["chkTest"] == "TEST");
        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");

        row = (Request["row"] ?? "").Trim();
        qs_dept = (Request["qs_dept"] ?? "").Trim();
        submitTask = (Request["submitTask"] ?? "").Trim();
        
        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        HTProgCap = myToken.Title;
        DebugStr = myToken.DebugStr;
        if (HTProgRight >= 0) {
            try {
                bool task = false;
                if (submitTask == "U") {
                    task = doUpdateDB();
                } else if (submitTask == "B") {
                    task = doUpdateDB_Back();
                }
                
                if (task) {
                    if (submitTask == "U") {
                        strOut.AppendLine("<div align='center'><h1>爭救案抽件簽核成功</h1></div>");
                    } else if (submitTask == "B") {
                        strOut.AppendLine("<div align='center'><h1>爭救案抽件退回成功</h1></div>");
                    }
                } else {
                    if (msg == "")
                        strOut.AppendLine("<div align='center'><h1>爭救案抽件簽核失敗</h1></div>");
                    else
                        strOut.AppendLine("<div align='center'><h1>"+msg+"</h1></div>");
                }
                connopt.Commit();
                //connopt.RollBack();
            }
            catch (Exception ex) {
                connopt.RollBack();
                Sys.errorLog(ex, connopt.exeSQL, prgid);
                //strOut.AppendLine("<div align='center'><h1>資料更新失敗("+ex.Message+")</h1></div>");
                throw;
            }
            finally {
                connopt.Dispose();
            }
            this.DataBind();
        }
    }

    //'****簽准
    private bool doUpdateDB() {
        for (int i = 1; i <= Convert.ToInt32("0" + row); i++) {
            if (Request["C_" + i] == "Y") {
                string opt_sqlno = ReqVal.TryGet("opt_sqlno_" + i);
                string cancel_sqlno = ReqVal.TryGet("cancel_sqlno_" + i);
                string branch = ReqVal.TryGet("branch_" + i);
                string case_no = ReqVal.TryGet("Case_no_" + i);

                //判斷狀態是否已異動,防止開雙視窗
                SQL = "select count(*) from cancel_opt where opt_sqlno='" + opt_sqlno + "' and sqlno='" + cancel_sqlno + "' and tran_status='DT'";
                objResult = connopt.ExecuteScalar(SQL);
                int cnt = (objResult == DBNull.Value || objResult == null) ? 0 : Convert.ToInt32(objResult);

                if (cnt == 0) {
                    msg = "該筆交辦資料(" + case_no + ")簽核失敗！<BR>(流程狀態已異動，請重新整理畫面)";
                    return false;
                } else {
                    //更新分案主檔狀態
                    SQL = "Update br_opt Set stat_code='DD'";
                    SQL += " where opt_sqlno='" + opt_sqlno + "'";
                    connopt.ExecuteNonQuery(SQL);

                    //更新註銷記錄檔
                    SQL = "Update cancel_opt Set tran_status='DY'";
                    SQL += ",cap_date=getdate()";
                    SQL += ",tran_scode='" + Session["scode"] + "'";
                    SQL += ",tran_date=getdate()";
                    SQL += " where opt_sqlno='" + opt_sqlno + "'";
                    SQL += " and sqlno='" + cancel_sqlno + "'";
                    connopt.ExecuteNonQuery(SQL);

                    //找todo
                    SQL = "Select max(sqlno) as maxsqlno from todo_opt where syscode='" + Session["syscode"] + "'";
                    SQL += " and apcode='brt1a' and opt_sqlno='" + opt_sqlno + "'";
                    SQL += " and dowhat='DT'";
                    objResult = connopt.ExecuteScalar(SQL);
                    string pre_sqlno = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();
                    //更新todo
                    SQL = "update todo_opt set approve_scode='" + Session["scode"] + "'";
                    SQL += ",resp_date=getdate()";
                    SQL += ",job_status='YY'";
                    SQL += ",approve_desc=" + Util.dbchar(ReqVal.TryGet("signdetail"));
                    SQL += " where apcode='brt1a' and opt_sqlno='" + opt_sqlno + "'";
                    SQL += " and dowhat='DT' and syscode='" + Session["syscode"] + "'";
                    SQL += " and sqlno=" + pre_sqlno;
                    connopt.ExecuteNonQuery(SQL);

                    //入流程控制檔
                    SQL = " insert into todo_opt(pre_sqlno,syscode,apcode,opt_sqlno,branch,case_no,in_scode,in_date";
                    SQL += ",dowhat,job_scode,job_status) values (";
                    SQL += "'" + pre_sqlno + "','" + Session["syscode"] + "','" + prgid + "'," + opt_sqlno + ",'" + branch + "','" + case_no + "'";
                    SQL += ",'" + Session["scode"] + "',getdate(),'DD','','NN')";
                    connopt.ExecuteNonQuery(SQL);
                }
            }
        }

        CreateMail();
        return true;
    }

    //'****退回
    private bool doUpdateDB_Back() {
        List<string> strTo = new List<string>();

        for (int i = 1; i <= Convert.ToInt32("0" + row); i++) {
            if (Request["C_" + i] == "Y") {
                string opt_sqlno = ReqVal.TryGet("opt_sqlno_" + i);
                string cancel_sqlno = ReqVal.TryGet("cancel_sqlno_" + i);
                string branch = ReqVal.TryGet("branch_" + i);
                string case_no = ReqVal.TryGet("Case_no_" + i);
                string input_scode = ReqVal.TryGet("input_scode_" + i);

                //判斷狀態是否已異動,防止開雙視窗
                SQL = "select count(*) from cancel_opt where opt_sqlno='" + opt_sqlno + "' and sqlno='" + cancel_sqlno + "' and tran_status='DT'";
                objResult = connopt.ExecuteScalar(SQL);
                int cnt = (objResult == DBNull.Value || objResult == null) ? 0 : Convert.ToInt32(objResult);

                if (cnt == 0) {
                    msg = "該筆交辦資料(" + case_no + ")簽核失敗！<BR>(流程狀態已異動，請重新整理畫面)";
                    return false;
                } else {
                    //更新註銷記錄檔
                    SQL = "Update cancel_opt Set tran_status='DN'";
                    SQL += ",cap_date=getdate()";
                    SQL += ",tran_scode='" + Session["scode"] + "'";
                    SQL += ",tran_date=getdate()";
                    SQL += " where opt_sqlno='" + opt_sqlno + "'";
                    SQL += " and sqlno='" + cancel_sqlno + "'";
                    connopt.ExecuteNonQuery(SQL);

                    //找todo
                    SQL = "Select max(sqlno) as maxsqlno from todo_opt where syscode='" + Session["syscode"] + "'";
                    SQL += " and apcode='brt1a' and opt_sqlno='" + opt_sqlno + "'";
                    SQL += " and dowhat='DT'";
                    objResult = connopt.ExecuteScalar(SQL);
                    string pre_sqlno = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();
                    
                    //更新todo
                    SQL = "update todo_opt set approve_scode='" + Session["scode"] + "'";
                    SQL += ",resp_date=getdate()";
                    SQL += ",job_status='XX'";
                    SQL += ",approve_desc=" + Util.dbchar(ReqVal.TryGet("signdetail"));
                    SQL += " where apcode='brt1a' and opt_sqlno='" + opt_sqlno + "'";
                    SQL += " and dowhat='DT' and syscode='" + Session["syscode"] + "'";
                    SQL += " and sqlno=" + pre_sqlno;
                    connopt.ExecuteNonQuery(SQL);

                    if (input_scode != "") {
                        strTo.Add(input_scode + "@saint-island.com.tw");
                    }
                }
            }
        }

        CreateMail1(strTo);
        return true;
    }

    //簽准mail
    private void CreateMail() {
        string Subject = "";
        string strFrom = Session["sc_name"] + "<" + Session["scode"] + "@saint-island.com.tw>";
        List<string> strTo = new List<string>();
        List<string> strCC = new List<string>();
        List<string> strBCC = new List<string>();
        //爭救案人員
        SQL = "select scode from sysctrl.dbo.scode_roles where branch='" + Session["SeBranch"] + "' and dept='T' and roles='opt'";
        DataTable dt = new DataTable();
        connopt.DataTable(SQL, dt);

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
        string fseq="";
        string body = dobody(ref fseq);
        Subject += "國內所商標爭救案件管理系統－爭救案件抽件通知(區所編號：" + fseq + ")";

        Sys.DoSendMail(Subject, body, strFrom, strTo, strCC, strBCC);
    }

    //退回mail
    private void CreateMail1(List<string> strTo) {
        string Subject = "";
        string strFrom = Session["sc_name"] + "<" + Session["scode"] + "@saint-island.com.tw>";
        List<string> strCC = new List<string>();
        List<string> strBCC = new List<string>();
        SQL = "select scode from sysctrl.dbo.scode_roles where branch='" + Session["SeBranch"] + "' and dept='T' and roles='opt'";
        DataTable dt = new DataTable();
        connopt.DataTable(SQL, dt);

        switch (Sys.Host) {
            case "web08":
            case "localhost":
                strTo.Clear();
                strTo.Add(Session["scode"] + "@saint-island.com.tw");
                break;
            case "web10":
                strTo.Clear();
                strTo.Add(Session["scode"] + "@saint-island.com.tw");
                strBCC.Add("m1583@saint-island.com.tw");
                break;
        }
        string fseq = "";
        string body = dobody(ref fseq);
        body += "<font color=blue>【退回理由】 :</font><B>" + ReqVal.TryGet("signdetail") + "</B><br>";
        body += "<P>◎請至國內案爭救案交辦專案室抽件作業重新提出申請<br>";
        Subject += "國內案爭救交辦抽件簽核－退回通知";

        Sys.DoSendMail(Subject, body, strFrom, strTo, strCC, strBCC);
    }
    
    //信件內容
    private string dobody(ref string fseq) {
        string tbody = "";
        for (int i = 1; i <= Convert.ToInt32("0" + row); i++) {
            if (Request["C_" + i] == "Y") {
                string in_scode = "", in_scode_name = "", cust_area = "", cust_seq = "", cust_name = "", appl_name = "", arcase_name = "", last_date = "";
                SQL = "select Bseq,Bseq1,in_scode,scode_name,cust_area,cust_seq";
                SQL += " ,appl_name,arcase_name,Last_date from vbr_opt where branch='" + Session["seBranch"] + "' and case_no='" + Request["case_no_" + i] + "'";
                fseq = "";
                using (SqlDataReader dr = connopt.ExecuteReader(SQL)) {
                    if (dr.Read()) {
                        fseq = Sys.formatSeq(dr.SafeRead("bseq", ""), dr.SafeRead("bseq1", ""), "", Sys.GetSession("seBranch"), Sys.GetSession("dept"));
                        in_scode = dr.SafeRead("in_scode", "");
                        in_scode_name = dr.SafeRead("scode_name", "");
                        cust_area = dr.SafeRead("cust_area", "");
                        cust_seq = dr.SafeRead("cust_seq", "");
                        appl_name = dr.SafeRead("appl_name", "");
                        arcase_name = dr.SafeRead("arcase_name", "");
                        last_date = dr.GetDateTimeString("last_date", "yyyy/M/d");

                        SQL = "Select RTRIM(ISNULL(ap_cname1, '')) + RTRIM(ISNULL(ap_cname2, ''))  as cust_name from apcust as c ";
                        SQL += " where c.cust_area='" + cust_area + "' and c.cust_seq='" + cust_seq + "'";
                        objResult = conn.ExecuteScalar(SQL);
                        cust_name = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();
                    }
                }
                tbody += "【案件編號】 : <B>" + fseq + "</B><br>";
                tbody += "【營洽】 : <B>" + in_scode + "-" + in_scode_name + "</B><br>";
                tbody += "【客戶名稱】 : <B>" + cust_name + "</B><br>";
                tbody += "【案件名稱】 : <B>" + appl_name + "</B><br>";
                tbody += "【案性】 : <B>" + arcase_name + "</B><br>";
                tbody += "【法定期限】 : <font color=red><B>" + last_date + "</font></B><br><br>";
            }
        }

        return tbody;
    }
</script>

<%Response.Write(strOut.ToString());%>
