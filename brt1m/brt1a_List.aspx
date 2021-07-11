<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Linq"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<script runat="server">
    protected string HTProgCap = "國內爭救案交辦專案室抽件作業";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string HTProgPrefix = HttpContext.Current.Request["prgid"] ?? "";//程式檔名前綴
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";

    protected string SQL = "";
    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected Paging page = null;

    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";
    protected string FormName = "";
    
    DBHelper conn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    DBHelper optconn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    private void Page_Unload(System.Object sender, System.EventArgs e) {
        if (conn != null) conn.Dispose();
        if (optconn != null) optconn.Dispose();
    }

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
        optconn = new DBHelper(Conn.optK).Debug(Request["chkTest"] == "TEST");
        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");

        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        HTProgCap = myToken.Title;
        DebugStr = myToken.DebugStr;
        if (HTProgRight >= 0) {
            PageLayout();
            QueryData();
            this.DataBind();
        }
    }

    private void PageLayout() {
        StrFormBtnTop += "<a class=\"imgRefresh\" href=\"javascript:void(0);\" >[重新整理]</a>";
        StrFormBtnTop += "<a href='" + HTProgPrefix + ".aspx?prgid=" + prgid + "'>[回查詢畫面]</a>";
    }

    private void QueryData() {
        DataTable dt = new DataTable();
        
		SQL = "SELECT a.opt_sqlno,a.Case_no,a.seq,a.seq1,RTRIM(ISNULL(b.ap_cname1, '')) + RTRIM(ISNULL(b.ap_cname2, '')) AS cust_name ";
		SQL+=",a.appl_name,a.class,a.arcase_name,a.service,a.fees,a.oth_money,a.Bmark,a.pr_scode_name,a.opt_in_date,a.ctrl_date,a.gs_date,a.Bstat_code ";
		SQL+=",a.cust_seq,a.cust_area,a.arcase_type,a.Bseq,a.Bseq1 ";
		SQL+=",(select code_name from cust_code as c where code_type='Ostat_code' and a.Bstat_code=c.cust_code) as dowhat_name ";
		SQL+=",(select sc_name from sysctrl.dbo.scode where scode=a.in_scode) in_scodenm ";
        SQL += ",''fseq,''in_no,''in_scode ";
		SQL+="FROM vbr_opt a ";
		SQL+="inner join "+Sys.tdbname(Sys.GetSession("seBranch"))+".apcust as b on a.cust_area=b.cust_area and a.cust_seq=b.cust_seq " ;
		SQL+="where a.Bmark in ('N') and (a.case_no is not null) and (a.Confirm_date is not null) ";
        if (ReqVal.TryGet("Qryscode") != ""&&ReqVal.TryGet("Qryscode") != "*") {
            SQL += " and a.in_scode = '" + Request["Qryscode"] + "'";
        }
        if (ReqVal.TryGet("qryBranch") != "") {
            SQL += " and a.Branch = '" + Request["qryBranch"] + "'";
        }
        if (ReqVal.TryGet("qrySeq") != "") {
            SQL += " and a.BSeq = '" + Request["qrySeq"] + "'";
        }
        if (ReqVal.TryGet("qrySeq1") != "") {
            SQL += " and a.BSeq1 = '" + Request["qrySeq1"] + "'";
        }
        if (ReqVal.TryGet("Qrycase_no") != "") {
            SQL += " and a.Case_no = '" + Request["Qrycase_no"] + "'";
        }
        if (ReqVal.TryGet("ChangeDate") != "") {
            if (ReqVal.TryGet("QryCustDateS") != "") {
            SQL += " and a."+Request["ChangeDate"]+" >= '" + Request["QryCustDateS"] + "'";
            }
            if (ReqVal.TryGet("QryCustDateE") != "") {
            SQL += " and a."+Request["ChangeDate"]+" <= '" + Request["QryCustDateE"] + "'";
            }
        }
        if (ReqVal.TryGet("QryArcase") != "") {
            SQL += " and a.arcase = '" + Request["QryArcase"] + "'";
        }
        SQL += " order by a.Bseq,a.Bseq1";
        //Sys.showLog(SQL);
        optconn.DataTable(SQL, dt);

        //處理分頁
        int nowPage = Convert.ToInt32(Request["GoPage"] ?? "1"); //第幾頁
        int PerPageSize = Convert.ToInt32(Request["PerPage"] ?? "10"); //每頁筆數
        page = new Paging(nowPage, PerPageSize, SQL);
        page.GetPagedTable(dt);

        //分頁完再處理其他資料才不會虛耗資源
        for (int i = 0; i < page.pagedTable.Rows.Count; i++) {
            DataRow dr=page.pagedTable.Rows[i];
            
            //案號
            dr["fseq"] = Sys.formatSeq1(dr.SafeRead("seq", ""), dr.SafeRead("seq1", ""), "", Sys.GetSession("seBranch"), Sys.GetSession("dept"));

            SQL = "Select in_scode,in_no,arcase_class,arcase ";
            SQL += ",(SELECT rs_class FROM code_br WHERE rs_code = a.arcase AND dept = 'T' AND cr = 'Y' AND no_code='N' and rs_type=a.arcase_type) AS Ar_form ";
            SQL += "from case_dmt as a where case_no='" + dr["Case_no"] + "'";
            using (SqlDataReader dr0 = conn.ExecuteReader(SQL)) {
                if (dr0.Read()) {
                    dr["in_no"] = dr0.SafeRead("in_no", "");
                    dr["in_scode"] = dr0.SafeRead("in_scode", "");
                }
            }
            
            if(dr.SafeRead("dowhat_name","")==""){
                dr["dowhat_name"]="未收件";
            }
        }

        dataRepeater.DataSource = page.pagedTable;
        dataRepeater.DataBind();
    }

    //退回記錄
    protected string GetXXLink(RepeaterItem Container) {
        string todoBack = "N";
        SQL = "select * from todo_opt ";
        SQL += "where case_no='" + Eval("case_no") + "' and branch='" + Session["seBranch"] + "' and syscode='" + Session["seBranch"] + "TBRT' ";
        SQL += " and apcode='brt1a' and dowhat='DT' and job_status='XX'";
        using (SqlDataReader dr0 = optconn.ExecuteReader(SQL)) {
            if (dr0.Read()) {
                todoBack = "Y";
            }
        }

        string todo_link = "~/brt1m/Brt18_ListA.aspx?Case_no=" + Eval("case_no") + "&Branch=" + Session["seBranch"] + "&prgid=" + prgid;
        todo_link += "&fseq=" + Eval("fseq") + "&scode_name=" + Eval("in_scodenm") + "&in_scode=" + Eval("in_scode");

        if (todoBack == "Y")
            return "<a href='" + Page.ResolveUrl(todo_link) + "' title='查詢退回紀錄' target='Eblank'><img src='" + Page.ResolveUrl("~/images/alarm.gif") + "' style='cursor:pointer' align='absmiddle' border='0' WIDTH='14' HEIGHT='11'></a>";
        return "";
    }

    protected string GetButtonLink(RepeaterItem Container) {
        string Bstat_code = Eval("Bstat_code").ToString();

        SQL = "Select max(Tran_status) as Tran_status from cancel_opt where opt_sqlno='" + Eval("opt_sqlno") + "'";
        object objResult = optconn.ExecuteScalar(SQL);
        string Tran_status = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();

        if (Bstat_code != "YS") {
            if (Tran_status == "DT" || Tran_status == "DY") {
                return "抽件中";
            } else {
                string urlasp = Sys.getCase11Aspx(prgid, Eval("in_no").ToString(), Eval("in_scode").ToString(), "Show")
                    + "&opt_sqlno=" + Eval("opt_sqlno")
                    + "&homelist=" + Request["homelist"]
                    + "&ctrl_date=" + Eval("ctrl_date", "{0:yyyy/M/d}");
                return "<span style='cursor: pointer;color:darkblue' onmouseover='this.style.color=\"red\"' onmouseout='this.style.color=\"darkblue\"' title=" + Eval("opt_sqlno") + ">" +
                "<a href='" + urlasp + "' target='Eblank'>[抽件]</a></span>";
            }
        }
        return "";
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
    <%#page.GetHiddenText("GoPage,PerPage,SetOrder")%>
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
			    </font>
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
    <table style="display:<%#page.totRow==0?"none":""%>" border="0" class="bluetable" cellspacing="1" cellpadding="2" width="100%" align="center" id="dataList">
	    <thead>
          <tr align="left">
	        <td align="center" class="lightbluetable" rowSpan=2>交辦單號</td>
	        <td align="center" class="lightbluetable" rowSpan=2>案件編號</td>
	        <td align="center" class="lightbluetable" rowSpan=2>客戶名稱</td>
	        <td align="center" class="lightbluetable" rowSpan=2>案件名稱</td>
	        <td align="center" class="lightbluetable" rowSpan=2>類別</td>
	        <td align="center" class="lightbluetable">案性</td>
	        <td align="center" class="lightbluetable">服務費</td>
	        <td align="center" class="lightbluetable">規費</td>
	        <td align="center" class="lightbluetable">轉帳費用</td>
	        <td align="center" class="lightbluetable" rowSpan=2>狀態</td>
	        <td align="center" class="lightbluetable" rowSpan=2>作業</td>
          </tr>
          <tr align="left">
	        <td align="center" class="lightbluetable">承辦人員</td>
	        <td align="center" class="lightbluetable">交辦日期</td>
	        <td align="center" class="lightbluetable">預計完成日期</td>
	        <td align="center" class="lightbluetable">發文日期</td>
          </tr>
	    </thead>
	    <tbody>
</HeaderTemplate>
			<ItemTemplate>
	            <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>">
	                <td class="whitetablebg" rowSpan=2 align="center">
                        <%#GetXXLink(Container)%>
		                <%#Eval("case_no")%>
	                </td>
		            <td class="whitetablebg" rowSpan=2><%#Eval("fseq")%></td>
		            <td class="whitetablebg" rowSpan=2><%#Eval("cust_name").ToString().Left(5)%></td>
		            <td class="whitetablebg" rowSpan=2><%#Eval("appl_name").ToString().CutData(20)%></td>
		            <td class="whitetablebg" align="center" rowSpan=2><%#Eval("class")%></td>
		            <td class="whitetablebg" align="center"><%#Eval("arcase_name")%></td>
		            <td class="whitetablebg" align="center"><%#Eval("service")%></td>
		            <td class="whitetablebg" align="center"><%#Eval("fees")%></td>
		            <td class="whitetablebg" align="center"><%#Eval("oth_money")%></td>
		            <td class="whitetablebg" rowSpan=2 align="center" style="color:blue" title="<%#Eval("opt_sqlno")%>"><%#Eval("dowhat_name")%></a></td>
		            <td class="whitetablebg" rowSpan=2 align="center"><%#GetButtonLink(Container)%></td>
                  </tr>
                  <tr>
	                <td class="whitetablebg" align="center"><%#Eval("pr_scode_name","{0:yyyy/M/d}")%>&nbsp;</td>
	                <td class="whitetablebg" align="center"><%#Eval("opt_in_date","{0:yyyy/M/d}")%></td>
	                <td class="whitetablebg" align="center"><%#Eval("ctrl_date","{0:yyyy/M/d}")%></td>
	                <td class="whitetablebg" align="center"><%#Eval("gs_date","{0:yyyy/M/d}")%></td>
                  </tr>
			</ItemTemplate>
<FooterTemplate>
	    </tbody>
    </table>
</FooterTemplate>
</asp:Repeater>
    <BR>
	備註:<br>
	1.已發文不可抽件<br>
	2.交辦單號前的「<img src="../images/alarm.gif" style="cursor:pointer" align="absmiddle"  border="0" WIDTH="14" HEIGHT="11">」表示被<font color="red">退回</font>狀態，可按下該圖示查詢相關退回紀錄
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
    function case_no_Click(x1, tlink) {
        if (x1 == "Y") {
            alert("該交辦案件已交辦專案室承辦，煩請於修改後通知專案室更新資料！");
        }
        if (x1 == "S") {
            if (!confirm("該交辦案件專案室已發文，確定要修改資料？")) {
                return false;
            }
        }
        window.parent.Eblank.location.href = tlink;
    }
</script>