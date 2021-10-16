<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<script runat="server">
    protected string HTProgCap = "國內爭救案交辦查詢";// HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "Brt19";//程式檔名前綴
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

    protected string submitTask = "";
    protected string homelist = "";

    DataTable dt = new DataTable();
    DBHelper conn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    DBHelper connopt = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    DBHelper cnn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    private void Page_Unload(System.Object sender, System.EventArgs e) {
        if (conn != null) conn.Dispose();
        if (connopt != null) connopt.Dispose();
        if (cnn != null) cnn.Dispose();
    }
    
    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
        connopt = new DBHelper(Conn.optK).Debug(Request["chkTest"] == "TEST");
        cnn = new DBHelper(Conn.Sysctrl).Debug(Request["chkTest"] == "TEST");

        ReqVal = Util.GetRequestParam(Context,Request["chkTest"] == "TEST");
        submitTask = Request["submitTask"] ?? "";

        homelist = ReqVal.TryGet("homelist").ToLower();

        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        HTProgCap = myToken.Title;
        DebugStr = myToken.DebugStr;
        if (HTProgRight >= 0) {
            QueryData();
            PageLayout();

            this.DataBind();
        }
    }

    private void PageLayout() {
        StrFormBtnTop += "<a class=\"imgRefresh\" href=\"javascript:void(0);\" >[重新整理]</a>";
        StrFormBtnTop += "<a href=\"" + HTProgPrefix + ".aspx?prgid=" + prgid + "\" >[回查詢]</a>";

        FormName = "備註:<br>\n";
        FormName += "專案室未發文才能編修法定期限";
    }

    private void QueryData() {
        SQL = "SELECT a.opt_sqlno,a.Case_no,a.seq,a.seq1,RTRIM(ISNULL(b.ap_cname1, '')) + RTRIM(ISNULL(b.ap_cname2, '')) AS cust_name";
        SQL += " ,a.appl_name,a.class,a.arcase_name,a.service,a.fees,a.oth_money,a.Bmark,a.pr_scode_name,a.opt_in_date,a.ctrl_date,a.gs_date";
        SQL += " ,(select code_name from cust_code as c where code_type='Ostat_code' and a.Bstat_code=c.cust_code) as dowhat_name,a.bstat_code,Last_date,a.Bcase_date";
        SQL += ",''fseq ";
        SQL += " FROM vbr_opt a";
        SQL += " inner join " + Sys.tdbname(Sys.GetSession("seBranch")) + ".apcust as b on a.cust_area=b.cust_area and a.cust_seq=b.cust_seq";
        SQL += " where a.Bmark in ('N') and (a.case_no is not null)";

        if (ReqVal.TryGet("Qryscode") != "" && ReqVal.TryGet("Qryscode") != "*") {
            SQL += "AND a.in_scode ='" + Request["Qryscode"] + "' ";
        }

        if (ReqVal.TryGet("qryBranch") != "") {
            SQL += "AND a.Branch ='" + Request["qryBranch"] + "' ";
        }

        if (ReqVal.TryGet("qrySeq") != "") {
            SQL += "AND a.BSeq ='" + Request["qrySeq"] + "' ";
        }

        if (ReqVal.TryGet("qrySeq1") != "") {
            SQL += "AND a.BSeq1 ='" + Request["qrySeq1"] + "' ";
        }

        if (ReqVal.TryGet("Qrycase_no") != "") {
            SQL += "AND a.case_no ='" + Request["Qrycase_no"] + "' ";
        }

        if (ReqVal.TryGet("QryCust_area") != "") {
            SQL += "AND a.Cust_area ='" + Request["QryCust_area"] + "' ";
        }

        if (ReqVal.TryGet("QryCust_seq") != "") {
            SQL += "AND a.Cust_seq ='" + Request["QryCust_seq"] + "' ";
        }

        if (ReqVal.TryGet("QryCust_name") != "") {
            SQL += "and ( b.ap_cname1 like'%" + Request["QryCust_name"] + "%' or b.ap_cname2 like'%" + Request["QryCust_name"] + "%') ";
        }

        if (ReqVal.TryGet("ChangeDate") != "") {
            if (ReqVal.TryGet("QryCustDateS") != "") {
                SQL += "and a." + Request["ChangeDate"] + " >= '" + Request["QryCustDateS"] + "' ";
            }
            if (ReqVal.TryGet("QryCustDateE") != "") {
                SQL += "and a." + Request["ChangeDate"] + " <= '" + Request["QryCustDateE"] + "' ";
            }
        }

        if (ReqVal.TryGet("QryArcase") != "") {
            SQL += "AND a.arcase ='" + Request["QryArcase"] + "' ";
        }

        ReqVal["qryOrder"] = ReqVal.TryGet("SetOrder", ReqVal.TryGet("qryOrder", "a.Bseq,a.Bseq1"));
        if (ReqVal.TryGet("qryOrder") != "") {
            SQL += " order by " + ReqVal.TryGet("qryOrder");
        }
        connopt.DataTable(SQL, dt);

        //處理分頁
        int nowPage = Convert.ToInt32(Request["GoPage"] ?? "1"); //第幾頁
        int PerPageSize = Convert.ToInt32(Request["PerPage"] ?? "10"); //每頁筆數
        page = new Paging(nowPage, PerPageSize, SQL);
        page.GetPagedTable(dt);

        //分頁完再處理其他資料才不會虛耗資源
        for (int i = 0; i < page.pagedTable.Rows.Count; i++) {
            DataRow dr = page.pagedTable.Rows[i];

            dr["fseq"] = Sys.formatSeq1(dr.SafeRead("seq", ""), dr.SafeRead("seq1", ""), "", "", "");

            //狀態
            string tran_status = "";
            string tran_status_name = "";
            SQL = "Select max(Tran_status) as Tran_status";
            SQL += ",(Select code_name from cust_code as b  where b.code_type='OTran_STAT' and a.tran_status=b.cust_code) as tran_status_name";
            SQL += " from cancel_opt as a where opt_sqlno='" + dr["opt_sqlno"] + "' and tran_status<>'DN'";
            SQL += " group by a.tran_status ";
            using (SqlDataReader dr0 = connopt.ExecuteReader(SQL)) {
                if (dr0.Read()) {
                    tran_status = dr0.SafeRead("Tran_status", "");
                    tran_status_name = dr0.SafeRead("Tran_status_name", "");
                }
            }
            if (tran_status != "") {
                dr["dowhat_name"] = tran_status_name;
            }
            if (dr.SafeRead("dowhat_name", "") == "") {
                dr["dowhat_name"] = "未收件";
            }
        }

        dataRepeater.DataSource = page.pagedTable;
        dataRepeater.DataBind();
    }

    //[作業]
    protected string GetButton(RepeaterItem Container) {
        string rtn = "";
        string bstat_code = Eval("bstat_code").ToString();
        string ahref = "Brt19_Edit.aspx?prgid=" + prgid + "&opt_sqlno=" + Eval("opt_sqlno") + "&Case_no=" + Eval("Case_no") + "&submitTask=U";

        //2013/8/8修改，增加判斷專案室未發文才能編修法定期限
        if (((HTProgRight & 8) != 0) && (bstat_code != "YS" || bstat_code == "")) {
            rtn = "<br><a href=\"" + ahref + "\" target=\"Eblank\">[編修]</font>";
        }

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
					    <option value="50" <%#page.perPage==50?"selected":""%>>50</option>
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
        <table style="display:<%#page.totRow==0?"none":""%>" border="0" class="bluetable" cellspacing="1" cellpadding="2" width="98%" align="center" id="dataList">
	        <thead>
                <Tr class="lightbluetable">
	                <td align="center" rowSpan=2>交辦單號</td>	
	                <td align="center" rowSpan=2 nowrap>案件編號</td>	
	                <td align="center" rowSpan=2>客戶名稱</td>
	                <td align="center" rowSpan=2>案件名稱</td>
	                <td align="center" rowSpan=2 width="15%">類別</td>
	                <td align="center">案性</td>
	                <td align="center">服務費</td>
	                <td align="center">規費</td>
	                <td align="center">轉帳費用</td>
	                <td align="center" rowSpan=2>狀態</td>
	                <td align="center" rowSpan=2 nowrap>法定期限</td>
                </Tr>
                <Tr class="lightbluetable">
	                <td align="center">承辦人員</td>
	                <td align="center" nowrap>交辦專案室日期</td>
	                <td align="center" nowrap>預計完成日期</td>
	                <td align="center">發文日期</td>
                </Tr>
	        </thead>
	        <tbody>
    </HeaderTemplate>
			    <ItemTemplate>
 		            <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>">
		                <td rowSpan=2 align="center" title="<%#Eval("opt_sqlno")%>"><%#Eval("case_no")%>
		                <td rowSpan=2 align="center"><%#Eval("fseq")%></td>
		                <td rowSpan=2 align="left"><%#Eval("Cust_name").ToString().ToUnicode().Left(5)%></td>
		                <td rowSpan=2 align="left"><%#Eval("appl_name").ToString().CutData(20)%></td>
		                <td rowSpan=2 align="center" width="15%"><%#Eval("class")%></td>
		                <td align="center">&nbsp;<%#Eval("arcase_name")%>&nbsp;</td>
		                <td align="center">&nbsp;<%#Eval("Service")%>&nbsp;</td>
		                <td align="center">&nbsp;<%#Eval("Fees")%>&nbsp;</td>
		                <td align="center">&nbsp;<%#Eval("oth_money")%>&nbsp;</td>
		                <td rowSpan=2 align="center" style="color:blue" title="<%#Eval("opt_sqlno")%>"><%#Eval("dowhat_name")%></td>
		                <td rowSpan=2 align="center">
			                <span id="span_Slast_date_<%#(Container.ItemIndex+1)%>" style="display:">
				                <input type="text" name="oldLast_date_<%#(Container.ItemIndex+1)%>" size="10" value="<%#Eval("Last_date","{0:d}")%>" class="sedit" readonly>
				                <%#GetButton(Container)%>
			                </span>
			
			                <span id="span_last_date_<%#(Container.ItemIndex+1)%>" style="display:none">
				                <br>
				                <input type="text" name="Last_date_<%#(Container.ItemIndex+1)%>" size="10" value="<%#Eval("Last_date","{0:d}")%>" onblur="Last_dateChange(<%#(Container.ItemIndex+1)%>)" class="dateField">
				                <br>
				                <span style="cursor: pointer;color:darkblue" onmouseover="this.style.color='red'" onmouseout="this.style.color='darkblue'" onclick="Last_dateSave(<%#(Container.ItemIndex+1)%>)">[存檔]</span>
				                <span style="cursor: pointer;color:darkblue" onmouseover="this.style.color='red'" onmouseout="this.style.color='darkblue'" onclick="Last_dateResp(<%#(Container.ItemIndex+1)%>)">[取消]</span>
			                </span>	
		                </td>
				    </tr>
 		            <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>">
	                    <td align="center">&nbsp;<%#Eval("pr_scode_name")%>&nbsp;</td>
	                    <td align="center">&nbsp;<%#Eval("Bcase_date","{0:d}")%>&nbsp;</td>
	                    <td align="center">&nbsp;<%#Eval("ctrl_date","{0:d}")%>&nbsp;</td>
	                    <td align="center">&nbsp;<%#Eval("GS_date","{0:d}")%>&nbsp;</td>
                    </tr>	 
			    </ItemTemplate>
    <FooterTemplate>
	        </tbody>
        </table>
	    <BR>
        <table style="display:<%#page.totRow==0?"none":""%>" border="0" width="100%" cellspacing="0" cellpadding="0">
		    <tr class="FormName"><td><div align="left" style="color:blue"><%#FormName%></div></td></tr>
	    </table>
	    <br>
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

</script>
