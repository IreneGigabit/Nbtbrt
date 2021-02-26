<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Collections.Generic"%>

<script runat="server">
    protected string HTProgCap = "國內案收文作業-後續交辦查詢結果畫面";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string Title = "";

    protected string SQL = "";

    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected Paging page = null;

    protected string cgrs = "";
    protected string seq = "";
    protected string seq1 = "";
    protected string cust_seq = "";
    protected string ap_cname1 = "";
    protected string s_mark = "";
    protected string appl_name = "";
    protected string kind_date = "";
    protected string sdate = "";
    protected string edate = "";
    protected string qrytype = "";
    protected string grconf_sqlno = "";

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        cgrs = Request["cgrs"] ?? "";
        seq = Request["seq"] ?? "";
        seq1 = Request["seq1"] ?? "";
        cust_seq = Request["cust_seq"] ?? "";
        ap_cname1 = Request["ap_cname1"] ?? "";
        s_mark = Request["s_mark"] ?? "";
        appl_name = Request["appl_name"] ?? "";
        kind_date = Request["kind_date"] ?? "";
        sdate = Request["sdate"] ?? "";
        edate = Request["edate"] ?? "";
        qrytype = Request["qrytype"] ?? "";
        grconf_sqlno = Request["grconf_sqlno"] ?? "";

        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");

        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        Title = myToken.Title;

        if (HTProgRight >= 0) {
            QueryData();

            this.DataBind();
        }
    }

    private void QueryData() {
        using (DBHelper conn = new DBHelper(Conn.btbrt, false).Debug(Request["chkTest"] == "TEST")) {
            SQL = "select a.seq,a.seq1,a.cappl_name as appl_name,a.cust_area,a.cust_seq,a.apply_no,a.ap_cname1 ";
            SQL += ",a.step_date,a.rs_detail,c.grconf_sqlno,c.step_grade,''fseq ";
            SQL += " from vstep_dmt a ";
            SQL += " inner join grconf_dmt c on a.seq=c.seq and a.seq1=c.seq1 and a.step_grade=c.step_grade ";
            SQL += " where c.job_type='case' ";
            if (qrytype == "Q") {
                SQL += " and (c.job_no is null or c.job_no='') ";
            }
            if (qrytype == "S") {
                SQL += " and c.grconf_sqlno=" + grconf_sqlno;
            }
            if (seq != "") {
                SQL += " and a.seq like '" + seq + "%'";
            }
            if (seq1 != "") {
                SQL += " and a.seq1 like '" + seq1 + "%'";
            }
            if (cust_seq != "") {
                SQL += " and a.cust_seq = '" + cust_seq + "'";
            }
            if (ReqVal.TryGet("SetOrder") != "") {
                SQL += " order by " + ReqVal.TryGet("SetOrder");
            } else {
                SQL += " order by a.seq,a.seq1";
            }

            DataTable dt = new DataTable();
            conn.DataTable(SQL, dt);

            //處理分頁
            int nowPage = Convert.ToInt32(Request["GoPage"] ?? "1"); //第幾頁
            int PerPageSize = Convert.ToInt32(Request["PerPage"] ?? "10"); //每頁筆數
            page = new Paging(nowPage, PerPageSize, SQL);
            page.GetPagedTable(dt);

            //分頁完再處理其他資料才不會虛耗資源
            for (int i = 0; i < page.pagedTable.Rows.Count; i++) {
                page.pagedTable.Rows[i]["fseq"] = Sys.formatSeq(page.pagedTable.Rows[i].SafeRead("Seq", "")
                    , page.pagedTable.Rows[i].SafeRead("Seq1", "")
                    , ""
                    , Sys.GetSession("SeBranch")
                    , "T"
                    );
            }

            dataRepeater.DataSource = page.pagedTable;
            dataRepeater.DataBind();
        }
    }
</script>
<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta http-equiv="x-ua-compatible" content="IE=10">
<title><%=HTProgCap%></title>
<link rel="stylesheet" type="text/css" href="<%=Page.ResolveUrl("~/inc/setstyle.css")%>" />
<link rel="stylesheet" type="text/css" href="<%=Page.ResolveUrl("~/js/lib/jquery.datepick.css")%>" />
<link rel="stylesheet" type="text/css" href="<%=Page.ResolveUrl("~/js/lib/toastr.css")%>" />
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/jquery-1.12.4.min.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/jquery.datepick.min.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/jquery.datepick-zh-TW.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/toastr.min.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/util.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/jquery.irene.form.js")%>"></script>
</head>

<body>
<table cellspacing="1" cellpadding="0" width="98%" border="0">
    <tr>
        <td class="text9" nowrap="nowrap">&nbsp;【<%=prgid%><%=Title%>】<span style="color:blue"><%=HTProgCap%></span></td>
        <td class="FormLink" valign="top" align="right" nowrap="nowrap">
            <a class="imgCls" href="javascript:void(0);" >[關閉視窗]</a>
        </td>
    </tr>
    <tr>
        <td colspan="2"><hr class="style-one"/></td>
    </tr>
</table>
<form id="regPage" name="regPage" method="post">
    <%#page.GetHiddenText("GoPage,PerPage,SetOrder")%>
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
                </font>
            </td>
        </tr>
    </TABLE>
    </div>
</form>

    <div align="center" id="noData" style="display:<%#page.totRow==0?"":"none"%>">
	    <font color="red">=== 查無案件資料 ===</font>
    </div>

    <asp:Repeater id="dataRepeater" runat="server">
    <HeaderTemplate>
        <table style="display:<%#page.totRow==0?"none":""%>" border="0" class="bluetable" cellspacing="1" cellpadding="2" width="98%" align="center" id="dataList">
	        <thead>
                <TR>
		            <TD class=lightbluetable align=center>本所編號</TD>
		            <TD class=lightbluetable align=center>收文日期</TD>
		            <TD class=lightbluetable align=center>案件名稱</TD>
		            <TD class=lightbluetable align=center>客戶</TD>
		            <TD class=lightbluetable align=center>收文內容</TD>
		            <TD class=lightbluetable align=center>詳細資料</TD>
	            </TR>
	        </thead>
	        <tbody>
    </HeaderTemplate>
			    <ItemTemplate>
                    <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>" align="center">
			            <td style="cursor:pointer;background-color:white" onmouseover="this.style.color='red'" onmouseout="this.style.color='black'" nowrap onclick="SeqClick(<%#Eval("Seq")%>,'<%#Eval("Seq1")%>','<%#Eval("grconf_sqlno")%>')">
                            <%#Eval("fseq")%><br><font style="color:blue;font-size:9pt">(序號：<%#Eval("grconf_sqlno")%>)</font>
			            </td>
			            <td nowrap><%#Eval("step_date", "{0:d}")%></td>
			            <td ><%#Eval("appl_name")%></td>
			            <td ><%#Eval("ap_cname1")%></td>
			            <td ><%#Eval("rs_detail")%></td>
			            <td nowrap style="cursor:pointer;background-color:white" onmouseover="this.style.color='red'" onmouseout="this.style.color='black'"  onclick="grconfClick(<%#Eval("seq")%>,'<%#Eval("seq1")%>',<%#Eval("grconf_sqlno")%>,<%#Eval("step_grade")%>)">
                            [詳細資料]
			            </td>
		            </tr>
			    </ItemTemplate>
    <FooterTemplate>
	        </tbody>
        </table>
    <br>
    <p style="text-align:center;display:<%#page.totRow==0?"none":""%>">
	    <font color=blue>*** 請點選本所編號將資料帶回洽案作業 ***</font>
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
        theadOdr();//設定表頭排序圖示
    });

    //執行查詢
    function goSearch() {
        $("#regPage").submit();
    };
    //每頁幾筆
    $("#PerPage").change(function (e) {
        goSearch();
    });
    //指定第幾頁
    $("#divPaging").on("change", "#GoPage", function (e) {
        goSearch();
    });
    //上下頁
    $(".pgU,.pgD").click(function (e) {
        $("#GoPage").val($(this).attr("v1"));
        goSearch();
    });
    //排序
    $(".setOdr").click(function (e) {
        //$("#dataList>thead tr .setOdr span").remove();
        //$(this).append("<span class='odby'>▲</span>");
        $("#SetOrder").val($(this).attr("v1"));
        goSearch();
    });
    //設定表頭排序圖示
    function theadOdr() {
        $(".setOdr").each(function (i) {
            $(this).remove("span.odby");
            if ($(this).attr("v1").toLowerCase() == $("#SetOrder").val().toLowerCase()) {
                $(this).append("<span class='odby'>▲</span>");
            }
        });
    }
    //重新整理
    $(".imgRefresh").click(function (e) {
        goSearch();
    });

    //關閉視窗
    $(".imgCls").click(function (e) {
        if (window.parent.tt !== undefined) {
            window.parent.tt.rows = "100%,0%";
        } else {
            window.close();
        }
    })

    function SeqClick(x1,x2,x4){
        if("<%=qrytype%>"=="Q"){
            window.opener.reg.grconf_sqlno.value = x4;
            window.close();
        }
    }
    //[詳細資料]
    function grconfClick(x1, x2, x3, x4) {
        //**todo**
        window.showModalDialog("brt15Edit.asp?prgid=<%=prgid%>&seq=" + x1 + "&seq1=" + x2 + "&grconf_sqlno=" + x3 + "&step_grade=" + x4 + "&submittask=Q&closewin=Y", "", "dialogHeight: 520px; dialogWidth: 800px; center: Yes;resizable: No; status: No;scrollbars=yes");
    }
</script>
