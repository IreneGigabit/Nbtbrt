<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Data"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>
<%@ Register Src="~/commonForm/Brta21form.ascx" TagPrefix="uc1" TagName="Brta21form" %>
<%@ Register Src="~/commonForm/Brta61form.ascx" TagPrefix="uc1" TagName="Brta61form" %>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>

<script runat="server">
    protected string HTProgCap = "國內案件進度查詢";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "brta61";//HttpContext.Current.Request["prgid"] ?? "";//程式檔名前綴
    protected string HTProgCode = "brta61";//HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid ="brta61";// (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";
    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";
    protected string formFunction = "";
    protected string FormName = "";
  
    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected Dictionary<string, string> Lock = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    protected Dictionary<string, string> Hide = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);

    protected string SQL = "";
    protected object objResult = null;

    protected string submitTask = "";
    protected string seq = "";
    protected string seq1 = "";
    protected string json_data = "";

    DBHelper conn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    private void Page_Unload(System.Object sender, System.EventArgs e) {
        if (conn != null) conn.Dispose();
    }

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
        if (ReqVal.TryGet("type") == "brtran") {
            conn = new DBHelper(Conn.brp(Request["branch"])).Debug(Request["chkTest"] == "TEST");
        }
        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");

        submitTask = ReqVal.TryGet("submittask").ToUpper();
        seq = (Request["aseq"] ?? Request["seq"]);
        seq1 = (Request["aseq1"] ?? Request["seq1"]);

        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        HTProgCap = myToken.Title;
        DebugStr = myToken.DebugStr;
        if (HTProgRight >= 0) {
            json_data = QueryData();
            PageLayout();
            ChildBind();
            this.DataBind();
        }
    }

    private void PageLayout() {
        if (submitTask == "Q") {
            Lock["QLock"] = "Lock";
            Lock["Qdisabled"] = "Lock";
        }

        StrFormBtnTop += "<a class=\"imgCls\" href=\"javascript:void(0);\" >[關閉視窗]</a>\n";
    }

    //將共用參數傳給子控制項
    private void ChildBind() {
        Brta61form.HTProgRight = HTProgRight;
    }

    private string QueryData() {
        Dictionary<string, string> dmt_data = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
        dmt_data["seq"] = "";
        dmt_data["seq1"] = "";

        SQL = "Select * From dmt Where seq = '" + seq+ "' and seq1 = '" + seq1 + "'";
        
        DataTable dtDmt = new DataTable();
        conn.DataTable(SQL, dtDmt);

        if (dtDmt.Rows.Count > 0) {
            DataRow dr = dtDmt.Rows[0];

            dmt_data["branch"] = dr.SafeRead("cust_area", "");
            dmt_data["seq"] = dr.SafeRead("seq", "");
            dmt_data["seq1"] = dr.SafeRead("seq1", "");
        }

        var settings = new JsonSerializerSettings()
        {
            Formatting = Formatting.None,
            ContractResolver = new LowercaseContractResolver(),//key統一轉小寫
            Converters = new List<JsonConverter> { new DBNullCreationConverter(), new TrimCreationConverter() }//dbnull轉空字串且trim掉
        };
        
        string rtn = "";
        rtn += "{";
        rtn += "\\\"request\\\":" + JsonConvert.SerializeObject(ReqVal, settings).Replace("\\", "\\\\").Replace("\"", "\\\"");
        rtn += ",\\\"dmt_data\\\":" + JsonConvert.SerializeObject(dmt_data, settings).Replace("\\", "\\\\").Replace("\"", "\\\"");
        rtn += "}";

        return rtn;
    }
</script>
<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title><%=HTProgCap%></title>
    <uc1:head_inc_form runat="server" ID="head_inc_form" />
</head>
<script language="javascript" type="text/javascript">
    var main = {};
    main.prgid = "<%#prgid%>";
    main.right = <%#HTProgRight%>;
    main.submittask = "<%#submitTask%>";
    main.seq = "<%#seq%>";
    main.seq1  = "<%#seq1%>";
    jMain={};
</script>

<body>
<table cellspacing="1" cellpadding="0" width="98%" border="0">
    <tr>
        <td class="text9" nowrap="nowrap">&nbsp;【<%=HTProgCode%><%=HTProgCap%>】</td>
        <td class="FormLink" valign="top" align="right" nowrap="nowrap">
            <%#StrFormBtnTop%>
        </td>
    </tr>
    <tr>
        <td colspan="2"><hr class="style-one"/></td>
    </tr>
</table>
<br>
<form id="reg" name="reg" method="post">
    <INPUT TYPE="hidden" id=prgid name=prgid value="<%=prgid%>">
    <INPUT TYPE="hidden" id=submittask name=submittask value="<%=submitTask%>">
    <center style="width:98%">
        <uc1:Brta21form runat="server" ID="Brta21form" /><!--~/commonForm/brt21form.ascx-->
        <uc1:Brta61form runat="server" ID="Brta61form" /><!--~/commonForm/brta61form.ascx-->
    </center>

    <%#DebugStr%>
</form>

<table border="0" width="98%" cellspacing="0" cellpadding="0">
<tr>
    <td width="100%" align="center">
        <%#StrFormBtn%>
    </td>
</tr>
</table>

<br />
<div align="left" style="color:blue">
自2017/8/1後採電子申請之案件，均可點下「官發進度」旁的<img src="<%#Page.ResolveUrl("~/images/gs_img1.png")%>" WIDTH="20" HEIGHT="20" title="電子送件資訊查詢" style="cursor:pointer" >圖示查詢總管處電子送件資訊，
例如：若須提前取得新申請案之申請案號，可於總管處完成送件後，透過此功能查詢。
</div>

<div id="dialog"></div>

<iframe id="ActFrame" name="ActFrame" src="about:blank" width="100%" height="300" style="display:none"></iframe>
</body>
</html>

<script language="javascript" type="text/javascript">
    $(function () {
        if (window.parent.tt !== undefined) {
            window.parent.tt.rows = "0%,100%";
        }

        this_init();
    });

    // 切換頁籤
    $("#CTab td.tab").click(function (e) {
        settab($(this).attr('href'));
    });
    function settab(k) {
        $("#CTab td.tab").removeClass("seltab").addClass("notab");
        $("#CTab td.tab[href='" + k + "']").addClass("seltab").removeClass("notab");
        $("div.tabCont").hide();
        $("div.tabCont[id='" + k + "']").show();
    }

    //執行查詢
    function goSearch() {
        $("#reg").attr("action","brta61_edit.aspx");
        $("#reg").submit();
    };
    //////////////////////

    function this_init() {
        jMain = $.parseJSON("<%#json_data%>");

        //畫面準備
        brta21form.init();//主檔資料
        brta61form.init();//進度資料
        //-----------------
        $("input.dateField").datepick();
        main.bind();//資料綁定
        $(".Lock").lock();
        $(".Hide").hide();
    }
    
    main.bind = function () {
        brta21form.bind(jMain.dmt_data);//主檔資料
        brta61form.bind();//進度資料
    }
</script>

