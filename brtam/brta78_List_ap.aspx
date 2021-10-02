<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<script runat="server">
    protected string HTProgCap = "程序確認轉案(轉入)-申請人";//;//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "brta78";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";
    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";
    
    protected string SQL = "";
    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected Paging page = null;

    public Dictionary<string, string> Lock = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);

    protected string qs_dept = "", tdept = "", ap_tblname = "", sort = "";
    protected string fseqo = "";

    DBHelper conn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    DBHelper connbr = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    DBHelper cnn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    private void Page_Unload(System.Object sender, System.EventArgs e) {
        if (conn != null) conn.Dispose();
        if (connbr != null) connbr.Dispose();
        if (cnn != null) cnn.Dispose();
    }

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");

        qs_dept = (Request["qs_dept"] ?? "").ToLower();
        if (qs_dept == "t") {
            tdept = "T";
            ap_tblname = "dmt_ap";
            sort = "dmt_ap_sqlno";
        } else {
            tdept = "TE";
            ap_tblname = "ext_apcust";
            sort = "sqlno";
        }
        fseqo=Sys.formatSeq(ReqVal.TryGet("old_seq"),ReqVal.TryGet("old_seq1"),"",ReqVal.TryGet("databr_branch"),tdept);
        
        conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
        connbr = new DBHelper(Conn.brp(Request["databr_branch"])).Debug(Request["chkTest"] == "TEST");
        cnn = new DBHelper(Conn.Sysctrl).Debug(Request["chkTest"] == "TEST");

        TokenN myToken = new TokenN(HTProgCode);
        //HTProgRight = myToken.CheckMe();
        //HTProgCap = myToken.Title;
        DebugStr = myToken.DebugStr;
        //if (HTProgRight >= 0) {
        PageLayout();
        QueryData();
        this.DataBind();
        //}
    }

    private void PageLayout() {
        StrFormBtnTop += "<a class=\"imgCls\" href=\"javascript:void(0);\" >[關閉視窗]</a>\n";
    }

    private void QueryData() {
        if (qs_dept == "t") {
            SQL = "select a.*,b.ap_country,b.ap_crep,b.ap_erep,b.apclass,b.ap_ename1,b.ap_ename2";
        } else {
            SQL = "select a.*,a.ap_cname1+a.ap_cname2 as ap_cname,b.ap_country,b.ap_crep,b.ap_erep,b.apclass,b.ap_ename1,b.ap_ename2";
        }
        SQL += ",(select coun_c from sysctrl.dbo.country where coun_code=b.ap_country) as ap_countrynm";
        SQL += ",(select code_name from cust_code where code_type='apclass' and cust_code=b.apclass) as apclass_name ";
        SQL += ",''ap_crep_str,''urlasp_str,''urlasp ";
        SQL += " from " + ap_tblname + " as a ";
        SQL+="inner join apcust as b on a.apsqlno=b.apsqlno ";
        SQL += " where seq=" + Request["old_seq"] + " and seq1='" + Request["old_seq1"] + "'";
        SQL += " order by " + sort;
        DataTable dt = new DataTable();
        connbr.DataTable(SQL, dt);
        
        //處理分頁
        int nowPage = Convert.ToInt32(Request["GoPage"] ?? "1"); //第幾頁
        int PerPageSize = Convert.ToInt32(Request["PerPage"] ?? "10"); //每頁筆數
        page = new Paging(nowPage, PerPageSize, SQL);
        page.GetPagedTable(dt);

        //分頁完再處理其他資料才不會虛耗資源
        for (int i = 0; i < page.pagedTable.Rows.Count; i++) {
            DataRow dr = page.pagedTable.Rows[i];

            dr["ap_crep_str"] = dr.SafeRead("ap_crep", "");
            if (dr.SafeRead("ap_erep", "") != "") {
                dr["ap_crep_str"] += "/" + dr.SafeRead("ap_erep", "");
            }

            ChkAPCust(dr);
        }

        dataRepeater.DataSource = page.pagedTable;
        dataRepeater.DataBind();
    }

    //檢查申請人是否存在
    protected void ChkAPCust(DataRow dr) {
        string urlasp_str = "新增申請人";
        string urlasp_Task = "A";
        string apcust_no = dr.SafeRead("apcust_no", "");
        string apsqlno = dr.SafeRead("apsqlno", "");
        string databr_branch=Request["databr_branch"];
        
        SQL = "select * from apcust ";
        SQL += " where (isnull(rtrim(ap_cname1),'')+isnull(rtrim(ap_cname2),'')='" + dr.SafeRead("ap_cname", "") + "'";
        SQL += " or apcust_no='" + dr.SafeRead("apcust_no", "") + "')";
        using (SqlDataReader dr0 = conn.ExecuteReader(SQL)) {
            if (dr0.Read()) {
                urlasp_str = "申請人查詢";
                urlasp_Task = "Q";
                apcust_no = dr0.SafeRead("apcust_no", "");
                apsqlno = dr0.SafeRead("apsqlno", "");
				//有找到客戶表示要抓本所apcust,不帶區所別
				databr_branch="";
            }
        }

        //***todo
        string urlasp = "/cust/cust13_edit.aspx?prgid=" + prgid;
        urlasp += "&submitTask=" + urlasp_Task + "&tran_flag=B&modify=" + urlasp_Task;
        urlasp += "&databr_branch=" + databr_branch + "&old_branch=" + Request["old_branch"];
        urlasp += "&old_seq=" + dr.SafeRead("seq", "") + "&old_seq1=" + dr.SafeRead("seq1", "") + "&qs_dept=" + Request["qs_dept"];
        urlasp += "&apcust_no=" + apcust_no + "&apsqlno=" + apsqlno;

        dr["urlasp_str"] = urlasp_str;
        dr["urlasp"] = Page.ResolveUrl("~" + urlasp);
    }
</script>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title><%#HTProgCap%></title>
    <uc1:head_inc_form runat="server" ID="head_inc_form" />
</head>

<body>
<table cellspacing="1" cellpadding="0" width="98%" border="0" align="center">
    <tr>
        <td class="text9" nowrap="nowrap">&nbsp;【<%#prgid%> <%#HTProgCap%>】</td>
        <td class="FormLink" valign="top" align="right" nowrap="nowrap">
            <%#StrFormBtnTop%>
        </td>
    </tr>
    <tr>
        <td colspan="2"><hr class="style-one"/></td>
    </tr>
</table>

<form id="regPage" name="regPage" method="post">
    <input type="hidden" id="prgid" name="prgid" value="<%=prgid%>">
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
      <Tr class=lightbluetable align=center>
		<td nowrap>作業</td>
		<td nowrap>申請人ID</td>
		<td nowrap>申請人名稱</td>
		<td nowrap>代表人</td>
		<td nowrap>申請人種類</td>
		<td nowrap>申請人國籍</td>
      </Tr>
	</thead>
</HeaderTemplate>
<ItemTemplate>
	<tr align="center" class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>">
		<td nowrap>
			<a href="<%#Eval("urlasp")%>" target="Eblank">[<%#Eval("urlasp_str")%>]</a>
		</td>
		<td nowrap><%#Eval("apcust_no")%></td>
		<td align="left"><%#Eval("ap_cname")%></td>
		<td align="left"><%#Eval("ap_crep_str")%></td>
		<td align="left"><%#Eval("apclass")%>_<%#Eval("apclass_name")%></td>
		<td align="left"><%#Eval("ap_country")%>_<%#Eval("ap_countrynm")%></td>
	</tr>

</ItemTemplate>
<FooterTemplate>
</TABLE>
</FooterTemplate>
</asp:Repeater>
<br />
<div align="center" id="haveData" style="display:<%#page.totRow==0?"":"none"%>">
</div>

<div id="dialog"></div>

</body>
</html>


<script language="javascript" type="text/javascript">
    $(function () {
        this_init();
    });

    function this_init() {
        if (window.parent.tt !== undefined) {
            window.parent.tt.rows = "10%,90%";
        }

        $("input.dateField").datepick();
        $(".Lock").lock();
    }

    //執行查詢
    function goSearch() {
        $("#regPage").submit();
    };
    //////////////////////
</script>
