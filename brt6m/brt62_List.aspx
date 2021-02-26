<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>

<script runat="server">
    protected string HTProgCap = "國內案文件上傳作業";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "brt62";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";

    protected string SQL = "";
    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected Paging page = null;

    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";

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

        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        HTProgCap = myToken.Title;
        DebugStr = myToken.DebugStr;
        if (HTProgRight >= 0) {
            PageLayout();
            QueryData();
            this.DataBind();
        }
    }

    private void PageLayout() {
        if(ReqVal.TryGet("frameblank")=="Y"){
            StrFormBtnTop += "<a class=\"imgCls\" href=\"javascript:void(0);\" >[關閉視窗]</a>";
        }
        
        if(prgid!="brta33"){
            StrFormBtnTop += "<a class=\"imgRefresh\" href=\"javascript:void(0);\" >[重新整理]</a>";
            StrFormBtnTop += "<a href=\"" + HTProgPrefix + ".aspx?prgid=" + prgid + "\" >[查詢]</a>";
            
            if ((HTProgRight & 4) > 0) {
                StrFormBtnTop += "<a href=\"" + HTProgPrefix + "_Edit.aspx?prgid=" + prgid + "&submittask=A&seq="+Request["qrySeq"]+"&seq1="+Request["qrySeq1"]+"\" target=\"Eblank\" >[新增附件]</a>";
            }
        }
    }
    
    private void QueryData() {
        string orderby = "";
        ReqVal["qryOrder"] = ReqVal.TryGet("SetOrder", ReqVal.TryGet("qryOrder"));
        if (ReqVal.TryGet("qryOrder") != "") {
            orderby += " order by " + ReqVal.TryGet("qryOrder");
        }
        
        if (prgid == "brta33") {//從官發回條確認查詢進來
            SQL = "Select ROW_NUMBER() OVER (" + orderby + ") AS RowNumber ";
            SQL += ",a.battach_sqlno as attach_sqlno,a.seq,a.seq1,null as step_grade,a.source,a.in_date,a.attach_desc,a.attach_path,a.source_name,a.source_name attach_name,b.cust_area ";
            SQL += " ,(Select sc_name from sysctrl.dbo.scode as s where a.in_scode=s.scode) as in_scodenm";
            SQL += " ,(Select code_name from cust_code as c where c.code_type='tdoc' and c.cust_code=a.doc_type) as doc_typenm";
            SQL += " ,(Select code_name from cust_code as d where d.code_type='tatt_source' and d.cust_code=a.source) as sourcenm";
            SQL += " ,''fseq,''button ";
            SQL += " from bdmt_attach_temp as a ";
        } else {
            SQL += "Select ROW_NUMBER() OVER (" + orderby + ") AS RowNumber ";
            SQL += ",a.*,b.cust_area ";
            SQL += " ,(Select sc_name from sysctrl.dbo.scode as s where a.in_scode=s.scode) as in_scodenm";
            SQL += " ,(Select code_name from cust_code as c where c.code_type='tdoc' and c.cust_code=a.doc_type) as doc_typenm";
            SQL += " ,(Select code_name from cust_code as d where d.code_type='tatt_source' and d.cust_code=a.source) as sourcenm";
            SQL += " ,''fseq,''button ";
            SQL += " From dmt_attach as a ";
        }
        SQL += " inner join dmt as b on a.seq=b.seq and a.seq1=b.seq1";
        SQL += " Where 1=1 ";

        if (prgid == "brta33") {
            SQL += " and attach_flag<>'D' and into_status='NN' and source='OPT' ";
        } else {
            SQL += " and (attach_flag<>'D' or chk_status like 'Y%') ";
        }
        if (ReqVal.TryGet("qryseq") != "") {
            SQL += "AND a.Seq ='" + Request["qryseq"] + "' ";
        }
        if (ReqVal.TryGet("qrySeq1") != "") {
            SQL += "AND a.Seq1 ='" + Request["qrySeq1"] + "' ";
        }
        if (ReqVal.TryGet("qryDoc_type") != "") {
            SQL += "AND a.Doc_type ='" + Request["qryDoc_type"] + "' ";
        }
        if (ReqVal.TryGet("qrydateS") != "") {
            SQL += "AND a.in_date>='" + Request["qrydateS"] + "' ";
        }
        if (ReqVal.TryGet("qrydateE") != "") {
            SQL += "AND a.in_date<='" + Request["qrydateE"] + "' ";
        }
        if (ReqVal.TryGet("qryattach_desc") != "") {
            SQL += "AND a.attach_desc like '%" + Request["qryattach_desc"] + "%' ";
        }
        if (ReqVal.TryGet("rs_no") != "") {
            SQL += "AND a.rs_no='" + Request["rs_no"] + "' ";
        }
        
        //處理分頁
        int nowPage = Convert.ToInt32(Request["GoPage"] ?? "1"); //第幾頁
        int PerPageSize = Convert.ToInt32(Request["PerPage"] ?? "10"); //每頁筆數
        page = new Paging(nowPage, PerPageSize, SQL);
        page.GetPagedTable(conn, SQL);

        //分頁完再處理其他資料才不會虛耗資源
        for (int i = 0; i < page.pagedTable.Rows.Count; i++) {
            DataRow dr = page.pagedTable.Rows[i];
            dr["fseq"] = Sys.formatSeq(dr.SafeRead("seq", ""), dr.SafeRead("seq1", ""), "", Sys.GetSession("seBranch"), Sys.GetSession("dept"));
            if (dr.SafeRead("attach_desc", "") == "") {
                dr["attach_desc"] = dr.SafeRead("doc_typenm", "");
            }

            dr["button"] = GetButton(dr, i + 1);
        }

        dataRepeater.DataSource = page.pagedTable;
        dataRepeater.DataBind();
    }
    
    //[作業]
    protected string GetButton(DataRow row,int nRow) {
        string rtn="";
        string prvPath="",href_update="",href_del="";
        
        string seq=row.SafeRead("seq", "");
        string seq1=row.SafeRead("seq1", "");
        string step_grade=row.SafeRead("step_grade", "");
        string source=row.SafeRead("source", "");
        string attach_path = row.SafeRead("attach_path", "");
        string attach_sqlno=row.SafeRead("attach_sqlno", "");
        
        //檢視
		if (source=="OPT"){
            //\opt\opt_file\attach/2009/000087/NT57596附件.pdf
            prvPath="http://"+Sys.Opt_IIS+Sys.Path2Nopt(attach_path);
        }else{
            ///btbrt/IPOGR/TTGR/N/20140609/103008678_10390502830_1/103008678_正本_1_10390502830.pdf
			if (source=="EGR" ||source=="EGS"){
				//先檢查本機檔案
				if (Sys.CheckFile(Sys.Path2Nbtbrt(attach_path)) ==false){
					prvPath="http://"+Sys.MG_IIS+ Regex.Replace(attach_path, "/btbrt", "/MG", RegexOptions.IgnoreCase);
            }else{
                    prvPath="http://"+Sys.Host+Sys.Path2Nbtbrt(attach_path);
            }
            }else{
                prvPath="http://"+Sys.Host+Sys.Path2Nbtbrt(attach_path);
            }
        }
		
		//修改
        href_update = HTProgPrefix + "_Edit.aspx?prgid=" + prgid + "&attach_sqlno=" + attach_sqlno + "&seq=" + seq + "&seq1=" + seq1 + "&step_grade=" + step_grade + "&source=" + source + "&submittask=U";
		//刪除
        href_del = HTProgPrefix + "_Edit.aspx?prgid=" + prgid + "&attach_sqlno=" + attach_sqlno + "&seq=" + seq + "&seq1=" + seq1 + "&step_grade=" + step_grade + "&source=" + source + "&submittask=D";

        if ((HTProgRight & 2) > 0) {
            rtn += "<a href=\"javascript:void(0)\" class=\"preview\" v1=\"" + prvPath.GetUrlStr() + "\" id=\"preview" + nRow + "\" title=\"" + prvPath + "\">[檢視]</a>\n";
        }
		if (source!="OPT" && source!="EGS"){//爭救案系統上傳/電子收據不能維護
            if (((HTProgRight & 8) > 0&&source!="scan")||((HTProgRight & 256) > 0&&source=="EGR")) {
                rtn+="<br><a href=\""+href_update+"\" target=\"Eblank\">[修改]</a>";
            }
            if (((HTProgRight & 16) > 0&&source!="scan")||((HTProgRight & 256) > 0&&source=="EGR")) {
                rtn+="<br><a href=\""+href_del+"\" target=\"Eblank\">[刪除]</a>";
            }
		}

        return rtn;
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title><%#HTProgCap%></title>
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
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/client_chk.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/jquery.Snoopy.date.js")%>"></script>
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

<div align="center" id="noData" style="display:<%#page.totRow==0?"":"none"%>">
	<font color="red">=== 目前無資料 ===</font>
</div>

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

<form style="margin:0;" id="reg" name="reg" method="post">
    <asp:Repeater id="dataRepeater" runat="server">
    <HeaderTemplate>
        <table style="display:<%#page.totRow==0?"none":""%>" border="0" class="bluetable" cellspacing="1" cellpadding="2" width="98%" align="center" id="dataList">
	        <thead>
                <Tr>
	                <td class="lightbluetable" align="center" nowrap>案件編號</td>
	                <td class="lightbluetable" align="center" nowrap>進度序號</td>
	                <td class="lightbluetable" align="center" nowrap>上傳人員</td>
	                <td class="lightbluetable" align="center" nowrap>上傳日期</td>
	                <td class="lightbluetable" align="center" nowrap>附件說明</td> 
	                <td class="lightbluetable" align="center" nowrap>檔案名稱</td> 
	                <td class="lightbluetable" align="center" nowrap>作業</td>
                </tr>
	        </thead>
	        <tbody>
    </HeaderTemplate>
			    <ItemTemplate>
 		            <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>">
                        <td class="whitetablebg" align="center"><%#Eval("fseq")%></td>
                        <td class="whitetablebg" align="center"><%#Eval("step_grade")%></td>
                        <td class="whitetablebg" align="center"><%#Eval("in_scodenm")%></td>
                        <td class="whitetablebg" align="center"><%#Eval("in_date","{0:yyyy/M/d}")%></td>
                        <td class="whitetablebg"><%#Eval("attach_desc")%></td>
                        <td class="whitetablebg" title="檔案名稱:<%#Eval("attach_path")%>"><%#Eval("source_name")%></td>
                        <td class="whitetablebg" align="center">
                            <%#Eval("button")%>
		                    <input type="hidden" name="attach_path_<%#(Container.ItemIndex+1)%>" value="<%#Eval("attach_path")%>">
		                    <input type="hidden" name="source_<%#(Container.ItemIndex+1)%>" value="<%#Eval("source")%>">
                        </td>
				    </tr>
			    </ItemTemplate>
    <FooterTemplate>
	        </tbody>
        </table>
	    <BR>
        <table style="display:<%#page.totRow==0?"none":""%>" border="0" width="100%" cellspacing="0" cellpadding="0">
		    <tr class="FormName"><td>
			    <div align="left">
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
            if ("<%=Request["frameblank"]%>" == "Y") {
                window.parent.tt.rows = "50%,50%";
            } else {
                window.parent.tt.rows = "100%,0%";
            }
        }

        $("input[name='signid']:checked").triggerHandler("click");
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
    //////////////////////

	//[檢視]
	$(".preview").on("click",function(){
	    var url=$(this).attr("v1");
	    window.open(url,"brt62window","width=700,height=480,toolbar=yes,menubar=yes,resizable=yes,scrollbars=yes,status=0,top=50,left=80");
	})
</script>