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
    protected string HTProgCap = "申請人資料維護";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "cust13_1";//HttpContext.Current.Request["prgid"] ?? "";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    
    protected int HTProgRight = 0;
    protected string DebugStr = "";
    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";
    protected string SQL = "";
    protected string submitTask = "";
    protected string td_tscode = "", html_apclass = "", html_country = "";

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
        
        conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
        cnn = new DBHelper(Conn.Sysctrl).Debug(Request["chkTest"] == "TEST");

        submitTask = Request["submitTask"];
        if (submitTask == "A") HTProgCap = HTProgCap + "-<font color=blue>新增</font>";
        if (submitTask == "U") HTProgCap = HTProgCap + "-<font color=blue>維護</font>";
        if (submitTask == "Q") HTProgCap = HTProgCap + "-<font color=blue>查詢</font>";
        
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

        //營洽清單
        //if ((HTProgRight & 64) != 0)
        //{
        //    td_tscode = "<select id='scode' name='scode' >";
        //    td_tscode += Sys.getDmtScode("", "").Option("{scode}", "{star}{scode}_{sc_name}", "style='color:{color}'", true);
        //    td_tscode += "<option value='" + Sys.GetSession("seBranch") + Sys.GetSession("dept") + "'>" + Sys.GetSession("seBranch") + Sys.GetSession("dept").ToUpper() + "_部門(開放客戶)</option>";
        //    td_tscode += "</select>";
        //} 

        //申請人種類
        html_apclass = Sys.getCustCode("apclass", "", "sortfld").Option("{cust_code}", "{cust_code}_{code_name}");
        //申請人國籍
        html_country = Sys.getCountry().Option("{coun_code}", "{coun_code}_{coun_c}");
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
<center><table border="0" class="bluetable" cellspacing="1" cellpadding="2" width="85%">
	<tr>
		<td class="lightbluetable" align="right">申請人種類：</td>
		<td class="whitetablebg" align="left">
			<select name="apclass" id="apclass">
				<%#html_apclass%>
			</select>
		</td>
		<td class="lightbluetable" align="right" width="18%">申請人編號：</td>
		<td class="whitetablebg" align="left">
		<input name="apcust_no" id="apcust_no" size="11" maxlength="10">
		</td>
        <input type="hidden" id="submitTask" name="submitTask" value="<%=Request["submitTask"]%>" />
	</tr>
	<tr>
		<td class="lightbluetable" align="right" nowrap>申請人名稱(中)：</td>
		<td class="whitetablebg" align="left">
		<input type="Text" name="ap_cname" id="ap_cname" size="30" maxlength="30"></td>
		<td class="lightbluetable" align="right" width="18%">申請人國籍：</td>
		<td class="whitetablebg" align="left">
			<select name="ap_country" id="ap_country">
		  		<%#html_country%>
			</select>
		</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right">申請人名稱(英)：</td>
		<td class="whitetablebg" align="left" colspan="3">
		<input type="Text" name="ap_ename" id="ap_ename" size="40" maxlength="40" onkeyup="value=value.replace(/[^\w\.\/]/ig,’’)"></td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right">代表人名稱(中)：</td>
		<td class="whitetablebg" align="left" colspan="3">
		<input type="Text" name="ap_crep" id="ap_crep" size="30" maxlength="30"></td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right">代表人名稱(英)：</td>
		<td class="whitetablebg" align="left" colspan="3">
		<input type="Text" name="ap_erep" id="ap_erep" size="40" maxlength="40"></td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right">証照地址(中)：</td>
		<td class="whitetablebg" align="left" colspan="3">
		<input type="Text" name="ap_zip" id="ap_zip" size="8" maxlength="8">
		<input type="Text" name="ap_addr" id="ap_addr" size="30" maxlength="30">
		</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right">聯絡地址：</td>
		<td class="whitetablebg" align="left" colspan="3">
		<input type="Text" name="apatt_zip" id="apatt_zip" size="8" maxlength="8">
		<input type="Text" name="apatt_addr" id="apatt_addr" size="30" maxlength="30">
		</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right">聯絡電話：</td>
		<td class="whitetablebg" align="left" colspan="3">
		<input type="Text" name="apatt_tel0" id="apatt_tel0" size="4" maxlength="4" onkeyup="value=value.replace(/[^\d]/g,'') " >
		<input type="Text" name="apatt_tel" id="apatt_tel" size="15" maxlength="15" onkeyup="value=value.replace(/[^\d]/g,'') " >
		<input type="Text" name="apatt_tel1" id="apatt_tel1" size="5" maxlength="5" onkeyup="value=value.replace(/[^\d]/g,'') " >
		</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right">日期種類：</td>
		<td class="whitetablebg" align="left" colspan="3">
		<input type="hidden" name="hkind">
		<input type="radio" name="dkind" onclick="dkind_onclick('in_date')" value="in_date">建檔日期
		<input type="radio" name="dkind" onclick="dkind_onclick('tran_date')" value="tran_date">最近異動日期
		<input type="radio" name="dkind" onclick="dkind_onclick('')" checked value>不指定
		</td>
	</tr>
	<tr><td class="lightbluetable" align="right">日期範圍：</td>
		<td class="whitetablebg" align="left" colspan="3">
		<div id="divdate" style="display:none">
		<input type="text" name="sdate" id="sdate" size="10" readonly="readonly" class="dateField">～
		<input type="text" name="edate" id="edate" size="10" readonly="readonly" class="dateField">
		</div>
		</td>
	</tr>
</table></center>
</form>
<table border="0" width="100%" cellspacing="0" cellpadding="0">
	<tr><td width="100%">     
		<p align="center">
		<input type="button" value="查詢" class="cbutton" style="cursor:hand" id="btnSrch" name="btnSrch">
		<input type="button" value="重填" class="cbutton" style="cursor:hand" id="btnRest" name="btnRest">
	</td></tr>
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
        //$("#cust_area").val("<%=Session["seBranch"]%>");
    }

    //[重填]
    $("#btnRest").click(function (e) {
        reg.reset();
        this_init();
    });

    //////////////////////////////////////////////////////
    //$("#seq").blur(function (e) {
    //    chkNum1($(this),"本所編號");
    //});
    //$("#cust_seq").blur(function (e) {
    //    chkNum1($(this), "客戶編號");
    //});

    //點選日期種類
    $("input[name='kind_date']").click(function () {
        if ($(this).val() == "End_Date") {//結案日期
            //結案代碼：已結案
            $("input[name='qryend'][value='N']").prop("checked", true).triggerHandler("click");
        } else {
            //結案代碼：不指定
            $("input[name='qryend'][value='']").prop("checked", true).triggerHandler("click");
        }
    });

    //點選結案代碼
    $("input[name='qryend']").click(function () {
        $("#sp_endcode").hide();
        if ($(this).val() == "N") {//已結案
            $("#sp_endcode").show();
        }
    });

    //[查詢]
    $("#btnSrch").click(function (e) {

        if ($("#apclass").val() == "" && $("#apcust_no").val() == "" && $("#ap_country").val() == ""
            && $("#ap_cname").val() == "" && $("#ap_ename").val() == "" && $("#ap_crep").val() == "" && $("#ap_erep").val() == ""
            && $("#ap_zip").val() == "" && $("#ap_addr").val() == "" && $("#apatt_zip").val() == "" && $("#apatt_addr").val() == ""
            && $("#apatt_tel0").val() == "" && $("#apatt_tel").val() == "" && $("#apatt_tel1").val() == "" && $("#sdate").val() == "" && $("#edate").val() == ""
            )
        {
            alert("請輸入任一查詢條件!!!");
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

        if ($("#ap_cname").val() != "") {
            if (fDataLenX($("#ap_cname").val(), 0, "") < 4) {
                alert("「申請人名稱(中)」至少輸入2個中文字!");
                return false;
            }
        }
        if ($("#ap_ename").val() != "") {
            if (fDataLenX($("#ap_ename").val(), 0, "") < 4) {
                alert("「申請人名稱(英)」至少輸入4個英文字!");
                return false;
            }
        }
        //if ($("#seq").val() != "" && IsNumeric($("#seq").val()) == false) {
        //    alert("本所序號輸入的資料必須為數值!!" + ("#seq").val());
        //    return false;
        //}
        reg.action = "cust13_List.aspx";
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

</script>
