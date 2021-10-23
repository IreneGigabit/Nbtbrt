<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Linq"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<script runat="server">
    protected string HTProgCap = " 更正客戶申請人作業-清單";//HttpContext.Current.Request["prgname"];//功能名稱
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
    
    private void QueryData() {
        
        DataTable dt = new DataTable();
        SQL = "select a.cust_area, a.cust_seq, a.apsqlno, a.apcust_no, a.apclass, (select code_name from cust_code where code_type='apclass' and cust_code=a.apclass) as apclassnm, ";
        SQL += "ap_country,(select coun_c from sysctrl.dbo.country where coun_code=a.ap_country and markb<>'X') as ap_countrynm,ap_cname1,ap_cname2,apsqlno, ";
        SQL += "(select sc_name from sysctrl.dbo.scode s1 where s1.scode=b.pscode)pscodenm, ";
        SQL += "(select sc_name from sysctrl.dbo.scode s2 where s2.scode=b.tscode)tscodenm ";
        SQL += "from apcust a LEFT JOIN custz b ON a.cust_seq = b.cust_seq where 1=1 ";
        string tdept = Request["gs_dept"] ?? "";
        
        if (ReqVal.TryGet("cust_seqs") != "")
        {
            SQL += " and a.cust_seq >= " + ReqVal.TryGet("cust_seqs");
        }
        if (ReqVal.TryGet("cust_seqe") != "")
        {
            SQL += " and a.cust_seq <= " + ReqVal.TryGet("cust_seqe");
        }
        if (ReqVal.TryGet("apcust_no") != "")
        {
            SQL += " and a.apcust_no = '" + ReqVal.TryGet("apcust_no") + "'";
        }
        if (ReqVal.TryGet("apclass") != "")
        {
            SQL += " and a.apclass = '" + ReqVal.TryGet("apclass") + "'";
        }
        
        if (ReqVal.TryGet("ap_cname") != "")
        {
            SQL += " and (a.ap_cname1 LIKE '%" + ReqVal.TryGet("ap_cname") + "%' OR a.ap_cname2 LIKE '%" + ReqVal.TryGet("ap_cname") + "%')";
        }
        if (ReqVal.TryGet("ap_ename") != "")
        {
            SQL += " and (a.ap_ename1 LIKE '%" + ReqVal.TryGet("ap_cname") + "%' OR a.ap_ename2 LIKE '%" + ReqVal.TryGet("ap_ename") + "%')";
        }

        if (ReqVal.TryGet("ap_country") != "")
        {
            SQL += " and a.ap_country = '" + ReqVal.TryGet("ap_country") + "'";
        }

        if (tdept == "P")
        {
            if (ReqVal.TryGet("plevel") != "")
            {
                SQL += " and plevel LIKE '%" + ReqVal.TryGet("plevel") + "%'";    
            }
        }
        else
        {
            if (ReqVal.TryGet("tlevel") != "")
            {
                SQL += " and tlevel LIKE '%" + ReqVal.TryGet("tlevel") + "%'";
            }
        }
        
        
        SQL += " order by cust_area,cust_seq";
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


    private string ShowURL(RepeaterItem Container)
    {
        string url = "";
        if ((HTProgRight & 2) > 0)
        {
            url = "<a href=\"cust14_List2.aspx?prgid=cust14&gs_dept=" + dept + "&apsqlno=" + Eval("apsqlno").ToString() + "&cust_area=" + Eval("cust_area").ToString() + "&cust_seq=" + Eval("cust_seq").ToString();
            url += "&apcust_no=" + Eval("apcust_no").ToString() + "\" target=\"Eblank\" >[明細]<a/>";
        }

        if ((HTProgRight & 4) > 0 || (HTProgRight & 8) > 0 || (HTProgRight & 64) > 0 || (HTProgRight & 128) > 0 || (HTProgRight & 256) > 0)
        {
            if (Eval("cust_seq").ToString() != "")
            {
                //havemaindata-待改
                url += " <a href=\"cust14_Edit.aspx?prgid=" + prgid + "&kind=custz&havemaindata=Y&gs_dept=" + dept + "&cust_area=" + Eval("cust_area").ToString() + "&cust_seq=" + Eval("cust_seq").ToString();
                url += "&apsqlno=" + Eval("apsqlno").ToString() + "&qcust_area=" + Request["cust_area"] + "&qcust_seqs=" + Request["cust_seqs"] + "&qcust_seqe=" + Request["cust_seqe"];
                url += "&qapsqlno=" + Request["apsqlno"] + "&qapclass=" + Request["apclass"] + "&qapcust_no=" + Request["apcust_no"] + "&qap_country=" + Request["ap_country"];
                url += "&qap_cname=" + Request["ap_cname"] + "&qap_ename=" + Request["ap_ename"] + "&qscode=" + Request["scode"] + "\" target=\"Eblank\">[客戶&申請人]</a>";
            }
            else
            {
                url += " <a href=\"cust14_Edit.aspx?prgid=" + prgid + "&kind=apcust&havemaindata=Y&gs_dept=" + dept + "&cust_area=" + Eval("cust_area").ToString() + "&cust_seq=" + Eval("cust_seq").ToString();
                url += "&apsqlno=" + Eval("apsqlno").ToString() + "&qcust_area=" + Request["cust_area"] + "&qcust_seqs=" + Request["cust_seqs"] + "&qcust_seqe=" + Request["cust_seqe"];
                url += "&qapsqlno=" + Request["apsqlno"] + "&qapclass=" + Request["apclass"] + "&qapcust_no=" + Request["apcust_no"] + "&qap_country=" + Request["ap_country"];
                url += "&qap_cname=" + Request["ap_cname"] + "&qap_ename=" + Request["ap_ename"] + "&qscode=" + Request["scode"] + "\" target=\"Eblank\">[申請人]</a>";
            }


        }
        return url;
    }

    private string ShowCust_seq(RepeaterItem Container)
    { 
        string u = "";
        if (Util.NullConvert(Eval("cust_seq")) != "")
        {
		    u = "<a href=\"cust11_Edit.aspx?prgid="+prgid+"&cust_area="+Eval("cust_area").ToString()+"&cust_seq="+Eval("cust_seq").ToString()+"&submitTask=Q&ctrl_open=Y\" target=\"Eblank\">";
            u += Eval("cust_area").ToString() + "-" + Eval("cust_seq").ToString() + "</a>"; 
        }
        return u;
    }

    private string PScodeName(RepeaterItem Container)
    {
        string s = (Eval("pscodenm").ToString() == "專利部門") ? "部門(開放客戶)" : Eval("pscodenm").ToString();
        return s;
    }
    private string TScodeName(RepeaterItem Container)
    {
        string s = (Eval("tscodenm").ToString() == "商標部門") ? "部門(開放客戶)" : Eval("tscodenm").ToString();
        return s;
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
        <td class="text9" nowrap="nowrap">&nbsp;【cust14_List <%=HTProgCap%>】</td>
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
    <table style="display:<%#page.totRow==0?"none":""%>" border="0" class="bluetable" cellspacing="1" cellpadding="2" width="100%" align="center" id="dataList">
	    <thead>
            <tr>
                <td class=lightbluetable align=center rowspan="2">客戶編號</td>
                <td class=lightbluetable align=center rowspan="2">客戶名稱</td>
                <td class=lightbluetable align=center rowspan="2" style="width:7%;">證照號碼</td>
                <td class=lightbluetable align=center rowspan="2" style="width:15%;">申請人種類</td>
                <td class=lightbluetable align=center rowspan="2" style="width:10%;">國籍</td>
		        <td class=lightbluetable align=center rowspan="1" colspan="2">營洽</td>
                <td class=lightbluetable align=center rowspan="2" style="width:15%;">更名</td>
            </tr>
            <tr>
                <td class=lightbluetable align=center>商標</td>
                <td class=lightbluetable align=center>專利</td>
            </tr>
	    </thead>
	    <tbody>
</HeaderTemplate>
			<ItemTemplate>
 		        <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>" align="center" style="height:​30px;">
			        <td nowrap><%#ShowCust_seq(Container)%></td>
			        <td nowrap>
                        <a href="cust13_Edit.aspx?prgid=cust14&apsqlno=<%#Eval("apsqlno")%>&apcust_no=<%#Eval("apcust_no")%>&submitTask=Q&ctrl_open=Y" target="Eblank">
                            <%#Eval("ap_cname1")%><%#Eval("ap_cname2")%>
                        </a>
			        </td>
			        <td nowrap><%#Eval("apcust_no").ToString()%></td>
			        <td nowrap><%#Eval("apclassnm")%></td>
                    <td nowrap><%#Eval("ap_countrynm")%></td>
			        <td nowrap><%#TScodeName(Container)%></td>
                    <td nowrap><%#PScodeName(Container)%></td>
                    <td nowrap>
                        <%#ShowURL(Container)%>
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
        reg.action = "cust14.aspx?prgid=<%=prgid%>";
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