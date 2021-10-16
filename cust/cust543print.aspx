<%@ Page Language="C#" %>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Data.SqlClient" %>
<%@ Import Namespace = "System.IO"%>
<%@ Import Namespace = "System.Linq"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<script runat="server">
    protected string HTProgCap = HttpContext.Current.Request["prgname"] ?? "客戶折扣明細表";//功能名稱
    protected string HTProgPrefix = "cust54";//HttpContext.Current.Request["prgid"] ?? "";//程式檔名前綴
    protected string HTProgCode = "cust54";//HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = HttpContext.Current.Request["prgid"] ?? "";//程式代碼
    protected int HTProgRight = 0;
    protected string SQLStr = "";
    protected string wSQL = "";
    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected StringBuilder strOut = new StringBuilder();
    DataTable dtRptMain = new DataTable();
    DataTable dtRpt = new DataTable();//明細
    DataTable dtData = new DataTable();//主資料
    DataTable dtDistype = Sys.getCustCode("B", "", "sortfld");//折扣代碼
    protected string branch = "";//區所別
    //protected string branchname = "";//區所別
    protected int countnum = 0;//總計件數
    protected string scodename = "";
    protected string OrderType = "";
    protected string OrderTypeName = "";
    protected string PagebyScode = "";
    protected string level = "";
    protected string dept = "";
    protected bool bData = true;
    DBHelper conn2 = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    DBHelper cnn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    private void Page_Unload(System.Object sender, System.EventArgs e)
    {
        if (conn2 != null) conn2.Dispose();
        if (cnn != null) cnn.Dispose();
    }

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "Private";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;
        Response.Clear();

        conn2 = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
        cnn = new DBHelper(Conn.Sysctrl).Debug(Request["chkTest"] == "TEST");
        
        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");
        branch = Sys.GetSession("seBranch");
        dept = Sys.GetSession("dept");
        level = ReqVal.TryGet("level");
        PagebyScode = ReqVal.TryGet("PagebyScode");
        
        if (ReqVal.TryGet("ordertype") == "2")
        {
            OrderType = "2";
            OrderTypeName = "依營洽薪號+客戶編號排序";
            if (PagebyScode == "Y") OrderTypeName += " (依營洽分頁)";
        }
        else
        {
            if (ReqVal.TryGet("ordertype") == "1")
            {
                OrderType = "1";
                OrderTypeName = "依客戶名稱排序"; 
            }
            else
            {
                OrderType = "0";
                OrderTypeName = "依客戶編號排序"; 
            }
        }
        
        
        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        if (HTProgRight >= 0) {
            //Sys.showLog(SQLQueryStr());
            PageLayout();
            this.Page.DataBind();
        }
    }

    
    protected void PageLayout()
    {
        wSQL = SQLQueryStr();
        using (DBHelper conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST"))
        {
            //if ((Request["sseq"] ?? "") != "") wSQL += " and seq>='" + Request["sseq"] + "'";
            //branchname = Sys.getCodeName(conn, "sysctrl.dbo.branch_code", "branchname", "where branch='" + Session["seBranch"] + "'");
            SQLStr = "select a.cust_area,a.cust_seq,a.in_date,a.id_no,a.plevel,a.tlevel,a.pscode,a.tscode, a.pdis_type, tdis_type, ";
            SQLStr += "b.apclass,b.ap_cname1,b.ap_cname2, ";
            SQLStr += "(select sc_name from sysctrl.dbo.scode where scode = a.pscode) as pscodename , (select sc_name from sysctrl.dbo.scode where scode = a.tscode) as tscodename ";
            SQLStr += "from custz a , apcust b ";
            SQLStr += "where a.cust_area = b.cust_area and a.cust_seq = b.cust_seq ";
            if (PagebyScode == "Y")
            {
                SQLStr += wSQL + " order by a.cust_area, a.cust_seq";
            }
            else SQLStr += wSQL + SQLOrderBy();
            conn.DataTable(SQLStr, dtData);

            if (dtData.Rows.Count == 0)
            {
                bData = false; return;
            }
            
            
            string SQL = "";
            if (OrderType == "2")
            {
                if (dept == "P")
                {
                    SQL = "select distinct pscode, ";
                    SQL += "(select sc_name from sysctrl.dbo.scode where scode = a.pscode) as pscodename";
                }
                else
                {
                    SQL = "select distinct tscode, ";
                    SQL += "(select sc_name from sysctrl.dbo.scode where scode = a.tscode) as tscodename";
                }
            }
            else
            {
                if (dept == "P")
                {
                    SQL = "select a.cust_area, a.cust_seq, pscode, ";
                    SQL += "(select sc_name from sysctrl.dbo.scode where scode = a.pscode) as pscodename";
                }
                else
                {
                    SQL = "select a.cust_area, a.cust_seq, tscode, ";
                    SQL += "(select sc_name from sysctrl.dbo.scode where scode = a.tscode) as tscodename";
                }
            }
          
            SQL += " FROM custz a , apcust b  WHERE a.cust_area = b.cust_area and a.cust_seq = b.cust_seq ";
            SQL += wSQL + SQLOrderBy();
            
            //第一層 (if type = 2 , Distinct營洽人員)
            //Sys.showLog(SQL);
            if (PagebyScode == "Y")
            {
                Repeater1.Visible = false;
                conn.DataTable(SQL, dtRptMain);
                rptRepeaterMain.DataSource = dtRptMain;
                rptRepeaterMain.DataBind();
            }
            else
            {
                rptRepeaterMain.Visible = false;
                Repeater1.DataSource = dtData;
                Repeater1.DataBind();
            }
           
        }
    }

    protected void dataRepeater_ItemDataBound(object sender, RepeaterItemEventArgs e)
    {
        //string pscode = "";
        string scode = "";
        string scodeStr = "";
        string cust_seq = "";
        if ((e.Item.ItemType == ListItemType.Item) || (e.Item.ItemType == ListItemType.AlternatingItem))
        {
            //pscode = DataBinder.Eval(e.Item.DataItem, "pscode").ToString();
            scode = (dept == "P") ? "pscode" : "tscode";
            scodeStr = DataBinder.Eval(e.Item.DataItem, scode).ToString();
            
            Repeater Rpt = (Repeater)e.Item.FindControl("rptRepeater");
            if (Rpt != null)
            {
                if (dept == "P")
                {
                    if (DataBinder.Eval(e.Item.DataItem, "pscode").ToString() == "np") scodename = "np 專利部門";
                    else
                    {
                        scodename = DataBinder.Eval(e.Item.DataItem, "pscode").ToString() + " " + DataBinder.Eval(e.Item.DataItem, "pscodename").ToString();
                    }
                }
                else
                {
                    if (DataBinder.Eval(e.Item.DataItem, "tscode").ToString() == "nt") scodename = "nt 商標部門";
                    else
                    {
                        scodename = DataBinder.Eval(e.Item.DataItem, "tscode").ToString() + " " + DataBinder.Eval(e.Item.DataItem, "tscodename").ToString();
                    }
                }
                
                if (OrderType == "2")
                {
                    //dtRpt = dtData.Select("pscode = '" + pscode + "'").CopyToDataTable();
                    dtRpt = dtData.Select(scode +" = '" + scodeStr + "'").CopyToDataTable();
                }
                else
                {
                    cust_seq = DataBinder.Eval(e.Item.DataItem, "cust_seq").ToString();
                    dtRpt = dtData.Select("cust_seq = '" + cust_seq + "'").CopyToDataTable();
                }
                
                if (dtRpt.Rows.Count > 0)
                {
                    Rpt.DataSource = dtRpt;
                    Rpt.DataBind();
                }
                else { Rpt.Visible = false; }
            }
        }
    }

    protected void dataRepeater2_ItemDataBound(object sender, RepeaterItemEventArgs e)
    {
        if (e.Item.ItemIndex == 0) {//因pagebind&repeater bind會讓repaeter觸發綁定2次.所以第一筆時總計要重算
            countnum = 0;
        }
        if ((e.Item.ItemType == ListItemType.Item) || (e.Item.ItemType == ListItemType.AlternatingItem)) {
            countnum += 1;
        }
    }

    private string SQLQueryStr()
    {
        //string SQLSub = "";
        string SQLw = "";
        string SQLOrderby = "";
        switch (ReqVal.TryGet("depttype"))
        {
            case "1"://只辦商標or專利客戶
                if (dept == "P")
                {
                    SQLw += " and ((a.pscode is not null and a.pscode <>'') and (a.tscode is null or a.tscode = '')) ";
                }
                else
                {
                    SQLw += " and ((a.tscode is not null and a.tscode <>'') and (a.pscode is null or a.pscode = '')) ";
                }
                break;

            case "2"://商標or專利所有客戶
                if (dept == "P") { SQLw += " and (a.pscode is not null and a.pscode <>'') "; }
                else { SQLw += " and (a.tscode is not null and a.tscode <>'') "; }
                break;

            case "3"://商標/專利共同客戶
                SQLw += " and ((a.tscode is not null and a.tscode <>'') and (a.pscode is not null and a.pscode <>'')) ";
                break;
            default:
                break;
        }

        //日期範圍
        if (ReqVal.TryGet("sdate") != "")
        {
            SQLw += " AND a.in_date >= '" + ReqVal.TryGet("sdate") + "'";
        }
        if (ReqVal.TryGet("edate") != "")
        {
            SQLw += " AND a.in_date <= '" + ReqVal.TryGet("edate") + " 23:59:59'";
        }

        if (ReqVal.TryGet("scode") != "")
        {
            if (ReqVal.TryGet("scode") == "_")
            {
                SQLw += " and (a." + dept.ToLower() + "scode = '' or a." + dept.ToLower() + "scode is null) ";
            }
            else
            {
                SQLw += " and a." + dept.ToLower() + "scode = '" + ReqVal.TryGet("scode") + "' ";
            }
        }

        if (ReqVal.TryGet("cust_seqS") != "") { SQLw += " and a.cust_seq >= " + ReqVal.TryGet("cust_seqS"); }
        if (ReqVal.TryGet("cust_seqE") != "") { SQLw += " and a.cust_seq <= " + ReqVal.TryGet("cust_seqE"); }

        if (level != "")
        {
            string lv = "";
            string[] s = level.Split(',');
            for (int i = 0; i < s.Length; i++)
            {
                lv += "'" + s[i] + "',";
            }
            SQLw += " and a." + dept.ToLower() + "level IN (" + lv.TrimEnd(',') + ") ";
        }

        if (ReqVal.TryGet("dis_type") != "")
        {
            SQLw += " and a." + dept.ToLower() + "dis_type = '" + ReqVal.TryGet("dis_type") + "' ";
        }

        if (ReqVal.TryGet("pay_type") != "")
        {
            SQLw += " and a." + dept.ToLower() + "pay_type = '" + ReqVal.TryGet("pay_type") + "' ";
        }

        switch (ReqVal.TryGet("ordertype"))
        {
            case "0":
                SQLOrderby += " order by a.cust_area, a.cust_seq ";
                break;

            case "1":
                SQLOrderby += " order by a.cust_area, ltrim(isnull(b.ap_cname1,'')+isnull(b.ap_cname2,''))";
                break;

            case "2":
                if (ReqVal.TryGet("PagebyScode") == "Y")
                {
                    //SQLOrderby += " group by isnull(a." + dept.ToLower() + "scode,'') order by scode";
                    SQLOrderby += " order by " + dept.ToLower() + "scode";
                }
                else
                {
                    SQLOrderby += " order by a." + dept.ToLower() + "scode, a.cust_area, a.cust_seq";
                }
                break;

            default:
                break;
        }
        return SQLw;
    }


    private string SQLOrderBy()
    {
        string Orderby = "";
        switch (ReqVal.TryGet("ordertype"))
        {
            case "0":
                Orderby += " order by a.cust_area, a.cust_seq ";
                break;

            case "1":
                Orderby += " order by a.cust_area, ltrim(isnull(b.ap_cname1,'')+isnull(b.ap_cname2,''))";
                break;

            case "2":
                Orderby += " order by " + dept.ToLower() + "scode";
                //if (PagebyScode == "Y") {}
                //else
                //{
                //    SQLOrderby += " order by a." + dept.ToLower() + "scode, a.cust_area, a.cust_seq";
                //}
                break;

            default:
                break;
        }
        return Orderby;
    }

    protected string SetDisType(RepeaterItem Container)
    {
        string type = (dept == "P") ? "pdis_type" : "tdis_type";
        DataRow[] r = dtDistype.Select("cust_code = '" + Eval(type) + "'");
        if (r.Length > 0)
        {
            return r[0]["code_name"].ToString();
        }
        else return "";
    }
    
    protected string SetScodeNameTitle(RepeaterItem Container)//列印順序-依營洽分頁用
    {
        if (OrderType == "2")
        {
            if (dept == "P")
            {
                if (Eval("pscode").ToString() == "np") { return "[ 專利營洽 : " + Eval("pscode") + " 專利部門 ]"; }
                else { return "[ 專利營洽 : " + Eval("pscode") + " " + Eval("pscodename") + " ]"; }
            }
            else
            {
                if (Eval("tscode").ToString() == "nt") { return "[ 商標營洽 : " + Eval("tscode") + " 商標部門 ]"; }
                else { return "[ 商標營洽 : " + Eval("tscode") + " " + Eval("tscodename") + " ]"; }
            }
        }
        else return "";
    }
    protected string SetScodeName(RepeaterItem Container)//列印順序-依營洽分頁用
    {
        if (dept == "P")
        {
            if (Eval("pscode").ToString() == "np") { return Eval("pscode") + "<br />" + "專利部門"; }
            else { return Eval("pscode") + "<br />" + Eval("pscodename"); }
        }
        else
        {
            if (Eval("tscode").ToString() == "nt") { return Eval("tscode") + "<br />" + "商標部門"; }
            else { return Eval("tscode") + "<br />" + Eval("tscodename"); }
        }
    }
    
    protected string SetScodeName2(RepeaterItem Container)
    {
        if (dept == "P")
        {
            if (Eval("pscode").ToString() == "np") { return Eval("pscode") + " " + "專利部門"; }
            else { return Eval("pscode") + " " + Eval("pscodename"); }
        }
        else
        {
            if (Eval("tscode").ToString() == "nt") { return Eval("tscode") + " " + "商標部門"; }
            else { return Eval("tscode") + " " + Eval("tscodename"); }
        }
    }
    
</script>

<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title><%=HTProgCap%></title>
<meta http-equiv="x-ua-compatible" content="IE=10">

<uc1:head_inc_form runat="server" ID="head_inc_form" />
</head>

<body>
<form id="reg" name="reg" method="post">
    <table border="0" width="100%" cellspacing="1" cellpadding="0" align="center">
		<tr style="font-size:12pt">
			<td width="25%" align=left></td>
			<td width="50%"  align=center>
                <b>
                    <span style="font-size:20px"><%=(dept == "P")?"專利":"商標" %><%#HTProgCap%></span><br />
                </b>
                <span style="font-size:14px">◆<%=OrderTypeName%>◆</span>
			</td>
			<td width="25%" align=right></td>
		</tr>
        <tr>
            <td colspan="3" width="25%" align=right><a href="javascript:window.print();void(0);">列印</a>日期：<%#DateTime.Today.ToShortDateString()%></td>
        </tr>

    </table>
    <asp:Label ID="lblEmpty" runat="server" Visible='<%#bool.Parse((rptRepeaterMain.Items.Count==0).ToString())%>'>
        <div align="center"><font color="red" size=2>=== 查無資料===</font></div>
    </asp:Label> 
	<asp:Repeater id="rptRepeaterMain" runat="server" Visible='<%#bool.Parse((rptRepeaterMain.Items.Count>0).ToString())%>' OnItemDataBound="dataRepeater_ItemDataBound">
        <HeaderTemplate>
            <table border="0" width="100%" cellspacing="0" cellpadding="1">	 
        </HeaderTemplate>
	    <ItemTemplate>
                 <tr id ="tr_codename">
                     <%--<input type="hidden" id=seq_<%#(Container.ItemIndex+1)%> value="<%#Eval("pscode")%>">--%>
                     <td colspan="8" >
                        <span style="color:#0000FF; font-size:16px" ><%#SetScodeNameTitle(Container)%></span>  
                     </td>
                 </tr>
                 <asp:Repeater id="rptRepeater" runat="server" OnItemDataBound="dataRepeater2_ItemDataBound">
                        <HeaderTemplate>
                            <table border=1 width="100%" cellspacing="0" cellpadding="4">	
                                <tr>
		                            <td class=lightbluetable align=center style="width:10%">客戶編號</td>
		                            <td class=lightbluetable align=center>客戶名稱</td>
		                            <td class=lightbluetable align=center style="width:10%">統一編號</td>
                                    <td class=lightbluetable align=center style="width:12%">折扣代碼</td>
		                            <td class=lightbluetable align=center style="width:8%">客戶等級</td>
                                    <td class=lightbluetable align=center style="width:12%"><%=(dept == "P")?"專利營洽":"商標營洽"%> </td>
		                            <td class=lightbluetable align=center style="width:10%">建檔日期</td>
                                </tr> 
                        </HeaderTemplate>
	                    <ItemTemplate>
                                <tr>
			                        <td nowrap align=center style="font-size:14px"><b><%#Eval("cust_area")%>-<%#Eval("cust_seq")%></b></td>
			                        <td nowrap align=center><%#Eval("ap_cname1")%><%#Eval("ap_cname2")%></td>
                                    <td nowrap align=center><%#Eval("id_no")%></td>
                                    <td nowrap align=center><%#SetDisType(Container)%></td>
                                    <td nowrap align=center><%#(dept == "P")? Eval("plevel") : Eval("tlevel")%> </td>
                                    <td nowrap align=center><%#SetScodeName2(Container)%></td>
                                    <td nowrap align=center><%#Eval("in_date","{0:d}")%></td>
		                        </tr>
                   </ItemTemplate>
                    <FooterTemplate>
	                            <tr class="lightbluetable" style="font-size:14pt;color:DarkBlue" id="tr_codenamecount">
		                            <td colspan=9>
                                        <b>
                                            [<%=(dept == "P")?"專利營洽":"商標營洽"%> : <%#scodename%> ]
                                            小計：　<%#countnum%>筆
                                        </b>
                                        
		                            </td>
	                            </tr>
                            </table>
                            </center>
                            <br />
                    </FooterTemplate>
                    </asp:Repeater>

        </ItemTemplate>
        <FooterTemplate>
                </table>
                </center>
                <br />
        </FooterTemplate>
    </asp:Repeater>

    <asp:Repeater id="Repeater1" runat="server" Visible='<%#bool.Parse((Repeater1.Items.Count>0).ToString())%>'>
        <HeaderTemplate>
            <table border=1 width="100%" cellspacing="0" cellpadding="4">
                <tr>
		            <td class=lightbluetable align=center style="width:10%">客戶編號</td>
		            <td class=lightbluetable align=center>客戶名稱</td>
		            <td class=lightbluetable align=center style="width:10%">統一編號</td>
                    <td class=lightbluetable align=center style="width:12%">折扣代碼</td>
		            <td class=lightbluetable align=center style="width:8%">客戶等級</td>
                    <td class=lightbluetable align=center style="width:12%"><%=(dept == "P")?"專利營洽":"商標營洽"%> </td>
		            <td class=lightbluetable align=center style="width:10%">建檔日期</td>
                </tr> 	 
        </HeaderTemplate>
	    <ItemTemplate>
                <tr>
			        <td nowrap align=center style="font-size:14px"><b><%#Eval("cust_area")%><%#Eval("cust_seq")%></b></td>
			        <td nowrap align=center><%#Eval("ap_cname1")%><%#Eval("ap_cname2")%></td>
                    <td nowrap align=center><%#Eval("id_no")%></td>
                    <td nowrap align=center><%#SetDisType(Container)%></td>
                    <td nowrap align=center><%#(dept == "P")? Eval("plevel") : Eval("tlevel")%> </td>
                    <td nowrap align=center><%#SetScodeName2(Container)%></td>
                    <td nowrap align=center><%#Eval("in_date","{0:d}")%></td>
	           </tr>
        </ItemTemplate>
        <FooterTemplate>
                </table>
                </center>
                <br />
        </FooterTemplate>
    </asp:Repeater>
</form>
</body>
</html>

<script type="text/javascript">
 
    if ('<%=PagebyScode%>' != "Y") {
        $("#lblEmpty").hide();
    }

    if ('<%=bData%>' == 'False') {
        alert("無符合條件之資料");
        this.close();
    }


</script>
