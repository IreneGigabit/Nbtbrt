<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>

<script runat="server">
    protected string HTProgCap = "營洽轉案處理-入檔";//HttpContext.Current.Request["prgname"];//功能名稱
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

    protected string logReason = "Brt1b營洽轉案處理修改轉案註記";
    string[] arr_chkflag, arr_seq,arr_seq1,arr_country,arr_scode,arr_cust_area,arr_cust_seq,arr_brtran_sqlno,arr_todo_sqlno;
            
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
        arr_chkflag = Request["rows_chkflag"].Split('\f');
        arr_seq = ReqVal.TryGet("rows_seq").Split('\f');
        arr_seq1 = ReqVal.TryGet("rows_seq1").Split('\f');
        arr_country = ReqVal.TryGet("rows_country").Split('\f');
        arr_scode = ReqVal.TryGet("rows_scode").Split('\f');
        arr_cust_area = ReqVal.TryGet("rows_cust_area").Split('\f');
        arr_cust_seq = ReqVal.TryGet("rows_cust_seq").Split('\f');
        arr_brtran_sqlno = ReqVal.TryGet("rows_brtran_sqlno").Split('\f');
        arr_todo_sqlno = ReqVal.TryGet("rows_todo_sqlno").Split('\f');

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
                        if (arr_country[i] == "") {//國內案
                            if (ReqVal.TryGet("qryjob_status") == "NX") {
                                //被退回來
                                SQL = "select count(*) from todo_dmt where sqlno='" + tmp_sqlno + "' and job_status like 'N%'";
                            } else {
                                //沒送簽過
                                SQL = "select count(*) from dmt where seq = " + tmp_seq + " and seq1='" + tmp_seq1 + "' and isnull(tran_flag,'') = ''";
                            }
                        } else {
                            if (ReqVal.TryGet("qryjob_status") == "NX") {
                                //被退回來
                                SQL = "select count(*) from todo_ext where sqlno='" + tmp_sqlno + "' and job_status like 'N%'";
                            } else {
                                //沒送簽過
                                SQL = "select count(*) from ext where seq = " + tmp_seq + " and seq1='" + tmp_seq1 + "' and isnull(tran_flag,'') = ''";
                            }
                        }
                        object objResult = conn.ExecuteScalar(SQL);
                        int cnt = (objResult == DBNull.Value || objResult == null) ? 0 : Convert.ToInt32(objResult);
                        if (cnt == 0) {
                            throw new Exception(Session["seBranch"] + "T" + tmp_seq + "-" + tmp_seq1 + "營洽轉案處理失敗(狀態已異動，請重新整理畫面)");
                        } else {
                            //送主管簽核
                            if (arr_country[i] == "") {
                                insert_todo_dmt(i);
                            } else {
                                insert_todo_ext(i);
                            }
                        }
                    }
                }

                strOut.AppendLine("<div align='center'><h1>營洽轉案處理成功</h1></div>");
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
    /// 新增主管簽核流程todo_dmt國內案
    /// </summary>
    private void insert_todo_dmt(int pno) {
        string tmp_seq = arr_seq[pno];
        string tmp_seq1 = arr_seq1[pno];
        string tmp_scode = arr_scode[pno];
        string tmp_cust_area = arr_cust_area[pno];
        string tmp_cust_seq = arr_cust_seq[pno];
        string tmp_brtran_sqlno = arr_brtran_sqlno[pno];
        string tmp_todo_sqlno = arr_todo_sqlno[pno];

        string brtran_sqlno = tmp_brtran_sqlno;//轉案案件記錄檔流水號
        //轉案案件記錄檔dmt_brtran
        if (tmp_brtran_sqlno == "0") {
            //新增轉案案件記錄檔dmt_brtran
            SQL = "insert into dmt_brtran(tran_flag,branch,seq,seq1,cust_area,cust_seq,tran_seq_branch,tran_remark,sc_date,sc_scode,tran_date,tran_scode) values (";
            SQL += "'A','" + Session["SeBranch"] + "'," + tmp_seq + ",'" + tmp_seq1 + "','" + tmp_cust_area + "'," + tmp_cust_seq + "," + Util.dbchar(ReqVal.TryGet("tran_seq_branch"));
            SQL += "," + Util.dbchar(ReqVal.TryGet("tran_remark")) + ",getdate(),'" + Session["scode"] + "',getdate(),'" + Session["scode"] + "')";
            conn.ExecuteNonQuery(SQL);

            //抓insert後的流水號
            SQL = "SELECT SCOPE_IDENTITY() AS Current_Identity";
            object objResult1 = conn.ExecuteScalar(SQL);
            brtran_sqlno = objResult1.ToString();
        } else {
            //修改轉案案件記錄檔dmt_brtran
            //入log
            Sys.insert_log_table(conn, "U", prgid, "dmt_brtran", "brtran_sqlno", tmp_brtran_sqlno, logReason);
            SQL = "update dmt_brtran set tran_seq_branch=" + Util.dbchar(ReqVal.TryGet("tran_seq_branch"));
            SQL += " ,tran_remark=" + Util.dbchar(ReqVal.TryGet("tran_remark"));
            SQL += " ,tran_date=getdate(),tran_scode='" + Session["scode"] + "'";
            SQL += " where brtran_sqlno=" + tmp_brtran_sqlno;
            conn.ExecuteNonQuery(SQL);
        }
        Sys.showLog("轉案記錄檔流水號=" + brtran_sqlno);

        //更新案件主檔轉案註記
        //入log
        Sys.insert_log_table(conn, "U", prgid, "dmt", "seq;seq1", tmp_seq + ";" + tmp_seq1, logReason);
        SQL = "update dmt set tran_flag = 'A' ";
        SQL += " ,tran_seq_branch =" + Util.dbchar(ReqVal.TryGet("tran_seq_branch"));
        SQL += " ,tran_remark=" + Util.dbchar(ReqVal.TryGet("tran_remark"));
        SQL += " ,tran_sc_date=getdate() ";
        SQL += " where seq = " + tmp_seq + " and seq1='" + tmp_seq1 + "'";
        conn.ExecuteNonQuery(SQL);

        //新增主管簽核
        string job_team = Sys.getCodeName(conn, "sysctrl.dbo.scode_group", "grpid", "where grpclass='" + Session["seBranch"] + "' and scode='" + Request["signid"] + "'");
        SQL = "insert into todo_dmt(pre_sqlno,syscode,apcode,temp_rs_sqlno,from_flag,branch,seq,seq1,case_in_scode,in_scode,in_date";
        SQL += ",dowhat,job_scode,job_team,job_status) values (";
        SQL += tmp_todo_sqlno + ",'" + Session["syscode"] + "','" + prgid + "'," + brtran_sqlno + ",'TRAN','" + Session["SeBranch"] + "'," + tmp_seq + ",'" + tmp_seq1 + "','" + tmp_scode + "',";
        SQL += "'" + Session["scode"] + "',getdate(),'TRAN_NM','" + Request["signid"] + "','" + job_team + "','NN')";
        conn.ExecuteNonQuery(SQL);

        //更新主管退回流程
        if (ReqVal.TryGet("qryjob_status") == "NX") {
            SQL = "update todo_dmt set job_status='YY',approve_scode='" + Session["scode"] + "',resp_date=getdate() ";
            SQL += " where sqlno=" + tmp_todo_sqlno;
            conn.ExecuteNonQuery(SQL);
        }

        //新增轉案記錄，更新營洽上傳文件檔，補入轉案流水號
        if (tmp_brtran_sqlno == "0") {
            SQL = "update dmt_attach set att_sqlno=" + brtran_sqlno;
            SQL += " where seq=" + tmp_seq + " and seq1='" + tmp_seq1 + "' and source='tran' and attach_flag<>'D'";
            conn.ExecuteNonQuery(SQL);
        }
    }

    /// <summary>
    /// 新增主管簽核流程todo_ext出口案
    /// </summary>
    private void insert_todo_ext(int pno) {
        string tmp_seq = arr_seq[pno];
        string tmp_seq1 = arr_seq1[pno];
        string tmp_scode = arr_scode[pno];
        string tmp_cust_area = arr_cust_area[pno];
        string tmp_cust_seq = arr_cust_seq[pno];
        string tmp_brtran_sqlno = arr_brtran_sqlno[pno];
        string tmp_todo_sqlno = arr_todo_sqlno[pno];

        string brtran_sqlno = tmp_brtran_sqlno;//轉案案件記錄檔流水號
        //轉案案件記錄檔dmt_brtran
        if (tmp_brtran_sqlno == "0") {
            //新增轉案案件記錄檔ext_brtran
            SQL = "insert into ext_brtran(tran_flag,branch,seq,seq1,cust_area,cust_seq,tran_seq_branch,tran_remark,sc_date,sc_scode,tran_date,tran_scode) values (";
            SQL += "'A','" + Session["SeBranch"] + "'," + tmp_seq + ",'" + tmp_seq1 + "','" + tmp_cust_area + "'," + tmp_cust_seq + "," + Util.dbchar(ReqVal.TryGet("tran_seq_branch"));
            SQL += "," + Util.dbchar(ReqVal.TryGet("tran_remark")) + ",getdate(),'" + Session["scode"] + "',getdate(),'" + Session["scode"] + "')";
            conn.ExecuteNonQuery(SQL);

            //抓insert後的流水號
            SQL = "SELECT SCOPE_IDENTITY() AS Current_Identity";
            object objResult1 = conn.ExecuteScalar(SQL);
            brtran_sqlno = objResult1.ToString();
        } else {
            //修改轉案案件記錄檔ext_brtran
            //入log
            Sys.insert_log_table(conn, "U", prgid, "ext_brtran", "brtran_sqlno", tmp_brtran_sqlno, logReason);
            SQL = "update ext_brtran set tran_seq_branch=" + Util.dbchar(ReqVal.TryGet("tran_seq_branch"));
            SQL += " ,tran_remark=" + Util.dbchar(ReqVal.TryGet("tran_remark"));
            SQL += " ,tran_date=getdate(),tran_scode='" + Session["scode"] + "'";
            SQL += " where brtran_sqlno=" + tmp_brtran_sqlno;
            conn.ExecuteNonQuery(SQL);
        }
        Sys.showLog("轉案記錄檔流水號=" + brtran_sqlno);

        //更新案件主檔轉案註記
        //入log
        Sys.insert_log_table(conn, "U", prgid, "ext", "seq;seq1", tmp_seq + ";" + tmp_seq1, logReason);
        SQL = "update ext set tran_flag = 'A' ";
        SQL += " ,tran_seq_branch =" + Util.dbchar(ReqVal.TryGet("tran_seq_branch"));
        SQL += " ,tran_remark=" + Util.dbchar(ReqVal.TryGet("tran_remark"));
        SQL += " ,tran_sc_date=getdate() ";
        SQL += " where seq = " + tmp_seq + " and seq1='" + tmp_seq1 + "'";
        conn.ExecuteNonQuery(SQL);

        //新增主管簽核
        string job_team = Sys.getCodeName(conn, "sysctrl.dbo.scode_group", "grpid", "where grpclass='" + Session["seBranch"] + "' and scode='" + Request["signid"] + "'");
        SQL = "insert into todo_ext(pre_sqlno,syscode,apcode,att_no,from_flag,branch,seq,seq1,case_in_scode,in_scode,in_date";
        SQL += ",dowhat,job_scode,job_team,job_status) values (";
        SQL += tmp_todo_sqlno + ",'" + Session["syscode"] + "','" + prgid + "'," + brtran_sqlno + ",'TRAN','" + Session["SeBranch"] + "'," + tmp_seq + ",'" + tmp_seq1 + "','" + tmp_scode + "',";
        SQL += "'" + Session["scode"] + "',getdate(),'TRAN_NM','" + Request["signid"] + "','" + job_team + "','NN')";
        conn.ExecuteNonQuery(SQL);


        //更新主管退回流程
        if (ReqVal.TryGet("qryjob_status") == "NX") {
            SQL = "update todo_ext set job_status='YY',approve_scode='" + Session["scode"] + "',resp_date=getdate() ";
            SQL += " where sqlno=" + tmp_todo_sqlno;
            conn.ExecuteNonQuery(SQL);
        }

        //新增轉案記錄，更新營洽上傳文件檔，補入轉案流水號
        if (tmp_brtran_sqlno == "0") {
            SQL = "update attach_ext set att_sqlno=" + brtran_sqlno;
            SQL += " where seq=" + tmp_seq + " and seq1='" + tmp_seq1 + "' and source='tran' and attach_flag<>'D'";
            conn.ExecuteNonQuery(SQL);
        }
    }
</script>

<%Response.Write(strOut.ToString());%>
