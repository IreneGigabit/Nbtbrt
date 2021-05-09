<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Linq"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>

<script runat="server">
    protected string HTProgCap = "案件交辦維護";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgCode = "brt52";//HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string HTProgPrefix = "brt52";//程式檔名前綴
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
        StrFormBtnTop += "<a href='" + HTProgPrefix + ".aspx?prgid=" + prgid + "'>[回上一頁]</a>";
    }

    private void QueryData() {
        DataTable dt = new DataTable();
            SQL = "SELECT a.seq,a.seq1,a.in_scode, a.in_no, a.service, a.fees,a.oth_money, b.appl_name,a.case_date,a.stat_code,a.arcase_type,a.arcase_class ";
            SQL += ",b.class, a.arcase, a.ar_mark, ISNULL(a.discount, 0) AS discount, d.cust_name ";
            SQL += ",a.case_num, a.stat_code, a.cust_area, a.cust_seq,a.case_no,a.ar_service,a.ar_fees,a.ar_code,a.ar_curr,a.mark ";
            SQL += ",(SELECT ChRelName FROM Relation WHERE ChRelType ='scode' AND chrelno = a.stat_code) AS Nstat_code ";
            SQL += ",(SELECT rs_class FROM code_br WHERE rs_code = a.arcase AND dept = 'T' AND cr = 'Y' AND rs_type=a.arcase_type) AS Ar_form ";
            SQL += ",(SELECT prt_code FROM code_br WHERE rs_code = a.arcase AND dept = 'T' AND cr = 'Y' AND rs_type=a.arcase_type) AS prt_code ";
            SQL += ",(SELECT mark FROM code_br WHERE rs_code = a.arcase AND dept = 'T' AND cr = 'Y' AND rs_type=a.arcase_type) AS codemark ";
            SQL += ",''link_remark,''arcodenm,''fseq,''fappl_name,''opt_stat,''urlasp,''step_grade ";
            SQL += " FROM case_dmt a ";
            SQL += " INNER JOIN dmt_temp b ON a.in_scode = b.in_scode AND a.in_no = b.in_no and b.case_sqlno=0 ";
            SQL += " INNER JOIN VIEW_Cust d ON a.cust_seq = d.cust_seq AND a.cust_area = d.cust_area ";
            SQL += " WHERE a.cust_area ='" + Request["tfx_Cust_area"] + "' and (a.stat_code = 'YY' or a.stat_code = 'YZ') ";
            SQL += " and (a.mark='N' or a.mark is null) and (a.change='C' or a.change='N' or a.change is null) ";
            if (ReqVal.TryGet("tfx_Cust_seq") != "") {
                SQL += " and a.cust_seq = '" + Request["tfx_Cust_seq"] + "'";
            }
            if (ReqVal.TryGet("scode") != "" && ReqVal.TryGet("scode") != "*") {
                SQL += " and a.in_scode = '" + Request["scode"] + "'";
            }
            if (ReqVal.TryGet("pfx_Cust_name") != "") {
                SQL += " and d.cust_name like '" + Request["pfx_Cust_name"] + "%'";
            }
            if (ReqVal.TryGet("sin_no") != "" && ReqVal.TryGet("ein_no") != "") {
                if (ReqVal.TryGet("new") == "in_no") {
                    SQL += " and a.in_no between '" + Request["sin_no"] + "' and '" + Request["ein_no"] + "'";
                } else if (ReqVal.TryGet("new") == "case_no") {
                    SQL += " and a.case_no between '" + Request["sin_no"] + "' and '" + Request["ein_no"] + "'";
                }
            }
            if (ReqVal.TryGet("sfx_seq") != "" && ReqVal.TryGet("sfx_seq1") != "") {
                if (ReqVal.TryGet("new") == "seq_no") {
                    SQL += " and a.seq='" + Request["sfx_seq"] + "' and a.seq1= '" + Request["sfx_seq1"] + "'";
                }
            }
            if (ReqVal.TryGet("ChangeDate") != "") {
                if (ReqVal.TryGet("ChangeDate") == "A") {
                    SQL += " and a.in_date between '" + Request["CustDate1"] + "' and '" + Request["CustDate2"] + "'";
                } else {
                    SQL += " and a.case_date between '" + Request["CustDate1"] + "' and '" + Request["CustDate2"] + "'";
                }
            }
            if (ReqVal.TryGet("qryOrder") != "") {
                SQL += " order by " + ReqVal.TryGet("qryOrder");
            } else {
                SQL += " order by a.in_no";
            }
            //Sys.showLog(SQL);
            conn.DataTable(SQL, dt);

            //處理分頁
            int nowPage = Convert.ToInt32(Request["GoPage"] ?? "1"); //第幾頁
            int PerPageSize = Convert.ToInt32(Request["PerPage"] ?? "10"); //每頁筆數
            page = new Paging(nowPage, PerPageSize, SQL);
            page.GetPagedTable(dt);

            //分頁完再處理其他資料才不會虛耗資源
            for (int i = 0; i < page.pagedTable.Rows.Count; i++) {
                SQL = "Select remark from cust_code where cust_code='__' and code_type='" + page.pagedTable.Rows[i]["arcase_type"] + "'";
                object objResult = conn.ExecuteScalar(SQL);
                string link_remark = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();
                page.pagedTable.Rows[i]["link_remark"] = link_remark;//案性版本連結

                page.pagedTable.Rows[i]["fseq"] = Sys.formatSeq1(page.pagedTable.Rows[i].SafeRead("seq", ""), page.pagedTable.Rows[i].SafeRead("seq1", ""), "", Sys.GetSession("seBranch"), Sys.GetSession("dept"));
                page.pagedTable.Rows[i]["fappl_name"] = page.pagedTable.Rows[i].SafeRead("appl_name", "").ToUnicode().Left(20);

                if (page.pagedTable.Rows[i].SafeRead("ar_code", "").Trim() == "N") {
                    page.pagedTable.Rows[i]["arcodenm"] = "未請款完畢";
                } else if (page.pagedTable.Rows[i].SafeRead("ar_code", "").Trim() == "M") {
                    page.pagedTable.Rows[i]["arcodenm"] = "大陸案另行請款";
                } else if (page.pagedTable.Rows[i].SafeRead("ar_code", "").Trim() == "X") {
                    page.pagedTable.Rows[i]["arcodenm"] = "不需請款";
                } else if (page.pagedTable.Rows[i].SafeRead("ar_code", "").Trim() == "Y") {
                    page.pagedTable.Rows[i]["arcodenm"] = "已請款完畢";
                }

                page.pagedTable.Rows[i]["opt_stat"] = GetOptStat(page.pagedTable.Rows[i]);

                //抓取客收進度for文件上傳
                SQL = "select step_grade from step_dmt ";
                SQL += "where seq='" + page.pagedTable.Rows[i]["seq"] + "' ";
                SQL += "and seq1='" + page.pagedTable.Rows[i]["seq1"] + "' ";
                SQL += "and case_no='" + page.pagedTable.Rows[i]["case_no"] + "' ";
                SQL += "and cg='C' and rs='R'";
                objResult = conn.ExecuteScalar(SQL);
                string step_grade = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();
                page.pagedTable.Rows[i]["step_grade"] = step_grade;
                
                page.pagedTable.Rows[i]["urlasp"] = GetLink(page.pagedTable.Rows[i]);
            }

            dataRepeater.DataSource = page.pagedTable;
            dataRepeater.DataBind();
    }

    protected string GetOptStat(DataRow row) {
		//2006/5/27配合爭救案系統，已交辦未發文前可修改交辦內容，已發文不能修改交辦內容
        string opt_stat = "";//交辦爭救案狀態
        if (row.SafeRead("codemark", "") == "B" && row.SafeRead("stat_code", "") == "YZ") {
            //抓取交辦專案室狀態
            SQL = "select opt_sqlno,opt_stat,opt_over_date from step_dmt ";
            SQL += "where branch='" + Session["seBranch"] + "' and seq=" + row["seq"] + " and seq1='" + row.SafeRead("seq1", "").Trim() + "' and cg='C' and rs='R' and case_no='" + row["case_no"] + "'";
            string opt_sqlno = "", opt_over_date = "";
            using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
                if (dr.Read()) {
                    opt_sqlno = dr.SafeRead("opt_sqlno", "");
                    opt_stat = dr.SafeRead("opt_stat", "");
                    opt_over_date = dr.SafeRead("opt_over_date", "");
                    if (opt_over_date != "") opt_stat = "S";
                }
            }
            if (opt_stat == "Y" && opt_over_date == "") {//已交辦專案室但區所未確認發文
                SQL = "select stat_code from br_opt where opt_sqlno=" + opt_sqlno;
                using (SqlDataReader dr = optconn.ExecuteReader(SQL)) {
                    if (dr.Read()) {
                        switch (dr.SafeRead("stat_code", "")) {
                            case "YS": opt_stat = "S"; break;//已發文
                            case "DD": opt_stat = ""; break;//註銷
                            default: opt_stat = "Y"; break;
                        }
                    }
                }
            }
        }
        
        return opt_stat;
    }
    protected string GetLink(DataRow row) {
        string urlasp = "";//連結的url
        string new_form = Sys.getCaseDmtAspx(row.SafeRead("arcase_type", ""), row.SafeRead("arcase", ""));//連結的aspx
        string link_remark = row.SafeRead("link_remark", "");

        if (row.SafeRead("stat_code", "") == "YY") {//已簽准.未客收確認
            urlasp = Page.ResolveUrl("~/brt1m" + link_remark + "/Brt11Edit" + new_form + ".aspx?prgid=" + prgid);
        } else {
            urlasp = Page.ResolveUrl("~/brt5m" + link_remark + "/Brt52EDIT" + new_form + ".aspx?prgid=" + prgid);
        }

        urlasp += "&in_scode=" + row["in_scode"];
        urlasp += "&in_no=" + row["in_no"];
        urlasp += "&case_no=" + row["case_no"];
        urlasp += "&seq=" + row["seq"];
        urlasp += "&seq1=" + row["seq1"];
        urlasp += "&add_arcase=" + row["arcase"];
        urlasp += "&cust_area=" + row["cust_area"];
        urlasp += "&cust_seq=" + row["cust_seq"];
        urlasp += "&ar_form=" + row["ar_form"];
        urlasp += "&new_form=" + new_form;
        urlasp += "&code_type=" + row["arcase_type"];
        urlasp += "&ar_code=" + row["ar_code"];
        urlasp += "&mark=" + row["mark"];
        urlasp += "&ar_service=" + row["ar_service"];
        urlasp += "&ar_fees=" + row["ar_fees"];
        urlasp += "&ar_curr=" + row["ar_curr"];
        urlasp += "&step_grade=" + row["step_grade"];
        urlasp += "&uploadtype=case";
        urlasp += "&submittask=Edit";

        return urlasp;
    }

    protected string GetNXLink(RepeaterItem Container) {
        string stat_code = Eval("stat_code").ToString();
        if (stat_code != "NN")
            return "<a href='" + Page.ResolveUrl("~/Brt4m/Brt13_ListA.aspx") +
                    "?in_scode=" + Eval("in_scode") +
                    "&in_no=" + Eval("in_no") +
                    "&qs_dept=T' target='Eblank'>"+Eval("Nstat_code")+"</a>";
        return "";
    }</script>

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
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/jquery.datepick.js")%>"></script>
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
            <Tr>
	            <td align="center" class="lightbluetable">接洽序號</td>
	            <td align="center" class="lightbluetable">交辦單號</td>		
	            <td align="center" class="lightbluetable">案件編號</td>	
	            <td align="center" class="lightbluetable">客戶名稱</td>
	            <td align="center" class="lightbluetable">案件名稱</td>
	            <td align="center" class="lightbluetable">類別</td>
	            <td align="center" class="lightbluetable">案性</td>
	            <td align="center" class="lightbluetable">服務費</td>
	            <td align="center" class="lightbluetable">規費</td>
	            <td align="center" class="lightbluetable">轉帳<br>費用</td>
	            <td align="center" class="lightbluetable">交辦日期</td>
	            <td align="center" class="lightbluetable">狀態</td>
            </tr>
	    </thead>
	    <tbody>
</HeaderTemplate>
			<ItemTemplate>
 		        <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>">
	                <td class="whitetablebg" align="center" style="cursor:pointer;color:blue" title="<%#Eval("arcodenm")%> 請款次數:<%#Eval("ar_curr")%>" onmouseover="this.style.color='red'" onmouseout="this.style.color='blue'"  onclick="case_no_Click('<%#Eval("opt_stat")%>','<%#Eval("urlasp")%>')"><%#Eval("In_scode")%>-<%#Eval("in_no")%></td>
	                <td class="whitetablebg" align="center"><%#Eval("case_no")%></td>
	                <td class="whitetablebg" align="center"><%#Eval("fseq")%></td>
	                <td class="whitetablebg" align="center" title="<%#Eval("cust_area")%>-<%#Eval("cust_seq")%>"><%#Eval("cust_name")%></td>
	                <td class="whitetablebg" align="center"><%#Eval("fappl_name")%></td>
	                <td class="whitetablebg" align="center"><%#Eval("Class")%></td>
	                <td class="whitetablebg" align="center"><%#Eval("Arcase")%></td>
	                <td class="whitetablebg" align="center"><%#Eval("service")%></A></td>
	                <td class="whitetablebg" align="center"><%#Eval("fees")%></A></td>
	                <td class="whitetablebg" align="center"><%#Eval("oth_money")%></A></td>
	                <td class="whitetablebg" align="center"><%#Eval("case_date","{0:yyyy/M/d}")%></td>
	                <td class="whitetablebg" align="center"><%#GetNXLink(Container)%></td>
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