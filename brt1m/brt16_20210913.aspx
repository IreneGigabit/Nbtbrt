<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data" %>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<script runat="server">
    protected string HTProgCap = "案件交辦單列印";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "brt16";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
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
        StrFormBtnTop += "<a class=\"imgRefresh\" href=\"javascript:void(0);\" >[重新整理]</a>\n";
        StrFormBtnTop += "<a class=\"imgQry\" href=\"javascript:void(0);\" >[查詢條件]</a>\n";
        if ((HTProgRight & 2) > 0) {
            StrFormBtn += "<input type=\"button\" id=\"btnSrch\" value=\"查　詢\" class=\"cbutton bsubmit\" />\n";
            StrFormBtn += "<input type=\"button\" id=\"btnRest\" value=\"重　填\" class=\"cbutton\" />\n";
        }

        using (DBHelper conn = new DBHelper(Conn.btbrt).Debug(false)) {
            //案性
            SQL = "SELECT RS_code, RS_detail FROM code_br WHERE dept = 'T' AND cr = 'Y' AND no_code='N' ";
            SQL += "and (end_date is null or end_date = '' or end_date > getdate()) ";
            SQL += " ORDER BY rs_type desc,rs_class ,rs_code";
            pfx_Arcase = Util.Option(conn, SQL, "{rs_code}", "{rs_code}--{rs_detail}");

            //洽案營洽清單
            DataTable dt = new DataTable();
            if ((HTProgRight & 64) != 0) {
                SQL = "select scode,sc_name from sysctrl.dbo.vscode_type where branch='" + Session["seBranch"] + "' and grpid like '" + Session["Dept"] + "%' and work_type='sales' order by scode";
                conn.DataTable(SQL, dt);
                td_tscode = "<select id='tfx_in_Scode' name='tfx_in_Scode'><option value='' style='color:blue'>全部</option>" + dt.Option("{scode}", "{scode}_{sc_name}",false,Sys.GetSession("scode")) + "</select>";
            } else {
                td_tscode = "<input type='text' id='tfx_in_Scode' name='tfx_in_Scode' readonly class='SEdit' value='" + Session["se_scode"] + "'>";
                td_tscode += "<input type='text' id='ScodeName' name='ScodeName' readonly class='SEdit' value='" + Session["sc_name"] + "'>";
            }
        }
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

<form id="regPage" name="regPage" method="post">
    <input type="hidden" id="prgid" name="prgid" value="<%=prgid%>">

    <div id="id-div-slide">
        <table id="qryForm" border="0" class="bluetable" cellspacing="1" cellpadding="2" width="70%" align="center">	
			<TR>
				<td class="lightbluetable" align="right">承辦案性 :</td>
				<td class="whitetablebg" align="left">
                    <select id="pfx_Arcase" name="pfx_Arcase"><%#pfx_Arcase%></select>
				</td> 
			</TR>
			<TR>
				<td class="lightbluetable" align="right">營洽人員 :</td>
		        <TD class=whitetablebg align=left><%#td_tscode%></TD>
            </TR>
	        <tr>
		        <td class="lightbluetable" align="right">序號選擇 :</td>
		        <td class="whitetablebg" align="left">
			        <label><input type="radio" name="new" value="in_no" checked onclick="$('#span_date').html('洽案')">接洽序號</label>
 			        <label><input type="radio" name="new" value="case_no" onclick="$('#span_date').html('交辦')">交辦序號</label>
 		        </td>
	        </tr>
	        <tr>
		        <td class="lightbluetable" align="right">序號範圍 :</td>
		        <td class="whitetablebg" align="left" colspan="3">
                    <input type="text" id="sin_no" name="sin_no" size="12" maxlength="12">～<input type="text" id="ein_no" name="ein_no" size="12" maxlength="12">
		            <input type="hidden" id="sfx_in_no" name="sfx_in_no" size="12" maxlength="12">
		            <input type="hidden" id="efx_in_no" name="efx_in_no" size="12" maxlength="12">
		            <input type="hidden" id="sfx_case_no" name="sfx_case_no" size="12" maxlength="12">
		            <input type="hidden" id="efx_case_no" name="efx_case_no" size="12" maxlength="12">
		        </td>
	        </tr>
	        <tr>
		        <td class="lightbluetable" align="right"><span id="span_date">接洽</span>日期 :</td>
		        <td class="whitetablebg" align="left" colspan="3">
		        <input type="text" id="sin_date" name="sin_date" size="10" class="dateField">～
		        <input type="text" id="ein_date" name="ein_date" size="10" class="dateField">
		        <input type="hidden" id="sfx_in_date" name="sfx_in_date" size="10">
		        <input type="hidden" id="efx_in_date" name="efx_in_date" size="10">
		        <input type="hidden" id="sfx_case_date" name="sfx_case_date" size="10">
		        <input type="hidden" id="efx_case_date" name="efx_case_date" size="10">
		        </td>
	        </tr>
	        <tr>
		        <td class="lightbluetable" align="right">作業狀態 :</td>
		        <td class="whitetablebg" align="left" colspan=3>
		            <input type="radio" name="tfx_stat_code" value="NN">未交辦	
		            <input type="radio" name="tfx_stat_code" value="YN">已交辦
		            <input type="radio" name="tfx_stat_code" value="YY">簽准	
		            <input type="radio" name="tfx_stat_code" value="NX">不准
		            <input type="radio" name="tfx_stat_code" value="YZ">程序確認
		            <input type="radio" name="tfx_stat_code" value="" checked>不指定
		        </td>
	        </tr>
        </table>
        <br>
        <table id="tabBtn" border="0" width="100%" cellspacing="0" cellpadding="0" align="center">
	        <tr><td width="100%" align="center">
			    <%#StrFormBtn%>
	        </td></tr>
        </table>
    </div>

    <div id="divPaging" style="display:none">
    <TABLE border=0 cellspacing=1 cellpadding=0 width="98%" align="center">
	    <tr>
		    <td colspan=2 align=center>
			    <font size="2" color="#3f8eba">
				    第<font color="red"><span id="NowPage"></span>/<span id="TotPage"></span></font>頁
				    | 資料共<font color="red"><span id="TotRec"></span></font>筆
				    | 跳至第<select id="GoPage" name="GoPage" style="color:#FF0000"></select>頁
				    <span id="PageUp">| <a href="javascript:void(0)" class="pgU" v1="">上一頁</a></span>
				    <span id="PageDown">| <a href="javascript:void(0)" class="pgD" v1="">下一頁</a></span>
				    | 每頁筆數:<select id="PerPage" name="PerPage" style="color:#FF0000">
					    <option value="10" selected>10</option>
					    <option value="20">20</option>
					    <option value="30">30</option>
					    <option value="50">50</option>
				    </select>
                    <input type="hidden" name="SetOrder" id="SetOrder" />
			    </font>
		    </td>
	    </tr>
    </TABLE>
    </div>
    <%#DebugStr%>
</form>

<div align="center" class="noData" style="display:none">
	<font color="red">=== 目前無資料 ===</font>
</div>

<table style="display:none" border="0" class="bluetable" cellspacing="1" cellpadding="2" width="98%" align="center" id="dataList">
	<thead>
        <Tr>
            <td align="center" class="lightbluetable" style="cursor:pointer">作業</td>
	        <td align="center" class="lightbluetable">營洽-接洽序號</td>
	        <td align="center" class="lightbluetable">接洽日期</td>	
	        <td align="center" class="lightbluetable">客戶名稱</td>
	        <td align="center" class="lightbluetable">案件名稱</td>	
	        <td align="center" class="lightbluetable">類別</td>
	        <td align="center" class="lightbluetable">案性</td>
	        <td align="center" class="lightbluetable">服務費</td>
	        <td align="center" class="lightbluetable">規費</td>
	        <td align="center" class="lightbluetable">轉帳<br>費用</td>
	        <td align="center" class="lightbluetable">合計</td>
        </tr>
	</thead>
	<tbody>
	</tbody>
    <script type="text/html" id="data_template"><!--清單樣板-->
	    <tr class='{{tclass}}' id='tr_data_{{nRow}}'>
	        <td class="whitetablebg" align="center">
                <a href="{{rptasp}}" target="Eblank">列印</A>
                <input type=hidden id="in_no_{{nRow}}" name="in_no_{{nRow}}" value="{{in_no}}">
            </td>
	        <td class="whitetablebg" align="center">
                <a href="{{urlasp}}" target="Eblank">{{sc_name}}-{{in_no}}</A>
            </td>
	        <td class="whitetablebg" align="center"><a href="{{urlasp}}" target="Eblank">{{in_date}}</A></td> 
	        <td class="whitetablebg" align="center"><a href="{{urlasp}}" target="Eblank">{{cust_name}}</A></td> 
	        <td class="whitetablebg" align="center"><a href="{{urlasp}}" target="Eblank">{{appl_name}}</A></td>
	        <td class="whitetablebg" align="center"><a href="{{urlasp}}" target="Eblank">{{class}}</A></td>
	        <td class="whitetablebg" align="center"><a href="{{urlasp}}" target="Eblank">{{case_name}}</A></td>
	        <td class="whitetablebg" align="center"><a href="{{urlasp}}" target="Eblank">{{service}}</A></td>
	        <td class="whitetablebg" align="center"><a href="{{urlasp}}" target="Eblank">{{fees}}</A></td>
	        <td class="whitetablebg" align="center"><a href="{{urlasp}}" target="Eblank">{{oth_money}}</A></td>
	        <td class="whitetablebg" align="center"><a href="{{urlasp}}" target="Eblank">{{afee}}</td>
	    </tr>
    </script>
</TABLE>
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
        $("#sin_date").val((new Date()).format("yyyy/M/1"));
        $("#ein_date").val(Today().format("yyyy/M/d"));
        $("input.dateField").datepick();
    }

    //[查詢]
    $("#btnSrch").click(function (e) {
        if ($("#pfx_Arcase").val() == "") {
            alert("承辦案性不得為空白!");
            $("#pfx_Arcase").focus();
            return false;
        }

        if ($("#sin_no").val() != "" && !IsNumeric($("#sin_no").val())) {
            alert("序號範圍(起)錯誤,請重新輸入!!");
            $("#sin_no").focus();
            return false;
        }

        if ($("#ein_no").val()!=""&&!IsNumeric($("#ein_no").val())) {
            alert("序號範圍(迄)錯誤,請重新輸入!!");
            $("#ein_no").focus();
            return false;
        }
		
        if ($("#sin_no").val()!=""&&$("#ein_no").val()!="") {
            if(CInt($("#sin_no").val())>CInt($("#ein_no").val())){
                alert("序號範圍(起),不得大於序號範圍(迄)!!");
                return false;
            }
        }
		
        $("#sfx_in_no,#efx_in_no,#sfx_case_no,#efx_case_no,#sfx_in_date,#efx_in_date,#sfx_case_date,#efx_case_date").val("");
        if($("input[name='new']:eq(0)").prop("checked")==true){
            $("#sfx_in_no").val($("#sin_no").val());
            $("#efx_in_no").val($("#ein_no").val());
            $("#sfx_in_date").val($("#sin_date").val());
            $("#efx_in_date").val($("#ein_date").val());
        }else{
            $("#sfx_case_no").val($("#sin_no").val());
            $("#efx_case_no").val($("#ein_no").val());
            $("#sfx_case_date").val($("#sin_date").val());
            $("#efx_case_date").val($("#ein_date").val());
        }

        $("#dataList>thead tr .setOdr span").remove();
        $("#SetOrder").val("");

        goSearch();
    });

    //執行查詢
    function goSearch() {
        window.parent.tt.rows = '100%,0%';
        $("#divPaging,#dataList,.noData,.haveData").hide();
        $("#dataList>tbody tr").remove();
        nRow = 0;

        $.ajax({
            url: "<%#HTProgPrefix%>_List.aspx",
            type: "get",
            async: false,
            cache: false,
            data: $("#regPage").serialize(),
            success: function (json) {
                if (!isJson(json) || $("#chkTest").prop("checked")) {
                    $("#dialog").html("<a href='" + this.url + "' target='_new'>Debug！<u>(點此顯示詳細訊息)</u></a><hr>" + json);
                    $("#dialog").dialog({ title: 'Debug！', modal: true, maxHeight: 500, width: "90%" });
                    return false;
                }
                var JSONdata = $.parseJSON(json);
                //////更新分頁變數
                var totRow = parseInt(JSONdata.totrow, 10);
                if (totRow > 0) {
                    $("#divPaging,#dataList,.haveData").show();
                } else {
                    $(".noData").show();
                }

                var nowPage = parseInt(JSONdata.nowpage, 10);
                var totPage = parseInt(JSONdata.totpage, 10);
                $("#NowPage").html(nowPage);
                $("#TotPage").html(totPage);
                $("#TotRec").html(totRow);
                var i = totPage + 1, option = new Array(i);
                while (--i) {
                    option[i] = ['<option value="' + i + '">' + i + '</option>'].join("");
                }
                $("#GoPage").replaceWith('<select id="GoPage" name="GoPage" style="color:#FF0000">' + option.join("") + '</select>');
                $("#GoPage").val(nowPage);
                nowPage > 1 ? $("#PageUp").show() : $("#PageUp").hide();
                nowPage < totPage ? $("#PageDown").show() : $("#PageDown").hide();
                $("a.pgU").attr("v1", nowPage - 1);
                $("a.pgD").attr("v1", nowPage + 1);
                $("#id-div-slide").slideUp("fast");

                $.each(JSONdata.pagedtable, function (i, item) {
                    nRow++;
                    //複製樣板
                    var copyStr = $("#data_template").text() || "";
                    copyStr = copyStr.replace(/##/g, nRow);
                    var tclass = "";
                    if (nRow % 2 == 1) tclass = "sfont9"; else tclass = "lightbluetable3";
                    copyStr = copyStr.replace(/{{tclass}}/g, tclass);
                    copyStr = copyStr.replace(/{{nRow}}/g, nRow);

                    copyStr = copyStr.replace(/{{in_scode}}/g, item.in_scode);
                    copyStr = copyStr.replace(/{{sc_name}}/g, item.sc_name);
                    copyStr = copyStr.replace(/{{in_no}}/g, item.in_no);
                    copyStr = copyStr.replace(/{{seq}}/g, item.seq);
                    copyStr = copyStr.replace(/{{seq1}}/g, item.seq1);
                    copyStr = copyStr.replace(/{{send_way}}/g, item.send_way);
                    copyStr = copyStr.replace(/{{receipt_title}}/g, item.receipt_title);
                    copyStr = copyStr.replace(/{{receipt_type}}/g, item.receipt_type);
                    copyStr = copyStr.replace(/{{ar_mark}}/g, item.ar_mark);
                    copyStr = copyStr.replace(/{{discount}}/g, item.discount);
                    copyStr = copyStr.replace(/{{discount_chk}}/g, item.discount_chk);
                    copyStr = copyStr.replace(/{{urlasp}}/g, item.urlasp);
                    copyStr = copyStr.replace(/{{rptasp}}/g, item.rptasp);
                    copyStr = copyStr.replace(/{{cust_name}}/g, item.cust_name.Left(5));
                    copyStr = copyStr.replace(/{{fseq}}/g, item.fseq);
                    copyStr = copyStr.replace(/{{appl_name}}/g, item.appl_name.Left(20));
                    copyStr = copyStr.replace(/{{class}}/g, item.class);
                    copyStr = copyStr.replace(/{{case_name}}/g, item.case_name);
                    copyStr = copyStr.replace(/{{service}}/g, item.service);
                    copyStr = copyStr.replace(/{{fees}}/g, item.fees);
                    copyStr = copyStr.replace(/{{oth_money}}/g, item.oth_money);
                    copyStr = copyStr.replace(/{{afee}}/g, item.afee);
                    copyStr = copyStr.replace(/{{case_no}}/g, item.case_no);
                    copyStr = copyStr.replace(/{{cust_area}}/g, item.cust_area);
                    copyStr = copyStr.replace(/{{cust_seq}}/g, item.cust_seq);
                    copyStr = copyStr.replace(/{{stat_code}}/g, item.stat_code);
                    copyStr = copyStr.replace(/{{arcase}}/g, item.arcase);
                    copyStr = copyStr.replace(/{{in_date}}/g, dateReviver(item.in_date, "yyyy/M/d"));

                    $("#dataList>tbody").append(copyStr);
                });
            },
            beforeSend: function (jqXHR, settings) {
                jqXHR.url = settings.url;
            },
            error: function (xhr) {
                $("#dialog").html("<a href='" + this.url + "' target='_new'>資料擷取剖析錯誤！<u>(點此顯示詳細訊息)</u></a><hr>" + xhr.responseText);
                $("#dialog").dialog({ title: '資料擷取剖析錯誤！', modal: true, maxHeight: 500, width: 800 });
                //toastr.error("<a href='" + this.url + "' target='_new'>案件資料載入失敗！<BR><b><u>(點此顯示詳細訊息)</u></b></a>");
            }
        });
    };
    //////////////////////

    //[重填]
    $("#btnRest").click(function (e) {
        regPage.reset();
        this_init();
    });

    $("#Sfx_in_date,#Efx_in_date").blur(function (e) {
        ChkDate(this);
    });

    //[刪除]
    function actDel(row) {
        var pin_scode=$("#inscode_"+row).val();
        var pin_no=$("#inno_"+row).val();
        var pcase_no = $("#case_no_" + row).val();
        var pcase_stat = $("#stat_code_" + row).val();
        var pappl_name = $("#appl_name_" + row).val();
        var pcust_name = "";//$("#cust_name_" + row).val();
        var parcase = $("#arcase_"+row).val();
        var pseq=$("#seq_"+row).val();
        var pseq1=$("#seq1_"+row).val();
        var pcust_areq=$("#cust_area_"+row).val();
        var pcust_seq=$("#cust_seq_"+row).val();
        var chktest=($("#chkTest:checked").val()||"");

        var msg = "接洽序號:" + pin_scode + "-" + pin_no +"\n\n是否確定刪除?";
        if (confirm(msg)){
            var url = getRootPath() + "/brt1m/brt16_save.aspx?submitTask=D"+
                    "&in_scode=" + pin_scode + "&in_no=" + pin_no + "&case_no=" + pcase_no +"&case_stat=" + pcase_stat +
                    "&cappl_name=" + pappl_name + "&ap_cname1=" + pcust_name + "&arcase=" + parcase + "&seq=" + pseq +
                    "&seq1=" + pseq1 + "&cust_area=" + pcust_areq + "&cust_seq=" + pcust_seq+"&chkTest="+chktest;
            ajaxScriptByGet("刪除接洽記錄", url);
        }
    }
</script>
