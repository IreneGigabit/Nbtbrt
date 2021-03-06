﻿<%@ Control Language="C#" ClassName="BZZ1Form" %>
<%@ Import Namespace = "System.Collections.Generic"%>

<script runat="server">
    //B爭議案交辦內容
    //父控制項傳入的參數
    public Dictionary<string, string> Lock = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);

    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
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

<div id="div_Form_BZZ1">
<%=Sys.GetAscxPath(this.AppRelativeVirtualPath)%>
<INPUT TYPE=hidden id=tfzd_mark name=tfzd_mark value="">
<TABLE border=0 class=bluetable cellspacing=1 cellpadding=2 width="100%">
	<tr>
		<td class="lightbluetable" valign="top" ><strong>壹、代理人(代碼)</strong></td>
		<td class="whitetablebg" colspan="7" >
		    <select id="tfg1_agt_no1" NAME="tfg1_agt_no1"><%#tfg1_agt_no1%></select>
		</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right">承辦內容說明</td>
		<td class="whitetablebg" colspan="7"><TEXTAREA rows=15 cols=80 id=tfg1_tran_remark1 name=tfg1_tran_remark1></TEXTAREA></td>
	</tr>
</table>
</div>
<input type=hidden id=fr_appl_name name=fr_appl_name>
<input type=hidden id=fr_issue_no name=fr_issue_no>

<INPUT TYPE=hidden id=tfr_mod_field NAME=tfr_mod_field value="mod_ap">
<INPUT TYPE=hidden id=tfg1_seq NAME=tfg1_seq>
<INPUT TYPE=hidden id=tfg1_seq1 NAME=tfg1_seq1>

<script language="javascript" type="text/javascript">
    //交辦內容綁定
    br_form.bindBZZ1 = function () {
        console.log("bzz1.br_form.bind");
        if (jMain.case_main.length == 0) {
        } else {
            $("#tfg1_agt_no1").val(jMain.case_main[0].agt_no);//代理人
            $("#tfg1_tran_remark1").val(jMain.case_main[0].tran_remark1);//承辦內容說明
            $("#fr_appl_name").val(jMain.case_main[0].appl_name);//商標名稱
            $("#fr_issue_no").val(jMain.case_main[0].issue_no);//註冊號
        }
    }
</script>
