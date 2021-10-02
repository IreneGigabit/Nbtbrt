<%@Page Language="C#" CodePage="65001" %>

<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Linq" %>
<%@ Import Namespace="Newtonsoft.Json" %>
<%@ Import Namespace="Newtonsoft.Json.Linq" %>


<script runat="server">
    protected string HTProgCap = "發明/創作人資料-入檔";
    private string HTProgCode = HttpContext.Current.Request["prgid"];
    protected string HTProgPrefix = HttpContext.Current.Request["prgid"];
    private int HTProgAcs = 1;
    private int HTProgRight = 0;

    protected string submitTask = "";
    protected string cust_seq = "";
    protected string cust_area = "";
    protected string msg = "";
    
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

        msg = "發明/創作人資料";
        
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

    private void ProcessAdd()
    {
        string SQLStr = "";
        DBHelper conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
        string antNO = "";
        SqlDataReader drNO = conn.ExecuteReader("SELECT RIGHT('000000' + CAST(sql+1 as varchar), 6) as sql FROM Cust_code where code_type = 'Z' and cust_code = 'Pant_no'");
        drNO.Read();
        antNO = cust_area + drNO["sql"].ToString();
        drNO.Close(); drNO.Dispose();
        
        try
        {
            SQLStr = "INSERT INTO inventor (ant_no,	ant_id,	cust_seq, ant_country, ant_cname1, ant_cname2, ant_ename1, ant_ename2, ant_tel0, ant_tel, ant_tel1, ant_zip, ant_addr1,	ant_addr2, " +
                     "ant_eaddr1, ant_eaddr2, ant_eaddr3, ant_eaddr4, apclass, same_ap, apcust_no, in_date, in_scode, ant_fcname, ant_lcname, ant_fename, ant_lename, ant_email) VALUES (";

            SQLStr += "'" + antNO + "',";
            if (ReqVal.TryGet("ant_id").Trim(' ') == "")
            {
                SQLStr += "'" + antNO + "',";
            }
            else
            {
                SQLStr += Util.dbchar(ReqVal.TryGet("ant_id")) + ",";
            }
            SQLStr += Util.dbchar(ReqVal.TryGet("cust_seq")) + ",";//maybe null
            SQLStr += "'" + ReqVal.TryGet("ant_country").ToString() + "',";
            SQLStr += Util.dbchar(ReqVal.TryGet("ant_cname1")) + ",";
            SQLStr += Util.dbchar(ReqVal.TryGet("ant_cname2")) + ",";
            SQLStr += Util.dbchar(ReqVal.TryGet("ant_ename1")) + ",";
            SQLStr += Util.dbchar(ReqVal.TryGet("ant_ename2")) + ",";
            SQLStr += "'" + ReqVal.TryGet("ant_tel0") + "',";
            SQLStr += "'" + ReqVal.TryGet("ant_tel") + "',";
            SQLStr += "'" + ReqVal.TryGet("ant_tel1") + "',";
            SQLStr += "'" + ReqVal.TryGet("ant_zip") + "',";
            SQLStr += Util.dbchar(ReqVal.TryGet("ant_addr1")) + ",";
            SQLStr += Util.dbchar(ReqVal.TryGet("ant_addr2")) + ",";
            SQLStr += Util.dbchar(ReqVal.TryGet("ant_eaddr1")) + ",";
            SQLStr += Util.dbchar(ReqVal.TryGet("ant_eaddr2")) + ",";
            SQLStr += Util.dbchar(ReqVal.TryGet("ant_eaddr3")) + ",";
            SQLStr += Util.dbchar(ReqVal.TryGet("ant_eaddr4")) + ",";
            SQLStr += Util.dbchar(ReqVal.TryGet("apclass")) + ",";
            SQLStr += "'" + ReqVal.TryGet("same_ap") + "',";
            SQLStr += Util.dbchar(ReqVal.TryGet("apcust_no")) + ",";
            SQLStr += "'" + DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss") + "',";//新增日期
            SQLStr += "'" + Sys.GetSession("scode") + "',";//scode(薪號)
            SQLStr += Util.dbchar(ReqVal.TryGet("ant_fcname")) + ",";
            SQLStr += Util.dbchar(ReqVal.TryGet("ant_lcname")) + ",";
            SQLStr += Util.dbchar(ReqVal.TryGet("ant_fename")) + ",";
            SQLStr += Util.dbchar(ReqVal.TryGet("ant_lename")) + ",";
            SQLStr += Util.dbchar(ReqVal.TryGet("ant_email")) + ")";

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
            UpdateCustCode();
        }
        msg += "成功！";
    }

    private void UpdateCustCode()//更新ant_no
    {
        string SQLStr = "";
        DBHelper conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
        try
        {
            SQLStr = "UPDATE Cust_code SET ";
            SQLStr += "sql = sql+1 ";
            SQLStr += " WHERE code_type = 'Z' and cust_code = 'Pant_no'";
            conn.ExecuteNonQuery(SQLStr);
            //都沒問題 
            conn.Commit();
        }
        catch (Exception ex)
        {
            //result = false;
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
        string SQLStr = "";
        DBHelper conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
        try
        {
            SQLStr = "UPDATE inventor SET ";
            SQLStr += "apclass = '" + ReqVal.TryGet("apclass") + "', ";
            SQLStr += "ant_id = " + Util.dbchar(ReqVal.TryGet("ant_id")) + ", ";
            SQLStr += "same_ap = '" + ReqVal.TryGet("same_ap") + "', ";
            SQLStr += "apcust_no = " + Util.dbchar(ReqVal.TryGet("apcust_no")) + ", ";
            SQLStr += "ant_country = '" + ReqVal.TryGet("ant_country") + "', ";
            SQLStr += "cust_seq = " + Util.dbchar(ReqVal.TryGet("cust_seq")) + ", ";
            SQLStr += "ant_cname1 = " + Util.dbchar(ReqVal.TryGet("ant_cname1")) + ", ";
            SQLStr += "ant_cname2 = " + Util.dbchar(ReqVal.TryGet("ant_cname2")) + ", ";
            SQLStr += "ant_ename1 = " + Util.dbchar(ReqVal.TryGet("ant_ename1")) + ", ";
            SQLStr += "ant_ename2 = " + Util.dbchar(ReqVal.TryGet("ant_ename2")) + ", ";
            SQLStr += "ant_tel0 = " + Util.dbchar(ReqVal.TryGet("ant_tel0")) + ", ";
            SQLStr += "ant_tel = " + Util.dbchar(ReqVal.TryGet("ant_tel")) + ", ";
            SQLStr += "ant_tel1 = " + Util.dbchar(ReqVal.TryGet("ant_tel1")) + ", ";
            SQLStr += "ant_zip = " + Util.dbchar(ReqVal.TryGet("ant_zip")) + ", ";
            SQLStr += "ant_addr1 = " + Util.dbchar(ReqVal.TryGet("ant_addr1")) + ", ";
            SQLStr += "ant_addr2 = " + Util.dbchar(ReqVal.TryGet("ant_addr2")) + ", ";
            SQLStr += "ant_eaddr1 = " + Util.dbchar(ReqVal.TryGet("ant_eaddr1")) + ", ";
            SQLStr += "ant_eaddr2 = " + Util.dbchar(ReqVal.TryGet("ant_eaddr2")) + ", ";
            SQLStr += "ant_eaddr3 = " + Util.dbchar(ReqVal.TryGet("ant_eaddr3")) + ", ";
            SQLStr += "ant_eaddr4 = " + Util.dbchar(ReqVal.TryGet("ant_eaddr4")) + ", ";
            SQLStr += "tran_date = '" + DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss") + "', ";
            SQLStr += "tran_scode = '" + Sys.GetSession("scode") + "', ";
            SQLStr += "ant_fcname = " + Util.dbchar(ReqVal.TryGet("ant_fcname")) + ", ";
            SQLStr += "ant_lcname = " + Util.dbchar(ReqVal.TryGet("ant_lcname")) + ", ";
            SQLStr += "ant_fename = " + Util.dbchar(ReqVal.TryGet("ant_fename")) + ", ";
            SQLStr += "ant_lename = " + Util.dbchar(ReqVal.TryGet("ant_lename")) + ", ";
            SQLStr += "ant_email = " + Util.dbchar(ReqVal.TryGet("ant_email"));
            SQLStr += " WHERE ant_no = '" + ReqVal.TryGet("ant_no") + "'";

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