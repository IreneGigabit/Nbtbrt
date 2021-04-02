<%@ Page Language="C#" %>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Data.SqlClient" %>
<%@ Import Namespace = "System.IO"%>
<%@ Import Namespace = "System.Linq"%>
<%@ Import Namespace = "System.Collections.Generic"%>

<script runat="server">
    protected string HTProgCap = HttpContext.Current.Request["prgname"] ?? "商標客戶收文明細表";//功能名稱
    protected string HTProgPrefix = "brta4m";//HttpContext.Current.Request["prgid"] ?? "";//程式檔名前綴
    protected string HTProgCode = "brta4m";//HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = HttpContext.Current.Request["prgid"] ?? "";//程式代碼
    protected int HTProgRight = 0;
    protected string SQL = "";
    
    protected StringBuilder strOut = new StringBuilder();
    DataTable dtRpt = new DataTable();//明細

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "Private";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;
        Response.Clear();

        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        if (HTProgRight >= 0) {
            PageLayout();
            this.Page.DataBind();
        }
    }

    protected string branch = "";//區所別
    protected string branchname = "";//區所別

    protected int countnum = 0;//總計件數
    protected int subcount = 0;//併案件數
    protected decimal tot_fees = 0;///總計規費
    protected decimal tot_service = 0;///總計服務費
    
    protected void PageLayout() {
        string wSQL = "";
        using (DBHelper conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST")) {
            if ((Request["sdate"] ?? "") != "") wSQL += " and step_date>='" + Request["sdate"] + "'";
            if ((Request["edate"] ?? "") != "") wSQL += " and step_date<='" + Request["edate"] + "'";
            if ((Request["srs_no"] ?? "") != "") wSQL += " and main_rs_no>='" + Request["srs_no"] + "'";
            if ((Request["ers_no"] ?? "") != "") wSQL += " and main_rs_no<='" + Request["ers_no"] + "'";

            branchname = Sys.getCodeName(conn, "sysctrl.dbo.branch_code", "branchname", "where branch='" + Session["seBranch"] + "'");
            
            SQL = "select branch,seq,seq1,rs_no,main_rs_no,rs_detail,step_date,cappl_name,ap_cname1,case_no,rs_code";
            SQL += ",dmt_scode,(select sc_name from sysctrl.dbo.scode where scode=a.dmt_scode) as sc_name";
            SQL += ",''fseq,'0' service,'0' fees";
            SQL+= " from vstep_dmt a where branch='"+Session["seBranch"]+"' and cg='C' and rs='R'";
            SQL+= wSQL;
            SQL += " order by step_date,branch,seq,seq1,rs_no";
            conn.DataTable(SQL, dtRpt);
            
            for (int i = 0; i < dtRpt.Rows.Count; i++) {
                countnum += 1;
                if (dtRpt.Rows[i].SafeRead("rs_no", "") != dtRpt.Rows[i].SafeRead("main_rs_no", "")) {
                    dtRpt.Rows[i]["fseq"]="*";
                    subcount+=1;
                }
                dtRpt.Rows[i]["fseq"] = dtRpt.Rows[i]["fseq"] + Sys.formatSeq1(dtRpt.Rows[i].SafeRead("seq", ""), dtRpt.Rows[i].SafeRead("seq1", ""), "", dtRpt.Rows[i].SafeRead("branch", ""), Sys.GetSession("dept"));

                if (dtRpt.Rows[i].SafeRead("case_no", "").Trim() != "" && dtRpt.Rows[i].SafeRead("rs_no", "") == dtRpt.Rows[i].SafeRead("main_rs_no", "")) {
                    SQL = "select service,fees from case_dmt where case_no='" + dtRpt.Rows[i]["case_no"] + "' ";
                    using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
                        if (dr.Read()) {
                            dtRpt.Rows[i]["service"] = dr.SafeRead("service", "0");
                            dtRpt.Rows[i]["fees"] = dr.SafeRead("fees", "0");
                        }
                    }
                }
                
                tot_service += Convert.ToDecimal(dtRpt.Rows[i].SafeRead("service", "0"));
                tot_fees += Convert.ToDecimal(dtRpt.Rows[i].SafeRead("fees", "0"));
            }
            
            rptRepeater.DataSource = dtRpt;
            rptRepeater.DataBind();
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
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/jquery.irene.form.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/client_chk.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/jquery.Snoopy.date.js")%>"></script>
</head>

<body>
<form id="reg" name="reg" method="post">
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
    <asp:Label ID="lblEmpty" runat="server" Visible='<%#bool.Parse((rptRepeater.Items.Count==0).ToString())%>'>
        <div align="center"><font color="red" size=2>=== 查無資料===</font></div>
    </asp:Label> 
	<asp:Repeater id="rptRepeater" runat="server" Visible='<%#bool.Parse((rptRepeater.Items.Count>0).ToString())%>'>
        <FooterTemplate>
        </FooterTemplate>
        <HeaderTemplate>
            <table border=1 width="100%" cellspacing="0" cellpadding="1">	
		        <tr align="center" height="20" class="lightbluetable" style="font-size:12pt">
		            <td nowrap>本所編號</td>
		            <td nowrap>收文日期</td>
		            <td>收文內容</td>
		            <td>案件名稱</td>
		            <td nowrap>服務費</td>
		            <td nowrap>規費</td>
		            <td nowrap>交辦單號</td>
		            <td nowrap>營洽</td>
		            <td>客戶名稱</td>
		        </tr>
        </HeaderTemplate>
	    <ItemTemplate>
                <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>">
			        <td nowrap align="center"><%#Eval("fseq")%></td>
			        <td nowrap align="center"><%#Eval("step_date","{0:yyyy/M/d}")%></td>
			        <td><%#Eval("rs_code")%><%#Eval("rs_detail")%></td><!--2015/4/13專案室要求，增加顯示收文代碼-->
			        <td align="left">&nbsp;<%#Eval("cappl_name")%></td>
			        <td nowrap align="center"><%#Eval("service")%>&nbsp;</td>
			        <td nowrap align="center"><%#Eval("fees")%>&nbsp;</td>
			        <td nowrap align="center"><%#Eval("case_no")%></td>
			        <td nowrap align="center"><%#Eval("sc_name")%></td>
			        <td align="left"><%#Eval("ap_cname1")%></td>
		        </tr>
    </ItemTemplate>
    <FooterTemplate>
                <tr class="lightbluetable" style="font-size:12pt;color:DarkBlue">
                    <td colspan=9>　總　　計：　　<%=countnum%>件
                        <%#(subcount>0?"( " + (countnum - subcount) + " 件公文 + " + subcount + " 件併案處理 )":"")%>
                        <br>
                        　總計服務費：　<%=tot_service%>元<br>
                        　總計規費：　　<%=tot_fees%>元
                    </td>
                </tr>
            </table>
            </center>
            <%#(subcount>0?"<br><font color='darkblue' size='2' >本所編號有 * 表示該筆資料為併案處理之子案件</font><br>":"")%>
            <br />
    </FooterTemplate>
    </asp:Repeater>
</form>
</body>
</html>
