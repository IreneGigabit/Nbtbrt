<%@ Control Language="C#" ClassName="cust11Form" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace = "System.Text"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.IO"%>
<%@ Import Namespace = "System.Linq"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Web.Script.Serialization"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>


<script runat="server">
  
    //申請人種類
    protected string html_apclass = Sys.getCustCode("apclass", "", "sortfld").Option("{cust_code}", "{cust_code}_{code_name}");
    //申請人國籍
    protected string html_country = Sys.getCountry().Option("{coun_code}", "{coun_code}_{coun_c}");
    //債信種類
    protected string html_RmarkCode = Sys.getCustCode("rmark_code", "", "sortfld").Option("{cust_code}", "{code_name}");
    //客戶等級
    protected string html_level = Sys.getCustCode("level", "", "sortfld").Option("{cust_code}", "{cust_code}_{code_name}");
    //顧問種類
    protected string html_H = Sys.getCustCode("H", "", "sortfld").Option("{cust_code}", "{code_name}");
    //折扣代碼
    protected string html_B = Sys.getCustCode("B", "", "sortfld").Option("{cust_code}", "{cust_code}_{code_name}");
    //付款條件
    protected string html_Payment = Sys.getCustCode("Payment", "", "sortfld").Option("{cust_code}", "{cust_code}_{code_name}");
    //營洽選單
    protected string html_TScode = "";
    protected string html_PScode = "";
    protected string submitTask = "";
    
    protected string dept = Sys.GetSession("dept");
    protected string level_Name = "";
    protected string dis_type_Name = "";
    protected string pay_type_Name = "";
    protected string month = "";

    private void Page_Load(System.Object sender, System.EventArgs e)
    {
        submitTask = Request["submitTask"];
        if (submitTask == "A")
        {
            html_PScode = Sys.getCustScode("A", "P", 64, "").Option("{scode}", "{scode}_{sc_name}");
            html_TScode = Sys.getCustScode("A", "T", 64, "").Option("{scode}", "{scode}_{sc_name}");
        }
        else
        {
            html_PScode = Sys.getCustScode("Q", "P", 64, "").Option("{pscode}", "{pscode}_{sc_name}");
            html_TScode = Sys.getCustScode("Q", "T", 64, "").Option("{tscode}", "{tscode}_{sc_name}");
        }
        html_PScode += "<option value='np'>np_部門(開放客戶)</option>";
        html_TScode += "<option value='nt'>nt_部門(開放客戶)</option>";
        

        for (int i = 1; i < 13; i++)
        {
            month += "<OPTION value="+i+">"+i+"</OPTION>";
        }
        //Response.Write("tscode is :" + html_TScode);
        //if (dept == "P")
        //{
        //    level_Name = "專利客戶等級：";
        //    dis_type_Name = "專利折扣代碼：";
        //    pay_type_Name = "專利付款條件：";
        //}
        //else
        //{
        //    level_Name = "商標客戶等級 : ";
        //    dis_type_Name = "商標折扣代碼：";
        //    pay_type_Name = "商標付款條件：";
        //}
        
    }

</script>
<style>
    .InputMB input{
         margin-bottom : 4px;
    }
    .emTag {
       
        font:inherit;
    }

</style>


<input TYPE="hidden" name="cust_area" id="cust_area" value="<%=Sys.GetSession("seBranch")%>">
<input TYPE="hidden" name="cust_seq" id="cust_seq" value="<%=Request["cust_seq"]%>">
<input TYPE="hidden" name="apsqlno" id="apsqlno" value="<%=Request["apsqlno"]%>">
<table border="0" class="bluetable" cellspacing="1" cellpadding="2" width="100%">
	<tr>
		<td class="lightbluetable" align="right" >
			<%--<div style="display:none">專利營洽：</div>
			<div style="display:none">商標營洽：</div>
			<div style="display:block">營洽：</div>--%>
			<div id="divscode" style="display:block">客戶編號：</div>
		</td>
		<td class="whitetablebg">
            <div style="display:none">
                <select NAME="scode" size="1" value="">
					<option value="">p_部門(開放客戶)</option>
					<option value="">t_部門(開放客戶)</option>
				</select>
				<input TYPE="text" NAME="scode" readonly class="sedit" size="4" value="">-
            </div>
            <div>
                <em class="emTag" id="cust_area_str"></em> － <em class="emTag" id="cust_seq_str"></em>
            </div>
		</td>
		<td class="lightbluetable" align="right">※客戶國籍：</td>
		<td class="whitetablebg">
			<input TYPE="hidden" NAME="hap_country" value="">
			<input TYPE="hidden" NAME="oap_country" value="">
			<select name="ap_country" id="ap_country" size="1" >
                <%#html_country%>
			</select>
		</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right">※客戶種類：</td>
		<td class="whitetablebg">
			<input TYPE="hidden" NAME="apclass_name" value="客戶種類">
			<input TYPE="hidden" NAME="oapclass" value="">
			<input TYPE="hidden" NAME="hapclass"  value="">
			<select name="apclass" id="apclass" size="1" onchange="cust11form.ChkApclass();cust11form.apclassChange();" >
                 <%#html_apclass%>
			</select>
		</td>
		<td class="lightbluetable" align="right">
            <em id="id_no_Name" class="emTag" >※統一編號：</em>
		</td>
		<td class="whitetablebg">
			<input TYPE="text" NAME="id_no" id="id_no" SIZE="12" MAXLENGTH="10" value="" onblur="cust11form.Chkid_no();cust11form.Chkid_noDouble(); ">
		</td>					
	</tr>
	<tr>
		<td class="lightbluetable" align="right" width="15%">客戶群組：</td>
		<td class="whitetablebg" colspan="3">
			<input TYPE="hidden" NAME="ref_seq_name" value="客戶群組">
			<input TYPE="hidden" NAME="oref_seq" value="">
			<input TYPE="text" NAME="ref_seq" id="ref_seq" size="6"  value="" onblur="cust11form.Chkref_seqDouble()">
			<input type="text" name="ref_seqName" id="ref_seqName" readonly="readonly" class="SEdit" size="47"  value="">
		</td>
	</tr>
	<tr><!--2012/7/增加名稱長度44-->		
		<td class="lightbluetable" align="right" nowrap>※客戶名稱：</td>
		<td class="whitetablebg" colspan="3">
			<input TYPE="hidden" NAME="oap_cname1" value="">
			<input TYPE="hidden" NAME="oap_cname2" value="">
			<input TYPE="text" NAME="ap_cname1" id="ap_cname1" size="47" maxlength="44" value="" onblur="cust11form.ap_cname1onblur()">
			<input TYPE="text" NAME="ap_cname2" id="ap_cname2" size="47" maxlength="44" value="">
		</td>
	</tr>
	<tr>		
		<td class="lightbluetable" align="right" nowrap title="若是複姓請注意調整姓及名字數的正確性"><font color=red><u>客戶名稱：</u></font></td>
		<td class="whitetablebg" colspan="3">
			<input TYPE="hidden" NAME="oap_fcname" value="">
			<input TYPE="hidden" NAME="oap_lcname" value="">
			姓：<input TYPE="text" NAME="ap_fcname" id="ap_fcname" size="16" maxlength="15"  value="">
			名：<input TYPE="text" NAME="ap_lcname" id="ap_lcname" size="16" maxlength="15"  value="">
		</td>
	</tr>
	<tr>	
		<td class="lightbluetable" align="right">英文名稱：</td>
		<td class="whitetablebg" colspan="4">
			<input TYPE="hidden" NAME="ap_ename1_name" value="英文名稱1">
			<input TYPE="hidden" NAME="ap_ename2_name" value="英文名稱2">
			<input TYPE="hidden" NAME="oap_ename1">
			<input TYPE="hidden" NAME="oap_ename2">
			<input TYPE="text" NAME="ap_ename1" id="ap_ename1" size="60" maxlength="100" value="">
			<input TYPE="text" NAME="ap_ename2" id="ap_ename2" size="60" maxlength="100" value="">
		</td>
	</tr>
	<tr>	
		<td class="lightbluetable" align="right">英文名稱：</td>
		<td class="whitetablebg" colspan="3">
			<input TYPE="hidden" NAME="ap_fename_name" value="英文名稱(姓)">
			<input TYPE="hidden" NAME="ap_lename_name" value="英文名稱(名)">
			<input TYPE="hidden" NAME="oap_fename" value="">
			<input TYPE="hidden" NAME="oap_lename" value="">
			姓：<input TYPE="text" NAME="ap_fename" id="ap_fename" size="33" maxlength="30"  value="">
			名：<input TYPE="text" NAME="ap_lename" id="ap_lename" size="33" maxlength="30"  value="">
		</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right">代表人(中)：</td>
		<td class="whitetablebg" colspan="3">
		<input TYPE="hidden" NAME="ap_crep_name" value="代表人(中)">
		<input TYPE="hidden" NAME="oap_crep" value="">
		<input TYPE="text" NAME="ap_crep" id="ap_crep" SIZE="44" MAXLENGTH="40" value=""></td>					
	</tr>
	<tr>
		<td class="lightbluetable" align="right">代表人(英)：</td>
		<td class="whitetablebg" colspan="3">
		<input TYPE="hidden" NAME="ap_erep_name" value="代表人(英)">
		<input TYPE="hidden" NAME="oap_erep" value="">
		<input TYPE="text" NAME="ap_erep" id="ap_erep" size="88" maxlength="80" value=""></td>
	</tr>
	<tr><!--2012/6/20增加代表人職稱-->
		<td class="lightbluetable" align="right">代表人職稱：</td>
		<td class="whitetablebg" colspan="3">
		<input TYPE="hidden" NAME="ap_title_name" value="代表人職稱">
		<input TYPE="hidden" NAME="oap_title" value="">
		<input TYPE="text" NAME="ap_title" id="ap_title" SIZE="55" MAXLENGTH="50"  value=""></td>
	</tr>
	<tr class="InputMB"><!--2012/7/增加地址長度44--><!--2016/1/7增加地址長度120-->	
		<td class="lightbluetable" align="right">証照地址(中)：</td>
		<td class="whitetablebg" colspan="3">
		<input TYPE="hidden" NAME="ap_zip_name" value="証照地址(中)郵遞區號">
		<input TYPE="hidden" NAME="ap_addr1_name" value="証照地址(中)1">
		<input TYPE="hidden" NAME="ap_addr2_name" value="証照地址(中)2">
		<input TYPE="hidden" NAME="oap_zip" value="">
		<input TYPE="hidden" NAME="oap_addr1" value="">
		<input TYPE="hidden" NAME="oap_addr2" value="">
        郵遞區號
		<input TYPE="text" NAME="ap_zip" id="ap_zip" size="8" maxlength="8"  value="" class="InputNumOnly"><br />
		<input TYPE="text" NAME="ap_addr1" id="ap_addr1" size="103" maxlength="120"  value=""><br />
		<input TYPE="text" NAME="ap_addr2" id="ap_addr2" size="103" maxlength="120"  value=""></td>
	</tr>
	<tr class="InputMB">	
		<td class="lightbluetable" align="right" nowrap>証照地址(英)：</td>
		<td class="whitetablebg" colspan="3">
		<input TYPE="hidden" NAME="ap_eaddr1_name" value="証照地址(英)1">
		<input TYPE="hidden" NAME="ap_eaddr2_name" value="証照地址(英)2">
		<input TYPE="hidden" NAME="ap_eaddr3_name" value="証照地址(英)3">
		<input TYPE="hidden" NAME="ap_eaddr4_name" value="証照地址(英)4">
		<input TYPE="hidden" NAME="oap_eaddr1" value="">
		<input TYPE="hidden" NAME="oap_eaddr2" value="">
		<input TYPE="hidden" NAME="oap_eaddr3" value="">
		<input TYPE="hidden" NAME="oap_eaddr4" value="">
		<input TYPE="text" NAME="ap_eaddr1" id="ap_eaddr1" size="103" maxlength="120"  value=""><br>
		<input TYPE="text" NAME="ap_eaddr2" id="ap_eaddr2" size="103" maxlength="120"  value=""><br>
		<input TYPE="text" NAME="ap_eaddr3" id="ap_eaddr3" size="103" maxlength="120"  value=""><br>
		<input TYPE="text" NAME="ap_eaddr4" id="ap_eaddr4" size="103" maxlength="120"  value=""></td>
	</tr>		
	<tr class="InputMB"><!--2012/7/增加名稱長度44--><!--2016/1/7增加地址長度120-->
		<td class="lightbluetable" align="right">聯絡地址：</td>
		<td class="whitetablebg" colspan="3">
		<input TYPE="hidden" NAME="apatt_zip_name" value="聯絡地址郵遞區號">
		<input TYPE="hidden" NAME="apatt_addr1_name" value="聯絡地址1">
		<input TYPE="hidden" NAME="apatt_addr2_name" value="聯絡地址2">
		<input TYPE="hidden" NAME="oapatt_zip" value="">
		<input TYPE="hidden" NAME="oapatt_addr1" value="">
		<input TYPE="hidden" NAME="oapatt_addr2" value="">
        郵遞區號
		<input TYPE="text" NAME="apatt_zip" id="apatt_zip" SIZE="8" MAXLENGTH="8"  value="" class="InputNumOnly"><br />
		<input TYPE="text" NAME="apatt_addr1" id="apatt_addr1" SIZE="103" MAXLENGTH="120"  value="" ><br />
		<input TYPE="text" NAME="apatt_addr2" id="apatt_addr2" SIZE="103" MAXLENGTH="120"  value="" >
		<input type="button" name=btnaddratt id="btnCopyAddr" value="同証照地址" class="cbutton" style="cursor:hand">
		</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right">聯絡電話：</td>
		<td class="whitetablebg">
		<input TYPE="hidden" NAME="apatt_tel0_name" value="聯絡電話區碼">
		<input TYPE="hidden" NAME="apatt_tel_name" value="聯絡電話">
		<input TYPE="hidden" NAME="apatt_tel1_name" value="聯絡電話分機">
		<input TYPE="hidden" NAME="oapatt_tel0" value="">
		<input TYPE="hidden" NAME="oapatt_tel" value="">
		<input TYPE="hidden" NAME="oapatt_tel1" value="">
		(<input TYPE="text" NAME="apatt_tel0" id="apatt_tel0" SIZE="4" MAXLENGTH="4"  value="" class="InputNumOnly">)
		<input TYPE="text" NAME="apatt_tel" id="apatt_tel" SIZE="16" MAXLENGTH="15"  value="" class="InputNumAndMarks" >
		<input TYPE="text" NAME="apatt_tel1" id="apatt_tel1" SIZE="10" MAXLENGTH="10"  value="" class="InputNumAndMarks" ></td>
		<td class="lightbluetable" align="right">聯絡傳真：</td>
		<td class="whitetablebg">
		<input TYPE="hidden" NAME="apatt_fax_name" value="聯絡傳真">
		<input TYPE="hidden" NAME="oapatt_fax" value="">
		<input TYPE="text" NAME="apatt_fax" id="apatt_fax" SIZE="20" MAXLENGTH="20"  value="" class="InputNumAndMarks" ></td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right">聯絡E-mail：</td>
		<td class="whitetablebg" colspan="3">
		<input TYPE="hidden" NAME="apatt_email_name" value="聯絡E-mail">
		<input TYPE="hidden" NAME="oapatt_email" value="">
		<input TYPE="text" NAME="apatt_email" id="apatt_email" SIZE="50" MAXLENGTH="50"  value="">
		</td>
	</tr>
	<tr>		  
		<td class="lightbluetable" align="right">公司網址：</td>
		<td class="whitetablebg" colspan="3">
		<input TYPE="hidden" NAME="www_name" value="公司網址">
		<input TYPE="hidden" NAME="owww" value="">
		<input TYPE="text" NAME="www" id="www" SIZE="50" MAXLENGTH="100" value=""></td>
	</tr>
	<tr>  
		<td class="lightbluetable" align="right">公司電子郵件：</td>		  
		<td class="whitetablebg" colspan="3">
		<input TYPE="hidden" NAME="email_name" value="公司電子郵件">
		<input TYPE="hidden" NAME="oemail" value="">
		<input TYPE="text" NAME="email" id="email" SIZE="50" MAXLENGTH="100"value=""></td>
	</tr>
	<tr class="dept_t" >
		<td class="lightbluetable" align="right">商標對帳聯絡人：</td>
		<td class="whitetablebg">
            <input TYPE="hidden" NAME="tacc_attention_name" value="商標對帳聯絡人">
			<input TYPE="hidden" NAME="otacc_attention">
			<input TYPE="text" NAME="tacc_attention" id="tacc_attention" size="40" maxlength="60" readonly value="">
		</td>
		<td class="lightbluetable" align="right">商標對帳聯絡人職稱：</td>
		<td class="whitetablebg">
            <input TYPE="hidden" NAME="tacc_title_name" value="商標對帳聯絡人職稱">
            <input TYPE="hidden" NAME="otacc_title">
		    <input TYPE="text" NAME="tacc_title" id="tacc_title" size="40" maxlength="40" readonly value="">
		</td>
	</tr>
	<tr class="dept_t">  
		<td class="lightbluetable" align="right">商標對帳電子郵件：</td>		  
		<td class="whitetablebg" style="width:550px;" >
            <input TYPE="hidden" NAME="tacc_email_name" value="商標對帳電子郵件">
            <input TYPE="hidden" NAME="otacc_email">
		    <input TYPE="text" NAME="tacc_email" id="tacc_email" SIZE="50" MAXLENGTH="100" value="">
		</td>
        <td class="lightbluetable" align="right">商標會計手機：</td>
		<td class="whitetablebg">
            <input TYPE="hidden" NAME="tacc_mobile_name" value="商標會計手機">
            <input TYPE="hidden" NAME="otacc_mobile">
		    <input TYPE="text" NAME="tacc_mobile" id="tacc_mobile" size="12" maxlength="10" value="" class="InputNumAndMarks" >
		</td>
	</tr>
	<tr class="dept_t">		  
		<td class="lightbluetable" align="right">商標對帳地址：</td>
		<td class="whitetablebg" colspan="3">
            <input TYPE="hidden" NAME="tacc_zip_name" value="商標對帳地址郵遞區號">
            <input TYPE="hidden" NAME="otacc_zip">
            <input TYPE="hidden" NAME="tacc_addr1_name" value="商標對帳地址1">
            <input TYPE="hidden" NAME="otacc_addr1">
            <input TYPE="hidden" NAME="tacc_addr2_name" value="商標對帳地址2">
            <input TYPE="hidden" NAME="otacc_addr2">
		郵遞區號
		<input TYPE="text" NAME="tacc_zip" id="tacc_zip" size="8" maxlength="8" value="" class="InputNumOnly">
		<input type="text" name="tacc_addr1" id="tacc_addr1" size="40" maxlength="44" class="sedit" value="">
		<input type="text" name="tacc_addr2" id="tacc_addr2" size="40" maxlength="44" class="sedit"  value="">  		  
		<input type="button" name=btnaddracc_ap_t id="btnCopyTAccAddr" value="同証照地址" class="cbutton" style="cursor:hand" >&nbsp;
		</td>
	</tr>
	<tr class="dept_t">
		<td class="lightbluetable" align="right">商標會計電話：</td>
		<td class="whitetablebg">
            <input TYPE="hidden" NAME="tacc_tel0_name" value="商標會計電話區碼">
            <input TYPE="hidden" NAME="otacc_tel0">
            <input TYPE="hidden" NAME="tacc_tel_name" value="商標會計電話">
            <input TYPE="hidden" NAME="otacc_tel">
            <input TYPE="hidden" NAME="tacc_tel1_name" value="商標會計電話分機">
            <input TYPE="hidden" NAME="otacc_tel1">
			(<input TYPE="text" NAME="tacc_tel0" id="tacc_tel0" size="4" maxlength="4" value="" class="InputNumOnly">)
			<input TYPE="text" NAME="tacc_tel" id="tacc_tel" size="11" maxlength="10" value="" class="InputNumAndMarks" >-
			<input TYPE="text" NAME="tacc_tel1" id="tacc_tel1" size="11" maxlength="10" value="" class="InputNumAndMarks" >
		</td>
		<td class="lightbluetable" align="right">商標會計傳真：</td>
		<td class="whitetablebg">
            <input TYPE="hidden" NAME="tacc_fax_name" value="商標會計傳真">
            <input TYPE="hidden" NAME="otacc_fax">
		    <input TYPE="text" NAME="tacc_fax" id="tacc_fax" size="22" maxlength="20" class="sedit" readonly value="" onkeyup="value=value.replace(/[^\d\*\-\#\.]/g,'')">
		</td>
	</tr>
    
	<tr class="dept_p">
		<td class="lightbluetable" align="right">專利對帳聯絡人：</td>
		<td class="whitetablebg">
            <input TYPE="hidden" NAME="pacc_attention_name" value="專利對帳聯絡人">
            <input TYPE="hidden" NAME="opacc_attention">
			<input TYPE="text" NAME="pacc_attention" id="pacc_attention" size="40" maxlength="60" value="">
		</td>
		<td class="lightbluetable" align="right">專利對帳聯絡人職稱：</td>
		<td class="whitetablebg">
            <input TYPE="hidden" NAME="pacc_title_name" value="專利對帳聯絡人職稱">
            <input TYPE="hidden" NAME="opacc_title">
		    <input TYPE="text" NAME="pacc_title" id="pacc_title" size="40" maxlength="40" value=""></td>
	</tr>
	<tr class="dept_p">  
		<td class="lightbluetable" align="right">專利對帳電子郵件：</td>		  
		<td class="whitetablebg">
            <input TYPE="hidden" NAME="pacc_email_name" value="專利對帳電子郵件">
            <input TYPE="hidden" NAME="opacc_email">
		    <input TYPE="text" NAME="pacc_email" id="pacc_email" SIZE="50" MAXLENGTH="100" value="">
		</td>
        <td class="lightbluetable" align="right">專利會計手機：</td>
		<td class="whitetablebg">
            <input TYPE="hidden" NAME="acc_mobile_name" value="專利會計手機">
            <input TYPE="hidden" NAME="oacc_mobile">
			<input TYPE="text" NAME="acc_mobile" id="acc_mobile" size="12" maxlength="10" value="" class="InputNumAndMarks" >
		</td>
	</tr>
	<tr class="dept_p">		  
		<td class="lightbluetable" align="right">專利對帳地址：</td>
		<td class="whitetablebg" colspan="3">
            <input TYPE="hidden" NAME="acc_zip_name" value="專利對帳地址郵遞區號">
            <input TYPE="hidden" NAME="oacc_zip">
            <input TYPE="hidden" NAME="acc_addr1_name" value="專利對帳地址1">
            <input TYPE="hidden" NAME="oacc_addr1">
            <input TYPE="hidden" NAME="acc_addr2_name" value="專利對帳地址2">
            <input TYPE="hidden" NAME="oacc_addr2">
         郵遞區號<input TYPE="text" NAME="acc_zip" id="acc_zip" size="8" maxlength="8" value="" class="InputNumOnly">
		<input type="text" name="acc_addr1" id="acc_addr1" size="40" maxlength="44" value="">
		<input type="text" name="acc_addr2" id="acc_addr2" size="40" maxlength="44" value="">  		  
		<input type="button" name=btnaddracc id="btnCopyPAccAddr" value="同証照地址" class="cbutton" style="cursor:hand">
		</td>
	</tr>
	<tr class="dept_p">
		<td class="lightbluetable" align="right">專利會計電話：</td>
		<td class="whitetablebg">
			<input TYPE="hidden" NAME="acc_tel0_name" value="專利會計電話區碼">
			<input TYPE="hidden" NAME="acc_tel_name" value="專利會計電話">
			<input TYPE="hidden" NAME="acc_tel1_name" value="專利會計電話分機">
			<input TYPE="hidden" NAME="oacc_tel0" value="">
			<input TYPE="hidden" NAME="oacc_tel" value="">
			<input TYPE="hidden" NAME="oacc_tel1" value="">
			(<input TYPE="text" NAME="acc_tel0" id="acc_tel0" size="4" maxlength="4" value="" class="InputNumOnly">)
			<input TYPE="text" NAME="acc_tel" id="acc_tel" size="11" maxlength="10"  value="" class="InputNumAndMarks">-
			<input TYPE="text" NAME="acc_tel1" id="acc_tel1" size="11" maxlength="10"  value="" class="InputNumAndMarks"></td>
		<td class="lightbluetable" align="right">專利會計傳真：</td>
		<td class="whitetablebg">
		<input TYPE="hidden" NAME="acc_fax_name" value="專利會計傳真">
		<input TYPE="hidden" NAME="oacc_fax" value="">
		<input TYPE="text" NAME="acc_fax" id="acc_fax" size="22" maxlength="20" value="" class="InputNumAndMarks"></td>
	</tr>
    <tr>
        <td class="lightbluetable" align="right">扣繳憑單聯絡人：</td>
		<td class="whitetablebg">
            <input TYPE="hidden" NAME="tax_attention_name" value="扣繳憑單聯絡人">
            <input TYPE="hidden" NAME="otax_attention">
			<input TYPE="text" NAME="tax_attention" id="tax_attention" size="40" maxlength="60" value="">
		</td>
        <td class="lightbluetable" align="right">扣繳憑單手機：</td>
		<td class="whitetablebg">
            <input TYPE="hidden" NAME="tax_mobile_name" value="扣繳憑單手機">
            <input TYPE="hidden" NAME="otax_mobile">
		    <input TYPE="text" NAME="tax_mobile" id="tax_mobile" SIZE="12" MAXLENGTH="10"  value="" class="InputNumAndMarks">
		</td>
    </tr>
	<tr>		  
		<td class="lightbluetable" align="right">扣繳憑單地址：</td>
		<td class="whitetablebg" colspan="3">
		<input TYPE="hidden" NAME="tax_zip_name" value="扣繳憑單地址郵遞區號">
		<input TYPE="hidden" NAME="tax_addr1_name" value="扣繳憑單地址1">
		<input TYPE="hidden" NAME="tax_addr2_name" value="扣繳憑單地址2">
		<input TYPE="hidden" NAME="otax_zip" value="">
		<input TYPE="hidden" NAME="otax_addr1" value="">
		<input TYPE="hidden" NAME="otax_addr2" value="">
        郵遞區號<input TYPE="text" NAME="tax_zip" id="tax_zip" size="8" maxlength="8" value="" class="InputNumOnly">
		<input type="text" name="tax_addr1" id="tax_addr1" size="47" maxlength="44"  value="">
		<input type="text" name="tax_addr2" id="tax_addr2" size="47" maxlength="44"  value="">  		  
		<input type="button" name=btnaddrtax id="btnCopyPaddrToTaxAddr" value="<%=(dept == "P")?"同專利":"同商標"%>對帳地址" class="cbutton" style="cursor:hand" >
		</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right">扣繳憑單電話：</td>
		<td class="whitetablebg">
			<input TYPE="hidden" NAME="tax_tel0_name" value="扣繳憑單電話區碼">
			<input TYPE="hidden" NAME="tax_tel_name" value="扣繳憑單電話">
			<input TYPE="hidden" NAME="tax_tel1_name" value="扣繳憑單電話分機">
			<input TYPE="hidden" NAME="otax_tel0" value="">
			<input TYPE="hidden" NAME="otax_tel" value="">
			<input TYPE="hidden" NAME="otax_tel1" value="">
			(<input TYPE="text" NAME="tax_tel0" id="tax_tel0" size="4" maxlength="4"  value="" class="InputNumOnly">)
			<input TYPE="text" NAME="tax_tel" id="tax_tel" size="11" maxlength="10"  value="" class="InputNumAndMarks">-
			<input TYPE="text" NAME="tax_tel1" id="tax_tel1" size="11" maxlength="10" value="" class="InputNumAndMarks"></td>
		<td class="lightbluetable" align="right">扣繳憑單傳真：</td>
		<td class="whitetablebg">
		<input TYPE="hidden" NAME="tax_fax_name" value="扣繳憑單傳真">
		<input TYPE="hidden" NAME="otax_fax" value="">
		<input TYPE="text" NAME="tax_fax" id="tax_fax" size="22" maxlength="20"  value="" class="InputNumAndMarks"></td>
	</tr>
    <tr>
		<td class="lightbluetable" align="right">扣繳憑單電子郵件：</td>
		<td class="whitetablebg" colspan="3">
            <input TYPE="hidden" NAME="tax_email_name" value="扣繳憑單電子郵件">
            <input TYPE="hidden" NAME="otax_email">
		    <input TYPE="text" NAME="tax_email" id="tax_email" SIZE="50" MAXLENGTH="100"  value="">
		</td>
    </tr>
        <tr>
        <td class="lightbluetable" align="right">會計師聯絡人：</td>
		<td class="whitetablebg">
            <input TYPE="hidden" NAME="taxacc_attention_name" value="會計師聯絡人">
            <input TYPE="hidden" NAME="otaxacc_attention">
			<input TYPE="text" NAME="taxacc_attention" id="taxacc_attention" size="40" maxlength="60" value="">
		</td>
        <td class="lightbluetable" align="right">會計師手機：</td>
		<td class="whitetablebg">
            <input TYPE="hidden" NAME="taxacc_mobile_name" value="會計師手機">
            <input TYPE="hidden" NAME="otaxacc_mobile">
		    <input TYPE="text" NAME="taxacc_mobile" id="taxacc_mobile" SIZE="12" MAXLENGTH="10"  value="" class="InputNumAndMarks">
		</td>
    </tr>
	<tr>		  
		<td class="lightbluetable" align="right">會計師地址：</td>
		<td class="whitetablebg" colspan="3">
		<input TYPE="hidden" NAME="taxacc_zip_name" value="會計師地址郵遞區號">
		<input TYPE="hidden" NAME="taxacc_addr1_name" value="會計師地址1">
		<input TYPE="hidden" NAME="taxacc_addr2_name" value="會計師地址2">
		<input TYPE="hidden" NAME="otaxacc_zip" value="">
		<input TYPE="hidden" NAME="otaxacc_addr1" value="">
		<input TYPE="hidden" NAME="otaxacc_addr2" value="">
        郵遞區號<input TYPE="text" NAME="taxacc_zip" id="taxacc_zip" size="8" maxlength="8" value="" class="InputNumOnly">
		<input type="text" name="taxacc_addr1" id="taxacc_addr1" size="47" maxlength="44"  value="">
		<input type="text" name="taxacc_addr2" id="taxacc_addr2" size="47" maxlength="44"  value="">  		  
		<input type="button" name=btnaddrtax id="btnCopyPaddrToTaxAccAddr" value="<%=(dept == "P")?"同專利":"同商標"%>對帳地址" class="cbutton"  onclick="" >
		</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right">會計師電話：</td>
		<td class="whitetablebg">
			<input TYPE="hidden" NAME="taxacc_tel0_name" value="會計師電話區碼">
			<input TYPE="hidden" NAME="taxacc_tel_name" value="會計師電話">
			<input TYPE="hidden" NAME="taxacc_tel1_name" value="會計師電話分機">
			<input TYPE="hidden" NAME="otaxacc_tel0" value="">
			<input TYPE="hidden" NAME="otaxacc_tel" value="">
			<input TYPE="hidden" NAME="otaxacc_tel1" value="">
			(<input TYPE="text" NAME="taxacc_tel0" id="taxacc_tel0" size="4" maxlength="4"  value="" class="InputNumOnly">)
			<input TYPE="text" NAME="taxacc_tel" id="taxacc_tel" size="11" maxlength="10"  value="" class="InputNumAndMarks">-
			<input TYPE="text" NAME="taxacc_tel1" id="taxacc_tel1" size="11" maxlength="10" value="" class="InputNumAndMarks"></td>
		<td class="lightbluetable" align="right">會計師傳真：</td>
		<td class="whitetablebg">
            <input TYPE="hidden" NAME="taxacc_fax_name" value="會計師傳真">
            <input TYPE="hidden" NAME="otaxacc_fax">
		    <input TYPE="text" NAME="taxacc_fax" id="taxacc_fax" size="22" maxlength="20"  value="" class="InputNumAndMarks">
		</td>
	</tr>
    <tr>
		<td class="lightbluetable" align="right">會計師電子郵件：</td>
		<td class="whitetablebg" colspan="3">
            <input TYPE="hidden" NAME="taxacc_email_name" value="會計師電子郵件">
            <input TYPE="hidden" NAME="otaxacc_email">
		    <input TYPE="text" NAME="taxacc_email" id="taxacc_email" SIZE="50" MAXLENGTH="100"  value="">
		</td>
    </tr>
	<tr>
		<td class="lightbluetable" align="right">會計備註說明：</td>
		<td class="whitetablebg" colspan="3">
			<input TYPE="hidden" NAME="acc_remark_name" value="會計備註說明">
			<input TYPE="hidden" NAME="oacc_remark" value="">
			<textarea rows="5" cols="80" name="acc_remark" id="acc_remark"></textarea>
		</td>
	</tr>
	<tr>		  
		<td class="lightbluetable" align="right">郵寄雜誌：</td>
		<td class="whitetablebg">
		<input TYPE="hidden" NAME="mag_name" value="郵寄雜誌">
		<input type="hidden" name="hmag" value="">
		<input TYPE="hidden" NAME="omag" value="">
		<input TYPE="radio" NAME="mag" value="Y" >需要
		<input TYPE="radio" NAME="mag" value="N" checked >不需要</td>
		<td class="lightbluetable" align="right">債信：</td>
		<td class="whitetablebg">
			<input TYPE="hidden" NAME="rmark_code_name" value="債信">
			<input TYPE="hidden" NAME="ormark_code" value="">
			<select NAME="rmark_code" id="rmark_code" size="1" value="">
                <%#html_RmarkCode%>
			</select></td>
		</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right">顧問種類：</td>
		<td class="whitetablebg">
			<input TYPE="hidden" NAME="con_code_name" value="顧問種類">
			<input TYPE="hidden" NAME="ocon_code" value="">
			<select NAME="con_code" id="con_code" SIZE="1">
                <%#html_H %>
			</select>
		</td>
		<td class="lightbluetable" align="right">顧問迄日：</td>
		<td class="whitetablebg">
            <input TYPE="hidden" NAME="con_term_name" value="顧問迄日">
			<input TYPE="hidden" NAME="ocon_term">
            <input type="text" name="con_term" id="con_term" size="10" readonly="readonly" class="dateField">
		</td>
	</tr>
	<tr id="tr_T1">
		<td class="lightbluetable" align="right"><%#(dept == "T")?"※":""%>商標營洽：</td>
		<td class="whitetablebg">
			<input TYPE="hidden" NAME="tscode_name" id="tscode_name" value="商標營洽">
            <input TYPE="hidden" NAME="otscode">
			<select NAME="tscode" id="tscode" size="1" >
                <%=html_TScode %>
				<%--<option value="t">t_部門(開放客戶)</option>
	  			<option value="">_部門(開放客戶)</option>--%>
			</select>
		</td>
		<td class="lightbluetable" align="right"><%#(dept == "T")?"※":""%>商標客戶等級：</td>
		<td class="whitetablebg">
			<input TYPE="hidden" NAME="tlevel_name" value="商標客戶等級">
			<input TYPE="hidden" NAME="otlevel">
			<select NAME="tlevel" id="tlevel" size="1" ><%=html_level%></select>
		</td>
	</tr>
	<tr id="tr_T2">
		<td class="lightbluetable" align="right">商標折扣：</td>
		<td class="whitetablebg">
			<input TYPE="hidden" NAME="tdis_type_name" value="商標折扣">
			<input TYPE="hidden" NAME="otdis_type" value="">
			<select NAME="tdis_type" id="tdis_type" size="1" ><%=html_B%> </select>
		</td>
		<td class="lightbluetable" align="right">商標付款：</td>
		<td class="whitetablebg">
			<input TYPE="hidden" NAME="tpay_type_name" value="商標付款">
			<input TYPE="hidden" NAME="otpay_type" value="">
			<select NAME="tpay_type" id="tpay_type" size="1" value="" ><%=html_Payment%></select>
		    ，月份：
            <input TYPE="hidden" NAME="tpay_typem_name" value="商標付款月份">
			<input TYPE="hidden" NAME="otpay_typem" value="">
            <select name="tpay_typem" id="tpay_typem" size="1" >
		        <option value="">請選擇</option>
		        <option value=""></option>
		    </select>
		</td>
	</tr>
        
	<tr id="tr_T3"><!--2012/6/20新增欄位begin-->
		<td class="lightbluetable" align="right">商標專案付款條件：</td>
		<td class="whitetablebg" colspan=3>
            <input TYPE="hidden" NAME="tspay_flag_name" value="商標專案付款條件">
			<input TYPE="hidden" NAME="otspay_flag">
			<input TYPE="radio" NAME="tspay_flag" value="Y" disabled >有
		    <input TYPE="radio" NAME="tspay_flag" value="N" disabled checked>無
	   </td>
	</tr><!--2012/6/20新增欄位end-->
	
	<tr id="tr_P1">
		<td class="lightbluetable" align="right"><%#(dept == "P")?"※":""%>專利營洽：</td>
		<td class="whitetablebg">
			<input TYPE="hidden" NAME="pscode_name" value="專利營洽">
            <input TYPE="hidden" NAME="opscode">
			<select NAME="pscode" id="pscode" size="1" >
                <%=html_PScode %>
				
			</select>
		</td>
		<td class="lightbluetable" align="right" nowrap><%#(dept == "P")?"※":""%>專利客戶等級：</td>
		<td class="whitetablebg">
			<input TYPE="hidden" NAME="plevel_name" value="專利客戶等級">
			<input TYPE="hidden" NAME="oplevel" value="">
			<select NAME="plevel" id="plevel" size="1" ><%=html_level%></select>
		</td>
	</tr>
	<tr id="tr_P2">
		<td class="lightbluetable" align="right">專利折扣：</td>
		<td class="whitetablebg">
			<input TYPE="hidden" NAME="pdis_type_name" value="專利折扣">
			<input TYPE="hidden" NAME="opdis_type" value="">
			<select NAME="pdis_type" id="pdis_type" size="1" ><%=html_B%></select>
		</td>
		<td class="lightbluetable" align="right">專利付款：</td>
		<td class="whitetablebg">
			<input TYPE="hidden" NAME="ppay_type_name" value="專利付款">
			<input TYPE="hidden" NAME="oppay_type">
			<select NAME="ppay_type" id="ppay_type" size="1" onchange="cust11form.ppaytypeChange()"><%=html_Payment%></select>
		    ，月份：
            <input TYPE="hidden" NAME="ppay_typem_name" value="專利付款月份">
			<input TYPE="hidden" NAME="oppay_typem">
            <select name="ppay_typem" id="ppay_typem" size="1">
		        <option value="">請選擇</option>
                <%=month %>
		    </select>
		</td>
	</tr>
	<tr id="tr_P3"><!--2012/6/20新增欄位begin-->
		<td class="lightbluetable" align="right">專利專案付款條件：</td>
		<td class="whitetablebg" colspan=3>
			<input TYPE="hidden" NAME="pspay_flag_name" value="專利專案付款條件">
			<input type="hidden" name="hpspay_flag" value="">
			<input TYPE="hidden" NAME="opspay_flag" value="">
			<input TYPE="radio" NAME="pspay_flag" value="Y" disabled >有
		    <input TYPE="radio" NAME="pspay_flag" value="N" disabled checked >無
            <br />
		    <em id="showpspay" style="color: #0000FF; display:none" class="emTag" >
                專案付款條件請核單上傳案件：<input type="text" id="pspay_seq" size="12"/>、
                接洽序號：<input type="text" id="pspay_refno_1" size="12"/>、
                交辦單號：<input type="text" id="pspay_refno_2" size="12"/>
                <img src="../images/annex.gif">
		    </em>
	   </td>
	</tr><!--2012/6/20新增欄位end-->
	<tr id="tr_payout">
		<TD class=lightbluetable align=right>代收代付請款：</TD>
		<TD class=whitetablebg colspan="3">
			<input type="hidden" name="payout_mark_name" value="代收代付請款">
			<input type="hidden" name="oldpayout_mark" value="">
			<input type="hidden" name="hpayout_mark" value="">
			<input type="hidden" name="payout_markcnt" value="3">
			<input type="radio" name="payout_mark" disabled value=""  checked><font title="當客戶之「代收代付請款註記」設定為「非代收代付」時，本次請款規費實報實銷註記不可設定「規費代收代付」">非代收代付</font>
			<input type="radio" name="payout_mark" disabled value="Y1"  ><font title="關於非大陸案年費由代理人繳納，大陸年費由北京聖島繳納。">全程代收代付</font>
			<input type="radio" name="payout_mark" disabled value="Y2"  ><font title="關於非大陸案年費由晟業繳納，大陸年費由北京聖島繳納。">代收代付，但非大陸案年費委由晟業繳納</font>
		</TD>
	</tr>
	<tr id="tr_tdate">
		<td class="lightbluetable" align="right">內商：</td>
		<td class="whitetablebg"><input type="text" name="dmt_date" id="dmt_date" readonly class="sedit" value=""></td>
		<td class="lightbluetable" align="right">外商：</td>
		<td class="whitetablebg"><input type="text" name="ext_date" id="ext_date" readonly class="sedit" value=""></td>
	</tr>
	<tr id="tr_pdate">
		<td class="lightbluetable" align="right">內專：</td>
		<td class="whitetablebg"><input type="text" name="dmp_date" id="dmp_date" readonly class="sedit" value=""></td>
		<td class="lightbluetable" align="right">外專：</td>
		<td class="whitetablebg"><input type="text" name="exp_date" id="exp_date" readonly class="sedit" value=""></td>
	</tr>
	<tr id="tr_contract" style="display:none">
		<td class="lightbluetable" align="right">契約書：</td>
		<td class="whitetablebg">
			<input type="radio" name="contract" onclick="vbscript:contract_onclick">無<br>
			<input type="radio" name="contract" onclick="vbscript:contract_onclick">有
			<span id="span_contract" style="display:none">
				<input type=button class="sgreenbutton"  name="btn_attachup_contract" value="上傳">
				<input type=button class="sgreenbutton" name="btn_attachvicw_contract" value="檢視">
			(<input type="radio" name="cust_sign" ><font color='red' title=""><u>單一客戶簽署</u></font>&nbsp;
			<input type="radio" name="cust_sign" ><font color='red' title=""><u>多個客戶合併簽署</u></font>
			<input type="button" class="sgreenbutton"  name="btn_contractlist"  value="加入">
			)
			</span>
			<span id="span_ref_cust_seq" style="display:none">
				<br>　　　　　　　　　　　　　　　　&nbsp;
				<select name="show_ref_cust_seq" id="show_ref_cust_seq" multiple=true>
					<option value="14702" value1="cust_seq">N14702_林玉杯</option>
					<option value="14694" value1="cust_seq">N14694_黎青龍</option>
					<option value="14690" value1="cust_seq">N14690_朱中一</option>
				</select>
			</span>
			<input TYPE="hidden" NAME="ref_cust_seq" value="">
		</td>
		<td class="lightbluetable" align="right"><span id="span_contract_tran_date">契約書異動日期：</span></td>
		<td class="whitetablebg">
			<input TYPE="text" NAME="contract_tran_date" SIZE="11" MAXLENGTH="10" readonly class=sedit value="">
		</td>
	</tr>
	<tr id="tr_contracta" style="display:none">
		<td class="lightbluetable" align="right">總契約書：</td>
		<td class="whitetablebg">
			<input type="radio" name="contracta" onclick="vbscript:contracta_onclick">無<br>
			<input type="radio" name="contracta" onclick="vbscript:contracta_onclick">有
			<span id="span_contracta" style="display:none">
				<input type=button class="sgreenbutton"  name="btn_attachup_contractall" value="上傳">
				<input type=button class="sgreenbutton" name="btn_attachvicw_contractall" value="檢視">
			(<input type="radio" name="cust_signa" ><font color='red' title=""><u>單一客戶簽署</u></font>&nbsp;
			<input type="radio" name="cust_signa" ><font color='red' title=""><u>多個客戶合併簽署</u></font>
			<input type="button" class="sgreenbutton"  name="btn_contractlista" value="加入">
			)
			</span>
			<span id="span_ref_cust_seqa" style="display:none">
				<br>　　　　　　　　　　　　　　　　&nbsp;
				<select name="show_ref_cust_seqa" id="show_ref_cust_seqa" multiple=true>
					<option value="14702" value1="cust_seq">N14702_林玉杯</option>
					<option value="14694" value1="cust_seq">N14694_黎青龍</option>
				</select>
			</span>
			<input TYPE="hidden" NAME="ref_cust_seqa" value="">
		</td>
		<td class="lightbluetable" align="right"><span id="span_contracta_tran_date">總契約書異動日期：</span></td>
		<td class="whitetablebg">
			<input TYPE="text" NAME="contracta_tran_date" SIZE="11" MAXLENGTH="10" readonly class=sedit value="">
		</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right">備註說明：</td>
		<td class="whitetablebg" colspan="3">
			<input TYPE="hidden" NAME="cust_remark_name" value="備註說明">
			<input TYPE="hidden" NAME="ocust_remark" value="">
			<textarea rows="5" cols="80"  name="cust_remark" id="cust_remark"></textarea>
		</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right">備註：</td>
		<td class="whitetablebg" colspan="3"><input type="text" name="mark" id="mark" readonly class="sedit" size="1">
	</tr>

</table>

<script language="javascript" type="text/javascript">
    //****每個form都有自已的別名
    var cust11form = {};
    //畫面初始化
    cust11form.init = function () {

    }

    
    $("#btnCopyAddr").click(function (e) {
        $("#apatt_zip").val($("#ap_zip").val());
        $("#apatt_addr1").val($("#ap_addr1").val());
        $("#apatt_addr2").val($("#ap_addr2").val());
    });
    $("#btnCopyPaddrToTaxAddr").click(function (e) {
        $("#tax_zip").val($("#acc_zip").val());
        $("#tax_addr1").val($("#acc_addr1").val());
        $("#tax_addr2").val($("#acc_addr2").val());
    });
    $("#btnCopyPaddrToTaxAccAddr").click(function (e) {
        $("#taxacc_zip").val($("#acc_zip").val());
        $("#taxacc_addr1").val($("#acc_addr1").val());
        $("#taxacc_addr2").val($("#acc_addr2").val());
    });
    $("#btnCopyPAccAddr").click(function (e) {
        $("#acc_zip").val($("#ap_zip").val());
        $("#acc_addr1").val($("#ap_addr1").val());
        $("#acc_addr2").val($("#ap_addr2").val());
    });
    $("#btnCopyTAccAddr").click(function (e) {
        $("#tacc_zip").val($("#ap_zip").val());
        $("#tacc_addr1").val($("#ap_addr1").val());
        $("#tacc_addr2").val($("#ap_addr2").val());
    });


    //資料綁定
    cust11form.bind = function (jData) {
        //$("#cust_area").val(jData.cust_area);
        //$("#cust_seq").val(jData.cust_seq);
        document.getElementById('cust_area_str').textContent = jData.cust_area;
        document.getElementById('cust_seq_str').textContent = jData.cust_seq;
        $("#cust_area").val(jData.cust_area);
        $("#cust_seq").val(jData.cust_seq);

        $("#ap_country").val(jData.ap_country);
        $("#apclass").val(jData.apclass);
        if ($("#apclass").val() == null) {
            $("#apclass").get(0).selectedIndex = 0;
        }
        $("#id_no").val(jData.id_no);
        $("#apsqlno").val(jData.apsqlno);
		
        $("#ref_seq").val(jData.ref_seq); $("input[name=oref_seq]").val(jData.ref_seq);
        $("#ref_seqName").val(jData.name1 + jData.name2);
        $("#ap_cname1").val(jData.ap_cname1);$("input[name=oap_cname1]").val(jData.ap_cname1);
        $("#ap_cname2").val(jData.ap_cname2);$("input[name=oap_cname2]").val(jData.ap_cname2);
        $("#ap_fcname").val(jData.ap_fcname);$("input[name=oap_fcname]").val(jData.ap_fcname);
        $("#ap_lcname").val(jData.ap_lcname);$("input[name=oap_lcname]").val(jData.ap_lcname);
        $("#ap_ename1").val(jData.ap_ename1);$("input[name=oap_ename1]").val(jData.ap_ename1);
        $("#ap_ename2").val(jData.ap_ename2);$("input[name=oap_ename2]").val(jData.ap_ename2);
        $("#ap_fename").val(jData.ap_fename);$("input[name=oap_fename]").val(jData.ap_fename);
        $("#ap_lename").val(jData.ap_lename);$("input[name=oap_lename]").val(jData.ap_lename);
        $("#ap_crep").val(jData.ap_crep);$("input[name=oap_crep]").val(jData.ap_crep);
        $("#ap_erep").val(jData.ap_erep);$("input[name=oap_erep]").val(jData.ap_erep);
        $("#ap_title").val(jData.ap_title);$("input[name=oap_title]").val(jData.ap_title);
        $("#ap_zip").val(jData.ap_zip);$("input[name=oap_zip]").val(jData.ap_zip);
        $("#ap_addr1").val(jData.ap_addr1);$("input[name=oap_addr1]").val(jData.ap_addr1);
        $("#ap_addr2").val(jData.ap_addr2);$("input[name=oap_addr2]").val(jData.ap_addr2);
        $("#ap_eaddr1").val(jData.ap_eaddr1);$("input[name=oap_eaddr1]").val(jData.ap_eaddr1);
        $("#ap_eaddr2").val(jData.ap_eaddr2);$("input[name=oap_eaddr2]").val(jData.ap_eaddr2);
        $("#ap_eaddr3").val(jData.ap_eaddr3);$("input[name=oap_eaddr3]").val(jData.ap_eaddr3);
        $("#ap_eaddr4").val(jData.ap_eaddr4);$("input[name=oap_eaddr4]").val(jData.ap_eaddr4);
        $("#apatt_zip").val(jData.apatt_zip);$("input[name=oapatt_zip]").val(jData.apatt_zip);
        $("#apatt_addr1").val(jData.apatt_addr1);$("input[name=oapatt_addr1]").val(jData.apatt_addr1);
        $("#apatt_addr2").val(jData.apatt_addr2);$("input[name=oapatt_addr2]").val(jData.apatt_addr2);
        $("#apatt_tel0").val(jData.apatt_tel0);$("input[name=oapatt_tel0]").val(jData.apatt_tel0);
        $("#apatt_tel").val(jData.apatt_tel);$("input[name=oapatt_tel]").val(jData.apatt_tel);
        $("#apatt_tel1").val(jData.apatt_tel1);$("input[name=oapatt_tel1]").val(jData.apatt_tel1);
        $("#apatt_fax").val(jData.apatt_fax);$("input[name=oapatt_fax]").val(jData.apatt_fax);
        $("#apatt_email").val(jData.apatt_email);$("input[name=oapatt_email]").val(jData.apatt_email);
        $("#www").val(jData.www);$("input[name=owww]").val(jData.www);
        $("#email").val(jData.email);$("input[name=oemail]").val(jData.email);
		
        $("#tacc_attention").val(jData.tacc_attention);$("input[name=otacc_attention]").val(jData.tacc_attention);
        $("#tacc_title").val(jData.tacc_title); $("input[name=otacc_title]").val(jData.tacc_title);
        $("#tacc_email").val(jData.tacc_email); $("input[name=otacc_email]").val(jData.tacc_email);
        $("#tacc_zip").val(jData.tacc_zip); $("input[name=otacc_zip]").val(jData.tacc_zip);
        $("#tacc_addr1").val(jData.tacc_addr1);$("input[name=otacc_addr1]").val(jData.tacc_addr1);
        $("#tacc_addr2").val(jData.tacc_addr2); $("input[name=otacc_addr2]").val(jData.tacc_addr2);
        $("#tacc_tel0").val(jData.tacc_tel0); $("input[name=otacc_tel0]").val(jData.tacc_tel0);
        $("#tacc_tel").val(jData.tacc_tel); $("input[name=otacc_tel]").val(jData.tacc_tel);
        $("#tacc_tel1").val(jData.tacc_tel1); $("input[name=otacc_tel1]").val(jData.tacc_tel1);
        $("#tacc_fax").val(jData.tacc_fax); $("input[name=otacc_fax]").val(jData.tacc_fax);
        $("#tacc_mobile").val(jData.tacc_mobile); $("input[name=otacc_mobile]").val(jData.tacc_mobile);
		
        $("#pacc_attention").val(jData.pacc_attention); $("input[name=opacc_attention]").val(jData.pacc_attention);
        $("#pacc_title").val(jData.pacc_title); $("input[name=opacc_title]").val(jData.pacc_title);
        $("#pacc_email").val(jData.pacc_email); $("input[name=opacc_email]").val(jData.pacc_email);
        $("#acc_zip").val(jData.acc_zip); $("input[name=oacc_zip]").val(jData.acc_zip);
        $("#acc_addr1").val(jData.acc_addr1); $("input[name=oacc_addr1]").val(jData.acc_addr1);
        $("#acc_addr2").val(jData.acc_addr2); $("input[name=oacc_addr2]").val(jData.acc_addr2);
        $("#acc_tel0").val(jData.acc_tel0); $("input[name=oacc_tel0]").val(jData.acc_tel0);
        $("#acc_tel").val(jData.acc_tel); $("input[name=oacc_tel]").val(jData.acc_tel);
        $("#acc_tel1").val(jData.acc_tel1); $("input[name=oacc_tel1]").val(jData.acc_tel1);
        $("#acc_fax").val(jData.acc_fax); $("input[name=oacc_fax]").val(jData.acc_fax);
        $("#acc_mobile").val(jData.acc_mobile);	$("input[name=oacc_mobile]").val(jData.acc_mobile);		

        $("#tax_zip").val(jData.tax_zip); $("input[name=otax_zip]").val(jData.tax_zip);
        $("#tax_addr1").val(jData.tax_addr1); $("input[name=otax_addr1]").val(jData.tax_addr1);
        $("#tax_addr2").val(jData.tax_addr2); $("input[name=otax_addr2]").val(jData.tax_addr2);
        $("#tax_tel0").val(jData.tax_tel0); $("input[name=otax_tel0]").val(jData.tax_tel0);
        $("#tax_tel").val(jData.tax_tel); $("input[name=otax_tel]").val(jData.tax_tel);
        $("#tax_tel1").val(jData.tax_tel1); $("input[name=otax_tel1]").val(jData.tax_tel1);
        $("#tax_fax").val(jData.tax_fax); $("input[name=otax_fax]").val(jData.tax_fax);
        $("#tax_attention").val(jData.tax_attention); $("input[name=otax_attention]").val(jData.tax_attention);
        $("#tax_mobile").val(jData.tax_mobile); $("input[name=otax_mobile]").val(jData.tax_mobile);
        $("#tax_email").val(jData.tax_email); $("input[name=otax_email]").val(jData.tax_email);
        $("#taxacc_attention").val(jData.taxacc_attention); $("input[name=otaxacc_attention]").val(jData.taxacc_attention);
        $("#taxacc_email").val(jData.taxacc_email); $("input[name=otaxacc_email]").val(jData.taxacc_email);
        $("#taxacc_zip").val(jData.taxacc_zip); $("input[name=otaxacc_zip]").val(jData.taxacc_zip);
        $("#taxacc_addr1").val(jData.taxacc_addr1); $("input[name=otaxacc_addr1]").val(jData.taxacc_addr1);
        $("#taxacc_addr2").val(jData.taxacc_addr2); $("input[name=otaxacc_addr2]").val(jData.taxacc_addr2);
        $("#taxacc_tel0").val(jData.taxacc_tel0); $("input[name=otaxacc_tel0]").val(jData.taxacc_tel0);
        $("#taxacc_tel").val(jData.taxacc_tel); $("input[name=otaxacc_tel]").val(jData.taxacc_tel);
        $("#taxacc_tel1").val(jData.taxacc_tel1); $("input[name=otaxacc_tel1]").val(jData.taxacc_tel1);
        $("#taxacc_fax").val(jData.taxacc_fax); $("input[name=otaxacc_fax]").val(jData.taxacc_fax);
        $("#taxacc_mobile").val(jData.taxacc_mobile); $("input[name=otaxacc_mobile]").val(jData.taxacc_mobile);
        $("#acc_remark").val(jData.acc_remark); $("input[name=oacc_remark]").val(jData.acc_remark);
		
        //郵寄
        $("input[name=mag]").each(function () {
            var way = $(this).val();
            var ischeck = jData.mag.indexOf(way);
            if (ischeck >= 0) {
                $(this).prop('checked', true);
                $("input[name=omag]").val(way);
            }
        });
		
        $("#rmark_code").val(jData.rmark_code); $("input[name=ormark_code]").val(jData.rmark_code);
        $("#con_code").val(jData.con_code); $("input[name=ocon_code]").val(jData.con_code);
        $("#con_term").val(dateReviver(jData.con_term, "yyyy/M/d")); $("input[name=ocon_term]").val(dateReviver(jData.con_term, "yyyy/M/d")); 

        //補商標營洽選單
        $("#tscode").val(jData.tscode); $("input[name=otscode]").val(jData.tscode);
        $("#tlevel").val(jData.tlevel); $("input[name=otlevel]").val(jData.tlevel);
        $("#tdis_type").val(jData.tdis_type); $("input[name=otdis_type]").val(jData.tdis_type);
        $("#tpay_type").val(jData.tpay_type); $("input[name=otpay_type]").val(jData.tpay_type);
        $("#tpay_typem").val(jData.tpay_typem); $("input[name=otpay_typem]").val(jData.tpay_typem);
		
        //商標專案付款條件
        $("input[name=tspay_flag]").each(function () {
            var way = $(this).val();
            var ischeck = jData.tspay_flag.indexOf(way);
            if (ischeck >= 0) {
                $(this).prop('checked', true);
            }
        });
		
        //補專利營洽選單
        $("#pscode").val(jData.pscode); $("input[name=opscode]").val(jData.pscode);
        $("#plevel").val(jData.plevel); $("input[name=oplevel]").val(jData.plevel);
        $("#pdis_type").val(jData.pdis_type); $("input[name=opdis_type]").val(jData.pdis_type);
        $("#ppay_type").val(jData.ppay_type); $("input[name=oppay_type]").val(jData.ppay_type);
        $("#ppay_typem").val(jData.ppay_typem); $("input[name=oppay_typem]").val(jData.ppay_typem);
		
        //專利專案付款條件
        $("#showpspay").hide();
        var showpspay_flag = false;
        $("input[name=pspay_flag]").each(function () {
            var way = $(this).val();
            var ischeck = jData.pspay_flag.indexOf(way);
            if (ischeck >= 0) {
                $(this).prop('checked', true);
                if (way == "Y") {
                    showpspay_flag = true;
                    $("#showpspay").show();
                }
            }
        });
        if (showpspay_flag == true) {
            var p = jData.pspay_refno.split(',');
            $("#pspay_seq").val(jData.pspay_seq);
            $("#pspay_refno_1").val(p[0]);
            $("#pspay_refno_2").val(p[1]);
        }

        //代收代付請款
        $("input[name=payout_mark]").each(function () {
            var way = $(this).val();
            var ischeck = jData.payout_mark.indexOf(way);
            if (ischeck >= 0) {
                $(this).prop('checked', true);
            }
        });

        $("#dmt_date").val(dateReviver(jData.dmt_date, "yyyy/M/d"));
        $("#ext_date").val(dateReviver(jData.ext_date, "yyyy/M/d"));
        $("#dmp_date").val(dateReviver(jData.dmp_date, "yyyy/M/d"));
        $("#exp_date").val(dateReviver(jData.exp_date, "yyyy/M/d"));

        $("#cust_remark").val(jData.cust_remark); $("input[name=ocust_remark]").val(jData.cust_remark);
        $("#mark").val(jData.mark);

    }

    cust11form.ChkApclass = function () {
        if ($("#apclass").val() == "") {
            alert("申請人種類為必選!");
            $("#apclass").focus();
            return false;
        }
    }
    

    //名稱自動帶入
    cust11form.ap_cname1onblur = function () {
        if ($("#apclass").val() == "B" && NulltoEmpty($("#ap_cname1").val()) != "") {
            var strfcname = $("#ap_cname1").val();
            $("#ap_fcname").val(strfcname.substring(0, 1));
            $("#ap_lcname").val(strfcname.substring(1, 5));
        }
    }

    cust11form.LockAll = function () {
        $(document.getElementById('#custz').getElementsByTagName('input')).each(function () {
            if ($(this).attr('type') == "button") {
                $(this).hide();
            }
            else {
                $(this).lock();
            }
        })  
        $(document.getElementById('#custz').getElementsByTagName('select')).each(function () {
            $(this).lock();
        })
        $(document.getElementById('#custz').getElementsByTagName('textarea')).each(function () {
            $(this).lock();
        })
        $("#con_term").removeClass('dateField');
    }

    cust11form.T_ColLock = function () {
        $("#tscode").lock();
        $("#tacc_attention, #tacc_title, #tacc_email, #tacc_mobile").lock();
        $("#tacc_zip, #tacc_addr1, #tacc_addr2").lock();
        $("#tacc_tel0, #tacc_tel, #tacc_tel1, #tacc_fax").lock();
        $("#btnCopyTAccAddr").hide();
        $("#tscode").lock();
        $("#tlevel").lock();
        $("#tdis_type").lock();
        $("#tpay_type").lock();
        $("#tpay_typem").lock();
    }

    cust11form.EditLock = function () {
        $("#ap_country").lock();
        $("#apclass").lock();
        $("#id_no").lock();
        $("#tr_payout").lock();
        //$("#tr_level").hide();
        //$("#tr_distype").hide();
        $("#ap_cname1, #ap_cname2, #ap_fcname, #ap_lcname").lock();
        $("#ap_ename1, #ap_ename2, #ap_fename, #ap_lename").lock();
    }


    //待確認權限顯示問題
    var s = <%="'" + submitTask + "'"%>;
    if (s != "A") {
        $("#pscode").append(new Option("np_部門(開放客戶)", ""));
        //"<option>p_部門(開放客戶)</option>";
        //<option value="">_部門(開放客戶)</option>
    }

    cust11form.ppaytypeChange = function () {
        var ppay = $("#ppay_type").val();
        if (ppay == "02" || ppay == "04" || ppay == "05") {
            document.getElementById('ppay_typem').disabled = false;
        }
        else {
            $("#ppay_typem").val("");
            document.getElementById('ppay_typem').disabled = true;
        }
    }

    cust11form.apclassChange = function () {
        var idname = document.getElementById('id_no_Name');
        if ($("#apclass").val() == "") {
            document.getElementById('id_no').disabled = true;
            idname.textContent = "";
            //$("#id_no_Name").textContent = "test";//$("#id_no_Name").val("TEST");
        }
        else {
            document.getElementById('id_no').disabled = false;

            if ($("#apclass").val().substring(0, 1) == "B" || $("#apclass").val().substring(0, 1) == "C") {
                $("#ap_fcname").show();
                $("#ap_lcname").show();
                $("#ap_fename").show();
                $("#ap_lename").show();
            }
            else {
                $("#ap_fcname").hide();
                $("#ap_lcname").hide();
                $("#ap_fename").hide();
                $("#ap_lename").hide();
            }

            switch ($("#apclass").val()) {
                case "AA":
                    idname.textContent = "※統一編號：";
                    document.getElementById('id_no').disabled = true;
                    break;
                case "AB":
                case "AC":
                case "AD":
                case "AE":
                    idname.textContent = "※統一編號：";
                    break;

                case "B":
                    idname.textContent = "※身份證號碼：";
                    break;

                case "CA":
                    idname.textContent = "※外國人流水號：";
                    document.getElementById('id_no').disabled = true;
                    break;

                case "CB":
                case "CT":
                    idname.textContent = "※外國人指定號：";
                    break;
                default:
                    break;
            }
        }
    }

    cust11form.Chkid_noDouble = function () {
        if ($("#id_no").val() == "") {
            return;
        }
        //檢查編號重複
        var b = false;
        var SQLStr = "select apcust_no from apcust where apcust_no = '" + $("#id_no").val() + "'";
        $.ajax({
            url: "../AJAX/JsonGetSqlData.aspx",
            type: "get",
            async: false,
            cache: false,
            data: { sql: SQLStr },
            success: function (json) {
                var JSONdata = $.parseJSON(json);
                if (JSONdata.length == 0) { }
                else {
                    alert($("#id_no_name").text() + "號碼重複，請重新輸入!");
                    b = true;
                    $("#id_no").focus();
                }
            },
            beforeSend: function (jqXHR, settings) {
                jqXHR.url = settings.url;
            },
            error: function (jqXHR, textStatus, errorThrown) {
                alert("\n資料擷取剖析錯誤 !\n" + jqXHR.url);
            }
        });
        if (b == true) { return false; }
    }

    cust11form.Chkid_no = function () {
        if ($("#id_no").val() == "") {
            return;
        }
        if ($("#apclass").val() != "") {

            switch ($("#apclass").val()) {
                case "AB":
                case "AC":
                case "AD":
                case "AE":
                    if (fChkDataLen2($("#id_no")[0], 8, "申請人編號") == "") { $("#id_no").focus(); return false; }
                    if (chkID($("#id_no").val(), "TaxID") == true) { $("#id_no").focus(); return false; }
                    break;

                case "B":
                case "CB":
                    if (fChkDataLen2($("#id_no")[0], 10, "申請人編號") == "") { $("#id_no").focus(); return false; }
                    if (chkID($("#id_no").val(), "ID") == true) { $("#id_no").focus(); return false; }
                    break;

                case "CT":
                    if (fChkDataLen2($("#id_no")[0], 6, "申請人編號") == "") {
                        $("#id_no").focus();
                        return false;
                    };
                    break;
                default:
                    break;
            }
        }
    }

    cust11form.Chkref_seqDouble = function () {
        if ($("#ref_seq").val() == "") {
            return;
        }
        //檢查客戶群組編號重複
        var b = false;
        var SQLStr = "select ap_cname1,ap_cname2 from apcust where cust_seq = '" + $("#ref_seq").val() + "'";
        $.ajax({
            url: "../AJAX/JsonGetSqlData.aspx",
            type: "get",
            async: false,
            cache: false,
            data: { sql: SQLStr },
            success: function (json) {
                var JSONdata = $.parseJSON(json);
                if (JSONdata.length == 0)
                { 
                    alert("客戶群組號碼"+$("#ref_seq").text() + "不存在，請重新輸入!");
                    b = true;
                    $("#ref_seq").focus();
                }
                else
                {
                    var data = JSONdata[0];
                    $("#ref_seqName").val(data["ap_cname1"]+data["ap_cname2"]);
                }
            },
            beforeSend: function (jqXHR, settings) {
                jqXHR.url = settings.url;
            },
            error: function (jqXHR, textStatus, errorThrown) {
                alert("\n資料擷取剖析錯誤 !\n" + jqXHR.url);
            }
        });
        if (b == true) { return false; }
    }



    cust11form.chkSaveAddData = function () {
        if ($("#apclass").val() == "") {
            alert("客戶種類為必填!");
            $("#apclass").focus();
            return false;
        }
        else
        {
            if ($("#apclass").val() == "AA" || $("#apclass").val() == "CA") { }
            else
            {
                if ($("#id_no").val() == "") {
                    alert(document.getElementById('id_no_Name').textContent + "為必填!");
                    $("#id_no").focus();
                    return false;
                }
                else
                {
                    if (cust11form.Chkid_no() == false) { return false;}
                }
            }
        }

        if (chkNull("客戶名稱", $("#ap_cname1"))) return false;

        if ($("#ap_country").val() == "") {
            alert("申請人國籍為必選!");
            return false;
        }
        else {
            if ($("#apclass").val() == "B" && $("#ap_country").val() != "T") {
                alert("本國人不可選擇外國國籍!");
                return false;
            }

            if (($("#apclass").val() == "CA" || $("#apclass").val() == "CB" || $("#apclass").val() == "CT") &&
                $("#ap_country").val() == "T") {
                alert("外國人不可選擇中華民國國籍!");
                return false;
            }
        }

        var deptStr = <%= "'" + Sys.GetSession("dept") + "'"%>;
        if (deptStr == "P")
        {
            //if (chkNull("客戶等級", $("#p1evel"))) return false;
            //if (chkNull("專利營洽", $("#pscode"))) return false;
            if ($("#plevel").val() == "") {
                alert("客戶等級為必選!");
                return false;
            }
            if ($("#pscode").val() == "") {
                alert("營洽為必選!");
                return false;
            }
        }
        else
        {
            //if (chkNull("客戶等級", $("#t1evel"))) return false;
            //if (chkNull("商標營洽", $("#tscode"))) return false;
            if ($("#tlevel").val() == "") {
                alert("客戶等級為必選!");
                return false;
            }
            if ($("#tscode").val() == "") {
                alert("營洽為必選!");
                return false;
            }
        }

    }//chksavedata




</script>