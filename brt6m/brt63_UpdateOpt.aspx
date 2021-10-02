<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Linq" %>

<script runat="server">
    protected string HTProgCap = "爭救案交辦專案室作業";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "brt63";//HttpContext.Current.Request["prgid"] ?? "";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";

    protected string SQL = "";
    protected object objResult = null;
    
    protected string submitTask = "";

    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected Dictionary<string, string> ColMap = new Dictionary<string, string>();

    protected StringBuilder strOut = new StringBuilder();

    protected string Bdb = "";

    DBHelper conn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    DBHelper connopt = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    private void Page_Unload(System.Object sender, System.EventArgs e) {
        if (conn != null) conn.Dispose();
        if (connopt != null) connopt.Dispose();
    }

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");

        Bdb = Sys.tdbname(Sys.GetSession("seBranch"));
        string case_no = Request["case_no"] ?? "";

        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        HTProgCap = myToken.Title;
        DebugStr = myToken.DebugStr;
        if (HTProgRight >= 0) {
            try {
                conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
                connopt = new DBHelper(Conn.optK).Debug(Request["chkTest"] == "TEST");

                doUpdateDB();
                conn.Commit();
                connopt.Commit();
                //conn.RollBack();
                //connopt.RollBack();

                //發mail通知
                //CreateMail(case_no);

                strOut.AppendLine("<div align='center'><h1>爭救案交辦成功!!</h1></div>");
            }
            catch (Exception ex) {
                conn.RollBack();
                connopt.RollBack();
                Sys.errorLog(ex, conn.exeSQL, prgid);
                //strOut.AppendLine("<div align='center'><h1>爭救案交辦失敗("+ex.Message+")</h1></div>");
                throw;
            }

            this.DataBind();
        }
    }

    private void doUpdateDB() {
        string in_no = ReqVal.TryGet("in_no");
        string seq = ReqVal.TryGet("brt18_seq");
        string seq1 = ReqVal.TryGet("brt18_seq1");
        string case_no = ReqVal.TryGet("case_no");
        string step_grade = ReqVal.TryGet("step_grade");
        string step_date = ReqVal.TryGet("step_date");
        string rs_no = ReqVal.TryGet("brt18_rs_no");
        string todo_sqlno = ReqVal.TryGet("todo_sqlno");

        //[區所]上傳文件存檔
        Sys.updmt_attach_forcase(Context, conn, prgid, in_no);

        //[爭救案]分案主檔
        SQL = "insert into br_opt(branch,Bseq,Bseq1,Bstep_date,Bstep_grade,Bcase_date,Last_date) values (";
        SQL += "'" + Session["seBranch"] + "'," + seq + ",'" + seq1 + "'";
        SQL += ",'" + step_date + "'," + step_grade + ",'" + DateTime.Today.ToShortDateString() + "'," + Util.dbnull(ReqVal.TryGet("dfy_last_date")) + ")";
        connopt.ExecuteNonQuery(SQL);

        //抓insert後的流水號
        SQL = "SELECT SCOPE_IDENTITY() AS Current_Identity";
        string opt_sqlno = (connopt.ExecuteScalar(SQL) ?? "").ToString();

        SQL = "select max(opt_num)+1 from step_dmt where case_no='" + case_no + "' ";
        SQL += " and Seq='" + seq + "' and Seq1='" + seq1 + "'";
        SQL += " and step_grade='" + step_grade + "'";
        SQL += " and RS_no='" + rs_no + "'";
        objResult = conn.ExecuteScalar(SQL);
        int opt_num = (objResult == DBNull.Value || objResult == null) ? 1 : Convert.ToInt32(objResult);

        //[區所]進度檔
        SQL = "update step_dmt set opt_sqlno=" + opt_sqlno;
        SQL += ",opt_branch='B',opt_stat='Y'";
        SQL += ",opt_num=" + opt_num;
        SQL += " where Seq='" + seq + "'";
        SQL += " and Seq1='" + seq1 + "'";
        SQL += " and step_grade='" + step_grade + "'";
        SQL += " and RS_no='" + rs_no + "'";
        conn.ExecuteNonQuery(SQL);

        //[區所]流程檔
        SQL = "update todo_dmt set approve_scode='" + Session["scode"] + "'";
        SQL += ",resp_date=getdate()";
        SQL += ",job_status='YY'";
        SQL += ",approve_desc=" + Util.dbchar(Request["job_remark"]) + "";
        SQL += ",temp_rs_sqlno=" + opt_sqlno;
        SQL += " where sqlno=" + todo_sqlno + " and job_status='NN' ";
        conn.ExecuteNonQuery(SQL);

        //[爭救案]將洽案主檔新增到專案室,2016/3/15增加寫入契約書種類
        SQL = "insert into case_opt(Opt_sqlno,Branch,Case_no,in_scode,seq,seq1,cust_area,cust_seq,att_sql,arcase_type,arcase_class,arcase,div_arcase";
        SQL += ",service,fees,tot_case,add_service,add_fees,gs_fees,gs_curr,oth_arcase,oth_code,oth_money,ar_service,ar_fees,ar_curr,ar_code";
        SQL += ",ar_mark,discount,discount_chk,ar_chk,ar_chk1,source,cust_date,pr_date,case_date,case_num,contract_no,contract_type,stat_code";
        SQL += ",remark,new,case_stat,tot_num,tran_date,mark,rectitle_name,send_way,receipt_type,receipt_title)";
        SQL += " select '" + opt_sqlno + "','" + Session["seBranch"] + "',Case_no,in_scode,seq,seq1,cust_area,cust_seq,att_sql,arcase_type,arcase_class,arcase,div_arcase";
        SQL += ",service,fees,tot_case,add_service,add_fees,gs_fees,gs_curr,oth_arcase,oth_code,oth_money,ar_service,ar_fees,ar_curr,ar_code";
        SQL += ",ar_mark,discount,discount_chk,ar_chk,ar_chk1,source,cust_date,pr_date,case_date,case_num,contract_no,contract_type,stat_code";
        SQL += ",remark,new,case_stat,tot_num,tran_date,'N',rectitle_name,send_way,receipt_type,receipt_title";
        SQL += " from " + Bdb + ".case_dmt where case_no='" + case_no + "'";
        connopt.ExecuteNonQuery(SQL);

        //[爭救案]新增接洽記錄暫存檔
        SQL = "insert into opt_detail(Branch,Case_no,opt_sqlno,seq,seq1,s_mark,pul,tcn_ref,class,class_count,tcn_class,tcn_name,tcn_mark,in_date";
        SQL += ",apsqlno,ap_cname,ap_cname1,ap_cname2,ap_ename,ap_ename1,ap_ename2,apply_date,apply_no,issue_date,issue_no";
        SQL += ",appl_name,cappl_name,eappl_name,eappl_name1,eappl_name2,jappl_name,jappl_name1,jappl_name2,zappl_name1,zappl_name2";
        SQL += ",zname_type,oappl_name,draw,draw_file,symbol,color,agt_no,prior_date,prior_no,prior_country,open_date,rej_no";
        SQL += ",end_date,end_code,dmt_term1,dmt_term2,renewal,grp_code,good_name,good_count,remark1,remark2";
        SQL += ",remark3,remark4,tr_date,tr_scode,ref_no,ref_no1,Mseq,Mseq1,mark,class_type";
        SQL += ")";
        SQL += " select '" + Session["seBranch"] + "','" + case_no + "'," + opt_sqlno + ",seq,seq1,s_mark,pul,tcn_ref,class,class_count,tcn_class,tcn_name,tcn_mark,in_date";
        SQL += ",apsqlno,ap_cname,ap_cname1,ap_cname2,ap_ename,ap_ename1,ap_ename2,apply_date,apply_no,issue_date,issue_no";
        SQL += ",appl_name,cappl_name,eappl_name,eappl_name1,eappl_name2,jappl_name,jappl_name1,jappl_name2,zappl_name1,zappl_name2";
        SQL += ",zname_type,oappl_name,draw,draw_file,symbol,color,agt_no,prior_date,prior_no,prior_country,open_date,rej_no";
        SQL += ",end_date,end_code,dmt_term1,dmt_term2,renewal,grp_code,good_name,good_count,remark1,remark2";
        SQL += ",remark3,remark4,tr_date,tr_scode,ref_no,ref_no1,Mseq,Mseq1,mark,class_type";
        SQL += " from " + Bdb + ".dmt_temp where in_no='" + in_no + "'";
        connopt.ExecuteNonQuery(SQL);

        //[爭救案]接洽費用檔
        SQL = "insert into caseitem_opt(opt_sqlno,Branch,Case_no,item_sql,seq,seq1,item_arcase";
        SQL += ",item_service,item_fees,item_count,mark";
        SQL += ")";
        SQL += " select " + opt_sqlno + ",'" + Session["seBranch"] + "','" + case_no + "',item_sql,seq,seq1,item_arcase";
        SQL += ",item_service,item_fees,item_count,mark";
        SQL += " from " + Bdb + ".caseitem_dmt where in_no='" + in_no + "'";
        connopt.ExecuteNonQuery(SQL);

        //[爭救案]接洽商品檔
        SQL = "insert into caseopt_good(opt_sqlno,Branch,Case_no,class,dmt_grp_code";
        SQL += ",dmt_goodname,dmt_goodcount,tr_date,tr_scode,mark";
        SQL += ")";
        SQL += " select " + opt_sqlno + ",'" + Session["seBranch"] + "','" + case_no + "'";
        SQL += ",class,dmt_grp_code";
        SQL += ",dmt_goodname,dmt_goodcount,tr_date,tr_scode,mark";
        SQL += " from " + Bdb + ".casedmt_good where in_no='" + in_no + "'";
        connopt.ExecuteNonQuery(SQL);

        //[爭救案]接洽案件異動檔
        SQL = "insert into opt_tran(opt_sqlno,Branch,Case_no";
        SQL += ",agt_no1,agt_no2,mod_ap,mod_aprep,mod_apaddr,mod_agt,mod_agtaddr";
        SQL += ",mod_dmt,mod_class,mod_pul,mod_tcnref,mod_claim1,mod_claim2,mod_oth,mod_oth2";
        SQL += ",term1,term2,tran_remark1,tran_remark2,other_item,other_item1";
        SQL += ",other_item2,tr_date,tr_scode,tran_mark,mod_agttype,tran_remark3,tran_remark4";
        SQL += ")";
        SQL += " select " + opt_sqlno + ",'" + Session["seBranch"] + "','" + case_no + "'";
        SQL += ",agt_no1,agt_no2,mod_ap,mod_aprep,mod_apaddr,mod_agt,mod_agtaddr";
        SQL += ",mod_dmt,mod_class,mod_pul,mod_tcnref,mod_claim1,mod_claim2,mod_oth,mod_oth2";
        SQL += ",term1,term2,tran_remark1,tran_remark2,other_item,other_item1";
        SQL += ",other_item2,tr_date,tr_scode,tran_mark,mod_agttype,tran_remark3,tran_remark4";
        SQL += " from " + Bdb + ".dmt_tran where in_no='" + in_no + "'";
        connopt.ExecuteNonQuery(SQL);

        //[爭救案]接洽案件異動明細檔
        SQL = "insert into opt_tranlist(opt_sqlno,Branch,Case_no";
        SQL += ",mod_field,mod_type,mod_dclass,mod_count,new_no,ncname1,ncname2,nename1,nename2,ncrep,nerep,nzip";
        SQL += ",naddr1,naddr2,neaddr1,neaddr2,neaddr3,neaddr4,ntel0,ntel,ntel1,nfax,nserver_flag";
        SQL += ",old_no,ocname1,ocname2,oename1,oename2,ocrep,oerep,ozip";
        SQL += ",oaddr1,oaddr2,oeaddr1,oeaddr2,oeaddr3,oeaddr4,otel0,otel,otel1,ofax,oserver_flag";
        SQL += ",list_remark,tran_code,mark";
        SQL += ")";
        SQL += " select " + opt_sqlno + ",'" + Session["seBranch"] + "','" + case_no + "'";
        SQL += ",mod_field,mod_type,mod_dclass,mod_count,new_no,ncname1,ncname2,nename1,nename2,ncrep,nerep,nzip";
        SQL += ",naddr1,naddr2,neaddr1,neaddr2,neaddr3,neaddr4,ntel0,ntel,ntel1,nfax,nserver_flag";
        SQL += ",old_no,ocname1,ocname2,oename1,oename2,ocrep,oerep,ozip";
        SQL += ",oaddr1,oaddr2,oeaddr1,oeaddr2,oeaddr3,oeaddr4,otel0,otel,otel1,ofax,oserver_flag";
        SQL += ",list_remark,tran_code,mark";
        SQL += " from " + Bdb + ".dmt_tranlist where in_no='" + in_no + "'";
        connopt.ExecuteNonQuery(SQL);

        //[爭救案]接洽案件申請人檔
        //2011/1/27增加申請人中英文姓、名、序號及中英文證照地址
        SQL = "insert into caseopt_ap(opt_sqlno,case_no,branch,apsqlno,server_flag,apcust_no,";
        SQL += "ap_cname,ap_cname1,ap_cname2,ap_ename,ap_ename1,ap_ename2,tran_date,tran_scode,mark";
        SQL += ",ap_fcname,ap_lcname,ap_fename,ap_lename,ap_sql,ap_zip,ap_addr1,ap_addr2,ap_eaddr1,ap_eaddr2,ap_eaddr3,ap_eaddr4)";
        SQL += " select " + opt_sqlno + ",'" + case_no + "','" + Session["seBranch"] + "',apsqlno,server_flag,apcust_no,";
        SQL += "ap_cname,ap_cname1,ap_cname2,ap_ename,ap_ename1,ap_ename2,tran_date,tran_scode,mark";
        SQL += ",ap_fcname,ap_lcname,ap_fename,ap_lename,ap_sql,ap_zip,ap_addr1,ap_addr2,ap_eaddr1,ap_eaddr2,ap_eaddr3,ap_eaddr4 ";
        SQL += " from " + Bdb + ".dmt_temp_ap where in_no='" + in_no + "'";
        connopt.ExecuteNonQuery(SQL);

        //[爭救案]入流程控制檔,因爭救案系統以apcode=brt18當where條件，所以寫死apcode=brt18
        SQL = " insert into todo_opt(syscode,apcode,opt_sqlno,branch,case_no,in_scode,in_date";
        SQL += ",dowhat,job_status) values (";
        SQL += "'" + Session["syscode"] + "','brt18'," + opt_sqlno + ",'" + Session["seBranch"] + "','" + case_no + "'";
        SQL += ",'" + Session["scode"] + "',getdate(),'RE','NN')";
        connopt.ExecuteNonQuery(SQL);
    }

    private void CreateMail(string case_no) {
        string fseq = "", in_scode = "", in_scode_name = "", cust_area = "", cust_seq = "", cust_name = "", appl_name = "", arcase_name = "", last_date = "";
        SQL = "select Bseq,Bseq1,in_scode,scode_name,cust_area,cust_seq";
        SQL += " ,appl_name,arcase_name,Last_date from vbr_opt where branch='" + Session["seBranch"] + "' and case_no='" + case_no + "' and bmark='N'";
        using (SqlDataReader dr = connopt.ExecuteReader(SQL)) {
            if (dr.Read()) {
                fseq = Sys.formatSeq(dr.SafeRead("bseq", ""), dr.SafeRead("bseq1", ""), "", Sys.GetSession("seBranch"), Sys.GetSession("dept"));
                in_scode = dr.SafeRead("in_scode", "");
                in_scode_name = dr.SafeRead("scode_name", "");
                cust_area = dr.SafeRead("cust_area", "");
                cust_seq = dr.SafeRead("cust_seq", "");
                appl_name = dr.SafeRead("appl_name", "");
                arcase_name = dr.SafeRead("arcase_name", "");
                last_date = dr.GetDateTimeString("last_date", "yyyy/M/d");

                SQL = "Select RTRIM(ISNULL(ap_cname1, '')) + RTRIM(ISNULL(ap_cname2, ''))  as cust_name from apcust as c ";
                SQL += " where c.cust_area='" + cust_area + "' and c.cust_seq='" + cust_seq + "'";
                objResult = conn.ExecuteScalar(SQL);
                cust_name = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();
            }
        }

        string Subject = "國內所商標爭救案件管理系統－爭救案件收件確認通知（區所編號：" + fseq + "）";
        string strFrom = Session["sc_name"] + "<" + Session["scode"] + "@saint-island.com.tw>";
        List<string> strTo = new List<string>();
        List<string> strCC = new List<string>();
        List<string> strBCC = new List<string>();
        SQL = "select scode from sysctrl.dbo.scode_roles where branch='" + Session["SeBranch"] + "' and dept='T' and roles='opt'";
        DataTable dt = new DataTable();
        conn.DataTable(SQL, dt);

        switch (Sys.Host) {
            case "web08":
            case "localhost":
                strTo.Add(Session["scode"] + "@saint-island.com.tw");
                break;
            case "web10":
                strTo = dt.AsEnumerable().Select(r => r.Field<string>("scode") + "@saint-island.com.tw").ToList();
                strCC.Add(Session["scode"] + "@saint-island.com.tw");
                break;
            default:
                strTo = dt.AsEnumerable().Select(r => r.Field<string>("scode") + "@saint-island.com.tw").ToList();
                break;
        }

        string body = "【區所案件編號】 : <B>" + fseq + "</B><br>";
        body += "【營洽】 : <B>" + in_scode + "-" + in_scode_name + "</B><br>";
        body += "【客戶名稱】 : <B>" + cust_name + "</B><br>";
        body += "【案件名稱】 : <B>" + appl_name + "</B><br>";
        body += "【案性】 : <B>" + arcase_name + "</B><br>";
        body += "【法定期限】 : <font color=red><B>" + last_date + "</font></B><br>";
        body += "◎請至國內所商標爭救案件管理系統－＞收件作業－＞區所交辦收件確認作業　進行確認";

        Sys.DoSendMail(Subject, body, strFrom, strTo, strCC, strBCC);
    }
</script>

<%Response.Write(strOut.ToString());%>
