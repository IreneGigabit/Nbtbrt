<%@ Page Language="C#" CodePage="65001"%>
<%@Import Namespace = "System.Collections.Generic"%>

<script runat="server">
    protected StringBuilder strOut = new StringBuilder();

    protected string type = "";
    protected string draw_file = "";
    protected string file_name = "";
    protected string folder_name = "";
    protected string cust_area = "";
    protected string btnname = "";
    
    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        type = Request["type"] ?? "";
        draw_file = Request["draw_file"] ?? "";
        draw_file=Sys.Path2Nbtbrt(draw_file);
        file_name = draw_file;//完整路徑+檔案
        
        System.IO.FileInfo dFi = new System.IO.FileInfo(HttpContext.Current.Server.MapPath(draw_file));
        
        //folder_name = draw_file.Substring(0,(draw_file.LastIndexOf(@"\")));
        btnname = Request["btnname"] ?? "";
        
        if (type=="brdb_file"){
            file_name = Request["folder_name"] ?? "";
        }
        
        //Response.Write("draw_file=" + draw_file + "<BR>");
        //Response.Write("file_name=" + file_name + "<BR>");
        //Response.Write("folder_name=" + folder_name + "<BR>");
        //Response.Write("file_name_w=" + System.IO.Path.GetFileNameWithoutExtension(file_name) + "<BR>");
        //Response.Write("dFi=" + dFi + "<BR>");
        //Response.End();
        
        System.IO.FileInfo fi = new System.IO.FileInfo(Server.MapPath(file_name));
        if (fi.Exists) {
            //刪除檔案是將原檔改名,改名規則：檔名_年月日時分秒
            string File_name_new = String.Format("{0}_{1}{2}", System.IO.Path.GetFileNameWithoutExtension(file_name), DateTime.Now.ToString("yyyyMMddHHmmss"), fi.Extension);
            if (type == "ext_photo" || type == "dmt_photo" || type == "doc_candel") {
                //商標圖檔或可刪除文件直接刪除
                //fi.Delete();
                //20201202改為不刪除只更名
                fi.MoveTo(fi.DirectoryName + "\\" + File_name_new);
            } else {
                fi.MoveTo(fi.DirectoryName + "\\" + File_name_new);
            }
        }
        
        if (btnname != "") {
            strOut.AppendLine("document.getElementById('"+btnname+"').disabled=false;");
        }
    }
</script>

<%=strOut.ToString()%>
