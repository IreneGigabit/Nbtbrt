<%@ Control Language="C#" ClassName="brta311form" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Data"%>

<script runat="server">
    //官發欄位畫面
    //父控制項傳入的參數
    public Dictionary<string, string> Lock = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    public Dictionary<string, string> Hide = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    public int HTProgRight = 0;

    protected string submitTask = "";
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//功能權限代碼
    protected string SQL = "";

    protected string html_send_cl="";
    protected string html_pr_scode="",html_send_sel = "",html_rfees_stat="";
    protected string opt_branch="";

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

        SQL = "select a.scode,b.sc_name,a.sort ";
        SQL += " from sysctrl.dbo.scode_roles a ";
        SQL += " inner join sysctrl.dbo.scode b on a.scode=b.scode ";
        SQL += " where a.dept = '" + Session["dept"] + "' and syscode = '" + Session["syscode"] + "' and prgid = 'brta21' ";
        SQL += " and roles = 'process' and branch = '" + Session["seBranch"] + "' ";
        SQL += " order by sort ";
        DataTable prDT = new DataTable();
        conn.DataTable(SQL, prDT);
        
        html_send_cl = Sys.getCustCode("SEND_CL", "", "cust_code").Option("{cust_code}", "{code_name}");
        html_send_sel = Sys.getCustCode("SEND_SEL", "", "cust_code").Option("{cust_code}", "{code_name}");
        html_pr_scode = prDT.Option("{scode}", "{scode}_{sc_name}", "", false, "", "sort=01");
        html_rfees_stat = Sys.getCustCode("fees_stat", "", "sql").Radio("rfees_stat", "{cust_code}", "{code_name}", "onclick=\"fees_stat_onclick()\"");

        opt_branch=Sys.GetSession("seBranch");
        
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
<TABLE id=tabbr border=0 class="bluetable" cellspacing=1 cellpadding=2 width="100%">
    	<TR>
		<TD align=center colspan=6 class=lightbluetable1><font color=white>發&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;文&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;資&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;料</font></TD>
	</TR>
	<TR>
		<TD class=lightbluetable align=right>進度序號：</TD>
		<TD class=whitetablebg>
			<input type="hidden" id="rs_no" name="rs_no">
			<input type="text" id="nstep_grade" name="nstep_grade" size=3 class=sedit readonly>
			<input type="hidden" id="cgrs" name="cgrs">
			<input type="text" id="scgrs" name="scgrs" size=4 class=sedit readonly>
		</TD>
		<TD class=lightbluetable align=right>發文日期：</TD>
		<TD class=whitetablebg><input type="text" id="step_date" name="step_date" class="dateField <%=Lock.TryGet("Qdisabled")%>"></TD>
		<TD class=lightbluetable align=right>總發文日期：</TD>
		<TD class=whitetablebg><input type="text" id="mp_date" name="mp_date" size="10" class="dateField <%=Lock.TryGet("Qdisabled")%>"></TD>
	</TR>
	<TR id=tr_send>	
		<TD class=lightbluetable align=right>發文對象：</TD>
		<TD class=whitetablebg >
			<SELECT id=send_cl name=send_cl class="<%=Lock.TryGet("Qdisabled")%>"><%=html_send_cl%></SELECT>
		</TD>
		<TD class=lightbluetable align=right>副本對象：</TD>
		<TD class=whitetablebg>
			<SELECT id=send_cl1 name=send_cl1 class="<%=Lock.TryGet("Qdisabled")%>"><%=html_send_cl%></SELECT>
		</TD>
		<TD class=lightbluetable align=right>官方號碼：</TD>
		<TD class=whitetablebg>
			<SELECT id=send_sel name=send_sel class="<%=Lock.TryGet("Qdisabled")%>"><%=html_send_sel%></SELECT>
		</TD>
	</TR>
	<TR>
		<TD class=lightbluetable align=right>發文代碼：</TD>
		<TD class=whitetablebg colspan=3>結構分類：
			<input type="hidden" name="rs_type" id="rs_type">
			<input type="hidden" name="rs_class_name" id="rs_class_name">
			<input type="hidden" name="rs_code_name" id="rs_code_name">
			<input type="hidden" name="act_code_name" id="act_code_name">
			<input type="hidden" name="case_change" id="case_change" value="N"><!--交辦異動註記，預設未異動-->
			<input type="hidden" name="case_arcase_class" id="case_arcase_class"><!--交辦結構分類-->
			<input type="hidden" name="case_arcase" id="case_arcase"><!--交辦結構分類-->
			<span id=span_rs_class>
                <select name="rs_class" id="rs_class" class="Lock"></select>
			</span>
			案性：
			<!--一案多件之子本所編號修改入檔用 -->
			<input type=hidden id="hrs_class" name="hrs_class" value="<%=rs_class%>">
			<input type=hidden id="hrs_code" name="hrs_code" value="<%=rs_code%>">
			<input type=hidden id="hact_code" name="hact_code" value="<%=act_code%>">
			<input type=hidden id="hmarkb" name="hmarkb" value="<%=markb%>">
			<span id=span_rs_code>
                <select name="rs_code" id="rs_code" onchange='rs_code_onchange1()' class="Lock"></select>
			</span><br>
			處理事項：
			<input type="hidden" id="act_sqlno" name="act_sqlno" value="<%=act_sqlno%>">
			<span id=span_act_code>
				<select name="act_code" id="act_code" class="Lock"></select>
			</span>		
		</TD>
		<TD class=lightbluetable align=right>本次狀態：</TD>
		<TD class=whitetablebg><input type="hidden" id="ncase_stat" name="ncase_stat" value="<%=ncase_stat%>">
			<input type="text" id="ncase_statnm" name="ncase_statnm" size="10" value="<%=ncase_statnm%>" class=sedit readonly></TD>
    </TR>
    <TR>
		<TD class=lightbluetable align=right>發文內容：</TD>
		<TD class=whitetablebg colspan=3><input type="text" id="rs_detail" name="rs_detail" size=60 <%=Qclass%> value="<%=rs_detail%>"></TD>
	    <TD class=lightbluetable align=right>發文出名代理：</TD>
		<TD class=whitetablebg ><input type=hidden id="rs_agt_no" name="rs_agt_no" value="<%=rs_agt_no%>">
		    <input type="text" id="rs_agt_nonm" name="rs_agt_nonm" size=15 value="<%=rs_agt_nonm%>" class=sedit readonly>
		</td>
	</TR>
	<TR id=tr_send_way>
		<TD class=lightbluetable align=right>發文方式：</TD>
		<TD class=whitetablebg colspan=5>
			<SELECT id="send_way" name="send_way" value="<%=send_way%>" class="<%=Lock.TryGet("Qdisabled")%>" >
			</select>
			<input type="hidden" id="spe_ctrl" name="spe_ctrl">	
			<input type="hidden" id="spe_ctrl_4" name="spe_ctrl_4">	
			<input type="hidden" id="old_send_way" name="old_send_way" value="<%=old_send_way%>">	
		</TD>
	</tr>
	<TR id=tr_case>	
		<TD class=lightbluetable align=right>承辦：</TD>
		<TD class=whitetablebg><SELECT id="pr_scode" name="pr_scode" class="<%=Lock.TryGet("Qdisabled")%>">
			<%=html_pr_scode%>
			</SELECT>
		</TD>
		<TD class=lightbluetable align=right>規費支出：</TD>
		<TD class=whitetablebg <%if (HTProgRight AND 128)=0 and (HTProgRight AND 256)=0 then%>colspan=3<%end if%>>
			<input type="text" id="fees" name="fees" size="6" <%=Qclass%> style='text-align:right;' value="<%=fees%>">
		</TD>
		<%if (HTProgRight AND 128)<>0 or (HTProgRight AND 256)<>0 then%>
		    <TD class=lightbluetable align=right>
		        <input type="hidden" id="fees_stat" name="fees_stat" value="<%=fees_stat%>">
		        收費管制：
		    </TD>
		    <TD class=whitetablebg>
			    <%=html_rfees_stat%>
		    </TD>
		<%end if%>
	</TR>
	<TR id=tr_rectitle>	
		<TD class=lightbluetable align=right>官發收據種類：</TD>
		<TD class=whitetablebg>
			<select id="receipt_type" name="receipt_type" class="<%=Lock.TryGet("Qdisabled")%>">
				<option value="" style="color:blue">請選擇</option>
				    <option value="P">紙本收據</option>
				    <option value="E">電子收據</option>
			</select>
		</TD>
		<TD class=lightbluetable align=right>收據抬頭：</TD>
		<TD class=whitetablebg colspan=3>
			<select id="receipt_title" name="receipt_title" <%if trim(prgid)="brta38" then response.write "disabled" else response.write Qdisabled end if%>>
				<option value="" style="color:blue">請選擇</option>
				    <option value="A">案件申請人</option>
				    <option value="B">空白</option>
				    <option value="C">案件申請人(代繳人)</option>
			</select>
			<input type="hidden" id="rectitle_name" name="rectitle_name" value="<%=rectitle_name%>">
		</TD>
	</TR>
	<TR id="show_optbranch" style="display:">
		<TD class=lightbluetable align=right><font color=darkblue>※發文單位：</font></TD>
		<TD class=whitetablebg colspan=5>
			<input type=radio id="opt_branch<%=opt_branch%>" name="opt_branch" value="<%=opt_branch%>">自行發文
			<input type=radio id="opt_branchL" name="opt_branch" value="L">轉法律所發文
		</TD>
	</tr>
</table>
<input type="hidden" id=arnum name=arnum value=0><!--支出筆數-->
<input type="hidden" id=oldarnum name=oldarnum value=0><!--支出筆數，修改時，刪除筆數要將case_dmt減回去-->
<TABLE id=tabar style="display:" border=0 class="bluetable" cellspacing=1 cellpadding=2 width="100%">
	<TR>
		<TD class=whitetablebg colspan=8>對應交辦收費：
			<input type=button value ="增加一筆" class="cbutton <%=Lock.TryGet("Qdisabled")%>" id=arAdd_button name=arAdd_button>
			<input type=button value ="減少一筆" class="cbutton <%=Qdisabled%"> id=arres_button name=arres_button>
		</TD>
		<TD class=whitetablebg align=left>
			合計: <input type="text" class="sedit" readonly id="tot_fees" name="tot_fees" value="0" maxlength=7 size=7>
		</TD>
	</TR>
	<TR align=center class=lightbluetable>
		<TD></TD><TD>交辦單號</TD><td>本次支出</td><TD>委辦案性</TD><TD>規費</TD><TD title="本次以外已支出之規費">已支出<br>規費</TD><TD>已支出<br>次數</TD><TD>請款註記</TD><TD>出名代理人</TD>
	</TR>
</table>
<input type="hidden" id=tot_num name=tot_num value=0><!--一案多件筆數-->
<span id="span_seq" style="display:none">
<TABLE id=tabar1 border=0 class="bluetable" cellspacing=1 cellpadding=2 width="100%">
    <thead>
		<TR>
			<TD class=whitetablebg colspan=7><span id="span_seqdesc">一案多件附屬本所編號：</span>
				<input type=button value ="增加一筆" class="cbutton <%=Lock.TryGet("Qdisabled")%>" id=dseqAdd_button name=dseqAdd_button onclick="dseqAdd_button_onclick('N')" >
			</TD>
		</TR>
		<TR align=center class=lightbluetable>
			<TD></TD><TD>本所編號</TD><td style="width:80px;">商標種類</TD><TD style="width:110px;">類別</TD>
			<TD>商標/案件名稱</TD><TD style="width:80px;"><span id="span_no">申請號</span></TD>
			<TD>刪除</TD>
		</TR>
    </thead>
    <tbody></tbody>
    <script type="text/html" id="cr_ar1_template"><!--一案多件樣板-->
	    <tr id=tr_cr_##>
		    <td class=whitetablebg align=center>
	            ##.
		    </td>
		    <td class="whitetablebg rs_code_FD" align=center>
		        <input type=text size=5 maxlength=5 id=dseq_## name=dseq_## onchange='btndseq_onchange(##)' class='FD_lock'>
		        -<input type=text size=1 maxlength=1 id=dseq1A_## name=dseq1A_## class='FD_lock' value='_' >
		        <input type=hidden id=hrs_no_## name=hrs_no_##>
		        &nbsp;<input type=button value ='確定' class='cbutton FD_lock' id='btndseq_ok_##' name='btndseq_ok_##' onclick='btndseq_ok_onclick("##")' title='本所編號確認'>
		        &nbsp;<input type=button value ='查詢' class='cbutton FD_lock' id='btndseqq1_##' name='btndseqq1_##' onclick='btndseqq1_onclick("##")' title='查詢本所編號'>
		        &nbsp;<input type=button value ='主檔' class='cbutton FD_lock' id='btndseqq2_##' name='btndseqq2_##' onclick='btndseqq2_onclick("##")' title='查詢案件主檔'>
		        <input type='hidden' id='keydseq_##' name='keydseq_##'>
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
		    <td class=whitetablebg align=center>
		        <input type=checkbox id=dseqdel_## name=dseqdel_## value='' onclick='dseqdel_oncheck("##")' <%if prgid="brt63" or prgid="brta38" then%> disabled <%end if%>>
		    </td>
	    </tr>
    </script>
</table>
</span>

<script language="javascript" type="text/javascript">
    var brta311form = {};

    brta311form.init = function () {
        $("input[name='opt_branch'][value='<%#opt_branch%>']").prop("checked",true);
    }

    //官發、客發 控制畫面
    $("#scgrs").change(function () {
        if($("#cgrs").val()=="GS"){
            $("#tr_send,#tr_case,#tabar").show();
            $("#scgrs").val("官發");
        }

        if($("#cgrs").val()=="CS"){
            $("#tr_send,#tr_case,#tabar").show();
            $("#scgrs").val("客發");
        }
    });


    //依rs_type帶結構分類
    $("#rs_type").change(function () {
        $("#rs_class").getOption({//結構分類
            url: getRootPath() + "/ajax/json_rs_class.aspx",
            data: { rs_type: $("#rs_type").val(), cg:"G", rs: "S" },
            valueFormat: "{cust_code}",
            textFormat: "{code_name}"
        });
    });

    //依結構分類帶案性代碼
    $("#rs_class").change(function () {
        if ($(this).val() != "") {
            $("#rs_class_name").val($("#rs_class option:selected").text());
        }

        $("#rs_code").getOption({//案性代碼
            url: getRootPath() + "/ajax/json_rs_code.aspx",
            data: { cgrs: "GS", rs_type: $("#rs_type").val(),submittask: $("#submittask").val()||"" },
            valueFormat: "{rs_code}",
            textFormat: "{rs_detail}",
            attrFormat: "vrs_class='{rs_class}' vfees='{fees}'"
        });

        $("#rs_code").triggerHandler("change");
    });

    //依案性帶處理事項
    $("#rs_code").change(function () {
        $("#rs_detail").val("");
        if ($(this).val() != "") {
            $("#rs_detail").val($("#rs_code option:selected").text());
        }
        $("#act_code").getOption({//處理事項
            url: getRootPath() + "/ajax/json_act_code.aspx",
            data: { bcgrs: "GS", cg:"G", rs:"S", rs_class: $("#rs_class").val(), rs_code: $("#rs_code").val() },
            valueFormat: "{act_code}",
            textFormat: "{act_code_name}",
            attrFormat: "spe_ctrl='{spe_ctrl}'"
        });
        $("#ncase_statnm").val("");
        $("#act_code").val("_");

        //規費收費標準
        if ($("#submittask") == "A" && $("#prgid1").val() != "brta81") {
            $("#fees").val($('option:selected', this).attr('vfees'));
        }

        //註冊費繳納期數與發文案性關聯性檢查
        if ($("#submittask") != "Q" && $("#prgid1").val() != "brta81") {
            switch (pvalue) {
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

        brta311form.setSendWay();
    });

    //20200701 增加顯示發文方式
    brta311form.setSendWay = function () {
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
    brta311form.add_sub = function (plock) {
        var nRow = CInt($("#tot_num").val()) + 1;
        //複製樣板
        var copyStr = $("#cr_ar1_template").text() || "";
        copyStr = copyStr.replace(/##/g, nRow);
        $("#tabar1 tbody").append(copyStr);
        $("#tot_num").val(nRow);
        $(".dateField", $('#tr_cr_' + nRow)).datepick();
        if (plock == "Y") {
            $('#tr_cr_' + nRow + ' .FD_lock').lock();
            $("#keydseq_" + nRow).val("Y");
        } else {
            $('#tr_cr_' + nRow + ' .FD_lock').lock();//***todo
            $("#keydseq_" + nRow).val("N");
        }
    }

    //一案多件時取得子案本所編號
    brta311form.getdseq = function () {
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
        brta311form.add_sub();
        var spl_num =1;
        $("#dseq_" + spl_num).val(jMain.case_main[0].seq);
        $("#dseq1A_" + spl_num).val(jMain.case_main[0].seq1);
        $("#s_mark_" + spl_num).val(jMain.case_main[0].s_marknm);
        $("#dclass_" + spl_num).val(jMain.case_main[0].class);
        $("#appl_name_" + spl_num).val(jMain.case_main[0].appl_name);
        if ($("#hrs_code").val() == "FC11" || $("#hrs_code").val() == "FC5" || $("#hrs_code").val() == "FC7" || $("#hrs_code").val() == "FCH") {
            $("#dref_no_" + spl_num).val(jMain.case_main[0].apply_no);
        } else if ($("#hrs_code").val() == "FC21" || $("#hrs_code").val() == "FC6" || $("#hrs_code").val() == "FC8" || $("#hrs_code").val() == "FCI") {
            $("#dref_no_" + spl_num).val(jMain.case_main[0].issue_no);
        }

        $.each(jMain.case_dmt1, function (i, item) {
            //產生一案多件子案案號
            brta311form.add_sub();
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
    brta311form.getdseq1 = function () {
        //案性為一案多件時, 要顯示 sub seq 的畫面
        $("#tabar1").show();
        if ($("#rs_code").val() == "FD1") {
            $("#span_no").html("申請號");
        } else if ($("#rs_code").val() == "FD2" || $("#rs_code").val() == "FD3") {
            $("#span_no").html("註冊號");
        }
        $("#span_seqdesc").html("此次分割案件資料：");

        $.each(jMain.dmt_temp1, function (i, item) {
            //產生分割子案案號
            brta311form.add_sub();
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
    brta311form.getCtrl = function () {
        if(jMain.case_main[0].cust_date!=""){
            //新增客戶期限
            brta212form.add_ctrl();
            $("#ctrl_type_"+$("#ctrlnum").val()).val("A2");
            $("#ctrl_date_"+$("#ctrlnum").val()).val(dateReviver(jMain.case_main[0].cust_date,'yyyy/M/d'));
        }
        if(jMain.case_main[0].pr_date!=""){
            //新增承辦期限
            brta212form.add_ctrl();
            $("#ctrl_type_"+$("#ctrlnum").val()).val("B2");
            $("#ctrl_date_"+$("#ctrlnum").val()).val(dateReviver(jMain.case_main[0].pr_date,'yyyy/M/d'));
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
    brta311form.end_stat = function () {
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
