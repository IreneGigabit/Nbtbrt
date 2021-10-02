<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Web" %>
<%@ Import Namespace = "System.Web.UI" %>
<%@ Import Namespace = "System.Web.UI.WebControls" %>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<script runat="server">
    protected string HTProgCap = "雙邊代理查詢";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "cust46";//HttpContext.Current.Request["prgid"] ?? "";//程式檔名前綴
    protected string HTProgCode = "cust46";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";
    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";
    protected string submitTask = "";
    protected string cust_area = "";

    DBHelper conn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    DBHelper cnn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    private void Page_Unload(System.Object sender, System.EventArgs e) {
        if (conn != null) conn.Dispose();
        if (cnn != null) cnn.Dispose();
    }

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        cust_area = Sys.GetSession("seBranch");

        
        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        //HTProgCap = myToken.Title;
        DebugStr = myToken.DebugStr;
        if (HTProgRight >= 0) {

            PageLayout();
            this.DataBind();
        }
    }

    private void PageLayout()
    {
        if ((HTProgRight & 2) > 0)
        {
            StrFormBtnTop += "<a href=http://web02/BRP/cust/雙邊代理查詢操作手冊.files/frame.htm target=_blank>[補助說明]</a>";
        }
    }
    
</script>

<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title><%#HTProgCap%></title>
    <uc1:head_inc_form runat="server" ID="head_inc_form" />
</head>

<body>
<table cellspacing="1" cellpadding="0" width="98%" border="0" align="center">
    <tr>
        <td class="text9" nowrap="nowrap">&nbsp;【<%#prgid%> <%#HTProgCap%>】</td>
        <td class="FormLink" valign="top" align="right" nowrap="nowrap">
            <%#StrFormBtnTop%>
        </td>
    </tr>
    <tr>
        <td colspan="2"><hr class="style-one"/></td>
    </tr>
</table>

<form name="reg" method="post" id="formData" action>
<input type=hidden name=prgid value="<%=prgid%>">
<center>
<TABLE border=0 class=bluetable cellspacing=1 cellpadding=2 width="60%">		
	<TR>
		<TD class=lightbluetable align=right width="35%">客戶名稱(中)：</TD>
		<TD class=whitetablebg align=left width="65%">
		<INPUT type=text name="ap_cname" id="ap_cname" size="33" maxlength=30 value=""></TD>
	</TR>
	<TR>
		<TD class=lightbluetable align=right>客戶名稱(英)：</TD>
		<TD class=whitetablebg align=left >
		<INPUT type=text name="ap_ename" id="ap_ename"  size="33" maxlength=30 value=""></TD>
	</TR>
	<TR>
		<TD class=lightbluetable align=right>代表人(中)：</TD>
		<TD class=whitetablebg align=left >
		<INPUT type=text name="ap_crep" id="ap_crep" size="33" maxlength=30 value=""></TD>
	</TR>
	<TR>
		<TD class=lightbluetable align=right>代表人(英)：</TD>
		<TD class=whitetablebg align=left >
		<INPUT type=text name="ap_erep" id="ap_erep" size="33" maxlength=30 value=""></TD>
	</TR>
	<TR>
		<TD class=lightbluetable align=right>客戶統編：</TD>
		<TD class=whitetablebg align=left >
		<INPUT type=text name="id_no" id="id_no" size="11" maxlength=10 value=""></TD>
	</TR>
</TABLE>
</center>

</form>
<table border="0" width="100%" cellspacing="0" cellpadding="0">
	<tr><td width="100%">     
		<p align="center">
		<input type="button" value="查詢" class="cbutton" style="cursor:hand" id="btnSrch" name="btnSrch">
		<input type="button" value="重填" class="cbutton" style="cursor:hand" id="btnRest" name="btnRest">
	</td></tr>
</table>
<br>
<font color="red">[說明]</font><br>
1. 此作業提供同時檢索[北、中、南、雄]四區所之資料庫功能，<font color="blue">只要符合上述任一輸入條件之客戶或申請人皆會顯示</font><br>
2. <font color="blue">除了「客戶統編」查詢條件<font color="red">不</font>提供關鍵字查詢之外</font>，其餘查詢條件皆提供關鍵字查詢<br>
3. 若統編為7碼，務必在前面加"0"，否則將查詢不到。如統一編號為1234567，則輸入<font color="red">0</font>1234567。

<div id="dialog"></div>

<iframe id="ActFrame" name="ActFrame" src="about:blank" width="100%" height="500" style="display:none"></iframe>
</body>
</html>

<script language="javascript" type="text/javascript">
    $(function () {
        this_init();
    });

    function this_init() {
        if (window.parent.tt !== undefined) {
            window.parent.tt.rows = "100%,0%";
        }
    }

    //[重填]
    $("#btnRest").click(function (e) {
        reg.reset();
        this_init();
    });

    //[查詢]
    $("#btnSrch").click(function (e) {

        if ($.trim($("#id_no").val()) == "" && $.trim($("#ap_cname").val()) == "" && $.trim($("#ap_ename").val()) == "" && $.trim($("#ap_crep").val()) == "" && $.trim($("#ap_erep").val()) == "")
        {
            alert("請輸入任一條件!");
            return false;
        }

        reg.action = "cust46_List.aspx?prgid=<%=prgid%>";
        reg.submit();
    });


</script>
