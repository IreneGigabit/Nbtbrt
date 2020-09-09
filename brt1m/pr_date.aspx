<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>

<script runat="server">
    protected string SQL = "";

    protected string Arcase = "";
    protected StringBuilder strOut = new StringBuilder();

    protected void Page_Load(object sender, EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        Arcase = (Request["Arcase"] ?? "").Trim();

        SQL = "select b.ad,b.days ";
        SQL += "from vcode_act a ";
        SQL += "inner join code_ctrl b on a.sqlno=b.act_sqlno and b.ctrl_type='B2' ";
        SQL += "where a.rs_code='" + Arcase + "' ";
        SQL += "and a.cg='C' and a.rs='R' AND no_code='N' and a.act_code='_' ";
        
        string value1 = "", value2 = "";
        using (DBHelper conn = new DBHelper(Conn.btbrt, false)) {
            using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
                if (dr.Read()) {
                    value1 = dr.SafeRead("ad", "").Trim();
                    value2 = dr.SafeRead("days", "0").Trim();
                } else {
                    value1 = "A";
                    value2 = "15";
                }
            }
        }
        
        DateTime svalue=DateTime.Today;
        if (value1=="A")
            svalue=svalue.AddDays(Convert.ToInt32(value2));
        else
            svalue=svalue.AddDays(Convert.ToInt32(value2)*(-1));

        strOut.AppendLine("reg.dfy_pr_date.value = '" + svalue.ToShortDateString() + "';");
    }
</script>

<%=strOut.ToString()%>
