<%@ Page Language="C#" %>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Data.SqlClient" %>
<%@ Import Namespace = "System.IO"%>
<%@ Import Namespace = "System.Linq"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<script runat="server">
    protected string HTProgCap = HttpContext.Current.Request["prgname"] ?? "商標期限管制報表列印";//功能名稱
    protected string HTProgPrefix = HttpContext.Current.Request["prgid"] ?? "";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = HttpContext.Current.Request["prgid"] ?? "";//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";
    protected string SQL = "";
    
    protected StringBuilder strOut = new StringBuilder();
    DataTable dtRpt = new DataTable();//明細

    protected string branchname = "";

    DBHelper conn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    private void Page_Unload(System.Object sender, System.EventArgs e) {
        if (conn != null) conn.Dispose();
    }

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "Private";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");

        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        //HTProgCap = myToken.Title;
        DebugStr = myToken.DebugStr;
        if (HTProgRight >= 0) {
            PageLayout();
            this.Page.DataBind();
        }
    }

    protected int totcnt = 0;//總計件數
    protected int ctrlcnt = 0;//管制期限件數

    protected void PageLayout() {
        branchname = Sys.getCodeName(conn, "sysctrl.dbo.branch_code", "branchname", "where branch='" + Session["seBranch"] + "'");

        string wSQL = "";
        if ((Request["sstep_date"] ?? "") != "") wSQL += " and a.step_date>='" + Request["sstep_date"] + "'";
        if ((Request["estep_date"] ?? "") != "") wSQL += " and a.step_date<='" + Request["estep_date"] + "'";
        if ((Request["sseq"] ?? "") != "") wSQL += " and a.seq>=" + Request["sseq"];
        if ((Request["eseq"] ?? "") != "") wSQL += " and a.seq<=" + Request["eseq"];
        if ((Request["sctrl_date"] ?? "") != "") wSQL += " and b.ctrl_date>='" + Request["sctrl_date"] + "'";
        if ((Request["ectrl_date"] ?? "") != "") wSQL += " and b.ctrl_date<='" + Request["ectrl_date"] + "'";
        if ((Request["ctrl_type"] ?? "") != "") wSQL += " and b.ctrl_type='" + Request["ctrl_type"] + "'";
        if ((Request["scode1"] ?? "") != "") wSQL += " and a.scode1<=" + Request["scode1"] + "'";

        SQL = "select min(b.ctrl_date) as ctrl_date,a.rs_no,a.branch,a.seq,a.seq1,a.step_grade,a.cappl_name,a.rs_detail,a.scode1";
        SQL += ",(select sc_name from sysctrl.dbo.scode where scode=a.scode1) scodenm,''tclass,''fseq";
        SQL += " from vstep_dmt a ";
        SQL += "inner join ctrl_dmt b on a.rs_no  = b.rs_no";
        SQL += " where a.branch  = '" + Session["seBranch"] + "'";
        SQL += wSQL;
        SQL += " group by a.rs_no,a.branch,a.seq,a.seq1,a.step_grade,a.cappl_name,a.rs_detail,a.scode1";
        if ((Request["sort"] ?? "") == "scode1") {
            SQL += " order by " + Request["sort"] + ",ctrl_date";
        } else {
            SQL += " order by " + Request["sort"];
        }
        conn.DataTable(SQL, dtRpt);

        for (int i = 0; i < dtRpt.Rows.Count; i++) {
            DataRow dr = dtRpt.Rows[i];

            //行樣式
            dr["tclass"] = (i + 1) % 2 == 1 ? "sfont9" : "lightbluetable3";

            //案號
            dr["fseq"] = Sys.formatSeq1(dr.SafeRead("seq", ""), dr.SafeRead("seq1", ""), "", dr.SafeRead("Branch", ""), Sys.GetSession("dept"));
        }

        grpRepeater.DataSource = dtRpt;
        grpRepeater.DataBind();
    }

    protected void grpRepeater_ItemDataBound(object sender, RepeaterItemEventArgs e) {
        if (e.Item.ItemIndex == 0) {//因pagebind&repeater bind會讓repaeter觸發綁定2次.所以第一筆時總計要重算
            totcnt = 0;
            ctrlcnt = 0;
        }

        if ((e.Item.ItemType == ListItemType.Item) || (e.Item.ItemType == ListItemType.AlternatingItem)) {
            totcnt += 1;//總計件數
            
            Repeater dtlRpt = (Repeater)e.Item.FindControl("dtlRepeater");

            if ((dtlRpt != null)) {
                string rs_no = ((DataRowView)e.Item.DataItem).Row["rs_no"].ToString();
                DataTable dtDtl = new DataTable();
                SQL = "select ctrl_type,ctrl_date,code_name,''tcolor";
                SQL += " from ctrl_dmt a inner join cust_code b on a.ctrl_type = b.cust_code and b.code_type = 'CT'";
                SQL += " where rs_no='" + rs_no + "'";
                SQL += " order by ctrl_date ";
                conn.DataTable(SQL, dtDtl);

                for (int i = 0; i < dtDtl.Rows.Count; i++) {
                    DataRow dr = dtDtl.Rows[i];
                    
                    //管制顏色
                    dr["tcolor"] = Sys.getSetting(Sys.GetSession("dept"), "1", Util.parseDBDate(dr.SafeRead("ctrl_date", ""),"yyyy/M/d"));
                }
                
                dtlRpt.DataSource = dtDtl;
                dtlRpt.DataBind();
            }
        }
    }

    protected void dtlRepeater_ItemDataBound(object sender, RepeaterItemEventArgs e) {
        if ((e.Item.ItemType == ListItemType.Item) || (e.Item.ItemType == ListItemType.AlternatingItem)) {
            ctrlcnt += 1;//管制期限件數
        }
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta http-equiv="x-ua-compatible" content="IE=10">
<title><%=HTProgCap%></title>
    <uc1:head_inc_form runat="server" ID="head_inc_form" />
</head>

<body onload="window.focus();">
    <table border="0" width="100%" cellspacing="1" cellpadding="0" align="center">
	    <tr>
            <td width="100%" style="font-size:20px" colspan="3" align=center><%#branchname%><%#HTProgCap%></td>
	    </tr>
	    <tr style="font-size:12pt">
		    <td width="31%" align=left>稽催期間：<%#Request["sctrl_date"]%>～<%#Request["ectrl_date"]%></td>
		    <td width="39%" align=left>管制種類：<%#Request["ctrl_name"]%></td>
		    <td width="20%" align=right><a href="javascript:window.print();void(0);">列印</a>日期：<%#DateTime.Today.ToShortDateString()%></td>
	    </tr>
    </table>

	<asp:Repeater id="grpRepeater" runat="server" OnItemDataBound="grpRepeater_ItemDataBound" Visible='<%#bool.Parse((grpRepeater.Items.Count>0).ToString())%>'>
    <HeaderTemplate>
        <table border="0" class="bluetable" cellspacing="1" cellpadding="2" width="100%">	
			<tr align="center" class="lightbluetable" style="font-size:12pt">
		        <td nowrap>本所編號</td>
		        <td nowrap>進度</td>
		        <td>商標名稱</td>
		        <td>管制內容</td>
		        <td nowrap>營洽姓名</td>
		        <td nowrap>管制期限</td>
			</tr>
    </HeaderTemplate>
	<ItemTemplate>
		<tr class="<%#Eval("tclass")%>">
		    <td nowrap align="center"><%#Eval("fseq")%></td>
		    <td nowrap align="center"><%#Eval("step_grade")%></td>
		    <td align="center">&nbsp;<%#Eval("cappl_name")%></td>
		    <td align="center">&nbsp;<%#Eval("rs_detail")%></td>
		    <td nowrap align="center">&nbsp;<%#Eval("scodenm")%></td>
	        <asp:Repeater id="dtlRepeater" runat="server" OnItemDataBound="dtlRepeater_ItemDataBound">
                <ItemTemplate>
                <asp:Panel runat="server" Visible='<%#Container.ItemIndex != 0 %>'><!--第1筆期限要顯示在上一層,其餘期限顯示在下層(要補前面的空格)-->
		        <tr class="<%#DataBinder.Eval(((RepeaterItem)Container.Parent.Parent).DataItem, "tclass") %>">
			        <td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td>
                </asp:Panel>
                <td nowrap align=left>
                    <font color="<%#Eval("tcolor")%>"><%#Eval("code_name").ToString().Left(2)%>&nbsp;<%#Eval("ctrl_date","{0:yyyy/M/d}")%></font>
                </td>
                </ItemTemplate>
            </asp:Repeater>
		</tr>
    </ItemTemplate>
    <FooterTemplate>
            <tr class="lightbluetable" style="font-size:10pt;color:DarkBlue">
		        <td colspan=5 align=right>合   計：</td>
		        <td align=left>案    件&nbsp;<%=totcnt%> &nbsp;件<br>管制期限&nbsp;<%=ctrlcnt%>&nbsp;筆</td>
            </tr>
        </table>
    </FooterTemplate>
    </asp:Repeater>

    <asp:Label ID="lblEmpty" runat="server" Visible='<%#bool.Parse((grpRepeater.Items.Count==0).ToString())%>'>
        <div align="center"><font color="red" size=2>=== 查無資料===</font></div>
    </asp:Label> 
    <BR>
</body>
</html>
