<%@ Control Language="C#" ClassName="case_form" %>
<%@ Import Namespace = "System.Collections.Generic"%>

<script runat="server">
    //父控制項傳入的參數
    public Dictionary<string, string> Lock = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    public string formFunction = "";

    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = HttpContext.Current.Request["prgid"] ?? "";//程式代碼
    protected int HTProgRight = 0;
    protected string SQL = "";

    protected int MaxTaCount = 5;//附屬案性筆數上限
    protected string ar_form = "", code_type = "";

    protected string tfy_Arcase = "", nfyi_item_Arcase = "", tfy_oth_arcase="";
    protected string tfy_oth_code = "", F_tscode = "", tfy_Ar_mark = "", tfy_source = "";
    protected string tfy_send_way = "", tfy_receipt_title = "";

    private void Page_Load(System.Object sender, System.EventArgs e) {
        ar_form = Request["ar_form"] ?? "";
        code_type = Request["code_type"] ?? "";

        Token myToken = new Token(HTProgCode);
        HTProgRight = myToken.CheckMe();

        PageLayout();
        this.DataBind();
    }
    
    private void PageLayout() {
        if (prgid.ToLower() == "brt51") {//程序客收確認
            Lock["brt51"] = "Lock";
        } else {
            Lock["brt51"] = "";
        }
        
        using (DBHelper conn = new DBHelper(Conn.btbrt).Debug(false)) {
            //案性
            if (ar_form.Left(1) != "B") {
                SQL = "SELECT rs_code,prt_code,rs_detail,remark FROM  code_br WHERE rs_class like '" + ar_form + "%' And  cr= 'Y' and dept='T' And rs_type='" + code_type + "' AND no_code='N' ";
            } else {
                SQL = "SELECT rs_code,prt_code,rs_detail,remark FROM  code_br WHERE rs_class like '" + ar_form.Left(1) + "%' And  cr= 'Y' and dept='T' And rs_type='" + code_type + "' AND no_code='N' ";
            }
            SQL += "and getdate() >= beg_date ";
            if (prgid.ToLower() != "brt51") {
                SQL += "and (end_date is null or end_date = '' or end_date > getdate()) ";
            }
            SQL += " ORDER BY rs_code";
            tfy_Arcase = SHtml.Option(conn, SQL, "{rs_code}", "{rs_code}---{rs_detail}", "v1='{prt_code}' v2='{remark}'", true);

            //其他費用
            SQL = "SELECT  rs_code, rs_detail FROM  code_br WHERE rs_class = 'Z1' And  cr= 'Y' and dept='T' AND no_code='N' and getdate() >= beg_date ";
            SQL += " and mark is null ";
            if ((Request["add_arcase"] ?? "") != "") {
                SQL += " and substring(rs_code,1,3)='" + (Request["add_arcase"] ?? "").Left(3) + "' ";
            }
            if (prgid.ToLower() != "brt51") {
                SQL += "and (end_date is null or end_date = '' or end_date > getdate()) ";
            }
            SQL += "ORDER BY rs_code ";
            nfyi_item_Arcase = SHtml.Option(conn, SQL, "{rs_code}", "{rs_code}---{rs_detail}");
            
            //轉帳費用
            SQL = "SELECT  rs_code,prt_code,rs_detail FROM  code_br WHERE  cr= 'Y' and dept='T' And rs_type='" + code_type + "' AND no_code='N' and mark='M' ";
            SQL += "and getdate() >= beg_date and (end_date is null or end_date = '' or end_date > getdate()) ORDER BY rs_code";
            tfy_oth_arcase = SHtml.Option(conn, SQL, "{rs_code}", "{rs_code}---{rs_detail}");

            //轉帳單位
            tfy_oth_code = SHtml.Option(conn, "SELECT branch,branchname FROM sysctrl.dbo.branch_code WHERE class='branch'", "{branch}", "{branch}_{branchname}");
            
            //請款註記
            //tfy_Ar_mark = SHtml.Option(conn, "select cust_code,code_name from cust_code where code_type='ar_mark' and (mark1 like '%" + Session["SeBranch"] + Session["Dept"] + "%' or mark1 is null)", "{cust_code}", "{code_name}");
            tfy_Ar_mark = Funcs.getCustCode("ar_mark", "and (mark1 like '%" + Session["SeBranch"] + Session["Dept"] + "%' or mark1 is null)", "").Option("{cust_code}", "{code_name}");

            //案源代碼
            tfy_source = Funcs.getCustCode("Source", "AND cust_code<> '__' AND End_date is null", "cust_code").Option("{cust_code}", "({cust_code})---{code_name}");
            
            //發文方式
            tfy_send_way = Funcs.getCustCode("GSEND_WAY", "", "sortfld").Option("{cust_code}", "{code_name}");

            //收據抬頭
            tfy_receipt_title = Funcs.getCustCode("rec_titleT", "", "sortfld").Option("{cust_code}", "{code_name}");
        }
    }
</script>

<%=Sys.GetAscxPath(this)%>
<input type=hidden id="spe_ctrl3" name="spe_ctrl3"><!--判斷是否需管制法定期限-->
<TABLE border=0 class=bluetable cellspacing=1 cellpadding=2 width="100%">
<TR>
	<td class="lightbluetable" align=right>洽案營洽 :</td>
	<td class="whitetablebg" align="left" colspan=5 id="td_tscode">
	</td>
</TR>
<tr id="tr_grconf">
	<TD class=lightbluetable align=right>對應後續交辦作業序號：</TD>
	<TD class=whitetablebg colspan=5><input type=hidden name=hgrconf_sqlno id=hgrconf_sqlno><!--判斷有值表從後續查詢來-->
		<input type=text name=grconf_sqlno id=grconf_sqlno size=10 readonly><input type=button class="cbutton" value="查詢" onclick="get_attcase('Q')">
		<input type=button class="cbutton" value="詳細" onclick="get_attcase('S')">
	</td>
</tr>
<TR id="tr_fees">
	<TD class=lightbluetable align=left colspan=6><strong>案性及費用：</strong>
        <input type="button" class="cbutton <%=Lock["brt51"]%>" value="增加請款項目" onclick="case_form.ta_display('Add')">
        <input type="button" class="cbutton <%=Lock["brt51"]%>" value="減少請款項目" onclick="case_form.ta_display('Del')">
	</TD>
</TR>
<TR>
    <TD class=whitetablebg align=center colspan=6>
	    <TABLE border=0 class=bluetable cellspacing=1 cellpadding=2>
		    <TR>
		        <TD class=lightbluetable align=right width="4%">案&nbsp;&nbsp;&nbsp;&nbsp;性：</TD>
		        <TD class=whitetablebg width=10%><select id=tfy_Arcase NAME=tfy_Arcase class="<%=Lock["brt51"]%>" onchange="ToArcase('T',this.value ,'Z1')"><%#tfy_Arcase%></SELECT>
		        </TD>
		        <TD class=lightbluetable align=right width=3%>服務費：</TD>
		        <TD class=whitetablebg  align="left">
                    <INPUT TYPE=text id=nfyi_Service name=nfyi_Service value=0 SIZE=8 maxlength=8 style="text-align:right;" onblur="summary()">
                    <INPUT TYPE=hidden id=Service name=Service>
		        </TD>
		        <TD class=lightbluetable align=right width=3%>規費：</TD>
		        <TD class=whitetablebg align="left"><INPUT TYPE=text id=nfyi_Fees name=nfyi_Fees value=0 SIZE=8 maxlength=8 style="text-align:right;" onblur="summary()">
                    <INPUT TYPE=hidden id=Fees name=Fees></TD>
		    </TR>
		    <tr id="tr_ta" style="display:none"></tr><!--其他費用-->
		    <TR>
			    <td class=lightbluetable align=right colspan=2>小計：</td>
			    <td class=lightbluetable align=right>服務費：</td>
			    <td class=whitetablebg align=left><INPUT TYPE=text id=nfy_service NAME=nfy_service SIZE=8 maxlength=8 style="text-align:right;" readonly class="SEdit"></td>
			    <td class=lightbluetable align=right>規費：</td>
			    <td class=whitetablebg align=left><INPUT TYPE=text id=nfy_fees NAME=nfy_fees SIZE=8 maxlength=8 style="text-align:right;" readonly class="SEdit"></td>
		    </TR>
		    <TR>
			    <TD class=lightbluetable align=right width="4%">轉帳費用：</TD>
			    <TD class=whitetablebg width="11%">
                    <select id=tfy_oth_arcase NAME=tfy_oth_arcase onchange="ToFee('T',reg.tfy_oth_arcase.value ,reg.ar_form.value,'10')" class="<%=Lock["brt51"]%>"><%#tfy_oth_arcase%></SELECT>
			    </TD>
			    <TD class=lightbluetable align=right width=4%>轉帳金額：</TD>
			    <TD class=whitetablebg width=5%><input type="text" id="nfy_oth_money" name="nfy_oth_money" size="8" style="text-align:right;" onblur="summary()" class="<%=Lock["brt51"]%>"></TD>
			    <TD class=lightbluetable align=right width=4%>轉帳單位：</TD>
			    <TD class=whitetablebg width=5%>
			    <select id=tfy_oth_code NAME=tfy_oth_code class="<%=Lock["brt51"]%>">
                    <%#tfy_oth_code%><option value="Z">Z_轉其他人</option>
			    </SELECT>
			    </TD>
		    </TR>
		    <TR>
			    <TD class=lightbluetable align=right colspan=2>合計：</TD>
			    <TD class=whitetablebg colspan=4>
                    <INPUT TYPE=text id=OthSum NAME=OthSum SIZE=7 class="SEdit" readonly>
            	    <input type="hidden" id="tot_zservice" name="tot_zservice" value=0>
				    <input type="hidden" id="tot_yservice" name="tot_yservice" value=0>
				    <input type="hidden" id="oth_money" name="oth_money" value=0>
				    <input type=hidden id="tot_count" name="tot_count" value="">
			    </TD>
		    </TR>
		    <TR style="display:none">
		  	    <TD class=whitetablebg align=center colspan=6>
				    <TABLE border=0 class=bluetable cellspacing=1 cellpadding=2 width=100%>
					    <TR>
					      <td class=lightbluetable2 align=center width=16%>追加服務費</td>
					      <td class=lightbluetable2 align=center width=16%>追加規費</td>
					      <td class=lightbluetable2 align=center width=16%>已請款服務費</td>
					      <td class=lightbluetable2 align=center width=16%>已請款規費</td>
					      <td class=lightbluetable2 align=center width=16%>已請款次數</td>
					      <td class=lightbluetable2 align=center width=16%>已支出規費</td>
					    </TR>
					    <TR>
					      <td class=whitetablebg><INPUT TYPE=text id=xadd_service NAME=xadd_service SIZE=8 maxlength=8 style="text-align:right;" readonly class="SEdit"></td>
					      <td class=whitetablebg><INPUT TYPE=text id=xadd_fees NAME=xadd_fees SIZE=8 maxlength=8 style="text-align:right;" readonly class="SEdit"></td>
					      <td class=whitetablebg><INPUT TYPE=text id=xar_service NAME=xar_service SIZE=8 maxlength=8 style="text-align:right;" readonly class="SEdit"></td>
					      <td class=whitetablebg><INPUT TYPE=text id=xar_fees NAME=xar_fees SIZE=8 maxlength=8 style="text-align:right;" readonly class="SEdit"></td>
					      <td class=whitetablebg><INPUT TYPE=text id=xar_curr NAME=xar_curr SIZE=8 maxlength=8 style="text-align:right;" readonly class="SEdit"></td>
					      <TD class=whitetablebg><INPUT TYPE=text id=xgs_fees NAME=xgs_fees SIZE=8 style="text-align:right;" readonly class="SEdit"></TD>
					    </TR>
				    </TABLE>		  
			    </TD>
		    </TR>  
	    </TABLE>
    </TD>
</TR>
<TR>
	<TD class=lightbluetable align=right>請款註記：</TD>
	<TD class=whitetablebg>
        <Select id=tfy_Ar_mark name=tfy_Ar_mark onchange="special()" class="<%=Lock["brt51"]%>"><%#tfy_Ar_mark%></Select>
	</TD>
	<TD class=lightbluetable align=right>折扣率：</TD>
	<TD class="whitetablebg" colspan="3">
        <input TYPE="hidden" id="nfy_Discount" name="nfy_Discount">
        <input TYPE=text id="Discount" name="Discount" class="SEdit" readonly>
        <span style="display:none">
	        <INPUT TYPE=checkbox id=tfy_discount_chk name=tfy_discount_chk value="Y" class="<%=Lock["brt51"]%>">折扣請核單
        </span>
		<span id="span_discount_remark" style="display:none">
			折扣理由：<INPUT TYPE=text NAME="tfy_discount_remark" id="tfy_dicount_remark" SIZE=100 MAXLENGTH=200 alt="『折扣理由』" onblur="fDataLen(this.value,me.MAXLENGTH,this.alt)">
		</span>
	</td>
</TR>
<TR>
	<TD class=lightbluetable align=right>案源代碼：</TD>
	<TD class=whitetablebg>
        <Select id=tfy_source name=tfy_source><%#tfy_source%></Select>
	</TD>
	<TD class=lightbluetable align=right>契約號碼：</TD>
	<TD class=whitetablebg colspan="3">
		<input type="hidden" id="tfy_contract_type" name="tfy_contract_type">
        <input type="radio" id="Contract_no_Type_N" name="Contract_no_Type" value="N" onclick="contract_type_ctrl()">
        <INPUT TYPE=text id=tfy_Contract_no name=tfy_Contract_no SIZE=10 MAXLENGTH=10 onchange="reg.Contract_no_Type(0).checked=true">
        <span id="contract_type">
		    <input type="radio" id="Contract_no_Type_A" name="Contract_no_Type" value="A" onclick="contract_type_ctrl()">後續案無契約書
		</span>
		<input type="radio" id="Contract_no_Type_S" name="Contract_no_Type" style="display:none">特案簽報<!--2015/12/29修改，併入C不顯示-->
	    <input type="radio" id="Contract_no_Type_C" name="Contract_no_Type" value="C" onclick="contract_type_ctrl()">其他契約書無編號/特案簽報
	    <input type="radio" id="Contract_no_Type_M" name="Contract_no_Type" value="M" onclick="contract_type_ctrl()">總契約書
	    <span id="span_btn_contract" style="display:none">
		    <INPUT TYPE=text id=Mcontract_no name=Mcontract_no SIZE=10 MAXLENGTH=10 readonly class="gSEdit">
		    <input type=button class="greenbutton" id="btn_contract" name="btn_contract" value="查詢總契約書">
		    +客戶案件委辦書
	    </span>
	    <br>
		<INPUT TYPE=checkbox id=tfy_contract_flag NAME=tfy_contract_flag value="Y" class="<%=Lock["brt51"]%>">契約書相關文件後補，尚缺文件說明：
        <input type="text" id="tfy_contract_remark" name="tfy_contract_remark" size=50 maxlength=100 readonly class="gSEdit">    
		<span id="ar_chk" style="display:none">
            <INPUT TYPE=checkbox id=tfy_ar_chk NAME=tfy_ar_chk  value="Y">請款單／收據與附本寄發
		    <INPUT TYPE=checkbox id=tfy_ar_chk1 NAME=tfy_ar_chk1 value="Y">即發請款單／收據
        </span>
	</TD>
</TR>
<TR>
    <TD class=lightbluetable align=right>客戶期限：</TD>
    <TD class=whitetablebg align=left><INPUT type=text id=dfy_cust_date NAME=dfy_cust_date SIZE=10 class="dateField"></TD>
    <TD class=lightbluetable align=right>承辦期限：</TD>
    <TD class=whitetablebg align=left><INPUT type=text id=dfy_pr_date NAME=dfy_pr_date SIZE=10 class="dateField"></TD>
    <TD class=lightbluetable align=right>法定期限：</TD>
    <TD class=whitetablebg align=left><INPUT type=text id=dfy_last_date NAME=dfy_last_date SIZE=10 class="dateField"></TD>

</TR>
<TR id=tr_send_way>
	<TD class=lightbluetable align=right>發文方式：</TD>
	<TD class=whitetablebg>
        <SELECT id="tfy_send_way" name="tfy_send_way" onchange="setReceiptType()"><%#tfy_send_way%></select>
        <input type="hidden" id="spe_ctrl" name="spe_ctrl">
	</TD>
	<TD class=lightbluetable align=right>官發收據種類：</TD>
	<TD class=whitetablebg>
		<select id="tfy_receipt_type" name="tfy_receipt_type" onchange="setReceiptTitle()">
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
	<TD class=whitetablebg colspan=5><TEXTAREA id=tfy_Remark name=tfy_Remark ROWS=6 COLS=70></TEXTAREA>
	</TD>
</TR>
</TABLE>
<input type=hidden id="anfees" name="anfees" value="">	
<input type=hidden id="code_type" name="code_type" value="<%#code_type%>">	
<input type=hidden id="TaMax" name="TaMax" value="<%=MaxTaCount%>"><!--最他費用最多可5筆-->
<input type=hidden id="TaCount" name="TaCount" value="0">
<input type=hidden id="nfy_tot_case" name="nfy_tot_case" value="">
<input type=hidden id="tfy_ar_code" name="tfy_ar_code" value="N">	

<!--其他費用樣板-->
<script type="text/html" id="ta_template">
	<tr id=tr_ta_##>
		<td class=lightbluetable align=right width="4%">##.其他費用：</td>
		<td class=whitetablebg align=left width="10%">
		    <select id="nfyi_item_Arcase_##" name="nfyi_item_Arcase_##" onchange="ToFee('T',me.value ,reg.Ar_Form.value,'##')" class="<%=Lock["brt51"]%>">
            <%#nfyi_item_Arcase%>
		    </select> x <input type=text id="nfyi_item_count_##" name="nfyi_item_count_##" size=3 maxlength=3 value="1" onblur="item_count('##')" class="<%=Lock["brt51"]%>">項
		</td>
		<td class=lightbluetable align=right width=4%>服務費：</td>
		<td class=whitetablebg align=left width=5%>
		    <INPUT TYPE=text id=nfyi_Service_## name=nfyi_Service_## SIZE=8 maxlength=8 style="text-align:right;" value="0" onblur="summary()" class="<%=Lock["brt51"]%>">
		    <input type=hidden id=nfzi_Service_## name=nfzi_Service_##>
		</td>
		<td class=lightbluetable align=right width=4%>規費：</td>
		<td class=whitetablebg align=left width=5%>
		    <INPUT TYPE=text id=nfyi_fees_## name=nfyi_fees_## SIZE=8 maxlength=8 style="text-align:right;" value="0" onblur="item_nfyi_fees('##')" class="<%=Lock["brt51"]%>">
		    <input type=hidden id=nfzi_fees_## name=nfzi_fees_##>
		</td>
	</tr>
</script>


<script language="javascript" type="text/javascript">
    var case_form = {};
    case_form.init = function () {
        //晝面準備==============================
        //洽案營洽
        $("#td_tscode").empty();
        if (jMain.salesList[0].input_type == "text") {
            $('#td_tscode').append('<input type="text" id="F_tscode" name="F_tscode" readonly class="SEdit" size=5 value="' + jMain.salesList[0].scode + '">' + jMain.salesList[0].sc_name);
        } else {
            $('#td_tscode').append("<select id='F_tscode' name='F_tscode' class='<%=Lock["brt51"]%>'></select>");
            $("#F_tscode").getOption({
                dataList: jMain.salesList,
                valueFormat: "{scode}",
                textFormat: "{sc_name}",
                showEmpty:false
            });
        }

        //晝面控制==============================
        //if (main.prgid == "brt51") {//客收確認
        //    $("#F_tscode").lock();//洽案營洽
        //    $("#tr_fees").lock();//案性及費用
        //    $("#tfy_Arcase").lock();//案性
        //    $("#nfyi_Service").lock();//服務費
        //    $("#nfyi_Fees").lock();//規費
        //}
        
        if (main.ar_form == "A0" || main.ar_form == "A1") {
            //對應後續交辦作業序號(新申請案不用顯示)
            $("#tr_grconf").hide();
        }

        /*
        $("#tfy_Arcase").getOption({//案性
            dataList: jMain.arcase,
            valueFormat: "{rs_code}",
            textFormat: "{rs_code}---{rs_detail}"
        });
        $("select[id='nfyi_item_Arcase_##']").getOption({//其他費用
            dataList: jMain.arcase_item,
            valueFormat: "{rs_code}",
            textFormat: "{rs_code}---{rs_detail}"
        });
        $("#tfy_oth_arcase").getOption({//轉帳費用
            dataList: jMain.arcase_other,
            valueFormat: "{rs_code}",
            textFormat: "{rs_code}---{rs_detail}"
        });

        //案性/案源
        var jCase = jMain.opt[0];
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
        $.each(jMain.casefee, function (i, item) {
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
        */
    }

    //增加/減少其他費用
    case_form.ta_display = function (act) {
        if ($("#tfy_Arcase").val() == "") {
            alert("請選擇案性!!");
            $("#tfy_Arcase").focus();
            return false;
        }

        if (act == "Add") {
            var nRow = parseInt($("#TaCount").val(), 10) + 1;
            var nMax = parseInt($("#TaMax").val(), 10);
            if (nRow > nMax) {
                alert("附屬案性超過" + nMax + "筆!");
                return false;
            }

            //複製樣板
            var copyStr = $("#ta_template").text() || "";
            copyStr = copyStr.replace(/##/g, nRow);
            $(copyStr).insertBefore("#tr_ta");
            $("#TaCount").val(nRow);
        } else {
            var nRow = parseInt($("#TaCount").val(), 10);
            $('#tr_ta_' + nRow).remove();
            $("#TaCount").val(Math.max(0, nRow - 1));

            if ((nRow - 1) < 0) {
                alert("已沒有任何附屬案性!");
            }
            Summary();
        }
    }

    //小計服務費及規費
    case_form.summary = function () {
        var nfy_service=0;
        var nfy_fees=0;
        nfy_service+=parseInt($("#nfyi_Service").val(), 10);
        nfy_fees+=parseInt($("#nfyi_Fees").val(), 10);

        for(var i=1;i<=parseInt($("#TaCount").val(), 10);i++){
            nfy_service+=parseInt($("#nfyi_Service_"+i).val(), 10);
            nfy_fees+=parseInt($("#nfyi_fees_"+i).val(), 10);
        }

        if trim(reg.nfy_oth_money.value)<>empty or reg.nfy_oth_money.value<>0 then
            reg.OthSum.value =clng(reg.nfy_service.value)+clng(reg.nfy_fees.value)+clng(reg.nfy_oth_money.value)
        else
		    reg.OthSum.value =clng(reg.nfy_service.value)+clng(reg.nfy_fees.value)
        end if
	    call special

        $("#fr_fees").val(nfy_fees);//註冊費繳費金額=規費

        $("#nfy_service").val(nfy_service);
        $("#nfy_fees").val(nfy_fees);
    }
</script>
