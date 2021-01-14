<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.IO"%>
<%@ Import Namespace = "System.Linq"%>

<script runat="server">
    protected string HTProgCap = HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "Brt15ShowFP";//程式檔名前綴
    protected string HTProgCode = "brt15";//HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼//brt51客收確認,brta24官收確認,brta78轉案確認
    protected int HTProgRight = 0;
    protected string DebugStr = "";

    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected Dictionary<string, string> ColMap = new Dictionary<string, string>();
    protected StringBuilder strOut = new StringBuilder();
    
    Sys sfile = new Sys();//轉出單位
    Sys dfile = new Sys();//轉入單位
    
    protected string submitTask = "";
    protected string SQL = "";
    protected object objResult = null;

    protected string ltfx_seq1 = "";
    protected string in_no = "";
    protected string in_scode = "";
    
    DBHelper conn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    DBHelper connbr = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    DBHelper connm = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    private void Page_Unload(System.Object sender, System.EventArgs e) {
        if (conn != null) conn.Dispose();
        if (connbr != null) connbr.Dispose();
        if (connm != null) connm.Dispose();
    }

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");
        
        submitTask = (Request["submitTask"] ?? "").Trim();
        
        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        HTProgCap = myToken.Title;
        DebugStr = myToken.DebugStr;
        if (HTProgRight >= 0) {
            sfile.getFileServer(Request["tran_seq_branch"], "brt");//檔案上傳相關設定(轉出單位)
            dfile.getFileServer(Sys.GetSession("SeBranch"), "brt");//檔案上傳相關設定(轉入單位)

            connm = new DBHelper(Conn.MG).Debug(Request["chkTest"] == "TEST");
            conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
            connbr = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
            //2011/3/10因轉案增加連結轉出區所connection
            if (prgid == "brta78") {
                connbr = new DBHelper(Conn.brp(Request["branch"])).Debug(Request["chkTest"] == "TEST");
            }

            if(ReqVal.TryGet("tfx_seq1")==""){
                ltfx_seq1="_";
            }else{
                ltfx_seq1 = ReqVal.TryGet("tfx_seq1");
                if (ltfx_seq1.Left(1) == "-") {
                    ltfx_seq1 = ltfx_seq1.Substring(1);
                }
            }
    
            in_no=ReqVal.TryGet("in_no");
            in_scode=ReqVal.TryGet("in_scode");
            if (in_no == "") {
                SQL = "select max(in_no) as in_no,in_scode from dmt_temp ";
                SQL += "where seq =" + Request["tfx_seq"] + " and seq1='" + ltfx_seq1 + "'";
                SQL += "group by in_scode";
                using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
                    if (dr.Read()) {
                        in_no = dr.SafeRead("in_no", "");
                        in_scode = dr.SafeRead("in_scode", "");
                    }
                }
            }
    
            try {
                if (submitTask == "A") {//新增
                    doAdd();
                    strOut.AppendLine("<div align='center'><h1>案件主檔新增成功!!!</h1></div>");
                } else if (submitTask == "U") {//修改
                    doUpdate();
                    strOut.AppendLine("<div align='center'><h1>案件主檔修改成功!!!</h1></div>");
                } else if (submitTask == "D") {//刪除
                    doDel();
                    strOut.AppendLine("<div align='center'><h1>案件主檔刪除成功!!!</h1></div>");
                }

                //conn.Commit();
                //connbr.Commit();
                //connm.Commit();
                conn.RollBack();
                connbr.RollBack();
                connm.RollBack();
            }
            catch (Exception ex) {
                conn.RollBack();
                connbr.RollBack();
                connm.RollBack();
                Sys.errorLog(ex, conn.exeSQL, prgid);
                Sys.errorLog(ex, connbr.exeSQL, prgid);
                Sys.errorLog(ex, connm.exeSQL, prgid);
                if (submitTask == "A") {//新增
                    strOut.AppendLine("<div align='center'><h1>案件主檔新增失敗!!!</h1></div>");
                } else if (submitTask == "U") {//修改
                    strOut.AppendLine("<div align='center'><h1>案件主檔修改失敗!!!</h1></div>");
                } else if (submitTask == "D") {//刪除
                    strOut.AppendLine("<div align='center'><h1>案件主檔刪除失敗!!!</h1></div>");
                }

                throw;
            }
            finally {
                conn.Dispose();
                connbr.Dispose();
                connm.Dispose();
            }

            this.DataBind();
        }
    }

    private void doAdd() {
        if (prgid == "brta78") {
            if (ltfx_seq1 == "Z") {
                SQL = " update cust_code set sql = sql + 1 where code_type='Z' and cust_code='" + Sys.GetSession("sebranch") + "TZ'";
                conn.ExecuteNonQuery(SQL);
            } else {
                SQL = " update cust_code set sql = sql + 1 where code_type='Z' and cust_code='" + Sys.GetSession("sebranch") + "T_'";
                conn.ExecuteNonQuery(SQL);
            }
        }

        //入dmt
        SQL = "insert into dmt ";
        ColMap.Clear();
        ColMap["seq"] = Util.dbnull(Request["tfx_seq"]);
        ColMap["seq1"] = Util.dbchar(ltfx_seq1);
        ColMap["s_mark"] = Util.dbnull(Request["tfx_s_mark"]);
        ColMap["s_mark2"] = Util.dbnull(Request["tfx_s_mark2"]);
        ColMap["class"] = Util.dbnull(Request["tfx_class"]);
        ColMap["class_count"] = Util.dbnull(Request["tfx_class_count"]);
        ColMap["class_type"] = Util.dbnull(Request["tfx_class_type"]);
        ColMap["in_date"] = Util.dbnull(Request["tfx_in_date"]);
        ColMap["arcase_type"] = Util.dbnull(Request["arcase_type"]);
        ColMap["arcase_class"] = Util.dbnull(Request["arcase_class"]);
        ColMap["arcase"] = Util.dbnull(Request["tfx_arcase"]);
        ColMap["appl_name"] = Util.dbnull(Request["tfx_appl_name"]);
        ColMap["dmt_draw"] = Util.dbnull(Request["tfx_dmt_draw"]);
        ColMap["cust_area"] = Util.dbnull(Request["tfx_cust_area"]);
        ColMap["cust_seq"] = Util.dbnull(Request["tfx_cust_seq"]);
        ColMap["att_sql"] = Util.dbnull(Request["tfx_att_sql"]);
        ColMap["apsqlno"] = Util.dbnull(Request["apsqlno1"]);
        ColMap["apcust_no"] = Util.dbnull(Request["apcust_no_1"]);
        ColMap["agt_no"] = Util.dbnull(Request["tfx_agt_no"]);
        ColMap["apply_date"] = Util.dbnull(Request["tfx_apply_date"]);
        ColMap["apply_no"] = Util.dbnull(Request["tfx_apply_no"]);
        ColMap["issue_date"] = Util.dbnull(Request["tfx_issue_date"]);
        ColMap["issue_no"] = Util.dbnull(Request["tfx_issue_no"]);
        ColMap["open_date"] = Util.dbnull(Request["tfx_open_date"]);
        ColMap["rej_no"] = Util.dbnull(Request["tfx_rej_no"]);
        ColMap["prior_date"] = Util.dbnull(Request["tfx_prior_date"]);
        ColMap["prior_no"] = Util.dbnull(Request["tfx_prior_no"]);
        ColMap["prior_country"] = Util.dbnull(Request["tfx_prior_country"]);
        ColMap["term1"] = Util.dbnull(Request["tfx_term1"]);
        ColMap["term2"] = Util.dbnull(Request["tfx_term2"]);
        ColMap["tcn_ref"] = Util.dbnull(Request["tfx_tcn_ref"]);
        ColMap["ref_no1"] = Util.dbnull(Request["tfx_ref_no1"]);
        ColMap["ref_no2"] = Util.dbnull(Request["tfx_ref_no2"]);
        ColMap["ref_no3"] = Util.dbnull(Request["tfx_ref_no3"]);
        ColMap["mseq"] = Util.dbnull(Request["tfx_mseq"]);
        ColMap["mseq1"] = Util.dbnull(Request["tfx_mseq1"]);
        ColMap["end_date"] = Util.dbnull(Request["tfx_end_date"]);
        ColMap["end_code"] = Util.dbnull(Request["tfx_end_code"]);
        ColMap["renewal"] = Util.dbnull(Request["tfx_renewal"]);
        ColMap["scode"] = Util.dbnull(Request["tfx_scode"]);
        ColMap["rej_item"] = Util.dbnull(Request["tfx_rej_item"]);
        ColMap["step_grade"] = Util.dbnull(Request["tfx_step_grade"]);
        ColMap["mark"] = Util.dbchar("G");
        ColMap["pay_times"] = Util.dbnull(Request["tfx_pay_times"]);
        ColMap["pay_date"] = Util.dbnull(Request["tfx_pay_date"]);
        ColMap["auth_chk"] = Util.dbchar("N");
        ColMap["end_type"] = Util.dbnull(Request["end_type"]);
        ColMap["end_remark"] = Util.dbnull(Request["end_remark"]);
        ColMap["tran_flag"] = Util.dbchar(Request["tran_flag"]);
        ColMap["tran_seq_branch"] = Util.dbchar(Request["tran_seq_branch"]);
        ColMap["tran_seq"] = Util.dbnull(Request["tran_seq"]);
        ColMap["tran_seq1"] = Util.dbnull(Request["tran_seq1"]);
        ColMap["tran_remark"] = Util.dbchar(Request["tran_remark"]);
        ColMap["cust_prod"] = Util.dbchar(Request["tfx_cust_prod"]);
        if (prgid == "brta78") {
            ColMap["now_grade"] = Util.dbchar("1");
            ColMap["now_arcase_type"] = Util.dbchar(Request["now_arcase_type"]);
            ColMap["now_arcase_class"] = Util.dbchar(Request["now_arcase_class"]);
            ColMap["now_arcase"] = Util.dbchar(Request["tfx_now_arcase"]);
            ColMap["now_act_code"] = Util.dbchar(Request["now_act_code"]);
            ColMap["now_stat"] = Util.dbchar(Request["tfx_now_stat"]);
        }
        SQL += ColMap.GetInsertSQL();
        conn.ExecuteNonQuery(SQL);

        //入ndmt
        string draw_file = ReqVal.TryGet("tfx_draw_file");
        if (prgid == "brta78" && draw_file != "") {
            string sPath = sfile.gbrWebDir + "/" + Request["tran_seq_branch"] + "T";
            string dPath = dfile.gbrWebDir + "/" + Request["tfx_cust_area"].Left(1) + "T";
            string aa = Path.GetFileName(draw_file);//來源檔名(含Ext)
            string sExt = Path.GetExtension(draw_file);//來源副檔名
            string lname = Request["tfx_seq"];//新檔名
            if (ltfx_seq1 == "_" || ltfx_seq1 == "") {
                lname += sExt;
            } else {
                lname += ltfx_seq1 + sExt;
            }

            string old_fseq = ReqVal.TryGet("tran_seq").PadLeft(Sys.DmtSeq, '0');
            string fseq = ReqVal.TryGet("tfx_seq").PadLeft(Sys.DmtSeq, '0');

            FileInfo sFi = new FileInfo(Server.MapPath(sPath + old_fseq.Left(1) + "/" + old_fseq.Substring(1, 2) + "/" + aa));
            if (sFi.Exists) {
                Sys.RenameFile(sPath + old_fseq.Left(1) + "/" + old_fseq.Substring(1, 2) + "/" + aa
                    , dPath + fseq.Left(1) + "/" + fseq.Substring(1, 2) + "/" + aa
                    , true);
            } else {
                draw_file = "";
            }
        }
        SQL = "insert into ndmt ";
        ColMap.Clear();
        ColMap["branch"] = Util.dbchar(Sys.GetSession("seBranch"));
        ColMap["seq"] = Util.dbchar(Request["tfx_seq"]);
        ColMap["seq1"] = Util.dbchar(ltfx_seq1);
        ColMap["cappl_name"] = Util.dbnull(Request["tfx_cappl_name"]);
        ColMap["eappl_name"] = Util.dbnull(Request["tfx_eappl_name"]);
        ColMap["eappl_name1"] = Util.dbnull(Request["tfx_eappl_name1"]);
        ColMap["eappl_name2"] = Util.dbnull(Request["tfx_eappl_name2"]);
        ColMap["zname_type"] = Util.dbnull(Request["tfx_zname_type"]);
        ColMap["oappl_name"] = Util.dbnull(Request["tfx_oappl_name"]);
        ColMap["draw"] = Util.dbnull(Request["tfx_draw"]);
        ColMap["draw_file"] = Util.dbnull(Sys.Path2Btbrt(draw_file));
        ColMap["symbol"] = Util.dbnull(Request["tfx_symbol"]);
        ColMap["color"] = Util.dbnull(Request["tfx_color"]);
        ColMap["tran_date"] = "'" + DateTime.Today.ToShortDateString() + "'";
        ColMap["tran_scode"] = "'" + Session["scode"] + "'";
        SQL += ColMap.GetInsertSQL();
        conn.ExecuteNonQuery(SQL);

        //新增dmt_good
        for (int i = 1; i <= Convert.ToInt32("0" + Request["classnum"]); i++) {
            if ((Request["tfx_class_" + i] ?? "") != "" || (Request["good_delchk_" + i] ?? "") != "Y") {
                SQL = "insert into dmt_good ";
                ColMap.Clear();
                ColMap["seq"] = Util.dbnull(Request["tfx_seq"]);
                ColMap["seq1"] = Util.dbchar(ltfx_seq1);
                ColMap["class"] = Util.dbchar(Request["tfx_class_" + i]);
                ColMap["dmt_grp_code"] = Util.dbchar(Request["tfx_grp_code_" + i]);
                ColMap["dmt_goodname"] = Util.dbnull(Request["tfx_goodname_" + i]);
                ColMap["dmt_goodcount"] = Util.dbnull(Request["tfx_goodcount_" + i]);
                ColMap["in_scode"] = Util.dbchar(in_scode);
                ColMap["in_no"] = Util.dbchar(in_no);
                ColMap["tr_date"] = "'" + DateTime.Today.ToShortDateString() + "'";
                ColMap["tr_scode"] = "'" + Session["scode"] + "'";
                SQL += ColMap.GetInsertSQL();
                conn.ExecuteNonQuery(SQL);
            }
        }

        //新增dmt_show
        for (int i = 1; i <= Convert.ToInt32("0" + Request["shownum"]); i++) {
            if ((Request["show_date_" + i] ?? "") != "" || (Request["show_name_" + i] ?? "") != "") {
                SQL = "insert into dmt_show ";
                ColMap.Clear();
                ColMap["seq"] = Util.dbchar(Request["tfx_seq"]);
                ColMap["seq1"] = Util.dbchar(ltfx_seq1);
                ColMap["show_date"] = Util.dbnull(Request["show_date_" + i]);
                ColMap["show_name"] = Util.dbchar(Request["show_name_" + i]);
                ColMap["tr_date"] = "getdate()";
                ColMap["tr_scode"] = "'" + Session["scode"] + "'";
                SQL += ColMap.GetInsertSQL();
                conn.ExecuteNonQuery(SQL);
            }
        }

        //新增dmt_ap
        for (int i = 1; i <= Convert.ToInt32("0" + Request["apnum"]); i++) {
            SQL = "insert into dmt_ap ";
            ColMap.Clear();
            ColMap["branch"] = "'" + Session["seBranch"] + "'";
            ColMap["seq"] = Util.dbchar(Request["tfx_seq"]);
            ColMap["seq1"] = Util.dbchar(ltfx_seq1);
            ColMap["apsqlno"] = Util.dbchar(Request["apsqlno_" + i]);
            ColMap["server_flag"] = Util.dbchar(Request["server_flag_" + i]);
            ColMap["apcust_no"] = Util.dbchar(Request["apcust_no_" + i]);
            ColMap["ap_cname"] = Util.dbchar(Request["ap_cname_" + i]);
            ColMap["ap_ename"] = Util.dbchar(Request["ap_ename_" + i]);
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
            SQL += ColMap.GetInsertSQL();
            conn.ExecuteNonQuery(SQL);
        }

        //轉案
        if (prgid == "brta78") {
            //產生客收進度
            //取得收發文序號
            SQL = "select isnull(max(seq1),0)+1 rs_no from cust_code where code_type='Z' and cust_code='" + Session["seBranch"] + "TCR'";
            objResult = conn.ExecuteScalar(SQL);
            string main_rs_no = "";
            string rs_no = (objResult == DBNull.Value || objResult == null) ? "_" : objResult.ToString();
            if (main_rs_no == "") main_rs_no = rs_no;

            SQL = " update cust_code set sql = sql + 1 where code_type='Z' and cust_code='" + Session["seBranch"] + "TCR'";
            conn.ExecuteNonQuery(SQL);

            string Getrs_sqlno = Insert_Step(Request["tfx_seq"], ltfx_seq1, 1, main_rs_no, rs_no);

            //新增上傳檔案
            string tseq = ReqVal.TryGet("tfx_seq").PadLeft(Sys.DmtSeq, '0');
            string tseq1 = "-";
            if (ltfx_seq1 != "_") tseq1 += ltfx_seq1;

            string fld = Request["uploadfield"] ?? "";
            string uploadSource = Request["uploadSource"] ?? "";
            for (int k = 1; k <= Convert.ToInt32("0" + Request[fld + "_filenum"]); k++) {
                string tstep_grade = "1".PadLeft(4, '0');
                string straa = (Request[fld + "_name_" + k] ?? "").Trim();//上傳檔名
                string attach_flag = (Request["attach_flag_" + k] ?? "").Trim().ToUpper();
                string attach_sqlno = (Request["attach_sqlno_" + k] ?? "").Trim();
                string attach_path = (Request[fld + "_" + k] ?? "").Trim();//上傳路徑
                string attach_no = (Request["attach_no_" + k] ?? "").Trim();//序號

                //當上傳路徑不為空的 and attach_sqlno為空的,才需要新增
                if (attach_path != "" && attach_sqlno == "") {
                    //更換檔名
                    string source_name = (Request[fld + "_name_" + k] ?? "").Trim();//原始檔名
                    string sExt = System.IO.Path.GetExtension(straa);//副檔名
                    string attach_name = "";//資料庫檔名
                    string newattach_path = "";//資料庫路徑
                    attach_name = Session["sebranch"] + Sys.GetSession("dept").ToUpper() + "-" + tseq + tseq1 + "-" + tstep_grade + "-" + attach_no + sExt;//重新命名檔名
                    newattach_path = attach_path + "/" + attach_name;//存在資料庫路徑
                    Sys.RenameFile(attach_path + "/" + straa, attach_path + "/" + attach_name, true);

                    SQL = "insert into dmt_attach ";
                    ColMap.Clear();
                    ColMap["Seq"] = Util.dbchar(Request["tfx_seq"]);
                    ColMap["seq1"] = Util.dbchar(ltfx_seq1);
                    ColMap["step_grade"] = Util.dbchar("1");
                    ColMap["case_no"] = Util.dbchar("");
                    ColMap["in_no"] = Util.dbchar("");
                    ColMap["source"] = Util.dbchar(uploadSource);
                    ColMap["in_date"] = "getdate()";
                    ColMap["in_scode"] = "'" + Session["scode"] + "'";
                    ColMap["attach_no"] = "'" + attach_no + "'";
                    ColMap["attach_path"] = "'" + Sys.Path2Btbrt(newattach_path) + "'";
                    ColMap["doc_type"] = Util.dbchar(Request["doc_type_" + k]);
                    ColMap["attach_desc"] = Util.dbchar(Request[fld + "_desc_" + k]);
                    ColMap["attach_name"] = Util.dbchar(attach_name);
                    ColMap["source_name"] = Util.dbchar(source_name);
                    ColMap["attach_size"] = Util.dbnull(Request[fld + "_size_" + k]);
                    ColMap["attach_flag"] = "'A'";
                    ColMap["Mark"] = "''";
                    ColMap["tran_date"] = "getdate()";
                    ColMap["tran_scode"] = "'" + Session["scode"] + "'";
                    ColMap["attach_branch"] = "''";
                    ColMap["att_sqlno"] = Util.dbnull(Request["brtran_sqlno"]);

                    SQL += ColMap.GetInsertSQL();
                    conn.ExecuteNonQuery(SQL);
                }
            }

            //更新轉案記錄資料
            Sys.insert_log_table(conn, "U", prgid, "dmt_brtran", "brtran_sqlno", Request["brtran_sqlno"], "");
            SQL = "update dmt_brtran set ";
            SQL += " tran_seq = " + Util.dbnull(Request["tfx_seq"]);
            SQL += ",tran_seq1 = " + Util.dbchar(ltfx_seq1);
            SQL += ",tran_cust_area = " + Util.dbchar(Request["tfx_cust_area"]);
            SQL += ",tran_cust_seq = " + Util.dbnull(Request["tfx_cust_seq"]);
            SQL += ",tran_scode1 = " + Util.dbchar(Request["tfx_scode"]);
            SQL += ",tran_date = getdate()";
            SQL += ",tran_scode = '" + Session["scode"] + "'";
            SQL += " where brtran_sqlno=" + Request["brtran_sqlno"];
            conn.ExecuteNonQuery(SQL);

            //更新程序確認轉案todo
            SQL = "update todo_dmt set ";
            SQL += " job_status = 'YY' ";
            SQL += ",approve_scode = '" + Session["scode"] + "'";
            SQL += ",resp_date = getdate()";
            SQL += " where sqlno=" + Request["todo_sqlno"];
            SQL += " and job_status='NN'";
            conn.ExecuteNonQuery(SQL);

            //已有官發要寫入總收發文
            if (ReqVal.TryGet("emg_flag") == "Y") {
                string s_mark = ReqVal.TryGet("tfx_s_mark").Trim();
                if (s_mark == "") s_mark = "_";

                SQL = "insert into brstep_mgt ";
                ColMap.Clear();
                ColMap["seq_area"] = "'" + Session["seBranch"] + "'";
                ColMap["Seq"] = Util.dbchar(Request["tfx_seq"]);
                ColMap["seq1"] = Util.dbchar(ltfx_seq1);
                ColMap["br_in_date"] = Util.dbnull(Request["tfx_in_date"]);
                ColMap["br_step_grade"] = Util.dbchar("1");
                ColMap["br_rs_sqlno"] = Util.dbnull(Getrs_sqlno);
                ColMap["cr_step_grade"] = Util.dbchar("1");
                ColMap["cr_rs_sqlno"] = Util.dbnull(Getrs_sqlno);
                ColMap["cg"] = Util.dbchar("Z");
                ColMap["rs"] = Util.dbchar("R");
                ColMap["br_rs_no"] = Util.dbchar(rs_no);
                ColMap["rs_type"] = Util.dbchar(Request["now_arcase_type"]);
                ColMap["rs_class"] = Util.dbchar(Request["now_arcase_class"]);
                ColMap["rs_class_name"] = Util.dbchar(Request["now_arcase_classnm"]);
                ColMap["rs_code"] = Util.dbchar(Request["tfx_now_arcase"]);
                ColMap["rs_code_name"] = Util.dbchar(Request["tfx_now_arcasenm"]);
                ColMap["act_code"] = Util.dbchar(Request["now_act_code"]);
                ColMap["act_code_name"] = Util.dbchar(Request["now_act_codenm"]);
                ColMap["rs_detail"] = Util.dbchar(Request["now_rs_detail"]);
                ColMap["send_cl"] = Util.dbchar("T");
                ColMap["step_date"] = "'" + DateTime.Today.ToShortDateString() + "'";
                ColMap["receive_way"] = "'R6'";
                ColMap["cappl_name"] = Util.dbchar(Request["tfx_appl_name"]);
                ColMap["s_mark1"] = Util.dbchar(s_mark);
                ColMap["country"] = Util.dbchar("T");
                ColMap["apply_date"] = Util.dbnull(Request["tfx_apply_date"]);
                ColMap["apply_no"] = Util.dbchar(Request["tfx_apply_no"]);
                ColMap["issue_date"] = Util.dbnull(Request["tfx_issue_date"]);
                ColMap["issue_no2"] = Util.dbchar(Request["tfx_issue_no"]);
                ColMap["issue_no3"] = Util.dbchar(Request["tfx_rej_no"]);
                ColMap["open_date"] = Util.dbnull(Request["tfx_open_date"]);
                ColMap["pay_times"] = Util.dbchar(Request["tfx_pay_times"]);
                ColMap["pay_date"] = Util.dbnull(Request["tfx_pay_date"]);
                ColMap["term1"] = Util.dbnull(Request["tfx_term1"]);
                ColMap["term2"] = Util.dbnull(Request["tfx_term2"]);
                ColMap["end_date"] = Util.dbnull(Request["tfx_end_date"]);
                ColMap["end_code"] = Util.dbnull(Request["tfx_end_code"]);
                ColMap["branch_date"] = "getdate()";
                ColMap["branch_scode"] = "'" + Session["scode"] + "'";
                ColMap["tran_date"] = "getdate()";
                ColMap["tran_scode"] = "'" + Session["scode"] + "'";
                ColMap["tran_seq_branch"] = Util.dbchar(Request["tran_seq_branch"]);
                ColMap["tran_seq"] = Util.dbchar(Request["tran_seq"]);
                ColMap["tran_seq1"] = Util.dbchar(Request["tran_seq1"]);
                ColMap["tran_remark"] = Util.dbchar(Request["tran_remark"]);
                SQL += ColMap.GetInsertSQL();
                connm.ExecuteNonQuery(SQL);

                //抓insert後的流水號
                SQL = "SELECT SCOPE_IDENTITY() AS Current_Identity";
                objResult = connm.ExecuteScalar(SQL);
                string Getmgrs_sqlno = objResult.ToString();

                //入總收發文之brctrl_mgt
                for (int i = 1; i <= Convert.ToInt32("0" + Request["ctrlnum"]); i++) {
                    if ((Request["ctrl_type_" + i] ?? "") != "" && (Request["ctrl_date_" + i] ?? "") != "" && (Request["brctrl_mgt_" + i] ?? "") == "Y") {
                        SQL = "insert into brctrl_mgt ";
                        ColMap.Clear();
                        ColMap["brstep_sqlno"] = "'" + Getmgrs_sqlno + "'";
                        ColMap["seq_area"] = "'" + Session["seBranch"] + "'";
                        ColMap["Seq"] = Util.dbchar(Request["tfx_seq"]);
                        ColMap["seq1"] = Util.dbchar(ltfx_seq1);
                        ColMap["br_rs_sqlno"] = Util.dbnull(Getrs_sqlno);
                        ColMap["br_step_grade"] = Util.dbchar("1");
                        ColMap["ctrl_type"] = Util.dbchar(Request["ctrl_type_" + i]);
                        ColMap["ctrl_remark"] = Util.dbnull(Request["ctrl_remark_" + i]);
                        ColMap["ctrl_date"] = Util.dbnull(Request["ctrl_date_" + i]);
                        ColMap["tran_date"] = "getdate()";
                        ColMap["tran_scode"] = "'" + Session["scode"] + "'";
                        SQL += ColMap.GetInsertSQL();
                        connm.ExecuteNonQuery(SQL);
                    }
                }

                //入總收發文之todo_mgt
                SQL = "insert into todo_mgt ";
                ColMap.Clear();
                ColMap["syscode"] = "'" + Session["syscode"] + "'";
                ColMap["apcode"] = "'" + prgid + "'";
                ColMap["temp_rs_sqlno"] = Util.dbchar(Getmgrs_sqlno);
                ColMap["br_rs_sqlno"] = Util.dbchar(Getrs_sqlno);
                ColMap["seq_area"] = "'" + Session["seBranch"] + "'";
                ColMap["seq"] = Util.dbchar(Request["tfx_seq"]);
                ColMap["seq1"] = Util.dbchar(ltfx_seq1);
                ColMap["rs"] = Util.dbchar("R");
                ColMap["rs_no"] = Util.dbchar(rs_no);
                ColMap["in_date"] = "getdate()";
                ColMap["in_scode"] = "'" + Session["scode"] + "'";
                ColMap["dowhat"] = "'tran_case'";
                ColMap["job_status"] = "'NN'";
                SQL += ColMap.GetInsertSQL();
                connm.ExecuteNonQuery(SQL);

                //通知總管處立案
                SendmailMG();
            }

            //通知原單位轉案完成
            Sys.insert_log_table(connbr, "U", prgid, "dmt_brtran", "brtran_sqlno", Request["old_brtran_sqlno"], "");
            SQL = "update dmt_brtran set ";
            SQL += " tran_seq = " + Util.dbnull(Request["tfx_seq"]);
            SQL += ",tran_seq1 = " + Util.dbchar(ltfx_seq1);
            SQL += ",tran_cust_area = " + Util.dbchar(Request["tfx_cust_area"]);
            SQL += ",tran_cust_seq = " + Util.dbnull(Request["tfx_cust_seq"]);
            SQL += ",tran_scode1 = " + Util.dbchar(Request["tfx_scode"]);
            SQL += ",dc1_date = getdate()";
            SQL += ",dc1_scode = '" + Session["scode"] + "'";
            SQL += ",tran_date = getdate()";
            SQL += ",tran_scode = '" + Session["scode"] + "'";
            SQL += " where brtran_sqlno=" + Request["old_brtran_sqlno"];
            connbr.ExecuteNonQuery(SQL);

            string job_scode = Sys.getCodeName(conn, "sysctrl.dbo.scode_group", "scode", "where grpclass='" + Request["tran_seq_branch"] + "' and grpid='T210' and grptype='F'");
            SQL = "insert into todo_dmt ";
            ColMap.Clear();
            ColMap["syscode"] = "'" + Request["tran_seq_branch"] + "TBRT'";
            ColMap["apcode"] = "'" + prgid + "'";
            ColMap["temp_rs_sqlno"] = Util.dbnull(Request["old_brtran_sqlno"]);
            ColMap["from_flag"] = Util.dbchar("TRAN");
            ColMap["branch"] = "'" + Request["tran_seq_branch"] + "'";
            ColMap["seq"] = Util.dbnull(Request["tran_seq"]);
            ColMap["seq1"] = Util.dbchar(Request["tran_seq1"]);
            ColMap["in_scode"] = "'" + Session["scode"] + "'";
            ColMap["in_date"] = "getdate()";
            ColMap["dowhat"] = Util.dbchar("TRAN_ED1");
            ColMap["job_scode"] = Util.dbchar(job_scode);
            ColMap["job_team"] = Util.dbchar("T210");
            ColMap["job_status"] = Util.dbchar("NN");
            SQL += ColMap.GetInsertSQL();
            connbr.ExecuteNonQuery(SQL);

            //Email通知原單位結案
            SendmailBr(job_scode);
        }
    }

    private void doUpdate() {
        //入dmt_log
        string reason = "Brt15國內案案件主檔維護作業";
        if (prgid == "brt51" && submitTask == "U")
            reason = "Brt51客收確認修改案件主檔";
        Sys.insert_log_table(conn, "U", prgid, "dmt", "seq;seq1", Request["tfx_seq"] + ";" + ltfx_seq1, reason);

        //修改dmt
        SQL = "update dmt set ";
        if ((HTProgRight + 256) != 0) {
            SQL += " cust_seq = " + Util.dbnull(Request["tfx_cust_seq"]) + ",";
            SQL += " cust_seq1 = '0',";
        }
        SQL += " tcn_ref = " + Util.dbnull(Request["tfx_tcn_ref"]) + ",";
        SQL += " ref_no1 = " + Util.dbnull(Request["tfx_ref_no1"]) + ",";
        SQL += " ref_no2 = " + Util.dbnull(Request["tfx_ref_no2"]) + ",";
        SQL += " ref_no3 = " + Util.dbnull(Request["tfx_ref_no3"]) + ",";
        SQL += " mseq = " + Util.dbnull(Request["tfx_mseq"]) + ",";
        SQL += " mseq1 = " + Util.dbnull(Request["tfx_mseq1"]) + ",";
        SQL += " s_mark = " + Util.dbnull(Request["tfx_s_mark"]) + ",";
        SQL += " s_mark2 = " + Util.dbnull(Request["tfx_s_mark2"]) + ",";
        SQL += " appl_name = " + Util.dbnull(Request["tfx_appl_name"]) + ",";
        SQL += " dmt_draw = " + Util.dbnull(Request["tfx_dmt_draw"]) + ",";
        SQL += " class = " + Util.dbnull(Request["tfx_class"]) + ",";
        SQL += " class_count = " + Util.dbnull(Request["tfx_class_count"]) + ",";
        SQL += " class_type = " + Util.dbnull(Request["tfx_class_type"]) + ",";
        SQL += " att_sql = " + Util.dbnull(Request["tfx_att_sql"]) + ",";
        SQL += " apsqlno = " + Util.dbnull(Request["tfx_apsqlno"]) + ",";
        SQL += " apcust_no = " + Util.dbnull(Request["tfx_apcust_no"]) + ",";
        SQL += " ap_cname = " + Util.dbnull(Request["tfx_ap_cname"]) + ",";
        SQL += " ap_ename = " + Util.dbnull(Request["tfx_ap_ename"]) + ",";
        SQL += " agt_no = " + Util.dbnull(Request["tfx_agt_no"]) + ",";
        SQL += " apply_date = " + Util.dbnull(Request["tfx_apply_date"]) + ",";
        SQL += " apply_no = " + Util.dbnull(Request["tfx_apply_no"]) + ",";
        SQL += " issue_date = " + Util.dbnull(Request["tfx_issue_date"]) + ",";
        SQL += " issue_no = " + Util.dbnull(Request["tfx_issue_no"]) + ",";
        SQL += " open_date = " + Util.dbnull(Request["tfx_open_date"]) + ",";
        SQL += " rej_no = " + Util.dbnull(Request["tfx_rej_no"]) + ",";
        SQL += " rej_item = " + Util.dbnull(Request["tfx_rej_item"]) + ",";
        SQL += " prior_date = " + Util.dbnull(Request["tfx_prior_date"]) + ",";
        SQL += " prior_no = " + Util.dbnull(Request["tfx_prior_no"]) + ",";
        SQL += " prior_country = " + Util.dbnull(Request["tfx_prior_country"]) + ",";
        SQL += " term1 = " + Util.dbnull(Request["tfx_term1"]) + ",";
        SQL += " term2 = " + Util.dbnull(Request["tfx_term2"]) + ",";
        SQL += " end_date = " + Util.dbnull(Request["tfx_end_date"]) + ",";
        SQL += " end_code = " + Util.dbnull(Request["tfx_end_code"]) + ",";
        SQL += " end_type = " + Util.dbchar(Request["end_type"]) + ",";
        SQL += " end_remark = " + Util.dbchar(Request["end_remark"]) + ",";
        SQL += " renewal = " + Util.dbnull(Request["tfx_renewal"]) + ",";
        SQL += " scode = " + Util.dbnull(Request["tfx_scode"]) + ",";
        SQL += " pay_times = " + Util.dbnull(Request["tfx_pay_times"]) + ",";
        SQL += " pay_date = " + Util.dbnull(Request["tfx_pay_date"]) + ",";
        SQL += " cust_prod = " + Util.dbnull(Request["tfx_cust_prod"]);
        SQL += " where seq = " + Request["tfx_seq"];
        SQL += "   and seq1 = '" + ltfx_seq1 + "'";
        conn.ExecuteNonQuery(SQL);

        //修改 ndmt
        SQL = "select count(*) as cnt from ndmt where seq=" + Request["tfx_seq"] + " and seq1='" + ltfx_seq1 + "'";
        objResult = conn.ExecuteScalar(SQL);
        int cnt = (objResult == DBNull.Value || objResult == null) ? 0 : Convert.ToInt32(objResult);
        if (cnt != 0) {
            SQL = "update ndmt set ";
            SQL += " cappl_name = " + Util.dbnull(Request["tfx_cappl_name"]) + ",";
            SQL += " eappl_name = " + Util.dbnull(Request["tfx_eappl_name"]) + ",";
            SQL += " eappl_name1 = " + Util.dbnull(Request["tfx_eappl_name1"]) + ",";
            SQL += " eappl_name2 = " + Util.dbnull(Request["tfx_eappl_name2"]) + ",";
            SQL += " zname_type = " + Util.dbnull(Request["tfx_zname_type"]) + ",";
            SQL += " oappl_name = " + Util.dbnull(Request["tfx_oappl_name"]) + ",";
            SQL += " draw = " + Util.dbnull(Request["tfx_draw"]) + ",";
            SQL += " draw_file = " + Util.dbnull(Sys.Path2Btbrt(Request["tfx_draw_file"])) + ",";
            SQL += " symbol = " + Util.dbnull(Request["tfx_symbol"]) + ",";
            SQL += " color = " + Util.dbnull(Request["tfx_color"]) + ",";
            SQL += " tran_date = '" + DateTime.Today.ToShortDateString() + "',";
            SQL += " tran_scode = '" + Session["scode"] + "'";
            SQL += " where seq = " + Request["tfx_seq"];
            SQL += "   and seq1 = '" + ltfx_seq1 + "'";
            conn.ExecuteNonQuery(SQL);
        } else {
            SQL = "insert into ndmt ";
            ColMap.Clear();
            ColMap["branch"] = "'" + Session["seBranch"] + "'";
            ColMap["seq"] = Util.dbchar(Request["tfx_seq"]);
            ColMap["seq1"] = Util.dbchar(ltfx_seq1);
            ColMap["cappl_name"] = Util.dbnull(Request["tfx_cappl_name"]);
            ColMap["eappl_name"] = Util.dbnull(Request["tfx_eappl_name"]);
            ColMap["eappl_name1"] = Util.dbnull(Request["tfx_eappl_name1"]);
            ColMap["eappl_name2"] = Util.dbnull(Request["tfx_eappl_name2"]);
            ColMap["zname_type"] = Util.dbnull(Request["tfx_zname_type"]);
            ColMap["oappl_name"] = Util.dbnull(Request["tfx_oappl_name"]);
            ColMap["draw"] = Util.dbnull(Request["tfx_draw"]);
            ColMap["draw_file"] = Util.dbnull(Sys.Path2Btbrt(Request["tfx_draw_file"]));
            ColMap["symbol"] = Util.dbnull(Request["tfx_symbol"]);
            ColMap["color"] = Util.dbnull(Request["tfx_color"]);
            ColMap["tran_date"] = "'" + DateTime.Today.ToShortDateString() + "'";
            ColMap["tran_scode"] = "'" + Session["scode"] + "'";
            SQL += ColMap.GetInsertSQL();
            conn.ExecuteNonQuery(SQL);
        }

        //修改 dmt_temp
        SQL = "update dmt_temp set ";
        SQL += " tcn_ref = " + Util.dbnull(Request["tfx_tcn_ref"]) + ",";
        SQL += " class = " + Util.dbnull(Request["tfx_class"]) + ",";
        SQL += " class_count = " + Util.dbnull(Request["tfx_class_count"]) + ",";
        SQL += " apply_date = " + Util.dbnull(Request["tfx_apply_date"]) + ",";
        SQL += " apply_no = " + Util.dbnull(Request["tfx_apply_no"]) + ",";
        SQL += " issue_date = " + Util.dbnull(Request["tfx_issue_date"]) + ",";
        SQL += " issue_no = " + Util.dbnull(Request["tfx_issue_no"]) + ",";
        SQL += " cappl_name = " + Util.dbnull(Request["tfx_cappl_name"]) + ",";
        SQL += " eappl_name = " + Util.dbnull(Request["tfx_eappl_name"]) + ",";
        SQL += " eappl_name1 = " + Util.dbnull(Request["tfx_eappl_name1"]) + ",";
        SQL += " eappl_name2 = " + Util.dbnull(Request["tfx_eappl_name2"]) + ",";
        SQL += " zname_type = " + Util.dbnull(Request["tfx_zname_type"]) + ",";
        SQL += " oappl_name = " + Util.dbnull(Request["tfx_oappl_name"]) + ",";
        SQL += " draw = " + Util.dbnull(Request["tfx_draw"]) + ",";
        SQL += " draw_file = " + Util.dbnull(Sys.Path2Btbrt(Request["tfx_draw_file"])) + ",";
        SQL += " symbol = " + Util.dbnull(Request["tfx_symbol"]) + ",";
        SQL += " color = " + Util.dbnull(Request["tfx_color"]) + ",";
        SQL += " agt_no = " + Util.dbnull(Request["tfx_agt_no"]) + ",";
        SQL += " prior_date = " + Util.dbnull(Request["tfx_prior_date"]) + ",";
        SQL += " prior_no = " + Util.dbnull(Request["tfx_prior_no"]) + ",";
        SQL += " prior_country = " + Util.dbnull(Request["tfx_prior_country"]) + ",";
        SQL += " open_date = " + Util.dbnull(Request["tfx_open_date"]) + ",";
        SQL += " rej_no = " + Util.dbnull(Request["tfx_rej_no"]) + ",";
        SQL += " end_date = " + Util.dbnull(Request["tfx_end_date"]) + ",";
        SQL += " end_code = " + Util.dbnull(Request["tfx_end_code"]) + ",";
        SQL += " dmt_term1 = " + Util.dbnull(Request["tfx_term1"]) + ",";
        SQL += " dmt_term2 = " + Util.dbnull(Request["tfx_term2"]) + ",";
        SQL += " renewal = " + Util.dbnull(Request["tfx_renewal"]) + ",";
        SQL += " tr_date = '" + DateTime.Today.ToShortDateString() + "',";
        SQL += " tr_scode = '" + Session["scode"] + "'";
        SQL += " where in_no='" + in_no + "' and in_scode = '" + in_scode + "' ";
        SQL += " and seq=" + Request["tfx_seq"] + " and seq1='" + ltfx_seq1 + "'";
        conn.ExecuteNonQuery(SQL);

        //刪除dmt_good,重入
        SQL = "delete from dmt_good where seq = " + Request["tfx_seq"] + " and seq1 = '" + ltfx_seq1 + "'";
        conn.ExecuteNonQuery(SQL);
        for (int i = 1; i <= Convert.ToInt32("0" + Request["classnum"]); i++) {
            if ((Request["tfx_class_" + i] ?? "") != "" || (Request["good_delchk_" + i] ?? "") != "Y") {
                SQL = "insert into dmt_good ";
                ColMap.Clear();
                ColMap["seq"] = Util.dbnull(Request["tfx_seq"]);
                ColMap["seq1"] = Util.dbchar(ltfx_seq1);
                ColMap["class"] = Util.dbchar(Request["tfx_class_" + i]);
                ColMap["dmt_grp_code"] = Util.dbchar(Request["tfx_grp_code_" + i]);
                ColMap["dmt_goodname"] = Util.dbnull(Request["tfx_goodname_" + i]);
                ColMap["dmt_goodcount"] = Util.dbnull(Request["tfx_goodcount_" + i]);
                ColMap["in_scode"] = Util.dbchar(in_scode);
                ColMap["in_no"] = Util.dbchar(in_no);
                ColMap["tr_date"] = "'" + DateTime.Today.ToShortDateString() + "'";
                ColMap["tr_scode"] = "'" + Session["scode"] + "'";
                SQL += ColMap.GetInsertSQL();
                conn.ExecuteNonQuery(SQL);
            }
        }

        //刪除dmt_show,重入
        Sys.insert_log_table(conn, "U", HTProgCode, "dmt_show", "seq;seq1", Request["tfx_seq"] + ";" + ltfx_seq1, "");
        SQL = "delete from dmt_show where seq = " + Request["tfx_seq"] + " and seq1 = '" + ltfx_seq1 + "'";
        conn.ExecuteNonQuery(SQL);
        for (int i = 1; i <= Convert.ToInt32("0" + Request["shownum"]); i++) {
            if ((Request["show_date_" + i] ?? "") != "" || (Request["show_name_" + i] ?? "") != "") {
                SQL = "insert into dmt_show ";
                ColMap.Clear();
                ColMap["seq"] = Util.dbchar(Request["tfx_seq"]);
                ColMap["seq1"] = Util.dbchar(ltfx_seq1);
                ColMap["show_date"] = Util.dbnull(Request["show_date_" + i]);
                ColMap["show_name"] = Util.dbchar(Request["show_name_" + i]);
                ColMap["tr_date"] = "getdate()";
                ColMap["tr_scode"] = "'" + Session["scode"] + "'";
                SQL += ColMap.GetInsertSQL();
                conn.ExecuteNonQuery(SQL);
            }
        }

        //刪除dmt_ap,重入
        Sys.insert_log_table(conn, "U", HTProgCode, "dmt_ap", "seq;seq1", Request["tfx_seq"] + ";" + ltfx_seq1, "");
        SQL = "delete from dmt_ap where seq = " + Request["tfx_seq"] + " and seq1 = '" + ltfx_seq1 + "'";
        conn.ExecuteNonQuery(SQL);
        for (int i = 1; i <= Convert.ToInt32("0" + Request["apnum"]); i++) {
            SQL = "insert into dmt_ap ";
            ColMap.Clear();
            ColMap["branch"] = "'" + Session["seBranch"] + "'";
            ColMap["seq"] = Util.dbchar(Request["tfx_seq"]);
            ColMap["seq1"] = Util.dbchar(ltfx_seq1);
            ColMap["apsqlno"] = Util.dbchar(Request["apsqlno_" + i]);
            ColMap["server_flag"] = Util.dbchar(Request["server_flag_" + i]);
            ColMap["apcust_no"] = Util.dbchar(Request["apcust_no_" + i]);
            ColMap["ap_cname"] = Util.dbchar(Request["ap_cname_" + i]);
            ColMap["ap_ename"] = Util.dbchar(Request["ap_ename_" + i]);
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
            SQL += ColMap.GetInsertSQL();
            conn.ExecuteNonQuery(SQL);
        }

        //結案或復案入總收發文待結案或復案處理
        if (ReqVal.TryGet("tfx_end_date") != "") {
            if (ReqVal.TryGet("old_end_date") == "") {
                //待結案處理
                string br_end_reason = Request["tfx_end_name"];
                if (ReqVal.TryGet("end_remark") != "") {
                    br_end_reason = ReqVal.TryGet("end_remark");
                }

                SQL = "insert into brend_mgt ";
                ColMap.Clear();
                ColMap["br_step_grade"] = "0";
                ColMap["br_rs_sqlno"] = "0";
                ColMap["seq_area"] = "'" + Session["seBranch"] + "'";
                ColMap["seq"] = Util.dbchar(Request["tfx_seq"]);
                ColMap["seq1"] = Util.dbchar(ltfx_seq1);
                ColMap["end_flag"] = "'end'";
                ColMap["br_end_date"] = Util.dbnull(Request["tfx_end_date"]);
                ColMap["br_end_code"] = Util.dbnull(Request["tfx_end_code"]);
                ColMap["br_end_reason"] = Util.dbnull(br_end_reason);
                ColMap["in_scode"] = "'" + Session["scode"] + "'";
                ColMap["in_date"] = "getdate()";
                SQL += ColMap.GetInsertSQL();
                connm.ExecuteNonQuery(SQL);

                //抓insert後的流水號
                SQL = "SELECT SCOPE_IDENTITY() AS Current_Identity";
                objResult = connm.ExecuteScalar(SQL);
                string Getrs_sqlno = objResult.ToString();

                SQL = "insert into todo_mgt ";
                ColMap.Clear();
                ColMap["syscode"] = "'" + Session["syscode"] + "'";
                ColMap["apcode"] = "'brt15'";
                ColMap["temp_rs_sqlno"] = Util.dbchar(Getrs_sqlno);
                ColMap["br_rs_sqlno"] = "0";
                ColMap["seq_area"] = "'" + Session["seBranch"] + "'";
                ColMap["seq"] = Util.dbchar(Request["tfx_seq"]);
                ColMap["seq1"] = Util.dbchar(ltfx_seq1);
                ColMap["in_date"] = "getdate()";
                ColMap["in_scode"] = "'" + Session["scode"] + "'";
                ColMap["dowhat"] = "'end'";
                ColMap["job_status"] = "'NN'";
                SQL += ColMap.GetInsertSQL();
                connm.ExecuteNonQuery(SQL);
            }
        } else {
            if (ReqVal.TryGet("old_end_date") != "") {
                //待復案處理
                SQL = "insert into brend_mgt ";
                ColMap.Clear();
                ColMap["br_step_grade"] = "0";
                ColMap["br_rs_sqlno"] = "0";
                ColMap["seq_area"] = "'" + Session["seBranch"] + "'";
                ColMap["seq"] = Util.dbchar(Request["tfx_seq"]);
                ColMap["seq1"] = Util.dbchar(ltfx_seq1);
                ColMap["end_flag"] = "'back'";
                ColMap["in_scode"] = "'" + Session["scode"] + "'";
                ColMap["in_date"] = "getdate()";
                SQL += ColMap.GetInsertSQL();
                connm.ExecuteNonQuery(SQL);

                //抓insert後的流水號
                SQL = "SELECT SCOPE_IDENTITY() AS Current_Identity";
                objResult = connm.ExecuteScalar(SQL);
                string Getrs_sqlno = objResult.ToString();

                SQL = "insert into todo_mgt ";
                ColMap.Clear();
                ColMap["syscode"] = "'" + Session["syscode"] + "'";
                ColMap["apcode"] = "'brt15'";
                ColMap["temp_rs_sqlno"] = Util.dbchar(Getrs_sqlno);
                ColMap["br_rs_sqlno"] = "0";
                ColMap["seq_area"] = "'" + Session["seBranch"] + "'";
                ColMap["seq"] = Util.dbchar(Request["tfx_seq"]);
                ColMap["seq1"] = Util.dbchar(ltfx_seq1);
                ColMap["in_date"] = "getdate()";
                ColMap["in_scode"] = "'" + Session["scode"] + "'";
                ColMap["dowhat"] = "'back'";
                ColMap["job_status"] = "'NN'";
                SQL += ColMap.GetInsertSQL();
                connm.ExecuteNonQuery(SQL);
            }
        }
    }

    private void doDel() {
        //入dmt_log
        Sys.insert_log_table(conn, "D", HTProgCode, "dmt", "seq;seq1", Request["tfx_seq"] + ";" + ltfx_seq1, "Brt15國內案案件主檔維護作業");

        //刪除案件主檔
        SQL = " delete from dmt where seq = " + Request["tfx_seq"] + " and seq1 = '" + ltfx_seq1 + "'";
        conn.ExecuteNonQuery(SQL);

        //刪除 ndmt
        SQL = " delete from ndmt where seq = " + Request["tfx_seq"] + " and seq1 = '" + ltfx_seq1 + "'";
        conn.ExecuteNonQuery(SQL);

        //刪除 dmt_good
        SQL = "delete from dmt_good where seq = " + Request["tfx_seq"] + " and seq1 = '" + ltfx_seq1 + "'";
        conn.ExecuteNonQuery(SQL);

        //刪除 dmt_temp
        SQL = "delete from dmt_temp where in_no='" + in_no + "' and in_scode = '" + in_scode + "' and seq=" + Request["tfx_seq"] + " and seq1 = '" + ltfx_seq1 + "'";
        conn.ExecuteNonQuery(SQL);

        //刪除 case_dmt
        SQL = "delete from case_dmt where in_no='" + in_no + "' and in_scode = '" + in_scode + "' and seq=" + Request["tfx_seq"] + " and seq1 = '" + ltfx_seq1 + "'";
        conn.ExecuteNonQuery(SQL);

        //刪除 dmt_show
        Sys.insert_log_table(conn, "D", HTProgCode, "dmt_show", "seq;seq1", Request["tfx_seq"] + ";" + ltfx_seq1, "");
        SQL = "delete from dmt_show where seq = " + Request["tfx_seq"] + " and seq1 = '" + ltfx_seq1 + "'";
        conn.ExecuteNonQuery(SQL);

        //刪除dmt_ap
        Sys.insert_log_table(conn, "D", HTProgCode, "dmt_ap", "seq;seq1", Request["tfx_seq"] + ";" + ltfx_seq1, "");
        SQL = "delete from dmt_ap where seq=" + Request["tfx_seq"] + " and seq1 = '" + ltfx_seq1 + "'";
        conn.ExecuteNonQuery(SQL);

        //刪除管制檔  新增 ctrl_dmt_log
        Sys.insert_log_table(conn, "D", HTProgCode, "ctrl_dmt", "seq;seq1", Request["tfx_seq"] + ";" + ltfx_seq1, "");
        SQL = "delete from ctrl_dmt where seq=" + Request["tfx_seq"] + " and seq1 = '" + ltfx_seq1 + "'";
        conn.ExecuteNonQuery(SQL);

        //刪除收文主檔
        //新增 step_dmp_Log 檔
        Sys.insert_log_table(conn, "D", HTProgCode, "step_dmt", "seq;seq1", Request["tfx_seq"] + ";" + ltfx_seq1, "");
        Response.End();

        //刪除 step_dmp
        SQL = "delete from step_dmt  where " + Request["tfx_seq"] + " and seq1 = '" + ltfx_seq1 + "'";
        conn.ExecuteNonQuery(SQL);
    }
    
    //新增進度檔 step_dmt
    private string Insert_Step(string seq, string seq1, int step_grade, string main_rs_no, string rs_no) {
        if (step_grade == 1) {
            //2008/12/11新增一筆進度0
            Insert_stepZZ(seq, seq1);
        }
        if (main_rs_no == "") {
            main_rs_no = rs_no;
        }
        //取得代碼種類
        string rs_type = Sys.getRsType();

        string pr_status = "X";
        string pr_scode = "";
        string opt_stat = "";

        SQL = "insert into step_dmt ";
        ColMap.Clear();
        ColMap["rs_no"] = Util.dbchar(rs_no);
        ColMap["branch"] = Util.dbchar(Sys.GetSession("seBranch"));
        ColMap["seq"] = Util.dbnull(seq);
        ColMap["seq1"] = Util.dbchar(seq1);
        ColMap["step_grade"] = Util.dbnull(step_grade.ToString());
        ColMap["main_rs_no"] = Util.dbchar(main_rs_no);
        ColMap["step_date"] = "'" + DateTime.Today.ToShortDateString() + "'";
        ColMap["cg"] = Util.dbchar("C");
        ColMap["rs"] = Util.dbchar("R");
        ColMap["rs_type"] = Util.dbnull(rs_type);
        ColMap["rs_class"] = Util.dbchar("X2");
        ColMap["rs_code"] = Util.dbchar("XZ2");
        ColMap["act_code"] = Util.dbchar("_");
        ColMap["rs_detail"] = Util.dbchar("轉案");
        ColMap["pr_status"] = Util.dbchar(pr_status);
        ColMap["pr_scode"] = Util.dbchar(pr_scode);
        ColMap["new"] = Util.dbchar("X");
        ColMap["tot_num"] = Util.dbchar("1");
        ColMap["tran_date"] = "'" + DateTime.Today.ToShortDateString() + "'";
        ColMap["tran_scode"] = "'" + Session["scode"] + "'";
        ColMap["opt_stat"] = Util.dbchar(opt_stat);
        SQL += ColMap.GetInsertSQL();
        conn.ExecuteNonQuery(SQL);

        //抓insert後的流水號
        SQL = "SELECT SCOPE_IDENTITY() AS Current_Identity";
        objResult = conn.ExecuteScalar(SQL);
        string Getrs_sqlno = objResult.ToString();

        //新增期限管制 ctrl_dmt
        for (int i = 1; i <= Convert.ToInt32("0" + Request["ctrlnum"]); i++) {
            if ((Request["ctrl_type_" + i] ?? "") != "" || (Request["ctrl_date_" + i] ?? "") != "") {
                SQL = "insert into ctrl_dmt ";
                ColMap.Clear();
                ColMap["rs_no"] = Util.dbchar(rs_no);
                ColMap["branch"] = Util.dbchar(Sys.GetSession("seBranch"));
                ColMap["seq"] = Util.dbnull(seq);
                ColMap["seq1"] = Util.dbchar(seq1);
                ColMap["step_grade"] = Util.dbchar(step_grade.ToString());
                ColMap["ctrl_type"] = Util.dbchar(Request["ctrl_type_" + i]);
                ColMap["ctrl_remark"] = Util.dbnull(Request["ctrl_remark_" + i]);
                ColMap["ctrl_date"] = Util.dbnull(Request["ctrl_date_" + i]);
                ColMap["tran_date"] = "'" + DateTime.Today.ToShortDateString() + "'";
                ColMap["tran_scode"] = "'" + Session["scode"] + "'";
                SQL += ColMap.GetInsertSQL();
                conn.ExecuteNonQuery(SQL);
            }
        }
        return Getrs_sqlno;
    }
    
    //新增案件進度0
    private void Insert_stepZZ(string seq, string seq1) {
        SQL = "select count(*) as cnt from step_dmt where seq=" + seq + " and seq1='" + seq1 + "' and step_grade=0";
        objResult = conn.ExecuteScalar(SQL);
        int cnt = (objResult == DBNull.Value || objResult == null) ? 0 : Convert.ToInt32(objResult);
        if (cnt == 0) {
            //收文序號
            SQL = "select isnull(max(seq1),0)+1 rs_no from cust_code where code_type='Z' and cust_code='" + Session["seBranch"] + "TZZ'";
            objResult = conn.ExecuteScalar(SQL);
            string zzrs_no = (objResult == DBNull.Value || objResult == null) ? "_" : objResult.ToString();
            zzrs_no = "ZZ" + zzrs_no.PadLeft(8, '0');

            //流水號加一
            SQL = " update cust_code set sql = sql + 1 where code_type='Z' and cust_code='" + Session["seBranch"] + "TZZ'";
            conn.ExecuteNonQuery(SQL);

            //新增進度0
            SQL = "insert into step_dmt(rs_no,branch,seq,seq1,step_grade,step_date,main_rs_no,cg,rs,rs_detail) values (";
            SQL += "'" + zzrs_no + "','" + Session["seBranch"] + "'," + seq + ",'" + seq1 + "',0,'" + DateTime.Today.ToShortDateString() + "','" + zzrs_no + "','Z','Z','')";
            conn.ExecuteNonQuery(SQL);
        }
    }

    //通知總管處立案
    private void SendmailMG() {
        string Subject = "國內商標網路作業系統－轉案完成通知";
        string strFrom = Session["scode"] + "@saint-island.com.tw";
        List<string> strTo = new List<string>();
        List<string> strCC = new List<string>();
        List<string> strBCC = new List<string>();
        switch (Sys.Host) {
            case "web08":
            case "localhost":
                strTo.Add(Session["scode"] + "@saint-island.com.tw");
                Subject = "(" + Sys.Host + "測試)" + Subject;
                break;
            case "web10":
                strTo.Add("s687@saint-island.com.tw");
                strTo.Add("m1583@saint-island.com.tw");
                Subject = "(" + Sys.Host + "測試)" + Subject;
                break;
            default:
                strTo = ReqVal.TryGet("emg_scodelist").Split(';').Where(p => p != "").Select(o => o + "@saint-island.com.tw").ToList();
                strCC = ReqVal.TryGet("emg_scodelist1").Split(';').Where(p => p != "").Select(o => o + "@saint-island.com.tw").ToList();
                break;
        }

        string fseq = Sys.formatSeq(Request["tfx_seq"], ltfx_seq1, "", Sys.GetSession("seBranch"), Sys.GetSession("dept"));
        string ftran_seq = Sys.formatSeq(Request["tran_seq"], Request["tran_seq1"], "", Request["tran_seq_branch"], Sys.GetSession("dept"));

        string body = "<B>致: 總管處 程序</B><br><br>";
        body += "【通知日期】 : <B>" + DateTime.Today.ToShortDateString() + "</B><br>";
        body += "【本所編號】 : <B>" + fseq + "</B><br>";
        body += "【申請案號】 : <B>" + Request["tfx_apply_no"] + "</B><br>";
        body += "【轉出日期】 : <B>" + Request["tran_seq_date"] + "</B><br>";
        body += "【轉出單位】 : <B>" + ftran_seq + "</B><br>";
        body += "【轉案說明】 : <B>" + Request["tran_remark"] + "</B><br>";

        Sys.DoSendMail(Subject, body, strFrom, strTo, strCC, strBCC);
    }
    
    //通知原單位轉案完成
    private void SendmailBr(string job_scode) {
        string Subject = "國內商標網路作業系統－轉案完成通知";
        string strFrom = Session["scode"] + "@saint-island.com.tw";
        List<string> strTo = new List<string>();
        List<string> strCC = new List<string>();
        List<string> strBCC = new List<string>();

        switch (Sys.Host) {
            case "web08":
            case "localhost":
                strTo.Add(Session["scode"] + "@saint-island.com.tw");
                Subject = "(" + Sys.Host + "測試)" + Subject;
                break;
            case "web10":
                strTo.Add("s687@saint-island.com.tw");
                strTo.Add("m1583@saint-island.com.tw");
                Subject = "(" + Sys.Host + "測試)" + Subject;
                break;
            default:
                strTo.Add(job_scode + "@saint-island.com.tw");
                string dept_scode = Sys.getCodeName(conn, "sysctrl.dbo.grpid", "master_scode", "where grpclass='" + Request["tran_seq_branch"] + "' and grpid='T000'");
                //營洽已離職不寄發mail
                string end_date = Sys.getCodeName(conn, "sysctrl.dbo.scode", "end_date", "where scode='" + Request["tran_seq_scode"] + "' (end_date is null or end_date>getdate()) ");
                if (end_date != "") {
                    strCC.Add(Request["tran_seq_scode"] + "@saint-island.com.tw");
                }
                strCC.Add(dept_scode + "@saint-island.com.tw");//部門主管
                strCC = strCC.Distinct().ToList();
                break;
        }
        string branchnm = Sys.getCodeName(conn, "sysctrl.dbo.branch_code", "branchname", "where branch='" + Request["tran_seq_branch"] + "'");
        string ftran_seq = Sys.formatSeq(Request["tran_seq"], Request["tran_seq1"], "", Request["tran_seq_branch"], Sys.GetSession("dept"));

        string body = "<B>致: " + branchnm + " 程序</B><br><br>";
        body += "【通知日期】 : <B>" + DateTime.Today.ToShortDateString() + "</B><br>";
        body += "【區所編號】 : <B>" + ftran_seq + "</B><br>";
        body += "【案件名稱】 : <B>" + Request["tfx_appl_name"] + "</B><br>";
        body += "【客戶名稱】 : <B>" + Request["tfx_cust_name"] + "</B><br>";
        body += "【收文內容】 : <B>轉案</B><br>";
        body += "謹通知本案已轉案完成，請執行後續確認暨結案作業，謝謝。<br>";
    }
</script>

<%Response.Write(strOut.ToString());%>
