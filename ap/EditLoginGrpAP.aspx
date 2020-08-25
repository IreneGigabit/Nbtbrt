<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Linq" %>

<script runat="server">
    protected string HTProgCap = "編修群組功能權限";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "EditLoginGrpAP";//HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = HttpContext.Current.Request["prgid"] ?? "";//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";
    protected string Title = "";
    protected string StrFormBtn = "";

    protected string submitTask = "";
    protected string syscode = "";
    protected string GrpID = "";
    protected string GrpName = "";

    protected string ULock = "false";

    protected string SQL = "";
    protected Dictionary<string, object> RS = new Dictionary<string, object>();

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        submitTask = Request["submitTask"] ?? "";
        syscode = Request["syscode"] ?? "";
        GrpID = Request["GrpID"] ?? "";
        GrpName = Request["GrpName"] ?? "";

        Token myToken = new Token(HTProgCode);
        HTProgRight = myToken.CheckMe();
        Title = myToken.Title;
        DebugStr = myToken.DebugStr;
        if (HTProgRight >= 0) {
            PageLayout();
            this.DataBind();
        }
    }

    private void PageLayout() {
        if (submitTask == "U") {
            StrFormBtn += "<input type=button value=\"編修存檔\" class=\"cbutton\" id=\"btnSubmit\">\n";
        } else {
            StrFormBtn += "<input type=button value=\"確定存檔\" class=\"cbutton\" id=\"btnSubmit\">\n";
        }

        using (DBHelper conn = new DBHelper(Conn.ODBCDSN, false).Debug(false)) {
            SQL = "SELECT * FROM APcat WHERE SYScode='" + Session["Syscode"].ToString() + "' ORDER BY APseq; ";
            SQL += "SELECT a.SYScode,a.APcat, a.APcode, a.APNameC,isnull(g.rights,0)rights ";
            SQL += ",CONVERT(varchar(10), g.beg_date, 111) AS 'beg_date' ";
            SQL += ",CONVERT(varchar(10), g.end_date, 111) AS 'end_date' ";
            SQL += ",CASE WHEN (isnull(g.rights,0) & 1) = 1 THEN ' checked' ELSE '' END AS 'Chk001' ";
            SQL += ",CASE WHEN (isnull(g.rights,0) & 2) = 2 THEN ' checked' ELSE '' END AS 'Chk002' ";
            SQL += ",CASE WHEN (isnull(g.rights,0) & 4) = 4 THEN ' checked' ELSE '' END AS 'Chk004' ";
            SQL += ",CASE WHEN (isnull(g.rights,0) & 8) = 8 THEN ' checked' ELSE '' END AS 'Chk008' ";
            SQL += ",CASE WHEN (isnull(g.rights,0) & 16) = 16 THEN ' checked' ELSE '' END AS 'Chk016' ";
            SQL += ",CASE WHEN (isnull(g.rights,0) & 32) = 32 THEN ' checked' ELSE '' END AS 'Chk032' ";
            SQL += ",CASE WHEN (isnull(g.rights,0) & 64) = 64 THEN ' checked' ELSE '' END AS 'Chk064' ";
            SQL += ",CASE WHEN (isnull(g.rights,0) & 128) = 128 THEN ' checked' ELSE '' END AS 'Chk128' ";
            SQL += ",CASE WHEN (isnull(g.rights,0) & 256) = 256 THEN ' checked' ELSE '' END AS 'Chk256' ";
            SQL += ",CASE WHEN (isnull(g.rights,0) & 512) = 512 THEN ' checked' ELSE '' END AS 'Chk512' ";
            SQL += " FROM AP AS a";
            SQL += " LEFT JOIN LoginAP AS g ON a.SYScode = g.SYScode AND a.APcode = g.APcode AND g.LoginGrp = '" + GrpID + "'";
            SQL += " WHERE a.SYScode = '" + syscode + "'";
            SQL += " ORDER BY a.APorder";
            DataSet ds = new DataSet();
            conn.DataSet(SQL, ds);

            ds.Relations.Add("APcodeInApcat", ds.Tables[0].Columns["APcatID"], ds.Tables[1].Columns["APcat"]);
            APcatResults.DataSource = ds.Tables[0];
            APcatResults.DataBind();
        }
    }

    protected void APcatResults_ItemDataBound(System.Object sender, System.Web.UI.WebControls.RepeaterItemEventArgs e) {
        if ((e.Item.ItemType == ListItemType.Item) | (e.Item.ItemType == ListItemType.AlternatingItem)) {
            Repeater tempRpt = (Repeater)e.Item.FindControl("APResults");

            if ((tempRpt != null)) {
                tempRpt.DataSource = ((DataRowView)e.Item.DataItem).CreateChildView("APcodeInApcat");
                tempRpt.DataBind();
            }
        }
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
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/client_chk.js")%>"></script>
</head>
<body>
<table cellspacing="1" cellpadding="0" width="98%" border="0">
    <tr>
        <td class="text9" nowrap="nowrap">&nbsp;【<%=prgid%><%=Title%>】<span style="color:blue"><%=HTProgCap%></span>
        </td>
        <td class="FormLink" valign="top" align="right" nowrap="nowrap">
            <a class="imgCls" href="javascript:void(0);" >[關閉視窗]</a>
        </td>
    </tr>
    <tr>
        <td colspan="2"><hr class="style-one"/></td>
    </tr>
</table>
<br>
<form id="reg" name="reg" method="post">
	<input type="hidden" id="submittask" name="submittask" value="<%=submitTask%>">
	<input type="hidden" id="prgid" name="prgid" value="<%=prgid%>">
	<input type="hidden" id="syscode" name="syscode" value="<%=syscode%>">
	<input type="hidden" id="GrpID" name="GrpID" value="<%=GrpID%>">
	<input type="hidden" id="GrpName" name="GrpName" value="<%=GrpName%>">

    <table border="0" cellspacing="1" cellpadding="1" class="apcat-bg" width="98%" align="center">
    <tr>
        <td align="left" class="aprights">群組:&nbsp;<b style="color:red"><%#GrpID%>&nbsp;<%#GrpName%></b></td>
        <td align="center" class="aprights" width="150">
            <input type="button" value="全部折疊" id="CloseAll" class="cbutton">
            <input type="button" value="全部展開" id="OpenAll" class="cbutton">
        </td>
    </tr>
    <asp:Repeater id="APcatResults" OnItemDataBound="APcatResults_ItemDataBound" runat="server">
    <ItemTemplate>
    <tr>
        <td align="left" colspan="2" class="apcat-fw" apcat="#tr<%#DataBinder.Eval(Container.DataItem, "APcatID")%>">&nbsp;
            <input type="image" src="../images/2.gif" class="ximg" />
            &nbsp;<%#DataBinder.Eval(Container.DataItem, "APcatCName")%>
        </td>
    </tr>
    <tr id="tr<%#DataBinder.Eval(Container.DataItem, "APcatID")%>" style="display:block">
        <td class="whitetablebg" colspan="2">
            <table border="0" cellspacing="1" cellpadding="1" width="100%" class="ap-bg" align="center">
                <tr>
                    <td align="center" width="250" class="aphead">群組</td>
                    <td align="center" width="43" class="aphead">選單</td>
                    <td align="center" width="43" class="aphead">查詢</td>
                    <td align="center" width="43" class="aphead">新增</td>
                    <td align="center" width="43" class="aphead">修改</td>
                    <td align="center" width="43" class="aphead">刪除</td>
                    <td align="center" width="43" class="aphead">列印</td>
                    <td align="center" width="43" class="aphead">保留A</td>
                    <td align="center" width="43" class="aphead">保留B</td>
                    <td align="center" width="43" class="aphead">保留C</td>
                    <td align="center" width="43" class="aphead">除錯</td>
                    <td align="center" width="43" class="aphead">全選</td>
                    <td align="left" class="aphead">有效期間</td>
                </tr>
                <asp:Repeater id="APResults" runat="server">
                <ItemTemplate>
                <tr>
                    <td align="left" class="apname">&nbsp;
                        <%#DataBinder.Eval(Container.DataItem, "APNameC")%>
                    </td>
                    <td align="center" class="apname">
                        <input type="checkbox" name="chk_<%#Eval("APcode")%>_001" value="1"<%#Eval("Chk001")%> />
                    </td>
                    <td align="center" class="aprights">
                        <input type="checkbox" name="chk_<%#Eval("APcode")%>_002" value="2"<%#Eval("Chk002")%> />
                    </td>
                    <td align="center" class="aprights">
                        <input type="checkbox" name="chk_<%#Eval("APcode")%>_004" value="4"<%#Eval("Chk004")%> />
                    </td>
                    <td align="center" class="aprights">
                        <input type="checkbox" name="chk_<%#Eval("APcode")%>_008" value="8"<%#Eval("Chk008")%> />
                    </td>
                    <td align="center" class="aprights">
                        <input type="checkbox" name="chk_<%#Eval("APcode")%>_016" value="16"<%#Eval("Chk016")%> />
                    </td>
                    <td align="center" class="aprights">
                        <input type="checkbox" name="chk_<%#Eval("APcode")%>_032" value="32"<%#Eval("Chk032")%> />
                    </td>
                    <td align="center" class="aprights">
                        <input type="checkbox" name="chk_<%#Eval("APcode")%>_064" value="64"<%#Eval("Chk064")%> />
                    </td>
                    <td align="center" class="aprights">
                        <input type="checkbox" name="chk_<%#Eval("APcode")%>_128" value="128"<%#Eval("Chk128")%> />
                    </td>
                    <td align="center" class="aprights">
                        <input type="checkbox" name="chk_<%#Eval("APcode")%>_256" value="256"<%#Eval("Chk256")%> />
                    </td>
                    <td align="center" class="aprights">
                        <input type="checkbox" name="chk_<%#Eval("APcode")%>_512" value="512"<%#Eval("Chk512")%> />
                    </td>
                    <td align="center" class="aprights">
                        <input type="checkbox" name="chk_<%#Eval("APcode")%>_ALL"/>
                    </td>
                    <td align="left" class="aprights" nowrap="nowrap">
                        <input type="text" name="Bgn_<%#Eval("APcode")%>" class="dateField" value="<%#Eval("beg_date", "{0:d}")%>" size="10" /> ~
                        <input type="text" name="End_<%#Eval("APcode")%>" class="dateField" value="<%#Eval("end_date", "{0:d}")%>" size="10" />
                    </td>
                </tr>
                </ItemTemplate>
                </asp:Repeater>
            </table>
      </ItemTemplate>
    </asp:Repeater>
    </table>

    <table border="0" width="98%" cellspacing="0" cellpadding="0" >
    <tr id="tr_button1">
        <td align="center">
            <%#StrFormBtn%><%#DebugStr%>
        </td>
    </tr>
    </table>
</form>

<iframe id="ActFrame" name="ActFrame" src="about:blank" width="100%" height="500" style="display:none"></iframe>
</body>
</html>

<script language="javascript" type="text/javascript">
    $(function () {
        if (window.parent.tt !== undefined) {
            window.parent.tt.rows = "0%,100%";
        }

        this_init();
    });

    //全部折疊
    $("#CloseAll").click(function () {
        $("input.ximg").attr("src", "../images/1.gif");
        $("tr[id^='tr']").children().hide();
    });

    //全部展開
    $("#OpenAll").click(function () {
        $("input.ximg").attr("src", "../images/2.gif");
        $("tr[id^='tr']").children().show();
    });

    //折疊
    $(".apcat-fw").click(function () {
        var obj = this;
        var apid = $(obj).attr("apcat");
        $(apid).children().toggle();
        $("input.ximg",obj).attr("src", ($(apid).children().is(":hidden")) ? "../images/1.gif" : "../images/2.gif");
        return false;
    }).css('cursor', 'pointer');

    //選單
    $("input[name$=_001]").click(function () {
        var a = this;
        var ss = "input[name^=" + a.name.substr(0, a.name.length - 3) + "][type='checkbox']";
        if (a.checked) {
            ss += ":lt(6)";
            $(ss).prop('checked', true);
        } else
            $(ss).prop('checked', false);
    });

    //全選
    $("input[name$=_ALL]").click(function () {
        var a = this;
        var ss = "input[name^=" + a.name.substr(0, a.name.length - 3) + "][type='checkbox']";//:gt(0)";
        $(ss).prop('checked', a.checked);
    });

    //初始化
    function this_init() {
        $("input.dateField").datepick();
        //欄位控制
        $(".Lock").lock();
    }

    //關閉視窗
    $(".imgCls,#btnClose").click(function (e) {
        if (window.parent.tt !== undefined) {
            window.parent.tt.rows = "100%,0%";
        } else {
            window.close();
        }
    })

    //新增/修改
    $("#btnSubmit").click(function () {
        $("select,textarea,input,span").unlock();
        $("#btnSubmit").lock(!$("#chkTest").prop("checked"));
        reg.action = "<%=HTProgPrefix%>_Update.aspx";
        reg.target = "ActFrame";
        reg.submit();
    });
</script>
