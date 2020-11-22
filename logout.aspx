<%@ Page Language="C#" CodePage="65001"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<script runat="server">
    private void Page_Load(Object sender, EventArgs e) {
        //Session["Password"] = false;
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;
        Session.Abandon();
    }
</script>
<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>登出</title>
<link href="./inc/setstyle.css" rel="stylesheet" type="text/css" />
<script language="javascript" type="text/javascript">
window.top.location.href = "default.aspx";
</script>
</head>
<body>
</body>
</html>
