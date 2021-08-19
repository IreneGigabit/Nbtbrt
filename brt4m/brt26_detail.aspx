<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<script runat="server">
    protected string HTProgCap = "商標收費修訂明細";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "Brt26";//HttpContext.Current.Request["prgid"] ?? "";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";

    protected string SQL = "";
    protected object objResult = null;
    
    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();

    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";

    protected int curr= 0;
    protected string submitTask = "";
    protected string tdate = DateTime.Today.AddMonths(-2).ToShortDateString();
    protected string strbranch = "";
    DataTable dt = new DataTable();

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
        submitTask = ReqVal.TryGet("submittask").ToUpper();
        strbranch = ReqVal.TryGet("branch");//國內/出口
    
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
        StrFormBtnTop += "<a class=\"imgRefresh\" href=\"javascript:void(0);\" >[重新整理]</a>";
    }

    private void QueryData() {
        if (strbranch == "T") {
            SQL = "select *,''coun_c,''tend_date,0 oth_ser,0 oth_fee,0 total ";
            SQL += "from tbfee_v where dept = 'T' and country = 'T' ";
            SQL += " and tran_date between '" + tdate + "' and '" + DateTime.Today.ToShortDateString() + "' and end_date='2099/12/31' and rs_type='T92' order by beg_date";
        } else {
            SQL = "select *,''coun_c,''tend_date,0 oth_ser,0 oth_fee,0 total ";
            SQL += "from tebfee_v where dept = 'T' and country <> 'T' ";
            SQL += " and tran_date between '" + tdate + "' and '" + DateTime.Today.ToShortDateString() + "' and end_date='2099/12/31' order by beg_date";
        }
        //Sys.showLog(SQL);
        conn.DataTable(SQL, dt);
        curr = dt.Rows.Count;

        for (int i = 0; i < dt.Rows.Count; i++) {
            DataRow dr = dt.Rows[i];

            if (dr.GetDateTimeString("end_date", "yyyy/MM/dd") != "2099/12/31") {
                dr["tend_date"] = "~" + dr.GetDateTimeString("end_date", "yyyy/MM/dd");
            }

            SQL = "select coun_c from country where coun_code = '" + dr["country"] + "' and markb<>'X'";
            objResult = cnn.ExecuteScalar(SQL);
            dr["coun_c"] = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();

            if (dr.SafeRead("country", "") == "T") {
                if (dr.SafeRead("oth_code", "") != "") {
                    SQL = "select service,fees from case_fee ";
                    SQL += "where country = 'T' and dept = '" + dr["dept"] + "' ";
                    SQL += " and rs_code = '" + dr["oth_code"] + "' ";
                    using (SqlDataReader dr0 = conn.ExecuteReader(SQL)) {
                        if (dr0.Read()) {
                            dr["oth_ser"] = dr0["service"];
                            dr["oth_fee"] = dr0["fees"];
                        }
                    }
                }
            }
            dr["total"] = dr.SafeRead("service", 0) + dr.SafeRead("fees", 0) + dr.SafeRead("others", 0) + dr.SafeRead("oth_ser", 0) + dr.SafeRead("oth_fee", 0);
        }

        //dt.ShowTable();
        dataRepeater.DataSource = dt;
        dataRepeater.DataBind();
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title><%#HTProgCap%></title>
    <uc1:head_inc_form runat="server" ID="head_inc_form" />
</head>
<script language="javascript" type="text/javascript">
    var main = {};
    main.branch = "<%#Session["SeBranch"]%>";
    main.prgid = "<%#prgid%>";
    main.right = <%#HTProgRight%>;
</script>

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
    <input type="hidden" id="prgid" name="prgid" value="<%=prgid%>">
</form>

<div align="center" id="noData" style="display:<%#dt.Rows.Count==0?"":"none"%>">
	<font color="red">=== 無修訂資料 ===</font>
</div>

<form style="margin:0;" id="reg" name="reg" method="post">
    <asp:Repeater id="dataRepeater" runat="server">
    <HeaderTemplate>
        <div align="left" style="COLOR: darkorange"><strong>修訂期間：<%=tdate%>~<%=DateTime.Today.ToShortDateString()%></strong></div>
        <table style="display:<%#dt.Rows.Count==0?"none":""%>" border="0" class="bluetable" cellspacing="1" cellpadding="2" width="100%" align="center" id="dataList">
	        <thead>
                <tr class=lightbluetable>
                    <td align="center" width="10%"><strong>國家</strong></td>
                    <td align="center" width="8%"><strong>案性</strong></td>
                    <td align="center" width="16%"><strong>案性名稱</strong></td>
                    <td align="center" width="8%"><strong>服務費</strong></td>
                    <td align="center" width="8%"><strong>規費</strong></td>
		            <%if (strbranch == "E"){%>
                        <td align="center" width="8%"><strong>公簽證費</strong></td>
		            <%}%>
                    <td align="center" width="10%" ><strong>合計</strong></td>
                    <td align="center" width="10%"><strong>本所啟用日</strong></td>
                    <td align="center" width="10%"><strong>智財局實施日</strong></td>
                </tr>
	        </thead>
	        <tbody>
    </HeaderTemplate>
			<ItemTemplate>
                <tr class=whitetablebg> 
		            <td align="center"><%#Eval("coun_c")%></td>  
		            <td align="center"><%#Eval("arcase")%></td>
		            <td><%#Eval("case_name")%></td>
 		            <td align="right"><%#Eval("service")%><!--服務費-->
			            <%#(Convert.ToInt32(Eval("oth_ser"))>0?"<br>(" +Eval("oth_code")+":"+Eval("oth_ser")+")":"")%>
		            </td>
		            <td align="right"><%#Eval("fees")%><!--規費-->
			            <%#(Convert.ToInt32(Eval("oth_fee"))>0?"<br>(" +Eval("oth_code")+":"+Eval("oth_fee")+")":"")%>
		            </td>
		            <%if (strbranch == "E"){%>
			            <td align="right"><%#Eval("others")%></td><!--公簽證費-->
		            <%}%>
                    <td align="center" bgcolor="#80FF80"><%#Eval("total","NT${0:N0}")%></td><!--含稅合計-->
		            <td align="center"><%#Eval("beg_date","{0:yyyy/M/d}")%><%#Eval("tend_date")%></td>
			        <td align="center"><%#Eval("IPO_date","{0:yyyy/M/d}")%></td>
                </tr>
			</ItemTemplate>
    <FooterTemplate>
	        </tbody>
        </table>
	    <BR>

        <table style="display:<%#dt.Rows.Count==0?"none":""%>" border="0" width="100%" cellspacing="0" cellpadding="0">
		    <tr class="FormName"><td>
                <center>
                    <br><strong>資料共&nbsp;<font color=red><%=curr%></font>&nbsp;筆</strong>
                </center>
		    </td>
            </tr>
	    </table>
	    <br>
    </FooterTemplate>
    </asp:Repeater>

    <%#DebugStr%>
</form>

<div id="dialog"></div>

<iframe id="ActFrame" name="ActFrame" src="about:blank" width="100%" height="300" style="display:none"></iframe>
</body>
</html>

<script language="javascript" type="text/javascript">
    $(function () {
        if (window.parent.tt !== undefined) {
            window.parent.tt.rows = "100%,0%";
        }

        this_init();
    });

    function this_init() {
        $(".Lock").lock();
        $("input.dateField").datepick();
    }

    //執行查詢
    function goSearch() {
        $("#regPage").submit();
    };
    //////////////////////
</script>