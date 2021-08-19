<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data" %>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<script runat="server">
    protected string HTProgCap = "國內案案件進度查詢作業";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "Brta61";//HttpContext.Current.Request["prgid"] ?? "";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";
    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";
    protected string SQL = "";

    protected string td_tscode = "", html_ctrl_type = "";

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

        //營洽清單
        if ((HTProgRight & 64) != 0) {
            td_tscode = "<select id='scode1' name='scode1' >";
            td_tscode += Sys.getDmtScode("", "").Option("{scode}", "{star}{scode}_{sc_name}", "style='color:{color}'", true);
            td_tscode += "<option value='" + Sys.GetSession("seBranch") + Sys.GetSession("dept") + "'>" + Sys.GetSession("seBranch") + Sys.GetSession("dept").ToUpper() + "_部門(開放客戶)</option>";
            td_tscode += "</select>";
        } else {
            td_tscode = "<input type='hidden' id='scode1' name='scode1' readonly class='SEdit' value='" + Session["se_scode"] + "'>" + Session["sc_name"];
        }

        //管制種類
        html_ctrl_type = Sys.getCustCode("CT", "", "").Option("{cust_code}", "{code_name}",false);
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
        <table border="0" class="bluetable" cellspacing="1" cellpadding="2" width="80%" align="center">
	        <TR>
		        <TD class=lightbluetable align=right>進度狀況：</TD>
		        <TD class=whitetablebg colspan=3>
			        <label><input type="radio" name="gtype" value="A" checked>所有進度</label>
			        <label><input type="radio" name="gtype" value="B">未銷管查詢</label>
			        <select id="ctrl_type" name="ctrl_type" disabled>
		                <option value="" style="color:blue" selected>所有管制種類</option>
                        <%#html_ctrl_type%>
			        </select>
		        </TD>
	        </TR>
	        <TR>
		        <TD class=lightbluetable align=right>本所編號：</TD>
		        <TD class=whitetablebg >
			        <input type="text" id="seq" name="seq" size=<%#Sys.DmtSeq%> maxlength=<%#Sys.DmtSeq%>>-
			        <input type="text" id="seq1" name="seq1" size=<%#Sys.DmtSeq1%> maxlength=<%#Sys.DmtSeq1%> style="text-transform:uppercase;">
		        </TD>
		        <TD class=lightbluetable align=right>商標名稱：</TD>
		        <TD class=whitetablebg>
			        <input type="text" id="appl_name" name="appl_name" size=40 maxlength=30>
		        </TD>
	        </TR>
	        <TR>
		        <TD class=lightbluetable align=right>客戶編號：</TD>
		        <TD class=whitetablebg>
			        <INPUT type="text" id="cust_area" name="cust_area" size="1" class=SEdit readonly maxlength="1">-
			        <INPUT type="text" id="cust_seq" name="cust_seq" size="6" maxlength="6">
		        </TD>
		        <TD class=lightbluetable align=right>客戶名稱：</TD>
		        <TD class=whitetablebg>
			        <input type="text" id="ap_cname1" name="ap_cname1" size=45 maxlength=40>
		        </TD>
	        </TR>
	        <TR>
                <TD class=lightbluetable align=right rowspan=2>商標種類：</TD>
		        <TD class=whitetablebg colspan=3>
			        <label><input type="radio" name="s_mark" value="T">商標</label>
			        <label><input type="radio" name="s_mark" value="S">92年修正前服務標章</label>
			        <label><input type="radio" name="s_mark" value="L">證明標章</label>
			        <label><input type="radio" name="s_mark" value="M">團體標章</label>
			        <label><input type="radio" name="s_mark" value="M">團體商標</label>
			        <label><input type="radio" name="s_mark" value="" checked>不指定</label>
		        </TD>
	        </TR>
	        <TR>
		        <TD class=whitetablebg colspan=3>
			        <label><input type="radio" name="s_mark2" value="A">平面</label>
			        <label><input type="radio" name="s_mark2" value="B">立體</label>
			        <label><input type="radio" name="s_mark2" value="C">聲音</label>
			        <label><input type="radio" name="s_mark2" value="D">顏色</label>
			        <label><input type="radio" name="s_mark2" value="E">全像圖</label>
			        <label><input type="radio" name="s_mark2" value="F">動態</label>
			        <label><input type="radio" name="s_mark2" value="G">其他</label>
			        <label><input type="radio" name="s_mark2" value="" checked>不指定</label>
		        </TD>
	        </TR>
	        <TR>
		        <TD class=lightbluetable align=right>正聯防：</TD>
		        <TD class=whitetablebg colspan=3>
			        <label><input type="radio" name="pul" value="0">正商標</label>
			        <label><input type="radio" name="pul" value="1">聯合</label>
			        <label><input type="radio" name="pul" value="2">防護</label>
			        <label><input type="radio" name="pul" value="" checked>不指定</label>
		        </TD>
	        </TR>
	        <TR>
		        <td class="lightbluetable" align="right">營　　洽:</td>
		        <td class="whitetablebg" align="left" colspan=3><%#td_tscode%></td>
	        </TR>
	        <TR>	
		        <TD class=lightbluetable align=right>文號種類：</TD>
		        <TD class=whitetablebg colspan=3>
			        <label><input type="radio" name="kind_no" value="Apply_No">申請號碼</label>
			        <label><input type="radio" name="kind_no" value="Issue_No">註冊號碼</label>
			        <label><input type="radio" name="kind_no" value="Rej_No">核駁號碼</label>
			        <label><input type="radio" name="kind_no" value="" checked>不指定</label>
                </TD>
	        </TR>
	        <TR>
		        <TD class=lightbluetable align=right>官方文號：</TD>
		        <TD class=whitetablebg colspan=3>
                    <input type="text" id="ref_no" name="ref_no" size=20>
		        </TD>
	        </TR>
	        <TR>
		        <TD class=lightbluetable align=right>日期種類：</TD>
		        <TD class=whitetablebg colspan=7>
			        <label><input type="radio" name="kind_date" value="Step_Date" checked>進度日期</label>
			        <label><input type="radio" name="kind_date" value="In_Date">立案日期</label>
			        <label><input type="radio" name="kind_date" value="Apply_Date">申請日期</label>
			        <label><input type="radio" name="kind_date" value="Issue_Date">註冊日期</label>
			        <label><input type="radio" name="kind_date" value="End_Date">結案日期</label>
			        <label><input type="radio" name="kind_date" value="term2">專用期限迄日</label>
			        <label><input type="radio" name="kind_date" value="">不指定</label>
		        </TD>
	        </TR>
	        <TR>
		        <TD class=lightbluetable align=right>日期期間：</TD>
		        <TD class=whitetablebg colspan=7>
			        <input type="text" id="sdate" name="sdate" size="10" class="dateField">～
			        <input type="text" id="edate" name="edate" size="10" class="dateField">&nbsp;&nbsp;(YYYY/MM/DD)
			        <label><input type="checkbox" id="date_flg" name="date_flg">不指定</label>
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

<br>
<div align="left">
    <br />*營洽中有　<font color=red size=2>' * '</font>　符號者，表該營洽已離職!!
</div>

<div id="dialog"></div>

<iframe id="ActFrame" name="ActFrame" src="about:blank" width="100%" height="300" style="display:none"></iframe>
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

        $("#sdate").val(Today().format("yyyy/M/1"));
        $("#edate").val(Today().format("yyyy/M/d"));

        $("#cust_area").val("<%=Session["seBranch"]%>");
    }

    //[重填]
    $("#btnRest").click(function (e) {
        reg.reset();
        this_init();
    });

    //////////////////////////////////////////////////////
    $("#seq").blur(function (e) {
        chkNum1($(this), "本所編號");
        if ($(this).val() != "") {
            $("#sdate,#edate").val("");
        } else {
            $("#date_flg").triggerHandler("click");
        }
    });
    $("#cust_seq").blur(function (e) {
        chkNum1($(this), "客戶編號");
        if ($(this).val() != "") {
            $("#sdate,#edate").val("");
        } else if ($("#date_flg").prop("checked") == false) {
            $("#date_flg").triggerHandler("click");
        }
    });
    $(".dateField").blur(function (e) {
        ChkDate(this);
    });

    //點選進度狀況
    $("input[name='gtype']").click(function () {
        if ($(this).val() == "A") {//所有進度
            $("#ctrl_type").prop("disabled", true);
        } else {
            $("#ctrl_type").prop("disabled", false);
        }
    });

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

    //日期期間:不指定
    $("#date_flg").click(function () {
        if ($(this).prop("checked")==true) {
            $("#sdate,#edate").val("");
        } else {
            $("#sdate").val(Today().format("yyyy/M/1"));
            $("#edate").val(Today().format("yyyy/M/d"));
        }
    });

    //[查詢]
    $("#btnSrch").click(function (e) {
        if ($("#seq").val() != "") {
            $("#seq").blur();
        }

        reg.action = "brta61_List.aspx";
        reg.submit();
    });
</script>
