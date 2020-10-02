<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>

<script runat="server">
    protected string HTProgCap = "洽案登錄完成[下一筆]";// HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "brt11";//程式檔名前綴
    protected string HTProgCode = "brt11";//HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected int HTProgRight = 0;

    protected string SQL = "";

    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";

    protected string submitTask = "";
    protected string F_tscode = "";
    protected string cust_area = "";
    protected string cust_seq = "";
    protected string in_no = "";
    protected string ar_Form = "";
    protected string prt_code = "";
    protected string add_arcase = "";
    protected string seq = "";
    protected string seq1 = "";
    protected string code_type = "";
    
    private void Page_Unload(System.Object sender, System.EventArgs e) {
    }
    
    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        ReqVal = Util.GetRequestParam(Context,Request["chkTest"] == "TEST");
        submitTask = Request["submitTask"] ?? "";
        F_tscode = Request["F_tscode"] ?? "";
        cust_area = Request["cust_area"] ?? "";
        cust_seq = Request["cust_seq"] ?? "";
        in_no = Request["in_no"] ?? "";
        ar_Form = Request["ar_Form"] ?? "";
        prt_code = Request["prt_code"] ?? "";
        add_arcase = Request["add_arcase"] ?? "";
        seq = Request["seq"] ?? "";
        seq1 = Request["seq1"] ?? "";
        code_type = Request["code_type"] ?? "";
    
        Token myToken = new Token(HTProgCode);
        HTProgRight = myToken.CheckMe();
        HTProgCap = myToken.Title;
        if (HTProgRight >= 0) {
            PageLayout();

            this.DataBind();
        }
    }

    private void PageLayout() {
    }
</script>
<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title><%=HTProgCap%></title>
<link rel="stylesheet" type="text/css" href="<%=Page.ResolveUrl("~/inc/setstyle.css")%>" />
<link rel="stylesheet" type="text/css" href="<%=Page.ResolveUrl("~/js/lib/jquery.datepick.css")%>" />
<link rel="stylesheet" type="text/css" href="<%=Page.ResolveUrl("~/js/lib/toastr.css")%>" />
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/jquery-1.12.4.min.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/jquery.datepick.min.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/jquery.datepick-zh-TW.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/toastr.min.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/util.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/jquery.irene.form.js")%>"></script>
</head>

<body>
<table cellspacing="1" cellpadding="0" width="98%" border="0" align="center">
    <tr>
        <td class="text9" nowrap="nowrap">&nbsp;【<%=prgid%> <%=HTProgCap%>】</td>
        <td class="FormLink" valign="top" align="right" nowrap="nowrap">
            <%#StrFormBtnTop%>
        </td>
    </tr>
    <tr>
        <td colspan="2"><hr class="style-one"/></td>
    </tr>
</table>

<form style="margin:0;" id="reg" name="reg" method="post">
<INPUT TYPE=hidden name=submitTask value="">
<INPUT TYPE=hidden name=tscode value="<%=F_tscode%>">
<INPUT TYPE=hidden name=cust_area value="<%=cust_area%>">
<INPUT TYPE=hidden name=cust_seq value="<%=cust_seq%>">
<INPUT TYPE=hidden name=in_no value="<%=in_no%>">
<INPUT TYPE=hidden name=Ar_Form value="<%=ar_Form%>">
<INPUT TYPE=hidden name=prt_code value="<%=prt_code%>">
<INPUT TYPE=hidden name=add_arcase value="<%=add_arcase%>">
<INPUT TYPE=hidden name=seq value="<%=seq%>">
<INPUT TYPE=hidden name=seq1 value="<%=seq1%>">
<INPUT TYPE=hidden name=code_type value="<%=code_type%>">
<INPUT TYPE=hidden name=uploadtype value="case">
</form>

    <table border="0" width="100%" cellspacing="0" cellpadding="0" align="center">
        <tr>
            <td width="100%" align="center">
                <br /><font size=4>資料新增成功</font><br /><br />
            </td>
        </tr>
        <tr>
            <td width="100%" align="center">
                <input type="button" value="新增下一筆" class="cbutton bsubmit" onclick="AddForm()">
                <input type="button" value="複製下一筆" class="cbutton bsubmit" onclick="NextForm()">
                <input type="button" value="案件洽成交辦" class="cbutton bsubmit" onclick="QueryForm()">
            </td>
        </tr>
    </table>
</body>
</html>

<script language="javascript" type="text/javascript">
    $(function () {
        if (window.parent.tt !== undefined) {
            window.parent.tt.rows = "100%,0%";
        }
    });

    //關閉視窗
    $(".imgCls").click(function (e) {
        if (window.parent.tt !== undefined) {
            window.parent.tt.rows = "100%,0%";
        } else {
            window.close();
        }
    })

    function AddForm(){
        reg.action = "Brt11Add" + reg.prt_code.value + ".aspx";
        reg.submit();
    }
	
    function NextForm() {
        reg.action = "Brt11Add" + reg.prt_code.value + ".aspx";
        reg.submitTask.value = "AddNext";
        reg.submit();
    }
	
    function QueryForm() {
        reg.action = "Brt11ListA.aspx";
        reg.submit();
    }
</script>
