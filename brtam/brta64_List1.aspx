<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Linq"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<script runat="server">
    protected string HTProgCap = "國內案管制期限稽催查詢";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "brta64";//HttpContext.Current.Request["prgid"] ?? "";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";

    protected string SQL = "";
    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected Paging page = null;

    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";
    protected string FormName = "";

    protected string rptTitle = "";//報表抬頭

    DBHelper conn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    DBHelper cnn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    private void Page_Unload(System.Object sender, System.EventArgs e) {
        if (conn != null) conn.Dispose();
        if (cnn != null) cnn.Dispose();
    }

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");
        
        conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
        cnn = new DBHelper(Conn.Sysctrl).Debug(Request["chkTest"] == "TEST");

        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        //HTProgCap = myToken.Title;
        DebugStr = myToken.DebugStr;
        if (HTProgRight >= 0) {
            PageLayout();
            QueryData();
            this.DataBind();
        }
    }

    private void PageLayout() {
        StrFormBtnTop += "<a href='" + HTProgPrefix + ".aspx?prgid=" + prgid + "'>[查詢畫面]</a>";

        string scode1nm = "全部";
        if (ReqVal.TryGet("scode1") != "") {
            SQL = "select sc_name from sysctrl.dbo.scode where scode='" + Request["scode1"] + "'";
            object objResult = conn.ExecuteScalar(SQL);
            scode1nm = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();
        }

        //包含結案案件
        string endcodenm = "未結案案件";
        if (ReqVal.TryGet("qendcode") == "Y") {
            endcodenm = "包含結案案件";
        }

        rptTitle += "<td>◎管制期間：" + Request["sdate"] + "～" + Request["edate"] + "</td>";
        rptTitle += "<td>管制種類：" + Request["ctrl_typenm"] + "</td>";
        rptTitle += "<td>營洽：" + scode1nm + "</td>";
        rptTitle += "<td align=right>結案：" + endcodenm + "</td>";
    }

    private void QueryData() {
        DataTable dt = new DataTable();
        SQL = "select min(b.ctrl_date) as ctrl_date,a.rs_no,a.branch,a.seq,a.seq1,a.step_grade,a.cappl_name,a.cust_area,a.cust_seq ";
        SQL += ",a.rs_detail,a.scode1,isnull(rtrim(c.ap_cname1),'')+isnull(rtrim(c.ap_cname2),'') as ap_cname,a.end_date ";
        SQL += ",''tclass,''fseq,''end_star,''lscode ";
        SQL += "  from vstep_dmt a ";
        SQL += " inner join ctrl_dmt b on a.rs_no = b.rs_no ";
        SQL += " inner join apcust c on a.cust_area  = c.cust_area and a.cust_seq  = c.cust_seq ";
        SQL += " where a.branch='" + Session["seBranch"] + "' and left(b.ctrl_type,1) in ('A','B') ";
        if (ReqVal.TryGet("chkdate") != "Y") {
            if (ReqVal.TryGet("sdate") != "") {
                SQL += " and b.ctrl_date>='" + ReqVal.TryGet("sdate") + "'";
            }
            if (ReqVal.TryGet("edate") != "") {
                SQL += " and b.ctrl_date<='" + ReqVal.TryGet("edate") + "'";
            }
        }
        if (ReqVal.TryGet("ctrl_type") != "") {
            SQL += " and b.ctrl_type like '" + ReqVal.TryGet("ctrl_type") + "%'";
        }
        if (ReqVal.TryGet("scode1") != "") {
            SQL += " and a.scode1='" + ReqVal.TryGet("scode1") + "'";
        }
        if (ReqVal.TryGet("cust_seq") != "") {
            SQL += " and a.cust_area='" + Session["seBranch"] + "'";
            SQL += " and a.cust_seq='" + ReqVal.TryGet("cust_seq") + "'";
        }
        //包含結案案件
        if (ReqVal.TryGet("qendcode") != "Y") {
            SQL += " and a.end_date is null";
        }

        SQL += " group by a.rs_no,a.branch,a.seq,a.seq1,a.step_grade,a.cust_area,a.cust_seq,a.cappl_name,a.rs_detail,a.scode1,c.ap_cname1,c.ap_cname2,a.end_date";
        ReqVal["qryOrder"] = ReqVal.TryGet("SetOrder", ReqVal.TryGet("qryOrder", ""));
        if (ReqVal.TryGet("qryOrder") != "") {
            SQL += " order by " + ReqVal.TryGet("qryOrder");
        }
        Sys.showLog(SQL);
        conn.DataTable(SQL, dt);

        //處理分頁
        int nowPage = Convert.ToInt32(Request["GoPage"] ?? "1"); //第幾頁
        int PerPageSize = Convert.ToInt32(Request["PerPage"] ?? "10"); //每頁筆數
        page = new Paging(nowPage, PerPageSize, SQL);
        page.GetPagedTable(dt);

        //分頁完再處理其他資料才不會虛耗資源
        for (int i = 0; i < page.pagedTable.Rows.Count; i++) {
            DataRow dr = page.pagedTable.Rows[i];

            //行樣式
            dr["tclass"] = (i + 1) % 2 == 1 ? "sfont9" : "lightbluetable3";

            //案號
            dr["fseq"] = Sys.formatSeq1(dr.SafeRead("seq", ""), dr.SafeRead("seq1", ""), "", Sys.GetSession("seBranch"), Sys.GetSession("dept"));
            if (dr.SafeRead("end_date", "") != "") {
                dr["end_star"] = "<font color=red>*</font>";
            }

            SQL = "select sc_name from scode where scode = '" + dr["scode1"] + "'";
            using (SqlDataReader dr0 = cnn.ExecuteReader(SQL)) {
                if (dr0.Read()) {
                    dr["lscode"] = dr0.SafeRead("sc_name", "");
                }
            }
        }

        dataRepeater.DataSource = page.pagedTable;
        dataRepeater.DataBind();
    }

    //管制期限
    protected void dataRepeater_ItemDataBound(object sender, RepeaterItemEventArgs e) {
        if ((e.Item.ItemType == ListItemType.Item) || (e.Item.ItemType == ListItemType.AlternatingItem)) {
            string rs_no = DataBinder.Eval(e.Item.DataItem, "rs_no").ToString();

            Repeater ctrlRpt = (Repeater)e.Item.FindControl("ctrlRepeater");
            if ((ctrlRpt != null)) {
                DataTable dtDtl = new DataTable();
                SQL = "select ctrl_type,ctrl_date,code_name,''tcolor ";
                SQL += "  from ctrl_dmt a inner join cust_code b on a.ctrl_type = b.cust_code ";
                SQL += " where rs_no = '" + rs_no + "'";
                SQL += "   and b.code_type = 'CT'";
                SQL += " order by ctrl_date ";
                conn.DataTable(SQL, dtDtl);

                for (int i = 0; i < dtDtl.Rows.Count; i++) {
                    DataRow dr = dtDtl.Rows[i];

                    //管制顏色
                    string tcolor = Sys.getSetting(Sys.GetSession("dept"), "1", Util.parseDBDate(dr.SafeRead("ctrl_date", ""), "yyyy/M/d"));
                    if (tcolor == "red") {
                        dr["tcolor"] = tcolor;
                    } else {
                        dr["tcolor"] = "black";
                    }
                }
                ctrlRpt.DataSource = dtDtl;
                ctrlRpt.DataBind();
            }
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

<form style="margin:0;" id="regPage" name="regPage" method="post">
    <%#page.GetHiddenText("GoPage,PerPage,SetOrder,chktest")%>
    <div id="divPaging" style="display:<%#page.totRow==0?"none":""%>">
    <TABLE border=0 cellspacing=1 cellpadding=0 width="98%" align="center">
	    <tr>
		    <td colspan=2 align=center>
			    <font size="2" color="#3f8eba">
				    第<font color="red"><span id="NowPage"><%#page.nowPage%></span>/<span id="TotPage"><%#page.totPage%></span></font>頁
				    | 資料共<font color="red"><span id="TotRec"><%#page.totRow%></span></font>筆
				    | 跳至第
				    <select id="GoPage" name="GoPage" style="color:#FF0000"><%#page.GetPageList()%></select>
				    頁
				    <span id="PageUp" style="display:<%#page.nowPage>1?"":"none"%>">| <a href="javascript:void(0)" class="pgU" v1="<%#page.nowPage-1%>">上一頁</a></span>
				    <span id="PageDown" style="display:<%#page.nowPage<page.totPage?"":"none"%>">| <a href="javascript:void(0)" class="pgD" v1="<%#page.nowPage+1%>">下一頁</a></span>
				    | 每頁筆數:
				    <select id="PerPage" name="PerPage" style="color:#FF0000">
					    <option value="10" <%#page.perPage==10?"selected":""%>>10</option>
					    <option value="20" <%#page.perPage==20?"selected":""%>>20</option>
					    <option value="30" <%#page.perPage==30?"selected":""%>>30</option>
					    <option value="100" <%#page.perPage==100?"selected":""%>>100</option>
					    <option value="300" <%#page.perPage==300?"selected":""%>>300</option>
					    <option value="500" <%#page.perPage==500?"selected":""%>>500</option>
					    <option value="1000" <%#page.perPage==1000?"selected":""%>>1000</option>
				    </select>
                    <input type="hidden" name="SetOrder" id="SetOrder" value="<%#ReqVal.TryGet("qryOrder")%>" />
			    </font><%#DebugStr%>
		    </td>
	    </tr>
    </TABLE>
    </div>
</form>

<div align="center" id="noData" style="display:<%#page.totRow==0?"":"none"%>">
	<font color="red">=== 目前無資料 ===</font>
</div>

<form style="margin:0;" id="reg" name="reg" method="post">
<asp:Repeater id="dataRepeater" runat="server" OnItemDataBound="dataRepeater_ItemDataBound">
<HeaderTemplate>
    <TABLE border=0 cellspacing=1 cellpadding=0 width="98%" align="center">
    <%#rptTitle%>
    </TABLE>
    <table style="display:<%#page.totRow==0?"none":""%>" border="0" class="bluetable" cellspacing="1" cellpadding="2" width="98%" align="center" id="dataList">
	    <thead>
            <Tr align="center">
		        <td class=lightbluetable nowrap><u class="setOdr" v1="a.seq,a.step_grade">本所編號</u></td>
		        <td class=lightbluetable nowrap>進度</td>
		        <td class=lightbluetable >案件名稱</td>
		        <td class=lightbluetable ><u class="setOdr" v1="ap_cname,a.seq">客戶</u></td>
		        <td class=lightbluetable nowrap><u class="setOdr" v1="scode1,ctrl_date">營洽</u></td>
		        <td class=lightbluetable >進度內容</td>
		        <td class=lightbluetable nowrap><u class="setOdr" v1="ctrl_date,a.seq">管制期限</u></td>
            </Tr>
	    </thead>
	    <tbody>
</HeaderTemplate>
			<ItemTemplate>
		        <tr class="<%#Eval("tclass")%>">
			        <td nowrap style="cursor: pointer;" onmouseover="this.style.color='red'" onmouseout="this.style.color='black'" onclick="CapplClick('<%#Eval("seq")%>','<%#Eval("seq1")%>')">
                        <%#Eval("end_star")%><%#Eval("fseq")%>
			        </td>
		            <td align="center" nowrap style="cursor: pointer;" onmouseover="this.style.color='red'" onmouseout="this.style.color='black'" onclick="StepClick('<%#Eval("seq")%>','<%#Eval("seq1")%>')">
                        <%#Eval("step_grade")%>
		            </td>
			        <td align="left"><%#Eval("cappl_name")%></td>
		            <td align="left" nowrap style="cursor: pointer;" onmouseover="this.style.color='red'" onmouseout="this.style.color='black'" onclick="CustClick('<%#Eval("cust_area")%>','<%#Eval("cust_seq")%>')">
                        <%#Eval("ap_cname")%>
		            </td>
			        <td align="center"><%#Eval("lscode")%></td>
			        <td align="center"><%#Eval("rs_detail")%></td>
	                <asp:Repeater id="ctrlRepeater" runat="server">
                        <ItemTemplate>
                        <asp:Panel runat="server" Visible='<%#Container.ItemIndex != 0 %>'><!--第1筆期限顯示在上一層,其餘期限顯示在下層(要補前面的空格)-->
			                <tr class="<%#DataBinder.Eval(((RepeaterItem)Container.Parent.Parent).DataItem, "tclass")%>"><td></td><td></td><td></td><td></td><td></td><td></td>
                        </asp:Panel>
                        <td nowrap>
                            <font color="<%#Eval("tcolor")%>"><%#Eval("code_name").ToString().Left(2)%>&nbsp;<%#Eval("ctrl_date","{0:d}")%>
                        </td>
                        </ItemTemplate>
			        </asp:Repeater>
				</tr>
			</ItemTemplate>
<FooterTemplate>
	    </tbody>
    </table>
    <BR>
    <table border="0" width="100%" cellspacing="0" cellpadding="0">
		<tr class="FormName"><td>
			<div align="left">
			備註:<br>
			◎本所編號前有　<font color=red size=2>' * '</font>　符號者，表該案件已結案!!<br>
			</div>
		</td></tr>
	</table>
</FooterTemplate>
</asp:Repeater>

    <%#DebugStr%>
</form>

<div id="dialog"></div>

</body>
</html>

<script language="javascript" type="text/javascript">
    $(function () {
        if (window.parent.tt !== undefined) {
            window.parent.tt.rows = "100%,0%";
        }

        $(".Lock").lock();
        $("input.dateField").datepick();
    });
    //執行查詢
    function goSearch() {
        $("#regPage").submit();
    };
    //////////////////////
    //案件主檔查詢
    function CapplClick(pseq, pseq1) {
        window.showModalDialog(getRootPath() + "/brt5m/brt15ShowFP.aspx?prgid=<%=prgid%>&seq=" + pseq + "&seq1=" + pseq1 + "&submittask=Q", "", "dialogHeight: 540px; dialogWidth: 800px; center: Yes;resizable: No; status: No;scrollbars:yes");
    }

    //案件進度查詢
    function StepClick(pseq, pseq1) {
        window.open(getRootPath() + "/brtam/brta61_Edit.aspx?submitTask=Q&qtype=N&prgid=<%=prgid%>&closewin=Y&winact=1&aseq=" + pseq + "&aseq1=" + pseq1, "myWindowOneN", "width=900 height=700 top=40 left=80 toolbar=no, menubar=no, location=no, directories=no resizeable=no status=no scrollbars=yes");
    }

    function CustClick(pcust_area, pcust_seq) {
        window.showModalDialog(getRootPath() + "/cust/cust11_edit.aspx?prgid=<%=prgid%>&submitTask=Q&hright=3&gs_dept=<%=Session["dept"]%>&cust_area=" + pcust_area + "&cust_seq=" + pcust_seq, "", "dialogHeight: 520px; dialogWidth: 800px; center: Yes;resizable: No; status: No;scrollbars=yes");
    }
</script>