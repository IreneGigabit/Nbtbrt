<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<script runat="server">
    protected string HTProgCap = "確認轉案作業(轉入部門主管指定營洽新營洽)";//HttpContext.Current.Request["prgname"];//功能名稱
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

    protected string qs_dept = "", tblname = "", dept_nm = "";
    protected string html_tran_scode1 = "", html_qbranch = "";

    protected string se_grpid = "000", mSC_code = "", mSC_name = "", html_selectsign = "";

    DBHelper conn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    DBHelper cnn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    private void Page_Unload(System.Object sender, System.EventArgs e) {
        if (conn != null) conn.Dispose();
        if (cnn != null) cnn.Dispose();
    }

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");

        conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
        cnn = new DBHelper(Conn.Sysctrl).Debug(Request["chkTest"] == "TEST");
       
        qs_dept = (Request["qs_dept"] ?? "").ToLower();
        if (qs_dept == "t") {
            tblname = "dmt";
            dept_nm = "T";
        } else {
            tblname = "ext";
            dept_nm = "TE";
        }

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
        if ((HTProgRight & 4) > 0 || (HTProgRight & 8) > 0 || (HTProgRight & 64) > 0) {
            StrFormBtn += "<input type=button value ='確認轉案暨送主管簽核' class='cbutton bsubmit' onclick='formSubmit()'>\n";
            StrFormBtn += "<input type=button value ='重　填' class='cbutton' onclick='this_init()'>\n";
        }

        //原單位區所別
        SQL = "select distinct a.branch,(select branchname from sysctrl.dbo.branch_code where branch=a.branch) as branchname ";
        SQL += ",(select sort from sysctrl.dbo.branch_code where branch=a.branch) as sort from dmt_brtran a ";
        SQL += "where a.tran_flag='B' and tran_seq is null  order by sort ";
        html_qbranch = Util.Option(conn, SQL, "{branch}", "{branchname}", true, ReqVal.TryGet("qbranch"));

        //新營洽清單
        SQL = "select distinct scode,sc_name,scode1 from vscode_roles ";
        SQL += " where branch='" + Session["SeBranch"] + "' and dept='" + Session["Dept"] + "' and syscode='" + Session["syscode"] + "' and roles='sales'";
        SQL += "and (end_date is null or end_date>'"+DateTime.Today.ToShortDateString()+"') ";
        SQL += " order by scode1 ";
        DataTable dt = new DataTable();
        cnn.DataTable(SQL, dt);
        html_tran_scode1 = dt.Option("{scode}", "{scode}_{sc_name}");
        html_tran_scode1 += "<option value='" + Sys.GetSession("seBranch") + "t'>" + Sys.GetSession("seBranch") + "t_部門(開放客戶)</option>";

        //抓區所主管
        Sys.getGrpidMaster(Sys.GetSession("SeBranch"), se_grpid, ref mSC_code, ref mSC_name);
        SQL = "select sc_name from scode where scode='" + mSC_code + "'";
        //特殊簽核(專商經理)
        DataRow[] drx = Sys.getGrpidUp(Sys.GetSession("SeBranch"), "000").Select("grplevel=0");
        html_selectsign = drx.Option("{master_scode}", "{master_type}---{master_nm}", false);
    }

    private void QueryData() {
        string wsql = "";
        if (ReqVal.TryGet("qseq") != "") {
            wsql += " and a.seq in (" + ReqVal["qseq"]+") ";
        }
        if (ReqVal.TryGet("qseq1") != "") {
            wsql += " and a.seq1 ='" + ReqVal["qseq1"]+"' ";
        }
        if (ReqVal.TryGet("sdate") != "") {
            wsql += " and a.dc_date >='" + ReqVal["sdate"]+" 00:00:00' ";
        }
        if (ReqVal.TryGet("edate") != "") {
            wsql += " and a.dc_date <='" + ReqVal["edate"]+" 23:59:59' ";
        }
        if (ReqVal.TryGet("qbranch") != "") {
            wsql += " and a.branch ='" + ReqVal["qbranch"]+"' ";
        }

        if (qs_dept == "t") {
		    SQL = "select a.*,c.sqlno as todo_sqlno ";
		    SQL+= ",(select branchname from sysctrl.dbo.branch_code where branch=a.branch) as branchname " ;
            SQL += ",''fseq,''appl_name,''scode,''scode_name,''term1,''term2,''cust_name ";
		    SQL+= " from dmt_brtran a ";
		    SQL+= " inner join todo_dmt c on a.brtran_sqlno=c.temp_rs_sqlno and c.dowhat='TRAN_EM' ";
		    SQL+= " where c.job_status ='NN' and c.apcode='brta76' ";
        } else if (qs_dept == "e") {
            SQL = "select a.*,c.sqlno as todo_sqlno ";
            SQL += ",(select branchname from sysctrl.dbo.branch_code where branch=a.branch) as branchname ";
            SQL += ",''fseq,''appl_name,''scode,''scode_name,''term1,''term2,''cust_name ";
            SQL += " from ext_brtran a ";
            SQL += " inner join todo_ext c on a.brtran_sqlno=c.att_no and c.dowhat='TRAN_EM' ";
            SQL += " where c.job_status ='NN' and c.apcode='exta76' ";
        }
        SQL += wsql;

        ReqVal["qryOrder"] = ReqVal.TryGet("SetOrder", "a.branch,a.seq,a.seq1");
        if (ReqVal.TryGet("qryOrder") != "") {
            SQL += " order by " + ReqVal.TryGet("qryOrder");
        }
        DataTable dt = new DataTable();
        conn.DataTable(SQL, dt);
        Sys.showLog(SQL);
        //處理分頁
        int nowPage = Convert.ToInt32(Request["GoPage"] ?? "1"); //第幾頁
        int PerPageSize = Convert.ToInt32(Request["PerPage"] ?? "10"); //每頁筆數
        page = new Paging(nowPage, PerPageSize, SQL);
        page.GetPagedTable(dt);

        //分頁完再處理其他資料才不會虛耗資源
        for (int i = 0; i < page.pagedTable.Rows.Count; i++) {
            DataRow dr = page.pagedTable.Rows[i];

            //案號
            dr["fseq"] = Sys.formatSeq(dr.SafeRead("seq", ""), dr.SafeRead("seq1", ""), "", dr.SafeRead("branch", ""), dept_nm);

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
        }

        dataRepeater.DataSource = page.pagedTable;
        dataRepeater.DataBind();
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
	        <td class="text9" colspan="2">
		        ◎原單位通知轉案期間：
			    <input type="text" id="sdate" name="sdate" size="10" maxlength=10 lass="dateField" value="<%#ReqVal.TryGet("sdate")%>">
                ~
			    <input type="text" id="edate" name="edate" size="10" maxlength=10 class="dateField" value="<%#ReqVal.TryGet("edate")%>">
	        </td>
        </tr>
	    <tr>	
		    <td class="text9">
			    ◎原單位本所編號：
				    <INPUT type="text" name="qseq" id="qseq" size="60" maxlength="100" onblur="fseq_chk(this)" value="<%#ReqVal.TryGet("qseq")%>">-
				    <INPUT type="text" name="qseq1" id="qseq1" size="3" maxlength="3" value="<%#ReqVal.TryGet("qseq1")%>">
			    &nbsp;&nbsp;&nbsp;
			    ◎原單位區所別：<select id="qbranch" name="qbranch"><%#html_qbranch%></SELECT>	
			    &nbsp;&nbsp;&nbsp;
			    <input type="button" value="查詢" class="cbutton" onClick="goSearch()" id=button1 name=button1>
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
	<br /><font color="red">=== 目前無資料 ===</font>
</div>

<form style="margin:0;" id="reg" name="reg" method="post">
	<input type="hidden" name="prgid" id="prgid" value="<%=prgid%>">
    <input type=hidden id=qs_dept name=qs_dept value="<%=qs_dept%>"> 
    <input type=hidden id=row name=row value="<%#page.pagedTable.Rows.Count%>"> 
    <INPUT type="hidden" id=rows_chkflag name=rows_chkflag />
	<input type="hidden" id=rows_brtran_sqlno name=rows_brtran_sqlno />
	<input type="hidden" id=rows_todo_sqlno name=rows_todo_sqlno />
	<input type="hidden" id=rows_branch name=rows_branch />
	<input type="hidden" id=rows_seq name=rows_seq />
	<input type="hidden" id=rows_seq1 name=rows_seq1 />
	<input type="hidden" id=rows_appl_name name=rows_appl_name />
	<input type="hidden" id=rows_scode name=rows_scode />
	<input type="hidden" id=rows_cust_name name=rows_cust_name />
	<input type="hidden" id=rows_tran_seq_branch name=rows_tran_seq_branch />
	<input type="hidden" id=rows_tran_remark name=rows_tran_remark />

    <asp:Repeater id="dataRepeater" runat="server">
    <HeaderTemplate>
        <table style="display:<%#page.totRow==0?"none":""%>" border="0" class="bluetable" cellspacing="1" cellpadding="2" width="100%" align="center" id="dataList">
	        <thead>
                  <Tr class="lightbluetable" align="center">
	                <td nowrap>
                        <a href="javascript:void(0);" onclick="selectall()" style="color:darkblue" onmouseover="this.style.color='red'" onmouseout="this.style.color='darkblue'">全選</a>
                    </td>
		            <td><u class="setOdr" v1="a.branch,a.seq,a.seq1">原單位</u></td>
		            <td nowrap>原單位案件編號</td>
		            <td>原單位營洽</td>
		            <td>案件名稱</td>
		            <td>客戶名稱</td>
		            <td>專用期限</td>
		            <td><u class="setOdr" v1="a.dc_date">轉案通知日</u></td>
		            <td>轉案原因</td>
                  </tr>
	        </thead>
	        <tbody>
    </HeaderTemplate>
		<ItemTemplate>
 	        <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>">
	            <td align="center">
			        <input type="checkbox" id=chkflag_<%#(Container.ItemIndex+1)%> value="Y">
			        <input type="hidden" id=brtran_sqlno_<%#(Container.ItemIndex+1)%> value="<%#Eval("brtran_sqlno")%>">
			        <input type="hidden" id=todo_sqlno_<%#(Container.ItemIndex+1)%> value="<%#Eval("todo_sqlno")%>">
			        <input type="hidden" id=branch_<%#(Container.ItemIndex+1)%> value="<%#Eval("branch")%>">
			        <input type="hidden" id=seq_<%#(Container.ItemIndex+1)%> value="<%#Eval("seq")%>">
			        <input type="hidden" id=seq1_<%#(Container.ItemIndex+1)%> value="<%#Eval("seq1")%>">
			        <input type="hidden" id=appl_name_<%#(Container.ItemIndex+1)%> value="<%#Eval("appl_name")%>">
			        <input type="hidden" id=scode_<%#(Container.ItemIndex+1)%> value="<%#Eval("scode")%>">
			        <input type="hidden" id=cust_name_<%#(Container.ItemIndex+1)%> value="<%#Eval("cust_name")%>">
			        <input type="hidden" id=tran_seq_branch_<%#(Container.ItemIndex+1)%> value="<%#Eval("tran_seq_branch")%>">
			        <input type="hidden" id=tran_remark_<%#(Container.ItemIndex+1)%> value="<%#Eval("tran_remark")%>">
		        </td>
		        <td align="center"><%#Eval("branchname")%></td>
		        <td nowrap align='center' style="cursor: pointer;" onmouseover="this.style.color='red'" onmouseout="this.style.color='black'"  onclick="CapplClick('<%#Eval("seq")%>', '<%#Eval("seq1")%>','<%#Eval("branch")%>','<%=dept_nm%>')">
                    <%#Eval("fseq")%>
		        </td>
		        <td align="center" nowrap><%#Eval("scode_name")%></td>
                <td style="cursor:pointer" title="<%#Eval("appl_name")%>"><%#Eval("appl_name").ToString().CutData(20)%></td>
                <td style="cursor:pointer" title="<%#Eval("cust_name")%>"><%#Eval("cust_name").ToString().CutData(20)%></td>
		        <td align="center"><%#(Eval("term1").ToString()!=""?Eval("term1")+"~":"")%><%#Eval("term2")%></td>
		        <td align="center"><%#Eval("dc_date")%></td>
		        <td align="left"><%#Eval("tran_remark")%></td>
	        </tr>
		</ItemTemplate>
    <FooterTemplate>
	        </tbody>
        </table>
        <br>
        <div id="divSign" style="display:<%#page.totRow==0?"none":""%>;text-align:center">
            <table border=0 class="bluetable"  cellspacing=1 cellpadding=2 width="100%">
	            <tr><td width="20%" class=lightbluetable3 align=right>新營洽：</td>
	                <td width="80%" class=whitetablebg>
			            <select name="tran_scode1" id="tran_scode1"><%#html_tran_scode1%></select>
		            </td>	
                </tr>
            </table> 
            <br>
            <table border="0" width="70%" cellspacing="1" cellpadding="0" align="center">
	            <TR>
		            <td >
                        <label>
                        <input type=radio name="usesign" id="usesignM" checked><strong>正常簽核:</strong>
		                <strong>區所主管:</strong><%=mSC_name%><input type=hidden name=Msign id=Msign value="<%=mSC_code%>">
                        </label>
		            </td>
	            </TR>
                <TR>
		            <td >
                        <label>
                        <input type=radio name="usesign" id="usesignO"><strong>特殊處理:</strong>
                        </label>
		                <select id=selectsign name=selectsign>
			            <option value="" style="color:blue">請選擇主管</option><%=html_selectsign%>
			            </select>
		            </td>	
	            </TR>
            </table>
	        <input type=hidden id=signid name=signid>
            <br />
            <%#StrFormBtn%>
	        <BR>
        </div>
        <BR>
        <table border="0" width="100%" cellspacing="0" cellpadding="0">
		    <tr class="FormName"><td>
			    <div align="left" style="color:blue">
			        ※流程:營洽轉案處理-->組主管簽核-->部門主管簽核-->區所主管簽核-->程序轉案發文確認--><font color=red>新單位主管確認轉案(部門主管指定營洽-->區所主管簽核)</font>-->新單位程序確認轉案-->程序轉案完成確認
			        <br>※步驟:請勾選確認轉案案件並選擇案件所屬新營洽，再送區所主管簽核
			    </div>
		    </td>
            </tr>
	    </table>
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

    //執行查詢
    function goSearch() {
        $("#regPage").submit();
    };

    function this_init() {
        $("#dataList>tbody select[id^='end_type_']").each(function () {
            $(this).triggerHandler("change");
        });

        $(".Lock").lock();
        $("input.dateField").datepick();
    }
    //////////////////////
    $("#sdate,#edate").blur(function (e){
        ChkDate(this);
    });

    //案件主檔
    function CapplClick(x1,x2,pbranch,pdept){
        if (pdept=="T"){
            url=getRootPath() + "/brt5m/brt15ShowFP.aspx?prgid=<%=prgid%>&seq=" + x1 + "&seq1=" + x2 + "&submittask=Q&type=brtran&branch=" + pbranch;
        }else{
            //***todo
            url=getRootPath() + "/brt5m/ext54Edit.aspx?prgid=<%=prgid%>&seq=" + x1 + "&seq1=" + x2 + "&submittask=Q&type=brtran&branch=" + pbranch;
        }
        $('#dialog').html('<iframe style="border: 0px;" src="' + url + '" width="100%" height="100%"></iframe>')
       .dialog({autoOpen: true,modal: true,height: 540,width: 900,title: "案件主檔"});
    }

    //全選
    function selectall(){
        for (var j = 1; j <= CInt($("#row").val()) ; j++) {
            $("#chkflag_"+j).prop("checked",true).triggerHandler("click");
        }
    }

    //確認
    function formSubmit(){
        $("#rows_chkflag,#rows_brtran_sqlno,#rows_todo_sqlno,#rows_branch,#rows_seq,#rows_seq1,#rows_appl_name,#rows_scode,#rows_cust_name,#rows_tran_seq_branch,#rows_tran_remark").val("");

        var totnum=$("input[id^='chkflag_']:checked").length;
        if (totnum==0){
            alert("請勾選您要轉案確認的案件!!");
            return false;
        }

        if ($("#tran_scode1").val()==""){
            alert("請點選新營洽！");
            return false;
        }

        if($("#usesignM").prop("checked")==true){//正常簽核
            $("#signid").val($("#Msign").val());
        }else{
            //特殊處理
            if($("#selectsign").val()==""){
                alert("請選擇主管");
                $("#selectsign").focus();
                return false;
            }
            $("#signid").val($("#selectsign").val());
        }


        if ($("#signid").val()==""){
            alert("未選擇主管，無法送主管簽核，請檢查！！");
            return false;
        }

        var tans = confirm("共有" + totnum + "筆確認轉案 , 是否確定?");
        if (tans ==false) return false;

        //串接資料
        $("#rows_chkflag").val(getJoinValue("#dataList>tbody input[id^='chkflag_']"));
        $("#rows_brtran_sqlno").val(getJoinValue("#dataList>tbody input[id^='brtran_sqlno_']"));
        $("#rows_todo_sqlno").val(getJoinValue("#dataList>tbody input[id^='todo_sqlno_']"));
        $("#rows_branch").val(getJoinValue("#dataList>tbody input[id^='branch_']"));
        $("#rows_seq").val(getJoinValue("#dataList>tbody input[id^='seq_']"));
        $("#rows_seq1").val(getJoinValue("#dataList>tbody input[id^='seq1_']"));
        $("#rows_appl_name").val(getJoinValue("#dataList>tbody input[id^='appl_name_']"));
        $("#rows_scode").val(getJoinValue("#dataList>tbody input[id^='scode_']"));
        $("#rows_cust_name").val(getJoinValue("#dataList>tbody input[id^='cust_name_']"));
        $("#rows_tran_seq_branch").val(getJoinValue("#dataList>tbody input[id^='tran_seq_branch_']"));
        $("#rows_tran_remark").val(getJoinValue("#dataList>tbody input[id^='tran_remark_']"));

        $("input:disabled, select:disabled").unlock();
        $(".bsubmit").lock(!$("#chkTest").prop("checked"));

        var formData = new FormData($('#reg')[0]);
        ajaxByForm("Brt3h_Update.aspx",formData)
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
                            window.parent.Etop.goSearch();//重新整理
                        }
                    }
                }
            });
        });
    }
</script>