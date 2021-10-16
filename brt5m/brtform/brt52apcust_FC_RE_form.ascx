<%@ Control Language="C#" ClassName="brt52apcust_FC_RE_form" %>
<%@ Import Namespace = "System.Collections.Generic"%>

<script runat="server">
    //父控制項傳入的參數
    public Dictionary<string, string> Lock = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    public Dictionary<string, string> Hide = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    public int HTProgRight = 0;

    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected string prgid = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string SQL = "";

    protected string ar_form = "";
    protected string apclass = "", ap_country = "";

    private void Page_Load(System.Object sender, System.EventArgs e) {
        apclass = Sys.getCustCode("apclass", "", "sortfld").Option("{cust_code}", "{code_name}");
        ap_country = Sys.getCountry().Option("{coun_code}", "{coun_c}");
        ar_form = (Request["ar_form"] ?? "").Trim();
        
        this.DataBind();
    }
</script>

<%=Sys.GetAscxPath(this.AppRelativeVirtualPath)%>
<input type=hidden id=FC0_apnum name=FC0_apnum value=0><!--筆數-->
<table border="0" id=FC0_tabap class="bluetable" cellspacing="1" cellpadding="2" width="100%">
	<THEAD>
		<tr>
			<td class="lightbluetable" colspan="2" valign="top" STYLE="cursor:pointer;COLOR:BLUE" onclick="PMARK(c2Apcust)"><strong>貳、<u>申請人</u></strong></td>
		</tr>
		<tr>
			<td class="lightbluetable" align=right width="10%">一、變更種類：</td>
		    <td class="whitetablebg">
		       <input type=radio name=tfzd_Mark id=tfzd_MarkI class="onoff" value="I">商標(標章)權人
		       <input type=radio name=tfzd_Mark id=tfzd_MarkA class="onoff" value="A">被授權人
               <input type=radio name=tfzd_Mark id=tfzd_MarkB class="onoff" value="B">再被授權人
               <input type=radio name=tfzd_Mark id=tfzd_MarkC class="onoff" value="C">質權人(請撰擇其一)
            </td>   
        </tr> 
        <tr class="<%#Hide.TryGet("apcust")%>">
			<td class="lightbluetable" align=left colspan=2>二、請填寫申請人各項資料(填寫變更後之正確資料) </td>
		</tr>   
	    <TR class="<%#Hide.TryGet("apcust")%>">
		    <TD class="bluetable sfont9" style="border-color:red" colspan=2 align=right>
                <span id="span_btn_POA">
    			    <input type=button class="greenbutton <%#Lock.TryGet("Qdisabled")%>" value="查詢申請人委任書" onclick="apcust_form.btn_POA('FC0_tabap','dbmn_')">
			    </span>
			    <input type=button value="增加一筆申請人" class="cbutton" id=FC0_AP_Add_button name=FC0_AP_Add_button>
			    <input type=button value="減少一筆申請人" class="cbutton" id=FC0_AP_Del_button name=FC0_AP_Del_button>
		    </TD>
	    </TR>
	</THEAD>
	<TBODY></TBODY>
</table>

<script type="text/html" id="apcust_fc_re_template">
	<TR>
		<TD class=lightbluetable align=right>
			<input type=text id="fc0_apnum_##" name="fc0_apnum_##" value="##." class="Lock" size=2>申請人種類：
            <INPUT type=hidden name="ttg2_apclass_##" id="ttg2_apclass_##">
		</TD>
		<TD class=whitetablebg title="輸入編號並點選確定，即顯示申請人資料；若無資料，請直接輸入申請人資料。">
		    申請人統一編號：
            <input TYPE=text id=dbmn_new_no_## NAME=dbmn_new_no_## SIZE=11 MAXLENGTH=10 onblur="apcust_form.chkapcust_no(reg.FC0_apnum.value,'##','dbmn_new_no_')" class="<%#Lock.TryGet("apcust")%>">&nbsp;
		    <input type=button id=queryap_## name=queryap_## value='確定' onclick="apcust_form.getAPy('##')" class="<%#Lock.TryGet("apcustC")%>" title='輸入編號並點選確定，即顯示申請人資料；若無資料，請直接輸入申請人資料。'>(統編/身份證字號)
		    <input type='checkbox' id='fc0_ap_hserver_flag_##' name='fc0_ap_hserver_flag_##' value='Y' onclick="apcust_form.apserver_flag('##','fc0_')" class="<%#Lock.TryGet("apcust")%>">註記此申請人為應受送達人
		    <input type='hidden' id='fc0_ap_server_flag_##' name='fc0_ap_server_flag_##' value='N'>
		    <input type=hidden id='dbmn_o_apsqlno_##' name='dbmn_o_apsqlno_##' value=''>
		    <input type=hidden id='dbmn_o_apcust_no_##' name='dbmn_o_apcust_no_##' value=''>
		</TD>
	</TR>
	<TR>
		<TD class=lightbluetable align=right></TD>
		<TD class=whitetablebg title="輸入關鍵字並點選申請人查詢，即顯示申請人資料清單。">
		    申請人名稱(中)：
		    <INPUT TYPE=text id=dbmn_ncname1_## NAME=dbmn_ncname1_## SIZE=30 alt='『申請人名稱(中)』' MAXLENGTH=60 onblur="fDataLen(this)" class="<%#Lock.TryGet("apcust")%>">
		    <INPUT TYPE=text id=dbmn_ncname2_## NAME=dbmn_ncname2_## SIZE=30 alt='『申請人名稱(中)』' MAXLENGTH=60 onblur="fDataLen(this)" class="<%#Lock.TryGet("apcust")%>">
		    <input type=hidden name='dbmn_apsqlno_##' id='dbmn_apsqlno_##'>
		    <input type=hidden name='dbmn_ap_cname_##' id='dbmn_ap_cname_##'>
		</TD>
	</TR>
	<TR id="FC0trap_sql_##">
		<TD class=lightbluetable align=right></TD>
		<TD class=whitetablebg>
		    申請人序號：
		    <INPUT TYPE=text id='dbmn_ap_sql_##' name='dbmn_ap_sql_##' SIZE=3 MAXLENGTH=3 class='sedit' readonly value=''>
		</TD>
	</TR>
	<TR>
		<TD class=lightbluetable align=right></TD>
		<TD class=whitetablebg>
		    <input type=button class='cbutton <%#Lock.TryGet("QA1disabled")%>' value='查詢' onclick="apcust_form.get_apnameaddr('##','FC0','dbmn_')">申請人名稱(英)：
		    <INPUT TYPE=text id=dbmn_nename1_## NAME=dbmn_nename1_## SIZE=60 MAXLENGTH=100 alt='『申請人名稱(英)』' onblur="fDataLen(this)" class="<%#Lock.TryGet("apcust")%>">
		    <INPUT TYPE=text id=dbmn_nename2_## NAME=dbmn_nename2_## SIZE=60 MAXLENGTH=100 alt='『申請人名稱(英)』' onblur="fDataLen(this)" class="<%#Lock.TryGet("apcust")%>">
		    <input type=hidden id='dbmn_ap_ename_##' name='dbmn_ap_ename_##'>
		</TD>
	</TR>
	<TR>
		<TD class=lightbluetable align=right></TD>
		<TD class=whitetablebg>
		    申請人名稱(英)：
		    姓：<INPUT TYPE=text id=dbmn_fename_## NAME=dbmn_fename_## SIZE=20 MAXLENGTH=60 class='sedit' readonly>
		    名：<INPUT TYPE=text id=dbmn_lename_## NAME=dbmn_lename_## SIZE=20 MAXLENGTH=60 class='sedit' readonly>
		</TD>
	</TR>
	<TR>
		<TD class=lightbluetable align=right></TD>
		<TD class=whitetablebg>
		    代表人名稱(中)：
		    <INPUT TYPE=text id=dbmn_ncrep_## NAME=dbmn_ncrep_## SIZE=40 MAXLENGTH=40 alt='『代表人名稱(中)』' onblur="fDataLen(this)">
		</TD>
	</TR>
	<TR>
		<TD class=lightbluetable align=right></TD>
		<TD class=whitetablebg>
		    代表人名稱(英)：
		    <INPUT TYPE=text id=dbmn_nerep_## NAME=dbmn_nerep_## SIZE=80 MAXLENGTH=80 alt='『代表人名稱(英)』' onblur="fDataLen(this)">
		</TD>
	</TR>
	<TR>
		<TD class=lightbluetable align=right></TD>
		<TD class=whitetablebg>
		地&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;址(中)：<br>
		<INPUT TYPE=text id=dbmn_nzip_## NAME=dbmn_nzip_## SIZE=8 MAXLENGTH=8>
		<INPUT TYPE=text id=dbmn_naddr1_## NAME=dbmn_naddr1_## SIZE=30 MAXLENGTH=60 alt='『地址(中)』' onblur="fDataLen(this)">
		<INPUT TYPE=text id=dbmn_naddr2_## NAME=dbmn_naddr2_## SIZE=30 MAXLENGTH=60 alt='『地址(中)』' onblur="fDataLen(this)">
		</TD>
	</TR>
	<TR>
		<TD class=lightbluetable align=right></TD>
		<TD class=whitetablebg>
		地&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;址(英)：<br>
		<INPUT TYPE=text id=dbmn_neaddr1_## NAME=dbmn_neaddr1_## SIZE=60 MAXLENGTH=60 alt='『地址(英)』' onblur="fDataLen(this)">
		<INPUT TYPE=text id=dbmn_neaddr2_## NAME=dbmn_neaddr2_## SIZE=60 MAXLENGTH=60 alt='『地址(英)』' onblur="fDataLen(this)"><br>
		<INPUT TYPE=text id=dbmn_neaddr3_## NAME=dbmn_neaddr3_## SIZE=60 MAXLENGTH=60 alt='『地址(英)』' onblur="fDataLen(this)">
		<INPUT TYPE=text id=dbmn_neaddr4_## NAME=dbmn_neaddr4_## SIZE=60 MAXLENGTH=60 alt='『地址(英)』' onblur="fDataLen(this)">
		</TD>
	</TR>
</script>

<script language="javascript" type="text/javascript">
    //增加一筆申請人
    $("#FC0_AP_Add_button").click(function () {
        var nRow = CInt($("#FC0_apnum").val()) + 1;
        //複製樣板
        var copyStr = $("#apcust_fc_re_template").text() || "";
        copyStr = copyStr.replace(/##/g, nRow);

        $("#FC0_tabap>tbody").append("<tr id='tr_ap_fc0_" + nRow + "' class='sfont9'><td colspan=2><table border='0' class='bluetable' cellspacing='1' cellpadding='2' width='100%'>" + copyStr + "</table></td></tr>");
        $("#tr_ap_fc0_" + nRow + " .Lock").lock();
        $("#FC0_apnum").val(nRow);
    });

    //減少一筆申請人
    $("#FC0_AP_Del_button").click(function () {
        var nRow = CInt($("#FC0_apnum").val());
        $('#tr_ap_fc0_' + nRow).remove();
        $("#FC0_apnum").val(Math.max(0, nRow - 1));
    });

    apcust_form.getappy=function(apcust_no,in_no){
        $("#FC0_tabap tbody").empty();

        $.ajax({
            type: "get",
            url: getRootPath() + "/ajax/_apcust.aspx?apcust_no=" + apcust_no + "&in_no=" + in_no,
            async: false,
            cache: false,
            success: function (json) {
                if ($("#chkTest").length > 0) toastr.info("<a href='" + this.url + "' target='_new'>Debug(apcust_form.getappy交辦申請人)！<BR><b><u>(點此顯示詳細訊息)</u></b></a>");
                var apcust_list = $.parseJSON(json);
                if (apcust_list.length == 0) {
                    alert("無該申請人編號!!!");
                    return false;
                }

                $.each(apcust_list, function (i, item) {
                    //增加一筆
                    $("#FC0_AP_Add_button").click();
                    //填資料
                    var nRow = $("#FC0_apnum").val();
                    $("#dbmn_new_no_" + nRow).val(item.apcust_no);
                    $("#dbmn_o_apcust_no_" + nRow).val(item.apcust_no);
                    $("#ttg2_apclass_" + nRow).val(item.apclass);
                    $("#dbmn_ncname1_" + nRow).val(item.ap_cname1);
                    $("#dbmn_ncname2_" + nRow).val(item.ap_cname2);
                    $("#dbmn_nename1_" + nRow).val(item.ap_ename1);
                    $("#dbmn_nename2_" + nRow).val(item.ap_ename2);
                    $("#dbmn_ncrep_" + nRow).val(item.ap_crep);
                    $("#dbmn_nerep_" + nRow).val(item.ap_erep);
                    $("#dbmn_naddr1_" + nRow).val(item.ap_addr1);
                    $("#dbmn_naddr2_" + nRow).val(item.ap_addr2);
                    $("#dbmn_neaddr1_" + nRow).val(item.ap_eaddr1);
                    $("#dbmn_neaddr2_" + nRow).val(item.ap_eaddr2);
                    $("#dbmn_neaddr3_" + nRow).val(item.ap_eaddr3);
                    $("#dbmn_neaddr4_" + nRow).val(item.ap_eaddr4);
                    $("#dbmn_apsqlno_" + nRow).val(item.apsqlno);
                    $("#dbmn_o_apsqlno_" + nRow).val(item.apsqlno);
                    $("#dbmn_nzip_" + nRow).val(item.ap_zip);
                    if (item.Server_flag == "Y") {
                        $("#fc0_ap_hserver_flag_" + nRow).prop("checked", true).triggerHandler("click");
                    } else {
                        $("#fc0_ap_hserver_flag_" + nRow).prop("checked", false).triggerHandler("click");
                    }
                    $("#dbmn_fcname_" + nRow).val(item.ap_fcname);
                    $("#dbmn_lcname_" + nRow).val(item.ap_lcname);
                    $("#dbmn_fename_" + nRow).val(item.ap_fename);
                    $("#dbmn_lename_" + nRow).val(item.ap_lename);
                    $("#dbmn_ap_sql_" + nRow).val(item.ap_sql);
                    //申請人序號空值不顯示
                    if (item.ap_sql == "" || item.ap_sql == "0") {
                        $("#FC0trap_sql_" + nRow).hide();
                    }

                })
            },
            error: function (xhr) { 
                $("#dialog").html("<a href='" + this.url + "' target='_new'>申請人資料載入失敗！<u>(點此顯示詳細訊息)</u></a><hr>"+xhr.responseText);
                $("#dialog").dialog({ title: '申請人資料載入失敗！', modal: true, maxHeight: 500,width: "90%" });
            }
        });
    }

    //申請人資料重抓
    apcust_form.getAPy = function (nRow) {
        $.ajax({
            type: "get",
            url: getRootPath() + "/ajax/_apcust.aspx?apcust_no=" + $("#apcust_no_"+nRow).val() ,
            async: false,
            cache: false,
            success: function (json) {
                if ($("#chkTest").length > 0) toastr.info("<a href='" + this.url + "' target='_new'>Debug(apcust_form.getAPy申請人資料重抓)！<BR><b><u>(點此顯示詳細訊息)</u></b></a>");
                var apcust_list = $.parseJSON(json);
                if (apcust_list.length == 0) {
                    alert("無該申請人編號!!!");
                    return false;
                }

                $.each(apcust_list, function (i, item) {
                    $("#ttg2_apclass_" + nRow).val(item.apclass);
                    $("#dbmn_ncname1_" + nRow).val(item.ap_cname1);
                    $("#dbmn_ncname2_" + nRow).val(item.ap_cname2);
                    $("#dbmn_nename1_" + nRow).val(item.ap_ename1);
                    $("#dbmn_nename2_" + nRow).val(item.ap_ename2);
                    $("#dbmn_ncrep_" + nRow).val(item.ap_crep);
                    $("#dbmn_nerep_" + nRow).val(item.ap_erep);
                    $("#dbmn_naddr1_" + nRow).val(item.ap_addr1);
                    $("#dbmn_naddr2_" + nRow).val(item.ap_addr2);
                    $("#dbmn_neaddr1_" + nRow).val(item.ap_eaddr1);
                    $("#dbmn_neaddr2_" + nRow).val(item.ap_eaddr2);
                    $("#dbmn_neaddr3_" + nRow).val(item.ap_eaddr3);
                    $("#dbmn_neaddr4_" + nRow).val(item.ap_eaddr4);
                    $("#dbmn_apsqlno_" + nRow).val(item.apsqlno);
                    $("#dbmn_nzip_" + nRow).val(item.ap_zip);
                    $("#dbmn_fcname_" + nRow).val(item.ap_fcname);
                    $("#dbmn_lcname_" + nRow).val(item.ap_lcname);
                    $("#dbmn_fename_" + nRow).val(item.ap_fename);
                    $("#dbmn_lename_" + nRow).val(item.ap_lename);
                    $("#dbmn_ap_sql_" + nRow).val("");
                })
            },
            error: function (xhr) { 
                $("#dialog").html("<a href='" + this.url + "' target='_new'>申請人資料載入失敗！<u>(點此顯示詳細訊息)</u></a><hr>"+xhr.responseText);
                $("#dialog").dialog({ title: '申請人資料載入失敗！', modal: true, maxHeight: 500,width: "90%" });
            }
        });
    }
</script>
