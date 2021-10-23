<%@ Control Language="C#" ClassName="cust13Form" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace = "System.Text"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.IO"%>
<%@ Import Namespace = "System.Linq"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Web.Script.Serialization"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>

<script runat="server">
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    
    //申請人種類
    protected string html_apclass = Sys.getCustCode("apclass", "", "sortfld").Option("{cust_code}", "{cust_code}_{code_name}");
    //申請人國籍
    protected string html_country = Sys.getCountry().Option("{coun_code}", "{coun_code}_{coun_c}");

    
    private void Page_Load(System.Object sender, System.EventArgs e)
    {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;
        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");
        prgid = Request["prgid"].ToString();
    }
    
    
</script>

<style>
    .InputMB input{
         margin-bottom : 4px;
    }

</style>


<table border="0" class="bluetable" cellspacing="1" cellpadding="2" width="100%" >
	<tr>
		<td class="lightbluetable" align="right">※申請人種類：</td>
		<td class="whitetablebg" align="left">
            <input name="hapclass" id="hapclass" type="hidden" value="" />
				<select name="apclass" id="apclass" onchange="cust13form.apclassChange()" onblur="cust13form.ChkApclass()">
                    <%#html_apclass%>
				</select>
            <input TYPE="text" id="txtapclass" NAME="txtapclass" readonly class="SEdit" size="30" value="">
		</td>
		<td class="lightbluetable" align="right" width="12%">申請人國籍：</td>
		<td class="whitetablebg" align="left">
			<select name="ap_country" id="ap_country" onblur="cust13form.chkCountry()">
                <%#html_country %>
			</select> 
		</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right" width="17%">※申請人編號：</td>
		<td class="whitetablebg" colspan="3">
			<input TYPE="text" id="apcust_no" NAME="apcust_no" SIZE="12" MAXLENGTH="10" value="<%=ReqVal.TryGet("apcust_no")%>" onblur="cust13form.ChkApcust_no();cust13form.ChkDataDouble();" >
		</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right">※申請人名稱(中)：</td>
		<td class="whitetablebg" colspan="3">
			<input TYPE="text" NAME="ap_cname1" id="ap_cname1" SIZE="47" MAXLENGTH="44"  value="<%=ReqVal.TryGet("cname1")%>" onblur="cust13form.ap_cname1onblur()">
			<input TYPE="text" NAME="ap_cname2" id="ap_cname2" SIZE="47" MAXLENGTH="44"  value="">
		</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right" title="若是複姓請注意調整姓及名字數的正確性"><font color=red><u>申請人名稱(中)：</u></font></td>
		<td class="whitetablebg" colspan="3">
			姓：<input TYPE="text" id="ap_fcname" NAME="ap_fcname" SIZE="16" MAXLENGTH="15" value="">
			名：<input TYPE="text" id="ap_lcname" NAME="ap_lcname" SIZE="16" MAXLENGTH="15" value="">
		</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right">申請人名稱(英)：</td>
		<td class="whitetablebg" colspan="3">
            <input TYPE="hidden" NAME="ap_ename1_name" value="申請人名稱(英)1">
			<input TYPE="hidden" NAME="ap_ename2_name" value="申請人名稱(英)2">
            <input TYPE="hidden" NAME="oap_ename1" id="oap_ename1" >
            <input TYPE="hidden" NAME="oap_ename2" id="oap_ename2" >
			<input TYPE="text" NAME="ap_ename1" id="ap_ename1" SIZE="60" MAXLENGTH="100" value="">
			<input TYPE="text" NAME="ap_ename2" id="ap_ename2" SIZE="60" MAXLENGTH="100" value="">
		</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right">申請人名稱(英)：</td>
		<td class="whitetablebg" colspan="3">
            <input TYPE="hidden" NAME="ap_fename_name" value="申請人名稱(英)姓">
			<input TYPE="hidden" NAME="ap_lename_name" value="申請人名稱(英)名">
            <input TYPE="hidden" NAME="oap_fename" id="oap_fename">
            <input TYPE="hidden" NAME="oap_lename" id="oap_lename">
			姓：<input TYPE="text" id="ap_fename" NAME="ap_fename" SIZE="33" MAXLENGTH="30" value="">
			名：<input TYPE="text" id="ap_lename" NAME="ap_lename" SIZE="33" MAXLENGTH="30" value="">
		</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right">代表人名稱(中)：</td>
		<td class="whitetablebg" colspan="3">
            <input TYPE="hidden" NAME="ap_crep_name" value="代表人名稱(中)">
            <input TYPE="hidden" NAME="oap_crep" id="oap_crep">
		    <input TYPE="text" NAME="ap_crep" id="ap_crep" SIZE="22" MAXLENGTH="40">
		</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right">代表人名稱(英)：</td>
		<td class="whitetablebg" colspan="3">
            <input TYPE="hidden" NAME="ap_erep_name" value="代表人名稱(英)">
            <input TYPE="hidden" NAME="oap_erep" id="oap_erep" >
		    <input TYPE="text" NAME="ap_erep" id="ap_erep" SIZE="44" MAXLENGTH="40" value="">
		</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right">代表人職稱：</td>
		<td class="whitetablebg" colspan="3">
            <input TYPE="hidden" NAME="ap_title_name" value="代表人職稱">
            <input TYPE="hidden" NAME="oap_title" id="oap_title" >
		    <input TYPE="text" NAME="ap_title" id="ap_title" SIZE="55" MAXLENGTH="50" value="">
		</td>
	</tr>
	<tr class="InputMB"><!--2016/1/7增加地址長度120-->	
		<td class="lightbluetable" align="right">證照地址(中)：</td>
		<td class="whitetablebg" colspan="3">
        <input TYPE="hidden" NAME="ap_zip_name" value="證照地址(中)郵遞區號">
		<input TYPE="hidden" NAME="ap_addr1_name" value="證照地址(中)1">
		<input TYPE="hidden" NAME="ap_addr2_name" value="證照地址(中)2">
        <input TYPE="hidden" NAME="oap_zip" id="oap_zip">
        <input TYPE="hidden" NAME="oap_addr1" id="oap_addr1">
        <input TYPE="hidden" NAME="oap_addr2" id="oap_addr2">
		郵遞區號 <input TYPE="text" NAME="ap_zip" id="ap_zip" SIZE="8" MAXLENGTH="8" value="" class="InputNumOnly"/><br />
		<input TYPE="text" NAME="ap_addr1" id="ap_addr1" SIZE="103" MAXLENGTH="120"  value=""/><br />
		<input TYPE="text" NAME="ap_addr2" id="ap_addr2" SIZE="103" MAXLENGTH="120"  value=""/></td>
	</tr>
	<tr class="InputMB"><!--2016/1/7增加地址長度120-->	
		<td class="lightbluetable" align="right">證照地址(英)：</td>
		<td class="whitetablebg" colspan="3">
            <input TYPE="hidden" NAME="ap_eaddr1_name" value="證照地址(英)1">
		    <input TYPE="hidden" NAME="ap_eaddr2_name" value="證照地址(英)2">
		    <input TYPE="hidden" NAME="ap_eaddr3_name" value="證照地址(英)3">
		    <input TYPE="hidden" NAME="ap_eaddr4_name" value="證照地址(英)4">
            <input TYPE="hidden" NAME="oap_eaddr1" id="oap_eaddr1">
            <input TYPE="hidden" NAME="oap_eaddr2" id="oap_eaddr2">
            <input TYPE="hidden" NAME="oap_eaddr3" id="oap_eaddr3">
            <input TYPE="hidden" NAME="oap_eaddr4" id="oap_eaddr4">
            <input type="text" name="ap_eaddr1" id="ap_eaddr1" size="103" maxlength="120" /><br />
            <input type="text" name="ap_eaddr2" id="ap_eaddr2" size="103" maxlength="120" /><br />
            <input type="text" name="ap_eaddr3" id="ap_eaddr3" size="103" maxlength="120" /><br />
            <input type="text" name="ap_eaddr4" id="ap_eaddr4" size="103" maxlength="120" />
		</td>
	</tr>
	<tr class="InputMB"><!--2016/1/7增加地址長度120-->
		<td class="lightbluetable" align="right">聯絡地址：</td>
		<td class="whitetablebg" colspan="3">
        郵遞區號
            <input TYPE="hidden" NAME="apatt_zip_name" value="聯絡地址郵遞區號">
		    <input TYPE="hidden" NAME="apatt_addr1_name" value="聯絡地址1">
		    <input TYPE="hidden" NAME="apatt_addr2_name" value="聯絡地址2">
            <input type="hidden" name="oapatt_zip" id="oapatt_zip">
            <input type="hidden" name="oapatt_addr1" id="oapatt_addr1">
            <input type="hidden" name="oapatt_addr2" id="oapatt_addr2"> 
		    <input TYPE="text" NAME="apatt_zip" id="apatt_zip" SIZE="8" MAXLENGTH="8" value="" class="InputNumOnly"/><br />
		    <input TYPE="text" NAME="apatt_addr1" id="apatt_addr1" SIZE="103" MAXLENGTH="120" value="">
		    <input TYPE="text" NAME="apatt_addr2" id="apatt_addr2" SIZE="103" MAXLENGTH="120" value="">
		    <input type="button" id="CopyAddr" value="同証照地址" class="cbutton" style="cursor:hand">
		</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right">電話：</td>
		<td class="whitetablebg">
            <input TYPE="hidden" NAME="apatt_tel0_name" value="電話區碼">
		    <input TYPE="hidden" NAME="apatt_tel_name" value="電話">
		    <input TYPE="hidden" NAME="apatt_tel1_name" value="電話分機">
            <input type="hidden" name="oapatt_tel0" id="oapatt_tel0">
            <input type="hidden" name="oapatt_tel" id="oapatt_tel">
            <input type="hidden" name="oapatt_tel1" id="oapatt_tel1">
		(<input TYPE="text" NAME="apatt_tel0" id="apatt_tel0" SIZE="4" MAXLENGTH="4" value="" class="InputNumOnly">)
		<input TYPE="text" NAME="apatt_tel" id="apatt_tel" SIZE="16" MAXLENGTH="15" value="" class="InputNumAndMarks" >
		<input TYPE="text" NAME="apatt_tel1" id="apatt_tel1" SIZE="5" MAXLENGTH="5"  value="" class="InputNumAndMarks" >
		</td>
		<td class="lightbluetable" align="right">傳真：</td>
		<td class="whitetablebg">
            <input TYPE="hidden" NAME="apatt_fax_name" value="傳真">
            <input type="hidden" name="oapatt_fax" id="oapatt_fax">
		    <input TYPE="text" NAME="apatt_fax" id="apatt_fax" SIZE="15" MAXLENGTH="15" value="" class="InputNumAndMarks">
		</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right">聯絡E-mail：</td>
		<td class="whitetablebg" colspan="3">
            <input TYPE="hidden" NAME="apatt_email_name" value="聯絡E-mail">
            <input type="hidden" name="oapatt_email" id="oapatt_email">
		    <input TYPE="text" NAME="apatt_email" id="apatt_email" SIZE="50" MAXLENGTH="50" value="">
		</td>
	</tr>
    
    <tr id="tr_1" ><td class="whitetablebg" colspan="4">權限 C</td></tr>
    <tr id="tr_2">
        <td class="lightbluetable" align="right">狀態代碼：</td>
		<td class="whitetablebg" colspan="3" ><input TYPE="text" NAME="ap_code" id="ap_code" SIZE="22" class="SEdit" readonly value=""></td>
    </tr>
	<tr id="tr_3">
		<td class="lightbluetable" align="right">建檔日期：</td>
		<td class="whitetablebg"><input TYPE="text" NAME="in_date" id="in_date" SIZE="27" class="SEdit" readonly ></td>
		<td class="lightbluetable" align="right">建檔人員：</td>
		<td class="whitetablebg"><input TYPE="text" NAME="ap_code" id="in_scode" class="SEdit" readonly ></td>
	</tr>
	<tr id="tr_4">
		<td class="lightbluetable" align="right">最近異動日期：</td>
		<td class="whitetablebg"><input TYPE="text" NAME="tran_date" id="tran_date" SIZE="27" class="SEdit" readonly value=""></td>
		<td class="lightbluetable" align="right">最近異動人員：</td>
		<td class="whitetablebg"><input TYPE="text" NAME="tran_scode" id="tran_scode" SIZE="22" class="SEdit" readonly value=""></td>
	</tr>
	<tr id="tr_5">
		<td class="lightbluetable" align="right">最近使用內專案號：</td>
		<td class="whitetablebg"><input TYPE="text" NAME="dmp_seq" id="dmp_seq" SIZE="22" class="SEdit" readonly value=""></td>
		<td class="lightbluetable" align="right">最近使用出專案號：</td>
		<td class="whitetablebg"><input TYPE="text" NAME="exp_seq" id="exp_seq" SIZE="22" class="SEdit" readonly value=""></td>
	</tr>
	<tr id="tr_6">
		<td class="lightbluetable" align="right">最近使用內商案號：</td>
		<td class="whitetablebg"><input TYPE="text" NAME="dmt_seq" id="dmt_seq" SIZE="22" class="SEdit" readonly value=""></td>
		<td class="lightbluetable" align="right">最近使用出商案號：</td>
		<td class="whitetablebg"><input TYPE="text" NAME="ext_seq" id="ext_seq" SIZE="22"  class="SEdit" readonly ></td>
	</tr>
	<tr id="tr_7">
		<td class="lightbluetable" align="right">備註：</td>
		<td class="whitetablebg" colspan=3><input TYPE="text" NAME="mark" id="mark" SIZE="22" class="SEdit" readonly ></td>
	</tr>
	<!--<tr>
		<td class="whitetablebg" colspan="4">
		※上傳的委任書上方空白處必須出現，例如：「正本存於申請案號第097201172號卷」的字樣。
		<br>※多個申請人合併簽署一份委任書時，請分別於各申請人資料庫上傳委任書檔案。
		<br>※「多個申請人（A+B）合併簽署」的委任書影本不能在各單一申請人（A或B）後續申請的案件中呈送。
		<br>※多個申請人（A+B）分別單獨在不同的委任書簽署時，請分別於A申請人資料庫上傳A簽署的委任書，於B申請人資料庫上傳B簽署的委任書。
		</td>
	</tr>-->
    
</table>




<script language="javascript" type="text/javascript">
    //****每個form都有自已的別名
    var cust13form = {};
    //畫面初始化
    cust13form.init = function () {

    }
    //資料綁定
    cust13form.bind = function (jData) {
        $("#apclass").val(jData.apclass);
        $("#txtapclass").val(jData.apclass + "-" + jData.apclassnm);
        //$("#hapclass").val(jData.apclass);
        $("#ap_country").val(jData.ap_country);
        $("#ap_cname1").val(jData.ap_cname1);
        $("#ap_cname2").val(jData.ap_cname2);
        $("#ap_fcname").val(jData.ap_fcname);
        $("#ap_lcname").val(jData.ap_lcname);
        $("#ap_ename1").val(jData.ap_ename1); $("#oap_ename1").val(jData.ap_ename1);
        $("#ap_ename2").val(jData.ap_ename2); $("#oap_ename2").val(jData.ap_ename2);
        $("#ap_fename").val(jData.ap_fename); $("#oap_fename").val(jData.ap_fename);
        $("#ap_lename").val(jData.ap_lename); $("#oap_lename").val(jData.ap_lename);
        $("#ap_crep").val(jData.ap_crep); $("#oap_crep").val(jData.ap_crep);
        $("#ap_erep").val(jData.ap_erep); $("#oap_erep").val(jData.ap_erep);
        $("#ap_title").val(jData.ap_title); $("#oap_title").val(jData.ap_title);

        $("#ap_zip").val(jData.ap_zip); $("#oap_zip").val(jData.ap_zip);
        $("#ap_addr1").val(jData.ap_addr1); $("#oap_addr1").val(jData.ap_addr1);
        $("#ap_addr2").val(jData.ap_addr2); $("#oap_addr2").val(jData.ap_addr2);
        $("#ap_eaddr1").val(jData.ap_eaddr1); $("#oap_eaddr1").val(jData.ap_eaddr1);
        $("#ap_eaddr2").val(jData.ap_eaddr2); $("#oap_eaddr2").val(jData.ap_eaddr2);
        $("#ap_eaddr3").val(jData.ap_eaddr3); $("#oap_eaddr3").val(jData.ap_eaddr3);
        $("#ap_eaddr4").val(jData.ap_eaddr4); $("#oap_eaddr4").val(jData.ap_eaddr4);
        $("#apatt_zip").val(jData.apatt_zip); $("#oapatt_zip").val(jData.apatt_zip);
        $("#apatt_addr1").val(jData.apatt_addr1); $("#oapatt_addr1").val(jData.apatt_addr1);
        $("#apatt_addr2").val(jData.apatt_addr2); $("#oapatt_addr2").val(jData.apatt_addr2);
        $("#apatt_tel0").val(jData.apatt_tel0); $("#oapatt_tel0").val(jData.apatt_tel0);
        $("#apatt_tel").val(jData.apatt_tel); $("#oapatt_tel").val(jData.apatt_tel);
        $("#apatt_tel1").val(jData.apatt_tel1); $("#oapatt_tel1").val(jData.apatt_tel1);
        $("#apatt_fax").val(jData.apatt_fax); $("#oapatt_fax").val(jData.apatt_fax);
        $("#apatt_email").val(jData.apatt_email); $("#oapatt_email").val(jData.apatt_email);
        //權限C
        $("#ap_code").val(jData.ap_code);
        //var d = new Date(jData.in_date).format("yyyy/MM/dd hh:mm:ss");
        //$("#in_date").val(d);
        $("#in_date").val(dateReviver(jData.in_date, "yyyy/M/d tt HH:mm:ss"));
        $("#in_scode").val(jData.in_scode + jData.scodename);
        $("#tran_date").val(dateReviver(jData.tran_date, "yyyy/M/d tt HH:mm:ss"));
        $("#tran_scode").val(jData.tran_scode + jData.scodename);
        $("#dmp_seq").val(jData.dmp_seq);
        $("#exp_seq").val(jData.exp_seq);
        $("#dmt_seq").val(jData.dmt_seq);
        $("#ext_seq").val(jData.ext_seq);
        $("#mark").val(jData.mark);
    }

    $("#CopyAddr").click(function (e) {
        $("#apatt_zip").val($("#ap_zip").val());
        $("#apatt_addr1").val($("#ap_addr1").val());
        $("#apatt_addr2").val($("#ap_addr2").val());
    });

    cust13form.ChkApclass = function () {
        if ($("#apclass").val() == "") {
            alert("申請人種類為必選!");
            $("#apclass").focus();
            return false;
        }
    }

    cust13form.chkSaveData = function () {

        if ($("#apclass").val() == "") {
            alert("申請人種類為必填!");
            $("#apclass").focus();
            return false;
        }

        if ($("#apclass").val() == "AA" || $("#apclass").val() == "CA") { }
        else
        {
            if ($("#apcust_no").val() == "") {
                alert("申請人編號為必填!");
                $("#apcust_no").focus();
                return false;
            }
        }

        if ($("#ap_cname1").val() == "") {
            alert("申請人名稱為必填!");
            $("#ap_cname1").focus();
            return false;
        }

    }

    cust13form.ChkApcust_no = function () {
        if ($("#apcust_no").val() == "") {
            return;
        }

        if ($("#apclass").val() != "") {

            switch ($("#apclass").val()) {
                case "AB":
                case "AC":
                case "AD":
                case "AE":
                    //if (fChkDataLen2($("#apcust_no")[0], 8, "申請人編號") == "") { $("#apcust_no").focus(); return false; }
                    if (chkID($("#apcust_no").val(), "TaxID") == true) { $("#apcust_no").focus(); return false; }
                    break;

                case "B":
                    if (chkID($("#apcust_no").val(), "ID") == true) { $("#apcust_no").focus(); return false; }
                    break;

                case "CB":
                    if (fChkDataLen2($("#apcust_no")[0], 10, "申請人編號") == "") { $("#apcust_no").focus(); return false; }
                    break;

                case "CT":
                    if (fChkDataLen2($("#apcust_no")[0], 6, "申請人編號") == "") {
                        $("#apcust_no").focus();
                        return false;
                    }
                    break;
                default:
                    break;
            }
        }
    }

    cust13form.ChkDataDouble = function () {

        if ($("#apcust_no").val() == "") {
            return;
        }
        if ($("#submitTask").val() != "A") {
            return;
        }

        //檢查編號重複
        var b = false;
        var SQLStr = "select * from apcust a where apcust_no = '" + $("#apcust_no").val() + "'";
        $.ajax({
            url: "../AJAX/JsonGetSqlData.aspx",
            type: "get",
            async: false,
            cache: false,
            data: { sql: SQLStr },
            success: function (json) {
                var JSONdata = $.parseJSON(json);
                if (JSONdata.length == 0) { }
                else {
                    alert("申請人編號重複，請重新輸入!");
                    b = true;
                    $("#apcust_no").focus();
                }
            },
            beforeSend: function (jqXHR, settings) {
                jqXHR.url = settings.url;
            },
            error: function (jqXHR, textStatus, errorThrown) {
                alert("\n資料擷取剖析錯誤 !\n" + jqXHR.url);
            }
        });
        if (b == true) { return false; }
    }


    //申請人名稱自動帶入
    cust13form.ap_cname1onblur = function () {
        if ($("#apclass").val() == "B" && NulltoEmpty($("#ap_cname1").val()) != "")
        {
            var strfcname = $("#ap_cname1").val();
            $("#ap_fcname").val(strfcname.substring(0, 1));
            $("#ap_lcname").val(strfcname.substring(1, 5));
        }
    }



    //****function使用別名才不會有同名function的問題
    //function apclass_onchange() {
    cust13form.apclassChange = function () {
        $("#apcust_no").show();
        if ($("#apclass").val() == "AA" || $("#apclass").val() == "CA") {
            $("#apcust_no").hide();
            $("#ap_cname1").focus();
        }
        if ($("#apclass").val() != "AA" || $("#apclass").val() != "CA") {
            $("#apcust_no").focus();
        }

        if ($("#apclass").val().substring(0, 1) == "B" || $("#apclass").val().substring(0, 1) == "C") {
            $("#ap_fcname").show();
            $("#ap_lcname").show();
            $("#ap_fename").show();
            $("#ap_lename").show();
        }
        else {
            $("#ap_fcname").hide();
            $("#ap_lcname").hide();
            $("#ap_fename").hide();
            $("#ap_lename").hide();
        }

        if ($("#apclass").val() == "B") {
            $("#ap_country").val("T");
        }
    }

    cust13form.chkCountry = function () {
        if ($("#ap_country").val() == "") {
            alert("申請人國籍為必選!");
            return false;
        }
        else {
            if (($("#apclass").val() == "AA" || $("#apclass").val() == "AB" || $("#apclass").val() == "AC"
                || $("#apclass").val() == "AD" || $("#apclass").val() == "AE" || $("#apclass").val() == "B")
                && $("#ap_country").val() != "T") {
                alert("本國公司行號及個人，不可為外國國籍!");
                $("#ap_country").val("T");
                $("#ap_country").focus();
                return false;
            }

            if (($("#apclass").val() == "CA" || $("#apclass").val() == "CB" || $("#apclass").val() == "CT") &&
                $("#ap_country").val() == "T") {
                alert("外國人或外國公司，不可選擇中華民國國籍!");
                $("#ap_country").val("");
                $("#ap_country").focus();
                return false;
            }
        }
    }


</script>

