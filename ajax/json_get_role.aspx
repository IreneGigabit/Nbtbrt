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
        string branch = Request["branch"] ?? Session["SeBranch"].ToString();
        string dept = Request["dept"] ?? Session["Dept"].ToString();
        string syscode = Request["syscode"] ?? Session["Syscode"].ToString();
        string role = Request["role"] ?? "";
        string submittask = Request["submittask"] ?? "Q";

        DataTable dt = new DataTable();
        using (DBHelper cnn = new DBHelper(Conn.Sysctrl, false)) {
            SQL = "select distinct scode,sc_name,scode1  ";
            SQL += "from vscode_roles";
            SQL += "where branch='" + branch + "' and dept='" + dept + "' and syscode='" + syscode + "' and roles='" + role + "' ";
            if (submittask == "A") {
                SQL += "and (end_date is null or end_date>convert(date,getDate()))";
            }
            SQL += "order by scode1 ";
            cnn.DataTable(SQL, dt);
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
