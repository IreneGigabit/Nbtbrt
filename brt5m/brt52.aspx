<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data" %>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<script runat="server">
    protected string HTProgCap = "案件交辦維護";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "Brt52";//程式檔名前綴
    protected string HTProgCode = "Brt52";//HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";
    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";
    protected string SQL = "";

    protected string td_tscode = "";

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

        using (DBHelper conn = new DBHelper(Conn.btbrt).Debug(false)) {
            //營洽清單
            td_tscode = Sys.getCaseDmtScode("", "").Option("{in_scode}", "{star}{in_scode}_{sc_name}", "style='color:{color}'", true);
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
		        <td class="lightbluetable" align="right">洽案營洽:</td>
		        <td class="whitetablebg" align="left" colspan="3">
                    <select id='scode' name='scode' >
                        <option value="*" style="color:blue" selected>全部</option>
                        <%#td_tscode%>
                    </select>
                </td>
	        </tr>
	        <tr>
		        <td class="lightbluetable" align="right">客戶編號:</td>
		        <td class="whitetablebg" align="left">
		        <input type="text" id="tfx_cust_area" name="tfx_cust_area" size="1" class="SEdit" readonly>-<input type="text" id="tfx_cust_seq" name="tfx_cust_seq" size="5" maxlength="5">
		        </td>		
		        <td class="lightbluetable" align="right">客戶名稱:</td>
		        <td class="whitetablebg" align="left"><input type="text" id="pfx_Cust_name" name="pfx_Cust_name" size="15" maxlength="15">
		        </td>
	        </tr>	
	        <tr>
		        <td class="lightbluetable" align="right">序號選擇 :</td>
		        <td class="whitetablebg" align="left" colspan="3">
		            <label><input type="radio" name="new" value="in_no" checked>接洽序號</label>
 		            <label><input type="radio" name="new" value="case_no">交辦序號</label>
 		            <label><input type="radio" name="new" value="seq_no">本所編號</label>
		        </td>
	        </tr>
	        <tr id=sin_no1 style="display:none">
		        <td class="lightbluetable" align="right">序號範圍 :</td>
		        <td class="whitetablebg" align="left" colspan="3">
                    <input type="text" id="sin_no" name="sin_no" size="12" maxlength="12">
                    ～
                    <input type="text" id="ein_no" name="ein_no" size="12" maxlength="12">
		        </td>
	        </tr>
	        <tr id=sin_no2 style="display:none">
		        <td class="lightbluetable" align="right">本所編號 :</td>
		        <td class="whitetablebg" align="left" colspan="3">
                    <input type="text" id="sfx_seq" name="sfx_seq" size="6" maxlength="<%=Sys.DmtSeq%>">-<input type="text" id="sfx_seq1" name="sfx_seq1" size="2" maxlength="<%=Sys.DmtSeq1%>" value="_">
		        </td>
	        </tr>
	        <tr>
		        <td class="lightbluetable" align="right">日期種類 :</td>
		        <td class="whitetablebg" align="left" colspan=3>
		            <label><input type="radio" name="ChangeDate" value="A" checked>接洽日期</label>
		            <label><input type="radio" name="ChangeDate" value="B">交辦日期</label>
		            <label><input type="radio" name="ChangeDate" value="">不指定</label>
		        </td>
	        </tr>
	        <tr>
		        <td class="lightbluetable" align="right">日期範圍 :</td>
		        <td class="whitetablebg" align="left" colspan=3>
		            <input type="text" id="CustDate1" name="CustDate1" size="10" class="dateField">
                    ～
		            <input type="text" id="CustDate2" name="CustDate2" size="10" class="dateField">
		        </td>
	        </tr>
        </table>
        <br>
        <table id="tabBtn" border="0" width="100%" cellspacing="0" cellpadding="0" align="center">
	        <tr><td width="100%" align="center">
			    <%#StrFormBtn%>
	        </td></tr>
        </table>

        <div></div>
    </div>

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

        $("input.dateField").datepick();

        $("#tfx_cust_area").val("<%#Session["sebranch"]%>");
        $("input[name='new']:checked").triggerHandler("click");
    }

    //////////////////////////////////////////////////////

    //[重填]
    $("#btnRest").click(function (e) {
        reg.reset();
        this_init();
    });

    //序號選擇
    $("input[name='new']").click(function (e) {
        $("#sin_no1,#sin_no2").hide();
        if ($(this).val() == "in_no" || $(this).val() == "case_no") {
            $("#sin_no1").show();
            $("input[name='ChangeDate'][value='A']").prop("checked", true).triggerHandler("click");
        } else if ($(this).val() == "seq_no") {
            $("#sin_no2").show();
            $("input[name='ChangeDate'][value='']").prop("checked", true).triggerHandler("click");
        }
    });

    //日期種類
    $("input[name='ChangeDate']").click(function (e) {
        if ($(this).val() == "A" || $(this).val() == "B") {
            $("#CustDate1").val("<%#DateTime.Today.ToString("yyyy/M/1")%>");
            $("#CustDate2").val("<%#DateTime.Today.ToString("yyyy/M/d")%>");
        } else if ($(this).val() == "") {
            $("#CustDate1,#CustDate2").val("");
        }
    });

    //[查詢]
    $("#btnSrch").click(function (e) {
        if ($("input[name=new]:checked").val() == "seq_no") {
            if ($("#sfx_seq").val() == "") {
                alert("請輸入本所編號!!");
                $("#sfx_seq").focus();
                return false;
            }
        }

        if ($("#CustDate1").val() != "" && $.isDate($("#CustDate1").val()) == false) {
            alert("請檢查日期範圍起日，日期格式是否正確!!");
            $("#CustDate1").focus();
            return false;
        }

        if ($("#CustDate2").val() != "" && $.isDate($("#CustDate2").val()) == false) {
            alert("請檢查日期範圍迄日，日期格式是否正確!!");
            $("#CustDate2").focus();
            return false;
        }

        if ($("input[name=ChangeDate]:eq(2)").prop("checked")==false && ($("#CustDate1").val() == "" || $("#CustDate1").val() == "")) {
            alert("日期範圍任一不得為空白!!");
            return false;
        }

        if (chkNum($("#sin_no").val(), "序號範圍(起)")) return false;
        if (chkNum($("#ein_no").val(), "序號範圍(迄)")) return false;
        if ($("#sin_no").val() != "" && $("#ein_no").val() != "") {
            if (CInt($("#sin_no").val()) > CInt($("#ein_no").val())) {
                alert("序號範圍(起),不得大於序號範圍(迄)!!!");
                return false;
            }
        }

        if ($("input[name=ChangeDate]:eq(2)").prop("checked") == true) {
            if ($("#scode").val() == "" && $("#tfx_cust_seq").val() == "" && $("#pfx_Cust_name").val() == "" && $("#sfx_seq").val() == "") {
                alert("請輸入洽案營洽、客戶編號、客戶名稱、本所編號任一查詢條件!!");
                return false;
            }
        }

        reg.action = "<%=HTProgPrefix%>_List.aspx";
        reg.submit();
    });
</script>
