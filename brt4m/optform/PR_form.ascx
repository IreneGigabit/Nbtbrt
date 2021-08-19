<%@ Control Language="C#" ClassName="opt_pr_form" %>

<script runat="server">
    protected string prgid = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string SQL = "";
    protected string branch = "";
    protected string opt_sqlno = "";
    protected string case_no = "";

    protected string html_pr_per = "";
  
    private void Page_Load(System.Object sender, System.EventArgs e) {
        branch = Request["branch"] ?? "";
        opt_sqlno = Request["opt_sqlno"] ?? "";
        case_no = Request["case_no"] ?? "";
        
        using (DBHelper connopt = new DBHelper(Conn.optK, false)) {
            html_pr_per = Sys.getCustCode(connopt, "Opr_per", "", "sortfld").Option("{cust_code}", "{code_name}");
        }

        this.DataBind();
    }
</script>

<%=Sys.GetAscxPath(this)%>
<table border="0" id="tabPR" class="bluetable" cellspacing="1" cellpadding="2" style="font-size: 9pt" width="100%">		
	<Tr>
		<TD align=center colspan=4 class=lightbluetable1><font color="white">承&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;辦&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;內&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;容</font></TD>
	</TR>
	<TR id="tr_pr_date">
		<td class="lightbluetable"  align="right" nowrap>承辦完成日期 :</td>
		<td class="whitetablebg"  align="left" colspan=3>
			<input type="text" id="pr_date" name="pr_date" SIZE=10 maxlength="10" class="QLock">
		</td>
	</TR>
	<TR>
		<td class="lightbluetable"  align="right" nowrap>承辦時數 :</td>
		<td class="whitetablebg"  align="left" >
			<input type="text" id="Pr_hour" name="Pr_hour" SIZE=3 maxlength="5" class="BLock">
		</td>
		<td class="lightbluetable" width="10%" align="right" nowrap>承辦完成百分比 :</td>
		<td class="whitetablebg"  align="left">
			<SELECT name="pr_per" id="pr_per" class="BLock"><%#html_pr_per%></SELECT>
		</td>
	</TR>
	<Tr>
		<td class="lightbluetable" align="right">承辦說明 :</td>
		<TD class=whitetablebg colspan=3>
			<textarea ROWS="6" style="width:90%" id=Pr_remark name="Pr_remark" class="BLock"></textarea>
		</TD>
	</tr>
</table>

<script language="javascript" type="text/javascript">
    var pr_form = {};
    pr_form.init = function () {
        //$("#pr_per").getOption({//承辦完成百分比
        //    url: getRootPath() + "/ajax/JsonGetSqlData.aspx",
        //    data: { sql: "Select cust_code,code_name from cust_code where code_type='Opr_per' order by sortfld" },
        //    valueFormat: "{cust_code}",
        //    textFormat: "{code_name}",
        //    showEmpty: false,
        //});

        pr_form.loadOpt();
        //$(".LockB").lock($("#Back_flag").val() == "B"||$("#submittask").val() == "Q");
    }

    pr_form.loadOpt = function () {
        var jOpt = br_opt.opt[0];
        $("#Pr_hour").val(jOpt.pr_hour);
        $("#pr_per").val(jOpt.pr_per);
        $("#Pr_remark").val(jOpt.pr_remark);

        if ($("#End_flag").val() == "Y") {//結辦
            $("#pr_date").val((new Date()).format("yyyy/M/d"));
        } else {
            $("#pr_date").val(dateReviver(jOpt.bpr_date, "yyyy/M/d"));
        }

        $("#tr_pr_date").showFor($("#submittask").val() == "Q");
    }

    $("#Pr_hour").blur(function () {
        chkNum1($(this)[0], "承辦時數");
    });

    $("#pr_per").blur(function () {
        chkNum1($(this)[0], "承辦完成百分比");
    });
</script>
