<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Linq" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<script runat="server">
    protected string HTProgCap = "交辦專案室爭救案品質評分表-統計表";// HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "Brt43";//HttpContext.Current.Request["prgid"] ?? "";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = HttpContext.Current.Request["prgid"] ?? "";//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";

    protected string SQL = "";

    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected string StrFormBtnTop = "";
    
    protected string titleLabel = "";
    protected string submitTask = "";

    protected DataTable dtx = new DataTable();
    protected DataTable dty = new DataTable();
    protected DataTable dt = new DataTable();
    protected string hrefq = "";

    DBHelper connopt = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    private void Page_Unload(System.Object sender, System.EventArgs e) {
        if (connopt != null) connopt.Dispose();
    }

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        connopt = new DBHelper(Conn.optK).Debug(Request["chkTest"] == "TEST");

        ReqVal = Util.GetRequestParam(Context,Request["chkTest"] == "TEST");
        submitTask = Request["submitTask"] ?? "";

        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        DebugStr = myToken.DebugStr;
        if (HTProgRight >= 0) {
            QueryData();
            ListPageLayout();

            this.DataBind();
        }
    }

    private void ListPageLayout() {
        StrFormBtnTop += "<a href=\"" + HTProgPrefix + ".aspx?prgid=" + prgid + "\" >[查詢]</a>";

        //根據查詢條件組查詢條件字串(hrefq)
        hrefq += "&qryinclude=" + Request["qryinclude"];
        hrefq += "&qryYear=" + Request["qryYear"];
        hrefq += "&qrysMonth=" + Request["qrysMonth"];
        hrefq += "&qryeMonth=" + Request["qryeMonth"];
        hrefq += "&qrybr_source=" + Request["qrybr_source"];
        hrefq += "&prgid=" + Request["prgid"];

        string qryinclude_name = "";
        if ((Request["qryinclude"] ?? "") == "Y") {
            qryinclude_name = "&nbsp;<font color=blue>◎包含項目：</font>只印附屬案性";
        } else if ((Request["qryinclude"] ?? "") == "N") {
            qryinclude_name = "&nbsp;<font color=blue>◎包含項目：</font>不含附屬案性";
        }

        string qrybranch_name = "";
        if ((Request["qrybranch"] ?? "") == "N") {
            qrybranch_name = "&nbsp;<font color=blue>◎區所：</font>台北所";
        } else if ((Request["qrybranch"] ?? "") == "C") {
            qrybranch_name = "&nbsp;<font color=blue>◎區所：</font>台中所";
        } else if ((Request["qrybranch"] ?? "") == "S") {
            qrybranch_name = "&nbsp;<font color=blue>◎區所：</font>台南所";
        } else if ((Request["qrybranch"] ?? "") == "K") {
            qrybranch_name = "&nbsp;<font color=blue>◎區所：</font>高雄所";
        }

        string qryAP_DATE_name = "";
        ReqVal["qrySdate"] = Request["qryYear"] + "/" + Request["qrysMonth"].Trim() + "/1"; //上個月一號
        ReqVal["qryEdate"] = new DateTime(Convert.ToInt32(Request["qryYear"].ToString()), Convert.ToInt32(Request["qryeMonth"].Trim()), 1).AddMonths(1).AddDays(-1).ToShortDateString();
        qryAP_DATE_name = "&nbsp;<font color=blue>◎判行期間：</font>" + ReqVal["qrySdate"] + "~" + ReqVal["qryEdate"];

        titleLabel = "<font color=red>" + qryinclude_name + qrybranch_name + qryAP_DATE_name + "</font>";
    }

    private void QueryData() {
        string SQL = "";
        //x軸
        SQL = "select b.cust_code x_branch,b.code_name x_branchnm ";
        SQL += "from cust_code b ";
        SQL += "where b.code_type='OBranch' and b.cust_code in ('N','C','S','K') ";
        if ((Request["qryBranch"] ?? "") != "") {//區所
            SQL += " and b.cust_code='" + Request["qryBranch"] + "' ";
        }
        SQL += " order by b.sortfld ";
        connopt.DataTable(SQL, dtx);
        //如果沒有指定區所則顯示合計
        if ((Request["qryBranch"] ?? "") == "") {
            DataRow sumRow = dtx.NewRow();
            sumRow[0] = "";
            sumRow[1] = "合計";
            dtx.Rows.Add(sumRow);
        }

        //y軸
        SQL = "select m.cust_code y_month,m.code_name y_monthnm ";
        SQL += "from cust_code m ";
        SQL += "where m.code_type='Omonth' and m.cust_code>=" + Request["qrysMonth"] + " and m.cust_code<=" + Request["qryeMonth"] + " ";
        SQL += " order by m.sortfld ";
        connopt.DataTable(SQL, dty);
        DataRow totRow = dty.NewRow();

        //符合條件的明細
        SQL = "select month(a.ap_date)m_ap_date,* from br_opt as a ";
        SQL += "where a.mark<>'B'and score_flag='Y' ";
        SQL += " and year(a.ap_date)='" + Request["qryYear"] + "' ";
        SQL += " and month(a.ap_date)>=" + Request["qrysMonth"] + " ";
        SQL += " and month(a.ap_date)<=" + Request["qryeMonth"] + " ";
        if ((Request["qrybr_source"] ?? "") != "") {
            SQL += " and a.br_source='" + Request["qrybr_source"] + "' ";
        }
        if ((Request["qryBranch"] ?? "") != "") {//區所
            SQL += " and a.branch='" + Request["qryBranch"] + "' ";
        }
        connopt.DataTable(SQL, dt);


        branchRepeater1.DataSource = dtx;
        branchRepeater1.DataBind();
        branchRepeater2.DataSource = dtx;
        branchRepeater2.DataBind();

        monthRepeater.DataSource = dty;
        monthRepeater.DataBind();
    }

    protected void monthRepeater_ItemDataBound(object sender, RepeaterItemEventArgs e) {
        if ((e.Item.ItemType == ListItemType.Item) || (e.Item.ItemType == ListItemType.AlternatingItem)) {// For items
            Repeater branchRepeater3 = (Repeater)e.Item.FindControl("branchRepeater3");
            branchRepeater3.DataSource = dtx;
            branchRepeater3.DataBind();
        } else if (e.Item.ItemType == ListItemType.Footer) {// For Footer
            Repeater branchRepeater4 = (Repeater)e.Item.FindControl("branchRepeater4");
            branchRepeater4.DataSource = dtx;
            branchRepeater4.DataBind();
            Repeater branchRepeater5 = (Repeater)e.Item.FindControl("branchRepeater5");
            branchRepeater5.DataSource = dtx;
            branchRepeater5.DataBind();
        }
    }

    //案件數
    protected string GetCount(RepeaterItem Container, bool showlink) {
        string rtn = "";

        string month = (DataBinder.Eval(((RepeaterItem)Container.Parent.Parent).DataItem, "y_month") ?? "").ToString();
        string branch = DataBinder.Eval(Container.DataItem, "x_branch").ToString();
        string where = " 1=1";
        if (month != "") where += " and m_ap_date='" + month + "'";
        if (branch != "") where += " and branch='" + branch + "'";

        rtn = dt.Compute("count(branch)", where).ToString();
        rtn = rtn == "" ? "0" : Convert.ToInt32(rtn).ToString("N0");

        if (showlink && rtn != "0")
            rtn = "<a href='brt43_List2.aspx?1=1" + hrefq + "&submitTask=Q&qryBranch=" + branch + "&month=" + month + "' target='Eblank'>" + rtn + "</a>";
        return rtn;
    }

    //得分
    protected string GetScore(RepeaterItem Container, bool showlink) {
        string rtn = "";
        string month = (DataBinder.Eval(((RepeaterItem)Container.Parent.Parent).DataItem, "y_month") ?? "").ToString();
        string branch = DataBinder.Eval(Container.DataItem, "x_branch").ToString();

        string where = " 1=1";
        if (month != "") where += " and m_ap_date='" + month + "'";
        if (branch != "") where += " and branch='" + branch + "'";

        rtn = dt.Compute("Sum(score)", where).ToString();
        rtn = rtn == "" ? "0" : Convert.ToInt32(rtn).ToString("N0");

        if (showlink && rtn != "0")
            rtn = "<a href='brt43_List2.aspx?1=1" + hrefq + "&submitTask=Q&qryBranch=" + branch + "&month=" + month + "' target='Eblank'>" + rtn + "</a>";
        return rtn;
    }
    //平均得分
    protected string GetAvg(RepeaterItem Container, bool showlink) {
        string rtn = "";
        decimal score = Convert.ToDecimal(GetScore(Container, false));
        decimal count = Convert.ToDecimal(GetCount(Container, false));

        decimal avg = 0;
        if (score != 0 && count != 0)
            avg = (score / count);

        rtn = avg.ToString("N");

        string branch = DataBinder.Eval(Container.DataItem, "x_branch").ToString();
        if (showlink && rtn != "0")
            rtn = "<a href='brt43_List2.aspx?1=1" + hrefq + "&submitTask=Q&qryBranch=" + branch + " target='Eblank'>" + rtn + "</a>";
        return rtn;
    }
</script>
<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title><%=HTProgCap%></title>
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
    <tr>
        <td colspan="2"><%#titleLabel%></td>
    </tr>
</table>
<br />
<table width="60%" cellspacing="1" cellpadding="2" class="bluetable" align="center">
    <tr align="left">
        <td align="center" class="lightbluetable" rowspan=2>月份</td>
        <asp:Repeater id="branchRepeater1" runat="server">
        <ItemTemplate>
            <td align="center" class="lightbluetable" colspan=2><%#Eval("x_branchnm")%></td>
        </ItemTemplate>
        </asp:Repeater>
    </tr>
    <tr>
        <asp:Repeater id="branchRepeater2" runat="server">
        <ItemTemplate>
            <td align="center" class="lightbluetable" nowrap>案件數</td>
            <td align="center" class="lightbluetable" nowrap>得　分</td>
        </ItemTemplate>
        </asp:Repeater>
    </tr>

    <asp:Repeater id="monthRepeater" runat="server" OnItemDataBound="monthRepeater_ItemDataBound">
    <ItemTemplate>
        <tr>
            <td align="center" class="lightbluetable3"><%#Eval("y_monthnm")%></td>
            <asp:Repeater id="branchRepeater3" runat="server">
            <ItemTemplate>
                <td align="center" class="<%#Eval("x_branch")!= "" ?"sfont9":"lightbluetable3"%>">
                    <%#GetCount(Container,true)%>
                    <!--GetCount(((RepeaterItem)Container.Parent.Parent).DataItem,Eval("x_branch"))-->
                </td>
                <td align="center" class="<%#Eval("x_branch")!= "" ?"sfont9":"lightbluetable3"%>">
                    <%#GetScore(Container,false)%>
                    <!--GetScore(((RepeaterItem)Container.Parent.Parent).DataItem,Eval("x_branch"))-->
                </td>
            </ItemTemplate>
            </asp:Repeater>
        </tr>
    </ItemTemplate>
    <FooterTemplate>
        <tr>
            <td align="center" class="lightbluetable">總計</td>
            <asp:Repeater id="branchRepeater4" runat="server">
            <ItemTemplate>
                <td align="center" class="lightbluetable"><%#GetCount(Container,true)%></td>
                <td align="center" class="lightbluetable"><%#GetScore(Container,false)%></td>
            </ItemTemplate>
            </asp:Repeater>
        </tr>
        <tr>
            <td align="center" class="lightbluetable">平均得分</td>
            <asp:Repeater id="branchRepeater5" runat="server">
            <ItemTemplate>
                <td align="center" class="lightbluetable" colspan="2">
                    <%#GetAvg(Container,false)%>
                </td>
            </ItemTemplate>
            </asp:Repeater>
        </tr>
    </FooterTemplate>
    </asp:Repeater>
</table>
</body>
</html>

<script language="javascript" type="text/javascript">
    $(function () {
        if (window.parent.tt !== undefined) {
            if ($("#submittask").val() == "Q") {
                window.parent.tt.rows = "30%,70%";
            } else {
                window.parent.tt.rows = "100%,0%";
            }
        }
    });
</script>
