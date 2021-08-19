<%@ Control Language="C#" ClassName="opt_bzz1_form" %>

<script runat="server">
    protected string prgid = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string SQL = "";
    protected string branch = "";
    protected string opt_sqlno = "";

    protected string html_Pagt_no = "";
    
    private void Page_Load(System.Object sender, System.EventArgs e) {
        branch = Request["branch"] ?? "";
        opt_sqlno = Request["opt_sqlno"] ?? "";

        html_Pagt_no = Sys.getAgent().Option("{agt_no}", "{strcomp_name}{agt_name}");
        
        this.DataBind();
    }
</script>

<%=Sys.GetAscxPath(this)%>
<table border="0" class="bluetable" cellspacing="1" cellpadding="2" width="100%">
	<tr>
		<td class="lightbluetable" valign="top" width="20%"><strong>壹、代理人(代碼)</strong></td>
		<td class="whitetablebg" colspan="7" valign="top">
		<select id=Pagt_no name=Pagt_no class="QLock"><%#html_Pagt_no%></select>
		</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right">承辦內容說明</td>
		<td class="whitetablebg" colspan="7">
            <TEXTAREA rows=15 cols=80 id=Ptran_remark1 name=Ptran_remark1 class="PLock"></TEXTAREA>
		</td>
	</tr>
</table>

<script language="javascript" type="text/javascript">
    var tran_form = {};
    tran_form.init = function () {
        //$("#Pagt_no").getOption({//代理人
        //    url: getRootPath() + "/ajax/LookupDataBranch.aspx",
        //    data: { type: "getagtdata", branch: "<%#branch%>" },
        //    valueFormat: "{agt_no}",
        //    textFormat: "{strcomp_name}{agt_name}"
        //});

        var jOpt = br_opt.opt[0];
        var jTran = br_opt.tran[0];
        $("#Pagt_no").val(jTran.agt_no1 == "" ? jOpt.agt_no : jTran.agt_no1);
        $("#Ptran_remark1").val(jTran.tran_remark1);
    }
</script>
