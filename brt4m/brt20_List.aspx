<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>

<script runat="server">
    protected string HTProgCap = "交辦專案室爭救案件統計表";// HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "Brt20";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";

    protected string SQL = "";

    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    DataTable dtRpt = new DataTable();//明細
 
    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";
    protected string FormName = "";

    protected string submitTask = "";
    protected string homelist = "";

    protected string rptTitle = "";//報表抬頭
    protected int totCnt = 0;//合計
    
    DataTable dt = new DataTable();
    DBHelper connopt = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    DBHelper cnn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    private void Page_Unload(System.Object sender, System.EventArgs e) {
        if (connopt != null) connopt.Dispose();
        if (cnn != null) cnn.Dispose();
    }
    
    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

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
        StrFormBtnTop += "<br><a href=\"javascript:window.print();void(0);\">列印</a>日期：" + DateTime.Today.ToShortDateString();

        FormName = "";

        if (ReqVal.TryGet("qryBranch") != "") {
            rptTitle += "<br>◎查詢區所別：<font color=\"blue\">" + Sys.getCodeName(connopt, "cust_code", "code_name", "where code_type='OBranch' and cust_code='" + Request["qryBranch"] + "'") + "</font>";
        }

        if (ReqVal.TryGet("qrykindDate") != "") {
            string Kind_Date_Name = "";
            switch (ReqVal.TryGet("qrykindDate")) {
                case "BCASE_DATE": Kind_Date_Name = "交辦專案室日期"; break;
                case "CONFIRM_DATE": Kind_Date_Name = "專案室收件日期"; break;
                case "PR_DATE": Kind_Date_Name = "專案室承辦完成日"; break;
                case "AP_DATE": Kind_Date_Name = "專案室判行日期"; break;
                case "GS_DATE": Kind_Date_Name = "專案室預計發文日期"; break;
            }
            rptTitle += "<br>◎查詢日期種類：<font color=\"blue\">" + Kind_Date_Name + "</font><br>";
            rptTitle += "◎查詢日期範圍：<font color=\"blue\">" + Request["qrysDate"] + " ～ " + Request["qryeDate"] + "</font>";
        }

        if (ReqVal.TryGet("qrySTAT_CODE") != "") {
            string Stat_code_name = "";
            if (ReqVal.TryGet("qrySTAT_CODE").IndexOf("RR;RX") > -1) {
                Stat_code_name += "、【尚未分案】";
            }
            if (ReqVal.TryGet("qrySTAT_CODE").IndexOf("NN;NX") > -1) {
                Stat_code_name += "、【承辦中】";
            }
            if (ReqVal.TryGet("qrySTAT_CODE").IndexOf("NY") > -1) {
                Stat_code_name += "、【承辦完成】";
            }
            if (ReqVal.TryGet("qrySTAT_CODE").IndexOf("YY") > -1) {
                Stat_code_name += "、【判行完成】";
            }
            if (ReqVal.TryGet("qrySTAT_CODE").IndexOf("YS") > -1) {
                Stat_code_name += "、【已發文】";
            }
            rptTitle += "<br>◎查詢承辦狀態：<font color=\"blue\">" + Stat_code_name.Substring(1) + "</font>";
        }

        rptTitle = (rptTitle != "" ? rptTitle.Substring(4) : "");
    }

    private void QueryData() {
	    SQL = "select code_name as Branch_name,cust_code,isnull(count(a.branch),0) as cnt ";
	    SQL +=" from cust_code as c ";
        SQL += " left join vbr_opt as a on a.branch=c.cust_code and a.Bmark='N'";
        SQL += " where c.code_type='OBranch' and c.sortfld is not null ";

        if (ReqVal.TryGet("qryBranch") != "") {
            SQL += "AND c.cust_code ='" + Request["qryBranch"] + "' ";
        }

        if (ReqVal.TryGet("qrySTAT_CODE") != "") {
            SQL += "and a.Bstat_code in ('" + ReqVal.TryGet("qrySTAT_CODE").Replace(";","','") + "') ";
        }

        SQL += " group by c.code_name, c.cust_code ,c.sortfld";
        ReqVal["qryOrder"] = ReqVal.TryGet("SetOrder", ReqVal.TryGet("qryOrder", "c.sortfld"));
        if (ReqVal.TryGet("qryOrder") != "") {
            SQL += " order by " + ReqVal.TryGet("qryOrder");
        }
        connopt.DataTable(SQL, dtRpt);

        //分頁完再處理其他資料才不會虛耗資源
        for (int i = 0; i < dtRpt.Rows.Count; i++) {
            DataRow dr = dtRpt.Rows[i];

            totCnt += Convert.ToInt32("0" + dr.SafeRead("cnt", ""));
        }

        rptRepeater.DataSource = dtRpt;
        rptRepeater.DataBind();
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
        <td class="text9" nowrap="nowrap"><%#rptTitle%></td>
        <td class="FormLink" valign="top" align="right" nowrap="nowrap">
            <%#StrFormBtnTop%>
        </td>
    </tr>
    <tr>
        <td colspan="3"><hr class="style-one"/></td>
    </tr>
</table>

<form style="margin:0;" id="reg" name="reg" method="post">
    <asp:Label ID="lblEmpty" runat="server" Visible='<%#bool.Parse((rptRepeater.Items.Count==0).ToString())%>'>
        <div align="center"><font color="red" size=2>=== 查無資料===</font></div>
    </asp:Label> 

    <asp:Repeater id="rptRepeater" runat="server">
    <HeaderTemplate>
        <table border="0" class="bluetable" cellspacing="1" cellpadding="2" width="20%" align="center" id="dataList">
	        <thead>
                <Tr class="lightbluetable">
	                <td align="center">區所</td>	
	                <td align="center">案件數</td>	
                </Tr>
	        </thead>
	        <tbody>
    </HeaderTemplate>
			    <ItemTemplate>
 		            <tr class="sfont9">
			            <td align="center" nowrap><%#Eval("Branch_name")%></td>
			            <td align="center" nowrap><%#Eval("cnt")%></td>
				    </tr>
			    </ItemTemplate>
    <FooterTemplate>
	        </tbody>
        	<%if (ReqVal.TryGet("qryBranch") == "") {%>	
                <tr>
                    <td align="center" class="lightbluetable3" nowrap>合計</td>
                    <td align="center" class="lightbluetable3" nowrap><%=totCnt%></td>
                </tr>	
	        <%}%>
        </table>
	    <BR>
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
