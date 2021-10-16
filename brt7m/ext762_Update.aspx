<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Linq"%>

<script runat="server">
    protected string HTProgCap = "預計請款記錄-入檔";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "ext762";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";

    protected string submitTask = "";
    protected string SQL = "";
    protected object objResult = null;

    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected Dictionary<string, string> ColMap = new Dictionary<string, string>();

    protected string logReason = "ext762預計請款記錄";

    string[] arr_prear_sqlno,arr_in_scode,arr_in_no,arr_case_no,arr_seq,arr_seq1,arr_country,arr_service,arr_fees,arr_tr_money;
    string[] arr_add_service,arr_add_fees,arr_ar_service,arr_ar_fees,arr_hchk_flag,arr_prear_date,arr_noar_code,arr_noar_remark;

    protected string tr_yy = "", tr_mm = "", msg="";
    protected List<string> tin_scode = new List<string>();

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
        
        arr_prear_sqlno= ReqVal.TryGet("rows_prear_sqlno").Split('\f');
        arr_in_scode= ReqVal.TryGet("rows_in_scode").Split('\f');
        arr_in_no= ReqVal.TryGet("rows_in_no").Split('\f');
        arr_case_no= ReqVal.TryGet("rows_case_no").Split('\f');
        arr_seq= ReqVal.TryGet("rows_seq").Split('\f');
        arr_seq1= ReqVal.TryGet("rows_seq1").Split('\f');
        arr_country= ReqVal.TryGet("rows_country").Split('\f');
        arr_service= ReqVal.TryGet("rows_service").Split('\f');
        arr_fees= ReqVal.TryGet("rows_fees").Split('\f');
        arr_tr_money= ReqVal.TryGet("rows_tr_money").Split('\f');
        arr_add_service= ReqVal.TryGet("rows_add_service").Split('\f');
        arr_add_fees= ReqVal.TryGet("rows_add_fees").Split('\f');
        arr_ar_service= ReqVal.TryGet("rows_ar_service").Split('\f');
        arr_ar_fees= ReqVal.TryGet("rows_ar_fees").Split('\f');
        arr_hchk_flag= ReqVal.TryGet("rows_hchk_flag").Split('\f');
        arr_prear_date= ReqVal.TryGet("rows_prear_date").Split('\f');
        arr_noar_code= ReqVal.TryGet("rows_noar_code").Split('\f');
        arr_noar_remark= ReqVal.TryGet("rows_noar_remark").Split('\f');

        tr_yy = ReqVal.TryGet("tr_yy");
        tr_mm = ReqVal.TryGet("tr_mm");

        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        HTProgCap = myToken.Title;
        DebugStr = myToken.DebugStr;
        if (HTProgRight >= 0) {
            try {
                conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");

                for (int i = 1; i < arr_hchk_flag.Length; i++) {
                    if (arr_hchk_flag[i] == "Y") {
                        int prear_sqlno = Convert.ToInt32(arr_prear_sqlno[i]);

                        if (prear_sqlno ==0) {
                            Insert_prear_brt(i);//新增prear_brt
                        } else {
                            if (prear_sqlno >0) {
                                Update_prear_brt(prear_sqlno,i);//修改prear_brt
                            }
                        }
                    }
                }

                msg = "預計請款記錄存檔成功";
                //strOut.AppendLine("<div align='center'><h1>預計請款記錄存檔成功</h1></div>");
                //conn.Commit();
                conn.RollBack();
            }
            catch (Exception ex) {
                conn.RollBack();
                Sys.errorLog(ex, conn.exeSQL, prgid);
                msg = "預計請款記錄存檔失敗";
                //strOut.AppendLine("<div align='center'><h1>預計請款記錄存檔失敗("+ex.Message+")</h1></div>");
                throw;
            }
            finally {
                conn.Dispose();
            }
            this.DataBind();
        }
    }

    /// <summary>
    /// 新增prear_brt
    /// </summary>
    private void Insert_prear_brt(int pno) {
        SQL = "insert into prear_brt ";
        ColMap.Clear();
        ColMap["tr_yy"] = Util.dbchar(tr_yy);
        ColMap["tr_mm"] = Util.dbchar(tr_mm);
        ColMap["input_scode"] = "'" + Session["scode"] + "'";
        ColMap["input_date"] = "getdate()";
        ColMap["in_scode"] = Util.dbchar(arr_in_scode[pno]);
        ColMap["in_no"] = Util.dbchar(arr_in_no[pno]);
        ColMap["case_no"] = Util.dbchar(arr_case_no[pno]);
        ColMap["seq"] = Util.dbnull(arr_seq[pno]);
        ColMap["seq1"] = Util.dbchar(arr_seq1[pno]);
        ColMap["country"] = Util.dbchar(arr_country[pno]);
        ColMap["service"] = Util.dbzero(arr_service[pno]);
        ColMap["fees"] = Util.dbzero(arr_fees[pno]);
        ColMap["tr_money"] = Util.dbzero(arr_tr_money[pno]);
        ColMap["add_service"] = Util.dbzero(arr_add_service[pno]);
        ColMap["add_fees"] = Util.dbzero(arr_add_fees[pno]);
        ColMap["ar_service"] = Util.dbzero(arr_ar_service[pno]);
        ColMap["ar_fees"] = Util.dbzero(arr_ar_fees[pno]);
        ColMap["prear_date"] = Util.dbnull(arr_prear_date[pno]);
        ColMap["noar_code"] = Util.dbchar(arr_noar_code[pno]);
        ColMap["noar_remark"] = Util.dbchar(arr_noar_remark[pno]);
        ColMap["invoice_mark"] = Util.dbchar(ReqVal.TryGet("qryinvoice_mark"));
        SQL += ColMap.GetInsertSQL();
        conn.ExecuteNonQuery(SQL);

        //抓insert後的流水號
        SQL = "SELECT SCOPE_IDENTITY() AS Current_Identity";
        object objResult1 = conn.ExecuteScalar(SQL);
        string GetPrear_sqlno = objResult1.ToString();

        SQL = "update " + Request["case_Table"] + " ";
        SQL += "set prear_sqlno='" + GetPrear_sqlno + "'";
        SQL += ",prear_date=" + Util.dbnull(arr_prear_date[pno]);
        SQL += " where in_no=" + Util.dbchar(arr_in_no[pno]) + " ";
        SQL += " and in_scode=" + Util.dbchar(arr_in_scode[pno]) + " ";
        conn.ExecuteNonQuery(SQL);
    }

    /// <summary>
    /// 修改prear_brt
    /// </summary>
    private void Update_prear_brt(int prear_sqlno, int pno) {
        SQL = "update prear_brt set ";
        ColMap.Clear();
        ColMap["prear_date"] = Util.dbnull(arr_prear_date[pno]);
        ColMap["noar_code"] = Util.dbchar(arr_noar_code[pno]);
        ColMap["noar_remark"] = Util.dbchar(arr_noar_remark[pno]);
        ColMap["service"] = Util.dbzero(arr_service[pno]);
        ColMap["fees"] = Util.dbzero(arr_fees[pno]);
        ColMap["tr_money"] = Util.dbzero(arr_tr_money[pno]);
        ColMap["add_service"] = Util.dbzero(arr_add_service[pno]);
        ColMap["add_fees"] = Util.dbzero(arr_add_fees[pno]);
        ColMap["ar_service"] = Util.dbzero(arr_ar_service[pno]);
        ColMap["ar_fees"] = Util.dbzero(arr_ar_fees[pno]);
        SQL += ColMap.GetUpdateSQL();
        SQL += " where sqlno=" + prear_sqlno + "";
        conn.ExecuteNonQuery(SQL);

        SQL = "update " + Request["case_Table"] + " ";
        SQL += "set prear_sqlno='" + prear_sqlno + "'";
        SQL += ",prear_date=" + Util.dbnull(arr_prear_date[pno]);
        SQL += " where in_no=" + Util.dbchar(arr_in_no[pno]) + " ";
        SQL += " and in_scode=" + Util.dbchar(arr_in_scode[pno]) + " ";
        conn.ExecuteNonQuery(SQL);
    }
</script>

<div align='center' style="color:red">
    <h3><%=msg%></h3>
    <input type=button name="button1" value ="返回清單" class="cbutton" onClick="ext762submit()">
    <%if (ReqVal.TryGet("qryin_scode")!="") {%>
    <input type=button name="button1" value ="產生word檔" class="cbutton" onClick="ext762print()">
    <%}%>
    <BR><BR><BR>
</div>

