<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data" %>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<script runat="server">
    protected string HTProgCap = "國內爭救案交辦查詢";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "Brt19";//HttpContext.Current.Request["prgid"] ?? "";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";
    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";
    protected string SQL = "";

    protected string td_tscode = "", html_arcase = "";

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
            DataTable dt = new DataTable();
            SQL = "select distinct scode,sc_name,scode1 from vscode_roles ";
            SQL += " where branch='" + Session["SeBranch"] + "' and dept='" + Session["Dept"] + "' and syscode='" + Session["syscode"] + "' and roles='sales'";
            SQL += " order by scode1 ";
            cnn.DataTable(SQL, dt);
            td_tscode = "<select id='Qryscode' name='Qryscode' >" + dt.Option("{scode}", "{sc_name}") + "<option value='*' style='color:blue' selected>全部</option></select>";
        } else {
            td_tscode = "<input type='text' id='Qryscode' name='Qryscode' readonly class='SEdit' value='" + Session["se_scode"] + "'>";
            td_tscode += "<span='span_tscode'>" + Session["sc_name"] + "</span>";
        }
        
        //案性
        SQL = "SELECT RS_code, RS_detail FROM code_br WHERE dept = 'T' AND cr = 'Y' AND no_code='N' and mark='B' ";
        SQL += " ORDER BY rs_type desc,rs_class ,rs_code";
        html_arcase = Util.Option(conn, SQL, "{rs_code}", "{rs_code}--{rs_detail}");
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
		        <td class="lightbluetable" align="right">洽案營洽:</td>
		        <td class="whitetablebg" align="left"><%#td_tscode%>
                </td>
		        <td class="lightbluetable" align="right">承辦案性:</td>
		        <td class="whitetablebg" align="left">
                    <select id='QryArcase' name='QryArcase' >
                        <%#html_arcase%>
                    </select>
                </td>
	        </TR>
	        <TR>
		        <TD class=lightbluetable align=right>本所編號：</TD>
		        <TD class=whitetablebg >
			        <input type="text" id="Qryseq" name="Qryseq" size=<%#Sys.DmtSeq%> maxlength=<%#Sys.DmtSeq%>>
		        </TD>
		        <TD class=lightbluetable align=right>交辦單號：</TD>
		        <TD class=whitetablebg >
			        <input type="text" id="Qrycase_no" name="Qrycase_no">
		        </TD>
	        </TR>
	        <TR>
		        <TD class=lightbluetable align=right>客戶編號：</TD>
		        <TD class=whitetablebg>
			        <INPUT type="text" id="QryCust_area" name="QryCust_area" size="1" class=SEdit readonly maxlength="1">-
			        <INPUT type="text" id="QryCust_seq" name="QryCust_seq" size="6" maxlength="6">
		        </TD>
		        <TD class=lightbluetable align=right>客戶名稱：</TD>
		        <TD class=whitetablebg>
			        <input type="text" id="QryCust_name" name="QryCust_name" style="width:70%">
		        </TD>
	        </TR>
	        <TR>
		        <TD class=lightbluetable align=right>日期種類：</TD>
		        <TD class=whitetablebg colspan=3>
		            <label><input type="radio" name="ChangeDate" value="in_date">接洽日期</label>
		            <label><input type="radio" name="ChangeDate" value="case_date">交辦日期</label>
		            <label><input type="radio" name="ChangeDate" value="Bcase_date">交辦專案室日期</label>
		            <label><input type="radio" name="ChangeDate" value="last_date">法定期限</label>
		            <label><input type="radio" name="ChangeDate" value="" checked>不指定</label>
		        </TD>
	        </TR>
	        <TR>
		        <TD class=lightbluetable align=right>日期範圍：</TD>
		        <TD class=whitetablebg colspan=3>
			        <input type="text" id="QryCustDateS" name="QryCustDateS" size="10" class="dateField">～
			        <input type="text" id="QryCustDateE" name="QryCustDateE" size="10" class="dateField">&nbsp;&nbsp;(YYYY/MM/DD)
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

        $("#QryCust_area").val("<%=Session["seBranch"]%>");
    }

    //[重填]
    $("#btnRest").click(function (e) {
        reg.reset();
        this_init();
    });

    //////////////////////////////////////////////////////
    $("#Qryseq").blur(function (e) {
        chkNum1($(this),"本所編號");
    });
    $("#QryCust_seq").blur(function (e) {
        chkNum1($(this), "客戶編號");
    });
    $(".dateField").blur(function (e) {
        ChkDate(this);
    });

    //點選日期種類
    $("input[name='ChangeDate']").click(function () {
        if ($(this).val() == "") {//不指定
            $("#QryCustDateS").val("");
            $("#QryCustDateE").val("");
        } else {
            $("#QryCustDateS").val((new Date()).format("yyyy/M/1"));
            $("#QryCustDateE").val(Today().format("yyyy/M/d"));
        }
    });

    //[查詢]
    $("#btnSrch").click(function (e) {
        if ($("input[name='ChangeDate']:checked").val() != "") {
            var dateLabel = $("input[name='ChangeDate']:checked").parent('label').text();
            if ($("#QryCustDateS").val() == "" && $("#QryCustDateE").val() == "") {
                alert("請輸入" + dateLabel + "之日期範圍!");
                return false;
            }
        } else {
            if ($("#Qryseq").val() == "" && $("#Qrycase_no").val() == "" && $("#Qryscode").val() == "" && $("#QryArcase").val() == ""
                 && $("#QryCust_seq").val() == "" && $("#QryCust_name").val() == ""
                ) {
                alert("洽案營洽、承辦案性、本所編號、交辦單號、客戶編號及客戶名稱至少一個有值!!!");
                return false;
            }
        }

        reg.action = "<%=HTProgPrefix%>_List.aspx";
        reg.submit();
    });
</script>
