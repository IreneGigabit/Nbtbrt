<%@ Page Language="C#" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Data.Odbc" %>
<%@ Import Namespace = "System.IO"%>
<%@ Import Namespace = "System.Linq"%>
<%@ Import Namespace = "System.Collections.Generic"%>

<script runat="server">
    protected OpenXmlHelper Rpt = new OpenXmlHelper();
    int right=0;
    string dept = "";
    string att_type, mag, depttype;
    string cust_seqs, cust_seqe, scode, level;
        
    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "Private";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;
        Response.Clear();

        //right=Convert.ToInt32(Request["right"] ?? "0");
        //se_scode = (Request["se_scode"] ?? "").Trim();
        //qcust_area = (Request["qcust_area"] ?? "").Trim();
        //qecase_date = (Request["qecase_date"] ?? "").Trim();
        //qseq = (Request["qseq"] ?? "").Trim();
        att_type = (Request["att_type"] ?? "").Trim();
        mag = (Request["magtype"] ?? "").Trim();
        depttype = (Request["depttype"] ?? "").Trim();
        cust_seqs = (Request["cust_seqs"] ?? "").Trim();
        cust_seqe = (Request["cust_seqe"] ?? "").Trim();
        scode = (Request["scode"] ?? "").Trim();
        level = (Request["level"] ?? "").Trim();
        dept = Sys.GetSession("dept");
       
        try
        {
            WordOut();
        }
        finally
        {
            if (Rpt != null) Rpt.Dispose();
        }
    }

    protected void WordOut()
    {
        Dictionary<string, string> _tplFile = new Dictionary<string, string>();
        _tplFile.Add("csrpt", Server.MapPath("~/ReportTemplate/報表/客戶標籤列印(一).docx"));//樣板
        Rpt.CloneFromFile(_tplFile, true);

        string docFileName = string.Format("{0}客戶標籤列印(一).docx", Sys.GetSession("scode"));//輸出的檔名

        string SQL = "";
        string wSQL = "";
        
        //指定聯絡人,當指定聯絡人有值時,會以指定聯絡人為基準,而忽略郵寄雜誌條件
        if (att_type != "")
	    {
            if (att_type == "F")//第一順位
            {
                wSQL += " and c.att_sql = ( ";
                wSQL += " select Min(d.att_sql) ";
            }
            if (att_type == "L")//最後順位
            {
                wSQL += " and c.att_sql = ( ";
                wSQL += " select Max(d.att_sql) ";
            }
            
            wSQL += " from custz_att d ";
            wSQL += " where d.cust_area = a.cust_area ";
            wSQL += " and d.cust_seq = a.cust_seq ";
            wSQL += " and d.att_code in ('NN','NU') ";
            wSQL += " and d.dept = '" + dept + "')";
	    }
        else
        {//郵寄雜誌
            if (mag == "Y") wSQL += " and c.att_mag = 'Y' ";
            if (mag == "N") wSQL += " and c.att_mag = 'N' ";
        }

        switch (depttype)
        {
            case "1"://只辦商標or專利客戶
                if (dept == "P")
	            {
                    wSQL += " and (a.dmp_date is not null or a.exp_date is not null) and a.dmt_date is null and a.ext_date is null ";
	            }
                else
                {
                    wSQL += " and (a.dmt_date is not null or a.ext_date is not null) and a.dmp_date is null and a.exp_date is null ";
                }
                break;

            case "2"://商標or專利所有客戶
                if (dept == "P")
                {
                    wSQL += " and (a.dmp_date is not null or a.exp_date is not null) ";
                }
                else
                {
                    wSQL += " and (a.dmt_date is not null or a.ext_date is not null) ";
                }
                break;

            case "3": //商標/專利共同客戶
                wSQL += " and (a.dmt_date is not null or a.ext_date is not null) and (a.dmp_date is not null or a.exp_date is not null) ";
                break;
                
            default:
                break;
        }

        if (cust_seqs != "")
        {
            wSQL += " and a.cust_seq >= " + cust_seqs ;
        }
        if (cust_seqe != "")
        {
            wSQL += " and a.cust_seq <= " + cust_seqe;
        }

        if (scode != "")
        {
            wSQL += " and a." + dept.ToLower() +"scode = '" + scode + "' ";
        }

        if (level != "")
        {
            string lv = "";
            string[] s = level.Split(',');
            for (int i = 0; i < s.Length; i++)
            {
                lv += "'" + s[i] + "',";
            }
            wSQL += " and a." + dept.ToLower() +"level IN (" + lv.TrimEnd(',') + ")";
        }


        using (DBHelper conn = new DBHelper(Conn.btbrt).Debug(true)) {
            SQL = "select a.cust_area,a.cust_seq,b.ap_cname1,b.ap_cname2,c.att_zip,c.att_addr1,c.att_addr2,c.att_dept,c.attention,c.att_sql,c.ttran_date,c.att_company,c.ptran_date,a.pscode,a.tscode ";
	        SQL += " from custz a , apcust b, custz_att c ";
            SQL += " where a.cust_area = b.cust_area ";
            SQL += " and a.cust_seq = b.cust_seq";
            SQL += " and a.cust_area = c.cust_area";
            SQL += " and a.cust_seq = c.cust_seq";
            SQL += " and c.dept = '" + dept + "'";
            SQL += " and c.att_code in ('NN','NU') ";
            SQL += wSQL;
            SQL += " order by a.cust_area, a.cust_seq";
            Sys.showLog(SQL);
            DataTable dt = new DataTable();
            conn.DataTable(SQL, dt);

            for (int i = 0; i < dt.Rows.Count; i++)
            {
                DataRow dr = dt.Rows[i];
                int pno = i + 1;

                //3筆一列,除3的餘數是1時就加一行
                if (pno % 3 == 1) {
                    Rpt.CopyTable("tbl_cust");
                }

                string cust_text = "";
                cust_text += dr.SafeRead("cust_area", "") + dr.SafeRead("cust_seq", "") + "   ";
                if (dept == "P")
                {
                    if (dr.SafeRead("pscode", "") != "") cust_text += dr.SafeRead("pscode", "");
                }
                else
                {
                    if (dr.SafeRead("tscode", "") != "") cust_text += dr.SafeRead("tscode", "");
                }
                cust_text += "\n";
                cust_text +=  (dr.SafeRead("att_zip", "") != "") ? "("+dr.SafeRead("att_zip", "")+")" :"";

                if ((dr.SafeRead("att_addr1", "") != "") || (dr.SafeRead("att_addr2", "") != ""))
                {
                    cust_text += dr.SafeRead("att_addr1", "") + dr.SafeRead("att_addr2", "");
                }
                cust_text += "\n";
                //若聯絡人公司名稱存在,則以聯絡人公司為準(表聯絡人與客戶名稱為不同公司),反之,則以客戶名稱為基準
                if (dr.SafeRead("att_company", "") != "")
                {
                    cust_text += dr.SafeRead("att_company", "");
                }
                else
                {
                    if ((dr.SafeRead("ap_cname1", "") != "") || (dr.SafeRead("ap_cname2", "") != ""))
                    {
                        cust_text += dr.SafeRead("ap_cname1", "") + dr.SafeRead("ap_cname2", "");
                    }
                }
                cust_text += "\n";
                //若聯絡人部門存在,則列印 聯絡人部門 + 聯絡人 ; 不存在,則直接列印聯絡人即可
                if (dr.SafeRead("att_dept", "") != "")
                {
                    cust_text += dr.SafeRead("att_dept", "");
                    if (dr.SafeRead("attention", "") != "") cust_text += " " + dr.SafeRead("attention", "");
                }
                else
                {
                    if (dr.SafeRead("attention", "") != "") cust_text += dr.SafeRead("attention", "");
                }
                
                
                cust_text += " 鈞啟";
                Rpt.ReplaceBookmark("cust_" + (pno % 3), cust_text.ToXmlUnicode());//用除3的餘數算要放在哪一格
            }
            Rpt.ReplaceBookmark("cust_1","");
            Rpt.ReplaceBookmark("cust_2","");
            Rpt.ReplaceBookmark("cust_0","");
        }
        Rpt.CopyPageFoot("csrpt", false);//複製頁尾/邊界
        Rpt.Flush(docFileName);
    }
</script>
