<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Linq" %>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<script runat="server">
    protected string HTProgCap = "收費標準查詢";//;//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "Brt26";//HttpContext.Current.Request["prgid"] ?? "";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";
    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";
    protected string SQL = "";
    protected object objResult = null;

    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected Dictionary<string, string> Lock = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    protected Dictionary<string, object> RS = new Dictionary<string, object>(StringComparer.OrdinalIgnoreCase);

    protected string submitTask = "";
    protected string tblname = "";
    protected string country = "";
    protected string dept = "";
    protected string arcase = "";
    protected string coun_c = "";
    protected string sqlno = "";

    DBHelper conn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    private void Page_Unload(System.Object sender, System.EventArgs e) {
        if (conn != null) conn.Dispose();
    }

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");

        submitTask = ReqVal.TryGet("submittask").ToUpper();
        country = ReqVal.TryGet("country");//國別
        dept = ReqVal.TryGet("dept");//專/商
        arcase = ReqVal.TryGet("arcase");//案性
        coun_c = ReqVal.TryGet("coun_c");//國別
        sqlno = ReqVal.TryGet("sqlno");

        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        HTProgCap = myToken.Title;
        DebugStr = myToken.DebugStr;
        if (HTProgRight >= 0) {
            PageLayout();
            QueryData();
            this.DataBind();
        }
    }

    private void PageLayout() {
    }

    private void QueryData() {
        if (country == "T") {
            tblname = "tbfee_v";
        } else {
            tblname = "tebfee_v";
        }

        SQL = "select * from " + tblname;
        SQL += " where country='" + country + "' and dept='" + dept + "' and arcase='" + arcase + "' and sqlno=" + sqlno;
        Sys.showLog(SQL);
        DataTable dt = new DataTable();
        conn.DataTable(SQL, dt);
        RS = dt.ToDictionary().FirstOrDefault() ?? new Dictionary<string, object>();
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
            <a class="imgCls" href="javascript:void(0);" >[關閉視窗]</a>
            <%#StrFormBtnTop%>
        </td>
    </tr>
    <tr>
        <td colspan="2"><hr class="style-one"/></td>
    </tr>
</table>

<form id="reg" name="reg" method="post">
    <INPUT TYPE="hidden" id=prgid name=prgid value="<%=prgid%>">

    <table class=bluetable border=0 cellspacing=1 cellpadding=2 width="75%" align="center">
        <tr class=lightbluetable>
            <td>國家：</td>
            <td class=whitetablebg><%=coun_c%></td>
        </tr>
	    <tr class=lightbluetable>
            <td>案性：</td>
            <td class=whitetablebg><%#RS.TryGet("arcase")%>-<%#RS.TryGet("case_name")%></td>
	    </tr>
	    <tr class=lightbluetable>
            <td>說明：</td>
            <td class=whitetablebg>
                <textarea class="Lock" cols=60 rows=10 style="width:99%"><%#RS.TryGet("remark")%></textarea>
            </td>
	    </tr>
    </table>
</form>

</body>
</html>

<script language="javascript" type="text/javascript">
    $(function () {
        this_init();
    });

    function this_init() {
        if (window.parent.tt !== undefined) {
            window.parent.tt.rows = "*,2*";
        }

        $("input.dateField").datepick();
        $(".Lock").lock();
    }
</script>
