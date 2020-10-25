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
			<input type=radio name=fr11_S_Mark value="" onclick="dmt_form.change_mark(1, this)">商標
			<span id="fr11_SmarkS" style="display:none">
			<input type=radio name=fr11_S_Mark value="S" onclick="dmt_form.change_mark(1, this)">92年修正前服務標章
			</span>
			<input type=radio name=fr11_S_Mark value="N" onclick="dmt_form.change_mark(1, this)">團體商標
			<input type=radio name=fr11_S_Mark value="M" onclick="dmt_form.change_mark(1, this)">團體標章
			<input type=radio name=fr11_S_Mark value="L" onclick="dmt_form.change_mark(1, this)">證明標章
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
	<tr class="br_attchstr">
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttz11_Z2" NAME="ttz11_Z2" value="Z2" onclick="br_form.AttachStr('.br_attchstr','ttz11_',reg.tfzd_remark1)"></td>
		<td class="whitetablebg" colspan="7">委任書(<input TYPE="checkbox" id="ttz11_Z2C" NAME="ttz11_Z2C" value="Z2C" onclick="br_form.AttachStr('.br_attchstr','ttz11_',reg.tfzd_remark1)">附中文譯本)。</td>
	</tr>
	<tr class="br_attchstr">
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttz11_Z1" NAME="ttz11_Z1" value="Z1" onclick="br_form.AttachStr('.br_attchstr','ttz11_',reg.tfzd_remark1)"></td>
		<td class="whitetablebg" colspan="7">變更證明文件。</td>
	</tr>
	<tr class="br_attchstr">
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttz11_Z8" NAME="ttz11_Z8" value="Z8" onclick="br_form.AttachStr('.br_attchstr','ttz11_',reg.tfzd_remark1)"></td>
		<td class="whitetablebg" colspan="7">移轉契約或其他移轉證明文件。</td>
	</tr>
	<tr class="br_attchstr">
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttz11_Z3" NAME="ttz11_Z3" value="Z3" onclick="br_form.AttachStr('.br_attchstr','ttz11_',reg.tfzd_remark1)"></td>
		<td class="whitetablebg" colspan="7">個人身分證影本。</td>
	</tr>
	<tr class="br_attchstr">
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttz11_Z4" NAME="ttz11_Z4" value="Z4" onclick="br_form.AttachStr('.br_attchstr','ttz11_',reg.tfzd_remark1)"></td>
		<td class="whitetablebg" colspan="7">法人公司執照影本。</td>
	</tr>
	<tr class="br_attchstr">
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttz11_Z5" NAME="ttz11_Z5" value="Z5" onclick="br_form.AttachStr('.br_attchstr','ttz11_',reg.tfzd_remark1)"></td>
		<td class="whitetablebg" colspan="7">身分或法人證明影本。</td>
	</tr>
	<tr class="br_attchstr">
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttz11_Z6" NAME="ttz11_Z6" value="Z6" onclick="br_form.AttachStr('.br_attchstr','ttz11_',reg.tfzd_remark1)"></td>
		<td class="whitetablebg" colspan="7">具結書。(印鑑遺失具結書)</td>
	</tr>
	<tr class="br_attchstr">
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttz11_Z7" NAME="ttz11_Z7" value="Z7" onclick="br_form.AttachStr('.br_attchstr','ttz11_',reg.tfzd_remark1)"></td>
		<td class="whitetablebg" colspan="7">全體共有人同意書。</td>
	</tr>
	<tr class="br_attchstr">
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttz11_Z9" NAME="ttz11_Z9" value="Z9" onclick="br_form.AttachStr('.br_attchstr','ttz11_',reg.tfzd_remark1)"></td>
		<td class="whitetablebg" colspan="7">其他證明文件。<input TYPE="text" id="ttz11_Z9t" NAME="ttz11_Z9t" SIZE="50" onchange="br_form.AttachStr('.br_attchstr','ttz11_',reg.tfzd_remark1)"></td>
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
                    $("#dialog").dialog({ title: 'check案件結案資料失敗！', modal: true, maxHeight: 500, width: 800 });
                    //toastr.error("<a href='" + this.url + "' target='_new'>check案件結案資料失敗！<BR><b><u>(點此顯示詳細訊息)</u></b></a>");
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
    br_form.bindFC11 = function () {
        console.log("fc11.br_form.bind");
        if (jMain.case_main.length == 0) {
        } else {
        }
    }
</script>
