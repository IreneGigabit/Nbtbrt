<%@ Page Language="C#" CodePage="65001"%>

<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<script runat="server">
    protected string HTProgCap = "";//"[案件查詢]";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "brt11_1";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";
    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";
  
    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

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
            StrFormBtn += "<input type=\"button\" id=\"btnSrch\" value=\"查　詢\" class=\"cbutton\" />\n";
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

<form id="reg" name="reg" method="post">
    <input type="hidden" id="prgid" name="prgid" value="<%=prgid%>">

    <div id="id-div-slide">
        <TABLE border=0 class=bluetable cellspacing=1 cellpadding=2 width="80%" align="center">	
	        <TR>
		        <TD class=lightbluetable align=right width=40%>案件編號區間：</TD>
		        <TD class=whitetablebg align=left>
                    <INPUT type=text id="sfx_seq" name="sfx_seq" size="5" value=1>~<INPUT type=text id="efx_seq" name="efx_seq" size="5" value=99999>
		        </TD>
	        </TR>
	        <TR>
		        <TD class=lightbluetable align=right width=40%>申請號：</TD>
		        <TD class=whitetablebg align=left>
                    <INPUT type=text id="tfx_apply_no" name="tfx_apply_no" size="20" maxlength="20">
		        </TD>
	        </TR>
	        <TR>	
		        <TD class=lightbluetable align=right>註冊號：</TD>
		        <TD class=whitetablebg align=left>
                    <input type=text id="tfx_issue_no" name="tfx_issue_no" size="20" maxlength=20>
		        </TD>
	        </TR>
	        <TR>	
		        <TD class=lightbluetable align=right>商標名稱：</TD>
		        <TD class=whitetablebg align=left>
                    <INPUT type=text id="pfx_appl_name" name="pfx_appl_name" size="20">
		        </TD>
	        </TR>
	        <TR>	
		        <TD class=lightbluetable align=right>客戶編號：</TD>
		        <TD class=whitetablebg align=left>
                    <INPUT type=text id="pfx_cust_area" name="pfx_cust_area" value="<%=Request["cust_area"]%>" readonly class="Sedit" size=1>-<INPUT type=text id="Ifx_cust_seq" name="Ifx_cust_seq" value="<%=Request["cust_seq"]%>" size="5">
		        </TD>
	        </TR>
	        <TR id=tr_apcustno >	
		        <TD class=lightbluetable align=right>申請人號(統編)：</TD>
		        <TD class=whitetablebg align=left>
                    <input type=text id="tfx_apcust_no" name="tfx_apcust_no" size="10">
		            <input type=hidden id="type" name="type" value="<%=Request["type"]%>">
		        </TD>
	        </TR>
        </TABLE>

        <br>
        <%#DebugStr%>
        <table id="tabBtn" border="0" width="100%" cellspacing="0" cellpadding="0" align="center">
	        <tr><td width="100%" align="center">
			    <%#StrFormBtn%>
	        </td></tr>
        </table>
    </div>
</form>

<div id="dialog"></div>

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

        if ($("#type").val().toLowerCase() == "ext") {
            $("#tr_apcustno").hide();
        }
    }

    //[查詢]
    $("#btnSrch").click(function (e) {
        if ($("#sfx_seq").val() == "" && $("#pfx_appl_name").val() == "" && $("#tfx_issue_no").val() == "") {
            alert("請輸入案件編號區間、或案件名稱或註冊號");
            ("#tfx_issue_no").focus
            return false;
        }

        if ($("#efx_seq").val() == "") {
            $("#efx_seq").val($("#sfx_seq").val());
        }

        reg.action = "<%=HTProgPrefix%>LISTSQL.aspx";
        //reg.target = "Eblank";
        reg.submit();
    });

    //[重填]
    $("#btnRest").click(function (e) {
        reg.reset();
        this_init();
    });

    //////////////////////
</script>
