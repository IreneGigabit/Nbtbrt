<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>

<script runat="server">
    protected string HTProgCap = "官發回條確認入檔";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "brta33";//程式檔名前綴
    protected string HTProgCode = "brta33";//HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";

    protected string submitTask = "";
    protected string SQL = "";
    protected object objResult = null;
    protected string logReason = "";
        
    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected Dictionary<string, string> ColMap = new Dictionary<string, string>();

    string[] arr_chk,arr_seq,arr_seq1,arr_gr_mp_date,arr_rs_type,arr_rs_class,arr_rs_code,arr_act_code;
	string[] arr_cust_seq,arr_att_sql,arr_temp_rs_sqlno,arr_rs_no,arr_rs_sqlno,arr_dmt_scode;
	string[] arr_step_grade,arr_mg_step_grade,arr_mg_rs_sqlno,arr_child_flag,arr_step_date;
    string[] arr_opt_attach_flag,arr_todo_sqlno,arr_appl_name,arr_rs_detail,arr_gs_send_way,arr_receipt_type,arr_fees;

	string[] arr_mg_apply_date,arr_apply_date,arr_mg_apply_no,arr_apply_no,arr_radcs,arr_chkcsd_flag,arr_send_way;
	string[] arr_opmail_date,arr_cs_remark_code,arr_cs_remark,arr_pmail_date,arr_radscan;

    string[] arr_mchknum;
    
    protected StringBuilder strOut = new StringBuilder();

    DBHelper conn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    DBHelper connm = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    DBHelper conni2 = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    DBHelper conniacc = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    private void Page_Unload(System.Object sender, System.EventArgs e) {
        if (conn != null) conn.Dispose();
        if (connm != null) connm.Dispose();
        if (conni2 != null) conni2.Dispose();
        if (conniacc != null) conniacc.Dispose();
    }

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");
        conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
        connm = new DBHelper(Conn.MG).Debug(Request["chkTest"] == "TEST");
        conni2 = new DBHelper(Conn.account).Debug(Request["chkTest"] == "TEST");
        conniacc = new DBHelper(Conn.iaccount).Debug(Request["chkTest"] == "TEST");

        arr_chk = Request["rows_chk"].Split('\f');
        arr_seq = Request["rows_seq"].Split('\f');
        arr_seq1 = Request["rows_seq1"].Split('\f');
        arr_gr_mp_date = Request["rows_gr_mp_date"].Split('\f');
        arr_rs_type = Request["rows_rs_type"].Split('\f');
        arr_rs_class = Request["rows_rs_class"].Split('\f');
        arr_rs_code = Request["rows_rs_code"].Split('\f');
        arr_act_code = Request["rows_act_code"].Split('\f');
        arr_cust_seq = Request["rows_cust_seq"].Split('\f');
        arr_att_sql = Request["rows_att_sql"].Split('\f');
        arr_temp_rs_sqlno = Request["rows_temp_rs_sqlno"].Split('\f');
        arr_rs_no = Request["rows_rs_no"].Split('\f');
        arr_rs_sqlno = Request["rows_rs_sqlno"].Split('\f');
        arr_dmt_scode = Request["rows_dmt_scode"].Split('\f');
        arr_step_grade = Request["rows_step_grade"].Split('\f');
        arr_mg_step_grade = Request["rows_mg_step_grade"].Split('\f');
        arr_mg_rs_sqlno = Request["rows_mg_rs_sqlno"].Split('\f');
        arr_child_flag = Request["rows_child_flag"].Split('\f');
        arr_step_date = Request["rows_step_date"].Split('\f');
        arr_opt_attach_flag = Request["rows_opt_attach_flag"].Split('\f');
        arr_todo_sqlno = Request["rows_todo_sqlno"].Split('\f');
        arr_appl_name = Request["rows_appl_name"].Split('\f');
        arr_rs_detail = Request["rows_rs_detail"].Split('\f');
        arr_gs_send_way = Request["rows_gs_send_way"].Split('\f');
        arr_receipt_type = Request["rows_receipt_type"].Split('\f');
        arr_fees = Request["rows_fees"].Split('\f');

        arr_mg_apply_date = Request["rows_mg_apply_date"].Split('\f');
        arr_apply_date = Request["rows_apply_date"].Split('\f');
        arr_mg_apply_no = Request["rows_mg_apply_no"].Split('\f');
        arr_apply_no = Request["rows_apply_no"].Split('\f');
        arr_radcs = Request["rows_radcs"].Split('\f');
        arr_chkcsd_flag = Request["rows_chkcsd_flag"].Split('\f');
        arr_send_way = Request["rows_send_way"].Split('\f');
        arr_opmail_date = Request["rows_opmail_date"].Split('\f');
        arr_cs_remark_code = Request["rows_cs_remark_code"].Split('\f');
        arr_cs_remark = Request["rows_cs_remark"].Split('\f');
        arr_pmail_date = Request["rows_pmail_date"].Split('\f');
        arr_radscan = Request["rows_radscan"].Split('\f');

        arr_mchknum = Request["rows_mchknum"].Split('\f');

        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        HTProgCap = myToken.Title;
        DebugStr = myToken.DebugStr;
        if (HTProgRight >= 0) {
            try {
                if (ReqVal.TryGet("qrydowhat") == "mg_gs") {
                    logReason = "Brta33國內案官發回條確認作業";
                    doAdd();
                    strOut.AppendLine("<div align='center'><h1>官方發文回條確認成功!!!</h1></div>");
                }
                if (ReqVal.TryGet("qrydowhat") == "mg_gs_back") {
                    logReason = "Brta33國內案官發退件確認作業";
                    doBack();
                    strOut.AppendLine("<div align='center'><h1>官方發文退件確認成功!!!</h1></div>");
                }
                //conn.Commit();
                //connm.Commit();
                //conni2.Commit();
                //conniacc.Commit();
                conn.RollBack();
                connm.RollBack();
                conni2.RollBack();
                conniacc.RollBack();
            }
            catch (Exception ex) {
                conn.RollBack();
                connm.RollBack();
                conni2.RollBack();
                conniacc.RollBack();
                Sys.errorLog(ex, conn.exeSQL, prgid);
                Sys.errorLog(ex, connm.exeSQL, prgid);
                Sys.errorLog(ex, conni2.exeSQL, prgid);
                Sys.errorLog(ex, conniacc.exeSQL, prgid);
                throw;
            }
            this.DataBind();
        }
    }

    //官發回條確認
    private void doAdd() {
        //新增attcase_dmt交辦發文檔
        for (int i = 1; i < arr_chk.Length; i++) {
            if (arr_chk[i] == "Y") {//有打勾
                Sys.showLog("<font color=red>﹝" + i + "﹞</font>seq=" + arr_seq[i] + "-" + arr_seq1[i]);
                string tseq = arr_seq[i];
                string tseq1 = arr_seq1[i];
                string trs_no = arr_rs_no[i];
                string trs_sqlno = arr_rs_sqlno[i];
                string tappl_name = arr_appl_name[i];
                string tcust_seq = arr_cust_seq[i];
                string trs_detail = arr_rs_detail[i];
                string gs_send_way = arr_gs_send_way[i];//官發之發文方式

                if (trs_no.Left(1) == "B") {
                    //取得案件進度
                    string blstep_grade = "1";
                    SQL = "select step_grade from dmt where seq= '" + tseq + "' and seq1 = '" + tseq1 + "'";
                    objResult = conn.ExecuteScalar(SQL);
                    blstep_grade = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();
                    if (blstep_grade == "") {
                        blstep_grade = "1";
                        throw new Exception("案件進度有問題, 請洽系統維護人員!!");
                    } else {
                        blstep_grade = (Convert.ToInt32(blstep_grade) + 1).ToString();
                        SQL = "select step_grade from dmt where seq= '" + tseq + "' and seq1 = '" + tseq1 + "' and step_grade = " + blstep_grade;
                        objResult = conn.ExecuteScalar(SQL);
                        if (objResult != DBNull.Value && objResult != null) {
                            throw new Exception("案件進度有問題, 請洽系統維護人員!!");
                        }
                    }
                    //取得爭救案發文資料
                    SQL = "select a.*,b.service+isnull(b.add_service,0) as service,b.gs_curr ";
                    SQL += ",b.receipt_type as breceipt_type,b.receipt_title as breceipt_title,b.rectitle_name as brectitle_name,b.send_way as bsend_way ";
                    SQL += "from bstep_temp a left outer join case_dmt b on a.case_no=b.case_no where rs_no='" + trs_no + "'";
                    DataTable dtOpt = new DataTable();
                    conn.DataTable(SQL, dtOpt);
                    if (dtOpt.Rows.Count == 0) {
                        throw new Exception("爭救案發文進度有問題, 請洽系統維護人員!!");
                    }
                    string opt_sqlno = dtOpt.Rows[0].SafeRead("opt_sqlno", "");
                    string opt_branch = dtOpt.Rows[0].SafeRead("send_dept", "");
                    string bstep_date = dtOpt.Rows[0].GetDateTimeString("step_date", "yyyy/M/d");
                    string bmp_date = dtOpt.Rows[0].GetDateTimeString("mp_date", "yyyy/M/d");
                    string send_cl = dtOpt.Rows[0].SafeRead("send_cl", "");
                    string send_cl1 = dtOpt.Rows[0].SafeRead("send_cl1", "");
                    string send_sel = dtOpt.Rows[0].SafeRead("send_sel", "");
                    string rs_type = dtOpt.Rows[0].SafeRead("rs_type", "");
                    string rs_class = dtOpt.Rows[0].SafeRead("rs_class", "");
                    string rs_code = dtOpt.Rows[0].SafeRead("rs_code", "");
                    string act_code = dtOpt.Rows[0].SafeRead("act_code", "");
                    //string rs_detail = dtOpt.Rows[0].SafeRead("rs_detail", "");
                    trs_detail = dtOpt.Rows[0].SafeRead("rs_detail", "");
                    string fees = dtOpt.Rows[0].SafeRead("fees", "");
                    string case_no = dtOpt.Rows[0].SafeRead("case_no", "");
                    string rs_agt_no = dtOpt.Rows[0].SafeRead("rs_agt_no", "");
                    string service = dtOpt.Rows[0].SafeRead("service", "0");
                    string gs_curr = dtOpt.Rows[0].SafeRead("gs_curr", "0");
                    if (Convert.ToInt32(gs_curr) > 0) service = "0";
                    string breceipt_type = dtOpt.Rows[0].SafeRead("breceipt_type", "");
                    string breceipt_title = dtOpt.Rows[0].SafeRead("breceipt_title", "");
                    string brectitle_name = dtOpt.Rows[0].SafeRead("brectitle_name", "");
                    string bsend_way = dtOpt.Rows[0].SafeRead("bsend_way", "");

                    if (dtOpt.Rows[0].SafeRead("case_no", "") != "") {
                        //新增 fees_dmt
                        SQL = "insert into fees_dmt ";
                        ColMap.Clear();
                        ColMap["rs_no"] = Util.dbchar(trs_no);
                        ColMap["case_no"] = Util.dbchar(case_no);
                        ColMap["fees"] = Util.dbzero(fees);
                        ColMap["service"] = Util.dbzero(service);
                        ColMap["gs_curr"] = (Convert.ToInt32(gs_curr) + 1) + "";
                        SQL += ColMap.GetInsertSQL();
                        conn.ExecuteNonQuery(SQL);

                        //將官發規費支出存入case_dmt
                        SQL = "update case_dmt set gs_fees=gs_fees+" + fees + ",gs_curr=gs_curr+1 where case_no='" + case_no + "'";
                        conn.ExecuteNonQuery(SQL);
                    }

                    //入step_dmt	
                    SQL = "insert into step_dmt ";
                    ColMap.Clear();
                    ColMap["rs_no"] = Util.dbchar(trs_no);
                    ColMap["branch"] = Util.dbchar(Sys.GetSession("seBranch"));
                    ColMap["seq"] = Util.dbnull(tseq);
                    ColMap["seq1"] = Util.dbchar(tseq1);
                    ColMap["step_grade"] = Util.dbnull(blstep_grade);
                    ColMap["main_rs_no"] = Util.dbchar(trs_no);
                    ColMap["step_date"] = Util.dbnull(bstep_date);
                    ColMap["mp_date"] = Util.dbnull(bmp_date);
                    ColMap["cg"] = Util.dbchar("G");
                    ColMap["rs"] = Util.dbchar("S");
                    ColMap["rs_type"] = Util.dbnull(rs_type);
                    ColMap["rs_class"] = Util.dbchar(rs_class);
                    ColMap["rs_code"] = Util.dbchar(rs_code);
                    ColMap["act_code"] = Util.dbchar(act_code);
                    ColMap["rs_detail"] = Util.dbnull(trs_detail);
                    ColMap["send_cl"] = Util.dbnull(send_cl);
                    ColMap["send_cl1"] = Util.dbnull(send_cl1);
                    ColMap["send_sel"] = Util.dbnull(send_sel);
                    ColMap["fees"] = Util.dbzero(fees);
                    ColMap["fees_stat"] = Util.dbchar("N");
                    ColMap["opt_branch"] = Util.dbchar(opt_branch);
                    ColMap["new"] = Util.dbchar("N");
                    ColMap["tot_num"] = Util.dbzero("1");
                    ColMap["rs_agt_no"] = Util.dbchar(rs_agt_no);
                    ColMap["tran_date"] = "getdate()";
                    ColMap["tran_scode"] = "'" + Session["scode"] + "'";
                    ColMap["opt_over_date"] = "getdate()";
                    ColMap["receipt_type"] = Util.dbnull(breceipt_type);
                    ColMap["receipt_title"] = Util.dbnull(breceipt_title);
                    ColMap["rectitle_name"] = Util.dbnull(brectitle_name);
                    ColMap["send_way"] = Util.dbnull(bsend_way);
                    SQL += ColMap.GetInsertSQL();
                    conn.ExecuteNonQuery(SQL);
                    //抓insert後的流水號
                    SQL = "SELECT SCOPE_IDENTITY() AS Current_Identity";
                    objResult = conn.ExecuteScalar(SQL);
                    trs_sqlno = objResult.ToString();
                    Sys.showLog("官發進度流水號=" + trs_sqlno);

                    //入ctrl_dmt官發管制期限
                    SQL = "select b.ctrl_type,b.date_ctrl,b.ad,b.days,b.md";
                    SQL += ",(select mark1 from cust_code where code_type='DC' and cust_code=b.date_ctrl) as date_name";
                    SQL += " from vcode_act a inner join code_ctrl b on a.sqlno=b.act_sqlno";
                    SQL += " where cg='G' and rs='S' and rs_code='" + rs_code + "' and act_code='" + act_code + "'";
                    DataTable dtCtrl = new DataTable();
                    conn.DataTable(SQL, dtCtrl);
                    for (int c = 0; c < dtCtrl.Rows.Count; c++) {
                        string ctrl_type = dtCtrl.Rows[c].SafeRead("ctrl_type", "");//管制種類
                        string ad = dtCtrl.Rows[c].SafeRead("ad", "");//運算公式:A:加，D:減 
                        int days = Convert.ToInt32(dtCtrl.Rows[c].SafeRead("days", "0"));//管制天數
                        string md = dtCtrl.Rows[c].SafeRead("md", "").ToUpper();//管制性質
                        string date_ctrl = "", ctrl_date = "";
                        if (dtCtrl.Rows[c].SafeRead("date_name", "") == "step_date") date_ctrl = bstep_date;//日期基礎
                        if (dtCtrl.Rows[c].SafeRead("date_name", "") == "mp_date") date_ctrl = bmp_date;//日期基礎

                        if (ad != "A") {
                            days = -days;
                        }
                        switch (md) {
                            case "D":
                                ctrl_date = Util.str2Dateime(date_ctrl).AddDays(days).ToString("yyyy/M/d"); break;
                            case "M":
                                ctrl_date = Util.str2Dateime(date_ctrl).AddMonths(days).ToString("yyyy/M/d"); break;
                            case "Y":
                                ctrl_date = Util.str2Dateime(date_ctrl).AddYears(days).ToString("yyyy/M/d"); break;
                        }
                        SQL = "insert into ctrl_dmt ";
                        ColMap.Clear();
                        ColMap["rs_no"] = Util.dbchar(trs_no);
                        ColMap["branch"] = Util.dbchar(Sys.GetSession("seBranch"));
                        ColMap["seq"] = Util.dbnull(tseq);
                        ColMap["seq1"] = Util.dbchar(tseq1);
                        ColMap["step_grade"] = Util.dbchar(blstep_grade);
                        ColMap["ctrl_type"] = Util.dbchar(ctrl_type);
                        ColMap["ctrl_date"] = Util.dbnull(ctrl_date);
                        ColMap["tran_date"] = "getdate()";
                        ColMap["tran_scode"] = "'" + Session["scode"] + "'";
                        SQL += ColMap.GetInsertSQL();
                        conn.ExecuteNonQuery(SQL);
                    }
                    //案件主檔進度序號加一
                    SQL = "update dmt set step_grade=step_grade+1  where seq=" + tseq + " and seq1='" + tseq1 + "'";
                    conn.ExecuteNonQuery(SQL);
                    //爭救案發文確認
                    SQL = "Update bstep_temp Set Mark='Y'";
                    SQL += ",confirm_date=getdate()";
                    SQL += ",confirm_scode='" + Session["scode"] + "'";
                    SQL += " where rs_no='" + trs_no + "' and opt_sqlno='" + opt_sqlno + "'";
                    conn.ExecuteNonQuery(SQL);
                    //有上傳文件新增至區所上傳文件檔
                    if (arr_opt_attach_flag[i] == "Y") {
                        SQL = "insert into dmt_attach (seq,seq1,step_grade,source,in_date,in_scode,attach_no,attach_path";
                        SQL += ",doc_type,attach_desc,attach_name,source_name,attach_size,attach_flag,mark,tran_date,tran_scode) ";
                        SQL += "select seq,seq1," + blstep_grade + ",source,in_date,in_scode,attach_no,attach_path";
                        SQL += ",doc_type,attach_desc,attach_name,source_name,attach_size,attach_flag,mark,getdate(),'" + Session["scode"] + "' ";
                        SQL += " from bdmt_attach_temp where seq=" + tseq + " and seq1='" + tseq1 + "' and rs_no='" + trs_no + "' and attach_flag<>'D' and into_status='NN' and source='OPT' ";
                        conn.ExecuteNonQuery(SQL);
                        SQL = "update bdmt_attach_temp set into_date=getdate(),into_scode='" + Session["scode"] + "',into_status='YY'";
                        SQL += " where seq=" + tseq + " and seq1='" + tseq1 + "' and rs_no='" + trs_no + "' and attach_flag<>'D' and into_status='NN' and source='OPT' ";
                        conn.ExecuteNonQuery(SQL);
                    }
                }

                //規費資料寫入帳款系統
                string tdate = DateTime.Today.ToString("MM/dd/yyyy");
                string step_date = Util.str2Dateime(arr_step_date[i]).ToString("MM/dd/yyyy");

                SQL = "select a.case_no,a.fees,a.service,isnull(a.gs_curr,0) as gs_curr,(select arcase from case_dmt where case_no=a.case_no) as case_arcase";
                SQL += ",(select ar_mark from case_dmt where case_no=a.case_no) as ar_mark";
                SQL += ",isnull((select oth_money from case_dmt where case_no=a.case_no),0) as oth_money";
                SQL += ",b.rs_agt_no,b.mp_date,(select agt_name from agt where agt_no=b.rs_agt_no) as rs_agt_name";
                SQL += ",isnull((select treceipt from agt where agt_no=b.rs_agt_no),'F') as rs_agt_company";
                SQL += " from fees_dmt a inner join step_dmt b on a.rs_no=b.rs_no where a.rs_no='" + trs_no + "'";
                DataTable dtFees = new DataTable();
                conn.DataTable(SQL, dtFees);

                if (dtFees.Rows.Count > 0) {
                    //2012/12/18因電子申請的mstat_flag=YE，狀況等同一般送件mstat_flag=YY，所以增加判斷
                    SQL = "select count(*) from plus_temp where branch='" + Session["seBranch"] + "' and dept='" + Session["dept"] + "'";
                    SQL += " and rs_no='" + trs_no + "' and (chk_type='Y' or mstat_flag='YY' or mstat_flag='YE')";
                    objResult = conni2.ExecuteScalar(SQL);
                    int plus_cnt = (objResult == DBNull.Value || objResult == null) ? 0 : Convert.ToInt32(objResult);
                    if (plus_cnt == 0) {
                        Sys.insert_log_table(conni2, "D", prgid, "plus_temp", "branch;dept;rs_no;chk_type", Session["seBranch"] + ";" + Session["dept"] + ";" + trs_no + ";N", logReason);
                        SQL = "delete from plus_temp where branch='" + Session["seBranch"] + "' and dept='" + Session["dept"] + "'";
                        SQL += " and rs_no='" + trs_no + "' and chk_type='N' and (mstat_flag='NN' or mstat_flag is null)";
                        conni2.ExecuteNonQuery(SQL);
                    }

                    //抓取案件申請人資料
                    SQL = "select a.apcust_no,a.ap_cname,(select apclass from apcust where apsqlno=a.apsqlno) as apclass ";
                    SQL += "from dmt_temp_ap a inner join case_dmt b on a.in_no=b.in_no where a.case_sqlno=0 and b.case_no='" + dtFees.Rows[0]["case_no"] + "'";
                    DataTable dtAP = new DataTable();
                    conn.DataTable(SQL, dtAP);
                    string fapclass = "";	//第一位申請人種類
                    string fapcust_num = "";//第一位申請人號碼
                    string fap_cname = "";//第一位申請人名稱
                    string strapcust_num = "";
                    string strapcust_no = "";
                    string strap_cname = "";
                    int ap_num = dtAP.Rows.Count;
                    if (ap_num > 0) {
                        fapclass = dtAP.Rows[0].SafeRead("apclass", "").Trim();
                        fapcust_num = dtAP.Rows[0].SafeRead("apcust_no", "").Trim();
                        fap_cname = dtAP.Rows[0].SafeRead("ap_cname", "").Trim();
                        strapcust_num = dtAP.ConcatColumn("apcust_no", ",");
                        strapcust_no = strapcust_num;
                        strap_cname = dtAP.ConcatColumn("ap_cname", ",");
                    }

                    for (int f = 0; f < dtFees.Rows.Count; f++) {
                        if (Convert.ToInt32(dtFees.Rows[f].SafeRead("fees", "0")) > 0) {
                            if (plus_cnt == 0) {
                                string mstat_flag = "YY";
                                if (gs_send_way == "E") mstat_flag = "YE";
                                //2014/11/5修改，因改至網路account，所以tdate=date,step_date=request("step_date"&i)改為yyyy/mm/dd
                                SQL = "insert into plus_temp(class,tr_date,tr_scode,send_date,branch,dept";
                                SQL += ",case_no,rs_no,seq,seq1,country,cust_seq,scode,case_arcase";
                                SQL += ",arcase,ar_mark,tr_money,chk_type,chk_date,mstat_flag,mtr_money,mstat_date) values(";
                                SQL += "'1','" + DateTime.Today.ToString("yyyy/M/d") + "','" + Session["scode"] + "','" + arr_step_date[i] + "','" + Session["seBranch"] + "'";
                                SQL += ",'" + Session["dept"] + "','" + dtFees.Rows[f]["case_no"] + "','" + trs_no + "'";
                                SQL += "," + tseq + ",'" + tseq1 + "','T'," + arr_cust_seq[i] + "";
                                SQL += ",'" + arr_dmt_scode[i] + "'," + Util.dbchar(dtFees.Rows[f].SafeRead("case_arcase", ""));
                                SQL += ",'" + arr_rs_code[i] + "','" + dtFees.Rows[f]["ar_mark"] + "'," + dtFees.Rows[f]["fees"] + ",'N',null,'" + mstat_flag + "'";
                                SQL += "," + dtFees.Rows[f]["fees"] + ",'" + dtFees.Rows[f].GetDateTimeString("mp_date", "yyyy/M/d") + "')";//2015/1/13mstat_date改抓總收發文日
                                conni2.ExecuteNonQuery(SQL);
                            }
                        }
                        //2011/10/26官發收入寫入智產會計系統,2017/12/11修改，改入網路不用入流水號
                        //入iacct_gsin
                        int service = Convert.ToInt32(dtFees.Rows[f].SafeRead("service", "0"));
                        if (service > 0) service = Convert.ToInt32(dtFees.Rows[f].SafeRead("service", "0")) + Convert.ToInt32(dtFees.Rows[f].SafeRead("oth_money", "0"));//依官發收入明細表，第一次官發服務費+轉帳
                        SQL = "insert into iacct_gsin(prgid,branch,dept,send_date,tax_yy,tax_mm,rs_sqlno,seq,seq1,country,appl_name,cust_area,cust_seq,apcust_type,apcust_num,apcust_no,ap_cname";
                        SQL += ",service,rs_detail,agt_company,agt_no,agt_name,case_no,in_date,in_scode,seq_chk,tax_chk,tran_date,tran_scode,fapclass,fapcust_num,fap_cname,apcust_no1,nservice";
                        SQL += ",send_service,send_fees,send_curr,rs_type,rs_class,rs_code,act_code,acc_chk,diff_money) values (";
                        SQL += "'" + prgid + "','" + Session["seBranch"] + "','" + Session["dept"] + "','" + step_date + "'," + Util.str2Dateime(arr_step_date[i]).Year;
                        SQL += "," + Util.str2Dateime(arr_step_date[i]).Month + "," + trs_sqlno + "," + tseq + ",'" + tseq1 + "','T'," + Util.dbchar(tappl_name);
                        SQL += ",'" + Session["seBranch"] + "'," + tcust_seq + ",'B','" + strapcust_num + "','" + strapcust_no + "'," + Util.dbchar(strap_cname) + "," + service;
                        SQL += "," + Util.dbchar(trs_detail) + ",'" + dtFees.Rows[f].SafeRead("rs_agt_company", "") + "','" + dtFees.Rows[f].SafeRead("rs_agt_no", "") + "'";
                        SQL += "," + Util.dbchar(dtFees.Rows[f].SafeRead("rs_agt_name", "")) + ",'" + dtFees.Rows[f].SafeRead("case_no", "") + "','" + tdate + "','" + Session["scode"] + "','NN','NN','" + tdate + "'";
                        SQL += ",'" + Session["scode"] + "','" + fapclass + "','" + fapcust_num + "'," + Util.dbchar(fap_cname) + ",'" + fapcust_num + "'," + service + "," + service + "," + dtFees.Rows[f].SafeRead("fees", "") + "," + dtFees.Rows[f].SafeRead("gs_curr", "");
                        SQL += ",'" + arr_rs_type[i] + "','" + arr_rs_class[i] + "','" + arr_rs_code[i] + "','" + arr_act_code[i] + "','NN',0)";
                        conniacc.ExecuteNonQuery(SQL);
                        //抓insert後的流水號
                        SQL = "SELECT SCOPE_IDENTITY() AS Current_Identity";
                        objResult = conniacc.ExecuteScalar(SQL);
                        string tigsin_sqlno = objResult.ToString();
                        Sys.showLog("tigsin_sqlno=" + tigsin_sqlno);

                        //入iacct_gsinap
                        if (ap_num == 1) {
                            SQL = "insert into iacct_gsinap(igsin_sqlno,branch,dept,rs_sqlno,apcust_type,apcust_num,apcust_no,ap_cname,in_date,in_scode,tran_date,tran_scode) values (";
                            SQL += tigsin_sqlno + ",'" + Session["seBranch"] + "','" + Session["dept"] + "'," + trs_sqlno + ",'B','" + strapcust_num + "','" + strapcust_no + "'";
                            SQL += "," + Util.dbchar(strap_cname) + ",'" + tdate + "','" + Session["scode"] + "','" + tdate + "','" + Session["scode"] + "')";
                            conniacc.ExecuteNonQuery(SQL);
                        } else {
                            SQL = "select a.apcust_no,a.ap_cname from dmt_temp_ap a inner join case_dmt b on a.in_no=b.in_no where a.case_sqlno=0 and b.case_no='" + dtFees.Rows[f]["case_no"] + "'";
                            DataTable dtAP1 = new DataTable();
                            for (int p = 0; p < dtAP1.Rows.Count; p++) {
                                SQL = "insert into iacct_gsinap(igsin_sqlno,branch,dept,rs_sqlno,apcust_type,apcust_num,apcust_no,ap_cname,in_date,in_scode,tran_date,tran_scode) values (";
                                SQL += "" + tigsin_sqlno + ",'" + Session["seBranch"] + "','" + Session["dept"] + "'," + trs_sqlno + ",'B','" + dtAP1.Rows[p]["apcust_no"] + "'";
                                SQL += ",'" + dtAP1.Rows[p]["apcust_no"] + "'," + Util.dbchar(dtAP1.Rows[p].SafeRead("ap_cname", "")) + ",'" + tdate + "','" + Session["scode"] + "','" + tdate + "','" + Session["scode"] + "')";
                                conniacc.ExecuteNonQuery(SQL);
                            }
                        }
                    }
                }

                //2008/11/13因增加營洽官收確認作業，所以等營洽確認後再產生客發
                //2008/11/27李協理回覆程序官收確認即產生客發
                //判斷是否需客戶報導 , 若需客戶報導則需新增一筆客發
                string cs_rs_no = "";
                if (arr_radcs[i] == "Y") {
                    //先取得客發序號. 新增完官收後再新增客發
                    cs_rs_no = Sys.getRsNo(conn, "CS");
                }
                //收文序號
                string rs_no = Sys.getRsNo(conn, "GR");

                //取得案件進度
                string lstep_grade = "1";
                SQL = "select step_grade from dmt where seq= '" + tseq + "' and seq1 = '" + tseq1 + "'";
                objResult = conn.ExecuteScalar(SQL);
                lstep_grade = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();
                if (lstep_grade == "") {
                    lstep_grade = "1";
                    throw new Exception("案件進度有問題, 請洽系統維護人員!!");
                } else {
                    lstep_grade = (Convert.ToInt32(lstep_grade) + 1).ToString();
                    SQL = "select step_grade from dmt where seq= '" + tseq + "' and seq1 = '" + tseq1 + "' and step_grade = " + lstep_grade;
                    objResult = conn.ExecuteScalar(SQL);
                    if (objResult != DBNull.Value && objResult != null) {
                        throw new Exception("案件進度有問題, 請洽系統維護人員!!");
                    }
                }
                //取得官收內容及狀態、客發代碼
                string act_sqlno = "", now_case_stat = "", rs_detail = "", csflg = "N", cs_detail = "", csact_code = "U1", lctrl_date = "";//客函法定期限
                SQL = "select sqlno,rs_detail, act_code_name,case_stat,csflg,cs_detail,csact_code";
                SQL += " from vcode_act a where a.dept='T' ";
                SQL += " and cg='G' and rs='R' and gr='Y' ";
                SQL += " and rs_code='" + arr_rs_code[i] + "'";
                SQL += " and act_code='U1' ";
                using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
                    if (dr.Read()) {
                        act_sqlno = dr.SafeRead("sqlno", "");
                        rs_detail = dr.SafeRead("rs_detail", "") + dr.SafeRead("act_code_name", "");
                        now_case_stat = dr.SafeRead("case_stat", "");
                        csflg = dr.SafeRead("csflg", "");
                        cs_detail = dr.SafeRead("cs_detail", "");
                        csact_code = dr.SafeRead("csact_code", "");
                    }
                }
                //官收入step_dmt
                SQL = "insert into step_dmt ";
                ColMap.Clear();
                ColMap["rs_no"] = Util.dbchar(rs_no);
                ColMap["branch"] = Util.dbchar(Sys.GetSession("seBranch"));
                ColMap["seq"] = Util.dbnull(tseq);
                ColMap["seq1"] = Util.dbchar(tseq1);
                ColMap["step_grade"] = Util.dbnull(lstep_grade);
                ColMap["main_rs_no"] = Util.dbchar(rs_no);
                ColMap["step_date"] = Util.dbchar(DateTime.Today.ToString("yyyy/M/d"));
                ColMap["mp_date"] = Util.dbnull(arr_gr_mp_date[i]);
                ColMap["cg"] = Util.dbchar("G");
                ColMap["rs"] = Util.dbchar("R");
                ColMap["send_cl"] = Util.dbnull("1");
                ColMap["rs_type"] = Util.dbnull(arr_rs_type[i]);
                ColMap["rs_class"] = Util.dbchar(arr_rs_class[i]);
                ColMap["rs_code"] = Util.dbchar(arr_rs_code[i]);
                ColMap["act_code"] = Util.dbchar("U1");
                ColMap["rs_detail"] = Util.dbnull(rs_detail);
                ColMap["cs_rs_no"] = Util.dbnull(cs_rs_no);
                ColMap["pr_status"] = Util.dbnull("X");
                ColMap["new"] = Util.dbchar("N");
                ColMap["tot_num"] = Util.dbzero("1");
                ColMap["pr_scan"] = Util.dbnull(arr_radscan[i]);
                ColMap["tran_date"] = "getdate()";
                ColMap["tran_scode"] = "'" + Session["scode"] + "'";
                ColMap["csd_flag"] = Util.dbchar(arr_chkcsd_flag[i]);
                ColMap["cs_remark"] = Util.dbchar(arr_cs_remark[i]);
                ColMap["pmail_date"] = Util.dbnull(arr_pmail_date[i]);
                SQL += ColMap.GetInsertSQL();
                conn.ExecuteNonQuery(SQL);
                //抓insert後的流水號
                SQL = "SELECT SCOPE_IDENTITY() AS Current_Identity";
                objResult = conn.ExecuteScalar(SQL);
                string Getrs_sqlno = objResult.ToString();
                Sys.showLog("官收進度流水號=" + Getrs_sqlno);

                //若官收有管制期限要入ctrl_dmt
                if (act_sqlno != "") {
                    SQL = "select ctrl_type,(select mark1 from cust_code where code_type='DC' and cust_code=a.date_ctrl) as date_name";
                    SQL += ",ad,days,md,ad2,isnull(days2,0) as days2,md2";
                    SQL += " from code_ctrl a where act_sqlno=" + act_sqlno;
                    DataTable dtCtrl = new DataTable();
                    conn.DataTable(SQL, dtCtrl);
                    for (int c = 0; c < dtCtrl.Rows.Count; c++) {
                        string ctrl_type = dtCtrl.Rows[c].SafeRead("ctrl_type", "");//管制種類
                        string ad = dtCtrl.Rows[c].SafeRead("ad", "");//運算公式:A:加，D:減 
                        int days = Convert.ToInt32(dtCtrl.Rows[c].SafeRead("days", "0"));//管制天數
                        string md = dtCtrl.Rows[c].SafeRead("md", "").ToUpper();//管制性質
                        string ad2 = dtCtrl.Rows[c].SafeRead("ad2", "");//運算公式:A:加，D:減 
                        int days2 = Convert.ToInt32(dtCtrl.Rows[c].SafeRead("days2", "0"));//管制天數
                        string md2 = dtCtrl.Rows[c].SafeRead("md2", "").ToUpper();//管制性質
                        if (ad != "A") {
                            days = -days;
                        }
                        if (ad2 != "A") {
                            days2 = -days2;
                        }

                        string date_ctrl = ReqVal.TryGet(dtCtrl.Rows[c].SafeRead("date_name", ""));//日期基礎
                        string ctrl_date = "";
                        if (date_ctrl != "") {
                            switch (md) {
                                case "D":
                                    ctrl_date = Util.str2Dateime(date_ctrl).AddDays(days).ToString("yyyy/M/d"); break;
                                case "M":
                                    ctrl_date = Util.str2Dateime(date_ctrl).AddMonths(days).ToString("yyyy/M/d"); break;
                                case "Y":
                                    ctrl_date = Util.str2Dateime(date_ctrl).AddYears(days).ToString("yyyy/M/d"); break;
                            }
                            if (ctrl_date != "" && ctrl_type != "") {
                                //取得客函法定期限,11/27修改,2009/9/14管制種類抓取A*但A2除外
                                if (arr_radcs[i] == "Y") {
                                    if (ctrl_type.Left(1) == "A" && ctrl_type != "A2" && lctrl_date == "") {
                                        lctrl_date = ctrl_date;
                                    }
                                } else {
                                    lctrl_date = "";
                                }
                                SQL = "insert into ctrl_dmt ";
                                ColMap.Clear();
                                ColMap["rs_no"] = Util.dbchar(rs_no);
                                ColMap["branch"] = Util.dbchar(Sys.GetSession("seBranch"));
                                ColMap["seq"] = Util.dbnull(tseq);
                                ColMap["seq1"] = Util.dbchar(tseq1);
                                ColMap["step_grade"] = Util.dbchar(lstep_grade);
                                ColMap["ctrl_type"] = Util.dbchar(ctrl_type);
                                ColMap["ctrl_date"] = Util.dbnull(ctrl_date);
                                ColMap["tran_date"] = "getdate()";
                                ColMap["tran_scode"] = "'" + Session["scode"] + "'";
                                SQL += ColMap.GetInsertSQL();
                                conn.ExecuteNonQuery(SQL);
                            }
                            if (ad2 != "") {
                                switch (md2) {
                                    case "D":
                                        ctrl_date = Util.str2Dateime(ctrl_date).AddDays(days2).ToString("yyyy/M/d"); break;
                                    case "M":
                                        ctrl_date = Util.str2Dateime(ctrl_date).AddMonths(days2).ToString("yyyy/M/d"); break;
                                    case "Y":
                                        ctrl_date = Util.str2Dateime(ctrl_date).AddYears(days2).ToString("yyyy/M/d"); break;
                                }
                                if (ctrl_date != "" && ctrl_type != "") {
                                    SQL = "insert into ctrl_dmt ";
                                    ColMap.Clear();
                                    ColMap["rs_no"] = Util.dbchar(rs_no);
                                    ColMap["branch"] = Util.dbchar(Sys.GetSession("seBranch"));
                                    ColMap["seq"] = Util.dbnull(tseq);
                                    ColMap["seq1"] = Util.dbchar(tseq1);
                                    ColMap["step_grade"] = Util.dbchar(lstep_grade);
                                    ColMap["ctrl_type"] = Util.dbchar(ctrl_type);
                                    ColMap["ctrl_date"] = Util.dbnull(ctrl_date);
                                    ColMap["tran_date"] = "getdate()";
                                    ColMap["tran_scode"] = "'" + Session["scode"] + "'";
                                    SQL += ColMap.GetInsertSQL();
                                    conn.ExecuteNonQuery(SQL);
                                }
                            }
                        }
                    }
                }
                //案件主檔進度序號加一 & 相關欄位 Update
                Sys.insert_log_table(conn, "U", prgid, "dmt", "seq;seq1", tseq + ";" + tseq1, logReason);
                SQL = "update dmt set step_grade=step_grade+1 ";
                SQL += ",apply_date = " + Util.dbnull(arr_apply_date[i]);
                SQL += ",apply_no = " + Util.dbnull(arr_apply_no[i]);
                if (now_case_stat != "" && now_case_stat != "") {
                    SQL += ",now_arcase_type = " + Util.dbnull(arr_rs_type[i]);
                    SQL += ",now_arcase = " + Util.dbnull(arr_rs_code[i]);
                    SQL += ",now_stat = " + Util.dbnull(now_case_stat);
                    SQL += ",now_grade = " + Util.dbnull(lstep_grade);
                }
                SQL += " where seq=" + tseq + " and seq1='" + tseq1 + "'";
                conn.ExecuteNonQuery(SQL);
                //2008/11/13因增加營洽官收確認作業，所以等營洽確認後再產生客發
                //2008/11/27李協理回覆程序官收確認即產生客發
                //新增客發紀錄
                if (cs_rs_no != "") {
                    SQL = "insert into cs_dmt(rs_no,step_date,rs_type,rs_class,rs_code,act_code,rs_detail,last_date,send_way,tran_date,tran_scode)";
                    SQL += " values('" + cs_rs_no + "','" + DateTime.Today.ToString("yyyy/M/d") + "'," + Util.dbnull(arr_rs_type[i]);
                    SQL += "," + Util.dbchar(arr_rs_class[i]) + "," + Util.dbchar(arr_rs_code[i]);
                    SQL += ",'" + csact_code + "'," + Util.dbnull(cs_detail) + "," + Util.dbnull(lctrl_date);
                    SQL += "," + Util.dbnull(arr_send_way[i]) + ",getdate(),'" + Session["scode"] + "')";
                    conn.ExecuteNonQuery(SQL);
                    
                    SQL = "insert into csd_dmt(rs_no,branch,seq,seq1,cust_seq,att_sql)";
                    SQL += "values('" + cs_rs_no + "','" + Session["seBranch"] + "'," + tseq + ",'" + tseq1 + "'";
                    SQL += "," + Util.dbnull(arr_cust_seq[i]) + "," + Util.dbnull(arr_att_sql[i]) + ")";
                    conn.ExecuteNonQuery(SQL);
                }

                //2008/11/13因增加營洽官收確認作業，所以新增營洽官收確認紀錄檔及todo_dmt
                SQL = "insert into grconf_dmt(seq,seq1,step_grade,rs_sqlno,from_flag,cs_flag,cs_send_way,scs_detail,last_date,cs_rs_no,csd_flag,csd_remark,pstep_date) values (";
                SQL += tseq + ",'" + tseq1 + "'," + lstep_grade + "," + Getrs_sqlno;
                SQL += ",'E','" + arr_radcs[i] + "'," + Util.dbnull(arr_send_way[i]) + "," + Util.dbnull(cs_detail) + "," + Util.dbnull(lctrl_date);
                SQL += "," + Util.dbnull(cs_rs_no) + ",'" + arr_chkcsd_flag[i] + "'," + Util.dbchar(arr_cs_remark[i]) + "," + Util.dbnull(arr_pmail_date[i]) + ")";
                conn.ExecuteNonQuery(SQL);
                //抓insert後的流水號
                SQL = "SELECT SCOPE_IDENTITY() AS Current_Identity";
                objResult = conn.ExecuteScalar(SQL);
                string Getgrconf_sqlno = objResult.ToString();
                Sys.showLog("Getgrconf_sqlno=" + Getgrconf_sqlno);

                //取得營洽及所屬組別
                string dmt_scode = "", grpid = "";
                SQL = "select a.scode,b.grpid from dmt a left outer join sysctrl.dbo.scode_group b on a.scode=b.scode and b.grpclass='" + Session["seBranch"] + "'";
                SQL += " where a.seq=" + tseq + " and a.seq1='" + tseq1 + "'";
                using (SqlDataReader dr0 = conn.ExecuteReader(SQL)) {
                    if (dr0.Read()) {
                        dmt_scode = dr0.SafeRead("scode", "");
                        grpid = dr0.SafeRead("grpid", "");
                    }
                }
                SQL = "insert into todo_dmt(syscode,apcode,temp_rs_sqlno,seq,seq1,step_grade,in_date,in_scode,dowhat,job_scode,job_team,job_status) values (";
                SQL += "'" + Session["syscode"] + "','" + prgid + "'," + Util.dbnull(Getgrconf_sqlno) + "," + tseq + ",'" + tseq1 + "'";
                SQL += "," + lstep_grade + ",getdate(),'" + Session["scode"] + "','SALES_GR','" + dmt_scode + "','" + grpid + "','NN')";
                conn.ExecuteNonQuery(SQL);

                //20170731電子收據
                int attach_no = 0;
                if (arr_fees[i] != "0" && arr_receipt_type[i] == "E") {
                    SQL = "select a.*,isnull((select cust_code from cust_code where Code_type='Tdoc' and mark='M' and mark1=a.doc_type),'99') as br_doc_type from mgt_attach_temp a where temp_rs_sqlno=" + arr_temp_rs_sqlno[i] + " and source='EGS' and attach_flag<>'D' order by attach_sqlno ";
                    DataTable dtEdoc = new DataTable();
                    conn.DataTable(SQL, dtEdoc);
                    for (int c = 0; c < dtEdoc.Rows.Count; c++) {
                        DataRow dr0 = dtEdoc.Rows[c];
                        attach_no++;
                        string attach_path = dr0.SafeRead("attach_path", "").Replace("/MG", "/btbrt");
                        SQL = "insert into dmt_attach ";
                        ColMap.Clear();
                        ColMap["Seq"] = Util.dbchar(tseq);
                        ColMap["seq1"] = Util.dbchar(tseq1);
                        ColMap["step_grade"] = Util.dbchar(lstep_grade);
                        ColMap["Source"] = Util.dbchar("EGS");
                        ColMap["in_date"] = "getdate()";
                        ColMap["in_scode"] = "'" + Session["scode"] + "'";
                        ColMap["Attach_no"] = Util.dbchar(attach_no.ToString());
                        ColMap["attach_path"] = Util.dbchar(attach_path);
                        ColMap["doc_type"] = Util.dbchar(dr0.SafeRead("br_doc_type", ""));
                        ColMap["attach_desc"] = Util.dbnull(dr0.SafeRead("attach_desc", ""));
                        ColMap["Attach_name"] = Util.dbnull(dr0.SafeRead("attach_name", ""));
                        ColMap["source_name"] = Util.dbnull(dr0.SafeRead("attach_name", ""));
                        ColMap["attach_flag"] = Util.dbchar("A");
                        ColMap["Mark"] = Util.dbchar("");
                        ColMap["tran_date"] = "getdate()";
                        ColMap["tran_scode"] = "'" + Session["scode"] + "'";
                        ColMap["att_sqlno"] = Util.dbchar(dr0.SafeRead("attach_sqlno", ""));
                        SQL += ColMap.GetInsertSQL();
                        conn.ExecuteNonQuery(SQL);
                    }
                }

                //2008/12/13有掃描要新增至文件紀錄檔dmt_attach及入todo_dmt
                //掃描文件命名規則branch+dept-seq(5)-seq1-step_grade(4)-attach_no(2).pdf
                if (arr_radscan[i] == "Y") {
                    attach_no++;
                    //string attach_name = Session["sebranch"] + Sys.GetSession("dept").ToUpper() + "-" + tseq.PadLeft(5, '0') + "-" + (tseq1 != "_" ? tseq1 : "") + "-" + lstep_grade.PadLeft(4, '0') + "-" + attach_no.ToString().PadLeft(2, '0') + ".pdf";//重新命名檔名
                    //string newattach_path = Sys.formatScanPathNo(tseq, tseq1, lstep_grade, attach_no.ToString());//存在資料庫路徑
                    //string source_name = attach_name;
                    string attach_path = "", attach_name = "";
                    Sys.formatScanPathNo(tseq, tseq1, lstep_grade, attach_no.ToString(), ref attach_path, ref attach_name);//存在資料庫路徑
                    string newattach_path = attach_path + attach_name;
                    string source_name = attach_name;

                    SQL = "insert into dmt_attach ";
                    ColMap.Clear();
                    ColMap["Seq"] = Util.dbchar(tseq);
                    ColMap["seq1"] = Util.dbchar(tseq1);
                    ColMap["step_grade"] = Util.dbchar(lstep_grade);
                    ColMap["Source"] = Util.dbchar("scan");
                    ColMap["in_date"] = "getdate()";
                    ColMap["in_scode"] = "'" + Session["scode"] + "'";
                    ColMap["Attach_no"] = Util.dbchar(attach_no.ToString());
                    ColMap["attach_path"] = Util.dbchar(Sys.Path2Btbrt(newattach_path));
                    ColMap["attach_desc"] = Util.dbnull("掃描文件");
                    ColMap["Attach_name"] = Util.dbnull(attach_name);
                    ColMap["source_name"] = Util.dbnull(source_name);
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
                    ColMap["seq"] = Util.dbnull(tseq);
                    ColMap["seq1"] = Util.dbchar(tseq1);
                    ColMap["step_grade"] = Util.dbzero(lstep_grade);
                    ColMap["in_date"] = "getdate()";
                    ColMap["in_scode"] = "'" + Session["scode"] + "'";
                    ColMap["dowhat"] = Util.dbchar("scan");//掃描確認,ref:cust_code.code_type='Ttodo'
                    ColMap["job_status"] = Util.dbchar("NN");
                    SQL += ColMap.GetInsertSQL();
                    conn.ExecuteNonQuery(SQL);
                }

                //官發進度之總收發文進度及序號
                SQL = "update step_dmt set mg_step_grade=" + arr_mg_step_grade[i] + ",mg_rs_sqlno=" + Util.dbnull(arr_mg_rs_sqlno[i]);
                SQL += " where rs_no='" + trs_no + "'";
                conn.ExecuteNonQuery(SQL);

                //暫存檔及流程檔之狀態更新
                SQL = "update step_mgt_temp set into_date=getdate(),into_scode='" + Session["scode"] + "'";
                SQL += " where temp_rs_sqlno=" + arr_temp_rs_sqlno[i];
                conn.ExecuteNonQuery(SQL);
                SQL = "update todo_dmt set job_status='YY',approve_scode='" + Session["scode"] + "',resp_date=getdate() ";
                SQL += " where temp_rs_sqlno=" + arr_temp_rs_sqlno[i] + " and dowhat='GS' and job_status='NN' ";
                conn.ExecuteNonQuery(SQL);

                //總收發文之單位官發回條確認日期寫回
                SQL = "update send_mgt set br_sconf_date=getdate(),br_sconf_scode='" + Session["scode"] + "'";
                SQL += " where seq_area='" + Session["seBranch"] + "' and rs_no='" + trs_no + "'";
                connm.ExecuteNonQuery(SQL);

                //有子案之官收進度處理
                if (arr_child_flag[i] == "Y") {
                    for (int j = 1; j <= Convert.ToInt32("0" + arr_mchknum[i]); j++) {
                        string dseq = ReqVal.TryGet("seq_" + i + "_" + j);
                        string dseq1 = ReqVal.TryGet("seq1_" + i + "_" + j);
                        string dgs_rs_no = ReqVal.TryGet("rs_no_" + i + "_" + j);
                        //2008/11/13因增加營洽官收確認作業，所以等營洽確認後再產生客發
                        //2008/11/27李協理回覆程序官收確認即產生客發
                        //判斷是否需客戶報導 , 若需客戶報導則需新增一筆客發
                        string dcs_rs_no = "";
                        if (arr_radcs[i] == "Y") {
                            dcs_rs_no = Sys.getRsNo(conn, "CS");
                        }
                        //收文序號
                        string drs_no = Sys.getRsNo(conn, "GR");
                        //取得案件進度
                        string dlstep_grade = "1";
                        SQL = "select step_grade from dmt where seq= '" + dseq + "' and seq1 = '" + dseq1 + "'";
                        objResult = conn.ExecuteScalar(SQL);
                        dlstep_grade = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();
                        if (dlstep_grade == "") {
                            dlstep_grade = "1";
                            throw new Exception("案件進度有問題, 請洽系統維護人員!!");
                        } else {
                            dlstep_grade = (Convert.ToInt32(dlstep_grade) + 1).ToString();
                            SQL = "select step_grade from dmt where seq= '" + dseq + "' and seq1 = '" + dseq1 + "' and step_grade = " + dlstep_grade;
                            objResult = conn.ExecuteScalar(SQL);
                            if (objResult != DBNull.Value && objResult != null) {
                                throw new Exception("案件進度有問題, 請洽系統維護人員!!");
                            }
                        }
                        //取得官收內容及狀態、客發代碼
                        string dact_sqlno = "", dnow_case_stat = "", drs_detail = "", dcsflg = "N", dcs_detail = "", dcsact_code = "U1", dlctrl_date = "";//客函法定期限
                        SQL = "select sqlno,rs_detail, act_code_name,case_stat,csflg,cs_detail,csact_code";
                        SQL += " from vcode_act a where a.dept='T' ";
                        SQL += " and cg='G' and rs='R' and gr='Y' ";
                        SQL += " and rs_code='" + arr_rs_code[i] + "'";
                        SQL += " and act_code='U1' ";
                        using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
                            if (dr.Read()) {
                                dact_sqlno = dr.SafeRead("sqlno", "");
                                drs_detail = dr.SafeRead("rs_detail", "") + dr.SafeRead("act_code_name", "");
                                dnow_case_stat = dr.SafeRead("case_stat", "");
                                dcsflg = dr.SafeRead("csflg", "");
                                dcs_detail = dr.SafeRead("cs_detail", "");
                                dcsact_code = dr.SafeRead("csact_code", "");
                            }
                        }
                        //官收入step_dmt
                        SQL = "insert into step_dmt ";
                        ColMap.Clear();
                        ColMap["rs_no"] = Util.dbchar(drs_no);
                        ColMap["branch"] = Util.dbchar(Sys.GetSession("seBranch"));
                        ColMap["seq"] = Util.dbnull(dseq);
                        ColMap["seq1"] = Util.dbchar(dseq1);
                        ColMap["step_grade"] = Util.dbnull(dlstep_grade);
                        ColMap["main_rs_no"] = Util.dbchar(drs_no);
                        ColMap["step_date"] = Util.dbchar(DateTime.Today.ToString("yyyy/M/d"));
                        ColMap["mp_date"] = Util.dbnull(arr_gr_mp_date[i]);
                        ColMap["cg"] = Util.dbchar("G");
                        ColMap["rs"] = Util.dbchar("R");
                        ColMap["send_cl"] = Util.dbnull("1");
                        ColMap["rs_type"] = Util.dbnull(arr_rs_type[i]);
                        ColMap["rs_class"] = Util.dbchar(arr_rs_class[i]);
                        ColMap["rs_code"] = Util.dbchar(arr_rs_code[i]);
                        ColMap["act_code"] = Util.dbchar("U1");
                        ColMap["rs_detail"] = Util.dbnull(drs_detail);
                        ColMap["cs_rs_no"] = Util.dbnull(dcs_rs_no);
                        ColMap["pr_status"] = Util.dbnull("X");
                        ColMap["new"] = Util.dbchar("N");
                        ColMap["tot_num"] = Util.dbzero("1");
                        ColMap["pr_scan"] = Util.dbnull(arr_radscan[i]);
                        ColMap["tran_date"] = "getdate()";
                        ColMap["tran_scode"] = "'" + Session["scode"] + "'";
                        ColMap["csd_flag"] = Util.dbchar(arr_chkcsd_flag[i]);
                        ColMap["cs_remark"] = Util.dbchar(arr_cs_remark[i]);
                        ColMap["pmail_date"] = Util.dbnull(arr_pmail_date[i]);
                        SQL += ColMap.GetInsertSQL();
                        conn.ExecuteNonQuery(SQL);
                        //抓insert後的流水號
                        SQL = "SELECT SCOPE_IDENTITY() AS Current_Identity";
                        objResult = conn.ExecuteScalar(SQL);
                        string dGetrs_sqlno = objResult.ToString();
                        Sys.showLog("官收進度流水號=" + dGetrs_sqlno);

                        //若官收有管制期限要入ctrl_dmt
                        if (dact_sqlno != "") {
                            SQL = "select ctrl_type,(select mark1 from cust_code where code_type='DC' and cust_code=a.date_ctrl) as date_name";
                            SQL += ",ad,days,md,ad2,isnull(days2,0) as days2,md2";
                            SQL += " from code_ctrl a where act_sqlno=" + dact_sqlno;
                            DataTable dtCtrl = new DataTable();
                            conn.DataTable(SQL, dtCtrl);
                            for (int c = 0; c < dtCtrl.Rows.Count; c++) {
                                string ctrl_type = dtCtrl.Rows[c].SafeRead("ctrl_type", "");//管制種類
                                string ad = dtCtrl.Rows[c].SafeRead("ad", "");//運算公式:A:加，D:減 
                                int days = Convert.ToInt32(dtCtrl.Rows[c].SafeRead("days", "0"));//管制天數
                                string md = dtCtrl.Rows[c].SafeRead("md", "").ToUpper();//管制性質
                                string ad2 = dtCtrl.Rows[c].SafeRead("ad2", "");//運算公式:A:加，D:減 
                                int days2 = Convert.ToInt32(dtCtrl.Rows[c].SafeRead("days2", "0"));//管制天數
                                string md2 = dtCtrl.Rows[c].SafeRead("md2", "").ToUpper();//管制性質
                                if (ad != "A") {
                                    days = -days;
                                }
                                if (ad2 != "A") {
                                    days2 = -days2;
                                }

                                string date_ctrl = ReqVal.TryGet(dtCtrl.Rows[c].SafeRead("date_name", ""));//日期基礎
                                string ctrl_date = "";
                                if (date_ctrl != "") {
                                    switch (md) {
                                        case "D":
                                            ctrl_date = Util.str2Dateime(date_ctrl).AddDays(days).ToString("yyyy/M/d"); break;
                                        case "M":
                                            ctrl_date = Util.str2Dateime(date_ctrl).AddMonths(days).ToString("yyyy/M/d"); break;
                                        case "Y":
                                            ctrl_date = Util.str2Dateime(date_ctrl).AddYears(days).ToString("yyyy/M/d"); break;
                                    }
                                    if (ctrl_date != "" && ctrl_type != "") {
                                        //取得客函法定期限,11/27修改,2009/9/14管制種類抓取A*但A2除外
                                        if (arr_radcs[i] == "Y") {
                                            if (ctrl_type.Left(1) == "A" && ctrl_type != "A2" && lctrl_date == "") {
                                                lctrl_date = ctrl_date;
                                            }
                                        } else {
                                            lctrl_date = "";
                                        }
                                        SQL = "insert into ctrl_dmt ";
                                        ColMap.Clear();
                                        ColMap["rs_no"] = Util.dbchar(drs_no);
                                        ColMap["branch"] = Util.dbchar(Sys.GetSession("seBranch"));
                                        ColMap["seq"] = Util.dbnull(dseq);
                                        ColMap["seq1"] = Util.dbchar(dseq1);
                                        ColMap["step_grade"] = Util.dbchar(dlstep_grade);
                                        ColMap["ctrl_type"] = Util.dbchar(ctrl_type);
                                        ColMap["ctrl_date"] = Util.dbnull(ctrl_date);
                                        ColMap["tran_date"] = "getdate()";
                                        ColMap["tran_scode"] = "'" + Session["scode"] + "'";
                                        SQL += ColMap.GetInsertSQL();
                                        conn.ExecuteNonQuery(SQL);
                                    }
                                    if (ad2 != "") {
                                        switch (md2) {
                                            case "D":
                                                ctrl_date = Util.str2Dateime(ctrl_date).AddDays(days2).ToString("yyyy/M/d"); break;
                                            case "M":
                                                ctrl_date = Util.str2Dateime(ctrl_date).AddMonths(days2).ToString("yyyy/M/d"); break;
                                            case "Y":
                                                ctrl_date = Util.str2Dateime(ctrl_date).AddYears(days2).ToString("yyyy/M/d"); break;
                                        }
                                        if (ctrl_date != "" && ctrl_type != "") {
                                            SQL = "insert into ctrl_dmt ";
                                            ColMap.Clear();
                                            ColMap["rs_no"] = Util.dbchar(drs_no);
                                            ColMap["branch"] = Util.dbchar(Sys.GetSession("seBranch"));
                                            ColMap["seq"] = Util.dbnull(dseq);
                                            ColMap["seq1"] = Util.dbchar(dseq1);
                                            ColMap["step_grade"] = Util.dbchar(dlstep_grade);
                                            ColMap["ctrl_type"] = Util.dbchar(ctrl_type);
                                            ColMap["ctrl_date"] = Util.dbnull(ctrl_date);
                                            ColMap["tran_date"] = "getdate()";
                                            ColMap["tran_scode"] = "'" + Session["scode"] + "'";
                                            SQL += ColMap.GetInsertSQL();
                                            conn.ExecuteNonQuery(SQL);
                                        }
                                    }
                                }
                            }
                        }
                        //案件主檔進度序號加一 & 相關欄位 Update
                        Sys.insert_log_table(conn, "U", prgid, "dmt", "seq;seq1", dseq + ";" + dseq1, logReason);
                        SQL = "update dmt set step_grade=step_grade+1 ";
                        SQL += ",apply_date = " + Util.dbnull(Request["apply_date_" + i + "_" + j]);
                        SQL += ",apply_no = " + Util.dbnull(Request["apply_no_" + i + "_" + j]);
                        if (dnow_case_stat != "" && dnow_case_stat != "") {
                            SQL += ",now_arcase_type = " + Util.dbnull(arr_rs_type[i]);
                            SQL += ",now_arcase = " + Util.dbnull(arr_rs_code[i]);
                            SQL += ",now_stat = " + Util.dbnull(dnow_case_stat);
                            SQL += ",now_grade = " + Util.dbnull(dlstep_grade);
                        }
                        SQL += " where seq=" + dseq + " and seq1='" + dseq1 + "'";
                        conn.ExecuteNonQuery(SQL);
                        //2008/11/13因增加營洽官收確認作業，所以等營洽確認後再產生客發
                        //2008/11/27李協理回覆程序官收確認即產生客發
                        //新增客發紀錄
                        if (dcs_rs_no != "") {
                            SQL = "insert into cs_dmt(rs_no,step_date,rs_type,rs_class,rs_code,act_code,rs_detail,last_date,send_way,tran_date,tran_scode)";
                            SQL += " values('" + dcs_rs_no + "','" + DateTime.Today.ToString("yyyy/M/d") + "'," + Util.dbnull(arr_rs_type[i]);
                            SQL += "," + Util.dbchar(arr_rs_class[i]) + "," + Util.dbchar(arr_rs_code[i]);
                            SQL += ",'" + dcsact_code + "'," + Util.dbnull(dcs_detail) + "," + Util.dbnull(dlctrl_date);
                            SQL += "," + Util.dbnull(arr_send_way[i]) + ",getdate(),'" + Session["scode"] + "')";
                            conn.ExecuteNonQuery(SQL);
                            SQL = "insert into csd_dmt(rs_no,branch,seq,seq1,cust_seq,att_sql)";
                            SQL += "values('" + dcs_rs_no + "','" + Session["seBranch"] + "'," + dseq + ",'" + dseq1 + "'";
                            SQL += "," + Util.dbnull(arr_cust_seq[i]) + "," + Util.dbnull(arr_att_sql[i]) + ")";
                            conn.ExecuteNonQuery(SQL);
                        }

                        //2008/11/13因增加營洽官收確認作業，所以新增營洽官收確認紀錄檔及todo_dmt
                        SQL = "insert into grconf_dmt(seq,seq1,step_grade,rs_sqlno,from_flag,cs_flag,cs_send_way,scs_detail,last_date,cs_rs_no,csd_flag,csd_remark,pstep_date) values (";
                        SQL += dseq + ",'" + dseq1 + "'," + dlstep_grade + "," + dGetrs_sqlno;
                        SQL += ",'E','" + arr_radcs[i] + "'," + Util.dbnull(arr_send_way[i]) + "," + Util.dbnull(dcs_detail) + "," + Util.dbnull(dlctrl_date);
                        SQL += "," + Util.dbnull(dcs_rs_no) + ",'" + arr_chkcsd_flag[i] + "'," + Util.dbchar(arr_cs_remark[i]) + "," + Util.dbnull(arr_pmail_date[i]) + ")";
                        conn.ExecuteNonQuery(SQL);
                        //抓insert後的流水號
                        SQL = "SELECT SCOPE_IDENTITY() AS Current_Identity";
                        objResult = conn.ExecuteScalar(SQL);
                        string dGetgrconf_sqlno = objResult.ToString();
                        Sys.showLog("dGetgrconf_sqlno=" + dGetgrconf_sqlno);

                        //取得營洽及所屬組別
                        string ddmt_scode = "", dgrpid = "";
                        SQL = "select a.scode,b.grpid from dmt a left outer join sysctrl.dbo.scode_group b on a.scode=b.scode and b.grpclass='" + Session["seBranch"] + "'";
                        SQL += " where a.seq=" + dseq + " and a.seq1='" + dseq1 + "'";
                        using (SqlDataReader dr0 = conn.ExecuteReader(SQL)) {
                            if (dr0.Read()) {
                                ddmt_scode = dr0.SafeRead("scode", "");
                                dgrpid = dr0.SafeRead("grpid", "");
                            }
                        }
                        SQL = "insert into todo_dmt(syscode,apcode,temp_rs_sqlno,seq,seq1,step_grade,in_date,in_scode,dowhat,job_scode,job_team,job_status) values (";
                        SQL += "'" + Session["syscode"] + "','" + prgid + "'," + Util.dbnull(dGetgrconf_sqlno) + "," + dseq + ",'" + dseq1 + "'";
                        SQL += "," + dlstep_grade + ",getdate(),'" + Session["scode"] + "','SALES_GR','" + ddmt_scode + "','" + dgrpid + "','NN')";
                        conn.ExecuteNonQuery(SQL);

                        //2008/12/13有掃描要新增至文件紀錄檔dmt_attach及入todo_dmt
                        //掃描文件命名規則branch+dept-seq(5)-seq1-step_grade(4)-attach_no(2).pdf
                        if (arr_radscan[i] == "Y") {
                            int dattach_no = 1;
                            //string attach_name = Session["sebranch"] + Sys.GetSession("dept").ToUpper() + "-" + dseq.PadLeft(5, '0') + "-" + (dseq1 != "_" ? dseq1 : "") + "-" + dlstep_grade.PadLeft(4, '0') + "-" + dattach_no.ToString().PadLeft(2, '0') + ".pdf";//重新命名檔名
                            //string newattach_path = Sys.formatScanPathNo(dseq, dseq1, dlstep_grade, dattach_no.ToString());//存在資料庫路徑
                            //string source_name = attach_name;

                            string attach_path = "", attach_name = "";
                            Sys.formatScanPathNo(dseq, dseq1, dlstep_grade, dattach_no.ToString(), ref attach_path, ref attach_name);//存在資料庫路徑
                            string newattach_path = attach_path + attach_name;
                            string source_name = attach_name;
                            
                            SQL = "insert into dmt_attach ";
                            ColMap.Clear();
                            ColMap["Seq"] = Util.dbchar(dseq);
                            ColMap["seq1"] = Util.dbchar(dseq1);
                            ColMap["step_grade"] = Util.dbchar(dlstep_grade);
                            ColMap["Source"] = Util.dbchar("scan");
                            ColMap["in_date"] = "getdate()";
                            ColMap["in_scode"] = "'" + Session["scode"] + "'";
                            ColMap["Attach_no"] = Util.dbchar(dattach_no.ToString());
                            ColMap["attach_path"] = Util.dbchar(Sys.Path2Btbrt(newattach_path));
                            ColMap["attach_desc"] = Util.dbnull("掃描文件");
                            ColMap["Attach_name"] = Util.dbnull(attach_name);
                            ColMap["source_name"] = Util.dbnull(source_name);
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
                            string dGetattach_sqlno = objResult.ToString();
                            Sys.showLog("掃描文件流水號=" + dGetattach_sqlno);

                            //新增掃描確認流程檔
                            SQL = "insert into todo_dmt ";
                            ColMap.Clear();
                            ColMap["syscode"] = "'" + Session["syscode"] + "'";
                            ColMap["apcode"] = "'" + prgid + "'";
                            ColMap["temp_rs_sqlno"] = Util.dbnull(dGetattach_sqlno);
                            ColMap["seq"] = Util.dbnull(dseq);
                            ColMap["seq1"] = Util.dbchar(dseq1);
                            ColMap["step_grade"] = Util.dbzero(dlstep_grade);
                            ColMap["in_date"] = "getdate()";
                            ColMap["in_scode"] = "'" + Session["scode"] + "'";
                            ColMap["dowhat"] = Util.dbchar("scan");//掃描確認,ref:cust_code.code_type='Ttodo'
                            ColMap["job_status"] = Util.dbchar("NN");
                            SQL += ColMap.GetInsertSQL();
                            conn.ExecuteNonQuery(SQL);
                        }

                        //官發進度之總收發文進度及序號
                        SQL = "update step_dmt set mg_step_grade=" + Request["mg_step_grade_" + i + "_" + j] + ",mg_rs_sqlno=" + Util.dbnull(Request["mg_rs_sqlno_" + i + "_" + j]);
                        SQL += " where rs_no='" + dgs_rs_no + "'";
                        conn.ExecuteNonQuery(SQL);

                        //暫存檔及流程檔之狀態更新
                        SQL = "update step_mgt_temp set into_date=getdate(),into_scode='" + Session["scode"] + "'";
                        SQL += " where temp_rs_sqlno=" + Request["temp_rs_sqlno_" + i + "_" + j];
                        conn.ExecuteNonQuery(SQL);
                        SQL = "update todo_dmt set job_status='YY',approve_scode='" + Session["scode"] + "',resp_date=getdate() ";
                        SQL += " where temp_rs_sqlno=" + Request["temp_rs_sqlno_" + i + "_" + j] + " and dowhat='GS' and job_status='NN' ";
                        conn.ExecuteNonQuery(SQL);

                        //總收發文之單位官發回條確認日期寫回
                        SQL = "update send_mgt set br_sconf_date=getdate(),br_sconf_scode='" + Session["scode"] + "'";
                        SQL += " where seq_area='" + Session["seBranch"] + "' and rs_no='" + dgs_rs_no + "'";
                        connm.ExecuteNonQuery(SQL);
                    }
                }
            }
        }
    }

    //官發總管處退件
    private void doBack() {
        for (int i = 1; i < arr_chk.Length; i++) {
            if (arr_chk[i] == "Y") {//有打勾
                Sys.showLog("<font color=red>﹝" + i + "﹞</font>seq=" + arr_seq[i] + "-" + arr_seq1[i]);
                //20170106刪除附件檔  新增 dmt_attach_log
                Sys.insert_log_table(conn, "D", prgid, "dmt_attach", "seq;seq1;step_grade", arr_seq[i] + ";" + arr_seq1[i] + ";" + arr_step_grade[i], logReason);
                SQL = "update dmt_attach set attach_flag='D',tran_date=getdate(),tran_scode='" + Session["scode"] + "' ";
                SQL += "where seq=" + arr_seq[i] + " and seq1='" + arr_seq1[i] + "' ";
                SQL += "and step_grade='" + arr_step_grade[i] + "' and attach_flag<>'D'";
                conn.ExecuteNonQuery(SQL);

                //刪除管制檔  新增 ctrl_dmt_log
                Sys.insert_log_table(conn, "D", prgid, "ctrl_dmt", "rs_no", arr_rs_no[i], logReason);
                SQL = "delete from ctrl_dmt where rs_no='" + arr_rs_no[i] + "'";
                conn.ExecuteNonQuery(SQL);

                //取消銷管,還原至ctrl_dmt
                //新增 resp_dmt_log
                Sys.insert_log_table(conn, "D,A", prgid, "resp_dmt", "seq;seq1;resp_grade", arr_seq[i] + ";" + arr_seq1[i] + ";" + arr_step_grade[i], logReason);
                //新增 ctrl_dmt
                SQL = "insert into ctrl_dmt(rs_no,branch,seq,seq1,step_grade,ctrl_type,ctrl_remark,ctrl_date,tran_date,tran_scode) ";
                SQL += "select rs_no,branch,seq,seq1,step_grade,ctrl_type,ctrl_remark,ctrl_date,getdate(),'" + Session["scode"] + "' ";
                SQL += "from resp_dmt where seq=" + arr_seq[i] + " and seq1='" + arr_seq1[i] + "' and step_grade='" + arr_step_grade[i] + "'";
                conn.ExecuteNonQuery(SQL);
                //刪除 resp_dmt
                SQL = "delete from resp_dmt where seq=" + arr_seq[i] + " and seq1='" + arr_seq1[i] + "' and step_grade='" + arr_step_grade[i] + "'";
                conn.ExecuteNonQuery(SQL);

                //取消被銷管
                //新增 resp_dmt_log
                Sys.insert_log_table(conn, "D,B", prgid, "resp_dmt", "rs_no", arr_rs_no[i], logReason);
                //刪除 resp_dmt
                SQL = "delete from resp_dmt where rs_no='" + arr_rs_no[i] + "'";
                conn.ExecuteNonQuery(SQL);

                //恢復case_dmt.gs_fees
                DataTable dtFees = new DataTable();
                SQL = "select * from fees_dmt where rs_no='" + arr_rs_no[i] + "' ";//條件同官發回條列印
                conn.DataTable(SQL, dtFees);
                for (int f = 0; f < dtFees.Rows.Count; f++) {
                    DataRow dr = dtFees.Rows[f];
                    //新增 fees_dmt_log
                    Sys.insert_log_table(conn, "D", prgid, "fees_dmt", "rs_no;case_no", arr_rs_no[i] + ";" + dr["case_no"], logReason);
                    //修改case_dmt
                    string hngs_fees = dr.SafeRead("fees", "");
                    if (hngs_fees == "") hngs_fees = "0";
                    SQL = "update case_dmt set gs_fees=gs_fees-" + hngs_fees + ",gs_curr=gs_curr-1 where case_no ='" + dr["case_no"] + "'";
                    conn.ExecuteNonQuery(SQL);
                    //刪除 fees_dmt
                    SQL = "delete from fees_dmt where rs_no = '" + arr_rs_no[i] + "' and case_no ='" + dr["case_no"] + "'";
                    conn.ExecuteNonQuery(SQL);
                }

                //刪除發文主檔
                //新增 step_dmt_Log 檔
                Sys.insert_log_table(conn, "D", prgid, "step_dmt", "rs_no", arr_rs_no[i], logReason);

                //刪除 step_dmt
                SQL = "delete step_dmt where rs_no='" + arr_rs_no[i] + "'";
                conn.ExecuteNonQuery(SQL);

                bool dmt_log_flag = false;
                //如果是註冊費電子送件,退件確時要把主檔的註冊費已繳清空
                if (arr_gs_send_way[i] == "EA") {
                    if (arr_rs_code[i] == "FF0" || arr_rs_code[i] == "FF2" || arr_rs_code[i] == "FF3") {
                        if (dmt_log_flag == false) {
                            Sys.insert_log_table(conn, "U", prgid, "dmt", "seq;seq1", arr_seq[i] + ";" + arr_seq1[i], logReason);
                            dmt_log_flag = true;
                        }

                        SQL = "update dmt set ";
                        ColMap.Clear();
                        ColMap["pay_times"] = Util.dbnull("");
                        ColMap["pay_date"] = Util.dbnull("");
                        SQL += ColMap.GetUpdateSQL();
                        SQL += " where seq=" + arr_seq[i] + " and seq1='" + arr_seq1[i] + "'";
                        conn.ExecuteNonQuery(SQL);
                    }
                }

                //若案件主檔案件狀態進度序號等於進度序號，則修改案件狀態
                updateDmtStatus(arr_seq[i], arr_seq1[i], arr_rs_no[i], arr_step_grade[i], ref dmt_log_flag);

                //暫存檔及流程檔之狀態更新
                SQL = "update step_mgt_temp set into_date=getdate(),into_scode='" + Session["scode"] + "'";
                SQL += " where temp_rs_sqlno=" + arr_temp_rs_sqlno[i];
                conn.ExecuteNonQuery(SQL);
                SQL = "update todo_dmt set job_status='YY',approve_scode='" + Session["scode"] + "',resp_date=getdate() ";
                SQL += " where temp_rs_sqlno=" + arr_temp_rs_sqlno[i] + " and (dowhat='GSB' or dowhat='GSBS') and job_status='NN' ";
                conn.ExecuteNonQuery(SQL);
                //2010/8/3增加退回承辦交辦發文todo_dmt
                if (Convert.ToInt32("0" + arr_todo_sqlno[i]) > 0) {
                    SQL = "insert into todo_dmt(pre_sqlno,syscode,apcode,from_flag,branch,seq,seq1,step_grade,case_in_scode,in_no,case_no,in_scode,in_date";
                    SQL += ",dowhat,job_scode,job_team,job_status) ";
                    SQL += "select sqlno,syscode,'" + prgid + "','CGRS','" + Session["seBranch"] + "'," + arr_seq[i] + ",'" + arr_seq1[i] + "'";
                    SQL += ",step_grade,case_in_scode,in_no,case_no,'" + Session["scode"] + "'";
                    SQL += ",getdate(),'DP_GS',job_scode,job_team,'NN'";
                    SQL += " from todo_dmt where sqlno=" + arr_todo_sqlno[i];
                    conn.ExecuteNonQuery(SQL);
                }
                //總收發文之單位官發回條確認日期寫回
                SQL = "update mgt_send set br_back_date=getdate(),br_back_scode='" + Session["scode"] + "'";
                SQL += " where seq_area='" + Session["seBranch"] + "' and rs_no='" + arr_rs_no[i] + "'";
                connm.ExecuteNonQuery(SQL);

                //有子案之官收進度處理
                if (arr_child_flag[i] == "Y") {
                    for (int j = 1; j <= Convert.ToInt32("0" + arr_mchknum[i]); j++) {
                        string dseq = ReqVal.TryGet("seq_" + i + "_" + j);
                        string dseq1 = ReqVal.TryGet("seq1_" + i + "_" + j);
                        string dgs_rs_no = ReqVal.TryGet("rs_no_" + i + "_" + j);
                        if (dseq != "" && dseq1 != "") {
                            //判斷是否已存在 step_dmt 案件主檔
                            SQL = " select * from step_dmt where main_rs_no = '" + arr_rs_no[i] + "' ";
                            SQL += " and seq=" + dseq + " and seq1 = '" + dseq1 + "' ";
                            DataTable dtMain = new DataTable();
                            conn.DataTable(SQL, dtMain);
                            if (dtMain.Rows.Count > 0) {//已存在進度檔, 將之刪除
                                DataRow dr0 = dtMain.Rows[0];
                                //刪除發文主檔
                                //新增 step_dmt_Log 檔
                                Sys.insert_log_table(conn, "D", prgid, "step_dmt", "rs_no", dgs_rs_no, logReason);

                                //刪除 step_dmt
                                SQL = "delete step_dmt where rs_no='" + dr0["rs_no"] + "'";
                                conn.ExecuteNonQuery(SQL);

                                //若案件主檔案件狀態進度序號等於進度序號，則修改案件狀態
                                bool ddmt_log_flag = false;
                                updateDmtStatus(dseq, dseq1, dr0.SafeRead("rs_no", ""), dr0.SafeRead("step_grade", ""), ref ddmt_log_flag);
                            }
                            //暫存檔及流程檔之狀態更新
                            SQL = "update step_mgt_temp set into_date=getdate(),into_scode='" + Session["scode"] + "'";
                            SQL += " where temp_rs_sqlno=" + Request["temp_rs_sqlno_" + i + "_" + j];
                            conn.ExecuteNonQuery(SQL);
                            SQL = "update todo_dmt set job_status='YY',approve_scode='" + Session["scode"] + "',resp_date=getdate() ";
                            SQL += " where temp_rs_sqlno=" + Request["temp_rs_sqlno_" + i + "_" + j] + " and (dowhat='GSB' or dowhat='GSBS') and job_status='NN' ";
                            conn.ExecuteNonQuery(SQL);
                            //總收發文之單位官發回條確認日期寫回
                            SQL = "update mgt_send set br_back_date=getdate(),br_back_scode='" + Session["scode"] + "'";
                            SQL += " where seq_area='" + Session["seBranch"] + "' and rs_no='" + dgs_rs_no + "'";
                            connm.ExecuteNonQuery(SQL);
                        }
                    }
                }
            }
        }
    }
    
    //更新案件主檔 案件狀態/進度序號
    private void updateDmtStatus(string tseq, string tseq1, string trs_no, string del_step_grade, ref bool dmt_log_flag) {
        //若案件主檔案件狀態進度序號等於進度序號，則修改案件狀態
        SQL = "select step_grade,isnull(now_grade,0) as now_grade from dmt where seq=" + tseq + " and seq1='" + tseq1 + "'";
        string step_grade = "0", now_grade = "0";
        using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
            if (dr.Read()) {
                step_grade = dr.SafeRead("step_grade", "0");//最新進度序號
                now_grade = dr.SafeRead("now_grade", "0");//最新有狀態的進度序號
            }
        }

        //更新主檔進度序號
        if (Convert.ToInt32(step_grade) == Convert.ToInt32(del_step_grade)) {
            if (dmt_log_flag == false) {
                Sys.insert_log_table(conn, "U", prgid, "dmt", "seq;seq1", tseq + ";" + tseq1, logReason);
                dmt_log_flag = true;
            }
            SQL = "select max(step_grade) as step_grade from vstep_dmt ";
            SQL += " where seq = " + tseq + " and seq1='" + tseq1 + "' and step_grade <> '" + del_step_grade + "'";
            objResult = conn.ExecuteScalar(SQL);
            string rstep_grade = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();

            SQL = " update dmt set seq = seq ";
            if (rstep_grade != "") SQL += " ,step_grade = '" + rstep_grade + "'";
            SQL += " where seq = " + tseq + " and seq1='" + tseq1 + "'";
            conn.ExecuteNonQuery(SQL);
        }

        //更新主檔 now_arcase, now_stat ..... 等欄位
        if (Convert.ToInt32(now_grade) == Convert.ToInt32(del_step_grade)) {
            if (dmt_log_flag == false) {
                Sys.insert_log_table(conn, "U", prgid, "dmt", "seq;seq1", tseq + ";" + tseq1, logReason);
                dmt_log_flag = true;
            }

            SQL = "select * from vstep_dmt a, vcode_act b";
            SQL += " where a.seq = " + tseq;
            SQL += "   and a.seq1 = '" + tseq1 + "'";
            SQL += "   and a.rs_no <> '" + trs_no + "'";
            SQL += "   and a.rs_type = b.rs_type ";
            SQL += "   and a.rs_class = b.rs_class ";
            SQL += "   and a.rs_code = b.rs_code ";
            SQL += "   and a.act_code = b.act_code ";
            SQL += "   and b.cg = a.cg ";
            SQL += "   and b.rs = a.rs ";
            SQL += "   and b.case_stat is not null ";
            SQL += " order by step_grade desc";

            string nnow_arcase_type = "", nnow_arcase = "", nnow_stat = "", nnow_grade = "", nnow_arcase_class = "", nnow_act_code = "";
            using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
                if (dr.Read()) {
                    nnow_arcase_type = dr.SafeRead("rs_type", "");
                    nnow_arcase = dr.SafeRead("rs_code", "");
                    nnow_stat = dr.SafeRead("case_stat", "");
                    nnow_grade = dr.SafeRead("step_grade", "");
                    nnow_arcase_class = dr.SafeRead("rs_class", "");
                    nnow_act_code = dr.SafeRead("act_code", "");
                }
            }
            SQL = " update dmt set seq = seq ";
            SQL += " ,now_arcase_type = " + Util.dbnull(nnow_arcase_type);
            SQL += " ,now_arcase = " + Util.dbnull(nnow_arcase);
            SQL += " ,now_stat = " + Util.dbnull(nnow_stat);
            SQL += " ,now_grade = " + Util.dbnull(nnow_grade);
            SQL += " ,now_arcase_class = " + Util.dbnull(nnow_arcase_class);
            SQL += " ,now_act_code = " + Util.dbnull(nnow_act_code);
            SQL += " where seq = " + tseq + " and seq1='" + tseq1 + "'";
            conn.ExecuteNonQuery(SQL);
        }
    }
</script>

<%Response.Write(strOut.ToString());%>
