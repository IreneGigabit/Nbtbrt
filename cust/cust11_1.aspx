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
    protected string HTProgCap = "客戶資料";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "cust11_1";//HttpContext.Current.Request["prgid"] ?? "";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    
    protected int HTProgRight = 0;
    protected string DebugStr = "";
    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";
    protected string SQL = "";
    protected string submitTask = "";
    protected string td_tscode = "";
    protected string cust_area = "";
    protected string no = "";//序號，cust22_apcustList用

    //申請人種類
    protected string html_apclass = Sys.getCustCode("apclass", "", "sortfld").Option("{cust_code}", "{cust_code}_{code_name}");
    //申請人國籍
    protected string html_country = Sys.getCountry().Option("{coun_code}", "{coun_code}_{coun_c}");
    //客戶等級
    protected string html_level = Sys.getCustCode("level", "", "sortfld").Option("{cust_code}", "{cust_code}_{code_name}");
    //顧問種類
    protected string html_H = Sys.getCustCode("H", "", "sortfld").Option("{cust_code}", "{code_name}");
    //折扣代碼
    protected string html_B = Sys.getCustCode("B", "", "sortfld").Option("{cust_code}", "{cust_code}_{code_name}");
    //付款條件
    protected string html_Payment = Sys.getCustCode("Payment", "", "sortfld").Option("{cust_code}", "{cust_code}_{code_name}");
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
        
        conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
        cnn = new DBHelper(Conn.Sysctrl).Debug(Request["chkTest"] == "TEST");

        submitTask = Request["submitTask"];
        cust_area = Sys.GetSession("seBranch");
        if ((Request["no"] ?? "") != "") no = Request["no"];

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

        //營洽清單
        //if ((HTProgRight & 64) != 0)
        //{
        //    td_tscode = "<select id='scode' name='scode' >";
        //    td_tscode += Sys.getDmtScode("", "").Option("{scode}", "{star}{scode}_{sc_name}", "style='color:{color}'", true);
        //    td_tscode += "<option value='" + Sys.GetSession("seBranch") + Sys.GetSession("dept") + "'>" + Sys.GetSession("seBranch") + Sys.GetSession("dept").ToUpper() + "_部門(開放客戶)</option>";
        //    td_tscode += "</select>";
        //} 
        if (HTProgRight >= 128)
        {
            //html_scode += "<option value='np'>np_部門(開放客戶)</option>";
            //html_scode += "<option value='nt'>nt_部門(開放客戶)</option>";
            //html_scode += "<option value='all'>全部</option>";
        }
        
        if (submitTask == "A") HTProgCap = HTProgCap + "-<font color=blue>新增</font>";
        if (submitTask == "U") HTProgCap = HTProgCap + "-<font color=blue>維護</font>";
        if (submitTask == "Q") HTProgCap = HTProgCap + "-<font color=blue>查詢</font>";

        if ((HttpContext.Current.Request["prgid"] ?? "") == "")
        {
            HTProgCode = "cust11_2"; prgid = "cust11_2";
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
<input type=hidden name="prgid" value="<%=prgid%>">
<input type=hidden name="submitTask" id="submitTask" value="<%=submitTask%>">
<input type=hidden name="no" id="no" value="<%=no%>">
<center>
    <TABLE border=0 class=bluetable cellspacing=1 cellpadding=2 width="85%">
	<TR><TD class=lightbluetable align=right>客戶編號：</TD>
		<TD class=whitetablebg align=left>
		    <INPUT type=text name="cust_area" id="cust_area" readonly="readonly" size="1" value="<%=cust_area%>">-
		    <INPUT type="text" name="cust_seq" id="cust_seq" size="6" maxlength="5" class="InputNumOnly"></TD>
		<TD class=lightbluetable align=right>群組客戶：</TD>
		<TD class=whitetablebg align=left>
            <INPUT type="text" name="ref_seq" id="ref_seq" size="6" class="InputNumOnly">
		</TD>
	</TR>
	<tr><TD class=lightbluetable align=right>客戶種類：</TD>
		<td class=whitetablebg align=left>
		<select name=apclass id="apclass" size=1><%=html_apclass%></select>
		</td>
		<TD class=lightbluetable align=right>証照號碼：</TD>
		<TD class=whitetablebg align=left>
		<div id="divid_no" style="display:">
		<INPUT type="text" name="id_no" id="id_no" size="11" maxlength=10>
		</div></TD>
	</tr>
	<TR>
		<TD class=lightbluetable align=right>客戶名稱(中)：</TD>
		<TD class=whitetablebg align=left><INPUT type=text name="ap_cname1" id="ap_cname1" size="22" maxlength=30></TD>
		<TD class=lightbluetable align=right>客戶名稱(英)：</TD>
		<TD class=whitetablebg align=left><INPUT type=text name="ap_ename1" id="ap_ename1" size="22" maxlength=40></TD>
	</TR>
	<TR>
		<td class="lightbluetable" align="right">代表人(中)：</td>
		<TD class=whitetablebg align=left>
		<INPUT type=text name="ap_crep" id="ap_crep" size="22" maxlength=20></TD>
		<td class="lightbluetable" align="right">代表人(英)：</td>
		<TD class=whitetablebg align=left>
		<INPUT type=text name="ap_erep" id="ap_erep" size="22" maxlength=40></TD>
	</TR>
	<tr><TD class=lightbluetable align=right>客戶國籍：</TD>
		<td class=whitetablebg align=left>
			<select name=ap_country id="ap_country" size=1><%=html_country %></select>
		</td>
		<TD class=lightbluetable align=right>營　　洽：</TD>
		<TD class=whitetablebg align=left>
			<input type="hidden" name="pwhescode" value="">
			<Select NAME="scode" id="scode" size=1>
                <%=html_scode%>
				<%--<option value="all">全部</option>
				<option value="">部門(開放客戶)</option>--%>
			</SELECT>
		</TD>
	</tr>
	<tr><TD class=lightbluetable align=right>日期種類：</TD>
		<td class="whitetablebg" align="left" colspan="3">
            <input type="hidden" name="hkind">
			<input type="radio"  name="dkind" onclick="dkind_onclick('in_date')" value="in_date">建檔日期
			<input type="radio"  name="dkind" onclick="dkind_onclick('con_term')" value="con_term">顧問迄日
			<input type="radio"  name="dkind" onclick="dkind_onclick('dmt_date')" value="dmt_date">內商最近立案日
			<input type="radio"  name="dkind" onclick="dkind_onclick('ext_date')" value="ext_date">外商最近立案日<br>
			<input type="radio"  name="dkind" onclick="dkind_onclick('dmp_date')" value="dmp_date">內專最近立案日
			<input type="radio"  name="dkind" onclick="dkind_onclick('exp_date')" value="exp_date">出專最近立案日
			<input type="radio"  name="dkind" checked onclick="dkind_onclick('')">不指定
		</td>
	</tr>
	<tr><td class="lightbluetable" align="right">日期範圍：</td>
		<td class="whitetablebg" align="left" colspan="3">
		<div id="divdate" style="display:none">
		<input type="text" name="sdate" id="sdate" size="10" readonly="readonly" class="dateField">～
		<input type="text" name="edate" id="edate" size="10" readonly="readonly" class="dateField">
		</div>
		</td>
	</TR>
	<tr><TD class=lightbluetable align=right>地址種類：</TD>
		<td class="whitetablebg" align="left" colspan="3">
			<input type="radio"  name="addrtype" onclick="addrtype_onclick('ap_addr')" value="ap_addr1">証照地址(中)
			<input type="radio"  name="addrtype" onclick="addrtype_onclick('ap_eaddr')" value="ap_eaddr1">証照地址(英)
			<input type="radio"  name="addrtype" onclick="addrtype_onclick('addr')" value="addr">對帳地址
			<input type="radio"  name="addrtype" checked onclick="addrtype_onclick('')">不指定
		</td>
	</tr>
	<TR>
		<td class="lightbluetable" align="right">地址內容：</td>
		<TD class=whitetablebg align=left colspan=3>
			<div id="divaddr" style="display:none">
				<INPUT type=text name="addr_zip" id="addr_zip" size=8 maxlength=8>
				<INPUT type=text name="addr" id="addr" size=44 maxlength=40>
			</div>
		</TD>
	</TR>
	<TR>
		<td class="lightbluetable" align="right">會計電話：</td>
		<TD class=whitetablebg align=left>(
		<INPUT type=text name="acc_tel0" id="acc_tel0" size=5 maxlength=4 class="InputNumOnly">)
		<INPUT type=text name="acc_tel" id="acc_tel" size=10 maxlength=8 class="InputNumOnly"> - 
		<INPUT type=text name="acc_tel1" id="acc_tel1" size=6 maxlength=5 class="InputNumOnly"></td>
		<td class="lightbluetable" align="right">傳　　真：</td>
		<TD class=whitetablebg align=left>
		<INPUT type=text name="acc_fax" id="acc_fax" size=16 maxlength=15 class="InputNumOnly"></TD>
	</TR>
<!--	<TR><td class="lightbluetable" align="right" name=lab1>債信：</td>
		<TD class=whitetablebg align=left colspan=3>
			<select name=level size=1></select>
		</td>
	</TR>-->
	<TR><td class="lightbluetable" align="right" name=lab1>商　　標：</td>
		<TD class=whitetablebg align=left colspan=3>
		客戶等級：<select name=tlevel id="tlevel" size=1><%=html_level%></select>
		折扣代碼：<select name=tdis_type id="tdis_type" size=1><%=html_B%></select>
		付款條件：<select name=tpay_type id="tpay_type" size=1><%=html_Payment%></select>
		</td>
	</TR>
	<TR><td class="lightbluetable" align="right" name=lab1>專　　利：</td>
		<TD class=whitetablebg align=left colspan=3>
		客戶等級：<select name=plevel id="plevel" size=1><%=html_level%></select>
		折扣代碼：<select name=pdis_type id="pdis_type" size=1><%=html_B%></select>
		付款條件：<select name=ppay_type id="ppay_type" size=1><%=html_Payment%></select>
		</td>
	</TR>
	<TR><td class="lightbluetable" align="right" name=lab1>債　　信：</td>
		<TD class=whitetablebg align=left colspan=3>
			<input type=radio name=qryrmark_code value="N" onclick="rmarkCode_onclick('')">無
			<input type=radio name=qryrmark_code value="Y" onclick="rmarkCode_onclick('Y')">有
			<span id="sp_rmark_code" style="display:none">
                <INPUT type="checkbox" value="E13" name="rmark_code" />撤案未付
                <INPUT type="checkbox" value="E20" name="rmark_code" />無力給付
                <INPUT type="checkbox" value="E21" name="rmark_code" />賴帳拒付
                <INPUT type="checkbox" value="E22" name="rmark_code" />倒閉
                <INPUT type="checkbox" value="E23" name="rmark_code" />無法聯絡
                <INPUT type="checkbox" value="Z90" name="rmark_code"/>其他
			</span>
		</td>
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
        $("#cust_area").lock();
    }

    //[重填]
    $("#btnRest").click(function (e) {
        reg.reset();
        this_init();
    });

    //點選日期種類
    //$("input[name='kind_date']").click(function () {
    //    if ($(this).val() == "End_Date") {//結案日期
    //        //結案代碼：已結案
    //        $("input[name='qryend'][value='N']").prop("checked", true).triggerHandler("click");
    //    } else {
    //        //結案代碼：不指定
    //        $("input[name='qryend'][value='']").prop("checked", true).triggerHandler("click");
    //    }
    //});

    //[查詢]
    $("#btnSrch").click(function (e) {

        var i = 0;
        var val = [];
        $(':checkbox:checked').each(function () {
            val[i] = $(this).val();
            i++;
        })

        if (NulltoEmpty($("#cust_seq").val()) == "" && NulltoEmpty($("#ref_seq").val()) == "" && NulltoEmpty($("#apclass").val()) == "" && NulltoEmpty($("#id_no").val()) == ""
             && NulltoEmpty($("#ap_cname1").val()) == "" && NulltoEmpty($("#ap_ename1").val()) == "" && NulltoEmpty($("#ap_crep").val()) == "" && NulltoEmpty($("#ap_erep").val()) == ""
             && NulltoEmpty($("#ap_country").val()) == "" && NulltoEmpty($("#scode").val()) == "" && $("#sdate").val() == "" && $("#edate").val() == ""
             && NulltoEmpty($("#addr_zip").val()) == "" && NulltoEmpty($("#addr").val()) == ""
             && NulltoEmpty($("#acc_tel0").val()) == "" && NulltoEmpty($("#acc_tel").val()) == "" && NulltoEmpty($("#acc_tel1").val()) == "" && NulltoEmpty($("#acc_fax").val()) == ""
             && NulltoEmpty($("#tlevel").val()) == "" && NulltoEmpty($("#tdis_type").val()) == "" && NulltoEmpty($("#tpay_type").val()) == ""
             && NulltoEmpty($("#plevel").val()) == "" && NulltoEmpty($("#pdis_type").val()) == "" && NulltoEmpty($("#ppay_type").val()) == "" && NulltoEmpty($("#rmark_code").val()) == ""
             && i == 0)
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
        if ($("#ap_cname1").val() != "") {
            if (fDataLenX($("#ap_cname1").val(), 0, "") < 4) {
                alert("「申請人名稱(中)」至少輸入二個中文字!");
                return false;
            }
        }

        if ('<%=prgid%>' == "cust21") {
            reg.action = "cust22_apcustList.aspx?prgid=cust21";
            reg.submit();
        }
        else {
            reg.action = "cust11_List.aspx";
            reg.submit();
        }

        
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

    function addrtype_onclick(pvalue) {
        if (pvalue == "") {
            document.all.divaddr.style.display = "none";
            document.all.addr_zip.value = "";
            document.all.addr.value = "";
        }
        else {
            if (pvalue == "ap_eaddr") {
                document.getElementById('addr_zip').textContent = "";
                document.all.addr_zip.disabled = true;
                document.all.addr_zip.style.background = "Silver";
            }
            else {
                document.all.addr_zip.disabled = false;
                document.all.addr_zip.style.background = "";
            }
            document.all.divaddr.style.display = "";
        }
    }

    function rmarkCode_onclick(pvalue) {
        if (pvalue == "") {
            document.all.sp_rmark_code.style.display = "none";
        }
        else {
            document.all.sp_rmark_code.style.display = "";
        }
    }

    $('.InputNumOnly').keypress(function (event) {
        if (event.which != 8 && isNaN(String.fromCharCode(event.which))) {
            event.preventDefault();
        }
    });

</script>
