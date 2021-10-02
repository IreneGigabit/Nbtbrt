<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Linq"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<script runat="server">
    protected string HTProgCap = "客戶資料清單";//HttpContext.Current.Request["prgname"];//功能名稱
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

    protected string ref_no = "";
    protected string submitTask = "";
    protected string ap_name = "";
    DataTable dtCountry = Sys.getCountry();
    
    DBHelper conn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    //DBHelper cnn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    private void Page_Unload(System.Object sender, System.EventArgs e) {
        if (conn != null) { conn.Dispose();}
        //if (cnn != null) cnn.Dispose();
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
        //cnn = new DBHelper(Conn.Sysctrl).Debug(Request["chkTest"] == "TEST");

        submitTask = Request["submitTask"];
        if ((Request["ap_name"] ?? "") != "") ap_name = Request["ap_name"];
        
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
            if (submitTask != "Q")
            {
                StrFormBtnTop += "<a href=javascript:GoToAdd()>[客戶新增]</a>";
            }
            StrFormBtnTop += "<a href=javascript:GoToSearch()>[客戶查詢]</a>";
        }
        
    }


    private void QueryData() {
        
        DataTable dt = new DataTable();
        //foreach (var item in ReqVal)
        //{
        //    Response.Write("[Key = " + item.Key + ", Value = " + item.Value + "], ");
        //}
        SQL = "SELECT *,";
        SQL += "(select sc_name from sysctrl.dbo.scode where scode = a.pscode) as pscodename , (select sc_name from sysctrl.dbo.scode where scode = a.tscode) as tscodename , ";
        SQL += "(select code_name from cust_code where code_type= 'rmark_code' and cust_code = a.rmark_code) as rmarkcodename, ";
        SQL += "(select count(*) as qty from apcust_attach where cust_area = a.cust_area and cust_seq = a.cust_seq and source = 'contract') as contractqty ";
        SQL += "FROM custz a LEFT JOIN apcust b ON a.cust_seq=b.cust_seq WHERE 1=1 ";

        //ReqVal.TryGet("")
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

            if (ap_name != "")
            {
                SQL += " AND (ap_cname1 LIKE '%" + ap_name + "%' OR ap_cname2 LIKE '%" + ap_name + "%' ";
                SQL += " OR ap_ename1 LIKE '%" + ap_name + "%' OR ap_ename2 LIKE '%" + ap_name + "%')";
            }
            
        }

        SQL += " order by a.cust_seq desc";
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
        <td class="text9" nowrap="nowrap">&nbsp;【cust11_List <%=HTProgCap%>】</td>
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
		        <td class=lightbluetable align=center>客戶編號</td>
		        <td class=lightbluetable align=center>客戶名稱</td>
		        <td class=lightbluetable align=center>代表人</td>
		        <td class=lightbluetable align=center>統一編號</td>
		        <td class=lightbluetable align=center>建檔日期</td>
                <td class=lightbluetable align=center>專商營洽</td>
		        <td class=lightbluetable align=center>聯絡人</td>
                <td class=lightbluetable align=center>契約書</td>
                <td class=lightbluetable align=center>債信</td>
               <%-- <td class=lightbluetable align=center>登錄</td>--%>
		        <td class=lightbluetable align=center>特殊維護</td>
                <td style="display:none;" >cust_seq</td>
            </tr>
	    </thead>
	    <tbody>
</HeaderTemplate>
			<ItemTemplate>
 		        <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>" align="center" style="height:​30px;">
			        <td nowrap>
                        <a href="cust11_Edit.aspx?prgid=<%=prgid%>&apsqlno=<%#Eval("apsqlno")%>&cust_area=<%#Eval("cust_area")%>&cust_seq=<%#Eval("cust_seq")%>&submitTask=<%=submitTask%>" target="Eblank">
                            <%#Eval("cust_seq")%></a>
			        </td>
			        <td nowrap>
                        <a href="cust11_Edit.aspx?prgid=<%=prgid%>&apsqlno=<%#Eval("apsqlno")%>&cust_area=<%#Eval("cust_area")%>&cust_seq=<%#Eval("cust_seq")%>&submitTask=<%=submitTask%>" target="Eblank">
                            <%#Eval("ap_cname1")%> <%#Eval("ap_cname2")%></a>
			        </td>
			        <td nowrap><%# (Eval("ap_erep").ToString() == "") ? Eval("ap_crep") : Eval("ap_crep").ToString() + "/" + Eval("ap_erep").ToString()%></td>
			        <td nowrap><%#Eval("id_no")%></td>
			        <td >
                        <%# (Eval("in_date").ToString() == "") ? "" : DateTime.Parse(Eval("in_date").ToString()).ToString("yyyy/M/d")%>
			        </td>
			        <td nowrap>
                            <%# (Eval("pscode").ToString().Trim(' ') == "np") ? "專利部門" : Eval("pscodename")%>/<%#Eval("tscodename")%>
			        </td>
			        <td nowrap>
                        <a href="cust12_Query.aspx?prgid=cust12&submitTask=<%=submitTask%>&cust_area=<%#Eval("cust_area")%>&cust_seq=<%#Eval("cust_seq")%>&ap_cname1=<%#Eval("ap_cname1")%>" target="Eblank">[清單]</a>
                        <a class="hideattAdd" href="cust11_Edit.aspx?prgid=cust11&submitTask=A&Type=ap_nameaddr&cust_area=<%#Eval("cust_area")%>&cust_seq=<%#Eval("cust_seq")%>&cust_att=A" target="Eblank">[新增]</a>
			        </td>
			        <td nowrap>
                        <%--<a href="cust21_List.aspx?prgid=cust21&submistTask=Q&cust_area=<%#Eval("cust_area")%>&cust_seq=" ></a>--%>
                        <a href="javascript:GetContract('<%#Eval("cust_area")%>', '<%#Eval("cust_seq")%>')">[<%#Eval("contractqty") %>]</a>
			        </td>
                    <td nowrap><%#Eval("rmarkcodename")%></td>
                  <%--  <td nowrap>
                        <select>
                            <option>請選擇</option>
                            <option>內專</option>
                            <option>出專</option>
                        </select>
                        <em>(待補)</em>
                    </td>--%>
                    <td nowrap>
                        <a href="#">[修改](待補)</a>
                    </td>
                    <td style="display:none;">[<%#Eval("cust_seq")%>]</td>
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

            if ($("#submitTask").val() == "Q") {

                var trs = $(".hideattAdd");
                //trs[0].style.display = "none";
                //trs.hide();
                for (i = 0; i < trs.length; i++) {
                    trs[i].style.display = "none"; //這裡獲取的trs[i]是DOM物件而不是jQuery物件，因此不能直接使用hide()方法 
                }
            }

        }

        $(".Lock").lock();
        $("input.dateField").datepick();
    });

    //執行查詢
    function goSearch() {
        $("#regPage").submit();
    };
    //////////////////////

    function GoToSearch() {
        var s = <%="'"+ submitTask + "'"%>;
        if (s == "A") {
            s = "U";
        }
        reg.action = "cust11_1.aspx?prgid=<%=prgid%>&submitTask=" + s;
        reg.submit();
    }

    function GoToAdd() {
        window.open("cust11_Edit.aspx?prgid=cust11&submitTask=A&cust_area=<%=Sys.GetSession("seBranch")%>", "Eblank");
        window.parent.tt.rows = "0%,100%";
    }

    function GetContract (cust_area, cust_seq) {
        //window.open("cust21_List.aspx?prgid=cust21&qcontract=Q&qrycust_area="+cust_area+"&qrycust_seq="+cust_seq+"&qryattach_flag=U", "Eblank");
        window.open("cust21_List.aspx?prgid=cust21&qcontract=Q&qrycust_area="+cust_area+"&qrycust_seq="+cust_seq, "Eblank");
        //window.parent.tt.rows = "50%,50%";
        //&qryattach_flag=A,U
    }


</script>