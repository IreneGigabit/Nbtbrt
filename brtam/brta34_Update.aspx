<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Linq"%>

<script runat="server">
    protected string HTProgCap = "國內案本所發文作業-入檔";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = HttpContext.Current.Request["prgid"] ?? "";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";

    protected string submitTask = "";
    protected string SQL = "";
    protected object objResult = null;

    protected string logReason = "";
    protected string rs_no = "";

    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected Dictionary<string, string> ColMap = new Dictionary<string, string>();

    protected StringBuilder strOut = new StringBuilder();

    DBHelper conn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    DBHelper connm = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    private void Page_Unload(System.Object sender, System.EventArgs e) {
        if (conn != null) conn.Dispose();
        if (connm != null) connm.Dispose();
    }

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");

        string in_scode = (Request["in_scode"] ?? "").Trim();
        string in_no = (Request["in_no"] ?? "").Trim();

        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        HTProgCap = myToken.Title;
        DebugStr = myToken.DebugStr;
        if (HTProgRight >= 0) {
            try {
                conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
                connm = new DBHelper(Conn.MG).Debug(Request["chkTest"] == "TEST");

                if (ReqVal.TryGet("submittask") == "A") {
                    doAdd();
                    strOut.AppendLine("<div align='center'><h3><font color=blue>本所發文確認成功!!!本發序號:(" + rs_no + ")</font></h3></div>");
                } else if (ReqVal.TryGet("submittask") == "U") {
                    doUpdate();
                    strOut.AppendLine("<div align='center'><h3><font color=blue>本所發文維護成功!!!本發序號:(" + Request["rs_no"] + ")</font></h3></div>");
                }
                conn.Commit();
                connm.Commit();
                //conn.RollBack();
                //connm.RollBack();
            }
            catch (Exception ex) {
                conn.RollBack();
                connm.RollBack();
                Sys.errorLog(ex, conn.exeSQL, prgid);
                //strOut.AppendLine("<div align='center'><h1>修改交辦案件狀態失敗("+ex.Message+")</h1></div>");
                throw;
            }

            this.DataBind();
        }
    }

    private void doAdd() {
        logReason = "Brta34國內案本發確認作業";

        //發文序號
        rs_no = Sys.getRsNo(conn, "ZS");
        //本發入step_dmt
        SQL = "insert into step_dmt ";
        ColMap.Clear();
        ColMap["rs_no"] = Util.dbchar(rs_no);
        ColMap["branch"] = Util.dbchar(Sys.GetSession("seBranch"));
        ColMap["seq"] = Util.dbnull(Request["seq"]);
        ColMap["seq1"] = Util.dbchar(Request["seq1"]);
        ColMap["step_grade"] = Util.dbnull(Request["nstep_grade"]);
        ColMap["main_rs_no"] = Util.dbchar(rs_no);
        ColMap["step_date"] = Util.dbnull(Request["step_date"]);
        ColMap["gov_date"] = Util.dbnull(Request["gov_date"]);
        ColMap["cg"] = Util.dbchar("Z");
        ColMap["rs"] = Util.dbchar("S");
        ColMap["send_cl"] = Util.dbnull(Request["send_cl"]);
        ColMap["rs_type"] = Util.dbnull(Request["rs_type"]);
        ColMap["rs_class"] = Util.dbchar(Request["rs_class"]);
        ColMap["rs_code"] = Util.dbchar(Request["rs_code"]);
        ColMap["act_code"] = Util.dbchar(Request["act_code"]);
        ColMap["rs_detail"] = Util.dbnull(Request["rs_detail"]);
        ColMap["doc_detail"] = Util.dbnull(Request["doc_detail"]);
        ColMap["pr_status"] = Util.dbnull("X");
        ColMap["new"] = Util.dbchar("N");
        ColMap["tot_num"] = Util.dbzero("1");
        ColMap["tran_date"] = "getdate()";
        ColMap["tran_scode"] = "'" + Session["scode"] + "'";
        ColMap["receive_way"] = Util.dbnull(Request["receive_way"]);
        SQL += ColMap.GetInsertSQL();
        conn.ExecuteNonQuery(SQL);
        //抓insert後的流水號
        SQL = "SELECT SCOPE_IDENTITY() AS Current_Identity";
        objResult = conn.ExecuteScalar(SQL);
        string Getrs_sqlno = objResult.ToString();
        Sys.showLog("進度流水號=" + Getrs_sqlno);

        //上傳文件處理
        Insert_dmt_attach(Request["seq"], Request["seq1"], Request["nstep_grade"], "");

        //案件主檔進度序號加一 & 相關欄位 Update
        Sys.insert_log_table(conn, "U", prgid, "dmt", "seq;seq1", Request["seq"] + ";" + Request["seq1"], logReason);
        SQL = "update dmt set step_grade=step_grade+1 where seq=" + Request["seq"] + " and seq1='" + Request["seq1"] + "'";
        conn.ExecuteNonQuery(SQL);

        //客收進度之本發資料更新
        //新增 step_dmt_Log 檔
        Sys.insert_log_table(conn, "U", prgid, "step_dmt", "rs_no", Request["cr_rs_no"], logReason);
        SQL = "update step_dmt set zs_rs_sqlno=" + Getrs_sqlno + ",tran_date=getdate(),tran_scode='" + Session["scode"] + "'";
        SQL += " where rs_no='" + Request["cr_rs_no"] + "'";
        conn.ExecuteNonQuery(SQL);

        //入總收發文之brstep_mgt
        string s_mark1 = ReqVal.TryGet("s_mark");
        if (s_mark1 == "") s_mark1 = "_";

        SQL = "insert into brstep_mgt(seq_area,seq,seq1,br_in_date,br_step_grade,br_rs_sqlno,cr_step_grade,cr_rs_sqlno,cg,rs,br_rs_no";
        SQL += ",rs_type,rs_class,rs_class_name,rs_code,rs_code_name,act_code,act_code_name,rs_detail,send_cl,step_date,receive_way,cappl_name";
        SQL += ",s_mark1,country,apply_date,apply_no,issue_date,issue_no2,issue_no3,open_date,pay_times,pay_date,term1,term2,end_date,end_code";
        SQL += ",branch_date,branch_scode,tran_date,tran_scode) values (";
        SQL += "'" + Session["seBranch"] + "'," + Request["seq"] + ",'" + Request["seq1"] + "'," + Util.dbnull(Request["in_date"]) + "," + Util.dbnull(Request["nstep_grade"]);
        SQL += "," + Getrs_sqlno + "," + Request["cr_step_grade"] + "," + Request["cr_rs_sqlno"] + ",'Z','R','" + rs_no + "','" + Request["rs_type"] + "'";
        SQL += ",'" + Request["rs_class"] + "'," + Util.dbchar(Request["rs_class_name"]) + ",'" + Request["rs_code"] + "'," + Util.dbchar(Request["rs_code_name"]);
        SQL += ",'" + Request["act_code"] + "'," + Util.dbchar(Request["act_code_name"]) + "," + Util.dbchar(Request["rs_detail"]) + ",'" + Request["send_cl"] + "'";
        SQL += "," + Util.dbnull(Request["step_date"]) + ",'" + Request["receive_way"] + "'," + Util.dbchar(Request["appl_name"]) + ",'" + s_mark1 + "','T'";
        SQL += "," + Util.dbnull(Request["apply_date"]) + ",'" + Request["apply_no"] + "'," + Util.dbnull(Request["issue_date"]) + ",'" + Request["issue_no"] + "'";
        SQL += ",'" + Request["rej_no"] + "'," + Util.dbnull(Request["open_date"]) + "," + Util.dbchar(Request["pay_times"]) + "," + Util.dbnull(Request["pay_date"]);
        SQL += "," + Util.dbnull(Request["term1"]) + "," + Util.dbnull(Request["term2"]) + "," + Util.dbnull(Request["end_date"]) + ",'" + Request["end_code"] + "'";
        SQL += ",getdate(),'" + Session["scode"] + "',getdate(),'" + Session["scode"] + "')";
        connm.ExecuteNonQuery(SQL);
        //抓insert後的流水號
        SQL = "SELECT SCOPE_IDENTITY() AS Current_Identity";
        objResult = connm.ExecuteScalar(SQL);
        string Getmgrs_sqlno = objResult.ToString();
        Sys.showLog("總收發發文暫存流水號=" + Getmgrs_sqlno);

        //入總收發文之brctrl_mgt
        for (int i = 1; i <= Convert.ToInt32("0" + Request["ctrlnum"]); i++) {
            if ((Request["ctrl_type_" + i] ?? "") != "" || (Request["ctrl_date_" + i] ?? "") != "") {
                SQL = "insert into brctrl_mgt ";
                ColMap.Clear();
                ColMap["brstep_sqlno"] = Util.dbnull(Getmgrs_sqlno);
                ColMap["seq_area"] = Util.dbchar(Sys.GetSession("seBranch"));
                ColMap["seq"] = Util.dbnull(Request["seq"]);
                ColMap["seq1"] = Util.dbchar(Request["seq1"]);
                ColMap["br_rs_sqlno"] = Util.dbnull(Getrs_sqlno);
                ColMap["br_step_grade"] = Util.dbnull(Request["nstep_grade"]);
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
        SQL = "insert into todo_mgt(syscode,apcode,temp_rs_sqlno,br_rs_sqlno,seq_area,seq,seq1,rs,rs_no,in_date,in_scode,dowhat,job_status) values (";
        SQL += "'" + Session["syscode"] + "','" + prgid + "'," + Getmgrs_sqlno + "," + Getrs_sqlno + ",'" + Session["seBranch"] + "'," + Request["seq"];
        SQL += ",'" + Request["seq1"] + "','R','" + rs_no + "',getdate(),'" + Session["scode"] + "','br_zr','NN')";
        connm.ExecuteNonQuery(SQL);

        //Email通知總管處人員
        CreateMail();
    }

    private void doUpdate() {
        logReason = "Brta2m國內案本發維護作業";
        
        //入log
        Sys.insert_log_table(conn, "U", prgid, "step_dmt", "rs_no", Request["rs_no"], logReason);
        //本發修改step_dmt
        SQL = "update step_dmt set step_date=" + Util.dbnull(Request["step_date"]);
        SQL += ",gov_date=" + Util.dbnull(Request["gov_date"]);
        SQL += ",send_cl=" + Util.dbnull(Request["send_cl"]);
        SQL += ",rs_type=" + Util.dbnull(Request["rs_type"]);
        SQL += ",rs_class=" + Util.dbchar(Request["rs_class"]);
        SQL += ",rs_code=" + Util.dbchar(Request["rs_code"]);
        SQL += ",act_code=" + Util.dbchar(Request["act_code"]);
        SQL += ",rs_detail=" + Util.dbchar(Request["rs_detail"]);
        SQL += ",doc_detail=" + Util.dbnull(Request["doc_detail"]);
        SQL += ",tran_date=getdate(),tran_scode='" + Session["scode"] + "'";
        SQL += ",receive_way=" + Util.dbnull(Request["receive_way"]);
        SQL += " where rs_no='" + Request["rs_no"] + "'";
        conn.ExecuteNonQuery(SQL);

        //上傳文件處理
        Insert_dmt_attach(Request["seq"], Request["seq1"], Request["nstep_grade"], "");
    }

    //新增文件上傳dmt_attach
    private void Insert_dmt_attach(string pseq, string pseq1, string pstep_grade, string patt_sqlno) {
        string uploadfield = ReqVal.TryGet("uploadfield");

        //目前資料庫中有的最大值
        string maxAttach_no = ReqVal.TryGet(uploadfield + "_maxAttach_no");
        //目前畫面上的最大值
        string filenum = ReqVal.TryGet("maxattach_no");
        //本次上傳筆數
        int sqlnum = Convert.ToInt32("0" + ReqVal.TryGet(uploadfield + "_filenum"));
        //目前table的筆數
        string attach_cnt = ReqVal.TryGet(uploadfield + "_attach_cnt");

        for (int i = 1; i <= sqlnum; i++) {
            string dbflag = ReqVal.TryGet("attach_flag_" + i);
            string attach_sqlno = ReqVal.TryGet("attach_sqlno_" + i);

            //keep修改前資料
            SQL = "Select * from dmt_attach where seq='" + pseq + "' and seq1='" + pseq1 + "' and step_grade='" + pstep_grade + "' and source='cgrs'";
            DataTable dtO = new DataTable();
            conn.DataTable(SQL, dtO);

            if (dbflag == "A") {
                //當上傳路徑不為空的 and attach_sqlno為空的,才需要新增
                if (ReqVal.TryGet(uploadfield + "_" + i) != "" && attach_sqlno == "") {
                    //更換檔名
                    string attach_path = "", attach_name = "";
                    RenameFile(pseq, pseq1, pstep_grade, uploadfield, i, ref attach_path, ref attach_name);

                    SQL = "insert into dmt_attach ";
                    ColMap.Clear();
                    ColMap["Seq"] = Util.dbchar(pseq);
                    ColMap["seq1"] = Util.dbchar(pseq1);
                    ColMap["step_grade"] = Util.dbchar(pstep_grade);
                    ColMap["case_no"] = Util.dbchar(Request["attach_case_no"]);
                    ColMap["in_no"] = Util.dbchar(Request["in_no"]);
                    ColMap["Source"] = Util.dbchar("cgrs");
                    ColMap["in_date"] = "getdate()";
                    ColMap["in_scode"] = "'" + Session["scode"] + "'";
                    ColMap["Attach_no"] = Util.dbchar(Request["attach_no_" + i]);
                    ColMap["attach_path"] = Util.dbchar(attach_path);
                    ColMap["doc_type"] = Util.dbchar(Request["doc_type_" + i]);
                    ColMap["attach_desc"] = Util.dbnull(Request[uploadfield + "_desc_" + i]);
                    ColMap["Attach_name"] = Util.dbnull(attach_name);
                    ColMap["source_name"] = Util.dbnull(Request[uploadfield + "_name_" + i]);
                    ColMap["Attach_size"] = Util.dbnull(Request[uploadfield + "_size_" + i]);
                    ColMap["attach_flag"] = Util.dbchar("A");
                    ColMap["Mark"] = Util.dbchar("");
                    ColMap["tran_date"] = "getdate()";
                    ColMap["tran_scode"] = "'" + Session["scode"] + "'";
                    ColMap["att_sqlno"] = Util.dbchar(patt_sqlno);
                    ColMap["doc_flag"] = Util.dbchar(Request["doc_flag_" + i]);
                    SQL += ColMap.GetInsertSQL();
                    conn.ExecuteNonQuery(SQL);
                }
            } else if (dbflag == "U") {
                //當attach_sqlno <> empty時 , 而且上傳的路徑又是空的時候,表示要刪除該筆資料,而非修改
                if (attach_sqlno != "" && ReqVal.TryGet(uploadfield + "_" + i) == "") {
                    Sys.insert_log_table(conn, "D", prgid, "dmt_attach", "attach_sqlno", attach_sqlno, logReason);

                    //當attach_sqlno <> empty時,表示db有值,必須刪除data(update attach_flag = 'D')
                    SQL = "update dmt_attach set attach_flag='D'";
                    SQL += ",tran_date=getdate(),tran_scode='" + Session["scode"] + "'";
                    SQL += " where attach_sqlno='" + attach_sqlno + "'";
                    conn.ExecuteNonQuery(SQL);

                } else {
                    Sys.insert_log_table(conn, "U", prgid, "dmt_attach", "attach_sqlno", attach_sqlno, logReason);

                    string old_attach_name = ReqVal.TryGet("old_" + uploadfield + "_name_" + i);//原檔案名稱
                    string attach_name = ReqVal.TryGet(uploadfield + "_name_" + i);//上傳檔名
                    string attach_path = ReqVal.TryGet(uploadfield + "_" + i);
                    string source_name = ReqVal.TryGet("source_name_" + i);

                    if (attach_name != old_attach_name) {//畫面上傳檔名與原檔案名稱不一樣，表示上傳新檔案
                        source_name = attach_name;
                    }
                    RenameFile(pseq, pseq1, pstep_grade, uploadfield, i, ref attach_path, ref attach_name);

                    SQL = "update dmt_attach set ";
                    ColMap.Clear();
                    ColMap["Source"] = Util.dbchar("cgrs");
                    ColMap["step_grade"] = Util.dbchar(pstep_grade);
                    ColMap["attach_path"] = Util.dbchar(Sys.Path2Btbrt(attach_path));
                    ColMap["attach_desc"] = Util.dbnull(Request[uploadfield + "_desc_" + i]);
                    ColMap["Attach_name"] = Util.dbnull(attach_name);
                    ColMap["Attach_size"] = Util.dbnull(Request[uploadfield + "_size_" + i]);
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
                Sys.insert_log_table(conn, "D", prgid, "dmt_attach", "attach_sqlno", attach_sqlno, logReason);

                //當attach_sqlno <> empty時,表示db有值,必須刪除data(update attach_flag = 'D')
                if (attach_sqlno != "") {
                    SQL = "update dmt_attach set attach_flag='D',tran_date=getdate(),tran_scode='" + Session["scode"] + "'";
                    SQL += " where attach_sqlno='" + attach_sqlno + "'";
                    conn.ExecuteNonQuery(SQL);
                }
            }
        }
    }

    /// <summary>
    /// 更換檔名(單位-案號-副號-進度序號-attach_no,EX:NT-01234--0001-1.pdf)
    /// </summary>
    private void RenameFile(string seq, string seq1, string step_grade, string uploadfield, int nRow, ref string attach_path, ref string attach_name) {
        Sys sfile = new Sys();
        sfile.getFileServer(Sys.GetSession("SeBranch"), Request["prgid"]);//檔案上傳相關設定

        string fseq = seq.PadLeft(Sys.DmtSeq, '0');
        string aa = System.IO.Path.GetFileName(Request[uploadfield + "_name_" + nRow]);//上傳檔名
        string ar = System.IO.Path.GetExtension(aa);//副檔名
        string lname = string.Format("{0}-{1}-{2}-{3:0000}-{4}{5}"//新檔名
                                    , Sys.GetSession("SeBranch") + Sys.GetSession("dept").ToUpper()//0
                                    , fseq//1
                                    , seq1 != "_" ? seq1 : ""//2
                                    , Convert.ToInt32(step_grade)//3
                                    , Request["attach_no_" + nRow]//4
                                    , ar);

        string strpath = Request[uploadfield + "_" + nRow];//存檔路徑+檔名
        if (strpath.IndexOf(".") > -1) strpath = System.IO.Path.GetDirectoryName(strpath);//如果有含檔名則只取目錄
        Sys.RenameFile(Sys.Path2Nbtbrt(strpath + "/" + aa), Sys.Path2Nbtbrt(strpath + "/" + lname), true);

        attach_path = Sys.Path2Btbrt(strpath + "/" + lname);//存入資料庫路徑+新檔名
        attach_name = lname;//新檔名
    }

    private void CreateMail() {
        string Subject = "";
        string strFrom = Session["scode"] + "@saint-island.com.tw";
        List<string> strTo = new List<string>();
        List<string> strCC = new List<string>();
        List<string> strBCC = new List<string>();
        switch (Sys.Host) {
            case "web08":
            case "localhost":
                strTo.Add(Session["scode"] + "@saint-island.com.tw");
                break;
            case "web10":
                strTo = ReqVal.TryGet("emg_scode").Split(';').Where(p => p != "").Select(o => o + "@saint-island.com.tw").ToList();
                strCC = ReqVal.TryGet("emg_agscode").Split(';').Where(p => p != "").Select(o => o + "@saint-island.com.tw").ToList();
                strTo.Add(Session["scode"] + "@saint-island.com.tw");
                strBCC.Add("m1583@saint-island.com.tw");
                break;
            default:
                strTo = ReqVal.TryGet("emg_scode").Split(';').Where(p => p != "").Select(o => o + "@saint-island.com.tw").ToList();
                strCC = ReqVal.TryGet("emg_agscode").Split(';').Where(p => p != "").Select(o => o + "@saint-island.com.tw").ToList();
                break;
        }

        string fseq=Sys.formatSeq(ReqVal.TryGet("seq"),ReqVal.TryGet("seq1"),"",Sys.GetSession("seBranch"),Sys.GetSession("dept"));
        string body = "<B>致: 總管處 程序</B><br><br>";
        body += "【區所案件編號】 : <B>" + fseq + "</B><br>";
        body += "【案件名稱】 : <B>" + Request["appl_name"] + "</B><br>";
        body += "【區所發文日期】 : <B>" + Request["step_date"] +"</B><br>";
        body += "【發文內容】 : <B>" + Request["rs_detail"] +  "</B><br>";
        body += "【法定期限】 : <B>" + Request["ctrl_date_1"] + "</B><br>";

        Subject = "國內所商標網路系統－本所發文通知（區所編號： " + fseq + " ）";

        Sys.DoSendMail(Subject, body, strFrom, strTo, strCC, strBCC);
    }
</script>

<%Response.Write(strOut.ToString());%>
