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

        JArray jarr = null;
        using (DBHelper conn = new DBHelper(Conn.btbrt, false)) {
            DataTable dt = new DataTable();
            
            string isql = "";
            if (case_no != "") isql = "select in_no from case_dmt where case_no = '" + case_no + "'";
            if (in_no != "") isql = "'" + in_no + "'";

            SQL = "select '1'sort, seq,seq1,'0' as case_sqlno from case_dmt where in_no in (" + isql + ")";
            SQL += " union ";
            SQL += " select '2'sort, seq,seq1,case_sqlno from case_dmt1 where in_no in (" + isql + ")";
            SQL += " order by sort,seq,seq1 ";
            conn.DataTable(SQL, dt);

            jarr = JArray.FromObject(dt);
            foreach (var item in jarr.ToArray()) {
                DataTable dt0 = new DataTable();
                SQL = "select '1' as sort,s_mark,appl_name,apply_no,issue_no,class,''s_marknm from dmt_temp where in_no ='" + item["in_no"] + "' and case_sqlno = '" + item["case_sqlno"] + "' ";
                SQL += "union ";
                SQL += "select '2' as sort,s_mark,appl_name,apply_no,issue_no,class,''s_marknm from dmt where seq='" + item["seq"] + "' and seq1='" + item["seq1"] + "' ";
                SQL += "order by sort ";
                conn.DataTable(SQL, dt0);
                for (int i = 0; i < dt0.Rows.Count; i++) {
                    DataRow dr = dt0.Rows[i];
                    if (dr.SafeRead("s_mark", "") == "S") {
                        dr["s_marknm"] = "服務";
                    } else if (dr.SafeRead("s_mark", "") == "L") {
                        dr["s_marknm"] = "證明";
                    } else if (dr.SafeRead("s_mark", "") == "M") {
                        dr["s_marknm"] = "團體標章";
                    } else if (dr.SafeRead("s_mark", "") == "N") {
                        dr["s_marknm"] = "團體商標";
                    } else if (dr.SafeRead("s_mark", "") == "K") {
                        dr["s_marknm"] = "產地證明標章";
                    } else {
                        dr["s_marknm"] = "商標";
                    }
                }
                item["get_dmt"] = JArray.FromObject(dt0);
            }
        }
        var settings = new JsonSerializerSettings()
        {
            Formatting = Formatting.Indented,
            ContractResolver = new LowercaseContractResolver(),//key統一轉小寫
            Converters = new List<JsonConverter> { new DBNullCreationConverter(), new TrimCreationConverter() }//dbnull轉空字串且trim掉
        };

        Response.Write(JsonConvert.SerializeObject(jarr, settings).ToUnicode());
    }
</script>
