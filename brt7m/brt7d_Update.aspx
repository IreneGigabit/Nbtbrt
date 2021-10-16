<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Linq"%>

<script runat="server">
    protected string HTProgCap = "會計契約書檢核及查詢作業(收據)-入檔";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "brt7d";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";

    protected string submitTask = "";
    protected string SQL = "";
    protected object objResult = null;

    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected Dictionary<string, string> ColMap = new Dictionary<string, string>();

    protected string logReason = "Brt7d會計契約書檢核作業";

    string[] arr_chkflag, arr_in_scode, arr_in_no, arr_case_no, arr_seq, arr_seq1, arr_country, arr_cust_area, arr_cust_seq, arr_old_spay_flag, arr_cust_apsqlno, arr_todo_sqlno;
    string[] arr_step_grade, arr_rs_no, arr_rs_sqlno, arr_sc_name, arr_appl_name, arr_attach_num, arr_spay_attach_num, arr_view_flag, arr_chkdoc, arr_chkspay_flag;

    protected string qryseq_type = "", todo = "", tblname = "", tdept = "", msgdept = "", msgtodo = "";
    protected List<string> tin_scode = new List<string>();

    protected StringBuilder strOut = new StringBuilder();

    DBHelper conn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    DBHelper connbr = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    private void Page_Unload(System.Object sender, System.EventArgs e) {
        if (conn != null) conn.Dispose();
        if (connbr != null) conn.Dispose();
    }

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");
        arr_chkflag = ReqVal.TryGet("rows_chkflag").Split('\f');
        arr_in_scode = ReqVal.TryGet("rows_in_scode").Split('\f');
        arr_in_no = ReqVal.TryGet("rows_in_no").Split('\f');
        arr_case_no = ReqVal.TryGet("rows_case_no").Split('\f');
        arr_seq = ReqVal.TryGet("rows_seq").Split('\f');
        arr_seq1 = ReqVal.TryGet("rows_seq1").Split('\f');
        arr_country = ReqVal.TryGet("rows_country").Split('\f');
        arr_cust_area = ReqVal.TryGet("rows_cust_area").Split('\f');
        arr_cust_seq = ReqVal.TryGet("rows_cust_seq").Split('\f');
        arr_old_spay_flag = ReqVal.TryGet("rows_old_spay_flag").Split('\f');
        arr_cust_apsqlno = ReqVal.TryGet("rows_cust_apsqlno").Split('\f');
        arr_todo_sqlno = ReqVal.TryGet("rows_todo_sqlno").Split('\f');
        arr_step_grade = ReqVal.TryGet("rows_step_grade").Split('\f');
        arr_rs_no = ReqVal.TryGet("rows_rs_no").Split('\f');
        arr_rs_sqlno = ReqVal.TryGet("rows_rs_sqlno").Split('\f');
        arr_sc_name = ReqVal.TryGet("rows_sc_name").Split('\f');
        arr_appl_name = ReqVal.TryGet("rows_appl_name").Split('\f');
        arr_attach_num = ReqVal.TryGet("rows_attach_num").Split('\f');
        arr_spay_attach_num = ReqVal.TryGet("rows_spay_attach_num").Split('\f');
        arr_view_flag = ReqVal.TryGet("rows_view_flag").Split('\f');
        arr_chkdoc = ReqVal.TryGet("rows_chkdoc").Split('\f');
        arr_chkspay_flag = ReqVal.TryGet("rows_chkspay_flag").Split('\f');

        qryseq_type = ReqVal.TryGet("qryseq_type").ToUpper();
        todo = ReqVal.TryGet("todo").ToLower();

        if (qryseq_type == "T") {
            tblname = "dmt";
            msgdept = "國內案";
        } else if (qryseq_type == "TE") {
            tblname = "ext";
            msgdept = "出口案";
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
                        string tmp_country = arr_country[i];

                        string fseq = Sys.formatSeq(tmp_seq, tmp_seq1, tmp_country, Sys.GetSession("seBranch"), qryseq_type);

                        tin_scode.Add(arr_in_scode[i]);

                        //判斷狀態是否已異動,防止開雙視窗
                        SQL = "select count(*) from todo_" + tblname + " where sqlno='" + tmp_sqlno + "' and job_status='NN' and dowhat='contractA'";
                        object objResult = conn.ExecuteScalar(SQL);
                        int cnt = (objResult == DBNull.Value || objResult == null) ? 0 : Convert.ToInt32(objResult);
                        if (cnt == 0) {
                            throw new Exception(fseq + "會計契約書檢核處理失敗(狀態已異動，請重新整理畫面)");
                        } else {
                            if (qryseq_type == "T") {
                                update_case_dmt(i);
                            } else if (qryseq_type == "TE") {
                                update_case_ext(i);
                            }

                            if (todo == "conf") {//確認
                                msgtodo = "檢核";
                                if (arr_chkspay_flag[i] == "Y") {//客戶專案付款註記
                                    update_custz(i);
                                }
                            }

                            if (todo == "back") {//退回，新增契約書後補todo及管制期限
                                msgtodo = "退回";
                                if (qryseq_type == "T") {
                                    insert_todo_dmt(i);
                                } else if (qryseq_type == "TE") {
                                    insert_todo_ext(i);
                                }
                                CreateMail();//退回才發送Email
                            }
                        }
                    }
                }

                strOut.AppendLine("<div align='center'><h1>" + msgdept + "收據會計契約書" + msgtodo + "成功</h1></div>");
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
    /// 更新交辦案件主檔case_dmt,2016/1/30修改，for總契約書增加todo判斷
    /// </summary>
    private void update_case_dmt(int pno) {
        string tmp_in_scode = arr_in_scode[pno];
        string tmp_in_no = arr_in_no[pno];
        string todo_sqlno = arr_todo_sqlno[pno];

        //新增交辦案件主檔Log檔
        Sys.insert_log_table(conn, "U", prgid, "case_dmt", "in_scode;in_no", tmp_in_scode + ";" + tmp_in_no, logReason);

        //更新交辦案件主檔
        SQL = "update case_dmt ";
        if (todo == "conf") {//確認，更新會計檢核狀態、會計檢核日期及檢核人員
            SQL += "set acc_chk = 'Y' ";
            SQL += " ,acc_chkdate = getdate() ";
            SQL += " ,acc_chkscode = '" + Session["scode"] + "'";
        } else if (todo == "back") {//退回，更新契約書後補及後補說明(會計輸入退回原因)
            SQL += "set contract_flag='Y',contract_remark=" + Util.dbchar(ReqVal.TryGet("back_remark")) + ",contract_flag_date=null";
        }
        SQL += " ,tran_date = getdate() ";
        SQL += " where in_scode = '" + tmp_in_scode + "' and in_no='" + tmp_in_no + "'";
        conn.ExecuteNonQuery(SQL);

        //2016/1/30修改，因契約書檢核改為todo,所以增加update契約書檢核todo
        SQL = "update todo_dmt set approve_scode='" + Session["scode"] + "',resp_date=getdate() ";
        if (todo == "conf") {//確認
            SQL += ",job_status='YY' ";
        } else if (todo == "back") {//退回
            SQL += ",job_status='NX',approve_desc=" + Util.dbchar(ReqVal.TryGet("back_remark"));
        }
        SQL += " where sqlno=" + todo_sqlno + " and job_status='NN' and dowhat='contractA' ";
        conn.ExecuteNonQuery(SQL);
    }

    /// <summary>
    /// 更新交辦案件主檔case_ext,2016/1/30修改，for總契約書增加todo判斷
    /// </summary>
    private void update_case_ext(int pno) {
        string tmp_in_scode = arr_in_scode[pno];
        string tmp_in_no = arr_in_no[pno];
        string todo_sqlno = arr_todo_sqlno[pno];

        //新增交辦案件主檔Log檔
        Sys.insert_log_table(conn, "U", prgid, "case_ext", "in_scode;in_no", tmp_in_scode + ";" + tmp_in_no, logReason);

        //更新交辦案件主檔
        SQL = "update case_ext ";
        if (todo == "conf") {//確認，更新會計檢核狀態、會計檢核日期及檢核人員
            SQL += "set acc_chk = 'Y' ";
            SQL += " ,acc_chkdate = getdate() ";
            SQL += " ,acc_chkscode = '" + Session["scode"] + "'";
        } else if (todo == "back") {//退回，更新契約書後補及後補說明(會計輸入退回原因)
            SQL += "set contract_flag='Y',contract_remark=" + Util.dbchar(ReqVal.TryGet("back_remark")) + ",contract_flag_date=null";
        }
        SQL += " ,tran_date = getdate() ";
        SQL += " where in_scode = '" + tmp_in_scode + "' and in_no='" + tmp_in_no + "'";
        conn.ExecuteNonQuery(SQL);

        //2016/1/30修改，因契約書檢核改為todo,所以增加update契約書檢核todo
        SQL = "update todo_ext set approve_scode='" + Session["scode"] + "',resp_date=getdate() ";
        if (todo == "conf") {//確認
            SQL += ",job_status='YY' ";
        } else if (todo == "back") {//退回
            SQL += ",job_status='NX',approve_desc=" + Util.dbchar(ReqVal.TryGet("back_remark"));
        }
        SQL += " where sqlno=" + todo_sqlno + " and job_status='NN' and dowhat='contractA' ";
        conn.ExecuteNonQuery(SQL);
    }
    
    /// <summary>
    /// 更新客戶主檔的專案付款條件
    /// </summary>
    private void update_custz(int pno) {
        string tmp_cust_area = arr_cust_area[pno];
        string tmp_cust_seq = arr_cust_seq[pno];
        string tmp_seq = arr_seq[pno];
        string tmp_seq1 = arr_seq1[pno];
        string tmp_in_no = arr_in_no[pno];
        string tmp_case_no = arr_case_no[pno];

        //新增客戶主檔log檔
        insert_apcust_log(tmp_cust_area, tmp_cust_seq, pno);

        //更新客戶主檔之專案付款條件及付款期限
        SQL = "update custz set tspay_flag='Y',tspay_mm=10 ";
        SQL += ",ttran_date=getdate(),ttran_scode='" + Session["scode"] + "'";
        if (qryseq_type == "T") {//2015/11/5增加註記哪個案件及接洽上傳專案付款條件
            SQL += ",tspay_source='dmt_attach',tspay_seq='" + Session["seBranch"] + "T-" + tmp_seq + "',tspay_refno='" + tmp_in_no + "," + tmp_case_no + "'";
        } else if (qryseq_type == "TE") {
            SQL += ",tspay_source='caseattach_ext',tspay_seq='" + Session["seBranch"] + "TE-" + tmp_seq + "',tspay_refno='" + tmp_in_no + "," + tmp_case_no + "'";
        }
        SQL += " where cust_area='" + tmp_cust_area + "' and cust_seq=" + tmp_cust_seq;
        conn.ExecuteNonQuery(SQL);
    }
    
    /// <summary>
    /// 新增客戶主檔log檔
    /// </summary>
    private void insert_apcust_log(string pcust_area, string pcust_seq, int pno) {
        SQL = "select isnull(max(grp_sql)+1,1) as grp_sql from apcust_log";
        string grp_sql = conn.getString(SQL);//記得那些是一起修改

        SQL = "insert into apcust_log(grp_sql,cust_area,cust_seq,apsqlno,in_prgid,chg_dept,chg_kind";
        SQL += ",fidname,fidcname,ovalue,nvalue,upd_main,tran_date,tran_scode)";
        SQL += " values(" + grp_sql + "," + Util.dbnull(pcust_area) + "," + Util.dbnull(pcust_seq);
        SQL += ",'" + arr_cust_apsqlno[pno] + "','" + prgid + "','T','custz'";
        SQL += ",'tspay_flag','商標專案付款條件'";
        SQL += "," + Util.dbnull(arr_old_spay_flag[pno]) + ",'Y'";
        SQL += ",'Y',getdate(),'" + Session["scode"] + "')";
        conn.ExecuteNonQuery(SQL);
    }
    
    /// <summary>
    /// 新增契約書後補todo_dmt(契約書後補會計退回)
    /// </summary>
    private void insert_todo_dmt(int pno) {
        string tmp_in_scode = arr_in_scode[pno];
        string tmp_in_no = arr_in_no[pno];
        string todo_sqlno = arr_todo_sqlno[pno];
        string tmp_seq = arr_seq[pno];
        string tmp_seq1 = arr_seq1[pno];

        //新增管制期限1個月B9_契約書後補期限
        string ctrl_date = DateTime.Today.AddMonths(1).ToShortDateString();
        SQL = "insert into ctrl_dmt ";
        ColMap.Clear();
        ColMap["rs_no"] = Util.dbchar(arr_rs_no[pno]);
        ColMap["branch"] = Util.dbchar(Sys.GetSession("seBranch"));
        ColMap["seq"] = Util.dbnull(tmp_seq);
        ColMap["seq1"] = Util.dbchar(tmp_seq1);
        ColMap["step_grade"] = Util.dbnull(arr_step_grade[pno]);
        ColMap["ctrl_type"] = Util.dbchar("B9");//契約書後補期限
        ColMap["ctrl_remark"] = Util.dbchar(Request["back_remark"]);
        ColMap["ctrl_date"] = Util.dbchar(ctrl_date);
        ColMap["tran_date"] = "getdate()";
        ColMap["tran_scode"] = "'" + Session["scode"] + "'";
        SQL += ColMap.GetInsertSQL();
        conn.ExecuteNonQuery(SQL);

        //新增契約書後補todo
        string nGrpID = Sys.getCodeName(conn, "sysctrl.dbo.scode_group", "grpid", "where grpclass='" + Session["seBranch"] + "' and scode='" + tmp_in_scode + "'");
        SQL = "insert into todo_dmt ";
        ColMap.Clear();
        ColMap["pre_sqlno"] = Util.dbnull(todo_sqlno);
        ColMap["branch"] = "'" + Session["seBranch"] + "'";
        ColMap["syscode"] = "'" + Session["syscode"] + "'";
        ColMap["apcode"] = "'" + prgid + "'";
        ColMap["seq"] = Util.dbnull(tmp_seq);
        ColMap["seq1"] = Util.dbchar(tmp_seq1);
        ColMap["step_grade"] = Util.dbnull(arr_step_grade[pno]);
        ColMap["in_team"] = Util.dbchar(nGrpID);
        ColMap["case_in_scode"] = Util.dbchar(tmp_in_scode);
        ColMap["in_no"] = Util.dbchar(tmp_in_no);
        ColMap["case_no"] = Util.dbchar(arr_case_no[pno]);
        ColMap["from_flag"] = Util.dbchar("CASE");
        ColMap["in_scode"] = "'" + Session["scode"] + "'";
        ColMap["in_date"] = "getdate()";
        ColMap["dowhat"] = Util.dbchar("contractLB");//契約書後補會計退回,ref:cust_code.code_type='Ttodo'
        ColMap["job_scode"] = Util.dbchar(tmp_in_scode);
        ColMap["job_team"] = Util.dbchar(nGrpID);
        ColMap["job_status"] = Util.dbchar("NN");
        ColMap["approve_desc"] = Util.dbchar(Request["back_remark"]);
        SQL += ColMap.GetInsertSQL();
        conn.ExecuteNonQuery(SQL);
    }

    /// <summary>
    /// 新增契約書後補todo_ext(契約書後補會計退回)
    /// </summary>
    private void insert_todo_ext(int pno) {
        string tmp_in_scode = arr_in_scode[pno];
        string tmp_in_no = arr_in_no[pno];
        string todo_sqlno = arr_todo_sqlno[pno];
        string tmp_seq = arr_seq[pno];
        string tmp_seq1 = arr_seq1[pno];

        //新增管制期限1個月B9_契約書後補期限
        string ctrl_date = DateTime.Today.AddMonths(1).ToShortDateString();
        SQL = "insert into ctrl_ext ";
        ColMap.Clear();
        ColMap["rs_sqlno"] = Util.dbchar(arr_rs_sqlno[pno]);
        ColMap["branch"] = Util.dbchar(Sys.GetSession("seBranch"));
        ColMap["seq"] = Util.dbnull(tmp_seq);
        ColMap["seq1"] = Util.dbchar(tmp_seq1);
        ColMap["step_grade"] = Util.dbnull(arr_step_grade[pno]);
        ColMap["ctrl_type"] = Util.dbchar("B9");//契約書後補期限
        ColMap["ctrl_remark"] = Util.dbchar(Request["back_remark"]);
        ColMap["ctrl_date"] = Util.dbchar(ctrl_date);
        ColMap["date_ctrl"] = Util.dbchar("");
        ColMap["tran_date"] = "getdate()";
        ColMap["tran_scode"] = "'" + Session["scode"] + "'";
        SQL += ColMap.GetInsertSQL();
        conn.ExecuteNonQuery(SQL);

        //新增契約書後補todo
        string nGrpID = Sys.getCodeName(conn, "sysctrl.dbo.scode_group", "grpid", "where grpclass='" + Session["seBranch"] + "' and scode='" + tmp_in_scode + "'");
        SQL = "insert into todo_ext ";
        ColMap.Clear();
        ColMap["pre_sqlno"] = Util.dbnull(todo_sqlno);
        ColMap["branch"] = "'" + Session["seBranch"] + "'";
        ColMap["syscode"] = "'" + Session["syscode"] + "'";
        ColMap["apcode"] = "'" + prgid + "'";
        ColMap["seq"] = Util.dbnull(tmp_seq);
        ColMap["seq1"] = Util.dbchar(tmp_seq1);
        ColMap["step_grade"] = Util.dbnull(arr_step_grade[pno]);
        ColMap["in_team"] = Util.dbchar(nGrpID);
        ColMap["case_in_scode"] = Util.dbchar(tmp_in_scode);
        ColMap["in_no"] = Util.dbchar(tmp_in_no);
        ColMap["case_no"] = Util.dbchar(arr_case_no[pno]);
        ColMap["from_flag"] = Util.dbchar("CASE");
        ColMap["in_scode"] = "'" + Session["scode"] + "'";
        ColMap["in_date"] = "getdate()";
        ColMap["dowhat"] = Util.dbchar("contractLB");//契約書後補會計退回,ref:cust_code.code_type='Ttodo'
        ColMap["job_scode"] = Util.dbchar(tmp_in_scode);
        ColMap["job_team"] = Util.dbchar(nGrpID);
        ColMap["job_status"] = Util.dbchar("NN");
        ColMap["approve_desc"] = Util.dbchar(Request["back_remark"]);
        SQL += ColMap.GetInsertSQL();
        conn.ExecuteNonQuery(SQL);
    }

    private void CreateMail() {
        string Subject = "商標案件管理系統－" + msgdept + "契約書檢核退回暨後補通知";
        string strFrom = Session["sc_name"] + "<" + Session["scode"] + "@saint-island.com.tw>";
        List<string> strTo = new List<string>();
        List<string> strCC = new List<string>();
        List<string> strBCC = new List<string>();

        //抓取部門主管、區所主管
        SQL = "select master_scode from sysctrl.dbo.grpid where grpclass='" + Session["SeBranch"] + "' and grpid in('000','T000') order by grplevel desc ";
        DataTable dt = new DataTable();
        conn.DataTable(SQL, dt);
        List<string> master = dt.AsEnumerable().Select(r => r.Field<string>("master_scode") + "@saint-island.com.tw").ToList();

        //抓取程序
        string prscode = "";
        if (qryseq_type == "TE") {
            prscode = Sys.getCodeName(conn, "sysctrl.dbo.scode_group", "scode", "where grpclass='" + Session["seBranch"] + "' and grpid='T220' and grptype='F'");
        } else {
            prscode = Sys.getCodeName(conn, "sysctrl.dbo.scode_group", "scode", "where grpclass='" + Session["seBranch"] + "' and grpid='T210' and grptype='F'");
        }

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
                strTo = tin_scode;
                strCC.AddRange(master);//部門主管、區所主管
                if (prscode != "") strCC.Add(prscode + "@saint-island.com.tw");//程序
                break;
        }

        string body = dobody();
        if (body != "") {
            Sys.DoSendMail(Subject, body, strFrom, strTo, strCC, strBCC);
        }
    }

    //信件內容
    private string dobody() {
        string tbody = "";
        if (arr_chkflag.Length > 0) {
            tbody = "Dear All:<br><br>";
            tbody += "茲因「" + ReqVal.TryGet("back_remark") + "」，會計執行契約書檢核之退回並<br>";
            tbody += "通知 貴單位各營洽需契約書後補之案件，明細如下，敬請至「" + msgdept + "契約書後補作業」完成相關文件上傳暨期限銷管，以便會計再執行後續之契約書檢核作業，謝謝。<br><br>";
            tbody += "●尚需契約書後補之案件資料：";
            tbody += "<br>";
            tbody += "<table width='60%' border='1' cellspacing='0' cellpadding='0' style='font-size:10pt'>";
            tbody += "<tr align='center' style='BACKGROUND-COLOR:#CCFFFF'>";
            tbody += "<td nowrap>營洽</td><td nowrap>本所編號</td><td nowrap>案件名稱</td>";
            tbody += "</tr>";

            for (int b = 1; b < arr_chkflag.Length; b++) {
                if (arr_chkflag[b] == "Y") {//有打勾
                    string fseq = Sys.formatSeq(arr_seq[b], arr_seq1[b], arr_country[b], Sys.GetSession("seBranch"), qryseq_type);

                    tbody += "<tr align='center'>";
                    tbody += "<td nowrap>" + arr_sc_name[b] + "</td>";
                    tbody += "<td nowrap>" + fseq + "</td>";
                    tbody += "<td nowrap>" + arr_appl_name[b] + "</td>";
                    tbody += "</tr>";
                }
            }
        }
        return tbody;
    }
</script>

<%Response.Write(strOut.ToString());%>
