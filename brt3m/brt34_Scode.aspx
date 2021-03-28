<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>

<script runat="server">
    protected string SQL = "";

    protected string fld1 = "";//簽核者
    protected string fld2 = "";//回傳的select欄位名
    protected string fld3 = "";//apcode
    protected StringBuilder strOut = new StringBuilder();

    protected void Page_Load(object sender, EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        fld1 = (Request["fld1"] ?? "").Trim();
        fld2 = (Request["fld2"] ?? "").Trim();
        fld3 = (Request["fld3"] ?? "").Trim();

        SQL = "select A.IN_scode,d.sc_name ";
        SQL += "from todo_opt A inner join sysctrl.dbo.scode D on a.in_scode = d.scode ";
        SQL += "where a.job_status='NN' and a.job_scode='" + fld1 + "' and a.syscode='" + Session["syscode"] + "' and apcode='" + fld3 + "' ";
        SQL += "group by a.in_scode,d.sc_name";

        strOut.AppendLine("var obj = $('#" + fld2 + "')");
        strOut.AppendLine("obj.empty();");
        strOut.AppendLine("obj.append(\"<option value='' style='COLOR:blue'>請選擇</option>\");");
        using (DBHelper optconn = new DBHelper(Conn.optK)) {
            using (SqlDataReader dr = optconn.ExecuteReader(SQL)) {
                if (dr.Read()) {
                    strOut.AppendLine("obj.append(\"<option value='" + dr.SafeRead("in_scode", "") + "'>" + dr.SafeRead("sc_name", "") + "</option>\");");
                }
            }
        }
    }
</script>

<%=strOut.ToString()%>
