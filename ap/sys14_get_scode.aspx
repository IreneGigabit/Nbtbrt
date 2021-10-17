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

    protected string query = "";

    protected void Page_Load(object sender, EventArgs e) {
        query = Request["query"] ?? "";

        DataTable dt = new DataTable();
        using (DBHelper cnn = new DBHelper(Conn.Sysctrl, false)) {
            SQL = "select scode value,sc_name data from scode where (sc_name like '%" + query + "%' or scode like '%" + query + "%') order by scode ";

            cnn.DataTable(SQL, dt);
        }

        var settings = new JsonSerializerSettings()
        {
            Formatting = Formatting.Indented,
            ContractResolver = new LowercaseContractResolver(),//key統一轉小寫
            Converters = new List<JsonConverter> { new DBNullCreationConverter(), new TrimCreationConverter() }//dbnull轉空字串且trim掉
        };

        //Response.Write(JsonConvert.SerializeObject(dt, settings).ToUnicode());
        Response.Write("{");
        Response.Write("\"suggestions\":" + JsonConvert.SerializeObject(dt, settings).ToUnicode() + "\n");
        Response.Write("}");
    }
</script>
