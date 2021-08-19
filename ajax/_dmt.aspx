<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Text"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.IO"%>
<%@ Import Namespace = "System.Linq"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Web.Script.Serialization"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>

<script runat="server">
    protected string SQL = "";

    protected int right = 0;
    protected string prgid = "";
    protected string submitTask = "";
    protected string seq = "";
    protected string seq1 = "";
    protected string maxseq = "";
    protected string maxseq1 = "";
    protected string type = "";
    protected string branch = "";
    
    Sys sfile = new Sys();
    DBHelper conn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    DBHelper connbr = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    private void Page_Unload(System.Object sender, System.EventArgs e) {
        if (conn != null) conn.Dispose();
        if (connbr != null) connbr.Dispose();
    }

    protected void Page_Load(object sender, EventArgs e) {
        sfile.getFileServer(Sys.GetSession("SeBranch"), "brt");//檔案上傳相關設定

        prgid = (Request["prgid"] ?? "").Trim().ToLower();//brt51客收確認,brta24官收確認,brta78轉案確認
        right = Convert.ToInt32(Request["right"] ?? "0");
        submitTask = (Request["submitTask"] ?? "").Trim();
        seq = (Request["seq"] ?? "").Trim();
        seq1 = (Request["seq1"] ?? "").Trim();
        type = (Request["type"] ?? "").Trim();
        branch = Sys.GetSession("sebranch");
        if (type == "brtran") {
            branch = (Request["branch"] ?? "").Trim();
        }
            
        //2011/3/10因轉案增加連結轉出區所connection
        if (prgid == "brta78") {
            conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
            connbr = new DBHelper(Conn.brp(Request["branch"])).Debug(Request["chkTest"] == "TEST");
        } else {
            conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
            connbr = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
            if (type == "brtran") {
                conn = new DBHelper(Conn.brp(Request["branch"])).Debug(Request["chkTest"] == "TEST");
                connbr = new DBHelper(Conn.brp(Request["branch"])).Debug(Request["chkTest"] == "TEST");
            }
        }

        object objResult = null;
        if (submitTask == "A") {
            if (prgid == "brta24") {
                SQL = "select isnull(max(seq1),0)+1 new_seq1 from ext where seq='" + seq + "' and seq1 not like '%[^0-9]%'";
                objResult = conn.ExecuteScalar(SQL);
                maxseq1 = (objResult == DBNull.Value || objResult == null) ? "_" : objResult.ToString();
            }
            if (prgid == "brta78") {
                if (seq1 == "Z") {
                    SQL = "select isnull(sql,0)+1 from cust_code where code_type='Z' and cust_code='" + Session["sebranch"] + "TZ'";
                }else{
                    SQL = "select isnull(sql,0)+1 from cust_code where code_type='Z' and cust_code='" + Session["sebranch"] + "T_'";
                }
                objResult = conn.ExecuteScalar(SQL);
                maxseq = (objResult == DBNull.Value || objResult == null) ? "1" : objResult.ToString();
            }
        }
        
        var settings = new JsonSerializerSettings()
        {
            Formatting = Formatting.Indented,
            ContractResolver = new LowercaseContractResolver(),//key統一轉小寫
            Converters = new List<JsonConverter> { new DBNullCreationConverter(), new TrimCreationConverter() }//dbnull轉空字串且trim掉
        };
        
        Response.Write("{");
        Response.Write("\"dmt\":" + JsonConvert.SerializeObject(GetDmt(), settings).ToUnicode() + "\n");
        Response.Write(",\"ndmt\":" + JsonConvert.SerializeObject(GetNdmt(), settings).ToUnicode() + "\n");//交辦費用.案性
        Response.Write(",\"dmt_good\":" + JsonConvert.SerializeObject(GetDmtGood(), settings).ToUnicode() + "\n");
        Response.Write(",\"dmt_show\":" + JsonConvert.SerializeObject(GetDmtShow(), settings).ToUnicode() + "\n");
        Response.Write(",\"dmt_ap\":" + JsonConvert.SerializeObject(GetDmtAp(), settings).ToUnicode() + "\n");
        Response.Write(",\"branch\":" + JsonConvert.SerializeObject(branch, settings).ToUnicode() + "\n");
        Response.Write(",\"dept\":" + JsonConvert.SerializeObject(Sys.GetSession("dept").ToUpper(), settings).ToUnicode() + "\n");
        Response.Write(",\"maxseq\":" + JsonConvert.SerializeObject(maxseq, settings).ToUnicode() + "\n");
        Response.Write(",\"maxseq1\":" + JsonConvert.SerializeObject(maxseq1, settings).ToUnicode() + "\n");
        Response.Write("}");

        //Response.Write(JsonConvert.SerializeObject(dt, settings).ToUnicode());
    }

    #region GetDmt 案件主檔
    private DataTable GetDmt() {
        DataTable dt = new DataTable();
        dt = Sys.GetDmt(connbr, seq, seq1);
        /*
        SQL = "SELECT *,''arcasenm,''now_arcasenm,''now_statnm,''cust_name,'否'con_termnm ";
        SQL += ",''end_codenm ";
        SQL += " FROM dmt ";
        SQL += " WHERE seq='" + seq + "' and seq1='" + seq1 + "'";
        connbr.DataTable(SQL, dt);
        */
        if (dt.Rows.Count > 0) {
            if (prgid == "brta24") {
                dt.Rows[0]["arcasenm"] = getArcase(Request["rs_code"], Request["rs_type"]);
            } else {
                dt.Rows[0]["arcasenm"] = getArcase(dt.Rows[0].SafeRead("arcase", ""), dt.Rows[0].SafeRead("arcase_type", ""));
                //dt.Rows[0]["now_arcasenm"] = getArcase(dt.Rows[0].SafeRead("now_arcase", ""), dt.Rows[0].SafeRead("now_arcase_type", ""));
            }
            //dt.Rows[0]["now_statnm"] = getStatus(dt.Rows[0].SafeRead("now_stat", ""));

            //SQL = "select b.ap_cname1,b.ap_cname2,a.con_term ";
            //SQL += "from custz a inner join apcust b on a.cust_seq=b.cust_seq and a.cust_area = b.cust_area ";
            //SQL += "where a.cust_area='" + dt.Rows[0].SafeRead("cust_area", "") + "' and a.cust_seq='" + dt.Rows[0].SafeRead("cust_seq", "") + "' ";
            //using (SqlDataReader dr = connbr.ExecuteReader(SQL)) {
            //    if (dr.Read()) {
            //        dt.Rows[0]["cust_name"] = dr.SafeRead("ap_cname1", "").Trim() + dr.SafeRead("ap_cname2", "").Trim();
            //        if (dr.SafeRead("con_term", "").Trim() != "") dt.Rows[0]["con_termnm"] = "是";
            //    }
            //}
            //dt.Rows[0]["end_codenm"] = getCodeName("ENDCODE", dt.Rows[0].SafeRead("end_code", ""));
            //brt51客收確認，移轉案傳入結案原因012_已另案移轉
            if(prgid=="brt51"&&Request["end_type"]!=""){
                dt.Rows[0]["end_type"] = (Request["end_type"]??"").ToString();
            }
        }
        
        return dt;
    }
    #endregion

    #region GetNdmt 案件明細
    private DataTable GetNdmt() {
        DataTable dt = new DataTable();
        SQL = "SELECT * FROM ndmt ";
        SQL += " WHERE seq='" + seq + "' and seq1='" + seq1 + "'";
        connbr.DataTable(SQL, dt);
        
        if (dt.Rows.Count > 0) {
            dt.Rows[0]["draw_file"] = Sys.Path2Nbtbrt(dt.Rows[0].SafeRead("draw_file", ""));

            if (prgid == "brta24") {//官收確認
                dt.Rows[0]["in_no"] = "";
                dt.Rows[0]["in_scode"] = "";
            }
        }
        
        return dt;
    }
    #endregion

    #region GetDmtGood 商品類別
    private DataTable GetDmtGood() {
        DataTable dt = new DataTable();
        SQL = "select * from dmt_good where seq='" + seq + "' and seq1='" + seq1 + "' order by cast(class as int)";
        connbr.DataTable(SQL, dt);

        for (int i = 0; i < dt.Rows.Count; i++) {
            dt.Rows[i]["class"] = dt.Rows[i].SafeRead("class", "").PadLeft(2, '0');
        }
        
        return dt;
    }
    #endregion

    #region GetDmtShow 展覽優先權
    private DataTable GetDmtShow() {
        DataTable dt = new DataTable();
        SQL = "select * from dmt_show where seq='" + seq + "' and seq1='" + seq1 + "' order by show_sqlno";
        connbr.DataTable(SQL, dt);

        return dt;
    }
    #endregion

    #region GetDmtAp 案件申請人
    private DataTable GetDmtAp() {
        DataTable dt = new DataTable();
        SQL = " SELECT a.*,b.ap_country,b.apclass,b.ap_crep,b.ap_erep,b.ap_zip as ap_ap_zip ";
        SQL += ",b.ap_addr1 as ap_ap_addr1,b.ap_addr2 as ap_ap_addr2 ";
        SQL += ",b.ap_eaddr1 as ap_ap_eaddr1,b.ap_eaddr2 as ap_ap_eaddr2,b.ap_eaddr3 as ap_ap_eaddr3,b.ap_eaddr4 as ap_ap_eaddr4 ";
        SQL += "From dmt_ap a ";
        SQL += "inner join apcust b on a.apsqlno=b.apsqlno ";
        SQL += "WHERE seq='" + seq + "' and seq1='" + seq1 + "' ";
        SQL += "order by ap_sort,dmt_ap_sqlno";

        connbr.DataTable(SQL, dt);
        return dt;
    }
    #endregion

    #region getArcase 取得案性說明
    private string getArcase(string pRsCode,string pRsType) {
        SQL = "select rs_detail from code_br ";
        SQL += "where cr = 'Y' ";
        SQL += " and dept = '" + Sys.GetSession("dept") + "' ";
        SQL += " and rs_code = '" + pRsCode + "' ";
        SQL += " and rs_type = '" + pRsType + "' ";
        object objResult = conn.ExecuteScalar(SQL);
        return (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();
    }
    #endregion

    #region getStatus 取得案件狀態
    private string getStatus(string pStat) {
        SQL = "select code_name from cust_code ";
        SQL += "where code_type = 'TCase_Stat' ";
        SQL += " and cust_code = '" + pStat + "' ";
        object objResult = conn.ExecuteScalar(SQL);
        return (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();
    }
    #endregion

    #region getCodeName 取得代碼名稱
    private string getCodeName(string pCodeType,string pCustCode) {
        SQL = "select code_name from cust_code ";
        SQL += "where code_type = '" + pCodeType + "' ";
        SQL += " and cust_code = '" + pCustCode + "' ";
        object objResult = conn.ExecuteScalar(SQL);
        return (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();
    }
    #endregion
</script>
