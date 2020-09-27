<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Collections.Generic"%>

<script runat="server">
    protected string HTProgCap = HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "brt11AddA1";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";
    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";
    protected string formFunction = "";
    
    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");
        
        Token myToken = new Token(HTProgCode);
        HTProgRight = myToken.CheckMe();
        HTProgCap = myToken.Title;
        DebugStr = myToken.DebugStr;
        if (HTProgRight >= 0) {
            doUpdateDB();
            this.DataBind();
        }
    }

    private void doUpdateDB() {
        string SQL = "";
        object objResult = null;
        using (DBHelper conn = new DBHelper(Conn.btbrt)) {
            //******************產生流水號(yyyyMMddnnn);
            string nowRSno = DateTime.Today.ToString("yyyyMMdd");
            SQL = "SELECT MAX(in_no) FROM case_dmt WITH(TABLOCKX) WHERE LEFT(in_no, 8) = '" + nowRSno + "'";
            objResult = conn.ExecuteScalar(SQL);
            int nowSql = (objResult == DBNull.Value || objResult == null ? 0 : Convert.ToInt32(((string)objResult).Right(3)));
            string RSno = String.Format("{0}{1:000}", nowRSno, nowSql + 1);

            //寫入case_dmt
            List<DBColumn> colList = new List<DBColumn>();
            //foreach (var key in ReqVal.Keys) {
            //    string colkey = key.ToString().ToLower();
            //    if (colkey.Substring(1, 3) == "fy_") {
            //        if (key.Left(1) == "p") {
            //            colList.Add(new DBColumn(colkey.Substring(4), colkey, ColType.PStr));
            //        }
            //        else if (key.Left(1) == "d") {
            //            colList.Add(new DBColumn(colkey.Substring(4), colkey, ColType.Date));
            //        }
            //        else if (key.Left(1) == "n") {
            //            colList.Add(new DBColumn(colkey.Substring(4), colkey, ColType.Number));
            //        }
            //        else {
            //            if (colkey == "tfy_arcase") {
            //                colList.Add(new DBColumn(colkey.Substring(4), colkey, ColType.Str));
            //            }
            //            else {
            //                colList.Add(new DBColumn(colkey.Substring(4), colkey, ColType.PStr));
            //            }
            //        }
            //    }
            //}

            colList.Add(new DBColumn("case_stat", "tfy_case_stat"));
            colList.Add(new DBColumn("cust_area", "tfy_cust_area"));
            colList.Add(new DBColumn("cust_seq", "tfy_cust_seq"));
            colList.Add(new DBColumn("att_sql", "tfy_att_sql"));
            colList.Add(new DBColumn("Arcase", "tfy_Arcase", ColType.Str));
            colList.Add(new DBColumn("service", "nfy_service", ColType.Number));
            colList.Add(new DBColumn("fees", "nfy_fees", ColType.Number));
            colList.Add(new DBColumn("oth_arcase", "tfy_oth_arcase"));
            colList.Add(new DBColumn("oth_money", "nfy_oth_money", ColType.Number));
            colList.Add(new DBColumn("oth_code", "tfy_oth_code"));
            colList.Add(new DBColumn("Ar_mark", "tfy_Ar_mark"));
            colList.Add(new DBColumn("Discount", "nfy_Discount", ColType.Number));
            colList.Add(new DBColumn("discount_chk", "tfy_discount_chk"));
            colList.Add(new DBColumn("discount_remark", "tfy_discount_remark"));
            colList.Add(new DBColumn("source", "tfy_source"));
            colList.Add(new DBColumn("contract_type", "tfy_contract_type"));
            colList.Add(new DBColumn("Contract_no", "tfy_Contract_no"));
            colList.Add(new DBColumn("contract_flag", "tfy_contract_flag"));
            colList.Add(new DBColumn("contract_remark", "tfy_contract_remark"));
            colList.Add(new DBColumn("ar_chk", "tfy_ar_chk"));
            colList.Add(new DBColumn("cust_date", "dfy_cust_date", ColType.Date));
            colList.Add(new DBColumn("pr_date", "dfy_pr_date", ColType.Date));
            colList.Add(new DBColumn("last_date", "dfy_last_date", ColType.Date));
            colList.Add(new DBColumn("send_way", "tfy_send_way"));
            colList.Add(new DBColumn("receipt_type", "tfy_receipt_type"));
            colList.Add(new DBColumn("receipt_title", "tfy_receipt_title"));
            colList.Add(new DBColumn("rectitle_name", "tfy_rectitle_name"));
            colList.Add(new DBColumn("Remark", "tfy_Remark"));
            colList.Add(new DBColumn("tot_case", "nfy_tot_case", ColType.Number));
            colList.Add(new DBColumn("ar_code", "tfy_ar_code"));
            colList.Add(new DBColumn("in_scode", "F_tscode"));
            colList.Add(new DBColumn("in_no", "'" + RSno + "'", ColType.Value));
            colList.Add(new DBColumn("seq1", "tfz1_seq1", ColType.Str));
            colList.Add(new DBColumn("in_date", "'" + DateTime.Today.ToShortDateString() + "'", ColType.Value));
            colList.Add(new DBColumn("arcase_type", "code_type", ColType.Str));
            colList.Add(new DBColumn("arcase_class", "prt_code", ColType.Str));
            //******折扣請核單
            colList.Add(new DBColumn("discount_chk", "tfy_discount_chk", ColType.Str, "'N'"));
            //******請款單 
            colList.Add(new DBColumn("ar_chk", "tfy_ar_chk", ColType.Str, "'N'"));
            colList.Add(new DBColumn("ar_chk1", "tfy_ar_chk1", ColType.Str, "'N'"));
            //****會計檢核2013/9/16增加，不需請款或大陸進口案不在線上請款，不需會計檢核
            if (Request["tfy_ar_code"] == "X" || Request["tfy_ar_code"] == "M") {
                colList.Add(new DBColumn("acc_chk", "'X'", ColType.Value));
            }
            SQL = Util.GetInsertSQL("case_dmt", colList);
            Response.Write(SQL + "<HR>");
            //conn.ExecuteNonQuery(SQL);

            //*****todo依案性新增內商的案件內容
            string aa = Request["draw_file1"] ?? "";
            string newfilename = "";
            if (aa != "") {
                //2013/11/26修改可以中文檔名上傳及虛擬路徑
                string strpath = "/btbrt/" + Session["seBranch"] + "T/temp";
                string attach_name = RSno + "." + System.IO.Path.GetExtension(aa);//重新命名檔名
                newfilename = strpath + "/" + attach_name;//存在資料庫路徑
            }
            colList = new List<DBColumn>();
            colList.Add(new DBColumn("S_Mark", "tfz1_S_Mark", ColType.Str));
            colList.Add(new DBColumn("seq", "tfz1_seq", ColType.Str));
            colList.Add(new DBColumn("seq1", "tfz1_seq1", ColType.Str));
            colList.Add(new DBColumn("s_mark2", "tfz1_s_mark2", ColType.Str));
            colList.Add(new DBColumn("cust_prod", "tfz1_cust_prod", ColType.Str));
            colList.Add(new DBColumn("agt_no", "tfz1_agt_no", ColType.Str));
            colList.Add(new DBColumn("prior_date", "pfz1_prior_date", ColType.PStr));
            colList.Add(new DBColumn("prior_country", "tfz1_prior_country", ColType.Str));
            colList.Add(new DBColumn("prior_no", "tfz1_prior_no", ColType.Str));
            colList.Add(new DBColumn("good_name", "tfz1_good_name", ColType.Str));
            colList.Add(new DBColumn("RCode", "ttz1_RCode", ColType.Str));
            colList.Add(new DBColumn("remark2", "tfz1_remark2", ColType.Str));
            colList.Add(new DBColumn("Appl_name", "tfz1_Appl_name", ColType.Str));
            colList.Add(new DBColumn("color", "tfz1_color", ColType.Str));
            colList.Add(new DBColumn("Oappl_name", "tfz1_Oappl_name", ColType.Str));
            colList.Add(new DBColumn("Cappl_name", "tfz1_Cappl_name", ColType.Str));
            colList.Add(new DBColumn("Eappl_name", "tfz1_Eappl_name", ColType.Str));
            colList.Add(new DBColumn("Zname_type", "tfz1_Zname_type", ColType.Str));
            colList.Add(new DBColumn("Eappl_name1", "tfz1_Eappl_name1", ColType.Str));
            colList.Add(new DBColumn("Eappl_name2", "tfz1_Eappl_name2", ColType.Str));
            colList.Add(new DBColumn("Draw", "tfz1_Draw", ColType.Str));
            colList.Add(new DBColumn("Symbol", "tfz1_Symbol", ColType.Str));
            colList.Add(new DBColumn("Remark4", "tfz1_Remark4", ColType.Str));
            colList.Add(new DBColumn("remark3", "tfz1_remark3", ColType.Str));
            colList.Add(new DBColumn("pul", "tfz1_pul", ColType.Str));
            colList.Add(new DBColumn("class_type", "tfz1_class_type", ColType.Str));
            colList.Add(new DBColumn("class_count", "tfz1_class_count", ColType.Str));
            colList.Add(new DBColumn("class", "tfz1_class", ColType.Str));
            colList.Add(new DBColumn("in_scode", "F_tscode", ColType.Str));
            colList.Add(new DBColumn("in_no", "'" + RSno + "'", ColType.Value));
            colList.Add(new DBColumn("in_date", "'" + DateTime.Today.ToShortDateString() + "'", ColType.Value));
            colList.Add(new DBColumn("draw_file", "'" + newfilename + "'", ColType.Value));
            colList.Add(new DBColumn("tr_date", "'" + DateTime.Today.ToShortDateString() + "'", ColType.Value));
            colList.Add(new DBColumn("tr_scode", "'" + Session["scode"] + "'", ColType.Value));
            SQL = Util.GetInsertSQL("dmt_temp", colList);
            Response.Write(SQL + "<HR>");
            //conn.ExecuteNonQuery(SQL);

            //****主委辦案性	
            colList = new List<DBColumn>();
            colList.Add(new DBColumn("in_scode", "F_tscode", ColType.Str));
            colList.Add(new DBColumn("in_no", "'" + RSno + "'", ColType.Value));
            colList.Add(new DBColumn("item_sql", "'0'", ColType.Value));
            colList.Add(new DBColumn("seq1", "tfz1_seq1", ColType.Str));
            colList.Add(new DBColumn("item_arcase", "tfy_arcase", ColType.Str));
            colList.Add(new DBColumn("item_service", "nfyi_service", ColType.Str));
            colList.Add(new DBColumn("item_fees", "nfyi_fees", ColType.Str));
            colList.Add(new DBColumn("item_count", "'1'", ColType.Value));
            SQL = Util.GetInsertSQL("caseitem_dmt", colList);
            Response.Write(SQL + "<HR>");
            //conn.ExecuteNonQuery(SQL);

            //****次委辦案性
            for (int i = 1; i <= Convert.ToInt32("0" + Request["TaCount"]); i++) {
                if ((Request["nfyi_item_Arcase_" + i] ?? "") != "") {
                    colList = new List<DBColumn>();
                    colList.Add(new DBColumn("in_scode", "F_tscode", ColType.Str));
                    colList.Add(new DBColumn("in_no", "'" + RSno + "'", ColType.Value));
                    colList.Add(new DBColumn("item_sql", "'" + i + "'", ColType.Value));
                    colList.Add(new DBColumn("seq1", "tfz1_seq1", ColType.Str));
                    colList.Add(new DBColumn("item_arcase", "nfyi_item_Arcase_" + i, ColType.Str));
                    colList.Add(new DBColumn("item_service", "nfyi_Service_" + i, ColType.Str));
                    colList.Add(new DBColumn("item_fees", "nfyi_fees_" + i, ColType.Str));
                    colList.Add(new DBColumn("item_count", "nfyi_item_count_" + i, ColType.Str));
                    SQL = Util.GetInsertSQL("caseitem_dmt", colList);
                    Response.Write(SQL + "<HR>");
                }
            }


            //conn.Commit();
        }
        //Response.Write("<script>alert('F_ap_crep');<"+"/script>");
    }
</script>
