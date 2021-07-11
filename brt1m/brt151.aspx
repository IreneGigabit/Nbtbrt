<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data" %>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<script runat="server">
    protected string HTProgCap = "國內案接洽客戶後續查詢作業";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = HttpContext.Current.Request["prgid"] ?? "";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";
    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";
    protected string SQL = "";

    protected string html_scode = "", html_qjob_case="";

    DBHelper conn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    DBHelper cnn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    private void Page_Unload(System.Object sender, System.EventArgs e) {
        if (conn != null) conn.Dispose();
        if (cnn != null) cnn.Dispose();
    }

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
        cnn = new DBHelper(Conn.Sysctrl).Debug(Request["chkTest"] == "TEST");

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

        if ((HTProgRight & 64) != 0) {
            SQL = "select distinct scode,sc_name,scode1 from vscode_roles ";
            SQL += " where branch='" + Session["SeBranch"] + "' and dept='" + Session["Dept"] + "' and syscode='" + Session["syscode"] + "' and roles='sales'";
            SQL += " order by scode1 ";
        } else {
            SQL = "select distinct scode,sc_name,sscode scode1 from scode ";
            SQL += " where scode='" + Session["scode"] + "'";
        }
        html_scode = Util.Option(cnn, SQL, "{scode}", "{scode}_{sc_name}");

        SQL = "SELECT Cust_code,Code_name,form_name,remark";
        SQL += " FROM Cust_code";
        SQL += " WHERE Code_type = '" + Sys.getRsType() + "' AND form_name is not null ";
        SQL += "order by cust_code";
        html_qjob_case = Util.Option(conn, SQL, "{Cust_code}", "{Code_name}", " v1='{form_name}' v2='{remark}'", true);
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
    <input type="hidden" id="prgid" name="prgid" value="<%=prgid%>">
    <input type="hidden" name=tscode id=tscode>

    <div id="id-div-slide">
        <table id="qryForm" border="0" class="bluetable" cellspacing="1" cellpadding="2" width="70%" align="center">	
	        <tr>
		        <td class="lightbluetable" align="right">本所編號 :</td>
		        <td class="whitetablebg" align="left">
                    <%=Session["seBranch"]%>T-
                    <input type="text" id="qseq" name="qseq" size="6" maxlength="<%=Sys.DmtSeq%>">-
                    <input type="text" id="qseq1" name="qseq1" size="2" maxlength="<%=Sys.DmtSeq1%>">
		        </td>
	        </tr>
	        <tr>
		        <td class="lightbluetable" align="right">洽案營洽:</td>
		        <td class="whitetablebg" align="left">
                    <select id='scode' name='scode' >
                        <%#html_scode%>
                    </select>
                </td>
	        </tr>
	        <tr>
		        <td class="lightbluetable" align="right">客戶編號:</td>
		        <td class="whitetablebg" align="left">
		        <input type="text" id="qCust_area" name="qCust_area" size="1" class="SEdit" readonly value="<%=Session["seBranch"]%>">-<input type="text" id="qCust_seq" name="qCust_seq" style="width:10%">
		        </td>
	        </tr>
			<TR>
				<td class="lightbluetable" align="right">後續案性 :</td>
				<td class="whitetablebg" align="left">
			        <SELECT name=qjob_case id=qjob_case>
                        <%#html_qjob_case%>
					</select>
				</td> 
			</TR>
			<TR>
				<TD class=lightbluetable align=right>日期種類：</TD>
				<TD class=whitetablebg >
					<label><input type="radio" name="kind_date" value="Pre_date" checked>預計處理日期</label>
					<label><input type="radio" name="kind_date" value="sconf_Date">確收日期</label>
					<label><input type="radio" name="kind_date" value="">不指定</label>
				</TD>
			</TR>
			<TR>
				<TD class=lightbluetable align=right>日期期間：</TD>
				<TD class=whitetablebg nowrap>
					<input type="text" name="sdate" id="sdate" size="10" class="dateField">～
					<input type="text" name="edate" id="edate" size="10" class="dateField">&nbsp;&nbsp;(YYYY/MM/DD)
				</TD>
			</TR>		
			<TR>
				<TD class=lightbluetable align=right>案件狀態：</TD>
				<TD class=whitetablebg nowrap>
					<label><input type="radio" name="qryjob_no" value="N" checked>尚未接洽後續案性</label>
					<label><input type="radio" name="qryjob_no" value="Y" >已接洽後續案性</label>
					<label><input type="radio" name="qryjob_no" value="">不指定</label>
				</TD>
			</TR>
        </table>
        <br>
        <table id="tabBtn" border="0" width="100%" cellspacing="0" cellpadding="0" align="center">
	        <tr><td width="100%" align="center">
			    <%#StrFormBtn%>
	        </td></tr>
        </table>

        <div></div>
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

        $("#tfx_cust_area").val("<%#Session["sebranch"]%>");
        $("input[name='new']:checked").triggerHandler("click");
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
        $("#tscode").val($("#scode").val());

        reg.action = "<%=HTProgPrefix%>_List.aspx";
        reg.submit();
    });
</script>
