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

        string prgid = (Request["prgid"] ?? "").ToLower();
        string dept = Request["dept"] ?? "";

        using (DBHelper conn = new DBHelper(Conn.btbrt, false)) {
            if (dept == "TE") {
                SQL = "select count(*) from attach_ext";
            } else {
                SQL = "select count(*) from dmt_attach";
            }
            SQL += " where source='scan' and attach_flag<>'D' ";

            if ((Request["step_grade"] ?? "") != "") SQL += " and step_grade='" + Request["step_grade"] + "'";
            if ((Request["sdate"] ?? "") != "") SQL += " and in_date>='" + Request["sdate"] + " 00:00:00'";
            if ((Request["edate"] ?? "") != "") SQL += " and in_date<='" + Request["edate"] + " 23:59:59'";
            if ((Request["seq"] ?? "") != "") SQL += " and seq='" + Request["seq"] + "'";
            if ((Request["bseq"] ?? "") != "") SQL += " and seq>='" + Request["bseq"] + "'";
            if ((Request["eseq"] ?? "") != "") SQL += " and seq<='" + Request["eseq"] + "'";
            if ((Request["seq1"] ?? "") != "") SQL += " and seq1='" + Request["seq1"] + "'";
            if ((Request["in_scode"] ?? "") != "") SQL += " and in_scode='" + Request["in_scode"] + "'";
            if ((Request["chk_status"] ?? "") != "") SQL += " and chk_status like '" + Request["chk_status"] + "%'";
            
            object objResult = conn.ExecuteScalar(SQL);
            int count = (objResult == DBNull.Value || objResult == null) ? 0 : Convert.ToInt32(objResult);
            strOut.AppendLine("var jCount=" + count + ";");
        }
    }
</script>
<%=strOut.ToString()%>
