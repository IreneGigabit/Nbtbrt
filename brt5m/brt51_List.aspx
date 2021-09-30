<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Linq"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<script runat="server">
    protected string HTProgCap = "程序客收確認作業";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgCode = "brt51";//HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string HTProgPrefix = "brt51";//程式檔名前綴
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";

    protected string SQL = "";
    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected Paging page = null;

    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";
    protected string FormName = "";

    protected string todo = "";
    protected string sdate = "";
    protected string edate = "";
    
    DBHelper conn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    private void Page_Unload(System.Object sender, System.EventArgs e) {
        if (conn != null) conn.Dispose();
    }

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");

        todo = Request["todo"] ?? "";
        if (todo == "") todo = "DC";
        sdate = Request["sdate"] ?? "";
        edate = Request["edate"] ?? "";
        if (Request["homelist"] == "homelist") {
            sdate = "";
            edate = "";
        } else {
            if (sdate == "") sdate = DateTime.Today.AddDays(-7).ToShortDateString();
            if (edate == "") edate = DateTime.Today.ToShortDateString();
        }

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
        StrFormBtnTop += "<a href='" + HTProgPrefix + ".aspx?prgid=" + prgid + "'>[回查詢]</a>";
    }

    private void QueryData() {
        DataTable dt = new DataTable();
        SQL = "SELECT a.seq,a.seq1,a.in_scode, a.in_no, a.service, a.fees,a.oth_money, b.appl_name,a.case_date,a.stat_code,a.arcase_type,a.arcase_class ";
        SQL += ",ISNULL(a.Discount, 0) AS discount, a.Service + a.Fees + a.oth_money AS allcost ";
        SQL += ",b.class, a.arcase, a.ar_mark, ISNULL(a.discount, 0) AS discount, d.cust_name ";
        SQL += ",a.case_num, a.stat_code, a.cust_area, a.cust_seq,a.case_no,a.ar_service,a.ar_fees,a.ar_code,a.ar_curr,a.mark ";
        SQL += ",(SELECT ChRelName FROM Relation WHERE ChRelType ='scode' AND chrelno = a.stat_code) AS Nstat_code ";
        SQL += ",f.rs_class as Ar_form,f.prt_code,f.mark AS codemark,f.Rs_detail as CArcase,e.sc_name,c.sqlno ";
        SQL += ",''link_remark,''fcust_name,''fseq,''fappl_name,''urlasp,''step_grade ";
        SQL += " FROM case_dmt a ";
        SQL += " INNER JOIN dmt_temp b ON a.in_scode = b.in_scode AND a.in_no = b.in_no and b.case_sqlno=0 ";
        SQL += " INNER JOIN todo_dmt c ON a.in_no = c.in_no AND a.in_scode = c.case_in_scode ";
        SQL += " INNER JOIN VIEW_Cust d ON a.cust_seq = d.cust_seq AND a.cust_area = d.cust_area ";
        SQL += " INNER JOIN sysctrl.dbo.scode e ON a.In_scode = e.scode ";
        SQL += " INNER JOIN code_br f ON a.arcase=f.rs_code and a.arcase_type=f.rs_type and f.cr='Y' and f.dept='T' ";
        SQL += " where (a.mark='N' or a.mark is null) and c.apcode in('Si04W02','brt31') ";
        SQL += " and c.job_status = 'NN' and c.dowhat = '" + todo + "'";

        if (sdate != "" && edate != "") {
            SQL += " and c.in_date between '" + sdate + " 00:00:00' and '" + edate + " 23:59:59'";
        }
        if (ReqVal.TryGet("sin_no") != "") {
            SQL += " and c.in_no >= '" + ReqVal.TryGet("sin_no") + "'";
        }
        if (ReqVal.TryGet("ein_no") != "") {
            SQL += " and c.in_no <= '" + ReqVal.TryGet("ein_no") + "'";
        }
        if (ReqVal.TryGet("scode") != "*" && ReqVal.TryGet("scode") != "") {
            SQL += " and c.case_in_scode = '" + ReqVal.TryGet("scode") + "'";
        }
        if (ReqVal.TryGet("qryOrder") != "") {
            SQL += " order by " + ReqVal.TryGet("qryOrder");
        } else {
            SQL += " order by e.sscode,a.in_no";
        }
        Sys.showLog(SQL);
        conn.DataTable(SQL, dt);

        //處理分頁
        int nowPage = Convert.ToInt32(Request["GoPage"] ?? "1"); //第幾頁
        int PerPageSize = Convert.ToInt32(Request["PerPage"] ?? "10"); //每頁筆數
        page = new Paging(nowPage, PerPageSize, SQL);
        page.GetPagedTable(dt);

        //分頁完再處理其他資料才不會虛耗資源
        for (int i = 0; i < page.pagedTable.Rows.Count; i++) {
            DataRow dr = page.pagedTable.Rows[i];
            
            SQL = "Select remark from cust_code where cust_code='__' and code_type='" + dr["arcase_type"] + "'";
            object objResult = conn.ExecuteScalar(SQL);
            string link_remark = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();
            dr["link_remark"] = link_remark;//案性版本連結

            dr["fseq"] = Sys.formatSeq1(dr.SafeRead("seq", ""), dr.SafeRead("seq1", ""), "", "", "");
            dr["fcust_name"] = dr.SafeRead("cust_name", "").ToUnicode().Left(5);
            dr["fappl_name"] = dr.SafeRead("appl_name", "").ToUnicode().Left(20);
            //dr["urlasp"] = GetLink(dr);
            dr["urlasp"] = Sys.getCase11Aspx(prgid, dr.SafeRead("in_no", ""), dr.SafeRead("in_scode", ""), "Edit") + "&code=" + dr["sqlno"];//todo.sqlno
        }

        dataRepeater.DataSource = page.pagedTable;
        dataRepeater.DataBind();
    }

    //protected string GetLink(DataRow row) {
    //    string urlasp = "";//連結的url
    //    string new_form = Sys.getCaseDmtAspx(row.SafeRead("arcase_type", ""), row.SafeRead("arcase", ""));//連結的aspx
    //    string link_remark = row.SafeRead("link_remark", "");
    //
    //    urlasp = Page.ResolveUrl("~/brt1m" + link_remark + "/Brt11Edit" + new_form + ".aspx?prgid=" + prgid);
    //    urlasp += "&in_scode=" + row["in_scode"];
    //    urlasp += "&in_no=" + row["in_no"];
    //    //urlasp += "&case_no=" + row["case_no"];
    //    //urlasp += "&seq=" + row["seq"];
    //    //urlasp += "&seq1=" + row["seq1"];
    //    urlasp += "&add_arcase=" + row["arcase"];
    //    urlasp += "&cust_area=" + row["cust_area"];
    //    urlasp += "&cust_seq=" + row["cust_seq"];
    //    urlasp += "&ar_form=" + row["ar_form"];
    //    urlasp += "&new_form=" + new_form;
    //    urlasp += "&code_type=" + row["arcase_type"];
    //    urlasp += "&ar_code=" + row["ar_code"];
    //    //urlasp += "&mark=" + row["mark"];
    //    //urlasp += "&ar_service=" + row["ar_service"];
    //    //urlasp += "&ar_fees=" + row["ar_fees"];
    //    //urlasp += "&ar_curr=" + row["ar_curr"];
    //    //urlasp += "&step_grade=" + row["step_grade"];
    //    urlasp += "&homelist=" + Request["homelist"];
    //    urlasp += "&code=" + row["sqlno"];//todo.sqlno
    //    urlasp += "&uploadtype=case";
    //    urlasp += "&submittask=Edit";
    //    
    //    return urlasp;
    //}

    protected string GetTodoLink(RepeaterItem Container) {
            return "<a href='" + Page.ResolveUrl("~/Brt4m/Brt13_ListA.aspx") +
                    "?prgid=" + prgid +
                    "&in_scode=" + Eval("in_scode") +
                    "&in_no=" + Eval("in_no") +
                    "&homelist=" + Request["homelist"] +
                    "&qs_dept=T' target='Eblank'>簽核</a>";
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title><%=HTProgCap%></title>
    <uc1:head_inc_form runat="server" ID="head_inc_form" />
</head>

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
            <Tr>
	            <td align="center" class="lightbluetable">作業</td>
	            <td align="center" class="lightbluetable">接洽序號</td>
	            <td align="center" class="lightbluetable">客戶名稱</td>
	            <td align="center" class="lightbluetable">案件編號</td>	
	            <td align="center" class="lightbluetable">案件名稱</td>
	            <td align="center" class="lightbluetable">案性</td>
	            <td align="center" class="lightbluetable">服務費</td>
	            <td align="center" class="lightbluetable">規費</td>
	            <td align="center" class="lightbluetable">轉帳<br>費用</td>
	            <td align="center" class="lightbluetable">合計</td>
	            <td align="center" class="lightbluetable">折扣</td>
	            <td align="center" class="lightbluetable">註記</td>
            </tr>
	    </thead>
	    <tbody>
</HeaderTemplate>
			<ItemTemplate>
 		        <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>">
	                <td class="whitetablebg" align="center" style="cursor:pointer;color:darkblue" onmouseover="this.style.color='red'" onmouseout="this.style.color='darkblue'" onclick="linkedit('<%#Eval("in_scode")%>','<%#Eval("in_no")%>','<%#Eval("urlasp")%>')">[確認]</td>
	                <td class="whitetablebg" align="center"><%#Eval("sc_name")%>-<%#Eval("in_no")%></td>
	                <td class="whitetablebg" align="center"><%#Eval("fcust_name")%></td>
	                <td class="whitetablebg" align="center"><%#Eval("fseq")%></td>
	                <td class="whitetablebg" align="center"><%#Eval("fappl_name")%></td>
	                <td class="whitetablebg" align="center"><%#Eval("Arcase")%><%#Eval("CArcase")%></td>
	                <td class="whitetablebg" align="center"><%#Eval("service")%></A></td>
	                <td class="whitetablebg" align="center"><%#Eval("fees")%></A></td>
	                <td class="whitetablebg" align="center"><%#Eval("oth_money")%></A></td>
	                <td class="whitetablebg" align="center"><%#Eval("allcost")%></A></td>
		            <td align="center">
                        <%#Convert.ToDecimal(Eval("discount"))>0 ? Eval("discount","{0:0.##}")+"%":""%>
                    </TD>
	                <td class="whitetablebg" align="center" title="主管簽核說明">
                        <A href="<%#Page.ResolveUrl("~/Brt4m/brt13_ListA.aspx?prgid=" + prgid+"&in_scode="+Eval("in_scode")+"&in_no="+Eval("in_no")+"&qs_dept=T&homelist="+Request["homelist"])%>" target="Eblank">
                        簽核
                        </A>
                    </td>
				</tr>
			</ItemTemplate>
<FooterTemplate>
	    </tbody>
    </table>
    <BR>
    <table border="0" width="100%" cellspacing="0" cellpadding="0">
		<tr class="FormName"><td>
			<div align="left">
			備註:<br>
			<!--1.註記有顯示「說明」，表示主管簽核時有輸入簽核說明，可點選「說明」查詢內容。-->
			1.註記顯示之「簽核」，可點選查詢簽核流程。
			</div>
		</td></tr>
	</table>
</FooterTemplate>
</asp:Repeater>

    <%#DebugStr%>
</form>

<div id="dialog"></div>

</body>
</html>

<script language="javascript" type="text/javascript">
    $(function () {
        if (window.parent.tt !== undefined) {
            window.parent.tt.rows = "100%,0%";
        }

        $(".Lock").lock();
        $("input.dateField").datepick();
    });
    //執行查詢
    function goSearch() {
        $("#regPage").submit();
    };
    //////////////////////
    function linkedit(tin_socde,tin_no,tlink) {
        var url = getRootPath() +"/ajax/case_dmt_status.aspx?in_scode=" + tin_socde + "&in_no=" + tin_no;
        ajaxScriptByGet("檢查案件狀態", url);
        if (jBreak) return false;//由ajaxScriptByGet呼叫的程式指定值
        if (jStat_code != "YY") {//由ajaxScriptByGet呼叫的程式指定值
            alert("本筆交辦(接洽序號：" + tin_no + ")已確認或案件狀態已改變，無法執行確認，請回系統首頁，重新由客收未確認清單進入！");
            return false;
        }

        window.parent.Eblank.location.href = tlink;
    }
</script>