<%@ Control Language="C#" ClassName="cust14QueryForm" %>

<script runat="server">
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected string branch = "";
    protected string dept = "";
    //營洽選單
    protected string html_scode = "";
    //客戶等級
    protected string html_level = Sys.getCustCode("level", "", "sortfld").Option("{cust_code}", "{cust_code}_{code_name}");
    //申請人種類
    protected string html_apclass = Sys.getCustCode("apclass", "", "sortfld").Option("{cust_code}", "{cust_code}_{code_name}");
    //申請人國籍
    protected string html_country = Sys.getCountry().Option("{coun_code}", "{coun_code}_{coun_c}");
    

    private void Page_Load(System.Object sender, System.EventArgs e)
    {
        branch = Sys.GetSession("seBranch");
        dept = Sys.GetSession("dept");
        if (Sys.GetSession("dept") == "P")
        {
            html_scode = Sys.getCustScode("Q", "P", 64, "").Option("{pscode}", "{pscode}_{sc_name}");
            html_scode += "<option value='np'>np_部門(開放客戶)</option>";
        }
        else
        {
            html_scode = Sys.getCustScode("Q", "T", 64, "").Option("{tscode}", "{tscode}_{sc_name}");
            html_scode += "<option value='nt'>nt_部門(開放客戶)</option>";
        }
    
    }

</script>

<center>
    <table border="0" class="bluetable" cellspacing="1" cellpadding="2" width="80%">
	<tr id="tr_scode">
		<TD class=lightbluetable align=right>客戶營洽：</TD>
		<td class=whitetablebg align=left>
			<select id="scode" name="scode" size=1>
                <%--<%=scodehtml%>--%>
			</select>
		</td>
	</tr>
	<TR>
        <TD class=lightbluetable align=right>客戶編號：</TD>
		<TD class=whitetablebg align=left>
		<INPUT type="text" name="cust_area" readonly class="SEdit" size="1" value="<%=Sys.GetSession("seBranch")%>">-
		<INPUT type="text" id="cust_seqs" name="cust_seqs" size="6">～
		<INPUT type="text" id="cust_seqe" name="cust_seqe" size="6"></TD>
	</TR>
	<tr>
        <TD class=lightbluetable align=right>客戶種類：</TD>
		<td class=whitetablebg align=left>
		<select name=apclass size=1>
            <%=html_apclass %>
		</select>
		</td>
	</tr>
	<TR>
		<TD class=lightbluetable align=right>証照號碼：</TD>
		<TD class=whitetablebg align=left>
			<INPUT type="text" id="apcust_no" name="apcust_no" size="11" maxlength=10>
		</TD>
	</TR>
	<TR>
		<TD class=lightbluetable align=right>客戶/申請人名稱(中)：</TD>
		<TD class=whitetablebg align=left>
            <INPUT type=text id="ap_cname" name="ap_cname" size="22" maxlength=30>
		</TD>
	</TR>
	<TR>
		<TD class=lightbluetable align=right>客戶/申請人名稱(英)：</TD>
		<TD class=whitetablebg align=left>
            <INPUT type=text id="ap_ename" name="ap_ename" size="22" maxlength=40>
		</TD>
	</TR>
	<tr><TD class=lightbluetable align=right>客戶國籍：</TD>
		<td class=whitetablebg align=left>
			<select name=ap_country size=1>
                <%=html_country %>
			</select>
		</td>
	</tr>
	<TR id="tr_tlevel">
        <td class="lightbluetable" align="right" name=lab1>客戶等級：</td>
		<TD class=whitetablebg align=left colspan=3>
			<select name=tlevel size=1><%=html_level%></select>
		</td>
	</TR>
	<TR id="tr_plevel">
        <td class="lightbluetable" align="right" name=lab1>客戶等級：</td>
		<TD class=whitetablebg align=left colspan=3>
			<select name=plevel size=1><%=html_level%></select>
		</td>
	</TR>
</table>
</center>

<script language="javascript" type="text/javascript">

    var cust14queryform = {};
    cust14queryform.init = function () {
        if ('<%=prgid%>' == "cust14") {
            $("#tr_scode").hide();
        }

        if ('<%=dept%>' == "P") {
            $("#tr_tlevel").hide();
        }
        else {
            $("#tr_plevel").hide();
        }
    }


</script>