<%@ Control Language="C#" ClassName="cust_form" %>
<%@ Import Namespace = "System.Collections.Generic"%>

<script runat="server">
    //父控制項傳入的參數
    public Dictionary<string, string> Lock = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    public Dictionary<string, string> Hide = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    public int HTProgRight = 0;
    
    protected string prgid = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string SQL = "";
    
    //protected string cust_area = "";
    //protected string cust_seq = "";
    
    protected string F_ap_country = "", F_con_code = "", F_dis_type = "", F_pay_type = "";
    
    private void Page_Load(System.Object sender, System.EventArgs e) {
        F_ap_country = Sys.getCountry().Option("{coun_code}", "{coun_code}-{coun_c}");
        F_con_code = Sys.getCustCode("H", "", "cust_code").Option("{cust_code}", "{cust_code}---{code_name}");
        F_dis_type = Sys.getCustCode("Discount", "", "cust_code").Option("{cust_code}", "{cust_code}---{code_name}");
        F_pay_type = Sys.getCustCode("Payment", "", "cust_code").Option("{cust_code}", "{cust_code}---{code_name}");
        
        this.DataBind();
    }
</script>

<%=Sys.GetAscxPath(this.AppRelativeVirtualPath)%>
<table border="0" class="bluetable" cellspacing="1" cellpadding="2" width="100%">
<TR>
	<TD class=lightbluetable align="right">客戶編號：</TD>
	<TD class=whitetablebg>
	    <input TYPE="text" id="F_cust_area" name="F_cust_area" size="1" readonly class="SEdit">-
	    <input TYPE="text" id="F_cust_seq" name="F_cust_seq" size="6" class="<%#Lock.TryGet("Qclass")%><%#Lock.TryGet("brt52")%>">
        <input type=button id="btncust_seq" name="btncust_seq" value ="確定" class="greenbutton">
		<input type=hidden id="O_cust_area" name="O_cust_area">
		<input type=hidden id="O_cust_seq" name="O_cust_seq">
	</TD>
	<TD class=lightbluetable  align="right">客戶國籍：</TD>
	<TD class=whitetablebg>
        <Select id="F_ap_country" name="F_ap_country" class="Lock"><%#F_ap_country%></SELECT>
	</TD>
</TR>
<TR>
	<TD class=lightbluetable align=right width=16%>客戶種類：</TD>
	<TD class=whitetablebg><input type=text id="F_apclass" name="F_apclass" size="30" readonly class="SEdit"></TD>
	<TD class=lightbluetable align="right" width="15%">客戶群組：</TD>
	<TD class=whitetablebg><input TYPE=text id=F_ref_seq name=F_ref_seq readonly class="SEdit" /></TD>
</TR>
<TR>
	<TD class=lightbluetable align=right>統一編號：</TD>
	<TD class=whitetablebg colspan=3><INPUT TYPE=text id="F_id_no" name="F_id_no" SIZE=12 MAXLENGTH=10 class="SEdit" readonly></TD>					
</TR>
<TR>		
	<TD class=lightbluetable align=right>客戶名稱：</TD>
	<TD class=whitetablebg colspan=3>
        <INPUT TYPE=text id="F_ap_cname1" name="F_ap_cname1" size=44 maxlength=60 class="SEdit" readonly>
	    <INPUT TYPE=text id="F_ap_cname2" name="F_ap_cname2" size=44 maxlength=60 class="SEdit" readonly>
	</TD>
</TR>
<TR>	
	<TD class=lightbluetable align=right>英文名稱：</TD>
	<TD class=whitetablebg colspan=3>
        <INPUT TYPE=text id="F_ap_ename1" name="F_ap_ename1" size=60 maxlength=100 class="SEdit" readonly>
	    <INPUT TYPE=text id="F_ap_ename2" name="F_ap_ename2" size=60 maxlength=100 class="SEdit" readonly>
	</TD>
</TR>
<TR>
	<TD class=lightbluetable align=right>代表人(中)：</TD>
	<TD class=whitetablebg colspan=3><INPUT TYPE=text id="F_ap_crep" name="F_ap_crep" SIZE=20 MAXLENGTH=20 class="SEdit" readonly></TD>					
</TR>
<TR>
	<TD class=lightbluetable  align=right>代表人(英)：</TD>
	<TD class=whitetablebg colspan=3><INPUT TYPE=text id="F_ap_erep" name="F_ap_erep" size=40 maxlength=40 class="SEdit" readonly></TD>
</TR>
<TR>	
	<TD class=lightbluetable align=right>証照地址(中)：</TD>
	<TD class=whitetablebg colspan=3>(<INPUT TYPE=text id=F_ap_zip name=F_ap_zip size=8 maxlength=8 class="SEdit" readonly>)
	<INPUT TYPE=text id=F_ap_addr1 name=F_ap_addr1 size=103 maxlength=120 class="SEdit" readonly>
	<INPUT TYPE=text id=F_ap_addr2 name=F_ap_addr2 size=103 maxlength=120 class="SEdit" readonly>
	</TD>
</TR>
<TR>
	<TD class=lightbluetable align=right>登記地址(英)：</TD>
	<TD class=whitetablebg colspan=3>
        <INPUT TYPE=text id=F_ap_eaddr1 size=103 maxlength=120 class="SEdit" readonly><br>
	    <INPUT TYPE=text id=F_ap_eaddr2 size=103 maxlength=120 class="SEdit" readonly><br>
	    <INPUT TYPE=text id=F_ap_eaddr3 size=103 maxlength=120 class="SEdit" readonly><br>
	    <INPUT TYPE=text id=F_ap_eaddr4 size=103 maxlength=120 class="SEdit" readonly>
	</TD>
</TR>
<TR>
	<TD class=lightbluetable align="right">公司網址：</TD>
	<TD class=whitetablebg colspan=3><INPUT TYPE=text id=F_www SIZE=40 MAXLENGTH=40 class="SEdit" readonly></TD>
</TR>
<TR>  
	<TD class=lightbluetable align="right">公司電子郵件：</TD>		  
	<TD class=whitetablebg colspan=3><INPUT TYPE=text id=F_email SIZE=40 MAXLENGTH=40 class="SEdit" readonly></TD>
</TR>
<TR>
	<TD class=lightbluetable align="right">商標對帳聯絡人：</TD>
	<TD class=whitetablebg><INPUT TYPE=text id=F_tacc_attention size=40 maxlength=60 class="SEdit" readonly></TD>
	<TD class=lightbluetable align="right">商標對帳聯絡人職稱：</TD>
	<TD class=whitetablebg><INPUT TYPE=text id=F_tacc_title size=40 maxlength=40 class="SEdit" readonly></TD>
</TR>
<TR>  
	<TD class=lightbluetable align="right">商標對帳電子郵件：</TD>
	<TD class=whitetablebg colspan=3><INPUT TYPE=text id=F_tacc_email SIZE=80 MAXLENGTH=100 class="SEdit" readonly></TD>
</TR>
<TR>
	<TD class=lightbluetable align="right">商標對帳地址：</TD>
	<TD class=whitetablebg colspan=3>(<INPUT TYPE=text id=F_tacc_zip size=8 maxlength=8 class="SEdit" readonly>)
		<input type="text" id="F_tacc_addr1" size="47" maxlength="60" class="SEdit" readonly>
		<input type="text" id="F_tacc_addr2" size="47" maxlength="60" class="SEdit" readonly>
	</TD>
</TR>
<TR>
	<TD class=lightbluetable align="right">商標會計電話：</TD>
	<TD class=whitetablebg>(<INPUT TYPE=text id=F_tacc_tel0 size=4 maxlength=4 class="SEdit" readonly>)
	    <INPUT TYPE=text id=F_tacc_tel size=10 maxlength=10 class="SEdit" readonly>-
	    <INPUT TYPE=text id=F_tacc_tel1 size=5 maxlength=5 class="SEdit" readonly>
	</TD>
	<TD class=lightbluetable align="right">商標會計傳真：</TD>
	<TD class=whitetablebg><INPUT TYPE=text id=F_tacc_fax size=15 maxlength=15 class="SEdit" readonly></TD>
</TR>
<TR>
	<TD class=lightbluetable align="right">商標會計手機：</TD>
	<TD class=whitetablebg colspan=3><INPUT TYPE=text id=F_tacc_mobile size=22 maxlength=30 class="SEdit" readonly></TD>
</TR>
<TR>
	<TD class=lightbluetable align="right">專利對帳聯絡人：</TD>
	<TD class=whitetablebg><INPUT TYPE=text id=F_acc_attention size=40 maxlength=60 class="SEdit" readonly></TD>
	<TD class=lightbluetable align="right">專利對帳聯絡人職稱：</TD>
	<TD class=whitetablebg><INPUT TYPE=text id=F_acc_title size=40 maxlength=40 class="SEdit" readonly></TD>
</TR>
<TR>  
	<TD class=lightbluetable align="right">專利對帳電子郵件：</TD>
	<TD class=whitetablebg colspan=3><INPUT TYPE=text id=F_acc_email SIZE=80 MAXLENGTH=100 class="SEdit" readonly></TD>
</TR>
<TR>
	<TD class=lightbluetable align="right">專利對帳地址：</TD>
	<TD class=whitetablebg colspan=3>(<INPUT TYPE=text id=F_acc_zip size=8 maxlength=8 class="SEdit" readonly>)
	    <input type="text" id="F_acc_addr1" size="47" maxlength="60" class="SEdit" readonly>
	    <input type="text" id="F_acc_addr2" size="47" maxlength="60" class="SEdit" readonly>
	</TD>
</TR>
<TR>
	<TD class=lightbluetable align="right">專利會計電話：</TD>
	<TD class=whitetablebg>(<INPUT TYPE=text id=F_acc_tel0 size=4 maxlength=4 class="SEdit" readonly>)
	    <INPUT TYPE=text id=F_acc_tel size=10 maxlength=10 class="SEdit" readonly>-
	    <INPUT TYPE=text id=F_acc_tel1 size=5 maxlength=5 class="SEdit" readonly>
	</TD>
	<TD class=lightbluetable align="right">專利會計傳真：</TD>
	<TD class=whitetablebg><INPUT TYPE=text id=F_acc_fax size=15 maxlength=15 class="SEdit" readonly></TD>
</TR>
<TR>
	<TD class=lightbluetable align="right">專利會計手機：</TD>
	<TD class=whitetablebg colspan=3><INPUT TYPE=text id=F_acc_mobile size=22 maxlength=30 class="SEdit" readonly></TD>
</TR>
<TR>
	<TD class=lightbluetable align="right">郵寄雜誌：</TD>
	<TD class=whitetablebg colspan=3><INPUT TYPE=text id=F_mag size=10 maxlength=15 class="SEdit" readonly></TD>
</TR>
<TR>
	<TD class=lightbluetable align="right">顧問種類：</TD>
	<TD class=whitetablebg>
        <select id=F_con_code class="Lock"><%#F_con_code%></SELECT>
	</TD>
	<TD class=lightbluetable align="right">顧問迄日：</TD>
	<TD class=whitetablebg><INPUT TYPE=text id=F_con_term SIZE=10 class="SEdit" readonly></TD>
</TR>
<TR>
	<TD class=lightbluetable align=right>專利客戶等級：</TD>
	<TD class=whitetablebg ><select id=F_plevel class="Lock">
		<option value="" style="color:blue">請選擇</option>
		<option value="A">大客戶</option>
		<option value="B">中客戶</option>
		<option value="C">小客戶</option>
		<option value="L">流失客戶</option>
		<option value="O">結束客戶</option>
	</SELECT></TD>
	<TD class=lightbluetable align=right>商標客戶等級：</TD>
	<TD class=whitetablebg><select id=F_tlevel class="Lock">
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
        <Select id=F_pdis_type class="Lock"><%#F_dis_type%></SELECT>
	</TD>
    <TD class=lightbluetable align=right>商標折扣代碼：</TD>
	<TD class=whitetablebg>
        <Select id=F_tdis_type class="Lock"><%#F_dis_type%></SELECT>
	</TD>
</TR>
<TR>
	<TD class=lightbluetable align=right>專利付款條件：</TD>
	<TD class=whitetablebg>
        <Select id=F_ppay_type class="Lock"><%#F_pay_type%></SELECT>
	</TD>
	<TD class=lightbluetable align=right>商標付款條件：</TD>
	<TD class=whitetablebg>
        <Select id=F_tpay_type class="Lock"><%#F_pay_type%></SELECT>
	</TD>
</TR>
<TR>
	<TD class=lightbluetable align=right>備註說明：</td>
	<TD class=whitetablebg colspan=3><textarea rows=5 cols=80 id=F_mark class="SEdit" readonly></textarea>
</TR>
</table>
<script language="javascript" type="text/javascript">
    var cust_form={};
    cust_form.init = function () {
    }

    //修改客戶編號，重新帶出客戶資料
    $("#btncust_seq").click(function () {
        if ($("#F_cust_seq").val().trim() == "") return false;
        $("#tfy_cust_area").val($("#F_cust_area").val());
        $("#tfy_cust_seq").val($("#F_cust_seq").val());

        //取得客戶資料
        $.ajax({
            type: "get",
            url: getRootPath() + "/ajax/_vcustlist.aspx?cust_area=" + $("#F_cust_area").val() + "&cust_seq=" + $("#F_cust_seq").val(),
            async: false,
            cache: false,
            success: function (json) {
                if ($("#chkTest").length > 0) toastr.info("<a href='" + this.url + "' target='_new'>Debug(_vcustlist)！<BR><b><u>(點此顯示詳細訊息)</u></b></a>");
                var JSONdata = $.parseJSON(json);
                if (JSONdata.length == 0) {
                    toastr.warning("無該客戶，請重新輸入或至[客戶新增]新增該客戶!!!");
                    $("#F_cust_seq").focus();
                    return false;
                }
                jCust = JSONdata[0];
                $("#F_id_no").val(jCust.apcust_no);
                $("#F_ref_seq").val(jCust.ref_seq + " " + jCust.ref_seqnm);
                $("#F_apclass").val(jCust.apclass + " " + jCust.apclassnm);
                $("#F_ap_country").val(jCust.ap_country);
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
                $("#F_con_code").val(jCust.con_code);
                $("#F_con_term").val(dateReviver(jCust.con_term, "yyyy/M/d"));
                $("#F_mag").val(jCust.magnm);
                $("#F_plevel").val(jCust.plevel);
                $("#F_pdis_type").val(jCust.pdis_type);
                $("#F_ppay_type").val(jCust.ppay_type);
                $("#F_tlevel").val(jCust.tlevel);
                $("#F_tdis_type").val(jCust.tdis_type);
                $("#F_tpay_type").val(jCust.tpay_type);

                $("#F_acc_zip").val(jCust.acc_zip);
                $("#F_acc_addr1").val(jCust.acc_addr1);
                $("#F_acc_addr2").val(jCust.acc_addr2);
                $("#F_acc_tel0").val(jCust.acc_tel0);
                $("#F_acc_tel").val(jCust.acc_tel);
                $("#F_acc_tel1").val(jCust.acc_tel1);
                $("#F_acc_fax").val(jCust.acc_fax);
                $("#F_acc_attention").val(jCust.pacc_attention);
                $("#F_acc_title").val(jCust.pacc_title);
                $("#F_acc_email").val(jCust.pacc_email);
                $("#F_acc_mobile").val(jCust.acc_mobile);

                $("#F_tacc_zip").val(jCust.tacc_zip);
                $("#F_tacc_addr1").val(jCust.tacc_addr1);
                $("#F_tacc_addr2").val(jCust.tacc_addr2);
                $("#F_tacc_tel0").val(jCust.tacc_tel0);
                $("#F_tacc_tel").val(jCust.tacc_tel);
                $("#F_tacc_tel1").val(jCust.tacc_tel1);
                $("#F_tacc_fax").val(jCust.tacc_fax);
                $("#F_tacc_attention").val(jCust.tacc_attention);
                $("#F_tacc_title").val(jCust.tacc_title);
                $("#F_tacc_email").val(jCust.tacc_email);
                $("#F_tacc_mobile").val(jCust.tacc_mobile);

                $("#F_mark").val(jCust.cust_remark);
                attent_form.getatt($("#F_cust_area").val(), $("#F_cust_seq").val());//重新抓聯諾人
            },
            error: function (xhr) { 
                $("#dialog").html("<a href='" + this.url + "' target='_new'>客戶資料載入失敗！<u>(點此顯示詳細訊息)</u></a><hr>"+xhr.responseText);
                $("#dialog").dialog({ title: '客戶資料載入失敗！', modal: true, maxHeight: 500, width: "90%" });
            }
        });
    });
</script>
