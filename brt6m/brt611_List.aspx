<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>

<script runat="server">
    protected string HTProgCap = "國內案文件掃描新增作業";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = HttpContext.Current.Request["prgid"] ?? "";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";

    protected string SQL = "";
    protected object objResult = null;
    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();

    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";

    protected string submitTask = "";
    protected string cgrs = "";

    DBHelper conn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    DBHelper cnn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    private void Page_Unload(System.Object sender, System.EventArgs e) {
        if (conn != null) conn.Dispose();
        if (cnn != null) cnn.Dispose();
    }

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");
        submitTask = ReqVal.TryGet("submittask").ToUpper();
        if (submitTask == "") submitTask = "A";
        
        conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
        cnn = new DBHelper(Conn.Sysctrl).Debug(Request["chkTest"] == "TEST");
        
        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        HTProgCap = myToken.Title.Replace("文件掃描", "<font color=blue>文件掃描</font>");
        DebugStr = myToken.DebugStr;
        if (HTProgRight >= 0) {
            PageLayout();
            QueryData();
            this.DataBind();
        }
    }

    private void PageLayout() {
        StrFormBtnTop += "<a href=\"" + Page.ResolveUrl("~/brt6m/brt612.aspx") + "?prgid=" + prgid + "\" target=\"Etop\">[列印掃描單]</a>\n";
        
        if ((HTProgRight & 4) > 0 && submitTask=="A") {
          StrFormBtn += "<input type=button id='button1' value='新增存檔' class='cbutton bsubmit' onClick='formAddSubmit()'>\n";
        }
    }

    private void QueryData() {
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title><%#HTProgCap%></title>
<link rel="stylesheet" type="text/css" href="<%=Page.ResolveUrl("~/inc/setstyle.css")%>" />
<link rel="stylesheet" type="text/css" href="<%=Page.ResolveUrl("~/js/lib/jquery.datepick.css")%>" />
<link rel="stylesheet" type="text/css" href="<%=Page.ResolveUrl("~/js/lib/toastr.css")%>" />
<link rel="stylesheet" type="text/css" href="<%=Page.ResolveUrl("~/js/lib/jquery-ui.min.css")%>" />
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/jquery-1.12.4.min.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/jquery-ui.min.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/jquery.datepick.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/jquery.datepick-zh-TW.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/toastr.min.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/util.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/client_chk.js")%>"></script>
</head>
<script language="javascript" type="text/javascript">
    var main = {};
    main.branch = "<%#Session["SeBranch"]%>";
    main.prgid = "<%#prgid%>";
    main.right = <%#HTProgRight%>;
    main.submittask = "<%#submitTask%>";
</script>

<body>
<table cellspacing="1" cellpadding="0" width="98%" border="0" align="center">
    <tr>
        <td class="text9" nowrap="nowrap">&nbsp;【<%=prgid%> <%=HTProgCap%>】</td>
        <td class="FormLink" valign="top" align="right" nowrap="nowrap">
            <%#StrFormBtnTop%>
        </td>
    </tr>
    <tr>
        <td colspan="2"><hr class="style-one"/></td>
    </tr>
</table>

<form style="margin:0;" id="reg" name="reg" method="post">
    <input type="hidden" id="prgid" name="prgid" value="<%=prgid%>">
    <input type="hidden" id="submitTask" name="submitTask" value="<%=submitTask%>">
    <input type="hidden" id="seqnum" name="seqnum" value="0"><!--本所編號筆數-->

    <INPUT type="hidden" name="rows_chkflag" id="rows_chkflag">
    <INPUT type="hidden" name="rows_keyseq" id="rows_keyseq">
    <INPUT type="hidden" name="rows_branch" id="rows_branch">
    <INPUT type="hidden" name="rows_oldseq" id="rows_oldseq">
    <INPUT type="hidden" name="rows_oldaseq1" id="rows_oldaseq1">
    <INPUT type="hidden" name="rows_dmt_in_date" id="rows_dmt_in_date">
    <INPUT type="hidden" name="rows_seq" id="rows_seq">
    <INPUT type="hidden" name="rows_aseq1" id="rows_aseq1">
    <INPUT type="hidden" name="rows_step_grade" id="rows_step_grade">
    <INPUT type="hidden" name="rows_cgrs_nm" id="rows_cgrs_nm">
    <INPUT type="hidden" name="rows_scan_num" id="rows_scan_num">

    <table border="0" class="bluetable" cellspacing="1" cellpadding="2" width="100%" align="center" id="dataList">
	    <thead>
	        <TR>
		        <TD class=whitetablebg colspan=6>
			        <input type=button class="cbutton" name="btnadd" id="btnadd" value="新增一筆">
			        <input type=button class="cbutton" name="btndel" id="btndel" value="減少一筆">
		        </TD>
	        </TR>
	        <TR class="lightbluetable">
	            <td align="center">新增</td>     
		        <td align="center">本所編號</td>
		        <td align="center">進度序號</td>
		        <td align="center">掃描份數</td>	
		        <td align="center">進度內容</td>
		        <td align="center">案件名稱</td>
	        </TR>
	    </thead>
	    <tbody></tbody>
        <script type="text/html" id="scan_template"><!--新增掃描樣板-->
		    <TR class="tr_scan_##">
				<td class="whitetablebg" align="center">
                    ##.<input type=checkbox id=chkflag_## value='Y' checked>
				</td>
				<td class="whitetablebg" align="center">
	                <input type='hidden' id='keyseq_##' value='N'>
	                <input type='hidden' id='branch_##'>
	                <input type='hidden' id='oldseq_##'>
	                <input type='hidden' id='oldaseq1_##'>
	                <input type='hidden' id='dmt_in_date_##'>
	                <input type=text size=6 id=seq_## onblur="seq_blur('##')">
	                <input type=text size=1 maxlength=1 id=aseq1_## onblur="seq_blur('##')" value='_'>
	                <input type=button class='cbutton' id='btnQuery_##' onclick="btnQueryClick('##')" title='查詢本所編號' value='查'>
                    <input type=button class='cbutton' id='btncase_##' onclick="btncaseclick('##')" title='案件主檔查詢' value='主'>
				</td>
				<td class="whitetablebg" align="center">
	                <input type='text' size=3 maxlength=3 id='step_grade_##' value=0 class='sedit' readonly>
	                <input type='text' size=4 id='cgrs_nm_##' value='本收' class='sedit' readonly><input type='button' class='c1button' id='btnstep_##' value='查詢' onclick="queryjob('##')">
				</td>
				<td class="whitetablebg" align="center">
	                <input type='text' size=2 maxlength=2 id='scan_num_##' value=1>
                </td>
				<td class="whitetablebg" align="center">
	                <span id="span_rs_detail_##"></span>
                </td>
				<td class="whitetablebg" align="center">
	                <span id="span_appl_name_##"></span>
                </td>
		    </TR>
        </script>
    </table>
	<BR>

    <table border="0" width="98%" cellspacing="0" cellpadding="0">
    <tr>
        <td width="100%" align="center">
            <%#StrFormBtn%>
        </td>
    </tr>
    </table>

    <table border="0" width="100%" cellspacing="0" cellpadding="0">
		<tr class="FormName"><td>
			<div align="left">
                作業步驟:<br>
                1.請先輸入欲新增掃描文件之本所編號，可點選<input type=button class='cbutton' value='查'>查詢本所編號，點選<input type=button class='cbutton' value='主'>查詢案件主檔明細資料。<br>
                2.挑選新增掃描文件所放置的進度，請點選<input type=button class='c1button' value='查詢' id=button2 name=button2>查詢案件進度並選取(若放置進度0，則不需選取)。<br>
                3.輸入掃描份數(即掃描單張數)，因一份掃描文件有250頁限制，若文件超過250頁，請依250頁為單位，輸入所需掃描份數。<br>
                4.系統會依有勾選之案件才會新增掃描文件，若不新增掃描文件，請取消勾選或減少一筆，最後記得按下「新增存檔」。<br>
			</div>
		</td>
        </tr>
	</table>
	<br>

    <%#DebugStr%>
</form>

<div id="dialog"></div>

<iframe id="ActFrame" name="ActFrame" src="about:blank" width="100%" height="500" style="display:none"></iframe>
</body>
</html>

<script language="javascript" type="text/javascript">
    $(function () {
        if (window.parent.tt !== undefined) {
            window.parent.tt.rows = "100%,0%";
        }
        this_init();
    });

    function this_init() {
        $(".Lock").lock();
        $("input.dateField").datepick();

        if (main.submittask == "A") {
            $("#btnadd").click();
        }
    }
    //////////////////////
    //增加一筆
    $("#btnadd").click(function (e) {
        var nRow = CInt($("#seqnum").val()) + 1;
        //複製樣板
        var copyStr = $("#scan_template").text() || "";
        copyStr = copyStr.replace(/##/g, nRow);
        $("#dataList>tbody").append(copyStr);

        $("#seqnum").val(nRow);
        $(".dateField", $('.tr_scan_' + nRow)).datepick();
    });

    //減少一筆
    $("#btndel").click(function (e) {
        var nRow = CInt($("#seqnum").val());
        $('.tr_scan_' + nRow).remove();
        $("#seqnum").val(Math.max(0, nRow - 1));
    });

    //[查詢本所編號]
    function btnQueryClick(nRow) {
        window.open(getRootPath() + "/brtam/brta21Query.aspx?cgrs=CS&seqnum="+ nRow, "myWindowOneN", "width=650 height=420 top=40 left=80 toolbar=no, menubar=no, location=no, directories=no resizeable=no status=no scrollbars=yes");
    }

    //[案件主檔查詢]
    function btncaseclick(nRow) {
        var tseq = $("#seq_" + nRow).val();
        var tseq1 = $("#aseq1_" + nRow).val();
        if (tseq == "") {
            alert("請先輸入本所編號!!!");
            $("#seq_" + nRow).focus();
            return false;
        } else {
            var url = getRootPath() + "/brt5m/brt15ShowFP.aspx?prgid=<%=prgid%>&seq=" + tseq + "&seq1=" + tseq1 + "&cgrs=CS&seqnum="+nRow+"&submittask=Q";
            window.showModalDialog(url, "", "dialogHeight: 540px; dialogWidth: 800px; center: Yes;resizable: No; status: No;scrollbars:yes");
        }
    }

    //查詢對應進度
    function queryjob(nRow){
        var tseq = $("#seq_" + nRow).val();
        var tseq1 = $("#aseq1_" + nRow).val();
        if(tseq1=="") tseq1="_";
        if(tseq==""||tseq1==""){
            alert("請輸入案件編號!!");
            return false;
        }

        var url = getRootPath() + "/brt6m/brt62_steplist.aspx?prgid="+$("#prgid").val()+"&seq=" + tseq+"&seq1=" + tseq1+"&seqnum="+nRow;
        window.open(url, "myWindowOneN", "width=700,height=480,toolbar=yes,menubar=yes,resizable=yes,scrollbars=yes,status=0,top=50,left=80");
    }

    //本所編號抓取資料
    function seq_blur(nRow){
        var seq = $("#seq_"+nRow).val();
        var seq1 = $("#aseq1_"+nRow).val();
        var oldseq = $("#oldseq_"+nRow).val();
        var oldseq1 = $("#oldaseq1_"+nRow).val();

        if (chkNum(seq, "本所編號")) return false;

        if(seq!=""&&seq1!=""){
            if (oldseq==""){
                oldseq = seq;
                oldseq1 = seq1;
                $("#oldseq_"+nRow).val(oldseq);
                $("#oldaseq1_"+nRow).val(oldseq1);
            }

            var dmt_data = {};
            $.ajax({
                type: "get",
                url: getRootPath() + "/ajax/json_dmt.aspx?prgid="+$("#prgid").val()+"&seq=" + seq + "&seq1=" + seq1,
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
                alert(seq+"-"+ seq1+ "不存在於案件主檔內，請重新輸入!!!");
                $("#seq_"+nRow).val("");
                $("#aseq1_"+nRow).val("");
                $("#step_grade_"+nRow).val("0");
                $("#cgrs_nm_"+nRow).val("本收");
                $("#seq_"+nRow).focus();
                return false;
            }

            $("#span_appl_name_"+nRow).html(dmt_data[0].appl_name);
            $("#branch_"+nRow).val(dmt_data[0].cust_area);
            $("#dmt_in_date_"+nRow).val(dmt_data[0].in_date);
            if(seq!=oldseq||seq1!=oldseq1){//案件編號不同，案件進度需重新選取
                $("#step_grade_"+nRow).val("0");
                $("#cgrs_nm_"+nRow).val("本收");
                $("#span_rs_detail_"+nRow).val("");
                alert("修改本所編號，請重新選取對應進度！");
                $("#btnstep_"+nRow).focus();
            }
        }
    }

    //整批確認
    function formAddSubmit(){
        if ($("#seqnum").val() == "0"){
            return false;
        }

        //檢查是否有勾選
        var totnum=$("input[id^='chkflag_']:checked").length;
        if (totnum == 0){
            alert("請勾選您要新增的案件!!");
            return false;
        }

        var isSubmit=true;
        var msg="";

        for (var pno = 1; pno <= CInt($("#seqnum").val()) ; pno++) {
            if($("#chkflag_"+pno).prop("checked")==true){
                if ($("#seq_"+pno).val()==""||$("#aseq1_"+pno).val()==""){
                    msg+="第"+pno+"筆 本所編號必須輸入!!!\n"
                    isSubmit=false;
                }
                if ($("#step_grade_"+pno).val()==""){
                    msg+="第"+pno+"筆 進度序號必須輸入!!!\n"
                    isSubmit=false;
                }
                if ($("#scan_num_"+pno).val()==""||$("#scan_num_"+pno).val()=="0"){
                    msg+="第"+pno+"筆 掃描份數必須輸入!!!\n"
                    isSubmit=false;
                }
            }
        }

        //檢查本所編號有無重覆
        var objSeq = {};
        for (var r = 1; r <= CInt($("#seqnum").val()) ; r++) {
            if($("#chkflag_"+r).prop("checked")==true){
                var vseq = $("#seq_" + r).val();
                var vseq1 = $("#aseq1_" + r).val();
                var vstep_grade = $("#step_grade_" + r).val();
                var lineSeq = vseq + vseq1+vstep_grade;
                if (lineSeq != "_" && objSeq[lineSeq]) {
                    alert("本所編號(" + vseq + "-"+vseq1+")與進度("+vstep_grade+")重複新增，請檢查！");
                    return false;
                } else {
                    objSeq[lineSeq] = { flag: true, idx: r };
                }
            }
        }
	
        if(msg!=""){
            alert(msg);
            return false;
        }
	
        if(!isSubmit){
            return false;
        }
	
        if (!confirm("共有" + totnum + "筆新增 , 是否確定?")) return false;

        //串接資料
        $("#rows_chkflag").val(getJoinValue("#dataList>tbody input[id^='chkflag_']"));
        $("#rows_keyseq").val(getJoinValue("#dataList>tbody input[id^='keyseq_']"));
        $("#rows_branch").val(getJoinValue("#dataList>tbody input[id^='branch_']"));
        $("#rows_oldseq").val(getJoinValue("#dataList>tbody input[id^='oldseq_']"));
        $("#rows_oldaseq1").val(getJoinValue("#dataList>tbody input[id^='oldaseq1_']"));
        $("#rows_dmt_in_date").val(getJoinValue("#dataList>tbody input[id^='dmt_in_date_']"));
        $("#rows_seq").val(getJoinValue("#dataList>tbody input[id^='seq_']"));
        $("#rows_aseq1").val(getJoinValue("#dataList>tbody input[id^='aseq1_']"));
        $("#rows_step_grade").val(getJoinValue("#dataList>tbody input[id^='step_grade_']"));
        $("#rows_cgrs_nm").val(getJoinValue("#dataList>tbody input[id^='cgrs_nm_']"));
        $("#rows_scan_num").val(getJoinValue("#dataList>tbody input[id^='scan_num_']"));
        
        //$("select,textarea,input,span").unlock();
        $("input:disabled, select:disabled").unlock();
        $(".bsubmit").lock(!$("#chkTest").prop("checked"));
        
        var formData = new FormData($('#reg')[0]);
        ajaxByForm("Brt611_Update.aspx",formData)
        .complete(function( xhr, status ) {
            $("#dialog").html(xhr.responseText);
            $("#dialog").dialog({
                title: '存檔訊息',modal: true,maxHeight: 500,width: 800,closeOnEscape: false
                ,buttons: {
                    確定: function() {
                        $(this).dialog("close");
                    }
                }
                ,close:function(event, ui){
                    if(status=="success"){
                        if(!$("#chkTest").prop("checked")){
                            window.parent.tt.rows="100%,0%";
                            window.parent.Etop.goSearch();//重新整理
                        }
                    }
                }
            });
        });
    }
</script>