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

        if (todo == "X") {//未開立請款單案件查詢
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
                SQL = "SELECT b.seq,b.seq1,b.in_no,B.In_scode, B.case_no,F.cust_name,''country,C.appl_name, B.Service, B.Fees,B.add_service";
                SQL += ",B.add_fees,isnull(b.oth_money,0) as tr_money,B.arcase_type,B.arcase_class,B.arcase";
                SQL += ",B.ar_service,B.ar_fees,B.ar_mark,B.case_date,b.change";
                SQL += ",(select Rs_detail from code_br where rs_code=b.arcase and cr='Y' and dept='T' and rs_type=b.arcase_type) as CArcase";
                SQL += ",(SELECT rs_class FROM code_br WHERE rs_code = b.arcase AND dept = 'T' AND cr = 'Y' and rs_type=b.arcase_type) AS Ar_form";
                SQL += ",(select treceipt from agt where agt_no=c.agt_no) as receipt";
                SQL += ",D.remark as progpath,B.Cust_area, B.Cust_seq,c.apsqlno,e.sc_name";
                SQL += ",(select code_name from cust_code where code_type='ar_mark' and cust_code=b.ar_mark) as ar_marknm";
                SQL += ",(select min(x.step_date) from step_dmt x,fees_dmt y where x.rs_no=y.rs_no and y.case_no=b.case_no) as gs_step_date";
                SQL += ",(select count(*) from account.dbo.artitem E where E.case_no = B.case_no and E.country = 'T') as cnt ";
                SQL += ",isnull(b.service,0)+isnull(b.fees,0)+isnull(b.oth_money,0)+isnull(b.add_service,0)+isnull(b.add_fees,0) as allcost ";
                SQL += ",isnull(b.service,0)+isnull(b.fees,0)+isnull(b.oth_money,0)+isnull(b.add_service,0)+isnull(b.add_fees,0) as total ";
                SQL += ",isnull(b.ar_service,0)+isnull(b.ar_fees,0) as ar_money ";
                SQL += ",''fseq,''gs_step_date_txt,''strar_mark,''urlasp,''urlar,''urlext71 ";
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
                SQL += ",B.ar_service,B.ar_fees,B.ar_mark,B.case_date,b.change";
                SQL += ",(select Rs_detail from code_ext where rs_code=b.arcase and cr_flag='Y' and rs_type=b.arcase_type) as CArcase";
                SQL += ",(select rs_class  from code_ext where rs_code=b.arcase and cr_flag='Y' and rs_type=b.arcase_type) as ar_form";
                SQL += ",B.arcase_class as prt_code";
                SQL += ",B.Cust_area, B.Cust_seq,g.sc_name";
                SQL += ",(select code_name from cust_code where code_type='ar_mark' and cust_code=b.ar_mark) as ar_marknm";
                SQL += ",(select max(tran_date) from fees_ext where case_no=b.case_no and fees>0) as gs_step_date";
                SQL += ",(select count(*) from account.dbo.artitem E where E.case_no = B.case_no and E.country = C.country) as cnt ";
                SQL += ",isnull(b.tot_service,0)+isnull(b.tot_fees,0)+isnull(b.oth_money,0) as allcost ";
                SQL += ",isnull(b.tot_service,0)+isnull(b.tot_fees,0)+isnull(b.oth_money,0)+isnull(b.add_service,0)+isnull(b.add_fees,0) as total ";
                SQL += ",isnull(b.ar_service,0)+isnull(b.ar_fees,0) as ar_money ";
                SQL += ",''fseq,''gs_step_date_txt,''strar_mark,''urlasp,''urlar,''urlext71 ";
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
            SQL += ",''fseq,''strrecno,''strmail,''strstatus,''urlasp  ";
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

            //案號
            dr["fseq"] = Sys.formatSeq(dr.SafeRead("seq", ""), dr.SafeRead("seq1", ""), dr.SafeRead("country", ""), "", "");

            //規費支出日期
            if (ReqVal.TryGet("spkind") == "gs_fees" && dr.SafeRead("gs_step_date", "") != "") {
                dr["gs_step_date_txt"] = "<font color=red>(" + dr.GetDateTimeString("formatdatetime", "yyyy/M/d") + ")</font>";
            }

            if (todo == "X") {//未開立請款單案件查詢
                //請款註記
                if (dr.SafeRead("ar_mark", "") != "N") {
                    dr["strar_mark"] = "<font color=red>" + dr.SafeRead("ar_marknm", "");
                }
                //交辦畫面連結
                if (qs_dept == "t") {
                    dr["urlasp"] = Sys.getCaseDmt11Aspx(prgid, dr.SafeRead("in_no", ""), dr.SafeRead("in_scode", ""), "Show");
                }
                if (qs_dept == "e") {
                    dr["urlasp"] = Sys.getCaseExt11Aspx(prgid, dr.SafeRead("in_no", ""), dr.SafeRead("in_scode", ""), "Show");
                }
                //已請款連結
                GetArLink(dr);
                //請款單開立連結
                GetArExt71(dr);
            } else {//已開立請款單案件查詢
                //***todo
                //請款單畫面連結
                dr["urlasp"] = "Ext73_Detail.aspx?modify=A&ar_no=" + dr.SafeRead("ar_no", "") + "&branch=" + dr.SafeRead("branch", "") + "&homelist=" + Request["homelist"] + "&ar_mark=" + ar_mark + "&ar_type=" + dr.SafeRead("ar_type", "") + "&prgid=Brt76";

                //2010/11/22增加顯示收據號碼
                string strrecno = "";
                if (dr.SafeRead("rec_no", "") != "") {
                    strrecno = "<br>(收據號碼：" + dr.SafeRead("rec_no", "");
                    if (dr.SafeRead("rec_no1", "") != "") {
                        strrecno += "、" + dr.SafeRead("rec_no1", "");
                    }
                    strrecno += ")";
                } else {
                    if (dr.SafeRead("rec_no1", "") != "") {
                        strrecno = "<br>(收據：" + dr.SafeRead("rec_no1", "") + ")";
                    }
                }
                dr["strrecno"] = strrecno;

                //寄出日期
                dr["strmail"] = dr.GetDateTimeString("mail_date", "yyyy/M/d");
                if (dr["strmail"] == "1900/1/1") {
                    dr["strmail"] = "<font color=red>無需寄發</font>";
                }

                //狀態
                string strstatus = "";
                switch (dr.SafeRead("ar_status", "")) {
                    case "NN":
                    case "NX": strstatus = "未送確認"; break;
                    case "YY": strstatus = "會計未確認"; break;
                    case "YZ": strstatus = "會計已確認"; break;
                }
                SQL = "select count(*) as curr from casetran_brt as a ";
                SQL += " inner join casetrand_brt as b on a.sqlno=b.tran_sqlno and b.ar_no='" + dr["ar_no"] + "' and b.cor_table='artmain'";
                SQL += " where a.tran_status not like '%Z%'";
                int curr = Convert.ToInt32(conn.getZero(SQL));
                if (curr > 0) {
                    strstatus = "異動請核中";
                } else {
                    strstatus = "<a href=\"" + dr["urlasp"] + "\" target=\"Eblank\">" + strstatus + "</a>";
                }
                dr["strstatus"] = strstatus;
            }
        }

        if (todo == "X") {//未開立請款單案件查詢
            //表頭合計
            if (dt.Rows.Count > 0) {
                service = Convert.ToDecimal(dt.Compute("Sum(service)", ""));//交辦服務費
                add_service = Convert.ToDecimal(dt.Compute("Sum(add_service)", ""));//追加服務費
                fees = Convert.ToDecimal(dt.Compute("Sum(fees)", ""));//交辦規費
                add_fees = Convert.ToDecimal(dt.Compute("Sum(add_fees)", ""));//追加規費
                oth_money = Convert.ToDecimal(dt.Compute("Sum(tr_money)", ""));//轉帳費用
                total = Convert.ToDecimal(dt.Compute("Sum(total)", ""));//交辦合計
                uar_money = Convert.ToDecimal(dt.Compute("Sum(total)-Sum(ar_money)", ""));//未請款金額
            }
            //每頁小計
            if (page.pagedTable.Rows.Count > 0) {
                case_service = Convert.ToDecimal(page.pagedTable.Compute("Sum(service)", ""));//服務費
                case_fees = Convert.ToDecimal(page.pagedTable.Compute("Sum(fees)", ""));//規費
                case_othmoney = Convert.ToDecimal(page.pagedTable.Compute("Sum(tr_money)", ""));//轉帳費用
                case_money = Convert.ToDecimal(page.pagedTable.Compute("Sum(allcost)", ""));//合計
                case_armoney = Convert.ToDecimal(page.pagedTable.Compute("Sum(ar_money)", ""));//已請款
            }
            //資料綁定
            XRepeater.DataSource = page.pagedTable;
            XRepeater.DataBind();
            NRepeater.Visible = false;//已開立隱藏
        } else {//已開立請款單案件查詢
            //表頭合計
            if (dt.Rows.Count > 0) {
                service = Convert.ToDecimal(dt.Compute("Sum(tot_service)", ""));//服務費
                fees = Convert.ToDecimal(dt.Compute("Sum(tot_fees)", ""));//規費
                cservice = Convert.ToDecimal(dt.Compute("Sum(ctot_service)", ""));//入帳服務費
                cfees = Convert.ToDecimal(dt.Compute("Sum(ctot_fees)", ""));//入帳規費
                total = Convert.ToDecimal(dt.Compute("Sum(tot_money)", ""));//合計
            }
            //每頁小計
            if (page.pagedTable.Rows.Count > 0) {
                sum_service = Convert.ToDecimal(page.pagedTable.Compute("Sum(tot_service)", ""));//服務費
                sum_fees = Convert.ToDecimal(page.pagedTable.Compute("Sum(tot_fees)", ""));//規費
                sum_cservice = Convert.ToDecimal(page.pagedTable.Compute("Sum(ctot_service)", ""));//入帳服務費
                sum_cfees = Convert.ToDecimal(page.pagedTable.Compute("Sum(ctot_fees)", ""));//入帳規費
                sum_money = Convert.ToDecimal(page.pagedTable.Compute("Sum(tot_money)", ""));//合計
            }
            //資料綁定
            NRepeater.DataSource = page.pagedTable;
            NRepeater.DataBind();
            XRepeater.Visible = false;//未開立隱藏
        }
    }

    //已請款連結
    protected void GetArLink(DataRow row) {
        //***todo
        if (Convert.ToDecimal(row.SafeRead("cnt", "0")) > 0 && Convert.ToDecimal(row.SafeRead("ar_money", "0")) > 0) {
            string strcoun = (qs_dept == "t" ? "T" : row.SafeRead("country", ""));
            row["urlar"] = "<a href=\"Ext71Show.aspx?qs_dept=" + qs_dept + "&case_no=" + row.SafeRead("case_no", "") + "&country=" + strcoun + "\" target=\"Eblank\">" + row.SafeRead("ar_money", "0") + "(" + row.SafeRead("cnt", "0") + ")";
        } else {
            row["urlar"] = row.SafeRead("ar_money", "0");
        }
    }

    //請款單開立連結
    protected void GetArExt71(DataRow row) {
        string urlext71 = "";

        string receipt_end_date = "", apsqlno = "", receipt = "", tar_mark = "";
        //檢查此收據種類可否開立收據
        if (qs_dept == "t") {
            SQL = "select ar_company,end_date from account.dbo.ar_code where code_type='ar_code' and ar_code='" + row.SafeRead("receipt", "") + "'";
            using (SqlDataReader dr0 = conn.ExecuteReader(SQL)) {
                if (dr0.Read()) {
                    receipt_end_date = dr0.GetDateTimeString("end_date", "yyyy/M/d");
                }
            }

            SQL = "select apsqlno from dmt_temp_ap where in_no='" + row.SafeRead("in_no", "") + "' and case_sqlno=0 ";
            apsqlno = conn.getString(SQL);
            receipt = row.SafeRead("receipt", "");
        } else {
            apsqlno = conn.getString(SQL);
            receipt = "";
        }
        
        tar_mark = row.SafeRead("ar_mark", "");

        if (row.SafeRead("change", "") == "Y") {
            urlext71 = "異動請核中";
        } else {
            urlext71 = "[<a href=\"Ext71.aspx?cust_seq=" + row.SafeRead("cust_seq", "") + "&ar_scode=" + row.SafeRead("in_scode", "") + "&Type=" + ar_mark + "&case_date=" + row.GetDateTimeString("case_date", "yyyy/M/d") + "&qs_dept=" + qs_dept + "&in_scode=" + row.SafeRead("in_scode", "") + "&in_no=" + row.SafeRead("in_no", "") + "&apsqlno=" + apsqlno + "&receipt=" + receipt + "&tar_mark=" + tar_mark + "\" >請款</a>]";
            if (receipt_end_date != "") {
                if (DateTime.Today > DateTime.Parse(receipt_end_date)) {
                    urlext71 = "收據停用";
                }
            }
        }

        //***todo
        row["urlext71"] = urlext71;
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
    <!--未開立請款單案件查詢-->
    <asp:Repeater id="XRepeater" runat="server">
    <HeaderTemplate>
        <table style="display:<%#page.totRow==0?"none":""%>" border="0" class="bluetable" cellspacing="1" cellpadding="2" width="100%" align="center" id="dataList">
	        <thead>
                <Tr class="lightbluetable">
                    <td align="center" width="6%"><u class="setOdr" v1="sc_name">營洽</u></td>
                    <td align="center" width="10%"><u class="setOdr" v1="F.cust_name">客戶名稱</u></td>
                    <td align="center" width="7%">
                        <u class="setOdr" v1="gs_step_date">交辦日期</u><%=((ReqVal.TryGet("spkind") == "gs_fees") ?"<br><font color=red>("+gs_titlenm+")</font>":"")%>
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
                    <%if (ReqVal.TryGet("getdo") != "N" && (chk_progright & 4) > 0) {//看板顯示，N:主管不顯示[作業]，其他：顯示[作業]%>
		                <td align="center" class="lightbluetable" width="6%">作業</td>
                    <%}%>
                </Tr>
	        </thead>
	        <tbody>
    </HeaderTemplate>
			<ItemTemplate>
 		        <tr align="center" class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>">
                        <td align="center"><a href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("sc_name")%></a></td>	
	                    <td align="center"><a href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("cust_name")%></a></td>
	                    <td align="center"><a href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("case_date","{0:d}")%><%#Eval("gs_step_date_txt")%></a></td>
	                    <td align="center"><a href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("fseq")%></a></td>	
	                    <td align="center"><a href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("appl_name").ToString().Left(20)%></a></td>
	                    <td align="center"><a href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("strar_mark")%></a></td>
	                    <td align="center"><a href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("CArcase")%></a></td>
	                    <td align="center"><a href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("service")%><%#(Convert.ToDecimal(Eval("add_service"))>0?"<font color=red>*</font>":"")%></a></td>
	                    <td align="center"><a href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("fees")%><%#(Convert.ToDecimal(Eval("add_fees"))>0?"<font color=red>*</font>":"")%></a></td>
	                    <td align="center"><a href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("tr_money")%></a></td>
	                    <td align="center"><a href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("allcost")%></a></td>
	                    <td align="center"><%#Eval("urlar")%></td>
                        <%if (ReqVal.TryGet("getdo") != "N" && (chk_progright & 4) > 0) {//看板顯示，N:主管不顯示[作業]，其他：顯示[作業]%>
	                        <td align="center"><%#Eval("urlext71")%></td>
                        <%}%>
		        </tr>
			</ItemTemplate>
    <FooterTemplate>
	        </tbody>
            <tfoot>
 	            <tr class="sfont9"><td colspan=13></td></tr>
		        <tr>
			        <td align="center" class="lightbluetable" colspan=7>每頁小計</td>
			        <td align="center" class="lightbluetable"><%=case_service.ToString("N0")  %></td>
			        <td align="center" class="lightbluetable"><%=case_fees.ToString("N0")  %></td>
			        <td align="center" class="lightbluetable"><%=case_othmoney.ToString("N0")  %></td>
			        <td align="center" class="lightbluetable"><%=case_money.ToString("N0")  %></td>
			        <td align="center" class="lightbluetable"><%=case_armoney.ToString("N0")  %></td>
			        <td align="center" class="lightbluetable" colspan="2"></td>
		        </tr>
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

    <!--已開立請款單案件查詢-->
    <asp:Repeater id="NRepeater" runat="server">
    <HeaderTemplate>
        <table style="display:<%#page.totRow==0?"none":""%>" border="0" class="bluetable" cellspacing="1" cellpadding="2" width="100%" align="center" id="dataList">
	        <thead>
                <Tr class="lightbluetable">
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
                </Tr>
	        </thead>
	        <tbody>
    </HeaderTemplate>
			<ItemTemplate>
 		        <tr align="center" class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>">
	                <td align="center">
	                    <a href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("ar_no")%></a>
                        <%#Sys.show_edb_file(connacc,Eval("ar_no").ToString())%>
	                    <a href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("strrecno")%></a>
	                </td>
	                <td align="center"><a href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("ar_date","{0:d}")%></a></td>
	                <td align="center"><a href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("strmail")%>
                        <%#(Eval("sendway_name").ToString()!=""?"<br>("+Eval("sendway_name")+")":"")%></a>
	                </td>
	                <td align="center"><a href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("ar_id")%><br><%#Eval("apcust_name").ToString().Trim().Left(8)%></a></td>
	                <td align="center"><a href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("ap_cname1").ToString().Trim().Left(8)%></a></td>
	                <td align="right" ><a href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("tot_service","{0:N0}")%></a></td>
	                <td align="right" ><a href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("tot_fees","{0:N0}")%></a></td>
	                <td align="right" style="BACKGROUND-COLOR:#b0e0e6"><a href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("ctot_service","{0:N0}")%></a></td>
	                <td align="right" style="BACKGROUND-COLOR:#b0e0e6"><a href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("ctot_fees","{0:N0}")%></a></td>
	                <td align="right" ><a href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("tot_money","{0:N0}")%></a></td>
	                <td align="center"><%#Eval("strstatus")%></td>
		        </tr>
			</ItemTemplate>
    <FooterTemplate>
	        </tbody>
            <tfoot>
 	            <tr class="sfont9"><td colspan=11></td></tr>
		        <tr>
			        <td align="center" class="lightbluetable" colspan=5 width=52%>每頁小計</td>
			        <td align="right" class="lightbluetable" width="8%"><%=sum_service.ToString("N0")  %></td>
			        <td align="right" class="lightbluetable" width="8%"><%=sum_fees.ToString("N0")  %></td>
			        <td align="right" class="lightbluetable" width="8%"><%=sum_cservice.ToString("N0")  %></td>
			        <td align="right" class="lightbluetable" width="8%"><%=sum_cfees.ToString("N0")  %></td>
			        <td align="right" class="lightbluetable" width="8%"><%=sum_money.ToString("N0")  %></td>
			        <td align="center" class="lightbluetable" width="8%"></td>
		        </tr>
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
        $(".Lock").lock();
        $("input.dateField").datepick();
    }
    //////////////////////
</script>