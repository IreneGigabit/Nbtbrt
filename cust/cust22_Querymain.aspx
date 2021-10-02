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
    protected string HTProgCap = " 案件主檔查詢";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "cust22";//HttpContext.Current.Request["prgid"] ?? "";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";
    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";
    protected string SQL = "";
    protected string dept = "";
    protected string html_dept = "";
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

        dept = Sys.GetSession("dept");
        if (Sys.GetSession("dept") == "P")
        {
            html_dept = "<option value='P'>專利國內案</option>";
            html_dept += "<option value='PE'>專利出口案</option>";
        }
        else
        {
            html_dept = "<option value='T'>商標國內案</option>";
            html_dept += "<option value='TE'>商標出口案</option>";
        }

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
        <td class="text9" nowrap="nowrap">&nbsp;【<%#prgid%> <%#HTProgCap%>-<%=(dept == "P")?"專利":"商標"%>】</td>
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
    <TABLE border=0 class=bluetable cellspacing=1 cellpadding=2 width="75%">
	<tr><TD class=lightbluetable align=right>部門別：</TD>
		<TD class=whitetablebg align=left>
		    <select name="qrydept" size=1>
                <%=html_dept%>
		    </select>
		</TD>
	</tr>
	<TR>
		<TD class=lightbluetable align=right>案件編號：</TD>
		<TD class=whitetablebg align=left>
		    <INPUT type=text name="qryseq" id="qryseq" size="6" maxlength=6>
		    <INPUT type=text name="qryseq1" size="1" maxlength=1>
		</TD>
	</tr>
	<TR>
		<TD class=lightbluetable align=right>案件名稱：</TD>
		<TD class=whitetablebg align=left><INPUT type=text name="qrycappl_name" id="qrycappl_name" size="60" maxlength=100></TD>
	</tr>
	<tr><TD class=lightbluetable align=right>營洽人員：</TD>
		<TD class=whitetablebg align=left>
			<Select NAME="qryscode" id="qryscode" size=1>
				<option value="">請選擇</option>
                <%=html_scode%>
			</SELECT>
		</TD>
	</tr>
	<tr><TD class=lightbluetable align=right>客戶編號：</TD>
		<TD class=whitetablebg align=left>
		    <INPUT type="text" name="qrycust_area" size="1" maxlength=1 readonly class=SEdit value="<%=Sys.GetSession("seBranch")%>">
		    -<INPUT type="text" name="qrycust_seq" id="qrycust_seq" size="7" maxlength=6>
		</TD>
	</tr>
	<tr><TD class=lightbluetable align=right>立案日期：</TD>
		<TD class=whitetablebg align=left>
            <input type="text" name="qryin_sdate" id="qryin_sdate" size="10" readonly="readonly" class="dateField">～
		    <input type="text" name="qryin_edate" id="qryin_edate" size="10" readonly="readonly" class="dateField">
		</TD>
	</tr>
</TABLE>
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
    <font size=2>
[備註]<br>
權限C：權限A+B：專商全部，權限B：區所主管、專利主管，權限A：組主管 
</font>
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

        if (NulltoEmpty($("#qryseq").val()) == "" && NulltoEmpty($("#qrycappl_name").val()) == "" && NulltoEmpty($("#qryscode").val()) == ""
            && NulltoEmpty($("#qrycust_seq").val()) == "" && NulltoEmpty($("#qryin_sdate").val()) == "" && NulltoEmpty($("#qryin_edate").val()) == "")
        {
            alert("請輸入「案件編號」、「案件名稱」、「接洽人員」、「客戶編號」及「立案日期」任一條件");
            return false;
        }

        if ($("#qryin_sdate").val() != "" && $.isDate($("#qryin_sdate").val()) == false) {
            alert("立案日期起始資料必須為日期型態!!");
            return false;
        }
        if ($("#qryin_edate").val() != "" && $.isDate($("#qryin_edate").val()) == false) {
            alert("立案日期終止資料必須為日期型態!!");
            return false;
        }
        if (chkSEDate($("#qryin_sdate").val(), $("#qryin_edate").val(), "日期範圍") == false) {
            return false;
        }

        reg.action = "cust22_Listmain.aspx?prgid=<%=prgid%>";
        reg.submit();
    
    });


</script>
