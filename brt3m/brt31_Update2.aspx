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
    protected string status = "";
    protected bool contract_flag_mail = false;
    
    protected string msg = "";
    protected List<string> tin_no = new List<string>();
    protected List<string> tappl_name = new List<string>();
    protected List<string> tcase_name = new List<string>();
    protected List<string> tseq = new List<string>();
    protected List<string> mail_in_scode = new List<string>();

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
            tblname = "todo_dmt";
            dept = "t";
       } else {
            HTProgCode = "ext34";
            HTProgCap = "出口案主管簽核作業";
            tblname = "todo_ext";
            dept = "e";
        }
        
        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        HTProgCap = myToken.Title;
        DebugStr = myToken.DebugStr;
        if (HTProgRight >= 0) {
            try {
                conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");

                bool task = doUpdateDB();
                if (task) {
                    strOut.AppendLine("<div align='center'><h1>資料更新成功</h1></div>");
                    CreateMail();
                } else {
                    if (msg == "")
                        strOut.AppendLine("<div align='center'><h1>資料更新失敗</h1></div>");
                    else
                        strOut.AppendLine("<div align='center'><h1>" + msg + "</h1></div>");
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
                string Mscode = ReqVal.TryGet("code_" + i);
                string Min_no = ReqVal.TryGet("In_no_" + i);
                string Min_scode = ReqVal.TryGet("In_scode_" + i);
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
                    msg = "該筆交辦資料(" + Min_no + ")已簽核，請通知資訊部！";
                    return false;
                } else {
                    //判斷狀態是否已異動,防止開雙視窗
                    //更新todo
                    SQL = "UPDATE " + tblname + " SET";
                    SQL += " Job_status = 'NX' ";
                    SQL += ",resp_date = getdate() ";
                    SQL += ",approve_scode = '" + Session["scode"] + "' ";
                    SQL += ",approve_desc = " + Util.dbnull(Request["signdetail"]) + " ";
                    SQL += " WHERE sqlno='" + Mscode + "'";
                    conn.ExecuteNonQuery(SQL);
                    
                    //更新交辦狀態
                    if (dept == "t") {
                        SQL = "update Case_dmt set stat_code = 'NX' where in_no = '" + Min_no + "'";
                        conn.ExecuteNonQuery(SQL);
                    }
                    if (dept == "e") {
                        SQL = "update Case_ext set stat_code = 'NX' where in_no = '" + Min_no + "'";
                     conn.ExecuteNonQuery(SQL);
                    }
                    
                    if (Request["contract_flag_"+i] == "Y") {
					    contract_flag_mail=true;
                        
                        tin_no.Add(Min_no);
                        tappl_name.Add(Request["appl_name_" + i]);
                        tcase_name.Add(Request["case_arcase_" + i] + "_" + Request["case_name_" + i]);
                        tseq.Add(fseq);
                        mail_in_scode.Add(Min_scode);

                        tot += 1;
                    }
                }
            }
        }
        
        return true;
    }

    private void CreateMail() {
        if (contract_flag_mail==true) {
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
                    foreach (var s in mail_in_scode) {
                        strTo.Add(s + "@saint-island.com.tw");//正本-營洽
                        //直屬主管
                        string master_scode = Sys.getSignMaster(Sys.GetSession("SeBranch"),s,false);
                        if (master_scode != s&& !mail_in_scode.Contains(s)) {
                            strCC.Add(master_scode + "@saint-island.com.tw");//直屬主管不在正本裡則加到副本
                        }
                    }
                    
                    //抓取副本通知人員-商標部門主管
                    string master_scode1 = Sys.getSignList(Sys.GetSession("seBranch"),"", "","","grplevel=2").Select()[0]["master_scode"].ToString();
                    if (master_scode1 != "" && !strCC.Contains(master_scode1)) {
                        strCC.Add(master_scode1 + "@saint-island.com.tw");
                    }

                    strTo = strTo.Distinct().ToList();
                    strCC = strCC.Distinct().ToList();
                    break;
            }

            string qs_deptnm = "";
            if (qs_dept == "t") {
                qs_deptnm = "國內案";
            } else if (qs_dept == "e") {
                qs_deptnm = "出口案";
            }

            string body = dobody();
            body += "<br><font color=blue>◎請至：商標網路作業系統－＞";
            string tsub = "退回";
            body += "營業交辦－＞" + qs_deptnm + "編修暨交辦作業，完成契約書相關文件上傳，重新進行交辦客收作業</font>";
            Subject += "商標網路作業系統~契約書後補先行客收之主管" + tsub + "通知";

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
        tbody += "交辦案性 : " + string.Join("、", tcase_name.ToArray()) + "<br>";
        tbody += "退回件數 : 共  " + tot + " 件<br>";
        if ((Request["signdetail"] ?? "") != "") {
            tbody += "主管簽核說明 :  " + Request["signdetail"] + " <br>";
        }
        tbody += "<br>主管不同意上述契約書後補之交辦案件可先行客收。<br>";
        return tbody;
    }
</script>

<%Response.Write(strOut.ToString());%>
