<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<script runat="server">
    protected string HTProgCap = "國內案件狀態查詢作業-流程";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = HttpContext.Current.Request["prgid"] ?? "";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";

    protected string SQL = "";
    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected Paging page = null;

    //protected string seq = "";
    //protected string seq1 = "";
    protected string fseq = "";
    protected string appl_name = "";
    protected string sc_name = "";
    protected string now_step_grade = "";
    protected string now_statnm = "";
    
    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");

        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        //HTProgCap = myToken.Title;
        if (HTProgRight >= 0) {
            PageLayout();
            QueryData();
            this.DataBind();
        }
    }

    private void PageLayout() {
        //StrFormBtnTop += "<a class=\"imgRefresh\" href=\"javascript:void(0);\" >[重新整理]</a>\n";
        if ((HTProgRight & 2) > 0) {
            //StrFormBtn += "<input type=\"button\" id=\"btnSrch\" value=\"查　詢\" class=\"cbutton bsubmit\" />\n";
            //StrFormBtn += "<input type=\"button\" id=\"btnRest\" value=\"重　填\" class=\"cbutton\" />\n";
        }
    }

    private void QueryData() {
        using (DBHelper conn = new DBHelper(Conn.btbrt, false)) {
            SQL = "select a.*,c.appl_name,c.step_grade as now_step_grade,b.cg,b.rs,''pcgrs ";
            SQL += ",(select code_name from cust_code where code_type='tcase_stat' and cust_code=c.now_stat) as now_statnm ";
            SQL += ",(select code_name from cust_code where code_type='ttodo' and cust_code=a.dowhat) as dowhat_nm ";
            SQL += ",(select code_name from cust_code where code_type='tjob_status' and cust_code=a.job_status) as job_statnm ";
            SQL += ",(select sc_name from sysctrl.dbo.scode where scode=c.scode) as sc_name ";
            SQL += ",(select sc_name from sysctrl.dbo.scode where scode=a.job_scode) as jobsc_name ";
            SQL += ",(select sc_name from sysctrl.dbo.scode where scode=a.approve_scode) as apsc_name ";
            SQL += "from todo_dmt a ";
            SQL += "inner join dmt c on a.seq=c.seq and a.seq1=c.seq1 ";
            SQL += "left outer join step_dmt b on a.seq=b.seq and a.seq1=b.seq1 and a.step_grade=b.step_grade ";
            SQL += "where a.seq=" + ReqVal.TryGet("seq") + " and a.seq1='" + ReqVal.TryGet("seq1") + "' ";
            SQL += "order by a.in_date desc";

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

                fseq = Sys.formatSeq(dr.SafeRead("seq", ""), dr.SafeRead("seq1", ""), dr.SafeRead("country", ""), Sys.GetSession("SeBranch"), Sys.GetSession("dept")); appl_name = dr.SafeRead("appl_name", "");
                sc_name = dr.SafeRead("sc_name", "");
                now_step_grade = dr.SafeRead("now_step_grade", "");
                now_statnm = dr.SafeRead("now_statnm", "");

                string pcgrs = "";
                switch (dr.SafeRead("cg", "")) {
                    case "C": pcgrs = "(客"; break;
                    case "G": pcgrs = "(官"; break;
                    case "Z": pcgrs = "(本"; break;
                }
                switch (dr.SafeRead("rs", "")) {
                    case "R": pcgrs += "收)"; break;
                    case "S": pcgrs += "發)"; break;
                    case "Z": pcgrs = ""; break;
                }
                dr["pcgrs"] = pcgrs;
            }

            dataRepeater.DataSource = page.pagedTable;
            dataRepeater.DataBind();
        }
    }
</script>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
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
            <a class="imgCls" href="javascript:void(0);" >[關閉視窗]</a>
        </td>
    </tr>
    <tr>
        <td colspan="2"><hr class="style-one"/></td>
    </tr>
</table>
<table cellspacing="1" cellpadding="0" width="98%" border="0" align="center">
	<tr>
		<td class="text9" style="color:blue" width="20%">
            案件編號：<%#fseq%>
		</td>
		<td class="text9" style="color:blue">案件名稱：<%#appl_name%>
		</td>
	</tr>
	<tr>	
		<td class="text9" style="color:blue">
            營洽：<%#sc_name%>
		</td>
		<td class="text9" style="color:blue">
            目前進度：<%#now_step_grade%>&nbsp;&nbsp;案件狀態：<%#now_statnm%>
		</td>
	</tr>
</table>
<br>
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
		<TD class="lightbluetable" align=center>進度</TD>
		<TD class="lightbluetable" align=center>交辦單號</TD>
		<TD class="lightbluetable" align=center>分派日期</TD>
		<TD class="lightbluetable" align=center>預計<br>處理人員</TD>
		<TD class="lightbluetable" align=center>管制日期</TD>
		<TD class="lightbluetable" align=center>實際<br>處理人員</td>
		<TD class="lightbluetable" align=center>實際處理日期</TD>
		<TD class="lightbluetable" align=center>狀態</TD>
		<TD class="lightbluetable" align=center>處理情形</TD>
		<TD class="lightbluetable" align=center>處理說明</TD>
      </tr>
	</thead>
</HeaderTemplate>
<ItemTemplate>
 	<tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>">
		<td align=center nowrap><%#Eval("step_grade")%><%#Eval("pcgrs")%></td>
		<td align=center nowrap><%#Eval("case_no")%></td>
		<td align=center><%#Eval("in_date")%></td>
		<td align=center nowrap><%#Eval("jobsc_name")%></td>
		<td align=center nowrap><%#Eval("ctrl_date")%></td>
		<td align=center nowrap><%#Eval("apsc_name")%></td>
		<td align=center><%#Eval("resp_date")%></td>
		<td align=center nowrap ><%#Eval("dowhat_nm")%></td>
		<td align=center nowrap><span id="stat_color_<%#(Container.ItemIndex+1)%>"><%#Eval("job_statnm")%></span></td>
		<td align=center ><%#Eval("approve_desc")%></td>
	</tr>
</ItemTemplate>
<FooterTemplate>
</TABLE>
</FooterTemplate>
</asp:Repeater>

    <%#DebugStr%>
</form>

<div id="dialog"></div>

</body>
</html>

<script language="javascript" type="text/javascript">
    $(function () {
        this_init();
    });

    function this_init() {
        if (window.parent.tt !== undefined) {
            window.parent.tt.rows = "30%,*";
        }
    }

    //執行查詢
    function goSearch() {
        $("#regPage").submit();
    };
</script>
