<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Web" %>
<%@ Import Namespace = "System.Web.UI" %>
<%@ Import Namespace = "System.Web.UI.WebControls" %>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>
<%@ Register Src="~/cust/impForm/cust14QueryForm.ascx" TagPrefix="uc1" TagName="cust14queryform" %>


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<script runat="server">
    protected string HTProgCap = "更正客戶申請人作業-查詢";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "cust14";//HttpContext.Current.Request["prgid"] ?? "";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    
    protected int HTProgRight = 0;
    protected string DebugStr = "";
    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";
    protected string SQL = "";
    protected string submitTask = "";
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
        
        conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
        cnn = new DBHelper(Conn.Sysctrl).Debug(Request["chkTest"] == "TEST");

        submitTask = Request["submitTask"];
        //if (submitTask == "A") HTProgCap = HTProgCap + "-<font color=blue>新增</font>";
        //if (submitTask == "U") HTProgCap = HTProgCap + "-<font color=blue>維護</font>";
        //if (submitTask == "Q") HTProgCap = HTProgCap + "-<font color=blue>查詢</font>";
        
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
     <table border="0" width="100%" cellspacing="0" cellpadding="0">
            <tr>
                <td width="100%" id="Cont" colspan="2" height="100%" valign="top">
                    <uc1:cust14queryform runat="server" ID="cust14queryform" />
                </td>
            </tr>
    </table>
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
<div align="left">
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

        cust14queryform.init();

    }

    //[重填]
    $("#btnRest").click(function (e) {
        reg.reset();
        this_init();
    });

    //[查詢]
    $("#btnSrch").click(function (e) {

        if ($("#cust_seqs").val() == "" && $("#cust_seqe").val() == "" && $("#apcust_no").val() == ""
            && $("#ap_cname").val() == "" && $("#ap_ename").val() == "")
        {
            alert("客戶編號或証照號碼或客戶/申請人名稱需輸入其一!");
            return false;
        }

        if ($("#ap_cname").val() != "") {
            if (fDataLenX($("#ap_cname").val(), 0, "") < 4) {
                alert("「客戶/申請人名稱(中)」至少輸入2個中文字!");
                return false;
            }
        }
        if ($("#ap_ename").val() != "") {
            if (fDataLenX($("#ap_ename").val(), 0, "") < 4) {
                alert("「客戶/申請人名稱(英)」至少輸入4個英文字!");
                return false;
            }
        }
        reg.action = "cust14_List.aspx";
        reg.submit();
    });


    $("#cust_seqs").blur(function myfunction() {
        if (NulltoEmpty($("#cust_seqs").val()) != "") {
            $("#cust_seqe").val($("#cust_seqs").val());
        }
    })




</script>
