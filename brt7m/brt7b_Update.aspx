<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>

<script runat="server">
    protected string HTProgCap = "國內案結案案件會計確認作業-入檔";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = HttpContext.Current.Request["prgid"] ?? "";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";

    protected string submitTask = "";
    protected string SQL = "";
    protected object objResult = null;

    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected Dictionary<string, string> ColMap = new Dictionary<string, string>();

    protected string logReason = "Brt7b國內案結案會計確認作業";
    string[] arr_chkflag, arr_ctrl_sqlno, arr_todo_sqlno, arr_branch, arr_seq, arr_seq1, arr_scode, arr_job_scode;
    protected string todo = "";
    
    protected StringBuilder strOut = new StringBuilder();

    DBHelper conn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    DBHelper cnn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    private void Page_Unload(System.Object sender, System.EventArgs e) {
        if (conn != null) conn.Dispose();
        if (cnn != null) conn.Dispose();
    }

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");
        todo = ReqVal.TryGet("todo");
        arr_chkflag = Request["rows_chkflag"].Split('\f');
        arr_ctrl_sqlno = ReqVal.TryGet("rows_ctrl_sqlno").Split('\f');
        arr_todo_sqlno = ReqVal.TryGet("rows_todo_sqlno").Split('\f');
        arr_branch = ReqVal.TryGet("rows_branch").Split('\f');
        arr_seq = ReqVal.TryGet("rows_seq").Split('\f');
        arr_seq1 = ReqVal.TryGet("rows_seq1").Split('\f');
        arr_scode = ReqVal.TryGet("rows_scode").Split('\f');
        arr_job_scode = ReqVal.TryGet("rows_job_scode").Split('\f');

        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        HTProgCap = myToken.Title;
        DebugStr = myToken.DebugStr;
        if (HTProgRight >= 0) {
            try {
                conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
                cnn = new DBHelper(Conn.Sysctrl).Debug(Request["chkTest"] == "TEST");

                for (int i = 1; i < arr_chkflag.Length; i++) {
                    if (arr_chkflag[i] == "Y") {//有打勾
                        string tmp_sqlno = arr_todo_sqlno[i];
                        string tmp_seq = arr_seq[i];
                        string tmp_seq1 = arr_seq1[i];

                        //判斷狀態是否已異動,防止開雙視窗
                        SQL = "select count(*) from todo_dmt where sqlno='" + tmp_sqlno + "' and job_status like 'N%'";
                        object objResult = conn.ExecuteScalar(SQL);
                        int cnt = (objResult == DBNull.Value || objResult == null) ? 0 : Convert.ToInt32(objResult);
                        if (cnt == 0) {
                            throw new Exception(Session["seBranch"] + "T" + tmp_seq + "-" + tmp_seq1 + "會計結案確認失敗(狀態已異動，請重新整理畫面)");
                        } else {
                            if (todo == "send") {//送主管簽核
                                insert_todo_dmt(i);
                            } else if (todo == "reject") {//退回程序
                                update_todo_dmt(i);
                            }
                        }
                    }
                }
                strOut.AppendLine("<div align='center'><h1>國內案結案會計確認成功</h1></div>");

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

    /// <summary>
    /// 新增主管簽核流程todo_dmt
    /// </summary>
    private void insert_todo_dmt(int pno) {
        string tmp_sqlno = arr_todo_sqlno[pno];
        string tmp_seq = arr_seq[pno];
        string tmp_seq1 = arr_seq1[pno];
        string tmp_scode = arr_scode[pno];
        string tmp_job_scode = arr_job_scode[pno];

        //更新會計結案處理狀態
        SQL = "update todo_dmt set job_status = 'YY' ";
        SQL += " ,approve_scode = '" + Session["scode"] + "' ";
        SQL += " ,resp_date=getdate() ";
        SQL += " where sqlno = '" + tmp_sqlno + "'";
        conn.ExecuteNonQuery(SQL);

        //新增主管簽核
        string job_team = Sys.getCodeName(conn, "sysctrl.dbo.scode_group", "grpid", "where grpclass='" + Session["seBranch"] + "' and scode='" + tmp_job_scode + "'");
        SQL = "insert into todo_dmt(pre_sqlno,syscode,apcode,from_flag,branch,seq,seq1,step_grade,case_in_scode,in_no,case_no,in_scode,in_date";
        SQL += ",dowhat,job_scode,job_team,job_status) ";
        SQL += "select sqlno,syscode,'" + prgid + "','END','" + Session["SeBranch"] + "'," + tmp_seq + ",'" + tmp_seq1 + "',";
        SQL += "step_grade,'"+tmp_scode+"',in_no,case_no,'" + Session["scode"] + "',";
        SQL += "getdate(),'DB_END','" + tmp_job_scode + "','"+job_team+"','NN'";
        SQL += " from todo_dmt where sqlno=" + tmp_sqlno;
        conn.ExecuteNonQuery(SQL);
    }
    
    /// <summary>
    /// 退回程序結案處理流程todo_dmt
    /// </summary>
    private void update_todo_dmt(int pno) {
        string tmp_sqlno = arr_todo_sqlno[pno];
        string tmp_seq = arr_seq[pno];
        string tmp_seq1 = arr_seq1[pno];
        string tmp_scode = arr_scode[pno];

        //更新會計結案處理狀態
        SQL = "update todo_dmt set job_status = 'NX' ";
        SQL += " ,approve_scode = '" + Session["scode"] + "' ";
        SQL += " ,approve_desc = '" + ReqVal.TryGet("reject_reason") + "' ";
        SQL += " ,resp_date=getdate() ";
        SQL += " where sqlno = '" + tmp_sqlno + "'";
        conn.ExecuteNonQuery(SQL);

        //新增退回程序處理
        string job_scode = Sys.getCodeName(conn, "sysctrl.dbo.scode_group", "scode", "where grpclass='" + Session["seBranch"] + "' and grpid='T210' and grptype='F' ");
        SQL = "insert into todo_dmt(pre_sqlno,syscode,apcode,from_flag,branch,seq,seq1,step_grade,case_in_scode,in_no,case_no,in_scode,in_date";
        SQL += ",dowhat,job_scode,job_team,job_status) ";
        SQL += "select sqlno,syscode,'" + prgid + "','END_ACC','" + Session["SeBranch"] + "'," + tmp_seq + ",'" + tmp_seq1 + "',";
        SQL += "step_grade,'" + tmp_scode + "',in_no,case_no,'" + Session["scode"] + "',";
        SQL += "getdate(),'DC_END1','" + job_scode + "','T210','NN'";
        SQL += " from todo_dmt where sqlno=" + tmp_sqlno;
        conn.ExecuteNonQuery(SQL);
    }
</script>

<%Response.Write(strOut.ToString());%>
