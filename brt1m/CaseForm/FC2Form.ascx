<%@ Control Language="C#" ClassName="FC2form" %>
<%@ Import Namespace = "System.Collections.Generic"%>

<script runat="server">
    //A6變更案交辦內容
    //父控制項傳入的參數
    public Dictionary<string, string> Lock = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    
    protected string prgid = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string SQL = "";

    protected string ttg2_agt_no = "", FC2_add_agt_no = "";
    
    private void Page_Load(System.Object sender, System.EventArgs e) {
        PageLayout();
        this.DataBind();
    }
    
    private void PageLayout() {
        //代理人
        ttg2_agt_no = Sys.getAgent().Option("{agt_no}", "{agt_no}_{agt_namefull}", " v1='{agt_name1}' {selected}", true);
        FC2_add_agt_no = Sys.getAgent().Option("{agt_no}", "{strcomp_name}_{agt_name}");
    }
</script>

<div id="div_Form_FC2">
<%=Sys.GetAscxPath(this)%>
<TABLE border=0 class=bluetable cellspacing=1 cellpadding=2 width="100%">
    <tr>
		<td class="lightbluetable" colspan=8 valign="top"><strong>※、代理人(與原註冊之代理人資料有變更者，請於該項資料前框格內打Ｖ註記)</strong></td>
	</tr>
	<tr>
		<td class="lightbluetable">
            <INPUT type="checkbox" id=tfop_mod_agt name=tfop_mod_agt value="Y" onclick="br_form.modagttype_chk(this)">
            <INPUT type="hidden" id="tfg2_mod_agt" name="tfg2_mod_agt" value="">
		</td>
		<td class="whitetablebg" colspan="7" valign="top">
		    <select id="ttg2_agt_no" NAME="ttg2_agt_no"><%#ttg2_agt_no%></select>
		</td>
	</tr>
	<tr>
		<td class=lightbluetable align=right >代理人異動：</td>
		<td class=whitetablebg colspan="7">
			<input type="radio" id=tfg2_mod_agttypeC name=tfg2_mod_agttype value="C">變更
            <input type="radio" id=tfg2_mod_agttypeA name=tfg2_mod_agttype value="A">新增
            <input type="radio" id=tfg2_mod_agttypeD name=tfg2_mod_agttype value="D">撤銷
		</td>
	</tr>
	<tr id="FC2_tr_addagtno" style="display:none">
		<td class="lightbluetable" valign="top"><strong>※、新增代理人(代碼)</strong></td>
		<td class="whitetablebg" colspan="7" valign="top">
		    <select id="FC2_add_agt_no" NAME="FC2_add_agt_no"><%#FC2_add_agt_no%></select>
		</td>
	</tr>
	<tr>
		<td class="lightbluetable" colspan=8 valign="top" STYLE="cursor:pointer;COLOR:BLUE" onclick="PMARK(c2Appl_name)">
            <strong>壹、<u>註冊號數、商標(標章)種類及名稱</u></strong>
		</td>
	</tr>
	<tr>
		<td class=lightbluetable align=right >商標種類：</td>
		<td class=whitetablebg colspan="7">
			<input type=radio name=fr2_S_Mark class="onoff" value="" onclick="dmt_form.change_mark(1, this)">商標
			<input type=radio name=fr2_S_Mark class="onoff" value="S" onclick="dmt_form.change_mark(1, this)">92年修正前服務標章
			<input type=radio name=fr2_S_Mark class="onoff" value="N" onclick="dmt_form.change_mark(1, this)">團體商標
			<input type=radio name=fr2_S_Mark class="onoff" value="M" onclick="dmt_form.change_mark(1, this)">團體標章
			<input type=radio name=fr2_S_Mark class="onoff" value="L" onclick="dmt_form.change_mark(1, this)">證明標章
		</TD>
	</tr>
	<tr id=tabbr2 style="display:none">
		<td colspan=8 class="sfont9">
		    <TABLE border=0 class="bluetable"  cellspacing=1 cellpadding=2 width="100%">
		    <tr>	
			    <td class="lightbluetable" align="right">件數：</td>
			    <td class="whitetablebg" colspan="7" ><input type="text" readonly class="SEdit" id=tft2_mod_count2 name=tft2_mod_count2 size=2 value="1">件
				    <input type=hidden id=count2 name=count2 value="1">
				    <input type=hidden id=ctrlcnt2 name=ctrlcnt2 value="">
				    <input type=hidden id=cnt2 name=cnt2 value="1">
			    </td>
		    </tr>
		    <tr>	
			    <td class="lightbluetable" align="right">註冊案號：</td>
			    <td class="whitetablebg" colspan="7" ><input type="text" id=new_no21 name=new_no21 size=20  readonly class=SEdit maxlength=20 onchange="reg.tfzd_issue_no.value=this.value"></td>
		    </tr>
		    <tr>	
			    <td class="lightbluetable" align="right">商標/標章名稱：</td>
			    <td class="whitetablebg" colspan="7"><input type="text" id=ncname121 name=ncname121 size=50 readonly class=SEdit maxlength=50 onchange="reg.tfzd_appl_name.value=this.value"></td>
		    </tr>		
		    </table>
		</td>
	</tr>
	<tr>
		<td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:pointer;COLOR:BLUE" onclick="PMARK(c2Other)"><strong>肆、<u>變更事項(未變更者免填)</u></strong></td>
	</tr>
	<tr>
		<td class=lightbluetable align=right ></td>
		<td class=whitetablebg colspan="7"><input type="hidden" id="tfop_mod_ap" name="tfop_mod_ap"><INPUT type="hidden" name=tfg2_mod_ap id=tfg2_mod_ap value=''>
		    <INPUT type="checkbox" name="tfop_mod_ap" value="Y" onclick="br_form.Cul_DmtTran('tfop_mod_ap','tfg2_mod_ap')">申請人中文名稱
		    <INPUT type="checkbox" name="tfop_mod_ap" value="Y" onclick="br_form.Cul_DmtTran('tfop_mod_ap','tfg2_mod_ap')">申請人英文名稱
		    <INPUT type="checkbox" name=tfop_mod_apaddr value="Y" onclick="br_form.Cul_DmtTran('tfop_mod_apaddr','tfg2_mod_apaddr')">申請人中文地址<INPUT type=hidden name=tfg2_mod_apaddr id=tfg2_mod_apaddr value="">
		    <INPUT type="checkbox" name=tfop_mod_oth value="Y"><INPUT type=hidden id=tfg2_mod_oth name=tfg2_mod_oth value="">申請人印章
		</td>
	</tr>	
	<tr>
		<td class=lightbluetable align=right ></td>
		<td class=whitetablebg colspan="7">	
		    <INPUT type="checkbox" name=tfop_mod_apaddr value="Y" onclick="br_form.Cul_DmtTran('tfop_mod_apaddr','tfg2_mod_apaddr')">申請人英文地址
		    <INPUT type="checkbox" name=tfop_mod_aprep value="Y" onclick="br_form.Cul_DmtTran('tfop_mod_aprep','tfg2_mod_aprep')">代表人中文名稱<INPUT type="hidden" name=tfg2_mod_aprep id=tfg2_mod_aprep value="">
		    <INPUT type="checkbox" name=tfop_mod_aprep value="Y" onclick="br_form.Cul_DmtTran('tfop_mod_aprep','tfg2_mod_aprep')">代表人英文名稱
		    <INPUT type="checkbox" name=tfop_mod_oth1 value="Y">代表人印章<INPUT type=hidden name=tfg2_mod_oth1 id=tfg2_mod_oth1 value="">
		</td>
	</tr>
	<tr>
		<td class=lightbluetable align=right ></td>
		<td class=whitetablebg colspan="7">
            <input type="checkbox" name=tfop_mod_claim1 value="Y" onclick="br_form.clearmod(2)">選定代表人
            <INPUT type="hidden" id="tfg2_mod_claim1" name="tfg2_mod_claim1" value=""><input type="hidden" id=ttg2_ncname2 name=ttg2_ncname2 >
		</td>
	</tr>
	<tr>
		<td class=lightbluetable align=right ></td>
		<td class=whitetablebg colspan="7">
            <input type="checkbox" name=tfop_mod_dmt value="Y" onclick="br_form.clearmod(1)">變更商標(標章)名稱：<input type="text" id=ttg2_ncname1 name=ttg2_ncname1>
            <INPUT type="hidden" id="tfg2_mod_dmt" name="tfg2_mod_dmt" value="">
		</td>
	</tr>
	<tr>
		<td class=lightbluetable align=right ></td>
		<td class=whitetablebg colspan="7"><input type="checkbox" id=tfop_oitem1 name=tfop_oitem1 value="Y" >修正使用規範書：
			<input type="radio" id=tfop_oitem1cN name=tfop_oitem1c value="N">團體商標
			<input type="radio" id=tfop_oitem1cM name=tfop_oitem1c value="M">團體標章
			<input type="radio" id=tfop_oitem1cL name=tfop_oitem1c value="L">證明標章
		</td>
	</tr>
	<tr>
		<td class=lightbluetable align=right ></td>
		<td class=whitetablebg colspan="7">
            <input type="checkbox" name=tfop_mod_claim2 value="Y" onclick="br_form.clearmod(3)">質權人名稱、地址、代表人及印章變更
            <INPUT type="hidden" name="tfg2_mod_claim2" id="tfg2_mod_claim2" value="">
		</td>
	</tr>
	<tr>
		<td class=lightbluetable align=right ></td>
		<td class=whitetablebg colspan="7"><input type="checkbox" id=tfop_oitem2 name=tfop_oitem2 value="Y" >質權移轉：擔保債權移轉原因
			<input type="radio" id=tfop_oitem2cA name=tfop_oitem2c value="A">有償讓與
			<input type="radio" id=tfop_oitem2cB name=tfop_oitem2c value="B">無償讓與
			<input type="radio" id=tfop_oitem2cC name=tfop_oitem2c value="C">繼承
			<input type="radio" id=tfop_oitem2cD name=tfop_oitem2c value="D">其他法定移轉
		</td>
	</tr>
	<tr>
		<td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:pointer;COLOR:BLUE" onclick="PMARK(zAttech)">
            <strong><u>附件：</u></strong>
		</td>
	</tr>
	<tr class="br_attchstr">
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttz2_Z1" NAME="ttz2_Z1" value="Z1" onclick="br_form.AttachStr('.br_attchstr','ttz2_',reg.tfzd_remark1)"></td>
		<td class="whitetablebg" colspan="7">公司變更登記事項卡影本或其他法人證明文件(<input TYPE="checkbox" id="ttz2_Z1C" NAME="ttz2_Z1C" value="Z1C" onclick="br_form.AttachStr('.br_attchstr','ttz2_',reg.tfzd_remark1)">附中譯本)。</td>
	</tr>
	<tr class="br_attchstr">
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttz2_Z3" NAME="ttz2_Z3" value="Z3" onclick="br_form.AttachStr('.br_attchstr','ttz2_',reg.tfzd_remark1)"></td>
		<td class="whitetablebg" colspan="7">戶口謄本。</td>
	</tr>
	<tr class="br_attchstr">
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttz2_Z2" NAME="ttz2_Z2" value="Z2" onclick="br_form.AttachStr('.br_attchstr','ttz2_',reg.tfzd_remark1)"></td>
		<td class="whitetablebg" colspan="7">委任書(<input TYPE="checkbox" id="ttz2_Z2C" NAME="ttz2_Z2C" value="Z2C" onclick="br_form.AttachStr('.br_attchstr','ttz2_',reg.tfzd_remark1)">附中譯本)。</td>
	</tr>
	<tr class="br_attchstr">
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttz2_Z4" NAME="ttz2_Z4" value="Z4" onclick="br_form.AttachStr('.br_attchstr','ttz2_',reg.tfzd_remark1)"></td>
		<td class="whitetablebg" colspan="7">使用規範書(<input TYPE="checkbox" id="ttz2_Z4C" NAME="ttz2_Z4C" value="Z4C" onclick="br_form.AttachStr('.br_attchstr','ttz2_',reg.tfzd_remark1)">附中文譯本或應記載事項之中文節譯本)。</td>
	</tr>
	<tr class="br_attchstr">
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttz2_Z5" NAME="ttz2_Z5" value="Z5" onclick="br_form.AttachStr('.br_attchstr','ttz2_',reg.tfzd_remark1)"></td>
		<td class="whitetablebg" colspan="7">使用規範書之電子檔光碟片(<input TYPE="checkbox" id="ttz2_Z5C" NAME="ttz2_Z5C" value="Z5C" onclick="br_form.AttachStr('.br_attchstr','ttz2_',reg.tfzd_remark1)">附中文譯本或應記載事項之中文節譯本)。</td>
	</tr>
	<tr class="br_attchstr">
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttz2_Z6" NAME="ttz2_Z6" value="Z6" onclick="br_form.AttachStr('.br_attchstr','ttz2_',reg.tfzd_remark1)"></td>
		<td class="whitetablebg" colspan="7">全體共有人同意書。</td>
	</tr>
	<tr class="br_attchstr">
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttz2_Z7" NAME="ttz2_Z7" value="Z7" onclick="br_form.AttachStr('.br_attchstr','ttz2_',reg.tfzd_remark1)"></td>
		<td class="whitetablebg" colspan="7">讓與債權時，質權隨同移轉，應檢附下列證明文件：</td>
	</tr>
	<tr class="br_attchstr">
		<td class="lightbluetable" align="right"></td>
		<td class="whitetablebg" colspan="7"><input TYPE="checkbox" id="ttz2_Z71" NAME="ttz2_Z71" value="Z71" onclick="br_form.AttachStr('.br_attchstr','ttz2_',reg.tfzd_remark1)">
		擔保債權有償讓與：應檢附擔保債權讓與契約書(<input TYPE="checkbox" id="ttz2_Z71C" NAME="ttz2_Z71C" value="Z71C" onclick="br_form.AttachStr('.br_attchstr','ttz2_',reg.tfzd_remark1)">附中文譯本)。
		</td>
	</tr>
	<tr class="br_attchstr">
		<td class="lightbluetable" align="right"></td>
		<td class="whitetablebg" colspan="7"><input TYPE="checkbox" id="ttz2_Z72" NAME="ttz2_Z72" value="Z72" onclick="br_form.AttachStr('.br_attchstr','ttz2_',reg.tfzd_remark1)">
		擔保債權無償讓與，應檢附擔保債權無償讓與契約書(<input TYPE="checkbox" id="ttz2_Z72C" NAME="ttz2_Z72C" value="Z72C" onclick="br_form.AttachStr('.br_attchstr','ttz2_',reg.tfzd_remark1)">附中文譯本)，<br>稽徵機關核發之稅款繳清證明書，或核定免稅證明書，或不計入贈與總額證明書，或同意移轉證明書之副本，或稽徵機關核發之其他證明文件。
		</td>
	</tr>
	<tr class="br_attchstr">
		<td class="lightbluetable" align="right"></td>
		<td class="whitetablebg" colspan="7"><input TYPE="checkbox" id="ttz2_Z73" NAME="ttz2_Z73" value="Z73" onclick="br_form.AttachStr('.br_attchstr','ttz2_',reg.tfzd_remark1)">
		擔保債權繼承移轉，應檢附質權人死亡證明、質權人全戶戶籍謄本(由繼承人具結係全戶謄本)、質權歸屬證明或其他繼承證明文件(<input TYPE="checkbox" id="ttz2_Z73C" NAME="ttz2_Z73C" value="Z73C" onclick="br_form.AttachStr('.br_attchstr','ttz2_',reg.tfzd_remark1)">附中文譯本)，<br>稽徵機關核發之稅款繳清證明書，或核定免稅證明書，或不計入遺產總額證明書，或同意移轉證明書之副本，或稽徵機關核發之其他證明文件。
		</td>
	</tr>
	<tr class="br_attchstr">
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttz2_Z9" NAME="ttz2_Z9" value="Z9" onclick="br_form.AttachStr('.br_attchstr','ttz2_',reg.tfzd_remark1)"></td>
		<td class="whitetablebg" colspan="7">其他。<input TYPE="text" id="ttz2_Z9t" NAME="ttz2_Z9t" SIZE="50" onchange="br_form.AttachStr('.br_attchstr','ttz2_',reg.tfzd_remark1)"></td>
	</tr>
	<tr style="display:none">
		<td class=lightbluetable  ROWSPAN=2 ><strong>附註一：</strong></td>
		<td class=whitetablebg colspan=7>本件商標(標章)於<INPUT type=text id=O_item21 name=O_item21 size=10 class="dateField">(年/月/日)</td>
	</tr>
	<tr style="display:none">		  
		<td class=whitetablebg colspan=7>另案辦理<INPUT type="radio" id=O_item22FT1 name=O_item22 value="FT1" onclick="reg.O_item23.value=''">移轉案
													<INPUT type="radio" id=O_item22FL1 name=O_item22 value="FL1" onclick="reg.O_item23.value=''">授權案
													<INPUT type="radio" id=O_item22F11 name=O_item22 value="FI1" onclick="reg.O_item23.value=''">補證案
													<INPUT type="radio" id=O_item22FR1 name=O_item22 value="FR1" onclick="reg.O_item23.value=''">延展案
													<INPUT type="radio" id=O_item22ZZ name=O_item22 value="ZZ">其他<input type="text" name="O_item23" value="" size=10 onchange="reg.O_item22(4).checked=true">案
		</TD>
	</tr>	
</table>
</div>

<script language="javascript" type="text/javascript">
    //代理人變更
    br_form.modagttype_chk = function (tfield) {
        if ($(tfield).prop("checked") == false) {
            $("input[name='tfop1_mod_agttype']").prop("checked", false);
            $("input[name='tfg2_mod_agttype']").prop("checked", false);
        }
    }

    br_form.clearmod = function (x) {
        if(x==1){
            if($("#tfop_mod_dmt").prop("checked")==true){
                $("#tfg2_mod_dmt").val("Y");
            }else{
                $("#tfg2_mod_dmt").val("N");
                $("#ttg2_ncname1").val("");
            }
        }else if(x==3){
            if($("#tfop_mod_claim2").prop("checked")==true){
                $("#tfg2_mod_claim2").val("Y");
            }else{
                $("#tfg2_mod_claim2").val("N");
                $("#ttg2_ncname1").val("");
            }
        }else{
            if($("#tfop_mod_claim1").prop("checked")==true){
                $("#tfg2_mod_claim1").val("Y");
            }else{
                $("#tfg2_mod_claim1").val("N");
            }
        }
    }

    br_form.Cul_DmtTran = function (src,tar) {
        var nclass = $("input[name='"+src+"']").map(function (index) {
            return ($(this).prop("checked")==true? "Y":"N");
        });

        $("#"+tar).val().get().join('');
    }

    //交辦內容綁定
    br_form.bindFC2 = function () {
        console.log("fc2.br_form.bind");
        if (jMain.case_main.length == 0) {
        } else {
        }
    }
</script>
