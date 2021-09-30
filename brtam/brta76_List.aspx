<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<script runat="server">
    protected string HTProgCap = "程序轉案發文確認";//HttpContext.Current.Request["prgname"];//功能名稱
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

    protected string qs_dept = "";
    protected string html_qscode = "",html_qtran_seq_branch="";

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

        qs_dept = (Request["qs_dept"] ?? "").ToLower();
        
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
            StrFormBtn += "<input type=button value ='轉案發文確認' class='cbutton bsubmit' onclick='formSubmit()'>\n";
            StrFormBtn += "<input type=button value ='重　填' class='cbutton' onclick='this_init()'>\n";
        }

        //案件營洽
        if (qs_dept == "t") {
            SQL = "select distinct a.scode,(select sc_name from sysctrl.dbo.scode where scode=a.scode) as sc_name ";
            SQL += ",(select sscode from sysctrl.dbo.scode where scode=a.scode) as scode1 ";
            SQL += "from dmt a inner join todo_dmt b on a.seq=b.seq and a.seq1=b.seq1 ";
            SQL += " where syscode='" + Session["syscode"] + "' and dowhat='TRAN_ND' and job_status='NN' ";
            SQL += "order by scode1 ";
        } else if (qs_dept == "e") {
            SQL = "select distinct a.scode,(select sc_name from sysctrl.dbo.scode where scode=a.scode) as sc_name ";
            SQL += ",(select sscode from sysctrl.dbo.scode where scode=a.scode) as scode1 ";
            SQL += "from ext a inner join todo_ext b on a.seq=b.seq and a.seq1=b.seq1 ";
            SQL += " where syscode='" + Session["syscode"] + "' and dowhat='TRAN_ND' and job_status='NN' ";
            SQL += "order by scode1 ";
        }
        html_qscode = Util.Option(conn, SQL, "{scode}", "{scode}_{sc_name}", true);

        //新單位區所別
        SQL = "select distinct a.tran_seq_branch,(select branchname from sysctrl.dbo.branch_code where branch=a.tran_seq_branch) as branchname ";
        SQL += ",(select sort from sysctrl.dbo.branch_code where branch=a.tran_seq_branch) as sort from dmt_brtran a ";
        SQL += "where a.dc_date is null  order by sort ";
        html_qtran_seq_branch = Util.Option(conn, SQL, "{tran_seq_branch}", "{branchname}", true, ReqVal.TryGet("qtran_seq_branch"));
    }

    private void QueryData() {
        string wsql = "";
        if (ReqVal.TryGet("qseq") != "") {
            wsql += " and a.seq in (" + ReqVal["qseq"] + ")";
        }
        if (ReqVal.TryGet("qseq1") != "") {
            wsql += " and a.seq1='" + ReqVal["qseq1"] + "'";
        }
        if (ReqVal.TryGet("sdate") != "") {
            wsql += " and a.sc_date>='" + ReqVal["sdate"] + " 00:00:00' ";
        }
        if (ReqVal.TryGet("edate") != "") {
            wsql += " and a.sc_date<='" + ReqVal["edate"] + " 23:59:59' ";
        }
        if (ReqVal.TryGet("qscode") != "") {
            wsql += " and b.scode='" + ReqVal["qscode"] + "'";
        }
        if (ReqVal.TryGet("qcust_seq") != "") {
            wsql += " and  b.cust_seq='" + ReqVal["qcust_seq"] + "'";
        }
        if (ReqVal.TryGet("qtran_seq_branch") != "") {
            wsql += " and a.tran_seq_branch='" + ReqVal["qtran_seq_branch"] + "'";
        }

        if (qs_dept == "t") {
            SQL = "select a.*,b.appl_name,b.class,b.scode,b.step_grade,b.end_date,b.cust_area,b.cust_seq,b.cust_seq1,'' as country,c.sqlno as todo_sqlno ";
            SQL += ",(select cust_name from view_cust where view_cust.cust_area = b.cust_area and view_cust.cust_seq = b.cust_seq) as cust_name ";
            SQL += ",(select sc_name from sysctrl.dbo.scode where scode = b.scode) as scode_name ";
            SQL += ",(select code_name from cust_code where code_type='Tcase_stat' and cust_code=b.now_stat) as now_stat_name  ";
            SQL += ",(select branchname from sysctrl.dbo.branch_code where branch=a.tran_seq_branch) as branchname ";
            SQL += ",(select count(*) from dmt_attach where source='tran' and attach_flag<>'D' and att_sqlno=a.brtran_sqlno) as attach_cnt ";
            SQL += ",''fseq,'todo_dmt'todo_tblnm ";
            SQL += " from dmt_brtran a ";
            SQL += " inner join dmt b on a.seq = b.seq and a.seq1 = b.seq1 ";
            SQL += " inner join todo_dmt c on a.seq=c.seq and a.seq1=c.seq1 and c.dowhat='TRAN_ND' ";
        } else if (qs_dept == "e") {
            SQL = "select a.*,b.appl_name,b.class,b.scode,b.step_grade,b.end_date,b.cust_area,b.cust_seq,b.cust_seq1,b.country as country,c.sqlno as todo_sqlno ";
            SQL += ",(select cust_name from view_cust where view_cust.cust_area = b.cust_area and view_cust.cust_seq = b.cust_seq) as cust_name ";
            SQL += ",(select sc_name from sysctrl.dbo.scode where scode = b.scode) as scode_name ";
            SQL += ",(select code_name from cust_code where code_type='Tecasestat' and cust_code=b.now_stat) as now_stat_name  ";
            SQL += ",(select branchname from sysctrl.dbo.branch_code where branch=a.tran_seq_branch) as branchname ";
            SQL += ",(select count(*) from attach_ext where source='tran' and attach_flag<>'D' and att_sqlno=a.brtran_sqlno) as attach_cnt ";
            SQL += ",''fseq,'todo_ext'todo_tblnm ";
            SQL += " from ext_brtran a ";
            SQL += " inner join ext b on a.seq = b.seq and a.seq1 = b.seq1 ";
            SQL += " inner join todo_ext c on a.seq=c.seq and a.seq1=c.seq1 and c.dowhat='TRAN_ND' ";
        }
        SQL += " where c.job_status ='NN' " + wsql;

        ReqVal["qryOrder"] = ReqVal.TryGet("SetOrder", "b.cust_seq,a.seq,a.seq1,a.sc_date");
        if (ReqVal.TryGet("qryOrder") != "") {
            SQL += " order by " + ReqVal.TryGet("qryOrder");
        }
        DataTable dt = new DataTable();
        conn.DataTable(SQL, dt);
        Sys.showLog(SQL);
        //處理分頁
        int nowPage = Convert.ToInt32(Request["GoPage"] ?? "1"); //第幾頁
        int PerPageSize = Convert.ToInt32(Request["PerPage"] ?? "10"); //每頁筆數
        page = new Paging(nowPage, PerPageSize, SQL);
        page.GetPagedTable(dt);

        //分頁完再處理其他資料才不會虛耗資源
        for (int i = 0; i < page.pagedTable.Rows.Count; i++) {
            DataRow dr = page.pagedTable.Rows[i];

            //案號
            if (dr.SafeRead("country", "") == "") {
                dr["fseq"] = Sys.formatSeq(dr.SafeRead("seq", ""), dr.SafeRead("seq1", ""), "", Sys.GetSession("seBranch"), Sys.GetSession("dept"));
            } else {
                dr["fseq"] = Sys.formatSeq(dr.SafeRead("seq", ""), dr.SafeRead("seq1", ""), dr.SafeRead("country", ""), Sys.GetSession("seBranch"), Sys.GetSession("dept") + "E");
            }

            if (dr.SafeRead("scode_name", "") == "") {
                dr["scode_name"] = dr.SafeRead("scode", "");
            }
        }

        dataRepeater.DataSource = page.pagedTable;
        dataRepeater.DataBind();
    }

    //退回原因
    protected string GetBackIcon(RepeaterItem Container) {
        string rtn = "";

        //抓取主管退回記錄
        SQL = "select approve_desc from " + Eval("todo_tblnm") + " where seq=" + Eval("seq") + " and seq1='" + Eval("seq1") + "' and from_flag='TRAN' and dowhat='TRAN_NM' and job_status='NX' order by sqlno desc";
        string br_ap_desc = conn.getString(SQL);
        objResult = conn.ExecuteScalar(SQL);

        if (br_ap_desc != "") {
            rtn = "<img border=\"0\" src=\"" + Page.ResolveUrl("~/images/star_pl.gif") + "\" title=\"主管退回原因：" + br_ap_desc + "\">";
        }

        return rtn;
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
		        ◎客戶編號：<input type="text" name="qcust_area" id="qcust_area" size=1 value="<%=Session["seBranch"]%>" class="Lock"> 
		                    <input type="text" name="qcust_seq" id="qcust_seq" size=5 value="<%#ReqVal.TryGet("qcust_seq")%>"> 
		        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		        ◎案件營洽 :<select id="qscode" name="qscode"><%#html_qscode%></SELECT>
		        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		        ◎營洽轉案處理期間：
			    <input type="text" name="sdate" id="sdate" size="10" maxlength=10 class="dateField" value="<%#ReqVal.TryGet("sdate")%>">
                ~
			    <input type="text" name="edate" id="edate" size="10" maxlength=10 class="dateField" value="<%#ReqVal.TryGet("edate")%>">
		    </td>
	    </tr>
	    <tr>	
		    <td class="text9">
			    ◎本所編號：
				    <INPUT type="text" name="qseq" id="qseq" size="60" maxlength="100" onblur="fseq_chk(this)" value="<%#ReqVal.TryGet("qseq")%>">-
				    <INPUT type="text" name="qseq1" id="qseq1" size="3" maxlength="3" value="<%#ReqVal.TryGet("qseq1")%>">
			    &nbsp;&nbsp;&nbsp;
			    ◎新單位區所別：<select id="qtran_seq_branch" name="qtran_seq_branch"><%#html_qtran_seq_branch%></SELECT>	
			    &nbsp;&nbsp;&nbsp;
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
    <input type=hidden id=branch name=branch> 
    <input type=hidden id=qs_dept name=qs_dept value="<%=qs_dept%>"> 
    <input type=hidden id=row name=row value="<%#page.pagedTable.Rows.Count%>"> 
    <INPUT type="hidden" id=rows_chkflag name=rows_chkflag />
	<input type="hidden" id=rows_brtran_sqlno name=rows_brtran_sqlno />
	<input type="hidden" id=rows_todo_sqlno name=rows_todo_sqlno />
	<input type="hidden" id=rows_seq name=rows_seq />
	<input type="hidden" id=rows_seq1 name=rows_seq1 />
	<input type="hidden" id=rows_appl_name name=rows_appl_name />
	<input type="hidden" id=rows_scode name=rows_scode />
	<input type="hidden" id=rows_cust_seq name=rows_cust_seq />
	<input type="hidden" id=rows_cust_seq1 name=rows_cust_seq1 />
	<input type="hidden" id=rows_cust_name name=rows_cust_name />
	<input type="hidden" id=rows_tran_seq_branch name=rows_tran_seq_branch />
	<input type="hidden" id=rows_tran_remark name=rows_tran_remark />

    <asp:Repeater id="dataRepeater" runat="server">
    <HeaderTemplate>
        <table style="display:<%#page.totRow==0?"none":""%>" border="0" class="bluetable" cellspacing="1" cellpadding="2" width="100%" align="center" id="dataList">
	        <thead>
                  <Tr class="lightbluetable" align="center">
	                <td nowrap>
                        <a href="javascript:void(0);" onclick="selectall()" style="color:darkblue" onmouseover="this.style.color='red'" onmouseout="this.style.color='darkblue'">全選</a>
                    </td>
		            <td nowrap><u class="setOdr" v1="a.seq,a.seq1">本所編號</u></td>
		            <td nowrap>目前<br>進度</td>
		            <td>案件名稱</td>
		            <td><u class="setOdr" v1="b.cust_seq,a.seq,a.seq1,a.sc_date">客戶名稱</u></td>
		            <td><u class="setOdr" v1="b.scode">營洽</u></td>
		            <td>結案日期</td>
		            <td>案件狀態</td>
		            <td><u class="setOdr" v1="a.sc_date">轉案處理日</u></td>
		            <td>新單位區所別</td>
		            <td>轉案原因</td>
		            <td>附件</td>
	            </tr>
	        </thead>
	        <tbody>
    </HeaderTemplate>
		<ItemTemplate>
 	        <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>">
	            <td  align="center">
			        <input type="checkbox" id=chkflag_<%#(Container.ItemIndex+1)%> value="Y" onclick="chkflagClick('<%#(Container.ItemIndex+1)%>')">
			        <input type="hidden" id=brtran_sqlno_<%#(Container.ItemIndex+1)%> value="<%#Eval("brtran_sqlno")%>">
			        <input type="hidden" id=todo_sqlno_<%#(Container.ItemIndex+1)%> value="<%#Eval("todo_sqlno")%>">
			        <input type="hidden" id=seq_<%#(Container.ItemIndex+1)%> value="<%#Eval("seq")%>">
			        <input type="hidden" id=seq1_<%#(Container.ItemIndex+1)%> value="<%#Eval("seq1")%>">
			        <input type="hidden" id=appl_name_<%#(Container.ItemIndex+1)%> value="<%#Eval("appl_name")%>">
			        <input type="hidden" id=scode_<%#(Container.ItemIndex+1)%> value="<%#Eval("scode")%>">
			        <input type="hidden" id=cust_seq_<%#(Container.ItemIndex+1)%> value="<%#Eval("cust_seq")%>">
			        <input type="hidden" id=cust_seq1_<%#(Container.ItemIndex+1)%> value="<%#Eval("cust_seq1")%>">
			        <input type="hidden" id=cust_name_<%#(Container.ItemIndex+1)%> value="<%#Eval("cust_name")%>">
			        <input type="hidden" id=tran_seq_branch_<%#(Container.ItemIndex+1)%> value="<%#Eval("tran_seq_branch")%>">
			        <input type="hidden" id=tran_remark_<%#(Container.ItemIndex+1)%> value="<%#Eval("tran_remark")%>">
		        </td>
		        <td  nowrap style="cursor: pointer;color:darkblue" onmouseover="this.style.color='red'" onmouseout="this.style.color='darkblue'" onclick="CapplClick('<%#Eval("seq")%>','<%#Eval("seq1")%>','<%#Eval("country")%>')">
                    <%#Eval("fseq")%>
                    <%#GetBackIcon(Container)%>
		        </td>
		        <td  nowrap align=center style="cursor: pointer;" onmouseover="this.style.color='red'" onmouseout="this.style.color='black'" onclick="QstepClick(<%#Eval("seq")%>, '<%#Eval("seq1")%>','<%#Eval("country")%>')"><%#Eval("step_grade")%></td>
		        <td  style="cursor: pointer" title="<%#Eval("appl_name")%>"><%#Eval("appl_name").ToString().CutData(20)%></td>
		        <td  style="cursor: pointer" title="<%#Eval("cust_name")%>"><%#Eval("cust_area")%><%#Eval("cust_seq")%>&nbsp;<%#Eval("cust_name").ToString().CutData(20)%></td>
		        <td  align="center"><%#Eval("scode_name")%></td>
		        <td  align="center"><%#Eval("end_date","{0:d}")%></td>
		        <td  align="left"><%#Eval("now_stat_name")%></td>
		        <td  align="center"><%#Eval("sc_date")%></td>
		        <td  align="center"><%#Eval("branchname")%></td>
		        <td  align="left"><%#Eval("tran_remark")%></td>
                <td  align="center"><input type="button" class="cbutton" value="檢視(<%#Eval("attach_cnt")%>)" onClick="attach_file('<%#Eval("seq")%>','<%#Eval("seq1")%>','<%#Eval("country")%>')" name=button1></td>
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
        <table border="0" width="100%" cellspacing="0" cellpadding="0">
		    <tr class="FormName"><td>
			    <div align="left" style="color:blue">
			        ※流程:原單位營洽轉案處理-->原單位組主管簽核-->原單位部門主管簽核-->原單位區所主管簽核--><font color=red>原單位程序轉案發文確認</font>-->新單位主管確認轉案-->新單位程序確認轉案-->原單位程序轉案完成確認
			        <br>※<img src="<%=Page.ResolveUrl("~/images/star_pl.gif")%>" border=0>表主管退回，滑鼠移至本圖案，即會顯示主管最近一次退回原因。
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
        $(".Lock").lock();
        $("input.dateField").datepick();
    }
    //////////////////////
    $("#sdate,#edate").blur(function (e){
        ChkDate(this);
    });

    //案件主檔
    function CapplClick(x1,x2,x3) {
        var url = "";
        if (x3=="") {
            url=getRootPath() + "/brt5m/brt15ShowFP.aspx?prgid=<%=prgid%>&seq=" + x1 + "&seq1=" + x2 + "&submittask=Q";
        }else{
            //***todo
            url=getRootPath() + "/brt5m/ext54Edit.aspx?prgid=<%=prgid%>&seq=" + x1 + "&seq1=" + x2 + "&submittask=DQ";
        }
        //window.showModalDialog(url, "", "dialogHeight: 540px; dialogWidth: 800px; center: Yes;resizable: No; status: No;scrollbars:yes");
        $('#dialog').html('<iframe style="border: 0px;" src="' + url + '" width="100%" height="100%"></iframe>')
        .dialog({autoOpen: true,modal: true,height: 540,width: 900,title: "案件主檔"});
    }

    //案件進度查詢
    function QstepClick(pseq,pseq1,pcountry) {
        var url = "";
        if (pcountry=="") {
            url=getRootPath() + "/brtam/brta61_Edit.aspx?submitTask=Q&qtype=A&prgid=<%=prgid%>&closewin=Y&winact=1&aseq=" + pseq + "&aseq1=" + pseq1;
        }else{
            //***todo
            url=getRootPath() + "/brtam/exta61Edit.aspx?submitTask=Q&qtype=A&prgid=<%=prgid%>&closewin=Y&winact=1&aseq=" + pseq + "&aseq1=" + pseq1;
        }

        window.open(url, "myWindowOneN", "width=900 height=700 top=40 left=80 toolbar=no, menubar=no, location=no, directories=no resizeable=no status=no scrollbars=yes");
    }

    //案件流程狀態查詢
    function TodoClick(pseq,pseq1) {
        window.open(getRootPath() + "/brtam/brta61_list2.aspx?prgid=<%=prgid%>&seq=" + pseq + "&seq1=" + pseq1, "myWindowOneN", "width=900px, height=550px, top=10, left=10, toolbar=no, menubar=no, location=no, directories=no, status=no,resizable=yes, scrollbars=yes");
    }

    //[上傳]
    function attach_file(pseq,pseq1,pcountry){
        var url = getRootPath() + "/brt1m/brt1b_attach.aspx?prgid=<%#prgid%>&seq=" + pseq + "&seq1=" + pseq1 + "&country=" + pcountry+"&submittask=Q&source=tran";
        //window.open(url, "myWindowOneN", "width=900px, height=650px, top=10, left=10, toolbar=no, menubar=no, location=no, directories=no, status=no,resizable=yes, scrollbars=yes");
        $('#dialog').html('<iframe style="border: 0px;" src="' + url + '" width="100%" height="100%"></iframe>')
        .dialog({ autoOpen: true, modal: true, height: 540, width: "80%", title: "轉案文件上傳" });
    }

    //全選
    function selectall(){
        for (var j = 1; j <= CInt($("#row").val()) ; j++) {
            $("#chkflag_"+j).prop("checked",true).triggerHandler("click");
        }
    }

    //每筆勾選時檢查區所
    function chkflagClick(pchknum) {
        var sign_branch=$("#tran_seq_branch_"+pchknum).val();

        if ($("#branch").val()=="") {
            $("#branch").val(sign_branch);
        }

        if($("#chkflag_"+pchknum).prop("checked")==true){
            if($("#branch").val()!=sign_branch){
                alert("新單位區所別不同，無法同時執行轉案，請分批執行。");
                $("#chkflag_"+pchknum).prop("checked",false);
                if ($("input[id^='chkflag_']:checked").length == 0) $("#branch").val("");
                return false;
            }
        }

        if ($("input[id^='chkflag_']:checked").length == 0) $("#branch").val("");
    }

    //確認
    function formSubmit(){
        $("#rows_brtran_sqlno,#rows_todo_sqlno,#rows_seq,#rows_seq1,#rows_appl_name,#rows_scode,#rows_cust_seq,#rows_cust_seq1,#rows_cust_name,#rows_tran_seq_branch,#rows_tran_remark").val("");

        var totnum=$("input[id^='chkflag_']:checked").length;
        if (totnum==0){
            alert("請勾選您要轉案確認的案件!!");
            return false;
        }else{
            var tans = confirm("共有" + totnum + "筆需要轉案發文確認 , 是否確定?");
            if (tans ==false) return false;

            //串接資料
            $("#rows_chkflag").val(getJoinValue("#dataList>tbody input[id^='chkflag_']"));
            $("#rows_brtran_sqlno").val(getJoinValue("#dataList>tbody input[id^='brtran_sqlno_']"));
            $("#rows_todo_sqlno").val(getJoinValue("#dataList>tbody input[id^='todo_sqlno_']"));
            $("#rows_seq").val(getJoinValue("#dataList>tbody input[id^='seq_']"));
            $("#rows_seq1").val(getJoinValue("#dataList>tbody input[id^='seq1_']"));
            $("#rows_appl_name").val(getJoinValue("#dataList>tbody input[id^='appl_name_']"));
            $("#rows_scode").val(getJoinValue("#dataList>tbody input[id^='scode_']"));
            $("#rows_cust_seq").val(getJoinValue("#dataList>tbody input[id^='cust_seq_']"));
            $("#rows_cust_seq1").val(getJoinValue("#dataList>tbody input[id^='cust_seq1_']"));
            $("#rows_cust_name").val(getJoinValue("#dataList>tbody input[id^='cust_name_']"));
            $("#rows_tran_seq_branch").val(getJoinValue("#dataList>tbody input[id^='tran_seq_branch_']"));
            $("#rows_tran_remark").val(getJoinValue("#dataList>tbody input[id^='tran_remark_']"));

            $("input:disabled, select:disabled").unlock();
            $(".bsubmit").lock(!$("#chkTest").prop("checked"));

            var formData = new FormData($('#reg')[0]);
            ajaxByForm("Brta76_Update.aspx",formData)
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
                                window.parent.Etop.goSearch();//重新整理
                            }
                        }
                    }
                });
            });
        }
    }
</script>