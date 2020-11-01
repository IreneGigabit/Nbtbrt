<%@ Control Language="C#" ClassName="DR1Form" %>
<%@ Import Namespace = "System.Collections.Generic"%>

<script runat="server">
    //B爭議案交辦內容
    //父控制項傳入的參數
    public Dictionary<string, string> Lock = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    
    protected string prgid = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string SQL = "";

    protected string tfp1_agt_no = "";
    
    private void Page_Load(System.Object sender, System.EventArgs e) {
        PageLayout();   
        this.DataBind();
    }
    
    private void PageLayout() {
        //代理人
        tfp1_agt_no = Sys.getAgent().Option("{agt_no}", "{agt_no}_{agt_namefull}", " v1='{agt_name1}' {selected}", true);
    }
</script>

<div id="div_Form_DR1">
<%=Sys.GetAscxPath(this)%>
<TABLE border=0 class=bluetable cellspacing=1 cellpadding=2 width="100%">
	<tr>			
		<td class=lightbluetable align=right><strong>案件種類：</strong></td>
		<td class=whitetablebg colspan=7>
            <Select name="tfp1_case_stat" id="tfp1_case_stat" onchange="br_form.new_oldcaseB('tfp1')">
			<option value="NN">新案</option>
			<option value="SN">新案(指定編號)</option>
            </Select>
		</TD>
	</tr>
	<tr  >
		<td class="lightbluetable" align=right><strong>本所編號：</strong></td>
		<td class="whitetablebg" colspan="7" id="showseq_tfp1" style="display:none">
			<input type="text" size="5" name="tfp1_seq" id="tfp1_seq" readonly class="SEdit">-
			<select name=tfp1_seq1 id=tfp1_seq1 onchange="br_form.seq1_conctrl()">
				<option value="_">一般</option>
				<option value="M">M_大陸案</option>
			</select>
		</td>
		<td class=whitetablebg colspan=7 style="display:none" id="ShowNewAssign_tfp1">
			<INPUT TYPE=text NAME=tfp1_New_Ass_seq id=tfp1_New_Ass_seq SIZE=5 MAXLENGTH=5 onblur="dmt_form.New_ass_seqB_blur('tfp1')">-<INPUT TYPE=text NAME=tfp1_New_Ass_seq1 id=tfp1_New_Ass_seq1 SIZE=1 MAXLENGTH=1 value="" onblur="dmt_form.New_ass_seqB_blur('tfp1')">	
		</td>
	</tr>
	<tr>
		<td class="lightbluetable" valign="top" ><strong>※、代理人(代碼)</strong></td>
		<td class="whitetablebg" colspan="7" >
		    <select id="tfp1_agt_no" NAME="tfp1_agt_no" onchange="br_form.copycaseZZ('tfp1_agt_no')"><%#tfp1_agt_no%></select>
		</td>
	</tr>
	<tr>
		<td class="lightbluetable" colspan="8" valign="top" width="20%" STYLE="cursor:pointer;COLOR:BLUE" onclick="PMARK(R1Appl_name)">
            <strong>壹、<u>廢止標的(你要廢止的標章)</u></strong>
        </td>
	</tr>
	<tr>
		<td class=lightbluetable align=right >商標種類：</td>
		<td class=whitetablebg colspan="7">
			<input type=radio name=fr1_S_Mark class="onoff" value="" onclick="dmt_form.change_mark(1, this)">商標
			<input type=radio name=fr1_S_Mark class="onoff" value="S" onclick="dmt_form.change_mark(1, this)">商標(92年修正前服務標章)
			<input type=radio name=fr1_S_Mark class="onoff" value="N" onclick="dmt_form.change_mark(1, this)">團體商標
			<input type=radio name=fr1_S_Mark class="onoff" value="M" onclick="dmt_form.change_mark(1, this)">團體標章
			<input type=radio name=fr1_S_Mark class="onoff" value="L" onclick="dmt_form.change_mark(1, this)">證明標章
		</TD>
	</tr>
	<tr>
		<td class=lightbluetable align=right >註冊號數：</td>
		<td class=whitetablebg colspan="3">
			<input type="text" id="fr1_issue_no" name="fr1_issue_no" value="" size="20" maxlength="20" >
		</TD>
		<td class=lightbluetable align=right width="18%">商標/標章名稱：</td>
		<td class=whitetablebg colspan="3">
			<input type="text" id="fr1_appl_name" name="fr1_appl_name" class="onoff" value="" size="30" maxlength="100" onchange="reg.tfzd_appl_name.value=this.value">
		</TD>
	</tr>
	<tr>
		<td class=lightbluetable align=right >擬廢止之類別種類：</td>
		<td class=whitetablebg colspan="3">
			<input type="radio" id=fr1_class_typeI name=fr1_class_type value="int" class="onoff" onclick="reg.tfzr_class_type(0).checked = reg.fr1_class_type(0).checked">國際分類
			<input type="radio" id=fr1_class_typeO name=fr1_class_type value="old" class="onoff" onclick="reg.tfzr_class_type(1).checked = reg.fr1_class_type(1).checked">舊類
		</TD>
		<td class=lightbluetable align=right width="18%" STYLE="cursor:pointer;COLOR:BLUE" title="請輸入類別，並以逗號分開(例如：001,005,032)。">擬廢止之類別：</td>
		<td class=whitetablebg colspan="3">
			<input type="text" id="fr1_class" name="fr1_class" value="" size="30" maxlength="100" onchange="br_form.count_kind_DR1()">，
			共<input type="text" id="fr1_class_count" name="fr1_class_count" value="" size=3 readonly class="SEdit" >類(廢止案依類別計算，請填具正確類別)
		</TD>
	</tr>
	<tr>
		<td class="lightbluetable" colspan="8" valign="top" width="20%">
            <strong>你要廢止的商標/標章圖樣包含那一部份請打勾並填寫：</strong>
		</td>
	</tr>
	<tr>
		<td class=lightbluetable align=right width="20%"></td>
		<td class=whitetablebg colspan=7>
            <input type="checkbox" name=R_cappl_name value="C">中文
            <input type="checkbox" name=R_eappl_name value="E">英文
            <input type="checkbox" name=R_jappl_name value="J">日文
            <input type="checkbox" name=R_draw value="D">圖形
            <input type="checkbox" name=R_zappl_name1 value="Z">其他（非英文或日文之外國文字、顏色、聲音、立體形狀等）
		</td>
	</tr>
	<tr>
		<td class=lightbluetable align=right></td>
		<td class=whitetablebg colspan=7>
            <INPUT TYPE=text NAME=R_remark3 id=R_remark3 SIZE=30 MAXLENGTH=50>
		</td>
	</tr>
	<tr>
		<td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:pointer;COLOR:BLUE" onclick="PMARK(O1Rapcust)">
            <strong>肆、<u>註冊人</u></strong>
		</td>
	</tr>
	<tr >
		<td colspan="8" class='sfont9'>
		<input type=hidden id=DR1_apnum name=DR1_apnum value=0><!--進度筆數-->
		<table border="0" id=DR1_tabap class="bluetable" cellspacing="1" cellpadding="1" width="100%">
        <thead>
		    <TR>
			    <TD  class=whitetablebg colspan=2 align=right>
				    <input type=button value ="增加一筆註冊人" class="cbutton" id=DR1_AP_Add_button name=DR1_AP_Add_button>
				    <input type=button value ="減少一筆註冊人" class="cbutton" id=DR1_AP_Del_button name=DR1_AP_Del_button>
			    </TD>
		    </TR>
        </thead>
        <tbody></tbody>
        <script type="text/html" id="dr1_ap_template">
	        <TR>
		        <TD class=lightbluetable align=right>
			        <input type=text id='DR1_apnum_##' name='DR1_apnum_##' class=SEdit readonly style='color:black;' size=2 value='##.'>名稱或姓名：
		        </TD>
		        <TD class=whitetablebg>
		            <input TYPE=text NAME=ttg1_mod_ap_ncname1_## id=ttg1_mod_ap_ncname1_## SIZE=60 MAXLENGTH=100 alt='『註冊人名稱』' onblur='fDataLen(this)'><br>
		            <input TYPE=text NAME=ttg1_mod_ap_ncname2_## id=ttg1_mod_ap_ncname2_## SIZE=60 MAXLENGTH=100 alt='『註冊人名稱』' onblur='fDataLen(this)'>
		        </TD>
	        </TR>
	        <TR>
		        <TD class=lightbluetable align=right>
			        地　　　址：
		        </TD>
		        <TD class=whitetablebg>
		            <input TYPE=text NAME=ttg1_mod_ap_nzip_## id=ttg1_mod_ap_nzip_## SIZE=8 MAXLENGTH=8 alt='『註冊人郵遞區號』' onblur='fDataLen(this)'>
		            <input TYPE=text NAME=ttg1_mod_ap_naddr1_## id=ttg1_mod_ap_naddr1_## SIZE=30 MAXLENGTH=60 alt='『註冊人地址』' onblur='fDataLen(this)'>
		            <input TYPE=text NAME=ttg1_mod_ap_naddr2_## id=ttg1_mod_ap_naddr2_## SIZE=30 MAXLENGTH=60 alt='『註冊人地址』' onblur='fDataLen(this)'>
		        </TD>
	        </TR>
	        <TR>
		        <TD class=lightbluetable align=right>
			        代理人姓名：
		        </TD>
		        <TD class=whitetablebg>
		            <input TYPE=text NAME=ttg1_mod_ap_ncrep_## id=ttg1_mod_ap_ncrep_## SIZE=20 MAXLENGTH=20 alt='『註冊人代理人』' onblur='fDataLen(this)'>
		        </TD>
	        </TR>
        </script>
		</table>
		</td>
	</tr>
	<tr>
		<td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:pointer;COLOR:BLUE" onclick="PMARK(R1New_no)">
            <strong>伍、<u>廢止聲明：</u></strong>
		</td>
	</tr>
	<tr>
		<td class=lightbluetable align=right valign=top></td>
		<td class=whitetablebg colspan=7>第<INPUT TYPE=text NAME=ttg11_mod_pul_new_no id=ttg11_mod_pul_new_no SIZE=10 MAXLENGTH=10>號「<INPUT TYPE=text NAME=ttg11_mod_pul_ncname1 id=ttg11_mod_pul_ncname1 SIZE=30 MAXLENGTH=50>」
            <input type="radio" name="ttg11_mod_pul_mod_type" value="Tmark">商標
            <input type="radio" name="ttg11_mod_pul_mod_type" value="Lmark">標章
		</td>
	</tr>
	<tr>
		<td class=lightbluetable align=right valign=top><input type="checkbox" name=ttg12_mod_pul_mod_type value="R1"></td>
		<td class=whitetablebg colspan=7>之商標權，應予廢止。</td>
	</tr>
	<tr>
		<td class=lightbluetable align=right valign=top><input type="checkbox" name=ttg13_mod_pul_mod_type value="R2"></td>
		<td class=whitetablebg colspan=7>指定使用於商標法施行細則第<INPUT TYPE=text NAME=ttg13_mod_pul_new_no id=ttg13_mod_pul_new_no SIZE=3 MAXLENGTH=10>條第<INPUT TYPE=text NAME=ttg13_mod_pul_mod_dclass id=ttg13_mod_pul_mod_dclass SIZE=20 MAXLENGTH=20>類商品/服務之商標權應予廢止。</td>
	</tr>

    <tr>
		<td class=lightbluetable align=right valign=top><input type="checkbox" name=ttg14_mod_pul_mod_type value="R3"></td>
		<td class=whitetablebg colspan=7>指定使用於商標法施行細則第<INPUT TYPE=text NAME=ttg14_mod_pul_new_no id=ttg14_mod_pul_new_no SIZE=3 MAXLENGTH=10>條第<INPUT TYPE=text NAME=ttg14_mod_pul_mod_dclass id=ttg14_mod_pul_mod_dclass SIZE=3 MAXLENGTH=3>類<INPUT TYPE=text NAME=ttg14_mod_pul_ncname1 id=ttg14_mod_pul_ncname1 SIZE=30 MAXLENGTH=50>商品/服務之商標權應予廢止。</td>
	</tr>
	<tr>
		<td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:pointer;COLOR:BLUE" onclick="PMARK(R1Other_item1)"><strong>陸、<u>主張法條及據以廢止商標／標章：</u></strong></td>
	</tr>
	<TR>
		<TD class=lightbluetable align=left>一、主張條款：</TD>
		<TD class=whitetablebg colspan=7>商標法<input TYPE=text NAME=tfz1_other_item1 id=tfz1_other_item1 SIZE=30 MAXLENGTH=50 alt="『主張條款』" onblur="fDataLen(this)" value="第  條第  項第  款">。</TD>
	</TR>
	<TR>
		<TD class=lightbluetable align=left width="22%">二、據以廢止商標／標章：</TD>
		<TD class=whitetablebg colspan=7><input TYPE=text NAME=ttg1_mod_claim1_ncname1 id=ttg1_mod_claim1_ncname1 SIZE=30 MAXLENGTH=50 alt="『據以廢止商標／標章』" onblur="fDataLen(this)"></TD>
	</TR>
	<tr>
		<td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:pointer;COLOR:BLUE" onclick="PMARK(R1Tran_remark1)"><strong>柒、<u>事實及理由：</u></strong></td>
	</tr>
	<tr>
		<td class="lightbluetable" colspan="8" valign="top"><TEXTAREA rows=9 cols=100 id=tfz1_tran_remark1 name=tfz1_tran_remark1></TEXTAREA></td>
	</tr>
	<tr>
		<td class="lightbluetable" colspan="8" valign="top" >【主張法條為商標法第63條第1項第1款且據以廢止商標註冊已滿3年者，<u>請具體說明據以廢止商標使用情形</u>】</td>
	</tr>
	<tr>
		<td class="lightbluetable" colspan="8" valign="top"><TEXTAREA rows=9 cols=100 id=tfz1_tran_remark4 name=tfz1_tran_remark4 ></TEXTAREA></td>
	</tr>
	<tr>
		<td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:pointer;COLOR:BLUE" onclick="PMARK(ZAttechD)"><strong>捌、<u>證據(附件)內容：</u></strong></td>
	</tr>
	<tr>
		<td class="lightbluetable" colspan="8" valign="top"><TEXTAREA rows=9 cols=100 id=tfz1_tran_remark2 name=tfz1_tran_remark2></TEXTAREA></td>
	</tr>
	<tr>
		<td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:pointer;COLOR:BLUE" onclick="PMARK(R1Other_item)"><strong>玖、<u>相關聯案件：</u></strong></td>
	</tr>
	<TR>
		<TD class=lightbluetable align=right></TD>
		<TD class=whitetablebg colspan=7>
		本案與<input TYPE=text NAME=R_O_item1 id=R_O_item1 SIZE=10 MAXLENGTH=10 class="dateField">(年/月/日)註冊第<input type="text" id="R_O_item2" name="R_O_item2" SIZE=10>號<input type="text" id="R_O_item3" name="R_O_item3" SIZE=10>案有關
		<input type="hidden" name="tfz1_other_item" id="tfz1_other_item">
		</TD>
	</TR>
	<tr>
		<td class="lightbluetable" colspan="8" valign="top"><strong>※廢止商標及據以廢止商標圖樣：</strong></td>
	</tr>
	<TR>
		<TD class=lightbluetable>一、廢止標的圖樣：</TD>
		<TD class=whitetablebg colspan=7>
		<input TYPE=text NAME=tfp1_draw_file id=tfp1_draw_file SIZE=50 MAXLENGTH=50 readonly>
		<input TYPE=hidden NAME=tfp1_file id=tfp1_file >
		<input type="button" class="cbutton" id="butUploadtfp1" name="butUploadtfp1" value="商標圖檔上傳" onclick="dmt_form.UploadAttach_photo('tfp1')" >
		<input type="button" class="redbutton" id="btnDelAtt" name="btnDelAtt" value="商標圖檔刪除" onclick="dmt_form.DelAttach_photo('tfp1')" >
        <input type="button" class="cbutton" id="btnDisplay" name="btnDisplay" value="商標圖檔檢視" onclick="dmt_form.PreviewAttach_photo('tfp1')" >
		</TD>
	</TR>	
	<TR>
		<TD class=lightbluetable align=right>二、變換加附記使用後之商標/標章圖樣：</TD>
		<TD class=whitetablebg colspan=7>
            <input type="button" class="cbutton" name="butadd_draw" value="增加一筆商標圖檔" onclick="br_form.drawadd('ttg1c')">
            <input type="hidden" name="draw_num_ttg1c" id="draw_num_ttg1c" value=5><!--預設5，因畫面直接顯示5筆，若有6筆以上，edit再給值--><br>
		    1.<input TYPE=text NAME=ttg1_mod_class_ncname1 id=ttg1_mod_class_ncname1 SIZE=50 MAXLENGTH=50 readonly>
			<input TYPE=hidden NAME=draw_attach_file_ttg1c_1 id=draw_attach_file_ttg1c_1 >
			<input TYPE=hidden NAME=old_file_ttg1c_1 id=old_file_ttg1c_1 >
			<input type="button" class="cbutton" id="butUploadttg1c_1" name="butUploadttg1c_1" value="商標圖檔上傳" onclick="br_form.UploadAttach_photo_mod('ttg1_mod_class_ncname1','ttg1c_1')" >
		    <input type="button" class="redbutton" name="btnDelAtt" value="商標圖檔刪除" onclick="br_form.DelAttach_photo_mod('ttg1c_mod_dmt_ncname1', 'ttg1c_1')" >
            <input type="button" class="cbutton" name="btnDisplay" value="商標圖檔檢視" onclick="br_form.PreviewAttach_photo_mod('ttg1c_mod_dmt_ncname1', 'ttg1c_1')" >
			<br>
			2.<input TYPE=text NAME=ttg1_mod_class_ncname2 id=ttg1_mod_class_ncname2 SIZE=50 MAXLENGTH=50 readonly>
			  <input TYPE=hidden NAME=draw_attach_file_ttg1c_2 id=draw_attach_file_ttg1c_2 >
			  <input TYPE=hidden NAME=old_file_ttg1c_2 id=old_file_ttg1c_2 >
			  <input type="button" class="cbutton" id="butUploadttg1c_2" name="butUploadttg1c_2" value="商標圖檔上傳" onclick="br_form.UploadAttach_photo_mod('ttg1_mod_class_ncname2','ttg1c_2')" >
		      <input type="button" class="redbutton" name="btnDelAtt" value="商標圖檔刪除" onclick="br_form.DelAttach_photo_mod('ttg1_mod_class_ncname2','ttg1c_2')" >
              <input type="button" class="cbutton" name="btnDisplay" value="商標圖檔檢視" onclick="br_form.PreviewAttach_photo_mod('ttg1_mod_class_ncname2','ttg1c_2')" >
			  <br>
			3.<input TYPE=text NAME=ttg1_mod_class_nename1 id=ttg1_mod_class_nename1 SIZE=50 MAXLENGTH=50 readonly>
			  <input TYPE=hidden NAME=draw_attach_file_ttg1c_3 id=draw_attach_file_ttg1c_3 >
			  <input TYPE=hidden NAME=old_file_ttg1c_3 id=old_file_ttg1c_3 >
			  <input type="button" class="cbutton" id="butUploadttg1c_3" name="butUploadttg1c_3" value="商標圖檔上傳" onclick="br_form.UploadAttach_photo_mod('ttg1_mod_class_nename1','ttg1c_3')" >
		      <input type="button" class="redbutton" name="btnDelAtt" value="商標圖檔刪除" onclick="br_form.DelAttach_photo_mod('ttg1_mod_class_nename1','ttg1c_3')" >
              <input type="button" class="cbutton" name="btnDisplay" value="商標圖檔檢視" onclick="br_form.PreviewAttach_photo_mod('ttg1_mod_class_nename1','ttg1c_3')" >
			  <br>
			4.<input TYPE=text NAME=ttg1_mod_class_nename2 id=ttg1_mod_class_nename2 SIZE=50 MAXLENGTH=50 readonly>
			  <input TYPE=hidden NAME=draw_attach_file_ttg1c_4 id=draw_attach_file_ttg1c_4 >
			  <input TYPE=hidden NAME=old_file_ttg1c_4 id=old_file_ttg1c_4 >
			  <input type="button" class="cbutton" id="butUploadttg1c_4" name="butUploadttg1c_4" value="商標圖檔上傳" onclick="br_form.UploadAttach_photo_mod('ttg1_mod_class_nename2','ttg1c_4')" >
		      <input type="button" class="redbutton" name="btnDelAtt" value="商標圖檔刪除" onclick="br_form.DelAttach_photo_mod('ttg1_mod_class_nename2','ttg1c_4')" >
              <input type="button" class="cbutton" name="btnDisplay" value="商標圖檔檢視" onclick="br_form.PreviewAttach_photo_mod('ttg1_mod_class_nename2','ttg1c_4')" >
			  <br>
			5.<input TYPE=text NAME=ttg1_mod_class_ncrep id=ttg1_mod_class_ncrep SIZE=50 MAXLENGTH=50 readonly>
			  <input TYPE=hidden NAME=draw_attach_file_ttg1c_5 id=draw_attach_file_ttg1c_5 >
			  <input TYPE=hidden NAME=old_file_ttg1c_5 id=old_file_ttg1c_5 >
			  <input type="button" class="cbutton" id="butUploadttg1c_5" name="butUploadttg1c_5" value="商標圖檔上傳" onclick="br_form.UploadAttach_photo_mod('ttg1_mod_class_ncrep','ttg1c_5')" >
		      <input type="button" class="redbutton" name="btnDelAtt" value="商標圖檔刪除" onclick="br_form.DelAttach_photo_mod('ttg1_mod_class_ncrep','ttg1c_5')" >
              <input type="button" class="cbutton" name="btnDisplay" value="商標圖檔檢視" onclick="br_form.PreviewAttach_photo_mod('ttg1_mod_class_ncrep','ttg1c_5')" >
			  <br>
			<span id="sp_ttg1c_6" style="display:none">
			6.<input TYPE=text NAME=ttg1_mod_class_nerep id=ttg1_mod_class_nerep SIZE=50 MAXLENGTH=50 readonly>  
			  <input TYPE=hidden NAME=draw_attach_file_ttg1c_6 id=draw_attach_file_ttg1c_6 >
			  <input TYPE=hidden NAME=old_file_ttg1c_6 id=old_file_ttg1c_6 >
			  <input type="button" class="cbutton" id="butUploadttg1c_6" name="butUploadttg1c_6" value="商標圖檔上傳" onclick="br_form.UploadAttach_photo_mod('ttg1_mod_class_nerep','ttg1c_6')" >
		      <input type="button" class="redbutton" name="btnDelAtt" value="商標圖檔刪除" onclick="br_form.DelAttach_photo_mod('ttg1_mod_class_nerep','ttg1c_6')" >
              <input type="button" class="cbutton" name="btnDisplay" value="商標圖檔檢視" onclick="br_form.PreviewAttach_photo_mod('ttg1_mod_class_nerep','ttg1c_6')" >	
			<br>
			</span>
			<span id="sp_ttg1c_7" style="display:none">
			7.<input TYPE=text NAME=ttg1_mod_class_neaddr1 id=ttg1_mod_class_neaddr1 SIZE=50 MAXLENGTH=50 readonly>  
			  <input TYPE=hidden NAME=draw_attach_file_ttg1c_7 id=draw_attach_file_ttg1c_7 >
			  <input TYPE=hidden NAME=old_file_ttg1c_7 id=old_file_ttg1c_7 >
			  <input type="button" class="cbutton" id="butUploadttg1c_7" name="butUploadttg1c_7" value="商標圖檔上傳" onclick="br_form.UploadAttach_photo_mod('ttg1_mod_class_neaddr1','ttg1c_7')" >
		      <input type="button" class="redbutton" name="btnDelAtt" value="商標圖檔刪除" onclick="br_form.DelAttach_photo_mod('ttg1_mod_class_neaddr1','ttg1c_7')" >
              <input type="button" class="cbutton" name="btnDisplay" value="商標圖檔檢視" onclick="br_form.PreviewAttach_photo_mod('ttg1_mod_class_neaddr1','ttg1c_7')" >	
			<br>
			</span>
			<span id="sp_ttg1c_8" style="display:none">
			8.<input TYPE=text NAME=ttg1_mod_class_neaddr2 id=ttg1_mod_class_neaddr2 SIZE=50 MAXLENGTH=50 readonly>  
			  <input TYPE=hidden NAME=draw_attach_file_ttg1c_8 id=draw_attach_file_ttg1c_8 >
			  <input TYPE=hidden NAME=old_file_ttg1c_8 id=old_file_ttg1c_8 >
			  <input type="button" class="cbutton" id="butUploadttg1c_8" name="butUploadttg1c_8" value="商標圖檔上傳" onclick="br_form.UploadAttach_photo_mod('ttg1_mod_class_neaddr2','ttg1c_8')" >
		      <input type="button" class="redbutton" name="btnDelAtt" value="商標圖檔刪除" onclick="br_form.DelAttach_photo_mod('ttg1_mod_class_neaddr2','ttg1c_8')" >
              <input type="button" class="cbutton" name="btnDisplay" value="商標圖檔檢視" onclick="br_form.PreviewAttach_photo_mod('ttg1_mod_class_neaddr2','ttg1c_8')" >	
			<br>
			</span>
			<span id="sp_ttg1c_9" style="display:none">
			9.<input TYPE=text NAME=ttg1_mod_class_neaddr3 id=ttg1_mod_class_neaddr3 SIZE=50 MAXLENGTH=50 readonly>  
			  <input TYPE=hidden NAME=draw_attach_file_ttg1c_9 id=draw_attach_file_ttg1c_9 >
			  <input TYPE=hidden NAME=old_file_ttg1c_9 id=old_file_ttg1c_9 >
			  <input type="button" class="cbutton" id="butUploadttg1c_9" name="butUploadttg1c_9" value="商標圖檔上傳" onclick="br_form.UploadAttach_photo_mod('ttg1_mod_class_neaddr3','ttg1c_9')" >
		      <input type="button" class="redbutton" name="btnDelAtt" value="商標圖檔刪除" onclick="br_form.DelAttach_photo_mod('ttg1_mod_class_neaddr3','ttg1c_9')" >
              <input type="button" class="cbutton" name="btnDisplay" value="商標圖檔檢視" onclick="br_form.PreviewAttach_photo_mod('ttg1_mod_class_neaddr3','ttg1c_9')" >	
			<br>
			</span>
			<span id="sp_ttg1c_10" style="display:none">
			10.<input TYPE=text NAME=ttg1_mod_class_neaddr4 id=ttg1_mod_class_neaddr4 SIZE=50 MAXLENGTH=50 readonly>  
			  <input TYPE=hidden NAME=draw_attach_file_ttg1c_10 id=draw_attach_file_ttg1c_10 >
			  <input TYPE=hidden NAME=old_file_ttg1c_10 id=old_file_ttg1c_10 >
			  <input type="button" class="cbutton" id="butUploadttg1c_10" name="butUploadttg1c_10" value="商標圖檔上傳" onclick="br_form.UploadAttach_photo_mod('ttg1_mod_class_neaddr4','ttg1c_10')" >
		      <input type="button" class="redbutton" name="btnDelAtt" value="商標圖檔刪除" onclick="br_form.DelAttach_photo_mod('ttg1_mod_class_neaddr4','ttg1c_10')" >
              <input type="button" class="cbutton" name="btnDisplay" value="商標圖檔檢視" onclick="br_form.PreviewAttach_photo_mod('ttg1_mod_class_neaddr4','ttg1c_10')" >	
			<br>
			</span>  
		</TD>
	</TR>
	<TR>
		<TD class=lightbluetable align=right>三、據以廢止商標／標章圖樣：</TD>
		<TD class=whitetablebg colspan=7>
            <input type="button" class="cbutton" name="butadd_draw" value="增加一筆商標圖檔" onclick="br_form.drawadd('ttg1')">
            <input type="hidden" name="draw_num_ttg1" id="draw_num_ttg1" value=5><!--預設5，因畫面直接顯示5筆，若有6筆以上，edit再給值--><br>
		1.<input TYPE=text NAME=ttg1_mod_dmt_ncname1 id=ttg1_mod_dmt_ncname1 SIZE=50 MAXLENGTH=50 readonly>
			<input TYPE=hidden NAME=draw_attach_file_ttg1_1 id=draw_attach_file_ttg1_1 >
			<input TYPE=hidden NAME=old_file_ttg1_1 id=old_file_ttg1_1 >
			<input type="button" class="cbutton" id="butUploadttg1_1" name="butUploadttg1_1" value="商標圖檔上傳" onclick="br_form.UploadAttach_photo_mod('ttg1_mod_dmt_ncname1','ttg1_1')" >
		    <input type="button" class="redbutton" name="btnDelAtt" value="商標圖檔刪除" onclick="br_form.DelAttach_photo_mod('ttg1_mod_dmt_ncname1','ttg1_1')" >
            <input type="button" class="cbutton" name="btnDisplay" value="商標圖檔檢視" onclick="br_form.PreviewAttach_photo_mod('ttg1_mod_dmt_ncname1','ttg1_1')" >
		<br>
		2.<input TYPE=text NAME=ttg1_mod_dmt_ncname2 id=ttg1_mod_dmt_ncname2 SIZE=50 MAXLENGTH=50 readonly>
			<input TYPE=hidden NAME=draw_attach_file_ttg1_2 id=draw_attach_file_ttg1_2 >
			<input TYPE=hidden NAME=old_file_ttg1_2 id=old_file_ttg1_2 >
			<input type="button" class="cbutton" id="butUploadttg1_2" name="butUploadttg1_2" value="商標圖檔上傳" onclick="br_form.UploadAttach_photo_mod('ttg1_mod_dmt_ncname2','ttg1_2')" >
		    <input type="button" class="redbutton" name="btnDelAtt" value="商標圖檔刪除" onclick="br_form.DelAttach_photo_mod('ttg1_mod_dmt_ncname2','ttg1_2')" >
            <input type="button" class="cbutton"  name="btnDisplay" value="商標圖檔檢視" onclick="br_form.PreviewAttach_photo_mod('ttg1_mod_dmt_ncname2','ttg1_2')" >	
		<br>
		3.<input TYPE=text NAME=ttg1_mod_dmt_nename1 id=ttg1_mod_dmt_nename1 SIZE=50 MAXLENGTH=50 readonly>
			<input TYPE=hidden NAME=draw_attach_file_ttg1_3 id=draw_attach_file_ttg1_3 >
			<input type="button" class="cbutton" id="butUploadttg1_3" name="butUploadttg1_3" value="商標圖檔上傳" onclick="br_form.UploadAttach_photo_mod('ttg1_mod_dmt_nename1','ttg1_3')" >
		    <input type="button" class="redbutton" name="btnDelAtt" value="商標圖檔刪除" onclick="br_form.DelAttach_photo_mod('ttg1_mod_dmt_nename1','ttg1_3')" >
            <input type="button" class="cbutton" name="btnDisplay" value="商標圖檔檢視" onclick="br_form.PreviewAttach_photo_mod('ttg1_mod_dmt_nename1','ttg1_3')" >	
		<br>
		4.<input TYPE=text NAME=ttg1_mod_dmt_nename2 id=ttg1_mod_dmt_nename2 SIZE=50 MAXLENGTH=50 readonly>
			<input TYPE=hidden NAME=draw_attach_file_ttg1_4 id=draw_attach_file_ttg1_4 >
			<input TYPE=hidden NAME=old_file_ttg1_4 id=old_file_ttg1_4 >
			<input type="button" class="cbutton" id="butUploadttg1_4" name="butUploadttg1_4" value="商標圖檔上傳" onclick="br_form.UploadAttach_photo_mod('ttg1_mod_dmt_nename2','ttg1_4')" >
		    <input type="button" class="redbutton" name="btnDelAtt" value="商標圖檔刪除" onclick="br_form.DelAttach_photo_mod('ttg1_mod_dmt_nename2','ttg1_4')" >
            <input type="button" class="cbutton" name="btnDisplay" value="商標圖檔檢視" onclick="br_form.PreviewAttach_photo_mod('ttg1_mod_dmt_nename2','ttg1_4')" >	
		<br>
		5.<input TYPE=text NAME=ttg1_mod_dmt_ncrep id=ttg1_mod_dmt_ncrep SIZE=50 MAXLENGTH=50 readonly>
			<input TYPE=hidden NAME=draw_attach_file_ttg1_5 id=draw_attach_file_ttg1_5 >
			<input TYPE=hidden NAME=old_file_ttg1_5 id=old_file_ttg1_5 >
			<input type="button" class="cbutton" id="butUploadttg1_5" name="butUploadttg1_5" value="商標圖檔上傳" onclick="br_form.UploadAttach_photo_mod('ttg1_mod_dmt_ncrep','ttg1_5')" >
		    <input type="button" class="redbutton" name="btnDelAtt" value="商標圖檔刪除" onclick="br_form.DelAttach_photo_mod('ttg1_mod_dmt_ncrep','ttg1_5')" >
            <input type="button" class="cbutton" name="btnDisplay" value="商標圖檔檢視" onclick="br_form.PreviewAttach_photo_mod('ttg1_mod_dmt_ncrep','ttg1_5')" >
		<br>
		<span id="sp_ttg1_6" style="display:none">
		6.<input TYPE=text NAME=ttg1_mod_dmt_nerep id=ttg1_mod_dmt_nerep SIZE=50 MAXLENGTH=50 readonly>  
			<input TYPE=hidden NAME=draw_attach_file_ttg1_6 id=draw_attach_file_ttg1_6 >
			<input TYPE=hidden NAME=old_file_ttg1_6 id=old_file_ttg1_6 >
			<input type="button" class="cbutton" id="butUploadttg1_6" name="butUploadttg1_6" value="商標圖檔上傳" onclick="br_form.UploadAttach_photo_mod('ttg1_mod_dmt_nerep','ttg1_6')" >
		    <input type="button" class="redbutton" name="btnDelAtt" value="商標圖檔刪除" onclick="br_form.DelAttach_photo_mod('ttg1_mod_dmt_nerep','ttg1_6')" >
            <input type="button" class="cbutton" name="btnDisplay" value="商標圖檔檢視" onclick="br_form.PreviewAttach_photo_mod('ttg1_mod_dmt_nerep','ttg1_6')" >	
		<br>
		</span>
		<span id="sp_ttg1_7" style="display:none">
		7.<input TYPE=text NAME=ttg1_mod_dmt_neaddr1 id=ttg1_mod_dmt_neaddr1 SIZE=50 MAXLENGTH=50 readonly>  
			<input TYPE=hidden NAME=draw_attach_file_ttg1_7 id=draw_attach_file_ttg1_7 >
			<input TYPE=hidden NAME=old_file_ttg1_7 id=old_file_ttg1_7 >
			<input type="button" class="cbutton" id="butUploadttg1_7" name="butUploadttg1_7" value="商標圖檔上傳" onclick="br_form.UploadAttach_photo_mod('ttg1_mod_dmt_neaddr1','ttg1_7')" >
		    <input type="button" class="redbutton" name="btnDelAtt" value="商標圖檔刪除" onclick="br_form.DelAttach_photo_mod('ttg1_mod_dmt_neaddr1','ttg1_7')" >
            <input type="button" class="cbutton" name="btnDisplay" value="商標圖檔檢視" onclick="br_form.PreviewAttach_photo_mod('ttg1_mod_dmt_neaddr1','ttg1_7')" >	
		<br>
		</span>
		<span id="sp_ttg1_8" style="display:none">
		8.<input TYPE=text NAME=ttg1_mod_dmt_neaddr2 id=ttg1_mod_dmt_neaddr2 SIZE=50 MAXLENGTH=50 readonly>  
			<input TYPE=hidden NAME=draw_attach_file_ttg1_8 id=draw_attach_file_ttg1_8 >
			<input TYPE=hidden NAME=old_file_ttg1_8 id=old_file_ttg1_8 >
			<input type="button" class="cbutton" id="butUploadttg1_8" name="butUploadttg1_8" value="商標圖檔上傳" onclick="br_form.UploadAttach_photo_mod('ttg1_mod_dmt_neaddr2','ttg1_8')" >
		    <input type="button" class="redbutton" name="btnDelAtt" value="商標圖檔刪除" onclick="br_form.DelAttach_photo_mod('ttg1_mod_dmt_neaddr2','ttg1_8')" >
            <input type="button" class="cbutton" name="btnDisplay" value="商標圖檔檢視" onclick="br_form.PreviewAttach_photo_mod('ttg1_mod_dmt_neaddr2','ttg1_8')" >	
		<br>
		</span>
		<span id="sp_ttg1_9" style="display:none">
		9.<input TYPE=text NAME=ttg1_mod_dmt_neaddr3 id=ttg1_mod_dmt_neaddr3 SIZE=50 MAXLENGTH=50 readonly>  
			<input TYPE=hidden NAME=draw_attach_file_ttg1_9 id=draw_attach_file_ttg1_9 >
			<input TYPE=hidden NAME=old_file_ttg1_9 id=old_file_ttg1_9 >
			<input type="button" class="cbutton" id="butUploadttg1_9" name="butUploadttg1_9" value="商標圖檔上傳" onclick="br_form.UploadAttach_photo_mod('ttg1_mod_dmt_neaddr3','ttg1_9')" >
		    <input type="button" class="redbutton" name="btnDelAtt" value="商標圖檔刪除" onclick="br_form.DelAttach_photo_mod('ttg1_mod_dmt_neaddr3','ttg1_9')" >
            <input type="button" class="cbutton" name="btnDisplay" value="商標圖檔檢視" onclick="br_form.PreviewAttach_photo_mod('ttg1_mod_dmt_neaddr3','ttg1_9')" >	
		<br>
		</span>
		<span id="sp_ttg1_10" style="display:none">
		10.<input TYPE=text NAME=ttg1_mod_dmt_neaddr4 id=ttg1_mod_dmt_neaddr4 SIZE=50 MAXLENGTH=50 readonly>  
			<input TYPE=hidden NAME=draw_attach_file_ttg1_10 id=draw_attach_file_ttg1_10 >
			<input TYPE=hidden NAME=old_file_ttg1_10 id=old_file_ttg1_10 >
			<input type="button" class="cbutton" id="butUploadttg1_10" name="butUploadttg1_10" value="商標圖檔上傳" onclick="br_form.UploadAttach_photo_mod('ttg1_mod_dmt_neaddr4','ttg1_10')" >
		    <input type="button" class="redbutton" name="btnDelAtt" value="商標圖檔刪除" onclick="br_form.DelAttach_photo_mod('ttg1_mod_dmt_neaddr4','ttg1_10')" >
            <input type="button" class="cbutton" name="btnDisplay" value="商標圖檔檢視" onclick="br_form.PreviewAttach_photo_mod('ttg1_mod_dmt_neaddr4','ttg1_10')" >	
		<br>
		</span>
		</TD>
	</TR>
</table>
</div>

<script language="javascript" type="text/javascript">
    //增加一筆註冊人
    $("#DR1_AP_Add_button").click(function () {
        var nRow = CInt($("#DR1_apnum").val()) + 1;
        //複製樣板
        var copyStr = $("#dr1_ap_template").text() || "";
        copyStr = copyStr.replace(/##/g, nRow);

        $("#DR1_tabap>tbody").append("<tr id='tr_dr1_" + nRow + "' class='sfont9'><td><table border='0' class='bluetable' cellspacing='1' cellpadding='2' width='100%'>" + copyStr + "</table></td></tr>");
        $("#tr_dr1_" + nRow + " .Lock").lock();
        $("#DR1_apnum").val(nRow);
    });

    //減少一筆註冊人
    $("#DR1_AP_Del_button").click(function () {
        var nRow = CInt($("#DR1_apnum").val());
        $('#tr_dr1_' + nRow).remove();
        $("#DR1_apnum").val(Math.max(0, nRow - 1));
    });

    //註冊號數
    $("#fr1_issue_no").blur(function () {
        chk_dmt_issueno($(this)[0],8);
		reg.tfzd_issue_no.value=$(this).val();
    });

    //計算類別
    br_form.count_kind_DR1 = function () {
        var pclass=[];
        var pcount=0;
        if ($("#fr1_class").val() != "") {
            pclass=$("#fr1_class").val().split(",");
            for(var j=0;j<pclass.length;j++){
                pclass[j]=("000" + pclass[j]).Right(3);//補0
            }
        }

        $("#fr1_class,#tfzr_class").val(pclass.get().join(','));
        $("#fr1_class_count,#tfzr_class_count").val(pclass.length);
    }

    //交辦內容綁定
    br_form.bindDR1 = function () {
        console.log("dr1.br_form.bind");
        if (jMain.case_main.length == 0) {
        } else {
        }
    }
</script>
