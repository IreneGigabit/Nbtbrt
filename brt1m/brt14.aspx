<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data" %>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<script runat="server">
    protected string HTProgCap = "承辦申請書列印";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "brt14";//HttpContext.Current.Request["prgid"] ?? "";//程式檔名前綴
    protected string HTProgCode = "brt14";//HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";
    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";
    protected string SQL = "";

    protected string homelist = "";
    protected string td_tscode = "";
    protected string html_arcase = "";

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

        homelist = (Request["homelist"] ?? "").ToLower();
     
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
        //StrFormBtnTop += "<a class=\"imgRefresh\" href=\"javascript:void(0);\" >[重新整理]</a>\n";
        //StrFormBtnTop += "<a class=\"imgQry\" href=\"javascript:void(0);\" >[查詢條件]</a>\n";
        if ((HTProgRight & 2) > 0) {
            StrFormBtn += "<input type=\"button\" id=\"btnSrch\" value=\"查　詢\" class=\"cbutton bsubmit\" />\n";
            StrFormBtn += "<input type=\"button\" id=\"btnRest\" value=\"重　填\" class=\"cbutton\" />\n";
        }

        //承辦案性
        DataTable dtCodeBr = Sys.getCodeBr("", "", "").Select("prt_code is not null", "rs_class,RS_code").CopyToDataTable();
        html_arcase = dtCodeBr.Option("{RS_code}", "{RS_code}--{RS_detail}");

        //營洽清單
        DataTable dtscode = new DataTable();
        SQL = "select scode,sc_name from vscode_type where branch='" + Session["seBranch"] + "' and grpid like '" + Session["Dept"] + "%' and work_type='sales' order by scode";
        cnn.DataTable(SQL, dtscode);
        if ((HTProgRight & 64) != 0) {
            td_tscode = "<select id='Scode' name='Scode'>";
            td_tscode += dtscode.Option("{scode}", "{scode}_{sc_name}",true, Sys.GetSession("scode"));
            td_tscode += "</select>";
        } else {
            td_tscode = "<input type='hidden' id='Scode' name='Scode' value='" + Session["scode"] + "'>";
            td_tscode += "<input type='text' id='ScodeName' name='ScodeName' readonly class='SEdit' value='" + Session["sc_name"] + "'>";
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
    <input type="hidden" id="homelist" name="homelist" value="<%=homelist%>">
    <input type="hidden" id="prgid" name="prgid" value="<%=prgid%>">
    <input type="hidden" id=tfx_in_scode name=tfx_in_scode>

    <div id="id-div-slide">
        <table id="qryForm" border="0" class="bluetable" cellspacing="1" cellpadding="2" width="90%" align="center">	
	        <tr>
		        <td class="lightbluetable" align="right">承辦案性 :</td>
		        <td class="whitetablebg" align="left">
                    <select name="tfx_Arcase" id="tfx_Arcase"><%#html_arcase%></select>
		        </td> 
	        </tr>
            <TR>
                <td class="lightbluetable" align="right">營　　洽 :</td>
		        <td class="whitetablebg" align="left"><%#td_tscode%>
            </TR>
 	        <tr>
		        <td class="lightbluetable" align="right">列印選擇 :</td>
		        <td class="whitetablebg" align="left">
                    <label><input type="radio" name="tfx_new" value="N" checked>尚未列印</label>
					<label><input type="radio" name="tfx_new" value="">不設定</label>
		        </td>
	        </tr>
	        <tr>
		        <td class="lightbluetable" align="right">序號選擇 :</td>
		        <td class="whitetablebg" align="left">
			        <label><input type="radio" name="new" value="in_no" checked>接洽序號</label>
 			        <label><input type="radio" name="new" value="seq_no">本所編號</label>
 		        </td>
	        </tr>
	        <tr id=sin_no1 style="display:none">
		        <td class="lightbluetable" align="right">接洽序號 :</td>
		        <td class="whitetablebg" align="left" colspan="3">
                    <input type="text" id="sfx_in_no" name="sfx_in_no" size="12" maxlength="12">～
                    <input type="text" id="efx_in_no" name="efx_in_no" size="12" maxlength="12">
		        </td>
	        </tr>
	        <tr id=sin_no2 style="display:none">
		        <td class="lightbluetable" align="right">本所編號 :</td>
		        <td class="whitetablebg" align="left" colspan="3">
                    <input type="text" id="tfx_seq" name="tfx_seq" size="6" maxlength="<%=Sys.DmtSeq%>">-<input type="text" id="tfx_seq1" name="tfx_seq1" size="2" maxlength="<%=Sys.DmtSeq1%>">
		        </td>
	        </tr>
	        <tr>
		        <td class="lightbluetable" align="right">接洽日期 :</td>
		        <td class="whitetablebg" align="left" colspan="3">
		            <input type="text" id="sfx_in_date" name="sfx_in_date" size="10" class="dateField">～
		            <input type="text" id="efx_in_date" name="efx_in_date" size="10" class="dateField">
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

        $("#sfx_in_date").val("<%#DateTime.Today.ToString("yyyy/M/1")%>");
        $("#efx_in_date").val("<%#DateTime.Today.ToShortDateString()%>");
        $("#tfx_seq1").val("");
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
        if ($(this).val() == "in_no") {
            $("#tfx_seq1").val("");
            $("#sin_no1").show();
        } else if ($(this).val() == "seq_no") {
            $("#tfx_seq1").val("_");
            $("#sin_no2").show();
        }
    });

    //[查詢]
    $("#btnSrch").click(function (e) {
        if ($("input[name='new']:checked").val() == "seq_no") {
            if ($("#tfx_seq").val() == "") {
                alert("請輸入本所編號!!!");
                $("#tfx_seq").focus();
                return false;
            }
        }

        if ($("#sfx_in_no").val() != "") {
            if (!IsNumeric($("#sfx_in_no").val())) {
                alert("接洽序號(起)錯誤,請重新輸入!!");
                $("#sfx_in_no").focus();
                return false;
            }
        }

        if ($("#efx_in_no").val() != "") {
            if (!IsNumeric($("#efx_in_no").val())) {
                alert("接洽序號(迄)錯誤,請重新輸入!!");
                $("#efx_in_no").focus();
                return false;
            }
        }

        if ($("#sfx_in_no").val() != "" && $("#efx_in_no").val() != "") {
            if (CInt($("#sfx_in_no").val()) > CInt($("#efx_in_no").val())) {
                alert("接洽序號(起),不得太於接洽序號(迄)");
                return false;
            }
        }

        $("#tfx_in_scode").val($("#Scode").val());

        reg.action = "<%=HTProgPrefix%>_List.aspx";
        reg.submit();
    });
</script>
