<%@ Control Language="C#" ClassName="FC21form" %>
<%@ Import Namespace = "System.Collections.Generic"%>

<script runat="server">
    //A6變更案交辦內容
    //父控制項傳入的參數
    public Dictionary<string, string> Lock = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    
    protected string prgid = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string SQL = "";

    protected string ttg21_agt_no = "";
    
    private void Page_Load(System.Object sender, System.EventArgs e) {
        PageLayout();
        this.DataBind();
    }
    
    private void PageLayout() {
        //代理人
        ttg21_agt_no = Sys.getAgent().Option("{agt_no}", "{agt_no}_{agt_namefull}", " v1='{agt_name1}' {selected}", true);
    }
</script>

<div id="div_Form_FC21">
<%=Sys.GetAscxPath(this)%>
<TABLE border=0 class=bluetable cellspacing=1 cellpadding=2 width="100%">
    <tr>
		<td class="lightbluetable" colspan=8 valign="top">
            <strong>※、代理人(與原註冊之代理人資料有變更者，請於該項資料前框格內打Ｖ註記)</strong>
		</td>
	</tr>
	<tr>
		<td class="lightbluetable">
            <INPUT type="checkbox" id=tfop1_mod_agt name=tfop1_mod_agt value="Y" onclick="br_form.modagttype_chk(this)">
		</td>
		<td class="whitetablebg" colspan="7" valign="top">
            <select id="ttg21_agt_no" NAME="ttg21_agt_no"><%#ttg21_agt_no%></select>
		</td>
	</tr>
	<tr>
		<td class=lightbluetable align=right >代理人異動：</td>
		<td class=whitetablebg colspan="7">
            <input type="radio" id=tfop1_mod_agttypeC name=tfop1_mod_agttype value="C">變更
            <input type="radio" id=tfop1_mod_agttypeA name=tfop1_mod_agttype value="A">新增
            <input type="radio" id=tfop1_mod_agttypeD name=tfop1_mod_agttype value="D">撤銷
		</td>
	</tr>	
	<tr>
		<td class="lightbluetable" colspan=8 valign="top" STYLE="cursor:pointer;COLOR:BLUE" onclick="PMARK(c21Appl_name)"><strong>壹、<u>註冊號數、商標(標章)種類及名稱</u></strong></td>
	</tr>
	<tr>
		<td class=lightbluetable align=right >商標種類：</td>
		<td class=whitetablebg colspan="7">
			<input type=radio name=fr21_S_Mark value="" onclick="dmt_form.change_mark(1, this)">商標
			<input type=radio name=fr21_S_Mark value="S" onclick="dmt_form.change_mark(1, this)">92年修正前服務標章
			<input type=radio name=fr21_S_Mark value="N" onclick="dmt_form.change_mark(1, this)">團體商標
			<input type=radio name=fr21_S_Mark value="M" onclick="dmt_form.change_mark(1, this)">團體標章
			<input type=radio name=fr21_S_Mark value="L" onclick="dmt_form.change_mark(1, this)">證明標章
		</TD>
	</tr>
	<tr>
		<td colspan=8 class="sfont9">
		<TABLE border=0 class="bluetable"  cellspacing=1 cellpadding=2 width="100%">
		<tr>	
			<td class="lightbluetable" align="right" width="23%">此次變更總件數：</td>
			<td class="whitetablebg" colspan="7" >共<input type="text" id=tot_num21 name=tot_num21 size=2 onchange="br_form.Add_FC21(this.value)">件
				<input type=hidden id=count211 name=count211 value="0">
				<input type=hidden id=ctrlcnt211 name=ctrlcnt211 value="">
				<input type=hidden id=cnt211 name=cnt211 value="0"><!--畫面上有幾筆-->
			</td>
		</tr>
		</table>
		</td>
	</tr>
	<tr>
		<td colspan=8 class="sfont9">
		<TABLE id=tabbr211 border=0 class="bluetable"  cellspacing=1 cellpadding=2 width="100%">
        <thead>
		    <tr>	
			    <td class="lightbluetable" align="right"><font color="red">(主)</font>案件編號1:</td>
			    <td class="whitetablebg" colspan="7" >
                    <input type="text" id=dseqb_1 name=dseqb_1 size=5  maxlength=5 onblur="br_form.seqChange('b_1')">-<input type="text" id=dseq1b_1 name=dseq1b_1 size=1  maxlength=1 value="_" onblur="br_form.seqChange('b_1')">
                    <input type=button class="cbutton" id="btndseq_okb_1" name="btndseq_okb_1" value ="確定" onclick="delayNO(reg.dseqb_1.value,reg.dseq1b_1.value)">
                    <input type=radio value=NN id="case_stat1b_1NN" name="case_stat1b_1" onclick="br_form.case_stat1_control('NN','b_1')">新案
                    <input type=radio value=OO id="case_stat1b_1OO" name="case_stat1b_1" onclick="br_form.case_stat1_control('OO','b_1')">舊案
                    <input type=button class="cbutton" id="btnQueryb_1" name="btnQueryb_1" value ="查詢主案件編號" onclick="br_form.btnQueryclick('b_1',reg.F_cust_seq.value)">
                    <input type=button class="cbutton" id="btncaseb_1" name="btncaseb_1" value ="案件主檔查詢" onclick="br_form.btncaseclick('b_1')">
                    <input type="hidden" id=keydseqb_1 name=keydseqb_1 value="N">
			    </td>
		    </tr>
		    <tr>	
			    <td class="lightbluetable" align="right"><font color="red">(主)</font>商標種類1:</td>
			    <td class="whitetablebg" colspan="7"><input type="text" id=s_markb_1 name=s_markb_1 size=50 maxlength=50  readonly class=SEdit></td>
		    </tr>		
		    <tr>	
			    <td class="lightbluetable" align="right"><font color="red">(主)</font>商標/標章名稱1:</td>
			    <td class="whitetablebg" colspan="7"><input type="text" id=appl_nameb_1 name=appl_nameb_1 size=50 maxlength=50 readonly class=SEdit></td>
		    </tr>		
		    <tr>	
			    <td class="lightbluetable" align="right"><font color="red">(主)</font>註冊號數1:</td>
			    <td class="whitetablebg" colspan="7"><input type="text" id=issue_nob_1 name=issue_nob_1 size=50 maxlength=50 readonly class=SEdit></td>
		    </tr>
        </thead>
        <tbody></tbody>
        <script type="text/html" id="br_fc21_template">
		    <tr class="trfc21_##">
			    <td class="lightbluetable" align="right">本所編號##:</td>
			    <td class="whitetablebg" colspan=3 >
					<input type=text id=dseqb_## name=dseqb_## size=5  maxlength=5 onblur="br_form.seqChange('b_##')" readonly>-<input type=text id=dseq1b_## name=dseq1b_## size=1  maxlength=1 value='_' onblur="br_form.seqChange('b_##')" readonly >
					<input type=button class='cbutton' id='btndseq_okb_##' name='btndseq_okb_##' value ='確定' onclick="br_form.btnseqclick('##', 'b_')">
					<input type=radio value=NN checked name='case_stat1b_##' id='case_stat1b_##NN' onclick="br_form.case_stat1_control('NN', 'b_##')">新案
                    <input type=radio value=OO name='case_stat1b_##' id='case_stat1b_##OO' onclick="br_form.case_stat1_control('OO', 'b_##')">舊案
					<input type=button class='cbutton' id='btnQueryb_##' name='btnQueryb_##' value ='查詢本所編號' onclick="br_form.btnQueryclick('b_##', reg.F_cust_seq.value)">
					<input type=button class='cbutton' id=btncaseb_## name=btncaseb_##  value ='案件主檔查詢' onclick="br_form.btncaseclick('b_##')">
					<input type=button class=cbutton id=btndmt_tempb_## name=btndmt_tempb_##  value ='案件主檔新增' onclick="br_form.btndmt_tempclick('b_##')">
					<input type=text id=keydseqb_## name=keydseqb_##>
					<input type=text id=case_sqlnob_## name=case_sqlnob_##>
					<input type=text id=submitTaskb_## name=submitTaskb_##>
			    </td>
		    </tr>
		    <tr class="trfc21_##">
			    <td class="lightbluetable" align="right">商標種類##:</td>
			    <td class="whitetablebg" colspan=3><input type=text id=s_markb_## NAME=s_markb_## size=30 readonly></td>
		    </tr>
		    <tr class="trfc21_##">
			    <td class="lightbluetable" align="right">商標/標章名稱##:</td>
			    <td class="whitetablebg" colspan=3><input type=text id=appl_nameb_## NAME=appl_nameb_## size=30 readonly></td>
		    </tr>
		    <tr class="trfc21_##">
			    <td class="lightbluetable" align="right">申請號數##:</td>
			    <td class="whitetablebg" colspan=3><input type=text id=apply_nob_## NAME=apply_nob_## size=30 readonly></td>
		    </tr>
        </script>
		</table>
		</td>
	</tr>
	<tr>
		<td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:pointer;COLOR:BLUE" onclick="PMARK(c2Other)"><strong>肆、<u>變更事項(未變更者免填)</u></strong></td>
	</tr>
	<tr>
		<td class=lightbluetable align=right ></td>
		<td class=whitetablebg colspan="7"><input type="hidden" id="tfop1_mod_ap" name="tfop1_mod_ap">
		    <INPUT type="checkbox" name="tfop1_mod_ap" value="Y" onclick="br_form.Cul_DmtTran('tfop1_mod_ap','tfg2_mod_ap')">申請人中文名稱
		    <INPUT type="checkbox" name="tfop1_mod_ap" value="Y" onclick="br_form.Cul_DmtTran('tfop1_mod_ap','tfg2_mod_ap')">申請人英文名稱
		    <INPUT type="checkbox" name=tfop1_mod_apaddr value="Y" onclick="br_form.Cul_DmtTran('tfop1_mod_apaddr','tfg2_mod_apaddr')">申請人中文地址
		    <INPUT type="checkbox" name="tfop1_mod_oth" value="Y" onclick="br_form.Cul_DmtTran('tfop1_mod_oth','tfg2_mod_oth')">申請人印章
		</td>
	</tr>	
	<tr>
		<td class=lightbluetable align=right ></td>
		<td class=whitetablebg colspan="7">	
		    <INPUT type="checkbox" name=tfop1_mod_apaddr value="Y" onclick="br_form.Cul_DmtTran('tfop1_mod_apaddr','tfg2_mod_apaddr')">申請人英文地址
		    <INPUT type="checkbox" name=tfop1_mod_aprep value="Y" onclick="br_form.Cul_DmtTran('tfop1_mod_aprep','tfg2_mod_aprep')">代表人中文名稱
		    <INPUT type="checkbox" name=tfop1_mod_aprep value="Y" onclick="br_form.Cul_DmtTran('tfop1_mod_aprep','tfg2_mod_aprep')">代表人英文名稱
		    <INPUT type="checkbox" name=tfop1_mod_oth1 value="Y" onclick="br_form.Cul_DmtTran('tfop1_mod_oth1','tfg2_mod_oth1')">代表人印章
		</td>
	</tr>
	<tr>
		<td class=lightbluetable align=right ></td>
		<td class=whitetablebg colspan="7">
            <input type="checkbox" id=tfop1_mod_claim1 name=tfop1_mod_claim1 value="Y" onclick="br_form.clearmod1(2)">選定代表人
            <input type="hidden" id=ttg21_ncname2 name=ttg21_ncname2 ></td>
	</tr>
	<tr>
		<td class=lightbluetable align=right ></td>
		<td class=whitetablebg colspan="7">
            <input type="checkbox" id=tfop1_mod_dmt name=tfop1_mod_dmt value="Y" onclick="br_form.clearmod1(1)">變更商標(標章)名稱：<input type="text" id=ttg21_ncname1 name=ttg21_ncname1></td>
	</tr>
	<tr>
		<td class=lightbluetable align=right ></td>
		<td class=whitetablebg colspan="7"><input type="checkbox" id=tfop1_oitem1 name=tfop1_oitem1 value="Y" >修正使用規範書：
			<input type="radio" id=tfop1_oitem1cN name=tfop1_oitem1c value="N">團體商標
			<input type="radio" id=tfop1_oitem1cM name=tfop1_oitem1c value="M">團體標章
			<input type="radio" id=tfop1_oitem1cL name=tfop1_oitem1c value="L">證明標章
		</td>
	</tr>
	<tr>
		<td class=lightbluetable align=right ></td>
		<td class=whitetablebg colspan="7"><input type="checkbox" id=tfop1_mod_claim2 name=tfop1_mod_claim2 value="Y" onclick="br_form.clearmod1(3)">質權人名稱、地址、代表人及印章變更</td>
	</tr>
	<tr>
		<td class=lightbluetable align=right ></td>
		<td class=whitetablebg colspan="7"><input type="checkbox" id=tfop1_oitem2 name=tfop1_oitem2 value="Y" >質權移轉：擔保債權移轉原因
			<input type="radio" id=tfop1_oitem2cA name=tfop1_oitem2c value="A">有償讓與
			<input type="radio" id=tfop1_oitem2cB name=tfop1_oitem2c value="B">無償讓與
			<input type="radio" id=tfop1_oitem2cC name=tfop1_oitem2c value="C">繼承
			<input type="radio" id=tfop1_oitem2cD name=tfop1_oitem2c value="D">其他法定移轉
		</td>
	</tr>
		<tr>
			<td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:pointer;COLOR:BLUE" onclick="PMARK(zAttech)"><strong><u>附件：</u></strong></td>
		</tr>			
		<tr class="br_attchstr">
			<td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttz21_Z1" NAME="ttz21_Z1" value="Z1" onclick="br_form.AttachStr('.br_attchstr','ttz21_',reg.tfzd_remark1)"></td>
			<td class="whitetablebg" colspan="7">公司變更登記事項卡影本或其他法人證明文件(<input TYPE="checkbox" id="ttz21_Z1C" NAME="ttz21_Z1C" value="Z1C" onclick="br_form.AttachStr('.br_attchstr','ttz21_',reg.tfzd_remark1)">附中譯本)。)</td>
		</tr>
		<tr class="br_attchstr">
			<td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttz21_Z3" NAME="ttz21_Z3" value="Z3" onclick="br_form.AttachStr('.br_attchstr','ttz21_',reg.tfzd_remark1)"></td>
			<td class="whitetablebg" colspan="7">戶口謄本。</td>
		</tr>
		<tr class="br_attchstr">
			<td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttz21_Z2" NAME="ttz21_Z2" value="Z2" onclick="br_form.AttachStr('.br_attchstr','ttz21_',reg.tfzd_remark1)"></td>
			<td class="whitetablebg" colspan="7">委任書(<input TYPE="checkbox" id="ttz21_Z2C" NAME="ttz21_Z2C" value="Z2C" onclick="br_form.AttachStr('.br_attchstr','ttz21_',reg.tfzd_remark1)">附中譯本)。)</td>
		</tr>
		<tr class="br_attchstr">
			<td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttz21_Z4" NAME="ttz21_Z4" value="Z4" onclick="br_form.AttachStr('.br_attchstr','ttz21_',reg.tfzd_remark1)"></td>
			<td class="whitetablebg" colspan="7">使用規範書(<input TYPE="checkbox" id="ttz21_Z4C" NAME="ttz21_Z4C" value="Z4C" onclick="br_form.AttachStr('.br_attchstr','ttz21_',reg.tfzd_remark1)">附中文譯本或應記載事項之中文節譯本)。</td>
		</tr>
		<tr class="br_attchstr">
			<td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttz21_Z5" NAME="ttz21_Z5" value="Z5" onclick="br_form.AttachStr('.br_attchstr','ttz21_',reg.tfzd_remark1)"></td>
			<td class="whitetablebg" colspan="7">使用規範書之電子檔光碟片(<input TYPE="checkbox" id="ttz21_Z5C" NAME="ttz21_Z5C" value="Z5C" onclick="br_form.AttachStr('.br_attchstr','ttz21_',reg.tfzd_remark1)">附中文譯本或應記載事項之中文節譯本)。</td>
		</tr>
		<tr class="br_attchstr">
			<td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttz21_Z6" NAME="ttz21_Z6" value="Z6" onclick="br_form.AttachStr('.br_attchstr','ttz21_',reg.tfzd_remark1)"></td>
			<td class="whitetablebg" colspan="7">全體共有人同意書。</td>
		</tr>
		<tr class="br_attchstr">
			<td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttz21_Z7" NAME="ttz21_Z7" value="Z7" onclick="br_form.AttachStr('.br_attchstr','ttz21_',reg.tfzd_remark1)"></td>
			<td class="whitetablebg" colspan="7">讓與債權時，質權隨同移轉，應檢附下列證明文件：</td>
		</tr>
		<tr class="br_attchstr">
			<td class="lightbluetable" align="right"></td>
			<td class="whitetablebg" colspan="7"><input TYPE="checkbox" id="ttz21_Z71" NAME="ttz21_Z71" value="Z71" onclick="br_form.AttachStr('.br_attchstr','ttz21_',reg.tfzd_remark1)">
			擔保債權有償讓與：應檢附擔保債權讓與契約書(<input TYPE="checkbox" id="ttz21_Z71C" NAME="ttz21_Z71C" value="Z71C" onclick="br_form.AttachStr('.br_attchstr','ttz21_',reg.tfzd_remark1)">附中文譯本)。
			</td>
		</tr>
		<tr class="br_attchstr">
			<td class="lightbluetable" align="right"></td>
			<td class="whitetablebg" colspan="7"><input TYPE="checkbox" id="ttz21_Z72" NAME="ttz21_Z72" value="Z72" onclick="br_form.AttachStr('.br_attchstr','ttz21_',reg.tfzd_remark1)">
			擔保債權無償讓與，應檢附擔保債權無償讓與契約書(<input TYPE="checkbox" id="ttz21_Z72C" NAME="ttz21_Z72C" value="Z72C" onclick="br_form.AttachStr('.br_attchstr','ttz21_',reg.tfzd_remark1)">附中文譯本)，<br>稽徵機關核發之稅款繳清證明書，或核定免稅證明書，或不計入贈與總額證明書，或同意移轉證明書之副本，或稽徵機關核發之其他證明文件。
			</td>
		</tr>
		<tr class="br_attchstr">
			<td class="lightbluetable" align="right"></td>
			<td class="whitetablebg" colspan="7"><input TYPE="checkbox" id="ttz21_Z73" NAME="ttz21_Z73" value="Z73" onclick="br_form.AttachStr('.br_attchstr','ttz21_',reg.tfzd_remark1)">
			擔保債權繼承移轉，應檢附質權人死亡證明、質權人全戶戶籍謄本(由繼承人具結係全戶謄本)、質權歸屬證明或其他繼承證明文件(<input TYPE="checkbox" id="ttz21_Z73C" NAME="ttz21_Z73C" value="Z73C" onclick="br_form.AttachStr('.br_attchstr','ttz21_',reg.tfzd_remark1)">附中文譯本)，<br>稽徵機關核發之稅款繳清證明書，或核定免稅證明書，或不計入遺產總額證明書，或同意移轉證明書之副本，或稽徵機關核發之其他證明文件。
			</td>
		</tr>	
		<tr class="br_attchstr">
			<td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttz21_Z9" NAME="ttz21_Z9" value="Z9" onclick="br_form.AttachStr('.br_attchstr','ttz21_',reg.tfzd_remark1)"></td>
			<td class="whitetablebg" colspan="7">其他。<input TYPE="text" id="ttz21_Z9t" NAME="ttz21_Z9t" SIZE="50" onchange="br_form.AttachStr('.br_attchstr','ttz21_',reg.tfzd_remark1)"></td>
		</tr>
		<tr style="display:none">
		  <td class=lightbluetable  ROWSPAN=2 ><strong>附註：</strong></td>
			<td class=whitetablebg colspan=7>本件商標(標章)於<INPUT type=text id=O_item211 name=O_item211 size=10 class="dateField">(年/月/日)</td>
		</tr>
		<tr style="display:none">		  
			<td class=whitetablebg colspan=7>另案辦理<INPUT type="radio" id=O_item221FT1 name=O_item221 value="FT1" onclick="reg.O_item231.value=''">移轉案
													 <INPUT type="radio" id=O_item221FL1 name=O_item221 value="FL1" onclick="reg.O_item231.value=''">授權案
													 <INPUT type="radio" id=O_item221FI1 name=O_item221 value="FI1" onclick="reg.O_item231.value=''">補證案
													 <INPUT type="radio" id=O_item221FR1 name=O_item221 value="FR1" onclick="reg.O_item231.value=''">延展案
													 <INPUT type="radio" id=O_item221ZZ name=O_item221 value="ZZ">其他<input type="text" id="O_item231" name="O_item231" value="" size=10 onchange="reg.O_item221(4).checked=true">案
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

    br_form.clearmod1 = function (x) {
        if (x == 1) {
            if ($("#tfop1_mod_dmt").prop("checked") == true) {
                $("#tfg2_mod_dmt").val("Y");
            } else {
                $("#tfg2_mod_dmt").val("N");
                $("#ttg2_ncname1").val("");
            }
        } else if (x == 3) {
            if ($("#tfop1_mod_claim2").prop("checked") == true) {
                $("#tfg2_mod_claim2").val("Y");
            } else {
                $("#tfg2_mod_claim2").val("N");
                $("#ttg2_ncname1").val("");
            }
        } else {
            if ($("#tfop1_mod_claim1").prop("checked") == true) {
                $("#tfg2_mod_claim1").val("Y");
            } else {
                $("#tfg2_mod_claim1").val("N");
            }
        }
    }

    br_form.Cul_DmtTran = function (src, tar) {
        var nclass = $("input[name='" + src + "']").map(function (index) {
            return ($(this).prop("checked") == true ? "Y" : "N");
        });

        $("#" + tar).val().get().join('');
    }

    //*****共N件
    br_form.Add_FC21 = function (arcaseCount) {
        if (arcaseCount > 50) {
            alert("變更案件數不可超過50筆");
            $("#tot_num11").val("1").focus();
            return false;
        }

        var doCount = CInt(arcaseCount);//要改為幾筆
        var cnt211 = Math.max(1, CInt($("#cnt211").val()));//目前畫面上有幾筆,最少是1
        if (doCount > cnt211) {//要加
            for (var nRow = cnt211; nRow < doCount ; nRow++) {
                var copyStr = $("#br_fc21_template").text() || "";
                copyStr = copyStr.replace(/##/g, nRow + 1);
                if (nRow % 2 != 0) copyStr = copyStr.replace(/whitetablebg/g, "greentablebg");
                $("#tabbr211 tbody").append(copyStr);
                if (nRow % 2 != 0) {
                    $(".trfc21_" + (nRow + 1) + " input[type=text]").attr("class", "sedit2");
                } else {
                    $(".trfc21_" + (nRow + 1) + " input[type=text]").attr("class", "SEdit");
                }
                $("#submitTaskb_" + (nRow + 1)).val(main.submittask);
                $("#cnt211").val(nRow + 1);
            }
        } else {
            //要減
            for (var nRow = cnt211; nRow > doCount ; nRow--) {
                $('.trfc21_' + nRow).remove();
                $("#cnt211").val(nRow - 1);
            }
        }
    }

    //新/舊案
    br_form.case_stat1_control = function (stat, fld) {
        if (stat == "NN") {
            $("#btndseq_ok" + fld).hide();//[確定]
            $("#btnQuery" + fld).hide();//[查詢本所編號]
            $("#btncase" + fld).hide();//[案件主檔查詢]
            if (fld != "a_1" && fld != "b_1") {//不是主案
                $("#btndmt_temp" + fld).show();//[案件主檔新增]
            }
            if (CInt(fld.substr(2)) % 2 == 0) {
                $("#dseq" + fld).attr("class", "sedit2").prop("readonly", true).val("");
                $("#dseq1" + fld).attr("class", "sedit2").prop("readonly", true).val("_");
            } else {
                $("#dseq" + fld).attr("class", "SEdit").prop("readonly", true).val("");
                $("#dseq1" + fld).attr("class", "SEdit").prop("readonly", true).val("_");
            }
            $("#apply_no" + fld).val("");
            $("#issue_no" + fld).val("");
            $("#s_mark" + fld).val("");
            $("#appl_name" + fld).val("");
            if (fld == "a_1" || fld == "b_1") {//是主案
                $("#tfy_case_stat").val("NN");
                $("#keyseq").val("N");
                $("#btnseq_ok").unlock();
                $("#old_seq").val("");
                $("#old_seq1").val("_");
                dmt_form.new_oldcase();
                alert("請至案件主檔填寫新案內容!!");
                settab("#dmt");
            }
        } else if (stat == "OO") {
            if (fld != "a_1" && fld != "b_1") {//不是主案
                $("#btndmt_temp" + fld).hide();//[案件主檔新增]
            }
            $("#btndseq_ok" + fld).show();//[確定]
            $("#btnQuery" + fld).show();//[查詢本所編號]
            $("#btncase" + fld).show();//[案件主檔查詢]
            $("#dseq" + fld).attr("class", "").prop("readonly", false).val("");
            $("#dseq1" + fld).attr("class", "").prop("readonly", false).val("_");
            $("#apply_no" + fld).val("");
            $("#issue_no" + fld).val("");
            $("#s_mark" + fld).val("");
            $("#appl_name" + fld).val("");
            if (fld == "a_1" && fld == "b_1") {//是主案
                $("#tfy_case_stat").val("OO");
                dmt_form.new_oldcase();
            }
        }
    }

    //副案[案件主檔新增]
    br_form.btndmt_tempclick = function (num) {
        var cust_area = $("#F_cust_area").val();
        var cust_seq = $("#F_cust_seq").val();
        var in_scode = $("#F_tscode").val();
        var case_sqlno = $("#case_sqlno" + num).val();
        var task = $("#submitTask" + num).val();
        var arcase = $("#tfy_Arcase").val();
        if (in_scode == "") {
            alert("請先輸入洽案營洽!!!");
            settab("#case");
            $("#F_tscode").focus();
            return false;
        } else {
            var tot_num = $("#tot_num21").val();
            if ($("#prgid").val() != "brt52") {
                //***todo
                window.open("Brt11Addtemp.asp?cust_area=" + cust_area + "&cust_seq=" + cust_seq + "&in_scode=" + in_scode + "&num=" + num + "&SubmitTask=" + task + "&arcase=" + arcase, "myWindowOne", "width=700 height=450 top=40 left=50 toolbar=no, menubar=no, location=no, directories=no resizeable=no status=no scrollbars=yes");
            } else {
                window.open("Brt11Addtemp.asp?cust_area=" + cust_area + "&cust_seq=" + cust_seq + "&in_scode=" + in_scode + "&num=" + num + "&case_sqlno=" + case_sqlno + "&Lock=show&arcase=" + arcase, "myWindowOne", "width=700 height=450 top=40 left=50 toolbar=no, menubar=no, location=no, directories=no resizeable=no status=no scrollbars=yes");
            }
        }
    }

    //副案[確定]
    br_form.btnseqclick = function (nRow, fld) {
        var value1 = $("#dseq" + fld + nRow).val();
        var value2 = $("#dseq1" + fld + nRow).val();
        if (value1 != "") {
            $("#case_stat1" + fld + nRow + "OO").prop("checked", true);//舊案
            $("#btndmt_temp" + fld + nRow).hide();//[案件主檔新增]
            $("#btncase" + fld + nRow).show();//[案件主檔查詢]
            $("#btnQuery" + fld + nRow).show();//[查詢本所編號]
            var objCase = {};
            for (var r = 2; r <= CInt(nRow) ; r++) {
                var lineCase = value1 + value2;
                if (lineCase != "_" && objCase[lineCase]) {
                    alert("變更本所編號(" + r + ")重覆,請重新輸入！！");
                    settab("#tran");

                    $("#keydseq" + fld + r).val("N");
                    $("#btndseq_ok" + fld + r).prop("disabled", false);
                    $("#dseq" + fld + r).focus();
                    return false;
                } else {
                    objCase[lineCase] = { flag: true, idx: r };
                }
            }

            var lname = $("#old_seq").val() + $("#old_seq1").val();
            var kname = value1 + value2;
            if (lname != "_" && kname != "_") {
                if (lname == kname) {
                    alert("變更本所編號" + r + "與主要的本所編號重覆,請重新輸入!!!");
                    settab("#tran");
                    $("#keydseq" + fld + r).val("N");
                    $("#btndseq_ok" + fld + r).prop("disabled", false);
                    $("#dseq" + fld + r).focus();
                    return false;
                }
            }
        }
        if (value1 != "") {
            if (chkNum(value1, "本所編號")) return false;
            var purl = getRootPath() + "/ajax/json_dmt.aspx?seq=" + value1 + "&seq1=" + value2 + "&cust_area=" + $("#tfy_cust_area").val() + "&cust_seq=" + $("#tfy_cust_seq").val();
            $.ajax({
                type: "get",
                url: purl,
                async: false,
                cache: false,
                success: function (json) {
                    //if ($("#chkTest").prop("checked")) toastr.info("<a href='" + this.url + "' target='_new'>Debug(_apcust交辦申請人)！<BR><b><u>(點此顯示詳細訊息)</u></b></a>");
                    var dmt_list = $.parseJSON(json);
                    if (dmt_list.length > 0) {
                        var backflag_fldname = "A9Z";
                        $("#s_mark" + fld + nRow).val(dmt_list[0].smarknm);
                        $("#appl_name" + fld + nRow).val(dmt_list[0].appl_name);
                        $("#apply_no" + fld + nRow).val(dmt_list[0].apply_no);
                        $("#issue_no" + fld + nRow).val(dmt_list[0].issue_no);
                        //2011/2/8因應復案修改，提醒結案是否要復案
                        if (dmt_list[0].end_date != "") {
                            if ($("#" + backflag_fldname + "_end_flag").prop("checked") == true) {
                                alert("該案(" + value1 + "-" + value2 + ")已結案且主案要復案，程序客收確認後將會一併復案。");
                            } else {
                                if (confirm("該案件已結案，如確定要交辦則需註記是否復案，請問是否復案？")) {
                                    $("#" + backflag_fldname + "_back_flag").prop("checked", true);
                                } else {
                                    $("#" + backflag_fldname + "_back_flag").prop("checked", false);
                                }
                                dmt_form.get_backdata(backflag_fldname);
                            }
                        }
                    } else {
                        alert("該客戶無此案件編號");
                        $("#dseq" + fld + nRow).unlock().val("").focus();
                        $("#dseq1" + fld + nRow).unlock().val("_");
                        $("#s_mark" + fld + nRow).val("");
                        $("#appl_name" + fld + nRow).val("");
                        $("#apply_no" + fld + nRow).val("");
                        $("#issue_no" + fld + nRow).val("");
                    }
                },
                error: function (xhr) {
                    $("#dialog").html("<a href='" + this.url + "' target='_new'>check案件結案資料失敗！<u>(點此顯示詳細訊息)</u></a><hr>" + xhr.responseText);
                    $("#dialog").dialog({ title: 'check案件結案資料失敗！', modal: true, maxHeight: 500, width: "90%" });
                }
            });
            $("#keydseq" + fld + nRow).val("Y");
            $("#btndseq_ok" + fld + nRow).prop("disabled", true);
        } else {
            alert("請先輸入本所編號!!!");
            $("#dseqb_" + nRow).focus();
            return false;
        }
    }

    //[查詢本所編號]
    br_form.btnQueryclick = function (tot_num, cust_seq) {
        $("#dseq" + tot_num).attr("class", "").prop("readonly", false);
        $("#dseq1" + tot_num).attr("class", "").prop("readonly", false);
        $("#btndseq_ok" + tot_num).show();//[確定]
        $("#case_stat1" + fld + nRow + "OO").prop("checked", true);//舊案
        if (fld == "a_1" || fld == "b_1") {//是主案
            Filereadonly();
        }
        //***todo
        window.open("..\brtam\brta21Query.aspx?cust_seq=" + cust_seq + "&tot_num=" + tot_num, "myWindowOne", "width=650 height=420 top=40 left=80 toolbar=no, menubar=no, location=no, directories=no resizeable=no status=no scrollbars=yes");
    }

    //[案件主檔查詢]
    br_form.btncaseclick = function (nRow) {
        var value1 = $("#dseq" + nRow).val();
        var value2 = $("#dseq1" + nRow).val();
        if (value1 == "") {
            alert("請先輸入本所編號!!!");
            $("#dseq" + nRow).focus();
            return false;
        } else {
            //***todo
            var url = getRootPath() + "/brt5m/brt15ShowFP.asp?seq=" + value1 + "&seq1=" + value2 + "&submittask=Q";
            window.showModalDialog(url, "", "dialogHeight: 540px; dialogWidth: 800px; center: Yes;resizable: No; status: No;scrollbars:yes");
        }
    }

    br_form.seqChange = function (nRow) {
        $("#keydseq" + nRow).val("N")//有變動給N
        $("#btndseq_ok" + nRow).prop("disabled", false);
    }

    //交辦內容綁定
    br_form.bindFC21 = function () {
        console.log("fc21.br_form.bind");
        if (jMain.case_main.length == 0) {
        } else {
        }
    }
</script>
