<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>

<script runat="server">
    protected string HTProgCap = "國內案文件掃描新增作業入檔";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = HttpContext.Current.Request["prgid"] ?? "";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";

    protected string submitTask = "";
    protected string SQL = "";
    protected object objResult = null;
        
    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected Dictionary<string, string> ColMap = new Dictionary<string, string>();

    string[] arr_chkflag,arr_keyseq,arr_branch,arr_oldseq,arr_oldaseq1,arr_dmt_in_date;
    string[] arr_seq, arr_aseq1, arr_step_grade, arr_cgrs_nm, arr_scan_num;
    
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
        conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
        
        arr_chkflag = Request["rows_chkflag"].Split('\f');
        arr_keyseq = Request["rows_keyseq"].Split('\f');
        arr_branch = Request["rows_branch"].Split('\f');
        arr_oldseq = Request["rows_oldseq"].Split('\f');
        arr_oldaseq1 = Request["rows_oldaseq1"].Split('\f');
        arr_dmt_in_date = Request["rows_dmt_in_date"].Split('\f');
        arr_seq = Request["rows_seq"].Split('\f');
        arr_aseq1 = Request["rows_aseq1"].Split('\f');
        arr_step_grade = Request["rows_step_grade"].Split('\f');
        arr_cgrs_nm = Request["rows_cgrs_nm"].Split('\f');
        arr_scan_num = Request["rows_scan_num"].Split('\f');

        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        HTProgCap = myToken.Title;
        DebugStr = myToken.DebugStr;
        if (HTProgRight >= 0) {
            try {
                doUpdateDB();
                strOut.AppendLine("<div align='center'><h1>文件掃描新增成功!!!</h1></div>");
                //conn.Commit();
                conn.RollBack();
            }
            catch (Exception ex) {
                conn.RollBack();
                Sys.errorLog(ex, conn.exeSQL, prgid);
                throw;
            }
            finally {
                conn.Dispose();
            }
            this.DataBind();
        }
    }

    private void doUpdateDB() {
        for (int i = 1; i < arr_chkflag.Length; i++) {
            if (arr_chkflag[i] == "Y") {//有打勾
                //進度0檢查進度檔無資料的話先新增
                if (arr_step_grade[i] == "0") {
                    SQL = "select count(*) from step_dmt where seq='" + arr_seq[i] + "' and seq1='" + arr_aseq1[i] + "' and step_grade=0";
                    object objResult = conn.ExecuteScalar(SQL);
                    int cnt = (objResult == DBNull.Value || objResult == null) ? 0 : Convert.ToInt32(objResult);
                    if (cnt == 0) {
                        //收文序號
                        string rs_no = Sys.getRsNo(conn, "ZZ");
                        //新增進度0
                        SQL = "insert into step_dmt(rs_no,branch,seq,seq1,step_grade,step_date,main_rs_no,cg,rs,rs_detail) values (";
                        SQL += "'" + rs_no + "','" + Session["seBranch"] + "'," + arr_seq[i] + ",'" + arr_aseq1[i] + "',0,'" + DateTime.Today.ToShortDateString() + "','" + rs_no + "','Z','Z','')";
                        conn.ExecuteNonQuery(SQL);
                    }
                }

                //更換檔名
                string tseq = arr_seq[i].PadLeft(Sys.DmtSeq, '0');
                string tseq1 = "-";
                if (arr_aseq1[i] != "_") {
                    tseq1 += arr_aseq1[i];
                }

                string tstep_grade = arr_step_grade[i].PadLeft(4, '0');
                for (int j = 1; j <= Convert.ToInt32(arr_scan_num[i]); j++) {
                    SQL = "select isnull(max(attach_no),0)+1 as attach_no from dmt_attach where seq=" + arr_seq[i] + " and seq1='" + arr_aseq1[i] + "' and step_grade=" + arr_step_grade[i] + " and attach_flag<>'D'";
                    objResult = conn.ExecuteScalar(SQL);
                    string attach_no = (objResult == DBNull.Value || objResult == null) ? "1" : objResult.ToString();

                    string attach_path = "", attach_name = "";
                    Sys.formatScanPathNo(arr_seq[i], arr_aseq1[i], tstep_grade, attach_no.ToString(), ref attach_path, ref attach_name);//存在資料庫路徑
                    string newattach_path = attach_path + attach_name;
                    string source_name = attach_name;

                    SQL = "insert into dmt_attach ";
                    ColMap.Clear();
                    ColMap["Seq"] = Util.dbchar(arr_seq[i]);
                    ColMap["seq1"] = Util.dbchar(arr_aseq1[i]);
                    ColMap["step_grade"] = Util.dbchar(arr_step_grade[i]);
                    ColMap["Source"] = Util.dbchar("scan");
                    ColMap["in_date"] = "getdate()";
                    ColMap["in_scode"] = "'" + Session["scode"] + "'";
                    ColMap["Attach_no"] = Util.dbchar(attach_no.ToString());
                    ColMap["attach_path"] = Util.dbchar(Sys.Path2Btbrt(newattach_path));
                    ColMap["attach_desc"] = Util.dbchar("掃描文件");
                    ColMap["Attach_name"] = Util.dbchar(attach_name);
                    ColMap["source_name"] = Util.dbchar(source_name);
                    ColMap["attach_flag"] = Util.dbchar("A");
                    ColMap["Mark"] = Util.dbchar("");
                    ColMap["tran_date"] = "getdate()";
                    ColMap["tran_scode"] = "'" + Session["scode"] + "'";
                    ColMap["chk_status"] = Util.dbchar("NN");
                    SQL += ColMap.GetInsertSQL();
                    conn.ExecuteNonQuery(SQL);
                    //抓insert後的流水號
                    SQL = "SELECT SCOPE_IDENTITY() AS Current_Identity";
                    objResult = conn.ExecuteScalar(SQL);
                    string Getattach_sqlno = objResult.ToString();
                    Sys.showLog("掃描文件流水號=" + Getattach_sqlno);

                    //新增掃描確認流程檔
                    SQL = "insert into todo_dmt ";
                    ColMap.Clear();
                    ColMap["syscode"] = "'" + Session["syscode"] + "'";
                    ColMap["apcode"] = "'" + prgid + "'";
                    ColMap["temp_rs_sqlno"] = Util.dbnull(Getattach_sqlno);
                    ColMap["seq"] = Util.dbnull(arr_seq[i]);
                    ColMap["seq1"] = Util.dbchar(arr_aseq1[i]);
                    ColMap["step_grade"] = Util.dbzero(arr_step_grade[i]);
                    ColMap["in_date"] = "getdate()";
                    ColMap["in_scode"] = "'" + Session["scode"] + "'";
                    ColMap["dowhat"] = Util.dbchar("scan");//掃描確認,ref:cust_code.code_type='Ttodo'
                    ColMap["job_status"] = Util.dbchar("NN");
                    SQL += ColMap.GetInsertSQL();
                    conn.ExecuteNonQuery(SQL);

                    //更新進度檔有掃描文件
                    SQL = "update step_dmt set pr_scan='Y' where seq=" + arr_seq[i] + " and seq1='" + arr_aseq1[i] + "' and step_grade=" + arr_step_grade[i];
                    conn.ExecuteNonQuery(SQL);
                }
            }
        }
    }
</script>

<%Response.Write(strOut.ToString());%>
