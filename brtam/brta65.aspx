<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data" %>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<script runat="server">
    protected string HTProgCap = "國內案案件資料查詢作業";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = HttpContext.Current.Request["prgid"] ?? "";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";
    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";
    protected string SQL = "";

    protected string td_tscode = "", html_end_code="";

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
            td_tscode = "<select id='scode' name='scode' >";
            td_tscode += Sys.getDmtScode("", "").Option("{scode}", "{star}{scode}_{sc_name}", "style='color:{color}'", true);
            td_tscode += "<option value='" + Sys.GetSession("seBranch") + Sys.GetSession("dept") + "'>" + Sys.GetSession("seBranch") + Sys.GetSession("dept").ToUpper() + "_部門(開放客戶)</option>";
            td_tscode += "</select>";
        } else {
            td_tscode = "<input type='hidden' id='scode' name='scode' readonly class='SEdit' value='" + Session["se_scode"] + "'>" + Session["sc_name"];
        }

        //結案代碼
        html_end_code = Sys.getCustCode("EndCode", "", "sortfld").Option("{cust_code}", "{code_name}");
    }
</script>
<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title><%#HTProgCap%></title>
<link rel="stylesheet" type="text/css" href="<%=Page.ResolveUrl("~/inc/setstyle.css")%>" />
<link rel="stylesheet" type="text/css" href="<%=Page.ResolveUrl("~/js/lib/jquery.datepick.css")%>" />
<link rel="stylesheet" type="text/css" href="<%=Page.ResolveUrl("~/js/lib/toastr.css")%>" />
<link rel="stylesheet" type="text/css" href="<%=Page.ResolveUrl("~/js/lib/jquery-ui.min.css")%>" />
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/jquery-1.12.4.min.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/jquery-ui.min.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/jquery.datepick.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/jquery.datepick-zh-TW.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/toastr.min.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/util.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/client_chk.js")%>"></script>
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
		        <TD class=lightbluetable align=right>本所編號：</TD>
		        <TD class=whitetablebg >
			        <input type="text" id="seq" name="seq" size=<%#Sys.DmtSeq%> maxlength=<%#Sys.DmtSeq%>>-
			        <input type="text" id="seq1" name="seq1" size=<%#Sys.DmtSeq1%> maxlength=<%#Sys.DmtSeq1%> style="text-transform:uppercase;">
		        </TD>
		        <TD class=lightbluetable align=right>類別：</TD>
		        <TD class=whitetablebg >
			        <input type="text" id="class" name="class" size=3 maxlength=3>
		        </TD>
		        <TD class=lightbluetable align=right>母案編號：</TD>
		        <TD class=whitetablebg >
			        <input type="text" id="mseq" name="mseq" size=<%#Sys.DmtSeq%> maxlength=<%#Sys.DmtSeq%>>-
			        <input type="text" id="mseq1" name="mseq1" size=<%#Sys.DmtSeq1%> maxlength=<%#Sys.DmtSeq1%> style="text-transform:uppercase;">
		        </TD>
		        <td class="lightbluetable" align="right">營　　洽:</td>
		        <td class="whitetablebg" align="left"><%#td_tscode%></td>
	        </TR>
	        <TR>
		        <TD class=lightbluetable align=right>客戶編號：</TD>
		        <TD class=whitetablebg>
			        <INPUT type="text" id="cust_area" name="cust_area" size="1" class=SEdit readonly maxlength="1">-
			        <INPUT type="text" id="cust_seq" name="cust_seq" size="6" maxlength="6">
		        </TD>
		        <TD class=lightbluetable align=right>客戶名稱：</TD>
		        <TD class=whitetablebg colspan="5">
			        <input type="text" id="ap_cname1" name="ap_cname1" size=45 maxlength=40>
		        </TD>
	        </TR>
	        <TR>
		        <TD class=lightbluetable align=right>申請人編號：</TD>
		        <TD class=whitetablebg>
			        <input type="text" id="apcust_no" name="apcust_no" size=10 maxlength=10>
		        </TD>
		        <TD class=lightbluetable align=right>申請人名稱：</TD>
		        <TD class=whitetablebg colspan="5">
			        <input type="text" id="ap_cname" name="ap_cname" size=45 maxlength=40>
		        </TD>
	        </TR>
	        <TR>
                <TD class=lightbluetable align=right rowspan=2>商標種類：</TD>
		        <TD class=whitetablebg colspan=7>
			        <input type="hidden" id="hs_mark" name="hs_mark" value="">
			        <label><input type="radio" name="s_mark" value="T" onclick="reg.hs_mark.value = this.value">商標</label>
			        <label><input type="radio" name="s_mark" value="S" onclick="reg.hs_mark.value = this.value">92年修正前服務標章</label>
			        <label><input type="radio" name="s_mark" value="L" onclick="reg.hs_mark.value = this.value">證明標章</label>
			        <label><input type="radio" name="s_mark" value="M" onclick="reg.hs_mark.value = this.value">團體標章</label>
			        <label><input type="radio" name="s_mark" value="M" onclick="reg.hs_mark.value = this.value">團體商標</label>
			        <label><input type="radio" name="s_mark" value="" checked onclick="reg.hs_mark.value = this.value">不指定</label>
		        </TD>
	        </TR>
	        <TR>
		        <TD class=whitetablebg colspan=7>
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
		        <TD class=whitetablebg colspan=7>
			        <input type="hidden" id="hpul" name="hpul" value="" >
			        <label><input type="radio" name="pul" value="0" onclick="reg.hpul.value = this.value">正商標</label>
			        <label><input type="radio" name="pul" value="1" onclick="reg.hpul.value = this.value">聯合</label>
			        <label><input type="radio" name="pul" value="2" onclick="reg.hpul.value = this.value">防護</label>
			        <label><input type="radio" name="pul" value="" checked onclick="reg.hpul.value = this.value">不指定</label>
		        </TD>
	        </TR>
	        <TR>	
		        <TD class=lightbluetable align=right>商標名稱：</TD>
		        <TD class=whitetablebg colspan=7>
			        <input type="text" id="appl_name" name="appl_name" size=40 maxlength=30>
		        </TD>
	        </TR>
	        <TR>	
		        <TD class=lightbluetable align=right>文號種類：</TD>
		        <TD class=whitetablebg colspan=5>
			        <label><input type="radio" name="kind_no" value="Apply_No">申請號碼</label>
			        <label><input type="radio" name="kind_no" value="Issue_No">註冊號碼</label>
			        <label><input type="radio" name="kind_no" value="Rej_No">核駁號碼</label>
			        <label><input type="radio" name="kind_no" value="" checked>不指定</label>
                </TD>
		        <TD class=lightbluetable align=right>官方文號：</TD>
		        <TD class=whitetablebg>
                    <input type="text" id="ref_no" name="ref_no" size=20>
		        </TD>
	        </TR>
	        <TR>
		        <TD class=lightbluetable align=right>日期種類：</TD>
		        <TD class=whitetablebg colspan=7>
			        <label><input type="radio" name="kind_date" value="In_Date">立案日期</label>
			        <label><input type="radio" name="kind_date" value="Apply_Date">申請日期</label>
			        <label><input type="radio" name="kind_date" value="Issue_Date">註冊日期</label>
			        <label><input type="radio" name="kind_date" value="End_Date">結案日期</label>
			        <label><input type="radio" name="kind_date" value="term2">專用期限迄日</label>
			        <label><input type="radio" name="kind_date" value="" checked>不指定</label>
		        </TD>
	        </TR>
	        <TR>
		        <TD class=lightbluetable align=right>日期期間：</TD>
		        <TD class=whitetablebg colspan=7>
			        <input type="text" id="sdate" name="sdate" size="10" class="dateField">～
			        <input type="text" id="edate" name="edate" size="10" class="dateField">&nbsp;&nbsp;(YYYY/MM/DD)
		        </TD>
	        </TR>
	        <TR>
		        <TD class=lightbluetable align=right>結案代碼：</TD>
		        <TD class=whitetablebg colspan=7>
		            <label><input type="radio" name="qryend" value="" checked>不指定</label>
			        <label><input type="radio" name="qryend" value="Y">尚未結案</label>
			        <label><input type="radio" name="qryend" value="N">已結案</label>
			        <span id='sp_endcode' style="display:none" >
			        ,結案代碼
	   		        <Select NAME="end_code" id="end_code">
				        <%#html_end_code%>
			        </SELECT>	
			        </span>		
			
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
    <br />*營洽中有　<font color=red size=2>' * '</font>　符號者，表該營洽已離職!!
</div>
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

        $("#cust_area").val("<%=Session["seBranch"]%>");
    }

    //[重填]
    $("#btnRest").click(function (e) {
        reg.reset();
        this_init();
    });

    //////////////////////////////////////////////////////
    $("#seq").blur(function (e) {
        chkNum1($(this),"本所編號");
    });
    $("#cust_seq").blur(function (e) {
        chkNum1($(this), "客戶編號");
    });
    $(".dateField").blur(function (e) {
        ChkDate(this);
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

    //點選結案代碼
    $("input[name='qryend']").click(function () {
        $("#sp_endcode").hide();
        if ($(this).val() == "N") {//已結案
            $("#sp_endcode").show();
        }
    });

    //[查詢]
    $("#btnSrch").click(function (e) {
        if ($("#seq").val() == "" && $("#seq1").val() == "" && $("#cust_seq").val() == ""
            && $("#ap_cname1").val() == "" && $("#hs_mark").val() == "" && $("#appl_name").val() == ""
             && $("#ref_no").val() == "" && $("#sdate").val() == "" && $("#edate").val() == ""
             && $("#mseq").val() == "" && $("#mseq1").val() == "" && $("#scode").val() == ""
             && $("#apcust_no").val() == "" && $("#ap_cname").val() == "" && $("#hpul").val() == ""
            ) {
            alert("請輸入任一查詢條件!!!");
            return false;
        }

        if ($("#seq").val() != "" && IsNumeric($("#seq").val()) == false) {
            alert("本所序號輸入的資料必須為數值!!");
            return false;
        }
        if ($("#cust_seq").val() != "" && IsNumeric($("#cust_seq").val()) == false) {
            alert("客戶編號輸入的資料必須為數值!!");
            return false;
        }
        if ($("#ref_no").val() != "" && IsNumeric($("#ref_no").val()) == false) {
            alert("官方文號輸入的資料必須為數值!!");
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

        reg.action = "brta65_List.aspx";
        reg.submit();
    });
</script>
