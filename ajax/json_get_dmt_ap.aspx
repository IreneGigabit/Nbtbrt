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

    protected string seq = "";
    protected string seq1 = "";
    protected string branch = "";

    protected void Page_Load(object sender, EventArgs e) {
        seq = (Request["seq"] ?? "").Trim();
        seq1 = (Request["seq1"] ?? "").Trim();
        branch = Sys.GetSession("seBranch");

        //2011/1/25修改中英文名稱及地址抓取案件申請人檔,案件申請人無地址資料，以申請人檔為主
        SQL = "SELECT d.apsqlno,d.Server_flag,substring(d.ap_cname,1,44) as ap_cname1,substring(d.ap_cname,45,44) as ap_cname2";
        SQL += ",substring(d.ap_ename,1,60) as ap_ename1,substring(d.ap_ename,61,60) as ap_ename2,d.ap_fcname,d.ap_lcname,d.ap_fename,d.ap_lename";
        SQL += ",d.ap_sql,d.ap_zip,d.ap_addr1,d.ap_addr2,d.ap_eaddr1,d.ap_eaddr2,d.ap_eaddr3,d.ap_eaddr4,d.ap_cname,d.ap_ename";
        SQL += ",a.apcust_no,a.Apclass,a.Ap_country,a.Ap_crep,a.Ap_erep,a.Ap_addr1 as ap_ap_addr1,a.Ap_addr2 as ap_ap_addr2";
        SQL += ",a.Ap_eaddr1 as ap_ap_eaddr1,a.Ap_eaddr2 as ap_ap_eaddr2,a.Ap_eaddr3 as ap_ap_eaddr3,a.Ap_eaddr4 as ap_ap_eaddr4";
        SQL += ",a.Apatt_zip,a.Apatt_addr1,a.Apatt_addr2,a.Apatt_tel0";
        SQL += ",a.Apatt_tel,a.Apatt_tel1,a.Apatt_fax,a.Ap_zip as ap_ap_zip";
        SQL += ",(Select count(*) from dmt_ap as c where d.seq=c.seq and d.seq1=c.seq1 group by seq,seq1) as dmt_apcount";
        SQL += " From dmt_ap as d ,apcust as a ";
        SQL += " Where a.apsqlno=d.apsqlno and a.apcust_no=d.apcust_no and d.seq = '" + seq + "' and d.seq1='" + seq1 + "' and d.branch='" + branch + "'";

        DataTable dt = new DataTable();
        using (DBHelper conn = new DBHelper(Conn.btbrt).Debug(false)) {
            conn.DataTable(SQL, dt);
            
            for (int i = 0; i < dt.Rows.Count; i++) {
                if (dt.Rows[i].SafeRead("ap_sql", "") == "") {
                    dt.Rows[i]["ap_sql"] = "0";
                }
                if (dt.Rows[i].SafeRead("ap_sql", "") == "0") {
                    if (dt.Rows[i].SafeRead("ap_addr1", "") == "") {
                        dt.Rows[i]["ap_zip"] = dt.Rows[i].SafeRead("ap_ap_zip", "").Trim();
                        dt.Rows[i]["ap_addr1"] = dt.Rows[i].SafeRead("ap_ap_addr1", "").Trim();
                        dt.Rows[i]["ap_addr2"] = dt.Rows[i].SafeRead("ap_ap_addr2", "").Trim();
                        dt.Rows[i]["ap_eaddr1"] = dt.Rows[i].SafeRead("ap_ap_eaddr1", "").Trim();
                        dt.Rows[i]["ap_eaddr2"] = dt.Rows[i].SafeRead("ap_ap_eaddr2", "").Trim();
                        dt.Rows[i]["ap_eaddr3"] = dt.Rows[i].SafeRead("ap_ap_eaddr3", "").Trim();
                        dt.Rows[i]["ap_eaddr4"] = dt.Rows[i].SafeRead("ap_ap_eaddr4", "").Trim();
                    }
                }
            }
        }

        var settings = new JsonSerializerSettings()
        {
            Formatting = Formatting.Indented,
            ContractResolver = new LowercaseContractResolver(),//key統一轉小寫
            Converters = new List<JsonConverter> { new DBNullCreationConverter(), new TrimCreationConverter() }//dbnull轉空字串且trim掉
        };
        Response.Write(JsonConvert.SerializeObject(dt, settings).ToUnicode());
    }
</script>
