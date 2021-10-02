<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>

<script runat="server">
    protected string HTProgCap = "申請人英文名稱及地址查詢結果畫面";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";

    protected string SQL = "";

    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected Paging page = null;

    protected string apsqlno = "";
    protected string pnum = "";
    protected string fld = "";//欄位前置變數，tfr:關係人,內商為變更申請人前變數
    protected string trid = "";//申請人序號tr id的前置變數，ex:trid=FC0→FC0trap_sql_##

    protected string apcust_no = "", ap_cname1="";
    
    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        apsqlno = Request["apsqlno"] ?? "";
        pnum = Request["pnum"] ?? "";
        fld = Request["fld"] ?? "";
        trid = Request["trid"] ?? "";

        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");
        
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
            SQL = "select a.*,b.apcust_no,b.ap_cname1,''ap_eaddr ";
            SQL += "from ap_nameaddr a ";
            SQL += "inner join apcust b on a.apsqlno= b.apsqlno ";
            SQL += "where 1=1";
            if (apsqlno != "") {
                SQL += " and a.apsqlno=" + apsqlno;
            }
            if (ReqVal.TryGet("SetOrder") != "") {
                SQL += " order by " + ReqVal.TryGet("SetOrder");
            } else {
                SQL += " order by a.ap_sql";
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

                apcust_no = dr.SafeRead("apcust_no", "");
                ap_cname1 = dr.SafeRead("ap_cname1", "");
                
                if (dr.SafeRead("ap_eaddr1", "") != "") dr["ap_eaddr"] += dr.SafeRead("ap_eaddr1", "");
                if (dr.SafeRead("ap_eaddr2", "") != "") dr["ap_eaddr"] += "<br>" + dr.SafeRead("ap_eaddr2", "");
                if (dr.SafeRead("ap_eaddr3", "") != "") dr["ap_eaddr"] += "<br>" + dr.SafeRead("ap_eaddr3", "");
                if (dr.SafeRead("ap_eaddr4", "") != "") dr["ap_eaddr"] += "<br>" + dr.SafeRead("ap_eaddr4", "");
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

	<input type=text id="pnum" name="pnum" value="<%=pnum%>"><!--交辦用，第幾筆申請人-->
	<input type=text id="fld" name="fld" value="<%=fld%>"><!--交辦用，區分申請人或關係人欄位-->
	<input type=text id="trid" name="trid" value="<%=trid%>"><!--國內變更交辦用，區分變更不同申請人序號tr.idname-->

    <asp:Repeater id="dataRepeater" runat="server">
    <HeaderTemplate>
        <div align="center" style="display:<%#page.totRow==0?"none":""%>">
        ※申請人統編：<%=apcust_no%>&nbsp;&nbsp;中文名稱：<%=ap_cname1%>
        </div>
        <table style="display:<%#page.totRow==0?"none":""%>" border="0" class="bluetable" cellspacing="1" cellpadding="2" width="98%" align="center" id="dataList">
	        <thead>
	            <TR>
		            <TD class=lightbluetable align=center rowspan=2>序號</TD>
		            <TD class=lightbluetable align=center rowspan=2>英文名稱</TD>
		            <TD class=lightbluetable align=center>證照地址(中)</TD>
	            </TR>
	            <TR>
		            <TD class=lightbluetable align=center>證照地址(英)</TD>
	            </TR>
	        </thead>
	        <tbody>
    </HeaderTemplate>
			    <ItemTemplate>
		            <input type=hidden id="ap_ename1_<%#(Container.ItemIndex+1)%>" value="<%#Eval("ap_ename1").ToString().Trim()%>">
		            <input type=hidden id="ap_ename2_<%#(Container.ItemIndex+1)%>" value="<%#Eval("ap_ename2").ToString().Trim()%>">
		            <input type=hidden id="ap_zip_<%#(Container.ItemIndex+1)%>" value="<%#Eval("ap_zip").ToString().Trim()%>">
		            <input type=hidden id="ap_addr1_<%#(Container.ItemIndex+1)%>" value="<%#Eval("ap_addr1").ToString().Trim()%>">
		            <input type=hidden id="ap_addr2_<%#(Container.ItemIndex+1)%>" value="<%#Eval("ap_addr2").ToString().Trim()%>">
		            <input type=hidden id="ap_eaddr1_<%#(Container.ItemIndex+1)%>" value="<%#Eval("ap_eaddr1").ToString().Trim()%>">
		            <input type=hidden id="ap_eaddr2_<%#(Container.ItemIndex+1)%>" value="<%#Eval("ap_eaddr2").ToString().Trim()%>">
		            <input type=hidden id="ap_eaddr3_<%#(Container.ItemIndex+1)%>" value="<%#Eval("ap_eaddr3").ToString().Trim()%>">
		            <input type=hidden id="ap_eaddr4_<%#(Container.ItemIndex+1)%>" value="<%#Eval("ap_eaddr4").ToString().Trim()%>">
                    <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>" align="center">
			            <td rowspan=2 style="cursor:pointer;" onmouseover="this.style.color='red'" onmouseout="this.style.color='black'" nowrap onclick="SeqClick('<%#(Container.ItemIndex+1)%>','<%#Eval("ap_sql")%>')"><%#Eval("ap_sql")%></td>
			            <td rowspan=2 ><%#Eval("ap_ename1").ToString().Trim()%>&nbsp;<%#Eval("ap_ename2").ToString().Trim()%></td>
			            <td >(<%#Eval("ap_zip").ToString().Trim()%>)<%#Eval("ap_addr1").ToString().Trim()%><%#Eval("ap_addr2").ToString().Trim()%></td>
		            </tr>
                    <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>" align="center">
			            <td ><%#Eval("ap_eaddr")%>
			            </td>
		            </tr>	

			    </ItemTemplate>
    <FooterTemplate>
	        </tbody>
        </table>
    <br>
    <p style="text-align:center;display:<%#page.totRow==0?"none":""%>">
	    <font color=blue>*** 請點選續號將資料帶回交辦作業 ***</font>
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
    function SeqClick(x1, x2) {
        var pnum = $("#pnum").val() || "";
        var fld = $("#fld").val() || "";
        var trid = $("#trid").val() || "";
        var gname1 = $("#ap_ename1_" + x1).val() + " " + $("#ap_ename2_" + x1).val();
        $("#" + fld + "ap_sql_" + pnum, opener.document).val(x2);

        //2011/1/20因內商增加申請人序號修改
        if ($("#prgid").val() == "brt54") {//國內案主檔維護
            if (fld != "") {
                $("#" + fld + "ap_ename_" + pnum, opener.document).val(gname1);
                $("#" + fld + "nzip_" + pnum, opener.document).val($("#ap_zip_" + x1).val());
                $("#" + fld + "nename1_" + pnum, opener.document).val($("#ap_ename1_" + x1).val());
                $("#" + fld + "nename2_" + pnum, opener.document).val($("#ap_ename2_" + x1).val());
                $("#" + fld + "naddr1_" + pnum, opener.document).val($("#ap_addr1_" + x1).val());
                $("#" + fld + "naddr2_" + pnum, opener.document).val($("#ap_addr2_" + x1).val());
                $("#" + fld + "neaddr1_" + pnum, opener.document).val($("#ap_eaddr1_" + x1).val());
                $("#" + fld + "neaddr2_" + pnum, opener.document).val($("#ap_eaddr2_" + x1).val());
                $("#" + fld + "neaddr3_" + pnum, opener.document).val($("#ap_eaddr3_" + x1).val());
                $("#" + fld + "neaddr4_" + pnum, opener.document).val($("#ap_eaddr4_" + x1).val());
            } else {
                $("#" + fld + "ap_ename_" + pnum, opener.document).val(gname1);
                $("#" + fld + "ap_zip_" + pnum, opener.document).val($("#ap_zip_" + x1).val());
                $("#" + fld + "ap_ename1_" + pnum, opener.document).val($("#ap_ename1_" + x1).val());
                $("#" + fld + "ap_ename2_" + pnum, opener.document).val($("#ap_ename2_" + x1).val());
                $("#" + fld + "ap_addr1_" + pnum, opener.document).val($("#ap_addr1_" + x1).val());
                $("#" + fld + "ap_addr2_" + pnum, opener.document).val($("#ap_addr2_" + x1).val());
                $("#" + fld + "ap_eaddr1_" + pnum, opener.document).val($("#ap_eaddr1_" + x1).val());
                $("#" + fld + "ap_eaddr2_" + pnum, opener.document).val($("#ap_eaddr2_" + x1).val());
                $("#" + fld + "ap_eaddr3_" + pnum, opener.document).val($("#ap_eaddr3_" + x1).val());
                $("#" + fld + "ap_eaddr4_" + pnum, opener.document).val($("#ap_eaddr4_" + x1).val());
            }
            $("#" + trid + "trap_sql_" + pnum, opener.document).show();
        } else {
            $("#" + fld + "ap_ename_" + pnum, opener.document).val(gname1);
            $("#" + fld + "ap_zip_" + pnum, opener.document).val($("#ap_zip_" + x1).val());
            $("#" + fld + "ap_ename1_" + pnum, opener.document).val($("#ap_ename1_" + x1).val());
            $("#" + fld + "ap_ename2_" + pnum, opener.document).val($("#ap_ename2_" + x1).val());
            $("#" + fld + "ap_addr1_" + pnum, opener.document).val($("#ap_addr1_" + x1).val());
            $("#" + fld + "ap_addr2_" + pnum, opener.document).val($("#ap_addr2_" + x1).val());
            $("#" + fld + "ap_eaddr1_" + pnum, opener.document).val($("#ap_eaddr1_" + x1).val());
            $("#" + fld + "ap_eaddr2_" + pnum, opener.document).val($("#ap_eaddr2_" + x1).val());
            $("#" + fld + "ap_eaddr3_" + pnum, opener.document).val($("#ap_eaddr3_" + x1).val());
            $("#" + fld + "ap_eaddr4_" + pnum, opener.document).val($("#ap_eaddr4_" + x1).val());
        }
        window.close();
    }
</script>
