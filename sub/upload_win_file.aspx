<%@ Page Language="C#" CodePage="65001"%>
<%@Import Namespace = "System.Collections.Generic"%>

<script runat="server">
    protected string DebugStr = "";
    protected string QueryString = "";
    protected string submitTask = "";
    protected string type = "";
    protected string cont = "";
    protected string msg = "";
    protected int attach_size = 0;
    
    protected Dictionary<string, string> SrvrVal = new Dictionary<string, string>();
    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        Token myToken = new Token();
        DebugStr = myToken.DebugStr;
       
        QueryString = Request.ServerVariables["QUERY_STRING"];
        ReqVal = Util.GetRequestParam(Context,Request["chkTest"] == "TEST");
        
        type = Request["type"] ?? "";
        submitTask = (Request["submitTask"] ?? "").ToUpper();
        
        string gdept = "T";
        SrvrVal.Add("folder_name", Request["folder_name"] ?? "");//檔案目錄所在,ex:attach/2011/000063
        SrvrVal.Add("prefix_name", Request["prefix_name"] ?? "");//檔案的前置名稱:例如: filename=abc.jpg, if prefix="123" , then filename=123_abc.jpg,用於區隔同目錄底下,不同的檔案名稱
        SrvrVal.Add("seq", Request["seq"] ?? "");
        SrvrVal.Add("draw_file", Request["draw_file"] ?? "");
        SrvrVal.Add("form_name", Request["form_name"] ?? "");//目錄+檔名欄位名,ex:opt_file_5
        SrvrVal.Add("size_name", Request["size_name"] ?? "");//檔案大小欄位名,ex:opt_file_size_5
        SrvrVal.Add("file_name", Request["file_name"] ?? "");//附件名稱欄位名,ex:opt_file_name_5
        SrvrVal.Add("source_name", Request["source_name"] ?? "");//原始檔案名稱,ex:opt_file_source_name_5
        SrvrVal.Add("desc", Request["desc"] ?? "");//附件說明欄位名,ex:opt_file_desc_5
        SrvrVal.Add("btnname", Request["btnname"] ?? "");//"上傳"按鈕名,ex:btnopt_file_5
        SrvrVal.Add("nfilename", Request["nfilename"] ?? "");//指定新檔名
        SrvrVal.Add("doc_add_date", Request["add_date"] ?? "");//上傳時間欄位名,ex:opt_file_add_date_5
        SrvrVal.Add("doc_add_scode", Request["add_scode"] ?? "");//上傳人員欄位名,ex:opt_file_add_scode_5

        SrvrVal.Add("aa","");//最後儲存的檔名(含路徑)
        SrvrVal.Add("ee","");//最後儲存的檔名
        SrvrVal.Add("bb","");//原始儲存的檔名
        SrvrVal.Add("zz", "");//原始儲存的檔名(不含ext)
        
        switch (type) {
            case "law_opt":
                SrvrVal.Add("type", "law_opt");
                SrvrVal.Add("cust_area", Request["cust_area"] + gdept);
                cont = "檔案上傳";
                break;
            case "doc":
                SrvrVal.Add("type", "doc");
                SrvrVal.Add("cust_area", Request["cust_area"] + gdept);
                cont = "檔案上傳";
                break;
            default:
                SrvrVal.Add("type", "");
                Response.Write("<html><head><title>RE?!1ORE!?DAo3?μoμ!!C</title></head><body bgcolor=#ffffff><br><br><p><center>RE?!1ORE!?DAo3?μoμ!!C");
                Response.Write("<form><input type=button value=Ao3?μoμ! onclick='window.close()'></form></center></body></html>");
                Response.End();
                break;
        }

        if (submitTask == "UPLOAD")
            DoUpLoad(); //上傳

        this.DataBind();
    }

    private void DoUpLoad() {
        //string mappath_name = @"\nopt\opt_file\";
        //if (type == "law_opt") mappath_name = @"\nopt\law_opt\";
        string mappath_name = Sys.FileDir(type);
        
        string file_path = mappath_name +"/"+ SrvrVal["folder_name"] + "/";//指定儲存路徑
        if (!System.IO.Directory.Exists(Server.MapPath(file_path))) {
            //新增資料夾
            System.IO.Directory.CreateDirectory(Server.MapPath(file_path));
        }

        //原檔名
        HttpFileCollection allFiles = Request.Files;
        HttpPostedFile uploadedFile = allFiles["theFile"];

        string FName = uploadedFile.FileName;               //使用者端目錄+檔案名稱
        string dd = System.IO.Path.GetFileNameWithoutExtension(FName);      //原檔名(不含Ext)
        string sExt = System.IO.Path.GetExtension(FName);   //副檔名
        attach_size = uploadedFile.ContentLength;       //檔案大小(bytes)
        string ee = "";//新檔名
        if (SrvrVal["nfilename"] != "")//有指定新檔案名稱
            ee = SrvrVal["nfilename"];
        else
            ee = dd;

        //如果存在的話原來的要備份起來,備份規則：檔名_年月日時分秒
        System.IO.FileInfo fi = new System.IO.FileInfo(Server.MapPath(file_path + ee + sExt));
        if (fi.Exists) {
            string File_name_new = String.Format("{0}_{1}{2}", ee, DateTime.Now.ToString("yyyyMMddHHmmss"), sExt);
            fi.MoveTo(Server.MapPath(file_path + File_name_new));
            msg = "此檔案已存在！已覆蓋檔案！";
        }

        SrvrVal["aa"] = (file_path + ee + sExt).Replace("\\", "\\\\");//最後儲存的檔名(含路徑)
        SrvrVal["ee"] = (ee + sExt).Replace("\\", "\\\\");//最後儲存的檔名
        SrvrVal["bb"] = (dd + sExt).Replace("\\", "\\\\");//原始儲存的檔名
        SrvrVal["zz"] = (dd).Replace("\\", "\\\\");//原始儲存的檔名(不含ext)

        if (Request["chkTest"] == "TEST") {
            Response.Write("<HR>");
            Response.Write("FName=" + FName + "<BR>");
            Response.Write("dd=" + dd + "<BR>");
            Response.Write("sExt=" + sExt + "<BR>");
            Response.Write("attach_size=" + attach_size + "<BR>");
            Response.Write("saveAs=" + Server.MapPath(file_path + ee + sExt) + "<BR>");
            Response.End();
        }
        uploadedFile.SaveAs(Server.MapPath(file_path + ee + sExt));
             
        //傳回window.opener之欄位
        StringBuilder strOut = new StringBuilder();
        strOut.AppendLine("<script language=javascript>");
        if (msg!="")
            strOut.AppendLine("alert('"+msg+"');");
         strOut.AppendLine("window.opener.document.getElementById('"+SrvrVal["form_name"]+"').value = '"+SrvrVal["aa"]+"';");
        if(SrvrVal["size_name"].Length>0)
            strOut.AppendLine("window.opener.document.getElementById('"+SrvrVal["size_name"]+"').value = '"+attach_size+"';");
        if(SrvrVal["file_name"].Length>0)
            strOut.AppendLine("window.opener.document.getElementById('"+SrvrVal["file_name"]+"').value = '"+SrvrVal["ee"]+"';");
        if(SrvrVal["doc_add_date"].Length>0)
            strOut.AppendLine("window.opener.document.getElementById('"+SrvrVal["doc_add_date"]+"').value = '"+DateTime.Now.ToShortDateString()+"';");
        if(SrvrVal["doc_add_scode"].Length>0)
            strOut.AppendLine("window.opener.document.getElementById('"+SrvrVal["doc_add_scode"]+"').value = '"+Session["scode"]+"';");
        if(SrvrVal["source_name"].Length>0)
            strOut.AppendLine("window.opener.document.getElementById('"+SrvrVal["source_name"]+"').value = '"+SrvrVal["bb"]+"';");
        if(SrvrVal["desc"].Length>0)
            strOut.AppendLine("window.opener.document.getElementById('"+SrvrVal["desc"]+"').value = '"+SrvrVal["zz"]+"';");
        if(SrvrVal["btnname"].Length>0)
            strOut.AppendLine("window.opener.document.getElementById('"+SrvrVal["btnname"]+"').disabled = true;");
       
        strOut.AppendLine("window.close();");
        strOut.AppendLine("<" + "/script>");

        Response.Write(strOut.ToString());
        Response.End();
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta http-equiv="x-ua-compatible" content="ie=10">
<title>文件上傳</title>
<link rel="stylesheet" type="text/css" href="<%=Page.ResolveUrl("~/inc/setstyle.css")%>" />
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/jquery-1.12.4.min.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/jquery.irene.form.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/util.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/client_chk.js")%>"></script>
</head>

<body bgcolor="#FFFFFF">
    <p align="center"><big><font face="標楷體" color="#004000"><strong><big><big><%=cont%></big></big></strong></font></big></p>
    <center>
      <form name="AttachForm" action="upload_win_file.aspx?<%#QueryString%>" method="Post" enctype="multipart/form-data" accept-charset="UTF-8">
        <table width="100%" border="0" cellspacing="0" cellpadding="0" align="center">
            <tr>
                <td align="left">
          　         上傳檔案到本資料欄位:<br>
          　         <input type="file" id="theFile" name="theFile" size="25">
          　         <input type="hidden" id="hidFile" name="hidFile">
          　         <input type="hidden" id="send_type" name="send_type" value="<%=SrvrVal["type"]%>">
          　         <input type="hidden" id="nfilename" name="nfilename" value="<%=SrvrVal["nfilename"]%>">
          　         <input type="hidden" id="submitTask" name="submitTask" value="">
                    <br>&nbsp;
                    <span style="display:none">
                        <font size="2" color="red"><input type="checkbox" id="chkoverwrite" name="chkoverwrite">覆蓋已存在的檔案<br></font>
                    </span>
                    <br>
                    <table width="95%" border="0">
                        <tr> 
                            <td align="left">
                                <font size="2" color="#009900">使用方式：</font><br>
                                <table border="0" width="100%">
                                <tr>
                                    <td width="9%" align="right" valign="top"><font size="2" color="black">◎</font></td>
                                    <td width="91%"><font size="2" color="black">
                                        欲上傳檔案至本欄位，請點選上方之『瀏覽』按鈕後會出現一個『選擇檔案』小視窗，然後請選擇您電腦中欲上傳之檔案。</font>
                                    </td>
                                </tr>
                                </table>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
            <tr>
                <td align="center">
                    <input type="button" value="上傳" onclick="AttachFile()" id="button1" name="button1" class="cbutton">
                    <input type="button" value="關閉視窗" onclick="javascript:parent.close()" id="button2" name="button2" class="cbutton">
                </td>
            </tr>
        </table>
        <br /><%#DebugStr%>
      </form>
    </center>
</body>
</html>
<script language="javascript" type="text/javascript">
    $(function () {
    });

    function AttachFile() {
        var attachfilename = $("#theFile").val();
        if (attachfilename.length == 0) {
            alert("請輸入要上傳的檔案名稱，或使用瀏覽來選擇檔案。");
            return false;
        }
        $("#hidFile").val(attachfilename);
        $("#button1").prop("disabled", true);

        AttachForm.submitTask.value = "UPLOAD";
        AttachForm.submit();
    }
</script>
