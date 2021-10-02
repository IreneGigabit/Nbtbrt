<%@ Page Language="C#" %>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Data.SqlClient" %>
<%@ Import Namespace = "System.IO"%>
<%@ Import Namespace = "System.Linq"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<script runat="server">
    protected string HTProgCap = HttpContext.Current.Request["prgname"] ?? "客戶資料更正明細表";//功能名稱
    protected string HTProgPrefix = "cust54";//HttpContext.Current.Request["prgid"] ?? "";//程式檔名前綴
    protected string HTProgCode = "cust54";//HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = HttpContext.Current.Request["prgid"] ?? "";//程式代碼
    protected int HTProgRight = 0;
    protected string SQLStr = "";
    protected string wSQL = "";
    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected StringBuilder strOut = new StringBuilder();
    DataTable dtRpt = new DataTable();//明細
    DataTable dtRptDetail = new DataTable();//聯絡人明細
    DataTable dtData = new DataTable();//主資料
    DataTable dtDataDetail = new DataTable();//主資料
    protected string scodename = "";
    protected string OrderType = "";
    protected string OrderTypeName = "";
    protected string level = "";
    protected string dept = "";
    protected string deptName = "";
    protected string ShowQDate = "";
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
        dept = Sys.GetSession("dept");
        deptName = (dept == "P") ? "專利" : "商標";
        level = ReqVal.TryGet("level");
        
        if (ReqVal.TryGet("ordertype") == "2")
        {
            OrderType = "2";
            OrderTypeName = "依營洽薪號+客戶編號排序";
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

        if (ReqVal.TryGet("sdate") != "" || ReqVal.TryGet("edate") != "")
        {
            ShowQDate = "查詢日期:" + ReqVal.TryGet("sdate") + "～" + ReqVal.TryGet("edate");
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
            SQLStr += "SELECT a.*,c.pscode,c.tscode,b.ap_cname1,b.ap_cname2,b.ap_ename1,b.ap_ename2, b.apcust_no, ";
            SQLStr += "(select sc_name from sysctrl.dbo.scode where scode=c.pscode) as pscodenm, ";
            SQLStr += "(select sc_name from sysctrl.dbo.scode where scode=c.tscode) as tscodenm ";
            SQLStr += "FROM apcust_log a,apcust b,custz c ";
            SQLStr += "WHERE a.cust_area=b.cust_area and a.cust_seq=b.cust_seq and a.cust_area=c.cust_area and a.cust_seq=c.cust_seq ";
            SQLStr += wSQL + " order by a.cust_area, a.cust_seq";
            conn.DataTable(SQLStr, dtData);

            string SQL = "";
            SQL += "SELECT distinct a.cust_area, a.cust_seq, a.apsqlno, b.apcust_no, b.ap_cname1,b.ap_cname2,c.pscode,c.tscode, ";
            SQL += "(select sc_name from sysctrl.dbo.scode where scode=c.pscode) as pscodenm, (select sc_name from sysctrl.dbo.scode where scode=c.tscode) as tscodenm ";
            SQL += "FROM apcust_log a, apcust b, custz c ";
            SQL += "WHERE a.cust_area=b.cust_area and a.cust_seq=b.cust_seq and a.cust_area=c.cust_area and a.cust_seq=c.cust_seq ";
            SQL += wSQL + SQLOrderBy();

            //Sys.showLog(SQL);
            //return;
            conn.DataTable(SQL, dtRpt);
            if (dtRpt.Rows.Count == 0)
            {
                bData = false; return;
            }
            
            rptRepeater.DataSource = dtRpt;
            rptRepeater.DataBind();
        }
    }

    protected void dataRepeater_ItemDataBound(object sender, RepeaterItemEventArgs e)
    {
        if ((e.Item.ItemType == ListItemType.Item) || (e.Item.ItemType == ListItemType.AlternatingItem))
        {
            //if (AttFlag != "Y") return;
            string seq = DataBinder.Eval(e.Item.DataItem, "cust_seq").ToString();
            Repeater Rpt = (Repeater)e.Item.FindControl("rptRepeaterDetail");
            if (Rpt != null)
            {
                DataRow[] row = dtData.Select("cust_seq = " + seq);
                if (row.Length > 0)
                {
                    dtRptDetail = dtData.Select("cust_seq = " + seq).CopyToDataTable();
                    Rpt.DataSource = dtRptDetail;
                    Rpt.DataBind();
                }
                else
                {
                    Rpt.Visible = false;
                }
            }
        }
    }

  
    private string SQLQueryStr()
    {
        string SQLw = "";
        
        switch (ReqVal.TryGet("depttype"))
        {
            case "1"://只辦商標or專利客戶
                if (dept == "P")
                {
                    SQLw += " and ((c.pscode is not null and c.pscode <>'') and (c.tscode is null or c.tscode = '')) ";
                }
                else
                {
                    SQLw += " and ((c.tscode is not null and c.tscode <>'') and (c.pscode is null or c.pscode = '')) ";
                }
                break;

            case "2"://商標or專利所有客戶
                if (dept == "P") { SQLw += " and (c.pscode is not null and c.pscode <>'') "; }
                else { SQLw += " and (c.tscode is not null and c.tscode <>'') "; }
                break;

            case "3"://商標/專利共同客戶
                SQLw += " and ((c.tscode is not null and c.tscode <>'') and (c.pscode is not null and c.pscode <>'')) ";
                break;
            default:
                break;
        }

        //日期範圍
        if (ReqVal.TryGet("sdate") != "")
        {
            SQLw += " AND a.tran_date >= '" + ReqVal.TryGet("sdate") + "'";
        }
        if (ReqVal.TryGet("edate") != "")
        {
            SQLw += " AND a.tran_date <= '" + ReqVal.TryGet("edate") + " 23:59:59'";
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

        return SQLw ;
    }

    private string SQLOrderBy()
    {
        string Orderby = "";
        switch (ReqVal.TryGet("ordertype"))
        {
            case "0":
                Orderby += " order by a.cust_area, a.cust_seq";
                break;

            case "1":
                Orderby += " order by a.cust_area, b.ap_cname1, b.ap_cname2";
                break;

            case "2":
                Orderby += " order by c." + dept.ToLower() + "scode, a.cust_area, a.cust_seq";
                break;

            default:
                break;
        }
        return Orderby;
    }

    protected string SetScodeName(RepeaterItem Container)
    {
        string p = "";
        string t = "";
        
        if (Util.NullConvert(Eval("pscode")) !="")
        {
            p = "專利營洽:" + Eval("pscode").ToString() + " " + Eval("pscodenm");
        }
        if (Util.NullConvert(Eval("tscode")) != "")
        {
            t = "，商標營洽:" + Eval("tscode").ToString() + " " + Eval("tscodenm");
        }
        
        return p + t;
    }

</script>

<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title><%=(dept == "P")?"專利":"商標" %><%=HTProgCap%></title>
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
            <td colspan="3" width="25%" align=right><%=ShowQDate%></td>
        </tr>
        <tr>
            <td colspan="3" width="25%" align=right><a href="javascript:window.print();void(0);">列印</a>日期：<%#DateTime.Today.ToShortDateString()%></td>
        </tr>

    </table>
    <asp:Label ID="lblEmpty" runat="server" Visible='<%#bool.Parse((rptRepeater.Items.Count==0).ToString())%>'>
        <div align="center"><font color="red" size=2>=== 查無資料===</font></div>
    </asp:Label> 
	<asp:Repeater id="rptRepeater" runat="server" Visible='<%#bool.Parse((rptRepeater.Items.Count>0).ToString())%>' OnItemDataBound="dataRepeater_ItemDataBound">
        <FooterTemplate>
        </FooterTemplate>
        <HeaderTemplate>
            <table border=0 width="100%" cellspacing="0" cellpadding="2">	
        </HeaderTemplate>
	    <ItemTemplate>
                <%--放營洽--%>
                <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>">
			        <td align="left" colspan="4">【<%#SetScodeName(Container)%>】</td>
		        </tr>
                <%--放客戶資料--%>
                <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>">
			        <td align="left" style="width:15%" nowrap>[客戶編號：<%#Eval("cust_area")%>-<%#Eval("cust_seq")%></td>
			        <td align="left" style="width:13%" nowrap>ID：<%#Eval("apcust_no")%></td>
			        <td align="left" style="width:15%" nowrap>申請人流水號：<%#Eval("apsqlno")%></td>
                    <td align="left" nowrap>名稱：<%#Eval("ap_cname1")%><%#Eval("ap_cname2")%>]</td>
		        </tr>
                <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>">
                    <td colspan="4">
                           <asp:Repeater id="rptRepeaterDetail" runat="server">
                                    <HeaderTemplate>
                                        <table border=1 width="100%" cellspacing="0" cellpadding="4">
                                            <tr>
		                                        <td class=lightbluetable align=center style="width:20%">異動日期</td>
		                                        <td class=lightbluetable align=center style="width:10%">異動人員</td>
		                                        <td class=lightbluetable align=center style="width:10%">變更項目</td>
                                                <td class=lightbluetable align=center>變更欄位</td>
					                            <td class=lightbluetable align=left>原資料</td>
                                                <td class=lightbluetable align=left>新資料</td>
                                            </tr>
                                    </HeaderTemplate>
	                                <ItemTemplate>                 
                                            <tr>
			                                    <td align=center><%#Eval("tran_date","{0:yyyy/M/d tt hh:mm:ss}")%></td>
			                                    <td nowrap align=center><%#Eval("tran_scode")%></td>
			                                    <td nowrap align=center><%#Eval("chg_kind")%></td>
                                                <td nowrap align=center><%#Eval("fidcname")%></td>
                                                <td align=left><%#Eval("ovalue")%></td>
                                                <td align=left><%#Eval("nvalue")%></td>
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



           
 		        <tr style="border:0"><td colspan="6"></td></tr>
            
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
    if ('<%=bData%>' == 'False') {
        alert("無符合條件之資料");
        this.close();
    }
  


</script>
