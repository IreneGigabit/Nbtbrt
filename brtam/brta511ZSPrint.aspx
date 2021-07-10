<%@ Page Language="C#" %>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Data.SqlClient" %>
<%@ Import Namespace = "System.IO"%>
<%@ Import Namespace = "System.Linq"%>
<%@ Import Namespace = "System.Collections.Generic"%>

<script runat="server">
    protected string HTProgCap = HttpContext.Current.Request["prgname"] ?? "商標本所發文明細表";//功能名稱
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

    protected int countnum = 0;//小計件數
    protected int totcnt = 0;//總計件數

    protected void PageLayout() {
        string wSQL = "";
        if ((Request["sdate"] ?? "") != "") wSQL += " and step_date>='" + Request["sdate"] + "'";
        if ((Request["edate"] ?? "") != "") wSQL += " and step_date<='" + Request["edate"] + "'";
        if ((Request["srs_no"] ?? "") != "") wSQL += " and rs_no>='" + Request["srs_no"] + "'";
        if ((Request["ers_no"] ?? "") != "") wSQL += " and rs_no<='" + Request["ers_no"] + "'";
        if ((Request["sseq"] ?? "") != "") wSQL += " and seq>=" + Request["sseq"];
        if ((Request["eseq"] ?? "") != "") wSQL += " and seq<=" + Request["eseq"];
        if ((Request["in_scode"] ?? "") != "") wSQL += " and dmt_scode='" + Request["in_scode"] + "'";
        if ((Request["scust_seq"] ?? "") != "") wSQL += " and cust_seq>=" + Request["scust_seq"];
        if ((Request["ecust_seq"] ?? "") != "") wSQL += " and cust_seq<=" + Request["ecust_seq"];

        SQL = "select main_rs_no,receive_way,branch,cappl_name,seq,seq1,rs_no,step_date,rs_detail,apply_no,fees ";
        SQL += ",(select code_name from cust_code where code_type='treceive_way' and cust_code=vstep_dmt.receive_way) as rec_name ";
        SQL += ",''fseq ";
        SQL += " from vstep_dmt where branch='" + Session["seBranch"] + "' and cg = 'z' and rs = 's' ";
        SQL += wSQL;
        SQL += " group by receive_way,branch,seq,seq1,rs_no,step_date,rs_detail,apply_no,fees,cappl_name,main_rs_no";
        SQL += " order by receive_way,seq,seq1,main_rs_no,rs_no";
        conn.DataTable(SQL, dtRpt);

        for (int i = 0; i < dtRpt.Rows.Count; i++) {
            DataRow dr = dtRpt.Rows[i];
            branchname = Sys.getCodeName(conn, "sysctrl.dbo.branch_code", "branchname", "where branch='" + dr["Branch"] + "'");

            //案號
            dr["fseq"] = Sys.formatSeq(dr.SafeRead("seq", ""), dr.SafeRead("seq1", ""), "", dr.SafeRead("Branch", ""), Sys.GetSession("dept"));
        }

        DataTable dtSendCL = dtRpt.DefaultView.ToTable(true, new string[] { "branch", "receive_way", "rec_name" });
        clRepeater.DataSource = dtSendCL;
        clRepeater.DataBind();
    }

    protected void clRepeater_ItemDataBound(object sender, RepeaterItemEventArgs e) {
        if (e.Item.ItemIndex == 0) {//因pagebind&repeater bind會讓repaeter觸發綁定2次.所以第一筆時總計要重算
            totcnt = 0;
        }
        countnum = 0;
        //if ((e.Item.ItemType == ListItemType.Header)) {
        //    Response.Write("<span style='color:red'>clRepeater_HeaderDataBound</span><BR>");
        //}
        //if ((e.Item.ItemType == ListItemType.Item) || (e.Item.ItemType == ListItemType.AlternatingItem)) {
        //    Response.Write("<span style='color:red'>clRepeater_ItemDataBound</span>" + e.Item.ItemIndex + "<BR>");
        //}
        
        if ((e.Item.ItemType == ListItemType.Item) || (e.Item.ItemType == ListItemType.AlternatingItem)) {
            Repeater dtlRpt = (Repeater)e.Item.FindControl("dtlRepeater");

            if ((dtlRpt != null)) {
                string branch = ((DataRowView)e.Item.DataItem).Row["branch"].ToString();
                string receive_way = ((DataRowView)e.Item.DataItem).Row["receive_way"].ToString();
                    
                //DataTable dtDtl = dtRpt.Select("branch='" + branch + "' and receive_way='" + receive_way + "'").CopyToDataTable();
                var rows = dtRpt.Select("branch='" + branch + "' and isnull(receive_way,'')='" + receive_way + "'");
                var dtDtl = rows.Any() ? rows.CopyToDataTable() : dtRpt.Clone();
                dtlRpt.DataSource = dtDtl;
                dtlRpt.DataBind();
            }
        }
    }

    protected void dtlRepeater_ItemDataBound(object sender, RepeaterItemEventArgs e) {
        //if ((e.Item.ItemType == ListItemType.Header)) {
        //    Response.Write("<span style='color:red'>dtlRepeater_HeaderDataBound</span><BR>");
        //}
        //if ((e.Item.ItemType == ListItemType.Item) || (e.Item.ItemType == ListItemType.AlternatingItem)) {
        //    Response.Write("<span style='color:red'>dtlRepeater_ItemDataBound</span><BR>");
        //}

        if ((e.Item.ItemType == ListItemType.Item) || (e.Item.ItemType == ListItemType.AlternatingItem)) {
            countnum += 1;//小計件數
            totcnt += 1;//總計件數
        }
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta http-equiv="x-ua-compatible" content="IE=10">
<title><%=HTProgCap%></title>
<link rel="stylesheet" type="text/css" href="<%=Page.ResolveUrl("~/inc/setstyle.css")%>" />
<link rel="stylesheet" type="text/css" href="<%=Page.ResolveUrl("~/js/lib/jquery.datepick.css")%>" />
<link rel="stylesheet" type="text/css" href="<%=Page.ResolveUrl("~/js/lib/toastr.css")%>" />
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/jquery-1.12.4.min.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/jquery.datepick.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/jquery.datepick-zh-TW.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/toastr.min.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/util.js")%>"></script>
</head>

<body>
    <table border="0" width="100%" cellspacing="1" cellpadding="0" align="center">
	    <tr>
            <td width="100%" style="font-size:20px" colspan="3" align=center><%#branchname%><%#HTProgCap%></td>
	    </tr>
	    <tr style="font-size:12pt">
		    <td width="20%" align=left></td>
		    <td width="60%" align=center>發文日期：<%#Request["sdate"]%>～<%#Request["edate"]%></td>
		    <td width="20%" align=right><!--<a href="javascript:window.print();void(0);">列印</a>-->日期：<%#DateTime.Today.ToShortDateString()%></td>
	    </tr>
    </table>

	<asp:Repeater id="clRepeater" runat="server" OnItemDataBound="clRepeater_ItemDataBound" Visible='<%#bool.Parse((clRepeater.Items.Count>0).ToString())%>'>
    <HeaderTemplate>
        <table border="0" class="bluetable" cellspacing="1" cellpadding="2" width="100%">	
			<tr align="center" height="20" class="lightbluetable" style="font-size:12pt">
				<td nowrap>本所編號</td>
		        <td>案件名稱</td>
				<td nowrap>發文日期</td>
				<td nowrap>發文字號</td>
				<td>發文內容</td>
				<td nowrap>申請號</td>
			</tr>
    </HeaderTemplate>
	<ItemTemplate>
			<tr class="lightbluetable3" style="font-size:12pt">
				<td colspan=9>&nbsp;<b>通知方式：<%#Eval("rec_name")%></b>&nbsp;</td>
			</tr>
	        <asp:Repeater id="dtlRepeater" runat="server" OnItemDataBound="dtlRepeater_ItemDataBound">
	        <ItemTemplate>
		        <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>">
			        <td nowrap align="center"><%#(Eval("rs_no").ToString()!=Eval("main_rs_no").ToString()?"*":"")%><%#Eval("fseq")%></td>
			        <td>&nbsp;<%#Eval("cappl_name").ToString().CutData(20)%></td>
			        <td nowrap align="center"><%#Eval("step_date","{0:yyyy/M/d}")%></td>
			        <td nowrap align="center"><%#Eval("rs_no")%></td>
			        <td>&nbsp;<%#Eval("rs_detail")%></td>
			        <td nowrap align="center">&nbsp;<%#Eval("apply_no")%></td>
		        </tr>
            </ItemTemplate>
            <FooterTemplate>
				<tr class="lightbluetable" style="font-size:12pt;color:DarkBlue">
					<td colspan=6>　小　　計：　　<%#countnum%>件
					</td>
				</tr>
            </FooterTemplate>
            </asp:Repeater>
    </ItemTemplate>
    <FooterTemplate>
            <tr class="lightbluetable" style="font-size:12pt;color:DarkBlue">
                <td colspan=6>　總　　計：　　<%#totcnt%>件
                </td>
            </tr>
        </table>
    </FooterTemplate>
    </asp:Repeater>

    <asp:Label ID="lblEmpty" runat="server" Visible='<%#bool.Parse((clRepeater.Items.Count==0).ToString())%>'>
        <div align="center"><font color="red" size=2>=== 查無資料===</font></div>
    </asp:Label> 
    <BR>
</body>
</html>
