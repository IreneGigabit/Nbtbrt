<%@ Page Language="C#" CodePage="65001"%>

<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<script runat="server">
    protected string draw_file = "";
    protected string file_name = "";
    protected string file_ext = "";
    protected string imglist = "";
    protected StringBuilder strOut = new StringBuilder();

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        draw_file = Request["draw_file"] ?? "";
        //draw_file = draw_file.Replace("\\", "/");
        //draw_file = draw_file.Replace("/btbrt/", "/nbtbrt/");
        draw_file = Sys.Path2Nbtbrt(draw_file);
        file_name = draw_file.Substring((draw_file.LastIndexOf(@"\") + 1));
        file_ext = draw_file.Substring((draw_file.LastIndexOf(".") + 1)).ToLower();
        imglist = "|.jpg|.png|.gif|.bmp|";

        if (imglist.IndexOf("|" + file_ext + "|") > -1) {
            strOut.AppendLine("<br><br>");
            strOut.AppendLine("<p><img border='0' src='" + draw_file + "'></p>");
        } else {
            //strOut.AppendLine("<iframe src='" + draw_file + "' style='width:100%;height:100%' frameborder='0'></iframe>");
            Response.Redirect(draw_file);
        }
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>檢視圖檔</title>
<uc1:head_inc_form runat="server" ID="head_inc_form" />
</head>

    <%=strOut.ToString()%>
</html>
