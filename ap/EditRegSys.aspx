<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Linq" %>

<script runat="server">
    protected string HTProgCap = "編修權限群組";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "EditRegSys";//HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = HttpContext.Current.Request["prgid"] ?? "";//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";
    protected string Title = "";
    protected string StrFormBtn = "";

    protected string submitTask = "";
    protected string syscode = "";
    protected string APcode = "";
    protected string GrpID = "";
    protected string n1 = "";
    protected string n2 = "";

    protected string ULock = "false";

    protected string SQL = "";
    protected Dictionary<string, object> RS = new Dictionary<string, object>();

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        submitTask = Request["submitTask"] ?? "";
        syscode = Request["syscode"] ?? "";
        APcode = Request["APcode"] ?? "";
        GrpID = Sys.GetSession("LoginGrp");
        n1 = Request["n1"] ?? "";
        n2 = Request["n2"] ?? "";

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
        
        using (DBHelper conn = new DBHelper(Conn.ODBCDSN, false)) {
            SQL = "select c.syscode,c.logingrp,c.grpname,d.beg_date,d.end_date";
            SQL += ",(select count(*) from SysCtrl where syscode=c.syscode and logingrp=c.logingrp)gcount";
            SQL += ",isnull(D.rights,0)rights";
            SQL += ",CASE WHEN (isnull(D.rights,0) & 1) = 1 THEN ' checked' ELSE '' END AS 'Chk001' ";
            SQL += ",CASE WHEN (isnull(D.rights,0) & 2) = 2 THEN ' checked' ELSE '' END AS 'Chk002' ";
            SQL += ",CASE WHEN (isnull(D.rights,0) & 4) = 4 THEN ' checked' ELSE '' END AS 'Chk004' ";
            SQL += ",CASE WHEN (isnull(D.rights,0) & 8) = 8 THEN ' checked' ELSE '' END AS 'Chk008' ";
            SQL += ",CASE WHEN (isnull(D.rights,0) & 16) = 16 THEN ' checked' ELSE '' END AS 'Chk016' ";
            SQL += ",CASE WHEN (isnull(D.rights,0) & 32) = 32 THEN ' checked' ELSE '' END AS 'Chk032' ";
            SQL += ",CASE WHEN (isnull(D.rights,0) & 64) = 64 THEN ' checked' ELSE '' END AS 'Chk064' ";
            SQL += ",CASE WHEN (isnull(D.rights,0) & 128) = 128 THEN ' checked' ELSE '' END AS 'Chk128' ";
            SQL += ",CASE WHEN (isnull(D.rights,0) & 256) = 256 THEN ' checked' ELSE '' END AS 'Chk256' ";
            SQL += ",CASE WHEN (isnull(D.rights,0) & 512) = 512 THEN ' checked' ELSE '' END AS 'Chk512' ";
            SQL += "from Logingrp As C ";
            SQL += "LEFT JOIN Loginap As D ON D.SYScode = C.SYScode And D.LoginGrp = C.LoginGrp And D.Apcode = '" + APcode + "'";
            SQL += "Where C.SYScode = '" + syscode + "'";
            SQL += "Order By C.LoginGrp";
            DataTable dt = new DataTable();
            conn.DataTable(SQL, dt);

            dataRepeater.DataSource = dt;
            dataRepeater.DataBind();
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
	<input type="hidden" id="apcode" name="apcode" value="<%=APcode%>">
	<input type="hidden" id="GrpID" name="GrpID" value="<%=GrpID%>">
	<input type="hidden" id="n1" name="n1" value="<%=n1%>">
	<input type="hidden" id="n2" name="n2" value="<%=n2%>">

    <table border="0" cellspacing="1" cellpadding="1" width="98%" class="ap-bg" align="center">
        <tr>
            <td align="center" colspan="13" class="aprights">功能:&nbsp;<b style="color:red"><%#APcode%>&nbsp;<%#n1%>_<%#n2%></b></td>
        </tr>
        <tr>
            <td align="center" class="aphead">群組</td>
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
            <td align="center" class="aphead">有效期間</td>
        </tr>
        <asp:Repeater id="dataRepeater" runat="server">
        <ItemTemplate>
        <tr>
            <td align="left" class="apname">&nbsp;
                <a href="sys14_List.aspx?prgid=<%#prgid%>&Syscode=<%#Eval("Syscode")%>&LoginGrp=<%#Eval("LoginGrp")%>">
                <%#Eval("LoginGrp")%>_<%#Eval("GrpName")%>(<%#Eval("gcount")%>)
                </a>
            </td>
            <td align="center" class="apname">
                <input type="checkbox" name="chk_<%#Eval("LoginGrp")%>_001" value="1"<%#Eval("Chk001")%> />
            </td>
            <td align="center" class="aprights">
                <input type="checkbox" name="chk_<%#Eval("LoginGrp")%>_002" value="2"<%#Eval("Chk002")%> />
            </td>
            <td align="center" class="aprights">
                <input type="checkbox" name="chk_<%#Eval("LoginGrp")%>_004" value="4"<%#Eval("Chk004")%> />
            </td>
            <td align="center" class="aprights">
                <input type="checkbox" name="chk_<%#Eval("LoginGrp")%>_008" value="8"<%#Eval("Chk008")%> />
            </td>
            <td align="center" class="aprights">
                <input type="checkbox" name="chk_<%#Eval("LoginGrp")%>_016" value="16"<%#Eval("Chk016")%> />
            </td>
            <td align="center" class="aprights">
                <input type="checkbox" name="chk_<%#Eval("LoginGrp")%>_032" value="32"<%#Eval("Chk032")%> />
            </td>
            <td align="center" class="aprights">
                <input type="checkbox" name="chk_<%#Eval("LoginGrp")%>_064" value="64"<%#Eval("Chk064")%> />
            </td>
            <td align="center" class="aprights">
                <input type="checkbox" name="chk_<%#Eval("LoginGrp")%>_128" value="128"<%#Eval("Chk128")%> />
            </td>
            <td align="center" class="aprights">
                <input type="checkbox" name="chk_<%#Eval("LoginGrp")%>_256" value="256"<%#Eval("Chk256")%> />
            </td>
            <td align="center" class="aprights">
                <input type="checkbox" name="chk_<%#Eval("LoginGrp")%>_512" value="512"<%#Eval("Chk512")%> />
            </td>
            <td align="center" class="aprights">
                <input type="checkbox" name="chk_<%#Eval("LoginGrp")%>_ALL"/>
            </td>
            <td align="left" class="aprights" nowrap="nowrap">
                <input type="text" name="Bgn_<%#Eval("LoginGrp")%>" class="dateField" value="<%#Eval("beg_date", "{0:d}")%>" size="10" /> ~
                <input type="text" name="End_<%#Eval("LoginGrp")%>" class="dateField" value="<%#Eval("end_date", "{0:d}")%>" size="10" />
            </td>
        </tr>
        </ItemTemplate>
        </asp:Repeater>
    </table>
    <%#DebugStr%>
</form>

<table border="0" width="98%" cellspacing="0" cellpadding="0" >
<tr id="tr_button1">
    <td align="center">
        <%#StrFormBtn%>
    </td>
</tr>
</table>

<iframe id="ActFrame" name="ActFrame" src="about:blank" width="100%" height="500" style="display:none"></iframe>
</body>
</html>

<script language="javascript" type="text/javascript">
    $(function () {
        if (window.parent.tt !== undefined) {
            window.parent.tt.rows = "30%,70%";
        }

        this_init();
    });

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
        $("#btnSubmit,#btnDel,#btnReset").lock(!$("#chkTest").prop("checked"));
        reg.action = "<%=HTProgPrefix%>_Update.aspx";
        reg.target = "ActFrame";
        reg.submit();
    });
</script>
