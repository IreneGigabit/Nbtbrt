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
    protected string html_pr_scode="",html_send_sel = "",html_rfees_stat="",html_send_way="";
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

        html_send_cl = Sys.getCustCode("SEND_CL", "", "cust_code").Option("{cust_code}", "{code_name}");
        html_send_sel = Sys.getCustCode("SEND_SEL", "", "cust_code").Option("{cust_code}", "{code_name}");
        //html_pr_scode = Sys.getPrScode().Option("{scode}", "{scode}_{sc_name}", "", true, "", "sort=01");
        html_pr_scode = Sys.getPrScode().Option("{scode}", "{scode}_{sc_name}", "vsort='{sort}'",true);
        html_rfees_stat = Sys.getCustCode("fees_stat", "", "sql").Radio("rfees_stat", "{cust_code}", "{code_name}", "class=\"" + Lock.TryGet("QLock") + "\" onclick=\"fees_stat_onclick()\"");
        html_send_way = Sys.getCustCode("GSEND_WAY", "", "sortfld").Option("{cust_code}", "{code_name}");

        opt_branch=Sys.GetSession("seBranch");
        
        PageLayout();
        this.DataBind();
    }

    private void PageLayout() {
        Lock["Lock38"] = Lock.TryGet("QLock");
        if (prgid == "brta38") {
            Lock["Lock38"] = "Lock";
        }
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
			<input type="hidden" id="rs_no" name="rs_no">
			<input type="text" id="nstep_grade" name="nstep_grade" size=3 class=sedit readonly>
			<input type="hidden" id="cgrs" name="cgrs">
			<input type="text" id="scgrs" name="scgrs" size=4 class=sedit readonly>
		</TD>
		<TD class=lightbluetable align=right>發文日期：</TD>
		<TD class=whitetablebg>
            <input type="text" id="step_date" name="step_date" size="10" class="dateField <%=Lock.TryGet("QLock")%>">
            <input type="hidden" id="old_step_date" name="old_step_date">
		</TD>
		<TD class=lightbluetable align=right>總發文日期：</TD>
		<TD class=whitetablebg><input type="text" id="mp_date" name="mp_date" size="10" class="dateField <%=Lock.TryGet("QLock")%>"></TD>
	</TR>
	<TR id=tr_send>	
		<TD class=lightbluetable align=right>發文對象：</TD>
		<TD class=whitetablebg >
			<SELECT id=send_cl name=send_cl class="<%=Lock.TryGet("QLock")%>"><%=html_send_cl%></SELECT>
		</TD>
		<TD class=lightbluetable align=right>副本對象：</TD>
		<TD class=whitetablebg>
			<SELECT id=send_cl1 name=send_cl1 class="<%=Lock.TryGet("QLock")%>"><%=html_send_cl%></SELECT>
		</TD>
		<TD class=lightbluetable align=right>官方號碼：</TD>
		<TD class=whitetablebg>
			<SELECT id=send_sel name=send_sel class="<%=Lock.TryGet("QLock")%>"><%=html_send_sel%></SELECT>
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
            <select name="rs_class" id="rs_class" class="<%=Lock.TryGet("QLock")%>"></select>
			案性：
			<!--一案多件之子本所編號修改入檔用 -->
			<input type=hidden id="hrs_class" name="hrs_class">
			<input type=hidden id="hrs_code" name="hrs_code">
			<input type=hidden id="hact_code" name="hact_code">
			<input type=hidden id="hmarkb" name="hmarkb">
			<span id=span_rs_code>
                <select name="rs_code" id="rs_code" class="Lock"></select>
			</span><br>
			處理事項：
			<input type="hidden" id="act_sqlno" name="act_sqlno">
			<select name="act_code" id="act_code" class="<%=Lock.TryGet("QLock")%>"></select>
		</TD>
		<TD class=lightbluetable align=right>本次狀態：</TD>
		<TD class=whitetablebg><input type="hidden" id="ncase_stat" name="ncase_stat">
			<input type="text" id="ncase_statnm" name="ncase_statnm" size="10" class=sedit readonly></TD>
    </TR>
    <TR>
		<TD class=lightbluetable align=right>發文內容：</TD>
		<TD class=whitetablebg colspan=3><input type="text" id="rs_detail" name="rs_detail" style="width:95%" class="<%=Lock.TryGet("QLock")%>"></TD>
	    <TD class=lightbluetable align=right>發文出名代理：</TD>
		<TD class=whitetablebg ><input type=hidden id="rs_agt_no" name="rs_agt_no">
		    <input type="text" id="rs_agt_nonm" name="rs_agt_nonm" size=15 class=sedit readonly>
		</td>
	</TR>
	<TR id=tr_send_way>
		<TD class=lightbluetable align=right>發文方式：</TD>
		<TD class=whitetablebg colspan=5>
			<select id="send_way" name="send_way" class="<%=Lock.TryGet("QLock")%>" >
                <%=html_send_way%>
			</select>
			<input type="hidden" id="spe_ctrl" name="spe_ctrl">	
			<input type="hidden" id="spe_ctrl_4" name="spe_ctrl_4">	
			<input type="hidden" id="old_send_way" name="old_send_way">
		</TD>
	</tr>
	<TR id=tr_case>	
		<TD class=lightbluetable align=right>承辦：</TD>
		<TD class=whitetablebg><SELECT id="pr_scode" name="pr_scode" class="<%=Lock.TryGet("QLock")%>">
			<%=html_pr_scode%>
			</select>
		</TD>
		<TD class=lightbluetable align=right>規費支出：</TD>
		<TD class=whitetablebg <%if ((HTProgRight & 128)==0 && (HTProgRight & 256)==0) Response.Write("colspan=3"); %>>
			<input type="text" id="fees" name="fees" size="6" class="<%=Lock.TryGet("QLock")%>" style='text-align:right;' onblur="brta311form.chkfees()">
		</TD>
        <%if ((HTProgRight & 128)!=0 || (HTProgRight & 256)!=0){%>
		    <TD class=lightbluetable align=right>
		        <input type="hidden" id="fees_stat" name="fees_stat">
		        收費管制：
		    </TD>
		    <TD class=whitetablebg>
			    <%=html_rfees_stat%>
		    </TD>
		<%}%>
	</TR>
	<TR id=tr_rectitle>	
		<TD class=lightbluetable align=right>官發收據種類：</TD>
		<TD class=whitetablebg>
			<select id="receipt_type" name="receipt_type" class="<%=Lock.TryGet("QLock")%>">
				<option value="" style="color:blue">請選擇</option>
				<option value="P">紙本收據</option>
				<option value="E">電子收據</option>
			</select>
		</TD>
		<TD class=lightbluetable align=right>收據抬頭：</TD>
		<TD class=whitetablebg colspan=3>
			<select id="receipt_title" name="receipt_title" class="<%=Lock.TryGet("Lock38")%>">
				<option value="" style="color:blue">請選擇</option>
				<option value="A">案件申請人</option>
				<option value="B">空白</option>
				<option value="C">案件申請人(代繳人)</option>
			</select>
			<input type="hidden" id="rectitle_name" name="rectitle_name">
		</TD>
	</TR>
	<TR id="show_optbranch" style="display:">
		<TD class=lightbluetable align=right><font color=darkblue>※發文單位：</font></TD>
		<TD class=whitetablebg colspan=5>
			<input type=radio id="opt_branch<%=opt_branch%>" name="opt_branch" value="<%=opt_branch%>" class="<%=Lock.TryGet("Qdisabled_opt")%>">自行發文
			<input type=radio id="opt_branchL" name="opt_branch" value="L" class="<%=Lock.TryGet("Qdisabled_opt")%>">轉法律所發文
		</TD>
	</tr>
</table>
<input type="hidden" id=arnum name=arnum value=0><!--支出筆數-->
<input type="hidden" id=oldarnum name=oldarnum value=0><!--支出筆數，修改時，刪除筆數要將case_dmt減回去-->
<TABLE id=tabar border=0 class="bluetable" cellspacing=1 cellpadding=2 width="100%">
    <thead>
	<TR>
		<TD class=whitetablebg colspan=8>對應交辦收費：
			<input type=button value ="增加一筆" class="cbutton <%=Lock.TryGet("QLock")%>" id=arAdd_button name=arAdd_button onclick="brta311form.add_ar()">
			<input type=button value ="減少一筆" class="cbutton <%=Lock.TryGet("QLock")%>" id=arres_button name=arres_button onclick="brta311form.del_ar()">
            <span id="span_chk_type"></span>
		</TD>
		<TD class=whitetablebg align=left>
			合計: <input type="text" class="sedit" readonly id="tot_fees" name="tot_fees" value="0" maxlength=7 size=7>
		</TD>
	</TR>
	<TR align=center class=lightbluetable>
		<TD></TD><TD>交辦單號</TD><td>本次支出</td><TD>委辦案性</TD><TD>規費</TD><TD title="本次以外已支出之規費">已支出<br>規費</TD><TD>已支出<br>次數</TD><TD>請款註記</TD><TD>出名代理人</TD>
	</TR>
    </thead>
    <tbody></tbody>
    <script type="text/html" id="gs_ar_template"><!--對應交辦樣板-->
	    <tr id=tr_ar_##>
		    <td class=whitetablebg align=center>
	            ##.
		    </td>
		    <td class="whitetablebg" align=center>
	            <input type=text size=10 maxlength=10 id=case_no_## name=case_no_## <%if (submitTask != "D") Response.Write("onblur='brta311form.getmoney(\"##\")'");%> class='<%=Lock.TryGet("QLock")%>' >
	            <input type=hidden id=oldcase_no_## name=oldcase_no_##>
	            <input type=button value='查' class='cbutton <%=Lock.TryGet("QLock")%>' id='btncase_no_##' name='btncase_no_##' onclick='brta311form.btncase_no("##")' title='查詢交辦編號'>
	            <input type='hidden' id=rs_type_## name=rs_type_##>
		    </td>
		    <td class=whitetablebg align=center>
	            <input type=text size=6 maxlength=6 id=gs_fees_## name=gs_fees_## onblur='brta311form.chkmoney("##")' class='<%=Lock.TryGet("QLock")%>' style='text-align:right;'>
	            <input type='hidden' size=6 maxlength=6 id=hngs_fees_## name=hngs_fees_##>
		    </td>
		    <td class=whitetablebg align=center>
	            <input type=text size=16 maxlength=16 style='text-align:center;width:80px' readonly class=sedit id=arcasenm_## name=arcasenm_##>
		    </td>
		    <td class=whitetablebg align=center>
	            <input type=text size=6 maxlength=6 style='text-align:center;' readonly class=sedit id=fees_## name=fees_##>
		    </td>
		    <td class=whitetablebg align=center>
	            <input type=text size=6 maxlength=6 style='text-align:center;' readonly class=sedit id=hgs_fees_## name=hgs_fees_##>
		    </td>
		    <td class=whitetablebg align=center>
	            <input type='hidden' id=service_## name=service_## style='width:95%'>
	            <input type=text size=2 maxlength=2 style='text-align:center;' readonly class=sedit id=gs_curr_## name=gs_curr_##>
		    </td>
		    <td class=whitetablebg align=center>
	            <input type=text size=12 maxlength=16 style='text-align:center;' readonly class=sedit id=ar_marknm_## name=ar_marknm_##>
		    </td>
		    <td class=whitetablebg align=center>
	            <input type='hidden' id=case_agt_no_## name=case_agt_no_##>
	            <input type=text size=16 maxlength=16 style='text-align:center;' readonly class=sedit id=agt_nonm_## name=agt_nonm_##>
		    </td>
	    </tr>
    </script>
</table>
<input type="hidden" id=tot_num name=tot_num value=0><!--一案多件筆數-->
<TABLE id=tabar1 border=0 class="bluetable" cellspacing=1 cellpadding=2 width="100%" style="display:none">
    <thead>
		<TR>
			<TD class=whitetablebg colspan=7><span id="span_seqdesc">一案多件附屬本所編號：</span>
				<input type=button value="增加一筆" style="display:none" class="cbutton <%=Lock.TryGet("QLock")%>" id=dseqAdd_button name=dseqAdd_button onclick="brta311form.dseqAdd('N')" >
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
		    <td class="whitetablebg rs_code_FD" align=center nowrap>
		        <input type=text size=5 maxlength=5 id=dseq_## name=dseq_## onchange='brta311form.btndseqchange(##)' class='FD_lock'>-<input type=text size=1 maxlength=1 id=dseq1A_## name=dseq1A_## class='FD_lock' value='_' >
		        <input type=hidden id=hrs_no_## name=hrs_no_##>
		        <input type=button value ='確定' class='cbutton FD_lock' id='btndseq_ok_##' name='btndseq_ok_##' onclick='brta311form.btndseq("##")' title='本所編號確認'>
		        <input type=button value ='查詢' class='cbutton FD_lock' id='btndseqq1_##' name='btndseqq1_##' onclick='brta311form.btndseqq1("##")' title='查詢本所編號'>
		        <input type=button value ='主檔' class='cbutton <%=Lock.TryGet("QLock")%>' id='btndseqq2_##' name='btndseqq2_##' onclick='brta311form.btndseqq2("##")' title='查詢案件主檔'>
		        <input type='hidden' id='keydseq_##' name='keydseq_##'>
		    </td>
		    <td class=whitetablebg align=center>
	            <input type=text id='s_mark_##' name=s_mark_## style='text-align:center;width:95%' readonly class='SEdit'>
		    </td>
		    <td class=whitetablebg align=center>
	            <input type=text id=dclass_## name=dclass_## style='text-align:left;width:95%' readonly class='SEdit'>
		    </td>
		    <td class=whitetablebg align=center>
		        <input type=text id=appl_name_## name=appl_name_## style='text-align:left;width:95%' readonly class='SEdit'>
		    </td>
		    <td class=whitetablebg align=center>
		        <input type=text id=dref_no_## name=dref_no_## style='text-align:center;width:95%' readonly class='SEdit'>
		    </td>
		    <td class=whitetablebg align=center>
		        <input type=checkbox id=dseqdel_## name=dseqdel_## value='' onclick='brta311form.dseqdel("##")' <%if (prgid=="brt63" || prgid=="brta38"){%> disabled <%}%>>
		    </td>
	    </tr>
    </script>
</table>

<script language="javascript" type="text/javascript">
    var brta311form = {};

    brta311form.init = function () {
        $("input[name='opt_branch'][value='<%#opt_branch%>']").prop("checked",true);
    }

    brta311form.bind = function (jData, jFees) {
        brta311form.empty_ar();//交辦單號清空
        $("#rs_no").val(jData.rs_no);
        $("#cgrs").val(jData.cgrs.toUpperCase()).triggerHandler("change");
        $("#old_step_date").val(jData.step_date);
        if (jData.step_grade != undefined) $("#nstep_grade").val(jData.step_grade);
        $("#step_date").val(jData.step_date);
        $("#mp_date").val(jData.mp_date);
        $("#send_cl option[value='" + jData.send_cl + "']").prop("selected", true);
        $("#send_cl1 option[value='" + jData.send_cl1 + "']").prop("selected", true);
        $("#send_sel option[value='" + jData.send_sel + "']").prop("selected", true);
        $("#rs_type").val(jData.rs_type).triggerHandler("change");
        $("#rs_class_name").val(jData.rs_class_name);
        $("#rs_code_name").val(jData.rs_code_name);
        $("#act_code_name").val(jData.act_code_name);
        $("#case_arcase_class").val(jData.rs_class);
        $("#case_arcase").val(jData.rs_code);
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
        if (jData.ncase_stat != undefined) $("#ncase_stat").val(jData.ncase_stat);
        if (jData.ncase_statnm != undefined) $("#ncase_statnm").val(jData.ncase_statnm);
        if (jData.rs_detail != undefined) $("#rs_detail").val(jData.rs_detail);
        $("#send_way option[value='" + jData.send_way + "']").prop("selected", true);
        if (jData.old_send_way != undefined) {
            $("#old_send_way").val(jData.old_send_way);
        } else {
            $("#old_send_way").val(jData.send_way);
        }
        $("#rs_agt_no").val(jData.rs_agt_no);
        $("#rs_agt_nonm").val(jData.rs_agt_nonm);
        if (jData.pr_scode != undefined) {
            $("#pr_scode option[value='" + jData.pr_scode + "']").prop("selected", true);
        } else {
            $("#pr_scode option[vsort='01']").prop("selected", true);//預設值
        }
        $("#fees").val(jData.fees);
        $("#fees_stat").val(jData.fees_stat);
        $("input[name='rfees_stat'][value='" + jData.fees_stat + "']").prop("checked", true);
        //if (main.submittask == "A") {
        //    if ((main.right & 128) != 0 || (main.right & 256) != 0) {
        //        $("input[name='rfees_stat']:eq(0)").prop("checked", true);
        //    }
        //} else {
        //    if ((main.right & 128) != 0 || (main.right & 256) != 0) {
        //        $("input[name='rfees_stat'][value='" + jData.fees_stat + "']").prop("checked", true);
        //    }
        //}
        $("#receipt_type option[value='" + jData.receipt_type + "']").prop("selected", true);
        $("#receipt_title option[value='" + jData.receipt_title + "']").prop("selected", true);
        $("#rectitle_name").val(jData.rectitle_name);
        $("input[name='opt_branch'][value='" + jData.opt_branch + "']").prop("checked", true);
        $("#span_chk_type").html(jData.chk_typestr);

        if (main.prgid1 == "brta81" || main.prgid == "brta38") {
            if (jData.case_no != "") {
                brta311form.add_ar();//增加一筆交辦單號
            }
            brta311form.get_dstep(jData.rs_no);//取得一案多件子本所編號資料
        } else {
            if (main.submittask == "A") {
                brta311form.add_ar();//增加一筆交辦單號
            }

            if (main.submittask == "U" || main.submittask == "Q" || main.submittask == "D") {
                brta311form.appendFees(jFees);//交辦單號明細
                brta311form.get_dstep(jData.rs_no);//取得一案多件子本所編號資料
            }
        }
    }

    brta311form.appendFees = function (jData) {
        if (jData != null) {
            $.each(jData, function (i, item) {
                brta311form.add_ar();//增加一筆交辦單號
                var nRow = $("#arnum").val();
                if (CInt(nRow) == 1) {
                    $("#case_change").val(item.change);
                    $("#case_arcase_class").val(item.arcase_class);
                    $("#case_arcase").val(item.arcase);
                }

                $("#case_no_" + nRow).val(item.case_no);
                $("#oldcase_no_" + nRow).val(item.case_no);
                $("#rs_type_" + nRow).val(item.arcase_type);
                $("#gs_fees_" + nRow).val(item.fees);//本次支出
                $("#hngs_fees_" + nRow).val(item.fees);//本次支出
                $("#tot_fees").val(CInt($("#tot_fees").val()) + CInt(item.fees));
                $("#arcasenm_" + nRow).val(item.arcasenm);//委辦案性
                $("#fees_" + nRow).val(item.case_fees);//規費
                $("#hgs_fees_" + nRow).val(CInt(item.gs_fees) - CInt(item.fees));//已支出規費
                if (CInt(item.gs_curr) >= 1) {//已支出次數
                    $("#gs_curr_" + nRow).val(CInt(item.gs_curr) - 1);//不包含自己
                } else {
                    $("#gs_curr_" + nRow).val(CInt(item.gs_curr));
                }
                $("#service_" + nRow).val(item.service);
                $("#ar_marknm_" + nRow).val(item.ar_marknm);//請款註記
                $("#case_agt_no_" + nRow).val(item.agt_no);//出名代理人
                $("#agt_nonm_" + nRow).val(item.receipt + "_" + item.agt_name);//出名代理人
            });
            $("#oldarnum").val(jData.length);
        }
    }
    /*
    brta311form.bind = function (jData) {
        $("#rs_no").val(jData.rs_no);
        $("#cgrs").val(jData.cgrs).triggerHandler("change");
        $("#step_date").val(jData.step_date);
        $("#mp_date").val(jData.mp_date);
        $("#send_cl option[value='" + jData.send_cl + "']").prop("selected", true);
        $("#send_cl1 option[value='" + jData.send_cl1 + "']").prop("selected", true);
        $("#send_sel option[value='" + jData.send_sel + "']").prop("selected", true);
        $("#rs_type").val(jData.rs_type).triggerHandler("change");
        $("#rs_class_name").val(jData.rs_class_name);
        $("#rs_code_name").val(jData.rs_code_name);
        $("#act_code_name").val(jData.act_code_name);
        $("#case_arcase_class").val(jData.rs_class);
        $("#case_arcase").val(jData.rs_code);
        $("#rs_class option[value='" + jData.rs_class + "']").prop("selected", true);
        $("#rs_class").triggerHandler("change");
        $("#hrs_class").val(jData.rs_class);
        $("#hrs_code").val(jData.rs_code);
        $("#hact_code").val(jData.act_code);
        $("#hmarkb").val(jData.markb);
        $("#rs_code option[value='" + jData.rs_code + "']").prop("selected", true);
        $("#rs_code").triggerHandler("change");
        $("#act_sqlno").val(jData.act_sqlno);
        if ((jData.act_code||"") == "") {
            $("#act_code option[value='_']").prop("selected", true);
        } else {
            $("#act_code option[value='" + jData.act_code + "']").prop("selected", true);
        }
        $("#act_code").triggerHandler("change");
        if (jData.ncase_stat != undefined) $("#ncase_stat").val(jData.ncase_stat);
        if (jData.ncase_statnm != undefined) $("#ncase_statnm").val(jData.ncase_statnm);
        if (jData.rs_detail != undefined) $("#rs_detail").val(jData.rs_detail);
        $("#send_way option[value='" + jData.send_way + "']").prop("selected", true);
        if (jData.old_send_way != undefined) {
            $("#old_send_way").val(jData.old_send_way);
        } else {
            $("#old_send_way").val(jData.send_way);
        }
        $("#rs_agt_no").val(jData.rs_agt_no);
        $("#rs_agt_nonm").val(jData.rs_agt_nonm);
        if (jData.pr_scode != undefined) {
            $("#pr_scode option[value='" + jData.pr_scode + "']").prop("selected", true);
        } else {
            $("#pr_scode option[vsort='01']").prop("selected", true);//預設值
        }
        $("#fees").val(jData.fees);
        $("#fees_stat").val(jData.fees_stat);
        if (main.submittask == "A") {
            if ((main.right & 128) != 0 || (main.right & 256) != 0) {
                $("input[name='rfees_stat']:eq(0)").prop("checked", true);
            }
        } else {
            if ((main.right & 128) != 0 || (main.right & 256) != 0) {
                $("input[name='rfees_stat'][value='" + jData.fees_stat + "']").prop("checked", true);
            }
        }
        $("#receipt_type option[value='" + jData.receipt_type + "']").prop("selected", true);
        $("#receipt_title option[value='" + jData.receipt_title + "']").prop("selected", true);
        $("#rectitle_name").val(jData.rectitle_name);
        $("input[name='opt_branch'][value='" + jData.opt_branch + "']").prop("checked", true);
        $("#span_chk_type").html(jData.chk_typestr);
    }
    */

    //官發、客發 控制畫面
    $("#cgrs").change(function () {
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
            data: { cgrs: "GS", rs_class: $("#rs_class").val(), rs_type: $("#rs_type").val(), submittask: $("#submittask").val() || "" },
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
            data: { cgrs: "GS", rs_class: $("#rs_class").val(), rs_code: $("#rs_code").val() },
            valueFormat: "{act_code}",
            textFormat: "{act_code_name}",
            attrFormat: "spe_ctrl='{spe_ctrl}'"
        });
        $("#ncase_statnm").val("");
        $("#act_code option[value='_']").prop("selected", true);
        $("#act_code").triggerHandler("change");

        //抓規費收費標準
        if ($("#submittask").val() == "A" && $("#prgid1").val() != "brta81") {
            $("#fees").val($('option:selected', this).attr('vfees'));
        }

        //註冊費繳納期數與發文案性關聯性檢查
        if ($("#submittask").val() != "Q" && $("#prgid1").val() != "brta81") {
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

        //2010/7/26因應承辦交辦發文不用管制期限，增加判斷prgid=brt63不抓期限管制
        if (($("#submittask").val() == "A" && $("#prgid").val() != "brt63") || ($("#submittask").val() == "U" && $("#prgid").val() == "brta38")) {
            brta212form.empty_ctrl();//onchange觸發多次會有多筆.先清空管制期限
            brta311form.getCtrl();
        }

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
                    $("#spe_ctrl").val(item.spe_ctrl);
                    $("#act_sqlno").val(item.ctrl_sqlno);

                    if ($("#spe_ctrl").val() != "") {
                        var spe_ctrl = $("#spe_ctrl").val().split(",");
                        $("#spe_ctrl").val(spe_ctrl[3]);
                        $("#spe_ctrl_4").val(spe_ctrl[4]);
                        if ($("#spe_ctrl").val() == "E") {
                            if ($("#submittask").val() != "U" && $("#submittask").val() != "Q" && $("#submittask").val() != "D" && $("#submittask").val() != "A") {
                                $("#send_way").val($("#spe_ctrl").val());
                            }
                        }else{
                            if ($("#submittask").val() != "U" && $("#submittask").val() != "Q" && $("#submittask").val() != "D" && $("#submittask").val() != "A") {
                                $("#send_way option[value='M']").prop("selected", true);
                            }
                        }
                    } else {
                        if ($("#submittask").val() != "U" && $("#submittask").val() != "Q" && $("#submittask").val() != "D" && $("#submittask").val() != "A") {
                            $("#send_way option[value='M']").prop("selected", true);
                        }
                    }
                })
            },
            error: function (xhr) {
                $("#dialog").html("<a href='" + this.url + "' target='_new'>案性設定載入失敗！<u>(點此顯示詳細訊息)</u></a><hr>" + xhr.responseText);
                $("#dialog").dialog({ title: '案性設定載入失敗！', modal: true, maxHeight: 500, width: "90%" });
            }
        });
    });

    //產生預設期限/案性管制設定
    brta311form.getCtrl = function () {
        $.ajax({
            type: "get",
            url: getRootPath() + "/ajax/json_act_sqlno.aspx?cgrs=" + $("#cgrs").val() + "&rs_class=" + $("#rs_class").val() + "&rs_code=" + $("#rs_code").val() + "&act_code=" + $("#act_code").val(),
            async: false,
            cache: false,
            success: function (json) {
                var jCtrl = $.parseJSON(json);
                $.each(jCtrl, function (i, item) {
                    if (item.sqlflg == "A") {
                        $("#act_sqlno").val(item.ctrl_sqlno);
                        brta212form.add_ctrl(true);
                        $("#ctrl_type_" + $("#ctrlnum").val()).val(item.ctrl_type);//管制種類
                        $("#ctrl_remark_" + $("#ctrlnum").val()).val(item.ctrl_remark);//管制內容
                        var days = 0;//管制天數
                        if (item.ad == "A") {//日期基礎:A:加，D:減 
                            days = CInt(item.days);
                        } else {
                            days = CInt(item.days) * -1;
                        }
                        var days2 = 0;//管制天數
                        if (item.ad2 == "A") {//日期基礎:A:加，D:減 
                            days2 = CInt(item.days2);
                        } else {
                            days2 = CInt(item.days2) * -1;
                        }

                        var md = item.md;//管制性質
                        var md2 = item.md2;//管制性質
                        var date_ctrl = $("#" + item.date_name).val() || "";//基準日期欄位
                        if (date_ctrl == "") {
                            alert("管制天數之基準日期未輸入, 請輸入!!");
                            $("#act_sqlno").val("");
                            $("#" + item.date_name).focus();
                        }

                        var Cdate_ctrl = CDate(date_ctrl);
                        if (md.toUpperCase() == "D") {
                            Cdate_ctrl = Cdate_ctrl.addDays(days);
                        } else if (md.toUpperCase() == "M") {
                            Cdate_ctrl = Cdate_ctrl.addMonths(days);
                        } else if (md.toUpperCase() == "Y") {
                            Cdate_ctrl = Cdate_ctrl.addYears(days);
                        }

                        if (item.ad2 != "") {
                            if (md2.toUpperCase() == "D") {
                                Cdate_ctrl = Cdate_ctrl.addDays(days2);
                            } else if (md2.toUpperCase() == "M") {
                                Cdate_ctrl = Cdate_ctrl.addMonths(days2);
                            } else if (md2.toUpperCase() == "Y") {
                                Cdate_ctrl = Cdate_ctrl.addYears(days2);
                            }
                        }

                        $("#ctrl_date_" + $("#ctrlnum").val()).val(Cdate_ctrl.format("yyyy/M/d"));//管制日期
                        $("#ncase_stat").val(item.case_stat);
                        $("#ncase_statnm").val(item.case_statnm);
                    } else {
                        //無預設期限管制, 新增法定期限及自管期限
                        brta212form.add_ctrl(false);
                        $("#ctrl_type_1").val("A1");
                        brta212form.add_ctrl(false);
                        $("#ctrl_type_2").val("B1");
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

    //清空交辦單號
    brta311form.empty_ar = function () {
        $("#tabar tbody").empty();
        $("#arnum").val("0");
    }
    //增加一筆交辦單號
    brta311form.add_ar = function () {
        var nRow = CInt($("#arnum").val()) + 1;
        //複製樣板
        var copyStr = $("#gs_ar_template").text() || "";
        copyStr = copyStr.replace(/##/g, nRow);
        $("#tabar tbody").append(copyStr);
        $("#arnum").val(nRow);
        $(".dateField", $('#tr_ar_' + nRow)).datepick();
    }

    //減少一筆交辦單號
    brta311form.del_ar = function () {
        var nRow = CInt($("#arnum").val());
        $('#tr_ar_' + nRow).remove();
        $("#arnum").val(Math.max(0, nRow - 1));
    }

    //查詢交辦單號
    brta311form.btncase_no = function (nRow) {
        if ($("#seq").val() != "" && $("#seq1").val() != "") {
            //***todo
            var url = getRootPath() + "/brtam/brta31list_1.aspx?prgid1=<%=Request["prgid1"]%>&submitTask=<%=submitTask%>&seq=" + $("#seq").val() + "&seq1=" + $("#seq1").val() + "&cust_area=" + $("#cust_area").val() + "&cust_seq=" + $("#cust_seq").val() + "&casenum=" + nRow + "&rs_agt_no=" + $("#rs_agt_no").val() + "&rs_agt_nonm=" + $("#rs_agt_nonm").val();
            window.open(url, "myWindowOneN", "width=780 height=500 top=10 left=10 toolbar=no, menubar=no, location=no, directories=no resizeable=no status=no scrollbars=yes");
            var tot_fees = 0;
            for (var n = 1; n <= CInt($("#arnum").val()) ; n++) {
                if ($("#gs_fees_" + n).val() != "") {
                    tot_fees += CInt($("#gs_fees_" + n).val());
                }
            }
            $("#tot_fees").val(tot_fees);
        } else {
            alert("需先輸入本所編號!!!");
            $("#seq").focus();
            return false;
        }
    }

   //顯示交辦單號
    brta311form.getcase_no_data1 = function (case_no) {
        if (case_no != "") {
            $("#case_no_1").val(case_no);
            brta311form.getmoney(1);
        }
    }

    //依交辦單號抓取服務費、規費
    brta311form.getmoney = function (nRow) {
        var case_no=$("#case_no_"+nRow).val();
        var oldcase_no=$("#oldcase_no_"+nRow).val();
        if (case_no==""){
            $("#arcasenm_"+nRow).val("");
            $("#ar_marknm_"+nRow).val("");
            $("#fees_"+nRow).val("0");
            $("#fees_"+nRow).val("0");
            $("#gs_curr_"+nRow).val("0");
            $("#service_"+nRow).val("0");
            $("#gs_fees_"+nRow).val("0");
            $("#hgs_fees_"+nRow).val("0");
            $("#hngs_fees_"+nRow).val("0");
            return false;
        }
        if ($("#seq").val() == "") {
            alert("請先輸入本所編號!!!");
            return false;
        }
        //不可同一筆官發重覆輸入同一case_no
        for (var j = 1; j <= CInt($("#arnum").val()) ; j++) {
            var ixcase_no = $("#case_no_" + j).val();//比對的key值
            if(j!=nRow){
                if (case_no==ixcase_no){
                    alert("同一筆官發不可重覆輸入同一筆交辦單號!!!");
                    return false;
                }
            }
        }

        if (oldcase_no==case_no) return false;

        var rs_type=$("#rs_type_"+nRow).val();
        $.ajax({
            type: "get",
            url: getRootPath() + "/ajax/json_case_no.aspx?case_no=" + case_no + "&seq=" + $("#seq").val() + "&seq1=" + $("#seq1").val() + "&step_grade=" + $("#nstep_grade").val() + "&rs_type=" + rs_type + "&rs_no=" + $("#rs_no").val(),
            async: false,
            cache: false,
            success: function (json) {
                //window.open(this.url);  
                var jCase = $.parseJSON(json);
                if (jCase.length > 0) {
                    $("#arcasenm_" +nRow).val(jCase[0].arcasenm);
                    $("#ar_marknm_" +nRow).val(jCase[0].ar_marknm);
                    $("#fees_" +nRow).val(jCase[0].a_fees);
                    $("#gs_curr_" +nRow).val(jCase[0].gs_curr);
                    if(jCase[0].havedata=="Y"){//表fees_dmt有該case_no資料
                        $("#service_" +nRow).val(jCase[0].nowservice);
                        $("#gs_fees_" +nRow).val(jCase[0].nowfees);
                        $("#hgs_fees_" +nRow).val(CInt(jCase[0].gs_fees)-CInt(jCase[0].nowfees));
                    }else{
                        if(CInt(jCase[0].gs_curr)>0){//若gs_curr>0表該case_no表服務費已收不可再重覆收
                            $("#service_" +nRow).val(jCase[0].nowservice);
                        }else{
                            $("#service_" +nRow).val(jCase[0].a_service);
                        }
                        $("#gs_fees_" +nRow).val(CInt(jCase[0].fees)-CInt(jCase[0].gs_fees));
                        $("#hgs_fees_" +nRow).val(jCase[0].gs_fees);
                    }
                    $("#hngs_fees_" +nRow).val(jCase[0].nowfees);
                    $("#agt_nonm_" +nRow).val(jCase[0].receipt+"_"+jCase[0].agt_name);
                    $("#case_agt_no_" +nRow).val(jCase[0].agt_no);
                }else{
                    alert("無此交辦單號");
                    $("#case_no_" +nRow).focus();
                }

                var tot_fees = 0;
                for (var n = 1; n <= CInt($("#arnum").val()) ; n++) {
                    if ($("#gs_fees_" + n).val() != "") {
                        tot_fees += CInt($("#gs_fees_" + n).val());
                    }
                }
                $("#tot_fees").val(tot_fees);
                brta311form.get_dseq(case_no);
            },
            error: function (xhr) {
                $("#dialog").html("<a href='" + this.url + "' target='_new'>交辦單載入失敗！<u>(點此顯示詳細訊息)</u></a><hr>" + xhr.responseText);
                $("#dialog").dialog({ title: '交辦單載入失敗！', modal: true, maxHeight: 500, width: "90%" });
            }
        });
    }

    //本次支出
    brta311form.chkmoney = function (nRow) {
        var gs_fees=CInt($("#gs_fees_" +nRow).val());
        var fees=CInt($("#fees_" +nRow).val());
        var hgs_fees=CInt($("#hgs_fees_" +nRow).val());

        if (chkNum(gs_fees, "本次支出")) {
            $("#gs_fees_" +nRow).focus();
            return false;
        }

	    if (gs_fees<0) {
	        $("#gs_fees_" +nRow).focus();
	        alert("本次支出不可小於零!!!");
            return false;
	    }

	    if ((gs_fees + hgs_fees) > fees ){
	        alert("累計支出規費 (" + gs_fees + " + " + hgs_fees + ") 已大於交辦時設定之規費, 請提列不足!!");
	        if ((main.right & 128) != 0 || (main.right & 256) != 0) {
	            $("input[name='rfees_stat']:eq(1)").prop("checked", true);
	        }
	        $("#fees_stat").val("A");
	    }
        brta311form.countfees();
    }

    //本次支出合計
    brta311form.countfees = function () {
        var tot_fees = 0;
        for (var n = 1; n <= CInt($("#arnum").val()) ; n++) {
            if ($("#gs_fees_" + n).val() != "") {
                tot_fees += CInt($("#gs_fees_" + n).val());
            }
        }
        $("#tot_fees").val(tot_fees);
        if (CInt($("#tot_fees").val()) > CInt($("#fees").val())) {
            alert("本次支出合計(" + $("#tot_fees").val() + ")大於此案性合理之規費支出金額(" + $("#fees").val() + ")!!");
            return false;
        }
    }

    brta311form.chkfees = function () {
        if (CInt($("#fees").val()) < 0) {
            alert("規費支出不可小於零!!!");
            $("#fees").focus();
            return false;
        }
        if (CInt($("#fees").val()) > 0 && CInt($("#arnum").val()) <= 0) {
            brta311form.add_ar();//增加一筆交辦單號
        }
    }

    //取得子案案號
    brta311form.get_dseq = function (pcase_no) {
        if ($("#rs_code").val() == null) return;
        if ($("#rs_code").val() == "FC11"||$("#rs_code").val() == "FC21" || $("#rs_code").val().Left(2) == "FD"
            || $("#rs_code").val() == "FC5" || $("#rs_code").val() == "FC6"|| $("#rs_code").val() == "FC7"|| $("#rs_code").val() == "FC8"
            || $("#rs_code").val() == "FCH" || $("#rs_code").val() == "FCI" || $("#rs_code").val() == "FL5" || $("#rs_code").val() == "FL6"
             || $("#rs_code").val() == "FT2") {

            $.ajax({
                type: "get",
                url: getRootPath() + "/ajax/json_get_seq.aspx?case_no=" + pcase_no,
                async: false,
                cache: false,
                success: function (json) {
                    var jSeq = $.parseJSON(json);
                    $.each(jSeq, function (i, item) {
                        var mseq=$.trim($("#seq").val())+$.trim($("#seq1").val());
                        var dseq=$.trim(item.seq)+$.trim(item.seq1);
                        if(mseq!=dseq){
                            brta311form.dseqAdd("Y");
                            $("#dseq_" + $("#tot_num").val()).val(item.seq);
                            $("#dseq1A_" + $("#tot_num").val()).val(item.seq1);
                            brta311form.btndseq($("#tot_num").val());//[確定]
                        }
                    })
                    if (jSeq.length > 0) {
                        if ($("#rs_code").val() == "FC11"|| $("#rs_code").val() == "FD1"
                        || $("#rs_code").val() == "FC5" || $("#rs_code").val() == "FC7"|| $("#rs_code").val() == "FCH" ) {
                            $("#span_no").html("申請號");
                        }else if ($("#rs_code").val() == "FC21"|| $("#rs_code").val() == "FD2"|| $("#rs_code").val() == "FD3"
                            || $("#rs_code").val() == "FC6" || $("#rs_code").val() == "FC8"|| $("#rs_code").val() == "FCI" 
                            || $("#rs_code").val() == "FL5" || $("#rs_code").val() == "FL6"|| $("#rs_code").val() == "FT2" ) {
                            $("#span_no").html("註冊號");
                        }

                        if ($("#rs_code").val().Left(2) == "FD") {
                            $("#span_seqdesc").html("分割案件本所編號:");
                        } else {
                            $("#span_seqdesc").html("一案多件附屬本所編號:");
                        }
                        $("#tabar1").show();
                    }else{
                        $("#tabar1").hide();
                    }
                },
                error: function (xhr) {
                    $("#dialog").html("<a href='" + this.url + "' target='_new'>案性設定載入失敗！<u>(點此顯示詳細訊息)</u></a><hr>" + xhr.responseText);
                    $("#dialog").dialog({ title: '案性設定載入失敗！', modal: true, maxHeight: 500, width: "90%" });
                }
            });
        }
    }

    //一案多件/分割 增加一筆子案
    brta311form.dseqAdd = function (plock) {
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
            $('#tr_cr_' + nRow + ' .FD_lock').lock("<%=Lock.TryGet("QLock")%>" == "Lock");
            $("#keydseq_" + nRow).val("N");
        }
    }

    //減少一筆一案多件之本所編號
    brta311form.dseqRes= function () {
        var nRow = CInt($("#tot_num").val());
        $('#tr_cr_' + nRow).remove();
        $("#tot_num").val(Math.max(0, nRow - 1));
    }

    //一案多件變更本所編號後將確定 button on 起來
    brta311form.btndseqchange=function(nRow){
        $("#keydseq_" + nRow).val("N");
        $("#btndseq_ok_" + nRow).unlock();
    }

    //一案多件[確定]
    brta311form.btndseq = function (nRow) {
        //檢查案件客戶與主案件是否相同
        if ($("#dseq_" + nRow).val() == "") {
            return false;
        }
        if (chkNum($("#seq").val(), "本所編號")) return false;

        var dmt_data = {};
        $.ajax({
            type: "get",
            url: getRootPath() + "/ajax/json_dmt.aspx?prgid=" + $("#prgid").val() + "&seq=" + $("#dseq_" + nRow).val() + "&seq1=" + $("#dseq1A_" + nRow).val(),
            async: false,
            cache: false,
            success: function (json) {
                dmt_data = $.parseJSON(json);
            },
            error: function (xhr) {
                $("#dialog").html("<a href='" + this.url + "' target='_new'>抓取案件主檔失敗！<u>(點此顯示詳細訊息)</u></a><hr>" + xhr.responseText);
                $("#dialog").dialog({ title: '抓取案件主檔失敗！', modal: true, maxHeight: 500, width: "90%" });
            }
        });

        if (dmt_data.length == 0) {
            alert("輸入之本所編號不存在於案件主檔內，請重新輸入!!!");
            $("#dseq_" + nRow).val("").focus();
            return false;
        }

        if(dmt_data[0].rmarkcode!=""&&dmt_data[0].rmarkcode!="___"){
            alert(dmt_data[0].cust_area+dmt_data[0].cust_seq+"債信不良不可收發文，請重新輸入!!!");
            if($("#submittask").val()!="Q"){
                $("#dseq_" + nRow).val("").focus();
                return false;
            }
        }

        if(dmt_data[0].cust_seq!=$("#cust_seq").val()){
            alert("案件客戶必須與主要案件相同，請重新輸入!!!");
            if($("#submittask").val()!="Q"){
                $("#dseq_" + nRow).val("").focus();
                return false;
            }
        }

        if($("#end_date").val()!=""){
            alert("該案件已結案!!!");
            if($("#submittask").val()!="Q"){
                $("#dseq_" + nRow).val("").focus();
                return false;
            }
        }

        $("#s_mark_"+nRow).val(dmt_data[0].s_marknm);

        $("#dclass_" + nRow).val(dmt_data[0].class);
        $("#appl_name_" + nRow).val(dmt_data[0].appl_name);
        if ($("#hrs_code").val() == "FC11" || $("#hrs_code").val() == "FC5" || $("#hrs_code").val() == "FC7" || $("#hrs_code").val() == "FCH" || $("#hrs_code").val() == "FD1") {
            $("#dref_no_" + nRow).val(dmt_data[0].apply_no);
        } else if ($("#hrs_code").val() == "FC21" || $("#hrs_code").val() == "FD2" || $("#hrs_code").val() == "FD3"
            || $("#hrs_code").val() == "FC6" || $("#hrs_code").val() == "FC8" || $("#hrs_code").val() == "FCI"
            || $("#hrs_code").val() == "FL5" || $("#hrs_code").val() == "FL6" || $("#hrs_code").val() == "FT2") {
            $("#dref_no_" + nRow).val(dmt_data[0].issue_no);
        }
        $("#keydseq_" + nRow).val("Y");//有按確定給Y
        $("#btndseq_ok_" + nRow).lock();
    }

    //一案多件[查詢]
    brta311form.btndseqq1 = function (nRow) {
        window.open(getRootPath() + "/brtam/brta21Query.aspx?cgrs=GS&cust_seq=" + $("#cust_seq").val() + "&tot_num=" + nRow, "myWindowOneN", "width=650 height=420 top=40 left=80 toolbar=no, menubar=no, location=no, directories=no resizeable=no status=no scrollbars=yes");
    }

    //一案多件[主檔]
    brta311form.btndseqq2 = function (nRow) {
        if ($("#dseq_"+nRow).val() == "") {
            alert("請先輸入本所編號!!!");
            return false;
        }

        $.ajax({
            type: "get",
            url: getRootPath() + "/ajax/json_dmt.aspx?prgid="+$("#prgid").val()+"&seq=" + $("#dseq_"+nRow).val() + "&seq1=" + $("#dseq1A_"+nRow).val(),
            async: false,
            cache: false,
            success: function (json) {
                var dmt_data = $.parseJSON(json);
                if (dmt_data.length == 0) {
                    alert("輸入之本所編號不存在於案件主檔內，請重新輸入!!!");
                    $("#dseq_" + nRow).val("").focus();
                    return false;
                }
            },
            error: function (xhr) {
                $("#dialog").html("<a href='" + this.url + "' target='_new'>抓取案件主檔失敗！<u>(點此顯示詳細訊息)</u></a><hr>" + xhr.responseText);
                $("#dialog").dialog({ title: '抓取案件主檔失敗！', modal: true, maxHeight: 500, width: "90%" });
            }
        });
        var url = getRootPath() + "/brt5m/brt15ShowFP.aspx?prgid=<%=prgid%>&seq=" + $("#dseq_" + nRow).val() + "&seq1=" + $("#dseq1A_" + nRow).val() + "&submittask=Q";
        window.showModalDialog(url, "", "dialogHeight: 520px; dialogWidth: 800px; center: Yes;resizable: No; status: No;scrollbars:yes");
    }

    brta311form.dseqdel=function (nRow) {
        if($("#dseqdel_"+nRow).prop("checked")==true){
            $("#dseqdel_"+nRow).val("D");
        }else{
            $("#dseqdel_"+nRow).val("");
        }
    }

    //取得發文進度子案
    brta311form.get_dstep = function (rs_no) {
        if ($("#rs_code").val() == null) return;
        if ($("#rs_code").val() == "FC11" || $("#rs_code").val() == "FC21" || $("#rs_code").val().Left(2) == "FD"
            || $("#rs_code").val() == "FC5" || $("#rs_code").val() == "FC6" || $("#rs_code").val() == "FC7" || $("#rs_code").val() == "FC8"
            || $("#rs_code").val() == "FCH" || $("#hrs_code").val() == "FCI" || $("#hrs_code").val() == "FL5" || $("#hrs_code").val() == "FL6"
             || $("#hrs_code").val() == "FT2") {

            $("#dseqAdd_button").show();

            var isql = "select * from vstep_dmt where main_rs_no ='" + rs_no + "'";
            isql += " and main_rs_no <> rs_no order by rs_no";
            $.ajax({
                type: "get",
                url: getRootPath() + "/ajax/JsonGetSqlData.aspx",
                data: { sql: isql },
                async: false,
                cache: false,
                success: function (json) {
                    var jSeq = $.parseJSON(json);
                    if (jSeq.length > 0) {
                        $("#tabar1").show();
                    }
                    $.each(jSeq, function (i, item) {
                        brta311form.dseqAdd("Y");
                        var tot_num = $("#tot_num").val();
                        $("#dseq_" + tot_num).val(item.seq);
                        $("#dseq1A_" + tot_num).val(item.seq1);
                        $("#hrs_no_" + tot_num).val(item.rs_no);
                        $("#keydseq_" + tot_num).val("Y");
                        $("#btndseq_ok_" + tot_num).lock();
                        var smark = "商標";
                        if (item.s_mark == "S") {
                            smark = "服務";
                        } else if (item.s_mark == "L") {
                            smark = "證明";
                        } else if (item.s_mark == "M") {
                            smark = "團體標章";
                        } else if (item.s_mark == "N") {
                            smark = "團體商標";
                        } else if (item.s_mark == "K") {
                            smark = "產地證明標章";
                        }
                        $("#s_mark_" + tot_num).val(smark);
                        $("#appl_name_" + tot_num).val(item.cappl_name);

                        if ($("#hrs_code").val() == "FC11" || $("#hrs_code").val() == "FC5" || $("#hrs_code").val() == "FC7" || $("#hrs_code").val() == "FCH" || $("#hrs_code").val() == "FD1") {
                            $("#dref_no_" + tot_num).val(item.apply_no);
                        } else if ($("#hrs_code").val() == "FC21" || $("#hrs_code").val() == "FD2" || $("#hrs_code").val() == "FD3"
                            || $("#hrs_code").val() == "FC6" || $("#hrs_code").val() == "FC8" || $("#hrs_code").val() == "FCI"
                            || $("#hrs_code").val() == "FL5" || $("#hrs_code").val() == "FL6" || $("#hrs_code").val() == "FT2") {
                            $("#dref_no_" + tot_num).val(item.issue_no);
                        }
                        $("#dclass_" + tot_num).val(item.class);
                    })
                },
                error: function (xhr) {
                    $("#dialog").html("<a href='" + this.url + "' target='_new'>取得發文進度子案失敗！<u>(點此顯示詳細訊息)</u></a><hr>" + xhr.responseText);
                    $("#dialog").dialog({ title: '取得發文進度子案失敗！', modal: true, maxHeight: 500, width: "90%" });
                }
            });
        }
    }

    //收費管制
    $("input[name='fees_stat']").click(function () {
        var oval = $(this).val();
        $("#fees_stat").val(oval);
    });

    $(".dateField").blur(function () {
        ChkDate($(this)[0]);
    });

    //發文對象
    $("#send_cl").change(function () {
        var oval=$(this).val();
        $("#send_cl1").val("");
        if(oval=="2"||oval=="B"||oval=="C") $("#send_cl1").val("1");
        if(oval=="3") $("#send_cl1").val("2");
    });
</script>
