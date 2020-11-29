<%@ Control Language="C#" ClassName="FI1Form" %>
<%@ Import Namespace = "System.Collections.Generic"%>

<script runat="server">
    //AB補(換)發證交辦內容
    //父控制項傳入的參數
    public Dictionary<string, string> Lock = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    
    protected string prgid = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string SQL = "";

    protected string tfg1_agt_no1 = "";
    
    private void Page_Load(System.Object sender, System.EventArgs e) {
        PageLayout();   
        this.DataBind();
    }
    
    private void PageLayout() {
        //代理人
        tfg1_agt_no1 = Sys.getAgent().Option("{agt_no}", "{agt_no}_{agt_namefull}", " v1='{agt_name1}' {selected}", true);
    }
</script>

<div id="div_Form_FI1">
<%=Sys.GetAscxPath(this)%>
<TABLE border=0 class=bluetable cellspacing=1 cellpadding=2 width="100%">
	<tr>
		<td class="lightbluetable" valign="top" ><strong>參、代理人</strong></td>
		<td class="whitetablebg" colspan="7" >
		    <select id="tfg1_agt_no1" NAME="tfg1_agt_no1"><%#tfg1_agt_no1%></select>
            <!--input type="text" id="tfzd_agt_no" name="tfzd_agt_no"-->
		</td>
	</tr>
	<tr>
		<td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:pointer;COLOR:BLUE" ONCLICK="PMARK(i1Appl_name)">
            <strong>壹、<u>註冊號數、商標(標章)種類及名稱</u></strong>
		</td>
	</tr>
	<tr>
		<td class=lightbluetable align=right >註冊號數：</td>
		<td class=whitetablebg colspan="3"><input type="text" name="fr_issue_no" id="fr_issue_no" class="onoff" value="" size="20" maxlength="20" onchange="reg.tfzd_issue_no.value=this.value"></TD>
		<td class=lightbluetable align=right >商標/標章名稱：</td>
		<td class=whitetablebg colspan="3"><input type="text" name="fr_appl_name" id="fr_appl_name" class="onoff" value="" size="50" maxlength="100" onchange="reg.tfzd_appl_name.value=this.value"></TD>
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
	<tr>
		<td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:pointer;COLOR:BLUE" ONCLICK="PMARK(s1Claim1)"><strong>伍、<u>簽章及具結</u></strong></td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tfg1_mod_claim1" NAME="tfg1_mod_claim1" value="Y"></td>
		<td class="whitetablebg" colspan="7">一、註冊證遺失聲明：本件註冊商標/標章註冊證確實遺失。</td>
	</tr>
    <tr>
		<td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:pointer;COLOR:BLUE" ONCLICK="PMARK(zAttech)"><strong><u>附件</u></strong>
		</td>
	</tr>
	<tr style="display:none" class="br_attchstr">
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttz1_Z1" NAME="ttz1_Z1" value="Z1" onclick="br_form.AttachStr('.br_attchstr','ttz1_',reg.tfzd_remark1)"></td>
		<td class="whitetablebg" colspan="7">原註冊證。</td>
	</tr>
	<tr class="br_attchstr">
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttz1_Z2" NAME="ttz1_Z2" value="Z2" onclick="br_form.AttachStr('.br_attchstr','ttz1_',reg.tfzd_remark1)"></td>
		<td class="whitetablebg" colspan="7">委任書(<input type="checkbox" id="ttz1_Z2C" name="ttz1_Z2C" value="Z2C" onclick="br_form.AttachStr('.br_attchstr','ttz1_',reg.tfzd_remark1)">附中文譯本)。</td>
	</tr>
	<tr class="br_attchstr">
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttz1_Z3" NAME="ttz1_Z3" value="Z3" onclick="br_form.AttachStr('.br_attchstr','ttz1_',reg.tfzd_remark1)"></td>
		<td class="whitetablebg" colspan="7">浮貼商標圖樣2張。</td>
	</tr>
	<tr class="br_attchstr">
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttz1_Z9" NAME="ttz1_Z9" value="Z9" onclick="br_form.AttachStr('.br_attchstr','ttz1_',reg.tfzd_remark1)"></td>
		<td class="whitetablebg" colspan="7">其他。<input TYPE="text" id="ttz1_Z9t" NAME="ttz1_Z9t" SIZE="50" onchange="br_form.AttachStr('.br_attchstr','ttz1_',reg.tfzd_remark1)">
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
</div>
<INPUT TYPE=text id=tfr_mod_field NAME=tfr_mod_field value="mod_ap">
<INPUT TYPE=text id=tfg1_seq NAME=tfg1_seq>
<INPUT TYPE=text id=tfg1_seq1 NAME=tfg1_seq1>

<script language="javascript" type="text/javascript">
    //交辦內容綁定
    br_form.bindFI1 = function () {
        console.log("fi1.br_form.bind");
        if (jMain.case_main.length == 0) {
        } else {
            $("#tfg1_agt_no1").val(jMain.case_main[0].agt_no);//代理人
            $("#tfzd_agt_no").val(jMain.case_main[0].agt_no);//代理人
            $("#fr_issue_no").val(jMain.case_main[0].issue_no);//註冊號
            $("#fr_appl_name").val(jMain.case_main[0].appl_name);//商標名稱
            //商標種類
            $("input[name=fr_S_Mark][value='" + jMain.case_main[0].s_mark + "']").prop("checked", true);
            //遺失聲明
            $("input[name=tfg1_mod_claim1][value='" + jMain.case_main[0].mod_claim1 + "']").prop("checked", true);
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
        }
    }
</script>
