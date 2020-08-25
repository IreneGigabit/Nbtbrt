<%@ Page Language="C#" CodePage="65001" %>
<%@ Import Namespace = "System.Data.SqlClient"%>

<script runat="server">
    protected string StrProjectName = Sys.Project;
    private int HTProgRight = 0;

    private void Page_Load(Object sender, EventArgs e) {
        this.DataBind();
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<link rel="icon" type="image/ico" href="./icon/myfarm.ico" />
<link rel="shortcut icon" href="./icon/myfarm.ico" />
<title></title>
</head>
<body>
    <%#StrProjectName%>
</body>
</html>
