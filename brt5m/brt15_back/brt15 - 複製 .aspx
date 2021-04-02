<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data" %>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<script runat="server">
    protected string HTProgCap = "案件主檔維護";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "brt15";//程式檔名前綴
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
           //營洽清單
            DataTable dt = new DataTable();
            if ((HTProgRight & 64) != 0) {
                SQL = "select distinct a.scode,b.sc_name,b.end_date ";
                SQL += ",case when b.end_date<getdate() then '*' else '' end star ";
                SQL += ",case when b.end_date<getdate() then 'red' else '' end color ";
                SQL += "from dmt a ";
                SQL += "inner join sysctrl.dbo.scode b on a.scode=b.scode ";
                SQL += "where (a.end_date is null or a.end_date = '') ";
                SQL += "order by a.scode ";
                conn.DataTable(SQL, dt);
                
                td_tscode = "<select id='tfx_Scode' name='tfx_Scode' >";
                td_tscode += dt.Option("{scode}", "{star}{scode}_{sc_name}", "style='color:{color}'",true);
                td_tscode += "<option value='" + Sys.GetSession("seBranch") + Sys.GetSession("dept") + "'>" + Sys.GetSession("seBranch") + Sys.GetSession("dept").ToUpper() + "_部門(開放客戶)</option>";
                td_tscode+="</select>";
            } else {
                td_tscode = "<input type='hidden' id='tfx_Scode' name='tfx_Scode' readonly class='SEdit' value='" + Session["se_scode"] + "'>";
                td_tscode = "<input type='text' id='ScodeName' name='ScodeName' readonly class='SEdit' value='" + Session["sc_name"] + "'>";
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

<form id="regPage" name="regPage" method="post">
    <input type="hidden" id="prgid" name="prgid" value="<%=prgid%>">

    <div id="id-div-slide">
        <table id="qryForm" border="0" class="bluetable" cellspacing="1" cellpadding="2" width="70%" align="center">	
            <tr>
		        <td class="lightbluetable" align="right">案件編號:</td>
		        <td class="whitetablebg" align="left" COLSPAN="3"><input type="text" id="tfx_seq" name="tfx_seq" size="8" maxlength="<%=Sys.DmtSeq%>">-<input type="text" value="_" id="ifx_seq1" name="ifx_seq1" size="<%=Sys.DmtSeq1%>" maxlength="<%=Sys.DmtSeq1%>"></td>
	        </tr>
	        <tr>
		        <td class="lightbluetable" align="right">營　　洽:</td>
		        <td class="whitetablebg" align="left"><%#td_tscode%></td>
		        <td class="lightbluetable" align="right">商標名稱:</td>
		        <td class="whitetablebg" align="left"><input type="text" id="pfx_cappl_name" name="pfx_cappl_name" size="15" maxlength="15">
		        </td>
	        </tr>
	        <tr>
		        <td class="lightbluetable" align="right">客戶編號:</td>
		        <td class="whitetablebg" align="left">
		        <input type="text" id="tfx_cust_area" name="tfx_cust_area" size="1" class="SEdit" readonly>-<input type="text" id="tfx_cust_seq" name="tfx_cust_seq" size="5" maxlength="5">
		        </td>		
		        <td class="lightbluetable" align="right">客戶名稱:</td>
		        <td class="whitetablebg" align="left"><input type="text" id="pfx_ap_cname1" name="pfx_ap_cname1" size="15" maxlength="15">
		        </td>
	        </tr>	
	        <tr>
		        <td class="lightbluetable" align="right">申請人號:</td>
		        <td class="whitetablebg" align="left"><input type="text" id="tfx_apcust_no" name="tfx_apcust_no" size="12" maxlength="10">
		        </td>		
		        <td class="lightbluetable" align="right">申請人名稱:</td>
		        <td class="whitetablebg" align="left"><input type="text" id="pfx_ap_cname" name="pfx_ap_cname" size="15" maxlength="80">
		        <input type="hidden" id="task" name="task">
		        </td>
	        </tr>
        </table>
        <br>
        <table id="tabBtn" border="0" width="100%" cellspacing="0" cellpadding="0" align="center">
	        <tr><td width="100%" align="center">
			    <%#StrFormBtn%>
	        </td></tr>
        </table>

        <div>
            *營洽中有　<font color=red size=2>' * '</font>　符號者，表該營洽已離職!!
        </div>
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
	        <td align="center" class="lightbluetable" width="5%">接洽序號</td>
	        <td align="center" class="lightbluetable" width="10%">客戶名稱</td>
	        <td align="center" class="lightbluetable" width="20%">案件名稱</td>	
	        <td align="center" class="lightbluetable">類別</td>
	        <td align="center" class="lightbluetable" width="15%">案性</td>
	        <td align="center" class="lightbluetable">服務費</td>
	        <td align="center" class="lightbluetable">規費</td>
	        <td align="center" class="lightbluetable">轉帳<br>費用</td>
	        <td align="center" class="lightbluetable">合計</td>
	        <td align="center" class="lightbluetable">折扣</td>
	        <td align="center" class="lightbluetable">註記</td>
	        <td align="center" class="lightbluetable">作業</td>
        </tr>
	</thead>
	<tbody>
	</tbody>
    <script type="text/html" id="data_template"><!--清單樣板-->
	    <tr class='{{tclass}}' id='tr_data_{{nRow}}'>
	        <td class="whitetablebg" align="center">
                <a href="{{urlasp}}" target="Eblank">{{in_scode}}-{{in_no}}{{case_num_txt}}</A>
                <input type=hidden id="inscode_{{nRow}}" name="inscode_{{nRow}}" value="{{in_scode}}">
                <input type=hidden id="inno_{{nRow}}" name="inno_{{nRow}}" value="{{in_no}}">
                <input type=hidden id="case_no_{{nRow}}" name="case_no_{{nRow}}" value="{{case_no}}">
                <input type=hidden id="seq_{{nRow}}" name="seq_{{nRow}}" value="{{seq}}">
                <input type=hidden id="seq1_{{nRow}}" name="seq1_{{nRow}}" value="{{seq1}}">
                <input type=hidden id="cust_area_{{nRow}}" name="cust_area_{{nRow}}" value="{{cust_area}}">
                <input type=hidden id="cust_seq_{{nRow}}" name="cust_seq_{{nRow}}" value="{{cust_seq}}">
                <input type=hidden id="arcase_{{nRow}}" name="arcase_{{nRow}}" value="{{arcase}}">
                <input type=hidden id="stat_code_{{nRow}}" name="stat_code_{{nRow}}" value="{{stat_code}}">
                <input type=hidden id="appl_name_{{nRow}}" name="appl_name_{{nRow}}" value="{{appl_name}}">
                <input type=hidden id="cust_name_{{nRow}}" name="cust_name_{{nRow}}" value="{{cust_name}}">
                <input type=hidden id="case_num_{{nRow}}" name="case_num_{{nRow}}" value="{{case_num}}">
            </td>
	        <td class="whitetablebg" align="center"><a href="{{urlasp}}" target="Eblank">{{cust_name}}</A></td> 
	        <td class="whitetablebg" align="center"><a href="{{urlasp}}" target="Eblank">{{appl_name}}</A></td>
	        <td class="whitetablebg" align="center"><a href="{{urlasp}}" target="Eblank">{{class}}</A></td>
	        <td class="whitetablebg" align="center"><a href="{{urlasp}}" target="Eblank">{{case_name}}</A></td>
	        <td class="whitetablebg" align="center"><a href="{{urlasp}}" target="Eblank">{{service}}</A></td>
	        <td class="whitetablebg" align="center"><a href="{{urlasp}}" target="Eblank">{{fees}}</A></td>
	        <td class="whitetablebg" align="center"><a href="{{urlasp}}" target="Eblank">{{oth_money}}</A></td>
	        <td class="whitetablebg" align="center">{{sum_txt}}</td>
	        <td class="whitetablebg" align="center">{{dis_txt}}</td>
            <td class="whitetablebg" align="center" title="主管簽退說明" ><span style="color:red">{{nx_link}}</span></td>
	        <td class="whitetablebg" align="center"><a href="javascript:void(0)" onclick="actDel('{{nRow}}')">[刪除]</a></td>
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

        $("#tfx_cust_area").val("<%#Session["sebranch"]%>");
    }

    //[查詢]
    $("#btnSrch").click(function (e) {
        if ($("#scode").val() == "") {
            alert("請選擇營洽!");
            return false;
        }
        $("#tscode").val($("#scode").val());

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
                    copyStr = copyStr.replace(/{{in_no}}/g, item.in_no);
                    copyStr = copyStr.replace(/{{seq}}/g, item.seq);
                    copyStr = copyStr.replace(/{{seq1}}/g, item.seq1);
                    copyStr = copyStr.replace(/{{discount_remark}}/g, item.discount_remark);
                    copyStr = copyStr.replace(/{{send_way}}/g, item.send_way);
                    copyStr = copyStr.replace(/{{receipt_title}}/g, item.receipt_title);
                    copyStr = copyStr.replace(/{{receipt_type}}/g, item.receipt_type);
                    copyStr = copyStr.replace(/{{ar_mark}}/g, item.ar_mark);
                    copyStr = copyStr.replace(/{{t_service}}/g, item.t_service);
                    copyStr = copyStr.replace(/{{p_service}}/g, item.p_service);
                    copyStr = copyStr.replace(/{{t_fees}}/g, item.t_fees);
                    copyStr = copyStr.replace(/{{p_fees}}/g, item.p_fees);
                    copyStr = copyStr.replace(/{{discount}}/g, item.discount);
                    copyStr = copyStr.replace(/{{discount_chk}}/g, item.discount_chk);
                    copyStr = copyStr.replace(/{{urlasp}}/g, item.urlasp);
                    copyStr = copyStr.replace(/{{case_num_txt}}/g, item.case_num_txt);
                    copyStr = copyStr.replace(/{{cust_name}}/g, item.cust_name);
                    copyStr = copyStr.replace(/{{todoicon}}/g, item.todoicon);
                    copyStr = copyStr.replace(/{{fseq}}/g, item.fseq);
                    copyStr = copyStr.replace(/{{appl_name}}/g, item.appl_name);
                    copyStr = copyStr.replace(/{{class}}/g, item.class);
                    copyStr = copyStr.replace(/{{case_name}}/g, item.case_name);
                    copyStr = copyStr.replace(/{{service}}/g, item.service);
                    copyStr = copyStr.replace(/{{fees}}/g, item.fees);
                    copyStr = copyStr.replace(/{{oth_money}}/g, item.oth_money);
                    copyStr = copyStr.replace(/{{sum_txt}}/g, item.sum_txt);
                    copyStr = copyStr.replace(/{{dis_txt}}/g, item.dis_txt);
                    copyStr = copyStr.replace(/{{nx_link}}/g, item.nx_link);
                    copyStr = copyStr.replace(/{{case_no}}/g, item.case_no);
                    copyStr = copyStr.replace(/{{cust_area}}/g, item.cust_area);
                    copyStr = copyStr.replace(/{{cust_seq}}/g, item.cust_seq);
                    copyStr = copyStr.replace(/{{stat_code}}/g, item.stat_code);
                    copyStr = copyStr.replace(/{{arcase}}/g, item.arcase);

                    copyStr = copyStr.replace(/{{last_date}}/g, dateReviver(item.last_date, "yyyy/M/d"));

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

    //每頁幾筆
    $("#PerPage").change(function (e) {
        goSearch();
    });
    //指定第幾頁
    $("#divPaging").on("change", "#GoPage", function (e) {
        goSearch();
    });
    //上下頁
    $(".pgU,.pgD").click(function (e) {
        $("#GoPage").val($(this).attr("v1"));
        goSearch();
    });
    //排序
    $(".setOdr").click(function (e) {
        $("#dataList>thead tr .setOdr span").remove();
        $(this).append("<span>▲</span>");
        $("#SetOrder").val($(this).attr("v1"));
        goSearch();
    });
    //重新整理
    $(".imgRefresh").click(function (e) {
        goSearch();
    });
    //查詢條件
    $(".imgQry").click(function (e) { $("#id-div-slide").slideToggle("fast"); });
    //關閉視窗
    $(".imgCls").click(function (e) {
        if (window.parent.tt !== undefined) {
            window.parent.tt.rows = "100%,0%";
        } else {
            window.close();
        }
    });
    //////////////////////

    //[重填]
    $("#btnRest").click(function (e) {
        regPage.reset();
        this_init();
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
            var url = getRootPath() + "/brt1m/brt17_save.aspx?submitTask=D"+
                    "&in_scode=" + pin_scode + "&in_no=" + pin_no + "&case_no=" + pcase_no +"&case_stat=" + pcase_stat +
                    "&cappl_name=" + pappl_name + "&ap_cname1=" + pcust_name + "&arcase=" + parcase + "&seq=" + pseq +
                    "&seq1=" + pseq1 + "&cust_area=" + pcust_areq + "&cust_seq=" + pcust_seq+"&chkTest="+chktest;
            ajaxScriptByGet("刪除接洽記錄", url);
        }
    }
</script>
