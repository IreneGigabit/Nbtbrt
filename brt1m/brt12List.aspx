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
    protected string prgid = HttpContext.Current.Request["prgid"] ?? "";//程式代碼
    protected int HTProgRight = 0;

    protected string SQL = "";

    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected string hiddenText = "";
    protected Paging page = new Paging(1, 10);
    
    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";

    protected string submitTask = "";
    protected string code_type = Sys.getRsType();

    DataTable dt = new DataTable();
    DBHelper conn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    private void Page_Unload(System.Object sender, System.EventArgs e) {
        if (conn != null) conn.Dispose();
    }
    
    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");

        ReqVal = Util.GetRequestParam(Context,Request["chkTest"] == "TEST");
        submitTask = Request["submitTask"] ?? "";

        Token myToken = new Token(HTProgCode);
        HTProgRight = myToken.CheckMe();
        HTProgCap = myToken.Title;
        if (HTProgRight >= 0) {
            QueryData();
            //PageLayout();

            this.DataBind();
        }
    }

    private void PageLayout() {
        StrFormBtnTop += "<a href=\"javascript:location.reload()\" >[重新整理]</a>";
        StrFormBtnTop += "<a href=\"javascript:window.history.back()\" >[回上頁]</a>";
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
        SQL += ",''link_remark ";
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

        ReqVal["qryOrder"] = ReqVal.TryGet("SetOrder", ReqVal.TryGet("qryOrder", ""));
        if (ReqVal.TryGet("qryOrder", "") != "") {
            SQL += " order by " + ReqVal.TryGet("qryOrder", "");
        }
        else {
            SQL += " order by a.in_no";
        }
        conn.DataTable(SQL, dt);

        //處理分頁
        int nowPage = Convert.ToInt32(Request["GoPage"] ?? "1"); //第幾頁
        int PerPageSize = Convert.ToInt32(Request["PerPage"] ?? "10"); //每頁筆數
        page = new Paging(nowPage, PerPageSize, string.Join(";", conn.exeSQL.ToArray()));
        page.GetPagedTable(dt);

        //分頁完再處理其他資料才不會虛耗資源
        for (int i = 0; i < page.pagedTable.Rows.Count; i++) {
            SQL = "Select remark from cust_code where cust_code='__' and code_type='" + page.pagedTable.Rows[i]["arcase_type"] + "'";
            object objResult = conn.ExecuteScalar(SQL);
            string link_remark = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();
            page.pagedTable.Rows[i]["link_remark"] = link_remark;

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
                T_Service += dr.SafeRead("case_service", 0);
                P_Service += dr.SafeRead("Fee_service", 0);
                T_Fees += dr.SafeRead("Case_Fees", 0);
                P_Fees += dr.SafeRead("Fee_Fees", 0);
            }

            SQL = "select a.oth_arcase,a.oth_money,b.service ";
            SQL += "from case_dmt a ";
            SQL += "inner join case_fee b on  a.oth_arcase=b.rs_code ";
            SQL += "where in_no='" + page.pagedTable.Rows[i].SafeRead("in_no", "") + "' ";
            SQL += "and and b.dept='T' and b.country='T' and getdate() between b.beg_date and b.end_date";
            using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
                T_Service += dr.SafeRead("oth_money", 0);
                P_Service += dr.SafeRead("service", 0);
            }


        }

        dataRepeater.DataSource = page.pagedTable;
        dataRepeater.DataBind();
    }

    protected void dataRepeater_ItemDataBound(object sender, RepeaterItemEventArgs e) {
        if ((e.Item.ItemType == ListItemType.Item) | (e.Item.ItemType == ListItemType.AlternatingItem)) {
            Repeater rsRepeater = (Repeater)e.Item.FindControl("rsRepeater");
            if ((rsRepeater != null)) {
                rsRepeater.DataSource = ds.Tables[1];
                rsRepeater.DataBind();
            }
        }
    }
</script>
<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
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
    <%#hiddenText%>
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

<div align="center" id="noData" style="display:<%#ds.Tables[0].Rows.Count==0?"":"none"%>">
	<font color="red">=== 目前無資料 ===</font>
</div>

<asp:Repeater id="dataRepeater" runat="server" OnItemDataBound="dataRepeater_ItemDataBound">
<HeaderTemplate>
    <table style="display:<%#ds.Tables[0].Rows.Count==0?"none":""%>" border="0" class="bluetable" cellspacing="1" cellpadding="2" width="98%" align="center" id="dataList">
	    <thead>
            <Tr>
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
		            <td align="center">
                        <a href="../cust/cust11_mod.asp?modify=Q&gs_dept=t&cust_area=<%#Eval("cust_area")%>&cust_seq=<%#Eval("cust_seq")%>&apsqlno=<%#Eval("id_no")%>&hRight=2&att_sql=1">
                            <%#Eval("cust_area")%>-<%#Eval("cust_seq")%>
                        </a>
                    </td>
		            <td align="center"><%#Eval("ap_cname1")%></td>
		            <td align="center"><%#Eval("ap_crep")%></td>
		            <td align="center"><%#Eval("id_no")%></td>
		            <td align="center"><%#Util.parseDBDate(Eval("in_date").ToString(),"yyyy/M/d")%></td>
		            <td align="center"><%#Util.parseDBDate(Eval("dmt_date").ToString(),"yyyy/M/d")%></td>
		            <td align="center">
                        <asp:Repeater id="rsRepeater" runat="server">
                            <HeaderTemplate>
			                    <SELECT name=toadd<%#(Container.ItemIndex+1)%> id=toadd<%#(Container.ItemIndex+1)%> onchange="Formadd('<%#DataBinder.Eval(((RepeaterItem)Container.Parent.Parent).DataItem, "cust_area")%>','<%#DataBinder.Eval(((RepeaterItem)Container.Parent.Parent).DataItem, "cust_seq")%>',this )" >
			                    <option value="" style="color:blue">請選擇案性</option>
                            </HeaderTemplate>
			                <ItemTemplate>
                                <option value="<%#Eval("Cust_code").ToString().Trim()%>" v1="<%#Eval("form_name").ToString().Trim()%>"><%#Eval("Code_name")%></option>
			                </ItemTemplate>
                        </asp:Repeater>
		            </td>
		            <td align="center">
                        [<a href="Brt11_1.asp?cust_area=<%#Eval("cust_area")%>&cust_seq=<%#Eval("cust_seq")%>&prgid=brt11&Type=Brt"><font color="blue">舊案檢索</font></a>]
                        [<a href="Brt11ListA.aspx?cust_area=<%#Eval("cust_area")%>&cust_seq=<%#Eval("cust_seq")%>"><font color="blue">維護/交辦</font></a>]
		            </td>
				</tr>
			</ItemTemplate>
<FooterTemplate>
	    </tbody>
    </table>
    <br />
</FooterTemplate>
</asp:Repeater>
</body>
</html>

<script language="javascript" type="text/javascript">
    $(function () {
        if (window.parent.tt !== undefined) {
            window.parent.tt.rows = "100%,0%";
        }
    });

    //關閉視窗
    $(".imgCls").click(function (e) {
        if (window.parent.tt !== undefined) {
            window.parent.tt.rows = "100%,0%";
        } else {
            window.close();
        }
    })

    function Formadd(x, y, obj) {
        var oThis = $(obj);
        if (oThis.val() == "") return false;
        reg.cust_area.value = x;
        reg.cust_seq.value = y;
        reg.submitTask.value = "Add";
        
        reg.Ar_Form.value = oThis.val();
        reg.prt_code.value = $('option:selected', oThis).attr('v1');
        reg.action = "Brt11Add" + reg.prt_code.value + ".aspx";
        reg.submit();
    }
</script>
