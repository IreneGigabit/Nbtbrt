<%@ Page Language="C#" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Data.Odbc" %>
<%@ Import Namespace = "System.IO"%>
<%@ Import Namespace = "System.Linq"%>
<%@ Import Namespace = "System.Collections.Generic"%>

<script runat="server">
    protected OpenXmlHelper Rpt = new OpenXmlHelper();
    protected int right = 0;
    protected string se_scode;
    protected string cgrs;
    protected List<string> updRsNo = new List<string>();
        
    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "Private";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;
        Response.Clear();

        right=Convert.ToInt32(Request["right"] ?? "0");
        se_scode = Sys.GetSession("scode");

        cgrs = (Request["cgrs"] ?? "").Trim().ToUpper();
        
        try {
            WordOut();
        }
        finally {
            if (Rpt != null) Rpt.Dispose();
        }
    }

    protected void WordOut() {
        Dictionary<string, string> _tplFile = new Dictionary<string, string>();
        _tplFile.Add("rpt", Server.MapPath("~/ReportTemplate/報表/承辦單.docx"));
        Rpt.CloneFromFile(_tplFile, true);

        string docFileName = string.Format("{0}-承辦單.docx", se_scode);

        string SQL = "";
        using (DBHelper conn = new DBHelper(Conn.btbrt).Debug(false)) {
            SQL = "select a.*,(select sc_name from sysctrl.dbo.scode where scode=a.dmt_scode) as sc_name,";
            SQL += "(select sc_name from sysctrl.dbo.scode where scode=a.pr_scode) as pr_name,";
            SQL += "attention,att_company,att_zip,att_addr1,att_addr2,att_fax,att_tel0,att_tel,att_tel1,";
            SQL += "(select send_way from cs_dmt where rs_no=a.cs_rs_no) as send_way,";
            SQL += "(select attach_name from dmt_attach where seq=a.seq and seq1=a.seq1 and step_grade=a.step_grade and source='scan' and attach_flag<>'D') as barcode_name ";
            SQL += " from vstep_dmt a where cg='" + cgrs.Left(1) + "' and rs='" + cgrs.Right(1) + "'";
            if ((Request["sdate"] ?? "") != "") SQL += " and step_date>='" + Request["sdate"] + "'";
            if ((Request["edate"] ?? "") != "") SQL += " and step_date<='" + Request["edate"] + "'";
            if ((Request["srs_no"] ?? "").Trim() != "") SQL += " and rs_no>='" + Request["srs_no"].Trim() + "'";
            if ((Request["ers_no"] ?? "").Trim() != "") SQL += " and rs_no<='" + Request["ers_no"].Trim() + "'";
            if ((Request["sseq"] ?? "") != "") SQL += " and seq>='" + Request["sseq"] + "'";
            if ((Request["eseq"] ?? "") != "") SQL += " and seq<='" + Request["eseq"] + "'";
            if ((Request["seq1"] ?? "") != "") SQL += " and seq1='" + Request["seq1"] + "'";
            if ((Request["hprint"] ?? "") == "N") SQL += " and isnull(new,'N')='" + Request["hprint"] + "'";
            if ((Request["hscan"] ?? "") != "*" && (Request["hscan"] ?? "") != "") SQL += " and pr_scan='" + Request["hscan"] + "'";
            SQL += " order by rs_no";

            DataTable dt = new DataTable();
            conn.DataTable(SQL, dt);

            if (dt.Rows.Count > 0) {
                //明細
                for (int i = 0; i < dt.Rows.Count; i++) {
                    updRsNo.Add(dt.Rows[i].SafeRead("rs_no", ""));//要更新列印狀態的rs_no

                    Rpt.CopyBlock("b_main");

                    //進度序號
                    Rpt.ReplaceBookmark("step_grade", dt.Rows[i].SafeRead("step_grade", ""));
                    //條碼
                    string tbarcode = "", tseq1 = "";
                    if (dt.Rows[i].SafeRead("seq1", "") != "_") tseq1 = dt.Rows[i].SafeRead("seq1", "");
                    if (dt.Rows[i].SafeRead("barcode_name", "") != "") {
                        string barcode_name = dt.Rows[i].SafeRead("barcode_name", "");
                        tbarcode = "*SIIPLO-" + Path.GetFileNameWithoutExtension(barcode_name) + "*";
                    } else {
                        if (dt.Rows[i].SafeRead("pr_scan", "") == "Y") {
                            tbarcode = "*SIIPLO-" + dt.Rows[i]["branch"] + Sys.GetSession("dept").ToUpper() + "-" + dt.Rows[i].SafeRead("seq", "").PadLeft(Sys.DmtSeq, '0') + "-" + tseq1 + "-" + dt.Rows[i].SafeRead("step_grade", "").PadLeft(4, '0') + "*";
                        }
                    }
                    Rpt.ReplaceBookmark("barcode", tbarcode);
                    //發文日期
                    Rpt.ReplaceBookmark("step_date", dt.Rows[i].GetDateTimeString("step_date", "yyyy/M/d"));
                    //本所編號
                    Rpt.ReplaceBookmark("fseq", Sys.formatSeq(dt.Rows[i].SafeRead("seq", ""), dt.Rows[i].SafeRead("seq1", ""), "", dt.Rows[i].SafeRead("branch", ""), Sys.GetSession("dept")));
                    //客戶編號
                    if (dt.Rows[i].SafeRead("cust_seq", "") != "") {
                        Rpt.ReplaceBookmark("cust_seq", "(" + dt.Rows[i].SafeRead("cust_area", "") + dt.Rows[i].SafeRead("cust_seq", "") + ")", "");
                    } else {
                        Rpt.ReplaceBookmark("cust_seq", "");
                    }
                    //申請號
                    Rpt.ReplaceBookmark("apply_no", dt.Rows[i].SafeRead("apply_no", ""));
                    //號數
                    if (dt.Rows[i].SafeRead("issue_no", "") != "") {//註冊號
                        Rpt.ReplaceBookmark("no_type", "註冊號");
                        Rpt.ReplaceBookmark("c_no", dt.Rows[i].SafeRead("issue_no", ""));
                    } else {
                        if (dt.Rows[i].SafeRead("rej_no", "") != "") {//核駁號
                            Rpt.ReplaceBookmark("no_type", "核駁號");
                            Rpt.ReplaceBookmark("c_no", dt.Rows[i].SafeRead("rej_no", ""));
                        } else {
                            Rpt.ReplaceBookmark("no_type", "註冊號");
                            Rpt.ReplaceBookmark("c_no", "");

                        }
                    }

                    //主旨:案件名稱 & 類別，收文內容
                    string subject = "";
                    subject = dt.Rows[i].SafeRead("cappl_name", "").ToUnicode();
                    if (dt.Rows[i].SafeRead("rs_class", "") == "A1") {
                        if (dt.Rows[i].SafeRead("class_count", "") != "") subject += "共" + dt.Rows[i].SafeRead("class_count", "") + "類";
                        if (dt.Rows[i].SafeRead("class", "") != "") subject += dt.Rows[i].SafeRead("class", "");
                    }
                    subject += "\n" + dt.Rows[i].SafeRead("rs_detail", "").ToUnicode();
                    Rpt.ReplaceBookmark("subject", subject);

                    //收文字號
                    if (dt.Rows[i].SafeRead("rs_no", "") != "") {
                        Rpt.ReplaceBookmark("rs_no", "聖 " + dt.Rows[i].SafeRead("dmt_scode", "") + " 字第 " + dt.Rows[i].SafeRead("rs_no", "") + " 號 ", "");
                    } else {
                        Rpt.ReplaceBookmark("rs_no", "");
                    }

                    //來文字號
                    Rpt.ReplaceBookmark("receive_no", dt.Rows[i].SafeRead("receive_no", ""), "");

                    //受文者
                    string contact = "";
                    if (dt.Rows[i].SafeRead("att_company", "") != "") {
                        contact += dt.Rows[i].SafeRead("att_company", "").ToUnicode().Trim() + "\n";
                    } else {
                        if (dt.Rows[i].SafeRead("ap_cname1", "") != "") {
                            contact += (dt.Rows[i].SafeRead("ap_cname1", "") + dt.Rows[i].SafeRead("ap_cname2", "")).ToUnicode().Trim() + "\n";
                        }
                    }
                    if (dt.Rows[i].SafeRead("att_addr1", "") != "") {
                        contact += dt.Rows[i].SafeRead("att_zip", "") + dt.Rows[i].SafeRead("att_addr1", "").ToUnicode() + dt.Rows[i].SafeRead("att_addr2", "").ToUnicode() + "\n";
                    }
                    if (dt.Rows[i].SafeRead("attention", "") != "") {
                        contact += "連絡人：" + dt.Rows[i].SafeRead("attention", "").ToUnicode();
                    }
                    contact += "　TEL:";
                    if (dt.Rows[i].SafeRead("att_tel0", "") != "") contact += "(" + dt.Rows[i].SafeRead("att_tel0", "") + ")";
                    contact += dt.Rows[i].SafeRead("att_tel", "");
                    if (dt.Rows[i].SafeRead("att_tel1", "") != "") contact += "-" + dt.Rows[i].SafeRead("att_tel1", "");
                    if (dt.Rows[i].SafeRead("att_fax", "") != "") contact += "　FAX:" + dt.Rows[i].SafeRead("att_fax", "");
                    Rpt.ReplaceBookmark("contact", contact);

                    //發文字號
                    if (dt.Rows[i].SafeRead("cs_rs_no", "") != "") {
                        Rpt.ReplaceBookmark("cs_rs_no", "聖 " + dt.Rows[i].SafeRead("dmt_scode", "") + " 字第 " + dt.Rows[i].SafeRead("cs_rs_no", "") + " 號 ", "");
                    } else {
                        Rpt.ReplaceBookmark("cs_rs_no", "");
                    }

                    //發文方式
                    SQL = "select cust_code,code_name from cust_code where code_type='SEND_WAY'";
                    DataTable swDt = new DataTable();
                    conn.DataTable(SQL, swDt);

                    //交辦內容
                    //承辦有輸交辦內容
                    SQL = "select pr_detail,pr_mark,end_flag,end_date,send_way,fax_no,send_mark";
                    SQL += " from br_dmt a where rs_no='" + dt.Rows[i].SafeRead("rs_no", "") + "'";
                    DataTable brDt = new DataTable();
                    conn.DataTable(SQL, brDt);
                    if (brDt.Rows.Count > 0) {
                        string pr_mark = brDt.Rows[0].SafeRead("pr_mark", "");
                        if (pr_mark.Substring(0, 1) == "Y") Rpt.ReplaceBookmark("pr_mark1", "☑"); else Rpt.ReplaceBookmark("pr_mark1", "☐");
                        if (pr_mark.Substring(1, 1) == "Y") Rpt.ReplaceBookmark("pr_mark2", "☑"); else Rpt.ReplaceBookmark("pr_mark2", "☐");
                        if (pr_mark.Substring(2, 1) == "Y") Rpt.ReplaceBookmark("pr_mark3", "☑"); else Rpt.ReplaceBookmark("pr_mark3", "☐");
                        if (pr_mark.Substring(3, 1) == "Y") Rpt.ReplaceBookmark("pr_mark4", "☑"); else Rpt.ReplaceBookmark("pr_mark4", "☐");
                        //結案狀態
                        if (brDt.Rows[0].SafeRead("end_flag", "") == "Y") {
                            Rpt.ReplaceBookmark("end_mark1", "☑");
                            Rpt.ReplaceBookmark("end_mark2", "☐");
                            Rpt.ReplaceBookmark("end_date", brDt.Rows[0].SafeRead("end_date", ""));
                        } else {
                            Rpt.ReplaceBookmark("end_mark1", "☐");
                            Rpt.ReplaceBookmark("end_mark2", "☑");
                        }
                        //交辦內容
                        Rpt.ReplaceBookmark("pr_detail", brDt.Rows[0].SafeRead("pr_detail", ""));
                        //寄發方式
                        string send_way = "", send_waynm = "";
                        send_way = brDt.Rows[0].SafeRead("send_way", "");
                        for (int k = 0; k < swDt.Rows.Count; k++) {
                            if (send_way.IndexOf(swDt.Rows[k].SafeRead("cust_code", "")) > -1) {
                                send_waynm += "(V)" + swDt.Rows[k]["code_name"] + " ";
                                if (swDt.Rows[k].SafeRead("cust_code", "") == "6") {//FAX
                                    send_waynm += brDt.Rows[0].SafeRead("fax_no", "");
                                }
                                if (swDt.Rows[k].SafeRead("cust_code", "") == "8") {//其他
                                    send_waynm += brDt.Rows[0].SafeRead("send_mark", "");
                                }

                            } else {
                                send_waynm += "(　)" + swDt.Rows[k]["code_name"] + " ";
                            }
                        }
                        Rpt.ReplaceBookmark("send_waynm", send_waynm);
                    } else {
                        Rpt.ReplaceBookmark("pr_mark1", "☐");
                        Rpt.ReplaceBookmark("pr_mark2", "☐");
                        Rpt.ReplaceBookmark("pr_mark3", "☐");
                        Rpt.ReplaceBookmark("pr_mark4", "☐");
                        Rpt.ReplaceBookmark("end_date", "");
                        Rpt.ReplaceBookmark("end_mark1", "☐");
                        Rpt.ReplaceBookmark("end_mark2", "☑");
                        Rpt.ReplaceBookmark("pr_detail", "");
                        //寄發方式
                        string send_way = "", send_waynm = "";
                        send_way = dt.Rows[i].SafeRead("send_way", "");
                        for (int k = 0; k < swDt.Rows.Count; k++) {
                            if (send_way == swDt.Rows[k].SafeRead("cust_code", "")) {
                                send_waynm += "(V)" + swDt.Rows[k]["code_name"] + " ";
                            } else {
                                send_waynm += "(　)" + swDt.Rows[k]["code_name"] + " ";
                            }
                        }
                        Rpt.ReplaceBookmark("send_waynm", send_waynm);
                    }
                    //營洽
                    Rpt.ReplaceBookmark("dmt_scode", dt.Rows[i].SafeRead("dmt_scode", "") + "\n" + dt.Rows[i].SafeRead("sc_name", ""));
                    //承辦
                    Rpt.ReplaceBookmark("pr_scode", dt.Rows[i].SafeRead("pr_scode", "") + "\n" + dt.Rows[i].SafeRead("pr_name", ""));

                    //進度管制
                    SQL = "select * from ctrl_dmt where rs_no='" + dt.Rows[i]["rs_no"] + "' and branch='" + dt.Rows[i]["branch"] + "' ";
                    SQL += "and seq='" + dt.Rows[i]["seq"] + "' and seq1='" + dt.Rows[i]["seq1"] + "' order by ctrl_date";
                    DataTable ctlDt = new DataTable();
                    conn.DataTable(SQL, ctlDt);
                    string Actrl_dateN = "", Bctrl_dateN = "";//本次進度序號
                    string Actrl_date = "", Bctrl_date = "";//非本次進度序號需加()
                    for (int k = 0; k < ctlDt.Rows.Count; k++) {
                        string ctrl_type = ctlDt.Rows[k].SafeRead("ctrl_type", "");
                        string ctrl_date = ctlDt.Rows[k].GetDateTimeString("ctrl_date", "yyyy/M/d");
                        if (ctrl_type.Left(1) == "A") {//法定期限、客戶期限
                            if (dt.Rows[i].SafeRead("step_grade", "") == ctlDt.Rows[k].SafeRead("step_grade", "")) {
                                Actrl_dateN += ctrl_date.PadRight(12, ' ') + "　";
                            } else {
                                Actrl_date += ("(" + ctrl_date + ")").PadRight(12, ' ') + "　";
                            }
                        } else if (ctrl_type.Left(1) == "B") {//自管期限、承辦期限
                            if (dt.Rows[i].SafeRead("step_grade", "") == ctlDt.Rows[k].SafeRead("step_grade", "")) {
                                if (ctrl_type == "B2") {
                                    Bctrl_dateN += (ctrl_date + "[承辦]").PadRight(16, ' ') + " ";
                                } else {
                                    Bctrl_dateN += (ctrl_date + "[自管]").PadRight(16, ' ') + " ";
                                }
                            } else {
                                if (ctrl_type == "B2") {
                                    Bctrl_date += ("(" + ctrl_date + "[承辦])").PadRight(16, ' ') + " ";
                                } else {
                                    Bctrl_date += ("(" + ctrl_date + "[自管])").PadRight(16, ' ') + " ";
                                }
                            }
                        }
                    }
                    Rpt.ReplaceBookmark("Bctrl_date", Bctrl_dateN + Bctrl_date);
                    Rpt.ReplaceBookmark("Actrl_date", Actrl_dateN + Actrl_date);

                    if (i != dt.Rows.Count - 1) {//不是最後一筆要加分頁符號
                        Rpt.NewPage();
                    }
                }

            }

            Rpt.CopyPageFoot("rpt");//複製頁尾/邊界
            Rpt.Flush(docFileName);

            //更新為已列印
            if (updRsNo.Count > 0) {
                SQL = "update step_dmt set new='Y' where rs_no in('" + string.Join("','", updRsNo.ToArray()) + "')";
                conn.ExecuteNonQuery(SQL);
                conn.Commit();
            }
        }
    }
</script>
