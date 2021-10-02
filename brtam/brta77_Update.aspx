<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Linq"%>

<script runat="server">
    protected string HTProgCap = "程序轉案完成確認(轉出)-入檔";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "brta77";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";

    protected string submitTask = "";
    protected string SQL = "";
    protected object objResult = null;

    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected Dictionary<string, string> ColMap = new Dictionary<string, string>();

    protected string logReason = "Brta77程序轉案發文確認作業";
    string[] arr_chkflag, arr_brtran_sqlno, arr_todo_sqlno, arr_seq, arr_seq1, arr_appl_name, arr_scode, arr_cust_seq, arr_cust_seq1, arr_cust_name, arr_tran_seq_branch, arr_tran_seq, arr_tran_seq1, arr_tran_remark;
             
    protected string qs_dept = "", rs_type = "", tblname = "", tdept = "", msgdept = "";

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
        arr_chkflag = ReqVal.TryGet("rows_chkflag").Split('\f');
        arr_brtran_sqlno = ReqVal.TryGet("rows_brtran_sqlno").Split('\f');
        arr_todo_sqlno = ReqVal.TryGet("rows_todo_sqlno").Split('\f');
        arr_seq = ReqVal.TryGet("rows_seq").Split('\f');
        arr_seq1 = ReqVal.TryGet("rows_seq1").Split('\f');
        arr_appl_name = ReqVal.TryGet("rows_appl_name").Split('\f');
        arr_scode = ReqVal.TryGet("rows_scode").Split('\f');
        arr_cust_seq = ReqVal.TryGet("rows_cust_seq").Split('\f');
        arr_cust_seq1 = ReqVal.TryGet("rows_cust_seq1").Split('\f');
        arr_cust_name = ReqVal.TryGet("rows_cust_name").Split('\f');
        arr_tran_seq_branch = ReqVal.TryGet("rows_tran_seq_branch").Split('\f');
        arr_tran_seq = ReqVal.TryGet("rows_tran_seq").Split('\f');
        arr_tran_seq1 = ReqVal.TryGet("rows_tran_seq1").Split('\f');
        arr_tran_remark = ReqVal.TryGet("rows_tran_remark").Split('\f');

        qs_dept = (Request["qs_dept"] ?? "").ToLower();
        if (qs_dept == "t") {
            rs_type = Sys.getRsType();
            tblname = "dmt";
            tdept = "T";
            msgdept = "國內案";
            logReason = "Brta77國內案轉案完成確認作業新單位區所編號及案件狀態修改";
        } else {
            rs_type = Sys.getRsTypeExt();
            tblname = "ext";
            tdept = "TE";
            msgdept = "出口案";
            logReason = "Exta77出口案轉案完成確認作業新單位區所編號及案件狀態修改";
        }

        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        HTProgCap = myToken.Title;
        DebugStr = myToken.DebugStr;
        if (HTProgRight >= 0) {
            try {
                conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");

                for (int i = 1; i < arr_chkflag.Length; i++) {
                    if (arr_chkflag[i] == "Y") {//有打勾
                        string tmp_sqlno = arr_todo_sqlno[i];
                        string tmp_seq = arr_seq[i];
                        string tmp_seq1 = arr_seq1[i];

                        //判斷狀態是否已異動,防止開雙視窗
                        SQL = "select count(*) from todo_" + tblname + " where sqlno='" + tmp_sqlno + "' and job_status ='NN'";

                        object objResult = conn.ExecuteScalar(SQL);
                        int cnt = (objResult == DBNull.Value || objResult == null) ? 0 : Convert.ToInt32(objResult);
                        if (cnt == 0) {
                            throw new Exception(Session["seBranch"] + "T" + tmp_seq + "-" + tmp_seq1 + "程序轉案發文處理失敗(狀態已異動，請重新整理畫面)");
                        } else {
                            insert_step_dmt(i);
                            update_todo_dmt(i);
                        }
                    }
                }

                strOut.AppendLine("<div align='center'><h1>" + msgdept + "轉案完成確認成功</h1></div>");
                conn.Commit();
                //conn.RollBack();
            }
            catch (Exception ex) {
                conn.RollBack();
                Sys.errorLog(ex, conn.exeSQL, prgid);
                //strOut.AppendLine("<div align='center'><h1>資料更新失敗("+ex.Message+")</h1></div>");
                throw;
            }
            finally {
                conn.Dispose();
            }
            this.DataBind();
        }
    }
    
    /// <summary>
    /// 新增本收進度-結案
    /// </summary>
    private void insert_step_dmt(int pno) {
        string tmp_seq = arr_seq[pno];
        string tmp_seq1 = arr_seq1[pno];
        string tran_seq_branch = arr_tran_seq_branch[pno];
        string tran_seq = arr_tran_seq[pno];
        string tran_seq1 = arr_tran_seq1[pno];

        string lstep_grade = "1";

        //取得案件進度
        SQL = "select step_grade from " + tblname + " where seq= '" + tmp_seq + "' and seq1 = '" + tmp_seq1 + "'";
        objResult = conn.ExecuteScalar(SQL);
        lstep_grade = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();
        if (lstep_grade == "") {
            lstep_grade = "1";
            throw new Exception("案件" + tdept + tmp_seq + "-" + tmp_seq1 + "進度有問題, 請洽系統維護人員!!");
        } else {
            lstep_grade = (Convert.ToInt32(lstep_grade) + 1).ToString();
            SQL = "select step_grade from step_" + tblname + " where seq= '" + tmp_seq + "' and seq1 = '" + tmp_seq1 + "' and step_grade = " + lstep_grade;
            objResult = conn.ExecuteScalar(SQL);
            if (objResult != DBNull.Value && objResult != null) {
                throw new Exception("案件" + tdept + tmp_seq + "-" + tmp_seq1 + "進度有問題, 請洽系統維護人員!!");
            }
        }

        //取得收文序號
        string main_rs_no = "", rs_no = "";

        //取得收文序號
        if (tdept == "T") {
            rs_no = Sys.getRsNo(conn, "ZR");
            main_rs_no = rs_no;
        } else if (tdept == "TE") {
            rs_no = Sys.getERsNo(conn, "ZR", "國內所本所收文");
            main_rs_no = rs_no;
        }

        if (rs_no == "") {
            throw new Exception("取得發文序號發生錯誤, 請通知系統人員！");
        }

        //入進度檔step_dmt	
        SQL = "insert into step_" + tblname + "(rs_no,branch,seq,seq1,step_grade,main_rs_no,step_date,cg,rs";
        SQL += ",rs_type,rs_class,rs_code,act_code,rs_detail,pr_status,new,tran_date,tran_scode)";
        SQL += " values('" + rs_no + "','" + Session["seBranch"] + "'," + tmp_seq + ",'" + tmp_seq1 + "'";
        SQL += "," + lstep_grade + ",'" + main_rs_no + "','" + DateTime.Today.ToShortDateString() + "','Z','R','" + rs_type + "'";
        if (tdept == "T") {
            SQL += ",'X1','XZ1','_','結案'";
        } else if (tdept == "TE") {
            SQL += ",'X1','EX1','_','結案'";
        }
        SQL += ",'X','X',getdate(),'" + Session["scode"] + "')";
        conn.ExecuteNonQuery(SQL);

        //抓insert後的流水號
        SQL = "SELECT SCOPE_IDENTITY() AS Current_Identity";
        object objResult1 = conn.ExecuteScalar(SQL);
        string lGetrs_sqlno = objResult1.ToString();

        //管制期限B6
        ColMap.Clear();
        string ctrl_date = "";
        if (tdept == "T") {
            ctrl_date = DateTime.Today.AddMonths(1).ToShortDateString();
            SQL = "insert into ctrl_dmt ";
            ColMap["rs_no"] = Util.dbchar(rs_no);
        } else if (tdept == "TE") {
            ctrl_date = DateTime.Today.AddMonths(6).ToShortDateString();
            SQL = "insert into ctrl_ext ";
            ColMap["rs_sqlno"] = Util.dbchar(lGetrs_sqlno);
        }
        ColMap["branch"] = Util.dbchar(Sys.GetSession("seBranch"));
        ColMap["seq"] = Util.dbnull(tmp_seq);
        ColMap["seq1"] = Util.dbchar(tmp_seq1);
        ColMap["step_grade"] = Util.dbnull(lstep_grade);
        ColMap["ctrl_type"] = Util.dbchar("B6");//結案期限
        ColMap["ctrl_remark"] = Util.dbchar("結案處理期限");
        ColMap["ctrl_date"] = Util.dbchar(ctrl_date);
        ColMap["tran_date"] = "getdate()";
        ColMap["tran_scode"] = "'" + Session["scode"] + "'";
        SQL += ColMap.GetInsertSQL();
        conn.ExecuteNonQuery(SQL);

        //入結案處理流程todo_dmt
        insert_todo_dmt(pno, lstep_grade, lGetrs_sqlno);

        //更新案件主檔-新單位區所編號
        //新增案件主檔Log檔
        Sys.insert_log_table(conn, "U", prgid, tblname, "seq;seq1", tmp_seq + ";" + tmp_seq1, logReason);

        //更新案件主檔
        SQL = "update " + tblname + " set tran_flag='A'";
        SQL += " ,tran_seq_branch='" + tran_seq_branch + "'";
        SQL += " ,tran_seq = " + tran_seq;
        SQL += " ,tran_seq1 = '" + tran_seq1 + "' ";
        SQL += " ,now_arcase_type='" + rs_type + "'";
        SQL += " ,now_grade=" + lstep_grade;
        SQL += " ,step_grade=" + lstep_grade;
        if (tdept == "T") {
            SQL += ",now_arcase_class='X1'";
            SQL += ",now_arcase='XZ1'";
            SQL += ",now_act_code='_'";
            SQL += ",now_stat='XZ1'";
        } else if (tdept == "TE") {
            SQL += ",now_arcase_class='X1'";
            SQL += ",now_arcase='EX1'";
            SQL += ",now_act_code='_'";
            SQL += ",now_stat='EX1'";
        }
        SQL += " where seq=" + tmp_seq + " and seq1='" + tmp_seq1 + "'";
        conn.ExecuteNonQuery(SQL);
    }
    
    /// <summary>
    /// 新增程序結案處理todo_dmt
    /// </summary>
    private void insert_todo_dmt(int pno, string pstep_grade, string prs_sqlno) {
        string tmp_sqlno = arr_todo_sqlno[pno];
        string tmp_seq = arr_seq[pno];
        string tmp_seq1 = arr_seq1[pno];

        string job_team = "";
        if (tdept == "T") {
            job_team = "T210";
        } else if (tdept == "TE") {
            job_team = "T220";
        }

        string job_scode = Sys.getCodeName(conn, "sysctrl.dbo.scode_group", "scode", "where grpclass='" + Session["seBranch"] + "' and grpid='" + job_team + "' and grptype='F'");

        SQL = "insert into todo_" + tblname + " ";
        ColMap.Clear();
        ColMap["pre_sqlno"] = Util.dbnull(tmp_sqlno);
        ColMap["syscode"] = "'" + Session["syscode"] + "'";
        ColMap["apcode"] = "'" + HTProgCode + "'";
        ColMap["from_flag"] = Util.dbchar("END");
        ColMap["branch"] = "'" + Session["seBranch"] + "'";
        ColMap["seq"] = Util.dbnull(tmp_seq);
        ColMap["seq1"] = Util.dbchar(tmp_seq1);
        ColMap["step_grade"] = Util.dbnull(pstep_grade);
        ColMap["in_scode"] = "'" + Session["scode"] + "'";
        ColMap["in_date"] = "getdate()";
        if (tdept == "TE") {
            ColMap["rs_sqlno"] = Util.dbnull(prs_sqlno);
        }
        ColMap["dowhat"] = Util.dbchar("DC_END1");//程序結案處理
        ColMap["job_scode"] = Util.dbchar(job_scode);
        ColMap["job_team"] = Util.dbchar(job_team);
        ColMap["job_status"] = Util.dbchar("NN");
        SQL += ColMap.GetInsertSQL();
        conn.ExecuteNonQuery(SQL);
    }
    
    /// <summary>
    /// 更新程序轉案發文確認處理狀態
    /// </summary>
    private void update_todo_dmt(int pno) {
        string tmp_sqlno = arr_todo_sqlno[pno];
        string tmp_seq = arr_seq[pno];
        string tmp_seq1 = arr_seq1[pno];

        //更新程序轉案發文確認處理狀態
        SQL = "update todo_" + tblname + " set job_status = 'YY' ";
        SQL += " ,approve_scode = '" + Session["scode"] + "' ";
        SQL += " ,resp_date=getdate() ";
        SQL += " where sqlno = " + tmp_sqlno;
        conn.ExecuteNonQuery(SQL);
    }
</script>

<%Response.Write(strOut.ToString());%>
