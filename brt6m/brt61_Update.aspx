<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>

<script runat="server">
    protected string HTProgCap = "國內案文件掃描確認入檔";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = HttpContext.Current.Request["prgid"] ?? "";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";

    protected string submitTask = "";
    protected string SQL = "";
    protected object objResult = null;
    protected string logReason = "";
       
    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected Dictionary<string, string> ColMap = new Dictionary<string, string>();

    string[] arr_chk,arr_seq,arr_seq1,arr_rs_sqlno,arr_step_grade,arr_rs_no,arr_hpr_scan;
    string[] arr_pr_scan_path,arr_attach_no,arr_attach_sqlno,arr_pr_scan,arr_pr_scan_page;
    string[] arr_attach_desc;
    
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
        arr_seq = Request["rows_seq"].Split('\f');
        arr_seq1 = Request["rows_seq1"].Split('\f');
        arr_rs_sqlno = Request["rows_rs_sqlno"].Split('\f');
        arr_step_grade = Request["rows_step_grade"].Split('\f');
        arr_rs_no = Request["rows_rs_no"].Split('\f');
        arr_hpr_scan = Request["rows_hpr_scan"].Split('\f');
        arr_pr_scan_path = Request["rows_pr_scan_path"].Split('\f');
        arr_attach_no = Request["rows_attach_no"].Split('\f');
        arr_attach_sqlno = Request["rows_attach_sqlno"].Split('\f');
        arr_pr_scan = Request["rows_pr_scan"].Split('\f');
        arr_pr_scan_page = Request["rows_pr_scan_page"].Split('\f');
        arr_attach_desc = Request["rows_attach_desc"].Split('\f');

        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        HTProgCap = myToken.Title;
        DebugStr = myToken.DebugStr;
        if (HTProgRight >= 0) {
            try {
                if (ReqVal.TryGet("task") == "conf") {
                    logReason = "brt61國內案文件掃描確認作業";
                    doConf();
                    strOut.AppendLine("<div align='center'><h1>文件掃描確認成功!!!</h1></div>");
                }
                if (ReqVal.TryGet("task") == "cancel") {
                    logReason = "brt61國內案文件掃描取消作業";
                    doCancel();
                    strOut.AppendLine("<div align='center'><h1>文件掃描取消成功!!!</h1></div>");
                }
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

    //文件掃描確認
    private void doConf() {
        for (int i = 1; i < arr_chk.Length; i++) {
            if (arr_chk[i] == "Y") {//有打勾
			    //更新dmt_attach&todo_dmt
                update_dmt_attach_scan(arr_attach_sqlno[i], "Y2", arr_pr_scan_page[i], i);

                //掃描確認資料更新step_dmt
                update_step_dmt_scan(arr_rs_no[i], i);
            }
        }
    }

    //文件掃描取消
    private void doCancel() {
        for (int i = 1; i < arr_chk.Length; i++) {
            if (arr_chk[i] == "Y") {//有打勾
                update_dmt_attach_scan(arr_attach_sqlno[i], "XX", "0", i);
            }
        }
    }
    
    //掃描確認資料更新step_dmt
    private void update_step_dmt_scan(string trs_no, int pno) {
        Sys.insert_log_table(conn, "U", prgid, "step_dmt", "rs_no", trs_no, logReason);
	    SQL = "update step_dmt set pr_scan='" +arr_hpr_scan[pno]+ "'";
	    SQL+= ",tran_date=getdate() ";
	    SQL+= ",tran_scode='" + Session["scode"] + "'";
        SQL += " where rs_no='" + trs_no +"'";
        conn.ExecuteNonQuery(SQL);
    }
    
    //更新dmt_attach&todo_dmt
    private void update_dmt_attach_scan(string tattach_sqlno, string tstatus, string tpage, int pno) {
        Sys.insert_log_table(conn, "U", prgid, "dmt_attach", "attach_sqlno", tattach_sqlno, logReason);
        SQL = "update dmt_attach set chk_status='" + tstatus + "'";
        SQL += ",chk_date=getdate()";
        SQL += ",chk_scode='" + Session["scode"] + "'";
        SQL += ",chk_page=" + Util.dbzero(tpage);
        SQL += ",attach_desc=" + Util.dbchar(arr_attach_desc[pno]);
        if (tstatus == "XX") {
            SQL += ",attach_flag='D' ";
        }
        SQL += ",tran_date=getdate()";
        SQL += ",tran_scode='" + Session["scode"] + "'";
        SQL += " where attach_sqlno=" + tattach_sqlno + " and source='scan' ";
        conn.ExecuteNonQuery(SQL);

        SQL = "update todo_dmt set approve_scode='" + Session["scode"] + "'";
        SQL += ",resp_date=getdate()";
        if (tstatus == "Y2") {
            SQL += ",job_status='YY'";
        } else if (tstatus == "XX") {
            SQL += ",job_status='XX'";
        }
        SQL += " where temp_rs_sqlno=" + tattach_sqlno + " and dowhat='scan' ";
        conn.ExecuteNonQuery(SQL);
    }
</script>

<%Response.Write(strOut.ToString());%>
