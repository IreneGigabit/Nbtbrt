<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<script runat="server">
    protected string HTProgCap = "國內商標案件數清單";//HttpContext.Current.Request["prgname"];//功能名稱
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

    protected string submitTask = "";

    protected string rptTitle = "";//報表抬頭
    protected string dept = "";
    protected string branch = "";
    protected string rs_class = "";
    protected string scode1 = "";
    protected string step_dates = "";
    protected string step_datee = "";

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

        dept = ReqVal.TryGet("dept");
        branch = ReqVal.TryGet("branch");
        rs_class = ReqVal.TryGet("rs_class");
        scode1 = ReqVal.TryGet("scode1");
        step_dates = ReqVal.TryGet("step_dates");
        step_datee = ReqVal.TryGet("step_datee");
        
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
        if (dept == "T") HTProgCap += "-國內案";
        else if (dept == "TE") HTProgCap += "-出口案";

        if (rs_class == "A1") HTProgCap += "新申請案";
        else if (rs_class == "A4" || rs_class == "A5") HTProgCap += "延展案";
        else HTProgCap += "新申請案及延展案";

        StrFormBtnTop += "<a class=\"imgCls\" href=\"javascript:void(0);\" >[關閉視窗]</a>";
        StrFormBtnTop += "<a class=\"imgRefresh\" href=\"javascript:void(0);\" >[重新整理]</a>";

        if (ReqVal.TryGet("qrykindDate") != "") {
            rptTitle = "<font color=blue>*單位：" + Sys.bName(branch) + "&nbsp;&nbsp;*客戶收文期間：" + step_dates + "~" + step_dates + "</font>";
        }
    }

    private void QueryData() {
        using (DBHelper connbr = new DBHelper(Conn.brp(branch)).Debug(Request["chkTest"] == "TEST")) {
            string wSQL = "";
            if (step_dates != "") {
                wSQL += " and a.step_date >= '" + step_dates + "'";
            }
            if (step_datee != "") {
                wSQL += " and a.step_date <= '" + step_datee + "'";
            }

            if (rs_class != "") {
                if (rs_class == "A1" && dept == "T") {
                    wSQL += " and a.rs_class in ('" + rs_class + "','A0')";
                } else {
                    wSQL += " and a.rs_class = '" + rs_class + "'";
                }
            }

            string iSQLp = "select 'T' as dept,a.seq,a.seq1,'T' as country,a.cappl_name as appl_name,a.step_grade,a.class,a.step_date,a.rs_detail";
            iSQLp += ",a.cust_area,a.cust_seq,a.dmt_scode as scode1,a.end_date,a.ap_cname1 as apcustnm,a.rs_class";
            iSQLp += ",(select sc_name from sysctrl.dbo.scode where scode=a.dmt_scode) as scode1nm,''fseq";
            iSQLp += " from vstep_dmt a";
            iSQLp += " where a.cg='C' and a.rs='R' and a.rs_class in ('A1','A4','A0') ";
            iSQLp += wSQL;
            if (scode1 != "") {
                iSQLp += " and a.dmt_scode = '" + scode1 + "'";
            }

            string iSQLpe = "select 'TE' as dept,a.seq,a.seq1,a.country,a.appl_name,a.step_grade,a.class,a.step_date,a.rs_detail";
            iSQLpe += ",a.cust_area,a.cust_seq,a.ext_scode as scode1,a.end_date,a.ap_cname1 as apcustnm,a.rs_class";
            iSQLpe += ",(select sc_name from sysctrl.dbo.scode where scode=a.ext_scode) as scode1nm,''fseq";
            iSQLpe += " from vstep_ext a";
            iSQLpe += " where a.cg='C' and a.rs='R'  and a.rs_class in ('A1','A5') ";
            iSQLpe += wSQL;
            if (scode1 != "") {
                iSQLpe += " and a.ext_scode = '" + scode1 + "'";
            }

            if (dept == "T") {
                SQL = iSQLp;
            } else if (dept == "TE") {
                SQL = iSQLpe;
            } else {
                SQL = iSQLp + " union " + iSQLpe;
            }
            SQL += " order by dept,a.rs_class,a.seq,a.seq1";
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

                if (dr.SafeRead("dept", "") == "T") {
                    dr["fseq"] = Sys.formatSeq(dr.SafeRead("Seq", ""), dr.SafeRead("Seq1", ""), "", Sys.GetSession("SeBranch"), "T");
                } else {
                    dr["fseq"] = Sys.formatSeq(dr.SafeRead("Seq", ""), dr.SafeRead("Seq1", ""), dr.SafeRead("country", ""), Sys.GetSession("SeBranch"), "TE");
                }

                if (dr.SafeRead("end_date", "") != "") {
                    dr["fseq"] = "<font color=red>*</font>" + dr["fseq"];
                }
            }

            dataRepeater.DataSource = page.pagedTable;
            dataRepeater.DataBind();
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
        <td class="text9" nowrap="nowrap">&nbsp;【<%=prgid%> <%=HTProgCap%>】<%=rptTitle%></td>
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
                  <Tr class="lightbluetable" align="center">
		            <td nowrap>案件編號</td>
		            <td>案件名稱</td>
		            <td nowrap>進度</td>
		            <td nowrap>類別</td>
		            <td nowrap>進度日期</td>
		            <td>收文案性</td>
		            <td>客戶</td>
		            <td nowrap>營洽</td>
                 </Tr>
	        </thead>
	        <tbody>
    </HeaderTemplate>
			<ItemTemplate>
 		        <tr align="center" class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>">
                    <td nowrap><%#Eval("fseq")%></td>
				    <td nowrap><%#Eval("appl_name")%></td>
				    <td nowrap><%#Eval("step_grade")%></td>
				    <td nowrap><%#Eval("class")%></td>
				    <td nowrap><%#Eval("step_date","{0:yyyy/M/d}")%></td>
				    <td nowrap><%#Eval("rs_detail")%></td>
				    <td nowrap><%#Eval("cust_seq")%><%#Eval("apcustnm")%></td>
				    <td nowrap><%#Eval("scode1nm")%></td>
		        </tr>
			</ItemTemplate>
    <FooterTemplate>
	        </tbody>
        </table>
	    <BR>

        <table style="display:<%#page.totRow==0?"none":""%>" border="0" width="100%" cellspacing="0" cellpadding="0">
		    <tr class="FormName"><td>
			    <div style="color:blue">
	                <font color=red>*</font>：表已結案
			    </div>
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
            window.parent.tt.rows = "30%,70%";
        }

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
    //////////////////////
</script>