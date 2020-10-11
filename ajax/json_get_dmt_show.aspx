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
    protected string branch = "";
    protected string seq = "";
    protected string seq1 = "";
    protected string in_no = "";
    protected string case_sqlno = "";
    protected string datasource = "";
    protected string in_scode = "";
    protected string cust_area = "";
    protected string cust_seq = "";
    protected string num = "";
    protected string mark = "";

    protected void Page_Load(object sender, EventArgs e) {
        prgid = (Request["prgid"] ?? "").Trim();
        branch = (Request["branch"] ?? "").Trim();
        seq = (Request["seq"] ?? "").Trim();
        seq1 = (Request["seq1"] ?? "").Trim();
        in_no = (Request["in_no"] ?? "").Trim();//接洽序號
        case_sqlno = (Request["case_sqlno"] ?? "").Trim();
        datasource = (Request["datasource"] ?? "").Trim();
        //接洽子案所傳參數
        in_scode = (Request["in_scode"] ?? "").Trim();
        cust_area = (Request["cust_area"] ?? "").Trim();
        cust_seq = (Request["cust_seq"] ?? "").Trim();
        num = (Request["num"] ?? "").Trim();
        mark = (Request["mark"] ?? "").Trim();

        if (datasource == "case") {//接洽
            SQL = "select * ";
            SQL += "from casedmt_show ";
            SQL += "where in_no='" + in_no + "' ";
            if (case_sqlno != "") {
                SQL += " and case_sqlno=" + case_sqlno + " ";
            }
            SQL += " order by show_sqlno ";
        } else if (datasource == "case_change") {
            SQL = "select *,show_no show_sqlno ";
            SQL += " from casedmt_show_change ";
            SQL += " where in_scode='" + in_scode + "'";
            SQL += " and cust_area='" + cust_area + "'";
            SQL += " and cust_seq='" + cust_seq + "'";
            SQL += " and num='" + num + "'";
            SQL += " and mark='" + mark + "'";
            SQL += " order by show_no ";
        } else {
            SQL = "select * ";
            SQL += " from dmt_show ";
            SQL += " where seq = " + seq + " and seq1 = '" + seq1 + "'";
            SQL += " order by show_sqlno ";
        }
        DataTable dt = new DataTable();
        using (DBHelper conn = new DBHelper(Conn.btbrt).Debug(false)) {
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
