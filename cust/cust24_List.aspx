<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Linq"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<script runat="server">
    protected string HTProgCap = "聯絡人職代/副本信箱設定清單";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = HttpContext.Current.Request["prgid"] ?? "";//程式檔名前綴
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
    protected string dept = "";
    
    DBHelper conn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    private void Page_Unload(System.Object sender, System.EventArgs e) {
        if (conn != null) conn.Dispose();
    }

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");
        conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");

        submitTask = Request["submitTask"];
        dept = Sys.GetSession("dept");

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
            StrFormBtnTop += "<a href=javascript:GoToSearch()>[查詢畫面]</a>";
        }
        StrFormBtnTop += "<a href=javascript:GoToAdd()>[新增]</a>";
    }

    private string ShowEdit(string status)
    {
        string url = "";
        url = "<a href=\"cust22_Edit.aspx?prgid=" + prgid + "&submitTask=Q&apattach_sqlno=" + Eval("apattach_sqlno").ToString() + "\" target=\"Eblank\" >[查詢]<a/>";
        if (status == "U")
        {
            url += "<a class=\"hidAdd\" href=\"cust22_Edit.aspx?prgid=" + prgid + "&submitTask=U&apattach_sqlno=" + Eval("apattach_sqlno").ToString() + "\" target=\"Eblank\" >[維護]<a/>";
        }
        return url;
    }
    
    
    private void QueryData() {
        
        DataTable dt = new DataTable();
        SQL = "SELECT v.cust_area,v.cust_seq,ap.apsqlno,ap.ap_cname1,ap.ap_cname2,ap.ap_crep, ap_erep, v.id_no, ";
	    SQL += "v.in_date,v.pscode,v.tscode, ";
	    SQL += "(select sc_name from sysctrl.dbo.scode s1 where s1.scode=v.pscode)psc_name, ";
	    SQL += "(select sc_name from sysctrl.dbo.scode s2 where s2.scode=v.tscode)tsc_name ";
	    SQL += "FROM custz v ";
	    SQL += "inner JOIN apcust ap ON v.cust_area = ap.cust_area AND v.cust_seq = ap.cust_seq ";
        SQL += "where 1=1 ";
        SQL += "and ((select count(*) from apcust_mark m where m.cust_area = v.cust_area AND m.cust_seq = v.cust_seq and m.mark_type in('cmark_mail'))>0) ";
        string tdept = Request["gs_dept"] ?? "";
        
        if (ReqVal.TryGet("cust_area") != "")
        {
            SQL += " and v.cust_area = '" + ReqVal.TryGet("cust_area") + "'";
        }
        
        if (ReqVal.TryGet("cust_seq") != "")
        {
            SQL += " and v.cust_seq = '" + ReqVal.TryGet("cust_seq") + "'";
        }
        else
        {
            if (ReqVal.TryGet("ap_cname") != "")
            {
                SQL += " and ap.ap_cname1 LIKE '%" + ReqVal.TryGet("ap_cname") + "%' OR ap.ap_cname2 LIKE '%" + ReqVal.TryGet("ap_cname") + "%'";
            }

            if (ReqVal.TryGet("scode") != "")
            {
                if (ReqVal.TryGet("scode") == "all")
                {
                    if ((HTProgRight & 128) > 0 && (HTProgRight & 64) > 0)
                    {
                        SQL += " and (isnull(tscode,'') in (" + Request["pwhescode"] + ")";
                        SQL += " or isnull(pscode,'') in (" + Request["pwhescode"] + "))";
                    }
                    else
                    {
                        SQL += " and isnull(" + tdept + "scode,'') in (" + Request["pwhescode"] + ")";
                    }
                }
                else
                {
                    if ((HTProgRight & 128) > 0 && (HTProgRight & 64) > 0)
                    {
                        SQL += " and (isnull(tscode,'') = '" + ReqVal.TryGet("scode") + "'";
                        SQL += " or isnull(pscode,'') = '" + ReqVal.TryGet("scode") + "')";
                    }
                    else
                    {
                        SQL += " and isnull(" + tdept + "scode,'') = '" + ReqVal.TryGet("scode") + "'";
                    }
                }
            }
        }

        SQL += " order by v.cust_area,v.cust_seq";
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
        <td class="text9" nowrap="nowrap">&nbsp;【cust24_List <%=HTProgCap%>-<%=(dept == "P")?"專利":"商標"%>】</td>
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
    <table style="display:<%#page.totRow==0?"none":""%>" border="0" class="bluetable" cellspacing="1" cellpadding="2" width="80%" align="center" id="dataList">
	    <thead>
            <tr>
                <td class=lightbluetable align=center style="width:10%;">客戶編號</td>
                <td class=lightbluetable align=center>客戶名稱</td>
                <td class=lightbluetable align=center>代表人</td>
                <td class=lightbluetable align=center>統一編號</td>
		        <td class=lightbluetable align=center style="width:10%;">建檔日期</td>
		        <td class=lightbluetable align=center>專商營洽</td>
                <td class=lightbluetable align=center style="width:10%;">作業</td>
            </tr>
	    </thead>
	    <tbody>
</HeaderTemplate>
			<ItemTemplate>
 		        <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>" align="center" style="height:​30px;">
			        <td nowrap><%#Eval("cust_seq")%></td>
			        <td nowrap><%#Eval("ap_cname1")%><%#Eval("ap_cname2")%></td>
			        <td nowrap><%# (Eval("ap_erep").ToString() == "") ? Eval("ap_crep") : Eval("ap_crep").ToString() + "/" + Eval("ap_erep").ToString()%></td>
			        <td nowrap><%#Eval("id_no")%></td>
			        <td >
                        <%#(Eval("in_date").ToString() == "") ? "" : DateTime.Parse(Eval("in_date").ToString()).ToString("yyyy/M/d")%>
			        </td>
			        <td nowrap><%#Eval("psc_name")%>/<%#Eval("tsc_name")%></td>
                    <td nowrap>
                        <a href="cust24_Edit.aspx?prgid=cust24&cust_area=<%#Eval("cust_area")%>&cust_seq=<%#Eval("cust_seq")%>&submitTask=Q" target="Eblank">[查詢]</a>&nbsp;&nbsp;
                        <a href="cust24_Edit.aspx?prgid=cust24&cust_area=<%#Eval("cust_area")%>&cust_seq=<%#Eval("cust_seq")%>&submitTask=U" target="Eblank">[維護]</a>
                    </td>
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


        }

        $("input.dateField").datepick();
    });

    //執行查詢
    function goSearch() {
        $("#regPage").submit();
    }
   
    function GoToSearch() {
        reg.action = "cust24.aspx?prgid=<%=prgid%>";
        reg.target = "Etop";
        reg.submit();
    }

    function GoToAdd() {
        reg.action = "cust24_Edit.aspx?prgid=cust24&submitTask=A";
        reg.target = "Eblank";
        reg.submit();
        //var url = "cust21_Edit.aspx?prgid=cust21&submitTask=A";
        //window.parent.Eblank.location.href = url;
    }





</script>