<%@ Page Language="C#" %>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Data.SqlClient" %>
<%@ Import Namespace = "System.IO"%>
<%@ Import Namespace = "System.Linq"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<script runat="server">
    protected string HTProgCap = HttpContext.Current.Request["prgname"] ?? "商標官方收文明細表";//功能名稱
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

    protected int cnt = 0;//小計件數
    protected int subcnt = 0;//合計件數
    protected int totcnt = 0;//總計件數

    protected void PageLayout() {
        string wSQL = "";
        if ((Request["sdate"] ?? "") != "") wSQL += " and step_date>='" + Request["sdate"] + "'";
        if ((Request["edate"] ?? "") != "") wSQL += " and step_date<='" + Request["edate"] + "'";
        if ((Request["srs_no"] ?? "") != "") wSQL += " and rs_no>='" + Request["srs_no"] + "'";
        if ((Request["ers_no"] ?? "") != "") wSQL += " and rs_no<='" + Request["ers_no"] + "'";
        if ((Request["sseq"] ?? "") != "") wSQL += " and seq>=" + Request["sseq"];
        if ((Request["eseq"] ?? "") != "") wSQL += " and seq<=" + Request["eseq"];
        if ((Request["seq1"] ?? "") != "") wSQL += " and seq1='" + Request["seq1"] + "'";
        if ((Request["scust_seq"] ?? "") != "") wSQL += " and cust_seq>=" + Request["scust_seq"];
        if ((Request["ecust_seq"] ?? "") != "") wSQL += " and cust_seq<=" + Request["ecust_seq"];
        if ((Request["hreceive_way"] ?? "") != "") {
            if ((Request["hreceive_way"] ?? "").IndexOf(",") > -1) {
                wSQL += " and (receive_way not in ('" + Request["hreceive_way"].Replace(",", "','") + "') or receive_way is null) ";
            } else {
                wSQL += " and receive_way ='" + Request["hreceive_way"] + "'";
            }
        }

        SQL = "select distinct step_date,(case receive_way when 'R5' then 'R5' when 'R9' then 'R9' else 'R1' end) as rway,branch,seq,seq1,rs_no,rs_detail,class,class_count,cust_area,cust_seq";
        SQL += ",dmt_scode,(select sc_name from sysctrl.dbo.scode where scode=a.dmt_scode) as sc_name";
        SQL += ",''fseq,''rway_name,''ctrl_date ";
        SQL += " from vstep_dmt a where branch='" + Session["seBranch"] + "' and cg='G' and rs='R'";
        SQL += wSQL;
        SQL += " order by step_date,rway,branch,seq,seq1,rs_no";
        conn.DataTable(SQL, dtRpt);

        for (int i = 0; i < dtRpt.Rows.Count; i++) {
            DataRow dr = dtRpt.Rows[i];
            branchname = Sys.getCodeName(conn, "sysctrl.dbo.branch_code", "branchname", "where branch='" + dr["Branch"] + "'");

            //案號
            dr["fseq"] = Sys.formatSeq1(dr.SafeRead("seq", ""), dr.SafeRead("seq1", ""), "", dr.SafeRead("Branch", ""), Sys.GetSession("dept"));

            //來文方式
            switch (dr.SafeRead("rway", "")) {
                case "R5": dr["rway_name"] = "電子收文"; break;
                case "R9": dr["rway_name"] = "電子公文"; break;
                default: dr["rway_name"] = "紙本收文"; break;
            }

            //法定期限
            string ctrl_date = "";
            SQL = "select ctrl_date from ctrl_dmt where rs_no='" + dr["rs_no"] + "' and ctrl_type='A1' order by ctrl_date";
            using (SqlDataReader dr0 = conn.ExecuteReader(SQL)) {
                while (dr0.Read()) {
                    ctrl_date += "<br>" + dr0.GetDateTimeString("ctrl_date", "yyyy/M/d");
                }
            }
            dr["ctrl_date"] = (ctrl_date != "" ? ctrl_date.Substring(4) : "");
        }

        DataTable dtDate = dtRpt.DefaultView.ToTable(true, new string[] { "branch", "step_date" });
        dateRepeater.DataSource = dtDate;
        dateRepeater.DataBind();
    }

    protected void dateRepeater_ItemDataBound(object sender, RepeaterItemEventArgs e) {
        if (e.Item.ItemIndex == 0) {//因pagebind&repeater bind會讓repaeter觸發綁定2次.所以第一筆時總計要重算
            totcnt = 0;
        }
        if ((e.Item.ItemType == ListItemType.Item) || (e.Item.ItemType == ListItemType.AlternatingItem)) {
            Repeater rwayRpt = (Repeater)e.Item.FindControl("rwayRepeater");

            if ((rwayRpt != null)) {
                string branch = DataBinder.Eval(e.Item.DataItem, "branch").ToString();
                string step_date = DataBinder.Eval(e.Item.DataItem, "step_date", "{0:d}");
                DataTable dtCL = dtRpt.Select("branch='" + branch + "' and step_date='" + step_date + "'").CopyToDataTable().DefaultView.ToTable(true, new string[] { "branch", "step_date", "rway", "rway_name" });
                rwayRpt.DataSource = dtCL;
                rwayRpt.DataBind();
            }
        }
    }

    protected void rwayRepeater_ItemDataBound(object sender, RepeaterItemEventArgs e) {
        if (e.Item.ItemIndex == 0) {//因pagebind&repeater bind會讓repaeter觸發綁定2次.所以第一筆時總計要重算
            subcnt = 0;
        }

        Repeater dtlRpt = (Repeater)e.Item.FindControl("dtlRepeater");
        if ((dtlRpt != null)) {
            string branch = DataBinder.Eval(e.Item.DataItem, "branch").ToString();
            string step_date = DataBinder.Eval(e.Item.DataItem, "step_date", "{0:d}");
            string rway = DataBinder.Eval(e.Item.DataItem, "rway").ToString();

            //DataTable dtDtl = dtRpt.Select("branch='" + branch + "' and step_date='" + step_date + "' and rway='" + rway + "'").CopyToDataTable();
            var rows = dtRpt.Select("branch='" + branch + "' and step_date='" + step_date + "' and rway='" + rway + "'");
            var dtDtl = rows.Any() ? rows.CopyToDataTable() : dtRpt.Clone();
            dtlRpt.DataSource = dtDtl;
            dtlRpt.DataBind();
        }
    }

    protected void dtlRepeater_ItemDataBound(object sender, RepeaterItemEventArgs e) {
        if (e.Item.ItemIndex == 0) {//因pagebind&repeater bind會讓repaeter觸發綁定2次.所以第一筆時總計要重算
            cnt = 0;
        }

        if ((e.Item.ItemType == ListItemType.Item) || (e.Item.ItemType == ListItemType.AlternatingItem)) {
            cnt += 1;//小計件數
            subcnt += 1;//合計件數
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

<body>
    <table border="0" width="100%" cellspacing="1" cellpadding="0" align="center">
	    <tr>
            <td width="100%" style="font-size:20px" colspan="3" align=center><%#branchname%><%#HTProgCap%></td>
	    </tr>
	    <tr style="font-size:12pt">
		    <td width="20%" align=left></td>
		    <td width="60%" align=center>收文日期：<%#Request["sdate"]%>～<%#Request["edate"]%></td>
		    <td width="20%" align=right><a href="javascript:window.print();void(0);">列印</a>日期：<%#DateTime.Today.ToShortDateString()%></td>
	    </tr>
    </table>

	<asp:Repeater id="dateRepeater" runat="server" OnItemDataBound="dateRepeater_ItemDataBound" Visible='<%#bool.Parse((dateRepeater.Items.Count>0).ToString())%>'>
    <HeaderTemplate>
        <table border="0" class="bluetable" cellspacing="1" cellpadding="2" width="100%">	
            <tr align="center" height="20" class="lightbluetable" style="font-size:12pt">
		        <td nowrap>本所編號</td>
		        <td nowrap>類別</td>
		        <td nowrap>客戶</td>
		        <td>收文內容</td>
		        <td nowrap>法定期限</td>
		        <td nowrap>營洽</td>
	        </tr>
    </HeaderTemplate>
	<ItemTemplate>
			<tr class="lightbluetable3">
				<td colspan=9 style="font-size:12pt">&nbsp;<b>收文日期：<%#Eval("step_date","{0:d}")%></b>&nbsp;</td>
			</tr>
	        <asp:Repeater id="rwayRepeater" runat="server" OnItemDataBound="rwayRepeater_ItemDataBound">
	        <ItemTemplate>
	            <tr class="lightbluetable3" style="font-size:10pt">
		            <td colspan=6>&nbsp;<b>來文方式：<%#Eval("rway_name")%></b></td>
	            </tr>
	            <asp:Repeater id="dtlRepeater" runat="server" OnItemDataBound="dtlRepeater_ItemDataBound">
	            <ItemTemplate>
		        <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>">
			            <td nowrap align="center"><%#Eval("fseq")%></td>
                        <td align="center">共<%#Eval("class_count")%>類-<%#Eval("class")%></td>
                        <td nowrap align="center"><%#Eval("cust_area")%><%#Eval("cust_seq")%></td>
                        <td>&nbsp;<%#Eval("rs_detail")%></td>
			            <td nowrap align="center">&nbsp;<%#Eval("ctrl_date")%></td>
			            <td nowrap align="center">&nbsp;<%#Eval("sc_name")%></td>
	                </tr>
                </ItemTemplate>
                <FooterTemplate>
				    <tr class="sfont9" style="font-size:12pt;color:DarkBlue">
					    <td colspan=6>　小　　計：　　<%#cnt%>件
					    </td>
				    </tr>
                </FooterTemplate>
                </asp:Repeater>
            </ItemTemplate>
            <FooterTemplate>
				<tr class="sfont9" style="font-size:12pt;color:DarkBlue">
					<td colspan=6>　合　　計：　　<%#subcnt%>件
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

    <asp:Label ID="lblEmpty" runat="server" Visible='<%#bool.Parse((dateRepeater.Items.Count==0).ToString())%>'>
        <div align="center"><font color="red" size=2>=== 查無資料===</font></div>
    </asp:Label> 
    <BR>
</body>
</html>
