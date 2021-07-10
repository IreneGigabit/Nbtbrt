<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data" %>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<script runat="server">
    protected string HTProgCap = "收發文共同報表列印";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = HttpContext.Current.Request["prgid"] ?? "";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";
    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";
    protected string SQL = "";

    protected string cgrs = "";
    protected string step_date = "";
    protected string rs_no = "";

    protected string html_rprtkind = "";
    protected string html_ctrl_type = "";
    protected string td_tscode = "";

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
        
        cgrs = (Request["cgrs"] ?? "").ToUpper();
        
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
            StrFormBtn += "<input type=\"button\" id=\"btnSrch\" value=\"列　印\" class=\"cbutton bsubmit\" />\n";
            StrFormBtn += "<input type=\"button\" id=\"btnRest\" value=\"重　填\" class=\"cbutton\" />\n";
        }
        
        //報表種類
        DataTable dtkind = Sys.getCustCode("rpt_cgrs_t", "", "");
        html_rprtkind = dtkind.Radio("rprtkind", "{cust_code}", "{code_name}", "onclick=\"rprtkind_onclick('{cust_code}','{mark1}',this.value)\"", 3);
        
        //管制種類
        html_ctrl_type = Sys.getCustCode("CT", "", "").Option("{cust_code}", "{code_name}",false);

        using (DBHelper conn = new DBHelper(Conn.btbrt).Debug(false)) {
            //營洽清單
            if ((HTProgRight & 64) != 0) {
                td_tscode = "<select id='scode1' name='scode1' >";
                td_tscode += Sys.getDmtScode("", "").Option("{scode}", "{star}{scode}_{sc_name}", "style='color:{color}'", true);
                td_tscode += "<option value='" + Sys.GetSession("seBranch") + Sys.GetSession("dept") + "'>" + Sys.GetSession("seBranch") + Sys.GetSession("dept").ToUpper() + "_部門(開放客戶)</option>";
                td_tscode += "</select>";
            } else {
                td_tscode = "<input type='hidden' id='scode1' name='scode1' readonly class='SEdit' value='" + Session["se_scode"] + "'>";
                td_tscode += "<input type='text' id='ScodeName' name='ScodeName' readonly class='SEdit' value='" + Session["sc_name"] + "'>";
            }
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
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/client_chk.js")%>"></script>
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
    <input type="hidden" id=cgrs name=cgrs value=<%=cgrs%>>
    <input type="hidden" id=haveword name=haveword>

    <div id="id-div-slide">
        <table id="qryForm" border="0" class="bluetable" cellspacing="1" cellpadding="2" width="90%" align="center">	
	        <tr>
		        <TD class=lightbluetable align=right width="15%">報表種類：</TD>
		        <TD class=whitetablebg align=left colspan=3>
			        <input type="hidden" id=prtkind name=prtkind>
                    <%#html_rprtkind%>
		        </td>
	        </tr>
	        <tr id="tr_step_date">
		        <td class="lightbluetable" align="right"><span id="datetitle">收/發</span>文日期：</td>
		        <td class="whitetablebg" align="left" colspan=3>
			        <input type="text" name="sstep_date" id="sstep_date" size="10" maxlength=10 class="dateField" onblur="ChkDate(this)">
			        <input type="text" name="estep_date" id="estep_date" size="10" maxlength=10 class="dateField" onblur="ChkDate(this)">
		        </td>
	        </tr>
	        <tr id="tr_rs_no">
		        <td class="lightbluetable" align="right"><span id="rsnotitle">收/發</span>文字號：</td>
		        <td class="whitetablebg" align="left" colspan=3>
			        <input type="text" name="srs_no" id="srs_no" size="11" maxlength=10>～
			        <input type="text" name="ers_no" id="ers_no" size="11" maxlength=10>
		        </td>
	        </tr>
	        <tr id="tr_seq">
		        <td class="lightbluetable" align="right">本所編號：</td>
		        <td class="whitetablebg" align="left" colspan=3>
			        <input type="text" id="sseq" name="sseq" size="<%#Sys.DmtSeq%>" maxlength=<%#Sys.DmtSeq%>>～
			        <input type="text" id="eseq" name="eseq" size="<%#Sys.DmtSeq%>" maxlength=<%#Sys.DmtSeq%>>
		        </td>
	        </tr>
	        <tr id="tr_ctrl_date">
		        <td class="lightbluetable" align="right" width="15%">稽催日期：</td>
		        <td class="whitetablebg" align="left" colspan=3>
			        <input type="text" id="sctrl_date" name="sctrl_date" size="10" maxlength=10 class="dateField" onblur="ChkDate(this)">
			        <input type="text" id="ectrl_date" name="ectrl_date" size="10" maxlength=10 class="dateField" onblur="ChkDate(this)">
		        </td>
	        </tr>
	        <tr id="tr_ctrl_type">
		        <td class="lightbluetable" align="right" width="15%">管制種類：</td>		
		        <td class=whitetablebg align="left" colspan=3>
			        <input type=hidden name="ctrl_name" id="ctrl_name" value="所有管制種類">		
			        <select name="ctrl_type" id="ctrl_type" onchange="reg.ctrl_name.value=reg.ctrl_type.options(reg.ctrl_type.selectedIndex).text">
		            <option value="" style="color:blue" selected>所有管制種類</option>
			        <%#html_ctrl_type%>
			        </select>
		        </td>
	        </tr>
	        <tr id="tr_scode1">
		        <td class=lightbluetable align="right" id=salename  width="15%">營　　洽：</td>
		        <td class=whitetablebg align="left" colspan=3>
			        <%#td_tscode%>
		        </td>
	        </tr>
	        <tr id="tr_in_date">
                <td class="lightbluetable" align="right">立案日期：</td>
		        <td class="whitetablebg" align="left" colspan=3>
			        <input type="text" id="isdate" name="isdate" size="10" class="dateField" onblur="ChkDate(this)">～
			        <input type="text" id="iedate" name="iedate" size="10" class="dateField" onblur="ChkDate(this)">
		        </td>
	        </tr>
	        <tr id="tr_end_date">
		        <td class="lightbluetable" align="right" width="15%">結案日期：</td>
		        <td class="whitetablebg" align="left" colspan=3>
			        <input type="text" id="esdate" name="esdate" size="10" class="dateField" onblur="ChkDate(this)">～
			        <input type="text" id="eedate" name="eedate" size="10" class="dateField" onblur="ChkDate(this)">
		        </td>
	        </tr>
	        <tr id="tr_cust">
		        <td class="lightbluetable" align="right">客戶編號：</td>
		        <td class="whitetablebg" align="left" colspan=3>
			        <input type="text" id="cust_area" name="cust_area" size="1" class=SEdit readonly value="<%#Session["seBranch"]%>">-
			        <input type="text" id="scust_seq" name="scust_seq" size="6" maxlength=6>～
			        <input type="text" id="ecust_seq" name="ecust_seq" size="6" maxlength=6>
		        </td>
	        </tr>
	        <tr id="tr_apcust">
		        <td class="lightbluetable" align="right">申請人名稱：</td>
		        <td class="whitetablebg" align="left" colspan=3>
			        <input type="text" id="ap_cname" name="ap_cname" size="40" maxlength="40">
		        </td>
	        </tr>
	        <tr id="tr_sort">
		        <td class="lightbluetable" align="right" width="15%">排列順序：</td>		
		        <td class=whitetablebg align="left" colspan=3>
			        <select id="sort" name="sort">
				        <option value='scode1' selected>依營洽</option>
				        <option value='ctrl_date' >依管制期限</option>
			        </select>
		        </td>
	        </tr>
	        <tr id="tr_sort1">
		        <td class="lightbluetable" align="right" width="15%">排列順序：</td>		
		        <td class=whitetablebg align="left" colspan=3>
			        <select id="sort1" name="sort1">
				        <option value='sort_seq' selected>依本所編號</option>
				        <option value='sort_cust' >依客戶</option>
			        </select>
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
    <br />
    *營洽中有　<font color=red size=2>' * '</font>　符號者，表該營洽已離職!!<br>
    *延展管制表的稽催日期，指專用期限迄日!!<br />
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
        $("input[name='rprtkind'][value='433']").prop("disabled", true);//官方回應追蹤報表

        init();
        $("#sstep_date,#estep_date,#isdate,#iedate").val("<%#DateTime.Today.ToShortDateString()%>");
        $("#sctrl_date").val("1980/1/1");
        $("#ectrl_date").val(Today().addDays(5).format("yyyy/M/d"));
    }

    //[重填]
    $("#btnRest").click(function (e) {
        reg.reset();
        this_init();
    });

    //////////////////////////////////////////////////////
    function init() {
        $("#tr_step_date").hide();//收/發文日期
        $("#tr_rs_no").hide();//收/發文字號
        $("#tr_seq").hide();//本所編號
        $("#tr_ctrl_date").hide();//稽催日期
        $("#tr_ctrl_type").hide();//管制種類
        $("#tr_scode1").hide();//營洽
        $("#tr_in_date").hide();//立案日期
        $("#tr_end_date").hide();//結案日期
        $("#tr_cust").hide();//客戶編號
        $("#tr_sort,#tr_sort1").hide();//排列順序
        $("#tr_apcust").hide();//申請人名稱
    }

    function getRsNo() {
        if ($("#sstep_date").val() != "" || $("#estep_date").val() != "") {
            $.ajax({
                type: "get",
                    url: getRootPath() + "/ajax/json_rs_no.aspx?branch=<%#Session["seBranch"]%>&cgrs=" + $("#cgrs").val() + "&sdate="+ $("#sstep_date").val() + "&edate=" + $("#estep_date").val(),
                async: false,
                cache: false,
                success: function (json) {
                    var jData = $.parseJSON(json);
                    if (jData.length != 0) {
                        $("#srs_no").val(jData[0].minrs_no);
                        $("#ers_no").val(jData[0].maxrs_no);
                    } else {
                        $("#srs_no").val("");
                        $("#ers_no").val("");
                    }
                },
                error: function (xhr) {
                    $("#dialog").html("<a href='" + this.url + "' target='_new'>抓取收文字號！<u>(點此顯示詳細訊息)</u></a><hr>" + xhr.responseText);
                    $("#dialog").dialog({ title: '抓取收文字號！', modal: true, maxHeight: 500, width: "90%" });
                }
            });
        }
    }

    $("#scust_seq").blur(function (e) {
        if ($("#ecust_seq").val()==""){
            $("#ecust_seq").val($(this).val());
        }
    });

    $("#sseq").blur(function (e) {
        if ($("#eseq").val() == "") {
            $("#eseq").val($(this).val());
        }
    });

    //報表種類
    function rprtkind_onclick(prtkind,pword,pvalue){
        $("#prtkind").val(prtkind);
        $("#haveword").val(pword);
        init();

        $("#rsnotitle,#datetitle").html("收/發");
        //431:期限管制列印、432:案件狀態列印、433:官方回應追蹤報表、434:延展管制表
        if (pvalue == "431") {
            $("#tr_step_date").show();//本所編號
            $("#tr_seq").show();//本所編號
            $("#tr_scode1").show();//營洽
            $("#tr_ctrl_date").show();//稽催日期
            $("#tr_ctrl_type").show();//管制種類
            $("#tr_sort").show();//排列順序
            $("#sstep_date").val("1980/1/1");//收/發文日期
        }
        if (pvalue == "432") {
            $("#tr_in_date").show();//立案日期
            $("#tr_end_date").show();//結案日期
            $("#tr_cust").show();//客戶編號
            $("#tr_seq").show();//本所編號
            $("#tr_scode1").show();//營洽
            $("#tr_sort1").show();//排列順序
        }
        if (pvalue == "433") {
            $("#cgrs").val("GS");
            $("#tr_step_date").show();//收/發文日期
            $("#tr_rs_no").show();//收/發文字號
            $("#tr_seq").show();//本所編號
            $("#tr_cust").show();//客戶編號
            $("#rsnotitle,#datetitle").html("發");
        }
        if (pvalue == "434") {
            $("#tr_seq").show();//本所編號
            $("#tr_scode1").show();//營洽
            $("#tr_ctrl_date").show();//稽催日期
            $("#tr_cust").show();//客戶編號
            $("#tr_apcust").show();//申請人名稱
            $("#tr_sort1").show();//排列順序
            $("#sctrl_date").val(Today().addMonths(6).format("yyyy/M/1"));
            $("#ectrl_date").val(CDate(Today().addMonths(7).format("yyyy/M/1")).addDays(-1).format("yyyy/M/d"));
        }
    }

    //[列印]
    $("#btnSrch").click(function (e) {
        if ($("#prtkind").val() == "") {
            alert("報表種類必須選擇!!!");
            return false;
        }
        if ($("#tr_ctrl_date").is(":visible")) {
            if ($("#sctrl_date").val() == "" || $("#ectrl_date").val() == "") {
                alert("稽催日期任一不得為空白!!!");
                return false;
            }
        }

        if ($("#haveword").val() == "Y") {
            reg.target = "ActFrame";
            reg.action = "brta" + $("#prtkind").val() + "Print.aspx";
            reg.submit();
        } else {
            //var url = "brta" + $("#prtkind").val() + "Print.aspx?sdate=" + $("#sdate").val() + "&edate=" + $("#edate").val() +
            //    "&srs_no=" + $("#srs_no").val() + "&ers_no=" + $("#ers_no").val() + "&sseq=" + $("#sseq").val() + "&eseq=" + $("#eseq").val() +
            //    "&seq1=" + $("#seq1").val() + "&hprint=" + $("#hprint").val();
            var url = "brta" + $("#prtkind").val() + "Print.aspx";
            url += "?" + $("#reg").serialize();
            window.open(url, "myWindowOneN", "width=750px, height=550px, top=10, left=10, toolbar=no, menubar=no, location=no, directories=no, status=no, scrollbars=yes");
            //$('#dialog')
            //.html('<iframe style="border: 0px;" src="' + url + '" width="100%" height="100%"></iframe>')
            //.dialog({autoOpen: true,modal: true,height: 550,width: 750,title: "列印"});
        }
    });
</script>
