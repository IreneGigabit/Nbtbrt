<%@ Page Language="C#" %>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Data.SqlClient" %>
<%@ Import Namespace = "System.IO"%>
<%@ Import Namespace = "System.Linq"%>
<%@ Import Namespace = "System.Collections.Generic"%>

<script runat="server">
    protected string HTProgCap = HttpContext.Current.Request["prgname"] ?? "商標官方發文規費明細表";//功能名稱
    protected string HTProgPrefix = HttpContext.Current.Request["prgid"] ?? "";//程式檔名前綴
    protected string HTProgCode = "brta5m";//HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = HttpContext.Current.Request["prgid"] ?? "";//程式代碼
    protected int HTProgRight = 0;
    protected string SQL = "";
    
    protected StringBuilder strOut = new StringBuilder();
    DataTable dtRpt = new DataTable();//明細

    protected string branchname = "";
    protected string mp_date = "";
    
    DBHelper conn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    private void Page_Unload(System.Object sender, System.EventArgs e) {
        if (conn != null) conn.Dispose();
    }

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "Private";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;
        Response.Clear();

        conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");

        if (Request["send_way"] == "E") HTProgCap += "(電子送件)";
        if (Request["send_way"] == "EA") HTProgCap += "(註冊費電子送件)";

        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        //HTProgCap = myToken.Title;
        if (HTProgRight >= 0) {
            PageLayout();
            this.Page.DataBind();
        }
    }

    protected int countnum = 0;//小計件數
    protected int fees = 0;//小計規費
    protected int service = 0;//小計服務費

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
        if ((Request["qrysend_dept"] ?? "") != "") wSQL += " and opt_Branch='" + Request["qrysend_dept"] + "'";
        if ((Request["send_way"] ?? "") != "") {
            if ((Request["send_way"] ?? "") == "E" || (Request["send_way"] ?? "") == "EA") {
                wSQL += " and send_way='" + Request["send_way"] + "'";
            } else {
                wSQL += "  and isnull(send_way,'') not in('E','EA') ";
            }
        }

        SQL = "select distinct send_cl,send_clnm,branch,seq,seq1,cust_area,cust_seq,ap_cname1,ap_cname2,rs_no,step_date,rs_code,rs_detail,mp_date ";
        SQL += ",fees,dmt_scode,cappl_name,case_no,(select sc_name from sysctrl.dbo.scode where scode=a.dmt_scode) as sc_name ";
        SQL += ",(select ar_mark from case_dmt where case_no=a.case_no) as ar_mark ";
        SQL += ",''fseq,''cust_name,0 service1,''case_no1";
        SQL += " from vstep_dmt a where branch='" + Session["seBranch"] + "' and cg='G' and rs='S'";
        SQL += wSQL + " and fees>0";
        SQL += " and left(rs_no,1)='G' ";//2006/5/27配合爭救案系統不列印爭救案發文資料,爭救案發文字號第一碼為B
        SQL += " order by send_cl,seq,seq1,rs_no";
        conn.DataTable(SQL, dtRpt);

        for (int i = 0; i < dtRpt.Rows.Count; i++) {
            DataRow dr = dtRpt.Rows[i];
            using (DBHelper cnn = new DBHelper(Conn.Sysctrl).Debug(Request["chkTest"] == "TEST")) {
                SQL = "select branchname from branch_code where branch='" + dr["Branch"] + "'";
                object objResult = cnn.ExecuteScalar(SQL);
                branchname = (objResult == DBNull.Value || objResult == null ? "" : objResult.ToString());
            }
            //總收發文日
            if (Request["sdate"].ToString() == Request["edate"].ToString()) {
                if (dr.SafeRead("mp_date", "") != "") {
                    mp_date = "總發文日期：" + dr.GetDateTimeString("mp_date", "yyyy/M/d");
                }
            }

            //案號
            dr["fseq"] = Sys.formatSeq1(dr.SafeRead("seq", ""), dr.SafeRead("seq1", ""), "", dr.SafeRead("Branch", ""), Sys.GetSession("dept"));

            SQL = "Select RTRIM(ISNULL(ap_cname1, '')) + RTRIM(ISNULL(ap_cname2, ''))  as cust_name from apcust as c ";
            SQL += " where c.cust_area='" + dr["cust_area"] + "' and c.cust_seq='" + dr["cust_seq"] + "'";
            using (SqlDataReader dr1 = conn.ExecuteReader(SQL)) {
                if (dr1.Read()) {
                    dr["cust_name"] = dr1.SafeRead("cust_name", "");
                }
            }

            //交辦單號
            string case_no1 = "";
            SQL = "select case_no from fees_dmt where rs_no='" + dr["rs_no"] + "' ";
            using (SqlDataReader dr1 = conn.ExecuteReader(SQL)) {
                while (dr1.Read()) {
                    case_no1 +="<BR>"+dr1.SafeRead("case_no", "");
                }
            }
            case_no1 = (case_no1 != "" ? case_no1.Substring(4) : "");
            dr["case_no1"] = case_no1;
                
            int service1 = 0;
            SQL = "select isnull(service,0)+isnull(add_service,0) service from case_dmt where case_no in(select case_no from fees_dmt where rs_no='" + dr["rs_no"] + "') ";
            using (SqlDataReader dr1 = conn.ExecuteReader(SQL)) {
                while (dr1.Read()) {
                    service1 += Convert.ToInt32(dr1.SafeRead("service", "0"));
                }
            }
            dr["service1"] = service1;
        }

        DataTable dtSendCL = dtRpt.DefaultView.ToTable(true, new string[] { "branch", "send_cl", "send_clnm" });
        clRepeater.DataSource = dtSendCL;
        clRepeater.DataBind();
    }

    protected void clRepeater_ItemDataBound(object sender, RepeaterItemEventArgs e) {
        countnum = 0;
        fees = 0;
        service = 0;

        if ((e.Item.ItemType == ListItemType.Item) || (e.Item.ItemType == ListItemType.AlternatingItem)) {
            Repeater dtlRpt = (Repeater)e.Item.FindControl("dtlRepeater");
            if ((dtlRpt != null)) {
                string branch = ((DataRowView)e.Item.DataItem).Row["branch"].ToString();
                string send_cl = ((DataRowView)e.Item.DataItem).Row["send_cl"].ToString();
                
                DataTable dtlDtl = dtRpt.Select("branch='" + branch + "' and send_cl='" + send_cl + "'").CopyToDataTable();
                dtlRpt.DataSource = dtlDtl;
                dtlRpt.DataBind();
            }
        }
    }

    protected void dtlRepeater_ItemDataBound(object sender, RepeaterItemEventArgs e) {
        if ((e.Item.ItemType == ListItemType.Item) || (e.Item.ItemType == ListItemType.AlternatingItem)) {
            countnum += 1;
            fees += Convert.ToInt32(((DataRowView)e.Item.DataItem).Row["fees"].ToString());
            service += Convert.ToInt32(((DataRowView)e.Item.DataItem).Row["service1"].ToString());
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
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/jquery.datepick.min.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/jquery.datepick-zh-TW.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/toastr.min.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/util.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/jquery.Snoopy.date.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/jquery.irene.form.js")%>"></script>
</head>

<body>

    <asp:Label ID="lblEmpty" runat="server" Visible='<%#bool.Parse((clRepeater.Items.Count==0).ToString())%>'>
        <table border="0" width="100%" cellspacing="1" cellpadding="0" align="center">
		    <tr>
                <td width="100%" style="font-size:20px" colspan="3" align=center><%#branchname%><%#HTProgCap%></td>
		    </tr>
		    <tr style="font-size:12pt">
			    <td width="20%" align=left></td>
			    <td width="60%" align=center>發文日期：<%#Request["sdate"]%>～<%#Request["edate"]%>
                    <%#mp_date%>
			    </td>
			    <td width="20%" align=right><a href="javascript:window.print();void(0);">列印</a>日期：<%#DateTime.Today.ToShortDateString()%></td>
		    </tr>
        </table>
        <div align="center"><font color="red" size=2>=== 查無資料===</font></div>
    </asp:Label> 

	<asp:Repeater id="clRepeater" runat="server" OnItemDataBound="clRepeater_ItemDataBound">
	<ItemTemplate>
        <table border="0" width="100%" cellspacing="1" cellpadding="0" align="center">
		    <tr>
                <td width="100%" style="font-size:20px" colspan="3" align=center><%#branchname%><%#HTProgCap%></td>
		    </tr>
		    <tr style="font-size:12pt">
			    <td width="20%" align=left></td>
			    <td width="60%" align=center>發文日期：<%#Request["sdate"]%>～<%#Request["edate"]%>
                    <%#mp_date%>
			    </td>
			    <td width="20%" align=right><a href="javascript:window.print();void(0);">列印</a>日期：<%#DateTime.Today.ToShortDateString()%></td>
		    </tr>
        </table>

        <table border="0" class="bluetable" cellspacing="1" cellpadding="2" width="100%">	
		    <tr align="center" height="20" class="lightbluetable" style="font-size:12pt">
			    <td nowrap rowspan=2>本所編號</td>
			    <td>案件名稱</td>
			    <td colspan=4>發文內容</td>
		    </tr>
		    <tr align="center" height="20" class="lightbluetable" style="font-size:12pt">
			    <td nowrap>客戶名稱</td>
			    <td nowrap>交辦單號</td>
			    <td nowrap>服務費</td>
			    <td nowrap>規費</td>
			    <td nowrap>營洽</td>
		    </tr>
		    <tr class="lightbluetable3" style="font-size:12pt">
			    <td colspan=6>&nbsp;<b>對象：<%#Eval("send_clnm")%></b></td>
		    </tr>
	        <asp:Repeater id="dtlRepeater" runat="server" OnItemDataBound="dtlRepeater_ItemDataBound">
	        <ItemTemplate>
                <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>">
			        <td nowrap align="center" rowspan=2><%#Eval("fseq")%></td>
			        <td>&nbsp;<%#Eval("cappl_name")%></td>
			        <td colspan=4>&nbsp;<%#Eval("rs_code")%>-<%#Eval("rs_detail")%></td>
		        </tr>
                <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>">
			        <td>&nbsp;<%#Eval("cust_area")%><%#Eval("cust_seq").ToString().PadLeft(5,'0')%><%#Eval("cust_name")%></td>
			        <td align="center"><%#Eval("case_no1").ToString()!="" ?Eval("case_no1").ToString():"&nbsp;"%></td>
			        <td nowrap align="center">
                        <%#Eval("service1").ToString()!="" ?Eval("service1").ToString():"0"%>
                        <%#Eval("ar_mark").ToString()=="D" ?"(D)":""%>
			        </td>
			        <td nowrap align="center"><%#Eval("fees")%></td>
			        <td nowrap align="center"><%#Eval("sc_name").ToString()!="" ?Eval("sc_name").ToString():"&nbsp;"%></td>
		        </tr>
            </ItemTemplate>
            <FooterTemplate>
	            <tr class="lightbluetable" style="font-size:12pt;color:DarkBlue">
		            <td colspan=2>　小　　計：　　<%#countnum%>件</td>
		            <td colspan=2>服務費：<%#service%></td>
		            <td colspan=2>規　費：<%#fees%></td>
	            </tr>
            </table>
            </FooterTemplate>
           </asp:Repeater>
    </ItemTemplate>
    </asp:Repeater>
</body>
</html>
