<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Linq" %>

<script runat="server">
    protected string HTProgCap = "程式資料";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "AP";//HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = HttpContext.Current.Request["prgid"] ?? "";//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";
    protected string Title = "";
    protected string StrFormBtn = "";

    protected string submitTask = "";
    protected string syscode = "";
    protected string APcode = "";
    protected string APcat = "";

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
        APcat = Request["APcat"] ?? "";

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
            SQL = "SELECT * FROM AP WHERE syscode='" + syscode + "' AND APcode='" + APcode + "' AND APcat='" + APcat + "'";
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
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/jquery.Snoopy.date.js")%>"></script>
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
		  <TD class=whitetablebg><INPUT TYPE=text id=pfx_SYScode NAME=pfx_SYScode SIZE=10 MAXLENGTH=16 class="Lock"></TD>		
		  <TD class=lightbluetable align=right>程式代碼：</TD>
		  <TD class=whitetablebg><INPUT TYPE=text id=pfx_APcode NAME=pfx_APcode SIZE=10 MAXLENGTH=10  class="ULock"></TD>
		</TR>
		<TR>		  
		  <TD class=lightbluetable align=right>程式中文名稱：</TD>
		  <TD class=whitetablebg colspan=3><INPUT TYPE=text id=tfx_APnameC NAME=tfx_APnameC SIZE=40 MAXLENGTH=30></TD>
		</TR>
		<TR>
		  <TD class=lightbluetable align=right>程式英文名稱：</TD>
		  <TD class=whitetablebg colspan=3><INPUT TYPE=text id=tfx_APnameE NAME=tfx_APnameE SIZE=40 MAXLENGTH=50></TD>
		</TR>
		<TR>
		  <TD class=lightbluetable align=right>Menu作業分類代碼：</TD>
		  <TD class=whitetablebg>
				<Select id=tfx_APcat NAME=tfx_APcat></Select>
		  </TD>		
		  <TD class=lightbluetable align=right>程式實體主機：</TD>
		  <TD class=whitetablebg><INPUT TYPE=text id=tfx_APserver NAME=tfx_APserver SIZE=10 MAXLENGTH=50></TD>
		</TR>
		<TR>
		  <TD class=lightbluetable align=right>程式實體路徑：</TD>
		  <TD class=whitetablebg colspan=3><INPUT TYPE=text id=tfx_APpath NAME=tfx_APpath SIZE=40 MAXLENGTH=100></TD>
		</TR>
		<TR>
		  <TD class=lightbluetable align=right>參數：</TD>
		  <TD class=whitetablebg colspan=3><INPUT TYPE=text id=tfx_ReMark NAME=tfx_ReMark SIZE=40 MAXLENGTH=40></TD>
		</TR>
		<TR>  
		  <TD class=lightbluetable align=right>Menu次序：</TD>
		  <TD class=whitetablebg colspan=3><INPUT TYPE=text id=tfx_APorder NAME=tfx_APorder SIZE=3 MAXLENGTH=3></TD>
		</TR>
		<TR>
		  <TD class=lightbluetable align=right>行政組織類別：</TD>
		  <TD class=whitetablebg><INPUT TYPE=text id=tfx_APGrpClass NAME=tfx_APGrpClass SIZE=10 MAXLENGTH=10></TD>
		  <TD class=lightbluetable align=right>簽核最高層級：</TD>
		  <TD class=whitetablebg><INPUT TYPE=text id=nfx_end_level NAME=nfx_end_level SIZE=8 style="text-align:right;"></TD>
		</TR>
		<TR>
		  <TD class=lightbluetable align=right>有效起始日期：</TD>
		  <TD class=whitetablebg><INPUT TYPE=text id=dfx_beg_date NAME=dfx_beg_date SIZE=10 class="dateField"></TD>
		  <TD class=lightbluetable align=right>有效結束日期：</TD>
		  <TD class=whitetablebg><INPUT TYPE=text id=dfx_end_date NAME=dfx_end_date SIZE=10 class="dateField"></TD>
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

        $("#tfx_APcat").getOption({//Menu作業分類代碼
            url: getRootPath() + "/ajax/JsonGetSqlDataCnn.aspx",
            data: { mg: "Y", sql: "select * from apcat where syscode='" + $("#syscode").val() + "'" },
            valueFormat: "{APCatID}",
            textFormat: "{APCatID}-{APCatCName}"
        });

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
            $("#pfx_APcode").val("<%#RS.TryGet("APcode","")%>");
            $("#tfx_APnameC").val("<%#RS.TryGet("APnameC","")%>");
            $("#tfx_APnameE").val("<%#RS.TryGet("APnameE","")%>");
            $("#tfx_APcat").val("<%#RS.TryGet("APcat","").ToString()%>");
            $("#tfx_APserver").val("<%#RS.TryGet("APserver","").ToString()%>");
            $("#tfx_APpath").val("<%#RS.TryGet("APpath","").ToString()%>");
            $("#tfx_ReMark").val("<%#RS.TryGet("ReMark","").ToString()%>");
            $("#tfx_APorder").val("<%#RS.TryGet("APorder","").ToString()%>");
            $("#tfx_APGrpClass").val("<%#RS.TryGet("APGrpClass","").ToString()%>");
            $("#nfx_end_level").val("<%#RS.TryGet("end_level","").ToString()%>");
            $("#dfx_beg_date").val("<%#Util.parseDBDate(RS.TryGet("beg_date","").ToString(),"yyyy/M/d")%>");
            $("#dfx_end_date").val("<%#Util.parseDBDate(RS.TryGet("end_date","").ToString(),"yyyy/M/d")%>");
        } else {
            $("#pfx_SYScode").val("<%#syscode%>");
            $("#tfx_APcat").val("<%#APcat%>");
            $("#dfx_beg_date").val((new Date()).format("yyyy/M/d"));
        }
    }

    //關閉視窗
    $(".imgCls,#btnClose").click(function (e) {
        if (window.parent.tt !== undefined) {
            if (window.parent.Etop.goSearch !== undefined) {
                window.parent.Etop.goSearch();
            } else {
                window.parent.tt.rows = "100%,0%";
            }
        } else {
            window.close();
        }
    })

    //新增/修改
    $("#btnSubmit").click(function () {
        if ($("#pfx_APcode").val() == "") {
            alert("請務必填寫「程式代碼」，不得為空白！");
            $("#pfx_APcode").focus();
            return false;
        }
        if ($("#tfx_APnameC").val() == "") {
            alert("請務必填寫「程式中文名稱」，不得為空白！");
            $("#tfx_APnameC").focus();
            return false;
        }
        if ($("#tfx_APnameE").val() == "") {
            alert("請務必填寫「程式英文名稱」，不得為空白！");
            $("#tfx_APnameE").focus();
            return false;
        }
        if ($("#tfx_APcat").val() == "") {
            alert("請務必填寫「Menu作業分類代碼」，不得為空白！");
            $("#tfx_APcat").focus();
            return false;
        }
        if ($("#tfx_APserver").val() == "") {
            alert("請務必填寫「程式實體主機」，不得為空白！");
            $("#tfx_APserver").focus();
            return false;
        }
        if ($("#tfx_APpath").val() == "") {
            alert("請務必填寫「程式實體路徑」，不得為空白！");
            $("#tfx_APpath").focus();
            return false;
        }
        if ($("#tfx_APorder").val() == "") {
            alert("請務必填寫「Menu次序」，不得為空白！");
            $("#tfx_APorder").focus();
            return false;
        }
        if ($("#tfx_APGrpClass").val() == "") {
            alert("請務必填寫「行政組織類別」，不得為空白！");
            $("#tfx_APGrpClass").focus();
            return false;
        }
        if ($("#tfx_APorder").val() == "") {
            alert("請務必填寫「Menu次序」，不得為空白！");
            $("#tfx_APorder").focus();
            return false;
        }
        ChkDate($("#dfx_beg_date")[0]);
        ChkDate($("#dfx_end_date")[0]);

        if (!chkSEDate($("#dfx_beg_date").val(), $("#dfx_end_date").val(), "有效日期")) {
            $("#dfx_end_date").focus();
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
