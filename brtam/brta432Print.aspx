<%@ Page Language="C#" %>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Data.SqlClient" %>
<%@ Import Namespace = "System.IO"%>
<%@ Import Namespace = "System.Linq"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<script runat="server">
    protected string HTProgCap = HttpContext.Current.Request["prgname"] ?? "商標案件狀態明細表";//功能名稱
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

    protected int subcnt = 0;//小計件數
    protected int totcnt = 0;//總計件數

    protected void PageLayout() {
        branchname = Sys.getCodeName(conn, "sysctrl.dbo.branch_code", "branchname", "where branch='" + Session["seBranch"] + "'");

        string wSQL = "";
        if ((Request["isdate"] ?? "") != "") wSQL += " and in_date>='" + Request["isdate"] + "'";
        if ((Request["iedate"] ?? "") != "") wSQL += " and in_date<='" + Request["iedate"] + "'";
        if ((Request["esdate"] ?? "") != "") wSQL += " and end_date>='" + Request["esdate"] + "'";
        if ((Request["eedate"] ?? "") != "") wSQL += " and end_date<='" + Request["eedate"] + "'";
        if ((Request["sseq"] ?? "") != "") wSQL += " and seq>=" + Request["sseq"];
        if ((Request["eseq"] ?? "") != "") wSQL += " and seq<=" + Request["eseq"];
        if ((Request["seq1"] ?? "") != "") wSQL += " and seq1='" + Request["seq1"] + "'";
        if ((Request["scode1"] ?? "") != "") wSQL += " and scode='" + Request["scode1"] + "'";
        if ((Request["cust_area"] ?? "") != "") wSQL += " and cust_area='" + Request["cust_area"] + "'";
        if ((Request["scust_seq"] ?? "") != "") wSQL += " and cust_seq>=" + Request["scust_seq"];
        if ((Request["ecust_seq"] ?? "") != "") wSQL += " and cust_seq<=" + Request["ecust_seq"];

        SQL = "select cust_area,cust_seq,seq,seq1,in_date,apply_no,apply_date,issue_no,issue_date,term1,term2,end_date";
        SQL+= ",appl_name,(select rtrim(isnull(ap_cname1,''))+rtrim(isnull(ap_cname2,'')) from apcust where cust_area=a.cust_area and cust_seq=a.cust_seq) as cust_name";
        SQL+= ",(select code_name from cust_code where code_type = 'ENDCODE' and cust_code = a.end_code) as end_name ";
        SQL+= ",(select sc_name from sysctrl.dbo.scode where scode = a.scode ) as scode_nm " ;
        SQL+= ",''fseq,''lrs_detail " ;
        SQL+= " from dmt a where 1=1";
        SQL += wSQL;
        if ((Request["sort1"] ?? "") == "sort_cust") {
            SQL += " order by cust_area,cust_seq,seq,seq1";
        } else {
            SQL += " order by seq,seq1";
        }
        conn.DataTable(SQL, dtRpt);

        for (int i = 0; i < dtRpt.Rows.Count; i++) {
            DataRow dr = dtRpt.Rows[i];
            
            //案號
            dr["fseq"] = Sys.formatSeq1(dr.SafeRead("seq", ""), dr.SafeRead("seq1", ""), "", dr.SafeRead("cust_area", ""), Sys.GetSession("dept"));
            
            //最後進度 取得最後一筆進度之收發文內容
            SQL = "select rs_detail from step_dmt where seq = " +dr["seq"]+ " and seq1 = '" +dr["seq1"]+ "' order by step_grade desc";
            object objResult1 = conn.ExecuteScalar(SQL);
            dr["lrs_detail"] = (objResult1 == DBNull.Value || objResult1 == null ? "" : objResult1.ToString());
        }

        if ((Request["sort1"] ?? "") == "sort_cust") {
            DataTable dtCust = dtRpt.DefaultView.ToTable(true, new string[] { "cust_area", "cust_seq", "cust_name" });
            custRepeater.DataSource = dtCust;
            custRepeater.DataBind();
            dtlRepeater.Visible = false;//依本所編號隱藏
        } else {
            dtlRepeater.DataSource = dtRpt;
            dtlRepeater.DataBind();
            custRepeater.Visible = false;//依客戶隱藏
        }
    }

    protected void dtlRepeater_ItemDataBound(object sender, RepeaterItemEventArgs e) {
        if (e.Item.ItemIndex == 0) {//因pagebind&repeater bind會讓repaeter觸發綁定2次.所以第一筆時總計要重算
            totcnt = 0;
        }

        if ((e.Item.ItemType == ListItemType.Item) || (e.Item.ItemType == ListItemType.AlternatingItem)) {
            totcnt += 1;//總計件數
        }
    }
    ///////////////////////////////////////////////////
    protected void custRepeater_ItemDataBound(object sender, RepeaterItemEventArgs e) {
        if (e.Item.ItemIndex == 0) {//因pagebind&repeater bind會讓repaeter觸發綁定2次.所以第一筆時總計要重算
            totcnt = 0;
        }

        if ((e.Item.ItemType == ListItemType.Item) || (e.Item.ItemType == ListItemType.AlternatingItem)) {
            Repeater dtl0Rpt = (Repeater)e.Item.FindControl("dtl0Repeater");

            if ((dtl0Rpt != null)) {
                string cust_area = DataBinder.Eval(e.Item.DataItem, "cust_area").ToString();
                string cust_seq = DataBinder.Eval(e.Item.DataItem, "cust_seq").ToString();

                var rows = dtRpt.Select("cust_area='" + cust_area + "' and cust_seq='" + cust_seq + "'");
                var dtDtl = rows.Any() ? rows.CopyToDataTable() : dtRpt.Clone();
                dtl0Rpt.DataSource = dtDtl;
                dtl0Rpt.DataBind();
            }
        }
    }

    protected void dtl0Repeater_ItemDataBound(object sender, RepeaterItemEventArgs e) {
        if (e.Item.ItemIndex == 0) {//因pagebind&repeater bind會讓repaeter觸發綁定2次.所以第一筆時總計要重算
            subcnt = 0;
        }
        
        if ((e.Item.ItemType == ListItemType.Item) || (e.Item.ItemType == ListItemType.AlternatingItem)) {
            subcnt += 1;//小計件數
            totcnt += 1;//總計件數
        }
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title><%=HTProgCap%></title>
<uc1:head_inc_form runat="server" ID="head_inc_form" />
</head>

<body onload="window.focus();">
    <table border="0" width="100%" cellspacing="1" cellpadding="0" align="center">
	    <tr>
            <td width="100%" style="font-size:20px" colspan="3" align=center><%#branchname%><%#HTProgCap%></td>
	    </tr>
	    <tr style="font-size:12pt">
             <td width="25%"></td>
		     <td width="50%" align=center>立案期間：<%#Request["isdate"]%>～<%#Request["iedate"]%></td>
		    <td width="25%" align=right><a href="javascript:window.print();void(0);">列印</a>日期：<%#DateTime.Today.ToShortDateString()%></td>
	    </tr>
    </table>

    <asp:Repeater id="custRepeater" runat="server" OnItemDataBound="custRepeater_ItemDataBound" Visible='<%#bool.Parse((custRepeater.Items.Count>0).ToString())%>'>
    <HeaderTemplate>
        <table border="0" class="bluetable" cellspacing="1" cellpadding="2" width="100%">	
			<tr align="center" height="20" class="lightbluetable" style="font-size:12pt">
			    <td nowrap>本所編號</td>
			    <td nowrap>立案日期</td>
			    <td nowrap>申請號</td>
			    <td nowrap>申請日期</td>
			    <td nowrap>註冊號</td>
			    <td nowrap>註冊日期</td>
			    <td nowrap>專用期限</td>
			</tr>
    </HeaderTemplate>
	<ItemTemplate>
			<tr class="lightbluetable3">
			    <td colspan=7>&nbsp;<b>客戶名稱：<%#Eval("cust_area")%><%#Eval("cust_seq")%><%#Eval("cust_name")%></b></td>
			</tr>
	        <asp:Repeater id="dtl0Repeater" runat="server" OnItemDataBound="dtl0Repeater_ItemDataBound">
	        <ItemTemplate>
		        <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>">
				    <td nowrap align="center" rowspan=4><%#Eval("fseq")%></td>
				    <td nowrap align="center">&nbsp;<%#Eval("in_date","{0:d}")%></td>
				    <td nowrap align="center">&nbsp;<%#Eval("apply_no")%></td>
				    <td nowrap align="center">&nbsp;<%#Eval("apply_date","{0:d}")%></td>
				    <td nowrap align="center">&nbsp;<%#Eval("issue_no")%></td>
				    <td nowrap align="center">&nbsp;<%#Eval("issue_date","{0:d}")%></td>
				    <td nowrap align="center">&nbsp;<%#Eval("term1","{0:d}")%>~<%#Eval("term2","{0:d}")%></td>
			    </tr>
		        <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>">
				    <td align="right">營洽：</td>
				    <td nowrap align="center">&nbsp;<%#Eval("scode_nm")%></td>
				    <td nowrap align="right">結案日期：</td>
				    <td nowrap align="center">&nbsp;<%#Eval("end_date","{0:d}")%><br><%#Eval("end_name")%></td>
				    <td align="right">最後進度：</td>
				    <td align="left">&nbsp;<%#Eval("lrs_detail")%></td>
			    </tr>
		        <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>">
				    <td align="right">商標名稱：</td>
				    <td colspan=5>&nbsp;<%#Eval("appl_name")%></td>
			    </tr>
		        <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>">
				    <td align="right">客戶名稱：</td>
				    <td align="left" colspan=5>&nbsp;<%#Eval("cust_area")%><%#Eval("cust_seq")%><%#Eval("cust_name")%></td>
			    </tr>
            </ItemTemplate>
            <FooterTemplate>
		        <tr class="lightbluetable" style="font-size:12pt;color:DarkBlue">
			        <td colspan=7>　小計件數：　　<%#subcnt%>件</td>
		        </tr>
            </FooterTemplate>
            </asp:Repeater>
  </ItemTemplate>
    <FooterTemplate>
		    <tr class="lightbluetable" style="font-size:12pt;color:DarkBlue">
			    <td colspan=7>　總計件數：　　<%#totcnt%>件</td>
		    </tr>
        </table>
    </FooterTemplate>
    </asp:Repeater>


	<asp:Repeater id="dtlRepeater" runat="server" OnItemDataBound="dtlRepeater_ItemDataBound" Visible='<%#bool.Parse((dtlRepeater.Items.Count>0).ToString())%>'>
    <HeaderTemplate>
        <table border="0" class="bluetable" cellspacing="1" cellpadding="2" width="100%">	
			<tr align="center" height="20" class="lightbluetable" style="font-size:12pt">
			    <td nowrap>本所編號</td>
			    <td nowrap>立案日期</td>
			    <td nowrap>申請號</td>
			    <td nowrap>申請日期</td>
			    <td nowrap>註冊號</td>
			    <td nowrap>註冊日期</td>
			    <td nowrap>專用期限</td>
			</tr>
    </HeaderTemplate>
	<ItemTemplate>
		    <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>">
				<td nowrap align="center" rowspan=4><%#Eval("fseq")%></td>
				<td nowrap align="center">&nbsp;<%#Eval("in_date","{0:d}")%></td>
				<td nowrap align="center">&nbsp;<%#Eval("apply_no")%></td>
				<td nowrap align="center">&nbsp;<%#Eval("apply_date","{0:d}")%></td>
				<td nowrap align="center">&nbsp;<%#Eval("issue_no")%></td>
				<td nowrap align="center">&nbsp;<%#Eval("issue_date","{0:d}")%></td>
				<td nowrap align="center">&nbsp;<%#Eval("term1","{0:d}")%>~<%#Eval("term2","{0:d}")%></td>
			</tr>
		    <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>">
				<td align="right">營洽：</td>
				<td nowrap align="center">&nbsp;<%#Eval("scode_nm")%></td>
				<td nowrap align="right">結案日期：</td>
				<td nowrap align="center">&nbsp;<%#Eval("end_date","{0:d}")%><br><%#Eval("end_name")%></td>
				<td align="right">最後進度：</td>
				<td align="left">&nbsp;<%#Eval("lrs_detail")%></td>
			</tr>
		    <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>">
				<td align="right">商標名稱：</td>
				<td colspan=5>&nbsp;<%#Eval("appl_name")%></td>
			</tr>
		    <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>">
				<td align="right">客戶名稱：</td>
				<td align="left" colspan=5>&nbsp;<%#Eval("cust_area")%><%#Eval("cust_seq")%><%#Eval("cust_name")%></td>
			</tr>
    </ItemTemplate>
    <FooterTemplate>
		    <tr class="lightbluetable" style="font-size:12pt;color:DarkBlue">
			    <td colspan=7>　總計件數：　　<%#totcnt%>件</td>
		    </tr>
        </table>
    </FooterTemplate>
    </asp:Repeater>

    <asp:Label ID="lblEmpty" runat="server" Visible='<%#bool.Parse((dtRpt.Rows.Count==0).ToString())%>'>
        <div align="center"><font color="red" size=2>=== 查無資料===</font></div>
    </asp:Label> 
    <BR>
</body>
</html>
