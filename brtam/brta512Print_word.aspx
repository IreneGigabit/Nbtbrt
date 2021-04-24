<%@ Page Language="C#" %>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Data.SqlClient" %>
<%@ Import Namespace = "System.IO"%>
<%@ Import Namespace = "System.Linq"%>
<%@ Import Namespace = "System.Collections.Generic"%>

<script runat="server">
    protected OpenXmlHelper Rpt = new OpenXmlHelper();
    protected StringBuilder strOut = new StringBuilder();

    protected string branchname = "";
    protected string mp_date = "";
    protected string dept = "";
    protected string send_way = "";

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "Private";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;
        Response.Clear();

        dept = Sys.GetSession("dept");
        send_way = (Request["send_way"] ?? "").ToString();//E

        try {
            WordOut();
        }
        catch (Exception ex) {
            strOut.AppendLine("<script language=\"javascript\">");
            strOut.AppendLine("    alert(\"官發規費明細表 Word 產生失敗!!!\");");
            strOut.AppendLine("<" + "/script>");
            Response.Write(strOut.ToString());
            Response.Write(ex.Message);
            Response.Write(ex.StackTrace.Replace("\n", "<BR>"));
        }
        finally {
            if (Rpt != null) Rpt.Dispose();
        }
    }

    protected void WordOut() {
        Dictionary<string, string> _tplFile = new Dictionary<string, string>();
        _tplFile.Add("gsrpt", Server.MapPath("~/ReportTemplate/報表/官方規費明細表.docx"));
        Rpt.CloneFromFile(_tplFile, true);
        string docFileName = string.Format("GS{0}-512T-{1:yyyyMMdd}.docx", send_way, Util.str2Dateime(Request["edate"]));

        string SQL = "", wSQL = "";
        DataTable dt = new DataTable();
        using (DBHelper conn = new DBHelper(Conn.btbrt).Debug(false)) {
            if ((Request["sdate"] ?? "") != "") wSQL += " and step_date>='" + Request["sdate"] + "'";
            if ((Request["edate"] ?? "") != "") wSQL += " and step_date<='" + Request["edate"] + "'";
            if ((Request["srs_no"] ?? "") != "") wSQL += " and rs_no>='" + Request["srs_no"] + "'";
            if ((Request["ers_no"] ?? "") != "") wSQL += " and rs_no<='" + Request["ers_no"] + "'";
            if ((Request["sseq"] ?? "") != "") wSQL += " and seq>=" + Request["sseq"];
            if ((Request["eseq"] ?? "") != "") wSQL += " and seq<=" + Request["eseq"];
            if ((Request["in_scode"] ?? "") != "") wSQL += " and dmt_scode='" + Request["in_scode"] + "'";
            if ((Request["scust_seq"] ?? "") != "") wSQL += " and cust_seq>=" + Request["scust_seq"];
            if ((Request["ecust_seq"] ?? "") != "") wSQL += " and cust_seq<=" + Request["ecust_seq"];
            if ((Request["qrysend_dept"] ?? "") != "") wSQL += " and opt_Branch='" + Request["qrysend_dept"] + "'";
            if ((Request["send_way"] ?? "") != "") {
                if ((Request["send_way"] ?? "") == "E" || (Request["send_way"] ?? "") == "EA") {
                    wSQL += " and send_way='" + Request["send_way"] + "'";
                } else {
                    wSQL += "  and isnull(send_way,'') not in('E','EA') ";
                }
            }

            SQL = "select distinct send_cl,send_clnm,branch,seq,seq1,cust_area,cust_seq,ap_cname1,ap_cname2,rs_no,step_date,rs_code,rs_detail,mp_date ";
            SQL += ",fees,dmt_scode,cappl_name,case_no,(select sc_name from sysctrl.dbo.scode where scode=a.dmt_scode) as sc_name ";
            SQL += ",(select ar_mark from case_dmt where case_no=a.case_no) as ar_mark ";
            SQL += ",''fseq,''cust_name,0 service1,''case_no1";
            SQL += " from vstep_dmt a where branch='" + Session["seBranch"] + "' and cg='G' and rs='S'";
            SQL += wSQL + " and fees>0";
            SQL += " and left(rs_no,1)='G' ";//2006/5/27配合爭救案系統不列印爭救案發文資料,爭救案發文字號第一碼為B
            SQL += " order by send_cl,seq,seq1,rs_no";
            conn.DataTable(SQL, dt);

            //整理資料
            for (int i = 0; i < dt.Rows.Count; i++) {
                DataRow dr = dt.Rows[i];
                using (DBHelper cnn = new DBHelper(Conn.Sysctrl).Debug(Request["chkTest"] == "TEST")) {
                    SQL = "select branchname from branch_code where branch='" + dr["Branch"] + "'";
                    object objResult = cnn.ExecuteScalar(SQL);
                    branchname = (objResult == DBNull.Value || objResult == null ? "" : objResult.ToString());

                    //總收發文日
                    if (Request["sdate"].ToString() == Request["edate"].ToString()) {
                        if (dr.SafeRead("mp_date", "") != "") {
                            mp_date = "總發文日期：" + dr.GetDateTimeString("mp_date", "yyyy/M/d");
                        }
                    }

                    //案號
                    dr["fseq"] = Sys.formatSeq1(dr.SafeRead("seq", ""), dr.SafeRead("seq1", ""), "", dr.SafeRead("Branch", ""), Sys.GetSession("dept"));

                    SQL = "Select RTRIM(ISNULL(ap_cname1, '')) + RTRIM(ISNULL(ap_cname2, ''))  as cust_name from apcust as c ";
                    SQL += " where c.cust_area='" + dr["cust_area"] + "' and c.cust_seq='" + dr["cust_seq"] + "'";
                    dr["cust_name"] = dr.SafeRead("cust_area", "") + dr.SafeRead("cust_seq", "").PadLeft(5, '0');
                    using (SqlDataReader dr1 = conn.ExecuteReader(SQL)) {
                        if (dr1.Read()) {
                            dr["cust_name"] += dr1.SafeRead("cust_name", "");
                        }
                    }

                    //交辦單號
                    string case_no1 = "";
                    SQL = "select case_no from fees_dmt where rs_no='" + dr["rs_no"] + "' ";
                    using (SqlDataReader dr1 = conn.ExecuteReader(SQL)) {
                        while (dr1.Read()) {
                            case_no1 += "<BR>" + dr1.SafeRead("case_no", "");
                        }
                    }
                    case_no1 = (case_no1 != "" ? case_no1.Substring(4) : "");
                    dr["case_no1"] = case_no1;

                    int service1 = 0;
                    SQL = "select isnull(service,0)+isnull(add_service,0) service from case_dmt where case_no in(select case_no from fees_dmt where rs_no='" + dr["rs_no"] + "') ";
                    using (SqlDataReader dr1 = conn.ExecuteReader(SQL)) {
                        while (dr1.Read()) {
                            service1 += Convert.ToInt32(dr1.SafeRead("service", "0"));
                        }
                    }
                    dr["service1"] = service1;
                }
            }

            int fees = 0;//小計規費
            int service = 0;//小計服務費
            int count = 0;//小計件數

            //產生內容
            string title = "";
            if (send_way == "E") {
                title = "(電子送件)";
            } else if (send_way == "EA") {
                title = "(註冊費電子送件)";
            }

            Rpt.CopyTable("tbl_title");//表頭
            Rpt.ReplaceBookmark("br_nm", branchname);
            Rpt.ReplaceBookmark("send_way", title);
            Rpt.ReplaceBookmark("sdate", Request["sdate"]);
            Rpt.ReplaceBookmark("edate", Request["edate"]);
            Rpt.ReplaceBookmark("mp_date", mp_date);
            Rpt.ReplaceBookmark("pdate", DateTime.Today.ToShortDateString());


            DataTable dtCL = dt.DefaultView.ToTable(true, new string[] { "branch", "send_cl", "send_clnm" });
            for (int c = 0; c < dtCL.Rows.Count; c++) {
                fees = 0;//小計規費
                service = 0;//小計服務費
                count = 0;//小計件數
                
                Rpt.CopyTable("tbl_cltitle");//發文對象

                Rpt.ReplaceBookmark("send_clnm", dtCL.Rows[c].SafeRead("send_clnm", ""));
                //DataTable dtDtl = dt.Select("branch='" + dtCL.Rows[c].SafeRead("branch", "") + "' and send_cl='" + dtCL.Rows[c].SafeRead("send_cl", "") + "'").CopyToDataTable();
                var rows = dt.Select("branch='" + dtCL.Rows[c].SafeRead("branch", "") + "' and send_cl='" + dtCL.Rows[c].SafeRead("send_cl", "") + "'");
                var dtDtl = rows.Any() ? rows.CopyToDataTable() : dt.Clone();
                for (int d = 0; d < dtDtl.Rows.Count; d++) {
                    Rpt.CopyTable("tbl_detail");//明細行
                    Rpt.ReplaceBookmark("seq", dtDtl.Rows[d].SafeRead("fseq", ""));
                    Rpt.ReplaceBookmark("appl_name", dtDtl.Rows[d].SafeRead("cappl_name", "").ToUnicode());
                    Rpt.ReplaceBookmark("rs_code", dtDtl.Rows[d].SafeRead("rs_code", ""));
                    Rpt.ReplaceBookmark("rs_detail", dtDtl.Rows[d].SafeRead("rs_detail", "").ToUnicode());
                    Rpt.ReplaceBookmark("cust_name", dtDtl.Rows[d].SafeRead("cust_name", "").ToUnicode());
                    Rpt.ReplaceBookmark("case_no", dtDtl.Rows[d].SafeRead("case_no1", ""));
                    Rpt.ReplaceBookmark("service", dtDtl.Rows[d].SafeRead("service1", "0") + (dtDtl.Rows[d].SafeRead("ar_mark", "") == "D" ? "(D)" : ""));
                    Rpt.ReplaceBookmark("fees", dtDtl.Rows[d].SafeRead("fees", "0"));
                    Rpt.ReplaceBookmark("sc_name", dtDtl.Rows[d].SafeRead("sc_name", ""));

                    fees += Convert.ToInt32(dtDtl.Rows[d].SafeRead("fees", "0"));//小計規費
                    service += Convert.ToInt32(dtDtl.Rows[d].SafeRead("service1", "0"));//總計規費
                    count += 1;
                }
                Rpt.CopyTable("tbl_subtot");//小計行
                Rpt.ReplaceBookmark("cnt", count.ToString());
                Rpt.ReplaceBookmark("sub_service", service.ToString());
                Rpt.ReplaceBookmark("sub_fees", fees.ToString());
            }

            if (dt.Rows.Count > 0) {
                Rpt.CopyPageFoot("gsrpt", false);//複製頁尾/邊界
                //Rpt.Flush(docFileName);
                Rpt.SaveAndFlush(Server.MapPath("~/ReportWord/" + DateTime.Today.ToString("yyyyMM") + "/" + docFileName), docFileName);
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

