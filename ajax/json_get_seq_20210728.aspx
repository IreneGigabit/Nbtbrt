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

    protected string case_no = "";
    protected string in_no = "";

    protected void Page_Load(object sender, EventArgs e) {
        case_no = Request["case_no"] ?? "";
        in_no = Request["in_no"] ?? "";

        DataTable dt = new DataTable();
        using (DBHelper conn = new DBHelper(Conn.btbrt, false)) {
            string isql = "";
            if (case_no != "") isql = "select in_no from case_dmt where case_no = '" + case_no + "'";
            if (in_no != "") isql = "'" + in_no + "'";

            SQL = "select '1'sort, seq,seq1,'0' as case_sqlno from case_dmt where in_no in (" + isql + ")";
            SQL += " union ";
            SQL += " select '2'sort, seq,seq1,case_sqlno from case_dmt1 where in_no in (" + isql + ")";
            SQL += " order by sort,seq,seq1 ";
            Sys.showLog(SQL);   
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
