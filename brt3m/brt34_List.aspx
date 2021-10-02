<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Linq"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<script runat="server">
    protected string HTProgCap = "國內案爭救交辦抽件簽核作業";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string HTProgPrefix = HttpContext.Current.Request["prgid"] ?? "";//程式檔名前綴
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";

    protected string SQL = "";
    
    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected Paging page = null;

    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";

    protected string FormName = "";
    protected string apcode = "";
    protected string qs_dept = "";
    
    DBHelper conn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    DBHelper connopt = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    private void Page_Unload(System.Object sender, System.EventArgs e) {
        if (conn != null) conn.Dispose();
        if (connopt != null) connopt.Dispose();
    }

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
        connopt = new DBHelper(Conn.optK).Debug(Request["chkTest"] == "TEST");
        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");

        qs_dept=(Request["qs_dept"]??"").ToLower();
        
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
        StrFormBtnTop += "<a class=\"imgRefresh\" href=\"javascript:void(0);\" >[重新整理]</a>";
        StrFormBtnTop += "<a href=" + HTProgPrefix + ".aspx?qs_dept=" + qs_dept + "&prgid=" + prgid + ">[回查詢]</a>";
    }
    
    private void QueryData() {
        DataTable dt = new DataTable();
		    SQL = "SELECT  a.opt_sqlno,a.Case_no,a.Branch,a.seq,a.seq1,RTRIM(ISNULL(b.ap_cname1, '')) + RTRIM(ISNULL(b.ap_cname2, '')) AS cust_name ";
		    SQL+=",a.appl_name,a.class,a.arcase_name,a.service,a.fees,a.oth_money,a.Bmark,a.pr_scode_name,a.opt_in_date,a.ctrl_date,a.gs_date,a.Bstat_code ";
		    SQL+=",a.cust_seq,a.cust_area,a.arcase_type,a.Bseq,a.Bseq1,C.sqlno as cancel_sqlno,C.input_scode,c.Creason ";
		    SQL+=",(select code_name from cust_code as c where code_type='Ostat_code' and a.Bstat_code=c.cust_code) as dowhat_name ";
            SQL += ",''fseq,''in_no,''in_scode,''urlasp ";
		    SQL+="FROM vbr_opt a ";
		    SQL+="inner join cancel_opt as c on a.opt_sqlno=c.opt_sqlno and c.tran_status='DT' ";
		    SQL+="inner join "+Sys.tdbname(Sys.GetSession("seBranch"))+".apcust as b on a.cust_area=b.cust_area and a.cust_seq=b.cust_seq ";
            SQL += "where 1=1 ";

            if (ReqVal.TryGet("job_scode") != "") {
                SQL += " AND (c.cap_scode = '" + Request["job_scode"] + "')";
            } else {
                SQL += " AND (c.cap_scode = '" + Session["scode"] + "')";
            }

            if (ReqVal.TryGet("scode") != "*" && ReqVal.TryGet("scode") != "") {
                SQL += " and A.in_scode = '" + Request["scode"] + "'";
            }

            if (ReqVal.TryGet("Sinput_date") != "") {
                SQL += " AND (c.input_date >= '" + Request["Sinput_date"] + "')";
            } 

            if (ReqVal.TryGet("Einput_date") != "") {
                SQL += " AND (c.input_date <= '" + Request["Einput_date"] + "')";
            } 

            ReqVal["qryOrder"] = ReqVal.TryGet("SetOrder", ReqVal.TryGet("qryOrder"));
            if (ReqVal.TryGet("qryOrder") != "") {
                SQL += " order by " + ReqVal.TryGet("qryOrder");
            }
            //Sys.showLog(SQL);
            connopt.DataTable(SQL, dt);

            //處理分頁
            int nowPage = Convert.ToInt32(Request["GoPage"] ?? "1"); //第幾頁
            int PerPageSize = Convert.ToInt32(Request["PerPage"] ?? "10"); //每頁筆數
            page = new Paging(nowPage, PerPageSize, SQL);
            page.GetPagedTable(dt);

            //分頁完再處理其他資料才不會虛耗資源
            for (int i = 0; i < page.pagedTable.Rows.Count; i++) {
                DataRow dr = page.pagedTable.Rows[i];

                //案號
                dr["fseq"] = Sys.formatSeq1(dr.SafeRead("seq", ""), dr.SafeRead("seq1", ""), "", Sys.GetSession("seBranch"), Sys.GetSession("dept"));

                SQL = "Select in_scode,in_no,arcase_class,arcase ";
                SQL += ",(SELECT rs_class FROM code_br WHERE rs_code = a.arcase AND dept = 'T' AND cr = 'Y' AND no_code='N' and rs_type=a.arcase_type) AS Ar_form ";
                SQL += "from case_dmt as a where case_no='" + dr["Case_no"] + "'";
                using (SqlDataReader dr0 = conn.ExecuteReader(SQL)) {
                    if (dr0.Read()) {
                        dr["in_no"] = dr0.SafeRead("in_no", "");
                        dr["in_scode"] = dr0.SafeRead("in_scode", "");
                    }
                }

                //連結
                dr["urlasp"] = GetLink(dr);

                //目前狀態
                if (dr.SafeRead("dowhat_name", "") == "") {
                    dr["dowhat_name"] = "未收件";
                }
            }

            dataRepeater.DataSource = page.pagedTable;
            dataRepeater.DataBind();
    }

    protected string GetLink(DataRow row) {
        string urlasp = "";//連結的url

        urlasp = Sys.getCaseDmt11Aspx(prgid, row.SafeRead("in_no",""), row.SafeRead("in_scode",""), "Show");
        urlasp+= "&opt_sqlno=" + row.SafeRead("opt_sqlno","");
        urlasp += "&homelist=" + Request["homelist"];
        urlasp+= "&ctrl_date=" + row.GetDateTimeString("ctrl_date", "yyyy/M/d");

        return urlasp;
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
    <input type=hidden id=row name=row value="<%#page.pagedTable.Rows.Count%>"> 
    <input type=hidden id=prgid name=prgid value="<%=prgid%>"> 
    <input type=hidden id=submittask name=submittask value=""> 

    <table style="display:<%#page.totRow==0?"none":""%>" border="0" class="bluetable" cellspacing="1" cellpadding="2" width="100%" align="center" id="dataList">
	    <thead>
            <tr>  
	            <td align="center" class="lightbluetable" Onclick="checkall()" style="cursor:pointer">全選</td>
	            <td align="center" class="lightbluetable">交辦單號</td>
	            <td align="center" class="lightbluetable">案件編號</td>
	            <td align="center" class="lightbluetable">案件名稱</td>
	            <td align="center" class="lightbluetable">案性</td>
	            <td align="center" class="lightbluetable">承辦人員</td>
	            <td align="center" class="lightbluetable">交辦日期</td>
	            <td align="center" class="lightbluetable">預計完成日</td>
	            <td align="center" class="lightbluetable">目前狀態</td>
            </tr>
	    </thead>
	    <tbody>
</HeaderTemplate>
			<ItemTemplate>
	            <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>">
	                <td class="whitetablebg" align="center" rowSpan=2>
                        <input type=checkbox id="C_<%#(Container.ItemIndex+1)%>" name="C_<%#(Container.ItemIndex+1)%>" value="Y">
	                    <input type="hidden" id="opt_sqlno_<%#(Container.ItemIndex+1)%>" name="opt_sqlno_<%#(Container.ItemIndex+1)%>">
	                    <input type="hidden" id="Case_no_<%#(Container.ItemIndex+1)%>" name="Case_no_<%#(Container.ItemIndex+1)%>">
	                    <input type="hidden" id="input_scode_<%#(Container.ItemIndex+1)%>" name="input_scode_<%#(Container.ItemIndex+1)%>">
	                    <input type="hidden" id="sqlno_<%#(Container.ItemIndex+1)%>" name="sqlno_<%#(Container.ItemIndex+1)%>" value="<%#Eval("opt_sqlno")%>">
	                    <input type="hidden" id="Pcase_no_<%#(Container.ItemIndex+1)%>" name="Pcase_no_<%#(Container.ItemIndex+1)%>" value="<%#Eval("case_no")%>">
	                    <input type="hidden" id="Pinput_scode_<%#(Container.ItemIndex+1)%>" name="Pinput_scode_<%#(Container.ItemIndex+1)%>" value="<%#Eval("input_scode")%>">
	                    <input type="hidden" id="Pin_scode_<%#(Container.ItemIndex+1)%>" name="Pin_scode_<%#(Container.ItemIndex+1)%>" value="<%#Eval("in_scode")%>">
	                    <input type="hidden" id="cancel_sqlno_<%#(Container.ItemIndex+1)%>" name="cancel_sqlno_<%#(Container.ItemIndex+1)%>" value="<%#Eval("cancel_sqlno")%>">
	                    <input type="hidden" id="Branch_<%#(Container.ItemIndex+1)%>" name="Branch_<%#(Container.ItemIndex+1)%>" value="<%#Eval("branch")%>">
	                </td>
	                <td class="whitetablebg" align="center"><a href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("in_scode")%>-<%#Eval("case_no")%></A></td>
	                <td class="whitetablebg" align="center"><a href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("fseq")%></A></td>
	                <td class="whitetablebg" align="center"><a href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("appl_name").ToString().CutData(20)%></A></td>
	                <td class="whitetablebg" align="center"><a href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("arcase_name")%></A></td>
	                <td class="whitetablebg" align="center"><a href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("pr_scode_name")%></A></td>
	                <td class="whitetablebg" align="center"><a href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("opt_in_date")%></A></td>
	                <td class="whitetablebg" align="center"><a href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("ctrl_date","{0:yyyy/M/d}")%></A></td>
	                <td class="whitetablebg" align="center"><a href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("dowhat_name")%></A></td>
                </tr>
                <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>">
	                <td align="right" class="whitetablebg">抽件原因：</td>
	                <td class="whitetablebg" colspan=7 align="left"><%#Eval("Creason")%>
                </tr>
			</ItemTemplate>
<FooterTemplate>
	    </tbody>
    </table>
	<BR>
    <table style="display:<%#page.totRow==0?"none":""%>" border="0" width="100%" cellspacing="0" cellpadding="0">
		<tr class="FormName"><td><div align="left"><%#FormName%></div></td>
        </tr>
	</table>
	<br>

    <table style="display:<%#page.totRow==0?"none":""%>" border="0" width="90%" cellspacing="0" cellpadding="0" align="center">
		<TR>			
			<TD align=right>簽核狀態:</TD>
			<TD align=left>
				<label><input type=radio name="signid" value="YY" checked>簽准</label>
				<label><input type=radio name="signid" value="XX">不准退回</label>
			</TD>
		</TR>
		<TR>
			<TD align=right>簽核說明:</TD>
			<TD align=left><TEXTAREA name=signdetail id=signdetail ROWS=2 COLS=50></TEXTAREA></TD>
		</TR>
    </table>

    <table style="display:<%#page.totRow==0?"none":""%>" border="0" width="100%" cellspacing="0" cellpadding="0">
     <tr><td width="100%">     
       <p align="center">        
            <input type=button value ="送出" class="cbutton bsubmit" onClick="formupdate()" id=btnsend name=btnsend>
            <input type=button value ="取消" class="cbutton" onClick="resetForm()" id=button4 name=button4>
     </td></tr>
    </table> 
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
    ///////////////////////////////////////////////////////////////
    //全選
    function checkall(){
        for (var j = 1; j <= CInt($("#row").val()) ; j++) {
            //沒有勾的觸發勾選
            if($("#C_"+j).prop("checked")==false){
                $("#C_"+j).click();
            }
        }
    }
    
    function formupdate(){
        if ($("input[name^='C_']:checked").length==0){
            alert("尚未選定!!");
        } else {
            for (var j = 1; j <= CInt($("#row").val()) ; j++) {
                if ($("#C_" + j).prop("checked") == true) {
                    $("#opt_sqlno_" + j).val($("#sqlno_" + j).val());
                    $("#Case_no_" + j).val($("#Pcase_no_" + j).val());
                    $("#input_scode_" + j).val($("#Pinput_scode_" + j).val());
                } else {
                    $("#opt_sqlno_" + j).val("");
                    $("#Case_no_" + j).val("");
                    $("#input_scode_" + j).val("");
                }
            }

            if ($("input[name='signid']:checked").length == 0) {
                alert("請點選簽核狀態!!");
                $("input[name='signid']:eq(0)").focus();
                return false;
            }

            if ($("input[name='signid']:checked").val() == "YY") {
                $("#submittask").val("U");
            } else if ($("input[name='signid']:checked").val() == "XX") {
                if (chkscode()) return false;
                if ($("#signdetail").val() == "") {
                    alert("簽核說明不可空白!!");
                    $("#signdetail").focus();
                    return false;
                }
                $("#submittask").val("B");
            }

            $(".bsubmit").lock(!$("#chkTest").prop("checked"));
            var form = $('#reg');
            var formData = new FormData(form[0]);
            $.ajax({
                url: '<%=HTProgPrefix%>_Update.aspx',
                type: "POST",
                data : formData,
                contentType: false,
                cache: false,
                processData: false,
                beforeSend:function(xhr){
                    $("#dialog").html("<div align='center'><h1>存檔中...</h1></div>");
                    $("#dialog").dialog({ title: '存檔訊息', modal: true,maxHeight: 500,width: 800,buttons:[] });
                },
                complete: function (xhr, status) {
                    $("#dialog").html(xhr.responseText);
                    $("#dialog").dialog({
                        title: '存檔訊息',modal: true,maxHeight: 500,width: 800,closeOnEscape: false
                        ,buttons: {
                            確定: function() {
                                $(this).dialog("close");
                            }
                        }
                        ,close:function(event, ui){
                            if(status=="success"){
                                goSearch();//重新整理
                            }
                        }
                    });
                }
            });
        }
    }

    //檢查不准退回營洽需為同一人
    function chkscode() {
        var rtn = false;

        var objKey = {};
        for (var r = 1; r <= CInt($("#row").val()) ; r++) {
            if ($("#C_" + r).prop("checked") == true) {
                var rKey = $("#Pin_scode_" + r).val();//要比對的key值
                if (rKey != "" && objKey[rKey]) {
                    rtn = true;
                    break;
                } else {
                    objKey[rKey] = { flag: true, idx: r };
                }
            }
        }

        if (rtn == true) {
            alert("不准退回，營洽需為同一人！！");
        }

        return rtn;
    }
</script>