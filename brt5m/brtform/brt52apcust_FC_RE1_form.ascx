<%@ Control Language="C#" ClassName="brt52apcust_FC_RE1_form" %>
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
<input type=hidden id=FC2_apnum name=FC2_apnum value=0><!--筆數-->
<table border="0" id=FC2_tabap class="bluetable" cellspacing="1" cellpadding="2" width="100%">
	<THEAD>
		<tr class="<%#Hide.TryGet("apcust")%>">
			<td class="lightbluetable" colspan="4" valign="top"><strong>參、申請人(填寫變更後之正確資料)</strong></td>
		</tr>
	    <TR class="<%#Hide.TryGet("apcust")%>">
		    <TD class="bluetable sfont9" style="border-color:red" colspan=4 align=right>
                <span id="span_btn_POA">
    			    <input type=button class="greenbutton <%#Lock.TryGet("Qdisabled")%>" value="查詢申請人委任書" onclick="apcust_form.btn_POA('FC2_tabap','dbmn1_')">
			    </span>
			    <input type=button value="增加一筆申請人" class="cbutton" id=FC2_AP_Add_button name=FC2_AP_Add_button>
			    <input type=button value="減少一筆申請人" class="cbutton" id=FC2_AP_Del_button name=FC2_AP_Del_button>
		    </TD>
	    </TR>
	</THEAD>
	<TBODY></TBODY>
    <script type="text/html" id="apcust_fc_re1_template_2">
	    <TR>
		    <TD class=lightbluetable align=right>
			    <input type=text id="fc2_apnum_##" name="fc2_apnum_##" value="##." class="Lock" size=2>
		    </TD>
		    <TD class=whitetablebg>
		        國籍：
		        <select id='dbmn1_country_##' name='dbmn1_country_##' disabled><%=ap_country%></select>
		        <INPUT type='hidden' name='ttg1_apclass_##' id='ttg1_apclass_##'>
		        <input type='checkbox' id='fc2_ap_hserver_flag_##' name='fc2_ap_hserver_flag_##' value='Y' onclick="apcust_form.apserver_flag('##','fc2_')">此申請人為選定代表人
		        <input type='hidden' id='fc2_ap_server_flag_##' name='fc2_ap_server_flag_##' value='N'>
		    </TD>
	    </TR>
	    <TR>
		    <TD class=lightbluetable align=right></TD>
		    <TD class=whitetablebg title="輸入編號並點選確定，即顯示申請人資料；若無資料，請直接輸入申請人資料。">
		        <span id='span_Apcust_no_##' style='cursor:pointer;color:blue'>申請人統一編號：</span>
		        <input TYPE=text id='dbmn1_new_no_##' NAME='dbmn1_new_no_##' SIZE=11 MAXLENGTH=10 onblur="apcust_form.chkapcust_no(reg.FC2_apnum.value,'##','dbmn1_new_no_')" class="<%#Lock.TryGet("apcust")%>">&nbsp;
			    <input type='button' id='queryap_##' name='queryap_##' value='確定' onclick="apcust_form.getAPy1('##')" class="<%#Lock.TryGet("apcustC")%>" title='輸入編號並點選確定，即顯示申請人資料；若無資料，請直接輸入申請人資料。'>(統編/身份證字號)
		        <input type=hidden id='dbmn1_o_apsqlno_##' name='dbmn1_o_apsqlno_##' value=''>
		        <input type=hidden id='dbmn1_o_apcust_no_##' name='dbmn1_o_apcust_no_##' value=''>
	    </TD>
	    </TR>
	    <TR>
		    <TD class=lightbluetable align=right></TD>
		    <TD class=whitetablebg title="輸入關鍵字並點選申請人查詢，即顯示申請人資料清單。">
		        申請人名稱(中)：
		        <INPUT TYPE=text id=dbmn1_ncname1_## NAME=dbmn1_ncname1_## SIZE=40 alt='『申請人名稱(中)』' MAXLENGTH=60 onblur="fDataLen(this)" class="<%#Lock.TryGet("apcust")%>">
		        <INPUT TYPE=text id=dbmn1_ncname2_## NAME=dbmn1_ncname2_## SIZE=40 alt='『申請人名稱(中)』' MAXLENGTH=60 onblur="fDataLen(this)" class="<%#Lock.TryGet("apcust")%>">
		        <input type=hidden name='dbmn1_apsqlno_##' id='dbmn1_apsqlno_##'>
		    </TD>
	    </TR>
	    <TR>
		    <TD class=lightbluetable align=right></TD>
		    <TD class=whitetablebg>
		        申請人名稱(中)：
		        姓：<INPUT TYPE=text id=dbmn1_fcname_## NAME=dbmn1_fcname_## SIZE=20 MAXLENGTH=60 class='sedit' readonly>
		        名：<INPUT TYPE=text id=dbmn1_lcname_## NAME=dbmn1_lcname_## SIZE=20 MAXLENGTH=60 class='sedit' readonly>
		    </TD>
	    </TR>
	    <TR id="FC2trap_sql_##">
		    <TD class=lightbluetable align=right></TD>
		    <TD class=whitetablebg>
		        申請人序號：
		        <INPUT TYPE=text id='dbmn1_ap_sql_##' name='dbmn1_ap_sql_##' SIZE=3 MAXLENGTH=3 class='sedit' readonly value=''>
		    </TD>
	    </TR>
	    <TR>
		    <TD class=lightbluetable align=right></TD>
		    <TD class=whitetablebg>
		        <input type=button class='cbutton <%#Lock.TryGet("QA1disabled")%>' value='查詢' onclick="apcust_form.get_apnameaddr('##', 'FC2', 'dbmn1_')">申請人名稱(英)：
		        <INPUT TYPE=text id=dbmn1_nename1_## NAME=dbmn1_nename1_## SIZE=60 MAXLENGTH=100 alt='『申請人名稱(英)』' onblur="fDataLen(this)" class="<%#Lock.TryGet("apcust")%>">
		        <INPUT TYPE=text id=dbmn1_nename2_## NAME=dbmn1_nename2_## SIZE=60 MAXLENGTH=100 alt='『申請人名稱(英)』' onblur="fDataLen(this)" class="<%#Lock.TryGet("apcust")%>">
		        <input type=hidden id='dbmn1_ap_ename_##' name='dbmn1_ap_ename_##'>
		    </TD>
	    </TR>
	    <TR>
		    <TD class=lightbluetable align=right></TD>
		    <TD class=whitetablebg>
		        申請人名稱(英)：
		        姓：<INPUT TYPE=text id=dbmn1_fename_## NAME=dbmn1_fename_## SIZE=20 MAXLENGTH=60 class='sedit' readonly>
		        名：<INPUT TYPE=text id=dbmn1_lename_## NAME=dbmn1_lename_## SIZE=20 MAXLENGTH=60 class='sedit' readonly>
		    </TD>
	    </TR>
	    <TR>
		    <TD class=lightbluetable align=right></TD>
		    <TD class=whitetablebg>
		        代表人名稱(中)：
		        <INPUT TYPE=text id=dbmn1_ncrep_## NAME=dbmn1_ncrep_## SIZE=40 MAXLENGTH=40 alt='『代表人名稱(中)』' onblur="fDataLen(this)" class='sedit' readonly>
		    </TD>
	    </TR>
	    <TR>
		    <TD class=lightbluetable align=right></TD>
		    <TD class=whitetablebg>
		        代表人名稱(英)：
		        <INPUT TYPE=text id=dbmn1_nerep_## NAME=dbmn1_nerep_## SIZE=80 MAXLENGTH=80 alt='『代表人名稱(英)』' onblur="fDataLen(this)" class='sedit' readonly>
		    </TD>
	    </TR>
	    <TR>
		    <TD class=lightbluetable align=right></TD>
		    <TD class=whitetablebg>
		    地&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;址(中)：<br>
		    <INPUT TYPE=text id=dbmn1_nzip_## NAME=dbmn1_nzip_## SIZE=8 MAXLENGTH=8 class='sedit' readonly>
		    <INPUT TYPE=text id=dbmn1_naddr1_## NAME=dbmn1_naddr1_## SIZE=30 MAXLENGTH=60 alt='『地址(中)』' onblur="fDataLen(this)" class='sedit' readonly>
		    <INPUT TYPE=text id=dbmn1_naddr2_## NAME=dbmn1_naddr2_## SIZE=30 MAXLENGTH=60 alt='『地址(中)』' onblur="fDataLen(this)" class='sedit' readonly>
		    </TD>
	    </TR>
	    <TR>
		    <TD class=lightbluetable align=right></TD>
		    <TD class=whitetablebg>
		    地&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;址(英)：<br>
		    <INPUT TYPE=text id=dbmn1_neaddr1_## NAME=dbmn1_neaddr1_## SIZE=60 MAXLENGTH=60 alt='『地址(英)』' onblur="fDataLen(this)" class='sedit' readonly>
		    <INPUT TYPE=text id=dbmn1_neaddr2_## NAME=dbmn1_neaddr2_## SIZE=60 MAXLENGTH=60 alt='『地址(英)』' onblur="fDataLen(this)" class='sedit' readonly><br>
		    <INPUT TYPE=text id=dbmn1_neaddr3_## NAME=dbmn1_neaddr3_## SIZE=60 MAXLENGTH=60 alt='『地址(英)』' onblur="fDataLen(this)" class='sedit' readonly>
		    <INPUT TYPE=text id=dbmn1_neaddr4_## NAME=dbmn1_neaddr4_## SIZE=60 MAXLENGTH=60 alt='『地址(英)』' onblur="fDataLen(this)" class='sedit' readonly>
		    </TD>
	    </TR>
	    <TR>
		    <TD class=lightbluetable align=right></TD>
		    <TD class=whitetablebg>
		    電話：
		    <INPUT TYPE=text id=dbmn1_ntel0_## NAME=dbmn1_ntel0_## SIZE=4 MAXLENGTH=4 class='sedit' readonly>
		    <INPUT TYPE=text id=dbmn1_ntel_## NAME=dbmn1_ntel_## SIZE=15 MAXLENGTH=15 class='sedit' readonly>
		    <INPUT TYPE=text id=dbmn1_ntel1_## NAME=dbmn1_ntel1_## SIZE=10 MAXLENGTH=10 class='sedit' readonly>
		    傳真：
		    <INPUT TYPE=text id=dbmn1_nfax_## NAME=dbmn1_nfax_## SIZE=20 MAXLENGTH=20 class='sedit' readonly>
		    </TD>
	    </TR>
    </script>
</table>

<input type=hidden id=FC1_apnum name=FC1_apnum value=0><!--筆數-->
<table border="0" id=FC1_tabap class="bluetable" cellspacing="1" cellpadding="2" width="100%">
	<THEAD>
	    <tr id="old_no_head">
		    <td class="lightbluetable" colspan="2" valign="top" STYLE="cursor:pointer;COLOR:BLUE" onclick="PMARK(c1Oapcust)"><strong>伍、<u>原申請人(如不是申請權利之讓與，可免填本項)</u></strong></td>
	    </tr>
	    <TR>
		    <TD  class=whitetablebg colspan=2 align=right>
			    <input type=button value ="增加一筆原申請人" class="cbutton" id=FC1_AP_Add_button name=FC1_AP_Add_button>
			    <input type=button value ="減少一筆原申請人" class="cbutton" id=FC1_AP_Del_button name=FC1_AP_Del_button>
		    </TD>
	    </TR>
	</THEAD>
	<TBODY></TBODY>
    <script type="text/html" id="apcust_fc_re1_template_1">
	    <TR>
		    <TD class=lightbluetable align=right title="輸入編號並點選確定，即顯示申請人資料；若無資料，請直接輸入申請人資料。">
			    <input type=text id="fc1_apnum_##" name="fc1_apnum_##" value="##." class="Lock" size=2>申請人統一編號：
		    </TD>
		    <TD class=whitetablebg>
		        <input type=hidden id='tft1_old_no_##' name='tft1_old_no_##'>
		        <input type=hidden id='tft1_ocname1_##' name='tft1_ocname1_##'>
		        <input type=hidden id='tft1_ocname2_##' name='tft1_ocname2_##'>
		        <input type=hidden id='tft1_oename1_##' name='tft1_oename1_##'>
		        <input type=hidden id='tft1_oename2_##' name='tft1_oename2_##'>
		        <input TYPE=text id=dbmo1_old_no_## name=dbmo1_old_no_## SIZE=11 MAXLENGTH=10 onblur="apcust_form.chkapcust_no(reg.FC1_apnum.value,'##','dbmo1_old_no_')">&nbsp;
 		        <input type=button value='確定' onclick="apcust_form.getappx1('##')" title='輸入編號並點選確定，即顯示申請人資料；若無資料，請直接輸入申請人資料。'>(統一編號/身份證字號)
		    </TD>
	    </TR>
	    <TR>
		    <TD class=lightbluetable align=right title="輸入關鍵字並點選申請人查詢，即顯示申請人資料清單。">
                申請人名稱(中)：
		    </TD>
		    <TD class=whitetablebg>
		        <INPUT TYPE=text id=dbmo1_ocname1_## name=dbmo1_ocname1_## SIZE=30 MAXLENGTH=60 alt='『申請人名稱(中)』' onblur="fDataLen(this)">
		        <INPUT TYPE=text id=dbmo1_ocname2_## name=dbmo1_ocname2_## SIZE=30 MAXLENGTH=60 alt='『申請人名稱(中)』' onblur="fDataLen(this)">
		    </TD>
	    </TR>
	    <TR>
		    <TD class=lightbluetable align=right>申請人名稱(英)：</TD>
		    <TD class=whitetablebg>
		        <INPUT TYPE=text id=dbmo1_oename1_## name=dbmo1_oename1_## SIZE=60 MAXLENGTH=100 alt='『申請人名稱(英)』' onblur="fDataLen(this)">
		        <INPUT TYPE=text id=dbmo1_oename2_## name=dbmo1_oename2_## SIZE=60 MAXLENGTH=100 alt='『申請人名稱(英)』' onblur="fDataLen(this)">
		        <INPUT TYPE=hidden id=dbmo1_ocrep_## name=ttgp_mod_ap_ocrep_##>
		        <INPUT TYPE=hidden id=dbmo1_oerep_## name=ttgp_mod_ap_oerep_##>
		        <INPUT TYPE=hidden id=dbmo1_ozip_## name=ttgp_mod_ap_ozip_##>
		        <INPUT TYPE=hidden id=dbmo1_oaddr1_## name=ttgp_mod_ap_oaddr1_##>
		        <INPUT TYPE=hidden id=dbmo1_oaddr2_## name=ttgp_mod_ap_oaddr2_##>
		        <INPUT TYPE=hidden id=dbmo1_oeaddr1_## name=ttgp_mod_ap_oeaddr1_##>
		        <INPUT TYPE=hidden id=dbmo1_oeaddr2_## name=ttgp_mod_ap_oeaddr2_##>
		        <INPUT TYPE=hidden id=dbmo1_oeaddr3_## name=ttgp_mod_ap_oeaddr3_##>
		        <INPUT TYPE=hidden id=dbmo1_oeaddr4_## name=ttgp_mod_ap_oeaddr4_##>
		        <INPUT TYPE=hidden id=dbmo1_otel0_## name=ttgp_mod_ap_otel0_##>
		        <INPUT TYPE=hidden id=dbmo1_otel_## name=ttgp_mod_ap_otel_##>
		        <INPUT TYPE=hidden id=dbmo1_otel1_## name=ttgp_mod_ap_otel1_##>
		        <INPUT TYPE=hidden id=dbmo1_ofax_## name=ttgp_mod_ap_ofax_##>
		    </TD>
	    </TR>
    </script>
</table>

<script language="javascript" type="text/javascript">
    //增加一筆申請人
    $("#FC2_AP_Add_button").click(function () {
        var nRow = CInt($("#FC2_apnum").val()) + 1;
        //複製樣板
        var copyStr = $("#apcust_fc_re1_template_2").text() || "";
        copyStr = copyStr.replace(/##/g, nRow);

        $("#FC2_tabap>tbody").append("<tr id='tr_ap_fc2_" + nRow + "' class='sfont9'><td><table border='0' class='bluetable' cellspacing='1' cellpadding='2' width='100%'>" + copyStr + "</table></td></tr>");
        $("#tr_ap_fc2_" + nRow + " .Lock").lock();
        $("#FC2_apnum").val(nRow);
    });

    //減少一筆申請人
    $("#FC2_AP_Del_button").click(function () {
        var nRow = CInt($("#FC2_apnum").val());
        $('#tr_ap_fc2_' + nRow).remove();
        $("#FC2_apnum").val(Math.max(0, nRow - 1));
    });

    //增加一筆原申請人
    $("#FC1_AP_Add_button").click(function () {
        var nRow = CInt($("#FC1_apnum").val()) + 1;
        //複製樣板
        var copyStr = $("#apcust_fc_re1_template_1").text() || "";
        copyStr = copyStr.replace(/##/g, nRow);

        $("#FC1_tabap>tbody").append("<tr id='tr_ap_fc1_" + nRow + "' class='sfont9'><td><table border='0' class='bluetable' cellspacing='1' cellpadding='2' width='100%'>" + copyStr + "</table></td></tr>");
        $("#tr_ap_fc1_" + nRow + " .Lock").lock();
        $("#FC1_apnum").val(nRow);
    });

    //減少一筆原申請人
    $("#FC1_AP_Del_button").click(function () {
        var nRow = CInt($("#FC1_apnum").val());
        $('#tr_ap_fc1_' + nRow).remove();
        $("#FC1_apnum").val(Math.max(0, nRow - 1));
    });
    
    //***變更後申請人
    apcust_form.getappy1 = function (apcust_no, in_no) {
        $("#FC2_tabap tbody").empty();

        $.ajax({
            type: "get",
            url: getRootPath() + "/ajax/_apcust.aspx?apcust_no=" + apcust_no + "&in_no=" + in_no,
            async: false,
            cache: false,
            success: function (json) {
                if ($("#chkTest").prop("checked")) toastr.info("<a href='" + this.url + "' target='_new'>Debug(_apcust交辦申請人)！<BR><b><u>(點此顯示詳細訊息)</u></b></a>");
                var apcust_list = $.parseJSON(json);
                if (apcust_list.length == 0) {
                    alert("無該申請人編號!!!");
                    return false;
                }

                $.each(apcust_list, function (i, item) {
                    //增加一筆
                    $("#FC2_AP_Add_button").click();
                    //填資料
                    var nRow = $("#FC2_apnum").val();
                    $("#dbmn1_apsqlno_" + nRow).val(item.apsqlno);
                    $("#dbmn1_o_apsqlno_" + nRow).val(item.apsqlno);
                    $("#ttg1_apclass_" + nRow).val(item.apclass);
                    $("#dbmn1_country_" + nRow).val(item.ap_country);
                    $("#dbmn1_new_no_" + nRow).val(item.apcust_no);
                    $("#dbmn1_o_apcust_no_" + nRow).val(item.apcust_no);
                    $("#dbmn1_ncname1_" + nRow).val(item.ap_cname1);
                    $("#dbmn1_ncname2_" + nRow).val(item.ap_cname2);
                    $("#dbmn1_nename1_" + nRow).val(item.ap_ename1);
                    $("#dbmn1_nename2_" + nRow).val(item.ap_ename2);
                    $("#dbmn1_ncrep_" + nRow).val(item.ap_crep);
                    $("#dbmn1_nerep_" + nRow).val(item.ap_erep);
                    $("#dbmn1_naddr1_" + nRow).val(item.ap_addr1);
                    $("#dbmn1_naddr2_" + nRow).val(item.ap_addr2);
                    $("#dbmn1_neaddr1_" + nRow).val(item.ap_eaddr1);
                    $("#dbmn1_neaddr2_" + nRow).val(item.ap_eaddr2);
                    $("#dbmn1_neaddr3_" + nRow).val(item.ap_eaddr3);
                    $("#dbmn1_neaddr4_" + nRow).val(item.ap_eaddr4);
                    $("#dbmn1_ntel0_" + nRow).val(item.apatt_tel0);
                    $("#dbmn1_ntel_" + nRow).val(item.apatt_tel);
                    $("#dbmn1_ntel1_" + nRow).val(item.apatt_tel1);
                    $("#dbmn1_nfax_" + nRow).val(item.apatt_fax);
                    $("#dbmn1_nzip_" + nRow).val(item.ap_zip);
                    if (item.Server_flag == "Y") {
                        $("#fc2_ap_hserver_flag_" + nRow).prop("checked", true).triggerHandler("click");
                    } else {
                        $("#fc2_ap_hserver_flag_" + nRow).prop("checked", false).triggerHandler("click");
                    }
                    $("#dbmn1_fcname_" + nRow).val(item.ap_fcname);
                    $("#dbmn1_lcname_" + nRow).val(item.ap_lcname);
                    $("#dbmn1_fename_" + nRow).val(item.ap_fename);
                    $("#dbmn1_lename_" + nRow).val(item.ap_lename);
                    $("#dbmn1_ap_sql_" + nRow).val(item.ap_sql);
                    //申請人序號空值不顯示
                    if (item.ap_sql == "" || item.ap_sql == "0") {
                        $("#FC2trap_sql_" + nRow).hide();
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
    apcust_form.getAPy1 = function (nRow) {
        $.ajax({
            type: "get",
            url: getRootPath() + "/ajax/_apcust.aspx?apcust_no=" + $("#apcust_no_"+nRow).val() ,
            async: false,
            cache: false,
            success: function (json) {
                if ($("#chkTest").prop("checked")) toastr.info("<a href='" + this.url + "' target='_new'>Debug(_apcust申請人資料重抓)！<BR><b><u>(點此顯示詳細訊息)</u></b></a>");
                var apcust_list = $.parseJSON(json);
                if (apcust_list.length == 0) {
                    alert("無該申請人編號!!!");
                    return false;
                }

                $.each(apcust_list, function (i, item) {
                    $("#dbmn1_apsqlno_" + nRow).val(item.apsqlno);
                    $("#ttg1_apclass_" + nRow).val(item.apclass);
                    $("#dbmn1_country_" + nRow).val(item.ap_country);
                    $("#dbmn1_ncname1_" + nRow).val(item.ap_cname1);
                    $("#dbmn1_ncname2_" + nRow).val(item.ap_cname2);
                    $("#dbmn1_nename1_" + nRow).val(item.ap_ename1);
                    $("#dbmn1_nename2_" + nRow).val(item.ap_ename2);
                    $("#dbmn1_ncrep_" + nRow).val(item.ap_crep);
                    $("#dbmn1_nerep_" + nRow).val(item.ap_erep);
                    $("#dbmn1_naddr1_" + nRow).val(item.ap_addr1);
                    $("#dbmn1_naddr2_" + nRow).val(item.ap_addr2);
                    $("#dbmn1_neaddr1_" + nRow).val(item.ap_eaddr1);
                    $("#dbmn1_neaddr2_" + nRow).val(item.ap_eaddr2);
                    $("#dbmn1_neaddr3_" + nRow).val(item.ap_eaddr3);
                    $("#dbmn1_neaddr4_" + nRow).val(item.ap_eaddr4);
                    $("#dbmn1_ntel0_" + nRow).val(item.apatt_tel0);
                    $("#dbmn1_ntel_" + nRow).val(item.apatt_tel);
                    $("#dbmn1_ntel1_" + nRow).val(item.apatt_tel1);
                    $("#dbmn1_nfax_" + nRow).val(item.apatt_fax);
                    $("#dbmn1_nzip_" + nRow).val(item.ap_zip);
                    $("#dbmn1_fcname_" + nRow).val(item.ap_fcname);
                    $("#dbmn1_lcname_" + nRow).val(item.ap_lcname);
                    $("#dbmn1_fename_" + nRow).val(item.ap_fename);
                    $("#dbmn1_lename_" + nRow).val(item.ap_lename);
                    $("#dbmn1_ap_sql_" + nRow).val("");
                })
            },
            error: function (xhr) { 
                $("#dialog").html("<a href='" + this.url + "' target='_new'>申請人資料載入失敗！<u>(點此顯示詳細訊息)</u></a><hr>"+xhr.responseText);
                $("#dialog").dialog({ title: '申請人資料載入失敗！', modal: true, maxHeight: 500,width: "90%" });
            }
        });
    }

    //***原申請人重抓
    apcust_form.getappx1 = function (nRow) {
        $.ajax({
            type: "get",
            url: getRootPath() + "/ajax/_apcust.aspx?apcust_no=" + $("#dbmo1_old_no_" + nRow).val(),
            async: false,
            cache: false,
            success: function (json) {
                if ($("#chkTest").prop("checked")) toastr.info("<a href='" + this.url + "' target='_new'>Debug(_apcust申請人資料重抓)！<BR><b><u>(點此顯示詳細訊息)</u></b></a>");
                var apcust_list = $.parseJSON(json);
                if (apcust_list.length == 0) {
                    alert("無該申請人編號!!!");
                    return false;
                }

                $.each(apcust_list, function (i, item) {
                    $("#dbmo1_ocname1_" + nRow).val(item.ap_cname1);
                    $("#dbmo1_ocname2_" + nRow).val(item.ap_cname2);
                    $("#dbmo1_oename1_" + nRow).val(item.ap_ename1);
                    $("#dbmo1_oename2_" + nRow).val(item.ap_ename2);
                    $("#dbmo1_ocrep_" + nRow).val(item.ap_crep);
                    $("#dbmo1_oerep_" + nRow).val(item.ap_erep);
                    $("#dbmo1_oaddr1_" + nRow).val(item.ap_addr1);
                    $("#dbmo1_oaddr2_" + nRow).val(item.ap_addr2);
                    $("#dbmn1_oeaddr1_" + nRow).val(item.ap_eaddr1);
                    $("#dbmn1_oeaddr2_" + nRow).val(item.ap_eaddr2);
                    $("#dbmn1_oeaddr3_" + nRow).val(item.ap_eaddr3);
                    $("#dbmn1_oeaddr4_" + nRow).val(item.ap_eaddr4);
                    $("#dbmo1_otel0_" + nRow).val(item.apatt_tel0);
                    $("#dbmo1_otel_" + nRow).val(item.apatt_tel);
                    $("#dbmo1_otel1_" + nRow).val(item.apatt_tel1);
                    $("#dbmo1_ofax_" + nRow).val(item.apatt_fax);
                    $("#dbmo1_ozip_" + nRow).val(item.ap_zip);
                })
            },
            error: function (xhr) {
                $("#dialog").html("<a href='" + this.url + "' target='_new'>原申請人資料載入失敗！<u>(點此顯示詳細訊息)</u></a><hr>" + xhr.responseText);
                $("#dialog").dialog({ title: '原申請人資料載入失敗！', modal: true, maxHeight: 500, width: "90%" });
            }
        });
    }
</script>
