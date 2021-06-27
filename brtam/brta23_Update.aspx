<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>

<script runat="server">
    protected string HTProgCap = "期限管制維護作業-入檔";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "brta23";//HttpContext.Current.Request["prgid"] ?? "";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";

    protected string submitTask = "";
    protected string SQL = "";
    protected object objResult = null;

    protected string logReason = "Brta23期限管制維護作業";
    protected string fseq = "", rs_no = "";
    
    protected string sqlno = "";
    protected string seq = "";
    protected string seq1 = "";
    protected string step_grade = "";
    protected string ctrl_type = "";
    protected string ctrl_date = "";
    protected string ctrl_remark = "";
    protected string resp_type = "";
    protected string resp_date = "";
    protected string resp_remark = "";

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
                submitTask = ReqVal.TryGet("task");
                sqlno = ReqVal.TryGet("sqlno");
                seq = ReqVal.TryGet("seq");
                seq1 = ReqVal.TryGet("seq1");
                step_grade = ReqVal.TryGet("grade");
                ctrl_type = ReqVal.TryGet("ctype");
                ctrl_date = ReqVal.TryGet("cdate");
                ctrl_remark = ReqVal.TryGet("cmark");
                resp_type = ReqVal.TryGet("rtype");
                resp_date = ReqVal.TryGet("rdate");
                resp_remark = ReqVal.TryGet("rmark");

                //取得收發文代號
                SQL = "select rs_no from step_dmt ";
                SQL += " where branch = '" + Session["seBranch"] + "' and seq = " + seq;
                SQL += " and seq1 = '" + seq1 + "' and step_grade = " + step_grade;
                objResult = conn.ExecuteScalar(SQL);
                rs_no = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();

                if (submitTask == "A") {
                    doAdd();
                } else if (submitTask == "U") {
                    doUpdate();
                } else if (submitTask == "R") {
                    doResp();
                }
                conn.Commit();
                //conn.RollBack();

                strOut.AppendLine("alert('存檔成功!!!');");
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
        SQL = "insert into ctrl_dmt ";
        ColMap.Clear();
        ColMap["rs_no"] = Util.dbchar(rs_no);
        ColMap["branch"] = Util.dbchar(Sys.GetSession("seBranch"));
        ColMap["seq"] = Util.dbnull(seq);
        ColMap["seq1"] = Util.dbchar(seq1);
        ColMap["step_grade"] = Util.dbchar(step_grade);
        ColMap["ctrl_type"] = Util.dbchar(ctrl_type);
        ColMap["ctrl_remark"] = Util.dbnull(ctrl_remark);
        ColMap["ctrl_date"] = Util.dbnull(ctrl_date);
        ColMap["tran_date"] = "getdate()";
        ColMap["tran_scode"] = "'" + Session["scode"] + "'";
        SQL += ColMap.GetInsertSQL();
        conn.ExecuteNonQuery(SQL);
    }

    //修改
    private void doUpdate() {
        Sys.insert_log_table(conn, "U", HTProgCode, "ctrl_dmt", "sqlno", sqlno, "");

        SQL = "update ctrl_dmt set ";
        ColMap.Clear();
        ColMap["ctrl_type"] = Util.dbchar(ctrl_type);
        ColMap["ctrl_remark"] = Util.dbnull(ctrl_remark);
        ColMap["ctrl_date"] = Util.dbnull(ctrl_date);
        ColMap["tran_date"] = "getdate()";
        ColMap["tran_scode"] = "'" + Session["scode"] + "'";
        SQL += ColMap.GetUpdateSQL();
        SQL += " where sqlno = '" + sqlno + "' ";
        conn.ExecuteNonQuery(SQL);
    }
    
    //銷管
    private void doResp() {
        //新增銷管檔 
        SQL = "insert into resp_dmt(sqlno,rs_no,branch,seq,seq1,step_grade,resp_grade,ctrl_type,ctrl_remark,ctrl_date";
        SQL += ",resp_date,resp_type,resp_remark,tran_date,tran_scode) ";
        SQL += "select sqlno,'" + rs_no + "','" + Session["seBranch"] + "','" + seq + "','" + seq1 + "','" + step_grade;
        SQL += "',0,ctrl_type,ctrl_remark,ctrl_date,'" + resp_date + "','" + resp_type + "','" + resp_remark + "'";
        SQL += ",getdate(),'" + Session["scode"] + "' ";
        SQL += "from ctrl_dmt where sqlno =" + sqlno + "";
        conn.ExecuteNonQuery(SQL);

        //刪除管制檔  新增 ctrl_dmt_log
        Sys.insert_log_table(conn, "D", HTProgCode, "ctrl_dmt", "sqlno", sqlno, logReason);
        SQL = "delete from ctrl_dmt where sqlno = " + sqlno;
        conn.ExecuteNonQuery(SQL);
    }
</script>

<%Response.Write(strOut.ToString());%>
