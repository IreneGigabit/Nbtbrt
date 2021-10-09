<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Linq"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<script runat="server">
    protected string HTProgCap = "客戶契約書管理清單";//HttpContext.Current.Request["prgname"];//功能名稱
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

    DataTable dtApattach = new DataTable();
    protected string qcontract = "";//cust11_List用
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

        qcontract = ReqVal.TryGet("qcontract") ?? "";
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

    protected string SetApname(RepeaterItem Container)
    {
        string Name = "";
        foreach (DataRow r in dtApattach.Select("apattach_sqlno = '" + Eval("apattach_sqlno").ToString() + "'"))
        {
            Name += r["cust_area"].ToString()+r["cust_seq"].ToString() + "-" + r["ap_cname"].ToString() + "<br />";
        }
        return Name;
    }

    protected string SetType(RepeaterItem Container)
    {
        string Type = "";
        DataRow[] row = dtApattach.Select("apattach_sqlno = '" + Eval("apattach_sqlno").ToString() + "'");
        Type = (row.Length > 1) ? "多個" : "單一";
        return Type;
    }

    protected string SetStatus(RepeaterItem Container)
    { 
        string s = "";
        if (Eval("attach_flag").ToString() == "U")
        {
            if (DateTime.Parse(Eval("use_datee").ToString()) < DateTime.Now) s = "逾期";
            else s = "使用中";
        }
        else s = "已停用";
        return s;
    }

    private string ShowEdit(string status)
    {
        string url = "";
        url = "<a href=\"cust21_Edit.aspx?prgid=" + prgid + "&submitTask=Q&apattach_sqlno=" + Eval("apattach_sqlno").ToString() + "\" target=\"Eblank\" >[詳細]<a/>";
        if (status == "使用中")
        {
            url += "<a class=\"hidAdd\" href=\"cust21_Edit.aspx?prgid=" + prgid + "&submitTask=U&apattach_sqlno=" + Eval("apattach_sqlno").ToString() + "\" target=\"Eblank\" >[維護]<a/>";
            if ((HTProgRight & 16) > 0)//有刪除的權限才能顯示及執行by柳月
            {
                url += "<a class=\"hidAdd\" href=\"cust21_Edit.aspx?prgid=" + prgid + "&submitTask=D&apattach_sqlno=" + Eval("apattach_sqlno").ToString() + "\" target=\"Eblank\" >[停用]<a/>";    
            }
        }
        return url;
    }
    
    
    
    private void QueryData() {
        
        DataTable dt = new DataTable();
        SQL = "SELECT a.*, (ap_cname1+ISNULL(ap_cname2,'')) as sap_cname, ";
        SQL += "(select sc_name from sysctrl.dbo.scode where scode=a.sign_scode) as sign_scodenm ";
        SQL += "FROM apcust_attach a ";
        SQL += "inner join apcust c on c.apsqlno=a.apsqlno ";
        SQL += "left join custz d on d.cust_area=c.cust_area and d.cust_seq=c.cust_seq ";
        SQL += "WHERE source='contract' and a.cust_area= '" + ReqVal.TryGet("qrycust_area") + "' ";

        if (ReqVal.TryGet("qrycust_seq") != "")
        {
            SQL += " and exists (select * from apcust_attach_ref r inner join apcust ap on r.apattach_sqlno=a.apattach_sqlno";
            SQL += " and r.apsqlno=ap.apsqlno where ap.cust_seq = '" + ReqVal.TryGet("qrycust_seq") + "') ";
        }
        else
        {
            if (ReqVal.TryGet("qrydept") != "")
            {
                SQL += " and dept = '" + ReqVal.TryGet("qrydept") + "'";
            }

            if (ReqVal.TryGet("qryscode") != "")
            {
                if (ReqVal.TryGet("qryscode") == "all")
                {
                    //補全部??
                    //SQL += " and isnull(a.sign_scode,'') in (" & request("pwhescode") & ")";
                }
                else
                {
                    SQL += " and isnull(a.sign_scode,'') = '" + ReqVal.TryGet("qryscode") + "'";
                }
            }
            if (ReqVal.TryGet("qrycontract_nos") != "")
            {
                SQL += " and a.contract_no >= '" + ReqVal.TryGet("qrycontract_nos") + "'";
            }
            if (ReqVal.TryGet("qrycontract_noe") != "")
            {
                SQL += " and a.contract_no <= '" + ReqVal.TryGet("qrycontract_noe") + "'";
            }
            if (ReqVal.TryGet("qrycontract_sdate") != "")
            {
                SQL += " and a.use_dates >= '" + ReqVal.TryGet("qrycontract_sdate") + "'";//簽約期間Start
            }
            if (ReqVal.TryGet("qrycontract_edate") != "")
            {
                SQL += " and a.use_dates <= '" + ReqVal.TryGet("qrycontract_edate") + "'";//簽約期間End
            }
            if (ReqVal.TryGet("qryuse_date") != "")
            {
                SQL += " and a.use_datee <= '" + ReqVal.TryGet("qryuse_date") + "'";//到期日期
            }
            if (ReqVal.TryGet("qryid_no") != "")
            {
                SQL += " and c.apcust_no LIKE '%" + ReqVal.TryGet("qryid_no") + "%'";
            }
            if (ReqVal.TryGet("qryap_cname") != "")
            {
                SQL += " and (c.ap_cname1 LIKE '%" + ReqVal.TryGet("qryap_cname") + "%' OR c.ap_cname2 LIKE '%" + ReqVal.TryGet("qryap_cname") + "%')";
            }
            if (ReqVal.TryGet("qryap_ename") != "")
            {
                SQL += " and (c.ap_ename1 LIKE '%" + ReqVal.TryGet("qryap_ename") + "%' OR c.ap_ename2 LIKE '%" + ReqVal.TryGet("qryap_ename") + "%')";
            }
            
            //狀態、逾期
            if (ReqVal.TryGet("qryattach_flag") != "")
            {
                if (ReqVal.TryGet("includeexpired") == "")
                {
                    SQL += " and a.attach_flag = '" + ReqVal.TryGet("qryattach_flag") + "'";
                    if (ReqVal.TryGet("qryattach_flag") == "U")
                    {
                        SQL += " and a.use_datee >= GETDATE() ";
                    }
                }
                else
                {
                    if (ReqVal.TryGet("qryattach_flag") == "U")
                    {
                        SQL += " and a.attach_flag = '" + ReqVal.TryGet("qryattach_flag") + "'";
                    }
                    else if (ReqVal.TryGet("qryattach_flag") == "E")//狀態停用-包含狀態是"使用中但已逾期"
                    {
                        SQL += " and (a.attach_flag = '" + ReqVal.TryGet("qryattach_flag") + "' or a.use_datee < GETDATE())";
                    }
                }
            }
        }
        
        
        
        SQL += " order by a.cust_area,a.cust_seq,a.apattach_sqlno";
        //Sys.showLog(SQL);
        conn.DataTable(SQL, dt);

        string s = "";
        foreach (DataRow r in dt.Rows)
        {
            s += "'" + r["apattach_sqlno"] + "',";
        }
        if (s == "") s = "'',";
        string SQLref = "SELECT a.*, b.cust_area, b.cust_seq, (b.ap_cname1+isnull(b.ap_cname2,'')) as ap_cname ";
        SQLref += "FROM apcust_attach_ref a left join apcust b on b.apsqlno=a.apsqlno WHERE apattach_sqlno IN (" + s.TrimEnd(',') + ")";
        conn.DataTable(SQLref, dtApattach);
        

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
        <td class="text9" nowrap="nowrap">&nbsp;【cust21_List <%=HTProgCap%>-<%=(dept == "P")?"專利":"商標"%>】</td>
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
		        <td class=lightbluetable align=center>種類</td>
		        <td class=lightbluetable align=center style="width:8%;">契約書編號</td>
		        <td class=lightbluetable align=center style="width:12%;">有效期間</td>
		        <td class=lightbluetable align=center>單位</td>
		        <td class=lightbluetable align=center>接洽人</td>
		        <td class=lightbluetable align=center>客戶名稱</td>
		        <td class=lightbluetable align=center>檔案</td>
		        <td class=lightbluetable align=center>狀態</td>
                <td class=lightbluetable align=center>備註</td>
                <td class=lightbluetable align=center style="width:10%;">作業</td>
            </tr>
	    </thead>
	    <tbody>
</HeaderTemplate>
			<ItemTemplate>
 		        <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>" align="center" style="height:​30px;">
			        <td nowrap><%#SetType(Container)%></td>
			        <td nowrap><%#Eval("contract_no")%></td>
			        <td>
                        <%#DateTime.Parse(Eval("use_dates").ToString()).ToShortDateString()%>～<%#DateTime.Parse(Eval("use_datee").ToString()).ToShortDateString()%>
			        </td>
			        <td nowrap><%#Eval("cust_area")%><%#Eval("dept")%></td>
			        <td nowrap><%#Eval("sign_scodenm")%></td>
                    <td nowrap><%#SetApname(Container)%></td>
			        <td nowrap>
                        <a  href="<%#Eval("attach_path")%>" target="_blank"><img src="../images/annex.gif"/></a>
			        </td>
			        <td nowrap><%#SetStatus(Container)%></td>
                    <td nowrap><%#Eval("remark")%></td>
                    <td nowrap>
                      <%#ShowEdit(SetStatus(Container))%>
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

            if ('<%=qcontract%>' == "Q") {//cust11_List用
                window.parent.tt.rows = "50%,50%";
                var trs = $("a[class='hidAdd']");
                for (i = 0; i < trs.length; i++) {
                    trs[i].style.display = "none"; //這裡獲取的trs[i]是DOM物件而不是jQuery物件，因此不能直接使用hide()方法 
                }
            }
        }

        $(".Lock").lock();
        $("input.dateField").datepick();
    });

    //執行查詢
    function goSearch() {
        $("#regPage").submit();
    }
   
    function GoToSearch() {
        reg.action = "cust21.aspx?prgid=<%=prgid%>";
        reg.target = "Etop";
        reg.submit();
    }

    function GoToAdd() {
        reg.action = "cust21_Edit.aspx?prgid=cust21&submitTask=A";
        reg.target = "Eblank";
        reg.submit();
        //var url = "cust21_Edit.aspx?prgid=cust21&submitTask=A";
        //window.parent.Eblank.location.href = url;
    }





</script>