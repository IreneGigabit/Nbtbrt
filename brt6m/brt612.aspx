<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data" %>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<script runat="server">
    protected string HTProgCap = "國內案文件掃描單列印作業";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = HttpContext.Current.Request["prgid"] ?? "";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";
    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";
    protected string SQL = "";

    protected string html_in_scode = "";

    DBHelper conn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    private void Page_Unload(System.Object sender, System.EventArgs e) {
        if (conn != null) conn.Dispose();
    }

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
        
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
        if ((HTProgRight & 2) > 0) {
            StrFormBtn += "<input type=\"button\" id=\"btnSrch\" value=\"查詢\" class=\"cbutton bsubmit\" />\n";
            StrFormBtn += "<input type=\"button\" id=\"btnRest\" value=\"重填\" class=\"cbutton\" />\n";
        }

        //新增人員
        SQL = "select A.in_scode,d.sc_name ";
        SQL+= "from dmt_attach A inner join sysctrl.dbo.scode D on a.in_scode = d.scode ";
        SQL+= "where attach_flag<>'D' and source='scan' ";
        SQL+= "group by a.in_scode,d.sc_name";
        DataTable dtscode = new DataTable();
        conn.DataTable(SQL, dtscode);
        html_in_scode = dtscode.Option("{in_scode}", "{in_scode}_{sc_name}");
    }
</script>
<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
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
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/jquery.irene.form.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/client_chk.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/jquery.Snoopy.date.js")%>"></script>
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
    <input type="hidden" id="prgid" name="prgid" value="<%=prgid%>">

    <div id="id-div-slide">
        <table id="qryForm" border="0" class="bluetable" cellspacing="1" cellpadding="2" width="50%" align="center">	
		    <tr align=center id="tr_seq">
			    <td class="lightbluetable" align="right" nowrap>本所編號：</td>
			    <td class="whitetablebg" align="left" >	
				    <input type="text" name="qrybSeq" id="qrybSeq" size="<%#Sys.DmtSeq%>" maxlength=<%#Sys.DmtSeq%>> ~
                    <input type="text" name="qryeSeq" id="qryeSeq"  size="<%#Sys.DmtSeq%>" maxlength=<%#Sys.DmtSeq%>>
                    - <input type="text" name="qrySeq1" id="qrySeq1" size="2">
			    </td>
			    <td class="lightbluetable" align="right" nowrap>進度序號：</td>
			    <td class="whitetablebg" align="left" >	
				    <input type="text" name="qryStep_grade" id="qryStep_grade" size="5" maxlength="5">
			    </td>
		    </tr>
		    <TR id="tr_in_scode">
			    <TD class=lightbluetable align=right>新增人員：</TD>
			    <TD class=whitetablebg align=left colspan="5">
				    <Select name="qryin_scode" id="qryin_scode">
					     <%#html_in_scode%>
				    </Select>
			    </TD>
		    </TR>
		    <TR id="tr_in_date">
			    <TD class=lightbluetable align=right>新增日期：</TD>
			    <TD class=whitetablebg align=left colspan="5">
			        <input type="text" name="qrydateS" id="qrydateS" size="10" class="dateField"> ~
			        <input type="text" name="qrydateE" id="qrydateE" size="10" class="dateField">
			        <label><input type=checkbox name=qrychkdate id=qrychkdate >不指定</label>
			    </TD>
		    </TR>
		    <TR >
			    <TD class=lightbluetable align=right>列印方式：</TD>
			    <TD class=whitetablebg align=left colspan="5">
			        <label><input type="radio" name="qrytype" value="pr" checked>承辦單</label>
			    </TD>
		    </TR>
		    <TR >
			    <TD class=lightbluetable align=right>掃描狀態：</TD>
			    <TD class=whitetablebg align=left colspan="5">
			        <input type="hidden" name="hchk_status" id="hchk_status" value="N">
			        <label><input type="radio" name="qrychk_status" value="N" checked>未掃描確認</label>
			        <label><input type="radio" name="qrychk_status" value="Y">已掃描確認</label>
			    </TD>
		    </TR>
		    <TR id="tr_from_flag">
			    <TD class=lightbluetable align=right>排序：</TD>
			    <TD class=whitetablebg align=left colspan="5">
				    <Select name="qryOrder" id="qryOrder">
					    <option value="a.seq,a.seq1 asc">案件編號
					    <option value="a.seq,a.seq1 asc,a.step_grade desc ">案件編號+進度序號
				    </Select>
			    </TD>
		    </TR>
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

<iframe id="ActFrame" name="ActFrame" src="about:blank" width="100%" height="500" style="display:none"></iframe>
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

        $("input.dateField").datepick();

        $("#qrySeq1").val("_");
        $("#qrychkdate").triggerHandler("click");
    }

    //[重填]
    $("#btnRest").click(function (e) {
        reg.reset();
        this_init();
    });

    //////////////////////////////////////////////////////

    //新增日期
    $("#qrychkdate").click(function (e) {
        if ($(this).prop("checked") == false) {
            $("#qrydateS").val(Today().format("yyyy/M/d"));
            $("#qrydateE").val(Today().format("yyyy/M/d"));
        } else {//不指定
            $("#qrydateS").val("");
            $("#qrydateE").val("");
        }
    });

    //掃描狀態
    $("input[name='qrychk_status']").click(function (e) {
        $("#hchk_status").val($(this).val());
    });
    
    //[列印]
    $("#btnSrch").click(function (e) {
        if ($("#qrybSeq").val() == "" && $("#qryeSeq").val() == "" && $("#qrySeq1").val() == ""
            && $("#qryin_scode").val() == "" && $("#qrydateS").val() == "" && $("#qrydateE").val() == "") {
            alert("請輸入任一條件!!");
            ("#qrybSeq").focus
            return false;
        }

        if ($("#qrybSeq").val() != "") {
            if ($("#qryeSeq").val() == "") {
                $("#qryeSeq").val($("#qrybSeq").val());
            }
        }

        var url = "json_data612.aspx?sdate=" + $("#qrydateS").val() + "&edate=" + $("#qrydateE").val() + "&seq1=" + $("#qrySeq1").val() +
            "&in_scode=" + $("#qryin_scode").val() + "&step_grade=" + $("#qryStep_grade").val() + "&chk_status=" + $("#hchk_status").val() +
            "&bseq=" + $("#qrybSeq").val() + "&eseq=" + $("#qryeSeq").val();
        ajaxScriptByGet("檢查承辦單筆數", url);
        if (jCount == 0) {//由ajaxScriptByGet呼叫的程式指定值
            alert("無資料需產生");
        } else if (jCount > 50) {
            alert("承辦單超過50筆，請縮小範圍列印!!!");
            return false;
        }

        reg.target = "ActFrame";
        reg.action = "brt612Print.aspx";
        reg.submit();
    });
</script>
