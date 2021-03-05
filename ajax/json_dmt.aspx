<%@ Page Language="C#" CodePage="65001"%>
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

    protected string prgid = "";
    protected string seq = "";
    protected string seq1 = "";
    protected string cust_area = "";
    protected string cust_seq = "";

    protected void Page_Load(object sender, EventArgs e) {
        prgid = (Request["prgid"] ?? "");
        seq = (Request["seq"] ?? "");
        seq1 = (Request["seq1"] ?? "");
        //cust_area = (Request["cust_area"] ?? "");
        //cust_seq = (Request["cust_seq"] ?? "");

        using (DBHelper conn = new DBHelper(Conn.btbrt).Debug(false)) {
            DataTable dt = new DataTable();
            dt = Sys.GetDmt(conn, seq, seq1);
            
            /*
            SQL = "select seq,seq1,s_mark,appl_name,apply_no,issue_no,end_date,''smarknm ";
            SQL += " from dmt where seq=" + seq;
            SQL += " and seq1='" + seq1 + "' ";
            if (cust_area != "") SQL += " and cust_area='" + cust_area + "' ";
            if (cust_seq != "") SQL += " and cust_seq='" + cust_seq + "'";
            
            DataTable dt = new DataTable();
            conn.DataTable(SQL, dt);

            for (int i = 0; i < dt.Rows.Count; i++) {
                switch (dt.Rows[i].SafeRead("s_mark", "")) {
                    case "S": dt.Rows[i]["smarknm"] = "92年修正前服務標章"; break;
                    case "L": dt.Rows[i]["smarknm"] = "證明標章"; break;
                    case "N": dt.Rows[i]["smarknm"] = "團體商標"; break;
                    case "M": dt.Rows[i]["smarknm"] = "團體標章"; break;
                    default: dt.Rows[i]["smarknm"] = "商標"; break;
                }
            }*/

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
