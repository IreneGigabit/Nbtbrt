<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Linq" %>

<script runat="server">
    protected string HTProgCap = "權限群組資料";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "LoginGrp";//HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = HttpContext.Current.Request["prgid"] ?? "";//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";
    protected string Title = "";
    protected string StrFormBtn = "";

    protected string submitTask = "";
    protected string syscode = "";
    protected string LoginGrp = "";

    protected string ULock = "false";

    protected string SQL = "";
    protected Dictionary<string, object> RS = new Dictionary<string, object>();

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        submitTask = Request["submitTask"] ?? "";
        syscode = Request["syscode"] ?? "";
        LoginGrp = Request["LoginGrp"] ?? "";

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
            SQL = "SELECT * FROM LoginGrp WHERE SYScode='" + syscode + "' And LoginGrp = '" + LoginGrp + "'";
            DataTable dt = new DataTable();
            conn.DataTable(SQL, dt);
            RS = dt.ToDictionary().FirstOrDefault() ?? new Dictionary<string, object>();
        }

        if (submitTask == "U") {
            HTProgCap = HTProgCap + "‧編修作業";
            if ((HTProgRight & 8) > 0) {
                StrFormBtn += "<input type=button value=\"編修群組\" class=\"cbutton\" id=\"btnSubmit\">\n";
            }
            if ((HTProgRight & 16) > 0) {
                StrFormBtn += "<input type=button value=\"刪除群組\" class=\"cbutton\" id=\"btnDel\">\n";
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
	<input type="hidden" id="LoginGrp" name="LoginGrp" value="<%=LoginGrp%>">

    <table border="0" class="bluetable" cellspacing="1" cellpadding="2" width="80%" align="center">	
        <tr>    
            <td align="center" class="bluetext" width=25%>網路作業系統代碼</td>     
            <td class="bluedata" width=3%><input id="pfx_Syscode" name="pfx_Syscode" size="20" class="Lock"></td>
            <td align="center" class="bluetext" width=20%>登錄群組代碼</td>     
            <td class="bluedata" width=2%><input id="pfx_LoginGrp" name="pfx_LoginGrp" size="20" class="ULock"></td>
        </tr>
        <tr>    
            <td align="center" class="bluetext"><font color=red>※</font>群組名稱</td>     
            <td class="bluedata" colspan=3><input id="tfx_GrpName" name="tfx_GrpName" size="30"> </td>     
        </tr>
        <tr>    
            <td align="center" class="bluetext"><font color=red>※</font>群組種類</td>     
            <td class="bluedata">
                <Select id="tfx_GrpType" name="tfx_GrpType" size="1">
                <option value="" style="color:blue">請選擇</option>
                <option value="N">正常登錄</option>
                <option value="X">暫停使用</option>
                </Select>
            </td>
            <td align="center" class="bluetext">首頁書面圖檔</td>     
            <td class="bluedata"><input id="tfx_HomeGif" name="tfx_HomeGif" size="10"> </td>     
        </tr>
        <tr>    
            <td align="center" class="bluetext">人員種類</td>     
            <td class="bluedata" colspan=3>
                <Select id="tfx_WorkType" name="tfx_WorkType" size="1">
                <option value="" style="color:blue">請選擇</option>
                <option value="sales">營洽</option>
                <option value="worker">承辦</option>
                </Select>
            </td>     
        </tr>      
        <tr>       
            <td align="center" class="bluetext">說明</td>      
            <td class="bluedata" colspan=3><input id="tfx_remark" name="tfx_remark" size="30"></td>      
        </tr>
        <tr>    
            <td align="center" class="bluetext"><font color=red>※</font>有效起始日期</td>
            <td class="bluedata"><input id="dfx_beg_date" name="dfx_beg_date" size="10" class="dateField"></TD>
            <td align="center" class="bluetext">有效結束日期</td>     
            <td class="bluedata"><input id="dfx_end_date" name="dfx_end_date" size="10" class="dateField"></TD>
        </tr>
        <tr>    
            <td align="center" class="bluetext">異動日期</td>     
            <td class="bluedata"><input type="text" id="xxx_tran_date" name="xxx_tran_date" size="10" class="Lock" ></TD>
            <td align="center" class="bluetext">異動薪號</td>     
            <td class="bluedata"><input type="text" id="xxx_tran_scode" name="xxx_tran_scode" size="10" class="Lock"></TD>
        </tr>
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
            $("#pfx_Syscode").val("<%#RS.TryGet("syscode","")%>");
            $("#pfx_LoginGrp").val("<%#RS.TryGet("LoginGrp","")%>");
            $("#tfx_GrpName").val("<%#RS.TryGet("GrpName","")%>");
            $("#tfx_GrpType").val("<%#RS.TryGet("GrpType","")%>");
            $("#tfx_HomeGif").val("<%#RS.TryGet("HomeGif","")%>");
            $("#tfx_WorkType").val("<%#RS.TryGet("WorkType","")%>");
            $("#tfx_remark").val("<%#RS.TryGet("remark","").ToString()%>");
            $("#dfx_beg_date").val("<%#Util.parseDBDate(RS.TryGet("beg_date","").ToString(),"yyyy/M/d")%>");
            $("#dfx_end_date").val("<%#Util.parseDBDate(RS.TryGet("end_date","").ToString(),"yyyy/M/d")%>");
            $("#xxx_tran_date").val("<%#Util.parseDBDate(RS.TryGet("tran_date","").ToString(),"yyyy/M/d")%>");
            $("#xxx_tran_scode").val("<%#RS.TryGet("tran_scode","").ToString()%>");
        } else {
            $("#pfx_Syscode").val("<%#syscode%>");
            $("#pfx_LoginGrp").val("<%#LoginGrp%>");
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
        if ($("#pfx_Syscode").val() == "") {
            alert("請務必填寫「網路作業系統代碼」，不得為空白！");
            $("#pfx_Syscode").focus();
            return false;
        }
        if ($("#pfx_LoginGrp").val() == "") {
            alert("請務必填寫「登錄群組代碼」，不得為空白！");
            $("#pfx_LoginGrp").focus();
            return false;
        }
        if ($("#tfx_GrpName").val() == "") {
            alert("請務必填寫「群組名稱」，不得為空白！");
            $("#tfx_GrpName").focus();
            return false;
        }
        if ($("#tfx_GrpType").val() == "") {
            alert("請務必填寫「群組種類」，不得為空白！");
            $("#tfx_GrpType").focus();
            return false;
        }
        if ($("#dfx_beg_date").val() == "") {
            alert("請務必填寫「有效起始日期」，不得為空白！");
            $("#dfx_beg_date").focus();
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
