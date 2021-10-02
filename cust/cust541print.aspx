<%@ Page Language="C#" %>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Data.SqlClient" %>
<%@ Import Namespace = "System.IO"%>
<%@ Import Namespace = "System.Linq"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<script runat="server">
    protected string HTProgCap = HttpContext.Current.Request["prgname"] ?? "客戶清冊";//功能名稱
    protected string HTProgPrefix = "cust54";//HttpContext.Current.Request["prgid"] ?? "";//程式檔名前綴
    protected string HTProgCode = "cust54";//HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = HttpContext.Current.Request["prgid"] ?? "";//程式代碼
    protected int HTProgRight = 0;
    protected string SQLStr = "";
    protected string wSQL = "";
    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected StringBuilder strOut = new StringBuilder();
    DataTable dtRpt = new DataTable();
    DataTable dtRptAtt = new DataTable();//聯絡人明細
    DataTable dtData = new DataTable();//主資料
    DataTable dtDataAtt = new DataTable();//主資料
    DataTable dtConCode = Sys.getCustCode("H", "", "sortfld");//顧問種類
    DataTable dtDis = Sys.getCustCode("B", "", "sortfld");//折扣代碼
    DataTable dtPayment = Sys.getCustCode("Payment", "", "sortfld");//付款條件
    DataTable dtCountry = Sys.getCountry();//申請人國籍
    protected string branch = "";//區所別
    protected int countnum = 0;//總計件數
    protected string scodename = "";
    protected string OrderType = "";
    protected string OrderTypeName = "";
    protected string level = "";
    protected string dept = "";
    protected string deptName = "";
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
        deptName = (dept == "P") ? "專利" : "商標";
        level = ReqVal.TryGet("level");
        AttFlag = ReqVal.TryGet("AttFlag");
        
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
            SQLStr += "select a.*, b.*, ";
            SQLStr += "(select sc_name from sysctrl.dbo.scode where scode = a.pscode) as pscodename , (select sc_name from sysctrl.dbo.scode where scode = a.tscode) as tscodename ";
            SQLStr += " from custz a , apcust b ";
            SQLStr += " where a.cust_area = b.cust_area and a.cust_seq = b.cust_seq ";
            SQLStr += wSQL + SQLOrderBy();
            conn.DataTable(SQLStr, dtData);

            if (dtData.Rows.Count == 0)
            {
                bData = false; return;
            }
            

            //Get AttData
            string SQLAtt = "select * from custz_att where cust_area = '" + branch + "' and cust_seq >= " + ReqVal.TryGet("cust_seqS") + " and cust_seq <= " + ReqVal.TryGet("cust_seqE");
            SQLAtt += " and (dept = '" + dept + "' or dept = '' or dept is null) ";
            conn.DataTable(SQLAtt, dtDataAtt);
            
            rptRepeater.DataSource = dtData;
            rptRepeater.DataBind();
        }
    }

    protected void dataRepeater_ItemDataBound(object sender, RepeaterItemEventArgs e)
    {
        //if (e.Item.ItemIndex == 0)
        //{//因pagebind&repeater bind會讓repaeter觸發綁定2次.所以第一筆時總計要重算
        //    countnum = 0;
        //}

        if ((e.Item.ItemType == ListItemType.Item) || (e.Item.ItemType == ListItemType.AlternatingItem))
        {
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
                Orderby += " order by a." + dept.ToLower() + "scode, a.cust_area, a.cust_seq";
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
            if (Eval("pscode").ToString() == "np") { return Eval("pscode") + " " + "專利部門"; }
            else { return Eval("pscode") + " " + Eval("pscodename"); }
        }
        else
        {
            if (Eval("tscode").ToString() == "nt") { return Eval("tscode") + " " + "商標部門"; }
            else { return Eval("tscode") + " " + Eval("tscodename"); }
        }
    }

    protected string SetAccAddr(RepeaterItem Container)
    {
        string s = "";
        string zip = "";
        if (dept == "P")
        {
            zip = (Eval("acc_zip").ToString() == "") ? "" : Eval("acc_zip").ToString() + " ";
            s = zip + Eval("acc_addr1").ToString() + Eval("acc_addr2").ToString();
        }
        else
        {
            zip = (Eval("tacc_zip").ToString() == "") ? "" : Eval("tacc_zip").ToString() + " ";
            s = zip + Eval("tacc_addr1").ToString() + Eval("tacc_addr2").ToString();
        }
        return s;
    }
    
    protected string SetAccTel(RepeaterItem Container)
    {
        string tel1 = (Util.NullConvert(Eval("acc_tel1")) != "") ? "-" + Eval("acc_tel1").ToString() :"" ;
        if (dept == "P")
        {
            return "(" + Eval("acc_tel0").ToString() + ")" + Eval("acc_tel").ToString() + tel1;
        }
        else return "(" + Eval("tacc_tel0").ToString() + ")" + Eval("tacc_tel").ToString() + tel1;
    }

    protected string SetConCode(RepeaterItem Container)
    {
        DataRow[] r = dtConCode.Select("cust_code = '" + Eval("con_code") + "'");
        if (r.Length > 0)
        {
            return r[0]["code_name"].ToString();
        }
        else return "";
    }

    protected string SetDisCode(RepeaterItem Container)
    {
        DataRow[] r = dtDis.Select("cust_code = '" + Eval(dept.ToLower()+"dis_type") + "'");
        if (r.Length > 0)
        {
            return r[0]["code_name"].ToString();
        }
        else return "";
    }
    protected string SetPaymentCode(RepeaterItem Container)
    {
        DataRow[] r = dtPayment.Select("cust_code = '" + Eval(dept.ToLower()+"pay_type") + "'");
        if (r.Length > 0)
        {
            return r[0]["code_name"].ToString();
        }
        else return "";
    }
    protected string SetCountry(RepeaterItem Container)
    {
        DataRow[] r = dtCountry.Select("coun_code = '" + Eval("ap_country") + "'");
        if (r.Length > 0)
        {
            return r[0]["coun_code"].ToString() + "_" + r[0]["coun_c"].ToString();
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
    <asp:Label ID="lblEmpty" runat="server" Visible='<%#bool.Parse((rptRepeater.Items.Count==0).ToString())%>'>
        <div align="center"><font color="red" size=2>=== 查無資料===</font></div>
    </asp:Label> 
	<asp:Repeater id="rptRepeater" runat="server" Visible='<%#bool.Parse((rptRepeater.Items.Count>0).ToString())%>' OnItemDataBound="dataRepeater_ItemDataBound">
        <FooterTemplate>
        </FooterTemplate>
        <HeaderTemplate>
            <table border=1 width="100%" cellspacing="0" cellpadding="2">	
        </HeaderTemplate>
	    <ItemTemplate>
                <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>">
			        <td align="right" nowrap>客戶編號：</td>
			        <td nowrap><b><%#Eval("cust_area")%><%#Eval("cust_seq")%></b></td>
			        <td align="right" nowrap>群組客戶：</td>
			        <td nowrap><%#Eval("ref_seq")%></td>
			        <td align="right" nowrap>建檔日期：</td>
			        <td nowrap><%#Eval("in_date","{0:yyyy/M/d}")%></td>
		        </tr>
                <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>">
			        <td align="right" nowrap>客戶名稱(中)：</td>
			        <td nowrap colspan="3"><%#Eval("ap_cname1")%><%#Eval("ap_cname2")%></td>
			        <td align="right" nowrap><%=deptName%>營洽：</td>
			        <td nowrap><%#SetScodeName(Container)%></td>
		        </tr>
                <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>">
			        <td align="right" nowrap>客戶名稱(英)：</td>
			        <td colspan="3"><%#Eval("ap_ename1")%><%#Eval("ap_ename2")%></td>
			        <td align="right" nowrap>統一編號：</td>
			        <td nowrap><%#Eval("id_no")%></td>
		        </tr>
                <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>">
			        <td align="right" nowrap>代表人(中)：</td>
			        <td nowrap><%#Eval("ap_crep")%></td>
			        <td align="right" nowrap>代表人(英)：</td>
			        <td nowrap><%#Eval("ap_erep")%></td>
			        <td align="right" nowrap>客戶國籍：</td>
                    <td nowrap><%#SetCountry(Container)%></td>
		        </tr>
                <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>">
			        <td align="right" >登記地址：</td>
			        <td colspan=5>
                         <%#(Eval("ap_zip")== "")?string.Empty: Eval("ap_zip") + " "%><%#Eval("ap_addr1")%><%#Eval("ap_addr2")%>
			        </td>
		        </tr>
                <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>">
			        <td align="right" nowrap>聯絡地址：</td>
			        <td colspan="5">
                        <%--<%#Eval("apatt_zip")%><%#Eval("apatt_addr1")%><%#Eval("apatt_addr2")%>--%>
                        <%#(Eval("apatt_zip")== "")? string.Empty : Eval("apatt_zip") + " " %><%#Eval("apatt_addr1")%><%#Eval("apatt_addr2")%>
			        </td>
		        </tr>
                <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>">
			        <td align="right" nowrap><%=deptName%>對帳地址：</td>
			        <td colspan="5"><%#SetAccAddr(Container)%></td>
		        </tr>
                <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>">
			        <td align="right" nowrap>聯絡電話：</td>
			        <td nowrap>
                        (<%#Eval("apatt_tel0")%>)<%#Eval("apatt_tel")%><%#(Util.NullConvert(Eval("apatt_tel1"))!="")?"-"+Eval("apatt_tel1"):""%>
			        </td>
			        <td align="right" nowrap>聯絡傳真：</td>
			        <td nowrap><%#Eval("apatt_fax")%></td>
                    <td align="right" nowrap>郵寄雜誌：</td>
			        <td nowrap><%#Eval("mag")%></td>
		        </tr>
                <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>">
			        <td align="right" nowrap><%=deptName%>會計電話：</td>
			        <td nowrap ><%#SetAccTel(Container)%></td>
                    <td align="right" nowrap><%=deptName%>會計傳真：</td>
			        <td nowrap ><%#(dept == "P")? Eval("acc_fax") : Eval("tacc_fax")%></td>
                    <td align="right" nowrap>顧問種類：</td>
			        <td nowrap ><%#SetConCode(Container)%></td>
		        </tr>
                <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>">
			        <td align="right" nowrap><%=deptName%>折扣條件：</td>
			        <td nowrap ><%#SetDisCode(Container)%></td>
                    <td align="right" nowrap><%=deptName%>付款條件：</td>
			        <td nowrap ><%#SetPaymentCode(Container)%></td>
                    <td align="right" nowrap><%=deptName%>客戶等級：</td>
			        <td nowrap ><%# (dept == "P")?Eval("plevel"):Eval("tlevel")%></td>
		        </tr>
                <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>">
			        <td align="right" nowrap>備註：</td>
			        <td nowrap colspan="5"><%#Eval("mark")%></td>
		        </tr>
                <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>">
                    <td colspan="6">
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
                                                    <%# (Util.NullConvert(Eval("att_tel0")) != "") ? "(" + Eval("att_tel0") + ")":""%><%#Eval("att_tel")%><%#Eval("att_tel1")%>
                                                    
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
