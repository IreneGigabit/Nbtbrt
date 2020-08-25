<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Linq" %>

<script runat="server">
    protected string HTProgCap = "複製權限群組";//HttpContext.Current.Request["prgname"];//功能名稱
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
    protected int count = 0;

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
            QueryData();
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

        if ((HTProgRight & 4) > 0) {
            StrFormBtn += "<input type=button value=\"複製存檔\" class=\"cbutton\" id=\"btnSubmit\">\n";
            StrFormBtn += "<input type=button value=\"重　填\" class=\"cbutton\" id=\"btnReset\">\n";
        }
    }
    
    private void QueryData() {
        using (DBHelper cnn = new DBHelper(Conn.ODBCDSN, false).Debug(Request["chkTest"] == "TEST")) {
            SQL = "SELECT * ";
            SQL += "FROM logingrp A ";
            SQL += "WHERE a.syscode = '" + syscode + "' ";
            SQL += " order by A.LoginGrp";
            DataTable dt = new DataTable();
            cnn.DataTable(SQL, dt);

            count = dt.Rows.Count;
            
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
	<input type="hidden" id="count" name="count" value="<%=count%>">

    <table align="center" border="0" cellspacing="1" cellpadding="3" width="30%" class="bluetable">
        <tr>    
            <td align="center" class="lightbluetable" width="30%">權限來源</td>
            <td class="whitetablebg">
                <Select id=tfx_source name=tfx_source></Select>
            </td>
        </tr>
    </table>
    <br />
    <asp:Repeater id="dataRepeater" runat="server">
<HeaderTemplate>
    <table border="0" class="bluetable" cellspacing="1" cellpadding="2" width="50%" align="center" id="dataList">
	    <thead>
            <tr>    
                <td align="center" class="lightbluetable" colspan=2>權限目的</td>
            </tr>
	    </thead>
	    <tbody>
</HeaderTemplate>
			<ItemTemplate>
	         <tr>
		        <td class="whitetablebg" width="50%">
		            <label><input type=checkbox id="LG" name="chk_<%#(Container.ItemIndex+1)%>" value="Y">
                    <%#Eval("LoginGrp").ToString().Trim()%>_<%#Eval("GrpName").ToString().Trim()%></label>
		            <input type=hidden id="loginGrpData_<%#(Container.ItemIndex+1)%>" name="loginGrpData_<%#(Container.ItemIndex+1)%>" value="<%#Eval("LoginGrp")%>">
		        </td>
		        <td class="whitetablebg" width="50%">
		            <a href="javascript:openW('<%#Eval("Syscode").ToString().Trim()%>','<%#Eval("LoginGrp").ToString().Trim()%>')">查詢使用者</a>
		        </td>
	        </tr>
			</ItemTemplate>
<FooterTemplate>
	    </tbody>
    </table>
    <br />
</FooterTemplate>
</asp:Repeater>

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

        $("#tfx_source").getOption({//權限來源
            url: getRootPath() + "/ajax/JsonGetSqlDataCnn.aspx",
            data: { mg: "Y", sql: "select LoginGrp,GrpName from logingrp where SYScode = '" + $("#syscode").val() + "' order by LoginGrp" },
            valueFormat: "{LoginGrp}",
            textFormat: "{LoginGrp}_{GrpName}"
        });

        $("#tfx_source").val($("#LoginGrp").val());
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

    //複製存檔
    $("#btnSubmit").click(function () {
        var errMsg = "";

        if ($("#tfx_source").val() == "") {
            alert("權限來源..未選取！");
            $("#tfx_source").focus();
            return false;
        }

        $("input[id='LG']").each(function (i) {
            if ($(this).prop("checked")) {
                if ($("#tfx_source").val() == $("#loginGrpData_" + (i + 1)).val()) {
                    alert("權限來源與目的不能相同!!");
                    $(this).focus();
                    return false;
                }
            }
        });

        var check = $("input[id='LG']:checked").length;
        if (check == 0) {
            alert("權限目的..未勾選任何資料!!");
            return false;
        }

        $("select,textarea,input,span").unlock();
        $("#btnSubmit,#btnDel,#btnReset").lock(!$("#chkTest").prop("checked"));
        $("#task").val("C");
        reg.action = "<%=HTProgPrefix%>_Update.aspx";
        reg.target = "ActFrame";
        reg.submit();
    });

    //重置
    $("#btnReset").click(function () {
        reg.reset();
        this_init();
    });

    function openW(x1, x2) {
        var url='sys14_List.aspx?prgid=' + $("#prgid").val() + '&Syscode=' + x1 + '&LoginGrp=' + x2 + '&ff=1';
        //var attwnd = OpenWnd('Attach', 'sys14_List.aspx?prgid=' + $("#prgid").val() + '&Syscode=' + x1 + '&LoginGrp=' + x2 + '&ff=1', 600, 400, 1);
        window.open(url, 'sys14Win', "width=600,height=400,resizable=yes,scrollbars=no,status=0,top=80,left=200");
    }
</script>
