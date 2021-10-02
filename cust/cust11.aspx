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
    protected string HTProgCap = "客戶資料新增";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "cust11";//HttpContext.Current.Request["prgid"] ?? "";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";
    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";
    protected string SQL = "";
    protected string submitTask = "";
    protected string cust_area = "";

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
        cust_area = Sys.GetSession("seBranch");

        if ((HttpContext.Current.Request["prgid"] ?? "") == "")
        {
            HTProgCode = "cust11"; prgid = "cust11";
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
            StrFormBtnTop += "<a href=javascript:gotoSearch()>[客戶查詢]</a>";
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

<center><table border="0" class="bluetable" cellspacing="1" cellpadding="3" width="40%">	
	<tr>
		<td class="lightbluetable" align="right" nowrap>客戶名稱：</td>
		<td class="whitetablebg" align="left">
		<input type="Text" name="ap_name" id="ap_name" size="30" maxlength="30" value=""><br />
		</td>
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
1.請輸入客戶名稱前5個中文關鍵字(最多5個中文字)，且至少輸入二個中文字<br />
2.確定執行後，系統檢查關鍵字;當無符合資料，則進入客戶資料登錄畫面 
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
    }

    //[重填]
    $("#btnRest").click(function (e) {
        reg.reset();
        this_init();
    });

    //[查詢]
    $("#btnSrch").click(function (e) {

        if ($.trim($("#ap_name").val()) == "") {
            alert("客戶名稱需輸入!");
            return false;
        }

        if ($("#ap_name").val() != "") {
            if (fDataLenX($("#ap_name").val(), 0, "") < 4) {
                alert("「申請人名稱(中)」至少輸入二個中文字!");
                return false;
            }
        }
        LoadData();
    });

    function LoadData() {
        var SQLStr = "select * from custz a left join apcust b ON a.cust_seq = b.cust_seq where a.cust_seq <> '' ";
        if (reg.ap_name.value != "") {
            SQLStr += " AND (b.ap_cname1 LIKE '%" + $.trim($("#ap_name").val()) + "%' OR b.ap_cname2 LIKE '%" + $.trim($("#ap_name").val()) + "%' ";
            SQLStr += " OR b.ap_ename1 LIKE '%" + $.trim($("#ap_name").val()) + "%' OR b.ap_ename2 LIKE '%" + $.trim($("#ap_name").val()) + "%')"
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
                    window.open("cust11_Edit.aspx?prgid=cust11&submitTask=A&cust_area=<%=cust_area%>&ap_cname1=" + $.trim($("#ap_name").val()), "Eblank");
                    //window.open("cust11_Edit.aspx?prgid=cust11&submitTask=A&cust_area=N&ap_cname1=" + $.trim($("#ap_cname").val()), "Etop");
                    window.parent.tt.rows = "100%,0%";
                }
                else {
                    window.location.href = "cust11_List.aspx?prgid=cust11&submitTask=<%=submitTask%>&cust_area=<%=cust_area%>&ap_name=" + $.trim($("#ap_name").val());
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


    function gotoSearch() {
        reg.action = "cust11_1.aspx?cust_area=<%=cust_area%>&submitTask=U";
        reg.submit();
    }



</script>
