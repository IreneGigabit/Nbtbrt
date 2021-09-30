<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<script runat="server">
    protected string HTProgCap = "程序確認轉案(轉入)";//HttpContext.Current.Request["prgname"];//功能名稱
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

    protected string qs_dept = "", seq_tblname = "", tran_tblnm = "", dept_nm = "";
    protected string html_qcust_area = "", html_qbranch = "";

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

        conn = new DBHelper(Conn.btbrt,false).Debug(Request["chkTest"] == "TEST");
        cnn = new DBHelper(Conn.Sysctrl).Debug(Request["chkTest"] == "TEST");

        qs_dept = (Request["qs_dept"] ?? "").ToLower();
        if (qs_dept == "t") {
            seq_tblname = "dmt";
            tran_tblnm = "dmt_brtran";
            dept_nm = "T";
        } else {
            seq_tblname = "ext";
            tran_tblnm = "ext_brtran";
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
        
        //原單位區所別
        SQL = "select distinct a.branch,(select branchname from sysctrl.dbo.branch_code where branch=a.branch) as branchname ";
        SQL += ",(select sort from sysctrl.dbo.branch_code where branch=a.branch) as sort  ";
        SQL += "from dmt_brtran a where a.tran_flag='B' and tran_seq is null  order by sort ";
        html_qcust_area = Util.Option(conn, SQL, "{branch}", "{branchname}", true, ReqVal.TryGet("qcust_area"));

        //新單位區所別
        html_qbranch = Util.Option(conn, SQL, "{branch}", "{branchname}", true, ReqVal.TryGet("qbranch"));
    }

    private void QueryData() {
        string wsql = "";
        if (ReqVal.TryGet("qseq") != "") {
            wsql += " and a.seq in (" + ReqVal["qseq"] + ")";
        }
        if (ReqVal.TryGet("qseq1") != "") {
            wsql += " and a.seq1='" + ReqVal["qseq1"] + "'";
        }
        if (ReqVal.TryGet("sdate") != "") {
            wsql += " and a.sc_date>='" + ReqVal["sdate"] + " 00:00:00' ";
        }
        if (ReqVal.TryGet("edate") != "") {
            wsql += " and a.sc_date<='" + ReqVal["edate"] + " 23:59:59' ";
        }
        if (ReqVal.TryGet("qscode") != "") {
            wsql += " and b.scode='" + ReqVal["qscode"] + "'";
        }
        if (ReqVal.TryGet("qcust_seq") != "") {
            wsql += " and  b.cust_seq='" + ReqVal["qcust_seq"] + "'";
        }
        if (ReqVal.TryGet("qtran_seq_branch") != "") {
            wsql += " and a.tran_seq_branch='" + ReqVal["qtran_seq_branch"] + "'";
        }

        if (qs_dept == "t") {
            SQL = "select a.*,c.sqlno as todo_sqlno ";
            SQL += ",(select sc_name from sysctrl.dbo.scode where scode = a.tran_scode1) as tran_scode_name ";
            SQL += ",(select branchname from sysctrl.dbo.branch_code where branch=a.branch) as branchname ";
            SQL += ",''fseq,''appl_name,''scode,''scode_name,''term1,''term2,''cust_name,''step_grade,''ap_cname,''id_no,''old_brtran_sqlno ";
            SQL += ",''urlasp1,''custz_flag,''custz_flag1,''urlasp1_str ";
            SQL += ",''urlasp2,''apcust_flag,''urlasp2_str ";
            SQL += " from dmt_brtran a ";
            SQL += " inner join todo_dmt c on a.brtran_sqlno=c.temp_rs_sqlno and c.dowhat='TRAN_ED' ";
        } else if (qs_dept == "e") {
            SQL = "select a.*,c.sqlno as todo_sqlno ";
            SQL += ",(select sc_name from sysctrl.dbo.scode where scode = a.tran_scode1) as tran_scode_name ";
            SQL += ",(select branchname from sysctrl.dbo.branch_code where branch=a.branch) as branchname ";
            SQL += ",''fseq,''appl_name,''scode,''scode_name,''term1,''term2,''cust_name,''step_grade,''ap_cname,''id_no,''old_brtran_sqlno ";
            SQL += ",''urlasp1,''custz_flag,''custz_flag1,''urlasp1_str ";
            SQL += ",''urlasp2,''apcust_flag,''urlasp2_str ";
            SQL += " from ext_brtran a ";
            SQL += " inner join todo_ext c on a.brtran_sqlno=c.att_no and c.dowhat='TRAN_ED' ";
        }
        SQL += " where c.job_status ='NN' " + wsql;

        ReqVal["qryOrder"] = ReqVal.TryGet("SetOrder", "a.cust_area,a.cust_seq");
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

            dr["seq"] = dr.SafeRead("seq", "");//trim掉
            dr["seq1"] = dr.SafeRead("seq1", "");//trim掉
            //案號
            if (dr.SafeRead("country", "") == "") {
                dr["fseq"] = Sys.formatSeq(dr.SafeRead("seq", ""), dr.SafeRead("seq1", ""), "", dr.SafeRead("branch", ""), Sys.GetSession("dept"));
            } else {
                dr["fseq"] = Sys.formatSeq(dr.SafeRead("seq", ""), dr.SafeRead("seq1", ""), dr.SafeRead("country", ""), dr.SafeRead("branch", ""), Sys.GetSession("dept") + "E");
            }

            SQL = "select a.appl_name,a.scode,a.term1,a.term2,a.step_grade,b.cust_name,b.ap_cname2,b.id_no,c.brtran_sqlno ";
            SQL += ",(SELECT sc_name FROM sysctrl.dbo.scode WHERE scode = a.scode) AS scode_name";
            SQL += " from " + seq_tblname + " a ";
            SQL += " inner join view_cust b on a.cust_area=b.cust_area and a.cust_seq=b.cust_seq ";
            SQL += " inner join " + seq_tblname + "_brtran c on a.seq=c.seq and a.seq1=c.seq1 and c.tran_flag='A' ";
            SQL += " where a.seq=" + dr["seq"] + " and a.seq1='" + dr["seq1"] + "'";
            using (DBHelper connbr = new DBHelper(Conn.brp(dr["branch"].ToString())).Debug(Request["chkTest"] == "TEST")) {
                using (SqlDataReader dr0 = connbr.ExecuteReader(SQL)) {
                    if (dr0.Read()) {
                        dr["appl_name"] = dr0.SafeRead("appl_name", "");
                        dr["scode"] = dr0.SafeRead("scode", "");
                        dr["term1"] = dr0.GetDateTimeString("term1", "yyyy/M/d");
                        dr["term2"] = dr0.GetDateTimeString("term2", "yyyy/M/d");
                        dr["step_grade"] = dr0.SafeRead("step_grade", "");
                        dr["cust_name"] = dr0.SafeRead("cust_name", "");
                        dr["ap_cname"] = dr0.SafeRead("cust_name", "") + dr0.SafeRead("ap_cname2", "");
                        dr["id_no"] = dr0.SafeRead("id_no", "");
                        dr["scode_name"] = dr0.SafeRead("scode_name", "");
                        dr["old_brtran_sqlno"] = dr0.SafeRead("brtran_sqlno", "");
                    }
                }
            }

            ChkCustz(dr);
            ChkAPCust(dr);
        }

        dataRepeater.DataSource = page.pagedTable;
        dataRepeater.DataBind();
    }

    //檢查客戶是否存在新區所
    protected void ChkCustz(DataRow dr) {
        string custz_flag = "N";//客戶是否已建檔
        string custz_flag1 = "N";//是否存在轉入區所
        string urlasp1_str = "";
        string urlasp1_Task = "";
        string cust_seq = "";
        string tran_cust_area = "";//新單位客戶區所別
        string tran_cust_seq = "";//新單位客戶編號

        if (dr.SafeRead("tran_cust_seq", "") != "") {
            urlasp1_str = "客戶查詢";
            urlasp1_Task = "Q";
            custz_flag = "Y";
            cust_seq = dr.SafeRead("tran_cust_seq", "");
            tran_cust_area = dr.SafeRead("tran_cust_area", "");
            tran_cust_seq = dr.SafeRead("tran_cust_seq", "");
        } else {
            SQL = "select cust_area,cust_seq from apcust where ap_cname1+isnull(ap_cname2,'')='" + dr.SafeRead("ap_cname","") + "'";
            DataTable dt1 = new DataTable();
            conn.DataTable(SQL, dt1);

            if (dt1.Rows.Count > 0) {
                if (dt1.Rows[0].SafeRead("cust_seq", "") != "") {
                    urlasp1_str = "客戶查詢";
                    urlasp1_Task = "Q";
                    custz_flag = "Y";
                    cust_seq = dt1.Rows[0].SafeRead("cust_seq", "");
                    tran_cust_area = dt1.Rows[0].SafeRead("cust_area", "");
                    tran_cust_seq = dt1.Rows[0].SafeRead("cust_seq", "");

                    SQL = "update " + tran_tblnm + " set tran_cust_seq=" + tran_cust_seq + ",tran_cust_area='" + tran_cust_area + "'";
                    SQL += " where brtran_sqlno='" + dr["brtran_sqlno"] + "'";
                    conn.ExecuteNonQuery(SQL);
                } else {
                    urlasp1_str = "轉客戶";
                    urlasp1_Task = "A";
                    tran_cust_seq = "";
                }
            } else {
                urlasp1_str = "新增客戶";
                urlasp1_Task = "A";
                tran_cust_seq = "";
                //2011/11/23增加判斷統編是否相同，因改制而更名，原區所未改但新區所已用改制後名稱建客戶及申請人，
                SQL = "select cust_area,cust_seq from apcust where apcust_no='" + dr.SafeRead("id_no","") + "'";
                DataTable dt2 = new DataTable();
                conn.DataTable(SQL, dt2);

                if (dt2.Rows.Count > 0) {
                    custz_flag1 = "Y";
                    if (dt2.Rows[0].SafeRead("cust_seq", "") != "") {
                        urlasp1_str = "客戶查詢";
                        urlasp1_Task = "Q";
                        custz_flag = "Y";
                        cust_seq = dt2.Rows[0].SafeRead("cust_seq", "");
                        tran_cust_area = dt2.Rows[0].SafeRead("cust_area", "");
                        tran_cust_seq = dt2.Rows[0].SafeRead("cust_seq", "");

                        SQL = "update " + tran_tblnm + " set tran_cust_seq=" + tran_cust_seq + ",tran_cust_area='" + tran_cust_area + "'";
                        SQL += " where brtran_sqlno='" + dr["brtran_sqlno"] + "'";
                        conn.ExecuteNonQuery(SQL);
                    } else {
                        urlasp1_str = "轉客戶";
                        urlasp1_Task = "A";
                        tran_cust_seq = "";
                    }
                }
            }
        }

        //連結客戶//***todo
        string urlasp1 = "/cust/cust11_mod.aspx?prgid=" + prgid + "&submitTask=A&tran_flag=B&modify=" + urlasp1_Task + "&attmodify=" + urlasp1_Task;
        urlasp1 += "&databr_branch=" + dr["branch"] + "&old_branch=" + Request["qbranch"];
        urlasp1 += "&scode1=" + dr["tran_scode1"] + "&scode1nm=" + dr["tran_scode_name"];
        urlasp1 += "&cust_area=" + dr["tran_cust_area"] + "&cust_seq=" + tran_cust_seq; //新單位
        urlasp1 += "&old_cust_area=" + dr["cust_area"] + "&old_cust_seq=" + dr["cust_seq"]; //原單位

        dr["urlasp1"] = Page.ResolveUrl("~" + urlasp1);
        dr["custz_flag"] = custz_flag;
        dr["custz_flag1"] = custz_flag1;
        dr["urlasp1_str"] = urlasp1_str;
        dr["tran_cust_seq"] = (tran_cust_seq == "" ? DBNull.Value : (object)Convert.ToInt32(tran_cust_seq));
   }


    //檢查案件申請人是否存在轉入區所申請人檔
    //檢查申請人是否存在
    protected void ChkAPCust(DataRow dr) {
        string urlasp2_str = "[無申請人]";
        int ap_num = 0;//已存在於申請人檔中的申請人數
        string apcust_flag = "N";//申請人是否已建檔

        if (qs_dept == "t") {
            SQL = "select apcust_no,ap_cname from dmt_ap ";
        } else if (qs_dept == "e") {
            SQL = "select apcust_no,rtrim(ap_cname1)+rtrim(ap_cname2) as ap_cname from ext_apcust ";
        }
        SQL += " where seq =" + dr.SafeRead("seq", "") + " and seq1='" + dr.SafeRead("seq1", "") + "'";
        using (DBHelper connbr = new DBHelper(Conn.brp(dr["branch"].ToString())).Debug(Request["chkTest"] == "TEST")) {
            using (SqlDataReader dr0 = connbr.ExecuteReader(SQL)) {
                if (dr0.HasRows) {
                    int tot_ap_num = 0;//本案的申請人數 
                    while (dr0.Read()) {
                        tot_ap_num++;
                        //檢查申請人是否存在
                        SQL = "select 1 as tot from apcust ";
                        SQL += " where (isnull(rtrim(ap_cname1),'')+isnull(rtrim(ap_cname2),'')='" + dr0.SafeRead("ap_cname", "") + "' or apcust_no='" + dr0.SafeRead("apcust_no", "") + "')";
                        ap_num += Convert.ToInt32(conn.getZero(SQL));
                    }

                    urlasp2_str = "[申請人(" + ap_num + "/" + tot_ap_num + ")]";
                    if (tot_ap_num == ap_num) apcust_flag = "Y";

                    //連結申請人
                    string urlasp2 = "/brtam/brta78_list_ap.aspx?prgid=" + prgid + "&submitTask=A&tran_flag=B&modify=";
                    urlasp2 += "&databr_branch=" + dr["branch"] + "&old_branch=" + Request["qbranch"];
                    urlasp2 += "&old_seq=" + dr.SafeRead("seq", "") + "&old_seq1=" + dr.SafeRead("seq1", "") + "&tablename=" + seq_tblname;
                    urlasp2 += "&qs_dept=" + qs_dept;
                    dr["urlasp2"] = Page.ResolveUrl("~" + urlasp2);

                    urlasp2_str = "<a href=\"" + Page.ResolveUrl("~" + urlasp2) + "\" target=\"Eblank\">" + urlasp2_str + "</a>";
                }
            }
        }
        dr["apcust_flag"] = apcust_flag;
        dr["urlasp2_str"] = urlasp2_str;
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
		    <td class="text9" width="50%">
		        ◎原單位通知轉案期間：
			    <input type="text" name="sdate" id="sdate" size="10" maxlength=10 class="dateField" value="<%#ReqVal.TryGet("sdate")%>">
                ~
			    <input type="text" name="edate" id="edate" size="10" maxlength=10 class="dateField" value="<%#ReqVal.TryGet("edate")%>">
		    </td>
		    <td class="text9">
		        ◎原單位客戶編號：<select id="qcust_area" name="qcust_area"><%#html_qcust_area%></SELECT>	
		        <input type="text" name="qcust_seq" id="qcust_seq" size=5 value="<%#ReqVal.TryGet("qcust_seq")%>"> 
		    </td>
	    </tr>
	    <tr>	
		    <td class="text9">
			    ◎原單位本所編號：
				    <INPUT type="text" name="qseq" id="qseq"size="50" maxlength="100" onblur="fseq_chk(this)" value="<%#ReqVal.TryGet("qseq")%>">-
				    <INPUT type="text" name="qseq1" id="qseq1" size="3" maxlength="3" value="<%#ReqVal.TryGet("qseq1")%>">
		    </td>
		    <td class="text9">	
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
    <input type=hidden id=branch name=branch> 
    <input type=hidden id=qs_dept name=qs_dept value="<%=qs_dept%>"> 
    <input type=hidden id=row name=row value="<%#page.pagedTable.Rows.Count%>"> 

    <asp:Repeater id="dataRepeater" runat="server">
    <HeaderTemplate>
        <table style="display:<%#page.totRow==0?"none":""%>" border="0" class="bluetable" cellspacing="1" cellpadding="2" width="100%" align="center" id="dataList">
	        <thead>
                  <Tr class="lightbluetable" align="center">
                    <td nowrap colspan=2>作業</td>
		            <td>原單位</td>
		            <td nowrap><u class="setOdr" v1="a.seq,a.seq1">原單位案件編號</u></td>
		            <td>原單位營洽</td>
		            <td>案件名稱</td>
		            <td><u class="setOdr" v1="a.cust_area,a.cust_seq">客戶名稱</u></td>
		            <td>專用期限</td>
		            <td>新營洽</td>
		            <td><u class="setOdr" v1="a.dc_date">轉案通知日</u></td>
		            <td>轉案原因</td>
	            </tr>
	        </thead>
	        <tbody>
    </HeaderTemplate>
		<ItemTemplate>
 	        <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>">
		        <td align='center'>
		            <a href="<%#Eval("urlasp1")%>" target="Eblank"><%#(Eval("custz_flag1").ToString()=="Y"?"<font color=red>*</font>":"")%>[<%#Eval("urlasp1_str")%>]</a>
			        <br>
			        <%#Eval("urlasp2_str")%>
		            <input type="hidden" id=old_brtran_sqlno_<%#(Container.ItemIndex+1)%> name=old_brtran_sqlno_<%#(Container.ItemIndex+1)%> value="<%#Eval("old_brtran_sqlno")%>"><!--原始單位轉案記錄流水號-->	
		            <input type="hidden" id=brtran_sqlno_<%#(Container.ItemIndex+1)%> name=brtran_sqlno_<%#(Container.ItemIndex+1)%> value="<%#Eval("brtran_sqlno")%>">
		            <input type="hidden" id=todo_sqlno_<%#(Container.ItemIndex+1)%> name=todo_sqlno_<%#(Container.ItemIndex+1)%> value="<%#Eval("todo_sqlno")%>">
		            <input type="hidden" id=seq_<%#(Container.ItemIndex+1)%> name=seq_<%#(Container.ItemIndex+1)%> value="<%#Eval("seq")%>">
		            <input type="hidden" id=seq1_<%#(Container.ItemIndex+1)%> name=seq1_<%#(Container.ItemIndex+1)%> value="<%#Eval("seq1")%>">
		            <input type="hidden" id=appl_name_<%#(Container.ItemIndex+1)%> name=appl_name_<%#(Container.ItemIndex+1)%> value="<%#Eval("appl_name")%>">
		            <input type="hidden" id=scode_<%#(Container.ItemIndex+1)%> name=scode_<%#(Container.ItemIndex+1)%> value="<%#Eval("scode")%>">
		            <input type="hidden" id=cust_seq_<%#(Container.ItemIndex+1)%> name=cust_seq_<%#(Container.ItemIndex+1)%> value="<%#Eval("cust_seq")%>">
		            <input type="hidden" id=cust_area_<%#(Container.ItemIndex+1)%> name=cust_area_<%#(Container.ItemIndex+1)%> value="<%#Eval("cust_area")%>">
		            <input type="hidden" id=cust_name_<%#(Container.ItemIndex+1)%> name=cust_name_<%#(Container.ItemIndex+1)%> value="<%#Eval("cust_name")%>">
	            </td>
		        <td nowrap align='center'>
			        [<a href="javascript:void(0);" onclick="linkedit('<%#(Container.ItemIndex+1)%>','<%#Eval("seq")%>','<%#Eval("seq1")%>','<%#Eval("brtran_sqlno")%>','<%#Eval("todo_sqlno")%>','<%#Eval("branch")%>','<%#Eval("tran_scode1")%>','<%#Eval("old_brtran_sqlno")%>','<%#Eval("custz_flag")%>','<%#Eval("apcust_flag")%>','<%#Eval("tran_cust_seq")%>','<%#Eval("dc_date")%>')">確認</a>]
		        </td>
		        <td align="center"><%#Eval("branchname")%></td>
		        <td nowrap align='center'>
		            <font style="cursor:pointer;" onmouseover="this.style.color='red'" onmouseout="this.style.color='black'" onclick="CapplClick('<%#Eval("seq")%>','<%#Eval("seq1")%>','<%#Eval("branch")%>')"><%#Eval("fseq")%></font>
		            <font style="cursor:pointer;" onmouseover="this.style.color='red'" onmouseout="this.style.color='black'" onclick="QstepClick('<%#Eval("seq")%>','<%#Eval("seq1")%>','<%#Eval("branch")%>')"><img src="<%=Page.ResolveUrl("~/images/annex.gif")%>"></font>
		        </td>
		        <td align="center" nowrap><%#Eval("scode_name")%></td>
		        <td align="left" title="<%#Eval("appl_name")%>"><%#Eval("appl_name").ToString().CutData(20)%></td>
		        <td align="left" title="<%#Eval("ap_cname")%>"><%#Eval("cust_area")%><%#Eval("cust_seq")%>&nbsp;<%#Eval("ap_cname").ToString().CutData(20)%></td>
	            <td align="center"><%#(Eval("term1").ToString()!=""?Eval("term1","{0:d}")+"~":"")%><%#Eval("term2","{0:d}")%></td>
		        <td align="center" nowrap><%#Eval("tran_scode_name")%></td>
		        <td align="center"><%#Eval("dc_date")%></td>
		        <td align="left"><%#Eval("tran_remark")%></td>
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
        <table border="0" width="100%" cellspacing="0" cellpadding="0">
		    <tr class="FormName"><td>
			    <div align="left" style="color:blue">
			        ※點原單位案件編號可查詢原單位案件主檔資料
			        <br>※點<img src="<%=Page.ResolveUrl("~/images/annex.gif")%>">可查詢原單位案件進度資料
			        <br>※[客戶查詢]前<font color=red>*</font>：表已存在於客戶檔，<font color=red>但客戶名稱與原單位客戶名稱不同，請注意</font>
			        <br>※申請人(n/m)：n表已存在於申請人檔中的申請人數，m表本案的申請人數
			        <br>※流程:營洽轉案處理-->組主管簽核-->部門主管簽核-->區所主管簽核-->程序轉案發文確認-->新單位主管確認轉案--><font color=red>新單位程序確認轉案</font>-->新單位程序轉案完成確認
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
        $(".Lock").lock();
        $("input.dateField").datepick();
    }
    //////////////////////
    $("#sdate,#edate").blur(function (e){
        ChkDate(this);
    });

    //檢查客戶及申請人已新增完成再連結到案件主檔立案
    function linkedit(pno,pseq,pseq1,pbrtran_sqlno,ptodo_sqlno,pbranch,ptran_scode1,pold_brtran_sqlno,pcustz_flag,papcust_flag,pcust_seq,ptran_seq_date){
        if (pcustz_flag=="N" || papcust_flag=="N"){
            alert("欲轉入原單位案件編號："+pseq+"-"+pseq1+"之客戶或申請人尚未建檔，無法確認！請先新增客戶主檔或申請人主檔，再執行轉案確認！");
            return false;
        }

        //2011/8/15增加檢查todo狀態，以免重覆轉案
        var searchSql="";
        if ($("#qs_dept").val()=="t"){
            searchSql="Select job_status from todo_dmt where sqlno='"+ ptodo_sqlno +"' ";
        }else{
            searchSql="Select job_status from todo_ext where sqlno='"+ ptodo_sqlno +"' ";
        }

        var errFlag=false;
        $.ajax({
            type: "get",
            url: getRootPath() + "/ajax/JsonGetSqlData.aspx",
            data: { sql: searchSql },
            async: false,
            cache: false,
            success: function (json) {
                var JSONdata = $.parseJSON(json);
                if (JSONdata.length == 0) {
                    errFlag = true;
                    alert("無本筆轉案(原單位案件編號：" + pseq + "-" +pseq1 + ")資料，請重新查詢！");
                } else {
                    if(JSONdata[0].job_status!="NN"){
                        alert("本筆轉案(原單位案件編號：" + pseq + "-" + pseq1 + ")已確認或轉案狀態已改變，無法執行確認，請回系統首頁，重新由確認轉案未處理清單進入！");
                    }
                }
            },
            error: function (xhr) { 
                $("#dialog").html("<a href='" + this.url + "' target='_new'>查詢案件編號載入失敗！<u>(點此顯示詳細訊息)</u></a><hr>" + xhr.responseText);
                $("#dialog").dialog({ title: '查詢案件編號載入失敗！', modal: true, maxHeight: 500, width: "90%" });
            }
        });

        if( errFlag) return false;
	
        var tlink="";
        if ($("#qs_dept").val()=="t"){
            tlink=getRootPath() + "/brt5m/Brt15ShowFP.aspx?submittask=A&prgid=<%=prgid%>&seq=" + pseq + "&seq1=" + pseq1 + "&brtran_sqlno=" + pbrtran_sqlno + "&todo_sqlno=" + ptodo_sqlno + "&branch=" + pbranch+ "&tran_scode1=" + ptran_scode1 + "&old_brtran_sqlno=" + pold_brtran_sqlno + "&cust_seq=" +pcust_seq + "&tran_seq_date=" + escape(ptran_seq_date);
        }else{
            //***todo
            tlink=getRootPath() + "/brt5m/ext54Edit.aspx?submittask=A&prgid=<%=prgid%>&branch=" + pbranch + "&seq=" + pseq + "&seq1=" + pseq1+ "&brtran_sqlno=" + pbrtran_sqlno + "&todo_sqlno=" + ptodo_sqlno + "&tran_scode1="+ ptran_scode1 + "&old_brtran_sqlno=" + pold_brtran_sqlno + "&cust_seq=" + pcust_seq + "&uploadtype=brtran&winact=1";
        }

        window.parent.Eblank.location.href = tlink;
    }

    //案件主檔
    function CapplClick(x1,x2,x3) {
        var url = "";
        if ($("#qs_dept").val()=="t") {
            url=getRootPath() + "/brt5m/brt15ShowFP.aspx?seq=" + x1 + "&seq1=" + x2 + "&submittask=Q&type=brtran&branch=" +x3;
        }else{
            //***todo
            url=getRootPath() + "/brt5m/ext54Edit.aspx?seq=" + x1 + "&seq1=" + x2 + "&submittask=DQ&type=brtran&branch=" +x3;
        }
        //window.showModalDialog(url, "", "dialogHeight: 540px; dialogWidth: 800px; center: Yes;resizable: No; status: No;scrollbars:yes");
        $('#dialog').html('<iframe style="border: 0px;" src="' + url + '" width="100%" height="100%"></iframe>')
        .dialog({autoOpen: true,modal: true,height: 540,width: 900,title: "案件主檔"});
    }

    //案件進度查詢
    function QstepClick(pseq,pseq1,x3) {
        var url = "";
        if ($("#qs_dept").val()=="t") {
            url=getRootPath() + "/brtam/brta61_Edit.aspx?submitTask=Q&qtype=A&prgid=<%=prgid%>&closewin=Y&winact=1&aseq=" + pseq + "&aseq1=" + pseq1+"&type=brtran&branch=" +x3;
        }else{
            //***todo
            url=getRootPath() + "/brtam/exta61Edit.aspx?submitTask=Q&qtype=A&prgid=<%=prgid%>&closewin=Y&winact=1&aseq=" + pseq + "&aseq1=" + pseq1+"&type=brtran&branch=" +x3;
        }

        window.open(url, "myWindowOneN", "width=900 height=700 top=40 left=80 toolbar=no, menubar=no, location=no, directories=no resizeable=no status=no scrollbars=yes");
    }
</script>