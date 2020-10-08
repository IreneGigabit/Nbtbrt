<%@ Page Language="C#" CodePage="65001"%>
<%@Import Namespace = "System.Collections.Generic"%>

<script runat="server">
    protected string DebugStr = "";
    protected string QueryString = "";
    protected string type = "";
    protected string fileext = "";
    protected string cont = "";
    protected string msg = "";
    protected int attach_size = 0;

    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        TokenN myToken = new TokenN();
        DebugStr = myToken.DebugStr;

        QueryString = Request.ServerVariables["QUERY_STRING"];
        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");

        type = (Request["type"] ?? "").ToLower();
        fileext = (Request["fileext"] ?? "").ToLower();//指定允許的副檔名,ex: pdf|gif

        if (type == "doc") {
            cont = "檔案上傳";
        } else if (type == "ext_photo" || type == "dmt_photo") {
            cont = "圖檔上傳";
        } else if (type == "custdb_file") {
            cont = "對催帳客函檔案上傳";
        } else if (type == "db_file") {
            cont = "請款單檔案上傳";
        } else if (type == "custresp_file") {
            cont = "對催帳客戶回應檔案上傳";
        } else if (type == "apcust_file") {
            cont = "契約書/委任書檔案上傳";
        } else if (type == "brdb_file") {
            cont = "英文Invoice檔案上傳";
        } else {
            Response.Write("<html><head><title>RE?!1ORE!?DAo3?μoμ!!C</title></head><body bgcolor=#ffffff><br><br><p><center>RE?!1ORE!?DAo3?μoμ!!C");
            Response.Write("<form><input type=button value=Ao3?μoμ! onclick='window.close()'></form></center></body></html>");
            Response.End();
        }

        this.DataBind();
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta http-equiv="x-ua-compatible" content="ie=10">
<title>文件上傳</title>
<link rel="stylesheet" type="text/css" href="<%=Page.ResolveUrl("~/inc/setstyle.css")%>" />
<link rel="stylesheet" type="text/css" href="<%=Page.ResolveUrl("~/js/lib/jquery-ui.min.css")%>" />
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/jquery-1.12.4.min.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/jquery-ui.min.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/util.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/jquery.irene.form.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/client_chk.js")%>"></script>
</head>

<body bgcolor="#FFFFFF">
    <p align="center"><big><font face="標楷體" color="#004000"><strong><big><big><%=cont%></big></big></strong></font></big></p>
    <center>
      <form id="AttachForm" name="AttachForm" action="upload_win_file_new.aspx?<%#QueryString%>" method="Post" enctype="multipart/form-data" accept-charset="UTF-8">
        <table width="100%" border="0" cellspacing="0" cellpadding="0" align="center">
            <tr>
                <td align="left">
          　         上傳檔案到本資料欄位:<br>
          　         <input type="file" id="theFile" name="theFile" size="25">
                    <br>&nbsp;
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
    <div id="result_msgbox"></div>
</body>
</html>
<script language="javascript" type="text/javascript">
    $(function () {
    });

    function AttachFile() {
        var attachfilename = $("#theFile").val();
        var fileext = "<%=ReqVal.TryGet("fileext")%>";
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

        var formData = new FormData($("#AttachForm")[0])
        $.ajax({
            url: getRootPath() + '/sub/UpLoadFile.ashx?<%=QueryString%>',
            type: "POST",
            dataType: null,
            data: formData,
            headers: {},
            cache: false,
            contentType: false,
            processData: false,
            forceSync: false,
            success: function (data) { file.onSuccess(data); },
            error: function (xhr, status, errMsg) { file.onError(xhr, status, errMsg); },
            complete: function () { file.onComplete(); }
        });
    }

    var file = {};
    file.onError = function (xhr, status, errMsg) {
        $("#result_msgbox").html(xhr.responseText);
        $("#result_msgbox").dialog({ width: 600 });
    }
    file.onSuccess = function (data) {
        if (data.msg != "") {
            alert(data.msg);
            return false;
        }

        if ("<%=ReqVal.TryGet("form_name")%>".length > 0)
            $('#<%=ReqVal.TryGet("form_name")%>', window.opener.document).val(data.full_path);
        if ("<%=ReqVal.TryGet("size_name")%>".length > 0)
            $('#<%=ReqVal.TryGet("size_name")%>', window.opener.document).val(data.size);
        if ("<%=ReqVal.TryGet("file_name")%>".length > 0)
            $('#<%=ReqVal.TryGet("file_name")%>', window.opener.document).val(data.name);
        if ("<%=ReqVal.TryGet("btnname")%>".length > 0)
            $('#<%=ReqVal.TryGet("btnname")%>', window.opener.document).prop('disabled', true);
        if ("<%=ReqVal.TryGet("doc_in_date")%>".length > 0)
            $('#<%=ReqVal.TryGet("doc_in_date")%>', window.opener.document).val((new Date()).format("yyyy/M/d"));
        if ("<%=ReqVal.TryGet("doc_in_scode")%>".length > 0)
            $('#<%=ReqVal.TryGet("doc_in_scode")%>', window.opener.document).val(data.in_scode);
        if ("<%=ReqVal.TryGet("doc_in_scodenm")%>".length > 0)
            $('#<%=ReqVal.TryGet("doc_in_scodenm")%>', window.opener.document).val(data.in_scodenm);
        if ("<%=ReqVal.TryGet("source_name")%>".length > 0)
            $('#<%=ReqVal.TryGet("source_name")%>', window.opener.document).val(data.source);
        if ("<%=ReqVal.TryGet("draw_name")%>".length > 0)
            $('#<%=ReqVal.TryGet("draw_name")%>', window.opener.document).val(data.full_path);
        if ("<%=ReqVal.TryGet("dir_name")%>".length > 0)
            $('#<%=ReqVal.TryGet("dir_name")%>', window.opener.document).val(data.dir);
        if ("<%=ReqVal.TryGet("attach_flag_name")%>".length > 0)
            $('#<%=ReqVal.TryGet("attach_flag_name")%>', window.opener.document).val(data.attach_flag);
        if ("<%=ReqVal.TryGet("db_file_flag")%>".length > 0) {
            //2012/5/2 將對催帳客函或請款單產生方式改為「使用者自行上傳」
            for (var i = 0; i <= $("input[name='<%=ReqVal.TryGet("db_file_flag")%>']", window.opener.document).length - 1; i++) {
                if (window.opener.document.getElementsByName('<%=ReqVal.TryGet("db_file_flag")%>')[i].value == 'Y') {
                    window.opener.document.getElementsByName('<%=ReqVal.TryGet("db_file_flag")%>')[i].checked = true;
                }
            }

            if ("<%=ReqVal.TryGet("btnname")%>".length > 0) {
                if ("<%=ReqVal.TryGet("type")%>" == "custresp_file") {
                    $('#<%=ReqVal.TryGet("draw_name")%>', window.opener.document).prop('disabled', true);
                } else {
                    $('#<%=ReqVal.TryGet("draw_name")%>', window.opener.document).prop('disabled', false);
                }
            }
        }
        window.close();
    }

    file.onComplete = function () {
        $("#button1").prop("disabled", false);
    }
</script>
