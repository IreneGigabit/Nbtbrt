<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Data"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>
<%@ Register Src="~/commonForm/Brta21form.ascx" TagPrefix="uc1" TagName="Brta21form" %>
<%@ Register Src="~/commonForm/Brta23form.ascx" TagPrefix="uc1" TagName="Brta23form" %>


<script runat="server">
    protected string HTProgCap = "國內案期限管制維護作業";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = HttpContext.Current.Request["prgid"] ?? "";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";
    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";
    protected string formFunction = "";
    
    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected Dictionary<string, string> Lock = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    protected Dictionary<string, string> Hide = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);

    protected string SQL = "";
    protected object objResult = null;

    protected string submitTask = "";
    protected string json_data = "";
    protected string cgrs = "";
    protected string formdmp = "";
    protected string chk = "";

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
        cgrs = ReqVal.TryGet("cgrs");
        formdmp = ReqVal.TryGet("formdmp");//Y:表由程序確認收文入資料
        chk = ReqVal.TryGet("chk");//Y:主管確認退回分案人員，N:主管退回承辦

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
        if (submitTask == "Q" || submitTask == "D") {
            Lock["QLock"] = "Lock";
            Lock["Qdisabled"] = "Lock";
        }
        
        if (submitTask == "A") HTProgCap += "-<font color=blue>新增</font>";
        if (submitTask == "U") HTProgCap += "-<font color=blue>修改</font>";
        if (submitTask == "Q") HTProgCap += "-<font color=blue>查詢</font>";
        if (submitTask == "D") HTProgCap += "-<font color=blue>刪除</font>";

        if (submitTask != "A") {
            StrFormBtnTop += "<a class=\"imgCls\" href=\"javascript:void(0);\" >[關閉視窗]</a>\n";
        }
    }

    //將共用參數傳給子控制項
    private void ChildBind() {
        Brta23form.HTProgRight = HTProgRight;
    }

    private string QueryData() {
        Dictionary<string, string> add_ctrl = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
        add_ctrl["seq"] = "";
        add_ctrl["seq1"] = "";

        if (submitTask == "A") {
        }

        if (submitTask == "U" || submitTask == "Q" || submitTask == "D") {
            SQL = "Select * From dmt Where seq = '" + Request["aseq"] + "' and seq1 = '" + Request["aseq1"] + "'";
            DataTable dtStepMgt = new DataTable();
            conn.DataTable(SQL, dtStepMgt);

            if (dtStepMgt.Rows.Count > 0) {
                DataRow dr = dtStepMgt.Rows[0];

                add_ctrl["seq"] = dr.SafeRead("seq", "");
                add_ctrl["seq1"] = dr.SafeRead("seq1", "");
            }
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
        rtn += ",\\\"add_ctrl\\\":" + JsonConvert.SerializeObject(add_ctrl, settings).Replace("\\", "\\\\").Replace("\"", "\\\"");
        rtn += "}";

        return rtn;
    }
</script>
<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title><%=HTProgCap%></title>
<link rel="stylesheet" type="text/css" href="<%=Page.ResolveUrl("~/inc/setstyle.css")%>" />
<link rel="stylesheet" type="text/css" href="<%=Page.ResolveUrl("~/js/lib/jquery.datepick.css")%>" />
<link rel="stylesheet" type="text/css" href="<%=Page.ResolveUrl("~/js/lib/toastr.css")%>" />
<link rel="stylesheet" type="text/css" href="<%=Page.ResolveUrl("~/js/lib/jquery-ui.min.css")%>" />
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/jquery-1.12.4.min.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/jquery-ui.min.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/jquery.datepick.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/jquery.datepick-zh-TW.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/toastr.min.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/util.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/jquery.Snoopy.date.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/jquery.irene.form.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/client_chk.js")%>"></script>
</head>
<script language="javascript" type="text/javascript">
    var main = {};
    main.prgid = "<%#prgid%>";
    main.right = <%#HTProgRight%>;
    main.submittask = "<%#submitTask%>";
    main.cgrs = "<%#cgrs%>";
    main.formdmp  = "<%#formdmp%>";
    main.chk = "<%#chk%>";
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
    <INPUT TYPE="text" id=prgid name=prgid value="<%=prgid%>">
    <INPUT TYPE="text" id=submittask name=submittask value="<%=submitTask%>">
    <INPUT TYPE="text" id=cgrs name=cgrs value="<%=cgrs%>">
    <center>
        <uc1:Brta21form runat="server" ID="Brta21form" /><!--~/commonForm/brt21form.ascx-->
        <uc1:Brta23form runat="server" id="Brta23form" /><!--~/commonForm/brt23form.ascx-->
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

<div id="dialog"></div>

<iframe id="ActFrame" name="ActFrame" src="about:blank" width="100%" height="500" style="display:none"></iframe>
</body>
</html>

<script language="javascript" type="text/javascript">
    $(function () {
        if (window.parent.tt !== undefined) {
            if($("#prgid").val()!="brt51"){
                window.parent.tt.rows = "*,2*";
            }else{
                window.parent.tt.rows = "0%,100%";
            }
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
        $("#reg").attr("action","brta23_edit.aspx");
        $("#reg").submit();
    };
    //////////////////////

    function this_init() {
        jMain = $.parseJSON("<%#json_data%>");

        //畫面準備
        brta21form.init();//主檔資料
        brta23form.init();//進度資料
        //-----------------
        $("input.dateField").datepick();
        main.bind();//資料綁定
        $(".Lock").lock();
        $(".Hide").hide();
    }
    
    main.bind = function () {
        brta21form.bind(jMain.add_ctrl);//主檔資料
        brta23form.bind();//進度資料
    }
</script>

