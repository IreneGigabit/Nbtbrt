<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<script runat="server">
    protected string HTProgCap = "國內案收發進度維護作業-客收清單";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "brta21";//HttpContext.Current.Request["prgid"] ?? "";//程式檔名前綴
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

    protected string submitTask = "";
    protected string cgrs = "";
    protected string cg = "";
    protected string rs = "";
    
    //統計表
    string cnt = "0", class_count = "0", service = "0", fees = "0", oth_money = "0", total = "0", nar_service = "0", nar_fees = "0";

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

        conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
        cnn = new DBHelper(Conn.Sysctrl).Debug(Request["chkTest"] == "TEST");

        cgrs = ReqVal.TryGet("cgrs").ToUpper();
        cg = ReqVal.TryGet("cgrs").Left(1);
        rs = ReqVal.TryGet("cgrs").Right(1);

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
        StrFormBtnTop += "<a href='" + HTProgPrefix + ".aspx?prgid=" + prgid + "'>[查詢畫面]</a>";
        StrFormBtnTop += "<a class=\"imgRefresh\" href=\"javascript:void(0);\" >[重新整理]</a>";
    }

    private void QueryData() {
        string wSQL = "";
        if (ReqVal.TryGet("seq") != "") {
            wSQL += "AND a.seq='" + ReqVal["seq"] + "' ";
        }
        if (ReqVal.TryGet("seq1") != "") {
            wSQL += "AND a.seq1='" + ReqVal["seq1"] + "' ";
        }
        if (ReqVal.TryGet("rs_no") != "") {
            wSQL += "AND rs_no='" + ReqVal["rs_no"] + "' ";
        }
        if (ReqVal.TryGet("cust_seq") != "") {
            wSQL += "AND c.cust_seq ='" + ReqVal["cust_seq"] + "' ";
        }
        if (ReqVal.TryGet("ap_cname") != "") {
            wSQL += "and d.ap_cname1+isnull(d.ap_cname2,'') like '%" + ReqVal["ap_cname"] + "%' ";
        }
        if (ReqVal.TryGet("cappl_name") != "") {
            wSQL += "and cappl_name like'%" + ReqVal["cappl_name"] + "%' ";
        }
        if (ReqVal.TryGet("rs_class") != "") {
            wSQL += "AND rs_class='" + ReqVal["rs_class"] + "' ";
        }
        if (ReqVal.TryGet("rs_code") != "") {
            wSQL += "AND rs_code='" + ReqVal["rs_code"] + "' ";
        }
        if (ReqVal.TryGet("act_code") != "") {
            wSQL += "AND act_code='" + ReqVal["act_code"] + "' ";
        }
        if (ReqVal.TryGet("sstep_date") != "") {
            wSQL += "AND step_date>='" + ReqVal["sstep_date"] + "' ";
        }
        if (ReqVal.TryGet("estep_date") != "") {
            wSQL += "AND step_date<='" + ReqVal["estep_date"] + "' ";
        }
        if (ReqVal.TryGet("slast_date") != "" || ReqVal.TryGet("elast_date") != "") {
            string wSQL0 = "";
            if (ReqVal.TryGet("slast_date") != "") {
                wSQL0 += "AND ctrl_date>='" + ReqVal["slast_date"] + "' ";
            }
            if (ReqVal.TryGet("elast_date") != "") {
                wSQL0 += "AND ctrl_date<='" + ReqVal["elast_date"] + "' ";
            }
            string sSQL = "and convert(char,seq) + seq1 in ";
            sSQL += " (select distinct convert(char,seq) + seq1 from ctrl_dmt where ctrl_type = 'A1' {0} ";
            sSQL += " union ";
            sSQL += " select distinct convert(char,seq) + seq1 from resp_dmt where ctrl_type = 'A1' {0} )";

            wSQL += string.Format(sSQL, wSQL0);
        }
        if (ReqVal.TryGet("scode1") != "") {
            wSQL += "AND b.in_scode='" + ReqVal["scode1"] + "' ";
        }

        SQL = "select a.rs_no,a.seq,a.seq1,a.step_grade,a.step_date,a.case_no,b.class_count,b.appl_name,a.rs_code,a.rs_class";
        SQL += ",c.service+c.add_service+c.oth_money as  service,c.oth_money,c.fees+c.add_fees as fees";
        SQL += ",c.service+c.add_service+c.oth_money+c.fees+c.add_fees as total,c.discount";
        SQL += ",c.arcase_type,c.arcase_class,c.arcase,b.in_scode,b.in_no,c.cust_area,c.cust_seq";
        SQL += ",(select rs_detail from code_br where dept='" + Session["dept"] + "' and cr='Y' and rs_type=a.rs_type and rs_class=a.rs_class and rs_code=a.rs_code) as rs_codenm";
        SQL += ",(select rtrim(sc_name) from sysctrl.dbo.scode where scode=b.in_scode) as sc_name";
        SQL += ",(select isnull(rtrim(ap_cname1),'')+isnull(rtrim(ap_cname2),'') from apcust where cust_area=c.cust_area and cust_seq=c.cust_seq) as cust_name";
        SQL += ",''lcg,''lrs,''fseq,''urlasp,''loth_money";
        SQL += " from step_dmt a,dmt_temp b, case_dmt c,apcust d ";
        SQL += " where cg = 'C' and rs = 'R' ";
        SQL += " and rs_no = main_rs_no ";
        SQL += " and b.case_sqlno = 0 ";
        SQL += " and a.case_no = c.case_no ";
        SQL += " and b.in_scode = c.in_scode and b.in_no = c.in_no ";
        SQL += " and c.cust_area=d.cust_area and c.cust_seq=d.cust_seq ";
        SQL += " and c.cust_area = '" + Session["seBranch"] + "' ";
        SQL += wSQL;

        ReqVal["qryOrder"] = ReqVal.TryGet("SetOrder", ReqVal.TryGet("qryOrder", "a.case_no"));
        if (ReqVal.TryGet("qryOrder") != "") {
            SQL += " order by " + ReqVal.TryGet("qryOrder");
        }

        DataTable dt = new DataTable();
        conn.DataTable(SQL, dt);

        //處理分頁
        int nowPage = Convert.ToInt32(Request["GoPage"] ?? "1"); //第幾頁
        int PerPageSize = Convert.ToInt32(Request["PerPage"] ?? "10"); //每頁筆數
        page = new Paging(nowPage, PerPageSize, SQL);
        page.GetPagedTable(dt);

        //分頁完再處理其他資料才不會虛耗資源
        for (int i = 0; i < page.pagedTable.Rows.Count; i++) {
            DataRow dr = page.pagedTable.Rows[i];

            //收發種類
            if (cg == "C") {
                dr["lcg"] = "客";
            } else if (cg == "G") {
                dr["lcg"] = "官";
            } else {
                dr["lcg"] = "本";
            }
            if (rs == "R" || rs == "Z") {
                dr["lrs"] = "收";
            } else {
                dr["lrs"] = "發";
            }
            //案號
            dr["fseq"] = Sys.formatSeq1(dr.SafeRead("seq", ""), dr.SafeRead("seq1", ""), "", Sys.GetSession("seBranch"), Sys.GetSession("dept"));
            //交辦畫面
            dr["urlasp"] = Sys.getCase11Aspx(prgid, dr.SafeRead("in_no", ""), dr.SafeRead("in_scode", ""), "Show");
            //服務費內含轉帳費用
            if (dr.SafeRead("oth_money", "0") != "0") {
                dr["loth_money"] = "<font color=red>*</font>";
            }
        }

        dataRepeater.DataSource = page.pagedTable;
        dataRepeater.DataBind();

        //統計表
        SQL = "select count(*) as cnt,sum(b.class_count) as class_count";
        SQL += ",sum(c.service+c.add_service) as service,sum(c.fees+c.add_fees) as fees,sum(c.oth_money) as oth_money";
        SQL += ",sum(c.service+c.add_service+c.oth_money+c.fees+c.add_fees) as total";
        SQL += ",sum(c.service+c.add_service+c.oth_money-c.ar_service)  as nar_service";
        SQL += ",sum(c.fees+c.add_fees-c.ar_fees)  as nar_fees";
        SQL += " from step_dmt a,dmt_temp b, case_dmt c,apcust d ";
        SQL += " where cg = 'C' and rs = 'R' ";
        SQL += " and rs_no = main_rs_no ";
        SQL += " and b.case_sqlno = 0 ";
        SQL += " and a.case_no = c.case_no ";
        SQL += " and b.in_scode = c.in_scode and b.in_no = c.in_no ";
        SQL += " and c.cust_area = d.cust_area and c.cust_seq=d.cust_seq ";
        SQL += " and c.cust_area = '" + Session["seBranch"] + "' ";
        SQL += wSQL;
        using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
            if (dr.Read()) {
                cnt = dr.SafeRead("cnt", "0");
                class_count = dr.SafeRead("class_count", "0");
                service = dr.SafeRead("service", "0");
                fees = dr.SafeRead("fees", "0");
                oth_money = dr.SafeRead("oth_money", "0");
                total = dr.SafeRead("total", "0");
                nar_service = dr.SafeRead("nar_service", "0");
                nar_fees = dr.SafeRead("nar_fees", "0");
            }
        }
    }

    //[作業]
    protected string GetLink(RepeaterItem Container) {
        string link = "";

        //[維護]/[刪除]
        if (submitTask != "Q") {
            if ((HTProgRight & 8) != 0) {
                link += "<a href=\"brta22_edit.aspx?submitTask=U&prgid=" + prgid + "&rs_no=" + Eval("rs_no") + "&aseq=" + Eval("seq") + "&aseq1=" + Eval("seq1") + "&cgrs=" + cgrs + "&FrameBlank=50\" target=\"Eblank\">[維護]</a>";
            }
            if ((HTProgRight & 16) != 0 && Eval("step_grade").ToString() != "1" && Eval("rs_code").ToString() != "FC11" && Eval("rs_code").ToString() != "FC21" && Eval("rs_code").ToString().Left(2) != "FD") {
                link += "<a href=\"brta22_edit.aspx?submitTask=U&prgid=" + prgid + "&rs_no=" + Eval("rs_no") + "&aseq=" + Eval("seq") + "&aseq1=" + Eval("seq1") + "&cgrs=" + cgrs + "&FrameBlank=50\" target=\"Eblank\">[刪除]</a>";
            }

            //[查詢]
            link += "<a href=\"brta22_edit.aspx?submitTask=Q&prgid=" + prgid + "&rs_no=" + Eval("rs_no") + "&cgrs=" + cgrs + "&FrameBlank=50\" target=\"Eblank\">[查詢]</a>";
        }

        //[列印]
        string step_date = Eval("step_date", "{0:yyyy/M/d}");
        link += "<a href=\"brta4m.aspx?prgid=brta4m&cgrs=cr&step_date=" + step_date + "&rs_no=" + Eval("rs_no") + "&FrameBlank=50\" target=\"Eblank\">[列印]</a>";

        return link;
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

<table style="display:<%#page.totRow==0?"none":""%>" border="0" class="bluetable" cellspacing="1" cellpadding="2" width="100%" align="center" id="dataList">
	<tr align="center" class="lightbluetable">
		<td>營洽</td>
		<td>期間</td>
		<td>案件數</td>
		<td>類別數</td>
		<td>交辦服務費</td>
		<td>交辦規費</td>
		<td>轉帳金額</td>
		<td>交辦合計</td>
		<td>未請服務費</td>
		<td>未請款規費</td>
	</tr>
	<tr align="center" class="sfont9">
		<td>全部</td>			
		<td><%=Request["sstep_date"]%>~<%=Request["estep_date"]%></td>
		<td><%=cnt%></td>
		<td><%=class_count%></td>
		<td><%=service%></td>
		<td><%=fees%></td>
		<td><%=oth_money%></td>
		<td><%=total%></td>
		<td><%=nar_service%></td>
		<td><%=nar_fees%></td>
	</tr>
</table>
<br />

<form style="margin:0;" id="regPage" name="regPage" method="post">
    <%#page.GetHiddenText("GoPage,PerPage,SetOrder,chktest")%>
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
			    </font><%#DebugStr%>
		    </td>
	    </tr>
    </TABLE>
    </div>
</form>

<div align="center" id="noData" style="display:<%#page.totRow==0?"":"none"%>">
	<font color="red">=== 目前無資料 ===</font>
</div>

<form style="margin:0;" id="reg" name="reg" method="post">
    <asp:Repeater id="dataRepeater" runat="server">
    <HeaderTemplate>
        <table style="display:<%#page.totRow==0?"none":""%>" border="0" class="bluetable" cellspacing="1" cellpadding="2" width="100%" align="center" id="dataList">
	        <thead>
                  <Tr class="lightbluetable" align="center">
 		            <td nowrap>收/發</td>
		            <td nowrap>交辦單號</td>
		            <td nowrap>本所編號</td>
		            <td nowrap>進度<br>序號</td>
		            <td nowrap>營洽</td>
		            <td>客戶名稱</td>
		            <td nowrap>類別</td>
		            <td >案件名稱</td>
		            <td >案性</td>
		            <td nowrap>服務費</td>
		            <td nowrap>規費</td>
		            <td nowrap>合計</td>
		            <td nowrap>折扣</td>
		            <td nowrap>作業</td>
                 </Tr>
	        </thead>
	        <tbody>
    </HeaderTemplate>
			<ItemTemplate>
 		        <tr align="center" class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>">
		            <td><%#Eval("lcg")%><%#Eval("lrs")%></td>
                    <td align="center" nowrap>
                        <span style="cursor:pointer;color:darkblue" onmouseover="this.style.color='red'" onmouseout="this.style.color='darkblue'" onclick="CaseNoClick('<%#Eval("urlasp")%>')">
                            <%#Eval("case_no")%>
                        </span>
		            </td>
		            <td nowrap style="cursor:pointer;color:darkblue" onmouseover="this.style.color='red'" onmouseout="this.style.color='darkblue'" onclick="CapplClick('<%#Eval("seq")%>', '<%#Eval("seq1")%>')">
                        <%#Eval("fseq")%>
		            </td>
		            <td><%#Eval("step_grade")%></td>
		            <td><%#Eval("sc_name")%></td>
			        <td><%#Eval("cust_name")%></td>
			        <td>共<%#Eval("class_count")%>類</td>
			        <td><%#Eval("appl_name").ToString().ToUnicode().Left(20)%></td>
		            <td><%#Eval("rs_code")%><%#Eval("rs_codenm")%></td>
		            <td><%#Eval("service")%><%#Eval("loth_money")%></td>
			        <td><%#Eval("fees")%></td>
			        <td><%#Eval("total")%></td>
			        <td><%#Eval("discount","{0:0}")%></td>
		            <td align=center><%#GetLink(Container)%></td>
	            </tr>
			</ItemTemplate>
    <FooterTemplate>
	        </tbody>
        </table>
	    <BR>

        <table style="display:<%#page.totRow==0?"none":""%>" border="0" width="100%" cellspacing="0" cellpadding="0">
		    <tr class="FormName">
                <td align="center">
                ****** 服務費加註 <font color=red>*</font> 者, 表示該金額內含轉帳費用 ******
		        </td>
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
        $("select[id^='act_code_']").each(function(idx) {
            $(this).trigger("change");
        });

        $(".Lock").lock();
        $("input.dateField").datepick();
    }

    //執行查詢
    function goSearch() {
        $("#regPage").submit();
    };
    //////////////////////
    function CaseNoClick(url){
        //$('#dialog')
        //.html('<iframe style="border: 0px;" src="' + url + '" width="100%" height="100%"></iframe>')
        //.dialog({autoOpen: true,modal: true,height: 550,width: 800,title: "交辦內容"});
        window.open(url, "", "width=950,height=540,resizable=yes,scrollbars=yes,status=0,top=80,left=200");
        //window.showModalDialog(url, "", "dialogHeight: 540px; dialogWidth: 800px; center: Yes;resizable: No; status: No;scrollbars:yes");
        //window.parent.Eblank.location.href=url;
    }
    function CapplClick(pseq,pseq1){
        window.showModalDialog(getRootPath() + "/brt5m/brt15ShowFP.aspx?prgid=<%=prgid%>&seq=" + pseq + "&seq1=" + pseq1 + "&submittask=Q", "", "dialogHeight: 540px; dialogWidth: 800px; center: Yes;resizable: No; status: No;scrollbars:yes");
    }
</script>