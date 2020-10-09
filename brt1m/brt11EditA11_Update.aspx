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
    protected Dictionary<string, string> ColMap = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);

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
        sfile.getFileServer(Sys.GetSession("SeBranch"), prgid);//檔案上傳相關設定

        string SQL = "";
        object objResult = null;
        using (DBHelper conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST")) {
            //入case_dmt_log
            Sys.insert_log_table(conn, "U", prgid, "case_dmt", "in_scode;in_no", Request["in_scode"] + ";" + Request["in_no"], "brt12國內案編修暨交辦作業");

            //入caseitem_dmt_log
            Sys.insert_log_table(conn, "U", prgid, "caseitem_dmt", "in_scode;in_no", Request["in_scode"] + ";" + Request["in_no"], "");
            SQL = "delete from caseitem_dmt where in_no='" + Request["in_no"] + "' and in_scode='" + Request["in_scode"] + "'";
            conn.ExecuteNonQuery(SQL);

            //商品入log_table
            Sys.insert_log_table(conn, "U", prgid, "casedmt_good", "in_no;in_scode", Request["in_no"] + ";" + Request["in_scode"], "");
            SQL = "delete from casedmt_good where in_no='" + Request["in_no"] + "' and in_scode='" + Request["in_scode"] + "'";
            conn.ExecuteNonQuery(SQL);

            //展覽優先權入log_table
            Sys.insert_log_table(conn, "U", prgid, "casedmt_show", "in_no;case_sqlno", Request["in_no"] + ";0", "");
            SQL = "delete from casedmt_show where in_no='" + Request["in_no"] + "' and case_sqlno=0";
            conn.ExecuteNonQuery(SQL);
            
            //寫入case_dmt
            SQL = "UPDATE case_dmt set ";
            foreach (var key in Request.Form.Keys) {
                string colkey = key.ToString().ToLower();
                string colValue = Request[colkey];
                
                //取2~4碼(直接用substr若欄位名稱太短會壞掉)
                if (colkey.Left(4).Substring(1) == "fy_") {
                    if (colkey.Left(1) == "d") {
                        SQL += " " + colkey.Substring(4) + "=" + Util.dbnull(colValue) + ",";
                    }
                    else if (colkey.Left(1) == "n") {
                        SQL += " " + colkey.Substring(4) + "=" + Util.dbzero(colValue) + ",";
                    }
                    else {
                        if (colkey == "tfy_arcase") {
                            SQL += " " + colkey.Substring(4) + "=" + Util.dbchar(colValue) + ",";
                        }
                        else {
                            SQL += " " + colkey.Substring(4) + "=" + Util.dbnull(colValue) + ",";
                        }
                    }
                }
            }
            if (Request["tfy_discount_chk"] == null) {
                SQL += " discount_chk='N',";
            }
            if (Request["tfy_ar_chk"] == null) {
                SQL += " ar_chk='N',";
            }
            if (Request["tfy_ar_chk1"] == null) {
                SQL += " ar_chk1='N',";
            }
            //****會計檢核2013/9/16增加，不需請款或大陸進口案不在線上請款，不需會計檢核
            if (Request["tfy_ar_code"] == "X" || Request["tfy_ar_code"] == "M") {
                SQL += " acc_chk = 'X',";
            } else {
                SQL += " acc_chk = 'N',";
            }
	        //*****契約書後補註記
            if (Request["tfy_contract_flag"] == null) {
                SQL += " contract_flag='N',";
            }
            SQL += " in_scode='" + Request["F_tscode"] + "' ";
            SQL += " where in_scode = '" + Request["in_scode"] + "' and in_no = '" + Request["In_no"] + "'";
            conn.ExecuteNonQuery(SQL);

            //*****todo依案性新增內商的案件內容
            string aa = Request["draw_file1"] ?? "";
            string newfilename = "";
            if (aa != "") {
                //2013/11/26修改可以中文檔名上傳及虛擬路徑
                //string strpath = "/btbrt/" + Session["seBranch"] + "T/temp";
                string strpath = sfile.gbrWebDir + "/temp";
                string attach_name = Request["in_no"] + System.IO.Path.GetExtension(aa);//重新命名檔名
                newfilename = strpath + "/" + attach_name;//存在資料庫路徑
                Sys.RenameFile(Sys.Path2Nbtbrt(aa), strpath + "/" + attach_name, true);
            }

            //dmt_temp
            Sys.insert_log_table(conn, "U", prgid, "dmt_temp", "in_no;in_scode", Request["in_no"] + ";" + Request["in_scode"], "");
            ColMap.Clear();
            foreach (var key in Request.Form.Keys) {
                string colkey = key.ToString().ToLower();
                string colValue = Request[colkey];
                
                //取2~5碼(直接用substr若欄位名稱太短會壞掉)
                if (colkey.Left(5).Substring(1) == "fz1_") {
                    if (colkey.Left(1) == "d") {
                        ColMap[colkey.Substring(5)]= Util.dbnull(colValue);
                    } else if (colkey.Left(1) == "n") {
                        ColMap[colkey.Substring(5)] = Util.dbzero(colValue);
                    } else {
                        ColMap[colkey.Substring(5)] = Util.dbnull(colValue);
                    }
                }
            }
            
            if (Request["tfd1_good_name"] != null) {//證明內容
                ColMap["good_name"] = Util.dbchar(Request["tfd1_good_name"]);
            }
            if (Request["tf91_good_name"] != null) {//表彰內容
                ColMap["good_name"] = Util.dbchar(Request["tf91_good_name"]);
            }
            ColMap["draw_file"] = Util.dbchar(Sys.Path2Btbrt(newfilename));
            ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
            ColMap["tr_date"] = "'" + DateTime.Today.ToShortDateString() + "'";
            ColMap["tr_scode"] = "'" + Session["scode"] + "'";
            
            SQL = "UPDATE dmt_temp set " + ColMap.GetUpdateSQL();
            SQL += " where in_scode = '" + Request["in_scode"] + "' and in_no = '" + Request["In_no"] + "'";
            conn.ExecuteNonQuery(SQL);
            
            //****主委辦案性
            ColMap.Clear();
            ColMap["in_scode"]=Util.dbchar(Request["F_tscode"]);
            ColMap["in_no"]=Util.dbchar(Request["in_no"]);
            ColMap["item_sql"]="'0'";
            ColMap["seq1"]=Util.dbchar(Request["tfz1_seq1"]);
            ColMap["item_arcase"]=Util.dbchar(Request["tfy_arcase"]);
            ColMap["item_service"]=Util.dbchar(Request["nfyi_service"]);
            ColMap["item_fees"]=Util.dbchar(Request["nfyi_fees"]);
            ColMap["item_count"]="'1'";
            
            SQL = "insert into caseitem_dmt "+ ColMap.GetInsertSQL();
            //Response.Write(SQL + "<HR>");
            conn.ExecuteNonQuery(SQL);

            //****次委辦案性
            for (int i = 1; i <= Convert.ToInt32("0" + Request["TaCount"]); i++) {
                if ((Request["nfyi_item_Arcase_" + i] ?? "") != "") {
                    ColMap.Clear();
                    ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
                    ColMap["in_no"] = Util.dbchar(Request["in_no"]);
                    ColMap["item_sql"] = "'" + i + "'";
                    ColMap["seq1"] = Util.dbchar(Request["tfz1_seq1"]);
                    ColMap["item_arcase"] = Util.dbchar(Request["nfyi_item_Arcase_" + i]);
                    ColMap["item_service"] = Util.dbchar(Request["nfyi_Service_" + i]);
                    ColMap["item_fees"] = Util.dbchar(Request["nfyi_fees_" + i]);
                    ColMap["item_count"] = Util.dbchar(Request["nfyi_item_count_" + i]);

                    SQL = "insert into caseitem_dmt " + ColMap.GetInsertSQL();
                    //Response.Write(SQL + "<HR>");
                    conn.ExecuteNonQuery(SQL);
                }
            }

            //****商品類別
            for (int i = 1; i <= Convert.ToInt32("0" + Request["num1"]); i++) {
                if ((Request["class1_" + i] ?? "") != "") {
                    ColMap.Clear();
                    ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
                    ColMap["in_no"] = Util.dbchar(Request["in_no"]);
                    ColMap["class"] = Util.dbchar(Request["class1_" + i]);
                    ColMap["dmt_grp_code"] = Util.dbchar(Request["grp_code1_" + i]);
                    ColMap["dmt_goodname"] = Util.dbchar(Request["good_name1_" + i]);
                    ColMap["dmt_goodcount"] = Util.dbchar(Request["good_count1_" + i]);
                    ColMap["tr_date"] = "'" + DateTime.Today.ToShortDateString() + "'";
                    ColMap["tr_scode"] = "'" + Session["scode"] + "'";

                    SQL = "insert into casedmt_good " + ColMap.GetInsertSQL();
                    //Response.Write(SQL + "<HR>");
                    conn.ExecuteNonQuery(SQL);
                }
            }

            //****新增展覽優先權資料
            for (int i = 1; i <= Convert.ToInt32("0" + Request["shownum"]); i++) {
                if ((Request["show_date_" + i] ?? "") != "" || (Request["show_name_" + i] ?? "") != "") {
                    ColMap.Clear();
                    ColMap["in_no"] = Util.dbchar(Request["in_no"]);
                    ColMap["case_sqlno"] = "0";
                    ColMap["show_date"] = Util.dbnull(Request["show_date_" + i]);
                    ColMap["show_name"] = Util.dbnull(Request["show_name_" + i]);
                    ColMap["tr_date"] = "getdate()";
                    ColMap["tr_scode"] = "'" + Session["scode"] + "'";

                    SQL = "insert into casedmt_show " + ColMap.GetInsertSQL();
                    //Response.Write(SQL + "<HR>");
                    conn.ExecuteNonQuery(SQL);
                }
            }

            //交辦申請人
            Sys.insert_log_table(conn, "U", prgid, "dmt_temp_ap", "in_no;case_sqlno", Request["in_no"] + ";0", "");
            SQL = "Delete dmt_temp_ap where in_no='" + Request["in_no"] + "' and case_sqlno=0";
            conn.ExecuteNonQuery(SQL);
            for (int i = 1; i <= Convert.ToInt32("0" + Request["apnum"]); i++) {
                ColMap.Clear();
                ColMap["in_no"] = Util.dbchar(Request["in_no"]);
                ColMap["case_sqlno"] = "0";
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

                SQL = "insert into dmt_temp_ap " + ColMap.GetInsertSQL();
                //Response.Write(SQL + "<HR>");
                conn.ExecuteNonQuery(SQL);
            }

            //*****文件上傳
            Sys.updmt_attach_forcase(Context, conn, prgid, (Request["in_no"]??""));

            conn.Commit();
            //conn.RollBack();

            if (Request["chkTest"] != "TEST") {
                strOut.AppendLine("<script language='javascript' type='text/javascript'>");
            }

            strOut.AppendLine("alert(\"資料更新成功\");");
            strOut.AppendLine("window.parent.tt.rows=\"100%,0%\";");

            if (Request["chkTest"] != "TEST") {
                strOut.AppendLine("<" + "/script>");
            }
        }
    }
</script>

<%Response.Write(strOut.ToString());%>
