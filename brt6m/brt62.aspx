<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data" %>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<script runat="server">
    protected string HTProgCap = "國內案文件上傳作業";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "brt62";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";
    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";
    protected string SQL = "";

    protected string html_doc_type = "", html_in_scode="";

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
        HTProgCap = myToken.Title;
        DebugStr = myToken.DebugStr;
        if (HTProgRight >= 0) {
            PageLayout();
            this.DataBind();
        }
    }

    private void PageLayout() {
        if ((HTProgRight & 2) > 0) {
            StrFormBtn += "<input type=\"button\" id=\"btnSrch\" value=\"查　詢\" class=\"cbutton bsubmit\" />\n";
            StrFormBtn += "<input type=\"button\" id=\"btnRest\" value=\"重　填\" class=\"cbutton\" />\n";
        }
        
        //文件種類
        html_doc_type = Sys.getCustCode("tdoc", "", "sortfld").Option("{cust_code}", "{code_name}");
        //上傳人員
        SQL = "select A.in_scode,d.sc_name from dmt_attach A ";
        SQL += "inner join sysctrl.dbo.scode D on a.in_scode = d.scode ";
        SQL += "group by a.in_scode,d.sc_name";
        html_in_scode = Util.Option(conn, SQL, "{in_scode}", "{in_scode}_{sc_name}");
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
    <div id="id-div-slide">
        <input type="hidden" id="prgid" name="prgid" value="<%=prgid%>">
        <table id="qryForm" border="0" class="bluetable" cellspacing="1" cellpadding="2" width="70%" align="center">	
		    <tr align=center id="tr_seq">
			    <td class="lightbluetable" align="right" nowrap>本所編號：</td>
			    <td class="whitetablebg" align="left" >	
				    <input type="text" id="qrySeq" name="qrySeq" size="5">-<input type="text" id="qrySeq1" name="qrySeq1" size="2" value="_">
			    </td>
		    </tr>
		
		    <TR id="tr_doc_type">
			    <TD class=lightbluetable align=right>文件種類：</TD>
			    <TD class=whitetablebg align=left colspan="5">
				    <Select name="qryDoc_type" id="qryDoc_type"><%#html_doc_type%></Select>
			    </TD>
		    </TR>
		    <TR id="tr_attach_desc">
			    <TD class=lightbluetable align=right>附件說明：</TD>
			    <TD class=whitetablebg align=left   colspan="5">
				    <INPUT type="text" id="qryattach_desc" name="qryattach_desc" size="40" maxlength="80">
			    </TD>
		    </TR>
		    <TR id="tr_in_scode">
			    <TD class=lightbluetable align=right>上傳人員：</TD>
			    <TD class=whitetablebg align=left colspan="5">
				    <Select name="qryin_scode" id="qryin_scode"><%#html_in_scode%></Select>
			    </TD>
		    </TR>
		    <TR id="tr_in_date">
			    <TD class=lightbluetable align=right>上傳日期：</TD>
			    <TD class=whitetablebg align=left   colspan="5">
			    <input type="text" name="qrydateS" id="qrydateS" size="10" class="dateField">～
			    <input type="text" name="qrydateE" id="qrydateE" size="10" class="dateField">
			    <input type=checkbox name=qrychkdate id=qrychkdate value="" checked>不指定
			    </TD>
		    </TR>
		    <TR id="tr_from_flag">
			    <TD class=lightbluetable align=right>排序：</TD>
			    <TD class=whitetablebg align=left colspan="5">
				    <Select name="qryOrder" id="qryOrder">
					    <option value="a.seq,a.seq1 asc">案件編號
					    <option value="a.seq,a.seq1 asc ,a.in_date desc ">案件編號+上傳日期
					    <option value="a.seq,a.seq1,a.in_scode asc">案件編號+上傳人員
				    </Select>
			    </TD>
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

<div id="divList"></div>

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

        $("#qrychkdate").triggerHandler("click");
    }

    //[查詢]
    $("#btnSrch").click(function (e) {
        if("<%=Session["LoginGrp"]%>".indexOf("ADMIN")==-1){
            if ($("#qrySeq").val() == "" && $("#qryattach_desc").val() == "") {
                alert("請輸入任一條件!!");
                return false;
            }
        }

        reg.action = "<%=HTProgPrefix%>_List.aspx";
        //reg.target = "Eblank";
        reg.submit();
    });

    //[重填]
    $("#btnRest").click(function (e) {
        reg.reset();
        this_init();
    });
    //////////////////////

    $("#qrychkdate").click(function (e) {
        if ($(this).prop("checked")==false) {
            $("#qrydateS").val(Today().format("yyyy/M/d"));
            $("#qrydateE").val(Today().format("yyyy/M/d"));
        }else {//不指定
            $("#qrydateS").val("");
            $("#qrydateE").val("");
        }
    });
</script>
