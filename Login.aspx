<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>

<!DOCTYPE html>
<script runat="server">
    protected string StrProjectName = Sys.Project;//.getAppSetting("Project");
    protected string syscode = "";//系統

    private void Page_Load(Object sender, EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        syscode = Request["syscode"] ?? Sys.Sysmenu;//.getAppSetting("Sysmenu");//系統

        this.DataBind();
    }
</script>

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<meta http-equiv="x-ua-compatible" content="IE=10">
<title><%#StrProjectName%></title>
<link rel="stylesheet" type="text/css" href="<%=Page.ResolveUrl("~/js/lib/toastr.css")%>" />
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/jquery-1.12.4.min.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/toastr.min.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/client_chk.js")%>"></script>
<link href="inc/setstyle.css" rel="stylesheet" />
</head>
<body style="margin:0px;">
<center>
<form method="post" name="reg" onsubmit="formSubmit()">
<input type="hidden" name="syscode" value="<%=syscode%>" />
<br><br><br><br><br><br>
<table border="2" cellspacing="10" cellpadding="1"  style ="border:lightblue double; width:250px;height: 181px">
	<tr>
		<td bgcolor=lightblue style="padding-right: 2px; padding-left: 2px; font-weight: bolder; font-size: 12pt; padding-bottom: 8px; color: white; padding-top: 8px; font-family: 細明體; text-align: center; text-decoration: none"> 
		    <font color="darkslateblue"><%#StrProjectName%></font>
		</td>
	</tr>
	<tr>
		<td style="border:none;color: darkblue; font-family: 細明體; background-color: #eeeeee; text-align: left; ">
		    <p align="center"><font size="2">帳號： <input name="tfx_scode" id="tfx_scode" style="width:10em"></font></p>
		</td>
	</tr>
	<tr>
		<td style="border:none;color:darkblue; font-family: 細明體; background-color: #eeeeee; text-align: left">
		    <p align="center"><font size="2">密碼： <input type="password" name="tfx_sys_password" id="tfx_sys_password" style="width:10em"></font></p>
		</td>
	</tr>
	<tr>
		<td style="border:none;text-align: center">
			<input type="button" value ="登入" name="btnLogin" class="cbutton" onclick="formSubmit()">
			<input type="button" value ="取消" name="btnCancel" class="cbutton" onclick="resetform()">
		</td>
	</tr>
</table>
</form>
</center>
</body>
</html>
<script>
$(function() {
    init_form();
});

function init_form() {
    reg.tfx_scode.focus();
}

function formSubmit() {
    //if (chkNull("帳號", reg.tfx_scode)) {
    //    return false;
    //}
    //
    //if (chkNull("密碼", reg.tfx_sys_password)) {
    //    return false;
    //}
    var errmsg = "";
    errmsg += chkNull2("帳號", reg.tfx_scode);
    errmsg += chkNull2("密碼", reg.tfx_sys_password);
    if (errmsg!="") {
        //toastr.clear();
        toastr.error(errmsg);
    }else{
        reg.target = "_top";
        reg.action = "checklogin.aspx";
        reg.submit();
    }
}

document.body.onkeydown = function(e){
    if (window.event.keyCode == 13) {
        formSubmit();
    }
};

function resetform() {
	reg.reset();
}
</script>
