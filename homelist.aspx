<%@ Page Language="C#" CodePage="65001" %>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Collections.Generic"%>

<script runat="server">
    protected string StrProjectName = Sys.Project;
    protected Dictionary<string, string> rights = new Dictionary<string, string>();
    protected Dictionary<string, string> rightsE = new Dictionary<string, string>();

    string SQL = "";
    
    DBHelper conn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    DBHelper cnn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    private void Page_Unload(System.Object sender, System.EventArgs e) {
        if (conn != null) conn.Dispose();
        if (cnn != null) cnn.Dispose();
    }

    private void Page_Load(Object sender, EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
        cnn = new DBHelper(Conn.ODBCDSN).Debug(Request["chkTest"] == "TEST");

        //kind=homelist_job(?).inc
        SQL = "select c.dept,c.kind,a.logingrp,c.Rights from logingrp a,sysctrl b,homeright c";
        SQL += " where a.syscode='" + Sys.Syscode + "' and b.scode='" + Session["scode"] + "'";
        SQL += " and a.syscode=b.syscode and a.logingrp=b.logingrp and a.syscode=c.syscode and a.logingrp=c.logingrp";
        using (SqlDataReader dr = cnn.ExecuteReader(SQL)) {
            while (dr.Read()) {
                switch (dr.SafeRead("dept", "").ToUpper()) {
                    case "T":
                        rights[dr.SafeRead("kind", "")] = dr.SafeRead("Rights", "").ToUpper();
                        break;
                    case "TE":
                        rightsE[dr.SafeRead("kind", "")] = dr.SafeRead("Rights", "").ToUpper();
                        break;
                }
            }
        }

        //foreach (KeyValuePair<string, string> item in rights) {
        //    Response.Write(string.Format("{0} : {1}<br/" + ">", item.Key, item.Value));
        //}
        //Response.Write("<HR>");
        //foreach (KeyValuePair<string, string> item in rightsE) {
        //    Response.Write(string.Format("{0} : {1}<br/" + ">", item.Key, item.Value));
        //}
        //Response.Write("<HR>");
        //Response.Write(rights.TryGet("1") + "<bR>");
        //Response.Write(rightsE.TryGet("1") + "<bR>");
        this.DataBind();
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title></title>
</head>
<BODY background="./images/back01.gif" style="margin-left:2em;margin-right:2em;background-repeat: repeat-y;">
    <%if (rights.TryGet("1")!=""||rightsE.TryGet("1")!=""){%>
	<!--#INCLUDE FILE="homelist_job1.inc" -->
	<%}%>
    <%if (rights.TryGet("2")!=""||rightsE.TryGet("2")!=""){%>
	<!--INCLUDE FILE="homelist_job2.inc" -->
	<%}%>
    <%if (rights.TryGet("3")!=""||rightsE.TryGet("3")!=""){%>
	<!--INCLUDE FILE="homelist_job3.inc" -->
	<%}%>
    <%if (rights.TryGet("5")!=""||rightsE.TryGet("5")!=""){%>
	<!--INCLUDE FILE="homelist_job5.inc" -->
	<%}%>
    <%if (rights.TryGet("6")!=""||rightsE.TryGet("6")!=""){%>
	<!--INCLUDE FILE="homelist_job6.inc" -->		
	<%}%>
</body>
</html>
