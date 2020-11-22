<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>

<script runat="server">
    protected string HTProgCap = HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "brt25";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";

    protected string submitTask = "";
    protected string SQL = "";

    protected string uploadfield = "";
    protected string tlink = "";
    protected string seq =  "";
    protected string seq1 = "";
    protected string fseq =  "";
    protected string case_no ="";
    protected string todo_sqlno = "";
    protected string in_no = "";
    protected string step_grade = "";

    protected string casetable = "";
    protected string todo_table = "";
    protected string ctrl_table = "";
    protected string ctrl_type = "";
    
    protected string acc_scode = "";
    protected string send_acc_mail = "N";

    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected Dictionary<string, string> ColMap = new Dictionary<string, string>();

    protected StringBuilder strOut = new StringBuilder();

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");

        uploadfield = (Request["uploadfield"] ?? "").Trim();
        submitTask = (Request["submitTask"] ?? "").Trim();
        seq = (Request["seq"] ?? "").Trim();
        seq1 = (Request["seq1"] ?? "").Trim();
        fseq = (Request["fseq"] ?? "").Trim();
        case_no = (Request["case_no"] ?? "").Trim();
        todo_sqlno = (Request["todo_sqlno"] ?? "").Trim();
        in_no = (Request["in_no"] ?? "").Trim();
        step_grade = (Request["step_grade"] ?? "").Trim();

        using (DBHelper cnn = new DBHelper(Conn.Sysctrl).Debug(Request["chkTest"] == "TEST")) {
            SQL = "select scode from sysctrl.dbo.scode_roles where branch='" + Session["SeBranch"] + "' and dept='T' and roles='account' and sort='01'";
            object objResult = cnn.ExecuteScalar(SQL);
            acc_scode = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();
        }

        if (prgid.Left(3) == "brt") {
            casetable = "case_dmt";
            todo_table = "todo_dmt";
            ctrl_table = "ctrl_dmt";
            ctrl_type = "B9";
        } else if (prgid.Left(3) == "ext") {
            casetable = "case_ext";
            todo_table = "todo_ext";
            ctrl_table = "ctrl_ext";
            ctrl_type = "B9";
        }

        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        HTProgCap = myToken.Title;
        DebugStr = myToken.DebugStr;
        if (HTProgRight >= 0) {
            DBHelper conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
            try {
                //判斷狀態是否已異動,防止開雙視窗
                SQL = "select count(*) from " + todo_table + " ";
                SQL += " where sqlno='" + todo_sqlno + "' and syscode='" + Session["syscode"] + "'";
                SQL += " and seq=" + seq + " and seq1='" + seq1 + "'";
                SQL += " and dowhat like 'contractL%' and substring(job_status,1,1)='N'";
                object objResult = conn.ExecuteScalar(SQL);
                int cnt = (objResult == DBNull.Value || objResult == null) ? 0 : Convert.ToInt32(objResult);

                if (cnt == 0) {
                    conn.RollBack();
                    strOut.AppendLine("<div align='center'><h1>契約書後補作業-入檔失敗<BR>(流程狀態已異動，請重新整理畫面)</h1></div>");
                } else {
                    if (submitTask == "A") {//[後補]
                        doSave(conn);
                    } else if (submitTask == "C") {//[取消(送會計)]：表取消後至會計契約書檢核
                        doCancel(conn);
                    } else if (submitTask == "D") {//[不需後補]：契約書已上傳，不需後補
                        doNothing(conn);
                    }

                    if (send_acc_mail == "Y") CreateMail(conn);

                    //conn.Commit();
                    conn.RollBack();
                    strOut.AppendLine("<div align='center'><h1>契約書後補作業-入檔成功</h1></div>");
                }
            }
            catch (Exception ex) {
                conn.RollBack();
                Sys.errorLog(ex, conn.exeSQL, prgid);
                //strOut.AppendLine("<div align='center'><h1>契約書後補作業-入檔失敗("+ex.Message+")</h1></div>");
                throw;
            }
            finally {
                conn.Dispose();
            }
            this.DataBind();
        }
    }

    //[後補]
    private void doSave(DBHelper conn) {
        SQL = "update " + casetable + " set";
        SQL += " contract_type='" + Request["contract_type"] + "'";
        if (ReqVal.TryGet("contract_type") == "M") {
            SQL += ",contract_no='" + Request["mcontract_no"] + "'";
        } else {
            SQL += ",contract_no='" + Request["hcontract_no"] + "'";
        }
        SQL += ",contract_flag_date=getdate() ";
        SQL += " where seq=" + seq + " and seq1='" + seq1 + "' and case_no='" + case_no + "'";
        conn.ExecuteNonQuery(SQL);

        //----insert attach
        if (prgid.Left(3) == "brt") {
            SQL = "select isnull(max(attach_no),0)+1 as attach_no from dmt_attach ";
            SQL += " where seq=" + seq + " and seq1='" + seq1 + "' and step_grade='" + Request["step_grade"] + "'";
        } else {
            SQL = "select isnull(count(*),0)+1 as attach_no from caseattach_ext ";
            SQL += " where in_no='" + Request["in_no"] + "'";
        }
        object objResult = conn.ExecuteScalar(SQL);
        string attach_no = (objResult == DBNull.Value || objResult == null) ? "1" : objResult.ToString();

        Sys sfile = new Sys();
        sfile.getFileServer(Sys.GetSession("SeBranch"), prgid);//檔案上傳相關設定
        if (prgid.Left(3) == "brt") {
            //更換檔名
            string straa = (Request[uploadfield + "_name"] ?? "");//上傳檔名
            if (straa != "") {
                string strpath = sfile.gbrWebDir + "/" + Request[uploadfield+"_path"];
                string sExt = System.IO.Path.GetExtension(straa);//副檔名
                string attach_name = "";//資料庫檔名
                string newattach_path = "";//資料庫路徑

                //總契約書不用更名
                if ((Request[uploadfield + "_apattach_sqlno"] ?? "") != "") {
                    attach_name = straa;
                    newattach_path = Request[uploadfield] ?? "";
                } else {
                    attach_name = in_no + "-" + attach_no + sExt;//重新命名檔名
                    newattach_path = strpath + "/" + attach_name;//存在資料庫路徑
                    Sys.RenameFile(strpath + "/" + straa, strpath + "/" + attach_name, true);
                }

                ColMap.Clear();
                ColMap["Seq"] = "'" + seq + "'";
                ColMap["Seq1"] = "'" + seq1 + "'";
                ColMap["step_grade"] = Util.dbchar(Request["step_grade"]);
                ColMap["case_no"] = "'" + case_no + "'";
                ColMap["in_no"] = Util.dbchar(Request["in_no"]);
                ColMap["source"] = "'CASE'";
                ColMap["in_date"] = "getdate()";
                ColMap["in_scode"] = "'" + Session["scode"] + "'";
                ColMap["attach_no"] = "'" + attach_no + "'";
                ColMap["attach_path"] = "'" + Sys.Path2Btbrt(newattach_path) + "'";
                ColMap["doc_type"] = Util.dbnull(Request[uploadfield + "_doc_type"]);
                ColMap["attach_desc"] = Util.dbnull(Request[uploadfield + "_desc"]);
                ColMap["attach_name"] = Util.dbchar(attach_name);
                ColMap["source_name"] = Util.dbchar(straa);
                ColMap["attach_size"] = Util.dbnull(Request[uploadfield + "_size"]);
                ColMap["attach_flag"] = "'A'";
                ColMap["Mark"] = "''";
                ColMap["tran_date"] = "getdate()";
                ColMap["tran_scode"] = "'" + Session["scode"] + "'";
                ColMap["attach_branch"] = "''";
                ColMap["apattach_sqlno"] = Util.dbchar(Request[uploadfield + "_apattach_sqlno"]);
                SQL = "insert into dmt_attach " + ColMap.GetInsertSQL();
                conn.ExecuteNonQuery(SQL);
            }

            //2016/9/20增加客戶案件委辦書
            if (Request["contract_type"] == "M") {
                string strpath = sfile.gbrWebDir + "/" + Request[uploadfield + "_path1"];
                straa = (Request[uploadfield + "_name1"] ?? "");//上傳檔名
                if (straa != "") {
                    string sExt = System.IO.Path.GetExtension(straa);//副檔名
                    string attach_name = "";//資料庫檔名
                    string newattach_path = "";//資料庫路徑

                    attach_name = Request["in_no"] + "-" + attach_no + sExt;//重新命名檔名
                    newattach_path = strpath + "/" + attach_name;//存在資料庫路徑
                    Sys.RenameFile(strpath + "/" + straa, strpath + "/" + attach_name, true);

                    ColMap.Clear();
                    ColMap["Seq"] = "'" + seq + "'";
                    ColMap["Seq1"] = "'" + seq1 + "'";
                    ColMap["step_grade"] = Util.dbchar(Request["step_grade"]);
                    ColMap["case_no"] = "'" + case_no + "'";
                    ColMap["in_no"] = Util.dbchar(Request["in_no"]);
                    ColMap["source"] = "'CASE'";
                    ColMap["in_date"] = "getdate()";
                    ColMap["in_scode"] = "'" + Session["scode"] + "'";
                    ColMap["attach_no"] = "'" + attach_no + "'";
                    ColMap["attach_path"] = "'" + Sys.Path2Btbrt(newattach_path) + "'";
                    ColMap["doc_type"] = Util.dbnull(Request[uploadfield + "_doc_type1"]);
                    ColMap["attach_desc"] = Util.dbnull(Request[uploadfield + "_desc1"]);
                    ColMap["attach_name"] = Util.dbchar(attach_name);
                    ColMap["source_name"] = Util.dbchar(straa);
                    ColMap["attach_size"] = Util.dbnull(Request[uploadfield + "_size1"]);
                    ColMap["attach_flag"] = "'A'";
                    ColMap["Mark"] = "''";
                    ColMap["tran_date"] = "getdate()";
                    ColMap["tran_scode"] = "'" + Session["scode"] + "'";
                    ColMap["attach_branch"] = "''";
                    ColMap["apattach_sqlno"] = Util.dbchar(Request[uploadfield + "_apattach_sqlno1"]);
                    SQL = "insert into dmt_attach " + ColMap.GetInsertSQL();
                    conn.ExecuteNonQuery(SQL);
                }
            }
        } else {
            //更換檔名
            string straa = (Request[uploadfield + "_name"] ?? "");//上傳檔名
            if (straa != "") {
                string strpath = sfile.gbrWebDir + "/" + Request[uploadfield+"_path"];
                string sExt = System.IO.Path.GetExtension(straa);//副檔名
                string attach_name = "";//資料庫檔名
                string newattach_path = "";//資料庫路徑

                //總契約書不用更名
                if ((Request[uploadfield + "_apattach_sqlno"] ?? "") != "") {
                    attach_name = straa;
                    newattach_path = Request[uploadfield] ?? "";
                } else {
                    attach_name = in_no + "-" + attach_no + sExt;//重新命名檔名
                    newattach_path = strpath + "/" + attach_name;//存在資料庫路徑
                    Sys.RenameFile(strpath + "/" + straa, strpath + "/" + attach_name, true);
                }

                ColMap.Clear();
                ColMap["in_no"] = Util.dbchar(Request["in_no"]);
                ColMap["in_date"] = "getdate()";
                ColMap["in_scode"] = "'" + Session["scode"] + "'";
                ColMap["attach_path"] = "'" + Sys.Path2Btbrt(newattach_path) + "'";
                ColMap["attach_desc"] = Util.dbnull(Request[uploadfield + "_desc"]);
                ColMap["attach_name"] = Util.dbchar(attach_name);
                ColMap["attach_size"] = Util.dbnull(Request[uploadfield + "_size"]);
                ColMap["attach_branch"] = "''";
                ColMap["doc_type"] = Util.dbnull(Request[uploadfield + "_doc_type"]);
                ColMap["apattach_sqlno"] = Util.dbchar(Request[uploadfield + "_apattach_sqlno"]);
                SQL = "insert into caseattach_ext " + ColMap.GetInsertSQL();
                conn.ExecuteNonQuery(SQL);
            }

            if (Request["contract_type"] == "M") {
                string strpath = sfile.gbrWebDir + "/" + Request[uploadfield + "_path1"];
                straa = (Request[uploadfield + "_name1"] ?? "");//上傳檔名
                if (straa != "") {
                    string sExt = System.IO.Path.GetExtension(straa);//副檔名
                    string attach_name = "";//資料庫檔名
                    string newattach_path = "";//資料庫路徑

                    attach_name = Request["in_no"] + "-" + attach_no + sExt;//重新命名檔名
                    newattach_path = strpath + "/" + attach_name;//存在資料庫路徑
                    Sys.RenameFile(strpath + "/" + straa, strpath + "/" + attach_name, true);

                    ColMap.Clear();
                    ColMap["in_no"] = Util.dbchar(Request["in_no"]);
                    ColMap["in_date"] = "getdate()";
                    ColMap["in_scode"] = "'" + Session["scode"] + "'";
                    ColMap["attach_path"] = "'" + Sys.Path2Btbrt(newattach_path) + "'";
                    ColMap["attach_desc"] = Util.dbnull(Request[uploadfield + "_desc1"]);
                    ColMap["attach_name"] = Util.dbchar(attach_name);
                    ColMap["attach_size"] = Util.dbnull(Request[uploadfield + "_size1"]);
                    ColMap["attach_branch"] = "''";
                    ColMap["doc_type"] = Util.dbnull(Request[uploadfield + "_doc_type1"]);
                    ColMap["apattach_sqlno"] = Util.dbchar(Request[uploadfield + "_apattach_sqlno1"]);
                    SQL = "insert into caseattach_ext " + ColMap.GetInsertSQL();
                    conn.ExecuteNonQuery(SQL);
                }
            }
        }

        //---update todo
        update_todo(conn);

        //---insert todo to 會計 
        //2016/5/27增加判斷是否至會計，當請款註記ar_mark="D"扣收入或ar_mark=E代收代付不需經會計契約書檢核，其餘依交辦入的acc_chk判斷
        string acc_chk = (Request["acc_chk"] ?? "");
        string ar_mark = (Request["ar_mark"] ?? "");
        if (ar_mark == "D" || ar_mark == "E") acc_chk = "X";

        if (acc_chk != "X") {
            insert_todo_acc(conn);
        }

        //---銷管契約書後補期限
        insert_resp(conn);
    }
    
    //[取消(送會計)]：表取消後至會計契約書檢核
    private void doCancel(DBHelper conn) {
        //---------------[取消(送會計)]：表取消後至會計契約書檢核
        if (prgid.Left(3) == "brt") {
            Sys.insert_log_table(conn, "U", prgid, "case_dmt", "in_scode;in_no", Request["in_scode"] + ";" + Request["in_no"], "brt25契約書後補修改");
        } else if (prgid.Left(3) == "ext") {
            Sys.insert_log_table(conn, "U", prgid, "case_ext", "in_scode;in_no", Request["in_scode"] + ";" + Request["in_no"], "brt25契約書後補修改");
        }

        //註記契約書後補完成日期
        SQL = "update " + casetable + " set contract_flag_date=getdate() ";
        SQL += " where seq=" + seq + " and seq1='" + seq1 + "' and case_no='" + case_no + "'";
        conn.ExecuteNonQuery(SQL);

        //---update todo
        update_todo(conn);
        //---insert todo to 會計 
        insert_todo_acc(conn);
        //---銷管契約書後補期限
        insert_resp(conn);
    }

    //[不需後補]：契約書已上傳，不需後補
    private void doNothing(DBHelper conn) {
        if (prgid.Left(3) == "brt") {
            Sys.insert_log_table(conn, "U", prgid, "case_dmt", "in_scode;in_no", Request["in_scode"] + ";" + Request["in_no"], "brt25契約書後補修改");
        } else if (prgid.Left(3) == "ext") {
            Sys.insert_log_table(conn, "U", prgid, "case_ext", "in_scode;in_no", Request["in_scode"] + ";" + Request["in_no"], "brt25契約書後補修改");
        }

        //註記契約書後補完成日期
        SQL = "update " + casetable + " set contract_flag_date=getdate() ";
        SQL += " where seq=" + seq + " and seq1='" + seq1 + "' and case_no='" + case_no + "'";
        conn.ExecuteNonQuery(SQL);

        //---update todo
        update_todo(conn);
        //---銷管契約書後補期限
        insert_resp(conn);
    }

    private void update_todo(DBHelper conn) {
        //---update todo
        SQL = "update " + todo_table + " set job_status='YY',resp_date=getdate(),approve_scode='" + Session["scode"] + "'";
        SQL += " where sqlno='" + todo_sqlno + "' and syscode='" + Session["syscode"] + "'";
        SQL += " and seq=" + seq + " and seq1='" + seq1 + "'";
        SQL += " and dowhat like 'contractL%' and substring(job_status,1,1)='N'";
        conn.ExecuteNonQuery(SQL);
    }

    private void insert_todo_acc(DBHelper conn) {
        //---insert todo to 會計 
        SQL = "select grpid from sysctrl.dbo.scode_group where grpclass='" + Session["SeBranch"] + "' and scode='" + Request["in_scode"] + "'";
        object objResult = conn.ExecuteScalar(SQL);
        string nGrpID = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();

        SQL = "Insert Into " + todo_table + "(pre_sqlno,Branch,Syscode,Apcode,seq,seq1,step_grade,In_team,case_In_scode,In_no,Case_no,from_flag";
        SQL += ",in_scode,in_date,dowhat,Job_scode,job_team,Job_status) values (";
        SQL += todo_sqlno + ",'" + Session["SeBranch"] + "', ";
        SQL += "'" + Session["syscode"] + "', ";
        SQL += "'" + prgid + "'," + seq + ",'" + seq1 + "'," + step_grade + ",";
        SQL += "'" + nGrpID + "', '" + Request["in_scode"] + "', '" + in_no + "', '" + case_no + "','CASE', ";
        SQL += "'" + Session["scode"] + "',getdate(),'contractA', '" + acc_scode + "','','NN') ";
        conn.ExecuteNonQuery(SQL);

        send_acc_mail = "Y";
    }

    private void insert_resp(DBHelper conn) {
        //---銷管契約書後補期限
        SQL = "select * from " + ctrl_table + " where seq=" + seq + " and seq1='" + seq1 + "' and step_grade=" + step_grade;
        SQL += " and ctrl_type='" + ctrl_type + "'";
        DataTable dt = new DataTable();
        conn.DataTable(SQL, dt);
        for (int i = 0; i < dt.Rows.Count; i++) {
            if (prgid.Left(3) == "brt") {
                string sqlno = dt.Rows[i].SafeRead("sqlno", "");
                SQL = "insert into resp_dmt(sqlno,rs_no,branch,seq,seq1,step_grade,resp_grade,ctrl_type,ctrl_remark,ctrl_date,";
                SQL += "resp_date,resp_type,resp_remark,tran_date,tran_scode)";
                SQL += " values(" + sqlno + ",'" + dt.Rows[i].SafeRead("rs_no", "") + "','" + dt.Rows[i].SafeRead("branch", "") + "'," + seq + ",'" + seq1 + "'," + step_grade + ",";
                SQL += "0,'" + dt.Rows[i].SafeRead("ctrl_type", "") + "','" + dt.Rows[i].SafeRead("ctrl_remark", "") + "','" + Util.parseDBDate(dt.Rows[i].SafeRead("ctrl_date", ""),"yyyy/M/d") + "',";
                SQL += "'" + DateTime.Today.ToShortDateString() + "','','契約書後補作業銷管',";
                SQL += "getdate(),'" + Session["scode"] + "')";
                conn.ExecuteNonQuery(SQL);

                //刪除管制檔
                SQL = "delete from " + ctrl_table + " where sqlno = " + sqlno;
                conn.ExecuteNonQuery(SQL);
            } else {
                string sqlno = dt.Rows[i].SafeRead("ctrl_sqlno", "");
                SQL = "insert into resp_ext(rs_sqlno,branch,seq,seq1,step_grade,resp_grade,ctrl_type,ctrl_remark,ctrl_date,";
                SQL += "resp_date,ctrl_sqlno,ctrlgs_num,ctrlgs_sqlno,back_num,dctrlgs_num,dctrlgs_sqlno,dback_num,";
                SQL += "tran_date,tran_scode,resp_type,resp_remark)";
                SQL += " values(" + dt.Rows[i].SafeRead("rs_sqlno", "") + ",'" + dt.Rows[i].SafeRead("branch", "") + "'," + dt.Rows[i].SafeRead("seq", "") + ",'" + dt.Rows[i].SafeRead("seq1", "") + "'," + dt.Rows[i].SafeRead("step_grade", "");
                SQL += ",0,'" + dt.Rows[i].SafeRead("ctrl_type", "") + "','" + dt.Rows[i].SafeRead("ctrl_remark", "") + "','" + dt.Rows[i].SafeRead("ctrl_date", "");
                SQL += ",'" + DateTime.Today.ToShortDateString() + "'," + dt.Rows[i].SafeRead("ctrl_sqlno", "") + "," + dt.Rows[i].SafeRead("ctrlgs_num", "") + "," + Util.dbnull(dt.Rows[i].SafeRead("ctrlgs_sqlno", ""));
                SQL += "," + dt.Rows[i].SafeRead("back_num", "") + "," + dt.Rows[i].SafeRead("dctrlgs_num", "") + "," + Util.dbnull(dt.Rows[i].SafeRead("dctrlgs_sqlno", "")) + "," + dt.Rows[i].SafeRead("dback_num", "");
                SQL += ",getdate(),'" + Session["scode"] + "','','契約書後補作業銷管')";
                conn.ExecuteNonQuery(SQL);

                //稽催未回覆，註記不需回覆
                SQL = "update ctrlgs_ext set back_flag='X'";
                SQL += ",tran_date=getdate(),tran_scode='" + Session["scode"] + "'";
                SQL += " where ctrl_sqlno=" + sqlno + " and back_flag='N' ";
                conn.ExecuteNonQuery(SQL);

                //刪除管制檔
                SQL = "delete from " + ctrl_table + " where ctrl_sqlno = " + sqlno;
                conn.ExecuteNonQuery(SQL);
            }
        }
    }

    private void CreateMail(DBHelper conn) {
        string Subject = "契約書/委辦書已後補通知(" + fseq + ")";
        string strFrom = Session["scode"] + "@saint-island.com.tw";
        List<string> strTo = new List<string>();
        List<string> strCC = new List<string>();
        List<string> strBCC = new List<string>();
        switch (Sys.Host) {
            case "web08":
                strTo.Add(Session["scode"] + "@saint-island.com.tw");
                Subject = "(" + Sys.Host + "測試)" + Subject;
                break;
            case "web10":
                strTo.Add(Session["scode"] + "@saint-island.com.tw");
                strBCC.Add("m1583@saint-island.com.tw");
                Subject = "(" + Sys.Host + "測試)" + Subject;
                break;
            default:
                strTo.Add(acc_scode + "@saint-island.com.tw");
                break;
        }

        string body = "<B><font color='blue'>契約書/委辦書已後補通知，請至【會計契約書檢核作業】執行文件檢核。</font></B>" +
            "<br><br>【案件編號】：" + fseq + "　" + Request["cappl_name"];

        Sys.DoSendMail(Subject, body, strFrom, strTo, strCC, strBCC);
    }
</script>

<%Response.Write(strOut.ToString());%>
