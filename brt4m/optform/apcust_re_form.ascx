<%@ Control Language="C#" ClassName="opt_apcust_re_form" %>

<script runat="server">
    protected string prgid = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string SQL = "";

    protected string branch = "";
    protected string opt_sqlno = "";

    protected string apclass = "", ap_country = "";

    private void Page_Load(System.Object sender, System.EventArgs e) {
        branch = Request["branch"] ?? "";
        opt_sqlno = Request["opt_sqlno"] ?? "";

        apclass = Sys.getCustCode("apclass", "", "sortfld").Option("{cust_code}", "{code_name}");
        ap_country = Sys.getCountry().Option("{coun_code}", "{coun_c}");
        
        this.DataBind();
    }
</script>

<%=Sys.GetAscxPath(this)%>
<input type=hidden id=apnum name=apnum value=0><!--筆數-->
<table border="0" id=tabap_re class="bluetable" cellspacing="1" cellpadding="2" width="100%">
	<TFOOT>
	<TR style="display:none">
		<TD class="bluetable sfont9" style="border-color:red" colspan=4 align=right>
			<input type=button value="增加一筆申請人" class="cbutton" id=AP_Add_button name=AP_Add_button>
			<input type=button value="減少一筆申請人" class="cbutton" id=AP_Del_button name=AP_Del_button>
		</TD>
	</TR>
	</TFOOT>
	<THEAD style="display:none">
		<TR>
			<TD class=lightbluetable align=right>
				<input type=text id="apnum_##" name="apnum_##" value="##." class="Lock" size=2>申請人種類：
			</TD>
			<TD class=sfont9>
				<select id="apclass_##" name="apclass_##" class="MLock"><%#apclass%></select>
                <input type="checkbox" id="ap_hserver_flag_##" name="ap_hserver_flag_##" value="Y" onclick="apcust_re_form.apserver_flag('##')" class="Lock">註記此申請人為應受送達人
                <input type="hidden" id="ap_server_flag_##" name="ap_server_flag_##" value="N">
			</TD>
			<TD class=lightbluetable align=right title="輸入編號並點選確定，即顯示申請人資料；若無資料，請直接輸入申請人資料。">
				<span id="span_Apcust_no_##" style="cursor:pointer;color:blue">申請人編號<br>(統一編號/身份證字號)：</span>
			</TD>
			<TD class=sfont9>
				<input type=text id="Apcust_no_##" name="Apcust_no_##" size=11 maxlength=10 onblur="chkapcust_no('##')" class="MLock">
			</TD>
		</TR>
		<TR>
			<TD class=lightbluetable align=right>申請人國籍：</TD>
			<TD class=sfont9 colspan=3>
                <select id="ap_country_##" name="ap_country_##" class="MLock"><%#ap_country%></select>
			</TD>
		</TR>
		<TR>
			<TD class=lightbluetable align=right>申請人名稱(中)：</TD>
			<TD class=sfont9 colspan=3>
                <input type=hidden id="ap_cname_##" name="ap_cname_##">
		        <input type=hidden id="apsqlno_##" name="apsqlno_##">
		        <INPUT TYPE=text id="ap_cname1_##" name="ap_cname1_##" SIZE=40 MAXLENGTH=60 alt="申請人名稱(中)" onblur="fDataLen(this.value,this.maxLength,this.alt)" class="MLock"><br>
		        <INPUT TYPE=text id="ap_cname2_##" name="ap_cname2_##" SIZE=40 MAXLENGTH=60 alt="申請人名稱(中)" onblur="fDataLen(this.value,this.maxLength,this.alt)" class="MLock">
			</TD>
		</TR>
		<TR>
			<TD class=lightbluetable align=right>申請人名稱(中)：</TD>
			<TD class=sfont9 colspan=3>
		        姓：<INPUT TYPE=text id="ap_fcname_##" name="ap_fcname_##" SIZE=20 MAXLENGTH=60 class="Lock">
		        名：<INPUT TYPE=text id="ap_lcname_##" name="ap_lcname_##" SIZE=20 MAXLENGTH=60 class="Lock">
			</TD>
		</TR>
		<TR id="trap_sql_##">
			<TD class=lightbluetable align=right>申請人序號：</TD>
			<TD class=sfont9 colspan=3>
		        <INPUT TYPE=text id="ap_sql##" name="ap_sql##" SIZE=3 MAXLENGTH=3 class="Lock">
			</TD>
		</TR>
		<TR>
			<TD class=lightbluetable align=right>申請人名稱(英)：</TD>
			<TD class=sfont9 colspan=3>
                <input type=hidden id="ap_ename_##" name="ap_ename_##">
		        <INPUT TYPE=text id="ap_ename1_##" name="ap_ename1_##" SIZE=60 MAXLENGTH=100 alt="申請人名稱(英)" onblur="fDataLen(this.value,this.maxLength,this.alt)" class="MLock"><br>
		        <INPUT TYPE=text id="ap_ename2_##" name="ap_ename2_##" SIZE=60 MAXLENGTH=100 alt="申請人名稱(英)" onblur="fDataLen(this.value,this.maxLength,this.alt)" class="MLock">
			</TD>
		</TR>
		<TR>
			<TD class=lightbluetable align=right>申請人名稱(英)：</TD>
			<TD class=sfont9 colspan=3>
		        姓：<INPUT TYPE=text id="ap_fename_##" name="ap_fename_##" SIZE=20 MAXLENGTH=60 class="Lock">
		        名：<INPUT TYPE=text id="ap_lename_##" name="ap_lename_##" SIZE=20 MAXLENGTH=60 class="Lock">
			</TD>
		</TR>
		<TR>
			<TD class=lightbluetable align=right>代表人名稱(中)：</TD>
			<TD class=sfont9 colspan=3>
		        <INPUT TYPE=text id="ap_crep_##" name="ap_crep_##" SIZE=40 MAXLENGTH=40 class="MLock">
			</TD>
		</TR>
		<TR>
			<TD class=lightbluetable align=right>代表人名稱(英)：</TD>
			<TD class=sfont9 colspan=3>
		        <INPUT TYPE=text id="ap_erep_##" name="ap_erep_##" SIZE=80 MAXLENGTH=80 class="MLock">
			</TD>
		</TR>
		<TR>
			<TD class=lightbluetable align=right>證照地址(中)：</TD>
			<TD class=sfont9 colspan=3>
		        <INPUT TYPE=text id="ap_zip_##" name="ap_zip_##" SIZE=8 MAXLENGTH=8 class="MLock">
		        <INPUT TYPE=text id="ap_addr1_##" name="ap_addr1_##" SIZE=103 MAXLENGTH=120 class="MLock"><br>
		        <INPUT TYPE=text id="ap_addr2_##" name="ap_addr2_##" SIZE=103 MAXLENGTH=120 class="MLock">
			</TD>
		</TR>
		<TR>
			<TD class=lightbluetable align=right>證照地址(英)：</TD>
			<TD class=sfont9 colspan=3>
		        <INPUT TYPE=text id="ap_eaddr1_##" name="ap_eaddr1_##" SIZE=103 MAXLENGTH=120 class="MLock"><br>
		        <INPUT TYPE=text id="ap_eaddr2_##" name="ap_eaddr2_##" SIZE=103 MAXLENGTH=120 class="MLock"><br>
		        <INPUT TYPE=text id="ap_eaddr3_##" name="ap_eaddr3_##" SIZE=103 MAXLENGTH=120 class="MLock"><br>
		        <INPUT TYPE=text id="ap_eaddr4_##" name="ap_eaddr4_##" SIZE=103 MAXLENGTH=120 class="MLock">
			</TD>
		</TR>
		<TR>
			<TD class=lightbluetable align=right>聯絡地址：</TD>
			<TD class=sfont9 colspan=3>
		        <INPUT TYPE=text id="apatt_zip_##" name="apatt_zip_##" SIZE=5 MAXLENGTH=5 class="MLock">
		        <INPUT TYPE=text id="apatt_addr1_##" name="apatt_addr1_##" SIZE=30 MAXLENGTH=60 class="MLock">
		        <INPUT TYPE=text id="apatt_addr2_##" name="apatt_addr2_##" SIZE=30 MAXLENGTH=60 class="MLock">
			</TD>
		</TR>
		<TR>
			<TD class=lightbluetable align=right>電話：</TD>
			<TD class=sfont9>
                <INPUT TYPE=text id="apatt_tel0_##" name="apatt_tel0_##" SIZE=4 MAXLENGTH=4 class="MLock">
                <INPUT TYPE=text id="apatt_tel_##" name="apatt_tel_##" SIZE=15 MAXLENGTH=15 class="MLock">
                <INPUT TYPE=text id="apatt_tel1_##" name="apatt_tel1_##" SIZE=10 MAXLENGTH=10 class="MLock">
			</TD>
			<TD class=lightbluetable align=right>傳真：</TD>
			<TD class=sfont9>
				<INPUT TYPE=text id="apatt_fax_##" name="apatt_fax_##" SIZE=20 MAXLENGTH=20 class="MLock">
			</TD>
		</TR>
	</THEAD>
	<TBODY>
	</TBODY>
</table>

<script language="javascript" type="text/javascript">
    var apcust_re_form={};
    apcust_re_form.init = function () {
        var jCaseap = br_opt.caseap;
        $("#tabap_re>tbody").empty();
        $.each(jCaseap, function (i, item) {
            //增加一筆
            $("#AP_Add_button").click();
            //填資料
            var nRow = $("#apnum").val();
            $("#apsqlno_" + nRow).val(item.apsqlno);
            $("#apclass_" + nRow).val(item.apclass);
            $("#Apcust_no_" + nRow).val(item.apcust_no);
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
                $("#ap_hserver_flag_" + nRow).prop("checked", true);
            } else {
                $("#ap_hserver_flag_" + nRow).prop("checked", false);
            }
            apcust_re_form.apserver_flag(nRow);
            $("#ap_fcname_" + nRow).val(item.ap_fcname);
            $("#ap_lcname_" + nRow).val(item.ap_lcname);
            $("#ap_fename_" + nRow).val(item.ap_fename);
            $("#ap_lename_" + nRow).val(item.ap_lename);
            $("#ap_sql_" + nRow).val(item.ap_sql);
            //申請人序號空值不顯示
            if (item.ap_sql == "" || item.ap_sql == "0") {
                $("#trap_sql_" + nRow).hide();
            }
        });
    }
    
    //增加一筆申請人
    $("#AP_Add_button").click(function () { apcust_re_form.appendAP(); });
    apcust_re_form.appendAP = function () {
        var nRow = parseInt($("#apnum").val(), 10) + 1;
        //複製樣板
        var copyStr = "";
        $("#tabap_re>thead tr").each(function (i) {
            copyStr += "<tr>" + $(this).html().replace(/##/g, nRow) + "</tr>"
        });
        $("#tabap_re>tbody").append("<tr id='tr_ap_" + nRow + "' class='sfont9'><td><table border='0' class='bluetable' cellspacing='1' cellpadding='2' width='100%'>" + copyStr + "</table></td></tr>");
        $("#apnum").val(nRow);
    }

    //減少一筆申請人
    $("#AP_Del_button").click(function () { apcust_re_form.deleteAP(); });
    apcust_re_form.deleteAP = function () {
        var nRow = parseInt($("#apnum").val(), 10);
        $('#tr_ap_'+nRow).remove();
        $("#apnum").val(Math.max(0, nRow - 1));
    }

    //應受送達人給值
    apcust_re_form.apserver_flag = function (papnum) {
        if ($("#ap_hserver_flag_" + papnum).prop("checked"))
            $("#ap_server_flag_" + papnum).val("Y");
        else
            $("#ap_server_flag_" + papnum).val("N");
    }
</script>
