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

    protected string rs_type = "";
    protected string cg = "";
    protected string rs = "";

    protected void Page_Load(object sender, EventArgs e) {
        rs_type = Request["rs_type"] ?? "";
        cg = Request["cg"] ?? "";
        rs = Request["rs"] ?? "";

        DataTable dt = new DataTable();
        using (DBHelper conn = new DBHelper(Conn.btbrt, false)) {
            SQL = "select * from cust_code ";
            SQL += " where code_type='" + rs_type + "' and mark is null ";
            SQL += " and cust_code in (select rs_class from vcode_act where cg ='" + cg + "' and rs = '" + rs + "' and rs_type='" + rs_type + "') ";
            SQL += " order by cust_code";

            conn.DataTable(SQL, dt);
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
