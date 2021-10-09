<%@ Page Language="C#" CodePage="65001" %>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<script runat="server">
    protected string HTProgCap = "請款綜合查詢作業";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "ext76";//HttpContext.Current.Request["prgid"] ?? "";//程式檔名前綴
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

    protected string qs_dept = "", todo = "", ar_mark="";
    protected int chk_progright = 0;
    protected string chk_progcode = "", gs_titlenm = "";
    protected string strdate = "", strdatename = "", sc_name="";
    //表頭總計
    protected decimal service = 0, fees = 0, oth_money=0,add_service=0,add_fees=0,uar_money=0,cservice=0,cfees=0,total=0;
    //每頁小計
    protected decimal case_service = 0, case_fees = 0, case_othmoney=0,case_money=0,case_armoney=0;
    protected decimal sum_service = 0, sum_fees = 0, sum_cservice=0,sum_cfees=0,sum_money=0;

    DBHelper conn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    DBHelper connacc = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    DBHelper cnn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    private void Page_Unload(System.Object sender, System.EventArgs e) {
        if (conn != null) conn.Dispose();
        if (connacc != null) connacc.Dispose();
        if (cnn != null) cnn.Dispose();
    }

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");

        conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
        connacc = new DBHelper(Conn.account).Debug(Request["chkTest"] == "TEST");
        cnn = new DBHelper(Conn.Sysctrl).Debug(Request["chkTest"] == "TEST");

        qs_dept = (Request["qs_dept"] ?? "").ToLower();
        todo = (Request["todo"] ?? "").ToUpper();//查詢種類
        ar_mark = (Request["ar_mark"] ?? "").ToUpper();//請款單種類
        if (qs_dept == "t") {
            HTProgCode = "Brt76";
            chk_progcode = "Brt71";//檢查請款單開立作業權限
        } else if (qs_dept == "e") {
            HTProgCode = "Ext76";
            chk_progcode = "Ext71";//檢查請款單開立作業權限
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
        StrFormBtnTop += "<a href=" + HTProgPrefix + ".aspx?prgid=" + prgid + "&qs_dept=" + qs_dept + ">[回請款單查詢]</a>";
        StrFormBtnTop += "<a class=\"imgRefresh\" href=\"javascript:void(0);\" >[重新整理]</a>";

        if (todo == "X") {
            HTProgCap += "查詢種類：尚未開立 ";
            if (ar_mark == "A") {
                HTProgCap += "請款單種類：一般+實報實銷 ";
            }
            if (ar_mark == "D") {
                HTProgCap += "請款單種類：扣收入案件(不開收據) ";
            }

            //總計Table
            if (ReqVal.TryGet("scdate") == "" && ReqVal.TryGet("ecdate") == "") {
                strdate = "不指定";
            } else {
                strdate = ReqVal["scdate"] + "~" + ReqVal["ecdate"];
            }
            strdatename = "交辦期間";
        } else {
            if (todo == "N") {
                HTProgCap += "查詢種類：已開立未送確認 ";
            } else if (todo == "Y") {
                HTProgCap += "查詢種類：會計未確認 ";
            } else if (todo == "Z") {
                HTProgCap += "查詢種類：會計已確認 ";
            } else if (todo == "S") {
                HTProgCap += "查詢種類：已寄出請款單 ";
            }

            //總計Table
            if (ReqVal.TryGet("sdate") == "" && ReqVal.TryGet("edate") == "") {
                strdate = "不指定";
            } else {
                strdate = ReqVal["sdate"] + "~" + ReqVal["edate"];
            }

            if (ReqVal.TryGet("todate") == "in_date") {
                strdatename = "開單期間";
            } else if (ReqVal.TryGet("todate") == "ar_date") {
                strdatename = "請款期間";
            } else if (ReqVal.TryGet("todate") == "conf_date") {
                strdatename = "確認期間";
            } else if (ReqVal.TryGet("todate") == "mail_date") {
                strdatename = "寄出期間";
            }
        }
        HTProgCap += "案件查詢結果";

        if (ReqVal.TryGet("scode") == "" || ReqVal.TryGet("scode") == "*") {
            sc_name = "全部";
        } else {
            sc_name = ReqVal.TryGet("scode");
        }
    }

    private void QueryData() {
        if (todo == "X") {//未開立請款單案件查詢
            //抓取開立請款單權限
            SQL = "Select rights from loginAP where syscode='" + Session["Syscode"] + "' and loginGrp='" + Session["LoginGrp"] + "' and beg_date<=GETDATE() and end_date>=GETDATE() AND (APcode='" + chk_progcode + "') ";
            using (DBHelper connsys = new DBHelper(Conn.ODBCDSN).Debug(false)) {
                chk_progright = Convert.ToInt32(connsys.getZero(SQL));
            }

            if (qs_dept == "t") {
                //規費支出日期之欄位名稱
                gs_titlenm = "官發日期";
                //2008/1/9業務出名代理人，修改收據別依交辦出名代理人對應抓取
                SQL = "SELECT b.seq,b.seq1,b.in_no,B.In_scode, B.case_no,F.cust_name,C.appl_name, B.Service, B.Fees,B.add_service";
                SQL += ",B.add_fees,isnull(b.oth_money,0) as tr_money,B.arcase_type,B.arcase_class,B.arcase";
                SQL += ",B.ar_service,B.ar_fees,B.Service + B.Fees+isnull(b.add_service,0)+isnull(b.add_fees,0)+isnull(b.oth_money,0) AS allcost,B.ar_mark,B.case_date,b.change";
                SQL += ",(select Rs_detail from code_br where rs_code=b.arcase and cr='Y' and dept='T' and rs_type=b.arcase_type) as CArcase";
                SQL += ",(SELECT rs_class FROM code_br WHERE rs_code = b.arcase AND dept = 'T' AND cr = 'Y' and rs_type=b.arcase_type) AS Ar_form";
                SQL += ",(select treceipt from agt where agt_no=c.agt_no) as receipt";
                SQL += ",D.remark  as progpath,B.Cust_area, B.Cust_seq,c.apsqlno,e.sc_name";
                SQL += ",(select code_name from cust_code where code_type='ar_mark' and cust_code=b.ar_mark) as ar_marknm";
                SQL += ",(select min(x.step_date) from step_dmt x,fees_dmt y where x.rs_no=y.rs_no and y.case_no=b.case_no) as gs_step_date";
                SQL += ",(select count(*) from account.dbo.artitem E where E.case_no = B.case_no and E.country = 'T') as cnt ";
                SQL += ",isnull(b.service,0)+isnull(b.fees,0)+isnull(b.oth_money,0)+isnull(b.add_service,0)+isnull(b.add_fees,0) as total ";
                SQL += ",isnull(b.ar_service,0)+isnull(b.ar_fees,0) as ar_money ";
                SQL += ",''urlasp ";
                SQL += "FROM Case_dmt B ";
                SQL += "INNER JOIN dmt_temp C ON B.In_no = C.in_no AND B.In_scode = C.in_scode and c.case_sqlno=0 ";
                SQL += "INNER JOIN cust_code D on d.code_type=b.arcase_type and d.cust_code='__' ";
                SQL += "INNER JOIN view_cust F on F.cust_area = B.cust_area and F.cust_seq=B.cust_seq ";
                SQL += "left join sysctrl.dbo.scode e ON B.in_scode = e.scode ";
                SQL += "WHERE (B.stat_code = 'YZ') and b.ar_code='N' and (B.mark='N' or B.mark is null) ";
                SQL += "and b.acc_chk='Y' ";
            } else {
                //規費支出日期之欄位名稱
                gs_titlenm = "確認日期";
                SQL = "SELECT b.seq,b.seq1,b.in_no,B.In_scode, B.case_no,F.cust_name,C.country,C.appl_name, B.tot_Service as service";
                SQL += ",B.tot_Fees as fees ,B.add_service,B.add_fees, isnull(B.oth_money,0) as tr_money,B.arcase,B.arcase_type";
                SQL += ",B.ar_service,B.ar_fees,B.tot_Service + B.tot_Fees+isnull(b.oth_money,0) AS allcost,B.ar_mark,B.case_date,b.change";
                SQL += ",(select Rs_detail from code_ext where rs_code=b.arcase and cr_flag='Y' and rs_type=b.arcase_type) as CArcase";
                SQL += ",(select rs_class  from code_ext where rs_code=b.arcase and cr_flag='Y' and rs_type=b.arcase_type) as ar_form";
                SQL += ",B.arcase_class as prt_code";
                SQL += ",B.Cust_area, B.Cust_seq,g.sc_name";
                SQL += ",(select code_name from cust_code where code_type='ar_mark' and cust_code=b.ar_mark) as ar_marknm";
                SQL += ",(select max(tran_date) from fees_ext where case_no=b.case_no and fees>0) as gs_step_date";
                SQL += ",(select count(*) from account.dbo.artitem E where E.case_no = B.case_no and E.country = C.country) as cnt ";
                SQL += ",isnull(b.tot_service,0)+isnull(b.tot_fees,0)+isnull(b.oth_money,0)+isnull(b.add_service,0)+isnull(b.add_fees,0) as total ";
                SQL += ",isnull(b.ar_service,0)+isnull(b.ar_fees,0) as ar_money ";
                SQL += ",''urlasp ";
                SQL += "FROM Case_ext B ";
                SQL += "INNER JOIN ext_temp C ON B.In_no = C.in_no AND B.In_scode = C.in_scode and c.case_sqlno=0 ";
                SQL += "INNER JOIN view_cust F on F.cust_area = B.cust_area and F.cust_seq=B.cust_seq ";
                SQL += "left join sysctrl.dbo.scode g ON B.in_scode = g.scode ";
                SQL += "WHERE (b.invoice_chk='B' or b.invoice_chk='C') and (B.stat_code = 'YZ' or B.stat_code like 'S%') and b.ar_code='N' and (B.mark='N' or B.mark is null) ";
                SQL += "and b.acc_chk='Y' ";
            }

            if (ReqVal.TryGet("scode") != "" && ReqVal.TryGet("scode") != "*") {
                SQL += "AND b.in_scode='" + ReqVal["scode"] + "' ";
            }
            if (ReqVal.TryGet("acust_seq") != "") {
                SQL += "AND b.cust_area='" + ReqVal["branch"] + "' and b.cust_seq='" + ReqVal["acust_seq"] + "' ";
            }
            if (ReqVal.TryGet("cust_name") != "") {
                SQL += "AND F.cust_name like '" + ReqVal["cust_name"] + "%' ";
            }
            if (ReqVal.TryGet("bseq") != "") {
                SQL += "AND b.seq between " + ReqVal["bseq"] + " and " + ReqVal["eseq"] + " ";
            }
            if (ReqVal.TryGet("scdate") != "") {
                SQL += "AND b.case_date>='" + ReqVal["scdate"] + "' ";
            }
            if (ReqVal.TryGet("ecdate") != "") {
                SQL += "AND b.case_date<='" + ReqVal["ecdate"] + "' ";
            }
            if (ReqVal.TryGet("ar_mark") == "A") {//一般+實報實銷
                SQL += "and b.ar_mark <>'D' ";
            }
            if (ReqVal.TryGet("ar_mark") == "D") {//扣收入(不開收據)
                SQL += "and b.ar_mark ='D' ";
            }
            if (ReqVal.TryGet("spkind") == "gs_fees") {//規費已支出
                SQL += "and b.gs_fees>0 ";
            }
            if (ReqVal.TryGet("spkind") == "N") {//規費未支出
                SQL += "and b.gs_fees=0 ";
            }

            ReqVal["qryOrder"] = ReqVal.TryGet("SetOrder", ReqVal.TryGet("qryOrder", "F.cust_name,b.case_no"));
            if (ReqVal.TryGet("qryOrder") != "") {
                SQL += " order by " + ReqVal.TryGet("qryOrder");
            }
        } else {//已開立請款單案件查詢
            SQL = " select distinct ar.ar_no,ar.mail_date,ar.rec_no,ar.rec_no1,ar.tot_service,ar.tot_fees,ar.tot_tax,ar.ctot_service,ar.ctot_fees,ar.tot_money,ar.ar_status";
            SQL += ",ar.branch,ar.ar_type,ar.mark,ar.ar_date,ar.ar_id,ap.ap_cname1";
            SQL += ",(select ap_cname1 from si" + Session["seBranch"] + "dbs.dbo.apcust b where b.apcust_no=ar.ar_id) as apcust_name";
            SQL += ",(select code_name from cust_code where code_type='dbsend_way' and cust_code=ar.Dbsend_way) as sendway_name ";
            SQL += ",''urlasp ";
            SQL += "from artmain ar ";
            SQL += "inner join artitem b on ar.ar_no=b.ar_no ";
            SQL += "left outer join si" + Session["seBranch"] + "dbs.dbo.apcust ap on ar.branch = ap.cust_area and ar.acust_seq = ap.cust_seq ";
            if (qs_dept == "t") {
                SQL += " Where ar_type = 'T' and invoice_mark='B' ";
            } else {
                SQL += " Where ar_type = 'E' and invoice_mark='B' ";
            }

            if (ReqVal.TryGet("scode") != "" && ReqVal.TryGet("scode") != "*") {
                SQL += "AND ar.ar_scode='" + ReqVal["scode"] + "' ";
            }
            if (ReqVal.TryGet("in_scode") != "") {
                SQL += "AND ar.in_scode='" + ReqVal["in_scode"] + "' ";
            }
            if (ReqVal.TryGet("acust_seq") != "") {
                SQL += "AND ar.branch='" + ReqVal["branch"] + "' and ar.acust_seq='" + ReqVal["acust_seq"] + "' ";
            }
            if (ReqVal.TryGet("cust_name") != "") {
                SQL += "AND ap.ap_cname1 like '" + ReqVal["cust_name"] + "%' ";
            }
            if (ReqVal.TryGet("bseq") != "") {
                SQL += "AND b.seq between " + ReqVal["bseq"] + " and " + ReqVal["eseq"] + " ";
            }

            if (todo == "NN") {//看板進入，請款單尚未送簽
                if (ReqVal.TryGet("homelist") == "homelist") {
                    SQL += "AND ar.ar_status like 'N%' ";
                }
            } else if (todo == "N") {
                SQL += "AND ar.ar_status like 'N%' ";
            } else if (todo == "Y") {
                SQL += "and ar.ar_status = 'YY' ";
            } else if (todo == "Z") {
                SQL += "and ar.ar_status = 'YZ' ";
            } else if (todo == "S") {
                SQL += "and ar.ar_status = 'YZ' and ar.mail_date is not null ";
            }
            if (ReqVal.TryGet("todate") != "") {
                if (ReqVal.TryGet("sdate") != "") {
                    SQL += "AND ar." + ReqVal.TryGet("todate") + ">='" + ReqVal["sdate"] + "' ";
                }
                if (ReqVal.TryGet("edate") != "") {
                    SQL += "AND ar." + ReqVal.TryGet("todate") + "<='" + ReqVal["edate"] + " 23:59:59' ";
                }
            }
            if (ReqVal.TryGet("bar_no") != "") {
                SQL += "AND ar.ar_no>='" + ReqVal["bar_no"] + "' ";
            }
            if (ReqVal.TryGet("ear_no") != "") {
                SQL += "AND ar.ar_no>='" + ReqVal["ear_no"] + "' ";
            }

            ReqVal["qryOrder"] = ReqVal.TryGet("SetOrder", ReqVal.TryGet("qryOrder", "ap.ap_cname1,ar.ar_no"));
            if (ReqVal.TryGet("qryOrder") != "") {
                SQL += " order by " + ReqVal.TryGet("qryOrder");
            }
        }

        DataTable dt = new DataTable();
        if (todo == "X") {//未開立請款單案件查詢
            conn.DataTable(SQL, dt);
        } else {//已開立請款單案件查詢
            connacc.DataTable(SQL, dt);
        }
        Sys.showLog(SQL);
        //處理分頁
        int nowPage = Convert.ToInt32(Request["GoPage"] ?? "1"); //第幾頁
        int PerPageSize = Convert.ToInt32(Request["PerPage"] ?? "50"); //每頁筆數
        page = new Paging(nowPage, PerPageSize, SQL);
        page.GetPagedTable(dt);

        //分頁完再處理其他資料才不會虛耗資源
        for (int i = 0; i < page.pagedTable.Rows.Count; i++) {
            DataRow dr = page.pagedTable.Rows[i];

            //聯結
            GetLink(dr);

        }
        //表頭合計
        if (dt.Rows.Count > 0) {
            if (todo == "X") {
                service = Convert.ToDecimal(dt.Compute("Sum(service)", ""));//服務費
                fees = Convert.ToDecimal(dt.Compute("Sum(fees)", ""));//規費
                oth_money = Convert.ToDecimal(dt.Compute("Sum(tr_money)", ""));//轉帳費用
                add_service = Convert.ToDecimal(dt.Compute("Sum(add_service)", ""));//未請款金額
                add_fees = Convert.ToDecimal(dt.Compute("Sum(add_fees)", ""));//未請款金額
                uar_money = Convert.ToDecimal(dt.Compute("Sum(total)-Sum(ar_money)", ""));//未請款金額
                total = Convert.ToDecimal(dt.Compute("Sum(total)", ""));//合計
            } else {
                service = Convert.ToDecimal(dt.Compute("Sum(tot_service)", ""));//服務費
                fees = Convert.ToDecimal(dt.Compute("Sum(tot_fees)", ""));//規費
                cservice = Convert.ToDecimal(dt.Compute("Sum(ctot_service)", ""));//入帳服務費
                cfees = Convert.ToDecimal(dt.Compute("Sum(ctot_fees)", ""));//入帳規費
                total = Convert.ToDecimal(dt.Compute("Sum(tot_money)", ""));//合計
            }
        }

        //每頁小計
        if (page.pagedTable.Rows.Count > 0) {
            if (todo == "X") {
                case_service = Convert.ToDecimal(page.pagedTable.Compute("Sum(service)", ""));//服務費
                case_fees = Convert.ToDecimal(page.pagedTable.Compute("Sum(fees)", ""));//規費
                case_othmoney = Convert.ToDecimal(page.pagedTable.Compute("Sum(tr_money)", ""));//轉帳費用
                case_money = Convert.ToDecimal(page.pagedTable.Compute("Sum(allcost)", ""));//合計
                case_armoney = Convert.ToDecimal(page.pagedTable.Compute("Sum(ar_service)+Sum(ar_fees)", ""));//已請款
            } else {
                sum_service = Convert.ToDecimal(page.pagedTable.Compute("Sum(tot_service)", ""));//服務費
                sum_fees = Convert.ToDecimal(page.pagedTable.Compute("Sum(tot_fees)", ""));//規費
                sum_cservice = Convert.ToDecimal(page.pagedTable.Compute("Sum(ctot_service)", ""));//入帳服務費
                sum_cfees = Convert.ToDecimal(page.pagedTable.Compute("Sum(ctot_fees)", ""));//入帳規費
                sum_money = Convert.ToDecimal(page.pagedTable.Compute("Sum(tot_money)", ""));//合計
            }
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
            //[自行發文]
            todo_link = Page.ResolveUrl("~/brt6m/brt63_edit.aspx") + "?prgid=" + prgid+"&menu=N&submittask=A&cgrs=GS&todo_sqlno=" + row["todo_sqlno"] + "&seq=" + row["seq"] + "&seq1=" + row["seq1"] + "&in_scode=" + row["in_scode"] + "&in_no=" + row["in_no"] + "&case_no=" + row["case_no"] + "&rs_class=" + row["ar_form"] + "&rs_code=" + row["arcase"] + "&erpt_code=" + row["erpt_code"] + "&att_sqlno=" + row["att_sqlno"];
            //[發文維護]
            todo_link1 = todo_link;
        }

        if (row.SafeRead("opt_stat", "") == "N") {
            todo_name = "專案室發文";
            string new_form = Sys.getCaseDmtAspx(row.SafeRead("arcase_type", ""), row.SafeRead("arcase", ""));//連結的aspx
            //todo_link = Page.ResolveUrl("~/brt1m" + row.SafeRead("link_remark", "") + "/Brt11Edit" + new_form + ".aspx?prgid=" + prgid);
            //todo_link += "&in_scode=" + row["in_scode"];
            //todo_link += "&in_no=" + row["in_no"];
            //todo_link += "&add_arcase=" + row["arcase"];
            //todo_link += "&cust_area=" + row["cust_area"];
            //todo_link += "&cust_seq=" + row["cust_seq"];
            //todo_link += "&ar_form=" + row["ar_form"];
            //todo_link += "&new_form=" + new_form;
            //todo_link += "&code_type=" + row["arcase_type"];
            //todo_link += "&homelist=" + Request["homelist"];
            //todo_link += "&uploadtype=case";
            //todo_link += "&submittask=Show";
            //[專案室發文]
            todo_link = Sys.getCaseDmt11Aspx(prgid, row.SafeRead("in_no", ""), row.SafeRead("in_scode", ""), "Show");
            todo_link += "&todo_sqlno=" + row["todo_sqlno"];
            todo_link += "&rs_no=" + row["rs_no"];
            //todo_link += "&seq=" + row["seq"];
            //todo_link += "&seq1=" + row["seq1"];
            //todo_link += "&case_no=" + row["case_no"];
            todo_link += "&ctrl_date=" + row.GetDateTimeString("ctrl_date", "yyyy/M/d");
            //todo_link += "&step_grade=" + row["step_grade"];
            todo_link += "&step_date=" + row.GetDateTimeString("step_date","yyyy/M/d");
            todo_link += "&contract_flag=" + row["contract_flag"];
            //[發文維護]
            todo_link1 = "brt63_edit.aspx?prgid=" + prgid + "&menu=N&submittask=A&cgrs=GS&todo_sqlno=" + row["todo_sqlno"] + "&seq=" + row["seq"] + "&seq1=" + row["seq1"] + "&in_scode=" + row["in_scode"] + "&in_no=" + row["in_no"] + "&case_no=" + row["case_no"] + "&rs_class=" + row["ar_form"] + "&rs_code=" + row["arcase"] + "&erpt_code=" + row["erpt_code"] + "&att_sqlno=" + row["att_sqlno"];
        }
        //950928為有關爭救案理由後補之收費情形,避免造成收費重覆新加入程式做控制,2010/8/6規費已支出不能發文	
        if (Convert.ToDecimal(row.SafeRead("gs_fees", "0")) > 0) {
            todo_name = "<font color=red>規費已支出</font>";
            todo_link = "";
        }
        //[不需發文]
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

    protected void GetLink(DataRow row) {
        row["urlasp"] = Sys.getCaseDmt11Aspx(prgid, row.SafeRead("in_no", ""), row.SafeRead("in_scode", ""), "Show");
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

<table style="display:<%#page.totRow==0?"none":""%>" border="0" class="bluetable" cellspacing="1" cellpadding="2" width="100%" align="center" id="dataTitle">
    <Tr class="lightbluetable" align="center">
	    <td>營洽</td>
	    <td><%=strdatename%></td>
        <%if(todo=="X"){%>
		    <td>交辦服務費</td>
		    <td>交辦規費</td>
		    <td>轉帳費用</td>
		    <td>交辦合計</td>
		    <td><font color=red>未請款金額</font></td>
	    <%}else{%>
		    <td>請款服務費</td>
		    <td>請款規費</td>
		    <td>入帳服務費</td>
		    <td>入帳規費</td>
		    <td>總計金額</td>
	    <%}%>
    </Tr>
	<tr align="center" class="sfont9">
		<td><%=sc_name%></td>
		<td><%=strdate%></td>
        <%if(todo=="X"){%>
			<td><%=service%><%=(add_service > 0?"+"+ add_service:"")%></td>
			<td><%=fees%><%=(add_fees > 0?"+"+ add_fees:"")%></td>
			<td><%=oth_money%></td>
			<td><%=total%></td>
			<td><font color=red><%=uar_money%></font></td>
	    <%}else{%>
			<td><%=service%></td>
			<td><%=fees%></td>
			<td style="BACKGROUND-COLOR:#b0e0e6"><%=cservice%></td>
			<td style="BACKGROUND-COLOR:#b0e0e6"><%=cfees%></td>
			<td><%=total%></td>
	    <%}%>
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
        <table style="display:<%#page.totRow==0?"none":""%>" border="0" class="bluetable" cellspacing="1" cellpadding="2" width="100%" align="center" id="dataList">
	        <thead>
                <Tr class="lightbluetable">
                <%if(todo=="X"){%>
                    <td align="center" width="6%"><u class="setOdr" v1="sc_name">營洽</u></td>
                    <td align="center" width="10%"><u class="setOdr" v1="F.cust_name">客戶名稱</u></td>
                    <td align="center" width="7%">
                        <u class="setOdr" v1="gs_step_date">交辦日期</u><%=((ReqVal.TryGet("spkind") == "gs_fees") ?"<br><font color=red>("+gs_titlenm+")</font><":"")%>
                    </td>
                    <td align="center" width="6%"><u class="setOdr" v1="b.seq">案件<br>編號</u></td>
                    <td align="center" width="12%">案件名稱</td>
                    <td align="center" width="6%">請款<br>註記</td>
                    <td align="center" width="8%"><u class="setOdr" v1="CArcase">案性</u></td>
                    <td align="center" width="7%">服務費</td>
                    <td align="center" width="7%">規費</td>
                    <td align="center" width="8%">轉帳<br>費用</td>
                    <td align="center" width="8%">合計</td>
                    <td align="center" width="10%">已請款<BR><font size=1>金額(次數)</td>
                    <%if (ReqVal.TryGet("getdo") != "N" && (HTProgRight & 2) > 0) {//看板顯示，N:主管不顯示作業，其他：顯示作業%>
		                <td align="center" class="lightbluetable" width="6%">作業</td>
                    <%}%>
                <%}else{%>
                    <td align="center" nowrap><u class="setOdr" v1="ar.ar_no">請款單號</u></td>  
                    <td align="center" nowrap><u class="setOdr" v1="ar.ar_date">請款日期</u></td>
                    <td align="center" nowrap>寄出日期</td>
                    <td align="center" nowrap>收據抬頭</td>
                    <td align="center" nowrap>請款客戶</td>
                    <td align="center" nowrap>請款服務費</td>
                    <td align="center" nowrap>請款規費</td>
                    <td align="center" nowrap>入帳服務費</td>
                    <td align="center" nowrap>入帳規費</td>
                    <td align="center" nowrap>請款金額</td>
                    <td align="center" nowrap>狀態</td>
                <%}%>
                </Tr>
	        </thead>
	        <tbody>
    </HeaderTemplate>
			<ItemTemplate>
 		        <tr align="center" class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>">
	                <%if(todo=="X"){%>
                        <td align="center"><a href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("sc_name")%></a></td>	
	                    <td align="center"><a href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("cust_name")%></a></td>
	                    <td align="center"><a href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("case_date")%><%if request("spkind") = "gs_fees" and RSreg("gs_step_date")<>"" then%><font color=red>(<%=formatdatetime(RSreg("gs_step_date"),2)%>)</font><%end if%></a></td>
	                    <td align="center"><a href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("seq")%><%=t1%><%=country%></a></td>	
	                    <td align="center"><a href="<%#Eval("urlasp")%>" target="Eblank"><%=endname%></a></td>
	                    <td align="center"><a href="<%#Eval("urlasp")%>" target="Eblank"><%=strar_mark%></a></td>
	                    <td align="center"><a href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("CArcase")%></a></td>
	                    <td align="center"><a href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("service")%><%if RSreg("add_service") > 0 then Response.Write "<font color=red>*"%></a></td>
	                    <td align="center"><a href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("fees")%><%if RSreg("add_fees") > 0 then Response.Write "<font color=red>*"%></a></td>
	                    <td align="center"><a href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("tr_money")%></a></td>
	                    <td align="center"><a href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("allcost")%></td>
	                    <td align="center">
		                    <%if urlar="" then
			                    Response.Write ar_money
		                    else%>
			                    <a href="<%=urlar%>" target="Eblank"><%=ar_money%>(<%#Eval("cnt")%>)
		                    <%end if%>
	                    </td>
                <%}else{%>
                <%}%>
		        </tr>
			</ItemTemplate>
    <FooterTemplate>
	        </tbody>
            <tfoot>
            <%if(todo=="X"){%>
 	            <tr class="sfont9"><td colspan=12><hr class="style-one"/></td></tr>
		        <tr>
			        <td align="center" class="lightbluetable" colspan=5 width="52%">每頁小計</td>
			        <td align="center" class="lightbluetable" width="9%"><%=case_service.ToString("N0")  %></td>
			        <td align="center" class="lightbluetable" width="8%"><%=case_fees.ToString("N0")  %></td>
			        <td align="center" class="lightbluetable" width="8%"><%=case_othmoney.ToString("N0")  %></td>
			        <td align="center" class="lightbluetable" width="8%"><%=case_money.ToString("N0")  %></td>
			        <td align="center" class="lightbluetable" width="8%"><%=case_armoney.ToString("N0")  %></td>
			        <td align="center" class="lightbluetable" width="6%"></td>
		        </tr>
            <%}else{%>
 	            <tr class="sfont9"><td colspan=11><hr class="style-one"/></td></tr>
		        <tr>
			        <td align="center" class="lightbluetable" colspan=5 width=52%>每頁小計</td>
			        <td align="right" class="lightbluetable" width="8%"><%=sum_service.ToString("N0")  %></td>
			        <td align="right" class="lightbluetable" width="8%"><%=sum_fees.ToString("N0")  %></td>
			        <td align="right" class="lightbluetable" width="8%"><%=sum_cservice.ToString("N0")  %></td>
			        <td align="right" class="lightbluetable" width="8%"><%=sum_cfees.ToString("N0")  %></td>
			        <td align="right" class="lightbluetable" width="8%"><%=sum_money.ToString("N0")  %></td>
			        <td align="center" class="lightbluetable" width="8%"></td>
		        </tr>
            <%}%>
            </tfoot>
        </table>
	    <BR>

        <table style="display:<%#page.totRow==0?"none":""%>" border="0" width="100%" cellspacing="0" cellpadding="0">
		    <tr class="FormName"><td>
			    <div style="color:blue">
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
        if ((main.right & 64) == 0) {
            $("#qryjob_scode").lock();
        }

        if ($("#submittask").val() == "U" || $("#submittask").val() == "D" || $("#submittask").val() == "Q") {
            $("#seq,#seq1").lock();
        }
        $(".Lock").lock();
        $("input.dateField").datepick();
    }
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
        window.open(getRootPath() + "/brtam/brta61_Edit.aspx?submitTask=Q&qtype=A&prgid=<%=prgid%>&closewin=Y&winact=1&aseq=" +seq+ "&aseq1=" +seq1,"myWindowOne", "width=900 height=700 top=40 left=80 toolbar=no, menubar=no, location=no, directories=no resizeable=no status=no scrollbars=yes");
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