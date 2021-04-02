<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data" %>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<script runat="server">
    protected string HTProgCap = "程序確認作業";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "Brt51";//程式檔名前綴
    protected string HTProgCode = "Brt51";//HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";
    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";
    protected string SQL = "";

    protected string td_tscode = "";

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

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
        //StrFormBtnTop += "<a class=\"imgRefresh\" href=\"javascript:void(0);\" >[重新整理]</a>\n";
        //StrFormBtnTop += "<a class=\"imgQry\" href=\"javascript:void(0);\" >[查詢條件]</a>\n";
        if ((HTProgRight & 2) > 0) {
            StrFormBtn += "<input type=\"button\" id=\"btnSrch\" value=\"查　詢\" class=\"cbutton bsubmit\" />\n";
            StrFormBtn += "<input type=\"button\" id=\"btnRest\" value=\"重　填\" class=\"cbutton\" />\n";
        }

        using (DBHelper conn = new DBHelper(Conn.btbrt).Debug(false)) {
            //營洽清單
            SQL = "select distinct a.case_in_scode,b.sc_name,b.sscode from todo_dmt a inner join sysctrl.dbo.scode b on a.case_in_scode=b.scode where a.job_status='NN' and a.dowhat='DC' order by sscode ";
            DataTable dtscode = new DataTable();
            conn.DataTable(SQL, dtscode);
            td_tscode = dtscode.Option("{case_in_scode}", "{sc_name}");
        }
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
        <table id="qryForm" border="0" class="bluetable" cellspacing="1" cellpadding="2" width="70%" align="center">	
	        <tr>
		        <td class="lightbluetable" align="right">洽案營洽:</td>
		        <td class="whitetablebg" align="left" colspan="3">
                    <select id='scode' name='scode' >
                        <%#td_tscode%>
                        <option value="*" style="color:blue" selected>全部</option>
                    </select>
                </td>
	        </tr>
	        <tr>
	            <td class=lightbluetable align=right>確認事項：</td>
	            <TD class=whitetablebg align=left>
	                <input type="radio" name=todo value="DC" checked>確認案件
	                <input type="radio" name=todo value="DP" >確認承辦修改
	            </TD>
	        </tr>
	        <TR>
		        <TD class=lightbluetable align=right>簽准日期：</TD>
		        <td class="whitetablebg" align="left" >
			        <input type="text" id="sdate" name="sdate" size="10" class="dateField">
                    ～
			        <input type="text" id="edate" name="edate" size="10" class="dateField">
		        </td>
	        </TR>
	        <TR>
		        <TD class=lightbluetable align=right>接洽序號：</TD>
		        <td class="whitetablebg" align="left" >
			        <input type="text" id="sin_no" name="sin_no" size="11" >
                    ～
			        <input type="text" id="ein_no" name="ein_no" size="11" >
		        </td>
	        </TR>	
        </table>
        <br>
        <table id="tabBtn" border="0" width="100%" cellspacing="0" cellpadding="0" align="center">
	        <tr><td width="100%" align="center">
			    <%#StrFormBtn%>
	        </td></tr>
        </table>
    </div>

    <%#DebugStr%>
</form>

<br />

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

        $("input.dateField").datepick();

        $("#sdate").val("<%#DateTime.Today.AddDays(-7).ToString("yyyy/M/d")%>");
        $("#edate").val("<%#DateTime.Today.ToString("yyyy/M/d")%>");
    }

    //////////////////////////////////////////////////////

    //[重填]
    $("#btnRest").click(function (e) {
        reg.reset();
        this_init();
    });

    $("#sdate,#edate").blur(function (e) {
        ChkDate(this);
    });

    //[查詢]
    $("#btnSrch").click(function (e) {
        if ($("#scode").val() == "") {
            if ($("#sfx_seq").val() == "") {
                alert("請選擇洽案營洽或全部!!");
                return false;
            }
        }

        reg.action = "<%=HTProgPrefix%>_List.aspx";
        reg.submit();
    });
</script>
