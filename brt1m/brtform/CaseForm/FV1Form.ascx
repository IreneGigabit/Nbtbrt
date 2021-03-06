﻿<%@ Control Language="C#" ClassName="FV1Form" %>
<%@ Import Namespace = "System.Collections.Generic"%>

<script runat="server">
    //AC閱案交辦內容
    //父控制項傳入的參數
    public Dictionary<string, string> Lock = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);

    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected string SQL = "";

    protected string ttg1_agt_no = "";
    
    private void Page_Load(System.Object sender, System.EventArgs e) {
        PageLayout();   
        this.DataBind();
    }
    
    private void PageLayout() {
        //代理人
        ttg1_agt_no = Sys.getAgent().Option("{agt_no}", "{agt_no}_{agt_namefull}", " v1='{agt_name1}' {selected}", true);
    }
</script>

<div id="div_Form_FV1">
<%=Sys.GetAscxPath(this.AppRelativeVirtualPath)%>
<TABLE border=0 class=bluetable cellspacing=1 cellpadding=2 width="100%">
	<tr>
		<td class="lightbluetable" valign="top" ><strong>參、代理人</strong></td>
		<td class="whitetablebg" colspan="7" >
		    <select id="ttg1_agt_no" NAME="ttg1_agt_no"><%#ttg1_agt_no%></select>
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
			<input type=radio name=tfzd_Mark class="onoff" value="A" onclick="br_form.change_no('A')">申請
			<input type=radio name=tfzd_Mark class="onoff" value="I" onclick="br_form.change_no('I')">註冊
			<input type=radio name=tfzd_Mark class="onoff" value="R" onclick="br_form.change_no('R')">核駁
		</TD>					
	</tr>
	<tr>
		<td class=lightbluetable align=right ><span id=span_no></span>號數：</td>
		<td class=whitetablebg colspan="3"><input type="text" id="no" name="no" value="" size="20" maxlength="20"></TD>
		<td class=lightbluetable align=right >商標名稱：</td>
		<td class=whitetablebg colspan="3"><input type="text" id="fr_appl_name" name="fr_appl_name" class="onoff" value="" size="50" maxlength="100" onchange="reg.tfzd_appl_name.value=this.value">
		<input type="hidden" value="" id=fr_issue_no name=fr_issue_no>
        </TD>
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
		<td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:pointer;COLOR:BLUE" ONCLICK="PMARK(vread_reason)"><strong>肆、<u>閱卷理由</u></strong></td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"></td>
		<td class=whitetablebg colspan=7 width=100><TEXTAREA rows=5 cols=60 id=tfg1_tran_remark1 name=tfg1_tran_remark1></TEXTAREA></TD>
	</tr>				
	<tr>
	 	<td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:pointer;COLOR:BLUE" ONCLICK="PMARK(zAttech)"><strong>伍、<u>附件</u></strong>
	 	</td>
	</tr>	
	<tr class="br_attchstr">
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttz1_Z1" NAME="ttz1_Z1" value="Z1" onclick="br_form.AttachStr('.br_attchstr','ttz1_',reg.tfzd_remark1)"></td>
		<td class="whitetablebg" colspan="7">申請人證明文件(<input type=checkbox id="ttz1_Z1C" name="ttz1_Z1C" value="Z1C" onclick="br_form.AttachStr('.br_attchstr','ttz1_',reg.tfzd_remark1)">外文者應附中譯本)。</td>
	</tr>
	<tr class="br_attchstr">
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttz1_Z2" NAME="ttz1_Z2" value="Z2" onclick="br_form.AttachStr('.br_attchstr','ttz1_',reg.tfzd_remark1)"></td>
		<td class="whitetablebg" colspan="7">申請人之代理人委任書(<input type=checkbox id="ttz1_Z2C" name="ttz1_Z2C" value="Z2C" onclick="br_form.AttachStr('.br_attchstr','ttz1_',reg.tfzd_remark1)">附中譯本）。</td>
	</tr>
	<tr class="br_attchstr">
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttz1_Z9" NAME="ttz1_Z9" value="Z9" onclick="br_form.AttachStr('.br_attchstr','ttz1_',reg.tfzd_remark1)"></td>
		<td class="whitetablebg" colspan="7">其他。</td>
	</tr>	
</TABLE>
</div>
<INPUT TYPE=hidden id=tfg1_seq NAME=tfg1_seq>
<INPUT TYPE=hidden id=tfg1_seq1 NAME=tfg1_seq1>

<script language="javascript" type="text/javascript">
    //程序種類
    br_form.change_no = function (x) {
        if(x=="A"){
            $("#span_no").html("申請");
            $("#no").val($("#O_apply_no").val());
        }else if(x=="I"){
            $("#span_no").html("註冊");
            $("#no").val($("#O_issue_no").val());
        }else if(x=="R"){
            $("#span_no").html("核駁");
            $("#no").val($("#O_rej_no").val());
        }
    }
	
    //號數
    $("#no").blur(function (e) {
        $("#tfzd_apply_no").val($("#O_apply_no").val());
        $("#tfzd_issue_no").val($("#O_issue_no").val());
        $("#tfzd_rej_no").val($("#O_rej_no").val());
        
        if($("input[name='tfzd_Mark']:checked").val() == "A"){
            $("#tfzd_apply_no").val($(this).val());
        }else if($("input[name='tfzd_Mark']:checked").val() == "I"){
            $("#tfzd_issue_no").val($(this).val());
        }else if($("input[name='tfzd_Mark']:checked").val() == "R"){
            $("#tfzd_rej_no").val($(this).val());
        }
    })

    //交辦內容綁定
    br_form.bindFV1 = function () {
        console.log("fv1.br_form.bind");
        if (jMain.case_main.length == 0) {
        } else {
            $("#ttg1_agt_no").val(jMain.case_main[0].agt_no);//代理人
            $("#tfzd_agt_no").val(jMain.case_main[0].agt_no);
            //程序種類
            $("input[name='tfzd_Mark'][value='" + jMain.case_main[0].temp_mark + "']").prop("checked", true).triggerHandler("click");
            //號數
            if (jMain.case_main[0].temp_mark == "A") {
                $("#no").val(jMain.case_main[0].apply_no);
            } else if (jMain.case_main[0].temp_mark == "I") {
                $("#no").val(jMain.case_main[0].issue_no);
            } else if (jMain.case_main[0].temp_mark == "R") {
                $("#no").val(jMain.case_main[0].rej_no);
            }
            $("#fr_appl_name").val(jMain.case_main[0].appl_name);//商標名稱
            $("#fr_issue_no").val(jMain.case_main[0].issue_no);//註冊號
            //商標種類
            $("input[name=fr_S_Mark][value='" + jMain.case_main[0].s_mark + "']").prop("checked", true);
            $("#tfg1_tran_remark1").val(jMain.case_main[0].tran_remark1);//閱卷理由
            //**附件
            $("#tfzd_remark1").val(jMain.case_main[0].remark1);
            if (jMain.case_main[0].remark1 != "") {
                var arr_remark1 = jMain.case_main[0].remark1.split("|");
                for (var i = 0; i < arr_remark1.length; i++) {
                    $("#ttz1_" + arr_remark1[i]).prop("checked", true);
                }
            }
        }
    }
</script>
