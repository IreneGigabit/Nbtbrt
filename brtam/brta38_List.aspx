<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>

<script runat="server">
    protected string HTProgCap = "國內案官方發文確認作業";//HttpContext.Current.Request["prgname"];//功能名稱
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

    protected string pcount = "",ecount = "",rcount = "";
    protected string html_scode = "";

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
        HTProgCap = myToken.Title.Replace("官發", "<font color=blue>官方發文</font>");
        DebugStr = myToken.DebugStr;
        if (HTProgRight >= 0) {
            PageLayout();
            QueryData();
            this.DataBind();
        }
    }

    private void PageLayout() {
        StrFormBtnTop += "<a href=\"區所商標電子申請程序作業-201301.pptx\" target=\"_blank\">[電子送件程序操作說明]</a>";
        StrFormBtnTop += "<a class=\"imgRefresh\" href=\"javascript:void(0);\" >[重新整理]</a>";

        //洽案營洽
        SQL="select distinct a.case_in_scode ";
        SQL += ",(select sc_name from sysctrl.dbo.scode where scode=a.case_in_scode) as sc_name ";
        SQL += ",(select sscode from sysctrl.dbo.scode where scode=a.case_in_scode) as scode1 ";
        SQL += " from todo_dmt a ";
        SQL += "where syscode='" + Session["syscode"] + "' and dowhat='DC_GS' and job_status='NN' ";
        SQL += "order by scode1";
        html_scode = Util.Option(conn, SQL, "{case_in_scode}", "{case_in_scode}_{sc_name}", true, Sys.GetSession("scode"));
    }

    private void QueryData() {
        //抓取非電子送件件數
        SQL = "SELECT count(*) as num ";
        SQL += " FROM attcase_dmt a  ";
        SQL += " inner join todo_dmt b on a.att_sqlno=b.temp_rs_sqlno ";
        SQL += " where a.conf_date is null and b.dowhat='DC_GS' and b.job_status='NN' ";
        SQL += " and isnull(a.send_way,'') not in('E','EA') ";
        objResult = conn.ExecuteScalar(SQL);
        pcount = (objResult == DBNull.Value || objResult == null) ? "" : "(<font color=blue>" + objResult + "</font>件)";

        //抓取電子送件件數
        SQL = "SELECT count(*) as num";
        SQL += " FROM attcase_dmt a  ";
        SQL += " inner join todo_dmt b on a.att_sqlno=b.temp_rs_sqlno ";
        SQL += " where a.conf_date is null and b.dowhat='DC_GS' and b.job_status='NN' ";
        SQL += " and a.send_way ='E' ";
        objResult = conn.ExecuteScalar(SQL);
        ecount = (objResult == DBNull.Value || objResult == null) ? "" : "(<font color=blue>" + objResult + "</font>件)";

        //抓取註冊費電子送件件數
        SQL = "SELECT count(*) as num";
        SQL += " FROM attcase_dmt a  ";
        SQL += " inner join todo_dmt b on a.att_sqlno=b.temp_rs_sqlno ";
        SQL += " where a.conf_date is null and b.dowhat='DC_GS' and b.job_status='NN' ";
        SQL += " and a.send_way ='EA' ";
        objResult = conn.ExecuteScalar(SQL);
        rcount = (objResult == DBNull.Value || objResult == null) ? "" : "(<font color=blue>" + objResult + "</font>件)";

        SQL = "select a.att_sqlno,a.seq,a.seq1,a.rs_detail,a.step_date,c.step_grade,c.now_grade,c.appl_name ";
        SQL += ",a.rs_type,a.rs_class,a.rs_code,a.act_code,a.in_scode,a.in_no,b.sqlno as todo_sqlno ";
        SQL += ",a.fees,a.send_sel,a.pr_scode,a.send_way,a.case_no,a.send_cl,a.send_cl1 ";
        SQL += ",a.in_no,a.fees_stat,a.opt_branch,a.mp_date ";
        SQL += ",c.scode as dmt_scode,c.class,(select sc_name from sysctrl.dbo.scode where scode=a.in_scode) as sc_name ";
        SQL += ",c.apply_no,c.pay_times,c.pay_date,c.cust_seq ";
        SQL += ",''link_remark,''button,''urlasp,''rs_agt_no,''rs_agt_nonm ";
        SQL += ",''fseq,''last_date,''pay_date,''spe_ctrl_4,''ectrlnum ";
        SQL += ",''receipt_type,''receipt_title,''rectitle_name,''tmprectitle_name ";
        SQL += ",'0'case_fees,'0'case_gs_fees,'0'case_service,''case_gs_curr,''case_agt_no,''case_agt_name ";
        //SQL+=",''dmt_pay_times,''apply_no,0 gs_fee,''mp_date,''gs_contract_flag ";
        SQL += " from attcase_dmt a ";
        SQL += " inner join todo_dmt as b on a.att_sqlno=b.temp_rs_sqlno ";
        SQL += " inner join dmt as c on a.seq=c.seq and a.seq1=c.seq1 ";
        SQL += " where a.conf_date is null and b.dowhat='DC_GS' and b.job_status='NN' ";

        if (ReqVal.TryGet("qrystep_dateS") != "") {
            SQL += "AND a.Step_Date>='" + ReqVal["qrystep_dateS"] + "' ";
        }
        if (ReqVal.TryGet("qrystep_dateE") != "") {
            SQL += "AND a.Step_Date<='" + ReqVal["qrystep_dateE"] + "' ";
        }

        if (ReqVal.TryGet("qrySeq") != "") {
            SQL += "AND a.Seq in ('" + ReqVal.TryGet("qrySeq").Replace(",", "','") + "') ";
        }
        if (ReqVal.TryGet("qrySeq1") != "") {
            SQL += "AND a.Seq1='" + ReqVal["qrySeq1"] + "' ";
        }

        if (ReqVal.TryGet("qryscode") != "") {
            SQL += "AND a.in_scode='" + ReqVal["qryscode"] + "' ";
        }

        if (ReqVal.TryGet("qrysend_way") == "") ReqVal["qrysend_way"] = "M";
        if (ReqVal.TryGet("qrysend_way") == "M") {
            SQL += "and isnull(a.send_way,'') not in('E','EA') ";
        } else {
            SQL += "AND a.send_way='" + Request["qrysend_way"] + "' ";
        }

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

            //抓取本筆案件最小法定期限
            SQL = " select min(ctrl_date) as last_date from ctrl_dmt ";
            SQL += " where seq=" + dr["seq"] + " and seq1='" + dr["seq1"] + "' and ctrl_type like 'A%'";
            objResult = conn.ExecuteScalar(SQL);
            string last_date = (objResult == DBNull.Value || objResult == null) ? "" : Util.parseDBDate(objResult.ToString(), "yyyy/M/d");
            dr["last_date"] = last_date;

            //註冊費已繳
            if (dr.SafeRead("rs_code", "") == "FF1") {
                if (dr.SafeRead("pay_times", "") == "") {
                    dr["pay_date"] = dr.GetDateTimeString("step_date", "yyyy/M/d");
                }
            } else if (dr.SafeRead("rs_code", "") == "FF2") {
                if (dr.SafeRead("pay_times", "") == "") {
                    dr["pay_date"] = dr.GetDateTimeString("step_date", "yyyy/M/d");
                }
            } else if (dr.SafeRead("rs_code", "") == "FF3") {
                if (dr.SafeRead("pay_times", "") == "") {
                    dr["pay_date"] = dr.GetDateTimeString("step_date", "yyyy/M/d");
                }
            } else if (dr.SafeRead("rs_code", "") == "FF0") {
                if (dr.SafeRead("pay_times", "") == "") {
                    dr["pay_date"] = dr.GetDateTimeString("step_date", "yyyy/M/d");
                }
            }

            //取得arcase_class,ar_form,arcase_type,cust_area,cust_seq,ar_code,等交辦資料
            SQL = "select receipt_type,receipt_title,rectitle_name ";
            SQL += ",service+isnull(add_service,0) as case_service,fees+isnull(add_fees,0) as case_fees,isnull(gs_fees,0) as case_gs_fees,gs_curr case_gs_curr ";
            SQL+=",b.agt_no case_agt_no ";
            SQL += ",(select agt_name from agt where agt_no=b.agt_no) as case_agt_name ";
            SQL += ",(select treceipt from agt where agt_no=b.agt_no) as receipt ";
            SQL+= " from case_dmt a ";
            SQL += " inner join dmt_temp b on a.in_no=b.in_no and b.case_sqlno=0 ";
            SQL += " where case_no='" +dr["case_no"]+ "' and a.seq="+dr["seq"]+  " and a.seq1='" +dr["seq1"]+ "'";
            using (SqlDataReader dr1 = conn.ExecuteReader(SQL)) {
                if (dr1.Read()) {
                    dr["receipt_type"] = dr1.SafeRead("receipt_type", "");
                    dr["receipt_title"] = dr1.SafeRead("receipt_title", "");
                    dr["rectitle_name"] = dr1.SafeRead("rectitle_name", "");
                    dr["case_fees"] = dr1.SafeRead("case_fees", "0");
                    dr["case_service"] = dr1.SafeRead("case_service", "0");
                    dr["case_gs_fees"] = dr1.SafeRead("case_gs_fees", "0");
                    dr["case_gs_curr"] = dr1.SafeRead("case_gs_curr", "");
                    dr["case_agt_no"] = dr1.SafeRead("case_agt_no", "");
                    dr["case_agt_name"] = dr1.SafeRead("case_agt_name", "");
                }
            }

            //若於step_fees已有該資料，讀取step_fees
            int nowfees = 0;
            int nowservice = 0;
            SQL = "select fees,service from fees_dmt where case_no='" +dr["case_no"]+ "'";
            using (SqlDataReader dr1 = conn.ExecuteReader(SQL)) {
                if (dr1.Read()) {
                    nowservice = Convert.ToInt32(dr1.SafeRead("service", "0"));
                    nowfees = Convert.ToInt32(dr1.SafeRead("fees", "0"));
                    dr["case_service"] = nowservice;
                    dr["case_fees"] = nowfees;
                    dr["case_gs_fees"] = nowfees;
                } else {
                    //若gs_curr>0表該case_no表服務費已收不可再重覆收
                    if (Convert.ToInt32(dr["case_gs_curr"]) > 0) {
                        dr["case_service"] = nowservice;
                    }
                    dr["case_gs_fees"] = dr["case_fees"];
                }
            }
            
            //如果DB無值則以設定檔為準
            string receipt_title = dr["receipt_title"].ToString();
            if (receipt_title == "") receipt_title = Sys.getDefaultTitle();

            string tmprectitle_name = "";
            SQL = "Select a.ap_cname from dmt_temp_ap a where a.in_no='" + dr["in_no"] + "' and a.case_sqlno=0 order by a.server_flag desc,a.temp_ap_sqlno";
            using (SqlDataReader sdr = conn.ExecuteReader(SQL)) {
                while (sdr.Read()) {
                    tmprectitle_name += "、" + sdr.SafeRead("ap_cname", "").Trim();
                }
            }
            tmprectitle_name = (tmprectitle_name != "" ? tmprectitle_name.Substring(1) : "");
            dr["tmprectitle_name"] = tmprectitle_name;
            if (receipt_title == "A" && dr.SafeRead("rectitle_name", "") == "") {
                dr["rectitle_name"] = tmprectitle_name;
            } else if (receipt_title == "C" && dr.SafeRead("rectitle_name", "") == "") {
                dr["rectitle_name"] = tmprectitle_name + "(代繳人：聖島國際專利商標聯合事務所)";
            }

            //抓可用的發文方式
            SQL = "select a.spe_ctrl from vcode_act a";
            SQL += " where cg='g' and rs='s' and gs='Y' and dept='" + Session["dept"] + "'";
            SQL += " and rs_code='" + dr["rs_code"] + "' and act_code='" + dr["act_code"] + "'";
            objResult = conn.ExecuteScalar(SQL);
            string spe_ctrl_4 = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();
            if (spe_ctrl_4 != "") spe_ctrl_4 = "|" + spe_ctrl_4.PadRight(5, ',').Split(',')[4] + "|";
            dr["spe_ctrl_4"] = spe_ctrl_4;

            //該案性的出名代理人
            DataTable agt = Sys.getCodeBrAgent(dr.SafeRead("rs_type", ""), dr.SafeRead("rs_code", ""), "gs", "A");
            if (agt.Rows.Count > 0) {
                dr["rs_agt_no"] = agt.Rows[0].SafeRead("rsagtno", "");
                dr["rs_agt_nonm"] = agt.Rows[0].SafeRead("rsagtnm", "");
            }
            
            //抓取未銷管筆數
            SQL = "select count(*) as ectrlnum from ctrl_dmt where seq=" + dr["seq"] + " and seq1='" + dr["seq1"] + "'";
            objResult = conn.ExecuteScalar(SQL);
            dr["ectrlnum"] = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();
        }

        if (ReqVal.TryGet("qrysend_way") == "EA") {//批次繳註冊費
            batchRepeater.DataSource = page.pagedTable;
            batchRepeater.DataBind();
            singleRepeater.Visible = false;//單筆隱藏
        } else {
            singleRepeater.DataSource = page.pagedTable;
            singleRepeater.DataBind();
            batchRepeater.Visible = false;//批次隱藏
        }
    }
        
    //發文對象
    protected string GetSendCL(RepeaterItem Container) {
        string send_cl=Eval("send_cl").ToString();
        return Sys.getCustCode("SEND_CL", "", "cust_code").Option("{cust_code}", "{code_name}",true,send_cl);
    }
    
    //副本對象
    protected string GetSendCL1(RepeaterItem Container) {
        string send_cl1=Eval("send_cl1").ToString();
        return Sys.getCustCode("SEND_CL", "", "cust_code").Option("{cust_code}", "{code_name}",true,send_cl1);
    }
    
    //結構分類
    protected string GetRsClass(RepeaterItem Container) {
        string rs_class=Eval("rs_class").ToString();
        SQL="select cust_code,code_name from cust_code where code_type='" +Eval("rs_type")+ "' and mark is null ";
		SQL += " and cust_code in (select rs_class from vcode_act where cg ='G' and rs = 'S' and rs_type='" +Eval("rs_type")+ "') order by cust_code";
        return Util.Option(conn, SQL, "{cust_code}", "{code_name}", true, rs_class);
    }
    
    //案性
    protected string GetRsCode(RepeaterItem Container) {
        string rs_code=Eval("rs_code").ToString();
		SQL="select rs_code,rs_detail,rs_class from code_br where dept='"+Session["dept"]+"' and gs='Y' ";
		SQL +=" and rs_type = '"  +Eval("rs_type")+ "'";
        return Util.Option(conn, SQL, "{rs_code}", "{rs_detail}","vrs_class='{rs_class}'", true, rs_code);
    }
    
    //處理事項
    protected string GetActCode(RepeaterItem Container) {
        string act_code = Eval("act_code").ToString();
        SQL = "select distinct act_code,act_code_name,act_sort,case_stat,case_stat_name ";
        SQL += " from vcode_act ";
        SQL += " where rs_type='" + Eval("rs_type") + "' and cg='G' and rs='S' ";
        if (Eval("rs_class").ToString() != "") {
            SQL += " and rs_class = '" + Eval("rs_class") + "' ";
        }
        if (Eval("rs_code").ToString() != "") {
            SQL += " and rs_code = '" + Eval("rs_code") + "' ";
        }
        SQL += " order by act_sort";
        return Util.Option(conn, SQL, "{act_code}", "{act_code_name}", "vcase_statnm='{case_stat_name}' vcase_stat='{case_stat}' vsql='{act_sort}'", true, act_code);
    }

    //承辦
    protected string GetPrScode(RepeaterItem Container) {
        string pr_scode = Eval("pr_scode").ToString();
        return Sys.getPrScode().Option("{scode}", "{scode}_{sc_name}", true, pr_scode);
    }

    //收據抬頭
    protected string GetReceiptTitle(RepeaterItem Container) {
        string receipt_title = Eval("receipt_title").ToString();
        return Sys.getCustCode("rec_titleT", "", "cust_code").Option("{cust_code}", "{code_name}", true, receipt_title);
    }

    //官方號碼
    protected string GetSendSel(RepeaterItem Container) {
        return Sys.getCustCode("SEND_SEL", "", "").Option("{cust_code}", "{code_name}", true, "1");//申請號
    }

    //註冊費已繳
    protected string GetOptPayTimes(RepeaterItem Container) {
        string pay_times = Eval("pay_times").ToString();
        //註冊費已繳
        if (pay_times == "") {
            if (Eval("rs_code").ToString() == "FF1") {
                pay_times = "1";
            } else if (Eval("rs_code").ToString() == "FF2") {
                pay_times = "2";
            } else if (Eval("rs_code").ToString() == "FF3") {
                pay_times = "2";
            } else if (Eval("rs_code").ToString() == "FF0") {
                pay_times = "A";
            }
        }
        return Sys.getCustCode(Sys.GetSession("dept") + "PAY_TIMES", "", "sortfld").Option("{cust_code}", "{code_name}", true, pay_times);
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title><%#HTProgCap%></title>
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
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/client_chk.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/jquery.Snoopy.date.js")%>"></script>
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
		        ◎發文方式:<input type="radio" name="qrysend_way" id="qrysend_wayM" value="M" <%#ReqVal.TryGet("qrysend_way")=="M"?"checked":""%>><label for="qrysend_wayM">非電子送件<%#pcount%></label>
		                   <input type="radio" name="qrysend_way" id="qrysend_wayE" value="E" <%#ReqVal.TryGet("qrysend_way")=="E"?"checked":""%>><label for="qrysend_wayE">電子送件<%#ecount%></label>
		                   <input type="radio" name="qrysend_way" id="qrysend_wayEA" value="EA" <%#ReqVal.TryGet("qrysend_way")=="EA"?"checked":""%>><label for="qrysend_wayEA">註冊費電子送件<%#rcount%></label>
	        </td>
	        <td class="text9" colspan=2>
		        ◎預計發文日期: <input type="text" name="qrystep_DateS" id="qrystep_DateS" size="10" value="<%#ReqVal.TryGet("qrystep_dateS")%>" class="dateField">
                		~ <input type="text" name="qrystep_DateE" id="qrystep_DateE" size="10" value="<%#ReqVal.TryGet("qrystep_dateE")%>" class="dateField">
	        </td>
        </tr>
        <tr>
	        <td class="text9">
		        ◎洽案營洽: <SELECT name="qryscode" id="qryscode"><%#html_scode%></SELECT>
	        </td>
	        <td class="text9">
		        ◎本所編號:<input type="text" name="qrySeq" id="qrySeq" size="30" value="">-<input type="text" name="qrySeq1" id="qrySeq1" size="2" value="">
	        </td>
	        <td class="text9">
		        <input type="button" value="查詢" class="cbutton" onClick="goSearch()" id="qrybutton" name="qrybutton">
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
    <input type="hidden" id=row name=row value="<%#page.pagedTable.Rows.Count%>"> 
    <INPUT type="hidden" name="rows_chk" id="rows_chk">
    <INPUT type="hidden" name="rows_cgrs" id="rows_cgrs">
    <INPUT type="hidden" name="rows_todo_sqlno" id="rows_todo_sqlno">
    <INPUT type="hidden" name="rows_cust_seq" id="rows_cust_seq">
    <INPUT type="hidden" name="rows_seq" id="rows_seq">
    <INPUT type="hidden" name="rows_seq1" id="rows_seq1">
    <INPUT type="hidden" name="rows_now_grade" id="rows_now_grade">
    <INPUT type="hidden" name="rows_step_grade" id="rows_step_grade">
    <INPUT type="hidden" name="rows_nstep_grade" id="rows_nstep_grade">
    <INPUT type="hidden" name="rows_rectitle_name" id="rows_rectitle_name">
    <INPUT type="hidden" name="rows_tmprectitle_name" id="rows_tmprectitle_name">
    <INPUT type="hidden" name="rows_att_sqlno" id="rows_att_sqlno">
    <INPUT type="hidden" name="rows_send_way" id="rows_send_way">
    <INPUT type="hidden" name="rows_case_no" id="rows_case_no">
    <INPUT type="hidden" name="rows_rs_type" id="rows_rs_type">
    <INPUT type="hidden" name="rows_rs_agt_no" id="rows_rs_agt_no">
    <INPUT type="hidden" name="rows_rs_agt_nonm" id="rows_rs_agt_nonm">
    <INPUT type="hidden" name="rows_case_agt_no" id="rows_case_agt_no">
    <INPUT type="hidden" name="rows_case_agt_name" id="rows_case_agt_name">
    <INPUT type="hidden" name="rows_fees_stat" id="rows_fees_stat">
    <INPUT type="hidden" name="rows_opt_branch" id="rows_opt_branch">
    <INPUT type="hidden" name="rows_dmt_pay_times" id="rows_dmt_pay_times">
    <INPUT type="hidden" name="rows_rs_no" id="rows_rs_no">
    <INPUT type="hidden" name="rows_spe_ctrl_4" id="rows_spe_ctrl_4">

    <INPUT type="hidden" name="rows_ctrl_num" id="rows_ctrl_num">
    <INPUT type="hidden" name="rows_rsqlno" id="rows_rsqlno">
    <INPUT type="hidden" name="rows_ctrl_type" id="rows_ctrl_type">
    <INPUT type="hidden" name="rows_ctrl_date" id="rows_ctrl_date">
    <INPUT type="hidden" name="rows_ctrl_remark" id="rows_ctrl_remark">
    <INPUT type="hidden" name="rows_fees" id="rows_fees">
    <INPUT type="hidden" name="rows_case_service" id="rows_case_service">
    <INPUT type="hidden" name="rows_case_fees" id="rows_case_fees">
    <INPUT type="hidden" name="rows_case_gs_fees" id="rows_case_gs_fees">
    <INPUT type="hidden" name="rows_case_gs_curr" id="rows_case_gs_curr">

    <INPUT type="hidden" name="rows_step_date" id="rows_step_date">
    <INPUT type="hidden" name="rows_mp_date" id="rows_mp_date">
    <INPUT type="hidden" name="rows_send_cl" id="rows_send_cl">
    <INPUT type="hidden" name="rows_send_cl1" id="rows_send_cl1">
    <INPUT type="hidden" name="rows_rs_class_name" id="rows_rs_class_name">
    <INPUT type="hidden" name="rows_rs_code_name" id="rows_rs_code_name">
    <INPUT type="hidden" name="rows_act_code_name" id="rows_act_code_name">
    <INPUT type="hidden" name="rows_rs_class" id="rows_rs_class">
    <INPUT type="hidden" name="rows_ncase_stat" id="rows_ncase_stat">
    <INPUT type="hidden" name="rows_ncase_statnm" id="rows_ncase_statnm">
    <INPUT type="hidden" name="rows_rs_code" id="rows_rs_code">
    <INPUT type="hidden" name="rows_act_code" id="rows_act_code">
    <INPUT type="hidden" name="rows_pr_scode" id="rows_pr_scode">
    <INPUT type="hidden" name="rows_rs_detail" id="rows_rs_detail">
    <INPUT type="hidden" name="rows_receipt_type" id="rows_receipt_type">
    <INPUT type="hidden" name="rows_receipt_title" id="rows_receipt_title">
    <INPUT type="hidden" name="rows_send_sel" id="rows_send_sel">
    <INPUT type="hidden" name="rows_apply_no" id="rows_apply_no">
    <INPUT type="hidden" name="rows_pay_times" id="rows_pay_times">
    <INPUT type="hidden" name="rows_pay_date" id="rows_pay_date">

    <asp:Repeater id="singleRepeater" runat="server">
    <HeaderTemplate>
        <table style="display:<%#page.totRow==0?"none":""%>" border="0" class="bluetable" cellspacing="1" cellpadding="2" width="100%" align="center" id="dataList">
	        <thead>
                  <Tr>
	                <td  class="lightbluetable" nowrap align="center" width=8%>作業</td>
	                <td  class="lightbluetable" nowrap align="center"><u class="setOdr" v1="a.seq,a.seq1">本所編號</u></td>
	                <td  class="lightbluetable" nowrap align="center">類別</td>
	                <td  class="lightbluetable" nowrap align="center">案件名稱</td>
	                <td  class="lightbluetable" nowrap align="center"><u class="setOdr" v1="a.in_scode">營洽</u></td> 
	                <td  class="lightbluetable" nowrap align="center"><u class="setOdr" v1="a.step_date,a.seq,a.seq1">預計發文日期</u></td> 
	                <td  class="lightbluetable" nowrap align="center">發文內容</td>
	                <td  class="lightbluetable" nowrap align="center">法定期限</td> 
	                <td  class="lightbluetable" nowrap align="center">接洽序號</td> 
                  </tr>
	        </thead>
	        <tbody>
    </HeaderTemplate>
			    <ItemTemplate>
 		            <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>">
		                <td align="center">
			                <a href="javascript:void(0)" onclick="linkedit(<%#(Container.ItemIndex+1)%>,'<%#Eval("seq")%>','<%#Eval("seq1")%>','U','<%#Eval("att_sqlno")%>','<%#Eval("fseq")%>','<%#Eval("todo_sqlno")%>')" >[確認]</a>
			                <a href="javascript:void(0)" onclick="linkedit(<%#(Container.ItemIndex+1)%>,'<%#Eval("seq")%>','<%#Eval("seq1")%>','R','<%#Eval("att_sqlno")%>','<%#Eval("fseq")%>','<%#Eval("todo_sqlno")%>')" >[退回]</a>
			                <input type="hidden" id="in_no_<%#(Container.ItemIndex+1)%>" value="<%#Eval("in_no")%>">
			                <input type="hidden" id="case_no_<%#(Container.ItemIndex+1)%>" value="<%#Eval("case_no")%>">
		                </td>
		                <td align="center"><%#Eval("fseq")%></td>
		                <td ><%#Eval("class")%></td>
		                <td ><%#Eval("appl_name").ToString().Left(20)%></td>
		                <td nowrap align="center"><%#Eval("sc_name")%></td>
		                <td align="center"><%#Eval("step_date","{0:yyyy/M/d}")%></td>
		                <td align="left"><%#Eval("rs_detail")%></td>
		                <td align="center"><%#Eval("last_date")%></td>
		                <td nowrap align="center"><%#Eval("in_no")%></td>
	                </tr>
			    </ItemTemplate>
    <FooterTemplate>
	        </tbody>
        </table>
	    <BR>

        <table style="display:<%#page.totRow==0?"none":""%>" border="0" width="100%" cellspacing="0" cellpadding="0">
		    <tr class="FormName"><td>
			    <div style="color:blue">
                    備註:<br>
                    ◎法定期限為本筆案件尚未銷管的最小法定期限。<br>
			    </div>
		    </td>
            </tr>
	    </table>
	    <br>
    </FooterTemplate>
    </asp:Repeater>

    <!--批次確認-->
    <asp:Repeater id="batchRepeater" runat="server">
    <HeaderTemplate>
        <table style="display:<%#page.totRow==0?"none":""%>" border="0" class="bluetable" cellspacing="1" cellpadding="2" width="100%" align="center" id="dataList">
	        <thead>
                <Tr>
	            <td  class="lightbluetable" nowrap align="center" rowspan="2">
		            <a href="javascript:void(0);" onclick="selectall()" style="color:darkblue" onmouseover="this.style.color='red'" onmouseout="this.style.color='darkblue'">全選</a>
	            </td>
	            <td  class="lightbluetable" nowrap align="center"><u class="setOdr" v1="a.seq,a.seq1">本所編號</u></td>
	            <td  class="lightbluetable" nowrap align="center">類別</td>
	            <td  class="lightbluetable" nowrap align="center">案件名稱</td> 
	            <td  class="lightbluetable" nowrap align="center"><u class="setOdr" v1="a.in_scode">營洽</u></td>
	            <td  class="lightbluetable" nowrap align="center"><u class="setOdr" v1="a.step_date,a.seq,a.seq1">預計發文日期</td>
	            <td  class="lightbluetable" nowrap align="center">發文內容</td>
	            <td  class="lightbluetable" nowrap align="center">法定期限</td>
	            <td  class="lightbluetable" nowrap align="center">接洽序號</td>
	            <td  class="lightbluetable" nowrap align="center" rowspan=2>管制</td> 
                </tr>
                <Tr>
	            <td class="lightbluetable" nowrap align="center">規費支出</td>
	            <td class="lightbluetable" nowrap align="center" colspan=7>發文內容</td>
                </tr>
	        </thead>
	        <tbody>
    </HeaderTemplate>
	<ItemTemplate>
 	    <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>">
		    <td align="center" rowspan=2>
                <input type=checkbox id=chk_<%#(Container.ItemIndex+1)%> onclick="chk_flag_onclick(<%#(Container.ItemIndex+1)%>)" value='Y'>
			    <BR>
			    <input type="hidden" id="cgrs_<%#(Container.ItemIndex+1)%>" value="GS">
			    <input type="hidden" id="todo_sqlno_<%#(Container.ItemIndex+1)%>" value="<%#Eval("todo_sqlno")%>">
			    <input type="hidden" id="cust_seq_<%#(Container.ItemIndex+1)%>" value="<%#Eval("cust_seq")%>">
			    <input type="hidden" id="seq_<%#(Container.ItemIndex+1)%>" value="<%#Eval("seq")%>">
			    <input type="hidden" id="seq1_<%#(Container.ItemIndex+1)%>" value="<%#Eval("seq1")%>">
			    <input type="hidden" id="now_grade_<%#(Container.ItemIndex+1)%>" value="<%#Eval("now_grade")%>">
			    <input type="hidden" id="step_grade_<%#(Container.ItemIndex+1)%>" value="<%#Eval("step_grade")%>">
			    <input type="hidden" id="nstep_grade_<%#(Container.ItemIndex+1)%>" value="<%#Convert.ToInt32(Eval("step_grade"))+1%>">
			    <input type="hidden" id="rectitle_name_<%#(Container.ItemIndex+1)%>" value="<%#Eval("rectitle_name")%>">
			    <input type="hidden" id="tmprectitle_name_<%#(Container.ItemIndex+1)%>" value="<%#Eval("tmprectitle_name")%>">
			    <input type="hidden" id="att_sqlno_<%#(Container.ItemIndex+1)%>" value="<%#Eval("att_sqlno")%>">
			    <input type="hidden" id="send_way_<%#(Container.ItemIndex+1)%>" value="<%#Eval("send_way")%>">
			    <input type="hidden" id="in_no_<%#(Container.ItemIndex+1)%>" value="<%#Eval("in_no")%>">
			    <input type="hidden" id="case_no_<%#(Container.ItemIndex+1)%>" value="<%#Eval("case_no")%>">
			    <input type="hidden" id="rs_type_<%#(Container.ItemIndex+1)%>" value="<%#Eval("rs_type")%>">
			    <input type="hidden" id="rs_agt_no_<%#(Container.ItemIndex+1)%>" value="<%#Eval("rs_agt_no")%>"><!--案性出名代理人-->
			    <input type="hidden" id="rs_agt_nonm_<%#(Container.ItemIndex+1)%>" value="<%#Eval("rs_agt_nonm")%>"><!--案性出名代理人-->
			    <input type="hidden" id="case_agt_no_<%#(Container.ItemIndex+1)%>" value="<%#Eval("case_agt_no")%>" /><!--交辦代理人-->
			    <input type="hidden" id="case_agt_name_<%#(Container.ItemIndex+1)%>" value="<%#Eval("case_agt_name")%>" /><!--交辦代理人-->
			    <input type="hidden" id="fees_stat_<%#(Container.ItemIndex+1)%>" value="<%#Eval("fees_stat")%>"><!--收費管制-->
			    <input type="hidden" id="opt_branch_<%#(Container.ItemIndex+1)%>" value="<%#Eval("opt_branch")%>"><!--發文單位-->
			    <input type="hidden" id="dmt_pay_times_<%#(Container.ItemIndex+1)%>" value="<%#Eval("pay_times")%>"><!--註冊費已繳-->
			    <input type="hidden" id="rs_no_<%#(Container.ItemIndex+1)%>" value="">
			    <input type="hidden" id="spe_ctrl_4_<%#(Container.ItemIndex+1)%>" value="<%#Eval("spe_ctrl_4")%>"><!--該案性可用發文方式-->
			    <a href="javascript:void(0)" onclick="linkedit(<%#(Container.ItemIndex+1)%>,'<%#Eval("seq")%>','<%#Eval("seq1")%>','U','<%#Eval("att_sqlno")%>','<%#Eval("fseq")%>','<%#Eval("todo_sqlno")%>')" >[確認]</a>
			    <BR>
			    <a href="javascript:void(0)" onclick="linkedit(<%#(Container.ItemIndex+1)%>,'<%#Eval("seq")%>','<%#Eval("seq1")%>','R','<%#Eval("att_sqlno")%>','<%#Eval("fseq")%>','<%#Eval("todo_sqlno")%>')" >[退回]</a>
		    </td>
		    <td align="center"><%#Eval("fseq")%></td>
		    <td ><%#Eval("class")%></td>
		    <td ><%#Eval("appl_name").ToString().Left(20)%></td>
		    <td nowrap align="center"><%#Eval("sc_name")%></td>
		    <td align="center"><%#Eval("step_date","{0:yyyy/M/d}")%></td>
		    <td align="left"><%#Eval("rs_detail")%></td>
		    <td align="center"><%#Eval("last_date")%></td>
		    <td nowrap align="center"><%#Eval("in_no")%></td>
		    <td align="center" rowspan=2>
			    <a href="javascript:void(0)" onclick="ctrlWin(<%#(Container.ItemIndex+1)%>)" ><span id="ctrl_<%#(Container.ItemIndex+1)%>">[新增]</span></a>
			    <BR>
			    <a href="javascript:void(0)" onclick="disWin(<%#(Container.ItemIndex+1)%>)" ><span id="ctrl_<%#(Container.ItemIndex+1)%>">[銷管(<%#Eval("ectrlnum")%>)]</span></a>
			    <input type="hidden" id="ctrl_num_<%#(Container.ItemIndex+1)%>" value="<%#Eval("ectrlnum")%>"><!--銷管筆數-->
			    <input type="hidden" id="rsqlno_<%#(Container.ItemIndex+1)%>" value=""><!--銷管的序號-->
			    <input type="hidden" id="ctrl_type_<%#(Container.ItemIndex+1)%>" value=""><!--管制種類-->
			    <input type="hidden" id="ctrl_date_<%#(Container.ItemIndex+1)%>" value=""><!--管制日期-->
			    <input type="hidden" id="ctrl_remark_<%#(Container.ItemIndex+1)%>" value=""><!--說明-->
		    </td>
	    </tr>
 	    <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>">
		    <td align="center">
			    <input type=text id="fees_<%#(Container.ItemIndex+1)%>" value="<%#Eval("fees")%>" style="text-align:right" size=5>
			    <input type=hidden id="case_service_<%#(Container.ItemIndex+1)%>" value="<%#Eval("case_service")%>" size=5>
			    <input type=hidden id="case_fees_<%#(Container.ItemIndex+1)%>" value="<%#Eval("case_fees")%>" size=5><!--交辦規費-->
			    <input type=hidden id="case_gs_fees_<%#(Container.ItemIndex+1)%>" value="<%#Eval("case_gs_fees")%>" size=5><!--已支出規費-->
			    <input type=hidden id="case_gs_curr_<%#(Container.ItemIndex+1)%>" value="<%#Eval("case_gs_curr")%>" size=5><!--官發次數-->
		    </td>
		    <td align="left" colspan=7>
			    發文日期:<input type=text id="step_date_<%#(Container.ItemIndex+1)%>" value="<%#Eval("step_date","{0:yyyy/M/d}")%>" size="10" class="dateField">
			    總發文日期:<input type=text id="mp_date_<%#(Container.ItemIndex+1)%>" value="<%#Eval("mp_date","{0:yyyy/M/d}")%>" size="10" class="dateField">
			    發文對象:<Select id="send_cl_<%#(Container.ItemIndex+1)%>">
			    <!--發文對象--><%#GetSendCL(Container)%>
			    </SELECT>
			    副本對象:<Select id="send_cl1_<%#(Container.ItemIndex+1)%>">
			    <!--副本對象--><%#GetSendCL1(Container)%>
			    </SELECT>
			    <BR>
			    結構分類:
			    <input type="hidden" id="rs_class_name_<%#(Container.ItemIndex+1)%>" value="">
			    <input type="hidden" id="rs_code_name_<%#(Container.ItemIndex+1)%>" value="">
			    <input type="hidden" id="act_code_name_<%#(Container.ItemIndex+1)%>" value="">
			    <select id="rs_class_<%#(Container.ItemIndex+1)%>" disabled >
			    <!--結構分類--><%#GetRsClass(Container)%>
			    </select>
			    案性:
			    <input type=hidden id="ncase_stat_<%#(Container.ItemIndex+1)%>" value="">
			    <input type=hidden id="ncase_statnm_<%#(Container.ItemIndex+1)%>" value="">
			    <span id=span_rs_code>
				    <select id="rs_code_<%#(Container.ItemIndex+1)%>" onchange='rs_code_onchange1()' disabled >
			        <!--案性--><%#GetRsCode(Container)%>
				    </select>
			    </span>
			    處理事項:
			    <span id=span_act_code>
				    <select id="act_code_<%#(Container.ItemIndex+1)%>">
			        <!--處理事項--><%#GetActCode(Container)%>
				    </select>
			    </span>
			    承辦:<SELECT id="pr_scode_<%#(Container.ItemIndex+1)%>">
			        <!--承辦--><%#GetPrScode(Container)%>
			    </SELECT>
			    <BR>
			    發文內容:<input type="text" id="rs_detail_<%#(Container.ItemIndex+1)%>" size=60 value="<%#Eval("rs_detail")%>">
			    <BR>
			    <font color=blue>收據種類:</font>
			    <select id="receipt_type_<%#(Container.ItemIndex+1)%>">
				    <option value="P" <%#(Eval("receipt_type").ToString()=="P"?" selected":"")%>>紙本收據</option>
				    <option value="E" <%#(Eval("receipt_type").ToString()=="E"||Eval("receipt_type").ToString()==""?" selected":"")%>>電子收據</option>
			    </select>
			    <font color=blue>收據抬頭:</font>
			    <select id="receipt_title_<%#(Container.ItemIndex+1)%>" onchange="rectitle_chk(<%#(Container.ItemIndex+1)%>,'<%#Eval("in_no")%>')">
			        <!--收據抬頭--><%#GetReceiptTitle(Container)%>
			    </select>
			    官方號碼:<SELECT id="send_sel_<%#(Container.ItemIndex+1)%>" disabled>
			        <!--官方號碼--><%#GetSendSel(Container)%>
			    </SELECT>
			    <input type=text id="apply_no_<%#(Container.ItemIndex+1)%>" value="<%#Eval("apply_no")%>" size="10" readonly class="SEdit">
			    註冊費已繳:<Select id="pay_times_<%#(Container.ItemIndex+1)%>" disabled>
			        <!--註冊費已繳--><%#GetOptPayTimes(Container)%>
			    </SELECT>
			    <input type=text id="pay_date_<%#(Container.ItemIndex+1)%>" value="<%#Eval("pay_date","{0:yyyy/M/d}")%>" size="10" readonly class="SEdit">
		    </td>
	    </tr>
	</ItemTemplate>
    <FooterTemplate>
	        </tbody>
        </table>
	    <BR>

	    <%if (ReqVal.TryGet("qrysend_way") == "EA") {%>
        <div style="text-align:center">
	    <br>
	    <input type=button name="button1" id="button1" value="承辦完成確認" class="cbutton" onClick="formAddSubmit('conf')">
        </div>
	    <%}%>

        <table style="display:<%#page.totRow==0?"none":""%>" border="0" width="100%" cellspacing="0" cellpadding="0">
		    <tr class="FormName"><td>
			    <div style="color:blue">
                    備註:<br>
                    ◎法定期限為本筆案件尚未銷管的最小法定期限。<br>
			    </div>
		    </td>
            </tr>
	    </table>
	    <br>
    </FooterTemplate>
    </asp:Repeater>

    <%#DebugStr%>
</form>

<div id="dialog"></div>

<iframe id="ActFrame" name="ActFrame" src="about:blank" width="100%" height="500" style="display:none"></iframe>
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
        $("select[id^='act_code_']").each(function(idx) {
            $(this).trigger("change");
        });

        $(".Lock").lock();
        $("input.dateField").datepick();
    }

    //執行查詢
    function goSearch() {
        $("#regPage").submit();
    };
    //////////////////////
    //全選
    function selectall(){
        for (var j = 1; j <= CInt($("#row").val()) ; j++) {
            //沒有勾的觸發勾選
            if($("#chk_"+j).prop("checked")==false){
                $("#chk_"+j).click();
            }
        }
    }

    //單筆確認
    function linkedit(pno,tseq,tseq1,task,att_sqlno,fseq,todo_sqlno){
        //var url = getRootPath() + "/brt6m/Brt63_edit.aspx?prgid=brta38&cgrs=gs&seq=" + tseq + "&seq1=" + tseq1 + "&branch=<%=Session["seBranch"]%>&SubmitTask=" + task + "&att_sqlno=" + att_sqlno + "&fseq=" + fseq + "&todo_sqlno=" + todo_sqlno;
        var url = getRootPath() + "/brt6m/Brt63_edit.aspx?prgid=brta38&cgrs=gs&seq=" + tseq + "&seq1=" + tseq1 + "&branch=<%=Session["seBranch"]%>&SubmitTask=" + task + "&att_sqlno=" + att_sqlno + "&fseq=" + fseq + "&todo_sqlno=" + todo_sqlno+ "&in_no=" + $("#in_no_"+pno).val()+ "&case_no=" + $("#case_no_"+pno).val();
        window.parent.Eblank.location.href=url;
    }


    //管制
    function ctrlWin(pno){
        var url=getRootPath() + "/brtam/brta38_CtrlEdit.aspx?prgid=brta38&branch=<%=Session["seBranch"]%>&seq="+$("#seq_"+pno).val()+
	    "&seq1="+$("#seq1_"+pno).val()+"&pno="+pno+"&step_grade="+$("#nstep_grade_"+pno).val()+
	    "&submitTask=A";
        //window.open(url,"CtrlWinN","width=780 height=490 top=10 left=10 toolbar=no, menubar=no, location=no, directories=no resizeable=no status=no scrollbars=yes");
        $('#dialog')
        .html('<iframe style="border: 0px;" src="'+url+'" width="100%" height="100%"></iframe>')
        .dialog({autoOpen: true,modal: true,height: 420,width: 650,title: "新增管制"});
    }

    //銷管
    function disWin(pno){
        //官收確認或官發確認之進度銷管同新增
        var url=getRootPath() + "/brtam/brta21disEdit.aspx?prgid=brta38&branch=<%=Session["seBranch"]%>&seq="+$("#seq_"+pno).val()+
        "&seq1="+$("#seq1_"+pno).val()+"&qtype=N&rsqlno="+$("#rsqlno_"+pno).val()+"&step_grade="+$("#nstep_grade_"+pno).val()+
        "&submitTask=A&rtnCol=rsqlno_"+pno;
        //window.open(url,"DisWinN","width=780 height=490 top=10 left=10 toolbar=no, menubar=no, location=no, directories=no resizeable=no status=no scrollbars=yes");
        $('#dialog')
        .html('<iframe style="border: 0px;" src="'+url+'" width="100%" height="100%"></iframe>')
        .dialog({autoOpen: true,modal: true,height: 420,width: 650,title: "進度查詢及銷案設定"});
    }

    //全選
    function selectall(){
        $("input:checkbox[id^='chk'][id!='chkTest']").each(function(idx) {
            var pno=(idx+1);
            if($(this).prop("checked")){
                $("#chk_"+pno).prop( "checked" , false );
                //$("#hchk_flag_"+pno).val( "N");
            }else{
                $("#chk_"+pno).prop( "checked" , true );
                //$("#hchk_flag_"+pno).val( "Y");
            }
        });
    }

    //勾選某一筆
    function chk_flag_onclick(pchknum){
        if (document.getElementById("chk_"+pchknum).checked) {
            //$("#hchk_flag_"+pchknum).val( "Y");
        }else{
            //$("#hchk_flag_"+pchknum).val( "N");
        }
    }

    //取消選擇某一筆
    function cancelChk(pno){
        //$("#chk"+pno).prop("checked",false);
        //$("#hchk_flag_"+pno).val("N");
    }

    //選擇處理事項
    $("select[id^='act_code_']").change(function(){
        var idx=$("select[id^='act_code_']").index(this);
	
        $("input[id^='act_code_name_']:eq("+idx+")").val($(this).find(":selected").text());
	
        if ($(this).find(":selected").attr("vcase_stat")=== undefined){
            $("input[id^='ncase_stat_']:eq("+idx+")").val("");
        }else{
            $("input[id^='ncase_stat_']:eq("+idx+")").val($(this).find(":selected").attr("vcase_stat"));
        }
	
        if ($(this).find(":selected").attr("vcase_statnm")=== undefined){
            $("input[id^='ncase_statnm_']:eq("+idx+")").val("");
        }else{
            $("input[id^='ncase_statnm_']:eq("+idx+")").val($(this).find(":selected").attr("vcase_statnm"));
        }
    });

    //顯示及抓取收據抬頭
    function rectitle_chk(pno,pin_no){
        if(document.getElementById("receipt_title_" + pno).value=="A"){
            //案件申請人
            document.getElementById("rectitle_name_" + pno).value=document.getElementById("tmprectitle_name_" + pno).value;
        }else if(document.getElementById("receipt_title_" + pno).value=="C"){
            //案件申請人(代繳人)
            var tstr=document.getElementById("tmprectitle_name_" + pno).value+"(代繳人：聖島國際專利商標聯合事務所)";
            document.getElementById("rectitle_name_" + pno).value=tstr.substring(0,50);
        }else{
            document.getElementById("rectitle_name_" + pno).value="";
        }
    }

    //整批確認檢核
    function formAddSubmit(){
        $("select[id^='rs_class_']").each(function(idx) {
            $("input[id^='rs_class_name_']:eq("+idx+")").val($(this).find(":selected").text());
        });
	
        $("select[id^='rs_code_']").each(function(idx) {
            $("input[id^='rs_code_name_']:eq("+idx+")").val($(this).find(":selected").text());
        });
	
        //檢查是否有勾選
        var totnum=$("input[id^='chk_']:checked").length;
        if (totnum == 0){
            alert("請勾選您要確認的案件!!");
            return false;
        }
        var isSubmit=true;
        var msg="";
        for (var pno = 1; pno <= CInt($("#row").val()) ; pno++) {
            if($("#chk_"+pno).prop("checked")==true){
                if( chkNull("第"+pno+"筆 本所編號 ",$('#seq_'+pno)[0]) ) {isSubmit=false;}
                if( chkNull("第"+pno+"筆 本所編號副碼 ",$('#seq1_'+pno)[0]) ) {isSubmit=false;}
                if( chkNull("第"+pno+"筆 發文日期 ",$('#step_date_'+pno)[0]) ) {isSubmit=false;}
                if( chkNull("第"+pno+"筆 總發文日期 ",$('#mp_date_'+pno)[0]) ) {isSubmit=false;}
                if( chkNull("第"+pno+"筆 案性代碼 ",$('#rs_code_'+pno)[0]) ) {isSubmit=false;}
                if( chkNull("第"+pno+"筆 處理事項 ",$('#act_code_'+pno)[0]) ) {isSubmit=false;}
                if( chkNull("第"+pno+"筆 發文方式 ",$('#send_way_'+pno)[0]) ) {isSubmit=false;}
			
                if ($('#send_cl_'+pno).val()=="") {
                    cancelChk(pno);
                    msg+="第"+pno+"筆 發文對象必須輸入！\n";
                }
                if ($('#send_sel_'+pno).val()=="") {
                    cancelChk(pno);
                    msg+="第"+pno+"筆 官方號碼必須輸入！\n";
                }
                if ($('#apply_no_'+pno).val()=="") {
                    cancelChk(pno);
                    msg+="第"+pno+"筆 申請號必須輸入！\n";
                }
                if ($('#pr_scode_'+pno).val()=="") {
                    cancelChk(pno);
                    msg+="第"+pno+"筆 承辦必須輸入！\n";
                }
                if ($('#pay_date_'+pno).val()==""||$('#pay_times_'+pno).val()=="") {
                    cancelChk(pno);
                    msg+="第"+pno+"筆 註冊費已繳必須輸入！\n";
                }
                if ($('#dmt_pay_times_'+pno).val()!="") {
                    cancelChk(pno);
                    msg+="第"+pno+"筆 註冊費已繳不可重覆交辦！\n";
                }
			
                if($('#spe_ctrl_4_'+pno).val() != ""){
                    if (($('#spe_ctrl_4_'+pno).val()).indexOf("|"+$('#send_way_'+pno).val()+"|")==-1){
                        cancelChk(pno);
                        msg+="第"+pno+"筆 此案性發文方式不可批次確認！若需修改請執行[退回]作業，並請通知程序至國內案客戶收文作業修改後再發文。\n";
                    }
                }
                //20180525增加檢查發文日期/總發文日期不可小於系統日
                var sdate = CDate($('#step_date_'+pno).val());
                var mdate = CDate($('#mp_date_'+pno).val());
                if(sdate.getTime()< Today().getTime() || mdate.getTime()<Today().getTime()){
                    cancelChk(pno);
                    msg+="第"+pno+"筆 發文日期或總發文日期不可小於系統日！\n";
                }
			
                //若無交辦單號，本次支出大於0，不可存檔
                var tgs_fees=$('#fees_'+pno).val();
                if (tgs_fees!=""){
                    if (CInt(tgs_fees)>0 && $('#case_no_'+pno).val()==""){
                        cancelChk(pno);
                        msg+="第"+pno+"筆 若無交辦單號，本次支出不可大於零！\n";
                    }
                }
			
                if (CInt($("#fees_"+pno).val())!=CInt($("#case_fees_"+pno).val())){
                    cancelChk(pno);
                    msg+="第"+pno+"筆 本次官發規費支出("+$("#fees_"+pno).val()+")需等於規費支出("+CInt($("#case_fees_"+pno).val())+")！\n";
                }
			
                //檢查交辦與發文出名代理人不一樣，顯示提示訊息
                var tmp_agt_no=$("#case_agt_no_"+pno).val();
                if (tmp_agt_no != ""){
                    if ($.trim(tmp_agt_no)!=$.trim($("#rs_agt_no_"+pno).val())){
                        var answer=confirm("第"+pno+"筆 該交辦案件之出名代理人與發文出名代理人不同，是否確定要發文？(如需修改出名代理人請至交辦維護作業)");
                        if (!answer){
                            isSubmit=false;
                        }else{
                            $("#rs_agt_no_"+pno).val(tmp_agt_no);
                            $("#rs_agt_nonm_"+pno).val($("#case_agt_name_"+pno).val());
                        }
                    }
                }
			
                //檢查若有管制但未銷管，則顯示提示訊息
                var tmp_ctrl_num=CInt($("#ctrl_num_"+pno).val());
                if (tmp_ctrl_num != 0){
                    if( ($("#rsqlno_"+pno).val().split(";").length-1) < tmp_ctrl_num){
                        var answer=confirm("第"+pno+"筆 尚有管制未銷管，是否確定要發文？");
                        if (!answer){
                            isSubmit=false;
                        }
                    }
                }
			
                //註冊費繳納期數與發文案性關聯性檢查
                switch (document.getElementById("rs_code_"+pno).value) {
                    case "FF1":
                        document.getElementById("pay_date_"+pno).value = document.getElementById("step_date_"+pno).value;
                        if ($.trim(document.getElementById("pay_times_"+pno).value) != "1") {
                            var ans = confirm("註冊費已繳期數與發文案性不符, 是否將註冊費已繳期數更正為『 第一期 』?");
                            if (!ans) {
                                isSubmit=false;
                            }else{
                                document.getElementById("pay_times_"+pno).value = "1";
                            }
                        }
                        break;
                    case "FF2":
                        document.getElementById("pay_date_"+pno).value = document.getElementById("step_date_"+pno).value;
                        if ($.trim(document.getElementById("pay_times_"+pno).value) != "2") {
                            var ans = confirm("註冊費已繳期數與發文案性不符, 是否將註冊費已繳期數更正為『 第二期 』?");
                            if (ans != true) {
                                isSubmit=false;
                            }else{
                                document.getElementById("pay_times_"+pno).value = "2";
                            }
                        }
                        break;
                    case "FF3":
                        document.getElementById("pay_date_"+pno).value = document.getElementById("step_date_"+pno).value;
                        if ($.trim(document.getElementById("pay_times_"+pno).value) != "2") {
                            var ans = confirm("註冊費已繳期數與發文案性不符, 是否將註冊費已繳期數更正為『 第二期 』?");
                            if (ans != true) {
                                isSubmit=false;
                            }else{
                                document.getElementById("pay_times_"+pno).value = "2";
                            }
                        }
                        break;
                    case "FF0":
                        document.getElementById("pay_date_"+pno).value = document.getElementById("step_date_"+pno).value;
                        if ($.trim(document.getElementById("pay_times_"+pno).value) != "A") {
                            var ans = confirm("註冊費已繳期數與發文案性不符, 是否將註冊費已繳期數更正為『 全期 』?");
                            if (ans != true) {
                                isSubmit=false;
                            }else{
                                document.getElementById("pay_times_"+pno).value = "A";
                            }
                        }
                        break;
                }
            }
        }
	
        if(!isSubmit){
            return false;
        }
	
        if(msg!=""){
            alert(msg);
            return false;
        }
	
        if (!confirm("共有" + totnum + "筆確認 , 是否確定?")) return false;
        
        //串接資料
        $("#rows_chk").val(getJoinValue("#dataList>tbody input[id^='chk_']"));
        $("#rows_cgrs").val(getJoinValue("#dataList>tbody input[id^='cgrs_']"));
        $("#rows_todo_sqlno").val(getJoinValue("#dataList>tbody input[id^='todo_sqlno_']"));
        $("#rows_cust_seq").val(getJoinValue("#dataList>tbody input[id^='cust_seq_']"));
        $("#rows_seq").val(getJoinValue("#dataList>tbody input[id^='seq_']"));
        $("#rows_seq1").val(getJoinValue("#dataList>tbody input[id^='seq1_']"));
        $("#rows_now_grade").val(getJoinValue("#dataList>tbody input[id^='now_grade_']"));
        $("#rows_step_grade").val(getJoinValue("#dataList>tbody input[id^='step_grade_']"));
        $("#rows_nstep_grade").val(getJoinValue("#dataList>tbody input[id^='nstep_grade_']"));
        $("#rows_rectitle_name").val(getJoinValue("#dataList>tbody input[id^='rectitle_name_']"));
        $("#rows_tmprectitle_name").val(getJoinValue("#dataList>tbody input[id^='tmprectitle_name_']"));
        $("#rows_att_sqlno").val(getJoinValue("#dataList>tbody input[id^='att_sqlno_']"));
        $("#rows_send_way").val(getJoinValue("#dataList>tbody input[id^='send_way_']"));
        $("#rows_case_no").val(getJoinValue("#dataList>tbody input[id^='case_no_']"));
        $("#rows_rs_type").val(getJoinValue("#dataList>tbody input[id^='rs_type_']"));
        $("#rows_rs_agt_no").val(getJoinValue("#dataList>tbody input[id^='rs_agt_no_']"));
        $("#rows_rs_agt_nonm").val(getJoinValue("#dataList>tbody input[id^='rs_agt_nonm_']"));
        $("#rows_case_agt_no").val(getJoinValue("#dataList>tbody input[id^='case_agt_no_']"));
        $("#rows_case_agt_name").val(getJoinValue("#dataList>tbody input[id^='case_agt_name_']"));
        $("#rows_fees_stat").val(getJoinValue("#dataList>tbody input[id^='fees_stat_']"));
        $("#rows_opt_branch").val(getJoinValue("#dataList>tbody input[id^='opt_branch_']"));
        $("#rows_dmt_pay_times").val(getJoinValue("#dataList>tbody input[id^='dmt_pay_times_']"));
        $("#rows_rs_no").val(getJoinValue("#dataList>tbody input[id^='rs_no_']"));
        $("#rows_spe_ctrl_4").val(getJoinValue("#dataList>tbody input[id^='spe_ctrl_4_']"));

        $("#rows_ctrl_num").val(getJoinValue("#dataList>tbody input[id^='ctrl_num_']"));
        $("#rows_rsqlno").val(getJoinValue("#dataList>tbody input[id^='rsqlno_']"));
        $("#rows_ctrl_type").val(getJoinValue("#dataList>tbody input[id^='ctrl_type_']"));
        $("#rows_ctrl_date").val(getJoinValue("#dataList>tbody input[id^='ctrl_date_']"));
        $("#rows_ctrl_remark").val(getJoinValue("#dataList>tbody input[id^='ctrl_remark_']"));

        $("#rows_fees").val(getJoinValue("#dataList>tbody input[id^='fees_']:not([id^='fees_stat_'])"));
        $("#rows_case_service").val(getJoinValue("#dataList>tbody input[id^='case_service_']"));
        $("#rows_case_fees").val(getJoinValue("#dataList>tbody input[id^='case_fees_']"));
        $("#rows_case_gs_fees").val(getJoinValue("#dataList>tbody input[id^='case_gs_fees_']"));
        $("#rows_case_gs_curr").val(getJoinValue("#dataList>tbody input[id^='case_gs_curr_']"));

        $("#rows_step_date").val(getJoinValue("#dataList>tbody input[id^='step_date_']"));
        $("#rows_mp_date").val(getJoinValue("#dataList>tbody input[id^='mp_date_']"));
        $("#rows_send_cl").val(getJoinValue("#dataList>tbody select[id^='send_cl_']"));
        $("#rows_send_cl1").val(getJoinValue("#dataList>tbody select[id^='send_cl1_']"));
        $("#rows_rs_class_name").val(getJoinValue("#dataList>tbody input[id^='rs_class_name_']"));
        $("#rows_rs_code_name").val(getJoinValue("#dataList>tbody input[id^='rs_code_name_']"));
        $("#rows_act_code_name").val(getJoinValue("#dataList>tbody input[id^='act_code_name_']"));
        $("#rows_rs_class").val(getJoinValue("#dataList>tbody select[id^='rs_class_']"));
        $("#rows_ncase_stat").val(getJoinValue("#dataList>tbody input[id^='ncase_stat_']"));
        $("#rows_ncase_statnm").val(getJoinValue("#dataList>tbody input[id^='ncase_statnm_']"));
        $("#rows_rs_code").val(getJoinValue("#dataList>tbody select[id^='rs_code_']"));
        $("#rows_act_code").val(getJoinValue("#dataList>tbody select[id^='act_code_']"));
        $("#rows_pr_scode").val(getJoinValue("#dataList>tbody select[id^='pr_scode_']"));
        $("#rows_rs_detail").val(getJoinValue("#dataList>tbody input[id^='rs_detail_']"));
        $("#rows_receipt_type").val(getJoinValue("#dataList>tbody select[id^='receipt_type_']"));
        $("#rows_receipt_title").val(getJoinValue("#dataList>tbody select[id^='receipt_title_']"));
        $("#rows_send_sel").val(getJoinValue("#dataList>tbody select[id^='send_sel_']"));
        $("#rows_apply_no").val(getJoinValue("#dataList>tbody input[id^='apply_no_']"));
        $("#rows_pay_times").val(getJoinValue("#dataList>tbody select[id^='pay_times_']"));
        $("#rows_pay_date").val(getJoinValue("#dataList>tbody input[id^='pay_date_']"));
        
        $("input:disabled, select:disabled").unlock();
        $(".bsubmit").lock(!$("#chkTest").prop("checked"));
        
        var formData = new FormData($('#reg')[0]);
        ajaxByForm("brta38_UpdateBatch.aspx?submitTask=A&cgrs=gs&prgid=<%=prgid%>",formData)
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
</script>