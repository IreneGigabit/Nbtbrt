<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data" %>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<script runat="server">
    protected string HTProgCap = "交辦專案室爭救案件統計表";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "Brt20";//HttpContext.Current.Request["prgid"] ?? "";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";
    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";
    protected string SQL = "";

    protected string html_branch = "";

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

        //區所別
        html_branch = Sys.getBranchCode().Radio("qryBranch","{branch}", "{branchname}");
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
        <table border="0" class="bluetable" cellspacing="1" cellpadding="2" width="88%" align="center">
	        <TR>
		        <td class="lightbluetable" align="right">區所別：</td>
		        <td class="whitetablebg" align="left">
                    <input type="radio" name="qryBranch" value="" checked>全部
		            <%#html_branch%>
                </td>
	        </TR>
	        <TR>
		        <TD class=lightbluetable align=right>日期種類：</TD>
		        <TD class=whitetablebg colspan=3>
	                <label>&nbsp;<input type="radio" name='qryKINDDATE' value='BCASE_DATE'>交辦專案室日期</label>
	                <label>&nbsp;<input type="radio" name='qryKINDDATE' value='CONFIRM_DATE'>專案室收件日期</label>
	                <label>&nbsp;<input type="radio" name='qryKINDDATE' value='PR_DATE'>專案室承辦完成日</label>
                    <label>&nbsp;<input type="radio" name='qryKINDDATE' value='AP_DATE'>專案室判行日期</label>
                    <label>&nbsp;<input type="radio" name='qryKINDDATE' value='GS_DATE'>專案室預計發文日期</label><br>
                    <label>&nbsp;<input type="radio" name='qryKINDDATE' checked  value=''>不指定</label>
		        </TD>
	        </TR>
	        <TR id='spdate'>
		        <TD class=lightbluetable align=right>日期範圍：</TD>
		        <TD class=whitetablebg colspan=3>
			        <input type="text" id="qrysDATE" name="qrysDATE" size="10" class="dateField">～
			        <input type="text" id="qryeDATE" name="qryeDATE" size="10" class="dateField">&nbsp;&nbsp;(YYYY/MM/DD)
		        </TD>
	        </TR>
	        <TR>
		        <TD class=lightbluetable align=right>承辦狀態：</TD>
		        <TD class=whitetablebg colspan=3>
	                <label>&nbsp;<input type="radio" name='qrySTAT_kind' checked value=''>不指定</label>
	                <label>&nbsp;<input type="radio" name='qrySTAT_kind' value='Yes'>指定</label>
	                <label>&nbsp;<input type="checkbox" name="qSTAT_CODE" value='RR'>尚未分案</label>
	                <label>&nbsp;<input type="checkbox" name="qSTAT_CODE" value='NN'>承辦中</label>
	                <label>&nbsp;<input type="checkbox" name="qSTAT_CODE" value='NY'>承辦完成</label>
	                <label>&nbsp;<input type="checkbox" name="qSTAT_CODE" value='YY'>判行完成</label>
	                <label>&nbsp;<input type="checkbox" name="qSTAT_CODE" value='YS'>已發文</label>
                    <input type="text" id="qrySTAT_CODE" name="qrySTAT_CODE" value="">
		        </TD>
	        </TR>
        </table>

        <br>
        <%#DebugStr%>
        <table id="tabBtn" border="0" width="100%" cellspacing="0" cellpadding="0" align="center">
	        <tr><td width="100%" align="center">
			    <%#StrFormBtn%>
	        </td></tr>
        </table>
    </div>
</form>

<div align="left">
</div>
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

        $("#qrysDATE").val((new Date()).format("yyyy/M/1"));
        $("#qryeDATE").val(Today().format("yyyy/M/d"));
        $("input[name='qryKINDDATE']:checked").triggerHandler("click");
        $("input[name='qrySTAT_kind']:checked").triggerHandler("click");
        $("input.dateField").datepick();
    }

    //[重填]
    $("#btnRest").click(function (e) {
        reg.reset();
        this_init();
    });

    //////////////////////////////////////////////////////
    $(".dateField").blur(function (e) {
        ChkDate(this);
    });

    //點選日期種類
    $("input[name='qryKINDDATE']").click(function () {
        if ($(this).val() == "") {//不指定
            $("#spdate").hide();
        } else {
            $("#spdate").show();
        }
    });

    //點選承辦狀態
    $("input[name='qrySTAT_kind']").click(function () {
        if ($(this).val() == "") {//不指定
            $("input[name='qSTAT_CODE']").prop("checked", false);
            $("input[name='qSTAT_CODE']").lock();
        } else {
            $("input[name='qSTAT_CODE']").unlock();
        }
    });

    //[查詢]
    $("#btnSrch").click(function (e) {
        if ($("input[name='qryKINDDATE']:checked").val() != "") {
            if ($("#qrysDATE").val() == "") {
                alert("請輸入日期範圍起日!");
                $("#qrysDATE").focus();
                return false;
            }
            if ($("#qryeDATE").val() == "") {
                alert("請輸入日期範圍迄日!");
                $("#qryeDATE").focus();
                return false;
            }
        }
        if ($("input[name='qrySTAT_kind']:checked").val() == "Yes") {
            if ($("input[name='qSTAT_CODE']:checked").length == 0) {
                alert("請輸入查詢狀態!");
                return false;
            }
        }
        $("#qrySTAT_CODE").val("");
        $("#qrySTAT_CODE").val(getJoinValue("input[name='qSTAT_CODE']:checked", ";").substr(1));

        reg.action = "<%=HTProgPrefix%>_List.aspx";
        //reg.submit();
    });
</script>
