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
    protected StringBuilder strOut = new StringBuilder();

    protected void Page_Load(object sender, EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        using (DBHelper conn = new DBHelper(Conn.btbrt, false)) {
            SQL = "Select stat_code from case_dmt";
            SQL += " where in_scode='" + Request["in_scode"] + "'";
            SQL += " and in_no='" + Request["in_no"] + "'";
            using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
                strOut.AppendLine("var jBreak=false;");
                if (dr.Read()) {
                    strOut.AppendLine("var jStat_code='" + dr.SafeRead("stat_code", "") + "';");
                } else {
                    strOut.AppendLine("alert('無本筆交辦(接洽序號：" + Request["in_no"] + ")資料，請重新查詢！');");
                    strOut.AppendLine("var jBreak=true;");
                }
            }
        }
    }
</script>
<%=strOut.ToString()%>
