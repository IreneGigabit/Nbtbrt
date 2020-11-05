<%@ Control Language="C#" ClassName="FC4form" %>
<%@ Import Namespace = "System.Collections.Generic"%>

<script runat="server">
    //A6變更案交辦內容
    //父控制項傳入的參數
    public Dictionary<string, string> Lock = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    
    protected string prgid = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string SQL = "";

    protected string ttg4_agt_no = "";
    
    private void Page_Load(System.Object sender, System.EventArgs e) {
        PageLayout();
        this.DataBind();
    }
    
    private void PageLayout() {
        //代理人
        ttg4_agt_no = Sys.getAgent().Option("{agt_no}", "{agt_no}_{agt_namefull}", " v1='{agt_name1}' {selected}", true);
    }
</script>

<div id="div_Form_FC4">
<%=Sys.GetAscxPath(this)%>
<TABLE border=0 class=bluetable cellspacing=1 cellpadding=2 width="100%">
	<tr>
		<td class="lightbluetable" valign="top"><strong>※、代理人(代碼)</strong></td>
		<td class="whitetablebg" colspan="7" valign="top">
		    <select id="ttg4_agt_no" NAME="ttg4_agt_no"><%#ttg4_agt_no%></select>
		</td>
	</tr>
	<tr>
		<td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:pointer;COLOR:BLUE" onclick="PMARK(c4Appl_name)"><strong>壹、<u>註冊號數、商標/標章名稱</u></strong></td>
	</tr>
	<tr>
		<td class=lightbluetable align=right >商標種類：</td>
		<td class=whitetablebg colspan="7">
			<input type=radio name=fr4_S_Mark value="" onclick="dmt_form.change_mark(1, this)">防護商標
			<input type=radio name=fr4_S_Mark value="S" onclick="dmt_form.change_mark(1, this)">92年修正前防護服務標章
		</TD>
	</tr>
	<tr>	
		<td class="lightbluetable" align="right">註冊號數：</td>
		<td class="whitetablebg" colspan="7" ><input type="text" id="fr4_issue_no" name="fr4_issue_no" value="" size="20" maxlength="20" onchange="reg.tfzd_issue_no.value=this.value"></td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right">商標/標章名稱：</td>
		<td class="whitetablebg" colspan="7"><input type="text" id="fr4_appl_name" name="fr4_Appl_name" value="" size="30" maxlength="100" onchange="reg.tfzd_appl_name.value=this.value"></td>
	</tr>
	<tr>
		<td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:pointer;COLOR:BLUE" onclick="PMARK(zAttech)"><u>附件：</u></td>
	</tr>
	<tr class="br_attchstrFC4">
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttz4_Z1" NAME="ttz4_Z1" value="Z1" onclick="br_form.AttachStr('.br_attchstrFC4','ttz4_',reg.tfzd_remark1)"></td>
		<td class="whitetablebg" colspan="7">委任書（<input TYPE="checkbox" id="ttz4_Z1C" NAME="ttz4_Z1C" value="Z1C" onclick="br_form.AttachStr('.br_attchstrFC4', 'ttz4_', reg.tfzd_remark1)">附中譯本）。</td>
	</tr>
</table>
</div>

<script language="javascript" type="text/javascript">
    //交辦內容綁定
    br_form.bindFC4 = function () {
        console.log("fc4.br_form.bind");
        if (jMain.case_main.length == 0) {
        } else {
            //代理人
            $("#ttg4_agt_no").val(jMain.case_main[0].agt_no);
            if (jMain.case_main[0].pul=="2"){
                $("input[name=fr4_S_Mark][value='" + jMain.case_main[0].s_mark + "']").prop("checked", true);
            }
            $("#fr4_issue_no").val(jMain.case_main[0].issue_no);//註冊號
            $("#fr4_appl_name").val(jMain.case_main[0].appl_name);//商標名稱
            //附件
            $("#tfzd_remark1").val(jMain.case_main[0].remark1);
            if (jMain.case_main[0].remark1 != "") {
                var arr_remark1 = jMain.case_main[0].remark1.split("|");
                for (var i = 0; i < arr_remark1.length; i++) {
                    $("#ttz4_" + arr_remark1[i]).prop("checked", true);
                }
            }
        }
    }
</script>
