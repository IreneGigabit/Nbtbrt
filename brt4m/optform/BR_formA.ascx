<%@ Control Language="C#" ClassName="opt_br_formA" %>

<script runat="server">
    protected string prgid = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string SQL = "";
    protected string branch = "";
    protected string opt_sqlno = "";
    protected string submitTask = "";

    protected string html_branch = "", html_agt_no="", tfy_send_way = "", tfy_receipt_title = "";

    private void Page_Load(System.Object sender, System.EventArgs e) {
        branch = Request["branch"] ?? "";
        opt_sqlno = Request["opt_sqlno"] ?? "";
        submitTask = Request["submitTask"] ?? "";

        using (DBHelper conn = new DBHelper(Conn.btbrt).Debug(false)) {
            html_branch = Util.Option(conn, "SELECT branch,branchname FROM sysctrl.dbo.branch_code WHERE class='branch'", "{branch}", "{branch}_{branchname}");
        }
        html_agt_no = Sys.getAgent().Option("{agt_no}", "{strcomp_name}{agt_name}");
        tfy_send_way = Sys.getCustCode("GSEND_WAY", "", "").Option("{cust_code}", "{code_name}");
        tfy_receipt_title = Sys.getCustCode("rec_titleT", "", "").Option("{cust_code}", "{code_name}");

        this.DataBind();
    }
</script>

<%=Sys.GetAscxPath(this)%>
<input type="hidden" id="apply_no" name="apply_no">
<input type="hidden" id="apply_date" name="apply_date">
<input type="hidden" id="issue_no" name="issue_no">
<input type="hidden" id="issue_date" name="issue_date">
<input type="hidden" id="rej_no" name="rej_no">
<input type="hidden" id="open_date" name="open_date">
<input type="hidden" id="dmt_term1" name="dmt_term1">
<input type="hidden" id="dmt_term2" name="dmt_term2">
<input type="hidden" id="apsqlno" name="apsqlno">
<input type="hidden" id="cust_name" name="cust_name">
<input type="hidden" id="ap_ename" name="ap_ename">
<input type="hidden" id="br_apnum" name="br_apnum" value=0><!--進度筆數-->
<table id=br_tab border="0" class="bluetable" cellspacing="1" cellpadding="2" width="100%">
	<Tr>
		<TD align=center colspan=6 class=lightbluetable1><font color="white">工&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;作&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;資&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;料</font></TD>
	</TR>
	<tr id="tr_Popt_show1" style="display:none">
		<td class="lightbluetable" valign="top"  align="right"><strong>案件編號：</strong></td>
		<td class="whitetablebg" colspan="7" valign="top">
			<input type="text" size="11" id="opt_no" name="opt_no" class="QLock" maxLength="10">
		</td>
	</tr>
	<TR>
		<td class="lightbluetable"  align="right">區所本所編號 :</td>
		<td class="whitetablebg"  align="left" colspan=5 >
			<Select id="Branch" name="Branch" class="QLock"><%#html_branch%></Select>
			<input type="text" id="Bseq" name="Bseq" SIZE=5 class="QLock" maxLength="5">-
			<input type="text" id="Bseq1" name="Bseq1" SIZE=1 class="QLock" maxLength="1">
			<input type="button" value="確定" class="cbutton QHide" id="btnBseq" name="btnBseq">
			<input type="hidden" id="keyBseq" name="keyBseq" class="QHide" value="N">
			<input type="hidden" id="oldBranch" name="oldBranch">
			<input type="hidden" id="oldBseq" name="oldBseq">
			<input type="hidden" id="oldBseq1" name="oldBseq1">
		</td>
	</TR>
	<TR>
		<td class="lightbluetable"  align="right">營洽 :</td>
		<td class="whitetablebg"  align="left">
			<input type="text" id="in_scode" name="in_scode" class="CLock" SIZE=5 >
			<input type="text" id="scode_name" name="scode_name" class="CLock" SIZE=10 >
		</td>
		<td class="lightbluetable"  align="right">出名代理人 :</td>
		<td class="whitetablebg"  align="left" colspan=3>
			<select id=agt_no name=agt_no class="CLock" SIZE=1 ><%#html_agt_no%></select>
		</td>
	</TR>
	<TR>
		<td class="lightbluetable"  align="right">案件名稱 :</td>
		<td class="whitetablebg"  align="left" colspan=5>
			<input type="text" id="appl_name" name="appl_name" class="CLock" SIZE=90 maxlength=100 >
		</td>
	</TR>
	<TR>
		<td class="lightbluetable"  align="right">申請人 :</td>
		<td class="whitetablebg"  align="left" colspan=5>
			<input type="text" id="ap_cname" name="ap_cname" class="CLock" SIZE=60 maxlength=60 >
		    <input type="hidden" id="cust_seq" name="cust_seq">
		    <input type="hidden" id="cust_area" name="cust_area">
		    <input type="hidden" id="att_sql" name="att_sql">
		</td>
	</TR>
	<TR>
		<td class="lightbluetable"  align="right">交辦案性 :</td>
		  <td class="whitetablebg"  align="left" colspan=5>
			 	案性：<select id=Arcase NAME=Arcase SIZE=1 class="QLock"></SELECT>
				<input type="hidden" id="arcase_type" name="arcase_type">
				<input type="hidden" id="arcase_class" name="arcase_class">
		</td>
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
		<td class="lightbluetable"  align="right" nowrap>法定期限 :</td>
		  <td class="whitetablebg"  align="left" colspan=5 >
			<input type="text" id="dfy_last_date" name="dfy_last_date" SIZE=10 class="RLock dateField" maxlength=10>
		</td>
	</TR>
	<Tr>
		<td class="lightbluetable" align="right">工作說明 :</td>
		<TD class=whitetablebg colspan=5>
			<textarea ROWS="6" style="width:90%" id=remark name="remark" class="RLock"></textarea>
		</TD>
	</tr>
</table>


<script language="javascript" type="text/javascript">
    var br_formA = {};
    br_formA.init = function () {
        //$("#Branch").getOption({//區所別
        //    url: getRootPath() + "/ajax/JsonGetSqlDataCnn.aspx",
        //    data: { sql: "select branch,branchname from branch_code where mark='Y' and branch<>'J' order by sort" },
        //    valueFormat: "{branch}",
        //    textFormat: "{branch}_{branchname}"
        //});
        //$("#agt_no").getOption({//出名代理人
        //    url: getRootPath() + "/ajax/LookupDataBranch.aspx",
        //    data: { type: "getagtdata", branch: "K" },
        //    valueFormat: "{agt_no}",
        //    textFormat: "{strcomp_name}{agt_name}"
        //});
        $("#Arcase").getOption({//交辦案性
            url: getRootPath() + "/ajax/LookupDataBranch.aspx",
            data: { type: "getarcasedata", branch: "K" },
            valueFormat: "{rs_code}",
            textFormat: "{rs_codenm}---{rs_detail}",
            attrFormat: "val1='{rs_type}' val2='{rs_class}'"
        });

        $("#Branch").val("<%#branch%>");

       if ("<%#submitTask%>" != "ADD") {
            br_formA.loadOpt();
            $("#btnBseq").click();
        } else {
            $("#Bseq1").val("_");
            $("#Arcase").val("FOC").trigger("change");
        }

        $("#tr_Popt_show1").hideFor($("#submittask").val()=="ADD");//新增分案時不顯示案件編號
        //$(".unlockADD").unlock($("#submittask").val()=="ADD");//新增分案解鎖
        //$(".showADD").showFor($("#submittask").val()=="ADD");//新增分案顯示
    }

    //載入爭救案件資料
    br_formA.loadOpt = function () {
        var jOpt = br_opt.opt[0];
        if (jOpt!=null) {
            $("#Branch,#oldBranch").val(jOpt.branch);
            $("#ctrl_date").val(dateReviver(jOpt.ctrl_date, "yyyy/M/d"));
            $("#opt_no").val(jOpt.opt_no);
            $("#Bseq,#oldBseq").val(jOpt.bseq);
            $("#Bseq1,#oldBseq1").val(jOpt.bseq1);
            $("#in_scode").val(jOpt.in_scode);
            $("#scode_name").val(jOpt.scode_name);
            $("#appl_name").val(jOpt.appl_name);
            $("#ap_cname").val(jOpt.ap_cname);
            $("#cust_seq").val(jOpt.cust_seq);
            $("#cust_area").val(jOpt.cust_area);
            $("#att_sql").val(jOpt.att_sql);
            $("#Arcase").val(jOpt.arcase).trigger("change");
            $("#dfy_last_date").val(dateReviver(jOpt.last_date, "yyyy/M/d"));
            $("#remark").val(jOpt.remark);
            $("#apply_no").val(jOpt.apply_no);
            $("#apply_date").val(dateReviver(jOpt.apply_date, "yyyy/M/d"));
            $("#issue_no").val(jOpt.issue_no);
            $("#issue_date").val(dateReviver(jOpt.issue_date, "yyyy/M/d"));
            $("#rej_no").val(jOpt.rej_no);
            $("#open_date").val(dateReviver(jOpt.open_date, "yyyy/M/d"));
            $("#dmt_term1").val(dateReviver(jOpt.dmt_term1, "yyyy/M/d"));
            $("#dmt_term2").val(dateReviver(jOpt.dmt_term2, "yyyy/M/d"));
            $("#apsqlno").val(jOpt.apsqlno);
            $("#ap_ename").val(jOpt.ap_ename);
            if($("#ctrl_date").val()==""){
                $("#dfy_last_date").blur();
            }

            //送件方式(DB有值以DB為準)
            //if (jOpt.send_way !== undefined && jOpt.send_way != "") $("#tfy_send_way").val(jOpt.send_way);
            //if (jOpt.receipt_type !== undefined && jOpt.receipt_type != "") $("#tfy_receipt_type").val(jOpt.receipt_type);
            //if (jOpt.receipt_title !== undefined && jOpt.receipt_title != "") $("#tfy_receipt_title").val(jOpt.receipt_title);
            //if (jOpt.rectitle_name !== undefined && jOpt.rectitle_name != "") $("#tfy_rectitle_name").val(jOpt.rectitle_name);
            $("#tfy_send_way").val(jOpt.send_way);
            $("#tfy_receipt_type").val(jOpt.receipt_type);
            $("#tfy_receipt_title").val(jOpt.receipt_title);
            $("#tfy_rectitle_name").val(jOpt.rectitle_name);
        }
    };

    //載入區所案件資料
    $("#btnBseq").click(function () { 
        br_formA.loadDmt(); 
    });
    br_formA.loadDmt = function () {
        var br_dmt = {};
        if ($("#Branch").val()==""){ alert("區所別未輸入!!!"); return false;}
        if ($("#Bseq").val()==""){ alert("區所編號未輸入!!!"); return false;}
        if ($("#Bseq1").val()==""){ alert("區所編號副碼未輸入!!!"); return false;}
        //取得區所案件資料
        $.ajax({
            type: "get",
            url: getRootPath() + "/ajax/_DmtData.aspx?branch=" + $("#Branch").val() + "&seq=" + $("#Bseq").val() + "&seq1=" + $("#Bseq1").val(),
            async: false,
            cache: false,
            success: function (json) {
                if ($("#chkTest").prop("checked")) toastr.info("<a href='" + this.url + "' target='_new'>DmtData Debug！<BR><b><u>(點此顯示詳細訊息)</u></b></a>");
                var JSONdata = $.parseJSON(json);
                if (JSONdata.dmt.length == 0) {
                    alert($("#Bseq").val()+"-"+$("#Bseq1").val()+"不存在於案件主檔內，請重新輸入!!!");
                    return false;
                }
                var jDmt = JSONdata.dmt[0];
                if (jDmt != null) {
                    $("#appl_name").val(jDmt.appl_name);
                    $("#cust_area").val(jDmt.cust_area);
                    $("#cust_seq").val(jDmt.cust_seq);
                    $("#cust_name").val(jDmt.custname);
                    $("#agt_no").val(jDmt.agt_no);
                    $("#scode_name").val(jDmt.scodename);
                    $("#in_scode").val(jDmt.scode);
                    $("#apply_date").val(dateReviver(jDmt.apply_date, "yyyy/M/d"));
                    $("#apply_no").val(jDmt.apply_no);
                    $("#issue_date").val(dateReviver(jDmt.issue_date, "yyyy/M/d"));
                    $("#issue_no").val(jDmt.issue_no);
                    $("#open_date").val(dateReviver(jDmt.open_date, "yyyy/M/d"));
                    $("#rej_no").val(jDmt.rej_no);
                    $("#dmt_term1").val(dateReviver(jDmt.term1, "yyyy/M/d"));
                    $("#dmt_term2").val(dateReviver(jDmt.term2, "yyyy/M/d"));
                    $("#apsqlno").val(jDmt.apsqlno);
                    $("#ap_cname").val(jDmt.ap_cname);
                    $("#ap_ename").val(jDmt.ap_ename);
                    $("#att_sql").val(jDmt.att_sql);
                    $("#br_apnum").val(JSONdata.dmt_ap.length);

		            $("#oldBranch").val($("#Branch").val());
		            $("#oldBseq").val($("#Bseq").val());
		            $("#oldBseq1").val($("#Bseq1").val());
                    $("#keyBseq").val("Y"); //有按確定給Y
                }

                var jAp = JSONdata.dmt_ap;
                $.each(jAp, function (i, item) {
                    var nRow = i + 1;
                    var trHTML = "";
                    trHTML += "<input type=hidden id='apsqlno_" + nRow + "' name='apsqlno_" + nRow + "' value='"+item.apsqlno+"'>";
                    trHTML += "<input type=hidden id='server_flag_" + nRow + "' name='server_flag_" + nRow + "' value='"+item.server_flag+"'>";
                    trHTML += "<input type=hidden id='apcust_no_" + nRow + "' name='apcust_no_" + nRow + "' value='"+item.apcust_no+"'>";
                    trHTML += "<input type=hidden id='ap_cname_" + nRow + "' name='ap_cname_" + nRow + "' value='"+item.ap_cname+"'>";
                    trHTML += "<input type=hidden id='ap_cname1_" + nRow + "' name='ap_cname1_" + nRow + "' value='"+item.ap_cname1+"'>";
                    trHTML += "<input type=hidden id='ap_cname2_" + nRow + "' name='ap_cname2_" + nRow + "' value='"+item.ap_cname2+"'>";
                    trHTML += "<input type=hidden id='ap_ename_" + nRow + "' name='ap_ename_" + nRow + "' value='"+item.ap_ename+"'>";
                    trHTML += "<input type=hidden id='ap_ename1_" + nRow + "' name='ap_ename1_" + nRow + "' value='"+item.ap_ename1+"'>";
                    trHTML += "<input type=hidden id='ap_ename2_" + nRow + "' name='ap_ename2_" + nRow + "' value='"+item.ap_ename2+"'>";
                    $("#reg").append(trHTML);
                });

                $("#btnBseq").prop("disabled", true);
            },
            error: function () { toastr.error("<a href='" + this.url + "' target='_new'>案件資料載入失敗！<BR><b><u>(點此顯示詳細訊息)</u></b></a>"); }
        });
    };

    //載入區所案件資料
    $("#Arcase").change(function () {
        br_formA.getArcaseData(this);
        br_formA.setSendWay();//依案性預設發文方式
    });
    br_formA.getArcaseData = function (obj) {
        $("#arcase_type").val($(":selected",obj).attr("val1"));
        $("#arcase_class").val($(":selected",obj).attr("val2"));
    };

    $("#BSeq").blur(function (e) {
        chkNum($(this).val(), "區所案件編號");
    });

    $("#dfy_last_date").blur(function (e) {
        if ($("#dfy_last_date").val() != "") {
            var Adate = (new Date($("#dfy_last_date").val())).addDays(-5);
            if (Adate < (new Date())){
                $("#ctrl_date").val($("#dfy_last_date").val());
            }else{
                $("#ctrl_date").val(Adate.format("yyyy/M/d"));
            }
        }
    });

    //20200701 增加顯示發文方式
    br_formA.setSendWay = function () {
        $("#tfy_send_way").getOption({//發文方式
            url: getRootPath() + "/ajax/json_sendway.aspx",
            data: { branch: "K", rs_code: $("#Arcase").val() },
            valueFormat: "{cust_code}",
            textFormat: "{code_name}"
        });
        $("#tfy_send_way option[value!='']").eq(0).prop("selected", true);

        br_formA.setReceiptType();
    };

    //發文方式修改時調整收據種類選項
    br_formA.setReceiptType = function () {
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
        br_formA.setReceiptTitle();
    };

    //收據種類時調整收據抬頭預設
    br_formA.setReceiptTitle = function () {
        //若是紙本收據抬頭預設空白
        if ($("#tfy_receipt_type").val() == "P") {
            $("#tfy_receipt_title").val("B");
        } else {
            $("#tfy_receipt_title").val("A");
        }
    };
</script>
