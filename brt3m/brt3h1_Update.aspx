<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Linq"%>

<script runat="server">
    protected string HTProgCap = "主管確認轉案(轉入)-入檔";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "brt3h1";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";

    protected string submitTask = "";
    protected string SQL = "";
    protected object objResult = null;

    protected string logReason = "";
    protected string row = "";
    protected string status = "";

    protected string msg = "";
    protected string qs_dept = "", todo_tblnm = "", tran_tblnm = "", todo_fldnm="",dept_nm = "", msgdept = "";
    protected string dowhat = "";

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

        conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");

        row = (Request["row"] ?? "").Trim();
        status = (Request["status"] ?? "").Trim();

        qs_dept = (Request["qs_dept"] ?? "").ToLower();
        if (qs_dept == "t") {
            todo_tblnm = "todo_dmt";
            tran_tblnm = "dmt_brtran";
            todo_fldnm = "temp_rs_sqlno";
            dept_nm = "T";
            msgdept = "國內案";
            logReason = "Brt3h國內案確認轉案簽核";
        } else {
            todo_tblnm = "todo_ext";
            tran_tblnm = "ext_brtran";
            todo_fldnm = "att_no";
            dept_nm = "TE";
            msgdept = "出口案";
            logReason = "Ext3h出口案確認轉案簽核";
        }

        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        HTProgCap = myToken.Title;
        DebugStr = myToken.DebugStr;
        if (HTProgRight >= 0) {
            try {
                if (status == "YY") {
                    dowhat = "TRAN_ED";//程序轉案發文確認
                } else if (status == "YT") {
                    dowhat = "TRAN_EM";
                }

                for (int i = 1; i <= Convert.ToInt32("0" + row); i++) {
                    if (Request["C_" + i] == "Y") {
                        string tmp_sqlno = ReqVal.TryGet("todo_sqlno_" + i);
                        string tmp_seq = ReqVal.TryGet("seq_" + i);
                        string tmp_seq1 = ReqVal.TryGet("seq1_" + i);

                        //判斷狀態是否已異動,防止開雙視窗
                        SQL = "select count(*) from " + todo_tblnm + " where sqlno='" + tmp_sqlno + "' and job_status ='NN'";
                        object objResult = conn.ExecuteScalar(SQL);
                        int cnt = (objResult == DBNull.Value || objResult == null) ? 0 : Convert.ToInt32(objResult);
                        if (cnt == 0) {
                            throw new Exception(Session["seBranch"] + "T" + tmp_seq + "-" + tmp_seq1 + "確認轉案簽核處理失敗(狀態已異動，請重新整理畫面)");
                        } else {
                            insert_todo_dmt(i);
                        }
                    }
                }

                strOut.AppendLine("<div align='center'><h1>" + msgdept + "確認轉案簽核成功</h1></div>");
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
    /// 送主管簽核
    /// </summary>
    private void insert_todo_dmt(int pno) {
        string tmp_sqlno = ReqVal.TryGet("todo_sqlno_" + pno);
        string tmp_brtran_sqlno = ReqVal.TryGet("brtran_sqlno_" + pno);
        string tmp_seq = ReqVal.TryGet("seq_" + pno);
        string tmp_seq1 = ReqVal.TryGet("seq1_" + pno);
        string tmp_scode = ReqVal.TryGet("tran_scode1_" + pno);
        string otmp_scode = ReqVal.TryGet("otran_scode1_" + pno);
        string fseq = Sys.formatSeq(tmp_seq, tmp_seq1, "", Sys.GetSession("seBranch"), dept_nm);

        //更新轉入單位營洽
        if (tmp_scode != otmp_scode) {
            Sys.insert_log_table(conn, "U", prgid, tran_tblnm, "brtran_sqlno", tmp_brtran_sqlno, logReason);

            SQL = "update " + tran_tblnm + " set tran_scode1='" + tmp_scode + "' ";
            SQL += ",tran_date=getdate(),tran_scode='" + Session["scode"] + "' ";
            SQL += " where brtran_sqlno=" + tmp_brtran_sqlno;
            conn.ExecuteNonQuery(SQL);
        }

        //更新主管簽核處理狀態
        SQL = "update " + todo_tblnm + " set job_status = '" + status + "' ";
        SQL += " ,approve_scode = '" + Session["scode"] + "' ";
        SQL += " ,approve_desc = " + Util.dbchar(ReqVal.TryGet("signdetail"));
        SQL += " ,resp_date=getdate() ";
        SQL += " where sqlno = " + tmp_sqlno;
        conn.ExecuteNonQuery(SQL);

        //新增流程主管簽核YT,程序轉案確認YY
        string job_team = Sys.getCodeName(conn, "sysctrl.dbo.scode_group", "grpid", "where grpclass='" + Session["seBranch"] + "' and scode='" + Request["signidnext"] + "'");
        SQL = "insert into " + todo_tblnm + "(pre_sqlno,syscode,apcode," + todo_fldnm + ",from_flag,branch,case_in_scode,in_scode,in_date";
        SQL += ",dowhat,job_scode,job_team,job_status) ";
        SQL += "select sqlno,syscode,'" + prgid + "'," + todo_fldnm + ",'TRAN','" + Session["SeBranch"] + "'";
        SQL += ",'" + tmp_scode + "','" + Session["scode"] + "'";
        SQL += ",getdate(),'" + dowhat + "','" + Request["signidnext"] + "','" + job_team + "','NN'";
        SQL += " from " + todo_tblnm + " where sqlno=" + tmp_sqlno;
        conn.ExecuteNonQuery(SQL);
    }
</script>

<%Response.Write(strOut.ToString());%>
