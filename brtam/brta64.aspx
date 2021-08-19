<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data" %>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<script runat="server">
    protected string HTProgCap = "國內案各項期限稽催查詢作業";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "Brta64";//HttpContext.Current.Request["prgid"] ?? "";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";
    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";
    protected string SQL = "";

    protected string cgrs = "";
    protected string step_date = "";
    protected string rs_no = "";

    protected string td_tscode = "";

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
        
        cgrs = (Request["cgrs"] ?? "").ToUpper();
        
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
            StrFormBtn += "<input type=\"button\" id=\"btnSrch\" value=\"列　印\" class=\"cbutton bsubmit\" />\n";
            StrFormBtn += "<input type=\"button\" id=\"btnRest\" value=\"重　填\" class=\"cbutton\" />\n";
        }

        using (DBHelper conn = new DBHelper(Conn.btbrt).Debug(false)) {
            //營洽清單
            if ((HTProgRight & 64) != 0) {
                td_tscode = "<select id='scode1' name='scode1' >";
                td_tscode += Sys.getDmtScode("", "").Option("{scode}", "{star}{scode}_{sc_name}", "style='color:{color}'", true);
                td_tscode += "<option value='" + Sys.GetSession("seBranch") + Sys.GetSession("dept") + "'>" + Sys.GetSession("seBranch") + Sys.GetSession("dept").ToUpper() + "_部門(開放客戶)</option>";
                td_tscode += "</select>";
            } else {
                td_tscode = "<input type='hidden' id='scode1' name='scode1' readonly class='SEdit' value='" + Session["se_scode"] + "'>";
                td_tscode += "<input type='text' id='ScodeName' name='ScodeName' readonly class='SEdit' value='" + Session["sc_name"] + "'>";
            }
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
    <input type="hidden" id="SetOrder" name="SetOrder" value="">

    <div id="id-div-slide">
        <table id="qryForm" border="0" class="bluetable" cellspacing="1" cellpadding="2" width="90%" align="center">	
	        <TR>
		        <TD class=lightbluetable align=right rowspan=5>稽催種類：</TD>
		        <TD class=whitetablebg>			
			        <label><input type="radio" name="qtype" value="1" checked>管制期限稽催查詢 (依案件管制期限)</label>
		        </TD>
	        </TR>
	        <TR>
		        <TD class=whitetablebg>			
			        <label><input type="radio" name="qtype" value="2">延展期限稽催查詢 (依專用期限迄日)</label>
		        </TD>
	        </TR>
	        <TR>
		        <TD class=whitetablebg>			
			        <label><input type="radio" name="qtype" value="3">第二期註冊費稽催查詢 (專用期限起日 + 3 年)</label>
		        </TD>
	        </TR>
	        <TR>
		        <TD class=whitetablebg>			
			        <label><input type="radio" name="qtype" value="4">使用稽催查詢 (專用期限起日每隔 3 年)</label>
		        </TD>
	        </TR>
	        <TR>
		        <TD class=whitetablebg>			
			        <label><input type="radio" name="qtype" value="5">追蹤期限稽催查詢 (依案件管制期限)</label>
		        </TD>
	        </TR>
	        <TR id="tr_ctrl">
		        <TD class=lightbluetable align=right>管制種類：</TD>
		        <TD class=whitetablebg >
			        <label><input type="hidden" name="ctrl_typenm" id="ctrl_typenm" value="全部"></label>
			        <label><input type="radio" name="ctrl_type" value="A">法定期限(A*)</label>
			        <label><input type="radio" name="ctrl_type" value="B">自管期限(B*)</label>
			        <label><input type="radio" name="ctrl_type" value="" checked>不指定</label>
		        </TD>
	        </TR>
	        <TR id="tr_date">
		        <TD class=lightbluetable align=right><span id="span_date">管制期限：</span></TD>
		        <TD class=whitetablebg>
			        <input type="text" name="sdate" id="sdate" size="10" class="dateField">～			
			        <input type="text" name="edate" id="edate" size="10" class="dateField">&nbsp;&nbsp;(YYYY/MM/DD)
			        <span id="span_sedate">
                        <br><input type='text' id='sdate1' name='sdate1' size='10' class="dateField">～<input type='text' id='edate1' name='edate1' size='10' class="dateField">
			        </span>
			        <span id="span_chkdate"><input type="checkbox" id="chkdate" name="chkdate" value="Y">不指定</span>
		        </TD>
	        </TR>
	        <tr>
		        <td class=lightbluetable align="right" id=salename  width="15%">營　　洽：</td>
		        <td class=whitetablebg align="left" colspan=3>
			        <%#td_tscode%>
		        </td>
	        </tr>
	        <TR>
		        <td class="lightbluetable" align="right">客戶編號：</td>
		        <td class="whitetablebg" align="left" colspan=3>
			        <input type="text" id="cust_area" name="cust_area" size="1" class=SEdit readonly value="<%#Session["seBranch"]%>">-
			        <input type="text" id="cust_seq" name="cust_seq" size="6" maxlength=6>
		        </td>
	        </TR>
	        <TR>
		        <td class="lightbluetable" align="right">查詢方式：</td>
		        <td class="whitetablebg" align="left" colspan=3>
			        <label><input type="checkbox" id="qendcode" name="qendcode" value="Y">包含結案案件</label>
		        </td>
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
    <br />
    *營洽中有　<font color=red size=2>' * '</font>　符號者，表該營洽已離職!!<br>
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
        $("input[name='qtype']:checked").triggerHandler("click");
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

    //稽催種類
    $("input[name='qtype']").click(function (e) {
        var pvalue = $(this).val();

        if (pvalue == "1") {//管制期限稽催查詢 
            $("#span_date").html("管制期限：");
            $("#span_chkdate").hide();//管制期限:不指定
            $("#span_sedate").hide();//專用期限迄日
            $("#tr_ctrl").show();//管制種類
            $("#sdate").val("1980/1/1");
            $("#edate").val(Today().addDays(5).format("yyyy/M/d"));
            $("#SetOrder").val("scode1,ctrl_date");
        }else if (pvalue == "2") {//延展期限稽催查詢 
            $("#span_date").html("專用期限迄日：");
            $("#span_chkdate").hide();//管制期限:不指定
            $("#span_sedate").hide();//專用期限迄日
            $("#tr_ctrl").hide();//管制種類
            $("#sdate").val(Today().format("yyyy/M/1"));
            $("#edate").val(CDate($("#sdate").val()).addMonths(2).addDays(-1).format("yyyy/M/d"));
            $("#SetOrder").val("a.scode,ap_cname,a.term2");
        }else if (pvalue == "3") {//第二期註冊費稽催查詢 
            $("#span_date").html("專用期限起日：");
            $("#span_chkdate").hide();//管制期限:不指定
            $("#span_sedate").hide();//專用期限迄日
            $("#tr_ctrl").hide();//管制種類
            $("#sdate").val(Today().addYears(-3).format("yyyy/M/1"));
            $("#edate").val(CDate($("#sdate").val()).addMonths(2).addDays(-1).format("yyyy/M/d"));
            $("#SetOrder").val("a.scode,ap_cname,a.term1");
        } else if (pvalue == "4") {//使用稽催查詢 
            $("#span_date").html("專用期限起日：");
            $("#span_chkdate").hide();//管制期限:不指定
            $("#span_sedate").show();//專用期限迄日
            $("#tr_ctrl").hide();//管制種類
            $("#sdate").val(Today().addYears(-6).format("yyyy/M/1"));
            $("#edate").val(CDate($("#sdate").val()).addMonths(2).addDays(-1).format("yyyy/M/d"));
            $("#sdate1").val(Today().addYears(-3).format("yyyy/M/1"));
            $("#edate1").val(CDate($("#sdate1").val()).addMonths(2).addDays(-1).format("yyyy/M/d"));
            $("#SetOrder").val("a.scode,ap_cname,a.term1");
        } else if (pvalue == "5") {//追蹤期限稽催查詢 
            $("#span_date").html("管制期限：");
            $("#span_chkdate").show();//管制期限:不指定
            $("#span_sedate").hide();//專用期限迄日
            $("#tr_ctrl").hide();//管制種類
            $("#sdate").val("1980/1/1");
            $("#edate").val(Today().addDays(5).format("yyyy/M/d"));
            $("#SetOrder").val("scode1,ctrl_date");
        }
    });

    //管制種類
    $("input[name='ctrl_type']").click(function (e) {
        $("#ctrl_typenm").val($(this).parent('label').text());
    });

    //[列印]
    $("#btnSrch").click(function (e) {
        var qtype = $("input[name='qtype']:checked").val();

        var url = "brta64_list2.aspx";
        if (qtype=="1") {//管制期限稽催查詢
            url = "brta64_list1.aspx";
        } else if (qtype=="5") {//追蹤期限稽催查詢
            url = "brta64_list3.aspx";
        }

        var lchkflg = true;//要輸入日期
        if (qtype == "1" || qtype == "5") {
            if ($("#chkdate").prop("checked")) {
                lchkflg = false;
            }
        }
        if (lchkflg) {
            if ($("#sdate").val() == "") {
                alert("起始日必須輸入!!!");
                $("#sdate").focus();
                return false;
            }
            if ($("#edate").val() == "") {
                alert("終止日必須輸入!!!");
                $("#edate").focus();
                return false;
            }
        }

        if (qtype == "4") {//使用稽催查詢
            if ($("#sdate1").val() != "" || $("#edate1").val() != "") {
                if ($("#sdate1").val() == "" || $("#edate1").val() == "") {
                    alert("起始與終止日必須同時輸入!!!");
                    $("#sdate1").focus();
                    return false;
                }
            }
        }

        reg.action = url;
        reg.submit();
    });
</script>
