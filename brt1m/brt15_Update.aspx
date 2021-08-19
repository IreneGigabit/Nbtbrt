<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>

<script runat="server">
    protected string HTProgCap = "國內案官方收文營洽確認作業-入檔";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "brt15";//程式檔名前綴
    protected string HTProgCode = "brt15";//HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";

    protected string SQL = "";
    protected object objResult = null;

    protected string logReason = "Brt15國內案營洽官收確認作業";

    protected string submitTask = "";
    protected string seq = "";
    protected string seq1 = "";
    protected string nstep_grade = "";

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

        submitTask = (Request["submittask"] ?? "").Trim();
        seq = (Request["seq"] ?? "").Trim();
        seq1 = (Request["seq1"] ?? "").Trim();
        nstep_grade = (Request["nstep_grade"] ?? "").Trim();

        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        HTProgCap = myToken.Title;
        DebugStr = myToken.DebugStr;
        if (HTProgRight >= 0) {
            try {
                conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");

                //判斷狀態是否已異動,防止開雙視窗
                SQL = "select count(*) from todo_dmt where temp_rs_sqlno='" + Request["grconf_sqlno"] + "' and dowhat='SALES_GR' and job_status like 'N%'";
                objResult = conn.ExecuteScalar(SQL);
                int cnt = (objResult == DBNull.Value || objResult == null) ? 0 : Convert.ToInt32(objResult);
                if (cnt == 0) {
                    conn.RollBack();
                    strOut.AppendLine("<div align='center'><h1>案件狀態有誤或已確認，請重新查詢!!!案件編號:(" + Session["seBranch"] + Session["dept"] + seq + seq1 + "進度" + nstep_grade + ")</h1></div>");
                } else {
                    if (submitTask == "U") {
                        doUpdateDB();
                    }
                }
            }
            catch (Exception ex) {
                conn.RollBack();
                Sys.errorLog(ex, conn.exeSQL, prgid);
                //strOut.AppendLine("<div align='center'><h1>案件確認失敗("+ex.Message+")</h1></div>");
                throw;
            }

            this.DataBind();
        }
    }

    private void doUpdateDB() {
        //判斷是否需自行客戶報導，若需要新增上傳文件
        if (ReqVal.TryGet("cs_report") == "Y") {
            Sys sfile = new Sys();
            sfile.getFileServer(Sys.GetSession("SeBranch"), prgid);//檔案上傳相關設定
            //自行客戶報導命名規則branch+dept-seq(5)-seq1-step_grade(4)-attach_no(2).pdf
            string strpath1 = sfile.gbrWebDir + "/" + Request["attach_path"];
            string fld = ReqVal.TryGet("uploadfield");

            //本次上傳筆數
            for (int k = 1; k <= Convert.ToInt32("0" + Request[fld + "_filenum"]); k++) {
                string straa = (Request[fld + "_name_" + k] ?? "");//原始檔名

                if (straa != "") {
                    //更換檔名
                    string attach_path = "", attach_name = "";
                    RenameFile(seq, seq1, nstep_grade, fld, k, ref attach_path, ref attach_name);
                    string source_name = ReqVal.TryGet("source_name_" + k);
                    if (ReqVal.TryGet("attach_flag_" + k) == "A") {
                        source_name = ReqVal.TryGet(fld + "_name_" + k);
                    }

                    SQL = "insert into dmt_attach ";
                    ColMap.Clear();
                    ColMap["seq"] = Util.dbnull(seq);
                    ColMap["seq1"] = Util.dbchar(seq1);
                    ColMap["step_grade"] = Util.dbchar(nstep_grade);
                    ColMap["source"] = Util.dbchar("grconf_cs");
                    ColMap["in_date"] = "getdate()";
                    ColMap["in_scode"] = "'" + Session["scode"] + "'";
                    ColMap["attach_no"] = Util.dbchar(Request["attach_no_" + k]);//Util.dbchar(mattach_no);
                    ColMap["attach_path"] = Util.dbchar(attach_path);
                    ColMap["doc_type"] = Util.dbchar(Request["doc_type_" + k]);
                    ColMap["attach_desc"] = Util.dbchar(Request[fld + "_desc_" + k]);
                    ColMap["attach_name"] = Util.dbchar(attach_name);
                    ColMap["source_name"] = Util.dbchar(source_name);
                    ColMap["attach_size"] = Util.dbzero(Request[fld + "_size_" + k]);
                    ColMap["attach_flag"] = Util.dbchar(Request["attach_flag_" + k]);
                    ColMap["tran_date"] = "getdate()";
                    ColMap["tran_scode"] = "'" + Session["scode"] + "'";
                    SQL += ColMap.GetInsertSQL();
                    conn.ExecuteNonQuery(SQL);
                }
            }
        }

        //修改營洽官收確認資料	
        //2008/11/27李協理回覆不需營洽確認並指示才產生客函，程序官收確認即產生客函，所以不用更新客函資料
        Sys.insert_log_table(conn, "U", prgid, "grconf_dmt", "grconf_sqlno", Request["grconf_sqlno"], logReason);
        SQL = "update grconf_dmt set ";
        ColMap.Clear();
        ColMap["job_type"] = Util.dbnull(Request["job_type"]);
        ColMap["job_case"] = Util.dbnull(Request["job_case"]);
        ColMap["pre_date"] = Util.dbnull(Request["pre_date"]);
        ColMap["sales_remark"] = Util.dbnull(Request["sales_remark"]);
        ColMap["cs_report"] = Util.dbnull(Request["cs_report"]);
        ColMap["sales_status"] = "'YY'";
        ColMap["sconf_scode"] = "'" + Session["scode"] + "'";
        ColMap["sconf_date"] = "getdate()";
        SQL += ColMap.GetUpdateSQL();
        SQL += " where grconf_sqlno=" + Request["grconf_sqlno"];
        conn.ExecuteNonQuery(SQL);

        //修改營洽確認流程檔
        SQL = "update todo_dmt set ";
        ColMap.Clear();
        ColMap["job_status"] = Util.dbchar("YY");
        ColMap["approve_scode"] = "'" + Session["scode"] + "'";
        ColMap["resp_date"] = "getdate()";
        SQL += ColMap.GetUpdateSQL();
        SQL += " where temp_rs_sqlno=" + Request["grconf_sqlno"] + " and dowhat='SALES_GR' and job_status like 'N%'";
        conn.ExecuteNonQuery(SQL);

        conn.Commit();
        //conn.RollBack();

        string fseq = Sys.formatSeq1(seq, seq1, "", Sys.GetSession("seBranch"), Sys.GetSession("dept"));
        strOut.AppendLine("<div align='center'><h3><font color=blue>案件編號：" + fseq + "<font color=red>官方收文確認成功</font>" +
        "，官收進度：" + nstep_grade +
        (ReqVal.TryGet("cs_rs_no") != "" ? "，客發序號：" + Request["cs_rs_no"] : "") +
        "</font></h3></div>");
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
                                    , Request["attach_no_" + nRow]//4mattach_no
                                    , ar);

        string strpath = Request[uploadfield + "_" + nRow];//存檔路徑+檔名
        if (strpath.IndexOf(".") > -1) strpath = System.IO.Path.GetDirectoryName(strpath);//如果有含檔名則只取目錄
        Sys.RenameFile(Sys.Path2Nbtbrt(strpath + "/" + aa), Sys.Path2Nbtbrt(strpath + "/" + lname), true);

        attach_path = Sys.Path2Btbrt(strpath + "/" + lname);//存入資料庫路徑+新檔名
        attach_name = lname;//新檔名
    }
</script>

<%Response.Write(strOut.ToString());%>
