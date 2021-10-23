<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Linq"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<script runat="server">
    protected string HTProgCap = " 更正明細清單";//HttpContext.Current.Request["prgname"];//功能名稱
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
    protected string grp_sql = "";
    DataTable dtScode = new DataTable();
    
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
            StrFormBtnTop += "<a class=\"imgCls\" href=\"javascript:void(0);\" >[關閉視窗]</a>\n";
        }
    }
    
    private void QueryData() {
        
        DataTable dt = new DataTable();
        SQL = "select a.*,(select apcust_no from apcust where apsqlno=a.apsqlno) as apcust_no, ";
        SQL += "(select sc_name from sysctrl.dbo.scode where scode=a.tran_scode) as tran_scodenm ";
        SQL += "from apcust_log a where apsqlno = " + Request["apsqlno"];
        if (Request["cust_seq"] != "")
        {
            SQL += " or cust_seq= " + Request["cust_seq"];
        }
        SQL += " and chg_dept = '" + Request["gs_dept"] + "'";
        SQL += " order by tran_date desc,sqlno";
        //Sys.showLog(SQL);
        conn.DataTable(SQL, dt);

        string SQLsysctrl = "select scode, sc_name from sysctrl.dbo.scode";
        conn.DataTable(SQLsysctrl, dtScode);
        
        
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

   
    private string ShowChg_Kind(RepeaterItem Container)
    {
        string kind = "";
        switch (Eval("chg_kind").ToString())
        {
            case "custz":
                kind = "客戶/申請人";
                break;
            case "apcust":
                kind = "申請人";
                break;
            case "sales":
                kind = "營洽";
                break;
            case "dmt":
                kind = "內商案件主檔";
                break;
            case "ext":
                kind = "外商案件主檔";
                break;
            case "dmp":
                kind = "內專案件主檔";
                break;
            case "exp":
                kind = "外專案件主檔";
                break;
            case "dmp_apcust":
                kind = "內專交辦案件申請人";
                break;
            case "exp_apcust":
                kind = "外專交辦案件申請人";
                break;
            case "cust11":
                kind = "由客戶維護修改";
                break;
            case "cust13":
                kind = "由申請人維護修改";
                break;
            default:
                kind = Eval("chg_kind").ToString();
                break;
        }
        return kind;
    }

    private string Showfidname(RepeaterItem Container)
    {
        string f = "";
        if (Eval("fidcname").ToString() != "") f = Eval("fidcname").ToString();
        else
        {
            switch (Eval("fidname").ToString())
            {
                case "apclass":
                    f = "申請人種類";
                    break;
                case "apcust_no":
                    f = "證照編號/ID";
                    break;
                case "ap_cname1":
                    f = "中文名稱1";
                    break;
                case "ap_cname2":
                    f = "中文名稱2";
                    break;
                case "ap_ename1":
                    f = "英文名稱1";
                    break;
                case "ap_ename2":
                    f = "英文名稱2";
                    break;
                case "ap_country":
                    f = "國籍";
                    break;
                case "ap_name":
                    f = "申請人名稱";
                    break;
                case "pscode":
                    f = "專利營洽";
                    break;
                case "tscode":
                    f = "商標營洽";
                    break;
                default:
                    f = Eval("fidname").ToString();
                    break;
            }
        }
       
        return f;
    }

    private string ShowGroupData(RepeaterItem Container)
    {
        string s = "";
        if (grp_sql == "" || grp_sql != Eval("grp_sql").ToString())
        {
            s = "<td nowrap>"+Eval("grp_sql").ToString()+"</td>";
            s += "<td nowrap>" + DateTime.Parse(Eval("tran_date").ToString()).ToString("yyyy/M/d tt hh:mm:ss") + "</td>";
            s += "<td nowrap>"+Eval("chg_dept").ToString()+"-"+Eval("tran_scodenm").ToString()+"</td>";
        }
        else
        {
            s = "<td></td><td></td><td></td>";
        }
        grp_sql = Eval("grp_sql").ToString();
        return s;
    }
    
    private string ShowOldValue(RepeaterItem Container)
    {
        string oValue = "";
        string scodenm = "";
        if (Eval("fidname").ToString() == "tscode" || Eval("fidname").ToString() == "pscode")
        {
            DataRow[] r = dtScode.Select("scode = '" + Eval("ovalue").ToString() + "'");
            if (r.Length > 0) scodenm = r[0]["sc_name"].ToString();
            oValue = Eval("ovalue").ToString() + "_" + scodenm;
        }
        else oValue = Eval("ovalue").ToString();
        return oValue;
    }

    private string ShowNewValue(RepeaterItem Container)
    {
        string nValue = "";
        string scodenm = "";
        if (Eval("fidname").ToString() == "tscode" || Eval("fidname").ToString() == "pscode")
        {
            DataRow[] r = dtScode.Select("scode = '" + Eval("nvalue").ToString() + "'");
            if (r.Length > 0) scodenm = r[0]["sc_name"].ToString();
            nValue = Eval("nvalue").ToString() + "_" + scodenm;
        }
        else nValue = Eval("nvalue").ToString();
        return nValue;
    }

    private string TitleCustname()
    {
        string s = "名稱：";
        string html_input = "";
        string sql = "select ap_cname1,ap_cname2,ap_ename1,ap_ename2 from apcust where apsqlno="+ Request["apsqlno"];
        using (DBHelper conn = new DBHelper(Conn.brp(Sys.GetSession("seBranch"))).Debug(Request["chkTest"] == "TEST"))
        {
            SqlDataReader dr = conn.ExecuteReader(sql);
            if (dr.Read())
            {
                s += dr["ap_cname1"].ToString().Trim() + dr["ap_cname2"].ToString().Trim();
                if (dr["ap_ename1"].ToString().Trim() != "")
                { s += "&nbsp;" + dr["ap_ename1"].ToString().Trim() + dr["ap_ename2"].ToString().Trim(); }

                html_input = "<input type=\"hidden\" name=\"ap_cname1\" value=\"" + dr["ap_cname1"].ToString().Trim() + "\" >";
                html_input += "<input type=\"hidden\" name=\"ap_cname2\" value=\"" + dr["ap_cname2"].ToString().Trim() + "\" >";
                html_input = "<input type=\"hidden\" name=\"ap_ename1\" value=\"" + dr["ap_ename1"].ToString().Trim() + "\" >";
                html_input += "<input type=\"hidden\" name=\"ap_ename2\" value=\"" + dr["ap_ename2"].ToString().Trim() + "\" >";
            }
            dr.Close(); dr.Dispose();
        }
        return s + html_input;
    }

    private string TitleEditStatus()
    {
        string u = "";
        if ((HTProgRight & 128) > 0 || (HTProgRight & 256) > 0)
        {
            u = "<a href=\"cust14_Edit1.aspx?gs_dept="+Request["gs_dept"]+"&cust_area="+Request["cust_area"]+"&cust_seq="+ Request["cust_seq"];
            u += "&apsqlno=" + Request["apsqlno"] + "&chg_dept=" + dept + "\" target=\"_blank\">[修改狀態]</a>";
        }
        //<a href="cust14_mod1.asp?gs_dept=<%=gs_dept%>&cust_area=<%=request("cust_area")%>&cust_seq=<%=request("cust_seq")%>&grp_sql=<%=RSreg("grp_sql")%>&apsqlno=<%=RSreg("apsqlno")%>&chg_dept=<%=RSreg("chg_dept")%>" target="_blank">[修改狀態]</a><%end if%>
        return u;
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
        <td class="text9" nowrap="nowrap">&nbsp;【cust14 <%=HTProgCap%>】</td>
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
             <tr class="lightbluetable3">
                <td colspan=7><font size="2" color=blue>
                    <%#(Request["cust_seq"] != "") ? "客戶編號：" + Request["cust_area"] + "-" + Request["cust_seq"] : ""%>&nbsp;&nbsp;
		            ID：<%=Request["apcust_no"]%>&nbsp;&nbsp;
		            申請人流水號：<%=Request["apsqlno"]%>&nbsp;&nbsp;
                    <%#TitleCustname()%>
		        </font>
                 &nbsp;<%#TitleEditStatus()%>
		        </td>
            </tr>
            <tr>
                <td class=lightbluetable align=center nowrap>群組</td>
		        <td class=lightbluetable align=center nowrap>異動日期</td>
		        <td class=lightbluetable align=center nowrap>異動人員</td>
		        <td class=lightbluetable align=center nowrap>變更項目</td>
		        <td class=lightbluetable align=center nowrap>變更欄位</td>
		        <td class=lightbluetable align=center>原資料</td>
		        <td class=lightbluetable align=center>新資料</td>
            </tr>
	    </thead>
	    <tbody>
</HeaderTemplate>
			<ItemTemplate>
 		        <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>" align="center" style="height:​30px;">
                   <%-- <td nowrap><%#Eval("grp_sql").ToString()%></td>
                    <td nowrap><%#DateTime.Parse(Eval("tran_date").ToString()).ToString("yyyy/M/d tt hh:mm:ss")%></td>
			        <td nowrap><%#Eval("chg_dept")%>-<%#Eval("tran_scodenm")%></td>--%>
                     <%#ShowGroupData(Container)%>
			        <td nowrap><%#ShowChg_Kind(Container)%></td>
                    <td nowrap><%#Showfidname(Container)%></td>
			        <td nowrap><%#ShowOldValue(Container)%></td>
                    <td nowrap><%#ShowNewValue(Container)%></td>
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
            window.parent.tt.rows = "40%,60%";

        }
    });

    //執行查詢
    function goSearch() {
        $("#regPage").submit();
    }
   
    



</script>