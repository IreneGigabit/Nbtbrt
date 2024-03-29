﻿<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<script runat="server">
    protected string HTProgCap = "程式資料";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "AP";//HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string Title = "";
    protected string DebugStr = "";

    protected string SQL = "";

    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected Paging page = null;
    protected string syscode = "";
    protected string apcat = "";

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        syscode = Request["Syscode"] ?? "";
        apcat = Request["apcat"] ?? "";
        
        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");

        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        Title = myToken.Title;
        DebugStr = myToken.DebugStr;
        if (HTProgRight >= 0) {
            QueryData();
            
            this.DataBind();
        }
    }

    private void QueryData() {
        using (DBHelper cnn = new DBHelper(Conn.ODBCDSN, false).Debug(Request["chkTest"] == "TEST")) {
            SQL = "SELECT * ";
            SQL += "FROM AP A ";
            SQL += "inner join APcat B on A.syscode=B.syscode and A.APCat =B.APCatID ";
            SQL += "WHERE a.syscode = '" + syscode + "' ";
            if (apcat != "") {
                SQL += " and apcat = '" + apcat + "' ";
	        }
            ReqVal["qryOrder"] = ReqVal.TryGet("SetOrder", ReqVal.TryGet("qryOrder"));
            if (ReqVal.TryGet("qryOrder") != "") {
                SQL += " order by " + ReqVal.TryGet("qryOrder");
            } else {
                SQL += " order by A.APCat,A.APOrder";
            }
            DataTable dt = new DataTable();
            cnn.DataTable(SQL, dt);

            //處理分頁
            int nowPage = Convert.ToInt32(Request["GoPage"] ?? "1"); //第幾頁
            int PerPageSize = Convert.ToInt32(Request["PerPage"] ?? "30"); //每頁筆數
            page = new Paging(nowPage, PerPageSize, string.Join(";", cnn.exeSQL.ToArray()));
            page.GetPagedTable(dt);

            //分頁完再處理其他資料才不會虛耗資源
            for (int i = 0; i < page.pagedTable.Rows.Count; i++) {
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

<body>
<table cellspacing="1" cellpadding="0" width="98%" border="0">
    <tr>
        <td class="text9" nowrap="nowrap">&nbsp;【<%=prgid%><%=Title%>】<span style="color:blue"><%=HTProgCap%></span>查詢結果清單</td>
        <td class="FormLink" valign="top" align="right" nowrap="nowrap">
            <a href="<%#HTProgPrefix%>_Edit.aspx?prgid=<%=prgid%>&SYScode=<%=syscode%>&Apcat=<%=apcat%>&submittask=A" target="Eblank">[新增]</a>
            <a href="<%#prgid%>.aspx?prgid=<%=prgid%>&SYScode=<%=syscode%>">[查詢]</a>
           	<a class="imgRefresh" href="javascript:void(0);" >[重新整理]</a>
        </td>
    </tr>
    <tr>
        <td colspan="2"><hr class="style-one"/></td>
    </tr>
</table>
<form id="regSYS" name="regSYS" method="post">
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

<asp:Repeater id="dataRepeater" runat="server">
<HeaderTemplate>
    <table style="display:<%#page.totRow==0?"none":""%>" border="0" class="bluetable" cellspacing="1" cellpadding="2" width="98%" align="center" id="dataList">
	    <thead>
            <Tr>
		        <td align=center class=lightbluetable>網路作業系統代碼</td>
		        <td align=center class=lightbluetable>Menu分類代碼</td>
		        <td align=center class=lightbluetable>程式代碼</td>
		        <td align=center class=lightbluetable>程式英文名稱</td>
		        <td align=center class=lightbluetable>程式中文名稱</td>
		        <td align=center class=lightbluetable>Menu次序</td>
		        <td align=center class=lightbluetable>權限作業</td>
            </tr>
	    </thead>
	    <tbody>
</HeaderTemplate>
			<ItemTemplate>
 		        <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>">
		            <TD align=center><a href="AP_Edit.aspx?prgid=<%#prgid%>&Syscode=<%#Eval("syscode")%>&Apcat=<%#Eval("Apcat")%>&APcode=<%#Eval("APcode")%>&ff=<%=Request["ff"]%>&submittask=U" target=Eblank><%#Eval("SYScode")%></A></TD>
		            <TD align=center><a href="AP_Edit.aspx?prgid=<%#prgid%>&Syscode=<%#Eval("syscode")%>&Apcat=<%#Eval("Apcat")%>&APcode=<%#Eval("APcode")%>&ff=<%=Request["ff"]%>&submittask=U" target=Eblank><%#Eval("APCat")%>_<%#Eval("APCatCname")%></A></TD>
		            <TD align=center><a href="AP_Edit.aspx?prgid=<%#prgid%>&Syscode=<%#Eval("syscode")%>&Apcat=<%#Eval("Apcat")%>&APcode=<%#Eval("APcode")%>&ff=<%=Request["ff"]%>&submittask=U" target=Eblank><%#Eval("APcode")%></A></TD>
		            <TD align=center><%#Eval("APnameE")%></TD>
		            <TD align=center><%#Eval("APnameC")%></TD>
		            <TD align=center><%#Eval("APorder")%></TD>
		            <TD align=center>
                        <a href="EditRegSys.aspx?prgid=<%#prgid%>&submittask=A&Syscode=<%#Eval("syscode")%>&apcode=<%#Eval("apcode")%>&n1=<%#Eval("APCatCname")%>&n2=<%#Eval("APnameC")%>" target=Eblank>[設定]</a>
		            </TD>
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

    //執行查詢
    function goSearch() {
        $("#regSYS").submit();
    };
</script>
