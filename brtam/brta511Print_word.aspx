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
        catch(Exception ex) {
            strOut.AppendLine("<script language=\"javascript\">");
            strOut.AppendLine("    alert(\"商標官方發文明細表 Word 產生失敗!!!\");");
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
        _tplFile.Add("gsrpt", Server.MapPath("~/ReportTemplate/報表/官方發文明細表.docx"));
        Rpt.CloneFromFile(_tplFile, true);
        string docFileName = string.Format("GS{0}-511T-{1:yyyyMMdd}.docx", send_way, Util.str2Dateime(Request["edate"]));

        string SQL = "", wSQL = "";
        DataTable dt = new DataTable();
        using (DBHelper conn = new DBHelper(Conn.btbrt).Debug(true)) {
            if ((Request["sdate"] ?? "") != "") wSQL += " and step_date>='" + Request["sdate"] + "'";
            if ((Request["edate"] ?? "") != "") wSQL += " and step_date<='" + Request["edate"] + "'";
            if ((Request["srs_no"] ?? "") != "") wSQL += " and main_rs_no>='" + Request["srs_no"] + "'";
            if ((Request["ers_no"] ?? "") != "") wSQL += " and main_rs_no<='" + Request["ers_no"] + "'";
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

            SQL = "select send_cl,send_clnm,branch,main_rs_no,seq,seq1,rs_no,step_date,rs_detail,apply_no,fees,'正本' as sendmark,step_grade,cappl_name,class,issue_no ";
            SQL += ",send_way,pr_scode,receipt_type,receipt_title ";
            SQL += ",''fseq,''pr_scodenm,''rectitle,''nstep_grade";
            SQL += " from vstep_dmt where branch='" + Session["seBranch"] + "' and cg = 'g' and rs = 's'";
            SQL += wSQL;
            SQL += " and left(rs_no,1)='G' ";//2006/5/27配合爭救案系統不列印爭救案發文資料,爭救案發文字號第一碼為B
            SQL += " union ";
            SQL += "select send_cl1 as send_cl,send_cl1nm as send_clnm,branch,main_rs_no,seq,seq1,rs_no,step_date,rs_detail,apply_no,0 fees,'副本' as sendmark,step_grade,cappl_name,class,issue_no";
            SQL += ",send_way,pr_scode,receipt_type,receipt_title ";
            SQL += ",''fseq,''pr_scodenm,''rectitle,''nstep_grade";
            SQL += " from vstep_dmt where branch='" + Session["seBranch"] + "' and cg = 'g' and rs = 's'";
            SQL += wSQL + " and send_cl1 is not null";
            SQL += " and left(rs_no,1)='G' ";//2006/5/27配合爭救案系統不列印爭救案發文資料,爭救案發文字號第一碼為B
            SQL += " group by send_cl,main_rs_no,send_clnm,send_cl1,send_cl1nm,branch,seq,seq1,rs_no,step_date,rs_detail,apply_no,fees,step_grade,cappl_name,class,issue_no,send_way,pr_scode,receipt_type,receipt_title ";
            SQL += " order by send_cl,main_rs_no,seq,seq1,rs_no";
            conn.DataTable(SQL, dt);

            //整理資料
            for (int i = 0; i < dt.Rows.Count; i++) {
                DataRow dr = dt.Rows[i];
                using (DBHelper cnn = new DBHelper(Conn.Sysctrl).Debug(Request["chkTest"] == "TEST")) {
                    branchname = Sys.getCodeName(conn, "sysctrl.dbo.branch_code", "branchname", "where branch='" + dr["Branch"] + "'");

                    dr["fseq"] = Sys.formatSeq1(dr.SafeRead("seq", ""), dr.SafeRead("seq1", ""), "", dr.SafeRead("Branch", ""), Sys.GetSession("dept"));

                    if (dr.SafeRead("issue_no", "") != "") {
                        dr["issue_no"] = "(" + dr.SafeRead("issue_no", "") + ")";
                    }

                    if (dr.SafeRead("step_grade", "") != "") {
                        dr["nstep_grade"] = "(" + dr.SafeRead("step_grade", "") + ")";
                    }

                    SQL = "select sc_name from scode where scode='" + dr["pr_scode"] + "'";
                    object objResult1 = cnn.ExecuteScalar(SQL);
                    dr["pr_scodenm"] = (objResult1 == DBNull.Value || objResult1 == null ? "" : objResult1.ToString());

                    if (dr.SafeRead("fees", "0") == "0") {
                        dr["rectitle"] = "";
                    } else {
                        if (dr.SafeRead("receipt_type", "") == "E") {
                            dr["rectitle"] = "電子收據(" + dr["receipt_title"] + ")";
                        } else {
                            dr["rectitle"] = "紙本收據";
                        }
                    }
                }
            }

            int fees = 0;//小計規費
            int Pcount = 0;//小計紙本收據件數
            int Ecount = 0;//小計電子收據件數
            int Zcount = 0;//小計無規費件數
            int subcount = 0;//小計併案件數

            int totfees = 0;//總計規費
            int totPcount = 0;//總計紙本收據件數
            int totEcount = 0;//總計電子收據件數
            int totZcount = 0;//總計無規費件數
            int tot_subcount = 0;//總計併案件數

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
            Rpt.ReplaceBookmark("pdate", DateTime.Today.ToShortDateString());

            DataTable dtCL = dt.DefaultView.ToTable(true, new string[] { "branch", "send_cl", "send_clnm" });
            for (int i = 0; i < dtCL.Rows.Count; i++) {
                fees = 0;//小計規費
                Pcount = 0;//小計紙本收據件數
                Ecount = 0;//小計電子收據件數
                Zcount = 0;//小計無規費件數
                subcount = 0;//小計併案件數
                
                Rpt.CopyTable("tbl_cltitle");//發文對象
                Rpt.ReplaceBookmark("send_clnm", dtCL.Rows[i].SafeRead("send_clnm", ""));
                //DataTable dtDtl = dt.Select("branch='" + dtCL.Rows[i].SafeRead("branch", "") + "' and send_cl='" + dtCL.Rows[i].SafeRead("send_cl", "") + "'", "send_cl,main_rs_no,seq,seq1,rs_no,fees desc").CopyToDataTable();
                var rows = dt.Select("branch='" + dtCL.Rows[i].SafeRead("branch", "") + "' and send_cl='" + dtCL.Rows[i].SafeRead("send_cl", "") + "'", "send_cl,main_rs_no,seq,seq1,rs_no,fees desc");
                var dtDtl = rows.Any() ? rows.CopyToDataTable() : dt.Clone();
                for (int d = 0; d < dtDtl.Rows.Count; d++) {
                    Rpt.CopyTable("tbl_detail");//明細行
                    Rpt.ReplaceBookmark("seq", dtDtl.Rows[d].SafeRead("fseq", ""));
                    Rpt.ReplaceBookmark("rs_detail", dtDtl.Rows[d].SafeRead("rs_detail", "").ToUnicode());
                    Rpt.ReplaceBookmark("send_cl", dtDtl.Rows[d].SafeRead("sendmark", ""));
                    Rpt.ReplaceBookmark("step_date", Util.parseDBDate(dtDtl.Rows[d].SafeRead("step_date", ""), "yyyy/M/d"));
                    Rpt.ReplaceBookmark("rs_no", dtDtl.Rows[d].SafeRead("rs_no", ""));
                    Rpt.ReplaceBookmark("step_grade", dtDtl.Rows[d].SafeRead("nstep_grade", ""));
                    Rpt.ReplaceBookmark("apply_no", dtDtl.Rows[d].SafeRead("apply_no", ""));
                    Rpt.ReplaceBookmark("issue_no", dtDtl.Rows[d].SafeRead("issue_no", ""));
                    if (dtDtl.Rows[d].SafeRead("sendmark", "") == "副本") {
                        Rpt.ReplaceBookmark("fees", "");
                    } else {
                        Rpt.ReplaceBookmark("fees", dtDtl.Rows[d].SafeRead("fees", "0"));
                    }
                    Rpt.ReplaceBookmark("appl_name", dtDtl.Rows[d].SafeRead("cappl_name", "").ToUnicode());
                    Rpt.ReplaceBookmark("pr_nm", dtDtl.Rows[d].SafeRead("pr_scodenm", ""));
                    Rpt.ReplaceBookmark("rectitle", dtDtl.Rows[d].SafeRead("rectitle", ""));
                    Rpt.ReplaceBookmark("class", dtDtl.Rows[d].SafeRead("class", ""));

                    fees += Convert.ToInt32(dtDtl.Rows[d].SafeRead("fees", "0"));//小計規費
                    totfees += Convert.ToInt32(dtDtl.Rows[d].SafeRead("fees", ""));//總計規費

                    if (Convert.ToInt32(dtDtl.Rows[d].SafeRead("fees", "0")) == 0) {
                        Zcount += 1;
                        totZcount += 1;
                    } else {
                        if (dtDtl.Rows[d].SafeRead("receipt_type", "") == "E") {
                            Ecount += 1;
                            totEcount += 1;
                        } else {
                            Pcount += 1;
                            totPcount += 1;
                        }
                    }

                    if (dtDtl.Rows[d].SafeRead("rs_no", "") != dtDtl.Rows[d].SafeRead("main_rs_no", "")) {
                        subcount += 1;
                        tot_subcount += 1;
                    }
                }
                Rpt.CopyTable("tbl_subtot");//小計行
                Rpt.ReplaceBookmark("ecnt", Ecount.ToString());
                Rpt.ReplaceBookmark("pcnt", Pcount.ToString());
                Rpt.ReplaceBookmark("zcnt", Zcount.ToString());
                Rpt.ReplaceBookmark("cnt", (Ecount + Pcount + Zcount).ToString());
                Rpt.ReplaceBookmark("sub_fees", fees.ToString());

                if (subcount > 0) {
                    Rpt.ReplaceBookmark("sub_remark", "( " + (Ecount + Pcount + Zcount - subcount) + " 件公文 + " + subcount + " 件併案處理 )");
                } else {
                    Rpt.ReplaceBookmark("sub_remark", "");
                }
            }

            if (dt.Rows.Count > 0) {
                Rpt.CopyTable("tbl_total");//總計行
                Rpt.ReplaceBookmark("tot_ecnt", totEcount.ToString());
                Rpt.ReplaceBookmark("tot_pcnt", totPcount.ToString());
                Rpt.ReplaceBookmark("tot_zcnt", totZcount.ToString());
                Rpt.ReplaceBookmark("tot_cnt", (totEcount + totPcount + totZcount).ToString());
                Rpt.ReplaceBookmark("tot_fees", totfees.ToString());

                if (tot_subcount > 0) {
                    Rpt.ReplaceBookmark("tot_remark", "( " + (totEcount + totPcount + totZcount - tot_subcount) + " 件公文 + " + tot_subcount + " 件併案處理 )");
                } else {
                    Rpt.ReplaceBookmark("tot_remark", "");
                }

                Rpt.AddParagraph();
                Rpt.CopyBlock("b_foot");
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

