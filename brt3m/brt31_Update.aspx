<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Linq"%>

<script runat="server">
    protected string HTProgCap = HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "brt31";//程式檔名前綴
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
    protected string field_name = "";
    protected string status = "";

    protected string msg = "";
    protected List<string> tCase_no = new List<string>();
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
            HTProgCode = "brt31";
            HTProgCap = "國內案主管簽核作業";
            dept = "t";
            tblname = "todo_dmt";
            field_name="mark";//todo_dmt.mark記錄是否給代理人簽核Y:S,N:空白
       } else {
            HTProgCode = "ext34";
            HTProgCap = "出口案主管簽核作業";
            dept = "e";
            tblname = "todo_ext";
            field_name = "remark";//todo_ext.remark記錄是否給代理人簽核Y:S,N:空白
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

    //'****簽核狀態為轉下一單位簽核或簽准
    private bool doUpdateDB() {
        string job_team = "", job_grplevel = "";
        Sys.getScodeGrpid(Sys.GetSession("seBranch"), Request["signidnext"], ref job_team, ref job_grplevel);

        for (int i = 1; i <= Convert.ToInt32("0" + row); i++) {
            if (Request["C_" + i] == "Y") {
                string Mscode = ReqVal.TryGet("code_" + i);
                string Min_no = ReqVal.TryGet("In_no_" + i);
                string case_no = ReqVal.TryGet("case_no_" + i);
                string seq = ReqVal.TryGet("seq_" + i);
                string seq1 = ReqVal.TryGet("seq1_" + i);
                string country = ReqVal.TryGet("country_" + i);
                string tdept = "";
                string fseq = "";
                if (country == "")
                    tdept = "T";
                else
                    tdept = "TE";

                fseq = Sys.formatSeq(seq, seq1, country, Sys.GetSession("seBranch"), tdept);

                //判斷狀態是否已異動,防止開雙視窗
                //SQL = "select count(*) from " + tblname + " where in_no='20200203001' and Job_status<>'NN'";
                SQL = "select count(*) from " + tblname + " where sqlno='" + Mscode + "' and Job_status='NN'";
                object objResult = conn.ExecuteScalar(SQL);
                int cnt = (objResult == DBNull.Value || objResult == null) ? 0 : Convert.ToInt32(objResult);

                if (cnt == 0) {
                    msg = "該筆交辦資料(" + case_no + ")已簽核，請通知資訊部！";
                    return false;
                } else {
                    //更新todo
                    SQL = "UPDATE " + tblname + " SET";
                    SQL += " Job_status = '" + status + "' ";
                    SQL += ",resp_date = getdate() ";
                    SQL += ",approve_scode = '" + Session["scode"] + "' ";
                    SQL += ",approve_desc = " + Util.dbnull(Request["signdetail"]) + " ";
                    SQL += " WHERE sqlno='" + Mscode + "'";
                    conn.ExecuteNonQuery(SQL);

                    DataTable dt = new DataTable();
                    SQL = "select * from " + tblname + " where sqlno = '" + Mscode + "'";
                    conn.DataTable(SQL, dt);
                    if (dt.Rows.Count > 0) {
                        //寫入todo
                        if (status == "YY") {
                            SQL = "insert into " + tblname;
                            ColMap.Clear();
                            ColMap["pre_sqlno"] = "'" + Mscode + "'";
                            ColMap["branch"] = "'" + dt.Rows[0]["Branch"] + "'";
                            ColMap["syscode"] = "'" + dt.Rows[0]["Syscode"] + "'";
                            ColMap["apcode"] = "'" + dt.Rows[0]["Apcode"] + "'";//下一關的prgid
                            ColMap["from_flag"] = Util.dbchar("CASE");
                            ColMap["seq"] = Util.dbzero(seq);
                            ColMap["seq1"] = Util.dbchar(seq1);
                            ColMap["In_team"] = "'" + dt.Rows[0]["In_team"] + "'";
                            ColMap["case_In_scode"] = "'" + dt.Rows[0]["case_In_scode"] + "'";
                            ColMap["In_no"] = "'" + dt.Rows[0]["In_no"] + "'";
                            ColMap["Case_no"] = "'" + dt.Rows[0]["Case_no"] + "'";
                            ColMap["in_scode"] = "'" + Session["scode"] + "'";
                            ColMap["in_date"] = "getdate()";
                            ColMap["dowhat"] = Util.dbchar("DC");//客收確認
                            ColMap["job_scode"] = Util.dbchar(Request["signidnext"]);
                            ColMap["job_team"] = Util.dbchar(job_team);
                            ColMap["job_status"] = Util.dbchar("NN");
                            ColMap[field_name] = Util.dbnull(Request["Mark"]);
                            SQL += ColMap.GetInsertSQL();
                            conn.ExecuteNonQuery(SQL);
                        }

                        if (status == "YT") {
                            string tdowhat = "";
                            if (Request["armark_flag"] == "Y") {
                                tdowhat = "acc_dchk";//會計扣收入檢核
                            }
                            SQL = "insert into " + tblname;
                            ColMap.Clear();
                            ColMap["pre_sqlno"] = "'" + Mscode + "'";
                            ColMap["branch"] = "'" + dt.Rows[0]["Branch"] + "'";
                            ColMap["syscode"] = "'" + dt.Rows[0]["Syscode"] + "'";
                            ColMap["apcode"] = "'" + dt.Rows[0]["Apcode"] + "'";//下一關的prgid
                            ColMap["from_flag"] = Util.dbchar("CASE");
                            ColMap["seq"] = Util.dbzero(seq);
                            ColMap["seq1"] = Util.dbchar(seq1);
                            ColMap["In_team"] = "'" + dt.Rows[0]["In_team"] + "'";
                            ColMap["case_In_scode"] = "'" + dt.Rows[0]["case_In_scode"] + "'";
                            ColMap["In_no"] = "'" + dt.Rows[0]["In_no"] + "'";
                            ColMap["Case_no"] = "'" + dt.Rows[0]["Case_no"] + "'";
                            ColMap["in_scode"] = "'" + Session["scode"] + "'";
                            ColMap["in_date"] = "getdate()";
                            ColMap["dowhat"] = Util.dbchar(tdowhat);
                            ColMap["job_scode"] = Util.dbchar(Request["signidnext"]);
                            ColMap["job_team"] = Util.dbchar(job_team);
                            ColMap["job_status"] = Util.dbchar("NN");
                            ColMap[field_name] = Util.dbnull(Request["Mark"]);
                            SQL += ColMap.GetInsertSQL();
                            conn.ExecuteNonQuery(SQL);

                            tCase_no.Add(case_no);
                            tappl_name.Add(Request["appl_name_" + i]);
                            tcase_name.Add(Request["case_arcase_" + i] + "_" + Request["case_name_" + i]);
                            tseq.Add(fseq);
                        }

                        //更新交辦狀態
                        if (dept == "t") {
                            SQL = "update Case_dmt set stat_code = '" + status + "' where in_no = '" + dt.Rows[0]["In_no"] + "' and in_scode = '" + dt.Rows[0]["case_In_scode"] + "'";
                            conn.ExecuteNonQuery(SQL);
                        }
                        if (dept == "e") {
                            SQL = "update Case_ext set stat_code = '" + status + "' where in_no = '" + dt.Rows[0]["In_no"] + "' and in_scode = '" + dt.Rows[0]["case_In_scode"] + "'";
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
        if (Request["upload_flag"] == "Y" || Request["armark_flag"] == "Y" || Request["armarkT_flag"] == "Y" || Request["contract_flag"] == "Y") {
            string Subject = "";
            string strFrom = Session["scode"] + "@saint-island.com.tw";
            List<string> strTo = new List<string>();
            List<string> strCC = new List<string>();
            List<string> strBCC = new List<string>();
            switch (Sys.Host) {
                case "web08":
                case "localhost":
                    strTo.Add(Session["scode"] + "@saint-island.com.tw");
                    Subject = "(" + Sys.Host + "測試)" + Subject;
                    break;
                case "web10":
                    strTo.Add(Session["scode"] + "@saint-island.com.tw");
                    strBCC.Add("m1583@saint-island.com.tw");
                    Subject = "(" + Sys.Host + "測試)" + Subject;
                    break;
                default:
                    strTo.Add(Request["signidnext"] + "@saint-island.com.tw");
                    if (Request["armark_flag"] == "Y") {
                        string acc = Sys.getRoleScode("", Sys.GetSession("syscode"), Sys.GetSession("dept"), "account");
                        List<string> acc_scode = acc.Split(';').Where(p => p != "").Select(o => o + "@saint-island.com.tw").ToList();
                        strTo.AddRange(acc_scode);
                    }
                    strTo = strTo.Distinct().ToList();
                    break;
            }

            string qs_deptnm = "";
            if (qs_dept == "t") {
                qs_deptnm = "國內案";
            } else if (qs_dept == "e") {
                qs_deptnm = "出口案";
            }

            string body = dobody();
            body += "<font color=blue>◎請至：商標網路作業系統－＞";
            string tsub = "簽核";
            if (Request["upload_flag"] == "Y") {
                body += "主管簽核－＞" + qs_deptnm + "主管簽核作業，進行簽核</font>";
                Subject += "商標網路作業系統~專案指定代理人之主管" + tsub + "通知";
            } else if (Request["armark_flag"] == "Y") {
                body += "智產請款－＞" + qs_deptnm + "扣收入會計檢核作業，進行檢核</font>";
                Subject += "商標網路作業系統~扣收入交辦之會計檢核通知";
            } else if (Request["armarkT_flag"] == "Y") {
                body += "主管簽核－＞" + qs_deptnm + "主管簽核作業，進行簽核</font>";
                Subject = "商標網路作業系統~扣收入交辦之主管" + tsub + "通知";
            } else if (Request["contract_flag"] == "Y") {
                body += "主管簽核－＞" + qs_deptnm + "主管簽核作業，進行簽核</font>";
                Subject += "商標網路作業系統~契約書後補先行客收之主管" + tsub + "通知";
            }

            Sys.DoSendMail(Subject, body, strFrom, strTo, strCC, strBCC);
        }
    }
    
    //信件內容
    private string dobody() {
        string tbody = "";
        tbody += "區所 : " + Sys.bName(Sys.GetSession("seBranch")) + "<br>";
        if (Request["armark_flag"] == "Y") {
            tbody += "本所編號 : " + string.Join("、", tseq.ToArray()) + "<br>";
        }
        tbody += "交辦單號 : " + string.Join("、", tCase_no.ToArray()) + "<br>";
        tbody += "案件名稱 : " + string.Join("、", tappl_name.ToArray()) + "<br>";
        tbody += "交辦案性 : " + string.Join("、", tcase_name.ToArray()) + "<br>";
        tbody += "送簽件數 : 共  " + tot + " 件<br><br>";
        return tbody;
    }
</script>

<%Response.Write(strOut.ToString());%>
