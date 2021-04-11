<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Linq"%>

<script runat="server">
    protected string HTProgCap = HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "brt36";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";

    protected string submitTask = "";
    protected string SQL = "";

    protected int tot = 0;
    protected string row = "";
    protected string qs_dept = "";
    protected string dept = "";
    protected string tblname = "";
    protected string att_tblname = "";
    protected string field_name = "";
    protected string status = "";

    protected string msg = "";
    protected List<string> tin_no = new List<string>();
    protected List<string> tappl_name = new List<string>();
    protected List<string> tcase_name = new List<string>();
    protected List<string> tseq = new List<string>();

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

        row = (Request["row"] ?? "").Trim();
        qs_dept = (Request["qs_dept"] ?? "").Trim();
        status = (Request["status"] ?? "").Trim();

        if (qs_dept == "t") {
            HTProgCode = "brt36";
            HTProgCap = "國內案官發簽核作業";
            dept = "t";
            tblname = "todo_dmt";
            att_tblname = "attcase_dmt";
       } else {
           HTProgCode = "ext36";
           HTProgCap = "出口案發文簽核作業";
            dept = "e";
            tblname = "todo_ext";
            att_tblname = "attcase_ext";
        }
        
        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        HTProgCap = myToken.Title;
        DebugStr = myToken.DebugStr;
        if (HTProgRight >= 0) {
            try {
                conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
                
                bool task=doUpdateDB();
                if (task) {
                    strOut.AppendLine("<div align='center'><h1>資料更新成功</h1></div>");
                    CreateMail();
                } else {
                    if (msg == "") 
                        strOut.AppendLine("<div align='center'><h1>資料更新失敗</h1></div>");
                    else
                        strOut.AppendLine("<div align='center'><h1>"+msg+"</h1></div>");
                }
                //conn.Commit();
                conn.RollBack();
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

    //'****簽核狀態為轉下一單位簽核或簽准
    private bool doUpdateDB() {
        string job_team = "", job_grplevel = "";
        Sys.getScodeGrpid(Sys.GetSession("seBranch"), Request["signidnext"], ref job_team, ref job_grplevel);

        for (int i = 1; i <= Convert.ToInt32("0" + row); i++) {
            if (Request["C_" + i] == "Y") {
                string tsqlno = ReqVal.TryGet("code_" + i);//todo.sqlno
                string Min_no = ReqVal.TryGet("In_no_" + i);
                string asqlno = ReqVal.TryGet("acode_" + i);//att_sqlno
                string work_opt = ReqVal.TryGet("work_opt_" + i);
                string seq = ReqVal.TryGet("seq_" + i);
                string seq1 = ReqVal.TryGet("seq1_" + i);
                string country = ReqVal.TryGet("country_" + i);
                string tdept = "";
                string fseq = "";
                if (dept == "t")
                    tdept = "T";
                else
                    tdept = "TE";

                fseq = Sys.formatSeq(seq, seq1, country, Sys.GetSession("seBranch"), tdept);


                //判斷狀態是否已異動,防止開雙視窗
                //SQL = "select count(*) from " + tblname + " where in_no='20200203001' and Job_status<>'NN'";
                SQL = "select count(*) from " + tblname + " where sqlno='" + tsqlno + "' and Job_status='NN'";
                object objResult = conn.ExecuteScalar(SQL);
                int cnt = (objResult == DBNull.Value || objResult == null) ? 0 : Convert.ToInt32(objResult);

                if (cnt == 0) {
                    msg = "案件 " + fseq + " 簽核失敗<BR>(流程狀態已異動，請重新整理畫面)";
                    return false;
                } else {
                    //更新todo
                    SQL = "UPDATE " + tblname + " SET";
                    SQL += " Job_status = '" + status + "' ";
                    SQL += ",resp_date = getdate() ";
                    SQL += ",approve_scode = '" + Session["scode"] + "' ";
                    SQL += ",approve_desc = " + Util.dbnull(Request["signdetail"]) + " ";
                    SQL += " WHERE sqlno='" + tsqlno + "'";
                    conn.ExecuteNonQuery(SQL);

                    DataTable dt = new DataTable();
                    SQL = "select * from " + tblname + " where sqlno = '" + tsqlno + "'";
                    conn.DataTable(SQL, dt);
                    if (dt.Rows.Count > 0) {
                        //寫入todo
                        if (status == "SY") {//簽准
                            SQL = "insert into " + tblname;
                            ColMap.Clear();
                            ColMap["pre_sqlno"] = "'" + tsqlno + "'";
                            ColMap["branch"] = "'" + dt.Rows[0]["Branch"] + "'";
                            ColMap["syscode"] = "'" + dt.Rows[0]["Syscode"] + "'";
                            ColMap["apcode"] = "'" + dt.Rows[0]["Apcode"] + "'";
                            ColMap["from_flag"] = Util.dbchar("CGRS");
                            ColMap["seq"] = Util.dbzero(dt.Rows[0].SafeRead("seq", ""));
                            ColMap["seq1"] = Util.dbchar(dt.Rows[0].SafeRead("seq1", ""));
                            ColMap["step_grade"] = Util.dbnull(dt.Rows[0].SafeRead("step_grade", ""));
                            ColMap["In_team"] = "'" + dt.Rows[0]["In_team"] + "'";
                            ColMap["case_In_scode"] = "'" + dt.Rows[0]["case_In_scode"] + "'";
                            ColMap["In_no"] = "'" + dt.Rows[0]["In_no"] + "'";
                            ColMap["Case_no"] = "'" + dt.Rows[0]["Case_no"] + "'";
                            ColMap["in_scode"] = "'" + Session["scode"] + "'";
                            ColMap["in_date"] = "getdate()";
                            ColMap["job_scode"] = Util.dbchar(Request["signidnext"]);
                            ColMap["job_team"] = Util.dbchar(job_team);
                            ColMap["job_status"] = Util.dbchar("NN");
                            if (dept == "t") {
                                ColMap["temp_rs_sqlno"] = "'" + dt.Rows[0]["temp_rs_sqlno"] + "'";
                                ColMap["dowhat"] = Util.dbchar("DC_GS");//程序官發確認,ref:cust_code.code_type='Ttodo'
                                ColMap["mark"] = Util.dbnull(Request["Mark"]);//記錄是否給代理人簽核Y:S,N:空白
                            } else {
                                ColMap["att_no"] = "'" + dt.Rows[0]["att_no"] + "'";
                                ColMap["dowhat"] = Util.dbchar("DS");//程序聯發確認,ref:cust_code.code_type='TEtodo'
                                ColMap["remark"] = Util.dbnull(Request["Mark"]);//記錄是否給代理人簽核Y:S,N:空白
                            }
                            SQL += ColMap.GetInsertSQL();
                            conn.ExecuteNonQuery(SQL);
                        }

                        if (status == "ST") {//轉上級簽核
                            SQL = "insert into " + tblname;
                            ColMap.Clear();
                            ColMap["pre_sqlno"] = "'" + tsqlno + "'";
                            ColMap["branch"] = "'" + dt.Rows[0]["Branch"] + "'";
                            ColMap["syscode"] = "'" + dt.Rows[0]["Syscode"] + "'";
                            ColMap["apcode"] = "'" + dt.Rows[0]["Apcode"] + "'";
                            ColMap["from_flag"] = Util.dbchar("CGRS");
                            ColMap["seq"] = Util.dbzero(dt.Rows[0].SafeRead("seq", ""));
                            ColMap["seq1"] = Util.dbchar(dt.Rows[0].SafeRead("seq1", ""));
                            ColMap["step_grade"] = Util.dbnull(dt.Rows[0].SafeRead("step_grade", ""));
                            ColMap["In_team"] = "'" + dt.Rows[0]["In_team"] + "'";
                            ColMap["case_In_scode"] = "'" + dt.Rows[0]["case_In_scode"] + "'";
                            ColMap["In_no"] = "'" + dt.Rows[0]["In_no"] + "'";
                            ColMap["Case_no"] = "'" + dt.Rows[0]["Case_no"] + "'";
                            ColMap["in_scode"] = "'" + Session["scode"] + "'";
                            ColMap["in_date"] = "getdate()";
                            ColMap["job_scode"] = Util.dbchar(Request["signidnext"]);
                            ColMap["job_team"] = Util.dbchar(job_team);
                            ColMap["job_status"] = Util.dbchar("NN");
                            if (dept == "t") {
                                ColMap["temp_rs_sqlno"] = "'" + dt.Rows[0]["temp_rs_sqlno"] + "'";
                                ColMap["dowhat"] = Util.dbchar("DB_GS");//主管發文簽核,ref:cust_code.code_type='Ttodo'
                                ColMap["mark"] = Util.dbnull(Request["Mark"]);//記錄是否給代理人簽核Y:S,N:空白
                            } else {
                                ColMap["att_no"] = "'" + dt.Rows[0]["att_no"] + "'";
                                ColMap["dowhat"] = Util.dbchar("DB_TS");//主管發文簽核,ref:cust_code.code_type='TEtodo'
                                ColMap["remark"] = Util.dbnull(Request["Mark"]);//記錄是否給代理人簽核Y:S,N:空白
                            }
                            SQL += ColMap.GetInsertSQL();
                            conn.ExecuteNonQuery(SQL);

                            tin_no.Add(Min_no);
                            tappl_name.Add(Request["appl_name_" + i]);
                            tcase_name.Add(Request["case_arcase_" + i] + "_" + Request["case_name_" + i]);
                            tseq.Add(fseq);
                        }

                        //更新交辦狀態
                        if (status == "SY") {//簽准
                            SQL = "";
                            if (work_opt != "P") {//新增交辦發文，不用修改客收交辦之最近狀態,2015/5/7修改
                                if (dept == "e") {
                                    SQL += "update Case_ext set stat_code = 'SY' where in_no = '" + dt.Rows[0]["In_no"] + "' and in_scode = '" + dt.Rows[0]["case_In_scode"] + "';";
                                }
                            }
                            //2016/2/22因應總契約書後補發文簽核修改
                            if (dept == "t") {
                                SQL += "update " + att_tblname + " set sign_stat = 'SY' where att_sqlno = " + asqlno;
                            } else {
                                SQL += "update " + att_tblname + " set sign_date = getdate(),sign_stat = 'SY' where att_sqlno = " + asqlno;
                            }
                            conn.ExecuteNonQuery(SQL);
                        }

                        if (status == "ST") {//轉上級簽核
                            SQL = "update " + att_tblname + " set sign_stat = 'ST' where att_sqlno = " + asqlno;
                            conn.ExecuteNonQuery(SQL);
                        }

                        tot += 1;
                    } else {
                        return false;
                    }
                }
            }
        }
        
        return true;
    }

    private void CreateMail() {
        if (Request["contract_flag"] == "Y") {
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
                    strTo.Add(Request["signidnext"] + "@saint-island.com.tw");
                    strTo = strTo.Distinct().ToList();
                    break;
            }

            string qs_deptnm = "";
            if (qs_dept == "t") {
                qs_deptnm = "國內案官發";
            } else if (qs_dept == "e") {
                qs_deptnm = "出口案發文";
            }

            string body = dobody();
            body += "<font color=blue>◎請至：商標網路作業系統－＞";
            string tsub = "簽核";
            if (Request["contract_flag"] == "Y") {
                body += "主管簽核－＞" + qs_deptnm + "簽核作業，進行簽核</font>";
                Subject += "商標網路作業系統~契約書後補先行發文之主管" + tsub + "通知";
            }

            Sys.DoSendMail(Subject, body, strFrom, strTo, strCC, strBCC);
        }
    }
    
    //信件內容
    private string dobody() {
        string tbody = "";
        tbody += "區所 : " + Sys.bName(Sys.GetSession("seBranch")) + "<br>";
        tbody += "本所編號 : " + string.Join("、", tseq.ToArray()) + "<br>";
        tbody += "接洽序號 : " + string.Join("、", tin_no.ToArray()) + "<br>";
        tbody += "案件名稱 : " + string.Join("、", tappl_name.ToArray()) + "<br>";
        tbody += "發文案性 : " + string.Join("、", tcase_name.ToArray()) + "<br>";
        tbody += "送簽件數 : 共  " + tot + " 件<br><br>";
        return tbody;
    }
</script>

<%Response.Write(strOut.ToString());%>
