<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Linq"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<script runat="server">
    protected string HTProgCap = "申請人資料清單";//HttpContext.Current.Request["prgname"];//功能名稱
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

    DataTable dtAttach = new DataTable();
    protected string kind_no = "";
    protected string ref_no = "";
    protected string kind_date = "";
    protected string sdate = "";
    protected string edate = "";
    protected string submitTask = "";
    DataTable dtCountry = Sys.getCountry();
    
    DBHelper conn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    private void Page_Unload(System.Object sender, System.EventArgs e) {
        if (conn != null) conn.Dispose();
    }

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");
        //foreach (var item in ReqVal)
        //{
        //    Response.Write("[Key:" + item.Key + "," + "Value:" + item.Value + "],");
        //}
        conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");

        if ((HttpContext.Current.Request["prgid"] ?? "") == "") {
            HTProgCode = "cust13"; prgid = "cust13";
        }

        sdate = ReqVal.TryGet("sdate");
        edate = ReqVal.TryGet("edate");
        submitTask = Request["submitTask"];

        string SQLStr = "select apsqlno from apcust_attach a where a.source='POA'";
        SQLStr += " and exists (select * From apcust_attach_ref r inner join apcust ap on r.apsqlno=ap.apsqlno";
        SQLStr += " where r.apattach_sqlno=a.apattach_sqlno)";
        SQLStr += " and a.attach_flag <> 'E' and (a.use_datee >= '" + DateTime.Now.ToShortDateString() + "' or a.use_datee is null)";
        conn.DataTable(SQLStr, dtAttach);

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

    private void PageLayout()
    {
        if ((HTProgRight & 2) > 0)
        {
            //StrFormBtnTop += "<a href=\"javascript:void(0)\" onclick=\"show_report()\">[申請人查詢]</a>";
            StrFormBtnTop += "<a href=javascript:GoToSearch()>[申請人查詢]</a>";
        }
        ///StrFormBtnTop += "<a href=cust13_mod.aspx?modify=A>[新增申請人]</a>";
        StrFormBtnTop += "<a href=javascript:GoToAdd()>[新增申請人]</a>";
    }

    protected string GetCountry(RepeaterItem Container)
    {
        DataRow[] row = dtCountry.Select("coun_code = '" + Eval("ap_country").ToString() + "'");
        if (row.Length > 0) return row[0]["coun_c"].ToString();
        else return "";
    }
    protected string GetFullName(RepeaterItem Container)
    {
        if (Eval("ap_ename1").ToString() == "" && Eval("ap_ename2").ToString() == "")
        {
            return Eval("ap_cname1").ToString() + Eval("ap_cname2").ToString();
        }
        else
        {
            return Eval("ap_cname1").ToString() + Eval("ap_cname2").ToString() + "/" + Eval("ap_ename1").ToString() + Eval("ap_ename2");
        }
    }
    protected string GetAttachQty(RepeaterItem Container)
    {
        int Qty = 0;
        string url = "";
        DataRow[] row = dtAttach.Select("apsqlno = '" + Eval("apsqlno").ToString() + "'");
        if (row.Length > 0)
        {
            Qty = row.Length;
        }

        if (Qty > 0)
        {
            url = "<a href=\"javascript:void(0)\" onclick=\"GoToAttachList('"+Eval("apcust_no").ToString()+"')\">" + Qty + "</a>";
        }
        else url = Qty.ToString();
        return url;
    }
    
    private void QueryData() {
        
        DataTable dt = new DataTable();
        SQL = "SELECT * , (select code_name from cust_code where code_type = 'apclass' and cust_code = a.apclass) as apclassname, ";
        SQL += "(select count(*) as Qty from ap_nameaddr where apsqlno = a.apsqlno) as nameqty ";
        SQL += "FROM apcust a WHERE 1=1";
        
        if (ReqVal.TryGet("apcust_no") != "")
        {
            SQL += " and apcust_no LIKE '%" + ReqVal.TryGet("apcust_no") + "%'";
        }
        else
        {
            if (ReqVal.TryGet("apclass") != "")
            {
                SQL += " and apclass = '" + ReqVal.TryGet("apclass") + "'";
            }

            if (ReqVal.TryGet("ap_country") != "")
            {
                SQL += " and ap_country = '" + ReqVal.TryGet("ap_country") + "'";
            }
            if (ReqVal.TryGet("ap_cname") != "")
            {
                SQL += " and (ap_cname1 LIKE '%" + ReqVal.TryGet("ap_cname") + "%' OR ap_cname2 LIKE '%" + ReqVal.TryGet("ap_cname") + "%')";
            }
            if (ReqVal.TryGet("ap_cname1") != "")
            {
                SQL += " and (ap_cname1 LIKE '%" + ReqVal.TryGet("ap_cname1") + "%')";
            }
            if (ReqVal.TryGet("ap_cname2") != "")
            {
                SQL += " and (ap_cname2 LIKE '%" + ReqVal.TryGet("ap_cname2") + "%')";
            }
            if (ReqVal.TryGet("ap_ename") != "")
            {
                SQL += " and (ap_ename1 LIKE '%" + ReqVal.TryGet("ap_ename") + "%' OR ap_ename2 LIKE '%" + ReqVal.TryGet("ap_ename") + "%')";
            }

            if (ReqVal.TryGet("ap_crep") != "")
            {
                SQL += " and ap_crep LIKE '%" + ReqVal.TryGet("ap_crep") + "%'";
            }
            if (ReqVal.TryGet("ap_erep") != "")
            {
                SQL += " and ap_erep LIKE '%" + ReqVal.TryGet("ap_erep") + "%'";
            }
            if (ReqVal.TryGet("ap_zip") != "")
            {
                SQL += " and ap_zip LIKE '%" + ReqVal.TryGet("ap_zip") + "%'";
            }

            if (ReqVal.TryGet("ap_addr") != "")
            {
                SQL += " and ap_addr1 LIKE '%" + ReqVal.TryGet("ap_addr") + "%'";
            }
            if (ReqVal.TryGet("apatt_zip") != "")
            {
                SQL += " and apatt_zip LIKE '%" + ReqVal.TryGet("apatt_zip") + "%'";
            }
            if (ReqVal.TryGet("apatt_addr") != "")
            {
                SQL += " and apatt_addr1 LIKE '%" + ReqVal.TryGet("apatt_addr") + "%'";
            }
            if (ReqVal.TryGet("apatt_tel0") != "")
            {
                SQL += " and apatt_tel0 LIKE '%" + ReqVal.TryGet("apatt_tel0") + "%'";
            }
            if (ReqVal.TryGet("apatt_tel") != "")
            {
                SQL += " and apatt_tel LIKE '%" + ReqVal.TryGet("apatt_tel") + "%'";
            }
            if (ReqVal.TryGet("apatt_tel1") != "")
            {
                SQL += " and apatt_tel1 LIKE '%" + ReqVal.TryGet("apatt_tel1") + "%'";
            }
            
            //日期範圍
            if (ReqVal.TryGet("sdate") != "")
            {
                SQL += " AND " + Request["dKind"].ToString() + " >= '" + ReqVal.TryGet("sdate") + "'";
            }
            if (ReqVal.TryGet("edate") != "")
            {
                SQL += " AND " + Request["dKind"].ToString() + " <= '" + ReqVal.TryGet("edate") + " 23:59:59'";
            }
        }

        //if (ReqVal.TryGet("ap_cname") != "") {
        //    SQL += " and rtrim(cast(a.seq as char))+a.seq1 in (select rtrim(cast(seq as char))+seq1 from dmt_ap where ap_cname like '%" + ReqVal.TryGet("ap_cname") + "%')";
        //}

        SQL += " order by apsqlno desc";
        //Sys.showLog(SQL);
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
            //dr["fseq"] = Sys.formatSeq1(dr.SafeRead("seq", ""), dr.SafeRead("seq1", ""), "", "", "");
            //if (dr.SafeRead("end_date", "") != "") {
            //    dr["end_star"] = "<font color=red>*</font>";
            //}
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
        <td class="text9" nowrap="nowrap">&nbsp;【cust13_List <%=HTProgCap%>】</td>
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
            <tr>
		        <td class=lightbluetable align=center>申請人編號</td>
		        <td class=lightbluetable align=center>申請人名稱</td>
		        <td class=lightbluetable align=center>代表人名稱</td>
		        <td class=lightbluetable align=center>申請人種類</td>
		        <td class=lightbluetable align=center>申請人國籍</td>
		        <td class=lightbluetable align=center>最近異動日期</td>
		        <td class=lightbluetable align=center>委任書</td>
		        <td class=lightbluetable align=center>申請人相關資料</td>
                <%--<td style="display:none;" >cust_area</td>
                <td style="display:none;" >cust_seq</td>--%>
            </tr>
	    </thead>
	    <tbody>
</HeaderTemplate>
			<ItemTemplate>
 		        <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>" align="center" style="height:​30px;">
			        <td nowrap>
                        <a href="cust13_Edit.aspx?prgid=<%=prgid%>&apcust_no=<%#Eval("apcust_no")%>&apsqlno=<%#Eval("apsqlno")%>&cust_area=<%#Eval("cust_area")%>&cust_seq=<%#Eval("cust_seq")%>&submitTask=<%=submitTask%>" onclick="GoToEdit(this)">
                            <%#Eval("apcust_no")%></a>
			        </td>
			        <td nowrap>
                        <a href="cust13_Edit.aspx?prgid=<%=prgid%>&apcust_no=<%#Eval("apcust_no")%>&apsqlno=<%#Eval("apsqlno")%>&cust_area=<%#Eval("cust_area")%>&cust_seq=<%#Eval("cust_seq")%>&submitTask=<%=submitTask%>" onclick="GoToEdit(this)">
                            <%#GetFullName(Container)%></a>
			        </td>
			        <td nowrap><%# (Eval("ap_erep").ToString() == "") ? Eval("ap_crep") : Eval("ap_crep").ToString() + "/" + Eval("ap_erep").ToString()%></td>
			        <td nowrap>
                        <%#Eval("apclassname")%>
			        </td>
			        <td >
                        <%#GetCountry(Container)%>
			        </td>
			        <td nowrap>
                        <%# 
                            (Eval("tran_date").ToString() == "") ? "" : DateTime.Parse(Eval("tran_date").ToString()).ToString("yyyy/M/d")
                        %>
			        </td>
			        <td nowrap>
                        <%#GetAttachQty(Container)%>
			        </td>
                    <td nowrap><a href="cust13_2List.aspx?prgid=cust13_1&apsqlno=<%#Eval("apsqlno")%>&submitTask=<%=submitTask%>&apcust_no=<%#Eval("apcust_no")%>&ap_cname1=<%#Eval("ap_cname1")%>&ctrl_open=Y" onclick="GoTo13_2List(this)" >
                        [<%#Eval("nameqty") %>]</a></td>
                    <%--<td style="display:none;"><%#Eval("cust_area")%></td>
                    <td style="display:none;"><%#Eval("cust_seq")%></td>--%>
				</tr>
			</ItemTemplate>
<FooterTemplate>
	    </tbody>
    </table>
    <BR>
    <table border="0" width="100%" cellspacing="0" cellpadding="0">
		
	</table>
</FooterTemplate>
</asp:Repeater>
    <%--<%#DebugStr%>--%>
</form>

</body>
</html>

<script type="text/javascript">
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
<%--    function show_report(){
        var urlasp = "brta65print.aspx?<%#Request.Form.ParseQueryString()%>";
        window.open(urlasp, "myWinPrintN", "width=750px, height=550px, top=10, left=10, toolbar=no, menubar=yes, location=no, directories=no, status=no,resizable=yes, scrollbars=yes");
    }--%>
    //[下載Excel]
    <%--function show_excel() {
        var urlasp = "brta65printExcel.aspx?<%#Request.Form.ParseQueryString()%>";
        window.open(urlasp, "myWinPrintN", "width=750px, height=550px, top=10, left=10, toolbar=no, menubar=yes, location=no, directories=no, status=no,resizable=yes, scrollbars=yes");
    }--%>

    function GoToSearch() {
        reg.action = "cust13_1.aspx?prgid=<%=prgid%>&submitTask=<%=submitTask%>";
        reg.target = "Etop";
        reg.submit();
    }

    function GoToAdd() {
        //var url = "cust13_Edit.aspx?prgid=cust13&submitTask=A";
        //window.parent.Eblank.location.href = url;
        if (window.parent.tt !== undefined) {
            reg.target = "Eblank";
        }
        reg.action = "cust13_Edit.aspx?prgid=cust13&submitTask=A";
        reg.submit();
    }

    function GoToEdit(e) {
        if (window.parent.tt === undefined) {//沒有找到頁框
            e.target = "_self";
        } else {
            e.target = "Eblank";
        }
    }

    function GoTo13_2List(e) {
        if(window.parent.tt === undefined){//沒有找到頁框
            e.target="_self";
        }else{
            e.target="Eblank";
        }
    }

    function GoToAttachList(qapcust_no) {
        if (window.parent.tt !== undefined) {
            reg.target = "Eblank";
        }
        reg.action = "cust22_List.aspx?prgid=cust22&from_flag=<%=prgid%>&FrameBlank=50&submitTask=Q&qryapcust_no=" + qapcust_no;
        reg.submit();
    }
   


</script>