<%@ Control Language="C#" ClassName="FFform" %>
<%@ Import Namespace = "System.Collections.Generic"%>

<script runat="server">
    //新申請案交辦內容
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

<%=Sys.GetAscxPath(this)%>
<TABLE border=0 class=bluetable cellspacing=1 cellpadding=2 width="100%">
	<tr>
		<td class="lightbluetable" valign="top" ><strong>參、代理人</strong></td>
		<td class="whitetablebg" colspan="7" >
            <input type="hidden" id="tfzd_agt_no" name="tfzd_agt_no">
		    <select id="tfg1_agt_no1" NAME="tfg1_agt_no1"><%#tfg1_agt_no1%></select>
		</td>
	</tr>
	<tr>
		<td class=lightbluetable align=right>繳費金額：</TD>
		<td class=whitetablebg colspan="7">
            <span id=span_issue_money></span>註冊費：新臺幣　
            <input type="text" name="fr_fees" id="fr_fees" size="8" class=sedit readonly>元
		</TD>
	</tr>
    <tr>
		<td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:pointer;COLOR:BLUE" ONCLICK="PMARK(vAppl_name)">
            <strong>壹、號數（前商標局核准註冊【係於大陸註冊之商標】，請於號數前加註「前商標局」字樣）</strong>
		</td>
	</tr>

	<tr>
		<td class=lightbluetable align=right id=no1 >申請號數：</td>
		<td class=whitetablebg colspan="3" id=no2 ><input type="text" name="fr_apply_no" id="fr_apply_no" value="" size="20" maxlength="20" onchange="reg.tfzd_apply_no.value=reg.fr_apply_no.value"></TD>
		<td class=lightbluetable align=right id=no3 style="display:none">註冊號數：</td>
		<td class=whitetablebg colspan="3" id=no4 style="display:none"><input type="text" name="fr_issue_no" id="fr_issue_no" value="" size="20" maxlength="20" onchange="reg.tfzd_issue_no.value=reg.fr_issue_no.value"></TD>
		<td class=lightbluetable align=right >商標名稱：</td>
		<td class=whitetablebg colspan="3"><input type="text" name="fr_Appl_name" id="fr_Appl_name" value="" size="50" maxlength="100" onchange="reg.tfzd_Appl_name.value=reg.fr_Appl_name.value"></TD>
	</tr>
	<tr>
		<td class=lightbluetable align=right >商標種類：</td>
		<td class="whitetablebg" colspan=7>
            <input type="radio" name="fr_S_Mark" value="" onclick="dmt_form.change_mark(1)">商標
			<span id="smark2" style="display:none">
            <input type="radio" name="fr_S_Mark" value="S" onclick="dmt_form.change_mark(1)">92年修正前服務標章
			</span>
            <input type="radio" name="fr_S_Mark" value="N" onclick="dmt_form.change_mark(1)">團體商標
            <input type="radio" name="fr_S_Mark" value="M" onclick="dmt_form.change_mark(1)">團體標章
            <input type="radio" name="fr_S_Mark" value="L" onclick="dmt_form.change_mark(1)">證明標章
		</TD>
	</tr>
	<tr>
		<td class=lightbluetable align=right >類別：</td>
		<td class=whitetablebg colspan="7">
			<input type=text name=fr_class id=fr_class value="" class="sedit" readonly>
		</td>
	</tr>
</TABLE>

<TABLE id=tabrem4 style="display:none" border=0 class="bluetable" cellspacing=1 cellpadding=2 width="100%">
	<tr>
		<td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:pointer;COLOR:BLUE" ><strong>附件：請勾註所檢附之文件</strong>
            <input type="hidden" id="tfzd_remark1" name="tfzd_remark1">
		</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="FF4_Z1" NAME="FF4_Z1" value="Z1" onclick="br_form.AttachStr()"></td>
		<td class="whitetablebg" colspan="7">委任書(<input TYPE="checkbox" id="FF4_Z1C" NAME="FF4_Z1C" value="Z1C" onclick="br_form.AttachStr()">附中文譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="FF4_Z2" NAME="FF4_Z2" value="Z2" onclick="br_form.AttachStr()"></td>
		<td class="whitetablebg" colspan="7">繳費資料(劃撥收據、即期票據如支票、本票、匯票等)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="FF4_Z9" NAME="FF4_Z9" value="Z9" onclick="br_form.AttachStr()"></td>
		<td class="whitetablebg" colspan="7">其他證明文件。<input TYPE="text" id="FF4_Z9t" NAME="FF4_Z9t" SIZE="50" onchange="br_form.AttachStr()"></td>
	</tr>
</table>
<INPUT TYPE=hidden id=tfg1_seq NAME=tfg1_seq>
<INPUT TYPE=hidden id=tfg1_seq1 NAME=tfg1_seq1>

<script language="javascript" type="text/javascript">
    var br_form = {};
    br_form.init = function () {
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
        reg.tfz1_remark1.value = strRemark1;
    }

    //交辦內容綁定
    br_form.bind = function () {
        //console.log("br_form.bind");
        if (jMain.case_main.length == 0) {
        } else {
            $("#tfg1_agt_no1").val(jMain.case_main[0].agt_no);//*出名代理人代碼
            $("#tfzd_agt_no").val(jMain.case_main[0].agt_no);//*出名代理人代碼
            //**繳費金額
            if ($("#tfy_Arcase").val() == "FF0") {
                $("#span_issue_money").html("全期(第一至第十年)");
            } else if ($("#tfy_Arcase").val() == "FF1") {
                $("#span_issue_money").html("第一期(第一至第三年)");
            } else if ($("#tfy_Arcase").val() == "FF2") {
                $("#span_issue_money").html("第二期(第四至第十年)");
            } else if ($("#tfy_Arcase").val() == "FF3") {
                $("#span_issue_money").html("加倍繳納第二期(第四至第十年)");
            }
            $("#fr_Fees").val(jMain.case_main[0].fees);
           
            $("#fr_apply_no").val(jMain.case_main[0].apply_no);//申請號數
            $("#fr_issue_no").val(jMain.case_main[0].issue_no);//註冊號
            $("#fr_Appl_name").val(jMain.case_main[0].appl_name);//商標名稱
            //商標種類
            $("input[name=fr_S_Mark][value='" + jMain.case_main[0].S_mark + "']").prop("checked", true);
            //類別
            $("#fr_class").val(jMain.case_main[0].class);

            //**附件
            $("#tfzd_remark1").val(jMain.case_main[0].remark1);
            if (jMain.case_main[0].remark1 != "") {
                var arr_remark1 = jMain.case_main[0].remark1.split("|");
                for (var i = 0; i < arr_remark1.length; i++) {
                    //var str="Z3|Z9|Z9-具結書正本、讓與人之負責人身份證影本-Z9|";
                    var str = "Z9-具結書正本、讓與人之負責人身份證影本-Z9";
                    var substr = arr_remark1[i].match(/Z9-(\S+)-Z9/);
                    if (substr != null) {
                        $("#FF4_Z9t").val(substr[1]);
                    } else {
                        $("#FF4_" + arr_remark1[i]).prop("checked", true);
                    }
                }
            }
        }
    }
</script>
