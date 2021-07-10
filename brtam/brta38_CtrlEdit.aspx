<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>

<script runat="server">
    protected string HTProgCap = "新增管制作業";//;//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "brta38";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";
    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";
    protected string SQL = "";
    protected string json = "";

    public Dictionary<string, string> Lock = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);

    protected string html_ctrl = "";
    protected string submittask = "";
    protected string pno = "";
    protected string step_sqlno = "";
    protected string sqlno = "";
    protected string seq = "";
    protected string seq1 = "";
    protected string step_grade = "";

    DBHelper conn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    private void Page_Unload(System.Object sender, System.EventArgs e) {
        if (conn != null) conn.Dispose();
    }

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");

        json = (Request["json"] ?? "").Trim().ToUpper();

        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        HTProgCap = myToken.Title;
        DebugStr = myToken.DebugStr;
        if (HTProgRight >= 0) {
                PageLayout();
            this.DataBind();
        }
    }

    private void PageLayout() {
        html_ctrl= Sys.getCustCode("CT", "", "").Option("{cust_code}", "{code_name}");
        
        submittask = (Request["submitTask"]??"").Trim();
        pno = (Request["pno"] ?? "").Trim();
        step_sqlno=(Request["step_sqlno"]??"").Trim();
        sqlno=(Request["sqlno"]??"").Trim();
        seq=(Request["seq"]??"").Trim();
        seq1=(Request["seq1"]??"").Trim();
        step_grade = (Request["step_grade"] ?? "").Trim();
    }
</script>
<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta http-equiv="x-ua-compatible" content="IE=10">
<title><%#HTProgCap%></title>
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
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/client_chk.js")%>"></script>
</head>

<body>
<table cellspacing="1" cellpadding="0" width="98%" border="0" align="center">
    <tr>
        <td class="text9" nowrap="nowrap">&nbsp;【<%#prgid%> <%#HTProgCap%>】</td>
        <td class="FormLink" valign="top" align="right" nowrap="nowrap">
            <a class="imgCls" href="javascript:void(0);" >[關閉視窗]</a>
            <%#StrFormBtnTop%>
        </td>
    </tr>
    <tr>
        <td colspan="2"><hr class="style-one"/></td>
    </tr>
</table>

<form id="reg" name="reg" method="post">
    <INPUT TYPE="hidden" id=prgid name=prgid value="<%=prgid%>">
    <INPUT TYPE="hidden" id=submittask name=submittask value="<%=submittask%>">
    <INPUT TYPE="hidden" id=pno name=pno value="<%=pno%>">
    <INPUT TYPE="hidden" id=step_sqlno name=step_sqlno value="<%=step_sqlno%>">
    <INPUT TYPE="hidden" id=sqlno name=sqlno value="<%=sqlno%>">

    <table cellspacing="1" cellpadding="0" width="98%" border="0">
	    <tr>
	        <td width="100%" colspan="6" height="245" valign="top" align="center">
				<input type=hidden id=ctrlnum name=ctrlnum value=0><!--管制筆數-->
				<TABLE id=tabbr1 border=0 class="bluetable"  cellspacing=1 cellpadding=2 width="70%">
					<TR>
						<TD class=lightbluetable align=right nowrap>本所編號：</TD>
						<TD class=greendata><%=Session["seBranch"]%><%=Sys.GetSession("dept").ToUpper()%>
							<input type=text size=6 maxlength="<%=Sys.DmtSeq%>" name=seq value="<%=seq%>" class="gSEdit" readonly>
							-<input type=text size=2 maxlength="<%=Sys.DmtSeq1%>" name=seq1 value="<%=seq1%>" class="gSEdit" readonly>
						</TD>
						<TD class=lightbluetable align=right nowrap>進度序號：</TD>
						<TD class=greendata>
							<input type=text size=6 maxlength=6 name=step_grade value="<%=step_grade%>" class="gSEdit" readonly>
						</TD>
					</TR>
				</Table>
                <br />
				<TABLE id=tabctrl border=0 class="bluetable"  cellspacing=1 cellpadding=2 width="100%">
                    <thead>
					<TR class=whitetablebg align=center>
						<TD colspan=7>
							<input type=button value ="增加一筆管制" class="cbutton" id=Add_button name=Add_button>
							<input type=button value ="減少一筆管制" class="cbutton" id=res_button name=res_button>
							<input type="hidden" name="rsqlno" id="rsqlno">
						</TD>
					</TR>
					<tr align="center" class="lightbluetable">
						<TD></TD><TD>管制種類</TD><TD>管制日期</TD><TD>說明</TD>
					</TR>
                    </thead>
                    <tbody></tbody>
                    <script type="text/html" id="ctrl_template"><!--類別樣板-->
		                <tr class="tr_ctrl_##">
				            <td class="whitetablebg" align="center">
                                <input type=hidden id='io_flg_##' name='io_flg_##' value=Y><!--可否修改-->
                                <input type=hidden id='ctrl_step_grade_##' name='ctrl_step_grade_##'><!--客收之對應官收法定期限進度序號-->
                                <input type=hidden id='ctrl_rs_no_##' name='ctrl_rs_no_##'><!--客收之對應官收法定期限收文字號-->
                                <input type=hidden id='sqlno_##' name='sqlno_##'><!--管制檔流水號-->
                                <input type=text id='ctrlnum_##' name='ctrlnum_##' class=sedit readonly size=2 value='##'>.
				            </td>
				            <td class="whitetablebg" align="center">
	                            <input type=hidden id='octrl_type_##' name='octrl_type_##'>
	                            <select id=ctrl_type_## name=ctrl_type_## ><%=html_ctrl%></select>
				            </td>
				            <td class="whitetablebg" align="center">
	                            <input type=hidden id='octrl_date_##' name='octrl_date_##'>
	                            <input type=text size=10 maxlength=10 id=ctrl_date_## name=ctrl_date_## class="dateField">
                            </td>
				            <td class="whitetablebg" align="center">
	                            <input type=hidden id='octrl_remark_##' name='octrl_remark_##'>
	                            <input type=text id='ctrl_remark_##' name='ctrl_remark_##' size=30 maxlength=60>
                            </td>
			            </tr>
                    </script>
				</Table>
                <br />
				<table width="100%" cellspacing="1" cellpadding="0" border="0">
					<tr align="center">
						<td>
							<input type=button class="cbutton" name="btnseq" value="確定" onclick="formupdate()">
							<input type=button class="cbutton" name="btnreset" value="重填" onclick="formreset()">
						</td>
					</tr>
				</table>
		    </td>
	    </tr>
    </table>
</form>

</body>
</html>


<script language="javascript" type="text/javascript">
    var rpno = $("#pno").val();
    $(function () {
        this_init();
    });

    function this_init() {
        if (window.parent.tt !== undefined) {
            window.parent.tt.rows = "100%,0%";
        }
        showctrl();
    }

    $('#tabctrl').on('blur', '.dateField', function () {
        ChkDate(this);
    });

    //顯示已暫存的資料
    function showctrl() {
        var pObject = opener;
        if (pObject === undefined) {
            pObject = parent;
        }

        //顯示已暫存的資料
        var arr_ctrl_type = $("#ctrl_type_" + rpno, pObject.document).val().split("︿");
        var arr_ctrl_date = $("#ctrl_date_" + rpno, pObject.document).val().split("︿");
        var arr_ctrl_remark = $("#ctrl_remark_" + rpno, pObject.document).val().split("︿");
        $.each(arr_ctrl_type, function (index, value) {
            var ipno = (index + 1);
            if (arr_ctrl_type[index] != "" && arr_ctrl_date[index] != "") {
                $("#Add_button").click();
                $("#ctrl_type_" + ipno).val(arr_ctrl_type[index]);
                $("#ctrl_date_" + ipno).val(arr_ctrl_date[index]);
                $("#ctrl_remark_" + ipno).val(arr_ctrl_remark[index]);
            }
        });

        if ($("#ctrlnum").val() == "0") {
            $("#Add_button").click();
        }
    }

    //增加一筆管制
    $("#Add_button").click(function (e) {
        var nRow = CInt($("#ctrlnum").val()) + 1;
        //複製樣板
        var copyStr = $("#ctrl_template").text() || "";
        copyStr = copyStr.replace(/##/g, nRow);
        $("#tabctrl tbody").append(copyStr);
        $("#ctrlnum").val(nRow);
        $(".dateField", $('.tr_ctrl_' + nRow)).datepick();
    });

    //減少一筆管制
    $("#res_button").click(function (e) {
        var nRow = CInt($("#ctrlnum").val());
        $('.tr_ctrl_' + nRow).remove();
        $("#ctrlnum").val(Math.max(0, nRow - 1));
    });

    //[重填]
    function formreset() {
        reg.reset();
        this_init();
    }

    //[確認]
    function formupdate() {
        var pObject = opener;
        if (pObject === undefined) {
            pObject = parent;
        }

        var ctrl_typeStr = "";
        var ctrl_dateStr = "";
        var ctrl_remarkStr = "";
        var addCount = 0;
        var msg = "";
        for (var pno = 1; pno <= $("#ctrlnum").val() ; pno++) {
            if ($("#ctrl_type_" + pno).val() != "" && $("#ctrl_date_" + pno).val() != "") {
                ctrl_typeStr += "︿" + $("#ctrl_type_" + pno).val();
                ctrl_dateStr += "︿" + $("#ctrl_date_" + pno).val();
                ctrl_remarkStr += "︿" + $("#ctrl_remark_" + pno).val();
                addCount++;
            } else {
                msg += "第" + pno + "筆 管制種類/管制日期 須輸入\n";
            }
        }

        if (msg != "") {
            alert(msg);
            return false;
        }

        $("#ctrl_type_" + rpno, pObject.document).val(ctrl_typeStr.substr(1));
        $("#ctrl_date_" + rpno, pObject.document).val(ctrl_dateStr.substr(1));
        $("#ctrl_remark_" + rpno, pObject.document).val(ctrl_remarkStr.substr(1));

        if (addCount == 0) {
            $("#ctrl_" + rpno, pObject.document).text("[新增]");
        } else {
            $("#ctrl_" + rpno, pObject.document).text("[新增(" + addCount + ")]");
        }

        $(".imgCls").click();
    }
</script>
