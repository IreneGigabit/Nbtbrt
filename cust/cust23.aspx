﻿<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Web" %>
<%@ Import Namespace = "System.Web.UI" %>
<%@ Import Namespace = "System.Web.UI.WebControls" %>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<script runat="server">
    protected string HTProgCap = "客戶特殊備註管理";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "cust23";//HttpContext.Current.Request["prgid"] ?? "";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";
    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";
    protected string SQL = "";
    protected string td_tscode = "", html_apclass = "", html_country = "";
    protected string branch = "";
    //營洽選單
    protected string html_scode = "";
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

        branch = Sys.GetSession("seBranch");
        
        if (Sys.GetSession("dept") == "P")
        {
            html_scode = Sys.getCustScode("Q", "P", 64, "").Option("{pscode}", "{pscode}_{sc_name}");
            html_scode += "<option value='np'>np_部門(開放客戶)</option>";
        }
        else
        {
            html_scode = Sys.getCustScode("Q", "T", 64, "").Option("{tscode}", "{tscode}_{sc_name}");
            html_scode += "<option value='nt'>nt_部門(開放客戶)</option>";
        }
        
        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        HTProgCap = myToken.Title;
        DebugStr = myToken.DebugStr;
        if (HTProgRight >= 0) {
            PageLayout();
            this.DataBind();
        }
    }

    private void PageLayout() {
        if ((HTProgRight & 2) > 0) {
            StrFormBtnTop += "<a href=javascript:GoToAdd()>[新增]</a>";
            StrFormBtn += "<input type=\"button\" id=\"btnSrch\" value=\"查　詢\" class=\"cbutton bsubmit\" />\n";
            StrFormBtn += "<input type=\"button\" id=\"btnRest\" value=\"重　填\" class=\"cbutton\" />\n";
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
    <table border="0" class="bluetable" cellspacing="1" cellpadding="2" width="50%">	
	<tr>
		<TD class=lightbluetable align=right style="width:30%">客戶編號：</TD>
	    <TD class=whitetablebg align=left style="width:50%">
            <INPUT type=text name="cust_area" id="cust_area" readonly class="SEdit" size="1" value="<%=branch%>">-
	        <INPUT type="text" name="cust_seq" id="cust_seq" class="InputNumOnly" maxlength="5" size="6">
        </TD>
	</tr>
	<tr>
		<td class="lightbluetable" align="right">客戶名稱：</td>
		<td class="whitetablebg" align="left" colspan="3">
		<input type="Text" name="ap_cname" id="ap_cname" size="40" maxlength="40" value=""></td>
	</tr>
        <tr><TD class=lightbluetable align=right>營　　洽：</TD>
	<TD class=whitetablebg align=left>
		<input type="hidden" name="pwhescode">
		<Select NAME="scode" id="scode" size=1>
		<%--<%if (HTProgRight AND 128) <> 0 or (HTProgRight AND 64) <> 0 then%>--%>
			
			<%--<option value="<%=ucase(session("se_Branch"))%><%=ucase(session("Dept"))%>">部門(開放客戶)</option>--%>
		<%=html_scode%>
            <option value="all">全部</option>
		</SELECT>
	</TD>
</tr>
</table>

</center>
</form>
<table border="0" width="100%" cellspacing="0" cellpadding="0">
	<tr>
        <td width="100%">     
		<p align="center">
        <%# StrFormBtn%> 
	    </td>
	</tr>
</table>
<br>
<div align="left">

</div>

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
        $("input.dateField").datepick();
    }


    //[重填]
    $("#btnRest").click(function (e) {
        reg.reset();
        this_init();
    });

    $(".dateField").blur(function (e) {
        ChkDate(this);
    });

    //[查詢]
    $("#btnSrch").click(function (e) {
        reg.action = "cust23_List.aspx?prgid=cust23&cust_area=<%=branch%>";
        reg.target = "Etop"
        reg.submit();
    });

    function GoToAdd() {
        var url = "cust23_Edit.aspx?prgid=cust23&submitTask=A";
        reg.target = "Eblank";
        reg.action = url;
        reg.submit();
    }

</script>
