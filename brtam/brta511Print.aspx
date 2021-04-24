<%@ Page Language="C#" %>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Data.SqlClient" %>
<%@ Import Namespace = "System.IO"%>
<%@ Import Namespace = "System.Linq"%>
<%@ Import Namespace = "System.Collections.Generic"%>

<script runat="server">
    protected string HTProgCap = HttpContext.Current.Request["prgname"] ?? "商標官方發文明細表";//功能名稱
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

        if (Request["send_way"] == "E") HTProgCap += "(電子送件)";
        if (Request["send_way"] == "EA") HTProgCap += "(註冊費電子送件)";

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
    protected int subcount = 0;//併案件數
    protected int fees = 0;//小計規費
    protected int totcnt = 0;//總計件數
    protected int tot_subcount = 0;//總計併案件數
    protected int totfees = 0;//總計規費

    protected void PageLayout() {
        string wSQL = "";
        if ((Request["sdate"] ?? "") != "") wSQL += " and step_date>='" + Request["sdate"] + "'";
        if ((Request["edate"] ?? "") != "") wSQL += " and step_date<='" + Request["edate"] + "'";
        if ((Request["srs_no"] ?? "") != "") wSQL += " and main_rs_no>='" + Request["srs_no"] + "'";
        if ((Request["ers_no"] ?? "") != "") wSQL += " and main_rs_no<='" + Request["ers_no"] + "'";
        if ((Request["sseq"] ?? "") != "") wSQL += " and seq>=" + Request["sseq"];
        if ((Request["eseq"] ?? "") != "") wSQL += " and seq<=" + Request["eseq"];
        if ((Request["in_scode"] ?? "") != "") wSQL += " and dmt_scode='" + Request["in_scode"] + "'";
        if ((Request["scust_seq"] ?? "") != "") wSQL += " and cust_seq>=" + Request["scust_seq"];
        if ((Request["ecust_seq"] ?? "") != "") wSQL += " and cust_seq<=" + Request["ecust_seq"];
        if ((Request["qrysend_dept"] ?? "") != "") wSQL += " and opt_Branch='" + Request["qrysend_dept"] + "'";
        if ((Request["send_way"] ?? "") != "") {
            if ((Request["send_way"] ?? "") == "E" || (Request["send_way"] ?? "") == "EA") {
                wSQL += " and send_way='" + Request["send_way"] + "'";
            } else {
                wSQL += "  and isnull(send_way,'') not in('E','EA') ";
            }
        }

        SQL = "select send_cl,send_clnm,branch,main_rs_no,seq,seq1,rs_no,step_date,rs_detail,apply_no,fees,'正本' as sendmark,step_grade,issue_no ";
        SQL += " ,send_way,receipt_type,receipt_title,''fseq";
        SQL += " from vstep_dmt where branch='" + Session["seBranch"] + "' and cg = 'g' and rs = 's'";
        SQL += wSQL;
        SQL += " and left(rs_no,1)='G' ";//2006/5/27配合爭救案系統不列印爭救案發文資料,爭救案發文字號第一碼為B
        SQL += " union ";
        SQL += "select send_cl1 as send_cl,send_cl1nm as send_clnm,branch,main_rs_no,seq,seq1,rs_no,step_date,rs_detail,apply_no,fees,'副本' as sendmark,step_grade,issue_no ";
        SQL += " ,'" + Request["send_way"] + "'send_way,'P'receipt_type,''receipt_title,''fseq ";
        SQL += " from vstep_dmt where branch='" + Session["seBranch"] + "' and cg = 'g' and rs = 's'";
        SQL += wSQL + " and send_cl1 is not null";
        SQL += " and left(rs_no,1)='G' ";//2006/5/27配合爭救案系統不列印爭救案發文資料,爭救案發文字號第一碼為B
        SQL += " group by send_cl,main_rs_no,send_clnm,send_cl1,send_cl1nm,branch,seq,seq1,rs_no,step_date,rs_detail,apply_no,fees,step_grade,issue_no ";
        SQL += " order by send_cl,main_rs_no,seq,seq1,rs_no";
        conn.DataTable(SQL, dtRpt);

        for (int i = 0; i < dtRpt.Rows.Count; i++) {
            DataRow dr = dtRpt.Rows[i];
            branchname = Sys.getCodeName(conn, "sysctrl.dbo.branch_code", "branchname", "where branch='" + dr["Branch"] + "'");

            //案號
            dr["fseq"] = Sys.formatSeq1(dr.SafeRead("seq", ""), dr.SafeRead("seq1", ""), "", dr.SafeRead("Branch", ""), Sys.GetSession("dept"));
        }

        DataTable dtSendCL = dtRpt.DefaultView.ToTable(true, new string[] { "branch", "send_cl", "send_clnm" });
        clRepeater.DataSource = dtSendCL;
        clRepeater.DataBind();
    }

    protected void clRepeater_ItemDataBound(object sender, RepeaterItemEventArgs e) {
        if (e.Item.ItemIndex == 0) {//因pagebind&repeater bind會讓repaeter觸發綁定2次.所以第一筆時總計要重算
            totcnt = 0;
            tot_subcount = 0;
            totfees = 0;
        }
        countnum = 0;
        subcount = 0;
        fees = 0;
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
                string send_cl = ((DataRowView)e.Item.DataItem).Row["send_cl"].ToString();
                //DataTable dtDtl = dtRpt.Select("branch='" + branch + "' and send_cl='" + send_cl + "'").CopyToDataTable();
                var rows = dtRpt.Select("branch='" + branch + "' and send_cl='" + send_cl + "'");
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

            if (((DataRowView)e.Item.DataItem).Row["rs_no"].ToString() != ((DataRowView)e.Item.DataItem).Row["main_rs_no"].ToString()) {
                subcount += 1;//小計併案件數
                tot_subcount += 1;//總計併案件數
            }
            
            if (((DataRowView)e.Item.DataItem).Row["sendmark"].ToString() == "正本") {
                fees += Convert.ToInt32(((DataRowView)e.Item.DataItem).Row["fees"].ToString());//小計規費
                totfees += Convert.ToInt32(((DataRowView)e.Item.DataItem).Row["fees"].ToString());//總計規費
            }
        }
    }

    //規費
    protected string GetFees(object oItem) {
        if (Eval("sendmark").ToString() == "正本")
            return Eval("fees").ToString();
        else
            return "&nbsp;";
    }

    //收據抬頭
    protected string GetRectitle(object oItem) {
        string send_way = Eval("send_way").ToString();
        string receipt_type = Eval("receipt_type").ToString();
        string receipt_title = Eval("receipt_title").ToString().Trim();

        //20180725 增加收據抬頭
        if (Convert.ToInt32(Eval("fees")) == 0) {//20191118 增加無規費不顯示收據種類
            return "";
        } else {
            if (send_way == "E" || send_way == "EA") {
                if (receipt_type == "E") {
                    return "電子收據(" + receipt_title + ")";
                } else {
                    return "紙本收據(" + receipt_title + ")";
                }
            } else {
                if (receipt_title != "") {
                    return "紙本收據(" + receipt_title + ")";
                } else {
                    return "紙本收據";
                }
            }
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
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/jquery.Snoopy.date.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/jquery.irene.form.js")%>"></script>
</head>

<body>
    <table border="0" width="100%" cellspacing="1" cellpadding="0" align="center">
	    <tr>
            <td width="100%" style="font-size:20px" colspan="3" align=center><%#branchname%><%#HTProgCap%></td>
	    </tr>
	    <tr style="font-size:12pt">
		    <td width="20%" align=left></td>
		    <td width="60%" align=center>發文日期：<%#Request["sdate"]%>～<%#Request["edate"]%></td>
		    <td width="20%" align=right><a href="javascript:window.print();void(0);">列印</a>日期：<%#DateTime.Today.ToShortDateString()%></td>
	    </tr>
    </table>

	<asp:Repeater id="clRepeater" runat="server" OnItemDataBound="clRepeater_ItemDataBound" Visible='<%#bool.Parse((clRepeater.Items.Count>0).ToString())%>'>
    <HeaderTemplate>
        <table border="0" class="bluetable" cellspacing="1" cellpadding="2" width="100%">	
			<tr align="center" height="20" class="lightbluetable" style="font-size:12pt">
				<td nowrap>本所編號</td>
				<td>發文內容</td>
				<td nowrap>正副本</td>
				<td nowrap>發文日期</td>
				<td nowrap>發文字號<%if(Request["send_way"]=="E" || Request["send_way"]=="EA") Response.Write("(進度)");%></td>
				<td nowrap>申請案號</td>
				<td nowrap>註冊號</td>
				<td nowrap>規費</td>
				<td nowrap>收據種類</td>
			</tr>
    </HeaderTemplate>
	<ItemTemplate>
			<tr class="lightbluetable3" style="font-size:12pt">
				<td colspan=9>&nbsp;<b>發文對象：<%#Eval("send_clnm")%></b>&nbsp;</td>
			</tr>
	        <asp:Repeater id="dtlRepeater" runat="server" OnItemDataBound="dtlRepeater_ItemDataBound">
	        <ItemTemplate>
		        <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>">
			        <td nowrap align="center"><%#Eval("fseq")%></td>
			        <td>&nbsp;<%#Eval("rs_detail")%></td>
			        <td nowrap align="center"><%#Eval("sendmark")%></td>
			        <td nowrap align="center"><%#Eval("step_date","{0:yyyy/M/d}")%></td>
			        <td nowrap align="center">
                        <%#(Eval("rs_no").ToString()!=Eval("main_rs_no").ToString()?"*":"")%><%#Eval("rs_no")%>
                        <%if(Request["send_way"]=="E" || Request["send_way"]=="EA") Response.Write("(&nbsp;"+Eval("step_grade")+")");%>
			        </td>
			        <td nowrap align="center">&nbsp;<%#Eval("apply_no")%></td>
			        <td nowrap align="center">&nbsp;<%#Eval("issue_no")%></td>
			        <td nowrap align="center"><%#GetFees(Container.DataItem)%></td>
			        <td nowrap align="center"><%#GetRectitle(Container.DataItem)%></td>
		        </tr>
            </ItemTemplate>
            <FooterTemplate>
				<tr class="lightbluetable" style="font-size:12pt;color:DarkBlue">
					<td colspan=4>　小　　計：　　<%#countnum%>件
                        <%#(subcount>0?"( " + (countnum - subcount) + " 件公文 + " + subcount + " 件併案處理 )":"")%>
					</td>
					<td colspan=5 align=right>規　費：<%#fees%></td>
				</tr>
            </FooterTemplate>
            </asp:Repeater>
    </ItemTemplate>
    <FooterTemplate>
            <tr class="lightbluetable" style="font-size:12pt;color:DarkBlue">
                <td colspan=4>　總　　計：　　<%#totcnt%>件
                    <%#(tot_subcount>0?"( " + (totcnt - tot_subcount) + " 件公文 + " + tot_subcount + " 件併案處理 )":"")%>
                </td>
                <td colspan=5 align=right>規　費：<%#totfees%></td>
            </tr>
        </table>
        <%if(tot_subcount > 0){%>
	    <br>
	    <font color="darkblue" size="2" >發文字號有 * 表示該筆資料為併案處理之子案件</font>
	    <br>
        <%}%>
    </FooterTemplate>
    </asp:Repeater>

    <asp:Label ID="lblEmpty" runat="server" Visible='<%#bool.Parse((clRepeater.Items.Count==0).ToString())%>'>
        <div align="center"><font color="red" size=2>=== 查無資料===</font></div>
    </asp:Label> 
    <BR>
</body>
</html>
