<%@ Control Language="C#" ClassName="DI1Form" %>
<%@ Import Namespace = "System.Collections.Generic"%>

<script runat="server">
    //B爭議案交辦內容
    //父控制項傳入的參數
    public Dictionary<string, string> Lock = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    public Dictionary<string, string> Hide = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    public int HTProgRight = 0;

    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected string SQL = "";

    protected string tfp3_agt_no = "";
    
    private void Page_Load(System.Object sender, System.EventArgs e) {
        PageLayout();   
        this.DataBind();
    }
    
    private void PageLayout() {
        //代理人
        tfp3_agt_no = Sys.getAgent().Option("{agt_no}", "{agt_no}_{agt_namefull}", " v1='{agt_name1}' {selected}", true);

        if (prgid.ToLower() == "brt52") {//交辦維護
            Lock["brt52"] = "Lock";
            Hide["brt52"] = "Hide";
        }
    }
</script>

<div id="div_Form_DI1">
<%=Sys.GetAscxPath(this.AppRelativeVirtualPath)%>
<TABLE border=0 class=bluetable cellspacing=1 cellpadding=2 width="100%">
	<tr>			
		<td class=lightbluetable align=right><strong>案件種類：</strong></td>
		<td class=whitetablebg colspan=7>
            <Select name="tfp3_case_stat" id="tfp3_case_stat" onchange="br_form.new_oldcaseB('tfp3',true)" class="<%#Lock.TryGet("brt52")%>">
			    <option value="NN">新案</option>
			    <option value="SN">新案(指定編號)</option>
            </Select>
		</TD>
	</tr>
	<tr >
		<td class="lightbluetable" align=right><strong>本所編號：</strong></td>
		<td class="whitetablebg" colspan="7">
            <span id="showseq_tfp3" style="display:none"><!--新案-->
			    <input type="text" size="<%=Sys.DmtSeq%>" MAXLENGTH=<%=Sys.DmtSeq%> name="tfp3_seq" id="tfp3_seq" readonly class="SEdit">-
                <%if(Lock.TryGet("brt52")!="Lock"){%>
			        <select name=tfp3_seq1 id=tfp3_seq1 onchange="br_form.seq1_conctrl()" class="<%#Lock.TryGet("brt52")%>">
				        <option value="_">一般</option>
				        <option value="M">M_大陸案</option>
			        </select>
                <%}else{%>
                    <INPUT TYPE=text NAME=tfp3_seq1 id=tfp3_seq1 SIZE=<%=Sys.DmtSeq1%> MAXLENGTH=<%=Sys.DmtSeq1%> style="text-transform:uppercase;" class="<%#Lock.TryGet("brt52")%>">	
                <%}%>
            </span>
            <span id="ShowNewAssign_tfp3" style="display:none">
			    <INPUT TYPE=text NAME=tfp3_New_Ass_seq id=tfp3_New_Ass_seq SIZE=<%=Sys.DmtSeq%> MAXLENGTH=<%=Sys.DmtSeq%> onblur="dmt_form.New_ass_seqB_blur('tfp3')" class="<%#Lock.TryGet("brt52")%>">-<INPUT TYPE=text NAME=tfp3_New_Ass_seq1 id=tfp3_New_Ass_seq1 SIZE=<%=Sys.DmtSeq1%> MAXLENGTH=<%=Sys.DmtSeq1%> value="" onblur="dmt_form.New_ass_seqB_blur('tfp3')" class="<%#Lock.TryGet("brt52")%>">	
            </span>
            <input type=button class="cbutton" name="Qry_step" id="Qry_step" value ="查詢案件進度" onclick="dmt_form.Qstepclick(reg.tfzb_seq.value, reg.tfzb_seq1.value)">
		</td>
	</tr>
	<tr>
		<td class="lightbluetable" valign="top" align=right><strong>※、代理人(代碼)</strong></td>
		<td class="whitetablebg" colspan="7" >
		    <select id="tfp3_agt_no" NAME="tfp3_agt_no" onchange="br_form.copycaseZZ('tfp3_agt_no')"><%#tfp3_agt_no%></select>
		</td>
	</tr>
	<tr>
		<td class="lightbluetable" colspan="8" valign="top" width="20%" STYLE="cursor:pointer;COLOR:BLUE" onclick="PMARK(o1Appl_name)">
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
			<input type="radio" id=fr3_class_typeI name=fr3_class_type class="onoff" value="int" onclick="reg.tfzr_class_typeI.checked = this.checked">國際分類
			<input type="radio" id=fr3_class_typeO name=fr3_class_type class="onoff" value="old" onclick="reg.tfzr_class_typeO.checked = this.checked">舊類
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
		<td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:pointer;COLOR:BLUE" onclick="PMARK(o1Rapcust)">
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
		<td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:pointer;COLOR:BLUE" onclick="PMARK(i1new_no)">
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
		<td class=lightbluetable align=right valign=top><input type="checkbox" id=ttg32_mod_pul_mod_type name=ttg32_mod_pul_mod_type value="I1"></td>
		<td class=whitetablebg colspan=7>註冊應予撤銷。</td>
	</tr>
	<tr>
		<td class=lightbluetable align=right valign=top><input type="checkbox" id=ttg33_mod_pul_mod_type name=ttg33_mod_pul_mod_type value="I2"></td>
		<td class=whitetablebg colspan=7>指定使用於商標法施行細則第<INPUT TYPE=text NAME=ttg33_mod_pul_new_no id=ttg33_mod_pul_new_no SIZE=3 MAXLENGTH=10>條第<INPUT TYPE=text NAME=ttg33_mod_pul_mod_dclass id=ttg33_mod_pul_mod_dclass SIZE=20 MAXLENGTH=20>類商品／服務之註冊應予撤銷。</td>
	</tr>
	<tr>
		<td class=lightbluetable align=right valign=top><input type="checkbox" id=ttg34_mod_pul_mod_type name=ttg34_mod_pul_mod_type value="I3"></td>
		<td class=whitetablebg colspan=7>指定使用於商標法施行細則第<INPUT TYPE=text NAME=ttg34_mod_pul_new_no id=ttg34_mod_pul_new_no SIZE=3 MAXLENGTH=10>條第<INPUT TYPE=text NAME=ttg34_mod_pul_mod_dclass id=ttg34_mod_pul_mod_dclass SIZE=3 MAXLENGTH=3>類<INPUT TYPE=text NAME=ttg34_mod_pul_ncname1 id=ttg34_mod_pul_ncname1 SIZE=30 MAXLENGTH=50>商品／服務之註冊應予撤銷。</td>
	</tr>
	<tr>
		<td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:pointer;COLOR:BLUE" onclick="PMARK(i1other_item1)"><strong>陸、<u>主張法條及據以評定商標/標章：</u></strong></td>
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
		<td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:pointer;COLOR:BLUE" onclick="PMARK(i1tran_remark1)"><strong>柒、<u>事實及理由：</u></strong></td>
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
		<td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:pointer;COLOR:BLUE" onclick="PMARK(zAttechD)"><strong>捌、<u>證據(附件)內容：</u></strong></td>
	</tr>
	<tr>
		<td class="lightbluetable" colspan="8" valign="top"><TEXTAREA rows=9 cols=90 id=tfz3_tran_remark2 name=tfz3_tran_remark2></TEXTAREA></td>
	</tr>
	<tr>
		<td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:pointer;COLOR:BLUE" onclick="PMARK(i1other_item)"><strong>玖、<u>相關聯案件：</u></strong></td>
	</tr>
	<TR>
		<TD class=lightbluetable align=right></TD>
		<TD class=whitetablebg colspan=7>
		本案與<input TYPE=text NAME=I_O_item1 id=I_O_item1 SIZE=10 MAXLENGTH=10 class="dateField">(年/月/日)註冊第<input type="text" id="I_O_item2" name="I_O_item2" SIZE=10>號<input type="text" id="I_O_item3" name="I_O_item3" SIZE=10>案有關
		<input type="text" name="tfz3_other_item" id="tfz3_other_item">
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
			<input type="button" class="cbutton" id="butUploadttg3_1" name="butUploadttg3_1"  value="商標圖檔上傳" onclick="br_form.UploadAttach_photo_mod('ttg3_mod_dmt_ncname1', 'ttg3_1', '-O1')" >
		    <input type="button" class="redbutton" name="btnDelAtt" value="商標圖檔刪除" onclick="br_form.DelAttach_photo_mod('ttg3_mod_dmt_ncname1','ttg3_1')" >
            <input type="button" class="cbutton" name="btnDisplay" value="商標圖檔檢視" onclick="br_form.PreviewAttach_photo_mod('ttg3_mod_dmt_ncname1','ttg3_1')" >
			<br>
		2.<input TYPE=text NAME=ttg3_mod_dmt_ncname2 id=ttg3_mod_dmt_ncname2 SIZE=50 MAXLENGTH=50 readonly>
			<input TYPE=hidden NAME=draw_attach_file_ttg3_2 id=draw_attach_file_ttg3_2 >
			<input TYPE=hidden NAME=old_file_ttg3_2 id=old_file_ttg3_2 >
			<input type="button" class="cbutton" id="butUploadttg3_2" name="butUploadttg3_2"  value="商標圖檔上傳" onclick="br_form.UploadAttach_photo_mod('ttg3_mod_dmt_ncname2', 'ttg3_2', '-O2')" >
		    <input type="button" class="redbutton" name="btnDelAtt" value="商標圖檔刪除" onclick="br_form.DelAttach_photo_mod('ttg3_mod_dmt_ncname2','ttg3_2')" >
            <input type="button" class="cbutton" name="btnDisplay" value="商標圖檔檢視" onclick="br_form.PreviewAttach_photo_mod('ttg3_mod_dmt_ncname2','ttg3_2')" >
			<br>
		3.<input TYPE=text NAME=ttg3_mod_dmt_nename1 id=ttg3_mod_dmt_nename1 SIZE=50 MAXLENGTH=50 readonly>
			<input TYPE=hidden NAME=draw_attach_file_ttg3_3 id=draw_attach_file_ttg3_3 >
			<input TYPE=hidden NAME=old_file_ttg3_3 id=old_file_ttg3_3 >
			<input type="button" class="cbutton" id="butUploadttg3_3" name="butUploadttg3_3"  value="商標圖檔上傳" onclick="br_form.UploadAttach_photo_mod('ttg3_mod_dmt_nename1', 'ttg3_3', '-O3')" >
		    <input type="button" class="redbutton" name="btnDelAtt" value="商標圖檔刪除" onclick="br_form.DelAttach_photo_mod('ttg3_mod_dmt_nename1','ttg3_3')" >
            <input type="button" class="cbutton" name="btnDisplay" value="商標圖檔檢視" onclick="br_form.PreviewAttach_photo_mod('ttg3_mod_dmt_nename1','ttg3_3')" >	
			<br>
		4.<input TYPE=text NAME=ttg3_mod_dmt_nename2 id=ttg3_mod_dmt_nename2 SIZE=50 MAXLENGTH=50 readonly>
			<input TYPE=hidden NAME=draw_attach_file_ttg3_4 id=draw_attach_file_ttg3_4 >
			<input TYPE=hidden NAME=old_file_ttg3_4 id=old_file_ttg3_4 >
			<input type="button" class="cbutton" id="butUploadttg3_4" name="butUploadttg3_4"  value="商標圖檔上傳" onclick="br_form.UploadAttach_photo_mod('ttg3_mod_dmt_nename2', 'ttg3_4', '-O4')" >
		    <input type="button" class="redbutton" name="btnDelAtt" value="商標圖檔刪除" onclick="br_form.DelAttach_photo_mod('ttg3_mod_dmt_nename2','ttg3_4')" >
            <input type="button" class="cbutton" name="btnDisplay" value="商標圖檔檢視" onclick="br_form.PreviewAttach_photo_mod('ttg3_mod_dmt_nename2','ttg3_4')" >
			<br>
		5.<input TYPE=text NAME=ttg3_mod_dmt_ncrep id=ttg3_mod_dmt_ncrep SIZE=50 MAXLENGTH=50 readonly>
			<input TYPE=hidden NAME=draw_attach_file_ttg3_5 id=draw_attach_file_ttg3_5 >
			<input TYPE=hidden NAME=old_file_ttg3_5 id=old_file_ttg3_5 >
			<input type="button" class="cbutton" id="butUploadttg3_5" name="butUploadttg3_5"  value="商標圖檔上傳" onclick="br_form.UploadAttach_photo_mod('ttg3_mod_dmt_ncrep', 'ttg3_5', '-O5')" >
		    <input type="button" class="redbutton" name="btnDelAtt" value="商標圖檔刪除" onclick="br_form.DelAttach_photo_mod('ttg3_mod_dmt_ncrep','ttg3_5')" >
            <input type="button" class="cbutton" name="btnDisplay" value="商標圖檔檢視" onclick="br_form.PreviewAttach_photo_mod('ttg3_mod_dmt_ncrep','ttg3_5')" >
			<br>			
		<span id="sp_ttg3_6" style="display:none">
		6.<input TYPE=text NAME=ttg3_mod_dmt_nerep id=ttg3_mod_dmt_nerep SIZE=50 MAXLENGTH=50 readonly>  
			<input TYPE=hidden NAME=draw_attach_file_ttg3_6 id=draw_attach_file_ttg3_6 >
			<input TYPE=hidden NAME=old_file_ttg3_6 id=old_file_ttg3_6 >
			<input type="button" class="cbutton" id="butUploadttg3_6" name="butUploadttg3_6"  value="商標圖檔上傳" onclick="br_form.UploadAttach_photo_mod('ttg3_mod_dmt_nerep', 'ttg3_6', '-O6')" >
		    <input type="button" class="redbutton" name="btnDelAtt" value="商標圖檔刪除" onclick="br_form.DelAttach_photo_mod('ttg3_mod_dmt_nerep','ttg3_6')" >
            <input type="button" class="cbutton" name="btnDisplay" value="商標圖檔檢視" onclick="br_form.PreviewAttach_photo_mod('ttg3_mod_dmt_nerep','ttg3_6')" >	
		<br>
		</span>
		<span id="sp_ttg3_7" style="display:none">
		7.<input TYPE=text NAME=ttg3_mod_dmt_neaddr1 id=ttg3_mod_dmt_neaddr1 SIZE=50 MAXLENGTH=50 readonly>  
			<input TYPE=hidden NAME=draw_attach_file_ttg3_7 id=draw_attach_file_ttg3_7 >
			<input TYPE=hidden NAME=old_file_ttg3_7 id=old_file_ttg3_7 >
			<input type="button" class="cbutton" id="butUploadttg3_7" name="butUploadttg3_7"  value="商標圖檔上傳" onclick="br_form.UploadAttach_photo_mod('ttg3_mod_dmt_neaddr1', 'ttg3_7', '-O7')" >
		    <input type="button" class="redbutton" name="btnDelAtt"  value="商標圖檔刪除" onclick="br_form.DelAttach_photo_mod('ttg3_mod_dmt_neaddr1','ttg3_7')" >
            <input type="button" class="cbutton" name="btnDisplay" value="商標圖檔檢視" onclick="br_form.PreviewAttach_photo_mod('ttg3_mod_dmt_neaddr1','ttg3_7')" >	
		<br>
		</span>
		<span id="sp_ttg3_8" style="display:none">
		8.<input TYPE=text NAME=ttg3_mod_dmt_neaddr2 id=ttg3_mod_dmt_neaddr2 SIZE=50 MAXLENGTH=50 readonly>  
			<input TYPE=hidden NAME=draw_attach_file_ttg3_8 id=draw_attach_file_ttg3_8 >
			<input TYPE=hidden NAME=old_file_ttg3_8 id=old_file_ttg3_8 >
			<input type="button" class="cbutton" id="butUploadttg3_8" name="butUploadttg3_8"  value="商標圖檔上傳" onclick="br_form.UploadAttach_photo_mod('ttg3_mod_dmt_neaddr2', 'ttg3_8', '-O8')" >
		    <input type="button" class="redbutton" name="btnDelAtt" value="商標圖檔刪除" onclick="br_form.DelAttach_photo_mod('ttg3_mod_dmt_neaddr2','ttg3_8')" >
            <input type="button" class="cbutton" name="btnDisplay" value="商標圖檔檢視" onclick="br_form.PreviewAttach_photo_mod('ttg3_mod_dmt_neaddr2','ttg3_8')" >	
		<br>
		</span>
		<span id="sp_ttg3_9" style="display:none">
		9.<input TYPE=text NAME=ttg3_mod_dmt_neaddr3 id=ttg3_mod_dmt_neaddr3 SIZE=50 MAXLENGTH=50 readonly>  
			<input TYPE=hidden NAME=draw_attach_file_ttg3_9 id=draw_attach_file_ttg3_9 >
			<input TYPE=hidden NAME=old_file_ttg3_9 id=old_file_ttg3_9 >
			<input type="button" class="cbutton" id="butUploadttg3_9" name="butUploadttg3_9"  value="商標圖檔上傳" onclick="br_form.UploadAttach_photo_mod('ttg3_mod_dmt_neaddr3', 'ttg3_9', '-O9')" >
		    <input type="button" class="redbutton" name="btnDelAtt"  value="商標圖檔刪除" onclick="br_form.DelAttach_photo_mod('ttg3_mod_dmt_neaddr3','ttg3_9')" >
            <input type="button" class="cbutton" name="btnDisplay" value="商標圖檔檢視" onclick="br_form.PreviewAttach_photo_mod('ttg3_mod_dmt_neaddr3','ttg3_9')" >	
		<br>
		</span>
		<span id="sp_ttg3_10" style="display:none">
		10.<input TYPE=text NAME=ttg3_mod_dmt_neaddr4 id=ttg3_mod_dmt_neaddr4 SIZE=50 MAXLENGTH=50 readonly>  
			<input TYPE=hidden NAME=draw_attach_file_ttg3_10 id=draw_attach_file_ttg3_10 >
			<input TYPE=hidden NAME=old_file_ttg3_10 id=old_file_ttg3_10 >
			<input type="button" class="cbutton" id="butUploadttg3_10" name="butUploadttg3_10"  value="商標圖檔上傳" onclick="br_form.UploadAttach_photo_mod('ttg3_mod_dmt_neaddr4', 'ttg3_10', '-O10')" >
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

        $("#fr3_class,#tfzr_class").val(pclass.join(','));
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
            //案件種類
            $("#tfp3_case_stat").val($("#tfy_case_stat").val());//.triggerHandler("change");
            br_form.new_oldcaseB('tfp3', false);
            $("#tfp3_seq").val("");
            $("#tfp3_seq1").val("_");
            $("#DI1_AP_Add_button").click();//註冊人預設顯示第1筆
            $("#ttg3_mod_aprep_mod_count").val("1").triggerHandler("change");//條款項目預設顯示第1筆
        } else {
            //案件種類
            $("#tfp1_case_stat").val($("#tfy_case_stat").val());//.triggerHandler("change");
            br_form.new_oldcaseB('tfp1', false);
            //本所編號
            if ($("#tfy_case_stat").val() == "NN") {
                $("#tfp3_seq").val(jMain.case_main[0].seq);
                $("#tfp3_seq1").val(jMain.case_main[0].seq1);
            } else if ($("#tfy_case_stat").val() == "SN") {
                $("#tfp3_New_Ass_seq").val(jMain.case_main[0].seq);
                $("#tfp3_New_Ass_seq1").val(jMain.case_main[0].seq1);
            }
            $("#tfp3_agt_no").val(jMain.case_main[0].agt_no);//代理人
            //商標種類
            $("input[name='fr3_S_Mark'][value='" + jMain.case_main[0].s_mark + "']").prop("checked", true);
            $("#fr3_issue_no").val(jMain.case_main[0].issue_no);//註冊號數
            $("#fr3_appl_name").val(jMain.case_main[0].appl_name);//商標名稱
            //擬評定之類別種類
            $("input[name='fr3_class_type'][value='" + jMain.case_main[0].class_type + "']").prop("checked", true);
            $("#fr3_class,#tfzr_class").val(jMain.case_main[0].class);//擬異議之類別
            $("#fr3_class_count,#tfzr_class_count").val(jMain.case_main[0].class_count);//共N類
            //商標/標章圖樣部份
            if (jMain.case_main[0].cappl_name == "C") {
                $("input[name='I_cappl_name']").prop("checked", true);
            }
            if (jMain.case_main[0].eappl_name == "E") {
                $("input[name='I_eappl_name']").prop("checked", true);
            }
            if (jMain.case_main[0].jappl_name == "J") {
                $("#tfzd_jappl_name").val(jMain.case_main[0].jappl_name);
                $("input[name='I_jappl_name']").prop("checked", true);
            }
            if (jMain.case_main[0].zappl_name1 == "Z") {
                $("#tfzd_zappl_name1").val(jMain.case_main[0].zappl_name1);
                $("input[name='I_zappl_name1']").prop("checked", true);
            }
            if (jMain.case_main[0].draw == "D") {
                $("input[name='I_draw']").prop("checked", true);
            }
            $("#I_remark3").val(jMain.case_main[0].remark3);
            $("#tfzd_remark3").val(jMain.case_main[0].remark3);
            if ($("#tfy_Arcase").val().Left(3) == "DI1") {
                //註冊人
                $.each(jMain.case_tranlist, function (i, item) {
                    if (item.mod_field == "mod_ap") {
                        //增加一筆
                        $("#DI1_AP_Add_button").click();
                        //填資料
                        var nRow = $("#DI1_apnum").val();
                        $("#ttg3_mod_ap_ncname1_" + nRow).val(item.ncname1);
                        $("#ttg3_mod_ap_ncname2_" + nRow).val(item.ncname2);
                        $("#ttg3_mod_ap_nzip_" + nRow).val(item.nzip);
                        $("#ttg3_mod_ap_naddr1_" + nRow).val(item.naddr1);
                        $("#ttg3_mod_ap_naddr2_" + nRow).val(item.naddr2);
                        $("#ttg3_mod_ap_ncrep_" + nRow).val(item.ncrep);
                    }
                });
                if (CInt($("#DI1_apnum").val()) == 0) {
                    alert("查無此交辦案件之被異議人資料!!");
                }
            }
            //評定聲明
            $.each(jMain.case_tranlist, function (i, item) {
                if (item.mod_field == "mod_pul") {
                    switch (item.mod_type) {
                        case "Tmark": case "Lmark":
                            $("input[name='ttg31_mod_pul_mod_type'][value='" + item.mod_type + "']").prop("checked", true);
                            $("#ttg31_mod_pul_new_no").val(item.new_no);
                            $("#ttg31_mod_pul_ncname1").val(item.ncname1);
                            break;
                        case "I1":
                            $("input[name='ttg32_mod_pul_mod_type']").prop("checked", true);
                            break;
                        case "I2":
                            $("input[name='ttg33_mod_pul_mod_type']").prop("checked", true);
                            $("#ttg33_mod_pul_new_no").val(item.new_no);
                            $("#ttg33_mod_pul_mod_dclass").val(item.mod_dclass);
                            break;
                        case "I3":
                            $("input[name='ttg34_mod_pul_mod_type']").prop("checked", true);
                            $("#ttg34_mod_pul_new_no").val(item.new_no);
                            $("#ttg34_mod_pul_mod_dclass").val(item.mod_dclass);
                            $("#ttg34_mod_pul_ncname1").val(item.ncname1);
                            break;
                    }
                }
            });
            //主張法條
            if (jMain.case_main[0].other_item1 != "") {
                var v = jMain.case_main[0].other_item1.split(";");
                if (v[0] != "") {
                    var I_item1 = v[0].split("|");
                    for (var i in I_item1) {
                        $("input[name='I_item1'][value='" + I_item1[i] + "']").prop("checked", true);
                    }
                }
                if (v[1] && v[1] != "") {
                    if (v[1].indexOf("|") > -1) {
                        var I_item2 = v[1].split("|");
                        $("#I_item2").val(I_item2[0]);
                        $("#I_item2t").val(I_item2[1]);
                    } else {
                        if ($("input[name='I_item1'][value='O']").prop("checked") == true) {
                            $("#I_item2t").val(v[1]);
                        } else {
                            $("#I_item2").val(v[1]);
                        }
                    }
                }
                $("#tfz3_other_item1").val(jMain.case_main[0].other_item1);
            }
            //主張條款/據以評定商標
            if (jMain.case_main[0].mod_aprep == "Y") {
                var tranlist = $(jMain.case_tranlist).filter(function (i, n) { return n.mod_field === 'mod_aprep' });
                if (tranlist.length > 0) {
                    $("#ttg3_mod_aprep_mod_count").val(tranlist[0].mod_count);
                    br_form.add_button_DI1(tranlist[0].mod_count);
                }
                $.each(tranlist, function (i, item) {
                    $("#ttg3_mod_aprep_ncname1_" + (i + 1)).val(item.ncname1);
                    $("#ttg3_mod_aprep_new_no_" + (i + 1)).val(item.new_no);
                });
            }
            $("#tfz3_tran_remark3").val(jMain.case_main[0].tran_remark3);//利害關係
            $("#tfz3_tran_remark1").val(jMain.case_main[0].tran_remark1);//事實及理由
            $("#tfz3_tran_remark4").val(jMain.case_main[0].tran_remark4);//註冊已滿3年使用說明
            $("#tfz3_tran_remark2").val(jMain.case_main[0].tran_remark2);//證據內容
            //**相關聯案件
            $("#tfz3_other_item").val(jMain.case_main[0].other_item);
            if (jMain.case_main[0].other_item != "") {
                var v = jMain.case_main[0].other_item.split(";");
                if ($.isDate(v[0])) $("#I_O_item1").val(v[0]);
                $("#I_O_item2").val(v[1]);
                $("#I_O_item3").val(v[2]);
            }
            //評定標的圖樣
            $("#tfp3_file").val(jMain.case_main[0].draw_file);//*圖檔實際路徑-for編修時記錄原檔名-2013/11/26增加
            $("#tfp3_draw_file").val(jMain.case_main[0].draw_file);//*圖檔實際路徑-for編修時記錄原檔名-2013/11/26增加
            if ($("#tfp3_file").val() != "") {
                $("#butUploadtfp3").prop("disabled", true);
            }

            //據以異議商標圖樣
            if (jMain.case_main[0].mod_dmt == "Y") {
                var tranlist = $(jMain.case_tranlist).filter(function (i, n) { return n.mod_field === 'mod_dmt' });
                if (tranlist.length > 0) {
                    $("#ttg3_mod_dmt_ncname1,#draw_attach_file_ttg3_1,#old_file_ttg3_1").val(tranlist[0].ncname1);
                    if ($("#ttg3_mod_dmt_ncname1").val() != "") {
                        $("#butUploadttg3_1").prop("disabled", true);
                    }
                    $("#ttg3_mod_dmt_ncname2,#draw_attach_file_ttg3_2,#old_file_ttg3_2").val(tranlist[0].ncname2);
                    if ($("#ttg3_mod_dmt_ncname2").val() != "") {
                        $("#butUploadttg3_2").prop("disabled", true);
                    }
                    $("#ttg3_mod_dmt_nename1,#draw_attach_file_ttg3_3,#old_file_ttg3_3").val(tranlist[0].nename1);
                    if ($("#ttg3_mod_dmt_nename1").val() != "") {
                        $("#butUploadttg3_3").prop("disabled", true);
                    }
                    $("#ttg3_mod_dmt_nename2,#draw_attach_file_ttg3_4,#old_file_ttg3_4").val(tranlist[0].nename2);
                    if ($("#ttg3_mod_dmt_nename2").val() != "") {
                        $("#butUploadttg3_4").prop("disabled", true);
                    }
                    $("#ttg3_mod_dmt_ncrep,#draw_attach_file_ttg3_5,#old_file_ttg3_5").val(tranlist[0].ncrep);
                    if ($("#ttg3_mod_dmt_ncrep").val() != "") {
                        $("#butUploadttg3_5").prop("disabled", true);
                    }
                    $("#ttg3_mod_dmt_nerep,#draw_attach_file_ttg3_6,#old_file_ttg3_6").val(tranlist[0].nerep);
                    if ($("#ttg3_mod_dmt_nerep").val() != "") {
                        $("#draw_num_ttg3").val("6");
                        $("#sp_ttg3_6").show();
                        $("#butUploadttg3_6").prop("disabled", true);
                    }
                    $("#ttg3_mod_dmt_neaddr1,#draw_attach_file_ttg3_7,#old_file_ttg3_7").val(tranlist[0].neaddr1);
                    if ($("#ttg3_mod_dmt_neaddr1").val() != "") {
                        $("#draw_num_ttg3").val("7");
                        $("#sp_ttg3_7").show();
                        $("#butUploadttg3_7").prop("disabled", true);
                    }
                    $("#ttg3_mod_dmt_neaddr2,#draw_attach_file_ttg3_8,#old_file_ttg3_8").val(tranlist[0].neaddr2);
                    if ($("#ttg3_mod_dmt_neaddr2").val() != "") {
                        $("#draw_num_ttg3").val("8");
                        $("#sp_ttg3_8").show();
                        $("#butUploadttg3_8").prop("disabled", true);
                    }
                    $("#ttg3_mod_dmt_neaddr3,#draw_attach_file_ttg3_9,#old_file_ttg3_9").val(tranlist[0].neaddr3);
                    if ($("#ttg3_mod_dmt_neaddr3").val() != "") {
                        $("#draw_num_ttg3").val("9");
                        $("#sp_ttg3_9").show();
                        $("#butUploadttg3_9").prop("disabled", true);
                    }
                    $("#ttg3_mod_dmt_neaddr4,#draw_attach_file_ttg3_10,#old_file_ttg3_10").val(tranlist[0].neaddr4);
                    if ($("#ttg3_mod_dmt_neaddr4").val() != "") {
                        $("#draw_num_ttg3").val("10");
                        $("#sp_ttg3_10").show();
                        $("#butUploadttg3_10").prop("disabled", true);
                    }
                }
            }
        }
    }
</script>
