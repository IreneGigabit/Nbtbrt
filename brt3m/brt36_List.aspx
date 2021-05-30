<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Linq"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>

<script runat="server">
    protected string HTProgCap = HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string HTProgPrefix = "brt36";//程式檔名前綴
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
    protected string prscode_grpid = "";//程序人員grpid
    protected string qs_dept = "";
    
    protected string job_grpid = "";//原始簽核者的Grpid
    protected string job_grplevel = "";//原始簽核者的Grplevel

    protected string rdoSY = "";//簽准
    protected string rdoSX = "";//不准退回
    protected string rodST = "";//轉上級簽核

    protected string txtSMaster = "", txtSMasternm = "", txtSMastercode = "", selAgent = "", selPrScode = "";

    DBHelper cnn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    private void Page_Unload(System.Object sender, System.EventArgs e) {
        if (cnn != null) cnn.Dispose();
    }

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        cnn = new DBHelper(Conn.Sysctrl).Debug(Request["chkTest"] == "TEST");
        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");

        qs_dept=(Request["qs_dept"]??"").ToLower();

        Sys.getScodeGrpid(Sys.GetSession("seBranch"), Request["job_scode"], ref job_grpid, ref job_grplevel);
        
        if (qs_dept =="t"){
           HTProgCap = "國內案官發簽核作業";
           apcode = "'brt63'";
           prscode_grpid = "T210";
        } else {
            HTProgCap = "出口案發文簽核作業";
            apcode = "'Ext61'";
            prscode_grpid = "T240";
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
        StrFormBtnTop += "<a href=" + HTProgPrefix + ".aspx?qs_dept=" + qs_dept + "&prgid=" + prgid + ">[回上一頁]</a>";

        FormName = "備註:<br>\n";
		FormName += "1.案件編號前的「<img src=\""+Page.ResolveUrl("~/images/todolist01.jpg")+"\" style=\"cursor:pointer\" align=\"absmiddle\"  border=\"0\">」表示結案/復案。<br>\n";
        FormName += "2.契約書後補先行官發/聯發，主管簽核流程：區所主管→商標經理→執委→程序官發/聯發。<br>\n";
        FormName += "◎ 簽核:<br>\n";
        FormName += "「0」表區所主管→程序官發/聯發； <br>\n";
        FormName += "「執」表區所主管→商標經理→執委→程序官發/聯發； <br>\n";

        DataTable MasterList = Sys.getMasterList(Sys.GetSession("seBranch"), Request["job_scode"]);
        MasterList.ShowTable();
        
        //轉上級人員
        if (job_grplevel == "0") {//專商經理
            txtSMaster = "執委:";
            txtSMasternm = MasterList.Select("grplevel=-1")[0]["master_nm"].ToString();
            txtSMastercode = MasterList.Select("grplevel=-1")[0]["Master_scode"].ToString();
        } else {//區所主管
            txtSMaster = "專商經理:";
            txtSMasternm = MasterList.Select("grplevel=0")[0]["master_nm"].ToString();
            txtSMastercode = MasterList.Select("grplevel=0")[0]["Master_scode"].ToString();
        }
        //例外簽核清單
        selAgent = MasterList.Select("grplevel<0", "up_level").CopyToDataTable().Option("{Master_scode}", "{master_type}--{Master_nm}", false);//只抓執委
        
        //程序人員
        SQL = "select b.scode,b.sc_name,a.grptype ";
        SQL += "from scode_group a ";
        SQL += "inner join scode b on a.scode=b.scode ";
        SQL += "where a.grpclass='" + Session["seBranch"] + "' and grpid='" + prscode_grpid + "' ";
        DataTable dtPrScode = new DataTable();
        cnn.DataTable(SQL, dtPrScode);
        selPrScode = dtPrScode.Option("{scode}", "{sc_name}", "", false,"", "grptype=F");
        
        if (Convert.ToInt32(job_grplevel) <= 1) {//區所主管以上預設簽准
            rdoSY = "checked";
            rodST = "";
        } else {
            rdoSY = "disabled";
            rodST = "checked";
        }
    }
    
    private void QueryData() {
        DataTable dt = new DataTable();
        using (DBHelper conn = new DBHelper(Conn.btbrt).Debug(false)) {
            if (qs_dept == "t") {
			    SQL = "SELECT b.att_sqlno as asqlno,b.in_no,B.In_scode,b.seq,b.seq1,'' as work_opt,b.pr_scode, A.in_date as step_date, A.ctrl_date, f.appl_name, c.Service, c.Fees, B.rs_code as arcase,b.rs_type";
			    SQL+= ",isnull(c.Service,0) + isnull(c.Fees,0) + isnull(c.oth_money,0) AS allcost, B.mark,b.seq,b.seq1,'' as country,'' as back_flag,'' as end_flag";
			    SQL+= ",A.job_scode, A.sqlno as tsqlno,a.pre_sqlno, d.Rs_detail as CArcase,D.rs_class as ar_form,D.prt_code,e.sc_name, f.Cust_area, f.Cust_seq,c.contract_flag,c.contract_flag_date,c.contract_remark ";
			    SQL+= ",c.arcase_type,c.arcase_class, (SELECT classp FROM code_br WHERE rs_code = c.arcase AND dept = 'T' AND cr = 'Y' and rs_type=c.arcase_type) AS classp ";
                SQL += ",''ctype,''ncontract_flag,''link_remark,''fseq,''urlasp,0 T_Service,0 T_Fees,0 P_Service,0 P_Fees ";
                SQL += ",''ctrl_rowspan,''upload_flag,''armark_flag,''armarkT_flag,''dis_flag,''disT_flag,''chk_stat,''accdchk_flag,''tran_remark1,''sign_level,''sign_levelnm ";
                SQL += "FROM attcase_dmt B ";
	            SQL+= "INNER JOIN todo_dmt A ON b.in_scode=A.case_in_scode and b.in_no=a.in_no and b.att_sqlno = a.temp_rs_sqlno ";
			    SQL+= "INNER JOIN code_br D ON B.rs_code = D.Rs_code and d.gs='Y' and d.no_code='N' and b.rs_type=d.rs_type ";
			    SQL+= "INNER JOIN sysctrl.dbo.scode e ON B.In_scode = e.scode ";
			    SQL+= "inner join dmt f on b.seq=f.seq and b.seq1=f.seq1 ";
			    SQL+= "left outer join case_dmt c on b.case_no=c.case_no " ;
                SQL += "WHERE (A.job_status = 'NN') and (a.dowhat='DB_GS') and syscode='" + Session["syscode"] + "' and a.apcode in(" + apcode + ") ";
            } else {
			    SQL = "SELECT b.att_sqlno as asqlno,b.in_no,B.In_scode,b.seq,b.seq1,b.work_opt,b.pr_scode, A.in_date as step_date, A.ctrl_date, f.appl_name, c.tot_service as Service, c.tot_fees as Fees, B.rs_code as arcase,b.rs_type";
			    SQL+= ",isnull(c.tot_Service,0) + isnull(c.tot_Fees,0) + isnull(c.oth_money,0) AS allcost, B.mark,b.seq,b.seq1,f.country,b.back_flag,b.end_flag";
			    SQL+= ",A.job_scode, A.sqlno as tsqlno,a.pre_sqlno, d.Rs_detail as CArcase,D.rs_class as ar_form,D.prt_code,e.sc_name, f.Cust_area, f.Cust_seq,c.contract_flag,c.contract_flag_date,c.contract_remark ";
                SQL += ",''ctype,''ncontract_flag,''link_remark,''fseq,''urlasp,0 T_Service,0 T_Fees,0 P_Service,0 P_Fees ";
                SQL += ",''ctrl_rowspan,''upload_flag,''armark_flag,''armarkT_flag,''dis_flag,''disT_flag,''chk_stat,''accdchk_flag,''tran_remark1,''sign_level,''sign_levelnm ";
                SQL += "FROM attcase_ext B ";
	            SQL+= "INNER JOIN todo_ext A ON b.in_scode=A.case_in_scode and b.in_no=a.in_no and b.att_sqlno = a.att_no " ;
			    SQL+= "INNER JOIN code_ext D ON B.rs_code = D.Rs_code and d.ts_flag='Y' and d.no_code='N' and b.rs_type=d.rs_type " ;
			    SQL+= "INNER JOIN sysctrl.dbo.scode e ON B.In_scode = e.scode " ;
			    SQL+= "inner join ext f on b.seq=f.seq and b.seq1=f.seq1 ";
			    SQL+= "left outer join case_ext c on b.case_no=c.case_no " ;
                SQL += "WHERE (A.job_status = 'NN') and (a.dowhat='DB_TS') and syscode='" + Session["syscode"] + "' and a.apcode in(" + apcode + ") ";
            }

            if (ReqVal.TryGet("job_scode") != "") {
                SQL += " AND (A.job_scode = '" + Request["job_scode"] + "')";
            } else {
                SQL += " AND (A.job_scode = '" + Session["scode"] + "')";
            }

            if (ReqVal.TryGet("scode") != "*" && ReqVal.TryGet("scode") != "") {
                SQL += " and b.in_scode = '" + Request["scode"] + "'";
            }
            if (ReqVal.TryGet("dtype") == "1") {
                SQL += " and A.ctrl_date between '" + Request["Sdate"] + "' and '" + Request["Edate"] + "'";
            }
            if (ReqVal.TryGet("dtype") == "2") {
                SQL += " and A.in_date between '" + Request["Sdate"] + " 00:00:00' and '" + Request["Edate"] + " 23:59:59'";
            }
            
            ReqVal["qryOrder"] = ReqVal.TryGet("SetOrder", ReqVal.TryGet("qryOrder"));
            if (ReqVal.TryGet("qryOrder") != "") {
                SQL += " order by " + ReqVal.TryGet("qryOrder");
            } else {
                SQL += " order by step_date";
            }
            //Sys.showLog(SQL);
            conn.DataTable(SQL, dt);

            //處理分頁
            int nowPage = Convert.ToInt32(Request["GoPage"] ?? "1"); //第幾頁
            int PerPageSize = Convert.ToInt32(Request["PerPage"] ?? "10"); //每頁筆數
            page = new Paging(nowPage, PerPageSize, SQL);
            page.GetPagedTable(dt);

            //分頁完再處理其他資料才不會虛耗資源
            for (int i = 0; i < page.pagedTable.Rows.Count; i++) {
                DataRow dr = page.pagedTable.Rows[i];
                if (dr.SafeRead("work_opt", "") == "S" || dr.SafeRead("work_opt", "") == "P") {//2015/5/7for新增交辦發文增加P
                    dr["ctype"] = "NN";
                } else {
                    dr["ctype"] = "NO";
                }

                //契約書後補註記
                if (dr.SafeRead("contract_flag", "") == "") {
                    dr["ncontract_flag"] = "N";
                }
                if (dr.SafeRead("contract_flag_date", "") != "") {//有日期表示已補
                    dr["ncontract_flag"] = "N";
                }
                
                if (qs_dept == "t") {
                    dr["fseq"] = Sys.formatSeq(dr.SafeRead("seq", ""), dr.SafeRead("seq1", ""), dr.SafeRead("country", ""), Sys.GetSession("SeBranch"), Sys.GetSession("dept"));
                    dr["urlasp"] = Sys.getCase11Aspx(prgid,dr.SafeRead("in_no",""),dr.SafeRead("in_scode","") ,"Show");
                } else {
                    dr["fseq"] = Sys.formatSeq(dr.SafeRead("seq", ""), dr.SafeRead("seq1", ""), dr.SafeRead("country", ""), Sys.GetSession("SeBranch"), Sys.GetSession("dept")+"E");
                }

                //計算簽核層級,並檢查簽准層級=交辦營洽則再往上一級
                string sign_level = "", sign_levelnm = "";
                if (dr["ncontract_flag"] == "Y" ) {
                    sign_level = "-1";//執委
                    sign_levelnm = "執";//執委
                } else {
                    sign_level = "0";//商標經理
                    sign_levelnm = "0";
                }
                dr["sign_level"] = sign_level;
                dr["sign_levelnm"] = sign_levelnm;
            }

            dataRepeater.DataSource = page.pagedTable;
            dataRepeater.DataBind();
        }
    }

    protected string GetTodoIcon(RepeaterItem Container) {
        string back_flag = Eval("back_flag").ToString().Trim().ToUpper();
        string end_flag = Eval("end_flag").ToString().Trim().ToUpper();
        if (back_flag == "Y" || end_flag == "Y")
            return "<img src='" + Page.ResolveUrl("~/images/todolist01.jpg") + "'  style='cursor:pointer' align='absmiddle' border='0'>";

        return "";
    }

    protected string GetContractFlag(RepeaterItem Container) {
        string rtn = "";
        string contract_flag = Eval("contract_flag").ToString().Trim().ToUpper();
        string contract_remark = Eval("contract_remark").ToString();
        string contract_flag_date = Eval("contract_flag_date").ToString();
        if (contract_flag == "Y") {
            rtn += "<br><font color=red>(契約書後補：" + contract_remark;
            if (contract_flag_date != "") {
                rtn += "，後補完成日" + contract_flag_date;
            }
            rtn += ")</font>";
        }
            
        return rtn;
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title><%=HTProgCap%></title>
<link rel="stylesheet" type="text/css" href="<%=Page.ResolveUrl("~/inc/setstyle.css")%>" />
<link rel="stylesheet" type="text/css" href="<%=Page.ResolveUrl("~/js/lib/jquery.datepick.css")%>" />
<link rel="stylesheet" type="text/css" href="<%=Page.ResolveUrl("~/js/lib/toastr.css")%>" />
<link rel="stylesheet" type="text/css" href="<%=Page.ResolveUrl("~/js/lib/jquery-ui.min.css")%>" />
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/jquery-1.12.4.min.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/jquery-ui.min.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/jquery.datepick.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/jquery.datepick-zh-TW.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/toastr.min.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/util.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/jquery.irene.form.js")%>"></script>
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

<div align="center" id="noData" style="display:<%#page.totRow==0?"":"none"%>">
	<font color="red">=== 目前無資料 ===</font>
</div>

<form style="margin:0;" id="reg" name="reg" method="post">
<asp:Repeater id="dataRepeater" runat="server">
<HeaderTemplate>
    <input type=hidden id="GrpID" name="GrpID" value="<%=job_grpid%>"><!--原始簽核者的Grpid-->
    <input type=hidden id="grplevel" name="grplevel" value="<%=job_grplevel%>"><!--原始簽核者的層級-->
    <input type=hidden id="sign_level" name="sign_level" value=""><!--簽准層級-->
    <input type=hidden id="contract_flag" name="contract_flag" value="N"><!--契約書後補contract_flag=Y需經區所+專商經理+執委主管簽准-->
    <input type=hidden id=row name=row value="<%#page.pagedTable.Rows.Count%>"> 

    <table style="display:<%#page.totRow==0?"none":""%>" border="0" class="bluetable" cellspacing="1" cellpadding="2" width="100%" align="center" id="dataList">
	    <thead>
            <Tr>
                <td align="center" class="lightbluetable" onclick="checkall()" style="cursor:pointer">全選</td>
	            <td align="center" class="lightbluetable">案件編號</td>
	            <td align="center" class="lightbluetable">營洽-接洽序號</td>
	            <td align="center" class="lightbluetable">交辦日期</td>	
	            <td align="center" class="lightbluetable">案件名稱</td>
	            <td align="center" class="lightbluetable">案性</td>
	            <td align="center" class="lightbluetable">服務費</td>
	            <td align="center" class="lightbluetable">規費</td>
	            <td align="center" class="lightbluetable">合計</td>
	            <td align="center" class="lightbluetable">簽核</td>
            </tr>
	    </thead>
	    <tbody>
</HeaderTemplate>
			<ItemTemplate>
 		        <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>">
		            <td align="center">
                        <input type=checkbox id="C_<%#(Container.ItemIndex+1)%>" name="C_<%#(Container.ItemIndex+1)%>" value="Y" onclick="Chkupload('<%#(Container.ItemIndex+1)%>','<%#Eval("sign_level")%>')">
                        <input type=hidden id="code_<%#(Container.ItemIndex+1)%>" name="code_<%#(Container.ItemIndex+1)%>" value="<%#Eval("tsqlno")%>">
	                    <input type=hidden id="acode_<%#(Container.ItemIndex+1)%>" name="acode_<%#(Container.ItemIndex+1)%>" value="<%#Eval("asqlno")%>">
	                    <input type=hidden id="In_no_<%#(Container.ItemIndex+1)%>" name="In_no_<%#(Container.ItemIndex+1)%>" value="<%#Eval("In_no")%>">
	                    <input type=hidden id="In_scode_<%#(Container.ItemIndex+1)%>" name="In_scode_<%#(Container.ItemIndex+1)%>" value="<%#Eval("In_scode")%>">
	                    <input type=hidden id="Cust_area_<%#(Container.ItemIndex+1)%>" name="Cust_area_<%#(Container.ItemIndex+1)%>" value="<%#Eval("Cust_area")%>">
	                    <input type=hidden id="Cust_seq_<%#(Container.ItemIndex+1)%>" name="Cust_seq_<%#(Container.ItemIndex+1)%>" value="<%#Eval("Cust_seq")%>">
	                    <input type=hidden id="pre_sqlno_<%#(Container.ItemIndex+1)%>" name="pre_sqlno_<%#(Container.ItemIndex+1)%>" value="<%#Eval("pre_sqlno")%>">
	                    <input type=hidden id="work_opt_<%#(Container.ItemIndex+1)%>" name="work_opt_<%#(Container.ItemIndex+1)%>" value="<%#Eval("work_opt")%>"><!--2015/5/7增加for新增交辦發文，作後續流程控制用-->
	                    <input type=hidden id="contract_flag_<%#(Container.ItemIndex+1)%>" name="contract_flag_<%#(Container.ItemIndex+1)%>" value="<%#Eval("ncontract_flag")%>"><!--2015/5/7增加for新增交辦發文，作後續流程控制用-->
	                    <input type=hidden id="appl_name_<%#(Container.ItemIndex+1)%>" name="appl_name_<%#(Container.ItemIndex+1)%>" value="<%#Eval("appl_name")%>">
	                    <input type=hidden id="seq_<%#(Container.ItemIndex+1)%>" name="seq_<%#(Container.ItemIndex+1)%>" value="<%#Eval("seq")%>">
	                    <input type=hidden id="seq1_<%#(Container.ItemIndex+1)%>" name="seq1_<%#(Container.ItemIndex+1)%>" value="<%#Eval("seq1")%>">
	                    <input type=hidden id="country_<%#(Container.ItemIndex+1)%>" name="country_<%#(Container.ItemIndex+1)%>" value="<%#Eval("country")%>">
	                    <input type=hidden id="case_arcase_<%#(Container.ItemIndex+1)%>" name="case_arcase_<%#(Container.ItemIndex+1)%>" value="<%#Eval("arcase")%>">
	                    <input type=hidden id="case_name_<%#(Container.ItemIndex+1)%>" name="case_name_<%#(Container.ItemIndex+1)%>" value="<%#Eval("carcase")%>">
	                    <input type=hidden id="pr_scode_<%#(Container.ItemIndex+1)%>" name="pr_scode_<%#(Container.ItemIndex+1)%>" value="<%#Eval("pr_scode")%>"><!--承辦人員，for退回Email通知用-->
		            </td>
	                <td align="center">
                        <A href="<%#Eval("urlasp")%>" target="Eblank">
                            <%#GetTodoIcon(Container)%>
                            <%#Eval("fseq")%>
	                    </A>
	                </td>
		            <td align="center">
                        <A href="<%#Eval("urlasp")%>" target="Eblank">
                            <%#Eval("sc_name")%>-<%#Eval("in_no")%>
                            <%#GetContractFlag(Container)%>
                        </A>
		            </td>
		            <td align="center">
                        <A href="<%#Page.ResolveUrl("~/Brt4m/brt13_ListA.aspx?prgid=" + prgid+"&in_scode="+Eval("in_scode")+"&in_no="+Eval("in_no")+"&qs_dept="+qs_dept)%>" target="Eblank">
                            <%#Eval("step_date", "{0: yyyy/MM/dd}")%>
                            <%#Eval("ctrl_date").ToString()!="" ? "<br><font size='2' color=red>("+Eval("ctrl_date")+")</font>":""%>
                        </A>
		            </td>
	                <td class="whitetablebg" align="center"><A href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("appl_name")%></A></td>
	                <td class="whitetablebg" align="center"><A href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("CArcase")%></A></td>
	                <td class="whitetablebg" align="center"><A href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("service")%></A></td>
	                <td class="whitetablebg" align="center"><A href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("fees")%></A></td>
	                <td class="whitetablebg" align="center"><A href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("allcost")%></TD></td>
		            <td align="center"><A href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("sign_levelnm")%></A></TD>
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
				<label><input type=radio name="signid" value="SY" onclick=tosign() <%#rdoSY%>>簽准</label>
				<label><input type=radio name="signid" value="SX" onclick=tosign() <%#rdoSX%>>不准，退回承辦</label>
				<label><input type=radio name="signid" value="ST" onclick=tosign() <%#rodST%>>轉上級簽核</label>
				<input type=hidden name=signidnext id=signidnext>
				<input type=hidden name=status id=status>
			</TD>
			<TD align=right>
				<span style="" id="showsign1">
					程序人員：<select name="prscode" id="prscode"><%#selPrScode%></select>
				</span>
			</TD>
			<TD align=right>
				<span id="showsign">
					<span id="spanMaster"><input type=radio name="upsign" value="sMaster"><!--主管-->
                        <%#txtSMaster%>
                        <select id="sMastercode" name="sMastercode">
                            <option value="<%=txtSMastercode%>"><%=txtSMasternm%></option>
                        </select>
					</span>
                    <span id="spanAgent"><input type=radio name="upsign" value="sAgent"><!--例外-->
                        例外簽核：
                        <%if (job_grplevel=="0") {%>
                            <input type=text name="agt_scode" size=5 onblur="reg.sAgentcode.value=this.value">(薪號)
                        <%}else{%>
                            <select id="smc_scode" name="smc_scode" onchange="reg.sAgentcode.value=this.value"><%#selAgent%></select>
                        <%}%>
                    </span>
					<input type=hidden value="" name="sAgentcode" id="sAgentcode">
					<input type=hidden value="S" name=mark id=mark>	
				</span>
			</TD>
		</TR>
		<TR>
			<TD align=right>簽核說明:</TD>
			<TD align=left colspan=2><TEXTAREA name=signdetail id=signdetail ROWS=2 COLS=50></TEXTAREA></TD>
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

        $("input[name='signid']:checked").triggerHandler("click");
        $(".Lock").lock();
        $("input.dateField").datepick();
    });
    //執行查詢
    function goSearch() {
        $("#regPage").submit();
    };
    ///////////////////////////////////////////////////////////////
    //每筆交辦勾選時檢查簽核層級
    //tcontract=契約書後補註記
    function Chkupload(tcount,sign_level) {
        var tcontract=$("#contract_flag_"+tcount).val();

        if ($("#sign_level").val()=="") {
            $("#sign_level").val(sign_level);
            $("#contract_flag").val(tcontract);
        }

        if($("#C_"+tcount).prop("checked")==true){
            if($("#sign_level").val()!=sign_level){
                if($("#sign_level").val()=="執"){
                    alert("送簽流程(需經國內所執委簽核)不相同無法同時送簽發信，請重新選取！");
                }else{
                    alert("送簽流程不相同無法同時送簽發信，請重新選取⑴！");
                }
                $("#C_"+tcount).prop("checked",false);
                if ($("input[name^='C_']:checked").length == 0) $("#sign_level").val("");
                return false;
            }
        }

        if($("#contract_flag").val() !=tcontract){
            alert("送簽流程不相同無法同時送簽發信，請重新選取⑵！");
            $("#C_"+tcount).prop("checked",false);
            if ($("input[name^='C_']:checked").length == 0) $("#sign_level").val("");
            return false;
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
        if ($("input[name=signid]:checked").val() == "SY") {//簽准
            $("#showsign").hide();//主管
            $("#showsign1").show();//程序人員
        }else if ($("input[name=signid]:checked").val() == "SX") {//不准退回
            $("#showsign").hide();//主管
            $("#showsign1").hide();//程序人員
        }else if ($("input[name=signid]:checked").val() == "ST") {//轉上級簽核
            $("#showsign1").hide();//程序人員
            $("#showsign").show();//主管
            $("input[name='upsign']:eq(0)").prop("checked", true);
        }
    }
    
    //*****簽准、轉上級單位:update  		
    //*****不准退回        :update2	
    function formupdate(){
        var url="";
        if($("input[name=signid][value='SY']").prop("checked")==true){
            if ($("#contract_flag").val()== "Y"){
                alert("選取契約書後補交辦案件依規定需經商標經理及國內所執委簽核才能發文，請點選「轉上級簽核」並選擇簽核主管！");
                $("input[name='signid'][value='ST']").prop("checked", true).triggerHandler("click");
                return false;
            }
            $("#status").val("SY");
            $("#signidnext").val($("#prscode").val());//程序
            $("#mark").val("");//是否給代理人簽核
            reg.action = "<%#HTProgPrefix%>_Update.aspx?qs_dept=<%=qs_dept%>";
        }else if($("input[name=signid][value='SX']").prop("checked")==true){
            $("#status").val("SX");
            reg.action = "<%#HTProgPrefix%>_Update2.aspx?qs_dept=<%=qs_dept%>";
        }else if($("input[name=signid][value='ST']").prop("checked")==true){
            if($("input[name='upsign']:eq(0)").prop("checked")==true){
                $("#signidnext").val($("#sMastercode").val());//主管
                $("#mark").val("");//是否給代理人簽核
            }else{
                $("#signidnext").val($("#sAgentcode").val());//例外簽核
                $("#mark").val("S");//是否給代理人簽核
            }
            $("#status").val("ST");
            reg.action = "<%#HTProgPrefix%>_Update.aspx?qs_dept=<%=qs_dept%>";
        }

        if ($("input[name^='C_']:checked").length==0){
            alert("尚未選定!!");
        }else{
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
                                window.location.href="<%=HTProgPrefix%>.aspx?prgid=<%#prgid%>&qs_dept=<%=qs_dept%>"
                            }
                        }
                    });
                }
            });
        }
    }
</script>