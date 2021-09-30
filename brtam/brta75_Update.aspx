<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>

<script runat="server">
    protected string HTProgCap = "國內案結案確認暨掃描上傳-入檔";//HttpContext.Current.Request["prgname"];//功能名稱
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

    protected string logReason = "Brta75結案確認作業";
    string[] arr_chkflag, arr_ctrl_sqlno, arr_todo_sqlno, arr_branch, arr_seq, arr_seq1, arr_ctrlcnt, arr_anncnt, arr_oend_date, arr_step_grade, arr_rs_sqlno, arr_scannum, arr_end_code, arr_end_type, arr_end_remark;
    
    protected StringBuilder strOut = new StringBuilder();

    DBHelper conn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    DBHelper connm = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    private void Page_Unload(System.Object sender, System.EventArgs e) {
        if (conn != null) conn.Dispose();
        if (connm != null) connm.Dispose();
    }

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");
        arr_chkflag=ReqVal.TryGet("rows_chkflag").Split('\f');
        arr_ctrl_sqlno=ReqVal.TryGet("rows_ctrl_sqlno").Split('\f');
        arr_todo_sqlno=ReqVal.TryGet("rows_todo_sqlno").Split('\f');
        arr_branch=ReqVal.TryGet("rows_branch").Split('\f');
        arr_seq=ReqVal.TryGet("rows_seq").Split('\f');
        arr_seq1=ReqVal.TryGet("rows_seq1").Split('\f');
        arr_oend_date=ReqVal.TryGet("rows_oend_date").Split('\f');
        arr_step_grade=ReqVal.TryGet("rows_step_grade").Split('\f');
        arr_rs_sqlno=ReqVal.TryGet("rows_rs_sqlno").Split('\f');
        arr_scannum=ReqVal.TryGet("rows_scannum").Split('\f');
        arr_end_code=ReqVal.TryGet("rows_end_code").Split('\f');
        arr_end_type=ReqVal.TryGet("rows_end_type").Split('\f');
        arr_end_remark = ReqVal.TryGet("rows_end_remark").Split('\f');
     
        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        HTProgCap = myToken.Title;
        DebugStr = myToken.DebugStr;
        if (HTProgRight >= 0) {
            try {
                connm = new DBHelper(Conn.MG).Debug(Request["chkTest"] == "TEST");
                conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");

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
                            throw new Exception(Session["seBranch"] + "T" + tmp_seq + "-" + tmp_seq1 + "程序結案確認失敗(狀態已異動，請重新整理畫面)");
                        } else {
                            update_dmt(i);
                            update_ctrl_dmt(i);
                            if (Convert.ToInt32(arr_scannum[i]) > 0) {
                                update_attach_dmt_scan(i);
                            }
                            update_todo_dmt(i);
                        }
                    }
                }

                strOut.AppendLine("<div align='center'><h1>國內案結案確認成功</h1></div>");
                conn.Commit();
                connm.Commit();
                //conn.RollBack();
                //connm.RollBack();
            }
            catch (Exception ex) {
                conn.RollBack();
                connm.RollBack();
                Sys.errorLog(ex, conn.exeSQL, prgid);
                Sys.errorLog(ex, connm.exeSQL, prgid);
                throw;
            }
            finally {
                conn.Dispose();
                connm.Dispose();
            }
            this.DataBind();
        }
    }

    /// <summary>
    /// 更新案件主檔
    /// </summary>
    private void update_dmt(int pno) {
        string tmp_seq = arr_seq[pno];
        string tmp_seq1 = arr_seq1[pno];
        string tmp_step_grade = arr_step_grade[pno];
        string tmp_rs_sqlno = arr_rs_sqlno[pno];
        string tmp_end_code = arr_end_code[pno];
        string tmp_end_type = arr_end_type[pno];
        string tmp_end_remark = arr_end_remark[pno];

        //新增案件主檔Log檔
        Sys.insert_log_table(conn, "U", HTProgCode, "dmt", "seq;seq1", tmp_seq + ";" + tmp_seq1, logReason);

        //更新案件主檔結案原因
        SQL = "update dmt set end_type = " + Util.dbchar(tmp_end_type) + " ";
        SQL += " ,end_remark = " + Util.dbchar(tmp_end_remark) + " ";
        SQL += " where seq = '" + tmp_seq + "' and seq1='" + tmp_seq1 + "'";

        //更新案件主檔結案日期及結案代碼
        SQL = "update dmt set end_date = '" + DateTime.Today.ToShortDateString() + "' ";
        SQL += " ,end_code = '" + tmp_end_code + "' ";
        SQL += " ,end_type = '" + tmp_end_type + "' ";
        SQL += " ,end_remark = '" + tmp_end_remark + "' ";
        SQL += " where seq = " + tmp_seq + " and seq1='" + tmp_seq1 + "'";
        conn.ExecuteNonQuery(SQL);

        //通知總收發文待結案處理
        SQL = "insert into brend_mgt ";
        ColMap.Clear();
        ColMap["br_step_grade"] = Util.dbchar(tmp_step_grade);
        ColMap["br_rs_sqlno"] = Util.dbchar(tmp_rs_sqlno);
        ColMap["seq_area"] = "'" + Session["seBranch"] + "'";
        ColMap["seq"] = Util.dbchar(tmp_seq);
        ColMap["seq1"] = Util.dbchar(tmp_seq1);
        ColMap["end_flag"] = "'end'";
        ColMap["br_end_date"] = "'" + DateTime.Today.ToShortDateString() + "'";
        ColMap["br_end_code"] = Util.dbchar(tmp_end_code);
        ColMap["br_end_reason"] = Util.dbchar(tmp_end_remark);
        ColMap["in_scode"] = "'" + Session["scode"] + "'";
        ColMap["in_date"] = "getdate()";
        SQL += ColMap.GetInsertSQL();
        connm.ExecuteNonQuery(SQL);

        //抓insert後的流水號
        SQL = "SELECT SCOPE_IDENTITY() AS Current_Identity";
        object objResult1 = connm.ExecuteScalar(SQL);
        string Getrs_sqlno = objResult1.ToString();
        Sys.showLog("總收發文流水號=" + Getrs_sqlno);

        //寫入總收發文結案流程資料
        SQL = "insert into todo_mgt ";
        ColMap.Clear();
        ColMap["syscode"] = "'" + Session["syscode"] + "'";
        ColMap["apcode"] = "'" + prgid + "'";
        ColMap["temp_rs_sqlno"] = Util.dbchar(Getrs_sqlno);
        ColMap["br_rs_sqlno"] = Util.dbchar(tmp_rs_sqlno);
        ColMap["seq_area"] = "'" + Session["seBranch"] + "'";
        ColMap["seq"] = Util.dbchar(tmp_seq);
        ColMap["seq1"] = Util.dbchar(tmp_seq1);
        ColMap["in_date"] = "getdate()";
        ColMap["in_scode"] = "'" + Session["scode"] + "'";
        ColMap["dowhat"] = "'end'";
        ColMap["job_status"] = "'NN'";
        SQL += ColMap.GetInsertSQL();
        connm.ExecuteNonQuery(SQL);
    }

    /// <summary>
    /// 銷管暨管制期限
    /// </summary>
    private void update_ctrl_dmt(int pno) {
        string tctrl_sqlno = arr_ctrl_sqlno[pno];

        //抓取ctrl_dmt入resp_dmt
        SQL = "insert into resp_dmt(sqlno,rs_no,branch,seq,seq1,step_grade,resp_grade,ctrl_type,ctrl_remark,ctrl_date,resp_date,resp_type,resp_remark,tran_date,tran_scode) ";
        SQL += "select sqlno,rs_no,branch,seq,seq1,step_grade,0,ctrl_type,ctrl_remark,ctrl_date,'" + DateTime.Today.ToShortDateString() + "','','已結案確認',getdate(),'" + Session["scode"] + "' ";
        SQL += "from ctrl_dmt where sqlno=" + tctrl_sqlno;
        conn.ExecuteNonQuery(SQL);

        //刪除結案期限	  
        SQL = "delete from ctrl_dmt where sqlno=" + tctrl_sqlno;
        conn.ExecuteNonQuery(SQL);
    }

    /// <summary>
    /// 修改程序結案確認狀態todo_dmt
    /// </summary>
    private void update_todo_dmt(int pno) {
        string tmp_sqlno = arr_todo_sqlno[pno];
        string tmp_seq = arr_seq[pno];
        string tmp_seq1 = arr_seq1[pno];

        //更新程序結案確認狀態
        SQL = "update todo_dmt set job_status = 'YZ' ";
        SQL += " ,approve_scode = '" + Session["scode"] + "' ";
        SQL += " ,resp_date=getdate() ";
        SQL += " where sqlno = '" + tmp_sqlno + "'";
        conn.ExecuteNonQuery(SQL);
    }
    
    /// <summary>
    /// 文件掃描確認處理
    /// </summary>
    private void update_attach_dmt_scan(int pno) {
        int scannum = Convert.ToInt32("0" + arr_scannum[pno]);
        string tseq = arr_seq[pno];
        string tseq1 = arr_seq1[pno];

        for (int j = 1; j <= scannum; j++) {
            string tattach_sqlno = ReqVal.TryGet("attach_sqlno_" + pno + "_" + j);
            string tstep_grade = ReqVal.TryGet("step_grade_" + pno + "_" + j);
            string tpage = ReqVal.TryGet("pr_scan_page_" + pno + "_" + j);
            string trs_no = ReqVal.TryGet("rs_no_" + pno + "_" + j);
            string trs_sqlno = ReqVal.TryGet("rs_sqlno_" + pno + "_" + j);

            //文件檔dmt_attach
            Sys.insert_log_table(conn, "U", prgid, "dmt_attach", "attach_sqlno", tattach_sqlno, logReason);
            SQL = "update dmt_attach set ";
            ColMap.Clear();
            ColMap["chk_status"] = Util.dbchar("Y2");
            ColMap["chk_date"] = "getdate()";
            ColMap["chk_scode"] = "'" + Session["scode"] + "'";
            ColMap["chk_page"] = Util.dbzero(tpage);
            ColMap["attach_desc"] = Util.dbchar(Request["attach_desc_" + pno + "_" + j]);
            ColMap["tran_date"] = "getdate()";
            ColMap["tran_scode"] = "'" + Session["scode"] + "'";
            SQL += ColMap.GetUpdateSQL();
            SQL += " where attach_sqlno = '" + tattach_sqlno + "' and source='scan'";
            conn.ExecuteNonQuery(SQL);

            //流程檔todo_dmt
            SQL = "update todo_dmt set approve_scode = '" + Session["scode"] + "' ";
            SQL += " ,resp_date=getdate() ";
            SQL += " ,job_status = 'YY' ";
            SQL += " where seq=" + tseq + " and seq1='" + tseq1 + "' and step_grade=" + tstep_grade + " and temp_rs_sqlno=" + tattach_sqlno + " and dowhat='scan' ";
            conn.ExecuteNonQuery(SQL);

            //新增 step_dmt_Log 檔
            Sys.insert_log_table(conn, "U", prgid, "step_dmt", "rs_no", trs_no, logReason);
            SQL = "update step_dmt set pr_scan=" + Util.dbchar(Request["hpr_scan_" + pno + "_" + j]);
            SQL += ",tran_date=getdate() ";
            SQL += ",tran_scode='" + Session["scode"] + "'";
            SQL += " where rs_sqlno='" + trs_sqlno + "'";
            conn.ExecuteNonQuery(SQL);
        }
    }
</script>

<%Response.Write(strOut.ToString());%>
