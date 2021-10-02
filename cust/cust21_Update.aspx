<%@Page Language="C#" CodePage="65001" %>

<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Linq" %>
<%@ Import Namespace="Newtonsoft.Json" %>
<%@ Import Namespace="Newtonsoft.Json.Linq" %>


<script runat="server">
    protected string HTProgCap = "客戶契約書資料-入檔";
    private string HTProgCode = HttpContext.Current.Request["prgid"];
    protected string HTProgPrefix = HttpContext.Current.Request["prgid"];
    private int HTProgAcs = 1;
    private int HTProgRight = 0;

    protected string prgid = "";
    protected string submitTask = "";
    protected string tf_code = "";
    protected string msg = "";
    protected string GetApcustNO = "";
    protected string uploadfield = "";
    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();

    private void Page_Load(System.Object sender, System.EventArgs e)
    {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;
        
        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");

        submitTask = Request["submitTask"] ?? "";
        prgid = Request["prgid"] ?? "";
        msg = "客戶契約書資料";
        uploadfield = Request["uploadfield"] ?? "";
        
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
            else //submitTask == "D"
            {
                msg = msg + "-停用";
                ProcessDisable();
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
    
    private void ProcessAdd()
    {
        string SQLStr = "";
        DBHelper conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
        try
        {
            string apattach_sqlno = "";
            int sql = 1; string sqlno = "";
            string YMNow = DateTime.Now.ToString("yyyyMM");
            string SQL = "SELECT sql,form_name FROM cust_code WHERE code_type='Z' AND cust_code='Zcontract'";
            SqlDataReader dr = conn.ExecuteReader(SQL);
            dr.Read();
            if (dr["form_name"].ToString() == YMNow)
            {
                sql = int.Parse(dr["sql"].ToString()) + 1;
                sqlno =  sql.ToString().PadLeft(3, '0');
                apattach_sqlno = Sys.GetSession("seBranch") + dr["form_name"].ToString() + sqlno;
                UpdateApattach_sqlno(sql, "");
            }
            else
            {
                sql = 1; sqlno = "001";
                apattach_sqlno = Sys.GetSession("seBranch") + YMNow + sqlno;
                UpdateApattach_sqlno(sql, YMNow);
            }
            dr.Close(); dr.Dispose();
            
            SQLStr = "INSERT INTO apcust_attach (apattach_sqlno,apsqlno,cust_area,cust_seq,source, in_date,in_scode,in_prgid,";
            SQLStr += "contract_no, sign_flag,company,dept, sign_scode, attach_no, attach_path,doc_type,attach_desc,attach_name,source_name,";
            SQLStr += "attach_size,attach_flag, mremark,use_dates,use_datee,remark,tran_date,tran_scode,tran_prgid) VALUES(";

            SQLStr += "'" + apattach_sqlno + "',";
            SQLStr += Util.dbnull(ReqVal.TryGet("sapsqlno_1")) + ",";
            SQLStr += Util.dbchar(ReqVal.TryGet("scust_area_1")) + ",";
            SQLStr += Util.dbchar(ReqVal.TryGet("scust_seq_1")) + ",";
            SQLStr += "'contract',";
            SQLStr += "GETDATE(),";
            SQLStr += "'" + Sys.GetSession("scode") + "'," + "'" + prgid + "',";
            
            SQLStr += "'" + apattach_sqlno + "',";//Contract_no同apattach_sqlno
            SQLStr += Util.dbnull(ReqVal.TryGet("sign_flag")) + ",";
            SQLStr += Util.dbnull(ReqVal.TryGet("company")) + ",";
            SQLStr += Util.dbnull(ReqVal.TryGet("dept")) + ",";
            SQLStr += Util.dbnull(ReqVal.TryGet("sign_scode")) + ",";
            SQLStr += Util.dbnull(ReqVal.TryGet(uploadfield+"_max_attach_no")) + ",";
            SQLStr += Util.dbnull(ReqVal.TryGet(uploadfield)) + ",";
            SQLStr += Util.dbnull(ReqVal.TryGet(uploadfield + "_doc_type")) + ",";
            SQLStr += Util.dbnull(ReqVal.TryGet(uploadfield + "_desc")) + ",";
            SQLStr += Util.dbnull(ReqVal.TryGet(uploadfield + "_name")) + ",";
            //SQLStr += Util.dbnull(ReqVal.TryGet(uploadfield + "_source_name")) + ",";
            SQLStr += Util.dbnull(ReqVal.TryGet("source_name")) + ",";
            SQLStr += Util.dbnull(ReqVal.TryGet(uploadfield + "_size")) + ",";
            //SQLStr += Util.dbnull(ReqVal.TryGet(uploadfield + "_dbflag")) + ",";//attach_flag狀態，A新增、U修改、E停用
            //SQLStr += Util.dbnull(ReqVal.TryGet(uploadfield + "_flag_name")) + ",";
            if (ReqVal.TryGet(uploadfield + "_flag_name") == "A")
            {
                SQLStr += "'U', ";
            }
            else
            {
                SQLStr += Util.dbnull(ReqVal.TryGet(uploadfield + "_flag_name")) + ",";//attach_flag狀態，A新增、U修改、E停用
            }
            
            SQLStr += Util.dbnull(ReqVal.TryGet("mremark")) + ",";//正本存放
            SQLStr += Util.dbnull(ReqVal.TryGet("use_sdate")) + ",";
            SQLStr += Util.dbnull(ReqVal.TryGet("use_edate")) + ",";
            SQLStr += Util.dbnull(ReqVal.TryGet("remark")) + ",";
            SQLStr += "GETDATE(),";
            SQLStr += "'" + Sys.GetSession("scode") + "'," + "'" + prgid + "')";
            conn.ExecuteNonQuery(SQLStr);
            //Sys.showLog(SQLStr);
            
            string SQLStr2 = ""; 
            string s = ""; string cust_seq = "";
            int custsqlno = int.Parse(ReqVal.TryGet("hatt_sql"));
            for (int i = 1; i <= custsqlno; i++)
            {
                s = ReqVal.TryGet("chkInsert_" + i);
                cust_seq = ReqVal.TryGet("scust_seq_"+i);
                if (s == "N" || cust_seq == "")
                {
                    continue;
                }
                else
                {
                    SQLStr2 = "insert into apcust_attach_ref (apattach_sqlno, apsqlno, tran_date, tran_scode, tran_prgid) VALUES(";
                    SQLStr2 += "'" + apattach_sqlno + "',";
                    SQLStr2 += Util.dbnull(ReqVal.TryGet("sapsqlno_" + i)) + ",";
                    SQLStr2 += "GETDATE(),";
                    SQLStr2 += "'" + Sys.GetSession("scode") + "'," + "'" + prgid + "')";
                    conn.ExecuteNonQuery(SQLStr2);
                    //Sys.showLog(SQLStr2);
                }
            }
            
            //都沒問題 
            conn.Commit();
            //conn.RollBack();
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
        msg += "成功！";
    }
    
    private void ProcessUpdate()
    {
        string SQLStr = "";
        DBHelper conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
        try
        {
            Sys.insert_log_table(conn, "U", prgid, "apcust_attach", "apattach_sqlno", ReqVal.TryGet("apattach_sqlno"), "");
            SQLStr = "UPDATE apcust_attach SET ";
            SQLStr += "sign_flag = " + Util.dbnull(ReqVal.TryGet("sign_flag")) + ", ";
            SQLStr += "cust_area = '" + ReqVal.TryGet("cust_area") + "', ";
            SQLStr += "cust_seq = " + Util.dbnull(ReqVal.TryGet("scust_seq_1")) + ", ";
            SQLStr += "apsqlno = " + Util.dbnull(ReqVal.TryGet("sapsqlno_1")) + ", ";
            SQLStr += "dept = " + Util.dbnull(ReqVal.TryGet("dept")) + ", ";
            SQLStr += "company = " + Util.dbnull(ReqVal.TryGet("company")) + ", ";
            SQLStr += "use_dates = " + Util.dbnull(ReqVal.TryGet("use_sdate")) + ", ";
            SQLStr += "use_datee = " + Util.dbnull(ReqVal.TryGet("use_edate")) + ", ";
            SQLStr += "attach_no = " + Util.dbnull(ReqVal.TryGet("attach_no")) + ", ";
            SQLStr += "attach_path = " + Util.dbnull(ReqVal.TryGet(uploadfield)) + ", ";
            SQLStr += "doc_type = " + Util.dbnull(ReqVal.TryGet(uploadfield + "_doc_type")) + ", ";
            SQLStr += "attach_desc = " + Util.dbnull(ReqVal.TryGet(uploadfield + "_desc")) + ", ";
            SQLStr += "attach_name = " + Util.dbnull(ReqVal.TryGet(uploadfield + "_name")) + ", ";
            SQLStr += "source_name = " + Util.dbnull(ReqVal.TryGet("source_name")) + ", ";
            SQLStr += "attach_size = " + Util.dbnull(ReqVal.TryGet(uploadfield + "_size")) + ", ";
            SQLStr += "sign_scode = " + Util.dbnull(ReqVal.TryGet("sign_scode")) + ", ";
            SQLStr += "mremark = " + Util.dbnull(ReqVal.TryGet("mremark")) + ", ";
            SQLStr += "remark = " + Util.dbnull(ReqVal.TryGet("remark")) + ", ";
            SQLStr += "tran_date = GETDATE(), ";
            SQLStr += "tran_scode = '" + Sys.GetSession("scode") + "', ";
            SQLStr += "tran_prgid = '" + prgid + "'";
            SQLStr += " WHERE apattach_sqlno = '" + ReqVal.TryGet("apattach_sqlno") + "'";
            conn.ExecuteNonQuery(SQLStr);
            //Sys.showLog(SQLStr);

            Sys.insert_log_table(conn, "U", prgid, "apcust_attach_ref", "apattach_sqlno", ReqVal.TryGet("apattach_sqlno"), "");
            string SQLDel = "delete from apcust_attach_ref where apattach_sqlno = '" + ReqVal.TryGet("apattach_sqlno") + "'";
            conn.ExecuteNonQuery(SQLDel);
            //Sys.showLog(SQLDel);

            string SQLStr2 = "";
            string s = ""; string cust_seq = "";
            int custsqlno = int.Parse(ReqVal.TryGet("hatt_sql"));
            for (int i = 1; i <= custsqlno; i++)
            {
                s = ReqVal.TryGet("chkInsert_" + i);
                cust_seq = ReqVal.TryGet("scust_seq_" + i);
                if (s == "N" || cust_seq == "")
                {
                    continue;
                }
                else
                {
                    SQLStr2 = "insert into apcust_attach_ref (apattach_sqlno, apsqlno, tran_date, tran_scode, tran_prgid) VALUES(";
                    SQLStr2 += "'" + ReqVal.TryGet("apattach_sqlno") + "',";
                    SQLStr2 += Util.dbnull(ReqVal.TryGet("sapsqlno_" + i)) + ",";
                    SQLStr2 += "GETDATE(),";
                    SQLStr2 += "'" + Sys.GetSession("scode") + "'," + "'" + prgid + "')";
                    conn.ExecuteNonQuery(SQLStr2);
                    //Sys.showLog(SQLStr2);
                }
            }
            
            //都沒問題 
            conn.Commit();
            //conn.RollBack();
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
        msg += "成功！";
    }


    private void ProcessDisable()
    {
        string SQLStr = "";
        DBHelper conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
        try
        {
            Sys.insert_log_table(conn, "U", prgid, "apcust_attach", "apattach_sqlno", ReqVal.TryGet("apattach_sqlno"), "");
            SQLStr = "UPDATE apcust_attach SET ";
            //SQLStr += "attach_flag = " + Util.dbnull(ReqVal.TryGet("attach_flag")) + ", ";
            SQLStr += "attach_flag = 'E', ";
            SQLStr += "stop_remark = " + Util.dbnull(ReqVal.TryGet("stop_remark"));
            SQLStr += " WHERE apattach_sqlno = '" + ReqVal.TryGet("apattach_sqlno") + "'";
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
        msg += "成功！";
    }

    

</script>

<%Response.Write(msg + "," + GetApcustNO);%>