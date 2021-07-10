<%@ Page Language="C#" %>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Data.SqlClient" %>
<%@ Import Namespace = "System.IO"%>
<%@ Import Namespace = "System.Linq"%>
<%@ Import Namespace = "System.Collections.Generic"%>

<script runat="server">
    protected string HTProgCap = HttpContext.Current.Request["prgname"] ?? "商標總簿簡表";//功能名稱
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
    
    protected void PageLayout() {
        string wSQL = "";
        using (DBHelper conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST")) {
            if ((Request["sseq"] ?? "") != "") wSQL += " and seq>='" + Request["sseq"] + "'";
            if ((Request["eseq"] ?? "") != "") wSQL += " and seq<='" + Request["eseq"] + "'";
            if ((Request["seq1"] ?? "") != "") wSQL += " and seq1='" + Request["seq1"] + "'";
            if ((Request["scode1"] ?? "") != "") wSQL += " and scode='" + Request["scode1"] + "'";
            if ((Request["cust_area"] ?? "") != "") wSQL += " and cust_area='" + Request["cust_area"] + "'";
            if ((Request["scust_seq"] ?? "") != "") wSQL += " and cust_seq>='" + Request["scust_seq"] + "'";
            if ((Request["ecust_seq"] ?? "") != "") wSQL += " and cust_seq<='" + Request["ecust_seq"] + "'";

            branchname = Sys.getCodeName(conn, "sysctrl.dbo.branch_code", "branchname", "where branch='" + Session["seBranch"] + "'");
            
            SQL = "select seq,seq1,in_date,apply_date,apply_no,open_date,issue_date,issue_no,rej_no";
            SQL+= ",agt_no,(select agt_name from agt where agt_no=a.agt_no) as agt_name";
            SQL+= ",scode,(select sc_name from sysctrl.dbo.scode where scode=a.scode) as sc_name";
            SQL+= ",pul,step_grade,class_count,class,s_mark";
            SQL+= ",cust_area,cust_seq,(select rtrim(ap_cname1)+rtrim(isnull(ap_cname2,'')) from apcust where cust_area=a.cust_area and cust_seq=a.cust_seq) as cust_name";
            SQL += ",appl_name,dmt_draw,renewal,ref_no1,ref_no2,ref_no3,term1,term2,tcn_ref,end_date,end_code";
            SQL += ",''fseq,''pulnm,''draw,''ref_no,''classnm,''s_marknm,''term";
            SQL+= " from dmt a where 1=1";
            SQL += wSQL;
            SQL += " order by seq,seq1";
            conn.DataTable(SQL, dtRpt);
    
            for (int i = 0; i < dtRpt.Rows.Count; i++) {
                countnum += 1;
                //本所編號
                dtRpt.Rows[i]["fseq"] = dtRpt.Rows[i]["fseq"] + Sys.formatSeq1(dtRpt.Rows[i].SafeRead("seq", ""), dtRpt.Rows[i].SafeRead("seq1", ""), "", dtRpt.Rows[i].SafeRead("cust_area", ""), Sys.GetSession("dept"));
                //正 聯 防
                if (dtRpt.Rows[i].SafeRead("pul", "") == "") dtRpt.Rows[i]["pulnm"] = "正商標";
                if (dtRpt.Rows[i].SafeRead("pul", "") == "1") dtRpt.Rows[i]["pulnm"] = "聯合";
                if (dtRpt.Rows[i].SafeRead("pul", "") == "2") dtRpt.Rows[i]["pulnm"] = "防護";
                //商標名稱
                if (dtRpt.Rows[i].SafeRead("dmt_draw", "") == "1") dtRpt.Rows[i]["draw"] = "及圖";
                if (dtRpt.Rows[i].SafeRead("dmt_draw", "") == "2") dtRpt.Rows[i]["draw"] = "圖";
                //相關案號
                dtRpt.Rows[i]["ref_no"] = dtRpt.Rows[i].SafeRead("ref_no1", "");
                if (dtRpt.Rows[i].SafeRead("ref_no2", "") != "") dtRpt.Rows[i]["ref_no"] += "," + dtRpt.Rows[i].SafeRead("ref_no2", "");
                if (dtRpt.Rows[i].SafeRead("ref_no3", "") != "") dtRpt.Rows[i]["ref_no"] += "," + dtRpt.Rows[i].SafeRead("ref_no3", "");
                //類　　別
                if (dtRpt.Rows[i].SafeRead("class_count", "") != "") dtRpt.Rows[i]["classnm"] += "共" + dtRpt.Rows[i].SafeRead("class_count", "")+"類";
                if (dtRpt.Rows[i].SafeRead("class", "") != "") dtRpt.Rows[i]["classnm"] += dtRpt.Rows[i].SafeRead("class", "");
                //種　　類
                if (dtRpt.Rows[i].SafeRead("s_mark", "") == "T") dtRpt.Rows[i]["s_marknm"] = "商標";
                if (dtRpt.Rows[i].SafeRead("s_mark", "") == "S") dtRpt.Rows[i]["s_marknm"] = "服務";
                if (dtRpt.Rows[i].SafeRead("s_mark", "") == "L") dtRpt.Rows[i]["s_marknm"] = "證明";
                if (dtRpt.Rows[i].SafeRead("s_mark", "") == "M") dtRpt.Rows[i]["s_marknm"] = "團體標章";
                if (dtRpt.Rows[i].SafeRead("s_mark", "") == "K") dtRpt.Rows[i]["s_marknm"] = "產地證明標章";
                if (dtRpt.Rows[i].SafeRead("s_mark", "") == "N") dtRpt.Rows[i]["s_marknm"] = "團體商標";
                //商標期限
                if (dtRpt.Rows[i].SafeRead("term1", "") != "") dtRpt.Rows[i]["term"] += dtRpt.Rows[i].GetDateTimeString("term1", "yyyy/M/d");
                if (dtRpt.Rows[i].SafeRead("term2", "") != "") dtRpt.Rows[i]["term"] += "~" + dtRpt.Rows[i].GetDateTimeString("term2", "yyyy/M/d");
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
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/client_chk.js")%>"></script>
</head>

<body>
<form id="reg" name="reg" method="post">
    <table border="0" width="100%" cellspacing="1" cellpadding="0" align="center">
		<tr style="font-size:12pt">
			<td width="25%" align=left></td>
			<td width="50%" style="font-size:20px" align=center><b><%#branchname%><%#HTProgCap%></b></td>
			<td width="25%" align=right><a href="javascript:window.print();void(0);">列印</a>日期：<%#DateTime.Today.ToShortDateString()%></td>
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
		            <td nowrap>立案日期</td>
		            <td nowrap>客戶</td>
		            <td nowrap>申請日期</td>
		            <td nowrap>申請號</td>
		            <td nowrap>審定號</td>
		            <td nowrap>核駁號</td>
		            <td nowrap>正商標號</td>
	            </tr>
        </HeaderTemplate>
	    <ItemTemplate>
                <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>">
			    <td nowrap align="center" rowspan="2"><%#Eval("fseq")%></td>
			    <td nowrap align="center">&nbsp;<%#Eval("in_date","{0:yyyy/M/d}")%></td>
			    <td nowrap align="center">&nbsp;<%#Eval("cust_area")%><%#Eval("cust_seq")%></td>
			    <td nowrap align="center">&nbsp;<%#Eval("apply_date","{0:yyyy/M/d}")%></td>
			    <td nowrap align="center">&nbsp;<%#Eval("apply_no")%></td>
			    <td nowrap align="center">&nbsp;<%#Eval("issue_no")%></td>
			    <td nowrap align="center">&nbsp;<%#Eval("rej_no")%></td>
			    <td nowrap align="center">&nbsp;<%#Eval("tcn_ref")%></td>
		    </tr>
            <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>">
			    <td align="right">商標名稱：</td>
			    <td colspan=3>&nbsp;<%#Eval("appl_name")%></td>
			    <td align="right">類別：</td>
			    <td colspan=2>共<%#Eval("class_count")%>類-<%#Eval("class")%></td>
		    </tr>
		    <tr><td colspan=8 height="1"></td></tr>
   </ItemTemplate>
    <FooterTemplate>
	            <tr class="lightbluetable" style="font-size:12pt;color:DarkBlue">
		            <td colspan=9>　總　　計：　　<%=countnum%>件</td>
	            </tr>
            </table>
            </center>
            <br />
    </FooterTemplate>
    </asp:Repeater>
</form>
</body>
</html>
