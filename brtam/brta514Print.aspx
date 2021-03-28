<%@ Page Language="C#" %>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Data.SqlClient" %>
<%@ Import Namespace = "System.IO"%>
<%@ Import Namespace = "System.Linq"%>
<%@ Import Namespace = "System.Collections.Generic"%>

<script runat="server">
    protected OpenXmlHelper Rpt = new OpenXmlHelper();
    protected StringBuilder strOut = new StringBuilder();

    protected string dept="";
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
            strOut.AppendLine("    alert(\"發文回條 Word 產生失敗!!!\");");
            strOut.AppendLine("<" + "/script>");
            Response.Write(strOut.ToString());
            Response.Write(ex.Message);
        }
        finally {
            if (Rpt != null) Rpt.Dispose();
        }
    }

    protected void WordOut() {
        Dictionary<string, string> _tplFile = new Dictionary<string, string>();
        _tplFile.Add("gsrpt", Server.MapPath("~/ReportTemplate/報表/官方發文回條.docx"));
        Rpt.CloneFromFile(_tplFile, true);

        string docFileName = Session["scode"] + "發文回條.docx";
        if (send_way == "E" || send_way == "EA") {
            docFileName = string.Format("GS{0}-514T-{1:yyyyMMdd}.docx", send_way, DateTime.Today);
        }

        string SQL = "";
        using (DBHelper conn = new DBHelper(Conn.btbrt).Debug(false)) {
            SQL = "select dmt_scode,cappl_name,apply_no,issue_no,rej_no,class,class_count,term1,term2 ";
            SQL += ",(case dmt_draw when '1' then '及圖' when '2' then '圖' end) as drawnm ";
            SQL += ",rs_no,main_rs_no,tot_num,class_count,branch,seq,seq1,step_grade,step_date,mp_date,send_selnm,send_clnm,send_cl1nm,rs_class,rs_detail,fees,pr_scode,send_way ";
            SQL += ",a.send_sel,(select mark1 from cust_code where code_type='SEND_SEL' and cust_code=a.send_sel) as send_selfel ";//發文性質的欄位名稱
            SQL += ",a.receipt_type,a.receipt_title,a.rectitle_name ";
            SQL += ",(select branchname from sysctrl.dbo.branch_code where branch=a.branch) as branchnm";
            SQL += " from vstep_dmt a where cg='G' and rs='S' and rs_no = main_rs_no ";
            SQL += " and left(rs_no,1)='G' ";//2006/5/27配合爭救案系統不列印爭救案發文資料,爭救案發文字號第一碼為B
            SQL += " and isnull(receipt_type,'')<>'E' ";//20170605 因應電子收據上線，不顯示電子收據資料

            if ((Request["sdate"] ?? "") != "") SQL += " and step_date>='" + Request["sdate"] + "'";
            if ((Request["edate"] ?? "") != "") SQL += " and step_date<='" + Request["edate"] + "'";
            if ((Request["srs_no"] ?? "") != "") SQL += " and rs_no>='" + Request["srs_no"] + "'";
            if ((Request["ers_no"] ?? "") != "") SQL += " and rs_no<='" + Request["ers_no"] + "'";
            if ((Request["sseq"] ?? "") != "") SQL += " and seq>=" + Request["sseq"];
            if ((Request["eseq"] ?? "") != "") SQL += " and seq<=" + Request["eseq"];
            if ((Request["dmt_scode"] ?? "") != "") SQL += " and dmt_scode='" + Request["dmt_scode"] + "'";
            if ((Request["scust_seq"] ?? "") != "") SQL += " and cust_seq>=" + Request["scust_seq"];
            if ((Request["ecust_seq"] ?? "") != "") SQL += " and cust_seq<=" + Request["ecust_seq"];
            if ((Request["qrysend_dept"] ?? "") != "") SQL += " and opt_Branch='" + Request["qrysend_dept"] + "'";
            if ((Request["send_way"] ?? "") != "") {
                if ((Request["send_way"] ?? "") == "E" || (Request["send_way"] ?? "") == "EA") {
                    SQL += " and send_way='" + Request["send_way"] + "'";
                } else {
                    SQL += "  and isnull(send_way,'') not in('E','EA') ";
                }
            }
            DataTable dt = new DataTable();
            conn.DataTable(SQL, dt);

            for (int i = 0; i < dt.Rows.Count; i++) {
                DataRow dr = dt.Rows[i];

                int runTime = 1;
                //副本有選擇要多一印份給副本收文者
                if (dr.SafeRead("send_cl1nm", "") != "") runTime = 2;

                for (int r = 1; r <= runTime; r++) {
                    Rpt.CopyTable("b_table");

                    //總管處發文日期
                    DateTime mp_date;
                    string mpDate = DateTime.TryParse(dr.SafeRead("mp_date", ""), out mp_date) ? mp_date.ToShortDateString() : "";
                    Rpt.ReplaceBookmark("mp_date", mpDate);

                    //發文序號
                    string step_date = dr.GetDateTimeString("step_date", "yyyy");
                    string strrs_no = string.Format("發文({0})聖{1}　{2}　字第　{3}　號"
                                        , step_date != "" ? (Convert.ToInt32(step_date) - 1911).ToString() : ""
                                        , (dr.SafeRead("branchnm", "").Substring(1, 1)) + (dept.ToUpper() == "T" ? "商" : "") + (dept.ToUpper() == "P" ? "專" : "")
                                        , dr.SafeRead("pr_scode", "")
                                        , dr.SafeRead("rs_no", "").Substring(3)
                                        );
                    Rpt.ReplaceBookmark("strrs_no", strrs_no);

                    //受文者，發文單位
                    if (r == 2) {
                        Rpt.ReplaceBookmark("send_clnm", "副本\n" + dr.SafeRead("send_cl1nm", ""));
                    } else {
                        Rpt.ReplaceBookmark("send_clnm", dr.SafeRead("send_clnm", ""));
                    }

                    //簡由，發文性質+案件名稱+發文內容
                    string send_detail = "";
                    string send_sel = dr.SafeRead("send_sel", "").Trim();
                    string str1 = "";
                    //一案多件的號數顯示在下方明細.不在這裡顯示
                    if (Convert.ToInt32(dr.SafeRead("tot_num", "0")) == 1) {
                        if (send_sel != "") {
                            switch (send_sel) {
                                case "1":
                                    if (dr.SafeRead("apply_no", "").Trim() != "")
                                        str1 = "申請號 第　" + dr.SafeRead("apply_no", "").Trim() + "　號";
                                    break;
                                case "2":
                                    if (dr.SafeRead("issue_no", "").Trim() != "")
                                        str1 = "審定號 第　" + dr.SafeRead("issue_no", "").Trim() + "　號";
                                    break;
                                case "3":
                                    if (dr.SafeRead("rej_no", "").Trim() != "")
                                        str1 = "核駁號 第　" + dr.SafeRead("rej_no", "").Trim() + "　號";
                                    break;
                                case "4":
                                    if (dr.SafeRead("issue_no", "").Trim() != "")
                                        str1 = "註冊號 第　" + dr.SafeRead("issue_no", "").Trim() + "　號";
                                    break;
                            }
                        }
                    }
                    if (send_detail != "" && str1 != "") send_detail += "\n";
                    send_detail += str1;

                    string str2 = dr.SafeRead("cappl_name", "").Trim();
                    if (send_detail != "" && str2 != "") send_detail += "\n";
                    send_detail += str2;

                    string str3 = dr.SafeRead("rs_detail", "").Trim();
                    if (send_detail != "" && str3 != "") send_detail += "\n";
                    send_detail += str3;

                    string str4 = "";
                    if (dr.SafeRead("rs_class", "").Trim() == "A4") {
                        str4 = "專用期限:" + dr.GetDateTimeString("term1", "yyyy/M/d") + " ~ " + dr.GetDateTimeString("term2", "yyyy/M/d");
                    }
                    if (send_detail != "" && str4 != "") send_detail += "\n";
                    send_detail += str4;

                    string str5 = "";
                    if (dr.SafeRead("rs_class", "").Trim() == "A0"
                        || dr.SafeRead("rs_class", "").Trim() == "A1"
                        || dr.SafeRead("rs_class", "").Trim() == "A4"
                        ) {
                        str5 = "共:" + dr.SafeRead("class_count", "") + "類(" + dr.SafeRead("class", "") + ")";
                    }
                    if (send_detail != "" && str5 != "") send_detail += "\n";
                    send_detail += str5;

                    string str6 = "";
                    if (dr.SafeRead("send_way", "").Trim() == "E") {
                        str6 = "※電子送件";
                    } else if (dr.SafeRead("send_way", "").Trim() == "EA") {
                        str6 = "※註冊費電子送件";
                    }
                    if (send_detail != "" && str6 != "") send_detail += "\n";
                    send_detail += str6;

                    //20180621 增加收據抬頭,若是空白則不顯示
                    //有指定抬頭才要顯示
                    string receipt_title = dr.SafeRead("receipt_title", "");
                    string rectitle_name = "";
                    if (receipt_title == "A" || receipt_title == "C") {
                        if (receipt_title == "A") {
                            rectitle_name = dr.SafeRead("rectitle_name", "");
                        } else if (receipt_title == "C") {//專利權人(代繳人)
                            if (dr.SafeRead("rectitle_name", "").IndexOf("(代繳人：聖島國際專利商標聯合事務所)") > -1) {
                                rectitle_name = dr.SafeRead("rectitle_name", "");
                            } else {
                                rectitle_name = dr.SafeRead("rectitle_name", "") + "(代繳人：聖島國際專利商標聯合事務所)";
                            }
                        }

                        send_detail += "\n收據抬頭：" + rectitle_name;
                    }

                    //件數(正本才顯示)
                    if (Convert.ToInt32(dr.SafeRead("tot_num", "0")) > 1 && r == 1) {
                        send_detail += "共" + dr.SafeRead("tot_num", "0") + "件";
                    }
                    Rpt.ReplaceBookmark("send_detail", send_detail.ToUnicode());

                    //本所編號
                    string seq = Sys.formatSeq1(dr.SafeRead("seq", ""), dr.SafeRead("seq1", ""), "", dr.SafeRead("Branch", ""), Sys.GetSession("dept"));
                    Rpt.ReplaceBookmark("seq", seq);

                    //最後期限，法定期限(本次官發銷管的管制日期)，2013/5/13增加延展A4及寬延展A41
                    string ctrl_date = "";
                    SQL = "select ctrl_date from resp_dmt where branch='" + dr.SafeRead("Branch", "") + "' and seq=" + dr.SafeRead("seq", "");
                    SQL += " and seq1='" + dr.SafeRead("seq1", "") + "' and resp_grade=" + dr.SafeRead("step_grade", "") + " and (ctrl_type='A1' or ctrl_type like 'A4%')";
                    using (SqlDataReader dr1 = conn.ExecuteReader(SQL)) {
                        while (dr1.Read()) {
                            ctrl_date += "\n" + dr1.GetDateTimeString("ctrl_date", "yyyy/M/d");
                        }
                    }
                    ctrl_date = (ctrl_date != "" ? ctrl_date.Substring(1) : "");

                    //最後期限
                    Rpt.ReplaceBookmark("ctrl_date", ctrl_date);

                    //規費
                    if (r == 2)
                        Rpt.ReplaceBookmark("fees", "0 元");
                    else
                        Rpt.ReplaceBookmark("fees", dr["fees"] + " 元");

                    //一案多件明細
                    if (Convert.ToInt32(dr.SafeRead("tot_num", "0")) > 1 && r == 1) {
                        string str7 = "";
                        string sub_nonm="";
                        SQL = "select seq,seq1,apply_no,issue_no,rej_no from vstep_dmt where main_rs_no='" + dr.SafeRead("main_rs_no", "") + "'";
                        using (SqlDataReader dr1 = conn.ExecuteReader(SQL)) {
                            while (dr1.Read()) {
                                str7 += "，" + Sys.formatSeq1(dr1.SafeRead("seq", ""), dr1.SafeRead("seq1", ""), "", dr.SafeRead("Branch", ""), Sys.GetSession("dept"));
                                
                                if (dr.SafeRead("send_sel", "") != "") {
                                    switch (dr.SafeRead("send_sel", "")) {
                                        case "1":
                                            sub_nonm="申請號";
                                            if (dr.SafeRead("apply_no", "").Trim() != "")
                                                str7 += "(" + dr1.SafeRead("apply_no", "").Trim() + ")";
                                            break;
                                        case "2":
                                            sub_nonm="審定號";
                                            if (dr.SafeRead("issue_no", "").Trim() != "")
                                                str7 += "(" + dr1.SafeRead("issue_no", "").Trim() + ")";
                                            break;
                                        case "3":
                                            sub_nonm="核駁號";
                                            if (dr.SafeRead("rej_no", "").Trim() != "")
                                                str7 += "(" + dr1.SafeRead("rej_no", "").Trim() + ")";
                                            break;
                                        case "4":
                                            sub_nonm="註冊號";
                                            if (dr.SafeRead("issue_no", "").Trim() != "")
                                                str7 += "(" + dr1.SafeRead("issue_no", "").Trim() + ")";
                                            break;
                                    }
                                }
                            }
                        }
                        
                        Rpt.CopyTable("b_sub");
                        if (r == 1 && dr.SafeRead("send_clnm", "") != "") Rpt.ReplaceBookmark("subtxt", "案件明細");
                        if (r == 2 && dr.SafeRead("send_cl1nm", "") != "") Rpt.ReplaceBookmark("subtxt", "案件明細 (副本)");
                        Rpt.ReplaceBookmark("sub_nonm", sub_nonm);
                        Rpt.ReplaceBookmark("strrs_no1", strrs_no);
                        Rpt.ReplaceBookmark("strseq", str7 != "" ? str7.Substring(1) : "");
                    }

                    //表尾
                    Rpt.CopyTable("b_foot");
                }
            }

            if (dt.Rows.Count > 0) {
                Rpt.CopyPageFoot("gsrpt", false);//複製頁尾/邊界
                if (send_way == "E" || send_way == "EA") {//電子送件才要保留副本
                    Rpt.SaveAndFlush(Server.MapPath("~/ReportWord/" + DateTime.Today.ToString("yyyyMM") + "/" + docFileName), docFileName);
                } else {
                    Rpt.Flush(docFileName);
                }
            } else {
                strOut.AppendLine("<script language=\"javascript\">");
                strOut.AppendLine("    alert(\"無資料需產生\");");
                strOut.AppendLine("<" + "/script>");
                Response.Write(strOut.ToString());
            }
        }
    }
</script>

