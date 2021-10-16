<%@ Control Language="C#" ClassName="FP1Form" %>
<%@ Import Namespace = "System.Collections.Generic"%>

<script runat="server">
    //A9質權交辦內容
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

<div id="div_Form_FP1">
<%=Sys.GetAscxPath(this.AppRelativeVirtualPath)%>
<TABLE border=0 class=bluetable cellspacing=1 cellpadding=2 width="100%">
	<tr>
		<td class="lightbluetable" valign="top" ><strong>參、代理人</strong></td>
		<td class="whitetablebg" colspan="7" >
		    <select id="tfg1_agt_no1" NAME="tfg1_agt_no1"><%#tfg1_agt_no1%></select>
		    <input type="hidden" id="tfg2_agt_no1" name="tfg2_agt_no1">
            <!--input type="hidden" id="tfzd_agt_no" name="tfzd_agt_no"-->
		</td>
	</tr>
    <tr>
	    <td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:pointer;COLOR:BLUE" ONCLICK="PMARK(h1Appl_name)">
            <strong>壹、<u>註冊號數、商標(標章)種類及名稱</u></strong>
	    </td>
    </tr>
	<tr>
		<td class=lightbluetable align=right >註冊號數：</td>
		<td class=whitetablebg colspan="3"><input type="text" id="fr1_issue_no" name="fr1_issue_no" value="" size="20" maxlength="20" onchange="reg.tfzd_issue_no.value=this.value"></TD>
		<td class=lightbluetable align=right >商標/標章名稱：</td>
		<td class=whitetablebg colspan="3"><input type="text" id="fr1_appl_name" name="fr1_appl_name" class="onoff" value="" size="30" maxlength="100" onchange="reg.tfzd_appl_name.value=this.value"></TD>
	</tr>
	<tr>
		<td class=lightbluetable align=right >商標種類：</td>
		<td class=whitetablebg colspan="7">
			<input type=radio name=fr1_S_Mark class="onoff" value="" onclick="dmt_form.change_mark(1, this)">商標
			<input type=radio name=fr1_S_Mark class="onoff" value="S" onclick="dmt_form.change_mark(1, this)">92年修正前服務標章
			<span id=smark2 style="display:none">
			<input type=radio name=fr1_S_Mark class="onoff" value="N" onclick="dmt_form.change_mark(1, this)">團體商標
			<input type=radio name=fr1_S_Mark class="onoff" value="M" onclick="dmt_form.change_mark(1, this)">團體標章
			<input type=radio name=fr1_S_Mark class="onoff" value="L" onclick="dmt_form.change_mark(1, this)">證明標章
			</span>
		</TD>
	</tr>
	<tr>
		<td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:pointer;COLOR:BLUE" ONCLICK="PMARK(l1Apcust)"><strong>貳、<u>申請人</u>(此欄請務必勾選)</strong></td>
	</tr>
	<tr>
		<td class=lightbluetable align=right width="18%"></td>
		<td class=whitetablebg colspan="7">
            <input type="radio" name="tfzd_Mark" class="onoff" value="A" onclick="br_form.apcust_role('A')"><span id=markA>商標權人</span>
            <input type="radio" name="tfzd_Mark" class="onoff" value="B" onclick="br_form.apcust_role('B')"><span id=markB>質權人</span>
		</TD>
	</tr>
	<tr>
		<td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:pointer;COLOR:BLUE" ONCLICK="PMARK(H1Rapcust)">
            <strong><span id=role1>伍、<u>質權人</u></span></strong>
        </td>
	</tr>
	<tr class='sfont9'>
		<td colspan="8">
		    <input type=hidden id=FT_apnum name=FT_apnum value=0><!--進度筆數-->
		    <table border="0" id=FT_tabap class="bluetable" cellspacing="1" cellpadding="1" width="100%">
            <thead>
		        <TR>
			        <TD  class=whitetablebg colspan=4 align=right>
				        <input type=button value ="增加一筆質權人" class="cbutton" id=FT_AP_Add_button name=FT_AP_Add_button>
				        <input type=button value ="減少一筆質權人" class="cbutton" id=FT_AP_Del_button name=FT_AP_Del_button>
			        </TD>
		        </TR>
            </thead>
            <tbody></tbody>
            <script type="text/html" id="br_role_template">
	            <TR>
		            <TD class="lightbluetable role9" align=right title="輸入編號並點選確定，即顯示質權人資料；若無資料，請直接輸入質權人資料。">
                        <input type=text id='FT_apnum_##' name='FT_apnum_##' class=SEdit readonly size=2 value='##.'>
                        <span id='span_FT_Apcust_no_##' style='cursor:pointer;color:blue'><span class="span_role">質權</span>人統一編號：</span>
		            </TD>
		            <TD class=sfont9 colspan="3">
		                <input TYPE=text ID=tfr1_apcust_no_## NAME=tfr1_apcust_no_## SIZE=10 MAXLENGTH=10 onblur="br_form.FT_chkapcust_no(reg.FT_apnum.value,'##','tfr1_apcust_no_')">
		                <input type='button' value='確定' onclick="br_form.getapp1_ft('##')" class='btn_role10' name='btn_role10_##' style='cursor:pointer;' title='輸入編號並點選確定，即顯示質權人資料；若無資料，請直接輸入質權人資料。'>
		            </TD>
	            </TR>
	            <TR>
		            <TD class=lightbluetable align=right>申請人種類：</TD>
		            <TD class=sfont9>
                        <select ID=tfr1_apclass_## name='tfr1_oapclass_##' ><%=html_apclass%></select>
		            </TD>
		            <TD class=lightbluetable align=right>申請人國籍：</TD>
		            <TD class=sfont9>
                        <select ID=tfr1_ap_country_## name='tfr1_oap_country_##' ><%=html_country%></select>
		            </TD>
	            </TR>
                <TR>
		            <TD class="lightbluetable td_role11" align=right title="輸入關鍵字並點選質權人查詢，即顯示質權人資料清單。">
                        <span class="span_role">質權</span>人名稱(中)：
		            </TD>
		            <TD class=sfont9 colspan="3">
		                <input type=hidden id=tfr1_ap_cname_##><input type=hidden id=tfr1_apsqlno_##>
		                <INPUT TYPE=text id=tfr1_ap_cname1_## name=tfr1_ap_cname1_## SIZE=30 MAXLENGTH=60 alt='『質權人名稱(中)』' onblur='fDataLen(this)'>
		                <INPUT TYPE=text id=tfr1_ap_cname2_## name=tfr1_ap_cname2_## SIZE=30 MAXLENGTH=60 alt='『質權人名稱(中)』' onblur='fDataLen(this)'>
		                <INPUT type='button' id='butQ_##' name='butQ_##' value='質權人查詢' onclick="apcust_form.cust13query('##','tfr1_')"  style='cursor:pointer;' title='輸入關鍵字並點選關係人查詢，即顯示關係人資料清單。'>
		            </TD>
	            </TR>
                <TR>
		            <TD class=lightbluetable align=right>
                        <span class="span_role">質權</span>人名稱(英)：
		            </TD>
		            <TD class=sfont9 colspan="3">
		                <INPUT TYPE=text id=tfr1_ap_ename1_## name=tfr1_ap_ename1_## SIZE=60 MAXLENGTH=60 alt='『關係人名稱(英)』' onblur='fDataLen(this)'><br>
		                <INPUT TYPE=text id=tfr1_ap_ename2_## name=tfr1_ap_ename2_## SIZE=60 MAXLENGTH=60 alt='『關係人名稱(英)』' onblur='fDataLen(this)'>
		            </TD>
	            </TR>
                <TR>
		            <TD class=lightbluetable align=right>
                        <span class="span_role">質權</span>人代表人(中)：
		            </TD>
		            <TD class=sfont9 colspan="3">
                        <INPUT TYPE=text id=tfr1_ap_crep_## name=tfr1_ap_crep_## SIZE=40 MAXLENGTH=40 alt='『代表人名稱(中)』' onblur='fDataLen(this)'>
		            </TD>
	            </TR>
                <TR>
		            <TD class=lightbluetable align=right>
                        <span class="span_role">質權</span>人代表人(英)：
		            </TD>
		            <TD class=sfont9 colspan="3">
                        <INPUT TYPE=text id=tfr1_ap_erep_## name=tfr1_ap_erep_## SIZE=80 MAXLENGTH=80 alt='『代表人名稱(英)』' onblur='fDataLen(this)'>
		            </TD>
	            </TR>
                <TR>
		            <TD class=lightbluetable align=right>
                        <span class="span_role">質權</span>人地址(中)：
		            </TD>
		            <TD class=sfont9 colspan="3">
		                <INPUT TYPE=text id=tfr1_ap_zip_## name=tfr1_ap_zip_## SIZE=8 MAXLENGTH=8 >
		                <INPUT TYPE=text id=tfr1_ap_addr1_## name=tfr1_ap_addr1_## SIZE=30 MAXLENGTH=60 alt='『地址(中)』' onblur='fDataLen(this)'>
		                <INPUT TYPE=text id=tfr1_ap_addr2_## name=tfr1_ap_addr2_## SIZE=30 MAXLENGTH=60 alt='『地址(中)』' onblur='fDataLen(this)'>
		            </TD>
	            </TR>
                <TR>
		            <TD class=lightbluetable align=right>
                        <span class="span_role">質權</span>人地址(英)：
		            </TD>
		            <TD class=sfont9 colspan="3">
		                <INPUT TYPE=text id=tfr1_ap_eaddr1_## name=tfr1_ap_eaddr1_## SIZE=60 MAXLENGTH=60 alt='『地址(英)』' onblur='fDataLen(this)'><br>
		                <INPUT TYPE=text id=tfr1_ap_eaddr2_## name=tfr1_ap_eaddr2_## SIZE=60 MAXLENGTH=60 alt='『地址(英)』' onblur='fDataLen(this)'><br>
		                <INPUT TYPE=text id=tfr1_ap_eaddr3_## name=tfr1_ap_eaddr3_## SIZE=60 MAXLENGTH=60 alt='『地址(英)』' onblur='fDataLen(this)'><br>
		                <INPUT TYPE=text id=tfr1_ap_eaddr4_## name=tfr1_ap_eaddr4_## SIZE=60 MAXLENGTH=60 alt='『地址(英)』' onblur='fDataLen(this)'>
		                <INPUT TYPE=hidden id=tfr1_apatt_tel0_##>
		                <INPUT TYPE=hidden id=tfr1_apatt_tel_##>
		                <INPUT TYPE=hidden id=tfr1_apatt_tel1_##>
		                <INPUT TYPE=hidden id=tfr1_apatt_zip_##>
		                <INPUT TYPE=hidden id=tfr1_apatt_fax_##>
		                <INPUT TYPE=hidden id=tfr1_apatt_addr1_##>
		                <INPUT TYPE=hidden id=tfr1_apatt_addr2_##>
		            </TD>
	            </TR>
            </script>
		    </table>
		</td>
	</tr>
	<tr style="display:none">
		<td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:pointer;COLOR:BLUE" ONCLICK="PMARK(b1Remark1)">
            <strong>陸、<u>另案一併設定質權之防護商標註冊號數</u></strong>
		</td>
	</tr>
	<tr style="display:none">
		<td class=whitetablebg colspan=8 width=100><TEXTAREA rows=1 cols=60 id=tfg1_tran_remark1 name=tfg1_tran_remark1></TEXTAREA></TD>
	</tr>
	<tr style="display:none">
		<td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:pointer;COLOR:BLUE" ONCLICK="PMARK(b1Remark2)">
            <strong>柒、<u>未一併設定質權之防護商標註冊號數(無防護商標者免填)</u></strong>
		</td>
	</tr>
	<tr style="display:none">
		<td class=whitetablebg colspan=8 width=100><TEXTAREA rows=1 cols=60 id=tfg1_tran_remark2 name=tfg1_tran_remark2></TEXTAREA></TD>
	</tr>
	<tr style="display:none">
		<td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:pointer;COLOR:BLUE" ONCLICK="PMARK(b1Term1)">
            <strong>捌、<u>設定質權期間</u></strong>
		</td>
	</tr>
	<tr style="display:none">
		<td class=lightbluetable align=right>設定期間：</td>
		<td class=whitetablebg colspan=7>自<input type=text id=tfg1_term1 name=tfg1_term1 size=10 class="dateField">(年/月/日)
      	                                至<input type=text id=tfg1_term2 name=tfg1_term2 size=10 class="dateField">(年/月/日)
		</td>
	</tr>

	<tr class='sfont9'>
		<td colspan=8>
		    <!--FP1的交辦內容及附件畫面-->
		    <TABLE id=tabrem1 border=0 class="bluetable" cellspacing=1 cellpadding=2 width="100%">
		    <tr>
			    <td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:pointer;COLOR:BLUE" ONCLICK="PMARK(b1Money)"><strong>柒、<u>設定質權之擔保債權額</u></strong></td>
		    </tr>
		    <tr>
		      <td class=lightbluetable align=right><input type="checkbox" name="debit_money"></td>
		      <td class=whitetablebg colspan=7><INPUT type="text" id=tfg1_debit_money name=tfg1_debit_money size=12 maxlength=12 style="text-align:right">元整</td>
		    </tr>
		    <tr>
		      <td class=lightbluetable align=right><input type="checkbox" name="O_item34"></td>
		      <td class=whitetablebg colspan=7><INPUT type="text" id=O_item3 name=O_item3 size=3 maxlength=3>件，總計<input type="text" id=O_item4 name=O_item4 style="text-align:right">元整</td>
		    </tr>
		    <tr>
			    <td class="lightbluetable" colspan="8" valign="top" id=tg_attech STYLE="cursor:pointer;COLOR:BLUE" ONCLICK="PMARK(zAttech)"><strong><u>附件：</u></strong></td>
		    </tr>
		    <tr class="br_attchstrFP1">
			    <td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttz1_Z2" NAME="ttz1_Z2" value="Z2" onclick="br_form.AttachStr('.br_attchstrFP1','ttz1_',reg.tfzd_remark1)"></td>
			    <td class="whitetablebg" colspan="7">委任書(<input TYPE="checkbox" id="ttz1_Z2C" NAME="ttz1_Z2C" value="Z2C" onclick="br_form.AttachStr('.br_attchstrFP1','ttz1_',reg.tfzd_remark1)">附中文譯本)。</td>
		    </tr>
		    <tr class="br_attchstrFP1">
			    <td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttz1_Z1" NAME="ttz1_Z1" value="Z1" onclick="br_form.AttachStr('.br_attchstrFP1','ttz1_',reg.tfzd_remark1)"></td>
			    <td class="whitetablebg" colspan="7">設定質權契約書或其他證明文件(<input type="checkbox" id="ttz1_Z1C" name="ttz1_Z1C" value="Z1C" onclick="br_form.AttachStr('.br_attchstrFP1','ttz1_',reg.tfzd_remark1)">附中文譯本)。</td>
		    </tr>
		    <tr class="br_attchstrFP1" style="display:none">
			    <td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttz1_Z3" NAME="ttz1_Z3" value="Z3" onclick="br_form.AttachStr('.br_attchstrFP1','ttz1_',reg.tfzd_remark1)"></td>
			    <td class="whitetablebg" colspan="7">關係人之代理人委任書(<input TYPE="checkbox" id="ttz1_Z3C" NAME="ttz1_Z3C" value="Z3C" onclick="br_form.AttachStr('.br_attchstrFP1','ttz1_',reg.tfzd_remark1)">附中譯本)。</td>
		    </tr>
		    <tr class="br_attchstrFP1">
			    <td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttz1_Z9" NAME="ttz1_Z9" value="Z9" onclick="br_form.AttachStr('.br_attchstrFP1','ttz1_',reg.tfzd_remark1)"></td>
			    <td class="whitetablebg" colspan="7">其他。<input TYPE="text" id="ttz1_Z9t" NAME="ttz1_Z9t" SIZE="50" onchange="br_form.AttachStr('.br_attchstrFP1','ttz1_',reg.tfzd_remark1)">
			    </td>
		    </tr>
		    <tr style="display:none">
		      <td class=lightbluetable  ROWSPAN=2 ><strong>附註一：</strong></td>
			    <td class=whitetablebg colspan=7>本件商標(標章)於<INPUT type=text id=O_item1 name=O_item1 size=10 class="dateField">(年/月/日)</td>
		    </tr>
		    <tr style="display:none">		  
			    <td class=whitetablebg colspan=7>另案辦理<INPUT type="radio" id=O_item2FT1 name=O_item2 value="FT1">移轉案
													     <INPUT type="radio" id=O_item2FL1 name=O_item2 value="FL1">授權案
													     <INPUT type="radio" id=O_item2FL2 name=O_item2 value="FL2">再授權案
													     <INPUT type="radio" id=O_item2FI1 name=O_item2 value="FI1">補證案
													     <INPUT type="radio" id=O_item2FC1 name=O_item2 value="FC1">變更案
													     <INPUT type="radio" id=O_item2FR1 name=O_item2 value="FR1">延展案</TD>
		    </tr>
		    </table>
		    <!--FP2的交辦內容及附件畫面-->
		    <TABLE id=tabrem2 border=0 class="bluetable" cellspacing=1 cellpadding=2 width="100%">
		    <tr>
			    <td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:pointer;COLOR:BLUE" ONCLICK="PMARK(h1Term1)"><strong>柒、<u>質權消滅日期</u></strong></td>
		    </tr>
		    <tr>
		      <td class=lightbluetable align=right></td>
		      <td class=whitetablebg colspan=7>自<input type=text id=tfg2_term1 name=tfg2_term1 size=10 class="dateField">(年/月/日)起質權消滅</td>
		    </tr>
		    <tr>
			    <td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:pointer;COLOR:BLUE" ONCLICK="PMARK(zAttech)"><strong><u>附件：</u></strong></td>
		    </tr>
		    <tr class="br_attchstrFP2">
			    <td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttz2_Z2" NAME="ttz2_Z2" value="Z2" onclick="br_form.AttachStr('.br_attchstrFP2','ttz2_',reg.tfzd_remark1)"></td>
			    <td class="whitetablebg" colspan="7">委任書(<input type="checkbox" id="ttz2_Z2C" name="ttz2_Z2C" value="Z2C" onclick="br_form.AttachStr('.br_attchstrFP2', 'ttz2_', reg.tfzd_remark1)">附中文譯本)。</td>
		    </tr>
		    <tr class="br_attchstrFP2">
			    <td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttz2_Z1" NAME="ttz2_Z1" value="Z1" onclick="br_form.AttachStr('.br_attchstrFP2', 'ttz2_', reg.tfzd_remark1)"></td>
			    <td class="whitetablebg" colspan="7">同意塗銷質權契約書或其他證明文件(<input type="checkbox" id="ttz2_Z1C" name="ttz2_Z1C" value="Z1C" onclick="br_form.AttachStr('.br_attchstrFP2', 'ttz2_', reg.tfzd_remark1)">附中文譯本)。</td>
		    </tr>
		    <tr class="br_attchstrFP2">
			    <td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttz2_Z9" NAME="ttz2_Z9" value="Z9" onclick="br_form.AttachStr('.br_attchstrFP2', 'ttz2_', reg.tfzd_remark1)"></td>
			    <td class="whitetablebg" colspan="7">其他。<input TYPE="text" id="ttz2_Z9t" NAME="ttz2_Z9t" SIZE="50" onchange="br_form.AttachStr('.br_attchstrFP2','ttz2_',reg.tfzd_remark1)"></td>
		    </tr>
		    </table>
		</td>
	</tr>
</TABLE>
</div>
<INPUT TYPE=hidden id=tfr1_mod_field NAME=tfr1_mod_field value="mod_ap">
<INPUT TYPE=hidden id=tfg1_seq NAME=tfg1_seq>
<INPUT TYPE=hidden id=tfg1_seq1 NAME=tfg1_seq1>
<INPUT TYPE=hidden id=tfg2_seq NAME=tfg2_seq>
<INPUT TYPE=hidden id=tfg2_seq1 NAME=tfg2_seq1>


<script language="javascript" type="text/javascript">
    //代理人連動
    $("#tfg1_agt_no1").change(function () {
        $("#tfg2_agt_no1").val($(this).val());
    });

    //申請人種類
    br_form.apcust_role=function(role){
        if( role=="A"){
            $("#role1").html("伍、<u>質權人</u>");
            $("#FT_AP_Add_button").val("增加一筆質權人");
            $("#FT_AP_Del_button").val("減少一筆質權人");
            $(".span_role").html("質權");
            $(".role9").attr("title","輸入編號並點選確定，即顯示質權人資料；若無資料，請直接輸入質權人資料。");
            $(".btn_role10").attr("title","輸入編號並點選確定，即顯示質權人資料；若無資料，請直接輸入質權人資料。");
            $(".td_role11").attr("title","輸入編號並點選確定，即顯示質權人資料；若無資料，請直接輸入質權人資料。");
            $("input[id^='tfr1_ap_cname1_'],input[id^='tfr1_ap_cname2_']").attr("alt","『質權人名稱(中)』");
            $("input[id^='butQ_']").attr("title","輸入關鍵字並點選質權人查詢，即顯示質權人資料清單。").val("質權人查詢");
        }else if(role=="B"){
            $("#role1").html("參、<u>商標權人</u>");
            $("#FT_AP_Add_button").val("增加一筆商標權人");
            $("#FT_AP_Del_button").val("減少一筆商標權人");
            $(".span_role").html("商標權");
            $(".role9").attr("title","輸入編號並點選確定，即顯示商標權人資料；若無資料，請直接輸入商標權人資料。");
            $(".btn_role10").attr("title","輸入編號並點選確定，即顯示商標權人資料；若無資料，請直接輸入商標權人資料。");
            $(".td_role11").attr("title","輸入關鍵字並點選商標權人查詢，即顯示商標權人資料清單。");
            $("input[id^='tfr1_ap_cname1_'],input[id^='tfr1_ap_cname2_']").attr("alt","『商標權人名稱(中)』");
            $("input[id^='butQ_']").attr("title","輸入關鍵字並點選商標權人查詢，即顯示商標權人資料清單。").val("商標權人查詢");
        }
    }

    //增加一筆關係人
    $("#FT_AP_Add_button").click(function () {
        var nRow = CInt($("#FT_apnum").val()) + 1;
        //複製樣板
        var copyStr = $("#br_role_template").text()||"";
        copyStr = copyStr.replace(/##/g, nRow);

        $("#FT_tabap>tbody").append("<tr id='tr_role_" + nRow + "' class='sfont9'><td><table border='0' class='bluetable' cellspacing='1' cellpadding='2' width='100%'>" + copyStr + "</table></td></tr>");
        $("#tr_role_" + nRow + " .Lock").lock();
        $("#FT_apnum").val(nRow);

        //申請人角色顯示授權人或被授權人
        $("input[name='tfzd_mark']:checked").triggerHandler("click");
    });

    //減少一筆關係人
    $("#FT_AP_Del_button").click(function () { 
        var nRow = CInt($("#FT_apnum").val());
        $('#tr_role_'+nRow).remove();
        $("#FT_apnum").val(Math.max(0, nRow - 1));
    });

    //***關係人重抓
    br_form.getapp1_ft = function (nRow) {
        $.ajax({
            type: "get",
            url: getRootPath() + "/ajax/_apcust.aspx?apcust_no=" + $("#tfr1_apcust_no_" + nRow).val(),
            async: false,
            cache: false,
            success: function (json) {
                if ($("#chkTest").length > 0) toastr.info("<a href='" + this.url + "' target='_new'>Debug(br_form.getapp1_ft關係人重抓)！<BR><b><u>(點此顯示詳細訊息)</u></b></a>");
                var apcust_list = $.parseJSON(json);
                if (apcust_list.length == 0) {
                    alert("無該關係人編號!!!");
                    return false;
                }

                $.each(apcust_list, function (i, item) {
                    $("#tfr1_apclass_" + nRow).val(item.apclass);
                    $("#tfr1_ap_country_" + nRow).val(item.ap_country);
                    $("#tfr1_ap_cname1_" + nRow).val(item.ap_cname1);
                    $("#tfr1_ap_cname2_" + nRow).val(item.ap_cname2);
                    $("#tfr1_ap_ename1_" + nRow).val(item.ap_ename1);
                    $("#tfr1_ap_ename2_" + nRow).val(item.ap_ename2);
                    $("#tfr1_ap_crep_" + nRow).val(item.ap_crep);
                    $("#tfr1_ap_erep_" + nRow).val(item.ap_erep);
                    $("#tfr1_ap_addr1_" + nRow).val(item.ap_addr1);
                    $("#tfr1_ap_addr2_" + nRow).val(item.ap_addr2);
                    $("#tfr1_ap_eaddr1_" + nRow).val(item.ap_eaddr1);
                    $("#tfr1_ap_eaddr2_" + nRow).val(item.ap_eaddr2);
                    $("#tfr1_ap_eaddr3_" + nRow).val(item.ap_eaddr3);
                    $("#tfr1_ap_eaddr4_" + nRow).val(item.ap_eaddr4);
                    $("#tfr1_apatt_zip_" + nRow).val(item.apatt_zip);
                    $("#tfr1_apatt_addr1_" + nRow).val(item.apatt_addr1);
                    $("#tfr1_apatt_addr2_" + nRow).val(item.apatt_addr2);
                    $("#tfr1_apatt_tel0_" + nRow).val(item.apatt_tel0);
                    $("#tfr1_apatt_tel_" + nRow).val(item.apatt_tel);
                    $("#tfr1_apatt_tel1_" + nRow).val(item.apatt_tel1);
                    $("#tfr1_apatt_fax_" + nRow).val(item.apatt_fax);
                    $("#tfr1_apsqlno_" + nRow).val(item.apsqlno);
                    $("#tfr1_ap_zip_" + nRow).val(item.ap_zip);
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

    //交辦內容綁定
    br_form.bindFP1 = function () {
        console.log("fp1.br_form.bind");
        if (jMain.case_main.length == 0) {
            $("#FT_AP_Add_button").click();//關係人預設顯示第1筆
            $("#tfg2_agt_no1").val($("#tfg1_agt_no1").val());//代理人連動
        } else {
            //代理人
            $("#tfg1_agt_no1,#tfg2_agt_no1").val(jMain.case_main[0].agt_no);
            $("#tfzd_agt_no").val(jMain.case_main[0].agt_no);
            $("#fr1_issue_no").val(jMain.case_main[0].issue_no);//註冊號
            $("#fr1_appl_name").val(jMain.case_main[0].appl_name);//商標名稱
            //商標種類
            $("input[name=fr1_S_Mark][value='" + jMain.case_main[0].s_mark + "']").prop("checked", true);
            //申請人種類
            $("input[name=tfzd_Mark][value='" + jMain.case_main[0].temp_mark + "']").prop("checked", true).triggerHandler("click");
            if (jMain.case_main[0].temp_mark == "A") {
                $("#no").val(jMain.case_main[0].apply_no);
            } else if (jMain.case_main[0].temp_mark == "I") {
                $("#no").val(jMain.case_main[0].issue_no);
            }
            //質權人
            $.each(jMain.case_tranlist, function (i, item) {
                if (item.mod_field == "mod_ap") {
                    //增加一筆
                    $("#FT_AP_Add_button").click();
                    //填資料
                    var nRow = $("#FT_apnum").val();
                    $("#tfr1_apcust_no_" + nRow).val(item.old_no);
                    $("#tfr1_apclass_" + nRow).val(item.oapclass);
                    $("#tfr1_ap_country_" + nRow).val(item.oap_country);
                    //$("#tfr1_ap_cname_" + nRow).val(item.naddr1);
                    //$("#tfr1_apsqlno_" + nRow).val(item.naddr1);
                    $("#tfr1_ap_cname1_" + nRow).val(item.ocname1);
                    $("#tfr1_ap_cname2_" + nRow).val(item.ocname2);
                    $("#tfr1_ap_ename1_" + nRow).val(item.oename1);
                    $("#tfr1_ap_ename2_" + nRow).val(item.oename2);
                    $("#tfr1_ap_crep_" + nRow).val(item.ocrep);
                    $("#tfr1_ap_erep_" + nRow).val(item.oerep);
                    $("#tfr1_ap_zip_" + nRow).val(item.ozip);
                    $("#tfr1_ap_addr1_" + nRow).val(item.oaddr1);
                    $("#tfr1_ap_addr2_" + nRow).val(item.oaddr2);
                    $("#tfr1_ap_eaddr1_" + nRow).val(item.oeaddr1);
                    $("#tfr1_ap_eaddr2_" + nRow).val(item.oeaddr2);
                    $("#tfr1_ap_eaddr3_" + nRow).val(item.oeaddr3);
                    $("#tfr1_ap_eaddr4_" + nRow).val(item.oeaddr4);
                    $("#tfr1_apatt_tel0_" + nRow).val(item.otel0);
                    $("#tfr1_apatt_tel_" + nRow).val(item.otel);
                    $("#tfr1_apatt_tel1_" + nRow).val(item.otel1);
                    $("#tfr1_apatt_fax_" + nRow).val(item.ofax);
                }
            });
            if (CInt($("#FT_apnum").val()) == 0) {
                alert("查無此交辦案件之關係人資料!!");
            }
            $("#tfg1_tran_remark1").val(jMain.case_main[0].tran_remark1);//一併設定號數
            $("#tfg1_tran_remark2").val(jMain.case_main[0].tran_remark2);//未一併設定號數
            //質權期間
            $("#tfg1_term1").val(dateReviver(jMain.case_main[0].term1, "yyyy/M/d"));
            $("#tfg1_term2").val(dateReviver(jMain.case_main[0].term2, "yyyy/M/d"));
            $("#tfg1_debit_money").val(jMain.case_main[0].debit_money);//債權額度
            if (jMain.case_main[0].debit_money != "") {
                $("input[name=debit_money]").prop("checked", true);
            }
            //件數.金額
            if (jMain.case_tran[0].other_item1.indexOf(";") > -1) {
                var oitem = jMain.case_tran[0].other_item1.split(";");
                $("input[name=O_item34]").prop("checked", true);
                $("#O_item3").val(oitem[0]);
                $("#O_item4").val(oitem[1]);
            }
            //**附件
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
            //FP2交辦內容
            $("#tfg2_term1").val(dateReviver(jMain.case_main[0].term1, "yyyy/M/d"));//質權消滅日期
            //附件
            if (jMain.case_main[0].remark1 != "") {
                var arr_remark1 = jMain.case_main[0].remark1.split("|");
                for (var i = 0; i < arr_remark1.length; i++) {
                    //var str="Z3|Z9|Z9-具結書正本、讓與人之負責人身份證影本-Z9|";
                    //var str = "Z9-具結書正本、讓與人之負責人身份證影本-Z9";
                    //var substr = arr_remark1[i].match(/Z9-(\S+)-Z9/);
                    var substr = arr_remark1[i].match(/Z9-([\s\S]+)-Z9/);
                    if (substr != null) {
                        $("#ttz2_Z9t").val(substr[1]);
                    } else {
                        $("#ttz2_" + arr_remark1[i]).prop("checked", true);
                    }
                }
            }
        }
    }
</script>
