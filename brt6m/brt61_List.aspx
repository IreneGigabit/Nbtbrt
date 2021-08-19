<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<script runat="server">
    protected string HTProgCap = "國內案文件掃描確認作業";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = HttpContext.Current.Request["prgid"] ?? "";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";

    protected string SQL = "";
    protected object objResult = null;
    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected Paging page = null;

    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";
    protected string FormName = "";

    protected string qryStep_DateE = "", qrypr_scan_status="";
    
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

        conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
        cnn = new DBHelper(Conn.Sysctrl).Debug(Request["chkTest"] == "TEST");

        qryStep_DateE = Request["qryStep_DateE"] ?? "";
        if (qryStep_DateE == "") qryStep_DateE = DateTime.Today.ToShortDateString();
        qrypr_scan_status = Request["qrypr_scan_status"] ?? "";
        if (qrypr_scan_status == "") qrypr_scan_status = "N";

        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        HTProgCap = myToken.Title;
        DebugStr = myToken.DebugStr;
        if (HTProgRight >= 0) {
            PageLayout();
            QueryData();
            this.DataBind();
        }
    }

    private void PageLayout() {
        StrFormBtnTop += "<a class=\"imgRefresh\" href=\"javascript:void(0);\" >[重新整理]</a>";

        if ((HTProgRight & 4) > 0 || (HTProgRight & 8) > 0) {
            StrFormBtn += "<br>\n";
            StrFormBtn += "<input type=button value ='掃描確認' class='cbutton bsubmit' onclick=\"formAddSubmit('conf')\">\n";
            StrFormBtn += "<input type=button value ='取消掃描' class='redbutton bsubmit' onclick=\"formAddSubmit('cancel')\">\n";
            StrFormBtn += "<input type=button value ='重　填' class='cbutton' onclick='this_init()'>\n";
        }
    }

    private void QueryData() {
        SQL = "select a.rs_sqlno,a.branch,a.seq,a.seq1,a.step_grade,a.rs_detail,a.cg,a.rs";
        SQL += ",a.cappl_name as appl_name,a.rs_no,a.step_date,a.pr_scan,b.attach_sqlno,b.attach_no,b.attach_desc,b.chk_page,b.chk_date,b.attach_path,b.attach_name";
        SQL += ",''fseq,'' pr_scan1,''lcg,''lrs,''pr_scan_path,''pr_scan_flag,''tstyle,''scanfile_title";
        SQL += " from vstep_dmt a inner join dmt_attach b on a.seq=b.seq and a.seq1=b.seq1 and a.step_grade=b.step_grade ";
        SQL += " where b.source='scan' and b.attach_flag<>'D' ";

        if (qrypr_scan_status != "") SQL += " and b.chk_status like '" + qrypr_scan_status + "%'";
        if ((Request["qryStep_dateS"] ?? "") != "") SQL += " and a.Step_Date>='" + Request["qryStep_dateS"] + "'";
        if (qryStep_DateE != "") SQL += " and a.Step_Date<='" + qryStep_DateE + "'";
        if ((Request["qrySeq"] ?? "") != "") SQL += " and a.Seq in ('" + Request["qrySeq"].Replace(",", "','") + "')";
        if ((Request["qrySeq1"] ?? "") != "") SQL += " and a.Seq1='" + Request["qrySeq1"] + "'";
        if ((Request["qryin_dateS"] ?? "") != "") SQL += " and b.in_Date>='" + Request["qryin_dateS"] + " 00:00:00'";
        if ((Request["qryin_dateE"] ?? "") != "") SQL += " and b.in_Date<='" + Request["qryin_dateE"] + " 23:59:59'";

        ReqVal["qryOrder"] = ReqVal.TryGet("SetOrder", ReqVal.TryGet("qryOrder", "a.seq,a.seq1,a.step_date"));
        if (ReqVal.TryGet("qryOrder") != "") {
            SQL += " order by " + ReqVal.TryGet("qryOrder");
        }
        Sys.showLog(SQL);
        DataTable dt = new DataTable();
        conn.DataTable(SQL, dt);

        //處理分頁
        int nowPage = Convert.ToInt32(Request["GoPage"] ?? "1"); //第幾頁
        int PerPageSize = Convert.ToInt32(Request["PerPage"] ?? "20"); //每頁筆數
        page = new Paging(nowPage, PerPageSize, SQL);
        page.GetPagedTable(dt);

        //分頁完再處理其他資料才不會虛耗資源
        for (int i = 0; i < page.pagedTable.Rows.Count; i++) {
            DataRow dr = page.pagedTable.Rows[i];

            //案號
            dr["fseq"] = Sys.formatSeq(dr.SafeRead("seq", ""), dr.SafeRead("seq1", ""), "", Sys.GetSession("seBranch"), Sys.GetSession("dept"));

            //收發種類
            if (dr.SafeRead("cg", "") == "C") {
                dr["lcg"] = "客";
            } else if (dr.SafeRead("cg", "") == "G") {
                dr["lcg"] = "官";
            } else {
                dr["lcg"] = "本";
            }

            if (dr.SafeRead("rs", "") == "R" || dr.SafeRead("rs", "") == "Z") {
                dr["lrs"] = "收";
            } else {
                dr["lrs"] = "發";
            }

            //檢查是否已掃描
            dr["pr_scan_path"] = Sys.Path2Nbtbrt(dr.SafeRead("attach_path", ""));
            if (Sys.CheckFile(dr.SafeRead("pr_scan_path", "")) == true) {
                dr["pr_scan_flag"] = "Y";
                dr["tstyle"] = "display:";
                dr["scanfile_title"] = "有文件";
                dr["pr_scan1"] = "Y";
            } else {
                dr["pr_scan_flag"] = "N";
                dr["tstyle"] = "display:none";
                dr["scanfile_title"] = "尚未掃描";
                dr["pr_scan1"] = "N";
            }
        }

        dataRepeater.DataSource = page.pagedTable;
        dataRepeater.DataBind();
    }

    //頁數
    protected string GetPage(RepeaterItem Container) {
        string pr_scan_flag = Eval("pr_scan_flag").ToString();
        if (pr_scan_flag == "Y") {
            return Eval("chk_page").ToString();
        } else {
            return "0";
        }
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title><%#HTProgCap%></title>
    <uc1:head_inc_form runat="server" ID="head_inc_form" />
</head>
<script language="javascript" type="text/javascript">
    var main = {};
    main.branch = "<%#Session["SeBranch"]%>";
    main.prgid = "<%#prgid%>";
    main.right = <%#HTProgRight%>;
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

<form style="margin:0;" id="regPage" name="regPage" method="post">
    <table border="0" cellspacing="1" cellpadding="2" width="100%">
        <tr>
            <td class="text9">
		        ◎新增掃描日期: <input type="text" name="qryin_DateS" size="10" value="<%#ReqVal.TryGet("qryin_DateS")%>" class="dateField">
                ~
                <input type="text" id="qryin_DateE" name="qryin_DateE" size="10" value="<%#ReqVal.TryGet("qryin_DateE")%>" class="dateField">
	        </td>
	        <td class="text9">
		        ◎確認狀態: 
		        <label><input type="radio" name="qrypr_scan_status" value="N" <%#qrypr_scan_status=="N"?"checked":""%>>未確認</label>
		        <label><input type="radio" name="qrypr_scan_status" value="Y" <%#qrypr_scan_status=="Y"?"checked":""%>>已確認</label>
	        </td>
        </tr>
        <tr>
	        <td class="text9">
		        ◎進度日期: <input type="text" id="qryStep_DateS" name="qryStep_DateS" size="10" value="<%#ReqVal.TryGet("qryStep_DateS")%>" class="dateField">
                ~
                <input type="text" id="qryStep_DateE" name="qryStep_DateE" size="10" value="<%#qryStep_DateE%>" class="dateField">
	        </td>
	        <td class="text9">
		        ◎本所編號:<input type="text" name="qrySeq" size="30">-<input type="text" name="qrySeq1" size="2">
	        </td>
	        <td class="text9">
		        <input type="button" value="查詢" class="cbutton" onClick="goSearch()" id=qrybutton name=qrybutton>
                <input type="hidden" name="prgid" id="prgid" value="<%=prgid%>">
	        </td>
        </tr>	
    </table>

    <div id="divPaging" style="display:<%#page.totRow==0?"none":""%>">
    <TABLE border=0 cellspacing=1 cellpadding=0 width="98%" align="center">
	    <tr>
		    <td colspan=2 align=center>
			    <font size="2" color="#3f8eba">
				    第<font color="red"><span id="NowPage"><%#page.nowPage%></span>/<span id="TotPage"><%#page.totPage%></span></font>頁
				    | 資料共<font color="red"><span id="TotRec"><%#page.totRow%></span></font>筆
				    | 跳至第
				    <select id="GoPage" name="GoPage" style="color:#FF0000"><%#page.GetPageList()%></select>
				    頁
				    <span id="PageUp" style="display:<%#page.nowPage>1?"":"none"%>">| <a href="javascript:void(0)" class="pgU" v1="<%#page.nowPage-1%>">上一頁</a></span>
				    <span id="PageDown" style="display:<%#page.nowPage<page.totPage?"":"none"%>">| <a href="javascript:void(0)" class="pgD" v1="<%#page.nowPage+1%>">下一頁</a></span>
				    | 每頁筆數:
				    <select id="PerPage" name="PerPage" style="color:#FF0000">
					    <option value="10" <%#page.perPage==10?"selected":""%>>10</option>
					    <option value="20" <%#page.perPage==20?"selected":""%>>20</option>
					    <option value="30" <%#page.perPage==30?"selected":""%>>30</option>
					    <option value="50" <%#page.perPage==50?"selected":""%>>50</option>
				    </select>
                    <input type="hidden" name="SetOrder" id="SetOrder" value="<%#ReqVal.TryGet("qryOrder")%>" />
			    </font>
		    </td>
	    </tr>
    </TABLE>
    </div>
</form>

<div align="center" id="noData" style="display:<%#page.totRow==0?"":"none"%>">
	<font color="red">=== 目前無資料 ===</font>
</div>

<form style="margin:0;" id="reg" name="reg" method="post">
	<input type="hidden" name="prgid" value="<%=prgid%>">
    <input type="hidden" id=row name=row value="<%#page.pagedTable.Rows.Count%>"> 
    <INPUT type="hidden" name="rows_chk" id="rows_chk">
	<INPUT type="hidden" name="rows_seq" id="rows_seq">
	<INPUT type="hidden" name="rows_seq1" id="rows_seq1">
	<INPUT type="hidden" name="rows_rs_sqlno" id="rows_rs_sqlno">
	<INPUT type="hidden" name="rows_step_grade" id="rows_step_grade">
	<INPUT type="hidden" name="rows_rs_no" id="rows_rs_no">
	<INPUT type="hidden" name="rows_hpr_scan" id="rows_hpr_scan">
	<INPUT type="hidden" name="rows_pr_scan_path" id="rows_pr_scan_path">
	<INPUT type="hidden" name="rows_attach_no" id="rows_attach_no">
	<INPUT type="hidden" name="rows_attach_sqlno" id="rows_attach_sqlno">
	<INPUT type="hidden" name="rows_pr_scan" id="rows_pr_scan">
	<INPUT type="hidden" name="rows_pr_scan_page" id="rows_pr_scan_page">
	<INPUT type="hidden" name="rows_attach_desc" id="rows_attach_desc">

    <asp:Repeater id="dataRepeater" runat="server">
    <HeaderTemplate>
        <table style="display:<%#page.totRow==0?"none":""%>" border="0" class="bluetable" cellspacing="1" cellpadding="2" width="100%" align="center" id="dataList">
	        <thead>
                <Tr>
	                <td  class="lightbluetable" nowrap align="center">作業</td>
	                <td  class="lightbluetable" nowrap align="center"><u class="setOdr" v1="a.seq,a.seq1,a.step_date">本所編號</u></td>
	                <td  class="lightbluetable" nowrap align="center">進度</td>
	                <td  class="lightbluetable" nowrap align="center">收發<br>種類</td>
	                <td  class="lightbluetable" nowrap align="center">文件<br>序號</td> 
	                <td  class="lightbluetable" nowrap align="center">掃描文件</td> 
	                <td  class="lightbluetable" nowrap align="center">掃描說明</td> 
	                <td  class="lightbluetable" nowrap align="center"><u class="setOdr" v1="a.step_date">進度日期</u></td>
	                <td  class="lightbluetable" nowrap align="center">進度內容</td>
	                <td  class="lightbluetable" nowrap align="center">案件名稱</td> 
                </tr>
	        </thead>
	        <tbody>
    </HeaderTemplate>
	<ItemTemplate>
 	    <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>">
		    <td align="center">
                <input type=checkbox id=chk_<%#(Container.ItemIndex+1)%> value='Y'>
		        <input type="hidden" id="seq_<%#(Container.ItemIndex+1)%>" value="<%#Eval("seq")%>">
		        <input type="hidden" id="seq1_<%#(Container.ItemIndex+1)%>" value="<%#Eval("seq1")%>">
		        <input type="hidden" id="rs_sqlno_<%#(Container.ItemIndex+1)%>" value="<%#Eval("rs_sqlno")%>">
		        <input type="hidden" id="step_grade_<%#(Container.ItemIndex+1)%>" value="<%#Eval("step_grade")%>">
		        <input type="hidden" id="rs_no_<%#(Container.ItemIndex+1)%>" value="<%#Eval("rs_no")%>">
		        <input type="hidden" id="hpr_scan_<%#(Container.ItemIndex+1)%>" value="<%#Eval("pr_scan1")%>">
		        <input type="hidden" id="pr_scan_path_<%#(Container.ItemIndex+1)%>" value="<%#Eval("pr_scan_path")%>">
		        <input type="hidden" id="attach_no_<%#(Container.ItemIndex+1)%>" value="<%#Eval("attach_no")%>">
		        <input type="hidden" id="attach_sqlno_<%#(Container.ItemIndex+1)%>" value="<%#Eval("attach_sqlno")%>">
		    </td>
		    <td align="center"><%#Eval("fseq")%></td>
		    <td align="center"><%#Eval("step_grade")%></td>
		    <td align="center"><%#Eval("lcg")%><%#Eval("lrs")%></td>
		    <td align="center"><%#Eval("attach_no")%></td>
		    <td >
                <label>
                    <input type=checkbox id="pr_scan_<%#(Container.ItemIndex+1)%>" value="Y" <%#(Eval("pr_scan1").ToString()=="Y" ?"checked":"")%> onclick="pr_scan_click('<%#(Container.ItemIndex+1)%>')">
		            <span id="span_scanfile_<%#(Container.ItemIndex+1)%>"><%#Eval("scanfile_title")%></span>
			        <span id="span_scanpath_<%#(Container.ItemIndex+1)%>" style="<%#Eval("tstyle")%>">
			        ，頁數：<input type=text id="pr_scan_page_<%#(Container.ItemIndex+1)%>" size=3 value="<%#GetPage(Container)%>" onblur="pr_scan_page_blur('<%#(Container.ItemIndex+1)%>')">
			        <a href="<%#Eval("pr_scan_path")%>" target="_blank">[檢視]</a>
			        </span>
                </label>
		    </td>
		    <td><input type=text id="attach_desc_<%#(Container.ItemIndex+1)%>" value="<%#Eval("attach_desc")%>" size=30 maxlength=40 alt="『掃描說明』" onblur="fDataLen(this)"></td>
		    <td align="center"><%#Eval("step_date","{0:yyyy/M/d}")%></td>
		    <td align="left"><%#Eval("rs_detail")%></td>
		    <td ><%#Eval("appl_name").ToString().ToUnicode().Left(10)%></td>
	    </tr>
	</ItemTemplate>
    <FooterTemplate>
	        </tbody>
        </table>
	    <BR>
	    <div align="center" style="display:<%#page.totRow==0?"none":""%>">
            <%#StrFormBtn%>
        </div>
	    <BR>
        <table style="display:<%#page.totRow==0?"none":""%>" border="0" width="100%" cellspacing="0" cellpadding="0">
		    <tr class="FormName"><td><div align="left" style="color:blue"><%#FormName%></div></td>
            </tr>
	    </table>
	    <br>
    </FooterTemplate>
    </asp:Repeater>

    <%#DebugStr%>
</form>

<div id="dialog"></div>

<iframe id="ActFrame" name="ActFrame" src="about:blank" width="100%" height="300" style="display:none"></iframe>
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
        $('#Syscode option').each(function () {
            $(this).val($(this).val().toUpperCase());
        });

        $(".Lock").lock();
        $("input.dateField").datepick();
    }

    //執行查詢
    function goSearch() {
        $("#regPage").submit();
    };
    //////////////////////
    //□掃描文件
    function pr_scan_click(pno){
        if($("#pr_scan_"+pno).prop("checked")==true){
            $("#hpr_scan_"+pno).val("Y");
            $("#span_scanfile_"+pno).html("有文件");
            $("#span_scanpath_"+pno).show();
        }else{
            $("#hpr_scan_"+pno).val("N");
            $("#pr_scan_page_"+pno).val("0");
            $("#span_scanfile_"+pno).html("尚未掃描");
            $("#span_scanpath_"+pno).hide();
        }
    }

    //頁數
    function pr_scan_page_blur(pno){
        if($("#pr_scan_page_"+pno).val()==""){
            alert("頁數必須輸入!!!");
            return false;
        }
        if(chkNum1($("#pr_scan_page_"+pno),"頁數")||chkInt($("#pr_scan_page_"+pno),"頁數")){
            $("#pr_scan_page_"+pno).val("0");
            return false;
        }
    }

    //串接資料
    function setRowData(){
        $("#rows_chk").val(getJoinValue("#dataList>tbody input[id^='chk_']"));
        $("#rows_seq").val(getJoinValue("#dataList>tbody input[id^='seq_']"));
        $("#rows_seq1").val(getJoinValue("#dataList>tbody input[id^='seq1_']"));
        $("#rows_rs_sqlno").val(getJoinValue("#dataList>tbody input[id^='rs_sqlno_']"));
        $("#rows_step_grade").val(getJoinValue("#dataList>tbody input[id^='step_grade_']"));
        $("#rows_rs_no").val(getJoinValue("#dataList>tbody input[id^='rs_no_']"));
        $("#rows_hpr_scan").val(getJoinValue("#dataList>tbody input[id^='hpr_scan_']"));
        $("#rows_pr_scan_path").val(getJoinValue("#dataList>tbody input[id^='pr_scan_path_']"));
        $("#rows_attach_no").val(getJoinValue("#dataList>tbody input[id^='attach_no_']"));
        $("#rows_attach_sqlno").val(getJoinValue("#dataList>tbody input[id^='attach_sqlno_']"));
        $("#rows_pr_scan").val(getJoinValue("#dataList>tbody input[id^='pr_scan_']"));
        $("#rows_pr_scan_page").val(getJoinValue("#dataList>tbody input[id^='pr_scan_page_']"));
        $("#rows_attach_desc").val(getJoinValue("#dataList>tbody input[id^='attach_desc_']"));
    }

    //確認檢核
    function formAddSubmit(task){
        var taskmsg="";
        if(task=="conf") taskmsg="掃描確認";
        if(task=="cancel") taskmsg="取消掃描";
        for (var pno = 1; pno <= CInt($("#row").val()) ; pno++) {
            if($("#chk_"+pno).prop("checked")==true){
                if($("#pr_scan_"+pno).prop("checked")==true){
                    if($("#pr_scan_page_"+pno).val()==""){
                        alert("頁數必須輸入!!!");
                        return false;
                    }
                    if(CInt($("#pr_scan_page_"+pno).val())<=0){
                        alert("頁數必須大於 0 !!!");
                        return false;
                    }
                    if(task=="cancel"){
                        if (!confirm("本案件" + $("#seq_"+pno).val() + "-"+$("#seq1_"+pno).val()+"進度"+$("#step_grade_"+pno).val()+"掃描序號"+$("#attach_no_"+pno).val()+"有掃描文件，是否確定要執行？"+taskmsg)) return false;
                    }
                }else{
                    if(task=="conf"){
                        if (!confirm("本案件" + $("#seq_"+pno).val() + "-"+$("#seq1_"+pno).val()+"進度"+$("#step_grade_"+pno).val()+"掃描序號"+$("#attach_no_"+pno).val()+"尚未掃描，是否確定要執行？"+taskmsg)) return false;
                    }
                }
            }
        }
	
        //檢查是否有勾選
        var totnum=$("input[id^='chk_']:checked").length;
        if (totnum == 0){
            alert("請勾選您要確認的案件!!");
            return false;
        }

        if (!confirm("共有" + totnum + "筆"+taskmsg+" , 是否確定?")) return false;
        
        //串接資料
        setRowData();

        $("input:disabled, select:disabled").unlock();
        $(".bsubmit").lock(!$("#chkTest").prop("checked"));
        
        var formData = new FormData($('#reg')[0]);
        ajaxByForm("brt61_Update.aspx?task="+task,formData)
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
                            goSearch();//重新整理
                        }
                    }
                }
            });
        });
    }
</script>