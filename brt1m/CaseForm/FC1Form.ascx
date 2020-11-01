<%@ Control Language="C#" ClassName="FC1form" %>
<%@ Import Namespace = "System.Collections.Generic"%>

<script runat="server">
    //A6變更案交辦內容
    //父控制項傳入的參數
    public Dictionary<string, string> Lock = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    
    protected string prgid = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string SQL = "";

    protected string ttg1_agt_no = "", FC1_add_agt_no = "";
    
    private void Page_Load(System.Object sender, System.EventArgs e) {
        PageLayout();
        this.DataBind();
    }
    
    private void PageLayout() {
        //代理人
        ttg1_agt_no = Sys.getAgent().Option("{agt_no}", "{agt_no}_{agt_namefull}", " v1='{agt_name1}' {selected}", true);
        FC1_add_agt_no = Sys.getAgent().Option("{agt_no}", "{strcomp_name}_{agt_name}");
    }
</script>

<div id="div_Form_FC1">
<%=Sys.GetAscxPath(this)%>
<TABLE border=0 class=bluetable cellspacing=1 cellpadding=2 width="100%">
	<tr>
		<td class="lightbluetable" valign="top"><strong>※、代理人(代碼)</strong></td>
		<td class="whitetablebg" colspan="7" valign="top">
		    <select id="ttg1_agt_no" NAME="ttg1_agt_no"><%#ttg1_agt_no%></select>
		</td>
	</tr>
	<tr id="FC1_tr_addagtno" style="display:none">
		<td class="lightbluetable" valign="top"><strong>※、新增代理人(代碼)</strong></td>
		<td class="whitetablebg" colspan="7" valign="top">
		    <select id="FC1_add_agt_no" NAME="FC1_add_agt_no"><%#FC1_add_agt_no%></select>
		</td>
	</tr>
	<tr>
		<td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:pointer;COLOR:BLUE" onclick="PMARK(c1Appl_name)">
            <strong>壹、<u>註冊申請案號、商標/標章名稱</u></strong>
		</td>
	</tr>
	<tr>
		<td class=lightbluetable align=right >商標種類：</td>
		<td class=whitetablebg colspan="7">
			<input type=radio name=fr_S_Mark class="onoff" value="" onclick="dmt_form.change_mark(1, this)">商標
			<span id="fr_smark" style="display:none">
			<input type=radio name=fr_S_Mark class="onoff" value="S" onclick="dmt_form.change_mark(1, this)">92年修正前服務標章
			</span>
			<input type=radio name=fr_S_Mark class="onoff" value="N" onclick="dmt_form.change_mark(1, this)">團體商標
			<input type=radio name=fr_S_Mark class="onoff" value="M" onclick="dmt_form.change_mark(1, this)">團體標章
			<input type=radio name=fr_S_Mark class="onoff" value="L" onclick="dmt_form.change_mark(1, this)">證明標章
		</TD>
	</tr>
	<tr>
		<td colspan=8 class="sfont9">
		    <TABLE id=tabbr11 style="display:" border=0 class="bluetable"  cellspacing=1 cellpadding=2 width="100%">
		    <tr>	
			    <td class="lightbluetable" align="right">件數：</td>
			    <td class="whitetablebg" colspan="7" ><input type="text" readonly class="SEdit" id=tft1_mod_count11 name=tft1_mod_count11 size=2 value="1">件
				    <input type=hidden id=count11 name=count11 value="1">
				    <input type=hidden id=ctrlcnt11 name=ctrlcnt11 value="">
				    <input type=hidden id=cnt11 name=cnt11 value="1">
			    </td>
		    </tr>
		    <tr>	
			    <td class="lightbluetable" align="right">申請案號：</td>
			    <td class="whitetablebg" colspan="7" ><input type="text" readonly class=sedit id=new_no11 name=new_no11 size=20  maxlength=20 onchange="reg.tfzd_apply_no.value=this.value"></td>
		    </tr>
		    <tr>	
			    <td class="lightbluetable" align="right">商標/標章名稱：</td>
			    <td class="whitetablebg" colspan="7"><input type="text" readonly class=sedit id=ncname111 name=ncname111 size=40 maxlength=50 onchange="reg.tfzd_appl_name.value=this.value"></td>
		    </tr>
		    </table>
		</td>
	</tr>
	<tr>
		<td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:pointer;COLOR:BLUE" onclick="PMARK(c1Mod)"><strong>貳、<u>變更事項</u></strong></td>
	</tr>
	<tr>
		<td class=lightbluetable align=right></td>
		<td class=whitetablebg colspan="7">
            <input type="checkbox" id="tfzr_mod_ap" name="tfzr_mod_ap">申請人名稱&nbsp;&nbsp;&nbsp;&nbsp;
            <input type="checkbox" id="tfzr_mod_aprep" name="tfzr_mod_aprep">代表人&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <input type="checkbox" id="tfzr_mod_agt" name="tfzr_mod_agt">代理人
		</TD>
	</tr>
	<tr>
		<td class=lightbluetable align=right></td>
		<td class=whitetablebg colspan="7">
            <input type="checkbox" id="tfzr_mod_apaddr" name="tfzr_mod_apaddr">申請人地址&nbsp;&nbsp;&nbsp;&nbsp;
            <input type="checkbox" id="tfzr_mod_agtaddr" name="tfzr_mod_agtaddr">代理人地址
			<input type="checkbox" id="tfzr_mod_claim1" name="tfzr_mod_claim1">選定代表人
		</TD>
	</tr>
	<tr>
		<td class=lightbluetable align=right></td>
		<td class=whitetablebg colspan="7">
            <input type="checkbox" id="tfzr_mod_oth" name="tfzr_mod_oth">申請人印鑑&nbsp;&nbsp;&nbsp;&nbsp;
            <input type="checkbox" id="tfzr_mod_oth1" name="tfzr_mod_oth1">代表人印鑑&nbsp
            <input type="checkbox" id="tfzr_mod_oth2" name="tfzr_mod_oth2">代理人印鑑
			<input type="hidden" id="tfg1_mod_ap" name="tfg1_mod_ap">
			<input type="hidden" id="tfg1_mod_aprep" name="tfg1_mod_aprep">
			<input type="hidden" id="tfg1_mod_agt" name="tfg1_mod_agt">
			<input type="hidden" id="tfg1_mod_apaddr" name="tfg1_mod_apaddr">
			<input type="hidden" id="tfg1_mod_agtaddr" name="tfg1_mod_agtaddr">
			<input type="hidden" id="tfg1_mod_oth" name="tfg1_mod_oth">
			<input type="hidden" id="tfg1_mod_oth1" name="tfg1_mod_oth1">
			<input type="hidden" id="tfg1_mod_oth2" name="tfg1_mod_oth2">
			<input type="hidden" id="tfg1_mod_claim1" name="tfg1_mod_claim1">
        </TD>
	</tr>
	<tr>
		<td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:pointer;COLOR:BLUE" onclick="PMARK(zAttech)">
            <strong><u>附件：</u></strong><input type="hidden" name=tfzd_remark1 id=tfzd_remark1>
		</td>
	</tr>
	<tr class="br_attchstr">
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttz1_Z2" NAME="ttz1_Z2" value="Z2" onclick="br_form.AttachStr('.br_attchstr','ttz1_',reg.tfzd_remark1)"></td>
		<td class="whitetablebg" colspan="7">委任書(<input TYPE="checkbox" id="ttz1_Z2C" NAME="ttz1_Z2C" value="Z2C" onclick="br_form.AttachStr('.br_attchstr','ttz1_',reg.tfzd_remark1)">附中文譯本)。</td>
	</tr>			
	<tr class="br_attchstr">
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttz1_Z1" NAME="ttz1_Z1" value="Z1" onclick="br_form.AttachStr('.br_attchstr','ttz1_',reg.tfzd_remark1)"></td>
		<td class="whitetablebg" colspan="7">變更證明文件。</td>
	</tr>
	<tr class="br_attchstr">
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttz1_Z8" NAME="ttz1_Z8" value="Z8" onclick="br_form.AttachStr('.br_attchstr','ttz1_',reg.tfzd_remark1)"></td>
		<td class="whitetablebg" colspan="7">移轉契約或其他移轉證明文件。</td>
	</tr>
	<tr class="br_attchstr">
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttz1_Z3" NAME="ttz1_Z3" value="Z3" onclick="br_form.AttachStr('.br_attchstr','ttz1_',reg.tfzd_remark1)"></td>
		<td class="whitetablebg" colspan="7">個人身分證影本。</td>
	</tr>
	<tr class="br_attchstr">
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttz1_Z4" NAME="ttz1_Z4" value="Z4" onclick="br_form.AttachStr('.br_attchstr','ttz1_',reg.tfzd_remark1)"></td>
		<td class="whitetablebg" colspan="7">法人公司執照影本。</td>
	</tr>
	<tr class="br_attchstr">
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttz1_Z5" NAME="ttz1_Z5" value="Z5" onclick="br_form.AttachStr('.br_attchstr','ttz1_',reg.tfzd_remark1)"></td>
		<td class="whitetablebg" colspan="7">身分或法人證明影本。</td>
	</tr>
	<tr class="br_attchstr">
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttz1_Z6" NAME="ttz1_Z6" value="Z6" onclick="br_form.AttachStr('.br_attchstr','ttz1_',reg.tfzd_remark1)"></td>
		<td class="whitetablebg" colspan="7">具結書。(印鑑遺失具結書)</td>
	</tr>
	<tr class="br_attchstr">
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttz1_Z7" NAME="ttz1_Z7" value="Z7" onclick="br_form.AttachStr('.br_attchstr','ttz1_',reg.tfzd_remark1)"></td>
		<td class="whitetablebg" colspan="7">全體共有人同意書。</td>
	</tr>
	<tr class="br_attchstr">
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttz1_Z9" NAME="ttz1_Z9" value="Z9" onclick="br_form.AttachStr('.br_attchstr','ttz1_',reg.tfzd_remark1)"></td>
		<td class="whitetablebg" colspan="7">其他證明文件。<input TYPE="text" id="ttz1_Z9t" NAME="ttz1_Z9t" SIZE="50" onchange="br_form.AttachStr('.br_attchstr','ttz1_',reg.tfzd_remark1)"></td>
	</tr>
</table>
</div>
<script language="javascript" type="text/javascript">
    //交辦內容綁定
    br_form.bindFC1 = function () {
        console.log("fc1.br_form.bind");
        if (jMain.case_main.length == 0) {
        } else {
        }
    }
</script>
