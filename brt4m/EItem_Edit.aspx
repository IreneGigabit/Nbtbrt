<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Linq" %>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<script runat="server">
    protected string HTProgCap = "英文商品資料";//;//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "Eitem";//HttpContext.Current.Request["prgid"] ?? "";//程式檔名前綴
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
        if (submitTask == "Q" || submitTask == "D") {
            Lock["QLock"] = "Lock";
            Lock["Qdisabled"] = "Lock";
        }

        if ((HTProgRight & 4) > 0 || (HTProgRight & 8) > 0 || (HTProgRight & 16) > 0 || (HTProgRight & 64) > 0 || (HTProgRight & 128) > 0) {
            if (((HTProgRight & 8) > 0)) {
                StrFormBtn += "<input type=button id='button1' value='編修存檔' class='cbutton bsubmit' onclick='formModSubmit()'>\n";
            }
            if (((HTProgRight & 16) > 0)) {
                StrFormBtn += "<input type=button id='button1' value='刪　除' class='cbutton bsubmit' onclick='formDelSubmit()'>\n";
            }
            if ((HTProgRight & 4) > 0) {
                StrFormBtn += "<input type=button value=\"新增存檔\" class=\"cbutton bsubmit\" id=\"btnSubmit\">\n";
            }
            StrFormBtn += "<input type=button value='重　填' class='cbutton' onclick='this_init()'>\n";
        }
    }

    private void QueryData() {
        SQL = "select * from eitem where sqlno=" + sqlno;
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
<script language="javascript" type="text/javascript">
    var main = {};
    main.prgid = "<%#prgid%>";
    main.right = <%#HTProgRight%>;
    main.submittask = "<%#submitTask%>";
</script>

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
		<TR>
		  <TD class=lightbluetable align=right>序號：</TD>
		  <TD class=whitetablebg>
              <INPUT TYPE=text id=pfx_sqlno NAME=pfx_sqlno SIZE=8 class=sedit readonly value="<%#RS.TryGet("sqlno")%>">
		  </TD>
		</TR>
		<TR>
		  <TD class=lightbluetable align=right>國際分類：</TD>
		  <TD class=whitetablebg>
              <INPUT TYPE=text id=tfx_class NAME=tfx_class SIZE=6 MAXLENGTH=6 value="<%#RS.TryGet("class")%>" class="<%#Lock.TryGet("QLock")%>">
		  </TD>
		</TR>
		<TR>
		  <TD class=lightbluetable align=right>商品：</TD>
		  <TD class=whitetablebg>
              <INPUT TYPE=text id=tfx_e_name NAME=tfx_e_name SIZE=60 MAXLENGTH=255 value="<%#RS.TryGet("e_name")%>" class="<%#Lock.TryGet("QLock")%>" style="width:99%">
		  </TD>
		</TR>
		<TR>
		  <TD class=lightbluetable align=right>備註：</TD>
		  <TD class=whitetablebg>
              <INPUT TYPE=text id=tfx_mark NAME=tfx_mark SIZE=1 MAXLENGTH=1 value="<%#RS.TryGet("mark")%>" class="<%#Lock.TryGet("QLock")%>">
		  </TD>
		</TR>
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

        main.bind();//資料綁定

        $("input.dateField").datepick();
        $(".Lock").lock();
    }

    main.bind = function () {
    }
</script>
