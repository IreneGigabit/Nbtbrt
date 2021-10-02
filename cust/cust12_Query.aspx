<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Linq"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<script runat="server">
    protected string HTProgCap = "聯絡人清單";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "cust12";//程式檔名前綴
    protected string HTProgCode = "Cust12";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";

    protected string SQL = "";
    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected Paging page = null;
    protected string Cust_Area = "";
    protected string Cust_Seq = "";
    

    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";
    protected string FormName = "";

    protected string apsqlno = "";
    protected string submitTask = "";
    DataTable dtCountry = Sys.getCountry();
    
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
        conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
        cnn = new DBHelper(Conn.Sysctrl).Debug(Request["chkTest"] == "TEST");

        submitTask = Request["submitTask"];
        Cust_Area = Request["cust_area"];
        Cust_Seq = Request["cust_seq"];
        apsqlno = Request["apsqlno"];

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
        //if ((HTProgRight & 2) > 0) { StrFormBtnTop += "<a href=\"javascript:void(0)\" onclick=\"show_excel()\">[下載Excel]</a>";}
        
    }

    
    private void QueryData() {
        
        DataTable dt = new DataTable();
        //foreach (var item in ReqVal)
        //{
        //    Response.Write("[Key = " + item.Key + ", Value = " + item.Value + "], ");
        //}
        
        SQL = "SELECT * FROM custz_att WHERE 1=1 AND cust_area = '" + Cust_Area + "' AND cust_seq = '" + Cust_Seq + "'";
        SQL += " order by att_sql";
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
    
    private string goEdit(string Chkdept,  string att_sql, string ap_cname1)
    { 
        string url = "";
        if (submitTask != "Q")
        {
            if (Chkdept == Sys.GetSession("dept"))
            {
                url = "<a href=\"cust12_Edit.aspx?prgid=cust12_1&submitTask=" + submitTask + "&cust_seq=" + Cust_Seq + "&cust_area=" + Cust_Area + "&att_sql=" + att_sql + "&ap_cname1=" + ap_cname1 + "&apsqlno=" + apsqlno + "\" target=\"Eblank\" >[修改]<a/>";
            }
            else
            {
                url = "<a href=\"cust12_Edit.aspx?prgid=cust12_1&submitTask=Q&cust_seq=" + Cust_Seq + "&cust_area=" + Cust_Area + "&att_sql=" + att_sql + "&ap_cname1=" + ap_cname1 + "\" target=\"Eblank\" >[查詢]<a/>";
            }
        }
        else
        {
            url = "<a href=\"cust12_Edit.aspx?prgid=cust12_1&submitTask=" + submitTask + "&cust_seq=" + Cust_Seq + "&cust_area=" + Cust_Area + "&att_sql=" + att_sql + "&ap_cname1=" + ap_cname1 + "\" target=\"Eblank\" >[查詢]<a/>";
        }
        
            
        return url; 
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
        <td class="text9" nowrap="nowrap">&nbsp;【cust12_Query <%=HTProgCap%>】</td>
        <td class="FormLink" valign="top" align="right" nowrap="nowrap">
            <%#StrFormBtnTop%>
        </td>
    </tr>
    <tr>
        <td colspan="2"><hr class="style-one"/></td>
    </tr>
</table>
<input type="hidden" name="apsqlno" id="apsqlno" value="<%=apsqlno%>" />
<form style="margin:0;" id="regPage" name="regPage" method="post">
    <h4>◎客戶編號：<%#Request["cust_seq"]%>&nbsp;◎客戶名稱：<%#Request["ap_cname1"]%></h4>
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
                        
		        <td class=lightbluetable align=center>序號</td>
		        <td class=lightbluetable align=center>聯絡人</td>
		        <td class=lightbluetable align=center>職稱</td>
		        <td class=lightbluetable align=center>聯絡部門</td>
		        <td class=lightbluetable align=center>聯絡電話</td>
		        <td class=lightbluetable align=center>傳真</td>
                <td class=lightbluetable align=center>行動電話</td>
                <td class=lightbluetable align=center>電子郵件</td>
                <td class=lightbluetable align=center>作業</td>
            </tr>
	    </thead>
	    <tbody>
</HeaderTemplate>
			<ItemTemplate>
 		        <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>" align="center" style="height:​30px;">
			        <td nowrap><%#Eval("att_sql")%></td>
			        <td nowrap><%#Eval("dept")%>-<%#Eval("attention")%></td>
			        <td nowrap><%#Eval("att_title")%></td>
			        <td nowrap><%#Eval("att_dept")%></td>
                    <td nowrap>(<%#Eval("att_tel0")%>)<%#Eval("att_tel")%>-<%#Eval("att_tel1")%></td>
                    <td nowrap><%#Eval("att_fax")%></td>
                    <td nowrap><%#Eval("att_mobile")%></td>
                    <td nowrap><%#Eval("att_email")%></td>
                     <td nowrap rowspan="1" colspan="1">
                         <%#goEdit(Eval("dept").ToString(), Eval("att_sql").ToString(), Request["ap_cname1"]) %>
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
            window.parent.tt.rows = "40%,60%";
        }

        $(".Lock").lock();
        $("input.dateField").datepick();
    });

    //換頁查詢
    function goSearch() {
        $("#regPage").submit();
    };


</script>