<%@Page Language="C#" CodePage="65001" %>

<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Linq" %>
<%@ Import Namespace="Newtonsoft.Json" %>
<%@ Import Namespace="Newtonsoft.Json.Linq" %>


<script runat="server">
    protected string HTProgCap = "客戶備註資料-入檔";
    private string HTProgCode = HttpContext.Current.Request["prgid"];
    protected string HTProgPrefix = HttpContext.Current.Request["prgid"];
    private int HTProgAcs = 1;
    private int HTProgRight = 0;

    protected string prgid = "";
    protected string submitTask = "";
    protected string msg = "";
    protected string errmsg = "";
    protected string uploadfield = "";
    protected string scode = "";
    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    string rpt_del, rpt_mark_sqlno, rpt_mark_type2, rpt_att_sql;
    string rpt_syscode, rpt_spe_mark1, rpt_end_date, rpt_upd_flag;
    string txt_del, txt_mark_sqlno, txt_mark_type2, txt_att_sql, txt_dept;
    string txt_type_content1, txt_end_date, txt_upd_flag;
    string attach_del, attach_apattach_sqlno, attach_no, attach_path;
    string attach_doc_type, attach_desc, attach_name, attach_source_name;
    string attach_size, attach_flag, attach_mremark_value, attach_upd_flag;  

    private void Page_Load(System.Object sender, System.EventArgs e)
    {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;
        
        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");

        submitTask = Request["submitTask"] ?? "";
        prgid = Request["prgid"] ?? "";
        msg = "客戶備註";
        uploadfield = Request["uploadfield"] ?? "";
        scode = Sys.GetSession("scode");
        
        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        if (HTProgRight >= 0)
        {
            if (submitTask == "A")
            {
                msg = msg + "-新增";
                ProcessAdd();
            }
            else if (submitTask == "U")
            {
                msg = msg + "-修改";
                ProcessUpdate();
            }
        }
    }

    private void UpdateApattach_sqlno(int sql, string YM)
    {
        string SQLStr = "";
        DBHelper conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
        try
        {
            if (YM == "")
            {
                SQLStr = "UPDATE Cust_code SET ";
                SQLStr += "sql = " + sql;
                SQLStr += " WHERE code_type='Z' and cust_code = 'Zcontract'";
            }
            else
            {
                SQLStr = "UPDATE Cust_code SET ";
                SQLStr += "sql = 1, form_name = '" + YM + "' ";
                SQLStr += " WHERE code_type='Z' and cust_code = 'Zcontract'";
            }
            //Sys.showLog(SQLStr);
            //conn.RollBack();
            conn.ExecuteNonQuery(SQLStr);
            //都沒問題 
            conn.Commit();
            
        }
        catch (Exception ex)
        {
            conn.RollBack();
            msg += "失敗！";
            throw new Exception(msg, ex);
        }
        finally
        {
            conn.Dispose();
        }
    }
    
    private bool chkDuplicate(DBHelper conn, string mark_sqlno, string apcust_no, string att_sql, string mark_type, string mark_type2, string mark_type3, string syscode, string dept)
    {
        string SQL = "SELECT mark_sqlno FROM apcust_mark WHERE";
        SQL += " apcust_no = '" + apcust_no + "'";
        SQL += " AND att_sql = '" + att_sql + "'";
        SQL += " AND mark_type = '" + mark_type + "'";
        SQL += " AND mark_type2 = '" + mark_type2 + "'";
        SQL += " AND mark_type3 = '" + mark_type3 + "'";
        SQL += " AND syscode = '" + syscode + "'";
        SQL += " AND  dept= '" + dept + "'";
        SQL += " AND  mark_sqlno <> '" + mark_sqlno + "'";
        using (SqlDataReader dr = conn.ExecuteReader(SQL))
        {
            //Sys.showLog(SQL);
            if (!dr.HasRows)
            {
                return false;
            }
            else return true;
        }
    }
	
    
    
    private void ProcessAdd()
    {
        string SQLReport = "";
      
        DBHelper conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
        try
        {
            //報表備註
            for (int i = 1; i <= Int32.Parse(ReqVal.TryGet("hreport_sql")); i++)
            {
                rpt_del = "";  rpt_mark_sqlno = "";  rpt_mark_type2 = "";  rpt_att_sql = "";
                rpt_syscode = "";  rpt_spe_mark1 = "";  rpt_end_date = "";
                
                rpt_del = ReqVal.TryGet("rpt_del_"+i);
                rpt_mark_sqlno = ReqVal.TryGet("rpt_mark_sqlno_"+i);
                rpt_mark_type2 = ReqVal.TryGet("rpt_mark_type2_" + i);
                rpt_att_sql = ReqVal.TryGet("rpt_att_sql_" + i);
                rpt_syscode = ReqVal.TryGet("rpt_syscode_" + i);
                rpt_spe_mark1 = ReqVal.TryGet("rpt_spe_mark1_" + i);
                rpt_end_date = ReqVal.TryGet("rpt_end_date_" + i);
                //沒勾刪除,且沒有流水號
                if (rpt_del != "Y" && rpt_mark_sqlno == "")
                {
                    string mark_grp = "";
                    if (rpt_mark_type2 == "_") mark_grp = "_";
                    else mark_grp = "T";

                    if (rpt_att_sql == "0") mark_grp += "_";
                    else mark_grp += "A";

                    if (chkDuplicate(conn, rpt_mark_sqlno, ReqVal.TryGet("apcust_no"), rpt_att_sql, "cmark_report", rpt_mark_type2, "", rpt_syscode, "") == true)
                    { errmsg += "[報表備註] " + i.ToString() + ". 選項重覆\n"; }
                    else
                    {
                        SQLReport = "INSERT INTO apcust_mark (apsqlno, apcust_no, att_sql, mark_type, mark_type2, syscode, mark_grp, cust_area, cust_seq, spe_mark1, ";
                        SQLReport += "in_date, in_scode, tran_date, tran_scode, end_date) VALUES (";

                        SQLReport += Util.dbnull(ReqVal.TryGet("apsqlno")) + ",";
                        SQLReport += Util.dbchar(ReqVal.TryGet("apcust_no")) + ",";
                        SQLReport += Util.dbnull(rpt_att_sql) + ",";
                        SQLReport += Util.dbchar("cmark_report") + ",";
                        SQLReport += Util.dbchar(rpt_mark_type2) + ",";
                        SQLReport += Util.dbchar(rpt_syscode) + ",";
                        SQLReport += Util.dbnull(mark_grp) + ",";
                        SQLReport += Util.dbnull(ReqVal.TryGet("cust_area")) + ",";
                        SQLReport += Util.dbnull(ReqVal.TryGet("cust_seq")) + ",";
                        SQLReport += Util.dbnull(rpt_spe_mark1) + ",";
                        SQLReport += "GETDATE(),";
                        SQLReport += "'" + scode + "',";
                        SQLReport += "GETDATE(),";
                        SQLReport += "'" + scode + "',";
                        SQLReport += Util.dbnull(rpt_end_date) + ")";
                        conn.ExecuteNonQuery(SQLReport);
                        //Sys.showLog(SQLReport);
                    }
                }
            }
            //報表備註
            
            
            //說明備註-備註設定
            string SQLText = "";
            for (int i = 1; i <= Int32.Parse(ReqVal.TryGet("htext_sql")); i++)
            {
                txt_del = ""; txt_mark_sqlno = ""; txt_mark_type2 = ""; txt_att_sql = ""; txt_dept = "";
                txt_type_content1 = ""; txt_end_date = "";

                txt_del = ReqVal.TryGet("txt_del_" + i);
                txt_mark_sqlno = ReqVal.TryGet("txt_mark_sqlno_" + i);
                txt_mark_type2 = ReqVal.TryGet("txt_mark_type2_" + i);
                txt_att_sql = ReqVal.TryGet("txt_att_sql_" + i);
                txt_dept = ReqVal.TryGet("txt_dept_" + i);
                txt_type_content1 = ReqVal.TryGet("txt_type_content1_" + i);
                txt_end_date = ReqVal.TryGet("txt_end_date_" + i);
                
                //沒勾刪除,且沒有流水號
                if (txt_del != "Y" && txt_mark_sqlno == "")
                {
                    string mark_grp = "";
                    if (txt_mark_type2 == "T_") mark_grp = "__";
                    else mark_grp = "T_";

                    if (txt_att_sql == "0") mark_grp += "_";
                    else mark_grp += "A";
                    
                    if (chkDuplicate(conn, txt_mark_sqlno, ReqVal.TryGet("apcust_no"), txt_att_sql, "cmark_text", txt_mark_type2, "", "", txt_dept) == true)
                    { errmsg += "[說明備註] " + i.ToString() + ". 選項重覆\n"; }
                    else
                    {
                        SQLText = "INSERT INTO apcust_mark (apsqlno, apcust_no, att_sql, mark_type, mark_type2, dept, mark_grp, cust_area, cust_seq, ";
                        SQLText += "type_content1, in_date, in_scode, tran_date, tran_scode, end_date) VALUES (";

                        SQLText += Util.dbnull(ReqVal.TryGet("apsqlno")) + ",";
                        SQLText += Util.dbchar(ReqVal.TryGet("apcust_no")) + ",";
                        SQLText += Util.dbnull(txt_att_sql) + ",";
                        SQLText += Util.dbchar("cmark_text") + ",";
                        SQLText += Util.dbchar(txt_mark_type2) + ",";
                        //SQLText += Util.dbchar(txt_dept) + ",";
                        string deptStr = "|";
                        string[] d = txt_dept.Split(',');
                        for (int j = 0; j < d.Length; j++)
                        {
                            deptStr += d[j] + "|";
                        }
                        SQLText += Util.dbchar(deptStr) + ",";
                        SQLText += Util.dbnull(mark_grp) + ",";
                        SQLText += Util.dbnull(ReqVal.TryGet("cust_area")) + ",";
                        SQLText += Util.dbnull(ReqVal.TryGet("cust_seq")) + ",";
                        SQLText += Util.dbnull(txt_type_content1) + ",";
                        SQLText += "GETDATE(),";
                        SQLText += "'" + scode + "',";
                        SQLText += "GETDATE(),";
                        SQLText += "'" + scode + "',";
                        SQLText += Util.dbnull(txt_end_date) + ")";
                        conn.ExecuteNonQuery(SQLText);
                        //Sys.showLog(SQLText);
              
                    }
                }
            }//說明備註-備註設定


            //說明備註-相關檔案
            string SQLAttach = "";
            for (int i = 1; i <= Int32.Parse(ReqVal.TryGet("hattach_sql")); i++)
            {
                attach_del = ""; attach_apattach_sqlno = ""; attach_no = ""; attach_path = "";
                attach_doc_type = ""; attach_desc = ""; attach_name = ""; attach_source_name = "";
                attach_size = ""; attach_flag = ""; attach_mremark_value = "";
                
                attach_del = ReqVal.TryGet("attach_del_" + i);
                attach_apattach_sqlno = ReqVal.TryGet("attach_apattach_sqlno_" + i);
                attach_no = ReqVal.TryGet("attach_no_" + i);
                attach_path = ReqVal.TryGet("attach_path_" + i);
                attach_doc_type = ReqVal.TryGet("attach_doc_type_" + i);
                attach_desc = ReqVal.TryGet("attach_desc_" + i);
                attach_name = ReqVal.TryGet("attach_name_" + i);
                attach_source_name= ReqVal.TryGet("attach_source_name_" + i);
                attach_size = ReqVal.TryGet("attach_size_" + i);
                attach_flag = ReqVal.TryGet("attach_flag_" + i);
                attach_mremark_value = ReqVal.TryGet("attach_mremark_value_" + i);
                //attach_mremark = ReqVal.TryGet("attach_mremark_" + i);
                

                if (attach_del != "Y" && attach_apattach_sqlno == "")//沒勾刪除,且沒有流水號
                { 
                    //求取流水號
                    string apattach_sqlno = "";
                    int sql = 1; string sqlno = "";
                    string YMNow = DateTime.Now.ToString("yyyyMM");
                    string SQL = "SELECT sql,form_name FROM cust_code WHERE code_type='Z' AND cust_code='Zcontract'";

                    using (SqlDataReader dr = conn.ExecuteReader(SQL))
                    {
                        if (!dr.HasRows)
                        {
                            string ZCode = "insert into cust_code(Code_type,Cust_code,Code_name,sql,form_name)values(";
				            ZCode += "'Z','Zcontract','契約書/委任書流水號','1','"+YMNow+"')";
                            conn.ExecuteNonQuery(ZCode);
                            //Sys.showLog(ZCode);
                        }
                        else
                        {
                            dr.Read();
                            if (dr["form_name"].ToString() == YMNow)
                            {
                                sql = int.Parse(dr["sql"].ToString()) + 1;
                                sqlno = sql.ToString().PadLeft(3, '0');
                                apattach_sqlno = Sys.GetSession("seBranch") + dr["form_name"].ToString() + sqlno;
                                UpdateApattach_sqlno(sql, "");
                            }
                            else
                            {
                                sql = 1; sqlno = "001";
                                apattach_sqlno = Sys.GetSession("seBranch") + YMNow + sqlno;
                                UpdateApattach_sqlno(sql, YMNow);
                            }
                        }
                    }
                    
                    SQLAttach = "INSERT INTO apcust_attach (apattach_sqlno, apsqlno, cust_area, cust_seq ,source, in_date, in_scode, in_prgid, attach_no, attach_path, ";
                    SQLAttach += "doc_type, attach_desc, attach_name, source_name, attach_size, attach_flag, mremark, tran_date, tran_scode, tran_prgid) VALUES (";
                   
                    SQLAttach += "'" + apattach_sqlno + "',";
                    SQLAttach += Util.dbnull(ReqVal.TryGet("apsqlno")) + ",";
                    SQLAttach += Util.dbnull(ReqVal.TryGet("cust_area")) + ",";
                    SQLAttach += Util.dbnull(ReqVal.TryGet("cust_seq")) + ",";
                    SQLAttach += "'custz',";
                    SQLAttach += "GETDATE(),";
                    SQLAttach += "'" + scode + "'," + "'" + prgid + "',";
                    SQLAttach += Util.dbnull(attach_no) + ",";
                    SQLAttach += Util.dbnull(attach_path) + ",";//10
                    SQLAttach += Util.dbchar(attach_doc_type) + ",";
                    SQLAttach += Util.dbnull(attach_desc) + ",";
                    SQLAttach += Util.dbnull(attach_name) + ",";
                    SQLAttach += Util.dbnull(attach_source_name) + ",";
                    SQLAttach += Util.dbnull(attach_size) + ",";
                    SQLAttach += Util.dbnull(attach_flag) + ",";
                    SQLAttach += Util.dbnull(attach_mremark_value) + ",";
                    //string mremarkStr = "|";
                    //string[] s = attach_mremark.Split(',');
                    //for (int j = 0; j < s.Length; j++)
                    //{
                    //    mremarkStr += s[j] + "|";
                    //}
                    //SQLAttach += Util.dbnull(mremarkStr) + ",";
                    SQLAttach += "GETDATE(),";
                    SQLAttach += "'" + scode + "'," + "'" + prgid + "')";
                    conn.ExecuteNonQuery(SQLAttach);
                    //Sys.showLog(SQLAttach);
                }
            }
            
            if (errmsg != "")
            {
                conn.RollBack();
                msg += "失敗！" + "\n" + errmsg;
            }
            else
            {
                //都沒問題 
                conn.Commit();
                msg += "成功！";
            }
        }
        catch (Exception ex)
        {
            conn.RollBack();
            msg += "失敗！";
            throw new Exception(msg, ex);
        }
        finally
        {
            conn.Dispose();
        }
        
    }
    
    private void ProcessUpdate()
    {
        string SQLReport = "";
        DBHelper conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
        try
        {
            //報表備註
            for (int i = 1; i <= Int32.Parse(ReqVal.TryGet("hreport_sql")); i++)
            {
                rpt_del = ""; rpt_mark_sqlno = ""; rpt_mark_type2 = ""; rpt_att_sql = "";
                rpt_syscode = ""; rpt_spe_mark1 = ""; rpt_end_date = ""; rpt_upd_flag = "";
                rpt_del = ReqVal.TryGet("rpt_del_" + i);
                rpt_mark_sqlno = ReqVal.TryGet("rpt_mark_sqlno_" + i);
                rpt_mark_type2 = ReqVal.TryGet("rpt_mark_type2_" + i);
                rpt_att_sql = ReqVal.TryGet("rpt_att_sql_" + i);
                rpt_syscode = ReqVal.TryGet("rpt_syscode_" + i);
                rpt_spe_mark1 = ReqVal.TryGet("rpt_spe_mark1_" + i);
                rpt_end_date = ReqVal.TryGet("rpt_end_date_" + i);
                rpt_upd_flag = ReqVal.TryGet("rpt_upd_flag_" + i);

                if (rpt_del == "Y")//有勾刪除
                {
                    string SQLDel = "";
                    if (rpt_mark_sqlno != "")//有流水號表示為DB有資料
                    {
                        SQLDel = "DELETE FROM apcust_mark ";
                        SQLDel += "OUTPUT 'D', GETDATE(), " + Util.dbnull(scode) + "," + Util.dbnull(prgid) + ", DELETED.* INTO apcust_mark_log ";
                        SQLDel += "WHERE mark_sqlno = '" + rpt_mark_sqlno + "'";
                    }
                    conn.ExecuteNonQuery(SQLDel);
                    //Sys.showLog(SQLDel);
                }
                else
                {
                    string mark_grp = "";
                    mark_grp = (rpt_mark_type2 == "_") ? "_" : "T";
                    mark_grp += (rpt_att_sql == "0") ? "_" : "A";
                    if (chkDuplicate(conn, rpt_mark_sqlno, Request["apcust_no"], rpt_att_sql, "cmark_report", rpt_mark_type2, "", rpt_syscode, "") == true)
                    { errmsg += "[報表備註] " + i.ToString() + ". 選項重覆\n";}
                    else
                    {
                        if (rpt_mark_sqlno != "")//有流水號表示為修改
                        {
                            if (rpt_upd_flag == "Y")//有更新註記才要update
                            {
                                SQLReport = "update apcust_mark set ";
                                SQLReport += "apcust_no = '" + Request["apcust_no"] + "',";
                                SQLReport += "att_sql = " + Util.dbnull(rpt_att_sql) + ",";
                                SQLReport += "mark_type2 = " + Util.dbchar(rpt_mark_type2) + ",";
                                SQLReport += "syscode = " + Util.dbchar(rpt_syscode) + ",";
                                SQLReport += "mark_grp = " + Util.dbnull(mark_grp) + ",";
                                SQLReport += "spe_mark1 = " + Util.dbnull(rpt_spe_mark1) + ",";
                                SQLReport += "tran_date = GETDATE(),";
                                SQLReport += "tran_scode = " + Util.dbnull(scode) + ",";
                                SQLReport += "end_date = " + Util.dbnull(rpt_end_date);
                                SQLReport += " OUTPUT 'U', GETDATE(), " + Util.dbnull(scode) + "," + Util.dbnull(prgid) + ", DELETED.* INTO apcust_mark_log ";
                                SQLReport += " where mark_sqlno = '" + rpt_mark_sqlno + "'";
                                conn.ExecuteNonQuery(SQLReport);
                                //Sys.showLog(SQLReport);
                            }
                        }
                        else
                        {
                            SQLReport = "INSERT INTO apcust_mark (apsqlno, apcust_no, att_sql, mark_type, mark_type2, syscode, mark_grp, cust_area, cust_seq, spe_mark1, ";
                            SQLReport += "in_date, in_scode, tran_date, tran_scode, end_date) VALUES (";

                            SQLReport += Util.dbnull(ReqVal.TryGet("apsqlno")) + ",";
                            SQLReport += Util.dbchar(ReqVal.TryGet("apcust_no")) + ",";
                            SQLReport += Util.dbnull(rpt_att_sql) + ",";
                            SQLReport += Util.dbchar("cmark_report") + ",";
                            SQLReport += Util.dbchar(rpt_mark_type2) + ",";
                            SQLReport += Util.dbchar(rpt_syscode) + ",";
                            SQLReport += Util.dbnull(mark_grp) + ",";
                            SQLReport += Util.dbnull(ReqVal.TryGet("cust_area")) + ",";
                            SQLReport += Util.dbnull(ReqVal.TryGet("cust_seq")) + ",";
                            SQLReport += Util.dbnull(rpt_spe_mark1) + ",";
                            SQLReport += "GETDATE(),";
                            SQLReport += "'" + scode + "',";
                            SQLReport += "GETDATE(),";
                            SQLReport += "'" + scode + "',";
                            SQLReport += Util.dbnull(rpt_end_date) + ")";
                            conn.ExecuteNonQuery(SQLReport);
                            //Sys.showLog(SQLReport);
                        }
                    }
                }
            }//報表備註
            

            
            //說明備註-備註設定
            string SQLText = "";
            for (int i = 1; i <= Int32.Parse(ReqVal.TryGet("htext_sql")); i++)
            {
                txt_del = ""; txt_mark_sqlno = ""; txt_mark_type2 = ""; txt_att_sql = ""; txt_dept = "";
                txt_type_content1 = ""; txt_end_date = ""; txt_upd_flag = "";

                txt_del = ReqVal.TryGet("txt_del_" + i);
                txt_mark_sqlno = ReqVal.TryGet("txt_mark_sqlno_" + i);
                txt_mark_type2 = ReqVal.TryGet("txt_mark_type2_" + i);
                txt_att_sql = ReqVal.TryGet("txt_att_sql_" + i);
                txt_dept = ReqVal.TryGet("txt_dept_" + i);
                txt_type_content1 = ReqVal.TryGet("txt_type_content1_" + i);
                txt_end_date = ReqVal.TryGet("txt_end_date_" + i);
                txt_upd_flag = ReqVal.TryGet("txt_upd_flag_" + i);

                if (txt_del == "Y")//有勾刪除
                {
                    string SQLDel = "";
                    if (txt_mark_sqlno != "")//有流水號表示為DB有資料
                    {
                        SQLDel = "DELETE FROM apcust_mark ";
                        SQLDel += "OUTPUT 'D', GETDATE(), " + Util.dbnull(scode) + "," + Util.dbnull(prgid) + ", DELETED.* INTO apcust_mark_log ";
                        SQLDel += "WHERE mark_sqlno = '" + txt_mark_sqlno + "'";
                        conn.ExecuteNonQuery(SQLDel);
                        //Sys.showLog(SQLDel);
                    }
                }
                else
                {
                    string mark_grp = "";
                    mark_grp = (txt_mark_type2 == "T_") ? "__" : "T_";
                    mark_grp += (txt_att_sql == "0") ? "_" : "A";

                    string deptStr = "|";//先組dept字串，ex:|PI|PE|
                    string[] d = txt_dept.Split(',');
                    for (int j = 0; j < d.Length; j++)
                    {
                        deptStr += d[j] + "|";
                    }
                    
                    if (chkDuplicate(conn, txt_mark_sqlno, Request["apcust_no"], txt_att_sql, "cmark_text", txt_mark_type2, "", "", deptStr) == true)
                    { errmsg += "[說明備註] " + i.ToString() + ". 選項重覆\n";}
                    else
                    {
                        if (txt_mark_sqlno != "") //有流水號表示為修改
                        {
                            if (txt_upd_flag == "Y") //有更新註記才要update
                            {
                                SQLText = "update apcust_mark set ";
                                SQLText += "apcust_no = '" + Request["apcust_no"] + "',";
                                SQLText += "att_sql = " + Util.dbnull(txt_att_sql) + ",";
                                SQLText += "mark_type2 = " + Util.dbchar(txt_mark_type2) + ",";
                                SQLText += "dept = " + Util.dbchar(deptStr) + ",";
                                SQLText += "mark_grp = " + Util.dbnull(mark_grp) + ",";
                                SQLText += "type_content1 = " + Util.dbnull(txt_type_content1) + ",";
                                SQLText += "tran_date = GETDATE(), ";
                                SQLText += "tran_scode = '" + scode + "',";
                                SQLText += "end_date = " + Util.dbnull(txt_end_date) + " ";
                                SQLText += "OUTPUT 'U', GETDATE(), " + Util.dbnull(scode) + "," + Util.dbnull(prgid) + ", DELETED.* INTO apcust_mark_log ";
                                SQLText += "where mark_sqlno = '" + txt_mark_sqlno + "'";
                                conn.ExecuteNonQuery(SQLText);
                                //Sys.showLog(SQLText);
                            }
                        }
                        else
                        {
                            SQLText = "INSERT INTO apcust_mark (apsqlno, apcust_no, att_sql, mark_type, mark_type2, dept, mark_grp, cust_area, cust_seq, ";
                            SQLText += "type_content1, in_date, in_scode, tran_date, tran_scode, end_date) VALUES (";

                            SQLText += Util.dbnull(ReqVal.TryGet("apsqlno")) + ",";
                            SQLText += Util.dbchar(ReqVal.TryGet("apcust_no")) + ",";
                            SQLText += Util.dbnull(txt_att_sql) + ",";
                            SQLText += Util.dbchar("cmark_text") + ",";
                            SQLText += Util.dbchar(txt_mark_type2) + ",";
                            SQLText += Util.dbchar(deptStr) + ",";
                            SQLText += Util.dbnull(mark_grp) + ",";
                            SQLText += Util.dbnull(ReqVal.TryGet("cust_area")) + ",";
                            SQLText += Util.dbnull(ReqVal.TryGet("cust_seq")) + ",";
                            SQLText += Util.dbnull(txt_type_content1) + ",";
                            SQLText += "GETDATE(),";
                            SQLText += "'" + scode + "',";
                            SQLText += "GETDATE(),";
                            SQLText += "'" + scode + "',";
                            SQLText += Util.dbnull(txt_end_date) + ")";
                            conn.ExecuteNonQuery(SQLText);
                            //Sys.showLog(SQLText);
                        }
                    }
                }
            }//說明備註-備註設定



            //說明備註-相關檔案
            string SQLAttach = "";
            for (int i = 1; i <= Int32.Parse(ReqVal.TryGet("hattach_sql")); i++)
            {
                attach_del = ""; attach_apattach_sqlno = ""; attach_no = ""; attach_path = "";
                attach_doc_type = ""; attach_desc = ""; attach_name = ""; attach_source_name = "";
                attach_size = ""; attach_flag = ""; attach_mremark_value = ""; attach_upd_flag = "";

                attach_del = ReqVal.TryGet("attach_del_" + i);
                attach_apattach_sqlno = ReqVal.TryGet("attach_apattach_sqlno_" + i);
                attach_no = ReqVal.TryGet("attach_no_" + i);
                attach_path = ReqVal.TryGet("attach_path_" + i);
                attach_doc_type = ReqVal.TryGet("attach_doc_type_" + i);
                attach_desc = ReqVal.TryGet("attach_desc_" + i);
                attach_name = ReqVal.TryGet("attach_name_" + i);
                attach_source_name = ReqVal.TryGet("attach_source_name_" + i);
                attach_size = ReqVal.TryGet("attach_size_" + i);
                attach_flag = ReqVal.TryGet("attach_flag_" + i);
                attach_mremark_value = ReqVal.TryGet("attach_mremark_value_" + i);
                attach_upd_flag = ReqVal.TryGet("attach_upd_flag_" + i);

                if (attach_del == "Y")//有勾刪除
                {
                    if (attach_apattach_sqlno != "")//有流水號表示為DB有資料
                    {
                        string SQLDel = "DELETE FROM apcust_attach ";
                        SQLDel += "OUTPUT 'D', GETDATE(), " + Util.dbnull(scode) + "," + Util.dbnull(prgid) + ", DELETED.* INTO apcust_attach_log ";
                        SQLDel += "WHERE apattach_sqlno = '" + attach_apattach_sqlno + "'";
                        conn.ExecuteNonQuery(SQLDel);
                    }

                    string File_name = attach_path;
                    if (File_name != "")
                    {
                        System.IO.FileInfo fi = new System.IO.FileInfo(Server.MapPath(File_name));
                        if (fi.Exists)
                        {
                            //刪除檔案是將原檔改名,改名規則：檔名_年月日時分秒
                            string File_name_new = String.Format("{0}_{1}{2}", System.IO.Path.GetFileNameWithoutExtension(File_name), DateTime.Now.ToString("yyyyMMddHHmmss"), fi.Extension);
                            fi.MoveTo(fi.DirectoryName + "\\" + File_name_new);
                        }
                    }
                }
                else
                {
                    //string mremarkStr = "|";
                    //string[] s = attach_mremark.Split(',');
                    //for (int j = 0; j < s.Length; j++)
                    //{
                    //    mremarkStr += s[j] + "|";
                    //}
                    
                    if (attach_apattach_sqlno != "")//有流水號表示為修改
                    {
                        if (attach_upd_flag == "Y")//有更新註記才要update
                        {
                            SQLAttach = "update apcust_attach set ";
                            SQLAttach += "attach_no = " + Util.dbnull(attach_no) + ",";
                            SQLAttach += "attach_path = " + Util.dbnull(attach_path) + ",";
                            SQLAttach += "doc_type = " + Util.dbchar(attach_doc_type) + ",";
                            SQLAttach += "attach_desc = " + Util.dbnull(attach_desc) + ",";
                            SQLAttach += "attach_name = " + Util.dbnull(attach_name) + ",";
                            SQLAttach += "source_name = " + Util.dbnull(attach_source_name) +",";
                            SQLAttach += "attach_size = " + Util.dbnull(attach_size) + ",";
                            SQLAttach += "attach_flag = " + Util.dbnull(attach_flag) + ",";
                            SQLAttach += "mremark = " + Util.dbnull(attach_mremark_value) + ",";
                            SQLAttach += "tran_date=getdate(), ";
                            SQLAttach += "tran_scode='"+ scode +"',";
                            SQLAttach += "tran_prgid='"+ prgid +"' ";
                            SQLAttach += "OUTPUT 'U', GETDATE(), " + Util.dbnull(scode) + "," + Util.dbnull(prgid) + ", DELETED.* INTO apcust_attach_log ";
                            SQLAttach += "where apattach_sqlno = '" + attach_apattach_sqlno + "'";
                            conn.ExecuteNonQuery(SQLAttach);
                            //Sys.showLog(SQLAttach);
                        }
                    }
                    else
                    {
                        //求取流水號
                        string apattach_sqlno = "";
                        int sql = 1; string sqlno = "";
                        string YMNow = DateTime.Now.ToString("yyyyMM");
                        string SQL = "SELECT sql,form_name FROM cust_code WHERE code_type='Z' AND cust_code='Zcontract'";

                        using (SqlDataReader dr = conn.ExecuteReader(SQL))
                        {
                            if (!dr.HasRows)
                            {
                                string ZCode = "insert into cust_code(Code_type,Cust_code,Code_name,sql,form_name)values(";
                                ZCode += "'Z','Zcontract','契約書/委任書流水號','1','" + YMNow + "')";
                                conn.ExecuteNonQuery(ZCode);
                                //Sys.showLog(ZCode);
                            }
                            else
                            {
                                dr.Read();
                                if (dr["form_name"].ToString() == YMNow)
                                {
                                    sql = int.Parse(dr["sql"].ToString()) + 1;
                                    sqlno = sql.ToString().PadLeft(3, '0');
                                    apattach_sqlno = Sys.GetSession("seBranch") + dr["form_name"].ToString() + sqlno;
                                    UpdateApattach_sqlno(sql, "");
                                }
                                else
                                {
                                    sql = 1; sqlno = "001";
                                    apattach_sqlno = Sys.GetSession("seBranch") + YMNow + sqlno;
                                    UpdateApattach_sqlno(sql, YMNow);
                                }
                            }
                        } //求取流水號

                        SQLAttach = "INSERT INTO apcust_attach (apattach_sqlno, apsqlno, cust_area, cust_seq ,source, in_date, in_scode, in_prgid, attach_no, attach_path, ";
                        SQLAttach += "doc_type, attach_desc, attach_name, source_name, attach_size, attach_flag, mremark, tran_date, tran_scode, tran_prgid) VALUES (";

                        SQLAttach += "'" + apattach_sqlno + "',";
                        SQLAttach += Util.dbnull(ReqVal.TryGet("apsqlno")) + ",";
                        SQLAttach += Util.dbnull(ReqVal.TryGet("cust_area")) + ",";
                        SQLAttach += Util.dbnull(ReqVal.TryGet("cust_seq")) + ",";
                        SQLAttach += "'custz',";
                        SQLAttach += "GETDATE(),";
                        SQLAttach += "'" + scode + "'," + "'" + prgid + "',";
                        SQLAttach += Util.dbnull(attach_no) + ",";
                        SQLAttach += Util.dbnull(attach_path) + ",";//10
                        SQLAttach += Util.dbchar(attach_doc_type) + ",";
                        SQLAttach += Util.dbnull(attach_desc) + ",";
                        SQLAttach += Util.dbnull(attach_name) + ",";
                        SQLAttach += Util.dbnull(attach_source_name) + ",";
                        SQLAttach += Util.dbnull(attach_size) + ",";
                        SQLAttach += Util.dbnull(attach_flag) + ",";
                        SQLAttach += Util.dbnull(attach_mremark_value) + ",";
                        //SQLAttach += Util.dbnull(mremarkStr) + ",";
                        SQLAttach += "GETDATE(),";
                        SQLAttach += "'" + scode + "'," + "'" + prgid + "')";
                        conn.ExecuteNonQuery(SQLAttach);
                        //Sys.showLog(SQLAttach);
                    }
                }
            }//說明備註-相關檔案
        

            if (errmsg != "")
            {
                conn.RollBack();
                msg += "失敗！\n" + errmsg;
            }
            else
            {
                //都沒問題 
                conn.Commit();
                //conn.RollBack();
                msg += "成功！";
            }
        }
        catch (Exception ex)
        {
            conn.RollBack();
            msg += "失敗！";
            throw new Exception(msg, ex);
        }
        finally
        {
           conn.Dispose();
        }
        
    }


</script>

<%Response.Write(msg);%>