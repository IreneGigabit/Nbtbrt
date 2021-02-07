<%@ Control Language="C#" ClassName="br_A9Z_end" %>
<%@ Import Namespace = "System.Collections.Generic"%>

<script runat="server">
    //新申請案交辦內容
    //父控制項傳入的參數
    public Dictionary<string, string> Lock = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);

    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected string SQL = "";

    protected string A9Z_end_type="";
    
    private void Page_Load(System.Object sender, System.EventArgs e) {
        PageLayout();
        this.DataBind();
    }
    
    private void PageLayout() {
        //結案原因
        A9Z_end_type = Sys.getCustCode("Tend_type","","sortfld").Option("{cust_code}", "{code_name}");
    }
</script>

<%=Sys.GetAscxPath(this.AppRelativeVirtualPath)%>
<TABLE border=0 class="bluetable"  cellspacing=1 cellpadding=2 width="100%" >
	<TR>
		<TD align=center colspan=4 class=lightbluetable1><font color=white>結&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;案&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;/&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;復&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;案&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;資&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;料</font></TD>
	</TR>
	<tr id="A9Ztr_endtype" style="display:none">
		<td class="lightbluetable" align="right">結案註記：</td>
		<td class="whitetablebg" >
            <input type="checkbox" name="A9Z_end_flag" id="A9Z_end_flag" value="Y" onclick="dmt_form.get_enddata('A9Z')"><font color=red>結案註記</font>(當此交辦需同時結案，請勾選)
		</td>
		<td class="lightbluetable" align="right">結案原因：</td>
		<td class="whitetablebg">
		    <select name="A9Z_end_type" id="A9Z_end_type" onchange="dmt_form.showendremark('A9Z')"><%#A9Z_end_type%></select>
            <input type=text name="A9Z_end_remark" id="A9Z_end_remark" size="60" maxlength=120 onblur="dmt_form.get_enddata('A9Z')" style="width:90%">
		</td>
	</tr>
	<tr id="A9Ztr_backflag" style="display:none">
		<td class="lightbluetable" align="right">復案註記：</td>
		<td class="whitetablebg" >
            <input type="checkbox" name="A9Z_back_flag" id="A9Z_back_flag" value="Y" onclick="dmt_form.get_backdata('A9Z')"><font color=red>復案註記</font>(當案件已結案且此交辦需復案，請勾選。<br>
            (注意：如有結案程序未完成，復案後系統將自動取消結案流程並銷管結案期限。))
		</td>
		<td class="lightbluetable" align="right">復案原因：</td>
		<td class="whitetablebg">
			<input type=text name="A9Z_back_remark" id="A9Z_back_remark" size="60" maxlength=120 onblur="dmt_form.get_backdata('A9Z')" style="width:90%">
		</td>
	</tr>
</table>	
