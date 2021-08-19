<%@ Control Language="C#" ClassName="opt_ap_form" %>

<script runat="server">
    protected string prgid = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string SQL = "";
    protected string branch = "";
    protected string opt_sqlno = "";
    
    private void Page_Load(System.Object sender, System.EventArgs e) {
        branch = Request["branch"] ?? "";
        opt_sqlno = Request["opt_sqlno"] ?? "";
        
        this.DataBind();
    }
</script>

<%=Sys.GetAscxPath(this)%>
<table id=tabAP class="bluetable" border="0" cellspacing="1" cellpadding="2" width="100%">
	<Tr>
		<TD align=center colspan=6 class=lightbluetable1><font color="white">判&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;行&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;資&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;料</font></TD>
	</tr>
	<TR>
		<td class="lightbluetable"  align="right" nowrap width="10%">承辦時數：</td>
		<td class="whitetablebg"  align="left">
            <input type="text" id="temp_PR_hour" name="temp_PR_hour" class="Lock" size="3">
		</td>
		<td class="lightbluetable"  align="right" nowrap width="10%">核准時數:</td>
		<td class="whitetablebg"  align="left">
			<input type="text" id="PRY_hour" name="PRY_hour" class="ALock" size="3">
		</td>
		<td class="lightbluetable"  align="right" nowrap width="10%">判行核稿時數:</td>
		<td class="whitetablebg"  align="left">
			<input type="text" id="AP_hour" name="AP_hour" class="ALock" size="3">
		</td> 
	</TR>
	<Tr>
		<td class="lightbluetable" align="right" width="14%">判行說明 :</td>
		<TD class=whitetablebg colspan=5>
			<textarea ROWS="6" style="width:90%" id=AP_remark name="AP_remark" class="ALock"></textarea>
		</TD>
	</tr>
</table>


<script language="javascript" type="text/javascript">
    var ap_form = {};
    ap_form.init = function () {
        var jOpt = br_opt.opt[0];
        $("#temp_PR_hour").val(jOpt.pr_hour);
        if (jOpt.pry_hour!="0"){
            $("#PRY_hour").val(jOpt.pry_hour);
        }else{
            $("#PRY_hour").val(jOpt.pr_hour);
        }
        $("#AP_hour").val(jOpt.ap_hour);
        $("#AP_remark").val(jOpt.ap_remark);
    }

    $("#PRY_hour").blur(function (e) {
        chkNum1($(this)[0], "核准時數");
    });

    $("#AP_hour").blur(function (e) {
        chkNum1($(this)[0], "判行時數");
    });
</script>
