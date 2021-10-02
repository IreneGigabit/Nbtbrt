<%@ Control Language="C#" ClassName="cust12Form" %>
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
    private void Page_Load(System.Object sender, System.EventArgs e)
    {
    }
    
    
</script>
<div align="center" id="noData" style="display:none">
	<font color="red">=== 目前無資料 ===</font>
</div>
<input type="hidden" id="hatt_sql" name="hatt_sql" value=""><!--位於第幾位-->
<table id="tbl_att" border="0" class="bluetable" cellspacing="1" cellpadding="2" style="font-size: 9pt" width="100%" align=center>
    <tbody></tbody>
    <script type="text/html" id="att_template"><!--聯絡人樣板-->
	    <tr>
		    <td class="lightbluetable" align="right" nowrap>聯絡序號：</td>
		    <td class="whitetablebg">
                <input TYPE="text" NAME="att_sql_##" id="att_sql_##" SIZE="5" MAXLENGTH="5" readonly class="sedit" value="">
                <input TYPE="button" NAME="btnattedit_##" id="btnattedit_##" class="cbutton" hidden="hidden" value="修改">
		    </td>
		    <td class="lightbluetable" align="right">※聯絡人：</td>
		    <td class="whitetablebg">
			    <input type="hidden" name="old_attention" value="">
			    <input TYPE="hidden" NAME="attention_name" value="聯絡人">
			    <input type="hidden" name="oattention">
			    <input TYPE="text" NAME="attention_##" id ="attention_##" SIZE="40" MAXLENGTH="60" value="">
		    </td>
	    </tr>
	    <tr>
		    <td class="lightbluetable" align="right">職稱：</td>
		    <td class="whitetablebg">
                <input type="hidden" name="oatt_title" value="">
			    <input TYPE="hidden" NAME="att_title_name" value="聯絡人職稱">
			    <input TYPE="text" NAME="att_title_##" id="att_title_##" SIZE="40" MAXLENGTH="40"  value="">
		    </td>
		    <td class="lightbluetable" align="right" nowrap>聯絡部門：</td>
		    <td class="whitetablebg">
			    <input TYPE="hidden" NAME="att_dept_name" value="聯絡部門">
			    <input type="hidden" name="oatt_dept" value="">
			    <input TYPE="text" NAME="att_dept_##" id="att_dept_##" SIZE="40" MAXLENGTH="40"  value="">
		    </td>
	    </tr>
	    <tr>
		    <td class="lightbluetable" align="right">聯絡公司：</td>
		    <td class="whitetablebg">
			    <input TYPE="hidden" NAME="att_company_name" value="聯絡公司">
			    <input type="hidden" name="oatt_company" value="">
			    <input TYPE="text" NAME="att_company_##" id="att_company_##" SIZE="40" MAXLENGTH="60" value="">
		    </td>
		    <td class="lightbluetable" align="right">聯絡電話：</td>
		    <td class="whitetablebg">
			    <input TYPE="hidden" NAME="att_tel0_name" value="聯絡電話區碼">
			    <input TYPE="hidden" NAME="att_tel_name" value="聯絡電話">
			    <input TYPE="hidden" NAME="att_tel1_name" value="聯絡電話分機">
                <input type="hidden" name="oatt_tel0" />
                <input type="hidden" name="oatt_tel" />
                <input type="hidden" name="oatt_tel1" />
			    (<input TYPE="text" NAME="att_tel0_##" id="att_tel0_##" SIZE="4" MAXLENGTH="4" onkeyup="value=value.replace(/[^\d\*\-\#\.]/g,'')">)
			    <input TYPE="text" NAME="att_tel_##" id="att_tel_##" SIZE="16" MAXLENGTH="16" onkeyup="value=value.replace(/[^\d\*\-\#\.]/g,'')">-
			    <input TYPE="text" NAME="att_tel1_##" id="att_tel1_##" SIZE="10" MAXLENGTH="10" onkeyup="value=value.replace(/[^\d\*\-\#\.]/g,'')">
		    </td>
	    </tr>
	    <tr>
		    <td class="lightbluetable" align="right">行動電話：</td>
		    <td class="whitetablebg">
			    <input TYPE="hidden" NAME="att_mobile_name" value="行動電話">
			    <input type="hidden" name="oatt_mobile" value="">
			    <input TYPE="text" NAME="att_mobile_##" id="att_mobile_##" SIZE="33" MAXLENGTH="30" value="" onkeyup="value=value.replace(/[^\d\*\-\#\.]/g,'')">
		    </td>
		    <td class="lightbluetable" align="right">傳真號碼：</td>
		    <td class="whitetablebg">
			    <input TYPE="hidden" NAME="att_fax_name" value="傳真號碼">
			    <input type="hidden" name="oatt_fax" value="">
			    <input TYPE="text" NAME="att_fax_##" id="att_fax_##" SIZE="20" MAXLENGTH="20" value="" onkeyup="value=value.replace(/[^\d\*\-\#\.]/g,'')">
		    </td>
	    </tr>
	    <tr>
		    <td class="lightbluetable" align="right" nowrap>※聯絡地址：</td>
		    <td class="whitetablebg" colspan="3">
			    <input TYPE="hidden" NAME="att_zip_name" value="聯絡地址郵遞區號">
			    <input TYPE="hidden" NAME="att_addr1_name" value="聯絡地址1">
			    <input TYPE="hidden" NAME="att_addr2_name" value="聯絡地址2">
                <input type="hidden" name="oatt_zip" />
                <input type="hidden" name="oatt_addr1" />
                <input type="hidden" name="oatt_addr2" />
			    郵遞區號<input TYPE="text" NAME="att_zip_##" id="att_zip_##" SIZE="8" MAXLENGTH="8" value="" onkeyup="value=value.replace(/[^\d]/g,'') ">
			    <input TYPE="text" NAME="att_addr1_##" id="att_addr1_##" SIZE="33" MAXLENGTH="30" value="">
			    <input TYPE="text" NAME="att_addr2_##" id="att_addr2_##" SIZE="33" MAXLENGTH="30" value="">
			    <input type="button" name=btnaddr id="btnaddr_##" value="同証照地址" class="cbutton" onclick="cust12form.btncopyaddr('##')">
		    </td>
	    </tr>
	    <tr>
		    <td class="lightbluetable" align="right">電子郵件：</td>
		    <td class="whitetablebg">
			    <input TYPE="hidden" NAME="att_email_name" value="電子郵件">
			    <input type="hidden" name="oatt_email" value="">
			    <input TYPE="text" NAME="att_email_##" id="att_email_##" SIZE="44" MAXLENGTH="100" value="">
			    <input type="button" name=btnemail id="btnemail_##" value="同公司電子郵件" class="cbutton" onclick="cust12form.btncopyemail('##')" >
		    </td>
		    <td class="lightbluetable" align="right">狀態：</td>
		    <td class="whitetablebg">
		        <input TYPE="hidden" NAME="att_code_name" value="狀態">
                <input type="hidden" name="oatt_code" />
		        <input TYPE="radio" NAME="att_code_##" value="Z" >離職
		        <input TYPE="radio" NAME="att_code_##" value="T" >職務移轉
		        <input TYPE="radio" NAME="att_code_##" checked value="NN" >正常
		    </td>
	    </tr>
	    <tr>
		    <td class="lightbluetable" align="right">郵寄雜誌：</td>
		    <td class="whitetablebg">
			    <input TYPE="hidden" NAME="att_mag_name" value="郵寄雜誌">
                <input type="hidden" name="oatt_mag" />
			    <input TYPE="radio" NAME="att_mag_##" checked value="Y">需要
			    <input TYPE="radio" NAME="att_mag_##" value="N" >不需要</td>
		    <td class="lightbluetable" align="right">部門：</td>
		    <td class="whitetablebg">
			    <input TYPE="hidden" NAME="dept_name" value="部門">
			    <input type="hidden" name="odept" />
			    <select NAME="dept_##" id="dept_##" size="1"  >
	  			    <option value="">請選擇</option>
	  			    <option value="T">商標</option>
	  			    <option value="P">專利</option>
			    </select></td>
	    </tr>
        <tr></tr>
        <tr></tr>
    </script>
</table>


<script language="javascript" type="text/javascript">
    //****每個form都有自已的別名
    var cust12form = {};
    //畫面初始化
    cust12form.init = function () {

    }
    //資料綁定
    cust12form.bind = function (jData) {
        $("#hatt_sql").val("0");
        $.each(jData, function (i, item) {
            cust12form.addAtt();//新增一筆
            var nRow = $("#hatt_sql").val();

            $("#att_sql_" + nRow).val(item.att_sql);
            $("#attention_" + nRow).val(item.attention); $("input[name=oattention]").val(item.attention);
            $("#att_title_" + nRow).val(item.att_title); $("input[name=oatt_title]").val(item.att_title);
            $("#att_dept_" + nRow).val(item.att_dept); $("input[name=oatt_dept]").val(item.att_dept);
            $("#dept_" + nRow).val(item.dept); $("input[name=odept]").val(item.dept);
            $("#att_company_" + nRow).val(item.att_company); $("input[name=oatt_company]").val(item.att_company);
            $("#att_tel0_" + nRow).val(item.att_tel0); $("input[name=oatt_tel0]").val(item.att_tel0);
            $("#att_tel_" + nRow).val(item.att_tel); $("input[name=oatt_tel]").val(item.att_tel);
            $("#att_tel1_" + nRow).val(item.att_tel1); $("input[name=oatt_tel1]").val(item.att_tel1);
            $("#att_mobile_" + nRow).val(item.att_mobile); $("input[name=oatt_mobile]").val(item.att_mobile);
            $("#att_fax_" + nRow).val(item.att_fax); $("input[name=oatt_fax]").val(item.att_fax);
            $("#att_zip_" + nRow).val(item.att_zip); $("input[name=oatt_zip]").val(item.att_zip);
            $("#att_addr1_" + nRow).val(item.att_addr1); $("input[name=oatt_addr1]").val(item.att_addr1);
            $("#att_addr2_" + nRow).val(item.att_addr2); $("input[name=oatt_addr2]").val(item.att_addr2);
            $("#att_email_" + nRow).val(item.att_email); $("input[name=oatt_email]").val(item.att_email);

            //狀態
            $("input[name=att_code_"+nRow+"]").each(function () {
                var way = $(this).val();
                var ischeck = item.att_code.indexOf(way);
                if (ischeck >= 0) {
                    //$(this).checked = true;
                    $(this).prop('checked', true);
                    $("input[name=oatt_code]").val(item.att_code);
                }
                if (item.att_code == "NU" & way == "NN") {
                    $(this).prop('checked', true);
                    $("input[name=oatt_code]").val(item.att_code);
                }
            });
            
            //郵寄
            $("input[name=att_mag_"+nRow+"]").each(function () {
                var way = $(this).val();
                var ischeck = item.att_mag.indexOf(way);
                if (ischeck >= 0) {
                    //$(this).checked = true;
                    $(this).prop('checked', true);
                    $("input[name=oatt_mag]").val(item.att_mag);
                }
            });
        })
    }


    //[增加一筆]
    cust12form.addAtt = function () {
        var nRow = CInt($("#hatt_sql").val()) + 1;//畫面顯示NO
        //複製樣板
        var copyStr = $("#att_template").text() || "";
        copyStr = copyStr.replace(/##/g, nRow);
        $("#tbl_att>tbody").append(copyStr);
        $("#hatt_sql").val(nRow);

        //$("#btnaddr_"+nRow).on("click", function (e) {
        //    $("#att_zip_1").val($("#ap_zip").val());
        //    $("#att_zip_1").val("this is zip");
        //    $("#att_addr1_1").val($("#ap_addr1").val());
        //    $("#att_addr2_1").val($("#ap_addr2").val());
        //})

    }

    cust12form.btncopyaddr = function (nRow) {
        $("#att_zip_" + nRow).val($("#ap_zip").val());
        $("#att_addr1_" + nRow).val($("#ap_addr1").val());
        $("#att_addr2_" + nRow).val($("#ap_addr2").val());
    }

    cust12form.btncopyemail = function (nRow) {
        $("#att_email_" + nRow).val($("#email").val());
    }

    cust12form.hideCopyBtn = function () {
        $("#btnaddr_1").hide();
        $("#btnemail_1").hide();
    }

    cust12form.addReadOnly = function (submitTask, dept) {
        if (submitTask == "A") {
            $("input[name='att_code_1']").lock();
            if (dept == "P") {
                $("#dept_1").val("P").lock();
            }
            else {
                $("#dept_1").val("T").lock();
            }
        }
    }

    cust12form.SetReadyOnly = function () {//cust12Edit-Only Query用
        $("input, select").lock();
    }
    //$(“input[id^=’code’]”);//id屬性以code開始的所有input標籤
    cust12form.LockAll = function () {//cust11Edit用
        $(document.getElementById('#custz_att').getElementsByTagName('input')).each(function () {
            if ($(this).attr('type') == "button") {
                $(this).hide();
            }
            else {
                $(this).lock();
            }
        })
        $(document.getElementById('#custz_att').getElementsByTagName('select')).each(function () {
            $(this).lock();
        })
    }

    cust12form.GoToEditAtt = function (cust_seq, att_sql) {
        var url = "cust12_Edit.aspx?prgid=cust12_1&submitTask=U&cust_seq=" + cust_seq + "&att_sql=" + att_sql;
        window.parent.Eblank.location.href = url;
    }


</script>