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

    protected string in_no = "";
    protected string apcust_no = "";
    protected string cust_area = "";
    protected string cust_seq = "";

    protected void Page_Load(object sender, EventArgs e) {
        in_no = (Request["in_no"] ?? "").Trim();
        apcust_no = (Request["apcust_no"] ?? "").Trim();
        cust_area = (Request["cust_area"] ?? "").Trim();
        cust_seq = (Request["cust_seq"] ?? "").Trim();

        DataTable dt_apcust = new DataTable();
        if (in_no == "") {
            GetApCust(ref dt_apcust);//申請人檔
        } else {
            GetDmtTempAp(ref dt_apcust, in_no);//交辦申請人檔
        }


        var settings = new JsonSerializerSettings()
        {
            Formatting = Formatting.Indented,
            ContractResolver = new LowercaseContractResolver(),//key統一轉小寫
            Converters = new List<JsonConverter> { new DBNullCreationConverter(), new TrimCreationConverter() }//dbnull轉空字串且trim掉
        };
        Response.Write(JsonConvert.SerializeObject(dt_apcust, settings).ToUnicode());
    }

    #region GetApCust 申請人檔
    private void GetApCust(ref DataTable dt) {
        using (DBHelper conn = new DBHelper(Conn.btbrt).Debug(false)) {
            SQL = "select *,'N'Server_flag,0 Ap_sql ";
            SQL += "from apcust ";
            SQL += "where 1=1 ";
            if (apcust_no != "") SQL += "and apcust_no='" + apcust_no + "' ";
            if (cust_area != "") SQL += "and cust_area='" + cust_area + "' ";
            if (cust_seq != "") SQL += "and cust_seq='" + cust_seq + "' ";
            SQL += "order by apsqlno ";
            conn.DataTable(SQL, dt);
        }
    }
    #endregion

    #region GetDmtTempAp 交辦申請人檔
    private void GetDmtTempAp(ref DataTable dt, string in_no) {
        using (DBHelper conn = new DBHelper(Conn.btbrt).Debug(false)) {
            SQL = "SELECT d.apsqlno,d.Server_flag,d.ap_cname1,d.ap_cname2,d.ap_ename1,d.ap_ename2,d.ap_fcname,d.ap_lcname,d.ap_fename,d.ap_lename";
            SQL += ",d.ap_sql,d.ap_zip as dmt_ap_zip,d.ap_addr1 as dmt_ap_addr1,d.ap_addr2 as dmt_ap_addr2";
            SQL += ",d.ap_eaddr1 as dmt_ap_eaddr1,d.ap_eaddr2 as dmt_ap_eaddr2,d.ap_eaddr3 as dmt_ap_eaddr3,d.ap_eaddr4 as dmt_ap_eaddr4";
            SQL += ",d.apcust_no,a.Apclass,a.Ap_country,a.Ap_crep,a.Ap_erep,a.Ap_addr1,a.Ap_addr2";//20180130改抓dmt_temp_ap.apcust_no
            SQL += ",a.Ap_eaddr1,a.Ap_eaddr2,a.Ap_eaddr3,a.Ap_eaddr4";
            SQL += ",a.Apatt_zip,a.Apatt_addr1,a.Apatt_addr2,a.Apatt_tel0";
            SQL += ",a.Apatt_tel,a.Apatt_tel1,a.Apatt_fax,a.Ap_zip";
            SQL += " From dmt_temp_ap as d  ";
            SQL += " inner join apcust as a on d.apsqlno=a.apsqlno ";
            SQL += " Where d.in_no = '" + in_no + "' and d.case_sqlno=0 ";
            SQL += " order by d.ap_sort,temp_ap_sqlno ";
            conn.DataTable(SQL, dt);

            for (int i = 0; i < dt.Rows.Count; i++) {
                //因交辦案件申請人先前無中英文地址，當無申請人序號，則依申請人檔資料顯示
                //若申請人序號>=0，則以交辦案件申請人為準
                if (dt.Rows[i].SafeRead("ap_sql", "") == "") {
                    dt.Rows[i]["ap_sql"] = "0";
                } else {
                    dt.Rows[i]["ap_zip"] = dt.Rows[i].SafeRead("dmt_ap_zip", "").Trim();
                    dt.Rows[i]["ap_addr1"] = dt.Rows[i].SafeRead("dmt_ap_addr1", "").Trim();
                    dt.Rows[i]["ap_addr2"] = dt.Rows[i].SafeRead("dmt_ap_addr2", "").Trim();
                    dt.Rows[i]["ap_eaddr1"] = dt.Rows[i].SafeRead("dmt_ap_eaddr1", "").Trim();
                    dt.Rows[i]["ap_eaddr2"] = dt.Rows[i].SafeRead("dmt_ap_eaddr2", "").Trim();
                    dt.Rows[i]["ap_eaddr3"] = dt.Rows[i].SafeRead("dmt_ap_eaddr3", "").Trim();
                    dt.Rows[i]["ap_eaddr4"] = dt.Rows[i].SafeRead("dmt_ap_eaddr4", "").Trim();
                }
            }
        }
    }
    #endregion
</script>
