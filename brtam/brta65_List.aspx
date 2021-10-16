<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Linq"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<script runat="server">
    protected string HTProgCap = "國內案案件資料查詢作業";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = HttpContext.Current.Request["prgid"] ?? "";//程式檔名前綴
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

    protected string kind_no = "";
    protected string ref_no = "";
    protected string kind_date = "";
    protected string sdate = "";
    protected string edate = "";

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

        kind_no = ReqVal.TryGet("kind_no");
        ref_no = ReqVal.TryGet("ref_no");
        kind_date = ReqVal.TryGet("kind_date");
        sdate = ReqVal.TryGet("sdate");
        edate = ReqVal.TryGet("edate");

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
        if ((HTProgRight & 2) > 0) {
            StrFormBtnTop += "<a href=\"javascript:void(0)\" onclick=\"show_excel()\">[下載Excel]</a>";
        }
        if ((HTProgRight & 2) > 0) {
            StrFormBtnTop += "<a href=\"javascript:void(0)\" onclick=\"show_report()\">[案件明細表列印]</a>";
        }

        StrFormBtnTop += "<a href='brta65.aspx?prgid=" + prgid + "'>[查詢畫面]</a>";
    }

    private void QueryData() {
        DataTable dt = new DataTable();
        SQL = "select a.seq,a.seq1,a.class,a.in_date,a.appl_name,a.cust_area,a.cust_seq,a.apply_no,a.apply_date,a.issue_date,a.issue_no,a.term2";
        SQL += ",a.scode,a.end_date,b.ap_cname1,c.draw_file ";
        SQL += ",(select code_name from cust_code where code_type = 'TCase_Stat' and cust_code = a.now_stat) as now_statnm";
        SQL += ",''fseq,''end_star,''fdraw_file,a.scode lscode";
        SQL += " from dmt a ";
        SQL += " inner join apcust b on a.cust_seq = b.cust_seq ";
        SQL += " inner join ndmt c on a.seq=c.seq and a.seq1=c.seq1 ";
        SQL += " where 1=1 ";

        if (ReqVal.TryGet("seq") != "") {
            SQL += " and a.seq = '" + ReqVal.TryGet("seq") + "'";
        }
        if (ReqVal.TryGet("seq1") != "") {
            SQL += " and a.seq1 = '" + ReqVal.TryGet("seq1") + "'";
        }
        if (ReqVal.TryGet("class") != "") {
            SQL += " and a.class like '%" + ReqVal.TryGet("class") + "%'";
        }
        if (ReqVal.TryGet("class_type") != "") {
            SQL += " and a.class_type = '" + ReqVal.TryGet("class_type") + "'";
        }
        if (ReqVal.TryGet("mseq") != "") {
            SQL += " and a.mseq = '" + ReqVal.TryGet("mseq") + "'";
        }
        if (ReqVal.TryGet("mseq1") != "") {
            SQL += " and a.mseq1 = '" + ReqVal.TryGet("mseq1") + "'";
        }
        if (ReqVal.TryGet("scode") != "") {
            SQL += " and a.scode = '" + ReqVal.TryGet("scode") + "'";
        }
        if (ReqVal.TryGet("cust_seq") != "") {
            SQL += " and a.cust_seq = '" + ReqVal.TryGet("cust_seq") + "'";
        }
        if (ReqVal.TryGet("ap_cname1") != "") {
            SQL += " and b.ap_cname1 like '%" + ReqVal.TryGet("ap_cname1") + "%'";
        }
        if (ReqVal.TryGet("apcust_no") != "") {
            SQL += " and a.seq in (select distinct seq from dmt_ap where apcust_no like '%" + ReqVal.TryGet("apcust_no") + "%' )";
        }
        if (ReqVal.TryGet("ap_cname") != "") {
            SQL += " and rtrim(cast(a.seq as char))+a.seq1 in (select rtrim(cast(seq as char))+seq1 from dmt_ap where ap_cname like '%" + ReqVal.TryGet("ap_cname") + "%')";
        }
        if (ReqVal.TryGet("s_mark") != "") {
            if (ReqVal.TryGet("s_mark") != "") {
                SQL += " and a.s_mark in ('T','')";
            } else {
                SQL += " and a.s_mark = '" + ReqVal.TryGet("s_mark") + "'";
            }
        }
        if (ReqVal.TryGet("s_mark2") != "") {
            SQL += " and a.s_mark2 = '" + ReqVal.TryGet("s_mark2") + "'";
        }
        if (ReqVal.TryGet("pul") != "") {
            if (ReqVal.TryGet("s_mark") == "0") {
                SQL += " and a.pul=''";
            } else {
                SQL += " and a.pul = '" + ReqVal.TryGet("pul") + "'";
            }
        }
        if (ReqVal.TryGet("appl_name") != "") {
            SQL += " and a.appl_name like '%" + ReqVal.TryGet("appl_name") + "%'";
        }
        if (kind_no != "") {
            SQL += " and a." + kind_no + " = '" + ref_no + "' ";
        } else {
            if (ref_no != "") {
                SQL += " and (a.Apply_No like '%" + ref_no + "%' ";
                SQL += " or a.Issue_No like '%" + ref_no + "%' ";
                SQL += " or a.Rej_No like '%" + ref_no + "%') ";
            }
        }

        if (kind_date != "") {
            if (sdate != "") SQL += " and a." + kind_date + " >= '" + sdate + "' ";
            if (edate != "") SQL += " and a." + kind_date + " <= '" + edate + "' ";
        } else {
            if (sdate != "") {
                SQL += " and (a.In_Date >= '" + sdate + "' ";
                SQL += "  or a.Apply_Date >= '" + sdate + "' ";
                SQL += "  or a.Issue_Date >= '" + sdate + "' ";
                SQL += "  or a.End_Date >= '" + sdate + "' ";
                SQL += "  or a.term2 >= '" + sdate + "') ";
            }
            if (edate != "") {
                SQL += " and (a.In_Date <= '" + edate + "' ";
                SQL += "  or a.Apply_Date <= '" + edate + "' ";
                SQL += "  or a.Issue_Date <= '" + edate + "' ";
                SQL += "  or a.End_Date <= '" + edate + "' ";
                SQL += "  or a.term2 <= '" + edate + "') ";
            }
        }

        if (ReqVal.TryGet("qryend") == "Y") {//尚未結案
            SQL += " and a.end_date is null";
        } else if (ReqVal.TryGet("qryend") == "N") {//已結案
            SQL += " and a.end_date is not null";
            if (ReqVal.TryGet("end_code") != "") {
                SQL += " and a.end_code = '" + ReqVal.TryGet("end_code") + "'";
            }
            if (ReqVal.TryGet("end_type") != "") {
                SQL += " and a.end_type = '" + ReqVal.TryGet("end_type") + "'";
            }
        }

        if (ReqVal.TryGet("tran_flag") != "") {
            SQL += " and a.tran_flag = '" + ReqVal.TryGet("tran_flag") + "'";
            if (ReqVal.TryGet("tran_seq_branch") != "") {
                SQL += " and a.tran_seq_branch = '" + ReqVal.TryGet("tran_seq_branch") + "'";
            }
        }

        ReqVal["qryOrder"] = ReqVal.TryGet("SetOrder", ReqVal.TryGet("qryOrder", "a.seq,a.seq1"));
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

            //案號
            dr["fseq"] = Sys.formatSeq1(dr.SafeRead("seq", ""), dr.SafeRead("seq1", ""), "", "", "");
            if (dr.SafeRead("end_date", "") != "") {
                dr["end_star"] = "<font color=red>*</font>";
            }
            
            if (dr.SafeRead("draw_file", "") != "") {
                dr["fdraw_file"] = "<img src=\"" + Sys.Path2Nbtbrt(dr["draw_file"].ToString()) + "\" width=\"30\" height=\"30\" onmouseout=\"ResizePic(0)\" onmouseover=\"ResizePic(1)\">";
            }

            SQL = "select sc_name from scode where scode = '" + dr["scode"] + "'";
            using (SqlDataReader dr0 = cnn.ExecuteReader(SQL)) {
                if (dr0.Read()) {
                    dr["lscode"] = dr0.SafeRead("sc_name", "");
                }
            }
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
            <Tr>
		        <TD class=lightbluetable align=center><u class="setOdr" v1="a.seq,a.seq1">本所編號</u></TD>
		        <TD class=lightbluetable align=center><u class="setOdr" v1="a.class">類別</u></TD>
		        <TD class=lightbluetable align=center>案件狀態</TD>
		        <TD class=lightbluetable align=center>圖樣</TD>
		        <TD class=lightbluetable align=center>案件名稱</TD>
		        <TD class=lightbluetable align=center>客戶</TD>
		        <TD class=lightbluetable align=center>申請日期</TD>
		        <TD class=lightbluetable align=center>申請號碼</TD>
		        <TD class=lightbluetable align=center>註冊日期</TD>
		        <TD class=lightbluetable align=center>註冊號碼</TD>	
		        <TD class=lightbluetable align=center>專用迄日</TD>	
		        <TD class=lightbluetable align=center>營洽</TD>
		        <TD class=lightbluetable align=center>進度查詢</TD><!--2011/7/14增加進度查詢功能-->
            </tr>
	    </thead>
	    <tbody>
</HeaderTemplate>
			<ItemTemplate>
 		        <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>" align="center">
			        <td nowrap style="cursor: pointer;" onmouseover="this.style.color='red'" onmouseout="this.style.color='black'" onclick="CapplClick('<%#Eval("seq")%>','<%#Eval("seq1")%>')">
                        <%#Eval("end_star")%><%#Eval("fseq")%>
			        </td>
			        <td nowrap><%#Eval("class")%></td>
			        <td nowrap><%#Eval("now_statnm")%></td>
			        <td nowrap><%#Eval("fdraw_file")%></td>
			        <td ><%#Eval("appl_name")%></td>
			        <td nowrap style="cursor: pointer;" onmouseover="this.style.color='red'" onmouseout="this.style.color='black'" onclick="CapplClick('<%#Eval("seq")%>','<%#Eval("seq1")%>')">
                        <%#Eval("ap_cname1").ToString().CutData(10)%>
			        </td>
			        <td nowrap><%#Eval("apply_date","{0:d}")%></td>
			        <td nowrap><%#Eval("apply_no")%></td>
			        <td nowrap><%#Eval("issue_date","{0:d}")%></td>
			        <td nowrap><%#Eval("issue_no")%></td>	
			        <td nowrap><%#Eval("term2","{0:d}")%></td>		
			        <td nowrap><%#Eval("lscode")%></td>
			        <td nowrap><a href="brta61_Edit.aspx?submitTask=Q&prgid=<%=prgid%>&aseq=<%#Eval("seq")%>&aseq1=<%#Eval("seq1")%>&FrameBlank=50" target="Eblank">[查詢]</a></td>
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
    function CapplClick(pseq, pseq1) {
        window.showModalDialog(getRootPath() + "/brt5m/brt15ShowFP.aspx?prgid=<%=prgid%>&seq=" + pseq + "&seq1=" + pseq1 + "&submittask=Q", "", "dialogHeight: 540px; dialogWidth: 800px; center: Yes;resizable: No; status: No;scrollbars:yes");
    }
    function ResizePic(n) {
        var src = event.target || event.srcElement;
        if (n == 0) {
            src.width = 30;
            src.height = 30;
        } else {
            src.width = 100;
            src.height = 100;
        }
    }
    //[案件明細表列印]
    function show_report(){
        var urlasp = "brta65print.aspx?<%#Request.Form.ParseQueryString()%>";
        window.open(urlasp, "myWinPrintN", "width=750px, height=550px, top=10, left=10, toolbar=no, menubar=yes, location=no, directories=no, status=no,resizable=yes, scrollbars=yes");
    }
    //[下載Excel]
    function show_excel() {
        var urlasp = "brta65printExcel.aspx?<%#Request.Form.ParseQueryString()%>";
        window.open(urlasp, "myWinPrintN", "width=750px, height=550px, top=10, left=10, toolbar=no, menubar=yes, location=no, directories=no, status=no,resizable=yes, scrollbars=yes");
    }
</script>