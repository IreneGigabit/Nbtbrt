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
    protected string HTProgCap = "客戶/申請人綜合查詢作業";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "cust45";//HttpContext.Current.Request["prgid"] ?? "";//程式檔名前綴
    protected string HTProgCode = "cust45";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";
    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";
    //protected string submitTask = "";
    protected string cust_area = "";
    //種類
    protected string html_apclass = Sys.getCustCode("apclass", "", "sortfld").Option("{cust_code}", "{cust_code}_{code_name}");
    //國籍
    protected string html_country = Sys.getCountry().Option("{coun_code}", "{coun_code}_{coun_c}");
    //客戶等級
    protected string html_level = Sys.getCustCode("level", "", "sortfld").Option("{cust_code}", "{cust_code}_{code_name}");
    //營洽選單
    protected string html_Scode = "";

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
        if (Sys.GetSession("dept") == "P")
        {
            html_Scode = Sys.getCustScode("Q", "P", 64, "").Option("{pscode}", "{pscode}_{sc_name}");
            html_Scode += "<option value='np'>np_部門(開放客戶)</option>";
        }
        else
        {
            html_Scode = Sys.getCustScode("Q", "T", 64, "").Option("{tscode}", "{tscode}_{sc_name}");
             html_Scode += "<option value='nt'>nt_部門(開放客戶)</option>";
        }

        
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
            StrFormBtnTop += "<a href=http://web02/BRP/cust/客戶申請人綜合查詢.files/frame.htm target=_blank>[補助說明]</a>";
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
<TABLE border=0 class=bluetable cellspacing=1 cellpadding=2 width="92%">
	<tr><td class=lightbluetable align=left colspan="4">■ 對象</td></tr>
	<tr><TD class=lightbluetable align=right>搜尋對象：</TD>
		<td class="whitetablebg" align="left" colspan="3">
			<input type=radio name=custtype value="vcustlist" checked onclick="custtype_onclick('vcustlist')">客戶&nbsp;
			<input type=radio name=custtype value="vcust_apcust" onclick="custtype_onclick('vcust_apcust')">客戶+申請人&nbsp;
		</td>
	</tr>
	<tr><td class=lightbluetable align=left colspan="4">■ 基本資料</td></tr>
	<TR><TD class=lightbluetable align=right>客戶編號：</TD>
		<TD class=whitetablebg align=left>
		<INPUT type=text name="cust_area" readonly class="SEdit" size="1" value="<%=cust_area%>">-
		<INPUT type="text" class="InputNumOnly" name="cust_seq" id="cust_seq" size="6"></TD>
		<TD class=lightbluetable align=right>客戶國籍：</TD>
		<td class=whitetablebg align=left>
			<select name=ap_country id="ap_country" size=1>
			<%=html_country%>
			</select></td>		
	</TR>
	<tr><TD class=lightbluetable align=right>客戶種類：</TD>
		<td class=whitetablebg align=left>
		<select name=apclass id="apclass" size=1><%=html_apclass%></select></td>
		<TD class=lightbluetable align=right>統編/身分證號：</TD>
		<TD class=whitetablebg align=left>
		<INPUT type="text" name="id_no" id="id_no" size="11" maxlength=10></TD>
	</tr>
	<TR>
		<TD class=lightbluetable align=right>中文名稱：</TD>
		<TD class=whitetablebg align=left><INPUT type=text name="ap_cname" id="ap_cname" size="22" maxlength=30></TD>
		<TD class=lightbluetable align=right>英文名稱：</TD>
		<TD class=whitetablebg align=left><INPUT type=text name="ap_ename" id="ap_ename" size="22" maxlength=40></TD>
	</TR>
	<TR>
		<td class="lightbluetable" align="right">代表人(中)：</td>
		<TD class=whitetablebg align=left>
		<INPUT type=text name="ap_crep" id="ap_crep" size="22" maxlength=20></TD>
		<td class="lightbluetable" align="right">代表人(英)：</td>
		<TD class=whitetablebg align=left>
		<INPUT type=text name="ap_erep" id="ap_erep" size="22" maxlength=40></TD>
	</TR>
	<tr><td class=lightbluetable align=left colspan="4">■ 聯絡方式</td></tr>
	<tr><TD class=lightbluetable align=right>地　　址：</TD>
		<td class="whitetablebg" align="left" colspan="3">
			<INPUT type=text name="addr" id="addr" size=44 maxlength=40 >&nbsp;&nbsp;&nbsp;<em>(搜尋範圍包括:證照中文地址,聯絡地址,對帳地址)</em> 
		</td>
	</tr>
	<tr><TD class=lightbluetable align=right>電　　話：</TD>
		<td class="whitetablebg" align="left" colspan="3">
			<INPUT type=text class="InputNumOnly" name="tel" id="tel" size=44 maxlength=10 >&nbsp;&nbsp;&nbsp;<em>(搜尋範圍包括:聯絡電話,會計電話)</em>
		</td>
	</tr>
	<tr><TD class=lightbluetable align=right>電子郵件：</TD>
		<td class="whitetablebg" align="left" colspan="3">
			<input type="radio" value="All" name=emailtype checked onclick="">全部&nbsp;		
			<input type="radio" value="Y" name=emailtype onclick="">有&nbsp;
			<input type="radio" value="N" name=emailtype onclick="">無&nbsp;
			<input type="radio" value="IN" name=emailtype onclick="">指定條件
			<INPUT type="text" name="email" id="email" size=44 maxlength=40 onblur="email_onblur();">
		</td>
	</tr>

    <tr id="display_scode_1"><td class=lightbluetable align=left colspan="4">■ 營洽客戶</td></tr>
	<tr id="display_scode_2"><TD class=lightbluetable align=right><%=(Sys.GetSession("dept") == "P") ? "專利" : "商標"%>營洽：</TD> <!--必須根據dept決定要顯示專利營洽or商標營洽-->
		<td class="whitetablebg" align="left" >
			<input type="hidden" name="pwhescode" value="">
			<Select NAME="scode" id="scode" size=1 ><%=html_Scode%>
		<%--	<%if (HTProgRight AND 128) <> 0 or (HTProgRight AND 64) <> 0 then%>
				<option value="">請選擇</option>
				<option value="all">全部</option>
			<%end if%>
			<%if (HTProgRight AND 128)=0 or (HTProgRight AND 64)=0 then%>
				<option value="<%=ucase(session("se_Branch"))%><%=ucase(session("Dept"))%>">部門(開放客戶)</option>
			<%end if%>
			<%=scodehtml%>--%>
			</SELECT>
		</td>
		<TD class=lightbluetable align=right>客戶等級：</TD>
		<TD class=whitetablebg align=left>
			<select name=level id="level" size=1><%=html_level%></select>
		</TD>
	</tr>
    <tr id="display_group_1"><td class=lightbluetable align=left colspan="4">■ 群組客戶</td></tr>
    <tr id="display_group_2">
		<TD class=lightbluetable align=right>群組客戶編號：</TD>
		<TD class=whitetablebg align=left colspan="3">
            <INPUT type="text" class="InputNumOnly" name="ref_seq" id="ref_seq" size="6">
		</TD>
	</tr>
    <tr id="display_other_1"><td class=lightbluetable align=left colspan="4">■ 其他</td></tr>
	<tr id="display_other_2"><TD class=lightbluetable align=right>日　　期：</TD>
		<td class="whitetablebg" align="left" colspan="3">
            <input type="hidden" name="hkind">
			<input type=radio name=dkind checked onclick="dkind_onclick('')">不指定條件
			<input type=radio name=dkind value="in_date" onclick="dkind_onclick('in_date')">建檔日期
			<input type=radio name=dkind value="All_date" onclick="dkind_onclick('All_date')">最近立案日<br><!--同時查詢 AND (dmt_date or ext_date or dmp_date or exp_date 四個欄位)-->
		    <div id="divdate" style="display:none">
		    <input type="text" name="sdate" id="sdate" size="10" readonly="readonly" class="dateField">～
		    <input type="text" name="edate" id="edate" size="10" readonly="readonly" class="dateField">
		    </div>
		</td>
	</tr>
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

    //[查詢]
    $("#btnSrch").click(function (e) {

        if ($.trim($("#cust_seq").val()) == "" && $.trim($("#ap_country").val()) == "" && $.trim($("#apclass").val()) == "" && $.trim($("#id_no").val()) == ""
            && $.trim($("#ap_cname").val()) == "" && $.trim($("#ap_ename").val()) == "" && $.trim($("#ap_crep").val()) == "" && $.trim($("#ap_erep").val()) == ""
            && $.trim($("#addr").val()) == "" && $.trim($("#tel").val()) == "" && $.trim($("#scode").val()) == "" && $.trim($("#level").val()) == ""
            && $.trim($("#ref_seq").val()) == "" && $.trim($("#sdate").val()) == "" && $.trim($("#edate").val()) == "" && $('input[name=emailtype]:checked').val() == "All")
        {
            alert("請輸入任一條件!");
            return false;
        }

        if ($("#sdate").val() != "" && $.isDate($("#sdate").val()) == false) {
            alert("日期期間起始資料必須為日期型態!!");
            return false;
        }
        if ($("#edate").val() != "" && $.isDate($("#edate").val()) == false) {
            alert("日期期間終止資料必須為日期型態!!");
            return false;
        }
        if (chkSEDate($("#sdate").val(), $("#edate").val(), "日期範圍") == false) {
            return false;
        }

        if (reg.emailtype[3].checked && reg.email.value == "") {
            alert("請輸入電子郵件指定條件內容!");
            reg.email.focus(); return false;
        }


        reg.action = "cust45_List.aspx?prgid=<%=prgid%>";
        reg.submit();
    });

    function dkind_onclick(pi) {
        reg.hkind.value = pi;
        if (pi == "") {
            reg.sdate.value = "";
            reg.edate.value = "";
            document.all.divdate.style.display = "none";
        }
        else { document.all.divdate.style.display = ""; }
    }

    function email_onblur() {
        if ($("email").val() != "")
        { reg.emailtype[3].checked = true; }
    }

    function custtype_onclick(pvalue) {
        if (pvalue == "vcust_apcust") {
            display_scode_1.style.display = "none";
            display_scode_2.style.display = "none";
            display_group_1.style.display = "none";
            display_group_2.style.display = "none";
            display_other_1.style.display = "none";
            display_other_2.style.display = "none";
        }
        else {
            display_scode_1.style.display = "";
            display_scode_2.style.display = "";
            display_group_1.style.display = "";
            display_group_2.style.display = "";
            display_other_1.style.display = "";
            display_other_2.style.display = "";
        }
    }

</script>
