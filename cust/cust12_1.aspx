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
    protected string HTProgCap = "聯絡人資料";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "cust12_1";//HttpContext.Current.Request["prgid"] ?? "";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";
    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";
    protected string SQL = "";
    protected string submitTask = "";
    protected string html_CustScode = "";
    protected string Auth = "";
    
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

        submitTask = Request["submitTask"];
        if (submitTask == "A") HTProgCap = HTProgCap + "-<font color=blue>新增</font>";
        if (submitTask == "U") HTProgCap = HTProgCap + "-<font color=blue>維護</font>";
        if (submitTask == "Q") HTProgCap = HTProgCap + "-<font color=blue>查詢</font>";
        
        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        HTProgCap = myToken.Title;
        DebugStr = myToken.DebugStr;
        if (HTProgRight >= 0) {

            //營洽選單
            if (Sys.GetSession("dept") == "P")
            {
                html_CustScode = Sys.getCustScode("Q", Sys.GetSession("dept"), HTProgRight, "").Option("{pscode}", "{pscode}_{sc_name}");
            }
            else
            {
                html_CustScode = Sys.getCustScode("Q", Sys.GetSession("dept"), HTProgRight, "").Option("{tscode}", "{tscode}_{sc_name}");
            }
            
            
            
            
            Auth = (Sys.GetSession("dept") == "P") ? "P" : "T";
            //權限All：專商全部
            if (HTProgRight >= 64) Auth = "All";
            
            
            PageLayout();
            this.DataBind();
        }
    }

    private void PageLayout()
    {
        if ((HTProgRight & 2) > 0)
        {
            StrFormBtnTop += "<a href=http://web02/BRP/cust/客戶系統操作手冊.htm target=_blank>[補助說明]</a>";
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

<form name="reg" method="post" id="formData" action>
<input type=hidden name=prgid value="<%=prgid%>">
<input type=hidden name=Auth id="Auth" value="<%=Auth%>">


<center>
<TABLE border=0 class=bluetable cellspacing=1 cellpadding=2 width="70%">
	<TR>
		<TD class=lightbluetable align=right>客戶編號：</TD>
		<TD class=whitetablebg align=left>
		<%--<INPUT type=text name="cust_area" id="cust_area" readonly class="sedit" size="1" value="<%=session("se_branch")%>">－--%>
        <INPUT type=text name="cust_area" id="cust_area" readonly class="sedit" size="1" value="<%=Session["sebranch"]%>">  －
		<INPUT type="text" name="cust_seq" id="cust_seq" size="7" maxlength="5" value="" class="InputNumOnly" ></TD>
		<TD class=lightbluetable align=right>營　　洽：</TD>
		<TD class=whitetablebg align=left>
		
			<%--<input type="hidden" name="pwhescode" value="<%=pwhescode%>">--%>
			<select NAME="scode" id="scode" size=1 >
                <%#html_CustScode%>
                <%--<option value="">部門(開放客戶)</option>
                <option value="all">全部</option>--%>
			</select>
		</TD>
	</TR>
	<TR>
		<TD class=lightbluetable align=right>客戶名稱(中)：</TD>
		<TD class=whitetablebg align=left colspan=3>
		<INPUT type=text name="ap_cname" id="ap_cname" maxlength=30 size=44 ></TD>
	</TR>
	<TR>
		<TD class=lightbluetable align=right>客戶名稱(英)：</TD>
		<TD class=whitetablebg align=left colspan=3>
		<INPUT type=text name="ap_ename" id="ap_ename" maxlength=40 size=44></TD>
	</TR>
	<TR>
		<TD class=lightbluetable align=right>聯絡人：</TD>
		<TD class=whitetablebg align=left colspan=3>
		<INPUT type=text name="attention" id="attention" maxlength=12 size="22"></TD>
	</TR>
	<TR>
		<TD class=lightbluetable align=right>職　稱：</TD>
		<TD class=whitetablebg align=left>
		<INPUT type=text name="att_title" id="att_title" maxlength=20 size="22"></TD>
		<TD class=lightbluetable align=right>部門：</TD>
		<TD class=whitetablebg align=left>
		<INPUT type=text name="att_dept" id="att_dept" maxlength=20 size="20"></TD>
	</TR>
	<TR>
		<TD class=lightbluetable align=right>聯絡電話：</TD>
		<TD class=whitetablebg align=left colspan=3>
		<INPUT type=text name="att_tel0" id="att_tel0" size="4" maxlength=4 class="InputNumOnly">
		<INPUT type=text name="att_tel"  id="att_tel"size="17" maxlength=15 class="InputNumOnly">
		<INPUT type=text name="att_tel1" id="att_tel1" size="6" maxlength=5 class="InputNumOnly">
		</TD>
	</TR>
	<TR>
		<TD class=lightbluetable align=right>行動電話：</TD>
		<TD class=whitetablebg align=left>
		<INPUT type=text name="att_mobile" id="att_mobile" size="12" maxlength=10 class="InputNumOnly"></TD>
		<TD class=lightbluetable align=right>傳　真：</TD>
		<TD class=whitetablebg align=left>
		<INPUT type=text name="att_fax" id="att_fax" size="20" maxlength=15 class="InputNumOnly"></TD>
	</TR>
	<TR>
		<TD class=lightbluetable align=right>郵寄雜誌：</TD>
		<TD class=whitetablebg align=left colspan=3>
		<input type=hidden name="hatt_mag">
		<INPUT type=radio name="att_mag" value="Y">需要
		<INPUT type=radio name="att_mag" value="N">不需要
		<INPUT type=radio name="att_mag" value="" checked>不指定</TD>
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

            $("#cust_area").lock();

            var a = <%= "'" + Auth + "'"%>;
            if (a == "All") {
                $("#scode").append('<option value=np>np_部門(開放客戶)</option>');
            }

            



        }
        $("input.dateField").datepick();
    }

    //[重填]
    $("#btnRest").click(function (e) {
        reg.reset();
        this_init();
    });

    //[查詢]
    $("#btnSrch").click(function (e) {
        var val = "";
        $(':radio:checked').each(function () {
            val = $(this).val();
        })

        if ($("#cust_seq").val() == "" && $("#scode").val() == "" && $("#ap_cname").val() == "" && $("#ap_ename").val() == ""
            && $("#attention").val() == "" && $("#att_title").val() == "" && $("#att_tel0").val() == "" && $("#att_tel").val() == ""
            && $("#att_tel1").val() == "" && $("#att_mobile").val() == "" && $("#att_fax").val() == "" && $("#att_mag").val() == undefined && $("#att_dept").val() == ""
            && val == "")
        {
            alert("請輸入任一條件!");
            return false;
        }

        if ($("#ap_cname").val() != "") {
            if (fDataLenX($("#ap_cname").val(), 0, "") < 4) {
                alert("「申請人名稱(中)」至少輸入二個中文字!");
                return false;
            }
        }

        reg.action = "cust12_List.aspx?cust_area=N&submitTask=<%=submitTask%>";
        reg.submit();
    });

    
    $('.InputNumOnly').keypress(function (event) {
        if (event.which != 8 && isNaN(String.fromCharCode(event.which))) {
            event.preventDefault();
        }
    });
  

</script>
