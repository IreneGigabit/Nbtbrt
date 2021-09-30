<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>

<script runat="server">
    protected string HTProgCap = "國內案結案案件處理作業-入檔";//HttpContext.Current.Request["prgname"];//功能名稱
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

    protected string logReason = "Brta74結案處理作業";
    string[] arr_chkflag, arr_ctrl_sqlno, arr_todo_sqlno, arr_branch, arr_seq, arr_seq1, arr_ctrlcnt, arr_anncnt, arr_oend_date, arr_end_type, arr_end_remark;
    
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
        arr_chkflag=Request["rows_chkflag"].Split('\f');
	    arr_ctrl_sqlno=ReqVal.TryGet("rows_ctrl_sqlno").Split('\f');
	    arr_todo_sqlno=ReqVal.TryGet("rows_todo_sqlno").Split('\f');
	    arr_branch=ReqVal.TryGet("rows_branch").Split('\f');
	    arr_seq=ReqVal.TryGet("rows_seq").Split('\f');
	    arr_seq1=ReqVal.TryGet("rows_seq1").Split('\f');
	    arr_ctrlcnt=ReqVal.TryGet("rows_ctrlcnt").Split('\f');
	    arr_anncnt=ReqVal.TryGet("rows_anncnt").Split('\f');
	    arr_oend_date=ReqVal.TryGet("rows_oend_date").Split('\f');
	    arr_end_type=ReqVal.TryGet("rows_end_type").Split('\f');
	    arr_end_remark=ReqVal.TryGet("rows_end_remark").Split('\f');
        
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
                            throw new Exception(Session["seBranch"] + "T" + tmp_seq + "-" + tmp_seq1 + "程序結案處理失敗(狀態已異動，請重新整理畫面)");
                        } else {
                            Update_dmt(i);
                            update_ctrl_dmt(i);
                            insert_todo_dmt(i);
                        }
                    }
                }
                
                strOut.AppendLine("<div align='center'><h1>國內案結案案件處理成功</h1></div>");
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
    /// 更新案件主檔
    /// </summary>
    private void Update_dmt(int pno) {
        string tmp_seq = arr_seq[pno];
        string tmp_seq1 = arr_seq1[pno];
        string tmp_end_type = arr_end_type[pno];
        string tmp_end_remark = arr_end_remark[pno];

        //新增案件主檔Log檔
        Sys.insert_log_table(conn, "U", HTProgCode, "dmt", "seq;seq1", tmp_seq + ";" + tmp_seq1, logReason);

        //更新案件主檔結案原因
        SQL = "update dmt set end_type = " + Util.dbchar(tmp_end_type) + " ";
        SQL += " ,end_remark = " + Util.dbchar(tmp_end_remark) + " ";
        SQL += " where seq = '" + tmp_seq + "' and seq1='" + tmp_seq1 + "'";
        conn.ExecuteNonQuery(SQL);
    }

    /// <summary>
    /// 銷管暨管制期限
    /// </summary>
    private void update_ctrl_dmt(int pno) {
        string tctrl_sqlno = arr_ctrl_sqlno[pno];

        //抓取ctrl_dmt入resp_dmt
        SQL = "insert into resp_dmt(sqlno,rs_no,branch,seq,seq1,step_grade,resp_grade,ctrl_type,ctrl_remark,ctrl_date,resp_date,resp_type,resp_remark,tran_date,tran_scode) ";
        SQL += "select sqlno,rs_no,branch,seq,seq1,step_grade,0,ctrl_type,ctrl_remark,ctrl_date,'" + DateTime.Today.ToShortDateString() + "','','已送會計確認',getdate(),'" + Session["scode"] + "' ";
        SQL += "from ctrl_dmt where sqlno =" + tctrl_sqlno;
        conn.ExecuteNonQuery(SQL);

        //管制3個月程序完成結案確認
        string ctrl_date = DateTime.Today.AddMonths(3).ToShortDateString();
        SQL = "insert into ctrl_dmt(rs_no,branch,seq,seq1,step_grade,ctrl_type,ctrl_remark,ctrl_date,tran_date,tran_scode) ";
        SQL += "select rs_no,branch,seq,seq1,step_grade,'B61','程序確認結案暨掃描完成期限','" + ctrl_date + "',getdate(),'" + Session["scode"] + "'";
        SQL += " from ctrl_dmt where sqlno=" + tctrl_sqlno;
        conn.ExecuteNonQuery(SQL);

        //刪除結案期限	  
        SQL = "delete from ctrl_dmt where sqlno=" + tctrl_sqlno;
        conn.ExecuteNonQuery(SQL);
    }

    /// <summary>
    /// 新增會計結案確認流程todo_dmt
    /// </summary>
    private void insert_todo_dmt(int pno) {
        string tmp_sqlno = arr_todo_sqlno[pno];
        string tmp_seq = arr_seq[pno];
        string tmp_seq1 = arr_seq1[pno];

        //更新程序結案處理狀態
        SQL = "update todo_dmt set job_status = 'YY' ";
        SQL += " ,approve_scode = '" + Session["scode"] + "' ";
        SQL += " ,resp_date=getdate() ";
        SQL += " where sqlno = '" + tmp_sqlno + "'";
        conn.ExecuteNonQuery(SQL);

        //新增會計結案確認
        SQL = "select scode from sysctrl.dbo.scode_roles where branch='" + Session["SeBranch"] + "' and dept='T' and roles='account' and sort='01'";
        object objResult = cnn.ExecuteScalar(SQL);
        string job_scode = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();

        SQL = "insert into todo_dmt(pre_sqlno,syscode,apcode,from_flag,branch,seq,seq1,step_grade,in_team,case_in_scode,in_no,case_no,in_scode,in_date";
        SQL += ",dowhat,job_scode,job_team,job_status) ";
        SQL += "select sqlno,syscode,'" + prgid + "','END','" + Session["SeBranch"] + "'," + tmp_seq + ",'" + tmp_seq1 + "',";
        SQL += "step_grade,in_team,case_in_scode,in_no,case_no,'" + Session["scode"] + "',";
        SQL += "getdate(),'ACC_END','" + job_scode + "','','NN'";
        SQL += " from todo_dmt where sqlno=" + tmp_sqlno;
        conn.ExecuteNonQuery(SQL);
    }
</script>

<%Response.Write(strOut.ToString());%>
