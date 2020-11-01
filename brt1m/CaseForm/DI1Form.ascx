<%@ Control Language="C#" ClassName="DI1Form" %>
<%@ Import Namespace = "System.Collections.Generic"%>

<script runat="server">
    //B爭議案交辦內容
    //父控制項傳入的參數
    public Dictionary<string, string> Lock = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    
    protected string prgid = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string SQL = "";

    protected string tfp3_agt_no = "";
    
    private void Page_Load(System.Object sender, System.EventArgs e) {
        PageLayout();   
        this.DataBind();
    }
    
    private void PageLayout() {
        //代理人
        tfp3_agt_no = Sys.getAgent().Option("{agt_no}", "{agt_no}_{agt_namefull}", " v1='{agt_name1}' {selected}", true);
    }
</script>

<div id="div_Form_DI1">
<%=Sys.GetAscxPath(this)%>
<TABLE border=0 class=bluetable cellspacing=1 cellpadding=2 width="100%">
	<tr>			
		<td class=lightbluetable align=right><strong>案件種類：</strong></td>
		<td class=whitetablebg colspan=7>
            <Select name="tfp3_case_stat" id="tfp3_case_stat" onchange="br_form.new_oldcaseB('tfp3')">
			<option value="NN">新案</option>
			<option value="SN">新案(指定編號)</option>
            </Select>
		</TD>
	</tr>
	<tr >
		<td class="lightbluetable" align=right><strong>本所編號：</strong></td>
		<td class="whitetablebg" colspan="7" id="showseq_tfp3" style="display:none">
			<input type="text" size="5" name="tfp3_seq" id="tfp3_seq" readonly class="SEdit">-
			<select name=tfp3_seq1 id=tfp3_seq1 onchange="br_form.seq1_conctrl()">
				<option value="_">一般</option>
				<option value="M">M_大陸案</option>
			</select>
		</td>
		<td class=whitetablebg colspan=7 style="display:none" id="ShowNewAssign_tfp3">
			<INPUT TYPE=text NAME=tfp3_New_Ass_seq id=tfp3_New_Ass_seq SIZE=5 MAXLENGTH=5 onblur="dmt_form.New_ass_seqB_blur('tfp3')">-<INPUT TYPE=text NAME=tfp3_New_Ass_seq1 id=tfp3_New_Ass_seq1 SIZE=1 MAXLENGTH=1 value="" onblur="dmt_form.New_ass_seqB_blur('tfp3')">	
		</td>
	</tr>
	<tr>
		<td class="lightbluetable" valign="top" ><strong>※、代理人(代碼)</strong></td>
		<td class="whitetablebg" colspan="7" >
		    <select id="tfp3_agt_no" NAME="tfp3_agt_no" onchange="br_form.copycaseZZ('tfp3_agt_no')"><%#tfp3_agt_no%></select>
		</td>
	</tr>
	<tr>
		<td class="lightbluetable" colspan="8" valign="top" width="20%" STYLE="cursor:pointer;COLOR:BLUE" onclick="PMARK(O1Appl_name)">
            <strong>壹、<u>評定標的（你要評定的標章）</u></strong>
		</td>
	</tr>
	<tr>
		<td class=lightbluetable align=right >商標種類：</td>
		<td class=whitetablebg colspan="7">
			<input type=radio name=fr3_S_Mark class="onoff" value="" onclick="dmt_form.change_mark(1, this)">商標
			<input type=radio name=fr3_S_Mark class="onoff" value="S" onclick="dmt_form.change_mark(1, this)">92年修正前服務標章
			<input type=radio name=fr3_S_Mark class="onoff" value="N" onclick="dmt_form.change_mark(1, this)">團體商標
			<input type=radio name=fr3_S_Mark class="onoff" value="M" onclick="dmt_form.change_mark(1, this)">團體標章
			<input type=radio name=fr3_S_Mark class="onoff" value="L" onclick="dmt_form.change_mark(1, this)">證明標章
		</TD>
	</tr>
	<tr>
		<td class=lightbluetable align=right >註冊號數：</td>
		<td class=whitetablebg colspan="3">
			<input type="text" id="fr3_issue_no" name="fr3_issue_no" class="onoff" value="" size="20" maxlength="20" >
		</TD>
		<td class=lightbluetable align=right width="18%">商標/標章名稱：</td>
		<td class=whitetablebg colspan="3">
			<input type="text" id="fr3_appl_name" name="fr3_appl_name" class="onoff" value="" size="30" maxlength="100" onchange="reg.tfzd_appl_name.value=this.value">
		</TD>
	</tr>
	<tr>
		<td class=lightbluetable align=right >擬評定之類別種類：</td>
		<td class=whitetablebg colspan="3">
			<input type="radio" id=fr3_class_typeI name=fr3_class_type class="onoff" value="int" onclick="reg.tfzr_class_type(0).checked = reg.fr3_class_type(0).checked">國際分類
			<input type="radio" id=fr3_class_typeO name=fr3_class_type class="onoff" value="old" onclick="reg.tfzr_class_type(1).checked = reg.fr3_class_type(1).checked">舊類
		</TD>
		<td class=lightbluetable align=right width="18%" STYLE="cursor:pointer;COLOR:BLUE" title="請輸入類別，並以逗號分開(例如：001,005,032)。">擬評定之類別：</td>
		<td class=whitetablebg colspan="3">
			<input type="text" id="fr3_class" name="fr3_class" value="" size="30" maxlength="100" onchange="br_form.count_kind_DI1()">，
			共<input type="text" id="fr3_class_count" name="fr3_class_count" value="" size=3 readonly class="SEdit" >類(評定案依類別計算，請填具正確類別)
		</TD>
	</tr>
	<tr>
		<td class="lightbluetable" colspan="8" valign="top" width="20%">
            <strong>你認為商標/標章圖樣那一部份違法請打勾並填寫：</strong>
		</td>
	</tr>
	<tr>
		<td class=lightbluetable align=right width="20%"></td>
		<td class=whitetablebg colspan=7>
            <input type="checkbox" name=I_cappl_name value="C">中文
            <input type="checkbox" name=I_eappl_name value="E">英文
            <input type="checkbox" name=I_jappl_name value="J">日文
            <input type="checkbox" name=I_draw value="D">圖形
            <input type="checkbox" name=I_zappl_name1 value="Z">其他（非英文或日文之外國文字、顏色、聲音、立體形狀等）
		</td>
	</tr>
	<tr>
		<td class=lightbluetable align=right></td>
		<td class=whitetablebg colspan=7>
            <INPUT TYPE=text NAME=I_remark3 id=I_remark3 SIZE=30 MAXLENGTH=50>
		</td>
	</tr>
	<tr>
		<td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:pointer;COLOR:BLUE" onclick="PMARK(O1Rapcust)">
            <strong>肆、<u>註冊人</u></strong>
		</td>
	</tr>
	<tr >
		<td colspan="8" class='sfont9'>
		<input type=hidden id=DI1_apnum name=DI1_apnum value=0><!--進度筆數-->
		<table border="0" id=DI1_tabap class="bluetable" cellspacing="1" cellpadding="1" width="100%">
        <thead>
		    <TR>
			    <TD  class=whitetablebg colspan=2 align=right>
				    <input type=button value ="增加一筆註冊人" class="cbutton" id=DI1_AP_Add_button name=DI1_AP_Add_button>
				    <input type=button value ="減少一筆註冊人" class="cbutton" id=DI1_AP_Del_button name=DI1_AP_Del_button>
			    </TD>
		    </TR>
        </thead>
        <tbody></tbody>
        <script type="text/html" id="di1_ap_template">
	        <TR>
		        <TD class=lightbluetable align=right>
			        <input type=text id='DI1_apnum_##' name='DI1_apnum_##' class=SEdit readonly style='color:black;' size=2 value='##.'>名稱或姓名：
		        </TD>
		        <TD class=whitetablebg>
		            <input TYPE=text NAME=ttg3_mod_ap_ncname1_## id=ttg3_mod_ap_ncname1_## SIZE=60 MAXLENGTH=100 alt='『註冊人名稱』' onblur='fDataLen(this)'><br>
		            <input TYPE=text NAME=ttg3_mod_ap_ncname2_## id=ttg3_mod_ap_ncname2_## SIZE=60 MAXLENGTH=100 alt='『註冊人名稱』' onblur='fDataLen(this)'>
		        </TD>
	        </TR>
	        <TR>
		        <TD class=lightbluetable align=right>
			        地　　　址：
		        </TD>
		        <TD class=whitetablebg>
		            <input TYPE=text NAME=ttg3_mod_ap_nzip_## id=ttg3_mod_ap_nzip_## SIZE=8 MAXLENGTH=8 alt='『註冊人郵遞區號』' onblur='fDataLen(this)'>
		            <input TYPE=text NAME=ttg3_mod_ap_naddr1_## id=ttg3_mod_ap_naddr1_## SIZE=30 MAXLENGTH=60 alt='『註冊人地址』' onblur='fDataLen(this)'>
		            <input TYPE=text NAME=ttg3_mod_ap_naddr2_## id=ttg3_mod_ap_naddr2_## SIZE=30 MAXLENGTH=60 alt='『註冊人地址』' onblur='fDataLen(this)'>
		        </TD>
	        </TR>
	        <TR>
		        <TD class=lightbluetable align=right>
			        代理人姓名：
		        </TD>
		        <TD class=whitetablebg>
		            <input TYPE=text NAME=ttg3_mod_ap_ncrep_## id=ttg3_mod_ap_ncrep_## SIZE=20 MAXLENGTH=20 alt='『註冊人代理人』' onblur='fDataLen(this)'>
		        </TD>
	        </TR>
        </script>
		</table>
		</td>
	</tr>
	<tr>
		<td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:pointer;COLOR:BLUE" onclick="PMARK(I1New_no)">
            <strong>伍、<u>評定聲明：</u></strong>
		</td>
	</tr>
	<tr>
		<td class=lightbluetable align=right valign=top></td>
		<td class=whitetablebg colspan=7>第<INPUT TYPE=text NAME=ttg31_mod_pul_new_no id=ttg31_mod_pul_new_no SIZE=10 MAXLENGTH=10>號「<INPUT TYPE=text NAME=ttg31_mod_pul_ncname1 id=ttg31_mod_pul_ncname1 SIZE=30 MAXLENGTH=50>」
            <input type="radio" name="ttg31_mod_pul_mod_type" value="Tmark">商標
            <input type="radio" name="ttg31_mod_pul_mod_type" value="Lmark">標章
		</td>
	</tr>
    <tr>
		<td class=lightbluetable align=right valign=top><input type="checkbox" name=ttg32_mod_pul_mod_type value="I1"></td>
		<td class=whitetablebg colspan=7>註冊應予撤銷。</td>
	</tr>
	<tr>
		<td class=lightbluetable align=right valign=top><input type="checkbox" name=ttg33_mod_pul_mod_type value="I2"></td>
		<td class=whitetablebg colspan=7>指定使用於商標法施行細則第<INPUT TYPE=text NAME=ttg33_mod_pul_new_no id=ttg33_mod_pul_new_no SIZE=3 MAXLENGTH=10>條第<INPUT TYPE=text NAME=ttg33_mod_pul_mod_dclass id=ttg33_mod_pul_mod_dclass SIZE=20 MAXLENGTH=20>類商品／服務之註冊應予撤銷。</td>
	</tr>
	<tr>
		<td class=lightbluetable align=right valign=top><input type="checkbox" name=ttg34_mod_pul_mod_type value="I3"></td>
		<td class=whitetablebg colspan=7>指定使用於商標法施行細則第<INPUT TYPE=text NAME=ttg34_mod_pul_new_no id=ttg34_mod_pul_new_no SIZE=3 MAXLENGTH=10>條第<INPUT TYPE=text NAME=ttg34_mod_pul_mod_dclass id=ttg34_mod_pul_mod_dclass SIZE=3 MAXLENGTH=3>類<INPUT TYPE=text NAME=ttg34_mod_pul_ncname1 id=ttg34_mod_pul_ncname1 SIZE=30 MAXLENGTH=50>商品／服務之註冊應予撤銷。</td>
	</tr>
	<tr>
		<td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:pointer;COLOR:BLUE" onclick="PMARK(I1Other_item1)"><strong>陸、<u>主張法條及據以評定商標/標章：</u></strong></td>
	</tr>
	<tr>
		<td class="lightbluetable" valign="top" rowspan=2>一、主張條款：</td>
		<td class=whitetablebg colspan="7" valign="top"><input type="checkbox" name="I_item1" value="I">註冊<input type="checkbox" name="I_item1" value="R">延展註冊時 商標法<input TYPE=text NAME=I_item2 id=I_item2 SIZE=30 MAXLENGTH=50 value="第  條第  項第  款">
		<input type="hidden" id="tfz3_other_item1" Name="tfz3_other_item1">
		</td>
	</tr>
	<tr>
		<td class=whitetablebg colspan="7" valign="top"><input type="checkbox" name="I_item1" value="O">商標法<input TYPE=text NAME=I_item2t id=I_item2t SIZE=30 MAXLENGTH=50 value="第  條第  項第  款">
		</td>
	</tr>
	<tr>
		<td class="lightbluetable" valign="top" colspan="8" ><strong>二、據以評定商標/標章：</strong>（你認為被評定商標/標章和那些商標/標章相衝突，請按照主張條款分別詳細列出，有號數者請務必依序填寫，以免延宕本案之審理）</td>
	</tr>
	<tr>
		<td colspan=8 class='sfont9'>
		    <TABLE id=tabbr31 style="display:" border=0 class="bluetable"  cellspacing=1 cellpadding=2 width="100%">
            <thead>
		    <tr>	
			    <td class="lightbluetable" align="right" width="18%">條款項目：</td>
			    <td class="whitetablebg" colspan="7" >共<input type="text" id=ttg3_mod_aprep_mod_count name=ttg3_mod_aprep_mod_count size=2 onchange=br_form.add_button_DI1(this.value)>項
				    <input type=hidden id=count31 name=count31 value="0">
				    <input type=hidden id=ctrlcnt31 name=ctrlcnt31 value="">
				    <input type=hidden id=cnt31 name=cnt31 value="0"><!--畫面上有幾筆-->
			    </td>
		    </tr>
            </thead>
            <tbody></tbody>
            <script type="text/html" id="di1_aprep_template">
		        <tr class="tr_di1_aprep_##">	
			        <td class="lightbluetable" align="right">主張條款##：</td>
			        <td class="whitetablebg" colspan="7" ><input type="text" id=ttg3_mod_aprep_ncname1_## name=ttg3_mod_aprep_ncname1_## size=20 maxlength=20></td>
		        </tr>
		        <tr class="tr_di1_aprep_##">	
			        <td class="lightbluetable" align="right">據以評定商標號數##：</td>
			        <td class="whitetablebg" colspan="7"><input type="text" id=ttg3_mod_aprep_new_no_## name=ttg3_mod_aprep_new_no_## size=60 maxlength=80></td>
		        </tr>
            </script>
		    </table>
		</td>
	</tr>
	<tr>
		<td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:pointer;COLOR:BLUE" onclick="PMARK(I1Tran_remark1)"><strong>柒、<u>事實及理由：</u></strong></td>
	</tr>
	<tr>
		<td class="lightbluetable" colspan="8" valign="top">一、申請評定人具利害關係人身分之事實及理由</td>
	</tr>
	<tr>
		<td class="lightbluetable" colspan="8" valign="top"><TEXTAREA rows=9 cols=90 id=tfz3_tran_remark3 name=tfz3_tran_remark3></TEXTAREA></td>
	</tr>
	<tr>
		<td class="lightbluetable" colspan="8" valign="top">二、本案事實及理由</td>
	</tr>
	<tr>
		<td class="lightbluetable" colspan="8" valign="top"><TEXTAREA rows=9 cols=90 id=tfz3_tran_remark1 name=tfz3_tran_remark1></TEXTAREA></td>
	</tr>
	<tr>
		<td class="lightbluetable" colspan="8" valign="top" >【主張法條為商標法第30條第1項第10款且據以評定商標註冊已滿3年者，<u>請具體說明據以評定商標使用情形</u>】</td>
	</tr>
	<tr>
		<td class="lightbluetable" colspan="8" valign="top"><TEXTAREA rows=9 cols=100 id=tfz3_tran_remark4 name=tfz3_tran_remark4 ></TEXTAREA></td>
	</tr>
	<tr>
		<td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:pointer;COLOR:BLUE" onclick="PMARK(ZAttechD)"><strong>捌、<u>證據(附件)內容：</u></strong></td>
	</tr>
	<tr>
		<td class="lightbluetable" colspan="8" valign="top"><TEXTAREA rows=9 cols=90 id=tfz3_tran_remark2 name=tfz3_tran_remark2></TEXTAREA></td>
	</tr>
	<tr>
		<td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:pointer;COLOR:BLUE" onclick="PMARK(I1Other_item)"><strong>玖、<u>相關聯案件：</u></strong></td>
	</tr>
	<TR>
		<TD class=lightbluetable align=right></TD>
		<TD class=whitetablebg colspan=7>
		本案與<input TYPE=text NAME=I_O_item1 id=I_O_item1 SIZE=10 MAXLENGTH=10 class="dateField">(年/月/日)註冊第<input type="text" name="I_O_item2" SIZE=10>號<input type="text" name="I_O_item3" SIZE=10>案有關
		<input type="hidden" name="tfz3_other_item" id="tfz3_other_item">
		</TD>
	</TR>
	<tr>
		<td class="lightbluetable" colspan="8" valign="top"><strong>※評定商標及據以評定商標圖樣：</strong></td>
	</tr>
	<TR>
		<TD class=lightbluetable align=right>一、評定標的圖樣：</TD>
		<TD class=whitetablebg colspan=7>
		<input TYPE=text NAME=tfp3_draw_file id=tfp3_draw_file SIZE=50 MAXLENGTH=50 readonly>
		<input TYPE=hidden NAME=tfp3_file id=tfp3_file >
		<input type="button" class="cbutton" id="butUploadtfp3" name="butUploadtfp3" value="商標圖檔上傳" onclick="dmt_form.UploadAttach_photo('tfp3')" >
		<input type="button" class="redbutton" name="btnDelAtt" value="商標圖檔刪除" onclick="dmt_form.DelAttach_photo('tfp3')" >
        <input type="button" class="cbutton" name="btnDisplay" value="商標圖檔檢視" onclick="dmt_form.PreviewAttach_photo('tfp3')" >
		</TD>
	</TR>
	<TR>
		<TD class=lightbluetable align=right>二、據以評定商標圖樣：</TD>
		<TD class=whitetablebg colspan=7>
            <input type="button" class="cbutton" id="butadd_draw" name="butadd_draw" value="增加一筆商標圖檔" onclick="br_form.drawadd('ttg3')">
            <input type="hidden" name="draw_num_ttg3" id="draw_num_ttg3" value=5><!--預設5，因畫面直接顯示5筆，若有6筆以上，edit再給值--><br>
		1.<input TYPE=text NAME=ttg3_mod_dmt_ncname1 id=ttg3_mod_dmt_ncname1 SIZE=50 MAXLENGTH=50 readonly>
			<input TYPE=hidden NAME=draw_attach_file_ttg3_1 id=draw_attach_file_ttg3_1 >
			<input TYPE=hidden NAME=old_file_ttg3_1 id=old_file_ttg3_1 >
			<input type="button" class="cbutton" id="butUploadttg3_1" name="butUploadttg3_1"  value="商標圖檔上傳" onclick="br_form.UploadAttach_photo_mod('ttg3_mod_dmt_ncname1','ttg3_1')" >
		    <input type="button" class="redbutton" name="btnDelAtt" value="商標圖檔刪除" onclick="br_form.DelAttach_photo_mod('ttg3_mod_dmt_ncname1','ttg3_1')" >
            <input type="button" class="cbutton" name="btnDisplay" value="商標圖檔檢視" onclick="br_form.PreviewAttach_photo_mod('ttg3_mod_dmt_ncname1','ttg3_1')" >
			<br>
		2.<input TYPE=text NAME=ttg3_mod_dmt_ncname2 id=ttg3_mod_dmt_ncname2 SIZE=50 MAXLENGTH=50 readonly>
			<input TYPE=hidden NAME=draw_attach_file_ttg3_2 id=draw_attach_file_ttg3_2 >
			<input TYPE=hidden NAME=old_file_ttg3_2 id=old_file_ttg3_2 >
			<input type="button" class="cbutton" id="butUploadttg3_2" name="butUploadttg3_2"  value="商標圖檔上傳" onclick="br_form.UploadAttach_photo_mod('ttg3_mod_dmt_ncname2','ttg3_2')" >
		    <input type="button" class="redbutton" name="btnDelAtt" value="商標圖檔刪除" onclick="br_form.DelAttach_photo_mod('ttg3_mod_dmt_ncname2','ttg3_2')" >
            <input type="button" class="cbutton" name="btnDisplay" value="商標圖檔檢視" onclick="br_form.PreviewAttach_photo_mod('ttg3_mod_dmt_ncname2','ttg3_2')" >
			<br>
		3.<input TYPE=text NAME=ttg3_mod_dmt_nename1 id=ttg3_mod_dmt_nename1 SIZE=50 MAXLENGTH=50 readonly>
			<input TYPE=hidden NAME=draw_attach_file_ttg3_3 id=draw_attach_file_ttg3_3 >
			<input TYPE=hidden NAME=old_file_ttg3_3 id=old_file_ttg3_3 >
			<input type="button" class="cbutton" id="butUploadttg3_3" name="butUploadttg3_3"  value="商標圖檔上傳" onclick="br_form.UploadAttach_photo_mod('ttg3_mod_dmt_nename1','ttg3_3')" >
		    <input type="button" class="redbutton" name="btnDelAtt" value="商標圖檔刪除" onclick="br_form.DelAttach_photo_mod('ttg3_mod_dmt_nename1','ttg3_3')" >
            <input type="button" class="cbutton" name="btnDisplay" value="商標圖檔檢視" onclick="br_form.PreviewAttach_photo_mod('ttg3_mod_dmt_nename1','ttg3_3')" >	
			<br>
		4.<input TYPE=text NAME=ttg3_mod_dmt_nename2 id=ttg3_mod_dmt_nename2 SIZE=50 MAXLENGTH=50 readonly>
			<input TYPE=hidden NAME=draw_attach_file_ttg3_4 id=draw_attach_file_ttg3_4 >
			<input TYPE=hidden NAME=old_file_ttg3_4 id=old_file_ttg3_4 >
			<input type="button" class="cbutton" id="butUploadttg3_4" name="butUploadttg3_4"  value="商標圖檔上傳" onclick="br_form.UploadAttach_photo_mod('ttg3_mod_dmt_nename2','ttg3_4')" >
		    <input type="button" class="redbutton" name="btnDelAtt" value="商標圖檔刪除" onclick="br_form.DelAttach_photo_mod('ttg3_mod_dmt_nename2','ttg3_4')" >
            <input type="button" class="cbutton" name="btnDisplay" value="商標圖檔檢視" onclick="br_form.PreviewAttach_photo_mod('ttg3_mod_dmt_nename2','ttg3_4')" >
			<br>
		5.<input TYPE=text NAME=ttg3_mod_dmt_ncrep id=ttg3_mod_dmt_ncrep SIZE=50 MAXLENGTH=50 readonly>
			<input TYPE=hidden NAME=draw_attach_file_ttg3_5 id=draw_attach_file_ttg3_5 >
			<input TYPE=hidden NAME=old_file_ttg3_5 id=old_file_ttg3_5 >
			<input type="button" class="cbutton" id="butUploadttg3_5" name="butUploadttg3_5"  value="商標圖檔上傳" onclick="br_form.UploadAttach_photo_mod('ttg3_mod_dmt_ncrep','ttg3_5')" >
		    <input type="button" class="redbutton" name="btnDelAtt" value="商標圖檔刪除" onclick="br_form.DelAttach_photo_mod('ttg3_mod_dmt_ncrep','ttg3_5')" >
            <input type="button" class="cbutton" name="btnDisplay" value="商標圖檔檢視" onclick="br_form.PreviewAttach_photo_mod('ttg3_mod_dmt_ncrep','ttg3_5')" >
			<br>			
		<span id="sp_ttg3_6" style="display:none">
		6.<input TYPE=text NAME=ttg3_mod_dmt_nerep id=ttg3_mod_dmt_nerep SIZE=50 MAXLENGTH=50 readonly>  
			<input TYPE=hidden NAME=draw_attach_file_ttg3_6 id=draw_attach_file_ttg3_6 >
			<input TYPE=hidden NAME=old_file_ttg3_6 id=old_file_ttg3_6 >
			<input type="button" class="cbutton" id="butUploadttg3_6" name="butUploadttg3_6"  value="商標圖檔上傳" onclick="br_form.UploadAttach_photo_mod('ttg3_mod_dmt_nerep','ttg3_6')" >
		    <input type="button" class="redbutton" name="btnDelAtt" value="商標圖檔刪除" onclick="br_form.DelAttach_photo_mod('ttg3_mod_dmt_nerep','ttg3_6')" >
            <input type="button" class="cbutton" name="btnDisplay" value="商標圖檔檢視" onclick="br_form.PreviewAttach_photo_mod('ttg3_mod_dmt_nerep','ttg3_6')" >	
		<br>
		</span>
		<span id="sp_ttg3_7" style="display:none">
		7.<input TYPE=text NAME=ttg3_mod_dmt_neaddr1 id=ttg3_mod_dmt_neaddr1 SIZE=50 MAXLENGTH=50 readonly>  
			<input TYPE=hidden NAME=draw_attach_file_ttg3_7 id=draw_attach_file_ttg3_7 >
			<input TYPE=hidden NAME=old_file_ttg3_7 id=old_file_ttg3_7 >
			<input type="button" class="cbutton" id="butUploadttg3_7" name="butUploadttg3_7"  value="商標圖檔上傳" onclick="br_form.UploadAttach_photo_mod('ttg3_mod_dmt_neaddr1','ttg3_7')" >
		    <input type="button" class="redbutton" name="btnDelAtt"  value="商標圖檔刪除" onclick="br_form.DelAttach_photo_mod('ttg3_mod_dmt_neaddr1','ttg3_7')" >
            <input type="button" class="cbutton" name="btnDisplay" value="商標圖檔檢視" onclick="br_form.PreviewAttach_photo_mod('ttg3_mod_dmt_neaddr1','ttg3_7')" >	
		<br>
		</span>
		<span id="sp_ttg3_8" style="display:none">
		8.<input TYPE=text NAME=ttg3_mod_dmt_neaddr2 id=ttg3_mod_dmt_neaddr2 SIZE=50 MAXLENGTH=50 readonly>  
			<input TYPE=hidden NAME=draw_attach_file_ttg3_8 id=draw_attach_file_ttg3_8 >
			<input TYPE=hidden NAME=old_file_ttg3_8 id=old_file_ttg3_8 >
			<input type="button" class="cbutton" id="butUploadttg3_8" name="butUploadttg3_8"  value="商標圖檔上傳" onclick="br_form.UploadAttach_photo_mod('ttg3_mod_dmt_neaddr2','ttg3_8')" >
		    <input type="button" class="redbutton" name="btnDelAtt" value="商標圖檔刪除" onclick="br_form.DelAttach_photo_mod('ttg3_mod_dmt_neaddr2','ttg3_8')" >
            <input type="button" class="cbutton" name="btnDisplay" value="商標圖檔檢視" onclick="br_form.PreviewAttach_photo_mod('ttg3_mod_dmt_neaddr2','ttg3_8')" >	
		<br>
		</span>
		<span id="sp_ttg3_9" style="display:none">
		9.<input TYPE=text NAME=ttg3_mod_dmt_neaddr3 id=ttg3_mod_dmt_neaddr3 SIZE=50 MAXLENGTH=50 readonly>  
			<input TYPE=hidden NAME=draw_attach_file_ttg3_9 id=draw_attach_file_ttg3_9 >
			<input TYPE=hidden NAME=old_file_ttg3_9 id=old_file_ttg3_9 >
			<input type="button" class="cbutton" id="butUploadttg3_9" name="butUploadttg3_9"  value="商標圖檔上傳" onclick="br_form.UploadAttach_photo_mod('ttg3_mod_dmt_neaddr3','ttg3_9')" >
		    <input type="button" class="redbutton" name="btnDelAtt"  value="商標圖檔刪除" onclick="br_form.DelAttach_photo_mod('ttg3_mod_dmt_neaddr3','ttg3_9')" >
            <input type="button" class="cbutton" name="btnDisplay" value="商標圖檔檢視" onclick="br_form.PreviewAttach_photo_mod('ttg3_mod_dmt_neaddr3','ttg3_9')" >	
		<br>
		</span>
		<span id="sp_ttg3_10" style="display:none">
		10.<input TYPE=text NAME=ttg3_mod_dmt_neaddr4 id=ttg3_mod_dmt_neaddr4 SIZE=50 MAXLENGTH=50 readonly>  
			<input TYPE=hidden NAME=draw_attach_file_ttg3_10 id=draw_attach_file_ttg3_10 >
			<input TYPE=hidden NAME=old_file_ttg3_10 id=old_file_ttg3_10 >
			<input type="button" class="cbutton" id="butUploadttg3_10" name="butUploadttg3_10"  value="商標圖檔上傳" onclick="br_form.UploadAttach_photo_mod('ttg3_mod_dmt_neaddr4','ttg3_10')" >
		    <input type="button" class="redbutton" name="btnDelAtt" value="商標圖檔刪除" onclick="br_form.DelAttach_photo_mod('ttg3_mod_dmt_neaddr4','ttg3_10')" >
            <input type="button" class="cbutton" name="btnDisplay" value="商標圖檔檢視" onclick="br_form.PreviewAttach_photo_mod('ttg3_mod_dmt_neaddr4','ttg3_10')" >	
		<br>
		</span>
		</TD>
	</TR>
</table>
</div>

<script language="javascript" type="text/javascript">
    //增加一筆註冊人
    $("#DI1_AP_Add_button").click(function () {
        var nRow = CInt($("#DI1_apnum").val()) + 1;
        //複製樣板
        var copyStr = $("#di1_ap_template").text() || "";
        copyStr = copyStr.replace(/##/g, nRow);

        $("#DI1_tabap>tbody").append("<tr id='tr_di1_" + nRow + "' class='sfont9'><td><table border='0' class='bluetable' cellspacing='1' cellpadding='2' width='100%'>" + copyStr + "</table></td></tr>");
        $("#tr_di1_" + nRow + " .Lock").lock();
        $("#DI1_apnum").val(nRow);
    });

    //減少一筆註冊人
    $("#DI1_AP_Del_button").click(function () {
        var nRow = CInt($("#DI1_apnum").val());
        $('#tr_di1_' + nRow).remove();
        $("#DI1_apnum").val(Math.max(0, nRow - 1));
    });

    //註冊號數
    $("#fr3_issue_no").blur(function () {
        chk_dmt_issueno($(this)[0],8);
		reg.tfzd_issue_no.value=$(this).val();
    });

    //計算類別
    br_form.count_kind_DI1 = function () {
        var pclass=[];
        var pcount=0;
        if ($("#fr3_class").val() != "") {
            pclass=$("#fr3_class").val().split(",");
            for(var j=0;j<pclass.length;j++){
                pclass[j]=("000" + pclass[j]).Right(3);//補0
            }
        }

        $("#fr3_class,#tfzr_class").val(pclass.get().join(','));
        $("#fr3_class_count,#tfzr_class_count").val(pclass.length);
    }

    //條款項目共N項
    br_form.add_button_DI1 = function (aprepCount) {
        var doCount = Math.max(0, CInt(aprepCount));//要改為幾筆,最少是0
        var cnt31 = CInt($("#cnt31").val());//目前畫面上有幾筆
        if (doCount > cnt31) {//要加
            for (var nRow = cnt31; nRow < doCount ; nRow++) {
                var copyStr = $("#di1_aprep_template").text() || "";
                copyStr = copyStr.replace(/##/g, nRow + 1);
                $("#tabbr31 tbody").append(copyStr);
                $("#cnt31").val(nRow + 1);
            }
        } else {
            //要減
            for (var nRow = cnt31; nRow > doCount ; nRow--) {
                $('.tr_di1_aprep_' + nRow).remove();
                $("#cnt31").val(nRow - 1);
            }
        }
    }

    //交辦內容綁定
    br_form.bindDI1 = function () {
        console.log("di1.br_form.bind");
        if (jMain.case_main.length == 0) {
        } else {
        }
    }
</script>
