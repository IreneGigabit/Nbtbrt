<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Web" %>
<%@ Import Namespace = "System.Web.UI" %>
<%@ Import Namespace = "System.Web.UI.WebControls" %>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>
<%@ Register Src="~/cust/impForm/custForm.ascx" TagPrefix="uc1" TagName="custForm" %>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<script runat="server">
    protected string HTProgCap = "客戶契約書管理";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "cust21";//HttpContext.Current.Request["prgid"] ?? "";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";
    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";
    protected string SQL = "";
    protected string dept = "";
    //protected string branch = "";

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

        dept = Sys.GetSession("dept");
        //branch = Sys.GetSession("seBranch");
        
        
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
        <td class="text9" nowrap="nowrap">&nbsp;【<%#prgid%> <%#HTProgCap%>-<%=(dept == "P")?"專利":"商標"%>】</td>
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
    <table border="0" width="100%" cellspacing="0" cellpadding="0">
            <tr>
                <td width="100%" id="Cont" colspan="2" height="100%" valign="top">
                    <uc1:custForm runat="server" ID="custForm" />
                </td>
            </tr>
    </table>
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
<div align="left">
    <font size=2>
[備註]<br>
權限C：權限A+B：專商全部，權限B：區所主管、專利主管，權限A：組主管 
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
        custForm.init();
    }

    //[重填]
    $("#btnRest").click(function (e) {
        reg.reset();
        this_init();
    });

    $(".dateField").blur(function (e) {
        ChkDate(this);
    });

    function skind_onclick(pi) {
        if (pi == "") {
            document.all.showinclude.style.display = "none";
            $("#includeexpired").prop("checked", false);
        }
        else
        {
            document.all.showinclude.style.display = "";
            $("#includeexpired").show();
            if (pi == "U") {
                $("#includeexpired").prop("checked", false);
            }
            else {
                $("#includeexpired").prop("checked", true);
            }
        }
    }

    //[查詢]
    $("#btnSrch").click(function (e) {

        if (NulltoEmpty($("#qrycust_seq").val()) == "" && NulltoEmpty($("#qrycontract_nos").val()) == "" && NulltoEmpty($("#qrycontract_noe").val()) == "" 
            && NulltoEmpty($("#qrycontract_sdate").val()) == "" && NulltoEmpty($("#qrycontract_edate").val()) == "" && NulltoEmpty($("#qryuse_date").val()) == ""
            && NulltoEmpty($("#qryid_no").val()) == "" && NulltoEmpty($("#qryap_cname").val()) == "" && NulltoEmpty($("#qryap_ename").val()) == ""
            && NulltoEmpty($("#qryscode").val()) == "") {
            alert("請輸入「客戶編號」、「接洽人員」、「契約書號碼」、「簽約期間」及「到期日期」任一條件");
            return false;
        }

        if ($("#qryuse_date").val() != "" && $.isDate($("#qryuse_date").val()) == false) {
            alert("簽約期間起始資料必須為日期型態!!");
            return false;
        }
        if ($("#qrycontract_sdate").val() != "" && $.isDate($("#qrycontract_sdate").val()) == false) {
            alert("簽約期間起始資料必須為日期型態!!");
            return false;
        }
        if ($("#qrycontract_edate").val() != "" && $.isDate($("#qrycontract_edate").val()) == false) {
            alert("簽約期間終止資料必須為日期型態!!");
            return false;
        }
        if (chkSEDate($("#qrycontract_sdate").val(), $("#qrycontract_edate").val(), "日期範圍") == false) {
            return false;
        }

        if ($("#qryap_cname").val() != "") {
            if (fDataLenX($("#qryap_cname").val(), 0, "") < 4) {
                alert("「客戶名稱(中)」至少輸入2個中文字!");
                return false;
            }
        }
        if ($("#qryap_ename").val() != "") {
            if (fDataLenX($("#qryap_ename").val(), 0, "") < 4) {
                alert("「客戶名稱(英)」至少輸入4個英文字!");
                return false;
            }
        }


        reg.action = "cust21_List.aspx?prgid=<%=prgid%>";
        reg.submit();


    });


</script>
