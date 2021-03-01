<%@ Control Language="C#" ClassName="brta21form" %>
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

        SQL = "select a.scode,b.sc_name,a.sort ";
        SQL += " from sysctrl.dbo.scode_roles a ";
        SQL += " inner join sysctrl.dbo.scode b on a.scode=b.scode ";
        SQL += " where a.dept = '" + Session["dept"] + "' and syscode = '" + Session["syscode"] + "' and prgid = 'brta21' ";
        SQL += " and roles = 'process' and branch = '" + Session["seBranch"] + "' ";
        SQL += " order by sort ";
        DataTable prDT = new DataTable();
        conn.DataTable(SQL, prDT);
        html_pr_scode = prDT.Option("{scode}", "{scode}_{sc_name}", "", false, "", "sort=01");
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
<input type="hidden" id="now_grade" name="now_grade">
<input type="hidden" id="now_arcase" name="now_arcase">
<input type="hidden" id="now_stat" name="now_stat">

<TABLE id=tabbr style="display:" border=0 class="bluetable"  cellspacing=1 cellpadding=2 width="100%">
	<%if prgid="brta24" then%>
	<TR class="brta24"><!--官收確認-->
		<input type=hidden id="hdomark" name="hdomark" value="X">
		<%if new_seq<>"" then%>
		    <TD class=lightbluetable align=right nowrap>作業選項：</td>
		    <td class=whitetablebg colspan=5>
			    <input type=radio name=domark id=domarkA value="A" onclick="vbscript:domark_onclick1 me.value">需立子案
			    <input type=button class="c1button" name="btnnewseq" id="btnnewseq" value="子案立案">
			    <input type=radio name=domark id=domarkB value="B" onclick="vbscript:domark_onclick1 me.value">已立案
			    <input type=radio name=domark id=domarkX value="X" onclick="vbscript:domark_onclick1 me.value">本案收文
		    </TD>
		    <TD align=right  class=whitetablebg>
			    <input type=button name="getmgdmt" id="getmgdmt" class="cbutton" value="核對總收發主檔檢核資料" onclick="vbscript:btnmgdmt_onclick1 'nseq'">
		    </TD>
		<%else%>
		    <TD align=right  class=whitetablebg colspan=7>
			    <input type=button name="getmgdmt" id="getmgdmt" class="cbutton" value="核對總收發主檔檢核資料" onclick="vbscript:btnmgdmt_onclick1 ''">
		    </TD>
		<%end if%>
	</TR>
	<%end if%>
	<TR>
		<TD class=lightbluetable align=right nowrap>本所編號：</TD>
		<TD class=whitetablebg>
			<input type="hidden" id="keyseq" name="keyseq" value="N">
			<input type="hidden" id="oldseq" name="oldseq" value="<%=seq%>">
			<input type="hidden" id="oldseq1" name="oldseq1" value="<%=seq1%>">
			<input type="hidden" id="s_mark" name="s_mark" value="<%=s_mark%>">
			<input type="hidden" id="grseq" name="grseq" value="<%=seq%>"><!--官收案號for官收立子案之原案號-->
			<input type="hidden" id="grseq1" name="grseq1" value="<%=seq1%>"><!--官收案號for官收立子案之原案號-->
			<input type="text" id="seq" name="seq" <%=Qclass1%> size=6 maxlength=6 value="<%=seq%>">-
			<input type="text" id="seq1" name="seq1" <%=Qclass1%> size=1 maxlength=1 value="<%=seq1%>">
			<input type=button class="cbutton" id="btnseq" name="btnseq" value ="確定">
		</td>
		<TD class=whitetablebg>
			<input type=button class="cbutton" id="btnQuery" name="btnQuery" value ="查詢本所編號" style="width:120">
			<input type=button class="cbutton" id="btncase" name="btncase"  value ="案件主檔查詢" style="width:120">
		</TD>
		<TD class=lightbluetable align=right nowrap>客戶卷號：</TD>
		<TD class=whitetablebg><input type="text" value="<%=cust_prod%>" id="cust_prod" name="cust_prod" class="sedit" readonly size=25></TD>
		<TD class=lightbluetable align=right nowrap>立案日期：</TD>
		<TD class=whitetablebg>
		<input type="text" value="<%=in_date%>" id="in_date" name="in_date" class="sedit" readonly size=10>
		&nbsp;&nbsp;進度：		
		<input type="text" value="<%=step_grade%>" id="step_grade" name="step_grade" size=5 class="sedit" readonly>
		</TD>
	</TR>
	<TR>
		<TD class=lightbluetable align=right>案件名稱：</TD>
		<TD class=whitetablebg colspan=4>
			<input type="text" value="<%=appl_name%>" id="appl_name" name="appl_name" class="sedit" readonly size=50>
		</TD>
		<TD class=lightbluetable align=right>立案案性：</TD>
		<TD class=whitetablebg><input type="text" value="<%=arcase%>" id="arcase" name="arcase" class="sedit" readonly size=25></TD>
	</TR>
	<TR>
		<TD class=lightbluetable align=right>客戶名稱：</TD>
		<TD class=whitetablebg colspan=4>
			<input type="hidden" value="<%=att_sql%>" id="att_sql" name="att_sql">
			<input type="text" value="<%=cust_area%>" id="cust_area" name="cust_area" class="sedit" readonly size=1>-
			<input type="text" value="<%=cust_seq%>" id="cust_seq" name="cust_seq" size=6 class="sedit" readonly>
			<input type="text" value="<%=cust_name%>" id="cust_name" name="cust_name" class="sedit" size=40 readonly>
		</TD>
		<TD class=lightbluetable align=right>類別：</TD>
		<TD class=whitetablebg>(共<input type="text" value="<%=class_count%>" id="class_count" name="class_count" class="sedit" readonly size=2>類) 
		                         <input type="text" value="<%=class1%>" id="class1" name="class1" class="sedit" readonly size=13></TD>
	</TR>
	<TR>
		<TD class=lightbluetable align=right>申請人：</TD>
		<TD class=whitetablebg colspan=4>
			<input type="hidden" value="<%=apcust_no%>" id="apcust_no" name="apcust_no" class="sedit" readonly size=11>
			<input type="hidden" value="<%=ap_cname%>" id="ap_cname" name="ap_cname" class="sedit" size=40 readonly>
			<input type="text" value="<%=dmtap_cname%>" id="dmtap_cname" name="dmtap_cname" class="sedit" size=60 readonly>
		</TD>	
		<TD class=lightbluetable align=right rowspan=2>案件狀態：</TD>	
		<TD class=whitetablebg><input type="text" value="<%=now_arcasenm%>" id="now_arcasenm" name="now_arcasenm" size=20 class="sedit" readonly></TD>
		</TR>
	<TR>
		<TD class=lightbluetable align=right>出名代理：</TD>
		<TD class=whitetablebg ><input type="text" value="<%=agt_no%>" id="agt_no" name="agt_no" size=8 class="sedit" readonly></TD>
		<TD class=lightbluetable align=right>營洽：</TD>
		<TD class=whitetablebg colspan=2><input type="text" value="<%=scode%>" id="scode" name="scode" size=12 class="sedit" readonly></TD>	    
		<TD class=whitetablebg><input type="text" value="<%=case_stat%>" id="case_stat" name="case_stat" size=20 class="sedit" readonly></TD>
		</TR>
	<TR>
		<TD class=lightbluetable align=right>申請日期：</TD>
		<TD class=whitetablebg>
            <input type="text" value="<%=apply_date%>" id="apply_date" name="apply_date" size=10 maxlength=10 class="dateField" <%if prgid<>"brta21" and prgid<>"brta24" then%>class="sedit" readonly <%end if%><%=Qclass%>>
		</TD>
		<TD class=lightbluetable align=right>申請號碼：</TD>
		<TD class=whitetablebg colspan=2><input type="text" value="<%=apply_no%>" id="apply_no" name="apply_no" size=15 maxlength=20 <%if prgid<>"brta21" and prgid<>"brta24" then%>class="sedit" readonly<%else%> onblur="vbscript:applyno_onblur"<%end if%><%=Qclass%>></TD>
		<TD class=lightbluetable align=right>相關案號：</TD>
		<TD class=whitetablebg>
			<input type="text" value="<%=ref_no1%>" id="ref_no1" name="ref_no1" size=5 class="sedit" readonly style="cursor:hand" onclick=refnoclick()>-
			<input type="text" value="<%=ref_no11%>" id="ref_no11" name="ref_no11" size=1 class="sedit" readonly style="cursor:hand" onclick=refnoclick()>
		</TD>
	</TR>
	<TR>
		<TD class=lightbluetable align=right>註冊日期：</TD>
		<TD class=whitetablebg>
            <input type="text" value="<%=issue_date%>" id="issue_date" name="issue_date" size=10 maxlength=10 class="dateField" <%if prgid<>"brta21" and prgid<>"brta24" then%>class="sedit" readonly <%end if%><%=Qclass%>>
		</TD>
		<TD class=lightbluetable align=right>註冊號碼：</TD>
		<TD class=whitetablebg colspan=2><input type="text" value="<%=issue_no%>" id="issue_no" name="issue_no" size=15 maxlength=20 <%if prgid<>"brta21" and prgid<>"brta24" then%>class="sedit" readonly<%else%> onblur="vbscript:issueno_onblur" <%end if%><%=Qclass%>></TD>
		<TD class=lightbluetable align=right>母案案號：</TD>
		<TD class=whitetablebg>
			<input type="text" value="<%=mseq%>" id="mseq" name="mseq" size=5 class="sedit" readonly style="cursor:hand" onclick=MSeqclick()>-
			<input type="text" value="<%=mseq1%>" id="mseq1" name="mseq1" size=1 class="sedit" readonly style="cursor:hand" onclick=MSeqclick()>
		</TD>
	</TR>
	<TR>
		<TD class=lightbluetable align=right>公告日期：</TD>
		<TD class=whitetablebg>
            <input type="text" value="<%=open_date%>" id="open_date" name="open_date" size=10 maxlength=10 class="dateField" <%if prgid<>"brta21" and prgid<>"brta24" then%>class="sedit" readonly <%end if%><%=Qclass%>>
		</TD>		
		<TD class=lightbluetable align=right>核駁號碼：</TD>
		<TD class=whitetablebg colspan=2><input type="text" value="<%=rej_no%>" id="rej_no" name="rej_no" size=15 maxlength=20 <%if prgid<>"brta21" and prgid<>"brta24" then%>class="sedit" readonly<%else%> onblur="vbscript:rejno_onblur"  <%end if%><%=Qclass%>></TD>
		<TD class=lightbluetable align=right>結案日期：</TD>
		<TD class=whitetablebg><input type="text" value="<%=end_date%>" id="end_date" name="end_date" size=10 class="sedit" readonly>-
			<input type="text" value="<%=end_code%>" id="end_code" name="end_code" size=1 class="sedit" readonly>
			<input type="hidden" value="<%=end_name%>" id="end_name" name="end_name" >
			原因：<input type="text" value="<%=end_remark%>" id="end_remark" name="end_remark" size=20 class="sedit" readonly>
		</TD>
		</TR>
	<TR>
		<TD class=lightbluetable align=right>專用期限：</TD>
		<TD class=whitetablebg colspan=2 nowrap>
            <input type="text" value="<%=term1%>" id="term1" name="term1" size=10 maxlength=10 class="dateField" <%if prgid<>"brta21" and prgid<>"brta24" then%>class="sedit" readonly <%end if%><%=Qclass%>>
			~
			<input type="text" value="<%=term2%>" id="term2" name="term2" size=10 maxlength=10 class="dateField" <%if prgid<>"brta21" and prgid<>"brta24" then%>class="sedit" readonly <%end if%><%=Qclass%>>
		</TD>
		<TD class=lightbluetable align=right>延展次數：</TD>
		<TD class=whitetablebg><input type="text" value="<%=renewal%>" id="renewal" name="renewal" size=2 maxlength=2 <%if prgid<>"brta21" and prgid<>"brta24" then%>class="sedit" readonly <%end if%>></TD>
		<TD class=lightbluetable align=right>註冊費已繳：</TD>
		<TD class=whitetablebg>
			<input type="hidden" id="opay_times" name="opay_times" value="<%=pay_times%>">
			<input type="hidden" id="hpay_times" name="hpay_times" value="<%=pay_times%>">
	   		<Select NAME="pay_times" id="pay_times" disabled=true>
				<%SQL="SELECT cust_code, code_name FROM cust_code where code_type = '"&ucase(session("dept"))&"PAY_TIMES' ORDER BY sortfld"
				call ShowSelect3(conn,SQL,false,pay_times)
				%>
			</SELECT>
			<input type="hidden" value="<%=pay_date%>" id="opay_date" name="opay_date" size=10 maxlength=10 class="sedit" readonly>
			<input type="text" value="<%=pay_date%>" id="pay_date" name="pay_date" size=10 maxlength=10 class="sedit" readonly>
		</TD>
	</TR>
	<tr>
		    <td class="lightbluetable"  align="right">轉案註記：</td>
			<td class="whitetablebg" >
			    <input type="radio" id="tran_flagA" name="tran_flag" value="A" disabled>轉出
			    <input type="radio" id="tran_flagB" name="tran_flag" value="B" disabled>轉入
			</td>
			<td class="lightbluetable"  align="right">轉案單位案件編號：</td>
			<td class="whitetablebg" colspan=2>
					<input type="text" id="tran_seq_branch" name="tran_seq_branch" size="1" disabled value="<%=tran_seq_branch%>">
					<input type="text" id="tran_seq" name="tran_seq" size=5 readonly class="sedit" value="<%=tran_seq%>">
					<input type="text" id="tran_seq1" name="tran_seq1" size="3" readonly class="sedit" value="<%=tran_seq1%>">
					<font style="cursor: hand;background-color:lightbluetable3" title="進度查詢" onmouseover="vbs:me.style.color='red'" onmouseout="vbs:me.style.color='black'" onclick="vbscript:QstepClick"><img src="../images/annex.gif">
			</td>
			<td class="lightbluetable"  align="right">轉案說明：</td>
			<td class="whitetablebg" >
				<input type="text" id="tran_remark" name="tran_remark" size="20" readonly class="sedit" value="<%=tran_remark%>">
			</td>
		</tr>
</table>


<script language="javascript" type="text/javascript">
    var brta21form = {};

    brta21form.init = function () {
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
            data: { cgrs: "CR", rs_type: $("#rs_type").val() },
            valueFormat: "{rs_code}",
            textFormat: "{rs_detail}",
            attrFormat: "vrs_class='{rs_class}'"
        });
    });

    //依案性帶處理事項
    $("#rs_code").change(function () {
        $("#act_code").getOption({//處理事項
            url: getRootPath() + "/ajax/json_act_code.aspx",
            data: { bcgrs: "CR", rs_class: $("#rs_class").val(), rs_code: $("#rs_code").val() },
            valueFormat: "{act_code}",
            textFormat: "{act_code_name}",
            attrFormat: "spe_ctrl='{spe_ctrl}'"
        });
        brta21form.setSendWay();
    });

    //20200701 增加顯示發文方式
    brta21form.setSendWay = function () {
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
    brta21form.add_sub = function () {
        var nRow = CInt($("#tot_num").val()) + 1;
        //複製樣板
        var copyStr = $("#cr_ar1_template").text() || "";
        copyStr = copyStr.replace(/##/g, nRow);
        $("#tabar1 tbody").append(copyStr);
        $("#tot_num").val(nRow);
        $(".dateField", $('#tr_cr_' + nRow)).datepick();
    }

    //一案多件時取得子案本所編號
    brta21form.getdseq = function () {
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
        brta21form.add_sub();
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
            brta21form.add_sub();
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
    brta21form.getdseq1 = function () {
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
            brta21form.add_sub();
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
    brta21form.getCtrl = function () {
        if(jMain.case_main[0].cust_date!=""){
            //新增客戶期限
            ctrl_form.add_ctrl();
            $("#ctrl_type_"+$("#ctrlnum").val()).val("A2");
            $("#ctrl_date_"+$("#ctrlnum").val()).val(dateReviver(jMain.case_main[0].cust_date,'yyyy/M/d'));
        }
        if(jMain.case_main[0].pr_date!=""){
            //新增承辦期限
            ctrl_form.add_ctrl();
            $("#ctrl_type_"+$("#ctrlnum").val()).val("B2");
            $("#ctrl_date_"+$("#ctrlnum").val()).val(dateReviver(jMain.case_main[0].pr_date,'yyyy/M/d'));
        }
        //2010/10/6修改為結案註記有勾選結案才顯示
        if($("#seqend_flag").val()=="Y"){
            //新增結案完成期限
            ctrl_form.add_ctrl();
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
                        ctrl_form.add_ctrl();
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
    brta21form.end_stat = function () {
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
