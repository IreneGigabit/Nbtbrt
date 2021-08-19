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
    protected string ar_no, branch, dept, ar_type, ar_mark;
        
    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "Private";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;
        Response.Clear();

        right=Convert.ToInt32(Request["right"] ?? "0");
        se_scode = (Request["se_scode"] ?? "").Trim();

        ar_no = (Request["ar_no"] ?? "").Trim().ToLower();
        branch = (Request["branch"] ?? "").Trim().ToUpper();
        dept = (Request["dept"] ?? "").Trim().ToUpper();
        ar_type = (Request["ar_type"] ?? "").Trim().ToUpper();
        ar_mark = (Request["ar_mark"] ?? "").Trim().ToUpper();
        
        try {
            WordOut();
        }
        finally {
            if (Rpt != null) Rpt.Dispose();
        }
    }

    protected void WordOut() {
        Dictionary<string, string> _tplFile = new Dictionary<string, string>();
        if (ar_mark == "I") {
            _tplFile.Add("invoice", Server.MapPath("~/ReportTemplate/報表/英文Invoice_智產.docx"));
        } else {
            _tplFile.Add("invoice", Server.MapPath("~/ReportTemplate/報表/英文Invoice_聖國.docx"));
        }
        Rpt.CloneFromFile(_tplFile, true);

        string docFileName = string.Format("{0}-Invoice.docx", se_scode);

        string SQL = "";
        using (DBHelper conn = new DBHelper(Session["account"].ToString()).Debug(false)) {
            SQL = "Select * from artmain_e a " +
            "inner join artitem_e e on a.ar_no=e.ar_no and a.branch=e.branch " +
            "where a.ar_no=" + ar_no + " and a.branch='" + branch + "' order by e.case_no ";
            DataTable dt = new DataTable();
            conn.DataTable(SQL, dt);

            if (dt.Rows.Count > 0) {
                //表頭
                Rpt.CopyBlock("b_title");
                System.Threading.Thread.CurrentThread.CurrentCulture = new System.Globalization.CultureInfo("en-US");
                Rpt.ReplaceBookmark("in_date", dt.Rows[0].SafeRead("in_date", DateTime.MinValue).ToString("MMMM dd, yyyy", System.Threading.Thread.CurrentThread.CurrentCulture));
                Rpt.ReplaceBookmark("ar_no", dt.Rows[0].SafeRead("branch", "") + dept + "-" + ar_no);
                Rpt.ReplaceBookmark("ar_etitle", dt.Rows[0].SafeRead("ar_etitle", ""));
                Rpt.ReplaceBookmark("ar_eaddr", dt.Rows[0].SafeRead("ar_eaddr", ""));

                //明細
                for (int i = 0; i < dt.Rows.Count; i++) {
                    Rpt.CopyBlock("b_item");
                    //英文案性
                    Rpt.ReplaceBookmark("e_arcase", dt.Rows[i].SafeRead("e_arcase", ""));
                    //本所編號
                    string strSeq = "";
                    if (ar_type == "T") {
                        strSeq = dt.Rows[i].SafeRead("branch", "") + "T-" + dt.Rows[i].SafeRead("seq", "") + "-" + dt.Rows[i].SafeRead("seq1", "");
                    } else {
                        strSeq = dt.Rows[i].SafeRead("branch", "") + "TE-" + dt.Rows[i].SafeRead("seq", "") + "-" + dt.Rows[i].SafeRead("seq1", "");
                    }
                    if (dt.Rows[i].SafeRead("country", "").Trim() != "T")
                        strSeq += dt.Rows[i].SafeRead("country", "");
                    strSeq = strSeq.Replace("-_", "");
                    Rpt.ReplaceBookmark("seq", strSeq);
                    //金額
                    if (dt.Rows[i].SafeRead("item_show", "") != "T") {
                        //外幣
                        Rpt.ReplaceBookmark("i_curr", dt.Rows[0].SafeRead("ar_currency", ""));
                        Rpt.ReplaceBookmark("i_amt", String.Format("{0:#,0.00}", dt.Rows[i].SafeRead("foreign_amt", 0.0)));
                    } else {
                        //台幣
                        Rpt.ReplaceBookmark("i_curr", "NT$");
                        if (dt.Rows[0].SafeRead("amt_tax", "") != "INC") {
                            Rpt.ReplaceBookmark("i_amt", String.Format("{0:#,0.00}", dt.Rows[i].SafeRead("tax_out_amt", 0.0)));//未稅
                        } else {
                            Rpt.ReplaceBookmark("i_amt", String.Format("{0:#,0.00}", dt.Rows[i].SafeRead("tax_inc_amt", 0.0)));//含稅
                        }
                    }
                }
                
                //合計
                //台幣
                if (dt.Rows[0].SafeRead("total_show", "").IndexOf("T")>-1) {
                    Rpt.CopyTable(1);
                    Rpt.ReplaceBookmark("t_title", "Total:");
                    Rpt.ReplaceBookmark("t_curr", "NT$");
                    if (dt.Rows[0].SafeRead("amt_tax", "") != "INC") {
                        Rpt.ReplaceBookmark("t_amt", String.Format("{0:#,0.00}", dt.Rows[0].SafeRead("tax_out_sum", 0.0)));//未稅
                    } else {
                        Rpt.ReplaceBookmark("t_amt", String.Format("{0:#,0.00}", dt.Rows[0].SafeRead("tax_inc_sum", 0.0)));//含稅
                    }
                }

                //外幣
                if (dt.Rows[0].SafeRead("total_show", "").IndexOf("F")>-1) {
                    
                    Rpt.CopyTable(1);
                    if (dt.Rows[0].SafeRead("total_show", "") == "F")//只選外幣顯示"Total:"
                        Rpt.ReplaceBookmark("t_title", "Total:");
                    else
                        Rpt.ReplaceBookmark("t_title", "");//勾台幣+外幣(為第2行所以不顯示"Total:")
                    Rpt.ReplaceBookmark("t_curr", dt.Rows[0].SafeRead("ar_currency", ""));
                    Rpt.ReplaceBookmark("t_amt", String.Format("{0:#,0.00}", dt.Rows[0].SafeRead("foreign_sum", 0.0)));
                }
                Rpt.CopyTable(2);//加總線
                Rpt.AddParagraph().AddParagraph();

                //匯率
                //惠生要求如果單項/總計都選只顯示外幣的話就不用show匯率
                //20190617惠生要求如果單項/總計都選只顯示台幣的話就不用show匯率
                if (!((dt.Rows[0].SafeRead("item_show", "") == "F" && dt.Rows[0].SafeRead("total_show", "") == "F")
                    || (dt.Rows[0].SafeRead("item_show", "") == "T" && dt.Rows[0].SafeRead("total_show", "") == "T"))) {
                    Rpt.CopyBlock("b_rate");
                    Rpt.ReplaceBookmark("foreign", dt.Rows[0].SafeRead("ar_currency", ""));
                    Rpt.ReplaceBookmark("rate", dt.Rows[0].SafeRead("ar_rate", ""));
                }
            }
        }
        
        Rpt.CopyPageHeader("invoice");//複製頁首
        Rpt.CopyPageFoot("invoice");//複製頁尾/邊界
        if ((Request["type"] ?? "").ToLower() != "pdf") {
            Rpt.Flush(docFileName);
        } else {
            string docxPath = Server.MapPath(@"~/ReportData/" + DateTime.Today.ToString("yyyy/MM") + "/" + docFileName);
            string pdfFile = docFileName.Replace(".docx", ".pdf");
            string pdfPath = Server.MapPath(@"~/ReportData/" + DateTime.Today.ToString("yyyy/MM") + "/" + pdfFile);
            Rpt.SaveTo(docxPath);

            OpenXmlHelper.ConvertToPDF(docxPath, pdfPath);

            Response.Clear();
            Response.HeaderEncoding = System.Text.Encoding.GetEncoding("big5");
            Response.AddHeader("Content-Disposition", "attachment; filename=\"" + pdfFile + "\"");
            Response.ContentType = "application/octet-stream";
            Response.WriteFile(pdfPath);
            Response.End();
        }
    }
</script>
