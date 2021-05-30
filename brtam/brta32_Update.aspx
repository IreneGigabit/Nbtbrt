<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>

<script runat="server">
    protected string HTProgCap = "國內案客戶發文作業-入檔";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "brta32";//HttpContext.Current.Request["prgid"] ?? "";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";

    protected string submitTask = "";
    protected string SQL = "";
    protected object objResult = null;
    
    protected string logReason = "Brta2m國內案客發維護作業";
    protected string rs_no = "";
    
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
        conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");

        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        HTProgCap = myToken.Title;
        DebugStr = myToken.DebugStr;
        if (HTProgRight >= 0) {
            try {
                if (ReqVal.TryGet("submittask") == "A") {
                    doAdd();
                    strOut.AppendLine("<div align='center'><h1>客戶發文新增成功!!!發文序號:(" + rs_no + ")</h1></div>");
                } else if (ReqVal.TryGet("submittask") == "U") {
                    doUpdate();
                    strOut.AppendLine("<div align='center'><h1>客戶發文維護成功!!!發文序號:(" + rs_no + ")</h1></div>");
                } else if (ReqVal.TryGet("submittask") == "D") {
                    doDel();
                    strOut.AppendLine("<div align='center'><h1>客戶發文刪除成功!!!發文序號:(" + rs_no + ")</h1></div>");
                }
                //conn.Commit();
                conn.RollBack();
            }
            catch (Exception ex) {
                conn.RollBack();
                Sys.errorLog(ex, conn.exeSQL, prgid);
                throw;
            }
            this.DataBind();
        }
    }

    //新增
    private void doAdd() {
        //發文序號
        rs_no = Sys.getRsNo(conn, "CS");

        SQL = "insert into cs_dmt(rs_no,step_date,send_way,rs_type,rs_class,rs_code,act_code,rs_detail,last_date,tran_date,tran_scode)";
        SQL += " values('" + rs_no + "'," + Util.dbnull(Request["step_date"]) + "," + Util.dbnull(Request["step_date"]);
        SQL += "," + Util.dbnull(Request["send_way"]) + "," + Util.dbnull(Request["rs_type"]);
        SQL += "," + Util.dbchar(Request["rs_class"]) + "," + Util.dbchar(Request["rs_code"]) + "," + Util.dbchar(Request["act_code"]);
        SQL += "," + Util.dbnull(Request["rs_detail"]) + "," + Util.dbnull(Request["last_date"]) + ",getdate(),'" + Session["scode"] + "')";
        conn.ExecuteNonQuery(SQL);

        for (int i = 1; i <= Convert.ToInt32("0" + Request["seqnum"]); i++) {
            if ((Request["seq_" + i] ?? "") != "" || (Request["aseq1_" + i] ?? "") != "") {
                SQL = "insert into csd_dmt ";
                ColMap.Clear();
                ColMap["rs_no"] = Util.dbchar(rs_no);
                ColMap["branch"] = Util.dbchar(Request["branch_" + i]);
                ColMap["seq"] = Util.dbnull(Request["seq_" + i]);
                ColMap["seq1"] = Util.dbchar(Request["aseq1_" + i]);
                ColMap["cust_seq"] = Util.dbnull(Request["cust_seq_" + i]);
                ColMap["att_sql"] = Util.dbnull(Request["att_sql_" + i]);
                SQL += ColMap.GetInsertSQL();
                conn.ExecuteNonQuery(SQL);
            }
        }
    }

    //維護
    private void doUpdate() {
        rs_no = Request["rs_no"];

        //新增 cs_dmt_Log 檔
        SQL = " insert into cs_dmt_log(ud_flg,rs_no,branch,seq,seq1,cust_seq,att_sql,step_date,";
        SQL += "send_way,rs_type,rs_class,rs_code,act_code,rs_detail,mark,tran_date,tran_scode)";
        SQL += " select 'U',rs_no,branch,seq,seq1,cust_seq,att_sql,step_date,send_way,";
        SQL += "rs_type,rs_class,rs_code,act_code,rs_detail,mark,tran_date,tran_scode";
        SQL += " from vcs_dmt where rs_no = '" + rs_no + "'";
        conn.ExecuteNonQuery(SQL);

        //更新cs_dmt
        SQL = "update cs_dmt set ";
        SQL += " step_date=" + Util.dbnull(Request["step_date"]) + ",rs_type=" + Util.dbnull(Request["rs_type"]);
        SQL += ",rs_class=" + Util.dbchar(Request["rs_class"]) + ",rs_code=" + Util.dbchar(Request["rs_code"]);
        SQL += ",act_code=" + Util.dbchar(Request["act_code"]) + ",rs_detail=" + Util.dbnull(Request["rs_detail"]);
        SQL += ",send_way=" + Util.dbnull(Request["send_way"]) + ",last_date=" + Util.dbnull(Request["last_date"]);
        SQL += ",tran_date=getdate(),tran_scode='" + Session["scode"] + "'";
        SQL += " where rs_no='" + rs_no + "'";
        conn.ExecuteNonQuery(SQL);

        //先刪除再入csd_dmt
        SQL = "delete from csd_dmt where rs_no='" + rs_no + "'";
        conn.ExecuteNonQuery(SQL);

        for (int i = 1; i <= Convert.ToInt32("0" + Request["seqnum"]); i++) {
            if ((Request["seq_" + i] ?? "") != "" || (Request["aseq1_" + i] ?? "") != "") {
                SQL = "insert into csd_dmt ";
                ColMap.Clear();
                ColMap["rs_no"] = Util.dbchar(rs_no);
                ColMap["branch"] = Util.dbchar(Request["branch_" + i]);
                ColMap["seq"] = Util.dbnull(Request["seq_" + i]);
                ColMap["seq1"] = Util.dbchar(Request["aseq1_" + i]);
                ColMap["cust_seq"] = Util.dbnull(Request["cust_seq_" + i]);
                ColMap["att_sql"] = Util.dbnull(Request["att_sql_" + i]);
                SQL += ColMap.GetInsertSQL();
                conn.ExecuteNonQuery(SQL);
            }
        }
    }
    
    //刪除
    private void doDel() {
        rs_no = Request["rs_no"];

        //新增 cs_dmt_Log 檔
        SQL = " insert into cs_dmt_log(ud_flg,rs_no,branch,seq,seq1,cust_seq,att_sql,step_date";
        SQL += ",send_way,rs_type,rs_class,rs_code,act_code,rs_detail,mark,tran_date,tran_scode)";
        SQL += "select 'D',rs_no,branch,seq,seq1,cust_seq,att_sql,step_date,send_way";
        SQL += ",rs_type,rs_class,rs_code,act_code,rs_detail,mark,tran_date,tran_scode";
        SQL += " from vcs_dmt where rs_no = '" + rs_no + "'";
        conn.ExecuteNonQuery(SQL);

        //刪除cs_dmt
        SQL = "delete from cs_dmt where rs_no='" + rs_no + "'";
        conn.ExecuteNonQuery(SQL);

        //刪除csd_dmt
        SQL = "delete from csd_dmt where rs_no='" + rs_no + "'";
        conn.ExecuteNonQuery(SQL);
    }
</script>

<%Response.Write(strOut.ToString());%>
