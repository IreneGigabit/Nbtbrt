<%@ Control Language="C#" ClassName="opt_qu_form" %>

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
<table id=tabQu class="bluetable" border="0" cellspacing="1" cellpadding="2" width="100%">
	<Tr>
	    <TD align="center" colspan="4" class=lightbluetable1><font color="white">品&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;質&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;評&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;分</font></TD>
	</tr>
	<TR>
		<td class="lightbluetable"  align="right" nowrap>營洽:</td>
		<td class="whitetablebg"  align="left">
			<input type="text" id="score_pr_scode" name="score_pr_scode" size="8" class="Lock">
		</td>
		<td class="lightbluetable"  align="right" nowrap>接洽得分:</td>
		<td class="whitetablebg"  align="left">
				<input type="text" id="Score" name="Score" class="ALock YZLock" size="3">
		</td> 
	</TR>
	<Tr>
		<td class="lightbluetable" align="right" nowrap>案件缺失及評語 :</td>
		<TD class=whitetablebg colspan=3>
			<textarea ROWS="6" style="width:90%" id=opt_Remark name="opt_Remark" class="ALock YZLock"></textarea>
		</TD>
	</tr>
</table>

<script language="javascript" type="text/javascript">
    var qu_form = {};
    qu_form.init = function () {
        var jOpt = br_opt.opt[0];
        $("#score_pr_scode").val(jOpt.scode_name);
        $("#Score").val(jOpt.score);
        $("#opt_Remark").val(jOpt.opt_remark);
    }

    $("#Score").blur(function (e) {
        chkNum1($(this)[0], "接洽得分");
    });
</script>
