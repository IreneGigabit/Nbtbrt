<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data" %>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<script runat="server">
    protected string HTProgCap = "國內爭救案交辦專案室抽件作業";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "brt1a";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
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
            //洽案營洽清單
            DataTable dt = new DataTable();
            if ((HTProgRight & 64) != 0) {
                SQL = "select scode,sc_name from sysctrl.dbo.vscode_type where branch='" + Session["seBranch"] + "' and grpid like '" + Session["Dept"] + "%' and work_type='sales' order by scode";
                conn.DataTable(SQL, dt);
                td_tscode = "<select id='Qryscode' name='Qryscode'><option value='*' class='xxx' style='color:blue'>全部</option>" + dt.Option("{scode}", "{scode}_{sc_name}",false,Sys.GetSession("scode")) + "</select>";
            } else {
                td_tscode = "<input type='text' id='Qryscode' name='Qryscode' readonly class='SEdit' value='" + Session["se_scode"] + "'>";
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
				<td class="lightbluetable" align="right">洽案營洽 :</td>
		        <TD class=whitetablebg align=left><%#td_tscode%></TD>
            </TR>
	        <TR>
		        <TD class=lightbluetable align=right nowrap>本所編號 :</TD>
		        <TD class=whitetablebg align=left><INPUT type=text name="Qryseq" id="Qryseq" value="" size="5"></TD>
	        </TR>	
	        <TR>
		        <TD class=lightbluetable align=right nowrap>交辦單號 :</TD>
		        <TD class=whitetablebg align=left><INPUT type=text name="Qrycase_no" id="Qrycase_no" style="width:10%"></TD>
	        </TR>
	        <tr>
		        <td class="lightbluetable" align="right" nowrap>日期種類 :</td>
		        <td class="whitetablebg" align="left">
		            <label><input type="radio" name="ChangeDate" value="in_date">接洽日期</label>
		            <label><input type="radio" name="ChangeDate" value="case_date">交辦日期</label>
		            <label><input type="radio" name="ChangeDate" value="opt_in_date">交辦專案室日期</label>
		            <label><input type="radio" name="ChangeDate" value="last_date">法定期限</label>
		            <label><input type="radio" name="ChangeDate" value="" checked>不指定</label>
		        </td>
	        </tr>
	        <tr>
		        <td class="lightbluetable" align="right" nowrap>日期範圍 :</td>
		        <td class="whitetablebg" align="left">
		            <input type="text" name="QryCustDateS" id="QryCustDateS" size="10" class="dateField">
                    ～
		            <input type="text" name="QryCustDateE" id="QryCustDateE" size="10" class="dateField">
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
        $("#QryCustDateS,#QryCustDateE").val("");
        $("input.dateField").datepick();
    }

    //////////////////////
    //[重填]
    $("#btnRest").click(function (e) {
        reg.reset();
        this_init();
    });
    
    //日期種類
    $("input[name='ChangeDate']").click(function (e) {
        if ($(this).val() == "") {
            $("#QryCustDateS,#QryCustDateE").val("");
        }else{
            $("#QryCustDateS").val("<%#DateTime.Today.ToString("yyyy/M/1")%>");
            $("#QryCustDateE").val("<%#DateTime.Today.ToString("yyyy/M/d")%>");
        }
    });

    $(".dateField").blur(function (e) {
        ChkDate(this);
    });

    //[查詢]
    $("#btnSrch").click(function (e) {
        if($("input[name='ChangeDate']:checked").val()!=""){
            if($("#QryCustDateS").val()==""&&$("#QryCustDateE").val()==""){
                alert("請輸入"+$('[name="ChangeDate"]:checked').closest('label').text()+"之日期範圍!");
                return false;
            }
        }else{
            if($("#Qryseq").val()==""&&$("#Qrycase_no").val()==""&&$("#Qryscode").val()=="*"){
                alert("洽案營洽、本所編號、交辦單號至少一個有值!");
                return false;
            }
        }

        reg.action = "<%=HTProgPrefix%>_List.aspx";
        reg.submit();
    });
</script>
