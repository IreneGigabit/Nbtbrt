<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Collections.Generic"%>

<script runat="server">
    protected string HTProgCap = "總收發文官方收文資料複製";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = HttpContext.Current.Request["prgid"] ?? "";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";

    protected string SQL = "";
    protected object objResult = null;
    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected string logReason = "";

    protected string qBranch = "";
    protected string qSeq = "";
    protected string qSeq1 = "";
    protected string temp_rs_sqlno = "";
    protected string mg_step_rs_sqlno = "";
    protected string cgrs = "";
    
    protected StringBuilder strOut = new StringBuilder();

    DBHelper conn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    DBHelper connm = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    private void Page_Unload(System.Object sender, System.EventArgs e) {
        if (conn != null) conn.Dispose();
        if (connm != null) connm.Dispose();
    }

    protected void Page_Load(object sender, EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        logReason = prgid + "總收發文官方收文資料複製";

        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");

        conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
        connm = new DBHelper(Conn.MG).Debug(Request["chkTest"] == "TEST");

        qBranch = (Request["qBranch"] ?? "").Trim();
        qSeq = (Request["qSeq"] ?? "").Trim();
        qSeq1 = (Request["qSeq1"] ?? "").Trim();
        temp_rs_sqlno = (Request["temp_rs_sqlno"] ?? "").Trim();
        mg_step_rs_sqlno = (Request["mg_step_rs_sqlno"] ?? "").Trim();
        cgrs = (Request["cgrs"] ?? "").Trim();

        try {
            //入step_mgt_temp_log
            Sys.insert_log_table(conn, "U", prgid, "step_mgt_temp", "temp_rs_sqlno", temp_rs_sqlno, logReason);

            //入總收發文進度檔資料至step_mgt_temp
            SQL = "select from_flag,step_date,send_cl,rs_type,rs_class,rs_code,act_code";
            SQL += ",rs_detail,receive_no,receive_way,doc_detail,pr_scan,pr_scan_remark,pr_scan_path";
            SQL += ",file_type,file_sqlno,file_into_type,new_seq,gno_type,gno,gno_date,mark from step_mgt ";
            SQL += "where seq_area='" + qBranch + "' and seq='" + qSeq + "' and seq1='" + qSeq1 + "' and step_rs_sqlno=" + mg_step_rs_sqlno;
            using (SqlDataReader dr = connm.ExecuteReader(SQL)) {
                if (dr.Read()) {
                    SQL = "update step_mgt_temp set from_flag=" + Util.dbchar(dr.SafeRead("from_flag", ""));
                    SQL += ",mg_step_date=" + Util.dbchar(dr.GetDateTimeString("step_date", "yyyy/M/d"));
                    SQL += ",send_cl=" + Util.dbchar(dr.SafeRead("send_cl", ""));
                    SQL += ",rs_type=" + Util.dbchar(dr.SafeRead("rs_type", ""));
                    SQL += ",rs_class=" + Util.dbchar(dr.SafeRead("rs_class", ""));
                    SQL += ",rs_code=" + Util.dbchar(dr.SafeRead("rs_code", ""));
                    SQL += ",act_code=" + Util.dbchar(dr.SafeRead("act_code", ""));
                    SQL += ",rs_detail=" + Util.dbchar(dr.SafeRead("rs_detail", ""));
                    SQL += ",receive_no=" + Util.dbchar(dr.SafeRead("receive_no", ""));
                    SQL += ",receive_way=" + Util.dbchar(dr.SafeRead("receive_way", ""));
                    SQL += ",doc_detail=" + Util.dbchar(dr.SafeRead("doc_detail", ""));
                    SQL += ",pr_scan=" + Util.dbchar(dr.SafeRead("pr_scan", ""));
                    SQL += ",pr_scan_remark=" + Util.dbchar(dr.SafeRead("pr_scan_remark", ""));
                    SQL += ",pr_scan_path=" + Util.dbchar(dr.SafeRead("pr_scan_path", ""));
                    SQL += ",file_type=" + Util.dbchar(dr.SafeRead("file_type", ""));
                    SQL += ",file_sqlno=" + Util.dbchar(dr.SafeRead("file_sqlno", ""));
                    SQL += ",file_into_type=" + Util.dbchar(dr.SafeRead("file_into_type", ""));
                    SQL += ",new_seq=" + Util.dbchar(dr.SafeRead("new_seq", ""));
                    SQL += ",gno_type=" + Util.dbchar(dr.SafeRead("gno_type", ""));
                    SQL += ",gno=" + Util.dbchar(dr.SafeRead("gno", ""));
                    SQL += ",gno_date=" + Util.dbchar(dr.GetDateTimeString("gno_date", "yyyy/M/d"));
                    SQL += ",mark=" + Util.dbchar(dr.SafeRead("mark", ""));
                    SQL += " where temp_rs_sqlno=" + temp_rs_sqlno;
                    conn.ExecuteNonQuery(SQL);
                }
            }

            //刪除國內所ctrl_mgt_temp
            //入ctrl_mgt_temp_log
            Sys.insert_log_table(conn, "U", prgid, "ctrl_mgt_temp", "temp_rs_sqlno", temp_rs_sqlno, logReason);
            SQL = "delete from ctrl_mgt_temp where temp_rs_sqlno=" + temp_rs_sqlno;
            conn.ExecuteNonQuery(SQL);

            //入總收發期限管制檔至ctrl_mgt_temp
            SQL = "select * from ctrl_mgt where step_rs_sqlno=" + mg_step_rs_sqlno;
            using (SqlDataReader dr = connm.ExecuteReader(SQL)) {
                while (dr.Read()) {
                    SQL = "insert into ctrl_mgt_temp (temp_rs_sqlno,seq_area,seq,seq1,mg_step_grade,mg_step_rs_sqlno,ctrl_type,ctrl_remark,ctrl_date,date_ctrl,tran_date,tran_scode) values (";
                    SQL += temp_rs_sqlno + "," + Util.dbchar(dr.SafeRead("seq_area", "")) + "," + Util.dbzero(dr.SafeRead("seq", "")) + "," + Util.dbchar(dr.SafeRead("seq1", ""));
                    SQL += "," + Util.dbzero(dr.SafeRead("step_grade", "")) + "," + Util.dbzero(dr.SafeRead("step_rs_sqlno", "")) + "," + Util.dbchar(dr.SafeRead("ctrl_type", ""));
                    SQL += "," + Util.dbchar(dr.SafeRead("ctrl_remark", "")) + "," + Util.dbchar(dr.GetDateTimeString("ctrl_date", "yyyy/M/d")) + "," + Util.dbchar(dr.SafeRead("date_ctrl", ""));
                    SQL += "," + Util.dbchar(dr.GetDateTimeString("tran_date", "yyyy/M/d HH:mm:ss")) + ",'" + Util.dbchar(dr.SafeRead("tran_scode", "")) + "')";
                    conn.ExecuteNonQuery(SQL);
                }
            }

            //入resp_mgt_temp_log
            SQL = "delete from resp_mgt_temp where temp_rs_sqlno=" + temp_rs_sqlno;
            conn.ExecuteNonQuery(SQL);

            //入總收發期限銷管檔至resp_mgt_temp
            SQL = "select * from resp_mgt where step_rs_sqlno=" + mg_step_rs_sqlno;
            using (SqlDataReader dr = connm.ExecuteReader(SQL)) {
                while (dr.Read()) {
                    SQL = "insert into resp_mgt_temp (temp_rs_sqlno,seq_area,seq,seq1,mg_step_grade,mg_step_rs_sqlno,mg_resp_step_grade,ctrl_type,ctrl_remark,ctrl_date";
                    SQL += ",date_ctrl,reason,resp_date,resp_type,resp_remark,ctrl_tran_date,ctrl_tran_scode,tran_date,tran_scode) values (";
                    SQL += temp_rs_sqlno + "," + Util.dbchar(dr.SafeRead("seq_area", "")) + "," + Util.dbzero(dr.SafeRead("seq", "")) + "," + Util.dbchar(dr.SafeRead("seq1", ""));
                    SQL += "," + Util.dbzero(dr.SafeRead("step_grade", "")) + "," + Util.dbzero(dr.SafeRead("step_rs_sqlno", "")) + "," + Util.dbzero(dr.SafeRead("resp_step_grade", ""));
                    SQL += "," + Util.dbchar(dr.SafeRead("ctrl_type", "")) + "," + Util.dbchar(dr.SafeRead("ctrl_remark", "")) + "," + Util.dbchar(dr.GetDateTimeString("ctrl_date", "yyyy/M/d"));
                    SQL += "," + Util.dbchar(dr.SafeRead("date_ctrl", "")) + "," + Util.dbchar(dr.SafeRead("reason", "")) + "," + Util.dbchar(dr.GetDateTimeString("resp_date", "yyyy/M/d HH:mm:ss"));
                    SQL += "," + Util.dbchar(dr.SafeRead("resp_type", "")) + "," + Util.dbchar(dr.SafeRead("resp_remark", "")) + "," + Util.dbchar(dr.GetDateTimeString("ctrl_tran_date", "yyyy/M/d HH:mm:ss"));
                    SQL += "," + Util.dbchar(dr.SafeRead("ctrl_tran_scode", "")) + "," + Util.dbchar(dr.GetDateTimeString("tran_date", "yyyy/M/d HH:mm:ss")) + "," + Util.dbchar(dr.SafeRead("tran_scode", "")) + "')";
                    conn.ExecuteNonQuery(SQL);
                }
            }

            //conn.Commit();
            conn.RollBack();
            strOut.AppendLine("alert('總收發收文資料抓取成功！');");
            if (prgid == "brta24") {//程序官收確認
                strOut.AppendLine("location.reload();");
            }
        }
        catch (Exception ex) {
            conn.RollBack();
            Sys.errorLog(ex, conn.exeSQL, prgid);
            strOut.AppendLine("alert('總收發收文資料抓取失敗！！');");
            //throw;
        }
    }
</script>

<%=strOut.ToString()%>
