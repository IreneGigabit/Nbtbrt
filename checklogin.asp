<%@ Language=VBScript CodePage=65001 %>
<%
Response.CacheControl = "Private"
Response.AddHeader "Pragma", "no-cache"
Response.Expires = -1

Dim url
url = "./checklogin.aspx?tfx_scode=" & Request("tfx_scode") & "&tfx_sys_password=" & Request("tfx_sys_password") & "&toppage=" & Request("toppage")  & "&syscode=" & Request("syscode") & "&stat=" & Request("stat") & "&sys_pwd=" & Request("sys_pwd")
Response.Redirect url
%>
