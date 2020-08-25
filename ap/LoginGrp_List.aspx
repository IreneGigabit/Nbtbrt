<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>

<script runat="server">
    protected string HTProgCap = "群組資料";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "LoginGrp";//HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = HttpContext.Current.Request["prgid"] ?? "";//程式代碼
    protected int HTProgRight = 0;
    protected string Title = "";

    protected string SQL = "";

    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected string hiddenText = "";
    protected Paging page = new Paging(1, 20);
    protected string syscode = "";
    protected string logingrp = "";

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        syscode = Request["Syscode"] ?? "";
        logingrp = Request["logingrp"] ?? "";
        
        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");
        foreach (KeyValuePair<string, string> p in ReqVal) {
            if (String.Compare(p.Key, "GoPage", true) != 0
                && String.Compare(p.Key, "PerPage", true) != 0
                && String.Compare(p.Key, "SetOrder", true) != 0)
                hiddenText += string.Format("<input type=\"hidden\" id=\"{0}\" name=\"{0}\" value=\"{1}\">\n", p.Key, p.Value);
        }

        Token myToken = new Token(HTProgCode);
        HTProgRight = myToken.CheckMe();
        Title = myToken.Title;
        if (HTProgRight >= 0) {
            QueryData();
            
            this.DataBind();
        }
    }

    private void QueryData() {
        using (DBHelper cnn = new DBHelper(Conn.ODBCDSN, false).Debug(Request["chkTest"] == "TEST")) {
            SQL = "SELECT * ";
            SQL += "FROM logingrp A ";
            SQL += "WHERE a.syscode = '" + syscode + "' ";
            if (logingrp != "") {
                SQL += " and LoginGrp = '" + logingrp + "' ";
	        }
            ReqVal["qryOrder"] = ReqVal.TryGet("SetOrder", ReqVal.TryGet("qryOrder", ""));
            if (ReqVal.TryGet("qryOrder", "") != "") {
                SQL += " order by " + ReqVal.TryGet("qryOrder", "");
            } else {
                SQL += " order by A.LoginGrp";
            }
            DataTable dt = new DataTable();
            cnn.DataTable(SQL, dt);

            //處理分頁
            int nowPage = Convert.ToInt32(Request["GoPage"] ?? "1"); //第幾頁
            int PerPageSize = Convert.ToInt32(Request["PerPage"] ?? "20"); //每頁筆數
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
<table cellspacing="1" cellpadding="0" width="98%" border="0">
    <tr>
        <td class="text9" nowrap="nowrap">&nbsp;【<%=prgid%><%=Title%>】<span style="color:blue"><%=HTProgCap%></span>查詢結果清單</td>
        <td class="FormLink" valign="top" align="right" nowrap="nowrap">
            <a href="<%#HTProgPrefix%>_Edit.aspx?prgid=<%=prgid%>&SYScode=<%=syscode%>&LoginGrp=<%=logingrp%>&submittask=A" target="Eblank">[新增群組]</a>
            <a href="<%#prgid%>.aspx?prgid=<%=prgid%>&SYScode=<%=syscode%>">[查詢]</a>
            <a class="imgRefresh" href="javascript:void(0);" >[重新整理]</a>
        </td>
    </tr>
    <tr>
        <td colspan="2"><hr class="style-one"/></td>
    </tr>
</table>
<form id="reg" name="reg" method="post">
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

<div align="center" id="noData" style="display:<%#page.totRow==0?"":"none"%>">
	<font color="red">=== 目前無資料 ===</font>
</div>

<asp:Repeater id="dataRepeater" runat="server">
<HeaderTemplate>
    <table style="display:<%#page.totRow==0?"none":""%>" border="0" class="bluetable" cellspacing="1" cellpadding="2" width="98%" align="center" id="dataList">
	    <thead>
            <Tr>
	            <td align=center class=lightbluetable>群組代碼</td>
	            <td align=center class=lightbluetable>群組名稱</td>
	            <td align=center class=lightbluetable>備註說明</td>
	            <td align=center class=lightbluetable>作業</td>	
            </tr>
	    </thead>
	    <tbody>
</HeaderTemplate>
			<ItemTemplate>
 		        <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>">
                    <TD class=whitetablebg><p align=center><%#Eval("LoginGrp")%></TD>	
                    <TD class=whitetablebg><p align=center><%#Eval("GrpName")%></TD>
                    <TD class=whitetablebg><p align=center><%#Eval("Remark")%></TD>
                    <TD class=whitetablebg><p align=center>
                        <a href="LoginGrp_Edit.aspx?prgid=<%#prgid%>&Syscode=<%#Eval("Syscode")%>&LoginGrp=<%#Eval("LoginGrp")%>&submitTask=U" target="Eblank">[編修群組]</a>
                        <a href="EditLoginGrpAP.aspx?prgid=<%#prgid%>&Syscode=<%#Eval("Syscode")%>&GrpID=<%#Eval("LoginGrp")%>&GrpName=<%#Eval("GrpName")%>" target="Eblank">[編修權限]</a>
                        <a href="sys14_List.aspx?prgid=<%#prgid%>&Syscode=<%#Eval("Syscode")%>&LoginGrp=<%#Eval("LoginGrp")%>">[查詢使用者]</a>
                        <a href="LoginGrp_Copy.aspx?prgid=<%#prgid%>&Syscode=<%#Eval("Syscode")%>&LoginGrp=<%#Eval("LoginGrp")%>" target="Eblank">[權限複製]</a>
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
        theadOdr();//設定表頭排序圖示
    });

    //執行查詢
    function goSearch() {
        $("#reg").submit();
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
    //重新整理
    $(".imgRefresh").click(function (e) {
        goSearch();
    });

    //關閉視窗
    $(".imgCls").click(function (e) {
        if (window.parent.tt !== undefined) {
            window.parent.tt.rows = "100%,0%";
        } else {
            window.close();
        }
    })
</script>
