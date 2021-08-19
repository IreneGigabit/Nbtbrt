<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<script runat="server">
    protected string HTProgCap = "英文商品資料";// HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "Eitem";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";

    protected string SQL = "";

    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected Paging page = null;
    
    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";
    protected string FormName = "";

    protected string submitTask = "";
    protected string homelist = "";

    DataTable dt = new DataTable();
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

        conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
        cnn = new DBHelper(Conn.Sysctrl).Debug(Request["chkTest"] == "TEST");

        ReqVal = Util.GetRequestParam(Context,Request["chkTest"] == "TEST");
        submitTask = Request["submitTask"] ?? "";

        homelist = ReqVal.TryGet("homelist").ToLower();

        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        HTProgCap = myToken.Title;
        DebugStr = myToken.DebugStr;
        if (HTProgRight >= 0) {
            QueryData();
            PageLayout();

            this.DataBind();
        }
    }

    private void PageLayout() {
        if (ReqVal.TryGet("frameblank") != "") {
            StrFormBtnTop += "<a class=\"imgCls\" href=\"javascript:void(0);\" >[關閉視窗]</a>";
        } else {
            StrFormBtnTop += "<a class=\"imgRefresh\" href=\"javascript:void(0);\" >[重新整理]</a>";
            StrFormBtnTop += "<a href=\"" + HTProgPrefix + ".aspx?prgid=" + prgid + "\" >[回查詢]</a>";
        }
    }

    private void QueryData() {
        if (ReqVal.TryGet("GoPage") == "") {
            SQL = "INSERT INTO TcnUse(Scode, StartDate, EProd, E_NameQueryWay, Class) VALUES ";
            SQL += "(" + Util.dbnull(Sys.GetSession("scode"));
            SQL += ",getdate()";
            SQL += "," + Util.dbnull(ReqVal.TryGet("tfx_e_name"));
            SQL += "," + Util.dbnull("8");
            SQL += "," + Util.dbnull(ReqVal.TryGet("tfx_class"));
            SQL += ")";
            conn.ExecuteNonQuery(SQL);
        }

        SQL = "SELECT * FROM eitem WHERE 1=1 ";
        if (ReqVal.TryGet("class") != "") {
            SQL += "AND class ='" + ReqVal.TryGet("class") + "' ";
        }

        if (ReqVal.TryGet("tfx_class") != "") {
            SQL += "AND class in(" + ParseClass(ReqVal.TryGet("tfx_class")) + ") ";
        }

        if (ReqVal.TryGet("tfx_e_name") != "") {
            SQL += "AND e_name like '%" + Request["tfx_e_name"] + "%' ";
        }

        string odr = "";
        if (ReqVal.TryGet("tfx_class") != "" || ReqVal.TryGet("class") != "") {
            odr = "class";
        } else {
            odr = "e_name";
        }
        ReqVal["qryOrder"] = ReqVal.TryGet("SetOrder", odr);
        if (ReqVal.TryGet("qryOrder") != "") {
            SQL += " order by " + ReqVal.TryGet("qryOrder");
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
        }

        dataRepeater.DataSource = page.pagedTable;
        dataRepeater.DataBind();
    }
    
    //展開類別
    protected string ParseClass(string str) {
        string ret = "";
        string[] arr = str.Trim().Split(',');

        foreach (string i in arr) {
            if (i.IndexOf("-") > -1) {
                string[] b = i.Trim().Split('-');
                int mMin = Math.Min(Convert.ToInt32(b[0]), Convert.ToInt32(b[1]));
                int mMax = Math.Max(Convert.ToInt32(b[0]), Convert.ToInt32(b[1]));
                for (int m = mMin; m <= mMax; m++) {
                    ret += ",'" + m.ToString().PadLeft(2, '0') + "'";
                }
            } else {
                ret += ",'" + i.Trim().PadLeft(2, '0') + "'";
            }
        }

        return ret != "" ? ret.Substring(1) : ret;
    }
    
    //變色
    protected string highlight(string strFull, string strMatch) {
        if (strMatch != "") {
            //string strFull = "1 fruit 2 Fruit 3";
            Regex rgx = new Regex("(" + strMatch + ")", RegexOptions.IgnoreCase);
            foreach (Match m in rgx.Matches(strFull)) {
                strFull = strFull.Replace(m.Value, "<font color='red'>" + m.Result("$1") + "</font>");
            }
        }
        
        return strFull;
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
<input type="hidden" id="prgid" name="prgid" value="<%=prgid%>">

<asp:Repeater id="dataRepeater" runat="server">
<HeaderTemplate>
    <table style="display:<%#page.totRow==0?"none":""%>" border="0" class="bluetable" cellspacing="1" cellpadding="2" width="95%" align="center" id="dataList">
	    <thead>
            <Tr class="lightbluetable">
	            <td align=center>商品名稱</td>
	            <td align=center>類別</td>
            </Tr>
	    </thead>
	    <tbody>
</HeaderTemplate>
			<ItemTemplate>
 		        <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>">
	                <TD><a href="Eitem_Edit.aspx?prgid=<%=prgid%>&submitTask=Q&sqlno=<%#Eval("sqlno")%>" target=Eblank><%#highlight(Eval("e_name").ToString(), ReqVal.TryGet("tfx_e_name"))%></a></TD>
	                <TD><a href="<%=HTProgPrefix%>_List.aspx?prgid=<%=prgid%>&class=<%#Eval("class")%>&frameblank=Y" target=Eblank><%#Eval("class")%></a></TD>
				</tr>
			</ItemTemplate>
<FooterTemplate>
	    </tbody>
    </table>
	<BR>
    <table style="display:<%#page.totRow==0?"none":""%>" border="0" width="100%" cellspacing="0" cellpadding="0">
		<tr class="FormName"><td><div align="left" style="color:blue"><%#FormName%></div></td></tr>
	</table>
	<br>
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
            if ("<%=Request["frameblank"]%>" == "") {
                window.parent.tt.rows = "100%,0%";
            } else {
                window.parent.tt.rows = "*,2*";
            }
        }

        this_init();
    });

    function this_init() {
        if ("<%=ReqVal.TryGet("class")%>" != "") {
            $('#dataList a').each(function (index) {
                $(this).replaceWith($(this).html());
            });
        }

        $(".Lock").lock();
        $("input.dateField").datepick();
    }

    //執行查詢
    function goSearch() {
        $("#regPage").submit();
    };
    //////////////////////
</script>
