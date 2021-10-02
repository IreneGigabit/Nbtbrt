<%@Page Language="C#" CodePage="65001" %>

<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Linq" %>
<%@ Import Namespace="Newtonsoft.Json" %>
<%@ Import Namespace="Newtonsoft.Json.Linq" %>


<script runat="server">
    protected string HTProgCap = "客戶資料-入檔";
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
        //foreach (var item in ReqVal)
        //{
        //    Response.Write("[Key = " + item.Key + ", Value = " + item.Value + ", ");
        //}

        prgid = Request["prgid"] ?? "";
        submitTask = Request["submitTask"] ?? "";
        msg = "客戶資料";
        
        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        //Response.Write("<br />HTProgRight = " + HTProgRight + " , " + " HTProgCode : " + HTProgCode + "<br />");
        if (HTProgRight >= 0)
        {
            if (submitTask == "A")
            {
                msg = msg + "- 新增";
                ProcessAdd();
            }
            else if (submitTask == "U")
            {
                msg = msg + "- 修改";
                ProcessUpdate();
                Sys.insert_apcust_log("apcust", ReqVal, prgid);
                Sys.insert_apcust_log("custz", ReqVal, prgid);
            }
        }
    }

    private void ProcessAdd()
    {
        string SQLStr = "";
        string SQLStrApcust = "";
        string SQLStrCustzatt = "";
     
        //DBHelper conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
        DBHelper conn = new DBHelper(Conn.brp(Sys.GetSession("seBranch"))).Debug(Request["chkTest"] == "TEST");
        SqlDataReader dr = conn.ExecuteReader("SELECT sql+1 as sql FROM Cust_code where code_type = 'Z' and cust_code = 'Z'");
        dr.Read();
        int cust_seqNo = int.Parse(dr["sql"].ToString());
        dr.Close(); dr.Dispose();
        
        GetApcustNO = "";
        if (ReqVal.TryGet("apclass") == "AA" || ReqVal.TryGet("apclass") == "CA")
        {
            SqlDataReader drNO = conn.ExecuteReader("SELECT RIGHT('0' + CAST(sql+1 as varchar), 4) as sql FROM Cust_code where code_type = 'Z' and cust_code = '" + ReqVal.TryGet("apclass").Substr(0, 1) + "'");
            drNO.Read();
            GetApcustNO = ReqVal.TryGet("apclass") + drNO["sql"].ToString();
            drNO.Close(); drNO.Dispose();
        }
        
        try
        {
            SQLStr = "INSERT INTO custz (cust_area, cust_seq, id_no, www, email, con_code,	con_term, ";
            if (ReqVal.TryGet("dept") == "P")
	        {
                SQLStr += "pacc_attention, pacc_title, pacc_email,  acc_zip, acc_addr1, acc_addr2, acc_tel0, acc_tel, acc_tel1,	acc_fax, acc_mobile, pscode, plevel, pdis_type, ppay_type, ppay_typem, ";
	        }
            else
            {
                SQLStr += "tacc_attention, tacc_title, tacc_email,  tacc_zip, tacc_addr1, tacc_addr2, tacc_tel0, tacc_tel, tacc_tel1, tacc_fax, tacc_mobile, tscode, tlevel, tdis_type, tpay_type, tpay_typem, ";
            }
            SQLStr += "rmark_code, ref_seq, ref_no, mag, in_date, in_scode, tran_code, cust_remark, mark, acc_remark, " +
            "tax_attention,	tax_email, tax_zip,	tax_addr1, tax_addr2, tax_tel0,	tax_tel, tax_tel1, tax_fax, tax_mobile, " +
            "taxacc_attention, taxacc_email, taxacc_zip, taxacc_addr1, taxacc_addr2, taxacc_tel0, taxacc_tel, taxacc_tel1, taxacc_fax, taxacc_mobile) values(";

            SQLStr +=  Util.dbchar(ReqVal.TryGet("cust_area")) + ",";
            SQLStr += "'" + cust_seqNo.ToString() + "',";
            if (GetApcustNO == "") GetApcustNO = ReqVal.TryGet("id_no");
            SQLStr += "'" + GetApcustNO + "',";

            SQLStr +=  Util.dbchar(ReqVal.TryGet("www")) + ",";
            SQLStr +=  Util.dbchar(ReqVal.TryGet("email")) + ",";
            SQLStr +=  Util.dbchar(ReqVal.TryGet("con_code")) + ",";
            
            if (ReqVal.TryGet("con_term") == "") { SQLStr += "NULL,"; }
            else { SQLStr += "'" + DateTime.Parse(ReqVal.TryGet("con_term")).ToString("yyyy-MM-dd HH:mm:ss") + "',"; }
            
            if (ReqVal.TryGet("dept") == "P")
            {
                SQLStr +=  Util.dbchar(ReqVal.TryGet("pacc_attention")) + ",";
                SQLStr +=  Util.dbchar(ReqVal.TryGet("pacc_title")) + ",";
                SQLStr +=  Util.dbchar(ReqVal.TryGet("pacc_email")) + ",";
                SQLStr +=  Util.dbchar(ReqVal.TryGet("acc_zip")) + ",";
                SQLStr +=  Util.dbchar(ReqVal.TryGet("acc_addr1")) + ",";
                SQLStr +=  Util.dbchar(ReqVal.TryGet("acc_addr2")) + ",";
                SQLStr +=  Util.dbchar(ReqVal.TryGet("acc_tel0")) + ",";
                SQLStr +=  Util.dbchar(ReqVal.TryGet("acc_tel")) + ",";
                SQLStr +=  Util.dbchar(ReqVal.TryGet("acc_tel1")) + ",";
                SQLStr +=  Util.dbchar(ReqVal.TryGet("acc_fax")) + ",";
                SQLStr +=  Util.dbchar(ReqVal.TryGet("acc_mobile")) + ",";
                SQLStr +=  Util.dbchar(ReqVal.TryGet("pscode")) + ",";
                SQLStr +=  Util.dbchar(ReqVal.TryGet("plevel")) + ",";
                SQLStr +=  Util.dbchar(ReqVal.TryGet("pdis_type")) + ",";
                SQLStr +=  Util.dbchar(ReqVal.TryGet("ppay_type")) + ",";
                SQLStr +=  Util.dbnull(ReqVal.TryGet("ppay_typem")) + ",";
            }
            else
            {
                SQLStr +=  Util.dbchar(ReqVal.TryGet("tacc_attention")) + ",";
                SQLStr +=  Util.dbchar(ReqVal.TryGet("tacc_title")) + ",";
                SQLStr +=  Util.dbchar(ReqVal.TryGet("tacc_email")) + ",";
                SQLStr +=  Util.dbchar(ReqVal.TryGet("tacc_zip")) + ",";
                SQLStr +=  Util.dbchar(ReqVal.TryGet("tacc_addr1")) + ",";
                SQLStr +=  Util.dbchar(ReqVal.TryGet("tacc_addr2")) + ",";
                SQLStr +=  Util.dbchar(ReqVal.TryGet("tacc_tel0")) + ",";
                SQLStr +=  Util.dbchar(ReqVal.TryGet("tacc_tel")) + ",";
                SQLStr +=  Util.dbchar(ReqVal.TryGet("tacc_tel1")) + ",";
                SQLStr +=  Util.dbchar(ReqVal.TryGet("tacc_fax")) + ",";
                SQLStr +=  Util.dbchar(ReqVal.TryGet("tacc_mobile")) + ",";
                SQLStr +=  Util.dbchar(ReqVal.TryGet("tscode")) + ",";
                SQLStr +=  Util.dbchar(ReqVal.TryGet("tlevel")) + ",";
                SQLStr +=  Util.dbchar(ReqVal.TryGet("tdis_type")) + ",";
                SQLStr +=  Util.dbchar(ReqVal.TryGet("tpay_type")) + ",";
                SQLStr +=  Util.dbnull(ReqVal.TryGet("tpay_typem")) + ",";
            }
            
            SQLStr +=  Util.dbchar(ReqVal.TryGet("rmark_code")) + ",";

            if (ReqVal.TryGet("ref_seq") == "") { SQLStr += "NULL,";}
            else { SQLStr += Util.dbchar(ReqVal.TryGet("ref_seq")) + ","; }
            
            SQLStr += "NULL,";//ref_no???
            SQLStr +=  Util.dbchar(ReqVal.TryGet("mag")) + ",";
            SQLStr += "'" + DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss") + "',";
            SQLStr += "'" + Sys.GetSession("scode") + "',";//in_scode(薪號)
            SQLStr += "'NN',";//tran_code-NN(正常_新增)
            SQLStr +=  Util.dbchar(ReqVal.TryGet("cust_remark")) + ",";
            SQLStr += "'N',";//mark
            SQLStr +=  Util.dbchar(ReqVal.TryGet("acc_remark")) + ",";
            //SQLStr +=  Util.dbchar(ReqVal.TryGet("pspay_flag")) + ",";
            //SQLStr +=  Util.dbchar(ReqVal.TryGet("tspay_flag")) + ",";
            SQLStr +=  Util.dbchar(ReqVal.TryGet("tax_attention")) + ",";
            SQLStr +=  Util.dbchar(ReqVal.TryGet("tax_email")) + ",";
            SQLStr +=  Util.dbchar(ReqVal.TryGet("tax_zip")) + ",";
            SQLStr +=  Util.dbchar(ReqVal.TryGet("tax_addr1")) + ",";
            SQLStr +=  Util.dbchar(ReqVal.TryGet("tax_addr2")) + ",";
            SQLStr +=  Util.dbchar(ReqVal.TryGet("tax_tel0")) + ",";
            SQLStr +=  Util.dbchar(ReqVal.TryGet("tax_tel")) + ",";
            SQLStr +=  Util.dbchar(ReqVal.TryGet("tax_tel1")) + ",";
            SQLStr +=  Util.dbchar(ReqVal.TryGet("tax_fax")) + ",";
            SQLStr +=  Util.dbchar(ReqVal.TryGet("tax_mobile")) + ",";
            SQLStr +=  Util.dbchar(ReqVal.TryGet("taxacc_attention")) + ",";
            SQLStr +=  Util.dbchar(ReqVal.TryGet("taxacc_email")) + ",";
            SQLStr +=  Util.dbchar(ReqVal.TryGet("taxacc_zip")) + ",";
            SQLStr +=  Util.dbchar(ReqVal.TryGet("taxacc_addr1")) + ",";
            SQLStr +=  Util.dbchar(ReqVal.TryGet("taxacc_addr2")) + ",";
            SQLStr +=  Util.dbchar(ReqVal.TryGet("taxacc_tel0")) + ",";
            SQLStr +=  Util.dbchar(ReqVal.TryGet("taxacc_tel")) + ",";
            SQLStr +=  Util.dbchar(ReqVal.TryGet("taxacc_tel1")) + ",";
            SQLStr +=  Util.dbchar(ReqVal.TryGet("taxacc_fax")) + ",";
            SQLStr +=  Util.dbchar(ReqVal.TryGet("taxacc_mobile")) + ")";
            
            SQLStrApcust = InsertApcustSQL(conn, GetApcustNO, cust_seqNo);
            SQLStrCustzatt = InsertCust_attSQL(cust_seqNo);
            
            int SqlNo = 0;
            using(DBHelper conn2 = new DBHelper(Conn.brp(Sys.GetSession("seBranch"))).Debug(Request["chkTest"] == "TEST"))
	        {
                SqlDataReader drApsqlno = conn2.ExecuteReader("select max(apsqlno) from apcust");
                drApsqlno.Read();
                SqlNo = int.Parse(drApsqlno[0].ToString()) + 1;
                drApsqlno.Close(); drApsqlno.Dispose();
	        }
            //Sys.showLog(SQLStr);
            //Sys.showLog(SQLStrApcust);
            //Sys.showLog(SQLStrCustzatt);
            //return;
            conn.ExecuteNonQuery(SQLStr);
            conn.ExecuteNonQuery(SQLStrApcust);

            if (ReqVal.TryGet("databr_branch") != "" && ReqVal.TryGet("tran_flag") == "B")
            {//轉案
                InsertCust_attSQLs(conn, int.Parse(ReqVal.TryGet("hatt_sql")), cust_seqNo);
                Transfer(conn, cust_seqNo, SqlNo);
            }
            else
            {
                conn.ExecuteNonQuery(SQLStrCustzatt);
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
            UpdateCustSeqNO();
            if (ReqVal.TryGet("apclass") == "AA" || ReqVal.TryGet("apclass") == "CA")
            {
                UpdateCustCode(ReqVal.TryGet("apclass").Substr(0, 1));
            }
        }
        msg = "客戶資料(編號 : " + ReqVal.TryGet("cust_area") + "-" + cust_seqNo.ToString() + ") - 新增成功！";
    }

    private void Transfer(DBHelper conn, int cust_seq, int apsqlno)
    {
        Sys.insert_log_table(conn, "U", prgid, "dmp_brtran", "cust_area;cust_seq;tran_flag;branch", ReqVal.TryGet("old_cust_area") + ";" + ReqVal.TryGet("old_cust_seq") + ";B;" + ReqVal.TryGet("old_branch"),"");
        string SQL = "update dmp_brtran set tran_cust_area='" + Sys.GetSession("seBranch") + "',tran_cust_seq= " + cust_seq;
        SQL += ",tran_date=getdate(),tran_scode ='" + Sys.GetSession("scode") + "'";
        SQL += " where tran_flag='B' and branch='" + ReqVal.TryGet("old_branch") + "'";
        SQL += " and cust_area='" + ReqVal.TryGet("old_cust_area") + "' and cust_seq='" + ReqVal.TryGet("old_cust_seq") + "'";
        conn.ExecuteNonQuery(SQL);
        
        Sys.insert_log_table(conn, "U", prgid, "exp_brtran", "cust_area;cust_seq;tran_flag;branch", ReqVal.TryGet("old_cust_area") + ";" + ReqVal.TryGet("old_cust_seq") + ";B;" + ReqVal.TryGet("old_branch"), "");
        SQL = "update exp_brtran set tran_cust_area='" + Sys.GetSession("seBranch") + "',tran_cust_seq=" + cust_seq;
        SQL += ",tran_date=getdate(),tran_scode='" + Sys.GetSession("scode") + "'";
        SQL += " where tran_flag='B' and branch='" + ReqVal.TryGet("old_branch") + "'";
        SQL += " and cust_area='" + ReqVal.TryGet("old_cust_area") + "' and cust_seq='" + ReqVal.TryGet("old_cust_seq") + "'";
        conn.ExecuteNonQuery(SQL);

        SQL = "update apcust set dmp_seq=null,exp_seq=null,dmt_seq=null,ext_seq=null where apsqlno = " + apsqlno;
        conn.ExecuteNonQuery(SQL);

        SQL = "update custz set dmp_date=null,exp_date=null,dmt_date=null,ext_date=null where cust_area = '" + Sys.GetSession("seBranch") + "' and cust_seq = " + cust_seq;
        conn.ExecuteNonQuery(SQL);
    }

    private string InsertApcustSQL(DBHelper conn, string apcustNO, int cust_seq)
    {
        string SQLStr = "";
        SqlDataReader dr = conn.ExecuteReader("select max(apsqlno) from apcust");
        dr.Read();
        int SqlNo = int.Parse(dr[0].ToString()) + 1;
        dr.Close(); dr.Dispose();

        SQLStr = "INSERT INTO apcust (apsqlno, apcust_no, apclass, cust_area, cust_seq, ap_cname1, ap_cname2, ap_ename1, ap_ename2, ap_crep, ap_erep, " +
                    "ap_country, ap_zip, ap_addr1, ap_addr2, ap_eaddr1, ap_eaddr2, ap_eaddr3, ap_eaddr4, apatt_zip, apatt_addr1, apatt_addr2, apatt_tel0, apatt_tel, apatt_tel1, apatt_fax, " +
                    "in_date, in_scode, ap_code, ap_title, ap_fcname, ap_lcname, ap_fename, ap_lename, apatt_email) values(";

        SQLStr += "'" + SqlNo.ToString() + "',";
        SQLStr += "'" + apcustNO + "',";
        SQLStr += "'" + ReqVal.TryGet("apclass") + "',";
        SQLStr += Util.dbchar(ReqVal.TryGet("cust_area")) + ",";
        SQLStr += "'" + cust_seq.ToString() + "',";
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
        SQLStr += Util.dbchar(ReqVal.TryGet("ap_lcname")) + ",";
        SQLStr += Util.dbchar(ReqVal.TryGet("ap_fename")) + ",";
        SQLStr += Util.dbchar(ReqVal.TryGet("ap_fename")) + ",";
        SQLStr += "'" + ReqVal.TryGet("apatt_email") + "')";
        return SQLStr;
    }

    private string InsertCust_attSQL(int cust_seq)
    {
        string SQLStr = "";
        int AttSql = 1;
        string UpdateDate = ""; string UpdateScode = "";
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
        SQLStr = "INSERT INTO custz_att (cust_area,	cust_seq, att_sql, dept, attention,	att_company, att_title,	att_dept, att_tel0,	att_tel, att_tel1,	att_mobile, " +
                    "att_fax, att_zip,	att_addr1, att_addr2, att_email, att_mag, att_code, " + UpdateDate + ", " + UpdateScode + ", mark) values(";

        SQLStr += Util.dbchar(ReqVal.TryGet("cust_area")) + ",";
        SQLStr += "'" + cust_seq.ToString() + "',";
        SQLStr += "'" + AttSql.ToString() + "',";
        SQLStr += "'" + Sys.GetSession("dept") + "',";
        SQLStr += Util.dbchar(ReqVal.TryGet("attention_1")) + ",";
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
        SQLStr += "'" + DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss") + "',";//專利/商標異動日期
        SQLStr += "'" + Sys.GetSession("scode") + "',";//ptran_scode(薪號)
        SQLStr += Util.dbchar(ReqVal.TryGet("mark_1")) + ")";//table有設計mark欄位，但畫面上沒有
        return SQLStr;
    }
    
    private void InsertCust_attSQLs(DBHelper conn, int attsql, int cust_seq)//brta78國內案確認轉案作業用
    {
        for (int i = 1; i <= attsql; i++)
        {
            string SQLStr = "";
            int Sql = i;
            string dept = Sys.GetSession("dept");
            string UpdateDate = ""; string UpdateScode = "";
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
            SQLStr = "INSERT INTO custz_att (cust_area,	cust_seq, att_sql, dept, attention,	att_company, att_title,	att_dept, att_tel0,	att_tel, att_tel1,	att_mobile, " +
                        "att_fax, att_zip,	att_addr1, att_addr2, att_email, att_mag, att_code, " + UpdateDate + ", " + UpdateScode + ", mark) values(";

            SQLStr += Util.dbchar(ReqVal.TryGet("cust_area")) + ",";
            SQLStr += "'" + cust_seq.ToString() + "',";
            SQLStr += "'" + Sql.ToString() + "',";
            SQLStr += "'" + dept + "',";
            SQLStr += Util.dbchar(ReqVal.TryGet("attention_"+i)) + ",";
            SQLStr += Util.dbchar(ReqVal.TryGet("att_company_"+i)) + ",";
            SQLStr += Util.dbchar(ReqVal.TryGet("att_title_"+i)) + ",";
            SQLStr += Util.dbchar(ReqVal.TryGet("att_dept_"+i)) + ",";
            SQLStr += "'" + ReqVal.TryGet("att_tel0_"+i) + "',";
            SQLStr += "'" + ReqVal.TryGet("att_tel_"+i) + "',";
            SQLStr += "'" + ReqVal.TryGet("att_tel1_"+i) + "',";
            SQLStr += "'" + ReqVal.TryGet("att_mobile_"+i) + "',";
            SQLStr += "'" + ReqVal.TryGet("att_fax_"+i) + "',";
            SQLStr += "'" + ReqVal.TryGet("att_zip_"+i) + "',";
            SQLStr += Util.dbchar(ReqVal.TryGet("att_addr1_"+i)) + ",";
            SQLStr += Util.dbchar(ReqVal.TryGet("att_addr2_"+i)) + ",";
            SQLStr += Util.dbchar(ReqVal.TryGet("att_email_"+i)) + ",";
            SQLStr += "'" + ReqVal.TryGet("att_mag_"+i) + "',";
            SQLStr += "'NN',";//att_code-NN(正常_新增)
            SQLStr += "'" + DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss") + "',";//專利/商標異動日期
            SQLStr += "'" + Sys.GetSession("scode") + "',";//ptran_scode(薪號)
            SQLStr += Util.dbchar(ReqVal.TryGet("mark_"+i)) + ")";//table有設計mark欄位，但畫面上沒有
            conn.ExecuteNonQuery(SQLStr);
        }
    }
    
    private void UpdateCustSeqNO()
    {
        string SQLStr = "";
        //DBHelper conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
        DBHelper conn = new DBHelper(Conn.brp(Sys.GetSession("seBranch"))).Debug(Request["chkTest"] == "TEST");
        try
        {
            SQLStr = "UPDATE Cust_code SET sql = sql+1 WHERE code_type = 'Z' and cust_code = 'Z'";
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
        finally { conn.Dispose(); }
    }
    private void UpdateCustCode(string sCust_code)
    {
        string SQLStr = "";
        //DBHelper conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
        DBHelper conn = new DBHelper(Conn.brp(Sys.GetSession("seBranch"))).Debug(Request["chkTest"] == "TEST");
        try
        {
            SQLStr = "UPDATE Cust_code SET sql = sql+1 WHERE code_type = 'Z' and cust_code = '" + sCust_code + "'";;
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
        finally { conn.Dispose(); }
    }

    private void ProcessUpdate()
    {
        string SQLStr = "";
        string SQLStrApcust = "";
        //DBHelper conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
        DBHelper conn = new DBHelper(Conn.brp(Sys.GetSession("seBranch"))).Debug(Request["chkTest"] == "TEST");
        try
        {
            SQLStr = "UPDATE custz SET ";
            //下列欄位為唯讀
            //SQLStr += "cust_area = 
            //SQLStr += "csut_seq =
            //SQLStr += "id_no
            SQLStr += "www = " + Util.dbchar(ReqVal.TryGet("www")) + ", ";
            SQLStr += "email = " + Util.dbchar(ReqVal.TryGet("email")) + ", ";
            SQLStr += "con_code = " + Util.dbchar(ReqVal.TryGet("con_code")) + ", ";
            if (ReqVal.TryGet("con_term") == "")
            {
                SQLStr += "con_term = NULL, ";
            }
            else
            {
                SQLStr += "con_term = '" + DateTime.Parse(ReqVal.TryGet("con_term")).ToString("yyyy-MM-dd HH:mm:ss") + "', ";
            }
            

            string dept = Sys.GetSession("dept").ToString().ToLower();
            SQLStr += dept + "acc_attention = " + Util.dbchar(ReqVal.TryGet(dept + "acc_attention")) + ", ";
            SQLStr += dept + "acc_title = " + Util.dbchar(ReqVal.TryGet(dept + "acc_title")) + ", ";
            SQLStr += dept + "acc_email = " + Util.dbchar(ReqVal.TryGet(dept + "acc_email")) + ", ";
            SQLStr += dept + "scode = " + Util.dbchar(ReqVal.TryGet("pscode")) + ", ";
            SQLStr += dept + "level = " + Util.dbchar(ReqVal.TryGet("plevel")) + ", ";
            SQLStr += dept + "dis_type = " + Util.dbchar(ReqVal.TryGet("pdis_type")) + ", ";
            SQLStr += dept + "pay_type = " + Util.dbchar(ReqVal.TryGet("ppay_type")) + ", ";
            SQLStr += dept + "pay_typem = " + Util.dbnull(ReqVal.TryGet("ppay_typem")) + ", ";
            SQLStr += dept + "tran_date = '" + DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss") + "', ";
            SQLStr += dept + "tran_scode = '" + Sys.GetSession("scode") + "', ";

            if (dept == "p")
            {
                SQLStr += "acc_zip = '" + ReqVal.TryGet("acc_zip") + "', ";
                SQLStr += "acc_addr1 = " + Util.dbchar(ReqVal.TryGet("acc_addr1")) + ", ";
                SQLStr += "acc_addr2 = " + Util.dbchar(ReqVal.TryGet("acc_addr2")) + ", ";
                SQLStr += "acc_tel0 = '" + ReqVal.TryGet("acc_tel0") + "', ";
                SQLStr += "acc_tel = '" + ReqVal.TryGet("acc_tel") + "', ";
                SQLStr += "acc_tel1 = '" + ReqVal.TryGet("acc_tel1") + "', ";
                SQLStr += "acc_fax = '" + ReqVal.TryGet("acc_fax") + "', ";
                SQLStr += "acc_mobile = '" + ReqVal.TryGet("acc_mobile") + "', ";
            }
            else
            {
                SQLStr += "tacc_zip = '" + ReqVal.TryGet("tacc_zip") + "', ";
                SQLStr += "tacc_addr1 = " + Util.dbchar(ReqVal.TryGet("tacc_addr1")) + ", ";
                SQLStr += "tacc_addr2 = " + Util.dbchar(ReqVal.TryGet("tacc_addr2")) + ", ";
                SQLStr += "tacc_tel0 = '" + ReqVal.TryGet("tacc_tel0") + "', ";
                SQLStr += "tacc_tel = '" + ReqVal.TryGet("tacc_tel") + "', ";
                SQLStr += "tacc_tel1 = '" + ReqVal.TryGet("tacc_tel1") + "', ";
                SQLStr += "tacc_fax = '" + ReqVal.TryGet("tacc_fax") + "', ";
                SQLStr += "tacc_mobile = '" + ReqVal.TryGet("tacc_mobile") + "', ";
            }
            SQLStr += "rmark_code = " + Util.dbchar(ReqVal.TryGet("rmark_code")) + ", ";
            if (ReqVal.TryGet("ref_seq") == "")
            {
                SQLStr += "ref_seq = null, ";
            }
            else
            {
                SQLStr += "ref_seq = '" + ReqVal.TryGet("ref_seq") + "', ";
            }
            SQLStr += "mag = " + Util.dbchar(ReqVal.TryGet("mag")) + ", ";
            SQLStr += "tran_code = 'AU', ";
            SQLStr += "cust_remark = " + Util.dbchar(ReqVal.TryGet("cust_remark")) + ", ";
            //SQLStr += "mark = " + Util.dbchar(ReqVal.TryGet("mark")) + ", ";
            SQLStr += "acc_remark = " + Util.dbchar(ReqVal.TryGet("acc_remark")) + ", ";
            SQLStr += "tax_attention = " + Util.dbchar(ReqVal.TryGet("tax_attention")) + ", ";
            SQLStr += "tax_email = " + Util.dbchar(ReqVal.TryGet("tax_email")) + ", ";
            SQLStr += "tax_zip = '" + ReqVal.TryGet("tax_zip") + "', ";
            SQLStr += "tax_addr1 = " + Util.dbchar(ReqVal.TryGet("tax_addr1")) + ", ";
            SQLStr += "tax_addr2 = " + Util.dbchar(ReqVal.TryGet("tax_addr2")) + ", ";
            SQLStr += "tax_tel0 = '" + ReqVal.TryGet("tax_tel0") + "', ";
            SQLStr += "tax_tel = '" + ReqVal.TryGet("tax_tel") + "', ";
            SQLStr += "tax_tel1 = '" + ReqVal.TryGet("tax_tel1") + "', ";
            SQLStr += "tax_fax = '" + ReqVal.TryGet("tax_fax") + "', ";
            SQLStr += "tax_mobile = '" + ReqVal.TryGet("tax_mobile") + "', ";
            SQLStr += "taxacc_attention = " + Util.dbchar(ReqVal.TryGet("taxacc_attention")) + ", ";
            SQLStr += "taxacc_email = " + Util.dbchar(ReqVal.TryGet("taxacc_email")) + ", ";
            SQLStr += "taxacc_zip = '" + ReqVal.TryGet("taxacc_zip") + "', ";
            SQLStr += "taxacc_addr1 = " + Util.dbchar(ReqVal.TryGet("taxacc_addr1")) + ", ";
            SQLStr += "taxacc_addr2 = " + Util.dbchar(ReqVal.TryGet("taxacc_addr2")) + ", ";
            SQLStr += "taxacc_tel0 = '" + ReqVal.TryGet("taxacc_tel0") + "', ";
            SQLStr += "taxacc_tel = '" + ReqVal.TryGet("taxacc_tel") + "', ";
            SQLStr += "taxacc_tel1 = '" + ReqVal.TryGet("taxacc_tel1") + "', ";
            SQLStr += "taxacc_fax = '" + ReqVal.TryGet("taxacc_fax") + "', ";
            SQLStr += "taxacc_mobile = '" + ReqVal.TryGet("taxacc_mobile") + "' ";
            SQLStr += "WHERE cust_area = '" + ReqVal.TryGet("cust_area") + "' AND cust_seq = '" + ReqVal.TryGet("cust_seq") + "'";

            SQLStrApcust = UpdateApcust();
            //Sys.showLog(SQLStr);
            //Sys.showLog(SQLStrApcust);
            //Sys.insert_log_table(conn, "D", prgid, "dmt_attach", "attach_sqlno", attach_sqlno, "");
            //Sys.insert_log_table(conn, "U", prgid, "apcust", ReqVal, "");
            
            conn.ExecuteNonQuery(SQLStr);
            conn.ExecuteNonQuery(SQLStrApcust);
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

    private string UpdateApcust()
    {
        string SQLStr = "UPDATE apcust SET ";
        SQLStr += "ap_crep = " + Util.dbchar(ReqVal.TryGet("ap_crep")) + ", ";
        SQLStr += "ap_erep = " + Util.dbchar(ReqVal.TryGet("ap_erep")) + ", ";
        SQLStr += "ap_zip = '" + ReqVal.TryGet("ap_zip") + "', ";
        SQLStr += "ap_addr1 = " + Util.dbchar(ReqVal.TryGet("ap_addr1")) + ", ";
        SQLStr += "ap_addr2 = " + Util.dbchar(ReqVal.TryGet("ap_addr2")) + ", ";
        SQLStr += "ap_eaddr1 = " + Util.dbchar(ReqVal.TryGet("ap_eaddr1")) + ", ";
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
        SQLStr += "tran_date = '" + DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss") + "', ";
        SQLStr += "tran_scode = '" + Sys.GetSession("scode") + "', ";
        SQLStr += "ap_code = 'NU', ";//“NU”正常(修改)
        SQLStr += "ap_title = " + Util.dbchar(ReqVal.TryGet("ap_title")) + ", ";
        SQLStr += "apatt_email = " + Util.dbchar(ReqVal.TryGet("apatt_email")) + " ";
        SQLStr += "WHERE cust_area = '" + ReqVal.TryGet("cust_area") + "' AND cust_seq = '" + ReqVal.TryGet("cust_seq") + "'";
        return SQLStr;
    }

    

</script>

<%Response.Write(msg);%>