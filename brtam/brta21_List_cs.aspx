<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<script runat="server">
    protected string HTProgCap = "國內案收發進度維護作業-客發清單";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "brta21";//HttpContext.Current.Request["prgid"] ?? "";//程式檔名前綴
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
    protected string cgrs = "";
    protected string cg = "";
    protected string rs = "";

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

        cgrs = ReqVal.TryGet("cgrs").ToUpper();
        cg = ReqVal.TryGet("cgrs").Left(1);
        rs = ReqVal.TryGet("cgrs").Right(1);

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
        StrFormBtnTop += "<a href='" + HTProgPrefix + ".aspx?prgid=" + prgid + "'>[查詢畫面]</a>";
        StrFormBtnTop += "<a class=\"imgRefresh\" href=\"javascript:void(0);\" >[重新整理]</a>";
    }

    private void QueryData() {
            SQL = "select ROW_NUMBER() OVER(PARTITION BY rs_no ORDER BY rs_no,seq,seq1 ) AS rank";
            SQL += ",*,''tclass,''fseq,''lcg,''lrs ";
            SQL += " from vcs_dmt ";
            SQL += " where 1=1";

        if (ReqVal.TryGet("seq") != "") {
            SQL += "AND Seq='" + ReqVal["seq"] + "' ";
        }
        if (ReqVal.TryGet("seq1") != "") {
            SQL += "AND Seq1='" + ReqVal["seq1"] + "' ";
        }
        if (ReqVal.TryGet("rs_no") != "") {
            SQL += "AND rs_no='" + ReqVal["rs_no"] + "' ";
        }
        if (ReqVal.TryGet("cust_area") != "") {
            SQL += "AND branch='" + ReqVal["cust_area"] + "' ";
        }
        if (ReqVal.TryGet("cust_seq") != "") {
            SQL += "AND cust_seq='" + ReqVal["cust_seq"] + "' ";
        }
        if (ReqVal.TryGet("ap_cname") != "") {
            SQL += "and ap_cname1 like'%" + ReqVal["ap_cname"] + "%' ";
        }
        if (ReqVal.TryGet("cappl_name") != "") {
            SQL += "and cappl_name like'%" + ReqVal["cappl_name"] + "%' ";
        }
        if (ReqVal.TryGet("rs_class") != "") {
            SQL += "AND rs_class='" + ReqVal["rs_class"] + "' ";
        }
        if (ReqVal.TryGet("rs_code") != "") {
            SQL += "AND rs_code='" + ReqVal["rs_code"] + "' ";
        }
        if (ReqVal.TryGet("act_code") != "") {
            SQL += "AND act_code='" + ReqVal["act_code"] + "' ";
        }
        if (ReqVal.TryGet("sstep_date") != "") {
            SQL += "AND step_date>='" + ReqVal["sstep_date"] + "' ";
        }
        if (ReqVal.TryGet("estep_date") != "") {
            SQL += "AND step_date<='" + ReqVal["estep_date"] + "' ";
        }
        if (ReqVal.TryGet("slast_date") != "") {
            SQL += "AND last_date>='" + ReqVal["slast_date"] + "' ";
        }
        if (ReqVal.TryGet("elast_date") != "") {
            SQL += "AND last_date<='" + ReqVal["elast_date"] + "' ";
        }
        if (ReqVal.TryGet("scode1") != "") {
            SQL += "AND dmt_scode='" + ReqVal["scode1"] + "' ";
        }
        if (cgrs == "CS") {
            ReqVal["qryOrder"] = ReqVal.TryGet("SetOrder", ReqVal.TryGet("qryOrder", "rs_no,seq,seq1"));
        } else {
            ReqVal["qryOrder"] = ReqVal.TryGet("SetOrder", ReqVal.TryGet("qryOrder", "seq,seq1,step_grade"));

        }
        if (ReqVal.TryGet("qryOrder") != "") {
            SQL += " order by " + ReqVal.TryGet("qryOrder");
        }

        DataTable dt = new DataTable();
        conn.DataTable(SQL, dt);

        //處理分頁
        int nowPage = Convert.ToInt32(Request["GoPage"] ?? "1"); //第幾頁
        int PerPageSize = Convert.ToInt32(Request["PerPage"] ?? "10"); //每頁筆數
        page = new Paging(nowPage, PerPageSize, SQL);
        page.GetPagedTable(dt);

        string tclass = "sfont9";
        //分頁完再處理其他資料才不會虛耗資源
        for (int i = 0; i < page.pagedTable.Rows.Count; i++) {
            DataRow dr = page.pagedTable.Rows[i];
            if (dr.SafeRead("rank", "") == "1" && i > 0) {
                tclass = (tclass == "sfont9" ? "lightbluetable3" : "sfont9");
            }

            dr["tclass"] = tclass;

            //案號
            dr["fseq"] = Sys.formatSeq1(dr.SafeRead("seq", ""), dr.SafeRead("seq1", ""), "", Sys.GetSession("seBranch"), Sys.GetSession("dept"));
            //收發種類
            if (cg == "C") {
                dr["lcg"] = "客";
            } else if (cg == "G") {
                dr["lcg"] = "官";
            } else {
                dr["lcg"] = "本";
            }
            if (rs == "R" || rs == "Z") {
                dr["lrs"] = "收";
            } else {
                dr["lrs"] = "發";
            }
        }

        dataRepeater.DataSource = page.pagedTable;
        dataRepeater.DataBind();
    }

    //[作業]
    protected string GetLink(RepeaterItem Container) {
        string link = "";

        //[維護]/[刪除]
        if (Eval("rank").ToString() == "1") {
            if ((HTProgRight & 8) != 0) {
                link += "<a href=\"brta32_edit.aspx?submitTask=U&prgid=" + prgid + "&rs_no=" + Eval("rs_no") + "&cgrs=" + cgrs + "&FrameBlank=50\" target=\"Eblank\">[維護]</a>";
            }
            //if ((HTProgRight & 16) != 0) {
            //    link += "<a href=\"brta32_edit.aspx?submitTask=D&prgid=" + prgid + "&rs_no=" + Eval("rs_no") + "&cgrs="+cgrs+"&FrameBlank=50\" target=\"Eblank\">[刪除]</a>";
            //}

            //[查詢]
            link += "<a href=\"brta32_edit.aspx?submitTask=Q&prgid=" + prgid + "&rs_no=" + Eval("rs_no") + "&cgrs=" + cgrs + "&FrameBlank=50\" target=\"Eblank\">[查詢]</a>";
        }

        //[列印]
        string step_date = Eval("step_date", "{0:d}");
        link += "<a href=\"brta5m.aspx?prgid=brta5m&cgrs=cs&step_date=" + step_date + "&rs_no=" + Eval("rs_no") + "&FrameBlank=50\" target=\"Eblank\">[列印]</a>";

        return link;
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
                  <Tr class="lightbluetable" align="center">
 		            <td nowrap>收/發</td>
		            <td>發文序號</td>
		            <td>發文內容</td>
		            <td nowrap>發文日期</td>
		            <td nowrap>法定期限</td>
		            <td nowrap>本所編號</td>
		            <td>案件名稱</td>
		            <td>客戶名稱</td>
			        <td nowrap>洽案營洽</td>
	                <td nowrap>作業</td>
                 </Tr>
	        </thead>
	        <tbody>
    </HeaderTemplate>
			<ItemTemplate>
 		        <tr class="<%#Eval("tclass")%>">
		            <td align=center><%#(Eval("rank").ToString()=="1"?Eval("lcg").ToString()+Eval("lrs").ToString():"")%></td>
		            <td nowrap align=center><%#(Eval("rank").ToString()=="1"?Eval("rs_no"):"")%></td>
		            <td><%#(Eval("rank").ToString()=="1"?Eval("rs_detail"):"")%></td>
		            <td nowrap align=center><%#(Eval("rank").ToString()=="1"?Eval("step_date","{0:d}"):"")%></td>
		            <td nowrap align=center><%#(Eval("rank").ToString()=="1"?Eval("last_date","{0:d}"):"")%></td>
		            <td nowrap align=center style="cursor:pointer;color:darkblue" onmouseover="this.style.color='red'" onmouseout="this.style.color='darkblue'" onclick="CapplClick('<%#Eval("seq")%>', '<%#Eval("seq1")%>')">
                        <%#Eval("fseq")%>
		            </td>
		            <td align=center><%#Eval("cappl_name")%></td>
		            <td align=center><%#Eval("ap_cname1")%></td>
		            <td align=center nowrap><%#Eval("sc_name")%></td>
		            <td align=center><%#GetLink(Container)%></td>
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
        $("select[id^='act_code_']").each(function(idx) {
            $(this).trigger("change");
        });

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