<%@ Control Language="C#" ClassName="FN1Form" %>
<%@ Import Namespace = "System.Collections.Generic"%>

<script runat="server">
    //AA各種證明書交辦內容
    //父控制項傳入的參數
    public Dictionary<string, string> Lock = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    
    protected string prgid = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string SQL = "";

    protected string tfgd_agt_no1 = "";
    
    private void Page_Load(System.Object sender, System.EventArgs e) {
        PageLayout();   
        this.DataBind();
    }
    
    private void PageLayout() {
        //代理人
        tfgd_agt_no1 = Sys.getAgent().Option("{agt_no}", "{agt_no}_{agt_namefull}", " v1='{agt_name1}' {selected}", true);
    }
</script>

<div id="div_Form_FN1">
<%=Sys.GetAscxPath(this)%>
<TABLE border=0 class=bluetable cellspacing=1 cellpadding=2 width="100%">
	<tr>
		<td class="lightbluetable" valign="top" ><strong>參、代理人</strong></td>
		<td class="whitetablebg" colspan="7" >
		    <select id="tfgd_agt_no1" NAME="tfgd_agt_no1"><%#tfgd_agt_no1%></select>
            <input type="hidden" id="tfzd_agt_no" name="tfzd_agt_no" value="">
		</td>
	</tr>
	<tr>
		<td class=lightbluetable width="20%" STYLE="cursor:pointer;COLOR:BLUE" ONCLICK="PMARK(N1mark)"><u>證明書種類</u>：</td>
		<td class=whitetablebg colspan=7 >
		    <INPUT type="radio" id=tfgd_tran_MarkC name=tfgd_tran_Mark value="C">中文證明書
		    <INPUT type="radio" id=tfgd_tran_MarkE name=tfgd_tran_Mark value="E">英文證明書
		</td>
	</tr>
	<tr>
		<td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:pointer;COLOR:BLUE" ONCLICK="PMARK(N1Appl_name)">
            <strong>壹、<u>號數、商標(標章)種類及名稱</u></strong>
		</td>
	</tr>
    <tr>
		<td class=lightbluetable align=right >程序種類：</td>
		<td class=whitetablebg colspan=7>
            <input type=radio NAME=tfzd_Mark id=tfzd_MarkA value="A" onclick="br_form.change_no('A')">申請
			<input type=radio NAME=tfzd_Mark id=tfzd_MarkI value="I" onclick="br_form.change_no('I')">註冊
		</td>
	</tr>
	<tr>
		<td class=lightbluetable align=right ><span id=span_no></span>號數：</td>
		<td class=whitetablebg colspan="3"><input type="text" id="no" name="no" value="" size="20" maxlength="20"></TD>
		<td class=lightbluetable align=right >商標名稱：</td>
		<td class=whitetablebg colspan="3"><input type="text" id="fr_Appl_name" name="fr_Appl_name" value="" size="50" maxlength="100" onchange="reg.tfzd_Appl_name.value=this.value">
		<input type="hidden" value="" id=fr_issue_no name=fr_issue_no>
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
    <tr style="display:none">
		<td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:pointer;COLOR:BLUE" ONCLICK="PMARK(e1Term1)"><strong>肆、<u>專用期間/申請註冊日期</u></strong></td>
	</tr>
	<tr style="display:none">
		<td class=lightbluetable align=right><input type="radio" id=tfgd_mod_claim1I name=tfgd_mod_claim1 value="I" onclick="reg.tfn2_term1.value=''">商標權期間：<br>(已註冊者)</td>
		<td class=whitetablebg colspan=7>
            自<input type=text id=tfn1_term1 name=tfn1_term1 size=10 class="dateField">(年/月/日)
      		至<input type=text id=tfn1_term2 name=tfn1_term2 size=10 class="dateField">(年/月/日)
      		<input type="hidden" id=tfg3_term1 name=tfg3_term1 value="">
      		<input type="hidden" id=tfg3_term2 name=tfg3_term2 value="">
        </td>
	</tr>
	<tr style="display:none">
		<td class=lightbluetable align=right><input type="radio" id=tfgd_mod_claim1A name=tfgd_mod_claim1 value="A" onclick="reg.tfn1_term1.value=''; reg.tfn1_term2.value=''">申請註冊日期：</td>
		<td class=whitetablebg colspan=7><input type=text id=tfn2_term1 name=tfn2_term1 size=10 class="dateField">(年/月/日)</td>
	</tr>
	<tr>
		<td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:pointer;COLOR:BLUE" ONCLICK="PMARK(e1Good)"><strong>肆、<u>指定使用商品(服務)(申請中文證明書者英文部分免填)</u></strong></td>
	</tr>
	<tr>
		<td class=lightbluetable align=right>類別：</td>
		<td class=whitetablebg colspan=7>商標法施行細則第<input type=text id=O_item4 NAME=O_item4 size=5 maxlength=14>條第<input type=text id=O_item41 name=O_item41 size=20 maxlength=50>類
		</td>
	</tr>
    <tr>
		<td class=lightbluetable align=right>商品(服務)名稱：<br>(中文)</td>
		<td class=lightbluetable  colspan=7><TEXTAREA id=tfgd_tran_remark1 NAME=tfgd_tran_remark1 Rows=5 cols=80></TEXTAREA></TD>
	</tr>
	<tr>
		<td class=lightbluetable align=right>商品(服務)名稱：<br>(英文)</td>
		<td class=lightbluetable  colspan=7><TEXTAREA id=tfgd_tran_remark2 NAME=tfgd_tran_remark2 Rows=5 cols=80></TEXTAREA></TD>
	</tr>
	<tr>
		<td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:pointer;COLOR:BLUE" ONCLICK="PMARK(e1Draw)"><strong>伍、<u>浮貼圖樣</u></strong></td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right">申請份數：</td>
		<td class="whitetablebg" colspan="7"><input type=text name=O_item3 id=O_item3 size=3 maxlength=3>份，商標(標章)圖樣：<input type=text name=O_item31 id=O_item31 size=3 maxlength=3>張。</td>
	</tr>
	<tr>
	 	<td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:pointer;COLOR:BLUE" ONCLICK="PMARK(zAttech)"><strong><u>附件</u></strong>
            <input type="text" id="tfzd_remark1" name="tfzd_remark1">
	 	</td>
	</tr>	
	<tr class="br_attchstr" style="display:none">
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttz1_Z1" NAME="ttz1_Z1" value="Z1" onclick="br_form.AttachStr('.br_attchstr','ttz1_',reg.tfzd_remark1)"></td>
		<td class="whitetablebg" colspan="7">中文註冊證影本(已註冊者)/原商標註冊申請書影本(申請中者)，另申中文註冊證明者，請檢附與申請份數相同之影本。</td>
	</tr>
	<tr class="br_attchstr">
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttz1_Z3" NAME="ttz1_Z3" value="Z3" onclick="br_form.AttachStr('.br_attchstr','ttz1_',reg.tfzd_remark1)"></td>
		<td class="whitetablebg" colspan="7">委任書(<input type=checkbox id="ttz1_Z3C" name="ttz1_Z3C" value="Z3C" onclick="br_form.AttachStr('.br_attchstr','ttz1_',reg.tfzd_remark1)">附中文譯本）。</td>
	</tr>
	<tr class="br_attchstr">
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttz1_Z2" NAME="ttz1_Z2" value="Z2" onclick="br_form.AttachStr('.br_attchstr','ttz1_',reg.tfzd_remark1)"></td>
		<td class="whitetablebg" colspan="7">申請人於貿易局廠商登記之英文名稱及地址資料或申請人英文名稱及地址其他資料。</td>
	</tr>
	<tr class="br_attchstr">
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttz1_Z9" NAME="ttz1_Z9" value="Z9" onclick="br_form.AttachStr('.br_attchstr','ttz1_',reg.tfzd_remark1)"></td>
		<td class="whitetablebg" colspan="7">其他。<input TYPE="text" id="ttz1_Z9t" NAME="ttz1_Z9t" SIZE="50" onchange="br_form.AttachStr('.br_attchstr','ttz1_',reg.tfzd_remark1)">
		</td>
	</tr>	
	<tr style="display:none">
		<td class=lightbluetable ROWSPAN=2 ><strong>附註：</strong></td>
		<td class=whitetablebg colspan=7>本件商標(標章)於<INPUT type=text id=O_item1 name=O_item1 size=10 class="dateField">(年/月/日)</td>
	</tr>
	<tr style="display:none">
		<td class=whitetablebg colspan=7>另案辦理<INPUT type="radio" id=O_item2FT1 name=O_item2 value="FT1" onclick="reg.O_item21.value = ''">移轉案
													<INPUT type="radio" id=O_item2FL1 name=O_item2 value="FL1" onclick="reg.O_item21.value = ''">授權案
													<INPUT type="radio" id=O_item2FC1 name=O_item2 value="FC1" onclick="reg.O_item21.value = ''">變更案
													<INPUT type="radio" id=O_item2FR1 name=O_item2 value="FR1" onclick="reg.O_item21.value = ''">延展案
													<INPUT type="radio" id=O_item2ZZ name=O_item2 value="ZZ">其他<input type=text id=O_item21 name=O_item21 size=20 maxlength=20>案</TD>
	</tr>
</TABLE>
</div>
<INPUT TYPE=hidden id=tfr_mod_field NAME=tfr_mod_field value="mod_ap">
<INPUT TYPE=text id=tfg1_seq NAME=tfg1_seq>
<INPUT TYPE=text id=tfg1_seq1 NAME=tfg1_seq1>

<script language="javascript" type="text/javascript">
    //程序種類
    br_form.change_no = function (x) {
        if(x=="A"){
            $("#span_no").html("申請");
            $("#no").val($("#O_apply_no").val());
        }else if(x=="I"){
            $("#span_no").html("註冊");
            $("#no").val($("#O_issue_no").val());
        }
    }
	
    //號數
    $("#no").blur(function (e) {
        $("#tfzd_apply_no").val($("#O_apply_no").val());
        $("#tfzd_issue_no").val($("#O_issue_no").val());
        
        if ($("input[name='tfzd_Mark']:checked").val() == "A") {
            $("#tfzd_apply_no").val($(this).val());
        } else if ($("input[name='tfzd_Mark']:checked").val() == "I") {
            $("#tfzd_issue_no").val($(this).val());
        }
    })

    //交辦內容綁定
    br_form.bindFN1 = function () {
        console.log("fn1.br_form.bind");
        if (jMain.case_main.length == 0) {
        } else {
        }
    }
</script>
