<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Linq"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<script runat="server">
    protected string HTProgCap = "客戶/申請人綜合查詢清單";//HttpContext.Current.Request["prgname"];//功能名稱
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
    protected string cust_area = "";
    protected string TableName = "";
    protected string custno = "";
    protected bool bData = true;
    protected string sortStr = "";
    protected string sortType = "";
    
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
        cust_area = ReqVal.TryGet("cust_area");

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
            StrFormBtnTop = "<a href=javascript:GoToSearch()>[查詢畫面]</a>";
            StrFormBtnTop += "<a href=http://web02/BRP/cust/客戶申請人綜合查詢.files/frame.htm target=_blank>[補助說明]</a>";
        }
        
    }

    private void QueryData() {
        
        DataTable dt = new DataTable();
        //foreach (var item in ReqVal)
        //{
        //    Response.Write("[Key = " + item.Key + ", Value = " + item.Value + "], ");
        //}
        TableName = ReqVal.TryGet("custtype");
        SQL = "SELECT * , ";
        SQL += "(select sc_name from sysctrl.dbo.scode where scode = pscode) as pscodename , (select sc_name from sysctrl.dbo.scode where scode = tscode) as tscodename ";
        SQL += "FROM " + TableName + " WHERE 1=1 ";

        if (ReqVal.TryGet("cust_seq") != "")
        {
            SQL += " AND cust_seq = '" + ReqVal.TryGet("cust_seq") + "'";
        }
        else
        {
            if (ReqVal.TryGet("apclass") != "")
            {
                SQL += " AND apclass = '" + ReqVal.TryGet("apclass") + "'";
            }
            if (ReqVal.TryGet("id_no") != "")
            {
                SQL += " AND id_no LIKE '%" + ReqVal.TryGet("id_no") + "%'";
            }
            if (ReqVal.TryGet("ref_seq") != "")
            {
                SQL += " AND ref_seq = '" + ReqVal.TryGet("ref_seq") + "'";
            }
            if (ReqVal.TryGet("ap_crep") != "")
            {
                SQL += " AND ap_crep LIKE '%" + ReqVal.TryGet("ap_crep") + "%'";
            }
            if (ReqVal.TryGet("ap_erep") != "")
            {
                SQL += " AND ap_erep LIKE '%" + ReqVal.TryGet("ap_erep") + "%'";
            }
            if (ReqVal.TryGet("ap_country") != "")
            {
                SQL += " AND ap_country = '" + ReqVal.TryGet("ap_country") + "'";
            }

            string scodeStr = Sys.GetSession("dept") + "scode";
            if (ReqVal.TryGet("scode") != "")
            {
                SQL += " AND " + scodeStr.ToLower() + " = '" + ReqVal.TryGet("scode") + "'";
            }
            //日期範圍
            if (ReqVal.TryGet("sdate") != "" || ReqVal.TryGet("edate") != "")
            {
                string SDate = (ReqVal.TryGet("sdate") == "") ? "1900/1/1" : ReqVal.TryGet("sdate");
                string EDate = (ReqVal.TryGet("edate") == "") ? "2066/1/1 23:59:59" : ReqVal.TryGet("edate") + " 23:59:59";
                
                if (ReqVal.TryGet("dkind") == "in_date")
                {
                    SQL += " AND in_date >= '" + SDate + "' and in_date <= '" + EDate + "'";
                }
                else if (ReqVal.TryGet("dkind") == "All_date")
                {
                    SQL += " AND ((dmt_date >= '" + SDate + "' and dmt_date <= '" + EDate + "')"
                        + " OR (ext_date >= '" + SDate + "' and ext_date <= '" + EDate + "')"
                        + " OR (dmp_date >= '" + SDate + "' and dmp_date <= '" + EDate + "')"
                        + " OR (exp_date >= '" + SDate + "' and exp_date <= '" + EDate + "'))";
                }
            }
            
            //地址
            if (ReqVal.TryGet("addr") != "")
            {
                SQL += " AND (ap_addr1 LIKE '%" + ReqVal.TryGet("addr") + "%' OR ap_addr2 LIKE '%" + ReqVal.TryGet("addr") + "%'"
                    + " OR ap_eaddr1 LIKE '%" + ReqVal.TryGet("addr") + "%' OR ap_eaddr2 LIKE '%" + ReqVal.TryGet("addr") + "%'"
                    + " OR apatt_addr1 LIKE '%" + ReqVal.TryGet("addr") + "%' OR apatt_addr2 LIKE '%" + ReqVal.TryGet("addr") + "%'"
                    + " OR acc_addr1 LIKE '%" + ReqVal.TryGet("addr") + "%' OR acc_addr2 LIKE '%" + ReqVal.TryGet("addr") + "%'"
                    + " OR tacc_addr1 LIKE '%" + ReqVal.TryGet("addr") + "%' OR tacc_addr2 LIKE '%" + ReqVal.TryGet("addr") + "%')";
            }
            
            if (ReqVal.TryGet("tel") != "")
            {
                SQL += " AND (acc_tel LIKE '%" + ReqVal.TryGet("tel") + "%'"
                    + " OR tacc_tel LIKE '%" + ReqVal.TryGet("tel") + "%'"
                    + " OR apatt_tel LIKE '%" + ReqVal.TryGet("tel") + "%')";
            }

            string levelStr = Sys.GetSession("dept") + "level";
            if (ReqVal.TryGet("level") != "")
            {
                SQL += " AND " + levelStr.ToLower() + " = '" + ReqVal.TryGet("level") + "'";
            }
            
            if (ReqVal.TryGet("ap_cname") != "")
            {
                SQL += " AND (ap_cname1 LIKE '%" + ReqVal.TryGet("ap_cname") + "%'";
                SQL += " OR ap_cname2 LIKE '%" + ReqVal.TryGet("ap_cname") + "%')";
            }
            if (ReqVal.TryGet("ap_ename") != "")
            {
                SQL += " AND (ap_ename1 LIKE '%" + ReqVal.TryGet("ap_ename") + "%'";
                SQL += " OR ap_ename2 LIKE '%" + ReqVal.TryGet("ap_ename") + "%')";
            }

            switch (ReqVal.TryGet("emailtype"))
            {
                case "Y":
                    SQL += " AND ((email <> '' and email is not null) "
                        + " OR (pacc_email <> '' and pacc_email is not null) "
                        + " OR (tacc_email <> '' and tacc_email is not null)) ";
                    break;

                case "N":
                    SQL += " AND (email = '' OR email is null) ";
                    break;

                case "IN":
                    SQL += " AND (email LIKE '%" + ReqVal.TryGet("email") + "%'"
                        + " OR pacc_email LIKE '%" + ReqVal.TryGet("email") + "%'"
                        + " OR tacc_email LIKE '%" + ReqVal.TryGet("email") + "%') ";
                    break;

                default:
                    break;
            }
            
        }

        ReqVal["qryOrder"] = ReqVal.TryGet("SetOrder", "cust_seq desc, apsqlno desc");//Default Query條件
        if (ReqVal.TryGet("qryOrder") != "") {
            SQL += " order by " + ReqVal.TryGet("qryOrder");
        }

        //Sys.showLog(SQL);
        conn.DataTable(SQL, dt);
        if (dt.Rows.Count == 0) { bData = false;  }

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

    protected string GetCustNoName(RepeaterItem Container, string tName)
    {
        if (tName == "vcust_apcust")
	    {
            if (Eval("custtype").ToString() == "1")
            {
                return Eval("cust_area").ToString() + Eval("custno").ToString();
            }
            else
            {
                return Eval("custno").ToString();
            }
	    }
        else
        {
            return Eval("cust_area").ToString() + Eval("cust_seq").ToString();
	    }
    }

    protected string SetCustURL(RepeaterItem Container, string tName)
    {
        if (tName == "vcust_apcust")
        {
            if (Eval("custtype").ToString() == "1")
            {
                return "cust11_Edit.aspx?prgid=cust11&cust_area=" + Eval("cust_area").ToString() + "&cust_seq=" + Eval("cust_seq").ToString() + "&submitTask=Q&ctrl_open=Y";
            }
            else
            {
                return "cust13_Edit.aspx?prgid=cust13&apcust_no=" + Eval("apcust_no").ToString() + "&apsqlno=" + Eval("apsqlno").ToString() +"&submitTask=Q&ctrl_open=Y";
            }
        }
        else
        {
            return "cust11_Edit.aspx?prgid=cust11&cust_area=" + Eval("cust_area").ToString() + "&cust_seq=" + Eval("cust_seq").ToString() + "&submitTask=Q&ctrl_open=Y";
        }
    }
    
    protected string SetCustz_attURL(RepeaterItem Container, string tName)
    {
        //string url = "<a href=\"#\">TEST</a>";
        string url = "<a href=\"cust12_Query.aspx?prgid=cust12&submitTask=Q&cust_area=" + Eval("cust_area").ToString() + "&cust_seq=" + Eval("cust_seq") + "&ap_cname1=" + Eval("ap_cname1").ToString()+"\" target=\"Eblank\">[清單]</a>";
        if (tName == "vcust_apcust")
        {
            if (Eval("custtype").ToString() == "1") { return url; }
            else return "";
        }
        else { return url; }
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
        <td class="text9" nowrap="nowrap">&nbsp;【cust45_List <%=HTProgCap%>】</td>
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
		        <td class=lightbluetable align=center>類別</td>
		        <td class=lightbluetable align=center><u class="setOdr" v1="<%=(TableName == "vcust_apcust")?"custno":"cust_seq"%>">客戶/申請人編號</u></td>
		        <td class=lightbluetable align=center>客戶名稱</td>
		        <td class=lightbluetable align=center>代表人</td>
		        <td class=lightbluetable align=center><u class="setOdr" v1="id_no">統一編號</u></td>
                <td class=lightbluetable align=center><u class="setOdr" v1="in_date">建檔日期</u></td>
                <td class=lightbluetable align=center>專利營洽</td>
		        <td class=lightbluetable align=center>商標營洽</td>
                <td class=lightbluetable align=center>聯絡人</td>
            </tr>
	    </thead>
	    <tbody>
</HeaderTemplate>
			<ItemTemplate>
 		        <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>" align="center" style="height:​30px;">
			        <td nowrap style="width:6%">
                       <%#(TableName == "vcust_apcust") ? ((Eval("custtype").ToString() == "1") ? "客戶" : "申請人") : "客戶"%>
			        </td>
			        <td nowrap style="width:10%">
                        <a href=<%#SetCustURL(Container, TableName)%> target="Eblank">
                            <%#GetCustNoName(Container, TableName)%>
                        </a>
			        </td>
			        <td nowrap>
                        <a href=<%#SetCustURL(Container, TableName)%> target="Eblank">
                            <%#Eval("ap_cname1")%> <%#Eval("ap_cname2")%></a>
			        </td>
			        <td nowrap>
                        <%# (Eval("ap_erep").ToString() == "") ? Eval("ap_crep") : Eval("ap_crep").ToString() + "/" + Eval("ap_erep").ToString()%>
			        </td>
			        <td >
                        <%#Eval("id_no")%>
			        </td>
			        <td nowrap>
                        <%# (Eval("in_date").ToString() == "") ? "" : DateTime.Parse(Eval("in_date").ToString()).ToString("yyyy/M/d")%>
			        </td>
			        <td nowrap>
                        <%# (Eval("pscode").ToString() == "np") ? "專利部門" : Eval("pscodename")%>
			        </td>
			        <td nowrap>
                        <%# (Eval("tscode").ToString() == "nt") ? "商標部門" : Eval("tscodename")%>
			        </td>
                    <td nowrap>
                        <%# SetCustz_attURL(Container, TableName) %>
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
            var s = '<%=bData%>';
            if (s == "False") {
                alert("查無資料!");
                reg.action = "cust45.aspx?prgid=cust45";
                reg.submit();
            }
        }

        $(".Lock").lock();
    });

    //執行查詢
    function goSearch() {
        $("#regPage").submit();
    };
    //////////////////////

    function GoToSearch() {
        reg.action = "cust45.aspx?prgid=cust45";
        reg.submit();
    }


</script>