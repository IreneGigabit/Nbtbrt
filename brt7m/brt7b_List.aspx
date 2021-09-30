<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<script runat="server">
    protected string HTProgCap = "國內案結案案件處理-會計";//HttpContext.Current.Request["prgname"];//功能名稱
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

    protected string html_qscode = "";

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
        if ((HTProgRight & 4) > 0 || (HTProgRight & 8) > 0 || (HTProgRight & 16) > 0 || (HTProgRight & 64) > 0) {
            StrFormBtn += "<input type=button value ='送主管簽核' class='cbutton bsubmit' onclick=\"formSubmit('send')\">\n";
            StrFormBtn += "<input type=button value ='退回程序' class='redbutton bsubmit' onclick=\"formSubmit('reject')\">\n";
            StrFormBtn += "<input type=button value ='重　填' class='cbutton' onclick='this_init()'>\n";
        }
        
        //洽案營洽
        html_qscode = Sys.getDmtScode("", "").Option("{scode}", "{star}{scode}_{sc_name}", "style='color:{color}'", true, ReqVal.TryGet("qscode", Sys.GetSession("scode")));
        html_qscode += "<option value='" + Sys.GetSession("seBranch") + Sys.GetSession("dept") + "'>" + Sys.GetSession("seBranch") + Sys.GetSession("dept").ToUpper() + "_部門(開放客戶)</option>";
    }

    private void QueryData() {
	    SQL = "select a.*,b.cappl_name as appl_name,b.dmt_scode as scode,b.rs_detail,b.end_date,b.now_step_grade,b.end_type,b.end_remark,c.sqlno as todo_sqlno ";
	    SQL+= ",(select cust_name from view_cust where view_cust.cust_area = b.cust_area and view_cust.cust_seq = b.cust_seq) as cust_name ";
	    SQL+= ",(select sc_name from sysctrl.dbo.scode where scode = b.dmt_scode) as scode_name ";
	    SQL+= ",(select code_name from cust_code where code_type = 'CT' and cust_code = a.ctrl_type) as ctrl_type_name ";
        SQL += ",''fseq,''job_scode ";
        SQL += " from ctrl_dmt a ";
	    SQL+= " inner join vstep_dmt b on a.seq = b.seq and a.seq1 = b.seq1 and a.step_grade=b.step_grade ";
	    SQL+= " inner join todo_dmt c on a.seq=c.seq and a.seq1=c.seq1 and a.step_grade=c.step_grade and c.dowhat='ACC_END' ";
        SQL += " where ctrl_type = 'B61' and c.job_status='NN' ";

        if (ReqVal.TryGet("qseq") != "") {
            SQL += "AND a.seq in('" + ReqVal.TryGet("qseq").Replace(",", "','") + "') ";
        }
        if (ReqVal.TryGet("qseq1") != "") {
            SQL += "AND a.seq1='" + ReqVal["qseq1"] + "' ";
        }
        if (ReqVal.TryGet("sdate") != "") {
            SQL += "AND a.ctrl_date>='" + ReqVal["sdate"] + " 00:00:00' ";
        }
        if (ReqVal.TryGet("edate") != "") {
            SQL += "AND a.ctrl_date<='" + ReqVal["edate"] + " 23:59:59' ";
        }
        if (ReqVal.TryGet("qscode") != "") {
            SQL += "AND b.dmt_scode='" + ReqVal["qscode"] + "' ";
        }
        if (ReqVal.TryGet("qcust_seq") != "") {
            SQL += "AND b.cust_seq='" + ReqVal["qcust_seq"] + "' ";
        }
        ReqVal["qryOrder"] = ReqVal.TryGet("SetOrder", "a.seq,a.seq1,a.ctrl_date");
        if (ReqVal.TryGet("qryOrder") != "") {
            SQL += " order by " + ReqVal.TryGet("qryOrder");
        }
        DataTable dt = new DataTable();
        conn.DataTable(SQL, dt);
        Sys.showLog(SQL);
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

            //案件營洽的組主管
            dr["job_scode"] = Sys.getSignMaster(Sys.GetSession("SeBranch"), dr.SafeRead("scode", ""),false);
        }

        dataRepeater.DataSource = page.pagedTable;
        dataRepeater.DataBind();
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
			<input type="hidden" name="prgid" value="<%=prgid%>">
			<input type="hidden" id="ctrlgs_type" name="ctrlgs_type">
			◎本所編號：
			<INPUT type="text" id="qseq"  name="qseq" size="60" maxlength="100" value="<%#ReqVal.TryGet("qseq")%>">-
			<INPUT type="text" id="qseq1" name="qseq1" size="3" maxlength="3" value="<%#ReqVal.TryGet("qseq1")%>">
			<br>◎結案完成期限期間：
			<input type="text" id="sdate" name="sdate" size="10" maxlength=10 value="<%#ReqVal.TryGet("sdate")%>" class="dateField">～
			<input type="text" id="edate" name="edate" size="10" maxlength=10 value="<%#ReqVal.TryGet("edate")%>" class="dateField">
		</td>
		<td class="text9">
		    ◎洽案營洽 :<select id="qscode" name="qscode"><%#html_qscode%></SELECT>
		    <br>◎客戶編號：<INPUT type="text" name="qcust_area" size="1" maxlength="1" readonly class="sedit" value="<%=Session["seBranch"]%>">-
				            <INPUT type="text" name="qcust_seq" size="5" maxlength="6" value="<%#ReqVal.TryGet("qcust_seq")%>">
		</td>
		<td class="text9">
			<input type="button" value="查詢" class="cbutton" onClick="goSearch()" id=button1 name=button1>
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
	<br /><font color="red">=== 目前無資料 ===</font>
</div>

<form style="margin:0;" id="reg" name="reg" method="post">
	<input type="hidden" name="prgid" id="prgid" value="<%=prgid%>">
    <input type="hidden" id=row name=row value="<%#page.pagedTable.Rows.Count%>"> 
    <INPUT type="hidden" id=rows_chkflag name=rows_chkflag />
	<input type="hidden" id=rows_ctrl_sqlno name=rows_ctrl_sqlno />
	<input type="hidden" id=rows_todo_sqlno name=rows_todo_sqlno />
	<input type="hidden" id=rows_branch name=rows_branch />
	<input type="hidden" id=rows_seq name=rows_seq />
	<input type="hidden" id=rows_seq1 name=rows_seq1 />
	<input type="hidden" id=rows_scode name=rows_scode />
	<input type="hidden" id=rows_job_scode name=rows_job_scode />

    <asp:Repeater id="dataRepeater" runat="server">
    <HeaderTemplate>
        <table style="display:<%#page.totRow==0?"none":""%>" border="0" class="bluetable" cellspacing="1" cellpadding="2" width="100%" align="center" id="dataList">
	        <thead>
                  <Tr class="lightbluetable" align="center">
	                <td nowrap>
		                <a href="javascript:void(0);" onclick="selectall()" style="color:darkblue" onmouseover="this.style.color='red'" onmouseout="this.style.color='darkblue'">全選</a>
	                </td>
		            <td nowrap><u class="setOdr" v1="a.seq,a.seq1,a.ctrl_date">本所編號</u></td>
		            <td nowrap>目前<br>進度</td>
		            <td>案件名稱</td>
		            <td>客戶名稱</td>
		            <td><u class="setOdr" v1="a.ctrl_date">管制期限</u></td>
		            <td><u class="setOdr" v1="b.dmt_scode">營洽</u></td>
		            <td>結案原因</td>
                  </Tr>
	        </thead>
	        <tbody>
    </HeaderTemplate>
		<ItemTemplate>
 	        <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>">
		        <td align='center'>
			        <input type="checkbox" id=chkflag_<%#(Container.ItemIndex+1)%> value="Y">
		            <input type="hidden" id=ctrl_sqlno_<%#(Container.ItemIndex+1)%> value="<%#Eval("sqlno")%>">
		            <input type="hidden" id=todo_sqlno_<%#(Container.ItemIndex+1)%> value="<%#Eval("todo_sqlno")%>">
		            <input type="hidden" id=branch_<%#(Container.ItemIndex+1)%> value="<%#Eval("branch")%>">
		            <input type="hidden" id=seq_<%#(Container.ItemIndex+1)%> value="<%#Eval("seq")%>">
		            <input type="hidden" id=seq1_<%#(Container.ItemIndex+1)%> value="<%#Eval("seq1")%>">
		            <input type="hidden" id=scode_<%#(Container.ItemIndex+1)%> value="<%#Eval("scode")%>">
		            <input type="hidden" id=job_scode_<%#(Container.ItemIndex+1)%> value="<%#Eval("job_scode")%>">
		        </td>
		        <td nowrap align='center'>
                    <a href="javascript:void(0)" onclick="CapplClick('<%#Eval("seq")%>','<%#Eval("seq1")%>')"><%#Eval("fseq")%></a>
                    <a href="<%=Page.ResolveUrl("~/Brt4m/extform/accseqlist_qry.aspx")%>?prgid=<%=HTProgCode%>&seq=<%#Eval("seq")%>&seq1=<%#Eval("seq1")%>&country=T&Frame=Y" target="Eblank">[個案明細查詢]</a>
		        </td>
		        <td align="center">
                    <span style="cursor: pointer;" onmouseover="this.style.color='red'" onmouseout="this.style.color='black'" onclick="QstepClick('<%#Eval("seq")%>', '<%#Eval("seq1")%>')">
                    <%#Eval("now_step_grade")%>
                    </span>
		        </td>
		        <td align="left" title="<%#Eval("appl_name")%>">&nbsp;<%#Eval("appl_name").ToString().ToUnicode().CutData(20)%></td>
		        <td align="left" title="<%#Eval("cust_name")%>">&nbsp;<%#Eval("cust_name").ToString().ToUnicode().CutData(20)%></td>
		        <td align="left"><%#Eval("ctrl_type_name")%>　<%#Eval("ctrl_date","{0:d}")%><br><%#Eval("ctrl_remark")%></td>
		        <td align="left" nowrap><%#Eval("scode_name")%></td>
		        <td align="left"><%#Eval("end_remark")%></td>
	        </tr>
		</ItemTemplate>
    <FooterTemplate>
	        </tbody>
        </table>
        <br />
        <table border=0 class="bluetable"  cellspacing=1 cellpadding=2 width="100%">
	        <tr><td width="20%" class=lightbluetable3 align=right><font color=red>退回原因：</font></td>
                <td width="80%" class=whitetablebg><textarea rows=3 cols=60 id="reject_reason" name="reject_reason"></textarea></td>	
            </tr>
        </table> 
        <br>
	    <div align="center" style="display:<%#page.totRow==0?"none":""%>">
            <%#StrFormBtn%>
        </div>
	    <BR>
        <table border="0" width="100%" cellspacing="0" cellpadding="0">
		    <tr class="FormName"><td>
			    <div align="left" style="color:blue">
			        ※流程:程序結案案件處理--><font color=red>會計確認</font>-->組主管簽核-->部門主管簽核-->區所主管簽核-->程序確認結案暨掃描上傳
			    </div>
		    </td>
            </tr>
	    </table>
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

    //執行查詢
    function goSearch() {
        $("#regPage").submit();
    };

    function this_init() {
        $("#dataList>tbody select[id^='end_type_']").each(function () {
            $(this).triggerHandler("change");
        });

        $(".Lock").lock();
        $("input.dateField").datepick();
    }
    //////////////////////
    $("#sdate,#edate").blur(function (e){
        ChkDate(this);
    });

    //全選
    function selectall(){
        for (var j = 1; j <= CInt($("#row").val()) ; j++) {
            //沒有勾的觸發勾選
            if($("#chkflag_"+j).prop("checked")==false){
                $("#chkflag_"+j).click();
            }
        }
    }
    //案件主檔
    function CapplClick(x1,x2) {
        var url = getRootPath() + "/brt5m/brt15ShowFP.aspx?prgid=<%=prgid%>&seq=" + x1 + "&seq1=" + x2 + "&submittask=Q";
        //window.showModalDialog(url, "", "dialogHeight: 540px; dialogWidth: 800px; center: Yes;resizable: No; status: No;scrollbars:yes");
        $('#dialog').html('<iframe style="border: 0px;" src="' + url + '" width="100%" height="100%"></iframe>')
        .dialog({autoOpen: true,modal: true,height: 540,width: 900,title: "案件主檔"});
    }
    //案件進度查詢
    function QstepClick(pseq,pseq1) {
        window.open(getRootPath() + "/brtam/brta61_Edit.aspx?submitTask=Q&qtype=A&prgid=<%=prgid%>&closewin=Y&winact=1&aseq=" + pseq + "&aseq1=" + pseq1, "myWindowOneN", "width=900 height=700 top=40 left=80 toolbar=no, menubar=no, location=no, directories=no resizeable=no status=no scrollbars=yes");
    }
    //確認
    function formSubmit(todo){
        $("#rows_chkflag,#rows_ctrl_sqlno,#rows_todo_sqlno,#rows_branch,#rows_seq,#rows_seq1,#rows_scode,#rows_job_scode").val("");

        for (var pno = 1; pno <= CInt($("#row").val()) ; pno++) {
            if($("#chkflag_"+pno).prop("checked")==true){
                if(todo=="send" &&$("#job_scode_"+pno).val()==""){
                    alert("第"+pno+"筆 找不到該案件所屬營洽之組主管，無法送主管簽核，請檢查！！");
                    return false;
                }
            }
        }

        if(todo=="reject"){
            if( chkNull("退回原因",$('#reject_reason')[0]) ) return false;
        }

        var totnum=$("input[id^='chkflag_']:checked").length;
        if (totnum==0){
            if(todo=="send"){
                alert("請勾選您要送確認的案件!!");
            }else{
                alert("請勾選您要退回的案件!!");
            }
            return false;
        }else{
            var tans = false;
            if(todo=="send"){
                tans=confirm("共有" + totnum + "筆需要送主管簽核 , 是否確定?");
            }else{
                tans=confirm("共有" + totnum + "筆需要退回程序 , 是否確定?");
            }

            if (tans ==false) return false;

            //串接資料
            $("#rows_chkflag").val(getJoinValue("#dataList>tbody input[id^='chkflag_']"));
            $("#rows_ctrl_sqlno").val(getJoinValue("#dataList>tbody input[id^='ctrl_sqlno_']"));
            $("#rows_todo_sqlno").val(getJoinValue("#dataList>tbody input[id^='todo_sqlno_']"));
            $("#rows_branch").val(getJoinValue("#dataList>tbody input[id^='branch_']"));
            $("#rows_seq").val(getJoinValue("#dataList>tbody input[id^='seq_']"));
            $("#rows_seq1").val(getJoinValue("#dataList>tbody input[id^='seq1_']"));
            $("#rows_scode").val(getJoinValue("#dataList>tbody input[id^='scode_']"));
            $("#rows_job_scode").val(getJoinValue("#dataList>tbody input[id^='job_scode_']"));

            $("input:disabled, select:disabled").unlock();
            $(".bsubmit").lock(!$("#chkTest").prop("checked"));

            var formData = new FormData($('#reg')[0]);
            ajaxByForm("brt7b_Update.aspx?todo="+todo,formData)
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
    }
</script>