<%@ Page Language="C#" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace = "System.IO"%>
<%@ Import Namespace = "System.Linq"%>
<%@ Import Namespace = "System.Collections.Generic"%>

<script runat="server">
    protected OpenXmlHelper Rpt = new OpenXmlHelper();
    protected int right = 0;
    protected string se_scode;
    protected string sdate, edate, cust_seq, scust_seq, ecust_seq;
        
    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "Private";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;
        Response.Clear();

        right=Convert.ToInt32(Request["right"] ?? "0");
        se_scode = Sys.GetSession("scode");

        sdate = (Request["sctrl_date"] ?? "");
        edate = (Request["ectrl_date"] ?? "");
        cust_seq = (Request["cust_seq"] ?? "");
        scust_seq = (Request["scust_seq"] ?? "");
        ecust_seq = (Request["ecust_seq"] ?? "");
        
        try {
            WordOut();
        }
        finally {
            if (Rpt != null) Rpt.Dispose();
        }
    }

    protected void WordOut() {
        Dictionary<string, string> _tplFile = new Dictionary<string, string>();
        _tplFile.Add("rpt", Server.MapPath("~/ReportTemplate/報表/延展管制表.docx"));
        Rpt.CloneFromFile(_tplFile, true);

        string docFileName = string.Format("{0}-延展管制表.docx", se_scode);

        string SQL = "";
        using (DBHelper conn = new DBHelper(Conn.btbrt).Debug(false)) {
            SQL = "select f.seq,f.seq1,f.issue_no,f.scode,f.ap_cname,f.appl_name as cappl_name,f.term2,n.draw_file";
            SQL += " from dmt f left join ndmt n on f.seq=n.seq and f.seq1=n.seq1";
            SQL += " where 1=1 ";
            if ((Request["sctrl_date"] ?? "") != "") SQL += " and f.term2>='" + Request["sctrl_date"] + "'";
            if ((Request["ectrl_date"] ?? "") != "") SQL += " and f.term2<='" + Request["ectrl_date"] + "'";
            if ((Request["sseq"] ?? "") != "") SQL += " and f.seq>='" + Request["sseq"] + "'";
            if ((Request["eseq"] ?? "") != "") SQL += " and f.seq<='" + Request["eseq"] + "'";
            if ((Request["scode1"] ?? "") != "") SQL += " and f.scode='" + Request["scode1"] + "'";
            if ((Request["scust_seq"] ?? "") != "") SQL += " and f.cust_seq>='" + Request["scust_seq"] + "'";
            if ((Request["ecust_seq"] ?? "") != "") SQL += " and f.cust_seq<='" + Request["ecust_seq"] + "'";
            if ((Request["ap_cname"] ?? "") != "") SQL += " and f.ap_cname like '%" + Request["ap_cname"] + "%'";
            //from延展期限稽催查詢brta64list2.asp
            if ((Request["cust_seq"] ?? "") != "") SQL += " and f.cust_seq='" + Request["cust_seq"] + "'";
            if ((Request["qendcode"] ?? "") != "Y") SQL += " and f.end_date is null";
            if ((Request["sort1"] ?? "") != "") {
                if ((Request["sort1"] ?? "") == "sort_seq") {
                    SQL += " order by f.seq ";
                }
                if ((Request["sort1"] ?? "") == "sort_cust") {
                    SQL += " order by f.cust_seq ";
                }
            } else {
                SQL += " order by f.seq ";
            }
            //Sys.showLog(SQL);
            //Response.End();
                
            DataTable dt = new DataTable();
            conn.DataTable(SQL, dt);

            if (dt.Rows.Count > 0) {
                //表頭
                Rpt.CopyTable("tbl_title");
                //明細
                for (int i = 0; i < dt.Rows.Count; i++) {
                    DataRow dr = dt.Rows[i];
                    Rpt.CopyTable("tbl_detail");

                    string fseq = Sys.formatSeq1(dr.SafeRead("seq", ""), dr.SafeRead("seq1", ""), "", Sys.GetSession("seBranch"), Sys.GetSession("dept"));
                    Rpt.ReplaceBookmark("fseq", fseq);
                    Rpt.ReplaceBookmark("issue_no", dr.SafeRead("issue_no", ""));
                    //商標圖樣
                    string draw_file = Sys.Path2Nbtbrt(dr.SafeRead("draw_file", ""));
                    if (dr.SafeRead("draw_file", "") != "") {
                        Rpt.ReplaceBookmark("draw_br", "\n");
                        try {
                            Rpt.ReplaceBookmark("draw_file", Rpt.GetImage(new ImageFile(Server.MapPath(draw_file),(decimal)0.5)));
                        }
                        catch (DirectoryNotFoundException) {
                            Rpt.ReplaceBookmark("draw_file", "找不到路徑(" + draw_file + ")！！", System.Drawing.Color.Red);
                        }
                        catch (FileNotFoundException) {
                            Rpt.ReplaceBookmark("draw_file", "找不到檔案(" + draw_file + ")！！", System.Drawing.Color.Red);
                        }
                    } else {
                        Rpt.ReplaceBookmark("draw_br", "");
                        Rpt.ReplaceBookmark("draw_file", "");
                    }
                    
                    Rpt.ReplaceBookmark("cappl_name", dr.SafeRead("cappl_name", "").Trim().ToUnicode());
                    //2008/6/23李協理Email確認只要抓取第一筆申請人資料
                    SQL = "select ap_cname from dmt_ap where seq=" + dr["seq"] + " and seq1='" + dr["seq1"] + "'";
                    using (SqlDataReader dr1 = conn.ExecuteReader(SQL)) {
                        if (dr1.Read()) {
                            Rpt.ReplaceBookmark("ap_cname", dr1.SafeRead("ap_cname", "").Trim().ToUnicode().Left(14));
                        } else {
                            Rpt.ReplaceBookmark("ap_cname", dr.SafeRead("ap_cname", "").Trim().ToUnicode().Left(14));
                        }
                    }
                    Rpt.ReplaceBookmark("scode", dr.SafeRead("scode", "").Trim().ToUnicode());
                    Rpt.ReplaceBookmark("term2", dr.GetDateTimeString("term2", "yyyy/M/d"));
                }
                //表尾
                Rpt.CopyTable("tbl_total");
                Rpt.ReplaceBookmark("totcnt", dt.Rows.Count.ToString());//總計
                Rpt.ReplaceBookmark("pdate", DateTime.Today.ToShortDateString());//列印日期
            }

            Rpt.CopyPageHeader("rpt");//複製頁首後再填入資料
            //商標權期限期間
            string datearea = "";
            datearea += sdate;
            datearea += (edate != "" ? "~" + edate : "");
            Rpt.ReplaceBookmark("qdatearea", datearea);
            //地區
            string branchname = Sys.getCodeName(conn, "sysctrl.dbo.branch_code", "branchname", "where branch='" + Session["seBranch"] + "'");
            Rpt.ReplaceBookmark("branchname", branchname);
            //客戶編號
            string custseq = "";
            if (scust_seq != "" || ecust_seq != "") {
                custseq += scust_seq + "~" + ecust_seq;
            } else {
                if (cust_seq != "")
                    custseq = cust_seq;
                else
                    custseq = "全部";
            }
            Rpt.ReplaceBookmark("custseq", custseq);

            Rpt.CopyPageFoot("rpt");//複製頁尾/邊界
            Rpt.Flush(docFileName);
        }
    }
</script>
