<%@ Page Language="C#" Debug="true" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace = "System.IO"%>
<%@ Import Namespace = "System.Linq"%>
<%@ Import Namespace = "System.Collections.Generic"%>

<script runat="server">
    protected OpenXmlHelper Rpt = new OpenXmlHelper();
    protected StringBuilder strOut = new StringBuilder();
    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();

    protected int right = 0;
    protected string qs_dept = "", tr_yy = "", tr_mm="", qryin_scode = "", sc_name = "";

    string SQL = "";
    object objResult = null;

    DataTable dt = new DataTable();
    DataTable dtSum = new DataTable();

    DBHelper conn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    DBHelper cnn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    private void Page_Unload(System.Object sender, System.EventArgs e) {
        if (conn != null) conn.Dispose();
        if (cnn != null) cnn.Dispose();
    }
    
    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "Private";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;
        Response.Clear();

        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");

        conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
        cnn = new DBHelper(Conn.Sysctrl).Debug(Request["chkTest"] == "TEST");

        qs_dept = ReqVal.TryGet("qs_dept").ToLower();
        tr_yy = ReqVal.TryGet("qrytr_yy");
        tr_mm = ReqVal.TryGet("qrytr_mm");
        qryin_scode = ReqVal.TryGet("qryin_scode");
        
        try {
            QueryData();
            WordOut();
        }
        finally {
            if (Rpt != null) Rpt.Dispose();
        }
    }

    protected void QueryData() {
        //抓取營洽人員
        DataTable dtscode = new DataTable();
        SQL = "select distinct scode,sc_name,scode1 from vscode_roles ";
        SQL += " where branch='" + Session["SeBranch"] + "' and dept='" + Session["Dept"] + "' and syscode='" + Session["syscode"] + "' and roles='sales'";
        SQL += " order by scode1 ";
        cnn.DataTable(SQL, dtscode);
        var list = dtscode.AsEnumerable().Select(r => r.Field<string>("scode")).ToArray();
        string sales_scode = "'" + string.Join("','", list) + "'";

        string vtemptbl = "", vtblname = "", casesql = "", wsql = "", swsql = "", statsql = "";

        if (qs_dept == "t") {
            vtemptbl = "dmt_temp";
            vtblname = "case_dmt";
            casesql = ",(select Rs_detail from code_br where rs_code=b.arcase and cr='Y' and dept='T' and rs_type=b.arcase_type) as case_name ";
        }
        if (qs_dept == "e") {
            vtemptbl = "ext_temp";
            vtblname = "case_ext";
            casesql = ",(select Rs_detail from code_ext where rs_code=b.arcase and cr_flag='Y' and rs_type=b.arcase_type) as case_name ";
        }

        if (ReqVal.TryGet("qrytr_yy") != "") {
            wsql += " and a.tr_yy='" + Request["qrytr_yy"] + "'";
        }
        if (ReqVal.TryGet("qrytr_mm") != "") {
            wsql += " and a.tr_mm='" + Request["qrytr_mm"] + "'";
        }

        if (qryin_scode == "" || qryin_scode == "*") {
            wsql += " and a.in_scode in (" + sales_scode + ")";
            swsql += " and c.in_scode in (" + sales_scode + ")";
        } else {
            wsql += " and a.in_scode ='" + qryin_scode + "'";
            swsql += " and c.in_scode ='" + qryin_scode + "'";
        }

        if (ReqVal.TryGet("qryinvoice_mark") != "") {
            wsql += " and a.invoice_mark='" + Request["qryinvoice_mark"] + "'";
        }
        if (ReqVal.TryGet("spkind") == "gs_fees") {//規費已支出
            wsql += "and b.gs_fees>0 ";
            swsql += "and b.gs_fees>0 ";
        }
        if (ReqVal.TryGet("spkind") == "N") {//規費未支出
            wsql += "and b.gs_fees=0 ";
            swsql += "and b.gs_fees=0 ";
        }
        if (ReqVal.TryGet("scdate") != "") {
            wsql += " and b.case_date >= '" + ReqVal.TryGet("scdate") + "'";
            swsql += " and b.case_date >= '" + ReqVal.TryGet("scdate") + "'";
        }
        if (ReqVal.TryGet("ecdate") != "") {
            wsql += " and b.case_date <= '" + ReqVal.TryGet("ecdate") + "'";
            swsql += " and b.case_date <= '" + ReqVal.TryGet("ecdate") + "'";
        }
        if (ReqVal.TryGet("acust_seq") != "") {
            wsql += " and b.cust_area ='" + Session["seBranch"] + "' and b.cust_seq = '" + ReqVal.TryGet("acust_seq") + "'";
            swsql += " and b.cust_area ='" + Session["seBranch"] + "' and b.cust_seq = '" + ReqVal.TryGet("acust_seq") + "'";
        }
        if (ReqVal.TryGet("cust_name") != "") {
            wsql += " and f.cust_name like '" + ReqVal.TryGet("cust_name") + "%' ";
            swsql += " and f.cust_name like '" + ReqVal.TryGet("cust_name") + "%' ";
        }
        if (ReqVal.TryGet("bseq") != "") {
            wsql += " and b.seq between " + ReqVal.TryGet("bseq") + " and " + ReqVal.TryGet("eseq");
            swsql += " and b.seq between " + ReqVal.TryGet("bseq") + " and " + ReqVal.TryGet("eseq");
        }
        if (qs_dept == "t") {
            wsql += " and a.country='T' ";
            swsql += " and c.country='T' ";
            statsql += " b.stat_code='YZ'";
        }
        if (qs_dept == "e") {
            wsql += " and a.country<>'T' ";
            swsql += " and c.country<>'T' ";
            statsql += " (b.stat_code='YZ' or B.stat_code like 'S%')";
        }

        //表頭
        SQL = "select a.invoice_mark,a.tr_yy,a.tr_mm";
        SQL += ",isnull((select sum(c.service+c.tr_money+c.add_service-c.ar_service) from prear_brt c inner join " + vtblname + " b on c.in_no=b.in_no and c.in_scode=b.in_scode and " + statsql + " and b.ar_code='N' and (b.mark='' or b.mark is null or b.mark='N' ) inner join view_cust F on F.cust_area = B.cust_area and F.cust_seq=B.cust_seq where c.invoice_mark=a.invoice_mark and c.tr_yy=a.tr_yy and c.tr_mm=a.tr_mm and datediff(month,getdate(), c.prear_date)<=0" + swsql + "),0) as service1";
        SQL += ",isnull((select sum(c.service+c.tr_money+c.add_service-c.ar_service) from prear_brt c inner join " + vtblname + " b on c.in_no=b.in_no and c.in_scode=b.in_scode and " + statsql + " and b.ar_code='N' and (b.mark='' or b.mark is null or b.mark='N') inner join view_cust F on F.cust_area = B.cust_area and F.cust_seq=B.cust_seq where c.invoice_mark=a.invoice_mark and c.tr_yy=a.tr_yy and c.tr_mm=a.tr_mm and datediff(month,getdate(), c.prear_date)=1" + swsql + "),0) as service2";
        SQL += ",isnull((select sum(c.service+c.tr_money+c.add_service-c.ar_service) from prear_brt c inner join " + vtblname + " b on c.in_no=b.in_no and c.in_scode=b.in_scode and " + statsql + " and b.ar_code='N' and (b.mark='' or b.mark is null or b.mark='N') inner join view_cust F on F.cust_area = B.cust_area and F.cust_seq=B.cust_seq where c.invoice_mark=a.invoice_mark and c.tr_yy=a.tr_yy and c.tr_mm=a.tr_mm and datediff(month,getdate(), c.prear_date)>1" + swsql + "),0) as service3";
        SQL += ",isnull((select sum(c.service+c.tr_money+c.add_service-c.ar_service) from prear_brt c inner join " + vtblname + " b on c.in_no=b.in_no and c.in_scode=b.in_scode and " + statsql + " and b.ar_code='N' and (b.mark='' or b.mark is null or b.mark='N') inner join view_cust F on F.cust_area = B.cust_area and F.cust_seq=B.cust_seq where c.invoice_mark=a.invoice_mark and c.tr_yy=a.tr_yy and c.tr_mm=a.tr_mm and c.prear_date is null" + swsql + "),0) as service4";
        SQL += " from prear_brt a ";
        SQL += " inner join " + vtblname + " b on a.in_scode=b.in_scode and a.in_no=b.in_no ";
        SQL += " inner join view_cust F on F.cust_area = B.cust_area and F.cust_seq=B.cust_seq ";
        SQL += " where a.case_no=a.case_no " + wsql;
        SQL += " and " + statsql + " and b.ar_code='N' and (b.mark='N' or b.mark ='' or b.mark is null) ";
        SQL += " group by a.invoice_mark,a.tr_yy,a.tr_mm";
        Sys.showLog(SQL);
        conn.DataTable(SQL, dtSum);

        //明細
        SQL = "select a.*,f.cust_name,t.appl_name, B.arcase ";
        SQL += ",B.ar_mark,B.case_date ";
        SQL += ",(select code_name from cust_code where code_type='ar_mark' and cust_code=b.ar_mark) as ar_marknm ";
        SQL += ",(select sc_name from sysctrl.dbo.scode where scode=b.in_scode) as sc_name ";
        SQL += casesql;
        SQL += " from prear_brt a ";
        SQL += " inner join " + vtblname + " b on a.case_no=b.case_no ";
        SQL += " inner join " + vtemptbl + " t ON b.In_no = t.in_no AND b.In_scode = t.in_scode and t.case_sqlno=0 ";
        SQL += " inner join view_cust F on F.cust_area = B.cust_area and F.cust_seq=B.cust_seq ";
        SQL += " where a.case_no=a.case_no " + wsql;
        SQL += " and " + statsql + " and b.ar_code='N' and (b.mark='N' or b.mark ='' or b.mark is null) ";
        ReqVal["qryOrder"] = ReqVal.TryGet("SetOrder", ReqVal.TryGet("qryOrder", "f.cust_name,b.case_no"));
        if (ReqVal.TryGet("qryOrder") != "") {
            SQL += " order by " + ReqVal.TryGet("qryOrder");
        }
        Sys.showLog(SQL);
        conn.DataTable(SQL, dt);

        if (dt.Rows.Count > 0) {
            //抬頭-營洽
            if (qryin_scode == "" || qryin_scode == "*") {
                sc_name = "全部";
            } else {
                sc_name = dt.Rows[0].SafeRead("sc_name", "");
            }
        }
    }

    protected void WordOut() {
        Dictionary<string, string> _tplFile = new Dictionary<string, string>();
        _tplFile.Add("rpt", Server.MapPath("~/ReportTemplate/報表/預計請款記錄表.docx"));
        Rpt.CloneFromFile(_tplFile, true);

        //抬頭-聖國或聖智請款
        string artypename = "";
        if (ReqVal.TryGet("qryinvoice_mark") == "B") {
            artypename = "聖國";
        }
        if (ReqVal.TryGet("qryinvoice_mark") == "A" || ReqVal.TryGet("qryinvoice_mark") == "E") {
            artypename = "聖智";
        }
        //案件別-國內案或出口案
        string deptname = "", datename = "";
        if (qs_dept == "t") {
            deptname = "國內";
            datename = "官發";
        }
        if (qs_dept == "e") {
            deptname = "出口";
            datename = "確認";
        }
        //地區
        string branchname = Sys.GetSession("SeBranchName").Replace("所", "");

        //檔名:m1583聖國預計請款記錄表20211014.docx
        string docFileName = string.Format("{0}{1}預計請款記錄表{2}.docx"
            , Sys.GetSession("scode")
            , artypename
            , DateTime.Today.ToString("yyyyMMdd")
            );

        //表頭統計
        if (dtSum.Rows.Count > 0) {
            DataRow dr = dtSum.Rows[0];
            Rpt.CopyTable("tbl_sum");
            Rpt.ReplaceBookmark("top_sc_name", sc_name);
            Rpt.ReplaceBookmark("service1", dr.SafeRead("service1", ""));
            Rpt.ReplaceBookmark("service2", dr.SafeRead("service1", ""));
            Rpt.ReplaceBookmark("service3", dr.SafeRead("service3", ""));
            Rpt.ReplaceBookmark("service4", dr.SafeRead("service4", ""));
            decimal totservice = dr.SafeRead("service1", (decimal)0) + dr.SafeRead("service2", (decimal)0) + dr.SafeRead("service3", (decimal)0) + dr.SafeRead("service4", (decimal)0);
            Rpt.ReplaceBookmark("totservice", dr.SafeRead("service1", ""));
        }

        if (dt.Rows.Count > 0) {
            //表頭
            Rpt.CopyBlock("b_head");
            Rpt.ReplaceBookmark("datename", datename);

            //明細
            for (int i = 0; i < dt.Rows.Count; i++) {
                DataRow dr = dt.Rows[i];

                Rpt.CopyTable("tbl_detail");

                //營洽
                Rpt.ReplaceBookmark("dtl_sc_name", dr.SafeRead("sc_name", ""));
                //客戶名稱
                Rpt.ReplaceBookmark("cust_name", dr.SafeRead("cust_name", "").ToUnicode().CutData(12));
                //交辦日期
                Rpt.ReplaceBookmark("case_date", dr.GetDateTimeString("case_date", "yyyy/M/d"));
                //2015/6/4增加顯示國內案官發日期、出口案確認日期
                string gs_step_date = "";
                if (qs_dept == "e") {
                    //抓取本筆交辦單之最近一次營洽聯收確認代理人請款日期
                    SQL = "select max(tran_date) as gs_step_date from fees_ext where case_no='" + dr.SafeRead("case_no", "") + "' and fees>0";
                    gs_step_date = conn.getDateTime(SQL, "yyyy/M/d");
                } else {
                    //官發日期
                    SQL = "select min(a.step_date) as gs_step_date from step_dmt a,fees_dmt b where a.rs_no=b.rs_no and b.case_no='" + dr.SafeRead("case_no", "") + "'";
                    gs_step_date = conn.getDateTime(SQL, "yyyy/M/d");
                }
                Rpt.ReplaceBookmark("gs_step_date", gs_step_date);
                //案件編號
                string fseq = "";
                if (qs_dept == "e") {
                    fseq = Sys.formatSeq1(dr.SafeRead("seq", ""), dr.SafeRead("seq1", ""), (dr.SafeRead("country", "") == "T" ? "" : dr.SafeRead("country", "")), Sys.GetSession("SeBranch"), Sys.GetSession("dept") + "E");
                } else {
                    fseq = Sys.formatSeq1(dr.SafeRead("seq", ""), dr.SafeRead("seq1", ""), (dr.SafeRead("country", "") == "T" ? "" : dr.SafeRead("country", "")), Sys.GetSession("SeBranch"), Sys.GetSession("dept"));
                }
                Rpt.ReplaceBookmark("seq", fseq);
                //案件名稱
                Rpt.ReplaceBookmark("appl_name", dr.SafeRead("appl_name", "").ToUnicode().CutData(12));
                //請款註記
                string strar_mark = "";
                if (dr.SafeRead("ar_mark", "") != "N") {
                    strar_mark = dr.SafeRead("ar_marknm", "");
                }
                Rpt.ReplaceBookmark("strar_mark", strar_mark);
                //案性
                Rpt.ReplaceBookmark("case_name", dr.SafeRead("case_name", "").ToUnicode());
                //未稅服務費
                decimal service = dr.SafeRead("service", (decimal)0) + dr.SafeRead("tr_money", (decimal)0) + dr.SafeRead("add_service", (decimal)0) - dr.SafeRead("ar_service", (decimal)0);
                Rpt.ReplaceBookmark("service", service.ToString());
                //未稅規費
                decimal fees = dr.SafeRead("fees", (decimal)0) + dr.SafeRead("add_fees", (decimal)0) - dr.SafeRead("ar_fees", (decimal)0);
                Rpt.ReplaceBookmark("fees", fees.ToString());
                //未稅合計
                decimal tot_money = service + fees;
                Rpt.ReplaceBookmark("tot_money", tot_money.ToString());

                //預計請款日與作業年月同月份顯示註記
                string show_flag = "";
                if (dr.SafeRead("prear_date", "") != "") {
                    if (Convert.ToInt32(dr.GetDateTimeString("prear_date", "yyyy")) == Convert.ToInt32(tr_yy) && Convert.ToInt32(dr.GetDateTimeString("prear_date", "MM")) == Convert.ToInt32(tr_mm)) {
                        show_flag = "*";
                    }
                }
                Rpt.ReplaceBookmark("prear_date", show_flag + dr.GetDateTimeString("prear_date", "yyyy/M/d"));
                Rpt.ReplaceBookmark("noar_remark", dr.SafeRead("noar_remark", "").ToUnicode());
            }

            //合計
            Rpt.CopyTable("tbl_foot");
            Rpt.ReplaceBookmark("totcnt", dt.Rows.Count.ToString());
            Rpt.ReplaceBookmark("pdate", DateTime.Today.ToShortDateString());

            //頁首/頁尾要在最後處理
            Rpt.CopyPageHeader("rpt");//複製頁首後再填入資料
            Rpt.ReplaceBookmark("artypename", artypename);
            Rpt.ReplaceBookmark("deptname", deptname);
            Rpt.ReplaceBookmark("tr_yy", tr_yy);
            Rpt.ReplaceBookmark("tr_mm", tr_mm);
            Rpt.ReplaceBookmark("branchname", branchname);
            Rpt.ReplaceBookmark("sc_name", sc_name);

            Rpt.CopyPageFoot("rpt");//複製頁尾/邊界

            Rpt.Flush(docFileName);//輸出
        } else {
            strOut.AppendLine("<script language=\"javascript\">");
            strOut.AppendLine("    alert(\"無資料需產生\");");
            strOut.AppendLine("    window.close();");
            strOut.AppendLine("<" + "/script>");
            Response.Write(strOut.ToString());
        }
    }
</script>
