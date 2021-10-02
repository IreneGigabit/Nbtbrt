<%@ Page Language="C#" %>

<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Data.Odbc" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq" %>
<%@ Import Namespace="System.Collections.Generic" %>

<script runat="server">
    protected OpenXmlHelper Rpt = new OpenXmlHelper();
    int right = 0;
    string dept = "";
    string pType = "";

    private void Page_Load(System.Object sender, System.EventArgs e)
    {
        Response.CacheControl = "Private";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;
        Response.Clear();

        dept = Sys.GetSession("dept");
        pType = (Request["pType"] ?? "").Trim();
            
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

        string docFileName = string.Format("{0}客戶標籤列印(二).docx", Sys.GetSession("scode"));//輸出的檔名
        string SQL = "";

        using (DBHelper conn = new DBHelper(Conn.btbrt).Debug(true))
        {
            SQL = "select * from cust532 where scode = '" + Sys.GetSession("scode") + "' and ptype = '" + pType + "'";
            SQL += " order by cust_seq";
            Sys.showLog(SQL);
            DataTable dt = new DataTable();
            conn.DataTable(SQL, dt);

            for (int i = 0; i < dt.Rows.Count; i++)
            {
                DataRow dr = dt.Rows[i];
                int pno = i + 1;

                //3筆一列,除3的餘數是1時就加一行
                if (pno % 3 == 1)
                {
                    Rpt.CopyTable("tbl_cust");
                }

                string cust_text = "";
                cust_text += Sys.GetSession("seBranch") + dr.SafeRead("cust_seq", "") + "   ";
                if (dept == "P")
                {
                    if (dr.SafeRead("pscode", "") != "") cust_text += dr.SafeRead("pscode", "");
                }
                else
                {
                    if (dr.SafeRead("tscode", "") != "") cust_text += dr.SafeRead("tscode", "");
                }
                cust_text += "\n";
                cust_text += (dr.SafeRead("zip", "") != "") ? "(" + dr.SafeRead("zip", "") + ")" : "";

                if ((dr.SafeRead("addr1", "") != "") || (dr.SafeRead("addr2", "") != ""))
                {
                    cust_text += dr.SafeRead("addr1", "") + dr.SafeRead("addr2", "");
                }
                cust_text += "\n";
                if ((dr.SafeRead("ap_cname1", "") != "") || (dr.SafeRead("ap_cname2", "") != ""))
                {
                    cust_text += dr.SafeRead("ap_cname1", "") + dr.SafeRead("ap_cname2", "");
                }
                cust_text += "\n";
                //若聯絡人部門存在,則列印 聯絡人部門 + 聯絡人 ; 不存在,則直接列印聯絡人即可
                if (dr.SafeRead("att_dept", "") != "")
                {
                    cust_text += dr.SafeRead("att_dept", "");
                    if (dr.SafeRead("name", "") != "") cust_text += " " + dr.SafeRead("name", "");
                }
                else
                {
                    if (dr.SafeRead("name", "") != "") cust_text += dr.SafeRead("name", "");
                }


                cust_text += " 鈞啟";
                Rpt.ReplaceBookmark("cust_" + (pno % 3), cust_text.ToXmlUnicode());//用除3的餘數算要放在哪一格
            }
            Rpt.ReplaceBookmark("cust_1", "");
            Rpt.ReplaceBookmark("cust_2", "");
            Rpt.ReplaceBookmark("cust_0", "");
        }
        Rpt.CopyPageFoot("csrpt", false);//複製頁尾/邊界
        Rpt.Flush(docFileName);
    }
</script>
