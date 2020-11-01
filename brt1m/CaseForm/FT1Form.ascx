<%@ Control Language="C#" ClassName="FT1Form" %>
<%@ Import Namespace = "System.Collections.Generic"%>

<script runat="server">
    //A8移轉交辦內容
    //父控制項傳入的參數
    public Dictionary<string, string> Lock = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    
    protected string prgid = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string SQL = "";

    protected string tfg1_agt_no1 = "";
    protected string html_apclass = "", html_country = "";
    
    private void Page_Load(System.Object sender, System.EventArgs e) {
        PageLayout();   
        this.DataBind();
    }
    
    private void PageLayout() {
        //代理人
        tfg1_agt_no1 = Sys.getAgent().Option("{agt_no}", "{agt_no}_{agt_namefull}", " v1='{agt_name1}' {selected}", true);
        html_apclass = Sys.getCustCode("apclass", "", "sortfld").Option("{cust_code}", "{code_name}");
        html_country = Sys.getCountry().Option("{coun_code}", "{coun_c}");
    }
</script>

<div id="div_Form_FT1">
<%=Sys.GetAscxPath(this)%>
<TABLE border=0 class=bluetable cellspacing=1 cellpadding=2 width="100%">
	<tr>
		<td class="lightbluetable" valign="top" ><strong>※代理人</strong></td>
		<td class="whitetablebg" colspan="7" >
		    <select id="tfg1_agt_no1" NAME="tfg1_agt_no1"><%#tfg1_agt_no1%></select>
            <input type="text" id="tfzd_agt_no" name="tfzd_agt_no">
		</td>
	</tr>
	<tr>
		<td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:pointer;COLOR:BLUE" onclick="PMARK(t1Appl_name)"><strong>壹、<u>註冊號數、商標(標章)種類及名稱</u></strong></td>
	</tr>
	<tr>
		<td class=lightbluetable align=right width="16%">註冊號數：</td>
		<td class=whitetablebg colspan="3"><input type="text" id="fr_issue_no" name="fr_issue_no" class="onoff" value="" size="20" maxlength="20" onchange="reg.tfzd_issue_no.value=this.value"></TD>
		<td class=lightbluetable align=right width="15%">商標/標章名稱：</td>
		<td class=whitetablebg colspan="3"><input type="text" id="fr_appl_name" name="fr_appl_name" class="onoff" value="" size="30" maxlength="100" class="onoff" onchange="reg.tfzd_appl_name.value=this.value"></TD>
	</tr>
	<tr>
		<td class=lightbluetable align=right >商標種類：</td>
		<td class=whitetablebg colspan="7">
			<input type=radio name=fr_S_Mark class="onoff" value="" onclick="dmt_form.change_mark(1, this)">商標
			<input type=radio name=fr_S_Mark class="onoff" value="S" onclick="dmt_form.change_mark(1, this)">92年修正前服務標章
			<input type=radio name=fr_S_Mark class="onoff" value="N" onclick="dmt_form.change_mark(1, this)">團體商標
			<input type=radio name=fr_S_Mark class="onoff" value="M" onclick="dmt_form.change_mark(1, this)">團體標章
			<input type=radio name=fr_S_Mark class="onoff" value="L" onclick="dmt_form.change_mark(1, this)">證明標章
		</TD>
	</tr>
	<tr class='sfont9'>
		<td colspan=8>
		<TABLE border=0 id=tabft2 class="bluetable"  cellspacing=1 cellpadding=2 width="100%" style="display:none">
        <thead>
		    <tr>
			    <td class="lightbluetable" align="right" width="23%">此次<span id="sp_titlecnt">移轉</span>總件數：</td>
			    <td class="whitetablebg"  colspan=3>共<input type="text" id=tot_num21 name=tot_num21 size=2 onchange="br_form.Add_FT1(this.value)" >件
				    <input type=text id=cnt211 name=cnt211 value="0"><!--畫面上有幾筆-->
				    <input type=text id=nfy_tot_num name=nfy_tot_num value="0">
			    </td>
		    </tr>
		    <tr>	
			    <td class="lightbluetable" align="right"><font color="red">(主)</font>案件編號1:</td>
			    <td class="whitetablebg">
                    <input type="text" id=dseqb_1 name=dseqb_1 size=5  maxlength=5 onblur="br_form.seqChange('b_1')" readonly class=SEdit>-<input type="text" id=dseq1b_1 name=dseq1b_1 size=1  maxlength=1 value="_" onblur="br_form.seqChange('b_1')" readonly class=SEdit>
                    <input type=button class="cbutton" id="btndseq_okb_1" name="btndseq_okb_1" value ="確定" onclick="delayNO(reg.dseqb_1.value,reg.dseq1b_1.value)">
                    <input type=radio value=NN id="case_stat1b_1NN" name="case_stat1b_1" onclick="br_form.case_stat1_control('NN','b_1')" checked>新案
                    <input type=radio value=OO id="case_stat1b_1OO" name="case_stat1b_1" onclick="br_form.case_stat1_control('OO','b_1')">舊案
                    <input type=button class="cbutton" id="btnQueryb_1" name="btnQueryb_1" value ="查詢主案件編號" onclick="br_form.btnQueryclick('b_1',reg.F_cust_seq.value)">
                    <input type=button class="cbutton" id="btncaseb_1" name="btncaseb_1"  value ="案件主檔查詢" onclick="br_form.btncaseclick('b_1')">
			　       <input type="text" id=keydseqb_1 name=keydseqb_1 value="N">
			    </td>
			    <td class="lightbluetable" align="right"><font color="red">(主)</font>母案本所編號1:</td>
			    <td class="whitetablebg" >
                    <input type="text" id=dmseqb_1 name=dmseqb_1 size=5  maxlength=5 readonly class=SEdit>-<input type="text" id=dmseq1b_1 name=dmseq1b_1 size=1  maxlength=1 value="_" readonly class=SEdit>
			    </td>
		    </tr>
		    <tr>	
			    <td class="lightbluetable" align="right"><font color="red">(主)</font>商標種類1:</td>
			    <td class="whitetablebg" colspan=3><input type="text" id=s_markb_1 name=s_markb_1 size=50 maxlength=50  readonly class=SEdit></td>
		    </tr>		
		    <tr>	
			    <td class="lightbluetable" align="right"><font color="red">(主)</font>商標/標章名稱1:</td>
			    <td class="whitetablebg" colspan=3><input type="text" id=appl_nameb_1 name=appl_nameb_1 size=50 maxlength=50 readonly class=SEdit></td>
		    </tr>		
		    <tr>	
			    <td class="lightbluetable" align="right"><font color="red">(主)</font>註冊號數1:</td>
			    <td class="whitetablebg" colspan=3><input type="text" id=issue_nob_1 name=issue_nob_1 size=50 maxlength=50 readonly class=SEdit></td>
		    </tr>
        </thead>
        <tbody></tbody>
        <script type="text/html" id="br_ft2_template">
		    <tr class="trft2_##">
			    <td class="lightbluetable" align="right">本所編號##:</td>
			    <td class="whitetablebg"  >
					<input type=text id=dseqb_## name=dseqb_## size=5  maxlength=5 onblur="br_form.seqChange('b_##')" readonly>-<input type=text id=dseq1b_## name=dseq1b_## size=1  maxlength=1 value='_' onblur="br_form.seqChange('b_##')" readonly >
					<input type=button class='cbutton' id='btndseq_okb_##' name='btndseq_okb_##' value ='確定' onclick="br_form.btnseqclick('##','b_')">
					<input type=radio value=NN checked name='case_stat1b_##' id='case_stat1b_##NN' onclick="br_form.case_stat1_control('NN','b_##')">新案
                    <input type=radio value=OO name='case_stat1b_##' id='case_stat1b_##OO' onclick="br_form.case_stat1_control('OO','b_##')">舊案
					<input type=button class='cbutton' id='btnQueryb_##' name='btnQueryb_##' value ='查詢本所編號' onclick="br_form.btnQueryclick('b_##', reg.F_cust_seq.value)">
					<input type=button class='cbutton' id=btncaseb_## name=btncaseb_##  value ='案件主檔查詢' onclick="br_form.btncaseclick('b_##')">
					<input type=button class=cbutton id=btndmt_tempb_## name=btndmt_tempb_##  value ='案件主檔新增' onclick="br_form.btndmt_tempclick('b_##')">
					<input type=text id=keydseqb_## name=keydseqb_##>
					<input type=text id=case_sqlnob_## name=case_sqlnob_##>
					<input type=text id=submitTaskb_## name=submitTaskb_##>
			    </td>
			    <td class="lightbluetable" align="right">母案本所編號##:</td>
			    <td class="whitetablebg" >
					<input type=text id=dmseqb_## name=dmseqb_## size=5  maxlength=5 readonly >-<input type=text id=dmseq1b_## name=dmseq1b_## size=1  maxlength=1 value='_' readonly >
					<input type=button style='display:none' id='but_endb_##' name='but_endb_##' id='but_endb_##' class='redbutton' style='cursor:hand' value='母案結案' onclick=""vbscript:btnendA8click 'dmseqb_##' ,reg.dmseqb_##.value,reg.dmseq1b_##.value"">
					<input type=text name='endflag51b_##' id='endflag51b_##' value='X'>
					<input type=text name='end_code51b_##' id='end_code51b_##'>
					<input type=text name='end_type51b_##' id='end_type51b_##'>
					<input type=text name='end_remark51b_##' id='end_remark51b_##'>
			    </td>
		    </tr>
		    <tr class="trft2_##">
			    <td class="lightbluetable" align="right">商標種類##:</td>
			    <td class="whitetablebg" colspan=3><input type=text id=s_markb_## NAME=s_markb_## size=30 readonly></td>
		    </tr>		
		    <tr class="trft2_##">
			    <td class="lightbluetable" align="right">商標/標章名稱##:</td>
			    <td class="whitetablebg" colspan=3><input type=text id=appl_nameb_## NAME=appl_nameb_## size=30 readonly></td>
		    </tr>		
		    <tr class="trft2_##">
			    <td class="lightbluetable" align="right">註冊號數##:</td>
			    <td class="whitetablebg" colspan=3><input type=text id=issue_nob_## NAME=issue_nob_## size=30 readonly></td>
		    </tr>
        </script>
		</table>
		</td>
	</tr>
	<tr style="display:none">
		<td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:pointer;COLOR:BLUE" ONCLICK="PMARK(c1Remark1)"><strong>伍、<u>另案一併移轉之防護商標註冊號數</u></strong></td>
	</tr>
	<tr style="display:none">
		<td class=whitetablebg colspan=8 ><TEXTAREA rows=1 cols=60 id=tfg1_tran_remark1 name=tfg1_tran_remark1></TEXTAREA></TD>
	</tr>
	<tr style="display:none">
		<td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:pointer;COLOR:BLUE" ONCLICK="PMARK(c1Remark2)"><strong>陸、<u>未一併移轉之防護商標註冊號數（未一併移轉者，其商標權消滅）</u></strong></td>
	</tr>
	<tr style="display:none">
		<td class=whitetablebg colspan=8 ><TEXTAREA rows=1 cols=60 id=tfg1_tran_remark2 name=tfg1_tran_remark2></TEXTAREA></TD>
	</tr>	
	<tr>
		<td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:pointer;COLOR:BLUE" ONCLICK="PMARK(zAttech)"><strong>肆、<u>移轉登記原因</u></strong>
            <input type=text id="tfzd_remark1" name="tfzd_remark1" value="">
		</td>
	</tr>	
	<tr class="br_attchstr" style="display:none">
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="ttz1_Z1" value="Z1" onclick="br_form.AttachStr('.br_attchstr','ttz1_',reg.tfzd_remark1)"></td>
		<td class="whitetablebg" colspan="7">移轉契約書或其他移轉證明文件(<input type="checkbox" name="ttz1_Z1C" value="Z1C" onclick="br_form.AttachStr('.br_attchstr','ttz1_',reg.tfzd_remark1)">附中譯本)。</td>
	</tr>
	<tr class="br_attchstr" style="display:none">
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="ttz1_Z2" value="Z2" onclick="br_form.AttachStr('.br_attchstr','ttz1_',reg.tfzd_remark1)"></td>
		<td class="whitetablebg" colspan="7">申請人之代理人委任書(<input type="checkbox" name="ttz1_Z2C" value="Z2C" onclick="br_form.AttachStr('.br_attchstr','ttz1_',reg.tfzd_remark1)">附中譯本)。</td>
	</tr>
	<!--2012/7/1新申請書增加，9/6修改-->
	<tr class="br_attchstr">
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="ttz1_Z3" value="Z3" onclick="br_form.AttachStr('.br_attchstr','ttz1_',reg.tfzd_remark1)"></td>
		<td class="whitetablebg" colspan="7">合意(買賣)移轉：應檢附移轉契約書(<input type="checkbox" name="ttz1_Z3C" value="Z3C" onclick="br_form.AttachStr('.br_attchstr','ttz1_',reg.tfzd_remark1)">附中文譯本)。</td>
	</tr>
	<tr class="br_attchstr">
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="ttz1_Z4" value="Z4" onclick="br_form.AttachStr('.br_attchstr','ttz1_',reg.tfzd_remark1)"></td>
		<td class="whitetablebg" colspan="7">繼承移轉，應檢附下列文件：<br>
			1.原商標權人死亡證明、原商標權人全戶戶籍謄本(由受讓人具結係全戶謄本)、專用權歸屬證明或其他繼承證明文件(如係外文應另附中文譯本)。<br>
			2.稽徵機關核發之稅款繳清證明書，或核定免稅證明書，或不計入遺產總額證明書，或同意移轉證明書之副本，或稽徵機關核發之其他證明文件。
		</td>
	</tr>
	<tr class="br_attchstr">
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="ttz1_Z5" value="Z5" onclick="br_form.AttachStr('.br_attchstr','ttz1_',reg.tfzd_remark1)"></td>
		<td class="whitetablebg" colspan="7">贈與移轉，應檢附下列文件：<br>
			1.贈與契約書(<input type="checkbox" name="ttz1_Z5C" value="Z5C" onclick="br_form.AttachStr('.br_attchstr','ttz1_',reg.tfzd_remark1)">附中文譯本)。<br>
			2.稽徵機關核發之稅款繳清證明書，或核定免稅證明書，或不計入贈與總額證明書，或同意移轉證明書之副本，或稽徵機關核發之其他證明文件。
		</td>
	</tr>
	<tr class="br_attchstr">
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="ttz1_Z6" value="Z6" onclick="br_form.AttachStr('.br_attchstr','ttz1_',reg.tfzd_remark1)"></td>
		<td class="whitetablebg" colspan="7">拍賣移轉：應檢附法院拍定證明影本。
		</td>
	</tr>
	<tr class="br_attchstr">
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="ttz1_Z7" value="Z7" onclick="br_form.AttachStr('.br_attchstr','ttz1_',reg.tfzd_remark1)"></td>
		<td class="whitetablebg" colspan="7">公司合併移轉：應檢附公司合併證明文件(<input type="checkbox" name="ttz1_Z7C" value="Z7C" onclick="br_form.AttachStr('.br_attchstr','ttz1_',reg.tfzd_remark1)">附中文譯本)。
			
		</td>
	</tr>
	<tr class="br_attchstr">
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="ttz1_Z8" value="Z8" onclick="br_form.AttachStr('.br_attchstr','ttz1_',reg.tfzd_remark1)"></td>
		<td class="whitetablebg" colspan="7">團體標章、團體商標、證明標章移轉：移轉契約書及使用規範書或使用規範書之電子檔光碟片(<input type="checkbox" name="ttz1_Z8C" value="Z8C" onclick="br_form.AttachStr('.br_attchstr','ttz1_',reg.tfzd_remark1)">附中文譯本)。
		</td>
	</tr>
	<tr class="br_attchstr">
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="ttz1_Z9" value="Z9" onclick="br_form.AttachStr('.br_attchstr','ttz1_',reg.tfzd_remark1)"></td>
		<td class="whitetablebg" colspan="7">其他。<input TYPE="text" NAME="ttz1_Z9t" SIZE="50" onchange="br_form.AttachStr('.br_attchstr','ttz1_',reg.tfzd_remark1)">
		</td>
	</tr>
	<tr style="display:none">
		<td class=lightbluetable  ROWSPAN=2 ><strong>附註一：</strong></td>
		<td class=whitetablebg colspan=7>本件商標(標章)於<INPUT type=text id=O_item1 name=O_item1 size=10 class="dateField">(年/月/日)</td>
	</tr>
	<tr style="display:none">		  
		<td class=whitetablebg colspan=7>另案辦理<INPUT type="radio" id=O_item2FT1 name=O_item2 value="FT1">移轉案
													<INPUT type="radio" id=O_item2FL1 name=O_item2 value="FL1">授權案
													<INPUT type="radio" id=O_item2FI1 name=O_item2 value="FI1">補證案
													<INPUT type="radio" id=O_item2FC1 name=O_item2 value="FC1">變更案
													<INPUT type="radio" id=O_item2FR1 name=O_item2 value="FR1">延展案
													<INPUT type="radio" id=O_item2FP1 name=O_item2 value="FP1">質權案</TD>
	</tr>
</TABLE>
</div>
<INPUT TYPE=text id=tfr_mod_field NAME=tfr_mod_field value="mod_ap">
<INPUT TYPE=text id=tfg1_seq NAME=tfg1_seq>
<INPUT TYPE=text id=tfg1_seq1 NAME=tfg1_seq1>

<script language="javascript" type="text/javascript">
    //*****共N件
    br_form.Add_FT1 = function (arcaseCount) {
        if (arcaseCount > 50) {
            alert("移轉案件數不可超過50筆");
            $("#tot_num1").val("1").focus();
            return false;
        }

        var doCount = CInt(arcaseCount);//要改為幾筆
        var cnt211 = Math.max(1, CInt($("#cnt211").val()));//目前畫面上有幾筆,最少是1
        if (doCount > cnt211) {//要加
            for (var nRow = cnt211; nRow < doCount ; nRow++) {
                var copyStr = $("#br_ft2_template").text() || "";
                copyStr = copyStr.replace(/##/g, nRow + 1);
                if (nRow % 2 != 0) copyStr = copyStr.replace(/whitetablebg/g, "greentablebg");
                $("#tabft2 tbody").append(copyStr);
                if (nRow % 2 != 0) {
                    $(".trft2_" + (nRow + 1) + " input[type=text]").attr("class", "sedit2");
                } else {
                    $(".trft2_" + (nRow + 1) + " input[type=text]").attr("class", "SEdit");
                }
                $("#submitTaskb_" + (nRow + 1)).val(main.submittask);
                $("#cnt211").val(nRow + 1);
            }
        } else {
            //要減
            for (var nRow = cnt211; nRow > doCount ; nRow--) {
                $('.trft2_' + nRow).remove();
                $("#cnt211").val(nRow - 1);
            }
        }
    }

    //交辦內容綁定
    br_form.bindFT1 = function () {
        console.log("ft1.br_form.bind");
        if (jMain.case_main.length == 0) {
        } else {
        }
    }
</script>
