<%@ Control Language="C#" ClassName="brt511form" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Data"%>

<script runat="server">
    //父控制項傳入的參數
    public Dictionary<string, string> Lock = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    public Dictionary<string, string> Hide = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    public int HTProgRight = 0;

    protected string submitTask = "";
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//功能權限代碼
    protected string SQL = "";

    protected string html_pr_scode="",html_send_sel = "", html_pay_times = "";

    DBHelper conn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    private void Page_Unload(System.Object sender, System.EventArgs e) {
        if (conn != null) conn.Dispose();
    }

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
        submitTask = (Request["submittask"] ?? "").Trim().ToUpper();

        //html_pr_scode = Sys.getPrScode().Option("{scode}", "{scode}_{sc_name}", "", false, "", "sort=01");
        html_pr_scode = Sys.getPrScode().Option("{scode}", "{scode}_{sc_name}", "", false);
        html_send_sel = Sys.getCustCode("SEND_SEL", "", "cust_code").Option("{cust_code}", "{code_name}");
        html_pay_times = Sys.getCustCode(Sys.GetSession("dept") + "PAY_TIMES", "", "sortfld").Option("{cust_code}", "{code_name}");

        PageLayout();
        this.DataBind();
    }

    private void PageLayout() {
        if (submitTask == "Q" || submitTask == "D") {
            Lock["Qdisabled"] = "Lock";
            Lock["Qdisabled_opt"] = "Lock";
        }
    }
</script>

<%=Sys.GetAscxPath(this.AppRelativeVirtualPath)%>
<TABLE id=tabbr style="display:" border=0 class="bluetable" cellspacing=1 cellpadding=2 width="100%">
	<TR>
		<TD align=center colspan=6 class=lightbluetable1><font color=white>收&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;文&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;資&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;料</font></TD>
	</TR>
	<TR>
		<TD class=lightbluetable align=right>進度序號：</TD>
		<TD class=whitetablebg>
			<input type="text" id="closewin" name="closewin" value="N">
			<input type="text" id="code" name="code"><!--todo.sqlno-->
			<input type="text" id="in_no" name="in_no">
			<input type="text" id="in_scode" name="in_scode">
			<input type="text" id="change" name="change">
			<input type="text" id="cust_area1" name="cust_area1">
			<input type="text" id="cust_seq1" name="cust_seq1">
			<input type="text" id="rs_no" name="rs_no">
			<input type="text" id="nstep_grade" name="nstep_grade" size="2" class="SEdit" readonly>
			<input type="text" id="cgrs" name="cgrs">
			<select id=scgrs name=scgrs class="<%=Lock.TryGet("Qdisabled")%>">
				<option value="CR">客收</option>
			</select>
		</TD>
		<TD class=lightbluetable align=right>收文日期：</TD>
		<TD class=whitetablebg ><input type="text" id="step_date" name="step_date" size="10" class="dateField <%=Lock.TryGet("Qdisabled")%>"></TD>
		<TD class=lightbluetable align=right>來文字號：</TD>
		<TD class=whitetablebg ><input type="text" id="receive_no" name="receive_no" size=20 maxlength=20 class="<%=Lock.TryGet("Qdisabled")%>"></TD>
	</TR>
	<TR>
		<TD class=lightbluetable align=right>收文代碼：</TD>
		<TD class=whitetablebg colspan=5>結構分類：
			<input type="text" name="rs_type" id="rs_type">
			<span id=span_rs_class>
			<input type="text" name="hrs_class" id="hrs_class">
			<select name="rs_class" id="rs_class"  class="Lock"></select>
			</span>
			案性代碼：
			<span id=span_rs_code>
				<input type="text" name="hrs_code" id="hrs_code">
				<select name="rs_code" id="rs_code" class="Lock"></select>
			</span><br>
			處理事項：
			<input type="text" name="act_sqlno" id="act_sqlno">
			<span id=span_act_code>
				<input type="text" name="hact_code" id="hact_code">
				<select name="act_code" id="act_code" class="Lock"></select>
			</span>
			&nbsp;&nbsp;&nbsp;&nbsp;本次狀態：
			<input type="text" name="ocase_stat" id="ocase_stat">
			<input type="text" name="ncase_stat" id="ncase_stat">
			<input type="text" name="ncase_statnm" id="ncase_statnm" size="10" class="Lock">
		</TD>
    </TR>
    <TR>
		<TD class=lightbluetable align=right>收文內容：</TD>
		<TD class=whitetablebg colspan=5><input type="text" name="rs_detail" id="rs_detail" size=60 class="<%=Lock.TryGet("Qdisabled")%>"></TD>
	</TR>
    <TR>
		<TD class=lightbluetable align=right>附件：</TD>
		<TD class=whitetablebg colspan=5><input type="text" name="doc_detail" id="doc_detail" size=60 maxlength=60 class="<%=Lock.TryGet("Qdisabled")%>"></TD>
	</tr>
	<TR>
		<TD class=lightbluetable align=right>承辦：</TD>
		<TD class=whitetablebg colspan=3>
			<SELECT name="pr_scode" id="pr_scode" class="<%=Lock.TryGet("Qdisabled")%>">
			<option value="" style="color:blue">不需承辦</option><%=html_pr_scode%>
			</SELECT>
		</TD>
		<TD class=lightbluetable align=right>官方號碼：</TD>
		<TD class=whitetablebg>
			<SELECT name=send_sel id=send_sel class="<%=Lock.TryGet("Qdisabled")%>"><%=html_send_sel%></SELECT>
		</TD>		
	</TR>
	<TR id="show_optstat" style="display:none">
		<TD class=lightbluetable align=right><font color=darkblue>※爭救案交辦：</font></TD>
		<TD class=whitetablebg colspan=5>
			<input type=radio name="opt_stat" value="N" class="<%=Lock.TryGet("Qdisabled_opt")%>">需交辦
			<input type=radio name="opt_stat" value="X" class="<%=Lock.TryGet("Qdisabled_opt")%>">不需交辦
			<span id="sp_optstat" style="display:none">
			<input type=radio name="opt_stat" value="Y" class="<%=Lock.TryGet("Qdisabled_opt")%>">已交辦
			</span>
		</TD>
	</tr>
	<%if(prgid == "brt51"){%>	
	    <tr id="show_paytimes" style="display:none">
			    <td class="lightbluetable" align="right">註冊費繳納：</td>
			    <td class="whitetablebg" colspan=3 >
	   			    <Select NAME=pay_times id=pay_times class="<%=Lock.TryGet("Qdisabled")%>"><%=html_pay_times%>
				    </SELECT>						
			    </td>
			    <td class="lightbluetable"  align="right">繳納日期：</td>
			    <td class="whitetablebg"><input type="text" name="pay_date" id="pay_date" size="10" class="dateField <%=Lock.TryGet("Qdisabled")%>"></td>
	    </tr>
	    <TR id="show_endstat" style="display:none">
		    <TD class=lightbluetable align=right><font color=darkblue>結案處理：</font></TD>
		    <TD class=whitetablebg colspan=5>
			    <input type=radio name="end_stat" value="B61" class="<%=Lock.TryGet("Qdisabled")%>" onclick="brt511form.end_stat()">送會計確認
			    <input type=radio name="end_stat" value="B6" class="<%=Lock.TryGet("Qdisabled")%>" onclick="brt511form.end_stat()">待結案處理
		    </TD>
	    </tr>
	<%}%>
	<TR><!--20160923 增加維護發文方式-->
		<TD class=lightbluetable align=right>發文方式：</TD>
		<TD class=whitetablebg colspan=5><input type="text" id="old_send_way" name="old_send_way">
		<SELECT id="send_way" name="send_way"></select>
		</TD>
	</TR>
	<%if(prgid=="brta22"){%>
	    <TR><!--20160923 增加維護發文方式-->
		    <!--20180712 增加客收維護可修改收據種類-->
		    <TD class=lightbluetable align=right>官發收據種類：</TD>
		    <TD class=whitetablebg><input type="text" id="old_receipt_type" name="old_receipt_type">
			    <select id="receipt_type" name="receipt_type">
				    <option value="" style="color:blue">請選擇</option>
				    <option value="P">紙本收據</option>
				    <option value="E">電子收據</option>
			    </select>
		    </TD>
		    <TD class=lightbluetable align=right>收據抬頭：</TD>
		    <TD class=whitetablebg colspan=3><input type="text" id="old_receipt_title" name="old_receipt_title">
			    <select id="receipt_title" name="receipt_title">
				    <option value="" style="color:blue">請選擇</option>
				    <option value="A">案件申請人</option>
				    <option value="B">空白</option>
				    <option value="C">案件申請人(代繳人)</option>
			    </select>
		    </TD>
	    </TR>
	<%}%>
</table>
<input type="text" name=tot_num id=tot_num value=0><!--一案多件筆數-->
<TABLE id=tabar1 style="display:none" border=0 class="bluetable" cellspacing=1 cellpadding=2 width="100%">
    <thead>
	<TR>
		<TD class=whitetablebg colspan=7><span id="span_seqdesc">此次變更本所編號：</span></TD>
	</TR>
	<TR align=center class=lightbluetable>
		<TD></TD><TD class="rs_code_FD">本所編號</TD><td>商標種類</TD><TD>類別</TD><TD>商標/案件名稱</TD>
		<TD><span id="span_no">申請號</span></TD>
	</TR>
    </thead>
    <tbody></tbody>
    <script type="text/html" id="cr_ar1_template"><!--一案多件樣板-->
	    <tr id=tr_cr_##>
		    <td class=whitetablebg align=center>
	            ##.
		    </td>
		    <td class="whitetablebg rs_code_FD" align=center>
		        <input type=text size=5 id=dseq_## name=dseq_## class='sedit' readonly>
		        -<input type=text size=1 id=dseq1A_## name=dseq1A_## class='sedit' readonly value='_' >
		        <input type=text name=hrs_no_## id=hrs_no_##>
		    </td>
		    <td class=whitetablebg align=center>
	            <input type=text id='s_mark_##' name=s_mark_## style='text-align:left;' readonly class='SEdit'>
		    </td>
		    <td class=whitetablebg align=center>
	            <input type=text id=dclass_## name=dclass_## style='text-align:left;' readonly class='SEdit'>
		    </td>
		    <td class=whitetablebg align=center>
		        <input type=text id=appl_name_## name=appl_name_## style='text-align:left;' readonly class='SEdit'>
		    </td>
		    <td class=whitetablebg align=center>
		        <input type=text id=dref_no_## name=dref_no_## style='text-align:center;' readonly class='SEdit'>
		    </td>
	    </tr>
    </script>
</table>

<script language="javascript" type="text/javascript">
    var brt511form = {};

    brt511form.init = function () {
    }

    brt511form.bind = function (jData) {
        $("#code").val(jData.code);
        $("#in_no").val(jData.in_no);
        $("#in_scode").val(jData.in_scode);
        $("#change").val(jData.change);
        $("#cust_area,#cust_area1").val(jData.cust_area);
        $("#cust_seq,#cust_seq1").val(jData.cust_seq);
        $("#rs_no").val(jData.rs_no);
        $("#nstep_grade").val(jData.step_grade);
        $("#cgrs").val(jData.cgrs);
        $("#step_date").val(jData.step_date);
        $("#receive_no").val(jData.receive_no);
        $("#rs_type").val(jData.rs_type);//結構分類
        $("#rs_type").triggerHandler("change");
        $("#hrs_class").val(jData.rs_class);
        $("#rs_class option[value='" + jData.rs_class + "']").prop("selected", true);
        $("#rs_class").triggerHandler("change");
        $("#hrs_code").val(jData.rs_code);
        $("#rs_code option[value='" + jData.rs_code + "']").prop("selected", true);
        $("#rs_code").triggerHandler("change");
        $("#act_sqlno").val(jData.act_sqlno);
        $("#hact_code").val(jData.act_code);
        $("#act_code option[value='" + jData.act_code + "']").prop("selected", true);
        $("#act_code").triggerHandler("change");
        $("#ocase_stat,#ncase_stat").val(jData.case_stat);
        $("#ncase_statnm").val(jData.case_statnm);
        $("#rs_detail").val(jData.rs_detail);
        $("#pr_scode option[value='" + jData.pr_scode + "']").prop("selected", true);
        $("#send_sel option[value='" + jData.send_sel + "']").prop("selected", true);
        $("input[name='opt_stat'][value='" + jData.opt_stat + "']").prop("checked", true);
        $("#pay_times option[value='" + jData.pay_times + "']").prop("selected", true);
        $("#pay_date").val(jData.pay_date);
        $("#old_send_way").val(jData.send_way);
        $("#send_way option[value='" + jData.send_way + "']").prop("selected", true);
        $("#old_receipt_type").val(jData.receipt_type);
        $("#receipt_type option[value='" + jData.receipt_type + "']").prop("selected", true);
        $("#old_receipt_title").val(jData.receipt_title);
        $("#receipt_title option[value='" + jData.receipt_title + "']").prop("selected", true);

        if (main.submittask == "A") {
            $("input[name='opt_stat'][value='N']").prop("checked", true);//需交辦
            $("input[name='end_stat'][value='B61']").prop("checked", true);//送會計確認
        }
    }

    //依rs_type帶結構分類
    $("#rs_type").change(function () {
        $("#rs_class").getOption({
            url: getRootPath() + "/ajax/JsonGetSqlData.aspx",
            data: {
                sql: "select cust_code,code_name from cust_code where code_type='" + $("#rs_type").val() + "' and mark is null " +
				      " and cust_code in (select rs_class from vcode_act where cg ='C' and rs = 'R') order by cust_code"
            },
            valueFormat: "{cust_code}",
            textFormat: "{code_name}"
        });
    });

    //依結構分類帶案性代碼
    $("#rs_class").change(function () {
        $("#rs_code").getOption({//案性代碼
            url: getRootPath() + "/ajax/json_rs_code.aspx",
            data: { cgrs: "CR", rs_class: $("#rs_class").val(), rs_type: $("#rs_type").val() },
            valueFormat: "{rs_code}",
            textFormat: "{rs_detail}",
            attrFormat: "vrs_class='{rs_class}'"
        });
    });

    //依案性帶處理事項
    $("#rs_code").change(function () {
        $("#act_code").getOption({//處理事項
            url: getRootPath() + "/ajax/json_act_code.aspx",
            data: { cgrs: "CR", rs_class: $("#rs_class").val(), rs_code: $("#rs_code").val() },
            valueFormat: "{act_code}",
            textFormat: "{act_code_name}",
            attrFormat: "spe_ctrl='{spe_ctrl}'"
        });
        brt511form.setSendWay();
    });

    //20200701 增加顯示發文方式
    brt511form.setSendWay = function () {
        $("#send_way").getOption({//發文方式
            url: getRootPath() + "/ajax/json_sendway.aspx",
            data: { rs_type: $("#rs_type").val(), rs_code: $("#rs_code").val() },
            valueFormat: "{cust_code}",
            textFormat: "{code_name}"
        });
        $("#send_way option[value!='']").eq(0).prop("selected", true);
    };

    $("#step_date").blur(function () {
        ChkDate($(this)[0]);
    });

    //一案多件/分割 增加一筆子案
    brt511form.add_sub = function () {
        var nRow = CInt($("#tot_num").val()) + 1;
        //複製樣板
        var copyStr = $("#cr_ar1_template").text() || "";
        copyStr = copyStr.replace(/##/g, nRow);
        $("#tabar1 tbody").append(copyStr);
        $("#tot_num").val(nRow);
        $(".dateField", $('#tr_cr_' + nRow)).datepick();
    }

    //一案多件時取得子案本所編號
    brt511form.getdseq = function (jData) {
        //案性為一案多件時, 要顯示 sub seq 的畫面
        $("#tabar1").show();
        if ($("#rs_code").val() == "FC11" || $("#rs_code").val() == "FC5" || $("#rs_code").val() == "FC7" || $("#rs_code").val() == "FCH") {
            $("#span_no").html("申請號");
        } else if ($("#rs_code").val() == "FC21" || $("#rs_code").val() == "FC6" || $("#rs_code").val() == "FC8" || $("#hrs_code").val() == "FCI"
             || $("#hrs_code").val() == "FT2" || $("#hrs_code").val() == "FL5" || $("#hrs_code").val() == "FL6") {
            $("#span_no").html("註冊號");
        }

        if ($("#rs_code").val() == "FT2") {
            $("#span_seqdesc").html("此次移轉本所編號：");
        } else if ($("#rs_code").val() == "FL5") {
            $("#span_seqdesc").html("此次授權本所編號：");
        } else if ($("#rs_code").val() == "FL6") {
            $("#span_seqdesc").html("此次再授權本所編號：");
        } else {
            $("#span_seqdesc").html("此次變更本所編號：");
        }

        //產生母案案號
        brt511form.add_sub();
        var spl_num =1;
        $("#dseq_" + spl_num).val(jData.seq);
        $("#dseq1A_" + spl_num).val(jData.seq1);
        $("#s_mark_" + spl_num).val(jData.s_marknm);
        $("#dclass_" + spl_num).val(jData.class);
        $("#appl_name_" + spl_num).val(jData.appl_name);
        if ($("#hrs_code").val() == "FC11" || $("#hrs_code").val() == "FC5" || $("#hrs_code").val() == "FC7" || $("#hrs_code").val() == "FCH") {
            $("#dref_no_" + spl_num).val(jData.apply_no);
        } else if ($("#hrs_code").val() == "FC21" || $("#hrs_code").val() == "FC6" || $("#hrs_code").val() == "FC8" || $("#hrs_code").val() == "FCI") {
            $("#dref_no_" + spl_num).val(jData.issue_no);
        }

        //取得一案多件子案
        var jDmt1 = {};
        $.ajax({
            type: "get",
            url: getRootPath() + "/ajax/json_get_dmt_temp_sub.aspx?prgid=" + main.prgid + "&in_no=" + main.in_no,
            async: false,
            cache: false,
            success: function (json) {
                toastr.info("<a href='" + this.url + "' target='_new'>Debug(json_get_dmt_temp_sub)！<BR><b><u>(點此顯示詳細訊息)</u></b></a>");
                jSub = $.parseJSON(json);
            },
            error: function (xhr) {
                $("#dialog").html("<a href='" + this.url + "' target='_new'>取得分割子案失敗！<u>(點此顯示詳細訊息)</u></a><hr>" + xhr.responseText);
                $("#dialog").dialog({ title: '取得分割子案失敗！', modal: true, maxHeight: 500, width: "90%" });
            }
        });

        $.each(jDmt1, function (i, item) {
            //產生一案多件子案案號
            brt511form.add_sub();
            var spl_num = (i + 2);//1是母案,從2開始
            $("#dseq_" + spl_num).val(item.seq);
            $("#dseq1A_" + spl_num).val(item.seq1);
            $.each(item.get_dmt, function (x, xitem) {
                $("#s_mark_" + spl_num).val(xitem.s_marknm);
                $("#dclass_" + spl_num).val(xitem.class);
                $("#appl_name_" + spl_num).val(xitem.appl_name);
                if ($("#hrs_code").val() == "FC11" || $("#hrs_code").val() == "FC5" || $("#hrs_code").val() == "FC7" || $("#hrs_code").val() == "FCH") {
                    $("#dref_no_" + spl_num).val(xitem.apply_no);
                } else if ($("#hrs_code").val() == "FC21" || $("#hrs_code").val() == "FC6" || $("#hrs_code").val() == "FC8" || $("#hrs_code").val() == "FCI") {
                    $("#dref_no_" + spl_num).val(xitem.issue_no);
                }
            });
        });

        $(".rs_code_FD").show();
    }

    //分割時取得子案本所編號
    brt511form.getdseq1 = function (jData) {
        //案性為一案多件時, 要顯示 sub seq 的畫面
        $("#tabar1").show();
        if ($("#rs_code").val() == "FD1") {
            $("#span_no").html("申請號");
        } else if ($("#rs_code").val() == "FD2" || $("#rs_code").val() == "FD3") {
            $("#span_no").html("註冊號");
        }
        $("#span_seqdesc").html("此次分割案件資料：");

        //取得分割子案
        var jSub = {};
        $.ajax({
            type: "get",
            url: getRootPath() + "/ajax/json_get_dmt_temp_sub.aspx?prgid=" + main.prgid + "&in_no=" + $("#in_no").val(),
            async: false,
            cache: false,
            success: function (json) {
                toastr.info("<a href='" + this.url + "' target='_new'>Debug(json_get_dmt_temp_sub)！<BR><b><u>(點此顯示詳細訊息)</u></b></a>");
                jSub = $.parseJSON(json);
            },
            error: function (xhr) {
                $("#dialog").html("<a href='" + this.url + "' target='_new'>取得分割子案失敗！<u>(點此顯示詳細訊息)</u></a><hr>" + xhr.responseText);
                $("#dialog").dialog({ title: '取得分割子案失敗！', modal: true, maxHeight: 500, width: "90%" });
            }
        });

        $.each(jSub, function (i, item) {
            //產生分割子案案號
            brt511form.add_sub();
            var spl_num = (i + 1);
            $("#dseq_" + spl_num).val(item.seq);
            $("#s_mark_" + spl_num).val(item.s_marknm);
            $("#dclass_" + spl_num).val(item.class);
            $("#appl_name_" + spl_num).val(item.appl_name);
            if ($("#hrs_code").val() == "FC11" || $("#hrs_code").val() == "FC5" || $("#hrs_code").val() == "FC7" || $("#hrs_code").val() == "FCH") {
                $("#dref_no_" + spl_num).val(item.apply_no);
            } else if ($("#hrs_code").val() == "FC21" || $("#hrs_code").val() == "FC6" || $("#hrs_code").val() == "FC8" || $("#hrs_code").val() == "FCI") {
                $("#dref_no_" + spl_num).val(item.issue_no);
            }
        });

        $(".rs_code_FD").hide();
    }

    //產生預設期限
    brt511form.getCtrl = function (jData) {
        if(jData.cust_date!=""){
            //新增客戶期限
            brta212form.add_ctrl();
            $("#ctrl_type_"+$("#ctrlnum").val()).val("A2");
            $("#ctrl_date_"+$("#ctrlnum").val()).val(jData.cust_date);
        }
        if(jData.pr_date!=""){
            //新增承辦期限
            brta212form.add_ctrl();
            $("#ctrl_type_"+$("#ctrlnum").val()).val("B2");
            $("#ctrl_date_"+$("#ctrlnum").val()).val(jData.pr_date);
        }
        //2010/10/6修改為結案註記有勾選結案才顯示
        if($("#seqend_flag").val()=="Y"){
            //新增結案完成期限
            brta212form.add_ctrl();
            $("#ctrl_type_"+$("#ctrlnum").val()).val("B61");
            $("#ctrl_date_"+$("#ctrlnum").val()).val(Today().addMonths(3).format("yyyy/M/d"));
            $("#ctrl_remark_"+$("#ctrlnum").val()).val("程序確認結案暨掃描完成期限");
        }
	
        //取得案性管制設定
        $.ajax({
            type: "get",
            url: getRootPath() + "/ajax/json_act_sqlno.aspx?cgrs=" + $("#cgrs").val()+ "&rs_class=" + $("#rs_class").val()+"&rs_code=" + $("#rs_code").val()+"&act_code=" + $("#act_code").val(),
            async: false,
            cache: false,
            success: function (json) {
                var jCtrl = $.parseJSON(json);
                $.each(jCtrl, function (i, item) {
                    if(item.sqlflg=="A"&&item.ctrl_type!="A2"&&item.ctrl_type!="B2"){
                        $("#act_sqlno").val(item.ctrl_sqlno);
                        brta212form.add_ctrl();
                        $("#ctrl_type_"+$("#ctrlnum").val()).val(item.ctrl_type);//管制種類
                        $("#ctrl_remark_"+$("#ctrlnum").val()).val(item.ctrl_remark);//管制內容
                        var days=0;//管制天數
                        if(item.ad=="A"){//日期基礎:A:加，D:減 
                            days=CInt(item.days);
                        }else{
                            days=CInt(item.days)*-1;
                        }
                        var days2=0;//管制天數
                        if(item.ad2=="A"){//日期基礎:A:加，D:減 
                            days2=CInt(item.days2);
                        }else{
                            days2=CInt(item.days2)*-1;
                        }
                       
                        var md=item.md;//管制性質
                        var md2=item.md2;//管制性質
                        var date_ctrl=$("#"+item.date_name).val()||"";//基準日期欄位
                        if(date_ctrl==""){
                            alert("管制天數之基準日期未輸入, 請輸入!!");
                            $("#act_sqlno").val("");
                            $("#"+item.date_name).focus();
                        }

                        var Cdate_ctrl=CDate(date_ctrl);
                        if(md.toUpperCase()=="D"){
                            Cdate_ctrl=Cdate_ctrl.addDays(days);
                        }else if(md.toUpperCase()=="M"){
                            Cdate_ctrl=Cdate_ctrl.addMonths(days);
                        }else if(md.toUpperCase()=="Y"){
                            Cdate_ctrl=Cdate_ctrl.addYears(days);
                        }

                        if(item.ad2!=""){
                            if(md2.toUpperCase()=="D"){
                                Cdate_ctrl=Cdate_ctrl.addDays(days2);
                            }else if(md2.toUpperCase()=="M"){
                                Cdate_ctrl=Cdate_ctrl.addMonths(days2);
                            }else if(md2.toUpperCase()=="Y"){
                                Cdate_ctrl=Cdate_ctrl.addYears(days2);
                            }
                        }

                        $("#ctrl_date_"+$("#ctrlnum").val()).val(Cdate_ctrl.format("yyyy/M/d"));//管制日期
                        $("#ncase_stat").val(item.case_stat);
                        $("#ncase_statnm").val(item.case_statnm);
                    }
                })
            },
            error: function (xhr) {
                $("#dialog").html("<a href='" + this.url + "' target='_new'>案性管制載入失敗！<u>(點此顯示詳細訊息)</u></a><hr>" + xhr.responseText);
                $("#dialog").dialog({ title: '案性管制載入失敗！', modal: true, maxHeight: 500, width: "90%" });
            }
        });
    }

    //結案處理
    brt511form.end_stat = function () {
        if ($("input[name='end_stat']:eq(0)").prop("checked") == true) {//送會計確認
            alert("修改管制種類為結案完成期限，請檢查！");
            for (var k = 1; k <= CInt($("#ctrlnum").val()) ; k++) {
                if ($("#ctrl_type_" + k).val() == "B6") {
                    $("#ctrl_type_" + k).val("B61");
                    $("#ctrl_date_" + k).val(Today().addMonths(3).format("yyyy/M/d"));
                    $("#ctrl_remark_" + k).val("程序確認結案暨掃描完成期限");
                }
            }
        } else {//待結案處理
            alert("修改管制種類為結案期限，請檢查！");
            if ($("#ctrl_type_" + k).val() == "B61") {
                $("#ctrl_type_" + k).val("B6");
                $("#ctrl_date_" + k).val(Today().addMonths(1).format("yyyy/M/d"));
                $("#ctrl_remark_" + k).val("結案處理期限");
            }

        }
    }
</script>
