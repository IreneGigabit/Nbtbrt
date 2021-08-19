<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data" %>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<script runat="server">
    protected string HTProgCap = "發文報表列印";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = HttpContext.Current.Request["prgid"] ?? "";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";
    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";
    protected string FormName = "";
    protected string SQL = "";

    protected string cgrs = "";
    protected string step_date = "";
    protected string rs_no = "";
    protected string emg_scode = "";
    protected string emg_agscode = "";

    protected string FrameBlank = "";
    protected string html_rprtkind = "";
    protected string html_sscode1 = "";

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
        step_date = (Request["step_date"] ?? "");
        rs_no = (Request["rs_no"] ?? "").ToUpper();
        FrameBlank = (Request["FrameBlank"] ?? "");
        
        if (cgrs == "CS") HTProgCap = "<font color=blue>客戶</font>";
        if (cgrs == "GS") HTProgCap = "<font color=blue>官方</font>";
        HTProgCap += "發文報表列印";
        
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
        if (FrameBlank != "") {
            StrFormBtnTop += "<a class=\"imgCls\" href=\"javascript:void(0);\" >[關閉視窗]</a>";
        }
        
        if ((HTProgRight & 32) > 0) {
            StrFormBtn += "<input type=\"button\" id=\"btnSubmit\" value=\"列　印\" class=\"cbutton bsubmit\" />\n";
            
			StrFormBtn += "<span id=\"span_gs_email\" style=\"display:none\">\n";
			StrFormBtn += "    <br><br>\n";
			StrFormBtn += "    發文日期：<input type=\"text\" id=\"gs_date\" name=\"gs_date\" size=\"10\" maxlength=10 class=\"dateField\">\n";
			StrFormBtn += "    <input onClick=\"formEmail()\" id=\"buttonE\" name=\"buttonE\" type=\"button\" value=\"官方發文Email通知總管處(電子送件)\" class=\"cbutton\">\n";
			StrFormBtn += "</span>\n";
            StrFormBtn += "<input type=\"button\" id=\"btnRest\" value=\"重　填\" class=\"cbutton\" />\n";
        }

        if (prgid == "brta51m") {
            FormName = "官方發文回條：不顯示收據種類為電子收據之資料<BR>\n";
        }

        emg_scode = Sys.getRoleScode("M", Sys.GetSession("syscode"), "T", "mg_pror");//總管處程序人員-正本
        emg_agscode = Sys.getRoleScode("M", Sys.GetSession("syscode"), "T", "mg_prorm");//總管處程序人員-副本
        
        //報表種類
        DataTable dtkind = Sys.getCustCode("rpt_" + cgrs.ToLower() + "_t", "", "");
        html_rprtkind = dtkind.Radio("rprtkind", "{cust_code}", "{code_name}", "onclick=\"rprtkind_onclick('{cust_code}','{mark1}')\"", 3);

        //營洽
        SQL = "select scode,sc_name from vscode_type where branch='" + Session["seBranch"] + "' and grpid like '" + Session["Dept"] + "%' and work_type='sales' order by scode";
        DataTable dtscode = new DataTable();
        cnn.DataTable(SQL, dtscode);
        html_sscode1 = dtscode.Option("{scode}", "{scode}_{sc_name}");
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
    <input type="hidden" id=cgrs name=cgrs value=<%=cgrs%>>
    <input type="hidden" id=haveword name=haveword>

    <div id="id-div-slide">
        <table id="qryForm" border="0" class="bluetable" cellspacing="1" cellpadding="2" width="90%" align="center">	
	        <tr>
		        <TD class=lightbluetable align=right width="15%">報表種類：</TD>
		        <TD class=whitetablebg align=left colspan=3>
			        <input type="hidden" id=prtkind name=prtkind>
                    <%#html_rprtkind%>
                    <%if (cgrs=="GS"){%>
			            <hr class="style-one" color="blue">
			            <label><input type=radio name="rprtkind" value="511ZS" id="rprtkind511ZS" onclick="rprtkind_onclick('511ZS','N')">本所發文明細</label>
			        <%}%>
		        </td>
	        </tr>
	        <tr id="tr_send_way">
		        <td class="lightbluetable" align="right">發文方式：</td>
		        <td class="whitetablebg" align="left" colspan=3>
			        <input type="hidden" id="hsend_way" name="hsend_way" value="">
			        <input type="radio" name="send_way" id="send_wayM" value="M"><label for="send_wayM">非電子送件</label>
			        <input type="radio" name="send_way" id="send_wayE" value="E"><label for="send_wayE">電子送件</label>
			        <input type="radio" name="send_way" id="send_wayEA" value="EA"><label for="send_wayEA">註冊費電子送件</label>
			        <span id="span_Email_msg" style="display:none"><font color=darkred>【請先點「列印」產生各項報表檔案，再點Email通知總管處(電子送件)】</font></span>
			        <input type="radio" name="send_way" id="send_wayAll" value=""><label for="send_wayAll">全部</label>
		        </td>
	        </tr>
            <TR id="tr_date">
                <td class="lightbluetable" align="right">發文日期：</td>
		        <td class="whitetablebg" align="left" colspan=3>
			        <input type="text" id="sdate" name="sdate" size="10" class="dateField">～
			        <input type="text" id="edate" name="edate" size="10" class="dateField">
		        </td>
	       </TR>
	        <tr id="tr_rs_no">
		        <td class="lightbluetable" align="right">發文字號：</td>
		        <td class="whitetablebg" align="left" colspan=3>
			        <input type="text" id="srs_no" name="srs_no" size="11" maxlength=10>～
			        <input type="text" id="ers_no" name="ers_no" size="11" maxlength=10>
		        </td>
	        </tr>
	        <tr>
		        <td class=lightbluetable align="right" width="15%">營　　洽：</td>
		        <td class=whitetablebg align="left" colspan=3>
			        <input type=hidden name=scode1 id=scode1>
			        <select id='sscode1' name='sscode1' onchange="reg.scode1.value=this.value">
                    <%#html_sscode1%>
			        </select>
		        </td>
	        </tr>
	        <tr>
		        <td class="lightbluetable" align="right">本所編號：</td>
		        <td class="whitetablebg" align="left">
			        <input type="text" id="sseq" name="sseq" size="<%#Sys.DmtSeq%>" maxlength=<%#Sys.DmtSeq%>>～
			        <input type="text" id="eseq" name="eseq" size="<%#Sys.DmtSeq%>" maxlength=<%#Sys.DmtSeq%>>
		        </td>
		        <td class="lightbluetable" align="right">客戶編號：</td>
		        <td class="whitetablebg" align="left">
			        <input type="text" id="cust_area" name="cust_area" size="1" class=SEdit readonly value="<%#Session["seBranch"]%>">-
			        <input type="text" id="scust_seq" name="scust_seq" size="6" maxlength=6>～
			        <input type="text" id="ecust_seq" name="ecust_seq" size="6" maxlength=6>
		        </td>
	        </tr>
	        <tr id="tr_ctrl_date">
		        <td class=lightbluetable align="right" width="15%">稽催期間：</td>
		        <td class="whitetablebg" align="left" colspan=3>
			        <input type="text" id="sctrl_date" name="sctrl_date" size="10" maxlength=10 class="dateField">
			        <input type="text" id="ectrl_date" name="ectrl_date" size="10" maxlength=10 class="dateField">
		        </td>
	        </tr>
           <TR id="tr_print">
		        <TD class=lightbluetable align=right>列印選擇：</TD>
		        <TD class=whitetablebg align=left colspan=3>
                    <label><input type="radio" name="tfx_print" value="N">未列印</label>
		            <label><input type="radio" name="tfx_print" value="Y">已列印 </label>
                    <label><input type="radio" name="tfx_print" value="" checked>不設定</label>
		        </TD>
	        </TR>
	        <tr id="tr_print_date">
		        <td class="lightbluetable" align="right">已列印日期：</td>
		        <td class="whitetablebg" align="left" colspan=3>
			        <input type="text" id="sprint_date" name="sprint_date" size="10" maxlength=10 class="dateField">
			        <input type="text" id="eprint_date" name="eprint_date" size="10" maxlength=10 class="dateField">
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

<div align="left" style="color:blue"><%#FormName%></div>

<div id="dialog"></div>

<iframe id="ActFrame" name="ActFrame" src="about:blank" width="100%" height="300" style="display:none"></iframe>
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

        if ($("#cgrs").val() == "CS") {//客發不顯示發文方式
            $("#tr_send_way").hide();
        } else {
            $("#send_wayM").prop("checked", true);
            $("#hsend_way").val("M")
        }
        $("#tr_ctrl_date,#tr_print,#tr_print_date").hide();//稽催期間/列印選擇/已列印日期
        $("#sdate,#edate").val("<%#DateTime.Today.ToShortDateString()%>");
        $("#sctrl_date").val("<%#DateTime.Today.AddDays(-5).ToShortDateString()%>");
        $("#ectrl_date").val("<%#DateTime.Today.ToShortDateString()%>");
        getRsNo();
        if ("<%#rs_no%>" != "") {
            window.parent.tt.rows = "30%,70%";
            $("#sdate,#edate").val("<%#step_date%>");
            $("#srs_no,#ers_no").val("<%#rs_no%>");
        }
        $("#gs_date").val($("#edate").val());
    }

    //[重填]
    $("#btnRest").click(function (e) {
        reg.reset();
        this_init();
    });

    //////////////////////////////////////////////////////
    $("#sctrl_date,#ectrl_date,#sprint_date,#eprint_date,#mpstep_date").blur(function (e) {
        ChkDate(this);
    });

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

    //發文方式
    $("input[name='send_way']").click(function (e) {
        $("#hsend_way").val($(this).val());

        if ($(this).val() == "E" || $(this).val() == "EA") {//電子送件/註冊費電子送件
            $("#span_Email_msg,#span_gs_email").show();//Email通知總管處
        } else {
            $("#span_Email_msg,#span_gs_email").hide();//Email通知總管處
        }
    });

    //報表種類
    function rprtkind_onclick(prtkind, pword) {
        $("#prtkind").val(prtkind);
        $("#haveword").val(pword);

        //511:官方發文明細、512:官方發文規費明細、513:官發收入明細、514:官方發文回條
        if (prtkind == "523") {
            $("#tr_ctrl_date").show();//稽催期間
            $("#tr_date,#tr_rs_no").hide();//發文日期/發文字號
        } else {
            $("#tr_ctrl_date").hide();//稽催期間
            $("#tr_date,#tr_rs_no").show();//發文日期/發文字號
        }

        //if (prtkind == "513") {//只可印 2003/12/1之後的案件
        //    var bdate = CDate("2003/12/1");
        //    var sdate = CDate($("#sdate").val());
        //    var edate = CDate($("#edate").val());
        //    if ($("#sdate").val()==""||sdate.getTime() < bdate.getTime()) $("#sdate").val("2003/12/1");
        //    if ($("#edate").val()==""||edate.getTime() < bdate.getTime()) $("#edate").val("2003/12/1");
        //    $("#tr_send_way").hide();//發文方式
        //} else {
        if ($("#sdate").val() == "") $("#sdate").val("<%#DateTime.Today.ToShortDateString()%>");
        if ($("#edate").val() == "") $("#edate").val("<%#DateTime.Today.ToShortDateString()%>");

        if (prtkind == "513" || prtkind == "511ZS" || $("#cgrs").val() == "CS") {//本發及客發不顯示發文方式
            $("#tr_send_way").hide();//發文方式
        } else {
            $("#tr_send_way").show();//發文方式
        }
        //}

        if (prtkind == "522") {
            $("#tr_print,#tr_print_date").show();//列印選擇/已列印日期
        } else {
            $("#tr_print,#tr_print_date").hide();//列印選擇/已列印日期
            $("#tr_print").hide();//列印選擇
            $("#sprint_date,#eprint_date").val("");
        }

        if (prtkind == "513" || prtkind == "521" && prtkind == "511" && prtkind == "512" && prtkind == "514" && prtkind == "511ZS") {
            getRsNo();
        }
    }

    //抓發文字號
    function getRsNo() {
        if (ChkDate($("#sdate"))) return false;
        if (ChkDate($("#edate"))) return false;

        if ($("#sdate").val() != "" || $("#edate").val() != "") {
            if ($("#prtkind").val() == "513") {//只可印 2003/12/1之後的案件
                var bdate = CDate("2003/12/1");
                var sdate = CDate($("#sdate").val());
                var edate = CDate($("#edate").val());
                if ($("#sdate").val() == "" || sdate.getTime() < bdate.getTime()) $("#sdate").val("2003/12/1");
                if ($("#edate").val() == "" || edate.getTime() < bdate.getTime()) $("#edate").val("2003/12/1");
            }

            var url = "";
            if ($("#prtkind").val() == "511ZS") {
                url = "/ajax/json_rs_no.aspx?branch=<%#Session["seBranch"]%>&cgrs=ZS&sdate=" + $("#sdate").val() + "&edate=" + $("#edate").val() + "&prtkind=" + $("#prtkind").val();
            } else {
                url = "/ajax/json_rs_no.aspx?branch=<%#Session["seBranch"]%>&cgrs=" + $("#cgrs").val() + "&sdate=" + $("#sdate").val() + "&edate=" + $("#edate").val() + "&prtkind=" + $("#prtkind").val() + "&send_way=" + $("#hsend_way").val();
            }

            $.ajax({
                type: "get",
                url: getRootPath() + url,
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
                    $("#dialog").html("<a href='" + this.url + "' target='_new'>抓取發文字號！<u>(點此顯示詳細訊息)</u></a><hr>" + xhr.responseText);
                    $("#dialog").dialog({ title: '抓取發文字號！', modal: true, maxHeight: 500, width: "90%" });
                }
            });
        }
    }

    $("#sdate").blur(function (e) {
        getRsNo();
    });
    $("#edate").blur(function (e) {
        $("#gs_date").val($("#edate").val());
        getRsNo();
    });

    //列印選擇
    $("input[name='tfx_print']").click(function (e) {
        if ($(this).val() == "Y") {//已列印
            $("#tr_print_date").show();
            $("#sprint_date,#eprint_date").val(Today().format("yyyy/M/d"));
        }else {
            $("#tr_print_date").hide();
            $("#sprint_date,#eprint_date").val("");
        }
    });

    //[列印]
    $("#btnSubmit").click(function (e) {
        if ($("#prtkind").val()==""){
            alert("報表種類必須選擇!!!");
            return false;
        }
        if ($("#cgrs").val()=="GS"){
            if ($("#prtkind").val()!="511ZS"&&$("#prtkind").val()!="513"){
                if ($("input[name='send_way']:checked").length==0) {
                    alert("發文方式必須選擇!!!");
                    return false;
                    }
            }
        }

        if ($("#prtkind").val()=="513"||$("#prtkind").val()=="521"){
            if (ChkDate($("#sdate"))) return false;
            if (ChkDate($("#edate"))) return false;
            if ($("#sdate").val() != "" && $("#edate").val() != "") {
                if (CDate($("#sdate").val()).getTime() > CDate($("#edate").val()).getTime()) {
                    alert("起始發文日期不可大於終止發文日期!!!");
                    return false;
                }
            }
        }

        if ($("#srs_no").val()=="" && $("#ers_no").val()==""){
            getRsNo();
        }
	    if ($("#srs_no").val().Left(1)=="B" || $("#ers_no").val().Left(1)=="B"){
            if (chkNum($("#srs_no").val().substring(3), "發文字號起始號")) return false;
            if (chkNum($("#ers_no").val().substring(3), "發文字號迄止號")) return false;
	    }else{
            if (chkNum($("#srs_no").val().substring(2), "發文字號起始號")) return false;
            if (chkNum($("#ers_no").val().substring(2), "發文字號迄止號")) return false;
	    }
        if ($("#srs_no").val()!="" && $("#ers_no").val()!=""){
            if ($("#srs_no").val()>$("#srs_no").val()){
                alert("起始發文字號不可大於終止發文字號!!!");
                return false;
            }
        }

        if (chkNum($("#sseq").val(),"本所編號起始號")) return false;
        if (chkNum($("#eseq").val(),"本所編號迄止號")) return false;
        if ($("#sseq").val()!="" && $("#eseq").val()!=""){
            if (CInt($("#sseq").val())>CInt($("#eseq").val())){
                alert("起始本所編號不可大於終止本所編號!!!");
                return false;
            }
        }
        if (chkNum($("#scust_seq").val(),"客戶編號起始號")) return false;
        if (chkNum($("#ecust_seq").val(),"客戶編號迄止號")) return false;
        if ($("#scust_seq").val()!="" && $("#ecust_seq").val()!=""){
            if (CInt($("#scust_seq").val())>CInt($("#ecust_seq").val())){
                alert("起始客戶編號不可大於終止客戶編號!!!");
                return false;
            }
        }

        if ($("#sprint_date").val()!="" && $("#eprint_date").val()!=""){
            if (CDate($("#sprint_date").val()).getTime()>CDate($("#eprint_date").val()).getTime()){
                alert("起始列印日期不可大於終止列印日期!!!");
                return false;
            }
        }

        if ($("#prtkind").val() == "522") {//客戶函若超過50筆，要縮小範圍
            var url = "json_data411.aspx?cgrs=" + $("#cgrs").val() + "&sdate=" + $("#sdate").val() + "&edate=" + $("#edate").val() +
                "&srs_no=" + $("#srs_no").val() + "&ers_no=" + $("#ers_no").val() + "&sseq=" + $("#sseq").val() + "&eseq=" + $("#eseq").val() +
                "&scode1=" + $("#in_scode").val() + "&cust_area=" + $("#cust_area").val() + "&scust_seq=" + $("#scust_seq").val() + "&ecust_seq=" + $("#ecust_seq").val();
            ajaxScriptByGet("檢查客戶函筆數", url);
            if (jCount == 0) {//由ajaxScriptByGet呼叫的程式指定值
                alert("無資料需產生");
            } else if (jCount > 50) {
                alert("客戶函超過50筆，請縮小範圍列印!!!");
                return false;
            }
        }

        //511:官方發文明細、512:官方發文規費明細、513:官發收入明細、514:官方發文回條、515：回應追蹤報表
        //521:客戶發文明細、522:客戶函、523:年費稽催明細、524:領証通知明細、
        //511ZS:本所發文明細
        //J：期限管制報表、K：案件狀態列印
        if($("#haveword").val()=="Y"){
            reg.target = "ActFrame";
            reg.action = "brta" + $("#prtkind").val() + "Print.aspx";
            reg.submit();
        }else{
            //var url = "brta" + $("#prtkind").val() + "Print.aspx";
            //if($("#hsend_way").val()=="E"||$("#hsend_way").val()=="EA")
            //    url = "brta" + $("#prtkind").val() + "Print_word.aspx";
            //url+="?"+$("#reg").serialize();
            //window.open(url,"myWindowOne1", "width=750px, height=550px, top=10, left=10, toolbar=no, menubar=no, location=no, directories=no, status=no, scrollbars=yes,titlebar=no");
        
            var url = "brta" + $("#prtkind").val() + "Print.aspx";
            if ($("#hsend_way").val() == "E" || $("#hsend_way").val() == "EA") {
                reg.target = "ActFrame";
                reg.action = "brta" + $("#prtkind").val() + "Print_word.aspx";
                reg.submit();
            } else {
                var url = "brta" + $("#prtkind").val() + "Print.aspx";
                url += "?" + $("#reg").serialize();
                window.open(url,"myWindowOne1", "width=750px, height=550px, top=10, left=10, toolbar=no, menubar=no, location=no, directories=no, status=no, scrollbars=yes,titlebar=no");
                //$('#dialog')
                //.html('<iframe style="border: 0px;" src="' + url + '" width="100%" height="100%"></iframe>')
                //.dialog({ autoOpen: true, modal: true, height: 550, width: 750, title: "列印" });
            }
        }
    });

    function formEmail() {
        <%
        string tsubject = "";//主旨
        string strto = "";//收件者
        string strcc = "";//副本
        string strbcc = "";//密件副本
        string Sender=Sys.GetSession("scode");//寄件者
        if (Sys.Host=="web08") {
            strto = "m1583;";
            strcc="";
            strbcc = "";
            tsubject = "測試-";
        } else if (Sys.Host == "web10") {
            strto = Sys.GetSession("scode") + ";";
            strcc = "";
            strbcc = "m1583;";
            tsubject = "測試-";
        } else {
            strto = emg_scode + ";";
            strcc = emg_agscode + ";";//2016/4/19修改
            strbcc = "m1583;";
        }
        tsubject += "國內商標案件管理網路作業系統─每日" + Session["SeBranchName"] + "官發發文明細通知";
        %>
        var tsubject = "<%=tsubject%>";//主旨
        var strto = "<%=strto%>";//收件者
        var strcc = "<%=strcc%>";//副本
        var strbcc = "<%=strbcc%>";//密件副本

        //511:官方發文明細、512:官方發文規費明細、514:官方發文回條 是否已產生
        //GSE-514T-20120106.doc、GSE-511T-20120106.doc、GSE-512T-20120106.doc
        var attach_path = "reportword/" + (new Date()).format("yyyyMM") + "/";
        var tdate = (new Date($("#gs_date").val())).format("yyyyMMdd");

        var attach_name = "GS" + $("#hsend_way").val() + "-514T-" + tdate + ".docx,GS" + $("#hsend_way").val() + "-511T-" + tdate + ".docx,GS" + $("#hsend_way").val() + "-512T-" + tdate + ".docx";
        var arug = "cgrs=" + $("#cgrs").val() + "&attach_path=" + attach_path + "&attach_name=" + attach_name;
        arug += "&msg=" + escape("官方發文回條,官方發文明細,官方發文規費明細");

        var rtnmsg = "";
        //檢查檔案是否存在
        $.ajax({
            type: "get",
            url: getRootPath() + "/ajax/json_chkFile.aspx?" + arug,
            async: false,
            cache: false,
            success: function (json) {
                var JSONdata = $.parseJSON(json);
                $.each(JSONdata, function (i, item) {
                    if (item.msg != "") rtnmsg += item.msg + "\n\n";
                });
            },
            error: function () { toastr.error("<a href='" + this.url + "' target='_new'>檔案檢查失敗！<BR><b><u>(點此顯示詳細訊息)</u></b></a>"); }
        });
        if (rtnmsg != "") alert(rtnmsg);

        //Mail To 總收發文
        var host = getRootPath();
        if ($("#hsend_way").val() == "E") {
            tsubject += "【電子送件】";
        } else if ($("#hsend_way").val() == "EA") {
            tsubject += "【註冊費電子送件】";
        }

        var tbody = "致：總管處-總務部-程序組";
        tbody += "%0A";
        tbody += "%0A【通 知 日 期】：" + (new Date()).format("yyyy/M/d");
        tbody += "%0A【發 文 日 期】：" + $("#gs_date").val();
        tbody += "%0A";
        tbody += "%0A◎請至總收發網路系統→商標收發文→商標區所發文送件確認作業。";
        tbody += "%0A";
        tbody += "%0A附件如下：";
        tbody += "%0A%0A官方發文明細 " + host + "/ReportWord/" + (new Date()).format("yyyyMM") + "/GS" + $("#hsend_way").val() + "-511T-" + tdate + ".docx";
        if (rtnmsg.indexOf("官方發文明細檔案尚未產生") > -1) {
            tbody += " (本次發文未產生) ";
        }
        tbody += "%0A%0A官方發文規費明細 " + host + "/ReportWord/" + (new Date()).format("yyyyMM") + "/GS" + $("#hsend_way").val() + "-512T-" + tdate + ".docx";
        if (rtnmsg.indexOf("官方發文規費明細檔案尚未產生") > -1) {
            tbody += " (本次發文未產生) ";
        }
        tbody += "%0A%0A官方發文回條 " + host + "/ReportWord/" + (new Date()).format("yyyyMM") + "/GS" + $("#hsend_way").val() + "-514T-" + tdate + ".docx";
        if (rtnmsg.indexOf("官方發文回條檔案尚未產生") > -1) {
            tbody += " (本次發文未產生) ";
        }

        ActFrame.location.href = "mailto:" + strto + "?subject=" + tsubject + "&body=" + tbody + "&cc=" + strcc;//+"&bcc="+ strbcc;
    }
</script>
