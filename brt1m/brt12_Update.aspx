<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>

<script runat="server">
    protected string HTProgCap = HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "brt12";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";

    protected string submitTask = "";
    protected string SQL = "";

    protected string signid = "";
    protected string nGrpID = "";
    protected string cust_seq = "";
    protected string proid = "";
    protected string row = "";

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

        signid = (Request["signid"] ?? "").Trim();
        nGrpID = (Request["grpid"] ?? "").Trim();
        cust_seq = (Request["cust_seq"] ?? "").Trim();
        proid = (Request["qs_proid"] ?? "").Trim();
        row = (Request["row"] ?? "").Trim();

        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        HTProgCap = myToken.Title;
        DebugStr = myToken.DebugStr;
        if (HTProgRight >= 0) {
            try {
                conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
                
                doUpdateDB();
                conn.Commit();
                //conn.RollBack();
                strOut.AppendLine("<div align='center'><h1>交辦成功</h1></div>");
            }
            catch (Exception ex) {
                conn.RollBack();
                Sys.errorLog(ex, conn.exeSQL, prgid);
                //strOut.AppendLine("<div align='center'><h1>交辦成功("+ex.Message+")</h1></div>");
                throw;
            }
            finally {
                conn.Dispose();
            }
            this.DataBind();
        }
    }

    private void doUpdateDB() {
        string job_team = "", job_Grplevel = "";
        Sys.getScodeGrpid(Sys.GetSession("seBranch"), signid, ref job_team, ref job_Grplevel);

        for (int i = 1; i <= Convert.ToInt32("0" + row); i++) {
            if (Request["T_" + i] == "Y") {
                string mscode = ReqVal.TryGet("incode_" + i);
                string mno = ReqVal.TryGet("inno_" + i);
                string seq = ReqVal.TryGet("seq_" + i);
                string seq1 = ReqVal.TryGet("seq1_" + i);

                //判斷狀態是否已異動,防止開雙視窗
                SQL = "select count(*) from case_dmt where In_no='" + mno + "' and left(stat_code,1)='Y'";
                object objResult = conn.ExecuteScalar(SQL);
                int cnt = (objResult == DBNull.Value || objResult == null) ? 0 : Convert.ToInt32(objResult);
                if (cnt == 0) {
                    string yymm = DateTime.Today.ToString("yyMM");
                    SQL = "select max(case_no)+1 from case_dmt where left(case_no,4)='" + yymm + "'";
                    objResult = conn.ExecuteScalar(SQL);
                    string RSno = (objResult == DBNull.Value || objResult == null ? (yymm + "0001") : objResult.ToString());

                    //更新交辦狀態
                    SQL = "UPDATE case_dmt SET Case_no = '" + RSno + "' ";
                    SQL += ",Case_date = '" + DateTime.Today.ToShortDateString() + "' ";
                    SQL += ",Stat_code = 'YN' ";
                    SQL += ",Case_num = Case_num + 1 ";
                    SQL += " WHERE In_scode='" + mscode + "' AND In_no='" + mno + "'";
                    conn.ExecuteNonQuery(SQL);

                    //2008/11/27增加將交辦單號寫入文件上傳檔
                    SQL = "update dmt_attach set case_no='" + RSno + "' ";
                    SQL += " where in_no='" + mno + "'";
                    conn.ExecuteNonQuery(SQL);

                    //寫入todo
                    SQL = "insert into todo_dmt ";
                    ColMap.Clear();
                    ColMap["branch"] = "'" + Session["seBranch"]+ "'";
                    ColMap["syscode"] = "'" + Session["syscode"]+ "'";
                    ColMap["apcode"] = "'brt31'";//下一關的prgid
                    ColMap["from_flag"] = Util.dbchar("CASE");
                    ColMap["seq"] = Util.dbzero(seq);
                    ColMap["seq1"] = Util.dbchar(seq1);
                    ColMap["In_team"] = "'" + nGrpID + "'";
                    ColMap["case_In_scode"] = "'" + mscode + "'";
                    ColMap["In_no"] = "'" + mno + "'";
                    ColMap["Case_no"] = "'" + RSno + "'";
                    ColMap["in_scode"] = "'" + Session["scode"] + "'";
                    ColMap["in_date"] = "getdate()";
                    ColMap["dowhat"] = Util.dbchar("");
                    ColMap["job_scode"] = Util.dbchar(signid);
                    ColMap["job_team"] = Util.dbchar(job_team);
                    ColMap["job_status"] = Util.dbchar("NN");
                    ColMap["Ctrl_date"] = Util.dbnull(ReqVal["signdate"]);
                    SQL += ColMap.GetInsertSQL();
                    conn.ExecuteNonQuery(SQL);
                }
            }
        }
    }
</script>

<%Response.Write(strOut.ToString());%>
