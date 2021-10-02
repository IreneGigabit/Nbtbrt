<%@Page Language="C#" CodePage="65001" %>

<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Linq" %>
<%@ Import Namespace="Newtonsoft.Json" %>
<%@ Import Namespace="Newtonsoft.Json.Linq" %>


<script runat="server">
    protected string HTProgCap = "申請人相關資料-入檔";
    private string HTProgCode = HttpContext.Current.Request["prgid"];
    protected string HTProgPrefix = HttpContext.Current.Request["prgid"];
    private int HTProgAcs = 1;
    private int HTProgRight = 0;

    protected string submitTask = "";
    protected string tf_code = "";
    protected string msg = "";
    protected string apcustno = "";
    protected string apsqlno = "";
    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();

    private void Page_Load(System.Object sender, System.EventArgs e)
    {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;
        
        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");
        //foreach (var item in ReqVal)
        //{
        //    Response.Write("[Key = " + item.Key + ", Value = " + item.Value + ", ");
        //}

        submitTask = Request["submitTask"] ?? "";
        apsqlno = Request["apsqlno"];
        apcustno = Request["apcust_no"];
        msg = "申請人相關資料";
        
        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        //Response.Write("<br />HTProgRight = " + HTProgRight + " , " + " HTProgCode : " + HTProgCode + "<br />");
        
        if (HTProgRight >= 0)
        {
            if (submitTask == "A")
            {
                msg = msg + "-新增";
                //Response.Write("<br /> SubmitTask : " + submitTask);
                ProcessAdd();
            }
            else if (submitTask == "U")
            {
                msg = msg + "-修改";
                //Response.Write("<br /> SubmitTask : " + submitTask);
                ProcessUpdate();
            }
        }
    }

    private void ProcessAdd()
    {
        int SqlNo = 1;
        DBHelper conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
        SqlDataReader dr = conn.ExecuteReader("select top 1 ap_sql from ap_nameaddr where apsqlno = '" + apsqlno + "' ORDER BY ap_sql DESC");
        if (dr.Read())
        {
            SqlNo = int.Parse(dr["ap_sql"].ToString()) + 1;
        }
        dr.Close(); dr.Dispose();
        
        string SQLStr = "";
        try
        {
            SQLStr = "INSERT INTO ap_nameaddr (apsqlno, ap_sql, ap_ename1, ap_ename2, ap_zip, ap_addr1, ap_addr2, ap_eaddr1, ap_eaddr2, ap_eaddr3, ap_eaddr4, ";
            SQLStr += " ap_remark, tr_date, tr_scode) values(";
            
            SQLStr += "'" + apsqlno + "',";
            SQLStr += "'" + SqlNo + "',";
            SQLStr += Util.dbchar(ReqVal.TryGet("ap_ename1")) + ",";
            SQLStr += Util.dbchar(ReqVal.TryGet("ap_ename2")) + ",";
            SQLStr += "'" + ReqVal.TryGet("ap_zip") + "',";
            SQLStr += Util.dbchar(ReqVal.TryGet("ap_addr1")) + ",";
            SQLStr += Util.dbchar(ReqVal.TryGet("ap_addr2")) + ",";
            SQLStr += Util.dbchar(ReqVal.TryGet("ap_eaddr1")) + ",";
            SQLStr += Util.dbchar(ReqVal.TryGet("ap_eaddr2")) + ",";
            SQLStr += Util.dbchar(ReqVal.TryGet("ap_eaddr3")) + ",";
            SQLStr += Util.dbchar(ReqVal.TryGet("ap_eaddr4")) + ",";
            SQLStr += Util.dbchar(ReqVal.TryGet("ap_remark")) + ",";
            SQLStr += "'" + DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss") + "',";
            SQLStr += "'" + Session["scode"].ToString() + "')";//in_scode(薪號)

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
            //Response.Write("<br />Save Done.");
        }
        msg += "成功！";
    }
    
    private void ProcessUpdate()
    {
        string SQLStr = "";
        DBHelper conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
        try
        {
            SQLStr = "UPDATE ap_nameaddr SET ";
            SQLStr += "ap_ename1 = " + Util.dbchar(ReqVal.TryGet("ap_ename1")) + ", ";
            SQLStr += "ap_ename2 = " + Util.dbchar(ReqVal.TryGet("ap_ename2")) + ", ";
            SQLStr += "ap_zip = '" + ReqVal.TryGet("ap_zip") + "', ";
            SQLStr += "ap_addr1 = " + Util.dbchar(ReqVal.TryGet("ap_addr1")) + ", ";
            SQLStr += "ap_addr2 = " + Util.dbchar(ReqVal.TryGet("ap_addr2")) + ", ";
            SQLStr += "ap_eaddr1 = " + Util.dbchar(ReqVal.TryGet("ap_eaddr1")) + ", ";
            SQLStr += "ap_eaddr2 = " + Util.dbchar(ReqVal.TryGet("ap_eaddr2")) + ", ";
            SQLStr += "ap_eaddr3 = " + Util.dbchar(ReqVal.TryGet("ap_eaddr3")) + ", ";
            SQLStr += "ap_eaddr4 = " + Util.dbchar(ReqVal.TryGet("ap_eaddr4")) + ", ";
            SQLStr += "ap_remark = " + Util.dbchar(ReqVal.TryGet("ap_remark")) + ", ";
            SQLStr += "tr_date = '" + DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss") + "', ";
            SQLStr += "tr_scode = '" + Session["scode"].ToString() + "'";
            SQLStr += " WHERE ap_sql = '" + ReqVal.TryGet("ap_sql") + "' AND apsqlno = '" + apsqlno + "'";
            
            //Response.Write(SQLStr);
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
