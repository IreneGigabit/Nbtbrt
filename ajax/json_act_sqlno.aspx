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

    protected string cgrs = "";
    protected string rs_class = "";
    protected string rs_code = "";
    protected string act_code = "";
    protected string submittask = "";

    protected void Page_Load(object sender, EventArgs e) {
        cgrs = Request["cgrs"] ?? "";
        rs_class = Request["rs_class"] ?? "";
        rs_code = Request["rs_code"] ?? "";
        act_code = Request["act_code"] ?? "";
        submittask = (Request["submittask"] ?? "").ToUpper();

        DataTable dt = new DataTable();
        using (DBHelper conn = new DBHelper(Conn.btbrt, false)) {
            SQL = "select a.csflg,a.cs_detail,a.spe_ctrl,b.sqlno ctrl_sqlno,b.act_sqlno,b.ctrl_type,b.date_ctrl,b.ad,b.days,b.md,b.remark ctrl_remark ";
            SQL += ",(select mark1 from cust_code where code_type='DC' and cust_code=b.date_ctrl) as date_name ";
            SQL += ",a.case_stat,(select code_name from cust_code where code_type='tcase_stat' and cust_code=a.case_stat) as case_statnm ";
            SQL += ",b.ad2,isnull(b.days2,0) as days2,b.md2 ";
            SQL += ",case when b.sqlno is not null then 'A' else 'B' end sqlflg ";
            SQL += " from vcode_act a ";
            SQL += " left join code_ctrl b on a.sqlno=b.act_sqlno ";
            SQL += " where a.dept='" + Sys.GetSession("dept") + "' ";
            SQL += " and cg='" + cgrs.Left(1) + "' and rs='" + cgrs.Substring(1, 1) + "' and " + cgrs + "='Y' ";
            SQL += " and rs_code='" + rs_code + "'";
            SQL += " and act_code='" + act_code + "'";
            if (rs_class != "") {
                SQL += " and rs_class='" + rs_class + "' ";
            }
            conn.DataTable(SQL, dt);
            for (int i = 0; i < dt.Rows.Count; i++) {
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
