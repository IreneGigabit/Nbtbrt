<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Linq"%>

<script runat="server">
    protected string HTProgCap = "程序轉案發文確認-入檔";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "brta76";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";

    protected string submitTask = "";
    protected string SQL = "";
    protected object objResult = null;

    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected Dictionary<string, string> ColMap = new Dictionary<string, string>();

    protected string logReason = "Brta76程序轉案發文確認作業";
    string[] arr_chkflag, arr_brtran_sqlno, arr_todo_sqlno, arr_seq, arr_seq1, arr_appl_name, arr_scode, arr_cust_seq, arr_cust_seq1, arr_cust_name, arr_tran_seq_branch, arr_tran_remark;
        
    protected string qs_dept = "", rs_type = "", tblname = "", tdept = "", msgdept = "";

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
	    arr_tran_remark = ReqVal.TryGet("rows_tran_remark").Split('\f');

        qs_dept = (Request["qs_dept"] ?? "").ToLower();
        if (qs_dept == "t") {
            rs_type = Sys.getRsType();
            tblname = "dmt";
            tdept = "T";
            msgdept = "國內案";
        } else {
            rs_type = Sys.getRsTypeExt();
            tblname = "ext";
            tdept = "TE";
            msgdept = "出口案";
        }
        
        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        HTProgCap = myToken.Title;
        DebugStr = myToken.DebugStr;
        if (HTProgRight >= 0) {
            try {
                conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
                connbr = new DBHelper(Conn.brp(Request["branch"])).Debug(Request["chkTest"] == "TEST");

                for (int i = 1; i < arr_chkflag.Length; i++) {
                    if (arr_chkflag[i] == "Y") {//有打勾
                        string tmp_sqlno = arr_todo_sqlno[i];
                        string tmp_seq = arr_seq[i];
                        string tmp_seq1 = arr_seq1[i];
        
                        //判斷狀態是否已異動,防止開雙視窗
                        SQL = "select count(*) from todo_"+tblname+" where sqlno='" + tmp_sqlno + "' and job_status ='NN'";
                        object objResult = conn.ExecuteScalar(SQL);
                        int cnt = (objResult == DBNull.Value || objResult == null) ? 0 : Convert.ToInt32(objResult);
                        if (cnt == 0) {
                            throw new Exception(Session["seBranch"] + "T" + tmp_seq + "-" + tmp_seq1 + "程序轉案發文處理失敗(狀態已異動，請重新整理畫面)");
                        } else {
                            update_dmt_brtran(i);
                            insert_step_dmt(i);
                            insert_todo_dmt(i);
                        }
                    }
                }

                strOut.AppendLine("<div align='center'><h1>" + msgdept + "轉案發文確認成功</h1></div>");
                conn.Commit();
                connbr.Commit();
                //conn.RollBack();
                //connbr.RollBack();
            }
            catch (Exception ex) {
                conn.RollBack();
                connbr.RollBack();
                Sys.errorLog(ex, conn.exeSQL, prgid);
                Sys.errorLog(ex, connbr.exeSQL, prgid);
                //strOut.AppendLine("<div align='center'><h1>資料更新失敗("+ex.Message+")</h1></div>");
                throw;
            }
            finally {
                conn.Dispose();
                connbr.Dispose();
            }
            this.DataBind();
        }
    }

    /// <summary>
    /// 更新轉案案件記錄檔
    /// </summary>
    private void update_dmt_brtran(int pno) {
        string tmp_brtran_sqlno = arr_brtran_sqlno[pno];
        string tmp_seq = arr_seq[pno];
        string tmp_seq1 = arr_seq1[pno];

        //新增轉案案件記錄Log檔
        Sys.insert_log_table(conn, "U", prgid, tblname + "_brtran", "brtran_sqlno", tmp_brtran_sqlno, logReason);

        //更新轉案記錄檔
        SQL = "update " + tblname + "_brtran set dc_date = getdate() ";
        SQL += " ,dc_scode = '" + Session["scode"] + "' ";
        SQL += " ,tran_date = getdate() ";
        SQL += " ,tran_scode = '" + Session["scode"] + "' ";
        SQL += " where brtran_sqlno = " + tmp_brtran_sqlno;
        conn.ExecuteNonQuery(SQL);
    }
    
    /// <summary>
    /// 新增本發進度
    /// </summary>
    private void insert_step_dmt(int pno) {
        string tmp_seq = arr_seq[pno];
        string tmp_seq1 = arr_seq1[pno];

        //取得發文序號
        string drs_no = "";

        //取得發文序號
        if (tdept == "T") {
            drs_no = Sys.getRsNo(conn, "ZS");
        } else if (tdept == "TE") {
            drs_no = Sys.getERsNo(conn, "ZS", "國內所本所發文");
        }

        if (drs_no == "") {
            throw new Exception("取得發文序號, 請通知系統人員！");
        }

        //取得案件進度
        SQL = "select step_grade+1 as step_grade,now_arcase from " + tblname + " where seq=" + tmp_seq + " and seq1='" + tmp_seq1 + "'";
        string dstep_grade = "0";
        using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
            if (dr.Read()) {
                dstep_grade = dr.SafeRead("step_grade", "0");
            } else {
                throw new Exception("找不到案件" + Session["seBranch"] + tdept + tmp_seq + "-" + tmp_seq1 + "，請通知資訊部檢查！");
            }
        }

        //入進度檔step_dmt	
        SQL = "insert into step_" + tblname + "(rs_no,branch,seq,seq1,step_grade,main_rs_no,step_date,cg,rs";
        SQL += ",rs_type,rs_class,rs_code,act_code,rs_detail,new,tran_date,tran_scode)";
        SQL += " values('" + drs_no + "','" + Session["seBranch"] + "'," + tmp_seq + ",'" + tmp_seq1 + "'";
        SQL += "," + dstep_grade + ",'" + drs_no + "','" + DateTime.Today.ToShortDateString() + "','Z','S','" + rs_type + "'";
        if (tdept == "T") {
            SQL += ",'X2','XZ2','_','轉案'";
        } else if (tdept == "TE") {
            SQL += ",'X3','EX4','_','轉案'";
        }
        SQL += ",'X',getdate(),'" + Session["scode"] + "')";
        conn.ExecuteNonQuery(SQL);

        //案件主檔now_arcase,now_grade,now_stat,step_grade
        SQL = "update " + tblname + " set now_arcase_type='" + rs_type + "'";
        if (tdept == "T") {
            SQL += ",now_arcase_class='X2'";
            SQL += ",now_arcase='XZ2'";
            SQL += ",now_act_code='_'";
            SQL += ",now_stat='XZ2'";
        } else if (tdept == "TE") {
            SQL += ",now_arcase_class='X3'";
            SQL += ",now_arcase='EX4'";
            SQL += ",now_act_code='_'";
            SQL += ",now_stat='EX4'";
        }
        SQL += ",now_grade=" + dstep_grade;
        SQL += ",step_grade=" + dstep_grade;
        SQL += ",tran_dc_date=getdate() ";
        SQL += " where seq=" + tmp_seq + " and seq1='" + tmp_seq1 + "'";
        conn.ExecuteNonQuery(SQL);

        //更新文件上傳的進度
        string attach_tblname = "";
        if (tdept == "T") {
            attach_tblname = "dmt_attach";
            SQL = "select * from dmt_attach where seq=" + tmp_seq + " and seq1='" + tmp_seq1 + "' and source='tran' and attach_flag<>'D'";
        } else {
            attach_tblname = "attach_ext";
            SQL = "select * from attach_ext where seq=" + tmp_seq + " and seq1='" + tmp_seq1 + "' and source='tran' and attach_flag<>'D'";
        }
        DataTable dtO = new DataTable();
        conn.DataTable(SQL, dtO);

        Sys sfile = new Sys();
        sfile.getFileServer(Sys.GetSession("SeBranch"), Request["prgid"]);//檔案上傳相關設定

        for (int i = 0; i < dtO.Rows.Count; i++) {
            DataRow dr = dtO.Rows[i];
            //更換檔名
            string tseq = tmp_seq.PadLeft(Sys.DmtSeq, '0');
            string aa = System.IO.Path.GetFileName(dr.SafeRead("attach_name", ""));//上傳檔名
            string ar = System.IO.Path.GetExtension(aa);//副檔名
            string lname = string.Format("{0}-{1}-{2}-{3:0000}-{4}{5}"//新檔名
                                        , Sys.GetSession("SeBranch") + tdept//0
                                        , tseq//1
                                        , tmp_seq1 != "_" ? tmp_seq1 : ""//2
                                        , Convert.ToInt32(dstep_grade)//3
                                        , dtO.Rows[i].SafeRead("attach_no", "")//4
                                        , ar);

            string strpath = sfile.gbrWebDir + "/doc/" + tmp_seq1 + "/" + tseq.Left(3) + "/" + tseq;
            if (strpath.IndexOf(".") > -1) strpath = System.IO.Path.GetDirectoryName(strpath);//如果有含檔名則只取目錄
            Sys.RenameFile(Sys.Path2Nbtbrt(strpath + "/" + aa), Sys.Path2Nbtbrt(strpath + "/" + lname), true);

            //入log
            Sys.insert_log_table(conn, "U", prgid, attach_tblname, "attach_sqlno", dr.SafeRead("attach_sqlno", ""), logReason);

            SQL = "update " + attach_tblname + " set step_grade=" + dstep_grade;
            SQL += ",attach_path=" + Util.dbchar(Sys.Path2Btbrt(strpath + "/" + lname));
            SQL += ",attach_name=" + Util.dbchar(lname);
            SQL += ",attach_flag='U' ";
            SQL += " where attach_sqlno=" + dr.SafeRead("attach_sqlno", "");

            conn.ExecuteNonQuery(SQL);
        }
    }
    
    /// <summary>
    /// 新增新單位主管確認轉案流程todo_dmt
    /// </summary>
    private void insert_todo_dmt(int pno) {
        string tmp_sqlno = arr_todo_sqlno[pno];
        string tmp_seq = arr_seq[pno];
        string tmp_seq1 = arr_seq1[pno];
        string tmp_brtran_sqlno = arr_brtran_sqlno[pno];

        //更新程序轉案發文確認處理狀態
        SQL = "update todo_" + tblname + " set job_status = 'YY' ";
        SQL += " ,approve_scode = '" + Session["scode"] + "' ";
        SQL += " ,resp_date=getdate() ";
        SQL += " where sqlno = " + tmp_sqlno;
        conn.ExecuteNonQuery(SQL);

        //新增新單位轉案記錄檔
        string temp_sqlno = "";
        SQL = "select * from " + tblname + "_brtran where brtran_sqlno=" + tmp_brtran_sqlno;
        DataTable dtBr = new DataTable();
        conn.DataTable(SQL, dtBr);
        if (dtBr.Rows.Count > 0) {
            DataRow dr = dtBr.Rows[0];
            string sc_date = dr.SafeRead("sc_date", "");
            string dc_date = dr.SafeRead("dc_date", "");
            if (sc_date != "") {
                sc_date = dr.GetDateTimeString("sc_date", "yyyy/M/d HH:mm:ss");
            }
            if (dc_date != "") {
                dc_date = dr.GetDateTimeString("dc_date", "yyyy/M/d HH:mm:ss");
            }

            SQL = "insert into " + tblname + "_brtran (tran_flag,branch,seq,seq1,cust_area,cust_seq,tran_seq_branch,tran_remark,sc_date,sc_scode,dc_date,dc_scode,tran_date,tran_scode) values (";
            SQL += "'B'," + Util.dbchar(dr.SafeRead("branch", "")) + "," + Util.dbzero(dr.SafeRead("seq", "")) + "," + Util.dbchar(dr.SafeRead("seq1", ""));
            SQL += "," + Util.dbchar(dr.SafeRead("cust_area", "")) + "," + Util.dbzero(dr.SafeRead("cust_seq", "")) + "," + Util.dbchar(dr.SafeRead("tran_seq_branch", ""));
            SQL += "," + Util.dbchar(dr.SafeRead("tran_remark", "")) + "," + Util.dbchar(sc_date) + "," + Util.dbchar(dr.SafeRead("sc_scode", ""));
            SQL += "," + Util.dbchar(dc_date) + "," + Util.dbchar(dr.SafeRead("dc_scode", "")) + ",getdate()," + Util.dbchar(Sys.GetSession("scode")) + ")";
            connbr.ExecuteNonQuery(SQL);

            //抓insert後的流水號
            SQL = "SELECT SCOPE_IDENTITY() AS Current_Identity";
            object objResult1 = connbr.ExecuteScalar(SQL);
            temp_sqlno = objResult1.ToString();
        } else {
            throw new Exception("找不到" + Session["seBranch"] + tdept + tmp_seq + "-" + tmp_seq1 + "轉案資料，請通知資訊部檢查！");
        }

        //新增新單位文件上傳暫存檔,放置原單位本發進度，所以不用新增
        string todo_fldname = "";
        if (tdept == "T") {
            todo_fldname = "temp_rs_sqlno";
        } else if (tdept == "TE") {
            todo_fldname = "att_no";
        }

        //新增新單位主管確認轉案todo
        string job_scode = Sys.getCodeName(conn, "sysctrl.dbo.grpid", "master_scode", "where grpclass='" + arr_tran_seq_branch[pno] + "' and grpid='T000'");
        string pro_scode = "";
        if (tdept == "T") {
            pro_scode = Sys.getCodeName(conn, " sysctrl.dbo.scode_group ", "scode", " where grpclass='" + arr_tran_seq_branch[pno] + "' and grpid='T210' and grptype='F' ");
        } else if (tdept == "TE") {
            pro_scode = Sys.getCodeName(conn, " sysctrl.dbo.scode_group ", "scode", " where grpclass='" + arr_tran_seq_branch[pno] + "' and grpid='T220' and grptype='F' ");
        }
        SQL = "insert into todo_" + tblname + "(syscode,apcode," + todo_fldname + ",from_flag,branch,in_scode,in_date,dowhat,job_scode,job_team,job_status) values (";
        SQL += "'" + arr_tran_seq_branch[pno] + "TBRT','" + prgid + "'," + temp_sqlno + ",'TRAN','" + arr_tran_seq_branch[pno] + "'";
        SQL += ",'" + Session["scode"] + "',getdate(),'TRAN_EM','" + job_scode + "','','NN')";
        connbr.ExecuteNonQuery(SQL);

        //Email通知新單位轉案
        SendmailBr(job_scode, pro_scode, pno);
    }

    //通知新單位轉案
    private void SendmailBr(string job_scode, string pro_scode, int pno) {
        string Subject = "國內" + (tdept == "TE" ? "出口" : "") + "商標網路作業系統－轉案通知";
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
                strTo.Add("s687@saint-island.com.tw");
                strTo.Add("m1583@saint-island.com.tw");
                break;
            default:
                strTo.Add(job_scode + "@saint-island.com.tw");
                string dept_scode = Sys.getCodeName(conn, "sysctrl.dbo.grpid", "master_scode", "where grpclass='" + arr_tran_seq_branch[pno] + "' and grpid='T000'");
                if (pro_scode != "") {
                    strCC.Add(pro_scode + "@saint-island.com.tw");
                }
                break;
        }
        string branchnm = Sys.getCodeName(conn, "sysctrl.dbo.branch_code", "branchname", "where branch='" + arr_tran_seq_branch[pno] + "'");
        string ftran_seq = Sys.formatSeq(arr_seq[pno], arr_seq1[pno], "", Sys.GetSession("seBranch"), tdept);

        string body = "<B>致: " + branchnm + " 商標部門主管</B><br><br>";
        body += "【通知日期】 : <B>" + DateTime.Today.ToShortDateString() + "</B><br>";
        body += "【區所編號】 : <B>" + ftran_seq + "</B><br>";
        body += "【案件名稱】 : <B>" + arr_appl_name[pno] + "</B><br>";
        body += "【客戶名稱】 : <B>" + arr_cust_name[pno] + "</B><br>";
        body += "【收文內容】 : <B>轉案</B><br>";
        body += "謹通知本案已轉案至 貴單位，煩請續行轉案處理(主管簽核-->確認轉案作業)，謝謝。<br>";

        Sys.DoSendMail(Subject, body, strFrom, strTo, strCC, strBCC);
    }
</script>

<%Response.Write(strOut.ToString());%>
