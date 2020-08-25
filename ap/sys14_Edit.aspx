<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Linq" %>

<script runat="server">
    protected string HTProgCap = "使用者系統控制";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "Sys14";//HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = HttpContext.Current.Request["prgid"] ?? "";//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";
    protected string Title = "";
    protected string StrFormBtn = "";

    protected string submitTask = "";
    protected string syscode = "";
    protected string LoginGrp = "";
    protected string sqlno = "";

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
        sqlno = Request["sqlno"] ?? "";

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
            SQL = "SELECT * FROM Sysctrl WHERE sqlno='" + sqlno + "'";
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
            StrFormBtn += "<input type=button value=\"回前頁\" class=\"cbutton\" id=\"btnBack\">\n";
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
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/jquery.autocomplete.js")%>"></script>
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
	<input type="hidden" id="sqlno" name="sqlno" value="<%=sqlno%>">

    <table border="0" class="bluetable" cellspacing="1" cellpadding="2" width="80%" align="center">	
        <TR>
            <TD width="20%" class=bluetext align=right>使用者薪號：</TD>
            <TD colspan="3" class=bluedata>
                <input type=text id=tfx_scode name=tfx_scode size=10 maxlength=10>
                <span id="xxx_scname"></span>
            </TD>		
        </tr>
        <tr>  
            <TD width="20%"  class=bluetext align=right>單位別：</TD>
            <TD width="30%"  class=bluedata>
                <select id="tfx_branch" NAME="tfx_branch" size=1></select>
            </TD>
            <TD width="20%"  class=bluetext align=right>部門別：</TD>
            <TD width="30%" class=bluedata>
                <select id=tfx_dept NAME=tfx_dept>
                    <option value="">請選擇</option>
                    <option value="T">商標</option>
                    <option value="P">專利</option>
                    <option value="L">法律</option>
                </select>
            </TD>
        </TR>
        <TR>
            <TD  width="20%" class=bluetext align=right>是否為預設網頁：</TD>
            <TD  colspan="3" class=bluedata>&nbsp
                <label><INPUT TYPE="radio" NAME="tfx_sysdefault" id="sysdefaultY" value="Y" >是</label>&nbsp&nbsp
                <label><INPUT TYPE="radio" NAME="tfx_sysdefault" id="sysdefaultN" value="N" >否</label>
            </TD>
        </TR>
        <TR>
            <TD width="20%" class=bluetext align=right>網路作業系統代碼：</TD>
            <TD width="30%" class=bluedata>
                <select id="tfx_syscode"  NAME="tfx_syscode"></select>
            </TD>
            <TD width="20%" class=bluetext align=right>登錄群組代碼：</TD>
            <TD width="30%" class=bluedata>
                <select id="tfx_logingrp" NAME="tfx_logingrp"></select>
            </TD>
        </tr>
        <tr>
            <td align="right" class="bluetext">有效起始日期：</td>
            <td class="bluedata"><input id="dfx_beg_date" name="dfx_beg_date" size="10" class="dateField"></TD>
            <td align="right" class="bluetext">有效結束日期：</td>
            <td class="bluedata"><input id="dfx_end_date" name="dfx_end_date" size="10" class="dateField"></TD>
        </tr>
        <TR>  
            <TD width="20%" class=bluetext align=right>備註：</TD>
            <TD class=bluedata colspan=3><INPUT TYPE=text id=tfx_mark NAME=tfx_mark SIZE=1 MAXLENGTH=1 /></TD>
        </TR>
        <tr>    
            <td align="right" class="bluetext">異動日期：</td>
            <td class="bluedata" colspan="3"><input type="text" id="xxx_tran_date" name="xxx_tran_date" size="10" class="Lock" ></TD>
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
            window.parent.tt.rows = "30,70%";
        }

        $("#tfx_branch").getOption({//單位別
            url: getRootPath() + "/ajax/JsonGetSqlDataCnn.aspx",
            data: { mg: "Y", sql: "select branch,branchname from branch_code order by branch" },
            valueFormat: "{branch}",
            textFormat: "{branch}_{branchname}"
        });

        $("#tfx_syscode").getOption({//網路作業系統代碼
            url: getRootPath() + "/ajax/JsonGetSqlDataCnn.aspx",
            data: { mg: "Y", sql: "select syscode,sysnameC From syscode order by syscode" },
            valueFormat: "{syscode}",
            textFormat: "{syscode}_{sysnameC}"
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
                window.parent.tt.rows = "30%,70%";
            }
            $("#sqlno").val("<%#RS.TryGet("sqlno","")%>");
            $("#tfx_scode").val("<%#RS.TryGet("scode","")%>");
            $("#tfx_branch").val("<%#RS.TryGet("branch","")%>");
            $("#tfx_dept").val("<%#RS.TryGet("dept","")%>");
            $("input[name='tfx_sysdefault'][value='<%#RS.TryGet("sysdefault","")%>']").prop("checked", true);
            $("#tfx_syscode").val("<%#RS.TryGet("syscode","")%>").triggerHandler("change");
            $("#tfx_logingrp").val("<%#RS.TryGet("logingrp","")%>");
            $("#dfx_beg_date").val("<%#Util.parseDBDate(RS.TryGet("beg_date","").ToString(),"yyyy/M/d")%>");
            $("#dfx_end_date").val("<%#Util.parseDBDate(RS.TryGet("end_date","").ToString(),"yyyy/M/d")%>");
            $("#tfx_mark").val("<%#RS.TryGet("mark","")%>");
            $("#xxx_tran_date").val("<%#Util.parseDBDate(RS.TryGet("tran_date","").ToString(),"yyyy/M/d")%>");
            $("#xxx_tran_scode").val("<%#RS.TryGet("tran_scode","").ToString()%>");
        } else {
            if (window.parent.tt !== undefined) {
                window.parent.tt.rows = "0%,100%";
            }
            $("#tfx_syscode").val("<%#syscode%>").triggerHandler("change");
            $("#tfx_logingrp").val("<%#LoginGrp%>");
            $("#dfx_beg_date").val((new Date()).format("yyyy/M/d"));
        }
    }

    //關閉視窗
    $(".imgCls,#btnClose").click(function (e) {
        if (window.parent.tt !== undefined) {
            if (window.parent.Etop.goSearch !== undefined) {
                window.parent.Etop.goSearch();
            }
            window.parent.tt.rows = "100%,0%";
        } else {
            window.close();
        }
    })

    //回前頁
    $(".btnBack,#btnBack").click(function (e) {
        history.go(-1);
    })

    //新增/修改
    $("#btnSubmit").click(function () {
        if ($("#tfx_scode").val() == "") {
            alert("請務必填寫「薪號」，不得為空白！");
            $("#pfx_Syscode").focus();
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

    //依系統代碼帶Apcat/LoginGrp
    $("#tfx_syscode").change(function () {
        $("#tfx_logingrp").getOption({//登錄群組代碼：
            url: getRootPath() + "/ajax/JsonGetSqlDataCnn.aspx",
            data: { mg: "Y", sql: "select LoginGrp,GrpName from logingrp where SYScode = '" + $("#syscode").val() + "' order by LoginGrp" },
            valueFormat: "{LoginGrp}",
            textFormat: "{LoginGrp}_{GrpName}"
        });
    });
    $(document).unbind();//autocomplete畫面會一直閃
    //查姓名
    $('#tfx_scode').autocomplete({
        width: 150,
        noCache:true,
        serviceUrl: getRootPath() + "/ajax/json_get_scode.aspx",
        onSelect: function (suggestion) {
            $(this).val(suggestion.scode);
            $("#xxx_scname").html(suggestion.sc_name);
        },
        onSearchStart: function (suggestion) {
            $("#xxx_scname").html("");
        }
    });
</script>
