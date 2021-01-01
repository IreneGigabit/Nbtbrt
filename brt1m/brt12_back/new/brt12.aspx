﻿<%@ Page Language="C#" CodePage="65001"%>
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
		StrFormBtnTop += "<a class=\"imgRefresh\" href=\"javascript:void(0);\" >[重新整理]</a>\n";
        StrFormBtnTop += "<a class=\"imgQry\" href=\"javascript:void(0);\" >[查詢條件]</a>\n";
        StrFormBtnTop += "<a href=\"" + Page.ResolveUrl("~/Brt4m/Brt13.aspx") + "?prgid=" + HTProgPrefix + "\">[交辦查詢]</a>\n";
        StrFormBtnTop += "<a href=\"" + Page.ResolveUrl("~/cust/cust11_1.aspx") + "?gs_dept=" + Session["Dept"] + "\">[客戶查詢]</a>\n";
        StrFormBtnTop += "<a href=\"" + Page.ResolveUrl("~/cust/cust11.aspx") + "?gs_dept=" + Session["Dept"] + "\">[客戶新增]</a>\n";

        if ((HTProgRight & 2) > 0) {
            StrFormBtn += "<input type=\"button\" id=\"btnSrch\" value=\"查　詢\" class=\"cbutton bsubmit\" />\n";
            StrFormBtn += "<input type=\"button\" id=\"btnRest\" value=\"重　填\" class=\"cbutton\" />\n";
        }

        using (DBHelper conn = new DBHelper(Conn.btbrt).Debug(false)) {
            //抓取組主管所屬營洽
            string sales_scode = Sys.getTeamScode(Sys.GetSession("SeBranch"), Sys.GetSession("scode"));

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
<link rel="stylesheet" type="text/css" href="<%=Page.ResolveUrl("~/js/lib/jquery-ui.min.css")%>" />
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/jquery-1.12.4.min.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/jquery-ui.min.js")%>"></script>
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

<form id="regPage" name="regPage" method="post">
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

    <div id="divPaging" style="display:none">
    <TABLE border=0 cellspacing=1 cellpadding=0 width="98%" align="center">
	    <tr>
            <td width="20%"></td>
		    <td align=center>
			    <font size="2" color="#3f8eba">
				    第<font color="red"><span id="NowPage"></span>/<span id="TotPage"></span></font>頁
				    | 資料共<font color="red"><span id="TotRec"></span></font>筆
				    | 跳至第
				    <select id="GoPage" name="GoPage" style="color:#FF0000"></select>
				    頁
				    <span id="PageUp">| <a href="javascript:void(0)" class="pgU" v1="">上一頁</a></span>
				    <span id="PageDown">| <a href="javascript:void(0)" class="pgD" v1="">下一頁</a></span>
				    | 每頁筆數:
				    <select id="PerPage" name="PerPage" style="color:#FF0000">
					    <option value="10">10</option>
					    <option value="20">20</option>
					    <option value="30" selected>30</option>
					    <option value="50">50</option>
				    </select>
                    <input type="hidden" name="SetOrder" id="SetOrder" />
			    </font>
		    </td>
		    <td width="20%"></td>
	    </tr>
    </TABLE>
    </div>
</form>

<div align="center" class="noData" style="display:none">
	<font color="red">=== 目前無資料 ===</font>
</div>

<form style="margin:0;" id="reg" name="reg" method="post">
<input type=text id=signid name=signid>
<input type=text id=in_no1 name=in_no1>
<input type=text id=in_scode1 name=in_scode1>
<input type=text id=C1 name=C1 value="Y"> 

<table style="display:none" border="0" class="bluetable" cellspacing="1" cellpadding="2" width="98%" align="center" id="dataList">
	<thead>
      <Tr>
	    <td align="center" class="lightbluetable"></td>
        <td align="center" class="lightbluetable" nowrap>接洽序號</td>
	    <td align="center" class="lightbluetable" nowrap>客戶名稱</td>
	    <td align="center" class="lightbluetable" nowrap>案件編號</td>
	    <td align="center" class="lightbluetable" nowrap>案件名稱</td>	
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
		    <input type=checkbox id="CT" name="T_{{nRow}}" value="Y" onclick="checkfee('{{nRow}}')">
		    <input type=hidden id="incode_{{nRow}}" name="incode_{{nRow}}" value="{{in_scode}}">
		    <input type=hidden id="inno_{{nRow}}" name="inno_{{nRow}}" value="{{in_no}}">
		    <!--2010/5/17因應todo_ext修改-->
		    <input type=hidden id="seq_{{nRow}}" name="seq_{{nRow}}" value="{{seq}}">
	        <input type=hidden id="seq1_{{nRow}}" name="seq1_{{nRow}}" value="{{seq1}}">
	        <!--2016/5/30因應折扣線上簽核修改-->
	        <input type=hidden id="discount_remark_{{nRow}}" name="discount_remark_{{nRow}}" value="{{discount_remark}}">
		    <input type=hidden id="send_way_{{nRow}}" name="send_way_{{nRow}}" value="{{send_way}}">
		    <input type=hidden id="receipt_title_{{nRow}}" name="receipt_title_{{nRow}}" value="{{receipt_title}}">
		    <input type=hidden id="receipt_type_{{nRow}}" name="receipt_type_{{nRow}}" value="{{receipt_type}}">
		    <input type=hidden id="ar_mark_{{nRow}}" value="{{ar_mark}}"><!--arkind-->
		    <input type=hidden id="t_service_{{nRow}}" value="{{t_service}}"><!--A-->
		    <input type=hidden id="p_service_{{nRow}}" value="{{p_service}}"><!--PA-->
		    <input type=hidden id="t_fees_{{nRow}}" value="{{t_fees}}"><!--B-->
		    <input type=hidden id="p_fees_{{nRow}}" value="{{p_fees}}"><!--PB-->
		    <input type=hidden id="discount_{{nRow}}" value="{{discount}}"><!--Sratio-->
		    <input type=hidden id="discount_chk_{{nRow}}" value="{{discount_chk}}"><!--dis_chk-->
	    </td>
	    <td class="whitetablebg" align="center"><a href="{{urlasp}}" target="Eblank">{{in_scode}}-{{in_no}}{{case_num_txt}}</a></td>
	    <td class="whitetablebg" align="center"><a href="{{urlasp}}" target="Eblank">{{cust_name}}</a></td>
	    <td class="whitetablebg" align="center"><a href="{{urlasp}}" target="Eblank">{{todoicon}}{{fseq}}</a></td>
	    <td class="whitetablebg" align="center"><a href="{{urlasp}}" target="Eblank">{{appl_name}}</a></td>
	    <td class="whitetablebg" align="center"><a href="{{urlasp}}" target="Eblank">{{class}}</a></td>
	    <td class="whitetablebg" align="center"><a href="{{urlasp}}" target="Eblank">{{case_name}}</a></td>
	    <td class="whitetablebg" align="center"><a href="{{urlasp}}" target="Eblank">{{service}}</a></td>
	    <td class="whitetablebg" align="center"><a href="{{urlasp}}" target="Eblank">{{fees}}</a></td>
	    <td class="whitetablebg" align="center"><a href="{{urlasp}}" target="Eblank">{{oth_money}}</a></td>
	    <td class="whitetablebg" align="center">{{sum_txt}}</td>
	    <td class="whitetablebg" align="center">{{dis_txt}}</td>
	    <td class="whitetablebg" align="center" title="主管簽退或程序退回說明">{{nx_link}}</td>
	    <td class="whitetablebg" align="center"><a href="{{urlasp}}" target="Eblank"><font color="blue">[編修]</font></a></td>
	</tr>
    </script>
</TABLE>
<div id="divSign" style="display:none">
<br>
<table border="0" width="70%" cellspacing="1" cellpadding="0" align="center" >			
	<TR>										 
		<td ><input type=radio name="usesign" id="usesignM" checked><strong>正常簽核:</strong></td>
		<td><strong>直屬主管:</strong><%=mSC_name%><input type=text name=Msign id=Msign value="<%=mSC_code%>"></td>
		<td><strong>管制日期:</strong>
		<input type=text id="signdate" name="signdate" size=10 readonly class="dateField">
		</td>
	</TR>
    <TR>
		<td ><input type=radio name="usesign" id="usesignO"><strong>特殊處理:</strong></td>
		<td ><input type=radio name=Osign id=Osign0 class="<%=nToSelect%>">
		    <select id=selectsign name=selectsign class="<%=nToSelect%>">
			<option value="" style="color:blue">請選擇主管</option><%=selSign%>
			</select>
		</td>	
		<td><input type=radio name=Osign id=Osign1 class="<%=nToText%>">
			<input type=text name=Nsign id=Nsign size=10 class="<%=nToText%>">(薪號)
		</td>
	</TR>
</table>
<input type=text id="GrpID" name="GrpID" value="<%=se_Grpid%>">
<table border="0" width="100%" cellspacing="0" cellpadding="0">
	<tr><td width="100%">     
	<p align="center">        
		<input type=button value ="案件交辦" class="cbutton bsubmit" onClick="formupdate()" id=button4 name=button4>
	</td></tr>
</table>
</div>
</form>

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
            url: "<%#HTProgPrefix%>List.aspx",
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
                    $("#divPaging,#dataList,.haveData,#divSign").show();
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

    $("#Sfx_in_date,#Efx_in_date").blur(function (e){
        ChkDate(this);
    });
</script>
