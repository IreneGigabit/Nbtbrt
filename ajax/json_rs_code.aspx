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
            SQL = "select * from code_br ";
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
        }
        
        var settings = new JsonSerializerSettings() {
            Formatting = Formatting.Indented,
            ContractResolver = new LowercaseContractResolver(),//key統一轉小寫
                Converters = new List<JsonConverter> { new DBNullCreationConverter(), new TrimCreationConverter() }//dbnull轉空字串且trim掉
        };

        Response.Write(JsonConvert.SerializeObject(dt, settings).ToUnicode());
    }
</script>
