<%@ Page Language="C#" CodePage="65001" %>
<script runat="server">
    protected string mainSrc = "";
    protected string leftSrc = "";
    protected string sideWidth = "";
    
	private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        if (Convert.ToBoolean(Session["Password"])) {
            mainSrc = "homelist.aspx";
            leftSrc = "leftmenu.aspx";
        } else {
            mainSrc = "login.aspx";
            leftSrc = "about:blank";
        }

        sideWidth = Request["sidewidth"] ?? "200";
        
        this.Page.DataBind();
    }
</script>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Frameset//EN" "http://www.w3.org/TR/html4/frameset.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
<title></title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
<meta http-equiv="cache-control" content="no-cache"/>
</head>
<frameset cols="<%#sideWidth%>,*" frameborder="no" border="0" framespacing="0" name="f" id="f">
	<frame id="leftFrame" name="leftFrame" src="<%#leftSrc%>" marginwidth="0" marginheight="0" frameborder="NO"/>
	<frame id="mainFrame" name="mainFrame" src="<%#mainSrc%>" marginwidth="10" marginheight="11"/>
</frameset>
<!--frameset name="f" id="f" cols="<%#sideWidth%>,*">
    <frame src="<%#leftSrc%>" frameborder="0" name="leftFrame" id="leftFrame" />
    <frameset rows="100%,*" name="tt" id="tt">
        <frame name="Etop" id="Etop" scrolling="auto" src="<%#mainSrc%>">"/>
        <frame name="Eblank" id="Eblank" scrolling="auto" src="about:blank"/>
　　 </frameset>
</frameset-->
</html>
