<%@Page Language="C#"%>
<!DOCTYPE html>
<html>
<head>
    <%
    var f = Request["f"];
    if (!string.IsNullOrEmpty(f))
    {
    %>
    <meta http-equiv="X-UA-Compatible" content="IE=<%=f%>"/>
    <%
    }
    %>
    <style>body { font-size: 9pt; }</style>
</head>
<body>
<div style="width:520px">
    <h2>IFrame</h2>
    <div id="result"></div>
    <script src="ietool.js"></script>
  <br />
  <iframe src="SubFrame.aspx<%=Request.Url.Query%>" style="width: 300px; height: 200px">
  </iframe>
</div>
</body>