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
		<td class=whitetablebg colspan="3"><input type="text" id="fr_issue_no" name="fr_issue_no" value="" size="20" maxlength="20" onchange="reg.tfzd_issue_no.value=this.value"></TD>
		<td class=lightbluetable align=right width="15%">商標/標章名稱：</td>
		<td class=whitetablebg colspan="3"><input type="text" id="fr_Appl_name" name="fr_Appl_name" value="" size="30" maxlength="100" onchange="reg.tfzd_Appl_name.value=this.value"></TD>
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
	<tr class='sfont9'>
		<td colspan=8>
		<TABLE border=0 id=tabft2 class="bluetable"  cellspacing=1 cellpadding=2 width="100%" style="display:none">
        <thead>
		    <tr>
			    <td class="lightbluetable" align="right" width="23%">此次<span id="sp_titlecnt">移轉</span>總件數：</td>
			    <td class="whitetablebg"  colspan=3>共<input type="text" id=tot_num21 name=tot_num21 size=2 onchange="br_form.Add_FC21(this.value)" >件
				    <input type=text id=cnt211 name=cnt211 value="1"><!--畫面上有幾筆-->
				    <input type=text id=nfy_tot_num name=nfy_tot_num value="1">
			    </td>
		    </tr>
		    <tr>	
			    <td class="lightbluetable" align="right"><font color="red">(主)</font>案件編號1:</td>
			    <td class="whitetablebg">
                    <input type="text" id=dseqb_1 name=dseqb_1 size=5  maxlength=5 onblur="br_form.seqChange(1)" readonly class=sedit>-<input type="text" id=dseq1b_1 name=dseq1b_1 size=1  maxlength=1 value="_" onblur="br_form.seqChange(1)" readonly class=sedit>
                    <input type=button class="cbutton" id="btndseq_okb_1" name="btndseq_okb_1" value ="確定" onclick="delayNO(reg.dseqb_1.value,reg.dseq1b_1.value)">
                    <input type=radio value=NN checked id="case_stat1b_1NN" name="case_stat1b_1" onclick="br_form.case_stat1_control('NN','b_1')">新案
                    <input type=radio value=OO id="case_stat1b_1OO" name="case_stat1b_1" onclick="br_form.case_stat1_control('OO','b_1')">舊案
                    <input type=button class="cbutton" id="btnQueryb_1" name="btnQueryb_1" value ="查詢主案件編號" width=85 onclick="br_form.btnQueryclick('b_1',reg.F_cust_seq.value)">
                    <input type=button class="cbutton" id="btncaseb_1" name="btncaseb_1"  value ="案件主檔查詢" width=85 onclick="br_form.btncaseclick('1')">
			　       <input type="text" id=keydseqb_1 name=keydseqb_1 value="N">
			    </td>
			    <td class="lightbluetable" align="right"><font color="red">(主)</font>母案本所編號1:</td>
			    <td class="whitetablebg" >
                    <input type="text" id=dmseqb_1 name=dmseqb_1 size=5  maxlength=5 readonly class=sedit>-<input type="text" id=dmseq1b_1 name=dmseq1b_1 size=1  maxlength=1 value="_" readonly class=sedit>
			    </td>
		    </tr>
		    <tr>	
			    <td class="lightbluetable" align="right"><font color="red">(主)</font>商標種類1:</td>
			    <td class="whitetablebg" colspan=3><input type="text" id=s_markb_1 name=s_markb_1 size=50 maxlength=50  readonly class=sedit></td>
		    </tr>		
		    <tr>	
			    <td class="lightbluetable" align="right"><font color="red">(主)</font>商標/標章名稱1:</td>
			    <td class="whitetablebg" colspan=3><input type="text" id=appl_nameb_1 name=appl_nameb_1 size=50 maxlength=50 readonly class=sedit></td>
		    </tr>		
		    <tr>	
			    <td class="lightbluetable" align="right"><font color="red">(主)</font>註冊號數1:</td>
			    <td class="whitetablebg" colspan=3><input type="text" id=issue_nob_1 name=issue_nob_1 size=50 maxlength=50 readonly class=sedit></td>
		    </tr>
        </thead>
        <tbody></tbody>
        <script type="text/html" id="br_ft2_template">
		    <tr class="trft2_##">
			    <td class="lightbluetable" align="right">本所編號##:</td>
			    <td class="whitetablebg"  >
					<input type=text id=dseqb_## name=dseqb_## size=5  maxlength=5 onblur="br_form.seqChange('##')" readonly>-<input type=text id=dseq1b_## name=dseq1b_## size=1  maxlength=1 value='_' onblur="br_form.seqChange('##')" readonly >
					<input type=button class='cbutton' id='btndseq_okb_##' name='btndseq_okb_##' value ='確定' onclick="br_form.btnseqclick('##','b_')">
					<input type=radio value=NN checked name='case_stat1b_##' id='case_stat1b_##NN' onclick="br_form.case_stat1_control('NN','b_##')">新案
                    <input type=radio value=OO name='case_stat1b_##' id='case_stat1b_##OO' onclick="br_form.case_stat1_control('OO','b_##')">舊案
					<input type=button class='cbutton' id='btnQueryb_##' name='btnQueryb_##' value ='查詢本所編號' width=85 onclick="br_form.btnQueryclick('b_##', reg.F_cust_seq.value)">
					<input type=button class='cbutton' id=btncaseb_## name=btncaseb_##  value ='案件主檔查詢' width=85 onclick="br_form.btncaseclick('##')">
					<input type=button class=cbutton id=btndmt_tempb_## name=btndmt_tempb_##  value ='案件主檔新增' width=85 onclick="btndmt_tempclick('b_##')">
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

<INPUT TYPE=text id=tfr_mod_field NAME=tfr_mod_field value="mod_ap">
<INPUT TYPE=text id=tfg1_seq NAME=tfg1_seq>
<INPUT TYPE=text id=tfg1_seq1 NAME=tfg1_seq1>

<script language="javascript" type="text/javascript">
    br_form.init = function () {
        //br_form.Add_FC21(1);//移轉件數預設1筆
    }

    //*****共N件
    br_form.Add_FC21 = function (arcaseCount) {
        if(arcaseCount>50){
            alert("移轉案件數不可超過50筆");
            $("#tot_num1").val("1").focus();
            return false;
        }

        var doCount = Math.max(1, CInt(arcaseCount));//要改為幾筆,最少是1
        var cnt211 = CInt($("#cnt211").val());//目前畫面上有幾筆
        if (doCount > cnt211) {//要加
            for (var nRow = cnt211; nRow < doCount ; nRow++) {
                var copyStr = $("#br_ft2_template").text() || "";
                copyStr = copyStr.replace(/##/g, nRow + 1);
                if(nRow%2!=0) copyStr = copyStr.replace(/whitetablebg/g,"greentablebg");
                $("#tabft2 tbody").append(copyStr);
                if(nRow%2!=0) {
                    $(".trft2_"+(nRow + 1)+" input[type=text]").attr("class","sedit2");
                }else{
                    $(".trft2_"+(nRow + 1)+" input[type=text]").attr("class","SEdit");
                }
                $("#submitTaskb_"+(nRow + 1)).val(main.submittask);
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

    //新/舊案
    br_form.case_stat1_control=function(stat,fld){
        if(stat=="NN"){
            $("#btndseq_ok"+fld).hide();//[確定]
            $("#btnQuery"+fld).hide();//[查詢本所編號]
            $("#btncase"+fld).hide();//[案件主檔查詢]
            if(fld!="a_1"&&fld!="b_1"){//不是主案
                $("#btndmt_temp"+fld).show();//[案件主檔新增]
            }
            if(CInt(fld.substr(2))%2==0){
                $("#dseq"+fld).attr("class","sedit2").prop("readonly",true).val("");
                $("#dseq1"+fld).attr("class","sedit2").prop("readonly",true).val("_");
            }else{
                $("#dseq"+fld).attr("class","SEdit").prop("readonly",true).val("");
                $("#dseq1"+fld).attr("class","SEdit").prop("readonly",true).val("_");
            }
            $("#issue_no"+fld).val("");
            $("#s_mark"+fld).val("");
            $("#appl_name"+fld).val("");

            if(fld=="a_1"||fld=="b_1"){//是主案
                $("#tfy_case_stat").val("NN");
                $("#keyseq").val("N");
                $("#btnseq_ok").unlock();
                $("#old_seq").val("");
                $("#old_seq1").val("_");
                dmt_form.new_oldcase();
                alert("請至案件主檔填寫新案內容!!");
                settab("#dmt");
            }
        }else if(stat=="OO"){
            if(fld!="a_1"&&fld!="b_1"){//不是主案
                $("#btndmt_temp"+fld).hide();//[案件主檔新增]
            }
            $("#btndseq_ok"+fld).show();//[確定]
            $("#btnQuery"+fld).show();//[查詢本所編號]
            $("#btncase"+fld).show();//[案件主檔查詢]
            $("#dseq" + fld).attr("class", "").prop("readonly", false).val("");
            $("#dseq1" + fld).attr("class", "").prop("readonly", false).val("_");
            $("#issue_no"+fld).val("");
            $("#s_mark"+fld).val("");
            $("#appl_name"+fld).val("");
            if(fld=="a_1"&&fld=="b_1"){//是主案
                $("#tfy_case_stat").val("OO");
                dmt_form.new_oldcase();
            }
        }
    }

    //副案[案件主檔新增]
    br_form.btndmt_tempclick=function(num){
        var cust_area=$("#F_cust_area").val();
        var cust_seq=$("#F_cust_seq").val();
        var in_scode=$("#F_tscode").val();
        var case_sqlno=$("#case_sqlno"+num).val();
        var task=$("#submitTask"+num).val();
        var arcase=$("#tfy_Arcase").val();
        if(in_scode==""){
            alert("請先輸入洽案營洽!!!");
            settab("#case");
            $("#F_tscode").focus();
            return false;
        }else{
            var tot_num=$("#tot_num21").val();
            if($("#prgid").val()!="brt52"){
                //***todo
                window.open("Brt11Addtemp.asp?tot_num=" + tot_num + "&cust_area="+cust_area+"&cust_seq="+cust_seq+"&in_scode="+ in_scode+"&num="+ num+"&SubmitTask="+ task + "&arcase="+arcase ,"myWindowOne", "width=700 height=450 top=40 left=50 toolbar=no, menubar=no, location=no, directories=no resizeable=no status=no scrollbars=yes");
            }else{
                window.open("Brt11Addtemp.asp?cust_area="+cust_area+"&cust_seq="+cust_seq+"&in_scode="+ in_scode+"&num="+ num+"&SubmitTask=&case_sqlno="+ case_sqlno+"&Lock=show&arcase="+arcase ,"myWindowOne", "width=700 height=450 top=40 left=50 toolbar=no, menubar=no, location=no, directories=no resizeable=no status=no scrollbars=yes");
            }
        }
    }

    //副案[確定]
    br_form.btnseqclick=function(nRow,fld){
        var value1=$("#dseq"+fld+nRow).val();
        var value2=$("#dseq1"+fld+nRow).val();
        if(value1!=""){
            $("#case_stat1"+fld+nRow+"OO").prop("checked",true);//舊案
            $("#btndmt_temp"+fld+nRow).hide();//[案件主檔新增]
            $("#btncase"+fld+nRow).show();//[案件主檔查詢]
            $("#btnQuery"+fld+nRow).show();//[查詢本所編號]
            var objCase = {};
            for (var r = 2; r <= CInt(nRow) ; r++) {
                var lineCase = value1+value2;
                if (lineCase != "_" && objCase[lineCase]) {
                    alert("移轉本所編號(" + r + ")重覆,請重新輸入！！");
                    settab("#tran");

                    $("#keydseq"+fld+r).val("N");
                    $("#btndseq_ok"+fld+r).prop("disabled",false);
                    $("#dseq"+fld+r).focus();
                    return false;
                } else {
                    objCase[lineCase] = { flag: true, idx: r };
                }
            }

            var lname=$("#old_seq").val()+$("#old_seq1").val();
            var kname=value1+value2;
            if(lname!="_"&&kname!="_"){
                if(lname==kname){
                    alert("移轉本所編號"+r+"與主要的本所編號重覆,請重新輸入!!!");
                    settab("#tran");
                    $("#keydseq"+fld+r).val("N");
                    $("#btndseq_ok"+fld+r).prop("disabled",false);
                    $("#dseq"+fld+r).focus();
                    return false;
                }
            }
        }
        if(value1!=""){
            if (chkNum(value1,"本所編號")) return false;
            var purl=getRootPath() + "/ajax/json_dmt.aspx?seq="+value1+"&seq1="+value2+"&cust_area="+ $("#tfy_cust_area").val()+"&cust_seq="+ $("#tfy_cust_seq").val();
            $.ajax({
                type: "get",
                url: purl,
                async: false,
                cache: false,
                success: function (json) {
                    //if ($("#chkTest").prop("checked")) toastr.info("<a href='" + this.url + "' target='_new'>Debug(_apcust交辦申請人)！<BR><b><u>(點此顯示詳細訊息)</u></b></a>");
                    dmt_list = $.parseJSON(json);
                    if (dmt_list.length > 0) {
                        var backflag_fldname="A9Z";
                        $("#s_mark"+fld+nRow).val(dmt_list[0].smarknm);
                        $("#appl_name"+fld+nRow).val(dmt_list[0].appl_name);
                        //2011/2/8因應復案修改，提醒結案是否要復案
                        if(dmt_list[0].end_date!=""){
                            if($("#"+backflag_fldname+"_end_flag").prop("checked")==true){
                                alert("該案("+value1+"-"+value2+")已結案且主案要復案，程序客收確認後將會一併復案。");
                            }else{
                                if(confirm("該案件已結案，如確定要交辦則需註記是否復案，請問是否復案？")){
                                    $("#"+backflag_fldname+"_back_flag").prop("checked",true);
                                }else{
                                    $("#"+backflag_fldname+"_back_flag").prop("checked",false);
                                }
                                dmt_form.get_backdata(backflag_fldname);
                            }
                        }
                    }else{
                        alert("該客戶無此案件編號");
                        $("#dseq"+fld+nRow).unlock().val("").focus();
                        $("#dseq1"+fld+nRow).unlock().val("_");
                        $("#issue_no"+fld+nRow).val("");
                        $("#s_mark"+fld+nRow).val("");
                        $("#appl_name"+fld+nRow).val("");
                        $("#issue_no"+fld+nRow).val("");
                    }
                },
                error: function (xhr) {
                    $("#dialog").html("<a href='" + this.url + "' target='_new'>check案件結案資料失敗！<u>(點此顯示詳細訊息)</u></a><hr>" + xhr.responseText);
                    $("#dialog").dialog({ title: 'check案件結案資料失敗！', modal: true, maxHeight: 500, width: 800 });
                    //toastr.error("<a href='" + this.url + "' target='_new'>check案件結案資料失敗！<BR><b><u>(點此顯示詳細訊息)</u></b></a>");
                }
            });
            $("#keydseq"+fld+nRow).val("Y");
            $("#btndseq_ok"+fld+nRow).prop("disabled",true);
        }else{
            alert("請先輸入本所編號!!!");
            $("#dseqb_"+nRow).focus();
            return false;
        }
    }

    //[查詢本所編號]
    br_form.btnQueryclick=function(tot_num,cust_seq){
        $("#dseq"+tot_num).attr("class","").prop("readonly",false);
        $("#dseq1"+tot_num).attr("class","").prop("readonly",false);
        $("#btndseq_ok"+tot_num).show();//[確定]
        $("#case_stat1"+fld+nRow+"OO").prop("checked",true);//舊案
        if(fld=="a_1"||fld=="b_1"){//是主案
            Filereadonly();
        }
        //***todo
        window.open("..\brtam\brta21Query.aspx?cust_seq="+cust_seq+"&tot_num="+ tot_num ,"myWindowOne", "width=650 height=420 top=40 left=80 toolbar=no, menubar=no, location=no, directories=no resizeable=no status=no scrollbars=yes");
    }

    //[案件主檔查詢]
    br_form.btncaseclick=function(nRow){
        var value1=$("#dseqb_"+nRow).val();
        var value2=$("#dseq1b_"+nRow).val();
        if(value1==""){
            alert("請先輸入本所編號!!!");
            $("#dseqb_"+nRow).focus();
            return false;
        }else{
            //***todo
            var url = getRootPath() + "/brt5m/brt15ShowFP.asp?seq="+value1+"&seq1="+value2 + "&submittask=Q";
            window.showModalDialog(url,"","dialogHeight: 540px; dialogWidth: 800px; center: Yes;resizable: No; status: No;scrollbars:yes");
        }
    }

    br_form.seqChange = function (nRow){
        $("#keydseqb_"+nRow).val("N")//有變動給N
        $("#btndseq_okb_"+nRow).prop("disabled",false);
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
        if (code3 == "FT1") {
            $("#tabft2").hide();
        } else if (code3 == "FT2") {
            $("#tabft2").show();
        }

        //切換後重新綁資料
        br_form.bind();
    }
</script>
