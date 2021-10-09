<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Linq"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>

<!DOCTYPE html>
<script runat="server">
    protected string HTProgCap = "客戶資料查詢清單";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "cust21";//程式檔名前綴
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

    protected string submitTask = "";
    protected string no = "";//from cust11_1&cust13
    
    DBHelper conn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    private void Page_Unload(System.Object sender, System.EventArgs e) {
        if (conn != null) conn.Dispose();
    }

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");
        conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
        if ((Request["no"] ?? "") != "") no = Request["no"];

        submitTask = Request["submitTask"];

        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
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
            StrFormBtnTop += "<a class=\"imgCls\" href=\"javascript:void(0);\" >[關閉視窗]</a>\n";
        }

    }

    private void QueryData() {
        
        DataTable dt = new DataTable();
        string dept = Sys.GetSession("dept").ToLower();

        SQL = "SELECT a.cust_area, a.cust_seq, b.apsqlno, b.apcust_no, b.ap_cname1, b.ap_cname2, b.ap_crep, b.ap_country, a."+dept+"scode as scode, ";
        SQL += "b.apcust_no, b.apclass, b.ap_country, b.ap_addr1, b.ap_addr2, b.ap_eaddr1, b.ap_eaddr2, b.ap_eaddr3, b.ap_eaddr4, ";
        SQL += "(select code_name From cust_code where Code_type='apclass' and cust_code=b.apclass) as apclassnm, ";
        SQL += "(select sc_name from sysctrl.dbo.scode where scode = a."+dept+"scode) as scodename, ";
        //SQL += "(select sc_name from sysctrl.dbo.scode where scode = a.tscode) as tscodename,";
        SQL += "(select code_name from cust_code where code_type='level' and cust_code=a."+dept+"level) as levelnm ";
        SQL += "FROM custz a LEFT JOIN apcust b ON a.cust_seq=b.cust_seq WHERE 1=1 ";

        if (ReqVal.TryGet("cust_seq") != "")
        {
            SQL += " AND a.cust_seq = '" + ReqVal.TryGet("cust_seq") + "'";
        }
        else
        {
            if (ReqVal.TryGet("apclass") != "")
            {
                SQL += " AND apclass = '" + ReqVal.TryGet("apclass") + "'";
            }
            if (ReqVal.TryGet("id_no") != "")
            {
                SQL += " AND id_no LIKE '%" + ReqVal.TryGet("id_no") + "%'";
            }
            if (ReqVal.TryGet("ref_seq") != "")
            {
                SQL += " AND ref_seq = '" + ReqVal.TryGet("ref_seq") + "'";
            }
            if (ReqVal.TryGet("ap_crep") != "")
            {
                SQL += " AND ap_crep LIKE '%" + ReqVal.TryGet("ap_crep") + "%'";
            }
            if (ReqVal.TryGet("ap_erep") != "")
            {
                SQL += " AND ap_erep LIKE '%" + ReqVal.TryGet("ap_erep") + "%'";
            }
            if (ReqVal.TryGet("ap_country") != "")
            {
                SQL += " AND ap_country = '" + ReqVal.TryGet("ap_country") + "'";
            }

            string scodeStr = Sys.GetSession("dept").ToLower() + "scode";
            if (ReqVal.TryGet("scode") != "")
            {
                SQL += " AND " + scodeStr + " = '" + ReqVal.TryGet("scode") + "'";
            }
            //日期範圍
            if (ReqVal.TryGet("sdate") != "")
            {
                SQL += " AND a." + Request["dKind"].ToString() + " >= '" + ReqVal.TryGet("sdate") + "'";
            }
            if (ReqVal.TryGet("edate") != "")
            {
                SQL += " AND a." + Request["dKind"].ToString() + " <= '" + ReqVal.TryGet("edate") + " 23:59:59'";
            }


            //地址
            if (ReqVal.TryGet("addr_zip") != "")
            {
                if (Request["addrtype"].ToString() == "ap_addr1")
                {
                    SQL += " AND ap_zip LIKE '%" + ReqVal.TryGet("addr_zip") + "%'";
                }
                else
                {
                    SQL += " AND (acc_zip LIKE '%" + ReqVal.TryGet("addr_zip") + "%' OR tacc_zip LIKE '%" + ReqVal.TryGet("addr_zip") + "%')";
                }
            }
            if (ReqVal.TryGet("addr") != "")
            {
                if (Request["addrtype"].ToString() == "ap_addr1")
                {
                    SQL += " AND (ap_addr1 LIKE '%" + ReqVal.TryGet("addr") + "%' OR ap_addr2 LIKE '%" + ReqVal.TryGet("addr") + "%')";
                }
                else if (Request["addrtype"].ToString() == "ap_eaddr1")
                {
                    SQL += " AND (ap_eaddr1 LIKE '%" + ReqVal.TryGet("addr") + "%' OR ap_eaddr2 LIKE '%" + ReqVal.TryGet("addr") + "%')";
                }
                else
                {
                    //if (Sys.GetSession("dept") == "P")
                    //{
                    //    SQL += " AND (acc_addr1 LIKE '%" + ReqVal.TryGet("addr") + "%' OR acc_addr2 LIKE '%" + ReqVal.TryGet("addr") + "%')";
                    //}
                    //else
                    //{
                    //    SQL += " AND (tacc_addr1 LIKE '%" + ReqVal.TryGet("addr") + "%' OR tacc_addr2 LIKE '%" + ReqVal.TryGet("addr") + "%')";
                    //}
                    SQL += " AND (acc_addr1 LIKE '%" + ReqVal.TryGet("addr") + "%' OR acc_addr2 LIKE '%" + ReqVal.TryGet("addr") + "%' OR tacc_addr1 LIKE '%"
                        + ReqVal.TryGet("addr") + "%' OR tacc_addr2 LIKE '%" + ReqVal.TryGet("addr") + "%')";
                }
            }


            if (ReqVal.TryGet("acc_tel0") != "")
            {
                SQL += " AND acc_tel0 = '" + ReqVal.TryGet("acc_tel0") + "'";
            }
            if (ReqVal.TryGet("acc_tel") != "")
            {
                SQL += " AND acc_tel LIKE '%" + ReqVal.TryGet("acc_tel") + "%'";
            }
            if (ReqVal.TryGet("acc_tel1") != "")
            {
                SQL += " AND acc_tel1 LIKE '%" + ReqVal.TryGet("acc_tel1") + "%'";
            }
            if (ReqVal.TryGet("acc_fax") != "")
            {
                SQL += " AND acc_fax LIKE '%" + ReqVal.TryGet("acc_fax") + "%'";
            }
            if (ReqVal.TryGet("tlevel") != "")
            {
                SQL += " AND tlevel = '" + ReqVal.TryGet("tlevel") + "'";
            }
            if (ReqVal.TryGet("tdis_type") != "")
            {
                SQL += " AND tdis_type = '" + ReqVal.TryGet("tdis_type") + "'";
            }
            if (ReqVal.TryGet("tpay_type") != "")
            {
                SQL += " AND tpay_type = '" + ReqVal.TryGet("tpay_type") + "'";
            }
            if (ReqVal.TryGet("plevel") != "")
            {
                SQL += " AND plevel = '" + ReqVal.TryGet("plevel") + "'";
            }
            if (ReqVal.TryGet("pdis_type") != "")
            {
                SQL += " AND pdis_type = '" + ReqVal.TryGet("pdis_type") + "'";
            }
            if (ReqVal.TryGet("ppay_type") != "")
            {
                SQL += " AND ppay_type = '" + ReqVal.TryGet("ppay_type") + "'";
            }
            if (ReqVal.TryGet("ap_cname1") != "")
            {
                SQL += " AND (ap_cname1 LIKE '%" + ReqVal.TryGet("ap_cname1") + "%'";
                SQL += " OR ap_cname2 LIKE '%" + ReqVal.TryGet("ap_cname1") + "%')";
            }
            if (ReqVal.TryGet("ap_ename1") != "")
            {
                SQL += " AND (ap_ename1 LIKE '%" + ReqVal.TryGet("ap_ename1") + "%'";
                SQL += " OR ap_ename2 LIKE '%" + ReqVal.TryGet("ap_ename1") + "%')";
            }
            if (ReqVal.TryGet("rmark_code") != "")
            {
                string rcodeStr = "";
                string[] rcode = ReqVal.TryGet("rmark_code").Split(',');
                for (int i = 0; i < rcode.Length; i++)
                {
                    rcodeStr += "'" + rcode[i] + "',";
                }
                SQL += " AND a.rmark_code IN (" + rcodeStr.Trim(',') + ")";
            }
        }
        string wsql = " order by a.cust_seq desc";
        
        //cust22_Edit申請人委任書條件
        if (ReqVal.TryGet("apcust_no") != "" || ReqVal.TryGet("ap_cname") != "")
        {
            SQL = "select *, (select code_name From cust_code where Code_type='apclass' and cust_code=a.apclass) as apclassnm from apcust a where 1=1 ";
            wsql = " order by apsqlno desc";
        }
        if (ReqVal.TryGet("apcust_no") != "")
        {
            SQL += " AND apcust_no = '" + ReqVal.TryGet("apcust_no") + "'";
        }
        if (ReqVal.TryGet("ap_cname") != "")
        {
            SQL += " AND (ap_cname1 LIKE '%" + ReqVal.TryGet("ap_cname") + "%'";
            SQL += " OR ap_cname2 LIKE '%" + ReqVal.TryGet("ap_cname") + "%')";
        }

        SQL += wsql;
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
        }

        if (prgid == "cust21")
        {
            dataRepeater.DataSource = page.pagedTable;
            dataRepeater.DataBind();
            dataRepeater2.Visible = false;
        }
        else
        {
            dataRepeater2.DataSource = page.pagedTable;
            dataRepeater2.DataBind();
            dataRepeater.Visible = true;
        }
        
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title><%=HTProgCap%></title>
    <meta http-equiv="x-ua-compatible" content="IE=10">
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
    <table style="display:<%#page.totRow==0?"none":""%>" border="0" class="bluetable" cellspacing="1" cellpadding="2" width="80%" align="center" id="dataList">
	    <thead>
            <tr>
		        <td class=lightbluetable align=center>客戶編號</td>
                <td class=lightbluetable align=center>証照號碼</td>
		        <td class=lightbluetable align=center>客戶名稱</td>
                <td class=lightbluetable align=center>代表人名稱</td>
		        <td class=lightbluetable align=center>國籍</td>
            </tr>
	    </thead>
	    <tbody>
</HeaderTemplate>
			<ItemTemplate>
 		        <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>" align="center" style="height:30px" 
                     onclick="Get_Csut_seq('<%#Eval("cust_seq")%>','<%#Eval("ap_cname1")%><%#Eval("ap_cname2")%>', '<%#Eval("levelnm")%>', '<%#Eval("scode")%><%#Eval("scodename")%>', '<%#Eval("apsqlno")%>')" >
			        <td nowrap>
                        <a href="javascript:void(0)"><%#Eval("cust_area")%><%#Eval("cust_seq")%></a>
			        </td>
			        <td nowrap>
                        <a href="javascript:void(0)"><%#Eval("apcust_no")%></a>
			        </td>
			        <td nowrap>
                        <a href="javascript:void(0)"><%#Eval("ap_cname1")%><%#Eval("ap_cname2")%></a>
			        </td>
			        <td nowrap>
                        <a href="javascript:void(0)"><%#Eval("ap_crep")%></a>
			        </td>
                     <td nowrap>
                        <a href="javascript:void(0)"><%#Eval("ap_country")%></a>
			        </td>
				</tr>
			</ItemTemplate>
<FooterTemplate>
	    </tbody>
    </table>
    <BR>
    
</FooterTemplate>
</asp:Repeater>

<asp:Repeater id="dataRepeater2" runat="server">
<HeaderTemplate>
    <table style="display:<%#page.totRow==0?"none":""%>" border="0" class="bluetable" cellspacing="1" cellpadding="2" width="80%" align="center" id="dataList2">
	    <thead>
            <tr>
                <td class=lightbluetable align=center>申請人流水號</td>
                <td class=lightbluetable align=center>申請人編號</td>
		        <td class=lightbluetable align=center>申請人名稱</td>
                <td class=lightbluetable align=center>代表人名稱</td>
                <td class=lightbluetable align=center>申請人種類</td>
		        <td class=lightbluetable align=center>申請人國籍</td>
            </tr>
	    </thead>
	    <tbody>
</HeaderTemplate>
			<ItemTemplate>
 		        <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>" align="center" style="height:30px" 
                     onclick="Get_Apcust_no('<%#Eval("apcust_no")%>','<%#Eval("ap_cname1")%><%#Eval("ap_cname2")%>', '<%#Eval("ap_crep")%>', '<%#Eval("apclass")%><%#Eval("apclassnm")%>', '<%#Eval("ap_addr1")%><%#Eval("ap_addr2")%>', '<%#Eval("ap_eaddr1")%><%#Eval("ap_eaddr2")%><%#Eval("ap_eaddr3")%><%#Eval("ap_eaddr4")%>', '<%#Eval("apsqlno")%>')" >
			        <td nowrap>
                        <a href="javascript:void(0)"><%#Eval("apsqlno")%></a>
			        </td>
			        <td nowrap>
                        <a href="javascript:void(0)"><%#Eval("apcust_no")%></a>
			        </td>
			        <td nowrap>
                        <a href="javascript:void(0)"><%#Eval("ap_cname1")%><%#Eval("ap_cname2")%></a>
			        </td>
			        <td nowrap>
                        <a href="javascript:void(0)"><%#Eval("ap_crep")%></a>
			        </td>
                    <td nowrap>
                        <a href="javascript:void(0)"><%#Eval("apclass")%><%#Eval("apclassnm")%></a>
			        </td>
                    <td nowrap>
                        <a href="javascript:void(0)"><%#Eval("ap_country")%></a>
			        </td>
				</tr>
			</ItemTemplate>
<FooterTemplate>
	    </tbody>
    </table>
    <BR>
    
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

    });


    //換頁查詢
    function goSearch() {
        $("#regPage").submit();
    };

    function Get_Csut_seq(cust_seq, ap_cname, level, scodename, apsqlno) {
        window.opener.reg.scust_seq_<%=no%>.value = cust_seq;
        window.opener.reg.scust_name_<%=no%>.value = ap_cname;
        window.opener.reg.aplevelnm_<%=no%>.value = level;
        window.opener.reg.scodenm_<%=no%>.value = scodename;
        window.opener.reg.sapsqlno_<%=no%>.value = apsqlno;
        window.close();
    }

    function Get_Apcust_no (apcust_no, ap_cname, ap_crep, apclassnm, ap_addr, ap_eaddr, apsqlno) {
        window.opener.reg.sapcust_no_<%=no%>.value = apcust_no;
        window.opener.reg.sap_cname_<%=no%>.value = ap_cname;
        window.opener.reg.ap_crep_<%=no%>.value = ap_crep;
        window.opener.reg.apclassnm_<%=no%>.value = apclassnm;
        window.opener.reg.ap_addr_<%=no%>.value = ap_addr;
        window.opener.reg.ap_eaddr_<%=no%>.value = ap_eaddr;
        window.opener.reg.sapsqlno_<%=no%>.value = apsqlno;
        window.close();
    }




</script>