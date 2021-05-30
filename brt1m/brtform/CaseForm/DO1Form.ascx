<%@ Control Language="C#" ClassName="DO1Form" %>
<%@ Import Namespace = "System.Collections.Generic"%>

<script runat="server">
    //B爭議案交辦內容
    //父控制項傳入的參數
    public Dictionary<string, string> Lock = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    public Dictionary<string, string> Hide = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    public int HTProgRight = 0;

    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected string SQL = "";

    protected string tfp2_agt_no = "";
    
    private void Page_Load(System.Object sender, System.EventArgs e) {
        PageLayout();   
        this.DataBind();
    }
    
    private void PageLayout() {
        //代理人
        tfp2_agt_no = Sys.getAgent().Option("{agt_no}", "{agt_no}_{agt_namefull}", " v1='{agt_name1}' {selected}", true);

        if (prgid.ToLower() == "brt52") {//交辦維護
            Lock["brt52"] = "Lock";
            Hide["brt52"] = "Hide";
        }
    }
</script>

<div id="div_Form_DO1">
<%=Sys.GetAscxPath(this.AppRelativeVirtualPath)%>
<TABLE border=0 class=bluetable cellspacing=1 cellpadding=2 width="100%">
	<tr>			
		<td class=lightbluetable align=right><strong>案件種類：</strong></td>
		<td class=whitetablebg colspan=7>
            <Select name="tfp2_case_stat" id="tfp2_case_stat" onchange="br_form.new_oldcaseB('tfp2',true)" class="<%#Lock.TryGet("brt52")%>">
			    <option value="NN">新案</option>
			    <option value="SN">新案(指定編號)</option>
            </Select>
		</TD>
	</tr>
	<tr  >
		<td class="lightbluetable" align=right><strong>本所編號：</strong></td>
		<td class="whitetablebg" colspan="7">
            <span id="showseq_tfp2" style="display:none"><!--新案-->
			    <input type="text" size="<%=Sys.DmtSeq%>" MAXLENGTH=<%=Sys.DmtSeq%> name="tfp2_seq" id="tfp2_seq" readonly class="SEdit">-
                <%if(Lock.TryGet("brt52")!="Lock"){%>
			        <select name=tfp2_seq1 id=tfp2_seq1 onchange="br_form.seq1_conctrl()" class="<%#Lock.TryGet("brt52")%>">
				        <option value="_">一般</option>
				        <option value="M">M_大陸案</option>
			        </select>
                <%}else{%>
                    <INPUT TYPE=text NAME=tfp2_seq1 id=tfp2_seq1 SIZE=<%=Sys.DmtSeq1%> MAXLENGTH=<%=Sys.DmtSeq1%> style="text-transform:uppercase;" class="<%#Lock.TryGet("brt52")%>">	
                <%}%>
            </span>
            <span id="ShowNewAssign_tfp2" style="display:none"><!--新案(指定編號)-->
			    <INPUT TYPE=text NAME=tfp2_New_Ass_seq id=tfp2_New_Ass_seq SIZE=<%=Sys.DmtSeq%> MAXLENGTH=<%=Sys.DmtSeq%> onblur="dmt_form.New_ass_seqB_blur('tfp2')" class="<%#Lock.TryGet("brt52")%>">-<INPUT TYPE=text NAME=tfp2_New_Ass_seq1 id=tfp2_New_Ass_seq1 SIZE=<%=Sys.DmtSeq1%> MAXLENGTH=<%=Sys.DmtSeq1%> value="" onblur="dmt_form.New_ass_seqB_blur('tfp2')" class="<%#Lock.TryGet("brt52")%>">	
            </span>
            <input type=button class="cbutton" name="Qry_step" id="Qry_step" value ="查詢案件進度" onclick="dmt_form.Qstepclick(reg.tfzb_seq.value, reg.tfzb_seq1.value)">
		</td>
	</tr>	
	<tr>
		<td class="lightbluetable" valign="top" align=right><strong>※、代理人</strong></td>
		<td class="whitetablebg" colspan="7" >
		    <select id="tfp2_agt_no" NAME="tfp2_agt_no" onchange="br_form.copycaseZZ('tfp2_agt_no')"><%#tfp2_agt_no%></select>
		</td>
	</tr>
	<tr>
		<td class="lightbluetable" colspan="8" valign="top" width="20%" STYLE="cursor:pointer;COLOR:BLUE" onclick="PMARK(o1Appl_name)">
            <strong>壹、<u>異議標的(你要異議的標章)</u></strong>
        </td>
	</tr>
	<tr>
		<td class=lightbluetable align=right >商標種類：</td>
		<td class=whitetablebg colspan="7">
			<input type=radio name=fr2_S_Mark class="onoff" value="" onclick="dmt_form.change_mark(1, this)">商標
			<input type=radio name=fr2_S_Mark class="onoff" value="S" onclick="dmt_form.change_mark(1, this)">92年修正前服務標章
			<input type=radio name=fr2_S_Mark class="onoff" value="N" onclick="dmt_form.change_mark(1, this)">團體商標
			<input type=radio name=fr2_S_Mark class="onoff" value="M" onclick="dmt_form.change_mark(1, this)">團體標章
			<input type=radio name=fr2_S_Mark class="onoff" value="L" onclick="dmt_form.change_mark(1, this)">證明標章
		</TD>
	</tr>
	<tr>
		<td class=lightbluetable align=right >註冊號數：</td>
		<td class=whitetablebg colspan="3">
			<input type="text" id="fr2_issue_no" name="fr2_issue_no" class="onoff" value="" size="20" maxlength="20" >
		</TD>
		<td class=lightbluetable align=right width="18%">商標/標章名稱：</td>
		<td class=whitetablebg colspan="3">
			<input type="text" id="fr2_appl_name" name="fr2_appl_name" class="onoff" value="" size="30" maxlength="100" onchange="reg.tfzd_appl_name.value=this.value">
		</TD>
	</tr>
	<tr>
		<td class=lightbluetable align=right >擬異議之類別種類：</td>
		<td class=whitetablebg colspan="3">
			<input type="radio" id=fr2_class_typeI name=fr2_class_type class="onoff" value="int" onclick="reg.tfzr_class_typeI.checked = this.checked">國際分類
			<input type="radio" id=fr2_class_typeO name=fr2_class_type class="onoff" value="old" onclick="reg.tfzr_class_typeO.checked = this.checked">舊類
		</TD>
		<td class=lightbluetable align=right width="18%" STYLE="cursor:pointer;COLOR:BLUE" title="請輸入類別，並以逗號分開(例如：001,005,032)。">擬異議之類別：</td>
		<td class=whitetablebg colspan="3">
			<input type="text" id="fr2_class" name="fr2_class" value="" size="30" maxlength="100" onchange="br_form.count_kind_DO1()">，
			共<input type="text" id="fr2_class_count" name="fr2_class_count" value="" size=3 readonly class="SEdit" >類(異議案依類別計算，請填具正確類別)
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
            <input type="checkbox" name=O_cappl_name value="C">中文
            <input type="checkbox" name=O_eappl_name value="E">英文
            <input type="checkbox" name=O_jappl_name value="J">日文
            <input type="checkbox" name=O_draw value="D">圖形
            <input type="checkbox" name=O_zappl_name1 value="Z">其他（非英文或日文之外國文字、顏色、聲音、立體形狀等）
		    <!--<input type="hidden" id="tfzd_cappl_name" name="tfzd_cappl_name" >
		    <input type="hidden" id="tfzd_eappl_name" name="tfzd_eappl_name" >
		    <input type="hidden" id="tfzd_draw" name="tfzd_draw" >-->
		    <input type="hidden" id="tfzd_jappl_name" name="tfzd_jappl_name" >
		    <input type="hidden" id="tfzd_zappl_name1" name="tfzd_zappl_name1" >
		</td>
	</tr>
	<tr>
		<td class=lightbluetable align=right></td>
		<td class=whitetablebg colspan=7>
            <INPUT TYPE=text NAME=O_remark3 id=O_remark3 SIZE=30 MAXLENGTH=50>
		</td>
	</tr>
	<tr>
		<td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:pointer;COLOR:BLUE" onclick="PMARK(o1Rapcust)">
            <strong>肆、<u>被異議人：</u></strong>
		</td>
	</tr>
	<tr >
		<td colspan="8" class='sfont9'>
		<input type=hidden id=DO1_apnum name=DO1_apnum value=0><!--進度筆數-->
		<table border="0" id=DO1_tabap class="bluetable" cellspacing="1" cellpadding="1" width="100%">
        <thead>
		    <TR>
			    <TD  class=whitetablebg colspan=2 align=right>
				    <input type=button value ="增加一筆被異議人" class="cbutton" id=DO1_AP_Add_button name=DO1_AP_Add_button>
				    <input type=button value ="減少一筆被異議人" class="cbutton" id=DO1_AP_Del_button name=DO1_AP_Del_button>
			    </TD>
		    </TR>
        </thead>
        <tbody></tbody>
        <script type="text/html" id="do1_ap_template">
	        <TR>
		        <TD class=lightbluetable align=right>
			        <input type=text id='DO1_apnum_##' name='DO1_apnum_##' class=SEdit readonly style='color:black;' size=2 value='##.'>名稱或姓名：
		        </TD>
		        <TD class=whitetablebg>
		            <input TYPE=text NAME=ttg2_mod_ap_ncname1_## id=ttg2_mod_ap_ncname1_## SIZE=60 MAXLENGTH=100 alt='『被異議人名稱或姓名』' onblur='fDataLen(this)'><br>
		            <input TYPE=text NAME=ttg2_mod_ap_ncname2_## id=ttg2_mod_ap_ncname2_## SIZE=60 MAXLENGTH=100 alt='『被異議人名稱或姓名』' onblur='fDataLen(this)'>
		        </TD>
	        </TR>
	        <TR>
		        <TD class=lightbluetable align=right>
			        地　　　址：
		        </TD>
		        <TD class=whitetablebg>
		            <input TYPE=text NAME=ttg2_mod_ap_nzip_## id=ttg2_mod_ap_nzip_## SIZE=8 MAXLENGTH=8 alt='『被異議人郵遞區號』' onblur='fDataLen(this)'>
		            <input TYPE=text NAME=ttg2_mod_ap_naddr1_## id=ttg2_mod_ap_naddr1_## SIZE=30 MAXLENGTH=60 alt='『被異議人地址』' onblur='fDataLen(this)'>
		            <input TYPE=text NAME=ttg2_mod_ap_naddr2_## id=ttg2_mod_ap_naddr2_## SIZE=30 MAXLENGTH=60 alt='『被異議人地址』' onblur='fDataLen(this)'>
		        </TD>
	        </TR>
	        <TR>
		        <TD class=lightbluetable align=right>
			        代理人姓名：
		        </TD>
		        <TD class=whitetablebg>
		            <input TYPE=text NAME=ttg2_mod_ap_ncrep_## id=ttg2_mod_ap_ncrep_## SIZE=20 MAXLENGTH=20 alt='『被異議代理人』' onblur='fDataLen(this)'>
		        </TD>
	        </TR>
        </script>
		</table>
		</td>
	</tr>
	<tr>
		<td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:pointer;COLOR:BLUE" onclick="PMARK(o1new_no)">
            <strong>伍、<u>異議聲明：</u></strong>
		</td>
	</tr>
	<tr>
		<td class=lightbluetable align=right valign=top></td>
		<td class=whitetablebg colspan=7>第<INPUT TYPE=text NAME=ttg21_mod_pul_new_no id=ttg21_mod_pul_new_no SIZE=10 MAXLENGTH=10>號「<INPUT TYPE=text NAME=ttg21_mod_pul_ncname1 id=ttg21_mod_pul_ncname1 SIZE=30 MAXLENGTH=50>」
            <input type="radio" name="ttg21_mod_pul_mod_type" value="Tmark">商標
            <input type="radio" name="ttg21_mod_pul_mod_type" value="Lmark">標章
		</td>
	</tr>
	<tr>
		<td class=lightbluetable align=right valign=top><input type="checkbox" id=ttg22_mod_pul_mod_type name=ttg22_mod_pul_mod_type value="O1"></td>
		<td class=whitetablebg colspan=7>註冊應予撤銷。</td>
	</tr>
	<tr>
		<td class=lightbluetable align=right valign=top><input type="checkbox" id=ttg23_mod_pul_mod_type name=ttg23_mod_pul_mod_type value="O2"></td>
		<td class=whitetablebg colspan=7>指定使用於商標法施行細則第<INPUT TYPE=text NAME=ttg23_mod_pul_new_no id=ttg23_mod_pul_new_no SIZE=3 MAXLENGTH=10>條第<INPUT TYPE=text NAME=ttg23_mod_pul_mod_dclass id=ttg23_mod_pul_mod_dclass SIZE=20 MAXLENGTH=20>類商品／服務之註冊應予撤銷。</td>
	</tr>
	<tr>
		<td class=lightbluetable align=right valign=top><input type="checkbox" id=ttg24_mod_pul_mod_type name=ttg24_mod_pul_mod_type value="O3"></td>
		<td class=whitetablebg colspan=7>指定使用於商標法施行細則第<INPUT TYPE=text NAME=ttg24_mod_pul_new_no id=ttg24_mod_pul_new_no SIZE=3 MAXLENGTH=10>條第<INPUT TYPE=text NAME=ttg24_mod_pul_mod_dclass id=ttg24_mod_pul_mod_dclass SIZE=3 MAXLENGTH=3>類<br><INPUT TYPE=text NAME=ttg24_mod_pul_ncname1 id=ttg24_mod_pul_ncname1 SIZE=170 MAXLENGTH=200><br>商品／服務之註冊應予撤銷。</td>
	</tr>
	<tr>
		<td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:pointer;COLOR:BLUE" onclick="PMARK(o1Other_item1)"><strong>陸、<u>主張法條及據以異議商標/標章：</u></strong></td>
	</tr>
	<tr>
		<td class="lightbluetable" valign="top">一、主張法條：</td>
		<td class=whitetablebg colspan="7" valign="top">商標法<input TYPE=text NAME=tfz2_other_item1 id=tfz2_other_item1 SIZE=50 MAXLENGTH=50 value="第  條第  項第  款"></td>
	</tr>
	<tr>
		<td class="lightbluetable" valign="top" colspan="8" >
            <strong>二、據以異議商標/標章：</strong>（你認為被異議商標/標章和那些商標/標章相衝突，請按照主張條款分別詳細列出，有號數者請務必依序填寫，以免延宕本案之審理）
		</td>
	</tr>
	<tr>
		<td colspan=8 class='sfont9'>
		    <TABLE id=tabbr21 style="display:" border=0 class="bluetable"  cellspacing=1 cellpadding=2 width="100%">
            <thead>
		    <tr>	
			    <td class="lightbluetable" align="right" width="18%">條款項目：</td>
			    <td class="whitetablebg" colspan="7" >共<input type="text" id=ttg2_mod_aprep_mod_count name=ttg2_mod_aprep_mod_count size=2 onchange=br_form.add_button_DO1(this.value)>項
				    <input type=hidden id=count21 name=count21 value="0">
				    <input type=hidden id=ctrlcnt21 name=ctrlcnt21 value="">
				    <input type=hidden id=cnt21 name=cnt21 value="0"><!--畫面上有幾筆-->
			    </td>
		    </tr>
            </thead>
            <tbody></tbody>
            <script type="text/html" id="do1_aprep_template">
		        <tr class="tr_do1_aprep_##">	
			        <td class="lightbluetable" align="right">主張條款##：</td>
			        <td class="whitetablebg" colspan="7" ><input type="text" id=ttg2_mod_aprep_ncname1_## name=ttg2_mod_aprep_ncname1_## size=20  maxlength=20></td>
		        </tr>
		        <tr class="tr_do1_aprep_##">	
			        <td class="lightbluetable" align="right">據以異議商標號數##：</td>
			        <td class="whitetablebg" colspan="7"><input type="text" id=ttg2_mod_aprep_new_no_## name=ttg2_mod_aprep_new_no_## size=60 maxlength=80></td>
		        </tr>
            </script>
		    </table>
		</td>
	</tr>
	<tr>
		<td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:pointer;COLOR:BLUE" onclick="PMARK(o1tran_remark1)"><strong>柒、<u>事實及理由：</u></strong></td>
	</tr>
	<tr>
		<td class="whitetablebg" colspan="8" valign="top"><TEXTAREA rows=9 cols=90 id=tfz2_tran_remark1 name=tfz2_tran_remark1></TEXTAREA></td>
	</tr>
	<tr>
		<td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:pointer;COLOR:BLUE" onclick="PMARK(zAttechD)"><strong>捌、<u>證據(附件)內容：</u></strong></td>
	</tr>
	<tr>
		<td class="whitetablebg" colspan="8" valign="top"><TEXTAREA rows=9 cols=90 id=tfz2_tran_remark2 name=tfz2_tran_remark2></TEXTAREA></td>
	</tr>
	<tr>
		<td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:pointer;COLOR:BLUE" onclick="PMARK(o1Other_item)"><strong>玖、<u>相關聯案件：</u></strong></td>
	</tr>
	<TR>
		<TD class=lightbluetable align=right></TD>
		<TD class=whitetablebg colspan=7>本案與<input TYPE=text NAME=O_O_item1 id=O_O_item1 SIZE=10 MAXLENGTH=10 class="dateField">(年/月/日)註冊第<input type="text" id="O_O_item2" name="O_O_item2" SIZE=10>號<input type="text" id="O_O_item3" name="O_O_item3" SIZE=10>案有關
		<input type="text" id="tfz2_other_item" name="tfz2_other_item">
		</TD>
	</TR>
	<tr>
		<td class="lightbluetable" colspan="8" valign="top"><strong>※異議商標及據以異議商標圖樣：</strong></td>
	</tr>
	<TR>
		<TD class=lightbluetable>一、異議標的圖樣：</TD>
		<TD class=whitetablebg colspan=7>
		<input TYPE=text NAME=tfp2_draw_file id=tfp2_draw_file SIZE=50 MAXLENGTH=50 readonly>
		<input TYPE=hidden NAME=tfp2_file id=tfp2_file >
		<input type="button" class="cbutton" id="butUploadtfp2" name="butUploadtfp2"  value="商標圖檔上傳" onclick="dmt_form.UploadAttach_photo('tfp2')" >
		<input type="button" class="redbutton" id="btnDelAtt" name="btnDelAtt"  value="商標圖檔刪除" onclick="dmt_form.DelAttach_photo('tfp2')" >
        <input type="button" class="cbutton" id="btnDisplay" name="btnDisplay" value="商標圖檔檢視" onclick="dmt_form.PreviewAttach_photo('tfp2')" >
		</TD>
	</TR>	
	<TR>
		<TD class=lightbluetable align=right>二、據以異議商標圖樣：</TD>
		<TD class=whitetablebg colspan=7>
            <input type="button" class="cbutton" id="butadd_draw" name="butadd_draw" value="增加一筆商標圖檔" onclick="br_form.drawadd('ttg2')">
            <input type="hidden" name="draw_num_ttg2" id="draw_num_ttg2" value=5><!--預設5，因畫面直接顯示5筆，若有6筆以上，edit再給值-->
            <br>
		1.<input TYPE=text NAME=ttg2_mod_dmt_ncname1 id=ttg2_mod_dmt_ncname1 SIZE=50 MAXLENGTH=50 readonly>
			<input TYPE=hidden NAME=draw_attach_file_ttg2_1 id=draw_attach_file_ttg2_1 >
			<input TYPE=hidden NAME=old_file_ttg2_1 id=old_file_ttg2_1 >
			<input type="button" class="cbutton" id="butUploadttg2_1" name="butUploadttg2_1" value="商標圖檔上傳" onclick="br_form.UploadAttach_photo_mod('ttg2_mod_dmt_ncname1','ttg2_1','-O1')" >
		    <input type="button" class="redbutton" name="btnDelAtt" value="商標圖檔刪除" onclick="br_form.DelAttach_photo_mod('ttg2_mod_dmt_ncname1','ttg2_1')" >
            <input type="button" class="cbutton" name="btnDisplay" value="商標圖檔檢視" onclick="br_form.PreviewAttach_photo_mod('ttg2_mod_dmt_ncname1','ttg2_1')" >
		<br>
		2.<input TYPE=text NAME=ttg2_mod_dmt_ncname2 id=ttg2_mod_dmt_ncname2 SIZE=50 MAXLENGTH=50 readonly>
			<input TYPE=hidden NAME=draw_attach_file_ttg2_2 id=draw_attach_file_ttg2_2 >
			<input TYPE=hidden NAME=old_file_ttg2_2 id=old_file_ttg2_2 >
			<input type="button" class="cbutton" id="butUploadttg2_2" name="butUploadttg2_2" value="商標圖檔上傳" onclick="br_form.UploadAttach_photo_mod('ttg2_mod_dmt_ncname2', 'ttg2_2', '-O2')" >
		    <input type="button" class="redbutton" name="btnDelAtt" value="商標圖檔刪除" onclick="br_form.DelAttach_photo_mod('ttg2_mod_dmt_ncname2','ttg2_2')" >
            <input type="button" class="cbutton" name="btnDisplay" value="商標圖檔檢視" onclick="br_form.PreviewAttach_photo_mod('ttg2_mod_dmt_ncname2','ttg2_2')" >
		<br>
		3.<input TYPE=text NAME=ttg2_mod_dmt_nename1 id=ttg2_mod_dmt_nename1 SIZE=50 MAXLENGTH=50 readonly>
			<input TYPE=hidden NAME=draw_attach_file_ttg2_3 id=draw_attach_file_ttg2_3 >
			<input TYPE=hidden NAME=old_file_ttg2_3 id=old_file_ttg2_3 >
			<input type="button" class="cbutton" id="butUploadttg2_3" name="butUploadttg2_3" value="商標圖檔上傳" onclick="br_form.UploadAttach_photo_mod('ttg2_mod_dmt_nename1', 'ttg2_3', '-O3')" >
		    <input type="button" class="redbutton" name="btnDelAtt" value="商標圖檔刪除" onclick="br_form.DelAttach_photo_mod('ttg2_mod_dmt_nename1','ttg2_3')" >
            <input type="button" class="cbutton" name="btnDisplay" value="商標圖檔檢視" onclick="br_form.PreviewAttach_photo_mod('ttg2_mod_dmt_nename1','ttg2_3')" >
		<br>
		4.<input TYPE=text NAME=ttg2_mod_dmt_nename2 id=ttg2_mod_dmt_nename2 SIZE=50 MAXLENGTH=50 readonly>
			<input TYPE=hidden NAME=draw_attach_file_ttg2_4 id=draw_attach_file_ttg2_4 >
			<input TYPE=hidden NAME=old_file_ttg2_4 id=old_file_ttg2_4 >
			<input type="button" class="cbutton" id="butUploadttg2_4" name="butUploadttg2_4" value="商標圖檔上傳" onclick="br_form.UploadAttach_photo_mod('ttg2_mod_dmt_nename2', 'ttg2_4', '-O4')" >
		    <input type="button" class="redbutton" name="btnDelAtt" value="商標圖檔刪除" onclick="br_form.DelAttach_photo_mod('ttg2_mod_dmt_nename2','ttg2_4')" >
            <input type="button" class="cbutton" name="btnDisplay" value="商標圖檔檢視" onclick="br_form.PreviewAttach_photo_mod('ttg2_mod_dmt_nename2','ttg2_4')" >	
		<br>
		5.<input TYPE=text NAME=ttg2_mod_dmt_ncrep id=ttg2_mod_dmt_ncrep SIZE=50 MAXLENGTH=50 readonly>
			<input TYPE=hidden NAME=draw_attach_file_ttg2_5 id=draw_attach_file_ttg2_5 >
			<input TYPE=hidden NAME=old_file_ttg2_5 id=old_file_ttg2_5 >
			<input type="button" class="cbutton" id="butUploadttg2_5" name="butUploadttg2_5" value="商標圖檔上傳" onclick="br_form.UploadAttach_photo_mod('ttg2_mod_dmt_ncrep', 'ttg2_5', '-O5')" >
		    <input type="button" class="redbutton" name="btnDelAtt" value="商標圖檔刪除" onclick="br_form.DelAttach_photo_mod('ttg2_mod_dmt_ncrep','ttg2_5')" >
            <input type="button" class="cbutton" name="btnDisplay" value="商標圖檔檢視" onclick="br_form.PreviewAttach_photo_mod('ttg2_mod_dmt_ncrep','ttg2_5')" >	
		<br>
		<span id="sp_ttg2_6" style="display:none">
		6.<input TYPE=text NAME=ttg2_mod_dmt_nerep id=ttg2_mod_dmt_nerep SIZE=50 MAXLENGTH=50 readonly>  
			<input TYPE=hidden NAME=draw_attach_file_ttg2_6 id=draw_attach_file_ttg2_6 >
			<input TYPE=hidden NAME=old_file_ttg2_6 id=old_file_ttg2_6 >
			<input type="button" class="cbutton" id="butUploadttg2_6" name="butUploadttg2_6" value="商標圖檔上傳" onclick="br_form.UploadAttach_photo_mod('ttg2_mod_dmt_nerep', 'ttg2_6', '-O6')" >
		    <input type="button" class="redbutton" name="btnDelAtt" value="商標圖檔刪除" onclick="br_form.DelAttach_photo_mod('ttg2_mod_dmt_nerep','ttg2_6')" >
            <input type="button" class="cbutton" name="btnDisplay" value="商標圖檔檢視" onclick="br_form.PreviewAttach_photo_mod('ttg2_mod_dmt_nerep','ttg2_6')" >	
		<br>
		</span>
		<span id="sp_ttg2_7" style="display:none">
		7.<input TYPE=text NAME=ttg2_mod_dmt_neaddr1 id=ttg2_mod_dmt_neaddr1 SIZE=50 MAXLENGTH=50 readonly>  
			<input TYPE=hidden NAME=draw_attach_file_ttg2_7 id=draw_attach_file_ttg2_7 >
			<input TYPE=hidden NAME=old_file_ttg2_7 id=old_file_ttg2_7 >
			<input type="button" class="cbutton" id="butUploadttg2_7" name="butUploadttg2_7" value="商標圖檔上傳" onclick="br_form.UploadAttach_photo_mod('ttg2_mod_dmt_neaddr1', 'ttg2_7', '-O7')" >
		    <input type="button" class="redbutton" name="btnDelAtt" value="商標圖檔刪除" onclick="br_form.DelAttach_photo_mod('ttg2_mod_dmt_neaddr1','ttg2_7')" >
            <input type="button" class="cbutton" name="btnDisplay" value="商標圖檔檢視" onclick="br_form.PreviewAttach_photo_mod('ttg2_mod_dmt_neaddr1','ttg2_7')" >	
		<br>
		</span>
		<span id="sp_ttg2_8" style="display:none">
		8.<input TYPE=text NAME=ttg2_mod_dmt_neaddr2 id=ttg2_mod_dmt_neaddr2 SIZE=50 MAXLENGTH=50 readonly>  
			<input TYPE=hidden NAME=draw_attach_file_ttg2_8 id=draw_attach_file_ttg2_8 >
			<input TYPE=hidden NAME=old_file_ttg2_8 id=old_file_ttg2_8 >
			<input type="button" class="cbutton" id="butUploadttg2_8" name="butUploadttg2_8" value="商標圖檔上傳" onclick="br_form.UploadAttach_photo_mod('ttg2_mod_dmt_neaddr2', 'ttg2_8', '-O8')" >
		    <input type="button" class="redbutton" name="btnDelAtt" value="商標圖檔刪除" onclick="br_form.DelAttach_photo_mod('ttg2_mod_dmt_neaddr2','ttg2_8')" >
            <input type="button" class="cbutton" name="btnDisplay" value="商標圖檔檢視" onclick="br_form.PreviewAttach_photo_mod('ttg2_mod_dmt_neaddr2','ttg2_8')" >	
		<br>
		</span>
		<span id="sp_ttg2_9" style="display:none">
		9.<input TYPE=text NAME=ttg2_mod_dmt_neaddr3 id=ttg2_mod_dmt_neaddr3 SIZE=50 MAXLENGTH=50 readonly>  
			<input TYPE=hidden NAME=draw_attach_file_ttg2_9 id=draw_attach_file_ttg2_9 >
			<input TYPE=hidden NAME=old_file_ttg2_9 id=old_file_ttg2_9 >
			<input type="button" class="cbutton" id="butUploadttg2_9" name="butUploadttg2_9" value="商標圖檔上傳" onclick="br_form.UploadAttach_photo_mod('ttg2_mod_dmt_neaddr3', 'ttg2_9', '-O9')" >
		    <input type="button" class="redbutton" name="btnDelAtt" value="商標圖檔刪除" onclick="br_form.DelAttach_photo_mod('ttg2_mod_dmt_neaddr3','ttg2_9')" >
            <input type="button" class="cbutton" name="btnDisplay" value="商標圖檔檢視" onclick="br_form.PreviewAttach_photo_mod('ttg2_mod_dmt_neaddr3','ttg2_9')" >	
		<br>
		</span>
		<span id="sp_ttg2_10" style="display:none">
		10.<input TYPE=text NAME=ttg2_mod_dmt_neaddr4 id=ttg2_mod_dmt_neaddr4 SIZE=50 MAXLENGTH=50 readonly>  
			<input TYPE=hidden NAME=draw_attach_file_ttg2_10 id=draw_attach_file_ttg2_10 >
			<input TYPE=hidden NAME=old_file_ttg2_10 id=old_file_ttg2_10 >
			<input type="button" class="cbutton" id="butUploadttg2_10" name="butUploadttg2_10" value="商標圖檔上傳" onclick="br_form.UploadAttach_photo_mod('ttg2_mod_dmt_neaddr4', 'ttg2_10', '-O10')" >
		    <input type="button" class="redbutton" name="btnDelAtt" value="商標圖檔刪除" onclick="br_form.DelAttach_photo_mod('ttg2_mod_dmt_neaddr4','ttg2_10')" >
            <input type="button" class="cbutton" name="btnDisplay" value="商標圖檔檢視" onclick="br_form.PreviewAttach_photo_mod('ttg2_mod_dmt_neaddr4','ttg2_10')" >	
		<br>
		</span>
		</TD>
	</TR>
</table>
</div>

<script language="javascript" type="text/javascript">
    //增加一筆被異議人
    $("#DO1_AP_Add_button").click(function () {
        var nRow = CInt($("#DO1_apnum").val()) + 1;
        //複製樣板
        var copyStr = $("#do1_ap_template").text() || "";
        copyStr = copyStr.replace(/##/g, nRow);

        $("#DO1_tabap>tbody").append("<tr id='tr_do1_" + nRow + "' class='sfont9'><td><table border='0' class='bluetable' cellspacing='1' cellpadding='2' width='100%'>" + copyStr + "</table></td></tr>");
        $("#tr_do1_" + nRow + " .Lock").lock();
        $("#DO1_apnum").val(nRow);
    });

    //減少一筆被異議人
    $("#DO1_AP_Del_button").click(function () {
        var nRow = CInt($("#DO1_apnum").val());
        $('#tr_do1_' + nRow).remove();
        $("#DO1_apnum").val(Math.max(0, nRow - 1));
    });

    //註冊號數
    $("#fr2_issue_no").blur(function () {
        chk_dmt_issueno($(this)[0],8);
		reg.tfzd_issue_no.value=$(this).val();
    });

    //計算類別
    br_form.count_kind_DO1 = function () {
        var pclass=[];
        var pcount=0;
        if ($("#fr2_class").val() != "") {
            pclass=$("#fr2_class").val().split(",");
            for(var j=0;j<pclass.length;j++){
                pclass[j]=("000" + pclass[j]).Right(3);//補0
            }
        }
        $("#fr2_class,#tfzr_class").val(pclass.join(','));
        $("#fr2_class_count,#tfzr_class_count").val(pclass.length);
    }

    //條款項目共N項
    br_form.add_button_DO1 = function (aprepCount) {
        var doCount = Math.max(0, CInt(aprepCount));//要改為幾筆,最少是0
        var cnt21 = CInt($("#cnt21").val());//目前畫面上有幾筆
        if (doCount > cnt21) {//要加
            for (var nRow = cnt21; nRow < doCount ; nRow++) {
                var copyStr = $("#do1_aprep_template").text() || "";
                copyStr = copyStr.replace(/##/g, nRow + 1);
                $("#tabbr21 tbody").append(copyStr);
                $("#cnt21").val(nRow + 1);
            }
        } else {
            //要減
            for (var nRow = cnt21; nRow > doCount ; nRow--) {
                $('.tr_do1_aprep_' + nRow).remove();
                $("#cnt21").val(nRow - 1);
            }
        }
    }

    //交辦內容綁定
    br_form.bindDO1 = function () {
        console.log("do1.br_form.bind");
        if (jMain.case_main.length == 0) {
            //案件種類
            $("#tfp2_case_stat").val($("#tfy_case_stat").val());//.triggerHandler("change");
            br_form.new_oldcaseB('tfp2', false);
            $("#tfp2_seq").val("");
            $("#tfp2_seq1").val("_");
            $("#DO1_AP_Add_button").click();//被異議人預設顯示第1筆
            $("#ttg2_mod_aprep_mod_count").val("1").triggerHandler("change");//條款項目預設顯示第1筆
        } else {
            //案件種類
            $("#tfp2_case_stat").val($("#tfy_case_stat").val());//.triggerHandler("change");
            br_form.new_oldcaseB('tfp2', false);
            //本所編號
            if ($("#tfy_case_stat").val() == "NN") {
                $("#tfp2_seq").val(jMain.case_main[0].seq);
                $("#tfp2_seq1").val(jMain.case_main[0].seq1);
            } else if ($("#tfy_case_stat").val() == "SN") {
                $("#tfp2_New_Ass_seq").val(jMain.case_main[0].seq);
                $("#tfp2_New_Ass_seq1").val(jMain.case_main[0].seq1);
            }
            $("#tfp2_agt_no").val(jMain.case_main[0].agt_no);//代理人
            //商標種類
            $("input[name='fr2_S_Mark'][value='" + jMain.case_main[0].s_mark + "']").prop("checked", true);
            $("#fr2_issue_no").val(jMain.case_main[0].issue_no);//註冊號數
            $("#fr2_appl_name").val(jMain.case_main[0].appl_name);//商標名稱
            //擬異議之類別種類
            $("input[name='fr2_class_type'][value='" + jMain.case_main[0].class_type + "']").prop("checked", true);
            $("#fr2_class,#tfzr_class").val(jMain.case_main[0].class);//擬異議之類別
            $("#fr2_class_count,#tfzr_class_count").val(jMain.case_main[0].class_count);//共N類
            //商標/標章圖樣部份
            if (jMain.case_main[0].cappl_name == "C") {
                $("input[name='O_cappl_name']").prop("checked", true);
            }
            if (jMain.case_main[0].eappl_name == "E") {
                $("input[name='O_eappl_name']").prop("checked", true);
            }
            if (jMain.case_main[0].jappl_name == "J") {
                $("#tfzd_jappl_name").val(jMain.case_main[0].jappl_name);
                $("input[name='O_jappl_name']").prop("checked", true);
            }
            if (jMain.case_main[0].zappl_name1 == "Z") {
                $("#tfzd_zappl_name1").val(jMain.case_main[0].zappl_name1);
                $("input[name='O_zappl_name1']").prop("checked", true);
            }
            if (jMain.case_main[0].draw == "D") {
                $("input[name='O_draw']").prop("checked", true);
            }
            $("#O_remark3").val(jMain.case_main[0].remark3);
            $("#tfzd_remark3").val(jMain.case_main[0].remark3);
            if ($("#tfy_Arcase").val().Left(3) == "DO1") {
                //被異議人
                $.each(jMain.case_tranlist, function (i, item) {
                    if (item.mod_field == "mod_ap") {
                        //增加一筆
                        $("#DO1_AP_Add_button").click();
                        //填資料
                        var nRow = $("#DO1_apnum").val();
                        $("#ttg2_mod_ap_ncname1_" + nRow).val(item.ncname1);
                        $("#ttg2_mod_ap_ncname2_" + nRow).val(item.ncname2);
                        $("#ttg2_mod_ap_nzip_" + nRow).val(item.nzip);
                        $("#ttg2_mod_ap_naddr1_" + nRow).val(item.naddr1);
                        $("#ttg2_mod_ap_naddr2_" + nRow).val(item.naddr2);
                        $("#ttg2_mod_ap_ncrep_" + nRow).val(item.ncrep);
                    }
                });
                if (CInt($("#DO1_apnum").val()) == 0) {
                    alert("查無此交辦案件之被異議人資料!!");
                }
            }
            //異議聲明
            $.each(jMain.case_tranlist, function (i, item) {
                if (item.mod_field == "mod_pul") {
                    switch (item.mod_type) {
                        case "Tmark": case "Lmark":
                            $("input[name='ttg21_mod_pul_mod_type'][value='" + item.mod_type + "']").prop("checked", true);
                            $("#ttg21_mod_pul_new_no").val(item.new_no);
                            $("#ttg21_mod_pul_ncname1").val(item.ncname1);
                            break;
                        case "O1":
                            $("input[name='ttg22_mod_pul_mod_type']").prop("checked", true);
                            break;
                        case "O2":
                            $("input[name='ttg23_mod_pul_mod_type']").prop("checked", true);
                            $("#ttg23_mod_pul_new_no").val(item.new_no);
                            $("#ttg23_mod_pul_mod_dclass").val(item.mod_dclass);
                            break;
                        case "O3":
                            $("input[name='ttg24_mod_pul_mod_type']").prop("checked", true);
                            $("#ttg24_mod_pul_new_no").val(item.new_no);
                            $("#ttg24_mod_pul_mod_dclass").val(item.mod_dclass);
                            $("#ttg24_mod_pul_ncname1").val(item.ncname1);
                            break;
                    }
                }
            });
            $("#tfz2_other_item1").val(jMain.case_main[0].other_item1);//主張法條
            //主張條款/據以異議商標號數
            if (jMain.case_main[0].mod_aprep == "Y") {
                var tranlist = $(jMain.case_tranlist).filter(function (i, n) { return n.mod_field === 'mod_aprep' });
                if (tranlist.length > 0) {
                    $("#ttg2_mod_aprep_mod_count").val(tranlist[0].mod_count);
                    br_form.add_button_DO1(tranlist[0].mod_count);
                }
                $.each(tranlist, function (i, item) {
                    $("#ttg2_mod_aprep_ncname1_" + (i + 1)).val(item.ncname1);
                    $("#ttg2_mod_aprep_new_no_" + (i + 1)).val(item.new_no);
                });
            }
            $("#tfz2_tran_remark1").val(jMain.case_main[0].tran_remark1);//事實及理由
            $("#tfz2_tran_remark2").val(jMain.case_main[0].tran_remark2);//證據內容
            //**相關聯案件
            $("#tfz2_other_item").val(jMain.case_main[0].other_item);
            if (jMain.case_main[0].other_item != "") {
                var v = jMain.case_main[0].other_item.split(";");
                if($.isDate(v[0]))$("#O_O_item1").val(v[0]);
                $("#O_O_item2").val(v[1]);
                $("#O_O_item3").val(v[2]);
            }

            //異議標的圖樣
            $("#tfp2_file").val(jMain.case_main[0].draw_file);//*圖檔實際路徑-for編修時記錄原檔名-2013/11/26增加
            $("#tfp2_draw_file").val(jMain.case_main[0].draw_file);//*圖檔實際路徑-for編修時記錄原檔名-2013/11/26增加
            if ($("#tfp2_file").val() != "") {
                $("#butUploadtfp2").prop("disabled", true);
            }

            //據以異議商標圖樣
            if (jMain.case_main[0].mod_dmt == "Y") {
                var tranlist = $(jMain.case_tranlist).filter(function (i, n) { return n.mod_field === 'mod_dmt' });
                if (tranlist.length > 0) {
                    $("#ttg2_mod_dmt_ncname1,#draw_attach_file_ttg2_1,#old_file_ttg2_1").val(tranlist[0].ncname1);
                    if ($("#ttg2_mod_dmt_ncname1").val() != "") {
                        $("#butUploadttg2_1").prop("disabled", true);
                    }
                    $("#ttg2_mod_dmt_ncname2,#draw_attach_file_ttg2_2,#old_file_ttg2_2").val(tranlist[0].ncname2);
                    if ($("#ttg2_mod_dmt_ncname2").val() != "") {
                        $("#butUploadttg2_2").prop("disabled", true);
                    }
                    $("#ttg2_mod_dmt_nename1,#draw_attach_file_ttg2_3,#old_file_ttg2_3").val(tranlist[0].nename1);
                    if ($("#ttg2_mod_dmt_nename1").val() != "") {
                        $("#butUploadttg2_3").prop("disabled", true);
                    }
                    $("#ttg2_mod_dmt_nename2,#draw_attach_file_ttg2_4,#old_file_ttg2_4").val(tranlist[0].nename2);
                    if ($("#ttg2_mod_dmt_nename2").val() != "") {
                        $("#butUploadttg2_4").prop("disabled", true);
                    }
                    $("#ttg2_mod_dmt_ncrep,#draw_attach_file_ttg2_5,#old_file_ttg2_5").val(tranlist[0].ncrep);
                    if ($("#ttg2_mod_dmt_ncrep").val() != "") {
                        $("#butUploadttg2_5").prop("disabled", true);
                    }
                    $("#ttg2_mod_dmt_nerep,#draw_attach_file_ttg2_6,#old_file_ttg2_6").val(tranlist[0].nerep);
                    if ($("#ttg2_mod_dmt_nerep").val() != "") {
                        $("#draw_num_ttg2").val("6");
                        $("#sp_ttg2_6").show();
                        $("#butUploadttg2_6").prop("disabled", true);
                    }
                    $("#ttg2_mod_dmt_neaddr1,#draw_attach_file_ttg2_7,#old_file_ttg2_7").val(tranlist[0].neaddr1);
                    if ($("#ttg2_mod_dmt_neaddr1").val() != "") {
                        $("#draw_num_ttg2").val("7");
                        $("#sp_ttg2_7").show();
                        $("#butUploadttg2_7").prop("disabled", true);
                    }
                    $("#ttg2_mod_dmt_neaddr2,#draw_attach_file_ttg2_8,#old_file_ttg2_8").val(tranlist[0].neaddr2);
                    if ($("#ttg2_mod_dmt_neaddr2").val() != "") {
                        $("#draw_num_ttg2").val("8");
                        $("#sp_ttg2_8").show();
                        $("#butUploadttg2_8").prop("disabled", true);
                    }
                    $("#ttg2_mod_dmt_neaddr3,#draw_attach_file_ttg2_9,#old_file_ttg2_9").val(tranlist[0].neaddr3);
                    if ($("#ttg2_mod_dmt_neaddr3").val() != "") {
                        $("#draw_num_ttg2").val("9");
                        $("#sp_ttg2_9").show();
                        $("#butUploadttg2_9").prop("disabled", true);
                    }
                    $("#ttg2_mod_dmt_neaddr4,#draw_attach_file_ttg2_10,#old_file_ttg2_10").val(tranlist[0].neaddr4);
                    if ($("#ttg2_mod_dmt_neaddr4").val() != "") {
                        $("#draw_num_ttg2").val("10");
                        $("#sp_ttg2_10").show();
                        $("#butUploadttg2_10").prop("disabled", true);
                    }
                }
            }
        }
    }
</script>
