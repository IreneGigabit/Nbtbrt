<%@ Page Language="C#" CodePage="65001"%>
<%@Import Namespace = "System.Collections.Generic"%>

<script runat="server">
    protected string type = "";
    protected string draw_file = "";
    protected string file_name = "";
    protected string folder_name = "";
    protected string cust_area = "";
    protected string file_path = "";
    protected string btnname = "";
    
    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        string gdept = "T";
        type = Request["type"] ?? "";
        draw_file = Request["draw_file"] ?? "";
        draw_file = draw_file.Replace("\\", "/");
        draw_file = draw_file.Replace("/opt/", "/nopt/");
        file_name = draw_file.Substring((draw_file.LastIndexOf("/") + 1));
        folder_name = Request["folder_name"] ?? "";
        cust_area = (Request["cust_area"] ?? "").Left(1)+gdept;
        btnname = Request["btnname"] ?? "";

        //file_path = "/nopt/opt_file/";
        //if (type == "law_opt") file_path = "/nopt/law_opt/";
        file_path = Sys.FileDir(type);

        //Response.Write("draw_file=" + draw_file + "<BR>");
        //Response.Write("file_name=" + file_name + "<BR>");
        //Response.Write("folder_name=" + folder_name + "<BR>");
        //Response.Write("file_name_w=" + System.IO.Path.GetFileNameWithoutExtension(file_name) + "<BR>");
        //Response.End();
        
        //刪除檔案是將原檔改名,改名規則：檔名_年月日時分秒
        System.IO.FileInfo fi = new System.IO.FileInfo(Server.MapPath(draw_file));
        if (fi.Exists) {
            string File_name_new = String.Format("{0}_{1}{2}", System.IO.Path.GetFileNameWithoutExtension(file_name), DateTime.Now.ToString("yyyyMMddHHmmss"), fi.Extension);
            //Response.Write("backup_name=" + file_path + "/" + folder_name + "/" + File_name_new + "<BR>");
            fi.MoveTo(Server.MapPath(file_path + "/" + folder_name + "/" + File_name_new));
        }

        this.DataBind();
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta http-equiv="x-ua-compatible" content="ie=10">
<title>文件刪除</title>
<link rel="stylesheet" type="text/css" href="<%=Page.ResolveUrl("~/inc/setstyle.css")%>" />
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/jquery-1.12.4.min.js")%>"></script>
</head>
</html>
<script language="javascript" type="text/javascript">
    if ("<%#btnname%>"!=""){
        window.opener.document.getElementById("<%#btnname%>").disabled=false;
    }
    window.close();
</script>
