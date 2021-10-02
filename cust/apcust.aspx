<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Web" %>
<%@ Import Namespace = "System.Web.UI" %>
<%@ Import Namespace = "System.Web.UI.WebControls" %>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>

<!DOCTYPE html>

<script runat="server">
    protected string HTProgCap = "";//HttpContext.Current.Request["prgname"];//功能名稱
    //protected string HTProgPrefix = "cust13";//HttpContext.Current.Request["prgid"] ?? "";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";
    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";
    protected string QueryName = "";
    protected string TableName = "";

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;
        TableName = Request["tablename"];
        
        if (TableName == "apcust") { HTProgCap = "申請人查詢"; QueryName = "申請人"; }
        else { HTProgCap = "客戶查詢"; QueryName = "客戶"; }
        
        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        DebugStr = myToken.DebugStr;
        if (HTProgRight >= 0)
        {
            PageLayout();
            this.DataBind();
        }
    }

    private void PageLayout() {
        if ((HTProgRight & 2) > 0) {
            StrFormBtnTop += "<a class=\"imgCls\" href=\"javascript:void(0);\" >[關閉視窗]</a>\n";
            
            StrFormBtn += "<input type=\"button\" id=\"btnSrch\" value=\"查　詢\" class=\"cbutton bsubmit\" />\n";
            StrFormBtn += "<input type=\"button\" id=\"btnRest\" value=\"重　填\" class=\"cbutton\" />\n";
        }
    }
    
</script>

<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title><%#HTProgCap%></title>
    <meta http-equiv="x-ua-compatible" content="IE=10">
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
<TABLE border="0" class="bluetable" cellspacing="1" cellpadding="2" width="40%">	
	<tr>
		<TD class="lightbluetable" align="right"><%=QueryName%>編號：</TD>
		<TD class="whitetablebg" align="left">
            <%if (TableName == "apcust")
              {
                 Response.Write("<INPUT type=\"text\" id=\"apcust_no\" name=\"apcust_no\" size=\"11\" maxlength=\"10\">");
              }
              else
              {
                  Response.Write(Sys.GetSession("seBranch") + " － ");
			      Response.Write("<INPUT type=\"text\" name=\"cust_seq\" id=\"cust_seq\" size=\"11\" maxlength=\"6\">");
              }
            %>
		</TD>
	</tr>
	<TR>
		<TD class="lightbluetable" align="right"><%=QueryName%>名稱(中)：</TD>
		<TD class="whitetablebg" align="left">
			<INPUT type="text" name="ap_cname" id="ap_cname" size="33" maxlength="30">
		</TD>
	</TR>
	<TR>
		<TD class="lightbluetable" align="right"><%=QueryName%>名稱(英)：</TD>
		<TD class="whitetablebg" align="left">
			<INPUT type="text" name="ap_ename" id="ap_ename" size="33" maxlength="30">
		</TD>
	</TR>			
</TABLE>

</center>
</form>
<table border="0" width="100%" cellspacing="0" cellpadding="0">
	<tr>
        <td width="100%">     
		<p align="center">
        <%# StrFormBtn%> 
	    </td>
	</tr>
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

    function ChkSrch() {
        var s = <%="'"+TableName+"'"%>;
        var id = "";
        if (s == "apcust") {
            id = $("#apcust_no").val();
        }
        else {
            id = $("#cust_seq").val();
        }
        if ($.trim(id) == "" && $.trim($("#ap_cname").val()) == "" && $.trim($("#ap_ename").val()) == "") {
            alert("編號或名稱需輸入其一!");
            return false;
        }

    }

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
        if (ChkSrch() == false) {
            return;
        }
        
        reg.action = "apcust_List.aspx?tablename=<%=TableName%>";
        reg.submit()

    });

</script>
