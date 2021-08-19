<%@ Control Language="C#" ClassName="opt_back_form" %>

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
<table id=tabreject class="bluetable" border="0" cellspacing="1" cellpadding="2" width="100%">
	<Tr align="center">
	    <TD align="center" colspan="3" class=lightbluetable><font color=red>退&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;回&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;處&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;理</font></TD>
	</tr>
	<Tr>
		<TD align=center class=lightbluetable width="18%"><font color="red">退回原因</font></TD>
		<TD class=whitetablebg>
			<textarea ROWS="5" style="width:82%" id=Preject_reason name=Preject_reason ></textarea>
		</TD>
	</tr>
</table>

<script language="javascript" type="text/javascript">
    var back_form = {};
    back_form.init = function () {
    }
</script>
