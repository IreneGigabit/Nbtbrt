<%@ Control Language="C#" Classname="opt_attent_form" %>

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
<table border="0" class="bluetable" cellspacing="1" cellpadding="2" width="100%">
	<TR>
		<td class="lightbluetable" align="right">客戶編號：</td>
		<td class="whitetablebg" colspan=3>
		<input TYPE="text" id="tfy_cust_area" name="tfy_cust_area" SIZE="1" class="MLock">-
		<input TYPE="text" id="tfy_cust_seq" name="tfy_cust_seq" size="8" class="MLock"></td>
	</TR>
	<TR>
		<td class="lightbluetable" align="right">聯絡人：</td>
		<td class="whitetablebg">
            <select id=tfy_att_sql name=tfy_att_sql class="MLock"></select>
        </td>
		<TD class=lightbluetable align=right>所屬部門：</TD>
		<TD class=whitetablebg><INPUT TYPE=text id=dept name=dept class="MLock"></TD>
	</TR>
	<TR>
		<TD class=lightbluetable align=right>職稱：</TD>
		<TD class=whitetablebg><INPUT TYPE=text id=att_title SIZE=11 MAXLENGTH=10 class="MLock"></TD>		
		<TD class=lightbluetable align=right>聯絡部門：</TD>
		<TD class=whitetablebg><INPUT TYPE=text id=att_dept SIZE=22 MAXLENGTH=20 class="MLock"></TD>
	</TR>
	<TR>
		<TD class=lightbluetable align=right>聯絡電話：</TD>
		<TD class=whitetablebg colspan=3>
            (<INPUT TYPE=text id=att_tel0 name=att_tel0 SIZE=4 MAXLENGTH=4 class="MLock" />)
		    <INPUT TYPE=text id=att_tel SIZE=16 MAXLENGTH=15 class="MLock">-<INPUT TYPE=text id=att_tel1 SIZE=5 MAXLENGTH=5 class="MLock">
		</TD>
	</TR>
	<TR>
		<TD class=lightbluetable align=right>行動電話：</TD>
		<TD class=whitetablebg><INPUT TYPE=text id=att_mobile SIZE=11 MAXLENGTH=10 class="MLock"></TD>		
		<TD class=lightbluetable align=right>傳真號碼：</TD>
		<TD class=whitetablebg><INPUT TYPE=text id=att_fax SIZE=16 MAXLENGTH=15 class="MLock"></TD>
	</TR>
	<TR>
		<TD class=lightbluetable align=right>聯絡地址：</TD>
		<TD class=whitetablebg colspan=3>
		    <INPUT TYPE=text id=att_zip SIZE=5 MAXLENGTH=5 class="MLock">
		    <INPUT TYPE=text id=att_addr1 SIZE=33 MAXLENGTH=30 class="MLock">
		    <INPUT TYPE=text id=att_addr2 SIZE=33 MAXLENGTH=30 class="MLock">
		</TD>
	</TR>
	<TR>
		<TD class=lightbluetable align=right>電子郵件：</TD>
		<TD class=whitetablebg colspan=3><INPUT TYPE=text id=Att_email SIZE=44 MAXLENGTH=40 class="MLock"></TD>
	</TR>
	<TR>
		<TD class=lightbluetable align=right>郵寄雜誌：</TD>
		<TD class=whitetablebg colspan=3><INPUT TYPE=text id=att_mag size=22 class="MLock"></TD>				  
	</TR>		
</table>
<script language="javascript" type="text/javascript">
    var attent_form = {};
    attent_form.init = function () {
        var jAttList = br_opt.att_list;
        $("#tfy_att_sql").getOption({//聯絡人清單
            dataList: jAttList,
            valueFormat: "{att_sql}",
            textFormat: "{att_sql}---{attention}"
        });

        $.each(jAttList, function (idx, obj) {
            if (obj.att_sql == br_opt.opt[0].att_sql) {
                $("#tfy_cust_area").val(obj.cust_area);
                $("#tfy_cust_seq").val(obj.cust_seq);
                $("#tfy_att_sql").val(obj.att_sql);
                $("#dept").val(obj.deptnm);
                $("#att_title").val(obj.att_title);
                $("#att_dept").val(obj.att_dept);
                $("#att_tel0").val(obj.att_tel0);
                $("#att_tel").val(obj.att_tel);
                $("#att_tel1").val(obj.att_tel1);
                $("#att_mobile").val(obj.att_mobile);
                $("#att_fax").val(obj.att_fax);
                $("#att_zip").val(obj.att_zip);
                $("#att_addr1").val(obj.att_addr1);
                $("#att_addr2").val(obj.att_addr2);
                $("#Att_email").val(obj.att_email);
                $("#att_mag").val(obj.magnm);
            }
        });
    }
</script>
