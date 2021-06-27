<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Collections.Generic"%>

<script runat="server">
    protected string HTProgCap = "總收發文案件主檔申請號資料複製";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = HttpContext.Current.Request["prgid"] ?? "";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";

    protected string SQL = "";
    protected object objResult = null;
    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected string logReason = "";

    protected string qBranch = "";
    protected string qSeq = "";
    protected string qSeq1 = "";
    protected string temp_rs_sqlno = "";
    
    protected StringBuilder strOut = new StringBuilder();

    DBHelper conn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    DBHelper connm = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    private void Page_Unload(System.Object sender, System.EventArgs e) {
        if (conn != null) conn.Dispose();
        if (connm != null) connm.Dispose();
    }

    protected void Page_Load(object sender, EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        logReason = prgid + "總收發文官方收文資料複製";

        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");

        conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
        connm = new DBHelper(Conn.MG).Debug(Request["chkTest"] == "TEST");

        qBranch = (Request["qBranch"] ?? "").Trim();
        qSeq = (Request["qSeq"] ?? "").Trim();
        qSeq1 = (Request["qSeq1"] ?? "").Trim();
        temp_rs_sqlno = (Request["temp_rs_sqlno"] ?? "").Trim();

        try {
            //入總收發文案件主檔資料至step_mgt_temp
            SQL = "select apply_date,apply_no from mgt ";
            SQL += "where seq_area='" + qBranch + "' and seq='" + qSeq + "' and seq1='" + qSeq1 + "'";
            using (SqlDataReader dr = connm.ExecuteReader(SQL)) {
                if (dr.Read()) {
                    string apply_date = dr.GetDateTimeString("apply_date", "yyyy/M/d");
                    string apply_no = dr.SafeRead("apply_no", "");

                    //入mgt_temp_log
                    Sys.insert_log_table(conn, "U", prgid, "step_mgt_temp", "temp_rs_sqlno", temp_rs_sqlno, logReason);
                    SQL = "update step_mgt_temp set apply_date=" + Util.dbchar(apply_date);
                    SQL += ",apply_no=" + Util.dbchar(apply_no);
                    SQL += " where temp_rs_sqlno=" + temp_rs_sqlno;
                    conn.ExecuteNonQuery(SQL);
                }
            }
            
            conn.Commit();
            //conn.RollBack();
            strOut.AppendLine("alert('總收發案件資料抓取成功！');");
            strOut.AppendLine("goSearch();");
        }
        catch (Exception ex) {
            conn.RollBack();
            Sys.errorLog(ex, conn.exeSQL, prgid);
            strOut.AppendLine("alert('總收發案件資料抓取失敗！！');");
            //throw;
        }
    }
</script>

<%=strOut.ToString()%>
