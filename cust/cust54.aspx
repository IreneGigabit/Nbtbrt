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
    protected string HTProgCap = " 客戶報表列印";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "cust54";//HttpContext.Current.Request["prgid"] ?? "";//程式檔名前綴
    protected string HTProgCode = "cust54";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";
    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";
    protected string deptName = "";
    protected string cust_area = "";
    protected string LevelList = "";
    //客戶等級
    protected string html_level = Sys.getCustCode("level", "", "sortfld").Option("{cust_code}", "{cust_code}");
    //營洽選單
    protected string html_Scode = "";
    //折扣代碼
    protected string html_B = Sys.getCustCode("B", "", "sortfld").Option("{cust_code}", "{cust_code}_{code_name}");
    //付款條件
    protected string html_Payment = Sys.getCustCode("Payment", "", "sortfld").Option("{cust_code}", "{cust_code}_{code_name}");

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

        deptName = (Sys.GetSession("dept") == "P") ? "專利" : "商標";
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
        DataTable dt = Sys.getCustCode("level", "", "sortfld");
        foreach (DataRow r in dt.Rows)
        {
            //LevelList += "<INPUT type=\"checkbox\" value="+ r["cust_code"].ToString() + " name=\"level\" onclick=\"level_onclick()\" />" + r["code_name"].ToString() + "  " ;
            LevelList += "<INPUT type=\"checkbox\" value=" + r["cust_code"].ToString() + " name=\"level\" />" + r["code_name"].ToString() + "  ";
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
            StrFormBtnTop += "<a href=http://web02/BRP/cust/客戶報表操作手冊.files/frame.htm target=_blank>[補助說明]</a>";
        }
    }
    
</script>

<style>
    input[type=checkbox] {
    vertical-align:middle;
    }
</style>


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
<TABLE border=0 class=bluetable cellspacing=1 cellpadding=2 width="85%">
	<TR><TD class=lightbluetable align=right>※報表種類：</TD>
		<TD class=whitetablebg align=left>
			<input type=hidden name="hkind" id="hkind">
			<input type=radio name="pkind" value="A" checked onclick="SetReportType_onclick('A')">營洽客戶明細表
			<input type=radio name="pkind" value="B" onclick="SetReportType_onclick('B')">客戶折扣明細表
			<input type=radio name="pkind" value="C" onclick="SetReportType_onclick('C')">客戶基本資料
			<br>
			<input type=radio name="pkind" value="G" onclick="SetReportType_onclick('G')">客戶資料更正明細表
		</TD>
	</TR>
	<TR><TD class=lightbluetable align=right>※列印部門：</TD>
		<td class="whitetablebg" align="left">
		<Select NAME=depttype id="depttype" size=1 onchange="dept_onchange()">
			<option value="" >請選擇</option>
			<option value="1">只印<%=deptName%>客戶(不含共同客戶)</option>
			<option value="2" selected><%=deptName%>所有客戶(含共同客戶)</option>
			<option value="3">只印商標/專利共同客戶</option>
		</SELECT>&nbsp;
		<span id=deptdesc>
		</span>
		</td>
	</TR>
	<tr id="tr_in_date">
		<td class="lightbluetable" align="right"><span id="span_in_date">建檔日期</span>：</td>
		<td class="whitetablebg" align="left">
			<div id="divdate" style="display:">
			<input type="text" name="sdate" id="sdate" size="10" readonly="readonly" class="dateField">～
		    <input type="text" name="edate" id="edate" size="10" readonly="readonly" class="dateField">
			</div>
		</td>
	</TR>
	<TR id="tr_cust_seq">
		<TD class=lightbluetable align=right>客戶編號：</TD>
		<TD class=whitetablebg align=left>
			<INPUT type=text name="cust_area" readonly class="SEdit" size="1" value="<%=cust_area%>">-
			<INPUT type="text" name="cust_seqS" id="cust_seqS" size="6" value="1">～
			<INPUT type="text" name="cust_seqE" id="cust_seqE" size="6" value="99999">
		</TD>
	</TR>
	<tr id="tr_scode">
		<TD class=lightbluetable align=right>營　　洽：</TD>
		<TD class=whitetablebg align=left>
				<select NAME=scode size=1>
					<option value="_">_(無營洽)</option>
                    <%=html_Scode %>
				</select>
		</TD>
	</tr>
	<TR id="tr_level">
		<td class="lightbluetable" align="right" name=lab1><%=deptName%>客戶等級：</td>
		<TD class=whitetablebg align=left style="vertical-align:middle">
            <%=LevelList%>
		<input type="checkbox" name="level_allcheck" id="level_allcheck" value="Y" onclick="level_AllCheck()">全部&nbsp;
		<input type="hidden" name="hidLevel" value="">
		</td>
	</TR>
	<TR id="tr_dis_type">
		<td class="lightbluetable" align="right" name=lab1><%=deptName%>折扣代碼：</td>
		<TD class=whitetablebg align=left>
			<select name=dis_type size=1>
                <%=html_B %>
			</select>
		</td>
	</TR>
	<TR id="tr_pay_type">
		<td class="lightbluetable" align="right" name=lab1><%=deptName%>付款條件：</td>
		<TD class=whitetablebg align=left>
			<select name=pay_type size=1>
                <%=html_Payment %>
			</select>
		</td>
	</TR>
	<TR><td class="lightbluetable" align="right">列印順序：</td>
		<TD class=whitetablebg align=left>
			<input type=radio value=0 name=ordertype onclick="SetOrderType('0')">依客戶編號<br>
			<input type=radio value=1 name=ordertype onclick="SetOrderType('1')">依客戶名稱<br>
			<input type=radio value=2 name=ordertype checked onclick="SetOrderType('2')">依營洽+客戶編號&nbsp;&nbsp;(
    		<input type="checkbox" name="PagebyScode" id="PagebyScode" value="Y" checked>依營洽分頁&nbsp;)
		</td>
	</TR>
	<TR id="display_AttFlag">
		<td class="lightbluetable" align="right">列印內容：</td>
		<TD class=whitetablebg align=left>
    		<input type="checkbox" name=AttFlag id="AttFlag" value="Y" checked>包含聯絡人資料
    		<input type="hidden" name=hidAttFlag value="">
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

            $("input.dateField").datepick();
           
        }
    }

    //[重填]
    $("#btnRest").click(function (e) {
        reg.reset();
        this_init();
    });

    //[查詢]
    $("#btnSrch").click(function (e) {
        //if (reg.magtype[2].checked && reg.att_type[0].checked && reg.depttype.value == 0 && reg.cust_seqs.value == "" && reg.cust_seqe.value == ""
        //    && reg.scode.value == "" && $('input[name=level]:checked').val() == undefined)
        //{
        //    alert("請輸入任一條件!!!");
        //    return true;
        //}

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

        var otypevalue = $("input[name='ordertype']:checked").val();
        var levelvalue = "";
        $("input[name='level']:checked").each(function () {
            levelvalue += $(this).val() + ",";
        })
        levelvalue = levelvalue.substring(0, levelvalue.length - 1);

        var ByScode = $("input#PagebyScode:checked").val();
        var Flag = $("input#AttFlag:checked").val();

        var ReportType = $("input[name='pkind']:checked").val();
        switch (ReportType) {

            case "A":
                var url = "cust542print.aspx?prgid=<%=prgid%>&depttype=" + reg.depttype.value + "&cust_seqS=" + reg.cust_seqS.value + "&cust_seqE=" + reg.cust_seqE.value;
                url += "&sdate=" + reg.sdate.value + "&edate=" + reg.edate.value + "&scode=" + reg.scode.value + "&level=" + levelvalue;
                url += "&dis_type=" + reg.dis_type.value + "&pay_type=" + reg.pay_type.value + "&ordertype=" + otypevalue + "&PagebyScode=" + ByScode + "&AttFlag=" + Flag;
                window.open(url, "_blank", "width=1000px, height=900px, top=10, left=10, toolbar=no, menubar=yes, location=no, directories=no, status=no, scrollbars=yes,titlebar=no");
                break;

            case "B":
                var url = "cust543print.aspx?prgid=<%=prgid%>&depttype=" + reg.depttype.value + "&cust_seqS=" + reg.cust_seqS.value + "&cust_seqE=" + reg.cust_seqE.value;
                url += "&sdate=" + reg.sdate.value + "&edate=" + reg.edate.value + "&scode=" + reg.scode.value + "&level=" + levelvalue;
                url += "&dis_type=" + reg.dis_type.value + "&pay_type=" + reg.pay_type.value + "&ordertype=" + otypevalue + "&PagebyScode=" + ByScode + "&AttFlag=" + Flag;
                window.open(url, "_blank", "width=1000px, height=900px, top=10, left=10, toolbar=no, menubar=yes, location=no, directories=no, status=no, scrollbars=yes,titlebar=no");
                break;

            case "C":
                var url = "cust541print.aspx?prgid=<%=prgid%>&depttype=" + reg.depttype.value + "&cust_seqS=" + reg.cust_seqS.value + "&cust_seqE=" + reg.cust_seqE.value;
                url += "&sdate=" + reg.sdate.value + "&edate=" + reg.edate.value + "&scode=" + reg.scode.value + "&level=" + levelvalue;
                url += "&dis_type=" + reg.dis_type.value + "&pay_type=" + reg.pay_type.value + "&ordertype=" + otypevalue + "&PagebyScode=" + ByScode + "&AttFlag=" + Flag;
                window.open(url, "_blank", "width=1000px, height=900px, top=10, left=10, toolbar=no, menubar=yes, location=no, directories=no, status=no, scrollbars=yes,titlebar=no");
                break;

            case "G":
                var url = "cust54Gprint.aspx?prgid=<%=prgid%>&depttype=" + reg.depttype.value + "&cust_seqS=" + reg.cust_seqS.value + "&cust_seqE=" + reg.cust_seqE.value;
                url += "&sdate=" + reg.sdate.value + "&edate=" + reg.edate.value + "&scode=" + reg.scode.value + "&level=" + levelvalue;
                url += "&dis_type=" + reg.dis_type.value + "&pay_type=" + reg.pay_type.value + "&ordertype=" + otypevalue + "&PagebyScode=" + ByScode;
                window.open(url, "_blank", "width=1000px, height=900px, top=10, left=10, toolbar=no, menubar=yes, location=no, directories=no, status=no, scrollbars=yes,titlebar=no");
                break;

            default:
                break;



        }


        





        <%--reg.action = "cust542print.aspx?prgid=<%=prgid%>";
        reg.submit();--%>
    });

    function level_AllCheck() {
        if ($("#level_allcheck").prop("checked") == true) {
            $("input[name=level]").prop("checked", true);
        }
        else {
            $("input[name=level]").prop("checked", false);
        }
    }

    function SetOrderType(type) {

        var ReportType = $("input[name='pkind']:checked").val();
        if (ReportType == "C") {
            $("#PagebyScode").prop("checked", false);
            $("#PagebyScode").lock();
        }
        else {
            if (type == "0" || type == "1") {
                $("#PagebyScode").prop("checked", false);
                $("#PagebyScode").lock();
            }
            else {
                $("#PagebyScode").prop("checked", true);
                $("#PagebyScode").unlock();
            }
        }
    }

    function SetReportType_onclick(type) {
        //reg.hkind.value = pkind
        $("#tr_indate, #tr_level, #tr_dis_type, #tr_pay_type, #display_AttFlag").show();
        //document.all.span_in_date.InnerHtml = "建檔日期"
        $("#span_in_date").text("建檔日期");
        $("#sdate, #edate").val("");
        $("#PagebyScode").prop("checked", true);
        $("#PagebyScode").unlock();
        $("#AttFlag").prop("checked", true);
        $("#AttFlag").unlock();

        if (type == "C") {
            $("#PagebyScode").prop("checked", false);
            $("#PagebyScode").lock();
        }
        
        if (type == "G") {
            $("#tr_indate, #tr_level, #tr_dis_type, #tr_pay_type, #display_AttFlag").hide();
            $("#span_in_date").text("修改日期");
            var d = new Date();
            $("#sdate").val(new Date(d.getFullYear(), (d.getMonth() - 4), d.getDate()).format('yyyy/M/d'));
            $("#edate").val(Today().format('yyyy/M/d'));
        }

        if (type == "B") {
            $("#AttFlag").prop("checked", false);
            $("#AttFlag").lock();
        }

        var otypevalue = $("input[name='ordertype']:checked").val();
        SetOrderType(otypevalue);
    
    }

     
</script>
