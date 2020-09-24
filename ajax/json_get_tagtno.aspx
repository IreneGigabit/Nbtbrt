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
        //抓取現行預設出名代理人
        //N:一般案件預設出名代理人
        //C:涉外案件預設出名代理人
        using (DBHelper conn = new DBHelper(Conn.btbrt, false)) {
            SQL = "select mark,remark,cust_code,form_name as agt_name ";
            SQL += ",(select agt_namefull from agt where agt_no=cust_code) as agt_namefull ";
            SQL += "from cust_code where code_type='Tagt_no' ";
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
