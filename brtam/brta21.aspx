<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data" %>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<script runat="server">
    protected string HTProgCap = "國內案收發進度維護作業";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = HttpContext.Current.Request["prgid"] ?? "";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";
    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";
    protected string SQL = "";

    protected string submitTask = "";
    protected string cgrs = "";
    protected string menu = "";

    protected string rs_type="",html_rs_class = "", html_rs_code = "", html_act_code = "";
    protected string td_tscode = "", html_pr_scode="";

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

        submitTask = "A";
        cgrs = (Request["cgrs"] ?? "").ToUpper();
        menu = (Request["menu"] ?? "").ToUpper();
        
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
        if (menu != "Y") {
            if(prgid=="brta21"||prgid=="brta31"||prgid=="brta32"){//brta21國內案官方收文作業//brta31國內案官方發文作業//brta32國內案客戶發文作業
                StrFormBtnTop += "<a href="+prgid+"_edit.aspx?submittask="+submitTask+"&prgid=" + prgid + "&cgrs=" + cgrs + ">[新增]</a>";
            }
        } else {
            submitTask = "Q";
        }
        
        if ((HTProgRight & 2) > 0) {
            StrFormBtn += "<input type=\"button\" id=\"btnSrch\" value=\"查　詢\" class=\"cbutton bsubmit\" />\n";
            StrFormBtn += "<input type=\"button\" id=\"btnRest\" value=\"重　填\" class=\"cbutton\" />\n";
        }
        
        //結構分類
        rs_type = Sys.getRsType();
        SQL="select cust_code,code_name from cust_code where code_type='" +rs_type+ "' and mark is null and ref_code is null ";
        html_rs_class = Util.Option(conn, SQL, "{cust_code}", "{cust_code}_{code_name}");

        //案性代碼
        SQL = "select rs_code,rs_detail from code_br where dept='T' and cr='Y' order by rs_code";
        html_rs_code = Util.Option(conn, SQL, "{rs_code}", "{rs_code}_{rs_detail}");

        //處理事項
        SQL= "select distinct b.act_code, c.code_name, c.sql ";
        SQL+="from  code_br  a ";
        SQL+="inner join code_act b on a.sqlno = b.code_sqlno ";
        SQL+="inner join cust_code c on b.act_code = c.cust_code ";
		SQL+=" where a.dept = 'T' and a.cr = 'Y' and c.code_type = 'TACT_Code'";
        SQL += " order by c.sql";
        html_act_code = Util.Option(conn, SQL, "{act_code}", "{act_code}_{code_name}");
        
        //營洽清單
        if ((HTProgRight & 64) != 0) {
            td_tscode = "<input type=hidden id=scode1 name=scode1>";
            td_tscode += "<select id='sscode1' name='sscode1' onchange='reg.scode1.value=this.value'>";
            td_tscode += Sys.getLoginGrpSales().Option("{scode}", "{scode}_{sc_name}");
            td_tscode += "</select>";
        } else {
            td_tscode = "<input type='hidden' id='scode1' name='scode1' value='" + Session["scode"] + "'>";
            td_tscode += "<input id=sscode1 name=sscode1 readonly class=SEdit size=5 value='" + Session["scode"] + "'>" + Session["sc_name"];
        }
        
        //承辦人員
        html_pr_scode += Sys.getPrScode().Option("{scode}", "{scode}_{sc_name}");
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
    <input type="hidden" id=menu name=menu value=<%=menu%>>
    <input type="hidden" id=submittask name=submittask value=<%=submitTask%>>
    <input type="hidden" id=rs_type name=rs_type value=<%=rs_type%>>

    <div id="id-div-slide">
        <table id="qryForm" border="0" class="bluetable" cellspacing="1" cellpadding="2" width="80%" align="center">	
	        <tr>
		        <td class="lightbluetable" align="right">本所編號：</td>
		        <td class="whitetablebg" align="left">
			        <input type="text" id="seq" name="seq" size="<%#Sys.DmtSeq%>">-
			        <input type="text" id="seq1" name="seq1" size="<%#Sys.DmtSeq1%>" style="text-transform:uppercase;">
		        </td>
		        <td class="lightbluetable" align="right"><span class="rsnotitle">收/發文</span>序號：</td>
		        <td class="whitetablebg" align="left">
			        <input type="text" name="rs_no" id="rs_no" size="11" maxlength=10>
		        </td>
	        </tr>
	        <TR>
		        <TD class=lightbluetable align=right>客戶代碼：</TD>
		        <TD class=whitetablebg align=left >
			        <INPUT type="text" id="cust_area" name="cust_area" size="1" class=SEdit readonly maxlength="1">-
			        <INPUT type="text" id="cust_seq" name="cust_seq" size="6" maxlength="6">
		        </TD>
		        <TD class=lightbluetable align=right>客戶名稱：</TD>
		        <TD class=whitetablebg align=left >
                    <INPUT type="text" id="ap_cname" name="ap_cname" size="25" maxlength=25>
		        </TD>
	        </TR>
	        <TR>
		        <TD class=lightbluetable align=right>案件名稱：</TD>
		        <TD class=whitetablebg align=left colspan=3>
                    <INPUT type="text" id="cappl_name" name="cappl_name" size="50" maxlength=50>
		        </TD>
	        </TR>
	        <TR>
		        <TD class=lightbluetable align=right><span class="rsnotitle">收/發文</span>種類：</TD>
		        <TD class=whitetablebg align=left colspan=3>
			    <select id=cgrs name=cgrs>
			        <option value="CR">客收</option><!--brta22-->
			        <option value="GR">官收</option><!--brta21-->
			        <option value="GS">官發</option><!--brta31-->
			        <option value="CS">客發</option><!--brta22-->
			        <option value="ZS">本發</option><!--brta34-->
			    </select>
		        </TD>
	        </TR>
	        <TR>
		        <TD class=lightbluetable align=right><span class="rsnotitle">收/發文</span>代碼：</TD>
		        <TD class=whitetablebg align=left colspan=3>
                    結構分類：
			        <span id=span_rs_class>
				        <select id="rs_class" name="rs_class"><%#html_rs_class%></select>
			        </span>
			        <br>案性代碼：
			        <span id=span_rs_code>
				        <select id="rs_code" name="rs_code"><%#html_rs_code%></select>
			        </span>
                    <br>處理事項：
			        <span id=span_act_code>
				        <select id="act_code" name="act_code"><%#html_act_code%></select>
			        </span>
		        </td>
	        </TR>
	        <TR>
		        <TD class=lightbluetable align=right><span class="rsnotitle">收/發文</span>期間：</TD>
		        <TD class=whitetablebg align=left colspan=3>
			        <input type="text" id="sstep_date" name="sstep_date" size="10" class="dateField">～
			        <input type="text" id="estep_date" name="estep_date" size="10" class="dateField">&nbsp;&nbsp;(YYYY/MM/DD)
		        </td>
	        </TR>
            <TR>
		        <TD class=lightbluetable align=right>法定日期：</TD>
		        <TD class=whitetablebg align=left colspan=3>
			        <input type="text" id="slast_date" name="slast_date" size="10" class="dateField">～
			        <input type="text" id="elast_date" name="elast_date" size="10" class="dateField">&nbsp;&nbsp;(YYYY/MM/DD)
		        </td>
	        </TR>
	        <tr id="tr_scode">
		        <td class=lightbluetable align="right" id=salename  width="15%">洽案營洽：</td>
		        <td class=whitetablebg align="left">
			        <%#td_tscode%>
		        </td>
		        <TD class=lightbluetable align=right>承辦人員：</TD>
		        <td class=whitetablebg align="left">
			        <input type=hidden id=pr_scode name=pr_scode>
			        <span id=span_pr_scode>
			        <select id='spr_scode' name='spr_scode' onchange="reg.pr_scode.value=this.value">
			        <%#html_pr_scode%>
			        </select>
			        </span>
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

<div align="left">
</div>

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

        $("#sstep_date").val(Today().format("yyyy/M/1"));
        $("#estep_date").val(Today().format("yyyy/M/d"));

        $("#cgrs").triggerHandler("change");

        $("#cust_area").val("<%=Session["seBranch"]%>");
        $("#qrycgrs option[value='" + $("#cgrs").val() + "']").prop("selected", true);
    }

    //[重填]
    $("#btnRest").click(function (e) {
        reg.reset();
        this_init();
    });

    //////////////////////////////////////////////////////
    $("#seq").blur(function (e) {
        chkNum1($(this),"本所編號");
    });
    $("#cust_seq").blur(function (e) {
        chkNum1($(this), "客戶編號");
    });
    $("#sstep_date,#estep_date,#slast_date,#elast_date").blur(function (e) {
        ChkDate(this);
    });

    //依結構分類帶案性代碼
    $("#cgrs").change(function () {
        $("#rs_class").triggerHandler("change");
    });

    //依結構分類帶案性代碼
    $("#rs_class").change(function () {
        $("#rs_code").getOption({//案性代碼
            url: getRootPath() + "/ajax/json_rs_code.aspx",
            data: { cgrs: $("#cgrs").val(), rs_type: $("#rs_type").val(), rs_class: $("#rs_class").val() },
            valueFormat: "{rs_code}",
            textFormat: "{rs_detail}",
            attrFormat: "vrs_class='{rs_class}'"
        });
        $("#rs_code").triggerHandler("change");
    });

    //依案性帶處理事項
    $("#rs_code").change(function () {
        $("#act_code").getOption({//處理事項
            url: getRootPath() + "/ajax/json_act_code.aspx",
            data: { cgrs: $("#cgrs").val(), rs_class: $("#rs_class").val(), rs_code: $("#rs_code").val() },
            valueFormat: "{act_code}",
            textFormat: "{act_code_name}",
            attrFormat: "spe_ctrl='{spe_ctrl}'"
        });
        $("#act_code").triggerHandler("change");
    });

    //[查詢]
    $("#btnSrch").click(function (e) {
        if ($("#sstep_date").val() == "") {
            alert("期間起始日必須輸入!!!");
            $("#sstep_date").focus();
            return false;
        }
        if ($("#estep_date").val() == "") {
            alert("期間終止日必須輸入!!!");
            $("#estep_date").focus();
            return false;
        }

        if ($("#sstep_date").val() != "" && $("#estep_date").val() != "") {
            if (CDate($("#sstep_date").val()).getTime() > CDate($("#estep_date").val()).getTime()) {
                alert($(".rsnotitle:eq(0)").html() + "期間起始日不可大於迄止日!!!");
                return false;
            }
        }

        if ($("#slast_date").val() != "" && $("#elast_date").val() != "") {
            if (CDate($("#slast_date").val()).getTime() > CDate($("#elast_date").val()).getTime()) {
                alert("法定期間起始日不可大於迄止日!!!");
                return false;
            }
        }

        reg.action = "brta21_List.aspx";

        if ($("#cgrs").val() == "CR") {//客收
            $("#prgid").val("brta22");
            reg.action = "brta21_List_cr.aspx";
        } else if ($("#cgrs").val() == "GR") {//官收
            $("#prgid").val("brta21");
        } else if ($("#cgrs").val() == "GS") {//官發
            $("#prgid").val("brta31");
        } else if ($("#cgrs").val() == "CS") {//客發
            $("#prgid").val("brta22");
            reg.action = "brta21_List_cs.aspx";
        } else if ($("#cgrs").val() == "ZS") {//本發
            $("#prgid").val("brta34");
        }

        reg.submit();
    });
</script>
