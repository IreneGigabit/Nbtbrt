<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<script runat="server">
    protected string HTProgCap = "國內案結案確認暨掃描上傳";//HttpContext.Current.Request["prgname"];//功能名稱
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

    protected string html_qscode = "";

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
        if ((HTProgRight & 4) > 0 || (HTProgRight & 8) > 0 || (HTProgRight & 16) > 0 || (HTProgRight & 64) > 0) {
            StrFormBtn += "<input type=button value ='確認結案' class='cbutton bsubmit' onclick='formSubmit()'>\n";
            StrFormBtn += "<input type=button value ='重　填' class='cbutton' onclick='this_init()'>\n";
        }
        
        //洽案營洽
        SQL="select distinct a.scode,(select sc_name from sysctrl.dbo.scode where scode=a.scode) as sc_name ";
        SQL += ",(select sscode from sysctrl.dbo.scode where scode=a.scode) as scode1 ";
        SQL += "from dmt a inner join todo_dmt b on a.seq=b.seq and a.seq1=b.seq1 ";
        SQL += "where syscode='"+Session["syscode"]+"' and dowhat='DC_END2' and job_status='NN' ";
        SQL += "order by scode1";
        html_qscode = Util.Option(conn, SQL, "{scode}", "{sc_name}", true, ReqVal.TryGet("qscode", Sys.GetSession("scode")));
    }

    private void QueryData() {
        SQL = "select a.*,b.rs_sqlno,b.cappl_name as appl_name,b.dmt_scode as scode,b.rs_detail,b.end_date,b.now_step_grade,b.end_code,b.end_type,b.end_remark,c.sqlno as todo_sqlno ";
        SQL += ",(select cust_name from view_cust where view_cust.cust_area = b.cust_area and view_cust.cust_seq = b.cust_seq) as cust_name ";
        SQL += ",(select sc_name from sysctrl.dbo.scode where scode = b.dmt_scode) as scode_name ";
        SQL += ",(select code_name from cust_code where code_type = 'CT' and cust_code = a.ctrl_type) as ctrl_type_name ";
        SQL += ",''fseq,''scancount ";
        SQL += " from ctrl_dmt a ";
        SQL += " inner join vstep_dmt b on a.seq = b.seq and a.seq1 = b.seq1 and a.step_grade=b.step_grade ";
        SQL += " inner join todo_dmt c on a.seq=c.seq and a.seq1=c.seq1 and a.step_grade=c.step_grade and c.dowhat='DC_END2' ";
        SQL += " where a.ctrl_type='B61' and c.job_status like 'N%' ";
        if (ReqVal.TryGet("qseq") != "") {
            SQL += "AND a.seq in('" + ReqVal.TryGet("qseq").Replace(",", "','") + "') ";
        }
        if (ReqVal.TryGet("qseq1") != "") {
            SQL += "AND a.seq1='" + ReqVal["qseq1"] + "' ";
        }
        if (ReqVal.TryGet("sdate") != "") {
            SQL += "AND a.ctrl_date>='" + ReqVal["sdate"] + " 00:00:00' ";
        }
        if (ReqVal.TryGet("edate") != "") {
            SQL += "AND a.ctrl_date<='" + ReqVal["edate"] + " 23:59:59' ";
        }
        if (ReqVal.TryGet("qscode") != "") {
            SQL += "AND b.dmt_scode='" + ReqVal["qscode"] + "' ";
        }
        if (ReqVal.TryGet("qcust_seq") != "") {
            SQL += "AND b.cust_seq='" + ReqVal["qcust_seq"] + "' ";
        }
        ReqVal["qryOrder"] = ReqVal.TryGet("SetOrder", "a.seq,a.seq1,a.ctrl_date");
        if (ReqVal.TryGet("qryOrder") != "") {
            SQL += " order by " + ReqVal.TryGet("qryOrder");
        }
        DataTable dt = new DataTable();
        conn.DataTable(SQL, dt);
        Sys.showLog(SQL);
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

            //結案代碼預設E_線上結案簽核完成
            if (dr.SafeRead("end_code","") == "") {
                dr["end_code"] = "E";
            }
            
            //明細筆數
            SQL = "select count(*) from dmt_attach where seq=" + dr["seq"] + " and seq1='" + dr["seq1"] + "' and source='scan' and chk_status='NN' and attach_flag<>'D' ";
            dr["scancount"] = Sys.getNum(conn, SQL);
        }

        dataRepeater.DataSource = page.pagedTable;
        dataRepeater.DataBind();
    }

    //結案代碼
    protected string GetEndCode(RepeaterItem Container) {
        return Sys.getCustCode("endcode", "", "sortfld").Option("{cust_code}", "{code_name}", Eval("end_code").ToString());
    }

    //結案原因
    protected string GetEndType(RepeaterItem Container) {
        return Sys.getCustCode("Tend_type", "", "sortfld").Option("{cust_code}", "{code_name}", Eval("end_type").ToString());
    }

    //文件掃描未確認資料
    protected void dataRepeater_ItemDataBound(object sender, RepeaterItemEventArgs e) {
        if ((e.Item.ItemType == ListItemType.Item) || (e.Item.ItemType == ListItemType.AlternatingItem)) {
            string seq = DataBinder.Eval(e.Item.DataItem, "seq").ToString();
            string seq1 = DataBinder.Eval(e.Item.DataItem, "seq1").ToString();
            Repeater scanRpt = (Repeater)e.Item.FindControl("scanRepeater");
            if ((scanRpt != null)) {
                DataTable dtDtl = new DataTable();
                SQL = "select seq,seq1,attach_sqlno,step_grade,attach_no,attach_desc,chk_page,chk_date,attach_path,attach_name";
                SQL += ",(select rs_no from step_dmt where seq=dmt_attach.seq and seq1=dmt_attach.seq1 and step_grade=dmt_attach.step_grade) as rs_no ";
                SQL += ",(select rs_sqlno from step_dmt where seq=dmt_attach.seq and seq1=dmt_attach.seq1 and step_grade=dmt_attach.step_grade) as rs_sqlno ";
                SQL += ",''i,''j,''pr_scan_path,''pr_scan_flag,''tstyle,''scanfile_title,''pr_scan ";
                SQL += " from dmt_attach ";
                SQL += " where seq=" + seq + " and seq1='" + seq1 + "' and source='scan' and chk_status='NN' and attach_flag<>'D' ";
                conn.DataTable(SQL, dtDtl);
                //dtDtl.ShowTable();

                for (int i = 0; i < dtDtl.Rows.Count; i++) {
                    DataRow dr = dtDtl.Rows[i];
                    dr["i"] = (e.Item.ItemIndex + 1);
                    dr["j"] = (i+ 1);
                    
                    //檢查是否已掃描
                    dr["pr_scan_path"] = Sys.Path2Nbtbrt(dr.SafeRead("attach_path", ""));
                    if (Sys.CheckFile(dr.SafeRead("pr_scan_path", "")) == true) {
                        dr["pr_scan_flag"] = "Y";
                        dr["tstyle"] = "display:";
                        dr["scanfile_title"] = "有文件";
                        dr["pr_scan"] = "Y";
                    } else {
                        dr["pr_scan_flag"] = "N";
                        dr["tstyle"] = "display:none";
                        dr["scanfile_title"] = "尚未掃描";
                        dr["pr_scan"] = "N";
                    }
                }

                if (dtDtl.Rows.Count > 0) {
                    scanRpt.DataSource = dtDtl;
                    scanRpt.DataBind();
                } else {
                    scanRpt.Visible = false;
                }
            }
        }
    }

    //頁數
    protected string GetPage(RepeaterItem Container) {
        string pr_scan_flag = Eval("pr_scan_flag").ToString();
        if (pr_scan_flag == "Y") {
            return Eval("chk_page").ToString();
        } else {
            return "0";
        }
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
			    <input type="hidden" name="prgid" id="prgid" value="<%=prgid%>">
			    <input type="hidden" id="ctrlgs_type" name="ctrlgs_type">
			    ◎本所編號：
				    <INPUT type="text" id="qseq"  name="qseq" size="60" maxlength="100" value="<%#ReqVal.TryGet("qseq")%>">-
				    <INPUT type="text" id="qseq1" name="qseq1" size="3" maxlength="3" value="<%#ReqVal.TryGet("qseq1")%>">
			    <br>
                ◎管制期限期間：
			    <input type="text" id="sdate" name="sdate" size="10" maxlength=10 value="<%#ReqVal.TryGet("sdate")%>" class="dateField">～
			    <input type="text" id="edate" name="edate" size="10" maxlength=10 value="<%#ReqVal.TryGet("edate")%>" class="dateField">
		    </td>
		    <td class="text9">
		    ◎洽案營洽 :<select id="qscode" name="qscode"><%#html_qscode%></SELECT>
					
		    <br>◎客戶編號：<INPUT type="text" name="qcust_area" size="1" maxlength="1" readonly class="sedit" value="<%=Session["seBranch"]%>">-
				            <INPUT type="text" name="qcust_seq" size="5" maxlength="6" value="<%#ReqVal.TryGet("qcust_seq")%>">
		    </td>
		    <td class="text9">
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
	<br /><font color="red">===目前無資料 ===</font>
</div>

<form style="margin:0;" id="reg" name="reg" method="post">
	<input type="hidden" name="prgid" id="prgid" value="<%=prgid%>">
    <input type=hidden id=row name=row value="<%#page.pagedTable.Rows.Count%>"> 
    <INPUT type="hidden" id=rows_chkflag name=rows_chkflag />
	<input type="hidden" id=rows_ctrl_sqlno name=rows_ctrl_sqlno />
	<input type="hidden" id=rows_todo_sqlno name=rows_todo_sqlno />
	<input type="hidden" id=rows_branch name=rows_branch />
	<input type="hidden" id=rows_seq name=rows_seq />
	<input type="hidden" id=rows_seq1 name=rows_seq1 />
	<input type="hidden" id=rows_oend_date name=rows_oend_date />
	<input type="hidden" id=rows_step_grade name=rows_step_grade />
	<input type="hidden" id=rows_rs_sqlno name=rows_rs_sqlno />
	<input type="hidden" id=rows_scannum name=rows_scannum />
	<input type="hidden" id=rows_end_code name=rows_end_code />
	<input type="hidden" id=rows_end_type name=rows_end_type />
	<input type="hidden" id=rows_end_remark name=rows_end_remark />

    <asp:Repeater id="dataRepeater" runat="server" OnItemDataBound="dataRepeater_ItemDataBound">
    <HeaderTemplate>
        <table style="display:<%#page.totRow==0?"none":""%>" border="0" class="bluetable" cellspacing="1" cellpadding="2" width="100%" align="center" id="dataList">
	        <thead>
                  <Tr class="lightbluetable" align="center">
	                <td nowrap>
		                <a href="javascript:void(0);" onclick="selectall()" style="color:darkblue" onmouseover="this.style.color='red'" onmouseout="this.style.color='darkblue'">全選</a>
	                </td>
		            <td nowrap><u class="setOdr" v1="a.seq,a.seq1,a.ctrl_date">本所編號</u></td>
		            <td nowrap>目前<br>進度</td>
		            <td>案件名稱</td>
		            <td>客戶名稱</td>
		            <td><u class="setOdr" v1="a.ctrl_date">管制期限</u></td>
		            <td><u class="setOdr" v1="b.dmt_scode">營洽</u></td>
		            <td>結案代碼</td>
		            <td>結案原因</td>
                  </Tr>
	        </thead>
	        <tbody>
    </HeaderTemplate>
		<ItemTemplate>
 	        <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>">
		        <td align='center'>
			        <input type="checkbox" id=chkflag_<%#(Container.ItemIndex+1)%> value="Y" onclick="chkflagClick('<%#(Container.ItemIndex+1)%>')">
		            <input type="hidden" id=ctrl_sqlno_<%#(Container.ItemIndex+1)%> value="<%#Eval("sqlno")%>">
		            <input type="hidden" id=todo_sqlno_<%#(Container.ItemIndex+1)%> value="<%#Eval("todo_sqlno")%>">
		            <input type="hidden" id=branch_<%#(Container.ItemIndex+1)%> value="<%#Eval("branch")%>">
		            <input type="hidden" id=seq_<%#(Container.ItemIndex+1)%> value="<%#Eval("seq")%>">
		            <input type="hidden" id=seq1_<%#(Container.ItemIndex+1)%> value="<%#Eval("seq1")%>">
		            <input type="hidden" id=oend_date_<%#(Container.ItemIndex+1)%> value="<%#Eval("end_date")%>">
		            <input type="hidden" id=step_grade_<%#(Container.ItemIndex+1)%> value="<%#Eval("step_grade")%>">
		            <input type="hidden" id=rs_sqlno_<%#(Container.ItemIndex+1)%> value="<%#Eval("rs_sqlno")%>">
                    <input type="hidden" id=scannum_<%#(Container.ItemIndex+1)%> value="<%#Eval("scancount")%>">
                    <!--明細
					<input type=text id="d_hpr_scan_<%#(Container.ItemIndex+1)%>" />
					<input type=text id="d_attach_sqlno_<%#(Container.ItemIndex+1)%>" />
					<input type=text id="d_step_grade_<%#(Container.ItemIndex+1)%>" />
					<input type=text id="d_attach_no_<%#(Container.ItemIndex+1)%>" />
					<input type=text id="d_rs_no_<%#(Container.ItemIndex+1)%>" />
					<input type=text id="d_rs_sqlno_<%#(Container.ItemIndex+1)%>" />
                    <input type=text id="d_pr_scan_<%#(Container.ItemIndex+1)%>" />
                    <input type=text id="d_pr_scan_page_<%#(Container.ItemIndex+1)%>" />
                    <input type=text id="d_attach_desc_<%#(Container.ItemIndex+1)%>" />-->
		        </td>
		        <td nowrap align='center' style="cursor: pointer;"" onmouseover="this.style.color='red'" onmouseout="this.style.color='black'" onclick="CapplClick('<%#Eval("seq")%>','<%#Eval("seq1")%>')">
                    <%#Eval("fseq")%>
		        </td>
		        <td align="center">
                    <span style="cursor: pointer;" onmouseover="this.style.color='red'" onmouseout="this.style.color='black'" onclick="QstepClick('<%#Eval("seq")%>', '<%#Eval("seq1")%>')"><%#Eval("now_step_grade")%></span>
		            <img src="../images/ok.gif" style="cursor: pointer;" onclick="TodoClick('<%#Eval("seq")%>','<%#Eval("seq1")%>')" title="案件流程狀態查詢">
		        </td>		
		        <td align="left" title="<%#Eval("appl_name")%>"><%#Eval("appl_name").ToString().ToUnicode().CutData(20)%></td>
		        <td align="left" title="<%#Eval("cust_name")%>"><%#Eval("cust_name").ToString().ToUnicode().CutData(20)%></td>
		        <td align="left"><%#Eval("ctrl_type_name")%>　<%#Eval("ctrl_date","{0:d}")%><br><%#Eval("ctrl_remark")%></td>
		        <td align="left" nowrap><%#Eval("scode_name")%></td>
		        <td align="left">
		            <SELECT id=end_code_<%#(Container.ItemIndex+1)%>>
                        <%#GetEndCode(Container)%>
		 	        </SELECT>
		        </td>
		        <td align="left">
		            <SELECT id=end_type_<%#(Container.ItemIndex+1)%> onchange="showend_remark('<%#(Container.ItemIndex+1)%>')" >
				        <%#GetEndType(Container)%>
		 	        </SELECT>
		 	        <span id="span_end_remark_<%#(Container.ItemIndex+1)%>"><br><input type=text id="end_remark_<%#(Container.ItemIndex+1)%>" size=60 maxlength=100 value="<%#Eval("end_remark")%>"></span>
		        </td>
	        </tr>

            <!--文件掃描未確認資料-->
	        <asp:Repeater id="scanRepeater" runat="server">
                <HeaderTemplate>
	                <tr id="detail_<%#(((RepeaterItem)Container.Parent.Parent).ItemIndex + 1)%>" class="sfont9">
		                <td colspan=11>
                    <table width="88%" id="scanList_<%#(((RepeaterItem)Container.Parent.Parent).ItemIndex + 1)%>" border=1 cellspacing="1" cellpadding=1 align="right" style="color:darkblue;FONT-SIZE:9pt;border-top-width:1px;border-bottom-width:1px;border-left-width:0px;border-right-width:0px;">
		            <tr align="center" bgcolor=Cornsilk><td nowrap >進度</td><td nowrap >文件序號</td><td nowrap>掃描文件</td><td nowrap>掃描說明</td></tr>
                    <tbody>
                </HeaderTemplate>
                <ItemTemplate>
                    <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>" align="center">
					    <td align="center">
					    <%#Eval("step_grade")%>
					    <input type=hidden name="hpr_scan_<%#Eval("i")%>_<%#Eval("j")%>" id="hpr_scan_<%#Eval("i")%>_<%#Eval("j")%>" value="<%#Eval("pr_scan")%>">
					    <input type=hidden name="attach_sqlno_<%#Eval("i")%>_<%#Eval("j")%>" id="attach_sqlno_<%#Eval("i")%>_<%#Eval("j")%>" value="<%#Eval("attach_sqlno")%>">
					    <input type=hidden name="step_grade_<%#Eval("i")%>_<%#Eval("j")%>" id="step_grade_<%#Eval("i")%>_<%#Eval("j")%>" value="<%#Eval("step_grade")%>">
					    <input type=hidden name="attach_no_<%#Eval("i")%>_<%#Eval("j")%>" id="attach_no_<%#Eval("i")%>_<%#Eval("j")%>" value="<%#Eval("attach_no")%>">
					    <input type=hidden name="rs_no_<%#Eval("i")%>_<%#Eval("j")%>" id="rs_no_<%#Eval("i")%>_<%#Eval("j")%>" value="<%#Eval("rs_no")%>">
					    <input type=hidden name="rs_sqlno_<%#Eval("i")%>_<%#Eval("j")%>" id="rs_sqlno_<%#Eval("i")%>_<%#Eval("j")%>" value="<%#Eval("rs_sqlno")%>">
					    </td>
					    <td align="center"><%#Eval("attach_no")%></td>
		                <td >
                            <label>
                                <input type=checkbox name="pr_scan_<%#Eval("i")%>_<%#Eval("j")%>" id="pr_scan_<%#Eval("i")%>_<%#Eval("j")%>" value="Y" <%#(Eval("pr_scan").ToString()=="Y" ?"checked":"")%> onclick="pr_scan_click('<%#Eval("i")%>_<%#Eval("j")%>')">
		                        <span id="span_scanfile_<%#Eval("i")%>_<%#Eval("j")%>"><%#Eval("scanfile_title")%></span>
			                    <span id="span_scanpath_<%#Eval("i")%>_<%#Eval("j")%>" style="<%#Eval("tstyle")%>">
			                    ，頁數：<input type=text name="pr_scan_page_<%#Eval("i")%>_<%#Eval("j")%>" id="pr_scan_page_<%#Eval("i")%>_<%#Eval("j")%>" size=3 value="<%#GetPage(Container)%>" onblur="pr_scan_page_blur('<%#Eval("i")%>_<%#Eval("j")%>')">
			                    <a href="<%#Eval("pr_scan_path")%>" target="_blank">[檢視]</a>
			                    </span>
                            </label>
		                </td>
		                <td><input type=text name="attach_desc_<%#Eval("i")%>_<%#Eval("j")%>" id="attach_desc_<%#Eval("i")%>_<%#Eval("j")%>" value="<%#Eval("attach_desc")%>" size=30 maxlength=40 alt="『掃描說明』" onblur="fDataLen(this)"></td>
		            </tr>
                </ItemTemplate>
                <FooterTemplate>
                    </tbody>
                    </table>
		            </td>
	            </tr>
                </FooterTemplate>
			</asp:Repeater>
		</ItemTemplate>
    <FooterTemplate>
	        </tbody>
        </table>
        <br />
	    <div align="center" style="display:<%#page.totRow==0?"none":""%>">
            <%#StrFormBtn%>
        </div>
	    <BR>
        <table border="0" width="100%" cellspacing="0" cellpadding="0">
		    <tr class="FormName"><td>
			    <div align="left" style="color:blue">
			        ※流程:程序結案案件處理-->會計確認-->組主管簽核-->部門主管簽核-->區所主管簽核--><font color=red>程序確認結案暨掃描上傳</font>
			        <br>※點選[本所編號]可查詢案件主檔資料、點選[目前進度]序號可查詢案件進度資料、點選[<img src="<%=Page.ResolveUrl("~/images/ok.gif")%>">]可查詢案件狀態流程
			        <br>※勾選案件時，當出現「作業未處理完成」訊息，請點選[<img src="<%=Page.ResolveUrl("~/images/ok.gif")%>">]查詢<font color=red>未處理</font>作業，除程序結案確認及掃描確認作業外，需請相關人員處理完成才能確認結案。
			        <br>※勾選案件時，當出現「未銷管期限」訊息，請點選[目前進度]序號查詢未銷管期限，除結案完成期限外，需銷管期限才能確認結案。
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

    //全選
    function selectall(){
        for (var j = 1; j <= CInt($("#row").val()) ; j++) {
            $("#chkflag_"+j).prop("checked",true).triggerHandler("click");
        }
    }

    function chkflagClick(pchknum){
        tstr1="Y" 
        tstr2="N" 
        if($("#chkflag_"+pchknum).prop("checked")==true){
            //檢查案件狀態及是否有未銷管期限或未處理完成作業
            var err=chkseqdata(pchknum);
            if (err==true){
                $("#chkflag_"+pchknum).prop("checked",false);
            }
        }
    }

    //案件主檔
    function CapplClick(x1,x2) {
        var url = getRootPath() + "/brt5m/brt15ShowFP.aspx?prgid=<%=prgid%>&seq=" + x1 + "&seq1=" + x2 + "&submittask=Q";
        //window.showModalDialog(url, "", "dialogHeight: 540px; dialogWidth: 800px; center: Yes;resizable: No; status: No;scrollbars:yes");
        $('#dialog').html('<iframe style="border: 0px;" src="' + url + '" width="100%" height="100%"></iframe>')
        .dialog({autoOpen: true,modal: true,height: 540,width: 800,title: "案件主檔"});
    }
    //案件進度查詢
    function QstepClick(pseq,pseq1) {
        window.open(getRootPath() + "/brtam/brta61_Edit.aspx?submitTask=Q&qtype=A&prgid=<%=prgid%>&closewin=Y&winact=1&aseq=" + pseq + "&aseq1=" + pseq1, "myWindowOneN", "width=900 height=700 top=40 left=80 toolbar=no, menubar=no, location=no, directories=no resizeable=no status=no scrollbars=yes");
    }
    //案件流程狀態查詢
    function TodoClick(pseq,pseq1) {
        window.open(getRootPath() + "/brtam/brta61_list2.aspx?prgid=<%=prgid%>&seq=" + pseq + "&seq1=" + pseq1, "myWindowOneN", "width=900px, height=550px, top=10, left=10, toolbar=no, menubar=no, location=no, directories=no, status=no,resizable=yes, scrollbars=yes");
    }
    //結案原因
    function showend_remark(nRow) {
        if($("#end_type_"+nRow).val()=="016"){//其他
            if($("#end_remark_"+nRow).prop("defaultValue")!=""){
                $("#end_remark_"+nRow).val($("#end_remark_"+nRow).prop("defaultValue"));
            }else{
                $("#end_remark_"+nRow).val("");
            }
            $("#span_end_remark_"+nRow).show();
        }else{
            if($("#end_type_"+nRow).val()!=""){
                $("#end_remark_"+nRow).val($("#end_type_"+nRow+" :selected").text());
            }
            $("#span_end_remark_"+nRow).hide();
        }
    }

    //□掃描文件
    function pr_scan_click(pno){
        if($("#pr_scan_"+pno).prop("checked")==true){
            $("#hpr_scan_"+pno).val("Y");
            $("#span_scanfile_"+pno).html("有文件");
            $("#span_scanpath_"+pno).show();
        }else{
            $("#hpr_scan_"+pno).val("N");
            $("#pr_scan_page_"+pno).val("0");
            $("#span_scanfile_"+pno).html("尚未掃描");
            $("#span_scanpath_"+pno).hide();
        }
    }

    //頁數
    function pr_scan_page_blur(pno){
        if($("#pr_scan_page_"+pno).val()==""){
            alert("頁數必須輸入!!!");
            return false;
        }
        if(chkNum1($("#pr_scan_page_"+pno),"頁數")||chkInt($("#pr_scan_page_"+pno),"頁數")){
            $("#pr_scan_page_"+pno).val("0");
            return false;
        }
    }

    //檢查案件狀態及是否有未銷管期限或未處理完成作業
    function chkseqdata(pno){
        var rtn=false;
        var tmp_todo_sqlno=$("#todo_sqlno_"+pno).val();
        var tmp_seq=$("#seq_"+pno).val();
        var tmp_seq1=$("#seq1_"+pno).val();
        var fseq ="<%=Session["seBranch"]%><%=Session["dept"]%>" + tmp_seq + "-" + tmp_seq1;

        //檢查案件狀態
        var searchSql = "SELECT count(*) as cnt from todo_dmt where seq= " + tmp_seq + " and seq1='" + tmp_seq1 +"' and job_status='NN' and dowhat<>'DC_END2' and dowhat<>'scan' ";
        $.ajax({
            type: "get",
            url: getRootPath() + "/ajax/JsonGetSqlData.aspx",
            data: { sql: searchSql },
            async: false,
            cache: false,
            success: function (json) {
                var JSONdata = $.parseJSON(json);
                if (JSONdata.length > 0) {
                    if (JSONdata[0].cnt > 0) {
                        alert("本結案案件"+fseq+ "尚有作業未處理(除程序結案確認及掃描確認)完成共" +JSONdata[0].cnt+" 項，請檢查並處理完成再執行結案確認！");
                        rtn=true;
                        $("#todoend_flag").val("Y");
                    }
                }
            },
            error: function (xhr) {
                $("#dialog").html("<a href='" + this.url + "' target='_new'>檢查尚有作業未處理失敗！<u>(點此顯示詳細訊息)</u></a><hr>" + xhr.responseText);
                $("#dialog").dialog({ title: '檢查尚有作業未處理失敗！', modal: true, maxHeight: 500, width: "90%" });
            }
        });

        if(rtn==true){
            return rtn;
        }

        //檢查管制期限除B61結案完成期限
        var searchSql = "select count(*) as cnt from ctrl_dmt where seq=" + tmp_seq + " and seq1='" + tmp_seq1 +"' and ctrl_type<>'B61' ";
        $.ajax({
            type: "get",
            url: getRootPath() + "/ajax/JsonGetSqlData.aspx",
            data: { sql: searchSql },
            async: false,
            cache: false,
            success: function (json) {
                var JSONdata = $.parseJSON(json);
                if (JSONdata.length > 0) {
                    if (JSONdata[0].cnt > 0) {
                        alert("本結案案件"+fseq + "尚有未銷管期限(除結案完成期限)共" +JSONdata[0].cnt+" 筆，請檢查並處理完成再執行結案確認！");
                        rtn=true;
                        $("#todoend_flag").val("Y");
                    }
                }
            },
            error: function (xhr) {
                $("#dialog").html("<a href='" + this.url + "' target='_new'>檢查管制期限失敗！<u>(點此顯示詳細訊息)</u></a><hr>" + xhr.responseText);
                $("#dialog").dialog({ title: '檢查管制期限失敗！', modal: true, maxHeight: 500, width: "90%" });
            }
        });

        if(rtn==true){
            return rtn;
        }
 
        //檢查文件掃描確認
        var scannum=$("#scannum_" + pno).val();
        if (CInt(scannum)>0){
            for (var x = 1; x <= CInt(scannum) ; x++) {
                if($("#pr_scan_"+pno+"_"+x).prop("checked")==false){
                    alert("本案件"+fseq+"進度"+$("#step_grade_"+pno+"_"+x).val()+"文件序號"+$("#attach_no_"+pno+"_"+x).val()+"尚未掃描，請檢查並掃描完成再執行結案確認！");
                    rtn=true;
                    return true;
                }
            }
        }
        return rtn;
    }
    
    //串接資料
    function setRowData(){
        $("#rows_chkflag,#rows_ctrl_sqlno,#rows_todo_sqlno,#rows_branch,#rows_seq,#rows_seq1,#rows_oend_date,#rows_step_grade,#rows_rs_sqlno,#rows_scannum,#rows_end_code,#rows_end_type,#rows_end_remark").val("");
        //<!--明細-->
        $("#rows_d_hpr_scan,#rows_d_attach_sqlno,#rows_d_step_grade,#rows_d_attach_no,#rows_d_rs_no,#rows_d_rs_sqlno,#rows_d_pr_scan,#rows_d_pr_scan_page,#rows_d_attach_desc").val("");
        
        //for (var pno = 1; pno <= CInt($("#row").val()) ; pno++) {
        //    $("#d_hpr_scan_"+pno).val(getJoinValue("#scanList_"+pno+">tbody input[id^='hpr_scan_']","\b"));
        //    $("#d_attach_sqlno_"+pno).val(getJoinValue("#scanList_"+pno+">tbody input[id^='attach_sqlno_']","\b"));
        //    $("#d_step_grade_"+pno).val(getJoinValue("#scanList_"+pno+">tbody input[id^='step_grade_']","\b"));
        //    $("#d_attach_no_"+pno).val(getJoinValue("#scanList_"+pno+">tbody input[id^='attach_no_']","\b"));
        //    $("#d_rs_no_"+pno).val(getJoinValue("#scanList_"+pno+">tbody input[id^='rs_no_']","\b"));
        //    $("#d_rs_sqlno_"+pno).val(getJoinValue("#scanList_"+pno+">tbody input[id^='rs_sqlno_']","\b"));
        //    $("#d_pr_scan_"+pno).val(getJoinValue("#scanList_"+pno+">tbody input[id^='pr_scan_']","\b"));
        //    $("#d_pr_scan_page_"+pno).val(getJoinValue("#scanList_"+pno+">tbody input[id^='pr_scan_page_']","\b"));
        //    $("#d_attach_desc_"+pno).val(getJoinValue("#scanList_"+pno+">tbody input[id^='attach_desc_']","\b"));
        //}

        $("#rows_chkflag").val(getJoinValue("#dataList>tbody input[id^='chkflag_']"));
        $("#rows_ctrl_sqlno").val(getJoinValue("#dataList>tbody input[id^='ctrl_sqlno_']"));
        $("#rows_todo_sqlno").val(getJoinValue("#dataList>tbody input[id^='todo_sqlno_']"));
        $("#rows_branch").val(getJoinValue("#dataList>tbody input[id^='branch_']"));
        $("#rows_seq").val(getJoinValue("#dataList>tbody input[id^='seq_']"));
        $("#rows_seq1").val(getJoinValue("#dataList>tbody input[id^='seq1_']"));
        $("#rows_oend_date").val(getJoinValue("#dataList>tbody input[id^='oend_date_']"));
        $("#rows_step_grade").val(getJoinValue("#dataList>tbody>tr:not([id^='detail_']) input[id^='step_grade_']"));
        $("#rows_rs_sqlno").val(getJoinValue("#dataList>tbody>tr:not([id^='detail_']) input[id^='rs_sqlno_']"));
        $("#rows_scannum").val(getJoinValue("#dataList>tbody input[id^='scannum_']"));
        $("#rows_end_code").val(getJoinValue("#dataList>tbody select[id^='end_code_']"));
        $("#rows_end_type").val(getJoinValue("#dataList>tbody select[id^='end_type_']"));
        $("#rows_end_remark").val(getJoinValue("#dataList>tbody input[id^='end_remark_']"));
    }

    //確認
    function formSubmit(){
        setRowData();
        var totnum=$("input[id^='chkflag_']:checked").length;
        if (totnum==0){
            alert("請勾選您要送確認的案件!!");
            return false;
        }else{
            for (var pno = 1; pno <= CInt($("#row").val()) ; pno++) {
                if($("#chk_"+pno).prop("checked")==true){
                    var fseq="<%=Session["seBranch"]%><%=Session["dept"]%>" + tmp_seq+"-"+tmp_seq1;

                    if($("#end_type_"+pno).val()==""){
                        alert("案件："+fseq+"請選擇結案原因！");
                        $("#end_type_"+pno).focus();
                        return  false;
                    }
                    if($("#end_type_"+pno).val()=="016"&&$("#end_remark_"+pno).val()==""){
                        alert("案件："+fseq+"請輸入結案原因！");
                        $("#end_remark_"+pno).focus();
                        return  false;
                    }
                    if($("#end_code_"+pno).val()==""){
                        alert("案件："+fseq+"請選擇結案代碼！");
                        $("#end_code_"+pno).focus();
                        return  false;
                    }

                    var scannum=$("#scannum_" + pno).val();
                    if (CInt(scannum)>0){
                        for (var x = 1; x <= CInt(scannum) ; x++) {
                            if($("#pr_scan_"+pno+"_"+x).prop("checked")==true){
                                if($("#pr_scan_page_"+pno+"_"+x).val()==""){
                                    alert("本案件"+fseq+"進度"+$("#step_grade_"+pno+"_"+x).val()+"文件序號"+$("#attach_no_"+pno+"_"+x).val()+"頁數必須輸入!!!");
                                    return false;
                                }else{
                                    if(CInt($("#pr_scan_page_"+pno+"_"+x).val())<=0){
                                        alert("本案件"+fseq+"進度"+$("#step_grade_"+pno+"_"+x).val()+"文件序號"+$("#attach_no_"+pno+"_"+x).val()+"頁數必須大於 0 !!!");
                                        return false;
                                    }
                                }
                            }else{
                                alert("本案件"+fseq+"進度"+$("#step_grade_"+pno+"_"+x).val()+"文件序號"+$("#attach_no_"+pno+"_"+x).val()+"尚未掃描，請檢查！");
                                return false;
                            }
                        }
                    }
                }
            }

            var tans = confirm("共有" + totnum + "筆確認結案 , 是否確定?");
            if (tans ==false) return false;

            //串接資料
            setRowData();

            $("input:disabled, select:disabled").unlock();
            $(".bsubmit").lock(!$("#chkTest").prop("checked"));

            var formData = new FormData($('#reg')[0]);
            ajaxByForm("Brta75_Update.aspx",formData)
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
                                window.parent.Etop.goSearch();//重新整理
                            }
                        }
                    }
                });
            });
        }
    }
</script>