<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<script runat="server">
    protected string HTProgCap = "交辦專案室爭救案品質評分表-明細表";// HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "Brt43";//HttpContext.Current.Request["prgid"] ?? "";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = HttpContext.Current.Request["prgid"] ?? "";//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";

    protected string SQL = "";

    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected Paging page = null;
    
    protected string StrFormBtnTop = "";
    
    protected string titleLabel = "";
    protected string submitTask = "";

    DBHelper connopt = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    private void Page_Unload(System.Object sender, System.EventArgs e) {
        if (connopt != null) connopt.Dispose();
    }
    
    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        connopt = new DBHelper(Conn.optK).Debug(Request["chkTest"] == "TEST");

        ReqVal = Util.GetRequestParam(Context,Request["chkTest"] == "TEST");
        submitTask = Request["submitTask"] ?? "";

        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        if (HTProgRight >= 0) {
            QueryData();
            ListPageLayout();

            this.DataBind();
        }
    }

    private void ListPageLayout() {
        if ((Request["submitTask"] ?? "") == "Q") {
            StrFormBtnTop += "<a class=\"imgCls\" href=\"javascript:void(0);\" >[關閉視窗]</a>";
        } else {
            StrFormBtnTop += "<a href=\"" + HTProgPrefix + ".aspx?prgid=" + prgid + "\" >[查詢]</a>";
        }

        //顯示查詢條件
        string qrybranch_name = "";
        if ((Request["qrybranch"] ?? "") == "N") {
            qrybranch_name = "&nbsp;<font color=blue>◎區所：</font>台北所";
        } else if ((Request["qrybranch"] ?? "") == "C") {
            qrybranch_name = "&nbsp;<font color=blue>◎區所：</font>台中所";
        } else if ((Request["qrybranch"] ?? "") == "S") {
            qrybranch_name = "&nbsp;<font color=blue>◎區所：</font>台南所";
        } else if ((Request["qrybranch"] ?? "") == "K") {
            qrybranch_name = "&nbsp;<font color=blue>◎區所：</font>高雄所";
        }

        string qryBseq_name = "";
        if ((Request["qryBseq"] ?? "").Trim() != "") {
            qryBseq_name = "&nbsp;<font color=blue>◎區所編號：</font>" + Request["qryBseq"];
        }
        if ((Request["qryBseq1"] ?? "").Trim() != "" && (Request["qryBseq1"] ?? "").Trim() != "_") {
            qryBseq_name += "-" + Request["qryBseq1"];
        }

        string qrycust_area_name = "";
        if ((Request["qrycust_area"] ?? "").Trim() != "") {
            qrycust_area_name = "&nbsp;<font color=blue>◎客戶編號：</font>" + Request["qrycust_area"];

            if ((Request["qrycust_seq"] ?? "").Trim() != "") {
                qrycust_area_name += "-" + Request["qrycust_seq"];
            }
        }

        string qryin_scode_name = "";
        if ((Request["qryin_scode"] ?? "") != "") {
            SQL = "select sc_name from sysctrl.dbo.scode where scode='" + Request["qryin_scode"] + "'";
            object objResult = connopt.ExecuteScalar(SQL);
            qryin_scode_name = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();
            qryin_scode_name = "&nbsp;<font color=blue>◎營洽：</font>" + qryin_scode_name;
        }

        string qrypr_scode_name = "";
        if ((Request["qrypr_scode"] ?? "") != "") {
            SQL = "select sc_name from sysctrl.dbo.scode where scode='" + Request["qrypr_scode"] + "'";
            object objResult = connopt.ExecuteScalar(SQL);
            qrypr_scode_name = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();
            qrypr_scode_name = "&nbsp;<font color=blue>◎承辦人：</font>" + qrypr_scode_name;
        }

        string qryAP_DATE_name = "";
        if ((ReqVal["qrySdate"] ?? "") != "" && (ReqVal["qryEdate"] ?? "") != "") {
            qryAP_DATE_name = "&nbsp;<font color=blue>◎判行日期：</font>" + ReqVal["qrySdate"] + "~" + ReqVal["qryEdate"];
        }

        titleLabel = "<font color=red>" + qrybranch_name + qryBseq_name +  qrycust_area_name +
            qryin_scode_name + qrypr_scode_name + qryAP_DATE_name + "</font>";
    }

    private void QueryData() {
        string back_flag = "";//用於判斷是從統計入,還是明細表入
        SQL = "SELECT a.Bseq,a.Bseq1,a.ap_cname,a.issue_no,a.appl_name,a.scode_name";
        SQL += ",a.pr_scode_name,a.score,a.opt_remark,a.branch,a.opt_sqlno";
        SQL += ",opt_no,case_no,a.in_scode,arcase ";
        SQL += ",''fseq,''optap_cname,''oappl_name,''link";
        SQL += " FROM vbr_opt as a ";
        SQL += "where a.bmark<>'B' and a.score_flag='Y' ";

        //2014/6/23增加交辦(分案)來源
        if ((Request["qrybr_source"] ?? "") != "") {
            SQL += " and a.br_source='" + Request["qrybr_source"] + "'";
        }
        if ((Request["qryBranch"] ?? "") != "") {
            SQL += " and a.branch='" + Request["qryBranch"] + "'";
        }
        if ((Request["qryBseq"] ?? "").Trim() != "") {
            SQL += " and a.Bseq='" + Request["qryBseq"] + "'";
        }
        if ((Request["qryBseq1"] ?? "").Trim() != "") {
            SQL += " and a.Bseq1='" + Request["qryBseq1"] + "'";
        }
        if ((Request["qrycust_area"] ?? "") != "") {
            SQL += " and a.cust_area='" + Request["qrycust_area"] + "'";
        }
        if ((Request["qrycust_seq"] ?? "").Trim() != "") {
            SQL += " and a.cust_seq='" + Request["qrycust_seq"] + "'";
        }
        if ((Request["qryin_scode"] ?? "") != "") {
            SQL += " and a.in_scode='" + Request["qryin_scode"] + "'";
        }
        if ((Request["qryPr_scode"] ?? "") != "") {
            SQL += " and a.Pr_scode='" + Request["qryPr_scode"] + "'";
        }
        if ((Request["month"] ?? "") != "") {
            SQL += " and year(a.ap_date)='" + Request["qryYear"] + "'";
        }
        if ((Request["month"] ?? "") != "") {
            SQL += " and month(a.ap_date)='" + Request["month"].Trim() + "' ";
            ReqVal["qrySdate"] = Request["qryYear"] + "/" + Request["month"].Trim() + "/1"; //上個月一號
            ReqVal["qryEdate"] = new DateTime(Convert.ToInt32(Request["qryYear"].ToString()), Convert.ToInt32(Request["month"].Trim()), 1).AddMonths(1).AddDays(-1).ToShortDateString();
        } else {
            if ((Request["SubmitTask"] ?? "") == "Q") {//從統計表來
                ReqVal["qrySdate"] = Request["qryYear"] + "/" + Request["qrysMonth"].Trim() + "/1"; //上個月一號
                ReqVal["qryEdate"] = new DateTime(Convert.ToInt32(Request["qryYear"].ToString()), Convert.ToInt32(Request["qryeMonth"].Trim()), 1).AddMonths(1).AddDays(-1).ToShortDateString();
            }
            if (ReqVal.TryGet("qrySdate", "") != "") {
                SQL += " and a.AP_DATE>='" + ReqVal.TryGet("qrySdate", "") + "' ";
            }
            if (ReqVal.TryGet("qryeDATE", "") != "") {
                SQL += " and a.AP_DATE<='" + ReqVal.TryGet("qryeDATE", "") + "' ";
            }
        }

        if ((Request["SubmitTask"] ?? "") == "Q") {//從統計表來
            SQL += " and a.form_name is not null ";
        }

        if ((Request["qryprint"] ?? "") == "2") {
            back_flag = "";
        } else {
            back_flag = "Y";
        }

        ReqVal["qryOrder"] = ReqVal.TryGet("SetOrder", ReqVal.TryGet("qryOrder", "AP_DATE,bseq"));
        if (ReqVal.TryGet("qryOrder", "") != "") {
            SQL += " order by " + ReqVal.TryGet("qryOrder", "");
        }

        DataTable dt = new DataTable();
        connopt.DataTable(SQL, dt);

        //處理分頁
        int nowPage = Convert.ToInt32(Request["GoPage"] ?? "1"); //第幾頁
        int PerPageSize = Convert.ToInt32(Request["PerPage"] ?? "10"); //每頁筆數
        page = new Paging(nowPage, PerPageSize, SQL);
        page.GetPagedTable(dt);

        //分頁完再處理其他資料才不會虛耗資源
        for (int i = 0; i < page.pagedTable.Rows.Count; i++) {
            DataRow dr = page.pagedTable.Rows[i];

            //組本所編號
            dr["fseq"] = Sys.formatSeq(dr.SafeRead("Bseq", ""), dr.SafeRead("Bseq1", ""), "", dr.SafeRead("Branch", ""), Sys.GetSession("dept"));

            SQL = "select ap_cname from caseopt_ap where opt_sqlno=" + dr.SafeRead("opt_sqlno", "");
            string ap_cname = "";
            using (SqlDataReader dr0 = connopt.ExecuteReader(SQL)) {
                while (dr0.Read()) {
                    ap_cname += (ap_cname != "" ? "、" : "") + dr0.SafeRead("ap_cname", "").Trim();
                }
            }

            //申請人
            dr["ap_cname"] = ap_cname;
            dr["optap_cname"] = ap_cname.CutData(20);
            //案件名稱
            dr["oappl_name"] = dr.SafeRead("appl_name", "").CutData(20);
            //連結
            string urlasp = "opt_sqlno=" + dr.SafeRead("opt_sqlno", "") +
                    "&opt_no=" + dr.SafeRead("opt_no", "") +
                    "&branch=" + dr.SafeRead("branch", "") +
                    "&case_no=" + dr.SafeRead("case_no", "") +
                    "&arcase=" + dr.SafeRead("arcase", "") +
                    "&prgid=" + prgid + "&Submittask=Q&back_flag=" + back_flag;
            if (dr.SafeRead("case_no", "") != "") {
                urlasp = "opt22Edit.aspx?" + urlasp;
            } else {
                urlasp = "opt22EditA.aspx?" + urlasp;
            }
            dr["link"] = "<a href='" + urlasp + "' target='Eblank'>";
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
    <tr>
        <td colspan="2"><%#titleLabel%></td>
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
        <table style="display:<%#page.totRow==0?"none":""%>" border="0" class="bluetable" cellspacing="1" cellpadding="2" width="98%" align="center" id="dataList">
	        <thead>
                <Tr class="lightbluetable">
	                <td nowrap align="center">區所編號</td>
	                <td nowrap align="center">申請人</td> 
	                <td nowrap align="center">註冊號</td> 
	                <td nowrap align="center">案件名稱</td> 
	                <td nowrap align="center">營洽</td>
	                <td nowrap align="center">承辦人</td> 
	                <td nowrap align="center">評分</td> 
	                <td nowrap align="center">案件缺失及評語</td> 
                </tr>
	        </thead>
	        <tbody>
    </HeaderTemplate>
			    <ItemTemplate>
 		            <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>">
		                <td align="center"><%#Eval("link")%><%#Eval("fseq")%></a></td>
		                <td title="<%#Eval("ap_cname")%>"><%#Eval("link")%><%#Eval("optap_cname")%></a></td>
		                <td><%#Eval("link")%><%#Eval("issue_no")%></a></td>
		                <td title="<%#Eval("appl_name")%>"><%#Eval("link")%><%#Eval("oappl_name")%></a></td>
		                <td align="center"><%#Eval("link")%><%#Eval("scode_name")%></a></td>
		                <td align="center"><%#Eval("link")%><%#Eval("pr_scode_name")%></a></td>
		                <td align="center"><%#Eval("link")%><%#Eval("score")%></a></td>
		                <td><%#Eval("link")%><%#Eval("opt_remark")%></a></td>
				    </tr>
			    </ItemTemplate>
    <FooterTemplate>
	        </tbody>
        </table>
        <br />
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
            if ($("#submittask").val() == "Q" || $("#submitTask").val() == "Q") {
                window.parent.tt.rows = "30%,70%";
            } else {
                window.parent.tt.rows = "100%,0%";
            }
        }
    });

    //執行查詢
    function goSearch() {
        $("#regPage").submit();
    };
    //////////////////////
</script>
