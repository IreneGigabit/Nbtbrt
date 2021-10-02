<%@ Control Language="C#" ClassName="cust17Form" %>
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
    //種類
    protected string html_apclass = Sys.getCustCode("int_apclass", "", "sortfld").Option("{cust_code}", "{cust_code}_{code_name}");
    //國籍
    protected string html_country = Sys.getCountry().Option("{coun_code}", "{coun_code}_{coun_c}");
    
    private void Page_Load(System.Object sender, System.EventArgs e)
    {
    }
    
    
</script>
<style>
    .InputMB input{
         margin-bottom : 4px;
    }
</style>

<div align="center" id="noData" style="display:none">
	<font color="red">=== 目前無資料 ===</font>
</div>
<input type="hidden" name="cust_area" id="cust_area" value="<%=Sys.GetSession("seBranch")%>" />
<input type="hidden" name="Original_ant_id" id="Original_ant_id" value="" />
<table border="0" class="bluetable" cellspacing="1" cellpadding="2" width="85%" align="center">
		<tr id="tr_1">
			<td width="20%" class="lightbluetable" align="right">發明/創作人編號：</td><!--新增不顯示 -->
			<td class="whitetablebg" colspan="3">
				<input type="text" name="ant_no" id="ant_no" size="11"  class="SEdit" readonly>
				(區所別+流水號六碼)
			</td>			
		</tr>
		<tr>
			<td width="20%" class="lightbluetable" align="right">發明/創作人種類：</td>
			<td width="30%" class="whitetablebg">
				<select name="apclass" id="apclass" size="1" onchange="cust17form.apclassChange()"><%=html_apclass%> </select>				
			</td>
			<td width="20%" class="lightbluetable" align="right">同申請人編號：</td>
			<td width="30%" class="whitetablebg">
				<input type="checkbox" name="same_ap" id="same_ap" value="Y" onclick="cust17form.same_ap_Click()" >
				<input type="text" name="apcust_no" id="apcust_no" size="12" maxlength="10" value="" >
				<input type="button" name="btn_apcust" class="cbutton" value="確定" onclick="cust17form.GetapcustData('SetDetail', 'apcust_no', 'Y')" > 
                <input type="button" name="btnquery_apcust_no" id="btnquery_apcust_no" class="cbutton" value="查詢" onclick="cust17form.QueryApcust()">
				<input type="hidden" name="bapcustno" id="bapcustno" value="N" ><!--是否按下「確定」-->
			</td>
		</tr>		
		<tr>
			<td class="lightbluetable" align="right">發明/創作人ID：</td>
			<td class="whitetablebg">
				<input type="text" name="ant_id" id="ant_id" size="12" maxlength="10" onblur="cust17form.Chkant_id()">
			</td>
			<td class="lightbluetable" align="right">發明人國籍：</td>
			<td class="whitetablebg">
				<select name="ant_country" id="ant_country" size="1" onchange="cust17form.ap_countryChange()"><%=html_country%></select>			
			</td>
		</tr>
			<td class="lightbluetable" align="right">相關客戶編號：</td>
			<td class="whitetablebg" colspan="3">
				<%=Sys.GetSession("seBranch")%> －  
				<input type="text" name="cust_seq" id="cust_seq" size="7" maxlength="6" class="InputNumOnly" >
				<input type="button" name="btn_getcust_seqName" id="btn_getcust_seqName" class="cbutton" value="確定" onclick="cust17form.GetapcustData('SetName', 'cust_seq', 'Y')" >
				<input type="button" name="btnquery_cust_seq" id="btnquery_cust_seq" class="cbutton" value="查詢" onclick="cust17form.QueryCust_seq()" >
				<input type="button" name="btn_cust_seqDetail" id="btn_cust_seqDetail" class="cbutton" value="詳細" onclick="cust17form.GetapcustData('', 'cust_seq', 'Y')">
				<span id="span_cust_name"></span>
			</td>
		</tr>		
		<tr>
			<td class="lightbluetable" align="right">發明人名稱(中)：</td>
			<td class="whitetablebg" colspan="3">
				<input type="text" name="ant_cname1" id="ant_cname1" size="33" maxlength="60" onblur="cust17form.ant_cname1onblur()" > 
                <input type="text" name="ant_cname2" id="ant_cname2" size="33" maxlength="60"> 
			</td>
		</tr>
		<tr>
			<td class="lightbluetable" align="right">發明人名稱(中)：</td>
			<td class="whitetablebg" colspan="3">
				姓：<input type="text" name="ant_fcname" id="ant_fcname" size="33" maxlength="60" >
				名：<input type="text" name="ant_lcname" id="ant_lcname" size="33" maxlength="60" >
			</td>
		</tr>
		<tr>
			<td class="lightbluetable" align="right">發明人名稱(英)：</td>
			<td class="whitetablebg" colspan="3">
				<input type="text" name="ant_ename1" id="ant_ename1" size="66" maxlength="60" >
				<input type="text" name="ant_ename2" id="ant_ename2" size="66" maxlength="60" >
			</td>
		</tr>
		<tr>
			<td class="lightbluetable" align="right">發明人名稱(英)：</td>
			<td class="whitetablebg" colspan="3">
				姓：<input type="text" name="ant_fename" id="ant_fename" size="33" maxlength="60" >
				名：<input type="text" name="ant_lename" id="ant_lename" size="33" maxlength="60" >
			</td>
		</tr>
		<tr class="InputMB">
			<td class="lightbluetable" align="right">中文地址：</td>
			<td class="whitetablebg" colspan="3">
				郵遞區號<input type="text" name="ant_zip" id="ant_zip" size="8" maxlength="8" class="InputNumOnly" ><br />
				<input type="text" name="ant_addr1" id="ant_addr1" size="66" maxlength="60" ><br>
				<input type="text" name="ant_addr2" id="ant_addr2" size="66" maxlength="60" >
			</td>
		</tr>
		<tr class="InputMB">
			<td class="lightbluetable" align="right">英文地址：</td>
			<td class="whitetablebg" colspan="3">
				<input type="text" name="ant_eaddr1" id="ant_eaddr1" size="66" maxlength="60" ><br>
				<input type="text" name="ant_eaddr2" id="ant_eaddr2" size="66" maxlength="60" ><br>
				<input type="text" name="ant_eaddr3" id="ant_eaddr3" size="66" maxlength="60" ><br>
				<input type="text" name="ant_eaddr4" id="ant_eaddr4" size="66" maxlength="60" >				
			</td>
		</tr>
		<tr>
			<td class="lightbluetable" align="right">電話：</td>
			<td class="whitetablebg" colspan="3">
				(<input TYPE="text" NAME="ant_tel0" id="ant_tel0" SIZE="4" MAXLENGTH="4" class="InputNumOnly" >)
				<input TYPE="text" NAME="ant_tel" id="ant_tel" SIZE="16" MAXLENGTH="16" class="InputNumAndMarks" >
				<input TYPE="text" NAME="ant_tel1" id="ant_tel1" SIZE="10" MAXLENGTH="10" class="InputNumAndMarks">			
			</td>
		</tr>											
		<tr>
			<td class="lightbluetable" align="right">E-mail：</td>
			<td class="whitetablebg" colspan="3">
				<input TYPE="text" NAME="ant_email" id="ant_email" SIZE="50" MAXLENGTH="100" >
			</td>
		</tr>
		<tr id="tr_2">
			<td class="lightbluetable" align="right">建檔人員：</td>
			<td class="whitetablebg">
				<input type="text" name="in_scode" id="in_scode" size="5" maxlength="5"  class="SEdit" readonly>
			</td>
			<td class="lightbluetable" align="right">建檔日期：</td>
			<td class="whitetablebg">
				<input type="text" name="in_date" id="in_date" size="30" maxlength="30"  class="SEdit" readonly>
			</td>
		</tr>		
		<tr id="tr_3">
			<td class="lightbluetable" align="right">最近異動人員：</td>
			<td class="whitetablebg">
				<input type="text" name="tran_scode" id="tran_scode" size="5" maxlength="5"  class="SEdit" readonly>
			</td>
			<td class="lightbluetable" align="right">最近異動日期：</td>
			<td class="whitetablebg">
				<input type="text" name="tran_date" id="tran_date" size="30" maxlength="30"  class="SEdit" readonly>
			</td>
		</tr>
		<!--
		<tr>
			<td colspan=4 class="lightbluetable3" align="left" style="color:blue">
			※發明/創作人編號旁「檢查」表:檢查申請人資料中有無此ID
			<br>※發明人名稱(中)旁「檢查」表:檢查申請人資料中有無此中文名稱
			<br>※發明人名稱(英)旁「檢查」表:檢查申請人資料中有無此英文名稱
			</td>
		</tr>
		-->
	</table>


<script language="javascript" type="text/javascript">
    //****每個form都有自已的別名
    var cust17form = {};
    //畫面初始化
    cust17form.init = function () {

    }
    //資料綁定
    cust17form.bind = function (jData) {
        $.each(jData, function (i, item) {
            //$("#antsqlno" ).val(item.antsqlno);
            $("#ant_no").val(item.ant_no);
            $("#ant_id").val(item.ant_id);
            $("#cust_seq").val(item.cust_seq);
            $("#span_cust_name").text(item.ap_cname1);
            $("#ant_country").val(item.ant_country);
            $("#ant_cname1").val(item.ant_cname1);
            $("#ant_cname2").val(item.ant_cname2);
            $("#ant_fcname").val(item.ant_fcname);
            $("#ant_lcname").val(item.ant_lcname);
            $("#ant_ename1").val(item.ant_ename1);
            $("#ant_ename2").val(item.ant_ename2);
            $("#ant_fename").val(item.ant_fename);
            $("#ant_lename").val(item.ant_lename);
            $("#ant_tel0").val(item.ant_tel0);
            $("#ant_tel").val(item.ant_tel);
            $("#ant_tel1").val(item.ant_tel1);
            $("#ant_zip").val(item.ant_zip);
            $("#ant_addr1").val(item.ant_addr1);
            $("#ant_addr2").val(item.ant_addr2);
            $("#ant_eaddr1").val(item.ant_eaddr1);
            $("#ant_eaddr2").val(item.ant_eaddr2);
            $("#ant_eaddr3").val(item.ant_eaddr3);
            $("#ant_eaddr4").val(item.ant_eaddr4);
            $("#apclass").val(item.apclass);

            if (item.same_ap == "Y") {
                $("#same_ap").prop("checked", true);
            }

            $("#apcust_no").val(item.apcust_no);
            $("#in_date").val(dateReviver(item.in_date, "yyyy/M/d tt HH:mm:ss"));
            $("#in_scode").val(item.in_scode);
            $("#tran_date").val(dateReviver(item.tran_date, "yyyy/M/d tt HH:mm:ss"));
            $("#tran_scode").val(item.tran_scode);
            $("#ant_email").val(item.ant_email);
            $("#Original_ant_id").val(item.ant_id);
        })
    }


    cust17form.addReadOnly = function (antid, antcname) {
        $("#ant_id").val(antid);
        $("#ant_cname1").val(antcname);
        $("#apclass").val("B");
        $("#ant_country").val("T");
        $("#tr_1").hide();
        $("#tr_2").hide();
        $("#tr_3").hide();
    }


    cust17form.LockAll = function () {
        $(":text, :checkbox, select").lock();
        $("input[type=button]").hide();
    }
   

    cust17form.GetapcustData = function (typeName, idName, SetData) {
        $("#span_cust_name").text('');
        var SQLStr = "select * from apcust where apsqlno <> ''";
        if (idName == "cust_seq") {
            if ($.trim($("#cust_seq").val()) == "" || $.trim($("#cust_seq").val()) == "0") {
                return;
            }
            SQLStr += " AND cust_seq is not null and cust_seq <> 0";
            SQLStr += " AND cust_seq = '" + $.trim($("#cust_seq").val()) + "'";
        }
        else {
            if ($.trim($("#apcust_no").val()) == "") {
                return;
            }
            SQLStr += " AND apcust_no = '" + $.trim($("#apcust_no").val()) + "'";
        }

        $.ajax({
            url: "../AJAX/JsonGetSqlData.aspx",
            type: "get",
            async: false,
            cache: false,
            data: { sql: SQLStr },
            success: function (json) {
                var JSONdata = $.parseJSON(json);
                if (JSONdata.length != 0) {
                    if (SetData == "Y")//Y要放資料，N則只檢查sql，Check編號是否存在
                    {
                        if (typeName == "SetName") {
                            $("#span_cust_name").text(JSONdata[0]["ap_cname1"]);
                        }
                        else {
                            if (typeName == "SetDetail") {
                                $("#ant_country").val(JSONdata[0]["ap_country"]);
                                if ($("#ant_country").val() == "T") {
                                    $("#apclass").val("B");
                                }
                                $("#ant_id").val(JSONdata[0]["apcust_no"]);
                                $("#ant_id").prop('readonly', true);
                                $("#ant_cname1").val(JSONdata[0]["ap_cname1"]);
                                $("#ant_cname2").val(JSONdata[0]["ap_cname2"]);
                                $("#ant_fcname").val(JSONdata[0]["ap_fcname"]);
                                $("#ant_lcname").val(JSONdata[0]["ap_lcname"]);
                                $("#ant_ename1").val(JSONdata[0]["ap_ename1"]);
                                $("#ant_ename2").val(JSONdata[0]["ap_ename2"]);
                                $("#ant_fename").val(JSONdata[0]["ap_fename"]);
                                $("#ant_lename").val(JSONdata[0]["ap_lename"]);
                                $("#ant_zip").val(JSONdata[0]["ap_zip"]);
                                $("#ant_addr1").val(JSONdata[0]["ap_addr1"]);
                                $("#ant_addr2").val(JSONdata[0]["ap_addr2"]);
                                $("#ant_eaddr1").val(JSONdata[0]["ap_eaddr1"]);
                                $("#ant_eaddr2").val(JSONdata[0]["ap_eaddr2"]);
                                $("#ant_eaddr3").val(JSONdata[0]["ap_eaddr3"]);
                                $("#ant_eaddr4").val(JSONdata[0]["ap_eaddr4"]);
                                $("#ant_tel0").val(JSONdata[0]["apatt_tel0"]);
                                $("#ant_tel").val(JSONdata[0]["apatt_tel"]);
                                $("#ant_tel1").val(JSONdata[0]["apatt_tel1"]);
                                $("#ant_email").val(JSONdata[0]["apatt_email"]);
                                $("#same_ap").prop("checked", true);
                                $("#bapcustno").val("Y");
                            }
                            else {
                                var url = "cust11_Edit.aspx?prgid=cust11_2&submitTask=Q&cust_area=<%=Sys.GetSession("seBranch")%>&cust_seq=" + $("#cust_seq").val();
                                window.open(url, "_blank");
                            }
                        }
                    }
                }
                else {
                    if (idName == "cust_seq") {
                        alert("此客戶編號不存在!");
                        $("#cust_seq").focus();
                        return;
                    }
                    else {
                        alert("申請人編號不存在!");
                        $("#ant_id").val("");
                        $("#apcust_no").val("");
                        $("#apcust_no").focus();
                        return;
                    }
                }
            },
            beforeSend: function (jqXHR, settings) {
                jqXHR.url = settings.url;
            },
            error: function (jqXHR, textStatus, errorThrown) {
                alert("\n資料擷取剖析錯誤 !\n" + jqXHR.url);
            }
        });
    }

    //名稱自動帶入
    cust17form.ant_cname1onblur = function () {
        if ($("#apclass").val() == "B" && NulltoEmpty($("#ant_cname1").val()) != "") {
            var strfcname = $("#ant_cname1").val();
            $("#ant_fcname").val(strfcname.substring(0, 1));
            $("#ant_lcname").val(strfcname.substring(1, 5));
        }
    }


    cust17form.chkapcust_no = function () {
        if ($("#same_ap").prop("checked") == true)
        {
            if ($.trim($("#apcust_no").val()) == "") {
                alert("若同申請人編號，申請人編號必需輸入!");
                $("#apcust_no").focus();
                return false;
            }

            //Y表示經過資料驗證有該apcust_no
            if ($("#bapcustno").val() != "Y") {
                alert("輸入申請人編號後，請按「確定」按鈕，以帶入申請人資料!");
                return false;
            }
        }
    }


    cust17form.Chkant_id = function () {
        if ($("#ant_id").val() == "") {
            return;
        }
        if ($("#apclass").val() != "" && $("#bapcustno").val() != "Y") {
            switch ($("#apclass").val())
            {
                case "B":
                    if (fChkDataLen2($("#ant_id")[0], 10, "發明/創作人ID") == "") { $("#ant_id").focus(); return false; }
                    if (chkID($("#ant_id").val(), "ID") == true) { $("#ant_id").focus(); return false; }
                    break;

                case "CB":
                    if (fChkDataLen2($("#ant_id")[0], 10, "發明/創作人ID") == "") { $("#ant_id").focus(); return false; }
                    break;

                case "CT":
                    if (fChkDataLen2($("#ant_id")[0], 6, "發明/創作人ID") == "") { $("#ant_id").focus(); return false; }
                    break;
                default:
                    break;
            }
        }
    }

    cust17form.chkSaveData = function () {

        if ($("#ant_cname1").val() == "") {
            alert("發明人名稱(中)為必填!");
            $("#ant_cname1").focus();
            return false;
        }
        if ($("#apclass").val() == "") {
            alert("發明/創作人種類為必填!");
            $("#apclass").focus();
            return false;
        }
        if ($("#ant_country").val() == "") {
            alert("發明人國籍為必填!");
            $("#ant_country").focus();
            return false;
        }
       
        if (($("#apclass").val() == "B" || $("#apclass").val() == "CB" || $("#apclass").val() == "CT") && $("#ant_id").val() == "")
        {
            alert("發明/創作人ID為必填!");
            $("#ant_id").focus();
            return false;
        }
    }

    cust17form.apclassChange = function () {
        if ($("#apclass").val() == "B" || $("#apclass").val() == "BA") {
            $("#ant_country").val("T");
        }
        if (($("#apclass").val() != "B" && $("#apclass").val() != "BA")  && $("#ant_country").val() == "T") {
            $("#ant_country").val('');
        }
    }

    cust17form.QueryCust_seq = function () {
        var url = "apcust.aspx?prgid=cust171&tablename=cust_seq";
        window.open(url, "_blank");
    }

    cust17form.QueryApcust = function () {
        var url = "apcust.aspx?prgid=cust171&tablename=apcust";
        window.open(url, "_blank");
    }

    cust17form.same_ap_Click = function () {
        if ($("#same_ap").prop("checked") == true) {
            $("#ant_id").val($("#ant_id").val().toUpperCase());
            $("#ant_id").prop("readonly", true);
        }
        else {
            $("#apcust_no").val('');
            $("#ant_id").prop("readonly", false);
            $("#bapcustno").val('');
        }
    }

    cust17form.Chkant_idDouble = function (submitTask, ant_id) {
        var s = true;
        var SQLStr = "select * from inventor where ant_id = '" + ant_id + "'";
        if (submitTask != "A") {
            SQLStr += " and ant_id <> '" + $("#Original_ant_id").val() + "'";
        }
        
        $.ajax({
            url: "../AJAX/JsonGetSqlData.aspx",
            type: "get",
            async: false,
            cache: false,
            data: { sql: SQLStr },
            success: function (json) {
                var JSONdata = $.parseJSON(json);
                if (JSONdata.length > 0) {
                    alert("發明/創作人ID已存在!");
                    s = false;
                }
            },
            beforeSend: function (jqXHR, settings) {
                jqXHR.url = settings.url;
            },
            error: function (jqXHR, textStatus, errorThrown) {
                alert("\n資料擷取剖析錯誤 !\n" + jqXHR.url);
            }
        });
        return s;
    }

    cust17form.ap_countryChange = function () {
        if ($("#ant_country").val() == "T") {
            $("#apclass").val("B");
        }
        else {
            if ($("#ant_country").val() != "T" && $("#apclass").val() == "B") {
                $("#apclass").val("");
            }
        }
    }



</script>