﻿<%@ Control Language="C#" ClassName="FOBForm" %>
<%@ Import Namespace = "System.Collections.Generic"%>

<script runat="server">
    //ZZ交辦內容
    //父控制項傳入的參數
    public Dictionary<string, string> Lock = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    
    protected string prgid = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string SQL = "";

    protected string tfg2_agt_no1 = "";
    
    private void Page_Load(System.Object sender, System.EventArgs e) {
        PageLayout();   
        this.DataBind();
    }
    
    private void PageLayout() {
        //代理人
        tfg2_agt_no1 = Sys.getAgent().Option("{agt_no}", "{agt_no}_{agt_namefull}", " v1='{agt_name1}' {selected}", true);
    }
</script>

<%=Sys.GetAscxPath(this)%>
<TABLE border=0 class=bluetable cellspacing=1 cellpadding=2 width="100%">
	<tr>
		<td class="lightbluetable" valign="top" ><strong>參、代理人</strong></td>
		<td class="whitetablebg" colspan="7" >
		    <select id="tfg2_agt_no1" NAME="tfg2_agt_no1"><%#tfg2_agt_no1%></select>
		</td>
	</tr>
	<tr>
		<td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:pointer;COLOR:BLUE" ONCLICK="PMARK(foBAppl_name)">
            <strong>壹、<u>號數（前商標局核准註冊【係於大陸註冊之商標】，請於號數前加註「前商標局」字樣）</u></strong>
		</td>
	</tr>
	<tr>
		<td class=lightbluetable align=right >程序種類：</td>
		<td class=whitetablebg colspan="7">
			<input type=radio name=fr_mark value="A" onclick="br_form.change_no('A')">申請
			<input type=radio name=fr_mark value="I" onclick="br_form.change_no('I')">註冊
			<input type=radio name=fr_mark value="R" onclick="br_form.change_no('R')">核駁
		</TD>
	</tr>
	<tr>
		<td class=lightbluetable align=right ><span id=span_no></span>號數：</td>
		<td class=whitetablebg colspan="3"><input type="text" id="no" name="no" value="" size="20" maxlength="20"></TD>
		<td class=lightbluetable align=right >商標名稱：</td>
		<td class=whitetablebg colspan="3"><input type="text" id="fr_Appl_name" name="fr_Appl_name" value="" size="50" maxlength="100" onchange="reg.tfzd_Appl_name.value=this.value">
		    <input type="hidden" value="" id=fr_issue_no name=fr_issue_no>
		</TD>
	</tr>
	<tr>
		<td class=lightbluetable align=right >商標種類：</td>
		<td class=whitetablebg colspan="7">
			<input type=radio name=fr_S_Mark value="" onclick="dmt_form.change_mark(1, this)">商標
			<input type=radio name=fr_S_Mark value="S" onclick="dmt_form.change_mark(1, this)">92年修正前服務標章
			<input type=radio name=fr_S_Mark value="N" onclick="dmt_form.change_mark(1, this)">團體商標
			<input type=radio name=fr_S_Mark value="M" onclick="dmt_form.change_mark(1, this)">團體標章
			<input type=radio name=fr_S_Mark value="L" onclick="dmt_form.change_mark(1, this)">證明標章
		</TD>
	</tr>
	<tr>
		<td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:pointer;COLOR:BLUE" ONCLICK="PMARK(foBattech)">
            <strong>肆、<u>影印內容</u></strong><input TYPE="hidden" NAME="tfg1_other_item" id="tfg1_other_item">
        </td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input type="checkbox" id="ttz1_P1" name="ttz1_P1" value="P1" onclick="br_form.CopyStr('input[name^=ttz1_]',reg.tfg1_other_item)"></td>
		<td class="whitetablebg" colspan="7">註冊簿</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input type="checkbox" id="ttz1_P2" name="ttz1_P2" value="P2" onclick="br_form.CopyStr('input[name^=ttz1_]',reg.tfg1_other_item)"></td>
		<td class="whitetablebg" colspan="7">訴願決定書　經（<input type="text" id="P2_mod_dclass" name="P2_mod_dclass" size="10" maxlength="20">）訴第<input type="text" id="P2_new_no" name="P2_new_no" size="20" maxlength="20">號</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input type="checkbox" id="ttz1_P3" name="ttz1_P3" value="P3" onclick="br_form.CopyStr('input[name^=ttz1_]',reg.tfg1_other_item)"></td>
		<td class="whitetablebg" colspan="7">再訴願決定書　台（<input type="text" id="P3_mod_dclass" name="P3_mod_dclass" size="10" maxlength="20">）訴第<input type="text" id="P3_new_no" name="P3_new_no" size="20" maxlength="20">號</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input type="checkbox" id="ttz1_P4" name="ttz1_P4" value="P4" onclick="br_form.CopyStr('input[name^=ttz1_]',reg.tfg1_other_item)"></td>
		<td class="whitetablebg" colspan="7">行政法院判決書（<input type="text" id="P4_mod_dclass" name="P4_mod_dclass" size="10" maxlength="20">）年度裁／判字第<input type="text" id="P4_new_no" name="P4_new_no" size="20" maxlength="20">號</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input type="checkbox" id="ttz1_P5" name="ttz1_P5" value="P5" onclick="br_form.CopyStr('input[name^=ttz1_]',reg.tfg1_other_item)"></td>
		<td class="whitetablebg" colspan="7">臺北高等行法院判決（<input type="text" id="P5_mod_dclass" name="P5_mod_dclass" size="10" maxlength="20">）年度訴字第<input type="text" id="P5_new_no" name="P5_new_no" size="20" maxlength="20">號</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input type="checkbox" id="ttz1_P6" name="ttz1_P6" value="P6" onclick="br_form.CopyStr('input[name^=ttz1_]',reg.tfg1_other_item)"></td>
		<td class="whitetablebg" colspan="7">最高行政法院判決書第<input type="text" id="P6_new_no" name="P6_new_no" size="20" maxlength="20">號</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input type="checkbox" id="ttz1_P7" name="ttz1_P7" value="P7" onclick="br_form.CopyStr('input[name^=ttz1_]',reg.tfg1_other_item)"></td>
		<td class="whitetablebg" colspan="7">異議審定書第<input type="text" id="P7_new_no" name="P7_new_no" size="20" maxlength="20">號</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input type="checkbox" id="ttz1_P8" name="ttz1_P8" value="P8" onclick="br_form.CopyStr('input[name^=ttz1_]',reg.tfg1_other_item)"></td>
		<td class="whitetablebg" colspan="7">異議案附件第<input type="text" id="P8_new_no" name="P8_new_no" size="20" maxlength="20">號</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input type="checkbox" id="ttz1_P9" name="ttz1_P9" value="P9" onclick="br_form.CopyStr('input[name^=ttz1_]',reg.tfg1_other_item)"></td>
		<td class="whitetablebg" colspan="7">評定書第<input type="text" id="P9_new_no" name="P9_new_no" size="20" maxlength="20">號</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input type="checkbox" id="ttz1_P10" name="ttz1_P10" value="P10" onclick="br_form.CopyStr('input[name^=ttz1_]',reg.tfg1_other_item)"></td>
		<td class="whitetablebg" colspan="7">評定書附件第<input type="text" id="P10_new_no" name="P10_new_no" size="20" maxlength="20">號</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input type="checkbox" id="ttz1_P11" name="ttz1_P11" value="P11" onclick="br_form.CopyStr('input[name^=ttz1_]',reg.tfg1_other_item)"></td>
		<td class="whitetablebg" colspan="7">廢止處分書第<input type="text" id="P11_new_no" name="P11_new_no" size="20" maxlength="20">號</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input type="checkbox" id="ttz1_P12" name="ttz1_P12" value="P12" onclick="br_form.CopyStr('input[name^=ttz1_]',reg.tfg1_other_item)"></td>
		<td class="whitetablebg" colspan="7">其他</td>
	</tr>
</table>

<script language="javascript" type="text/javascript">
    var br_form = {};
    br_form.init = function () {
    }

    //程序種類
    br_form.change_no = function (x) {
        if(x=="A"){
            $("#span_no").html("申請");
            $("#no").val($("#O_apply_no").val());
        }else if(x=="I"){
            $("#span_no").html("註冊");
            $("#no").val($("#O_issue_no").val());
        }else if(x=="R"){
            $("#span_no").html("核駁");
            $("#no").val($("#O_rej_no").val());
        }
    }

    //號數
    $("#no").blur(function (e) {
        $("#tfzd_apply_no").val($("#O_apply_no").val());
        $("#tfzd_issue_no").val($("#O_issue_no").val());
        $("#tfzd_rej_no").val($("#O_rej_no").val());
        
        if($("input[name='tfzd_Mark']:checked").val() == "A"){
            $("#tfzd_apply_no").val($(this).val());
        }else if($("input[name='tfzd_Mark']:checked").val() == "I"){
            $("#tfzd_issue_no").val($(this).val());
        }else if($("input[name='tfzd_Mark']:checked").val() == "R"){
            $("#tfzd_rej_no").val($(this).val());
        }
    })
    
    br_form.CopyStr = function (selector,tar) {
        var strRemark1 = "";
        $(selector).each(function (index) {
            var $this = $(this);
            if ($this.prop("checked")) {
                strRemark1 += $this.val() + "|";
            }
        });
        tar.value = strRemark1;
    }

    //交辦內容綁定
    br_form.bind = function () {
        //console.log("br_form.bind");
        if (jMain.case_main.length == 0) {
        } else {
        }
    }

    //依案性切換要顯示的欄位
    br_form.changeTag = function (T1) {
        var code3 = T1.Left(3).toUpperCase();//案性前3碼
        //切換後重新綁資料
        br_form.bind();
    }
</script>
