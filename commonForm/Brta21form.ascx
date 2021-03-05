<%@ Control Language="C#" ClassName="brta21form" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Data"%>

<script runat="server">
    //案件主檔欄位畫面，與收文共同
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
        if (prgid != "brta21" || prgid == "brta24") {
            Lock["QLock"] = "Lock";
        }
    }
</script>

<%=Sys.GetAscxPath(this.AppRelativeVirtualPath)%>
<input type="text" id="now_grade" name="now_grade">
<input type="text" id="now_arcase" name="now_arcase">
<input type="text" id="now_stat" name="now_stat">

<TABLE id=tabbr style="display:" border=0 class="bluetable"  cellspacing=1 cellpadding=2 width="100%">
	<%if (prgid=="brta24"){%>><!--官收確認****todo-->
	<TR>
		<TD class=lightbluetable align=right nowrap>作業選項：</td>
		<td class=whitetablebg colspan=5>
			<input type=radio name=domark id=domarkA value="A" onclick="brta21form.domark(this.value)">需立子案
			<input type=button class="c1button" name="btnnewseq" id="btnnewseq" value="子案立案" onclick="brta21form.btnnewseq()">
			<input type=radio name=domark id=domarkB value="B" onclick="brta21form.domark(this.value)">已立案
			<input type=radio name=domark id=domarkX value="X" onclick="brta21form.domark(this.value)">本案收文
		    <input type=text id="hdomark" name="hdomark" value="X">
		</TD>
		<TD align=right  class=whitetablebg>
			<input type=button name="getmgdmt" id="getmgdmt" class="cbutton" value="核對總收發主檔檢核資料" onclick="brta21form.btnmgdmt('nseq')"><!--***todo brta21form.btnmgdmt('')-->
		</TD>
	</TR>
	<%}%>
	<TR>
		<TD class=lightbluetable align=right nowrap>本所編號：</TD>
		<TD class=whitetablebg>
			<input type="text" id="keyseq" name="keyseq" value="N">
			<input type="text" id="oldseq" name="oldseq">
			<input type="text" id="oldseq1" name="oldseq1">
			<input type="text" id="s_mark" name="s_mark">
			<input type="text" id="grseq" name="grseq"><!--官收案號for官收立子案之原案號-->
			<input type="text" id="grseq1" name="grseq1"><!--官收案號for官收立子案之原案號-->
			<input type="text" id="seq" name="seq" size=6 maxlength="<%#Sys.DmtSeq%>">-
			<input type="text" id="seq1" name="seq1" size=1 maxlength="<%#Sys.DmtSeq1%>">
			<input type=button class="cbutton" id="btnseq" name="btnseq" value ="確定" onclick="brta21form.btnseq()">
		</td>
		<TD class=whitetablebg>
			<input type=button class="cbutton" id="btnQuery" name="btnQuery" value ="查詢本所編號" onclick="brta21form.btnQuery()">
			<input type=button class="cbutton" id="btncase" name="btncase"  value ="案件主檔查詢" onclick="brta21form.btncase()">
		</TD>
		<TD class=lightbluetable align=right nowrap>客戶卷號：</TD>
		<TD class=whitetablebg><input type="text" id="cust_prod" name="cust_prod" class="sedit" readonly size=25></TD>
		<TD class=lightbluetable align=right nowrap>立案日期：</TD>
		<TD class=whitetablebg>
		<input type="text" id="in_date" name="in_date" class="sedit" readonly size=10>
		&nbsp;&nbsp;進度：		
		<input type="text" id="step_grade" name="step_grade" size=5 class="sedit" readonly>
		</TD>
	</TR>
	<TR>
		<TD class=lightbluetable align=right>案件名稱：</TD>
		<TD class=whitetablebg colspan=4>
			<input type="text" id="appl_name" name="appl_name" class="sedit" readonly size=50>
		</TD>
		<TD class=lightbluetable align=right>立案案性：</TD>
		<TD class=whitetablebg><input type="text" id="arcase" name="arcase" class="sedit" readonly size=25></TD>
	</TR>
	<TR>
		<TD class=lightbluetable align=right>客戶名稱：</TD>
		<TD class=whitetablebg colspan=4>
			<input type="text" id="att_sql" name="att_sql">
			<input type="text" id="cust_area" name="cust_area" class="sedit" readonly size=1>-
			<input type="text" id="cust_seq" name="cust_seq" size=6 class="sedit" readonly>
			<input type="text" id="cust_name" name="cust_name" class="sedit" size=40 readonly>
		</TD>
		<TD class=lightbluetable align=right>類別：</TD>
		<TD class=whitetablebg>(共<input type="text" id="class_count" name="class_count" class="sedit" readonly size=2>類) 
		                         <input type="text" id="class1" name="class1" class="sedit" readonly size=13></TD>
	</TR>
	<TR>
		<TD class=lightbluetable align=right>申請人：</TD>
		<TD class=whitetablebg colspan=4>
			<input type="text" id="apcust_no" name="apcust_no" class="sedit" readonly size=11>
			<input type="text" id="ap_cname" name="ap_cname" class="sedit" size=40 readonly>
			<input type="text" id="dmtap_cname" name="dmtap_cname" class="sedit" size=60 readonly>
		</TD>	
		<TD class=lightbluetable align=right rowspan=2>案件狀態：</TD>	
		<TD class=whitetablebg><input type="text" id="now_arcasenm" name="now_arcasenm" size=20 class="sedit" readonly></TD>
		</TR>
	<TR>
		<TD class=lightbluetable align=right>出名代理：</TD>
		<TD class=whitetablebg ><input type="text" id="agt_no" name="agt_no" size=8 class="sedit" readonly></TD>
		<TD class=lightbluetable align=right>營洽：</TD>
		<TD class=whitetablebg colspan=2><input type="text" id="scode" name="scode" size=12 class="sedit" readonly></TD>	    
		<TD class=whitetablebg><input type="text" id="case_stat" name="case_stat" size=20 class="sedit" readonly></TD>
		</TR>
	<TR>
		<TD class=lightbluetable align=right>申請日期：</TD>
		<TD class=whitetablebg>
            <input type="text" id="apply_date" name="apply_date" size=10 maxlength=10 class="dateField <%#Lock.TryGet("QLock")%>">
		</TD>
		<TD class=lightbluetable align=right>申請號碼：</TD>
		<TD class=whitetablebg colspan=2><input type="text" id="apply_no" name="apply_no" size=15 maxlength=20 class="<%#Lock.TryGet("QLock")%>"></TD>
		<TD class=lightbluetable align=right>相關案號：</TD>
		<TD class=whitetablebg>
			<input type="text" id="ref_no1" name="ref_no1" size=5 class="sedit" readonly style="cursor:pointer" onclick=brta21form.RefnoClick()>-
			<input type="text" id="ref_no11" name="ref_no11" size=1 class="sedit" readonly style="cursor:pointer" onclick=brta21form.RefnoClick()>
		</TD>
	</TR>
	<TR>
		<TD class=lightbluetable align=right>註冊日期：</TD>
		<TD class=whitetablebg>
            <input type="text" id="issue_date" name="issue_date" size=10 maxlength=10 class="dateField <%#Lock.TryGet("QLock")%>">
		</TD>
		<TD class=lightbluetable align=right>註冊號碼：</TD>
		<TD class=whitetablebg colspan=2><input type="text" id="issue_no" name="issue_no" size=15 maxlength=20 class="<%#Lock.TryGet("QLock")%>"></TD>
		<TD class=lightbluetable align=right>母案案號：</TD>
		<TD class=whitetablebg>
			<input type="text" id="mseq" name="mseq" size=5 class="sedit" readonly style="cursor:pointer" onclick=brta21form.MSeqClick()>-
			<input type="text" id="mseq1" name="mseq1" size=1 class="sedit" readonly style="cursor:pointer" onclick=brta21form.MSeqClick()>
		</TD>
	</TR>
	<TR>
		<TD class=lightbluetable align=right>公告日期：</TD>
		<TD class=whitetablebg>
            <input type="text" id="open_date" name="open_date" size=10 maxlength=10 class="dateField <%#Lock.TryGet("QLock")%>">
		</TD>		
		<TD class=lightbluetable align=right>核駁號碼：</TD>
		<TD class=whitetablebg colspan=2><input type="text" id="rej_no" name="rej_no" size=15 maxlength=20 class="<%#Lock.TryGet("QLock")%>"></TD>
		<TD class=lightbluetable align=right>結案日期：</TD>
		<TD class=whitetablebg><input type="text" id="end_date" name="end_date" size=10 class="sedit" readonly>-
			<input type="text" id="end_code" name="end_code" size=1 class="sedit" readonly>
			<input type="text" id="end_name" name="end_name" >
			原因：<input type="text" id="end_remark" name="end_remark" size=20 class="sedit" readonly>
		</TD>
		</TR>
	<TR>
		<TD class=lightbluetable align=right>專用期限：</TD>
		<TD class=whitetablebg colspan=2 nowrap>
            <input type="text" id="term1" name="term1" size=10 maxlength=10 class="dateField <%#Lock.TryGet("QLock")%>">
			~
			<input type="text" id="term2" name="term2" size=10 maxlength=10 class="dateField <%#Lock.TryGet("QLock")%>">
		</TD>
		<TD class=lightbluetable align=right>延展次數：</TD>
		<TD class=whitetablebg><input type="text" id="renewal" name="renewal" class="<%#Lock.TryGet("QLock")%>" size=2 maxlength=2 /></TD>
		<TD class=lightbluetable align=right>註冊費已繳：</TD>
		<TD class=whitetablebg>
			<input type="text" id="opay_times" name="opay_times">
			<input type="text" id="hpay_times" name="hpay_times">
	   		<Select NAME="pay_times" id="pay_times" class="Lock"><%#html_pay_times%></SELECT>
			<input type="text" id="opay_date" name="opay_date" size=10 maxlength=10 class="sedit" readonly>
			<input type="text" id="pay_date" name="pay_date" size=10 maxlength=10 class="sedit" readonly>
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
					<input type="text" id="tran_seq_branch" name="tran_seq_branch" size="1" class="Lock">
					<input type="text" id="tran_seq" name="tran_seq" size=5 readonly class="sedit">
					<input type="text" id="tran_seq1" name="tran_seq1" size="3" readonly class="sedit">
					<span style="cursor: pointer;background-color:lightbluetable3" title="進度查詢" onmouseover="this.style.color='red'" onmouseout="this.style.color='black'" onclick="brta21form.Qstep()"><img src="<%=Page.ResolveUrl("~/images/annex.gif")%>"><span>
			</td>
			<td class="lightbluetable"  align="right">轉案說明：</td>
			<td class="whitetablebg" >
				<input type="text" id="tran_remark" name="tran_remark" size="20" readonly class="sedit">
			</td>
		</tr>
</table>


<script language="javascript" type="text/javascript">
    var brta21form = {};

    brta21form.init = function () {
        if($("#submittask").val()=="U"||$("#submittask").val()=="Q"||$("#submittask").val()=="D"||$("#submittask").val()=="R"){
            $("#seq,#seq1").lock().triggerHandler("change");
            $("#btnseq").hide();//[確定]
            $("#btnQuery").hide();//[查詢本所編號]
            $("#btnnewseq").hide();//子案立案
        }
    }

    //[確定]
    brta21form.btnseq=function () {
        if($("#seq").val()==""){
            alert("本所編號未輸入!!!");
            $("#seq").focus();
            return false;
        }
        if (chkNum($("#seq").val(), "本所編號")) return false;

        var dmt_data = {};
        $.ajax({
            type: "get",
            url: getRootPath() + "/ajax/json_dmt.aspx?seq=" + $("#seq").val() + "&seq1=" + $("#seq1").val(),
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
            alert($("#seq").val()+"-"+ $("#seq1").val()+ "不存在於案件主檔內，請重新輸入!!!");
            return false;
        }

        if(dmt_data[0].rmarkcode!=""&&dmt_data[0].rmarkcode!="___"&&$("#cgrs").val()!="GR" &&$("#cgrs").val()!="CS"){
            alert(dmt_data[0].cust_area+dmt_data[0].cust_seq+"債信不良不可收發文，請重新輸入!!!");
            if($("#submittask").val()!="Q"){
                $("#seq").val("").focus();
                return false;
            }
        }
        $("#appl_name").val(dmt_data[0].appl_name);
        $("#s_mark").val(dmt_data[0].s_mark);
        $("#class1").val(dmt_data[0].class.CutData(10)).attr("title",dmt_data[0].class);
        $("#cust_area").val(dmt_data[0].cust_area);
        $("#cust_seq").val(dmt_data[0].cust_seq);
        $("#cust_name").val(dmt_data[0].cust_name);
        $("#agt_no").val(dmt_data[0].agt_no);
        $("#scode").val(dmt_data[0].scodenm);
        $("#apply_date").val(dateReviver(dmt_data[0].apply_date,'yyyy/M/d'));
        $("#apply_no").val(dmt_data[0].apply_no);
        var ar_ref=dmt_data[0].ref_no1.split("-");
        if(ar_ref.count>=1) $("#ref_no1").val(ar_ref[0]);
        if(ar_ref.count>=2) $("#ref_no11").val(ar_ref[1]);
        $("#issue_date").val(dateReviver(dmt_data[0].issue_date,'yyyy/M/d'));
        $("#issue_no").val(dmt_data[0].issue_no);
        $("#step_grade").val(dmt_data[0].step_grade);
        $("#open_date").val(dateReviver(dmt_data[0].open_date,'yyyy/M/d'));
        $("#rej_no").val(dmt_data[0].rej_no);
        $("#term1").val(dateReviver(dmt_data[0].term1,'yyyy/M/d'));
        $("#term2").val(dateReviver(dmt_data[0].term2,'yyyy/M/d'));
        $("#end_date").val(dateReviver(dmt_data[0].end_date,'yyyy/M/d'));
        $("#end_code").val(dmt_data[0].end_code);
        $("#in_date").val(dateReviver(dmt_data[0].in_date,'yyyy/M/d'));
        $("#case_stat").val(dmt_data[0].now_statnm);
        $("#apcust_no").val(dmt_data[0].ap_apcust_no);
        $("#ap_cname").val(dmt_data[0].ap_cname);
        $("#arcase").val(dmt_data[0].arcasenm);
        $("#now_arcasenm").val(dmt_data[0].now_arcasenm);
        $("#class_count").val(dmt_data[0].class_count);
        $("#mseq").val(dmt_data[0].mseq);
        $("#mseq1").val(dmt_data[0].mseq1);
        $("#renewal").val(dmt_data[0].renewal);
        $("#att_sql").val(dmt_data[0].att_sql);
        $("#now_grade").val(dmt_data[0].now_grade);
        $("#now_arcase").val(dmt_data[0].now_arcase);
        $("#now_stat").val(dmt_data[0].now_stat);
        $("#rs_class").val(dmt_data[0].now_rsclass).triggerHandler("change");
        $("#nstep_grade").val(CInt(dmt_data[0].step_grade)+1);
        $("#rs_code").val($("#now_arcase").val()).triggerHandler("change");

        $("#opay_times,#hpay_times,#pay_times").val(dmt_data[0].pay_times);
        $("#opay_date,#pay_date").val(dateReviver(dmt_data[0].pay_date,'yyyy/M/d'));
        $("#dmtap_cname").val(dmt_data[0].dmtap_cname);
        $("#end_name").val(dmt_data[0].end_codenm);
        $("#end_remark").val(dmt_data[0].end_remark);
        $("input[name='tran_flag'][value='"+dmt_data[0].tran_flag+"']").prop("checked",true);
        $("#tran_seq_branch").val(dmt_data[0].tran_seq_branch);
        $("#tran_seq").val(dmt_data[0].tran_seq);
        $("#tran_seq1").val(dmt_data[0].tran_seq1);
        $("#tran_remark").val(dmt_data[0].tran_remark);
        $("#cust_prod").val(dmt_data[0].cust_prod);

        //$("#oldseq,#grseq,#seq").val(dmt_data[0].seq);
        //$("#oldseq1,#grseq1,#seq1").val(dmt_data[0].seq1);
        $("#oldseq,#grseq").val(dmt_data[0].seq);
        $("#oldseq1,#grseq").val(dmt_data[0].seq1);
        $("#keyseq").val("Y");//有按確定給Y
        $("#btnseq").lock();

        if($("#end_date").val()!=""){
            alert("該案件已結案!!!");
            if($("#submittask").val()!="Q" && $("#cgrs").val()=="GS"){
                if($("#task").val()!="cancel"){
                    $("#button1").lock();
                }
            }
        }
    }

    //[查詢本所編號]
    brta21form.btnQuery=function () {
        window.open(getRootPath() + "/brt1m/brta21Query.aspx", "myWindowOneN", "width=650 height=420 top=40 left=80 toolbar=no, menubar=no, location=no, directories=no resizeable=no status=no scrollbars=yes");
    }

    //[案件主檔查詢]
    brta21form.btncase=function(){
        if ($("#seq").val() == "") {
            alert("請先輸入本所編號!!!");
            return false;
        }

        //2011/6/13因新單位進度查詢連結原單位案件進度查詢時，點選案件主檔查詢要連回原單位，所以增加type=brtran&branch
        var breakflag=false;
        $.ajax({
            type: "get",
            url: getRootPath() + "/ajax/_dmt.aspx?prgid=brta21&seq="+$("#seq").val()+"&seq1="+$("#seq1").val()+"&type=<%=Request["type"]%>&branch=<%=Request["branch"]%>",
            async: false,
            cache: false,
            success: function (json) {
                var JSONdata = $.parseJSON(json);
                if (JSONdata.length == 0) {
                    alert($("#seq").val()+  "-" + $("#seq1").val()+ "不存在於案件主檔內，請重新輸入!!!");
                    breakflag=true;
                }
            },
            error: function (xhr) {
                $("#dialog").html("<a href='" + this.url + "' target='_new'>案件資料載入失敗！<u>(點此顯示詳細訊息)</u></a><hr>" + xhr.responseText);
                $("#dialog").dialog({ title: '案件資料載入失敗！', modal: true, maxHeight: 500, width: "90%" });
            }
        });

        if(breakflag==false){
            window.open(getRootPath() +"/brt5m/brt15ShowFP.aspx?submittask=Q&seq=" + $("#seq").val() + "&seq1=" + $("#seq1").val() + "&type=<%=Request["type"]%>&branch=<%=Request["branch"]%>&prgid=<%=prgid%>&winact=Y","DmtmyWindowOne","width=800 height=520 top=40 left=80 toolbar=no, menubar=no, location=no, directories=no resizeable=no status=no scrollbars=yes");
        }
    }

    //相關案號
    brta21form.RefnoClick=function(){
        if($("#ref_no1").val()!=""&&$("#ref_no11").val()!=""){
            //***todo
            window.showModalDialog(getRootPath() +"\commonForm\brta21Qdmt.aspx?seq=" +$("#ref_no1").val()+ "&seq1=" +$("#ref_no11").val() ,"","dialogHeight: 520px; dialogWidth: 800px; center: Yes;resizable: No; status: No;scrollbars=yes");
        }
    }

    //母案案號
    brta21form.MSeqClick=function(){
        if($("#mseq").val()!=""&&$("#mseq1").val()!=""){
            //***todo
            window.showModalDialog(getRootPath() +"\commonForm\brta21Qdmt.aspx?seq=" +$("#mseq").val()+ "&seq1=" +$("#mseq1").val() ,"","dialogHeight: 520px; dialogWidth: 800px; center: Yes;resizable: No; status: No;scrollbars=yes");
        }
    }

    $("#seq,#seq1").blur(function () {
        if($("#oldseq").val()!=$("#seq").val()||$("#oldseq1").val()!=$("#seq1").val()){
            $("#keyseq").val("N");//有變動給N
        }else{
            $("#keyseq").val("Y");//無變動給Y
        }
    });

    $("#seq,#seq1").change(function (e) {
        $("#btnseq").unlock();
    });

    $("#apply_date,#issue_date,#term1,#term2").blur(function (e) {
        ChkDate(this);
    });

    $("#apply_no").blur(function (e) {
        chk_dmt_applyno($(this)[0],9);
    });

    $("#issue_no").blur(function (e) {
        chk_dmt_issueno($(this)[0],8);
    });

    $("#rej_no").blur(function (e) {
        chk_dmt_rejno($(this)[0],7);
    });

    //[核對總收發主檔檢核資料]
    brta21form.btnmgdmt=function(pchk){
        //存檔時檢查
        if (pchk=="chk") {
            var isql="";
            if ($("#hdomark").val()=="A" || $("#hdomark").val()=="B"){
                isql="select a.gno_date as mg_apply_date,a.gno as mg_apply_no,b.issue_date as mg_issue_date,b.issue_no2 as mg_issue_no,b.issue_no3 as mg_rej_no,b.end_date as mg_end_date ";
                isql +=" from mgt_temp b,step_mgt_temp a ";
                isql+= " where a.temp_rs_sqlno=b.temp_rs_sqlno and b.temp_rs_sqlno=" +$("#temp_rs_sqlno").val();
            }else{
                isql="select b.apply_date as mg_apply_date,b.apply_no as mg_apply_no,b.issue_date as mg_issue_date,b.issue_no2 as mg_issue_no,b.issue_no3 as mg_rej_no,b.end_date as mg_end_date ";
                isql+= " from mgt_temp b ";
                isql+= " where b.temp_rs_sqlno=" +$("#temp_rs_sqlno").val();
            }

            var mg_apply_date = "",mg_apply_no = "",mg_issue_date = "",mg_issue_no = "",mg_rej_no = "",mg_end_date = "";
            $.ajax({
                type: "get",
                url: getRootPath() + "/ajax/JsonGetSqlData.aspx",
                data: { sql: isql },
                async: false,
                cache: false,
                success: function (json) {
                    var JSONdata = $.parseJSON(json);
                    if (JSONdata.length > 0) {
                        mg_apply_date = dateReviver(JSONdata[0].mg_apply_date,'yyyy/M/d');
                        mg_apply_no = JSONdata[0].mg_apply_no;
                        mg_issue_date = dateReviver(JSONdata[0].mg_issue_date,'yyyy/M/d');
                        mg_issue_no = JSONdata[0].mg_issue_no;
                        mg_rej_no = JSONdata[0].mg_rej_no;
                        mg_end_date = dateReviver(JSONdata[0].mg_end_date,'yyyy/M/d');
                    }else{
                        alert("找不到總管處案件主檔資料，請通知系統維護人員!!");
                    }
                }
            });

            var cansave_flag = "Y";
            //申請日期
            if ($("#apply_date").val()!=mg_apply_date){
                cansave_flag = "N";
            }
            //申請號
            if ($("#apply_no").val()!=mg_apply_no){
                cansave_flag = "N"
            }
            //註冊號
            if ($("#issue_no").val()!=mg_issue_no){
                if($("#smgt_temp_mark").val()!="IS"){
                    cansave_flag = "N"
                }
            }
            //核駁號
            if ($("#rej_no").val()!=mg_rej_no){
                cansave_flag = "N"
            }

            if (cansave_flag == "N"){
                $("#cansave").val("N");
                alert("案件主檔檢核資料與總收發主檔不符，請檢查！");
            }else{
                var mg_ctrl_date = "",mg_ctrl_type = "";
                //檢查法定期限
                isql="select ctrl_date,ctrl_type from ctrl_mgt_temp where temp_rs_sqlno=" +$("#temp_rs_sqlno").val()+ " and left(ctrl_type,1)='A' ";
                $.ajax({
                    type: "get",
                    url: getRootPath() + "/ajax/JsonGetSqlData.aspx",
                    data: { sql: isql },
                    async: false,
                    cache: false,
                    success: function (json) {
                        var JSONdata = $.parseJSON(json);
                        if (JSONdata.length > 0) {
                            mg_ctrl_date = dateReviver(JSONdata[0].ctrl_date,'yyyy/M/d');
                            mg_ctrl_type = JSONdata[0].ctrl_type;
                        }else{
                            alert("找不到總管處期限管制資料，請通知系統維護人員!!");
                        }
                    }
                });

                if(mg_ctrl_date!=""){
                    var havectrl_flag="N";
                    for (var n = 1; n <= CInt($("#ctrlnum").val()) ;n++) {
                        var ctrl_type= $("#ctrl_type_" + n).val();
                        var ctrl_date= $("#ctrl_date_" + n).val();
                        if (ctrl_type!="" && ctrl_date!="" && ctrl_type==mg_ctrl_type && ctrl_date==mg_ctrl_date){
                            havectrl_flag=="Y";
                            break;
                        }
                    }
                    if(havectrl_flag=="N"){
                        $("#cansave").val("N");
                        alert("期限管制資料與總收發不符，請檢查！");
                    }else{
                        $("#cansave").val("Y");
                        return false;
                    }
                }else{
                    $("#cansave").val("Y");
                    return false;
                }
            }
        }
        //立子案檢查
        if (pchk=="nseq") {
            if($("input[name='domark']:checked").length==0){
                alert("請先點選「作業選項」並確認本次收文案件編號後，再執行核對總收發主檔資料！");
                return false;
            }
        }
        var requlink = "&seq="+ $("#seq").val() +"&seq1="+ $("#seq1").val()+"&temp_rs_sqlno=" + $("#temp_rs_sqlno").val();
        requlink+= "&apply_no=" + $("#apply_no").val() +"&apply_date=" +$("#apply_date").val();
        requlink+= "&issue_no=" + $("#issue_no").val() +"&issue_date=" +$("#issue_date").val();
        requlink+= "&rej_no=" + $("#rej_no").val();
        requlink+= "&end_date=" + $("#end_date").val();
        requlink+= "&domark=" + $("#hdomark").val();
        requlink+= "&smgt_temp_mark=" + $("#smgt_temp_mark").val();
        //***todo
        window.open(getRootPath() +"/brtam/brtaform/brtachkdmt.aspx?prgid=<%=prgid%>"+requlink,"", "width=900 height=700 top=20 left=20 toolbar=no, menubar=no, location=no, directories=no resizeable=no status=no scrollbars=yes");
    }

    //官收立子案的作業處理
    brta21form.domark=function(pvalue){
        $("#hdomark").val(pvalue);
        switch (pvalue) {
            case 'A':
                alet("若確定要立子案並以子案收文，請先點選「子案立案」立案完成後再執行官收確認！");
                $("#btnseq,#btnnewseq").show();//[確定]
                break;
            case 'B':
                alet("若確定以子案收文且子案已立案，請輸入子案編號並點選確定後後再執行官收確認！");
                $("#seq,#seq1").unlock();
                $("#btnseq,#btnQuery").show();//[確定][查詢本所編號]
                $("#btnnewseq").hide();//[子案立案]
                break;
            case 'X':
                $("#seq").val($("#grseq").val()).lock();
                $("#seq1").val($("#grseq1").val()).lock();
                $("#btnseq,#btnQuery,#btnnewseq").hide();//[確定][查詢本所編號][子案立案]
                break;
        }
    }

    //官收立案[子案立案]
    brta21form.btnnewseq=function(){
        window.open(getRootPath() +"/brt5m/brt15ShowFP.aspx?submittask=A&seq=" + $("#grseq").val() + "&seq1=" + $("#grseq1").val() + "&cgrs=" + $("#cgrs").val()+ "&rs_type=" + $("#rs_type").val() + "&rs_code="+ $("#rs_code").val() + "&prgid=<%=prgid%>&winact=Y","DmtmyWindowOne","width=1000 height=800 top=40 left=80 toolbar=no, menubar=no, location=no, directories=no resizeable=no status=no scrollbars=yes");
        $("#btnseq").unlock();
        $("#keyseq").val("N");
    }

    //查詢轉案進度
    brta21form.Qstep=function(){
        x1 = $("#tran_seq").val()||"";
        x2 = $("#tran_seq1").val()||"";
        x3 = $("#tran_seq_branch").val()||"";
        if (x1=="" ||x2==""||x3==""){
            alert("無轉案單位資料，無法查詢進度！");
            return false;
        }
        //***todo
        window.open(getRootPath() +"/brtam/brta61Edit.aspx?aseq=" + x1 + "&aseq1=" + x2 + "&branch=" +x3+ "&submittask=Q&FrameBlank=50&prgid=<%=prgid%>&closewin=Y&winact=1&type=brtran","","dialogHeight: 520px; dialogWidth: 960px; center: Yes;resizable: No; status: No;scrollbars=yes");
    }
</script>
