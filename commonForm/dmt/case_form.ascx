<%@ Control Language="C#" ClassName="case_form" %>

<script runat="server">
    protected string prgid = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string SQL = "";
    protected string branch = "";
    protected string opt_sqlno = "";

    protected string tfy_oth_code = "", F_tscode = "", tfy_Ar_mark = "", tfy_source = "";
    protected string tfy_send_way = "", tfy_receipt_title = "";

    private void Page_Load(System.Object sender, System.EventArgs e) {
        branch = Request["branch"] ?? "";
        opt_sqlno = Request["opt_sqlno"] ?? "";

        using (DBHelper cnn = new DBHelper(Conn.Sysctrl).Debug(false)) {
            tfy_oth_code = SHtml.Option(cnn, "SELECT branch,branchname FROM branch_code WHERE class = 'branch'", "{branch}", "{branch}_{branchname}");
        }
        using (DBHelper connB = new DBHelper(Conn.OptB(branch)).Debug(false)) {
            F_tscode = SHtml.Option(connB, "select distinct scode,sc_name,scode1 from sysctrl.dbo.vscode_roles where branch='"+branch+"' and dept='T' and syscode='"+branch+"Tbrt' and roles='sales' order by scode1", "{scode}", "{sc_name}");
            //tfy_Ar_mark = SHtml.Option(connB, "select cust_code,code_name from cust_code where code_type='ar_mark' and (mark1 like '%" + Session["SeBranch"] + Session["Dept"] + "%' or mark1 is null)", "{cust_code}", "{code_name}");
            //tfy_source = SHtml.Option(connB, "select cust_code,code_name from cust_code where code_type='Source' AND cust_code<> '__' AND End_date is null order by cust_code", "{cust_code}", "({cust_code}---{code_name})");
            tfy_send_way = SHtml.Option(connB, "select cust_code,code_name from cust_code where code_type='GSEND_WAY' order by sortfld", "{cust_code}", "{code_name}");
            tfy_receipt_title = SHtml.Option(connB, "select cust_code,code_name,mark from cust_code where code_type='rec_titleT' order by sortfld", "{cust_code}", "{code_name}");
        }
        tfy_Ar_mark = Funcs.getcust_code_mul("ar_mark","and (mark1 like '%" + Session["SeBranch"] + Session["Dept"] + "%' or mark1 is null)","").Option("{cust_code}", "{code_name}");
        tfy_source = Funcs.getcust_code_mul("Source","AND cust_code<> '__' AND End_date is null","cust_code").Option("{cust_code}", "({cust_code})---{code_name}");

        this.DataBind();
    }
</script>

<%=Sys.GetAscxPath(this)%>
<TABLE border=0 class=bluetable cellspacing=1 cellpadding=2 width="100%">
<TR>
	<td class="lightbluetable" align=right>洽案營洽 :</td>
	<td class="whitetablebg" align="left" colspan=5>
		<select id="F_tscode" name="F_tscode" class="QLock"><%#F_tscode%></SELECT>
	</td>
</TR>
<TR>
	<TD class=lightbluetable align=left colspan=6><strong>案性及費用：</strong></TD>
</TR>
<TR>
    <TD class=whitetablebg align=center colspan=6>
	    <TABLE border=0 class=bluetable cellspacing=1 cellpadding=2 >
		    <TR>
		        <TD class=lightbluetable align=right width="4%">案&nbsp;&nbsp;&nbsp;&nbsp;性：</TD>
		        <TD class=whitetablebg width=10%><select id=tfy_Arcase NAME=tfy_Arcase class="QLock"></SELECT></TD>
		        <TD class=lightbluetable align=right width=4%>服務費：</TD>
		        <TD class=whitetablebg  align="left">
                    <INPUT TYPE=text id=nfyi_Service name=nfyi_Service class="QLock" SIZE=8 maxlength=8 style="text-align:right;" >
                    <INPUT TYPE=hidden id=Service name=Service>
		        </TD>
		        <TD class=lightbluetable align=right width=4%>規費：</TD>
		        <TD class=whitetablebg align="left"><INPUT TYPE=text id=nfyi_Fees name=nfyi_Fees class="QLock" size=8 maxlength=8 style="text-align:right;" ><INPUT TYPE=hidden id=Fees name=Fees></TD>
		    </TR>
		    <tr id=ta_## style="display:none">
			    <td class=lightbluetable align=right width="4%">##.其他費用：</td>
			    <td class=whitetablebg align=left width="10%">
			    <select id="nfyi_item_Arcase_##" name="nfyi_item_Arcase_##" class="Lock"></select> x <input type=text id="nfyi_item_count_##" name="nfyi_item_count_##" size=2 maxlength=2 value="" class="QLock">項</td>
			    <td class=lightbluetable align=right width=4%>服務費：</td>
			    <td class=whitetablebg align=left width=5%>
			    <INPUT TYPE=text id=nfyi_Service_## name=nfyi_Service_## SIZE=8 maxlength=8 style="text-align:right;" class="QLock">
			    <input type=hidden id=nfzi_Service_## name=nfzi_Service_## SIZE=5>
			    </td>
			    <td class=lightbluetable align=right width=4%>規費：</td>
			    <td class=whitetablebg align=left width=5%>
			    <INPUT TYPE=text id=nfyi_fees_## name=nfyi_fees_## SIZE=8 maxlength=8 style="text-align:right;" class="QLock">
			    <input type=hidden id=nfzi_fees_## name=nfzi_fees_## SIZE=5>
			    </td>
		    </tr>
		    <TR>
			    <td class=lightbluetable align=right colspan=2>小計：</td>
			    <td class=lightbluetable align=right>服務費：</td>
			    <td class=whitetablebg align=left><INPUT TYPE=text id=nfy_service NAME=nfy_service SIZE=8 maxlength=8 style="text-align:right;" class="QLock"></td>
			    <td class=lightbluetable align=right>規費：</td>
			    <td class=whitetablebg align=left><INPUT TYPE=text id=nfy_fees NAME=nfy_fees SIZE=8 maxlength=8 style="text-align:right;" class="QLock"></td>
		    </TR>
		    <TR>
			    <TD class=lightbluetable align=right width="4%">轉帳費用：</TD>
			    <TD class=whitetablebg width="11%">
                    <select id=tfy_oth_arcase NAME=tfy_oth_arcase class="QLock"></SELECT>
			    </TD>
			    <TD class=lightbluetable align=right width=4%>轉帳金額：</TD>
			    <TD class=whitetablebg width=5%><input type="text" id="nfy_oth_money" name="nfy_oth_money" size="8" style="text-align:right;" class="QLock"></TD>
			    <TD class=lightbluetable align=right width=4%>轉帳單位：</TD>
			    <TD class=whitetablebg width=5%>
			    <select id=tfy_oth_code NAME=tfy_oth_code class="QLock"><%#tfy_oth_code%><option value="Z">Z_轉其他人</option></SELECT>
			    </TD>
		    </TR>
		    <TR>
			    <TD class=lightbluetable align=right colspan=2>合計：</TD>
			    <TD class=whitetablebg colspan=4>
                    <INPUT TYPE=text id=OthSum NAME=OthSum SIZE=7 class="QLock">
			    </TD>
		    </TR>
	    </TABLE>
    </TD>
</TR>
<TR>
	<TD class=lightbluetable align=right>請款註記：</TD>
	<TD class=whitetablebg>
        <Select id=tfy_Ar_mark name=tfy_Ar_mark class="QLock"><%#tfy_Ar_mark%></Select>
	</TD>
	<TD class=lightbluetable align=right>折扣率：</TD>
	<TD class="whitetablebg" colspan="3">
        <input TYPE="hidden" id="nfy_Discount" name="nfy_Discount">
        <input TYPE=text id="Discount" name="Discount" class="QLock">
	    <INPUT TYPE=checkbox id=tfy_discount_chk name=tfy_discount_chk value="Y" class="QLock" >折扣請核單
	</td>
</TR>		
<TR>
	<TD class=lightbluetable align=right>案源代碼：</TD>
	<TD class=whitetablebg>
        <Select id=tfy_source name=tfy_source class="QLock"><%#tfy_source%></Select>
	</TD>
	<TD class=lightbluetable align=right>契約號碼：</TD>
	<TD class=whitetablebg colspan="3">
        <input type="radio" id="Contract_no_Type_N" name="Contract_no_Type" value="N" class="QLock">
        <INPUT TYPE=text id=tfy_Contract_no name=tfy_Contract_no SIZE=10 MAXLENGTH=10  class="QLock">
		<input type="radio" id="Contract_no_Type_A" name="Contract_no_Type" value="A" class="QLock">後續案無契約書
	    <span style="display:none"><!--2015/12/29修改，併入C不顯示-->
		<input type="radio" id="Contract_no_Type_B" name="Contract_no_Type" value="B" class="QLock">特案簽報
	    </span>	
	    <input type="radio" id="Contract_no_Type_C" name="Contract_no_Type" value="C" class="QLock">其他契約書無編號/特案簽報
	    <input type="radio" id="Contract_no_Type_M" name="Contract_no_Type" value="M" class="QLock">總契約書
	    <span id="span_btn_contract" style="display:none">
		    <INPUT TYPE=text id=Mcontract_no name=Mcontract_no SIZE=10 MAXLENGTH=10 class="Lock">
		    <input type=button class="greenbutton QLock" name="btn_contract" value="查詢總契約書">
		    +客戶案件委辦書
	    </span>
	    <br>
	</TD>
</TR>
<TR>
	<TD class=lightbluetable align=right>法定期限：</TD>
	<TD class=whitetablebg align=left colspan=5>
        <INPUT type=text id=dfy_last_date name=dfy_last_date SIZE=10 class="dateField QLock">
	</TD>
</TR>
<TR>
	<TD class=lightbluetable align=right>發文方式：</TD>
	<TD class=whitetablebg><SELECT id="tfy_send_way" name="tfy_send_way" class="QLock"><%#tfy_send_way%></select>
	</TD>
	<TD class=lightbluetable align=right>官發收據種類：</TD>
	<TD class=whitetablebg>
		<select id="tfy_receipt_type" name="tfy_receipt_type" class="QLock">
			<option value='' style='color:blue'>請選擇</option>
			<option value="P">紙本收據</option>
			<option value="E">電子收據</option>
		</select>
	</TD>
	<TD class=lightbluetable align=right>收據抬頭：</TD>
	<TD class=whitetablebg>
		<select id="tfy_receipt_title" name="tfy_receipt_title" class="QLock"><%#tfy_receipt_title%></select>
		<input type="hidden" id="tfy_rectitle_name" name="tfy_rectitle_name">
	</TD>
</tr>
<TR>
	<TD class=lightbluetable align=right>其他接洽：<BR>事項記錄：</TD>
	<TD class=whitetablebg colspan=5><TEXTAREA id=tfy_Remark name=tfy_Remark ROWS=6 COLS=70 class="QLock"></TEXTAREA>
	</TD>
</TR>
</TABLE>
<input type=hidden id="TaCount" name="TaCount">
	
<script language="javascript" type="text/javascript">
    var case_form = {};
    case_form.init = function () {
        $("#tfy_Arcase").getOption({//案性
            dataList: br_opt.arcase,
            valueFormat: "{rs_code}",
            textFormat: "{rs_code}---{rs_detail}"
        });
        $("select[id='nfyi_item_Arcase_##']").getOption({//其他費用
            dataList: br_opt.arcase_item,
            valueFormat: "{rs_code}",
            textFormat: "{rs_code}---{rs_detail}"
        });
        $("#tfy_oth_arcase").getOption({//轉帳費用
            dataList: br_opt.arcase_other,
            valueFormat: "{rs_code}",
            textFormat: "{rs_code}---{rs_detail}"
        });

        //案性/案源
        var jCase = br_opt.opt[0];
        $("#F_tscode").val(jCase.in_scode);
        $("#tfy_Arcase").val(jCase.arcase);
        $("#tfy_oth_code").val(jCase.oth_code);
        $("#tfy_oth_arcase").val(jCase.oth_arcase);
        $("#tfy_Ar_mark").val(jCase.ar_mark);
        $("#tfy_discount_chk").prop("checked", jCase.discount_chk == "Y");
        $("#tfy_source").val(jCase.source);
        if (jCase.contract_type != "") {
            $("input[name='Contract_no_Type'][value='" + jCase.contract_type + "']").prop("checked", true);
            if (jCase.contract_type == "M") {
                $("#span_btn_contract").show();
                $("#Mcontract_no").val(jCase.contract_no);
            }
            if (jCase.contract_type == "N") {
                $("#tfy_Contract_no").val(jCase.contract_no);
            }
        }

        $("#dfy_last_date").val(dateReviver(jCase.last_date, "yyyy/M/d"));
        $("#tfy_Remark").val(jCase.remark);
        $("#nfy_service").val(jCase.service);
        $("#nfy_fees").val(jCase.fees);
        $("#nfy_oth_money").val(jCase.oth_money);
        $("#OthSum").val(jCase.othsum);
        $("#nfy_Discount").val(jCase.discount);
        $("#Discount").val(jCase.discount + "%");

        //產生其他費用tr
        for (z = 1; z <= jCase.tot_case; z++) {
            var copyStr = "<tr id='ta_" + z + "' style='display:none'>" + $("tr[id='ta_##']").html().replace(/##/g, z) + "</tr>";
            $(copyStr).insertBefore("tr[id='ta_##']");
        }

        //費用
        $.each(br_opt.casefee, function (i, item) {
            if (item.item_sql == "0") {
                $("#tfy_Arcase").val(item.item_arcase);
                $("#nfyi_Service").val(item.item_service);
                $("#nfyi_Fees").val(item.item_fees);
                $("#Service").val(item.service == "" ? "0" : item.service);
                $("#fees").val(item.fees == "" ? "0" : item.fees);
                $("#TaCount").val(item.item_sql);
            } else {
                $("#nfyi_item_Arcase_" + item.item_sql).val(item.item_arcase);
                $("#nfyi_item_count_" + item.item_sql).val(item.item_count);
                $("#nfyi_Service_" + item.item_sql).val(item.item_service);
                $("#nfzi_Service_" + item.item_sql).val(item.item_service);
                $("#nfyi_fees_" + item.item_sql).val(item.item_fees);
                $("#nfzi_fees_" + item.item_sql).val(item.item_fees);
                $("#nfzi_service_" + item.item_sql).val(item.service == "" ? "0" : item.service);
                $("#nfzi_fees_" + item.item_sql).val(item.fees == "" ? "0" : item.fees);
                $("#TaCount").val(item.item_sql);
                $("#ta_" + item.item_sql).show();
            }
        });

        //送件方式
        $("#tfy_send_way").val(jCase.send_way);
        $("#tfy_receipt_type").val(jCase.receipt_type);
        $("#tfy_receipt_title").val(jCase.receipt_title);
        $("#tfy_rectitle_name").val(jCase.rectitle_name);
    }
</script>
