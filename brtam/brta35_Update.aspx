<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>

<script runat="server">
    protected string HTProgCap = "客戶函寄出登錄確認入檔";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "brta35";//程式檔名前綴
    protected string HTProgCode = "brta35";//HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";

    protected string submitTask = "";
    protected string SQL = "";
    protected object objResult = null;
    protected string logReason = "";
        
    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected Dictionary<string, string> ColMap = new Dictionary<string, string>();

    string[] arr_chk, arr_rs_no, arr_seq, arr_seq1;
    
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
        conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");

        arr_chk = Request["rows_chk"].Split('\f');
        arr_rs_no = Request["rows_rs_no"].Split('\f');
        arr_seq = Request["rows_seq"].Split('\f');
        arr_seq1 = Request["rows_seq1"].Split('\f');

        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        HTProgCap = myToken.Title;
        DebugStr = myToken.DebugStr;
        if (HTProgRight >= 0) {
            try {
                doConfirm();
                strOut.AppendLine("<div align='center'><h1>客戶函寄發登錄確認成功!!!</h1></div>");

                conn.Commit();
                //conn.RollBack();
            }
            catch (Exception ex) {
                conn.RollBack();
                Sys.errorLog(ex, conn.exeSQL, prgid);
                throw;
            }
            this.DataBind();
        }
    }

    //客戶函寄發登錄確認
    private void doConfirm() {
        //新增attcase_dmt交辦發文檔
        for (int i = 1; i < arr_chk.Length; i++) {
            if (arr_chk[i] == "Y") {//有打勾
                Sys.showLog("<font color=red>﹝" + i + "﹞</font>seq=" + arr_seq[i] + "-" + arr_seq1[i]);
                string trs_no = arr_rs_no[i];
                string tseq = arr_seq[i];
                string tseq1 = arr_seq1[i];

                //判斷狀態是否已異動,防止開雙視窗
                SQL = "select count(*) from cs_dmt where rs_no='" + trs_no + "' and mail_date is null";
                object objResult = conn.ExecuteScalar(SQL);
                int cnt = (objResult == DBNull.Value || objResult == null) ? 0 : Convert.ToInt32(objResult);
                if (cnt == 0) {
                    throw new Exception("<div align='center'><h1>案件狀態有誤或已確認(" + tseq + "-" + tseq1 + ")，請重新查詢！</h1></div>");
                } else {
                    //客發紀錄檔之寄出日期更新
                    SQL = "update cs_dmt set mail_date=" + Util.dbnull(Request["mail_date"]);
                    SQL += ",mail_scode='" + Session["scode"] + "'";
                    SQL += ",mwork_date=getdate() ";
                    SQL += " where rs_no='" + trs_no + "'";
                    conn.ExecuteNonQuery(SQL);
                }
            }
        }
    }
</script>

<%Response.Write(strOut.ToString());%>
