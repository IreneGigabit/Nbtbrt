<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Collections.Generic"%>

<script runat="server">
    protected string HTProgCap = "進度查詢及銷案設定";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "brta21";//HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string Title = "";

    protected string SQL = "";

    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected Paging page = null;

    protected string qtype = "";

    DBHelper conn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    private void Page_Unload(System.Object sender, System.EventArgs e) {
        if (conn != null) conn.Dispose();
    }

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        qtype = Request["qtype"] ?? "";
        
        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");
        conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");

        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        Title = myToken.Title;

        if (HTProgRight >= 0) {
            QueryData();
            this.DataBind();
        }
    }

    private void QueryData() {
        if (qtype == "N") {
            SQL = "select a.cs_rs_no,b.rs_no,b.sqlno,a.seq,a.seq1,b.step_grade,a.cg,a.rs,a.step_date,a.rs_detail,b.ctrl_type,b.ctrl_date, '' as resp_date, '' as resp_grade, b.ctrl_remark";
            SQL += ",''rownum,''lcgrs,''cs_flag,''nctrl_type,'N'nctrl_type_mark,''ldisabled ";
            SQL += "  from step_dmt a inner join ctrl_dmt b on a.rs_no = b.rs_no ";
            SQL += " where a.branch = '" + Request["branch"] + "'";
            SQL += "   and a.seq = '" + Request["seq"] + "'";
            SQL += "   and a.seq1 = '" + Request["seq1"] + "'";
            SQL += " order by  a.seq,a.seq1,a.step_grade,b.ctrl_date";
        } else if (qtype == "A") {
            SQL = "select cs_rs_no,a.rs_no,1 as sqlno,a.seq,a.seq1,a.step_grade,cg,rs,a.step_date,rs_detail,b.ctrl_type, b.ctrl_date,b.resp_date,b.resp_grade,b. ctrl_remark";
            SQL += ",''rownum,''lcgrs,''cs_flag,''nctrl_type,'N'nctrl_type_mark,''ldisabled ";
            SQL += "  from step_dmt a inner join resp_dmt b on a.seq = b.seq and a.seq1 = b.seq1 and a.step_grade = b.step_grade ";
            SQL += " where a.branch = '" + Request["branch"] + "'";
            SQL += "   and a.seq = '" + Request["seq"] + "'";
            SQL += "   and a.seq1 = '" + Request["seq1"] + "'";
            SQL += "   and a.step_grade not in (select distinct step_grade from ctrl_dmt where seq = '" + Request["seq"] + "' and seq1 = '" + Request["seq1"] + "'";
            SQL += "   and step_grade not in (select distinct step_grade from resp_dmt where seq = '" + Request["seq"] + "' and seq1 = '" + Request["seq1"] + "'))";
            SQL += " union ";
            SQL += "select a.cs_rs_no,b.rs_no,b.sqlno,a.seq,a.seq1,b.step_grade,a.cg,a.rs,a.step_date,a.rs_detail,b.ctrl_type,b.ctrl_date, '' as resp_date, '' as resp_grade, b.ctrl_remark";
            SQL += ",''rownum,''lcgrs,''cs_flag,''nctrl_type,'N'nctrl_type_mark,''ldisabled ";
            SQL += "  from step_dmt a inner join ctrl_dmt b on a.rs_no = b.rs_no ";
            SQL += " where a.branch = '" + Request["branch"] + "'";
            SQL += "   and a.seq = '" + Request["seq"] + "'";
            SQL += "   and a.seq1 = '" + Request["seq1"] + "'";
            SQL += " order by  a.seq,a.seq1,a.step_grade,b.ctrl_date";
        } else if (qtype == "R") {
            SQL = "select a.cs_rs_no,b.rs_no,b.sqlno,a.seq,a.seq1,b.step_grade,a.cg,a.rs,a.step_date,a.rs_detail,b.ctrl_type,b.ctrl_date, b.resp_date, b.resp_grade, b.ctrl_remark";
            SQL += ",''rownum,''lcgrs,''cs_flag,''nctrl_type,'N'nctrl_type_mark,''ldisabled ";
            SQL += "  from step_dmt a inner join resp_dmt b on a.rs_no = b.rs_no ";
            SQL += " where a.branch = '" + Request["branch"] + "'";
            SQL += "   and a.seq = '" + Request["seq"] + "'";
            SQL += "   and a.seq1 = '" + Request["seq1"] + "'";
            SQL += "   and b.resp_grade = '" + Request["step_grade"] + "'";
            SQL += " order by a.seq,a.seq1,b.step_grade,b.ctrl_date";
        }

        DataTable dt = new DataTable();
        conn.DataTable(SQL, dt);

        //處理分頁
        int nowPage = Convert.ToInt32(Request["GoPage"] ?? "1"); //第幾頁
        int PerPageSize = Convert.ToInt32(Request["PerPage"] ?? "10"); //每頁筆數
        page = new Paging(nowPage, PerPageSize, SQL);
        page.GetPagedTable(dt);

        string lrs_no="";
        //分頁完再處理其他資料才不會虛耗資源
        for (int i = 0; i < page.pagedTable.Rows.Count; i++) {
            DataRow dr = page.pagedTable.Rows[i];
            
            //計算row_num,group by rs_no
            if( lrs_no != dr.SafeRead("rs_no","")){
                dr["rownum"] = "*";
                lrs_no = dr.SafeRead("rs_no", "");
            }

            //取得管制種類說明,2016/2/18修改，remark=C表該期限種類不能由期限管制維護或進度維護銷管，權限C才能維護，如B9契約書後補期限，需由契約書後補作業銷管	
            SQL = "select cust_code,code_name,remark from cust_code ";
            SQL += " where code_type = 'CT' and cust_code = '" + dr["ctrl_type"] + "'";
            using (SqlDataReader dr1 = conn.ExecuteReader(SQL)) {
                if (dr1.Read()) {
                    dr["nctrl_type"] = dr1.SafeRead("code_name", "").Left(2);
                    dr["nctrl_type_mark"] = dr1.SafeRead("remark", "").Trim();
                    if (dr.SafeRead("nctrl_type_mark", "") == "") dr["nctrl_type_mark"] = "N";
                }
            }

            //收發種類
            if (dr.SafeRead("cg", "") == "C") {
                dr["lcgrs"] = "客";
            } else if (dr.SafeRead("cg", "") == "G") {
                dr["lcgrs"] = "官";
            } else {
                dr["lcgrs"] = "本";
            }
            if (dr.SafeRead("rs", "") == "R") {
                dr["lcgrs"] = dr["lcgrs"]+"收";
            } else {
                dr["lcgrs"] = dr["lcgrs"]+"發";
            }

            //客戶報導
            if (dr.SafeRead("cs_rs_no", "") != "") {
                dr["cs_flag"] = "Y";
            } else {
                dr["cs_flag"] = "N";
            }

            //不可銷本身進度的管制 & 之後進度的管制
            if (Convert.ToInt32(dr["step_grade"]) >= Convert.ToInt32(Request["step_grade"])) {
                dr["ldisabled"] = "disabled";
            } else {
                dr["ldisabled"] = "";
                //若管制種類的remark=C(記錄於cust_code.code_type=CT and cust_code=code_type and remark=C)，則不能由此作業銷管，權限C除外,2017/4/18修改同期限管制維護，remark=B也不能銷管		
                if (dr.SafeRead("nctrl_type_mark", "") == "C" || dr.SafeRead("nctrl_type_mark", "") == "B") {
                    if ((HTProgRight & 256) == 0) {
                        dr["ldisabled"] = "disabled";
                    }
                }
            }
            if (Request["submitTask"] == "D" || Request["submitTask"] == "Q") {
                dr["ldisabled"] = "disabled";
            }
        }

        dataRepeater.DataSource = page.pagedTable;
        dataRepeater.DataBind();
    }
</script>
<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta http-equiv="x-ua-compatible" content="IE=10">
<title><%=HTProgCap%></title>
<link rel="stylesheet" type="text/css" href="<%=Page.ResolveUrl("~/inc/setstyle.css")%>" />
<link rel="stylesheet" type="text/css" href="<%=Page.ResolveUrl("~/js/lib/jquery.datepick.css")%>" />
<link rel="stylesheet" type="text/css" href="<%=Page.ResolveUrl("~/js/lib/toastr.css")%>" />
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/jquery-1.12.4.min.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/jquery.datepick.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/jquery.datepick-zh-TW.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/toastr.min.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/util.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/jquery.irene.form.js")%>"></script>
</head>

<body>
<table cellspacing="1" cellpadding="0" width="98%" border="0">
    <tr>
        <td class="text9" nowrap="nowrap">&nbsp;【<%=prgid%><%=Title%>】<span style="color:blue"><%=HTProgCap%></span></td>
        <td class="FormLink" valign="top" align="right" nowrap="nowrap">
            <a class="imgCls" href="javascript:void(0);" >[關閉視窗]</a>
        </td>
    </tr>
    <tr>
        <td colspan="2"><hr class="style-one"/></td>
    </tr>
</table>
<form id="regPage" name="regPage" method="post" action="brta21disEdit.aspx">
    <input type="hidden" id=row name=row value="<%#page.pagedTable.Rows.Count%>"> 
    <div id="divPaging" style="display:<%#page.totRow==0?"none":""%>">
    <table border="0" width="100%" cellspacing="1" cellpadding="0" align="center">  
		<tr>
			<td width="100%" colspan="6" class="FormRtext">
				<input type="hidden" name="prgid" id="prgid" value="<%=prgid%>">
				<input type="hidden" name="rtnCol" id="rtnCol" value="<%=Request["rtnCol"]%>">
				<input type="hidden" name="branch" id="branch" value="<%=Request["branch"]%>">
				<input type="hidden" name="seq" id="seq" value="<%=Request["seq"]%>">
				<input type="hidden" name="seq1" id="seq1" value="<%=Request["seq1"]%>">
				<input type="hidden" name="qtype" id="qtype" value="<%=Request["qtype"]%>">
				<input type="hidden" name="step_grade" id="step_grade" value="<%=Request["step_grade"]%>">
				<input type="hidden" name="submitTask" id="submitTask" value="<%=Request["submitTask"]%>">
				<input type="hidden" name="rsqlno" id="rsqlno" value="<%=Request["rsqlno"]%>">
				<label><input type="radio" name="Rqtype" value="R">本進度銷管</label>
				<label><input type="radio" name="Rqtype" value="N">尚未銷管</label>
				<label><input type="radio" name="Rqtype" value="A">全部進度</label>
			</td>
		</tr>
    </TABLE>

    <TABLE border=0 cellspacing=1 cellpadding=0 width="98%" align="center">
        <tr>
            <td><%if(qtype=="N"){%>
                <a href="javascript:void(0);" onclick="selectall()" style="color:darkblue" onmouseover="this.style.color='red'" onmouseout="this.style.color='darkblue'">全選</a>
                <%}%>
            </td>
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
                </font>
            </td>
        </tr>
    </TABLE>
    </div>
</form>

    <div align="center" id="noData" style="display:<%#page.totRow==0?"":"none"%>">
	    <font color="red">=== 查無進度資料 ===</font>
    </div>

    <asp:Repeater id="dataRepeater" runat="server">
    <HeaderTemplate>
        <table style="display:<%#page.totRow==0?"none":""%>" border="0" class="bluetable" cellspacing="1" cellpadding="2" width="98%" align="center" id="dataList">
	        <thead>
	            <tr align="center" class="lightbluetable">
		            <td nowrap class="td_dis">銷管</td>
		            <td nowrap>進度<br>序號</td>
		            <td nowrap>收發<br>種類</td>
		            <td nowrap>進度日期</td>
		            <td>進度內容</td>
		            <td nowrap>客戶<br>報導</td>
		            <td nowrap>管制期限</td>
		            <td nowrap>銷管日期</td>
		            <td nowrap>銷管<br>進度</td>
		            <td>管制說明</td>
	            </tr>
	        </thead>
	        <tbody>
    </HeaderTemplate>
		<ItemTemplate>
            <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>" align="center">
		        <td class="td_dis">
			        <input type="hidden" name="rsqlno_<%#(Container.ItemIndex+1)%>" id="rsqlno_<%#(Container.ItemIndex+1)%>" value=<%#Eval("sqlno")%>>
			        <input type="checkbox" name="respChk_<%#(Container.ItemIndex+1)%>" id="respChk_<%#(Container.ItemIndex+1)%>" vsqlno="<%#Eval("sqlno")%>" value="Y" <%#Eval("ldisabled")%>>
		        </td>		
		        <td><%#(Eval("rownum").ToString()=="*"?Eval("step_grade"):"")%></td>
		        <td><%#(Eval("rownum").ToString()=="*"?Eval("lcgrs"):"")%></td>
		        <td><%#(Eval("rownum").ToString()=="*"?Eval("step_date","{0:yyyy/M/d}"):"")%></td>
		        <td><%#(Eval("rownum").ToString()=="*"?Eval("rs_detail"):"")%></td>
		        <td><%#(Eval("rownum").ToString()=="*"?Eval("cs_flag"):"")%></td>
		        <td align="left"><%#Eval("nctrl_type")%>&nbsp;<%#Eval("ctrl_date","{0:yyyy/M/d}")%></td>
		        <td><%#(Eval("resp_date","{0:yyyy/M/d}")!="1900/1/1"?Eval("resp_date","{0:yyyy/M/d}"):"")%></td>
		        <td><%#(Eval("resp_grade").ToString()!="0"?Eval("resp_grade"):"")%></td>
		        <td><%#Eval("ctrl_remark")%></td>
		    </tr>
		</ItemTemplate>
    <FooterTemplate>
	        </tbody>
        </table>
    <br>
    <table width="100%" cellspacing="1" cellpadding="0" border="0">
	    <tr align="center">
		    <td>
			    <input type=button class="cbutton" name="btnseq" id="btnseq" value="確定" onclick="formupdate()">
			    <input type=button class="cbutton" name="btnreset" id="btnreset" value="重填" onclick="formreset()">
		    </td>
	    </tr>
    </table>
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
        theadOdr();//設定表頭排序圖示
        this_init();
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
            if (window.parent.$('.ui-dialog-content:visible').length > 0) {
                window.parent.$('.ui-dialog-content:visible').dialog('destroy').empty();
            } else {
                window.close();
            }
        }
    })

    /////////////////////////////////////////////
    $("input[name='Rqtype']").click(function (e) {
        if ($(this).val() == "N") {//尚未銷管
            $("#rsqlno").val(getChkValue());
        }

        $("#qtype").val($(this).val());
        goSearch();
    })

    function this_init() {
        if (window.parent.tt !== undefined) {
            window.parent.tt.rows = "100%,0%";
        }

        $("input[name='Rqtype'][value='" + $("#qtype").val() + "']").prop("checked", true);

        if ($("#submitTask").val() == "A") {
            $("input[name='Rqtype'][value='R']").prop("disabled", true);
        }
        if ($("#qtype").val() == "N") {//尚未銷管
            $("#btnreset").prop("disabled", false);
            $("#btnseq").prop("disabled", false);
            $(".td_dis").show();
        } else if ($("#qtype").val() == "A") {//全部進度
            $("#btnreset").prop("disabled", true);
            $("#btnseq").prop("disabled", true);
            $(".td_dis").hide();
        } else if ($("#qtype").val() == "R") {//本進度銷管
            $("#btnreset").prop("disabled", true);
            $("#btnseq").prop("disabled", true);
            $(".td_dis").hide();
        }

        //顯示已暫存的資料
        var arr_asqlno = $("#rsqlno").val().split(";");
        $.each(arr_asqlno, function (index, value) {
            $("input:checkbox[id^='respChk_'][vsqlno='" + arr_asqlno[index] + "']").prop("checked", true);
        });
    }

    //全選
    function selectall() {
        $("input:checkbox[id^='respChk_']").each(function (idx) {
            var pno = (idx + 1);
            if ($(this).prop("disabled")==false) {
                $(this).prop("checked", true);
            }
        });
    }

    //串接資料
    function getChkValue() {
        var rtn = $("input[id^='respChk_']").map(function () {
            return $(this).prop("checked") ? $(this).attr("vsqlno")+";" : "";
        }).get().join('');

        return rtn;
    }

    //[重填]
    function formreset() {
        reg.reset();
        this_init();
    }

    //[確定]
    function formupdate() {
        var pObject = opener;
        if (pObject === undefined) {
            pObject = parent;
        }

        var lstr = getChkValue();
        if ($("#rtnCol").val() != "") {
            $("#" + $("#rtnCol").val(), pObject.document).val(lstr);
        } else {
            $("#rsqlno", pObject.document).val(lstr);
        }

        $(".imgCls").click();
    }
</script>
