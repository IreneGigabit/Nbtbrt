<%@ Control Language="C#" ClassName="opt_send_form" %>

<script runat="server">
    protected string prgid = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string SQL = "";
    protected string branch = "";
    protected string opt_sqlno = "";
    protected string case_no = "";

    protected string send_cl = "", send_sel = "";
    protected string send_way = "", receipt_title = "";

    private void Page_Load(System.Object sender, System.EventArgs e) {
        branch = Request["branch"] ?? "";
        opt_sqlno = Request["opt_sqlno"] ?? "";
        case_no = Request["case_no"] ?? "";

        send_cl = Sys.getCustCode("SEND_CL","","").Option("{cust_code}", "{code_name}");
        send_sel = Sys.getCustCode("SEND_SEL", "", "").Option("{cust_code}", "{code_name}");
        send_way = Sys.getCustCode("GSEND_WAY", "", "").Option("{cust_code}", "{code_name}");
        receipt_title = Sys.getCustCode("rec_titleT", "", "").Option("{cust_code}", "{code_name}");

        this.DataBind();
    }
</script>

<%=Sys.GetAscxPath(this)%>
<table border="0" id=tabSend class="bluetable" cellspacing="1" cellpadding="2" width="100%">
	<Tr>
		<TD align=center colspan=6 class=lightbluetable1><font color="white">發&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;文&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;資&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;料</font></TD>
	</TR>
	<TR>
		<td class="lightbluetable"  align="right" nowrap>發文單位 :</td>
		<td class="whitetablebg"  align="left" colspan=5>
			<input type="radio" name="send_dept" class="SLock YYLock" value="B">自行發文
			<input type="radio" name="send_dept" class="SLock YYLock" value="L">轉法律處發文
		</td>
	</TR>
	<TR>
		<td class="lightbluetable"  align="right" nowrap>預計發文日期 :</td>
		<td class="whitetablebg"  align="left">
			 	<input type="text" id="GS_date" name="GS_date" SIZE=10  maxlength="10" class="SLock YYLock dateField">
		</td>
		<td class="lightbluetable"  align="right" nowrap>總收發文日期 :</td>
		<td class="whitetablebg"  align="left" colspan=3>
			<input type="text" id="mp_date" name="mp_date" SIZE=10  maxlength="10" class="SLock YYLock dateField">
		</td>
	</TR>
	<TR>
		<td class="lightbluetable"  align="right" nowrap>發文對象 :</td>
		<td class="whitetablebg"  align="left">
			<SELECT id=send_cl name=send_cl class="SLock YYLock"><%#send_cl%></SELECT>
		</td>
		<td class="lightbluetable"  align="right" nowrap>單位副本 :</td>
		<td class="whitetablebg"  align="left">
			<SELECT id=send_cl1 name=send_cl1  class="SLock YYLock"><%#send_cl%></SELECT>
		</td>
		<td class="lightbluetable"  align="right" nowrap>官方號碼 :</td>
		<td class="whitetablebg"  align="left">
			<SELECT id=send_sel name=send_sel class="SLock YYLock"><%#send_sel%></SELECT>
		</td>
	</TR>
	<TR>
		<td class="lightbluetable"  align="right" nowrap>發文代碼 :</td>
		<td class="whitetablebg"  align="left" colspan=5>
			結構分類：
			<input type="hidden" name="rs_type" id="rs_type">
			<span id=span_rs_class>
				<select id="rs_class" name="rs_class" class="SELock"></select>
			</span>
			案性：
			<span id=span_rs_code>
				<select id="rs_code" name="rs_code" class="SELock"></select>
			</span><br>
			處理事項：
			<input type="hidden" id="act_sqlno" name="act_sqlno">
			<span id=span_act_code>
				<select id="act_code" name="act_code" class="SLock YYLock" ></select>
			</span>	
		    <input type="hidden" id="code_br_agt_no" name="code_br_agt_no">
		    <input type="hidden" id="code_br_agt_nonm" name="code_br_agt_nonm">
		    <input type="hidden" id="rs_agt_no" name="rs_agt_no">
		</td>
	</TR>
	<TR>
		<td class="lightbluetable"  align="right" nowrap>發文內容 :</td>
		<td class="whitetablebg"  align="left" colspan=5>
			<input type="text" id="rs_detail" name="rs_detail" SIZE=60  maxlength="60" class="SLock YYLock">
		</td>
	</TR>
	<TR>
		<td class="lightbluetable"  align="right" nowrap>規費支出 :</td>
		<td class="whitetablebg"  align="left" colspan=5>
			<input type="text" id="Send_Fees" name="Send_Fees" SIZE=10  maxlength="10" class="SELock">
			<input type="hidden" id="old_Send_Fees" name="old_Send_Fees" SIZE=10  maxlength="10" class="SELock">
		</td>
	</TR>
    <TR id=tr_send_way>
	    <TD class=lightbluetable align=right>發文方式：</TD>
	    <TD class=whitetablebg><SELECT id="send_way" name="send_way" class="SELock"><%#send_way%></select>
	    </TD>
	    <TD class=lightbluetable align=right>官發收據種類：</TD>
	    <TD class=whitetablebg>
		    <select id="receipt_type" name="receipt_type" class="SELock">
			    <option value='' style='color:blue'>請選擇</option>
			    <option value="P">紙本收據</option>
			    <option value="E">電子收據</option>
		    </select>
	    </TD>
	    <TD class=lightbluetable align=right>收據抬頭：</TD>
	    <TD class=whitetablebg>
		    <select id="receipt_title" name="receipt_title" class="SELock"><%#receipt_title%></select>
		    <input type="hidden" id="rectitle_name" name="rectitle_name">
	    </TD>
    </tr>
	<TR id="tr_score_flag">
		<td class="lightbluetable"  align="right" nowrap>是否輸入評分 :</td>
		<td class="whitetablebg"  align="left" colspan=5>
			<input type="radio" name="score_flag" class="SLock" value="Y">是
			<input type="radio" name="score_flag" class="SLock" value="N">否
		</td>
	</TR>
</table>

<script language="javascript" type="text/javascript">
    var send_form = {};
    send_form.init = function () {
        send_form.loadOpt();
        //$(".LockB").lock($("#Back_flag").val() == "B"||$("#submittask").val() == "Q");
    }

    send_form.loadOpt = function () {
        var jOpt = br_opt.opt[0];

        $("#rs_class").getOption({//結構分類
            url: getRootPath() + "/ajax/JsonGetSqlData.aspx",
            data: {
                branch: "<%#branch%>"
                , sql: "select cust_code,code_name from cust_code where code_type='" + jOpt.rs_type + "' and mark is null and mark1='B' " +
				      " and cust_code in (select rs_class from vcode_act where cg ='G' and rs = 'S' and rs_type='" + jOpt.rs_type + "') order by cust_code"
            },
            valueFormat: "{cust_code}",
            textFormat: "{code_name}"
        });

        $("#rs_code").getOption({//案性
            url: getRootPath() + "/ajax/JsonGetSqlData.aspx",
            data: {
                branch: "<%#branch%>"
				, sql: "select rs_code,rs_detail,rs_class from code_br where dept='<%#Session["Dept"]%>' and gs='Y' " +
				      " and rs_type = '" + jOpt.rs_type + "' and mark='B' " +
					    " and (end_date is null or end_date = '' or end_date > getdate()) "+
				      " order by rs_class,rs_code"
            },
            valueFormat: "{rs_code}",
            textFormat: "{rs_detail}"
        });

        //處理事項
        var sql="select distinct b.act_code, c.code_name, c.sql from code_br a,code_act b,cust_code c " +
                " where a.dept = '<%#Session["Dept"]%>' and a.gs = 'Y'" +
                " and a.rs_type = '" + jOpt.rs_type + "' " +
                " and b.cg = 'G' and b.rs = 'S' " +
                " and a.sqlno = b.code_sqlno "+
                " and b.act_code = c.cust_code "+
                " and c.code_type = 'tact_Code' "+
                " and (a.end_date is null or a.end_date = '' or a.end_date > getdate()) "+
                " and (b.end_date is null or b.end_date = '' or b.end_date > getdate()) ";
        if (jOpt.rs_class !="") sql+= " and a.rs_class = '" +jOpt.rs_class + "' ";
        if (jOpt.rs_code !="") sql+= " and a.rs_code = '" +jOpt.rs_code + "' ";
        sql+=" order by c.sql";
        $("#act_code").getOption({
            url: getRootPath() + "/ajax/JsonGetSqlData.aspx",
            data: {
                branch: "<%#branch%>"
				, sql: sql
            },
            valueFormat: "{act_code}",
            textFormat: "{code_name}"
        });

        //預計發文日期
        $("#GS_date").val(dateReviver(jOpt.gs_date, "yyyy/M/d"));
        if($("#GS_date").val()==""&&$("#prgid").val()=="opt31_1"){//結辦
            $("#GS_date").val((new Date().format("yyyy/M/d")));
        }

        //總收發文日期,若無值,預設為發文日期後一天
        $("#mp_date").val(dateReviver(jOpt.mp_date, "yyyy/M/d"));
        if ($("#mp_date").val() == "" && $("#prgid").val() == "opt31_1") {//結辦
            switch ((new Date($("#GS_date").val())).getDay()) {
                case 5:
                    $("#mp_date").val(new Date($("#GS_date").val()).addDays(3).format("yyyy/M/d"));//星期五加三天
                    break;
                case 6:
                    $("#mp_date").val(new Date($("#GS_date").val()).addDays(2).format("yyyy/M/d"));//星期六加兩天
                    break;
                case 0:
                    $("#mp_date").val(new Date($("#GS_date").val()).addDays(1).format("yyyy/M/d"));//星期日加一天
                    break;
                default:
                    $("#mp_date").val(new Date($("#GS_date").val()).addDays(1).format("yyyy/M/d"));//加一天
                    break;
            }
        }

        //電子送件之總發文日為預計發文日期
        if ($("#prgid").val() == "opt31" || $("#prgid").val() == "opt31_1") {//承辦結辦
            if (jOpt.send_way == "E" || jOpt.send_way == "EA") {
                $("#mp_date").val($("#GS_date").val());
            }
        }

        //發文單位
        $("input[name='send_dept'][value='" + jOpt.send_dept + "']").prop("checked", true);

        //發文對象
        $("#send_cl").val(jOpt.send_cl);
        if ($("#send_cl").val() == "") {
            if ($("#rs_class").val().toUpperCase() == "C4")
                $("#send_cl").val("Q");
            else
                $("#send_cl").val("1");
        }

        //單位副本
        $("#send_cl1").val(jOpt.send_cl1);

        //官方號碼
        $("#send_sel").val(jOpt.send_sel);

        //發文內容
        $("#rs_detail").val(jOpt.rs_detail);

        //規費支出
        //var send_Fees = jOpt.bfees;
        //$("#Send_Fees").val(jOpt.bfees);
        //$("#old_Send_Fees").val(jOpt.bfees);

        //是否輸入評分
        if(jOpt.score_flag!=""){
            $("input[name='score_flag'][value='" + jOpt.score_flag + "']").prop("checked", true).triggerHandler("click");
        }else{
            $("input[name='score_flag'][value='" + $("#show_qu_form").val() + "']").prop("checked", true).triggerHandler("click");
        }
        $("#tr_score_flag").hideFor($("#prgid").val().indexOf("opt31") > -1 && $("#sameap_flag").val() == "N");//承辦結辦作業且承辦不是判行人員則不顯示

        $("#rs_type").val(jOpt.rs_type);
        $("#rs_class").val(jOpt.rs_class);
        if($("#submittask").val()!="Q") $("#rs_class").triggerHandler("change");
        $("#rs_code").val(jOpt.rs_code);
        if($("#submittask").val()!="Q") $("#rs_code").triggerHandler("change");
        $("#act_code").val(jOpt.act_code);
        if($("#submittask").val()!="Q") $("#act_code").triggerHandler("change");

        //送件方式(DB有值以DB為準)
        //if (jOpt.send_way !== undefined && jOpt.send_way != "") $("#send_way").val(jOpt.send_way);
        //if (jOpt.receipt_type !== undefined && jOpt.receipt_type != "") $("#receipt_type").val(jOpt.receipt_type);
        //if (jOpt.receipt_title !== undefined && jOpt.receipt_title != "") $("#receipt_title").val(jOpt.receipt_title);
        //if (jOpt.rectitle_name !== undefined && jOpt.rectitle_name != "") $("#rectitle_name").val(jOpt.rectitle_name);

        //規費支出
        if(jOpt.case_no==""){
            $("#send_fees").val(jOpt.send_fees);
        }else{
            if(jOpt.bfees !== undefined&&jOpt.bfees != null){
                $("#Send_Fees").val(jOpt.bfees);
                $("#old_Send_Fees").val(jOpt.bfees);
            }else{
                $("#Send_Fees").val(jOpt.fees);
                $("#old_Send_Fees").val(jOpt.fees);
            }
        }

        $("#send_way").val(jOpt.send_way);
        $("#receipt_type").val(jOpt.receipt_type);
        $("#receipt_title").val(jOpt.receipt_title);
        $("#rectitle_name").val(jOpt.rectitle_name);
    }

    //依結構分類帶案性代碼
    $("#rs_class").change(function () {
        $("#rs_code").getOption({//案性代碼
            url: getRootPath() + "/ajax/json_rs_code.aspx",
            data: { branch: "<%#branch%>", cgrs: "GR", rs_class: $("#rs_class").val() },
            valueFormat: "{rs_code}",
            textFormat: "{rs_detail}",
            attrFormat: "value1='{rs_class}'"
        });
    });

    //依案性帶處理事項/規費收費標準
    $("#rs_code").change(function () {
        $("#act_code").getOption({//處理事項
            url: getRootPath() + "/ajax/json_act_code.aspx",
            data: { branch: "<%#branch%>", cgrs: "GS", rs_class: $("#rs_class").val(), rs_code: $("#rs_code").val() },
            valueFormat: "{act_code}",
            textFormat: "{act_code_name}",
        });
        $("#act_code").val("_").triggerHandler("change");

        //規費收費標準
        $.ajax({
            type: "get",
            url: getRootPath() + "/ajax/json_Fee.aspx",
            data: { branch: "<%#branch%>", country: "T", arcase: $("#rs_code").val(), type: "Fee" },
            async: false,
            cache: false,
            success: function (json) {
                var JSONdata = $.parseJSON(json);
                if (JSONdata.length == 0) {
                    $("#Send_Fees").val("0");
                    $("#old_Send_Fees").val("0");
                } else {
                    $.each(JSONdata, function (i, item) {
                        $("#Send_Fees").val(item.fees);
                        $("#old_Send_Fees").val(item.fees);
                    });
                }
            },
            error: function () { toastr.error("<a href='" + this.url + "' target='_new'>規費收費標準載入失敗！<BR><b><u>(點此顯示詳細訊息)</u></b></a>"); }
        });

        if ($("#rs_class").val()!="" && $("#rs_code").val()!=""){
            send_form.getcode_br_agt_no();
        }
        //send_form.setSendWay();//依案性預設發文方式
    });

    //依處理事項代發文內容
    $("#act_code").change(function () {
        if ($(this).prop('selectedIndex') == 0) {
            $("#rs_detail").val($('#rs_code option:selected').text());
        } else {
            if ($('#act_code option:selected').text() != "_") {
                $("#rs_detail").val($('#rs_code option:selected').text() + $('#act_code option:selected').text());
            } else {
                $("#rs_detail").val($('#rs_code option:selected').text());
            }
            //當處理事項為補呈理由時，將規費清空為0
            if ($(this).val == "B2") {
                $("#Send_Fees").val("0");
            } else {
                $("#Send_Fees").val($("#old_Send_Fees").val());
            }
        }
    });

    //是否輸入評分
    $("input[name='score_flag']").click(function () {
        $("#tabQu").hideFor($("input[name='score_flag']:checked").val() == "N");
        if ($("input[name='score_flag']:checked").val() == "Y") {
            $("#Score,#opt_Remark").unlock();
        } else {
            $("#Score,#opt_Remark").lock();
        }
    });

    $("#Send_Fees").blur(function () {
        chkNum1($(this)[0], "規費");
    });

    send_form.getcode_br_agt_no=function(){
        $.ajax({
            type: "get",
            url: getRootPath() + "/ajax/json_rsagt_no.aspx",
            data: { branch: "<%#branch%>", cgrs: "GS", rs_type:$("#rs_type").val(),rs_class: $("#rs_class").val(),rs_code: $("#rs_code").val() },
            async: false,
            cache: false,
            success: function (json) {
            var JSONdata = $.parseJSON(json);
                $.each(JSONdata, function (i, item) {
                    $("#code_br_agt_no").val(item.remark);
                    $("#code_br_agt_nonm").val(item.agt_name);
                });
            },
            error: function () { toastr.error("<a href='" + this.url + "' target='_new'>規費收費標準載入失敗！<BR><b><u>(點此顯示詳細訊息)</u></b></a>"); }
        });
    }

    //20200701 增加顯示發文方式
    send_form.setSendWay = function () {
        $("#send_way").getOption({
            url: getRootPath() + "/ajax/json_sendway.aspx",
            data: { branch: "<%#branch%>", rs_type: $("#rs_type").val(), rs_code: $("#rs_code").val() },
            valueFormat: "{cust_code}",
            textFormat: "{code_name}"
        });

        $("#send_way option[value!='']").eq(0).prop("selected", true);
        send_form.setReceiptType();
    };

    //發文方式修改時調整收據種類選項
    send_form.setReceiptType = function () {
        var send_way = $("#send_way").val();
        var receipt_type = $("#receipt_type");
        receipt_type.empty();
        receipt_type.append("<option value='' style='COLOR:blue'>請選擇</option>");

        if (send_way == "E" || send_way == "EA") {
            receipt_type.append(new Option("紙本收據", "P"));
            receipt_type.append(new Option("電子收據", "E", true, true));
        } else {
            receipt_type.append(new Option("紙本收據", "P", true, true));
        }
        send_form.setReceiptTitle();
    };

    //收據種類時調整收據抬頭預設
    send_form.setReceiptTitle = function () {
        //若是紙本收據抬頭預設空白
        if ($("#receipt_type").val() == "P") {
            $("#receipt_title").val("B");
        } else {
            $("#receipt_title").val("A");
        }
    };
</script>
