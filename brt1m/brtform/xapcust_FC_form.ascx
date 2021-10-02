<%@ Control Language="C#" ClassName="apcust_FC_form" %>
<%@ Import Namespace = "System.Collections.Generic"%>

<script runat="server">
    //父控制項傳入的參數
    public Dictionary<string, string> Lock = new Dictionary<string, string>();
    
    protected string prgid = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string SQL = "";

    protected string ar_form = "";
    protected string apclass = "", ap_country = "";
    protected string apserver_name = "";

    private void Page_Load(System.Object sender, System.EventArgs e) {
        apclass = Sys.getCustCode("apclass", "", "sortfld").Option("{cust_code}", "{code_name}");
        ap_country = Sys.getCountry().Option("{coun_code}", "{coun_c}");
        ar_form = (Request["ar_form"] ?? "").Trim();
        
        apserver_name = "註記此申請人為應受送達人";

        if (ar_form == "A7" || ar_form == "A8"||ar_form=="B")
            apserver_name = "此申請人為選定代表人";
         
        this.DataBind();
    }
</script>

<script type="text/html" id="div_apcust_FC">
<%=Sys.GetAscxPath(this.AppRelativeVirtualPath)%>
<input type=hidden id=FC_apnum name=FC_apnum value=0><!--筆數-->
<table border="0" id=FC_tabap class="bluetable" cellspacing="1" cellpadding="2" width="100%">
	<THEAD>
		<tr>
			<td class="lightbluetable" colspan="8" valign="top"><strong><span id=span_FC></span></strong></td>
		</tr>
	    <TR>
			<TD  class=whitetablebg colspan=4 align=right>
                <span id="span_btn_POA">
    			    <input type=button class="greenbutton <%#Lock.TryGet("Qdisabled")%>" id="btn_POA" name="btn_POA" value="查詢申請人委任書"  onclick="apcust_form.btn_POA('FC_tabap', '')">
			    </span>
			    <input type=button value="增加一筆申請人" class="cbutton" id=FC_AP_Add_button name=FC_AP_Add_button>
			    <input type=button value="減少一筆申請人" class="cbutton" id=FC_AP_Del_button name=FC_AP_Del_button>
		    </TD>
	    </TR>
	</THEAD>
	<TBODY>
	</TBODY>
</table>
<INPUT TYPE=hidden id=tfr_mod_field value="mod_ap">

<script type="text/html" id="apcust_template">
	<TR>
		<TD class=lightbluetable align=right>
			<input type=text id="apnum_##" name="apnum_##" value="##." class="SEdit" readonly size=2>申請人種類：
		</TD>
		<TD class=sfont9>
			<select id="apclass_##" name="apclass_##" class="SEdit" readonly><%#apclass%></select>
            <label><input type="checkbox" id="fc_ap_hserver_flag_##" name="fc_ap_hserver_flag_##" value="Y" onclick="apcust_form.apserver_flag('##')"><%#apserver_name%>
            <input type="hidden" id="fc_ap_server_flag_##" name="fc_ap_server_flag_##" value="N"></label>
		</TD>
		<TD class=lightbluetable align=right title="輸入編號並點選確定，即顯示申請人資料；若無資料，請直接輸入申請人資料。">
			<span id="span_apcust_no_##" style="cursor:pointer;color:blue">申請人編號<br>(統一編號/身份證字號)：</span>
		</TD>
		<TD class=sfont9>
			<input type=text id="apcust_no_##" name="apcust_no_##" size=11 maxlength=10 onblur="apcust_form.chkapcust_no('##')">
		    <input type='button' id='queryap_##' name='queryap_##' value='確定' onclick="apcust_form.getAP('##')" style='cursor:pointer;' title='輸入編號並點選確定，即顯示申請人資料；若無資料，請直接輸入申請人資料。'>
		</TD>
	</TR>
	<TR>
		<TD class=lightbluetable align=right>申請人國籍：</TD>
		<TD class=sfont9>
            <select id="ap_country_##" name="ap_country_##" class="SEdit" readonly><%#ap_country%></select>
		</TD>
		<TD class=lightbluetable align=right>排序：</TD>
		<TD class=sfont9>
			<input type=text id="ap_sort_##" name="ap_sort_##" size=2 maxlength=2>
		</TD>
	</TR>
	<TR>
		<TD class=lightbluetable align=right title="輸入關鍵字並點選申請人查詢，即顯示申請人資料清單。">申請人名稱(中)：</TD>
		<TD class=sfont9 colspan=3>
            <input type=hidden id="ap_cname_##" name="ap_cname_##">
		    <input type=hidden id="apsqlno_##" name="apsqlno_##">
		    <INPUT TYPE=text id="ap_cname1_##" name="ap_cname1_##" SIZE=40 MAXLENGTH=60 alt="申請人名稱(中)" onblur="fDataLen(this)"><br>
		    <INPUT TYPE=text id="ap_cname2_##" name="ap_cname2_##" SIZE=40 MAXLENGTH=60 alt="申請人名稱(中)" onblur="fDataLen(this)">
		    <INPUT type='button' value='申請人查詢' onclick="apcust_form.cust13query('##')"  style='cursor:pointer;' title='輸入關鍵字並點選申請人查詢，即顯示申請人資料清單。'>
		</TD>
	</TR>
	<TR>
		<TD class=lightbluetable align=right>申請人名稱(中)：</TD>
		<TD class=sfont9 colspan=3>
		    姓：<INPUT TYPE=text id="ap_fcname_##" name="ap_fcname_##" SIZE=20 MAXLENGTH=60 class="SEdit" readonly>
		    名：<INPUT TYPE=text id="ap_lcname_##" name="ap_lcname_##" SIZE=20 MAXLENGTH=60 class="SEdit" readonly>
		</TD>
	</TR>
	<TR id="FCtrap_sql_##">
		<TD class=lightbluetable align=right>申請人序號：</TD>
		<TD class=sfont9 colspan=3>
		    <INPUT TYPE=text id="ap_sql_##" name="ap_sql_##" SIZE=3 MAXLENGTH=3 class="SEdit" readonly>
		</TD>
	</TR>
	<TR>
		<TD class=lightbluetable align=right>
            <input type=button class='cbutton <%#Lock.TryGet("QA1disabled")%>' value='查詢' onclick="apcust_form.get_apnameaddr('##', 'FC', '')">申請人名稱(英)：
		</TD>
		<TD class=sfont9 colspan=3>
            <input type=hidden id="ap_ename_##" name="ap_ename_##">
		    <INPUT TYPE=text id="ap_ename1_##" name="ap_ename1_##" SIZE=60 MAXLENGTH=100 alt="申請人名稱(英)" onblur="fDataLen(this)"><br>
		    <INPUT TYPE=text id="ap_ename2_##" name="ap_ename2_##" SIZE=60 MAXLENGTH=100 alt="申請人名稱(英)" onblur="fDataLen(this)">
	    </TD>
	</TR>
	<TR>
		<TD class=lightbluetable align=right>申請人名稱(英)：</TD>
		<TD class=sfont9 colspan=3>
		    姓：<INPUT TYPE=text id="ap_fename_##" name="ap_fename_##" SIZE=20 MAXLENGTH=60 class="SEdit" readonly>
		    名：<INPUT TYPE=text id="ap_lename_##" name="ap_lename_##" SIZE=20 MAXLENGTH=60 class="SEdit" readonly>
		</TD>
	</TR>
	<TR>
		<TD class=lightbluetable align=right>代表人名稱(中)：</TD>
		<TD class=sfont9 colspan=3>
		    <INPUT TYPE=text id="ap_crep_##" name="ap_crep_##" SIZE=40 MAXLENGTH=40 class="SEdit" readonly>
		</TD>
	</TR>
	<TR>
		<TD class=lightbluetable align=right>代表人名稱(英)：</TD>
		<TD class=sfont9 colspan=3>
		    <INPUT TYPE=text id="ap_erep_##" name="ap_erep_##" SIZE=80 MAXLENGTH=80 class="SEdit" readonly>
		</TD>
	</TR>
	<TR>
		<TD class=lightbluetable align=right>證照地址(中)：</TD>
		<TD class=sfont9 colspan=3>
		    <INPUT TYPE=text id="ap_zip_##" name="ap_zip_##" SIZE=8 MAXLENGTH=8 class="SEdit" readonly>
		    <INPUT TYPE=text id="ap_addr1_##" name="ap_addr1_##" SIZE=103 MAXLENGTH=120 class="SEdit" readonly><br>
		    <INPUT TYPE=text id="ap_addr2_##" name="ap_addr2_##" SIZE=103 MAXLENGTH=120 class="SEdit" readonly>
		</TD>
	</TR>
	<TR>
		<TD class=lightbluetable align=right>證照地址(英)：</TD>
		<TD class=sfont9 colspan=3>
		    <INPUT TYPE=text id="ap_eaddr1_##" name="ap_eaddr1_##" SIZE=103 MAXLENGTH=120 class="SEdit" readonly><br>
		    <INPUT TYPE=text id="ap_eaddr2_##" name="ap_eaddr2_##" SIZE=103 MAXLENGTH=120 class="SEdit" readonly><br>
		    <INPUT TYPE=text id="ap_eaddr3_##" name="ap_eaddr3_##" SIZE=103 MAXLENGTH=120 class="SEdit" readonly><br>
		    <INPUT TYPE=text id="ap_eaddr4_##" name="ap_eaddr4_##" SIZE=103 MAXLENGTH=120 class="SEdit" readonly>
		</TD>
	</TR>
	<TR>
		<TD class=lightbluetable align=right>聯絡地址：</TD>
		<TD class=sfont9 colspan=3>
		    <INPUT TYPE=text id="apatt_zip_##" name="apatt_zip_##" SIZE=8 MAXLENGTH=8 class="SEdit" readonly>
		    <INPUT TYPE=text id="apatt_addr1_##" name="apatt_addr1_##" SIZE=30 MAXLENGTH=60 class="SEdit" readonly>
		    <INPUT TYPE=text id="apatt_addr2_##" name="apatt_addr2_##" SIZE=30 MAXLENGTH=60 class="SEdit" readonly>
		</TD>
	</TR>
	<TR>
		<TD class=lightbluetable align=right>電話：</TD>
		<TD class=sfont9>
            <INPUT TYPE=text id="apatt_tel0_##" name="apatt_tel0_##" SIZE=4 MAXLENGTH=4 class="SEdit" readonly>
            <INPUT TYPE=text id="apatt_tel_##" name="apatt_tel_##" SIZE=15 MAXLENGTH=15 class="SEdit" readonly>
            <INPUT TYPE=text id="apatt_tel1_##" name="apatt_tel1_##" SIZE=10 MAXLENGTH=10 class="SEdit" readonly>
		</TD>
		<TD class=lightbluetable align=right>傳真：</TD>
		<TD class=sfont9>
			<INPUT TYPE=text id="apatt_fax_##" name="apatt_fax_##" SIZE=20 MAXLENGTH=20 class="SEdit" readonly>
		</TD>
	</TR>
</script>

<script language="javascript" type="text/javascript">
    var apcust_form={};
    apcust_form.init = function () {
    }
    
    //增加一筆申請人
    $("#FC_AP_Add_button").click(function () { apcust_form.appendAP(); });
    apcust_form.appendAP = function () {
        var nRow = CInt($("#FC_apnum").val()) + 1;
        //複製樣板
        var copyStr = $("#apcust_template").text()||"";
        copyStr = copyStr.replace(/##/g, nRow);

        $("#FC_tabap>tbody").append("<tr id='tr_ap_" + nRow + "' class='sfont9'><td><table border='0' class='bluetable' cellspacing='1' cellpadding='2' width='100%'>" + copyStr + "</table></td></tr>");
        $("#tr_ap_" + nRow + " .Lock").lock();
        $("#FC_apnum").val(nRow);
    }

    //減少一筆申請人
    $("#FC_AP_Del_button").click(function () { apcust_form.deleteAP(); });
    apcust_form.deleteAP = function () {
        var nRow = CInt($("#FC_apnum").val());
        $('#tr_ap_'+nRow).remove();
        $("#FC_apnum").val(Math.max(0, nRow - 1));
    }

    apcust_form.getapp = function (apcust_no, in_no) {
        console.log("apcust_fc_getapp");
        $("#FC_tabap tbody").empty();

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
                    $("#FC_AP_Add_button").click();
                    //填資料
                    var nRow = $("#FC_apnum").val();
                    $("#apsqlno_" + nRow).val(item.apsqlno);
                    $("#apclass_" + nRow).val(item.apclass);
                    $("#apcust_no_" + nRow).val(item.apcust_no);
                    $("#ap_country_" + nRow).val(item.ap_country);
                    $("#ap_sortfld_" + nRow).val(item.ap_sort);
                    $("#ap_cname1_" + nRow).val(item.ap_cname1);
                    $("#ap_cname2_" + nRow).val(item.ap_cname2);
                    $("#ap_cname_" + nRow).val(item.ap_cname1 + item.ap_cname2);
                    $("#ap_ename1_" + nRow).val(item.ap_ename1);
                    $("#ap_ename2_" + nRow).val(item.ap_ename2);
                    $("#ap_ename_" + nRow).val(item.ap_ename1 + item.ap_ename2);
                    $("#ap_crep_" + nRow).val(item.ap_crep);
                    $("#ap_erep_" + nRow).val(item.ap_erep);
                    $("#ap_zip_" + nRow).val(item.ap_zip);
                    $("#ap_addr1_" + nRow).val(item.ap_addr1);
                    $("#ap_addr2_" + nRow).val(item.ap_addr2);
                    $("#ap_eaddr1_" + nRow).val(item.ap_eaddr1);
                    $("#ap_eaddr2_" + nRow).val(item.ap_eaddr2);
                    $("#ap_eaddr3_" + nRow).val(item.ap_eaddr3);
                    $("#ap_eaddr4_" + nRow).val(item.ap_eaddr4);
                    $("#apatt_zip_" + nRow).val(item.apatt_zip);
                    $("#apatt_addr1_" + nRow).val(item.apatt_addr1);
                    $("#apatt_addr2_" + nRow).val(item.apatt_addr2);
                    $("#apatt_tel0_" + nRow).val(item.apatt_tel0);
                    $("#apatt_tel_" + nRow).val(item.apatt_tel);
                    $("#apatt_tel1_" + nRow).val(item.apatt_tel1);
                    $("#apatt_fax_" + nRow).val(item.apatt_fax);
                    if (item.Server_flag == "Y") {
                        $("#fc_ap_hserver_flag_" + nRow).prop("checked", true).triggerHandler("click");
                    } else {
                        $("#fc_ap_hserver_flag_" + nRow).prop("checked", false).triggerHandler("click");
                    }
                    $("#ap_fcname_" + nRow).val(item.ap_fcname);
                    $("#ap_lcname_" + nRow).val(item.ap_lcname);
                    $("#ap_fename_" + nRow).val(item.ap_fename);
                    $("#ap_lename_" + nRow).val(item.ap_lename);
                    $("#ap_sql_" + nRow).val(item.ap_sql);
                    //申請人序號空值不顯示
                    if (item.ap_sql == "" || item.ap_sql == "0") {
                        $("#FCtrap_sql_" + nRow).hide();
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
    apcust_form.getAP = function (nRow) {
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
                    $("#apsqlno_" + nRow).val(item.apsqlno);
                    $("#apclass_" + nRow).val(item.apclass);
                    $("#apcust_no_" + nRow).val(item.apcust_no);
                    $("#ap_country_" + nRow).val(item.ap_country);
                    $("#ap_cname1_" + nRow).val(item.ap_cname1);
                    $("#ap_cname2_" + nRow).val(item.ap_cname2);
                    $("#ap_cname_" + nRow).val(item.ap_cname1 + item.ap_cname2);
                    $("#ap_ename1_" + nRow).val(item.ap_ename1);
                    $("#ap_ename2_" + nRow).val(item.ap_ename2);
                    $("#ap_ename_" + nRow).val(item.ap_ename1 + item.ap_ename2);
                    $("#ap_crep_" + nRow).val(item.ap_crep);
                    $("#ap_erep_" + nRow).val(item.ap_erep);
                    $("#ap_zip_" + nRow).val(item.ap_zip);
                    $("#ap_addr1_" + nRow).val(item.ap_addr1);
                    $("#ap_addr2_" + nRow).val(item.ap_addr2);
                    $("#ap_eaddr1_" + nRow).val(item.ap_eaddr1);
                    $("#ap_eaddr2_" + nRow).val(item.ap_eaddr2);
                    $("#ap_eaddr3_" + nRow).val(item.ap_eaddr3);
                    $("#ap_eaddr4_" + nRow).val(item.ap_eaddr4);
                    $("#apatt_zip_" + nRow).val(item.apatt_zip);
                    $("#apatt_addr1_" + nRow).val(item.apatt_addr1);
                    $("#apatt_addr2_" + nRow).val(item.apatt_addr2);
                    $("#apatt_tel0_" + nRow).val(item.apatt_tel0);
                    $("#apatt_tel_" + nRow).val(item.apatt_tel);
                    $("#apatt_tel1_" + nRow).val(item.apatt_tel1);
                    $("#apatt_fax_" + nRow).val(item.apatt_fax);
                    if (item.Server_flag == "Y") {
                        $("#fc_ap_hserver_flag_" + nRow).prop("checked", true).triggerHandler("click");
                    } else {
                        $("#fc_ap_hserver_flag_" + nRow).prop("checked", false).triggerHandler("click");
                    }
                    $("#ap_fcname_" + nRow).val(item.ap_fcname);
                    $("#ap_lcname_" + nRow).val(item.ap_lcname);
                    $("#ap_fename_" + nRow).val(item.ap_fename);
                    $("#ap_lename_" + nRow).val(item.ap_lename);
                    $("#ap_sql_" + nRow).val("");
                })
            },
            error: function (xhr) { 
                $("#dialog").html("<a href='" + this.url + "' target='_new'>申請人資料載入失敗！<u>(點此顯示詳細訊息)</u></a><hr>"+xhr.responseText);
                $("#dialog").dialog({ title: '申請人資料載入失敗！', modal: true, maxHeight: 500,width: "90%" });
            }
        });
    }

    //申請人查詢
    apcust_form.cust13query = function (nRow) {
        if ($("#apcust_no_" + nRow).val() == "" && $("#ap_cname1_" + nRow).val() == "") {
            alert("請輸入統一編號或申請人(關係人)名稱");
            return false;
        }
        var url = getRootPath() + "/cust/cust13_list.aspx?ap_cname1=" + $("#ap_cname1_" + nRow).val() + "&ap_cname2=" + $("#ap_cname2_" + nRow).val() + "&submitTask=U";
        window.open(url, 'cust13Blank');
    }

    //應受送達人給值
    apcust_form.apserver_flag = function (papnum) {
        if ($("#fc_ap_hserver_flag_" + papnum).prop("checked"))
            $("#fc_ap_server_flag_" + papnum).val("Y");
        else
            $("#fc_ap_server_flag_" + papnum).val("N");
    }

    //檢查申請人重覆
    apcust_form.chkapcust_no = function (papnum) {
        var objAp = {};
        for (var r = 1; r <= CInt($("#FC_apnum").val()) ; r++) {
            var lineAp = $("#apcust_no_" + r).val();
            if (lineAp != "" && objAp[lineAp]) {
                alert("(" + r + ")申請人重覆，請重新輸入！！");
                $("#apcust_no_" + papnum).focus();
            } else {
                objAp[lineAp] = { flag: true, idx: r };
            }
        }
    }

    //抓取申請人多組英文名稱及地址(申請人英文名稱[查詢])
    //pTrId=申請人序號的tr前置名,pFld=欄位前置名
    apcust_form.get_apnameaddr = function (nRow, pTrId, pFld) {
        var apsqlno = $("#" + pFld + "apsqlno_" + nRow).val();
        if (apsqlno == "") {
            alert("請先輸入統編或再點選統編後「確定」重新抓取申請人資料！");
            return false;
        }
        
        var url = getRootPath() + "/cust/cust13_2Qlist.aspx?prgid=brt54&apsqlno=" + apsqlno + "&pnum=" + nRow + "&trid=" + pTrId + "&fld=" + pFld;
        window.open(url, 'myWindowOneN', "width=650 height=420 top=40 left=80 toolbar=no, menubar=no, location=no, directories=no resizeable=no status=no scrollbars=yes");
    }

    //查詢申請人委任書
    /*05644305
    select * from apcust_attach 
    --update apcust_attach set use_datee='2020/12/30'--2016-12-31 00:00:00
    where apattach_sqlno='N201512015'
    */
    //ptbl = 申請人table名, pfld = apsqlno欄位的前置名，如dbmn_apsqlno, 傳入dbmn_
    apcust_form.btn_POA = function (ptbl, pfld) {
        var allapsqlno = $("#" + ptbl + " input[id^='" + pfld + "apsqlno_']").map(function () {
            return $(this).val();
        }).get().join(',');

        var url = getRootPath() + "/brt1m/POA_attachlist.aspx?prgid=" + $("#prgid").val() + "&dept=T&source=POA&allapsqlno=" + allapsqlno + "&upload_tabname=upload";
        window.open(url, "myWindowapN", "width=900 height=680 top=20 left=20 toolbar=no, menubar=no, location=no, directories=no resizeable=no status=no scrollbars=yes");
    }
</script>
</script>