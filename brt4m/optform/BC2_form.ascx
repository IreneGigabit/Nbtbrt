<%@ Control Language="C#" ClassName="opt_bc2_form" %>

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
		<td class="lightbluetable" valign="top"><strong>※、代理人</strong></td>
		<td class="whitetablebg" colspan="3" valign="top">
		    <select id=Pagt_no NAME=Pagt_no class="QLock"><%#html_Pagt_no%></select>
		</td>
	</tr>
	<tr>
		<td class="lightbluetable" colspan="4" valign="top" width="20%"><strong>壹、申請<span id="span_case">舉行</span>聽證的案件</strong></td>
	</tr>
	<tr>
		<td class=lightbluetable align=right>商標種類：</td>
		<td class=whitetablebg colspan="3" >
			<input type=radio name=PS_Mark value=""  class="QLock">商標
			<input type=radio name=PS_Mark value="S" class="QLock">92年修正前服務標章
			<input type=radio name=PS_Mark value="N" class="QLock">團體商標
			<input type=radio name=PS_Mark value="M" class="QLock">團體標章
			<input type=radio name=PS_Mark value="L" class="QLock">證明標章
		</TD>
	</tr>
	<tr>
		<td class=lightbluetable align=right width="20%">註冊號數：</td>
		<td class=whitetablebg width="30%">
			<input type="text" id="Pissue_no" name="Pissue_no" size="20" maxlength="20" class="QLock">
		</TD>
		<td class=lightbluetable align=right width="20%">商標/標章名稱：</td>
		<td class=whitetablebg width="30%">
			<input type="text" id="PAppl_name" name="PAppl_name" size="40" maxlength="100" class="QLock">
		</TD>
	</tr>
	<tr>
		<td class=lightbluetable align=right >案件種類：</td>
		<td class=whitetablebg colspan="3">
			<input type=radio name=Premark3 value="DI1" class="PLock">評定案件
			<input type=radio name=Premark3 value="DO1" class="PLock">異議案件
			<input type=radio name=Premark3 value="DR1" class="PLock">廢止案件
		</TD>
	</tr>
	<tr>
		<td class="lightbluetable" colspan="4" valign="top" width="20%"><strong>貳、申請人</strong></td>
	</tr>
	<tr>
		<td class=lightbluetable align=right >種　　類：</td>
		<td class=whitetablebg colspan="3">
				<input type=radio name=PMark value="B" class="PLock">爭議案申請人或異議人
				<input type=radio name=PMark value="I" class="PLock">系爭商標商標權人
				<input type=radio name=PMark value="R" class="PLock">利害關係人
		</TD>
	</tr>
	<tr>
		<td class="lightbluetable" colspan="4" valign="top" width="20%"><strong>參、出席代表姓名或代理姓名</strong></td>
	</tr>
	<tr>
		<td class=lightbluetable align=right><span id="span_other_item">指定發言姓名</span>：</td>
		<td class=whitetablebg colspan="3">
			<input type=text id=Pother_item name=Pother_item size="55" maxlength="50" class="PLock">
		</TD>
	</tr>
	<tr>
		<td class=lightbluetable align=right>職　　稱：</td>
		<td class=whitetablebg colspan="3">
			<input type=text id=Pother_item1 name=Pother_item1 size="55" maxlength="50" class="PLock">
		</TD>
	</tr>
	<tr>
		<td class=lightbluetable align=right><span id="span_other_item2">聯絡電話</span>：</td>
		<td class=whitetablebg colspan="3">
			<input type=text name=Pother_item2 name=Pother_item2 size="33" maxlength="30" class="PLock">
		</TD>
	</tr>
	<tr>
		<td class="lightbluetable" colspan="4" valign="top" width="20%"><strong>附註：新事證及陳述意見書</strong></td>
	</tr>
	<TR>
		<TD class=whitetablebg colspan="4">
		<TEXTAREA id=Ptran_remark1 NAME=Ptran_remark1 ROWS=6 COLS=100 class="PLock"></TEXTAREA>
		</TD>
	</TR>	
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
        $("#Pagt_no").val(jOpt.agt_no);
        $("#Pissue_no").val(jOpt.issue_no);
        $("#PAppl_name").val(jOpt.appl_name);
        $("#Pother_item").val(jOpt.other_item);
        $("#Pother_item1").val(jOpt.other_item1);
        $("#Pother_item2").val(jOpt.other_item2);
        $("#Ptran_remark1").val(jOpt.tran_remark1);
        $("input[name='PS_Mark'][value='" + jOpt.s_mark + "']").prop("checked", true);
        $("input[name='Premark3'][value='" + jOpt.remark3 + "']").prop("checked", true);
        $("input[name='Pmark'][value='" + jOpt.detail_mark + "']").prop("checked", true);
    }
</script>
