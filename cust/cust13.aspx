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
    protected string HTProgCap = "申請人資料新增";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "cust13";//HttpContext.Current.Request["prgid"] ?? "";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";
    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";
    protected string SQL = "";
    protected string no = "";//序號，cust22_apcustList用
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

        if ((Request["no"] ?? "") != "") no = Request["no"];
        if ((HttpContext.Current.Request["prgid"] ?? "") == "")
        {
            HTProgCode = "cust13"; prgid = "cust13";
        }
        
        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        //HTProgCap = myToken.Title;
        DebugStr = myToken.DebugStr;
        if (HTProgRight >= 0) {
            PageLayout();
            this.DataBind();
        }
        //string str_json = JsonConvert.SerializeObject(page, Formatting.Indented);
        //    Response.Write(str_json);
        //    Response.End();
    }

    private void PageLayout() {
        if ((HTProgRight & 2) > 0) {
            StrFormBtn += "<input type=\"button\" id=\"btnSrch\" value=\"查　詢\" class=\"cbutton bsubmit\" />\n";
            StrFormBtn += "<input type=\"button\" id=\"btnRest\" value=\"重　填\" class=\"cbutton\" />\n";
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
        <td class="text9" nowrap="nowrap">&nbsp;【cust13 <%#HTProgCap%>】</td>
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
<input type=hidden name="no" id="no" value="<%=no%>">
<center><table border="0" class="bluetable" cellspacing="1" cellpadding="2" width="50%">	
	<tr>
		<td class="lightbluetable" align="right" nowrap>申請人編號：</td>
		<td class="whitetablebg" align="left">
		<input type="Text" name="apcust_no" id="apcust_no" size="12" maxlength="10"></td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right">申請人名稱：</td>
		<td class="whitetablebg" align="left" colspan="3">
		<input type="Text" name="ap_cname" id="ap_cname" size="40" maxlength="40" value=""></td>
	</tr>
</table></center>
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
<div align="left">
    <font size=2 color=blue>
[說明]<br>
1.請輸入申請人編號或申請人名稱關鍵字<br>
2.確定執行後，系統檢查申請人編號或關鍵字，當無符合資料，則進入申請人資料登錄畫面
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

    function ChkSrch() {
        if (reg.apcust_no.value == "" && reg.ap_cname.value == "") {
            alert("申請人編號或申請人名稱需輸入其一!");
            return true;
        }
    }

    function this_init() {
        if (window.parent.tt !== undefined) {
            window.parent.tt.rows = "100%,0%";
        }
        $("input.dateField").datepick();
        //$("#cust_area").val("<%=Session["seBranch"]%>");
    }

    //After Save NewData goto List
    function AddDone(apcust_no) {
        reg.action = "cust13_List.aspx?prgid=cust13&submitTask=U&apcust_no=" + apcust_no;
        reg.submit();
    }


    //[重填]
    $("#btnRest").click(function (e) {
        reg.reset();
        this_init();
    });

    //////////////////////////////////////////////////////
    //$("#seq").blur(function (e) {
    //    chkNum1($(this),"本所編號");
    //});
    //$("#cust_seq").blur(function (e) {
    //    chkNum1($(this), "客戶編號");
    //});
    $(".dateField").blur(function (e) {
        ChkDate(this);
    });

    //[查詢]
    $("#btnSrch").click(function (e) {
        ChkSrch();

        if ('<%=prgid%>' == "cust22") {
            reg.action = "cust22_apcustList.aspx?prgid=cust22";
            reg.submit();
        }
        else {
            LoadData();
        }
    });

    function LoadData() {
        var SQLStr = "select * from apcust where apsqlno <> '' ";
        if (reg.apcust_no.value != "")
        {
            SQLStr += " and apcust_no LIKE '%" + $("#apcust_no").val() + "%'";
        }
        if (reg.ap_cname.value != "")
        {
            SQLStr += " and ap_cname1 LIKE '%" + $("#ap_cname").val() + "%'";
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
                    window.open("cust13_Edit.aspx?prgid=cust13&submitTask=A&apcust_no=" + $("#apcust_no").val() + "&ap_cname1=" + $("#ap_cname").val(), "Eblank");
                    window.parent.tt.rows = "0%,100%";
                }
                else {
                    window.location.href = "cust13_List.aspx?prgid=cust13&submitTask=U&apcust_no=" + $("#apcust_no").val() + "&ap_cname=" + $("#ap_cname").val();
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
