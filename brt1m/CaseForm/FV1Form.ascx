<%@ Control Language="C#" ClassName="FV1Form" %>
<%@ Import Namespace = "System.Collections.Generic"%>

<script runat="server">
    //閱案交辦內容
    //父控制項傳入的參數
    public Dictionary<string, string> Lock = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    
    protected string prgid = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string SQL = "";

    protected string tfzd_agt_no = "";
    
    private void Page_Load(System.Object sender, System.EventArgs e) {
        PageLayout();   
        this.DataBind();
    }
    
    private void PageLayout() {
        //代理人
        tfzd_agt_no = Sys.getAgent().Option("{agt_no}", "{agt_no}_{agt_namefull}", " v1='{agt_name1}' {selected}", true);
    }
</script>

<%=Sys.GetAscxPath(this)%>
<TABLE border=0 class=bluetable cellspacing=1 cellpadding=2 width="100%">
	<tr>
		<td class="lightbluetable" valign="top" ><strong>參、代理人</strong></td>
		<td class="whitetablebg" colspan="7" >
		    <select id="tfzd_agt_no" NAME="tfzd_agt_no"><%#tfzd_agt_no%></select>
		</td>
	</tr>
	<tr>
		<td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:pointer;COLOR:BLUE" ONCLICK="PMARK(vAppl_name)">
            <strong>壹、<u>號數（前商標局核准註冊【係於大陸註冊之商標】，請於號數前加註「前商標局」字樣）</u></strong>
		</td>
	</tr>
	<tr>
		<td class=lightbluetable align=right >程序種類：</td>
		<td class=whitetablebg colspan="7">
			<input type=radio name=tfzd_Mark value="A" onclick="change_no('A')">申請
			<input type=radio name=tfzd_Mark value="I" onclick="change_no('I')">註冊
			<input type=radio name=tfzd_Mark value="R" onclick="change_no('R')">核駁
		</TD>					
	</tr>
	<tr>
		<td class=lightbluetable align=right ><span id=span_no></span>號數：</td>
		<td class=whitetablebg colspan="3"><input type="text" id="no" name="no" value="" size="20" maxlength="20" onchange="reg.tfzd_issue_no.value=reg.fr_issue_no.value"></TD>
		<td class=lightbluetable align=right >商標名稱：</td>
		<td class=whitetablebg colspan="3"><input type="text" id="fr_Appl_name name="fr_Appl_name" value="" size="50" maxlength="100" onchange="reg.tfzd_Appl_name.value=this.value">
		<input type="hidden" value="" id=fr_issue_no name=fr_issue_no>
        </TD>
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
	<tr>
		<td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:pointer;COLOR:BLUE" ONCLICK="PMARK(s1Claim1)"><strong>伍、<u>簽章及具結</u></strong></td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tfg1_mod_claim1" NAME="tfg1_mod_claim1" value="Y"></td>
		<td class="whitetablebg" colspan="7">一、註冊證遺失聲明：本件註冊商標/標章註冊證確實遺失。</td>
	</tr>
    <tr>
		<td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:pointer;COLOR:BLUE" ONCLICK="PMARK(zAttech)"><strong><u>附件</u></strong>
            <input type="text" id="tfzd_remark1" name="tfzd_remark1">
		</td>
	</tr>
	<tr style="display:none" class="br_attchstr">
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttz1_Z1" NAME="ttz1_Z1" value="Z1" onclick="br_form.AttachStr()"></td>
		<td class="whitetablebg" colspan="7">原註冊證。</td>
	</tr>
	<tr class="br_attchstr">
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttz1_Z2" NAME="ttz1_Z2" value="Z2" onclick="br_form.AttachStr()"></td>
		<td class="whitetablebg" colspan="7">委任書(<input type="checkbox" id="ttz1_Z2C" name="ttz1_Z2C" value="Z2C" onclick="br_form.AttachStr()">附中文譯本)。</td>
	</tr>
	<tr class="br_attchstr">
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttz1_Z3" NAME="ttz1_Z3" value="Z3" onclick="br_form.AttachStr()"></td>
		<td class="whitetablebg" colspan="7">浮貼商標圖樣2張。</td>
	</tr>
	<tr class="br_attchstr">
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttz1_Z9" NAME="ttz1_Z9" value="Z9" onclick="br_form.AttachStr()"></td>
		<td class="whitetablebg" colspan="7">其他。<input TYPE="text" id="ttz1_Z9t" NAME="ttz1_Z9t" SIZE="50" onchange="br_form.AttachStr()">
		</td>
	</tr>	
	<tr style="display:none">
		<td class=lightbluetable  ROWSPAN=2 ><strong>附註：</strong></td>
		<td class=whitetablebg colspan=7>本件商標(標章)於<INPUT type=text id=O_item1 name=O_item1 size=10 class="dateField">(年/月/日)</td>
	</tr>
	<tr style="display:none">		  
		<td class=whitetablebg colspan=7>另案辦理<INPUT type="radio" id=O_item2FT1 name=O_item2 value="FT1">移轉案
													<INPUT type="radio" id=O_item2FL1 name=O_item2 value="FL1">授權案
													<INPUT type="radio" id=O_item2FC1 name=O_item2 value="FC1">變更案
													<INPUT type="radio" id=O_item2FR1 name=O_item2 value="FR1">延展案</TD>
	</tr>
</TABLE>


<INPUT TYPE=text id=tfr_mod_field NAME=tfr_mod_field value="mod_ap">
<INPUT TYPE=text id=tfg1_seq NAME=tfg1_seq>
<INPUT TYPE=text id=tfg1_seq1 NAME=tfg1_seq1>

<script language="javascript" type="text/javascript">
    var br_form = {};
    br_form.init = function () {
    }

    //附件
    br_form.AttachStr = function () {
        var strRemark1 = "";
        $(".br_attchstr :checkbox").each(function (index) {
            var $this = $(this);
            if ($this.prop("checked")) {
                strRemark1 += $this.val()
                //其他文件輸入框
                if ($("#ttz1_" + $this.val() + "t").length > 0) {
                    if ($("#ttz1_" + $this.val() + "t").val() != "") {
                        strRemark1 += "|Z9-" + $("#ttz1_" + $this.val() + "t").val() + "-Z9";
                    }
                }
                strRemark1 += "|";
            }
        });
        reg.tfzd_remark1.value = strRemark1;
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
        //切換後重新綁資料
        br_form.bind();
    }
</script>
