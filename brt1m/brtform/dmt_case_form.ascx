<%@ Control Language="C#" ClassName="dmt_case_form" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Data" %>

<script runat="server">
    //父控制項傳入的參數
    public Dictionary<string, string> Lock = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    public Dictionary<string, string> Hide = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    public int HTProgRight = 0;
    public string formFunction = "";

    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected string SQL = "";

    protected string submitTask = "";
    protected int MaxTaCount = 5;//附屬案性筆數上限
    protected string recTitle = Sys.getDefaultTitle();//收據種類預設抬頭
    protected string ar_form = "", code_type = "";

    protected string td_tscode = "";
    protected string tfy_Arcase = "", nfyi_item_Arcase = "", tfy_oth_arcase="";
    protected string tfy_oth_code = "", F_tscode = "", tfy_Ar_mark = "", tfy_source = "";
    protected string tfy_send_way = "", tfy_receipt_title = "";

    private void Page_Load(System.Object sender, System.EventArgs e) {
        ar_form = Request["ar_form"] ?? "";
        code_type = Request["code_type"] ?? "";
        submitTask = (Request["submitTask"] ?? "").Trim();
        
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
            //洽案營洽清單
            using (DBHelper cnn = new DBHelper(Conn.Sysctrl).Debug(false)) {
                DataTable dt = new DataTable();
                if ((HTProgRight & 64) != 0) {
                    SQL = "select distinct 'select'input_type,scode,sc_name,scode1  ";
                    SQL += "from vscode_roles ";
                    SQL += "where branch='" + Session["SeBranch"] + "' ";
                    SQL += "and dept='" + Session["Dept"] + "' ";
                    SQL += "and syscode='" + Session["Syscode"] + "' ";
                    SQL += "and roles='sales' ";
                    if (formFunction != "Edit") {
                        SQL += "and (end_date is null or end_date>'"+DateTime.Today.ToShortDateString()+"') ";
                    }
                    SQL += "order by scode1 ";
                    cnn.DataTable(SQL, dt);
                    td_tscode = "<select id='F_tscode' name='F_tscode' class='" + Lock.TryGet("brt51")+"'>" + dt.Option("{scode}", "{sc_name}") + "</select>";
                } else {
                    td_tscode = "<input type='text' id='F_tscode' name='F_tscode' readonly class='SEdit' size=5 value='" + Session["se_scode"] + "'>";
                    td_tscode += "<span id='span_tscode'>" + Session["sc_name"] + "</span>";
                }
            }
            
            //案性
            SQL = "SELECT rs_code,prt_code,rs_detail,remark FROM  code_br WHERE cr= 'Y' and dept='T' And rs_type='" + code_type + "' AND no_code='N' ";
            if (ar_form.Left(1) != "B") {
                SQL += "and rs_class like '" + ar_form + "%' ";
            } else {
                SQL += "and rs_class like '" + ar_form.Left(1) + "%' ";
            }
            SQL += "and getdate() >= beg_date ";
            if (prgid.ToLower() != "brt51") {
                SQL += "and (end_date is null or end_date = '' or end_date > getdate()) ";
            }
            SQL += " ORDER BY rs_code";
            tfy_Arcase = Util.Option(conn, SQL, "{rs_code}", "{rs_code}---{rs_detail}", "v1='{prt_code}' v2='{remark}'", true);

            //其他費用
            //SQL = "SELECT  rs_code, rs_detail FROM  code_br WHERE rs_class = 'Z1' And  cr= 'Y' and dept='T' AND no_code='N' and getdate() >= beg_date ";
            //SQL += " and mark is null ";
            //if ((Request["add_arcase"] ?? "") != "") {
            //    SQL += " and substring(rs_code,1,3)='" + (Request["add_arcase"] ?? "").Left(3) + "' ";
            //}
            //if (prgid.ToLower() != "brt51") {
            //    SQL += "and (end_date is null or end_date = '' or end_date > getdate()) ";
            //}
            //SQL += "ORDER BY rs_code ";
            //nfyi_item_Arcase = Util.Option(conn, SQL, "{rs_code}", "{rs_code}---{rs_detail}");
            
            //轉帳費用
            SQL = "SELECT  rs_code,prt_code,rs_detail FROM  code_br WHERE  cr= 'Y' and dept='T' And rs_type='" + code_type + "' AND no_code='N' and mark='M' ";
            SQL += "and getdate() >= beg_date and (end_date is null or end_date = '' or end_date > getdate()) ORDER BY rs_code";
            tfy_oth_arcase = Util.Option(conn, SQL, "{rs_code}", "{rs_code}---{rs_detail}");

            //轉帳單位
            tfy_oth_code = Util.Option(conn, "SELECT branch,branchname FROM sysctrl.dbo.branch_code WHERE class='branch'", "{branch}", "{branch}_{branchname}");
            
            //請款註記
            tfy_Ar_mark = Sys.getCustCode("ar_mark", "and (mark1 like '%" + Session["SeBranch"] + Session["Dept"] + "%' or mark1 is null)", "").Option("{cust_code}", "{code_name}", false);

            //案源代碼
            tfy_source = Sys.getCustCode("Source", "AND cust_code<> '__' AND End_date is null", "cust_code").Option("{cust_code}", "({cust_code})---{code_name}");
            
            //發文方式
            tfy_send_way = Sys.getCustCode("GSEND_WAY", "", "sortfld").Option("{cust_code}", "{code_name}");

            //收據抬頭
            tfy_receipt_title = Sys.getCustCode("rec_titleT", "", "sortfld").Option("{cust_code}", "{code_name}");
        }
    }
</script>

<%=Sys.GetAscxPath(this.AppRelativeVirtualPath)%>
<input type=hidden id="spe_ctrl3" name="spe_ctrl3"><!--判斷是否需管制法定期限-->
<TABLE border=0 class=bluetable cellspacing=1 cellpadding=2 width="100%">
<TR>
	<td class="lightbluetable" align=right>洽案營洽 :</td>
	<td class="whitetablebg" align="left" colspan=5 id="td_tscode"><%=td_tscode%>
	</td>
</TR>
<tr id="tr_grconf">
	<TD class=lightbluetable align=right>對應後續交辦作業序號：</TD>
	<TD class=whitetablebg colspan=5><input type=hidden name=hgrconf_sqlno id=hgrconf_sqlno><!--判斷有值表從後續查詢來-->
		<input type=text name=grconf_sqlno id=grconf_sqlno size=10 readonly><input type=button class="cbutton" value="查詢" onclick="case_form.get_attcase('Q')">
		<input type=button class="cbutton" value="詳細" id=grconf_dtl onclick="case_form.get_attcase('S')">
	</td>
</tr>
<TR id="tr_fees">
	<TD class=lightbluetable align=left colspan=6><strong>案性及費用：</strong>
        <input type="button" class="cbutton <%=Lock.TryGet("brt51")%>" value="增加請款項目" onclick="case_form.ta_display('Add')">
        <input type="button" class="cbutton <%=Lock.TryGet("brt51")%>" value="減少請款項目" onclick="case_form.ta_display('Del')">
	</TD>
</TR>
<TR>
    <TD class=whitetablebg align=center colspan=6>
	    <TABLE border=0 class=bluetable cellspacing=1 cellpadding=2 width="100%">
		    <TR>
		        <TD class=lightbluetable align=right width="4%">案&nbsp;&nbsp;&nbsp;&nbsp;性：</TD>
		        <TD class=whitetablebg width=10%>
                    <select id=tfy_Arcase NAME=tfy_Arcase class="<%=Lock.TryGet("brt51")%> <%=Lock.TryGet("ar_curr")%>" onchange="case_form.toArcase('T',this.value ,'Z1')"><%#tfy_Arcase%></SELECT>
		        </TD>
		        <TD class=lightbluetable align=right width=3%>服務費：</TD>
		        <TD class=whitetablebg  align="left">
                    <INPUT TYPE=text id=nfyi_Service name=nfyi_Service value=0 SIZE=8 maxlength=8 style="text-align:right;">
                    <INPUT TYPE=hidden id=Service name=Service>
		        </TD>
		        <TD class=lightbluetable align=right width=3%>規費：</TD>
		        <TD class=whitetablebg align="left">
                    <INPUT TYPE=text id=nfyi_Fees name=nfyi_Fees value=0 SIZE=8 maxlength=8 style="text-align:right;" onblur="case_form.summary()">
                    <INPUT TYPE=hidden id=Fees name=Fees>
		        </TD>
		    </TR>
            <script type="text/html" id="ta_template"><!--其他費用樣板-->
	            <tr id=tr_ta_##>
		            <td class=lightbluetable align=right width="4%">##.其他費用：</td>
		            <td class=whitetablebg align=left width="10%">
		                <select id="nfyi_item_Arcase_##" name="nfyi_item_Arcase_##" onchange="case_form.ToFee('T',this.value ,reg.ar_form.value,'##')" class="<%=Lock.TryGet("brt51")%>">
                        <%#nfyi_item_Arcase%>
		                </select> x <input type=text id="nfyi_item_count_##" name="nfyi_item_count_##" size=3 maxlength=3 value="1" onblur="case_form.item_count('##')" class="<%=Lock.TryGet("brt51")%>">項
		            </td>
		            <td class=lightbluetable align=right width=4%>服務費：</td>
		            <td class=whitetablebg align=left width=5%>
		                <INPUT TYPE=text id=nfyi_Service_## name=nfyi_Service_## SIZE=8 maxlength=8 style="text-align:right;" value="0" onblur="case_form.summary()" class="<%=Lock.TryGet("brt51")%>">
		                <input type=text id=nfzi_Service_## name=nfzi_Service_##>
		            </td>
		            <td class=lightbluetable align=right width=4%>規費：</td>
		            <td class=whitetablebg align=left width=5%>
		                <INPUT TYPE=text id=nfyi_fees_## name=nfyi_fees_## SIZE=8 maxlength=8 style="text-align:right;" value="0" onblur="case_form.item_nfyi_fees('##')" class="<%=Lock.TryGet("brt51")%>">
		                <input type=text id=nfzi_fees_## name=nfzi_fees_##>
		            </td>
	            </tr>
            </script>
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
                    <select id=tfy_oth_arcase NAME=tfy_oth_arcase onchange="case_form.ToFee('T',this.value ,reg.ar_form.value,'10')" class="<%=Lock.TryGet("brt51")%>"><%#tfy_oth_arcase%></SELECT>
			    </TD>
			    <TD class=lightbluetable align=right width=4%>轉帳金額：</TD>
			    <TD class=whitetablebg width=5%><input type="text" id="nfy_oth_money" name="nfy_oth_money" size="8" style="text-align:right;" onblur="case_form.summary()" class="<%=Lock.TryGet("brt51")%>"></TD>
			    <TD class=lightbluetable align=right width=4%>轉帳單位：</TD>
			    <TD class=whitetablebg width=5%>
			        <select id=tfy_oth_code NAME=tfy_oth_code class="<%=Lock.TryGet("brt51")%>">
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
				    <input type="hidden" id="tot_count" name="tot_count" value="">
			    </TD>
		    </TR>
		    <TR>
			    <TD class=lightbluetable align=right width="4%">注意事項：</TD>
			    <TD class=whitetablebg colspan="5">
                    <TEXTAREA id=fee_remark name=fee_remark ROWS=6 COLS=70 class="SEdit" readonly></TEXTAREA>
			    </TD>
		    </TR>
		    <TR style="display:none">
		  	    <TD class=whitetablebg align=center colspan=6>
				    <TABLE border=0 class=bluetable cellspacing=1 cellpadding=2 width=100%>
					    <TR>
					      <td class=lightbluetable2 align=center>追加服務費</td>
					      <td class=lightbluetable2 align=center>追加規費</td>
					      <td class=lightbluetable2 align=center>已請款服務費</td>
					      <td class=lightbluetable2 align=center>已請款規費</td>
					      <td class=lightbluetable2 align=center>已請款次數</td>
					      <td class=lightbluetable2 align=center>已支出規費</td>
					      <td class="lightbluetable2 td_chkar_code" align=center style="display:none">
                              是否請款完畢
					      </td>
					    </TR>
					    <TR>
					      <td class=whitetablebg><INPUT TYPE=text id=xadd_service NAME=xadd_service SIZE=8 maxlength=8 style="text-align:right;" readonly class="SEdit"></td>
					      <td class=whitetablebg><INPUT TYPE=text id=xadd_fees NAME=xadd_fees SIZE=8 maxlength=8 style="text-align:right;" readonly class="SEdit"></td>
					      <td class=whitetablebg><INPUT TYPE=text id=xar_service NAME=xar_service SIZE=8 maxlength=8 style="text-align:right;" readonly class="SEdit"></td>
					      <td class=whitetablebg><INPUT TYPE=text id=xar_fees NAME=xar_fees SIZE=8 maxlength=8 style="text-align:right;" readonly class="SEdit"></td>
					      <td class=whitetablebg><INPUT TYPE=text id=xar_curr NAME=xar_curr SIZE=8 maxlength=8 style="text-align:right;" readonly class="SEdit"></td>
					      <TD class=whitetablebg><INPUT TYPE=text id=xgs_fees NAME=xgs_fees SIZE=8 style="text-align:right;" readonly class="SEdit"></TD>
					      <TD class="whitetablebg td_chkar_code" style="display:none">
                              <span id="span_ar_code_O" style="display:none">舊款</span>
                              <span id="span_ar_code_X" style="display:none">
                                    <input type=checkbox id=chkar_code name=chkar_code value="X">不需請款
								    <input type="hidden" id="ochkar_code" name="ochkar_code">
                              </span>
					      </TD>
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
        <Select id=tfy_Ar_mark name=tfy_Ar_mark onchange="case_form.special()" class="<%=Lock.TryGet("brt51")%>"><%#tfy_Ar_mark%></Select>
	</TD>
	<TD class=lightbluetable align=right>折扣率：</TD>
	<TD class="whitetablebg" colspan="3">
        <input TYPE="hidden" id="nfy_Discount" name="nfy_Discount">
        <input TYPE=text id="Discount" name="Discount" class="SEdit" readonly>
        <span style="display:none">
	        <INPUT TYPE=checkbox id=tfy_discount_chk name=tfy_discount_chk value="Y" class="<%=Lock.TryGet("brt51")%>">折扣請核單
        </span>
		<span id="span_discount_remark" style="display:none">
			折扣理由：<INPUT TYPE=text NAME="tfy_discount_remark" id="tfy_dicount_remark" SIZE=100 MAXLENGTH=200 alt="『折扣理由』" onblur="fDataLen(this)">
		</span>
	</td>
</TR>
<TR>
	<TD class=lightbluetable align=right>案源代碼：</TD>
	<TD class=whitetablebg>
        <input type="hidden" id="osource" name="osource">
        <Select id=tfy_source name=tfy_source><%#tfy_source%></Select>
	</TD>
	<TD class=lightbluetable align=right>契約號碼：</TD>
	<TD class=whitetablebg colspan="3">
        <input type="hidden" id="ocontract_no" name="ocontract_no">
		<input type="hidden" id="tfy_contract_type" name="tfy_contract_type">
        <input type="radio" id="Contract_no_Type_N" name="Contract_no_Type" value="N">
        <INPUT TYPE=text id=tfy_Contract_no name=tfy_Contract_no SIZE=10 MAXLENGTH=10 onchange="$('#Contract_no_Type_N').prop('checked',true).trigger('click');">
        <span id="contract_type">
		    <input type="radio" id="Contract_no_Type_A" name="Contract_no_Type" value="A">後續案無契約書
		</span>
		<span style="display:none"><!--2015/12/29修改，併入C不顯示-->
		    <input type="radio" id="Contract_no_Type_S" name="Contract_no_Type" value="B">特案簽報
		</span>
	    <input type="radio" id="Contract_no_Type_C" name="Contract_no_Type" value="C">其他契約書無編號/特案簽報
	    <input type="radio" id="Contract_no_Type_M" name="Contract_no_Type" value="M">總契約書
	    <span id="span_btn_contract" style="display:none">
		    <INPUT TYPE=text id=Mcontract_no name=Mcontract_no SIZE=10 MAXLENGTH=10 readonly class="SEdit">
		    <input type=button class="greenbutton" id="btn_contract" name="btn_contract" value="查詢總契約書">
		    +客戶案件委辦書
	    </span>
	    <br>
		<INPUT TYPE=checkbox id=tfy_contract_flag NAME=tfy_contract_flag value="Y" class="<%=Lock.TryGet("brt51")%>">契約書相關文件後補，尚缺文件說明：
        <input type="text" id="tfy_contract_remark" name="tfy_contract_remark" size=50 maxlength=100 readonly class="SEdit">
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
        <SELECT id="tfy_send_way" name="tfy_send_way" onchange="case_form.setReceiptType()"><%#tfy_send_way%></select>
        <input type="hidden" id="spe_ctrl" name="spe_ctrl">
	</TD>
	<TD class=lightbluetable align=right>官發收據種類：</TD>
	<TD class=whitetablebg>
		<select id="tfy_receipt_type" name="tfy_receipt_type" onchange="case_form.setReceiptTitle()">
			<option value='' style='color:blue'>請選擇</option>
			<option value="P">紙本收據</option>
			<option value="E">電子收據</option>
		</select>
	</TD>
	<TD class=lightbluetable align=right>收據抬頭：</TD>
	<TD class=whitetablebg>
		<select id="tfy_receipt_title" name="tfy_receipt_title"><%#tfy_receipt_title%></select>
		<input type="hidden" id="tfy_rectitle_name" name="tfy_rectitle_name">
	</TD>
</tr>
<TR>
	<TD class=lightbluetable align=right>其他接洽：<BR>事項記錄：</TD>
	<TD class=whitetablebg colspan=5><TEXTAREA id=tfy_Remark name=tfy_Remark ROWS=6 COLS=70></TEXTAREA>
	</TD>
</TR>
</TABLE>
<input type=hidden id="anfees" name="anfees" value=""><!--有無收費標準-->
<input type=hidden id="code_type" name="code_type" value="<%#code_type%>">	
<input type=hidden id="TaMax" name="TaMax" value="<%=MaxTaCount%>"><!--最他費用最多可用筆數-->
<input type=hidden id="TaCount" name="TaCount" value="0">
<input type=hidden id="nfy_tot_case" name="nfy_tot_case" value="0"><!--案性數=主案性+請款案性數-->
<input type=hidden id="tfy_ar_code" name="tfy_ar_code" value="N">	<!--請款是否開立完畢-->


<script language="javascript" type="text/javascript">
    var case_form = {};
    //晝面準備
    case_form.init = function () {
        if ($("#ar_form").val() == "A0" || $("#ar_form").val() == "A1") {
            //對應後續交辦作業序號(新申請案不用顯示)
            $("#tr_grconf").hide();
            //後續案無契約書(新申請案不用顯示)
            $("#contract_type").hide();
        }
        if (main.formFunction != "Edit") {
            //不是編輯模式隱藏對應後續交辦作業序號[詳細]
            $("#grconf_dtl").hide();
        }
        if (main.formFunction == "Edit") {
            //是編輯模式顯示原始交辦營洽
            $("#F_tscode").val(main.br_in_scode);
            $("#span_tscode").html(main.br_in_scname);
        }
    }

    //增加/減少其他費用(附屬案性)
    case_form.ta_display = function (act) {
        if ($("#tfy_Arcase").val() == "") {
            alert("請選擇案性!!");
            $("#tfy_Arcase").focus();
            return false;
        }

        if (act == "Add") {
            var nRow = CInt($("#TaCount").val()) + 1;
            var nMax = CInt($("#TaMax").val());
            if (nRow > nMax) {
                alert("附屬案性超過" + nMax + "筆!");
                return false;
            }

            //複製樣板
            var copyStr = $("#ta_template").text() || "";
            copyStr = copyStr.replace(/##/g, nRow);
            $(copyStr).insertBefore("#ta_template");
            $("#nfyi_item_Arcase_" + nRow).getOption({
                url: getRootPath() + "/ajax/json_Fee.aspx",
                data: { type: "Arcase", country: "T", arcase: $("#tfy_Arcase").val(), ar_form: "Z1", prgid: "<%#prgid%>" },
                valueFormat: "{rs_code}",
                textFormat: "{rs_code}---{rs_detail}"
            });
            $("#TaCount").val(nRow);
        } else {
            var nRow = CInt($("#TaCount").val());
            $('#tr_ta_' + nRow).remove();
            $("#TaCount").val(Math.max(0, nRow - 1));

            if ((nRow - 1) < 0) {
                alert("已沒有任何附屬案性!");
            }
            case_form.summary();
        }
    }

    //承辦期限控制
    case_form.pr_date_control = function (T1) {
        /*
        $.ajax({
            url: getRootPath() + "/brt1m/pr_date.aspx?Arcase=" + T1,
            type: 'GET',
            dataType: "script",
            async: false,
            cache: false,
            error: function (xhr) { 
                $("#dialog").html("<a href='" + this.url + "' target='_new'>取得承辦期限控制失敗！<u>(點此顯示詳細訊息)</u></a><hr>"+xhr.responseText);
                $("#dialog").dialog({ title: '取得承辦期限控制失敗！', modal: true, maxHeight: 500,width: "90%" });
            }
        });
        */
        ajaxScriptByGet("取得承辦期限控制", getRootPath() + "/brt1m/pr_date.aspx?Arcase=" + T1);
    }

    //顯示附屬案性(x1:國別:T為國內案,x2:案性代碼,x3:Z1=>附屬案性)
    case_form.toArcase = function (x1, x2, x3) {
        if (x2 == "") {
            reg.nfyi_Service.value = 0;//服務費
            reg.nfyi_Fees.value = 0;//規費
            reg.nfy_service.value = 0;//小計服務費
            reg.nfy_fees.value = 0;//小計規費
            case_form.summary();//計算合計
            case_form.setSendWay(x2);//20160909 增加發文方式
            return false;
        }
        var Arcase = x2;
        var prt_code = $("#tfy_Arcase option:selected").attr("v1");
        main.changeTag(x2);//轉換要SHOW的交辦書面
        reg.tfy_Arcase.value = x2;
        //2011/9/26抓取案性特殊控制
        if (x2 != "") {
            case_form.display_caseform(x1, x2);//抓案性特殊控制
        }
        case_form.ToFee(x1, x2, x3, "0");//***抓收費標準,0=主案性
        case_form.Display_Arcase(x1, x2, x3);//***抓附屬案性.轉帳費用
        //***附屬案性清空
        for (var r = 1; r <= CInt($("#TaCount").val()) ; r++) {
            $("#nfyi_item_Arcase_" + r).val("");
            $("#nfyi_item_count_" + r).val("1");
            $("#nfyi_Service_" + r).val("0");
            $("#nfzi_Service_" + r).val("0");
            $("#nfyi_fees_" + r).val("0");
            $("#nfzi_fees_" + r).val("0");
        }
        case_form.summary();
        //****顯示無收費標準
        if (reg.anfees.value == "N") reg.Discount.value = "無收費標準";

        //***2010/6/7因應結案流程修改，交辦結案代碼XX1~XX4且為舊案,顯示結案原因
        //***2010/10/12因增加結案選項，提醒交辦結案案性是否結案
        //***2011/1/10因交辦其他案性也可勾選結案註記，所以每個畫面加結案註記，因此結案案性畫面欄位名稱修改
        if (prt_code == "ZZ" && $("#ar_form").val().Left(1) != "B") {
            if ($("#tfy_Arcase").val().Left(2) == "XX") {
                $("#A9Ztr_endtype").show();
                if (confirm("交辦結案案性，請問是否結案？※確認結案則系統將續行結案流程並管制結案期限。")) {
                    $("#A9Z_end_flag").prop("checked", true);//zz_form
                    $("#tfy_end_flag").val("Y");//dmt_form
                } else {
                    $("#A9Z_end_flag").prop("checked", false);//zz_form
                    $("#tfy_end_flag").val("N");//dmt_form
                }
            } else {
                $("#A9Ztr_endtype").hide();
                $("#A9Z_end_flag").prop("checked", false);//zz_form
                $("#tfy_end_flag").val("N");//dmt_form
            }
        }
        case_form.setSendWay(x2)//20160909 增加發文方式
    }

    //抓取案性特殊控制(x1:國別:T為國內案,x2:案性代碼)
    case_form.display_caseform = function (x1, x2) {
        $("#spe_ctrl3").val("");
        $.ajax({
            type: "get",
            url: getRootPath() + "/ajax/json_Fee.aspx?type=spectrl&country=" + x1 + "&Arcase=" + x2 + "&ar_form=" + $("#ar_form").val() + "&prgid=<%#prgid%>",
            async: false,
            cache: false,
            success: function (json) {
                if ($("#chkTest").prop("checked")) toastr.info("<a href='" + this.url + "' target='_new'>Debug(抓取案性特殊控制)！<BR><b><u>(點此顯示詳細訊息)</u></b></a>");
                var jFee = $.parseJSON(json);
                $.each(jFee, function (i, item) {
                    if (item.rs_code != "") {
                        $("#spe_ctrl3").val(item.spe_ctrl3);
                    }
                });
            },
            error: function (xhr) { 
                $("#dialog").html("<a href='" + this.url + "' target='_new'>取得轉帳費用失敗！<u>(點此顯示詳細訊息)</u></a><hr>"+xhr.responseText);
                $("#dialog").dialog({ title: '取得轉帳費用失敗！', modal: true, maxHeight: 500,width: "90%" });
            }
        });
        //程序客收確認不能修改法定期限
        if ($("#prgid").val() == "brt51") {
            if ($("spe_ctrl3").val() == "Y") {
                $("#dfy_last_date").lock();
            } else {
                $("#dfy_last_date").unlock();
            }
        }
    }

    //依案性帶其他案性.轉帳費用(x1:國別:T為國內案,x2:案性代碼,x3:ar_form)
    case_form.Display_Arcase = function (x1, x2, x3) {
        $("select[id^='nfyi_item_Arcase_']").getOption({//其他費用
            url: getRootPath() + "/ajax/json_Fee.aspx",
            data: { type: "Arcase", country: x1, arcase: x2, ar_form: x3, prgid:"<%#prgid%>" },
            valueFormat: "{rs_code}",
            textFormat: "{rs_code}---{rs_detail}"
        });

        //轉帳費用
        $("#tfy_oth_arcase").val("");
        $.ajax({
            type: "get",
            url: getRootPath() + "/ajax/json_Fee.aspx?type=Arcase&country=" + x1 + "&Arcase=" + x2 + "&ar_form=" + x3 + "&mark=M&prgid=<%#prgid%>",
            async: false,
            cache: false,
            success: function (json) {
                if ($("#chkTest").prop("checked")) toastr.info("<a href='" + this.url + "' target='_new'>Debug(轉帳費用)！<BR><b><u>(點此顯示詳細訊息)</u></b></a>");
                var jFee = $.parseJSON(json);
                $.each(jFee, function (i, item) {
                    if (item.rs_code != "") {
                        $("#tfy_oth_arcase").val(item.rs_code);
                    }
                });
                case_form.ToFee("T", $("#tfy_oth_arcase").val(), $("#ar_form").val(), "10");
            },
            error: function (xhr) { 
                $("#dialog").html("<a href='" + this.url + "' target='_new'>取得轉帳費用失敗！<u>(點此顯示詳細訊息)</u></a><hr>"+xhr.responseText);
                $("#dialog").dialog({ title: '取得轉帳費用失敗！', modal: true, maxHeight: 500,width: "90%" });
            }
        });
    }

    //費用(x1:國別:T為國內案,x2:案性代碼,x3:ar_form,x4為第n個案性),收費標準
    case_form.ToFee = function (x1, x2, x3, x4) {
        var taCC = CInt($("#TaCount").val());
        //檢查其他費用有無重覆
        if (x4 > 0 && x4 <= taCC) {
            var objTa = {};
            for (var r = 1; r <= taCC; r++) {
                var lineTa = $("#nfyi_item_Arcase_" + r).val();
                if (lineTa != "" && objTa[lineTa]) {
                    alert(r + ".其他費用重覆，請重新輸入！");
                    $("#nfyi_item_Arcase_" + r + " option").eq(0).prop('selected', true);
                    $("#nfyi_item_count_" + r).val("1");
                    $("#nfyi_Service_" + r).val("0");
                    $("#nfyi_fees_" + r).val("0");
                    $("#nfzi_Service_" + r).val("0");
                    $("#nfzi_fees_" + r).val("0");
                    $("#nfyi_item_Arcase_" + r).focus();
                    case_form.summary();
                    return false;
                } else {
                    objTa[lineTa] = { flag: true, idx: r };
                }
            }
        }

        //取得案性費用
        if (x4 == 10) {//轉帳費用
            $("#nfy_oth_money").val("0");
            $("#oth_money").val("0");
        } else if (x4 >= 1) {//其他費用
            $("#nfyi_Service_" + x4).val("0");
            $("#nfzi_Service_" + x4).val("0");
            $("#nfyi_fees_" + x4).val("0");
            $("#nfzi_fees_" + x4).val("0");
        } else {
            $("#nfyi_Service").val("0");
            $("#Service").val("0");
            $("#nfyi_Fees").val("0");
            $("#Fees").val("0");
        }

        $.ajax({
            type: "get",
            url: getRootPath() + "/ajax/json_Fee.aspx?type=Fee&country=" + x1 + "&Arcase=" + x2 + "&ar_form=" + x3 + "&Service=" + x4 + "&prgid=<%#prgid%>",
            async: false,
            cache: false,
            success: function (json) {
                if ($("#chkTest").prop("checked")) toastr.info("<a href='" + this.url + "' target='_new'>Debug(收費標準)！<BR><b><u>(點此顯示詳細訊息)</u></b></a>");
                var jFee = $.parseJSON(json);
                //if (jFee.length != 0) {
                    if (x4 != 10) {//轉帳費用
                        $.each(jFee, function (i, item) {
                            if (x4 >= 1) {//其他費用
                                $("#nfyi_Service_" + x4).val(item.service * CInt($("#nfyi_item_count_" + x4).val()));
                                $("#nfzi_Service_" + x4).val(item.service);
                                $("#nfyi_fees_" + x4).val(item.fees * CInt($("#nfyi_item_count_" + x4).val()));
                                $("#nfzi_fees_" + x4).val(item.fees);
                            } else {//主案性
                                $("#nfyi_Service").val(item.service);
                                $("#Service").val(item.service);
                                $("#nfyi_Fees").val(item.fees);
                                $("#Fees").val(item.fees);
                                $("#fee_remark").val(item.remark);//注意事項
                            }
                        });
                    } else {
                        if (jFee.length == 0) {
                            $("#nfy_oth_money").val("0");
                            $("#oth_money").val("0");
                        } else {
                            $.each(jFee, function (i, item) {
                                $("#nfy_oth_money").val(item.service);
                                $("#oth_money").val(item.service);
                            });
                        }

                        if ($("#tfy_oth_arcase").val() == "") {
                            $("#tfy_oth_code").val("");
                        } else {
                            $("#tfy_oth_code").val("L");
                        }
                    }
                //}
            },
            error: function (xhr) { 
                $("#dialog").html("<a href='" + this.url + "' target='_new'>取得案性費用失敗！<u>(點此顯示詳細訊息)</u></a><hr>"+xhr.responseText);
                $("#dialog").dialog({ title: '取得案性費用失敗！', modal: true, maxHeight: 500,width: "90%" });
            }
        });

        case_form.summary();
    }

    //小計服務費及規費
    case_form.summary = function () {
        var nfy_service = 0;
        var nfy_fees = 0;
        nfy_service += CInt($("#nfyi_Service").val());
        nfy_fees += CInt($("#nfyi_Fees").val());

        for (var i = 1; i <= CInt($("#TaCount").val()) ; i++) {
            nfy_service += CInt($("#nfyi_Service_" + i).val());
            nfy_fees += CInt($("#nfyi_fees_" + i).val());
        }

        $("#OthSum").val(nfy_service + nfy_fees + CInt($("#nfy_oth_money").val()));
        case_form.special();

        if ($("#ar_form").val() == "A3") {//註冊費
            $("#fr_fees").val(nfy_fees);//繳費金額=規費
        }

        $("#nfy_service").val(nfy_service);
        $("#nfy_fees").val(nfy_fees);
    }

    //其他費用與項目小計
    case_form.item_count = function (nRow) {
        $("#nfyi_Service_" + nRow).val(CInt($("#nfyi_item_count_" + nRow).val()) * CInt($("#nfzi_Service_" + nRow).val()));
        $("#nfyi_fees_" + nRow).val(CInt($("#nfyi_item_count_" + nRow).val()) * CInt($("#nfzi_fees_" + nRow).val()));
        case_form.summary();
    }

    //計算折扣率?
    case_form.special = function () {
        if ($("#tfy_Ar_mark").val()=="") return false;
        $("#span_discount_remark").hide();
        $("#tfy_discount_remark").val("");
	
        if($("#tfy_Ar_mark").val()== "X"){
            $("#nfy_Discount").val(0);
            $("#Discount").val(0);
        }else if($("#tfy_Ar_mark").val()== "B"||$("#tfy_Ar_mark").val()== "N"){
            var tot_zservice = CInt($("#Service").val());
            var tot_yservice = CInt($("#nfyi_Service").val());
            for (var i = 1; i <= CInt($("#TaCount").val()) ; i++) {
                tot_zservice += CInt($("#nfzi_Service_" + i).val()) * CInt($("#nfyi_item_count_" + i).val());
                tot_yservice += CInt($("#nfyi_Service_" + i).val());
            }
            tot_zservice += CInt($("#oth_money").val());
            tot_yservice += CInt($("#nfy_oth_money").val());
            $("#tot_zservice").val(tot_zservice);
            $("#tot_yservice").val(tot_yservice);

            if (CInt($("#tot_zservice").val()) > CInt($("#tot_yservice").val())) {
                var dis = (1 - (CLng(tot_yservice) / CLng(tot_zservice))) * 100;
                $("#nfy_Discount").val(dis.format(2, 0));
                $("#Discount").val(dis.format(2, 0) + "%");
            } else {
                $("#nfy_Discount").val(0);
                if ($("#anfees").val() == "N") {
                    $("#Discount").val("無收費標準");
                } else {
                    $("#Discount").val("");
                }
            }

            //2016/5/30增加判斷，當折扣低於8折，顯示折扣理由
            if(CInt($("#nfy_Discount").val())>20){
                $("#span_discount_remark").show();
            }
        }else{
            $("#nfy_Discount").val("");
            if($("#anfees").val()=="N"){
                $("#Discount").val("無收費標準");
            }else{
                $("#Discount").val("");
            }
        }
    }
    
    //服務費檢查
    $("#nfyi_Service").blur(function () {
        if (IsEmpty(reg.nfyi_Service.value) || !IsNumeric(reg.nfyi_Service.value)) {
            alert("服務費填寫錯誤,請重新輸入");
            $("#nfyi_Service").val(0);
            return false;
        }
        case_form.summary();
        case_form.special();
    });

    //規費檢查
    $("#nfyi_Fees").blur(function () {
        if (IsEmpty(reg.nfyi_Fees.value) || !IsNumeric(reg.nfyi_Fees.value)) {
            $("#nfyi_Fees").val(0);
        }

        if ($("#tfy_Ar_mark").val() == "N" || $("#tfy_Ar_mark").val() == "A" || $("#tfy_Ar_mark").val() == "D") {//一般.實報實銷.扣收入
            if (CLng($("#nfyi_Fees").val()) < CLng($("#Fees").val()) && CLng($("#Fees").val()) > 0) {
                alert("規費小於收費標準");
                $("#nfyi_Fees").focus();
                return false;
            }
        }
        $("#nfyi_Service").blur();
    });

    //檢查附屬案性規費
    case_form.item_nfyi_fees = function (nRow) {
        if (IsEmpty($("#nfyi_fees_" + nRow).val()) || !IsNumeric($("#nfyi_fees_" + nRow).val())) {
            $("#nfyi_fees_"+nRow).val(0);
        }

        if ($("#tfy_Ar_mark").val() == "N" || $("#tfy_Ar_mark").val() == "A" || $("#tfy_Ar_mark").val() == "D") {
            if (CLng($("#nfyi_fees_"+nRow).val()) < CLng($("#nfzi_fees_"+nRow).val()) && CLng($("#nfzi_fees_"+nRow).val()) > 0) {
                alert("規費小於收費標準");
                $("#nfyi_fees_"+nRow).focus();
            }
        }
        case_form.summary();
    }

    //對應後續交辦[查詢/詳細]
    case_form.get_attcase = function (act) {
        if (act == "S") {
            if ($("#grconf_sqlno").val() == "") {
                alert("無對應後續交辦作業序號，無法查詢詳細資料！");
                return false;
            }
        }

        var url = getRootPath() + "/brt1m/brt11Qlist.aspx?prgid=<%=prgid%>&qrytype=" + act;
        url += "&cust_seq=" + $("#F_cust_seq").val() + "&scode=" + $("#F_tscode") + "&grconf_sqlno=" + $("#grconf_sqlno").val();
        window.open(url, "myWindowOneN", "width=650 height=420 top=40 left=80 toolbar=no, menubar=no, location=no, directories=no resizeable=no status=no scrollbars=yes");
    }

    //查詢總契約書
    $("#btn_contract").click(function () {
        var url = getRootPath() + "/brt1m/POA_attachlist.aspx?prgid=<%=prgid%>&dept=T&source=contract&cust_seq=" + $("#F_cust_seq").val() + "&upload_tabname=upload";
        window.open(url, "myWindowapN", "width=900 height=680 top=20 left=20 toolbar=no, menubar=no, location=no, directories=no resizeable=no status=no scrollbars=yes");

    });

    //☑契約書相關文件後補
    $("#tfy_contract_flag").click(function () {
        $("#tfy_contract_remark").unlock($(this).prop("checked"));
    });

    //契約書點選控制2015/12/25for總契約書增加
    $("input[name='Contract_no_Type']").click(function () {
        $("#span_btn_contract").hide();
        if ($(this).val() == "M") {//總契約書
            $("#tfy_Contract_no").val("");
            $("#span_btn_contract").show();
        } else if ($(this).val() != "N") {//不是一般契約書
            $("#tfy_Contract_no").val("");
        }
    });

    //20200701 增加顯示發文方式
    case_form.setSendWay = function () {
        $("#tfy_send_way").getOption({//發文方式
            url: getRootPath() + "/ajax/json_sendway.aspx",
            data: { rs_type: $("#code_type").val(), rs_code: $("#tfy_Arcase").val() },
            valueFormat: "{cust_code}",
            textFormat: "{code_name}"
        });
        $("#tfy_send_way option[value!='']").eq(0).prop("selected", true);

        case_form.setReceiptType();
    };

    //發文方式修改時調整收據種類選項
    case_form.setReceiptType = function () {
        //alert("setReceiptType");
        var send_way = $("#tfy_send_way").val();
        var receipt_type = $("#tfy_receipt_type");
        receipt_type.empty();
        receipt_type.append("<option value='' style='COLOR:blue'>請選擇</option>");

        if (send_way == "E" || send_way == "EA") {
            receipt_type.append(new Option("紙本收據", "P"));
            receipt_type.append(new Option("電子收據", "E", true, true));
        } else {
            receipt_type.append(new Option("紙本收據", "P", true, true));
        }
        case_form.setReceiptTitle();
    };

    //收據種類時調整收據抬頭預設
    case_form.setReceiptTitle = function () {
        //若是紙本收據抬頭預設空白
        if ($("#tfy_receipt_type").val() == "P") {
            $("#tfy_receipt_title").val("B");
        } else {
            $("#tfy_receipt_title").val("<%#recTitle%>");
        }
    };
</script>
