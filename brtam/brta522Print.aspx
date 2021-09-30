<%@ Page Language="C#" %>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Data.SqlClient" %>
<%@ Import Namespace = "System.IO"%>
<%@ Import Namespace = "System.Linq"%>
<%@ Import Namespace = "System.Collections.Generic"%>

<script runat="server">
    protected OpenXmlHelper Rpt = new OpenXmlHelper();
    protected StringBuilder strOut = new StringBuilder();

    protected List<string> updRsNo = new List<string>();

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "Private";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;
        Response.Clear();

        try {
            WordOut();
        }
        catch(Exception ex) {
            strOut.AppendLine("<script language=\"javascript\">");
            strOut.AppendLine("    alert(\"客戶函 產生失敗!!!\");");
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
        _tplFile.Add("csrpt", Server.MapPath("~/ReportTemplate/報表/客戶函.docx"));
        Rpt.CloneFromFile(_tplFile, true);

        string docFileName = string.Format("{0}custreport.docx", Session["scode"]);

        string SQL = "";
        using (DBHelper conn = new DBHelper(Conn.btbrt).Debug(false)) {
            SQL = "select rs_no,branch,seq,seq1,step_date,rs_type,rs_class,rs_code,act_code,rs_detail,last_date,scode,sc_name";
            SQL += ",cappl_name,ap_cname1,att_zip,att_addr1,att_addr2,s_mark,pul,class,class_count,arcase";
            SQL += ",dmt_draw,apply_date,apply_no,issue_date,issue_no,open_date,rej_no,case_name,attention,att_company,att_fax";
            SQL += ",cust_prod";
            SQL += " from vcs_dmt_1 a where branch='" + Session["seBranch"] + "'";
            if ((Request["sdate"] ?? "") != "") SQL += " and step_date>='" + Request["sdate"] + "'";
            if ((Request["edate"] ?? "") != "") SQL += " and step_date<='" + Request["edate"] + "'";
            if ((Request["srs_no"] ?? "") != "") SQL += " and rs_no>='" + Request["srs_no"] + "'";
            if ((Request["ers_no"] ?? "") != "") SQL += " and rs_no<='" + Request["ers_no"] + "'";
            if ((Request["sseq"] ?? "") != "") SQL += " and seq>=" + Request["sseq"];
            if ((Request["eseq"] ?? "") != "") SQL += " and seq<=" + Request["eseq"];
            if ((Request["seq1"] ?? "") != "") SQL += " and seq1='" + Request["seq1"] + "'";
            if ((Request["in_scode"] ?? "") != "") SQL += " and scode='" + Request["in_scode"] + "'";
            if ((Request["scust_seq"] ?? "") != "") SQL += " and cust_seq>=" + Request["scust_seq"];
            if ((Request["ecust_seq"] ?? "") != "") SQL += " and cust_seq<=" + Request["ecust_seq"];
            if ((Request["tfx_print"] ?? "") != "") {
                if ((Request["tfx_print"] ?? "") == "Y") SQL += " and print_date is not null";
                if ((Request["tfx_print"] ?? "") == "N") SQL += " and print_date is null";
            }
            if ((Request["sprint_date"] ?? "") != "") SQL += " and print_date>='" + Request["sprint_date"] + " 0:0:0'";
            if ((Request["eprint_date"] ?? "") != "") SQL += " and print_date<='" + Request["eprint_date"] + " 23:59:59'";
            SQL += " order by branch,rs_no,seq,seq1";
            DataTable dt = new DataTable();
            conn.DataTable(SQL, dt);

            for (int i = 0; i < dt.Rows.Count; i++) {
                DataRow dr = dt.Rows[i];

                Rpt.CopyTable("b_table");

                //寄送地址
                if (dr.SafeRead("att_addr1", "") != "") {
                    Rpt.ReplaceBookmark("att_addr", dr.SafeRead("att_zip", "").Trim() + "\n" + dr.SafeRead("att_addr1", "").Trim().ToUnicode() + dr.SafeRead("att_addr2", "").Trim().ToUnicode());
                } else {
                    Rpt.ReplaceBookmark("att_addr", "");
                }

                //客戶名稱&聯絡人
                if (dr.SafeRead("att_company", "") != "") {
                    Rpt.ReplaceBookmark("att_company", dr.SafeRead("att_company", "").Trim().ToUnicode());
                    Rpt.ReplaceBookmark("attention", dr.SafeRead("attention", "").Trim().ToUnicode());
                } else {
                    Rpt.ReplaceBookmark("att_company", dr.SafeRead("ap_cname1", "").Trim().ToUnicode());
                    if (dr.SafeRead("attention", "") != "" && dr.SafeRead("ap_cname1", "").Trim() != dr.SafeRead("attention", "").Trim()) {
                        Rpt.ReplaceBookmark("attention", dr.SafeRead("attention", "").Trim().ToUnicode());
                    } else {
                        Rpt.ReplaceBookmark("attention", "");
                    }
                }

                //法定期限
                Rpt.ReplaceBookmark("last_date", dr.GetDateTimeString("last_date", "yyyy/M/d"));

                //通知日期(進度日期)
                Rpt.ReplaceBookmark("step_date", dr.GetDateTimeString("step_date", "yyyy/M/d"));

                //國別種類
                Rpt.ReplaceBookmark("coun_c", "中華民國");
                switch (dr.SafeRead("seq1", "")) {
                    case "_": Rpt.ReplaceBookmark("seq1nm", "商標"); break;
                    case "C": Rpt.ReplaceBookmark("seq1nm", "著作權"); break;
                    default: Rpt.ReplaceBookmark("seq1nm", ""); break;
                }

                //案性
                switch (dr.SafeRead("s_mark", "")) {
                    case "S": Rpt.ReplaceBookmark("case_name", "服務標章"); break;
                    case "L": Rpt.ReplaceBookmark("case_name", "證明標章"); break;
                    case "M": Rpt.ReplaceBookmark("case_name", "團體標章"); break;
                    case "N": Rpt.ReplaceBookmark("case_name", "團體商標"); break;
                    default: Rpt.ReplaceBookmark("case_name", "商標"); break;
                }

                //本所編號
                string fseq = Sys.formatSeq1(dr.SafeRead("seq", ""), dr.SafeRead("seq1", ""), "", dr.SafeRead("Branch", ""), Sys.GetSession("dept"));
                Rpt.ReplaceBookmark("fseq", fseq);

                //類別
                Rpt.ReplaceBookmark("class", "共" + dr.SafeRead("class_count", "") + "類 " + dr.SafeRead("class", ""));

                //案件名稱
                Rpt.ReplaceBookmark("cappl_name", dr.SafeRead("cappl_name", "").Trim().ToUnicode());

                //20170824增加客戶卷號
                Rpt.ReplaceBookmark("cust_prod", dr.SafeRead("cust_prod", "").Trim());

                //申請日
                Rpt.ReplaceBookmark("apply_date", dr.GetDateTimeString("apply_date", "yyyy/M/d"));

                //申請案號
                Rpt.ReplaceBookmark("apply_no", dr.SafeRead("apply_no", "").Trim());

                //商標註冊號數
                Rpt.ReplaceBookmark("issue_no", dr.SafeRead("issue_no", "").Trim());

                //核准/核駁審定號數
                Rpt.ReplaceBookmark("rej_no", dr.SafeRead("rej_no", "").Trim());

                //通知事項
                Rpt.ReplaceBookmark("rs_detail", dr.SafeRead("rs_detail", "").Trim(), true);
                SQL = "select a.send_code,b.send_detail from vcode_act a,code_send b where a.dept='" + Session["dept"] + "'";
                SQL += " and cg='C' and rs='S' and cs='Y' and rs_type = '" + dr["rs_type"] + "' and rs_class='" + dr["rs_class"] + "'";
                SQL += " and rs_code='" + dr["rs_code"] + "' and act_code='" + dr["act_code"] + "'";
                SQL += " and a.dept=b.dept and a.send_code=b.send_code";
                using (SqlDataReader dr1 = conn.ExecuteReader(SQL)) {
                    if (dr1.Read()) {
                        Rpt.ReplaceBookmark("send_detail", dr1.SafeRead("send_detail", "").Trim().ToUnicode());
                    } else {
                        Rpt.ReplaceBookmark("send_detail", "");
                    }
                }

                //聯絡人傳真
                Rpt.ReplaceBookmark("att_fax", dr.SafeRead("att_fax", "").Trim());

                //營洽
                string sc_name = "";
                sc_name += Sys.getCodeName(conn, "sysctrl.dbo.branch_code", "branchname", "where branch='" + Session["seBranch"] + "'");
                if (Sys.GetSession("dept") == "T") sc_name += "商標部";
                if (Sys.GetSession("dept") == "P") sc_name += "專利部";
                if (dr.SafeRead("sc_name", "") != "") {
                    sc_name += "　"+dr.SafeRead("sc_name", "");
                }
                Rpt.ReplaceBookmark("sc_name", sc_name.ToUnicode());

                //表尾
                Rpt.CopyTable("b_foot");

                //2009/1/8配合客函寄出作業紀錄列印日期
                if (Request["prtkind"] == "522") {
                    updRsNo.Add(dr.SafeRead("rs_no", ""));//要更新列印狀態的rs_no
                }
            }

            if (dt.Rows.Count > 0) {
                Rpt.CopyPageFoot("csrpt", false);//複製頁尾/邊界
                Rpt.Flush(docFileName);

                //更新為已列印
                if (updRsNo.Count > 0) {
                    if (Request["tfx_print"] == "N") {
                        SQL = "update cs_dmt set print_date=getdate() where rs_no in('" + string.Join("','", updRsNo.ToArray()) + "')";
                        conn.ExecuteNonQuery(SQL);
                        conn.Commit();
                        //conn.RollBack();
                    }
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

