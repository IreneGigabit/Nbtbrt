<%@ Control Language="C#" ClassName="FC11form" %>
<%@ Import Namespace = "System.Collections.Generic"%>

<script runat="server">
    //A6變更案交辦內容
    //父控制項傳入的參數
    public Dictionary<string, string> Lock = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    
    protected string prgid = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string SQL = "";

    protected string ttg11_agt_no = "";
    
    private void Page_Load(System.Object sender, System.EventArgs e) {
        PageLayout();
        this.DataBind();
    }
    
    private void PageLayout() {
        //代理人
        ttg11_agt_no = Sys.getAgent().Option("{agt_no}", "{agt_no}_{agt_namefull}", " v1='{agt_name1}' {selected}", true);
    }
</script>

<div id="div_Form_FC11">
<%=Sys.GetAscxPath(this)%>
<TABLE border=0 class=bluetable cellspacing=1 cellpadding=2 width="100%">
	<tr>
		<td class="lightbluetable" valign="top"><strong>※、代理人(代碼)</strong></td>
		<td class="whitetablebg" colspan="7" valign="top">
		    <select id="ttg11_agt_no" NAME="ttg11_agt_no"><%#ttg11_agt_no%></select>
		</td>
	</tr>
	<tr>
		<td class="lightbluetable" colspan=8 valign="top" STYLE="cursor:pointer;COLOR:BLUE" onclick="PMARK(c1Appl_name)"><strong>壹、<u>註冊號數、商標(標章)種類及名稱</u></strong></td>
	</tr>
	<tr>
		<td class=lightbluetable align=right >商標種類：</td>
		<td class=whitetablebg colspan="7">
			<input type=radio name=fr11_S_Mark class="onoff" value="" onclick="dmt_form.change_mark(1, this)">商標
			<span id="fr11_SmarkS" style="display:none">
			<input type=radio name=fr11_S_Mark class="onoff" value="S" onclick="dmt_form.change_mark(1, this)">92年修正前服務標章
			</span>
			<input type=radio name=fr11_S_Mark class="onoff" value="N" onclick="dmt_form.change_mark(1, this)">團體商標
			<input type=radio name=fr11_S_Mark class="onoff" value="M" onclick="dmt_form.change_mark(1, this)">團體標章
			<input type=radio name=fr11_S_Mark class="onoff" value="L" onclick="dmt_form.change_mark(1, this)">證明標章
		</TD>
	</tr>
	<tr>
		<td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:pointer;COLOR:BLUE" onclick="PMARK(c1Mod)"><strong>貳、<u>變更事項</u></strong></td>
	</tr>
	<tr>
		<td class=lightbluetable align=right></td>
		<td class=whitetablebg colspan="7">
            <input type="checkbox" name="tfzr1_mod_ap">申請人名稱&nbsp;&nbsp;&nbsp;&nbsp;
            <input type="checkbox" name="tfzr1_mod_aprep">代表人&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <input type="checkbox" name="tfzr1_mod_agt">代理人
		</TD>
	</tr>
	<tr>
		<td class=lightbluetable align=right></td>
		<td class=whitetablebg colspan="7">
            <input type="checkbox" name="tfzr1_mod_apaddr">申請人地址&nbsp;&nbsp;&nbsp;&nbsp;
            <input type="checkbox" name="tfzr1_mod_agtaddr">代理人地址
			<input type="checkbox" name="tfzr1_mod_claim1">選定代表人
		</TD>
	</tr>
	<tr>
		<td class=lightbluetable align=right></td>
		<td class=whitetablebg colspan="7">
            <input type="checkbox" name="tfzr1_mod_oth">申請人印鑑&nbsp;&nbsp;&nbsp;&nbsp;
            <input type="checkbox" name="tfzr1_mod_oth1">代表人印鑑&nbsp;
            <input type="checkbox" name="tfzr1_mod_oth2">代理人印鑑
		</TD>
	</tr>
	<tr>
		<td colspan=8 class="sfont9">
		<TABLE border=0 class="bluetable"  cellspacing=1 cellpadding=2 width="100%">
		<tr>	
			<td class="lightbluetable" align="right" width="23%">此次變更總件數：</td>
			<td class="whitetablebg" colspan="7" >共<input type="text" id=tot_num11 name=tot_num11 size=2 onchange="br_form.Add_FC11(this.value)">件
				<input type=hidden id=count111 name=count111 value="0">
				<input type=hidden id=ctrlcnt111 name=ctrlcnt111 value="">
				<input type=text id=cnt111 name=cnt111 value="0"><!--畫面上有幾筆-->
				<input type=hidden id=nfy_tot_num name=nfy_tot_num value="0">
			</td>
		</tr>
		</table>
		</td>
	</tr>
	<tr>
		<td colspan=8 class="sfont9">
		<TABLE id=tabbr111 border=0 class="bluetable"  cellspacing=1 cellpadding=2 width="100%">
        <thead>
		    <tr>	
			    <td class="lightbluetable" align="right"><font color="red">(主)</font>案件編號1:</td>
			    <td class="whitetablebg" colspan="7" >
                    <input type="text" id=dseqa_1 name=dseqa_1 size=5  maxlength=5 onblur="br_form.seqChange('a_1')">-<input type="text" id=dseq1a_1 name=dseq1a_1 size=1  maxlength=1 value="_" onblur="br_form.seqChange('a_1')">
                    <input type=button class="cbutton" id="btndseq_oka_1" name="btndseq_oka_1" value ="確定" onclick="delayNO(reg.dseqa_1.value,reg.dseq1a_1.value)">
                    <input type=radio value=NN id="case_stat1a_1NN" name="case_stat1a_1" onclick="br_form.case_stat1_control('NN','a_1')">新案
                    <input type=radio value=OO id="case_stat1a_1OO" name="case_stat1a_1" onclick="br_form.case_stat1_control('OO','a_1')">舊案
                    <input type=button class="cbutton" id="btnQuerya_1" name="btnQuerya_1" value ="查詢主案件編號" onclick="br_form.btnQueryclick('a_1',reg.F_cust_seq.value)">
                    <input type=button class="cbutton" id="btncasea_1" name="btncasea_1" value ="案件主檔查詢" onclick="br_form.btncaseclick('a_1')">
                    <input type="hidden" id=keydseqa_1 name=keydseqa_1 value="N">
			    </td>
		    </tr>
		    <tr>	
			    <td class="lightbluetable" align="right"><font color="red">(主)</font>商標種類1:</td>
			    <td class="whitetablebg" colspan="7"><input type="text" id=s_marka_1 name=s_marka_1 size=50 maxlength=50  readonly class=sedit></td>
		    </tr>		
		    <tr>	
			    <td class="lightbluetable" align="right"><font color="red">(主)</font>商標/標章名稱1:</td>
			    <td class="whitetablebg" colspan="7"><input type="text" id=appl_namea_1 name=appl_namea_1 size=50 maxlength=50 readonly class=sedit></td>
		    </tr>		
		    <tr>	
			    <td class="lightbluetable" align="right"><font color="red">(主)</font>申請號數1:</td>
			    <td class="whitetablebg" colspan="7"><input type="text" id=apply_noa_1 name=apply_noa_1 size=50 maxlength=50 readonly class=sedit></td>
		    </tr>
        </thead>
        <tbody></tbody>
        <script type="text/html" id="br_fc11_template">
		    <tr class="trfc11_##">
			    <td class="lightbluetable" align="right">本所編號##:</td>
			    <td class="whitetablebg" colspan=3 >
					<input type=text id=dseqa_## name=dseqa_## size=5  maxlength=5 onblur="br_form.seqChange('a_##')" readonly>-<input type=text id=dseq1a_## name=dseq1a_## size=1  maxlength=1 value='_' onblur="br_form.seqChange('a_##')" readonly >
					<input type=button class='cbutton' id='btndseq_oka_##' name='btndseq_oka_##' value ='確定' onclick="br_form.btnseqclick('##', 'a_')">
					<input type=radio value=NN checked name='case_stat1a_##' id='case_stat1a_##NN' onclick="br_form.case_stat1_control('NN', 'a_##')">新案
                    <input type=radio value=OO name='case_stat1a_##' id='case_stat1a_##OO' onclick="br_form.case_stat1_control('OO', 'a_##')">舊案
					<input type=button class='cbutton' id='btnQuerya_##' name='btnQuerya_##' value ='查詢本所編號' onclick="br_form.btnQueryclick('a_##', reg.F_cust_seq.value)">
					<input type=button class='cbutton' id=btncasea_## name=btncasea_##  value ='案件主檔查詢' onclick="br_form.btncaseclick('a_##')">
					<input type=button class=cbutton id=btndmt_tempa_## name=btndmt_tempa_##  value ='案件主檔新增' onclick="br_form.btndmt_tempclick('a_##')">
					<input type=text id=keydseqa_## name=keydseqa_##>
					<input type=text id=case_sqlnoa_## name=case_sqlnoa_##>
					<input type=text id=submitTaska_## name=submitTaska_##>
			    </td>
		    </tr>
		    <tr class="trfc11_##">
			    <td class="lightbluetable" align="right">商標種類##:</td>
			    <td class="whitetablebg" colspan=3><input type=text id=s_marka_## NAME=s_marka_## size=30 readonly></td>
		    </tr>
		    <tr class="trfc11_##">
			    <td class="lightbluetable" align="right">商標/標章名稱##:</td>
			    <td class="whitetablebg" colspan=3><input type=text id=appl_namea_## NAME=appl_namea_## size=30 readonly></td>
		    </tr>
		    <tr class="trfc11_##">
			    <td class="lightbluetable" align="right">申請號數##:</td>
			    <td class="whitetablebg" colspan=3><input type=text id=apply_noa_## NAME=apply_noa_## size=30 readonly></td>
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
	<tr class="br_attchstrFC11">
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttz11_Z2" NAME="ttz11_Z2" value="Z2" onclick="br_form.AttachStr('.br_attchstrFC11','ttz11_',reg.tfzd_remark1)"></td>
		<td class="whitetablebg" colspan="7">委任書(<input TYPE="checkbox" id="ttz11_Z2C" NAME="ttz11_Z2C" value="Z2C" onclick="br_form.AttachStr('.br_attchstrFC11','ttz11_',reg.tfzd_remark1)">附中文譯本)。</td>
	</tr>
	<tr class="br_attchstrFC11">
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttz11_Z1" NAME="ttz11_Z1" value="Z1" onclick="br_form.AttachStr('.br_attchstrFC11','ttz11_',reg.tfzd_remark1)"></td>
		<td class="whitetablebg" colspan="7">變更證明文件。</td>
	</tr>
	<tr class="br_attchstrFC11">
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttz11_Z8" NAME="ttz11_Z8" value="Z8" onclick="br_form.AttachStr('.br_attchstrFC11','ttz11_',reg.tfzd_remark1)"></td>
		<td class="whitetablebg" colspan="7">移轉契約或其他移轉證明文件。</td>
	</tr>
	<tr class="br_attchstrFC11">
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttz11_Z3" NAME="ttz11_Z3" value="Z3" onclick="br_form.AttachStr('.br_attchstrFC11','ttz11_',reg.tfzd_remark1)"></td>
		<td class="whitetablebg" colspan="7">個人身分證影本。</td>
	</tr>
	<tr class="br_attchstrFC11">
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttz11_Z4" NAME="ttz11_Z4" value="Z4" onclick="br_form.AttachStr('.br_attchstrFC11','ttz11_',reg.tfzd_remark1)"></td>
		<td class="whitetablebg" colspan="7">法人公司執照影本。</td>
	</tr>
	<tr class="br_attchstrFC11">
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttz11_Z5" NAME="ttz11_Z5" value="Z5" onclick="br_form.AttachStr('.br_attchstrFC11','ttz11_',reg.tfzd_remark1)"></td>
		<td class="whitetablebg" colspan="7">身分或法人證明影本。</td>
	</tr>
	<tr class="br_attchstrFC11">
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttz11_Z6" NAME="ttz11_Z6" value="Z6" onclick="br_form.AttachStr('.br_attchstrFC11','ttz11_',reg.tfzd_remark1)"></td>
		<td class="whitetablebg" colspan="7">具結書。(印鑑遺失具結書)</td>
	</tr>
	<tr class="br_attchstrFC11">
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttz11_Z7" NAME="ttz11_Z7" value="Z7" onclick="br_form.AttachStr('.br_attchstrFC11','ttz11_',reg.tfzd_remark1)"></td>
		<td class="whitetablebg" colspan="7">全體共有人同意書。</td>
	</tr>
	<tr class="br_attchstrFC11">
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttz11_Z9" NAME="ttz11_Z9" value="Z9" onclick="br_form.AttachStr('.br_attchstrFC11','ttz11_',reg.tfzd_remark1)"></td>
		<td class="whitetablebg" colspan="7">其他證明文件。<input TYPE="text" id="ttz11_Z9t" NAME="ttz11_Z9t" SIZE="50" onchange="br_form.AttachStr('.br_attchstrFC11','ttz11_',reg.tfzd_remark1)"></td>
	</tr>
</table>	
</div>

<script language="javascript" type="text/javascript">
    //*****共N件
    br_form.Add_FC11 = function (arcaseCount) {
        if (arcaseCount > 50) {
            alert("變更案件數不可超過50筆");
            $("#tot_num11").val("1").focus();
            return false;
        }

        var doCount = CInt(arcaseCount);//要改為幾筆
        var cnt111 = Math.max(1, CInt($("#cnt111").val()));//目前畫面上有幾筆,最少是1
        if (doCount > cnt111) {//要加
            for (var nRow = cnt111; nRow < doCount ; nRow++) {
                var copyStr = $("#br_fc11_template").text() || "";
                copyStr = copyStr.replace(/##/g, nRow + 1);
                if (nRow % 2 != 0) copyStr = copyStr.replace(/whitetablebg/g, "greentablebg");
                $("#tabbr111 tbody").append(copyStr);
                if (nRow % 2 != 0) {
                    $(".trfc11_" + (nRow + 1) + " input[type=text]").attr("class", "sedit2");
                } else {
                    $(".trfc11_" + (nRow + 1) + " input[type=text]").attr("class", "SEdit");
                }
                $("#submitTaska_" + (nRow + 1)).val(main.submittask);
                $("#cnt111").val(nRow + 1);
            }
        } else {
            //要減
            for (var nRow = cnt111; nRow > doCount ; nRow--) {
                $('.trfc11_' + nRow).remove();
                $("#cnt111").val(nRow - 1);
            }
        }
    }

    //交辦內容綁定
    br_form.bindFC11 = function () {
        console.log("fc11.br_form.bind");
        if (jMain.case_main.length == 0) {
            $("#tot_num11,#nfy_tot_num").val("1").triggerHandler("change");
        } else {
            //代理人
            $("#ttg11_agt_no").val(jMain.case_main[0].agt_no);
            //商標種類
            $("input[name=fr11_S_Mark][value='" + jMain.case_main[0].s_mark + "']").prop("checked", true);
            //變更事項
            var arr_mod = ["mod_ap", "mod_aprep", "mod_agt", "mod_apaddr", "mod_agtaddr", "mod_claim1", "mod_oth", "mod_oth1", "mod_oth2"];
            for (var m in arr_mod) {
                if (jMain.case_main[0][arr_mod[m]] == "Y") {
                    $("#tfzr1_" + arr_mod[m]).prop("checked", true);
                    $("#ttfg1_" + arr_mod[m]).val("Y");
                } else {
                    $("#tfzr1_" + arr_mod[m]).prop("checked", false);
                    $("#ttfg1_" + arr_mod[m]).val("N");
                }
            }
            //變更一案多件
            if (main.prgid == "brt52") {
                $("#tot_num11").lock();
                $("#btndseq_oka_1,#btnQuerya_1").hide();
                $("#dseqa_1,#dseq1a_1").lock();
                $("input[name=case_stat1a_1]").lock();
            }
            $("#tot_num11,#nfy_tot_num").val(jMain.case_main[0].tot_num).triggerHandler("change");
            if (jMain.case_main[0].seq == "0") {
                $("#dseqa_1").val("");
            } else {
                $("#dseqa_1").val(item.seq);
            }
            $("#dseq1a_1").val(item.seq1);
            $("#btndseq_oka_1").lock();
            $("#keydseqa_1").val("Y");
            var smark_val = jMain.case_main[0].s_mark;
            if (smark_val == "S") {
                $("#s_marka_1").val("92年修正前服務標章");
            } else if (smark_val == "N") {
                $("#s_marka_1").val("團體商標");
            } else if (smark_val == "M") {
                $("#s_marka_1").val("團體標章");
            } else if (smark_val == "L") {
                $("#s_marka_1").val("證明標章");
            } else {
                $("#s_marka_1").val("商標");
            }
            $("#appl_namea_1").val(jMain.case_main[0].appl_name);//商標名稱
            $("#apply_noa_1").val(jMain.case_main[0].apply_no);//申請號數
            $.each(jMain.case_dmt1, function (i, item) {
                //填資料
                var nRow = (i + 1);
                $("#dseqa_" + nRow).val(item.seq);
                $("#dseq1a_" + nRow).val(item.seq1);
                if (item.case_stat1 == "NN") {
                    $("input[name='case_stat1a_" + nRow + "'][value=NN]").prop("checked", true).triggerHandler("click");
                    var smark_val = item.s_mark;
                    if (smark_val == "S") {
                        $("#s_marka_" + nRow).val("92年修正前服務標章");
                    } else if (smark_val == "N") {
                        $("#s_marka_" + nRow).val("團體商標");
                    } else if (smark_val == "M") {
                        $("#s_marka_" + nRow).val("團體標章");
                    } else if (smark_val == "L") {
                        $("#s_marka_" + nRow).val("證明標章");
                    } else {
                        $("#s_marka_" + nRow).val("商標");
                    }
                    $("#appl_namea_" + nRow).val(item.appl_name);
                    $("#apply_noa_" + nRow).val(item.apply_no);
                    $("#btndmt_tempa_" + nRow).val("案件主檔編修").show();
                    $("#case_sqlnoa_" + nRow).val(item.case_sqlno);
                    $("#dseqa_" + nRow).val(item.seq).lock();
                    $("#dseq1a_" + nRow).val(item.seq1).lock();
                    if (main.prgid == "brt52") {
                        $("#btndseq_oka_" + nRow + ",#btnQuerya_" + nRow).hide();
                        $("input[name=case_stat1a_" + nRow + " ]").lock();
                    }
                } else {
                    $("input[name='case_stat1a_" + nRow + "'][value=OO]").prop("checked", true).triggerHandler("click");
                    $("#btndmt_tempa_" + nRow).hide();
                    if (main.prgid == "brt52") {
                        $("#dseqa_" + nRow).lock();
                        $("#dseq1a_" + nRow).lock();
                    } else {
                        $("#dseqa_" + nRow).unlock();
                        $("#dseq1a_" + nRow).unlock();
                    }
                    $("#btncasea_" + nRow).show();
                    $("#btnQuerya_" + nRow).show();
                    br_form.btnseqclick(nRow, 'a_');
                    if (main.prgid == "brt52") {
                        $("#btndseq_oka_" + nRow + ",#btnQuerya_" + nRow).hide();
                        $("#btndmt_tempa_" + nRow).val("案件主檔編修").show();
                        $("input[name=case_stat1a_" + nRow + " ]").lock();
                        $("#btncasea_" + nRow).hide();
                    }
                }
            });
            //附件
            $("#tfzd_remark1").val(jMain.case_main[0].remark1);
            if (jMain.case_main[0].remark1 != "") {
                var arr_remark1 = jMain.case_main[0].remark1.split("|");
                for (var i = 0; i < arr_remark1.length; i++) {
                    //var str="Z3|Z9|Z9-具結書正本、讓與人之負責人身份證影本-Z9|";
                    //var str = "Z9-具結書正本、讓與人之負責人身份證影本-Z9";
                    var substr = arr_remark1[i].match(/Z9-(\S+)-Z9/);
                    if (substr != null) {
                        $("#ttz11_Z9t").val(substr[1]);
                    } else {
                        $("#ttz11_" + arr_remark1[i]).prop("checked", true);
                    }
                }
            }
        }
    }
</script>
