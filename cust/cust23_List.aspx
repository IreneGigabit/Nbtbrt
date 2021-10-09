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
    protected string HTProgPrefix = "cust23";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";
    DataTable dtMark = new DataTable();
    DataTable dtReport = new DataTable();
    DataTable dtText = new DataTable();
    DataTable dtAttach = new DataTable();
    DataTable dtAttachB = new DataTable();
    DataTable dtCustcode_text = new DataTable();

    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected Paging page = null;

    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";
    protected string FormName = "";

    protected string dept = "";
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
        dept = Sys.GetSession("dept");
        dtCustcode_text = Sys.getCustCode("cmark_text", "", "");
            
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
            StrFormBtnTop += "<a href=javascript:GoToSearch()>[查詢畫面]</a>";
            StrFormBtnTop += "<a href=javascript:GoToAdd()>[新增]</a>";
        }
    }

    
    private void QueryData() {
        
        DataTable dt = new DataTable();
        string SQL = "";
        SQL = "SELECT v.cust_area,v.cust_seq,ap.apsqlno,ap.ap_cname1,ap.ap_cname2,ap.ap_crep,v.id_no, ";
        SQL += "v.in_date,v.pscode,v.tscode, ";
        SQL += "(select sc_name from sysctrl.dbo.scode s1 where s1.scode=v.pscode)pscodename, ";
        SQL += "(select sc_name from sysctrl.dbo.scode s2 where s2.scode=v.tscode)tscodename ";
        SQL += "FROM custz v ";
        SQL += "INNER JOIN apcust ap ON v.cust_area = ap.cust_area AND v.cust_seq = ap.cust_seq ";
        SQL += "where ((select count(*) from apcust_mark m where m.cust_area = v.cust_area AND m.cust_seq = v.cust_seq and m.mark_type in('cmark_report','cmark_text'))>0 ";
        SQL += "or (select count(*) from apcust_attach t where t.cust_area = v.cust_area AND t.cust_seq = v.cust_seq and t.source='custz')>0) ";
        
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
                SQL += " and (c.ap_cname1 LIKE '%" + ReqVal.TryGet("ap_cname") + "%' OR c.ap_cname2 LIKE '%" + ReqVal.TryGet("ap_cname") + "%') ";
            }
            if (ReqVal.TryGet("scode") != "")
            {
                if ((HTProgRight & 128) > 0 && (HTProgRight & 64) > 0)
                {
                    SQL += " and (isnull(tscode,'') = '" + ReqVal.TryGet("scode") + "'";
                    SQL += " or isnull(pscode,'') = '" + ReqVal.TryGet("scode") + "') ";
                }
                else SQL += " and isnull(" + dept.ToLower() + "scode,'') = '" + ReqVal.TryGet("scode") + "'";
            }
        }

        SQL += " order by v.cust_area,v.cust_seq";
        //Sys.showLog(SQL);
        conn.DataTable(SQL, dt);
        
        //抓出主LIST的cust_seq來where IN
        string cust_seqStr = "";
        foreach (DataRow r in dt.Rows)
        {
            cust_seqStr += r["cust_seq"].ToString()+",";
        }

        if (cust_seqStr != "")
        {
            string SQLStr = "select convert(varchar,m.tran_date,120)trandate,convert(varchar,m.end_date,111)enddate,m.*, ";
            SQLStr += "(select code_name from cust_code c where c.code_type='cmark_text' and c.cust_code=m.mark_type2) mark_type2nm_text, ";
            SQLStr += "(select code_name from cust_code c where c.code_type='cmark_report' and c.cust_code=m.mark_type2) mark_type2nm, ";
            SQLStr += "(select code_name from cust_code c where c.code_type='cmark_attach' and c.cust_code=m.spe_mark1) spe_mark1nm, ";
            SQLStr += "(select sc_name from sysctrl.dbo.scode s where m.tran_scode=s.scode) tran_scodenm, ";
            SQLStr += "isnull(Attention,'不指定') Attention ";
            SQLStr += "from apcust_mark m left join custz_Att a on a.Cust_area=m.Cust_area and a.Cust_seq=m.Cust_seq and a.att_sql=m.att_sql ";
            SQLStr += "where m.cust_area='" + ReqVal.TryGet("cust_area") + "' and m.cust_seq IN (" + cust_seqStr.TrimEnd(',') + ") ";
            SQLStr += "order by mark_sqlno";
            conn.DataTable(SQLStr, dtMark);

            string SQLAttach = "select convert(varchar,m.in_date,111)indate, m.*, ";
            SQLAttach += "(select sc_name from sysctrl.dbo.scode s where m.in_scode=s.scode) tran_scodenm ";
            SQLAttach += "from apcust_attach m where source='custz' ";
            SQLAttach += "and m.cust_area='" + ReqVal.TryGet("cust_area") + "' and m.cust_seq IN (" + cust_seqStr.TrimEnd(',') + ") ";
            SQLAttach += "order by apattach_sqlno";
            conn.DataTable(SQLAttach, dtAttach);
        }
        
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

    protected void dataRepeater_ItemDataBound(object sender, RepeaterItemEventArgs e)
    {
        if ((e.Item.ItemType == ListItemType.Item) || (e.Item.ItemType == ListItemType.AlternatingItem))
        {
            string seq = DataBinder.Eval(e.Item.DataItem, "cust_seq").ToString();
            Repeater RptReport = (Repeater)e.Item.FindControl("rptcmark_report");
            if (RptReport != null)
            {
                DataRow[] row = dtMark.Select("mark_type='cmark_report' and cust_seq = " + seq);
                if (row.Length > 0)
                {
                    dtReport = dtMark.Select("mark_type='cmark_report' and cust_seq = " + seq).CopyToDataTable();
                    RptReport.DataSource = dtReport;
                    RptReport.DataBind();
                }
                else RptReport.Visible = false;
            }
            
            Repeater RptText = (Repeater)e.Item.FindControl("rptcmark_text");
            if (RptText != null)
            {
                DataRow[] row = dtMark.Select("mark_type='cmark_text' and cust_seq = " + seq);
                if (row.Length > 0)
                {
                    dtText = dtMark.Select("mark_type='cmark_text' and cust_seq = " + seq).CopyToDataTable();
                    RptText.DataSource = dtText;
                    RptText.DataBind();
                }
                else RptText.Visible = false;
            }

            Repeater RptAttach = (Repeater)e.Item.FindControl("rptattach");
            if (RptAttach != null)
            {
                DataRow[] row = dtAttach.Select("cust_seq = " + seq);
                if (row.Length > 0)
                {
                    dtAttachB = dtAttach.Select("cust_seq = " + seq).CopyToDataTable();
                    RptAttach.DataSource = dtAttachB;
                    RptAttach.DataBind();
                }
                else RptAttach.Visible = false;
            }
        }
    }

    protected string SetDeptName(RepeaterItem Container)
    {
        string Name = "";
        string [] deptStr = Eval("dept").ToString().Split('|');
        for (int i = 0; i < deptStr.Length; i++)
        {
            string s = "";
            switch (deptStr[i])
            {
                case "TI":
                    s = "內商";
                    break;
                case "TE":
                    s = "出商";
                    break;
                case "PI":
                    s = "內專";
                    break;
                case "PE":
                    s = "出專";
                    break;
                case "AC":
                    s = "會計";
                    break;
                default:
                    break;
            }

            Name += s + "、";
        }
        return Name.TrimEnd('、').TrimStart('、');
    }

    protected string SetSyscodeName(RepeaterItem Container)
    {
        string Name = "";
        string s = Eval("syscode").ToString();
        if (s == "BRP") { Name = "專利"; }
        else if (s == "BTBRT") { Name = "商標"; }
        else if (s == "ACC") { Name = "會計"; }
        return Name;
    }

    protected string SetmremarkName(RepeaterItem Container)
    {
        string Name = "";
        string [] m = Eval("mremark").ToString().Split('|');
        for (int i = 0; i < m.Length; i++)
        {
            DataRow[] r = dtCustcode_text.Select("Cust_code = '" + m[i] + "'");
            if (r.Length>0)
            {
                Name += r[0]["Code_name"].ToString() + "、";    
            }
        }
        return Name.TrimEnd('、');
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
        <td class="text9" nowrap="nowrap">&nbsp;【<%#prgid%> 客戶特殊備註管理-清單】</td>
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
<asp:Repeater id="dataRepeater" runat="server" OnItemDataBound="dataRepeater_ItemDataBound">
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
                <td class=lightbluetable align=center colspan="2">作業</td>
                <td style="display:none;" >apsqlno</td>
            </tr>
	    </thead>
	    <tbody>
</HeaderTemplate>
			<ItemTemplate>
 		        <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>" align="center" style="height:​30px;">
			        <td nowrap><%#Eval("cust_seq")%></td>
			        <td nowrap><%#Eval("ap_cname1")%></td>
			        <td nowrap><%#Eval("ap_crep")%></td>
			        <td nowrap><%#Eval("id_no")%></td>
			        <td ><%#(Eval("in_date").ToString() == "") ? "" : DateTime.Parse(Eval("in_date").ToString()).ToString("yyyy/M/d")%></td>
			        <td nowrap><%#Eval("pscodename")%>/<%#Eval("tscodename")%></td>
			        <td nowrap rowspan="1" colspan="1">
                        <a href="javascript:void(0)" onclick="GoToQuery('<%#Eval("cust_area")%>', '<%#Eval("cust_seq")%>')" target="Eblank">[查詢]</a>
			        </td>
                     <td class="hidAdd" nowrap rowspan="1" colspan="1">
                        <a href="javascript:void(0)" onclick="ShowDetail('<%#Container.ItemIndex%>')">[明細]</a>
			        </td>
                    <td style="display:none;">[<%#Eval("apsqlno")%>]</td>
				</tr>
                <tr id="tr_<%#Container.ItemIndex%>" class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>" style="display:none">
                    <td colspan="8">
                         <asp:Repeater id="rptcmark_report" runat="server">
                                    <HeaderTemplate>
                                        <center>
                                        <table border="0" class="bluetable" width="85%" cellspacing="1" cellpadding="0">
                                            <tr><td class=lightbluetable align=center colspan="8">報表備註</td></tr>
                                            <tr>
		                                        <td class=lightbluetable align=center>系統</td>
		                                        <td class=lightbluetable align=center>種類</td>
		                                        <td class=lightbluetable align=center>聯絡人</td>
                                                <td class=lightbluetable align=center>選項</td>
					                            <td class=lightbluetable align=center>停用日期</td>
                                                <td class=lightbluetable align=center>作業</td>
                                            </tr>
                                    </HeaderTemplate>
	                                <ItemTemplate>                 
                                            <tr>
                                                <td nowrap class="whitetablebg" align=center><%#SetSyscodeName(Container)%></td>
			                                    <td nowrap class="whitetablebg" align=center><%#Eval("mark_type2nm")%></td>
			                                    <td nowrap class="whitetablebg" align=center><%#Eval("Attention")%></td>
                                                <td nowrap class="whitetablebg" align=center><%#Eval("spe_mark1nm")%></td>
                                                <td class="whitetablebg" align=center><%#Eval("end_date","{0:yyyy/M/d}")%></td>
                                                <td class="whitetablebg" align=center><a href="#">[修改]</a></td>
		                                    </tr>
                                    </ItemTemplate>
                                    <FooterTemplate>
	                                        </table>
                                            </center>
                                            <br />
                                    </FooterTemplate>
                        </asp:Repeater>
                        <asp:Repeater id="rptcmark_text" runat="server">
                                    <HeaderTemplate>
                                        <center>
                                        <table border="0" class="bluetable" width="85%" cellspacing="1" cellpadding="2">
                                            <tr class=lightbluetable align=center><td colspan="6">備註設定</td></tr>
                                            <tr class=lightbluetable align=center>
		                                        <td>部門</td>
		                                        <td>種類</td>
		                                        <td>聯絡人</td>
                                                <td align="left">說明</td>
					                            <td>停用日期</td>
                                                <td>作業</td>
                                            </tr>
                                    </HeaderTemplate>
	                                <ItemTemplate>                 
                                            <tr class="whitetablebg" align=center>
                                                <td nowrap><%#SetDeptName(Container)%></td>
			                                    <td nowrap><%#Eval("mark_type2nm_text")%></td>
			                                    <td nowrap><%#Eval("Attention")%></td>
                                                <td align="left"><%#Eval("type_content1")%></td>
                                                <td nowrap><%#Eval("end_date","{0:yyyy/M/d}")%></td>
                                                <td nowrap>
                                                    <a href="cust23_Edit.aspx?prgid=cust23&submitTask=U&cust_area=<%#Eval("cust_area")%>&cust_seq=<%#Eval("cust_seq")%>&mark_sqlno=<%#Eval("mark_sqlno")%>" target="Eblank">[修改]</a>
                                                </td>
		                                    </tr>
                                    </ItemTemplate>
                                    <FooterTemplate>
	                                        </table>
                                            </center>
                                            <br />
                                    </FooterTemplate>
                        </asp:Repeater>
                        <asp:Repeater id="rptattach" runat="server">
                                    <HeaderTemplate>
                                        <center>
                                        <table border="0" class="bluetable" width="85%" cellspacing="1" cellpadding="1">
                                            <tr class=lightbluetable align=center><td colspan="4">相關檔案</td></tr>
                                            <tr class=lightbluetable align=center>
		                                        <td>附件名稱</td>
		                                        <td>種類</td>
		                                        <td align="left">附件說明</td>
                                                <td>作業</td>
                                            </tr>
                                    </HeaderTemplate>
	                                <ItemTemplate>                 
                                            <tr class="whitetablebg" align=center>
			                                    <td nowrap><%#Eval("attach_name")%></td>
			                                    <td nowrap><%#SetmremarkName(Container)%></td>
                                                <td nowrap align="left"><%#Eval("attach_desc")%></td>
                                                <td nowrap><a href="#">[修改]</a></td>
		                                    </tr>
                                    </ItemTemplate>
                                    <FooterTemplate>
	                                        </table>
                                            </center>
                                            <br />
                                    </FooterTemplate>
                        </asp:Repeater>
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

        
        $(".Lock").lock();
        $("input.dateField").datepick();
    });

    function ShowDetail(ItemIndex) {
        $("tr[id^='tr_']").hide();
        $("#tr_"+ItemIndex).show();
    }

    //換頁查詢
    function goSearch() {
        $("#regPage").submit();
    };

    function GoToSearch() {
        var url = "cust23.aspx?prgid=cust23";
        reg.target = "Etop"
        reg.action = url;
        reg.submit();
    }
    function GoToAdd() {
        <%--    window.open("cust11_Edit.aspx?prgid=cust11&submitTask=A&cust_area=<%=Sys.GetSession("seBranch")%>", "Eblank");
        window.parent.tt.rows = "0%,100%";--%>
        var url = "cust23_Edit.aspx?prgid=cust23&submitTask=A";
        reg.target = "Eblank";
        reg.action = url;
        reg.submit();
    }
    function GoToQuery(cust_area, cust_seq) {
        var url = "cust23_Edit.aspx?prgid=cust23&submitTask=Q&cust_area="+cust_area+"&cust_seq="+cust_seq;
        reg.target = "Eblank";
        reg.action = url;
        reg.submit();
    }


</script>