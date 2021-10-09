<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data" %>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<script runat="server">
    protected string HTProgCap = "請款綜合查詢作業";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "ext76";//HttpContext.Current.Request["prgid"] ?? "";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";
    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";
    protected string SQL = "";

    protected string homelist = "",ar_type="";
    protected string td_scode = "", html_in_scode = "";

    DBHelper connacc = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    DBHelper cnn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    private void Page_Unload(System.Object sender, System.EventArgs e) {
        if (connacc != null) connacc.Dispose();
        if (cnn != null) cnn.Dispose();
    }

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        connacc = new DBHelper(Conn.account).Debug(Request["chkTest"] == "TEST");
        cnn = new DBHelper(Conn.Sysctrl).Debug(Request["chkTest"] == "TEST");

        homelist = (Request["homelist"] ?? "").ToLower();
        ar_type = (Request["ar_type"] ?? "").ToUpper();
         
        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        //HTProgCap = myToken.Title;
        DebugStr = myToken.DebugStr;
        if (HTProgRight >= 0) {
            PageLayout();
            this.DataBind();
        }
    }

    private void PageLayout() {
        //StrFormBtnTop += "<a class=\"imgRefresh\" href=\"javascript:void(0);\" >[重新整理]</a>\n";
        //StrFormBtnTop += "<a class=\"imgQry\" href=\"javascript:void(0);\" >[查詢條件]</a>\n";
        if ((HTProgRight & 2) > 0) {
            StrFormBtn += "<input type=\"button\" id=\"btnSrch\" value=\"查　詢\" class=\"cbutton bsubmit\" />\n";
            StrFormBtn += "<input type=\"button\" id=\"btnRest\" value=\"重　填\" class=\"cbutton\" />\n";
            StrFormBtn += "<input type=\"button\" id=\"btnPre\" value=\"預計請款記錄\" class=\"cbutton bsubmit\" />\n";
        }

        //營洽清單
        DataTable dtscode = new DataTable();
        SQL = "select distinct scode,sc_name,scode1 from vscode_roles ";
        SQL += " where branch='" + Session["SeBranch"] + "' and dept='" + Session["Dept"] + "' and syscode='" + Session["syscode"] + "' and roles='sales'";
        SQL += " order by scode1 ";
        cnn.DataTable(SQL, dtscode);
        if ((HTProgRight & 64) != 0) {
            td_scode = "<select id='Scode' name='Scode'>";
            td_scode += dtscode.Option("{scode}", "{scode}_{sc_name}", true, Sys.GetSession("scode"));
            td_scode += "<option value=\"*\" style=\"color:blue\">全部</option>";
            td_scode += "</select>";
        } else {
            td_scode = "<input type='hidden' id='Scode' name='Scode' value='" + Session["scode"] + "'>";
            td_scode += "<input type='text' id='ScodeName' name='ScodeName' readonly class='SEdit' value='" + Session["sc_name"] + "'>";
        }

        //開單人員
        SQL = "select distinct in_scode,(select sc_name from sysctrl.dbo.scode where scode= artmain.in_scode) as in_name from artmain where ar_type = '" + ar_type + "' order by in_scode";
        html_in_scode = Util.Option(connacc, SQL, "{in_scode}", "{in_name}", true);
    }
</script>
<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title><%#HTProgCap%></title>
    <uc1:head_inc_form runat="server" ID="head_inc_form" />
</head>

<body>
<table cellspacing="1" cellpadding="0" width="98%" border="0" align="center">
    <tr>
        <td class="text9" nowrap="nowrap">&nbsp;【<%#prgid%> <%#HTProgCap%>】</td>
        <td class="FormLink" valign="top" align="right" nowrap="nowrap">
            <%#StrFormBtnTop%>
        </td>
    </tr>
    <tr>
        <td colspan="2"><hr class="style-one"/></td>
    </tr>
</table>

<form id="reg" name="reg" method="post">
    <input type="hidden" id="homelist" name="homelist" value="<%=homelist%>">
    <input type="hidden" id="prgid" name="prgid" value="<%=prgid%>">
    <input type="hidden" name="qs_dept" value="<%=Request["qs_dept"]%>">

    <div id="id-div-slide">
        <table id="qryForm" border="0" class="bluetable" cellspacing="1" cellpadding="2" width="90%" align="center">	
	        <tr>
		        <TD class=lightbluetable align=right>查詢種類：</TD>
		        <TD class=whitetablebg align=left colspan="3">
		            <label><input type=radio name=todo value="X" checked onclick="todo_chk('X')">交辦尚未請款完畢</label>
		            <label><input type=radio name=todo value="N" onclick="todo_chk('N')">已開立未送確認請款單</label>
		            <label><input type=radio name=todo value="Y" onclick="todo_chk('N')">會計未確認請款單</label>
		            <label><input type=radio name=todo value="Z" onclick="todo_chk('N')">會計已確認請款單</label>
		            <label><input type=radio name=todo value="S" onclick="todo_chk('N')">已寄出請款單</label>
		            <label><input type=radio name=todo value="U" onclick="todo_chk('N')">不指定</label>
		        </TD>
	        </tr>
            <TR>
                <td class="lightbluetable" align="right">營洽人員 :</td>
		        <TD class=whitetablebg align=left colspan=3><%#td_scode%></TD>
            </TR>
	        <tr id=show_inscode>
		        <td class=lightbluetable align=right>開單人員：</td>
		        <TD class=whitetablebg align=left colspan="3"><Select NAME=in_scode id=in_scode><%#html_in_scode%></select></TD>
	        </tr>
	        <TR>
		        <TD class=lightbluetable align=right >請款客戶：</TD>
		        <TD class=whitetablebg align=left width="25%">
                    <INPUT type=text id="branch" name="branch" value="<%=Session["seBranch"]%>" class="Lock" size="1">-<INPUT type="text" id="acust_seq" name="acust_seq" size="10">
		        </TD>
		        <TD class=lightbluetable align=right width="20%">客戶名稱：</TD>
		        <TD class=whitetablebg align=left><INPUT type="text" id="cust_name" name="cust_name" size="10"></TD>
	        </TR>
	        <TR id=show_seq>
		        <TD class=lightbluetable align=right >本所編號：</TD>
		        <TD class=whitetablebg align=left colspan=3><INPUT type=text id="bseq" name="bseq" size="5">~<INPUT type="text" id="eseq" name="eseq" size="5" ></TD>		
	        </TR>
	        <tr id=show_armark>
		        <TD class=lightbluetable align=right >請款單種類：</TD>
		        <TD class=whitetablebg align=left colspan="3">
		            <label><input type=radio name=ar_mark value="A" title="一般請款單" checked>一般+實報實銷案件</label>
		            <label><input type=radio name=ar_mark value="D" title="此請款單為扣收入，不寄給客戶">扣收入案件(不開收據)</label>
		        </TD>
	        </tr>
	        <tr id=show_casedate>
		        <TD class=lightbluetable align=right >交辦期間：</TD>
		        <TD class=whitetablebg align=left colspan="3">
		            <input type="text" name="Scdate" id="Scdate" size="10" readonly class="dateField">～
		            <input type="text" name="Ecdate" id="Ecdate" size="10" readonly class="dateField">
		            <label><input type="checkbox" name="case_chk" id="case_chk" checked>不指定</label>
		        </TD>
	        </tr>
	        <tr id=show_feestat>
		        <TD class=lightbluetable align=right >規費支出：</TD>
		        <TD class=whitetablebg align=left colspan="3">
		            <label><input type=radio name=spkind value="gs_fees" >已支出</label>
		            <label><input type=radio name=spkind value="N">未支出</label>
		            <label><input type=radio name=spkind value="" checked>不指定</label>
		        </TD>
	        </tr>
	        <tr id=show_arno>
		        <TD class=lightbluetable align=right >請款單號：</TD>
		        <TD class=whitetablebg align=left colspan="3">
		            <input type=text id=bar_no name=bar_no size=10>～<input type=text id=ear_no name=ear_no size=10>
		        </TD>
	        </tr>
	        <tr id=show_datatype>
		        <TD class=lightbluetable align=right >日期種類：</TD>
		        <TD class=whitetablebg align=left colspan="3">
		            <label><input type=radio name=todate value="in_date" checked>開單日期</label>
		            <label><input type=radio name=todate value="ar_date">請款日期</label>
		            <label><input type=radio name=todate value="conf_date">確認日期</label>
		            <label><input type=radio name=todate value="mail_date">寄出日期</label>
		        </TD>
	        </tr>
	        <tr id=show_datarange>
		        <td class="lightbluetable" align="right">日期範圍：</td>
		        <td class="whitetablebg" align="left" colspan=3>
		            <input type="text" name="Sdate" id="Sdate" size="10" class="dateField">～
		            <input type="text" name="Edate" id="Edate" size="10" class="dateField">
		        </td>
	        </tr>
        </table>
        <br>
        <%#DebugStr%>
        <table id="tabBtn" border="0" width="100%" cellspacing="0" cellpadding="0" align="center">
	        <tr><td width="100%" align="center">
			    <%#StrFormBtn%>
	        </td></tr>
        </table>
    </div>
</form>

<div id="dialog"></div>

</body>
</html>


<script language="javascript" type="text/javascript">
    $(function () {
        this_init();
    });

    function this_init() {
        if (window.parent.tt !== undefined) {
            window.parent.tt.rows = "100%,0%";
        }

        $(".Lock").lock();
        $("input.dateField").datepick();
        $("#Sdate").val("<%#DateTime.Today.ToString("yyyy/M/1")%>");
        $("#Edate").val("<%#DateTime.Today.ToShortDateString()%>");
        $("input[name='todo']:checked").triggerHandler("click");
    }

    $(".dateField").blur(function (e) {
        ChkDate(this);
    });
    //////////////////////////////////////////////////////

    //[重填]
    $("#btnRest").click(function (e) {
        reg.reset();
        this_init();
    });

    //查詢種類
    function todo_chk(t) {
        if (t == "X") {//交辦尚未請款完畢
            $("#show_inscode").hide();//開單人員
            $("#show_seq").show();//本所編號
            $("#show_armark").show();//請款單種類
            $("#show_casedate").show();//交辦期間
            $("#show_feestat").show();//規費支出
            $("#show_arno").hide();//請款單號
            $("#show_datatype").hide();//日期種類
            $("#show_datarange").hide();//日期範圍
        } else {
            $("#show_inscode").show();//開單人員
            $("#show_seq").show();//本所編號
            $("#show_armark").hide();//請款單種類
            $("#show_casedate").hide();//交辦期間
            $("#show_feestat").hide();//規費支出
            $("#show_arno").show();//請款單號
            $("#show_datatype").show();//日期種類
            $("#show_datarange").show();//日期範圍
        }
    }

    //交辦期間:不指定
    $("#case_chk").click(function () {
        if ($(this).prop("checked") == true) {
            $("#Scdate,#Ecdate").val("");
        } else {
            $("#Scdate").val(Today().format("yyyy/M/1"));
            $("#Ecdate").val(Today().format("yyyy/M/d"));
        }
    });


    //[查詢]
    $("#btnSrch").click(function (e) {
        if ($("input[name=todo][value='X']").prop("checked") == true) {//交辦尚未請款完畢
            if ($("#Scode").val() == "") {
                alert("請選擇營洽人員！");
                return false;
            }
        }

        if ($("#eseq").val() == "" && $("#bseq").val() != "") {
            $("#eseq").val($("#bseq").val());
        }

        //if ($("input[name=todo][value='X']").prop("checked") == true) {
            reg.action = "<%=HTProgPrefix%>_List.aspx";//未開立請款單案件查詢
        //} else {
        //    reg.action = "<%=HTProgPrefix%>_List1.aspx";//已開立請款單案件查詢
        //}
        reg.submit();
    });

    //[預計請款記錄]
    $("#btnPre").click(function (e) {
        if ($("input[name=todo][value='X']").prop("checked") == true) {//交辦尚未請款完畢
            if ($("#Scode").val() == "") {
                alert("請選擇營洽人員！");
                return false;
            }
        }

        if ($("#eseq").val() == "" && $("#bseq").val() != "") {
            $("#eseq").val($("#bseq").val());
        }

        reg.action = "<%=HTProgPrefix%>_List2.aspx?qryform=Y";
        reg.submit();
    });

    $("#bar_no").blur(function (e) {
        $("#ear_no").val($("#bar_no").val());
    });
</script>
