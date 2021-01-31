<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>

<script runat="server">
    protected string HTProgCap = "國內案編修暨交辦作業";// HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "brt12";//程式檔名前綴
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

    protected string nToSelect = "";//特殊處理鎖定
    protected string nToText = "Lock";//特殊處理指定薪號鎖定
    protected string se_Grpid = "";//營洽所屬grpid
    protected string se_Grplevel = "";//營洽所屬grplevel
    protected string mSC_code = "";//直屬主管
    protected string mSC_name = "";//直屬主管名稱
    protected string selSign = "";//特殊簽核清單
        
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

        ReqVal = Util.GetRequestParam(Context,Request["chkTest"] == "TEST");
        submitTask = Request["submitTask"] ?? "";

        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        HTProgCap = myToken.Title;
        DebugStr = myToken.DebugStr;
        if (HTProgRight >= 0) {
            QueryData();
            PageLayout();

            this.DataBind();
        }
    }

    private void PageLayout() {
        StrFormBtnTop += "<a href=\"javascript:location.reload()\" >[重新整理]</a>";
        StrFormBtnTop += "<a href=\"javascript:window.history.back()\" >[回上頁]</a>";

        //簽核用
        /*
        SQL = "SELECT GrpID.Master_scode AS Mscode1, GrpID_1.Master_scode AS Mscode2, scode_group.GrpID,scode_group.grptype ";
        SQL += "FROM scode_group ";
        SQL += "INNER JOIN GrpID ON scode_group.GrpClass = GrpID.GrpClass AND scode_group.GrpID = GrpID.GrpID ";
        SQL += "LEFT OUTER JOIN GrpID GrpID_1 ON GrpID.UpgrpID = GrpID_1.GrpID AND GrpID.GrpClass = GrpID_1.GrpClass ";
        SQL += "WHERE scode_group.scode = '" + Request["tscode"] + "' and scode_group.grpclass ='" + Session["SeBranch"] + "' ";
        if ((HTProgRight & 256) != 0) nToText = "";

        using (SqlDataReader dr = cnn.ExecuteReader(SQL)) {
            if (dr.Read()) {
                se_Grpid = dr.SafeRead("GrpID", "");
                mSC_code = dr.SafeRead("Mscode1", "");
                if (Request["tscode"] == mSC_code) {//營洽=直屬主管
                    nToSelect = "Lock";
                    if (dr.SafeRead("grptype", "") != "S") {
                        mSC_code = dr.SafeRead("Mscode2", "");
                    }
                }
            }
        }
        */

        //簽核用20201229修改邏輯,防自己交辦自己簽
        if ((HTProgRight & 256) != 0) nToText = "";//特殊簽核指定薪號
        Sys.getScodeGrpid(Sys.GetSession("SeBranch"), Request["tscode"],ref se_Grpid,ref se_Grplevel);
        mSC_code = Sys.getSignMaster(Sys.GetSession("SeBranch"), Request["tscode"]);
        string mSC_code1 = Sys.getSignMaster(Sys.GetSession("SeBranch"), Request["tscode"],false);
        if (Request["tscode"] == mSC_code1) {//營洽=直屬主管
            nToSelect = "Lock";
        }
        
        SQL = "select sc_name from scode where scode='" + mSC_code + "'";
        object objResult = cnn.ExecuteScalar(SQL);
        mSC_name = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();
        DataTable dtSign = Sys.getSignList(Sys.GetSession("SeBranch"), se_Grpid, Sys.GetSession("Scode"), mSC_code, "grplevel>0");
        selSign = dtSign.Option("{master_scode}", "{master_type}---{Master_nm}", false);
    }

    private void QueryData() {
        SQL = "SELECT a.send_way,a.receipt_title,a.receipt_type,a.seq,a.seq1,a.In_scode,a.In_no, a.Service, a.Fees";
        SQL += ",a.oth_money,a.arcase_type,a.arcase_class, b.appl_name, b.class";
        SQL += ",a.Arcase, a.Ar_mark, isnull(a.discount,0) as discount, a.case_num,a.stat_code, a.cust_area, a.cust_seq,a.end_flag,a.back_flag ";
        SQL += ",c.service AS p_service, c.fees AS p_fees, a.Discount_chk,a.discount_remark, d.cust_name ";
        SQL += ",(SELECT rs_detail FROM code_br WHERE rs_code = a.arcase AND dept = 'T' AND cr = 'Y' and no_code='N' and rs_type=a.arcase_type) AS case_name ";
        SQL += ",(SELECT rs_class FROM code_br WHERE rs_code = a.arcase AND dept = 'T' AND cr = 'Y' and no_code='N' and rs_type=a.arcase_type) AS Ar_form ";
        SQL += ",(SELECT prt_code FROM code_br WHERE rs_code = a.arcase AND dept = 'T' AND cr = 'Y' and no_code='N' and rs_type=a.arcase_type) AS prt_code ";
        SQL += ",(select reportp from code_br where rs_code = a.arcase and dept = 'T' and cr = 'Y' and no_code='N' and rs_type=a.arcase_type) as reportp ";
        SQL += ",''link_remark,''fseq,''urlasp,0 T_Service,0 T_Fees,0 P_Service,0 P_Fees ";
        SQL += "FROM case_dmt a ";
        SQL += "INNER JOIN dmt_temp b ON a.in_scode = b.in_scode AND a.in_no = b.in_no ";
        SQL += "INNER JOIN VIEW_Cust d ON a.cust_seq = d.cust_seq AND a.cust_area = d.cust_area ";
        SQL += "LEFT OUTER JOIN case_fee c ON a.arcase = c.rs_code AND (c.dept = 'T') AND (c.country = 'T') AND (GETDATE() BETWEEN c.beg_date AND c.end_date) ";
        SQL += "WHERE a.cust_area = '" + Request["tfx_cust_area"] + "' ";
        SQL += "AND a.stat_code LIKE 'N%' and case_sqlno=0 ";
        if (ReqVal.TryGet("stat_code") != "") {
            SQL += "AND a.stat_code ='" + Request["stat_code"] + "' ";
        }
        if (ReqVal.TryGet("tfx_cust_seq") != "") {
            SQL += "AND a.cust_seq ='" + Request["tfx_cust_seq"] + "' ";
        }
        if (ReqVal.TryGet("sfx_in_date") != "") {
            SQL += "AND a.in_date> ='" + Request["sfx_in_date"] + "' ";
        }
        if (ReqVal.TryGet("Efx_in_date") != "") {
            SQL += "AND a.in_date< ='" + Request["Efx_in_date"] + "' ";
        }
        if (ReqVal.TryGet("tscode") != "") {
            SQL += "AND a.in_scode ='" + Request["tscode"] + "' ";
        }
        if (ReqVal.TryGet("pfx_Arcase") != "") {
            SQL += "AND a.Arcase ='" + Request["pfx_Arcase"] + "' ";
        }
        SQL += "AND (a.mark='N' or a.mark is null)";

        ReqVal["qryOrder"] = ReqVal.TryGet("SetOrder", ReqVal.TryGet("qryOrder"));
        if (ReqVal.TryGet("qryOrder") != "") {
            SQL += " order by " + ReqVal.TryGet("qryOrder");
        }
        else {
            SQL += " order by a.in_no";
        }
        conn.DataTable(SQL, dt);

        //處理分頁
        int nowPage = Convert.ToInt32(Request["GoPage"] ?? "1"); //第幾頁
        int PerPageSize = Convert.ToInt32(Request["PerPage"] ?? "30"); //每頁筆數
        page = new Paging(nowPage, PerPageSize, string.Join(";", conn.exeSQL.ToArray()));
        page.GetPagedTable(dt);

        //分頁完再處理其他資料才不會虛耗資源
        for (int i = 0; i < page.pagedTable.Rows.Count; i++) {
            SQL = "Select remark from cust_code where cust_code='__' and code_type='" + page.pagedTable.Rows[i]["arcase_type"] + "'";
            object objResult = conn.ExecuteScalar(SQL);
            string link_remark = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();
            page.pagedTable.Rows[i]["link_remark"] = link_remark;//案性版本連結

            int T_Service = 0;//交辦服務費
            int T_Fees = 0;//交辦規費
            int P_Service = 0;//服務費收費標準
            int P_Fees = 0;//規費收費標準
            SQL = "select a.item_service as case_service,a.item_fees as case_fees, service*item_count as fee_service,fees*item_count AS fee_Fees ";
            SQL += "from caseitem_dmt a ";
            SQL += "inner join case_fee b on a.item_arcase=b.rs_code ";
            SQL += "where a.in_no='" + page.pagedTable.Rows[i].SafeRead("in_no", "") + "' ";
            SQL += "and b.dept='T' and b.country='T' and getdate() between b.beg_date and b.end_date";
            using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
                if (dr.Read()) {
                    T_Service += dr.SafeRead("case_service", 0);
                    P_Service += dr.SafeRead("Fee_service", 0);
                    T_Fees += dr.SafeRead("Case_Fees", 0);
                    P_Fees += dr.SafeRead("Fee_Fees", 0);
                }
            }
            SQL = "select a.oth_arcase,a.oth_money,b.service ";
            SQL += "from case_dmt a ";
            SQL += "inner join case_fee b on  a.oth_arcase=b.rs_code ";
            SQL += "where in_no='" + page.pagedTable.Rows[i].SafeRead("in_no", "") + "' ";
            SQL += "and b.dept='T' and b.country='T' and getdate() between b.beg_date and b.end_date";
            using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
                if (dr.Read()) {
                    T_Service += dr.SafeRead("oth_money", 0);
                    P_Service += dr.SafeRead("service", 0);
                }
            }
            page.pagedTable.Rows[i]["T_Service"]=T_Service;
            page.pagedTable.Rows[i]["T_Fees"]=T_Fees;
            page.pagedTable.Rows[i]["P_Service"]=P_Service;
            page.pagedTable.Rows[i]["P_Fees"]=P_Fees;
                
            page.pagedTable.Rows[i]["cust_name"] = page.pagedTable.Rows[i].SafeRead("cust_name", "").Left(5);
            page.pagedTable.Rows[i]["fseq"] = page.pagedTable.Rows[i].SafeRead("seq", "") + (page.pagedTable.Rows[i].SafeRead("seq1", "_") != "_" ? "-" + page.pagedTable.Rows[i].SafeRead("seq1", "") : "");

            string new_form = Sys.getCaseDmtAspx(page.pagedTable.Rows[i].SafeRead("arcase_type", ""), page.pagedTable.Rows[i].SafeRead("arcase", ""));//連結的aspx
            //SQL = "SELECT c.remark ";
            //SQL += "FROM Cust_code c ";
            //SQL += "inner join code_br b on b.rs_type=c.Code_type and b.rs_class=c.Cust_code ";
            ////SQL += "WHERE c.form_name is not null ";
            //SQL += "WHERE 1=1 ";
            //SQL += "and b.rs_type='" + page.pagedTable.Rows[i]["arcase_type"] + "' ";
            //SQL += "and b.rs_code='" + page.pagedTable.Rows[i]["arcase"] + "' ";
            //using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
            //    if (dr.Read()) {
            //        new_form = dr.SafeRead("remark", "");
            //    }/* else {
            //        dr.Close();
            //        SQL = "SELECT c.remark ";
            //        SQL += "FROM Cust_code c ";
            //        SQL += "inner join code_br b on b.rs_type=c.Code_type and left(b.rs_class,1)=c.Cust_code ";
            //        SQL += "WHERE c.form_name is not null ";
            //        SQL += "and b.rs_type='" + page.pagedTable.Rows[i]["arcase_type"] + "' ";
            //        SQL += "and b.rs_code='" + page.pagedTable.Rows[i]["arcase"] + "' ";
            //        using (SqlDataReader dr1 = conn.ExecuteReader(SQL)) {
            //            if (dr1.Read()) {
            //                new_form += dr1.SafeRead("remark", "");
            //            }
            //        }
            //    }*/
            //}
            string ar_form = page.pagedTable.Rows[i].SafeRead("ar_form", "");//rs_class
            string prt_name = page.pagedTable.Rows[i].SafeRead("reportp", "");//列印程式
            bool FlagPrint = (prt_name != "" ? true : false);
            if (page.pagedTable.Rows[i].SafeRead("prt_code", "") == "D9Z" || page.pagedTable.Rows[i].SafeRead("prt_code", "") == "ZZ") {
                //2014/4/29因有部份類別在洽案登錄為大類別，如C救濟案，但編修時值皆抓rs_class=C2，則會造成若要改C1下的案性，就會選不到，增加下列判斷重抓洽案登錄大類別
                SQL = "select cust_code from cust_code where code_type='" + page.pagedTable.Rows[i]["arcase_type"] + "' and form_name is not null and cust_code='" + ar_form + "'";
                using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
                    if (!dr.HasRows) {
                        dr.Close();
                        SQL = "select cust_code from cust_code where code_type='" + page.pagedTable.Rows[i]["arcase_type"] + "' and form_name is not null and cust_code like '" + ar_form.Left(1) + "%' ";
                        using (SqlDataReader dr1 = conn.ExecuteReader(SQL)) {
                            if (dr1.Read()) {
                                page.pagedTable.Rows[i]["ar_form"] = dr1.SafeRead("cust_code", "");
                            }
                        }
                    }
                }
            } else {
                if (page.pagedTable.Rows[i].SafeRead("prt_code", "") == "D3"
                    || page.pagedTable.Rows[i].SafeRead("prt_code", "") == ""
                    || page.pagedTable.Rows[i].SafeRead("arcase", "") == "DE2"
                    || page.pagedTable.Rows[i].SafeRead("arcase", "") == "AD7"
                    )
                    FlagPrint = false;
            }
            string urlasp = "";//連結的url
            urlasp = Page.ResolveUrl("~/brt1m" + link_remark + "/Brt11Edit" + new_form + ".aspx?prgid="+prgid);
            urlasp += "&in_scode=" + page.pagedTable.Rows[i]["in_scode"];
            urlasp += "&in_no=" + page.pagedTable.Rows[i]["in_no"];
            urlasp += "&add_arcase=" + page.pagedTable.Rows[i]["arcase"];
            urlasp += "&cust_area=" + page.pagedTable.Rows[i]["cust_area"];
            urlasp += "&cust_seq=" + page.pagedTable.Rows[i]["cust_seq"];
            urlasp += "&ar_form=" + page.pagedTable.Rows[i]["ar_form"];
            urlasp += "&new_form=" + new_form;
            urlasp += "&code_type=" + page.pagedTable.Rows[i]["arcase_type"];
            urlasp += "&homelist=" + Request["homelist"];
            urlasp += "&uploadtype=case";

            if (Sys.GetSession("scode") == page.pagedTable.Rows[i].SafeRead("in_scode", "") || (HTProgRight & 128) != 0)
                urlasp += "&submittask=Edit";
            else
                urlasp += "&submittask=Show";
            page.pagedTable.Rows[i]["urlasp"] = urlasp;
        }

        dataRepeater.DataSource = page.pagedTable;
        dataRepeater.DataBind();
    }
    
    protected string GetCaseNum(RepeaterItem Container) {
        string stat_code = DataBinder.Eval(Container.DataItem, "stat_code").ToString();
        if (stat_code == "NX")
            return "(" + DataBinder.Eval(Container.DataItem, "case_num").ToString() + ")";

        return "";
    }

    protected string GetTodoIcon(RepeaterItem Container) {
        string back_flag = DataBinder.Eval(Container.DataItem, "back_flag").ToString().Trim().ToUpper();
        string end_flag = DataBinder.Eval(Container.DataItem, "end_flag").ToString().Trim().ToUpper();
        if (back_flag == "Y" || end_flag == "Y")
            return "<img src='" + Page.ResolveUrl("~/images/todolist01.jpg") + "' align='absmiddle' border='0'>";

        return "";
    }

    protected string GetSum(RepeaterItem Container) {
        int Service = Convert.ToInt32(DataBinder.Eval(Container.DataItem, "Service"));
        int fees = Convert.ToInt32(DataBinder.Eval(Container.DataItem, "fees"));
        int oth_money = Convert.ToInt32(DataBinder.Eval(Container.DataItem, "oth_money"));
            return (Service+fees+oth_money).ToString();
    }

    protected string GetDiscount(RepeaterItem Container) {
        decimal discount = Convert.ToDecimal(DataBinder.Eval(Container.DataItem, "discount"));
        string discount_chk = DataBinder.Eval(Container.DataItem, "Discount_chk").ToString();
        string discount_remark = DataBinder.Eval(Container.DataItem, "discount_remark").ToString();
        string rtn = "";
        if (discount > 0) {
            rtn += discount + "%";
        }

        if (discount_chk == "Y" || discount_remark != "") {
            rtn += "(*)";
        }

        return rtn;
    }

    protected string GetNXLink(RepeaterItem Container) {
        string stat_code = DataBinder.Eval(Container.DataItem, "stat_code").ToString();
        if (stat_code == "NX")//**todo
            return "<a href='" + Page.ResolveUrl("~/Brt4m/Brt13ListA.aspx") + 
                    "?in_scode="+DataBinder.Eval(Container.DataItem, "in_scode").ToString()+
                    "&in_no="+DataBinder.Eval(Container.DataItem, "in_no").ToString()+
                    "&ar_form=" + DataBinder.Eval(Container.DataItem, "ar_form").ToString() +
                    "&homelist="+Request["homelist"]+
                    "&qs_dept=T' target='Eblank'><font color=red>說明</font></a>";
          return "";
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
<input type="text" id="prgid" name="prgid" value="<%=prgid%>">
<input type=text id=signid name=signid>
<input type=text id=in_no1 name=in_no1>
<input type=text id=in_scode1 name=in_scode1>
<input type=text id=C1 name=C1 value="Y"> 
<input type=text id=row name=row value="<%#page.pagedTable.Rows.Count%>"> 

<asp:Repeater id="dataRepeater" runat="server">
<HeaderTemplate>
    <table style="display:<%#page.totRow==0?"none":""%>" border="0" class="bluetable" cellspacing="1" cellpadding="2" width="98%" align="center" id="dataList">
	    <thead>
            <Tr>
	            <td align="center" class="lightbluetable"></td>
                <td align="center" class="lightbluetable" nowrap>接洽序號</td>
	            <td align="center" class="lightbluetable" nowrap>客戶名稱</td>
	            <td align="center" class="lightbluetable" nowrap>案件編號</td>
	            <td align="center" class="lightbluetable" nowrap>案件名稱</td>	
	            <td align="center" class="lightbluetable">類別</td>
	            <td align="center" class="lightbluetable" width="15%">案性</td>
	            <td align="center" class="lightbluetable">服務費</td>
	            <td align="center" class="lightbluetable">規費</td>
	            <td align="center" class="lightbluetable">轉帳<br>費用</td>
	            <td align="center" class="lightbluetable">合計</td>
	            <td align="center" class="lightbluetable">折扣</td>
	            <td align="center" class="lightbluetable">註記</td>
	            <td align="center" class="lightbluetable">作業</td>
            </tr>
	    </thead>
	    <tbody>
</HeaderTemplate>
			<ItemTemplate>
 		        <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>">
	                <td class="whitetablebg" align="center">
		                <input type=checkbox id="CT" name="T_<%#(Container.ItemIndex+1)%>" value="Y" onclick="checkfee('<%#(Container.ItemIndex+1)%>')">
		                <input type=hidden id="incode_<%#(Container.ItemIndex+1)%>" name="incode_<%#(Container.ItemIndex+1)%>" value="<%#Eval("in_scode")%>">
		                <input type=hidden id="inno_<%#(Container.ItemIndex+1)%>" name="inno_<%#(Container.ItemIndex+1)%>" value="<%#Eval("in_no")%>">
		                <!--2010/5/17因應todo_ext修改-->
		                <input type=hidden id="seq_<%#(Container.ItemIndex+1)%>" name="seq_<%#(Container.ItemIndex+1)%>" value="<%#Eval("seq")%>">
	                    <input type=hidden id="seq1_<%#(Container.ItemIndex+1)%>" name="seq1_<%#(Container.ItemIndex+1)%>" value="<%#Eval("seq1")%>">
	                    <!--2016/5/30因應折扣線上簽核修改-->
	                    <input type=hidden id="discount_remark_<%#(Container.ItemIndex+1)%>" name="discount_remark_<%#(Container.ItemIndex+1)%>" value="<%#Eval("discount_remark")%>">
		                <input type=hidden id="send_way_<%#(Container.ItemIndex+1)%>" name="send_way_<%#(Container.ItemIndex+1)%>" value="<%#Eval("send_way")%>">
		                <input type=hidden id="receipt_title_<%#(Container.ItemIndex+1)%>" name="receipt_title_<%#(Container.ItemIndex+1)%>" value="<%#Eval("receipt_title")%>">
		                <input type=hidden id="receipt_type_<%#(Container.ItemIndex+1)%>" name="receipt_type_<%#(Container.ItemIndex+1)%>" value="<%#Eval("receipt_type")%>">
		                <input type=hidden id="ar_mark_<%#(Container.ItemIndex+1)%>" value="<%#Eval("Ar_mark")%>"><!--arkind-->
		                <input type=hidden id="t_service_<%#(Container.ItemIndex+1)%>" value="<%#Eval("T_Service")%>"><!--A-->
		                <input type=hidden id="p_service_<%#(Container.ItemIndex+1)%>" value="<%#Eval("P_Service")%>"><!--PA-->
		                <input type=hidden id="t_fees_<%#(Container.ItemIndex+1)%>" value="<%#Eval("T_fees")%>"><!--B-->
		                <input type=hidden id="p_fees_<%#(Container.ItemIndex+1)%>" value="<%#Eval("P_fees")%>"><!--PB-->
		                <input type=hidden id="discount_<%#(Container.ItemIndex+1)%>" value="<%#Eval("discount")%>"><!--Sratio-->
		                <input type=hidden id="discount_chk_<%#(Container.ItemIndex+1)%>" value="<%#Eval("Discount_chk")%>"><!--dis_chk-->
	                </td>
	                <td class="whitetablebg" align="center"><a href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("In_scode")%>-<%#Eval("in_no")%><%#GetCaseNum(Container)%></a></td>
	                <td class="whitetablebg" align="center"><a href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("cust_name")%></a></td>
	                <td class="whitetablebg" align="center"><a href="<%#Eval("urlasp")%>" target="Eblank"><%#GetTodoIcon(Container)%><%#Eval("fseq")%></a></td>
	                <td class="whitetablebg" align="center"><a href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("appl_name")%></a></td>
	                <td class="whitetablebg" align="center"><a href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("Class")%></a></td>
	                <td class="whitetablebg" align="center"><a href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("case_name")%></a></td>
	                <td class="whitetablebg" align="center"><a href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("service")%></a></td>
	                <td class="whitetablebg" align="center"><a href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("fees")%></a></td>
	                <td class="whitetablebg" align="center"><a href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("oth_money")%></a></td>
	                <td class="whitetablebg" align="center"><%#GetSum(Container)%></td>
	                <td class="whitetablebg" align="center"><%#GetDiscount(Container)%></td>
	                <td class="whitetablebg" align="center" title="主管簽退或程序退回說明"><%#GetNXLink(Container)%></td>
	                <td class="whitetablebg" align="center"><a href="<%#Eval("urlasp")%>" target="Eblank"><font color="blue">[編修]</font></a></td>
				</tr>
			</ItemTemplate>
<FooterTemplate>
	    </tbody>
    </table>
	<BR>
    <table style="display:<%#page.totRow==0?"none":""%>" border="0" width="100%" cellspacing="0" cellpadding="0">
		<tr class="FormName"><td>
			<div align="left">
			備註:<br>
			1.案件編號前的「<img src="../images/todolist01.jpg" style="cursor:pointer" align="absmiddle" border="0">」表示結案/復案<br>
			2.「註記」顯示「<font color=red>說明</font>」，表示主管簽退或程序退回，可點選「說明」檢視主管簽退或程序退回原因。
			</div>
		</td>
        </tr>
	</table>
	<br>
</FooterTemplate>
</asp:Repeater>

<div id="divSign" style="display:none">
<br>
<table border="0" width="70%" cellspacing="1" cellpadding="0" align="center" >			
	<TR>										 
		<td ><input type=radio name="usesign" id="usesignM" checked><strong>正常簽核:</strong></td>
		<td><strong>直屬主管:</strong><%=mSC_name%><input type=text name=Msign id=Msign value="<%=mSC_code%>"></td>
		<td><strong>管制日期:</strong>
		<input type=text id="signdate" name="signdate" size=10 readonly class="dateField">
		</td>
	</TR>
    <TR>
		<td ><input type=radio name="usesign" id="usesignO"><strong>特殊處理:</strong></td>
		<td ><input type=radio name=Osign id=Osign0 class="<%=nToSelect%>">
		    <select id=selectsign name=selectsign class="<%=nToSelect%>">
			<option value="" style="color:blue">請選擇主管</option><%=selSign%>
			</select>
		</td>	
		<td><input type=radio name=Osign id=Osign1 class="<%=nToText%>">
			<input type=text name=Nsign id=Nsign size=10 class="<%=nToText%>">(薪號)
		</td>
	</TR>
</table>
<input type=text id="GrpID" name="GrpID" value="<%=se_Grpid%>">
<table border="0" width="100%" cellspacing="0" cellpadding="0">
	<tr><td width="100%">     
	<p align="center">        
		<input type=button value ="案件交辦" class="cbutton bsubmit" onClick="formupdate()" id=button4 name=button4>
	</td></tr>
</table>
</div>

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

        if("<%#mSC_name%>"!=""&&$("#dataList").is(':visible')) $("#divSign").show();
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

    $("#usesignM").click(function (e) {
        $("input[name=Osign]").prop("checked",false);
    })

    $("input[name=Osign]").click(function (e) {//特殊處理
        $("#usesignO").prop("checked",true);
    })
   
    $("#selectsign").click(function (e) {//特殊處理-請選擇主管
        $("#usesignO").prop("checked",true);
        $("#Osign0").prop("checked",true);
    })

    $("#Nsign").click(function (e) {//特殊處理-指定人員
        $("#usesignO").prop("checked",true);
        $("#Osign1").prop("checked",true);
    })

    //arkind 為請款註記,B為服務費，PA為服務費標準，B為規費，PB為規費標準
    function checkfee(i){
        //2011/2/25增加判斷是否已交辦，避免營洽開二個視窗重覆交辦
        if(!checkstatus(i)){
            alert("本接洽序號："+$("#incode_"+i).val()+"-"+$("#inno_"+i).val()+ "已交辦主管簽核，請重新整理並檢查再執行案件交辦！");
            $("input[name='T_"+i+"']").prop("checked",false);
        }

        //arkind 為請款註記,A為服務費，PA為服務費標準，B為規費，PB為規費標準
        if($("input[name='T_"+i+"']").prop("checked")==true){
            var A=CLng($("#t_service_"+i).val());
            var PA=CLng($("#p_service_"+i).val());
            var B=CLng($("#t_fees_"+i).val());
            var PB=CLng($("#p_fees_"+i).val());
            if(A>0){
                if(A<PA){
                    if($("#ar_mark_"+i).val()=="B"||$("#ar_mark_"+i).val()=="A"){
                        var Aratio = (1 - (A / PA)) * 100;
                        if(CDbl($("#discount_"+i).val())!=Aratio){
                            alert("服務費收費標準調整，請重新計算折扣率");
                            $("input[name='T_"+i+"']").prop("checked",false);
                            return false;
                        }
                        if(Aratio<100&&Aratio>20 &&$("#discount_remark_"+i).val()==""){
                            alert("折扣低於8折，請進入[編修]並輸入折扣理由。");
                            $("input[name='T_"+i+"']").prop("checked",false);
                            return false;
                        }
                    }
                }
            }
            if(B<PB &&($("#ar_mark_"+i).val()=="A"||$("#ar_mark_"+i).val()=="N")){
                alert("規費小於收費標準，請檢核請款註記或調整規費");
                $("input[name='T_"+i+"']").prop("checked",false);
                return false;
            }
        }
    }

    //檢查案件狀態
    function checkstatus(i){
        var rtnflag=true;
        if($("input[name='T_"+i+"']").prop("checked")==true){
            //2011/2/25增加判斷是否已交辦，避免營洽開二個視窗重覆交辦
            var searchSql = "SELECT stat_code from case_dmt where in_no='" +$("#inno_"+i).val()+ "' ";
            $.ajax({
                type: "get",
                url: getRootPath() + "/ajax/JsonGetSqlData.aspx",
                data: { sql: searchSql },
                async: false,
                cache: false,
                success: function (json) {
                    var JSONdata = $.parseJSON(json);
                    if (JSONdata.length > 0) {
                        if(JSONdata[0].stat_code.Left(1)=="Y"){
                            rtnflag=false;
                        }
                    }
                }
            });
        }
        return rtnflag;
    }

    function formupdate(){
        if($("#usesignM").prop("checked")==true){//正常簽核
            $("#signid").val($("#Msign").val());
        }else{
            if($("#Osign").prop("checked")==true){
                //特殊處理-請選擇主管
                if($("#selectsign").val()==""){
                    alert("請選擇主管");
                    $("#selectsign").focus();
                    return false;
                }
                $("#signid").val($("#selectsign").val());
            }else{
                //特殊處理-指定人員
                if($("#Nsign").val()==""){
                    alert("薪號欄位不得為空白");
                    $("#Nsign").focus();
                    return false;
                }
                $("#signid").val($("#Nsign").val());
            }
        }

        var errMsg = "";
        var check=$("input[id='CT']:checked").length;
        if (check==0){
            errMsg+="尚未選定!!\n";
        }

        if (errMsg!="") {
            alert(errMsg);
            return false;
        }

        for(var i=1;i<=CInt($("input[id='CT']").length);i++){
            //2018/3/20增加判斷是否已交辦，避免營洽開二個視窗重覆交辦
            if(!checkstatus(i)){
                alert("本接洽序號："+$("#incode_"+i).val()+"-"+$("#inno_"+i).val()+ "已交辦主管簽核，請重新整理並檢查再執行案件交辦！");
                $("input[name='T_"+i+"']").prop("checked",false);
                return false;
            }
        }
        //***todo
        $(".bsubmit").lock(!$("#chkTest").prop("checked"));
        var formData = new FormData($('#reg')[0]);
        $.ajax({
            url:'<%=HTProgPrefix%>_Update.aspx?qs_proid=<%#prgid%>',
            type : "POST",
            data : formData,
            contentType: false,
            cache: false,
            processData: false,
            beforeSend:function(xhr){
                $("#dialog").html("<div align='center'><h1>存檔中...</h1></div>");
                $("#dialog").dialog({ title: '存檔訊息', modal: true,maxHeight: 500,width: 800,buttons:[] });
            },
            complete: function (xhr, status) {
                $("#dialog").html(xhr.responseText);
                $("#dialog").dialog({
                    title: '存檔訊息',modal: true,maxHeight: 500,width: 800,closeOnEscape: false
                    ,buttons: {
                        確定: function() {
                            $(this).dialog("close");
                        }
                    }
                    ,close:function(event, ui){
                        if(status=="success"){
                            window.location.href="<%=HTProgPrefix%>.aspx?prgid=<%#prgid%>"
                        }
                    }
                });
            }
        });
    }
</script>
