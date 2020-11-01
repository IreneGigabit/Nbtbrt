<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Collections.Generic"%>

<script runat="server">
    protected string HTProgCap = HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "brt11";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";
    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";
    protected string formFunction = "";
    
    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected StringBuilder strOut = new StringBuilder();

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");
        
        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        HTProgCap = myToken.Title;
        DebugStr = myToken.DebugStr;
        if (HTProgRight >= 0) {
            doUpdateDB();
            this.DataBind();
        }
    }

    private void doUpdateDB() {
        Sys sfile = new Sys();
        sfile.getFileServer(Sys.GetSession("SeBranch"), Request["prgid"]);//檔案上傳相關設定

        string SQL = "";
        object objResult = null;
        using (DBHelper conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST")) {
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
            SQL = "insert into case_dmt";
            colList.Add(new DBColumn("case_stat", "tfy_case_stat", true));
            colList.Add(new DBColumn("cust_area", "tfy_cust_area", true));
            colList.Add(new DBColumn("cust_seq", "tfy_cust_seq", true));
            colList.Add(new DBColumn("att_sql", "tfy_att_sql", true));
            colList.Add(new DBColumn("Arcase", "tfy_Arcase", ColType.Str, true));
            colList.Add(new DBColumn("service", "nfy_service", ColType.Zero, true));
            colList.Add(new DBColumn("fees", "nfy_fees", ColType.Zero, true));
            colList.Add(new DBColumn("oth_arcase", "tfy_oth_arcase", true));
            colList.Add(new DBColumn("oth_money", "nfy_oth_money", ColType.Zero, true));
            colList.Add(new DBColumn("oth_code", "tfy_oth_code", true));
            colList.Add(new DBColumn("Ar_mark", "tfy_Ar_mark", true));
            colList.Add(new DBColumn("Discount", "nfy_Discount", ColType.Zero, true));
            colList.Add(new DBColumn("discount_chk", "tfy_discount_chk", true));
            colList.Add(new DBColumn("discount_remark", "tfy_discount_remark", true));
            colList.Add(new DBColumn("source", "tfy_source", true));
            colList.Add(new DBColumn("contract_type", "tfy_contract_type", true));
            colList.Add(new DBColumn("Contract_no", "tfy_Contract_no", true));
            colList.Add(new DBColumn("contract_flag", "tfy_contract_flag", true));
            colList.Add(new DBColumn("contract_remark", "tfy_contract_remark", true));
            colList.Add(new DBColumn("cust_date", "dfy_cust_date", ColType.Null, true));
            colList.Add(new DBColumn("pr_date", "dfy_pr_date", ColType.Null, true));
            colList.Add(new DBColumn("last_date", "dfy_last_date", ColType.Null, true));
            colList.Add(new DBColumn("send_way", "tfy_send_way", true));
            colList.Add(new DBColumn("receipt_type", "tfy_receipt_type", true));
            colList.Add(new DBColumn("receipt_title", "tfy_receipt_title", true));
            colList.Add(new DBColumn("rectitle_name", "tfy_rectitle_name", true));
            colList.Add(new DBColumn("Remark", "tfy_Remark", true));
            colList.Add(new DBColumn("tot_case", "nfy_tot_case", ColType.Zero, true));
            colList.Add(new DBColumn("ar_code", "tfy_ar_code", true));
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
            } else {
                colList.Add(new DBColumn("acc_chk", "'N'", ColType.Value));
            }
            SQL += Util.GetInsertSQL(colList);
            //Response.Write(SQL + "<HR>");
            conn.ExecuteNonQuery(SQL);

            //*****todo依案性新增內商的案件內容
            string aa = Request["draw_file1"] ?? "";
            string newfilename = "";
            if (aa != "") {
                //2013/11/26修改可以中文檔名上傳及虛擬路徑
                //string strpath = "/btbrt/" + Session["seBranch"] + "T/temp";
                string strpath = sfile.gbrWebDir + "/temp";
                string attach_name = RSno + System.IO.Path.GetExtension(aa);//重新命名檔名
                newfilename = strpath + "/" + attach_name;//存在資料庫路徑
                Sys.RenameFile(Sys.Path2Nbtbrt(aa), strpath + "/" + attach_name, true);
            }
            SQL = "insert into dmt_temp";
            colList = new List<DBColumn>();
            colList.Add(new DBColumn("S_Mark", "tfz1_S_Mark", ColType.Str, true));
            colList.Add(new DBColumn("seq", "tfz1_seq", ColType.Str, true));
            colList.Add(new DBColumn("seq1", "tfz1_seq1", ColType.Str, true));
            colList.Add(new DBColumn("s_mark2", "tfz1_s_mark2", ColType.Str, true));
            colList.Add(new DBColumn("cust_prod", "tfz1_cust_prod", ColType.Str, true));
            colList.Add(new DBColumn("agt_no", "tfz1_agt_no", ColType.Str, true));
            colList.Add(new DBColumn("prior_date", "pfz1_prior_date", ColType.Null, true));
            colList.Add(new DBColumn("prior_country", "tfz1_prior_country", ColType.Str, true));
            colList.Add(new DBColumn("prior_no", "tfz1_prior_no", ColType.Str, true));
            colList.Add(new DBColumn("good_name", "tfd1_good_name", ColType.Str, true));//證明內容
            colList.Add(new DBColumn("good_name", "tf91_good_name", ColType.Str, true));//表彰內容
            colList.Add(new DBColumn("remark1", "tfz1_remark1", ColType.Str, true));
            colList.Add(new DBColumn("remark2", "tfz1_remark2", ColType.Str, true));
            colList.Add(new DBColumn("Appl_name", "tfz1_Appl_name", ColType.Str, true));
            colList.Add(new DBColumn("color", "tfz1_color", ColType.Str, true));
            colList.Add(new DBColumn("Oappl_name", "tfz1_Oappl_name", ColType.Str, true));
            colList.Add(new DBColumn("Cappl_name", "tfz1_Cappl_name", ColType.Str, true));
            colList.Add(new DBColumn("Eappl_name", "tfz1_Eappl_name", ColType.Str, true));
            colList.Add(new DBColumn("Zname_type", "tfz1_Zname_type", ColType.Str, true));
            colList.Add(new DBColumn("Eappl_name1", "tfz1_Eappl_name1", ColType.Str, true));
            colList.Add(new DBColumn("Eappl_name2", "tfz1_Eappl_name2", ColType.Str, true));
            colList.Add(new DBColumn("Draw", "tfz1_Draw", ColType.Str, true));
            colList.Add(new DBColumn("Symbol", "tfz1_Symbol", ColType.Str, true));
            colList.Add(new DBColumn("Remark4", "tfz1_Remark4", ColType.Str, true));
            colList.Add(new DBColumn("remark3", "tfz1_remark3", ColType.Str, true));
            colList.Add(new DBColumn("pul", "tfz1_pul", ColType.Str, true));
            colList.Add(new DBColumn("class_type", "tfz1_class_type", ColType.Str, true));
            colList.Add(new DBColumn("class_count", "ctrlcount1", ColType.Null, true));
            colList.Add(new DBColumn("class", "tfz1_class", ColType.Str, true));
            colList.Add(new DBColumn("in_scode", "F_tscode", ColType.Str));
            colList.Add(new DBColumn("in_no", "'" + RSno + "'", ColType.Value));
            colList.Add(new DBColumn("in_date", "'" + DateTime.Today.ToShortDateString() + "'", ColType.Value));
            colList.Add(new DBColumn("draw_file", "'" + Sys.Path2Btbrt(newfilename) + "'", ColType.Value));
            colList.Add(new DBColumn("tr_date", "'" + DateTime.Today.ToShortDateString() + "'", ColType.Value));
            colList.Add(new DBColumn("tr_scode", "'" + Session["scode"] + "'", ColType.Value));
            SQL += Util.GetInsertSQL(colList);
            //Response.Write(SQL + "<HR>");
            conn.ExecuteNonQuery(SQL);

            //****主委辦案性	
            SQL = "insert into caseitem_dmt";
            colList = new List<DBColumn>();
            colList.Add(new DBColumn("in_scode", "F_tscode", ColType.Str));
            colList.Add(new DBColumn("in_no", "'" + RSno + "'", ColType.Value));
            colList.Add(new DBColumn("item_sql", "'0'", ColType.Value));
            colList.Add(new DBColumn("seq1", "tfz1_seq1", ColType.Str));
            colList.Add(new DBColumn("item_arcase", "tfy_arcase", ColType.Str));
            colList.Add(new DBColumn("item_service", "nfyi_service", ColType.Str));
            colList.Add(new DBColumn("item_fees", "nfyi_fees", ColType.Str));
            colList.Add(new DBColumn("item_count", "'1'", ColType.Value));
            SQL += Util.GetInsertSQL(colList);
            //Response.Write(SQL + "<HR>");
            conn.ExecuteNonQuery(SQL);

            //****次委辦案性
            for (int i = 1; i <= Convert.ToInt32("0" + Request["TaCount"]); i++) {
                if ((Request["nfyi_item_Arcase_" + i] ?? "") != "") {
                    SQL = "insert into caseitem_dmt";
                    colList = new List<DBColumn>();
                    colList.Add(new DBColumn("in_scode", "F_tscode", ColType.Str));
                    colList.Add(new DBColumn("in_no", "'" + RSno + "'", ColType.Value));
                    colList.Add(new DBColumn("item_sql", "'" + i + "'", ColType.Value));
                    colList.Add(new DBColumn("seq1", "tfz1_seq1", ColType.Str));
                    colList.Add(new DBColumn("item_arcase", "nfyi_item_Arcase_" + i, ColType.Str));
                    colList.Add(new DBColumn("item_service", "nfyi_Service_" + i, ColType.Str));
                    colList.Add(new DBColumn("item_fees", "nfyi_fees_" + i, ColType.Str));
                    colList.Add(new DBColumn("item_count", "nfyi_item_count_" + i, ColType.Str));
                    SQL += Util.GetInsertSQL(colList);
                    //Response.Write(SQL + "<HR>");
                    conn.ExecuteNonQuery(SQL);
                }
            }

            //****商品類別
            for (int i = 1; i <= Convert.ToInt32("0" + Request["num1"]); i++) {
                if ((Request["class1_" + i] ?? "") != "") {
                    SQL = "insert into casedmt_good";
                    colList = new List<DBColumn>();
                    colList.Add(new DBColumn("in_scode", "F_tscode", ColType.Str));
                    colList.Add(new DBColumn("in_no", "'" + RSno + "'", ColType.Value));
                    colList.Add(new DBColumn("class", "class1_" + i, ColType.Str));
                    colList.Add(new DBColumn("dmt_grp_code", "grp_code1_" + i, ColType.Str));
                    colList.Add(new DBColumn("dmt_goodname", "good_name1_" + i, ColType.Str));
                    colList.Add(new DBColumn("dmt_goodcount", "good_count1_" + i, ColType.Str));
                    colList.Add(new DBColumn("tr_date", "'" + DateTime.Today.ToShortDateString() + "'", ColType.Value));
                    colList.Add(new DBColumn("tr_scode", "'" + Session["scode"] + "'", ColType.Value));
                    SQL += Util.GetInsertSQL(colList);
                    //Response.Write(SQL + "<HR>");
                    conn.ExecuteNonQuery(SQL);
                }
            }

            //****新增展覽優先權資料
            for (int i = 1; i <= Convert.ToInt32("0" + Request["shownum"]); i++) {
                if ((Request["show_date_" + i] ?? "") != "" || (Request["show_name_" + i] ?? "") != "") {
                    SQL = "insert into casedmt_show";
                    colList = new List<DBColumn>();
                    colList.Add(new DBColumn("in_no", "'" + RSno + "'", ColType.Value));
                    colList.Add(new DBColumn("case_sqlno", "0", ColType.Value));
                    colList.Add(new DBColumn("show_date", "show_date_" + i, ColType.Null));
                    colList.Add(new DBColumn("show_name", "show_name_" + i, ColType.Null));
                    colList.Add(new DBColumn("tr_date", "getdate()", ColType.Value));
                    colList.Add(new DBColumn("tr_scode", "'" + Session["scode"] + "'", ColType.Value));
                    SQL += Util.GetInsertSQL(colList);
                    //Response.Write(SQL + "<HR>");
                    conn.ExecuteNonQuery(SQL);
                }
            }

            //最近立案日
            colList = new List<DBColumn>();
            SQL = "update custz set dmt_date = '" + DateTime.Today.ToShortDateString() + "' ";
            SQL += "where cust_area = '" + Request["tfy_cust_area"] + "' ";
            SQL += "and cust_seq = '" + Request["tfy_cust_seq"] + "'";
            //Response.Write(SQL + "<HR>");
            conn.ExecuteNonQuery(SQL);

            //交辦申請人
            for (int i = 1; i <= Convert.ToInt32("0" + Request["apnum"]); i++) {
                SQL = "insert into dmt_temp_ap";
                colList = new List<DBColumn>();
                colList.Add(new DBColumn("in_no", "'" + RSno + "'", ColType.Value));
                colList.Add(new DBColumn("case_sqlno", "0", ColType.Value));
                colList.Add(new DBColumn("apsqlno", "apsqlno_" + i, ColType.Str));
                colList.Add(new DBColumn("Server_flag", "ap_server_flag_" + i, ColType.Str));
                colList.Add(new DBColumn("apcust_no", "apcust_no_" + i, ColType.Str));
                colList.Add(new DBColumn("ap_cname", "ap_cname_" + i, ColType.Str));
                colList.Add(new DBColumn("ap_cname1", "ap_cname1_" + i, ColType.Str));
                colList.Add(new DBColumn("ap_cname2", "ap_cname2_" + i, ColType.Str));
                colList.Add(new DBColumn("ap_ename", "ap_ename_" + i, ColType.Str));
                colList.Add(new DBColumn("ap_ename1", "ap_ename1_" + i, ColType.Str));
                colList.Add(new DBColumn("ap_ename2", "ap_ename2_" + i, ColType.Str));
                colList.Add(new DBColumn("tran_date", "getdate()", ColType.Value));
                colList.Add(new DBColumn("tran_scode", "'" + Session["scode"] + "'", ColType.Value));
                colList.Add(new DBColumn("ap_fcname", "ap_fcname_" + i, ColType.Str));
                colList.Add(new DBColumn("ap_lcname", "ap_lcname_" + i, ColType.Str));
                colList.Add(new DBColumn("ap_fename", "ap_fename_" + i, ColType.Str));
                colList.Add(new DBColumn("ap_lename", "ap_lename_" + i, ColType.Str));
                colList.Add(new DBColumn("ap_sql", "ap_sql_" + i, ColType.Zero));
                colList.Add(new DBColumn("ap_zip", "ap_zip_" + i, ColType.Str));
                colList.Add(new DBColumn("ap_addr1", "ap_addr1_" + i, ColType.Str));
                colList.Add(new DBColumn("ap_addr2", "ap_addr2_" + i, ColType.Str));
                colList.Add(new DBColumn("ap_eaddr1", "ap_eaddr1_" + i, ColType.Str));
                colList.Add(new DBColumn("ap_eaddr2", "ap_eaddr2_" + i, ColType.Str));
                colList.Add(new DBColumn("ap_eaddr3", "ap_eaddr3_" + i, ColType.Str));
                colList.Add(new DBColumn("ap_eaddr4", "ap_eaddr4_" + i, ColType.Str));
                SQL += Util.GetInsertSQL(colList);
                //Response.Write(SQL + "<HR>");
                conn.ExecuteNonQuery(SQL);
            }

            //*****新增文件上傳
            //string strpath="/btbrt/" + Session["seBranch"] + "T/"  + Request["attach_path"];
            string strpath1 = sfile.gbrWebDir + "/" + Request["attach_path"];
            string fld = Request["uploadfield"] ?? "";
            for (int k = 1; k <= Convert.ToInt32("0" + Request[fld + "_filenum"]); k++) {
                string straa = (Request[fld + "_name_" + k] ?? "");//原始檔名
                if (straa != "") {
                    string sExt = System.IO.Path.GetExtension(straa);//副檔名
                    string attach_name = "";//資料庫檔名
                    string newattach_path = "";//資料庫路徑
                    //2015/12/29修改，總契約書或委任書不需更換檔名
                    if ((Request[fld + "_apattach_sqlno_" + k] ?? "") != "") {
                        attach_name = straa;
                        newattach_path = Request[fld + "_" + k] ?? "";
                    } else {
                        attach_name = RSno + "-" + k + sExt;//重新命名檔名
                        newattach_path = strpath1 + "/" + attach_name;//存在資料庫路徑
                    }
                    SQL = "insert into dmt_attach";
                    colList = new List<DBColumn>();
                    colList.Add(new DBColumn("in_no", "'" + RSno + "'", ColType.Value));
                    colList.Add(new DBColumn("source", "'case'", ColType.Value));
                    colList.Add(new DBColumn("in_date", "getdate()", ColType.Value));
                    colList.Add(new DBColumn("in_scode", "'" + Session["scode"] + "'", ColType.Value));
                    colList.Add(new DBColumn("attach_no", "'" + k + "'", ColType.Value));
                    colList.Add(new DBColumn("attach_path", "'" + Sys.Path2Btbrt(newattach_path) + "'", ColType.Value));
                    colList.Add(new DBColumn("doc_type", "doc_type_" + k, ColType.Null));
                    colList.Add(new DBColumn("attach_desc", fld + "_desc_" + k, ColType.Null));
                    colList.Add(new DBColumn("attach_name", "'" + attach_name + "'", ColType.Value));
                    colList.Add(new DBColumn("source_name", "'" + straa + "'", ColType.Value));
                    colList.Add(new DBColumn("attach_size", fld + "_size_" + k, ColType.Null));
                    colList.Add(new DBColumn("attach_flag", "'A'", ColType.Value));
                    colList.Add(new DBColumn("attach_branch", fld + "_branch_" + k, ColType.Str));
                    colList.Add(new DBColumn("apattach_sqlno", fld + "_apattach_sqlno_" + k, ColType.Str));
                    SQL += Util.GetInsertSQL(colList);
                    //Response.Write(SQL + "<HR>");
                    conn.ExecuteNonQuery(SQL);
                    //有改檔名要重新命名
                    if (straa != attach_name) {
                        Sys.RenameFile(strpath1 + "/" + straa, strpath1 + "/" + attach_name, false);
                    }
                }
            }
            conn.Commit();
            //conn.RollBack();

            if (Request["chkTest"] != "TEST") {
                strOut.AppendLine("<script language='javascript' type='text/javascript'>");
            }

            strOut.AppendLine("document.location.href='Brt11addnext.aspx?prgid=" + prgid +
                "&cust_area=" + Request["tfy_cust_area"] + "&cust_seq=" + Request["tfy_cust_seq"] +
                "&in_no=" + RSno + "&add_arcase=" + Request["tfy_arcase"] + "&ar_form=" + Request["ar_form"] +
                "&code_type=" + Request["code_type"] + "&F_tscode=" + Request["F_tscode"] +
                "&seq=" + Request["tfzb_seq"] + "&seq1=" + Request["tfzb_seq1"] +
                "&prt_code=" + Request["prt_code"] + "&new_form=" + Request["new_form"] + "'");

            if (Request["chkTest"] != "TEST") {
                strOut.AppendLine("<" + "/script>");
            }
        }
    }
</script>

<%Response.Write(strOut.ToString());%>
