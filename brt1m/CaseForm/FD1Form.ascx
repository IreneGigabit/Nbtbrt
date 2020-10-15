﻿<%@ Control Language="C#" ClassName="FD1form" %>
<%@ Import Namespace = "System.Collections.Generic"%>

<script runat="server">
    //新申請案交辦內容
    //父控制項傳入的參數
    public Dictionary<string, string> Lock = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    
    protected string prgid = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string SQL = "";

    protected string ttg1_agt_no = "", tfg1_div_arcase = "";
    protected string code_type = "";
    
    private void Page_Load(System.Object sender, System.EventArgs e) {
        code_type = (Request["code_type"] ?? "").Trim();
        PageLayout();
        this.DataBind();
    }
    
    private void PageLayout() {
        using (DBHelper conn = new DBHelper(Conn.btbrt).Debug(false)) {
            //代理人
            ttg1_agt_no = Sys.getAgent().Option("{agt_no}", "{agt_no}_{agt_namefull}", " v1='{agt_name1}' {selected}", true);
            //分割後申請案性
            SQL = "SELECT  rs_code,prt_code,rs_detail,remark ";
            SQL += "FROM code_br WHERE rs_class like 'A1%' And  cr= 'Y' and dept='T' And rs_type='" + code_type + "' AND no_code='N' ";
            SQL += "and getdate() >= beg_date and end_date is null ORDER BY rs_code";
            tfg1_div_arcase = SHtml.Option(conn, SQL, "{rs_code}", "{rs_code}--{rs_detail}");
        }
    }
</script>

<%=Sys.GetAscxPath(this)%>
<TABLE border=0 class=bluetable cellspacing=1 cellpadding=2 width="100%">
	<tr>
		<td class="lightbluetable" valign="top" ><strong>※、代理人</strong></td>
		<td class="whitetablebg" colspan="7" >
		    <select id="ttg1_agt_no" NAME="ttg1_agt_no"><%#ttg1_agt_no%></select>
            <input type="hidden" name="tfzd_agt_no" id="tfzd_agt_no">
		</td>
	</tr>
	<tr>
		<td class="lightbluetable" colspan=8 valign="top" STYLE="cursor:pointer;COLOR:BLUE" ONCLICK="PMARK(d1apply_no)">
            <strong>壹、<u>原註冊申請案號、商標/標章名稱、商標種類、分割件數、商標/標章圖樣</u></strong>
        </td>
	</tr>
	<tr>
		<td class=lightbluetable align=right >一、原申請案號：</td>
		<td class=whitetablebg colspan="7">
			<input type=text id=fr1_apply_no name=fr1_apply_no onchange="reg.tfzd_apply_no.value=reg.fr1_apply_no.value">
		</TD>									
	</tr>
	<tr>
		<td class=lightbluetable align=right >二、商標／標章名稱：</td>
		<td class=whitetablebg colspan="7">
			<input type=text id=fr1_appl_name name=fr1_appl_name onchange="reg.tfzd_appl_name.value=reg.fr1_appl_name.value">
		</TD>
	</tr>
    <tr>
		<td class=lightbluetable align=right >三、商標種類：</td>
		<td class=whitetablebg colspan="7">
            <input type="radio" name="fr1_S_Mark" value="" onclick="dmt_form.change_mark(1)">商標
            <span id="fr1_smark1" style="display:none">
            <input type="radio" name="fr1_S_Mark" value="S" onclick="dmt_form.change_mark(1)">92年修正前服務標章
            </span>
            <input type="radio" name="fr1_S_Mark" value="N" onclick="dmt_form.change_mark(1)">團體商標
            <span id="fr1_smark2" style="display:none">
            <input type="radio" name="fr1_S_Mark" value="M" onclick="dmt_form.change_mark(1)">團體標章
            </span>
            <input type="radio" name="fr1_S_Mark" value="L" onclick="dmt_form.change_mark(1)">證明標章
		</TD>
	</tr>
	<tr>
		<td class=lightbluetable align=right >四、分割件數：</td>
		<td class=whitetablebg colspan="7">
			分割為<input type=text id=tot_num1 name=tot_num1 size="2" maxlength="2" onchange="vbscript:Add_button_FD1 me.value">件
			<input type=hidden id=count1 name=count1 value="1">
			<input type=hidden id=ctrlcnt1 name=ctrlcnt1 value="">
			<input type=hidden id=cnt1 name=cnt1 value="1">
			<input type=hidden id=nfy_tot_num name=nfy_tot_num value="1">
		</TD>
	</tr>
	<tr>
		<td class=lightbluetable align=right >分割後申請案性：</td>
		<td class=whitetablebg colspan="7">
            <select id="tfg1_div_arcase" name="tfg1_div_arcase"><%#tfg1_div_arcase%></SELECT>
            <font color="red">(為列印商標註冊申請書，請選擇分割後申請案性)</font><input type=hidden name=tfy_div_arcase id=tfy_div_arcase>
		</TD>
	</tr>
	<tr>
		<td class="lightbluetable" colspan=8 valign="top" STYLE="cursor:pointer;COLOR:BLUE" ONCLICK="PMARK(d1class)">
            <strong>肆、<u>分割商品/服務類別、名稱、證明內容及標的(請依序填寫商品/服務類別、名稱)</u></strong>
		</td>
	</tr>
	<tr>
	    <td colspan=8>
			<TABLE id=tabbDa1 name=tabbDa1 style="display" border=1 class="bluetable" cellspacing=1 cellpadding=2 width="100%">
			<tr>
				<td class="lightbluetable" align="right" width="30%" ><font color=red>分割(一)</font>類別種類:</td>		
				<td class="whitetablebg" width="70%">
				   <INPUT type="radio" id=FD1_class_type1 name=FD1_class_type1 value="int">國際分類
				   <INPUT type="radio" id=FD1_class_type1 name=FD1_class_type1 value="old">舊類
				</td>
			</tr>
			<tr>
				<td class="lightbluetable" align="right" style="cursor:pointer" title="請輸入類別" width="30%" ><font color=red>分割(一)</font>類別項目:</td>		
				<td class="whitetablebg" width="70%">共<INPUT type="text" id=FD1_class_count1 name=FD1_class_count1 size=2 maxlength=2 onchange="vbscript:Add_button_FDA me.value,'1'">類
				<input type=hidden name=FD1_count1 value="1">
					<input type=hidden name=FD1_ctrlcnt1 value="1">
					<input type=hidden name=FD1_cnt1 value="1">
					<input type=hidden name=FD1_case_sqlno1 value="">
					<input type="text" name=FD1_class1 id=FD1_class1 readonly>
				</td>
			</tr>
			<tr>
				<td class="lightbluetable" align="right" style="cursor:pointer" ><font color=red>(一)</font>名稱種類:</td>		
				<td class="whitetablebg"><INPUT type="radio" id=FD1_Marka1T name=FD1_Marka1 value="T">商品/服務名稱<INPUT type="radio" id=FD1_Marka1L name=FD1_Marka1 value="L">證明標的及內容</td>
			</tr>
			<tr>
				<td class="lightbluetable" align="right" style="cursor:pointer" title="請輸入類別"><font color=red>(一)</font>類別1:</td>		
				<td class="whitetablebg">第<INPUT type="text" id=classa11 name=classa11 size=3 maxlength=3 onchange="vbscript:count_kind1 reg.classa11.value,1,'a1'">類
				</td>
			</tr>
			<tr style="height:107.6pt">
				<td class="lightbluetable" align="right"><font color=red>(一)</font>商品/服務名稱1:</td>			
				<td class="whitetablebg"><textarea NAME="FD1_good_namea11" ROWS="10" COLS="55" onchange="vbscript:good_name_count1 'FD1_good_namea11','FD1_good_counta11'"></textarea><br>共<input type="text" name=FD1_good_counta11 size=2>項</td>
			</tr>		
			</table>

		</td>
	</tr>

	<tr>
		<td class=lightbluetable align=right >註冊號數：</td>
		<td class=whitetablebg colspan="7"><input type="text" id="fr_issue_no" name="fr_issue_no" value="" size="20" maxlength="20" onchange="reg.tfzd_issue_no.value=reg.fr_issue_no.value"></TD>
	</tr>
	<tr>
		<td class=lightbluetable align=right >商標/標章名稱：</td>
		<td class=whitetablebg colspan="7"><input type="text" id="fr_Appl_name" name="fr_Appl_name" value="" size="30" maxlength="100" onchange="reg.tfzd_Appl_name.value=reg.fr_Appl_name.value"></TD>
	</tr>
	<tr style="display:none">
		<td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:pointer;COLOR:BLUE" onclick="PMARK(r1Term2)"><strong>肆、<u>原註冊證核准專用期間</u></strong></td>
	</tr>
	<tr style="display:none">
        <td class=lightbluetable STYLE="cursor:pointer;COLOR:BLUE">　</td>
        <td class=whitetablebg colspan=7 >
            自<INPUT type=text id=tfgp_term1 name=tfgp_term1 size=10 class="dateField">
            至<INPUT type=text id=tfgp_term2 name=tfgp_term2 size=10 class="dateField">
        </TD>
	</tr>
	<tr>
		<td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:pointer;COLOR:BLUE" onclick="PMARK(r1Term1)">
            <strong>肆、<u>變更事項</u></strong>
		    <input type="hidden" id="tfgp_mod_ap" name="tfgp_mod_ap">
		    <input type="hidden" id="tfgp_mod_aprep" name="tfgp_mod_aprep">
		    <input type="hidden" id="tfgp_mod_agt" name="tfgp_mod_agt">
		    <input type="hidden" id="tfgp_mod_apaddr" name="tfgp_mod_apaddr">
		    <input type="hidden" id="tfgp_mod_agtaddr" name="tfgp_mod_agtaddr">
		    <input type="hidden" id="tfgp_mod_pul" name="tfgp_mod_pul">
		    <input type="hidden" id="tfgp_mod_oth" name="tfgp_mod_oth">
		    <input type="hidden" id="tfgp_mod_oth1" name="tfgp_mod_oth1">
		    <input type="hidden" id="tfgp_mod_oth2" name="tfgp_mod_oth2">
		    <input type="hidden" id="tfgp_mod_dmt" name="tfgp_mod_dmt">
		    <input type="hidden" id="tfgp_mod_agttype" name="tfgp_mod_agttype">
		</td>
	</tr>
	<tr>
		<td class=lightbluetable align=right></td>
		<td class=whitetablebg colspan="7">
            <input type="checkbox" id="tfzr_mod_dmt" name="tfzr_mod_dmt">變更商標／標章名稱：<input type="text" id="new_appl_name" name="new_appl_name" size="60" maxlength="100" onblur="fDataLen(this)">
		</TD>
	</tr>
	<tr >
		<td class=lightbluetable align=right></td>
		<td class=whitetablebg colspan="7">
            <span style="display:none">
                <input type="checkbox" id="tfzr_mod_apaddr" name="tfzr_mod_apaddr">申請人地址&nbsp;&nbsp;&nbsp;&nbsp;
                <input type="checkbox" id="tfzr_mod_agtaddr" name="tfzr_mod_agtaddr" onclick="chkagttype()">代理人地址&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            </span>
			<input type="checkbox" id="tfzr_mod_pul" name="tfzr_mod_pul">防護商標/標章變更為商標
		</TD>
	</tr>
	<tr>
		<td class=lightbluetable align=right></td>
		<td class=whitetablebg colspan="7">
            <span style="display:none">
                <input type="checkbox" name="tfzr_mod_ap" id="tfzr_mod_ap">申請人名稱&nbsp;&nbsp;&nbsp;&nbsp;
                <input type="checkbox" name="tfzr_mod_aprep" id="tfzr_mod_aprep">代表人或負責人&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            </span>
			<input type="checkbox" name="tfzr_mod_agt" id="tfzr_mod_agt">代理人&nbsp;&nbsp;&nbsp;代理人異動：
			<input type="radio" name="tfzr_mod_agttype" value="C" onclick="chkmodagt">變更
			<input type="radio" name="tfzr_mod_agttype" value="A" onclick="chkmodagt">新增
			<input type="radio" name="tfzr_mod_agttype" value="D" onclick="chkmodagt">撤銷
		</TD>
	</tr>
    <tr style="display:none">
		<td class=lightbluetable align=right></td>
		<td class=whitetablebg colspan="7">
            <input type="checkbox" id="tfzr_mod_oth" name="tfzr_mod_oth">申請人印鑑&nbsp;&nbsp;&nbsp;&nbsp;
            <input type="checkbox" id="tfzr_mod_oth1" name="tfzr_mod_oth1">代表人或負責人印鑑&nbsp
            <input type="checkbox" id="tfzr_mod_oth2" name="tfzr_mod_oth2" onclick="chkagttype()">代理人印鑑
		</TD>
	</tr>
	<tr>
		<td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:pointer;COLOR:BLUE" onclick="PMARK(r1Good)"><strong>伍、<u>延展商標權範圍及內容</u></strong></td>
	</tr>
	<tr>
		<td colspan=8>
		    <TABLE id=tabbr2 border=1 class="bluetable"  cellspacing=1 cellpadding=2 width="100%">
            <thead>
		        <tr>
			        <td class=lightbluetable align=right>一、</td>
			        <td class=whitetablebg colspan="7">
                        <input type="radio" name="tfzy_mark" id="tfzy_markY" value="Y">全部延展（原指定使用之商品／服務全部延展者，請勾選此欄位即可）
			            <input type="hidden" name="tfzd_mark" id="tfzd_mark">
			        </TD>
		        </tr>
		        <tr>
			        <td class=lightbluetable align=right>二、</td>
			        <td class=whitetablebg colspan="7">
                        <input type="radio" name="tfzy_mark" id="tfzy_markN" value="N">部分延展：(請指明延展之商品/服務名稱)
                    </td>
		        </tr>
		        <tr>
			        <td class=lightbluetable align=right>類別：</td>
			        <td class="whitetablebg" colspan="7">
                        <span style="display:none">商標法施行細則第<INPUT type="text" id=tfgp_other_item2 name=tfgp_other_item2 size=3 maxlength=3>條</span>第<input type="text" name="tfzd_class" id="tfzd_class" readonly>類
			        </td>
		        </tr>
		        <tr>	
			        <td class="lightbluetable" align="right" >類別種類：</td>
			        <td class="whitetablebg" colspan="7" >
				        <input type="radio" id=tfzd_class_typeI name=tfzd_class_type value="int">國際分類
				        <input type="radio" id=tfzd_class_typeO name=tfzd_class_type value="old">舊類
			        </td>
		        </tr>
		        <tr>	
			        <td class="lightbluetable" align="right">類別項目：</td>
			        <td class="whitetablebg" colspan="7" >共<input type="text" id=tfzd_class_count name=tfzd_class_count size=2 onchange="br_form.Add_class(this.value)">類
				        <input type=text id=num2 name=num2 value="0"><!--畫面上有幾筆-->
				        <input type=text id=ctrlnum2 name=ctrlnum2 value="0">
				        <input type=text id=ctrlcount2 name=ctrlcount2 value="">
			        </td>
		        </tr>
            </thead>
            <tbody></tbody>
            <script type="text/html" id="br_class_template"><!--類別樣板-->
                <tr class="tr_br_class_##">
			        <td class="lightbluetable" align="right" style="cursor:pointer" title="請輸入類別，並以逗號分開(例如：1,5,32)。或輸入類別範圍，並以  -  (半形) 分開(例如：8-16)。也可複項組合(例如：3,5,13-32,35)">類別##：</td>
			        <td class="whitetablebg" colspan="7">第<INPUT type="text" id=class2_## name=class2_## size=3 maxlength=3 onchange="br_form.count_kind('##')">類</td>		
		        </tr>
		        <tr class="tr_br_class_##" style="height:107.6pt">
			        <td class="lightbluetable" align="right" width="18%">商品名稱##：</td>
			        <td class="whitetablebg" colspan="7">
                        <textarea id="good_name2_##" NAME="good_name2_##" ROWS="10" COLS="75" onchange="br_form.good_name_count('##')"></textarea>
                        <br>共<input type="text" id=good_count2_## name=good_count2_## size=2>項
			        </td>
		        </tr>
		        <tr class="tr_br_class_##">
			        <td class="lightbluetable" align="right">商品群組代碼##：</td>
			        <td class="whitetablebg" colspan="7"><textarea id=grp_code2_## NAME=grp_code2_## ROWS="1" COLS="50"></textarea>(跨群組請以全形「、」作分隔)</td>
		        </tr>
            </script>
		    </table>
		</td>
	</tr>
	<tr style="display:none">
		<td class="lightbluetable" colspan="8" valign="top" STYLE="COLOR:BLUE">
            <strong>伍、延展證明標的及內容/表彰組織及會員之會籍</strong>
            <input type="hidden" name="tfgp_tran_remark2" id="tfgp_tran_remark2" value="">
		</td>
	</tr>
	<tr style="display:none">
		<td class=lightbluetable align=right ><INPUT type="radio" name="ttr1_RCode" id="ttr1_RCodeL" value="L" onclick="br_form.CopyStr1(reg.tfgp_tran_remark2,'1',this)"></td>
		<td class=whitetablebg colspan="7">證明標章證明標的及內容：<input TYPE="text" NAME="ttr1_R1" id="ttr1_R1" SIZE="20" MAXLENGTH="50" onchange="br_form.CopyStr1(reg.tfgp_tran_remark2,'0',this)"></TD>
	</tr>
	<tr style="display:none">
		<td class=lightbluetable align=right ><INPUT type="radio" name="ttr1_RCode" id="ttr1_RCodeM" value="M" onclick="br_form.CopyStr1(reg.tfgp_tran_remark2, '1', this)"></td>
		<td class=whitetablebg colspan="7">團體標章：<input TYPE="text" NAME="ttr1_R9" id="ttr1_R9" SIZE="20" MAXLENGTH="50" onchange="br_form.CopyStr1(reg.tfgp_tran_remark2,'0',this)"></TD>
	</tr>
	<tr>
		<td class=lightbluetable colspan="8" STYLE="cursor:pointer;COLOR:BLUE" onclick="PMARK(r1Remark1)"><strong><u>備註：本案另涉有他案時，請於備註欄內填明。</u></strong></td>
	</tr>
	<tr>
		<td class="lightbluetable" colspan="8" valign="top">
			<INPUT type="checkbox" name="O_item" value="1" ><label onclick="reg.O_item(0).checked=true">
			本案於<INPUT type=text id=O_item1 name=O_item1 size=10 class="dateField">(年/月/日)
			，另案辦理<INPUT type=radio id=O_item2FI1 name=O_item2 value="FI1"><label for=O_item2FI1>補證案</label>
			<INPUT type=radio id=O_item2FT1 name=O_item2 value="FT1"><label for=O_item2FT1>移轉案</label>
			<INPUT type=radio id=O_item2FL1 name=O_item2 value="FL1"><label for=O_item2FL1>授權案</label>
			</label>
		</td>
	</tr>
	<tr>
		<td class="lightbluetable" colspan="8" valign="top">
			<INPUT type="checkbox" name="O_item" value="Z">
			其他：<input type=text id=O_item2t name=O_item2t size=44 onclick="reg.O_item(1).checked=true">
		</TD>
	</tr>
</TABLE>

<TABLE id=tabrem4 style="display:none" border=0 class="bluetable" cellspacing=1 cellpadding=2 width="100%">
	<tr>
		<td class="lightbluetable" colspan="8" valign="top" STYLE="COLOR:BLUE" onclick="PMARK(ZAttech)">
            <strong><u>附件：</u></strong>
            <input type=hidden id="tfzd_remark1" name="tfzd_remark1" value="">
		</td>
	</tr>
	<tr style="display:none">
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttzd_Z1" NAME="ttzd_Z1" value="Z1" onclick="br_form.AttachStr()"></td>
		<td class="whitetablebg" colspan="7">大陸地區（含港、澳地區）之自然人或法人之身分證明文件。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttzd_Z2" NAME="ttzd_Z2" value="Z2" onclick="br_form.AttachStr()"></td>
		<td class="whitetablebg" colspan="7">委任書(<input TYPE="checkbox" id="ttzd_Z2C" NAME="ttzd_Z2C" value="Z2C" onclick="br_form.AttachStr()">附中文譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttzd_Z3" NAME="ttzd_Z3" value="Z3" onclick="br_form.AttachStr()"></td>
		<td class="whitetablebg" colspan="7">變更證明文件。(更名時檢附)</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttzd_Z9" NAME="ttzd_Z9" value="Z9" onclick="br_form.AttachStr()"></td>
		<td class="whitetablebg" colspan="7">其他證明文件。<input TYPE="text" id="ttzd_Z9t" NAME="ttzd_Z9t" SIZE="50" onchange="br_form.AttachStr()">
			
		</td>
	</tr>
</table>
<INPUT TYPE=hidden id=tfgp_seq NAME=tfgp_seq>
<INPUT TYPE=hidden id=tfgp_seq1 NAME=tfgp_seq1>

<script language="javascript" type="text/javascript">
    var br_form = {};
    br_form.init = function () {
    }

    //*****依商品名稱計算類別
    br_form.good_name_count = function (nRow) {
        var MyString = $("#good_name2_" + nRow).val().trim();
        MyString = MyString.replace(/;/gm, "；");
        MyString = MyString.replace(/,/gm, "，");

        if (MyString.Right(1) == "；" || MyString.Right(1) == "，" || MyString.Right(1) == "、") {
            MyString = MyString.substring(0, MyString.length - 1);
        }

        $("#good_count2_" + nRow).val("");
        if (MyString != "") {
            var myarray = MyString.split(/[；，、]/);
            $("#good_name2_" + nRow).val(MyString);
            var aKind = myarray.length;//共幾類
            alert("商品內容共" + aKind + "項");
            $("#good_count2_" + nRow).val(aKind);

            if (MyString.indexOf("及") > -1 || MyString.indexOf("或") > -1) {
                alert("【商品服務項目中包含有「及」、「或」等用語，請留意商品項目數。】");
            }
        }
    }

    //共N類
    br_form.Add_class = function (classCount) {
        var doCount = Math.max(0, CInt(classCount));//要改為幾筆,最少是0
        var num2 = CInt($("#num2").val());//目前畫面上有幾筆
        if (doCount > num2) {//要加
            for (var nRow = num2; nRow < doCount ; nRow++) {
                var copyStr = $("#br_class_template").text() || "";
                copyStr = copyStr.replace(/##/g, nRow + 1);
                $("#tabbr2 tbody").append(copyStr);
                $("#num2").val(nRow + 1);
            }
        } else {
            //要減
            for (var nRow = num2; nRow > doCount ; nRow--) {
                $('.tr_br_class_' + nRow).remove();
                $("#num2").val(nRow - 1);
            }
        }
    }

    //檢查類別範圍0~45
    br_form.checkclass = function (xclass) {
        if (CInt(xclass) < 0 || CInt(xclass) > 45) {
            alert("商品類別需介於1~45之間,請重新輸入。");
            return false;
        }
    }

    //類別串接
    br_form.count_kind = function (nRow) {
        if ($("#class2_" + nRow).val() != "") {
            if (IsNumeric($("#class2_" + nRow).val())) {
                var x = ("000" + $("#class2_" + nRow).val()).Right(3);//補0
                $("#class2_" + nRow).val(x);
                br_form.checkclass(x);
            } else {
                alert("商品類別請輸入數值!!!");
                $("#class2_" + nRow).val("");
            }
        }

        $("#tfzd_class").val($("#tabbr2>tbody input[id^='class2_']").map(function (index) {
            if (index == 0 || $(this).val() != "") return $(this).val();
        }).get().join(','));
    }


    //附件
    br_form.AttachStr = function () {
        var strRemark1 = "";
        $("#tabrem4 :checkbox").each(function (index) {
            var $this = $(this);
            if ($this.prop("checked")) {
                strRemark1 += $this.val() + "|";
            }
        });
        //其他文件輸入框
        $("#tabrem4 :text").each(function (index) {
            var $this = $(this);
            if ($this.val() != "") {
                strRemark1 += "Z9-" + $this.val() + "-Z9|";
            }
        });
        reg.tfzd_remark1.value = strRemark1;
    }

    //交辦內容綁定
    br_form.bind = function () {
        //console.log("br_form.bind");
        if (jMain.case_main.length == 0) {
        } else {
            //*出名代理人代碼
            $("#tfzd_agt_no").val(jMain.case_main[0].agt_no);
            //商標種類
            $("input[name=fr_S_Mark][value='" + jMain.case_main[0].S_mark + "']").prop("checked", true);

            $("#fr_issue_no").val(jMain.case_main[0].issue_no);//註冊號
            $("#fr_Appl_name").val(jMain.case_main[0].appl_name);//商標名稱
            $("#fr_apply_no").val(jMain.case_main[0].apply_no);//申請號數
            //***原註冊證核准專用期間
            $("#tfgp_term1").val(jMain.case_main[0].term1);
            $("#tfgp_term2").val(jMain.case_main[0].term2);

            if (jMain.case_tran.length != 0) {
                //**變更事項
                if (jMain.case_tran[0].mod_dmt == "Y") {//變更商標／標章名稱
                    $("#tfzr_mod_dmt").prop("checked", true);
                    $("#tfgp_mod_dmt").val("Y");
                    if (jMain.case_tranlist.length > 0) {
                        $("#new_appl_name").val(jMain.case_tranlist[0].ncname1);
                    }
                } else {
                    $("#tfzr_mod_dmt").prop("checked", false);
                    $("#tfgp_mod_dmt").val("N");
                }
                if (jMain.case_tran[0].mod_apaddr == "Y") {//申請人地址
                    $("#tfzr_mod_apaddr").prop("checked", true);
                    $("#tfgp_mod_apaddr").val("Y");
                } else {
                    $("#tfzr_mod_apaddr").prop("checked", false);
                    $("#tfgp_mod_apaddr").val("N");
                }
                if (jMain.case_tran[0].mod_agtaddr == "Y") {//代理人地址
                    $("#tfzr_mod_agtaddr").prop("checked", true);
                    $("#tfgp_mod_agtaddr").val("Y");
                } else {
                    $("#tfzr_mod_agtaddr").prop("checked", false);
                    $("#tfgp_mod_agtaddr").val("N");
                }
                if (jMain.case_tran[0].mod_pul == "Y") {//防護商標/標章變更為商標
                    $("#tfzr_mod_pul").prop("checked", true);
                    $("#tfgp_mod_pul").val("Y");
                } else {
                    $("#tfzr_mod_pul").prop("checked", false);
                    $("#tfgp_mod_pul").val("N");
                }

                if (jMain.case_tran[0].mod_ap == "Y") {//申請人名稱
                    $("#tfzr_mod_ap").prop("checked", true);
                    $("#tfgp_mod_ap").val("Y");
                } else {
                    $("#tfzr_mod_ap").prop("checked", false);
                    $("#tfgp_mod_ap").val("N");
                }
                if (jMain.case_tran[0].mod_aprep == "Y") {//代表人或負責人
                    $("#tfzr_mod_aprep").prop("checked", true);
                    $("#tfgp_mod_aprep").val("Y");
                } else {
                    $("#tfzr_mod_aprep").prop("checked", false);
                    $("#tfgp_mod_aprep").val("N");
                }
                if (jMain.case_tran[0].mod_agt == "Y") {//代理人異動
                    $("#tfzr_mod_agt").prop("checked", true);
                    $("#tfgp_mod_agt").val("Y");
                } else {
                    $("#tfzr_mod_agt").prop("checked", false);
                    $("#tfgp_mod_agt").val("N");
                }
                //代理人異動種類
                $("input[name='tfzr_mod_agttype'][value='" + jMain.case_tran[0].mod_agttype + "']").prop("checked", true);
                var opt_type = ['C', 'A', 'D'];
                if (opt_type.indexOf(jMain.case_tran[0].mod_agttype)!==-1){
                    $("#tfgp_mod_agttype").val(jMain.case_tran[0].mod_agttype);
                } else {
                    $("#tfgp_mod_agttype").val("N");
                }
                if (jMain.case_tran[0].mod_oth == "Y") {//申請人印鑑
                    $("#tfzr_mod_oth").prop("checked", true);
                    $("#tfgp_mod_oth").val("Y");
                } else {
                    $("#tfzr_mod_oth").prop("checked", false);
                    $("#tfgp_mod_oth").val("N");
                }
                if (jMain.case_tran[0].mod_oth1 == "Y") {//代表人或負責人印鑑
                    $("#tfzr_mod_oth1").prop("checked", true);
                    $("#tfgp_mod_oth1").val("Y");
                } else {
                    $("#tfzr_mod_oth1").prop("checked", false);
                    $("#tfgp_mod_oth1").val("N");
                }
                if (jMain.case_tran[0].mod_oth2 == "Y") {//代理人印鑑
                    $("#tfzr_mod_oth2").prop("checked", true);
                    $("#tfgp_mod_oth2").val("Y");
                } else {
                    $("#tfzr_mod_oth2").prop("checked", false);
                    $("#tfgp_mod_oth2").val("N");
                }
                //商標法施行細則第
                $("#tfgp_other_item2").val(jMain.case_tran[0].other_item2);

                //延展證明標的及內容/表彰組織及會員之會籍
                $("#tfgp_tran_remark2").val(jMain.case_tran[0].tran_remark2);
                if (jMain.case_tran[0].tran_remark2 != "") {
                    var arr_mark2 = jMain.case_tran[0].tran_remark2.split("|");
                    if (arr_mark2[0] == "L") {
                        $("#ttr1_RCodeL").prop("checked", true);
                        $("#ttr1_R1").val(arr_mark2[1]);
                    } else {
                        $("#ttr1_RCodeM").prop("checked", true);
                        $("#ttr1_R9").val(arr_mark2[1]);
                    }
                }
                //**備註
                var arrItem = jMain.case_tran[0].other_item.split("|");
                for (var ix in arrItem) {
                    if (arrItem[ix].indexOf(";") > -1) {
                        var oitem = arrItem[ix].split(";");
                        if (oitem.indexOf(",") > -1) {
                            var oitem1 = oitem[0].split(",");
                            $("input[name=O_item][value='1']").prop("checked", true);
                            $("#O_item1").val(oitem1[1]);
                            $("input[name=O_item2][value='" + oitem[1] + "']").prop("checked", true);
                        } else {
                            if (oitem[0] == "Z") {
                                $("input[name=O_item][value='Z']").prop("checked", true);
                                if (oitem[1].indexOf(",")) {
                                    var oitem2 = oitem[1].split(",");//備註為ZZ且後面有接說明
                                    $("#O_item2t").val(oitem2[1]);
                                }
                            } else {
                                if (oitem[1] == "ZZ") {
                                    $("input[name=O_item][value='Z']").prop("checked", true);
                                } else {
                                    $("input[name=O_item][value='1']").prop("checked", true);
                                    $("#O_item1").val(oitem[0]);
                                    $("input[name=O_item2][value='" + oitem[1] + "']").prop("checked", true);
                                }
                            }
                        }
                    }
                }
            }
           
            //延展商標權範圍及內容
            $("#tfzd_mark").val(jMain.case_main[0].temp_mark);
            if (jMain.case_main[0].temp_mark == "N") {
                $("#tfzy_markY").prop("checked", true);//全部延展
            } else {
                $("#tfzy_markN").prop("checked", true);//部分延展
            }

            //**類別
            if (jMain.case_good.length > 0) {
                //類別種類
                $("input[name='tfzd_class_type'][value='" + jMain.case_main[0].class_type + "']").prop('checked', true).triggerHandler("click");
                $("#fr_class").val(jMain.case_main[0].class);
                //指定使用商品／服務類別
                $("#tfzd_class").val(jMain.case_main[0].class);//*類別
                $("#tfzd_class_count").val(jMain.case_good.length);//共N類
                br_form.Add_class(jMain.case_good.length);//產生筆數
                $.each(jMain.case_good, function (i, item) {
                    $("#class2_" + (i + 1)).val(item.class);//第X類
                    $("#good_count2_" + (i + 1)).val(item.dmt_goodcount);//共N項
                    $("#grp_code2_" + (i + 1)).val(item.dmt_grp_code);//商品群組代碼
                    $("#good_name2_" + (i + 1)).val(item.dmt_goodname);//商品名稱
                });
            } else {
                br_form.count_kind(1);////類別串接
            }

            //**附件
            $("#tfzd_remark1").val(jMain.case_main[0].remark1);
            if (jMain.case_main[0].remark1 != "") {
                var arr_remark1 = jMain.case_main[0].remark1.split("|");
                for (var i = 0; i < arr_remark1.length; i++) {
                    //var str="Z3|Z9|Z9-具結書正本、讓與人之負責人身份證影本-Z9|";
                    var str = "Z9-具結書正本、讓與人之負責人身份證影本-Z9";
                    var substr = arr_remark1[i].match(/Z9-(\S+)-Z9/);
                    if (substr != null) {
                        $("#ttzd_Z9t").val(substr[1]);
                    } else {
                        $("#ttzd_" + arr_remark1[i]).prop("checked", true);
                    }
                }
            }
        }
    }
</script>
