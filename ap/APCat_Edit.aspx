<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Linq" %>

<script runat="server">
    protected string HTProgCap = "Menu資料";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "APCat";//HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = HttpContext.Current.Request["prgid"] ?? "";//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";
    protected string Title = "";
    protected string StrFormBtn = "";

    protected string submitTask = "";
    protected string syscode = "";
    protected string APcatID = "";

    protected string ULock = "false";

    protected string SQL = "";
    protected Dictionary<string, object> RS = new Dictionary<string, object>();

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        submitTask = Request["submitTask"] ?? "";
        syscode = Request["syscode"] ?? "";
        APcatID = Request["APcatID"] ?? "";

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
        //欄位開關
        if (submitTask == "A") {
        } else if (submitTask == "U") {
            ULock = "true";
        }

        using (DBHelper conn = new DBHelper(Conn.ODBCDSN, false)) {
            SQL = "SELECT * FROM APcat WHERE syscode='" + syscode + "' AND APcatID='" + APcatID + "'";
            DataTable dt = new DataTable();
            conn.DataTable(SQL, dt);
            RS = dt.ToDictionary().FirstOrDefault() ?? new Dictionary<string, object>();
        }

        if (submitTask == "U") {
            HTProgCap = HTProgCap + "‧編修作業";
            if ((HTProgRight & 8) > 0) {
                StrFormBtn += "<input type=button value=\"編修存檔\" class=\"cbutton\" id=\"btnSubmit\">\n";
            }
            if ((HTProgRight & 16) > 0) {
                StrFormBtn += "<input type=button value=\"刪　除\" class=\"cbutton\" id=\"btnDel\">\n";
            }
            StrFormBtn += "<input type=button value=\"重　填\" class=\"cbutton\" id=\"btnReset\">\n";
            StrFormBtn += "<input type=button value=\"關閉視窗\" class=\"cbutton\" id=\"btnClose\">\n";
        } else {
            HTProgCap = HTProgCap + "‧新增作業";
            if ((HTProgRight & 4) > 0) {
                StrFormBtn += "<input type=button value=\"新增存檔\" class=\"cbutton\" id=\"btnSubmit\">\n";
                StrFormBtn += "<input type=button value=\"重　填\" class=\"cbutton\" id=\"btnReset\">\n";
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
	<input type="hidden" id="task" name="task" value="">
	<input type="hidden" id="prgid" name="prgid" value="<%=prgid%>">
	<input type="hidden" id="syscode" name="syscode" value="<%=syscode%>">

    <table border="0" class="bluetable" cellspacing="1" cellpadding="2" width="80%" align="center">	
        <TR>
		  <TD class=lightbluetable align=right>網路作業系統代碼：</TD>
		  <TD class=whitetablebg><INPUT TYPE=text id=pfx_SYScode NAME=pfx_SYScode SIZE=10 MAXLENGTH=16 class=Lock></TD>
		</TR>
		<TR>
		  <TD class=lightbluetable align=right>Menu作業分類代碼：</TD>
		  <TD class=whitetablebg><INPUT TYPE=text id=pfx_APcatID NAME=pfx_APcatID SIZE=10 MAXLENGTH=10 class="ULock"></TD>
		</TR>
		<TR>
		  <TD class=lightbluetable align=right>系統中文名稱：</TD>
		  <TD class=whitetablebg><INPUT TYPE=text id=tfx_APcatCName NAME=tfx_APcatCName SIZE=20 MAXLENGTH=20></TD>
		</TR>
		<TR>
		  <TD class=lightbluetable align=right>系統英文名稱：</TD>
		  <TD class=whitetablebg><INPUT TYPE=text id=tfx_APcatEName NAME=tfx_APcatEName SIZE=30 MAXLENGTH=30></TD>
		</TR>
		<TR>
		  <TD class=lightbluetable align=right>系統Menu顯示次序：</TD>
		  <TD class=whitetablebg><INPUT TYPE=text id=nfx_APseq NAME=nfx_APseq SIZE=8 style="text-align:right;"></TD>
		</TR>
    </TABLE>

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
            window.parent.tt.rows = "0%,100%";
        }

        this_init();
    });

    //初始化
    function this_init() {
        $("input.dateField").datepick();
        //欄位控制
        $(".Lock").lock();
        $(".ULock").lock(<%#ULock%>);

        if ($("#submittask").val() != "A") {
            if (window.parent.tt !== undefined) {
                window.parent.tt.rows = "*,2*";
            }
            $("#pfx_SYScode").val("<%#RS.TryGet("syscode","")%>");
            $("#pfx_APcatID").val("<%#RS.TryGet("apcatid","")%>");
            $("#tfx_APcatCName").val("<%#RS.TryGet("apcatcname","")%>");
            $("#tfx_APcatEName").val("<%#RS.TryGet("apcatename","")%>");
            $("#nfx_APseq").val("<%#RS.TryGet("apseq","").ToString()%>");
        } else {
            $("#pfx_SYScode").val("<%#syscode%>");
        }
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
        if ($("#pfx_SYScode").val() == "") {
            alert("請務必填寫「網路作業系統代碼」，不得為空白！");
            $("#pfx_SYScode").focus();
            return false;
        }
        if ($("#pfx_APcatID").val() == "") {
            alert("請務必填寫「Menu作業分類代碼」，不得為空白！");
            $("#pfx_APcatID").focus();
            return false;
        }
        if ($("#tfx_APcatCName").val() == "") {
            alert("請務必填寫「系統中文名稱」，不得為空白！");
            $("#tfx_APcatCName").focus();
            return false;
        }
        $("select,textarea,input,span").unlock();
        $("#btnSubmit,#btnDel,#btnReset").lock(!$("#chkTest").prop("checked"));
        $("#task").val($("#submittask").val());
        reg.action = "<%=HTProgPrefix%>_Update.aspx";
        reg.target = "ActFrame";
        reg.submit();
    });

    //刪除
    $("#btnDel").click(function () {
        if (confirm("注意！\n\n　你確定刪除資料嗎？")) {
            $("select,textarea,input,span").unlock();
            $("#btnSubmit,#btnDel,#btnReset").lock(!$("#chkTest").prop("checked"));
            $("#task").val("D");
            reg.action = "<%=HTProgPrefix%>_Update.aspx";
            reg.target = "ActFrame";
            reg.submit();
        }
    });

    //重置
    $("#btnReset").click(function () {
        reg.reset();
        this_init();
    });
</script>
