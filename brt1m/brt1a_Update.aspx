<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Linq" %>

<script runat="server">
    protected string HTProgCap = "爭救案交辦專案室抽件作業";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "brt1a";//HttpContext.Current.Request["prgid"] ?? "";//程式檔名前綴
    protected string HTProgCode = "brt1a";//HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";

    protected string SQL = "";
    protected object objResult = null;
    
    protected string submitTask = "";

    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected Dictionary<string, string> ColMap = new Dictionary<string, string>();

    protected StringBuilder strOut = new StringBuilder();

    protected string Bdb = "";

    DBHelper conn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    DBHelper optconn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    private void Page_Unload(System.Object sender, System.EventArgs e) {
        if (conn != null) conn.Dispose();
        if (optconn != null) optconn.Dispose();
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
            try {
                conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
                optconn = new DBHelper(Conn.optK).Debug(Request["chkTest"] == "TEST");

                doUpdateDB();
                
                conn.Commit();
                optconn.Commit();

                strOut.AppendLine("<div align='center'><h1>爭救案抽件申請成功!!</h1></div>");
            }
            catch (Exception ex) {
                conn.RollBack();
                optconn.RollBack();
                Sys.errorLog(ex, conn.exeSQL, prgid);
                //strOut.AppendLine("<div align='center'><h1>爭救案抽件申請失敗("+ex.Message+")</h1></div>");
                throw;
            }

            this.DataBind();
        }
    }

    private void doUpdateDB() {
        string tprgid = ReqVal.TryGet("brt18_prgid");
        string opt_sqlno = ReqVal.TryGet("opt_sqlno");
        string seq = Request["brt18_seq"];
        string seq1 = Request["brt18_seq1"];
        string case_no = ReqVal.TryGet("case_no");
        string ap_type = ReqVal.TryGet("ap_type");
        string creason = ReqVal.TryGet("creason");
        string Job_Scode = "";

        if (ap_type == "1") {
            Job_Scode = ReqVal.TryGet("job_scode1");
        } else if (ap_type == "2") {
            Job_Scode = ReqVal.TryGet("job_scode2");
        }

        //新增註銷記錄檔
        SQL = "insert into cancel_opt(input_scode,input_date,opt_sqlno,branch,seq,seq1,cap_scode,creason,tran_status,tran_date) values (";
        SQL += "'" + Session["scode"] + "','" + DateTime.Today.ToShortDateString() + "','" + opt_sqlno + "','" + Session["seBranch"] + "'," + seq + ",'" + seq1 + "'";
        SQL += ",'" + Job_Scode + "'," + Util.dbchar(creason) + ",'DT',getdate())";
        optconn.ExecuteNonQuery(SQL);

        //入流程控制檔
        SQL = " insert into todo_opt(syscode,apcode,opt_sqlno,branch,case_no,in_scode,in_date";
        SQL += ",dowhat,job_scode,job_status) values (";
        SQL += "'" + Session["syscode"] + "','" + tprgid + "'," + opt_sqlno + ",'" + Session["seBranch"] + "','" + case_no + "'";
        SQL += ",'" + Session["scode"] + "',getdate(),'DT','" + Job_Scode + "','NN')";
        optconn.ExecuteNonQuery(SQL);
        
        //發mail通知
        CreateMail(case_no,Job_Scode);
    }

    private void CreateMail(string case_no, string Job_Scode) {
        string fseq = "", in_scode = "", in_scode_name = "", cust_area = "", cust_seq = "", cust_name = "", appl_name = "", arcase_name = "", last_date = "";
        SQL = "select Bseq,Bseq1,in_scode,scode_name,cust_area,cust_seq";
        SQL += " ,appl_name,arcase_name,Last_date from vbr_opt where branch='" + Session["seBranch"] + "' and case_no='" + case_no + "'";
        using (SqlDataReader dr = optconn.ExecuteReader(SQL)) {
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

        string Subject = "商標網路作業系統－國內爭救案交辦專案室抽件通知（區所編號：" + fseq + "）";
        string strFrom = Session["scode"] + "@saint-island.com.tw";
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
                break;
            default:
                strTo.Add(Job_Scode + "@saint-island.com.tw");
                break;
        }

        string body = "【案件編號】 : <B>" + fseq + "</B><br>";
        body += "【營洽】 : <B>" + in_scode + "-" + in_scode_name + "</B><br>";
        body += "【客戶名稱】 : <B>" + cust_name + "</B><br>";
        body += "【案件名稱】 : <B>" + appl_name + "</B><br>";
        body += "【案性】 : <B>" + arcase_name + "</B><br>";
        body += "【法定期限】 : <font color=red><B>" + last_date + "</font></B><br>";
        body += "◎請連至下列網址簽核: <br><a href=\"http://" + Sys.Host + "/nbtbrt/maillogin.aspx?prgid=brt34&mail=mail&scode=" + Job_Scode + "&syscode=" + Session["seBranch"] + "tbrt\">【請登錄】</a>";

        Sys.DoSendMail(Subject, body, strFrom, strTo, strCC, strBCC);
    }
</script>

<%Response.Write(strOut.ToString());%>
