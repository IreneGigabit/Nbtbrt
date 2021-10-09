<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Linq"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<script runat="server">
    protected string HTProgCap = "聯絡人資料登錄";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "cust12";//程式檔名前綴
    protected string HTProgCode = "Cust12";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";

    protected string SQL = "";
    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected Paging page = null;
    protected string Cust_Area = "";

    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";
    protected string FormName = "";

    protected string kind_no = "";
    protected string ref_no = "";
    protected string submitTask = "";
    
    DBHelper conn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    //DBHelper cnn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    private void Page_Unload(System.Object sender, System.EventArgs e) {
        if (conn != null) conn.Dispose();
        //if (cnn != null) cnn.Dispose();
    }

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");
        conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
        //cnn = new DBHelper(Conn.Sysctrl).Debug(Request["chkTest"] == "TEST");

        submitTask = Request["submitTask"];
        Cust_Area = Sys.GetSession("seBranch");

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

    private void PageLayout()
    {
        if ((HTProgRight & 2) > 0)
        {
            StrFormBtnTop += "<a href=javascript:GoToSearch()>[聯絡人查詢]</a>";
        }
    }

    
    private void QueryData() {
        
        DataTable dt = new DataTable();
        //foreach (var item in ReqVal)
        //{
        //    Response.Write("[Key = " + item.Key + ", Value = " + item.Value + "], ");
        //}
        SQL = "SELECT distinct c.cust_seq,";
        SQL += "(select sc_name from sysctrl.dbo.scode where scode = b.pscode) as pscodename , ";
        SQL += "(select sc_name from sysctrl.dbo.scode where scode = b.tscode) as tscodename , c.* ";
        SQL += "FROM custz_att a LEFT JOIN custz b ON a.cust_seq = b.cust_seq left join apcust c ON b.cust_seq = c.cust_seq ";
        SQL += "where c.cust_seq is not null ";
        
        //只能查專利或商標??
        string codeType = "";
        if (ReqVal.TryGet("Auth") == "All") { }
        else
        {
            if (ReqVal.TryGet("Auth") == "P")
            { 
                SQL += "and b.tscode <> '' and (b.pscode = '' OR b.pscode is null)";
                codeType = "pscode";
            }
            else
            {
                SQL += "and b.pscode <> '' and (b.tscode = '' OR b.tscode is null)";
                codeType = "tscode";
            }
        }
        
        
        if (ReqVal.TryGet("cust_seq") != "")
        {
            SQL += " and c.cust_seq = '" + ReqVal.TryGet("cust_seq") + "'";
        }
        else
        {
            //where in "custz"
            if (ReqVal.TryGet("scode") != "")
            {
                if (codeType == "")
                {
                    SQL += " and b.pscode = '" + ReqVal.TryGet("scode") + "' OR b.tscode = '" + ReqVal.TryGet("scode") + "'";
                }
                else
                {
                    SQL += " and b." + codeType + " = '" + ReqVal.TryGet("scode") + "'";
                }
                
            }
            
            //where in "apcust"
            if (ReqVal.TryGet("ap_cname") != "")
            {
                SQL += " and c.ap_cname1 LIKE '%" + ReqVal.TryGet("ap_cname") + "%' OR c.ap_cname2 LIKE '%" + ReqVal.TryGet("ap_cname") + "%'";
            }
            if (ReqVal.TryGet("ap_ename") != "")
            {
                SQL += " and c.ap_ename1 LIKE '%" + ReqVal.TryGet("ap_ename") + "%' OR c.ap_ename2 LIKE '%" + ReqVal.TryGet("ap_ename") + "%'";
            }

            //where in "custz_att"
            if (ReqVal.TryGet("attention") != "")
            {
                SQL += " and a.attention LIKE '%" + ReqVal.TryGet("attention") + "%'";
            }
            if (ReqVal.TryGet("att_title") != "")
            {
                SQL += " and a.att_title LIKE '%" + ReqVal.TryGet("att_title") + "%'";
            }
            if (ReqVal.TryGet("att_dept") != "")
            {
                SQL += " and a.att_dept LIKE '%" + ReqVal.TryGet("att_dept") + "%'";
            }
            if (ReqVal.TryGet("att_tel0") != "")
            {
                SQL += " and a.att_tel0 LIKE '%" + ReqVal.TryGet("att_tel0") + "%'";
            }
            if (ReqVal.TryGet("att_tel") != "")
            {
                SQL += " and a.att_tel LIKE '%" + ReqVal.TryGet("att_tel") + "%'";
            }
            if (ReqVal.TryGet("att_tel1") != "")
            {
                SQL += " and a.att_tel1 LIKE '%" + ReqVal.TryGet("att_tel1") + "%'";
            }
            if (ReqVal.TryGet("att_mobile") != "")
            {
                SQL += " and a.att_mobile LIKE '%" + ReqVal.TryGet("att_mobile") + "%'";
            }
            if (ReqVal.TryGet("att_fax") != "")
            {
                SQL += " and a.att_fax LIKE '%" + ReqVal.TryGet("att_fax") + "%'";
            }
            if (ReqVal.TryGet("att_mag") != "")
            {
                SQL += " and a.att_mag = '" + ReqVal.TryGet("att_mag") + "'";
            }



        }

        SQL += " order by c.cust_seq desc";
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
        <td class="text9" nowrap="nowrap">&nbsp;【cust12_List 聯絡人資料登錄】</td>
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
		        <td class=lightbluetable align=center>客戶編號</td>
		        <td class=lightbluetable align=center>客戶名稱</td>
		        <td class=lightbluetable align=center>代表人</td>
		        <td class=lightbluetable align=center>統一編號</td>
		        <td class=lightbluetable align=center>建檔日期</td>
		        <td class=lightbluetable align=center>專商營洽</td>
                <td class=lightbluetable align=center colspan="2">聯絡人作業</td>
                <td style="display:none;" >apsqlno</td>
            </tr>
	    </thead>
	    <tbody>
</HeaderTemplate>
			<ItemTemplate>
 		        <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>" align="center" style="height:​30px;">
			        <td nowrap>
                        <a href="cust12_cust.aspx?prgid=cust12&submitTask=Q&cust_area=<%=Cust_Area%>&cust_seq=<%#Eval("cust_seq")%>" target="Eblank">
                            <%#Eval("cust_seq")%></a>
			        </td>
			        <td nowrap>
                        <a href="cust12_cust.aspx?prgid=cust12&submitTask=Q&cust_area=<%=Cust_Area%>&cust_seq=<%#Eval("cust_seq")%>" target="Eblank">
                            <%#Eval("ap_cname1")%></a>
			        </td>
			        <td nowrap><%# (Eval("ap_erep").ToString() == "") ? Eval("ap_crep") : Eval("ap_crep").ToString() + "/" + Eval("ap_erep").ToString()%></td>
			        <td nowrap>
                        <%#Eval("apcust_no")%>
			        </td>
			        <td >
                        <%#
                            //custz的in_date
                            (Eval("in_date").ToString() == "") ? "" : DateTime.Parse(Eval("in_date").ToString()).ToString("yyyy/M/d")
                        %>
			        </td>
			        <td nowrap>
                            <%#Eval("pscodename")%>/<%#Eval("tscodename")%>
			        </td>
			        <td nowrap rowspan="1" colspan="1">
                        <a href="cust12_Query.aspx?prgid=cust12&submitTask=<%=submitTask%>&cust_area=<%=Cust_Area%>&cust_seq=<%#Eval("cust_seq")%>&ap_cname1=<%#Eval("ap_cname1")%>&apsqlno=<%#Eval("apsqlno")%>" target="Eblank">[清單]</a>
			        </td>
                     <td class="hidAdd" nowrap rowspan="1" colspan="1">
                        <a href="cust11_Edit.aspx?prgid=cust12&submitTask=A&Type=ap_nameaddr&cust_area=<%=Cust_Area%>&cust_seq=<%#Eval("cust_seq")%>&cust_att=A" target="Eblank">[新增]</a>
			        </td>
                    <td style="display:none;">[<%#Eval("apsqlno")%>]</td>
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

                var trs = $("td[class='hidAdd']");
                for (i = 0; i < trs.length; i++) {
                    trs[i].style.display = "none"; //這裡獲取的trs[i]是DOM物件而不是jQuery物件，因此不能直接使用hide()方法 
                }
            }

        }

        
        //if ($("#from_query").val() != "1") {
        //    window.parent.tt.rows = "50%,50%";
        //}
        $(".Lock").lock();
        $("input.dateField").datepick();
    });

    //換頁查詢
    function goSearch() {
        $("#regPage").submit();
    };

    function GoToSearch() {
        var url = "";
        var p = <%="'"+prgid+"'"%>;
        if (p == "cust12") {
            url = "cust12.aspx?prgid=cust12&submitTask=U";
        }
        else {
            url = "cust12_1.aspx?prgid=cust12_1&submitTask=<%=submitTask%>";
        }
        
        reg.action = url;
        reg.submit();
    }



</script>