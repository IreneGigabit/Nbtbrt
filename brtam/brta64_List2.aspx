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
    protected string qtype = "";

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

        qtype = ReqVal.TryGet("qtype");
        if (qtype == "2") {
            HTProgCap = "國內案延展期限稽催查詢";
        } else if (qtype == "3") {
            HTProgCap = "國內案第二期註冊費稽催查詢";
        } else if (qtype == "4") {
            HTProgCap = "國內案使用稽催查詢";
        }

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
        if (qtype == "2") StrFormBtnTop += "<a href=\"" + Page.ResolveUrl("~/brtam/brta434Print.aspx?") + Request.Form.ParseQueryString() + "\" target=\"Eblank\">[延展管制表列印]</a>\n";
        StrFormBtnTop += "<a href='" + HTProgPrefix + ".aspx?prgid=" + prgid + "'>[查詢畫面]</a>";

        string scode1nm = "全部";
        if (ReqVal.TryGet("scode1") != "") {
            SQL = "select sc_name from scode where scode='" + Request["scode1"] + "'";
            object objResult = conn.ExecuteScalar(SQL);
            scode1nm = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();
        }

        //包含結案案件
        string endcodenm = "未結案案件";
        if (ReqVal.TryGet("qendcode") == "Y") {
            endcodenm = "包含結案案件";
        }

        if (qtype == "2") {
            rptTitle += "<td>◎專用期限迄日：" + Request["sdate"] + "～" + Request["edate"] + "</td>";
        }else if(qtype == "3") {
            rptTitle += "<td>◎專用期限起日：" + Request["sdate"] + "～" + Request["edate"] + "</td>";
        } else if (qtype == "4") {
            rptTitle += "<td>◎專用期限起日：" + Request["sdate"] + "～" + Request["edate"] + "或" + Request["sdate1"] + "～" + Request["edate1"] + "</td>";
        }
        rptTitle += "<td>營洽：" + scode1nm + "</td>";
        rptTitle += "<td align=right>結案：" + endcodenm + "</td>";
    }

    private void QueryData() {
        DataTable dt = new DataTable();

        SQL = "select a.seq,a.seq1,a.appl_name,a.class_count,a.scode,a.issue_no,a.term1,a.term2,a.cust_area,a.cust_seq";
        SQL += ",(select code_name from cust_code where code_type = '" + Session["dept"] + "PAY_TIMES' and cust_code=a.pay_times) as pay_times";
        SQL += ",isnull(rtrim(b.ap_cname1),'')+isnull(rtrim(b.ap_cname2),'') as ap_cname,a.end_date";
        SQL += ",''tclass,''fseq,''end_star,''lscode,''ldate ";
        SQL += " from dmt a ";
        SQL += "inner join apcust b on a.cust_area = b.cust_area and a.cust_seq = b.cust_seq";
        SQL += " where 1=1 ";
        if (qtype == "2") {
            if (ReqVal.TryGet("sdate") != "") {
                SQL += " and a.term2>='" + ReqVal.TryGet("sdate") + "'";
            }
            if (ReqVal.TryGet("edate") != "") {
                SQL += " and a.term2<='" + ReqVal.TryGet("edate") + "'";
            }
        } else if (qtype == "3") {
            SQL += " and pay_times = '1' ";
            if (ReqVal.TryGet("sdate") != "") {
                SQL += " and a.term1>='" + ReqVal.TryGet("sdate") + "'";
            }
            if (ReqVal.TryGet("edate") != "") {
                SQL += " and a.term1<='" + ReqVal.TryGet("edate") + "'";
            }
        } else if (qtype == "4") {
            if (ReqVal.TryGet("sdate") != "") {
                if (ReqVal.TryGet("sdate1") != "") {
                    SQL += " and (a.term1 between '" + ReqVal.TryGet("sdate") + "' and '" + ReqVal.TryGet("edate") + "'";
                    SQL += " or a.term1 between '" + ReqVal.TryGet("sdate1") + "' and '" + ReqVal.TryGet("edate1") + "')";
                } else {
                    SQL += " and a.term1 between '" + ReqVal.TryGet("sdate") + "' and '" + ReqVal.TryGet("edate") + "'";
                }
            }
        }
        if (ReqVal.TryGet("scode1") != "") {
            SQL += " and a.scode='" + ReqVal.TryGet("scode1") + "'";
        }
        if (ReqVal.TryGet("cust_seq") != "") {
            SQL += " and a.cust_area='" + Session["seBranch"] + "'";
            SQL += " and a.cust_seq='" + ReqVal.TryGet("cust_seq") + "'";
        }
        //包含結案案件
        if (ReqVal.TryGet("qendcode") != "Y") {
            SQL += " and a.end_date is null";
        }

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

            SQL = "select sc_name from scode where scode = '" + dr["scode"] + "'";
            using (SqlDataReader dr0 = cnn.ExecuteReader(SQL)) {
                if (dr0.Read()) {
                    dr["lscode"] = dr0.SafeRead("sc_name", "");
                }
            }

            string ldate = "";
            if (qtype == "3") {
                //稽催日期=專用期起日+3年-1天
                ldate = Convert.ToDateTime(dr["term1"]).AddYears(3).AddDays(-1).ToShortDateString();
            } else if (qtype == "4") {
                if (Convert.ToDateTime(dr["term1"]) >= Convert.ToDateTime(ReqVal.TryGet("sdate")) && Convert.ToDateTime(dr["term1"]) <= Convert.ToDateTime(ReqVal.TryGet("edate"))) {
                    //稽催日期=專用期起日+6年-1天
                    ldate = Convert.ToDateTime(dr["term1"]).AddYears(6).AddDays(-1).ToShortDateString();
                }
                if (Convert.ToDateTime(dr["term1"]) >= Convert.ToDateTime(ReqVal.TryGet("sdate1")) && Convert.ToDateTime(dr["term1"]) <= Convert.ToDateTime(ReqVal.TryGet("edate1"))) {
                    //稽催日期=專用期起日+3年-1天
                    ldate = Convert.ToDateTime(dr["term1"]).AddYears(3).AddDays(-1).ToShortDateString();
                }
            }
            dr["ldate"] = ldate;
        }

        dataRepeater.DataSource = page.pagedTable;
        dataRepeater.DataBind();
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
<asp:Repeater id="dataRepeater" runat="server">
<HeaderTemplate>
    <TABLE border=0 cellspacing=1 cellpadding=0 width="98%" align="center">
    <%#rptTitle%>
    </TABLE>
    <table style="display:<%#page.totRow==0?"none":""%>" border="0" class="bluetable" cellspacing="1" cellpadding="2" width="98%" align="center" id="dataList">
	    <thead>
            <Tr align="center">
			    <td class=lightbluetable nowrap><u class="setOdr" v1="a.seq">本所編號</u></td>
			    <td class=lightbluetable >案件名稱</td>
			    <td class=lightbluetable nowrap>類別數</td>
			    <td class=lightbluetable ><u class="setOdr" v1="ap_cname,a.seq">客戶</u></td>
                <%if (qtype == "2") {%>
			        <td class=lightbluetable nowrap><u class="setOdr" v1="a.scode,ap_cname,a.term2">營洽</u></td>
			        <td class=lightbluetable nowrap>註冊號</td>
			        <td class=lightbluetable nowrap><u class="setOdr" v1="a.term1,a.seq">專用期限</u></td>
		        <%}else if( qtype == "3"){%>
			        <td class=lightbluetable nowrap><u class="setOdr" v1="a.scode,ap_cname,a.term2">營洽</u></td>
			        <td class=lightbluetable nowrap>註冊號</td>
			        <td class=lightbluetable nowrap>註冊費已繳</td>
			        <td class=lightbluetable nowrap><u class="setOdr" v1="a.term1,a.seq">專用期限</u></td>
			        <td class=lightbluetable nowrap>稽催日期</td>
		        <%}else if( qtype == "4"){%>
			        <td class=lightbluetable nowrap><u class="setOdr" v1="a.scode,ap_cname,a.term1">營洽</u></td>
			        <td class=lightbluetable nowrap>註冊號</td>
			        <td class=lightbluetable nowrap><u class="setOdr" v1="a.term1,a.seq">專用期限</u></td>
			        <td class=lightbluetable nowrap>稽催日期</td>
		        <%}%>

            </Tr>
	    </thead>
	    <tbody>
</HeaderTemplate>
			<ItemTemplate>
		        <tr class="<%#Eval("tclass")%>">
			        <td nowrap style="cursor: pointer;" onmouseover="this.style.color='red'" onmouseout="this.style.color='black'" onclick="CapplClick('<%#Eval("seq")%>','<%#Eval("seq1")%>')">
                        <%#Eval("end_star")%><%#Eval("fseq")%>
			        </td>
			        <td align="left"><%#Eval("appl_name")%></td>
			        <td nowrap align="center"><%#Eval("class_count")%></td>
		            <td align="left" nowrap style="cursor: pointer;" onmouseover="this.style.color='red'" onmouseout="this.style.color='black'" onclick="CustClick('<%#Eval("cust_area")%>','<%#Eval("cust_seq")%>')">
                        <%#Eval("ap_cname")%>
		            </td>
			        <td align="center"><%#Eval("lscode")%></td>
			        <td nowrap align="center"><%#Eval("issue_no")%></td>
		            <%if( qtype == "3"){%>
				        <td nowrap><%#Eval("pay_times")%></td>
			        <%}%>
			        <td nowrap align="center"><%#Eval("term1","{0:yyyy/M/d}")%>~<%#Eval("term2","{0:yyyy/M/d}")%></td>
                    <%if( qtype == "3"||qtype=="4"){%>
				        <td nowrap><%#Eval("ldate")%></td>
			        <%}%>
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

    function CustClick(pcust_area, pcust_seq) {
        //***todo
        window.showModalDialog(getRootPath() + "/cust/cust11_mod.asp?prgid=<%=prgid%>&modify=Q&hright=3&gs_dept=<%=Session["dept"]%>&cust_area=" + pcust_area + "&cust_seq=" + pcust_seq, "", "dialogHeight: 520px; dialogWidth: 800px; center: Yes;resizable: No; status: No;scrollbars=yes");
    }
</script>