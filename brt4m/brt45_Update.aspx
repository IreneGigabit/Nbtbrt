<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Linq"%>

<script runat="server">
    protected string HTProgCap = "提撥捐款基金會調整資料入檔";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = HttpContext.Current.Request["prgid"] ?? "";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";

    protected string submitTask = "";
    protected string SQL = "";
    protected object objResult = null;

    protected string logReason = "Brt45提撥捐款基金會調整資料入檔";
    protected string qrybranch = "", qrystep_yy = "", qrystep_mm = "", chknum="";

    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected Dictionary<string, string> ColMap = new Dictionary<string, string>();

    protected StringBuilder strOut = new StringBuilder();

    DBHelper connacc = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    private void Page_Unload(System.Object sender, System.EventArgs e) {
        if (connacc != null) connacc.Dispose();
    }

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");

        submitTask = ReqVal.TryGet("submittask").ToUpper();
        qrybranch = ReqVal.TryGet("qrybranch");
        qrystep_yy = ReqVal.TryGet("qrystep_yy");
        qrystep_mm = ReqVal.TryGet("qrystep_mm");
        chknum = ReqVal.TryGet(qrybranch + "cnti");

        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        HTProgCap = myToken.Title;
        DebugStr = myToken.DebugStr;
        if (HTProgRight >= 0) {
            try {
                connacc = new DBHelper(Conn.account).Debug(Request["chkTest"] == "TEST");

                if (submitTask == "A") {
                    doAdd();
                    strOut.AppendLine("<div align='center'><h1>調整檔產生成功!!!</h1></div>");
                } else if (submitTask == "D") {
                    doDel();
                    strOut.AppendLine("<div align='center'><h1>調整檔刪除成功!!!</h1></div>");
                }
                connacc.Commit();
                //connacc.RollBack();
            }
            catch (Exception ex) {
                connacc.RollBack();
                Sys.errorLog(ex, connacc.exeSQL, prgid);
                if (submitTask == "A") {
                    //strOut.AppendLine("<div align='center'><h1>調整檔產生失敗("+ex.Message+")</h1></div>");
                } else if (submitTask == "D") {
                    //strOut.AppendLine("<div align='center'><h1>調整檔刪除失敗("+ex.Message+")</h1></div>");
                }
                throw;
            }

            this.DataBind();
        }
    }

    /// <summary>
    /// 新增調整資料
    /// </summary>
    private void doAdd() {
        //檢查是否已產生調整資料
        SQL = "select count(*) from account.dbo.acct_plus ";
        SQL += " where plus_date >='" + DateTime.Today.ToString("yyyy/M/1") + "'";
        SQL += " and plus_date<='" + DateTime.Today.AddMonths(1).AddDays(-DateTime.Today.AddMonths(1).Day).ToShortDateString() + "'";
        SQL += " and class='F' and branch='" + qrybranch + "' and dept='T' ";
        connacc.ExecuteNonQuery(SQL);
        objResult = connacc.ExecuteScalar(SQL);
        int cnt = (objResult == DBNull.Value || objResult == null) ? 0 : Convert.ToInt32(objResult);
        if (cnt > 0) {
            connacc.RollBack();
            strOut.AppendLine("<div align='center'><h1>該年月已產生調整資料，請檢查!!!</h1></div>");
        } else {
            for (int i = 1; i <= Convert.ToInt32("0" + chknum); i++) {
                string scode = ReqVal.TryGet(qrybranch + "scode" + i);
                string nt_money = ReqVal.TryGet(qrybranch + "totmoney" + i);
                string totcnt = ReqVal.TryGet(qrybranch + "totcnt" + i);

                //XX月BranchDept提撥捐款聖島基金會薪號x##件x@單價,ex:10月NT提撥捐款聖島基金會n1350x34件x@100
                string remark = qrystep_mm + "月" + qrybranch + "T提撥捐款聖島基金會" + scode + "x" + totcnt + "件x@" + Request[qrybranch + "fund_money"];

                SQL = "insert into account.dbo.acct_plus ";
                ColMap.Clear();
                ColMap["in_prgid"] = Util.dbchar(prgid);
                ColMap["class"] = Util.dbchar("F");
                ColMap["plus_no"] = Util.dbzero("0");
                ColMap["plus_date"] = Util.dbchar(DateTime.Today.ToShortDateString());
                ColMap["branch"] = Util.dbchar(qrybranch);
                ColMap["dept"] = Util.dbchar("T");
                ColMap["scode"] = Util.dbchar(scode);
                ColMap["dc_code"] = Util.dbchar("1");
                ColMap["acc_code"] = Util.dbchar("4T03");
                ColMap["acc_code1"] = Util.dbchar("0000");
                ColMap["nt_money"] = Util.dbzero(nt_money);
                ColMap["mark_code"] = Util.dbchar("413");
                ColMap["remark"] = Util.dbchar(remark);
                ColMap["mark"] = Util.dbchar("6");
                ColMap["from_flag"] = Util.dbchar(prgid);
                ColMap["tran_date"] = "getdate()";
                ColMap["tran_scode"] = Util.dbchar(Sys.GetSession("scode"));
                SQL += ColMap.GetInsertSQL();
                connacc.ExecuteNonQuery(SQL);
            }
        }
    }

    /// <summary>
    /// 刪除調整資料
    /// </summary>
    private void doDel() {
        //檢查調整資料是否已轉UNIX
        SQL = "select count(*) from account.dbo.acct_plus ";
        SQL += " where plus_date >='" + DateTime.Today.ToString("yyyy/M/1") + "'";
        SQL += " and plus_date<='" + DateTime.Today.AddMonths(1).AddDays(-DateTime.Today.AddMonths(1).Day).ToShortDateString() + "'";
        SQL += " and class='F' and branch='" + qrybranch + "' and dept='T' and acc_sqlno<>0 ";
        connacc.ExecuteNonQuery(SQL);
        objResult = connacc.ExecuteScalar(SQL);

        int cnt = (objResult == DBNull.Value || objResult == null) ? 0 : Convert.ToInt32(objResult);
        if (cnt > 0) {
            connacc.RollBack();
            strOut.AppendLine("<div align='center'><h1>該年月調整資料已轉入UNIX，無法刪除，請檢查!!!</h1></div>");
        } else {
            //逐筆抓取當月資料並刪除
            SQL = "select acct_plus_sqlno from account.dbo.acct_plus ";
            SQL += " where plus_date >='" + DateTime.Today.ToString("yyyy/M/1") + "'";
            SQL += " and plus_date<='" + DateTime.Today.AddMonths(1).AddDays(-DateTime.Today.AddMonths(1).Day).ToShortDateString() + "'";
            SQL += " and class='F' and branch='" + qrybranch + "' and dept='T' and acc_sqlno=0 ";
            DataTable dt = new DataTable();
            connacc.DataTable(SQL, dt);
            for (int i = 0; i < dt.Rows.Count; i++) {
                DataRow dr = dt.Rows[i];
                //入acct_plus_log
                Sys.insert_log_table(connacc, "D", prgid, "acct_plus", "acct_plus_sqlno", dr.SafeRead("acct_plus_sqlno", ""), logReason);
                //刪除acct_plus
                SQL = "delete from account.dbo.acct_plus where acct_plus_sqlno=" + dr["acct_plus_sqlno"];
                connacc.ExecuteNonQuery(SQL);
            }
        }
    }
</script>

<%Response.Write(strOut.ToString());%>


