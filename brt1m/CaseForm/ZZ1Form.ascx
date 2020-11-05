<%@ Control Language="C#" ClassName="ZZ1Form" %>
<%@ Import Namespace = "System.Collections.Generic"%>

<script runat="server">
    //ZZ交辦內容
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

<div id="div_Form_ZZ1">
<%=Sys.GetAscxPath(this)%>
<TABLE border=0 class=bluetable cellspacing=1 cellpadding=2 width="100%">
	<tr>
		<td class="lightbluetable" valign="top" ><strong>壹、代理人(代碼)</strong></td>
		<td class="whitetablebg" colspan="7" >
		    <select id="tfg1_agt_no1" NAME="tfg1_agt_no1"><%#tfg1_agt_no1%></select>
		</td>
	</tr>
	<tr id="tr_zz" style="display:">
		<td class="lightbluetable" align="right">承辦內容說明</td>
		<td class="whitetablebg" colspan="7"><TEXTAREA rows=15 cols=80 id=tfg1_tran_remark1 name=tfg1_tran_remark1></TEXTAREA></td>
	</tr>
	<tr id="tr_fw1" style="display:none">
		<td colspan=8 class='sfont9'>
		    <table border="0" class="bluetable" cellspacing="1" cellpadding="1" style="font-size: 9pt" width="100%">
		    <tr>
			    <td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:pointer;COLOR:BLUE" ONCLICK="PMARK(fw1remark)">
                    <strong>肆、<u>自請撤回聲明</u></strong>
                </td>
		    </tr>
		    <tr  >
			    <td class="lightbluetable" align="right"><input type=checkbox id="tfw1_mod_claim1" name="tfw1_mod_claim1" value="Y" checked></td>
			    <td class="whitetablebg" colspan="7">本申請案自請撤回。</td>
		    </tr>
		    <tr >
			    <td class="lightbluetable" align="right">其他聲明事項</td>
			    <td class="whitetablebg" colspan="7"><TEXTAREA rows=15 cols=80 id=tfw1_tran_remark1 name=tfw1_tran_remark1></TEXTAREA></td>
		    </tr>	
		    <tr>
			    <td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:pointer;COLOR:BLUE" ONCLICK="PMARK(FW1mark)">
                    <strong><u>附件</u></strong><input TYPE="hidden" NAME="tfw1_other_item" id="tfw1_other_item">
			    </td>
		    </tr>
		    <tr class="br_attchstrZZ1">
			    <td class="lightbluetable" align="right"><input type="checkbox" name="tfw1_Z1" id="tfw1_Z1" value="Z1" onclick="br_form.AttachStr('.br_attchstrZZ1','tfw1_',reg.tfw1_other_item)"></td>
			    <td class="whitetablebg" colspan="7">委任書（<input type="checkbox" name="tfw1_Z1C" id="tfw1_Z1C" value="Z1C" onclick="br_form.AttachStr('.br_attchstrZZ1','tfw1_',reg.tfw1_other_item)">附中文譯本）。</td>
		    </tr>
		    </table>
		</td>
	</tr>
</table>
</div>
<INPUT TYPE=hidden id=tfr_mod_field NAME=tfr_mod_field value="mod_ap">
<INPUT TYPE=text id=tfg1_seq NAME=tfg1_seq>
<INPUT TYPE=text id=tfg1_seq1 NAME=tfg1_seq1>

<script language="javascript" type="text/javascript">
    //交辦內容綁定
    br_form.bindZZ1 = function () {
        console.log("zz1.br_form.bind");
        if (jMain.case_main.length == 0) {
        } else {
            $("#tfg1_agt_no1").val(jMain.case_main[0].agt_no);
            //承辦內容說明
            $("#tfg1_tran_remark1").val(jMain.case_main[0].tran_remark1);
            //自請撤回聲明
            $("input[name=tfw1_mod_claim1][value='" + jMain.case_main[0].mod_claim1 + "']").prop("checked", true);
            //其他聲明事項
            $("#tfw1_tran_remark1").val(jMain.case_main[0].tran_remark1);
            //**附件
            $("#tfw1_other_item").val(jMain.case_main[0].other_item);
            if (jMain.case_main[0].other_item != "") {
                var arr_remark1 = jMain.case_main[0].other_item.split("|");
                for (var i = 0; i < arr_remark1.length; i++) {
                    //var str="Z3|Z9|Z9-具結書正本、讓與人之負責人身份證影本-Z9|";
                    //var str = "Z9-具結書正本、讓與人之負責人身份證影本-Z9";
                    $("#tfw1_" + arr_remark1[i]).prop("checked", true);
                }
            }
        }
    }
</script>
