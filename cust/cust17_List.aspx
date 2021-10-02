<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Linq"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<script runat="server">
    protected string HTProgCap = "發明/創作人資料清單";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = HttpContext.Current.Request["prgid"] ?? "";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";

    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected Paging page = null;

    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";
    protected string FormName = "";
    protected string submitTask = "";
    
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
        //foreach (var item in ReqVal)
        //{
        //    Response.Write("[Key:" + item.Key + "," + "Value:" + item.Value + "],");
        //}
        conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
        cnn = new DBHelper(Conn.Sysctrl).Debug(Request["chkTest"] == "TEST");

        submitTask = Request["submitTask"];

        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        //HTProgCap = myToken.Title;
        DebugStr = myToken.DebugStr;
        if (HTProgRight >= 0) {
            PageLayout();
            QueryData();
            this.DataBind();
        }
    }

    private void PageLayout()
    {
        if ((HTProgRight & 2) > 0)
        {
            //StrFormBtnTop += "<a href=\"javascript:void(0)\" onclick=\"show_report()\">[申請人查詢]</a>";
            StrFormBtnTop += "<a href=javascript:GoToSearch()>[查詢畫面]</a>";
        }
        StrFormBtnTop += "<a href=javascript:GoToAdd()>[新增發明/創作人]</a>";
        
    }

    private void QueryData() {
        
        DataTable dt = new DataTable();
        string SQL = "SELECT * , (select coun_c from sysctrl.dbo.country where coun_code = a.ant_country AND (markb <> 'X' or markb is null)) as coun_name ";
        SQL += "FROM inventor as a WHERE 1=1 ";
        if (ReqVal.TryGet("ant_no") != "")
        {
            SQL += " and ant_no = '" + ReqVal.TryGet("ant_no") + "'";
        }
        else
        {
            if (ReqVal.TryGet("ant_id") != "")
            {
                SQL += " and ant_id LIKE '%" + ReqVal.TryGet("ant_id") + "%'";
            }
            else
            {
                if (ReqVal.TryGet("apclass") != "")
                {
                    SQL += " and apclass = '" + ReqVal.TryGet("apclass") + "'";
                }
                if (ReqVal.TryGet("ant_country") != "")
                {
                    SQL += " and ant_country = '" + ReqVal.TryGet("ant_country") + "'";
                }
                if (ReqVal.TryGet("cust_seq") != "")
                {
                    SQL += " and cust_seq = '" + ReqVal.TryGet("cust_seq") + "'";
                }
                if (ReqVal.TryGet("ant_cname") != "")
                {
                    SQL += " and (ant_cname1 LIKE '%" + ReqVal.TryGet("ant_cname") + "%' OR ant_cname2 LIKE '%" + ReqVal.TryGet("ant_cname") + "%')";
                }
                if (ReqVal.TryGet("ant_ename") != "")
                {
                    SQL += " and (ant_ename1 LIKE '%" + ReqVal.TryGet("ant_ename") + "%' OR ant_ename2 LIKE '%" + ReqVal.TryGet("ant_ename") + "%')";
                }
                if (ReqVal.TryGet("ant_zip") != "")
                {
                    SQL += " AND ant_zip LIKE '%" + ReqVal.TryGet("ant_zip") + "%'";
                }
                if (ReqVal.TryGet("ant_addr") != "")
                {
                    SQL += " AND (ant_addr1 LIKE '%" + ReqVal.TryGet("ant_addr") + "%' OR ant_addr2 LIKE '%" + ReqVal.TryGet("ant_addr") + "%')";
                }
                if (ReqVal.TryGet("ant_eaddr") != "")
                {
                    SQL += " AND (ant_eaddr1 LIKE '%" + ReqVal.TryGet("ant_eaddr") + "%' OR ant_eaddr2 LIKE '%" + ReqVal.TryGet("ant_eaddr") + "%'";
                    SQL += " OR ant_eaddr3 LIKE '%" + ReqVal.TryGet("ant_eaddr") + "%' OR ant_eaddr4 LIKE '%" + ReqVal.TryGet("ant_eaddr") + "%')";
                }
                if (ReqVal.TryGet("ant_tel0") != "")
                {
                    SQL += " AND ant_tel0 = '" + ReqVal.TryGet("ant_tel0") + "'";
                }
                if (ReqVal.TryGet("ant_tel") != "")
                {
                    SQL += " AND ant_tel LIKE '%" + ReqVal.TryGet("ant_tel") + "%'";
                }
                if (ReqVal.TryGet("ant_tel1") != "")
                {
                    SQL += " AND ant_tel1 LIKE '%" + ReqVal.TryGet("ant_tel1") + "%'";
                }
                
                //日期範圍
                if (ReqVal.TryGet("sdate") != "")
                {
                    SQL += " AND a." + Request["dKind"].ToString() + " >= '" + ReqVal.TryGet("sdate") + "'";
                }
                if (ReqVal.TryGet("edate") != "")
                {
                    SQL += " AND a." + Request["dKind"].ToString() + " <= '" + ReqVal.TryGet("edate") + " 23:59:59'";
                }
            
                if (ReqVal.TryGet("ant_name") != "")//cust17用
                {
                    SQL += " and (ant_cname1 LIKE '%" + ReqVal.TryGet("ant_name") + "%' OR ant_cname2 LIKE '%" + ReqVal.TryGet("ant_name") + "%'" +
                    " OR ant_ename1 LIKE '%" + ReqVal.TryGet("ant_name") + "%' OR ant_ename2 LIKE '%" + ReqVal.TryGet("ant_name") + "%')";
                }
                
            }
        }
        SQL += " order by antsqlno desc";
        //Sys.showLog(SQL);
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
    <%#page.GetHiddenText("GoPage,PerPage,SetOrder")%>
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
<asp:Repeater id="dataRepeater" runat="server">
<HeaderTemplate>
    <table style="display:<%#page.totRow==0?"none":""%>" border="0" class="bluetable" cellspacing="1" cellpadding="2" width="90%" align="center" id="dataList">
	    <thead>
            <tr>
		        <td class=lightbluetable align=center>流水號</td>
		        <td class=lightbluetable align=center>發明/創作人編號</td>
		        <td class=lightbluetable align=center>發明/創作人ID</td>
		        <td class=lightbluetable align=center>發明人國籍</td>
		        <td class=lightbluetable align=center>發明人中文名稱</td>
		        <td class=lightbluetable align=center>發明人英文名稱</td>
		        <td class=lightbluetable align=center colspan="2">作業</td>
                <td class=lightbluetable style="display:none;" >apsqlno</td>
            </tr>
	    </thead>
	    <tbody>
</HeaderTemplate>
			<ItemTemplate>
 		        <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>" align="center" style="height:​30px;">
			        <td nowrap>
                        <%#Eval("antsqlno")%>
			        </td>
			        <td nowrap>
                        <%#Eval("ant_no")%>
			        </td>
			        <td nowrap>
                        <%#Eval("ant_id")%>
			        </td>
			        <td nowrap>
                        <%#Eval("coun_name")%>
			        </td>
			        <td >
                        <%#Eval("ant_cname1")%>
			        </td>
			        <td nowrap>
                        <%#Eval("ant_ename1")%>
			        </td>
			        <td nowrap>
                       <a href="cust17_Edit.aspx?prgid=cust173&antsqlno=<%#Eval("antsqlno")%>&ant_no=<%#Eval("ant_no")%>&submitTask=Q" target="Eblank">[查詢] </a>
                       <a class="hideUpdate" href="cust17_Edit.aspx?prgid=cust173&antsqlno=<%#Eval("antsqlno")%>&ant_no=<%#Eval("ant_no")%>&submitTask=U" target="Eblank">[維護]</a>
			        </td>
                    <%--<td style="display:none;">[<%#Eval("apsqlno")%>]</td>--%>
				</tr>
			</ItemTemplate>
<FooterTemplate>
	    </tbody>
    </table>
    <BR>
</FooterTemplate>
</asp:Repeater>
    <%--<%#DebugStr%>--%>
</form>

</body>
</html>

<script type="text/javascript">
    $(function () {
        if (window.parent.tt !== undefined) {
            window.parent.tt.rows = "100%,0%";

            if ($("#submitTask").val() == "Q") {

                var trs = $("a[class='hideUpdate']");
                for (i = 0; i < trs.length; i++) {
                    trs[i].style.display = "none"; //這裡獲取的trs[i]是DOM物件而不是jQuery物件，因此不能直接使用hide()方法 
                }
            }

        }

    });

    //執行查詢
    function goSearch() {
        $("#regPage").submit();
    };

    function GoToSearch() {
        var url = "";
        var s = <%="'"+submitTask+"'"%>;
        if (s == "A") {
            url = "cust17.aspx?prgid=cust171&submitTask=<%=submitTask%>";
        }
        else {
            url = "cust17_1.aspx?prgid=<%=prgid%>&submitTask=<%=submitTask%>";
        }
        reg.action = url;
        reg.submit();
    }

    function GoToAdd() {
        window.open("cust17_Edit.aspx?prgid=cust171&submitTask=A", "Eblank");
        window.parent.tt.rows = "0%,100%";
    }



</script>