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
    protected string HTProgCap = "發明/創作人資料";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "cust173";//HttpContext.Current.Request["prgid"] ?? "";//程式檔名前綴
    protected string HTProgCode = "cust173";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";
    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";
    protected string submitTask = "";
    //種類
    protected string html_apclass = Sys.getCustCode("int_apclass", "", "sortfld").Option("{cust_code}", "{cust_code}_{code_name}");
    //國籍
    protected string html_country = Sys.getCountry().Option("{coun_code}", "{coun_code}_{coun_c}");
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

        submitTask = Request["submitTask"];
        if (submitTask == "A") HTProgCap = HTProgCap + "-<font color=blue>新增</font>";
        if (submitTask == "U") HTProgCap = HTProgCap + "-<font color=blue>維護</font>";
        if (submitTask == "Q") HTProgCap = HTProgCap + "-<font color=blue>查詢</font>";
        
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
<table border="0" class="bluetable" cellspacing="1" cellpadding="2" width="80%">
		<tr>
			<td class="lightbluetable" align="right">發明/創作人編號：</td>
			<td class="whitetablebg" colspan="3" align="left">
				<input type="text" name="ant_no" id="ant_no" size="11" maxlength="7">
				(區所別+流水號六碼)
			</td>			
		</tr>		
        <tr>
            <td class="lightbluetable" align="right">發明/創作人種類：</td>
            <td class="whitetablebg" colspan="3" align="left">
				<select name="apclass" id="apclass" size="1" ><%=html_apclass %></select>
            </td>
        </tr>
		<tr>
			<td class="lightbluetable" align="right">發明/創作人ID：</td>
			<td class="whitetablebg" align="left">
				<input type="text" name="ant_id" id="ant_id" size="12" maxlength="10">
			</td>
			<td class="lightbluetable" align="right">發明人國籍：</td>
			<td class="whitetablebg" align="left" style="width:30%">
				<select name="ant_country" id="ant_country" size="1"><%=html_country %></select>
			</td>
		</tr>
		<tr>
			<td class="lightbluetable" align="right">相關客戶編號：</td>
			<td class="whitetablebg" colspan="3" align="left">
				<%=Sys.GetSession("seBranch")%> － 
				<input type="text" name="cust_seq" id="cust_seq" size="7" maxlength="6" value="" class="InputNumOnly">
			</td>			
		</tr>
		<tr>
			<td class="lightbluetable" align="right">發明人名稱(中)：</td>
			<td class="whitetablebg" colspan="3" align="left">
				<input type="text" name="ant_cname" id="ant_cname" size="33" maxlength="30">
			</td>
		</tr>
		<tr>
			<td class="lightbluetable" align="right">發明人名稱(英)：</td>
			<td class="whitetablebg" colspan="3" align="left">
				<input type="text" name="ant_ename" id="ant_ename" size="44" maxlength="40">
			</td>
		</tr>
		<tr>
			<td class="lightbluetable" align="right">中文地址：</td>
			<td class="whitetablebg" colspan="3" align="left">郵遞區號
				<input type="text" name="ant_zip" id="ant_zip" size="8" maxlength="8" class="InputNumOnly">
				<input type="text" name="ant_addr" id="ant_addr" size="66" maxlength="60">
			</td>
		</tr>
		<tr>
			<td class="lightbluetable" align="right">英文地址：</td>
			<td class="whitetablebg" colspan="3" align="left">
				<input type="text" name="ant_eaddr" id="ant_eaddr" size="66" maxlength="60">				
			</td>
		</tr>
		<tr>
			<td class="lightbluetable" align="right">電話：</td>
			<td class="whitetablebg" colspan="3" align="left">
				(<input TYPE="text" NAME="ant_tel0" id="ant_tel0" SIZE="4" MAXLENGTH="4" class="InputNumOnly">)
				<input TYPE="text" NAME="ant_tel" id="ant_tel" SIZE="16" MAXLENGTH="15" class="InputNumAndMarks" >
				<input TYPE="text" NAME="ant_tel1" id="ant_tel1" SIZE="7" MAXLENGTH="7" class="InputNumAndMarks" >			
			</td>
		</tr>
		<tr>
			<td class="lightbluetable" align="right">日期種類：</td>
			<td class="whitetablebg" colspan="3" align="left">
                <input type="hidden" name="hkind" />
                <input type="radio" name="dkind" onclick="dkind_onclick('in_date')" value="in_date" />建檔日期
				<input type="radio" name="dkind" onclick="dkind_onclick('tran_date')" value="tran_date" />最近異動日期
				<input type="radio" name="dkind" onclick="dkind_onclick('')" checked value="" />不指定
			</td>
		</tr>		
		<tr>
			<td class="lightbluetable" align="right">日期範圍：</td>
			<td class="whitetablebg" colspan="3" align="left">
				<div id="divdate" style="display:none">
					<input type="text" name="sdate" id="sdate" size="10" readonly="readonly" class="dateField">～
		            <input type="text" name="edate" id="edate" size="10" readonly="readonly" class="dateField">
				</div>
			</td>
		</tr>					
	</table>

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

        if ($("#ant_no").val() == "" && $("#apclass").val() == "" && $("#ant_cname").val() == "" && $("#ant_ename").val() == ""
            && $("#ant_id").val() == "" && $("#ant_country").val() == "" && $("#ant_tel0").val() == "" && $("#ant_tel").val() == ""
            && $("#ant_tel1").val() == "" && $("#cust_seq").val() == "" && $("#ant_zip").val() == "" && $("#ant_addr").val() == "" && $("#ant_eaddr").val() == ""
            && $("#sdate").val() == "" && $("#edate").val() == "")
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
        if ($("#ant_cname").val() != "") {
            if (fDataLenX($("#ant_cname").val(), 0, "") < 2) {
                alert("「發明人名稱(中)」至少輸入一個中文字!");
                return false;
            }
        }

        reg.action = "cust17_List.aspx?prgid=<%=prgid%>&submitTask=<%=submitTask%>";
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
