<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>

<script runat="server">
    protected string HTProgCap = "國內案不發文註記取消處理";//HttpContext.Current.Request["prgname"];//功能名稱
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

    protected bool emptyForm = true;
    protected string html_qscode = "";

    DBHelper conn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    DBHelper cnn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    private void Page_Unload(System.Object sender, System.EventArgs e) {
        if (conn != null) conn.Dispose();
        if (cnn != null) conn.Dispose();
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
            StrFormBtn += "<input type=button value ='確  認' class='cbutton bsubmit' onclick='formSubmit()'>\n";
            StrFormBtn += "<input type=button value ='重　填' class='cbutton' onclick='this_init()'>\n";
        }

        if (ReqVal.TryGet("qscode") != "" || ReqVal.TryGet("qseq") != "" || ReqVal.TryGet("qseq1") != "" 
            || ReqVal.TryGet("sdate") != "" || ReqVal.TryGet("edate") != "" 
            || ReqVal.TryGet("qsin_no") != "" || ReqVal.TryGet("qein_no") != "" || ReqVal.TryGet("qcust_seq") != "") {
            emptyForm = false;
        }
        
        //洽案營洽
		SQL="select distinct a.in_scode,(select sc_name from sysctrl.dbo.scode where scode=a.in_scode) as sc_name ";
        SQL += ",(select sscode from sysctrl.dbo.scode where scode=a.in_scode) as scode1 ";
        SQL += "from attcase_dmt a where a.sign_stat='SX' order by scode1 ";
        html_qscode = Util.Option(conn, SQL, "{in_scode}", "{sc_name}", true, ReqVal.TryGet("qscode", Sys.GetSession("scode")));
    }

    private void QueryData() {
        SQL = "select a.seq,a.seq1,a.in_scode,a.in_no,a.att_sqlno,a.todo_sqlno,a.remark as approve_desc,b.appl_name,c.arcase_type,c.cust_area,c.cust_seq,c.arcase_class,c.arcase,c.case_date ";
	    SQL+= ",(select cust_name from view_cust where view_cust.cust_area = c.cust_area and view_cust.cust_seq = c.cust_seq) as cust_name ";
	    SQL+= ",(select sc_name from sysctrl.dbo.scode where scode = a.in_scode) as scode_name ";
	    SQL+= ",(select rs_detail from code_br where dept='T' and rs_type=c.arcase_type and rs_code = c.arcase and cr='Y') as arcase_name ";
        SQL += ",(select rs_class from code_br where dept='T' and rs_type=c.arcase_type and rs_code=c.arcase and cr='Y') as ar_form ";
        SQL += ",''fseq,''urlasp ";
	    SQL+= " from attcase_dmt a ";
	    SQL+= " inner join dmt_temp b on a.in_no=b.in_no and a.in_scode=b.in_scode and b.case_sqlno=0 ";
	    SQL+= " inner join case_dmt c on a.in_no=c.in_no and a.in_scode=c.in_scode and c.stat_code='YZ' and (c.change='N' or c.change='C') ";
	    SQL+= " where a.sign_stat='SX' ";
        if (emptyForm) SQL += "AND 1=0 ";
        
        if (ReqVal.TryGet("qseq") != "") {
            SQL += "AND a.seq in('" + ReqVal.TryGet("qseq").Replace(",", "','") + "') ";
        }
        if (ReqVal.TryGet("qseq1") != "") {
            SQL += "AND a.seq1='" + ReqVal["qseq1"] + "' ";
        }
        if (ReqVal.TryGet("sdate") != "") {
            SQL += "AND c.case_date>='" + ReqVal["sdate"] + " 00:00:00' ";
        }
        if (ReqVal.TryGet("edate") != "") {
            SQL += "AND c.case_date<='" + ReqVal["edate"] + " 23:59:59' ";
        }
        if (ReqVal.TryGet("qscode") != "") {
            SQL += "AND a.in_scode='" + ReqVal["qscode"] + "' ";
        }
        if (ReqVal.TryGet("qcust_seq") != "") {
            SQL += "AND c.cust_seq='" + ReqVal["qcust_seq"] + "' ";
        }
        if (ReqVal.TryGet("qsin_no") != "") {
            SQL += "AND a.in_no>='" + ReqVal["qsin_no"] + "' ";
        }
        if (ReqVal.TryGet("qein_no") != "") {
            SQL += "AND a.in_no<='" + ReqVal["qein_no"] + "' ";
        }
        
        ReqVal["qryOrder"] = ReqVal.TryGet("SetOrder", "a.in_scode,a.in_no,c.case_date");
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
            //交辦案號連結
            dr["urlasp"] = GetCaseLink(dr);
        }

        dataRepeater.DataSource = page.pagedTable;
        dataRepeater.DataBind();
    }

    protected string GetCaseLink(DataRow row) {
        string urlasp = "";//連結的url
        string new_form = Sys.getCaseDmtAspx(row.SafeRead("arcase_type", ""), row.SafeRead("arcase", ""));//連結的aspx
        urlasp = Page.ResolveUrl("~/brt1m" + row.SafeRead("link_remark", "") + "/Brt11Edit" + new_form + ".aspx?prgid=" + prgid);
        urlasp += "&in_scode=" + row["in_scode"];
        urlasp += "&in_no=" + row["in_no"];
        urlasp += "&add_arcase=" + row["arcase"];
        urlasp += "&cust_area=" + row["cust_area"];
        urlasp += "&cust_seq=" + row["cust_seq"];
        urlasp += "&ar_form=" + row["ar_form"];
        urlasp += "&new_form=" + new_form;
        urlasp += "&code_type=" + row["arcase_type"];
        urlasp += "&homelist=" + Request["homelist"];
        urlasp += "&uploadtype=case";
        urlasp += "&submittask=Show";

        return urlasp;
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
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/jquery.datepick.min.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/jquery.datepick-zh-TW.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/toastr.min.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/util.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/jquery.irene.form.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/client_chk.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/jquery.Snoopy.date.js")%>"></script>
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
			    <input type="hidden" name="prgid" id="prgid" value="<%=prgid%>">
			    ◎洽案營洽 :<select id="qscode" name="qscode"><%#html_qscode%></SELECT>
			    <br>◎交辦日期：
			    <input type="text" id="sdate" name="sdate" size="10" maxlength=10 value="<%#ReqVal.TryGet("sdate")%>" class="dateField">
			    <input type="text" id="edate" name="edate" size="10" maxlength=10 value="<%#ReqVal.TryGet("edate")%>" class="dateField">
		    </td>
		    <td class="text9">
			    ◎本所編號：
				    <INPUT type="text" name="qseq" size="50" maxlength="100" value="<%#ReqVal.TryGet("qseq")%>">-
				    <INPUT type="text" name="qseq1" size="3" maxlength="3" value="<%#ReqVal.TryGet("qseq1")%>">
					
		    <br>◎客戶編號：<INPUT type="text" name="qcust_area" size="1" maxlength="1" readonly class="sedit" value="<%=Session["seBranch"]%>">-
				            <INPUT type="text" name="qcust_seq" size="5" maxlength="6" value="<%#ReqVal.TryGet("qcust_seq")%>">
		    </td>
	    </tr>	
        <tr>
		    <td class="text9">
			    ◎接洽序號：
				<INPUT type="text" name="qsin_no" size="12" onblur="regPage.qein_no.value=this.value" value="<%#ReqVal.TryGet("qsin_no")%>">~
				<INPUT type="text" name="qein_no" size="12" value="<%#ReqVal.TryGet("qein_no")%>">
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
	<br /><font color="red">=== <%=(emptyForm?"請先輸入查詢條件":"目前無資料")%> ===</font>
</div>

<form style="margin:0;" id="reg" name="reg" method="post">
    <input type=hidden id=row name=row value="<%#page.pagedTable.Rows.Count%>"> 
    <INPUT type="hidden" name="rows_chkflag" id="rows_chkflag">
    <INPUT type="hidden" name="rows_att_sqlno" id="rows_att_sqlno">
    <INPUT type="hidden" name="rows_todo_sqlno" id="rows_todo_sqlno">
    <INPUT type="hidden" name="rows_seq" id="rows_seq">
    <INPUT type="hidden" name="rows_seq1" id="rows_seq1">
    <INPUT type="hidden" name="rows_in_scode" id="rows_in_scode">
    <INPUT type="hidden" name="rows_in_no" id="rows_in_no">

    <asp:Repeater id="dataRepeater" runat="server">
    <HeaderTemplate>
        <table style="display:<%#page.totRow==0?"none":""%>" border="0" class="bluetable" cellspacing="1" cellpadding="2" width="100%" align="center" id="dataList">
	        <thead>
                  <Tr>
	                <td class="lightbluetable" nowrap align="center">
		                <a href="javascript:void(0);" onclick="selectall()" style="color:darkblue" onmouseover="this.style.color='red'" onmouseout="this.style.color='darkblue'">全選</a>
	                </td>
		            <td class="lightbluetable" align="center" nowrap>本所編號</td>
		            <td class="lightbluetable" align="center" nowrap>接洽序號</td>
		            <td class="lightbluetable" align="center" nowrap>交辦日期</td>
		            <td class="lightbluetable" align="center" >案件名稱</td>
		            <td class="lightbluetable" align="center" >客戶名稱</td>
		            <td class="lightbluetable" align="center" >交辦案性</td>
		            <td class="lightbluetable" align="center" >營洽</td>
		            <td class="lightbluetable" align="center" >註記</td>
                  </tr>
	        </thead>
	        <tbody>
    </HeaderTemplate>
			    <ItemTemplate>
 		            <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>">
		                <td align="center">
			                <input type="checkbox" id=chkflag_<%#(Container.ItemIndex+1)%> value="Y">
		                    <input type="hidden" id=att_sqlno_<%#(Container.ItemIndex+1)%> value="<%#Eval("att_sqlno")%>">
		                    <input type="hidden" id=todo_sqlno_<%#(Container.ItemIndex+1)%> value="<%#Eval("todo_sqlno")%>">
		                    <input type="hidden" id=seq_<%#(Container.ItemIndex+1)%> value="<%#Eval("seq")%>">
		                    <input type="hidden" id=seq1_<%#(Container.ItemIndex+1)%> value="<%#Eval("seq1")%>">
		                    <input type="hidden" id=in_scode_<%#(Container.ItemIndex+1)%> value="<%#Eval("in_scode")%>">
		                    <input type="hidden" id=in_no_<%#(Container.ItemIndex+1)%> value="<%#Eval("in_no")%>">
		                </td>
		                <td nowrap align='center' style="cursor: pointer;" onmouseover="this.style.color='red'" onmouseout="this.style.color='black'"  >
                            <a href="#" onclick="CapplClick('<%#Eval("seq")%>','<%#Eval("seq1")%>')"><%#Eval("fseq")%></a>
		                </td>
		                <td align="center" ><a href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("in_no")%></a></td>		
		                <td align="left"><%#Eval("case_date","{0:yyyy/M/d}")%></td>
		                <td align="left" title="<%#Eval("appl_name")%>">&nbsp;<%#Eval("appl_name").ToString().CutData(20)%></td>
		                <td align="left" title="<%#Eval("cust_name")%>">&nbsp;<%#Eval("cust_name").ToString().CutData(20)%></td>
		                <td align="left" >&nbsp;<%#Eval("arcase_name")%></td>
		                <td align="left" nowrap>&nbsp;<%#Eval("scode_name")%></td>
		                <td align="left" nowrap title="<%#Eval("approve_desc")%>" style="cursor:pointer;">不發文說明</td>
				    </tr>

			    </ItemTemplate>
    <FooterTemplate>
	        </tbody>
        </table>
        <br />
	    <div align="center" style="display:<%#page.totRow==0?"none":""%>">
            <%#StrFormBtn%>
        </div>
	    <BR>
        <table style="display:<%#page.totRow==0?"none":""%>" border="0" width="100%" cellspacing="0" cellpadding="0">
		    <tr class="FormName"><td>
			    <div align="left">
                    ※流程:<font color=red>承辦不發文註記取消處理</font>-->國內案承辦交辦發文-->程序官發確認
			    </div>
		    </td>
            </tr>
	    </table>
    </FooterTemplate>
    </asp:Repeater>

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

        theadOdr();//設定表頭排序圖示
        this_init();
    });

    function this_init() {
        $(".Lock").lock();
        $("input.dateField").datepick();
    }

    //執行查詢
    function goSearch() {
        $("#regPage").submit();
    };
    //每頁幾筆
    $("#PerPage").change(function (e) {
        goSearch();
    });
    //指定第幾頁
    $("#divPaging").on("change", "#GoPage", function (e) {
        goSearch();
    });
    //上下頁
    $(".pgU,.pgD").click(function (e) {
        $("#GoPage").val($(this).attr("v1"));
        goSearch();
    });
    //排序
    $(".setOdr").click(function (e) {
        $("#SetOrder").val($(this).attr("v1"));
        goSearch();
    });
    //設定表頭排序圖示
    function theadOdr() {
        $(".setOdr").each(function (i) {
            $(this).remove("span.odby");
            if ($(this).attr("v1").toLowerCase() == $("#SetOrder").val().toLowerCase()) {
                $(this).append("<span class='odby'>▲</span>");
            }
        });
    }
    //重新整理
    $(".imgRefresh").click(function (e) {
        goSearch();
    });
    //關閉視窗
    $(".imgCls").click(function (e) {
        if (window.parent.tt !== undefined) {
            window.parent.tt.rows = "100%,0%";
        } else {
            window.close();
        }
    })
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
        var url = getRootPath() + "/brt5m/brt15ShowFP.aspx?seq=" + x1 + "&seq1=" + x2 + "&submittask=Q";
        //window.showModalDialog(url, "", "dialogHeight: 540px; dialogWidth: 800px; center: Yes;resizable: No; status: No;scrollbars:yes");
        $('#dialog').html('<iframe style="border: 0px;" src="' + url + '" width="100%" height="100%"></iframe>')
        .dialog({autoOpen: true,modal: true,height: 540,width: 800,title: "案件主檔"});
    }
    //確認
    function formSubmit(){
	    $("#rows_chkflag,#rows_att_sqlno,#rows_todo_sqlno,#rows_seq,#rows_seq1,#rows_in_scode,#rows_in_no").val("");

        var totnum=$("input[id^='chkflag_']:checked").length;
        if (totnum==0){
            alert("請勾選您要取消不發文註記的案件!!");
            return false;
        }else{
	        var tans = confirm("共有" + totnum + "筆需要取消不發文註記 , 是否確定?");
	        if (tans ==false) return false;

            //串接資料
		    $("#rows_chkflag").val(getJoinValue("#dataList>tbody input[id^='chkflag_']"));
            $("#rows_att_sqlno").val(getJoinValue("#dataList>tbody input[id^='att_sqlno_']"));
            $("#rows_todo_sqlno").val(getJoinValue("#dataList>tbody input[id^='todo_sqlno_']"));
            $("#rows_seq").val(getJoinValue("#dataList>tbody input[id^='seq_']"));
            $("#rows_seq1").val(getJoinValue("#dataList>tbody input[id^='seq1_']"));
            $("#rows_in_scode").val(getJoinValue("#dataList>tbody input[id^='in_scode_']"));
            $("#rows_in_no").val(getJoinValue("#dataList>tbody input[id^='in_no_']"));

            //$("select,textarea,input,span").unlock();
            $("input:disabled, select:disabled").unlock();
            $(".bsubmit").lock(!$("#chkTest").prop("checked"));

            var formData = new FormData($('#reg')[0]);
            ajaxByForm("Brt631_Update.aspx",formData)
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