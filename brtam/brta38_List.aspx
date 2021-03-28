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
        SQL += ",''fseq,''last_date,''pay_times,''pay_date,''spe_ctrl_4,''ectrlnum ";
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

            //抓取本筆案件最小法定期限
            SQL = " select min(ctrl_date) as last_date from ctrl_dmt ";
            SQL += " where seq=" + dr["seq"] + " and seq1='" + dr["seq1"] + "' and ctrl_type like 'A%'";
            objResult = conn.ExecuteScalar(SQL);
            string last_date = (objResult == DBNull.Value || objResult == null) ? "" : Util.parseDBDate(objResult.ToString(), "yyyy/M/d");
            dr["last_date"] = last_date;

            //註冊費已繳
            if (dr.SafeRead("rs_code", "") == "FF1") {
                if (dr.SafeRead("pay_times", "") == "") {
                    dr["pay_times"] = "1";
                    dr["pay_date"] = dr.GetDateTimeString("step_date", "yyyy/M/d");
                }
            } else if (dr.SafeRead("rs_code", "") == "FF2") {
                if (dr.SafeRead("pay_times", "") == "") {
                    dr["pay_times"] = "2";
                    dr["pay_date"] = dr.GetDateTimeString("step_date", "yyyy/M/d");
                }
            } else if (dr.SafeRead("rs_code", "") == "FF3") {
                if (dr.SafeRead("pay_times", "") == "") {
                    dr["pay_times"] = "2";
                    dr["pay_date"] = dr.GetDateTimeString("step_date", "yyyy/M/d");
                }
            } else if (dr.SafeRead("rs_code", "") == "FF0") {
                if (dr.SafeRead("pay_times", "") == "") {
                    dr["pay_times"] = "A";
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
            Sys.showLog(SQL);
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
        SQL = "select a.scode,b.sc_name,a.sort ";
        SQL += " from scode_roles a inner join scode b on a.scode=b.scode";
        SQL += " where a.dept = '" + Session["dept"] + "' and syscode = '" + Session["seBranch"] + "TBRT' and prgid = 'brta21' ";
        SQL += " and roles = 'process' and branch = '" + Session["seBranch"] + "'";
        SQL += " order by sort";
        return Util.Option(cnn, SQL, "{scode}", "{scode}_{sc_name}", true, pr_scode);
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
        string pay_times = DataBinder.Eval(Container.DataItem, "pay_times").ToString();
        return Sys.getCustCode(Sys.GetSession("dept") + "PAY_TIMES", "", "sortfld").Option("{cust_code}", "{code_name}", true, pay_times);
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
                        <input type=checkbox name=chk_<%#(Container.ItemIndex+1)%> id=chk_<%#(Container.ItemIndex+1)%> onclick="chk_flag_onclick(<%#(Container.ItemIndex+1)%>)" value='Y'>
			            <BR>
			            <input type="text" name="hchk_flag_<%#(Container.ItemIndex+1)%>" id="hchk_flag_<%#(Container.ItemIndex+1)%>" value="N">
			            <input type="text" name="cgrs_<%#(Container.ItemIndex+1)%>" id="cgrs_<%#(Container.ItemIndex+1)%>" value="GS">
			            <input type="text" name="todo_sqlno_<%#(Container.ItemIndex+1)%>" id="todo_sqlno_<%#(Container.ItemIndex+1)%>" value="<%#Eval("todo_sqlno")%>">
			            <input type="text" name="cust_seq_<%#(Container.ItemIndex+1)%>" id="cust_seq_<%#(Container.ItemIndex+1)%>" value="<%#Eval("cust_seq")%>">
			            <input type="text" name="seq_<%#(Container.ItemIndex+1)%>" id="seq_<%#(Container.ItemIndex+1)%>" value="<%#Eval("seq")%>">
			            <input type="text" name="seq1_<%#(Container.ItemIndex+1)%>" id="seq1_<%#(Container.ItemIndex+1)%>" value="<%#Eval("seq1")%>">
			            <input type="text" name="now_grade_<%#(Container.ItemIndex+1)%>" id="now_grade_<%#(Container.ItemIndex+1)%>" value="<%#Eval("now_grade")%>">
			            <input type="text" name="step_grade_<%#(Container.ItemIndex+1)%>" id="step_grade_<%#(Container.ItemIndex+1)%>" value="<%#Eval("step_grade")%>">
			            <input type="text" name="nstep_grade_<%#(Container.ItemIndex+1)%>" id="nstep_grade_<%#(Container.ItemIndex+1)%>" value="<%#Convert.ToInt32(Eval("step_grade"))+1%>">
			            <input type="text" name="rectitle_name_<%#(Container.ItemIndex+1)%>" id="rectitle_name_<%#(Container.ItemIndex+1)%>" value="<%#Eval("rectitle_name")%>">
			            <input type="text" name="tmprectitle_name_<%#(Container.ItemIndex+1)%>" id="tmprectitle_name_<%#(Container.ItemIndex+1)%>" value="<%#Eval("tmprectitle_name")%>">
			            <input type="text" name="att_sqlno_<%#(Container.ItemIndex+1)%>" id="att_sqlno_<%#(Container.ItemIndex+1)%>" value="<%#Eval("att_sqlno")%>">
			            <input type="text" name="send_way_<%#(Container.ItemIndex+1)%>" id="send_way_<%#(Container.ItemIndex+1)%>" value="<%#Eval("send_way")%>">
			            <input type="text" name="case_no_<%#(Container.ItemIndex+1)%>" id="case_no_<%#(Container.ItemIndex+1)%>" value="<%#Eval("case_no")%>">
			            <input type="text" name="rs_type_<%#(Container.ItemIndex+1)%>" id="rs_type_<%#(Container.ItemIndex+1)%>" value="<%#Eval("rs_type")%>">
			            <input type="text" name="rs_agt_no_<%#(Container.ItemIndex+1)%>" id="rs_agt_no_<%#(Container.ItemIndex+1)%>" value="<%#Eval("rs_agt_no")%>"><!--案性出名代理人-->
			            <input type="text" name="rs_agt_nonm_<%#(Container.ItemIndex+1)%>" id="rs_agt_nonm_<%#(Container.ItemIndex+1)%>" value="<%#Eval("rs_agt_nonm")%>"><!--案性出名代理人-->
			            <input type="text" name="case_agt_no_<%#(Container.ItemIndex+1)%>" id="case_agt_no_<%#(Container.ItemIndex+1)%>" value="<%#Eval("case_agt_no")%>" /><!--交辦代理人-->
			            <input type="text" name="case_agt_name_<%#(Container.ItemIndex+1)%>" id="case_agt_name_<%#(Container.ItemIndex+1)%>" value="<%#Eval("case_agt_name")%>" /><!--交辦代理人-->
			            <input type="text" name="fees_stat_<%#(Container.ItemIndex+1)%>" id="fees_stat_<%#(Container.ItemIndex+1)%>" value="<%#Eval("fees_stat")%>"><!--收費管制-->
			            <input type="text" name="opt_branch_<%#(Container.ItemIndex+1)%>" id="opt_branch_<%#(Container.ItemIndex+1)%>" value="<%#Eval("opt_branch")%>"><!--發文單位-->
			            <input type="text" name="dmt_pay_times_<%#(Container.ItemIndex+1)%>" id="dmt_pay_times_<%#(Container.ItemIndex+1)%>" value="<%#Eval("pay_times")%>"><!--註冊費已繳-->
			            <input type="text" name="rs_no_<%#(Container.ItemIndex+1)%>" id="rs_no_<%#(Container.ItemIndex+1)%>" value="">
			            <input type="text" name="spe_ctrl_4_<%#(Container.ItemIndex+1)%>" id="spe_ctrl_4_<%#(Container.ItemIndex+1)%>" value="<%#Eval("spe_ctrl_4")%>"><!--該案性可用發文方式-->
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
			            <input type="text" name="ctrl_num_<%#(Container.ItemIndex+1)%>" id="ctrl_num_<%#(Container.ItemIndex+1)%>" value="<%#Eval("ectrlnum")%>"><!--銷管筆數-->
			            <input type="text" name="rsqlno_<%#(Container.ItemIndex+1)%>" id="rsqlno_<%#(Container.ItemIndex+1)%>" value=""><!--銷管的序號-->
			            <input type="text" name="ctrl_type_<%#(Container.ItemIndex+1)%>" id="ctrl_type_<%#(Container.ItemIndex+1)%>" value=""><!--管制種類-->
			            <input type="text" name="ctrl_date_<%#(Container.ItemIndex+1)%>" id="ctrl_date_<%#(Container.ItemIndex+1)%>" value=""><!--管制日期-->
			            <input type="text" name="ctrl_remark_<%#(Container.ItemIndex+1)%>" id="ctrl_remark_<%#(Container.ItemIndex+1)%>" value=""><!--說明-->
		            </td>
	            </tr>
 	            <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>">
		            <td align="center">
			            <input type=text name="fees_<%#(Container.ItemIndex+1)%>" id="fees_<%#(Container.ItemIndex+1)%>" value="<%#Eval("fees")%>" style="text-align:right" size=5>
			            <input type=text name="case_service_<%#(Container.ItemIndex+1)%>" id="case_service_<%#(Container.ItemIndex+1)%>" value="<%#Eval("case_service")%>" size=5>
			            <input type=text name="case_fees_<%#(Container.ItemIndex+1)%>" id="case_fees_<%#(Container.ItemIndex+1)%>" value="<%#Eval("case_fees")%>" size=5><!--交辦規費-->
			            <input type=text name="case_gs_fees_<%#(Container.ItemIndex+1)%>" id="case_gs_fees_<%#(Container.ItemIndex+1)%>" value="<%#Eval("case_gs_fees")%>" size=5><!--已支出規費-->
			            <input type=text name="case_gs_curr_<%#(Container.ItemIndex+1)%>" id="case_gs_curr_<%#(Container.ItemIndex+1)%>" value="<%#Eval("case_gs_curr")%>" size=5><!--官發次數-->
		            </td>
		<td align="left" colspan=7>
			發文日期:<input type=text name="step_date_<%#(Container.ItemIndex+1)%>" id="step_date_<%#(Container.ItemIndex+1)%>" value="<%#Eval("step_date","{0:yyyy/M/d}")%>" size="10" class="dateField">
			總發文日期:<input type=text name="mp_date_<%#(Container.ItemIndex+1)%>" id="mp_date_<%#(Container.ItemIndex+1)%>" value="<%#Eval("mp_date","{0:yyyy/M/d}")%>" size="10" class="dateField">
			發文對象:<Select NAME="send_cl_<%#(Container.ItemIndex+1)%>" id="send_cl_<%#(Container.ItemIndex+1)%>">
			<!--發文對象--><%#GetSendCL(Container)%>
			</SELECT>
			副本對象:<Select NAME="send_cl1_<%#(Container.ItemIndex+1)%>" id="send_cl1_<%#(Container.ItemIndex+1)%>">
			<!--副本對象--><%#GetSendCL1(Container)%>
			</SELECT>
			<BR>
			結構分類:
			<input type="text" name="rs_class_name_<%#(Container.ItemIndex+1)%>" id="rs_class_name_<%#(Container.ItemIndex+1)%>" value="">
			<input type="text" name="rs_code_name_<%#(Container.ItemIndex+1)%>" id="rs_code_name_<%#(Container.ItemIndex+1)%>" value="">
			<input type="text" name="act_code_name_<%#(Container.ItemIndex+1)%>" id="act_code_name_<%#(Container.ItemIndex+1)%>" value="">
			<select id="rs_class_<%#(Container.ItemIndex+1)%>" name="rs_class_<%#(Container.ItemIndex+1)%>" disabled >
			<!--結構分類--><%#GetRsClass(Container)%>
			</select>
			案性:
			<input type=text id="ncase_stat_<%#(Container.ItemIndex+1)%>" name="ncase_stat_<%#(Container.ItemIndex+1)%>" value="">
			<input type=text id="ncase_statnm_<%#(Container.ItemIndex+1)%>" name="ncase_statnm_<%#(Container.ItemIndex+1)%>" value="">
			<span id=span_rs_code>
				<select id="rs_code_<%#(Container.ItemIndex+1)%>" name="rs_code_<%#(Container.ItemIndex+1)%>" onchange='rs_code_onchange1()' disabled >
			    <!--案性--><%#GetRsCode(Container)%>
				</select>
			</span>
			處理事項:
			<span id=span_act_code>
				<select id="act_code_<%#(Container.ItemIndex+1)%>" name="act_code_<%#(Container.ItemIndex+1)%>">
			    <!--處理事項--><%#GetActCode(Container)%>
				</select>
			</span>
			承辦:<SELECT id="pr_scode_<%#(Container.ItemIndex+1)%>" name="pr_scode_<%#(Container.ItemIndex+1)%>">
			    <!--承辦--><%#GetPrScode(Container)%>
			</SELECT>
			<BR>
			發文內容:<input type="text" id="rs_detail_<%#(Container.ItemIndex+1)%>" name="rs_detail_<%#(Container.ItemIndex+1)%>" size=60 value="<%#Eval("rs_detail")%>">
			<BR>
			<font color=blue>收據種類:</font>
			<select id="receipt_type_<%#(Container.ItemIndex+1)%>" name="receipt_type_<%#(Container.ItemIndex+1)%>">
				<option value="P" <%#(Eval("receipt_type").ToString()=="P"?" selected":"")%>>紙本收據</option>
				<option value="E" <%#(Eval("receipt_type").ToString()=="E"||Eval("receipt_type").ToString()==""?" selected":"")%>>電子收據</option>
			</select>
			<font color=blue>收據抬頭:</font>
			<select id="receipt_title_<%#(Container.ItemIndex+1)%>" name="receipt_title_<%#(Container.ItemIndex+1)%>" onchange="rectitle_chk(<%#(Container.ItemIndex+1)%>,'<%#Eval("in_no")%>')">
			    <!--收據抬頭--><%#GetReceiptTitle(Container)%>
			</select>
			官方號碼:<SELECT name="send_sel_<%#(Container.ItemIndex+1)%>" id="send_sel_<%#(Container.ItemIndex+1)%>" disabled>
			    <!--官方號碼--><%#GetSendSel(Container)%>
			</SELECT>
			<input type=text name="apply_no_<%#(Container.ItemIndex+1)%>" id="apply_no_<%#(Container.ItemIndex+1)%>" value="<%#Eval("apply_no")%>" size="10" readonly class="SEdit">
			註冊費已繳:<Select NAME="pay_times_<%#(Container.ItemIndex+1)%>" id="pay_times_<%#(Container.ItemIndex+1)%>" disabled>
			    <!--註冊費已繳--><%#GetOptPayTimes(Container)%>
			</SELECT>
			<input type=text name="pay_date_<%#(Container.ItemIndex+1)%>" id="pay_date_<%#(Container.ItemIndex+1)%>" value="<%#Eval("pay_date","{0:yyyy/M/d}")%>" size="10" readonly class="SEdit">
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

        theadOdr();//設定表頭排序圖示
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

    //單筆確認
    function linkedit(pno,tseq,tseq1,task,att_sqlno,fseq,todo_sqlno){
        var url = getRootPath() + "/brt6m/Brt63_edit.aspx?prgid=brta38&cgrs=gs&seq=" + tseq + "&seq1=" + tseq1 + "&branch=<%=Session["seBranch"]%>&SubmitTask=" + task + "&att_sqlno=" + att_sqlno + "&fseq=" + fseq + "&todo_sqlno=" + todo_sqlno;
        window.parent.Eblank.location.href=url;
    }


    //管制
    function ctrlWin(pno){
        var url=getRootPath() + "/brtam/brta38CtrlEdit.aspx?branch=<%=Session["seBranch"]%>&seq="+$("#seq_"+pno).val()+
	"&seq1="+$("#seq1_"+pno).val()+"&pno="+pno+"&step_grade="+$("#nstep_grade_"+pno).val()+
	"&submitTask=A";
        window.open(url,"CtrlWin","width=780 height=490 top=10 left=10 toolbar=no, menubar=no, location=no, directories=no resizeable=no status=no scrollbars=yes");
    }

    //銷管
    function disWin(pno){
        //官收確認或官發確認之進度銷管同新增
        var url=getRootPath() + "/brtam/brta21disEdit.aspx?branch=<%=Session["seBranch"]%>&seq="+$("#seq_"+pno).val()+
        "&seq1="+$("#seq1_"+pno).val()+"&qtype=N&rsqlno="+$("#rsqlno_"+pno).val()+"&step_grade="+$("#nstep_grade_"+pno).val()+
        "&submitTask=A&rtnCol=rsqlno_"+pno;
        window.open(url,"DisWin","width=780 height=490 top=10 left=10 toolbar=no, menubar=no, location=no, directories=no resizeable=no status=no scrollbars=yes");
    }

    //全選
    function selectall(){
        $("input:checkbox[id^='chk'][id!='chkTest']").each(function(idx) {
            var pno=(idx+1);
            if($(this).attr("checked")){
                $("#chk"+pno).attr( "checked" , false );
                $("#hchk_flag"+pno).val( "N");
            }else{
                $("#chk"+pno).attr( "checked" , true );
                $("#hchk_flag"+pno).val( "Y");
            }
        });
    }

    //勾選某一筆
    function chk_flag_onclick(pchknum){
        if (document.getElementById("chk"+pchknum).checked) {
            document.getElementById("hchk_flag"+pchknum).value="Y";
        }else{
            document.getElementById("hchk_flag"+pchknum).value="N";
        }
    }

    //取消選擇某一筆
    function cancelChk(pno){
        //$("#chk"+pno).attr("checked",false);
        //$("#hchk_flag"+pno).val("N");
        //document.getElementById("chk"+pno).style.borderColor ="#3D7591";
        document.getElementById("chk"+pno).setAttribute("style","border-color: red");
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
        var totnum=$("input[id^='hchk_flag'][value=Y]").length;
        if (totnum == 0){
            alert("請勾選您要確認的案件!!");
            return false;
        }
        var isSubmit=true;
        var msg="";
        $("input[id^='hchk_flag']").each(function(idx) {
            var pno=(idx+1);
            if($(this).val()=="Y"){//hchk_flag
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
        });
	
        if(msg!=""){
            alert(msg);
            return false;
        }
	
        if(!isSubmit){
            return false;
        }
	
        if (!confirm("共有" + totnum + "筆確認 , 是否確定?")) return false;
        document.getElementById('reg').action = "brta38UpdateBatch.asp?submitTask=A&cgrs=gs";
        $("#reg :input").attr("disabled", false);
        if (document.getElementById("chkTest").checked) reg.target = "ActFrame"; else reg.target = "_self";
        document.getElementById('reg').submit();
        document.getElementById('button1').disabled = true;
    }
</script>