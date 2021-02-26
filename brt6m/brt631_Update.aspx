<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>

<script runat="server">
    protected string HTProgCap = "承辦不發文註記取消確認入檔";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "brt631";//程式檔名前綴
    protected string HTProgCode = "brt631";//HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";

    protected string submitTask = "";
    protected string SQL = "";
    protected object objResult = null;

    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected Dictionary<string, string> ColMap = new Dictionary<string, string>();

    string[] arr_chkflag, arr_att_sqlno, arr_todo_sqlno, arr_seq, arr_seq1, arr_in_scode, arr_in_no;

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
        arr_chkflag=Request["rows_chkflag"].Split('\f');
        arr_att_sqlno=Request["rows_att_sqlno"].Split('\f');
        arr_todo_sqlno=Request["rows_todo_sqlno"].Split('\f');
        arr_seq=Request["rows_seq"].Split('\f');
        arr_seq1=Request["rows_seq1"].Split('\f');
        arr_in_scode=Request["rows_in_scode"].Split('\f');
        arr_in_no = Request["rows_in_no"].Split('\f');

        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        HTProgCap = myToken.Title;
        DebugStr = myToken.DebugStr;
        if (HTProgRight >= 0) {
            try {
                conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
                
                doUpdateDB();
                strOut.AppendLine("<div align='center'><h1>國內案不發文註記取消成功</h1></div>");
                //conn.Commit();
                conn.RollBack();
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
        for (int i = 1; i < arr_chkflag.Length; i++) {
            if (arr_chkflag[i] == "Y") {//有打勾
                string tmp_sqlno = arr_todo_sqlno[i];
                string tmp_att_sqlno = arr_att_sqlno[i];
                string tmp_seq = arr_seq[i];
                string tmp_seq1 = arr_seq1[i];
                string tmp_scode = arr_in_scode[i];
                string tmp_in_no = arr_in_no[i];

                //判斷狀態是否已異動,防止開雙視窗
                SQL = "select count(*) from attcase_dmt where att_sqlno='" + tmp_att_sqlno + "' and sign_stat='SX'";
                object objResult = conn.ExecuteScalar(SQL);
                int cnt = (objResult == DBNull.Value || objResult == null) ? 0 : Convert.ToInt32(objResult);
                if (cnt == 0) {
                    throw new Exception("新增接洽序號" + tmp_in_no + "承辦交辦發文狀態失敗");
                } else {
                    //修改交辦發文註記
                    SQL = "update attcase_dmt set sign_stat='XX' where att_sqlno=" + tmp_att_sqlno;
                    conn.ExecuteNonQuery(SQL);

                    //新增承辦交辦發文todo
                    SQL = "insert into todo_dmt(pre_sqlno,syscode,apcode,from_flag,branch,seq,seq1,step_grade,case_in_scode,in_no,case_no,in_scode,in_date";
                    SQL += ",dowhat,job_scode,job_team,job_status) ";
                    SQL += "select sqlno,syscode,'" + prgid + "','CGRS','" + Session["seBranch"] + "'," + tmp_seq + ",'" + tmp_seq1 + "',";
                    SQL += "step_grade,'" + tmp_scode + "','" + tmp_in_no + "',case_no,'" + Session["scode"] + "',";
                    SQL += "getdate(),'DP_GS',job_scode,job_team,'NN'";
                    SQL += " from todo_dmt where sqlno=" + tmp_sqlno;
                    conn.ExecuteNonQuery(SQL);
                }
            }
        }
    }
</script>

<%Response.Write(strOut.ToString());%>
