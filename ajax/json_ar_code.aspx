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

    protected void Page_Load(object sender, EventArgs e) {
        DataTable dt = new DataTable();
        using (DBHelper connacc = new DBHelper(Conn.account, false)) {
            SQL = "SELECT * from ar_code ";
            SQL += "where code_type = '" + Request["code_type"] + "' ";
            SQL += "and branch='" + Request["branch"] + "' ";
            SQL += "and dept='" + Request["dept"] + "' ";
            SQL += "and ar_code='" + Request["ar_code"] + "'";
            connacc.DataTable(SQL, dt);

            for (int i = 0; i < dt.Rows.Count; i++) {
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
