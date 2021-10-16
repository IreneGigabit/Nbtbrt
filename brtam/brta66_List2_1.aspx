<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>

<script runat="server">
    protected string HTProgCap = "內商品質控制(T.Q.C)事項分析-清單";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = HttpContext.Current.Request["prgid"] ?? "";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";

    protected string SQL = "";
    protected object objResult = null;
    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected Paging page = null;

    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";

    protected string submitTask = "";

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
        StrFormBtnTop += "<a class=\"imgRefresh\" href=\"javascript:void(0);\" >[重新整理]</a>";
    }

    private void QueryData() {
        if (ReqVal.TryGet("cgrs") != "") {
            SQL = "select a.*,''fseq,''scode1_name,''pr_name ";
            SQL += "from vstep_dmt a ";
            SQL += "inner join vcode_act b on a.rs_type = b.rs_type and a.rs_class = b.rs_class and a.rs_code = b.rs_code and a.act_code = b.act_code ";
            SQL += "where b.tqc_type is not null and a.dmt_scode is not null ";
            SQL += " and a.cg = '" + ReqVal.TryGet("cgrs").Left(1) + "' and a.rs = '" + ReqVal.TryGet("cgrs").Right(1) + "' ";
            SQL += " and a.rs_no = a.main_rs_no ";
            SQL += " and a.seq1 <> 'M' and a.seq1 <> 'Z' ";
        } else {
            SQL = "select a.*,''fseq,''scode1_name,''pr_name ";
            SQL += "from vstep_dmt a ";
            SQL += "inner join vcode_act b on a.rs_type = b.rs_type  and a.rs_class = b.rs_class and a.rs_code = b.rs_code and a.act_code = b.act_code ";
            SQL += "inner join cust_code c on b.TQC_TYPE= c.cust_code and a.cg = left(c.mark1,1) and a.rs = right(c.mark1,1) ";
            SQL += "where b.tqc_type is not null and a.dmt_scode is not null ";
            SQL += " and c.code_type = 'TTQC_TYPE' ";
            SQL += " and a.rs_no = a.main_rs_no ";
            SQL += " and a.seq1 <> 'M' and a.seq1 <> 'Z' ";
        }

        if (ReqVal.TryGet("sstep_date") != "") {
            SQL += "AND step_date>='" + ReqVal["sstep_date"] + "' ";
        }
        if (ReqVal.TryGet("estep_date") != "") {
            SQL += "AND step_date<='" + ReqVal["estep_date"] + "' ";
        }
        if (ReqVal.TryGet("dmt_scode") != "") {
            SQL += "AND a.dmt_scode='" + ReqVal["dmt_scode"] + "' ";
        }
        if (ReqVal.TryGet("tqc_type") != "") {
            SQL += "AND b.tqc_type like '" + ReqVal["tqc_type"] + "%' ";
        }
        ReqVal["qryOrder"] = ReqVal.TryGet("SetOrder", ReqVal.TryGet("qryOrder", "dmt_scode,seq,seq1,step_grade"));
        if (ReqVal.TryGet("qryOrder") != "") {
            SQL += " order by " + ReqVal.TryGet("qryOrder");
        }
        //Sys.showLog(SQL);
        DataTable dt = new DataTable();
        conn.DataTable(SQL, dt);

        //處理分頁
        int nowPage = Convert.ToInt32(Request["GoPage"] ?? "1"); //第幾頁
        int PerPageSize = Convert.ToInt32(Request["PerPage"] ?? "10"); //每頁筆數
        page = new Paging(nowPage, PerPageSize, SQL);
        page.GetPagedTable(dt);

        //分頁完再處理其他資料才不會虛耗資源
        for (int i = 0; i < page.pagedTable.Rows.Count; i++) {
            DataRow dr = page.pagedTable.Rows[i];

            //案號
            dr["fseq"] = Sys.formatSeq1(dr.SafeRead("seq", ""), dr.SafeRead("seq1", ""), "", Sys.GetSession("seBranch"), Sys.GetSession("dept"));
            if (dr.SafeRead("end_date", "") != "") {
                dr["fseq"] += "<font color=red>*</font>";
            }
            //洽案營洽
            dr["scode1_name"] = GetScode1Name(dr);

            //承辦人員
            dr["pr_name"] = GetPrName(dr);
        }

        dataRepeater.DataSource = page.pagedTable;
        dataRepeater.DataBind();
    }

    //洽案營洽
    protected string GetScode1Name(DataRow dr) {
        string scode1_name = "";
        SQL = "select sc_name from scode where scode='" + dr.SafeRead("dmt_scode", "") + "'";
        objResult = cnn.ExecuteScalar(SQL);
        scode1_name = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();
        return scode1_name;
    }

    //承辦人員
    protected string GetPrName(DataRow dr) {
        string pr_name = "";
        SQL = "select sc_name from scode where scode='" + dr.SafeRead("pr_scode", "") + "'";
        objResult = cnn.ExecuteScalar(SQL);
        pr_name = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();
        return pr_name;
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
        <table style="display:<%#page.totRow==0?"none":""%>" border="0" class="bluetable" cellspacing="1" cellpadding="2" width="100%" align="center" id="dataList">
	        <thead>
                <Tr class="lightbluetable" align=center>
                    <td nowrap>本所編號</td>
                    <td nowrap>進度<br>序號</td>
                    <td nowrap>案件名稱</td>
                    <td>客戶名稱</td>
                    <td nowrap>發文日期</td>
                    <td>發文內容</td>
                    <td nowrap>洽案營洽</td>
                    <td nowrap>承辦人員</td>
                </Tr>
	        </thead>
	        <tbody>
    </HeaderTemplate>
			<ItemTemplate>
 		        <tr align="center" class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>">
			        <td nowrap style="cursor: pointer;color:darkblue;" onmouseover="this.style.color='red'" onmouseout="this.style.color='black'" onclick="CapplClick('<%#Eval("seq")%>', '<%#Eval("seq1")%>')">
                        <%#Eval("fseq")%>
			        </td>
                    <td><%#Eval("step_grade")%></td>
		            <td align=left><%#Eval("cappl_name")%></td>
		            <td align=left><%#Eval("ap_cname1")%></td>
		            <td><%#Eval("step_date","{0:d}")%></td>
		            <td align=left>(<%#Eval("rs_no")%>)<%#Eval("rs_detail")%></td>
		            <td><%#Eval("scode1_name")%></td>
		            <td><%#Eval("pr_name")%></td>
		        </tr>
			</ItemTemplate>
    <FooterTemplate>
	        </tbody>
        </table>
	    <BR>

        <table style="display:<%#page.totRow==0?"none":""%>" border="0" width="100%" cellspacing="0" cellpadding="0">
		    <tr class="FormName"><td>
			    <div style="color:blue">
			    </div>
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
    function CapplClick(pseq,pseq1){
        window.showModalDialog(getRootPath() + "/brt5m/brt15ShowFP.aspx?prgid=<%=prgid%>&seq=" + pseq + "&seq1=" + pseq1 + "&submittask=Q", "", "dialogHeight: 540px; dialogWidth: 800px; center: Yes;resizable: No; status: No;scrollbars:yes");
    }
</script>