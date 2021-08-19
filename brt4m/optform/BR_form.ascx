<%@ Control Language="C#" ClassName="opt_br_form" %>

<script runat="server">
    protected string prgid = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string SQL = "";
    protected string submitTask = "";
    protected string branch = "";
    protected string opt_sqlno = "";
    protected string case_no = "";

    protected string pr_branch = "", html_pr_scode="";

    private void Page_Load(System.Object sender, System.EventArgs e) {
        branch = Request["branch"] ?? "";
        opt_sqlno = Request["opt_sqlno"] ?? "";
        case_no = Request["case_no"] ?? "";
        submitTask = Request["submitTask"] ?? "";

        using (DBHelper connopt = new DBHelper(Conn.optK, false)) {
            pr_branch = Sys.getCustCode(connopt, "OBranch", "", "").Option("{cust_code}", "{code_name}", false);
        }
        html_pr_scode = Sys.GetOptPrScode("A").Option("{scode}", "{scode}_{sc_name}");
            
        this.DataBind();
    }
</script>

<%=Sys.GetAscxPath(this)%>
<table border="0" class="bluetable" cellspacing="1" cellpadding="2" width="100%">		
	<Tr>
		<TD align=center colspan=4 class=lightbluetable1><font color="white">分&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;案&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;設&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;定</font></TD>
	</TR>
	<TR>
		<td class="lightbluetable"  align="right" nowrap>預計完成日期 :</td>
		<td class="whitetablebg" colspan=3 >
			<input type="text" id="ctrl_date" name="ctrl_date" SIZE=10 class="dateField RLock">
			<span id="span_last_date0">
			    <font color="blue">區所指定法定期限：</font><font color="red"><span id="span_last_date"></span></font>
			</span>
		</td>
	</TR>
	<TR>
		<td class="lightbluetable"  align="right">承辦區所別 :</td>
		<td class="whitetablebg">
			<Select id="pr_branch" name="pr_branch" class="Lock"><%#pr_branch%></Select>
		</td>
		<td class="lightbluetable"  align="right">承辦人員 :</td>
		<td class="whitetablebg">
			<Select id="pr_scode" name="pr_scode" class="RLock"><%#html_pr_scode%></Select>
		</td>
	</TR>
	<Tr>
		<td class="lightbluetable" align="right">分案說明 :</td>
		<TD class=whitetablebg colspan=3>
			<textarea ROWS="6" style="width:90%" id=Br_remark name="Br_remark" class="RLock"></textarea>
		</TD>
	</tr>
</table>

<script language="javascript" type="text/javascript">
    var br_form = {};
    br_form.init = function () {
        //$("#pr_scode").getOption({//爭議組承辦人員
        //    url: getRootPath() + "/ajax/LookupDataCnn.aspx?type=GetPrScode&submitTask=A",
        //    valueFormat: "{scode}",
        //    textFormat: "{scode}_{sc_name}"
        //});

        if ("<%#submitTask%>" != "ADD") {
            br_form.loadOpt();
        }
        $("#span_last_date0").showFor($("#span_last_date").html()!= "");
    }

    br_form.loadOpt = function () {
        var jOpt = br_opt.opt[0];
        $("#pr_branch").val(jOpt.pr_branch || "B");
        $("#pr_scode").val(jOpt.pr_scode);
        $("#ctrl_date").val(dateReviver(jOpt.ctrl_date, "yyyy/M/d"));
        $("#span_last_date").html(dateReviver(jOpt.last_date, "yyyy/M/d"));

        if (jOpt.ctrl_date == "") {
            var Adate = dateConvert(jOpt.last_date).addDays(-5);
            if (Adate < (new Date()))
                $("#ctrl_date").val(dateReviver(jOpt.last_date, "yyyy/M/d"));
            else
                $("#ctrl_date").val(Adate.format("yyyy/M/d"));
        }
    }
</script>
