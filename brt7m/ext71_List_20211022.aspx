<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<script runat="server">
    protected string HTProgCap = "一般請款單開立作業-請款案件選取";// HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "ext71";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";

    protected string SQL = "";

    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected Paging page = null;
    
    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";

    protected string submitTask = "";

    protected string qs_dept = "", modify="";
        
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

        conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
        cnn = new DBHelper(Conn.Sysctrl).Debug(Request["chkTest"] == "TEST");

        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");

        qs_dept = (Request["qs_dept"] ?? "").ToLower();
        modify = (Request["modify"] ?? "").ToUpper();
        if (qs_dept == "t") {
            HTProgCode = "Brt71";
        } else if (qs_dept == "e") {
            HTProgCode = "Ext71";
        }

        ReqVal["tfx_cust_area"] = ReqVal.TryGet("tfx_cust_area", Sys.GetSession("seBranch"));
        ReqVal["tfx_cust_seq"] = ReqVal.TryGet("tfx_cust_seq", ReqVal.TryGet("cust_seq"));
        
        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        HTProgCap = myToken.Title + "-請款案件選取";
        DebugStr = myToken.DebugStr;
        if (HTProgRight >= 0) {
            QueryData();
            PageLayout();

            this.DataBind();
        }
    }

    private void PageLayout() {
        if (modify == "U") {//追加選取
            if (qs_dept == "t") {
                if (ReqVal.TryGet("prg").ToLower() == "brt72") {//請款單護護
                    //***todo
                    StrFormBtnTop += "<a href=\"Brt72_Detail.aspx?ar_mark=" + Request["Type"] + "\">[回開立請款單]</a>";
                } else {
                    StrFormBtnTop += "<a href=\"Brt71_Detail.aspx?" + ReqVal.ParseQueryString() + "\">[回開立請款單]</a>";
                }
            } else if (qs_dept == "e") {
                if (ReqVal.TryGet("prg").ToLower() == "ext72") {//請款單護護
                    //***todo出口案
                    StrFormBtnTop += "<a href=\"Ext72_Detail.aspx?ar_mark=" + Request["Type"] + "\">[回開立請款單]</a>";
                } else {
                    //***todo出口案
                    StrFormBtnTop += "<a href=\"Ext71_Detail.aspx?" + ReqVal.ParseQueryString() + "\">[回開立請款單]</a>";
                }
            }
        } else {
            StrFormBtnTop += "<a href=\"" + HTProgPrefix + ".aspx?prgid=" + prgid + "&type=" + Request["type"] + "&qs_dept=" + Request["qs_dept"] + "\" >[回查詢]</a>";
        }
    }

    private void QueryData() {
        if (qs_dept == "t") {
            //2008/1/9業務出名代理人，修改收據別依交辦出名代理人對應抓取
            SQL = "SELECT b.seq,b.seq1,b.in_no,B.In_scode, B.case_no,b.arcase_type,b.arcase_class as ar_form,F.cust_name,'T'country,C.appl_name, B.Service, B.Fees, isnull(b.oth_money,0) as tr_money,B.arcase ";
            SQL += ",b.add_service,b.add_fees,B.ar_service,B.ar_fees,B.Service + B.Fees+isnull(b.oth_money,0) AS allcost,B.ar_mark, B.Cust_area, B.Cust_seq,D.remark as progpath ";
            SQL += ",(select Rs_detail from code_br where rs_code=b.arcase and cr='Y' and dept='T' and rs_type=b.arcase_type) as CArcase ";
            SQL += ",(select treceipt from agt where agt_no=c.agt_no) as receipt ";
            SQL += ",(select count(*) from account.dbo.artitem E where E.case_no = B.case_no and E.country = 'T') as cnt ";
            SQL += ",''fseq,''ap_cname,''strar_mark,''chkdisabled,''urlasp,''urlar ";
            SQL += "FROM Case_dmt B ";
            SQL += "INNER JOIN dmt_temp C ON B.In_no = C.in_no AND B.In_scode = C.in_scode and c.case_sqlno=0 ";
            SQL += "INNER JOIN cust_code D ON D.code_type = B.arcase_type and d.cust_code='__'  ";
            SQL += "INNER JOIN view_cust F on F.cust_area = B.cust_area and F.cust_seq=B.cust_seq ";
            if (ReqVal.TryGet("tobject") != "1") {//收據抬頭=案件申請人
                SQL += " inner join dmt_temp_ap E on b.in_no=e.in_no and e.case_sqlno=0";
            }
            SQL += " WHERE (B.stat_code = 'YZ') and b.ar_code='N' and b.in_scode='" + Request["scode"] + "' and (b.change is null or b.change='C' or b.change='N') ";
            if (modify == "U") {//追加選取
                if(ReqVal.TryGet("prg").ToLower()=="brt72"){//請款單護護
				    SQL += " and not exists (select * from account.dbo.artitem_temp A where a.ar_no = '" + Request["ar_no"] +  "' and a.branch = '" + Request["branch"] + "' and a.case_no=b.case_no and a.country='T') ";
			    }else{
                    SQL += " and not exists (select * from ar_temp a where a.dept='T' and a.ar_scode ='" + Session["scode"] + "' and a.ar_date = '" + DateTime.Today.ToShortDateString() + "' and a.case_no=b.case_no) ";
                }
            }
        }
        if (qs_dept == "e") {
            SQL = "SELECT b.seq,b.seq1,b.in_no,B.In_scode, B.case_no,B.Cust_area, B.Cust_seq,F.cust_name,C.country,C.appl_name, B.tot_Service as service, B.tot_Fees as fees ,isnull(b.oth_money,0) as tr_money, B.arcase,B.arcase_type ";
            SQL += ",b.add_service,b.add_fees,B.ar_service,B.ar_fees,B.tot_Service + B.tot_Fees+isnull(b.oth_money,0) AS allcost,b.ar_mark, ";
            SQL += ",D.Rs_detail as CArcase,D.rs_class as ar_form,b.arcase_class as prt_code, ";
            SQL += ",'' receipt ";
            SQL += ",(select count(*) from account.dbo.artitem E where E.case_no = B.case_no and E.country = C.country) as cnt ";
            SQL += ",''fseq,''ap_cname,''strar_mark,''chkdisabled,''urlasp,''urlar ";
            SQL += "FROM Case_ext B ";
            SQL += "INNER JOIN ext_temp C ON B.In_no = C.in_no AND B.In_scode = C.in_scode and c.case_sqlno=0 ";
            SQL += "INNER JOIN code_ext D ON B.Arcase = D.Rs_code and d.cr_flag='Y' and d.rs_type=b.arcase_type ";
            SQL += "INNER JOIN view_cust F on F.cust_area = B.cust_area and F.cust_seq=B.cust_seq ";
            if (ReqVal.TryGet("tobject") != "1") {//收據抬頭=案件申請人
                SQL += " inner join caseext_apcust E on b.in_no=e.in_no";
            }
            SQL += " WHERE (b.invoice_chk='B' or b.invoice_chk='C') and (B.stat_code = 'YZ' or B.stat_code like 'S%') and b.ar_code='N' and b.in_scode='" + Request["scode"] + "' and (b.change is null or b.change='C' or b.change='N') ";
            if (modify == "U") {//追加選取
                if (ReqVal.TryGet("prg").ToLower() == "ext72") {//請款單護護
                    SQL += " and not exists (select * from account.dbo.artitem_temp A where a.ar_no = '" + Request["ar_no"] + "' and a.branch = '" + Request["branch"] + "' and a.case_no=b.case_no and a.country=c.country) ";
                } else {
                    SQL += " and not exists (select * from are_temp A where a.dept='T' and a.ar_scode = '" + Session["scode"] + "' and a.ar_date = '" + DateTime.Today.ToShortDateString() + "' and a.case_no=b.case_no) ";
                }
            }
        }
        //2014/4/23增加會計檢核條件
        SQL += " and b.acc_chk='Y' ";
        if (ReqVal.TryGet("tar_mark") == "D") {//扣收入案件(不開收據)
            SQL += " and b.ar_mark = 'D' ";
        } else {
            SQL += " and b.ar_mark <> 'D' ";
        }

        SQL += " and b.cust_area = '" + ReqVal.TryGet("tfx_cust_area") + "' and b.cust_seq=" +ReqVal.TryGet("tfx_cust_seq") ;
        if (ReqVal.TryGet("tobject") != "1") {//收據抬頭=案件申請人
            SQL += " and e.apsqlno = " + Request["apsqlno"];
        }

        if (ReqVal.TryGet("scode") != "") {
            SQL += " and b.in_scode = '" + Request["scode"] + "'";
        }

        if (ReqVal.TryGet("sdate") != "") {
            SQL += " and b.case_date >='" + Request["sdate"] + "'";
        }

        if (ReqVal.TryGet("edate") != "") {
            SQL += " and b.case_date <='" + Request["edate"] + "'";
        }

        ReqVal["qryOrder"] = ReqVal.TryGet("SetOrder", ReqVal.TryGet("qryOrder"));
        if (ReqVal.TryGet("qryOrder") != "") {
            SQL += " order by " + ReqVal.TryGet("qryOrder");
        } else {
            SQL += " order by b.case_no";
        }
        Sys.showLog(SQL);
        conn.DataTable(SQL, dt);

        //處理分頁
        int nowPage = Convert.ToInt32(Request["GoPage"] ?? "1"); //第幾頁
        int PerPageSize = Convert.ToInt32(Request["PerPage"] ?? "20"); //每頁筆數
        page = new Paging(nowPage, PerPageSize, SQL);
        page.GetPagedTable(dt);

        //分頁完再處理其他資料才不會虛耗資源
        for (int i = 0; i < page.pagedTable.Rows.Count; i++) {
            DataRow dr = page.pagedTable.Rows[i];

            dr["fseq"] = Sys.formatSeq(dr.SafeRead("seq", ""), dr.SafeRead("seq1", ""), (dr.SafeRead("country", "") == "T" ? "" : dr.SafeRead("country", "")), "", "");

            ChkRecipt(dr);//檢查此收據種類可否開立收據
            GetAPCname(dr);//抓取接洽申請人檔

            string strar_mark = "";
            if (dr.SafeRead("ar_mark", "") != "N") {
                switch (dr.SafeRead("ar_mark", "")) {
                    case "A":
                    case "B": strar_mark = "<font color=red>實報實銷"; break;
                    case "C": strar_mark = "<font color=red>時程請款"; break;
                    case "D": strar_mark = "<font color=red>扣收入"; break;
                    case "M": strar_mark = "<font color=red>代收款"; break;
                    case "S": strar_mark = "<font color=red>專案指定代理人"; break;
                }
            }
            dr["strar_mark"] = strar_mark;//請款註記

            //交辦畫面連結
            if (qs_dept == "t") {
                dr["urlasp"] = Sys.getCaseDmt11Aspx(prgid, dr.SafeRead("in_no", ""), dr.SafeRead("in_scode", ""), "Show");
            }
            if (qs_dept == "e") {
                dr["urlasp"] = Sys.getCaseExt11Aspx(prgid, dr.SafeRead("in_no", ""), dr.SafeRead("in_scode", ""), "Show");
            }

            GetArLink(dr);//抓取已請款連結
        }
        
        dataRepeater.DataSource = page.pagedTable;
        dataRepeater.DataBind();
    }


    //檢查此收據種類可否開立收據
    protected void ChkRecipt(DataRow row) {
        string receipt = "", receipt_end_date = "";

        receipt = row.SafeRead("receipt", "");
        if (qs_dept == "t") {
            SQL = "select ar_company,end_date from account.dbo.ar_code where code_type='ar_code' and ar_code='" + row.SafeRead("receipt", "") + "'";
        }

        if (qs_dept == "e") {
            SQL = "select a.ar_code,a.ar_company";
            SQL += ",(select end_date from account.dbo.ar_code where code_type='ar_code' and ar_code=a.ar_code) as end_date ";
            SQL += "from account.dbo.ar_code a where code_type='ar_company' and branch ='" + Session["seBranch"] + "' and dept='TE'";
        }

        using (SqlDataReader dr0 = conn.ExecuteReader(SQL)) {
            if (dr0.Read()) {
                receipt_end_date = dr0.GetDateTimeString("end_date", "yyyy/M/d");
            }
        }

        if (receipt_end_date != "") {
            if (DateTime.Today > DateTime.Parse(receipt_end_date)) {
                row["chkdisabled"] = "disabled";
            }
        }
    }
    
    //抓取接洽申請人檔
    protected void GetAPCname(DataRow row) {
        string ap_cname = "";
        if (qs_dept == "t") {
            SQL = "select ap_cname1,ap_cname2 from dmt_temp_ap where in_no='" + row.SafeRead("in_no", "") + "' and case_sqlno=0";
            using (SqlDataReader dr0 = conn.ExecuteReader(SQL)) {
                while (dr0.Read()) {
                    ap_cname += (ap_cname != "" ? "、" : "");
                    ap_cname += dr0.SafeRead("ap_cname1", "") + dr0.SafeRead("ap_cname2", "");
                }
            }
        }

        if (qs_dept == "e") {
            SQL = "select ap_cname1,ap_cname2 from caseext_apcust where in_no='" + row.SafeRead("in_no", "") + "'";
            using (SqlDataReader dr0 = conn.ExecuteReader(SQL)) {
                while (dr0.Read()) {
                    ap_cname += (ap_cname != "" ? "、" : "");
                    ap_cname += dr0.SafeRead("ap_cname1", "") + dr0.SafeRead("ap_cname2", "");
                }
            }
        }

        row["ap_cname"] = ap_cname;
    }

    //已請款連結
    protected void GetArLink(DataRow row) {
        //***todo
        if (Convert.ToDecimal(row.SafeRead("cnt", "0")) > 0 && Convert.ToDecimal(row.SafeRead("ar_money", "0")) > 0) {
            string strcoun = (qs_dept == "t" ? "T" : row.SafeRead("country", ""));
            row["urlar"] = "<a href=\"Ext71Show.aspx?qs_dept=" + qs_dept + "&case_no=" + row.SafeRead("case_no", "") + "&country=" + row.SafeRead("country", "") + "\" target=\"Eblank\">" + row.SafeRead("ar_money", "0") + "(" + row.SafeRead("cnt", "0") + ")";
        } else {
            row["urlar"] = row.SafeRead("ar_money", "0");
        }
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

<form style="margin:0;" id="reg" name="reg" method="post">
    <input type="text" id="prgid" name="prgid" value="<%=prgid%>">
    <input type="text" id="qs_dept" name="qs_dept" value="<%=qs_dept%>">
    <input type="text" id="modify" name="modify" value="<%=modify%>">
    <input type=text id=tfx_cust_area name=tfx_cust_area value="<%=ReqVal.TryGet("tfx_cust_area")%>">
    <input type=text id=tfx_cust_seq name=tfx_cust_seq value="<%=ReqVal.TryGet("tfx_cust_seq")%>">
    <input type=text id=cust_seq name=cust_seq value="<%=ReqVal.TryGet("tfx_cust_seq")%>">
    <input type=text id=apsqlno name=apsqlno value="<%=ReqVal.TryGet("apsqlno")%>">
    <input type=text id=tobject name=tobject value="<%=ReqVal.TryGet("tobject")%>">
    <input type=text id=scode name=scode value="<%=ReqVal.TryGet("scode")%>">
    <input type=text id=rec_scode name=rec_scode value="<%=ReqVal.TryGet("scode")%>">
    <input type=text id=rec_chk1 name=rec_chk1 value="<%=ReqVal.TryGet("rec_chk1")%>">
    <input type=text id=tar_mark name=tar_mark value="<%=Request["tar_mark"]%>">
    <input type=text id=receipt name=receipt>
    <input type=text id=sdate name=sdate value="<%=ReqVal.TryGet("sdate")%>">
    <input type=text id=edate name=edate value="<%=ReqVal.TryGet("edate")%>">
    <input type=text id=row name=row value="<%#page.pagedTable.Rows.Count%>"> 
    <input type=text id=homelist name=homelist value="<%=Request["homelist"]%>">

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

<div align="center" id="noData" style="display:<%#page.totRow==0?"":"none"%>">
	<font color="red">=== 目前無資料 ===</font>
</div>

<asp:Repeater id="dataRepeater" runat="server">
<HeaderTemplate>
    <table style="display:<%#page.totRow==0?"none":""%>" border="0" class="bluetable" cellspacing="1" cellpadding="2" width="98%" align="center" id="dataList">
	    <thead>
            <Tr>
	            <td align="center" class="lightbluetable"></td>
	            <td align="center" class="lightbluetable">客戶名稱</td>
	            <td align="center" class="lightbluetable">申請人</td>    
	            <td align="center" class="lightbluetable">請款註記</td>  
  	            <td align="center" class="lightbluetable">案件編號</td>
  	            <td align="center" class="lightbluetable">案件名稱</td>
	            <td align="center" class="lightbluetable">案性</td>
	            <td align="center" class="lightbluetable">服務費</td>
	            <td align="center" class="lightbluetable">規費</td>
	            <td align="center" class="lightbluetable">轉帳費用</td>
	            <td align="center" class="lightbluetable">合計</td>
	            <td align="center" class="lightbluetable">已請款金額(次數)</td>
            </tr>
	    </thead>
	    <tbody>
</HeaderTemplate>
			<ItemTemplate>
 		        <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>">
	                <td class="whitetablebg" align="center">
		                <input type=checkbox id="T_<%#(Container.ItemIndex+1)%>" name="T_<%#(Container.ItemIndex+1)%>" <%#Eval("chkdisabled")%> value="Y" onclick="receipt_chk71('<%#(Container.ItemIndex+1)%>','<%#Eval("receipt")%>')">
	                    <input type=text id="inno_<%#(Container.ItemIndex+1)%>" name="inno_<%#(Container.ItemIndex+1)%>" value="<%#Eval("in_no")%>">
	                    <input type=text id="inscode_<%#(Container.ItemIndex+1)%>" name="inscode_<%#(Container.ItemIndex+1)%>" value="<%#Eval("in_scode")%>">
                        <input type=text id="receipt_<%#(Container.ItemIndex+1)%>" name="receipt_<%#(Container.ItemIndex+1)%>" value="<%#Eval("receipt")%>">
	                </td>
	                <td class="whitetablebg" align="center"><a href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("cust_name")%></a></td>
	                <td class="whitetablebg" align="center"><a href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("ap_cname")%></a></td>
	                <td class="whitetablebg" align="center"><a href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("strar_mark")%></a></td>
	                <td class="whitetablebg" align="center"><a href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("fseq")%></a></td>	
	                <td class="whitetablebg" align="center"><a href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("appl_name").ToString().Left(20)%></a></td>
	                <td class="whitetablebg" align="center"><a href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("CArcase")%></a></td>
	                <td class="whitetablebg" align="center"><a href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("service","{0:0}")%><%#(Convert.ToDecimal(Eval("add_service"))>0?"<font color=red>*</font>":"")%></a></td>
	                <td class="whitetablebg" align="center"><a href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("fees","{0:0}")%><%#(Convert.ToDecimal(Eval("add_fees"))>0?"<font color=red>*</font>":"")%></a></td>
	                <td class="whitetablebg" align="center"><a href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("tr_money")%></a></td>
	                <td class="whitetablebg" align="center"><a href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("allcost")%></a></td>
	                <td class="whitetablebg" align="center"><%#Eval("urlar")%></td>
				</tr>
			</ItemTemplate>
<FooterTemplate>
	    </tbody>
    </table>
	<BR>
    <table style="display:<%#page.totRow==0?"none":""%>" border="0" width="100%" cellspacing="0" cellpadding="0">
	    <tr>
	        <td align="center">
                <input type=button value ="下一步" class="cbutton" onClick="formupdate()">
                <input type=reset value ="重　填" class="cbutton" onClick="this_init()">
	            <br>
	            <br>
	        </td>
        </tr>
		<tr class="FormName"><td>
			<div align="left">
			    <font color='red'>*</font> 交辦案件無法勾選請款，表示該交辦案件之出名代理人所屬事務所別已被合併，請至交辦維護作業修改出名代理人後再請款!!<br>
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

</body>
</html>

<script language="javascript" type="text/javascript">
    $(function () {
        if (window.parent.tt !== undefined) {
            window.parent.tt.rows = "100%,0%";
        }

        this_init();
    });
    //執行查詢
    function goSearch() {
        $("#reg").submit();
    };

    function this_init() {
        $(".Lock").lock();
        $("input.dateField").datepick();
    }
    //////////////////////

    //檢查選取案件收據種類是否相同
    function receipt_chk71(curr,nreceipt){//curr目前筆數，nreceipt目前案性之收據種類
        if ($("#receipt").val()=="") {
            $("#receipt").val(nreceipt);
        }

        if($("#receipt").val() !=nreceipt){
            alert("該交辦案件之收據種類與已選取請款交辦案件收據種類不同，不能開立於同一請款單！");
            $("#T_"+tcount).prop("checked",false);
        }

        if ($("input[name^='T_']:checked").length == 0) $("#receipt").val("");
    }

    //[下一步]
    function formupdate(){
        var errMsg = "";
        if ($("input[name^='T_']:checked").length==0){
            errMsg+="尚未選定!!\n";
        }

        if (errMsg!="") {
            alert(errMsg);
            return false;
        }
        
        $(".bsubmit").lock(!$("#chkTest").prop("checked"));

        var url="";
        if ($("#qs_dept").val() == "t") {
            url = "Brt71_Detail.aspx?modify=A";
        } else if ($("#qs_dept").val() == "e") {
            url = "Ext71_Detail.aspx?modify=A";
        }
        reg.action = url;
        //reg.target = "Eblank";
        $("#reg").submit();
    }
</script>
