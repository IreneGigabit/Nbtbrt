<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>

<script runat="server">
    protected string HTProgCap = "內商文件上傳存檔入檔";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = HttpContext.Current.Request["prgid"] ?? "";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";

    protected string SQL = "";
    protected object objResult = null;
    
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

        string in_scode = (Request["in_scode"] ?? "").Trim();
        string in_no = (Request["in_no"] ?? "").Trim();

        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        HTProgCap = myToken.Title;
        DebugStr = myToken.DebugStr;
        if (HTProgRight >= 0) {
            try {
                conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");

                doUpdateDB();
                conn.Commit();
                //conn.RollBack();
                strOut.AppendLine("<div align='center'><h1>文件維護成功!!</h1></div>");
            }
            catch (Exception ex) {
                conn.RollBack();
                Sys.errorLog(ex, conn.exeSQL, prgid);
                //strOut.AppendLine("<div align='center'><h1>文件維護失敗("+ex.Message+")</h1></div>");
                throw;
            }

            this.DataBind();
        }
    }

    private void doUpdateDB() {
        string seq = ReqVal.TryGet("seq");
        string seq1 = ReqVal.TryGet("seq1");
        string step_grade = ReqVal.TryGet("step_grade");
        string step_date = ReqVal.TryGet("step_date");
        string uploadfield = ReqVal.TryGet("uploadfield");
        string tsqlnum = ReqVal.TryGet("tsqlnum");
        string pcg = ReqVal.TryGet("pcg");
        string prs = ReqVal.TryGet("prs");
        string uploadsource = ReqVal.TryGet("uploadSource");

        //目前資料庫中有的最大值
        string maxAttach_no = ReqVal.TryGet(uploadfield + "_maxAttach_no");
        //目前畫面上的最大值
        string filenum = ReqVal.TryGet("maxattach_no");
        //本次上傳筆數
        int sqlnum = Convert.ToInt32("0" + ReqVal.TryGet(uploadfield + "_filenum"));
        //目前table的筆數
        string attach_cnt = ReqVal.TryGet(uploadfield + "_attach_cnt");

        //目前畫面上的最大值
        for (int i = 1; i <= sqlnum; i++) {
            string dbflag = ReqVal.TryGet("attach_flag_" + i);
            string attach_sqlno = ReqVal.TryGet("attach_sqlno_" + i);

            //keep修改前資料
            SQL = "Select * from dmt_attach where seq='" + seq + "' and seq1='" + seq1 + "' and attach_sqlno='" + attach_sqlno + "'";
            DataTable dtO = new DataTable();
            conn.DataTable(SQL, dtO);

            if (dbflag == "A") {
                //當上傳路徑不為空的 and attach_sqlno為空的,才需要新增
                if (ReqVal.TryGet(uploadfield + "_" + i) != "" && attach_sqlno == "") {
                    //進度0檢查進度檔無資料的話先新增
                    if (step_grade == "0") {
                        Insert_stepZZ(seq, seq1);
                    }

                    //更換檔名
                    string attach_path = "", attach_name = "";
                    RenameFile(seq, seq1, step_grade, uploadfield, i, ref attach_path, ref attach_name);

                    SQL = "insert into dmt_attach ";
                    ColMap.Clear();
                    ColMap["Seq"] = Util.dbchar(seq);
                    ColMap["seq1"] = Util.dbchar(seq1);
                    ColMap["step_grade"] = Util.dbchar(step_grade);
                    ColMap["case_no"] = Util.dbchar(Request["attach_case_no"]);
                    ColMap["in_no"] = Util.dbchar(Request["attach_in_no"]);
                    ColMap["Source"] = Util.dbchar(uploadsource);
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
                    if (ReqVal.TryGet("cgrs") == "GS") {
                        ColMap["doc_flag"] = Util.dbnull(Request["doc_flag_" + i]);
                    }
                    ColMap["tran_date"] = "getdate()";
                    ColMap["tran_scode"] = "'" + Session["scode"] + "'";
                    ColMap["attach_branch"] = Util.dbchar(Request[uploadfield + "_branch_" + i]);
                    SQL += ColMap.GetInsertSQL();
                    conn.ExecuteNonQuery(SQL);

                    iposend_attach(seq, seq1, step_grade, step_date, ReqVal.TryGet("rs_code_name"), "A", ReqVal.TryGet("doc_flag_" + i), attach_path, ReqVal.TryGet(uploadfield + "_name_" + i), dtO);
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

                    iposend_attach(seq, seq1, step_grade, step_date, ReqVal.TryGet("rs_code_name"), "D", "", "", "", dtO);
                } else {
                    Sys.insert_log_table(conn, "U", prgid, "dmt_attach", "attach_sqlno", attach_sqlno, "");

                    string old_attach_name = ReqVal.TryGet("old_" + uploadfield + "_name_" + i);//原檔案名稱
                    string attach_name = ReqVal.TryGet(uploadfield + "_name_" + i);//上傳檔名
                    string attach_path = ReqVal.TryGet(uploadfield + "_" + i);
                    string source_name = ReqVal.TryGet("source_name_" + i);

                    if (attach_name != old_attach_name) {//畫面上傳檔名與原檔案名稱不一樣，表示上傳新檔案，所以要更名
                        source_name = attach_name;
                        RenameFile(seq, seq1, step_grade, uploadfield, i, ref attach_path, ref attach_name);
                    }

                    SQL = "update dmt_attach set ";
                    ColMap.Clear();
                    ColMap["Source"] = Util.dbchar(uploadsource);
                    ColMap["attach_path"] = Util.dbchar(Sys.Path2Btbrt(attach_path));
                    ColMap["attach_desc"] = Util.dbnull(Request[uploadfield + "_desc_" + i]);
                    ColMap["Attach_name"] = Util.dbnull(attach_name);
                    ColMap["Attach_size"] = Util.dbnull(Request[uploadfield + "_size_" + i]);
                    ColMap["source_name"] = Util.dbnull(source_name);
                    ColMap["doc_type"] = Util.dbchar(Request["doc_type_" + i]);
                    ColMap["attach_flag"] = Util.dbchar("U");
                    ColMap["attach_branch"] = Util.dbchar(Request[uploadfield + "_branch_" + i]);
                    if (ReqVal.TryGet("cgrs") == "GS") {
                        ColMap["doc_flag"] = Util.dbnull(Request["doc_flag_" + i]);
                    }
                    ColMap["tran_date"] = "getdate()";
                    ColMap["tran_scode"] = "'" + Session["scode"] + "'";
                    SQL += ColMap.GetUpdateSQL();
                    SQL += " where attach_sqlno = '" + attach_sqlno + "'";
                    conn.ExecuteNonQuery(SQL);

                    iposend_attach(seq, seq1, step_grade, step_date, ReqVal.TryGet("rs_code_name"), "U", ReqVal.TryGet("doc_flag_" + i), attach_path, Request["source_name_" + i], dtO);
                }
            } else if (dbflag == "D") {
                Sys.insert_log_table(conn, "D", prgid, "dmt_attach", "attach_sqlno", attach_sqlno, "");

                //當attach_sqlno <> empty時,表示db有值,必須刪除data(update attach_flag = 'D')
                if (attach_sqlno != "") {
                    SQL = "update dmt_attach set attach_flag='D',tran_date=getdate(),tran_scode='" + Session["scode"] + "'";
                    SQL += " where attach_sqlno='" + attach_sqlno + "'";
                    conn.ExecuteNonQuery(SQL);
                }

                iposend_attach(seq, seq1, step_grade, step_date, ReqVal.TryGet("rs_code_name"), "D", "", "", "", dtO);
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

        string strpath = Request[uploadfield + "_" + nRow];//存檔路徑
        Sys.RenameFile(Sys.Path2Nbtbrt(strpath + "/" + aa), Sys.Path2Nbtbrt(strpath + "/" + lname), true);

        attach_path = Sys.Path2Btbrt(strpath + "/" + lname);//存入資料庫路徑+新檔名
        attach_name = lname;//新檔名
    }

    /// <summary>
    /// 新增案件進度0
    /// </summary>
    private void Insert_stepZZ(string seq, string seq1) {
        SQL = "select count(*) cnt from step_dmt where seq='" + seq + "' and seq1='" + seq1 + "' and step_grade=0";
        objResult = conn.ExecuteScalar(SQL);
        int cnt = (objResult == DBNull.Value || objResult == null) ? 0 : Convert.ToInt32(objResult);

        if (cnt == 0) {
            //收文序號
            string zzrs_no = Sys.getRsNo(conn, "ZZ");

            //新增進度0
            SQL = "insert into step_dmt(rs_no,branch,seq,seq1,step_grade,step_date,main_rs_no,cg,rs,rs_detail) values ";
            SQL += "('" + zzrs_no + "','" + Session["sebranch"] + "'," + seq + ",'" + seq1 + "',0";
            SQL += "," + Util.dbnull(Request["dmt_in_date"]) + ",'" + zzrs_no + "','Z','Z','')";
            conn.ExecuteNonQuery(SQL);
        }
    }

    //複製到iposend
    private void iposend_attach(string seq, string seq1, string step_grade, string step_date, string rs_detail, string dbflag, string doc_flag, string attach_path, string attach_name, DataTable oDT) {
        if (ReqVal.TryGet("send_way") == "E") {
            string branch = Sys.GetSession("SeBranch");
            //第一層目錄：發文日期+發文單位，如20210220-NT
            DateTime sdate = Util.str2Dateime(step_date);
            string tfoldername = String.Format("{0}-{1}", sdate.ToString("yyyyMMdd"), branch + Sys.GetSession("dept"));
            //第二層目錄：案號+副碼+進度+案性前6碼，如NT12345-_-2-申請商標註冊
            tfoldername += "/" + String.Format("{0}-{1}-{2}-{3}"
                , branch + Sys.GetSession("dept") + seq
                , seq1
                , step_grade
                , rs_detail.ToUnicode().Left(6).Trim());
            //iposend存檔路徑
            string sendt_path = Sys.IPODir + "/" + tfoldername;

            Sys.CreateFolder(sendt_path);//電子送件目錄

            //備份舊檔案
            if (oDT.Rows.Count > 0) {
                if (oDT.Rows[0].SafeRead("doc_flag", "") == "E") {
                    Sys.CreateFolder(sendt_path);
                    Sys.CreateFolder(sendt_path + "/backup");//備份路徑

                    var sourceFile = Server.MapPath(sendt_path + "/" + oDT.Rows[0].SafeRead("source_name", ""));
                    var backupDir = Server.MapPath(sendt_path + "/backup");
                    string firstName = System.IO.Path.GetFileNameWithoutExtension(sourceFile);
                    string extName = System.IO.Path.GetExtension(sourceFile);
                    string stamp = DateTime.Now.ToString("yyyyMMddhhmmss") + "-" + Session["scode"];//備份註記(_時間-薪號)
                    if (Request["chkTest"] == "TEST") {
                        Response.Write("move..備份舊檔案..<BR>" + sourceFile + "<BR>" + backupDir + "\\" + firstName + "_" + stamp + extName + "<HR>");
                    }
                    if (System.IO.File.Exists(sourceFile)) {
                        System.IO.File.Move(sourceFile, backupDir + "\\" + firstName + "_" + stamp + extName);
                    }
                }
            }

            if ((dbflag == "A" || dbflag == "U") && doc_flag == "E") {//doc_flag=E:電子送件
                //要將檔案copy至sin07/iposend
                if (Request["chkTest"] == "TEST") {
                    Response.Write("copy..複製新檔案..<BR>" + Server.MapPath(Sys.Path2Nbtbrt(attach_path)) + "→" + Server.MapPath(sendt_path + "/" + attach_name) + "<HR>");
                }
                System.IO.File.Copy(Server.MapPath(Sys.Path2Nbtbrt(attach_path)), Server.MapPath(sendt_path + "/" + attach_name), true);
            }
        }
    }
</script>

<%Response.Write(strOut.ToString());%>
