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
    protected string connbr = "";
    DBHelper conn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用

    private void Page_Unload(System.Object sender, System.EventArgs e) {
        if (conn != null) conn.Dispose();
    }

    protected void Page_Load(object sender, EventArgs e) {
        SQL = Request["SQL"];
        connbr = Request["connbr"]??"";

        if (connbr != "") {
            conn = new DBHelper(Conn.brp(connbr)).Debug(false);
        } else {
            conn = new DBHelper(Conn.btbrt).Debug(false);
        }
        
        DataTable dt = new DataTable();
        conn.DataTable(SQL, dt);

        var settings = new JsonSerializerSettings()
        {
            Formatting = Formatting.Indented,
            ContractResolver = new LowercaseContractResolver(),//key統一轉小寫
            Converters = new List<JsonConverter> { new DBNullCreationConverter(), new TrimCreationConverter() }//dbnull轉空字串且trim掉
        };
        Response.Write(JsonConvert.SerializeObject(dt, settings).ToUnicode());
    }
</script>
