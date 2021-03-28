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
    protected string in_no = "";

    protected void Page_Load(object sender, EventArgs e) {
        prgid = (Request["prgid"] ?? "").Trim();
        in_no = (Request["in_no"] ?? "").Trim();//接洽序號

        DataTable dt = new DataTable();
        JArray jarr = new JArray();
        using (DBHelper conn = new DBHelper(Conn.btbrt).Debug(false)) {
            dt = Sys.GetCaseDmt1(conn, in_no);

            //對應案件主檔/交辦暫存檔
            jarr = JArray.FromObject(dt);
            foreach (var item in jarr.ToArray()) {
                DataTable dt0 = new DataTable();
                SQL = "select '1' as sort,s_mark,appl_name,apply_no,issue_no,class,''s_marknm from dmt_temp where in_no ='" + item["in_no"] + "' and case_sqlno = '" + item["case_sqlno"] + "' ";
                SQL += "union ";
                SQL += "select '2' as sort,s_mark,appl_name,apply_no,issue_no,class,''s_marknm from dmt where seq='" + item["seq"] + "' and seq1='" + item["seq1"] + "' ";
                SQL += "order by sort ";
                conn.DataTable(SQL, dt0);
                for (int i = 0; i < dt0.Rows.Count; i++) {
                    if (dt0.Rows[i].SafeRead("s_mark", "") == "S") {
                        dt0.Rows[i]["s_marknm"] = "服務";
                    } else if (dt0.Rows[i].SafeRead("s_mark", "") == "L") {
                        dt0.Rows[i]["s_marknm"] = "證明";
                    } else if (dt0.Rows[i].SafeRead("s_mark", "") == "M") {
                        dt0.Rows[i]["s_marknm"] = "團體標章";
                    } else if (dt0.Rows[i].SafeRead("s_mark", "") == "N") {
                        dt0.Rows[i]["s_marknm"] = "團體商標";
                    } else if (dt0.Rows[i].SafeRead("s_mark", "") == "K") {
                        dt0.Rows[i]["s_marknm"] = "產地證明標章";
                    } else {
                        dt0.Rows[i]["s_marknm"] = "商標";
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
