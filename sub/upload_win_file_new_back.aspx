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

    protected Dictionary<string, string> SrvrVal = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        Token myToken = new Token();
        DebugStr = myToken.DebugStr;
       
        QueryString = Request.ServerVariables["QUERY_STRING"];
        ReqVal = Util.GetRequestParam(Context,Request["chkTest"] == "TEST");
        
        type = (Request["type"] ?? "").ToLower();
        submitTask = (Request["submitTask"] ?? "").ToUpper();

        string gdept = "T";
        SrvrVal["fileext"] = (Request["fileext"] ?? "");//指定允許的副檔名,ex: pdf|gif
        SrvrVal["folder_name"] = (Request["folder_name"] ?? "");//檔案目錄所在,會在cust_area之下建立,ex:CT/attach/2011/000063
        SrvrVal["prefix_name"] = (Request["prefix_name"] ?? "");//檔案的前置名稱:例如: filename=abc.jpg]=(if prefix="123" ]=(then filename=123_abc.jpg,用於區隔同目錄底下,不同的檔案名稱
        SrvrVal["cust_area"] = (Request["cust_area"] ?? "").Left(1) + gdept;
        SrvrVal["draw_file"] = (Request["draw_file"] ?? "");//原檔案路徑(存在於server上的D:\data\document)
        SrvrVal["form_name"] = (Request["form_name"] ?? "");//目錄+檔名欄位名,ex:opt_file_5
        SrvrVal["size_name"] = (Request["size_name"] ?? "");//檔案大小欄位名,ex:opt_file_size_5
        SrvrVal["file_name"] = (Request["file_name"] ?? "");//附件名稱欄位名,ex:opt_file_name_5
        SrvrVal["source_name"] = (Request["source_name"] ?? "");//原始檔案欄位名稱,ex:opt_file_source_name_5
        SrvrVal["filename_flag"] = (Request["filename_flag"] ?? "").ToLower();//??
        SrvrVal["btnname"] = (Request["btnname"] ?? "");//"上傳"按鈕名,ex:btnopt_file_5
        SrvrVal["nfilename"] = (Request["nfilename"] ?? "");//指定新檔名
        SrvrVal["prgid"] = ((Request["prgid"] ?? "").ToLower());//??
        SrvrVal["prgid_name"] = ((Request["prgid_name"] ?? "").ToLower());//??
        SrvrVal["dir_name"] = ((Request["dir_name"] ?? "").ToLower());//回傳路徑的欄位名
        
        SrvrVal["branch_name"] = (Request["branch_name"] ?? "");
        SrvrVal["docbranch"] = (Request["branch"] ?? "");
        SrvrVal["tablename"] = (Request["tablename"] ?? "");
        SrvrVal["doc_in_date"] = (Request["in_date"] ?? "");//上傳時間欄位名
        SrvrVal["doc_in_scode"] = (Request["in_scode"] ?? "");//上傳人員欄位名
        SrvrVal["doc_in_scodenm"] = (Request["in_scodenm"] ?? "");//上傳人員欄位名
        SrvrVal["db_file_flag"] = (Request["db_file_flag"] ?? "");//for 催帳客函/請款單 
        SrvrVal["attach_flag_name"] = (Request["attach_flag_name"] ?? "");
        SrvrVal["ar_no"] = (Request["ar_no"] ?? "");//for 英文invoice
        SrvrVal["qs_dept"] = (Request["qs_dept"] ?? "");//for 英文invoice
        SrvrVal["draw_name"] = (Request["draw_name"] ?? "");//for 英文invoice

        SrvrVal["aa"] = "";//最後儲存的檔名(含路徑)
        SrvrVal["ee"] = "";//最後儲存的檔名
        SrvrVal["bb"] = "";//原始儲存的檔名
        SrvrVal["zz"] = "";//原始儲存的檔名(不含ext)

        switch (type) {
            case "doc":
                SrvrVal["type"] = "doc";
                cont = "檔案上傳";
                break;
            case "ext_photo":
            case "dmt_photo":
                SrvrVal["type"] = "photo";
                cont = "圖檔上傳";
                break;
            case "custdb_file"://對催帳客函
            case "db_file"://請款單
            case "custresp_file"://客戶對催回應文件
            case "apcust_file"://契約書、委任書
            case "brdb_file"://英文invoice
                SrvrVal["type"] = type;
                cont = "檔案上傳";
                if (type == "custdb_file") {
                    cont = "對催帳客函檔案上傳";
                } else if (type == "db_file") {
                    cont = "請款單檔案上傳";
                } else if (type == "custresp_file") {
                    cont = "對催帳客戶回應檔案上傳";
                } else if (type == "apcust_file") {
                    cont = "契約書/委任書檔案上傳";
                    SrvrVal["db_file_flag"] = "";
                } else if (type == "brdb_file") {
                    cont = "英文Invoice檔案上傳";
                }
                break;
            default:
                Response.Write("<html><head><title>RE?!1ORE!?DAo3?μoμ!!C</title></head><body bgcolor=#ffffff><br><br><p><center>RE?!1ORE!?DAo3?μoμ!!C");
                Response.Write("<form><input type=button value=Ao3?μoμ! onclick='window.close()'></form></center></body></html>");
                Response.End();
                break;
        }

        if (submitTask == "UPLOAD")
            DoUpLoad();//存檔
        
        this.DataBind();
    }

    private void DoUpLoad() {
        //回傳畫面的attach_flag值
        string attach_flag_value = "A";
        Sys sfile = new Sys();
        if (SrvrVal.TryGet("docbranch") != "") {
            sfile.getFileServer(SrvrVal["docbranch"], SrvrVal["prgid"]);
            SrvrVal["folder_name"] = "temp/" + SrvrVal["docbranch"] + "/" + SrvrVal["folder_name"];
        } else {
            sfile.getFileServer(Sys.GetSession("SeBranch"), SrvrVal["prgid"]);
        }

        string file_path = sfile.gbrWebDir + "/" + SrvrVal["folder_name"] + "/";//指定儲存路徑
        switch (SrvrVal["type"]) {
            case "custdb_file"://對催帳客函
            case "db_file"://請款單
            case "custresp_file"://客戶對催回應文件
            case "apcust_file"://契約書、委任書
            case "brdb_file"://英文invoice
                file_path = sfile.gcustDbDir + "/" + SrvrVal["folder_name"] + "/";
                break;
        }
        if (!System.IO.Directory.Exists(Server.MapPath(file_path))) {
            //新增資料夾
            System.IO.Directory.CreateDirectory(Server.MapPath(file_path));
        }

        //原檔名
        HttpFileCollection allFiles = Request.Files;
        HttpPostedFile uploadedFile = allFiles["theFile"];

        string FName = uploadedFile.FileName;               //使用者端目錄+檔案名稱
        string original_name = System.IO.Path.GetFileNameWithoutExtension(FName);      //原檔名(不含Ext)
        string sExt = System.IO.Path.GetExtension(FName);   //副檔名
        attach_size = uploadedFile.ContentLength;       //檔案大小(bytes)

        string ee = original_name;//新檔名(預設用原始檔名)
        string ee_new = "";//新檔名
        string old_file1 = SrvrVal.TryGet("draw_file");//舊檔名(畫面上欄位的值)
        if (old_file1 != "") {
            old_file1 = System.IO.Path.GetFileNameWithoutExtension(old_file1);
        }

        if (SrvrVal.TryGet("filename_flag") == "source_name") {
            //ex:原檔名abc.html，nfilename=111，ee_new=111
            if (SrvrVal["nfilename"] != "")//有指定新檔案名稱
                ee_new = SrvrVal["nfilename"];
        } else if (SrvrVal.TryGet("filename_flag") == "soure_name2") {
            //若有指定新檔名則用加上新檔名
            //ex:原檔名abc.html，nfilename=111，ee=111-abc.html
            if (SrvrVal["nfilename"] != "")//有指定新檔案名稱
                ee = SrvrVal["nfilename"] + "-" + original_name;

            if (SrvrVal.TryGet("prgid").Left(3) != "brp") {
                if (SrvrVal["nfilename"] != "")//有指定新檔案名稱
                    original_name = SrvrVal["nfilename"] + "-" + original_name;
            }
        } else {
            ee = SrvrVal["nfilename"];
        }

        bool saveFlag = true;
        System.IO.FileInfo fi = new System.IO.FileInfo(Server.MapPath(file_path + ee + sExt));
        if (original_name == old_file1) {
            if (SrvrVal["type"] == "custdb_file" || SrvrVal["type"] == "db_file" || SrvrVal["type"] == "custresp_file" || SrvrVal["type"] == "apcust_file" || SrvrVal["type"] == "brdb_file") {
                attach_flag_value = "AR";
            }
            if (fi.Exists) {
                string File_name_new = String.Format("{0}_{1}{2}", ee, DateTime.Now.ToString("yyyyMMddHHmmss"), sExt);
                fi.MoveTo(Server.MapPath(file_path + File_name_new));
                msg = "此檔案已存在！已覆蓋檔案！";
            }
        } else {
            //2012/5/2增加，因請款單及對催帳客函傳入路徑為需擬路徑/btbrt/custdb_file，所以另外判斷
            if (SrvrVal["type"] == "custdb_file" || SrvrVal["type"] == "db_file" || SrvrVal["type"] == "custresp_file") {
                //如果存在的話原來的要備份起來,備份規則：檔名_年月日時分秒
                if (fi.Exists) {
                    attach_flag_value = "U";
                    saveFlag = false;
                    msg = "該檔案已經存在!!\\n\\n請將該檔案更名，並重新上傳!!";
                }
            } else if (SrvrVal["type"] == "photo") {//圖檔判斷
                if (fi.Exists) {
                    attach_flag_value = "U";
                    saveFlag = false;
                    msg = "該檔案已經存在!!\\n\\n請將該檔案更名，並重新上傳!!";
                } else {
                    if (ee_new != "") {//編修時檢查上傳檔名與更名檔名是否相同
                        if (original_name == ee_new) {
                            saveFlag = false;
                            msg = "該檔案" + original_name + "與更名後檔案相同!!\\n\\n請將該檔案更名，並重新上傳!!";
                        }
                    }
                    attach_flag_value = "A";
                }
            } else if (SrvrVal["type"] == "brdb_file") {//英文invoice,檔名命名規則：E+branch+dept+ar_no副檔名為使用者上傳
                if (fi.Exists) {
                    string File_name_new = String.Format("{0}_{1}{2}", ee, DateTime.Now.ToString("yyyyMMddHHmmss"), sExt);
                    fi.MoveTo(Server.MapPath(file_path + File_name_new));
                }
            } else {
                //如果存在的話原來的要備份起來,備份規則：檔名_年月日時分秒
                if (fi.Exists) {
                    attach_flag_value = "U";
                    saveFlag = false;
                    msg = "該檔案已經存在!!\\n\\n請將該檔案更名，並重新上傳!!";
                }
            }
        }

        SrvrVal["aa"] = (file_path + ee + sExt).Replace("\\", "\\\\");//最後儲存的檔名(含路徑)
        SrvrVal["ee"] = (ee + sExt).Replace("\\", "\\\\");//最後儲存的檔名
        SrvrVal["bb"] = (original_name + sExt).Replace("\\", "\\\\");//原始儲存的檔名
        SrvrVal["zz"] = (original_name).Replace("\\", "\\\\");//原始儲存的檔名(不含ext)

        if (Request["chkTest"] == "TEST") {
            Response.Write("<HR>");
            Response.Write("FName=" + FName + "<BR>");
            Response.Write("original_name=" + original_name + "<BR>");
            Response.Write("sExt=" + sExt + "<BR>");
            Response.Write("attach_size=" + attach_size + "<BR>");
            Response.Write("saveAs=" + Server.MapPath(file_path + ee + sExt) + "<BR>");
            Response.End();
        }
        
        if (saveFlag) {
            uploadedFile.SaveAs(Server.MapPath(file_path + ee + sExt));
        }

        //傳回window.opener之欄位
        StringBuilder strOut = new StringBuilder();
        strOut.AppendLine("<script type='text/javascript' src='"+Page.ResolveUrl("~/js/lib/jquery-1.12.4.min.js")+"'><"+"/script>");
        strOut.AppendLine("<script language=javascript>");
        if (msg != "")
            strOut.AppendLine("alert('" + msg + "');");

        if (saveFlag) {
            if (SrvrVal.TryGet("form_name").Length > 0)
                strOut.AppendLine("$('#" + SrvrVal["form_name"] + "', window.opener.document).val('" + SrvrVal["aa"] + "');");
            if (SrvrVal.TryGet("size_name").Length > 0)
                strOut.AppendLine("$('#" + SrvrVal["size_name"] + "', window.opener.document).val('" + attach_size + "');");
            if (SrvrVal.TryGet("file_name").Length > 0)
                strOut.AppendLine("$('#" + SrvrVal["file_name"] + "', window.opener.document).val('" + SrvrVal["ee"] + "');");
            if (SrvrVal.TryGet("btnname").Length > 0)
                strOut.AppendLine("$('#" + SrvrVal["btnname"] + "', window.opener.document).prop('disabled',true);");
            if (SrvrVal.TryGet("doc_in_date").Length > 0)
                strOut.AppendLine("$('#" + SrvrVal["doc_in_date"] + "', window.opener.document).val('" + DateTime.Now.ToShortDateString() + "');");
            if (SrvrVal.TryGet("doc_in_scode").Length > 0)
                strOut.AppendLine("$('#" + SrvrVal["doc_in_scode"] + "', window.opener.document).val('" + Session["scode"] + "');");
            if (SrvrVal.TryGet("doc_in_scodenm").Length > 0)
                strOut.AppendLine("$('#" + SrvrVal["doc_in_scodenm"] + "', window.opener.document).val('" + Session["sc_name"] + "');");
            if (SrvrVal.TryGet("source_name").Length > 0)
                strOut.AppendLine("$('#" + SrvrVal["source_name"] + "', window.opener.document).val('" + SrvrVal["bb"] + "');");
            if (SrvrVal.TryGet("draw_name").Length > 0)
                strOut.AppendLine("$('#" + SrvrVal["draw_name"] + "', window.opener.document).val('" + file_path + ee + sExt + "');");
            if (SrvrVal.TryGet("dir_name").Length > 0)
                strOut.AppendLine("$('#" + SrvrVal["dir_name"] + "', window.opener.document).val('" + file_path + "');");
            if (SrvrVal.TryGet("attach_flag_name").Length > 0)
                strOut.AppendLine("$('#" + SrvrVal["attach_flag_name"] + "', window.opener.document).val('" + attach_flag_value + "');");
            if (SrvrVal.TryGet("db_file_flag").Length > 0) {
                //2012/5/2 將對催帳客函或請款單產生方式改為「使用者自行上傳」
                strOut.AppendLine("for(var i=0;i<=$(\"input[name='" + SrvrVal["db_file_flag"] + "']\", window.opener.document).length-1;i++){");
                strOut.AppendLine("     if(window.opener.document.getElementsByName('<%=db_file_flag%>')[i].value == 'Y' {");
                strOut.AppendLine("         window.opener.document.getElementsByName('<%=db_file_flag%>')[i].checked=true;");
                strOut.AppendLine("     }");
                strOut.AppendLine("}");

                if (SrvrVal["btnname"].Length > 0) {
                    if (SrvrVal["type"] == "custresp_file") {
                        strOut.AppendLine("$('#" + SrvrVal["draw_name"] + "', window.opener.document).prop('disabled',true);");
                    } else {
                        strOut.AppendLine("$('#" + SrvrVal["draw_name"] + "', window.opener.document).prop('disabled',false);");
                    }
                }
            }
        }
        
        //strOut.AppendLine("window.close();");
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
      <form name="AttachForm" action="upload_win_file_new.aspx?<%#QueryString%>" method="Post" enctype="multipart/form-data" accept-charset="UTF-8">
        <table width="100%" border="0" cellspacing="0" cellpadding="0" align="center">
            <tr>
                <td align="left">
          　         上傳檔案到本資料欄位:<br>
          　         <input type="file" id="theFile" name="theFile" size="25">
          　         <input type="text" id="hidFile" name="hidFile">
				　   <input type="hidden" id="hidoverwrite" name="hidoverwrite">
          　         <input type="text" id="nfilename" name="nfilename" value="<%=SrvrVal.TryGet("nfilename")%>">
          　         <input type="text" id="tablename" name="tablename" value="<%=SrvrVal.TryGet("tablename")%>">
          　         <input type="text" id="submitTask" name="submitTask" value="">
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
                    <input type="button" value="關閉視窗" onclick="javascript:window.close()" id="button2" name="button2" class="cbutton">
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
        var fileext = "<%=SrvrVal.TryGet("fileext")%>";
        if (fileext != "") {
            var re = new RegExp(fileext, 'gi')//允許的副檔名,ex: pdf|gif
            if (!re.test(attachfilename)) {
                alert("檔案類型錯誤，可接受的副檔名為：" + fileext.ReplaceAll("|", "、"));
                return false;
            }
        }

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
