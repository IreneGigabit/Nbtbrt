<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data" %>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<script runat="server">
    protected string HTProgCap = "案件交辦單列印";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "brt16";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";
    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";
    protected string SQL = "";

    protected string td_tscode = "";
    protected string pfx_Arcase = "";

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
            //案性
            SQL = "SELECT RS_code, RS_detail FROM code_br WHERE dept = 'T' AND cr = 'Y' AND no_code='N' ";
            SQL += "and (end_date is null or end_date = '' or end_date > getdate()) ";
            SQL += " ORDER BY rs_type desc,rs_class ,rs_code";
            pfx_Arcase = Util.Option(conn, SQL, "{rs_code}", "{rs_code}--{rs_detail}");

            //洽案營洽清單
            DataTable dt = new DataTable();
            if ((HTProgRight & 64) != 0) {
                SQL = "select scode,sc_name from sysctrl.dbo.vscode_type where branch='" + Session["seBranch"] + "' and grpid like '" + Session["Dept"] + "%' and work_type='sales' order by scode";
                conn.DataTable(SQL, dt);
                td_tscode = "<select id='tfx_in_Scode' name='tfx_in_Scode'><option value='' style='color:blue'>全部</option>" + dt.Option("{scode}", "{scode}_{sc_name}",false,Sys.GetSession("scode")) + "</select>";
            } else {
                td_tscode = "<input type='text' id='tfx_in_Scode' name='tfx_in_Scode' readonly class='SEdit' value='" + Session["se_scode"] + "'>";
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

    <div id="id-div-slide">
        <table id="qryForm" border="0" class="bluetable" cellspacing="1" cellpadding="2" width="70%" align="center">	
			<TR>
				<td class="lightbluetable" align="right">承辦案性 :</td>
				<td class="whitetablebg" align="left">
                    <select id="pfx_Arcase" name="pfx_Arcase"><%#pfx_Arcase%></select>
				</td> 
			</TR>
			<TR>
				<td class="lightbluetable" align="right">營洽人員 :</td>
		        <TD class=whitetablebg align=left><%#td_tscode%></TD>
            </TR>
	        <tr>
		        <td class="lightbluetable" align="right">序號選擇 :</td>
		        <td class="whitetablebg" align="left">
			        <label><input type="radio" name="new" value="in_no" checked onclick="$('#span_date').html('洽案')">接洽序號</label>
 			        <label><input type="radio" name="new" value="case_no" onclick="$('#span_date').html('交辦')">交辦序號</label>
 		        </td>
	        </tr>
	        <tr>
		        <td class="lightbluetable" align="right">序號範圍 :</td>
		        <td class="whitetablebg" align="left" colspan="3">
                    <input type="text" id="sin_no" name="sin_no" size="12" maxlength="12">～<input type="text" id="ein_no" name="ein_no" size="12" maxlength="12">
		            <input type="hidden" id="sfx_in_no" name="sfx_in_no" size="12" maxlength="12">
		            <input type="hidden" id="efx_in_no" name="efx_in_no" size="12" maxlength="12">
		            <input type="hidden" id="sfx_case_no" name="sfx_case_no" size="12" maxlength="12">
		            <input type="hidden" id="efx_case_no" name="efx_case_no" size="12" maxlength="12">
		        </td>
	        </tr>
	        <tr>
		        <td class="lightbluetable" align="right"><span id="span_date">接洽</span>日期 :</td>
		        <td class="whitetablebg" align="left" colspan="3">
		        <input type="text" id="sin_date" name="sin_date" size="10" class="dateField">～
		        <input type="text" id="ein_date" name="ein_date" size="10" class="dateField">
		        <input type="hidden" id="sfx_in_date" name="sfx_in_date" size="10">
		        <input type="hidden" id="efx_in_date" name="efx_in_date" size="10">
		        <input type="hidden" id="sfx_case_date" name="sfx_case_date" size="10">
		        <input type="hidden" id="efx_case_date" name="efx_case_date" size="10">
		        </td>
	        </tr>
	        <tr>
		        <td class="lightbluetable" align="right">作業狀態 :</td>
		        <td class="whitetablebg" align="left" colspan=3>
		            <input type="radio" name="tfx_stat_code" value="NN">未交辦	
		            <input type="radio" name="tfx_stat_code" value="YN">已交辦
		            <input type="radio" name="tfx_stat_code" value="YY">簽准	
		            <input type="radio" name="tfx_stat_code" value="NX">不准
		            <input type="radio" name="tfx_stat_code" value="YZ">程序確認
		            <input type="radio" name="tfx_stat_code" value="" checked>不指定
		        </td>
	        </tr>
        </table>
        <br>
        <table id="tabBtn" border="0" width="100%" cellspacing="0" cellpadding="0" align="center">
	        <tr><td width="100%" align="center">
			    <%#StrFormBtn%>
	        </td></tr>
        </table>
    </div>
    <%#DebugStr%>
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
        $("#sin_date").val((new Date()).format("yyyy/M/1"));
        $("#ein_date").val(Today().format("yyyy/M/d"));
        $("input.dateField").datepick();
    }

    //[查詢]
    $("#btnSrch").click(function (e) {
        if ($("#pfx_Arcase").val() == "") {
            alert("承辦案性不得為空白!");
            $("#pfx_Arcase").focus();
            return false;
        }

        if ($("#sin_no").val() != "" && !IsNumeric($("#sin_no").val())) {
            alert("序號範圍(起)錯誤,請重新輸入!!");
            $("#sin_no").focus();
            return false;
        }

        if ($("#ein_no").val()!=""&&!IsNumeric($("#ein_no").val())) {
            alert("序號範圍(迄)錯誤,請重新輸入!!");
            $("#ein_no").focus();
            return false;
        }
		
        if ($("#sin_no").val()!=""&&$("#ein_no").val()!="") {
            if(CInt($("#sin_no").val())>CInt($("#ein_no").val())){
                alert("序號範圍(起),不得大於序號範圍(迄)!!");
                return false;
            }
        }
		
        $("#sfx_in_no,#efx_in_no,#sfx_case_no,#efx_case_no,#sfx_in_date,#efx_in_date,#sfx_case_date,#efx_case_date").val("");
        if($("input[name='new']:eq(0)").prop("checked")==true){
            $("#sfx_in_no").val($("#sin_no").val());
            $("#efx_in_no").val($("#ein_no").val());
            $("#sfx_in_date").val($("#sin_date").val());
            $("#efx_in_date").val($("#ein_date").val());
        }else{
            $("#sfx_case_no").val($("#sin_no").val());
            $("#efx_case_no").val($("#ein_no").val());
            $("#sfx_case_date").val($("#sin_date").val());
            $("#efx_case_date").val($("#ein_date").val());
        }

        $("#dataList>thead tr .setOdr span").remove();
        $("#SetOrder").val("");

        reg.action = "<%=HTProgPrefix%>_List.aspx";
        reg.submit();
    });

    //[重填]
    $("#btnRest").click(function (e) {
        reg.reset();
        this_init();
    });

    $("#Sfx_in_date,#Efx_in_date").blur(function (e) {
        ChkDate(this);
    });
</script>
