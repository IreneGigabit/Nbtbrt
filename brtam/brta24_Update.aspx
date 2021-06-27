<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Linq"%>

<script runat="server">
    protected string HTProgCap = "程序官收確認入檔";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "brta24";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";

    protected string submitTask = "";
    protected string SQL = "";
    protected object objResult = null;

    protected string logReason = "Brta24國內案官收確認作業";
    protected string fseq="",rs_no = "",cs_rs_no="";

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

                fseq = Sys.formatSeq1(Request["seq"], Request["seq1"], "", Sys.GetSession("seBranch"), Sys.GetSession("dept"));

                //判斷狀態是否已異動,防止開雙視窗
                SQL = "select count(*) from todo_dmt ";
                SQL += " where temp_rs_sqlno=" + Request["temp_rs_sqlno"] + " and dowhat='GR' and job_status='NN' ";
                conn.ExecuteNonQuery(SQL);
                objResult = conn.ExecuteScalar(SQL);
                int cnt = (objResult == DBNull.Value || objResult == null) ? 0 : Convert.ToInt32(objResult);
                if (cnt == 0) {
                    conn.RollBack();
                    connm.RollBack();
                    strOut.AppendLine("<div align='center'><h1>案件狀態有誤或已確認(" + fseq + ")，請重新查詢！</h1></div>");
                } else {
                    if (ReqVal.TryGet("task") == "conf") {
                        doConfirm();
                        strOut.AppendLine("<div align='center'><h3><font color=blue>案件編號：" + fseq + "<font color=red>官方收文成功</font>" +
                        "，官收序號：" + rs_no + (cs_rs_no != "" ? "，客發序號：" + cs_rs_no : "") + "</font></h3></div>");
                    } else if (ReqVal.TryGet("task") == "back") {
                        doBack();
                        strOut.AppendLine("<div align='center'><h3><font color=blue>案件編號：" + fseq + "<font color=red>官方收文退回總管處成功</font></h3></div>");
                    }
                    conn.Commit();
                    connm.Commit();
                    //conn.RollBack();
                    //connm.RollBack();
                }
            }
            catch (Exception ex) {
                conn.RollBack();
                connm.RollBack();
                Sys.errorLog(ex, conn.exeSQL, prgid);
                Sys.errorLog(ex, connm.exeSQL, prgid);
                //strOut.AppendLine("<div align='center'><h1>官方收文失敗("+ex.Message+")</h1></div>");
                throw;
            }

            this.DataBind();
        }
    }

    /// <summary>
    /// 官收確認處理
    /// </summary>
    private void doConfirm() {
        //2008/11/13因增加營洽官收確認作業，所以等營洽確認後再產生客發
        //2008/11/27李協理回覆程序官收確認即產生客發
        //判斷是否需客戶報導 , 若需客戶報導則需新增一筆客發
        cs_rs_no = "";
        if (ReqVal.TryGet("csflg") == "Y") {
            //先取得客發序號. 新增完官收後再新增客發
            cs_rs_no = Sys.getRsNo(conn, "CS");
        }

        //收文序號
        rs_no = Sys.getRsNo(conn, "GR");

        //官收入step_dmt	
        SQL = "insert into step_dmt ";
        ColMap.Clear();
        ColMap["rs_no"] = Util.dbchar(rs_no);
        ColMap["branch"] = Util.dbchar(Sys.GetSession("seBranch"));
        ColMap["seq"] = Util.dbnull(Request["seq"]);
        ColMap["seq1"] = Util.dbchar(Request["seq1"]);
        ColMap["step_grade"] = Util.dbnull(Request["nstep_grade"]);
        ColMap["mg_step_grade"] = Util.dbnull(Request["mg_step_grade"]);
        ColMap["mg_rs_sqlno"] = Util.dbnull(Request["mg_rs_sqlno"]);
        ColMap["main_rs_no"] = Util.dbchar(rs_no);
        ColMap["step_date"] = Util.dbnull(Request["step_date"]);
        ColMap["mp_date"] = Util.dbnull(Request["mp_date"]);
        ColMap["cg"] = Util.dbchar(Request["cgrs"].Substring(0, 1));
        ColMap["rs"] = Util.dbchar(Request["cgrs"].Substring(1, 1));
        ColMap["send_cl"] = Util.dbnull(Request["send_cl"]);
        ColMap["rs_type"] = Util.dbnull(Request["rs_type"]);
        ColMap["rs_class"] = Util.dbchar(Request["rs_class"]);
        ColMap["rs_code"] = Util.dbchar(Request["rs_code"]);
        ColMap["act_code"] = Util.dbchar(Request["act_code"]);
        ColMap["rs_detail"] = Util.dbnull(Request["rs_detail"]);
        ColMap["doc_detail"] = Util.dbnull(Request["doc_detail"]);
        ColMap["receive_no"] = Util.dbnull(Request["receive_no"]);
        ColMap["cs_rs_no"] = Util.dbnull(cs_rs_no);
        ColMap["pr_status"] = Util.dbchar(ReqVal.TryGet("pr_scode") != "" ? "N" : "X");
        ColMap["pr_scode"] = Util.dbnull(Request["pr_scode"]);
        ColMap["new"] = Util.dbchar("N");
        ColMap["tot_num"] = Util.dbzero("1");
        ColMap["tran_date"] = "getdate()";
        ColMap["tran_scode"] = "'" + Session["scode"] + "'";
        ColMap["receive_way"] = Util.dbnull(Request["receive_way"]);
        ColMap["pr_scan"] = Util.dbchar(Request["pr_scan"]);
        ColMap["pr_scan_remark"] = Util.dbchar(Request["pr_scan_remark"]);
        ColMap["pr_scan_path"] = Util.dbchar(Request["pr_scan_path"]);
        ColMap["pr_scan_page"] = Util.dbzero(Request["pr_scan_page"]);
        ColMap["csd_flag"] = Util.dbchar(Request["csd_flag"]);
        ColMap["cs_remark"] = Util.dbchar(Request["cs_remark"]);
        ColMap["pmail_date"] = Util.dbnull(Request["pmail_date"]);
        SQL += ColMap.GetInsertSQL();
        conn.ExecuteNonQuery(SQL);

        //抓insert後的流水號
        SQL = "SELECT SCOPE_IDENTITY() AS Current_Identity";
        objResult = conn.ExecuteScalar(SQL);
        string Getrs_sqlno = objResult.ToString();
        Sys.showLog("進度流水號=" + Getrs_sqlno);

        //入ctrl_dmt
        for (int i = 1; i <= Convert.ToInt32("0" + Request["ctrlnum"]); i++) {
            if ((Request["ctrl_type_" + i] ?? "") != "" || (Request["ctrl_date_" + i] ?? "") != "") {
                SQL = "insert into ctrl_dmt ";
                ColMap.Clear();
                ColMap["rs_no"] = Util.dbchar(rs_no);
                ColMap["branch"] = Util.dbchar(Sys.GetSession("seBranch"));
                ColMap["seq"] = Util.dbnull(Request["seq"]);
                ColMap["seq1"] = Util.dbchar(Request["seq1"]);
                ColMap["step_grade"] = Util.dbnull(Request["nstep_grade"]);
                ColMap["ctrl_type"] = Util.dbchar(Request["ctrl_type_" + i]);
                ColMap["ctrl_remark"] = Util.dbnull(Request["ctrl_remark_" + i]);
                ColMap["ctrl_date"] = Util.dbnull(Request["ctrl_date_" + i]);
                ColMap["tran_date"] = "getdate()";
                ColMap["tran_scode"] = "'" + Session["scode"] + "'";
                SQL += ColMap.GetInsertSQL();
                conn.ExecuteNonQuery(SQL);
            }
        }

        //銷管制入檔
        //新增至 resp_dmt
        SQL = "insert into resp_dmt(sqlno,rs_no,branch,seq,seq1,step_grade,resp_grade,ctrl_type,ctrl_remark,ctrl_date,resp_date,tran_date,tran_scode) ";
        SQL += "select sqlno,rs_no,branch,seq,seq1,step_grade,'" + Request["nstep_grade"] + "',ctrl_type,ctrl_remark,ctrl_date,'" + Request["step_date"] + "',getdate(),'" + Session["scode"] + "' ";
        SQL += "from ctrl_dmt where sqlno in('" + Request["rsqlno"].Replace(";", "','") + "') and sqlno<>''";
        conn.ExecuteNonQuery(SQL);

        //由 ctrl_dmt 中刪除
        SQL = "delete from ctrl_dmt where sqlno in('" + Request["rsqlno"].Replace(";", "','") + "') and sqlno<>''";
        conn.ExecuteNonQuery(SQL);

        //案件主檔進度序號加一 & 相關欄位 Update
        Sys.insert_log_table(conn, "U", prgid, "dmt", "seq;seq1", Request["seq"] + ";" + Request["seq1"], logReason);
        SQL = "update dmt set step_grade=step_grade+1 ";
        SQL += ",apply_date = " + Util.dbnull(Request["apply_date"]);
        SQL += ",apply_no = " + Util.dbnull(Request["apply_no"]);
        SQL += ",issue_date = " + Util.dbnull(Request["issue_date"]);
        SQL += ",issue_no = " + Util.dbnull(Request["issue_no"]);
        SQL += ",open_date = " + Util.dbnull(Request["open_date"]);
        SQL += ",rej_no = " + Util.dbnull(Request["rej_no"]);
        SQL += ",term1 = " + Util.dbnull(Request["term1"]);
        SQL += ",term2 = " + Util.dbnull(Request["term2"]);
        //2011/9/22依需求2011/5/20李協理Email，增加update延展次數
        SQL += ",renewal = " + Util.dbzero(Request["renewal"]);
        if (ReqVal.TryGet("ncase_stat") != "") {
            SQL += ",now_arcase_type = " + Util.dbnull(Request["rs_type"]);
            SQL += ",now_arcase = " + Util.dbnull(Request["rs_code"]);
            SQL += ",now_stat = " + Util.dbnull(Request["ncase_stat"]);
            SQL += ",now_grade = " + Util.dbnull(Request["nstep_grade"]);
            SQL += ",now_arcase_class = " + Util.dbnull(Request["rs_class"]);
            SQL += ",now_act_code = " + Util.dbnull(Request["act_code"]);
        }
        SQL += ",pay_times = " + Util.dbnull(Request["hpay_times"]);
        SQL += ",pay_date = " + Util.dbnull(Request["pay_date"]);
        SQL += " where seq=" + Request["seq"] + " and seq1='" + Request["seq1"] + "'";
        conn.ExecuteNonQuery(SQL);

        //取得最小法定期限,2009/9/14法定期限抓取A*但A2客戶期限除外且管制日期最小者
        SQL = "select ctrl_date from ctrl_dmt ";
        SQL += "where seq=" + Request["seq"] + " and seq1='" + Request["seq1"] + "' and step_grade=" + Request["nstep_grade"] + " and ctrl_type like 'A%' and ctrl_type<>'A2' ";
        SQL += "order by ctrl_date";
        objResult = conn.ExecuteScalar(SQL);
        string lctrl_date = (objResult == DBNull.Value || objResult == null) ? "" : Convert.ToDateTime(objResult).ToString("yyyy/M/d");

        //2008/11/13因增加營洽官收確認作業，所以等營洽確認後再產生客發，
        //2008/11/27李協理回覆程序官收確認即產生客發
        //新增客發紀錄
        if (cs_rs_no != "") {
            //取得取得客發代碼
            string lcsact_code = ReqVal.TryGet("act_code");
            SQL = "select csact_code from vcode_act where rs_type = '" + Request["rs_type"] + "'";
            SQL += "  and rs_class = '" + Request["rs_class"] + "' and rs_code = '" + Request["rs_code"] + "'";
            SQL += "  and act_code = '" + Request["act_code"] + "' and cg = 'G' and rs = 'R' ";
            using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
                if (dr.Read()) {
                    lcsact_code = dr.SafeRead("csact_code", "");
                }
            }

            SQL = "insert into cs_dmt(rs_no,step_date,rs_type,rs_class,rs_code,act_code,rs_detail,last_date,send_way,tran_date,tran_scode)";
            SQL += " values('" + cs_rs_no + "'," + Util.dbnull(Request["step_date"]) + "," + Util.dbnull(Request["rs_type"]);
            SQL += "," + Util.dbchar(Request["rs_class"]) + "," + Util.dbchar(Request["rs_code"]);
            SQL += ",'" + lcsact_code + "'," + Util.dbnull(Request["cs_detail"]) + "," + Util.dbnull(lctrl_date);
            SQL += "," + Util.dbnull(Request["send_way"]) + ",getdate(),'" + Session["scode"] + "')";
            conn.ExecuteNonQuery(SQL);

            SQL = "insert into csd_dmt(rs_no,branch,seq,seq1,cust_seq,att_sql)";
            SQL += "values('" + cs_rs_no + "','" + Session["seBranch"] + "'," + Request["seq"] + ",'" + Request["seq1"] + "'";
            SQL += "," + Util.dbnull(Request["cust_seq"]) + "," + Util.dbnull(Request["att_sql"]) + ")";
            conn.ExecuteNonQuery(SQL);
        }

        //2008/11/13因增加營洽官收確認作業，所以新增營洽官收確認紀錄檔及todo_dmt
        string from_flag = "A";
        if (ReqVal.TryGet("qryfrom_flag") == "C") {
            from_flag = "C";
        } else if (ReqVal.TryGet("qryfrom_flag") == "J") {
            from_flag = "J";
        } else {
            from_flag = "A";
        }

        SQL = "insert into grconf_dmt(seq,seq1,step_grade,rs_sqlno,from_flag,cs_flag,cs_send_way,scs_detail,last_date,cs_rs_no,csd_flag,csd_remark,pstep_date) values (";
        SQL += Request["seq"] + ",'" + Request["seq1"] + "'," + Request["nstep_grade"] + "," + Getrs_sqlno;
        SQL += ",'" + from_flag + "','" + Request["csflg"] + "'," + Util.dbnull(Request["send_way"]) + "," + Util.dbnull(Request["cs_detail"]) + "," + Util.dbnull(lctrl_date);
        SQL += "," + Util.dbnull(cs_rs_no) + ",'" + Request["csd_flag"] + "'," + Util.dbchar(Request["cs_remark"]) + "," + Util.dbnull(Request["pmail_date"]) + ")";
        conn.ExecuteNonQuery(SQL);
        //抓insert後的流水號
        SQL = "SELECT SCOPE_IDENTITY() AS Current_Identity";
        objResult = conn.ExecuteScalar(SQL);
        string Getgrconf_sqlno = objResult.ToString();
        Sys.showLog("Getgrconf_sqlno=" + Getgrconf_sqlno);

        //取得營洽及所屬組別
        string dmt_scode = "", grpid = "";
        SQL = "select a.scode,b.grpid from dmt a left outer join sysctrl.dbo.scode_group b on a.scode=b.scode and b.grpclass='" + Session["seBranch"] + "'";
        SQL += " where a.seq=" + Request["seq"] + " and a.seq1='" + Request["seq1"] + "'";
        using (SqlDataReader dr0 = conn.ExecuteReader(SQL)) {
            if (dr0.Read()) {
                dmt_scode = dr0.SafeRead("scode", "");
                grpid = dr0.SafeRead("grpid", "");
            }
        }
        SQL = "insert into todo_dmt(syscode,apcode,temp_rs_sqlno,seq,seq1,step_grade,in_date,in_scode,dowhat,job_scode,job_team,job_status) values (";
        SQL += "'" + Session["syscode"] + "','" + prgid + "'," + Util.dbnull(Getgrconf_sqlno) + "," + Request["seq"] + ",'" + Request["seq1"] + "'";
        SQL += "," + Request["nstep_grade"] + ",getdate(),'" + Session["scode"] + "','SALES_GR','" + dmt_scode + "','" + grpid + "','NN')";
        conn.ExecuteNonQuery(SQL);

        //2008/12/13有掃描要新增至文件紀錄檔dmt_attach及入todo_dmt
        //掃描文件命名規則branch+dept-seq(5)-seq1-step_grade(4)-attach_no(2).pdf
        int attach_no = 0;
        if (ReqVal.TryGet("pr_scan") == "Y") {
            attach_no++;
            string attach_path = "", attach_name = "";
            Sys.formatScanPathNo(Request["seq"], Request["seq1"], Request["nstep_grade"], attach_no.ToString(), ref attach_path, ref attach_name);//存在資料庫路徑
            string newattach_path = attach_path + attach_name;
            string source_name = attach_name;

            SQL = "insert into dmt_attach ";
            ColMap.Clear();
            ColMap["Seq"] = Util.dbchar(Request["seq"]);
            ColMap["seq1"] = Util.dbchar(Request["seq1"]);
            ColMap["step_grade"] = Util.dbchar(Request["nstep_grade"]);
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
            ColMap["chk_page"] = Util.dbzero(Request["pr_scan_page"]);
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
            ColMap["seq"] = Util.dbnull(Request["seq"]);
            ColMap["seq1"] = Util.dbchar(Request["seq1"]);
            ColMap["step_grade"] = Util.dbzero(Request["nstep_grade"]);
            ColMap["in_date"] = "getdate()";
            ColMap["in_scode"] = "'" + Session["scode"] + "'";
            ColMap["dowhat"] = Util.dbchar("scan");//掃描確認,ref:cust_code.code_type='Ttodo'
            ColMap["job_status"] = Util.dbchar("NN");
            SQL += ColMap.GetInsertSQL();
            conn.ExecuteNonQuery(SQL);
        }

        //2014/5/6有電子公文檔要新增至dmt_attach，2015/8/12新增Email公文
        if (Convert.ToInt32("0" + Request["pdfcnt"]) > 0) {
            //2015/8/12增加抓取Email公文
            SQL = "select a.*,isnull((select cust_code from cust_code where Code_type='Tdoc' and mark='M' and mark1=a.doc_type),'99') as br_doc_type ";
            SQL += "from mgt_attach_temp a where temp_rs_sqlno=" + Request["temp_rs_sqlno"] + " and source='" + Request["pdfsource"] + "' and attach_flag<>'D' ";
            SQL += "order by attach_sqlno ";
            DataTable dtMgtAttachTemp = new DataTable();
            conn.DataTable(SQL, dtMgtAttachTemp);
            for (int t = 0; t < dtMgtAttachTemp.Rows.Count; t++) {
                DataRow dr0 = dtMgtAttachTemp.Rows[t];
                attach_no++;
                string newattach_path = dr0.SafeRead("attach_path", "");//Email公文連結到總管處檢視，所以不用換路徑
                if (ReqVal.TryGet("pdfsource") == "EGR") {//電子公文會同步至區所，所以要換路徑
                    newattach_path = newattach_path.Replace("/MG", "/btbrt");
                }

                SQL = "insert into dmt_attach ";
                ColMap.Clear();
                ColMap["Seq"] = Util.dbchar(Request["seq"]);
                ColMap["seq1"] = Util.dbchar(Request["seq1"]);
                ColMap["step_grade"] = Util.dbchar(Request["nstep_grade"]);
                ColMap["Source"] = Util.dbchar(Request["pdfsource"]);
                ColMap["in_date"] = "getdate()";
                ColMap["in_scode"] = "'" + Session["scode"] + "'";
                ColMap["Attach_no"] = Util.dbchar(attach_no.ToString());
                ColMap["attach_path"] = Util.dbchar(Sys.Path2Btbrt(newattach_path));
                ColMap["doc_type"] = Util.dbchar(dr0.SafeRead("br_doc_type", ""));
                ColMap["attach_desc"] = Util.dbchar(dr0.SafeRead("attach_desc", ""));
                ColMap["Attach_name"] = Util.dbchar(dr0.SafeRead("attach_name", ""));
                ColMap["source_name"] = Util.dbchar(dr0.SafeRead("attach_name", ""));
                ColMap["attach_flag"] = Util.dbchar("A");
                ColMap["Mark"] = Util.dbchar("");
                ColMap["tran_date"] = "getdate()";
                ColMap["tran_scode"] = "'" + Session["scode"] + "'";
                ColMap["att_sqlno"] = Util.dbzero(dr0.SafeRead("attach_sqlno", ""));
                SQL += ColMap.GetInsertSQL();
                conn.ExecuteNonQuery(SQL);
            }
        }

        //暫存檔及流程檔之狀態更新
        SQL = "update step_mgt_temp set step_grade=" + Request["nstep_grade"] + ",br_rs_sqlno=" + Getrs_sqlno + ",into_date=getdate(),into_scode='" + Session["scode"] + "'";
        SQL += " where temp_rs_sqlno=" + Request["temp_rs_sqlno"];
        conn.ExecuteNonQuery(SQL);
        SQL = "update todo_dmt set step_grade=" + Request["nstep_grade"] + ",job_status='YY',approve_scode='" + Session["scode"] + "',resp_date=getdate() ";
        SQL += " where temp_rs_sqlno=" + Request["temp_rs_sqlno"] + " and dowhat='GR' and job_status='NN' ";
        conn.ExecuteNonQuery(SQL);

        //總收發文之單位官收確認日期寫回
        SQL = "update step_mgt set br_conf_date=getdate(),br_conf_scode='" + Session["scode"] + "'";
        SQL += " where seq_area='" + Session["seBranch"] + "' and step_rs_sqlno=" + Request["mg_rs_sqlno"];
        connm.ExecuteNonQuery(SQL);

        //結案註記寫回待結案處理，區所有結案，但總收發文沒結案
        if (ReqVal.TryGet("end_flag") == "Y") {
            //brend_mgt結案資料檔
            SQL = "insert into brend_mgt(br_step_grade,br_rs_sqlno,seq_area,seq,seq1,end_flag,br_end_date,br_end_code,br_end_reason,in_scode,in_date) values (";
            SQL += Request["nstep_grade"] + "," + Getrs_sqlno + ",'" + Session["seBranch"] + "'," + Request["seq"] + ",'" + Request["seq1"] + "','end'," + Util.dbnull(Request["end_date"]);
            SQL += "," + Util.dbnull(Request["end_code"]) + "," + Util.dbnull(Request["end_name"]) + ",'" + Session["scode"] + "',getdate())";
            connm.ExecuteNonQuery(SQL);
            //抓insert後的流水號
            SQL = "SELECT SCOPE_IDENTITY() AS Current_Identity";
            objResult = connm.ExecuteScalar(SQL);
            string Getmgrs_sqlno = objResult.ToString();
            Sys.showLog("總收發結案暫存流水號=" + Getmgrs_sqlno);

            SQL = "insert into todo_mgt(syscode,apcode,temp_rs_sqlno,br_rs_sqlno,seq_area,seq,seq1,in_date,in_scode,dowhat,job_status) values(";
            SQL += "'" + Session["syscode"] + "','" + prgid + "'," + Getmgrs_sqlno + "," + Getrs_sqlno + ",'" + Session["seBranch"] + "'," + Request["seq"];
            SQL += ",'" + Request["seq1"] + "',getdate(),'" + Session["scode"] + "','end','NN')";
            connm.ExecuteNonQuery(SQL);
        }

        //官收立子案處理
        if (ReqVal.TryGet("hdomark") == "A" || ReqVal.TryGet("hdomark") == "B") {//A需立子案  B已立案
            //brstep_mgt收文暫存檔
            string s_mark1 = ReqVal.TryGet("s_mark");
            if (s_mark1 == "") s_mark1 = "_";
            SQL = "insert into brstep_mgt(seq_area,seq,seq1,br_in_date,br_step_grade,br_rs_sqlno,mseq,mseq1,mrs_sqlno,mstep_grade,cg,rs,rs_type,rs_class,rs_class_name";
            SQL += ",rs_code,rs_code_name,act_code,act_code_name,rs_detail,step_date,cappl_name,s_mark1,country,apply_date,apply_no,issue_date,issue_no2,issue_no3";
            SQL += ",open_date,pay_times,pay_date,term1,term2,end_date,end_code,branch_date,branch_scode,tran_date,tran_scode,mark) values (";
            SQL += "'" + Session["seBranch"] + "'," + Request["seq"] + ",'" + Request["seq1"] + "'," + Util.dbnull(Request["in_date"]) + "," + Util.dbnull(Request["nstep_grade"]);
            SQL += "," + Getrs_sqlno + "," + Request["grseq"] + ",'" + Request["grseq1"] + "'," + Request["mg_rs_sqlno"] + "," + Request["mg_step_grade"] + ",'G','R'";
            SQL += ",'" + Request["rs_type"] + "','" + Request["rs_class"] + "'," + Util.dbchar(Request["rs_class_name"]) + ",'" + Request["rs_code"] + "'," + Util.dbchar(Request["rs_code_name"]);
            SQL += ",'" + Request["act_code"] + "'," + Util.dbchar(Request["act_code_name"]) + "," + Util.dbchar(Request["rs_detail"]) + "," + Util.dbnull(Request["step_date"]) + "," + Util.dbchar(Request["appl_name"]);
            SQL += ",'" + s_mark1 + "','T'," + Util.dbnull(Request["apply_date"]) + ",'" + Request["apply_no"] + "'," + Util.dbnull(Request["issue_date"]) + ",'" + Request["issue_no"] + "'";
            SQL += ",'" + Request["rej_no"] + "'," + Util.dbnull(Request["open_date"]) + "," + Util.dbnull(Request["pay_times"]) + "," + Util.dbnull(Request["pay_date"]);
            SQL += "," + Util.dbnull(Request["term1"]) + "," + Util.dbnull(Request["term2"]) + "," + Util.dbnull(Request["end_date"]) + ",'" + Request["end_code"] + "'";
            SQL += ",getdate(),'" + Session["scode"] + "',getdate(),'" + Session["scode"] + "','" + Request["hdomark"] + "')";
            connm.ExecuteNonQuery(SQL);
            //抓insert後的流水號
            SQL = "SELECT SCOPE_IDENTITY() AS Current_Identity";
            objResult = connm.ExecuteScalar(SQL);
            string Getbrstep_sqlno = objResult.ToString();
            Sys.showLog("總收發立子案收文暫存流水號=" + Getbrstep_sqlno);

            //todo_mgt
            SQL = "insert into todo_mgt(syscode,apcode,temp_rs_sqlno,rs_sqlno,br_rs_sqlno,seq_area,seq,seq1,step_grade,rs,in_date,in_scode,dowhat,job_status) values ";
            SQL += "('" + Session["syscode"] + "','" + prgid + "'," + Getbrstep_sqlno + "," + Request["mg_rs_sqlno"] + "," + Getrs_sqlno + ",'" + Session["seBranch"] + "'";
            SQL += "," + Request["seq"] + ",'" + Request["seq1"] + "'," + Request["mg_step_grade"] + ",'R',getdate(),'" + Session["scode"] + "','br_gr','NN')";
            connm.ExecuteNonQuery(SQL);
            //brctrl_mgt
            for (int i = 1; i <= Convert.ToInt32("0" + Request["ctrlnum"]); i++) {
                if ((Request["ctrl_type_" + i] ?? "") == "A1" || (Request["ctrl_date_" + i] ?? "") != "") {
                    SQL = "insert into brctrl_mgt ";
                    ColMap.Clear();
                    ColMap["brstep_sqlno"] = Util.dbnull(Getbrstep_sqlno);
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
        }
    }

    /// <summary>
    /// 官收退件處理
    /// </summary>
    private void doBack() {
        //暫存檔及流程檔之狀態更新,2009/9/4修改退件不要更新區所官收確認日期及人員
        //2010/2/23修回退件要更新區所官收確認日及人員，因總收發文系統刪除後重新收文，若無確認日期會有問題
        SQL = "update step_mgt_temp set reject_reason=" + Util.dbchar(Request["reject_reason"]);
        SQL += ",into_date=getdate(),into_scode='" + Session["scode"] + "'";
        SQL += " where temp_rs_sqlno=" + Request["temp_rs_sqlno"];
        conn.ExecuteNonQuery(SQL);

        SQL = "update todo_dmt set job_status='XX',approve_scode='" + Session["scode"] + "',approve_desc=" + Util.dbchar(Request["reject_reason"]) + ",resp_date=getdate() ";
        SQL += " where temp_rs_sqlno=" + Request["temp_rs_sqlno"] + " and dowhat='GR' and job_status='NN' ";
        conn.ExecuteNonQuery(SQL);

        //2014/5/7新增，因應電子公文，將上傳電子公文檔案註記D
        if (Convert.ToInt32("0" + Request["pdfcnt"]) > 0) {
            Sys.insert_log_table(conn, "U", HTProgCode, "mgt_attach_temp", "temp_rs_sqlno", Request["temp_rs_sqlno"], logReason);
            SQL = "update mgt_attach_temp set attach_flag='D' where temp_rs_sqlno=" + Request["temp_rs_sqlno"];
            conn.ExecuteNonQuery(SQL);
        }
        //入總收發退件流程
        SQL = "insert into todo_mgt(syscode,apcode,temp_rs_sqlno,rs_sqlno,seq_area,seq,seq1,step_grade,rs,in_date,in_scode,dowhat,job_status,approve_desc) values ";
        SQL += "('" + Session["syscode"] + "','" + prgid + "'," + Request["temp_rs_sqlno"] + "," + Request["mg_rs_sqlno"] + ",'" + Session["seBranch"] + "'," + Request["seq"] + "";
        SQL += ",'" + Request["seq1"] + "'," + Request["mg_step_grade"] + ",'R',getdate(),'" + Session["scode"] + "','br_back','NN'," + Util.dbchar(Request["reject_reason"]) + ")";
        connm.ExecuteNonQuery(SQL);

        //總收發文之單位官收確認日期寫回,2009/9/4修改退件部要更新總收發文
        //2010/2/23修回退件要更新區所官收確認日及人員，因總收發文系統刪除後重新收文，若無確認日期會有問題
        SQL = "update step_mgt set br_conf_date=getdate(),br_conf_scode='" + Session["scode"] + "'";
        SQL += " where seq_area='" + Session["seBranch"] + "' and step_rs_sqlno=" + Request["mg_rs_sqlno"];
        connm.ExecuteNonQuery(SQL);

        //Email通知總管處人員
        CreateMail();
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
                strTo.Add(Session["scode"] + "@saint-island.com.tw");
                strBCC.Add("m1583@saint-island.com.tw");
                break;
            default:
                strTo = ReqVal.TryGet("emg_scode").Split(';').Where(p => p != "").Select(o => o + "@saint-island.com.tw").ToList();
                strCC = ReqVal.TryGet("emg_agscode").Split(';').Where(p => p != "").Select(o => o + "@saint-island.com.tw").ToList();
                break;
        }


        string body = "<B>致: 總管處 程序</B><br><br>";
        body += "【區所案件編號】 : <B>" + fseq + "</B><br>";
        body += "【案件名稱】 : <B>" + Request["appl_name"] + "</B><br>";
        body += "【總收發進度序號】 : <B>" + Request["mg_step_grade"] + "</B><br>";
        body += "【總收發收文日期】 : <B>" + Request["mp_date"] + "</B><br>";
        body += "【總收發收文內容】 : <B>" + Request["mg_rs_detail"] + "</B><br><br>";
        body += "<font color=red>【退回原因】 : <B>" + Request["reject_reason"] + "</B></font><br>";

        Subject = "國內所商標網路系統－官方收文退件通知（區所編號： " + fseq + " ，總收發進度：" + Request["mg_step_grade"] + "）";

        Sys.DoSendMail(Subject, body, strFrom, strTo, strCC, strBCC);
    }
</script>

    <%Response.Write(strOut.ToString());%>
	<center>
        <p>
	    <input type=button name="cbutton1" value="承辦單列印" class="c1button" onClick="brta24Prt()">
	    <input type=button name="button5" value="回官收確認作業" class="cbutton" onClick="brta24Srch()">
        </p>
	</center>

<script language='javascript' type='text/javascript'>
    function brta24Prt(){
        if("<%=rs_no%>"==""){
            alert("無官收序號,不可列印!");
        }else{
            window.open(getRootPath() + "/brtam/brta411print.aspx?cgrs=GR&srs_no=<%=rs_no%>&ers_no=<%=rs_no%>&menu=N");
        }
    }
    function brta24Srch(){
        window.parent.Etop.goSearch();
    }
</script>

