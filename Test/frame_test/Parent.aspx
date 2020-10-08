<%@Page Language="C#"%>
<!DOCTYPE html>
<html>
<head>
    <%
    var p = Request["p"];
    if (!string.IsNullOrEmpty(p))
    {
    %>
    <meta http-equiv="X-UA-Compatible" content="IE=<%=p%>"/>
    <%
    }
    %>
    <style>body { font-size: 9pt; }</style>
</head>
<body>
<div style="width:520px">
    <h2>Parent</h2>
    <div id="result"></div>
    <script src="ietool.js"></script>
  <br />
  <iframe src="frame.aspx<%=Request.Url.Query%>" style="width: 550px; height: 400px">
  </iframe>
</div>
</body>