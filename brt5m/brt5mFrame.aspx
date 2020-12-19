<%@ Page Language="C#" %>

<!DOCTYPE html>

<script runat="server">
    protected string QueryString = "";
    
    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        QueryString = Request.ServerVariables["QUERY_STRING"];
        //Response.Write(QueryString);
        //Response.End();
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <title></title>
</head>
<frameset rows="100,0" id="tt" name="tt">   
　<frame id="Etop" name="Etop" scrolling="auto" src="<%=Request["prg"]%>?<%=QueryString%>">
  <frame id="Eblank" name="Eblank" >
</frameset>
</HTML>