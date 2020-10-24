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
		<td class="whitetablebg" colspan="7"><input type="text" id="fr4_Appl_name" name="fr4_Appl_name" value="" size="30" maxlength="100" onchange="reg.tfzd_Appl_name.value=this.value"></td>
	</tr>
	<tr>
		<td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:pointer;COLOR:BLUE" onclick="PMARK(zAttech)"><u>附件：</u><input type="hidden" name=tfzd_remark1 id=tfzd_remark1></td>
	</tr>
	<tr class="br_attchstr">
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttz4_Z1" NAME="ttz4_Z1" value="Z1" onclick="br_form.AttachStr('.br_attchstr','ttz4_',reg.tfzd_remark1)"></td>
		<td class="whitetablebg" colspan="7">委任書（<input TYPE="checkbox" id="ttz4_Z1C" NAME="ttz4_Z1C" value="Z1C" onclick="br_form.AttachStr('.br_attchstr', 'ttz4_', reg.tfzd_remark1)">附中譯本）。</td>
	</tr>
</table>

<script language="javascript" type="text/javascript">
    br_form.init = function () {
        //br_form.Add_class(1);//類別預設顯示第1筆
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
