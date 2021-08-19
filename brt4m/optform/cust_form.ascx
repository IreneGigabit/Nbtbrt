<%@ Control Language="C#" ClassName="opt_cust_form" %>

<script runat="server">
    protected string prgid = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string SQL = "";
    protected string branch = "";
    protected string opt_sqlno = "";

    protected string F_ap_country = "", F_con_code = "", F_dis_type = "", F_pay_type = "";
    
    private void Page_Load(System.Object sender, System.EventArgs e) {
        branch = Request["branch"] ?? "";
        opt_sqlno = Request["opt_sqlno"] ?? "";

        F_ap_country = Sys.getCountry().Option("{coun_code}", "{coun_code}-{coun_c}");
        F_con_code = Sys.getCustCode("H", "", "cust_code").Option("{cust_code}", "{cust_code}---{code_name}");
        F_dis_type = Sys.getCustCode("Discount", "", "cust_code").Option("{cust_code}", "{cust_code}---{code_name}");
        F_pay_type = Sys.getCustCode("Payment", "", "cust_code").Option("{cust_code}", "{cust_code}---{code_name}");
        
        this.DataBind();
    }
</script>

<%=Sys.GetAscxPath(this)%>
<table border="0" class="bluetable" cellspacing="1" cellpadding="2" width="100%">
<TR>
	<TD class=lightbluetable align="right">客戶編號：</TD>
	<TD class=whitetablebg>
	<input TYPE="text" id="F_cust_area" name="F_cust_area" SIZE="1" class="MLock">-
	<input TYPE="text" id="F_cust_seq" name="F_cust_seq" size="6"  class="MLock">
	</TD>
	<TD class=lightbluetable  align="right">客戶國籍：</TD>
	<TD class=whitetablebg>
        <Select id="F_ap_country" name="F_ap_country" class="MLock"><%#F_ap_country%></SELECT>
	</TD>
</TR>
<TR>
	<TD class=lightbluetable align=right width=16%>客戶種類：</TD>
	<TD class=whitetablebg><input type=text id="F_apclass" name="F_apclass" size="30" class="MLock"></TD>
	<TD class=lightbluetable align="right" width="15%">客戶群組：</TD>
	<TD class=whitetablebg><input TYPE=text id=F_ref_seq name=F_ref_seq class="MLock" /></TD>
</TR>
<TR>
	<TD class=lightbluetable align=right>統一編號：</TD>
	<TD class=whitetablebg colspan=3><INPUT TYPE=text id="F_id_no" name="F_id_no" SIZE=12 MAXLENGTH=10 class="MLock"></TD>					
</TR>
<TR>		
	<TD class=lightbluetable align=right>客戶名稱：</TD>
	<TD class=whitetablebg colspan=3>
        <INPUT TYPE=text id="F_ap_cname1" name="F_ap_cname1" size=44 maxlength=60 class="MLock">
	    <INPUT TYPE=text id="F_ap_cname2" name="F_ap_cname2" size=44 maxlength=60 class="MLock" >
	</TD>
</TR>
<TR>	
	<TD class=lightbluetable align=right>英文名稱：</TD>
	<TD class=whitetablebg colspan=3>
        <INPUT TYPE=text id="F_ap_ename1" name="F_ap_ename1" size=60 maxlength=100 class="MLock">
	    <INPUT TYPE=text id="F_ap_ename2" name="F_ap_ename2" size=60 maxlength=100 class="MLock">
	</TD>
</TR>
<TR>
	<TD class=lightbluetable align=right>代表人(中)：</TD>
	<TD class=whitetablebg colspan=3><INPUT TYPE=text id="F_ap_crep" name="F_ap_crep" SIZE=20 MAXLENGTH=20 class="MLock"></TD>					
</TR>
<TR>
	<TD class=lightbluetable  align=right>代表人(英)：</TD>
	<TD class=whitetablebg colspan=3><INPUT TYPE=text id="F_ap_erep" name="F_ap_erep" size=40 maxlength=40 class="MLock"></TD>
</TR>
<TR>	
	<TD class=lightbluetable align=right>証照地址(中)：</TD>
	<TD class=whitetablebg colspan=3>(<INPUT TYPE=text id=F_ap_zip name=F_ap_zip size=8 maxlength=8 class="MLock">)
	<INPUT TYPE=text id=F_ap_addr1 name=F_ap_addr1 size=103 maxlength=120 class="MLock">
	<INPUT TYPE=text id=F_ap_addr2 name=F_ap_addr2 size=103 maxlength=120 class="MLock"></TD>
</TR>		
<TR>	
	<TD class=lightbluetable align=right>登記地址(英)：</TD>
	<TD class=whitetablebg colspan=3>
        <INPUT TYPE=text id=F_ap_eaddr1 size=103 maxlength=120 class="MLock"><br>
	    <INPUT TYPE=text id=F_ap_eaddr2 size=103 maxlength=120 class="MLock"><br>
	    <INPUT TYPE=text id=F_ap_eaddr3 size=103 maxlength=120 class="MLock"><br>
	    <INPUT TYPE=text id=F_ap_eaddr4 size=103 maxlength=120 class="MLock">
	</TD>
</TR>
<TR>		  
	<TD class=lightbluetable align="right">公司網址：</TD>
	<TD class=whitetablebg colspan=3><INPUT TYPE=text id=F_www SIZE=40 MAXLENGTH=40 class="MLock"></TD>
</TR>
<TR>  
	<TD class=lightbluetable align="right">公司電子郵件：</TD>		  
	<TD class=whitetablebg colspan=3><INPUT TYPE=text id=F_email SIZE=40 MAXLENGTH=40 class="MLock"></TD>		  
</TR>
<TR>		  
	<TD class=lightbluetable align="right">對帳地址：</TD>
	<TD class=whitetablebg colspan=3>
        (<INPUT TYPE=text id=F_acc_zip size=8 maxlength=8 class="MLock">)
	    <input type="text" id="F_acc_addr1" size="47" maxlength="60" class="MLock">
	    <input type="text" id="F_acc_addr2" size="47" maxlength="60" class="MLock">
	</TD>
</TR>
<TR>
	<TD class=lightbluetable align="right">會計電話：</TD>
	<TD class=whitetablebg>
        (<INPUT TYPE=text id=F_acc_tel0 size=4 maxlength=4 class="MLock">)
	    <INPUT TYPE=text id=F_acc_tel size=10 maxlength=10 class="MLock">-
	    <INPUT TYPE=text id=F_acc_tel1 size=5 maxlength=5 class="MLock">
	</TD>
	<TD class=lightbluetable align="right">會計傳真：</TD>
	<TD class=whitetablebg><INPUT TYPE=text id=F_acc_fax size=15 maxlength=15 class="MLock"></TD>
</TR>
<TR>		  
	<TD class=lightbluetable align="right">郵寄雜誌：</TD>
	<TD class=whitetablebg colspan=3><INPUT TYPE=text id=F_mag size=10 maxlength=15 class="MLock"></TD>
</TR>
<TR>
	<TD class=lightbluetable align="right">顧問種類：</TD>
	<TD class=whitetablebg>
        <select id=F_con_code class="MLock"><%#F_con_code%></SELECT>
	</TD>
	<TD class=lightbluetable align="right">顧問迄日：</TD>
	<TD class=whitetablebg><INPUT TYPE=text id=F_con_term SIZE=10 class="MLock"></TD>
</TR>
<TR>		  
	<TD class=lightbluetable align=right>專利客戶等級：</TD>
	<TD class=whitetablebg ><select id=F_plevel class="MLock">
		<option value="" style="color:blue">請選擇</option>
		<option value="A">大客戶</option>
		<option value="B">中客戶</option>
		<option value="C">小客戶</option>
		<option value="L">流失客戶</option>
		<option value="O">結束客戶</option>
	</SELECT></TD>
	<TD class=lightbluetable align=right>商標客戶等級：</TD>
	<TD class=whitetablebg><select id=F_tlevel class="MLock">
		<option value="" style="color:blue">請選擇</option>
		<option value="A">大客戶</option>
		<option value="B">中客戶</option>
		<option value="C">小客戶</option>
		<option value="L">流失客戶</option>
		<option value="O">結束客戶</option>
	</SELECT></TD>	
</TR>
<TR>
	<TD class=lightbluetable align=right>專利折扣代碼：</TD>
	<TD class=whitetablebg>
        <Select id=F_pdis_type class="MLock"><%#F_dis_type%></SELECT>
	</TD>
<TD class=lightbluetable align=right>商標折扣代碼：</TD>
	<TD class=whitetablebg>
        <Select id=F_tdis_type class="MLock"><%#F_dis_type%></SELECT>
	</TD>
</TR>
<TR>
	<TD class=lightbluetable align=right>專利付款條件：</TD>
	<TD class=whitetablebg>
        <Select id=F_ppay_type class="MLock"><%#F_pay_type%></SELECT>
	</TD>
	<TD class=lightbluetable align=right>商標付款條件：</TD>
	<TD class=whitetablebg>
        <Select id=F_tpay_type class="MLock"><%#F_pay_type%></SELECT>
	</TD>
</TR>
<TR>
	<TD class=lightbluetable align=right>備註說明：</td>
	<TD class=whitetablebg colspan=3><textarea rows=5 cols=80 id=F_mark class="MLock"></textarea>
</TR>		        
</table>
<script language="javascript" type="text/javascript">
    var cust_form={};
    cust_form.init = function () {
        //if (br_opt.cust.length == 0) {
        //    toastr.error("「案件客戶」載入失敗！<BR>請聯繫資訊人員！");
        //    return false;
        //}
        var jCust = br_opt.cust[0];
        if (br_opt.cust.length > 0) {
            $("#F_cust_area").val(jCust.cust_area);
            $("#F_cust_seq").val(jCust.cust_seq);
            $("#F_ap_country").val(jCust.ap_country);
            $("#F_apclass").val(jCust.apclass + " " + jCust.apclassnm);
            $("#F_ref_seq").val(jCust.ref_seq + " " + jCust.ref_seqnm);
            $("#F_id_no").val(jCust.apcust_no);
            $("#F_ap_cname1").val(jCust.ap_cname1);
            $("#F_ap_cname2").val(jCust.ap_cname2);
            $("#F_ap_ename1").val(jCust.ap_ename1);
            $("#F_ap_ename2").val(jCust.ap_ename2);
            $("#F_ap_crep").val(jCust.ap_crep);
            $("#F_ap_erep").val(jCust.ap_erep);
            $("#F_ap_zip").val(jCust.ap_zip);
            $("#F_ap_addr1").val(jCust.ap_addr1);
            $("#F_ap_addr2").val(jCust.ap_addr2);
            $("#F_ap_eaddr1").val(jCust.ap_eaddr1);
            $("#F_ap_eaddr2").val(jCust.ap_eaddr2);
            $("#F_ap_eaddr3").val(jCust.ap_eaddr3);
            $("#F_ap_eaddr4").val(jCust.ap_eaddr4);
            $("#F_www").val(jCust.www);
            $("#F_email").val(jCust.email);
            $("#F_acc_zip").val(jCust.acc_zip);
            $("#F_acc_addr1").val(jCust.acc_addr1);
            $("#F_acc_addr2").val(jCust.acc_addr2);
            $("#F_acc_tel0").val(jCust.acc_tel0);
            $("#F_acc_tel").val(jCust.acc_tel);
            $("#F_acc_tel1").val(jCust.acc_tel1);
            $("#F_acc_fax").val(jCust.acc_fax);
            $("#F_mag").val(jCust.magnm);
            $("#F_con_code").val(jCust.con_code);
            $("#F_con_term").val(dateReviver(jCust.con_term, "yyyy/M/d"));
            $("#F_plevel").val(jCust.plevel);
            $("#F_tlevel").val(jCust.tlevel);
            $("#F_pdis_type").val(jCust.pdis_type);
            $("#F_tdis_type").val(jCust.tdis_type);
            $("#F_ppay_type").val(jCust.ppay_type);
            $("#F_tpay_type").val(jCust.tpay_type);
            $("#F_mark").val(jCust.cust_remark);
        }
    }
</script>
