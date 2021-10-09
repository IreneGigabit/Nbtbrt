<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Web" %>
<%@ Import Namespace = "System.Web.UI" %>
<%@ Import Namespace = "System.Web.UI.WebControls" %>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<script runat="server">
    protected string HTProgCap = " 客戶標籤列印作業";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "cust531";//HttpContext.Current.Request["prgid"] ?? "";//程式檔名前綴
    protected string HTProgCode = "cust531";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";
    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";
    protected string deptName = "";
    protected string cust_area = "";
    protected string LevelList = "";
    //客戶等級
    protected string html_level = Sys.getCustCode("level", "", "sortfld").Option("{cust_code}", "{cust_code}");
    //營洽選單
    protected string html_Scode = "";

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

        deptName = (Sys.GetSession("dept") == "P") ? "專利" : "商標";
        cust_area = Sys.GetSession("seBranch");
        if (Sys.GetSession("dept") == "P")
        {
            html_Scode = Sys.getCustScode("Q", "P", 64, "").Option("{pscode}", "{pscode}_{sc_name}");
            html_Scode += "<option value='np'>np_部門(開放客戶)</option>";
        }
        else
        {
            html_Scode = Sys.getCustScode("Q", "T", 64, "").Option("{tscode}", "{tscode}_{sc_name}");
             html_Scode += "<option value='nt'>nt_部門(開放客戶)</option>";
        }
        DataTable dt = Sys.getCustCode("level", "", "sortfld");
        foreach (DataRow r in dt.Rows)
        {
            //LevelList += "<INPUT type=\"checkbox\" value="+ r["cust_code"].ToString() + " name=\"level\" onclick=\"level_onclick()\" />" + r["code_name"].ToString() + "  " ;
            LevelList += "<INPUT type=\"checkbox\" value=" + r["cust_code"].ToString() + " name=\"level\" />" + r["code_name"].ToString() + "  ";
        }
        
        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        //HTProgCap = myToken.Title;
        DebugStr = myToken.DebugStr;
        if (HTProgRight >= 0) {

            PageLayout();
            this.DataBind();
        }
    }

    private void PageLayout()
    {
        if ((HTProgRight & 2) > 0)
        {
            StrFormBtnTop += "<a href=http://web02/BRP/cust/客戶報表操作手冊.files/frame.htm target=_blank>[補助說明]</a>";
        }
    }
    
</script>

<style>
    input[type=checkbox] {
    vertical-align:middle;
    }
</style>

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

<form name="reg" method="post" id="formData" action>
<input type=hidden name=prgid value="<%=prgid%>">
<center>
<TABLE border=0 class=bluetable cellspacing=1 cellpadding=2 width="60%">	
	<TR>
		<TD class=lightbluetable align=right>郵寄雜誌：</TD>
		<TD class=whitetablebg>
		<INPUT type=radio name="magtype" value="Y" >是
		<INPUT type=radio name="magtype" value="N" >否
		<INPUT type=radio name="magtype" value="" checked >不指定
		</TD>
	</TR>
	<TR>
		<TD class=lightbluetable align=right>指定聯絡人：</TD>
		<TD class=whitetablebg>
		<INPUT type=radio name="att_type" value="" checked >不指定
		<INPUT type=radio name="att_type" value="F" >第一順位
		<INPUT type=radio name="att_type" value="L" >最後一位
		</TD>
	</TR>
	<TR>
		<TD class=lightbluetable align=right>列印部門：</TD>
		<TD class=whitetablebg>
		<Select NAME=depttype size=1>
			<option value=0>請選擇</option>
			<option value=1 >只辦<%=deptName%>客戶</option>
			<option value=2 selected><%=deptName%>所有客戶</option>
			<option value=3>商標/專利共同客戶</option>
		</SELECT>
		</TD>
	</TR>		
	<TR>
		<TD class=lightbluetable align=right>客戶編號：</TD>
		<TD class=whitetablebg>
		<INPUT type=text name="cust_area" readonly class="SEdit" size="1" value="<%=Sys.GetSession("seBranch")%>">-
		<INPUT type=text name="cust_seqs" class="InputNumOnly" size="7" maxlength="5" value="1"> ～
		<INPUT type=text name="cust_seqe" class="InputNumOnly" size="7" maxlength="5" value="99999">
		</TD>
	</TR>		
	<tr><TD class=lightbluetable align=right>營　　洽：</TD>
		<TD class=whitetablebg align=left>
				<Select NAME=scode size=1>
                    <%=html_Scode%>
				</SELECT>
		</TD>
	</tr>
	<TR><td class="lightbluetable" align="right" ><%=deptName%>客戶等級：</td>
		<TD class=whitetablebg align=left>
            <%=LevelList%>
		    <input type="checkbox" id="level_allcheck" name="level_allcheck" value="Y" onclick="level_AllCheck()">全部&nbsp;
		    <input type="hidden" name="hidLevel" value="">
		</td>
	</TR>
</TABLE>
</center>

</form>
<table border="0" width="100%" cellspacing="0" cellpadding="0">
	<tr><td width="100%">     
		<p align="center">
		<input type="button" value="查詢" class="cbutton" style="cursor:hand" id="btnSrch" name="btnSrch">
		<input type="button" value="重填" class="cbutton" style="cursor:hand" id="btnRest" name="btnRest">
	</td></tr>
</table>
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
    }

    //[重填]
    $("#btnRest").click(function (e) {
        reg.reset();
        this_init();
    });

    //[查詢]
    $("#btnSrch").click(function (e) {
        if (reg.magtype[2].checked && reg.att_type[0].checked && reg.depttype.value == 0 && reg.cust_seqs.value == "" && reg.cust_seqe.value == ""
            && reg.scode.value == "" && $('input[name=level]:checked').val() == undefined)
        {
            alert("請輸入任一條件!!!");
            return true;
        }

        reg.action = "cust531_word.aspx?prgid=<%=prgid%>";
        reg.submit();
    });

    function level_AllCheck() {
        if ($("#level_allcheck").prop("checked") == true) {
            $("input[name=level]").prop("checked", true);
        }
        else {
            $("input[name=level]").prop("checked", false);
        }
    }
     
</script>
