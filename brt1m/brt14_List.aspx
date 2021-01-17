<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Linq"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>

<script runat="server">
    protected string HTProgCap = HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgCode = "brt14";//HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string HTProgPrefix = "brt14";//程式檔名前綴
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";

    protected string SQL = "";
    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected Paging page = null;

    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";
    protected string FormName = "";
    
    DBHelper cnn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    private void Page_Unload(System.Object sender, System.EventArgs e) {
        if (cnn != null) cnn.Dispose();
    }

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        cnn = new DBHelper(Conn.Sysctrl).Debug(Request["chkTest"] == "TEST");
        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");

        TokenN myToken = new TokenN(HTProgCode);
        myToken.CheckMe(false);
        HTProgCap = myToken.Title;
        DebugStr = myToken.DebugStr;
        if (HTProgRight >= 0) {
            PageLayout();
            QueryData();
            this.DataBind();
        }
    }

    private void PageLayout() {
        StrFormBtnTop += "<a href=" + HTProgPrefix + ".aspx>[回上一頁]</a>";
    }

    private void QueryData() {
        DataTable dt = new DataTable();
        using (DBHelper conn = new DBHelper(Conn.btbrt).Debug(false)) {
            //2009/2/25因FW1有交辦畫面且有申請書，所以修改原code_br的where條件prt_code not in ('null','ZZ','D9Z','D3')
            SQL = "SELECT a.in_scode, a.in_no, a.service, a.fees,a.oth_money,a.arcase_type,a.arcase_class, b.appl_name,";
            SQL += " b.class, a.arcase, a.ar_mark, ISNULL(a.discount, 0) AS discount,";
            SQL += " a.case_num, a.stat_code, a.cust_area, a.cust_seq, ";
            SQL += " a.discount_chk, d.cust_name, a.in_date,a.seq,a.seq1,";
            SQL += " e.rs_detail AS case_name,";
            SQL += " e.rs_class  AS Ar_form,";
            SQL += " e.prt_code  AS prt_code,";
            SQL += " e.reportp  AS reportp,";
            SQL += " e.classp, ";
            SQL += " isnull((select send_sel from attcase_dmt at where at.in_scode = a.in_scode AND at.in_no=a.in_no and at.sign_stat='NN') , ";
            SQL += "        (select send_sel from step_dmt s where s.seq=a.seq and s.seq1=a.seq1 and s.case_no=a.case_no and s.cg='C' and s.rs='R')) send_sel ";
            SQL += ",''link_remark,''fseq,''fcust_name,''fappl_name,''urlasp,''prturl ";
            SQL += " FROM case_dmt a ";
            SQL += " INNER JOIN dmt_temp b ON a.in_scode = b.in_scode AND a.in_no = b.in_no ";
            SQL += " inner join code_br e on e.rs_code=a.arcase AND e.dept = 'T' AND e.cr = 'Y' and e.no_code = 'N' and e.rs_type=a.arcase_type and e.prt_code not in ('null','D9Z','D3') and ((reportp is not null and reportp<>'') or (classp is not null and classp<>'')) ";
            SQL += " INNER JOIN VIEW_Cust d ON a.cust_seq = d.cust_seq AND a.cust_area = d.cust_area";
            SQL += " LEFT OUTER JOIN case_fee c ON a.arcase = c.rs_code and c.dept = 'T' AND c.country = 'T' AND (GETDATE() BETWEEN c.beg_date AND c.end_date) ";
            if (Request["tfx_new"] != "" && Request["homelist"] == "homelist") {
                SQL += " left join attcase_dmt at on a.in_no=at.in_no and isnull(at.sign_stat,'') not in('XX') ";
            }
            SQL += " WHERE 1=1 ";
            if (Request["tfx_in_scode"] != "") {
                SQL += " AND a.in_scode = '" + Request["tfx_in_scode"] + "'";
            }
            if (Request["tfx_Arcase"] != "") {
                SQL += " AND a.Arcase = '" + Request["tfx_Arcase"] + "'";
            }
            if (Request["tfx_new"] != "") {
                SQL += " AND a.new = '" + Request["tfx_new"] + "'";
            }
            if (Request["tfx_seq"] != "") {
                SQL += " AND a.seq = '" + Request["tfx_seq"] + "'";
            }
            if (Request["tfx_seq1"] != "") {
                SQL += " AND a.seq1 = '" + Request["tfx_seq1"] + "'";
            }
            if (Request["sfx_in_no"] != "") {
                SQL += " AND a.in_no >= '" + Request["sfx_in_no"] + "'";
            }
            if (Request["efx_in_no"] != "") {
                SQL += " AND a.in_no <= '" + Request["efx_in_no"] + "'";
            }
            if (Request["sfx_in_date"] != "") {
                SQL += " AND a.in_date >= '" + Request["sfx_in_date"] + "'";
            }
            if (Request["efx_in_date"] != "") {
                SQL += " AND a.in_date <= '" + Request["efx_in_date"] + "'";
            }
            if (Request["tfx_new"] != "" && Request["homelist"] == "homelist") {
                SQL += " and a.new='" + Request["tfx_new"] + "'";
                SQL += " and e.prt_code not in ('null','ZZ','D9Z','D3') ";
                SQL += " and isnull(at.sign_stat,'') not in('SZ') ";
            }
            SQL += " and (a.mark='N' or a.mark is null) And case_sqlno=0 ";
            //因為出席聽證有交辦畫面但是不用有申請書
            SQL += " and a.arcase not in ('DE2','AD8')";


            //Sys.showLog(SQL);
            conn.DataTable(SQL, dt);

            //處理分頁
            int nowPage = Convert.ToInt32(Request["GoPage"] ?? "1"); //第幾頁
            int PerPageSize = Convert.ToInt32(Request["PerPage"] ?? "10"); //每頁筆數
            page = new Paging(nowPage, PerPageSize, string.Join(";", conn.exeSQL.ToArray()));
            page.GetPagedTable(dt);

            //分頁完再處理其他資料才不會虛耗資源
            for (int i = 0; i < page.pagedTable.Rows.Count; i++) {
                int ctrl_rowspan = 1;
                SQL = "Select remark from cust_code where cust_code='__' and code_type='" + page.pagedTable.Rows[i]["arcase_type"] + "'";
                object objResult = conn.ExecuteScalar(SQL);
                string link_remark = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();
                page.pagedTable.Rows[i]["link_remark"] = link_remark;//案性版本連結

                page.pagedTable.Rows[i]["fseq"] = Sys.formatSeq1(page.pagedTable.Rows[i].SafeRead("seq", "") ,page.pagedTable.Rows[i].SafeRead("seq1", ""),"",Sys.GetSession("seBranch"),Sys.GetSession("dept"));
                page.pagedTable.Rows[i]["fcust_name"] = page.pagedTable.Rows[i].SafeRead("cust_name", "").ToUnicode().Left(5);
                page.pagedTable.Rows[i]["fappl_name"] = page.pagedTable.Rows[i].SafeRead("appl_name", "").ToUnicode().Left(20);

                page.pagedTable.Rows[i]["urlasp"] = GetLink(page.pagedTable.Rows[i]);
                page.pagedTable.Rows[i]["prturl"] = GetPrintLink(page.pagedTable.Rows[i]);
            }

            dataRepeater.DataSource = page.pagedTable;
            dataRepeater.DataBind();
        }
    }

    protected string GetLink(DataRow row) {
        string urlasp = "";//連結的url
        string new_form = Sys.getCaseDmtAspx(row.SafeRead("arcase_type", ""), row.SafeRead("arcase", ""));//連結的aspx
        urlasp = Page.ResolveUrl("~/brt1m" + row["link_remark"] + "/Brt11Edit" + new_form + ".aspx?prgid=" + prgid);
        urlasp += "&in_scode=" + row["in_scode"];
        urlasp += "&in_no=" + row["in_no"];
        urlasp += "&add_arcase=" + row["arcase"];
        urlasp += "&cust_area=" + row["cust_area"];
        urlasp += "&cust_seq=" + row["cust_seq"];
        urlasp += "&ar_form=" + row["ar_form"];
        urlasp += "&new_form=" + new_form;
        urlasp += "&code_type=" + row["arcase_type"];
        urlasp += "&homelist=" + Request["homelist"];
        urlasp += "&uploadtype=case";
        urlasp += "&submittask=Show";
        
        return urlasp;
    }
    
    protected string GetPrintLink(DataRow row) {
        string prtUrl = "";//列印的url
        //有電子申請書優先
        if(row.SafeRead("classp", "")!=""){
            prtUrl=Page.ResolveUrl("~/Report/Print_" + row["classp"] + ".aspx?in_scode=" + row["in_scode"] + "&in_no=" + row["in_no"] + "&seq=" + row["seq"] + "&seq1=" + row["seq1"] + "&send_sel=" + row["send_sel"]);
        }else if(row.SafeRead("reportp", "")!=""){//紙本申請書
            if(row.SafeRead("prt_code", "")!="ZZ"&&row.SafeRead("prt_code", "")!="D9Z"&&row.SafeRead("ar_form", "")!="D3"){
             prtUrl=Page.ResolveUrl("~/Report-word/Print_" + row["reportp"] + ".asp?in_scode1=" + row["in_scode"] + "&in_no1=" + row["in_no"]);
            }
        }
        return prtUrl;
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title><%=HTProgCap%></title>
<link rel="stylesheet" type="text/css" href="<%=Page.ResolveUrl("~/inc/setstyle.css")%>" />
<link rel="stylesheet" type="text/css" href="<%=Page.ResolveUrl("~/js/lib/jquery.datepick.css")%>" />
<link rel="stylesheet" type="text/css" href="<%=Page.ResolveUrl("~/js/lib/toastr.css")%>" />
<link rel="stylesheet" type="text/css" href="<%=Page.ResolveUrl("~/js/lib/jquery-ui.min.css")%>" />
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/jquery-1.12.4.min.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/jquery-ui.min.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/jquery.datepick.min.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/jquery.datepick-zh-TW.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/toastr.min.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/util.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/jquery.irene.form.js")%>"></script>
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
                    <input type="hidden" name="SetOrder" id="SetOrder" value="<%#ReqVal.TryGet("qryOrder", "")%>" />
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
            <Tr>
                <td align="center" class="lightbluetable">作業</td>
	            <td align="center" class="lightbluetable">案件編號</td>
	            <td align="center" class="lightbluetable">營洽薪號-接洽序號</td>
	            <td align="center" class="lightbluetable">接洽日期</td>	
	            <td align="center" class="lightbluetable">客戶名稱</td>
	            <td align="center" class="lightbluetable">案件名稱</td>
	            <td align="center" class="lightbluetable">類別</td>
	            <td align="center" class="lightbluetable">案性</td>
	            <td align="center" class="lightbluetable">服務費</td>
	            <td align="center" class="lightbluetable">規費</td>
	            <td align="center" class="lightbluetable">轉帳<br>費用</td>
	            <td align="center" class="lightbluetable">合計</td>
            </tr>
	    </thead>
	    <tbody>
</HeaderTemplate>
			<ItemTemplate>
 		        <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>">
		            <td class="whitetablebg" align="center">[<a href="<%#Eval("prturl")%>" target="Eblank">列印</a>]</td>
		            <td class="whitetablebg" align="center"><a href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("fseq")%></A></td>
		            <td class="whitetablebg" align="center"><a href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("in_scode")%>-<%#Eval("in_no")%></A></td>
		            <td class="whitetablebg" align="center"><a href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("in_date", "{0: yyyy/MM/dd}")%></A></td>
		            <td class="whitetablebg" align="center"><a href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("fcust_name")%></A></td>
		            <td class="whitetablebg" align="center"><a href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("fappl_name")%></A></td>
		            <td class="whitetablebg" align="center"><a href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("class")%></A></td>
		            <td class="whitetablebg" align="center"><a href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("case_name")%></A></td>
		            <td class="whitetablebg" align="center"><a href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("service")%></A></td>
		            <td class="whitetablebg" align="center"><a href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("fees")%></A></td>
		            <td class="whitetablebg" align="center"><a href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("oth_money")%></A></td>
		            <td class="whitetablebg" align="center"><%#Convert.ToInt32(Eval("fees"))+Convert.ToInt32(Eval("service"))+Convert.ToInt32(Eval("oth_money"))%></TD>

				</tr>
			</ItemTemplate>
<FooterTemplate>
	    </tbody>
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

        $("input[name='signid']:checked").triggerHandler("click");
        $(".Lock").lock();
        $("input.dateField").datepick();
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

    //關閉視窗
    $(".imgCls").click(function (e) {
        if (window.parent.tt !== undefined) {
            window.parent.tt.rows = "100%,0%";
        } else {
            window.close();
        }
    })
</script>