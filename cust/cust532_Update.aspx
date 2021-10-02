<%@Page Language="C#" CodePage="65001" %>

<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Linq" %>
<%@ Import Namespace="Newtonsoft.Json" %>
<%@ Import Namespace="Newtonsoft.Json.Linq" %>


<script runat="server">
    protected string HTProgCap = "列印名單資料-入檔";
    private string HTProgCode = HttpContext.Current.Request["prgid"];
    protected string HTProgPrefix = HttpContext.Current.Request["prgid"];
    private int HTProgAcs = 1;
    private int HTProgRight = 0;

    protected string msg = "";
    protected string cust_area = "";
    //protected string actionflag = "";
    protected string arrayList = "";
    protected string ptype = "";
    protected string saveType = "";
    
    string name, zip, addr1, addr2, att_dept;
    string pscode, tscode, ap_cname1, ap_cname2;
    
    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();

    private void Page_Load(System.Object sender, System.EventArgs e)
    {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;
        
        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");
        cust_area = Sys.GetSession("seBranch");
        ptype = ReqVal.TryGet("pType");
        //actionflag = ReqVal.TryGet("actionflag");
        arrayList = ReqVal.TryGet("arrayList");
        saveType = ReqVal.TryGet("saveType");
        msg = "列印名單資料-";
        
        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        if (HTProgRight >= 0)
        {
            ProcessDel();
            if (ReqVal.TryGet("saveType") != "Clear")
            {
                ProcessAdd();
            }
        }
    }

    private void ProcessAdd()
    {
        DBHelper conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
        string SQLStr = "";
        string cust_seqStr = "";
        string cust_seq_List = "";
        string att_sqlStr = "";
        string[] aData = arrayList.TrimEnd(',').Split(',');
        for (int i = 0; i < aData.Length; i++)
        {
            string[] s = aData[i].Split('|');
            cust_seq_List += "'"+ s[0] + "',";
        }
        //Sys.showLog(cust_seq_List);
        //return;
        
        DataTable dtCustz_att = new DataTable();
        string SQLatt = "select cust_seq, att_sql, attention,att_zip,att_addr1,att_addr2,att_dept from custz_att where cust_seq IN ("+ cust_seq_List.TrimEnd(',') + ")";
        conn.DataTable(SQLatt, dtCustz_att);

        DataTable dtCustz = new DataTable();
        string SQLcustz = "select cust_seq, pscode,tscode from custz where cust_area = '" + cust_area + "' and cust_seq IN (" + cust_seq_List.TrimEnd(',') + ")";
        conn.DataTable(SQLcustz, dtCustz);
        
        DataTable dtApcust = new DataTable();
        string SQLapcust = "select cust_seq, ap_cname1, ap_cname2, ap_crep,ap_zip,ap_addr1,ap_addr2 from apcust where cust_seq IN (" + cust_seq_List.TrimEnd(',') + ")";
        conn.DataTable(SQLapcust, dtApcust);
        
        for (int i = 0; i < aData.Length; i++)
        {
            string[] s = aData[i].Split('|');
            cust_seqStr = s[0];
            att_sqlStr = s[1];
            if (ptype == "A")
            {
                foreach (DataRow r in dtCustz_att.Select("cust_seq = " + cust_seqStr + " and att_sql = " + att_sqlStr))
                {
                    if (r["attention"] != DBNull.Value)
                    {
                        name = r["attention"].ToString();
                    }
                    else name = "";

                    zip = r["att_zip"].ToString();
                    addr1 = r["att_addr1"].ToString();
                    addr2 = r["att_addr2"].ToString();
                    att_dept = r["att_dept"].ToString();
                }
            }
            else
            { 
                //cust_seqStr = s[0];
                att_sqlStr = "0";
            }

            foreach (DataRow r in dtCustz.Select("cust_seq = " + int.Parse(cust_seqStr)))
            {
                pscode = r["pscode"].ToString();
                tscode = r["tscode"].ToString();
            }

            foreach (DataRow r in dtApcust.Select("cust_seq = '" + cust_seqStr + "'"))
            {
                ap_cname1 = r["ap_cname1"].ToString();
                ap_cname2 = r["ap_cname2"].ToString();
                if (ptype != "A")
                {
                    name = (r["ap_crep"] != DBNull.Value) ? r["ap_crep"].ToString(): "";
                    zip = r["ap_zip"].ToString();
                    addr1 = r["ap_addr1"].ToString();
                    addr2 = r["ap_addr2"].ToString();
                }
            }

            try
            {
                SQLStr = "INSERT INTO cust532 (scode, ptype, cust_seq, ap_cname1, ap_cname2, att_sql, name, zip, addr1,	addr2, pscode, tscode,	att_dept) VALUES(";
                SQLStr += "'" + Sys.GetSession("scode") + "',";
                SQLStr += "'" + ptype + "',";
                SQLStr += "'" + cust_seqStr + "',";
                SQLStr += Util.dbchar(ap_cname1) + ",";
                SQLStr += Util.dbchar(ap_cname2) + ",";
                SQLStr += "'" + att_sqlStr + "',";
                SQLStr += Util.dbchar(name) + ",";
                SQLStr += "'" + zip + "',";
                SQLStr += Util.dbchar(addr1) + ",";
                SQLStr += Util.dbchar(addr2) + ",";
                SQLStr += "'" + pscode + "',";
                SQLStr += "'" + tscode + "',";
                SQLStr += Util.dbchar(att_dept) + ")";

                //Sys.showLog(SQLStr);
                //conn.Dispose();
                //return;
                conn.ExecuteNonQuery(SQLStr);
            }
            catch (Exception ex)
            {
                conn.RollBack();
                msg += "失敗！";
                throw new Exception(msg, ex);
            }
        }
        conn.Commit(); conn.Dispose();
        msg += "存檔成功！";
    }

    private void ProcessDel()
    {
        DBHelper conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
        string SQLStr = "delete from cust532 where scode = '" + Sys.GetSession("scode") + "' and ptype='" + ptype + "'";
        try
        {
            conn.ExecuteNonQuery(SQLStr);
            //都沒問題 
            conn.Commit();
        }
        catch (Exception ex)
        {
            conn.RollBack();
            msg = "ProcessDel()失敗！";
            throw new Exception(msg, ex);
        }
        finally
        {
            conn.Dispose();
        }

        if (ReqVal.TryGet("saveType") == "Clear") { msg += "清檔成功"; }
    }
    
    

</script>

<%Response.Write(msg);%>