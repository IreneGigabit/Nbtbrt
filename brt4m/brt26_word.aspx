<%@ Page Language="C#" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Data.Odbc" %>
<%@ Import Namespace = "System.IO"%>
<%@ Import Namespace = "System.Linq"%>
<%@ Import Namespace = "System.Collections.Generic"%>

<script runat="server">
    protected OpenXmlHelper Rpt = new OpenXmlHelper();
    protected StringBuilder strOut = new StringBuilder();
    
    protected int right = 0;
    protected string tblname = "";
    protected string dept;
    protected string coun;
    protected string code;
    protected string branch;
    protected string ar_flag;

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

        dept = (Request["dept"] ?? "").Trim();
        coun = (Request["coun"] ?? "").Trim();
        code = (Request["code"] ?? "").Trim();
        branch = (Request["branch"] ?? "").Trim();
        ar_flag = (Request["ar_flag"] ?? "").Trim();

        conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
        cnn = new DBHelper(Conn.Sysctrl).Debug(Request["chkTest"] == "TEST");

        try {
            WordOut();
        }
        finally {
            if (Rpt != null) Rpt.Dispose();
        }
    }

    protected void WordOut() {
        Dictionary<string, string> _tplFile = new Dictionary<string, string>();
        if (ar_flag == "N") {
            _tplFile.Add("rpt", Server.MapPath("~/ReportTemplate/報表/收費查詢明細表_未稅.docx"));
        } else {
            _tplFile.Add("rpt", Server.MapPath("~/ReportTemplate/報表/收費查詢明細表.docx"));
        }
        Rpt.CloneFromFile(_tplFile, true);

        string ar_txt = "";
        if (branch == "E") {
            if (ar_flag == "N")
                ar_txt = "_未稅";
            else
                ar_txt = "_已稅";
        }

        //m1583出口案性收費標準_已稅
        string docFileName = string.Format("{0}{1}案性收費標準{2}.docx"
            , Sys.GetSession("scode")
            , (branch == "E" ? "出口" : "國內")
            , ar_txt
            );

        if (coun == "T") {
            tblname = "tbfee_v";
        } else {
            tblname = "tebfee_v";
        }

        string SQL = "";
        object objResult = null;
        SQL = "select *,''coun_c,''tend_date,0 oth_ser,0 oth_fee,0 total,0 tax ";
        SQL += "from " + tblname;
        SQL += " where dept = '" + dept + "' ";
        SQL += "and country in('" + coun.Replace(",", "','") + "') ";
        SQL += "and class in('" + code.Replace(",", "','") + "') ";
        SQL += "and end_date >= '" + DateTime.Today.ToShortDateString() + "' ";
        SQL += "order by country,class";
        DataTable dt = new DataTable();
        conn.DataTable(SQL, dt);

        if (dt.Rows.Count > 0) {
            //表頭
            Rpt.CopyTable("tbl_title");
            string head_tax = "";
            if (branch == "E") {
                if (ar_flag == "N")
                    head_tax = "\n(未稅)";
                else
                    head_tax = "\n(含稅)";
            }
            Rpt.ReplaceBookmark("head_s", "服務費" + head_tax);
            Rpt.ReplaceBookmark("head_f", "規費" + head_tax);
            Rpt.ReplaceBookmark("head_t", "合計" + (branch == "E" ? "\n(含稅)" : ""));

            //明細
            for (int i = 0; i < dt.Rows.Count; i++) {
                DataRow dr = dt.Rows[i];

                if (dr.GetDateTimeString("end_date", "yyyy/MM/dd") != "2099/12/31") {
                    dr["tend_date"] = "~" + dr.GetDateTimeString("end_date", "yyyy/MM/dd");
                }

                SQL = "select coun_c from country where coun_code = '" + dr["country"] + "' and markb<>'X'";
                objResult = cnn.ExecuteScalar(SQL);
                dr["coun_c"] = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();

                if (dr.SafeRead("country", "") == "T") {
                    if (dr.SafeRead("oth_code", "") != "") {
                        SQL = "select service,fees from case_fee ";
                        SQL += "where country = 'T' and dept = '" + dr["dept"] + "' ";
                        SQL += " and rs_code = '" + dr["oth_code"] + "' ";
                        SQL += " and beg_date='" + dr.GetDateTimeString("beg_date", "yyyy/MM/dd") + "' ";
                        SQL += "and end_date='" + dr.GetDateTimeString("end_date", "yyyy/MM/dd") + "'";
                        using (SqlDataReader dr0 = conn.ExecuteReader(SQL)) {
                            if (dr0.Read()) {
                                dr["oth_ser"] = dr0["service"];
                                dr["oth_fee"] = dr0["fees"];
                            }
                        }
                    }

                    dr["total"] = dr.SafeRead("service", 0) + dr.SafeRead("fees", 0) + dr.SafeRead("others", 0) + dr.SafeRead("oth_ser", 0) + dr.SafeRead("oth_fee", 0);
                } else {
                    dr["total"] = dr.SafeRead("ar_service", 0) + dr.SafeRead("ar_fees", 0) + dr.SafeRead("ar_others", 0);//含稅合計
                    dr["tax"] = dr.SafeRead("total", 0) - dr.SafeRead("service", 0) - dr.SafeRead("fees", 0) - dr.SafeRead("others", 0);//稅
                    if (ar_flag != "N") {//含稅
                        dr["service"] = dr["ar_service"];
                        dr["fees"] = dr["ar_fees"];
                        dr["others"] = dr["ar_others"];
                    }
                }

                Rpt.CopyTable("tbl_detail");
                Rpt.ReplaceBookmark("coun_c", dr.SafeRead("coun_c", ""));
                Rpt.ReplaceBookmark("case_name", dr.SafeRead("case_name", ""));
                Rpt.ReplaceBookmark("service", dr.SafeRead("service", "0"));
                Rpt.ReplaceBookmark("fees", (dr.SafeRead("fees", 0) + dr.SafeRead("others", 0)).ToString());
                Rpt.ReplaceBookmark("tax", dr.SafeRead("tax", "0"));
                Rpt.ReplaceBookmark("total", "NT$" + dr.SafeRead("total", 0).ToString("N0"));

                //國內案的附屬案性
                if (dr.SafeRead("country", "") == "T" && dr.SafeRead("class", "") != "Z1") {
                    DataTable dtChild = new DataTable();
                    SQL = "select *,''coun_c,''tend_date,0 oth_ser,0 oth_fee,0 total,0 tax ";
                    SQL += "from " + tblname;
                    SQL += " where dept = '" + dept + "' and country = 'T' and class='Z1' ";
                    SQL += " and arcase like '" + dr["arcase"] + "%' ";
                    SQL += "and end_date >= '" + DateTime.Today.ToShortDateString() + "' ";
                    SQL += "order by arcase";
                    conn.DataTable(SQL, dtChild);

                    for (int j = 0; j < dtChild.Rows.Count; j++) {
                        DataRow drz = dtChild.Rows[j];

                        if (drz.GetDateTimeString("end_date", "yyyy/MM/dd") != "2099/12/31") {
                            drz["tend_date"] = "~" + drz.GetDateTimeString("end_date", "yyyy/MM/dd");
                        }

                        SQL = "select coun_c from country  where coun_code = '" + drz["country"] + "' and markb<>'X'";
                        objResult = cnn.ExecuteScalar(SQL);
                        drz["coun_c"] = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();

                        if (drz.SafeRead("oth_code", "") != "") {
                            SQL = "select service,fees from case_fee ";
                            SQL += "where country = 'T' and dept = '" + drz["dept"] + "' ";
                            SQL += " and rs_code = '" + drz["oth_code"] + "' ";
                            SQL += " and beg_date='" + drz.GetDateTimeString("beg_date", "yyyy/MM/dd") + "' ";
                            SQL += "and end_date='" + drz.GetDateTimeString("end_date", "yyyy/MM/dd") + "'";
                            using (SqlDataReader dr0 = conn.ExecuteReader(SQL)) {
                                if (dr0.Read()) {
                                    drz["oth_ser"] = dr0["service"];
                                    drz["oth_fee"] = dr0["fees"];
                                }
                            }
                        }

                        drz["total"] = drz.SafeRead("service", 0) + drz.SafeRead("fees", 0) + drz.SafeRead("others", 0) + drz.SafeRead("oth_ser", 0) + drz.SafeRead("oth_fee", 0);

                        Rpt.CopyTable("tbl_detail");
                        Rpt.ReplaceBookmark("coun_c", drz.SafeRead("coun_c", ""));
                        Rpt.ReplaceBookmark("case_name", drz.SafeRead("case_name", ""));
                        Rpt.ReplaceBookmark("service", drz.SafeRead("service", "0"));
                        Rpt.ReplaceBookmark("fees", (drz.SafeRead("fees", 0) + drz.SafeRead("others", 0)).ToString());
                        Rpt.ReplaceBookmark("total", "NT$" + drz.SafeRead("total", 0).ToString("N0"));
                    }
                }
            }

            Rpt.CopyPageHeader("rpt");//複製頁首後再填入資料
            Rpt.ReplaceBookmark("title", (dept == "T" ? "商標" : "專利") + "收費查詢明細表");

            Rpt.CopyPageFoot("rpt");//複製頁尾/邊界
            Rpt.ReplaceBookmark("company", (branch == "E" ? "聖島智產股份有限公司" : "聖島國際專利商標聯合事務所"));
            
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
