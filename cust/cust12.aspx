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
    protected string HTProgCap = "聯絡人資料新增";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "cust12";//HttpContext.Current.Request["prgid"] ?? "";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";
    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";
    protected string SQL = "";
    protected string submitTask = "";
    protected string Auth = "";
    

    protected string td_tscode = "", html_apclass = "", html_country = "";

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

        if ((HttpContext.Current.Request["prgid"] ?? "") == "")
        {
            HTProgCode = "cust12"; prgid = "cust12";
        }
        
        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        //HTProgCap = myToken.Title;
        DebugStr = myToken.DebugStr;
        if (HTProgRight >= 0) {

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
            StrFormBtnTop += "<a href=javascript:gotoSearch()>[聯絡人查詢]</a>";
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

<center><table border="0" class="bluetable" cellspacing="1" cellpadding="3" width="50%">	
    <tr>
		<td class="lightbluetable" align="right" nowrap>客戶編號：</td>
		<td class="whitetablebg" align="left">
		N - <input type="Text" name="cust_seq" id="cust_seq" size="10" maxlength="5" onkeyup="value=value.replace(/[^\d]/g,'') "></td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right" nowrap>客戶名稱(中)：</td>
		<td class="whitetablebg" align="left">
		<input type="Text" name="ap_cname" id="ap_cname" size="40" maxlength="40" value=""><br />
		</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right">客戶名稱(英)：</td>
		<td class="whitetablebg" align="left" colspan="3">
		<input type="Text" name="ap_ename" id="ap_ename" size="40" maxlength="40" ></td>
	</tr>
</table></center>
</form>
<table border="0" width="100%" cellspacing="0" cellpadding="0">
	<tr><td width="100%">     
		<p align="center">
		<input type="button" value="查詢" class="cbutton" style="cursor:hand" id="btnSrch" name="btnSrch">
		<input type="button" value="重填" class="cbutton" style="cursor:hand" id="btnRest" name="btnRest">
	</td></tr>
</table>
<br>
<div align="left">
    <font size=2 color=blue>
[說明]<br>
1.請輸入客戶編號或客戶名稱關鍵字，以便登錄該客戶之聯絡人資料
</font>
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
        //$("#cust_area").val("<%=Session["seBranch"]%>");
    }

    //[重填]
    $("#btnRest").click(function (e) {
        reg.reset();
        this_init();
    });

    //[查詢]
    $("#btnSrch").click(function (e) {

        if ($("#cust_seq").val() == "" && $("#ap_cname").val() == "" && $("#ap_ename").val() == "") {
            alert("客戶名稱或客戶編號需輸入其一!");
            return false;
        }

        if ($("#ap_cname").val() != "") {
            if (fDataLenX($("#ap_cname").val(), 0, "") < 4) {
                alert("「申請人名稱(中)」至少輸入二個中文字!");
                return false;
            }
        }

        var SQLStr = "SELECT cust_seq, ap_cname1, ap_ename1 FROM apcust WHERE cust_seq is not null ";
        if ($("#cust_seq").val() != "") {
            SQLStr += " AND cust_seq LIKE '%" + $("#cust_seq").val() + "%'";
        }
        if ($("#ap_cname").val() != "") {
            SQLStr += " AND ap_cname1 LIKE '%" + $("#ap_cname").val() + "%'";
        }
        if ($("#ap_ename").val() != "") {
            SQLStr += " AND ap_ename1 LIKE '%" + $("#ap_ename").val() + "%'";
        }
        $.ajax({
            url: "../AJAX/JsonGetSqlData.aspx",
            type: "get",
            async: false,
            cache: false,
            data: { sql: SQLStr },
            success: function (json) {
                var JSONdata = $.parseJSON(json);
                if (JSONdata.length == 0) {
                    alert("查無資料!");
                    return;
                }
                else {
                    reg.action = "cust12_List.aspx?cust_area=<%=Sys.GetSession("seBranch")%>&submitTask=<%=submitTask%>";
                    reg.submit();
                }
            },
            beforeSend: function (jqXHR, settings) {
                jqXHR.url = settings.url;
            },
            error: function (jqXHR, textStatus, errorThrown) {
                alert("\n資料擷取剖析錯誤 !\n" + jqXHR.url);
            }
        });
        //reg.action = "cust12_List.aspx?cust_area=<%=Sys.GetSession("seBranch")%>&submitTask=<%=submitTask%>";
        //reg.submit();
    });

    function gotoSearch() {
        reg.action = "cust12_1.aspx?cust_area=<%=Sys.GetSession("seBranch")%>&submitTask=U";
        reg.submit();

    }



</script>
