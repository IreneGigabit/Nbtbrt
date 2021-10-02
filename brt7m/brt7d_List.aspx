<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<script runat="server">
    protected string HTProgCap = "會計契約書檢核及查詢作業";//HttpContext.Current.Request["prgname"];//功能名稱
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

    protected string qryseq_type = "", qryacc_chk = "";
    protected string html_qscode = "",html_accback_code="";

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

        qryseq_type = ReqVal.TryGet("qryseq_type").ToUpper();
        if (qryseq_type == "") qryseq_type = Sys.GetSession("dept").ToUpper();
        qryacc_chk = ReqVal.TryGet("qryacc_chk");
        if (qryacc_chk == "") qryacc_chk = "N";
        
        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        HTProgCap = myToken.Title;
        HTProgCap += "-<font color=blue>收據</font>";
        DebugStr = myToken.DebugStr;
        if (HTProgRight >= 0) {
            PageLayout();
            QueryData();
            this.DataBind();
        }
    }

    private void PageLayout() {
        //退回原因
        html_accback_code = Sys.getCustCode("accback_code", "", "cust_code,sortfld").Option("{cust_code}", "{code_name}");
        
        StrFormBtnTop += "<a class=\"imgRefresh\" href=\"javascript:void(0);\" >[重新整理]</a>";
        if (qryacc_chk == "N") {
            if ((HTProgRight & 4) > 0 || (HTProgRight & 8) > 0) {
                StrFormBtn += "<table border=\"0\" class=greentable cellspacing=\"1\" cellpadding=\"2\" width=\"60%\" align=\"center\">\n";
                StrFormBtn += "    <tr class=\"greenths\">\n";
                StrFormBtn += "		<td class=greentext rowspan=2><font color=red>退回原因：</font></td>\n";
                StrFormBtn += "		<td class=whitetablebg>\n";
                StrFormBtn += "			<Select id=\"accback_code\" name=\"accback_code\" onchange=\"showback_remark()\">\n";
                StrFormBtn += html_accback_code;
                StrFormBtn += "		    </select>\n";
                StrFormBtn += "		</td>\n";
                StrFormBtn += "    </tr>\n";
                StrFormBtn += "	<tr >\n";
                StrFormBtn += "		<td class=\"whitetablebg\"><input type=\"text\" id=\"back_remark\" name=\"back_remark\" size=60 maxlength=100></td>\n";
                StrFormBtn += "	</tr>\n";
                StrFormBtn += "</table>\n";
                StrFormBtn += "<br>\n";
                StrFormBtn += "<input type=button value ='確　認' class='cbutton bsubmit' onclick='formSubmit()'>\n";
                StrFormBtn += "<input type=button value ='退　回' class='redbutton bsubmit' onclick='formBack()'>\n";
                StrFormBtn += "<input type=button value ='重　填' class='cbutton' onclick='this_init()'>\n";
            }
        }

        //案件營洽
        SQL = "select distinct scode,sc_name,scode1 from vscode_roles ";
        SQL += " where branch='" + Session["SeBranch"] + "' and dept='" + Session["Dept"] + "' and syscode='" + Session["syscode"] + "' and roles='sales'";
        SQL += " order by scode1 ";
        html_qscode = Util.Option(cnn, SQL, "{scode}", "{scode}_{sc_name}", true, Sys.GetSession("scode"));
        html_qscode += "<option value='" + Sys.GetSession("seBranch") + "t'>" + Sys.GetSession("seBranch") + "t_部門(開放客戶)</option>";
    }

    private void QueryData() {
        if (qryseq_type == "T") {
            //2016/1/30契約書檢核改為todo，但之前無todo，所以用檢核狀態區分抓取sql
            if (qryacc_chk == "Y") {
                SQL = "SELECT 0 as todo_sqlno,b.seq,b.seq1,b.in_no,B.In_scode, B.case_no,F.cust_name,'T' as country,C.appl_name, B.service, B.fees ,B.add_service,B.add_fees ";
                SQL += ",isnull(B.oth_money,0) as tr_money,B.arcase,B.arcase_type ";
                SQL += ",B.ar_service,B.ar_fees,B.Service + B.Fees+isnull(b.oth_money,0)+isnull(b.add_service,0)+isnull(b.add_fees,0) AS allcost,B.ar_mark,B.case_date,B.contract_no ";
                SQL += ",(select Rs_detail from code_br where rs_code=b.arcase and cr='Y' and rs_type=b.arcase_type) as CArcase ";
                SQL += ",(select rs_class  from code_br where rs_code=b.arcase and cr='Y' and rs_type=b.arcase_type) as ar_form ";
                SQL += ",(select sc_name from sysctrl.dbo.scode where scode=b.in_scode) as sc_name ";
                SQL += ",B.arcase_class as prt_code,b.case_stat,b.change ";
                SQL += ",B.Cust_area, B.Cust_seq,b.acc_chk,b.acc_chkdate,d.step_grade,d.step_date,d.rs_no,d.rs_sqlno,F.tspay_flag as old_spay_flag,F.cust_apsqlno ";
                SQL += ",isnull((select count(*) from dmt_attach where in_no=b.in_no and step_grade=d.step_grade),0) as attach_num ";
                SQL += ",isnull((select count(*) from dmt_attach where in_no=b.in_no and step_grade=d.step_grade and doc_type='S01'),0) as spay_attach_num ";
                SQL += ",''fseq,''tdisabled,''strstat_code,''docchecked,''spaychecked,''strcontract_no,''strcase_stat,''mailto,''urlasp ";
                SQL += "FROM Case_dmt B ";
                SQL += "INNER JOIN dmt_temp C ON B.In_scode = C.in_scode and B.In_no = C.in_no AND  c.case_sqlno=0 ";
                SQL += "inner join step_dmt D on  b.seq=d.seq and b.seq1=d.seq1 and d.cg='C' and d.rs='R' and B.case_no = D.case_no ";
                SQL += "INNER JOIN view_cust F on F.cust_area = B.cust_area and F.cust_seq=B.cust_seq ";
                SQL += "WHERE B.stat_code = 'YZ'  and (B.mark='N' or B.mark is null) and b.acc_chk='" + qryacc_chk + "' and b.acc_chkdate is not null ";
            } else {
                SQL = "SELECT t.sqlno as todo_sqlno,b.seq,b.seq1,b.in_no,B.In_scode, B.case_no,F.cust_name,'T' as country,C.appl_name, B.service, B.fees ,B.add_service,B.add_fees ";
                SQL += ", isnull(B.oth_money,0) as tr_money,B.arcase,B.arcase_type ";
                SQL += ",B.ar_service,B.ar_fees,B.Service + B.Fees+isnull(b.oth_money,0)+isnull(b.add_service,0)+isnull(b.add_fees,0) AS allcost,B.ar_mark,B.case_date,B.contract_no ";
                SQL += ",(select Rs_detail from code_br where rs_code=b.arcase and cr='Y' and rs_type=b.arcase_type) as CArcase ";
                SQL += ",(select rs_class  from code_br where rs_code=b.arcase and cr='Y' and rs_type=b.arcase_type) as ar_form ";
                SQL += ",(select sc_name from sysctrl.dbo.scode where scode=b.in_scode) as sc_name ";
                SQL += ",B.arcase_class as prt_code,b.case_stat,b.change ";
                SQL += ",B.Cust_area, B.Cust_seq,b.acc_chk,b.acc_chkdate,d.step_grade,d.step_date,d.rs_no,d.rs_sqlno,F.tspay_flag as old_spay_flag,F.cust_apsqlno ";
                SQL += ",isnull((select count(*) from dmt_attach where in_no=b.in_no and step_grade=d.step_grade),0) as attach_num ";
                SQL += ",isnull((select count(*) from dmt_attach where in_no=b.in_no and step_grade=d.step_grade and doc_type='S01'),0) as spay_attach_num ";
                SQL += ",''fseq,''tdisabled,''strstat_code,''docchecked,''spaychecked,''strcontract_no,''strcase_stat,''mailto,''urlasp ";
                SQL += "FROM todo_dmt t ";
                SQL += "inner join Case_dmt B on t.in_no=b.in_no ";
                SQL += "INNER JOIN dmt_temp C ON B.In_scode = C.in_scode and B.In_no = C.in_no AND  c.case_sqlno=0 ";
                SQL += "inner join step_dmt D on  b.seq=d.seq and b.seq1=d.seq1 and d.cg='C' and d.rs='R' and B.case_no = D.case_no ";
                SQL += "INNER JOIN view_cust F on F.cust_area = B.cust_area and F.cust_seq=B.cust_seq ";
                SQL += "WHERE t.syscode='" + Session["syscode"] + "' and (t.apcode='brt51' or t.apcode='brt25' or t.apcode='acc31at') and t.dowhat='contractA' and t.job_status='NN' ";
            }
        } else if (qryseq_type == "TE") {
            if (qryacc_chk == "Y") {
                SQL = "SELECT 0 as todo_sqlno, b.seq,b.seq1,b.in_no,B.In_scode, B.case_no,F.cust_name,C.country,C.appl_name, B.tot_Service as service, B.tot_Fees as fees ,B.add_service,B.add_fees ";
                SQL += ",isnull(B.oth_money,0) as tr_money,B.arcase,B.arcase_type ";
                SQL += ",B.ar_service,B.ar_fees,B.tot_Service + B.tot_Fees+isnull(b.oth_money,0)+isnull(b.add_service,0)+isnull(b.add_fees,0) AS allcost,B.ar_mark,B.case_date,B.contract_no ";
                SQL += ",(select Rs_detail from code_ext where rs_code=b.arcase and cr_flag='Y' and rs_type=b.arcase_type) as CArcase ";
                SQL += ",(select rs_class  from code_ext where rs_code=b.arcase and cr_flag='Y' and rs_type=b.arcase_type) as ar_form ";
                SQL += ",(select sc_name from sysctrl.dbo.scode where scode=b.in_scode) as sc_name ";
                SQL += ",B.arcase_class as prt_code,b.case_stat,b.change ";
                SQL += ",B.Cust_area, B.Cust_seq,b.acc_chk,b.acc_chkdate,d.step_grade,d.step_date,d.step_grade,d.rs_no,d.rs_sqlno,F.tspay_flag as old_spay_flag,F.cust_apsqlno ";
                SQL += ",isnull((select count(*) from caseattach_ext where in_no=b.in_no),0) as attach_num ";
                SQL += ",isnull((select count(*) from caseattach_ext where in_no=b.in_no and doc_type='S01'),0) as spay_attach_num ";
                SQL += ",''fseq,''tdisabled,''strstat_code,''docchecked,''spaychecked,''strcontract_no,''strcase_stat,''mailto,''urlasp ";
                SQL += "FROM Case_ext B ";
                SQL += "INNER JOIN ext_temp C ON B.In_scode = C.in_scode and B.In_no = C.in_no AND  c.case_sqlno=0 ";
                SQL += "inner join step_ext D on B.case_no = D.case_no and b.seq=d.seq and b.seq1=d.seq1 and d.cg='C' and d.rs='R' ";
                SQL += "INNER JOIN view_cust F on F.cust_area = B.cust_area and F.cust_seq=B.cust_seq ";
                SQL += "WHERE B.invoice_chk='B' and (B.stat_code = 'YZ' or B.stat_code like 'S%')  and (B.mark='N' or B.mark is null) ";
            } else {
                SQL = "SELECT t.sqlno as todo_sqlno,b.seq,b.seq1,b.in_no,B.In_scode, B.case_no,F.cust_name,C.country,C.appl_name, B.tot_Service as service, B.tot_Fees as fees ,B.add_service,B.add_fees ";
                SQL += ",isnull(B.oth_money,0) as tr_money,B.arcase,B.arcase_type ";
                SQL += ",B.ar_service,B.ar_fees,B.tot_Service + B.tot_Fees+isnull(b.oth_money,0)+isnull(b.add_service,0)+isnull(b.add_fees,0) AS allcost,B.ar_mark,B.case_date,B.contract_no ";
                SQL += ",(select Rs_detail from code_ext where rs_code=b.arcase and cr_flag='Y' and rs_type=b.arcase_type) as CArcase ";
                SQL += ",(select rs_class  from code_ext where rs_code=b.arcase and cr_flag='Y' and rs_type=b.arcase_type) as ar_form ";
                SQL += ",(select sc_name from sysctrl.dbo.scode where scode=b.in_scode) as sc_name ";
                SQL += ",B.arcase_class as prt_code,b.case_stat,b.change ";
                SQL += ",B.Cust_area, B.Cust_seq,b.acc_chk,b.acc_chkdate,d.step_grade,d.step_date,d.step_grade,d.rs_no,d.rs_sqlno,F.tspay_flag as old_spay_flag,F.cust_apsqlno ";
                SQL += ",isnull((select count(*) from caseattach_ext where in_no=b.in_no),0) as attach_num ";
                SQL += ",isnull((select count(*) from caseattach_ext where in_no=b.in_no and doc_type='S01'),0) as spay_attach_num ";
                SQL += ",''fseq,''tdisabled,''strstat_code,''docchecked,''spaychecked,''strcontract_no,''strcase_stat,''mailto,''urlasp ";
                SQL += "FROM todo_ext t ";
                SQL += "inner join  Case_ext B on t.in_no=b.in_no and b.invoice_chk='B' ";
                SQL += "INNER JOIN ext_temp C ON B.In_scode = C.in_scode and B.In_no = C.in_no AND  c.case_sqlno=0 ";
                SQL += "inner join step_ext D on  b.seq=d.seq and b.seq1=d.seq1 and d.cg='C' and d.rs='R' and B.case_no = D.case_no ";
                SQL += "INNER JOIN view_cust F on F.cust_area = B.cust_area and F.cust_seq=B.cust_seq ";
                SQL += "WHERE t.syscode='" + Session["syscode"] + "' and (t.apcode='ext51' or t.apcode='ext25' or t.apcode='acc31at') and t.dowhat='contractA' and t.job_status='NN' ";
            }
        }

        if (ReqVal.TryGet("qrySeq") != "") {
            SQL += " and b.seq in ('" + ReqVal.TryGet("qrySeq").Replace(",", "','") + "')";
        }
        if (ReqVal.TryGet("qrySeq1") != "") {
            SQL += " and b.seq1='" + ReqVal["qrySeq1"] + "'";
        }
        if (ReqVal.TryGet("qryscode") != "") {
            SQL += " and b.in_scode='" + ReqVal["qryscode"] + "'";
        }
        if (ReqVal.TryGet("qrybcase_date") != "") {
            SQL += " and b.case_date>='" + ReqVal["qrybcase_date"] + " 00:00:00' ";
        }
        if (ReqVal.TryGet("qryecase_date") != "") {
            SQL += " and b.case_date <='" + ReqVal["qryecase_date"] + " 23:59:59' ";
        }
        if (ReqVal.TryGet("qrycust_seq") != "") {
            SQL += " and b.cust_seq='" + ReqVal["qrycust_seq"] + "'";
        }
        if (ReqVal.TryGet("qrycontract_no") != "") {
            SQL += " and b.contract_no like '%" + ReqVal["qrycontract_no"] + "%' ";
        }
        if (ReqVal.TryGet("qrycase_stat") != "*") {
            if (ReqVal.TryGet("qrycase_stat") == "N") {
                SQL += " and left(b.case_stat,1) in ('N','S','Z')";
            } else if (ReqVal.TryGet("qrycase_stat") == "O") {
                SQL += " and left(b.case_stat,1) = 'O'";
            }
        }
        if (ReqVal.TryGet("qrybstep_date") != "") {
            SQL += " and d.step_date>='" + ReqVal["qrybstep_date"] + " 00:00:00' ";
        }
        if (ReqVal.TryGet("qryestep_date") != "") {
            SQL += " and d.step_date<='" + ReqVal["qryestep_date"] + " 23:59:59' ";
        }

        ReqVal["qryOrder"] = ReqVal.TryGet("SetOrder", "d.step_date desc,F.cust_name");
        if (ReqVal.TryGet("qryOrder") != "") {
            SQL += " order by " + ReqVal.TryGet("qryOrder");
        }
        DataTable dt = new DataTable();
        conn.DataTable(SQL, dt);
        Sys.showLog(SQL);

        //處理分頁
        int nowPage = Convert.ToInt32(Request["GoPage"] ?? "1"); //第幾頁
        int PerPageSize = Convert.ToInt32(Request["PerPage"] ?? "30"); //每頁筆數
        page = new Paging(nowPage, PerPageSize, SQL);
        page.GetPagedTable(dt);

        //分頁完再處理其他資料才不會虛耗資源
        for (int i = 0; i < page.pagedTable.Rows.Count; i++) {
            DataRow dr = page.pagedTable.Rows[i];

            //案號
            dr["fseq"] = Sys.formatSeq(dr.SafeRead("seq", ""), dr.SafeRead("seq1", ""), dr.SafeRead("country", ""), Sys.GetSession("seBranch"), qryseq_type);

            if (dr.SafeRead("acc_chk", "") == "Y") {
                dr["docchecked"] = " checked ";//確認檢核
                if (dr.SafeRead("old_spay_flag", "") == "Y") {//客戶主檔\商標專案付款條件
                    dr["spaychecked"] = " checked ";//專案付款條件
                }
            }
            
            //契約書編號
            if (dr.SafeRead("contract_no", "") != "") {
                if (dr.SafeRead("contract_no", "").IN("A,B,C") == false) {
                    dr["strcontract_no"] = "<font color=red>(" + dr["contract_no"] + ")</font>";
                }
            }
            
            //新舊案判斷
            if (dr.SafeRead("case_stat", "").Left(1).IN("N,S,Z") == true) {
                dr["strcase_stat"] = "<font color=red>*</font>";

            }
            
		    //增加判斷交辦案件是否異動中，因異動後可能要重新檢核或交辦註銷不需檢核，所以，先暫緩處理。
            if (dr.SafeRead("change", "") == "Y") {
		        dr["tdisabled"]=" disabled ";
                dr["strstat_code"] = "<font color=red>異動請核中</font>";
		    }
            
            //交辦畫面連結,email程序人員
            string urlasp = "";
            string mailto = dr["in_scode"]+";";
            
            if (qryseq_type == "T") {
                mailto += Sys.getCodeName(conn, "sysctrl.dbo.scode_group", "scode", "where grpclass='" + Session["seBranch"] + "' and grpid='T210' and grptype='F'");
                urlasp = Sys.getCaseDmt11Aspx(prgid, dr.SafeRead("in_no", ""), dr.SafeRead("in_scode", ""), "Show");
            } else {
                mailto += Sys.getCodeName(conn, "sysctrl.dbo.scode_group", "scode", "where grpclass='" + Session["seBranch"] + "' and grpid='T220' and grptype='F'");
                urlasp = Sys.getCaseExt11Aspx(prgid, dr.SafeRead("in_no", ""), dr.SafeRead("in_scode", ""), "Show");
            }
            dr["urlasp"] = urlasp;
            dr["mailto"] = mailto;
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
	        <td class="text9">
		        ◎作業案件：<label><input type=radio name="qryseq_type" <%#qryseq_type=="T"?"checked":""%> value="T">國內案</label>
		                  <label><input type=radio name="qryseq_type" <%#qryseq_type=="TE"?"checked":""%> value="TE" disabled>出口案</label><!--***todo出口案-->
	        </td>
        </tr>
        <tr>
	        <td class="text9">
		        ◎確認狀態: <label><input type="radio" name="qryacc_chk" value="N" <%#qryacc_chk=="N"?"checked":""%>>未確認</label>
		                  <label><input type="radio" name="qryacc_chk" value="Y" <%#qryacc_chk=="Y"?"checked":""%>>已確認</label>
	        </td>
	        <td class="text9">
		        ◎洽案營洽 :<select id="qryscode" name="qryscode"><%#html_qscode%></SELECT>
	        </td>
	        <td class="text9">
		        ◎本所編號:<input type="text" id="qrySeq" name="qrySeq" size="30" value="<%#ReqVal.TryGet("qrySeq")%>" onblur="fseq_chk(this)">-<input type="text" id="qrySeq1" name="qrySeq1" size="2" value="<%#ReqVal.TryGet("qrySeq1")%>">
	        </td>
	        <td class="text9">
		        <input type="button" value="查詢" class="cbutton" onClick="goSearch()" id=button1 name=button1>
	        </td>
        </tr>	
        <tr>
	        <td class="text9"  >
		        ◎案件種類：<label><input type=radio name="qrycase_stat" <%#ReqVal.TryGet("qrycase_stat")=="N"?"checked":""%> value="N">新案(契約書)</label>
		                  <label><input type=radio name="qrycase_stat" <%#ReqVal.TryGet("qrycase_stat")=="O"?"checked":""%> value="O">舊案(確認函)</label>
		                  <label><input type=radio name="qrycase_stat" <%#ReqVal.TryGet("qrycase_stat","*")=="*"?"checked":""%> value="*">不指定</label>
	        </td>
	        <td class="text9">
		        ◎客戶編號:<%#Session["seBranch"]%>-<input type="text" id="qrycust_Seq" name="qrycust_Seq" size="5" value="<%#ReqVal.TryGet("qrycust_Seq")%>" >
	        </td>
	        <td class="text9">
		        ◎契約書號:<input type="text" id="qrycontract_no" name="qrycontract_no" size="10" value="<%#ReqVal.TryGet("qrycontract_no")%>" >
	        </td>
            <td class="text9">
		        ◎客收確認日:
                <input type="text" name="qrybstep_date" id="qrybstep_date" size=10 value="<%#ReqVal.TryGet("qrybstep_date")%>" class="dateField">~
		        <input type="text" name="qryestep_date" id="qryestep_date" size=10 value="<%#ReqVal.TryGet("qryestep_date")%>" class="dateField">
	        </td>
        </tr>
    </table>
    <%if(qryacc_chk=="N"){%>
         <BR>
        <table border="0" width="100%" cellspacing="0" cellpadding="0">
		    <tr class="FormName">
			    <td align="left">
			    檢核步驟:<br>
			    1.請先點選「檢核文件」，需檢核完畢才能點選「確認」。<br>
			    ※備註：<br>1.「檢核文件」括號中的件數表有上傳文件的筆數，當筆數為0，請直接通知程序至「國內案/出口案交辦維護作業」將所需文件上傳。<br>
			                2.「客收確認日」括號中的內容表契約書號，<font color=red>*</font>表新立案。
		        </td>
            </tr>
	    </table>    
    <%}%>

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
    <input type="hidden" id=row name=row value="<%#page.pagedTable.Rows.Count%>"> 
    <input type="hidden" id=qryseq_type name=qryseq_type> 
    <INPUT type="hidden" id="rows_chkflag" name="rows_chkflag" />
	<input type="hidden" id="rows_in_scode" name="rows_in_scode" />
	<input type="hidden" id="rows_in_no" name="rows_in_no" />
	<input type="hidden" id="rows_case_no" name="rows_case_no" />
	<input type="hidden" id="rows_seq" name="rows_seq" />
	<input type="hidden" id="rows_seq1" name="rows_seq1" />
	<input type="hidden" id="rows_country" name="rows_country" />
	<input type="hidden" id="rows_cust_area" name="rows_cust_area" />
	<input type="hidden" id="rows_cust_seq" name="rows_cust_seq" />
	<input type="hidden" id="rows_old_spay_flag" name="rows_old_spay_flag" />
	<input type="hidden" id="rows_cust_apsqlno" name="rows_cust_apsqlno" />
	<input type="hidden" id="rows_todo_sqlno" name="rows_todo_sqlno" /><!--2016/1/30契約書檢核todo流水號-->
	<input type="hidden" id="rows_step_grade" name="rows_step_grade" /><!--2016/1/30客收進度-->
	<input type="hidden" id="rows_rs_no" name="rows_rs_no" /><!--2016/1/30客收進度收文字號-->
	<input type="hidden" id="rows_rs_sqlno" name="rows_rs_sqlno" /><!--2016/1/30客收進度流水號-->
	<input type="hidden" id="rows_sc_name" name="rows_sc_name" /><!--2016/1/30營洽姓名-->
	<input type="hidden" id="rows_appl_name" name="rows_appl_name" /><!--2016/1/30案件名稱-->
    <input type="hidden" id="rows_attach_num" name="rows_attach_num" /><!--檢核文件(n)-->
	<input type="hidden" id="rows_spay_attach_num" name="rows_spay_attach_num" /><!--專案付款條件請核單,doc_type='S01'-->
	<input type="hidden" id="rows_view_flag" name="rows_view_flag" /><!--有無按[檢核文件]-->
	<input type="hidden" id="rows_chkdoc" name="rows_chkdoc" /><!--☐確認檢核-->
	<input type="hidden" id="rows_chkspay_flag" name="rows_chkspay_flag" /><!--☐專案付款條件-->

    <asp:Repeater id="dataRepeater" runat="server">
    <HeaderTemplate>
        <table style="display:<%#page.totRow==0?"none":""%>" border="0" class="bluetable" cellspacing="1" cellpadding="2" width="100%" align="center" id="dataList">
	        <thead>
                <Tr class="lightbluetable" align="center">
                    <%if (qryacc_chk=="N"){%>
	                <td nowrap>確認</td> 
	                <%}else if (qryacc_chk=="Y"){%>
	                <td nowrap>確認日期</td>   
	                <%}%>
	                <td width="10%">上傳文件</td>    
	                <td width="10%">客戶名稱</td>    
	                <td width="10%">客收確認日</td>  
  	                <td width="8%">案件<br>編號</td>
  	                <td width="6%">營洽</td>
  	                <td width="12%">案件名稱</td>
	                <td width="8%">案性</td>
	                <td width="8%">服務費</td>
	                <td width="8%">規費</td>
	                <td width="8%">轉帳<br>費用</td>
	                <td width="8%">合計</td>
                </tr>
	        </thead>
	        <tbody>
    </HeaderTemplate>
		<ItemTemplate>
 	        <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>">
                <%if (qryacc_chk=="N"){%>
		        <td align="center">
			        <input type="checkbox" id=chkflag_<%#(Container.ItemIndex+1)%> value="Y" onclick="chkflagClick('<%#(Container.ItemIndex+1)%>')" <%#Eval("tdisabled")%>><!--2016/2/1修改，因增加退回功能，開放勾選-->	
		            <br><%#Eval("strstat_code")%>
			        <input type=hidden id="in_scode_<%#(Container.ItemIndex+1)%>" value="<%#Eval("in_scode")%>">
			        <input type=hidden id="in_no_<%#(Container.ItemIndex+1)%>" value="<%#Eval("in_no")%>">
			        <input type=hidden id="case_no_<%#(Container.ItemIndex+1)%>" value="<%#Eval("case_no")%>">
			        <input type=hidden id="seq_<%#(Container.ItemIndex+1)%>" value="<%#Eval("seq")%>">
			        <input type=hidden id="seq1_<%#(Container.ItemIndex+1)%>" value="<%#Eval("seq1")%>">
			        <input type=hidden id="country_<%#(Container.ItemIndex+1)%>" value="<%#Eval("country")%>">
			        <input type=hidden id="cust_area_<%#(Container.ItemIndex+1)%>" value="<%#Eval("cust_area")%>">
			        <input type=hidden id="cust_seq_<%#(Container.ItemIndex+1)%>" value="<%#Eval("cust_seq")%>">
			        <input type=hidden id="old_spay_flag_<%#(Container.ItemIndex+1)%>" value="<%#Eval("old_spay_flag")%>">
			        <input type=hidden id="cust_apsqlno_<%#(Container.ItemIndex+1)%>" value="<%#Eval("cust_apsqlno")%>">
			        <input type=hidden id="todo_sqlno_<%#(Container.ItemIndex+1)%>" value="<%#Eval("todo_sqlno")%>"><!--2016/1/30契約書檢核todo流水號-->
			        <input type=hidden id="step_grade_<%#(Container.ItemIndex+1)%>" value="<%#Eval("step_grade")%>"><!--2016/1/30客收進度-->
			        <input type=hidden id="rs_no_<%#(Container.ItemIndex+1)%>" value="<%#Eval("rs_no")%>"><!--2016/1/30客收進度收文字號-->
			        <input type=hidden id="rs_sqlno_<%#(Container.ItemIndex+1)%>" value="<%#Eval("rs_sqlno")%>"><!--2016/1/30客收進度流水號-->
			        <input type=hidden id="sc_name_<%#(Container.ItemIndex+1)%>" value="<%#Eval("sc_name")%>"><!--2016/1/30營洽姓名-->
			        <input type=hidden id="appl_name_<%#(Container.ItemIndex+1)%>" value="<%#Eval("appl_name")%>"><!--2016/1/30案件名稱-->
			        <input type=hidden id="urlasp_<%#(Container.ItemIndex+1)%>" value="<%#Eval("urlasp")%>">
		        </td>
	            <%}else if (qryacc_chk=="Y"){%>
		        <td><%#Eval("acc_chkdate")%></td>
	            <%}%>
		        <td nowrap>
		            <input type=hidden id="attach_num_<%#(Container.ItemIndex+1)%>" value="<%#Eval("attach_num")%>"><!--檢核文件(n)-->
		            <input type=hidden id="spay_attach_num_<%#(Container.ItemIndex+1)%>" value="<%#Eval("spay_attach_num")%>"><!--專案付款條件請核單,doc_type='S01'-->
		            <input type=hidden id="view_flag_<%#(Container.ItemIndex+1)%>" value="N"><!--有無按[檢核文件]-->
			        <input type=checkbox id="chkdoc_<%#(Container.ItemIndex+1)%>" value="Y" onclick="doc_chk('<%#(Container.ItemIndex+1)%>')" <%#Eval("docchecked")%> <%#Eval("tdisabled")%>>確認檢核
                    <img src="<%=Page.ResolveUrl("~/images/email01.gif")%>" style="cursor:pointer" title="Email通知營洽" align="absmiddle" border="0" onClick="show_email('<%#Eval("fseq")%>','<%#Eval("appl_name")%>',<%#Eval("in_no")%>,'<%#Eval("case_no")%>','<%#Eval("mailto")%>')"><br>
			        <input type=checkbox id="chkspay_flag_<%#(Container.ItemIndex+1)%>" value="Y" onclick="spay_flag_chk('<%#(Container.ItemIndex+1)%>')" disabled <%#Eval("spaychecked")%>>專案付款條件
			        <br /><input type=button class="cbutton" id="btnview_<%#(Container.ItemIndex+1)%>" value="檢核文件(<%#Eval("attach_num")%>)" onclick="view_attach('<%#(Container.ItemIndex+1)%>')">
		        </td>
		        <td><p align="center"><a href="javascript:void(0)" onclick="ShowCase('<%#(Container.ItemIndex+1)%>')"><%#Eval("cust_name")%></a></td>
		        <td><p align="center"><a href="javascript:void(0)" onclick="ShowCase('<%#(Container.ItemIndex+1)%>')"><%#Eval("step_date","{0:d}")%><%#Eval("strcontract_no")%><%#Eval("strcase_stat")%></a></td>
		        <td><p align="center"><a href="javascript:void(0)" onclick="ShowCase('<%#(Container.ItemIndex+1)%>')"><%#Eval("fseq")%></a></td>	
		        <td><p align="center"><a href="javascript:void(0)" onclick="ShowCase('<%#(Container.ItemIndex+1)%>')"><%#Eval("sc_name")%></a></td>	
		        <td><p align="center"><a href="javascript:void(0)" onclick="ShowCase('<%#(Container.ItemIndex+1)%>')"><%#Eval("appl_name").ToString().Left(20)%></a></td>
		        <td><p align="center"><a href="javascript:void(0)" onclick="ShowCase('<%#(Container.ItemIndex+1)%>')"><%#Eval("CArcase")%></a></td>
		        <td><p align="center"><a href="javascript:void(0)" onclick="ShowCase('<%#(Container.ItemIndex+1)%>')"><%#Eval("service")%><%#(Convert.ToInt32(Eval("add_service")) > 0 ?"<font color=red>*</font>":"")%></a></td>
		        <td><p align="center"><a href="javascript:void(0)" onclick="ShowCase('<%#(Container.ItemIndex+1)%>')"><%#Eval("fees")%><%#(Convert.ToInt32(Eval("add_fees")) > 0 ?"<font color=red>*</font>":"")%></a></td>
		        <td><p align="center"><a href="javascript:void(0)" onclick="ShowCase('<%#(Container.ItemIndex+1)%>')"><%#Eval("tr_money")%></a></td>
		        <td><p align="center"><a href="javascript:void(0)" onclick="ShowCase('<%#(Container.ItemIndex+1)%>')"><%#Eval("allcost")%></td>
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
                    備註：<br>
                    1.點選「退回」，系統會將該筆交辦退回「契約書後補作業」且將契約書狀態改成契約書後補及增加契約書後補管制期限，同時發送Email通知營洽，副本給區所主管、部門主管、程序。<br>  
                    2.確認欄顯示<font color=red>異動請核中</font>，表示該筆交辦尚未完成帳款異動，待帳款異動完成再行處理。<br>
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
        $("input[name='qryseq_type']").triggerHandler("click");
        $(".Lock").lock();
        $("input.dateField").datepick();
    }
    //////////////////////
    $("#qrybstep_date,#qryestep_date").blur(function (e){
        ChkDate(this);
    });

    $("input[name='qryseq_type']").click(function (e){
        $("#qryseq_type").val($(this).val());
    });

    //☐確認檢核,檢查可否勾選有上傳文件
    function doc_chk(pnum){
        var tattach_num=CInt($("#attach_num_"+pnum).val());//檢核文件(n)
        var tview_flag=$("#view_flag_"+pnum).val();//有無按[檢核文件]
        var tchkdoc_flag=$("#chkdoc_"+pnum).prop("checked");//☐確認檢核

        if (tchkdoc_flag==true){//☑確認檢核
            if (tattach_num==0){
                alert("該交辦案件無上傳任何檔案，請通知程序上傳所需文件！");
                $("#chkdoc_"+pnum).prop("checked",false);
                return false;
            }
            if (tview_flag == "N"){
                alert("尚未檢視上傳文件，請先點選「檢核文件」再行勾選！");
                $("#chkdoc_"+pnum).prop("checked",false);
                return false;
            }
            $("#chkflag_"+pnum).prop("checked",true).prop("disabled",false).triggerHandler("click");//☑確認
            if(CInt($("#spay_attach_num_"+pnum).val())>0){//專案付款條件請核單
                $("#chkspay_flag_"+pnum).prop("disabled",false);
            }
        }else{
            $("#chkflag_"+pnum).prop("checked",false).prop("disabled",true).triggerHandler("click");//☐確認
        }
    }

    //交辦畫面
    function ShowCase(pnum) {
        var tlink = $("#urlasp_"+pnum).val();
        window.parent.Eblank.location.href = tlink;
    }

    //[檢核文件]
    function view_attach(pnum) {
        ShowCase(pnum);
        $("#view_flag_"+pnum).val("Y");
    }

    //☐確認
    function chkflagClick(pchknum) {
    }

    //☐專案付款條件
    function spay_flag_chk(pchknum) {
    }

    //Email通知營洽及程序上傳文件有問題
    function show_email(fseq,appl_name,in_no,case_no,mailto){
        var tsubject = "會計檢核上傳文件有誤通知";
        var tbody = "%0A本所編號：" + fseq;
        tbody += "%0A案件名稱：" + appl_name;
        tbody += "%0A接洽序號：" + in_no;
        tbody += "%0A交辦單號：" +case_no + "%0A";
        tbody += "%0A發函者對本函件之說明：";

        ActFrame.location.href = "mailto:" + mailto + "?subject=" + tsubject + "&body=" + tbody ;
    }

    //退回原因
    function showback_remark(){
        if($("#accback_code").val()==""){
            $("#back_remark").val("");
        }else{
            $("#back_remark").val($("#accback_code :selected").text());
        }
    }

    //串接資料
    function setRowData(){
        $("#rows_chkflag,#rows_in_scode,#rows_in_no,#rows_case_no,rows_seq,#rows_seq1,#rows_country,#rows_cust_area,#rows_cust_seq,#rows_old_spay_flag,#rows_cust_apsqlno").val("");
        $("#rows_todo_sqlno,#rows_step_grade,#rows_rs_no,#rows_rs_sqlno,#rows_sc_name,#rows_appl_name,#rows_attach_num,#rows_spay_attach_num,#rows_view_flag,#rows_chkdoc,#rows_chkspay_flag").val("");

        $("#rows_chkflag").val(getJoinValue("#dataList>tbody input[id^='chkflag_']"));
        $("#rows_in_scode").val(getJoinValue("#dataList>tbody input[id^='in_scode_']"));
        $("#rows_in_no").val(getJoinValue("#dataList>tbody input[id^='in_no_']"));
        $("#rows_case_no").val(getJoinValue("#dataList>tbody input[id^='case_no_']"));
        $("#rows_seq").val(getJoinValue("#dataList>tbody input[id^='seq_']"));
        $("#rows_seq1").val(getJoinValue("#dataList>tbody input[id^='seq1_']"));
        $("#rows_country").val(getJoinValue("#dataList>tbody input[id^='country_']"));
        $("#rows_cust_area").val(getJoinValue("#dataList>tbody input[id^='cust_area_']"));
        $("#rows_cust_seq").val(getJoinValue("#dataList>tbody input[id^='cust_seq_']"));
        $("#rows_old_spay_flag").val(getJoinValue("#dataList>tbody input[id^='old_spay_flag_']"));
        $("#rows_cust_apsqlno").val(getJoinValue("#dataList>tbody input[id^='cust_apsqlno_']"));
        $("#rows_todo_sqlno").val(getJoinValue("#dataList>tbody input[id^='todo_sqlno_']"));
        $("#rows_step_grade").val(getJoinValue("#dataList>tbody input[id^='step_grade_']"));
        $("#rows_rs_no").val(getJoinValue("#dataList>tbody input[id^='rs_no_']"));
        $("#rows_rs_sqlno").val(getJoinValue("#dataList>tbody input[id^='rs_sqlno_']"));
        $("#rows_sc_name").val(getJoinValue("#dataList>tbody input[id^='sc_name_']"));
        $("#rows_appl_name").val(getJoinValue("#dataList>tbody input[id^='appl_name_']"));

        $("#rows_attach_num").val(getJoinValue("#dataList>tbody input[id^='attach_num_']"));
        $("#rows_spay_attach_num").val(getJoinValue("#dataList>tbody input[id^='spay_attach_num_']"));
        $("#rows_view_flag").val(getJoinValue("#dataList>tbody input[id^='view_flag_']"));
        $("#rows_chkdoc").val(getJoinValue("#dataList>tbody input[id^='chkdoc_']"));
        $("#rows_chkspay_flag").val(getJoinValue("#dataList>tbody input[id^='chkspay_flag_']"));
    }

    //確認
    function formSubmit(){
        var totnum=$("input[id^='chkflag_']:checked").length;
        if (totnum==0){
            alert("請勾選您要確認的案件!!");
            return false;
        }else{
            for (var j = 1; j <= CInt($("#row").val()) ; j++) {
                if ($("#chkflag_" + j).prop("checked") == true) {
                    if ($("#chkdoc_" + j).prop("checked") == false) {//☐確認檢核
                        alert("請勾選您要確認的案件有上傳文件！");
                        return false;
                    }
                    //提醒有上傳專案付款條件請核單簽呈，是否要勾選
                    if(CInt($("#spay_attach_num_"+j).val())>0){//專案付款條件請核單
                        if($("#chkspay_flag_"+j).prop("disabled")==false &&$("#chkspay_flag_"+j).prop("checked")==false){
                            var ans=confirm("本交辦案件" + $("#seq_"+j).val()+"-"+$("#seq1_"+j).val() + "有上傳「專案付款條件請核單」，是否確定不註記該交辦客戶為「專案付款條件」之客戶？");
                        }
                    }
                    //檢查若該客戶已有註記，確認是否還要註記
                    if($("#chkspay_flag_"+j).prop("disabled")==false &&$("#chkspay_flag_"+j).prop("checked")==true){
                        if($("#old_spay_flag_"+j).val()=="Y"){
                            var ans=confirm("本交辦案件" + $("#seq_"+j).val()+"-"+$("#seq1_"+j).val() + "客戶"+$("#cust_area_"+j).val()+$("#cust_seq_"+j).val()+"已有註記「專案付款條件」，是否確定還需註記該交辦客戶為「專案付款條件」之客戶？");
                        }
                    }
                }
            }

            //未免點選錯誤，若有輸入退回原因，則提醒會計再確認
            if($("#back_remark").val()!=""){
                alert("有輸入退回原因，請確認是要執行「契約書檢核確認」或「退回」，若要退回，請點選「退回」按鈕，若要「確認」，請將「退回原因」內容清空。");
                return false;
            }
	
            if (confirm("共有" + totnum + "筆需要確認 , 是否確定?")){
                postForm("brt7d_Update.aspx?todo=conf");
            }
        }
    }

    //退回存檔前檢查
    function formBack(){
        var totnum=$("input[id^='chkflag_']:checked").length;
        if (totnum==0){
            alert("請勾選您要退回的案件!!");
            return false;
        }else{
            //檢查是否有輸入退回原因
            if($("#back_remark").val()==""){
                alert("請輸入退回原因！");
                return false;
            }
	
            if (confirm("共有" + totnum + "筆需要退回 , 是否確定?")){
                postForm("brt7d_Update.aspx?todo=back");
            }
        }
    }
    
    function postForm(url){
        setRowData();//串接資料

        $("input:disabled, select:disabled").unlock();
        $(".bsubmit").lock(!$("#chkTest").prop("checked"));

        var formData = new FormData($('#reg')[0]);
        ajaxByForm(url,formData)
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