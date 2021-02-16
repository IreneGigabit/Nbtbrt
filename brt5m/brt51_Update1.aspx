<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>

<script runat="server">
    protected string HTProgCap = "程序確認作業-客收";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "brt51";//程式檔名前綴
    protected string HTProgCode = "Brt51";//HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";

    protected string submitTask = "";
    protected string SQL = "";
    protected object objResult = "";

    protected string logReason = "Brt51國內案客收確認作業";
    protected string wheresqlA = "";
    protected string main_rs_no = "",msgseq="";

    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected Dictionary<string, string> ColMap = new Dictionary<string, string>();

    protected StringBuilder strOut = new StringBuilder();

    DBHelper conn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    DBHelper connm = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    private void Page_Unload(System.Object sender, System.EventArgs e) {
        if (conn != null) conn.Dispose();
        if (connm != null) conn.Dispose();
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

                //判斷狀態是否已異動,防止開雙視窗
                SQL = "select count(*) from case_dmt where in_scode='" + in_scode + "' and in_no='" + in_no + "' and stat_code='YY'";
                objResult = conn.ExecuteScalar(SQL);
                int cnt = (objResult == DBNull.Value || objResult == null) ? 0 : Convert.ToInt32(objResult);
                if (cnt == 0) {
                    conn.RollBack();
                    connm.RollBack();
                    strOut.AppendLine("<div align='center'><h1>本筆交辦(接洽序號：" + in_no + ")案件狀態有誤或已確認，請重新查詢！</h1></div>");
                } else {
                    doUpdateDB();
                }
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

    private void doUpdateDB() {
        bool nLcase = false;//新案處理

        string Msqlno = ReqVal.TryGet("code");
        string Mscode = ReqVal.TryGet("in_scode");
        string Min_no = ReqVal.TryGet("in_no");
        string Mcust_area = ReqVal.TryGet("cust_area");
        string Mcust_seq = ReqVal.TryGet("cust_seq");
        //母案結案2006/5/26 柳月
        string endflag51 = ReqVal.TryGet("endflag51");
        string end_date51 = ReqVal.TryGet("end_date51");
        string end_code51 = ReqVal.TryGet("end_code51");
        string end_type51 = ReqVal.TryGet("end_type51");
        string end_remark51 = ReqVal.TryGet("end_remark51");
        //結案處理狀態2010/6/9
        string end_stat = ReqVal.TryGet("end_stat");
        string seqend_flag = ReqVal.TryGet("seqend_flag");

        DataTable dt = new DataTable();
        SQL = "SELECT '1' as sort, a.arcase_type, a.arcase as arcase,a.case_stat as case_stat,a.seq,a.seq1,b.nstat as new_stat,b.ostat as old_stat,seq as Cseq,seq1 as Cseq1,0 as case_sqlno,a.ar_mark,a.case_no,a.acc_chk,a.contract_flag,a.contract_remark ";
        SQL += " from case_dmt as a inner join code_br as b on a.arcase_type = b.rs_type and a.arcase = b.rs_code ";
        SQL += " WHERE a.in_no = '" + Min_no + "' and  b.dept = 'T' and b.cr='Y' and b.no_code = 'N' ";
        SQL += " union ";
        SQL += " SELECT '2' as sort, '' as arcase_type, '' as arcase,case_stat1 as case_stat,seq,seq1,'' as new_stat,'' as old_stat,cseq,cseq1,case_sqlno,'' as ar_mark,'' as case_no,'' as acc_chk,'' as contract_flag,'' as contract_remark ";
        SQL += " from case_dmt1 ";
        SQL += " where in_no = '" + Min_no + "' ";
        SQL += "order by sort";
        conn.DataTable(SQL, dt);

        string arcase_type = dt.Rows[0].SafeRead("arcase_type", "");
        string arcase = dt.Rows[0].SafeRead("arcase", "");
        string case_stat = dt.Rows[0].SafeRead("case_stat", "");//N*代表新案件,O*代表舊案,簽核過為*U	
        string seq = dt.Rows[0].SafeRead("seq", "");
        string seq1 = dt.Rows[0].SafeRead("seq1", "");
        string cseq = dt.Rows[0].SafeRead("Cseq", "");
        string cseq1 = dt.Rows[0].SafeRead("Cseq1", "");
        string new_stat = dt.Rows[0].SafeRead("new_stat", "");//該案性新案更新狀態
        string old_stat = dt.Rows[0].SafeRead("old_stat", "");//該案性舊案更新狀態
        string ar_mark = dt.Rows[0].SafeRead("ar_mark", "");
        string case_no = dt.Rows[0].SafeRead("case_no", "");
        string acc_chk = dt.Rows[0].SafeRead("acc_chk", "");//會計契約書檢核註記,2016/1/14修改，因契約書後補一併修改為todo處理
        string contract_flag = dt.Rows[0].SafeRead("contract_flag", "");//契約書後補
        string contract_remark = dt.Rows[0].SafeRead("contract_remark", ""); //契約書後補說明

        if (case_stat.Left(1) == "N") {
            if (case_stat == "NN") {//新案,取案號並+1
                SQL = "select sql+1 as seq from cust_code where code_type='Z' and cust_code='" + Session["seBranch"] + "T" + seq1 + "'";
                objResult = conn.ExecuteScalar(SQL);
                seq = (objResult == DBNull.Value || objResult == null) ? "1" : objResult.ToString();
                nLcase = true;
                SQL = " update cust_code set sql=sql+1 where code_type='Z' and cust_code='" + Session["seBranch"] + "T" + seq1 + "'";
                conn.ExecuteNonQuery(SQL);
            } else if (case_stat == "NA") { //舊案變更申請人後會產生一筆新的案件
                seq1 = getSeq1(seq);
                nLcase = true;
            }
        }

        //修改todo狀態
        SQL = "update ToDo_dmt set ";
        ColMap.Clear();
        ColMap["job_status"] = Util.dbchar("YZ");
        ColMap["seq"] = Util.dbnull(seq);
        ColMap["seq1"] = Util.dbchar(seq1);
        ColMap["step_grade"] = Util.dbzero(ReqVal.TryGet("nstep_grade"));
        ColMap["resp_date"] = "getdate()";
        ColMap["approve_scode"] = "'" + Session["scode"] + "'";
        SQL += ColMap.GetUpdateSQL();
        SQL += " where sqlno='" + Msqlno + "'";
        conn.ExecuteNonQuery(SQL);

        //****搬移檔案
        string draw = movefile(Mscode, Min_no, seq, seq1, Mcust_area, dt.Rows[0].SafeRead("case_sqlno", ""));

        //****新案處理
        wheresqlA = " in_scode = '" + Mscode + "' and in_no = '" + Min_no + "'";
        if (nLcase) {
            //更新dmt_temp案件編號
            SQL = "update dmt_temp set seq =" + seq + ",seq1='" + seq1 + "' where " + wheresqlA;
            conn.ExecuteNonQuery(SQL);

            //更新case_dmt案件編號
            if (ReqVal.TryGet("send_way") != ReqVal.TryGet("old_send_way")) {//20160923 有修改發文方式寫入log
                Sys.insert_log_table(conn, "U", HTProgCode, "case_dmt", "in_scode;in_no", Request["in_scode"] + ";" + Request["in_no"], logReason);
            }
            SQL = "update case_dmt set seq =" + seq + ",seq1='" + seq1 + "'";
            SQL += ",send_way=" + Util.dbchar(ReqVal.TryGet("send_way")) + ", stat_code = 'YZ',case_stat = 'NU' where " + wheresqlA;
            conn.ExecuteNonQuery(SQL);

            //更新dmt_tran案件編號
            SQL = "update dmt_tran set seq =" + seq + ",seq1='" + seq1 + "' where " + wheresqlA;
            conn.ExecuteNonQuery(SQL);

            //更新caseitem_dmt案件編號
            SQL = "update caseitem_dmt set seq =" + seq + ",seq1='" + seq1 + "' where " + wheresqlA;
            conn.ExecuteNonQuery(SQL);

            //2008/11/27增加更新dmt_attach案件編號及進度,2011/2/22因客收確認新增上傳不會寫入，增加交辦單號case_no
            SQL = "update dmt_attach set seq=" + seq + ",seq1='" + seq1 + "',step_grade=1,case_no='" + case_no + "',tran_date=getdate(),tran_scode='" + Session["scode"] + "' where in_no='" + Min_no + "'";
            conn.ExecuteNonQuery(SQL);

            Insert_dmt(seq, seq1, cseq, cseq1, Mscode, Min_no, "1", dt.Rows[0].SafeRead("case_sqlno", ""), "I");
            Insert_ndmt(seq, seq1, dt.Rows[0].SafeRead("case_sqlno", ""));
            //2012/8/27因新申請案新增展覽會優先權
            Insert_dmt_show(seq, seq1, Min_no, dt.Rows[0].SafeRead("case_sqlno", ""));

            //客收 & 管制 入檔
            Insert_Step(seq, seq1, Mscode, Min_no, "1", "N");
        } else {
            if (case_stat == "SN") {//新案指定編號
                                    //更新 case_dmt 狀態
                SQL = "update case_dmt set stat_code = 'YZ',case_stat = 'SU' where " + wheresqlA;
                conn.ExecuteNonQuery(SQL);
                //2008/11/27增加更新dmt_attach進度,2011/2/22因客收確認新增上傳不會寫入，增加交辦單號case_no
                SQL = "update dmt_attach set seq=" + seq + ",seq1='" + seq1 + "',step_grade=1,case_no='" + case_no + "',tran_date=getdate(),tran_scode='" + Session["scode"] + "' where in_no='" + Min_no + "'";
                conn.ExecuteNonQuery(SQL);

                Insert_dmt(seq, seq1, cseq, cseq1, Mscode, Min_no, "1", dt.Rows[0].SafeRead("case_sqlno", ""), "I");
                Insert_ndmt(seq, seq1, dt.Rows[0].SafeRead("case_sqlno", ""));
                //2012/8/27因新申請案新增展覽會優先權
                Insert_dmt_show(seq, seq1, Min_no, dt.Rows[0].SafeRead("case_sqlno", ""));

                //客收 & 管制 入檔
                Insert_Step(seq, seq1, Mscode, Min_no, "1", "N");
            } else {//後續案
                    //更新 case_dmt 狀態
                SQL = "update case_dmt set stat_code = 'YZ',case_stat = 'OU' where " + wheresqlA;
                conn.ExecuteNonQuery(SQL);
                //2008/11/27增加更新dmt_attach進度,2011/2/22因客收確認新增上傳不會寫入，增加交辦單號case_no
                SQL = "update dmt_attach set seq=" + seq + ",seq1='" + seq1 + "',step_grade=" + Request["nstep_grade"] + ",case_no='" + case_no + "',tran_date=getdate(),tran_scode='" + Session["scode"] + "' where in_no='" + Min_no + "'";
                conn.ExecuteNonQuery(SQL);

                //更新 dmt & ndmt
                if (old_stat.Left(1) == "Y") {
                    Update_dmt(seq, seq1, Mscode, Min_no, Request["nstep_grade"]);
                } else {
                    Update_dmt1(seq, seq1, Mscode, Min_no, Request["nstep_grade"]);
                }
                //客收 & 管制 入檔
                Insert_Step(seq, seq1, Mscode, Min_no, Request["nstep_grade"], "Y");

                //結案處理todo_dmt入檔,2011/4/20因南商ST33818未結案卻有入todo但無ctrl_dmt增加判斷結案註記
                if (end_stat == "B61" && seqend_flag == "Y") {
                    insert_todo_dmt("ACC_END", seq, seq1, Request["nstep_grade"], Mscode, Min_no, case_no, Msqlno);
                }
                if (end_stat == "B6" && seqend_flag == "Y") {
                    insert_todo_dmt("DC_END1", seq, seq1, Request["nstep_grade"], Mscode, Min_no, case_no, Msqlno);
                }
            }
        }

        //新增案件商品檔
        Insert_Good(seq, seq1, dt.Rows[0].SafeRead("case_sqlno", ""));

        //更新 custz dmt_date
        SQL = "Update custz set dmt_date = '" + DateTime.Today.ToShortDateString() + "' ";
        SQL += " where cust_area = '" + Request["cust_area"] + "' ";
        SQL += "and cust_seq = '" + Request["cust_seq"] + "'";
        conn.ExecuteNonQuery(SQL);

        //扣收入案件不需開立請款單，直接寫入帳款系統之扣收入檔，預計2008/1/1上線
        if (ar_mark == "D") {
            Insert_markd(Mscode, Min_no);

            //2011/1/3依2010/12/24李協理Email修改扣收入案件仍至承辦交辦發文
            string nGrpID = Sys.getCodeName(conn, "sysctrl.dbo.scode_group", "grpid", "where grpclass='" + Session["seBranch"] + "' and scode='" + Mscode + "'");
            string job_team = Sys.getCodeName(conn, "sysctrl.dbo.scode_group", "grpid", "where grpclass='" + Session["seBranch"] + "' and scode='" + Request["pr_scode"] + "'");

            SQL = "insert into todo_dmt ";
            ColMap.Clear();
            ColMap["pre_sqlno"] = Util.dbnull(Msqlno);
            ColMap["branch"] = "'" + Session["seBranch"] + "'";
            ColMap["syscode"] = "'" + Session["syscode"] + "'";
            ColMap["apcode"] = "'" + HTProgCode + "'";
            ColMap["seq"] = Util.dbnull(seq);
            ColMap["seq1"] = Util.dbchar(seq1);
            ColMap["step_grade"] = Util.dbnull(Request["nstep_grade"]);
            ColMap["in_team"] = Util.dbchar(nGrpID);
            ColMap["case_in_scode"] = Util.dbchar(Mscode);
            ColMap["in_no"] = Util.dbchar(Min_no);
            ColMap["case_no"] = Util.dbchar(case_no);
            ColMap["from_flag"] = Util.dbchar("CGRS");
            ColMap["in_scode"] = "'" + Session["scode"] + "'";
            ColMap["in_date"] = "getdate()";
            ColMap["dowhat"] = Util.dbchar("DP_GS");
            ColMap["job_scode"] = Util.dbchar(Request["pr_scode"]);
            ColMap["job_team"] = Util.dbchar(job_team);
            ColMap["job_status"] = Util.dbchar("NN");
            SQL += ColMap.GetInsertSQL();
            conn.ExecuteNonQuery(SQL);
        } else {
            string nGrpID = Sys.getCodeName(conn, "sysctrl.dbo.scode_group", "grpid", "where grpclass='" + Session["seBranch"] + "' and scode='" + Mscode + "'");
            //2016/1/14因總契約書，增加契約書後補todo及管制期限或會計契約書檢核
            if (contract_flag == "Y") {//需契約書後補
                                       //新增管制期限
                string ctrl_date = DateTime.Today.AddMonths(1).ToShortDateString();
                SQL = "insert into ctrl_dmt(rs_no,branch,seq,seq1,step_grade,ctrl_type,ctrl_remark,ctrl_date,tran_date,tran_scode)";
                SQL += " values('" + main_rs_no + "','" + Session["sebranch"] + "'," + seq + ",'" + seq1 + "'";
                SQL += "," + Request["nstep_grade"] + ",'B9'," + Util.dbchar(contract_remark) + "";
                SQL += ",'" + ctrl_date + "',getdate(),'" + Session["scode"] + "')";
                conn.ExecuteNonQuery(SQL);

                //新增契約書後補todo
                SQL = "insert into todo_dmt ";
                ColMap.Clear();
                ColMap["pre_sqlno"] = Util.dbnull(Msqlno);
                ColMap["branch"] = "'" + Session["seBranch"] + "'";
                ColMap["syscode"] = "'" + Session["syscode"] + "'";
                ColMap["apcode"] = "'" + HTProgCode + "'";
                ColMap["seq"] = Util.dbnull(seq);
                ColMap["seq1"] = Util.dbchar(seq1);
                ColMap["step_grade"] = Util.dbnull(Request["nstep_grade"]);
                ColMap["in_team"] = Util.dbchar(nGrpID);
                ColMap["case_in_scode"] = Util.dbchar(Mscode);
                ColMap["in_no"] = Util.dbchar(Min_no);
                ColMap["case_no"] = Util.dbchar(case_no);
                ColMap["from_flag"] = Util.dbchar("CASE");
                ColMap["in_scode"] = "'" + Session["scode"] + "'";
                ColMap["in_date"] = "getdate()";
                ColMap["dowhat"] = Util.dbchar("contractL");
                ColMap["job_scode"] = Util.dbchar(Mscode);
                ColMap["job_team"] = Util.dbchar(nGrpID);
                ColMap["job_status"] = Util.dbchar("NN");
                SQL += ColMap.GetInsertSQL();
                conn.ExecuteNonQuery(SQL);
            } else {
                if (acc_chk == "N") {//需會計檢核
                                     //抓取會計
                    string acc_scode = Sys.getCodeName(conn, "sysctrl.dbo.scode_roles", "scode", "where branch='" + Session["seBranch"] + "' and dept='T' and syscode='" + Session["syscode"] + "' and sort='01' and roles='account'");

                    SQL = "insert into todo_dmt ";
                    ColMap.Clear();
                    ColMap["pre_sqlno"] = Util.dbnull(Msqlno);
                    ColMap["branch"] = "'" + Session["seBranch"] + "'";
                    ColMap["syscode"] = "'" + Session["syscode"] + "'";
                    ColMap["apcode"] = "'" + HTProgCode + "'";
                    ColMap["seq"] = Util.dbnull(seq);
                    ColMap["seq1"] = Util.dbchar(seq1);
                    ColMap["step_grade"] = Util.dbnull(Request["nstep_grade"]);
                    ColMap["in_team"] = Util.dbchar(nGrpID);
                    ColMap["case_in_scode"] = Util.dbchar(Mscode);
                    ColMap["in_no"] = Util.dbchar(Min_no);
                    ColMap["case_no"] = Util.dbchar(case_no);
                    ColMap["from_flag"] = Util.dbchar("CASE");
                    ColMap["in_scode"] = "'" + Session["scode"] + "'";
                    ColMap["in_date"] = "getdate()";
                    ColMap["dowhat"] = Util.dbchar("contractA");
                    ColMap["job_scode"] = Util.dbchar(acc_scode);
                    ColMap["job_team"] = Util.dbchar("");
                    ColMap["job_status"] = Util.dbchar("NN");
                    SQL += ColMap.GetInsertSQL();
                    conn.ExecuteNonQuery(SQL);
                }
            }

            //****2009/3/6新增承辦交辦發文todolist apcode=brt51
            string job_team = Sys.getCodeName(conn, "sysctrl.dbo.scode_group", "grpid", "where grpclass='" + Session["seBranch"] + "' and scode='" + Request["pr_scode"] + "'");
            SQL = "insert into todo_dmt ";
            ColMap.Clear();
            ColMap["pre_sqlno"] = Util.dbnull(Msqlno);
            ColMap["branch"] = "'" + Session["seBranch"] + "'";
            ColMap["syscode"] = "'" + Session["syscode"] + "'";
            ColMap["apcode"] = "'" + HTProgCode + "'";
            ColMap["seq"] = Util.dbnull(seq);
            ColMap["seq1"] = Util.dbchar(seq1);
            ColMap["step_grade"] = Util.dbnull(Request["nstep_grade"]);
            ColMap["in_team"] = Util.dbchar(nGrpID);
            ColMap["case_in_scode"] = Util.dbchar(Mscode);
            ColMap["in_no"] = Util.dbchar(Min_no);
            ColMap["case_no"] = Util.dbchar(case_no);
            ColMap["from_flag"] = Util.dbchar("CGRS");
            ColMap["in_scode"] = "'" + Session["scode"] + "'";
            ColMap["in_date"] = "getdate()";
            ColMap["dowhat"] = Util.dbchar("DP_GS");
            ColMap["job_scode"] = Util.dbchar(Request["pr_scode"]);
            ColMap["job_team"] = Util.dbchar(job_team);
            ColMap["job_status"] = Util.dbchar("NN");
            SQL += ColMap.GetInsertSQL();
            conn.ExecuteNonQuery(SQL);
        }

        //一案多件子本所編號入檔
        if (arcase.Left(2) == "FD") {
            //分割案之母案編號 所以交辦的 CSeq CSeq1 有可能會是空值
            cseq = seq;
            cseq1 = seq1;
        }

        //從1開始,0是母案
        for (int n = 1; n < dt.Rows.Count; n++) {
            string lstep_grade = "1";
            //後來結論是變更申請人也不產生新案 所以都不會有 NA 的狀況了!!!)
            if (arcase.IN("FC11,FC21,FC5,FC6,FC7,FC8,FCH,FCI,FT2,FL5,FL6")) {
                seq = dt.Rows[n].SafeRead("seq", "");
                cseq = dt.Rows[n].SafeRead("cseq", "");
                cseq1 = dt.Rows[n].SafeRead("cseq1", "");

                if (dt.Rows[n].SafeRead("case_stat", "") == "NA") {//舊案變更申請人後會產生一筆新的案件
                    seq1 = getSeq1(seq);

                    //更新case_dmt案件編號
                    SQL = "update case_dmt1 set seq =" + seq + ",seq1='" + seq1 + "'where in_no = '" + Min_no + "'";
                    SQL += " and cseq = " + cseq + " and cseq1 = '" + cseq1 + "'";
                    conn.ExecuteNonQuery(SQL);

                    lstep_grade = "1";
                    Insert_dmt2(seq, seq1, cseq, cseq1, Mscode, Min_no, lstep_grade);
                    Insert_ndmt2(seq, seq1, cseq, cseq1, Mscode, Min_no);

                } else if (dt.Rows[n].SafeRead("case_stat", "") == "OO") {
                    //更新 dmt & ndmt
                    seq1 = dt.Rows[n].SafeRead("seq1", "");

                    //取得案件進度
                    SQL = "select step_grade from dmt where seq= '" + seq + "' and seq1 = '" + seq1 + "'";
                    objResult = conn.ExecuteScalar(SQL);
                    lstep_grade = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();
                    if (lstep_grade == "") {
                        lstep_grade = "1";
                        throw new Exception("案件進度有問題, 請洽系統維護人員!!");
                    } else {
                        lstep_grade = (Convert.ToInt32(lstep_grade) + 1).ToString();
                        SQL = "select step_grade from dmt where seq= '" + seq + "' and seq1 = '" + seq1 + "' and step_grade = " + lstep_grade;
                        objResult = conn.ExecuteScalar(SQL);
                        if (objResult != DBNull.Value && objResult != null) {
                            throw new Exception("案件進度有問題, 請洽系統維護人員!!");
                        }
                    }
                    Update_dmt2(seq, seq1, Mscode, Min_no, lstep_grade);

                } else if (dt.Rows[n].SafeRead("case_stat", "") == "NN") {
                    //取案號並+1
                    SQL = "select sql+1 as seq from cust_code where code_type='Z' and cust_code='" + Session["seBranch"] + "T" + seq1 + "'";
                    objResult = conn.ExecuteScalar(SQL);
                    seq = (objResult == DBNull.Value || objResult == null) ? "1" : objResult.ToString();

                    SQL = " update cust_code set sql=sql+1 where code_type='Z' and cust_code='" + Session["seBranch"] + "T" + seq1 + "'";
                    conn.ExecuteNonQuery(SQL);

                    seq1 = dt.Rows[n].SafeRead("seq1", "");

                    //****搬移檔案
                    draw = movefile(Mscode, Min_no, seq, seq1, Mcust_area, dt.Rows[n].SafeRead("case_sqlno", ""));

                    //更新case_dmt案件編號
                    SQL = "update case_dmt1 set seq =" + seq + ",seq1='" + seq1 + "' where in_no = '" + Min_no + "'";
                    SQL += " and case_sqlno = '" + dt.Rows[n].SafeRead("case_sqlno", "") + "'";
                    conn.ExecuteNonQuery(SQL);

                    //更新dmt_temp案件編號
                    SQL = "update dmt_temp set seq =" + seq + ",seq1='" + seq1 + "' where in_no = '" + Min_no + "'";
                    SQL += " and case_sqlno = '" + dt.Rows[n].SafeRead("case_sqlno", "") + "'";
                    conn.ExecuteNonQuery(SQL);

                    lstep_grade = "1";
                    if (arcase == "FT2") {
                        Insert_dmt(seq, seq1, cseq, cseq1, Mscode, Min_no, lstep_grade, dt.Rows[n].SafeRead("case_sqlno", ""), "IN");
                    } else {
                        Insert_dmt(seq, seq1, cseq, cseq1, Mscode, Min_no, lstep_grade, dt.Rows[n].SafeRead("case_sqlno", ""), "N");
                    }
                    Insert_ndmt(seq, seq1, dt.Rows[n].SafeRead("case_sqlno", ""));

                    //新增案件商品檔
                    Insert_Good(seq, seq1, dt.Rows[n].SafeRead("case_sqlno", ""));

                    //新增案件展覽優先權檔
                    Insert_dmt_show(seq, seq1, Min_no, dt.Rows[n].SafeRead("case_sqlno", ""));
                }
            }

            //分割案可能是 NN(新案) 或 OO(舊案) 但分割子案入檔均相同
            if (arcase.Left(2) == "FD") {
                seq1 = getSeq1(seq);
                Response.Write(seq1+"<HR>");

                //更新case_dmt案件編號
                SQL = "update case_dmt1 set seq =" + seq + ",seq1='" + seq1 + "' where in_no = '" + Min_no + "'";
                SQL += " and case_sqlno = '" + dt.Rows[n].SafeRead("case_sqlno", "") + "'";
                conn.ExecuteNonQuery(SQL);

                //更新dmt_temp案件編號
                SQL = "update dmt_temp set seq =" + seq + ",seq1='" + seq1 + "' where in_no = '" + Min_no + "'";
                SQL += " and case_sqlno = '" + dt.Rows[n].SafeRead("case_sqlno", "") + "'";
                conn.ExecuteNonQuery(SQL);

                lstep_grade = "1";
                Insert_dmt(seq, seq1, cseq, cseq1, Mscode, Min_no, lstep_grade, dt.Rows[n].SafeRead("case_sqlno", ""), "N");
                Insert_ndmt(seq, seq1, dt.Rows[n].SafeRead("case_sqlno", ""));

                //新增案件商品檔
                Insert_Good(seq, seq1, dt.Rows[n].SafeRead("case_sqlno", ""));

                //新增案件展覽優先權檔
                Insert_dmt_show(seq, seq1, Min_no, dt.Rows[n].SafeRead("case_sqlno", ""));

                //更改圖檔路徑
                if (draw != "") {
                    SQL = "update ndmt set draw_file='" + draw + "'";
                    SQL += " where seq = " + seq + " and seq1 = '" + seq1 + "' ";
                    conn.ExecuteNonQuery(SQL);

                    SQL = "update dmt_temp set draw_file='" + draw + "' ";
                    SQL += " where in_no = '" + Min_no + "' and case_sqlno =" + dt.Rows[n].SafeRead("case_sqlno", "");
                    conn.ExecuteNonQuery(SQL);
                }
            }

            //客收 & 管制 入檔
            if (lstep_grade == "1") {
                Insert_Step(seq, seq1, Mscode, Min_no, lstep_grade, "N");
            } else {
                Insert_Step(seq, seq1, Mscode, Min_no, lstep_grade, "Y");
            }
        }

        //conn.Commit();
        conn.RollBack();

        strOut.AppendLine("<div align='center'><h1>客戶收文入檔成功！本所編號:" + msgseq.Substring(1) + "，客收序號:" + main_rs_no + "！</h1></div>");
    }

    /// <summary>
    /// 取得該案號的新副碼
    /// <param name="pseq">主案號</param>
    /// </summary>
    private string getSeq1(string pseq) {
        string cChars = "123456789ABDEFGHIJKLNOPQRSTUVWXY";//可用的副碼依順序取用,不含C、M、Z
        SQL = "select max(seq1) as seq1 from dmt where seq ='" + pseq + "' and seq1 not in ('_','C','M','Z') ";
        objResult = conn.ExecuteScalar(SQL);
        string seq1 = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();
        int cinx = cChars.IndexOf("seq1") + 1;//取得新副碼的charindex
        if (cinx > 31) {
            strOut.AppendLine("<div align='center'><h1>本所編號取得有誤, 請通知系統人員！</h1></div>");
            Response.End();
        } else {
            seq1 = cChars[cinx].ToString();
        }

        SQL = "select count(*) from dmt where seq = " + pseq + " and seq1 = '" + seq1 + "'";
        objResult = conn.ExecuteScalar(SQL);
        int cnt = (objResult == DBNull.Value || objResult == null) ? 0 : Convert.ToInt32(objResult);
        if (cnt != 0) {
            strOut.AppendLine("<div align='center'><h1>本所編號取得有誤, 請通知系統人員！</h1></div>");
            Response.End();
        }
        return seq1;
    }

    private string move_file(string RSno, string drawValue, string suffix) {
        Sys sfile = new Sys();
        sfile.getFileServer(Sys.GetSession("SeBranch"), Request["prgid"]);//檔案上傳相關設定

        if (drawValue.Trim() == "" || drawValue == null)
            return "";

        string aa = drawValue.ToLower();
        string newfilename = "";
        if (aa != "") {
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
        }
        return newfilename;
    }

    /// <summary>
    /// 搬移檔案
    /// </summary>
    private string movefile(string in_scode, string in_no, string seq, string seq1, string cust_area, string case_sqlno) {
        Sys sfile = new Sys();
        sfile.getFileServer(Sys.GetSession("SeBranch"), Request["prgid"]);//檔案上傳相關設定

        SQL = "select draw_file from dmt_temp where in_scode= '" + in_scode + "' and in_no = '" + in_no + "' and case_sqlno = " + case_sqlno;
        objResult = conn.ExecuteScalar(SQL);
        string draw_file = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();

        if (draw_file == "") return draw_file;

        string fseq = seq.PadLeft(Sys.DmtSeq, '0');
        string aa = System.IO.Path.GetFileName(draw_file);//原始檔名
        string ar = System.IO.Path.GetExtension(aa);//副檔名
        string lname = string.Format("{0}{1}{2}", seq, seq1 != "_" && seq1 != "" ? "-" + seq1 : "", ar);//新檔名

        string strpath = sfile.gbrWebDir + "/" + fseq.Left(1) + "/" + fseq.Substring(1, 2);
        Sys.RenameFile(Sys.Path2Nbtbrt(draw_file), strpath + "/" + lname, true);
        string draw = Sys.Path2Btbrt(strpath + "/" + lname);//存到資料庫的路徑

        SQL = "update dmt_temp set draw_file='" + draw + "' where in_scode= '" + in_scode + "' and in_no = '" + in_no + "' and case_sqlno = " + case_sqlno;
        conn.ExecuteNonQuery(SQL);
        return draw;
    }

    /// <summary>
    /// 新案新增資料到dmt
    /// <para>後續案之新立案新增資料到dmt</para>
    /// <para>更新apcust內商案件編號</para>
    /// <param name="insflag">I:入繳費狀態,N:變更or分割子案不入只入母案，IN:移轉子案</param>
    /// </summary>
    private void Insert_dmt(string seq, string seq1, string cseq, string cseq1, string Mscode, string Min_no, string step_grade, string case_sqlno, string insflag) {
        SQL = "select a.*,b.cust_area,b.cust_seq,b.att_sql,b.arcase_type,b.arcase,b.case_no";
        SQL += ",isnull(a.ap_cname1,'') as ap_cname1A,isnull(a.ap_cname2,'') as ap_cname2A,isnull(a.ap_ename1,'') as ap_ename1A,isnull(a.ap_ename2,'') as ap_ename2A ";
        SQL += ",c.end_flag,c.end_code,c.end_type,c.end_remark ";
        SQL += " from dmt_temp as a ";
        SQL += " inner join case_dmt as b on a.in_scode = b.in_scode and a.in_no = b.in_no ";
        SQL += " left outer join case_dmt1 as c on a.in_no=c.in_no and a.case_sqlno=c.case_sqlno ";
        SQL += " where a.in_scode = '" + Mscode + "' and a.in_no = '" + Min_no + "'";
        SQL += " and a.case_sqlno = " + case_sqlno;
        DataTable dt = new DataTable();
        conn.DataTable(SQL, dt);

        if (dt.Rows.Count > 0) {
            SQL = "select a.apsqlno,a.apcust_no,a.ap_cname from dmt_temp_ap a where a.in_no='" + Min_no + "' and case_sqlno=" + case_sqlno + " order by temp_ap_sqlno";
            string lapsqlno = "", lapcust_no = "";
            using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
                if (dr.Read()) {
                    lapsqlno = dr.SafeRead("apsqlno", "");
                    lapcust_no = dr.SafeRead("apcust_no", "");
                    dr.Close();
                } else {
                    lapsqlno = dt.Rows[0].SafeRead("apsqlno", "");
                    SQL = "select apcust_no from apcust where apsqlno = '" + dt.Rows[0].SafeRead("apsqlno", "") + "'";
                    using (SqlDataReader dr1 = conn.ExecuteReader(SQL)) {
                        if (dr1.Read()) {
                            lapcust_no = dr1.SafeRead("apcust_no", "");
                        }
                    }
                }
            }

            SQL = "select * from dmt where seq = " + seq + " and seq1 = '" + seq1 + "'";
            using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
                if (dr.Read()) {
                    dr.Close();
                    SQL = "insert into dmt ";
                    ColMap.Clear();
                    ColMap["seq"] = Util.dbnull(seq);
                    ColMap["seq1"] = Util.dbchar(seq1);
                    ColMap["s_mark"] = Util.dbchar(dt.Rows[0].SafeRead("s_mark", ""));
                    ColMap["pul"] = Util.dbchar(dt.Rows[0].SafeRead("pul", ""));
                    ColMap["class"] = Util.dbnull(dt.Rows[0].SafeRead("class", ""));
                    ColMap["class_count"] = Util.dbzero(dt.Rows[0].SafeRead("class_count", ""));
                    ColMap["class_type"] = Util.dbnull(dt.Rows[0].SafeRead("class_type", ""));
                    ColMap["in_date"] = Util.dbchar(DateTime.Today.ToShortDateString());
                    ColMap["arcase_type"] = Util.dbnull(dt.Rows[0].SafeRead("arcase_type", ""));
                    ColMap["arcase_class"] = Util.dbnull(ReqVal.TryGet("hrs_class"));
                    ColMap["arcase"] = Util.dbnull(dt.Rows[0].SafeRead("arcase", ""));
                    ColMap["appl_name"] = Util.dbnull(dt.Rows[0].SafeRead("appl_name", ""));
                    ColMap["cust_area"] = Util.dbnull(dt.Rows[0].SafeRead("cust_area", ""));
                    ColMap["cust_seq"] = Util.dbnull(dt.Rows[0].SafeRead("cust_seq", ""));
                    ColMap["cust_seq1"] = Util.dbchar("0");
                    ColMap["att_sql"] = Util.dbnull(dt.Rows[0].SafeRead("att_sql", ""));
                    ColMap["apsqlno"] = Util.dbnull(lapsqlno);
                    ColMap["apcust_no"] = Util.dbnull(lapcust_no);
                    ColMap["ap_cname"] = Util.dbnull(dt.Rows[0].SafeRead("ap_cname1A", "") + dt.Rows[0].SafeRead("ap_cname2A", ""));
                    ColMap["ap_ename"] = Util.dbnull(dt.Rows[0].SafeRead("ap_ename1A", "") + dt.Rows[0].SafeRead("ap_ename2A", ""));
                    ColMap["agt_no"] = Util.dbnull(dt.Rows[0].SafeRead("agt_no", ""));
                    ColMap["apply_date"] = Util.dbnull(dt.Rows[0].GetDateTimeString("apply_date", "yyyy/M/d"));
                    ColMap["apply_no"] = Util.dbnull(dt.Rows[0].SafeRead("apply_no", ""));
                    ColMap["issue_date"] = Util.dbnull(dt.Rows[0].GetDateTimeString("issue_date", "yyyy/M/d"));
                    ColMap["issue_no"] = Util.dbnull(dt.Rows[0].SafeRead("issue_no", ""));
                    ColMap["open_date"] = Util.dbnull(dt.Rows[0].GetDateTimeString("open_date", "yyyy/M/d"));
                    ColMap["rej_no"] = Util.dbnull(dt.Rows[0].SafeRead("rej_no", ""));
                    if (dt.Rows[0].GetDateTimeString("prior_date", "yyyy/M/d") == "1900/1/1") {
                        ColMap["prior_date"] = Util.dbnull("");
                    } else {
                        ColMap["prior_date"] = Util.dbnull(dt.Rows[0].GetDateTimeString("prior_date", "yyyy/M/d"));
                    }
                    ColMap["prior_no"] = Util.dbnull(dt.Rows[0].SafeRead("prior_no", ""));
                    ColMap["prior_country"] = Util.dbnull(dt.Rows[0].SafeRead("prior_country", ""));
                    ColMap["term1"] = Util.dbnull(dt.Rows[0].SafeRead("dmt_term1", ""));
                    ColMap["term2"] = Util.dbnull(dt.Rows[0].SafeRead("dmt_term2", ""));
                    ColMap["tcn_ref"] = Util.dbnull(dt.Rows[0].SafeRead("tcn_ref", ""));
                    ColMap["tcn_class"] = Util.dbnull(dt.Rows[0].SafeRead("tcn_class", ""));
                    ColMap["tcn_name"] = Util.dbnull(dt.Rows[0].SafeRead("tcn_name", ""));
                    ColMap["tcn_mark"] = Util.dbnull(dt.Rows[0].SafeRead("tcn_mark", ""));
                    if (ReqVal.TryGet("hrs_code").Left(2) == "FD") {//分割案入母案編號
                        ColMap["mseq"] = Util.dbnull(cseq);
                        ColMap["mseq1"] = Util.dbnull(cseq1);
                    }
                    if (ReqVal.TryGet("hrs_code").Left(2) == "FT") {//移轉案入母案編號
                        ColMap["mseq"] = Util.dbnull(dt.Rows[0].SafeRead("ref_no", ""));
                        ColMap["mseq1"] = Util.dbnull(dt.Rows[0].SafeRead("ref_no1", ""));
                    }
                    if (insflag == "I") {
                        ColMap["pay_times"] = Util.dbchar(seq1);
                        ColMap["pay_date"] = Util.dbchar(seq1);
                    }
                    ColMap["end_date"] = Util.dbnull(dt.Rows[0].SafeRead("end_date", ""));
                    ColMap["end_code"] = Util.dbnull(dt.Rows[0].SafeRead("end_code", ""));
                    ColMap["renewal"] = Util.dbzero(dt.Rows[0].SafeRead("renewal", ""));
                    ColMap["scode"] = Util.dbnull(dt.Rows[0].SafeRead("in_scode", ""));
                    ColMap["step_grade"] = Util.dbnull(step_grade);
                    ColMap["now_grade"] = Util.dbnull(step_grade);
                    ColMap["now_stat"] = Util.dbnull(ReqVal.TryGet("ncase_stat"));
                    ColMap["now_arcase_type"] = Util.dbnull(ReqVal.TryGet("rs_type"));
                    ColMap["now_arcase_class"] = Util.dbnull(ReqVal.TryGet("hrs_class"));
                    ColMap["now_arcase"] = Util.dbnull(ReqVal.TryGet("hrs_code"));
                    ColMap["now_act_code"] = Util.dbnull(ReqVal.TryGet("hact_code"));
                    ColMap["cseq"] = Util.dbnull(cseq);
                    ColMap["cseq1"] = Util.dbnull(cseq1);
                    ColMap["s_mark2"] = Util.dbnull(dt.Rows[0].SafeRead("s_mark2", ""));
                    ColMap["cust_prod"] = Util.dbnull(dt.Rows[0].SafeRead("cust_prod", ""));
                    SQL += ColMap.GetInsertSQL();
                    conn.ExecuteNonQuery(SQL);
                } else {
                    dr.Close();
                    SQL = "update dmt set ";
                    ColMap.Clear();
                    ColMap["s_mark"] = Util.dbchar(dt.Rows[0].SafeRead("s_mark", ""));
                    ColMap["pul"] = Util.dbchar(dt.Rows[0].SafeRead("pul", ""));
                    ColMap["class"] = Util.dbnull(dt.Rows[0].SafeRead("class", ""));
                    ColMap["class_count"] = Util.dbzero(dt.Rows[0].SafeRead("class_count", ""));
                    ColMap["appl_name"] = Util.dbnull(dt.Rows[0].SafeRead("appl_name", ""));
                    ColMap["cust_area"] = Util.dbnull(dt.Rows[0].SafeRead("cust_area", ""));
                    ColMap["cust_seq"] = Util.dbnull(dt.Rows[0].SafeRead("cust_seq", ""));
                    ColMap["cust_seq1"] = Util.dbchar("0");
                    ColMap["att_sql"] = Util.dbnull(dt.Rows[0].SafeRead("att_sql", ""));
                    ColMap["apsqlno"] = Util.dbnull(lapsqlno);
                    ColMap["apcust_no"] = Util.dbnull(lapcust_no);
                    ColMap["ap_cname"] = Util.dbnull(dt.Rows[0].SafeRead("ap_cname1A", "") + dt.Rows[0].SafeRead("ap_cname2A", ""));
                    ColMap["ap_ename"] = Util.dbnull(dt.Rows[0].SafeRead("ap_ename1A", "") + dt.Rows[0].SafeRead("ap_ename2A", ""));
                    ColMap["agt_no"] = Util.dbnull(dt.Rows[0].SafeRead("agt_no", ""));
                    ColMap["apply_date"] = Util.dbnull(dt.Rows[0].GetDateTimeString("apply_date", "yyyy/M/d"));
                    ColMap["apply_no"] = Util.dbnull(dt.Rows[0].SafeRead("apply_no", ""));
                    ColMap["issue_date"] = Util.dbnull(dt.Rows[0].GetDateTimeString("issue_date", "yyyy/M/d"));
                    ColMap["issue_no"] = Util.dbnull(dt.Rows[0].SafeRead("issue_no", ""));
                    ColMap["open_date"] = Util.dbnull(dt.Rows[0].GetDateTimeString("open_date", "yyyy/M/d"));
                    ColMap["rej_no"] = Util.dbnull(dt.Rows[0].SafeRead("rej_no", ""));
                    if (dt.Rows[0].GetDateTimeString("prior_date", "yyyy/M/d") == "1900/1/1") {
                        ColMap["prior_date"] = Util.dbnull("");
                    } else {
                        ColMap["prior_date"] = Util.dbnull(dt.Rows[0].GetDateTimeString("prior_date", "yyyy/M/d"));
                    }
                    ColMap["prior_no"] = Util.dbnull(dt.Rows[0].SafeRead("prior_no", ""));
                    ColMap["prior_country"] = Util.dbnull(dt.Rows[0].SafeRead("prior_country", ""));
                    ColMap["term1"] = Util.dbnull(dt.Rows[0].SafeRead("dmt_term1", ""));
                    ColMap["term2"] = Util.dbnull(dt.Rows[0].SafeRead("dmt_term2", ""));
                    ColMap["tcn_ref"] = Util.dbnull(dt.Rows[0].SafeRead("tcn_ref", ""));
                    ColMap["tcn_class"] = Util.dbnull(dt.Rows[0].SafeRead("tcn_class", ""));
                    ColMap["tcn_name"] = Util.dbnull(dt.Rows[0].SafeRead("tcn_name", ""));
                    ColMap["tcn_mark"] = Util.dbnull(dt.Rows[0].SafeRead("tcn_mark", ""));
                    if (ReqVal.TryGet("hrs_code").Left(2) == "FD") {//分割案入母案編號
                        ColMap["mseq"] = Util.dbnull(cseq);
                        ColMap["mseq1"] = Util.dbnull(cseq1);
                    }
                    ColMap["renewal"] = Util.dbzero(dt.Rows[0].SafeRead("renewal", ""));
                    ColMap["scode"] = Util.dbnull(dt.Rows[0].SafeRead("in_scode", ""));
                    ColMap["step_grade"] = Util.dbnull(step_grade);
                    ColMap["now_grade"] = Util.dbnull(step_grade);
                    ColMap["now_stat"] = Util.dbnull(ReqVal.TryGet("ncase_stat"));
                    ColMap["now_arcase_type"] = Util.dbnull(ReqVal.TryGet("rs_type"));
                    ColMap["now_arcase_class"] = Util.dbnull(ReqVal.TryGet("hrs_class"));
                    ColMap["now_arcase"] = Util.dbnull(ReqVal.TryGet("hrs_code"));
                    ColMap["now_act_code"] = Util.dbnull(ReqVal.TryGet("hact_code"));
                    ColMap["cseq"] = Util.dbnull(cseq);
                    ColMap["cseq1"] = Util.dbnull(cseq1);
                    ColMap["s_mark2"] = Util.dbnull(dt.Rows[0].SafeRead("s_mark2", ""));
                    ColMap["cust_prod"] = Util.dbnull(dt.Rows[0].SafeRead("cust_prod", ""));
                    SQL += ColMap.GetUpdateSQL();
                    SQL += " where seq = " + seq + " and seq1 = '" + seq1 + "'";
                    conn.ExecuteNonQuery(SQL);
                }
            }

            //新增申請人檔及更新申請人檔案件編號
            string t1 = "";
            if (seq1 != "_") t1 = "-" + seq1;

            seq = seq.PadLeft(Sys.DmtSeq, '0');
            string tseq = Session["seBranch"] + Sys.GetSession("dept").ToUpper() + seq + t1;
            SQL = "select a.*,b.ap_zip as ap_ap_zip,b.ap_addr1 as ap_ap_addr1,b.ap_addr2 as ap_ap_addr2 ";
            SQL += ",b.ap_eaddr1 as ap_ap_eaddr1,b.ap_eaddr2 as ap_ap_eaddr2,b.ap_eaddr3 as ap_ap_eaddr3,b.ap_eaddr4 as ap_ap_eaddr4 ";
            SQL += "from dmt_temp_ap a left outer join apcust b on a.apsqlno=b.apsqlno ";
            SQL += "where a.in_no='" + Min_no + "' and a.case_sqlno = " + case_sqlno;
            DataTable dr2 = new DataTable();
            conn.DataTable(SQL, dr2);

            for (int n = 0; n < dr2.Rows.Count; n++) {
                //因交辦案件申請人先前無中英文地址，當無申請人序號，則依申請人檔資料顯示
                //若申請人序號>=0，則以交辦案件申請人為準
                string ap_sql = dr2.Rows[n].SafeRead("ap_sql", "");
                string ap_zip = dr2.Rows[n].SafeRead("ap_zip", "");
                string ap_addr1 = dr2.Rows[n].SafeRead("ap_addr1", "");
                string ap_addr2 = dr2.Rows[n].SafeRead("ap_addr2", "");
                string ap_eaddr1 = dr2.Rows[n].SafeRead("ap_eaddr1", "");
                string ap_eaddr2 = dr2.Rows[n].SafeRead("ap_eaddr2", "");
                string ap_eaddr3 = dr2.Rows[n].SafeRead("ap_eaddr3", "");
                string ap_eaddr4 = dr2.Rows[n].SafeRead("ap_eaddr4", "");
                if (ap_sql == "") {
                    ap_zip = dr2.Rows[n].SafeRead("ap_ap_zip", "");
                    ap_addr1 = dr2.Rows[n].SafeRead("ap_ap_addr1", "");
                    ap_addr2 = dr2.Rows[n].SafeRead("ap_ap_addr2", "");
                    ap_eaddr1 = dr2.Rows[n].SafeRead("ap_ap_eaddr1", "");
                    ap_eaddr2 = dr2.Rows[n].SafeRead("ap_ap_eaddr2", "");
                    ap_eaddr3 = dr2.Rows[n].SafeRead("ap_ap_eddr3", "");
                    ap_eaddr4 = dr2.Rows[n].SafeRead("ap_ap_eddr4", "");
                }

                SQL = "insert into dmt_ap (branch,seq,seq1,apsqlno,server_flag,apcust_no,ap_cname,ap_ename,tran_date,tran_scode,ap_fcname,ap_lcname,ap_fename,ap_lename";
                SQL += ",ap_sql,ap_zip,ap_addr1,ap_addr2,ap_eaddr1,ap_eaddr2,ap_eaddr3,ap_eaddr4) values (";
                SQL += "'" + Session["seBranch"] + "'," + seq + ",'" + seq1 + "'," + Util.dbnull(dr2.Rows[n].SafeRead("apsqlno", ""));
                SQL +=  "," + Util.dbchar(dr2.Rows[n].SafeRead("server_flag", "")) + "," + Util.dbchar(dr2.Rows[n].SafeRead("apcust_no", ""));
                SQL += "," + Util.dbchar(dr2.Rows[n].SafeRead("ap_cname", "")) + "," + Util.dbchar(dr2.Rows[n].SafeRead("ap_ename", ""));
                SQL +=",getdate(),'" + Session["scode"] + "'," + Util.dbchar(dr2.Rows[n].SafeRead("ap_fcname", ""));
                SQL += "," + Util.dbchar(dr2.Rows[n].SafeRead("ap_lcname", "")) + "," + Util.dbchar(dr2.Rows[n].SafeRead("ap_fename", ""));
               SQL += "," + Util.dbchar(dr2.Rows[n].SafeRead("ap_lename", "")) + "," + Util.dbzero(ap_sql) + "";
                SQL += "," + Util.dbchar(ap_zip) + "," + Util.dbchar(ap_addr1) + "," + Util.dbchar(ap_addr2) + "";
                SQL += "," + Util.dbchar(ap_eaddr1) + "," + Util.dbchar(ap_eaddr2) + "," + Util.dbchar(ap_eaddr3) + "," + Util.dbchar(ap_eaddr4) + ")";
                conn.ExecuteNonQuery(SQL);

                SQL = "update apcust set dmt_seq='" + tseq + "',ap_code='NO'";
                SQL += ",tran_date=getdate(),tran_scode='" + Session["scode"] + "'";
                SQL += " where apsqlno=" + dr2.Rows[n].SafeRead("apsqlno", "");
                conn.ExecuteNonQuery(SQL);
            }

            //移轉將原舊案結案insflag=I,endflag51=Y,舊案編號為dmt_temp.ref_no,ref_no1
            if (insflag.Left(1) == "I") {
                //2012/10/19修改，因移轉有多件，所以判斷主案request("endflag51")，子案由case_dmt1抓取
                string endflag51 = dt.Rows[0].SafeRead("end_flag", "");
                string end_code51 = dt.Rows[0].SafeRead("end_code", "");
                string end_type51 = dt.Rows[0].SafeRead("end_type", "");
                string end_remark51 = dt.Rows[0].SafeRead("end_remark", "");

                if (insflag == "I") {
                    endflag51 = ReqVal.TryGet("endflag51");
                    end_code51 = ReqVal.TryGet("end_code51");
                    end_type51 = ReqVal.TryGet("end_type51");
                    end_remark51 = ReqVal.TryGet("end_remark51");
                }

                if (endflag51.Trim() == "Y") {
                    //產生本收進度
                    //取得案件進度
                    SQL = "select step_grade from dmt where seq= '" + dt.Rows[0].SafeRead("ref_no", "") + "' and seq1 = '" + dt.Rows[0].SafeRead("ref_no1", "") + "'";
                    objResult = conn.ExecuteScalar(SQL);
                    string lstep_grade = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();
                    if (lstep_grade == "") {
                        lstep_grade = "1";
                        throw new Exception("案件進度有問題, 請洽系統維護人員!!");
                    } else {
                        lstep_grade = (Convert.ToInt32(lstep_grade) + 1).ToString();
                        SQL = "select step_grade from dmt where seq= '" + dt.Rows[0].SafeRead("ref_no", "") + "' and seq1 = '" + dt.Rows[0].SafeRead("ref_no1", "") + "' and step_grade = " + lstep_grade;
                        objResult = conn.ExecuteScalar(SQL);
                        if (objResult != DBNull.Value && objResult != null) {
                            throw new Exception("案件進度有問題, 請洽系統維護人員!!");
                        }
                    }

                    //取得收發文序號
                    SQL = "select isnull(sql,0)+1 from cust_code where code_type='Z' and cust_code='" + Session["sebranch"] + "TZR'";
                    objResult = conn.ExecuteScalar(SQL);
                    string rs_no = (objResult == DBNull.Value || objResult == null) ? "1" : objResult.ToString();
                    rs_no = "ZR" + rs_no.PadLeft(8, '0');
                    if (main_rs_no == "") {
                        main_rs_no = rs_no;
                    }
                    //流水號加一
                    SQL = " update cust_code set sql = sql + 1 where code_type='Z' and cust_code='" + Session["sebranch"] + "TZR'";
                    conn.ExecuteNonQuery(SQL);

                    SQL = "insert into step_dmt (rs_no,branch,seq,seq1,step_grade,main_rs_no,step_date,cg,rs,rs_type,rs_class,rs_code,act_code,rs_detail";
                    SQL += ",pr_status,new,tran_date,tran_scode) values ('" + rs_no + "','" + Session["sebranch"] + "'";
                    SQL += "," + dt.Rows[0].SafeRead("ref_no", "") + ",'" + dt.Rows[0].SafeRead("ref_no1", "") + "'," + lstep_grade + "";
                    SQL += ",'" + main_rs_no + "'," + Util.dbnull(Request["step_date"]) + ",'Z','R'";
                    SQL += "," + Util.dbnull(Request["rs_type"]) + ",'X1','XZ1','_'";
                    SQL += ",'結案','X','X',getdate(),'" + Session["scode"] + "')";
                    conn.ExecuteNonQuery(SQL);

                    //管制期限B6
                    string ctrl_date = DateTime.Today.AddMonths(1).ToShortDateString();
                    SQL = "insert into ctrl_dmt(rs_no,branch,seq,seq1,step_grade,ctrl_type,ctrl_remark,ctrl_date,tran_date,tran_scode)";
                    SQL += " values('" + rs_no + "','" + Session["sebranch"] + "'," + dt.Rows[0].SafeRead("ref_no", "") + ",'" + dt.Rows[0].SafeRead("ref_no1", "") + "'";
                    SQL += "," + lstep_grade + ",'B6','結案處理期限'";
                    SQL += ",'" + ctrl_date + "',getdate(),'" + Session["scode"] + "')";
                    conn.ExecuteNonQuery(SQL);

                    //入結案處理流程todo_dmt
                    insert_todo_dmt("DC_END1", dt.Rows[0].SafeRead("ref_no", ""), dt.Rows[0].SafeRead("ref_no1", ""), lstep_grade, Mscode, "", "", "0");

                    //修改案件主檔
                    Sys.insert_log_table(conn, "U", HTProgCode, "dmt", "seq;seq1", dt.Rows[0].SafeRead("ref_no", "") + ";" + dt.Rows[0].SafeRead("ref_no1", ""), logReason + "移轉(接洽序號：" + Mscode + "-" + Min_no + ")之前案作結案處理");
                    SQL = "update dmt set seq=seq";
                    SQL += " ,end_code = " + Util.dbnull(end_code51);
                    SQL += " ,end_type = " + Util.dbnull(end_type51);
                    SQL += " ,end_remark = " + Util.dbnull(end_remark51);
                    SQL += " ,step_grade = " + lstep_grade;
                    SQL += " ,now_grade = " + lstep_grade;
                    SQL += " ,now_stat = 'XZ1'";//結案
                    SQL += " ,now_arcase_type = " + Util.dbnull(Request["rs_type"]);
                    SQL += " ,now_arcase = 'XZ1'";//結案
                    SQL += " ,now_arcase_class = 'X1'";//結案
                    SQL += " ,now_act_code = '_'";
                    SQL += " where seq='" + dt.Rows[0].SafeRead("ref_no", "") + "' and seq1 = '" + dt.Rows[0].SafeRead("ref_no1", "") + "'";
                    conn.ExecuteNonQuery(SQL);
                }
            }
        }
    }

    /// <summary>
    /// 新案新增資料到ndmt
    /// </summary>
    private void Insert_ndmt(string seq, string seq1, string case_sqlno) {
        SQL = "select * from dmt_temp where " + wheresqlA + " and case_sqlno = " + case_sqlno;
        DataTable dt2 = new DataTable();
        conn.DataTable(SQL, dt2);

        if (dt2.Rows.Count > 0) {
            SQL = "select * from ndmt where seq = " + seq + " and seq1 = '" + seq1 + "'";
            using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
                if (!dr.HasRows) {
                    dr.Close();
                    SQL = "insert into ndmt (branch,seq,seq1,cappl_name,eappl_name,eappl_name1,eappl_name2,jappl_name,jappl_name1,";
                    SQL += "jappl_name2,zappl_name1,zappl_name2,zname_type,oappl_name,draw,draw_file,symbol,color,tran_date,";
                    SQL += "tran_scode,in_scode,in_no,mark) values (";
                    SQL += "'" + Session["sebranch"] + "'," + seq + ",'" + seq1 + "'," + Util.dbnull(dt2.Rows[0].SafeRead("cappl_name", ""));
                    SQL += "," + Util.dbnull(dt2.Rows[0].SafeRead("eappl_name", "")) + "," + Util.dbnull(dt2.Rows[0].SafeRead("eappl_name1", ""));
                    SQL += "," + Util.dbnull(dt2.Rows[0].SafeRead("eappl_name2", "")) + "," + Util.dbnull(dt2.Rows[0].SafeRead("jappl_name", ""));
                    SQL += "," + Util.dbnull(dt2.Rows[0].SafeRead("jappl_name1", "")) + "," + Util.dbnull(dt2.Rows[0].SafeRead("jappl_name2", ""));
                    SQL += "," + Util.dbnull(dt2.Rows[0].SafeRead("zappl_name1", "")) + "," + Util.dbnull(dt2.Rows[0].SafeRead("zappl_name2", ""));
                    SQL += "," + Util.dbnull(dt2.Rows[0].SafeRead("zname_type", "")) + "," + Util.dbnull(dt2.Rows[0].SafeRead("oappl_name", ""));
                    SQL += "," + Util.dbnull(dt2.Rows[0].SafeRead("draw", "")) + "," + Util.dbnull(dt2.Rows[0].SafeRead("draw_file", ""));
                    SQL += "," + Util.dbnull(dt2.Rows[0].SafeRead("symbol", "")) + "," + Util.dbnull(dt2.Rows[0].SafeRead("color", ""));
                    SQL += ",null,null," + Util.dbnull(dt2.Rows[0].SafeRead("in_scode", ""));
                    SQL += "," + Util.dbnull(dt2.Rows[0].SafeRead("in_no", "")) + "," + Util.dbnull(dt2.Rows[0].SafeRead("mark", "")) + ")";
                } else {
                    dr.Close();
                    SQL = "Update ndmt set cappl_name=" + Util.dbnull(dt2.Rows[0].SafeRead("cappl_name", ""));
                    SQL += ",eappl_name =" + Util.dbnull(dt2.Rows[0].SafeRead("eappl_name", ""));
                    SQL += ",eappl_name1 =" + Util.dbnull(dt2.Rows[0].SafeRead("eappl_name1", ""));
                    SQL += ",eappl_name2 =" + Util.dbnull(dt2.Rows[0].SafeRead("eappl_name2", ""));
                    SQL += ",jappl_name =" + Util.dbnull(dt2.Rows[0].SafeRead("jappl_name", ""));
                    SQL += ",jappl_name1 =" + Util.dbnull(dt2.Rows[0].SafeRead("jappl_name1", ""));
                    SQL += ",jappl_name2 =" + Util.dbnull(dt2.Rows[0].SafeRead("jappl_name2", ""));
                    SQL += ",zappl_name1 =" + Util.dbnull(dt2.Rows[0].SafeRead("zappl_name1", ""));
                    SQL += ",zappl_name2 =" + Util.dbnull(dt2.Rows[0].SafeRead("zappl_name2", ""));
                    SQL += ",zname_type =" + Util.dbnull(dt2.Rows[0].SafeRead("zname_type", ""));
                    SQL += ",oappl_name =" + Util.dbnull(dt2.Rows[0].SafeRead("oappl_name", ""));
                    SQL += ",draw =" + Util.dbnull(dt2.Rows[0].SafeRead("draw", ""));
                    SQL += ",draw_file =" + Util.dbnull(dt2.Rows[0].SafeRead("draw_file", ""));
                    SQL += ",symbol =" + Util.dbnull(dt2.Rows[0].SafeRead("symbol", ""));
                    SQL += ",color =" + Util.dbnull(dt2.Rows[0].SafeRead("color", ""));
                    SQL += ",tran_date =getdate()";
                    SQL += ",tran_scode ='" + Session["scode"] + "'";
                    SQL += ",in_scode =" + Util.dbnull(dt2.Rows[0].SafeRead("in_scode", ""));
                    SQL += ",in_no =" + Util.dbnull(dt2.Rows[0].SafeRead("in_no", ""));
                    SQL += " where branch = '" + Session["sebranch"] + "' and seq = " + seq + " and seq1 = '" + seq1 + "'";
                }
            }
            conn.ExecuteNonQuery(SQL);
        }
    }

    /// <summary>
    /// 新案新增資料到dmt_show
    /// </summary>
    private void Insert_dmt_show(string seq, string seq1, string in_no, string case_sqlno) {
        SQL = "select * from casedmt_show where in_no=" + in_no + " and case_sqlno = " + case_sqlno;
        DataTable dt2 = new DataTable();
        conn.DataTable(SQL, dt2);

        if (dt2.Rows.Count > 0) {
            Sys.insert_log_table(conn, "U", HTProgCode, "dmt_show", "seq;seq1", seq + ";" + seq1, logReason);
            SQL = "delete from dmt_show where seq=" + seq + " and seq1='" + seq1 + "'";
            conn.ExecuteNonQuery(SQL);

            SQL = "insert into dmt_show (seq,seq1,show_date,show_name,tr_date,tr_scode,mark) ";
            SQL += "select " + seq + ",'" + seq1 + "',show_date,show_name,getdate(),'" + Session["scode"] + "',mark ";
            SQL += "from casedmt_show where in_no=" + in_no + " and case_sqlno = " + case_sqlno;
            conn.ExecuteNonQuery(SQL);
        }
    }

    /// <summary>
    /// 一案多件子本所編號新增資料到dmt
    /// </summary>
    private void Insert_dmt2(string seq, string seq1, string cseq, string cseq1, string Mscode, string Min_no, string step_grade) {
        SQL = "select a.*,b.cust_area,b.cust_seq,b.att_sql,b.arcase_type,b.arcase";
        SQL += ",isnull(a.ap_cname1,'') as ap_cname1A,isnull(a.ap_cname2,'') as ap_cname2A,isnull(a.ap_ename1,'') as ap_ename1A,isnull(a.ap_ename2,'') as ap_ename2A ";
        SQL += " from dmt_temp as a ";
        SQL += " inner join case_dmt as b on a.in_scode = b.in_scode and a.in_no = b.in_no ";
        SQL += " where a.in_scode = '" + Mscode + "' and a.in_no = '" + Min_no + "'";
        DataTable dt = new DataTable();
        conn.DataTable(SQL, dt);

        if (dt.Rows.Count > 0) {
            SQL = "select apcust_no from apcust where apsqlno = '" + dt.Rows[0].SafeRead("apsqlno", "") + "'";
            objResult = conn.ExecuteScalar(SQL);
            string lapcust_no = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();

            SQL = "select * from dmt where seq = " + cseq + " and seq1 = '" + cseq1 + "'";
            using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
                if (dr.Read()) {
                    SQL = "insert into dmt ";
                    ColMap.Clear();
                    ColMap["seq"] = Util.dbnull(seq);
                    ColMap["seq1"] = Util.dbchar(seq1);
                    ColMap["s_mark"] = Util.dbchar(dr.SafeRead("s_mark", ""));
                    ColMap["pul"] = Util.dbchar(dr.SafeRead("pul", ""));
                    ColMap["class"] = Util.dbnull(dr.SafeRead("class", ""));
                    ColMap["class_count"] = Util.dbzero(dr.SafeRead("class_count", ""));
                    ColMap["class_type"] = Util.dbnull(dr.SafeRead("class_type", ""));
                    ColMap["in_date"] = Util.dbchar(DateTime.Today.ToShortDateString());
                    ColMap["arcase_type"] = Util.dbnull(dt.Rows[0].SafeRead("arcase_type", ""));
                    ColMap["arcase_class"] = Util.dbnull(ReqVal.TryGet("hrs_class"));
                    ColMap["arcase"] = Util.dbnull(dt.Rows[0].SafeRead("arcase", ""));
                    ColMap["appl_name"] = Util.dbnull(dr.SafeRead("appl_name", ""));
                    ColMap["cust_area"] = Util.dbnull(dt.Rows[0].SafeRead("cust_area", ""));
                    ColMap["cust_seq"] = Util.dbnull(dt.Rows[0].SafeRead("cust_seq", ""));
                    ColMap["cust_seq1"] = Util.dbchar("0");
                    ColMap["att_sql"] = Util.dbnull(dt.Rows[0].SafeRead("att_sql", ""));
                    ColMap["apsqlno"] = Util.dbnull(dt.Rows[0].SafeRead("apsqlno", ""));
                    ColMap["apcust_no"] = Util.dbnull(lapcust_no);
                    ColMap["ap_cname"] = Util.dbnull(dt.Rows[0].SafeRead("ap_cname1A", "") + dt.Rows[0].SafeRead("ap_cname2A", ""));
                    ColMap["ap_ename"] = Util.dbnull(dt.Rows[0].SafeRead("ap_ename1A", "") + dt.Rows[0].SafeRead("ap_ename2A", ""));
                    ColMap["agt_no"] = Util.dbnull(dr.SafeRead("agt_no", ""));
                    ColMap["apply_date"] = Util.dbnull(dr.GetDateTimeString("apply_date", "yyyy/M/d"));
                    ColMap["apply_no"] = Util.dbnull(dr.SafeRead("apply_no", ""));
                    ColMap["issue_date"] = Util.dbnull(dr.GetDateTimeString("issue_date", "yyyy/M/d"));
                    ColMap["issue_no"] = Util.dbnull(dr.SafeRead("issue_no", ""));
                    ColMap["open_date"] = Util.dbnull(dr.GetDateTimeString("open_date", "yyyy/M/d"));
                    ColMap["rej_no"] = Util.dbnull(dr.SafeRead("rej_no", ""));
                    if (dr.GetDateTimeString("prior_date", "yyyy/M/d") == "1900/1/1") {
                        ColMap["prior_date"] = Util.dbnull("");
                    } else {
                        ColMap["prior_date"] = Util.dbnull(dr.GetDateTimeString("prior_date", "yyyy/M/d"));
                    }
                    ColMap["prior_no"] = Util.dbnull(dr.SafeRead("prior_no", ""));
                    ColMap["prior_country"] = Util.dbnull(dr.SafeRead("prior_country", ""));
                    ColMap["term1"] = Util.dbnull(dr.SafeRead("term1", ""));
                    ColMap["term2"] = Util.dbnull(dr.SafeRead("term2", ""));
                    ColMap["tcn_ref"] = Util.dbnull(dr.SafeRead("tcn_ref", ""));
                    ColMap["tcn_class"] = Util.dbnull(dr.SafeRead("tcn_class", ""));
                    ColMap["tcn_name"] = Util.dbnull(dr.SafeRead("tcn_name", ""));
                    ColMap["tcn_mark"] = Util.dbnull(dr.SafeRead("tcn_mark", ""));
                    ColMap["mseq"] = Util.dbnull(dr.SafeRead("mseq", ""));
                    ColMap["mseq1"] = Util.dbnull(dr.SafeRead("mseq1", ""));
                    ColMap["end_date"] = Util.dbnull(dr.SafeRead("end_date", ""));
                    ColMap["end_code"] = Util.dbnull(dr.SafeRead("end_code", ""));
                    ColMap["renewal"] = Util.dbzero(dr.SafeRead("renewal", ""));
                    ColMap["scode"] = Util.dbnull(Mscode);
                    ColMap["step_grade"] = Util.dbnull(step_grade);
                    ColMap["now_grade"] = Util.dbnull(step_grade);
                    ColMap["now_stat"] = Util.dbnull(ReqVal.TryGet("ncase_stat"));
                    ColMap["now_arcase_type"] = Util.dbnull(ReqVal.TryGet("rs_type"));
                    ColMap["now_arcase_class"] = Util.dbnull(ReqVal.TryGet("hrs_class"));
                    ColMap["now_arcase"] = Util.dbnull(ReqVal.TryGet("hrs_code"));
                    ColMap["now_act_code"] = Util.dbnull(ReqVal.TryGet("hact_code"));
                    ColMap["cseq"] = Util.dbnull(cseq);
                    ColMap["cseq1"] = Util.dbnull(cseq1);
                    ColMap["s_mark2"] = Util.dbnull(dr.SafeRead("s_mark2", ""));
                    ColMap["cust_prod"] = Util.dbnull(dr.SafeRead("cust_prod", ""));
                    SQL += ColMap.GetInsertSQL();
                    conn.ExecuteNonQuery(SQL);
                }
            }
        }
    }

    /// <summary>
    /// 新案新增資料到ndmt, dmt_good, dmt_show
    /// </summary>
    private void Insert_ndmt2(string seq, string seq1, string cseq, string cseq1, string Mscode, string Min_no) {
        SQL = "insert into ndmt (branch,seq,seq1,cappl_name,eappl_name,eappl_name1,eappl_name2,jappl_name,jappl_name1";
        SQL += ",jappl_name2,zappl_name1,zappl_name2,zname_type,oappl_name,draw,draw_file,symbol,color,tran_date";
        SQL += ",tran_scode,in_scode,in_no,mark) ";
        SQL += "select '" + Session["seBranch"] + "'," + seq + ",'" + seq1 + "',cappl_name ";
        SQL += ",eappl_name,eappl_name1,eappl_name2,jappl_name,jappl_name1 ";
        SQL += ",jappl_name2,zappl_name1,zappl_name2,zname_type,oappl_name,draw,draw_file,symbol,color,null ";
        SQL += ",null,'" + Mscode + "','" + Min_no + "',mark ";
        SQL += "from ndmt where seq = " + cseq + " and seq1 = '" + cseq1 + "'";
        conn.ExecuteNonQuery(SQL);

        SQL = "insert into dmt_good (seq,seq1,class,dmt_grp_code,dmt_goodname,dmt_goodcount,in_scode,in_no,tr_date,tr_scode,mark) ";
        SQL += "select " + seq + ",'" + seq1 + "',class,dmt_grp_code,dmt_goodname,dmt_goodcount";
        SQL += "," + Util.dbnull(Mscode) + "," + Util.dbnull(Min_no) + ",getdate(),'" + Session["scode"] + "',mark ";
        SQL += "from dmt_good where seq = " + cseq + " and seq1 = '" + cseq1 + "'";
        conn.ExecuteNonQuery(SQL);

        SQL = "insert into dmt_show (seq,seq1,show_date,show_name,tr_date,tr_scode,mark) ";
        SQL += "select " + seq + ",'" + seq1 + "',show_date,show_name,getdate(),'" + Session["scode"] + "',mark ";
        SQL += "from dmt_show where seq = " + cseq + " and seq1 = '" + cseq1 + "'";
        conn.ExecuteNonQuery(SQL);
    }

    /// <summary>
    /// 舊案修改資料到dmt,ndmt
    /// </summary>
    private void Update_dmt(string seq, string seq1, string Mscode, string Min_no, string step_grade) {
        SQL = "select a.*,b.cust_area,b.cust_seq,b.att_sql,b.arcase_type,b.arcase,b.case_no,b.end_type,b.end_remark,b.back_flag";
        SQL += ",isnull(a.ap_cname1,'') as ap_cname1A,isnull(a.ap_cname2,'') as ap_cname2A,isnull(a.ap_ename1,'') as ap_ename1A,isnull(a.ap_ename2,'') as ap_ename2A ";
        SQL += " from dmt_temp as a ";
        SQL += " inner join case_dmt as b on a.in_scode = b.in_scode and a.in_no = b.in_no ";
        SQL += " where a.in_scode = '" + Mscode + "' and a.in_no = '" + Min_no + "'";
        DataTable RTreg = new DataTable();
        conn.DataTable(SQL, RTreg);

        if (RTreg.Rows.Count > 0) {
            string ncname1 = "";//變更商標名稱
            //變更案,有變更申請人時才需更改申請人
            string arcase = RTreg.Rows[0].SafeRead("arcase", "");
            if (arcase.IN("FC2,FC21,FC0,FC6,FC8,FCI") || arcase.Left(2) == "FR") {
                SQL = "select ncname1 from dmt_tranlist where " + wheresqlA + " and mod_field = 'mod_dmt'";
                objResult = conn.ExecuteScalar(SQL);
                ncname1 = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();
            }

            //判斷該案性是否可修改申請人相關資料
            bool upddmtap = false; string lapcust_no = "";
            SQL = "select * from code_br where dept = '" + Session["dept"] + "'";
            SQL += " and cr = 'Y' and rs_type = '" + RTreg.Rows[0].SafeRead("arcase_type", "") + "'";
            SQL += " and rs_code = '" + RTreg.Rows[0].SafeRead("arcase", "") + "'";
            SQL += " and rs_class in (select cust_code from cust_code where code_type = 'TUP_APCust')";
            using (SqlDataReader dr1 = conn.ExecuteReader(SQL)) {
                if (dr1.Read()) {
                    dr1.Close();
                    SQL = "select a.*,b.ap_zip as ap_ap_zip,b.ap_addr1 as ap_ap_addr1,b.ap_addr2 as ap_ap_addr2 ";
                    SQL += ",b.ap_eaddr1 as ap_ap_eaddr1,b.ap_eaddr2 as ap_ap_eaddr2,b.ap_eaddr3 as ap_ap_eaddr3,b.ap_eaddr4 as ap_ap_eaddr4 ";
                    SQL += "from dmt_temp_ap a left outer join apcust b on a.apsqlno=b.apsqlno ";
                    SQL += " where a.in_no='" + Min_no + "' and a.case_sqlno = 0";
                    using (SqlDataReader dr2 = conn.ExecuteReader(SQL)) {
                        if (dr2.HasRows) {
                            Sys.insert_log_table(conn, "U", HTProgCode, "dmt_ap", "seq;seq1", seq + ";" + seq1, logReason);
                            SQL = "delete from dmt_ap where seq=" + seq + " and seq1='" + seq1 + "'";
                            conn.ExecuteNonQuery(SQL);
                            while (dr2.Read()) {
                                //因交辦案件申請人先前無中英文地址，當無申請人序號，則依申請人檔資料顯示
                                //若申請人序號>=0，則以交辦案件申請人為準
                                string ap_sql = dr2.SafeRead("ap_sql", "");
                                string ap_zip = dr2.SafeRead("ap_zip", "");
                                string ap_addr1 = dr2.SafeRead("ap_addr1", "");
                                string ap_addr2 = dr2.SafeRead("ap_addr2", "");
                                string ap_eaddr1 = dr2.SafeRead("ap_eaddr1", "");
                                string ap_eaddr2 = dr2.SafeRead("ap_eaddr2", "");
                                string ap_eaddr3 = dr2.SafeRead("ap_eaddr3", "");
                                string ap_eaddr4 = dr2.SafeRead("ap_eaddr4", "");
                                if (ap_sql == "") {
                                    ap_zip = dr2.SafeRead("ap_ap_zip", "");
                                    ap_addr1 = dr2.SafeRead("ap_ap_addr1", "");
                                    ap_addr2 = dr2.SafeRead("ap_ap_addr2", "");
                                    ap_eaddr1 = dr2.SafeRead("ap_ap_eaddr1", "");
                                    ap_eaddr2 = dr2.SafeRead("ap_ap_eaddr2", "");
                                    ap_eaddr3 = dr2.SafeRead("ap_ap_eddr3", "");
                                    ap_eaddr4 = dr2.SafeRead("ap_ap_eddr4", "");
                                }

                                SQL = "insert into dmt_ap (branch,seq,seq1,apsqlno,server_flag,apcust_no,ap_cname,ap_ename,tran_date,tran_scode,ap_fcname,ap_lcname,ap_fename,ap_lename,ap_sql,ap_zip,ap_addr1,ap_addr2,ap_eaddr1,ap_eaddr2,ap_eaddr3,ap_eaddr4) values (";
                                SQL += "'" + Session["seBranch"] + "'," + seq + ",'" + seq1 + "'," + Util.dbnull(dr2.SafeRead("apsqlno", "")) + "," + Util.dbchar(dr2.SafeRead("server_flag", "")) + "";
                                SQL += "," + Util.dbchar(dr2.SafeRead("apcust_no", "")) + "," + Util.dbchar(dr2.SafeRead("ap_cname", "")) + "," + Util.dbchar(dr2.SafeRead("ap_ename", "")) + ",getdate(),'" + Session["scode"] + "'";
                                SQL += "," + Util.dbchar(dr2.SafeRead("ap_fcname", "")) + "," + Util.dbchar(dr2.SafeRead("ap_lcname", "")) + "," + Util.dbchar(dr2.SafeRead("ap_fename", "")) + "," + Util.dbchar(dr2.SafeRead("ap_lename", "")) + "";
                                SQL += "," + Util.dbzero(ap_sql) + "," + Util.dbchar(ap_zip) + "," + Util.dbchar(ap_addr1) + "," + Util.dbchar(ap_addr2) + "";
                                SQL += "," + Util.dbchar(ap_eaddr1) + "," + Util.dbchar(ap_eaddr2) + "," + Util.dbchar(ap_eaddr3) + "," + Util.dbchar(ap_eaddr4) + ")";
                                conn.ExecuteNonQuery(SQL);
                            }
                        } else {
                            dr2.Close();
                            upddmtap = true;
                            SQL = "select apcust_no from apcust where apsqlno = '" + RTreg.Rows[0].SafeRead("apsqlno", "") + "'";
                            using (SqlDataReader dr3 = conn.ExecuteReader(SQL)) {
                                if (dr3.Read()) {
                                    lapcust_no = dr3.SafeRead("apcust_no", "");
                                }
                            }
                        }
                    }
                }
            }

            //修改案件主檔、入dmt_log檔
            Sys.insert_log_table(conn, "U", HTProgCode, "dmt", "seq;seq1", seq + ";" + seq1, logReason + "舊案修改");
            SQL = "update dmt set ";
            ColMap.Clear();
            ColMap["s_mark"] = Util.dbchar(RTreg.Rows[0].SafeRead("s_mark", ""));
            ColMap["pul"] = Util.dbchar(RTreg.Rows[0].SafeRead("pul", ""));
            ColMap["class"] = Util.dbnull(RTreg.Rows[0].SafeRead("class", ""));
            ColMap["class_count"] = Util.dbzero(RTreg.Rows[0].SafeRead("class_count", ""));
            if (ncname1 != "") {
                ColMap["appl_name"] = Util.dbnull(ncname1);
            }
            ColMap["cust_area"] = Util.dbnull(RTreg.Rows[0].SafeRead("cust_area", ""));
            ColMap["cust_seq"] = Util.dbnull(RTreg.Rows[0].SafeRead("cust_seq", ""));
            ColMap["cust_seq1"] = Util.dbchar("0");
            ColMap["att_sql"] = Util.dbnull(RTreg.Rows[0].SafeRead("att_sql", ""));
            if (upddmtap) {
                ColMap["apsqlno"] = Util.dbnull(RTreg.Rows[0].SafeRead("apsqlno", ""));
                ColMap["apcust_no"] = Util.dbnull(lapcust_no);
                ColMap["ap_cname"] = Util.dbnull(RTreg.Rows[0].SafeRead("ap_cname1A", "") + RTreg.Rows[0].SafeRead("ap_cname2A", ""));
                ColMap["ap_ename"] = Util.dbnull(RTreg.Rows[0].SafeRead("ap_ename1A", "") + RTreg.Rows[0].SafeRead("ap_ename2A", ""));
            }
            ColMap["agt_no"] = Util.dbnull(RTreg.Rows[0].SafeRead("agt_no", ""));
            ColMap["apply_date"] = Util.dbnull(RTreg.Rows[0].GetDateTimeString("apply_date", "yyyy/M/d"));
            ColMap["apply_no"] = Util.dbnull(RTreg.Rows[0].SafeRead("apply_no", ""));
            ColMap["issue_date"] = Util.dbnull(RTreg.Rows[0].GetDateTimeString("issue_date", "yyyy/M/d"));
            ColMap["issue_no"] = Util.dbnull(RTreg.Rows[0].SafeRead("issue_no", ""));
            ColMap["open_date"] = Util.dbnull(RTreg.Rows[0].GetDateTimeString("open_date", "yyyy/M/d"));
            ColMap["rej_no"] = Util.dbnull(RTreg.Rows[0].SafeRead("rej_no", ""));
            if (RTreg.Rows[0].GetDateTimeString("prior_date", "yyyy/M/d") == "1900/1/1") {
                ColMap["prior_date"] = Util.dbnull("");
            } else {
                ColMap["prior_date"] = Util.dbnull(RTreg.Rows[0].GetDateTimeString("prior_date", "yyyy/M/d"));
            }
            ColMap["prior_no"] = Util.dbnull(RTreg.Rows[0].SafeRead("prior_no", ""));
            ColMap["prior_country"] = Util.dbnull(RTreg.Rows[0].SafeRead("prior_country", ""));
            ColMap["term1"] = Util.dbnull(RTreg.Rows[0].SafeRead("dmt_term1", ""));
            ColMap["term2"] = Util.dbnull(RTreg.Rows[0].SafeRead("dmt_term2", ""));
            ColMap["tcn_ref"] = Util.dbnull(RTreg.Rows[0].SafeRead("tcn_ref", ""));
            ColMap["tcn_class"] = Util.dbnull(RTreg.Rows[0].SafeRead("tcn_class", ""));
            ColMap["tcn_name"] = Util.dbnull(RTreg.Rows[0].SafeRead("tcn_name", ""));
            ColMap["tcn_mark"] = Util.dbnull(RTreg.Rows[0].SafeRead("tcn_mark", ""));
            //2011/1/13增加復案註記處理,將結案資料清空
            if (RTreg.Rows[0].SafeRead("back_flag", "") == "Y") {
                ColMap["end_date"] = Util.dbnull("");
                ColMap["end_code"] = Util.dbchar("");
                ColMap["end_type"] = Util.dbchar("");
                ColMap["end_remark"] = Util.dbchar("");
            } else {
                ColMap["end_type"] = Util.dbnull(RTreg.Rows[0].SafeRead("end_type", ""));
                ColMap["end_remark"] = Util.dbnull(RTreg.Rows[0].SafeRead("end_remark", ""));
            }
            ColMap["renewal"] = Util.dbzero(RTreg.Rows[0].SafeRead("renewal", ""));
            ColMap["scode"] = Util.dbnull(RTreg.Rows[0].SafeRead("in_scode", ""));
            ColMap["step_grade"] = Util.dbnull(step_grade);
            //2010/9/29修改判斷有案件狀態才更新
            if (ReqVal.TryGet("ncase_stat") != "") {
                ColMap["now_grade"] = Util.dbnull(step_grade);
                ColMap["now_stat"] = Util.dbnull(ReqVal.TryGet("ncase_stat"));
                ColMap["now_arcase_type"] = Util.dbnull(ReqVal.TryGet("rs_type"));
                ColMap["now_arcase_class"] = Util.dbnull(ReqVal.TryGet("hrs_class"));
                ColMap["now_arcase"] = Util.dbnull(ReqVal.TryGet("hrs_code"));
                ColMap["now_act_code"] = Util.dbnull(ReqVal.TryGet("hact_code"));
            }
            SQL += ColMap.GetUpdateSQL();
            SQL += " where seq = " + seq + " and seq1 = '" + seq1 + "'";
            conn.ExecuteNonQuery(SQL);

            SQL = "select * from ndmt where branch='" + Session["seBranch"] + "' and seq = " + seq + " and seq1 = '" + seq1 + "'";
            using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
                if (!dr.HasRows) {
                    dr.Close();
                    SQL = "insert into ndmt (branch,seq,seq1,cappl_name,eappl_name,eappl_name1,eappl_name2,jappl_name,jappl_name1,";
                    SQL += "jappl_name2,zappl_name1,zappl_name2,zname_type,oappl_name,draw,draw_file,symbol,color,tran_date,";
                    SQL += "tran_scode,in_scode,in_no,mark) values (";
                    SQL += "'" + Session["sebranch"] + "'," + seq + ",'" + seq1 + "'," + Util.dbnull(RTreg.Rows[0].SafeRead("cappl_name", ""));
                    SQL += "," + Util.dbnull(RTreg.Rows[0].SafeRead("eappl_name", "")) + "," + Util.dbnull(RTreg.Rows[0].SafeRead("eappl_name1", ""));
                    SQL += "," + Util.dbnull(RTreg.Rows[0].SafeRead("eappl_name2", "")) + "," + Util.dbnull(RTreg.Rows[0].SafeRead("jappl_name", ""));
                    SQL += "," + Util.dbnull(RTreg.Rows[0].SafeRead("jappl_name1", "")) + "," + Util.dbnull(RTreg.Rows[0].SafeRead("jappl_name2", ""));
                    SQL += "," + Util.dbnull(RTreg.Rows[0].SafeRead("zappl_name1", "")) + "," + Util.dbnull(RTreg.Rows[0].SafeRead("zappl_name2", ""));
                    SQL += "," + Util.dbnull(RTreg.Rows[0].SafeRead("zname_type", "")) +"," + Util.dbnull(RTreg.Rows[0].SafeRead("oappl_name", ""));
                    SQL += "," + Util.dbnull(RTreg.Rows[0].SafeRead("draw", "")) + "," + Util.dbnull(RTreg.Rows[0].SafeRead("draw_file", ""));
                    SQL += "," + Util.dbnull(RTreg.Rows[0].SafeRead("symbol", "")) + "," + Util.dbnull(RTreg.Rows[0].SafeRead("color", ""));
                    SQL += ",null,null," + Util.dbnull(RTreg.Rows[0].SafeRead("in_scode", ""));
                    SQL += "," + Util.dbnull(RTreg.Rows[0].SafeRead("in_no", "")) + "," + Util.dbnull(RTreg.Rows[0].SafeRead("mark", "")) + ")";
                    conn.ExecuteNonQuery(SQL);
                } else {
                    dr.Close();
                    SQL = "Update ndmt set cappl_name=" + Util.dbnull(RTreg.Rows[0].SafeRead("cappl_name", ""));
                    SQL += ",eappl_name =" + Util.dbnull(RTreg.Rows[0].SafeRead("eappl_name", ""));
                    SQL += ",eappl_name1 =" + Util.dbnull(RTreg.Rows[0].SafeRead("eappl_name1", ""));
                    SQL += ",eappl_name2 =" + Util.dbnull(RTreg.Rows[0].SafeRead("eappl_name2", ""));
                    SQL += ",jappl_name =" + Util.dbnull(RTreg.Rows[0].SafeRead("jappl_name", ""));
                    SQL += ",jappl_name1 =" + Util.dbnull(RTreg.Rows[0].SafeRead("jappl_name1", ""));
                    SQL += ",jappl_name2 =" + Util.dbnull(RTreg.Rows[0].SafeRead("jappl_name2", ""));
                    SQL += ",zappl_name1 =" + Util.dbnull(RTreg.Rows[0].SafeRead("zappl_name1", ""));
                    SQL += ",zappl_name2 =" + Util.dbnull(RTreg.Rows[0].SafeRead("zappl_name2", ""));
                    SQL += ",zname_type =" + Util.dbnull(RTreg.Rows[0].SafeRead("zname_type", ""));
                    SQL += ",oappl_name =" + Util.dbnull(RTreg.Rows[0].SafeRead("oappl_name", ""));
                    SQL += ",draw =" + Util.dbnull(RTreg.Rows[0].SafeRead("draw", ""));
                    SQL += ",draw_file =" + Util.dbnull(RTreg.Rows[0].SafeRead("draw_file", ""));
                    SQL += ",symbol =" + Util.dbnull(RTreg.Rows[0].SafeRead("symbol", ""));
                    SQL += ",color =" + Util.dbnull(RTreg.Rows[0].SafeRead("color", ""));
                    SQL += ",tran_date =getdate()";
                    SQL += ",tran_scode ='" + Session["scode"] + "'";
                    SQL += ",in_scode =" + Util.dbnull(RTreg.Rows[0].SafeRead("in_scode", ""));
                    SQL += ",in_no =" + Util.dbnull(RTreg.Rows[0].SafeRead("in_no", ""));
                    SQL += " where branch = '" + Session["sebranch"] + "' and seq = " + seq + " and seq1 = '" + seq1 + "'";
                    conn.ExecuteNonQuery(SQL);
                }
            }

            //2011/2/14復案註記，結案進行中取消結案流程並銷管結案期限
            if (ReqVal.TryGet("back_flag").Trim() == "Y") {
                update_tododmt_end(seq, seq1);
            }
        }
    }

    /// <summary>
    /// 
    /// </summary>
    private void Update_dmt1(string seq, string seq1, string Mscode, string Min_no, string step_grade) {
        SQL = "select a.*,b.cust_area,b.cust_seq,b.att_sql,b.arcase_type,b.arcase,b.end_type,b.end_remark,b.back_flag";
        SQL += " from dmt_temp as a ";
        SQL += " inner join case_dmt as b on a.in_scode = b.in_scode and a.in_no = b.in_no ";
        SQL += " where a.in_scode = '" + Mscode + "' and a.in_no = '" + Min_no + "'";
        DataTable RTreg = new DataTable();
        conn.DataTable(SQL, RTreg);

        if (RTreg.Rows.Count > 0) {
            //入dmt_log檔
            Sys.insert_log_table(conn, "U", HTProgCode, "dmt", "seq;seq1", seq + ";" + seq1, logReason + "舊案修改");
            SQL = "update dmt set ";
            ColMap.Clear();
            ColMap["att_sql"] = Util.dbnull(RTreg.Rows[0].SafeRead("att_sql", ""));
            ColMap["scode"] = Util.dbnull(RTreg.Rows[0].SafeRead("in_scode", ""));
            //2011/1/13增加復案註記處理
            if (RTreg.Rows[0].SafeRead("back_flag", "") == "Y") {
                ColMap["end_date"] = Util.dbnull("");
                ColMap["end_code"] = Util.dbchar("");
                ColMap["end_type"] = Util.dbchar("");
                ColMap["end_remark"] = Util.dbchar("");
            } else {
                ColMap["end_type"] = Util.dbnull(RTreg.Rows[0].SafeRead("end_type", ""));
                ColMap["end_remark"] = Util.dbnull(RTreg.Rows[0].SafeRead("end_remark", ""));
            }
            ColMap["step_grade"] = Util.dbnull(step_grade);
            //2010/9/29修改判斷有案件狀態才更新
            if (ReqVal.TryGet("ncase_stat") != "") {
                ColMap["now_grade"] = Util.dbnull(step_grade);
                ColMap["now_stat"] = Util.dbnull(ReqVal.TryGet("ncase_stat"));
                ColMap["now_arcase_type"] = Util.dbnull(ReqVal.TryGet("rs_type"));
                ColMap["now_arcase_class"] = Util.dbnull(ReqVal.TryGet("hrs_class"));
                ColMap["now_arcase"] = Util.dbnull(ReqVal.TryGet("hrs_code"));
                ColMap["now_act_code"] = Util.dbnull(ReqVal.TryGet("hact_code"));
            }
            SQL += ColMap.GetUpdateSQL();
            SQL += " where seq = " + seq + " and seq1 = '" + seq1 + "'";
            conn.ExecuteNonQuery(SQL);

            SQL = "select * from ndmt where branch='" + Session["seBranch"] + "' and seq = " + seq + " and seq1 = '" + seq1 + "'";
            using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
                if (!dr.HasRows) {
                    dr.Close();
                    SQL = "insert into ndmt (branch,seq,seq1,cappl_name,eappl_name,eappl_name1,eappl_name2,jappl_name,jappl_name1,";
                    SQL += "jappl_name2,zappl_name1,zappl_name2,zname_type,oappl_name,draw,draw_file,symbol,color,tran_date,";
                    SQL += "tran_scode,in_scode,in_no,mark) values (";
                    SQL += "'" + Session["sebranch"] + "'," + seq + ",'" + seq1 + "'," + Util.dbnull(RTreg.Rows[0].SafeRead("cappl_name", ""));
                    SQL += "," + Util.dbnull(RTreg.Rows[0].SafeRead("eappl_name", "")) + "," + Util.dbnull(RTreg.Rows[0].SafeRead("eappl_name1", ""));
                    SQL += "," + Util.dbnull(RTreg.Rows[0].SafeRead("eappl_name2", "")) + "," + Util.dbnull(RTreg.Rows[0].SafeRead("jappl_name", ""));
                    SQL += "," + Util.dbnull(RTreg.Rows[0].SafeRead("jappl_name1", "")) + "," + Util.dbnull(RTreg.Rows[0].SafeRead("jappl_name2", ""));
                    SQL += "," + Util.dbnull(RTreg.Rows[0].SafeRead("zappl_name1", "")) + "," + Util.dbnull(RTreg.Rows[0].SafeRead("zappl_name2", ""));
                    SQL += "," + Util.dbnull(RTreg.Rows[0].SafeRead("zname_type", "")) + "," +Util.dbnull(RTreg.Rows[0].SafeRead("oappl_name", ""));
                    SQL += "," + Util.dbnull(RTreg.Rows[0].SafeRead("draw", "")) + "," + Util.dbnull(RTreg.Rows[0].SafeRead("draw_file", ""));
                    SQL += "," + Util.dbnull(RTreg.Rows[0].SafeRead("symbol", "")) + "," + Util.dbnull(RTreg.Rows[0].SafeRead("color", ""));
                    SQL += ",null,null," + Util.dbnull(RTreg.Rows[0].SafeRead("in_scode", ""));
                    SQL += "," + Util.dbnull(RTreg.Rows[0].SafeRead("in_no", "")) + "," + Util.dbnull(RTreg.Rows[0].SafeRead("mark", "")) + ")";
                    conn.ExecuteNonQuery(SQL);
                } else {
                    dr.Close();
                    SQL = "Update ndmt set tran_date =getdate()";
                    SQL += ",tran_scode ='" + Session["scode"] + "'";
                    SQL += ",in_scode =" + Util.dbchar(Mscode);
                    SQL += ",in_no =" + Util.dbchar(Min_no);
                    SQL += " where branch = '" + Session["sebranch"] + "' and seq = " + seq + " and seq1 = '" + seq1 + "'";
                    conn.ExecuteNonQuery(SQL);
                }
            }

            //2011/2/14復案註記，結案進行中取消結案流程並銷管結案期限
            if (ReqVal.TryGet("back_flag").Trim() == "Y") {
                update_tododmt_end(seq, seq1);
            }
        }
    }

    /// <summary>
    /// 一案多件子案主檔變更
    /// </summary>
    private void Update_dmt2(string seq, string seq1, string Mscode, string Min_no, string step_grade) {
        SQL = "select a.*,b.cust_area,b.cust_seq,b.att_sql,b.arcase_type,b.arcase,b.back_flag";
        SQL += ",isnull(a.ap_cname1,'') as ap_cname1A,isnull(a.ap_cname2,'') as ap_cname2A,isnull(a.ap_ename1,'') as ap_ename1A,isnull(a.ap_ename2,'') as ap_ename2A ";
        SQL += " from dmt_temp as a ";
        SQL += " inner join case_dmt as b on a.in_scode = b.in_scode and a.in_no = b.in_no ";
        SQL += " where a.in_scode = '" + Mscode + "' and a.in_no = '" + Min_no + "'";
        DataTable RTreg = new DataTable();
        conn.DataTable(SQL, RTreg);
        if (RTreg.Rows.Count > 0) {
            string ncname1 = "";//變更商標名稱
            //變更案,有變更申請人時才需更改申請人
            string arcase = RTreg.Rows[0].SafeRead("arcase", "");
            if (arcase.IN("FC21,FC6,FC8,FCI")) {
                SQL = "select ncname1 from dmt_tranlist where " + wheresqlA + " and mod_field = 'mod_dmt'";
                objResult = conn.ExecuteScalar(SQL);
                ncname1 = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();
            }

            //判斷該案性是否可修改申請人相關資料
            bool upddmtap = false; string lapcust_no = "";
            if (arcase.IN("FC11,FC21,FC5,FC6,FC7,FC8,FCH,FCI")) {
                SQL = "select a.*,b.ap_zip as ap_ap_zip,b.ap_addr1 as ap_ap_addr1,b.ap_addr2 as ap_ap_addr2 ";
                SQL += ",b.ap_eaddr1 as ap_ap_eaddr1,b.ap_eaddr2 as ap_ap_eaddr2,b.ap_eaddr3 as ap_ap_eaddr3,b.ap_eaddr4 as ap_ap_eaddr4 ";
                SQL += "from dmt_temp_ap a left outer join apcust b on a.apsqlno=b.apsqlno ";
                SQL += " where a.in_no='" + Min_no + "' and a.case_sqlno = 0";
                using (SqlDataReader dr2 = conn.ExecuteReader(SQL)) {
                    if (dr2.HasRows) {
                        Sys.insert_log_table(conn, "U", HTProgCode, "dmt_ap", "seq;seq1", seq + ";" + seq1, logReason);
                        SQL = "delete from dmt_ap where seq=" + seq + " and seq1='" + seq1 + "'";
                        conn.ExecuteNonQuery(SQL);
                        while (dr2.Read()) {
                            //因交辦案件申請人先前無中英文地址，當無申請人序號，則依申請人檔資料顯示
                            //若申請人序號>=0，則以交辦案件申請人為準
                            string ap_sql = dr2.SafeRead("ap_sql", "");
                            string ap_zip = dr2.SafeRead("ap_zip", "");
                            string ap_addr1 = dr2.SafeRead("ap_addr1", "");
                            string ap_addr2 = dr2.SafeRead("ap_addr2", "");
                            string ap_eaddr1 = dr2.SafeRead("ap_eaddr1", "");
                            string ap_eaddr2 = dr2.SafeRead("ap_eaddr2", "");
                            string ap_eaddr3 = dr2.SafeRead("ap_eaddr3", "");
                            string ap_eaddr4 = dr2.SafeRead("ap_eaddr4", "");
                            if (ap_sql == "") {
                                ap_zip = dr2.SafeRead("ap_ap_zip", "");
                                ap_addr1 = dr2.SafeRead("ap_ap_addr1", "");
                                ap_addr2 = dr2.SafeRead("ap_ap_addr2", "");
                                ap_eaddr1 = dr2.SafeRead("ap_ap_eaddr1", "");
                                ap_eaddr2 = dr2.SafeRead("ap_ap_eaddr2", "");
                                ap_eaddr3 = dr2.SafeRead("ap_ap_eddr3", "");
                                ap_eaddr4 = dr2.SafeRead("ap_ap_eddr4", "");
                            }

                            SQL = "insert into dmt_ap (branch,seq,seq1,apsqlno,server_flag,apcust_no,ap_cname,ap_ename,tran_date,tran_scode,ap_fcname,ap_lcname,ap_fename,ap_lename,ap_sql,ap_zip,ap_addr1,ap_addr2,ap_eaddr1,ap_eaddr2,ap_eaddr3,ap_eaddr4) values (";
                            SQL += "'" + Session["seBranch"] + "'," + seq + ",'" + seq1 + "'," + Util.dbnull(dr2.SafeRead("apsqlno", "")) + "," + Util.dbchar(dr2.SafeRead("server_flag", "")) + "";
                            SQL += "," + Util.dbchar(dr2.SafeRead("apcust_no", "")) + "," + Util.dbchar(dr2.SafeRead("ap_cname", "")) + "," + Util.dbchar(dr2.SafeRead("ap_ename", "")) + ",getdate(),'" + Session["scode"] + "'";
                            SQL += "," + Util.dbchar(dr2.SafeRead("ap_fcname", "")) + "," + Util.dbchar(dr2.SafeRead("ap_lcname", "")) + "," + Util.dbchar(dr2.SafeRead("ap_fename", "")) + "," + Util.dbchar(dr2.SafeRead("ap_lename", "")) + "";
                            SQL += "," + Util.dbzero(ap_sql) + "," + Util.dbchar(ap_zip) + "," + Util.dbchar(ap_addr1) + "," + Util.dbchar(ap_addr2) + "";
                            SQL += "," + Util.dbchar(ap_eaddr1) + "," + Util.dbchar(ap_eaddr2) + "," + Util.dbchar(ap_eaddr3) + "," + Util.dbchar(ap_eaddr4) + ")";
                            conn.ExecuteNonQuery(SQL);
                        }
                    } else {
                        dr2.Close();
                        upddmtap = true;
                        SQL = "select apcust_no from apcust where apsqlno = '" + RTreg.Rows[0].SafeRead("apsqlno", "") + "'";
                        using (SqlDataReader dr3 = conn.ExecuteReader(SQL)) {
                            if (dr3.Read()) {
                                lapcust_no = dr3.SafeRead("apcust_no", "");
                            }
                        }
                    }
                }
            }

            //修改案件主檔、入dmt_log檔
            Sys.insert_log_table(conn, "U", HTProgCode, "dmt", "seq;seq1", seq + ";" + seq1, logReason + "舊案修改");
            SQL = "update dmt set ";
            ColMap.Clear();
            ColMap["att_sql"] = Util.dbnull(RTreg.Rows[0].SafeRead("att_sql", ""));
            if (ncname1 != "") {
                ColMap["appl_name"] = Util.dbnull(ncname1);
            }
            if (upddmtap) {
                ColMap["apsqlno"] = Util.dbnull(RTreg.Rows[0].SafeRead("apsqlno", ""));
                ColMap["apcust_no"] = Util.dbnull(lapcust_no);
                ColMap["ap_cname"] = Util.dbnull(RTreg.Rows[0].SafeRead("ap_cname1A", "") + RTreg.Rows[0].SafeRead("ap_cname2A", ""));
                ColMap["ap_ename"] = Util.dbnull(RTreg.Rows[0].SafeRead("ap_ename1A", "") + RTreg.Rows[0].SafeRead("ap_ename2A", ""));
            }
            ColMap["scode"] = Util.dbnull(RTreg.Rows[0].SafeRead("in_scode", ""));
            ColMap["step_grade"] = Util.dbnull(step_grade);
            //2011/1/13增加復案註記處理,將結案資料清空
            if (RTreg.Rows[0].SafeRead("back_flag", "") == "Y") {
                ColMap["end_date"] = Util.dbnull("");
                ColMap["end_code"] = Util.dbchar("");
                ColMap["end_type"] = Util.dbchar("");
                ColMap["end_remark"] = Util.dbchar("");
            }
            //2010/9/29修改判斷有案件狀態才更新
            if (ReqVal.TryGet("ncase_stat") != "") {
                ColMap["now_grade"] = Util.dbnull(step_grade);
                ColMap["now_stat"] = Util.dbnull(ReqVal.TryGet("ncase_stat"));
                ColMap["now_arcase_type"] = Util.dbnull(ReqVal.TryGet("rs_type"));
                ColMap["now_arcase_class"] = Util.dbnull(ReqVal.TryGet("hrs_class"));
                ColMap["now_arcase"] = Util.dbnull(ReqVal.TryGet("hrs_code"));
                ColMap["now_act_code"] = Util.dbnull(ReqVal.TryGet("hact_code"));
            }
            SQL += ColMap.GetUpdateSQL();
            SQL += " where seq = " + seq + " and seq1 = '" + seq1 + "'";
            conn.ExecuteNonQuery(SQL);

            SQL = "Update ndmt set tran_date =getdate()";
            SQL += ",tran_scode ='" + Session["scode"] + "'";
            SQL += ",in_scode =" + Util.dbchar(Mscode);
            SQL += ",in_no =" + Util.dbchar(Min_no);
            SQL += " where branch = '" + Session["sebranch"] + "' and seq = " + seq + " and seq1 = '" + seq1 + "'";
            conn.ExecuteNonQuery(SQL);

            //2011/2/14復案註記，結案進行中取消結案流程並銷管結案期限
            if (ReqVal.TryGet("back_flag").Trim() == "Y") {
                update_tododmt_end(seq, seq1);
            }
        }
    }

    /// <summary>
    /// 復案處理，結案進行中取消結案流程並銷管結案期限
    /// </summary>
    private void update_tododmt_end(string pseq, string pseq1) {
        //檢查有無結案進行中
        SQL = "select * from todo_dmt where seq=" + pseq + " and seq1='" + pseq1 + "' and job_status='NN' and dowhat like '%END%' ";
        using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
            while (dr.Read()) {
                //銷管結案期限
                SQL = "insert into resp_dmt(sqlno,rs_no,branch,seq,seq1,step_grade,resp_grade,ctrl_type,ctrl_remark,ctrl_date,resp_date,resp_type,resp_remark,tran_date,tran_scode) ";
                SQL += "select sqlno,rs_no,branch,seq,seq1,step_grade,0,ctrl_type,ctrl_remark,ctrl_date,'" + DateTime.Today.ToShortDateString() + "','','復案取消結案',getdate(),'" + Session["scode"] + "' ";
                SQL += "from ctrl_dmt where sqlno in(";
                SQL += "select sqlno from ctrl_dmt where seq=" + pseq + " and seq1='" + pseq1 + "' and step_grade='" + dr["step_grade"] + "' andc ctrl_type in ('B6','B61') ";
                SQL += ")";
                conn.ExecuteNonQuery(SQL);

                SQL = "delete from ctrl_dmt where sqlno in(";
                SQL += "select sqlno from ctrl_dmt where seq=" + pseq + " and seq1='" + pseq1 + "' and step_grade='" + dr["step_grade"] + "' andc ctrl_type in ('B6','B61') ";
                SQL += ")";
                conn.ExecuteNonQuery(SQL);

                //更新結案流程狀態
                SQL = "update todo_dmt set job_status = 'XX' ";
                SQL += " ,approve_scode = '" + Session["scode"] + "' ";
                SQL += " ,approve_desc = '復案取消結案流程'";
                SQL += " ,resp_date=getdate() ";
                SQL += " where sqlno in(";
                SQL += "select sqlno from ctrl_dmt where seq=" + pseq + " and seq1='" + pseq1 + "' and step_grade='" + dr["step_grade"] + "' andc ctrl_type in ('B6','B61') ";
                SQL += ")";
                conn.ExecuteNonQuery(SQL);
            }
        }
    }

    /// <summary>
    /// 新增資料到 dmt_good
    /// </summary>
    private void Insert_Good(string seq, string seq1, string case_sqlno) {
        SQL = "delete from dmt_good where seq=" + seq + " and seq1='" + seq1 + "'";
        conn.ExecuteNonQuery(SQL);

        SQL = "insert into dmt_good (seq,seq1,class,dmt_grp_code,dmt_goodname,dmt_goodcount,in_scode,in_no,tr_date,tr_scode,mark) ";
        SQL += "select " + seq + ",'" + seq1 + "',class,dmt_grp_code,dmt_goodname,dmt_goodcount";
        SQL += ",in_scode,in_no,getdate(),'" + Session["scode"] + "',mark ";
        SQL += "from casedmt_good where " + wheresqlA + " and case_sqlno = " + case_sqlno;
        conn.ExecuteNonQuery(SQL);
    }

    /// <summary>
    /// 新增進度檔 step_dmt
    /// <param name="pflag">Y:舊案要處理復案</param>
    /// </summary>
    private void Insert_Step(string seq, string seq1, string scode, string in_no, string step_grade, string pflag) {
        if (step_grade == "1") {
            //2008/12/11新增一筆進度0
            Insert_stepZZ(seq, seq1);
        }
        //取得收發文序號
        SQL = "select isnull(sql,0)+1 from cust_code where code_type='Z' and cust_code='" + Session["sebranch"] + "TCR'";
        objResult = conn.ExecuteScalar(SQL);
        string rs_no = (objResult == DBNull.Value || objResult == null) ? "1" : objResult.ToString();
        rs_no = "CR" + rs_no.PadLeft(8, '0');
        if (main_rs_no == "") {
            main_rs_no = rs_no;
        }

        SQL = " update cust_code set sql = sql + 1 where code_type='Z' and cust_code='" + Session["sebranch"] + "TCR'";
        conn.ExecuteNonQuery(SQL);

        //取得交辦單號
        string case_no = "", tot_num = "", back_flag = "", back_remark = "";
        SQL = "select case_no,isnull(tot_num,'1') as tot_num,back_flag,back_remark from case_dmt where in_scode='" + scode + "' and in_no = '" + in_no + "'";
        using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
            if (dr.Read()) {
                case_no = dr.SafeRead("case_no", "");
                tot_num = dr.SafeRead("tot_num", "");
                back_flag = dr.SafeRead("back_flag", "");
                back_remark = dr.SafeRead("back_remark", "");
            }
        }

        string pr_status = "N", pr_scode = ReqVal.TryGet("pr_scode");
        if (pr_scode == "") {
            pr_status = "X";
        }

        //爭救案需註記爭救案處理狀態
        string opt_stat = "";
        if (ReqVal.TryGet("codemark") == "B") {
            opt_stat = ReqVal.TryGet("opt_stat");
        }

        SQL = "insert into step_dmt (rs_no,branch,seq,seq1,step_grade,main_rs_no,step_date,cg,rs,send_sel,rs_type,rs_class,rs_code,act_code";
        SQL += ",rs_detail,doc_detail,receive_no,pr_status,pr_scode,case_no,new,tot_num,tran_date,tran_scode,opt_stat,send_way) values ";
        SQL += "('" + rs_no + "','" + Session["seBranch"] + "'," + seq + ",'" + seq1 + "'," + step_grade + ",'" + main_rs_no + "'";
        SQL += "," + Util.dbnull(ReqVal.TryGet("step_date")) + ",'C','R'," + Util.dbnull(ReqVal.TryGet("send_sel")) + "";
        SQL += "," + Util.dbnull(ReqVal.TryGet("rs_type")) + "," + Util.dbnull(ReqVal.TryGet("hrs_class")) + "";
        SQL += "," + Util.dbnull(ReqVal.TryGet("hrs_code")) + "," + Util.dbnull(ReqVal.TryGet("hact_code")) + "";
        SQL += "," + Util.dbnull(ReqVal.TryGet("rs_detail")) + "," + Util.dbnull(ReqVal.TryGet("doc_detail")) + "";
        SQL += "," + Util.dbnull(ReqVal.TryGet("receive_no")) + ",'" + pr_status + "'," + Util.dbnull(pr_scode) + "";
        SQL += ",'" + case_no + "','N'," + tot_num + ",getdate(),'" + Session["scode"] + "','" + opt_stat + "'," + Util.dbnull(ReqVal.TryGet("send_way")) + ")";
        //conn.ExecuteNonQuery(SQL);

        //抓insert後的流水號
        SQL = "SELECT SCOPE_IDENTITY() AS Current_Identity";
        objResult = conn.ExecuteScalar(SQL);
        string br_rs_sqlno = conn.ExecuteScalar(SQL).ToString();

        //2011/1/13新增復案註記處理要通知總管處
        if (pflag == "Y" && back_flag == "Y") {
            SQL = "insert into brend_mgt(br_step_grade,br_rs_sqlno,seq_area,seq,seq1,end_flag,in_scode,in_date,br_end_reason) values ";
            SQL += "(" + step_grade + "," + br_rs_sqlno + ",'" + Session["seBranch"] + "'," + seq + ",'" + seq1 + "','back'";
            SQL += ",'" + Session["scode"] + "',getdate(),'" + back_remark + "')";
            connm.ExecuteNonQuery(SQL);

            //抓insert後的流水號
            SQL = "SELECT SCOPE_IDENTITY() AS Current_Identity";
            objResult = connm.ExecuteScalar(SQL);
            string Getrs_sqlno = objResult.ToString();

            SQL = "insert into todo_mgt(syscode,apcode,temp_rs_sqlno,br_rs_sqlno,seq_area,seq,seq1,in_date,in_scode,dowhat,job_status) values";
            SQL += "('" + Session["syscode"] + "','brt51'," + Getrs_sqlno + "," + br_rs_sqlno + ",'" + Session["seBranch"] + "'," + seq;
            SQL += ",'" + seq1 + "',getdate(),'" + Session["scode"] + "','back','NN')";
            connm.ExecuteNonQuery(SQL);
        }

        //新增期限管制 ctrl_dmt , 一案多件時, 管制在主要案件
        if (main_rs_no == rs_no) {
            //新增期限管制 ctrl_dmt
            for (int i = 1; i <= Convert.ToInt32("0" + Request["ctrlnum"]); i++) {
                if ((Request["ctrl_type_" + i] ?? "") != "" || (Request["ctrl_date_" + i] ?? "") != "") {
                    SQL = "insert into ctrl_dmt ";
                    ColMap.Clear();
                    ColMap["rs_no"] = Util.dbchar(rs_no);
                    ColMap["branch"] = Util.dbchar(Sys.GetSession("seBranch"));
                    ColMap["seq"] = Util.dbnull(seq);
                    ColMap["seq1"] = Util.dbchar(seq1);
                    ColMap["step_grade"] = Util.dbchar(step_grade);
                    ColMap["ctrl_type"] = Util.dbchar(Request["ctrl_type_" + i]);
                    ColMap["ctrl_remark"] = Util.dbnull(Request["ctrl_remark_" + i]);
                    ColMap["ctrl_date"] = Util.dbnull(Request["ctrl_date_" + i]);
                    ColMap["tran_date"] = "getdate()";
                    ColMap["tran_scode"] = "'" + Session["scode"] + "'";
                    ColMap["from_rs_no"] = Util.dbnull(Request["ctrl_rs_no_" + i]);
                    ColMap["from_step_grade"] = Util.dbnull(Request["ctrl_step_grade_" + i]);
                    SQL += ColMap.GetInsertSQL();
                    conn.ExecuteNonQuery(SQL);
                }
            }
        }

        msgseq += "、" + seq + "-" + seq1;
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
            SQL = "select isnull(sql,0)+1 from cust_code where code_type='Z' and cust_code='" + Session["sebranch"] + "TZZ'";
            objResult = conn.ExecuteScalar(SQL);
            string zzrs_no = (objResult == DBNull.Value || objResult == null) ? "1" : objResult.ToString();
            zzrs_no = "ZZ" + zzrs_no.PadLeft(8, '0');

            //流水號加一
            SQL = " update cust_code set sql = sql + 1 where code_type='Z' and cust_code='" + Session["sebranch"] + "TZZ'";
            conn.ExecuteNonQuery(SQL);

            //新增進度0
            SQL = "insert into step_dmt(rs_no,branch,seq,seq1,step_grade,step_date,main_rs_no,cg,rs,rs_detail) values ";
            SQL += "('" + zzrs_no + "','" + Session["sebranch"] + "'," + seq + ",'" + seq1 + "',0";
            SQL += ",'" + DateTime.Today.ToShortDateString() + "','" + zzrs_no + "','Z','Z','')";
            conn.ExecuteNonQuery(SQL);
        }
    }

    /// <summary>
    /// 新增會計結案處理todo_dmt
    /// </summary>
    private void insert_todo_dmt(string ptodo, string pseq, string pseq1, string pstep_grade, string pin_scode, string pin_no, string pcase_no, string psqlno) {
        string job_team = "";
        string job_scode = Sys.getCodeName(conn, "sysctrl.dbo.scode_roles", "scode", "where branch='" + Session["seBranch"] + "' and dept='T' and syscode='" + Session["syscode"] + "' and sort='01' and roles='account'");
        string in_team = Sys.getCodeName(conn, "sysctrl.dbo.scode_group", "grpid", "where grpclass='" + Session["seBranch"] + "' and scode='" + pin_scode + "'");

        if (ptodo == "DC_END1") {
            job_team = "T210";
            job_scode = Sys.getCodeName(conn, "sysctrl.dbo.scode_group", "scode", "where grpclass='" + Session["seBranch"] + "' and grpid='T210' and grptype='F'");
        }

        SQL = "insert into todo_dmt ";
        ColMap.Clear();
        ColMap["pre_sqlno"] = Util.dbnull(psqlno);
        ColMap["syscode"] = "'" + Session["syscode"] + "'";
        ColMap["apcode"] = "'" + HTProgCode + "'";
        ColMap["from_flag"] = Util.dbchar("END");
        ColMap["branch"] = "'" + Session["seBranch"] + "'";
        ColMap["seq"] = Util.dbnull(pseq);
        ColMap["seq1"] = Util.dbchar(pseq1);
        ColMap["step_grade"] = Util.dbnull(pstep_grade);
        ColMap["in_team"] = Util.dbchar(in_team);
        ColMap["case_in_scode"] = Util.dbchar(pin_scode);
        ColMap["in_no"] = Util.dbchar(pin_no);
        ColMap["case_no"] = Util.dbchar(pcase_no);
        ColMap["in_scode"] = "'" + Session["scode"] + "'";
        ColMap["in_date"] = "getdate()";
        ColMap["dowhat"] = Util.dbchar(ptodo);
        ColMap["job_scode"] = Util.dbchar(job_scode);
        ColMap["job_team"] = Util.dbchar(job_team);
        ColMap["job_status"] = Util.dbchar("NN");
        SQL += ColMap.GetInsertSQL();
        conn.ExecuteNonQuery(SQL);
    }

    /// <summary>
    /// 扣收入案件入帳款系統art_markd
    /// </summary>
    private void Insert_markd(string in_scode, string in_no) {
        //抓取會計人員
        string acc_scode = Sys.getCodeName(conn, "sysctrl.dbo.scode_roles", "scode", "where branch='" + Session["seBranch"] + "' and dept='T' and sort='01' and roles='account'");
        if (acc_scode == "") acc_scode = "m802";

        SQL = "select case_no,seq,seq1,arcase,arcase_type,service,fees,cust_area,cust_seq";
        SQL += ",(select rs_detail from code_br where dept='T' and cr='Y' and rs_type=case_dmt.arcase_type and rs_code=case_dmt.arcase) as arcase_name";
        SQL += ",(select sc_name from sysctrl.dbo.scode where scode=case_dmt.in_scode) as sc_name ";
        SQL += " from case_dmt where in_scode='" + in_scode + "' and in_no='" + in_no + "'";
        DataTable dt = new DataTable();
        conn.DataTable(SQL, dt);

        if (dt.Rows.Count > 0) {
            //修改請款完畢註記為不需請款,2013/9/16增加註記不需會計檢核
            SQL = "update case_dmt set ar_code='X',acc_chk='X' where in_scode='" + in_scode + "' and in_no='" + in_no + "'";
            conn.ExecuteNonQuery(SQL);

            //新增交辦扣收入檔art_markd
            SQL = "insert into account.dbo.art_markd(branch,case_no,seq,seq1,country,ar_type,tr_scode,tr_date,arcase,scode,tot_service,tot_fees,ar_mark,chk_code,cust_area,cust_seq,casegrp) ";
            SQL += " values ('" + Session["seBranch"] + "','" + dt.Rows[0].SafeRead("case_no", "") + "'," + dt.Rows[0].SafeRead("seq", "");
            SQL += ",'" + dt.Rows[0].SafeRead("seq1", "") + "','T','T','" + Session["scode"] + "','" + DateTime.Today.ToShortDateString() + "'";
            SQL += ",'" + dt.Rows[0].SafeRead("arcase", "") + "','" + in_scode + "'," + dt.Rows[0].SafeRead("service", "") + "";
            SQL += "," + dt.Rows[0].SafeRead("fees", "") + ",'D','N','" + dt.Rows[0].SafeRead("cust_area", "") + "'";
            SQL += "," + dt.Rows[0].SafeRead("cust_seq", "") + ",'" + dt.Rows[0].SafeRead("arcase_type", "") + "')";
            conn.ExecuteNonQuery(SQL);

            //Email通知會計
            string Subject = "國內商標網路作業系統－扣收入案件確認通知";
            string strFrom = Session["scode"] + "@saint-island.com.tw";
            List<string> strTo = new List<string>();
            List<string> strCC = new List<string>();
            List<string> strBCC = new List<string>();
            switch (Sys.Host) {
                case "web08":
                case "localhost":
                    strTo.Add("m802@saint-island.com.tw");
                    break;
                case "web10":
                    strTo.Add("m802@saint-island.com.tw");
                    break;
                default:
                    strTo.Add(acc_scode + "@saint-island.com.tw");
                    break;
            }
            string tseq1 = "";
            if (dt.Rows[0].SafeRead("seq1", "") != "_") {
                tseq1 = "-" + dt.Rows[0].SafeRead("seq1", "");
            }

            string body = "【本所編號】 : <B>" + Session["seBranch"] + Session["dept"] + "-" + dt.Rows[0].SafeRead("seq", "") + tseq1 + "</B><br>";
            body += "【交辦單號】 : <B>" + dt.Rows[0].SafeRead("case_no", "") + "</B><br>";
            body += "【交辦案性】 : <B>" + dt.Rows[0].SafeRead("arcase", "") + "_" + dt.Rows[0].SafeRead("arcase_name", "") + "</B><br>";
            body += "【交辦營洽】 : <B>" + in_scode + "_" + dt.Rows[0].SafeRead("sc_name", "") + "</B><br>";
            body += "【交辦服務費】 : <B>" + dt.Rows[0].SafeRead("service", "") + "</B><br>";
            body += "【交辦規費】 : <B>" + dt.Rows[0].SafeRead("fees", "") + "</B><br>";
            body += "◎請至帳款系統執行扣收入案件確認並產生扣收入傳票。";

            Sys.DoSendMail(Subject, body, strFrom, strTo, strCC, strBCC);
        }
    }
</script>

<%Response.Write(strOut.ToString());%>
