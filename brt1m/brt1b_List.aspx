<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<script runat="server">
    protected string HTProgCap = "營洽轉案處理";//HttpContext.Current.Request["prgname"];//功能名稱
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

    protected string back_count = "";
    protected string qryjob_status = "";
    protected string cust_area = "";
    protected string cust_seq = "";
    protected string cust_name = "";
    protected string cscode_name = "";
    
    protected bool emptyForm = true;
    protected string td_tscode = "",html_tran_seq_branch="";

    protected string tscode = "";//簽核計算營洽
    protected string nToSelect = "";//特殊處理鎖定
    protected string se_Grpid = "";//營洽所屬grpid
    protected string se_Grplevel = "";//營洽所屬grplevel
    protected string mSC_code = "";//直屬主管
    protected string mSC_name = "";//直屬主管名稱
    protected string selSign = "";//特殊簽核清單

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

        qryjob_status = ReqVal.TryGet("qryjob_status");
        if (qryjob_status == "") qryjob_status = "NN";
        
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
            StrFormBtn += "<input type=button value ='轉案暨送主管簽核' class='cbutton bsubmit' onclick='formSubmit()'>\n";
            StrFormBtn += "<input type=button value ='重　填' class='cbutton' onclick='this_init()'>\n";
        }

        if (qryjob_status == "NX") {//主管退回
            emptyForm = false;
        } else {
            if (ReqVal.TryGet("qrycust_seq") != "" || ReqVal.TryGet("qryscode") != "" || ReqVal.TryGet("qryseq") != "" || ReqVal.TryGet("qryseq1") != "") {
                emptyForm = false;
            }
        }

        //案件營洽
        //營洽清單
        //權限B：部門主管,區所主管
        //權限A：組主管
        if ((HTProgRight & 64) != 0 || (HTProgRight & 128) != 0) {
            string sales_scode = "";
            if ((HTProgRight & 128) != 0) {
                sales_scode = "";
            } else if ((HTProgRight & 64) != 0) {
                //抓取組主管所屬營洽
                string pwhescode = Sys.getTeamScode(Sys.GetSession("SeBranch"), Sys.GetSession("scode"));
                sales_scode = "and a.scode in(" + pwhescode + ")";
            }
            DataTable allScode = Sys.getDmtScode("", sales_scode);
            DataTable extScode = Sys.getExtScode("", sales_scode);
            allScode.Merge(extScode);
            allScode.DefaultView.Sort = "sscode,scode";
            DataTable dtDist = allScode.DefaultView.ToTable(true, new string[] { "sscode", "scode", "star", "sc_name", "color" });

            td_tscode = "<select id='qryscode' name='qryscode' >";
            td_tscode += Sys.getDmtScode("", sales_scode).Option("{scode}", "{star}{scode}_{sc_name}", "style='color:{color}'", true, ReqVal.TryGet("qryScode"));
            td_tscode += "<option value='" + Sys.GetSession("seBranch") + Sys.GetSession("dept") + "'>" + Sys.GetSession("seBranch") + Sys.GetSession("dept").ToUpper() + "_部門(開放客戶)</option>";
            td_tscode += "<option value='*' style='color:blue'>全部</option>";
            td_tscode += "</select>";
        } else {
            td_tscode = "<input type='text' id='qryscode' name='qryscode' readonly class='SEdit' value='" + Session["se_scode"] + "'>" + Session["sc_name"];
        }

        html_tran_seq_branch = Sys.getBranchCode().Select("branch<>'" + Sys.GetSession("sebranch") + "'", "sort").CopyToDataTable().Option("{branch}", "{branchname}", true);
    }

    private void QueryData() {
        string wsql = "";
        if (ReqVal.TryGet("qrycust_seq") != "") {
            wsql += " and a.cust_seq=" + ReqVal["qrycust_seq"];
        }
        if (ReqVal.TryGet("qryScode") != "") {
            wsql += " and a.scode='" + ReqVal["qryScode"] + "'";
        }
        if (ReqVal.TryGet("qrySeq") != "") {
            wsql += " and a.seq='" + ReqVal["qrySeq"] + "'";
        }
        if (ReqVal.TryGet("qrySeq1") != "") {
            wsql += " and a.seq1='" + ReqVal["qrySeq1"] + "'";
        }
        if (ReqVal.TryGet("qryend_flag") != "Y") {
            wsql += " and (a.end_date is null or a.end_date='')";
        }

        //抓取主管退回件數
        SQL = "SELECT count(*) as recnt from dmt a inner join todo_dmt b on a.seq=b.seq and a.seq1=b.seq1 where b.dowhat='TRAN_NSB' and b.job_status='NN' " + wsql;
        int dmt_recnt = Convert.ToInt32(conn.getZero(SQL));
        SQL = "SELECT count(*) as recnt from ext a inner join todo_ext b on a.seq=b.seq and a.seq1=b.seq1 where b.dowhat='TRAN_NSB' and b.job_status='NN' " + wsql;
        int ext_recnt = Convert.ToInt32(conn.getZero(SQL));
        back_count = (dmt_recnt != 0 || ext_recnt != 0) ? "(國內案：" + dmt_recnt + "件/出口案：" + ext_recnt + "件)" : "";

        if (emptyForm) wsql += "AND 1=0 ";
        
        if (qryjob_status == "NX") {//主管退回
            SQL = "Select '1' as sort,a.seq,a.seq1,'' as country,'' as ext_seq,'' as ext_seq1,a.cust_area,a.cust_seq,a.appl_name,a.class,a.scode,a.end_date,a.step_grade,a.term1,a.term2";
            SQL += ",b.cust_name,b.tscode,c.brtran_sqlno,d.sqlno as todo_sqlno,d.pre_sqlno as todo_presqlno ";
            SQL += ",(select code_name from cust_code where code_type='Tcase_stat' and cust_code=a.now_stat) as now_stat_name ";
            SQL += ",(SELECT sc_name FROM sysctrl.dbo.scode WHERE scode = a.scode) AS scode_name";
            SQL += ",(select sc_name from sysctrl.dbo.scode where scode = b.tscode) as cscode_name";
            SQL += ",''fseq,''fext_seq,'todo_dmt'todo_tblnm";
            SQL += " from dmt a ";
            SQL += " inner join view_cust b on a.cust_area=b.cust_area and a.cust_seq=b.cust_seq ";
            SQL += " inner join dmt_brtran c on a.seq=c.seq and a.seq1=c.seq1 ";
            SQL += " inner join todo_dmt d on d.seq=c.seq and d.seq1=c.seq1 and d.temp_rs_sqlno=c.brtran_sqlno and d.dowhat='TRAN_NSB' and d.job_status='NN' ";
            SQL += " where (a.tran_flag='A') " + wsql;
            //***todo
            //SQL += " union ";
            //SQL += " select '2' as sort,a.seq,a.seq1,a.country,a.ext_seq,a.ext_seq1,a.cust_area,a.cust_seq,a.appl_name,a.class,a.scode,a.end_date,a.step_grade,a.term1,a.term2";
            //SQL += ",b.cust_name,b.tscode,c.brtran_sqlno,d.sqlno as todo_sqlno,d.pre_sqlno as todo_presqlno ";
            //SQL += ",(select code_name from cust_code where code_type='TEcasestat' and cust_code=a.now_stat) as now_stat_name ";
            //SQL += ",(SELECT sc_name FROM sysctrl.dbo.scode WHERE scode = a.scode) AS scode_name";
            //SQL += ",(select sc_name from sysctrl.dbo.scode where scode = b.tscode) as cscode_name";
            //SQL += ",''fseq,''fext_seq,'todo_ext'todo_tblnm";
            //SQL += " from ext a ";
            //SQL += " inner join view_cust b on a.cust_area=b.cust_area and a.cust_seq=b.cust_seq ";
            //SQL += " inner join ext_brtran c on a.seq=c.seq and a.seq1=c.seq1 ";
            //SQL += " inner join todo_ext d on d.seq=c.seq and d.seq1=c.seq1 and d.att_no=c.brtran_sqlno and d.dowhat='TRAN_NSB' and d.job_status='NN' ";
            //SQL += " where (a.tran_flag='A') " + wsql;
        } else {
            SQL = "Select '1' as sort,a.seq,a.seq1,'' as country,'' as ext_seq,'' as ext_seq1,a.cust_area,a.cust_seq,a.appl_name,a.class,a.scode,a.end_date,a.step_grade,a.term1,a.term2";
            SQL += ",b.cust_name,b.tscode ";
            SQL += ",(select code_name from cust_code where code_type='Tcase_stat' and cust_code=a.now_stat) as now_stat_name ";
            SQL += ",(SELECT sc_name FROM sysctrl.dbo.scode WHERE scode = a.scode) AS scode_name";
            SQL += ",(select sc_name from sysctrl.dbo.scode where scode = b.tscode) as cscode_name";
            SQL += ",''fseq,''fext_seq,0 brtran_sqlno,0 todo_sqlno,'todo_dmt'todo_tblnm";
            SQL += " from dmt a ";
            SQL += " inner join view_cust b on a.cust_area=b.cust_area and a.cust_seq=b.cust_seq ";
            SQL += " where (a.tran_flag='' or a.tran_flag is null) " + wsql;
            SQL += " and a.seq1<>'M' ";//大陸進口案只於台北所立案處理不能轉案
            //***todo
            //SQL += " union ";
            //SQL += " select '2' as sort,a.seq,a.seq1,a.country,a.ext_seq,a.ext_seq1,a.cust_area,a.cust_seq,a.appl_name,a.class,a.scode,a.end_date,a.step_grade,a.term1,a.term2";
            //SQL += ",b.cust_name,b.tscode ";
            //SQL += ",(select code_name from cust_code where code_type='TEcasestat' and cust_code=a.now_stat) as now_stat_name ";
            //SQL += ",(SELECT sc_name FROM sysctrl.dbo.scode WHERE scode = a.scode) AS scode_name";
            //SQL += ",(select sc_name from sysctrl.dbo.scode where scode = b.tscode) as cscode_name";
            //SQL += ",''fseq,''fext_seq,0 brtran_sqlno,0 todo_sqlno,'todo_ext'todo_tblnm";
            //SQL += " from ext a ";
            //SQL += " inner join view_cust b on a.cust_area=b.cust_area and a.cust_seq=b.cust_seq ";
            //SQL += " where (a.tran_flag='' or a.tran_flag is null) " + wsql;
        }

        ReqVal["qryOrder"] = ReqVal.TryGet("SetOrder", "sort,a.seq,a.seq1");
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

            tscode = dr.SafeRead("tscode", "");
            cust_area = dr.SafeRead("cust_area", "");
            cust_seq = dr.SafeRead("cust_seq", "");
            cust_name = dr.SafeRead("cust_name", "");
            cscode_name = dr.SafeRead("cscode_name", "");

            //案號
            if (dr.SafeRead("country", "") == "") {
                dr["fseq"] = Sys.formatSeq(dr.SafeRead("seq", ""), dr.SafeRead("seq1", ""), "", Sys.GetSession("seBranch"), Sys.GetSession("dept"));
            } else {
                dr["fseq"] = Sys.formatSeq(dr.SafeRead("seq", ""), dr.SafeRead("seq1", ""), dr.SafeRead("country", ""), Sys.GetSession("seBranch"), Sys.GetSession("dept") + "E");
                dr["fext_seq"] = Sys.formatSeq(dr.SafeRead("ext_seq", ""), dr.SafeRead("ext_seq1", ""), "", "", Sys.GetSession("dept") + "E");
            }

            if (dr.SafeRead("scode_name", "") == "") {
                dr["scode_name"] = dr.SafeRead("scode", "");
            }
        }

        dataRepeater.DataSource = page.pagedTable;
        dataRepeater.DataBind();

        //簽核用20201229修改邏輯,防自己交辦自己簽
        if (ReqVal.TryGet("qryscode", "") != "") {
            tscode = ReqVal.TryGet("qryscode", "");
        }
        Sys.getScodeGrpid(Sys.GetSession("SeBranch"), tscode, ref se_Grpid, ref se_Grplevel);
        mSC_code = Sys.getSignMaster(Sys.GetSession("SeBranch"), tscode);//抓取直屬主管,若主管為自己則再往上找
        string mSC_code1 = Sys.getSignMaster(Sys.GetSession("SeBranch"), tscode, false);
        if (tscode == mSC_code1) {//營洽=組主管
            nToSelect = "Lock";
        }

        SQL = "select sc_name from scode where scode='" + mSC_code + "'";
        object objResult = cnn.ExecuteScalar(SQL);
        mSC_name = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();
        DataTable dtSign = Sys.getSignList(Sys.GetSession("SeBranch"), se_Grpid, Sys.GetSession("Scode"), mSC_code, "grplevel>0");
        selSign = dtSign.Option("{master_scode}", "{master_type}---{Master_nm}", false);
    }

    //退回原因
    protected string GetBackIcon(RepeaterItem Container) {
        string rtn = "";

        if (qryjob_status == "NX") {
            SQL = "select approve_desc from " + Eval("todo_tblnm") + " where sqlno=" + Eval("todo_presqlno");
            string br_ap_desc = conn.getString(SQL);

            if (br_ap_desc != "") {
                rtn = "<img border=\"0\" src=\"" + Page.ResolveUrl("~/images/star_pl.gif") + "\" title=\"主管退回原因：" + br_ap_desc + "\">";
            }
        }

        return rtn;
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
		        ◎作業狀態：<label><input type="radio" name="qryjob_status" value="NN" <%#qryjob_status=="NN"?"checked":""%>>轉案處理</label>
		                  <label><input type="radio" name="qryjob_status" value="NX" <%#qryjob_status=="NX"?"checked":""%>><font color=red>主管退回<%#back_count%></font></label>
	        </td>
        </tr>
	    <tr>
		    <td class="text9" width="50%" nowrap>
			    <input type="hidden" name="prgid" id="prgid" value="<%=prgid%>">
                ◎客戶編號：<INPUT type="text" name="qrycust_area" size="1" maxlength="1" readonly class="sedit" value="<%=Session["seBranch"]%>">-
				<INPUT type="text" name="qrycust_Seq" size="5" maxlength="6" value="<%#ReqVal.TryGet("qrycust_Seq")%>">
		        ◎案件營洽 :<%#td_tscode%>
		        <br>
			    ◎本所編號：
				<INPUT type="text" id="qrySeq"  name="qrySeq" size="40" maxlength="100" value="<%#ReqVal.TryGet("qrySeq")%>">-
				<INPUT type="text" id="qrySeq1" name="qrySeq1" size="3" maxlength="3" value="<%#ReqVal.TryGet("qrySeq1")%>">
                <label><input type="checkbox" name="qryend_flag" value="Y" <%#ReqVal.TryGet("qryend_flag")=="Y"?"checked":""%>>包含結案</label>
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
	<br /><font color="red">=== <%=(emptyForm?"請先輸入查詢條件":"目前無資料")%> ===</font>
</div>

<form style="margin:0;" id="reg" name="reg" method="post">
	<input type="hidden" name="prgid" id="prgid" value="<%=prgid%>">
    <input type=hidden id=row name=row value="<%#page.pagedTable.Rows.Count%>"> 
    <INPUT type="hidden" id=qryjob_status name=qryjob_status />
    <INPUT type="hidden" id=rows_chkflag name=rows_chkflag />
	<input type="hidden" id=rows_seq name=rows_seq />
	<input type="hidden" id=rows_seq1 name=rows_seq1 />
	<input type="hidden" id=rows_country name=rows_country />
	<input type="hidden" id=rows_scode name=rows_scode />
	<input type="hidden" id=rows_cust_area name=rows_cust_area />
	<input type="hidden" id=rows_cust_seq name=rows_cust_seq />
	<input type="hidden" id=rows_brtran_sqlno name=rows_brtran_sqlno />
	<input type="hidden" id=rows_todo_sqlno name=rows_todo_sqlno />

    <asp:Repeater id="dataRepeater" runat="server">
    <HeaderTemplate>
        <table style="display:<%#page.totRow==0?"none":""%>" border="0" class="bluetable" cellspacing="1" cellpadding="2" width="100%" align="center" id="dataList">
	        <thead>
                  <tr class="sfont9">
                      <td colspan=11 style="cursor: pointer;color:darkblue" onmouseover="this.style.color='red'" onmouseout="this.style.color='darkblue'" onclick="CustClick('<%=cust_area%>', '<%=cust_seq%>')">
                      客戶名稱：<%=cust_name%>&nbsp;&nbsp;客戶營洽：<%=cscode_name%></td>
                  </tr>
                  <Tr class="lightbluetable" align="center">
	                <td nowrap>
                        <a href="javascript:void(0);" onclick="selectall()" style="color:darkblue" onmouseover="this.style.color='red'" onmouseout="this.style.color='darkblue'">全選</a>
                    </td>
	                <td nowrap>案件編號</td>  
	                <td nowrap>目前<br>進度</td>   
	                <td nowrap>類別</td>  
	                <td nowrap>案件名稱</td> 
	                <td nowrap>專用期限</td>
	                <td nowrap>案件狀態</td> 
	                <td nowrap>結案日期</td>
                    <td nowrap>營洽</td>
                    <td nowrap>國外所編號</td>
                    <td nowrap>附件</td>
                  </tr>
	        </thead>
	        <tbody>
    </HeaderTemplate>
		<ItemTemplate>
 	        <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>">
	            <td  align="center">
			        <input type="checkbox" id=chkflag_<%#(Container.ItemIndex+1)%> value="Y">
	                <input type="hidden" id="seq_<%#(Container.ItemIndex+1)%>" value="<%#Eval("seq")%>">
	                <input type="hidden" id="seq1_<%#(Container.ItemIndex+1)%>" value="<%#Eval("seq1")%>">
	                <input type="hidden" id="country_<%#(Container.ItemIndex+1)%>" value="<%#Eval("country")%>">
	                <input type="hidden" id="scode_<%#(Container.ItemIndex+1)%>" value="<%#Eval("scode")%>">
	                <input type="hidden" id="cust_area_<%#(Container.ItemIndex+1)%>" value="<%#Eval("cust_area")%>">
	                <input type="hidden" id="cust_seq_<%#(Container.ItemIndex+1)%>" value="<%#Eval("cust_seq")%>">
	                <input type="hidden" id="brtran_sqlno_<%#(Container.ItemIndex+1)%>" value="<%#Eval("brtran_sqlno")%>">
	                <input type="hidden" id="todo_sqlno_<%#(Container.ItemIndex+1)%>" value="<%#Eval("todo_sqlno")%>">
		        </td>
		        <td  nowrap style="cursor: pointer;color:darkblue" onmouseover="this.style.color='red'" onmouseout="this.style.color='darkblue'" onclick="CapplClick('<%#Eval("seq")%>','<%#Eval("seq1")%>','<%#Eval("country")%>')">
                    <%#Eval("fseq")%>
                    <%#GetBackIcon(Container)%>
		        </td>
		        <td  nowrap align=center style="cursor: pointer;" onmouseover="this.style.color='red'" onmouseout="this.style.color='black'" onclick="QstepClick(<%#Eval("seq")%>, '<%#Eval("seq1")%>','<%#Eval("country")%>')"><%#Eval("step_grade")%></td>
		        <td  ><%#Eval("class")%></td>
		        <td  style="cursor: pointer" title="<%#Eval("appl_name")%>"><%#Eval("appl_name").ToString().CutData(20)%></td>
		        <td  nowrap align=left ><%#(Eval("term1").ToString()!=""?Eval("term1","{0:d}")+"~":"")%><%#Eval("term2","{0:d}")%></td>
		        <td  align="center"><%#Eval("now_stat_name")%></td>
		        <td  align="center"><%#Eval("end_date","{0:d}")%></td>
		        <td  align="center"><%#Eval("scode_name")%></td>
		        <td  align="center"><%#Eval("fext_seq")%></td>
		        <td  align="center"><input type="button" class="cbutton" value="上傳" onClick="attach_file('<%#Eval("seq")%>','<%#Eval("seq1")%>','<%#Eval("country")%>')"></td>
	        </tr>
		</ItemTemplate>
    <FooterTemplate>
	        </tbody>
        </table>
        <br>
        <div id="divSign" style="display:none;text-align:center">
            <table border=0 class="bluetable"  cellspacing=1 cellpadding=2 width="100%">
	            <tr><td width="20%" class=lightbluetable3 align=right>新單位區所別：</td>
	                <td width="80%" class=whitetablebg>
			            <select name="tran_seq_branch" id="tran_seq_branch">
			                <%#html_tran_seq_branch%>
			            </select>
		            </td>	
                </tr>
                <tr><td width="20%" class=lightbluetable3 align=right>轉案說明：</td>
	                <td width="80%" class=whitetablebg><textarea rows=3 cols=60 id="tran_remark" name="tran_remark"></textarea></td>	
                </tr>
            </table> 
            <br>
            <table border="0" width="70%" cellspacing="1" cellpadding="0" align="center">
	            <TR>
		            <td >
                        <label>
                        <input type=radio name="usesign" id="usesignM" checked><strong>正常簽核:</strong>
		                <strong>直屬主管:</strong><%=mSC_name%><input type=hidden name=Msign id=Msign value="<%=mSC_code%>">
                        </label>
		            </td>
	            </TR>
                <TR>
		            <td >
                        <label>
                        <input type=radio name="usesign" id="usesignO"><strong>特殊處理:</strong>
                        </label>
		                <select id=selectsign name=selectsign class="<%=nToSelect%>">
			            <option value="" style="color:blue">請選擇主管</option><%=selSign%>
			            </select>
		            </td>	
	            </TR>
            </table>
            <input type=hidden id="GrpID" name="GrpID" value="<%=se_Grpid%>">
	        <input type=hidden id=signid name=signid>
            <br />
            <%#StrFormBtn%>
	        <BR>
        </div>
        <BR>
        <table border="0" width="100%" cellspacing="0" cellpadding="0">
		    <tr class="FormName"><td>
			    <div align="left" style="color:blue">
			        ※流程:<font color=red>原單位營洽轉案處理</font>-->原單位組主管簽核-->原單位部門主管簽核-->原單位區所主管簽核-->原單位程序轉案發文確認-->新單位主管確認轉案-->新單位程序確認轉案-->原單位程序轉案完成確認
			        <br>※<img src="<%=Page.ResolveUrl("~/images/star_pl.gif")%>" border=0>表主管曾退回，滑鼠移至本圖案，即會顯示主管退回原因。
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
        if("<%#mSC_name%>"!=""&&$("#dataList").is(':visible')) $("#divSign").show();
        $(".Lock").lock();
        $("input.dateField").datepick();
    }
    //////////////////////
    $("#sdate,#edate").blur(function (e){
        ChkDate(this);
    });

    $("#selectsign").click(function (e) {//特殊處理-請選擇主管
        $("#usesignO").prop("checked",true);
    })

    //案件主檔
    function CapplClick(x1,x2,x3) {
        var url = "";
        if (x3=="") {
            url=getRootPath() + "/brt5m/brt15ShowFP.aspx?prgid=<%=prgid%>&seq=" + x1 + "&seq1=" + x2 + "&submittask=Q";
        }else{
            //***todo
            url=getRootPath() + "/brt5m/ext54Edit.aspx?prgid=<%=prgid%>&seq=" + x1 + "&seq1=" + x2 + "&submittask=DQ";
        }
        //window.showModalDialog(url, "", "dialogHeight: 540px; dialogWidth: 800px; center: Yes;resizable: No; status: No;scrollbars:yes");
        $('#dialog').html('<iframe style="border: 0px;" src="' + url + '" width="100%" height="100%"></iframe>')
        .dialog({autoOpen: true,modal: true,height: 540,width: 900,title: "案件主檔"});
    }

    //案件進度查詢
    function QstepClick(pseq,pseq1,pcountry) {
        var url = "";
        if (pcountry=="") {
            url=getRootPath() + "/brtam/brta61_Edit.aspx?submitTask=Q&qtype=A&prgid=<%=prgid%>&closewin=Y&winact=1&aseq=" + pseq + "&aseq1=" + pseq1;
        }else{
            //***todo
            url=getRootPath() + "/brtam/exta61Edit.aspx?submitTask=Q&qtype=A&prgid=<%=prgid%>&closewin=Y&winact=1&aseq=" + pseq + "&aseq1=" + pseq1;
        }

        window.open(url, "myWindowOneN", "width=900 height=700 top=40 left=80 toolbar=no, menubar=no, location=no, directories=no resizeable=no status=no scrollbars=yes");
    }

    //[上傳]
    function attach_file(pseq,pseq1,pcountry){
        var url = getRootPath() + "/brt1m/brt1b_attach.aspx?prgid=<%#prgid%>&seq=" + pseq + "&seq1=" + pseq1 + "&country=" + pcountry+"&submittask=A";
        //window.open(url, "myWindowOneN", "width=900px, height=650px, top=10, left=10, toolbar=no, menubar=no, location=no, directories=no, status=no,resizable=yes, scrollbars=yes");
        $('#dialog').html('<iframe style="border: 0px;" src="' + url + '" width="100%" height="100%"></iframe>')
        .dialog({ autoOpen: true, modal: true, height: 540, width: "80%", title: "轉案文件上傳" });
    }

    //全選
    function selectall(){
        for (var j = 1; j <= CInt($("#row").val()) ; j++) {
            //沒有勾的觸發勾選
            if($("#chkflag_"+j).prop("checked")==false){
                $("#chkflag_"+j).click();
            }
        }
    }

    //確認
    function formSubmit(){
        $("#rows_chkflag,#rows_ctrl_sqlno,#rows_todo_sqlno,#rows_branch,#rows_seq,#rows_seq1,#rows_ctrlcnt,#rows_anncnt,#rows_oend_date,#rows_end_type,#rows_end_remark").val("");

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


        var totnum=$("input[id^='chkflag_']:checked").length;
        if (totnum==0){
            alert("請勾選您要轉案的案件!!");
            return false;
        }else{
            if ($("#signid").val()==""){
                alert("未選擇主管，無法送主管簽核，請檢查！！");
                return false;
            }

            if ($("#tran_seq_branch").val()==""){
                alert("請選擇新單位區所別！");
            return false;
            }

            if ($("#tran_remark").val()==""){
                var tans = confirm("尚未輸入轉案說明，是否輸入？");
                if (tans==true) {
                    $("#tran_remark").focus();
                    return false;
                }
            }

            var tans = confirm("共有" + totnum + "筆需要轉案並送主管簽核 , 是否確定?");
            if (tans ==false) return false;

            //串接資料
            $("#rows_chkflag").val(getJoinValue("#dataList>tbody input[id^='chkflag_']"));
            $("#rows_seq").val(getJoinValue("#dataList>tbody input[id^='seq_']"));
            $("#rows_seq1").val(getJoinValue("#dataList>tbody input[id^='seq1_']"));
            $("#rows_country").val(getJoinValue("#dataList>tbody input[id^='country_']"));
            $("#rows_scode").val(getJoinValue("#dataList>tbody input[id^='scode_']"));
            $("#rows_cust_area").val(getJoinValue("#dataList>tbody input[id^='cust_area_']"));
            $("#rows_cust_seq").val(getJoinValue("#dataList>tbody input[id^='cust_seq_']"));
            $("#rows_brtran_sqlno").val(getJoinValue("#dataList>tbody input[id^='brtran_sqlno_']"));
            $("#rows_todo_sqlno").val(getJoinValue("#dataList>tbody input[id^='todo_sqlno_']"));
            $("#qryjob_status").val($("input:radio[name='qryjob_status']:checked").val());

            $("input:disabled, select:disabled").unlock();
            $(".bsubmit").lock(!$("#chkTest").prop("checked"));

            var formData = new FormData($('#reg')[0]);
            ajaxByForm("Brt1b_Update.aspx",formData)
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
    }
</script>