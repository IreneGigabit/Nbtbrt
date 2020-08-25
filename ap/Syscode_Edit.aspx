<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Linq" %>

<script runat="server">
    protected string HTProgCap = "系統資料";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "Syscode";//HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = HttpContext.Current.Request["prgid"] ?? "";//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";
    protected string Title = "";
    protected string StrFormBtn = "";

    protected string submitTask = "";
    protected string syscode = "";

    protected string ULock = "false";

    protected string SQL = "";
    protected Dictionary<string, object> RS = new Dictionary<string, object>();

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        submitTask = Request["submitTask"] ?? "";
        syscode = Request["syscode"] ?? "";

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
            SQL = "SELECT * FROM syscode WHERE syscode='" + syscode + "'";
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

    <table border="0" class="bluetable" cellspacing="1" cellpadding="2" width="80%" align="center">	
		<TR>
		  <TD class=lightbluetable align=right>網路作業代碼：</TD>
		  <TD class=whitetablebg><INPUT TYPE=text id=pfx_syscode NAME=pfx_syscode SIZE=10 MAXLENGTH=16 class="ULock"></TD>
		</TR>
		<TR>
		  <TD class=lightbluetable align=right>網路作業名稱(中)：</TD>
		  <TD class=whitetablebg><INPUT TYPE=text id=tfx_sysnameC NAME=tfx_sysnameC SIZE=30 MAXLENGTH=30></TD>
		</TR>
		<TR>
		  <TD class=lightbluetable align=right>網路作業名稱(英)：</TD>
		  <TD class=whitetablebg><INPUT TYPE=text id=tfx_sysnameE NAME=tfx_sysnameE SIZE=30 MAXLENGTH=50></TD>
		</TR>
		<TR>
		  <TD class=lightbluetable align=right>伺服器名稱：</TD>
		  <TD class=whitetablebg><INPUT TYPE=text id=tfx_sysserver NAME=tfx_sysserver SIZE=10 MAXLENGTH=10></TD>
		</TR>
		<TR>
		  <TD class=lightbluetable align=right>路徑：</TD>
		  <TD class=whitetablebg><INPUT TYPE=text id=tfx_syspath NAME=tfx_syspath SIZE=40 MAXLENGTH=60></TD>
		</TR>
		<TR>
		  <TD class=lightbluetable align=right>區所別：</TD>
		  <TD class=whitetablebg>
		  <SELECT id=tfx_DataBranch NAME=tfx_DataBranch></select>
		  </TD>
		</TR>
		<TR>
		  <TD class=lightbluetable align=right>分類代碼：</TD>
		  <TD class=whitetablebg>
		  <SELECT id=tfx_ClassCode NAME=tfx_ClassCode></SELECT>
		  <input type=button value="新增" onclick="newopen()" class=cbutton >
		  <input type=button value="重新整理"  class=cbutton id=button1 name=button1 onclick="getname()">
		  </TD>
		</TR>
		<TR>
		  <TD class=lightbluetable align=right>系統順序：</TD>
		  <TD class=whitetablebg><INPUT TYPE=text id=tfx_syssql NAME=tfx_syssql SIZE=2 MAXLENGTH=2></TD>
		</TR>
		<TR>
		  <TD class=lightbluetable align=right>協調人員：</TD>
		  <TD class=whitetablebg><INPUT TYPE=text id=tfx_corp_user NAME=tfx_corp_user SIZE=15 MAXLENGTH=30></TD>
		</TR>
		<TR>
		  <TD class=lightbluetable align=right>開發人員：</TD>
		  <TD class=whitetablebg><INPUT TYPE=text id=tfx_main_user NAME=tfx_main_user SIZE=15 MAXLENGTH=30></TD>
		</TR>
		<TR>
		  <TD class=lightbluetable align=right>使用人員：</TD>
		  <TD class=whitetablebg><INPUT TYPE=text id=tfx_sys_user NAME=tfx_sys_user SIZE=30 MAXLENGTH=60></TD>
		</TR>
		<TR>
		  <TD class=lightbluetable align=right>上線日期：</TD>
		  <TD class=whitetablebg><INPUT TYPE=text id=dfx_online_date NAME=dfx_online_date SIZE=10 class="dateField"></TD>
		</TR>
		<TR>
		  <TD class=lightbluetable align=right>開始日期：</TD>
		  <TD class=whitetablebg><INPUT TYPE=text id=dfx_beg_date NAME=dfx_beg_date SIZE=10 class="dateField"></TD>
		</TR>
		<TR>
		  <TD class=lightbluetable align=right>結束日期：</TD>
		  <TD class=whitetablebg><INPUT TYPE=text id=dfx_end_date NAME=dfx_end_date SIZE=10 class="dateField"></TD>
		</TR>
		<TR>
		  <TD class=lightbluetable align=right>系統說明：</TD>
		  <TD class=whitetablebg><textarea id=tfx_sysremark NAME=tfx_sysremark rows=6 cols=70></textarea></TD>
		</TR>
		<TR>
		  <TD class=lightbluetable align=right>備註：</TD>
		  <TD class=whitetablebg><INPUT TYPE=text id=tfx_mark NAME=tfx_mark SIZE=1 MAXLENGTH=1></TD>
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
        $("#tfx_DataBranch").getOption({//區所別
            url: getRootPath() + "/ajax/JsonGetSqlDataCnn.aspx",
            data: { mg: "Y", sql: "select branch,branchname from branch_code order by branch" },
            valueFormat: "{branch}",
            textFormat: "{branch}_{branchname}"
        });

        getname();//分類代碼重新整理

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
            $("#pfx_syscode").val("<%#RS.TryGet("syscode","")%>");
            $("#tfx_sysnameC").val("<%#RS.TryGet("sysnameC","")%>");
            $("#tfx_sysnameE").val("<%#RS.TryGet("sysnameE","")%>");
            $("#tfx_sysserver").val("<%#RS.TryGet("sysserver","")%>");
            $("#tfx_syspath").val("<%#RS.TryGet("syspath","").ToString()%>");
            $("#tfx_DataBranch").val("<%#RS.TryGet("DataBranch","")%>");
            $("#tfx_ClassCode").val("<%#RS.TryGet("ClassCode","")%>");
            $("#tfx_syssql").val("<%#RS.TryGet("syssql","")%>");
            $("#tfx_corp_user").val("<%#RS.TryGet("corp_user","")%>");
            $("#tfx_main_user").val("<%#RS.TryGet("main_user","")%>");
            $("#tfx_sys_user").val("<%#RS.TryGet("sys_user","")%>");
            $("#dfx_online_date").val("<%#Util.parseDBDate(RS.TryGet("online_date","").ToString(),"yyyy/M/d")%>");
            $("#dfx_beg_date").val("<%#Util.parseDBDate(RS.TryGet("beg_date","").ToString(),"yyyy/M/d")%>");
            $("#dfx_end_date").val("<%#Util.parseDBDate(RS.TryGet("end_date","").ToString(),"yyyy/M/d")%>");
            $("#tfx_sysremark").val("<%#RS.TryGet("sysremark","")%>");
            $("#tfx_mark").val("<%#RS.TryGet("mark","")%>");
        } else {
            $("#dfx_end_date").val("2079/6/6");
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
        if ($("#pfx_syscode").val() == "") {
            alert("請務必填寫「網路作業代碼」，不得為空白！");
            $("#pfx_syscode").focus();
            return false;
        }
        if ($("#tfx_sysnameC").val() == "") {
            alert("請務必填寫「網路作業名稱」，不得為空白！");
            $("#tfx_sysnameC").focus();
            return false;
        }
        if ($("#tfx_sysserver").val() == "") {
            alert("請務必填寫「伺服器名稱」，不得為空白！");
            $("#tfx_sysserver").focus();
            return false;
        }
        if ($("#tfx_syspath").val() == "") {
            alert("請務必填寫「路徑」，不得為空白！");
            $("#tfx_syspath").focus();
            return false;
        }
        if ($("#tfx_syspath").val().Left(1) != "/") {
            alert("「路徑」輸入錯誤，請重新輸入！");
            $("#tfx_syspath").focus();
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

    //分類代碼新增
    function newopen() {
        window.open("DataBranch_ADD.aspx?prgid=" + $("#prgid").val());
    }

    //分類代碼重新整理
    function getname() {
        $("#tfx_ClassCode").getOption({
            url: getRootPath() + "/ajax/JsonGetSqlDataCnn.aspx",
            data: { mg: "Y", sql: "select classcode,classnameC from sysclass where sysclass = 'system' order by classcode" },
            valueFormat: "{classcode}",
            textFormat: "{classcode}_{classnameC}"
        });
    }
</script>
