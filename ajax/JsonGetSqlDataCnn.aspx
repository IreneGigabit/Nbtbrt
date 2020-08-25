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
    protected string mg = "";
    
    protected void Page_Load(object sender, EventArgs e)
    {
        mg = Request["mg"] ?? "";
        string connstr = Conn.Sysctrl;
        if (mg != "") connstr = Conn.ODBCDSN;
        using (DBHelper cnn = new DBHelper(connstr).Debug(false))
        {
            SQL = Request["SQL"];
            DataTable dt = new DataTable();
            cnn.DataTable(SQL, dt);

            var settings = new JsonSerializerSettings()
            {
                Formatting = Formatting.Indented,
                ContractResolver = new LowercaseContractResolver(),//key統一轉小寫
                Converters = new List<JsonConverter> { new DBNullCreationConverter(), new TrimCreationConverter() }//dbnull轉空字串且trim掉
            };
            Response.Write(JsonConvert.SerializeObject(dt, settings).ToUnicode());
        }
    }
</script>
