<%@Page Language="C#" CodePage="65001" %>

<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Linq" %>
<%@ Import Namespace="Newtonsoft.Json" %>
<%@ Import Namespace="Newtonsoft.Json.Linq" %>


<script runat="server">
    protected string HTProgCap = "聯絡人資料-入檔";
    private string HTProgCode = HttpContext.Current.Request["prgid"];
    protected string HTProgPrefix = HttpContext.Current.Request["prgid"];
    private int HTProgAcs = 1;
    private int HTProgRight = 0;

    protected string submitTask = "";
    protected string cust_seq = "";
    protected string cust_area = "";
    protected string tf_code = "";
    protected string msg = "";
    protected string UpdateDate = "";
    protected string UpdateScode = "";
    protected string prgid = "";
    
    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();

    private void Page_Load(System.Object sender, System.EventArgs e)
    {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;
        
        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");
        submitTask = Request["submitTask"] ?? "";
        cust_seq = ReqVal.TryGet("cust_seq");
        cust_area = ReqVal.TryGet("cust_area");
        prgid = Request["prgid"] ?? "";
        
        msg = "聯絡人資料";
        if (Sys.GetSession("dept") == "P")
        {
            UpdateDate = "ptran_date";
            UpdateScode = "ptran_scode";
        }
        else
	    {
            UpdateDate = "ttran_date";
            UpdateScode = "ttran_scode";
	    }
        
        
        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        //Response.Write("<br />HTProgRight = " + HTProgRight + " , " + " HTProgCode : " + HTProgCode + "<br />");
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
                Sys.insert_apcust_log("custz_att", ReqVal, prgid);
            }
        }
    }

    private void ProcessAdd()
    {
        string SQLStr = "";
        int AttSql = 1;
        //DBHelper conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
        DBHelper conn = new DBHelper(Conn.brp(Sys.GetSession("seBranch"))).Debug(Request["chkTest"] == "TEST");
        SqlDataReader dr = conn.ExecuteReader("select max(att_sql) as sql from custz_att where cust_seq = '" + cust_seq + "'");
        if (dr.Read())
        {
            if (dr["sql"] != DBNull.Value)
            {
                AttSql = int.Parse(dr["sql"].ToString()) + 1;
            }
        }
        dr.Close(); dr.Dispose();
        
        try
        {
            SQLStr = "INSERT INTO custz_att (cust_area,	cust_seq, att_sql, dept, attention,	att_company, att_title,	att_dept, att_tel0,	att_tel, att_tel1,	att_mobile, " +
                     "att_fax, att_zip,	att_addr1, att_addr2, att_email, att_mag, att_code, " + UpdateDate + ", " + UpdateScode + ", mark) values(";
            SQLStr += "'" + cust_area + "',";
            SQLStr += "'" + cust_seq + "',";
            SQLStr += "'" + AttSql.ToString() + "',";
            SQLStr += "'" + Sys.GetSession("dept") + "',";
            SQLStr += Util.dbchar(ReqVal.TryGet("attention_1")) +",";
            SQLStr += Util.dbchar(ReqVal.TryGet("att_company_1")) + ",";
            SQLStr += Util.dbchar(ReqVal.TryGet("att_title_1")) + ",";
            SQLStr += Util.dbchar(ReqVal.TryGet("att_dept_1")) + ",";
            SQLStr += "'" + ReqVal.TryGet("att_tel0_1") + "',";
            SQLStr += "'" + ReqVal.TryGet("att_tel_1") + "',";
            SQLStr += "'" + ReqVal.TryGet("att_tel1_1") + "',";
            SQLStr += "'" + ReqVal.TryGet("att_mobile_1") + "',";
            SQLStr += "'" + ReqVal.TryGet("att_fax_1") + "',";
            SQLStr += "'" + ReqVal.TryGet("att_zip_1") + "',";
            SQLStr += Util.dbchar(ReqVal.TryGet("att_addr1_1")) + ",";
            SQLStr += Util.dbchar(ReqVal.TryGet("att_addr2_1")) + ",";
            SQLStr += Util.dbchar(ReqVal.TryGet("att_email_1")) + ",";
            SQLStr += "'" + ReqVal.TryGet("att_mag_1") + "',";
            SQLStr += "'NN',";//att_code-NN(正常_新增)
            SQLStr += "'" + DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss") + "',";//專利異動日期
            SQLStr += "'" + Sys.GetSession("scode") + "',";//ptran_scode(薪號)
            SQLStr += Util.dbchar(ReqVal.TryGet("mark_1")) + ")";
            //Sys.showLog(SQLStr);
            //conn.Dispose();
            //return;
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
    
    private void ProcessUpdate()
    {
        string SQLStr = "";
        //DBHelper conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
        DBHelper conn = new DBHelper(Conn.brp(Sys.GetSession("seBranch"))).Debug(Request["chkTest"] == "TEST");
        try
        {
            SQLStr = "UPDATE custz_att SET ";
            SQLStr += "dept = '" + ReqVal.TryGet("dept_1") + "', ";
            SQLStr += "attention = " + Util.dbchar(ReqVal.TryGet("attention_1")) + ", ";
            SQLStr += "att_company = " + Util.dbchar(ReqVal.TryGet("att_company_1")) + ", ";
            SQLStr += "att_title = " + Util.dbchar(ReqVal.TryGet("att_title_1"))+ ", ";
            SQLStr += "att_dept = " + Util.dbchar(ReqVal.TryGet("att_dept_1")) + ", ";
            SQLStr += "att_tel0 = '" + ReqVal.TryGet("att_tel0_1") + "', ";
            SQLStr += "att_tel = '" + ReqVal.TryGet("att_tel_1") + "', ";
            SQLStr += "att_tel1 = '" + ReqVal.TryGet("att_tel1_1") + "', ";
            SQLStr += "att_mobile = '" + ReqVal.TryGet("att_mobile_1") + "', ";
            SQLStr += "att_fax = '" + ReqVal.TryGet("att_fax_1") + "', ";
            SQLStr += "att_zip = '" + ReqVal.TryGet("att_zip_1") + "', ";
            SQLStr += "att_addr1 = " + Util.dbchar(ReqVal.TryGet("att_addr1_1")) + ", ";
            SQLStr += "att_addr2 = " + Util.dbchar(ReqVal.TryGet("att_addr2_1")) + ", ";
            SQLStr += "att_email = " + Util.dbchar(ReqVal.TryGet("att_email_1")) + ", ";
            SQLStr += "att_mag	= '" + ReqVal.TryGet("att_mag_1") + "', ";

            string AttCode = (ReqVal.TryGet("att_code_1") == "NN") ? "NU" : ReqVal.TryGet("att_code_1");
            SQLStr += "att_code = '" + AttCode +"', ";
            
            SQLStr += UpdateDate + "= '" + DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss") + "', ";
            SQLStr += UpdateScode + "= '" + Sys.GetSession("scode") + "', ";
            SQLStr += "mark = '" + ReqVal.TryGet("mark") + "'";

            SQLStr += " WHERE cust_seq = '" + ReqVal.TryGet("cust_seq") + "' AND att_sql = '" + ReqVal.TryGet("att_sql_1") + "'";

            //Sys.showLog(SQLStr);
            //conn.Dispose();
            //return;
            //Sys.insert_log_table(conn, "D", prgid, "dmt_attach", "attach_sqlno", attach_sqlno, "");
            //Sys.insert_log_table(conn, "U", prgid, "apcust", ReqVal, "");
            
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

<%Response.Write(msg);%>