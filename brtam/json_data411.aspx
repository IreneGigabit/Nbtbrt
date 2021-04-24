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
        string branch = Request["branch"] ?? "";
        string cgrs = (Request["cgrs"] ?? "").ToUpper();

        using (DBHelper conn = new DBHelper(Conn.btbrt, false)) {
            if (cgrs == "CS") {
                SQL = "select isnull(count(*),0) count from vcs_dmt where 1=1";
            } else {
                SQL = "select isnull(count(*),0) count from vstep_dmt";
                SQL += " where cg='" + cgrs.Left(1) + "' and rs='" + cgrs.Right(1) + "'";
            }

            if ((Request["step_date"] ?? "") != "") SQL += " and step_date='" + Request["step_date"] + "'";
            if ((Request["sdate"] ?? "") != "") SQL += " and step_date>='" + Request["sdate"] + "'";
            if ((Request["edate"] ?? "") != "") SQL += " and step_date<='" + Request["edate"] + "'";
            if ((Request["srs_no"] ?? "") != "") SQL += " and rs_no>='" + Request["srs_no"] + "'";
            if ((Request["ers_no"] ?? "") != "") SQL += " and rs_no<='" + Request["ers_no"] + "'";
            if ((Request["sseq"] ?? "") != "") SQL += " and seq>='" + Request["sseq"] + "'";
            if ((Request["eseq"] ?? "") != "") SQL += " and seq<='" + Request["eseq"] + "'";
            if ((Request["seq1"] ?? "") != "") SQL += " and seq1='" + Request["seq1"] + "'";
            if ((Request["cust_area"] ?? "") != "" && cgrs != "CS") SQL += " and cust_area='" + Request["cust_area"] + "'";
            if ((Request["scust_seq"] ?? "") != "") SQL += " and cust_seq>='" + Request["scust_seq"] + "'";
            if ((Request["ecust_seq"] ?? "") != "") SQL += " and cust_seq<='" + Request["ecust_seq"] + "'";
            if ((Request["hprint"] ?? "") == "N" && cgrs != "CS") SQL += " and isnull(new,'N')='" + Request["hprint"] + "'";
            object objResult = conn.ExecuteScalar(SQL);
            int count = (objResult == DBNull.Value || objResult == null) ? 0 : Convert.ToInt32(objResult);
            strOut.AppendLine("var jCount=" + count + ";");
        }
    }
</script>
<%=strOut.ToString()%>
