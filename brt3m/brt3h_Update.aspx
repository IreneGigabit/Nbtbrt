<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Linq"%>

<script runat="server">
    protected string HTProgCap = "確認轉案作業(轉入部門主管指定營洽新營洽)-入檔";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "brt3h";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";

    protected string SQL = "";
    protected object objResult = null;

    protected string logReason = "";
    string[] arr_chkflag, arr_brtran_sqlno, arr_todo_sqlno, arr_branch, arr_seq, arr_seq1, arr_appl_name, arr_scode, arr_cust_seq, arr_cust_seq1, arr_cust_name, arr_tran_seq_branch, arr_tran_remark;
    protected string qs_dept = "", tran_tblnm = "", todo_tblnm = "", todo_fldnm="", dept_nm = "", msgdept = "";

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
        arr_chkflag = ReqVal.TryGet("rows_chkflag").Split('\f');
        arr_brtran_sqlno = ReqVal.TryGet("rows_brtran_sqlno").Split('\f');
        arr_todo_sqlno = ReqVal.TryGet("rows_todo_sqlno").Split('\f');
        arr_branch = ReqVal.TryGet("rows_branch").Split('\f');
        arr_seq = ReqVal.TryGet("rows_seq").Split('\f');
        arr_seq1 = ReqVal.TryGet("rows_seq1").Split('\f');
        arr_appl_name = ReqVal.TryGet("rows_appl_name").Split('\f');
        arr_scode = ReqVal.TryGet("rows_scode").Split('\f');
        arr_cust_seq = ReqVal.TryGet("rows_cust_seq").Split('\f');
        arr_cust_seq1 = ReqVal.TryGet("rows_cust_seq1").Split('\f');
        arr_cust_name = ReqVal.TryGet("rows_cust_name").Split('\f');
        arr_tran_seq_branch = ReqVal.TryGet("rows_tran_seq_branch").Split('\f');
        arr_tran_remark = ReqVal.TryGet("rows_tran_remark").Split('\f');

        qs_dept = (Request["qs_dept"] ?? "").ToLower();
        if (qs_dept == "t") {
            tran_tblnm = "dmt_brtran";
            todo_tblnm = "todo_dmt";
            todo_fldnm = "temp_rs_sqlno";
            dept_nm = "T";
            msgdept = "國內案";
            logReason = "Brt3h國內案確認轉案作業";
        } else if (qs_dept == "e") {
            tran_tblnm = "ext_brtran";
            todo_tblnm = "todo_ext";
            todo_fldnm = "att_no";
            dept_nm = "TE";
            msgdept = "出口案";
            logReason = "Ext3h出口案確認轉案作業";
        }

        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        HTProgCap = myToken.Title;
        DebugStr = myToken.DebugStr;
        if (HTProgRight >= 0) {
            try {
                conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");

                for (int i = 1; i < arr_chkflag.Length; i++) {
                    if (arr_chkflag[i] == "Y") {//有打勾
                        string tmp_sqlno = arr_todo_sqlno[i];
                        string tmp_seq = arr_seq[i];
                        string tmp_seq1 = arr_seq1[i];

                        //判斷狀態是否已異動,防止開雙視窗
                        SQL = "select count(*) from " + todo_tblnm + " where sqlno='" + tmp_sqlno + "' and job_status ='NN'";
                        object objResult = conn.ExecuteScalar(SQL);
                        int cnt = (objResult == DBNull.Value || objResult == null) ? 0 : Convert.ToInt32(objResult);
                        if (cnt == 0) {
                            throw new Exception(Session["seBranch"] + "T" + tmp_seq + "-" + tmp_seq1 + "程序轉案發文處理失敗(狀態已異動，請重新整理畫面)");
                        } else {
                            insert_todo_dmt(i);
                        }
                    }
                }

                strOut.AppendLine("<div align='center'><h1>" + msgdept + "主管確認轉案成功</h1></div>");
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

    /// <summary>
    /// 新增主管簽核流程todo_dmt
    /// </summary>
    private void insert_todo_dmt(int pno) {
        string tmp_sqlno = arr_todo_sqlno[pno];
        string tmp_branch = arr_branch[pno];
        string tmp_seq = arr_seq[pno];
        string tmp_seq1 = arr_seq1[pno];
        string tmp_brtran_sqlno = arr_brtran_sqlno[pno];

        //更新轉案記錄之新單位營洽
        Sys.insert_log_table(conn, "U", prgid, tran_tblnm, "brtran_sqlno", tmp_brtran_sqlno, logReason);

        SQL = "update " + tran_tblnm + " set tran_scode1='" + Request["tran_scode1"] + "'";
        SQL += ",tran_date=getdate(),tran_scode='" + Session["scode"] + "'";
        SQL += " where brtran_sqlno=" + tmp_brtran_sqlno;
        conn.ExecuteNonQuery(SQL);

        //更新主管簽核處理狀態
        SQL = "update " + todo_tblnm + " set job_status = 'YT' ";
        SQL += " ,approve_scode = '" + Session["scode"] + "' ";
        SQL += " ,resp_date=getdate() ";
        SQL += " where sqlno = " + tmp_sqlno;
        conn.ExecuteNonQuery(SQL);

        //新增流程主管簽核YT
        string job_team = Sys.getCodeName(conn, "sysctrl.dbo.scode_group", "grpid", "where grpclass='" + Session["seBranch"] + "' and scode='" + Request["signid"] + "'");
        SQL = "insert into " + todo_tblnm + "(pre_sqlno,syscode,apcode," + todo_fldnm + ",from_flag,branch,case_in_scode,in_scode,in_date";
        SQL += ",dowhat,job_scode,job_team,job_status) ";
        SQL += "select sqlno,syscode,'" + prgid + "'," + todo_fldnm + ",'TRAN','" + Session["seBranch"] + "'";
        SQL += ",'" + Request["tran_scode1"] + "','" + Session["scode"] + "'";
        SQL += ",getdate(),'TRAN_EM','" + Request["signid"] + "','" + job_team + "','NN'";
        SQL += " from " + todo_tblnm + " where sqlno=" + tmp_sqlno;
        conn.ExecuteNonQuery(SQL);
    }
</script>

<%Response.Write(strOut.ToString());%>
