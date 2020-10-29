<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data" %>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<script runat="server">
    protected string HTProgCap = "";//"國內案編修暨交辦作業";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "brt12";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = HttpContext.Current.Request["prgid"] ?? "";//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";
    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";
    protected string SQL = "";

    protected string td_tscode = "";
    protected string pfx_Arcase = "";

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
        StrFormBtnTop += "<a href=\"" + Page.ResolveUrl("~/Brt4m/Brt13.aspx") + "?prgid=" + HTProgPrefix + "\">[交辦查詢]</a>\n";
        StrFormBtnTop += "<a href=\"" + Page.ResolveUrl("~/cust/cust11_1.aspx") + "?gs_dept=" + Session["Dept"] + "\">[客戶查詢]</a>\n";
        StrFormBtnTop += "<a href=\"" + Page.ResolveUrl("~/cust/cust11.aspx") + "?gs_dept=" + Session["Dept"] + "\">[客戶新增]</a>\n";

        if ((HTProgRight & 2) > 0) {
            StrFormBtn += "<input type=\"button\" id=\"btnSrch\" value=\"查　詢\" class=\"cbutton bsubmit\" />\n";
            StrFormBtn += "<input type=\"button\" id=\"btnRest\" value=\"重　填\" class=\"cbutton\" />\n";
        }

        using (DBHelper conn = new DBHelper(Conn.btbrt).Debug(false)) {
            //抓取組主管所屬營洽
            string sales_scode = Sys.getScode(Sys.GetSession("SeBranch"), Sys.GetSession("scode"));

            //洽案營洽清單
            DataTable dt = new DataTable();
            if ((HTProgRight & 128) != 0) {
                //權限B為全部，for程序主管為營助職務代理可看全部營洽
                SQL = "select distinct a.in_scode,b.sc_name,b.sscode ";
                SQL += "from case_dmt a ";
                SQL += "inner join sysctrl.dbo.scode b on a.in_scode=b.scode ";
                SQL += "where a.stat_code LIKE 'N%' ";
                SQL += "order by sscode ";
                conn.DataTable(SQL, dt);
                td_tscode = "<select id='scode' name='scode' >" + dt.Option("{in_scode}", "{sc_name}") + "</select>";
            } else if ((HTProgRight & 64) != 0) {
                //權限A為看所屬營洽
                SQL = "select distinct a.in_scode,b.sc_name,b.sscode ";
                SQL += "from case_dmt a ";
                SQL += "inner join sysctrl.dbo.scode b on a.in_scode=b.scode ";
                SQL += "where a.stat_code LIKE 'N%' ";
                if (sales_scode != "" && sales_scode != "''") {
                    SQL += " and a.in_scode in (" + sales_scode + ")";
                }
                SQL += "order by sscode ";
                conn.DataTable(SQL, dt);
                td_tscode = "<select id='scode' name='scode' >" + dt.Option("{in_scode}", "{sc_name}") + "</select>";
            } else {
                td_tscode = "<input type='text' id='scode' name='scode' readonly class='SEdit' value='" + Session["se_scode"] + "'>";
                td_tscode = "<span='span_tscode'>" + Session["sc_name"] + "</span>";
            }
            //案性
            SQL = "SELECT RS_code, RS_detail FROM code_br WHERE dept = 'T' AND cr = 'Y' AND no_code='N' ";
            SQL += "and (end_date is null or end_date = '' or end_date > getdate()) ";
            SQL += " ORDER BY rs_type desc,rs_class ,rs_code";
            pfx_Arcase = Util.Option(conn, SQL, "{rs_code}", "{rs_code}--{rs_detail}");
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
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/jquery-1.12.4.min.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/jquery.datepick.min.js")%>"></script>
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
    <input type=hidden name=tscode id=tscode>

    <div id="id-div-slide">
        <table id="qryForm" border="0" class="bluetable" cellspacing="1" cellpadding="2" width="70%" align="center">	
			<TR>
				<td class="lightbluetable" align="right">洽案營洽 :</td>
		        <TD class=whitetablebg align=left><%#td_tscode%></TD>
            </TR>
			<TR>
				<td class="lightbluetable" align="right">承辦案性 :</td>
				<td class="whitetablebg" align="left">
                    <select id="pfx_Arcase" name="pfx_Arcase"><%#pfx_Arcase%></select>
				</td> 
			</TR>
			<TR>	
				<TD class=lightbluetable align=right>接洽日期 :</TD>
				<TD class=whitetablebg align=left>
                    <INPUT type=text id=Sfx_in_date NAME=Sfx_in_date SIZE=10 class="dateField">
                    ~
                    <INPUT type=text id=Efx_in_date NAME=Efx_in_date SIZE=10 class="dateField">
			</TR>
			<TR>
				<TD class=lightbluetable align=right width=40%>客戶編號 :</TD>
				<TD class=whitetablebg align=left>
                    <INPUT type=text id="tfx_Cust_area" name="tfx_Cust_area" readonly class="SEdit" size="1">-<INPUT type="text" name="tfx_Cust_seq" size="10">
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

<div id="dialog">
    <!--iframe id="myIframe" src="about:blank" width="100%" height="97%" style="border:none""></iframe-->
</div>

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

        $("#tfx_Cust_area").val("<%#Session["sebranch"]%>");
        $("#Sfx_in_date").val((new Date()).format("yyyy/M/1"));
        $("#Efx_in_date").val(Today().format("yyyy/M/d"));
    }

    //[查詢]
    $("#btnSrch").click(function (e) {
        if ($("#scode").val() == "") {
            alert("請選擇營洽!");
            return false;
        }
        $("#tscode").val($("#scode").val());

        reg.action = "<%=prgid%>List.aspx";
        //reg.target = "Eblank";
        reg.submit();
    });

    //[重填]
    $("#btnRest").click(function (e) {
        reg.reset();
        this_init();
    });

    $("#Sfx_in_date,#Efx_in_date").blur(function (e){
        ChkDate(this);
    });
</script>
