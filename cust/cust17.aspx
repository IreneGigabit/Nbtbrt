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
    protected string HTProgCap = "發明/創作人資料新增";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "cust171";//HttpContext.Current.Request["prgid"] ?? "";//程式檔名前綴
    //protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string HTProgCode = "cust171";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";
    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";
    protected string SQL = "";
    protected string submitTask = "";
    
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
<center><table border="0" class="bluetable" cellspacing="1" cellpadding="3" width="50%">	
	<tr>
		<td class="lightbluetable" align="right" nowrap>發明/創作人ID：</td>
		<td class="whitetablebg" align="left">
		<input type="Text" name="ant_id" id="ant_id" size="12" maxlength="10" value=""><br />
		</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right">發明/創作人名稱：</td>
		<td class="whitetablebg" align="left" colspan="3">
		<input type="Text" name="ant_name" id="ant_name" size="33" maxlength="30" ></td>
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
1.請輸入發明/創作人編號或發明/創作人名稱關鍵字<br />
2.確定執行後，系統檢查發明/創作人編號或關鍵字，當無符合資料，則進入發明/創作人資料登錄畫面 
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
    }

    //[重填]
    $("#btnRest").click(function (e) {
        reg.reset();
        this_init();
    });

    //[查詢]
    $("#btnSrch").click(function (e) {

        if ($("#ant_id").val() == "" && $("#ant_name").val() == "") {
            alert("ID或名稱需輸入其一!");
            return false;
        }

        if ($("#ant_name").val() != "") {
            if (fDataLenX($("#ant_name").val(), 0, "") < 2) {
                alert("「發明/創作人名稱」至少輸入一個中文字!");
                return false;
            }
        }

        LoadData();

    });

    function LoadData() {
        var SQLStr = "select * from inventor where antsqlno <> '' ";
        if (reg.ant_id.value != "") {
            SQLStr += " AND ant_id = '" + $.trim($("#ant_id").val()) + "'";
        }
        if (reg.ant_name.value != "") {
            SQLStr += " AND (ant_cname1 LIKE '%" + $.trim($("#ant_name").val()) + "%' OR ant_cname2 LIKE '%" + $.trim($("#ant_name").val()) + "%'" +
                   " OR ant_ename1 LIKE '%" + $.trim($("#ant_name").val()) + "%' OR ant_ename2 LIKE '%" + $.trim($("#ant_name").val()) + "%')";
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
                    window.open("cust17_Edit.aspx?prgid=cust171&submitTask=A&ant_id=" + $.trim($("#ant_id").val()) + "&ant_name=" + $.trim($("#ant_name").val()) , "Eblank");
                }
                else {
                    reg.action = "cust17_List.aspx?prgid=cust172&submitTask=A";
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
    }


</script>
