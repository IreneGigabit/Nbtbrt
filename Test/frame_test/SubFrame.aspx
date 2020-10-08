<%@Page Language="C#"%>
<!DOCTYPE html>
<html>
<head>
    <%
    var p = Request["s"];
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
  <h2>Sub IFrame</h2>
    <div id="result"></div>
    <script src="ietool.js"></script>
    <script>
        var parentRes = parent.parent.document.getElementById("result").innerHTML;
        var frameRes = parent.document.getElementById("result").innerHTML;
        var subFrameRes = document.getElementById("result").innerHTML;
        var param = location.search.split("=")[4];
        localStorage[param] = parentRes + "," + frameRes + "," + subFrameRes;
    </script>
</body>