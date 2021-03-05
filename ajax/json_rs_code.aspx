<%@ Page Language="C#" CodePage="65001" AutoEventWireup="true"  %>
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

    protected string cgrs = "";
    protected string rs_type = "";
    protected string rs_class = "";
    protected string submittask = "";

    protected void Page_Load(object sender, EventArgs e) {
        cgrs = Request["cgrs"] ?? "";
        rs_type = Request["rs_type"] ?? "";
        rs_class = Request["rs_class"] ?? "";
        submittask = (Request["submittask"] ?? "").ToUpper();

        DataTable dt = new DataTable();
        using (DBHelper conn = new DBHelper(Conn.btbrt, false)) {
            SQL = "select *,0 service,0 fees,0 ar_service,0 ar_fees,0 others,0 ar_others from code_br ";
            SQL += " where dept='" + Sys.GetSession("dept") + "' and rs_type = '" + rs_type + "'";
            if (cgrs != "") {
                SQL += " and " + cgrs + "='Y' ";
            }
            if (rs_class != "") {
                SQL += " and rs_class='" + rs_class + "' ";
            }
            if (submittask == "A") {
                SQL += " and (end_date is null or end_date = '' or end_date > getdate()) ";
            }
            SQL += " ORDER BY rs_class,rs_code";
            conn.DataTable(SQL, dt);

            for (int i = 0; i < dt.Rows.Count; i++) {
                DataRow dr = dt.Rows[i];
                
                //現行收費標準
                SQL = "select * from case_fee ";
                SQL += "where dept='T' and country='T' and rs_code='" + dr["rs_code"] + "' ";
                SQL += "and (getdate() between beg_date and end_date) ";
                using (SqlDataReader sdr = conn.ExecuteReader(SQL)) {
                    if (sdr.Read()) {
                        dr["service"] = sdr["service"];
                        dr["fees"] = sdr["fees"];
                        dr["ar_service"] = sdr["ar_service"];
                        dr["ar_fees"] = sdr["ar_fees"];
                        dr["others"] = sdr["others"];
                        dr["ar_others"] = sdr["ar_others"];
                    }
                }
            }
        }
    
        var settings = new JsonSerializerSettings() {
            Formatting = Formatting.Indented,
            ContractResolver = new LowercaseContractResolver(),//key統一轉小寫
                Converters = new List<JsonConverter> { new DBNullCreationConverter(), new TrimCreationConverter() }//dbnull轉空字串且trim掉
        };

        Response.Write(JsonConvert.SerializeObject(dt, settings).ToUnicode());
    }
</script>
