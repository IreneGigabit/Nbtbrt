<%@Page Language="C#" CodePage="65001" %>

<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Linq" %>
<%@ Import Namespace="Newtonsoft.Json" %>
<%@ Import Namespace="Newtonsoft.Json.Linq" %>


<script runat="server">
    protected string HTProgCap = "申請人資料-入檔";
    private string HTProgCode = HttpContext.Current.Request["prgid"];
    protected string HTProgPrefix = HttpContext.Current.Request["prgid"];
    private int HTProgAcs = 1;
    private int HTProgRight = 0;

    protected string prgid = "";
    protected string submitTask = "";
    protected string tf_code = "";
    protected string msg = "";
    protected string GetApcustNO = "";
    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();

    private void Page_Load(System.Object sender, System.EventArgs e)
    {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;
        
        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");

        submitTask = Request["submitTask"] ?? "";
        prgid = Request["prgid"] ?? "";
        msg = "申請人資料";
        
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
                Sys.insert_apcust_log("apcust", ReqVal, prgid);
            }
        }
    }

    private void ProcessAdd()
    {
        string SQLStr = "";
        //DBHelper conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
        DBHelper conn = new DBHelper(Conn.brp(Sys.GetSession("seBranch"))).Debug(Request["chkTest"] == "TEST");
        SqlDataReader dr = conn.ExecuteReader("select max(apsqlno) from apcust");
        dr.Read();
        int SqlNo = int.Parse(dr[0].ToString()) + 1;
        dr.Close(); dr.Dispose();

        GetApcustNO = ReqVal.TryGet("apcust_no").Trim();
        if (ReqVal.TryGet("apclass") == "AA" || ReqVal.TryGet("apclass") == "CA")
        {
            SqlDataReader drNO = conn.ExecuteReader("SELECT RIGHT('0' + CAST(sql+1 as varchar), 4) as sql FROM Cust_code where code_type='Z' and cust_code = '" + ReqVal.TryGet("apclass").Substr(0, 1) + "'");
            drNO.Read();
            GetApcustNO = ReqVal.TryGet("apclass") + drNO["sql"].ToString();
            drNO.Close(); drNO.Dispose();
            UpdateCustCode(ReqVal.TryGet("apclass").Substr(0, 1));
        }

        string CustArea = ""; int CustSeq = 0;
        SqlDataReader drCustz = conn.ExecuteReader("SELECT cust_area, cust_seq, id_no FROM custz WHERE id_no = '" + GetApcustNO + "'");
        if (drCustz.Read())
        {
            CustArea = drCustz["cust_area"].ToString();
            CustSeq = int.Parse(drCustz["cust_seq"].ToString());
        }
        drCustz.Close(); drCustz.Dispose();
        
        try
        {
            SQLStr = "INSERT INTO apcust (apsqlno, apcust_no, apclass, cust_area, cust_seq, ap_cname1, ap_cname2, ap_ename1, ap_ename2, ap_crep, ap_erep, " +
                     "ap_country, ap_zip, ap_addr1, ap_addr2, ap_eaddr1, ap_eaddr2, ap_eaddr3, ap_eaddr4, apatt_zip, apatt_addr1, apatt_addr2, apatt_tel0, apatt_tel, apatt_tel1, apatt_fax, " +
                     "in_date, in_scode, ap_code, ap_title, ap_fcname, ap_lcname, ap_fename, ap_lename, apatt_email) values(";
            
            SQLStr += "'" + SqlNo.ToString() + "',";
            if (GetApcustNO == "") GetApcustNO = ReqVal.TryGet("apcust_no");
            SQLStr += "'" + GetApcustNO + "',";
            
            SQLStr += "'" + ReqVal.TryGet("apclass") + "',";
            //cust_area、cust_seq--對應custz 檔若有對應則表此資料亦為客戶。N→cust_seq、空值→0
            if (CustArea == "" && CustSeq == 0)
            {
                SQLStr += "default,";
                SQLStr += "default,";
            }
            else
            {
                SQLStr += "'" + CustArea + "',";
                SQLStr += "'" + CustSeq.ToString() + "',";
            }
            
            SQLStr += Util.dbchar(ReqVal.TryGet("ap_cname1")) + ",";
            SQLStr += Util.dbchar(ReqVal.TryGet("ap_cname2")) + ",";
            SQLStr += Util.dbchar(ReqVal.TryGet("ap_ename1")) + ",";
            SQLStr += Util.dbchar(ReqVal.TryGet("ap_ename2")) + ",";
            SQLStr += Util.dbchar(ReqVal.TryGet("ap_crep")) + ",";
            SQLStr += Util.dbchar(ReqVal.TryGet("ap_erep")) + ",";

            SQLStr += "'" + ReqVal.TryGet("ap_country") + "',";
            SQLStr += "'" + ReqVal.TryGet("ap_zip") + "',";
            SQLStr += Util.dbchar(ReqVal.TryGet("ap_addr1")) + ",";
            SQLStr += Util.dbchar(ReqVal.TryGet("ap_addr2")) + ",";
            SQLStr += Util.dbchar(ReqVal.TryGet("ap_eaddr1")) + ",";
            SQLStr += Util.dbchar(ReqVal.TryGet("ap_eaddr2")) + ",";
            SQLStr += Util.dbchar(ReqVal.TryGet("ap_eaddr3")) + ",";
            SQLStr += Util.dbchar(ReqVal.TryGet("ap_eaddr4")) + ",";
            SQLStr += "'" + ReqVal.TryGet("apatt_zip") + "',";
            SQLStr += Util.dbchar(ReqVal.TryGet("apatt_addr1")) + ",";
            SQLStr += Util.dbchar(ReqVal.TryGet("apatt_addr2")) + ",";
            SQLStr += "'" + ReqVal.TryGet("apatt_tel0") + "',";
            SQLStr += "'" + ReqVal.TryGet("apatt_tel") + "',";
            SQLStr += "'" + ReqVal.TryGet("apatt_tel1") + "',";
            SQLStr += "'" + ReqVal.TryGet("apatt_fax") + "',";
            
            SQLStr += "'" + DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss") + "',";
            SQLStr += "'" + Sys.GetSession("scode") + "',";//in_scode(薪號)
            SQLStr += "'NN',";//ap_code-NN(正常_新增)
            SQLStr += Util.dbchar(ReqVal.TryGet("ap_title")) + ",";
            SQLStr += Util.dbchar(ReqVal.TryGet("ap_fcname")) + ",";
            SQLStr += Util.dbchar(ReqVal.TryGet("ap_lcname"))+ ",";
            SQLStr += Util.dbchar(ReqVal.TryGet("ap_fename")) + ",";
            SQLStr += Util.dbchar(ReqVal.TryGet("ap_fename")) + ",";
            SQLStr += "'" + ReqVal.TryGet("apatt_email") + "')";
            
            //Sys.showLog(SQLStr);
            //return;
            conn.ExecuteNonQuery(SQLStr);
            //都沒問題 
            conn.Commit();
            //conn.RollBack();
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
            //Response.Write("<br />Save Done.");
        }
        msg += "成功！";
        
        //window.location.href = "cust13_List.aspx?&prgid=cust13&apcust_no=<%=GetApcustNO%>&submitTask=U";
    }
    
    private void UpdateCustCode(string sCust_code)
    {
        string SQLStr = "";
        DBHelper conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
        try
        {
            SQLStr = "UPDATE Cust_code SET ";
            SQLStr += "sql = sql+1 ";
            SQLStr += " WHERE code_type='Z' and cust_code='" + sCust_code + "'";
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
            GetApcustNO = ReqVal.TryGet("apcust_no");
            SQLStr = "UPDATE apcust SET ";
            //下列欄位為唯讀
            //SQLStr += "apcust_no = '" + ReqVal.TryGet("apcust_no") + "', ";
            //SQLStr += "apclass = '" + ReqVal.TryGet("apclass") + "', ";
            //SQLStr += "ap_country = '" + ReqVal.TryGet("ap_country") + "', ";
            //SQLStr += "cust_area = '" + ReqVal.TryGet("") + "', ";
            //SQLStr += "cust_seq = '" + ReqVal.TryGet("") + "', ";
            SQLStr += "ap_cname1 = " + Util.dbchar(ReqVal.TryGet("ap_cname1")) + ", ";
            SQLStr += "ap_cname2 = " + Util.dbchar(ReqVal.TryGet("ap_cname2")) + ", ";
            SQLStr += "ap_ename1 = " + Util.dbchar(ReqVal.TryGet("ap_ename1")) + ", ";
            SQLStr += "ap_ename2 = " + Util.dbchar(ReqVal.TryGet("ap_ename2")) + ", ";
            SQLStr += "ap_crep = " + Util.dbchar(ReqVal.TryGet("ap_crep")) + ", ";
            SQLStr += "ap_erep = " + Util.dbchar(ReqVal.TryGet("ap_erep")) + ", ";
            SQLStr += "ap_zip = '" + ReqVal.TryGet("ap_zip") + "', ";
            SQLStr += "ap_addr1 = " + Util.dbchar(ReqVal.TryGet("ap_addr1")) + ", ";
            SQLStr += "ap_addr2 = " + Util.dbchar(ReqVal.TryGet("ap_addr2")) + ", ";
            SQLStr += "ap_eaddr1 = " + Util.dbchar( ReqVal.TryGet("ap_eaddr1")) + ", ";
            SQLStr += "ap_eaddr2 = " + Util.dbchar(ReqVal.TryGet("ap_eaddr2")) + ", ";
            SQLStr += "ap_eaddr3 = " + Util.dbchar(ReqVal.TryGet("ap_eaddr3")) + ", ";
            SQLStr += "ap_eaddr4 = " + Util.dbchar(ReqVal.TryGet("ap_eaddr4")) + ", ";
            SQLStr += "apatt_zip = '" + ReqVal.TryGet("apatt_zip") + "', ";
            SQLStr += "apatt_addr1 = " + Util.dbchar(ReqVal.TryGet("apatt_addr1")) + ", ";
            SQLStr += "apatt_addr2 = " + Util.dbchar(ReqVal.TryGet("apatt_addr2")) + ", ";
            SQLStr += "apatt_tel0 = '" + ReqVal.TryGet("apatt_tel0") + "', ";
            SQLStr += "apatt_tel = '" + ReqVal.TryGet("apatt_tel") + "', ";
            SQLStr += "apatt_tel1 = '" + ReqVal.TryGet("apatt_tel1") + "', ";
            SQLStr += "apatt_fax = '" + ReqVal.TryGet("apatt_fax") + "', ";
            SQLStr += "ap_code = 'NU', ";//ap_code
            SQLStr += "tran_date = '" + DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss") + "', ";
            SQLStr += "tran_scode = '" + Sys.GetSession("scode") + "', ";
            SQLStr += "ap_title = " + Util.dbchar(ReqVal.TryGet("ap_title")) + ", ";
            SQLStr += "ap_fcname = " + Util.dbchar(ReqVal.TryGet("ap_fcname")) + ", ";
            SQLStr += "ap_lcname = " + Util.dbchar(ReqVal.TryGet("ap_lcname")) + ", ";
            SQLStr += "ap_fename = " + Util.dbchar(ReqVal.TryGet("ap_fename")) + ",";
            SQLStr += "ap_lename = " + Util.dbchar(ReqVal.TryGet("ap_lename")) + ", ";
            SQLStr += "apatt_email = '" + ReqVal.TryGet("apatt_email") + "' ";
            SQLStr += " WHERE apcust_no = '" + GetApcustNO + "' AND apsqlno = '"  + ReqVal.TryGet("apsqlno") + "'";

            //Sys.showLog(SQLStr);
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

    

</script>

<%Response.Write(msg + "," + GetApcustNO);%>