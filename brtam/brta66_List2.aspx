<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Linq" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<script runat="server">
    protected string HTProgCap = "內商品質控制(T.Q.C)事項分析查詢";// HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "brta66";//HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = HttpContext.Current.Request["prgid"] ?? "";//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";

    protected string SQL = "";
    protected object objResult = null;
    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    
    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";
    
    protected string titleLabel = "";
    protected string submitTask = "";

    protected DataTable dtx = new DataTable();
    protected DataTable dty = new DataTable();
    protected DataTable dt = new DataTable();
    protected string hrefq = "";

    DBHelper conn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    private void Page_Unload(System.Object sender, System.EventArgs e) {
        if (conn != null) conn.Dispose();
    }

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");
        submitTask = Request["submitTask"] ?? "";

        conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");

        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        //HTProgCap = myToken.Title;
        DebugStr = myToken.DebugStr;
        if (HTProgRight >= 0) {
            QueryData();
            ListPageLayout();

            this.DataBind();
        }
    }

    private void ListPageLayout() {
        StrFormBtnTop += "<a href=\"" + HTProgPrefix + ".aspx?prgid=" + prgid + "\" >[查詢畫面]</a>";

        //根據查詢條件組查詢條件字串(hrefq)
        hrefq += "&sstep_date=" + Request["sdate"];
        hrefq += "&estep_date=" + Request["edate"];

        titleLabel = "◎統計區間：" + ReqVal["sdate"] + "～" + ReqVal["edate"];
    }

    private void QueryData() {
            string SQL = "";

            //符合條件的明細
            SQL = "select a.dmt_scode,b.TQC_Type,count(*) as cnt,c.mark1 ";
            SQL += ",Right('0000'+substring(a.dmt_scode,2,len(a.dmt_scode)),4)sort_scode ";
            SQL += ",case when Left(b.TQC_Type,1)='a' THEN '＊申　　　　請　　　　補　　　　正　　　　案＊' ";
            SQL += "when Left(b.TQC_Type,1)='b' THEN '＊核　　　　駁　　　　前　　　　函　　　　請＊' ";
            SQL += "when Left(b.TQC_Type,1)='c' THEN '＊爭　　　　救　　　　案　　　　函　　　　請＊' ";
            SQL += "when Left(b.TQC_Type,1)='d' THEN '＊延　　　　期　　　　函　　　　覆＊' ";
            SQL += "when Left(b.TQC_Type,1)='e' THEN '＊爭　　　　救　　　　延　　　　補　　　　案＊' ";
            SQL += "END TQC_Type1_nm,Left(b.TQC_Type,1)TQC_Type1 ";
            SQL += ",(select code_name from cust_code where code_type = 'TTQC_Type' and cust_code = b.TQC_Type) as qty_name ";
            SQL += ",(select sc_name from sysctrl.dbo.scode where scode=a.dmt_scode) as scode_name ";
            SQL += "from vstep_dmt a ";
            SQL += "inner join vcode_act b on a.rs_type = b.rs_type and a.rs_class = b.rs_class and a.rs_code = b.rs_code and a.act_code = b.act_code ";
            SQL += "inner join cust_code c on b.TQC_TYPE= c.cust_code and a.cg = left(c.mark1,1) and a.rs = right(c.mark1,1) ";
            SQL += " where b.tqc_type is not null and a.dmt_scode is not null ";
            SQL += " and c.code_type = 'TTQC_TYPE' ";
            SQL += " and a.rs_no = a.main_rs_no and a.seq1 <> 'M' and a.seq1 <> 'Z' ";
            if (ReqVal.TryGet("sdate") != "") {
                SQL += "AND a.step_date>='" + ReqVal["sdate"] + "' ";
            }
            if (ReqVal.TryGet("edate") != "") {
                SQL += "AND a.step_date<='" + ReqVal["edate"] + "' ";
            }
            SQL += "group by b.TQC_Type,a.dmt_scode,c.mark1 ";
            SQL += "order by b.TQC_Type,sort_scode";
            conn.DataTable(SQL, dt);
        
            //x軸(人員)
            dtx = dt.DefaultView.ToTable(true, new string[] { "dmt_scode", "sort_scode", "scode_name" });
            dtx.DefaultView.Sort= "sort_scode";
            xRepeater.DataSource = dtx;
            xRepeater.DataBind();

            //y軸(大分類)
            dty = dt.DefaultView.ToTable(true, new string[] { "TQC_Type1", "TQC_Type1_nm", "mark1" });
            dty.DefaultView.Sort = "TQC_Type1";
            yRepeater.DataSource = dty;
            yRepeater.DataBind();
    }

    protected void yRepeater_ItemDataBound(object sender, RepeaterItemEventArgs e) {
        if ((e.Item.ItemType == ListItemType.Item) || (e.Item.ItemType == ListItemType.AlternatingItem)) {
            Repeater y1Repeater = (Repeater)e.Item.FindControl("y1Repeater");
            //y軸(小分類)
            string TQC_Type1 = DataBinder.Eval(e.Item.DataItem, "TQC_Type1").ToString();
            DataTable dtY1 = dt.Select("TQC_Type1='" + TQC_Type1 + "'").CopyToDataTable().DefaultView.ToTable(true, new string[] { "TQC_Type", "qty_name", "mark1" });
            y1Repeater.DataSource = dtY1;
            y1Repeater.DataBind();
            //小計人員
            Repeater xSubRepeater = (Repeater)e.Item.FindControl("xSubRepeater");
            xSubRepeater.DataSource = dtx;
            xSubRepeater.DataBind();
        } else if (e.Item.ItemType == ListItemType.Footer) {// For Footer
            //合計人員
            Repeater xTotRepeater = (Repeater)e.Item.FindControl("xTotRepeater");
            xTotRepeater.DataSource = dtx;
            xTotRepeater.DataBind();
        }
    }
    
    protected void y1Repeater_ItemDataBound(object sender, RepeaterItemEventArgs e) {
        if ((e.Item.ItemType == ListItemType.Item) || (e.Item.ItemType == ListItemType.AlternatingItem)) {
            //子項人員
            Repeater x1Repeater = (Repeater)e.Item.FindControl("x1Repeater");
            x1Repeater.DataSource = dtx;
            x1Repeater.DataBind();
        }
    }

    //件數
    protected string GetCnt(string vType, string vScode) {
        string rtn = "";

        string where = " 1=1 ";
        if (vType != "") where += " and TQC_Type like '" + vType + "%'";
        if (vScode != "") where += " and dmt_scode='" + vScode + "'";
        rtn = dt.Compute("sum(cnt)", where).ToString();
        rtn = rtn == "" ? "0" : Convert.ToInt32(rtn).ToString("N0");

        return rtn;
    }
</script>
<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title><%#HTProgCap%></title>
    <uc1:head_inc_form runat="server" ID="head_inc_form" />
</head>

<body>
<table cellspacing="1" cellpadding="0" width="98%" border="0" align="center">
    <tr>
        <td class="text9" nowrap="nowrap">&nbsp;【<%=prgid%> <%=HTProgCap%>】</td>
        <td class="FormLink" valign="top" align="right" nowrap="nowrap">
            <%#StrFormBtnTop%>
        </td>
    </tr>
    <tr>
        <td colspan="2"><hr class="style-one"/></td>
    </tr>
</table>
<br />
<%#titleLabel%>
<table width="100%" cellspacing="1" cellpadding="2" class="bluetable" align="center" style="background-color:gray">
    <tr class=lightbluetable style="font-size:12pt">
        <td align="center" class="lightbluetable2"><font color=white>營洽人員＊</font></td>
        <asp:Repeater id="xRepeater" runat="server">
        <ItemTemplate>
            <td class=lightbluetable2 align="center" nowrap><font color=white><%#Eval("scode_name")%></font></td>
        </ItemTemplate>
        </asp:Repeater>
        <td align="center" class="lightbluetable2"><font color=white>合計</font></td>
    </tr>

    <asp:Repeater id="yRepeater" runat="server" OnItemDataBound="yRepeater_ItemDataBound">
    <ItemTemplate>
        <tr>
            <td align=center class=lightbluetable colspan=<%#(dtx.Rows.Count+2)%>><%#Eval("TQC_Type1_nm")%></td>
        </tr>
        <asp:Repeater id="y1Repeater" runat="server" OnItemDataBound="y1Repeater_ItemDataBound">
        <ItemTemplate>
            <tr>
                <td align=left class="lightbluetable3">&nbsp;&nbsp;&nbsp;<%#Eval("qty_name")%></td>
                <asp:Repeater id="x1Repeater" runat="server">
                <ItemTemplate>
                    <td align=center class="sfont9" style="cursor:pointer;" onmouseover="this.style.color='red'" onmouseout="this.style.color='black'" onclick="CntClick('<%#DataBinder.Eval(((RepeaterItem)Container.Parent.Parent).DataItem, "TQC_Type")%>','<%#Eval("dmt_scode")%>','<%#DataBinder.Eval(((RepeaterItem)Container.Parent.Parent).DataItem, "mark1")%>')">
                        <%#GetCnt(DataBinder.Eval(((RepeaterItem)Container.Parent.Parent).DataItem, "TQC_Type").ToString(),Eval("dmt_scode").ToString())%>
                    </td>
                </ItemTemplate>
                </asp:Repeater>
                <td align=center class="sfont9" style="cursor:pointer;" onmouseover="this.style.color='red'" onmouseout="this.style.color='black'" onclick="CntClick('<%#Eval("TQC_Type")%>','','<%#Eval("mark1")%>')"><%#GetCnt(Eval("TQC_Type").ToString(),"")%></td>
            </tr>
        </ItemTemplate>
        </asp:Repeater>
        <tr>
            <td align="left" class="lightbluetable3">&nbsp;&nbsp;&nbsp;小  計</td>
            <asp:Repeater id="xSubRepeater" runat="server">
            <ItemTemplate>
                <td align=center class="sfont9" style="cursor:pointer;" onmouseover="this.style.color='red'" onmouseout="this.style.color='black'" onclick="CntClick('<%#DataBinder.Eval(((RepeaterItem)Container.Parent.Parent).DataItem, "TQC_Type1")%>','<%#Eval("dmt_scode")%>','<%#DataBinder.Eval(((RepeaterItem)Container.Parent.Parent).DataItem, "mark1")%>')">
                    <%#GetCnt(DataBinder.Eval(((RepeaterItem)Container.Parent.Parent).DataItem, "TQC_Type1").ToString(),Eval("dmt_scode").ToString())%>
                </td>
            </ItemTemplate>
            </asp:Repeater>
            <td align=center class="sfont9" style="cursor:pointer;" onmouseover="this.style.color='red'" onmouseout="this.style.color='black'" onclick="CntClick('<%#Eval("TQC_Type1")%>','','<%#Eval("mark1")%>')"><%#GetCnt(Eval("TQC_Type1").ToString(),"")%></td>
       </tr>
    </ItemTemplate>
    <FooterTemplate>
        <tr>
            <td align="left" class="lightbluetable3">&nbsp;&nbsp;&nbsp;合  計</td>
            <asp:Repeater id="xTotRepeater" runat="server">
            <ItemTemplate>
                <td align=center class="sfont9" style="cursor:pointer;" onmouseover="this.style.color='red'" onmouseout="this.style.color='black'" onclick="CntClick('','<%#Eval("dmt_scode")%>','')"><%#GetCnt("",Eval("dmt_scode").ToString())%></td>
            </ItemTemplate>
            </asp:Repeater>
            <td align=center class="sfont9" style="cursor:pointer;" onmouseover="this.style.color='red'" onmouseout="this.style.color='black'" onclick="CntClick('','','')"><%#GetCnt("","")%></td>
        </tr>
    </FooterTemplate>
    </asp:Repeater>
</table>

<div id="dialog"></div>

</body>
</html>

<script language="javascript" type="text/javascript">
    $(function () {
        if (window.parent.tt !== undefined) {
            window.parent.tt.rows = "100%,0%";
        }
    });

    function CntClick(pTqc_type, pDmt_scode, pCgrs) {
        var url = getRootPath() + "/brtam/brta66_List2_1.aspx?prgid=<%#prgid%>&menu=Y&tqc_type=" + pTqc_type + "&dmt_scode=" + pDmt_scode + "&cgrs=" + pCgrs + "<%#hrefq%>";
        //window.open(url, "myWindowOneN", "width=750px height=520px top=10 left=10 toolbar=no, menubar=no, location=no, directories=no resizeable=no status=no scrollbars=yes");
        $('#dialog').html('<iframe style="border: 0px;" src="' + url + '" width="100%" height="100%"></iframe>')
        .dialog({ autoOpen: true, modal: true, height: 540, width: "80%", title: "明細" });
    }
</script>
