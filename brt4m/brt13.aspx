<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data" %>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<script runat="server">
    protected string HTProgCap = "國內案洽案交辦查詢";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "Brt13";//HttpContext.Current.Request["prgid"] ?? "";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";
    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";
    protected string SQL = "";

    protected string html_scode = "", html_arcase = "";

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
        html_scode = Sys.getCaseDmtScode("", "").Option("{in_scode}", "{star}{in_scode}_{sc_name}", "style='color:{color}'", true);

        //案性
        SQL = "SELECT RS_code, RS_detail FROM code_br WHERE dept = 'T' AND cr = 'Y' AND no_code='N' ";
        SQL += "and (end_date is null or end_date = '' or end_date > getdate()) ";
        SQL += " ORDER BY rs_type desc,rs_class ,rs_code";
        html_arcase = Util.Option(conn, SQL, "{rs_code}", "{rs_code}--{rs_detail}");
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
		        <td class="lightbluetable" align="right">洽案營洽:</td>
		        <td class="whitetablebg" align="left">
                    <select id='scode' name='scode' >
                        <option value="*" style="color:blue" selected>全部</option>
                        <%#html_scode%>
                    </select>
                </td>
		        <td class="lightbluetable" align="right">承辦案性:</td>
		        <td class="whitetablebg" align="left">
                    <select id='tfx_Arcase' name='tfx_Arcase' >
                        <%#html_arcase%>
                    </select>
                </td>
	        </TR>
	        <TR>
		        <TD class=lightbluetable align=right>本所編號：</TD>
		        <TD class=whitetablebg >
			        <input type="text" id="pfx_seq" name="pfx_seq" size=<%#Sys.DmtSeq%> maxlength=<%#Sys.DmtSeq%>>
		        </TD>
		        <TD class=lightbluetable align=right>交辦單號：</TD>
		        <TD class=whitetablebg >
			        <input type="text" id="tfx_case_no" name="tfx_case_no">
		        </TD>
	        </TR>
	        <TR>
		        <TD class=lightbluetable align=right>客戶編號：</TD>
		        <TD class=whitetablebg>
			        <INPUT type="text" id="tfx_Cust_area" name="tfx_Cust_area" size="1" class=SEdit readonly maxlength="1">-
			        <INPUT type="text" id="tfx_Cust_seq" name="tfx_Cust_seq" size="6" maxlength="6">
		        </TD>
		        <TD class=lightbluetable align=right>客戶名稱：</TD>
		        <TD class=whitetablebg>
			        <input type="text" id="pfx_Cust_name" name="pfx_Cust_name" style="width:70%">
		        </TD>
	        </TR>
	        <TR>
		        <TD class=lightbluetable align=right>契約號碼：</TD>
		        <TD class=whitetablebg colspan=3>
		            <label><input type="radio" name="Contract_no_Type" value="N"><INPUT TYPE=text id=tfx_Contract_no NAME=tfx_Contract_no SIZE=10 MAXLENGTH=10 onchange="reg.Contract_no_Type(0).checked=true"></label>
		            <label><input type="radio" name="Contract_no_Type" value="A">後續案無契約書</label>
			        <label style="display:none"><input type="radio" name="Contract_no_Type" value="B">特案簽報</label><!--2015/12/29修改，併入C不顯示-->
		            <label><input type="radio" name="Contract_no_Type" value="C">其他契約書無編號/特案簽報</label>
		            <label><input type="radio" name="Contract_no_Type" value="M">總契約書
                        <INPUT TYPE=text id=Mcontract_no NAME=Mcontract_no SIZE=10 MAXLENGTH=10 onchange="reg.Contract_no_Type(4).checked=true">
		                <input type="button" id="btncustcontract" class="cbutton" value="客戶總契約書查詢" >
		            </label>
		            <label><input type="radio" name="Contract_no_Type" value="*" checked>不指定</label>
		        </TD>
	        </TR>
	        <TR>
		        <TD class=lightbluetable align=right>契約書後補狀態:</TD>
		        <TD class=whitetablebg align=left colspan=3>
			        <label><input type="checkbox" id="Contract_flag" name="Contract_flag" value="Y" onclick="reg.Contract_flag1(2).checked=true">契約書後補，</label>
			        <label><input type="radio" name="Contract_flag1" value="N" onclick="reg.Contract_flag.checked=true">尚未後補完成</label>
			        <label><input type="radio" name="Contract_flag1" value="Y" onclick="reg.Contract_flag.checked=true">已後補完成</label>
			        <label><input type="radio" name="Contract_flag1" value="" checked>不指定</label>
		        </TD>
	        </TR>	
	        <TR>
		        <TD class=lightbluetable align=right>日期種類：</TD>
		        <TD class=whitetablebg colspan=7>
		            <label><input type="radio" name="ChangeDate" value="A">接洽日期</label>
		            <label><input type="radio" name="ChangeDate" value="B">交辦日期</label>
		            <label><input type="radio" name="ChangeDate" value="" checked>不指定</label>
		        </TD>
	        </TR>
	        <TR>
		        <TD class=lightbluetable align=right>日期範圍：</TD>
		        <TD class=whitetablebg colspan=7>
			        <input type="text" id="CustDate1" name="CustDate1" size="10" class="dateField">～
			        <input type="text" id="CustDate2" name="CustDate2" size="10" class="dateField">&nbsp;&nbsp;(YYYY/MM/DD)
		        </TD>
	        </TR>
	        <tr>
		        <td class="lightbluetable" align="right">作業狀態 :</td>
		        <td class="whitetablebg" align="left" colspan=3>
		            <label><input type="radio" name="tfx_stat_code" value="NN" checked>未交辦</label>
		            <label><input type="radio" name="tfx_stat_code" value="YN">已交辦</label>
		            <label><input type="radio" name="tfx_stat_code" value="YY">簽准</label>
		            <label><input type="radio" name="tfx_stat_code" value="NX">不准退回</label>
		            <label><input type="radio" name="tfx_stat_code" value="YZ">程序確認</label>
		            <label><input type="radio" name="tfx_stat_code" value="">不指定</label>
		        </td>
	        </tr>
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

        $("#tfx_Cust_area").val("<%=Session["seBranch"]%>");
    }

    //[重填]
    $("#btnRest").click(function (e) {
        reg.reset();
        this_init();
    });

    //////////////////////////////////////////////////////
    $("#pfx_seq").blur(function (e) {
        chkNum1($(this),"本所編號");
    });
    $("#tfx_Cust_seq").blur(function (e) {
        chkNum1($(this), "客戶編號");
    });
    $(".dateField").blur(function (e) {
        ChkDate(this);
    });

    //點選契約號碼
    $("input[name='Contract_no_Type']").click(function () {
        if ($(this).val() != "N") {//不是一般契約書
            $("#tfx_Contract_no").val("");
        }
    });

    //點選日期種類
    $("input[name='ChangeDate']").click(function () {
        if ($(this).val() == "") {//不指定
            $("#CustDate1").val("");
            $("#CustDate2").val("");
        } else {
            $("#CustDate1").val((new Date()).format("yyyy/M/1"));
            $("#CustDate2").val(Today().format("yyyy/M/d"));
        }
    });

    //[客戶總契約書查詢]
    $("#btncustcontract").click(function () {
        //***todo
       var url = getRootPath() + "/sub/cust21.aspx?qs_dept=<%=Session["dept"]%>&prgid=cust21&from_flag=Query&close_flag=Y&noframe=Y";
	   window.open(url,"myWindowTwoN", "width=880 height=680 top=40 left=80 toolbar=no, menubar=no, location=no, directories=no resizable=yes status=no scrollbars=yes");
    });

    //[查詢]
    $("#btnSrch").click(function (e) {
        //*****契約號碼控制
        var contract_type = $("input[name='Contract_no_Type']:checked").val();
        if (contract_type == "A") {//後續案無契約書
            $("#tfx_Contract_no").val("A");
        } else if (contract_type == "B") {//特案簽報
            $("#tfx_Contract_no").val("B");
        } else if (contract_type == "C") {//特案簽報
            $("#tfx_Contract_no").val("C");//其他契約書無編號
        } else if (contract_type == "M") {//總契約書
            $("#tfx_Contract_no").val($("#Mcontract_no").val());
        } else if (contract_type == "N") {//一般
            if ($("#tfx_Contract_no").val() != "" && IsNumeric($("#tfx_Contract_no").val()) == false) {
                alert("契約號碼請輸入數值!!");
                return false;
            }
        } else if (contract_type == "*") {//不指定
            $("#tfx_Contract_no").val("");
        }

        if ($("input[name='ChangeDate']:checked").val() != "") {
            var dateLabel = $("input[name='ChangeDate']:checked").parent('label').text();
            if ($("#CustDate1").val() == "" && $("#CustDate2").val() == "") {
                alert("請輸入" + dateLabel + "之日期範圍!");
                return false;
            }
        }

        if ($("input[name='tfx_stat_code']:checked").val() == "" && $("input[name='ChangeDate']:checked").val() == "") {//日期&狀態:不指定
            if ($("#pfx_seq").val() == "" && $("#tfx_case_no").val() == "" && $("#scode").val() == "" && $("#tfx_Arcase").val() == ""
                 && $("#tfx_Cust_seq").val() == "" && $("#pfx_Cust_name").val() == "" && $("#tfx_Contract_no").val() == ""
                ) {
                alert("請輸入任一查詢條件!!!");
                return false;
            }
        }

        reg.action = "<%=HTProgPrefix%>_List.aspx";
        reg.submit();
    });
</script>
