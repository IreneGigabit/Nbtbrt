<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Linq"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>

<script runat="server">
    protected string HTProgCap = "雙邊代理查詢客戶清單";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = HttpContext.Current.Request["prgid"] ?? "";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";

    protected string seBranch = "";
    protected string SQL = "";
    protected string SQLwhere = "";
    protected string msg = "";
    protected bool bData = true;
    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected Paging page = null;

    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";
    protected string TempTableName = "cust46";
    
    DBHelper conn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    DBHelper connSel = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    DBHelper conn2 = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    private void Page_Unload(System.Object sender, System.EventArgs e) {
        if (conn != null) conn.Dispose();
        if (connSel != null) conn.Dispose();
        if (conn2 != null) conn2.Dispose();
    }

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");
        conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
        conn2 = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
        seBranch = Sys.GetSession("seBranch");
        
        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        //HTProgCap = myToken.Title;
        DebugStr = myToken.DebugStr;
        if (HTProgRight >= 0) {
            PageLayout();
            SetTempTable();
            QueryData();
            this.DataBind();
        }
    }

    private void PageLayout()
    {
        if ((HTProgRight & 2) > 0)
        {
            StrFormBtnTop = "<a href=javascript:GoToSearch()>[查詢畫面]</a>";
            StrFormBtnTop += "<a href=http://web02/BRP/cust/雙邊代理查詢操作手冊.files/frame.htm target=_blank>[補助說明]</a>";
        }
    }
    
    //若從條件頁面進入(cust46.asp),需要重新InsertTable
    private void SetTempTable()
    {
        //如果已經重新存在的資料,要先delete
        string SQLTempQ = "select count(*) as totalcount from " + TempTableName + " where scode = '" + Sys.GetSession("scode") + "'";
        SqlDataReader dr = conn.ExecuteReader(SQLTempQ);
        if (dr.Read())
	    {
            if (dr["totalcount"].ToString() != "0")
	        {
                string SQLTempD = "delete from " + TempTableName + " where scode = '" + Sys.GetSession("scode") + "'";
                try
                {
                    conn2.ExecuteNonQuery(SQLTempD);
                }
                catch (Exception ex)
                {
                    conn2.RollBack();
                    throw new Exception(msg, ex);
                }
                //Sys.showLog("SQLTempD = " + SQLTempD);
	        }
	    }
        dr.Close(); dr.Dispose();

        //將各所(N、K...)SQL查詢資料結果Insert到cust46
        SQLwhere = "";
        if (ReqVal.TryGet("id_no") != "")
        {
            SQLwhere += " AND id_no = '" + ReqVal.TryGet("id_no") + "'";
        }
        else
        {
            if (ReqVal.TryGet("ap_crep") != "")
            {
                SQLwhere += " AND ap_crep LIKE '%" + ReqVal.TryGet("ap_crep") + "%'";
            }
            if (ReqVal.TryGet("ap_erep") != "")
            {
                SQLwhere += " AND ap_erep LIKE '%" + ReqVal.TryGet("ap_erep") + "%'";
            }
            if (ReqVal.TryGet("ap_cname") != "")
            {
                SQLwhere += " AND (ap_cname1 LIKE '%" + ReqVal.TryGet("ap_cname") + "%'";
                SQLwhere += " OR ap_cname2 LIKE '%" + ReqVal.TryGet("ap_cname") + "%')";
            }
            if (ReqVal.TryGet("ap_ename") != "")
            {
                SQLwhere += " AND (ap_ename1 LIKE '%" + ReqVal.TryGet("ap_ename") + "%'";
                SQLwhere += " OR ap_ename2 LIKE '%" + ReqVal.TryGet("ap_ename") + "%')";
            }
        }
        SQL = "SELECT * , ";
        SQL += "(select sc_name from sysctrl.dbo.scode where scode = pscode) as pscodename , (select sc_name from sysctrl.dbo.scode where scode = tscode) as tscodename ";
        
        SQL += "FROM vcust_apcust WHERE 1=1" + SQLwhere;
        //Get customer data from 4 branches(N,C,S,K) 
        //string [] Branches = {"N", "C", "S", "K"};
        string[] Branches = { "N" };
        for (int i = 0; i < Branches.Length; i++)
        {
            connSel = new DBHelper(Conn.brp(Branches[i])).Debug(Request["chkTest"] == "TEST");

            SqlDataReader drChkTable = connSel.ExecuteReader("select count(*) as count from sysobjects where name='vcust_apcust'");
            drChkTable.Read();
            if (drChkTable["count"].ToString() == "0")
            {
                drChkTable.Close(); drChkTable.Dispose();
                continue;
            }
            else { drChkTable.Close(); drChkTable.Dispose(); }
            
            SqlDataReader drData = connSel.ExecuteReader(SQL);
            while (drData.Read())
	        {
                string SQLInsert = "";
                string cust_area = (drData["custtype"].ToString() == "2") ? Branches[i] : drData["cust_area"].ToString();
                string pscode_name = (drData["pscode"].ToString() == "np") ? "專利客戶" : drData["pscodename"].ToString();
                string tscode_name = (drData["tscode"].ToString() == "nt") ? "商標客戶" : drData["tscodename"].ToString();
                    
                SQLInsert = "INSERT INTO " + TempTableName + " VALUES (";
                SQLInsert += "'" + Sys.GetSession("scode") + "','" + drData["custtype"].ToString() + "','" + cust_area + "','" + drData["cust_seq"].ToString() + "','" + drData["id_no"].ToString() + "',";
                SQLInsert += "'" + drData["apsqlno"].ToString() + "','" + drData["apcust_no"].ToString() + "','" + drData["ap_cname1"].ToString() + "','" + drData["ap_cname2"].ToString() + "',";
                SQLInsert += "'" + drData["ap_ename1"].ToString() + "','" + drData["ap_ename2"].ToString() + "','" + drData["ap_crep"].ToString() + "',";
                SQLInsert += "'" + drData["ap_erep"].ToString() + "','" + drData["pscode"].ToString() + "','" + drData["tscode"].ToString() + "',";
                SQLInsert += "'" + pscode_name + "','" + tscode_name + "','" + drData["rmark_code"].ToString() + "')";

                try
                {
                    conn2.ExecuteNonQuery(SQLInsert);
                }
                catch (Exception ex)
                {
                    conn2.RollBack();
                    throw new Exception(msg, ex);
                }
	        }
            drData.Close(); drData.Dispose(); connSel.Dispose();
        }
        conn2.Commit(); conn2.Dispose();
    }

    private void QueryData()
    {
        DataTable dt = new DataTable();
        SQL = "SELECT * , ";
        SQL += "(select sc_name from sysctrl.dbo.scode where scode = pscode) as pscodename , (select sc_name from sysctrl.dbo.scode where scode = tscode) as tscodename, ";
        SQL += "(select code_name from cust_code where code_type= 'rmark_code' and cust_code = rmark_code) as rmarkcodename ";
        SQL += "FROM cust46 WHERE 1=1 AND scode = '" + Sys.GetSession("scode") + "'" + SQLwhere;
        //SQL += " order by custtype, cust_area, cust_seq desc, apcust_no desc ";
        //Sys.showLog(SQL);
        ReqVal["qryOrder"] = ReqVal.TryGet("SetOrder", "custtype, cust_area, cust_seq desc, apcust_no desc");//Default Query條件
        if (ReqVal.TryGet("qryOrder") != "")
        {
            SQL += " order by " + ReqVal.TryGet("qryOrder");
        }
        conn.DataTable(SQL, dt);

        if (dt.Rows.Count == 0){ bData = false; }

        //處理分頁
        int nowPage = Convert.ToInt32(Request["GoPage"] ?? "1"); //第幾頁
        int PerPageSize = Convert.ToInt32(Request["PerPage"] ?? "10"); //每頁筆數
        page = new Paging(nowPage, PerPageSize, SQL);
        page.GetPagedTable(dt);

        //分頁完再處理其他資料才不會虛耗資源
        for (int i = 0; i < page.pagedTable.Rows.Count; i++)
        {
            DataRow dr = page.pagedTable.Rows[i];
        }

        dataRepeater.DataSource = page.pagedTable;
        dataRepeater.DataBind();
    }

    protected string GetRmarkCode(RepeaterItem Container)
    {
        if (Eval("rmark_code").ToString().Substr(0, 2) == "E2")
        {
            return "<span style='color:red'>" + Eval("rmarkcodename") + "</span>";
        }
        else
        {
            return "<span>" + Eval("rmarkcodename") + "</span>";
        }
    }

    protected string GetCustNoName(RepeaterItem Container)
    {
        string s = "";
        if ((HTProgRight & 128) > 0)
        {
            if (Eval("custtype").ToString() == "1")
            {
                if (Eval("cust_area").ToString() == seBranch)
                {
                    s = "<a href='cust11_Edit.aspx?prgid=cust11&cust_area=" + Eval("cust_area").ToString() + "&cust_seq=" + Eval("cust_seq").ToString() + "&submitTask=Q&ctrl_open=Y' target='Eblank'>";
                    s += Eval("cust_area").ToString() + "-" + Eval("cust_seq").ToString() + "</a>";
                    return s;
                }
                else return Eval("cust_area").ToString() + "-" + Eval("cust_seq").ToString();
            }
            else
            {
                if (Eval("cust_area").ToString() == seBranch)
                {
                    s = "<a href='cust13_Edit.aspx?prgid=cust13&apcust_no=" + Eval("apcust_no").ToString() + "&apsqlno=" + Eval("apsqlno").ToString() + "&submitTask=Q&ctrl_open=Y' target='Eblank'>";
                    s += Eval("cust_area").ToString() + "-" + Eval("apcust_no").ToString() + "</a>";
                    return s;
                }
                else return Eval("cust_area").ToString() + "-" + Eval("apcust_no").ToString(); 
            }
        }
        else
        {
            if (Eval("custtype").ToString() == "1")
            {
                return Eval("cust_area").ToString() + "-" + Eval("cust_seq").ToString();
            }
            else
            {
                return Eval("cust_area").ToString() + "-" + Eval("apcust_no").ToString();   
            }
        }
    }

    protected string GetCustName(RepeaterItem Container)
    {
        string s = "";
        if ((HTProgRight & 128) > 0)
        {
            if (Eval("custtype").ToString() == "1")
            {
                if (Eval("cust_area").ToString() == seBranch)
                {
                    s = "<a href='cust11_Edit.aspx?prgid=cust11&cust_area=" + Eval("cust_area").ToString() + "&cust_seq=" + Eval("cust_seq").ToString() + "&submitTask=Q&ctrl_open=Y' target='Eblank'>";
                    s += Eval("ap_cname1").ToString() + Eval("ap_cname2").ToString() + "</a>";
                    return s;
                }
                else return Eval("ap_cname1").ToString() + Eval("ap_cname2").ToString();
            }
            else
            {
                if (Eval("cust_area").ToString() == seBranch)
                {
                    s = "<a href='cust13_Edit.aspx?prgid=cust13&apcust_no=" + Eval("apcust_no").ToString() + "&apsqlno=" + Eval("apsqlno").ToString() + "&submitTask=Q&ctrl_open=Y' target='Eblank'>";
                    s += Eval("ap_cname1").ToString() + Eval("ap_cname2").ToString() + "</a>";
                    return s;
                }
                else return Eval("ap_cname1").ToString() + Eval("ap_cname2").ToString();
            }
        }
        else
        {
            return Eval("ap_cname1").ToString() + Eval("ap_cname2").ToString();
        }
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
        <td class="text9" nowrap="nowrap">&nbsp;【cust46_List <%=HTProgCap%>】</td>
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
		        <td class=lightbluetable align=center><u class="setOdr" v1="cust_seq">客戶/申請人編號</u></td>
		        <td class=lightbluetable align=center>中文名稱</td>
                <td class=lightbluetable align=center>英文名稱</td>
                <td class=lightbluetable align=center><u class="setOdr" v1="id_no">統一編號</u></td>
		        <td class=lightbluetable align=center>代表人</td>
                <td class=lightbluetable align=center>債信</td>
                <td class=lightbluetable align=center>專利營洽</td>
		        <td class=lightbluetable align=center>商標營洽</td>
            </tr>
	    </thead>
	    <tbody>
</HeaderTemplate>
			<ItemTemplate>
 		        <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>" align="center" style="height:​30px;">
			        <td nowrap style="width:6%">
                       <%#(Eval("custtype").ToString() == "1") ? "客戶" : "申請人"%>
			        </td>
			        <td nowrap style="width:10%">
                        <%#GetCustNoName(Container)%>
			        </td>
			        <td nowrap>
                        <%--<a href="#" target="Eblank">
                            <%#Eval("ap_cname1")%> <%#Eval("ap_cname2")%>
                        </a>--%>
                        <%#GetCustName(Container)%>
			        </td>
                    <td nowrap>
                        <%#Eval("ap_ename1")%> <%#Eval("ap_ename2")%>
			        </td>
                    <td >
                        <%#Eval("id_no")%>
			        </td>
			        <td nowrap>
                        <%# (Eval("ap_erep").ToString() == "") ? Eval("ap_crep") : Eval("ap_crep").ToString() + "/" + Eval("ap_erep").ToString()%>
			        </td>
                    <td nowrap>
                        <%#GetRmarkCode(Container)%>
			        </td>
			        <td nowrap>
                        <%# (Eval("pscode").ToString() == "np") ? "專利部門" : Eval("pscodename")%>
			        </td>
			        <td nowrap>
                        <%# (Eval("tscode").ToString() == "nt") ? "商標部門" : Eval("tscodename")%>
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
<p align="left" class="whitetablebg">
	說明: <br>
	1.「客戶/申請人編號」欄位為<font color="red">區所別-客戶編號(或申請人編號)</font><br>
	2. 區所別包括: N→台北、C→台中、S→台南、K→高雄
	</p>
</form>

</body>
</html>

<script type="text/javascript">
    $(function () {
        if (window.parent.tt !== undefined) {
            window.parent.tt.rows = "100%,0%";
            if ('<%=bData%>' == "False") {
                alert("查無資料!");
                reg.action = "cust46.aspx?prgid=cust46";
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
        reg.action = "cust46.aspx?prgid=cust46";
        reg.submit();
    }


</script>