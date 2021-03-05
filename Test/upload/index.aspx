<%@ Page Language="C#"%>

<%@ Register Src="~/Test/upload/dmt_upload_Form.ascx" TagPrefix="uc1" TagName="dmt_upload_Form" %>


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<script runat="server">
    protected string prgid = "";

    private void Page_Load(System.Object sender, System.EventArgs e) {
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta http-equiv="x-ua-compatible" content="IE=11">
    <title>多檔上傳</title>
    <link rel="stylesheet" type="text/css" href="<%=Page.ResolveUrl("~/inc/setstyle.css")%>" />
    <script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/jquery-1.12.4.min.js")%>"></script>
    <script type="text/javascript" src="<%=Page.ResolveUrl("~/js/util.js")%>"></script>
</head>

<body>
    案件編號：<input type="text" name="seq" id="seq" value="20056" class="SEdit" readonly>-<input type="text" name="seq1" id="seq1" value="_" class="SEdit" readonly>
    <br />
    <uc1:dmt_upload_Form runat="server" id="dmt_upload_Form" />
</body>
</html>

<script type="text/javascript" language="javascript">
</script>
