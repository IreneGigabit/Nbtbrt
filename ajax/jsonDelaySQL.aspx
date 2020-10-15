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
    protected string type = "";
    protected string delay_seq = "";
    protected string delay_seq1 = "";
    protected string delay_arcase = "";
    protected string cust_area = "";
    protected string cust_seq = "";

    protected void Page_Load(object sender, EventArgs e) {
        prgid = (Request["prgid"] ?? "").Trim();
        type = (Request["type"] ?? "").Trim().ToLower();
        delay_seq = (Request["delay_seq"] ?? "").Trim();
        delay_seq1 = (Request["delay_seq1"] ?? "").Trim();
        delay_arcase = (Request["delay_arcase"] ?? "").Trim();
        cust_area = (Request["cust_area"] ?? "").Trim();
        cust_seq = (Request["cust_seq"] ?? "").Trim();

        var settings = new JsonSerializerSettings() {
            Formatting = Formatting.Indented,
            ContractResolver = new LowercaseContractResolver(),//key統一轉小寫
            Converters = new List<JsonConverter> { new DBNullCreationConverter(), new TrimCreationConverter() }//dbnull轉空字串且trim掉
        };
        Response.Write("{");
        Response.Write("\"vdmtall\":" + JsonConvert.SerializeObject(GetDmt(), settings).ToUnicode() + "\n");
        Response.Write(",\"dmt_good\":" + JsonConvert.SerializeObject(GetDmtGood(), settings).ToUnicode() + "\n");
        Response.Write("}");
    }

    #region GetDmt 主檔
    private DataTable GetDmt() {
        DataTable dt = new DataTable();
        using (DBHelper conn = new DBHelper(Conn.btbrt).Debug(false)) {
            if (type == "ref_no") {
                SQL = "SELECT *,''dmt_temp_remark3 ";
                SQL = ",(select agt_name from agt where agt_no=vdmtall.agt_no) as agt_name ";
                SQL += "FROM vdmtall ";
                SQL += "where seq=" + delay_seq + " ";
                SQL += "and seq1='" + delay_seq1 + "' ";
            } else {
                SQL = "SELECT *,''dmt_temp_remark3 ";
                SQL = ",(select agt_name from agt where agt_no=vdmtall.agt_no) as agt_name ";
                SQL += "FROM vdmtall ";
                SQL += "where seq=" + delay_seq + " ";
                SQL += "and seq1='" + delay_seq1 + "' ";
                SQL += "and cust_area='" + cust_area + "' ";
                SQL += "and cust_seq=" + cust_seq + " ";
            }
            conn.DataTable(SQL, dt);

            for (int i = 0; i < dt.Rows.Count; i++) {
                SQL = "SELECT remark3 FROM dmt_temp as a ";
                SQL += "inner join case_dmt as b on a.in_no=b.in_no and a.in_scode=b.in_scode and b.arcase='" + delay_arcase + "' ";
                SQL += "where a.seq=" + delay_seq + " and a.seq1='" + delay_seq1 + "' ";
                SQL += "order by a.in_no desc";
                using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
                    if (dr.Read()) {
                        dt.Rows[i]["dmt_temp_remark3"] = dr.SafeRead("remark3", "");
                    }
                }
            }
        }

        return dt;
    }
    #endregion
    
    #region GetDmtGood 商品檔
    private DataTable GetDmtGood() {
        DataTable dt = new DataTable();
        using (DBHelper conn = new DBHelper(Conn.btbrt).Debug(false)) {
            SQL = "SELECT * ";
            SQL += "FROM dmt_good ";
            SQL += "where seq=" + delay_seq + " ";
            SQL += "and seq1='" + delay_seq1 + "' ";
            conn.DataTable(SQL, dt);
        }
        return dt;
    }
    #endregion

</script>
