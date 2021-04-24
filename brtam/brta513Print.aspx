<%@ Page Language="C#" %>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Data.SqlClient" %>
<%@ Import Namespace = "System.IO"%>
<%@ Import Namespace = "System.Linq"%>
<%@ Import Namespace = "System.Collections.Generic"%>

<script runat="server">
    protected OpenXmlHelper Rpt = new OpenXmlHelper();
    protected StringBuilder strOut = new StringBuilder();

    protected string dept = "";
    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "Private";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;
        Response.Clear();

        dept = Sys.GetSession("dept");

        try {
            WordOut();
        }
        catch(Exception ex) {
            strOut.AppendLine("<script language=\"javascript\">");
            strOut.AppendLine("    alert(\"商標官發收入明細表 Word 產生失敗!!!\");");
            strOut.AppendLine("<" + "/script>");
            Response.Write(strOut.ToString());
            Response.Write(ex.Message);
            Response.Write(ex.StackTrace.Replace("\n","<BR>"));
        }
        finally {
            if (Rpt != null) Rpt.Dispose();
        }
    }

    protected void WordOut() {
        Dictionary<string, string> _tplFile = new Dictionary<string, string>();
        _tplFile.Add("gsrpt", Server.MapPath("~/ReportTemplate/報表/官發收入明細表.docx"));
        Rpt.CloneFromFile(_tplFile, true);
        string docFileName = string.Format("{0}官發收入明細表.docx", Session["scode"]);

        string SQL = "", wSQL = "";
        DataTable dt = new DataTable();
        using (DBHelper conn = new DBHelper(Conn.btbrt).Debug(true)) {
            if ((Request["sdate"] ?? "") != "") wSQL += " and a.step_date>='" + Request["sdate"] + "'";
            if ((Request["edate"] ?? "") != "") wSQL += " and a.step_date<='" + Request["edate"] + "'";
            if ((Request["srs_no"] ?? "") != "") wSQL += " and a.rs_no>='" + Request["srs_no"] + "'";
            if ((Request["ers_no"] ?? "") != "") wSQL += " and a.rs_no<='" + Request["ers_no"] + "'";
            if ((Request["sseq"] ?? "") != "") wSQL += " and a.seq>=" + Request["sseq"];
            if ((Request["eseq"] ?? "") != "") wSQL += " and a.seq<=" + Request["eseq"];
            if ((Request["in_scode"] ?? "") != "") wSQL += " and f.scode='" + Request["in_scode"] + "'";
            if ((Request["scust_seq"] ?? "") != "") wSQL += " and f.cust_seq>=" + Request["scust_seq"];
            if ((Request["ecust_seq"] ?? "") != "") wSQL += " and f.cust_seq<=" + Request["ecust_seq"];

            SQL = "select (select code_name from vagt g where a.rs_agt_no=g.agt_no) as compname,a.rs_agt_no ";
            SQL += ",a.rs_no,a.main_rs_no,a.step_date,a.branch,a.seq,a.seq1 ";
            SQL += ",(e.ap_cname1+isnull(e.ap_cname2,'')) as ap_cname1,f.appl_name as cappl_name ";
            SQL += ",a.rs_detail,b.case_no,a.tot_num,c.ar_mark ";
            SQL += ",isnull(b.service,0) as service,isnull(c.oth_money,0) as oth_money,isnull(b.service,0)+isnull(c.oth_money,0) as nservice ";
            SQL += ",(select agt_name from agt where agt_no=a.rs_agt_no) agt_name ";
            SQL += ",''fseq,''ap_cname ";
            SQL += " from step_dmt a ";
            SQL += " inner join fees_dmt b on a.rs_no=b.rs_no ";
            SQL += " inner join case_dmt c on b.case_no=c.case_no ";
            SQL += " inner join dmt_temp d on c.in_no=d.in_no and a.seq = d.seq and a.seq1 = d.seq1 ";
            SQL += " inner join apcust e on c.cust_area=e.cust_area and c.cust_seq=e.cust_seq ";
            SQL += " inner join dmt f on a.seq=f.seq and a.seq1=f.seq1 ";
            SQL += " where a.branch='" + Session["seBranch"] + "' and a.cg='G' and a.rs='S' ";
            SQL += wSQL;
            SQL += " order by compname,a.rs_agt_no,a.step_date desc,a.seq desc,a.seq1 desc";
            conn.DataTable(SQL, dt);

            //整理資料
            for (int i = 0; i < dt.Rows.Count; i++) {
                DataRow dr = dt.Rows[i];
                using (DBHelper cnn = new DBHelper(Conn.Sysctrl).Debug(Request["chkTest"] == "TEST")) {
                    dr["fseq"] = Sys.formatSeq1(dr.SafeRead("seq", ""), dr.SafeRead("seq1", ""), "", dr.SafeRead("Branch", ""), Sys.GetSession("dept"));

                    string ap_cname = "";
                    SQL = "select a.ap_cname from dmt_temp_ap a inner join case_dmt b on a.in_no=b.in_no where a.case_sqlno=0 and b.case_no='" + dr.SafeRead("case_no", "") + "'";
                    using (SqlDataReader dr1 = conn.ExecuteReader(SQL)) {
                        while (dr1.Read()) {
                            ap_cname += "\n" + dr1.SafeRead("ap_cname","");
                        }
                    }
                    dr["ap_cname"] = (ap_cname != "" ? ap_cname.Substring(1) : "");
                }
            }

            int count = 0;//小計件數
            int tot_service = 0;//小計服務費
            string havemark = "";//備註
            
            DataTable dtCL = dt.DefaultView.ToTable(true, new string[] { "branch", "compname", "rs_agt_no", "agt_name" });
            for (int i = 0; i < dtCL.Rows.Count; i++) {
                count = 0;//小計件數
                tot_service = 0;//小計服務費
                
                if (i != 0) Rpt.NewPage();
                Rpt.CopyTable("tbl_title");//表頭
                Rpt.ReplaceBookmark("compname", dtCL.Rows[i].SafeRead("compname", ""));
                Rpt.ReplaceBookmark("agt_name", dtCL.Rows[i].SafeRead("agt_name", ""));
                Rpt.ReplaceBookmark("sdate", Request["sdate"]);
                Rpt.ReplaceBookmark("edate", Request["edate"]);

                //DataTable dtDtl = dt.Select("branch='" + dtCL.Rows[i].SafeRead("branch", "") + "' and rs_agt_no='" + dtCL.Rows[i].SafeRead("rs_agt_no", "") + "'", " compname,rs_agt_no,step_date,seq,seq1").CopyToDataTable();
                var rows = dt.Select("branch='" + dtCL.Rows[i].SafeRead("branch", "") + "' and rs_agt_no='" + dtCL.Rows[i].SafeRead("rs_agt_no", "") + "'", " compname,rs_agt_no,step_date,seq,seq1");
                var dtDtl = rows.Any() ? rows.CopyToDataTable() : dt.Clone();
                for (int d = 0; d < dtDtl.Rows.Count; d++) {
                    DataRow dr=dtDtl.Rows[d];

                    Rpt.CopyTable("tbl_detail");//明細行
                    Rpt.ReplaceBookmark("step_date", Util.parseDBDate(dr.SafeRead("step_date", ""), "M/d"));
                    Rpt.ReplaceBookmark("seq", dr.SafeRead("fseq", ""));
                    Rpt.ReplaceBookmark("ap_cname", dr.SafeRead("ap_cname", "").ToUnicode().Left(14));
                    Rpt.ReplaceBookmark("cappl_name", dr.SafeRead("cappl_name", "").ToUnicode().CutData(17).Replace("...",""));
                    Rpt.ReplaceBookmark("rs_detail", dr.SafeRead("rs_detail", "").ToUnicode().Left(8));

                    if (Convert.ToInt32(dr.SafeRead("service","0"))==0&&Convert.ToInt32(dr.SafeRead("tot_num","0"))==1){
                        havemark = "＊：後續案－服務費已於第一次申請時顯示";
                        Rpt.ReplaceBookmark("service", "＊"+dr.SafeRead("service", "0"));
                        tot_service += Convert.ToInt32(dr.SafeRead("service", "0"));
                    }else{
                        if (Convert.ToInt32(dr.SafeRead("service","0"))>0){
                            Rpt.ReplaceBookmark("service", dr.SafeRead("nservice", "0"));//2007/6/26第一次支出之服務費+轉帳費用
                            tot_service += Convert.ToInt32(dr.SafeRead("nservice", "0"));
                        } else {
                            Rpt.ReplaceBookmark("service", dr.SafeRead("service", "0"));
                            tot_service += Convert.ToInt32(dr.SafeRead("service", "0"));
                        }
                    }

                    count += 1;
                }
                Rpt.CopyTable("tbl_total");//小計行
                Rpt.ReplaceBookmark("cnt", count.ToString());
                Rpt.ReplaceBookmark("tot_service", tot_service.ToString());
                Rpt.ReplaceBookmark("txt_mark", havemark);
            }

            if (dt.Rows.Count > 0) {
                Rpt.AddParagraph();
                Rpt.CopyPageFoot("gsrpt", false);//複製頁尾/邊界
                Rpt.Flush(docFileName);
                //Rpt.SaveAndFlush(Server.MapPath("~/ReportWord/" + DateTime.Today.ToString("yyyyMM") + "/" + docFileName), docFileName);
                //Rpt.SaveTo(Server.MapPath("~/ReportWord/" + docFileName));
            } else {
                strOut.AppendLine("<script language=\"javascript\">");
                strOut.AppendLine("    alert(\"無資料需產生\");");
                strOut.AppendLine("<" + "/script>");
                Response.Write(strOut.ToString());
            }
        }
    }
</script>
