<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data" %>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<script runat="server">
    protected string HTProgCap = HttpContext.Current.Request["prgname"];//功能名稱
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
    
        if (cgrs == "CR") HTProgCap = "<font color=blue>客戶</font>";
        if (cgrs == "GR") HTProgCap = "<font color=blue>官方</font>";
        HTProgCap += "收文報表列印";
        
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
        
        if ((HTProgRight & 2) > 0) {
            StrFormBtn += "<input type=\"button\" id=\"btnSrch\" value=\"列　印\" class=\"cbutton bsubmit\" />\n";
            StrFormBtn += "<input type=\"button\" id=\"btnRest\" value=\"重　填\" class=\"cbutton\" />\n";
        }
        
        //報表種類
        DataTable dtkind = Sys.getCustCode("rpt_" + cgrs.ToLower() + "_t", "", "");
        html_rprtkind = dtkind.Radio("rprtkind", "{cust_code}", "{code_name}", "onclick=\"rprtkind_onclick('{cust_code}','{mark1}',this.value)\"", 3);

        //洽案營洽
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
		        </td>
	        </tr>
            <TR id="tr_sdate">
                <td class="lightbluetable" align="right">收文日期：</td>
		        <td class="whitetablebg" align="left" colspan=3>
			        <input type="text" id="sdate" name="sdate" size="10" class="dateField" onchange="getRsNo()">～
			        <input type="text" id="edate" name="edate" size="10" class="dateField" onchange="getRsNo()">
		        </td>
	       </TR>
	        <tr id="tr_rs_no">
		        <td class="lightbluetable" align="right">收文字號：</td>
		        <td class="whitetablebg" align="left" colspan=3>
			        <input type="text" id="srs_no" name="srs_no" size="11" maxlength=10>～
			        <input type="text" id="ers_no" name="ers_no" size="11" maxlength=10>
		        </td>
	        </tr>
	        <tr id="tr_seq">
		        <td class="lightbluetable" align="right">本所編號：</td>
		        <td class="whitetablebg" align="left" colspan=3>
			        <input type="text" id="sseq" name="sseq" size="<%#Sys.DmtSeq%>" maxlength=<%#Sys.DmtSeq%>>～
			        <input type="text" id="eseq" name="eseq" size="<%#Sys.DmtSeq%>" maxlength=<%#Sys.DmtSeq%>>
			        <select id=seq1 name=seq1>
				        <option value="" selected>請選擇</option>
                        <option value="_">一般</option>
				        <option value="C">著作權</option>
                        <option value="Z">雜卷</option>
			        </select>
		        </td>
	        </tr>
	        <tr id="tr_bdate_days">
		        <td class=lightbluetable align="right">基準日期：</td>
		        <td class="whitetablebg" align="left">
			        <input type="text" id="bdate" name="bdate" size="10" maxlength=10 class="dateField">
		        </td>
		        <td class=lightbluetable align="right">稽催天數：</td>
		        <td class="whitetablebg" align="left">
			        <input type="text" id="days"  name="days" size="2" maxlength=2 value=5>
		        </td>
	        </tr>
	        <tr id="tr_scode1">
		        <td class=lightbluetable align="right" id=salename  width="15%">洽案營洽：</td>
		        <td class=whitetablebg align="left" colspan=3>
			        <input type=hidden name=scode1 id=scode1>
			        <select id='sscode1' name='sscode1' onchange="reg.scode1.value=this.value">
		            <option value="" style="color:blue" selected>全部</option>
                    <%#html_sscode1%>
			        </select>
		        </td>
	        </tr>
	        <tr id="tr_in_date">
                <td class="lightbluetable" align="right">立案日期：</td>
		        <td class="whitetablebg" align="left" colspan=3>
			        <input type="text" id="isdate" name="isdate" size="10" class="dateField" onblur="ChkDate(this)">～
			        <input type="text" id="iedate" name="iedate" size="10" class="dateField" onblur="ChkDate(this)">
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
           <TR id="tr_print">
		        <TD class=lightbluetable align=right>列印選擇：</TD>
		        <TD class=whitetablebg align=left colspan=3>
                    <input type=hidden name=hprint id=hprint>
		            <label><input type=radio value="N" name=rprint>尚未列印</label>
			        <label><input type=radio value="Y" name=rprint>已列印</label>
		        </TD>
	        </TR>
	        <tr id="tr_scan">
		        <td class="lightbluetable" align="right">掃描選擇：</td>
		        <td class="whitetablebg" align="left" colspan=3>
			        <input type="hidden" name="hscan" id="hscan">
			        <label><input type="radio" name="rscan" value="N">不需掃描</label>
			        <label><input type="radio" name="rscan" value="Y">需要掃描</label>
			        <label><input type="radio" name="rscan" value="*" checked>不指定</label>
		        </td>
	        </tr>
	        <tr id="tr_receive_way">
		        <td class="lightbluetable" align="right" >來文方式：</td>
		        <td class="whitetablebg" align="left" colspan=3>
		            <input type="hidden" name="hreceive_way" id="hreceive_way" value="">
			        <input type="radio" name="receive_way" value="R5,R9">紙本收文<!--非電子收文及非電子公文-->
			        <input type="radio" name="receive_way" value="R5">電子收文
			        <input type="radio" name="receive_way" value="R9">電子公文
			        <input type="radio" name="receive_way" value="" checked>不指定
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

        init();
        $("#sdate,#edate,#bdate,#isdate,#iedate").val("<%#DateTime.Today.ToShortDateString()%>");
        getRsNo();
        if ("<%#rs_no%>" != "") {
            window.parent.tt.rows = "30%,70%";
            $("#sdate,#edate").val("<%#step_date%>");
            $("#srs_no,#ers_no").val("<%#rs_no%>");
        }
    }

    //[重填]
    $("#btnRest").click(function (e) {
        reg.reset();
        this_init();
    });

    //////////////////////////////////////////////////////
    function init() {
        $("#tr_seq").hide();//本所編號
        $("#tr_bdate_days").hide();//基準日期
        $("#tr_scode1").hide();//洽案營洽
        $("#tr_in_date").hide();//立案日期
        $("#tr_cust").hide();//客戶編號
        $("#tr_print").hide();//列印選擇
        $("#tr_scan").hide();//掃描選擇
        $("#tr_receive_way").hide();//來文方式
        $("#hprint").val("");//列印選擇
        $("#hscan").val("*");//掃描選擇
    }

    function getRsNo() {
        if ($("#sdate").val() != "" || $("#edate").val() != "") {

            $.ajax({
                type: "get",
                url: getRootPath() + "/ajax/json_rs_no.aspx?branch=<%#Session["seBranch"]%>&cgrs=" + $("#cgrs").val() + "&sdate="+ $("#sdate").val() + "&edate=" + $("#edate").val(),
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

    //列印選擇
    $("input[name='rprint']").click(function (e) {
        $("#hprint").val($(this).val());
    });

    //掃描選擇
    $("input[name='rscan']").click(function (e) {
        $("#hscan").val($(this).val());
    });

    //來文方式
    $("input[name='receive_way']").click(function (e) {
        $("#hreceive_way").val($(this).val());
    });

    //報表種類
    function rprtkind_onclick(prtkind,pword,pvalue){
        $("#prtkind").val(prtkind);
        $("#haveword").val(pword);
        init();

        if ($("#cgrs").val() == "CR") {
            //411:客收承辦單、412:客收明細、413:案件總簿明細、414:案件總簿簡表
            if (pvalue == "411") {
                $("#tr_seq").show();//本所編號
                $("#tr_print").show();//列印選擇
                $("input[name='rprint'][value='N']").prop("checked", true).triggerHandler("click");
            }
            if (pvalue == "413" || pvalue == "414") {
                $("#tr_sdate").hide();//收文日期
                $("#tr_rs_no").hide();//收文字號
                $("#tr_seq").show();//本所編號
                $("#tr_cust").show();//客戶編號
                $("#tr_scode1").show();//洽案營洽
            } else {
                $("#tr_sdate").show();//收文日期
                $("#tr_rs_no").show();//收文字號
            }
        }

        if ($("#cgrs").val() == "GR") {
            //421:官收承辦單、422:官收明細
            if (pvalue == "421") {
                $("#prtkind").val("411");//報表同客收承辦單
                $("#tr_seq").show();//本所編號
                $("#tr_print").show();//列印選擇
                $("#tr_scan").show();//掃描選擇
                $("#tr_receive_way").hide();//來文方式
                $("input[name='rprint'][value='N']").prop("checked", true).triggerHandler("click");
            }
            if (pvalue == "422") {
                $("#tr_receive_way").show();//來文方式
            }
        }

    }

    $("input[name='dtype']").click(function (e) {
        if ($(this).val() == "1") {//管制日期
            $("#sdate").val(Today().format("yyyy/M/d"));
            $("#edate").val(Today().addDays(1).format("yyyy/M/d"));
        } else if ($(this).val() == "2") {//交辦日期
            $("#sdate").val(Today().format("yyyy/M/1"));
            $("#edate").val(Today().format("yyyy/M/d"));
        }else {//不指定
            $("#sdate").val("");
            $("#edate").val("");
        }
    });

    //[列印]
    $("#btnSrch").click(function (e) {
        if ($("#tr_sdate").is(":visible")) {
            if ($("#sdate").val() == "" || $("#edate").val() == "") {
                alert("收文日期任一不得為空白!!!");
                return false;
            }
        }

        if ($("#srs_no").val() == "" && $("#srs_no").val() == "") {
            getRsNo();
        }

        if ($("#prtkind").val() == "") {
            alert("報表種類必須選擇!!!");
            return false;
        }

        if ($("#cgrs").val() == "CR") {
            if (chkNum($("#scust_seq").val(), "客戶編號起始號")) return false;
            if (chkNum($("#ecust_seq").val(), "客戶編號迄止號")) return false;
            if ($("#scust_seq").val() != "" && $("#ecust_seq").val() != "") {
                if (CInt($("#scust_seq").val()) > CInt($("#ecust_seq").val())) {
                    alert("起始客戶編號不可大於終止客戶編號!!!");
                    return false;
                }
            }
            if ($("#prtkind").val() == "413" || $("#prtkind").val() == "414") {
                if ($("#scust_seq").val() == "" && $("#ecust_seq").val() == "" && $("#sseq").val() == "" && $("#eseq").val() == "") {
                    alert("本所編號或客戶編號需輸入其一!!!");
                    return false;
                }
            }
        }

        if ($("#prtkind").val() == "411" || $("#prtkind").val() == "421") {//承辦單若超過50筆，要縮小範圍
            var url = "json_data411.aspx?cgrs=" + $("#cgrs").val() + "&sdate=" + $("#sdate").val() + "&edate=" + $("#edate").val() +
                "&srs_no=" + $("#srs_no").val() + "&ers_no=" + $("#ers_no").val() + "&sseq=" + $("#sseq").val() + "&eseq=" + $("#eseq").val() +
                "&seq1=" + $("#seq1").val() + "&hprint=" + $("#hprint").val();
            ajaxScriptByGet("檢查承辦單筆數", url);
            if (jCount == 0) {//由ajaxScriptByGet呼叫的程式指定值
                alert("無資料需產生");
            } else if (jCount > 50) {
                alert("承辦單超過50筆，請縮小範圍列印!!!");
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
