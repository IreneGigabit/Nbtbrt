﻿<%@ Page Language="C#" CodePage="65001" %>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace="System.Collections.Generic" %>

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
    protected string drawFilename = "";

    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected Dictionary<string, string> ColMap = new Dictionary<string, string>();
    protected string SQL = "";
    Sys sfile = new Sys();

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
        sfile.getFileServer(Sys.GetSession("SeBranch"), Request["prgid"]);//檔案上傳相關設定

        object objResult = null;
        using (DBHelper conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST")) {
            //******************產生流水號(yyyyMMddnnn);
            string nowRSno = DateTime.Today.ToString("yyyyMMdd");
            SQL = "SELECT MAX(in_no) FROM case_dmt WITH(TABLOCKX) WHERE LEFT(in_no, 8) = '" + nowRSno + "'";
            objResult = conn.ExecuteScalar(SQL);
            int nowSql = (objResult == DBNull.Value || objResult == null ? 0 : Convert.ToInt32(((string)objResult).Right(3)));
            string RSno = String.Format("{0}{1:000}", nowRSno, nowSql + 1);

            //交辦內容欄位畫面
            if (Request["ar_form"] == "A3") {
                addA3(conn,RSno);
            } else if (Request["ar_form"] == "A4") {
                addA4(conn, RSno);
            } else if (Request["ar_form"] == "A5") {
                addA5(conn, RSno);
            } else if (Request["ar_form"] == "A6") {
                addA6(conn, RSno);
            } else if (Request["ar_form"] == "A7") {
                addA7(conn, RSno);
            } else if (Request["ar_form"] == "A8") {
                addA8(conn, RSno);
            } else if (Request["ar_form"] == "A9") {
                addA9(conn, RSno);
            } else if (Request["ar_form"] == "AA") {
                addAA(conn, RSno);
            } else if (Request["ar_form"] == "AB") {
                addAB(conn, RSno);
            } else if (Request["ar_form"] == "AC") {
                addAC(conn, RSno);
            } else if (Request["ar_form"].Left(1) == "B") {
                addB(conn, RSno);
            } else {
                addZZ(conn, RSno);
            }

            conn.Commit();
            //conn.RollBack();

            if (Request["chkTest"] != "TEST") {
                strOut.AppendLine("<script language='javascript' type='text/javascript'>");
            }
            if (prgid == "brt151") {//國內案接洽客戶後續查詢作業
                strOut.AppendLine("window.parent.Etop.goSearch();");//清單重新整理
            } else {
                strOut.AppendLine("document.location.href='Brt11addnext.aspx?prgid=" + prgid +
                    "&cust_area=" + Request["tfy_cust_area"] + "&cust_seq=" + Request["tfy_cust_seq"] +
                    "&in_no=" + RSno + "&add_arcase=" + Request["tfy_arcase"] + "&ar_form=" + Request["ar_form"] +
                    "&code_type=" + Request["code_type"] + "&F_tscode=" + Request["F_tscode"] +
                    "&seq=" + Request["tfzb_seq"] + "&seq1=" + Request["tfzb_seq1"] +
                    "&prt_code=" + Request["prt_code"] + "&new_form=" + Request["new_form"] + "'");
            }
            if (Request["chkTest"] != "TEST") {
                strOut.AppendLine("<" + "/script>");
            }
        }
    }

    /// <summary>
    /// 寫入接洽記錄檔(case_dmt)
    /// </summary>
    private void insert_case_dmt(DBHelper conn, string RSno) {
        ColMap.Clear();
        foreach (var key in Request.Form.Keys) {
            string colkey = key.ToString().ToLower();
            string colValue = Request[colkey];

            //取2~4碼(直接用substr若欄位名稱太短會壞掉)
            if (colkey.Left(4).Substring(1) == "fy_") {
                if (colkey.Left(1) == "p") {
                    ColMap[colkey.Substring(4)] = Util.dbnull(colValue);
                } else if (colkey.Left(1) == "d") {
                    ColMap[colkey.Substring(4)] = Util.dbnull(colValue);
                } else if (colkey.Left(1) == "n") {
                    ColMap[colkey.Substring(4)] = Util.dbzero(colValue);
                } else {
                    ColMap[colkey.Substring(4)] = Util.dbnull(colValue);
                }
            }
        }

        ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
        ColMap["in_no"] = "'" + RSno + "'";
        ColMap["in_date"] = "'" + DateTime.Today.ToShortDateString() + "'";
        ColMap["arcase_type"] = Util.dbchar(Request["code_type"]);
        ColMap["arcase_class"] = Util.dbchar(Request["prt_code"]);
        ColMap["seq1"] = Util.dbchar(Request["tfzb_seq1"]);
        ColMap["seq"] = Util.dbnull(Request["tfzb_seq"]);
        ColMap["grconf_sqlno"] = Util.dbnull(Request["grconf_sqlno"]);
        //******折扣請核單
        if (Request["tfy_discount_chk"] == null) {
            ColMap["discount_chk"] = "'N'";
        }
        //******請款單 
        if (Request["tfy_ar_chk"] == null) {
            ColMap["ar_chk"] = "'N'";
        }
        if (Request["tfy_ar_chk1"] == null) {
            ColMap["ar_chk1"] = "'N'";
        }
        //****會計檢核2013/9/16增加，不需請款或大陸進口案不在線上請款，不需會計檢核
        //M→大陸進口案,X→沒有費用且請款註記=一般
        if (Request["tfy_ar_code"] == "X" || Request["tfy_ar_code"] == "M") {
            ColMap["acc_chk"] = "'X'";
        }
        SQL = "insert into case_dmt " + ColMap.GetInsertSQL();
        //Response.Write(SQL + "<HR>");
        conn.ExecuteNonQuery(SQL);
    }

    /// <summary>
    /// 將檔案更改檔名
    /// </summary>
    private string move_file(string RSno, string drawValue, string suffix) {
        if (drawValue == null || drawValue.Trim() == "")
            return "";

        string aa = drawValue.ToLower();
        string newfilename = "";
        if (aa != "") {
            //if (aa.IndexOf("/temp") > -1) {//若是舊案(不是/temp)則不處理
                //2013/11/26修改可以中文檔名上傳及虛擬路徑
                //string strpath = "/btbrt/" + Session["seBranch"] + "T/temp";
                string strpath = sfile.gbrWebDir + "/temp";
                //string attach_name = RSno + System.IO.Path.GetExtension(aa);//重新命名檔名
                //string attach_name = filename + System.IO.Path.GetExtension(aa);//重新命名檔名
                string attach_name = RSno + suffix + System.IO.Path.GetExtension(aa);//重新命名檔名
                newfilename = strpath + "/" + attach_name;//存在資料庫路徑
                if (aa.IndexOf("/") > -1 || aa.IndexOf("\\") > -1)
                    Sys.RenameFile(Sys.Path2Nbtbrt(aa), strpath + "/" + attach_name, true);
                else
                    Sys.RenameFile(strpath + "/" + aa, strpath + "/" + attach_name, true);
            //} else {
            //    newfilename=Sys.Path2Nbtbrt(aa);
            //}
        }
        return newfilename;
    }
    
    /// <summary>
    /// 寫入接洽記錄主檔檔(dmt_temp)
    /// </summary>
    private void insert_dmt_temp(DBHelper conn, string RSno) {
        //將檔案更改檔名
        //舊案不處理
        if ((Request["tfy_case_stat"] ?? "") == "OO") {
            drawFilename = Sys.Path2Nbtbrt(Request["draw_file"]);
        } else {
            drawFilename = move_file(RSno, Request["draw_file"], "");
        }
        //*****若為新案則新增至案件檔,舊案則不用
        ColMap.Clear();
        foreach (var key in Request.Form.Keys) {
            string colkey = key.ToString().ToLower();
            string colValue = Request[colkey];

            //取2~5碼(直接用substr若欄位名稱太短會壞掉)
            if (colkey.Left(4).Substring(1) == "fzd"
                || colkey.Left(4).Substring(1) == "fzb"
                || colkey.Left(4).Substring(1) == "fzp"
                ) {
                if (colkey.Left(1) == "p") {
                    ColMap[colkey.Substring(5)] = Util.dbnull(colValue);
                } else if (colkey.Left(1) == "d") {
                    ColMap[colkey.Substring(5)] = Util.dbnull(colValue);
                } else if (colkey.Left(1) == "n") {
                    ColMap[colkey.Substring(5)] = Util.dbzero(colValue);
                } else {
                    ColMap[colkey.Substring(5)] = Util.dbnull(colValue);
                }
            }
        }
        if ((Request["ar_form"] ?? "") != "A4" && (Request["tfy_arcase"] ?? "") != "FC3") {
            if ((Request["tfzr_class_count"] ?? "") != "") {
                ColMap["class_type"] = Util.dbchar(Request["tfzr_class_type"]);
                ColMap["class_count"] = Util.dbchar(Request["tfzr_class_count"]);
                ColMap["class"] = Util.dbchar(Request["tfzr_class"]);
            }
        } else {
            if ((Request["tft3_class_count2"] ?? "") != "") {
                ColMap["class_type"] = Util.dbchar(Request["tft3_class_type2"]);
                ColMap["class_count"] = Util.dbchar(Request["tft3_class_count2"]);
                ColMap["class"] = Util.dbchar(Request["tft3_class2"]);
            }
        }

        ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
        ColMap["in_no"] = "'" + RSno + "'";
        ColMap["in_date"] = "'" + DateTime.Today.ToShortDateString() + "'";
        ColMap["draw_file"] = Util.dbchar(Sys.Path2Btbrt(drawFilename));
        ColMap["tr_date"] = "getdate()";
        ColMap["tr_scode"] = "'" + Session["scode"] + "'";
        ColMap["case_sqlno"] = "0";
        if ((Request["tfy_arcase"] ?? "").Left(3).IN("FD1,FD2,FD3")) {//分割案才寫入母案編號
            ColMap["Mseq"] = Util.dbnull(Request["tfzb_seq"]);
            ColMap["Mseq1"] = Util.dbnull(Request["tfzb_seq1"]);
        }
        SQL = "insert into dmt_temp " + ColMap.GetInsertSQL();
        conn.ExecuteNonQuery(SQL);
    }

    /// <summary>
    /// 寫入交辦申請人檔(dmt_temp_ap)
    /// </summary>
    private void insert_dmt_temp_ap(DBHelper conn, string RSno, string case_sqlno) {
        //交辦申請人
        for (int i = 1; i <= Convert.ToInt32("0" + Request["apnum"]); i++) {
            ColMap.Clear();
            ColMap["in_no"] = "'" + RSno + "'";
            ColMap["case_sqlno"] = case_sqlno;
            ColMap["apsqlno"] = Util.dbchar(Request["apsqlno_" + i]);
            ColMap["Server_flag"] = Util.dbchar(Request["ap_server_flag_" + i]);
            ColMap["apcust_no"] = Util.dbchar(Request["apcust_no_" + i]);
            ColMap["ap_cname"] = Util.dbchar(Request["ap_cname_" + i]);
            ColMap["ap_cname1"] = Util.dbchar(Request["ap_cname1_" + i]);
            ColMap["ap_cname2"] = Util.dbchar(Request["ap_cname2_" + i]);
            ColMap["ap_ename"] = Util.dbchar(Request["ap_ename_" + i]);
            ColMap["ap_ename1"] = Util.dbchar(Request["ap_ename1_" + i]);
            ColMap["ap_ename2"] = Util.dbchar(Request["ap_ename2_" + i]);
            ColMap["tran_date"] = "getdate()";
            ColMap["tran_scode"] = "'" + Session["scode"] + "'";
            ColMap["ap_fcname"] = Util.dbchar(Request["ap_fcname_" + i]);
            ColMap["ap_lcname"] = Util.dbchar(Request["ap_lcname_" + i]);
            ColMap["ap_fename"] = Util.dbchar(Request["ap_fename_" + i]);
            ColMap["ap_lename"] = Util.dbchar(Request["ap_lename_" + i]);
            ColMap["ap_sql"] = Util.dbzero(Request["ap_sql_" + i]);
            ColMap["ap_zip"] = Util.dbchar(Request["ap_zip_" + i]);
            ColMap["ap_addr1"] = Util.dbchar(Request["ap_addr1_" + i]);
            ColMap["ap_addr2"] = Util.dbchar(Request["ap_addr2_" + i]);
            ColMap["ap_eaddr1"] = Util.dbchar(Request["ap_eaddr1_" + i]);
            ColMap["ap_eaddr2"] = Util.dbchar(Request["ap_eaddr2_" + i]);
            ColMap["ap_eaddr3"] = Util.dbchar(Request["ap_eaddr3_" + i]);
            ColMap["ap_eaddr4"] = Util.dbchar(Request["ap_eaddr4_" + i]);
            ColMap["ap_sort"] = Util.dbnull(Request["ap_sort_" + i]);

            SQL = "insert into dmt_temp_ap " + ColMap.GetInsertSQL();
            conn.ExecuteNonQuery(SQL);
        }
    }

    /// <summary>
    /// 寫入交辦申請人檔(dmt_temp_ap)(Apcust_FC_RE_form)
    /// </summary>
    private void insert_dmt_temp_ap_FC0(DBHelper conn, string RSno, string case_sqlno) {
        //交辦申請人
		for (int i = 1; i <= Convert.ToInt32("0" + Request["FC0_apnum"]); i++) {
			ColMap.Clear();
			ColMap["in_no"] = "'" + RSno + "'";
			ColMap["case_sqlno"] = case_sqlno;
			ColMap["apsqlno"] = Util.dbchar(Request["dbmn_apsqlno_" + i]);
			ColMap["Server_flag"] = Util.dbchar(Request["fc0_ap_server_flag_" + i]);
			ColMap["apcust_no"] = Util.dbchar(Request["dbmn_new_no_" + i]);
			ColMap["ap_cname"] = Util.dbchar(Request["dbmn_ap_cname_" + i]);
			ColMap["ap_cname1"] = Util.dbchar(Request["dbmn_ncname1_" + i]);
			ColMap["ap_cname2"] = Util.dbchar(Request["dbmn_ncname2_" + i]);
			ColMap["ap_ename"] = Util.dbchar(Request["dbmn_ap_ename_" + i]);
			ColMap["ap_ename1"] = Util.dbchar(Request["dbmn_nename1_" + i]);
			ColMap["ap_ename2"] = Util.dbchar(Request["dbmn_nename2_" + i]);
			ColMap["tran_date"] = "getdate()";
			ColMap["tran_scode"] = "'" + Session["scode"] + "'";
			ColMap["ap_fcname"] = Util.dbchar(Request["dbmn_fcname_" + i]);
			ColMap["ap_lcname"] = Util.dbchar(Request["dbmn_lcname_" + i]);
			ColMap["ap_fename"] = Util.dbchar(Request["dbmn_fename_" + i]);
			ColMap["ap_lename"] = Util.dbchar(Request["dbmn_lename_" + i]);
			ColMap["ap_sql"] = Util.dbzero(Request["dbmn_ap_sql_" + i]);
			ColMap["ap_zip"] = Util.dbchar(Request["dbmn_nzip_" + i]);
			ColMap["ap_addr1"] = Util.dbchar(Request["dbmn_naddr1_" + i]);
			ColMap["ap_addr2"] = Util.dbchar(Request["dbmn_naddr2_" + i]);
			ColMap["ap_eaddr1"] = Util.dbchar(Request["dbmn_neaddr1_" + i]);
			ColMap["ap_eaddr2"] = Util.dbchar(Request["dbmn_neaddr2_" + i]);
			ColMap["ap_eaddr3"] = Util.dbchar(Request["dbmn_neaddr3_" + i]);
			ColMap["ap_eaddr4"] = Util.dbchar(Request["dbmn_neaddr4_" + i]);

			SQL = "insert into dmt_temp_ap " + ColMap.GetInsertSQL();
			conn.ExecuteNonQuery(SQL);
		}
    }

    /// <summary>
    /// 寫入交辦申請人檔(dmt_temp_ap)(Apcust_FC_RE1_form)
    /// </summary>
    private void insert_dmt_temp_ap_FC2(DBHelper conn, string RSno, string case_sqlno) {
        //交辦申請人
		for (int i = 1; i <= Convert.ToInt32("0" + Request["FC2_apnum"]); i++) {
			ColMap.Clear();
			ColMap["in_no"] = "'" + RSno + "'";
			ColMap["case_sqlno"] = case_sqlno;
			ColMap["apsqlno"] = Util.dbchar(Request["dbmn1_apsqlno_" + i]);
			ColMap["Server_flag"] = Util.dbchar(Request["fc2_ap_server_flag_" + i]);
			ColMap["apcust_no"] = Util.dbchar(Request["dbmn1_new_no_" + i]);
			ColMap["ap_cname"] = Util.dbchar(Request["dbmn1_ap_cname_" + i]);
			ColMap["ap_cname1"] = Util.dbchar(Request["dbmn1_ncname1_" + i]);
			ColMap["ap_cname2"] = Util.dbchar(Request["dbmn1_ncname2_" + i]);
			ColMap["ap_ename"] = Util.dbchar(Request["dbmn1_ap_ename_" + i]);
			ColMap["ap_ename1"] = Util.dbchar(Request["dbmn1_nename1_" + i]);
			ColMap["ap_ename2"] = Util.dbchar(Request["dbmn1_nename2_" + i]);
			ColMap["tran_date"] = "getdate()";
			ColMap["tran_scode"] = "'" + Session["scode"] + "'";
			ColMap["ap_fcname"] = Util.dbchar(Request["dbmn1_fcname_" + i]);
			ColMap["ap_lcname"] = Util.dbchar(Request["dbmn1_lcname_" + i]);
			ColMap["ap_fename"] = Util.dbchar(Request["dbmn1_fename_" + i]);
			ColMap["ap_lename"] = Util.dbchar(Request["dbmn1_lename_" + i]);
			ColMap["ap_sql"] = Util.dbzero(Request["dbmn1_ap_sql_" + i]);
			ColMap["ap_zip"] = Util.dbchar(Request["dbmn1_nzip_" + i]);
			ColMap["ap_addr1"] = Util.dbchar(Request["dbmn1_naddr1_" + i]);
			ColMap["ap_addr2"] = Util.dbchar(Request["dbmn1_naddr2_" + i]);
			ColMap["ap_eaddr1"] = Util.dbchar(Request["dbmn1_neaddr1_" + i]);
			ColMap["ap_eaddr2"] = Util.dbchar(Request["dbmn1_neaddr2_" + i]);
			ColMap["ap_eaddr3"] = Util.dbchar(Request["dbmn1_neaddr3_" + i]);
			ColMap["ap_eaddr4"] = Util.dbchar(Request["dbmn1_neaddr4_" + i]);

			SQL = "insert into dmt_temp_ap " + ColMap.GetInsertSQL();
			conn.ExecuteNonQuery(SQL);
		}
    }

    /// <summary>
    /// 寫入接洽費用檔(caseitem_dmt)
    /// </summary>
    private void insert_caseitem_dmt(DBHelper conn, string RSno) {
        //****主委辦案性	
        ColMap.Clear();
        ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
        ColMap["in_no"] = "'" + RSno + "'";
        ColMap["item_sql"] = "'0'";
        ColMap["seq"] = Util.dbnull(Request["tfzb_seq"]);
        ColMap["seq1"] = Util.dbchar(Request["tfzb_seq1"]);
        ColMap["item_arcase"] = Util.dbchar(Request["tfy_arcase"]);
        ColMap["item_service"] = Util.dbchar(Request["nfyi_service"]);
        ColMap["item_fees"] = Util.dbchar(Request["nfyi_fees"]);
        ColMap["item_count"] = "'1'";
        SQL = "insert into caseitem_dmt " + ColMap.GetInsertSQL();
        //Response.Write(SQL + "<HR>");
        conn.ExecuteNonQuery(SQL);

        //****次委辦案性
        for (int i = 1; i <= Convert.ToInt32("0" + Request["TaCount"]); i++) {
            if ((Request["nfyi_item_Arcase_" + i] ?? "") != "") {
                ColMap.Clear();
                ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
                ColMap["in_no"] = "'" + RSno + "'";
                ColMap["item_sql"] = "'" + i + "'";
                ColMap["seq"] = Util.dbnull(Request["tfzb_seq"]);
                ColMap["seq1"] = Util.dbchar(Request["tfzb_seq1"]);
                ColMap["item_arcase"] = Util.dbchar(Request["nfyi_item_Arcase_" + i]);
                ColMap["item_service"] = Util.dbchar(Request["nfyi_Service_" + i]);
                ColMap["item_fees"] = Util.dbchar(Request["nfyi_fees_" + i]);
                ColMap["item_count"] = Util.dbchar(Request["nfyi_item_count_" + i]);

                SQL = "insert into caseitem_dmt " + ColMap.GetInsertSQL();
                //Response.Write(SQL + "<HR>");
                conn.ExecuteNonQuery(SQL);
            }
        }
    }

    /// <summary>
    /// 寫入商品類別檔(casedmt_good)
    /// </summary>
    private void insert_casedmt_good(DBHelper conn, string RSno) {
        //****商品類別
        if ((Request["ar_form"] ?? "") == "A4") {
            //延展以交辦內容為準
            for (int i = 1; i <= Convert.ToInt32("0" + Request["tfzd_class_count"]); i++) {
                //2015/10/21增加判斷若有商品也入，因證明標章及團體標章無類別但會有證明內容
                if ((Request["class2_" + i] ?? "") != "" || (Request["good_name2_" + i] ?? "") != "") {
                    ColMap.Clear();
                    ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
                    ColMap["in_no"] = "'" + RSno + "'";
                    ColMap["class"] = Util.dbchar(Request["class2_" + i]);
                    ColMap["dmt_grp_code"] = Util.dbchar(Request["grp_code2_" + i]);
                    ColMap["dmt_goodname"] = Util.dbchar(Request["good_name2_" + i]);
                    ColMap["dmt_goodcount"] = Util.dbchar(Request["good_count2_" + i]);
                    ColMap["tr_date"] = "getdate()";
                    ColMap["tr_scode"] = "'" + Session["scode"] + "'";

                    SQL = "insert into casedmt_good " + ColMap.GetInsertSQL();
                    //Response.Write(SQL + "<HR>");
                    conn.ExecuteNonQuery(SQL);
                }
            }
        } else if ((Request["tfy_arcase"] ?? "") == "FC3") {
            for (int i = 1; i <= Convert.ToInt32("0" + Request["tft3_class_count2"]); i++) {
                //2015/10/21增加判斷若有商品也入，因證明標章及團體標章無類別但會有證明內容
                if ((Request["class32_" + i] ?? "") != "" || (Request["good_name32_" + i] ?? "") != "") {
                    ColMap.Clear();
                    ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
                    ColMap["in_no"] = "'" + RSno + "'";
                    ColMap["class"] = Util.dbchar(Request["class32_" + i]);
                    ColMap["dmt_goodname"] = Util.dbchar(Request["good_name32_" + i]);
                    ColMap["dmt_goodcount"] = Util.dbchar(Request["good_count32_" + i]);
                    ColMap["tr_date"] = "getdate()";
                    ColMap["tr_scode"] = "'" + Session["scode"] + "'";

                    SQL = "insert into casedmt_good " + ColMap.GetInsertSQL();
                    //Response.Write(SQL + "<HR>");
                    conn.ExecuteNonQuery(SQL);
                }
            }
        } else {
            for (int i = 1; i <= Convert.ToInt32("0" + Request["tfzr_class_count"]); i++) {
                //2015/10/21增加判斷若有商品也入，因證明標章及團體標章無類別但會有證明內容
                if ((Request["class1_" + i] ?? "") != "" || (Request["good_name1_" + i] ?? "") != "") {
                    ColMap.Clear();
                    ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
                    ColMap["in_no"] = "'" + RSno + "'";
                    ColMap["class"] = Util.dbchar(Request["class1_" + i]);
                    ColMap["dmt_grp_code"] = Util.dbchar(Request["grp_code1_" + i]);
                    ColMap["dmt_goodname"] = Util.dbchar(Request["good_name1_" + i]);
                    ColMap["dmt_goodcount"] = Util.dbchar(Request["good_count1_" + i]);
                    ColMap["tr_date"] = "getdate()";
                    ColMap["tr_scode"] = "'" + Session["scode"] + "'";

                    SQL = "insert into casedmt_good " + ColMap.GetInsertSQL();
                    //Response.Write(SQL + "<HR>");
                    conn.ExecuteNonQuery(SQL);
                }
            }
        }
    }

    /// <summary>
    /// 寫入展覽會優先權檔(casedmt_show)
    /// </summary>
    private void insert_casedmt_show(DBHelper conn, string RSno, string case_sqlno) {
        for (int i = 1; i <= Convert.ToInt32("0" + Request["shownum_dmt"]); i++) {
            if ((Request["show_date_dmt_" + i] ?? "") != "" || (Request["show_name_dmt_" + i] ?? "") != "") {
                ColMap.Clear();
                ColMap["in_no"] = "'" + RSno + "'";
                ColMap["case_sqlno"] = case_sqlno;
                ColMap["show_date"] = Util.dbnull(Request["show_date_dmt_" + i]);
                ColMap["show_name"] = Util.dbnull(Request["show_name_dmt_" + i]);
                ColMap["tr_date"] = "getdate()";
                ColMap["tr_scode"] = "'" + Session["scode"] + "'";

                SQL = "insert into casedmt_show " + ColMap.GetInsertSQL();
                //Response.Write(SQL + "<HR>");
                conn.ExecuteNonQuery(SQL);
            }
        }
    }

    /// <summary>
    /// 寫入附件記錄檔(dmt_attach)
    /// </summary>
    private void insert_dmt_attach(DBHelper conn, string RSno) {
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
                    Sys.RenameFile(strpath1 + "/" + straa, strpath1 + "/" + attach_name, true);
                }
                ColMap.Clear();
                ColMap["seq"] = Util.dbnull(Request["tfzb_seq"]);
                ColMap["seq1"] = Util.dbnull(Request["tfzb_seq1"]);
                ColMap["in_no"] = "'" + RSno + "'";
                ColMap["source"] = "'case'";
                ColMap["in_date"] = "getdate()";
                ColMap["in_scode"] = "'" + Session["scode"] + "'";
                ColMap["attach_no"] = "'" + k + "'";
                ColMap["attach_path"] = "'" + Sys.Path2Btbrt(newattach_path) + "'";
                ColMap["doc_type"] = Util.dbnull(Request["doc_type_" + k]);
                ColMap["attach_desc"] = Util.dbnull(Request[fld + "_desc_" + k]);
                ColMap["attach_name"] = Util.dbchar(attach_name);
                ColMap["source_name"] = Util.dbchar(straa);
                ColMap["attach_size"] = Util.dbnull(Request[fld + "_size_" + k]);
                ColMap["attach_flag"] = "'A'";
                ColMap["attach_branch"] = Util.dbchar(Request[fld + "_branch_" + k]);
                ColMap["apattach_sqlno"] = Util.dbchar(Request[fld + "_apattach_sqlno_" + k]);

                SQL = "insert into dmt_attach " + ColMap.GetInsertSQL();
                conn.ExecuteNonQuery(SQL);
            }
        }
    }

    /// <summary>
    /// 更新營洽官收確認紀錄檔(grconf_dmt.job_no)
    /// </summary>
    private void upd_grconf_job_no(DBHelper conn, string RSno) {
        //後續交辦作業，更新營洽官收確認紀錄檔grconf_dmt.job_no
        if ((Request["grconf_sqlno"] ?? "") != "") {
            SQL = "update grconf_dmt set job_no = '" + RSno + "' ";
            SQL += ",finish_date = getdate() ";
            SQL += "where grconf_sqlno = '" + Request["grconf_sqlno"] + "' ";
            //Response.Write(SQL + "<HR>");
            conn.ExecuteNonQuery(SQL);
        }
    }

    /// <summary>
    /// 更新客戶主檔最近立案日(custz.dmt_date)
    /// </summary>
    private void upd_dmt_date(DBHelper conn, string RSno) {
        //新案要更新最近立案日
        if ((Request["tfy_case_stat"] ?? "") == "NN" || (Request["tfy_case_stat"] ?? "") == "SN") {
            SQL = "update custz set dmt_date = '" + DateTime.Today.ToShortDateString() + "' ";
            SQL += "where cust_area = '" + Request["tfy_cust_area"] + "' ";
            SQL += "and cust_seq = '" + Request["tfy_cust_seq"] + "'";
            //Response.Write(SQL + "<HR>");
            conn.ExecuteNonQuery(SQL);
        }
    }

    /// <summary>
    /// 重建暫存檔(一案多件)
    /// </summary>
    private void rebuil_change(string RSno, string mark) {
        using (DBHelper conn1 = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST")) {
            SQL = "delete from dmt_temp_change where in_scode='" + Request["F_tscode"] + "' and cust_area='" + Request["F_cust_area"] + "' and cust_seq='" + Request["F_cust_seq"] + "' and mark='" + mark + "'";
            conn1.ExecuteNonQuery(SQL);
            SQL = "delete from casedmt_good_change where in_scode='" + Request["F_tscode"] + "' and cust_area='" + Request["F_cust_area"] + "' and cust_seq='" + Request["F_cust_seq"] + "' and mark='" + mark + "'";
            conn1.ExecuteNonQuery(SQL);
            SQL = "delete from casedmt_show_change where in_scode='" + Request["F_tscode"] + "' and cust_area='" + Request["F_cust_area"] + "' and cust_seq='" + Request["F_cust_seq"] + "' and mark='" + mark + "'";
            conn1.ExecuteNonQuery(SQL);

            DataTable dt = new DataTable();
            SQL = "select * from case_dmt1 where in_no= '" + RSno + "'";
            conn1.DataTable(SQL, dt);
            for (int i = 0; i < dt.Rows.Count; i++) {
                SQL = "insert into dmt_temp_change(s_mark,s_mark2,pul,appl_name,cappl_name,eappl_name";
                SQL += ",eappl_name1,eappl_name2,jappl_name,jappl_name1,jappl_name2,zappl_name1 ";
                SQL += ",zappl_name2,zname_type,oappl_name,Draw,symbol,color,prior_date,prior_no ";
                SQL += ",prior_country,ref_no,ref_no1,tcn_ref,tcn_class,tcn_name,tcn_mark ";
                SQL += ",apply_date,apply_no,issue_date,issue_no,open_date,rej_no,end_date ";
                SQL += ",end_code,dmt_term1,dmt_term2,renewal,seq,seq1,draw_file,class_type ";
                SQL += ",class_count,class ";
                SQL += ",in_scode,cust_area,cust_seq,num,tr_date,tr_scode,mark) ";
                SQL += "Select s_mark,s_mark2 as ts_mark,pul,appl_name,cappl_name,eappl_name ";
                SQL += ",eappl_name1,eappl_name2,jappl_name,jappl_name1,jappl_name2,zappl_name1 ";
                SQL += ",zappl_name2,zname_type,oappl_name,Draw,symbol,color,prior_date,prior_no ";
                SQL += ",prior_country,ref_no,ref_no1,tcn_ref,tcn_class,tcn_name,tcn_mark ";
                SQL += ",apply_date,apply_no,issue_date,issue_no,open_date,rej_no,end_date ";
                SQL += ",end_code,dmt_term1,dmt_term2,renewal,seq,seq1,draw_file,class_type ";
                SQL += ",class_count,class ";
                SQL += ",'" + Request["F_tscode"] + "','" + Request["F_cust_area"] + "','" + Request["F_cust_seq"] + "','" + (i + 1) + "' ";
                SQL += ",getdate(),'" + Session["scode"] + "','" + mark + "' ";
                SQL += "from dmt_temp where in_no='" + RSno + "' and case_sqlno=" + dt.Rows[i]["case_sqlno"] + "";
                conn1.ExecuteNonQuery(SQL);

                SQL = "INSERT INTO casedmt_good_change(in_scode,cust_area,cust_seq,num,class,dmt_grp_code";
                SQL += ",dmt_goodname,dmt_goodcount,tr_date,tr_scode,mark) ";
                SQL += "select '" + Request["F_tscode"] + "','" + Request["F_cust_area"] + "','" + Request["F_cust_seq"] + "','" + (i + 1) + "'";
                SQL += ",class,dmt_grp_code,dmt_goodname,dmt_goodcount,getdate(),'" + Session["scode"] + "','" + mark + "' ";
                SQL += "from casedmt_good where in_no='" + RSno + "' and case_sqlno=" + dt.Rows[i]["case_sqlno"] + "";
                conn1.ExecuteNonQuery(SQL);

                SQL = "INSERT INTO casedmt_show_change(in_scode,cust_area,cust_seq,num,show_no,show_date";
                SQL += ",show_name,tr_date,tr_scode,mark) ";
                SQL += "select '" + Request["F_tscode"] + "','" + Request["F_cust_area"] + "','" + Request["F_cust_seq"] + "','" + (i + 1) + "'";
                SQL += ",ROW_NUMBER() OVER(ORDER BY show_sqlno),show_date,show_name,getdate()";
                SQL += ",'" + Session["scode"] + "','" + mark + "' ";
                SQL += "from casedmt_show where in_no='" + RSno + "' and case_sqlno=" + dt.Rows[i]["case_sqlno"] + " order by show_sqlno";
                conn1.ExecuteNonQuery(SQL);
            }
            conn1.Commit();
            //conn1.RollBack();
        }
    }
    
    /// <summary>
    /// 註冊費
    /// </summary>
    private void addA3(DBHelper conn,string RSno) {
        //寫入case_dmt
        insert_case_dmt(conn, RSno);

        //寫入dmt_temp
        insert_dmt_temp(conn, RSno);

        //寫入接洽費用檔
        insert_caseitem_dmt(conn, RSno);

        //寫入商品類別檔
        insert_casedmt_good(conn, RSno);

        //****新增展覽優先權資料
        insert_casedmt_show(conn, RSno, "0");

        //寫入交辦申請人檔
        insert_dmt_temp_ap(conn, RSno, "0");

        //*****新增文件上傳
        insert_dmt_attach(conn, RSno);

        //後續交辦作業，更新營洽官收確認紀錄檔grconf_dmt.job_no
        upd_grconf_job_no(conn, RSno);

        //更新客戶主檔最近立案日
        upd_dmt_date(conn, RSno);
    }
    
    /// <summary>
    /// 延展
    /// </summary>
    private void addA4(DBHelper conn, string RSno) {
        //寫入case_dmt
        insert_case_dmt(conn, RSno);

        //寫入dmt_temp
        insert_dmt_temp(conn, RSno);

        //寫入接洽費用檔
        insert_caseitem_dmt(conn, RSno);

        //寫入商品類別檔
        insert_casedmt_good(conn, RSno);

        //****新增展覽優先權資料
        insert_casedmt_show(conn, RSno, "0");

        //***異動檔
        ColMap.Clear();
        foreach (var key in Request.Form.Keys) {
            string colkey = key.ToString().ToLower();
            string colValue = Request[colkey];

            //取1~4碼
            if (colkey.Left(4) == "tfgp") {
                ColMap[colkey.Substring(5)] = Util.dbnull(colValue);
            }
        }

        //20161006因電子送件修改備註.2欄都可存檔(用|分隔)
        if ((Request["O_item"] ?? "") != "") {
            string sqlvalue = "";
            if ((Request["O_item"] ?? "").IndexOf("1") > -1) {
                if ((Request["O_item1"] ?? "") != "" || (Request["O_item2"] ?? "") != "") {
                    sqlvalue += "1," + Request["O_item1"] + ";" + Request["O_item2"];
                }
            }
            sqlvalue += "|";
            if ((Request["O_item"] ?? "").IndexOf("Z") > -1) {
                sqlvalue += "Z;ZZ," + Request["O_item2t"];
            }
            ColMap["other_item"] = Util.dbchar(sqlvalue);
        } else {
            ColMap["other_item"] = "null";
        }

        ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
        ColMap["in_no"] = "'" + RSno + "'";
        ColMap["tr_date"] = "getdate()";
        ColMap["tr_scode"] = "'" + Session["scode"] + "'";
        SQL = "insert into dmt_tran " + ColMap.GetInsertSQL();
        conn.ExecuteNonQuery(SQL);

        //寫入交辦申請人檔
        insert_dmt_temp_ap(conn, RSno, "0");

        //*****新增文件上傳
        insert_dmt_attach(conn, RSno);

        //*****異動明細
        if ((Request["tfgp_mod_dmt"] ?? "") == "Y") {//變更商標／標章名稱
            ColMap.Clear();
            ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
            ColMap["in_no"] = "'" + RSno + "'";
            ColMap["mod_field"] = "'mod_dmt'";
            ColMap["ncname1"] = Util.dbchar(Request["new_appl_name"]);

            SQL = "insert into dmt_tranlist " + ColMap.GetInsertSQL();
            conn.ExecuteNonQuery(SQL);
        }

        //後續交辦作業，更新營洽官收確認紀錄檔grconf_dmt.job_no
        upd_grconf_job_no(conn, RSno);

        //更新客戶主檔最近立案日
        upd_dmt_date(conn, RSno);
    }
    
    /// <summary>
    /// 分割
    /// </summary>
    private void addA5(DBHelper conn, string RSno) {
        //寫入case_dmt
        insert_case_dmt(conn, RSno);

        //寫入dmt_temp
        insert_dmt_temp(conn, RSno);

        //寫入接洽費用檔
        insert_caseitem_dmt(conn, RSno);

        //***異動檔
        ColMap.Clear();
        switch ((Request["tfy_arcase"] ?? "").Left(3)) {
            case "FD1":
                ColMap["other_item"] = Util.dbchar(Request["O_item11"] + ";" + Request["O_item12"] + ";" + Request["O_item13"]);
                break;
            case "FD2":
            case "FD3":
                ColMap["other_item"] = Util.dbchar(Request["O_item21"] + ";" + Request["O_item22"] + ";" + Request["O_item23"]);
                break;
        }
        ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
        ColMap["in_no"] = "'" + RSno + "'";
        ColMap["tr_date"] = "getdate()";
        ColMap["tr_scode"] = "'" + Session["scode"] + "'";
        ColMap["seq"] = Util.dbnull(Request["tfzb_seq"]);
        ColMap["seq1"] = Util.dbnull(Request["tfzb_seq1"]);
        SQL = "insert into dmt_tran " + ColMap.GetInsertSQL();
        conn.ExecuteNonQuery(SQL);

        //寫入商品類別檔
        insert_casedmt_good(conn, RSno);

        //****新增展覽優先權資料
        insert_casedmt_show(conn, RSno, "0");

        //寫入交辦申請人檔
        insert_dmt_temp_ap(conn, RSno, "0");

        //*****新增文件上傳
        insert_dmt_attach(conn, RSno);

        //件數
        for (int x = 1; x <= Convert.ToInt32("0" + Request["nfy_tot_num"]); x++) {
            ColMap.Clear();
            ColMap["in_no"] = Util.dbchar(RSno);
            ColMap["seq"] = Util.dbnull(Request["tfzb_seq"]);
            ColMap["seq1"] = Util.dbnull(Request["tfzb_seq1"]);
            ColMap["Cseq"] = Util.dbnull(Request["tfzb_seq"]);
            ColMap["Cseq1"] = Util.dbnull(Request["tfzb_seq1"]);
            SQL = "insert into case_dmt1 " + ColMap.GetInsertSQL();
            conn.ExecuteNonQuery(SQL);

            //抓insert後的流水號
            SQL = "SELECT SCOPE_IDENTITY() AS Current_Identity";
            object objResult1 = conn.ExecuteScalar(SQL);
            string case_sqlno = objResult1.ToString();

            //*****新增至案件檔
            ColMap.Clear();
            if ((Request["tfzb_seq"] ?? "") != "") ColMap["seq"] = Util.dbchar(Request["tfzb_seq"]);
            if ((Request["tfzb_seq1"] ?? "") != "") ColMap["seq1"] = Util.dbchar(Request["tfzb_seq1"]);
            if ((Request["tfzd_S_mark"] ?? "") != "") ColMap["s_mark"] = Util.dbchar(Request["tfzd_S_mark"]);
            if ((Request["tfzd_pul"] ?? "") != "") ColMap["pul"] = Util.dbchar(Request["tfzd_pul"]);
            if ((Request["tfzd_Appl_name"] ?? "") != "") ColMap["appl_name"] = Util.dbchar(Request["tfzd_Appl_name"]);
            if ((Request["tfzd_cappl_name"] ?? "") != "") ColMap["cappl_name"] = Util.dbchar(Request["tfzd_cappl_name"]);
            if ((Request["tfzd_eappl_name"] ?? "") != "") ColMap["eappl_name"] = Util.dbchar(Request["tfzd_eappl_name"]);
            if ((Request["tfzd_eappl_name1"] ?? "") != "") ColMap["eappl_name1"] = Util.dbchar(Request["tfzd_eappl_name1"]);
            if ((Request["tfzd_eappl_name2"] ?? "") != "") ColMap["eappl_name2"] = Util.dbchar(Request["tfzd_eappl_name2"]);
            if ((Request["tfzd_jappl_name"] ?? "") != "") ColMap["jappl_name"] = Util.dbchar(Request["tfzd_jappl_name"]);
            if ((Request["tfzd_jappl_name1"] ?? "") != "") ColMap["jappl_name1"] = Util.dbchar(Request["tfzd_jappl_name1"]);
            if ((Request["tfzd_jappl_name2"] ?? "") != "") ColMap["jappl_name2"] = Util.dbchar(Request["tfzd_jappl_name2"]);
            if ((Request["tfzd_zappl_name1"] ?? "") != "") ColMap["zappl_name1"] = Util.dbchar(Request["tfzd_zappl_name1"]);
            if ((Request["tfzd_zappl_name2"] ?? "") != "") ColMap["zappl_name2"] = Util.dbchar(Request["tfzd_zappl_name2"]);
            if ((Request["tfzd_zname_type"] ?? "") != "") ColMap["zname_type"] = Util.dbchar(Request["tfzd_zname_type"]);
            if ((Request["tfzd_oappl_name"] ?? "") != "") ColMap["oappl_name"] = Util.dbchar(Request["tfzd_oappl_name"]);
            if ((Request["tfzd_Draw"] ?? "") != "") ColMap["Draw"] = Util.dbchar(Request["tfzd_Draw"]);
            if ((Request["tfzd_symbol"] ?? "") != "") ColMap["symbol"] = Util.dbchar(Request["tfzd_symbol"]);
            if ((Request["tfzd_color"] ?? "") != "") ColMap["color"] = Util.dbchar(Request["tfzd_color"]);
            if ((Request["tfzd_agt_no"] ?? "") != "") ColMap["agt_no"] = Util.dbchar(Request["tfzd_agt_no"]);
            if ((Request["pfzd_prior_date"] ?? "") != "") ColMap["prior_date"] = Util.dbchar(Request["pfzd_prior_date"]);
            if ((Request["tfzd_prior_no"] ?? "") != "") ColMap["prior_no"] = Util.dbchar(Request["tfzd_prior_no"]);
            if ((Request["tfzd_prior_country"] ?? "") != "") ColMap["prior_country"] = Util.dbchar(Request["tfzd_prior_country"]);
            if ((Request["tfzd_ref_no"] ?? "") != "") ColMap["ref_no"] = Util.dbchar(Request["tfzd_ref_no"]);
            if ((Request["tfzd_ref_no1"] ?? "") != "") ColMap["ref_no1"] = Util.dbchar(Request["tfzd_ref_no1"]);
            if ((Request["tfzb_seq"] ?? "") != "") ColMap["Mseq"] = Util.dbchar(Request["tfzb_seq"]);
            if ((Request["tfzb_seq1"] ?? "") != "") ColMap["Mseq1"] = Util.dbchar(Request["tfzb_seq1"]);
            //2014/4/15增加寫入申請日，因分割子案申請日與母案相同
            if ((Request["tfzd_apply_date"] ?? "") != "") ColMap["apply_date"] = Util.dbchar(Request["tfzd_apply_date"]);
            switch ((Request["tfy_arcase"] ?? "").Left(3)) {
                case "FD1":
                    if ((Request["FD1_class_count_" + x] ?? "") != "") {
                        ColMap["class_type"] = Util.dbchar(Request["FD1_class_type_" + x]);
                        ColMap["class_count"] = Util.dbchar(Request["FD1_class_count_" + x]);
                        ColMap["class"] = Util.dbchar(Request["FD1_class_" + x]);
                    }
                    if ((Request["FD1_Marka_" + x] ?? "") != "") {
                        ColMap["mark"] = Util.dbchar(Request["FD1_Marka_" + x]);
                    }
                    //分割後子案之商標種類2
                    string s_mark2 = "";
                    if ((Request["tfy_div_arcase"] ?? "").Substring(2, 1).IN("1,5,H")) s_mark2 = "A";
                    else if ((Request["tfy_div_arcase"] ?? "").Substring(2, 1).IN("4,8,C,G")) s_mark2 = "B";
                    else if ((Request["tfy_div_arcase"] ?? "").Substring(2, 1).IN("3,7,B,F")) s_mark2 = "C";
                    else if ((Request["tfy_div_arcase"] ?? "").Substring(2, 1).IN("2,6,A,E")) s_mark2 = "D";
                    else if ((Request["tfy_div_arcase"] ?? "").Substring(2, 1).IN("I")) s_mark2 = "E";
                    else if ((Request["tfy_div_arcase"] ?? "").Substring(2, 1).IN("J")) s_mark2 = "F";
                    else if ((Request["tfy_div_arcase"] ?? "").Substring(2, 1).IN("K")) s_mark2 = "G";
                    else s_mark2 = "A";
                    
                    ColMap["s_mark2"] = Util.dbchar(s_mark2);
                    break;
                case "FD2":
                case "FD3":
                    if ((Request["FD2_class_count_" + x] ?? "") != "") {
                        ColMap["class_type"] = Util.dbchar(Request["FD2_class_type_" + x]);
                        ColMap["class_count"] = Util.dbchar(Request["FD2_class_count_" + x]);
                        ColMap["class"] = Util.dbchar(Request["FD2_class_" + x]);
                    }
                    if ((Request["FD2_Markb_" + x] ?? "") != "") {
                        ColMap["mark"] = Util.dbchar(Request["FD2_Markb_" + x]);
                    }
                    if ((Request["tfzd_s_mark2" + x] ?? "") != "") {
                        ColMap["s_mark2"] = Util.dbchar(Request["tfzd_s_mark2"]);
                    }
                    break;
            }
            ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
            ColMap["in_no"] = "'" + RSno + "'";
            ColMap["in_date"] = "'" + DateTime.Today.ToShortDateString() + "'";
            ColMap["draw_file"] = Util.dbchar(Sys.Path2Btbrt(drawFilename));
            ColMap["tr_date"] = "getdate()";
            ColMap["tr_scode"] = "'" + Session["scode"] + "'";
            ColMap["case_sqlno"] = case_sqlno;

            SQL = "insert into dmt_temp " + ColMap.GetInsertSQL();
            conn.ExecuteNonQuery(SQL);

            switch ((Request["tfy_arcase"] ?? "").Left(3)) {
                case "FD1":
                    //分割子案商品類別入檔
                    for (int p = 1; p <= Convert.ToInt32("0" + Request["FD1_class_count_" + x]); p++) {
                        if ((Request["classa_" + x + "_" + p] ?? "") != "" || (Request["FD1_good_namea_" + x + "_" + p] ?? "") != "") {
                            ColMap.Clear();
                            ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
                            ColMap["in_no"] = "'" + RSno + "'";
                            ColMap["case_sqlno"] = "'" + case_sqlno + "'";
                            ColMap["class"] = Util.dbchar(Request["classa_" + x + "_" + p]);
                            ColMap["dmt_goodname"] = Util.dbchar(Request["FD1_good_namea_" + x + "_" + p]);
                            ColMap["dmt_goodcount"] = Util.dbchar(Request["FD1_good_counta_" + x + "_" + p]);
                            ColMap["tr_date"] = "getdate()";
                            ColMap["tr_scode"] = "'" + Session["scode"] + "'";

                            SQL = "insert into casedmt_good " + ColMap.GetInsertSQL();
                            //Response.Write(SQL + "<HR>");
                            conn.ExecuteNonQuery(SQL);
                        }
                    }
                    //分割子案展覽優先權入檔
                    //分割後案性除FA9,FAA,FAB,FAC外(因所列案性無展覽優先權)，再依母案展覽優先權資料入檔
                    if ((Request["tfy_div_arcase"] ?? "").Left(3) != "FA9" && (Request["tfy_div_arcase"] ?? "").Left(3) != "FAA"
                    && (Request["tfy_div_arcase"] ?? "").Left(3) != "FAB" && (Request["tfy_div_arcase"] ?? "").Left(3) != "FAC") {
                        //分割子案展覽優先權入檔
                        insert_casedmt_show(conn, RSno, case_sqlno);
                    }
                    break;
                case "FD2":
                case "FD3":
                    //分割子案商品類別入檔
                    for (int p = 1; p <= Convert.ToInt32("0" + Request["FD2_class_count_" + x]); p++) {
                        if ((Request["classb_" + x + "_" + p] ?? "") != "" || (Request["FD2_good_nameb_" + x + "_" + p] ?? "") != "") {
                            ColMap.Clear();
                            ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
                            ColMap["in_no"] = "'" + RSno + "'";
                            ColMap["case_sqlno"] = "'" + case_sqlno + "'";
                            ColMap["class"] = Util.dbchar(Request["classb_" + x + "_" + p]);
                            ColMap["dmt_goodname"] = Util.dbchar(Request["FD2_good_nameb_" + x + "_" + p]);
                            ColMap["dmt_goodcount"] = Util.dbchar(Request["FD2_good_countb_" + x + "_" + p]);
                            ColMap["tr_date"] = "getdate()";
                            ColMap["tr_scode"] = "'" + Session["scode"] + "'";

                            SQL = "insert into casedmt_good " + ColMap.GetInsertSQL();
                            //Response.Write(SQL + "<HR>");
                            conn.ExecuteNonQuery(SQL);
                        }
                    }
                    //分割子案展覽優先權入檔
                    insert_casedmt_show(conn, RSno, case_sqlno);
                    break;
            }
            //分割子案申請人入檔	
            insert_dmt_temp_ap(conn, RSno, case_sqlno);
        }

        //後續交辦作業，更新營洽官收確認紀錄檔grconf_dmt.job_no
        upd_grconf_job_no(conn, RSno);

        //更新客戶主檔最近立案日
        upd_dmt_date(conn, RSno);
    }

    /// <summary>
    /// 變更
    /// </summary>
    private void addA6(DBHelper conn, string RSno) {
        //重建暫存檔
        //rebuil_change(RSno,"C");

        //寫入case_dmt
        insert_case_dmt(conn, RSno);

        if ((Request["tfy_arcase"] ?? "") == "FC11" || (Request["tfy_arcase"] ?? "") == "FC5" || (Request["tfy_arcase"] ?? "") == "FC7" || (Request["tfy_arcase"] ?? "") == "FCH") {
            for (int i = 2; i <= Convert.ToInt32("0" + Request["nfy_tot_num"]); i++) {
                ColMap.Clear();
                ColMap["in_no"] = Util.dbchar(RSno);
                ColMap["seq"] = Util.dbnull(Request["dseqa_" + i]);
                ColMap["seq1"] = Util.dbnull(Request["dseq1a_" + i]);
                ColMap["Cseq"] = Util.dbnull(Request["dseqa_" + i]);
                ColMap["Cseq1"] = Util.dbnull(Request["dseq1a_" + i]);
                ColMap["case_stat1"] = ((Request["dseqa_" + i] ?? "") != "" ? "'OO'" : "'NN'");
                SQL = "insert into case_dmt1 " + ColMap.GetInsertSQL();
                conn.ExecuteNonQuery(SQL);

                //抓insert後的流水號
                SQL = "SELECT SCOPE_IDENTITY() AS Current_Identity";
                object objResult1 = conn.ExecuteScalar(SQL);
                string case_sqlno = objResult1.ToString();

                if ((Request["dseqa_" + i] ?? "") == "") {
                    //抓圖檔
                    SQL = "SELECT draw_file FROM dmt_temp_change where in_scode='" + Request["F_tscode"] + "' and cust_area='" + Request["F_cust_area"] + "' and cust_seq='" + Request["F_cust_seq"] + "' and num='" + i + "' and (mark='C' or mark is null) ";
                    object objResult2 = conn.ExecuteScalar(SQL);
                    if (objResult2 != null) {
                        string draw_file = objResult2.ToString();
                        //將檔案更改檔名
                        string newfilename = move_file(RSno, draw_file, "-FC" + i);

                        SQL = "insert into dmt_temp(s_mark,s_mark2,pul,apsqlno,ap_cname,ap_cname1,ap_cname2 ";
                        SQL += ",ap_ename,ap_ename1,ap_ename2,appl_name,cappl_name,eappl_name";
                        SQL += ",eappl_name1,eappl_name2,jappl_name,jappl_name1,jappl_name2,zappl_name1 ";
                        SQL += ",zappl_name2,zname_type,oappl_name,Draw,symbol,color,agt_no,prior_date,prior_no ";
                        SQL += ",prior_country,ref_no,ref_no1,tcn_ref,tcn_class,tcn_name,tcn_mark ";
                        SQL += ",apply_date,apply_no,issue_date,issue_no,open_date,rej_no,end_date ";
                        SQL += ",end_code,dmt_term1,dmt_term2,renewal,class_type,class_count,class ";
                        SQL += ",in_scode,in_no,in_date,draw_file,tr_date,tr_scode,case_sqlno,seq1) ";
                        SQL += "Select s_mark,s_mark2 as ts_mark,pul," + Util.dbnull(Request["tfzp_apsqlno"]) + " ";
                        SQL += "," + Util.dbnull(Request["tfzp_ap_cname"]) + "," + Util.dbnull(Request["tfzp_ap_cname1"]) + " ";
                        SQL += "," + Util.dbnull(Request["tfzp_ap_cname2"]) + "," + Util.dbnull(Request["tfzp_ap_ename"]) + " ";
                        SQL += "," + Util.dbnull(Request["tfzp_ap_ename1"]) + "," + Util.dbnull(Request["tfzp_ap_ename2"]) + " ";
                        SQL += ",appl_name,cappl_name,eappl_name ";
                        SQL += ",eappl_name1,eappl_name2,jappl_name,jappl_name1,jappl_name2,zappl_name1 ";
                        SQL += ",zappl_name2,zname_type,oappl_name,Draw,symbol,color ";
                        SQL += "," + Util.dbnull(Request["tfzd_agt_no"]) + ",prior_date,prior_no ";
                        SQL += ",prior_country,ref_no,ref_no1,tcn_ref,tcn_class,tcn_name,tcn_mark ";
                        SQL += ",apply_date,apply_no,issue_date,issue_no,open_date,rej_no,end_date ";
                        SQL += ",end_code,dmt_term1,dmt_term2,renewal,class_type,class_count,class ";
                        SQL += ",'" + Request["F_tscode"] + "','" + RSno + "','" + DateTime.Today.ToShortDateString() + "','" + newfilename + "' ";
                        SQL += ",getdate(),'" + Session["scode"] + "'," + case_sqlno + ",'" + Request["dseq1a_" + i] + "' ";
                        SQL += "from dmt_temp_change where in_scode='" + Request["F_tscode"] + "' ";
                        SQL += "and cust_area='" + Request["F_cust_area"] + "' and cust_seq='" + Request["F_cust_seq"] + "' ";
                        SQL += "and num='" + i + "' and (mark='C' or mark is null)";
                        conn.ExecuteNonQuery(SQL);

                        //*****新增申請人檔
                        insert_dmt_temp_ap_FC2(conn, RSno, case_sqlno);
                    }

                    //商品類別
                    SQL = "INSERT INTO casedmt_good(in_scode,in_no,case_sqlno,class,dmt_grp_code";
                    SQL += ",dmt_goodname,dmt_goodcount,tr_date,tr_scode) ";
                    SQL += "select '" + Request["F_tscode"] + "','" + RSno + "'," + case_sqlno + ",class,dmt_grp_code,dmt_goodname,dmt_goodcount";
                    SQL += ",getdate(),'" + Session["scode"] + "' ";
                    SQL += "from casedmt_good_change where in_scode='" + Request["F_tscode"] + "' ";
                    SQL += "and cust_area='" + Request["F_cust_area"] + "' and cust_seq='" + Request["F_cust_seq"] + "' ";
                    SQL += "and num='" + i + "' and (mark='C' or mark is null) and (isnull(class,'')<>'' or isnull(dmt_goodname,'')<>'')";
                    conn.ExecuteNonQuery(SQL);

                    //展覽會優先權
                    SQL = "INSERT INTO casedmt_show(in_no,case_sqlno,show_date,show_name,tr_date,tr_scode) ";
                    SQL += "select '" + RSno + "'," + case_sqlno + ",show_date,show_name,getdate()'";
                    SQL += ",'" + Session["scode"] + "' ";
                    SQL += "from casedmt_show_change where in_scode='" + Request["F_tscode"] + "' ";
                    SQL += "and cust_area='" + Request["F_cust_area"] + "' and cust_seq='" + Request["F_cust_seq"] + "' ";
                    SQL += "and num='" + i + "' and (mark='C' or mark is null) order by show_no ";
                    conn.ExecuteNonQuery(SQL);
                }
            }

            //清空暫存檔
            SQL = "delete from dmt_temp_change where in_scode='" + Request["F_tscode"] + "' and cust_area='" + Request["F_cust_area"] + "' and cust_seq='" + Request["F_cust_seq"] + "' and (mark='C' or mark is null)";
            conn.ExecuteNonQuery(SQL);
            SQL = "delete from casedmt_good_change where in_scode='" + Request["F_tscode"] + "' and cust_area='" + Request["F_cust_area"] + "' and cust_seq='" + Request["F_cust_seq"] + "' and (mark='C' or mark is null)";
            conn.ExecuteNonQuery(SQL);
            SQL = "delete from casedmt_show_change where in_scode='" + Request["F_tscode"] + "' and cust_area='" + Request["F_cust_area"] + "' and cust_seq='" + Request["F_cust_seq"] + "' and (mark='C' or mark is null)";
            conn.ExecuteNonQuery(SQL);
        } else if ((Request["tfy_arcase"] ?? "") == "FC21" || (Request["tfy_arcase"] ?? "") == "FC6" || (Request["tfy_arcase"] ?? "") == "FC8" || (Request["tfy_arcase"] ?? "") == "FCI") {
            for (int i = 2; i <= Convert.ToInt32("0" + Request["nfy_tot_num"]); i++) {
                ColMap.Clear();
                ColMap["in_no"] = Util.dbchar(RSno);
                ColMap["seq"] = Util.dbnull(Request["dseqb_" + i]);
                ColMap["seq1"] = Util.dbnull(Request["dseq1b_" + i]);
                ColMap["Cseq"] = Util.dbnull(Request["dseqb_" + i]);
                ColMap["Cseq1"] = Util.dbnull(Request["dseq1b_" + i]);
                ColMap["case_stat1"] = ((Request["dseqb_" + i] ?? "") != "" ? "'OO'" : "'NN'");
                SQL = "insert into case_dmt1 " + ColMap.GetInsertSQL();
                conn.ExecuteNonQuery(SQL);

                //抓insert後的流水號
                SQL = "SELECT SCOPE_IDENTITY() AS Current_Identity";
                object objResult1 = conn.ExecuteScalar(SQL);
                string case_sqlno = objResult1.ToString();

                if ((Request["dseqb_" + i] ?? "") == "") {
                    //抓圖檔
                    SQL = "SELECT draw_file FROM dmt_temp_change where in_scode='" + Request["F_tscode"] + "' and cust_area='" + Request["F_cust_area"] + "' and cust_seq='" + Request["F_cust_seq"] + "' and num='" + i + "' and (mark='C' or mark is null)";
                    object objResult2 = conn.ExecuteScalar(SQL);

                    if (objResult2 != null) {
                        string draw_file = objResult2.ToString();
                        //將檔案更改檔名
                        string newfilename = move_file(RSno, draw_file, "-FC" + i);

                        SQL = "insert into dmt_temp(s_mark,s_mark2,pul,apsqlno,ap_cname,ap_cname1,ap_cname2 ";
                        SQL += ",ap_ename,ap_ename1,ap_ename2,appl_name,cappl_name,eappl_name";
                        SQL += ",eappl_name1,eappl_name2,jappl_name,jappl_name1,jappl_name2,zappl_name1 ";
                        SQL += ",zappl_name2,zname_type,oappl_name,Draw,symbol,color,agt_no,prior_date,prior_no ";
                        SQL += ",prior_country,ref_no,ref_no1,tcn_ref,tcn_class,tcn_name,tcn_mark ";
                        SQL += ",apply_date,apply_no,issue_date,issue_no,open_date,rej_no,end_date ";
                        SQL += ",end_code,dmt_term1,dmt_term2,renewal,class_type,class_count,class ";
                        SQL += ",in_scode,in_no,in_date,draw_file,tr_date,tr_scode,case_sqlno,seq1) ";
                        SQL += "Select s_mark,s_mark2 as ts_mark,pul," + Util.dbnull(Request["tfzp_apsqlno"]) + " ";
                        SQL += "," + Util.dbnull(Request["tfzp_ap_cname"]) + "," + Util.dbnull(Request["tfzp_ap_cname1"]) + " ";
                        SQL += "," + Util.dbnull(Request["tfzp_ap_cname2"]) + "," + Util.dbnull(Request["tfzp_ap_ename"]) + " ";
                        SQL += "," + Util.dbnull(Request["tfzp_ap_ename1"]) + "," + Util.dbnull(Request["tfzp_ap_ename2"]) + " ";
                        SQL += ",appl_name,cappl_name,eappl_name ";
                        SQL += ",eappl_name1,eappl_name2,jappl_name,jappl_name1,jappl_name2,zappl_name1 ";
                        SQL += ",zappl_name2,zname_type,oappl_name,Draw,symbol,color ";
                        SQL += "," + Util.dbnull(Request["tfzd_agt_no"]) + ",prior_date,prior_no ";
                        SQL += ",prior_country,ref_no,ref_no1,tcn_ref,tcn_class,tcn_name,tcn_mark ";
                        SQL += ",apply_date,apply_no,issue_date,issue_no,open_date,rej_no,end_date ";
                        SQL += ",end_code,dmt_term1,dmt_term2,renewal,class_type,class_count,class ";
                        SQL += ",'" + Request["F_tscode"] + "','" + RSno + "','" + DateTime.Today.ToShortDateString() + "','" + newfilename + "' ";
                        SQL += ",getdate(),'" + Session["scode"] + "'," + case_sqlno + ",'" + Request["dseq1b_" + i] + "' ";
                        SQL += "from dmt_temp_change where in_scode='" + Request["F_tscode"] + "' ";
                        SQL += "and cust_area='" + Request["F_cust_area"] + "' and cust_seq='" + Request["F_cust_seq"] + "' ";
                        SQL += "and num='" + i + "' and (mark='C' or mark is null) ";
                        conn.ExecuteNonQuery(SQL);

                        //寫入交辦申請人檔
                        insert_dmt_temp_ap_FC0(conn, RSno, case_sqlno);
                    }

                    //商品類別
                    SQL = "INSERT INTO casedmt_good(in_scode,in_no,case_sqlno,class,dmt_grp_code";
                    SQL += ",dmt_goodname,dmt_goodcount,tr_date,tr_scode) ";
                    SQL += "select '" + Request["F_tscode"] + "','" + RSno + "'," + case_sqlno + ",class,dmt_grp_code,dmt_goodname,dmt_goodcount";
                    SQL += ",getdate(),'" + Session["scode"] + "' ";
                    SQL += "from casedmt_good_change where in_scode='" + Request["F_tscode"] + "' ";
                    SQL += "and cust_area='" + Request["F_cust_area"] + "' and cust_seq='" + Request["F_cust_seq"] + "' ";
                    SQL += "and num='" + i + "' and (mark='C' or mark is null) and (isnull(class,'')<>'' or isnull(dmt_goodname,'')<>'')";
                    conn.ExecuteNonQuery(SQL);

                    //展覽會優先權
                    SQL = "INSERT INTO casedmt_show(in_no,case_sqlno,show_date,show_name,tr_date,tr_scode) ";
                    SQL += "select '" + RSno + "'," + case_sqlno + ",show_date,show_name,getdate()'";
                    SQL += ",'" + Session["scode"] + "' ";
                    SQL += "from casedmt_show_change where in_scode='" + Request["F_tscode"] + "' ";
                    SQL += "and cust_area='" + Request["F_cust_area"] + "' and cust_seq='" + Request["F_cust_seq"] + "' ";
                    SQL += "and num='" + i + "' and (mark='C' or mark is null) order by show_no ";
                    conn.ExecuteNonQuery(SQL);
                }
            }

            //清空暫存檔
            SQL = "delete from dmt_temp_change where in_scode='" + Request["F_tscode"] + "' and cust_area='" + Request["F_cust_area"] + "' and cust_seq='" + Request["F_cust_seq"] + "' and (mark='C' or mark is null)";
            conn.ExecuteNonQuery(SQL);
            SQL = "delete from casedmt_good_change where in_scode='" + Request["F_tscode"] + "' and cust_area='" + Request["F_cust_area"] + "' and cust_seq='" + Request["F_cust_seq"] + "' and (mark='C' or mark is null)";
            conn.ExecuteNonQuery(SQL);
            SQL = "delete from casedmt_show_change where in_scode='" + Request["F_tscode"] + "' and cust_area='" + Request["F_cust_area"] + "' and cust_seq='" + Request["F_cust_seq"] + "' and (mark='C' or mark is null)";
            conn.ExecuteNonQuery(SQL);
        }

        //寫入接洽費用檔
        insert_caseitem_dmt(conn, RSno);

        //寫入dmt_temp
        insert_dmt_temp(conn, RSno);

        //寫入商品類別檔
        insert_casedmt_good(conn, RSno);

        //****新增展覽優先權資料
        insert_casedmt_show(conn, RSno, "0");

        //*****新增案件變更檔
        switch ((Request["tfy_arcase"] ?? "")) {
            case "FC1": case "FC10": case "FC11": case "FC5": case "FC7": case "FC9": case "FCA": case "FCB": case "FCF": case "FCH":
                ColMap.Clear();
                foreach (var key in Request.Form.Keys) {
                    string colkey = key.ToString().ToLower();
                    string colValue = Request[colkey];

                    //取1~4碼
                    if (colkey.Left(4) == "tfg1") {
                        ColMap[colkey.Substring(5)] = Util.dbnull(colValue);
                    }
                }
                ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
                ColMap["in_no"] = "'" + RSno + "'";
                ColMap["tr_date"] = "getdate()";
                ColMap["tr_scode"] = "'" + Session["scode"] + "'";
                ColMap["seq"] = Util.dbnull(Request["tfzb_seq"]);
                ColMap["seq1"] = Util.dbchar(Request["tfzb_seq1"]);
                SQL = "insert into dmt_tran " + ColMap.GetInsertSQL();
                conn.ExecuteNonQuery(SQL);

                //*****變更申請人(原申請人)(apcust_FC_RE1_form)
                if ((Request["tfg1_mod_ap"] ?? "") == "Y") {
                    for (int k = 1; k <= Convert.ToInt32("0" + Request["FC1_apnum"]); k++) {
                        SQL = "insert into dmt_tranlist(in_scode,in_no,mod_field,old_no,ocname1,ocname2,oename1,oename2) values (";
                        SQL += "'" + Request["F_tscode"] + "','" + RSno + "','mod_ap'";
                        SQL += "," + Util.dbchar(Request["tft1_old_no_" + k]) + "," + Util.dbchar(Request["tft1_ocname1_" + k]) + "";
                        SQL += "," + Util.dbchar(Request["tft1_ocname2_" + k]) + "," + Util.dbchar(Request["tft1_oename1_" + k]) + "";
                        SQL += "," + Util.dbchar(Request["tft1_oename2_" + k]) + ")";
                        conn.ExecuteNonQuery(SQL);
                    }
                }

                //*****變更註冊申請案號數
                if ((Request["tfy_arcase"] ?? "").IN("FC1,FC10,FC9,FCA,FCB,FCF")) {
                    for (int k = 1; k <= Convert.ToInt32("0" + Request["tft1_mod_count11"]); k++) {
                        SQL = "insert into dmt_tranlist(in_scode,in_no,mod_field,mod_count,new_no,ncname1) values (";
                        SQL += "'" + Request["F_tscode"] + "','" + RSno + "','mod_tcnref'";
                        SQL += "," + Util.dbchar(Request["tft1_mod_count11"]) + "," + Util.dbchar(Request["new_no1" + k]) + "";
                        SQL += "," + Util.dbchar(Request["ncname11" + k]) + ")";
                        conn.ExecuteNonQuery(SQL);
                    }
                }

                //*****增加代理人	 
                if ((Request["tfy_arcase"] ?? "") == "FCA") {
                    SQL = "insert into dmt_tranlist(in_scode,in_no,mod_field,new_no) values (";
                    SQL += "'" + Request["F_tscode"] + "','" + RSno + "','mod_agt'";
                    SQL += "," + Util.dbchar(Request["FC1_add_agt_no"]) + ")";
                    conn.ExecuteNonQuery(SQL);
                }

                //*****新增申請人檔
                insert_dmt_temp_ap_FC2(conn, RSno, "0");
                break;
            case "FC2": case "FC20": case "FC21": case "FC0": case "FC6": case "FC8": case "FCC": case "FCD": case "FCG": case "FCI":
                ColMap.Clear();
                foreach (var key in Request.Form.Keys) {
                    string colkey = key.ToString().ToLower();
                    string colValue = Request[colkey];

                    //取1~4碼
                    if (colkey.Left(4) == "tfg2") {
                        ColMap[colkey.Substring(5)] = Util.dbnull(colValue);
                    }
                }

                if ((Request["tfy_arcase"] ?? "").IN("FC21,FC6,FCI")) {
                    if ((Request["O_item211"] ?? "") != "" || (Request["O_item221"] ?? "") != "") {
                        ColMap["other_item"] = Util.dbchar(Request["O_item211"] + ";" + Request["O_item221"] + ";" + Request["O_item231"]);
                    }
                } else {
                    if ((Request["O_item21"] ?? "") != "" || (Request["O_item22"] ?? "") != "") {
                        ColMap["other_item"] = Util.dbchar(Request["O_item21"] + ";" + Request["O_item22"] + ";" + Request["O_item23"]);
                    }
                }
                //2012/7/1新申請書增加修正使用規費書及質權移轉原因
                if ((Request["tfy_arcase"] ?? "") == "FC2") {
                    if ((Request["tfop_oitem1"] ?? "") == "Y") {
                        ColMap["other_item1"] = Util.dbchar("Y," + Request["tfop_oitem1c"]);
                    }
                    if ((Request["tfop_oitem2"] ?? "") == "Y") {
                        ColMap["other_item2"] = Util.dbchar("Y," + Request["tfop_oitem2c"]);
                    }
                } else {
                    if ((Request["tfop1_oitem1"] ?? "") == "Y") {
                        ColMap["other_item1"] = Util.dbchar("Y," + Request["tfop1_oitem1c"]);
                    }
                    if ((Request["tfop1_oitem2"] ?? "") == "Y") {
                        ColMap["other_item2"] = Util.dbchar("Y," + Request["tfop1_oitem2c"]);
                    }
                }
                ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
                ColMap["in_no"] = "'" + RSno + "'";
                ColMap["tr_date"] = "getdate()";
                ColMap["tr_scode"] = "'" + Session["scode"] + "'";
                ColMap["seq"] = Util.dbnull(Request["tfzb_seq"]);
                ColMap["seq1"] = Util.dbchar(Request["tfzb_seq1"]);
                SQL = "insert into dmt_tran " + ColMap.GetInsertSQL();
                conn.ExecuteNonQuery(SQL);

                //*****變更申請人
                if ((Request["tfg2_mod_ap"] ?? "") != "") {
                    for (int i = 1; i <= Convert.ToInt32("0" + Request["FC0_apnum"]); i++) {
                        ColMap.Clear();
                        ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
                        ColMap["in_no"] = "'" + RSno + "'";
                        ColMap["mod_field"] = "'mod_ap'";
                        ColMap["new_no"] = Util.dbchar(Request["dbmn_new_no_" + i]);
                        if ((Request["tfg2_mod_ap"] ?? "").Substring(1, 1) == "Y") {
                            ColMap["ncname1"] = Util.dbchar(Request["dbmn_ncname1_" + i]);
                            ColMap["ncname2"] = Util.dbchar(Request["dbmn_ncname2_" + i]);
                        }
                        if ((Request["tfg2_mod_ap"] ?? "").Substring(2, 1) == "Y") {
                            ColMap["nename1"] = Util.dbchar(Request["dbmn_nename1_" + i]);
                            ColMap["nename2"] = Util.dbchar(Request["dbmn_nename2_" + i]);
                        }

                        SQL = "insert into dmt_tranlist " + ColMap.GetInsertSQL();
                        conn.ExecuteNonQuery(SQL);
                    }
                }

                //*****變更申請人地址
                if ((Request["tfg2_mod_apaddr"] ?? "") != "") {
                    for (int i = 1; i <= Convert.ToInt32("0" + Request["FC0_apnum"]); i++) {
                        ColMap.Clear();
                        ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
                        ColMap["in_no"] = "'" + RSno + "'";
                        ColMap["mod_field"] = "'mod_apaddr'";
                        ColMap["new_no"] = Util.dbchar(Request["dbmn_new_no_" + i]);
                        if ((Request["tfg2_mod_apaddr"] ?? "").Substring(0, 1) == "Y") {
                            ColMap["nzip"] = Util.dbchar(Request["dbmn_nzip_" + i]);
                            ColMap["naddr1"] = Util.dbchar(Request["dbmn_naddr1_" + i]);
                            ColMap["naddr2"] = Util.dbchar(Request["dbmn_naddr2_" + i]);
                        }
                        if ((Request["tfg2_mod_apaddr"] ?? "").Substring(1, 1) == "Y") {
                            ColMap["neaddr1"] = Util.dbchar(Request["dbmn_neaddr1_" + i]);
                            ColMap["neaddr2"] = Util.dbchar(Request["dbmn_neaddr2_" + i]);
                            ColMap["neaddr3"] = Util.dbchar(Request["dbmn_neaddr3_" + i]);
                            ColMap["neaddr4"] = Util.dbchar(Request["dbmn_neaddr4_" + i]);
                        }

                        SQL = "insert into dmt_tranlist " + ColMap.GetInsertSQL();
                        conn.ExecuteNonQuery(SQL);
                    }
                }

                //*****變更代表人
                if ((Request["tfg2_mod_aprep"] ?? "") != "") {
                    for (int i = 1; i <= Convert.ToInt32("0" + Request["FC0_apnum"]); i++) {
                        ColMap.Clear();
                        ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
                        ColMap["in_no"] = "'" + RSno + "'";
                        ColMap["mod_field"] = "'mod_aprep'";
                        ColMap["new_no"] = Util.dbchar(Request["dbmn_new_no_" + i]);
                        if ((Request["tfg2_mod_aprep"] ?? "").Substring(0, 1) == "Y") {
                            ColMap["ncrep"] = Util.dbchar(Request["dbmn_ncrep_" + i]);
                        }
                        if ((Request["tfg2_mod_aprep"] ?? "").Substring(1, 1) == "Y") {
                            ColMap["nerep"] = Util.dbchar(Request["dbmn_nerep_" + i]);
                        }

                        SQL = "insert into dmt_tranlist " + ColMap.GetInsertSQL();
                        conn.ExecuteNonQuery(SQL);
                    }
                }

                //*****其他變更事項1
                if ((Request["tfg2_mod_dmt"] ?? "") == "Y") {
                    ColMap.Clear();
                    ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
                    ColMap["in_no"] = "'" + RSno + "'";
                    ColMap["mod_field"] = "'mod_dmt'";
                    if ((Request["tfy_arcase"] ?? "").IN("FC21,FC6,FC8,FCI")) {
                        ColMap["ncname1"] = Util.dbchar(Request["ttg21_ncname1"]);
                    } else {
                        ColMap["ncname1"] = Util.dbchar(Request["ttg2_ncname1"]);
                    }
                    SQL = "insert into dmt_tranlist " + ColMap.GetInsertSQL();
                    conn.ExecuteNonQuery(SQL);
                }

                //*****其他變更事項2
                if ((Request["tfg2_mod_claim1"] ?? "") == "Y") {
                    ColMap.Clear();
                    ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
                    ColMap["in_no"] = "'" + RSno + "'";
                    ColMap["mod_field"] = "'mod_claim1'";
                    if ((Request["tfy_arcase"] ?? "").IN("FC21,FC6,FC8,FCI")) {
                        ColMap["ncname1"] = Util.dbchar(Request["ttg21_ncname2"]);
                    } else {
                        ColMap["ncname1"] = Util.dbchar(Request["ttg2_ncname2"]);
                    }
                    SQL = "insert into dmt_tranlist " + ColMap.GetInsertSQL();
                    conn.ExecuteNonQuery(SQL);
                }

                //*****變更註冊申請案號數
                if ((Request["tfy_arcase"] ?? "").IN("FC2,FC20,FC0,FCC,FCD,FCG")) {
                    if ((Request["tft2_mod_count2"] ?? "") != "") {
                        ColMap.Clear();
                        ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
                        ColMap["in_no"] = "'" + RSno + "'";
                        ColMap["mod_field"] = "'mod_tcnref'";
                        ColMap["mod_count"] = Util.dbchar(Request["tft2_mod_count2"]);
                        ColMap["new_no"] = Util.dbchar(Request["new_no21"]);
                        ColMap["ncname1"] = Util.dbchar(Request["ncname121"]);

                        SQL = "insert into dmt_tranlist " + ColMap.GetInsertSQL();
                        conn.ExecuteNonQuery(SQL);
                    }
                }

                //'*****變更註冊申請案號數
                for (int j = 1; j <= 5; j++) {
                    if ((Request["tft2_mod_count2" + j] ?? "") != "") {
                        for (int i = 1; i <= Convert.ToInt32("0" + Request["tft2_mod_count2" + j]); i++) {
                            ColMap.Clear();
                            ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
                            ColMap["in_no"] = "'" + RSno + "'";
                            ColMap["mod_field"] = "'mod_tcnref'";
                            ColMap["mod_type"] = Util.dbchar(Request["tft2_mod_type_" + j]);
                            ColMap["mod_count"] = Util.dbchar(Request["tft2_mod_count2_" + j]);
                            ColMap["new_no"] = Util.dbchar(Request["new_no2_" + j + "_" + i]);
                            ColMap["ncname1"] = Util.dbchar(Request["ncname12_" + j + "_" + i]);

                            SQL = "insert into dmt_tranlist " + ColMap.GetInsertSQL();
                            conn.ExecuteNonQuery(SQL);
                        }
                    }
                }

                //*****新增代理人
                if ((Request["tfy_arcase"] ?? "") == "FCC") {
                    ColMap.Clear();
                    ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
                    ColMap["in_no"] = "'" + RSno + "'";
                    ColMap["mod_field"] = "'mod_agt'";
                    ColMap["new_no"] = Util.dbchar(Request["FC2_add_agt_no"]);

                    SQL = "insert into dmt_tranlist " + ColMap.GetInsertSQL();
                    conn.ExecuteNonQuery(SQL);
                }

                //寫入交辦申請人檔
                insert_dmt_temp_ap_FC0(conn, RSno, "0");

                break;
            case "FC3":
                ColMap.Clear();
                foreach (var key in Request.Form.Keys) {
                    string colkey = key.ToString().ToLower();
                    string colValue = Request[colkey];

                    //取1~4碼
                    if (colkey.Left(4) == "tfg3") {
                        ColMap[colkey.Substring(5)] = Util.dbnull(colValue);
                    }
                }
                if ((Request["O_item31"] ?? "") != "" || (Request["O_item32"] ?? "") != "") {
                    ColMap["other_item"] = Util.dbchar(Request["O_item31"] + ";" + Request["O_item32"] + ";" + Request["O_item33"]);
                }
                ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
                ColMap["in_no"] = "'" + RSno + "'";
                ColMap["tr_date"] = "getdate()";
                ColMap["tr_scode"] = "'" + Session["scode"] + "'";
                ColMap["seq"] = Util.dbnull(Request["tfzb_seq"]);
                ColMap["seq1"] = Util.dbchar(Request["tfzb_seq1"]);
                SQL = "insert into dmt_tran " + ColMap.GetInsertSQL();
                conn.ExecuteNonQuery(SQL);

                //*****擬減縮商品(服務名稱)
                if ((Request["tfg3_mod_class"] ?? "") == "Y") {
                    for (int i = 1; i <= Convert.ToInt32("0" + Request["tft3_class_count1"]); i++) {
                        if ((Request["class31_" + i] ?? "") != "") {
                            ColMap.Clear();
                            ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
                            ColMap["in_no"] = "'" + RSno + "'";
                            ColMap["mod_field"] = "'mod_class'";
                            ColMap["mod_type"] = Util.dbchar(Request["tft3_mod_type"]);
                            ColMap["mod_dclass"] = Util.dbchar(Request["tft3_class1"]);
                            ColMap["mod_count"] = Util.dbchar(Request["tft3_class_count1"]);
                            ColMap["new_no"] = Util.dbchar(Request["class31_" + i]);
                            ColMap["list_remark"] = Util.dbchar(Request["good_name31_" + i]);

                            SQL = "insert into dmt_tranlist " + ColMap.GetInsertSQL();
                            conn.ExecuteNonQuery(SQL);
                        }
                    }
                }

                //*****新增案件申請人檔
                insert_dmt_temp_ap(conn, RSno, "0");

                break;
            case "FC4":
                ColMap.Clear();
                foreach (var key in Request.Form.Keys) {
                    string colkey = key.ToString().ToLower();
                    string colValue = Request[colkey];

                    //取1~4碼
                    if (colkey.Left(4) == "tfg4") {
                        ColMap[colkey.Substring(5)] = Util.dbnull(colValue);
                    }
                }
                ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
                ColMap["in_no"] = "'" + RSno + "'";
                ColMap["tr_date"] = "getdate()";
                ColMap["tr_scode"] = "'" + Session["scode"] + "'";
                ColMap["seq"] = Util.dbnull(Request["tfzb_seq"]);
                ColMap["seq1"] = Util.dbchar(Request["tfzb_seq1"]);
                SQL = "insert into dmt_tran " + ColMap.GetInsertSQL();
                conn.ExecuteNonQuery(SQL);

                //*****變更註冊申請案號數
                for (int k = 1; k <= Convert.ToInt32("0" + Request["tft4_mod_count41"]); k++) {
                    SQL = "insert into dmt_tranlist(in_scode,in_no,mod_field,mod_type,mod_count,new_no,ncname1) values (";
                    SQL += "'" + Request["F_tscode"] + "','" + RSno + "','mod_tcnref'";
                    SQL += "," + Util.dbchar(Request["tft4_mod_type"]) + "," + Util.dbchar(Request["tft4_mod_count41"]) + "";
                    SQL += "," + Util.dbchar(Request["new_no41_" + k]) + "," + Util.dbchar(Request["ncname141_" + k]) + ")";
                    conn.ExecuteNonQuery(SQL);
                }

                //*****新增案件申請人檔
                insert_dmt_temp_ap(conn, RSno, "0");

                break;
        }

        //*****新增文件上傳
        insert_dmt_attach(conn, RSno);

        //後續交辦作業，更新營洽官收確認紀錄檔grconf_dmt.job_no
        upd_grconf_job_no(conn, RSno);

        //更新客戶主檔最近立案日
        upd_dmt_date(conn, RSno);
    }

    /// <summary>
    /// 授權
    /// </summary>
    private void addA7(DBHelper conn, string RSno) {
        //重建暫存檔
        //rebuil_change(RSno, "L");

        //寫入case_dmt
        insert_case_dmt(conn, RSno);

        //寫入dmt_temp
        insert_dmt_temp(conn, RSno);

        //寫入接洽費用檔
        insert_caseitem_dmt(conn, RSno);

        //寫入商品類別檔
        insert_casedmt_good(conn, RSno);

        //****新增展覽優先權資料
        insert_casedmt_show(conn, RSno, "0");

        //*****新增案件移轉檔
        ColMap.Clear();
        foreach (var key in Request.Form.Keys) {
            string colkey = key.ToString().ToLower();
            string colValue = Request[colkey];

            //取1~4碼
            if (colkey.Left(4) == "tfg1") {
                ColMap[colkey.Substring(5)] = Util.dbnull(colValue);
            }
        }

        if ((Request["O_item1"] ?? "") != "" || (Request["O_item2"] ?? "") != "") {//附註
            ColMap["other_item"] = Util.dbchar(Request["O_item1"] + ";" + Request["O_item2"]);
        }

        if ((Request["other_item2"] ?? "") != "") {
            if ((Request["other_item2t"] ?? "") != "") {
                ColMap["other_item2"] = Util.dbchar(Request["other_item2"] + "," + Request["other_item2t"]);
            } else {
                ColMap["other_item2"] = Util.dbchar(Request["other_item2"]);
            }
        }
        ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
        ColMap["in_no"] = "'" + RSno + "'";
        ColMap["tr_date"] = "getdate()";
        ColMap["tr_scode"] = "'" + Session["scode"] + "'";
        SQL = "insert into dmt_tran " + ColMap.GetInsertSQL();
        conn.ExecuteNonQuery(SQL);

        //*****新增案件異動明細檔，關係人資料
        for (int i = 1; i <= Convert.ToInt32("0" + Request["fl_apnum"]); i++) {
            ColMap.Clear();
            ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
            ColMap["in_no"] = "'" + RSno + "'";
            ColMap["mod_field"] = "'mod_ap'";
            ColMap["old_no"] = Util.dbchar(Request["tfr_old_no_" + i]);
            ColMap["ocname1"] = Util.dbchar(Request["tfr_ocname1_" + i]);
            ColMap["ocname2"] = Util.dbchar(Request["tfr_ocname2_" + i]);
            ColMap["oename1"] = Util.dbchar(Request["tfr_oename1_" + i]);
            ColMap["oename2"] = Util.dbchar(Request["tfr_oename2_" + i]);
            ColMap["ocrep"] = Util.dbchar(Request["tfr_ocrep_" + i]);
            ColMap["oerep"] = Util.dbchar(Request["tfr_oerep_" + i]);
            ColMap["ozip"] = Util.dbchar(Request["tfr_ozip_" + i]);
            ColMap["oaddr1"] = Util.dbchar(Request["tfr_oaddr1_" + i]);
            ColMap["oaddr2"] = Util.dbchar(Request["tfr_oaddr2_" + i]);
            ColMap["oeaddr1"] = Util.dbchar(Request["tfr_oeaddr1_" + i]);
            ColMap["oeaddr2"] = Util.dbchar(Request["tfr_oeaddr2_" + i]);
            ColMap["oeaddr3"] = Util.dbchar(Request["tfr_oeaddr3_" + i]);
            ColMap["oeaddr4"] = Util.dbchar(Request["tfr_oeaddr4_" + i]);
            ColMap["otel0"] = Util.dbchar(Request["tfr_otel0_" + i]);
            ColMap["otel"] = Util.dbchar(Request["tfr_otel_" + i]);
            ColMap["otel1"] = Util.dbchar(Request["otel1_" + i]);
            ColMap["ofax"] = Util.dbchar(Request["ofax_" + i]);
            ColMap["oapclass"] = Util.dbchar(Request["tfr_oapclass_" + i]);
            ColMap["oap_country"] = Util.dbchar(Request["tfr_oap_country_" + i]);
            ColMap["tran_code"] = "'N'";

            SQL = "insert into dmt_tranlist " + ColMap.GetInsertSQL();
            conn.ExecuteNonQuery(SQL);
        }

        //*****新增案件異動明細檔	
        if ((Request["tfy_arcase"] ?? "") == "FL1" || (Request["tfy_arcase"] ?? "") == "FL5") {
            for (int x = 1; x <= Convert.ToInt32("0" + Request["num2"]); x++) {
                SQL = "INSERT INTO dmt_tranlist(in_scode,in_no,mod_field,mod_type,mod_count,mod_dclass,new_no,list_remark)";
                SQL += "VALUES('" + Request["F_tscode"] + "','" + RSno + "','mod_class'";
                SQL += "," + Util.dbchar(Request["tfl1_mod_type"]) + "," + Util.dbchar(Request["mod_count"]);
                SQL += "," + Util.dbchar(Request["mod_dclass"]) + "," + Util.dbchar(Request["new_no_" + x]);
                SQL += "," + Util.dbchar(Request["list_remark_" + x]) + ")";
                conn.ExecuteNonQuery(SQL);
            }
        } else if ((Request["tfy_arcase"] ?? "") == "FL2" || (Request["tfy_arcase"] ?? "") == "FL6") {
            for (int x = 1; x <= Convert.ToInt32("0" + Request["num2"]); x++) {
                SQL = "INSERT INTO dmt_tranlist(in_scode,in_no,mod_field,mod_type,mod_count,mod_dclass,new_no,list_remark)";
                SQL += "VALUES('" + Request["F_tscode"] + "','" + RSno + "','mod_class'";
                SQL += "," + Util.dbchar(Request["tfl1_mod_type"]) + "," + Util.dbchar(Request["mod_count"]);
                SQL += "," + Util.dbchar(Request["mod_dclass"]) + "," + Util.dbchar(Request["new_no_" + x]);
                SQL += "," + Util.dbchar(Request["list_remark_" + x]) + ")";
                conn.ExecuteNonQuery(SQL);
            }
            //商標權人資料
            for (int i = 1; i <= Convert.ToInt32("0" + Request["fl2_apnum"]); i++) {
                ColMap.Clear();
                ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
                ColMap["in_no"] = "'" + RSno + "'";
                ColMap["mod_field"] = "'mod_tap'";
                ColMap["new_no"] = Util.dbchar(Request["tfv_new_no_" + i]);
                ColMap["ncname1"] = Util.dbchar(Request["tfv_ncname1_" + i]);
                ColMap["ncname2"] = Util.dbchar(Request["tfv_ncname2_" + i]);
                ColMap["nename1"] = Util.dbchar(Request["tfv_nename1_" + i]);
                ColMap["nename2"] = Util.dbchar(Request["tfv_nename2_" + i]);
                ColMap["ncrep"] = Util.dbchar(Request["tfv_ncrep_" + i]);
                ColMap["nerep"] = Util.dbchar(Request["tfv_nerep_" + i]);
                ColMap["nzip"] = Util.dbchar(Request["tfv_nzip_" + i]);
                ColMap["naddr1"] = Util.dbchar(Request["tfv_naddr1_" + i]);
                ColMap["naddr2"] = Util.dbchar(Request["tfv_naddr2_" + i]);
                ColMap["neaddr1"] = Util.dbchar(Request["tfv_neaddr1_" + i]);
                ColMap["neaddr2"] = Util.dbchar(Request["tfv_neaddr2_" + i]);
                ColMap["neaddr3"] = Util.dbchar(Request["tfv_neaddr3_" + i]);
                ColMap["neaddr4"] = Util.dbchar(Request["tfv_neaddr4_" + i]);
                ColMap["ntel0"] = Util.dbchar(Request["tfv_ntel0_" + i]);
                ColMap["ntel"] = Util.dbchar(Request["tfv_ntel_" + i]);
                ColMap["ntel1"] = Util.dbchar(Request["tfv_ntel1_" + i]);
                ColMap["nfax"] = Util.dbchar(Request["tfv_nfax_" + i]);
                ColMap["napclass"] = Util.dbchar(Request["tfv_napclass_" + i]);
                ColMap["nap_country"] = Util.dbchar(Request["tfv_nap_country_" + i]);
                ColMap["tran_code"] = "'N'";

                SQL = "insert into dmt_tranlist " + ColMap.GetInsertSQL();
                conn.ExecuteNonQuery(SQL);
            }
        }
        //寫入交辦申請人檔
        insert_dmt_temp_ap(conn, RSno, "0");

        //*****新增文件上傳
        insert_dmt_attach(conn, RSno);

        //授權及被授權多件入檔	
        if ((Request["tfy_arcase"] ?? "") == "FL5" || (Request["tfy_arcase"] ?? "") == "FL6") {
            for (int i = 2; i <= Convert.ToInt32("0" + Request["nfy_tot_num"]); i++) {
                ColMap.Clear();
                ColMap["in_no"] = Util.dbchar(RSno);
                ColMap["seq"] = Util.dbnull(Request["dseqb_" + i]);
                ColMap["seq1"] = Util.dbnull(Request["dseq1b_" + i]);
                ColMap["Cseq"] = Util.dbnull(Request["dseqb_" + i]);
                ColMap["Cseq1"] = Util.dbnull(Request["dseq1b_" + i]);
                ColMap["case_stat1"] = ((Request["dseqb_" + i] ?? "") != "" ? "'OO'" : "'NN'");
                SQL = "insert into case_dmt1 " + ColMap.GetInsertSQL();
                conn.ExecuteNonQuery(SQL);

                //抓insert後的流水號
                SQL = "SELECT SCOPE_IDENTITY() AS Current_Identity";
                object objResult1 = conn.ExecuteScalar(SQL);
                string case_sqlno = objResult1.ToString();

                if ((Request["dseqb_" + i] ?? "") == "") {
                    //抓圖檔
                    SQL = "SELECT draw_file FROM dmt_temp_change where in_scode='" + Request["F_tscode"] + "' and cust_area='" + Request["F_cust_area"] + "' and cust_seq='" + Request["F_cust_seq"] + "' and num='" + i + "' and mark='L'";
                    object objResult2 = conn.ExecuteScalar(SQL);
                    if (objResult2 != null) {
                        string draw_file = objResult2.ToString();
                        //將檔案更改檔名
                        string newfilename = move_file(RSno, draw_file, "-FC" + i);

                        SQL = "insert into dmt_temp(s_mark,s_mark2,pul,apsqlno,ap_cname,ap_cname1,ap_cname2 ";
                        SQL += ",ap_ename,ap_ename1,ap_ename2,appl_name,cappl_name,eappl_name";
                        SQL += ",eappl_name1,eappl_name2,jappl_name,jappl_name1,jappl_name2,zappl_name1 ";
                        SQL += ",zappl_name2,zname_type,oappl_name,Draw,symbol,color,agt_no,prior_date,prior_no ";
                        SQL += ",prior_country,ref_no,ref_no1,tcn_ref,tcn_class,tcn_name,tcn_mark ";
                        SQL += ",apply_date,apply_no,issue_date,issue_no,open_date,rej_no,end_date ";
                        SQL += ",end_code,dmt_term1,dmt_term2,renewal,class_type,class_count,class ";
                        SQL += ",in_scode,in_no,in_date,draw_file,tr_date,tr_scode,case_sqlno,seq1) ";
                        SQL += "Select s_mark,s_mark2 as ts_mark,pul," + Util.dbnull(Request["tfzp_apsqlno"]) + " ";
                        SQL += "," + Util.dbnull(Request["tfzp_ap_cname"]) + "," + Util.dbnull(Request["tfzp_ap_cname1"]) + " ";
                        SQL += "," + Util.dbnull(Request["tfzp_ap_cname2"]) + "," + Util.dbnull(Request["tfzp_ap_ename"]) + " ";
                        SQL += "," + Util.dbnull(Request["tfzp_ap_ename1"]) + "," + Util.dbnull(Request["tfzp_ap_ename2"]) + " ";
                        SQL += ",appl_name,cappl_name,eappl_name ";
                        SQL += ",eappl_name1,eappl_name2,jappl_name,jappl_name1,jappl_name2,zappl_name1 ";
                        SQL += ",zappl_name2,zname_type,oappl_name,Draw,symbol,color ";
                        SQL += "," + Util.dbnull(Request["tfzd_agt_no"]) + ",prior_date,prior_no ";
                        SQL += ",prior_country,ref_no,ref_no1,tcn_ref,tcn_class,tcn_name,tcn_mark ";
                        SQL += ",apply_date,apply_no,issue_date,issue_no,open_date,rej_no,end_date ";
                        SQL += ",end_code,dmt_term1,dmt_term2,renewal,class_type,class_count,class ";
                        SQL += ",'" + Request["F_tscode"] + "','" + RSno + "','" + DateTime.Today.ToShortDateString() + "','" + newfilename + "' ";
                        SQL += ",getdate(),'" + Session["scode"] + "'," + case_sqlno + ",'" + Request["dseq1b_" + i] + "' ";
                        SQL += "from dmt_temp_change where in_scode='" + Request["F_tscode"] + "' ";
                        SQL += "and cust_area='" + Request["F_cust_area"] + "' and cust_seq='" + Request["F_cust_seq"] + "' ";
                        SQL += "and num='" + i + "' and mark='L'";
                        conn.ExecuteNonQuery(SQL);

                        //申請人資料畫面Apcust_FC_RE_form.inc
                        //*****申請人檔
                        insert_dmt_temp_ap(conn, RSno, case_sqlno);
                    }

                    //商品類別
                    SQL = "INSERT INTO casedmt_good(in_scode,in_no,case_sqlno,class,dmt_grp_code";
                    SQL += ",dmt_goodname,dmt_goodcount,tr_date,tr_scode) ";
                    SQL += "select '" + Request["F_tscode"] + "','" + RSno + "'," + case_sqlno + ",class,dmt_grp_code,dmt_goodname,dmt_goodcount";
                    SQL += ",getdate(),'" + Session["scode"] + "' ";
                    SQL += "from casedmt_good_change where in_scode='" + Request["F_tscode"] + "' ";
                    SQL += "and cust_area='" + Request["F_cust_area"] + "' and cust_seq='" + Request["F_cust_seq"] + "' ";
                    SQL += "and num='" + i + "' and mark='L' and (isnull(class,'')<>'' or isnull(dmt_goodname,'')<>'')";
                    conn.ExecuteNonQuery(SQL);

                    //展覽會優先權
                    SQL = "INSERT INTO casedmt_show(in_no,case_sqlno,show_date,show_name,tr_date,tr_scode) ";
                    SQL += "select '" + RSno + "'," + case_sqlno + ",show_date,show_name,getdate()";
                    SQL += ",'" + Session["scode"] + "' ";
                    SQL += "from casedmt_show_change where in_scode='" + Request["F_tscode"] + "' ";
                    SQL += "and cust_area='" + Request["F_cust_area"] + "' and cust_seq='" + Request["F_cust_seq"] + "' ";
                    SQL += "and num='" + i + "' and mark='L' order by show_no";
                    conn.ExecuteNonQuery(SQL);
                }
            }
            //清空暫存檔
            SQL = "delete from dmt_temp_change where in_scode='" + Request["F_tscode"] + "' and cust_area='" + Request["F_cust_area"] + "' and cust_seq='" + Request["F_cust_seq"] + "' and mark='L'";
            conn.ExecuteNonQuery(SQL);
            SQL = "delete from casedmt_good_change where in_scode='" + Request["F_tscode"] + "' and cust_area='" + Request["F_cust_area"] + "' and cust_seq='" + Request["F_cust_seq"] + "' and mark='L'";
            conn.ExecuteNonQuery(SQL);
            SQL = "delete from casedmt_show_change where in_scode='" + Request["F_tscode"] + "' and cust_area='" + Request["F_cust_area"] + "' and cust_seq='" + Request["F_cust_seq"] + "' and mark='L'";
            conn.ExecuteNonQuery(SQL);
        }

        //後續交辦作業，更新營洽官收確認紀錄檔grconf_dmt.job_no
        upd_grconf_job_no(conn, RSno);

        //更新客戶主檔最近立案日
        upd_dmt_date(conn, RSno);
    }

    /// <summary>
    /// 移轉
    /// </summary>
    private void addA8(DBHelper conn, string RSno) {
        //重建暫存檔
        //rebuil_change(RSno, "T");

        //寫入case_dmt
        insert_case_dmt(conn, RSno);

        //寫入dmt_temp
        insert_dmt_temp(conn, RSno);

        //寫入接洽費用檔
        insert_caseitem_dmt(conn, RSno);

        //寫入商品類別檔
        insert_casedmt_good(conn, RSno);

        //****新增展覽優先權資料
        insert_casedmt_show(conn, RSno, "0");

        //*****新增案件移轉檔
        ColMap.Clear();
        foreach (var key in Request.Form.Keys) {
            string colkey = key.ToString().ToLower();
            string colValue = Request[colkey];

            //取1~4碼
            if (colkey.Left(4) == "tfg1") {
                ColMap[colkey.Substring(5)] = Util.dbnull(colValue);
            }
        }

        if ((Request["O_item1"] ?? "") != "" || (Request["O_item2"] ?? "") != "") {//附註
            ColMap["other_item"] = Util.dbchar(Request["O_item1"] + ";" + Request["O_item2"]);
        }

        ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
        ColMap["in_no"] = "'" + RSno + "'";
        ColMap["tr_date"] = "getdate()";
        ColMap["tr_scode"] = "'" + Session["scode"] + "'";
        SQL = "insert into dmt_tran " + ColMap.GetInsertSQL();
        conn.ExecuteNonQuery(SQL);

        //*****新增案件異動明細檔，關係人資料
        for (int i = 1; i <= Convert.ToInt32("0" + Request["ft_apnum"]); i++) {
            ColMap.Clear();
            ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
            ColMap["in_no"] = "'" + RSno + "'";
            ColMap["mod_field"] = "'mod_ap'";
            ColMap["old_no"] = Util.dbchar(Request["tfr_old_no_" + i]);
            ColMap["ocname1"] = Util.dbchar(Request["tfr_ocname1_" + i]);
            ColMap["ocname2"] = Util.dbchar(Request["tfr_ocname2_" + i]);
            ColMap["oename1"] = Util.dbchar(Request["tfr_oename1_" + i]);
            ColMap["oename2"] = Util.dbchar(Request["tfr_oename2_" + i]);
            ColMap["ocrep"] = Util.dbchar(Request["tfr_ocrep_" + i]);
            ColMap["oerep"] = Util.dbchar(Request["tfr_oerep_" + i]);
            ColMap["ozip"] = Util.dbchar(Request["tfr_ozip_" + i]);
            ColMap["oaddr1"] = Util.dbchar(Request["tfr_oaddr1_" + i]);
            ColMap["oaddr2"] = Util.dbchar(Request["tfr_oaddr2_" + i]);
            ColMap["oeaddr1"] = Util.dbchar(Request["tfr_oeaddr1_" + i]);
            ColMap["oeaddr2"] = Util.dbchar(Request["tfr_oeaddr2_" + i]);
            ColMap["oeaddr3"] = Util.dbchar(Request["tfr_oeaddr3_" + i]);
            ColMap["oeaddr4"] = Util.dbchar(Request["tfr_oeaddr4_" + i]);
            ColMap["otel0"] = Util.dbchar(Request["tfr_otel0_" + i]);
            ColMap["otel"] = Util.dbchar(Request["tfr_otel_" + i]);
            ColMap["otel1"] = Util.dbchar(Request["otel1_" + i]);
            ColMap["ofax"] = Util.dbchar(Request["ofax_" + i]);
            ColMap["tran_code"] = "'N'";

            SQL = "insert into dmt_tranlist " + ColMap.GetInsertSQL();
            conn.ExecuteNonQuery(SQL);
        }

        //寫入交辦申請人檔
        insert_dmt_temp_ap(conn, RSno, "0");

        //*****新增文件上傳
        insert_dmt_attach(conn, RSno);

        //移轉多件入檔	
        if ((Request["tfy_arcase"] ?? "") == "FT2") {
            for (int i = 2; i <= Convert.ToInt32("0" + Request["nfy_tot_num"]); i++) {
                ColMap.Clear();
                ColMap["in_no"] = Util.dbchar(RSno);
                ColMap["seq"] = Util.dbnull(Request["dseqb_" + i]);
                ColMap["seq1"] = Util.dbnull(Request["dseq1b_" + i]);
                ColMap["Cseq"] = Util.dbnull(Request["dmseqb_" + i]);
                ColMap["Cseq1"] = Util.dbnull(Request["dmseq1b_" + i]);
                ColMap["case_stat1"] = ((Request["dseqb_" + i] ?? "") != "" ? "'OO'" : "'NN'");
                SQL = "insert into case_dmt1 " + ColMap.GetInsertSQL();
                conn.ExecuteNonQuery(SQL);

                //抓insert後的流水號
                SQL = "SELECT SCOPE_IDENTITY() AS Current_Identity";
                object objResult1 = conn.ExecuteScalar(SQL);
                string case_sqlno = objResult1.ToString();

                if ((Request["dseqb_" + i] ?? "") == "") {
                    //抓圖檔
                    SQL = "SELECT draw_file FROM dmt_temp_change where in_scode='" + Request["F_tscode"] + "' and cust_area='" + Request["F_cust_area"] + "' and cust_seq='" + Request["F_cust_seq"] + "' and num='" + i + "' and mark='T'";
                    object objResult2 = conn.ExecuteScalar(SQL);
                    if (objResult2 != null) {
                        string draw_file = objResult2.ToString();
                        //將檔案更改檔名
                        string newfilename = move_file(RSno, draw_file, "-FT" + i);

                        SQL = "insert into dmt_temp(s_mark,s_mark2,pul,apsqlno,ap_cname,ap_cname1,ap_cname2 ";
                        SQL += ",ap_ename,ap_ename1,ap_ename2,appl_name,cappl_name,eappl_name";
                        SQL += ",eappl_name1,eappl_name2,jappl_name,jappl_name1,jappl_name2,zappl_name1 ";
                        SQL += ",zappl_name2,zname_type,oappl_name,Draw,symbol,color,agt_no,prior_date,prior_no ";
                        SQL += ",prior_country,ref_no,ref_no1,tcn_ref,tcn_class,tcn_name,tcn_mark ";
                        SQL += ",apply_date,apply_no,issue_date,issue_no,open_date,rej_no,end_date ";
                        SQL += ",end_code,dmt_term1,dmt_term2,renewal,class_type,class_count,class ";
                        SQL += ",in_scode,in_no,in_date,draw_file,tr_date,tr_scode,case_sqlno,seq1) ";
                        SQL += "Select s_mark,s_mark2 as ts_mark,pul," + Util.dbnull(Request["tfzp_apsqlno"]) + " ";
                        SQL += "," + Util.dbnull(Request["tfzp_ap_cname"]) + "," + Util.dbnull(Request["tfzp_ap_cname1"]) + " ";
                        SQL += "," + Util.dbnull(Request["tfzp_ap_cname2"]) + "," + Util.dbnull(Request["tfzp_ap_ename"]) + " ";
                        SQL += "," + Util.dbnull(Request["tfzp_ap_ename1"]) + "," + Util.dbnull(Request["tfzp_ap_ename2"]) + " ";
                        SQL += ",appl_name,cappl_name,eappl_name ";
                        SQL += ",eappl_name1,eappl_name2,jappl_name,jappl_name1,jappl_name2,zappl_name1 ";
                        SQL += ",zappl_name2,zname_type,oappl_name,Draw,symbol,color ";
                        SQL += "," + Util.dbnull(Request["tfzd_agt_no"]) + ",prior_date,prior_no ";
                        SQL += ",prior_country,ref_no,ref_no1,tcn_ref,tcn_class,tcn_name,tcn_mark ";
                        SQL += ",apply_date,apply_no,issue_date,issue_no,open_date,rej_no,end_date ";
                        SQL += ",end_code,dmt_term1,dmt_term2,renewal,class_type,class_count,class ";
                        SQL += ",'" + Request["F_tscode"] + "','" + RSno + "','" + DateTime.Today.ToShortDateString() + "','" + newfilename + "' ";
                        SQL += ",getdate(),'" + Session["scode"] + "'," + case_sqlno + ",'" + Request["dseq1b_" + i] + "' ";
                        SQL += "from dmt_temp_change where in_scode='" + Request["F_tscode"] + "' ";
                        SQL += "and cust_area='" + Request["F_cust_area"] + "' and cust_seq='" + Request["F_cust_seq"] + "' ";
                        SQL += "and num='" + i + "' and mark='T'";
                        conn.ExecuteNonQuery(SQL);

                        //申請人資料畫面Apcust_FC_RE_form.inc
                        //*****申請人檔
                        insert_dmt_temp_ap(conn, RSno, case_sqlno);
                    }

                    //商品類別
                    SQL = "INSERT INTO casedmt_good(in_scode,in_no,case_sqlno,class,dmt_grp_code,dmt_goodname,dmt_goodcount,tr_date,tr_scode) ";
                    SQL += "select '" + Request["F_tscode"] + "','" + RSno + "'," + case_sqlno + ",class,dmt_grp_code,dmt_goodname,dmt_goodcount";
                    SQL += ",getdate()','" + Session["scode"] + "' ";
                    SQL += "from casedmt_good_change where in_scode='" + Request["F_tscode"] + "' ";
                    SQL += "and cust_area='" + Request["F_cust_area"] + "' and cust_seq='" + Request["F_cust_seq"] + "' ";
                    SQL += "and num='" + i + "' and mark='T' and (isnull(class,'')<>'' or isnull(dmt_goodname,'')<>'')";
                    conn.ExecuteNonQuery(SQL);

                    //展覽會優先權
                    SQL = "INSERT INTO casedmt_show(in_no,case_sqlno,show_date,show_name,tr_date,tr_scode) ";
                    SQL += "select '" + RSno + "'," + case_sqlno + ",show_date,show_name,getdate()";
                    SQL += "'" + Session["scode"] + "' ";
                    SQL += "from casedmt_show_change where in_scode='" + Request["F_tscode"] + "' ";
                    SQL += "and cust_area='" + Request["F_cust_area"] + "' and cust_seq='" + Request["F_cust_seq"] + "' ";
                    SQL += "and num='" + i + "' and mark='T' order by show_no";
                    conn.ExecuteNonQuery(SQL);
                }
            }
            //清空暫存檔
            SQL = "delete from dmt_temp_change where in_scode='" + Request["F_tscode"] + "' and cust_area='" + Request["F_cust_area"] + "' and cust_seq='" + Request["F_cust_seq"] + "' and mark='T'";
            conn.ExecuteNonQuery(SQL);
            SQL = "delete from casedmt_good_change where in_scode='" + Request["F_tscode"] + "' and cust_area='" + Request["F_cust_area"] + "' and cust_seq='" + Request["F_cust_seq"] + "' and mark='T'";
            conn.ExecuteNonQuery(SQL);
            SQL = "delete from casedmt_show_change where in_scode='" + Request["F_tscode"] + "' and cust_area='" + Request["F_cust_area"] + "' and cust_seq='" + Request["F_cust_seq"] + "' and mark='T'";
            conn.ExecuteNonQuery(SQL);
        }

        //後續交辦作業，更新營洽官收確認紀錄檔grconf_dmt.job_no
        upd_grconf_job_no(conn, RSno);

        //更新客戶主檔最近立案日
        upd_dmt_date(conn, RSno);
    }

    /// <summary>
    /// 質權
    /// </summary>
    private void addA9(DBHelper conn, string RSno) {
        //寫入case_dmt
        insert_case_dmt(conn, RSno);

        //寫入dmt_temp
        insert_dmt_temp(conn, RSno);

        //寫入接洽費用檔
        insert_caseitem_dmt(conn, RSno);

        //寫入商品類別檔
        insert_casedmt_good(conn, RSno);

        //****新增展覽優先權資料
        insert_casedmt_show(conn, RSno, "0");

        string save1 = "";
        if ((Request["tfy_arcase"] ?? "") == "FP1") {
            save1 = "tfg1";//欄位開頭
        } else if ((Request["tfy_arcase"] ?? "") == "FP2") {
            save1 = "tfg2";
        }

        //***異動檔
        ColMap.Clear();
        foreach (var key in Request.Form.Keys) {
            string colkey = key.ToString().ToLower();
            string colValue = Request[colkey];

            //取1~4碼
            if (colkey.Left(4) == save1) {
                ColMap[colkey.Substring(5)] = Util.dbnull(colValue);
            }
        }

        ColMap["other_item"] = Util.dbchar(Request["O_item1"] + ";" + Request["O_item2"]);

        if ((Request["O_item3"] ?? "") != "") {
            ColMap["other_item1"] = Util.dbchar(Request["O_item3"] + ";" + Request["O_item4"]);
        }

        ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
        ColMap["in_no"] = "'" + RSno + "'";
        ColMap["tr_date"] = "getdate()";
        ColMap["tr_scode"] = "'" + Session["scode"] + "'";
        SQL = "insert into dmt_tran " + ColMap.GetInsertSQL();
        conn.ExecuteNonQuery(SQL);


        //*****新增案件異動明細檔,關係人
        for (int i = 1; i <= Convert.ToInt32("0" + Request["ft_apnum"]); i++) {
            ColMap.Clear();
            ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
            ColMap["in_no"] = "'" + RSno + "'";
            ColMap["mod_field"] = "'mod_ap'";
            ColMap["old_no"] = Util.dbchar(Request["tfr1_apcust_no_" + i]);
            ColMap["ocname1"] = Util.dbchar(Request["tfr1_ap_cname1_" + i]);
            ColMap["ocname2"] = Util.dbchar(Request["tfr1_ap_cname2_" + i]);
            ColMap["oename1"] = Util.dbchar(Request["tfr1_ap_ename1_" + i]);
            ColMap["oename2"] = Util.dbchar(Request["tfr1_ap_ename2_" + i]);
            ColMap["ocrep"] = Util.dbchar(Request["tfr1_ap_crep_" + i]);
            ColMap["oerep"] = Util.dbchar(Request["tfr1_ap_erep_" + i]);
            ColMap["ozip"] = Util.dbchar(Request["tfr1_ap_zip_" + i]);
            ColMap["oaddr1"] = Util.dbchar(Request["tfr1_ap_addr1_" + i]);
            ColMap["oaddr2"] = Util.dbchar(Request["tfr1_ap_addr2_" + i]);
            ColMap["oeaddr1"] = Util.dbchar(Request["tfr1_ap_eaddr1_" + i]);
            ColMap["oeaddr2"] = Util.dbchar(Request["tfr1_ap_eaddr2_" + i]);
            ColMap["oeaddr3"] = Util.dbchar(Request["tfr1_ap_eaddr3_" + i]);
            ColMap["oeaddr4"] = Util.dbchar(Request["tfr1_ap_eaddr4_" + i]);
            ColMap["otel0"] = Util.dbchar(Request["tfr1_apatt_tel0_" + i]);
            ColMap["otel"] = Util.dbchar(Request["tfr1_apatt_tel_" + i]);
            ColMap["otel1"] = Util.dbchar(Request["tfr1_apatt_tel1_" + i]);
            ColMap["ofax"] = Util.dbchar(Request["tfr1_apatt_fax_" + i]);
            ColMap["oapclass"] = Util.dbchar(Request["tfr1_oapclass_" + i]);
            ColMap["oap_country"] = Util.dbchar(Request["tfr1_oap_country_" + i]);
            ColMap["tran_code"] = "'N'";

            SQL = "insert into dmt_tranlist " + ColMap.GetInsertSQL();
            conn.ExecuteNonQuery(SQL);
        }

        //寫入交辦申請人檔
        insert_dmt_temp_ap(conn, RSno, "0");

        //*****新增文件上傳
        insert_dmt_attach(conn, RSno);

        //後續交辦作業，更新營洽官收確認紀錄檔grconf_dmt.job_no
        upd_grconf_job_no(conn, RSno);

        //更新客戶主檔最近立案日
        upd_dmt_date(conn, RSno);
    }

    /// <summary>
    /// 質權
    /// </summary>
    private void addAA(DBHelper conn, string RSno) {
        //寫入case_dmt
        insert_case_dmt(conn, RSno);

        //寫入dmt_temp
        insert_dmt_temp(conn, RSno);

        //寫入接洽費用檔
        insert_caseitem_dmt(conn, RSno);

        //寫入商品類別檔
        insert_casedmt_good(conn, RSno);

        //****新增展覽優先權資料
        insert_casedmt_show(conn, RSno, "0");

        //***異動檔
        ColMap.Clear();
        foreach (var key in Request.Form.Keys) {
            string colkey = key.ToString().ToLower();
            string colValue = Request[colkey];

            //取2~4碼
            if (colkey.Left(4).Substring(1) == "fgd" || colkey.Left(4).Substring(1) == "fg3" || colkey.Left(4).Substring(1) == "fg2") {
                if (colkey.Left(1) == "p") {
                    ColMap[colkey.Substring(5)] = Util.dbnull(colValue);
                } else if (colkey.Left(1) == "d") {
                    ColMap[colkey.Substring(5)] = Util.dbnull(colValue);
                } else {
                    ColMap[colkey.Substring(5)] = Util.dbnull(colValue);
                }
            }
        }

        if ((Request["O_item1"] ?? "") != "" || (Request["O_item2"] ?? "") != "" || (Request["O_item21"] ?? "") != "") {//附註
            ColMap["other_item1"] = Util.dbchar(Request["O_item1"] + ";" + Request["O_item2"] + ";" + Request["O_item21"]);
        }

        if ((Request["O_item3"] ?? "") != "" || (Request["O_item31"] ?? "") != "") {//申請份數
            ColMap["other_item2"] = Util.dbchar(Request["O_item3"] + ";" + Request["O_item31"]);
        }

        if ((Request["O_item4"] ?? "") != "" || (Request["O_item41"] ?? "") != "") {//指定類別
            ColMap["other_item"] = Util.dbchar(Request["O_item4"] + ";" + Request["O_item41"]);
        }

        ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
        ColMap["in_no"] = "'" + RSno + "'";
        ColMap["tr_date"] = "getdate()";
        ColMap["tr_scode"] = "'" + Session["scode"] + "'";
        SQL = "insert into dmt_tran " + ColMap.GetInsertSQL();
        conn.ExecuteNonQuery(SQL);

        //寫入交辦申請人檔
        insert_dmt_temp_ap(conn, RSno, "0");

        //*****新增文件上傳
        insert_dmt_attach(conn, RSno);

        //後續交辦作業，更新營洽官收確認紀錄檔grconf_dmt.job_no
        upd_grconf_job_no(conn, RSno);

        //更新客戶主檔最近立案日
        upd_dmt_date(conn, RSno);
    }

    /// <summary>
    /// 補(換)發證
    /// </summary>
    private void addAB(DBHelper conn, string RSno) {
        //寫入case_dmt
        insert_case_dmt(conn, RSno);

        //寫入dmt_temp
        insert_dmt_temp(conn, RSno);

        //寫入接洽費用檔
        insert_caseitem_dmt(conn, RSno);

        //寫入商品類別檔
        insert_casedmt_good(conn, RSno);

        //****新增展覽優先權資料
        insert_casedmt_show(conn, RSno, "0");

        //***異動檔
        if ((Request["ar_form"] ?? "") == "AB") {//捕(換)發證
            ColMap.Clear();
            foreach (var key in Request.Form.Keys) {
                string colkey = key.ToString().ToLower();
                string colValue = Request[colkey];

                //取1~4碼
                if (colkey.Left(4) == "tfg1") {
                    ColMap[colkey.Substring(5)] = Util.dbnull(colValue);
                }
            }

            if ((Request["O_item1"] ?? "") != "" || (Request["O_item2"] ?? "") != "") {//附註
                ColMap["other_item"] = Util.dbchar(Request["O_item1"] + ";" + Request["O_item2"]);
            }

            ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
            ColMap["in_no"] = "'" + RSno + "'";
            ColMap["tr_date"] = "getdate()";
            ColMap["tr_scode"] = "'" + Session["scode"] + "'";
            SQL = "insert into dmt_tran " + ColMap.GetInsertSQL();
            conn.ExecuteNonQuery(SQL);
        }

        //寫入交辦申請人檔
        insert_dmt_temp_ap(conn, RSno, "0");

        //*****新增文件上傳
        insert_dmt_attach(conn, RSno);

        //後續交辦作業，更新營洽官收確認紀錄檔grconf_dmt.job_no
        upd_grconf_job_no(conn, RSno);

        //更新客戶主檔最近立案日
        upd_dmt_date(conn, RSno);
    }

    /// <summary>
    /// 閱案
    /// </summary>
    private void addAC(DBHelper conn, string RSno) {
        //寫入case_dmt
        insert_case_dmt(conn, RSno);

        //寫入dmt_temp
        insert_dmt_temp(conn, RSno);

        //寫入接洽費用檔
        insert_caseitem_dmt(conn, RSno);

        //寫入商品類別檔
        insert_casedmt_good(conn, RSno);

        //***異動檔
        ColMap.Clear();
        foreach (var key in Request.Form.Keys) {
            string colkey = key.ToString().ToLower();
            string colValue = Request[colkey];

            //取2~4碼
            if (colkey.Left(4).Substring(1) == "fg1") {
                if (colkey.Left(1) == "p") {
                    ColMap[colkey.Substring(5)] = Util.dbnull(colValue);
                } else if (colkey.Left(1) == "d") {
                    ColMap[colkey.Substring(5)] = Util.dbnull(colValue);
                } else {
                    ColMap[colkey.Substring(5)] = Util.dbnull(colValue);
                }
            }
        }

        ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
        ColMap["in_no"] = "'" + RSno + "'";
        ColMap["tr_date"] = "getdate()";
        ColMap["tr_scode"] = "'" + Session["scode"] + "'";
        SQL = "insert into dmt_tran " + ColMap.GetInsertSQL();
        conn.ExecuteNonQuery(SQL);

        //寫入交辦申請人檔
        insert_dmt_temp_ap(conn, RSno, "0");

        //*****新增文件上傳
        insert_dmt_attach(conn, RSno);

        //後續交辦作業，更新營洽官收確認紀錄檔grconf_dmt.job_no
        upd_grconf_job_no(conn, RSno);

        //更新客戶主檔最近立案日
        upd_dmt_date(conn, RSno);
    }

    /// <summary>
    /// 爭議案
    /// </summary>
    private void addB(DBHelper conn, string RSno) {
        //寫入case_dmt
        insert_case_dmt(conn, RSno);

        //寫入dmt_temp
        insert_dmt_temp(conn, RSno);

        //寫入接洽費用檔
        insert_caseitem_dmt(conn, RSno);

        //將檔案更改檔名
        //*****新增案件變更檔
        switch ((Request["tfy_arcase"] ?? "").Left(3)) {
            case "DR1":
                //--變換加附記使用後之商標/標章圖樣
                string DR1_mod_class_ncname1 = move_file(RSno, Request["ttg1_mod_class_ncname1"], "-C1");
                string DR1_mod_class_ncname2 = move_file(RSno, Request["ttg1_mod_class_ncname2"], "-C2");
                string DR1_mod_class_nename1 = move_file(RSno, Request["ttg1_mod_class_nename1"], "-C3");
                string DR1_mod_class_nename2 = move_file(RSno, Request["ttg1_mod_class_nename2"], "-C4");
                string DR1_mod_class_ncrep = move_file(RSno, Request["ttg1_mod_class_ncrep"], "-C5");
                string DR1_mod_class_nerep = move_file(RSno, Request["ttg1_mod_class_nerep"], "-C6");
                string DR1_mod_class_neaddr1 = move_file(RSno, Request["ttg1_mod_class_neaddr1"], "-C7");
                string DR1_mod_class_neaddr2 = move_file(RSno, Request["ttg1_mod_class_neaddr2"], "-C8");
                string DR1_mod_class_neaddr3 = move_file(RSno, Request["ttg1_mod_class_neaddr3"], "-C9");
                string DR1_mod_class_neaddr4 = move_file(RSno, Request["ttg1_mod_class_neaddr4"], "-C10");
                //--據以異議
                string DR1_mod_dmt_ncname1 = move_file(RSno, Request["ttg1_mod_dmt_ncname1"], "-O1");
                string DR1_mod_dmt_ncname2 = move_file(RSno, Request["ttg1_mod_dmt_ncname2"], "-O2");
                string DR1_mod_dmt_nename1 = move_file(RSno, Request["ttg1_mod_dmt_nename1"], "-O3");
                string DR1_mod_dmt_nename2 = move_file(RSno, Request["ttg1_mod_dmt_nename2"], "-O4");
                string DR1_mod_dmt_ncrep = move_file(RSno, Request["ttg1_mod_dmt_ncrep"], "-O5");
                string DR1_mod_dmt_nerep = move_file(RSno, Request["ttg1_mod_dmt_nerep"], "-O6");
                string DR1_mod_dmt_neaddr1 = move_file(RSno, Request["ttg1_mod_dmt_neaddr1"], "-O7");
                string DR1_mod_dmt_neaddr2 = move_file(RSno, Request["ttg1_mod_dmt_neaddr2"], "-O8");
                string DR1_mod_dmt_neaddr3 = move_file(RSno, Request["ttg1_mod_dmt_neaddr3"], "-O9");
                string DR1_mod_dmt_neaddr4 = move_file(RSno, Request["ttg1_mod_dmt_neaddr4"], "-O10");

                ColMap.Clear();
                foreach (var key in Request.Form.Keys) {
                    string colkey = key.ToString().ToLower();
                    string colValue = Request[colkey];

                    //取1~4碼
                    if (colkey.Left(4) == "tfz1") {
                        ColMap[colkey.Substring(5)] = Util.dbnull(colValue);
                    }
                }
                ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
                ColMap["in_no"] = "'" + RSno + "'";
                ColMap["tr_date"] = "getdate()";
                ColMap["tr_scode"] = "'" + Session["scode"] + "'";
                ColMap["seq"] = Util.dbnull(Request["tfzb_seq"]);
                ColMap["seq1"] = Util.dbchar(Request["tfzb_seq1"]);
                SQL = "insert into dmt_tran " + ColMap.GetInsertSQL();
                conn.ExecuteNonQuery(SQL);

                //*****變更被申請撤銷人資料
                if (Convert.ToInt32("0" + Request["DR1_apnum"]) > 0) {
                    for (int k = 1; k <= Convert.ToInt32("0" + Request["DR1_apnum"]); k++) {
                        SQL = "insert into dmt_tranlist(in_scode,in_no,mod_field,ncname1,ncname2,ncrep,nzip,naddr1,naddr2) values (";
                        SQL += "'" + Request["F_tscode"] + "','" + RSno + "','mod_ap'";
                        SQL += "," + Util.dbchar(Request["ttg1_mod_ap_ncname1_" + k]) + "," + Util.dbchar(Request["ttg1_mod_ap_ncname2_" + k]) + "";
                        SQL += "," + Util.dbchar(Request["ttg1_mod_ap_ncrep_" + k]) + "," + Util.dbchar(Request["ttg1_mod_ap_nzip_" + k]) + "";
                        SQL += "," + Util.dbchar(Request["ttg1_mod_ap_naddr1_" + k]) + "," + Util.dbchar(Request["ttg1_mod_ap_naddr2_" + k]) + ")";
                        conn.ExecuteNonQuery(SQL);
                    }
                    SQL = "update dmt_tran set mod_ap='Y' where in_scode='" + Request["F_tscode"] + "' and in_no = '" + RSno + "'";
                    conn.ExecuteNonQuery(SQL);
                }

                //*****廢止聲明
                if ((Request["ttg11_mod_pul_new_no"] ?? "") != "" || (Request["ttg11_mod_pul_ncname1"] ?? "") != ""
                || (Request["ttg11_mod_pul_mod_type"] ?? "") != "") {
                    ColMap.Clear();
                    ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
                    ColMap["in_no"] = "'" + RSno + "'";
                    ColMap["mod_field"] = "'mod_pul'";

                    string[] field = { "mod_type", "new_no", "ncname1" };
                    foreach (string f in field) {
                        ColMap[f] = Util.dbnull(Request["ttg11_mod_pul_" + f]);
                    }

                    SQL = "insert into dmt_tranlist " + ColMap.GetInsertSQL();
                    conn.ExecuteNonQuery(SQL);

                    SQL = "update dmt_tran set mod_pul='Y' where in_scode='" + Request["F_tscode"] + "' and in_no = '" + RSno + "'";
                    conn.ExecuteNonQuery(SQL);
                }

                if ((Request["ttg12_mod_pul_mod_type"] ?? "") != "") {
                    ColMap.Clear();
                    ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
                    ColMap["in_no"] = "'" + RSno + "'";
                    ColMap["mod_field"] = "'mod_pul'";

                    string[] field = { "mod_type" };
                    foreach (string f in field) {
                        ColMap[f] = Util.dbnull(Request["ttg12_mod_pul_" + f]);
                    }
                    SQL = "insert into dmt_tranlist " + ColMap.GetInsertSQL();
                    conn.ExecuteNonQuery(SQL);

                    SQL = "update dmt_tran set mod_pul='Y' where in_scode='" + Request["F_tscode"] + "' and in_no = '" + RSno + "'";
                    conn.ExecuteNonQuery(SQL);
                }

                if ((Request["ttg13_mod_pul_new_no"] ?? "") != "" || (Request["ttg13_mod_pul_mod_dclass"] ?? "") != ""
                || (Request["ttg13_mod_pul_mod_type"] ?? "") != "") {
                    ColMap.Clear();
                    ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
                    ColMap["in_no"] = "'" + RSno + "'";
                    ColMap["mod_field"] = "'mod_pul'";

                    string[] field = { "mod_type", "new_no", "mod_dclass" };
                    foreach (string f in field) {
                        ColMap[f] = Util.dbnull(Request["ttg13_mod_pul_" + f]);
                    }

                    SQL = "insert into dmt_tranlist " + ColMap.GetInsertSQL();
                    conn.ExecuteNonQuery(SQL);

                    SQL = "update dmt_tran set mod_pul='Y' where in_scode='" + Request["F_tscode"] + "' and in_no = '" + RSno + "'";
                    conn.ExecuteNonQuery(SQL);
                }

                if ((Request["ttg14_mod_pul_new_no"] ?? "") != "" || (Request["ttg14_mod_pul_mod_dclass"] ?? "") != ""
                || (Request["ttg14_mod_pul_ncname1"] ?? "") != "" || (Request["ttg14_mod_pul_mod_type"] ?? "") != "") {
                    ColMap.Clear();
                    ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
                    ColMap["in_no"] = "'" + RSno + "'";
                    ColMap["mod_field"] = "'mod_pul'";

                    string[] field = { "mod_type","new_no", "mod_dclass", "ncname1" };
                    foreach (string f in field) {
                        ColMap[f] = Util.dbnull(Request["ttg14_mod_pul_" + f]);
                    }

                    SQL = "insert into dmt_tranlist " + ColMap.GetInsertSQL();
                    conn.ExecuteNonQuery(SQL);

                    SQL = "update dmt_tran set mod_pul='Y' where in_scode='" + Request["F_tscode"] + "' and in_no = '" + RSno + "'";
                    conn.ExecuteNonQuery(SQL);
                }

                //據以異議商標/標章
                if ((Request["ttg1_mod_claim1_ncname1"] ?? "") != "") {
                    ColMap.Clear();
                    ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
                    ColMap["in_no"] = "'" + RSno + "'";
                    ColMap["mod_field"] = "'mod_claim1'";

                    string[] field = { "ncname1" };
                    foreach (string f in field) {
                        ColMap[f] = Util.dbnull(Request["ttg1_mod_claim1_" + f]);
                    }
                    SQL = "insert into dmt_tranlist " + ColMap.GetInsertSQL();
                    conn.ExecuteNonQuery(SQL);

                    SQL = "update dmt_tran set mod_claim1='Y' where in_scode='" + Request["F_tscode"] + "' and in_no = '" + RSno + "'";
                    conn.ExecuteNonQuery(SQL);
                }

                //變換使用商標圖樣
                if ((Request["ttg1_mod_class_ncname1"] ?? "") != "" || (Request["ttg1_mod_class_ncname2"] ?? "") != ""
                || (Request["ttg1_mod_class_nename1"] ?? "") != "" || (Request["ttg1_mod_class_nename2"] ?? "") != ""
                || (Request["ttg1_mod_class_ncrep"] ?? "") != "" || (Request["ttg1_mod_class_nerep"] ?? "") != ""
                || (Request["ttg1_mod_class_neaddr1"] ?? "") != "" || (Request["ttg1_mod_class_neaddr2"] ?? "") != ""
                || (Request["ttg1_mod_class_neaddr3"] ?? "") != "" || (Request["ttg1_mod_class_neaddr4"] ?? "") != ""
                ) {
                    SQL = "INSERT INTO dmt_tranlist(in_scode,in_no,mod_field,ncname1,ncname2,nename1,nename2,ncrep,nerep,neaddr1,neaddr2,neaddr3,neaddr4)";
                    SQL += "VALUES('" + Request["F_tscode"] + "','" + RSno + "','mod_class'";
                    SQL += "," + Util.dbnull(Sys.Path2Btbrt(DR1_mod_class_ncname1)) + "," + Util.dbnull(Sys.Path2Btbrt(DR1_mod_class_ncname2));
                    SQL += "," + Util.dbnull(Sys.Path2Btbrt(DR1_mod_class_nename1)) + "," + Util.dbnull(Sys.Path2Btbrt(DR1_mod_class_nename2));
                    SQL += "," + Util.dbnull(Sys.Path2Btbrt(DR1_mod_class_ncrep)) + "," + Util.dbnull(Sys.Path2Btbrt(DR1_mod_class_nerep));
                    SQL += "," + Util.dbnull(Sys.Path2Btbrt(DR1_mod_class_neaddr1)) + "," + Util.dbnull(Sys.Path2Btbrt(DR1_mod_class_neaddr2));
                    SQL += "," + Util.dbnull(Sys.Path2Btbrt(DR1_mod_class_neaddr3)) + "," + Util.dbnull(Sys.Path2Btbrt(DR1_mod_class_neaddr4)) + ")";
                    conn.ExecuteNonQuery(SQL);

                    SQL = "update dmt_tran set mod_class='Y' where in_scode='" + Request["F_tscode"] + "' and in_no = '" + RSno + "'";
                    conn.ExecuteNonQuery(SQL);
                }

                //變換撤銷商標圖樣
                if ((Request["ttg1_mod_dmt_ncname1"] ?? "") != "" || (Request["ttg1_mod_dmt_ncname2"] ?? "") != ""
                || (Request["ttg1_mod_dmt_nename1"] ?? "") != "" || (Request["ttg1_mod_dmt_nename2"] ?? "") != ""
                || (Request["ttg1_mod_dmt_ncrep"] ?? "") != "" || (Request["ttg1_mod_dmt_nerep"] ?? "") != ""
                || (Request["ttg1_mod_dmt_neaddr1"] ?? "") != "" || (Request["ttg1_mod_dmt_neaddr2"] ?? "") != ""
                || (Request["ttg1_mod_dmt_neaddr3"] ?? "") != "" || (Request["ttg1_mod_dmt_neaddr4"] ?? "") != ""
                ) {
                    SQL = "INSERT INTO dmt_tranlist(in_scode,in_no,mod_field,ncname1,ncname2,nename1,nename2,ncrep,nerep,neaddr1,neaddr2,neaddr3,neaddr4)";
                    SQL += "VALUES('" + Request["F_tscode"] + "','" + RSno + "','mod_dmt'";
                    SQL += "," + Util.dbnull(Sys.Path2Btbrt(DR1_mod_dmt_ncname1)) + "," + Util.dbnull(Sys.Path2Btbrt(DR1_mod_dmt_ncname2));
                    SQL += "," + Util.dbnull(Sys.Path2Btbrt(DR1_mod_dmt_nename1)) + "," + Util.dbnull(Sys.Path2Btbrt(DR1_mod_dmt_nename2));
                    SQL += "," + Util.dbnull(Sys.Path2Btbrt(DR1_mod_dmt_ncrep)) + "," + Util.dbnull(Sys.Path2Btbrt(DR1_mod_dmt_nerep));
                    SQL += "," + Util.dbnull(Sys.Path2Btbrt(DR1_mod_dmt_neaddr1)) + "," + Util.dbnull(Sys.Path2Btbrt(DR1_mod_dmt_neaddr2));
                    SQL += "," + Util.dbnull(Sys.Path2Btbrt(DR1_mod_dmt_neaddr3)) + "," + Util.dbnull(Sys.Path2Btbrt(DR1_mod_dmt_neaddr4)) + ")";
                    conn.ExecuteNonQuery(SQL);

                    SQL = "update dmt_tran set mod_dmt='Y' where in_scode='" + Request["F_tscode"] + "' and in_no = '" + RSno + "'";
                    conn.ExecuteNonQuery(SQL);
                }
                break;
            case "DO1":
                string DO1_mod_dmt_ncname1 = move_file(RSno, Request["ttg2_mod_dmt_ncname1"], "-O1");
                string DO1_mod_dmt_ncname2 = move_file(RSno, Request["ttg2_mod_dmt_ncname2"], "-O2");
                string DO1_mod_dmt_nename1 = move_file(RSno, Request["ttg2_mod_dmt_nename1"], "-O3");
                string DO1_mod_dmt_nename2 = move_file(RSno, Request["ttg2_mod_dmt_nename2"], "-O4");
                string DO1_mod_dmt_ncrep = move_file(RSno, Request["ttg2_mod_dmt_ncrep"], "-O5");
                string DO1_mod_dmt_nerep = move_file(RSno, Request["ttg2_mod_dmt_nerep"], "-O6");
                string DO1_mod_dmt_neaddr1 = move_file(RSno, Request["ttg2_mod_dmt_neaddr1"], "-O7");
                string DO1_mod_dmt_neaddr2 = move_file(RSno, Request["ttg2_mod_dmt_neaddr2"], "-O8");
                string DO1_mod_dmt_neaddr3 = move_file(RSno, Request["ttg2_mod_dmt_neaddr3"], "-O9");
                string DO1_mod_dmt_neaddr4 = move_file(RSno, Request["ttg2_mod_dmt_neaddr4"], "-O10");

                ColMap.Clear();
                foreach (var key in Request.Form.Keys) {
                    string colkey = key.ToString().ToLower();
                    string colValue = Request[colkey];

                    //取1~4碼
                    if (colkey.Left(4) == "tfz2") {
                        ColMap[colkey.Substring(5)] = Util.dbnull(colValue);
                    }
                }
                ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
                ColMap["in_no"] = "'" + RSno + "'";
                ColMap["tr_date"] = "getdate()";
                ColMap["tr_scode"] = "'" + Session["scode"] + "'";
                ColMap["seq"] = Util.dbnull(Request["tfzb_seq"]);
                ColMap["seq1"] = Util.dbchar(Request["tfzb_seq1"]);
                SQL = "insert into dmt_tran " + ColMap.GetInsertSQL();
                conn.ExecuteNonQuery(SQL);

                //*****變更被申請撤銷人資料
                if (Convert.ToInt32("0" + Request["DO1_apnum"]) > 0) {
                    for (int k = 1; k <= Convert.ToInt32("0" + Request["DO1_apnum"]); k++) {
                        SQL = "insert into dmt_tranlist(in_scode,in_no,mod_field,ncname1,ncname2,ncrep,nzip,naddr1,naddr2) values (";
                        SQL += "'" + Request["F_tscode"] + "','" + RSno + "','mod_ap'";
                        SQL += "," + Util.dbchar(Request["ttg2_mod_ap_ncname1_" + k]) + "," + Util.dbchar(Request["ttg2_mod_ap_ncname2_" + k]) + "";
                        SQL += "," + Util.dbchar(Request["ttg2_mod_ap_ncrep_" + k]) + "," + Util.dbchar(Request["ttg2_mod_ap_nzip_" + k]) + "";
                        SQL += "," + Util.dbchar(Request["ttg2_mod_ap_naddr1_" + k]) + "," + Util.dbchar(Request["ttg2_mod_ap_naddr2_" + k]) + ")";
                        conn.ExecuteNonQuery(SQL);
                    }
                    SQL = "update dmt_tran set mod_ap='Y' where in_scode='" + Request["F_tscode"] + "' and in_no = '" + RSno + "'";
                    conn.ExecuteNonQuery(SQL);
                }

                //*****廢止聲明
                if ((Request["ttg21_mod_pul_new_no"] ?? "") != "" || (Request["ttg21_mod_pul_ncname1"] ?? "") != ""
                || (Request["ttg21_mod_pul_mod_type"] ?? "") != "") {
                    ColMap.Clear();
                    ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
                    ColMap["in_no"] = "'" + RSno + "'";
                    ColMap["mod_field"] = "'mod_pul'";

                    string[] field = { "mod_type", "new_no", "ncname1" };
                    foreach (string f in field) {
                        ColMap[f] = Util.dbnull(Request["ttg21_mod_pul_" + f]);
                    }

                    SQL = "insert into dmt_tranlist " + ColMap.GetInsertSQL();
                    conn.ExecuteNonQuery(SQL);

                    SQL = "update dmt_tran set mod_pul='Y' where in_scode='" + Request["F_tscode"] + "' and in_no = '" + RSno + "'";
                    conn.ExecuteNonQuery(SQL);
                }

                if ((Request["ttg22_mod_pul_mod_type"] ?? "") != "") {
                    ColMap.Clear();
                    ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
                    ColMap["in_no"] = "'" + RSno + "'";
                    ColMap["mod_field"] = "'mod_pul'";

                    string[] field = { "mod_type" };
                    foreach (string f in field) {
                        ColMap[f] = Util.dbnull(Request["ttg22_mod_pul_" + f]);
                    }
                    SQL = "insert into dmt_tranlist " + ColMap.GetInsertSQL();
                    conn.ExecuteNonQuery(SQL);

                    SQL = "update dmt_tran set mod_pul='Y' where in_scode='" + Request["F_tscode"] + "' and in_no = '" + RSno + "'";
                    conn.ExecuteNonQuery(SQL);
                }

                if ((Request["ttg23_mod_pul_new_no"] ?? "") != "" || (Request["ttg23_mod_pul_mod_dclass"] ?? "") != ""
                || (Request["ttg23_mod_pul_mod_type"] ?? "") != "") {
                    ColMap.Clear();
                    ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
                    ColMap["in_no"] = "'" + RSno + "'";
                    ColMap["mod_field"] = "'mod_pul'";

                    string[] field = { "mod_type", "new_no", "mod_dclass" };
                    foreach (string f in field) {
                        ColMap[f] = Util.dbnull(Request["ttg23_mod_pul_" + f]);
                    }

                    SQL = "insert into dmt_tranlist " + ColMap.GetInsertSQL();
                    conn.ExecuteNonQuery(SQL);

                    SQL = "update dmt_tran set mod_pul='Y' where in_scode='" + Request["F_tscode"] + "' and in_no = '" + RSno + "'";
                    conn.ExecuteNonQuery(SQL);
                }

                if ((Request["ttg24_mod_pul_new_no"] ?? "") != "" || (Request["ttg24_mod_pul_mod_dclass"] ?? "") != ""
                || (Request["ttg24_mod_pul_ncname1"] ?? "") != "" || (Request["ttg24_mod_pul_mod_type"] ?? "") != "") {
                    ColMap.Clear();
                    ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
                    ColMap["in_no"] = "'" + RSno + "'";
                    ColMap["mod_field"] = "'mod_pul'";

                    string[] field = { "mod_type", "new_no", "mod_dclass", "ncname1" };
                    foreach (string f in field) {
                        ColMap[f] = Util.dbnull(Request["ttg24_mod_pul_" + f]);
                    }

                    SQL = "insert into dmt_tranlist " + ColMap.GetInsertSQL();
                    conn.ExecuteNonQuery(SQL);

                    SQL = "update dmt_tran set mod_pul='Y' where in_scode='" + Request["F_tscode"] + "' and in_no = '" + RSno + "'";
                    conn.ExecuteNonQuery(SQL);
                }

                //據以異議商標/標章
                if (Convert.ToInt32("0" + Request["ttg2_mod_aprep_mod_count"]) > 0) {
                    for (int i = 1; i <= Convert.ToInt32("0" + Request["ttg2_mod_aprep_mod_count"]); i++) {
                        SQL = "insert into dmt_tranlist(in_scode,in_no,mod_field,mod_count,ncname1,new_no) values (";
                        SQL += "'" + Request["F_tscode"] + "','" + RSno + "','mod_aprep'";
                        SQL += "," + Util.dbnull(Request["ttg2_mod_aprep_mod_count"]) + "," + Util.dbchar(Request["ttg2_mod_aprep_ncname1_" + i]) + "";
                        SQL += "," + Util.dbchar(Request["ttg2_mod_aprep_new_no_" + i]) + ")";
                        conn.ExecuteNonQuery(SQL);
                    }
                    SQL = "update dmt_tran set mod_aprep='Y' where in_scode='" + Request["F_tscode"] + "' and in_no = '" + RSno + "'";
                    conn.ExecuteNonQuery(SQL);
                }

                //變換撤銷商標圖樣
                if ((Request["ttg2_mod_dmt_ncname1"] ?? "") != "" || (Request["ttg2_mod_dmt_ncname2"] ?? "") != ""
                || (Request["ttg2_mod_dmt_nename1"] ?? "") != "" || (Request["ttg2_mod_dmt_nename2"] ?? "") != ""
                || (Request["ttg2_mod_dmt_ncrep"] ?? "") != "" || (Request["ttg2_mod_dmt_nerep"] ?? "") != ""
                || (Request["ttg2_mod_dmt_neaddr1"] ?? "") != "" || (Request["ttg2_mod_dmt_neaddr2"] ?? "") != ""
                || (Request["ttg2_mod_dmt_neaddr3"] ?? "") != "" || (Request["ttg2_mod_dmt_neaddr4"] ?? "") != ""
                ) {
                    SQL = "INSERT INTO dmt_tranlist(in_scode,in_no,mod_field,ncname1,ncname2,nename1,nename2,ncrep,nerep,neaddr1,neaddr2,neaddr3,neaddr4)";
                    SQL += "VALUES('" + Request["F_tscode"] + "','" + RSno + "','mod_dmt'";
                    SQL += "," + Util.dbnull(Sys.Path2Btbrt(DO1_mod_dmt_ncname1)) + "," + Util.dbnull(Sys.Path2Btbrt(DO1_mod_dmt_ncname2));
                    SQL += "," + Util.dbnull(Sys.Path2Btbrt(DO1_mod_dmt_nename1)) + "," + Util.dbnull(Sys.Path2Btbrt(DO1_mod_dmt_nename2));
                    SQL += "," + Util.dbnull(Sys.Path2Btbrt(DO1_mod_dmt_ncrep)) + "," + Util.dbnull(Sys.Path2Btbrt(DO1_mod_dmt_nerep));
                    SQL += "," + Util.dbnull(Sys.Path2Btbrt(DO1_mod_dmt_neaddr1)) + "," + Util.dbnull(Sys.Path2Btbrt(DO1_mod_dmt_neaddr2));
                    SQL += "," + Util.dbnull(Sys.Path2Btbrt(DO1_mod_dmt_neaddr3)) + "," + Util.dbnull(Sys.Path2Btbrt(DO1_mod_dmt_neaddr4)) + ")";
                    conn.ExecuteNonQuery(SQL);

                    SQL = "update dmt_tran set mod_dmt='Y' where in_scode='" + Request["F_tscode"] + "' and in_no = '" + RSno + "'";
                    conn.ExecuteNonQuery(SQL);
                }
                break;
            case "DI1":
                string DI1_mod_dmt_ncname1 = move_file(RSno, Request["ttg3_mod_dmt_ncname1"], "-O1");
                string DI1_mod_dmt_ncname2 = move_file(RSno, Request["ttg3_mod_dmt_ncname2"], "-O2");
                string DI1_mod_dmt_nename1 = move_file(RSno, Request["ttg3_mod_dmt_nename1"], "-O3");
                string DI1_mod_dmt_nename2 = move_file(RSno, Request["ttg3_mod_dmt_nename2"], "-O4");
                string DI1_mod_dmt_ncrep = move_file(RSno, Request["ttg3_mod_dmt_ncrep"], "-O5");
                string DI1_mod_dmt_nerep = move_file(RSno, Request["ttg3_mod_dmt_nerep"], "-O6");
                string DI1_mod_dmt_neaddr1 = move_file(RSno, Request["ttg3_mod_dmt_neaddr1"], "-O7");
                string DI1_mod_dmt_neaddr2 = move_file(RSno, Request["ttg3_mod_dmt_neaddr2"], "-O8");
                string DI1_mod_dmt_neaddr3 = move_file(RSno, Request["ttg3_mod_dmt_neaddr3"], "-O9");
                string DI1_mod_dmt_neaddr4 = move_file(RSno, Request["ttg3_mod_dmt_neaddr4"], "-O10");

                ColMap.Clear();
                foreach (var key in Request.Form.Keys) {
                    string colkey = key.ToString().ToLower();
                    string colValue = Request[colkey];

                    //取1~4碼
                    if (colkey.Left(4) == "tfz3") {
                        ColMap[colkey.Substring(5)] = Util.dbnull(colValue);
                    }
                }
                ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
                ColMap["in_no"] = "'" + RSno + "'";
                ColMap["tr_date"] = "getdate()";
                ColMap["tr_scode"] = "'" + Session["scode"] + "'";
                ColMap["seq"] = Util.dbnull(Request["tfzb_seq"]);
                ColMap["seq1"] = Util.dbchar(Request["tfzb_seq1"]);
                SQL = "insert into dmt_tran " + ColMap.GetInsertSQL();
                conn.ExecuteNonQuery(SQL);

                //*****變更被申請撤銷人資料
                if (Convert.ToInt32("0" + Request["DI1_apnum"]) > 0) {
                    for (int k = 1; k <= Convert.ToInt32("0" + Request["DI1_apnum"]); k++) {
                        SQL = "insert into dmt_tranlist(in_scode,in_no,mod_field,ncname1,ncname2,ncrep,nzip,naddr1,naddr2) values (";
                        SQL += "'" + Request["F_tscode"] + "','" + RSno + "','mod_ap'";
                        SQL += "," + Util.dbchar(Request["ttg3_mod_ap_ncname1_" + k]) + "," + Util.dbchar(Request["ttg3_mod_ap_ncname2_" + k]) + "";
                        SQL += "," + Util.dbchar(Request["ttg3_mod_ap_ncrep_" + k]) + "," + Util.dbchar(Request["ttg3_mod_ap_nzip_" + k]) + "";
                        SQL += "," + Util.dbchar(Request["ttg3_mod_ap_naddr1_" + k]) + "," + Util.dbchar(Request["ttg3_mod_ap_naddr2_" + k]) + ")";
                        conn.ExecuteNonQuery(SQL);
                    }
                    SQL = "update dmt_tran set mod_ap='Y' where in_scode='" + Request["F_tscode"] + "' and in_no = '" + RSno + "'";
                    conn.ExecuteNonQuery(SQL);
                }

                //*****廢止聲明
                if ((Request["ttg31_mod_pul_new_no"] ?? "") != "" || (Request["ttg31_mod_pul_ncname1"] ?? "") != ""
                || (Request["ttg31_mod_pul_mod_type"] ?? "") != "") {
                    ColMap.Clear();
                    ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
                    ColMap["in_no"] = "'" + RSno + "'";
                    ColMap["mod_field"] = "'mod_pul'";

                    string[] field = { "mod_type", "new_no", "ncname1" };
                    foreach (string f in field) {
                        ColMap[f] = Util.dbnull(Request["ttg31_mod_pul_" + f]);
                    }

                    SQL = "insert into dmt_tranlist " + ColMap.GetInsertSQL();
                    conn.ExecuteNonQuery(SQL);

                    SQL = "update dmt_tran set mod_pul='Y' where in_scode='" + Request["F_tscode"] + "' and in_no = '" + RSno + "'";
                    conn.ExecuteNonQuery(SQL);
                }

                if ((Request["ttg32_mod_pul_mod_type"] ?? "") != "") {
                    ColMap.Clear();
                    ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
                    ColMap["in_no"] = "'" + RSno + "'";
                    ColMap["mod_field"] = "'mod_pul'";

                    string[] field = { "mod_type" };
                    foreach (string f in field) {
                        ColMap[f] = Util.dbnull(Request["ttg32_mod_pul_" + f]);
                    }
                    SQL = "insert into dmt_tranlist " + ColMap.GetInsertSQL();
                    conn.ExecuteNonQuery(SQL);

                    SQL = "update dmt_tran set mod_pul='Y' where in_scode='" + Request["F_tscode"] + "' and in_no = '" + RSno + "'";
                    conn.ExecuteNonQuery(SQL);
                }

                if ((Request["ttg33_mod_pul_new_no"] ?? "") != "" || (Request["ttg33_mod_pul_mod_dclass"] ?? "") != ""
                || (Request["ttg33_mod_pul_mod_type"] ?? "") != "") {
                    ColMap.Clear();
                    ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
                    ColMap["in_no"] = "'" + RSno + "'";
                    ColMap["mod_field"] = "'mod_pul'";

                    string[] field = { "mod_type", "new_no", "mod_dclass" };
                    foreach (string f in field) {
                        ColMap[f] = Util.dbnull(Request["ttg33_mod_pul_" + f]);
                    }

                    SQL = "insert into dmt_tranlist " + ColMap.GetInsertSQL();
                    conn.ExecuteNonQuery(SQL);

                    SQL = "update dmt_tran set mod_pul='Y' where in_scode='" + Request["F_tscode"] + "' and in_no = '" + RSno + "'";
                    conn.ExecuteNonQuery(SQL);
                }

                if ((Request["ttg34_mod_pul_new_no"] ?? "") != "" || (Request["ttg34_mod_pul_mod_dclass"] ?? "") != ""
                || (Request["ttg34_mod_pul_ncname1"] ?? "") != "" || (Request["ttg34_mod_pul_mod_type"] ?? "") != "") {
                    ColMap.Clear();
                    ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
                    ColMap["in_no"] = "'" + RSno + "'";
                    ColMap["mod_field"] = "'mod_pul'";

                    string[] field = { "mod_type", "new_no", "mod_dclass", "ncname1" };
                    foreach (string f in field) {
                        ColMap[f] = Util.dbnull(Request["ttg34_mod_pul_" + f]);
                    }

                    SQL = "insert into dmt_tranlist " + ColMap.GetInsertSQL();
                    conn.ExecuteNonQuery(SQL);

                    SQL = "update dmt_tran set mod_pul='Y' where in_scode='" + Request["F_tscode"] + "' and in_no = '" + RSno + "'";
                    conn.ExecuteNonQuery(SQL);
                }

                //據以異議商標/標章
                if (Convert.ToInt32("0" + Request["ttg3_mod_aprep_mod_count"]) > 0) {
                    for (int i = 1; i <= Convert.ToInt32("0" + Request["ttg3_mod_aprep_mod_count"]); i++) {
                        SQL = "insert into dmt_tranlist(in_scode,in_no,mod_field,mod_count,ncname1,new_no) values (";
                        SQL += "'" + Request["F_tscode"] + "','" + RSno + "','mod_aprep'";
                        SQL += "," + Util.dbnull(Request["ttg3_mod_aprep_mod_count"]) + "," + Util.dbchar(Request["ttg3_mod_aprep_ncname1_" + i]) + "";
                        SQL += "," + Util.dbchar(Request["ttg3_mod_aprep_new_no_" + i]) + ")";
                        conn.ExecuteNonQuery(SQL);
                    }
                    SQL = "update dmt_tran set mod_aprep='Y' where in_scode='" + Request["F_tscode"] + "' and in_no = '" + RSno + "'";
                    conn.ExecuteNonQuery(SQL);
                }

                //變換撤銷商標圖樣
                if ((Request["ttg3_mod_dmt_ncname1"] ?? "") != "" || (Request["ttg3_mod_dmt_ncname2"] ?? "") != ""
                || (Request["ttg3_mod_dmt_nename1"] ?? "") != "" || (Request["ttg3_mod_dmt_nename2"] ?? "") != ""
                || (Request["ttg3_mod_dmt_ncrep"] ?? "") != "" || (Request["ttg3_mod_dmt_nerep"] ?? "") != ""
                || (Request["ttg3_mod_dmt_neaddr1"] ?? "") != "" || (Request["ttg3_mod_dmt_neaddr2"] ?? "") != ""
                || (Request["ttg3_mod_dmt_neaddr3"] ?? "") != "" || (Request["ttg3_mod_dmt_neaddr4"] ?? "") != ""
                ) {
                    SQL = "INSERT INTO dmt_tranlist(in_scode,in_no,mod_field,ncname1,ncname2,nename1,nename2,ncrep,nerep,neaddr1,neaddr2,neaddr3,neaddr4)";
                    SQL += "VALUES('" + Request["F_tscode"] + "','" + RSno + "','mod_dmt'";
                    SQL += "," + Util.dbnull(Sys.Path2Btbrt(DI1_mod_dmt_ncname1)) + "," + Util.dbnull(Sys.Path2Btbrt(DI1_mod_dmt_ncname2));
                    SQL += "," + Util.dbnull(Sys.Path2Btbrt(DI1_mod_dmt_nename1)) + "," + Util.dbnull(Sys.Path2Btbrt(DI1_mod_dmt_nename2));
                    SQL += "," + Util.dbnull(Sys.Path2Btbrt(DI1_mod_dmt_ncrep)) + "," + Util.dbnull(Sys.Path2Btbrt(DI1_mod_dmt_nerep));
                    SQL += "," + Util.dbnull(Sys.Path2Btbrt(DI1_mod_dmt_neaddr1)) + "," + Util.dbnull(Sys.Path2Btbrt(DI1_mod_dmt_neaddr2));
                    SQL += "," + Util.dbnull(Sys.Path2Btbrt(DI1_mod_dmt_neaddr3)) + "," + Util.dbnull(Sys.Path2Btbrt(DI1_mod_dmt_neaddr4)) + ")";
                    conn.ExecuteNonQuery(SQL);

                    SQL = "update dmt_tran set mod_dmt='Y' where in_scode='" + Request["F_tscode"] + "' and in_no = '" + RSno + "'";
                    conn.ExecuteNonQuery(SQL);
                }
                break;
            default:
                //寫入商品類別檔
                insert_casedmt_good(conn, RSno);

                if ((Request["tfy_arcase"] ?? "").Left(3) == "DE1") {
                    SQL = "INSERT INTO dmt_tran(in_scode,in_no,other_item,other_item1,other_item2,tran_remark1,tran_mark,tr_date,tr_scode,seq,seq1)";
                    SQL += " values ('" + Request["F_tscode"] + "','" + RSno + "'," + Util.dbchar(Request["fr4_other_item"]) + "";
                    SQL += "," + Util.dbchar(Request["fr4_other_item1"]) + "," + Util.dbchar(Request["fr4_other_item2"]) + "";
                    SQL += "," + Util.dbchar(Request["fr4_tran_remark1"]) + "," + Util.dbchar(Request["fr4_tran_mark"]) + "";
                    SQL += ",getdate(),'" + Session["scode"] + "',";
                    SQL += Util.dbnull(Request["tfzb_seq"]) + "," + Util.dbchar(Request["tfzb_seq1"]) + ")";
                    conn.ExecuteNonQuery(SQL);
                    //新增對照當事人資料
                    for (int k = 1; k <= Convert.ToInt32("0" + Request["de1_apnum"]); k++) {
                        SQL = "insert into dmt_tranlist(in_scode,in_no,mod_field,ncname1,naddr1) values (";
                        SQL += "'" + Request["F_tscode"] + "','" + RSno + "','mod_client'";
                        SQL += "," + Util.dbchar(Request["tfr4_ncname1_" + k]) + "," + Util.dbchar(Request["tfr4_naddr1_" + k]) + ")";
                        conn.ExecuteNonQuery(SQL);
                    }
                } else if ((Request["tfy_arcase"] ?? "").Left(3) == "DE2") {
                    SQL = "INSERT INTO dmt_tran(in_scode,in_no,other_item,other_item1,other_item2,tran_remark1,tr_date,tr_scode,seq,seq1)";
                    SQL += " values ('" + Request["F_tscode"] + "','" + RSno + "'," + Util.dbchar(Request["fr4_other_item"]) + ",";
                    SQL += "" + Util.dbchar(Request["fr4_other_item1"]) + "," + Util.dbchar(Request["fr4_other_item2"]) + ",";
                    SQL += "" + Util.dbchar(Request["fr4_tran_remark1"]) + ",getdate(),'" + Session["scode"] + "',";
                    SQL += Util.dbnull(Request["tfzb_seq"]) + "," + Util.dbchar(Request["tfzb_seq1"]) + ")";
                    conn.ExecuteNonQuery(SQL);
                } else {
                    SQL = "INSERT INTO dmt_tran(in_scode,in_no,tran_remark1,tr_date,tr_scode,seq,seq1,agt_no1)";
                    SQL += " values ('" + Request["F_tscode"] + "','" + RSno + "'," + Util.dbchar(Request["tfg1_tran_remark1"]) + "";
                    SQL += ",getdate(),'" + Session["scode"] + "',";
                    SQL += Util.dbnull(Request["tfzb_seq"]) + "," + Util.dbchar(Request["tfzb_seq1"]) + "," + Util.dbnull(Request["tfg1_agt_no1"]) + ")";
                    conn.ExecuteNonQuery(SQL);
                }
                break;
        }

        //寫入交辦申請人檔
        insert_dmt_temp_ap(conn, RSno, "0");

        //*****新增文件上傳
        insert_dmt_attach(conn, RSno);

        //後續交辦作業，更新營洽官收確認紀錄檔grconf_dmt.job_no
        upd_grconf_job_no(conn, RSno);

        //更新客戶主檔最近立案日
        upd_dmt_date(conn, RSno);
    }

    /// <summary>
    /// 其他
    /// </summary>
    private void addZZ(DBHelper conn, string RSno) {
        //寫入case_dmt
        insert_case_dmt(conn, RSno);

        //寫入dmt_temp
        insert_dmt_temp(conn, RSno);

        //寫入接洽費用檔
        insert_caseitem_dmt(conn, RSno);

        //寫入商品類別檔
        insert_casedmt_good(conn, RSno);

        //****新增展覽優先權資料
        insert_casedmt_show(conn, RSno, "0");

        //寫入交辦申請人檔
        insert_dmt_temp_ap(conn, RSno, "0");

        //***異動檔
        if ((Request["tfy_arcase"] ?? "").Left(3) == "FOB") {
            if ((Request["tfg1_other_item"] ?? "") != "") {
                SQL = "INSERT INTO dmt_tran(in_scode,in_no,other_item,tr_date,tr_scode,seq,seq1,agt_no1)";
                SQL += " values (" + Util.dbchar(Request["F_tscode"]) + ",'" + RSno + "'," + Util.dbnull(Request["tfg1_other_item"]);
                SQL += ",getdate(),'" + Session["scode"] + "'";
                SQL += "," + Util.dbnull(Request["tfg1_seq"]) + "," + Util.dbchar(Request["tfg1_seq1"]) + "," + Util.dbchar(Request["tfg1_agt_no1"]) + ")";
                conn.ExecuteNonQuery(SQL);
            }
        } else if ((Request["tfy_arcase"] ?? "").Left(3) == "AD7") {
            SQL = "INSERT INTO dmt_tran(in_scode,in_no,other_item,other_item1,other_item2,tran_remark1,tran_mark,tr_date,tr_scode,seq,seq1)";
            SQL += " values ('" + Request["F_tscode"] + "','" + RSno + "'," + Util.dbchar(Request["fr4_other_item"]) + "";
            SQL += "," + Util.dbchar(Request["fr4_other_item1"]) + "," + Util.dbchar(Request["fr4_other_item2"]) + "";
            SQL += "," + Util.dbchar(Request["fr4_tran_remark1"]) + "," + Util.dbchar(Request["fr4_tran_mark"]) + "";
            SQL += ",getdate(),'" + Session["scode"] + "'";
            SQL += "," + Util.dbnull(Request["tfg1_seq"]) + "," + Util.dbchar(Request["tfzb_seq1"]) + ")";
            conn.ExecuteNonQuery(SQL);

            //新增對照當事人資料
            for (int k = 1; k <= Convert.ToInt32("0" + Request["de1_apnum"]); k++) {
                SQL = "insert into dmt_tranlist(in_scode,in_no,mod_field,ncname1,naddr1) values (";
                SQL += "'" + Request["F_tscode"] + "','" + RSno + "','mod_client'";
                SQL += "," + Util.dbchar(Request["tfr4_ncname1_" + k]);
                SQL += "," + Util.dbchar(Request["tfr4_naddr1_" + k]) + ")";
                conn.ExecuteNonQuery(SQL);
            }
        } else if ((Request["tfy_arcase"] ?? "").Left(3) == "AD8") {
            SQL = "INSERT INTO dmt_tran(in_scode,in_no,other_item,other_item1,other_item2,tran_remark1,tr_date,tr_scode,seq,seq1)";
            SQL += " values ('" + Request["F_tscode"] + "','" + RSno + "'," + Util.dbchar(Request["fr4_other_item"]) + "";
            SQL += "," + Util.dbchar(Request["fr4_other_item1"]) + "," + Util.dbchar(Request["fr4_other_item2"]) + "";
            SQL += "," + Util.dbchar(Request["fr4_tran_remark1"]) + ",getdate(),'" + Session["scode"] + "'";
            SQL += "," + Util.dbnull(Request["tfg1_seq"]) + ",'" + Util.dbchar(Request["tfzb_seq1"]) + ")";
            conn.ExecuteNonQuery(SQL);
        } else if ((Request["tfy_arcase"] ?? "").Left(3) == "FOF") {
            SQL = "insert into dmt_tran(in_scode,in_no,seq,seq1,agt_no1,debit_money,other_item,other_item1,other_item2,tr_date,tr_scode) ";
            SQL += "values ('" + Request["F_tscode"] + "','" + RSno + "'," + Util.dbnull(Request["tfg1_seq"]) + "," + Util.dbchar(Request["tfg1_seq1"]) + "";
            SQL += "," + Util.dbchar(Request["tfzf_agt_no1"]) + "," + Util.dbchar(Request["tfzf_debit_money"]) + "," + Util.dbchar(Request["tfzf_other_item"]) + "";
            SQL += "," + Util.dbchar(Request["tfzf_other_item1"]) + "," + Util.dbchar(Request["tfzf_other_item2"]);
            SQL += ",getdate(),'" + Session["scode"] + "')";
            conn.ExecuteNonQuery(SQL);
        } else if ((Request["tfy_arcase"] ?? "").Left(3) == "FB7") {
            SQL = "insert into dmt_tran(in_scode,in_no,seq,seq1,agt_no1,other_item,tr_date,tr_scode) ";
            SQL += "values ('" + Request["F_tscode"] + "','" + RSno + "'," + Util.dbchar(Request["tfzb_seq"]) + "," + Util.dbchar(Request["tfzb_seq1"]) + "";
            SQL += "," + Util.dbchar(Request["tfb7_agt_no1"]) + "," + Util.dbchar(Request["tfb7_other_item"]) + "";
            SQL += ",getdate(),'" + Session["scode"] + "')";
            conn.ExecuteNonQuery(SQL);
        } else if ((Request["tfy_arcase"] ?? "").Left(3) == "FW1") {
            SQL = "INSERT INTO dmt_tran(in_scode,in_no,mod_claim1,tran_remark1,tr_date,tr_scode,seq,seq1,agt_no1,other_item)";
            SQL += " values ('" + Request["F_tscode"] + "','" + RSno + "'," + Util.dbchar(Request["tfw1_mod_claim1"]) + "";
            SQL += "," + Util.dbnull(Request["tfw1_tran_remark1"]) + ",getdate(),'" + Session["scode"] + "'";
            SQL += "," + Util.dbnull(Request["tfg1_seq"]) + "," + Util.dbchar(Request["tfg1_seq1"]) + "";
            SQL += "," + Util.dbchar(Request["tfg1_agt_no1"]) + "," + Util.dbchar(Request["tfw1_other_item"]) + ")";
            conn.ExecuteNonQuery(SQL);
        } else {
            SQL = "INSERT INTO dmt_tran(in_scode,in_no,tran_remark1,tr_date,tr_scode,seq,seq1,agt_no1)";
            SQL += " values ('" + Request["F_tscode"] + "','" + RSno + "'," + Util.dbnull(Request["tfg1_tran_remark1"]) + "";
            SQL += ",getdate(),'" + Session["scode"] + "'";
            SQL += "," + Util.dbnull(Request["tfg1_seq"]) + "," + Util.dbchar(Request["tfg1_seq1"]) + "," + Util.dbchar(Request["tfg1_agt_no1"]) + ")";
            conn.ExecuteNonQuery(SQL);
        }

        if ((Request["tfg1_other_item"] ?? "") != "") {
            for (int i = 2; i <= 11; i++) {
                if ((Request["ttz1_P" + i] ?? "") != "") {
                    SQL = "INSERT INTO dmt_tranlist(in_scode,in_no,mod_field,mod_type,mod_dclass,new_no) values (";
                    SQL += " '" + Request["F_tscode"] + "','" + RSno + "','other_item'," + Util.dbchar(Request["ttz1_P" + i]) + "";
                    SQL += "," + Util.dbchar(Request["P" + i + "_mod_dclass"]) + "," + Util.dbchar(Request["P" + i + "_new_no"]) + ")";
                    conn.ExecuteNonQuery(SQL);
                }
            }
        }
        //*****新增文件上傳
        insert_dmt_attach(conn, RSno);

        //後續交辦作業，更新營洽官收確認紀錄檔grconf_dmt.job_no
        upd_grconf_job_no(conn, RSno);

        //更新客戶主檔最近立案日
        upd_dmt_date(conn, RSno);
    }
</script>

<%Response.Write(strOut.ToString());%>
