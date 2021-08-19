<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<script runat="server">
    protected string HTProgCap = "國內/出口個案明細查詢作業";//HttpContext.Current.Request["prgname"];//功能名稱
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
    protected string FormName = "";

    protected bool emptyForm = true;
    protected string country = "";
    protected string qrySeq = "", qrySeq1 = "";
    protected string qryCust_seq = "", qryCust_name = "";
    protected string qryScode = "";
	protected string qrySin_date  = "",qryEin_date  = "";
	protected string qryEnd_flag  = "";
	protected string pwhescode = "";
    
    protected string td_tscode = "";

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

	    country = ReqVal.TryGet("country");
	    qrySeq = ReqVal.TryGet("qrySeq");
	    qrySeq1 = ReqVal.TryGet("qrySeq1");
	    qryCust_seq = ReqVal.TryGet("qrycust_seq");
	    qryCust_name = ReqVal.TryGet("qrycust_name");
	    qryScode = ReqVal.TryGet("qryscode");
	    qrySin_date = ReqVal.TryGet("qrySin_date");
	    qryEin_date = ReqVal.TryGet("qryEin_date");
	    qryEnd_flag = ReqVal.TryGet("qryend_flag");
	    pwhescode = ReqVal.TryGet("pwhescode");

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

        if (qrySeq != "" || qrySeq1 != "" || qryScode != "" || qryCust_seq != "" || qrySin_date != "" || qryEin_date != "") {
            emptyForm = false;
        }

        //營洽清單
        //權限B：部門主管,區所主管
        //權限A：組主管
        if ((HTProgRight & 64) != 0 || (HTProgRight & 128) != 0) {
            //抓取組主管所屬營洽
            string sales_scode = "";
            if ((HTProgRight & 64) != 0) {
                sales_scode = "";
            } else if ((HTProgRight & 64) != 0) {
                pwhescode = Sys.getTeamScode(Sys.GetSession("SeBranch"), Sys.GetSession("scode"));
                sales_scode = "and a.scode in(" + pwhescode + ")";
            }
            td_tscode = "<select id='qryscode' name='qryscode' >";
            td_tscode += Sys.getDmtScode("", sales_scode).Option("{scode}", "{star}{scode}_{sc_name}", "style='color:{color}'", true);
            td_tscode += "<option value='" + Sys.GetSession("seBranch") + Sys.GetSession("dept") + "'>" + Sys.GetSession("seBranch") + Sys.GetSession("dept").ToUpper() + "_部門(開放客戶)</option>";
            td_tscode += "</select>";
        } else {
            pwhescode = "'" + Session["scode"] + "'";
            td_tscode = "<input type='hidden' id='qryscode' name='qryscode' readonly class='SEdit' value='" + Session["se_scode"] + "'>" + Session["sc_name"];
        }
    }

    private void QueryData() {
        if (country == "T") {
            SQL = "select a.*,b.ap_cname1 as cust_name,'T' as country,''fseq,''fext_seq,''func ";
            SQL += ",(select sc_name from sysctrl.dbo.scode where scode=a.scode) as sc_name ";
            SQL += " from dmt a ";
            SQL += " inner join apcust b ";
        } else {
            SQL = "select a.*,b.ap_cname1 as cust_name,''fseq,''fext_seq,''func ";
            SQL += ",(select sc_name from sysctrl.dbo.scode where scode=a.scode) as sc_name ";
            SQL += " from ext a ";
            SQL += " inner join apcust b ";
        }
        SQL += " on a.cust_area=b.cust_area and a.cust_seq=b.cust_seq ";
        SQL += " where 1=1 ";
        if (emptyForm) SQL += "AND 1=0 ";

        if (qrySeq != "") SQL += " and a.Seq in ('" + qrySeq.Replace(",", "','") + "')";
        if (qrySeq1 != "") SQL += " and a.Seq1 ='" + qrySeq1 + "'";
        if (qryScode != "") {
            if (qryScode == "*") {
                SQL += " and a.scode in ('" + pwhescode + "')";
            } else {
                SQL += " and a.scode ='" + qryScode + "'";
            }
        }
        if (qryCust_seq != "") SQL += " and a.cust_seq ='" + qryCust_seq + "'";
        if (qryCust_name != "") SQL += " and b.ap_cname1 like '%" + qryCust_name + "%'";
        if (qrySin_date != "") SQL += " and a.in_date >='" + qrySin_date + "'";
        if (qryEin_date != "") SQL += " and a.in_date <='" + qryEin_date + "'";
        if (qryEnd_flag != "Y") SQL += " and a.end_date is null";

        ReqVal["qryOrder"] = ReqVal.TryGet("SetOrder", ReqVal.TryGet("qryOrder", ""));
        if (ReqVal.TryGet("qryOrder") != "") {
            SQL += " order by " + ReqVal.TryGet("qryOrder");
        }
        Sys.showLog(SQL);
        DataTable dt = new DataTable();
        conn.DataTable(SQL, dt);

        //處理分頁
        int nowPage = Convert.ToInt32(Request["GoPage"] ?? "1"); //第幾頁
        int PerPageSize = Convert.ToInt32(Request["PerPage"] ?? "20"); //每頁筆數
        page = new Paging(nowPage, PerPageSize, SQL);
        page.GetPagedTable(dt);

        //分頁完再處理其他資料才不會虛耗資源
        for (int i = 0; i < page.pagedTable.Rows.Count; i++) {
            DataRow dr = page.pagedTable.Rows[i];

            //案號
            if (dr.SafeRead("country", "") == "T") {
                dr["fseq"] = Sys.formatSeq(dr.SafeRead("seq", ""), dr.SafeRead("seq1", ""), "", Sys.GetSession("SeBranch"), Sys.GetSession("dept"));
                dr["func"] = "CapplClick_dmt";
            } else {
                dr["fseq"] = Sys.formatSeq(dr.SafeRead("seq", ""), dr.SafeRead("seq1", ""), dr.SafeRead("country", ""), Sys.GetSession("SeBranch"), Sys.GetSession("dept") + "E");
                dr["func"] = "CapplClick_ext";
            }

            //案件名稱
            dr["appl_name"] = dr.SafeRead("appl_name", "").ToUnicode().CutData(20);
            //客戶名稱
            dr["cust_name"] = dr.SafeRead("cust_name", "").ToUnicode().CutData(10);
        }

        dataRepeater.DataSource = page.pagedTable;
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
    <table border="0" cellspacing="1" cellpadding="2" width="100%">
<tr>
	<td class="text9">
		◎洽案營洽: 
        <%#td_tscode%> 
		<input type="hidden" name="pwhescode" id="pwhescode" value="<%=pwhescode%>"> 
	</td>
	<td class="text9">
		◎本所編號:<input type="text" id="qrySeq" name="qrySeq" size="30">-<input type="text" id="qrySeq1" name="qrySeq1" size="2">
	</td>
	<td class="text9">
		◎立案日期:<input type="text" id="qrySin_date" name="qrySin_date" size="10" value="<%=qrySin_date%>" class="dateField">~<input type="text" id="qryEin_date" name="qryEin_date" size="10" value="<%=qryEin_date%>" class="dateField">
		<label><input type=checkbox id="qryend_flag" name="qryend_flag" value="Y" checked>包含結案案件</label>
	</td>
</tr>	
<tr>
	<td class="text9">
		◎客戶編號: <input type="text" id="qrycust_seq" name="qrycust_seq" size="10" value="<%=qryCust_seq%>">
	</td>
	<td class="text9">
		◎客戶名稱:<input type="text" id="qrycust_name" name="qrycust_name" size="30" value="<%=qryCust_name%>">
	</td>
	<td class="text9">
		<input type="button" value="查詢" class="cbutton" onClick="goSearch()" id=qrybutton name=qrybutton>
		<input type="hidden" id="prgid" name="prgid" value="<%=prgid%>">
		<input type="hidden" id="country" name="country" value="<%=country%>">
	</td>
</tr>

    </table>

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
	<br /><font color="red">=== <%=(emptyForm?"請先輸入查詢條件":"目前無資料")%> ===</font>
</div>


<form style="margin:0;" id="reg" name="reg" method="post">
	<input type="hidden" name="prgid" value="<%=prgid%>">

    <asp:Repeater id="dataRepeater" runat="server">
    <HeaderTemplate>
        <table style="display:<%#page.totRow==0?"none":""%>" border="0" class="bluetable" cellspacing="1" cellpadding="2" width="100%" align="center" id="dataList">
	        <thead>
                <Tr>
	                <td  class="lightbluetable" nowrap align="center">作業</td>
	                <td  class="lightbluetable" nowrap align="center">本所編號</td>
	                <%if (country!="T"){%>
	                <td  class="lightbluetable" nowrap align="center">國外所編號</td>
	                <%}%>
	                <td  class="lightbluetable" nowrap align="center">案件名稱</td>
	                <td  class="lightbluetable" nowrap align="center">客戶名稱</td> 
	                <td  class="lightbluetable" nowrap align="center">立案日期</td> 
	                <td  class="lightbluetable" nowrap align="center">結案日期</td> 
	                <td  class="lightbluetable" nowrap align="center">營洽</td> 
                </tr>
	        </thead>
	        <tbody>
    </HeaderTemplate>
	<ItemTemplate>
 	    <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>">
		    <td nowrap align="center">
			    <a href="extform/accseqlist_qry.aspx?prgid=<%=prgid%>&seq=<%#Eval("seq")%>&seq1=<%#Eval("seq1")%>&country=<%#Eval("country")%>&Frame=Y" title="個案明細查詢" target="Eblank">[個案明細]</a>
		    </td>
	        <td align="center" style="cursor: pointer;color:darkblue" onmouseover="this.style.color='red'" onmouseout="this.style.color='darkblue'" nowrap onclick="<%#Eval("func")%>('<%#Eval("Seq")%>','<%#Eval("Seq1")%>')">
                <%#Eval("fseq")%>
	        </td>
	        <%if (country!="T"){%>
		        <td align="center"><%#Eval("fext_seq")%></td>
	        <%}%>
		    <td align="left"><%#Eval("appl_name")%></td>
		    <td align="center"><%#Eval("cust_area")%><%#Eval("cust_seq")%>_<%#Eval("cust_name")%></td>
		    <td align="center"><%#Eval("in_date","{0:yyyy/M/d}")%></td>
		    <td align="center"><%#Eval("end_date","{0:yyyy/M/d}")%></td>
		    <td align="center"><%#Eval("sc_name")%></td>
	    </tr>
	</ItemTemplate>
    <FooterTemplate>
	        </tbody>
        </table>
	    <BR>
	    <div align="center" style="display:<%#page.totRow==0?"none":""%>">
            <%#StrFormBtn%>
        </div>
	    <BR>
        <table style="display:<%#page.totRow==0?"none":""%>" border="0" width="100%" cellspacing="0" cellpadding="0">
		    <tr class="FormName"><td><div align="left" style="color:blue"><%#FormName%></div></td>
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
        $("#qryscode option[value='<%=qryScode%>']").prop("selected", true);//營洽清單

        $(".Lock").lock();
        $("input.dateField").datepick();
    }

    //執行查詢
    function goSearch() {
        if ((main.right & 256) == 0) {
            if ($("#qrySeq").val() == "" && $("#qrySeq1").val() == "" && ($("#qryscode").val() == "" ||$("#qryscode").val() == "*" )
            && $("#qrycust_seq").val() == "" && $("#qrySin_date").val() == "" && $("#qryEin_date").val() == "") {
                alert("「本所編號」、「洽案營洽」、「客戶編號」、「立案日期」請至少輸入一項查詢條件！ ");
                return false;
            }
        }

        $("#regPage").submit();
    };
    //////////////////////
    $(".dateField").blur(function (e){
        ChkDate(this);
    });

    //查詢國內案主檔
    function CapplClick_dmt(pseq, pseq1) {
        window.showModalDialog(getRootPath() + "/brt5m/brt15ShowFP.aspx?prgid=<%=prgid%>&seq=" + pseq + "&seq1=" + pseq1 + "&submittask=Q", "", "dialogHeight: 540px; dialogWidth: 800px; center: Yes;resizable: No; status: No;scrollbars:yes");
    }
    //查詢出口案主檔
    function CapplClick_ext(pseq, pseq1) {
        //****todo
        window.showModalDialog(getRootPath() + "/brt5m/ext54Edit.aspx?prgid=<%=prgid%>&seq=" + pseq + "&seq1=" + pseq1 + "&submittask=DQ", "", "dialogHeight: 540px; dialogWidth: 800px; center: Yes;resizable: No; status: No;scrollbars:yes");
    }
</script>