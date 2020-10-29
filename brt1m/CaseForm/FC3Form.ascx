<%@ Control Language="C#" ClassName="FC3form" %>
<%@ Import Namespace = "System.Collections.Generic"%>

<script runat="server">
    //A6變更案交辦內容
    //父控制項傳入的參數
    public Dictionary<string, string> Lock = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    
    protected string prgid = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string SQL = "";

    protected string ttg3_agt_no = "";
    
    private void Page_Load(System.Object sender, System.EventArgs e) {
        PageLayout();
        this.DataBind();
    }
    
    private void PageLayout() {
        //代理人
        ttg3_agt_no = Sys.getAgent().Option("{agt_no}", "{agt_no}_{agt_namefull}", " v1='{agt_name1}' {selected}", true);
    }
</script>

<div id="div_Form_FC3">
<%=Sys.GetAscxPath(this)%>
<TABLE border=0 class=bluetable cellspacing=1 cellpadding=2 width="100%">
 	<tr>
		<td class="lightbluetable" valign="top"><strong>※、代理人(代碼)</strong></td>
		<td class="whitetablebg" colspan="7" valign="top">
		    <select id="ttg3_agt_no" NAME="ttg3_agt_no"><%#ttg3_agt_no%></select>
		</td>
	</tr>
	<tr>
		<td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:pointer;COLOR:BLUE" onclick="PMARK(c3Appl_name)">
            <strong>壹、<u>註冊號數、商標/標章名稱、商標種類</u></strong>
        </td>
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
		<td class=lightbluetable align=right >註冊號數：</td>
		<td class=whitetablebg colspan="7"><input type="text" id="fr3_issue_no" name="fr3_issue_no" value="" size="20" maxlength="20" onchange="reg.tfzd_issue_no.value=this.value"></TD>
	</tr>
	<tr>
		<td class=lightbluetable align=right >商標/標章名稱：</td>
		<td class=whitetablebg colspan="7"><input type="text" id="fr3_appl_name" name="fr3_appl_name" value="" size="30" maxlength="100" onchange="reg.tfzd_appl_name.value=this.value"></TD>
	</tr>
	<tr>
		<td class="lightbluetable" colspan=8 valign="top" STYLE="cursor:pointer;COLOR:BLUE" onclick="PMARK(m5Good1)"><strong>肆、<u>擬減縮商品（服務）名稱</u></strong></td>
	</tr>
	<tr>
		<td colspan=8 class="sfont9">
		    <TABLE id=tabbr31 style="display:" border=0 class="bluetable"  cellspacing=1 cellpadding=2 width="100%">
            <thead>
		    <tr>	
			    <td class="lightbluetable" align="right" width="18%">件數：</td>
			    <td class="whitetablebg" colspan="7" >共<input type="text" id=tft3_class_count1 name=tft3_class_count1 size=2 onchange="br_form.Add_classFC3(this.value,1)">件<input type="text" id="tft3_class1" name="tft3_class1" readonly>
				    <input type=hidden id=ctrlnum31 name=ctrlnum31 value="0">
				    <input type=hidden id=ctrlcount31 name=ctrlcount31 value="">
				    <input type=hidden id=num31 name=num31 value="0"><!--畫面上有幾筆-->
				    <input type=hidden id=tft3_mod_type name=tft3_mod_type value="Dgood">
				    <input type=hidden id=tfg3_mod_class name=tfg3_mod_class value="">
			    </td>
		    </tr>
            </thead>
            <tbody></tbody>
            <script type="text/html" id="fc3_br_class_template1"><!--類別樣板-->
		    <tr class="fc3_br_class_template1_##">
			    <td class="lightbluetable" align="right">類別##：</td>
			    <td class="whitetablebg" colspan="7" ><input type="text" id=class31_## name=class31_## size=3 maxlength=3 onchange="br_form.count_kindFC3(this,'1')"></td>
		    </tr>
		    <tr class="fc3_br_class_template1_##">
			    <td class="lightbluetable" align="right">商標/服務名稱1：</td>
			    <td class="whitetablebg" colspan="7"><textarea id="good_name31_##" NAME="good_name31_##" ROWS="10" COLS="75" onchange="br_form.good_name_count('good_name31_##','good_count31_##')"></textarea>
			    <input type="hidden" id=good_count31_## name=good_count31_## size=2>
			    </td>
		    </tr>
            </script>
		    </table>
		</td>
	</tr>
	<tr>
		<td class="lightbluetable" colspan=8 valign="top" STYLE="cursor:pointer;COLOR:BLUE" onclick="PMARK(m5Good2)"><strong>伍、<u>減縮後指定商品（服務）名稱</u></strong></td>
	</tr>
	<tr>
		<td colspan=8 class="sfont9">
		<TABLE id=tabbr32 style="display:" border=0 class="bluetable"  cellspacing=1 cellpadding=2 width="100%">
        <thead>
		<tr>	
			<td class="lightbluetable" align="right" >類別種類：</td>
			<td class="whitetablebg" colspan="7" >
				<input type="radio" id=tft3_class_type2I name=tft3_class_type2 value="int">國際分類
				<input type="radio" id=tft3_class_type2O name=tft3_class_type2 value="old">舊類
			</td>
		</tr>
		<tr>	
			<td class="lightbluetable" align="right" width="18%">件數：</td>
			<td class="whitetablebg" colspan="7" >共<input type="text" id=tft3_class_count2 name=tft3_class_count2 size=2 onchange="br_form.Add_classFC3(this.value,2)">件<input type="text" id=tft3_class2 name=tft3_class2 readonly>
				<input type=hidden id=ctrlnum32 name=ctrlnum32 value="0">
				<input type=hidden id=ctrlcount32 name=ctrlcount32 value="">
				<input type=hidden id=num32 name=num32 value="0"><!--畫面上有幾筆-->
			</td>
		</tr>
        </thead>
        <tbody></tbody>
        <script type="text/html" id="fc3_br_class_template2"><!--類別樣板-->
		    <tr class="fc3_br_class_template2_##">	
			    <td class="lightbluetable" align="right">類別##：</td>
			    <td class="whitetablebg" colspan="7" ><input type="text" id=class32_## name=class32_## size=3 maxlength=3 onchange="br_form.count_kindFC3(this,'2')"></td>
		    </tr>
		    <tr class="fc3_br_class_template2_##">	
			    <td class="lightbluetable" align="right">商標/服務名稱1：</td>
			    <td class="whitetablebg" colspan="7"><textarea id="good_name32_##" NAME="good_name32_##" ROWS="10" COLS="75" onchange="br_form.good_name_count('good_name32_##','good_count32_##')"></textarea>
			    <input type="hidden" id=good_count32_## name=good_count32_## size=2>
			    </td>
		    </tr>
        </script>
		</table>
		</td>
	</tr>
	<tr>
		<td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:pointer;COLOR:BLUE" onclick="PMARK(zAttech)">
            <strong><u>附件：</u></strong>
		</td>
	</tr>
	<tr class="br_attchstr">
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttz3_Z1" NAME="ttz3_Z1" value="Z1" onclick="br_form.AttachStr('.br_attchstr','ttz3_',reg.tfzd_remark1)"></td>
		<td class="whitetablebg" colspan="7">委任書(<input TYPE="checkbox" id="ttz3_Z1C" NAME="ttz3_Z1C" value="Z1C" onclick="br_form.AttachStr('.br_attchstr','ttz3_',reg.tfzd_remark1)">附中文譯本)。</td>
	</tr>
	<tr class="br_attchstr">
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttz3_Z2" NAME="ttz3_Z2" value="Z2" onclick="br_form.AttachStr('.br_attchstr','ttz3_',reg.tfzd_remark1)"></td>
		<td class="whitetablebg" colspan="7">全體共有人同意書(<input TYPE="checkbox" id="ttz3_Z2C" NAME="ttz3_Z2C" value="Z2C" onclick="br_form.AttachStr('.br_attchstr','ttz3_',reg.tfzd_remark1)">附中文譯本)。</td>
	</tr>
	<tr class="br_attchstr">
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="ttz3_Z3" id="ttz3_Z3" value="Z3" onclick="br_form.AttachStr('.br_attchstr','ttz3_',reg.tfzd_remark1)"></td>
		<td class="whitetablebg" colspan="7">團體商標或證明標章使用規範書(<input TYPE="checkbox" id="ttz3_Z3C" NAME="ttz3_Z3C" value="Z3C" onclick="br_form.AttachStr('.br_attchstr','ttz3_',reg.tfzd_remark1)">附中文譯本)。</td>
	</tr>
	<tr class="br_attchstr">
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttz3_Z4" NAME="ttz3_Z4" value="Z4" onclick="br_form.AttachStr('.br_attchstr','ttz3_',reg.tfzd_remark1)"></td>
		<td class="whitetablebg" colspan="7">團體商標或證明標章使用規範書之電子檔光碟片(<input TYPE="checkbox" id="ttz3_Z4C" NAME="ttz3_Z4C" value="Z4C" onclick="br_form.AttachStr('.br_attchstr','ttz3_',reg.tfzd_remark1)">附中文譯本)。</td>
	</tr>
	<tr class="br_attchstr">
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttz3_Z9" NAME="ttz3_Z9" value="Z9" onclick="br_form.AttachStr('.br_attchstr','ttz3_',reg.tfzd_remark1)"></td>
		<td class="whitetablebg" colspan="7">其他。<input TYPE="text" id="ttz3_Z9t" NAME="ttz3_Z9t" SIZE="50" onchange="br_form.AttachStr('.br_attchstr','ttz3_',reg.tfzd_remark1)"></td>
	</tr>	
	<tr>
		<td class=lightbluetable  colspan="8"><strong>備註：本案另涉有他案時，請於備註欄內填明。</strong></td>
	</tr>	
	<tr>
		<td class=lightbluetable  ></td>
		<td class=whitetablebg colspan=7>
			本件商標(標章)於<INPUT type=text id=O_item31 name=O_item31 size=10 class="dateField">(年/月/日)，另案辦理：
			<INPUT type="radio" id=O_item32DO1 name=O_item32 value="DO1" onclick="reg.O_item33.value=''">異議案
			<INPUT type="radio" id=O_item32DI1 name=O_item32 value="DI1" onclick="reg.O_item33.value=''">評定案
			<INPUT type="radio" id=O_item32FI1 name=O_item32 value="FI1" onclick="reg.O_item33.value=''">補證案
			<INPUT type="radio" id=O_item32FR1 name=O_item32 value="FR1" onclick="reg.O_item33.value=''">延展案
			<INPUT type="radio" id=O_item32ZZ name=O_item32 value="ZZ">其他<input type="text" id="O_item33" name="O_item33" value="" size=10 onchange="reg.O_item32(4).checked=true">案
		</TD>
	</tr>
</table>
</div>

<script language="javascript" type="text/javascript">
    //共N件，classCount:要改成幾筆,cntTar:第幾個類別table
    br_form.Add_classFC3 = function (classCount, cntTar) {
        var doCount = Math.max(0, CInt(classCount));//要改為幾筆,最少是0
        var num = CInt($("#num3" + cntTar).val());//目前畫面上有幾筆
        if (doCount > num) {//要加
            for (var nRow = num; nRow < doCount ; nRow++) {
                var copyStr = $("#br_class_template" + cntTar).text() || "";
                copyStr = copyStr.replace(/##/g, nRow + 1);
                $("#tabbr3" + cntTar + " tbody").append(copyStr);
                $("#num3" + cntTar).val(nRow + 1);
            }
        } else {
            //要減
            for (var nRow = num; nRow > doCount ; nRow--) {
                $('.br_class_template' + cntTar + "_" + +nRow, $("#tabbr3" + cntTar + " tbody")).remove();
                $("#num3" + cntTar).val(nRow - 1);
            }
        }
    }

    //類別串接
    br_form.count_kindFC3 = function (pObj,pFld) {
        if ($(pObj).val() != "") {
            if (IsNumeric($(pObj).val())) {
                var x = ("000" + $(pObj).val()).Right(3);//補0
                $(pObj).val(x);
                br_form.checkclass(x);
            } else {
                alert("商品類別請輸入數值!!!");
                $(pObj).val("");
            }
        }

        var nclass = $("input[id^='class3"+pFld+"_']").map(function (index) {
            if (index == 0 || $(this).val() != "") return $(this).val();
        });
        $("#tft3_class" + pFld).val(nclass.get().join(','));
        $("#ctrlcount3" + pFld).val(Math.max(CInt($("#tft3_class" + pFld).val()), nclass.length));//回寫共N類
    }

    //交辦內容綁定
    br_form.bindFC3 = function () {
        console.log("fc3.br_form.bind");
        if (jMain.case_main.length == 0) {
        } else {
        }
    }
</script>
