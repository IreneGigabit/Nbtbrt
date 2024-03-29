﻿<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data" %>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<script runat="server">
    protected string HTProgCap = "案件主檔維護";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "brt15";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";
    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";
    protected string SQL = "";

    protected string td_tscode = "";
    protected string pfx_Arcase = "";

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
        //StrFormBtnTop += "<a class=\"imgRefresh\" href=\"javascript:void(0);\" >[重新整理]</a>\n";
        //StrFormBtnTop += "<a class=\"imgQry\" href=\"javascript:void(0);\" >[查詢條件]</a>\n";
        if ((HTProgRight & 2) > 0) {
            StrFormBtn += "<input type=\"button\" id=\"btnSrch\" value=\"查　詢\" class=\"cbutton bsubmit\" />\n";
            StrFormBtn += "<input type=\"button\" id=\"btnRest\" value=\"重　填\" class=\"cbutton\" />\n";
        }

        //營洽清單
        if ((HTProgRight & 64) != 0) {
            td_tscode = "<select id='tfx_Scode' name='tfx_Scode' >";
            td_tscode += Sys.getDmtScode("", "").Option("{scode}", "{star}{scode}_{sc_name}", "style='color:{color}'", true);
            td_tscode += "<option value='" + Sys.GetSession("seBranch") + Sys.GetSession("dept") + "'>" + Sys.GetSession("seBranch") + Sys.GetSession("dept").ToUpper() + "_部門(開放客戶)</option>";
            td_tscode += "</select>";
        } else {
            td_tscode = "<input type='hidden' id='tfx_Scode' name='tfx_Scode' readonly class='SEdit' value='" + Session["se_scode"] + "'>";
            td_tscode += "<input type='text' id='ScodeName' name='ScodeName' readonly class='SEdit' value='" + Session["sc_name"] + "'>";
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
        <table id="qryForm" border="0" class="bluetable" cellspacing="1" cellpadding="2" width="70%" align="center">	
            <tr>
		        <td class="lightbluetable" align="right">案件編號:</td>
		        <td class="whitetablebg" align="left" COLSPAN="3"><input type="text" id="ifx_seq" name="ifx_seq" size="8" maxlength="<%=Sys.DmtSeq%>">-<input type="text" value="_" id="ifx_seq1" name="ifx_seq1" size="<%=Sys.DmtSeq1%>" maxlength="<%=Sys.DmtSeq1%>"></td>
	        </tr>
	        <tr>
		        <td class="lightbluetable" align="right">營　　洽:</td>
		        <td class="whitetablebg" align="left"><%#td_tscode%></td>
		        <td class="lightbluetable" align="right">商標名稱:</td>
		        <td class="whitetablebg" align="left"><input type="text" id="pfx_cappl_name" name="pfx_cappl_name" size="15" maxlength="15">
		        </td>
	        </tr>
	        <tr>
		        <td class="lightbluetable" align="right">客戶編號:</td>
		        <td class="whitetablebg" align="left">
		        <input type="text" id="tfx_cust_area" name="tfx_cust_area" size="1" class="SEdit" readonly>-<input type="text" id="tfx_cust_seq" name="tfx_cust_seq" size="5" maxlength="5">
		        </td>		
		        <td class="lightbluetable" align="right">客戶名稱:</td>
		        <td class="whitetablebg" align="left"><input type="text" id="pfx_ap_cname1" name="pfx_ap_cname1" size="15" maxlength="15">
		        </td>
	        </tr>	
	        <tr>
		        <td class="lightbluetable" align="right">申請人號:</td>
		        <td class="whitetablebg" align="left"><input type="text" id="tfx_apcust_no" name="tfx_apcust_no" size="12" maxlength="10">
		        </td>		
		        <td class="lightbluetable" align="right">申請人名稱:</td>
		        <td class="whitetablebg" align="left"><input type="text" id="pfx_ap_cname" name="pfx_ap_cname" size="15" maxlength="80">
		        <input type="hidden" id="task" name="task">
		        </td>
	        </tr>
        </table>
        <br>
        <table id="tabBtn" border="0" width="100%" cellspacing="0" cellpadding="0" align="center">
	        <tr><td width="100%" align="center">
			    <%#StrFormBtn%>
	        </td></tr>
        </table>

        <div>
            *營洽中有　<font color=red size=2>' * '</font>　符號者，表該營洽已離職!!
        </div>
    </div>

    <div id="divList"></div>
    <%#DebugStr%>
</form>

<br />

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

        $("#tfx_cust_area").val("<%#Session["sebranch"]%>");
    }
    //////////////////////

    //[重填]
    $("#btnRest").click(function (e) {
        reg.reset();
        this_init();
    });

    //[查詢]
    $("#btnSrch").click(function (e) {
        if ($("#ifx_seq").val()!="") {
            if (!IsNumeric($("#ifx_seq").val())) {
                alert("案件編號應為數字，請重新輸入!");
                $("#ifx_seq").focus();
                return false;
            }
            if ($("#ifx_seq1").val() == "") {
                alert("案件編號副碼不得為空白，請重新輸入!");
                return false;
            }
        }

        if ($("#ifx_seq").val() == "") {
            if ($("#tfx_cust_seq").val() == ""&&$("#pfx_ap_cname1").val() == ""){
                alert("請至少輸入『客戶編號』或『客戶名稱』其中一個查詢條件!");
                return false;
            }
        }

        $("#dataList>thead tr .setOdr span").remove();
        $("#SetOrder").val("");

        reg.action = "<%=HTProgPrefix%>_List.aspx";
        reg.submit();
    });
</script>
