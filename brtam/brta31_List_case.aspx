<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<script runat="server">
    protected string HTProgCap = "案件交辦單號清單";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "brta31" ?? "";//功能權限代碼
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";

    protected string SQL = "";
    protected object objResult = null;

    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected Paging page = null;

    protected string submitTask = "";

    DBHelper conn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    private void Page_Unload(System.Object sender, System.EventArgs e) {
        if (conn != null) conn.Dispose();
    }

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        submitTask = ReqVal.TryGet("submittask").ToUpper();

        conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");

        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        HTProgCap = myToken.Title + "-官收未銷管法定查詢";
        DebugStr = myToken.DebugStr;
        if (HTProgRight >= 0) {
            QueryData();

            this.DataBind();
        }
    }

    private void QueryData() {
        SQL = "SELECT a.case_no,a.in_scode,a.in_no,a.service+a.add_service as service,a.fees+a.add_fees as fees";
        SQL += ",b.appl_name,b.class,b.class_count,a.Arcase,a.Ar_mark,isnull(a.discount,0) as discount";
        SQL += ",a.case_num,a.stat_code, a.cust_area, a.cust_seq,a.Discount_chk,a.gs_fees,a.arcase_type,a.arcase_class,d.agt_no";
        SQL += ",(select agt_name from agt where agt_no=d.agt_no) as agt_name ";
        SQL += ",(select treceipt from agt where agt_no=d.agt_no) as receipt ";
        SQL += ",(select rtrim(ap_cname1) from apcust where cust_area=a.cust_area and cust_seq=a.cust_seq) as cust_name";
        SQL += ",(SELECT rs_detail FROM code_br WHERE rs_type=a.arcase_type and rs_code = a.arcase AND dept= 'T' AND cr='Y') AS case_name";
        SQL += ",(SELECT rs_class FROM code_br WHERE rs_code = a.arcase AND dept = 'T' AND cr = 'Y' and no_code='N' and a.arcase_type=rs_type) AS Ar_form ";
        SQL += ",(SELECT mark FROM code_br WHERE rs_code = a.arcase AND dept = 'T' AND cr = 'Y' and no_code='N' and a.arcase_type=rs_type) AS codemark ";
        SQL += " FROM case_dmt a INNER JOIN dmt b ON a.seq = b.seq AND a.seq1=b.seq1";
        SQL += " INNER JOIN dmt_temp d on a.in_no=d.in_no and d.case_sqlno=0 ";
        SQL += " LEFT OUTER JOIN case_fee c ON a.arcase = c.rs_code";
        SQL += " AND (c.dept = 'T') AND (c.country = 'T') AND (GETDATE() BETWEEN c.beg_date AND c.end_date)";
        SQL += " WHERE (case_no is not null and case_no<>'') and (a.mark<>'D' and a.mark<>'X')";
        if (ReqVal.TryGet("seq") != "") SQL += " AND a.seq='" + ReqVal.TryGet("seq") + "'";
        if (ReqVal.TryGet("seq1") != "") SQL += " AND a.seq1='" + ReqVal.TryGet("seq1") + "'";
        if (ReqVal.TryGet("cust_area") != "") SQL += " AND a.cust_area='" + ReqVal.TryGet("cust_area") + "'";
        if (ReqVal.TryGet("cust_seq") != "") SQL += " AND a.cust_seq='" + ReqVal.TryGet("cust_seq") + "'";
        if (ReqVal.TryGet("case_no") != "") SQL += " AND a.case_no='" + ReqVal.TryGet("case_no") + "'";
        SQL += " Order by a.case_no desc";

        DataTable dt = new DataTable();
        conn.DataTable(SQL, dt);

        //處理分頁
        int nowPage = Convert.ToInt32(Request["GoPage"] ?? "1"); //第幾頁
        int PerPageSize = Convert.ToInt32(Request["PerPage"] ?? "30"); //每頁筆數
        page = new Paging(nowPage, PerPageSize, SQL);
        page.GetPagedTable(dt);

        //分頁完再處理其他資料才不會虛耗資源
        for (int i = 0; i < page.pagedTable.Rows.Count; i++) {
            DataRow dr = page.pagedTable.Rows[i];
        }

        dataRepeater.DataSource = page.pagedTable;
        dataRepeater.DataBind();
    }

    protected string GetClickFunc(RepeaterItem Container) {
        //2006/5/27配合爭救案系統，檢查爭救案性如已將辦專案室提醒程序是否還要發文
        string opt_stat = "";
        if (Eval("codemark").ToString() == "B") {
            SQL = "select opt_stat from step_dmt where branch='" + Session["seBranch"] + "' and seq=" + Request["seq"] + " and seq1='" + Request["seq1"] + "' and case_no='" + Eval("case_no") + "' and cg='C' and rs='R' ";
            opt_stat = conn.getString(SQL);
        }

        SQL = "select form_name from cust_code where code_type='company' and cust_code='" + Eval("receipt") + "'";
        string receipt_name = conn.getString(SQL);

        if (submitTask != "Q") {
            return "style=\"cursor:pointer;\" onmouseover=\"this.style.color='red'\" onmouseout=\"this.style.color='black'\" onclick=\"case_no_Click('" + Eval("case_no") + "','" + opt_stat + "','" + Eval("agt_no") + "','" + Eval("agt_name") + "','" + receipt_name + "')\"";
        }
        return "";
    }

    protected string GetCaseLink(RepeaterItem Container) {
        string arcase_type = Eval("arcase_type").ToString();
        string in_no = Eval("in_no").ToString();
        string in_scode = Eval("in_scode").ToString();
        string appl_name = Eval("appl_name").ToString().Left(20);

        if (arcase_type != "") {
            return "<a href=\"" + Sys.getCaseDmt11Aspx(prgid, in_no, in_scode, "Show") + "\">" + appl_name + "</a>";
        } else {
            return appl_name;
        }
    }
</script>
<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title><%=HTProgCap%></title>
<uc1:head_inc_form runat="server" ID="head_inc_form" />
</head>

<body onload="window.focus();">
<table cellspacing="1" cellpadding="0" width="98%" border="0">
    <tr>
        <td class="text9" nowrap="nowrap">&nbsp;【<%=HTProgCode%><%=HTProgCap%>】</td>
        <td class="FormLink" valign="top" align="right" nowrap="nowrap">
            <a class="imgCls" href="javascript:void(0);" >[關閉視窗]</a>
        </td>
    </tr>
    <tr>
        <td colspan="2"><hr class="style-one"/></td>
    </tr>
</table>
<form id="regPage" name="regPage" method="post">
    <%#page.GetHiddenText("GoPage,PerPage,SetOrder,chktest")%>
    <div id="divPaging" style="display:<%#page.totRow==0?"none":""%>">
    <TABLE border=0 cellspacing=1 cellpadding=0 width="98%" align="center">
        <tr>
            <td colspan=2 align=center>
                <font size="2" color="#3f8eba">
                第<font color="red"><span id="NowPage"><%#page.nowPage%></span>/<span id="TotPage"><%#page.totPage%></span></font>頁
                | 資料共 <font color="red"><span id="TotRec"><%#page.totRow%></span></font> 筆
                | 跳至第<select id="GoPage" name="GoPage" style="color:#FF0000"><%#page.GetPageList()%></select>頁
                <span id="PageUp" style="display:<%#page.nowPage>1?"":"none"%>">| <a href="javascript:void(0)" class="pgU" v1="<%#page.nowPage-1%>">上一頁</a></span>
                <span id="PageDown" style="display:<%#page.nowPage<page.totPage?"":"none"%>">| <a href="javascript:void(0)" class="pgD" v1="<%#page.nowPage+1%>">下一頁</a></span>
                | 每頁筆數:
                <select id="PerPage" name="PerPage" style="color:#FF0000">
                 <option value="10" <%#page.perPage==10?"selected":""%>>10</option>
                 <option value="20" <%#page.perPage==20?"selected":""%>>20</option>
                 <option value="30" <%#page.perPage==30?"selected":""%>>30</option>
                 <option value="30" <%#page.perPage==40?"selected":""%>>40</option>
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

    <asp:Repeater id="dataRepeater" runat="server">
    <HeaderTemplate>
        <table style="display:<%#page.totRow==0?"none":""%>" border="0" class="bluetable" cellspacing="1" cellpadding="2" width="98%" align="center" id="dataList">
	        <thead>
                <TR align="center">
                    <td class="lightbluetable">交辦單號</td>
		            <td class="lightbluetable">客戶名稱</td>
		            <td class="lightbluetable">案件名稱</td>	
		            <td class="lightbluetable">類別</td>
		            <td class="lightbluetable">案性</td>
		            <td class="lightbluetable">已支出<BR>規費</td>
		            <td class="lightbluetable">規費</td>
		            <td class="lightbluetable">服務費</td>
		            <td class="lightbluetable">合計</td>
		            <td class="lightbluetable">折扣</td>
	            </TR>
	        </thead>
	        <tbody>
    </HeaderTemplate>
			    <ItemTemplate>
                    <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>" align="center">
		                <td class="whitetablebg" align="center" <%#GetClickFunc(Container)%>>
			                <%#Eval("case_no")%>
                            <input type=hidden id="incode_<%#(Container.ItemIndex+1)%>" name="incode_<%#(Container.ItemIndex+1)%>" value="<%#Eval("in_scode")%>">
		                    <input type=hidden id="inno_<%#(Container.ItemIndex+1)%>" name="inno_<%#(Container.ItemIndex+1)%>" value="<%#Eval("in_no")%>">
		                    <input type=hidden id="case_no_<%#(Container.ItemIndex+1)%>" name="case_no_<%#(Container.ItemIndex+1)%>" value="<%#Eval("case_no")%>">
		                </td>
		                <td class="whitetablebg" align="center"><%#Eval("cust_name").ToString().Left(5)%></td> 
		                <td class="whitetablebg" align="center"><%#GetCaseLink(Container)%></td>
		                <td class="whitetablebg" align="center">(共<%#Eval("class_count")%>類)<%#Eval("Class")%></td>
		                <td class="whitetablebg" align="center"><%#Eval("case_name")%></td>
		                <td class="whitetablebg" align="center"><%#Eval("gs_fees")%></td>
		                <td class="whitetablebg" align="center"><%#Eval("fees")%></td>
		                <td class="whitetablebg" align="center"><%#Eval("service")%></td>
		                <td class="whitetablebg" align="center"><%#Convert.ToInt32(Eval("Service"))+Convert.ToInt32(Eval("fees"))%></td>
		                <td class="whitetablebg" align="center">
                            <%#(Convert.ToInt32(Eval("discount"))>0?Eval("discount")+"%":"")%>
                            <%#(Eval("discount").ToString()=="Y"?"(*)":"")%>
		                </td>

		            </tr>
			    </ItemTemplate>
    <FooterTemplate>
	        </tbody>
        </table>
    <br>
    <p style="text-align:center;display:<%#page.totRow==0?"none":""%>">
    </p>
</FooterTemplate>
</asp:Repeater>

<div id="dialog"></div>

</body>
</html>

<script language="javascript" type="text/javascript">
    $(function () {
        if (window.parent.tt !== undefined) {
            window.parent.tt.rows = "100%,0%";
        }
    });

    //執行查詢
    function goSearch() {
        $("#regPage").submit();
    };

    //帶回交辦單號
    function case_no_Click(x1, a, b, c, d) {//x1:case_no,a:opt_stat,b:agt_no,c:agt_nonm,d:receipt_name
        if ("<%=prgid%>" != "brta81") {//爭救案官發回條確認進入，不用提醒，因對應延期第一次發文且有規費支出
            if (a == "Y") {//爭救案已交辦
                if (confirm("該交辦案件已交辦專案室，確定要自行發文？")==false) {
                    return false;
                }
            }
        }
        //2008/1/14聖島四合一，檢查交辦與發文出名代理人不一樣，顯示提示訊息
        if ($("#rs_agt_no").val() != "") {
            if ($("#rs_agt_no").val() != b) {
                var answer = "該交辦案件之出名代理人「" + d + "_" + c + "」與發文出名代理人「" + $("#rs_agt_nonm").val() + "」不同，是否確定要發文？(如需修改出名代理人請至交辦維護作業)";
                if (confirm(answer) == false) {
                    return false;
                }
            }
        }
        var casenum = $("#casenum").val();
        //檢查所點選交辦之出名代理人是否相同
        for (var w = 1; w <= CInt(casenum) ; w++) {
            var tagt_no = $("#case_agt_no_" + w, window.opener.document).val();
            if (tagt_no != b) {
                alert("同一件官發對應交辦之出名代理人必須相同！");
                return false;
            }
        }
        $("#case_no_" + casenum, window.opener.document).val(x1).triggerHandler("blur")
        window.close();
    }
</script>
