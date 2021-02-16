<%@ Control Language="C#" ClassName="FT1Form" %>
<%@ Import Namespace = "System.Collections.Generic"%>

<script runat="server">
    //A8移轉交辦內容
    //父控制項傳入的參數
    public Dictionary<string, string> Lock = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);

    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
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
<%=Sys.GetAscxPath(this.AppRelativeVirtualPath)%>
<TABLE border=0 class=bluetable cellspacing=1 cellpadding=2 width="100%">
	<tr>
		<td class="lightbluetable" valign="top" ><strong>※代理人</strong></td>
		<td class="whitetablebg" colspan="7" >
		    <select id="tfg1_agt_no1" NAME="tfg1_agt_no1"><%#tfg1_agt_no1%></select>
            <!--input type="text" id="tfzd_agt_no" name="tfzd_agt_no"-->
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
				    <input type=hidden id=cnt211 name=cnt211 value="0"><!--畫面上有幾筆-->
				    <input type=hidden id=nfy_tot_num name=nfy_tot_num value="0">
			    </td>
		    </tr>
		    <tr>	
			    <td class="lightbluetable" align="right"><font color="red">(主)</font>案件編號1:</td>
			    <td class="whitetablebg">
                    <input type="text" id=dseqb_1 name=dseqb_1 size=<%=Sys.DmtSeq%> maxlength=<%=Sys.DmtSeq%> onblur="br_form.seqChange('b_1')" readonly class=SEdit>-<input type="text" id=dseq1b_1 name=dseq1b_1 size=<%=Sys.DmtSeq1%> maxlength=<%=Sys.DmtSeq1%> value="_" onblur="br_form.seqChange('b_1')" readonly class=SEdit>
                    <input type=button class="cbutton" id="btndseq_okb_1" name="btndseq_okb_1" value ="確定" onclick="delayNO(reg.dseqb_1.value,reg.dseq1b_1.value)">
                    <input type=radio value=NN id="case_stat1b_1NN" name="case_stat1b_1" onclick="br_form.case_stat1_control('NN','b_1')" checked>新案
                    <input type=radio value=OO id="case_stat1b_1OO" name="case_stat1b_1" onclick="br_form.case_stat1_control('OO','b_1')">舊案
                    <input type=button class="cbutton" id="btnQueryb_1" name="btnQueryb_1" value ="查詢主案件編號" onclick="br_form.btnQueryclick('b_1',reg.F_cust_seq.value)">
                    <input type=button class="cbutton" id="btncaseb_1" name="btncaseb_1"  value ="案件主檔查詢" onclick="br_form.btncaseclick('b_1')">
			　       <input type="text" id=keydseqb_1 name=keydseqb_1 value="N">
			    </td>
			    <td class="lightbluetable" align="right"><font color="red">(主)</font>母案本所編號1:</td>
			    <td class="whitetablebg" >
                    <input type="text" id=dmseqb_1 name=dmseqb_1 size=<%=Sys.DmtSeq%> maxlength=<%=Sys.DmtSeq%> readonly class=SEdit>-<input type="text" id=dmseq1b_1 name=dmseq1b_1 size=<%=Sys.DmtSeq1%>  maxlength=<%=Sys.DmtSeq1%> value="_" readonly class=SEdit>
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
					<input type=text id=dseqb_## name=dseqb_## size=<%=Sys.DmtSeq%> maxlength=<%=Sys.DmtSeq%> onblur="br_form.seqChange('b_##')" readonly>-<input type=text id=dseq1b_## name=dseq1b_## size=<%=Sys.DmtSeq1%> maxlength=<%=Sys.DmtSeq1%> value='_' onblur="br_form.seqChange('b_##')" readonly >
					<input type=button class='cbutton' id='btndseq_okb_##' name='btndseq_okb_##' value ='確定' onclick="br_form.btnseqclick('##','b_')">
					<input type=radio value=NN checked name='case_stat1b_##' id='case_stat1b_##NN' onclick="br_form.case_stat1_control('NN','b_##')">新案
                    <input type=radio value=OO name='case_stat1b_##' id='case_stat1b_##OO' onclick="br_form.case_stat1_control('OO','b_##')">舊案
					<input type=button class='cbutton' id='btnQueryb_##' name='btnQueryb_##' value ='查詢本所編號' onclick="br_form.btnQueryclick('b_##', reg.F_cust_seq.value)">
					<input type=button class='cbutton' id=btncaseb_## name=btncaseb_##  value ='案件主檔查詢' onclick="br_form.btncaseclick('b_##')">
					<input type=button class=cbutton id=btndmt_tempb_## name=btndmt_tempb_##  value ='案件主檔新增' onclick="br_form.btndmt_tempclick('b_##')">
					<input type=hidden id=keydseqb_## name=keydseqb_##>
					<input type=hidden id=case_sqlnob_## name=case_sqlnob_##>
					<input type=hidden id=submitTaskb_## name=submitTaskb_##>
			    </td>
			    <td class="lightbluetable" align="right">母案本所編號##:</td>
			    <td class="whitetablebg" >
					<input type=text id=dmseqb_## name=dmseqb_## size=<%=Sys.DmtSeq%> maxlength=<%=Sys.DmtSeq%> readonly >-<input type=text id=dmseq1b_## name=dmseq1b_## size=<%=Sys.DmtSeq1%>  maxlength=<%=Sys.DmtSeq1%> value='_' readonly >
					<input type=button style='display:none' id='but_endb_##' name='but_endb_##' class='redbutton' style='cursor:pointer' value='母案結案' onclick="btnendA8click('dmseqb_##' ,reg.dmseqb_##.value,reg.dmseq1b_##.value)">
					<input type=hidden name='endflag51b_##' id='endflag51b_##' value='X'>
					<input type=hidden name='end_code51b_##' id='end_code51b_##'>
					<input type=hidden name='end_type51b_##' id='end_type51b_##'>
					<input type=hidden name='end_remark51b_##' id='end_remark51b_##'>
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
		<td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:pointer;COLOR:BLUE" ONCLICK="PMARK(c1Rapcust)"><strong>肆、<u>讓與人(原商標權人)</u></strong></td>
	</tr>
	<tr style="display:none">
		<td class=sfont9 colspan="8">
		<input type=hidden id=FT_apnum name=FT_apnum value=0><!--進度筆數-->
		<table border="0" id=FT_tabap class="bluetable" cellspacing="1" cellpadding="1" style="font-size: 9pt" width="100%">
            <thead>
		        <TR>
			        <TD  class=whitetablebg colspan=4 align=right>
				        <input type=button value ="增加一筆關係人" class="cbutton" id=FT_AP_Add_button name=FT_AP_Add_button>
				        <input type=button value ="減少一筆關係人" class="cbutton" id=FT_AP_Del_button name=FT_AP_Del_button>
			        </TD>
		        </TR>
            </thead>
            <tbody></tbody>
            <script type="text/html" id="ft_role_template">
	            <TR>
		            <TD class="lightbluetable role9" align=right title="輸入編號並點選確定，即顯示關係人資料；若無資料，請直接輸入關係人資料。">
                        <input type=text id='FT_apnum_##' name='FT_apnum_##' class=SEdit readonly size=2 value='##.'>
                        <span id='span_FT_Apcust_no_##' style='cursor:pointer;color:blue'>關係人統一編號：</span>
		            </TD>
		            <TD class=sfont9 colspan="3">
		                <input TYPE=text ID=tfr_apcust_no_## NAME=tfr_old_no_## SIZE=10 MAXLENGTH=10 onblur="br_form.FT_chkapcust_no(reg.FT_apnum.value,'##','tfr_apcust_no_')">
		                <input type='button' value='確定' onclick="br_form.getapp1_ft('##')"  id='button_##' name='button_##' title='輸入編號並點選確定，即顯示關係人資料；若無資料，請直接輸入關係人資料。'>
		            </TD>
	            </TR>
                <TR>
		            <TD class="lightbluetable td_role11" align=right title="輸入關鍵字並點選關係人查詢，即顯示關係人資料清單。">
                        關係人名稱(中)：
		            </TD>
		            <TD class=sfont9 colspan="3">
		                <input type=hidden id=tfr_ap_cname_##><input type=hidden id=tfr_apsqlno_##>
		                <INPUT TYPE=text id=tfr_ap_cname1_## name=tfr_ocname1_## SIZE=30 MAXLENGTH=60 alt='『關係人名稱(中)』' onblur='fDataLen(this)'>
		                <INPUT TYPE=text id=tfr_ap_cname2_## name=tfr_ocname2_## SIZE=30 MAXLENGTH=60 alt='『關係人名稱(中)』' onblur='fDataLen(this)'>
		                <INPUT type='button' id='butQ_##' name='butQ_##' value='關係人查詢' onclick="apcust_form.cust13query('##', 'tfr_')"  style='cursor:pointer;' title='輸入關鍵字並點選關係人查詢，即顯示關係人資料清單。'>
		            </TD>
	            </TR>
                <TR>
		            <TD class=lightbluetable align=right>
                        關係人名稱(英)：
		            </TD>
		            <TD class=sfont9 colspan="3">
		                <INPUT TYPE=text id=tfr_ap_ename1_## name=tfr_oename1_## SIZE=60 MAXLENGTH=60 alt='『關係人名稱(英)』' onblur='fDataLen(this)'><br>
		                <INPUT TYPE=text id=tfr_ap_ename2_## name=tfr_oename2_## SIZE=60 MAXLENGTH=60 alt='『關係人名稱(英)』' onblur='fDataLen(this)'>
		            </TD>
	            </TR>
                <TR>
		            <TD class=lightbluetable align=right>
                        關係人代表人(中)：
		            </TD>
		            <TD class=sfont9 colspan="3">
                        <INPUT TYPE=text id=tfr_ap_crep_## name=tfr_ocrep_## SIZE=40 MAXLENGTH=40 alt='『代表人名稱(中)』' onblur='fDataLen(this)'>
		            </TD>
	            </TR>
                <TR>
		            <TD class=lightbluetable align=right>
                        關係人代表人(英)：
		            </TD>
		            <TD class=sfont9 colspan="3">
                        <INPUT TYPE=text id=tfr_ap_erep_## name=tfr_oerep_## SIZE=80 MAXLENGTH=80 alt='『代表人名稱(英)』' onblur='fDataLen(this)'>
		            </TD>
	            </TR>
                <TR>
		            <TD class=lightbluetable align=right>
                        關係人地址(中)：
		            </TD>
		            <TD class=sfont9 colspan="3">
		                <INPUT TYPE=text id=tfr_ap_zip_## name=tfr_ozip_## SIZE=8 MAXLENGTH=8 >
		                <INPUT TYPE=text id=tfr_ap_addr1_## name=tfr_oaddr1_## SIZE=30 MAXLENGTH=60 alt='『地址(中)』' onblur='fDataLen(this)'>
		                <INPUT TYPE=text id=tfr_ap_addr2_## name=tfr_oaddr2_## SIZE=30 MAXLENGTH=60 alt='『地址(中)』' onblur='fDataLen(this)'>
		            </TD>
	            </TR>
                <TR>
		            <TD class=lightbluetable align=right>
                        關係人地址(英)：
		            </TD>
		            <TD class=sfont9 colspan="3">
		                <INPUT TYPE=text id=tfr_ap_eaddr1_## name=tfr_oeaddr1_## SIZE=60 MAXLENGTH=60 alt='『地址(英)』' onblur='fDataLen(this)'><br>
		                <INPUT TYPE=text id=tfr_ap_eaddr2_## name=tfr_oeaddr2_## SIZE=60 MAXLENGTH=60 alt='『地址(英)』' onblur='fDataLen(this)'><br>
		                <INPUT TYPE=text id=tfr_ap_eaddr3_## name=tfr_oeaddr3_## SIZE=60 MAXLENGTH=60 alt='『地址(英)』' onblur='fDataLen(this)'><br>
		                <INPUT TYPE=text id=tfr_ap_eaddr4_## name=tfr_oeaddr4_## SIZE=60 MAXLENGTH=60 alt='『地址(英)』' onblur='fDataLen(this)'>
		                <INPUT TYPE=hidden id=tfr_apatt_tel0_##>
		                <INPUT TYPE=hidden id=tfr_apatt_tel_##>
		                <INPUT TYPE=hidden id=tfr_apatt_tel1_##>
		                <INPUT TYPE=hidden id=tfr_apatt_zip_##>
		                <INPUT TYPE=hidden id=tfr_apatt_fax_##>
		                <INPUT TYPE=hidden id=tfr_apatt_addr1_##>
		                <INPUT TYPE=hidden id=tfr_apatt_addr2_##>
		                <INPUT TYPE=hidden id=tfr_apclass_##>
		                <INPUT TYPE=hidden id=tfr_ap_country_##>
		            </TD>
	            </TR>
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
		</td>
	</tr>	
	<tr class="br_attchstr" style="display:none">
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttz1_Z1" name="ttz1_Z1" value="Z1" onclick="br_form.AttachStr('.br_attchstr','ttz1_',reg.tfzd_remark1)"></td>
		<td class="whitetablebg" colspan="7">移轉契約書或其他移轉證明文件(<input type="checkbox" id="ttz1_Z1C" name="ttz1_Z1C" value="Z1C" onclick="br_form.AttachStr('.br_attchstr','ttz1_',reg.tfzd_remark1)">附中譯本)。</td>
	</tr>
	<tr class="br_attchstr" style="display:none">
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttz1_Z2" name="ttz1_Z2" value="Z2" onclick="br_form.AttachStr('.br_attchstr','ttz1_',reg.tfzd_remark1)"></td>
		<td class="whitetablebg" colspan="7">申請人之代理人委任書(<input type="checkbox" id="ttz1_Z2C" name="ttz1_Z2C" value="Z2C" onclick="br_form.AttachStr('.br_attchstr','ttz1_',reg.tfzd_remark1)">附中譯本)。</td>
	</tr>
	<!--2012/7/1新申請書增加，9/6修改-->
	<tr class="br_attchstr">
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttz1_Z3" name="ttz1_Z3" value="Z3" onclick="br_form.AttachStr('.br_attchstr','ttz1_',reg.tfzd_remark1)"></td>
		<td class="whitetablebg" colspan="7">合意(買賣)移轉：應檢附移轉契約書(<input type="checkbox" id="ttz1_Z3C" name="ttz1_Z3C" value="Z3C" onclick="br_form.AttachStr('.br_attchstr','ttz1_',reg.tfzd_remark1)">附中文譯本)。</td>
	</tr>
	<tr class="br_attchstr">
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttz1_Z4" name="ttz1_Z4" value="Z4" onclick="br_form.AttachStr('.br_attchstr','ttz1_',reg.tfzd_remark1)"></td>
		<td class="whitetablebg" colspan="7">繼承移轉，應檢附下列文件：<br>
			1.原商標權人死亡證明、原商標權人全戶戶籍謄本(由受讓人具結係全戶謄本)、專用權歸屬證明或其他繼承證明文件(如係外文應另附中文譯本)。<br>
			2.稽徵機關核發之稅款繳清證明書，或核定免稅證明書，或不計入遺產總額證明書，或同意移轉證明書之副本，或稽徵機關核發之其他證明文件。
		</td>
	</tr>
	<tr class="br_attchstr">
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttz1_Z5" name="ttz1_Z5" value="Z5" onclick="br_form.AttachStr('.br_attchstr','ttz1_',reg.tfzd_remark1)"></td>
		<td class="whitetablebg" colspan="7">贈與移轉，應檢附下列文件：<br>
			1.贈與契約書(<input type="checkbox" id="ttz1_Z5C" name="ttz1_Z5C" value="Z5C" onclick="br_form.AttachStr('.br_attchstr','ttz1_',reg.tfzd_remark1)">附中文譯本)。<br>
			2.稽徵機關核發之稅款繳清證明書，或核定免稅證明書，或不計入贈與總額證明書，或同意移轉證明書之副本，或稽徵機關核發之其他證明文件。
		</td>
	</tr>
	<tr class="br_attchstr">
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttz1_Z6" name="ttz1_Z6" value="Z6" onclick="br_form.AttachStr('.br_attchstr','ttz1_',reg.tfzd_remark1)"></td>
		<td class="whitetablebg" colspan="7">拍賣移轉：應檢附法院拍定證明影本。
		</td>
	</tr>
	<tr class="br_attchstr">
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttz1_Z7" name="ttz1_Z7" value="Z7" onclick="br_form.AttachStr('.br_attchstr','ttz1_',reg.tfzd_remark1)"></td>
		<td class="whitetablebg" colspan="7">公司合併移轉：應檢附公司合併證明文件(<input type="checkbox" id="ttz1_Z7C" name="ttz1_Z7C" value="Z7C" onclick="br_form.AttachStr('.br_attchstr','ttz1_',reg.tfzd_remark1)">附中文譯本)。
			
		</td>
	</tr>
	<tr class="br_attchstr">
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttz1_Z8" name="ttz1_Z8" value="Z8" onclick="br_form.AttachStr('.br_attchstr','ttz1_',reg.tfzd_remark1)"></td>
		<td class="whitetablebg" colspan="7">團體標章、團體商標、證明標章移轉：移轉契約書及使用規範書或使用規範書之電子檔光碟片(<input type="checkbox" id="ttz1_Z8C" name="ttz1_Z8C" value="Z8C" onclick="br_form.AttachStr('.br_attchstr','ttz1_',reg.tfzd_remark1)">附中文譯本)。
		</td>
	</tr>
	<tr class="br_attchstr">
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttz1_Z9" name="ttz1_Z9" value="Z9" onclick="br_form.AttachStr('.br_attchstr','ttz1_',reg.tfzd_remark1)"></td>
		<td class="whitetablebg" colspan="7">其他。<input TYPE="text" id="ttz1_Z9t" NAME="ttz1_Z9t" SIZE="50" onchange="br_form.AttachStr('.br_attchstr','ttz1_',reg.tfzd_remark1)">
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
<INPUT TYPE=hidden id=tfr_mod_field NAME=tfr_mod_field value="mod_ap">
<INPUT TYPE=hidden id=tfg1_seq NAME=tfg1_seq>
<INPUT TYPE=hidden id=tfg1_seq1 NAME=tfg1_seq1>

<script language="javascript" type="text/javascript">
    //增加一筆關係人
    $("#FT_AP_Add_button").click(function () {
        var nRow = CInt($("#FT_apnum").val()) + 1;
        //複製樣板
        var copyStr = $("#ft_role_template").text() || "";
        copyStr = copyStr.replace(/##/g, nRow);

        $("#FT_tabap>tbody").append("<tr id='tr_ft1_" + nRow + "' class='sfont9'><td><table border='0' class='bluetable' cellspacing='1' cellpadding='2' width='100%'>" + copyStr + "</table></td></tr>");
        $("#tr_ft1_" + nRow + " .Lock").lock();
        $("#FT_apnum").val(nRow);
    });

    //減少一筆關係人
    $("#FT_AP_Del_button").click(function () {
        var nRow = CInt($("#FT_apnum").val());
        $('#tr_ft1_' + nRow).remove();
        $("#FT_apnum").val(Math.max(0, nRow - 1));
    });

    //***授權關係人重抓
    br_form.getapp1_ft = function (nRow) {
        $.ajax({
            type: "get",
            url: getRootPath() + "/ajax/_apcust.aspx?apcust_no=" + $("#tfr_apcust_no_" + nRow).val(),
            async: false,
            cache: false,
            success: function (json) {
                if ($("#chkTest").prop("checked")) toastr.info("<a href='" + this.url + "' target='_new'>Debug(_apcust關係人重抓)！<BR><b><u>(點此顯示詳細訊息)</u></b></a>");
                var apcust_list = $.parseJSON(json);
                if (apcust_list.length == 0) {
                    alert("無該關係人編號!!!");
                    return false;
                }

                $.each(apcust_list, function (i, item) {
                    $("#tfr_apclass_" + nRow).val(item.apclass);
                    $("#tfr_ap_country_" + nRow).val(item.ap_country);
                    $("#tfr_ap_cname1_" + nRow).val(item.ap_cname1);
                    $("#tfr_ap_cname2_" + nRow).val(item.ap_cname2);
                    $("#tfr_ap_ename1_" + nRow).val(item.ap_ename1);
                    $("#tfr_ap_ename2_" + nRow).val(item.ap_ename2);
                    $("#tfr_ap_crep_" + nRow).val(item.ap_crep);
                    $("#tfr_ap_erep_" + nRow).val(item.ap_erep);
                    $("#tfr_ap_addr1_" + nRow).val(item.ap_addr1);
                    $("#tfr_ap_addr2_" + nRow).val(item.ap_addr2);
                    $("#tfr_ap_eaddr1_" + nRow).val(item.ap_eaddr1);
                    $("#tfr_ap_eaddr2_" + nRow).val(item.ap_eaddr2);
                    $("#tfr_ap_eaddr3_" + nRow).val(item.ap_eaddr3);
                    $("#tfr_ap_eaddr4_" + nRow).val(item.ap_eaddr4);
                    $("#tfr_apatt_zip_" + nRow).val(item.apatt_zip);
                    $("#tfr_apatt_addr1_" + nRow).val(item.apatt_addr1);
                    $("#tfr_apatt_addr2_" + nRow).val(item.apatt_addr2);
                    $("#tfr_apatt_tel0_" + nRow).val(item.apatt_tel0);
                    $("#tfr_apatt_tel_" + nRow).val(item.apatt_tel);
                    $("#tfr_apatt_tel1_" + nRow).val(item.apatt_tel1);
                    $("#tfr_apatt_fax_" + nRow).val(item.apatt_fax);
                    $("#tfr_apsqlno_" + nRow).val(item.apsqlno);
                    $("#tfr_ap_zip_" + nRow).val(item.ap_zip);
                })
            },
            error: function (xhr) {
                $("#dialog").html("<a href='" + this.url + "' target='_new'>關係人資料載入失敗！<u>(點此顯示詳細訊息)</u></a><hr>" + xhr.responseText);
                $("#dialog").dialog({ title: '關係人資料載入失敗！', modal: true, maxHeight: 500, width: "90%" });
            }
        });
    }

    //檢查關係人重覆
    //papnum=筆數,pfld=檢查重覆的欄位名,ex:apcust_no_,dbmn_new_no_
    br_form.FT_chkapcust_no = function (papnum, nRow, pfld) {
        var objAp = {};
        for (var r = 1; r <= CInt(papnum) ; r++) {
            var lineAp = $("#" + pfld + "" + r).val();
            if (lineAp != "" && objAp[lineAp]) {
                alert("(" + r + ")關係人重覆，請重新輸入！！");
                $("#" + pfld + nRow).focus();
            } else {
                objAp[lineAp] = { flag: true, idx: r };
            }
        }
    }

    //*****共N件
    br_form.Add_FT1 = function (arcaseCount) {
        if (arcaseCount > 50) {
            alert("移轉案件數不可超過50筆");
            $("#tot_num1,#nfy_tot_num").val("1").focus();
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
                $("#cnt211,#nfy_tot_num").val(nRow + 1);
            }
        } else {
            //要減
            for (var nRow = cnt211; nRow > doCount ; nRow--) {
                $('.trft2_' + nRow).remove();
                $("#cnt211,#nfy_tot_num").val(nRow - 1);
            }
        }
    }

    //交辦內容綁定
    br_form.bindFT1 = function () {
        console.log("ft1.br_form.bind");
        if (jMain.case_main.length == 0) {
            $("#FT_AP_Add_button").click();//關係人預設顯示第1筆
            $("#tot_num21,#nfy_tot_num").val("1").triggerHandler("change");
        } else {
            //代理人
            $("#tfg1_agt_no1").val(jMain.case_main[0].agt_no);
            $("#tfzd_agt_no").val(jMain.case_main[0].agt_no);
            $("#fr_issue_no").val(jMain.case_main[0].issue_no);//註冊號
            $("#fr_appl_name").val(jMain.case_main[0].appl_name);//商標名稱
            //商標種類
            $("input[name=fr_S_Mark][value='" + jMain.case_main[0].s_mark + "']").prop("checked", true);
            //移轉一案多件
            if (main.prgid == "brt52") {
                $("#tot_num21").lock();
                $("#btndseq_okb_1,#btnQueryb_1").hide();
                $("#dseqb_1,#dseq1b_1").lock();
                $("input[name=case_stat1b_1]").lock();
            }
            $("#tot_num21,#nfy_tot_num").val(jMain.case_main[0].tot_num).triggerHandler("change");
            //br_form.Add_FT1(jMain.case_main[0].tot_num);
            if (jMain.case_main[0].seq == "0") {
                $("#dseqb_1").val("");
            } else {
                $("#dseqb_1").val(jMain.case_main[0].seq);
            }
            $("#dseq1b_1").val(jMain.case_main[0].seq1);
            $("#dmseqb_1").val(jMain.case_main[0].ref_no);
            $("#dmseq1b_1").val(jMain.case_main[0].ref_no1);
            $("#btndseq_okb_1").lock();
            $("#keydseqb_1").val("Y");
            $("#s_markb_1").val(jMain.case_main[0].s_marknm);//商標種類
            $("#appl_nameb_1").val(jMain.case_main[0].appl_name);//商標名稱
            $("#issue_nob_1").val(jMain.case_main[0].issue_no);//註冊號
            $.each(jMain.case_dmt1, function (i, item) {
                //填資料
                var nRow = (i+2);//從2開始,第一筆是母案
                $("#dseqb_" + nRow).val(item.seq);
                $("#dseq1b_" + nRow).val(item.seq1);
                $("#dmseqb_" + nRow).val(item.cseq);
                $("#dmseq1b_" + nRow).val(item.cseq1);
                if (main.prgid == "brt51") {
                    $("#but_endb_" + nRow).show();
                }
                if (item.case_stat1 == "NN") {
                    $("input[name='case_stat1b_" + nRow + "'][value='NN']").prop("checked", true);//.triggerHandler("click");
                    $("#s_markb_" + nRow).val(item.s_marknm);
                    $("#appl_nameb_" + nRow).val(item.appl_name);
                    $("#issue_nob_" + nRow).val(item.issue_no);
                    $("#btndmt_tempb_" + nRow).val("案件主檔編修").show();
                    $("#case_sqlnob_" + nRow).val(item.case_sqlno);
                    $("#dseqb_" + nRow).val(item.seq).lock();
                    $("#dseq1b_" + nRow).val(item.seq1).lock();
                    $("#dmseqb_" + nRow).val(item.ref_no);
                    $("#dmseq1b_" + nRow).val(item.ref_no1);
                    if (main.prgid == "brt52") {
                        $("#btndseq_okb_" + nRow + ",#btnQueryb_" + nRow).hide();
                        $("input[name=case_stat1b_" + nRow + " ]").lock();
                    }
                } else {
                    $("input[name='case_stat1b_" + nRow + "'][value='OO']").prop("checked", true);//.triggerHandler("click");
                    $("#btndmt_tempb_" + nRow).hide();
                    if (main.prgid == "brt52") {
                        $("#dseqb_" + nRow).lock();
                        $("#dseq1b_" + nRow).lock();
                    } else {
                        $("#dseqb_" + nRow).unlock();
                        $("#dseq1b_" + nRow).unlock();
                    }
                    $("#btncaseb_" + nRow).show();
                    $("#btnQueryb_" + nRow).show();
                    br_form.btnseqclick(nRow, 'b_');
                    if (main.prgid == "brt52") {
                        $("#btndseq_okb_" + nRow + ",#btnQueryb_" + nRow).hide();
                        $("#btndmt_tempb_" + nRow).val("案件主檔編修").show();
                        $("input[name=case_stat1b_" + nRow + " ]").lock();
                        $("#btncaseb_" + nRow).hide();
                    }
                }
            });

            //關係人
            var tranlist = $(jMain.case_tranlist).filter(function (i, n) { return n.mod_field === 'mod_ap' });
            $.each(tranlist, function (i, item) {
                //增加一筆
                $("#FT_AP_Add_button").click();
                //填資料
                var nRow = $("#FT_apnum").val();
                $("#tfr_apcust_no_" + nRow).val(item.old_no);
                $("#tfr_ap_cname1_" + nRow).val(item.ocname1);
                $("#tfr_ap_cname2_" + nRow).val(item.ocname2);
                $("#tfr_ap_ename1_" + nRow).val(item.oename1);
                $("#tfr_ap_ename2_" + nRow).val(item.oename2);
                $("#tfr_ap_crep_" + nRow).val(item.ocrep);
                $("#tfr_ap_erep_" + nRow).val(item.oerep);
                $("#tfr_ap_addr1_" + nRow).val(item.oaddr1);
                $("#tfr_ap_addr2_" + nRow).val(item.oaddr2);
                $("#tfr_ap_eaddr1_" + nRow).val(item.oeaddr1);
                $("#tfr_ap_eaddr2_" + nRow).val(item.oeaddr2);
                $("#tfr_ap_eaddr3_" + nRow).val(item.oeaddr3);
                $("#tfr_ap_eaddr4_" + nRow).val(item.oeaddr4);
                $("#tfr_apatt_tel0_" + nRow).val(item.otel0);
                $("#tfr_apatt_tel_" + nRow).val(item.otel);
                $("#tfr_apatt_tel1_" + nRow).val(item.otel1);
                $("#tfr_apatt_fax_" + nRow).val(item.ofax);
                $("#tfr_ap_zip_" + nRow).val(item.ozip);
                //$("#tfr_apclass_" + nRow).val(item.oapclass);
                //$("#tfr_ap_country_" + nRow).val(item.oap_country);
                //$("#tfr_ap_cname_" + nRow).val(item.naddr1);
                //$("#tfr_apsqlno_" + nRow).val(item.naddr1);
            });
            if (CInt($("#FT_apnum").val()) == 0) {
                alert("查無此交辦案件之關係人資料!!");
            }

            $("#tfg1_tran_remark1").val(jMain.case_main[0].tran_remark1);//一併設定號數
            $("#tfg1_tran_remark2").val(jMain.case_main[0].tran_remark2);//未一併設定號數
            //附件
            $("#tfzd_remark1").val(jMain.case_main[0].remark1);
            if (jMain.case_main[0].remark1 != "") {
                var arr_remark1 = jMain.case_main[0].remark1.split("|");
                for (var i = 0; i < arr_remark1.length; i++) {
                    //var str="Z3|Z9|Z9-具結書正本、讓與人之負責人身份證影本-Z9|";
                    //var str = "Z9-具結書正本、讓與人之負責人身份證影本-Z9";
                    //var substr = arr_remark1[i].match(/Z9-(\S+)-Z9/);
                    var substr = arr_remark1[i].match(/Z9-([\s\S]+)-Z9/);
                    if (substr != null) {
                        $("#ttz1_Z9t").val(substr[1]);
                    } else {
                        $("#ttz1_" + arr_remark1[i]).prop("checked", true);
                    }
                }
            }
            //**附註
            if (jMain.case_tran[0].other_item.indexOf(";") > -1) {
                var oitem = jMain.case_tran[0].other_item.split(";");
                $("#O_item1").val(oitem[0]);
                $("input[name=O_item2][value='" + oitem[1] + "']").prop("checked", true);
            }
        }
    }
</script>
