<%@ Control Language="C#" ClassName="FL1Form" %>
<%@ Import Namespace = "System.Collections.Generic"%>

<script runat="server">
    //A7授權交辦內容
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

<div id="div_Form_FL1">
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
		<td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:pointer;COLOR:BLUE" onclick="PMARK(L1Appl_name)"><strong>壹、<u>註冊號數、商標(標章)種類及名稱</u></strong></td>
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
		<TABLE border=0 id=tabfl5 class="bluetable"  cellspacing=1 cellpadding=2 width="100%" style="display:none">
        <thead>
		    <tr>
			    <td class="lightbluetable" align="right" width="23%">此次<span id="sp_titlecnt">授權</span>總件數：</td>
			    <td class="whitetablebg"  colspan=3>共<input type="text" id=tot_num21 name=tot_num21 size=2 onchange="br_form.Add_FC21(this.value)" >件
				    <input type=text id=cnt211 name=cnt211 value="0"><!--畫面上有幾筆-->
				    <input type=text id=nfy_tot_num name=nfy_tot_num value="0">
			    </td>
		    </tr>
		    <tr>	
			    <td class="lightbluetable" align="right"><font color="red">(主)</font>案件編號1:</td>
			    <td class="whitetablebg" colspan=3>
                    <input type="text" id=dseqb_1 name=dseqb_1 size=5  maxlength=5 onblur="br_form.seqChange('b_1')" readonly class=sedit>-<input type="text" id=dseq1b_1 name=dseq1b_1 size=1  maxlength=1 value="_" onblur="br_form.seqChange('b_1')" readonly class=sedit>
                    <input type=button class="cbutton" id="btndseq_okb_1" name="btndseq_okb_1" value ="確定" onclick="delayNO(reg.dseqb_1.value,reg.dseq1b_1.value)">
                    <input type=radio value=NN checked id="case_stat1b_1NN" name="case_stat1b_1" onclick="br_form.case_stat1_control('NN','b_1')">新案
                    <input type=radio value=OO id="case_stat1b_1OO" name="case_stat1b_1" onclick="br_form.case_stat1_control('OO','b_1')">舊案
                    <input type=button class="cbutton" id="btnQueryb_1" name="btnQueryb_1" value ="查詢主案件編號" onclick="br_form.btnQueryclick('b_1',reg.F_cust_seq.value)">
                    <input type=button class="cbutton" id="btncaseb_1" name="btncaseb_1"  value ="案件主檔查詢" onclick="br_form.btncaseclick('b_1')">
			　       <input type="text" id=keydseqb_1 name=keydseqb_1 value="N">
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
        <script type="text/html" id="br_fl1_template">
		    <tr class="trfl1_##">
			    <td class="lightbluetable" align="right">本所編號##:</td>
			    <td class="whitetablebg" colspan=3>
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
		    </tr>
		    <tr class="trfl1_##">
			    <td class="lightbluetable" align="right">商標種類##:</td>
			    <td class="whitetablebg" colspan=3><input type=text id=s_markb_## NAME=s_markb_## size=30 readonly></td>
		    </tr>		
		    <tr class="trfl1_##">
			    <td class="lightbluetable" align="right">商標/標章名稱##:</td>
			    <td class="whitetablebg" colspan=3><input type=text id=appl_nameb_## NAME=appl_nameb_## size=30 readonly></td>
		    </tr>		
		    <tr class="trfl1_##">
			    <td class="lightbluetable" align="right">註冊號數##:</td>
			    <td class="whitetablebg" colspan=3><input type=text id=issue_nob_## NAME=issue_nob_## size=30 readonly></td>
		    </tr>
        </script>
		</table>
		</td>
	</tr>
	<tr>
		<td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:pointer;COLOR:BLUE" ONCLICK="PMARK(L1Apcust)"><strong>貳、<u>申請人</u>(此欄請務必勾選)</strong></td>
	</tr>
    <tr>
		<td class=lightbluetable align=right width="18%"></td>
		<td class=whitetablebg colspan="7">
            <input type="radio" name="tfzd_mark" value="A" onclick="br_form.apcust_role('A')"><span id=markA></span>
            <input type="radio" name="tfzd_mark" value="B" onclick="br_form.apcust_role('B')">被授權人<span id=markB></span>
		</TD>
	</tr>
	<tr>
		<td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:pointer;COLOR:BLUE" ONCLICK="PMARK(a1Rapcust)"><span id=role1></span></td>
	</tr>
	<tr>
		<td class=sfont9 colspan="8">
		<input type=hidden id=FL_apnum name=FL_apnum value=0><!--進度筆數-->
		<table border="0" id=FL_tabap class="bluetable" cellspacing="1" cellpadding="1" style="font-size: 9pt" width="100%">
            <thead>
		        <TR>
			        <TD  class=whitetablebg colspan=4 align=right>
				        <input type=button value ="增加一筆被授權人" class="cbutton" id=FL_AP_Add_button name=FL_AP_Add_button>
				        <input type=button value ="減少一筆被授權人" class="cbutton" id=FL_AP_Del_button name=FL_AP_Del_button>
			        </TD>
		        </TR>
            </thead>
            <tbody></tbody>
            <script type="text/html" id="fl_role_template">
	            <TR>
		            <TD class="lightbluetable role9" align=right title="輸入編號並點選確定，即顯示被授權人資料；若無資料，請直接輸入被授權人資料。">
                        <input type=text id='FL_apnum_##' name='FL_apnum_##' class=sedit readonly size=2 value='##.'>
                        <span id='span_FT_Apcust_no_##' style='cursor:pointer;color:blue'><span class="span_role"></span>授權人統編：</span>
		            </TD>
		            <TD class=sfont9 colspan="3">
		                <input TYPE=text ID=tfr_apcust_no_## NAME=tfr_old_no_## SIZE=10 MAXLENGTH=10 onblur="br_form.FL_chkapcust_no(reg.FL_apnum.value,'##','tfr_apcust_no_')">
		                <input type='button' value='確定' onclick="br_form.getapp1_fl('##')" class='btn_role10' name='btn_role10_##' style='cursor:pointer;' title='輸入編號並點選確定，即顯示被授權人資料；若無資料，請直接輸入被授權人資料。'>
		            </TD>
	            </TR>
	            <TR>
		            <TD class=lightbluetable align=right>申請人種類：</TD>
		            <TD class=sfont9>
                        <select ID=tfr_apclass_## name='tfr_oapclass_##' ><%=html_apclass%></select>
		            </TD>
		            <TD class=lightbluetable align=right>申請人國籍：</TD>
		            <TD class=sfont9>
                        <select ID=tfr_ap_country_## name='tfr_oap_country_##' ><%=html_country%></select>
		            </TD>
	            </TR>
                <TR>
		            <TD class="lightbluetable td_role11" align=right title="輸入關鍵字並點選授權人查詢，即顯示被授權人資料清單。">
                        <span class="span_role"></span>授權人名稱(中)：
		            </TD>
		            <TD class=sfont9 colspan="3">
		                <input type=hidden id=tfr_ap_cname_##><input type=hidden id=tfr_apsqlno_##>
		                <INPUT TYPE=text id=tfr_ap_cname1_## name=tfr_ocname1_## SIZE=30 MAXLENGTH=60 alt='『被授權人名稱(中)』' onblur='fDataLen(this)'>
		                <INPUT TYPE=text id=tfr_ap_cname2_## name=tfr_ocname2_## SIZE=30 MAXLENGTH=60 alt='『被授權人名稱(中)』' onblur='fDataLen(this)'>
		                <INPUT type='button' id='butQ_##' name='butQ_##' value='被授權人查詢' onclick="apcust_form.cust13query('##','tfr_')"  style='cursor:pointer;' title='輸入關鍵字並點選關係人查詢，即顯示關係人資料清單。'>
		            </TD>
	            </TR>
                <TR>
		            <TD class=lightbluetable align=right>
                        <span class="span_role"></span>授權人名稱(英)：
		            </TD>
		            <TD class=sfont9 colspan="3">
		                <INPUT TYPE=text id=tfr_ap_ename1_## name=tfr_oename1_## SIZE=60 MAXLENGTH=60 alt='『被授權人名稱(英)』' onblur='fDataLen(this)'><br>
		                <INPUT TYPE=text id=tfr_ap_ename2_## name=tfr_oename2_## SIZE=60 MAXLENGTH=60 alt='『被授權人名稱(英)』' onblur='fDataLen(this)'>
		            </TD>
	            </TR>
                <TR>
		            <TD class=lightbluetable align=right>
                        <span class="span_role"></span>授權人地址(中)：
		            </TD>
		            <TD class=sfont9 colspan="3">
		                <INPUT TYPE=text id=tfr_ap_zip_## name=tfr_ozip## SIZE=8 MAXLENGTH=8 >
		                <INPUT TYPE=text id=tfr_ap_addr1_## name=tfr_oaddr1_## SIZE=30 MAXLENGTH=60 alt='『證照地址(中)』' onblur='fDataLen(this)'>
		                <INPUT TYPE=text id=tfr_ap_addr2_## name=tfr_oaddr2_## SIZE=30 MAXLENGTH=60 alt='『證照地址(中)』' onblur='fDataLen(this)'>
		            </TD>
	            </TR>
                <TR>
		            <TD class=lightbluetable align=right>
                        <span class="span_role"></span>授權人地址(英)：
		            </TD>
		            <TD class=sfont9 colspan="3">
		                <INPUT TYPE=text id=tfr_ap_eaddr1_## name=tfr_oeaddr1_## SIZE=60 MAXLENGTH=60 alt='『證照地址(英)』' onblur='fDataLen(this)'><br>
		                <INPUT TYPE=text id=tfr_ap_eaddr2_## name=tfr_oeaddr2_## SIZE=60 MAXLENGTH=60 alt='『證照地址(英)』' onblur='fDataLen(this)'><br>
		                <INPUT TYPE=text id=tfr_ap_eaddr3_## name=tfr_oeaddr3_## SIZE=60 MAXLENGTH=60 alt='『證照地址(英)』' onblur='fDataLen(this)'><br>
		                <INPUT TYPE=text id=tfr_ap_eaddr4_## name=tfr_oeaddr4_## SIZE=60 MAXLENGTH=60 alt='『證照地址(英)』' onblur='fDataLen(this)'>
		            </TD>
	            </TR>
                <TR>
		            <TD class=lightbluetable align=right>
                        <span class="span_role"></span>授權代表人(中)：
		            </TD>
		            <TD class=sfont9 colspan="3">
                        <INPUT TYPE=text id=tfr_ap_crep_## name=tfr_ocrep_## SIZE=40 MAXLENGTH=40 alt='『代表人名稱(中)』' onblur='fDataLen(this)'>
		            </TD>
	            </TR>
                <TR>
		            <TD class=lightbluetable align=right>
                        <span class="span_role"></span>授權代表人(英)：
		            </TD>
		            <TD class=sfont9 colspan="3">
                        <INPUT TYPE=text id=tfr_ap_erep_## name=tfr_oerep_## SIZE=80 MAXLENGTH=80 alt='『代表人名稱(英)』' onblur='fDataLen(this)'>
		                <INPUT TYPE=hidden id=tfr_apatt_tel0_##>
		                <INPUT TYPE=hidden id=tfr_apatt_tel_##>
		                <INPUT TYPE=hidden id=tfr_apatt_tel1_##>
		                <INPUT TYPE=hidden id=tfr_apatt_zip_##>
		                <INPUT TYPE=hidden id=tfr_apatt_fax_##>
		                <INPUT TYPE=hidden id=tfr_apatt_addr1_##>
		                <INPUT TYPE=hidden id=tfr_apatt_addr2_##>
		            </TD>
	            </TR>
            </script>
		</table>
		</td>
	</tr>
    <tr>
	    <td class=lightbluetable valign=top colspan=8 STYLE="cursor:pointer;COLOR:BLUE" ONCLICK="PMARK(a1term1)"><strong><span id=term></span></strong></td>
    </tr>
	<tr >
		<td id="td_tm1" class=lightbluetable align=right rowspan=2><span id=tg_term1></span>：</td>
		<td id=term1 class=whitetablebg colspan=3><input type="radio" name="tfg1_mod_claim1" id="tfg1_mod_claim1B" value="B">自<input type=text id=tfg1_term1 name=tfg1_term1 size=10 class="dateField">(年/月/日)<span id=tg_term2></span></td>
		<td id=term2 class=whitetablebg colspan=4>至<input type=text id=tfg1_term2 name=tfg1_term2 size=10 class="dateField">(年/月/日)</td>   
	</tr>
	<tr id="tr_claim1">
		<td class=whitetablebg colspan=3><input type="radio" name="tfg1_mod_claim1" id="tfg1_mod_claim1E" value="E">自<input type=text id=fl_term1 name=fl_term1 size=10 class="dateField">(年/月/日)</td>
		<td class=whitetablebg colspan=4>至<input type=text id=tfg1_other_item1 name=tfg1_other_item1 size=50></td>   
	</tr>
	<tr id="tr_type">
		<td class=lightbluetable valign=top colspan=8 STYLE="cursor:pointer;COLOR:BLUE" ><strong><span id=tg_type></span></strong></td>
	</tr>
	<tr id="tr_type1">
		<td class=lightbluetable align=right ></td>
		<td class=whitetablebg colspan=3><input type="radio" name="tfg1_mod_claim2" id="tfg1_mod_claim2A" value="A">專屬授權</td>
		<td class=whitetablebg colspan=4><input type="radio" name="tfg1_mod_claim2" id="tfg1_mod_claim2B" value="B">非專屬授權</td>   
	</tr>
	<tr id="tr_area">
		<td class=lightbluetable valign=top colspan=8 STYLE="cursor:pointer;COLOR:BLUE" ><strong><span id=tg_area></span></strong></td>
	</tr>
	<tr id="tr_area1">
		<td class=lightbluetable align=right ></td>
		<td class=whitetablebg colspan=3><input type="radio" name="other_item2" id="other_item2T" value="T">中華民國全境</td>
		<td class=whitetablebg colspan=4><input type="radio" name="other_item2" id="other_item2O" value="O">其他：<input type=text id="other_item2t" name="other_item2t" size=48></td>   
	</tr>
	<tr id=remark style="display:">
		<td class=lightbluetable valign=top colspan=8 STYLE="cursor:pointer;COLOR:BLUE" ONCLICK="PMARK(a1Good)"><strong><span id=tg_good></span></strong></td>
	</tr>
	<tr id=mark1 style="display:">
		<td class=lightbluetable align=right ></td>
		<td class=whitetablebg colspan=7><input type=radio id=tfl1_mod_typeA name=tfl1_mod_type value="All">全部授權(即原授權之商品/服務全部授權者)</td>
	</tr>
	<tr id=mark2 style="display:">
		<td class=lightbluetable align=right ></td>
		<td class=whitetablebg colspan=7><input type=radio id=tfl1_mod_typeP name=tfl1_mod_type value="Part">部份授權(請按商品/服務類別分別填寫商品/服務名稱類別)</td>
	</tr>
	<tr id=remark1 style="display:">
		<td colspan=8 class=sfont9>
		<TABLE id=tabbr2 style="display:" border=0 class="bluetable"  cellspacing=1 cellpadding=2 width="100%">
        <thead>
		<tr>
			<td class="lightbluetable" align="right">類別項目：</td>
			<td class="whitetablebg" colspan="7" >共<input type="text" id=mod_count name=mod_count size=2 onchange="br_form.Add_class(this.value,'#num2','#br_class_template','#tabbr2 tbody')">類<input type="text" id="mod_dclass" name="mod_dclass" readonly>
				<input type=hidden id=ctrlnum2 name=ctrlnum2 value="0">
				<input type=hidden id=ctrlcount2 name=ctrlcount2 value="">
				<input type=hidden id=num2 name=num2 value="0"><!--畫面上有幾筆-->
				<input type=hidden id=tfg1_mod_class name=tfg1_mod_class>
			</td>
		</tr>
        </thead>
        <tbody></tbody>
        <script type="text/html" id="br_class_template"><!--類別樣板-->
		<tr class="br_class_template_##">
			<td class="lightbluetable" align="right" style="cursor:pointer" title="請輸入類別，並以逗號分開(例如：1,5,32)。或輸入類別範圍，並以  -  (半形) 分開(例如：8-16)。也可複項組合(例如：3,5,13-32,35)">類別##：</td>		
			<td class="whitetablebg" colspan="7">第<INPUT type="text" id=new_no_## name=new_no_## size=3 maxlength=3 onchange="br_form.count_kind('##')">類</td>		
		</tr>
		<tr class="br_class_template_##" style="height:107.6pt">
			<td class="lightbluetable" align="right" width="18%">商品名稱##：</td>
			<td class="whitetablebg" colspan="7">
                <textarea id="list_remark_##" NAME="list_remark_##" ROWS="10" COLS="75" onchange="br_form.good_name_count('list_remark_##','')"></textarea>
			</td>
		</tr>		
        </script>
		</table>
		</td>
	</tr>
	<tr>
		<td class="lightbluetable" colspan="8" valign="top"  STYLE="cursor:pointer;COLOR:BLUE" ONCLICK="PMARK(zAttech)"><strong><span id=tg_attech></span></strong></td>
	</tr>
	<tr class=whitetablebg>
	    <td colspan=8><input type=hidden id="tfzd_remark1" name="tfzd_remark1" value="">
	    <!--FL1的附件畫面-->
	    <TABLE id=tabrem1 style="display:" border=0 class="bluetable"  cellspacing=1 cellpadding=2 width="100%">			
	    <tr >
		    <td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttz1_Z4" NAME="ttz1_Z4" value="Z4" onclick="br_form.AttachStr('#tabrem1', 'ttz1_', reg.tfzd_remark1)"></td>
		    <td class="whitetablebg" colspan="7">委任書(<input TYPE="checkbox" id="ttz1_Z4C" NAME="ttz1_Z4C" value="Z4C" onclick="br_form.AttachStr('#tabrem1','ttz1_',reg.tfzd_remark1)">附中文譯本)。</td>
	    </tr>
	    <tr>
		    <td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttz1_Z1" NAME="ttz1_Z1" value="Z1" onclick="br_form.AttachStr('#tabrem1','ttz1_',reg.tfzd_remark1)"></td>
		    <td class="whitetablebg" colspan="7">授權契約書或其他授權證明文件(<input type="checkbox" id="ttz1_Z1C" name="ttz1_Z1C" value="Z1C" onclick="br_form.AttachStr('#tabrem1','ttz1_',reg.tfzd_remark1)">附中譯本)。</td>
	    </tr>
	    <tr style="display:none">
		    <td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttz1_Z2" NAME="ttz1_Z2" value="Z2" onclick="br_form.AttachStr('#tabrem1','ttz1_',reg.tfzd_remark1)"></td>
		    <td class="whitetablebg" colspan="7">商標權人之代理人委任書(<input TYPE="checkbox" id="ttz1_Z2C" NAME="ttz1_Z2C" value="Z2C" onclick="br_form.AttachStr('#tabrem1','ttz1_',reg.tfzd_remark1)">附中譯本)。</td>
	    </tr>
	    <tr style="display:none">
		    <td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttz1_Z3" NAME="ttz1_Z3" value="Z3" onclick="br_form.AttachStr('#tabrem1','ttz1_',reg.tfzd_remark1)"></td>
		    <td class="whitetablebg" colspan="7">被授權人之代理人委任書(<input TYPE="checkbox" id="ttz1_Z3C" NAME="ttz1_Z3C" value="Z3C" onclick="br_form.AttachStr('#tabrem1','ttz1_',reg.tfzd_remark1)">附中譯本)。</td>
	    </tr>
	    <tr>
		    <td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttz1_Z9" NAME="ttz1_Z9" value="Z9" onclick="br_form.AttachStr('#tabrem1','ttz1_',reg.tfzd_remark1)"></td>
		    <td class="whitetablebg" colspan="7">其他。<input TYPE="text" id="ttz1_Z9t" NAME="ttz1_Z9t" SIZE="50" onchange="br_form.AttachStr('#tabrem1','ttz1_',reg.tfzd_remark1)"></td>
	    </tr>	
	    </table>
	    <!--FL2的附件畫面-->
	    <TABLE id=tabrem2 style="display:none" border=0 class="bluetable"  cellspacing=1 cellpadding=2 width="100%">			
	    <tr >
		    <td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttz2_Z5" NAME="ttz2_Z5" value="Z5" onclick="br_form.AttachStr('#tabrem2','ttz2_',reg.tfzd_remark1)"></td>
		    <td class="whitetablebg" colspan="7">委任書(<input TYPE="checkbox" id="ttz2_Z5C" NAME="ttz2_Z5C" value="Z5C" onclick="br_form.AttachStr('#tabrem2','ttz2_',reg.tfzd_remark1)">附中文譯本)。</td>
	    </tr>
	    <tr>
		    <td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttz2_Z1" NAME="ttz2_Z1" value="Z1" onclick="br_form.AttachStr('#tabrem2','ttz2_',reg.tfzd_remark1)"></td>
		    <td class="whitetablebg" colspan="7">再授權契約書或其他再授權證明文件(<input type="checkbox" id="ttz2_Z1C" name="ttz2_Z1C" value="Z1C" onclick="br_form.AttachStr('#tabrem2','ttz2_',reg.tfzd_remark1)">附中文譯本)。</td>
	    </tr>
	    <tr style="display:none">
		    <td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttz2_Z2" NAME="ttz2_Z2" value="Z2" onclick="br_form.AttachStr('#tabrem2','ttz2_',reg.tfzd_remark1)"></td>
		    <td class="whitetablebg" colspan="7">授權人之代理人委任書(<input TYPE="checkbox" id="ttz2_Z2C" NAME="ttz2_Z2C" value="Z2C" onclick="br_form.AttachStr('#tabrem2','ttz2_',reg.tfzd_remark1)">附中譯本)。</td>
	    </tr>
	    <tr style="display:none">
		    <td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttz2_Z3" NAME="ttz2_Z3" value="Z3" onclick="br_form.AttachStr('#tabrem2','ttz2_',reg.tfzd_remark1)"></td>
		    <td class="whitetablebg" colspan="7">被授權人之代理人委任書(<input TYPE="checkbox" id="ttz2_Z3C" NAME="ttz2_Z3C" value="Z3C" onclick="br_form.AttachStr('#tabrem2','ttz2_',reg.tfzd_remark1)">附中譯本)。</td>
	    </tr>
	    <tr>
		    <td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttz2_Z4" NAME="ttz2_Z4" value="Z4" onclick="br_form.AttachStr('#tabrem2','ttz2_',reg.tfzd_remark1)"></td>
		    <td class="whitetablebg" colspan="7">商標權人同意再授權證明文件。</td>
	    </tr>	
	    <tr>
		    <td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttz2_Z9" NAME="ttz2_Z9" value="Z9" onclick="br_form.AttachStr('#tabrem2','ttz2_',reg.tfzd_remark1)"></td>
		    <td class="whitetablebg" colspan="7">其他。<input TYPE="text" id="ttz2_Z9t" NAME="ttz2_Z9t" SIZE="50" onchange="br_form.AttachStr('#tabrem2','ttz2_',reg.tfzd_remark1)"></td>
	    </tr>	
	    </table>
	    <!--FL3的附件畫面-->
	    <TABLE id=tabrem3 style="display:none" border=0 class="bluetable"  cellspacing=1 cellpadding=2 width="100%">			
	    <tr >
		    <td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttz3_Z4" NAME="ttz3_Z4" value="Z4" onclick="br_form.AttachStr('#tabrem3','ttz3_',reg.tfzd_remark1)"></td>
		    <td class="whitetablebg" colspan="7">委任書(<input TYPE="checkbox" id="ttz3_Z4C" NAME="ttz3_Z4C" value="Z4C" onclick="br_form.AttachStr('#tabrem3','ttz3_',reg.tfzd_remark1)">附中文譯本)。</td>
	    </tr>
	    <tr>
		    <td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttz3_Z1" NAME="ttz3_Z1" value="Z1" onclick="br_form.AttachStr('#tabrem3','ttz3_',reg.tfzd_remark1)"></td>
		    <td class="whitetablebg" colspan="7">廢止授權契約書或其他廢止授權證明文件(<input type="checkbox" id="ttz3_Z1C" name="ttz3_Z1C" value="Z1C" onclick="br_form.AttachStr('#tabrem3','ttz3_',reg.tfzd_remark1)">附中文譯本)。</td>
	    </tr>
	    <tr style="display:none">
		    <td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttz3_Z2" NAME="ttz3_Z2" value="Z2" onclick="br_form.AttachStr('#tabrem3','ttz3_',reg.tfzd_remark1)"></td>
		    <td class="whitetablebg" colspan="7">商標權人之代理人委任書(<input TYPE="checkbox" id="ttz3_Z2C" NAME="ttz3_Z2C" value="Z2C" onclick="br_form.AttachStr('#tabrem3','ttz3_',reg.tfzd_remark1)">附中譯本)。</td>
	    </tr>
	    <tr style="display:none">
		    <td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttz3_Z3" NAME="ttz3_Z3" value="Z3" onclick="br_form.AttachStr('#tabrem3','ttz3_',reg.tfzd_remark1)"></td>
		    <td class="whitetablebg" colspan="7">被授權人之代理人委任書(<input TYPE="checkbox" id="ttz3_Z3C" NAME="ttz3_Z3C" value="Z3C" onclick="br_form.AttachStr('#tabrem3','ttz3_',reg.tfzd_remark1)">附中譯本)。</td>
	    </tr>
	    <tr>
		    <td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttz3_Z9" NAME="ttz3_Z9" value="Z9" onclick="br_form.AttachStr('#tabrem3','ttz3_',reg.tfzd_remark1)"></td>
		    <td class="whitetablebg" colspan="7">其他。<input TYPE="text" id="ttz3_Z9t" NAME="ttz3_Z9t" SIZE="50" onchange="br_form.AttachStr('#tabrem3','ttz3_',reg.tfzd_remark1)"></td>
	    </tr>	
	    </table>
	    <!--FL4的附件畫面-->
	    <TABLE id=tabrem4 style="display:none" border=0 class="bluetable"  cellspacing=1 cellpadding=2 width="100%">			
	    <tr >
		    <td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttz4_Z4" NAME="ttz4_Z4" value="Z4" onclick="br_form.AttachStr('#tabrem4','ttz4_',reg.tfzd_remark1)"></td>
		    <td class="whitetablebg" colspan="7">委任書(<input TYPE="checkbox" id="ttz4_Z4C" NAME="ttz4_Z4C" value="Z4C" onclick="br_form.AttachStr('#tabrem4','ttz4_',reg.tfzd_remark1)">附中文譯本)。</td>
	    </tr>
	    <tr>
		    <td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttz4_Z1" NAME="ttz4_Z1" value="Z1" onclick="br_form.AttachStr('#tabrem4','ttz4_',reg.tfzd_remark1)"></td>
		    <td class="whitetablebg" colspan="7">廢止再授權契約書或其他廢止再授權證明文件(<input type="checkbox" id="ttz4_Z1C" name="ttz4_Z1C" value="Z1C" onclick="br_form.AttachStr('#tabrem4','ttz4_',reg.tfzd_remark1)">附中文譯本)。</td>
	    </tr>
	    <tr style="display:none">
		    <td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttz4_Z2" NAME="ttz4_Z2" value="Z2" onclick="br_form.AttachStr('#tabrem4','ttz4_',reg.tfzd_remark1)"></td>
		    <td class="whitetablebg" colspan="7">授權人之代理人委任書(<input TYPE="checkbox" id="ttz4_Z2C" NAME="ttz4_Z2C" value="Z2C" onclick="br_form.AttachStr('#tabrem4','ttz4_',reg.tfzd_remark1)">附中譯本)。</td>
	    </tr>
	    <tr style="display:none">
		    <td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttz4_Z3" NAME="ttz4_Z3" value="Z3" onclick="br_form.AttachStr('#tabrem4','ttz4_',reg.tfzd_remark1)"></td>
		    <td class="whitetablebg" colspan="7">被授權人之代理人委任書(<input TYPE="checkbox" id="ttz4_Z3C" NAME="ttz4_Z3C" value="Z3C" onclick="br_form.AttachStr('#tabrem4','ttz4_',reg.tfzd_remark1)">附中譯本)。</td>
	    </tr>
	    <tr>
		    <td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttz4_Z9" NAME="ttz4_Z9" value="Z9" onclick="br_form.AttachStr('#tabrem4','ttz4_',reg.tfzd_remark1)"></td>
		    <td class="whitetablebg" colspan="7">其他。<input TYPE="text" id="ttz4_Z9t" NAME="ttz4_Z9t" SIZE="50" onchange="br_form.AttachStr('#tabrem4','ttz4_',reg.tfzd_remark1)"></td>
	    </tr>	
	    </table>
	</td>
	</tr>
	<tr id=tg_FL1 style="display:none">
		<td class=lightbluetable ROWSPAN=2 align=right><strong>附註：</strong></td>
		<td class=whitetablebg colspan=7>本件商標(標章)於<INPUT type=text id=O_item1 name=O_item1 size=10 class="dateField">(年/月/日)</td>
	</tr>
	<tr id=tg_FL2 style="display:none">
		<td class=whitetablebg colspan=7>另案辦理<INPUT type="radio" id=O_item2FT1 name=O_item2 value="FT1">移轉案
													<INPUT type="radio" id=O_item2FP1 name=O_item2 value="FP1">質權案
													<INPUT type="radio" id=O_item2FI1 name=O_item2 value="FI1">補證案
													<INPUT type="radio" id=O_item2FC1 name=O_item2 value="FC1">變更案
													<INPUT type="radio" id=O_item2FR1 name=O_item2 value="FR1">延展案
													<INPUT type="radio" id=O_item2FL2 name=O_item2 value="FL2"><span id=oth_FL></span></TD>
	</tr>
</table>
</div>
<INPUT TYPE=text id=tfr_mod_field NAME=tfr_mod_field value="mod_ap">
<INPUT TYPE=text id=tfg1_seq NAME=tfg1_seq>
<INPUT TYPE=text id=tfg1_seq1 NAME=tfg1_seq1>

<script language="javascript" type="text/javascript">
    //申請人種類
    br_form.apcust_role = function (role) {
        if (role == "A") {
            $("#role1").html("伍、<u>被授權人</u>");
            $("#FL_AP_Add_button").val("增加一筆被授權人");
            $("#FL_AP_Del_button").val("減少一筆被授權人");
            $(".span_role").html("被");
            $(".role9").attr("title", "輸入編號並點選確定，即顯示被授權人資料；若無資料，請直接輸入被授權人資料。");
            $(".btn_role10").attr("title", "輸入編號並點選確定，即顯示被授權人資料；若無資料，請直接輸入被授權人資料。");
            $(".td_role11").attr("title", "輸入關鍵字並點選被授權人查詢，即顯示被授權人資料清單。");
            $("input[id^='tfr_ap_cname1_'],input[id^='tfr_ap_cname2_']").attr("alt", "『被授權人名稱(中)』");
            $("input[id^='butQ_']").attr("title", "輸入關鍵字並點選被授權人查詢，即顯示被授權人資料清單。").val("被授權人查詢");
        } else if (role == "B") {
            $("#role1").html("參、<u>授權人</u>");
            $("#FL_AP_Add_button").val("增加一筆授權人");
            $("#FL_AP_Del_button").val("減少一筆授權人");
            $(".span_role").html("");
            $(".role9").attr("title", "輸入編號並點選確定，即顯示授權人資料；若無資料，請直接輸入授權人資料。");
            $(".btn_role10").attr("title", "輸入編號並點選確定，即顯示授權人資料；若無資料，請直接輸入授權人資料。");
            $(".td_role11").attr("title", "輸入關鍵字並點選授權人查詢，即顯示授權人資料清單。");
            $("input[id^='tfr_ap_cname1_'],input[id^='tfr_ap_cname2_']").attr("alt", "『授權人名稱(中)』");
            $("input[id^='butQ_']").attr("title", "輸入關鍵字並點選授權人查詢，即顯示授權人資料清單。").val("授權人查詢");
        }
    }

    //增加一筆關係人
    $("#FL_AP_Add_button").click(function () {
        var nRow = CInt($("#FL_apnum").val()) + 1;
        //複製樣板
        var copyStr = $("#fl_role_template").text() || "";
        copyStr = copyStr.replace(/##/g, nRow);

        $("#FL_tabap>tbody").append("<tr id='tr_fl1_" + nRow + "' class='sfont9'><td><table border='0' class='bluetable' cellspacing='1' cellpadding='2' width='100%'>" + copyStr + "</table></td></tr>");
        $("#tr_fl1_" + nRow + " .Lock").lock();
        $("#FL_apnum").val(nRow);

        //申請人角色顯示授權人或被授權人
        $("input[name='tfzd_mark']:checked").triggerHandler("click");
    });

    //減少一筆關係人
    $("#FL_AP_Del_button").click(function () {
        var nRow = CInt($("#FL_apnum").val());
        $('#tr_fl1_' + nRow).remove();
        $("#FL_apnum").val(Math.max(0, nRow - 1));
    });

    //***關係人重抓
    br_form.getapp1_fl = function (nRow) {
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
                $("#dialog").dialog({ title: '關係人資料載入失敗！', modal: true, maxHeight: 500, width: 800 });
                //toastr.error("<a href='" + this.url + "' target='_new'>關係人資料載入失敗！<BR><b><u>(點此顯示詳細訊息)</u></b></a>");
            }
        });
    }

    //檢查關係人重覆
    //papnum=筆數,pfld=檢查重覆的欄位名,ex:apcust_no_,dbmn_new_no_
    br_form.FL_chkapcust_no = function (papnum, nRow, pfld) {
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

    //類別串接
    br_form.count_kind = function (nRow) {
        if ($("#new_no_" + nRow).val() != "") {
            if (IsNumeric($("#new_no_" + nRow).val())) {
                var x = ("000" + $("#new_no_" + nRow).val()).Right(3);//補0
                $("#new_no_" + nRow).val(x);
                br_form.checkclass(x);
            } else {
                alert("商品類別請輸入數值!!!");
                $("#new_no_" + nRow).val("");
            }
        }

        var nclass = $("#tabbr2>tbody input[id^='new_no_']").map(function (index) {
            if (index == 0 || $(this).val() != "") return $(this).val();
        });
        $("#mod_dclass").val(nclass.get().join(','));
        $("#mod_count").val(Math.max(CInt($("#mod_count").val()), nclass.length));//回寫共N類
    }

    //*****共N件
    br_form.Add_FC21 = function (arcaseCount) {
        if(arcaseCount>50){
            alert("變更案件數不可超過50筆");
            $("#tot_num1").val("1").focus();
            return false;
        }

        var doCount = CInt(arcaseCount);//要改為幾筆
        var cnt211 = Math.max(1, CInt($("#cnt211").val()));//目前畫面上有幾筆,最少是1
        if (doCount > cnt211) {//要加
            for (var nRow = cnt211; nRow < doCount ; nRow++) {
                var copyStr = $("#br_fl1_template").text() || "";
                copyStr = copyStr.replace(/##/g, nRow + 1);
                if(nRow%2!=0) copyStr = copyStr.replace(/whitetablebg/g,"greentablebg");
                $("#tabfl5 tbody").append(copyStr);
                if(nRow%2!=0) {
                    $(".trfl1_"+(nRow + 1)+" input[type=text]").attr("class","sedit2");
                }else{
                    $(".trfl1_"+(nRow + 1)+" input[type=text]").attr("class","SEdit");
                }
                $("#submitTaskb_"+(nRow + 1)).val(main.submittask);
                $("#cnt211").val(nRow + 1);
            }
        } else {
            //要減
            for (var nRow = cnt211; nRow > doCount ; nRow--) {
                $('.trfl1_' + nRow).remove();
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
                    var dmt_list = $.parseJSON(json);
                    if (dmt_list.length > 0) {
                        var backflag_fldname="A9Z";
                        $("#s_mark"+fld+nRow).val(dmt_list[0].smarknm);
                        $("#appl_name"+fld+nRow).val(dmt_list[0].appl_name);
                        $("#apply_no" + fld + nRow).val(dmt_list[0].apply_no);
                        $("#issue_no" + fld + nRow).val(dmt_list[0].issue_no);
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
        var value1=$("#dseq"+nRow).val();
        var value2=$("#dseq1"+nRow).val();
        if(value1==""){
            alert("請先輸入本所編號!!!");
            $("#dseq"+nRow).focus();
            return false;
        }else{
            //***todo
            var url = getRootPath() + "/brt5m/brt15ShowFP.asp?seq="+value1+"&seq1="+value2 + "&submittask=Q";
            window.showModalDialog(url,"","dialogHeight: 540px; dialogWidth: 800px; center: Yes;resizable: No; status: No;scrollbars:yes");
        }
    }

    br_form.seqChange = function (nRow){
        $("#keydseq"+nRow).val("N")//有變動給N
        $("#btndseq_ok"+nRow).prop("disabled",false);
    }

    //交辦內容綁定
    br_form.bindFL1 = function () {
        console.log("fl1.br_form.bind");
        if (jMain.case_main.length == 0) {
        } else {
        }
    }
</script>
