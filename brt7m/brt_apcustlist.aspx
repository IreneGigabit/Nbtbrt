<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>

<script runat="server">
    protected string HTProgCap = "一般請款單開立作業-[共同申請人]交辦案件申請人清單";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";

    protected string SQL = "";

    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected Paging page = null;

    protected string qs_dept = "", tblname = "";
    
    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");

        qs_dept = (Request["qs_dept"] ?? "").ToLower();
        if (qs_dept == "t") {
            tblname = "dmt_temp_ap";
        } else if (qs_dept == "e") {
            tblname = "caseext_apcust";
        }
   
        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        //HTProgCap = myToken.Title;
        DebugStr = myToken.DebugStr;

        if (HTProgRight >= 0) {
            QueryData();

            this.DataBind();
        }
    }

    private void QueryData() {
        using (DBHelper conn = new DBHelper(Conn.btbrt, false).Debug(Request["chkTest"] == "TEST")) {
            SQL = "select a.apsqlno, b.apcust_no,(b.ap_cname1+isnull(b.ap_cname2,'')) as ap_cname,b.cust_area,b.cust_seq";
            SQL+= " From " + tblname + " a ";
            SQL+= " inner join apcust b on a.apsqlno=b.apsqlno";
            SQL+= " where a.in_no = '" + in_no + "'";
    
            if (ReqVal.TryGet("SetOrder") != "") {
                SQL += " order by " + ReqVal.TryGet("SetOrder");
            } else {
                if (qs_dept == "t") {
                    SQL += " order by a.temp_ap_sqlno";
                } else {
                    SQL += " order by a.sqlno";
                }
            }
            DataTable dt = new DataTable();
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
    }
</script>
<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title><%=HTProgCap%></title>
<uc1:head_inc_form runat="server" ID="head_inc_form" />
</head>

<body onload="window.focus();">
<table cellspacing="1" cellpadding="0" width="98%" border="0">
    <tr>
        <td class="text9" nowrap="nowrap">&nbsp;【<%=prgid%><%=HTProgCap%>】</td>
        <td class="FormLink" valign="top" align="right" nowrap="nowrap">
            <a class="imgCls" href="javascript:void(0);" >[關閉視窗]</a>
        </td>
    </tr>
    <tr>
        <td colspan="2"><hr class="style-one"/></td>
    </tr>
</table>
<form id="regPage" name="regPage" method="post">
    <%#page.GetHiddenText("GoPage,PerPage,SetOrder,chktest")%>
    <div id="divPaging" style="display:<%#page.totRow==0?"none":""%>">
    <TABLE border=0 cellspacing=1 cellpadding=0 width="98%" align="center">
        <tr>
            <td colspan=2 align=center>
                <font size="2" color="#3f8eba">
                第<font color="red"><span id="NowPage"><%#page.nowPage%></span>/<span id="TotPage"><%#page.totPage%></span></font>頁
                | 資料共 <font color="red"><span id="TotRec"><%#page.totRow%></span></font> 筆
                | 跳至第<select id="GoPage" name="GoPage" style="color:#FF0000"><%#page.GetPageList()%></select>頁
                <span id="PageUp" style="display:<%#page.nowPage>1?"":"none"%>">| <a href="javascript:void(0)" class="pgU" v1="<%#page.nowPage-1%>">上一頁</a></span>
                <span id="PageDown" style="display:<%#page.nowPage<page.totPage?"":"none"%>">| <a href="javascript:void(0)" class="pgD" v1="<%#page.nowPage+1%>">下一頁</a></span>
                | 每頁筆數:
                <select id="PerPage" name="PerPage" style="color:#FF0000">
                 <option value="10" <%#page.perPage==10?"selected":""%>>10</option>
                 <option value="20" <%#page.perPage==20?"selected":""%>>20</option>
                 <option value="30" <%#page.perPage==30?"selected":""%>>30</option>
                 <option value="30" <%#page.perPage==40?"selected":""%>>40</option>
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
	    <font color="red">=== 查無案件資料 ===</font>
    </div>

    <asp:Repeater id="dataRepeater" runat="server">
    <HeaderTemplate>
        <table style="display:<%#page.totRow==0?"none":""%>" border="0" class="bluetable" cellspacing="1" cellpadding="2" width="98%" align="center" id="dataList">
	        <thead>
	            <TR>
                    <td class="bluetext2" align="center" nowrap>客戶編號</td>
		            <td class="bluetext2" align="center" nowrap>申請人編號</td>
                    <td class="bluetext2" align="center" nowrap>客戶/申請人名稱</td>
	            </TR>
	        </thead>
	        <tbody>
    </HeaderTemplate>
			    <ItemTemplate>
                    <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>" align="center">
                        <td nowrap><%#Eval("cust_area")%><%#Eval("cust_seq")%></td>
		                <td nowrap title="<%#Eval("apsqlno")%>">
                            <font style="cursor: pointer;color:darkblue" onmouseover="this.style.color='red'" onmouseout="this.style.color='darkblue'" onclick="getapcustno('<%#(Container.ItemIndex+1)%>')">
                                <%#Eval("apcust_no")%>
                            </font>
                        </td>
		                <td nowrap ><%#Eval("ap_cname")%>
                            <INPUT TYPE="hidden" id="apsqlno_<%#(Container.ItemIndex+1)%>" value="<%#Eval("apsqlno")%>" >
		                    <INPUT TYPE="hidden" id="apcust_no_<%#(Container.ItemIndex+1)%>" value="<%#Eval("apcust_no")%>" >
		                    <INPUT TYPE="hidden" id="ap_cname_<%#(Container.ItemIndex+1)%>" value="<%#Eval("ap_cname")%>" >
		                </td>
		            </tr>
			    </ItemTemplate>
    <FooterTemplate>
	        </tbody>
        </table>
    <br>
    <p style="text-align:center;display:<%#page.totRow==0?"none":""%>">
	    <font color=blue>*** 請點選申請人編號，以帶回請款開立ID及名稱 ***</font>
    </p>
</FooterTemplate>
</asp:Repeater>

<div id="dialog"></div>

</body>
</html>

<script language="javascript" type="text/javascript">
    $(function () {
        if (window.parent.tt !== undefined) {
            window.parent.tt.rows = "100%,0%";
        }
    });

    //執行查詢
    function goSearch() {
        $("#regPage").submit();
    };
    //////////////////////
    //帶回申請人編號及名稱
    function getapcustno(pno) {
        $("#apsqlno", opener.document).val($("#apsqlno_" + x1).val());
        window.opener.reg.tfx_apcust_no.value = $("#apcust_no_" + x1).val();
        window.opener.reg.ap_cname.value = $("#ap_cname_" + x1).val();
        window.opener.reg.myobject.value = "A";
        window.opener.reg.tobject(1).checked = true;//案件申請人
        window.opener.reg.tfx_apcust_no.disabled = false;
        window.opener.reg.tfx_rec_chk1.checked = false;//檢附間接委辦單
        window.opener.reg.rec_chk1.value = "N";
        window.close();
    }
</script>
