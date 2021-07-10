<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data" %>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<script runat="server">
    protected string HTProgCap = "國內案管制期限維護作業";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = HttpContext.Current.Request["prgid"] ?? "";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";
    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";
    protected string SQL = "";

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
		        <TD class=lightbluetable align=right>商標名稱：</TD>
		        <TD class=whitetablebg >
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
		        <TD class=whitetablebg colspan=3>
			        <label><input type="radio" name="kind_date" value="Step_Date" checked>進度日期</label>
			        <label><input type="radio" name="kind_date" value="In_Date">立案日期</label>
			        <label><input type="radio" name="kind_date" value="Apply_Date">申請日期</label>
			        <label><input type="radio" name="kind_date" value="Issue_Date">註冊日期</label>
			        <label><input type="radio" name="kind_date" value="End_Date">結案日期</label>
			        <label><input type="radio" name="kind_date" value="">不指定</label>
		        </TD>
	        </TR>
	        <TR>
		        <TD class=lightbluetable align=right>日期期間：</TD>
		        <TD class=whitetablebg colspan=3>
			        <input type="text" id="sdate" name="sdate" size="10" class="dateField">～
			        <input type="text" id="edate" name="edate" size="10" class="dateField">&nbsp;&nbsp;(YYYY/MM/DD)
			        <label><input type="checkbox" id="date_flag" name="date_flag">不指定</label>
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
        chkNum1($(this),"本所編號");
    });
    $("#cust_seq").blur(function (e) {
        chkNum1($(this), "客戶編號");
    });
    $(".dateField").blur(function (e) {
        ChkDate(this);
    });

    //日期期間:不指定
    $("#date_flag").click(function () {
        if ($(this).prop("checked") == true) {
            $("#sdate,#edate").val("");
        } else {
            $("#sdate").val(Today().format("yyyy/M/1"));
            $("#edate").val(Today().format("yyyy/M/d"));
        }
    });

    //[查詢]
    $("#btnSrch").click(function (e) {
        if ($("#seq").val() == "" && $("#seq1").val() == "" && $("#appl_name").val() == ""
            && $("#cust_seq").val() == "" && $("#ap_cname1").val() == "" && $("#ref_no").val() == ""
            && $("#sdate").val() == "" && $("#edate").val() == "") {
            alert("請至少輸入一項查詢條件!!!");
            return false;
        }

        reg.action = "brta23_List.aspx";
        reg.submit();
    });
</script>
