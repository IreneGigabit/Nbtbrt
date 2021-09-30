<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<script runat="server">
    protected string HTProgCap = "國內案客戶函寄發登錄作業";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = HttpContext.Current.Request["prgid"] ?? "";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";

    protected string SQL = "";
    protected object objResult = null;
    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected Paging page = null;

    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";
    protected string FormName = "";

    protected string html_send_way = "";

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
        HTProgCap = myToken.Title.Replace("客戶函", "<font color=blue>客戶函</font>");
        DebugStr = myToken.DebugStr;
        if (HTProgRight >= 0) {
            PageLayout();
            QueryData();
            this.DataBind();
        }
    }

    private void PageLayout() {
        StrFormBtnTop += "<a class=\"imgRefresh\" href=\"javascript:void(0);\" >[重新整理]</a>";

        //發文方式
        html_send_way = Sys.getCustCode("SEND_WAY", "", "sortfld").Option("{cust_code}", "{code_name}");
        
        if ((HTProgRight & 4) > 0 || (HTProgRight & 8) > 0) {
            StrFormBtn += "<br>\n";
            StrFormBtn += "客戶函寄出日期：<input type=text name='mail_date' id='mail_date' size='10' class='dateField'><br><br>\n";
            StrFormBtn += "<input type=button value='寄發確認' class='cbutton bsubmit' onClick='formAddSubmit()'>\n";
            StrFormBtn += "<input type=button value='重　填' class='cbutton' onClick='this_init()'>\n";
        }
    }

    private void QueryData() {
		SQL = "select a.rs_no,a.branch,a.seq,a.seq1,a.step_date,a.send_way,a.rs_detail,a.last_date";
		SQL+= ",a.cappl_name,a.ap_cname1,a.scode,a.sc_name ";
		SQL+= ",b.pmail_date,(select code_name from cust_code where code_type='send_way' and cust_code=a.send_way) as send_waynm ";
        SQL += ",''fseq ";
		SQL+= " from vcs_dmt_1 a ";
		SQL+= " inner join step_dmt as b on a.rs_no=b.cs_rs_no ";
        SQL += " where a.print_date is not null and a.mail_date is null ";
        if ((Request["qryStep_dateS"] ?? "") != "") SQL += " and a.Step_Date>='" + Request["qryStep_dateS"] + "'";
        if ((Request["qryStep_dateE"] ?? "") != "") SQL += " and a.Step_Date<='" + Request["qryStep_dateE"] + "'";
        if ((Request["qrypmail_dateS"] ?? "") != "") SQL += " and b.pmail_Date>='" + Request["qrypmail_dateS"] + "'";
        if ((Request["qrypmail_dateE"] ?? "") != "") SQL += " and b.pmail_Date<='" + Request["qrypmail_dateE"] + "'";
        if ((Request["qrySeq"] ?? "") != "") SQL += " and a.Seq in ('" + Request["qrySeq"].Replace(",", "','") + "')";
        if ((Request["qrySeq1"] ?? "") != "") SQL += " and a.Seq1='" + Request["qrySeq1"] + "'";
        if ((Request["qrycust_seq"] ?? "") != "") SQL += " and a.cust_seq='" + Request["qrycust_seq"] + "'";
        if ((Request["qrysend_way"] ?? "") != "") SQL += " and a.send_way='" + Request["qrysend_way"] + "'";
            
        ReqVal["qryOrder"] = ReqVal.TryGet("SetOrder", ReqVal.TryGet("qryOrder", "a.step_date,a.seq,a.seq1"));
        if (ReqVal.TryGet("qryOrder") != "") {
            SQL += " order by " + ReqVal.TryGet("qryOrder");
        }

        DataTable dt = new DataTable();
        conn.DataTable(SQL, dt);

        //處理分頁
        int nowPage = Convert.ToInt32(Request["GoPage"] ?? "1"); //第幾頁
        int PerPageSize = Convert.ToInt32(Request["PerPage"] ?? "20"); //每頁筆數
        page = new Paging(nowPage, PerPageSize, SQL);
        page.GetPagedTable(dt);

        //分頁完再處理其他資料才不會虛耗資源
        for (int i = 0; i < page.pagedTable.Rows.Count; i++) {
            DataRow dr = page.pagedTable.Rows[i];

            //案號
            dr["fseq"] = Sys.formatSeq(dr.SafeRead("seq", ""), dr.SafeRead("seq1", ""), "", Sys.GetSession("seBranch"), Sys.GetSession("dept"));
        }

        batchRepeater.DataSource = page.pagedTable;
        batchRepeater.DataBind();
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title><%#HTProgCap%></title>
    <uc1:head_inc_form runat="server" ID="head_inc_form" />
</head>
<script language="javascript" type="text/javascript">
    var main = {};
    main.branch = "<%#Session["SeBranch"]%>";
    main.prgid = "<%#prgid%>";
    main.right = <%#HTProgRight%>;
</script>

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
    <table border="0" cellspacing="1" cellpadding="2" width="100%">
        <tr>
	        <td class="text9">
		        ◎預定寄發日期:<input type="text" name="qrypmail_DateS" id="qrypmail_DateS" size="10" class="dateField">
                ~
                <input type="text" name="qrypmail_DateE" id="qrypmail_DateE" size="10" class="dateField">
	        </td>
	        <td class="text9">
		        ◎進度日期:<input type="text" name="qrystep_DateS" id="qrystep_DateS" size="10" class="dateField">
                ~
                <input type="text" name="qrystep_DateE" id="qrystep_DateE" size="10" class="dateField">
	        </td>
	        <td class="text9">
		        ◎發文方式:<SELECT name="qrysend_way" id="qrysend_way"><%#html_send_way%></select>
	        </td>
	    </tr>
        <tr>
		    <td class="text9">
		        ◎本所編號:<input type="text" name="qrySeq" id="qrySeq" size="30">-<input type="text" name="qrySeq1" id="qrySeq1" size="2">
	        </td>
	        <td class="text9">
		        ◎客戶編號:<input type="text" name="qrycust_Seq" id="qrycust_Seq" size="5">
	        </td>
	        <td class="text9">
		        <input type="button" value="查詢" class="cbutton" onClick="goSearch()" id=qrybutton name=qrybutton>
		        <input type="hidden" name="prgid" id="prgid" value="<%=prgid%>">
	        </td>
        </tr>
    </table>

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
    <INPUT type="hidden" name="qrydowhat" id="qrydowhat">
	<input type="hidden" name="prgid" value="<%=prgid%>">
    <input type="hidden" id=row name=row value="<%#page.pagedTable.Rows.Count%>"> 

    <INPUT type="hidden" name="rows_chk" id="rows_chk">
	<INPUT type="hidden" name="rows_rs_no" id="rows_rs_no">
	<INPUT type="hidden" name="rows_seq" id="rows_seq">
	<INPUT type="hidden" name="rows_seq1" id="rows_seq1">

    <asp:Repeater id="batchRepeater" runat="server">
    <HeaderTemplate>
        <table style="display:<%#page.totRow==0?"none":""%>" border="0" class="bluetable" cellspacing="1" cellpadding="2" width="100%" align="center" id="dataList">
	        <thead>
                <Tr>
	                <td  class="lightbluetable" nowrap align="center">
		                <a href="javascript:void(0);" onclick="selectall()" style="color:darkblue" onmouseover="this.style.color='red'" onmouseout="this.style.color='darkblue'">全選</a>
	                </td>
	                <td  class="lightbluetable" nowrap align="center"><u class="setOdr" v1="a.seq,a.seq1">本所編號</u></td>
	                <td  class="lightbluetable" nowrap align="center">案件名稱</td>
	                <td  class="lightbluetable" nowrap align="center"><u class="setOdr" v1="a.scode">營洽</u></td>
	                <td  class="lightbluetable" nowrap align="center"><u class="setOdr" v1="a.step_date,a.seq,a.seq1">進度日期</u></td>
	                <td  class="lightbluetable" nowrap align="center"><u class="setOdr" v1="b.pmail_Date">預定寄發日</u></td>
	                <td  class="lightbluetable" nowrap align="center">客戶函主旨</td>
	                <td  class="lightbluetable" nowrap align="center"><u class="setOdr" v1="a.last_date">法定期限</u></td>
	                <td  class="lightbluetable" nowrap align="center">發文方式</td> 
	                <td  class="lightbluetable" nowrap align="center"><u class="setOdr" v1="a.ap_cname1">客戶</u></td>
                </tr>
	        </thead>
	        <tbody>
    </HeaderTemplate>
	<ItemTemplate>
 	    <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>">
		    <td nowrap align="center">
			    <input type=checkbox id=chk_<%#(Container.ItemIndex+1)%> onclick="chk_flag_onclick('<%#(Container.ItemIndex+1)%>')" value='Y'>
		        <input type="hidden" id="rs_no_<%#(Container.ItemIndex+1)%>" value="<%#Eval("rs_no")%>">
		        <input type="hidden" id="seq_<%#(Container.ItemIndex+1)%>" value="<%#Eval("seq")%>">
		        <input type="hidden" id="seq1_<%#(Container.ItemIndex+1)%>" value="<%#Eval("seq1")%>">
		    </td>
		    <td align="center" >
			    <font style="cursor: pointer;" onmouseover="this.style.color='red'" onmouseout="this.style.color='black'" onclick="CapplClick('<%#Eval("seq")%>','<%#Eval("seq1")%>')" title="案件主檔查詢"><%#Eval("fseq")%></font>
                <img src="<%=Page.ResolveUrl("~/images/annex.gif")%>" style="cursor:pointer" align="absmiddle" title="案件進度查詢" onclick="QstepClick('<%#Eval("seq")%>','<%#Eval("seq1")%>')">
			</td>
		    <td ><%#Eval("cappl_name").ToString().ToUnicode().Left(20)%></td>
		    <td nowrap align="center"><%#Eval("sc_name")%></td>
		    <td align="center"><%#Eval("step_date","{0:yyyy/M/d}")%></td>
		    <td align="center"><%#Eval("pmail_date","{0:yyyy/M/d}")%></td>
		    <td align="left"><%#Eval("rs_detail")%></td>
		    <td align="center"><%#Eval("last_date","{0:yyyy/M/d}")%></td>
		    <td align="center"><%#Eval("send_waynm")%></td>
		    <td align="left"><%#Eval("ap_cname1").ToString().ToUnicode().Left(10)%></td>
	    </tr>
	</ItemTemplate>
    <FooterTemplate>
	        </tbody>
        </table>
	    <BR>
	    <div align="center" style="display:<%#page.totRow==0?"none":""%>">
            <%#StrFormBtn%>
        </div>
	    <BR>
        <table style="display:<%#page.totRow==0?"none":""%>" border="0" width="100%" cellspacing="0" cellpadding="0">
		    <tr class="FormName"><td><div align="left" style="color:blue"><%#FormName%></div></td>
            </tr>
	    </table>
	    <br>
    </FooterTemplate>
    </asp:Repeater>

    <%#DebugStr%>
</form>

<div id="dialog"></div>

<iframe id="ActFrame" name="ActFrame" src="about:blank" width="100%" height="300" style="display:none"></iframe>
</body>
</html>

<script language="javascript" type="text/javascript">
    $(function () {
        if (window.parent.tt !== undefined) {
            window.parent.tt.rows = "100%,0%";
        }

        this_init();
    });

    function this_init() {
        $("#mail_date").val(Today().format("yyyy/M/d"));

        $(".Lock").lock();
        $("input.dateField").datepick();
    }

    //執行查詢
    function goSearch() {
        $("#regPage").submit();
    };
    //////////////////////

    $("#qrypmail_DateS,#qrypmail_DateE").blur(function (e) {
        ChkDate(this);
    });
    $("#qrystep_DateS,#qrystep_DateE").blur(function (e) {
        ChkDate(this);
    });
    $("#mail_date").blur(function (e) {
        ChkDate(this);
    });
    //案件主檔查詢
    function CapplClick(pseq,pseq1){
        window.showModalDialog(getRootPath() + "/brt5m/brt15ShowFP.aspx?prgid=<%=prgid%>&seq=" + pseq + "&seq1=" + pseq1 + "&submittask=Q", "", "dialogHeight: 540px; dialogWidth: 800px; center: Yes;resizable: No; status: No;scrollbars:yes");
    }
    //案件進度查詢
    function QstepClick(pseq,pseq1) {
        window.open(getRootPath() + "/brtam/brta61_Edit.aspx?submitTask=Q&qtype=A&prgid=<%=prgid%>&closewin=Y&winact=1&aseq=" + pseq + "&aseq1=" + pseq1, "myWindowOneN", "width=900 height=700 top=40 left=80 toolbar=no, menubar=no, location=no, directories=no resizeable=no status=no scrollbars=yes");
    }
    //全選
    function selectall(){
        for (var j = 1; j <= CInt($("#row").val()) ; j++) {
            $("#chk_"+j).prop("checked",!$("#chk_"+j).prop("checked"));
            //chk_flag_onclick(j);
        }
    }
    //勾選某一筆
    function chk_flag_onclick(pchknum){
        if ($("#chk_"+pchknum).prop("checked")) {
            //$("#hchk_flag_"+pchknum).val( "Y");
        }else{
            //$("#hchk_flag_"+pchknum).val( "N");
        }
    }

    ///////////////////////////////////////
    //串接資料
    function setRowData(){
        $("#rows_chk").val(getJoinValue("#dataList>tbody input[id^='chk_']"));
        $("#rows_rs_no").val(getJoinValue("#dataList>tbody input[id^='rs_no_']"));
        $("#rows_seq").val(getJoinValue("#dataList>tbody input[id^='seq_']"));
        $("#rows_seq1").val(getJoinValue("#dataList>tbody input[id^='seq1_']"));
    }

    //確認
    function formAddSubmit(){
        //檢查是否有勾選
        var totnum=$("input[id^='chk_']:checked").length;
        if (totnum == 0){
            alert("請勾選您要確認的案件!!");
            return false;
        }
        if( chkNull("客戶函寄出日期",$('#mail_date')[0]) ) return false;

        if (!confirm("共有" + totnum + "筆確認 , 是否確定?")) return false;
        
        //串接資料
        setRowData();

        $("input:disabled, select:disabled").unlock();
        $(".bsubmit").lock(!$("#chkTest").prop("checked"));
        $("#qrydowhat").val($("input[name='qrydowhat']:checked").val());
        
        var formData = new FormData($('#reg')[0]);
        ajaxByForm("brta35_Update.aspx",formData)
        .complete(function( xhr, status ) {
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
                        if(!$("#chkTest").prop("checked")){
                            window.parent.tt.rows="100%,0%";
                            goSearch();//重新整理
                        }
                    }
                }
            });
        });
    }
</script>