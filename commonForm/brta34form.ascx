<%@ Control Language="C#" ClassName="brta34form" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Data"%>

<script runat="server">
    //本發欄位畫面
    //父控制項傳入的參數
    public Dictionary<string, string> Lock = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    public Dictionary<string, string> Hide = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    public int HTProgRight = 0;

    protected string submitTask = "";
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//功能權限代碼
    protected string SQL = "";

    protected string html_send_cl = "",html_receive_way="";
    //protected string html_pr_scode="",html_send_sel = "",html_rfees_stat="",html_send_way="";

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

        html_receive_way = Sys.getCustCode("Treceive_way", "and ref_code='ZS'", "cust_code").Option("{cust_code}", "{code_name}");
        html_send_cl = Sys.getCustCode("SEND_CL", "", "cust_code").Option("{cust_code}", "{code_name}");
        
        PageLayout();
        this.DataBind();
    }

    private void PageLayout() {
    }
</script>

<%=Sys.GetAscxPath(this.AppRelativeVirtualPath)%>
<TABLE id=tabgs border=0 class="bluetable" cellspacing=1 cellpadding=2 width="100%">
    	<TR>
		<TD align=center colspan=6 class=lightbluetable1><font color=white>發&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;文&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;資&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;料</font></TD>
	</TR>
	<TR>
		<TD class=lightbluetable align=right>進度序號：</TD>
		<TD class=whitetablebg>
			<input type="text" id="rs_no" name="rs_no">
			<input type="text" id="nstep_grade" name="nstep_grade" size=3 class=sedit readonly>
			<input type="text" id="cgrs" name="cgrs">
			<input type="text" id="scgrs" name="scgrs" size=4 class=sedit readonly>
		</TD>
		<TD class=lightbluetable align=right>發文日期：</TD>
		<TD class=whitetablebg><input type="text" id="step_date" name="step_date" size="10" class="dateField <%=Lock.TryGet("QLock")%>"></TD>
		<TD class=lightbluetable align=right>公文日期：</TD>
		<TD class=whitetablebg><input type="text" id="gov_date" name="gov_date" size="10" class="dateField <%=Lock.TryGet("QLock")%>"></TD>
	</TR>
	<TR id=tr_send>	
		<TD class=lightbluetable align=right>發文方式：</TD>
		<TD class=whitetablebg colspan="3">
			<SELECT id=receive_way name=receive_way class="<%=Lock.TryGet("QLock")%>"><%=html_receive_way%></SELECT>
		</TD>
		<TD class=lightbluetable align=right>來文機關：</TD>
		<TD class=whitetablebg >
			<SELECT id=send_cl name=send_cl class="<%=Lock.TryGet("QLock")%>"><%=html_send_cl%></SELECT>
		</TD>
	</TR>
	<TR>
		<TD class=lightbluetable align=right>發文代碼：</TD>
		<TD class=whitetablebg colspan=3>結構分類：
			<input type="text" name="rs_type" id="rs_type">
			<input type="text" name="rs_class_name" id="rs_class_name">
			<input type="text" name="rs_code_name" id="rs_code_name">
			<input type="text" name="act_code_name" id="act_code_name">
            <select name="rs_class" id="rs_class" class="<%=Lock.TryGet("QLock")%>"></select>
			案性：
			<!--一案多件之子本所編號修改入檔用 -->
			<input type=text id="hrs_class" name="hrs_class">
			<input type=text id="hrs_code" name="hrs_code">
			<input type=text id="hact_code" name="hact_code">
			<input type=text id="hmarkb" name="hmarkb">
			<span id=span_rs_code>
                <select name="rs_code" id="rs_code" class="<%=Lock.TryGet("QLock")%>"></select>
			</span><br>
			處理事項：
			<input type="text" id="act_sqlno" name="act_sqlno">
			<select name="act_code" id="act_code" class="<%=Lock.TryGet("QLock")%>"></select>
		</TD>
		<TD class=lightbluetable align=right>本次狀態：</TD>
		<TD class=whitetablebg><input type="text" id="ncase_stat" name="ncase_stat">
			<input type="text" id="ncase_statnm" name="ncase_statnm" size="10" class=sedit readonly>
		</TD>
    </TR>
    <TR>
		<TD class=lightbluetable align=right>發文內容：</TD>
		<TD class=whitetablebg colspan=5><input type="text" id="rs_detail" name="rs_detail" size=60 class="<%=Lock.TryGet("QLock")%>"></TD>
	</TR>
	<TR>
		<TD class=lightbluetable align=right>附件：</TD>
		<TD class=whitetablebg colspan=5><input type="text" id="doc_detail" name="doc_detail" size=60 maxlength=60 class="<%=Lock.TryGet("QLock")%>"></TD>
	</TR>
</table>
<input type="text" id=arnum name=arnum value=0><!--支出筆數-->
<TABLE id=tabar border=0 class="bluetable" cellspacing=1 cellpadding=2 width="100%">
    <thead>
	<TR>
		<TD class=whitetablebg colspan=8>對應客收交辦：
		</TD>
	</TR>
	<TR align=center class=lightbluetable>
		<TD></TD><TD>交辦單號</TD><TD>委辦案性</TD><TD>規費</TD><TD title="本次以外已支出之規費">已支出<br>規費</TD><TD>已支出<br>次數</TD><TD>請款註記</TD><TD>出名代理人</TD>
	</TR>
    </thead>
    <tbody></tbody>
    <script type="text/html" id="cr_ar_template"><!--對應客收交辦樣板-->
	    <tr id=tr_ar_##>
		    <td class=whitetablebg align=center>
	            ##.
		    </td>
		    <td class="whitetablebg" align=center>
                <input type=text size=10 maxlength=10 id=case_no_## name=case_no_## readonly class=sedit onclick="brta34form.CaseNoClick('##')" style="cursor:pointer;color:darkblue" onmouseover="this.style.color='red'" onmouseout="this.style.color='darkblue'">
	            <input type='hidden' id=rs_type_## name=rs_type_##>
	            <input type='hidden' id=arcase_type_## name=arcase_type_##>
	            <input type='hidden' id=in_scode_## name=in_scode_##>
	            <input type='hidden' id=in_no_## name=in_no_##>
	            <input type='hidden' id=arcase_class_## name=arcase_class_##>
	            <input type='hidden' id=arcase_## name=arcase_##>
	            <input type='hidden' id=linkpath_## name=linkpath_##>
	            <input type='hidden' id=rs_class_## name=rs_class_##>
		    </td>
		    <td class=whitetablebg align=center>
	            <input type=text size=16 maxlength=16 style='text-align:center;width:80px' readonly class=sedit id=arcasenm_## name=arcasenm_##>
		    </td>
		    <td class=whitetablebg align=center>
	            <input type=text size=6 maxlength=6 style='text-align:center;' readonly class=sedit id=fees_## name=fees_##>
	        </td>
		    <td class=whitetablebg align=center>
	            <input type=text size=6 maxlength=6 style='text-align:center;' readonly class=sedit id=gs_fees_## name=gs_fees_##>
	        </td>
		    <td class=whitetablebg align=center>
	            <input type='text' id=service_## name=service_##>
	            <input type=text size=2 maxlength=2 style='text-align:center;' readonly class=sedit id=gs_curr_## name=gs_curr_##>
	        </td>
		    <td class=whitetablebg align=center>
	            <input type=text size=12 maxlength=16 style='text-align:center;' readonly class=sedit id=ar_marknm_## name=ar_marknm_##>
		    </td>
		    <td class=whitetablebg align=center>
	            <input type='text' id=case_agt_no_## name=case_agt_no_##>
	            <input type=text size=16 maxlength=16 style='text-align:center;' readonly class=sedit id=agt_nonm_## name=agt_nonm_##>
		    </td>
	    </tr>
    </script>
</table>

<script language="javascript" type="text/javascript">
    var brta34form = {};

    brta34form.init = function () {
    }

    brta34form.bind = function (jData,jCase) {
        $("#rs_no").val(jData.rs_no);
        $("#cgrs").val(jData.cgrs).triggerHandler("change");
        $("#step_date").val(jData.step_date);
        $("#gov_date").val(jData.gov_date);
        $("#receive_way option[value='" + jData.receive_way + "']").prop("selected", true);
        $("#send_cl option[value='" + jData.send_cl + "']").prop("selected", true);
        $("#rs_type").val(jData.rs_type).triggerHandler("change");
        $("#rs_class_name").val(jData.rs_class_name);
        $("#rs_code_name").val(jData.rs_code_name);
        $("#rs_class option[value='" + jData.rs_class + "']").prop("selected", true);
        $("#rs_class").triggerHandler("change");
        $("#hrs_class").val(jData.rs_class);
        $("#hrs_code").val(jData.rs_code);
        $("#hact_code").val(jData.act_code);
        $("#hmarkb").val(jData.markb);
        $("#rs_code option[value='" + jData.rs_code + "']").prop("selected", true);
        $("#rs_code").triggerHandler("change");
        $("#act_sqlno").val(jData.act_sqlno);
        if ((jData.act_code || "") == "") {
            $("#act_code option[value='_']").prop("selected", true);
        } else {
            $("#act_code option[value='" + jData.act_code + "']").prop("selected", true);
        }
        $("#act_code").triggerHandler("change");
        if (jData.rs_detail != undefined) $("#rs_detail").val(jData.rs_detail);
        $("#doc_detail").val(jData.doc_detail);

        brta34form.append_ar(jCase);//對應客收交辦
    }

    brta34form.append_ar = function (jData) {
        $.each(jData, function (i, item) {
            brta34form.add_ar();//增加一筆交辦單號
            var nRow = CInt($("#arnum").val());

            $("#case_no_" + nRow).val(item.case_no);
            $("#rs_type_" + nRow).val(item.arcase_type);
            $("#gs_fees_" + nRow).val(item.gs_fees);
            $("#arcasenm_" + nRow).val(item.arcasenm);
            $("#fees_" + nRow).val(item.a_fees);
            $("#service_" + nRow).val(item.a_service);
            $("#gs_curr_" + nRow).val(item.gs_curr);
            $("#ar_marknm_" + nRow).val(item.ar_marknm);
            $("#case_agt_no_" + nRow).val(item.agt_no);
            $("#agt_nonm_" + nRow).val(item.receipt + "_" + item.agt_name);
            $("#arcase_type_" + nRow).val(item.arcase_type);
            $("#in_scode_" + nRow).val(item.in_scode);
            $("#in_no_" + nRow).val(item.in_no);
            $("#arcase_class_" + nRow).val(item.arcase_class);
            $("#arcase_" + nRow).val(item.arcase);
            $("#linkpath_" + nRow).val(item.case11aspx);
            $("#rs_class_" + nRow).val(item.rs_class);
        });
    }

    $("#cgrs").change(function () {
        $("#scgrs").val("本發");
    });

    //依rs_type帶結構分類
    $("#rs_type").change(function () {
        $("#rs_class").getOption({//結構分類
            url: getRootPath() + "/ajax/json_rs_class.aspx",
            data: { rs_type: $("#rs_type").val(), cg:"G", rs: "S" },
            valueFormat: "{cust_code}",
            textFormat: "{code_name}",
            attrFormat: "vref_code='{ref_code}'"
        });
    });

    //依結構分類帶案性代碼
    $("#rs_class").change(function () {
        if ($(this).val() != "") {
            $("#rs_class_name").val($("#rs_class option:selected").text());
        }

        $("#rs_code").getOption({//案性代碼
            url: getRootPath() + "/ajax/json_rs_code.aspx",
            data: { cgrs: $("#cgrs").val(), rs_class: $("#rs_class").val(), rs_type: $("#rs_type").val(), submittask: $("#submittask").val() || "" },
            valueFormat: "{rs_code}",
            textFormat: "{rs_detail}",
            attrFormat: "vrs_class='{rs_class}' vfees='{fees}' vmark='{mark}' vrs_agtno='{rsagtno}' vrs_agtnm='{receipt}_{rsagtnm}'"
        });
    });

    //依案性帶處理事項
    $("#rs_code").change(function () {
        $("#rs_detail,#rs_code_name,#hmarkb,#rs_agt_no,#rs_agt_nonm").val("");
        if ($(this).val() != "") {
            $("#rs_detail,#rs_code_name").val($("#rs_code option:selected").text());
            $("#hmarkb").val($('option:selected', this).attr('vmark'));
            $("#rs_agt_no").val($('option:selected', this).attr('vrs_agtno'));
            $("#rs_agt_nonm").val($('option:selected', this).attr('vrs_agtnm'));
        }

        $("#act_code").getOption({//處理事項
            url: getRootPath() + "/ajax/json_act_code.aspx",
            data: { cgrs: $("#cgrs").val(), rs_class: $("#rs_class").val(), rs_code: $("#rs_code").val() },
            valueFormat: "{act_code}",
            textFormat: "{act_code_name}",
            attrFormat: "spe_ctrl='{spe_ctrl}'"
        });
        $("#ncase_statnm").val("");
        $("#act_code option[value='_']").prop("selected", true);
        $("#act_code").triggerHandler("change");

        //註冊費繳納期數與發文案性關聯性檢查
        if ($("#prgid1").val() != "brta81") {
            switch ($("#rs_code").val()) {
                case 'FF1':
                    if($("#opay_times").val()!=""&&$("#opay_times").val()!="1"){
                        var ans=confirm("註冊費已繳期數與發文案性不符, 是否將註冊費已繳期數更正為『 第一期 』?");
                        if(ans==false){
                            $("#rs_code").focus();
                            break;
                        }
                    }
                    $("#pay_times,#hpay_times").val("1");
                    $("#pay_date").val($("#step_date").val());
                    break;
                case 'FF2':
                    if($("#opay_times").val()!="1"&&$("#opay_times").val()!="2"){
                        var ans=confirm("註冊費已繳期數與發文案性不符, 是否將註冊費已繳期數更正為『 第二期 』?");
                        if(ans==false){
                            $("#rs_code").focus();
                            break;
                        }
                    }
                    $("#pay_times,#hpay_times").val("2");
                    $("#pay_date").val($("#step_date").val());
                    break;
                case 'FF3':
                    if($("#opay_times").val()!="1"&&$("#opay_times").val()!="2"){
                        var ans=confirm("註冊費已繳期數與發文案性不符, 是否將註冊費已繳期數更正為『 第二期 』?");
                        if(ans==false){
                            $("#rs_code").focus();
                            break;
                        }
                    }
                    $("#pay_times,#hpay_times").val("2");
                    $("#pay_date").val($("#step_date").val());
                    break;
                case 'FF0':
                    if($("#opay_times").val()!=""&&$("#opay_times").val()!="A"){
                        var ans=confirm("註冊費已繳期數與發文案性不符, 是否將註冊費已繳期數更正為『 全期 』?");
                        if(ans==false){
                            $("#rs_code").focus();
                            break;
                        }
                    }
                    $("#pay_times,#hpay_times").val("A");
                    $("#pay_date").val($("#step_date").val());
                    break;
                default:
                    $("#pay_times,#hpay_times").val($("#opay_times").val());
                    $("#pay_date").val($("#opay_date").val());
                    break;
            }
        }
    });

    //依處理事項帶本次狀態/管制
    $("#act_code").change(function () {
        $("#act_code_name").val("");
        if ($(this).val() != "") {
            $("#act_code_name").val($("#act_code option:selected").text());
        }

        $("#ncase_stat,#ncase_statnm").val("");
        $("#rs_detail").val($("#rs_code option:selected").text());
        if ($("#act_code option:selected").val() != "" && $("#act_code option:selected").val() != "_") {
            $("#rs_detail").val($("#rs_code option:selected").text() + $("#act_code option:selected").text());
        }

        //brta34form.getCtrl();//帶預設期限

        //取得案性設定
        $.ajax({
            type: "get",
            url: getRootPath() + "/ajax/json_act_sqlno.aspx?cgrs=" + $("#cgrs").val() + "&rs_class=" + $("#rs_class").val() + "&rs_code=" + $("#rs_code").val() + "&act_code=" + $("#act_code").val(),
            async: false,
            cache: false,
            success: function (json) {
                var jAct = $.parseJSON(json);
                $.each(jAct, function (i, item) {
                    $("#ncase_stat").val(item.case_stat);
                    $("#ncase_statnm").val(item.case_statnm);
                    $("#act_sqlno").val(item.ctrl_sqlno);
                })
            },
            error: function (xhr) {
                $("#dialog").html("<a href='" + this.url + "' target='_new'>案性設定載入失敗！<u>(點此顯示詳細訊息)</u></a><hr>" + xhr.responseText);
                $("#dialog").dialog({ title: '案性設定載入失敗！', modal: true, maxHeight: 500, width: "90%" });
            }
        });
    });

    //增加一筆交辦單號
    brta34form.add_ar = function () {
        var nRow = CInt($("#arnum").val()) + 1;
        //複製樣板
        var copyStr = $("#cr_ar_template").text() || "";
        copyStr = copyStr.replace(/##/g, nRow);
        $("#tabar tbody").append(copyStr);
        $("#arnum").val(nRow);
        $(".dateField", $('#tr_ar_' + nRow)).datepick();
    }

    //減少一筆交辦單號
    brta34form.del_ar = function () {
        var nRow = CInt($("#arnum").val());
        $('#tr_ar_' + nRow).remove();
        $("#arnum").val(Math.max(0, nRow - 1));
    }

    //發文對象
    $("#send_cl").change(function () {
        var oval=$(this).val();
        $("#send_cl1").val("");
        if(oval=="2"||oval=="B"||oval=="C") $("#send_cl1").val("1");
        if(oval=="3") $("#send_cl1").val("2");
    });

    //查詢交辦資料
    brta34form.CaseNoClick=function (pno) {
        var url=$("#linkpath_"+pno).val()+"&prgid=<%=prgid%>&submittask=show";
        window.showModalDialog(url, "", "dialogHeight: 540px; dialogWidth: 800px; center: Yes;resizable: No; status: No;scrollbars:yes");
    }

    $(".dateField").blur(function () {
        ChkDate($(this)[0]);
    });
</script>
