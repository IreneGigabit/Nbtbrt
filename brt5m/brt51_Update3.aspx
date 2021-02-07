<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>

<script runat="server">
    protected string HTProgCap = "程序確認作業-退回營洽";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "brt51";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";

    protected string submitTask = "";
    protected string SQL = "";

    protected string in_scode = "";
    protected string in_no = "";
    
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

        in_scode = (Request["in_scode"] ?? "").Trim();
        in_no = (Request["in_no"] ?? "").Trim();

        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        HTProgCap = myToken.Title;
        DebugStr = myToken.DebugStr;
        if (HTProgRight >= 0) {
            try {
                conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
                doUpdateDB();
            }
            catch (Exception ex) {
                conn.RollBack();
                Sys.errorLog(ex, conn.exeSQL, prgid);
                //strOut.AppendLine("<div align='center'><h1>修改交辦案件狀態失敗("+ex.Message+")</h1></div>");
                throw;
            }

            this.DataBind();
        }
    }

    private void doUpdateDB() {
        //判斷狀態是否已異動,防止開雙視窗
        SQL = "select count(*) from case_dmt where in_scode='" + in_scode + "' and in_no='" + in_no + "' and stat_code='YY'";
        object objResult = conn.ExecuteScalar(SQL);
        int cnt = (objResult == DBNull.Value || objResult == null) ? 0 : Convert.ToInt32(objResult);
        if (cnt == 0) {
            conn.RollBack();
            strOut.AppendLine("<div align='center'><h1>交辦案件狀態有誤，請重新查詢！<br>(案件狀態已異動)</h1></div>");
        } else {
            //修改case_dmt狀態
            SQL = "UPDATE case_dmt SET Stat_code = 'NX' ";
            SQL += " WHERE in_scode='" + in_scode + "' and in_no='" + in_no + "'";
            conn.ExecuteNonQuery(SQL);

            //修改todolist狀態
            SQL = "update todo_dmt set ";
            ColMap.Clear();
            ColMap["job_status"] = Util.dbchar("NX");
            ColMap["approve_scode"] = "'" + Session["scode"] + "'";
            ColMap["resp_date"] = "getdate()";
            ColMap["approve_desc"] = Util.dbchar(ReqVal.TryGet("back_remark"));
            SQL += ColMap.GetUpdateSQL();
            SQL += " where case_in_scode='" + in_scode + "' and in_no='" + in_no + "' and apcode in('Si04W02','brt31')";
            SQL += " and dowhat='DC' and job_status='NN' and approve_scode is null";
            conn.ExecuteNonQuery(SQL);
            
            //conn.Commit();
            conn.RollBack();
            
            strOut.AppendLine("<div align='center'><h1>資料更新成功</h1></div>");
        }
    }
</script>

<%Response.Write(strOut.ToString());%>
