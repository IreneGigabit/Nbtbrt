<%@ Control Language="C#" ClassName="FB7Form" %>
<%@ Import Namespace = "System.Collections.Generic"%>

<script runat="server">
    //ZZ交辦內容
    //父控制項傳入的參數
    public Dictionary<string, string> Lock = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    
    protected string prgid = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string SQL = "";

    protected string tfb7_agt_no1 = "";
    
    private void Page_Load(System.Object sender, System.EventArgs e) {
        PageLayout();   
        this.DataBind();
    }
    
    private void PageLayout() {
        //代理人
        tfb7_agt_no1 = Sys.getAgent().Option("{agt_no}", "{agt_no}_{agt_namefull}", " v1='{agt_name1}' {selected}", true);
    }
</script>

<div id="div_Form_FB7">
<%=Sys.GetAscxPath(this)%>
<TABLE border=0 class=bluetable cellspacing=1 cellpadding=2 width="100%">
	<tr>
		<td class="lightbluetable" valign="top" ><strong>參、代理人</strong></td>
		<td class="whitetablebg" colspan="7" >
		    <select id="tfb7_agt_no1" NAME="tfb7_agt_no1"><%#tfb7_agt_no1%></select>
		</td>
	</tr>
	<tr>
		<td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:pointer;COLOR:BLUE" ONCLICK="PMARK(FB7appl_name)">
            <strong>壹、<u>註冊申請案號、商標/標章名稱、商標種類</u></strong>
		</td>
	</tr>
	<tr>
		<td class=lightbluetable align=right >註冊申請案號：</td>
		<td class=whitetablebg colspan="7">
			<input type="text" id="fbf_no" name="fbf_no" value="" size="20" maxlength="20" >
		</TD>
	</tr>
	<tr>
		<td class=lightbluetable align=right >商標/標章名稱：</td>
		<td class=whitetablebg colspan="7">
            <input type="text" id="fbf_Appl_name" name="fbf_Appl_name" value="" size="50" maxlength="100" onchange="reg.tfzd_appl_name.value=this.value">
		</TD>
	</tr>
	<tr>
		<td class=lightbluetable align=right >商標種類：</td>
		<td class=whitetablebg colspan="7">
			<input type=radio name=fbf_S_Mark value="" onclick="dmt_form.change_mark(1, this)">商標
			<!--<input type=radio name=fbf_S_Mark value="S" onclick="dmt_form.change_mark(1, this)">92年修正前服務標章-->
			<input type=radio name=fbf_S_Mark value="N" onclick="dmt_form.change_mark(1, this)">團體商標
			<input type=radio name=fbf_S_Mark value="M" onclick="dmt_form.change_mark(1, this)">團體標章
			<input type=radio name=fbf_S_Mark value="L" onclick="dmt_form.change_mark(1, this)">證明標章
		</TD>
	</tr>
	<tr>
		<td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:pointer;COLOR:BLUE" ONCLICK="PMARK(FB7mark)">
            <strong>肆、<u>補送文件</u></strong><input TYPE="hidden" NAME="tfb7_other_item" id="tfb7_other_item">
        </td>
	</tr>
	<tr class="br_attchstrFB7">
		<td class="lightbluetable" align="right"><input type="checkbox" id="tfb7_Z1" name="tfb7_Z1" value="Z1" onclick="br_form.AttachStr('.br_attchstrFB7', 'tfb7_', reg.tfb7_other_item)" ></td>
		<td class="whitetablebg" colspan="7">商標圖樣浮貼一式５張。</td>
	</tr>
	<tr class="br_attchstrFB7">
		<td class="lightbluetable" align="right"><input type="checkbox" id="tfb7_Z2" name="tfb7_Z2" value="Z2" onclick="br_form.AttachStr('.br_attchstrFB7','tfb7_',reg.tfb7_other_item)" ></td>
		<td class="whitetablebg" colspan="7">載有本件聲音之.wav檔光碟片。</td>
	</tr>
	<tr class="br_attchstrFB7">
		<td class="lightbluetable" align="right"><input type="checkbox" id="tfb7_Z31" name="tfb7_Z31" value="Z31" onclick="br_form.AttachStr('.br_attchstrFB7','tfb7_',reg.tfb7_other_item)" ></td>
		<td class="whitetablebg" colspan="7">商標樣本。</td>
	</tr>
	<tr class="br_attchstrFB7">
		<td class="lightbluetable" align="right"><input type="checkbox" id="tfb7_Z3" name="tfb7_Z3" value="Z3" onclick="br_form.AttachStr('.br_attchstrFB7','tfb7_',reg.tfb7_other_item)" ></td>
		<td class="whitetablebg" colspan="7">商標陳述意見書。</td>
	</tr>
	<tr class="br_attchstrFB7">
		<td class="lightbluetable" align="right"><input type="checkbox" id="tfb7_Z4" name="tfb7_Z4" value="Z4" onclick="br_form.AttachStr('.br_attchstrFB7','tfb7_',reg.tfb7_other_item)" ></td>
		<td class="whitetablebg" colspan="7">委任書（<input type="checkbox" id="tfb7_Z4C" name="tfb7_Z4C" value="Z4C" onclick="br_form.AttachStr('.br_attchstrFB7','tfb7_',reg.tfb7_other_item)" >附中文譯本）。</td>
	</tr>
	<tr class="br_attchstrFB7">
		<td class="lightbluetable" align="right"><input type="checkbox" id="tfb7_Z5" name="tfb7_Z5" value="Z5" onclick="br_form.AttachStr('.br_attchstrFB7','tfb7_',reg.tfb7_other_item)" ></td>
		<td class="whitetablebg" colspan="7">優先權證明文件（<input type="checkbox" id="tfb7_Z5C" name="tfb7_Z5C" value="Z5C" onclick="br_form.AttachStr('.br_attchstrFB7','tfb7_',reg.tfb7_other_item)" >附中文譯本）。</td>
	</tr>
	<tr class="br_attchstrFB7">
		<td class="lightbluetable" align="right"><input type="checkbox" id="tfb7_Z71" name="tfb7_Z71" value="Z71" onclick="br_form.AttachStr('.br_attchstrFB7','tfb7_',reg.tfb7_other_item)" ></td>
		<td class="whitetablebg" colspan="7">展覽會優先權證明文件（<input type="checkbox" id="tfb7_Z71C" name="tfb7_Z71C" value="Z71C" onclick="br_form.AttachStr('.br_attchstrFB7','tfb7_',reg.tfb7_other_item)" >附中文譯本）。</td>
	</tr>
	<tr class="br_attchstrFB7" style="display:none">
		<td class="lightbluetable" align="right"><input type="checkbox" id="tfb7_Z6" name="tfb7_Z6" value="Z6" onclick="br_form.AttachStr('.br_attchstrFB7','tfb7_',reg.tfb7_other_item)" ></td>
		<td class="whitetablebg" colspan="7">大陸地區之自然人或法人之身分證明文件。</td>
	</tr>
	<tr class="br_attchstrFB7">
		<td class="lightbluetable" align="right"><input type="checkbox" id="tfb7_Z7" name="tfb7_Z7" value="Z7" onclick="br_form.AttachStr('.br_attchstrFB7','tfb7_',reg.tfb7_other_item)" ></td>
		<td class="whitetablebg" colspan="7">具結書。（印鑑遺失具結書）</td>
	</tr>
	<tr class="br_attchstrFB7">
		<td class="lightbluetable" align="right"><input type="checkbox" id="tfb7_Z8" name="tfb7_Z8" value="Z8" onclick="br_form.AttachStr('.br_attchstrFB7','tfb7_',reg.tfb7_other_item)" ></td>
		<td class="whitetablebg" colspan="7">法人、團體或政府機關證明文件。（證明標章之附件）</td>
	</tr>
	<tr class="br_attchstrFB7">
		<td class="lightbluetable" align="right"><input type="checkbox" id="tfb7_Z9" name="tfb7_Z9" value="Z9" onclick="br_form.AttachStr('.br_attchstrFB7','tfb7_',reg.tfb7_other_item)" ></td>
		<td class="whitetablebg" colspan="7">申請人得為證明之資格或能力之文件。（證明標章之附件）</td>
	</tr>
	<tr class="br_attchstrFB7" style="display:none">
		<td class="lightbluetable" align="right"><input type="checkbox" id="tfb7_Z10" name="tfb7_Z10" value="Z10" onclick="br_form.AttachStr('.br_attchstrFB7','tfb7_',reg.tfb7_other_item)" ></td>
		<td class="whitetablebg" colspan="7">標示標章條件及控制標章使用方式。（證明標章之附件）</td>
	</tr>
	<tr class="br_attchstrFB7">
		<td class="lightbluetable" align="right"><input type="checkbox" id="tfb7_Z111" name="tfb7_Z111" value="Z111" onclick="br_form.AttachStr('.br_attchstrFB7','tfb7_',reg.tfb7_other_item)" ></td>
		<td class="whitetablebg" colspan="7">申請人具代表性證明文件。（申請產地團體商標/產地證明標章者始需檢附）</td>
	</tr>
	<tr class="br_attchstrFB7">
		<td class="lightbluetable" align="right"><input type="checkbox" id="tfb7_Z11" name="tfb7_Z11" value="Z11" onclick="br_form.AttachStr('.br_attchstrFB7','tfb7_',reg.tfb7_other_item)" ></td>
		<td class="whitetablebg" colspan="7">申請人不從事所證明商品之製造、行銷或服務提供之聲明。（證明標章之附件）</td>
	</tr>
	<tr class="br_attchstrFB7">
		<td class="lightbluetable" align="right"><input type="checkbox" id="tfb7_Z131" name="tfb7_Z131" value="Z131" onclick="br_form.AttachStr('.br_attchstrFB7','tfb7_',reg.tfb7_other_item)" ></td>
		<td class="whitetablebg" colspan="7">使用規範書（<input type="checkbox" id="tfb7_Z131C" name="tfb7_Z131C" value="Z131C" onclick="br_form.AttachStr('.br_attchstrFB7','tfb7_',reg.tfb7_other_item)" >附中文譯本或應記載事項之中文節譯本）。</td>
	</tr>
	<tr class="br_attchstrFB7">
		<td class="lightbluetable" align="right"><input type="checkbox" id="tfb7_Z141" name="tfb7_Z141" value="Z141" onclick="br_form.AttachStr('.br_attchstrFB7','tfb7_',reg.tfb7_other_item)" ></td>
		<td class="whitetablebg" colspan="7">使用規範書之電子檔光碟片（<input type="checkbox" id="tfb7_Z141C" name="tfb7_Z141C" value="Z141C" onclick="br_form.AttachStr('.br_attchstrFB7','tfb7_',reg.tfb7_other_item)" >附中文譯本或應記載事項之中文節譯本）。</td>
	</tr>
	<tr class="br_attchstrFB7">
		<td class="lightbluetable" align="right"><input type="checkbox" id="tfb7_Z12" name="tfb7_Z12" value="Z12" onclick="br_form.AttachStr('.br_attchstrFB7','tfb7_',reg.tfb7_other_item)" ></td>
		<td class="whitetablebg" colspan="7">法人資格證明文件。（團體商標、團體標章之附件）</td>
	</tr>
	<tr class="br_attchstrFB7" style="display:none">
		<td class="lightbluetable" align="right"><input type="checkbox" id="tfb7_Z13" name="tfb7_Z13" value="Z13" onclick="br_form.AttachStr('.br_attchstrFB7','tfb7_',reg.tfb7_other_item)" ></td>
		<td class="whitetablebg" colspan="7">載明申請人成員資格及控制團體商標使用方式之商標使用規範書。（團體商標之附件）</td>
	</tr>
	<tr class="br_attchstrFB7" style="display:none">
		<td class="lightbluetable" align="right"><input type="checkbox" id="tfb7_Z14" name="tfb7_Z14" value="Z14" onclick="br_form.AttachStr('.br_attchstrFB7','tfb7_',reg.tfb7_other_item)" ></td>
		<td class="whitetablebg" colspan="7">載明申請人成員資格及控制團體標章使用方式之使用規範書。（團體標章之附件）</td>
	</tr>
	<tr class="br_attchstrFB7">
		<td class="lightbluetable" align="right"><input type="checkbox" id="tfb7_Z15" name="tfb7_Z15" value="Z15" onclick="br_form.AttachStr('.br_attchstrFB7','tfb7_',reg.tfb7_other_item)" ></td>
		<td class="whitetablebg" colspan="7">分割後之商標註冊申請書正本（含相關文件）。（註冊申請案分割案之附件）</td>
	</tr>
	<tr class="br_attchstrFB7">
		<td class="lightbluetable" align="right"><input type="checkbox" id="tfb7_Z16" name="tfb7_Z16" value="Z16" onclick="br_form.AttachStr('.br_attchstrFB7','tfb7_',reg.tfb7_other_item)" ></td>
		<td class="whitetablebg" colspan="7">變更證明文件。（註冊前變更申請書之附件）</td>
	</tr>
	<tr class="br_attchstrFB7">
		<td class="lightbluetable" align="right"><input type="checkbox" id="tfb7_Z17" name="tfb7_Z17" value="Z17" onclick="br_form.AttachStr('.br_attchstrFB7','tfb7_',reg.tfb7_other_item)" ></td>
		<td class="whitetablebg" colspan="7">其他證明文件。<input TYPE="text" id="tfb7_Z17t" NAME="tfb7_Z17t" SIZE="50" onchange="br_form.AttachStr('.br_attchstrFB7','tfb7_',reg.tfb7_other_item)"></td>
	</tr>
</table>
</div>

<script language="javascript" type="text/javascript">
    //註冊申請案號
    $("#fbf_no").blur(function (e) {
        $("#tfzd_apply_no").val($(this).val());
    })
    
    //交辦內容綁定
    br_form.bindFB7 = function () {
        console.log("fb7.br_form.bind");
        if (jMain.case_main.length == 0) {
        } else {
            $("#tfb7_agt_no1").val(jMain.case_main[0].agt_no);     
            $("#fbf_no").val(jMain.case_main[0].apply_no);//註冊申請案號
            $("#fbf_Appl_name").val(jMain.case_main[0].appl_name);//商標名稱
            //商標種類
            $("input[name=fbf_S_Mark][value='" + jMain.case_main[0].s_mark + "']").prop("checked", true);

            //**附件
            $("#tfb7_other_item").val(jMain.case_main[0].other_item);
            if (jMain.case_main[0].other_item != "") {
                var arr_remark1 = jMain.case_main[0].other_item.split("|");
                for (var i = 0; i < arr_remark1.length; i++) {
                    //var str="Z3|Z9|Z9-具結書正本、讓與人之負責人身份證影本-Z9|";
                    //var str = "Z9-具結書正本、讓與人之負責人身份證影本-Z9";
                    //var substr = arr_remark1[i].match(/Z9-(\S+)-Z9/);
                    var substr = arr_remark1[i].match(/Z9-([\s\S]+)-Z9/);
                    if (substr != null) {
                        $("#tfb7_Z17t").val(substr[1]);
                    } else {
                        $("#tfb7_" + arr_remark1[i]).prop("checked", true);
                    }
                }
            }
        }
    }
</script>
