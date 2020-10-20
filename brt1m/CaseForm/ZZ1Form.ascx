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
		<td colspan=8>
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
		    <tr class="br_attchstr">
			    <td class="lightbluetable" align="right"><input type="checkbox" name="tfw1_Z1" id="tfw1_Z1" value="Z1" onclick="br_form.AttachStr()"></td>
			    <td class="whitetablebg" colspan="7">委任書（<input type="checkbox" name="tfw1_Z1C" id="tfw1_Z1C" value="Z1C" onclick="br_form.AttachStr()">附中文譯本）。</td>
		    </tr>
		    </table>
		</td>
	</tr>
</table>

<INPUT TYPE=hidden id=tfr_mod_field NAME=tfr_mod_field value="mod_ap">
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
                if ($("#tfw1_" + $this.val() + "t").length > 0) {
                    if ($("#tfw1_" + $this.val() + "t").val() != "") {
                        strRemark1 += "|Z9-" + $("#tfw1_" + $this.val() + "t").val() + "-Z9";
                    }
                }
                strRemark1 += "|";
            }
        });
        reg.tfw1_other_item.value = strRemark1;
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
