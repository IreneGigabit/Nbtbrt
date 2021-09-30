<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>

<script runat="server">
    protected string HTProgCap = "轉案文件上傳存檔入檔";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = HttpContext.Current.Request["prgid"] ?? "";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";

    protected string SQL = "";
    protected object objResult = null;
    
    protected string submitTask = "";
    protected string tblname = "";

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
        string country = (Request["country"] ?? "").Trim();

        if (country == "") {
            tblname = "dmt_attach";
        } else {
            tblname = "attach_ext";
        }

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

            if (dbflag == "A") {
                //當上傳路徑不為空的 and attach_sqlno為空的,才需要新增
                if (ReqVal.TryGet(uploadfield + "_" + i) != "" && attach_sqlno == "") {
                    //更換檔名
                    string attach_path = "", attach_name = "";
                    //RenameFile(seq, seq1, step_grade, uploadfield, i, ref attach_path, ref attach_name);
                    attach_path = Request[uploadfield + "_" + i] + "/" + Request[uploadfield + "_name_" + i];
                    attach_name = Request[uploadfield + "_name_" + i];

                    SQL = "insert into " + tblname + " ";
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
                    ColMap["tran_date"] = "getdate()";
                    ColMap["tran_scode"] = "'" + Session["scode"] + "'";
                    ColMap["attach_branch"] = Util.dbchar(Request[uploadfield + "_branch_" + i]);
                    if (tblname == "attach_ext") {
                        ColMap["branch"] = "'" + Session["seBranch"] + "'";
                    }
                    SQL += ColMap.GetInsertSQL();
                    conn.ExecuteNonQuery(SQL);
                }
            } else if (dbflag == "U") {
                //當attach_sqlno <> empty時 , 而且上傳的路徑又是空的時候,表示要刪除該筆資料,而非修改
                if (attach_sqlno != "" && ReqVal.TryGet(uploadfield + "_" + i) == "") {
                    Sys.insert_log_table(conn, "D", prgid, tblname, "attach_sqlno", attach_sqlno, "");

                    //當attach_sqlno <> empty時,表示db有值,必須刪除data(update attach_flag = 'D')
                    SQL = "update " + tblname + " set attach_flag='D'";
                    SQL += ",tran_date=getdate(),tran_scode='" + Session["scode"] + "'";
                    SQL += " where attach_sqlno='" + attach_sqlno + "'";
                    conn.ExecuteNonQuery(SQL);
                } else {
                    Sys.insert_log_table(conn, "U", prgid, tblname, "attach_sqlno", attach_sqlno, "");

                    string old_attach_name = ReqVal.TryGet("old_" + uploadfield + "_name_" + i);//原檔案名稱
                    string attach_path = ReqVal.TryGet(uploadfield + "_" + i);
                    string attach_name = ReqVal.TryGet(uploadfield + "_name_" + i);//上傳檔名
                    string source_name = ReqVal.TryGet("source_name_" + i);

                    if (attach_name != old_attach_name) {//畫面上傳檔名與原檔案名稱不一樣，表示上傳新檔案，所以要更名
                        source_name = attach_name;
                    }

                    SQL = "update " + tblname + " set ";
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
                    ColMap["tran_date"] = "getdate()";
                    ColMap["tran_scode"] = "'" + Session["scode"] + "'";
                    SQL += ColMap.GetUpdateSQL();
                    SQL += " where attach_sqlno = '" + attach_sqlno + "'";
                    conn.ExecuteNonQuery(SQL);
                }
            } else if (dbflag == "D") {
                Sys.insert_log_table(conn, "D", prgid, tblname, "attach_sqlno", attach_sqlno, "");

                //當attach_sqlno <> empty時,表示db有值,必須刪除data(update attach_flag = 'D')
                if (attach_sqlno != "") {
                    SQL = "update " + tblname + " set attach_flag='D',tran_date=getdate(),tran_scode='" + Session["scode"] + "'";
                    SQL += " where attach_sqlno='" + attach_sqlno + "'";
                    conn.ExecuteNonQuery(SQL);
                }
            }
        }
    }
</script>

<%Response.Write(strOut.ToString());%>
