<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>

<script runat="server">
    protected string HTProgCap = "國內案承辦交辦發文作業";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "brt63";//程式檔名前綴
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
    protected string html_job_scode = "";
    protected string row_span = "1";

    DBHelper conn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    DBHelper cnn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    private void Page_Unload(System.Object sender, System.EventArgs e) {
        if (conn != null) conn.Dispose();
        if (cnn != null) conn.Dispose();
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
        StrFormBtnTop += "<a href=\"商標電子申請書製作操作說明.docx\" target=\"_blank\">[電子申請書製作操作說明]</a>";
        StrFormBtnTop += "<a href=\"區所商標電子申請承辦作業.pptx\" target=\"_blank\">[電子送件承辦操作說明]</a>";
        StrFormBtnTop += "<a class=\"imgRefresh\" href=\"javascript:void(0);\" >[重新整理]</a>";

        //承辦人員
        SQL = "select distinct a.job_scode,b.sc_name ";
        SQL += " from todo_dmt a,sysctrl.dbo.scode b where a.job_scode=b.scode ";
        SQL += " and a.syscode='" + Session["syscode"] + "' and dowhat='DP_GS' and job_status='NN'";
        html_job_scode = Util.Option(conn, SQL, "{job_scode}", "{job_scode}_{sc_name}", true, Sys.GetSession("scode"));

        //20180314增加批次註冊費
        if (ReqVal.TryGet("qrysend_way") == "EA") {
            row_span = "2";
        }

        //客收確認日(迄)
        if (ReqVal.TryGet("qrystep_dateE") == "") ReqVal["qrystep_dateE"] = DateTime.Today.ToShortDateString();

    }

    private void QueryData() {
        //抓取非電子送件件數
        SQL = "SELECT count(*) as num ";
        SQL += " FROM case_dmt a  ";
        SQL += " inner join todo_dmt t on t.syscode='" + Session["syscode"] + "' and t.in_no=a.in_no and t.job_status='NN' and dowhat='DP_GS' ";
        SQL += " inner join step_dmt s on a.seq=s.seq and a.seq1=s.seq1 and a.case_no=s.case_no and s.cg='C' and s.rs='R' ";
        SQL += " WHERE a.stat_code='YZ' and (a.mark='N' or a.mark is null) ";
        SQL += " and isnull(s.send_way,'') not in('E','EA') ";
        objResult = conn.ExecuteScalar(SQL);
        pcount = (objResult == DBNull.Value || objResult == null) ? "" : "(<font color=blue>" + objResult + "</font>件)";

        //抓取電子送件件數
        SQL = "SELECT count(*) as num ";
        SQL += " FROM case_dmt a  ";
        SQL += " inner join todo_dmt t on t.syscode='" + Session["syscode"] + "' and t.in_no=a.in_no and t.job_status='NN' and dowhat='DP_GS' ";
        SQL += " inner join step_dmt s on a.seq=s.seq and a.seq1=s.seq1 and a.case_no=s.case_no and s.cg='C' and s.rs='R' ";
        SQL += " WHERE a.stat_code='YZ' and (a.mark='N' or a.mark is null) ";
        SQL += " and s.send_way ='E' ";
        objResult = conn.ExecuteScalar(SQL);
        ecount = (objResult == DBNull.Value || objResult == null) ? "" : "(<font color=blue>" + objResult + "</font>件)";

        //抓取註冊費電子送件件數
        SQL = "SELECT count(*) as num ";
        SQL += " FROM case_dmt a  ";
        SQL += " inner join todo_dmt t on t.syscode='" + Session["syscode"] + "' and t.in_no=a.in_no and t.job_status='NN' and dowhat='DP_GS' ";
        SQL += " inner join step_dmt s on a.seq=s.seq and a.seq1=s.seq1 and a.case_no=s.case_no and s.cg='C' and s.rs='R' ";
        SQL += " WHERE a.stat_code='YZ' and (a.mark='N' or a.mark is null) ";
        SQL += " and s.send_way ='EA' ";
        objResult = conn.ExecuteScalar(SQL);
        rcount = (objResult == DBNull.Value || objResult == null) ? "" : "(<font color=blue>" + objResult + "</font>件)";

        SQL = "SELECT a.in_scode, a.in_no, a.service, a.fees,a.oth_money,a.arcase_type,a.arcase_class, b.appl_name,b.draw_file ";
        SQL += ",b.class, a.arcase, a.ar_mark, ISNULL(a.discount, 0) AS discount,b.eappl_name,b.eappl_name1,b.zname_type ";
        SQL += ",a.case_num, a.stat_code, a.cust_area, a.cust_seq, a.case_date,a.ar_code,a.ar_service,a.ar_fees,a.ar_curr ";
        SQL += ",a.discount_chk, d.cust_name, a.in_date,a.seq,a.seq1,a.case_no,a.gs_fees,a.mark as case_mark ";
        SQL += ",a.rectitle_flag,a.rectitle_name,a.receipt_type,a.receipt_title,a.contract_flag,a.contract_flag_date ";
        SQL += ",e.rs_detail AS case_name,e.rs_class  AS Ar_form,e.prt_code  AS prt_code, b.agt_no, s.send_way ";
        SQL += ",e.reportp  AS reportp,t.in_date as step_date,t.sqlno as todo_sqlno,s.rs_no,s.step_grade,s.step_date,s.opt_stat ";
        SQL += ",e.classp as erpt_code,isnull(at.att_sqlno,0) as att_sqlno ";
        SQL += ",(select code_name from cust_code where code_type='rpt_pr_t' and cust_code=e.classp) as report_name ";
        SQL += ",(select min(ctrl_date) from ctrl_dmt where rs_no=s.rs_no and branch=s.branch and seq=s.seq and seq1=s.seq1 and step_grade=s.step_grade and ctrl_type='A1') as ctrl_date ";
        SQL += ",(select cust_code from cust_code where code_type='rec_titleT' and mark='Y' and end_date is null )def_title ";
        SQL += ",a.service + a.fees+ a.oth_money AS othsum ";
        SQL += ",isnull(s.send_sel,at.send_sel)send_sel,isnull(at.pr_scode,s.pr_scode)pr_scode ";
        SQL += ",''link_remark,''button,''urlasp,''rs_agt_no,''rs_agt_nonm ";
        SQL += ",''fseq,''dmt_pay_times,''pay_times,''pay_date,''apply_no,''spe_ctrl_4,0 gs_fee,''mp_date,''gs_contract_flag ";
        SQL += " FROM case_dmt a ";
        SQL += " INNER JOIN dmt_temp b ON a.in_scode = b.in_scode AND a.in_no = b.in_no ";
        SQL += " inner join code_br e on e.rs_code=a.arcase AND e.dept = 'T' AND e.cr = 'Y' and e.no_code = 'N' and e.rs_type=a.arcase_type ";
        SQL += " INNER JOIN VIEW_Cust d ON a.cust_seq = d.cust_seq AND a.cust_area = d.cust_area ";
        SQL += " LEFT OUTER JOIN case_fee c ON a.arcase = c.rs_code and c.dept = 'T' AND c.country = 'T' AND (GETDATE() BETWEEN c.beg_date AND c.end_date) ";
        SQL += " inner join todo_dmt t on t.syscode='" + Session["syscode"] + "' and t.in_no=a.in_no and t.job_status='NN' and dowhat='DP_GS' ";
        SQL += " inner join step_dmt s on a.seq=s.seq and a.seq1=s.seq1 and a.case_no=s.case_no and s.cg='C' and s.rs='R' ";
        SQL += " left outer join attcase_dmt at on a.in_no=at.in_no and at.sign_stat='NN' ";
        SQL += " WHERE a.stat_code='YZ' ";
        SQL += " and (a.mark='N' or a.mark is null) And case_sqlno=0 ";

        if (ReqVal.TryGet("qrycase_dateS") != "") {
            SQL += "AND a.case_Date>='" + ReqVal["qrycase_dateS"] + "' ";
        }
        if (ReqVal.TryGet("qrycase_dateE") != "") {
            SQL += "AND a.case_Date<='" + ReqVal["qrycase_dateE"] + "' ";
        }
        if (ReqVal.TryGet("qrystep_dateS") != "") {
            SQL += "AND t.in_Date>='" + ReqVal["qrystep_dateS"] + " 00:00:00' ";
        }
        if (ReqVal.TryGet("qrystep_dateE") != "") {
            SQL += "AND t.in_Date<='" + ReqVal["qrystep_dateE"] + " 23:59:59' ";
        }
        if (ReqVal.TryGet("qrySeq") != "") {
            SQL += "AND a.Seq in ('" + ReqVal.TryGet("qrySeq").Replace(",", "','") + "') ";
        }
        if (ReqVal.TryGet("qrySeq1") != "") {
            SQL += "AND a.Seq1='" + ReqVal["qrySeq1"] + "' ";
        }
        if (ReqVal.TryGet("qryjob_scode") != "") {
            SQL += "AND t.job_scode='" + ReqVal["qryjob_scode"] + "' ";
        }

        if (ReqVal.TryGet("qrysend_way") == "") ReqVal["qrysend_way"] = "M";
        if (ReqVal.TryGet("qrysend_way") == "M") {
            SQL += "and isnull(s.send_way,'') not in('E','EA') ";
        } else {
            SQL += "AND s.send_way='" + Request["qrysend_way"] + "' ";
        }

        //2012/11/9依湯協理Email先依客收確認日、交辦日排序，日後再加可依各欄位排序
        ReqVal["qryOrder"] = ReqVal.TryGet("SetOrder", ReqVal.TryGet("qryOrder","t.in_date,a.case_date"));
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

            SQL = "Select remark from cust_code where cust_code='__' and code_type='" + dr["arcase_type"] + "'";
            objResult = conn.ExecuteScalar(SQL);
            string link_remark = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();
            dr["link_remark"] = link_remark;//案性版本連結

            //案號
            dr["fseq"] = Sys.formatSeq(dr.SafeRead("seq", ""), dr.SafeRead("seq1", ""), "", Sys.GetSession("seBranch"), Sys.GetSession("dept"));

            //總收發文日期
            //台北所總收發當天就會發文
            dr["mp_date"] =DateTime.Today.ToShortDateString();
            if (dr.SafeRead("send_way","")!="EA"){//不是註冊費電子送件則其他區所要加天數
                if(Sys.GetSession("seBranch")!="N"){
                    switch (DateTime.Today.DayOfWeek)
	                {
                        case DayOfWeek.Friday: dr["mp_date"]=DateTime.Today.AddDays(3).ToShortDateString(); break;//星期五加三天
                        case DayOfWeek.Saturday: dr["mp_date"]=DateTime.Today.AddDays(2).ToShortDateString(); break;//星期六加兩天
		                default: dr["mp_date"]=DateTime.Today.AddDays(1).ToShortDateString(); break;//加一天
	                }
                }
            }
                
            //發文規費
		    SQL="select fees from case_fee ";
		    SQL+=" where dept='T' and country='T' and rs_code='" + dr["arcase"] + "' and getdate() between beg_date and end_date";
            objResult = conn.ExecuteScalar(SQL);
		    dr["gs_fee"]=(objResult == DBNull.Value || objResult == null) ? 0 : Convert.ToInt32(objResult);

            dr["gs_contract_flag"] = dr.SafeRead("contract_flag", "").Trim();
            if (dr.SafeRead("contract_flag_date", "") != "") {//若已有契約書後補完成日，則表契約書已後補
                dr["gs_contract_flag"] = "N";
            }
                dr["gs_contract_flag"] = "Y";
        
            //註冊費已繳
            SQL = "select pay_times,pay_date,apply_no from dmt where seq=" + dr["seq"] + " and seq1='" + dr["seq1"] + "'";
            using (SqlDataReader dr1 = conn.ExecuteReader(SQL)) {
                if (dr1.Read()) {
                    dr["dmt_pay_times"] = dr1.SafeRead("pay_times", "");
                    dr["pay_times"] = dr1.SafeRead("pay_times", "");
                    dr["pay_date"] = dr1.GetDateTimeString("pay_date", "yyyy/M/d");
                    dr["apply_no"] = dr1.SafeRead("apply_no", "");
                }
            }

            if (dr.SafeRead("arcase", "") == "FF1") {
                if (dr.SafeRead("pay_times", "") == "") {
                    dr["pay_times"] = "1";
                }
            } else if (dr.SafeRead("arcase", "") == "FF2") {
                if (dr.SafeRead("pay_times", "") == "") {
                    dr["pay_times"] = "2";
                    dr["pay_date"] = DateTime.Today.ToString("yyyy/M/d");
                }
            } else if (dr.SafeRead("arcase", "") == "FF3") {
                if (dr.SafeRead("pay_times", "") == "") {
                    dr["pay_times"] = "2";
                    dr["pay_date"] = DateTime.Today.ToString("yyyy/M/d");
                }
            } else if (dr.SafeRead("arcase", "") == "FF0") {
                if (dr.SafeRead("pay_times", "") == "") {
                    dr["pay_times"] = "A";
                    dr["pay_date"] = DateTime.Today.ToString("yyyy/M/d");
                }
            }

            //抓可用的發文方式
            SQL = "select a.spe_ctrl from vcode_act a";
            SQL += " where cg='g' and rs='s' and gs='Y' and dept='" + Session["dept"] + "'";
            SQL += " and rs_code='" + dr["arcase"] + "' and act_code='_'";
            objResult = conn.ExecuteScalar(SQL);
            string spe_ctrl_4 = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();
            if (spe_ctrl_4 != "") spe_ctrl_4 = "|" + spe_ctrl_4.PadRight(5, ',').Split(',')[4] + "|";
            dr["spe_ctrl_4"] = spe_ctrl_4;

            //出名代理人
            DataTable agt = Sys.getCodeBrAgent(dr.SafeRead("arcase_type", ""), dr.SafeRead("arcase", ""),"gs", "U");
            if (agt.Rows.Count > 0) {
                dr["rs_agt_no"] = agt.Rows[0].SafeRead("rsagtno","");
                dr["rs_agt_nonm"] = agt.Rows[0].SafeRead("rsagtnm","");
            }
            
            dr["urlasp"] = GetCaseLink(dr);//交辦案號連結
            dr["button"] = GetButton(dr, i + 1);//作業
        }

        dataRepeater.DataSource = page.pagedTable;
        dataRepeater.DataBind();
    }

    //[作業]
    protected string GetButton(DataRow row, int nRow) {
        string rtn = "";
        string todo_name = "";
        string todo_link = "";//自行發文/專案室發文
        string todo_link1 = "";//發文維護
        string untodo_link = "";//不需發文

        if (row.SafeRead("opt_stat", "") == "" || row.SafeRead("opt_stat", "") == "X") {
            todo_name = "自行發文";
            todo_link = Page.ResolveUrl("~/brt6m/brt63_edit.aspx") + "?prgid=" + prgid+"&menu=N&submittask=A&cgrs=GS&todo_sqlno=" + row["todo_sqlno"] + "&seq=" + row["seq"] + "&seq1=" + row["seq1"] + "&in_scode=" + row["in_scode"] + "&in_no=" + row["in_no"] + "&case_no=" + row["case_no"] + "&rs_class=" + row["ar_form"] + "&rs_code=" + row["arcase"] + "&erpt_code=" + row["erpt_code"] + "&att_sqlno=" + row["att_sqlno"];
            todo_link1 = todo_link;
        }

        if (row.SafeRead("opt_stat", "") == "N") {
            todo_name = "專案室發文";
            string new_form = Sys.getCaseDmtAspx(row.SafeRead("arcase_type", ""), row.SafeRead("arcase", ""));//連結的aspx
            todo_link = Page.ResolveUrl("~/brt1m" + row.SafeRead("link_remark", "") + "/Brt11Edit" + new_form + ".aspx?prgid=" + prgid);
            todo_link += "&in_scode=" + row["in_scode"];
            todo_link += "&in_no=" + row["in_no"];
            todo_link += "&add_arcase=" + row["arcase"];
            todo_link += "&cust_area=" + row["cust_area"];
            todo_link += "&cust_seq=" + row["cust_seq"];
            todo_link += "&ar_form=" + row["ar_form"];
            todo_link += "&new_form=" + new_form;
            todo_link += "&code_type=" + row["arcase_type"];
            todo_link += "&homelist=" + Request["homelist"];
            todo_link += "&uploadtype=case";
            todo_link += "&submittask=Show";
            todo_link += "&todo_sqlno=" + row["todo_sqlno"];
            todo_link += "&rs_no=" + row["rs_no"];
            todo_link += "&seq=" + row["seq"];
            todo_link += "&seq1=" + row["seq1"];
            todo_link += "&case_no=" + row["case_no"];
            todo_link += "&ctrl_date=" + row.GetDateTimeString("ctrl_date", "yyyy/M/d");
            todo_link += "&step_grade=" + row["step_grade"];
            todo_link += "&step_date=" + row.GetDateTimeString("step_date","yyyy/M/d");
            todo_link += "&contract_flag=" + row["contract_flag"];

            todo_link1 = "brt63_edit.aspx?prgid=" + prgid + "&menu=N&submittask=A&cgrs=GS&todo_sqlno=" + row["todo_sqlno"] + "&seq=" + row["seq"] + "&seq1=" + row["seq1"] + "&in_scode=" + row["in_scode"] + "&in_no=" + row["in_no"] + "&case_no=" + row["case_no"] + "&rs_class=" + row["ar_form"] + "&rs_code=" + row["arcase"] + "&erpt_code=" + row["erpt_code"] + "&att_sqlno=" + row["att_sqlno"];
        }
        //950928為有關爭救案理由後補之收費情形,避免造成收費重覆新加入程式做控制,2010/8/6規費已支出不能發文	
        if (Convert.ToDecimal(row.SafeRead("gs_fees", "0")) > 0) {
            todo_name = "<font color=red>規費已支出</font>";
            todo_link = "";
        }
        //不需發文link
        untodo_link = Page.ResolveUrl("~/brt6m/brt63_edit.aspx") + "?prgid=" + prgid + "&menu=N&submittask=A&cgrs=GS&todo_sqlno=" + row["todo_sqlno"] + "&seq=" + row["seq"] + "&seq1=" + row["seq1"] + "&in_scode=" + row["in_scode"] + "&in_no=" + row["in_no"] + "&case_no=" + row["case_no"] + "&rs_class=" + row["ar_form"] + "&rs_code=" + row["arcase"] + "&task=cancel";

        string seq = row.SafeRead("seq", "");
        string seq1 = row.SafeRead("seq1", "");
        string step_grade = row.SafeRead("step_grade", "");
        string source = row.SafeRead("source", "");
        string attach_path = row.SafeRead("attach_path", "");
        string attach_sqlno = row.SafeRead("attach_sqlno", "");

        //抓確認當天有無其他進度
        SQL = "select count(*)cc from step_dmt where seq='" + row["seq"] + "' and seq1='" + row["seq1"] + "' and step_date='" + DateTime.Today.ToShortDateString() + "' and cg+rs in('CR','GS')";
        objResult = conn.ExecuteScalar(SQL);
        int same_count = (objResult == DBNull.Value || objResult == null) ? 0 : Convert.ToInt32(objResult);

        if (ReqVal.TryGet("qrysend_way") != "EA") {
            if (todo_name != "") {
                rtn = "[<a href=\"" + todo_link1 + "&task=prsave\" target=\"Eblank\">發文維護</a>]<BR>";
                rtn += "[<a href=\"" + todo_link + "&task=pr\" target=\"Eblank\">" + todo_name + "</a>]<BR>";
            }
            rtn += "[<a href=\"" + untodo_link + "\" target=\"Eblank\">不需發文</a>]<BR>";
        } else {
            rtn = "<input type=checkbox name=chk_" + nRow + " id=chk_" + nRow + " value='Y'>";
            if (same_count > 1) rtn += "<font color=red>*</font>";
        }

        return rtn;
    }

    protected string GetCaseLink(DataRow row) {
        string urlasp = "";//連結的url
        string new_form = Sys.getCaseDmtAspx(row.SafeRead("arcase_type", ""), row.SafeRead("arcase", ""));//連結的aspx

        urlasp = Page.ResolveUrl("~/brt5m" + row["link_remark"] + "/Brt52EDIT" + new_form + ".aspx?prgid=brt52");
        urlasp += "&in_scode=" + row["in_scode"];
        urlasp += "&in_no=" + row["in_no"];
        urlasp += "&case_no=" + row["case_no"];
        urlasp += "&seq=" + row["seq"];
        urlasp += "&seq1=" + row["seq1"];
        urlasp += "&add_arcase=" + row["arcase"];
        urlasp += "&cust_area=" + row["cust_area"];
        urlasp += "&cust_seq=" + row["cust_seq"];
        urlasp += "&ar_form=" + row["ar_form"];
        urlasp += "&new_form=" + new_form;
        urlasp += "&code_type=" + row["arcase_type"];
        urlasp += "&ar_code=" + row["ar_code"];
        urlasp += "&mark=" + row["case_mark"];
        urlasp += "&ar_service=" + row["ar_service"];
        urlasp += "&ar_fees=" + row["ar_fees"];
        urlasp += "&ar_curr=" + row["ar_curr"];
        urlasp += "&step_grade=" + row["step_grade"];
        urlasp += "&uploadtype=case";
        urlasp += "&submittask=Edit";
              
        return urlasp;
    }
    
    //申請書列印
    protected string GetPrintLink(RepeaterItem Container, string showSendWay) {
        string rtn = "";
        int i = Container.ItemIndex + 1;
        if (showSendWay.IndexOf(ReqVal.TryGet("qrysend_way")) > -1) {
            string erpt_code = Eval("erpt_code").ToString();
            string reportp = Eval("reportp").ToString();

            //有電子申請書優先
            if (erpt_code == "" & reportp != "") {//沒有電子申請書才顯示紙本申請書
                //***todo
                /*select reportp,classp,* from code_br 
                where reportp in('FD2','FC11','FC21','FL5','FT1','FP1','FP2','B5C1') --,'FOB'
                order by rs_class
                 */
                if (Eval("prt_code") != "ZZ" && Eval("prt_code") != "D9Z" && Eval("ar_form") != "D3") {
                    string prtUrl = Page.ResolveUrl("~/Report-word/Print_" + reportp + ".aspx?in_scode=" + Eval("in_scode") + "&in_no=" + Eval("in_no"));
                    rtn += "[<a href=\"" + prtUrl + "\" target=\"Eblank\">紙本申請書</a>]";
                }
            } else if (erpt_code != "") {
                if (ReqVal.TryGet("qrysend_way") == "E") {
                    //電子送件要依畫面所選收據種類列印,需要參數不同
                    rtn += "[<font style=\"cursor:pointer;color=darkblue\" onmouseover=\"this.style.color='red'\" onmouseout=\"this.style.color='darkblue'\" onclick=\"formPrintDNet_erpt("+i+",'" + Eval("in_scode") + "','" + Eval("in_no") + "','" + Eval("link_remark") + "','" + Eval("seq") + "','" + Eval("seq1") + "','" + Eval("erpt_code") + "')\">電子申請書</font>]";
                } else {
                    string prtUrl = Page.ResolveUrl("~/Report/Print_" + erpt_code + ".aspx?in_scode=" + Eval("in_scode") + "&in_no=" + Eval("in_no") + "&seq=" + Eval("seq") + "&seq1=" + Eval("seq1") + "&send_sel=" + Eval("send_sel"));
                    rtn += "[<a href=\"" + prtUrl + "\" target=\"Eblank\">電子申請書</a>]";
                }
            }

        }
        return rtn;
    }
    
    //商標圖檔
    protected string GetDrawFile(RepeaterItem Container) {
        string rtn = "";

        if (Eval("draw_file") != null && Eval("draw_file").ToString() != "") {
            rtn = "<img border=\"0\" src=\"" + Page.ResolveUrl("~/images/annex.gif") + "\" onclick=\"ViewAttach_dmt('" + Sys.Path2Nbtbrt(Eval("draw_file").ToString()) + "')\">";
        }
        return rtn;
    }

    //合計
    protected string GetSum(RepeaterItem Container) {
        int Service = Convert.ToInt32(DataBinder.Eval(Container.DataItem, "Service"));
        int fees = Convert.ToInt32(DataBinder.Eval(Container.DataItem, "fees"));
        int oth_money = Convert.ToInt32(DataBinder.Eval(Container.DataItem, "oth_money"));
        return (Service + fees + oth_money).ToString();
    }
    
    //官方號碼
    protected string GetOptSendSel(RepeaterItem Container) {
        string s_send_sel=DataBinder.Eval(Container.DataItem, "send_sel").ToString();
        if (s_send_sel=="")s_send_sel="1";
        return Sys.getCustCode("SEND_SEL","","").Option("{cust_code}","{code_name}",true,s_send_sel);
    }

    //註冊費已繳
    protected string GetOptPayTimes(RepeaterItem Container) {
        string pay_times = DataBinder.Eval(Container.DataItem, "pay_times").ToString();
        return Sys.getCustCode(Sys.GetSession("dept") + "PAY_TIMES", "", "sortfld").Option("{cust_code}", "{code_name}", true, pay_times);
    }

    //承辦
    protected string GetOptPrScode(RepeaterItem Container) {
        string pr_scode = DataBinder.Eval(Container.DataItem, "pr_scode").ToString();
        SQL="select a.scode,b.sc_name,a.sort ";
        SQL += " from scode_roles a inner join scode b on a.scode=b.scode";
        SQL += " where a.dept = '" + Session["dept"] + "' and syscode = '" + Session["seBranch"] + "TBRT' and prgid = 'brta21' ";
        SQL += " and roles = 'process' and branch = '" + Session["seBranch"] + "'";
        SQL += " order by sort";
        return Util.Option(cnn, SQL, "{scode}", "{scode}_{sc_name}", true, pr_scode);
    }

    //收據種類
    protected string GetReceiptType(RepeaterItem Container, string showSendWay) {
        string rtn = "";
        int i = Container.ItemIndex+1;
        string receipt_type = Eval("receipt_type").ToString();

        if (ReqVal.TryGet("qrysend_way") == showSendWay) {
            rtn += "<font color=blue>收據種類：</font>";
            rtn += "<select id=\"receipt_type_" + i + "\" disabled>";
            rtn += "	<option value=\"P\" " + (receipt_type == "P" ? "selected" : "") + ">紙本收據</option>";
            rtn += "	<option value=\"E\" " + (receipt_type == "E" ? "selected" : "") + ">電子收據</option>";
            rtn += "</select>";
        }
        return rtn;
    }

    //收據抬頭
    protected string GetReceiptTitle(RepeaterItem Container, string showSendWay) {
        string rtn = "";
        int i = Container.ItemIndex+1;
        string receipt_title = Eval("receipt_title").ToString();
        //如果DB無值則以設定檔為準
        if (receipt_title == "") receipt_title = Eval("def_title").ToString();

        if (ReqVal.TryGet("qrysend_way") == showSendWay) {

            string rectitle_name = Eval("rectitle_name").ToString();
            string tmprectitle_name = "";
            SQL = "Select a.ap_cname from dmt_temp_ap a where a.in_no='" + Eval("in_no") + "' and a.case_sqlno=0 order by a.server_flag desc,a.temp_ap_sqlno";
            using (SqlDataReader sdr = conn.ExecuteReader(SQL)) {
                while (sdr.Read()) {
                    tmprectitle_name += "、" + sdr.SafeRead("ap_cname", "").Trim();
                }
            }
            tmprectitle_name = tmprectitle_name.Substring(1);
            if (receipt_title == "A" && rectitle_name == "") {
                rectitle_name = tmprectitle_name;
            } else if (receipt_title == "C" && rectitle_name == "") {
                rectitle_name = tmprectitle_name + "(代繳人：聖島國際專利商標聯合事務所)";
            }

            string option = Sys.getCustCode("rec_titleT", "and end_date is null", "cust_code").Option("{cust_code}", "{code_name}", true, receipt_title);
            rtn += "<font color=blue>收據抬頭：</font>";
            rtn += "<select id=\"receipt_title_" + i + "\" onchange=\"rectitle_chk(" + i + ",'" + Eval("in_no") + "')\">";
            rtn += option;
            rtn += "</select>";
            rtn += "<span id=\"sp_rectitle_" + i + "\" align=\"left\" " + (receipt_title == "B" ? "style=\"display:none\"" : "") + ">";
            rtn += "<input type=\"text\" id=\"rectitle_name_" + i + "\" value=\"" + rectitle_name + "\" size=50 maxlength=50 readonly class=\"SEdit\">";
            rtn += "<input type=\"hidden\" id=\"tmprectitle_name_" + i + "\" value=\"" + tmprectitle_name + "\">";
            rtn += "</span>";
        }
        return rtn;
    }
    
    //契約書後補簽核
    protected string GetContractSign(RepeaterItem Container, string showSendWay) {
        string rtn = "";
        int i = Container.ItemIndex+1;
        string gs_contract_flag = Eval("gs_contract_flag").ToString();

        rtn += "<input type=hidden id=\"signid_" + i + "\">";
        if (gs_contract_flag == "Y") {
            //正常簽核
            string se_grpid = "000", mSC_code = "", mSC_name = "";
            Sys.getGrpidMaster(Sys.GetSession("SeBranch"), ref se_grpid, ref mSC_code, ref mSC_name);
            //特殊簽核
            DataRow[] drx = Sys.getGrpidUp("N", "000").Select("grplevel=1");
            //SQL = "select '3'id,'區所主管'tname,Master_scode,s.sc_name from Grpid g inner join scode s on g.Master_scode = s.scode where Grpid like '000' and grpclass='" + Session["seBranch"] + "' ";
            //SQL += "union all ";
            //SQL += "select '31'id,'區所主管代理'tname,agent_scode,s.sc_name from grpid g inner join scode s on g.agent_scode = s.scode where grpid like '000' and grpclass='" + Session["seBranch"] + "' and agent_scode not in ('" + mSC_code + "') ";

            rtn += "<label><input type=radio name=\"usesign_" + i + "\" id=\"usesign1_" + i + "\" checked>";
            rtn += "<strong>正常簽核:上級主管:</strong>" + mSC_name + "<input type=hidden id=\"Msign_" + i + "\" value=\"" + mSC_code + "\">";
            rtn += "</label><BR>";
            rtn += "<label><input type=radio name=\"usesign_" + i + "\" id=\"usesign2_" + i + "\">";
            rtn += "<strong>特殊處理:</strong></label>";
            rtn += "<select id=\"selectsign_" + i + "\" onclick=\"$('#usesign2_" + i + "').prop('checked',true)\">";
            rtn += "<option value=\"\" style=\"color:blue\">請選擇主管</option>";
            //rtn += Util.Option(cnn, SQL, "{master_scode}", "{tname}---{sc_name}", false);
            rtn += drx.Option("{master_scode}", "{master_type}---{master_nm}", false);
            rtn += "</select>";
            rtn += "";
        }
        return rtn;
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
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/jquery.datepick.min.js")%>"></script>
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
	        <td class="text9">
		        ◎承辦人員: <SELECT name="qryjob_scode" id="qryjob_scode"><%#html_job_scode%></SELECT>
	        </td>
	        <td class="text9">
		        ◎本所編號:<input type="text" name="qrySeq" id="qrySeq" size="30" value="">-<input type="text" name="qrySeq1" id="qrySeq1" size="2" value="">
	        </td>
        </tr>
        <tr>
	        <td class="text9">
		        ◎交辦日期: <input type="text" name="qrycase_DateS" id="qrycase_DateS" size="10" value="<%#ReqVal.TryGet("qrycase_dateS")%>" class="dateField">
                		~ <input type="text" name="qrycase_DateE" id="qrycase_DateE" size="10" value="<%#ReqVal.TryGet("qrycase_dateE")%>" class="dateField">
	        </td>
	        <td class="text9">
		        ◎客收確認日: <input type="text" name="qrystep_DateS" id="qrystep_DateS" size="10" value="<%#ReqVal.TryGet("qrystep_dateS")%>" class="dateField">
                		~ <input type="text" name="qrystep_DateE" id="qrystep_DateE" size="10" value="<%#ReqVal.TryGet("qrystep_dateE")%>" class="dateField">
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
    <INPUT type="hidden" name="rows_seq" id="rows_seq">
    <INPUT type="hidden" name="rows_seq1" id="rows_seq1">
    <INPUT type="hidden" name="rows_todo_sqlno" id="rows_todo_sqlno">
    <INPUT type="hidden" name="rows_eappl_name" id="rows_eappl_name">
    <INPUT type="hidden" name="rows_eappl_name1" id="rows_eappl_name1">
    <INPUT type="hidden" name="rows_zname_type" id="rows_zname_type">
    <INPUT type="hidden" name="rows_dmt_pay_times" id="rows_dmt_pay_times">
    <INPUT type="hidden" name="rows_spe_ctrl_4" id="rows_spe_ctrl_4">
    <INPUT type="hidden" name="rows_fees" id="rows_fees">
    <INPUT type="hidden" name="rows_case_fees" id="rows_case_fees">
    <INPUT type="hidden" name="rows_step_date" id="rows_step_date">
    <INPUT type="hidden" name="rows_mp_date" id="rows_mp_date">
    <INPUT type="hidden" name="rows_send_sel" id="rows_send_sel">
    <INPUT type="hidden" name="rows_apply_no" id="rows_apply_no">
    <INPUT type="hidden" name="rows_pay_times" id="rows_pay_times">
    <INPUT type="hidden" name="rows_pay_date" id="rows_pay_date">
    <INPUT type="hidden" name="rows_pr_scode" id="rows_pr_scode">

    <INPUT type="hidden" name="rows_send_way" id="rows_send_way">
    <INPUT type="hidden" name="rows_case_no" id="rows_case_no">
    <INPUT type="hidden" name="rows_send_cl" id="rows_send_cl">
    <INPUT type="hidden" name="rows_send_cl1" id="rows_send_cl1">
    <INPUT type="hidden" name="rows_in_scode" id="rows_in_scode">
    <INPUT type="hidden" name="rows_in_no" id="rows_in_no">
    <INPUT type="hidden" name="rows_rs_type" id="rows_rs_type">
    <INPUT type="hidden" name="rows_rs_class" id="rows_rs_class">
    <INPUT type="hidden" name="rows_rs_code" id="rows_rs_code">
    <INPUT type="hidden" name="rows_act_code" id="rows_act_code">
    <INPUT type="hidden" name="rows_rs_detail" id="rows_rs_detail">
    <INPUT type="hidden" name="rows_agt_no" id="rows_agt_no">
    <INPUT type="hidden" name="rows_fees_stat" id="rows_fees_stat">
    <INPUT type="hidden" name="rows_opt_branch" id="rows_opt_branch">
    <INPUT type="hidden" name="rows_contract_flag" id="rows_contract_flag">
    <INPUT type="hidden" name="rows_rs_agt_no" id="rows_rs_agt_no">
    <INPUT type="hidden" name="rows_rs_agt_nonm" id="rows_rs_agt_nonm">

    <INPUT type="hidden" name="rows_receipt_type" id="rows_receipt_type">
    <INPUT type="hidden" name="rows_receipt_title" id="rows_receipt_title">
    <INPUT type="hidden" name="rows_rectitle_name" id="rows_rectitle_name">
    <INPUT type="hidden" name="rows_tmprectitle_name" id="rows_tmprectitle_name">

    <INPUT type="hidden" name="rows_signid" id="rows_signid">

    <asp:Repeater id="dataRepeater" runat="server">
    <HeaderTemplate>
        <table style="display:<%#page.totRow==0?"none":""%>" border="0" class="bluetable" cellspacing="1" cellpadding="2" width="100%" align="center" id="dataList">
	        <thead>
                  <Tr>
	                <td  class="lightbluetable" nowrap align="center" rowspan="<%=row_span%>">
	                <%if (ReqVal.TryGet("qrysend_way") == "EA") {%>
		                <a href="javascript:void(0);" onclick="selectall()" style="color:darkblue" onmouseover="this.style.color='red'" onmouseout="this.style.color='darkblue'">全選</a>
	                <%}else{%>
		                作業
	                <%}%>
	                </td>
	                <td  class="lightbluetable" nowrap align="center"><u class="setOdr" v1="a.seq,a.seq1">本所編號</td>
	                <td  class="lightbluetable" nowrap align="center"><u class="setOdr" v1="a.in_scode,a.in_no">營洽薪號-接洽序號</td>
	                <td  class="lightbluetable" nowrap align="center"><u class="setOdr" v1="a.case_date">交辦日期</td>
	                <td  class="lightbluetable" nowrap align="center"><u class="setOdr" v1="t.in_date,a.case_date">客收確認日</td>
	                <td  class="lightbluetable" nowrap align="center"><u class="setOdr" v1="d.cust_name">客戶名稱</td> 
	                <td  class="lightbluetable" nowrap align="center">案件名稱</td> 
	                <td  class="lightbluetable" nowrap align="center">類別</td>
	                <td  class="lightbluetable" nowrap align="center">案性</td> 
	                <td  class="lightbluetable" nowrap align="center">服務費</td>
	                <td  class="lightbluetable" nowrap align="center">規費</td> 
	                <td  class="lightbluetable" nowrap align="center">轉帳<br>費用</td>
	                <td  class="lightbluetable" nowrap align="center">合計</td>  
                  </tr>
                  <Tr <%=((row_span == "1")?"style=\"display:none\"":"")%>>
	                <%=((row_span == "1")?"<td class=\"lightbluetable\"></td>":"")%>
	                <td class="lightbluetable" nowrap align="center">規費支出</td>
	                <td class="lightbluetable" nowrap align="center" colspan=6>發文內容</td>
	                <td class="lightbluetable" nowrap align="center" colspan=5>契約書後補簽核</td>
                  </tr>
	        </thead>
	        <tbody>
    </HeaderTemplate>
			    <ItemTemplate>
 		            <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>">
		                <td align="center" rowspan="<%=row_span%>">
		                    <input type="hidden" id="seq_<%#(Container.ItemIndex+1)%>" value="<%#Eval("seq")%>">
		                    <input type="hidden" id="seq1_<%#(Container.ItemIndex+1)%>" value="<%#Eval("seq1")%>">
		                    <input type="hidden" id="todo_sqlno_<%#(Container.ItemIndex+1)%>" value="<%#Eval("todo_sqlno")%>">
		                    <input type="hidden" id="eappl_name_<%#(Container.ItemIndex+1)%>" value="<%#Eval("eappl_name")%>">
		                    <input type="hidden" id="eappl_name1_<%#(Container.ItemIndex+1)%>" value="<%#Eval("eappl_name1")%>">
		                    <input type="hidden" id="zname_type_<%#(Container.ItemIndex+1)%>" value="<%#Eval("zname_type")%>">
		                    <input type="hidden" id="dmt_pay_times_<%#(Container.ItemIndex+1)%>" value="<%#Eval("dmt_pay_times")%>">
		                    <input type="hidden" id="spe_ctrl_4_<%#(Container.ItemIndex+1)%>" value="<%#Eval("spe_ctrl_4")%>"><!--該案性可用發文方式-->
			                <%#Eval("button")%>
		                </td>
		                <td align="center">
		                    <%#Eval("fseq")%>
		                    <img src="../images/icon2.gif" style="cursor:pointer" align="absmiddle" title="收發進度" WIDTH="25" HEIGHT="20" onclick="showStep('<%#Eval("seq")%>','<%#Eval("seq1")%>')">
		                </td>
		                <td align="center">
                            <a href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("in_scode")%>-<%#Eval("in_no")%></a>
                            <!--申請書列印--><%#GetPrintLink(Container,"M,E")%>
                            <!--商標圖檔--><%#GetDrawFile(Container)%>
                            <!--收據抬頭--><BR /><%#GetReceiptTitle(Container,"E")%>
		                </td>
		                <td align="center"><%#Eval("case_date","{0:yyyy/M/d}")%></td>
		                <td align="center"><%#Eval("step_date","{0:yyyy/M/d}")%></td>
		                <td align="center"><%#Eval("cust_name").ToString().Left(5)%></td>
		                <td><%#Eval("appl_name").ToString().Left(20)%></td>
		                <td><%#Eval("class")%></td>
		                <td align="center"><%#Eval("case_name")%></td>
		                <td align="right"><%#Eval("service")%></td>
		                <td align="right"><%#Eval("fees")%></td>
		                <td align="right"><%#Eval("oth_money")%></td>
		                <td align="right"><%#GetSum(Container)%></td>
				    </tr>
 		            <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>" <%=((row_span == "1")?"style=\"display:none\"":"")%>>
	                    <%=((row_span == "1")?"<td class=\"lightbluetable\"></td>":"")%>
		                <td nowrap align="center">
			                <input type=text id="fees_<%#(Container.ItemIndex+1)%>" value="<%#Eval("gs_fee")%>" style="text-align:right" size=5><!--收費標準-->
			                <input type=hidden  id="case_fees_<%#(Container.ItemIndex+1)%>" value="<%#Eval("fees")%>" size=5><!--交辦規費-->
		                </td>
		                <td colspan=6>
			                發文日期:<input type=text id="step_date_<%#(Container.ItemIndex+1)%>" value="<%#DateTime.Today.ToShortDateString()%>" size="10" class="dateField">
			                總發文日期:<input type=text id="mp_date_<%#(Container.ItemIndex+1)%>" value="<%#Eval("mp_date")%>" size="10" class="dateField">
			                官方號碼:<SELECT id="send_sel_<%#(Container.ItemIndex+1)%>" disabled><%#GetOptSendSel(Container)%></SELECT>
			                <input type=text id="apply_no_<%#(Container.ItemIndex+1)%>" value="<%#Eval("apply_no")%>" size="10" readonly class="SEdit">
			                註冊費已繳:<Select id="pay_times_<%#(Container.ItemIndex+1)%>" disabled><%#GetOptPayTimes(Container)%></SELECT>
			                <input type=text id="pay_date_<%#(Container.ItemIndex+1)%>" value="<%#Eval("pay_date")%>" size="10" readonly class="SEdit">
			                <BR>
			                承辦:<SELECT id="pr_scode_<%#(Container.ItemIndex+1)%>" ><%#GetOptPrScode(Container)%></SELECT>
                            <!--收據種類--><%#GetReceiptType(Container,"EA")%>
                            <!--收據抬頭--><%#GetReceiptTitle(Container,"EA")%>
			                <input type=hidden id="send_way_<%#(Container.ItemIndex+1)%>" value="<%#Eval("send_way")%>">
			                <input type=hidden id="case_no_<%#(Container.ItemIndex+1)%>" value="<%#Eval("case_no")%>">
			                <input type=hidden id="send_cl_<%#(Container.ItemIndex+1)%>" value="1"><!--發文對象-->
			                <input type=hidden id="send_cl1_<%#(Container.ItemIndex+1)%>" value=""><!--副本對象-->
			                <input type=hidden id="in_scode_<%#(Container.ItemIndex+1)%>" value="<%#Eval("in_scode")%>">
			                <input type=hidden id="in_no_<%#(Container.ItemIndex+1)%>" value="<%#Eval("in_no")%>">
			                <input type=hidden id="rs_type_<%#(Container.ItemIndex+1)%>" value="<%#Eval("arcase_type")%>">
			                <input type=hidden id="rs_class_<%#(Container.ItemIndex+1)%>" value="<%#Eval("arcase_class")%>">
			                <input type=hidden id="rs_code_<%#(Container.ItemIndex+1)%>" value="<%#Eval("arcase")%>">
			                <input type=hidden id="act_code_<%#(Container.ItemIndex+1)%>" value="_">
			                <input type=hidden id="rs_detail_<%#(Container.ItemIndex+1)%>" value="<%#Eval("case_name")%>">
			                <input type=hidden id="agt_no_<%#(Container.ItemIndex+1)%>" value="<%#Eval("agt_no")%>">
			                <input type=hidden id="fees_stat_<%#(Container.ItemIndex+1)%>" value="N"><!--收費管制-->
			                <input type=hidden id="opt_branch_<%#(Container.ItemIndex+1)%>" value="<%#Session["seBranch"]%>"><!--發文單位-->
			                <input type=hidden id="contract_flag_<%#(Container.ItemIndex+1)%>" value="<%#Eval("gs_contract_flag")%>">
			                <input type=hidden id="rs_agt_no_<%#(Container.ItemIndex+1)%>" value="<%#Eval("rs_agt_no")%>">
			                <input type=hidden id="rs_agt_nonm_<%#(Container.ItemIndex+1)%>" value="<%#Eval("rs_agt_nonm")%>">
		                </td>
		                <td nowrap colspan=5>
                            <!--契約書後補簽核--><%#GetContractSign(Container,"EA")%>
		                </td>
				    </tr>

			    </ItemTemplate>
    <FooterTemplate>
	        </tbody>
        </table>
	    <BR>

	    <%if (ReqVal.TryGet("qrysend_way") == "EA") {%>
        <div style="text-align:center">
	    <table id=tabar border=0 cellspacing="1" cellpadding="1" class="bluetable" align="center">
		    <tr>
			    <td class="lightbluetable" align="right" width="20%">承辦處理說明：</td>
			    <td class="whitetablebg" align="left">	
				    <textarea name="job_remark" rows="5" cols="65"></textarea>
			    </td>
		    </tr>
	    </table>
	    <br>
	    <input type=button name="button1" id="button1" value="承辦完成確認" class="cbutton" onClick="formAddSubmit('conf')">
        </div>
	    <%}%>

        <table style="display:<%#page.totRow==0?"none":""%>" border="0" width="100%" cellspacing="0" cellpadding="0">
		    <tr class="FormName"><td>
			    <div align="left">
                    備註:<br>
                    1.作業中「<font color="red">規費已支出</font>」表示該筆已官方發文！<br>
                    2.電子送件所連結的[電子申請書]及[基本資料表]已由系統產生html檔，請依<a href="商標電子申請書製作操作說明.docx" target="_blank">[電子申請書製作操作說明]</a>產製pdf檔。<br>
                    3.電子送件所需pdf檔完成後，請依<a href="區所商標電子申請承辦作業.pptx" target="_blank">[電子送件承辦操作說明]</a>上傳至系統。<br>
                    4.電子申請書的收據抬頭預設抓取第一位申請人的中文名稱，若有共同申請且需修改為另一位申請人，則請承辦自行於「收據抬頭」修改；<br>
                      另智慧局有限制收據抬頭欄位字數為50字(2015/9/2更新1.8.2版)，因此系統將只擷取前50個字顯示，承辦請再檢查，確認「收據抬頭」內容無誤後再產生電子申請書。<br>
                    5.批次確認中「<input type="checkbox"><font color="red">*</font>」表示同一天有其他進度
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

        theadOdr();//設定表頭排序圖示
        this_init();
    });

    function this_init() {
        if ((main.right & 64) == 0) {
            $("#qryjob_scode").lock();
        }

        if ($("#submittask").val() == "U" || $("#submittask").val() == "D" || $("#submittask").val() == "Q") {
            $("#seq,#seq1").lock();
        }
        $(".Lock").lock();
        $("input.dateField").datepick();
    }

    //執行查詢
    function goSearch() {
        $("#regPage").submit();
    };
    //每頁幾筆
    $("#PerPage").change(function (e) {
        goSearch();
    });
    //指定第幾頁
    $("#divPaging").on("change", "#GoPage", function (e) {
        goSearch();
    });
    //上下頁
    $(".pgU,.pgD").click(function (e) {
        $("#GoPage").val($(this).attr("v1"));
        goSearch();
    });
    //排序
    $(".setOdr").click(function (e) {
        $("#SetOrder").val($(this).attr("v1"));
        goSearch();
    });
    //設定表頭排序圖示
    function theadOdr() {
        $(".setOdr").each(function (i) {
            $(this).remove("span.odby");
            if ($(this).attr("v1").toLowerCase() == $("#SetOrder").val().toLowerCase()) {
                $(this).append("<span class='odby'>▲</span>");
            }
        });
    }
    //重新整理
    $(".imgRefresh").click(function (e) {
        goSearch();
    });
    //關閉視窗
    $(".imgCls").click(function (e) {
        if (window.parent.tt !== undefined) {
            window.parent.tt.rows = "100%,0%";
        } else {
            window.close();
        }
    })
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

    //顯示圖檔
    function ViewAttach_dmt(x){
        //window.open(x);
        $("#dialog").html('<img border="0" src="'+x+'"/><br/>');
        $("#dialog").dialog({
            title: '圖檔檢視',modal: true,maxHeight: 500,width: 800,closeOnEscape: true
        });
    }

    //顯示及抓取收據抬頭
    function rectitle_chk(pno,pin_no){
        $("#sp_rectitle_"+pno).show();
	
        if($("#receipt_title_" + pno).val()=="A"){
            //案件申請人
            $("#rectitle_name_" + pno).val($("#tmprectitle_name_" + pno).val());
        }else if($("#receipt_title_" + pno).val()=="C"){
            //案件申請人(代繳人)
            var tstr=$("#tmprectitle_name_" + pno).val()+"(代繳人：聖島國際專利商標聯合事務所)";
            $("#rectitle_name_" + pno).val(tstr.substring(0,50));
        }else{
            $("#rectitle_name_" + pno).val("");
            $("#sp_rectitle_"+pno).hide();
        }
    }

    //顯示收發進度
    function showStep(seq,seq1){
        //***todo
        window.open(getRootPath() + "/brtam/brta61Edit.aspx?submitTask=Q&qtype=A&prgid=<%=prgid%>&closewin=Y&winact=1&aseq=" +seq+ "&aseq1=" +seq1,"myWindowOne", "width=900 height=700 top=40 left=80 toolbar=no, menubar=no, location=no, directories=no resizeable=no status=no scrollbars=yes");
    }

    //20180323 改用.net產生電子申請書
    function formPrintDNet_erpt(pno,pin_scode,pin_no,link_remark,seq,seq1,prpt_code){
        //2014/6/23增加檢查，若要顯示外文，則內容為必填，不能只輸入語文別或中文字義，否則E-set驗證會有問題(案例ST39683)
        var peappl_name=document.getElementById("eappl_name_"+ pno).value;
        var peappl_name1=document.getElementById("eappl_name1_"+ pno).value;
        var pzname_type=document.getElementById("zname_type_"+ pno).value;
        var send_sel=document.getElementById("send_sel_"+ pno).value;
        if (peappl_name=="" && (peappl_name1!="" || pzname_type!="") ){
            alert("本案件若需顯示外文資料，則「外文」必須輸入資料，不能只輸入「語文別」或「中文字義」，以便正確產生電子申請書！");
            return false;
        }
	
        //2015/9/24增加收據抬頭註記及收據抬頭(因共同申請，先預設抓取第一個申請人，若不是由承辦修改)
        var preceipt_title=document.getElementById("receipt_title_"+ pno ).value;
        var prectitle_flag="N";
        if(preceipt_title=="A"){//案件申請人
            prectitle_flag="Y";
        }else if(preceipt_title=="C"){//案件申請人(代繳人)
            prectitle_flag="Y";
        }

        var urlasp =getRootPath() +"/Report" + link_remark + "/print_" + prpt_code + ".aspx";
        $('<form action="'+urlasp+'" target="Eblank">'+
            '<input type="text" name="in_scode" value="'+pin_scode+'"/>'+
            '<input type="text" name="in_no" value="'+pin_no+'"/>'+
            '<input type="text" name="seq" value="'+seq+'"/>'+
            '<input type="text" name="seq1" value="'+seq1+'"/>'+
            '<input type="text" name="rectitle_flag" value="'+prectitle_flag+'"/>'+
            '<input type="text" name="receipt_title" value="'+preceipt_title+'"/>'+
            '<input type="text" name="send_sel" value="'+send_sel+'"/>'+
        '</form>').appendTo('body').submit().remove();
    }

    //整批確認檢核
    function formAddSubmit(task){
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
			
                $("#signid_"+pno).val("");
                //若契約書尚未後補完成，則需轉區所主管簽核
                if ($("#contract_flag_"+pno).val()=="Y"){
                    if ($("input[name='usesign_"+pno+"']:eq(0)").prop("checked")){
                        $("#signid_"+pno).val($("#Msign_"+pno).val());
                    }else{
                        if($("#selectsign_"+pno+" option:selected").val()!=""){
                            $("#signid_"+pno).val($("#selectsign_"+pno+" option:selected").val());
                        }
                    }
                    if ($("#signid_"+pno).val()==""){
                        cancelChk(pno);
                        msg+="第"+pno+"筆 為契約書後補，需經主管簽核，請選擇主管！\n";
                    }
                }
			
                if ($('#send_sel_'+pno).val()=="") {
                    cancelChk(pno);
                    msg+="第"+pno+"筆 官方號碼必須輸入!!!\n";
                }
                if ($('#apply_no_'+pno).val()=="") {
                    cancelChk(pno);
                    msg+="第"+pno+"筆 申請號必須輸入!!!\n";
                }
                if ($('#dmt_pay_times_'+pno).val()!="") {
                    cancelChk(pno);
                    msg+="第"+pno+"筆 註冊費已繳不可重覆交辦!!!\n";
                }
                if ($('#pr_scode_'+pno).val()=="") {
                    cancelChk(pno);
                    msg+="第"+pno+"筆 承辦必須輸入!!!\n";
                }
			
                if($('#spe_ctrl_4_'+pno).val() != ""){
                    if (($('#spe_ctrl_4_'+pno).val()).indexOf("|"+$('#send_way_'+pno).val()+"|")==-1){
                        cancelChk(pno);
                        msg+="第"+pno+"筆 此案性發文方式不可批次確認！\n";
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
			
                //檢查交辦與發文出名代理人不一樣，顯示提示訊息
                if ($("#agt_no_"+pno).val() != ""){
                    if ($("#agt_no_"+pno).val()!=$.trim($("#rs_agt_no_"+pno).val())){
                        var answer=confirm("第"+pno+"筆 交辦案件之出名代理人與發文出名代理人不同，是否確定要發文？(如需修改出名代理人請至交辦維護作業)");
                        if (!answer){
                            isSubmit=false;
                        }
                    }
                }
			
                if (CDbl($("#fees_"+pno).val())!=CDbl($("#case_fees_"+pno).val())){
                    cancelChk(pno);
                    msg+="第"+pno+"筆 本次官發規費支出("+$("#fees_"+pno).val()+")需等於規費支出("+$("#case_fees_"+pno).val()+")!!!\n";
                }
			
                if ($("#rs_code_"+pno).val()=="FF1" || $("#rs_code_"+pno).val()=="FF2" 
                || $("#rs_code_"+pno).val()=="FF3" || $("#rs_code_"+pno).val()=="FF0"){
                    $("#pay_date_"+pno).val($("#step_date_"+pno).val());
                }
            }
        }
	
        if(msg!=""){
            alert(msg);
            return false;
        }
	
        if(!isSubmit){
            return false;
        }
	
        if (task=="conf"){
            //串接資料
            $("#rows_chk").val(getJoinValue("#dataList>tbody input[id^='chk_']"));
            $("#rows_seq").val(getJoinValue("#dataList>tbody input[id^='seq_']"));
            $("#rows_seq1").val(getJoinValue("#dataList>tbody input[id^='seq1_']"));
            $("#rows_todo_sqlno").val(getJoinValue("#dataList>tbody input[id^='todo_sqlno_']"));
            $("#rows_eappl_name").val(getJoinValue("#dataList>tbody input[id^='eappl_name_']"));
            $("#rows_eappl_name1").val(getJoinValue("#dataList>tbody input[id^='eappl_name1_']"));
            $("#rows_zname_type").val(getJoinValue("#dataList>tbody input[id^='zname_type_']"));
            $("#rows_dmt_pay_times").val(getJoinValue("#dataList>tbody input[id^='dmt_pay_times_']"));
            $("#rows_spe_ctrl_4").val(getJoinValue("#dataList>tbody input[id^='spe_ctrl_4_']"));
            $("#rows_fees").val(getJoinValue("#dataList>tbody input[id^='fees_']:not([id^='fees_stat_'])"));
            $("#rows_case_fees").val(getJoinValue("#dataList>tbody input[id^='case_fees_']"));
            $("#rows_step_date").val(getJoinValue("#dataList>tbody input[id^='step_date_']"));
            $("#rows_mp_date").val(getJoinValue("#dataList>tbody input[id^='mp_date_']"));
            $("#rows_send_sel").val(getJoinValue("#dataList>tbody select[id^='send_sel_']"));
            $("#rows_apply_no").val(getJoinValue("#dataList>tbody input[id^='apply_no_']"));
            $("#rows_pay_times").val(getJoinValue("#dataList>tbody select[id^='pay_times_']"));
            $("#rows_pay_date").val(getJoinValue("#dataList>tbody input[id^='pay_date_']"));
            $("#rows_pr_scode").val(getJoinValue("#dataList>tbody select[id^='pr_scode_']"));

            $("#rows_send_way").val(getJoinValue("#dataList>tbody input[id^='send_way_']"));
            $("#rows_case_no").val(getJoinValue("#dataList>tbody input[id^='case_no_']"));
            $("#rows_send_cl").val(getJoinValue("#dataList>tbody input[id^='send_cl_']"));
            $("#rows_send_cl1").val(getJoinValue("#dataList>tbody input[id^='send_cl1_']"));
            $("#rows_in_scode").val(getJoinValue("#dataList>tbody input[id^='in_scode_']"));
            $("#rows_in_no").val(getJoinValue("#dataList>tbody input[id^='in_no_']"));
            $("#rows_rs_type").val(getJoinValue("#dataList>tbody input[id^='rs_type_']"));
            $("#rows_rs_class").val(getJoinValue("#dataList>tbody input[id^='rs_class_']"));
            $("#rows_rs_code").val(getJoinValue("#dataList>tbody input[id^='rs_code_']"));
            $("#rows_act_code").val(getJoinValue("#dataList>tbody input[id^='act_code_']"));
            $("#rows_rs_detail").val(getJoinValue("#dataList>tbody input[id^='rs_detail_']"));
            $("#rows_agt_no").val(getJoinValue("#dataList>tbody input[id^='agt_no_']"));
            $("#rows_fees_stat").val(getJoinValue("#dataList>tbody input[id^='fees_stat_']"));
            $("#rows_opt_branch").val(getJoinValue("#dataList>tbody input[id^='opt_branch_']"));
            $("#rows_contract_flag").val(getJoinValue("#dataList>tbody input[id^='contract_flag_']"));
            $("#rows_rs_agt_no").val(getJoinValue("#dataList>tbody input[id^='rs_agt_no_']"));
            $("#rows_rs_agt_nonm").val(getJoinValue("#dataList>tbody input[id^='rs_agt_nonm_']"));

            $("#rows_receipt_type").val(getJoinValue("#dataList>tbody select[id^='receipt_type_']"));
            $("#rows_receipt_title").val(getJoinValue("#dataList>tbody select[id^='receipt_title_']"));
            $("#rows_rectitle_name").val(getJoinValue("#dataList>tbody input[id^='rectitle_name_']"));
            $("#rows_tmprectitle_name").val(getJoinValue("#dataList>tbody input[id^='tmprectitle_name_']"));

            $("#rows_signid").val(getJoinValue("#dataList>tbody input[id^='signid_']"));

            //$("select,textarea,input,span").unlock();
            $("input:disabled, select:disabled").unlock();
            $(".bsubmit").lock(!$("#chkTest").prop("checked"));

            var formData = new FormData($('#reg')[0]);
            ajaxByForm("Brt63_UpdateBatch.aspx?task="+task,formData)
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

    //取消選擇某一筆
    function cancelChk(pno){
        //$("#chk"+pno).attr("checked",false);
        //$("#hchk_flag"+pno).val("N");
    }

</script>