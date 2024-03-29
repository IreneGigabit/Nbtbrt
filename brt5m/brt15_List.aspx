﻿<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Linq"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>

<script runat="server">
    protected string HTProgCap = "案件主檔維護";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string HTProgPrefix = "brt15";//程式檔名前綴
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";

    protected string SQL = "";
    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected Paging page = null;
    
    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";
    protected string FormName = "";

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");

        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        if (HTProgRight >= 0) {
            PageLayout();
            QueryData();
            this.DataBind();
        }
    }

    private void PageLayout() {
        StrFormBtnTop += "<a href=brt15.aspx?prgid=" + prgid + ">[回查詢]</a>";
    }

    private void QueryData() {
        DataTable dt = new DataTable();
        using (DBHelper conn = new DBHelper(Conn.btbrt).Debug(false)) {
            SQL = "select a.*,b.ap_cname1 as cust_name ";
            SQL += ",(select sc_name from sysctrl.dbo.scode where scode=a.scode) as scode1nm ";
            SQL += ",''end_star,''fseq,''url ";
            SQL += "from dmt as a ";
            SQL += "left outer join apcust as b on a.cust_seq=b.cust_seq ";
            SQL += "where 1=1 ";
            if (ReqVal.TryGet("tfx_Scode") != "") {
                SQL += "AND a.Scode ='" + Request["tfx_Scode"] + "' ";
            }
            if (ReqVal.TryGet("ifx_seq") != "") {
                SQL += "AND a.seq ='" + Request["ifx_seq"] + "' ";
                if (ReqVal.TryGet("ifx_seq1") != "") {
                    SQL += "AND a.seq1 ='" + Request["ifx_seq1"] + "' ";
                }
            }
            if (ReqVal.TryGet("pfx_cappl_name") != "") {
                SQL += "AND b.cappl_name like '" + Request["pfx_cappl_name"] + "%' ";
            }
            if (ReqVal.TryGet("tfx_cust_area") != "") {
                SQL += "AND a.cust_area like '" + Request["tfx_cust_area"] + "%' ";
            }
            if (ReqVal.TryGet("tfx_cust_seq") != "") {
                SQL += "AND a.cust_seq ='" + Request["tfx_cust_seq"] + "' ";
            }
            if (ReqVal.TryGet("pfx_ap_cname1") != "") {
                SQL += "AND b.ap_cname1 like '" + Request["pfx_ap_cname1"] + "%' ";
            }
            if (ReqVal.TryGet("tfx_apcust_no") != "") {
                SQL += "AND a.apcust_no ='" + Request["tfx_apcust_no"] + "' ";
            }
            if (ReqVal.TryGet("pfx_ap_cname") != "") {
                SQL += "AND b.ap_cname like '" + Request["pfx_ap_cname"] + "%' ";
            }
            if (ReqVal.TryGet("A1") == "Y") {
                //抓創申案之案性種類
                string fsql = "select b.cust_code from cust_code a ";
                fsql += " inner join cust_code b on a.cust_code=b.code_type and b.ref_code='A' ";
                fsql += " where a.code_type='TRS_TYPE' ";
                DataTable dt1 = new DataTable();
                conn.DataTable(fsql, dt1);
                var list_class = dt.AsEnumerable().Select(r => r.Field<string>("scode")).ToArray();
                string prs_class = string.Join("','", list_class);
                if (prs_class == "") prs_class = "A1";
                SQL += " and a.arcase in (select rs_code from code_br where rs_type = 'T92' and rs_class in ('" + prs_class + "') )";
            }
            if (ReqVal.TryGet("scode") != "") {
                SQL += " and a.scode = '" + Request["scode"] + "' ";
            }
            if (ReqVal.TryGet("in_date") != "") {
                SQL += " and a.in_date = '" + Request["in_date"] + "' ";
            }
            if (ReqVal.TryGet("in_yy") != "" && ReqVal.TryGet("in_mm") != "") {
                SQL += " and year(a.in_date) = '" + Request["in_yy"] + "' ";
                SQL += " and month(a.in_date) = '" + Request["in_mm"] + "' ";
            }

            ReqVal["qryOrder"] = ReqVal.TryGet("SetOrder", ReqVal.TryGet("qryOrder"));
            if (ReqVal.TryGet("qryOrder") != "") {
                SQL += " order by " + ReqVal.TryGet("qryOrder");
            } else {
                SQL += " order by seq,seq1";
            }
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
                dr["fseq"] = Sys.formatSeq(dr.SafeRead("seq", ""), dr.SafeRead("seq1", ""), "", "", "");
                if (dr.SafeRead("end_date", "") != "") {
                    dr["end_star"] = "<font color=red>*</font>";
                }
                dr["cust_area"] = dr.SafeRead("cust_area", "").Left(1);
                dr["url"] = GetLink(dr);
            }
            
            dataRepeater.DataSource = page.pagedTable;
            dataRepeater.DataBind();
        }
    }

    protected string GetLink(DataRow row) {
        string url = Page.ResolveUrl("~/Brt5m/Brt15showFP.aspx") + "?prgid="+prgid+"&cust_area=" + row.SafeRead("cust_area", "") + "&seq=" + row.SafeRead("seq", "") + "&seq1=" + row.SafeRead("seq1", "");
        if (ReqVal.TryGet("submittask") == "Q") {
            return url + "&submittask=Q";
        } else {
            return url + "&submittask=U";
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
    <table style="display:<%#page.totRow==0?"none":""%>" border="0" class="bluetable" cellspacing="1" cellpadding="2" width="90%" align="center" id="dataList">
	    <thead>
            <Tr>
	            <td align="center" class="lightbluetable">案件編號</td>
	            <td align="center" class="lightbluetable">案件名稱</td>
	            <td align="center" class="lightbluetable">客戶名稱</td>	
	            <td align="center" class="lightbluetable">類別</td>
	            <td align="center" class="lightbluetable">營洽</td>
            </tr>
	    </thead>
	    <tbody>
</HeaderTemplate>
			<ItemTemplate>
 		        <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>">
                    <td class="whitetablebg"><p align="center"><a href="<%#Eval("url")%>" target="Eblank"><%#Eval("end_star")%><%#Eval("fseq")%></a></td>
                    <td class="whitetablebg"><p align="left"><a href="<%#Eval("url")%>" target="Eblank"><%#Eval("appl_name")%></a></td>
                    <td class="whitetablebg"><p align="left"><a href="<%#Eval("url")%>" target="Eblank"><%#Eval("cust_area")%><%#Eval("cust_seq")%>&nbsp;<%#Eval("cust_name")%></a></td>
                    <td class="whitetablebg"><p align="center"><%#Eval("class")%></td>	
                    <td class="whitetablebg"><p align="center"><%#Eval("scode1nm")%></td>
				</tr>
			</ItemTemplate>
<FooterTemplate>
	    </tbody>
    </table>
	<BR>
    <table style="display:<%#page.totRow==0?"none":""%>" border="0" width="100%" cellspacing="0" cellpadding="0">
		<tr class="FormName"><td>
			<div align="left">
                ◎本所編號前有　<font color=red size=2>' * '</font>　符號者，表該案件已結案!!
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

        $(".Lock").lock();
        $("input.dateField").datepick();
    });
    //執行查詢
    function goSearch() {
        $("#regPage").submit();
    };
</script>