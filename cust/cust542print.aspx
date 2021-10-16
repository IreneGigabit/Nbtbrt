<%@ Page Language="C#" %>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Data.SqlClient" %>
<%@ Import Namespace = "System.IO"%>
<%@ Import Namespace = "System.Linq"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<script runat="server">
    protected string HTProgCap = HttpContext.Current.Request["prgname"] ?? "營洽客戶名冊";//功能名稱
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
    DataTable dtRptAtt = new DataTable();//聯絡人明細
    DataTable dtData = new DataTable();//主資料
    DataTable dtDataAtt = new DataTable();//主資料
    protected string branch = "";//區所別
    //protected string branchname = "";//區所別
    protected int countnum = 0;//總計件數
    protected string scodename = "";
    protected string OrderType = "";
    protected string OrderTypeName = "";
    protected string PagebyScode = "";
    protected string level = "";
    protected string dept = "";
    protected string AttFlag = "";
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
        AttFlag = ReqVal.TryGet("AttFlag");
        
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
            SQLStr = "select a.cust_area,a.cust_seq,a.in_date,a.id_no,a.plevel,a.tlevel,a.pscode,a.tscode,a.acc_zip,a.acc_addr1,a.acc_addr2,a.mag, ";
            SQLStr += " a.tacc_zip,a.tacc_addr1,a.tacc_addr2, ";
            SQLStr += " b.apclass,b.ap_cname1,b.ap_cname2,b.ap_crep,b.ap_zip,b.ap_addr1,b.ap_addr2,b.apatt_zip,b.apatt_addr1,b.apatt_addr2, ";
            SQLStr += "(select sc_name from sysctrl.dbo.scode where scode = a.pscode) as pscodename , (select sc_name from sysctrl.dbo.scode where scode = a.tscode) as tscodename ";
            SQLStr += " from custz a , apcust b ";
            SQLStr += " where a.cust_area = b.cust_area and a.cust_seq = b.cust_seq ";
            //if (ReqVal.TryGet("PagebyScode") == "Y")
            //{
            //    SQLStr = "select isnull(a." + dept.ToLower() + "scode,'') as scode from custz a , apcust b ";
            //    SQLStr += " where a.cust_area = b.cust_area  and a.cust_seq = b.cust_seq";
            //}
            SQLStr += wSQL + " order by a.cust_area, a.cust_seq";
            conn.DataTable(SQLStr, dtData);

            if (dtData.Rows.Count == 0)
            {
                bData = false; return;
            }

            //Get AttData
            string SQLAtt = "select * from custz_att where cust_area = '" + branch + "' and cust_seq >= " + ReqVal.TryGet("cust_seqS") + " and cust_seq <= " + ReqVal.TryGet("cust_seqE");
            SQLAtt += " and (dept = '" + dept + "' or dept = '' or dept is null) ";
            conn.DataTable(SQLAtt, dtDataAtt);

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
            conn.DataTable(SQL, dtRptMain);
            //for (int i = 0; i < dtRptMain.Rows.Count; i++)
            //{
            //    countnum += 1;
            //    //本所編號
            //    dtRpt.Rows[i]["fseq"] = dtRpt.Rows[i]["fseq"] + Sys.formatSeq1(dtRpt.Rows[i].SafeRead("seq", ""), dtRpt.Rows[i].SafeRead("seq1", ""), "", dtRpt.Rows[i].SafeRead("cust_area", ""), Sys.GetSession("dept"));
            //    //正 聯 防
            //    if (dtRpt.Rows[i].SafeRead("pul", "") == "") dtRpt.Rows[i]["pulnm"] = "正商標";
            //}
            rptRepeaterMain.DataSource = dtRptMain;
            rptRepeaterMain.DataBind();
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
                    if (DataBinder.Eval(e.Item.DataItem, "pscode").ToString() == "np")
                    {
                        scodename = "np 專利部門";
                    }
                    else
                    {
                        scodename = DataBinder.Eval(e.Item.DataItem, "pscode").ToString() + " " + DataBinder.Eval(e.Item.DataItem, "pscodename").ToString();
                    }
                }
                else
                {
                    if (DataBinder.Eval(e.Item.DataItem, "tscode").ToString() == "nt")
                    {
                        scodename = "nt 商標部門";
                    }
                    else
                    {
                        scodename = DataBinder.Eval(e.Item.DataItem, "tscode").ToString() + " " + DataBinder.Eval(e.Item.DataItem, "tscodename").ToString();        
                    }
                }
                

                if (OrderType == "2")
                {
                    //dtRpt = dtData.Select("pscode = '" + scodeStr + "'").CopyToDataTable();
                    dtRpt = dtData.Select(scode + " = '" + scodeStr + "'").CopyToDataTable();
                }
                else
                {
                    cust_seq = DataBinder.Eval(e.Item.DataItem, "cust_seq").ToString();
                    dtRpt = dtData.Select("cust_seq = '" + cust_seq + "'").CopyToDataTable();
                }
                
                //for (int i = 0; i < dtRpt.Rows.Count; i++)
                //{
                //    //檢查是否已掃描
                //    dr["pr_scan_path"] = Sys.Path2Nbtbrt(dr.SafeRead("attach_path", ""));
                //    if (Sys.CheckFile(dr.SafeRead("pr_scan_path", "")) == true)
                //    {
                //        dr["tstyle"] = "display:";
                //        dr["scanfile_title"] = "有文件";
                //    }
                //}
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
        
        
        if ((e.Item.ItemType == ListItemType.Item) || (e.Item.ItemType == ListItemType.AlternatingItem))
        {
            countnum += 1;
            if (AttFlag != "Y") return;
            string seq = DataBinder.Eval(e.Item.DataItem, "cust_seq").ToString();
            Repeater Rpt = (Repeater)e.Item.FindControl("rptRepeaterAtt");
            if (Rpt != null)
            {
                DataRow[] row = dtDataAtt.Select("cust_seq = " + seq);
                if (row.Length > 0)
                {
                    dtRptAtt = dtDataAtt.Select("cust_seq = " + seq).CopyToDataTable();
                    Rpt.DataSource = dtRptAtt;
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
        //string SQLSub = "";
        string SQLw = "";
        
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

        return SQLw ;
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
    
    

    protected string SetScodeName(RepeaterItem Container)
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
    
    protected string SetScodeNameTitle(RepeaterItem Container)
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
            <td colspan="3" width="25%" align=right><a href="javascript:window.print();void(0);">列印</a>日期：<%#DateTime.Today.ToShortDateString()%></td>
        </tr>

    </table>
    <asp:Label ID="lblEmpty" runat="server" Visible='<%#bool.Parse((rptRepeaterMain.Items.Count==0).ToString())%>'>
        <div align="center"><font color="red" size=2>=== 查無資料===</font></div>
    </asp:Label> 
	<asp:Repeater id="rptRepeaterMain" runat="server" Visible='<%#bool.Parse((rptRepeaterMain.Items.Count>0).ToString())%>' OnItemDataBound="dataRepeater_ItemDataBound">
        <HeaderTemplate>
            <table border=0 width="100%" cellspacing="0" cellpadding="2">	 
        </HeaderTemplate>
	    <ItemTemplate>
                 <tr>
                     <%--<input type="hidden" id=seq_<%#(Container.ItemIndex+1)%> value="<%#Eval("pscode")%>">--%>
                     <td colspan="8" >
                        <span class ="tr_codename" style="color:#0000FF; font-size:16px" ><%#SetScodeNameTitle(Container)%></span>  
                     </td>
                 </tr>
                 <asp:Repeater id="rptRepeater" runat="server" OnItemDataBound="dataRepeater2_ItemDataBound">
                        <HeaderTemplate>
                            <table border=1 width="100%" cellspacing="0" cellpadding="2">	 
                        </HeaderTemplate>
	                    <ItemTemplate>
                                 <tr>
		                            <td class=lightbluetable align=center style="width:10%">客戶編號</td>
		                            <td class=lightbluetable align=center>客戶名稱</td>
		                            <td class=lightbluetable align=center>代表人</td>
                                    <td class=lightbluetable align=center style="width:10%">客戶種類</td>
		                            <td class=lightbluetable align=center style="width:15%">統一編號</td>
		                            <td class=lightbluetable align=center style="width:5%">等級</td>
                                    <td class=lightbluetable align=center style="width:5%">雜誌</td>
		                            <td class=lightbluetable align=center style="width:10%">建檔日期</td>
                                </tr>
                                <tr>
			                        <td nowrap align=center style="font-size:14px"><b><%#Eval("cust_area")%><%#Eval("cust_seq")%></b></td>
			                        <td nowrap align=center><%#Eval("ap_cname1")%><%#Eval("ap_cname2")%></td>
			                        <td nowrap align=center><%#Eval("ap_crep")%></td>
                                    <td nowrap align=center><%#Eval("apclass")%></td>
			                        <td nowrap align=center><%#Eval("id_no")%></td>
                                    <td nowrap align=center>
                                        <%# (dept == "P")? Eval("plevel") : Eval("tlevel")%>
                                    </td>
                                    <td nowrap align=center><%#Eval("mag")%></td>
                                    <td nowrap align=center><%#Eval("in_date","{0:d}")%></td>
		                        </tr>
                                <tr>
			                        <td nowrap align=center style="font-size:14px">
                                        <b>
                                            <%#SetScodeName(Container)%>
                                        </b>
			                        </td>
			                        <td nowrap colspan="7" align="left" style="padding-top: 6px; padding-bottom: 6px">
                                        證照地址：(<%#Eval("ap_zip")%>)<%#Eval("ap_addr1")%><%#Eval("ap_addr2")%><br>
						                聯絡地址：(<%#Eval("apatt_zip")%>)<%#Eval("apatt_addr1")%><%#Eval("apatt_addr2")%><br>
						                對帳地址：<%# (dept == "P") ? "(" +Eval("acc_zip")+")"+ Eval("acc_addr1") + Eval("acc_addr2") 
                                             : "(" +Eval("tacc_zip")+")"+ Eval("tacc_addr1") + Eval("tacc_addr2")  %>
			                        </td>
		                        </tr>
                            

                            <tr class="tr_AttList">
                                <td align="center">聯絡人名單</td>

                                <td nowrap colspan="7" >
                                    <asp:Repeater id="rptRepeaterAtt" runat="server">
                                    <HeaderTemplate>
                                        <table border=0 width="100%" cellspacing="0" cellpadding="1">
                                            <tr>
		                                        <td align=center style="width:20%"><u>聯絡人</u></td>
		                                        <td align=center style="width:15%"><u>職稱</u></td>
		                                        <td align=center style="width:25%"><u>聯絡部門</u></td>
                                                <td align=center style="width:30%"><u>聯絡電話</u></td>
					                            <td align=center style="width:10%"><u>郵寄雜誌</u></td>              
                                            </tr>
                                    </HeaderTemplate>
	                                <ItemTemplate>                 
                                            <tr>
			                                    <td nowrap align=center><%#(Eval("attention") == "") ? "-" : Eval("attention")%></td>
			                                    <td nowrap align=center><%#(Eval("att_title") == "") ? "-" : Eval("att_title") %></td>
			                                    <td nowrap align=center><%#(Eval("att_dept") == "") ? "-" : Eval("att_dept")%></td>
                                                <td nowrap align=center>
                                                    <%# (Eval("att_tel0") != "") ? "(" + Eval("att_tel0") + ")" : ""%>
                                                    <%#Eval("att_tel")%><%#Eval("att_tel1")%>
                                                </td>
                                                <td nowrap align=center><%#Eval("att_mag")%></td>
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
                   </ItemTemplate>
                    <FooterTemplate>
	                            <tr class="lightbluetable" style="font-size:14pt;color:DarkBlue" >
		                            <td colspan="9" class="tr_codenamecount">
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
</form>
</body>
</html>

<script type="text/javascript">
 
    if ('<%=OrderType%>' == "2") {
        if ('<%=PagebyScode%>' != "Y") {
            $(".tr_codename").hide();
            $(".tr_codenamecount").hide();
        }
    }
    else {
        $(".tr_codename").hide();
        $(".tr_codenamecount").hide();
    }

    if ('<%=AttFlag%>' != "Y") {
        $(".tr_AttList").hide();
    }

    if ('<%=bData%>' == 'False') {
        alert("無符合條件之資料");
        this.close();
    }

</script>
