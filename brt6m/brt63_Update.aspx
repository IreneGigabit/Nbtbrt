<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Linq" %>

<script runat="server">
    protected string HTProgCap = "承辦交辦發文入檔";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "brt63";//HttpContext.Current.Request["prgid"] ?? "";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";

    protected string SQL = "";
    protected object objResult = null;
    protected string logReason="brt63承辦交辦發文";

    protected string submitTask = "";

    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected Dictionary<string, string> ColMap = new Dictionary<string, string>();

    protected StringBuilder strOut = new StringBuilder();

    DBHelper conn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    private void Page_Unload(System.Object sender, System.EventArgs e) {
        if (conn != null) conn.Dispose();
    }

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");

        string todo_sqlno = ReqVal.TryGet("todo_sqlno");

        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        HTProgCap = myToken.Title;
        DebugStr = myToken.DebugStr;
        if (HTProgRight >= 0) {
            try {
                conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");

                //判斷狀態是否已異動,防止開雙視窗
                SQL = "select count(*) from todo_dmt where sqlno='" + todo_sqlno + "' and job_status='NN'";
                object objResult = conn.ExecuteScalar(SQL);
                int cnt = (objResult == DBNull.Value || objResult == null) ? 0 : Convert.ToInt32(objResult);
                if (cnt == 0) {
                    throw new Exception("接洽序號" + Request["in_no"] + "-入檔失敗(流程狀態已異動，請重新整理畫面)");
                } else {
                    if (Request["task"] == "pr" || Request["task"] == "prsave") {
                        doUpdateDB();
                    }
                    if (Request["task"] == "cancel") {
                        doCancel();
                    }
                    conn.Commit();
                    //conn.RollBack();
                }
                
                if (Request["task"] == "pr") {
                    strOut.AppendLine("<div align='center'><h1>承辦交辦發文成功!!</h1></div>");
                } else if (Request["task"] == "prsave") {
                    strOut.AppendLine("<div align='center'><h1>承辦發文存檔成功!!</h1></div>");
                } else if (Request["task"] == "cancel") {
                    strOut.AppendLine("<div align='center'><h1>承辦不需發文成功!!</h1></div>");
                }
            }
            catch (Exception ex) {
                conn.RollBack();
                Sys.errorLog(ex, conn.exeSQL, prgid);
                //strOut.AppendLine("<div align='center'><h1>承辦交辦存檔失敗("+ex.Message+")</h1></div>");
                throw;
            }

            this.DataBind();
        }
    }

    private void doUpdateDB() {
        string tseq = ReqVal.TryGet("seq");
        string tseq1 = ReqVal.TryGet("seq1");
        string rs_code = ReqVal.TryGet("rs_code");
        string in_no = ReqVal.TryGet("in_no");
        string todo_sqlno = ReqVal.TryGet("todo_sqlno");
        string sign_stat = "SN";
        if (Request["task"] == "prsave") {
            sign_stat = "NN";
        }

        //新增attcase_dmt交辦發文檔
        //計算 tot_num區所發文件數
        int tot_num = 1;
        if (rs_code.Left(2) == "FD") {
            tot_num = 0;
        }
        for (int i = 1; i <= Convert.ToInt32("0" + Request["tot_num"]); i++) {
            if (ReqVal.TryGet("dseqdel_" + i) != "D") {
                tot_num++;
            }
        }

        //再抓一次交辦流水號,防止多個視窗同時存檔
        string Getatt_sqlno = "0";
        SQL = "select att_sqlno,0 ord from attcase_dmt where in_no='" + in_no + "' and sign_stat='SN' ";
        SQL += "union all ";
        SQL += "select att_sqlno,1 ord from attcase_dmt where in_no='" + in_no + "' and sign_stat='NN' ";
        SQL += "order by ord ";
        using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
            if (dr.Read()) {
                Getatt_sqlno = dr.SafeRead("att_sqlno", "0");
            }
        }

        if (Convert.ToInt32(Getatt_sqlno) > 0) {
            //入attcase_dmt_log
            Sys.insert_log_table(conn, "U", prgid, "attcase_dmt", "att_sqlno", Getatt_sqlno, logReason);

            SQL = "update attcase_dmt set ";
            ColMap.Clear();
            ColMap["pr_scode"] = Util.dbchar(ReqVal.TryGet("pr_scode"));//承辦人員
            ColMap["step_date"] = Util.dbchar(ReqVal.TryGet("step_date"));//發文日期
            ColMap["mp_date"] = Util.dbchar(ReqVal.TryGet("mp_date"));//總管處發文日期
            ColMap["send_cl"] = Util.dbchar(ReqVal.TryGet("send_cl"));//收發單位
            ColMap["send_cl1"] = Util.dbchar(ReqVal.TryGet("send_cl1"));//副本單位
            ColMap["send_sel"] = Util.dbchar(ReqVal.TryGet("send_sel"));//發文性質
            ColMap["rs_class"] = Util.dbchar(ReqVal.TryGet("rs_class"));//發文代碼結構分類
            ColMap["rs_code"] = Util.dbchar(ReqVal.TryGet("rs_code"));//發文代碼
            ColMap["act_code"] = Util.dbchar(ReqVal.TryGet("act_code"));//處理事項代碼
            ColMap["rs_detail"] = Util.dbchar(ReqVal.TryGet("rs_detail"));//發文內容
            ColMap["fees"] = Util.dbzero(ReqVal.TryGet("fees"));//規費
            ColMap["fees_stat"] = Util.dbchar(ReqVal.TryGet("fees_stat"));//規費狀態
            ColMap["rs_agt_no"] = Util.dbchar(ReqVal.TryGet("rs_agt_no"));//出名代理人
            ColMap["opt_branch"] = Util.dbchar(ReqVal.TryGet("opt_branch"));//爭救案處理單位
            if (Request["task"] == "pr") {
                ColMap["sign_stat"] = Util.dbchar("SN");
                ColMap["send_way"] = Util.dbchar(ReqVal.TryGet("send_way"));//發文方式
            }
            SQL += ColMap.GetUpdateSQL();
            SQL += " where att_sqlno=" + Getatt_sqlno;
            conn.ExecuteNonQuery(SQL);
        } else {
            SQL = "insert into attcase_dmt ";
            ColMap.Clear();
            ColMap["in_scode"] = Util.dbchar(ReqVal.TryGet("in_scode"));
            ColMap["in_no"] = Util.dbchar(ReqVal.TryGet("in_no"));
            ColMap["case_no"] = Util.dbchar(ReqVal.TryGet("case_no"));
            ColMap["pr_scode"] = Util.dbchar(ReqVal.TryGet("pr_scode"));
            ColMap["in_date"] = Util.dbchar(DateTime.Today.ToShortDateString());
            ColMap["seq"] = Util.dbnull(tseq);
            ColMap["seq1"] = Util.dbchar(tseq1);
            ColMap["step_date"] = Util.dbchar(ReqVal.TryGet("step_date"));
            ColMap["mp_date"] = Util.dbchar(ReqVal.TryGet("mp_date"));
            ColMap["send_cl"] = Util.dbchar(ReqVal.TryGet("send_cl"));
            ColMap["send_cl1"] = Util.dbchar(ReqVal.TryGet("send_cl1"));
            ColMap["send_sel"] = Util.dbchar(ReqVal.TryGet("send_sel"));
            ColMap["rs_type"] = Util.dbchar(ReqVal.TryGet("rs_type"));
            ColMap["rs_class"] = Util.dbchar(ReqVal.TryGet("rs_class"));
            ColMap["rs_code"] = Util.dbchar(ReqVal.TryGet("rs_code"));
            ColMap["act_code"] = Util.dbchar(ReqVal.TryGet("act_code"));
            ColMap["rs_detail"] = Util.dbchar(ReqVal.TryGet("rs_detail"));
            ColMap["fees"] = Util.dbzero(ReqVal.TryGet("fees"));
            ColMap["fees_stat"] = Util.dbchar(ReqVal.TryGet("fees_stat"));
            ColMap["rs_agt_no"] = Util.dbchar(ReqVal.TryGet("rs_agt_no"));
            ColMap["opt_branch"] = Util.dbchar(ReqVal.TryGet("opt_branch"));
            ColMap["remark"] = Util.dbchar(Request["job_remark"]);
            ColMap["tot_num"] = Util.dbzero(tot_num.ToString());
            ColMap["sign_stat"] = Util.dbchar(sign_stat);
            ColMap["todo_sqlno"] = Util.dbnull(todo_sqlno);
            ColMap["send_way"] = Util.dbchar(ReqVal.TryGet("send_way"));
            SQL += ColMap.GetInsertSQL();
            conn.ExecuteNonQuery(SQL);

            //抓insert後的流水號
            SQL = "SELECT SCOPE_IDENTITY() AS Current_Identity";
            object objResult1 = conn.ExecuteScalar(SQL);
            Getatt_sqlno = objResult1.ToString();
        }

        //新增dmt_attach文件上傳檔
        Sys sfile = new Sys();
        sfile.getFileServer(Sys.GetSession("SeBranch"), prgid);//檔案上傳相關設定
        string strstep_grade = Getatt_sqlno;
        string sattach_path = sfile.gbrWebDir + "/" + Request["attach_path"];
        string uploadfield = (Request["uploadfield"] ?? "").Trim();

        //本次上傳筆數
        int sqlnum = Convert.ToInt32("0" + ReqVal.TryGet(uploadfield + "_filenum"));

        for (int i = 1; i <= sqlnum; i++) {
            string dbflag = ReqVal.TryGet("attach_flag_" + i);
            string attach_sqlno = ReqVal.TryGet("attach_sqlno_" + i);

            if (dbflag == "A") {
                //當上傳路徑不為空的 and attach_sqlno為空的,才需要新增
                if (ReqVal.TryGet(uploadfield + "_" + i) != "" && attach_sqlno == "") {
                    //更換檔名
                    string attach_path = "", attach_name = "";
                    RenameFile(tseq, tseq1, strstep_grade, uploadfield, i, ref attach_path, ref attach_name);

                    SQL = "insert into dmt_attach ";
                    ColMap.Clear();
                    ColMap["Seq"] = Util.dbchar(tseq);
                    ColMap["seq1"] = Util.dbchar(tseq1);
                    ColMap["att_sqlno"] = Util.dbnull(Getatt_sqlno);
                    ColMap["in_no"] = Util.dbchar(Request["in_no"]);
                    ColMap["case_no"] = Util.dbchar(Request["case_no"]);
                    ColMap["source"] = Util.dbchar("cgrs");
                    ColMap["in_date"] = "getdate()";
                    ColMap["in_scode"] = "'" + Session["scode"] + "'";
                    ColMap["attach_no"] = Util.dbchar(Request["attach_no_" + i]);
                    ColMap["attach_path"] = Util.dbchar(attach_path);
                    ColMap["doc_type"] = Util.dbchar(Request["doc_type_" + i]);
                    ColMap["attach_desc"] = Util.dbnull(Request[uploadfield + "_desc_" + i]);
                    ColMap["attach_name"] = Util.dbnull(attach_name);
                    ColMap["source_name"] = Util.dbnull(Request[uploadfield + "_name_" + i]);
                    ColMap["attach_size"] = Util.dbzero(Request[uploadfield + "_size_" + i]);
                    ColMap["attach_flag"] = Util.dbchar("A");
                    ColMap["tran_date"] = "getdate()";
                    ColMap["tran_scode"] = "'" + Session["scode"] + "'";
                    ColMap["doc_flag"] = Util.dbchar(Request["doc_flag_" + i]);
                    SQL += ColMap.GetInsertSQL();
                    conn.ExecuteNonQuery(SQL);
                }
            } else if (dbflag == "U") {
                //當attach_sqlno <> empty時 , 而且上傳的路徑又是空的時候,表示要刪除該筆資料,而非修改
                if (attach_sqlno != "" && ReqVal.TryGet(uploadfield + "_" + i) == "") {
                    Sys.insert_log_table(conn, "D", prgid, "dmt_attach", "attach_sqlno", attach_sqlno, "");

                    //當attach_sqlno <> empty時,表示db有值,必須刪除data(update attach_flag = 'D')
                    SQL = "update dmt_attach set attach_flag='D'";
                    SQL += ",tran_date=getdate(),tran_scode='" + Session["scode"] + "'";
                    SQL += " where attach_sqlno='" + attach_sqlno + "'";
                    conn.ExecuteNonQuery(SQL);
                } else {
                    Sys.insert_log_table(conn, "U", prgid, "dmt_attach", "attach_sqlno", attach_sqlno, "");

                    string old_attach_name = ReqVal.TryGet("old_" + uploadfield + "_name_" + i);//原檔案名稱
                    string attach_name = ReqVal.TryGet(uploadfield + "_name_" + i);//上傳檔名
                    string attach_path = ReqVal.TryGet(uploadfield + "_" + i);
                    string source_name = ReqVal.TryGet("source_name_" + i);

                    if (attach_name != old_attach_name) {//畫面上傳檔名與原檔案名稱不一樣，表示上傳新檔案，所以要更名
                        source_name = attach_name;
                        RenameFile(tseq, tseq1, strstep_grade, uploadfield, i, ref attach_path, ref attach_name);
                    }

                    SQL = "update dmt_attach set ";
                    ColMap.Clear();
                    ColMap["Source"] = Util.dbchar("cgrs");
                    ColMap["attach_path"] = Util.dbchar(Sys.Path2Btbrt(attach_path));
                    ColMap["attach_desc"] = Util.dbnull(Request[uploadfield + "_desc_" + i]);
                    ColMap["attach_name"] = Util.dbnull(attach_name);
                    ColMap["attach_size"] = Util.dbnull(Request[uploadfield + "_size_" + i]);
                    ColMap["source_name"] = Util.dbnull(source_name);
                    ColMap["doc_type"] = Util.dbchar(Request["doc_type_" + i]);
                    ColMap["attach_flag"] = Util.dbchar("U");
                    ColMap["attach_branch"] = Util.dbchar(Request[uploadfield + "_branch_" + i]);
                    ColMap["tran_date"] = "getdate()";
                    ColMap["tran_scode"] = "'" + Session["scode"] + "'";
                    ColMap["doc_flag"] = Util.dbchar(Request["doc_flag_" + i]);
                    SQL += ColMap.GetUpdateSQL();
                    SQL += " where attach_sqlno = '" + attach_sqlno + "'";
                    conn.ExecuteNonQuery(SQL);
                }
            } else if (dbflag == "D") {
                Sys.insert_log_table(conn, "D", prgid, "dmt_attach", "attach_sqlno", attach_sqlno, "");

                //當attach_sqlno <> empty時,表示db有值,必須刪除data(update attach_flag = 'D')
                if (attach_sqlno != "") {
                    SQL = "update dmt_attach set attach_flag='D',tran_date=getdate(),tran_scode='" + Session["scode"] + "'";
                    SQL += " where attach_sqlno='" + attach_sqlno + "'";
                    conn.ExecuteNonQuery(SQL);
                }
            }
        }

        if (Request["task"] == "pr") {
            //更新todo_dmt承辦交辦發文
            update_todolist(todo_sqlno, "YY");
            if (Request["contract_flag"] == "Y") {//尚有契約書需後補，先經主管簽核
                string in_team = Sys.getCodeName(conn, "sysctrl.dbo.scode_group", "grpid", "where grpclass='" + Session["seBranch"] + "' and scode='" + Request["in_scode"] + "'");
                string job_team = Sys.getCodeName(conn, "sysctrl.dbo.scode_group", "grpid", "where grpclass='" + Session["seBranch"] + "' and scode='" + Request["signid"] + "'");

                SQL = "insert into todo_dmt ";
                ColMap.Clear();
                ColMap["pre_sqlno"] = Util.dbnull(todo_sqlno);
                ColMap["syscode"] = "'" + Session["syscode"] + "'";
                ColMap["apcode"] = "'" + prgid + "'";
                ColMap["temp_rs_sqlno"] = Util.dbnull(Getatt_sqlno);
                ColMap["branch"] = "'" + Session["seBranch"] + "'";
                ColMap["seq"] = Util.dbnull(tseq);
                ColMap["seq1"] = Util.dbchar(tseq1);
                ColMap["in_team"] = Util.dbchar(in_team);
                ColMap["case_in_scode"] = Util.dbchar(Request["in_scode"]);
                ColMap["in_no"] = Util.dbchar(Request["in_no"]);
                ColMap["case_no"] = Util.dbchar(Request["case_no"]);
                ColMap["from_flag"] = Util.dbchar("CGRS");
                ColMap["in_date"] = "getdate()";
                ColMap["in_scode"] = "'" + Session["scode"] + "'";
                ColMap["dowhat"] = Util.dbchar("DB_GS");//主管發文簽核,ref:cust_code.code_type='Ttodo'
                ColMap["job_team"] = Util.dbchar(job_team);
                ColMap["job_scode"] = Util.dbchar(Request["signid"]);
                ColMap["job_status"] = Util.dbchar("NN");
                SQL += ColMap.GetInsertSQL();
                conn.ExecuteNonQuery(SQL);
            } else {
                //新增todo_dmt程序官發確認，無契約書後補或已後補完成
                string in_team = Sys.getCodeName(conn, "sysctrl.dbo.scode_group", "grpid", "where grpclass='" + Session["seBranch"] + "' and scode='" + Request["in_scode"] + "'");
                string job_scode = Sys.getCodeName(conn, "sysctrl.dbo.scode_group", "scode", "where grpclass='" + Session["seBranch"] + "' and grpid='T210' and grptype='F'");

                SQL = "insert into todo_dmt ";
                ColMap.Clear();
                ColMap["pre_sqlno"] = Util.dbnull(todo_sqlno);
                ColMap["syscode"] = "'" + Session["syscode"] + "'";
                ColMap["apcode"] = "'" + prgid + "'";
                ColMap["temp_rs_sqlno"] = Util.dbnull(Getatt_sqlno);
                ColMap["branch"] = "'" + Session["seBranch"] + "'";
                ColMap["seq"] = Util.dbnull(tseq);
                ColMap["seq1"] = Util.dbchar(tseq1);
                ColMap["in_team"] = Util.dbchar(in_team);
                ColMap["case_in_scode"] = Util.dbchar(Request["in_scode"]);
                ColMap["in_no"] = Util.dbchar(Request["in_no"]);
                ColMap["case_no"] = Util.dbchar(Request["case_no"]);
                ColMap["from_flag"] = Util.dbchar("CGRS");
                ColMap["in_date"] = "getdate()";
                ColMap["in_scode"] = "'" + Session["scode"] + "'";
                ColMap["dowhat"] = Util.dbchar("DC_GS");//程序官發確認,ref:cust_code.code_type='Ttodo'
                ColMap["job_team"] = Util.dbchar("T210");
                ColMap["job_scode"] = Util.dbchar(job_scode);
                ColMap["job_status"] = Util.dbchar("NN");
                SQL += ColMap.GetInsertSQL();
                conn.ExecuteNonQuery(SQL);
            }
        }
    }

    private void doCancel() {
        //入交辦發文檔註記不發文
        string in_no = ReqVal.TryGet("in_no");

        //再抓一次交辦流水號,防止多個視窗同時存檔
        string Getatt_sqlno = "0";
        SQL = "select att_sqlno,0 ord from attcase_dmt where in_no='" + in_no + "' and sign_stat='SN' ";
        SQL += "union all ";
        SQL += "select att_sqlno,1 ord from attcase_dmt where in_no='" + in_no + "' and sign_stat='NN' ";
        SQL += "order by ord ";
        using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
            if (dr.Read()) {
                Getatt_sqlno = dr.SafeRead("att_sqlno", "0");
            }
        }

        if (Convert.ToInt32(Getatt_sqlno) > 0) {
            //入attcase_dmt_log
            Sys.insert_log_table(conn, "U", prgid, "attcase_dmt", "att_sqlno", Getatt_sqlno, logReason);

            SQL = "update attcase_dmt set ";
            ColMap.Clear();
            ColMap["sign_stat"] = Util.dbchar("SX");
            SQL += ColMap.GetUpdateSQL();
            SQL += " where att_sqlno=" + Getatt_sqlno;
            conn.ExecuteNonQuery(SQL);
        } else {
            SQL = "insert into attcase_dmt ";
            ColMap.Clear();
            ColMap["in_scode"] = Util.dbchar(ReqVal.TryGet("in_scode"));
            ColMap["in_no"] = Util.dbchar(ReqVal.TryGet("in_no"));
            ColMap["case_no"] = Util.dbchar(ReqVal.TryGet("case_no"));
            ColMap["pr_scode"] = Util.dbchar(Sys.GetSession("scode"));
            ColMap["in_date"] = Util.dbchar(DateTime.Today.ToShortDateString());
            ColMap["seq"] = Util.dbchar(ReqVal.TryGet("seq"));
            ColMap["seq1"] = Util.dbchar(ReqVal.TryGet("seq1"));
            ColMap["remark"] = Util.dbchar(ReqVal.TryGet("job_remark"));
            ColMap["sign_stat"] = Util.dbchar("SX");
            ColMap["todo_sqlno"] = Util.dbnull(ReqVal.TryGet("todo_sqlno"));
            SQL += ColMap.GetInsertSQL();
            conn.ExecuteNonQuery(SQL);
        }
        
        //銷管制期限
        if (ReqVal.TryGet("rsqlno") != "") {
            string[] ar = ReqVal.TryGet("rsqlno").Split(';');
            for (int i = 0; i < ar.Length; i++) {
                //讀取銷管資料
                SQL = "insert into resp_dmt(sqlno,rs_no,branch,seq,seq1,step_grade,resp_grade,ctrl_type,ctrl_remark,ctrl_date,resp_date,resp_remark,tran_date,tran_scode) ";
                SQL += "select sqlno,rs_no,branch,seq,seq1,step_grade,0,ctrl_type,ctrl_remark,ctrl_date,'" + DateTime.Today.ToShortDateString() + "','交辦發文註記不發文',getdate(),'" + Session["scode"] + "' ";
                SQL += "from ctrl_dmt where sqlno in(";
                SQL += "select sqlno from ctrl_dmt where sqlno='" + ar[i] + "'";
                SQL += ")";
                conn.ExecuteNonQuery(SQL);

                SQL = "delete from ctrl_dmt where sqlno in(";
                SQL += "select sqlno from ctrl_dmt where sqlno='" + ar[i] + "'";
                SQL += ")";
                conn.ExecuteNonQuery(SQL);
            }
        }

        //更新todo_dmt承辦不需發文
        update_todolist(ReqVal.TryGet("todo_sqlno"), "SX");
    }
    
    //更新todolist
    private void update_todolist(string todo_sqlno, string tstatus) {
        SQL = "update todo_dmt set approve_scode='" + Session["scode"] + "'";
        SQL += ",resp_date=getdate()";
        SQL += ",job_status='" + tstatus + "'";
        SQL += ",approve_desc=" + Util.dbchar(ReqVal.TryGet("job_remark"));
        SQL += " where sqlno=" + todo_sqlno + " and job_status='NN' ";
        conn.ExecuteNonQuery(SQL);
    }
    
    
    /// <summary>
    /// 更換檔名(單位-案號-副號-進度序號-attach_no,EX:NT-01234--0001-1.pdf)
    /// </summary>
    private void RenameFile(string seq, string seq1, string step_grade, string uploadfield, int nRow, ref string attach_path, ref string attach_name) {
        Sys sfile = new Sys();
        sfile.getFileServer(Sys.GetSession("SeBranch"), Request["prgid"]);//檔案上傳相關設定

        string aa = System.IO.Path.GetFileName(Request[uploadfield + "_name_" + nRow]);//上傳檔名
        string ar = System.IO.Path.GetExtension(aa);//副檔名
        string lname = string.Format("{0}-{1}-{2}-{3}-{4}{5}"//新檔名
                                    , Sys.GetSession("SeBranch") + Sys.GetSession("dept").ToUpper()//0
                                    , seq.PadLeft(Sys.DmtSeq, '0')//1
                                    , seq1 != "_" ? seq1 : ""//2
                                    , Convert.ToInt32(step_grade)//3
                                    , Request["attach_no_" + nRow]//4
                                    , ar);

        string strpath = Request[uploadfield + "_" + nRow];//存檔路徑
        Sys.RenameFile(Sys.Path2Nbtbrt(strpath + "/" + aa), Sys.Path2Nbtbrt(strpath + "/" + lname), true);

        attach_path = Sys.Path2Btbrt(strpath + "/" + lname);//存入資料庫路徑+新檔名
        attach_name = lname;//新檔名
    }
</script>

<%Response.Write(strOut.ToString());%>
