<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Linq"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<script runat="server">
    protected string HTProgCap = "確認轉案主管簽核(轉入)";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string HTProgPrefix = "brt3h1";//程式檔名前綴
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

    protected string job_grpid = "";//原始簽核者的Grpid
    protected string job_grplevel = "";//原始簽核者的Grplevel

    protected string rdoYY = "";//簽准
    protected string rodYT = "";//轉上級簽核

    protected string txtSMaster = "", txtSMasternm = "", txtSMastercode = "", txt_agentNm = "無", txt_agentNo = "", selPrScode = "";

    protected string qs_dept = "", tblname = "", dept_nm = "";
    protected string todo_tblnm = "";

    DBHelper cnn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    DBHelper conn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    private void Page_Unload(System.Object sender, System.EventArgs e) {
        if (cnn != null) cnn.Dispose();
        if (conn != null) conn.Dispose();
    }

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        cnn = new DBHelper(Conn.Sysctrl).Debug(Request["chkTest"] == "TEST");
        conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");

        qs_dept = (Request["qs_dept"] ?? "").ToLower();
        Sys.getScodeGrpid(Sys.GetSession("seBranch"), Request["job_scode"], ref job_grpid, ref job_grplevel);
        //Sys.showLog(job_grplevel);

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
        StrFormBtnTop += "<a href=" + HTProgPrefix + ".aspx?prgid=" + prgid + "&qs_dept="+qs_dept+">[回查詢]</a>";

		FormName += "※流程:營洽轉案處理-->組主管簽核-->部門主管簽核-->區所主管簽核-->程序轉案發文確認--><font color=red>新單位主管確認轉案(部門主管指定營洽-->區所主管簽核)</font>-->新單位程序確認轉案-->程序轉案完成確認<br>\n";
        FormName += "※提醒:若不同意或需修改新營洽，則請重新點選新營洽名單，系統會於簽准後以重新指定營洽建檔。<br>\n";

        if (qs_dept == "t") {
            todo_tblnm = "todo_dmt";
            tblname = "dmt";
            dept_nm = "T";
        } else {
            todo_tblnm = "todo_ext";
            tblname = "ext";
            dept_nm = "TE";
        }

        DataTable MasterList = Sys.getMasterList(Sys.GetSession("seBranch"), Request["job_scode"], false);
        //MasterList.ShowTable();
        //Response.End();
        
        //轉上級人員
        if (job_grplevel == "") {//執委
            job_grplevel = "-1";
            txtSMaster = "";
            txtSMasternm = "";
            txtSMastercode = "";
        } else if (job_grplevel == "0") {//專商經理
            txtSMaster = "執委:";
            txtSMasternm = MasterList.Select("grplevel=-1")[0]["master_nm"].ToString();
            txtSMastercode = MasterList.Select("grplevel=-1")[0]["Master_scode"].ToString();
        } else if (job_grplevel == "1") {//區所主管
            txtSMaster = "專商經理:";
            txtSMasternm = MasterList.Select("grplevel=0")[0]["master_nm"].ToString();
            txtSMastercode = MasterList.Select("grplevel=0")[0]["Master_scode"].ToString();
        } else if (job_grplevel == "2") {//商標主管
            txtSMaster = "區所主管:" + MasterList.Select("grplevel=1")[0]["master_nm"];
            txtSMastercode = MasterList.Select("grplevel=1")[0]["Master_scode"].ToString();
        } else {//組主管
            txtSMaster = "商標主管:" + MasterList.Select("grplevel<" + job_grplevel, "up_level")[0]["master_nm"];
            txtSMastercode = MasterList.Select("grplevel<" + job_grplevel, "up_level")[0]["Master_scode"].ToString();
        }

        //程序人員
        DataTable dtPrScode = new DataTable();
        if (qs_dept == "t") {
            dtPrScode = Sys.GetGrpidScode(Sys.GetSession("seBranch"), "T210", "A");
        } else if (qs_dept == "e") {
            dtPrScode = Sys.GetGrpidScode(Sys.GetSession("seBranch"), "T220", "A");
        }
        selPrScode = dtPrScode.Option("{scode}", "{sc_name}", "", false, "", "grptype=F");

        if (Convert.ToInt32(job_grplevel) <= 1) {//區所主管以上預設簽准
            rdoYY = "checked";
            rodYT = "";
            if (Convert.ToInt32(job_grplevel) <= -1) {//執委不可再轉上級
                rodYT = "disabled";
            }
        } else {
            rdoYY = "disabled";
            rodYT = "checked";
        }
    }

    private void QueryData() {
        DataTable dt = new DataTable();
        if (qs_dept == "t") {
            SQL = " select  t.apcode,t.job_scode,t.sqlno as todo_sqlno,a.*,(select sc_name from sysctrl.dbo.scode where scode=a.tran_scode1) as transc_name ";
            SQL += ",(select branchname from sysctrl.dbo.branch_code where branch=a.branch) as branchname ";
            SQL += ",''fseq,''appl_name,''scode,''scode_name,''term1,''term2,''cust_name,''sign_level,''sign_levelnm ";
            SQL += " from todo_dmt t ";
            SQL += " inner join dmt_brtran a on  t.temp_rs_sqlno=a.brtran_sqlno ";
            SQL += " where t.job_status='NN' and t.syscode='" + Session["syscode"] + "' and t.dowhat='TRAN_EM' and t.apcode='brt3h' ";
        } else if (qs_dept == "e") {
            SQL = " select  t.apcode,t.job_scode,t.sqlno as todo_sqlno,a.*,(select sc_name from sysctrl.dbo.scode where scode=a.tran_scode) as transc_name ";
            SQL += ",(select branchname from sysctrl.dbo.branch_code where branch=a.branch) as branchname ";
            SQL += ",''fseq,''appl_name,''scode,''scode_name,''term1,''term2,''cust_name,''sign_level,''sign_levelnm ";
            SQL += " from todo_ext t ";
            SQL += " inner join ext_brtran a on  t.att_no=a.brtran_sqlno ";
            SQL += " where t.job_status='NN' and t.syscode='" + Session["syscode"] + "' and t.dowhat='TRAN_EM' and t.apcode='ext3h' ";
        }

        if (ReqVal.TryGet("job_scode") != "") {
            SQL += " AND (t.job_scode = '" + Request["job_scode"] + "')";
        } else {
            if (ReqVal.TryGet("homelist") == "homelist") {//從清單來沒傳job_scode則不用組條件
            } else {
                SQL += " AND (t.job_scode = '" + Session["scode"] + "')";
            }
        }

        if (ReqVal.TryGet("from_scode") != "*" && ReqVal.TryGet("from_scode") != "") {
            SQL += " and a.scode= '" + Request["from_scode"] + "'";
        }
        if (ReqVal.TryGet("sdate") != "") {
            SQL += " and t.in_date>= '" + Request["sdate"] + " 00:00:00'";
        }
        if (ReqVal.TryGet("edate") != "") {
            SQL += " and t.in_date<= '" + Request["edate"] + " 23:59:59'";
        }
        
        ReqVal["qryOrder"] = ReqVal.TryGet("SetOrder", ReqVal.TryGet("qryOrder", "t.in_date,a.seq,a.seq1"));
        if (ReqVal.TryGet("qryOrder") != "") {
            SQL += " order by " + ReqVal.TryGet("qryOrder");
        }
        Sys.showLog(SQL);
        conn.DataTable(SQL, dt);

        //處理分頁
        int nowPage = Convert.ToInt32(Request["GoPage"] ?? "1"); //第幾頁
        int PerPageSize = Convert.ToInt32(Request["PerPage"] ?? "30"); //每頁筆數
        page = new Paging(nowPage, PerPageSize, SQL);
        page.GetPagedTable(dt);

        //分頁完再處理其他資料才不會虛耗資源
        for (int i = 0; i < page.pagedTable.Rows.Count; i++) {
            DataRow dr = page.pagedTable.Rows[i];
            
            //案號
            if (dr.SafeRead("country", "") == "") {
                dr["fseq"] = Sys.formatSeq(dr.SafeRead("seq", ""), dr.SafeRead("seq1", ""), "", dr.SafeRead("branch", ""), Sys.GetSession("dept"));
            } else {
                dr["fseq"] = Sys.formatSeq(dr.SafeRead("seq", ""), dr.SafeRead("seq1", ""), dr.SafeRead("country", ""), dr.SafeRead("branch", ""), Sys.GetSession("dept") + "E");
            }

            SQL = "select a.appl_name,a.scode,a.term1,a.term2,a.step_grade,b.cust_name ";
            SQL += ",(SELECT sc_name FROM sysctrl.dbo.scode WHERE scode = a.scode) AS scode_name";
            SQL += " from " + tblname + " a ";
            SQL += " inner join view_cust b on a.cust_area=b.cust_area and a.cust_seq=b.cust_seq ";
            SQL += " where seq=" + dr["seq"] + " and seq1='" + dr["seq1"] + "'";
            using (DBHelper connbr = new DBHelper(Conn.brp(dr["branch"].ToString())).Debug(Request["chkTest"] == "TEST")) {
                using (SqlDataReader dr0 = connbr.ExecuteReader(SQL)) {
                    if (dr0.Read()) {
                        dr["appl_name"] = dr0.SafeRead("appl_name", "");
                        dr["scode"] = dr0.SafeRead("scode", "");
                        dr["term1"] = dr0.GetDateTimeString("term1", "yyyy/M/d");
                        dr["term2"] = dr0.GetDateTimeString("term2", "yyyy/M/d");
                        dr["cust_name"] = dr0.SafeRead("cust_name", "");
                        dr["scode_name"] = dr0.SafeRead("scode_name", "");
                    }
                }
            }

            //計算簽核層級
            string sign_level = "", sign_levelnm = "";
            DataTable MasterList = Sys.getMasterList(Sys.GetSession("seBranch"), dr.SafeRead("scode", ""), false);
            sign_level = "1";//區所主管
            sign_levelnm = "1";
            dr["sign_level"] = sign_level;
            dr["sign_levelnm"] = sign_levelnm;
        }

        dataRepeater.DataSource = page.pagedTable;
        dataRepeater.DataBind();
    }

    //新營洽
    protected string GetTranScode1(RepeaterItem Container) {
        string tran_scode1 = Eval("tran_scode1").ToString();
        
        SQL = "select distinct scode,sc_name,scode1 from vscode_roles ";
        SQL += " where branch='" + Session["SeBranch"] + "' and dept='" + Session["Dept"] + "' and syscode='" + Session["syscode"] + "' and roles='sales'";
        SQL += "and (end_date is null or end_date>'" + DateTime.Today.ToShortDateString() + "') ";
         SQL +="union all ";
         SQL += "select '" + Session["SeBranch"] + "t','部門(開放客戶)',9999 ";
         SQL += " order by scode1 ";
        DataTable dt = new DataTable();
        cnn.DataTable(SQL, dt);
        return dt.Option("{scode}", "{scode}_{sc_name}",true,tran_scode1);
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
				    <span id="PageUp" style="display:<%#page.nowPage>1?"":"none"%>">| <a href="javascript:void(0)" class="pgU" v1="<%#page.nowPage - 1%>">上一頁</a></span>
				    <span id="PageDown" style="display:<%#page.nowPage<page.totPage?"":"none"%>">| <a href="javascript:void(0)" class="pgD" v1="<%#page.nowPage + 1%>">下一頁</a></span>
				    | 每頁筆數:
				    <select id="PerPage" name="PerPage" style="color:#FF0000">
					    <option value="10" <%#page.perPage == 10 ? "selected" : ""%>>10</option>
					    <option value="20" <%#page.perPage == 20 ? "selected" : ""%>>20</option>
					    <option value="30" <%#page.perPage == 30 ? "selected" : ""%>>30</option>
					    <option value="50" <%#page.perPage == 50 ? "selected" : ""%>>50</option>
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
    <input type=hidden name=qs_dept id=qs_dept value=<%=qs_dept%>>
    <input type=hidden id="prgid" name="prgid" value="<%=prgid%>">
    <input type=hidden id="GrpID" name="GrpID" value="<%=job_grpid%>"><!--原始簽核者的Grpid-->
    <input type=hidden id="grplevel" name="grplevel" value="<%=job_grplevel%>"><!--原始簽核者的層級-->
    <input type=hidden id="sign_level" name="sign_level" value=""><!--簽准層級-->
    <input type=hidden id="contract_flag" name="contract_flag" value="N"><!--契約書後補contract_flag=Y需經區所+專商經理+執委主管簽准-->
    <input type=hidden id=row name=row value="<%#page.pagedTable.Rows.Count%>"> 

    <table style="display:<%#page.totRow==0?"none":""%>" border="0" class="bluetable" cellspacing="1" cellpadding="2" width="100%" align="center" id="dataList">
	    <thead>
            <Tr align="center" class="lightbluetable">
                <%if(ReqVal.TryGet("submittask")!="Q"){%>
                <td onclick="checkall()" style="cursor:pointer">全選</td>
                <%}%>
		        <td>原單位</td>
		        <td nowrap>原單位案件編號</td>
		        <td>原單位營洽</td>
		        <td>案件名稱</td>
		        <td>客戶名稱</td>
		        <td>專用期限</td>
		        <td>轉案通知日</td>
		        <td>轉案原因</td>
		        <td>新營洽</td>
            </Tr>
	    </thead>
	    <tbody>
</HeaderTemplate>
			<ItemTemplate>
 		        <tr class="<%#(Container.ItemIndex + 1) % 2 == 1 ? "sfont9" : "lightbluetable3"%>">
                    <%if(ReqVal.TryGet("submittask")!="Q"){%>
	                <td align="center">
                        <input type=checkbox id="C_<%#(Container.ItemIndex + 1)%>" name="C_<%#(Container.ItemIndex + 1)%>" value="Y" onclick="Chkupload('<%#(Container.ItemIndex + 1)%>','<%#Eval("sign_level")%>')">
		                <input type="hidden" id=hchkflag_<%#(Container.ItemIndex + 1)%> name=hchkflag_<%#(Container.ItemIndex + 1)%>>
		                <input type="hidden" id="todo_sqlno_<%#(Container.ItemIndex + 1)%>" name="todo_sqlno_<%#(Container.ItemIndex + 1)%>" value="<%#Eval("todo_sqlno")%>">
		                <input type="hidden" id="brtran_sqlno_<%#(Container.ItemIndex + 1)%>" name="brtran_sqlno_<%#(Container.ItemIndex + 1)%>" value="<%#Eval("brtran_sqlno")%>">
		                <input type="hidden" id=branch_<%#(Container.ItemIndex + 1)%> name=branch_<%#(Container.ItemIndex + 1)%> value="<%#Eval("branch")%>">
		                <input type="hidden" id=seq_<%#(Container.ItemIndex + 1)%> name=seq_<%#(Container.ItemIndex + 1)%> value="<%#Eval("seq")%>">
		                <input type="hidden" id=seq1_<%#(Container.ItemIndex + 1)%> name=seq1_<%#(Container.ItemIndex + 1)%> value="<%#Eval("seq1")%>">
		                <input type="hidden" id=otran_scode1_<%#(Container.ItemIndex + 1)%> name=otran_scode1_<%#(Container.ItemIndex + 1)%> value="<%#Eval("tran_scode1")%>">
	                </td>
                    <%}%>
	                <td align="center" nowrap >&nbsp;<%#Eval("branchname")%></td>
                    <td nowrap align='center' style="cursor: pointer;" onmouseover="this.style.color='red'" onmouseout="this.style.color='black'" onclick="CapplClick('<%#Eval("seq")%>', '<%#Eval("seq1")%>','<%#Eval("branch")%>','<%=dept_nm%>')">
                        <%#Eval("fseq")%>
                    </td>
	                <td align="center" nowrap><%#Eval("scode_name")%></td>
                    <td style="cursor:pointer" title="<%#Eval("appl_name")%>"><%#Eval("appl_name").ToString().CutData(20)%></td>
                    <td style="cursor:pointer" title="<%#Eval("cust_name")%>"><%#Eval("cust_name").ToString().CutData(20)%></td>
	                <td align="left"><%#(Eval("term1").ToString()!=""?Eval("term1","{0:d}")+"~":"")%><%#Eval("term2","{0:d}")%></td>
	                <td align="center"><%#Eval("dc_date")%></td>
	                <td align="left">&nbsp;<%#Eval("tran_remark")%></td>
	                <td align="center" nowrap >
	                    <select name="tran_scode1_<%#(Container.ItemIndex + 1)%>" id="tran_scode1_<%#(Container.ItemIndex + 1)%>" <%#(ReqVal.TryGet("job_scode")=="Q"?"disabled":"")%>>
	                        <%#GetTranScode1(Container)%>
	                    </select>
	                </td>
				</tr>
			</ItemTemplate>
<FooterTemplate>
	    </tbody>
    </table>
	<BR>
    <table style="display:<%#page.totRow==0?"none":""%>" border="0" width="60%" cellspacing="0" cellpadding="0" align="center">
		<TR>			
			<TD align=right>簽核狀態:</TD>
			<TD align=left>
				<label><input type=radio name="signid" value="YY" onclick=tosign() <%#rdoYY%>>簽准</label>
				<label><input type=radio name="signid" value="YT" onclick=tosign() <%#rodYT%>>轉上級簽核</label>
				<input type=hidden name=signidnext id=signidnext>
				<input type=hidden name=status id=status>
			</TD>
			<TD align=right>
				<span style="" id="showsign1"><!--程序人員-->
					程序人員：<select name="prscode" id="prscode"><%#selPrScode%></select>
				</span>
			</TD>
			<TD align=right>
				<span style="display:" id="showsign"><!--主管-->
					<span id="spanMaster"><input type=radio name="upsign" value="sMaster"><%#txtSMaster%><%#txtSMasternm%></span><input type=hidden value="<%=txtSMastercode%>" name="sMastercode" id="sMastercode">
                    <span id="spanAgent"><input type=radio name="upsign" value="sAgent">代理人:<%#txt_agentNm%><input type=hidden value="<%#txt_agentNo%>" name="sAgentcode" id="sAgentcode"><input type=hidden value="S" name=mark id=mark>	</span>
				</span>
			</TD>
		</TR>
		<TR>
			<TD align=right>簽核說明:</TD>
			<TD align=left colspan=3><TEXTAREA name=signdetail id=signdetail ROWS=2 COLS=50></TEXTAREA></TD>
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

<table style="display:<%#page.totRow==0?"none":""%>" border="0" width="100%" cellspacing="0" cellpadding="0">
	<tr class="FormName"><td><div align="left" style="color:blue"><%#FormName%></div></td>
    </tr>
</table>
</form>

<div id="dialog"></div>

</body>
</html>

<script language="javascript" type="text/javascript">
    $(function () {
        if (window.parent.tt !== undefined) {
            window.parent.tt.rows = "100%,0%";
        }

        $("input[name='signid']:checked").triggerHandler("click");
        $(".Lock").lock();
        $("input.dateField").datepick();
    });
    //執行查詢
    function goSearch() {
        $("#regPage").submit();
    };
    ///////////////////////////////////////////////////////////////
    //案件主檔
    function CapplClick(x1,x2,pbranch,pdept){
        if (pdept=="T"){
            url=getRootPath() + "/brt5m/brt15ShowFP.aspx?prgid=<%=prgid%>&seq=" + x1 + "&seq1=" + x2 + "&submittask=Q&type=brtran&branch=" + pbranch;
        }else{
            //***todo出口案
            url=getRootPath() + "/brt5m/ext54Edit.aspx?prgid=<%=prgid%>&seq=" + x1 + "&seq1=" + x2 + "&submittask=Q&type=brtran&branch=" + pbranch;
        }
        $('#dialog').html('<iframe style="border: 0px;" src="' + url + '" width="100%" height="100%"></iframe>')
       .dialog({autoOpen: true,modal: true,height: 540,width: 900,title: "案件主檔"});
    }

    //每筆交辦勾選時檢查簽核層級
    function Chkupload(tcount,sign_level) {
        if ($("#sign_level").val()=="") {
            $("#sign_level").val(sign_level);
        }

        if($("#C_"+tcount).prop("checked")==true){
            if($("#sign_level").val()!=sign_level){
                alert("送簽流程不相同無法同時送簽發信，請重新選取⑴！");
                $("#C_"+tcount).prop("checked",false);
                if ($("input[name^='C_']:checked").length == 0) $("#sign_level").val("");
                return false;
            }
        }

        if ($("input[name^='C_']:checked").length == 0) $("#sign_level").val("");
    }

    //全選
    function checkall(){
        for (var j = 1; j <= CInt($("#row").val()) ; j++) {
            //沒有勾的觸發勾選
            if($("#C_"+j).prop("checked")==false){
                $("#C_"+j).click();
            }
        }
    }

    function tosign(){
        if ($("input[name=signid]:checked").val() == "YY") {//簽准
            $("#showsign").hide();//主管
            $("#showsign1").show();//程序人員
        }else if ($("input[name=signid]:checked").val() == "YT") {//轉上級簽核
            $("#showsign1").hide();//程序人員
            $("#showsign").show();//主管
            $("input[name='upsign']:eq(0)").prop("checked", true);
        }
    }
    
    function formupdate(){
        var url="";
        var status=$("input[name=signid]:checked").val();
        if(status=="YY"){
            var sign_levl=CInt($("#sign_level").val());
            if(sign_levl>=0)
                sign_levl=CInt($("#sign_level").val().Left(1));
            else
                sign_levl=CInt($("#sign_level").val().Left(2));
            var sign_flag=CInt($("#grplevel").val())>sign_levl;//判斷簽准層級夠不夠,true:不夠

            if (sign_flag){
                alert("簽准層級不夠，請點選「轉上級簽核」並選擇簽核主管！");
                $("input[name='signid'][value='YT']").prop("checked", true).triggerHandler("click");
                return false;
            }
            $("#signidnext").val($("#prscode").val());//程序
            $("#mark").val("");//是否給代理人簽核
        }else if(status=="YT"){
            if($("input[name='upsign']:eq(0)").prop("checked")==true){
                $("#signidnext").val($("#sMastercode").val());//主管
                $("#mark").val("");//是否給代理人簽核
            }else{
                $("#signidnext").val($("#sAgentcode").val());//代理人
                $("#mark").val("S");//是否給代理人簽核
            }
        }

        if ($("#signidnext").val()==""){
            alert( "無下一流程處理人員，請檢查！");
            return false;
        }

        for (var pno = 1; pno <= CInt($("#row").val()) ; pno++) {
            if($("#C_"+pno).prop("checked")==true){
                if ($("#tran_scode1_"+pno).val()==""){
                    alert("請點選新營洽！");
                    return false;
                }
            }
        }

        $("#status").val(status);
        reg.action = "<%#HTProgPrefix%>_Update.aspx";

        var totnum=$("input[name^='C_']:checked").length;
        if (totnum==0){
            alert("尚未選定!!");
        }else{
            var tans = confirm("共有" + totnum + "筆需要轉案簽核 , 是否確定?");
            if (tans ==false) return false;

            $(".bsubmit").lock(!$("#chkTest").prop("checked"));
            var form = $('#reg');
            var formData = new FormData(form[0]);
            $.ajax({
                url:form.attr('action'),
                type : "POST",
                data : formData,//form.serialize(),
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
</script>