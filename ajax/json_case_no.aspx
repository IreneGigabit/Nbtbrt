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

    protected string case_no = "";
    protected string seq = "";
    protected string seq1 = "";
    protected string step_grade = "";
    protected string rs_no = "";

    protected void Page_Load(object sender, EventArgs e) {
        case_no = (Request["case_no"] ?? "").Trim();
        seq = (Request["seq"] ?? "").Trim();
        seq1 = (Request["seq1"] ?? "").Trim();
        step_grade = (Request["step_grade"] ?? "").Trim();
        rs_no = (Request["rs_no"] ?? "").Trim();

        DataTable dt = new DataTable();
        using (DBHelper conn = new DBHelper(Conn.btbrt).Debug(false)) {
            dt = Sys.GetCaseDmtMain(conn, seq, seq1, case_no);
            dt.Columns.Add(new DataColumn("havedata", typeof(string)));
            dt.Columns.Add(new DataColumn("nowfees", typeof(int)));
            dt.Columns.Add(new DataColumn("nowservice", typeof(int)));

            for (int i = 0; i < dt.Rows.Count; i++) {
                DataRow dr = dt.Rows[i];
                
                //若於step_fees已有該資料，讀取step_fees
                SQL = "select fees,service from fees_dmt ";
                SQL += "where rs_no='" + rs_no + "' and case_no='" + case_no + "' ";
                using (SqlDataReader sdr = conn.ExecuteReader(SQL)) {
                    if (sdr.Read()) {
                        dr["havedata"] = "Y";
                        dr["nowfees"] = Convert.ToInt32(sdr.SafeRead("fees","0"));
                        dr["nowservice"] = Convert.ToInt32(sdr.SafeRead("ar_service", "0"));
                    } else {
                        dr["havedata"] = "N";
                        dr["nowfees"] = 0;
                        dr["nowservice"] = 0;
                    }
                }
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
