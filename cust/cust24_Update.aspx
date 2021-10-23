<%@Page Language="C#" CodePage="65001" %>

<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Linq" %>
<%@ Import Namespace="Newtonsoft.Json" %>
<%@ Import Namespace="Newtonsoft.Json.Linq" %>


<script runat="server">
    protected string HTProgCap = "聯絡人職代/副本信箱設定-入檔";
    private string HTProgCode = HttpContext.Current.Request["prgid"];
    protected string HTProgPrefix = HttpContext.Current.Request["prgid"];
    private int HTProgAcs = 1;
    private int HTProgRight = 0;

    protected string prgid = "";
    protected string submitTask = "";
    protected string msg = "";
    protected string errmsg = "";
    protected string scode = "";
    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    string mail_del, mail_mark_sqlno, mail_mark_type2, mail_att_sql;
    string mail_syscode, mail_spe_mark, mail_open_date, mail_end_date, mail_upd_flag;
    string mail_type_content1, mail_type_content2, mail_type_content3;

    private void Page_Load(System.Object sender, System.EventArgs e)
    {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;
        
        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");

        submitTask = Request["submitTask"] ?? "";
        prgid = Request["prgid"] ?? "";
        msg = "聯絡人副本信箱";
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

    
    private void ProcessAdd()
    {
        string SQLStr = "";
      
        DBHelper conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
        try
        {
            for (int i = 1; i <= Int32.Parse(ReqVal.TryGet("hmail_sql")); i++)
            {
                mail_del = "";  mail_mark_sqlno = "";  mail_mark_type2 = "";  mail_att_sql = "";
                mail_syscode = ""; mail_spe_mark = ""; mail_open_date = ""; mail_end_date = "";
                mail_type_content1 = ""; mail_type_content2 = ""; mail_type_content3 = "";
                
                mail_del = ReqVal.TryGet("mail_del_"+i);
                mail_mark_sqlno = ReqVal.TryGet("mail_mark_sqlno_"+i);
                mail_mark_type2 = ReqVal.TryGet("mail_mark_type2_" + i);
                mail_att_sql = ReqVal.TryGet("mail_att_sql_" + i);
                mail_syscode = ReqVal.TryGet("mail_syscode_" + i);
                mail_spe_mark = ReqVal.TryGet("mail_spe_mark_" + i);
                mail_open_date = ReqVal.TryGet("mail_open_date_" + i);
                mail_end_date = ReqVal.TryGet("mail_end_date_" + i);
                mail_type_content1 = ReqVal.TryGet("mail_type_content1_" + i);
                mail_type_content2 = ReqVal.TryGet("mail_type_content2_" + i);
                mail_type_content3 = ReqVal.TryGet("mail_type_content3_" + i);
                
                //沒勾刪除,且沒有流水號
                if (mail_del != "Y" && mail_mark_sqlno == "")
                {
                    SQLStr = "INSERT INTO apcust_mark (apsqlno, apcust_no, att_sql, mark_type, syscode, cust_area, cust_seq, type_content1, type_content2, type_content3,";
                    SQLStr += "in_date,in_scode,tran_date,tran_scode,open_date, end_date,mark_type2,spe_mark) VALUES (";

                    SQLStr += Util.dbnull(ReqVal.TryGet("apsqlno")) + ",";
                    SQLStr += Util.dbchar(ReqVal.TryGet("apcust_no")) + ",";
                    SQLStr += Util.dbnull(mail_att_sql) + ",";
                    SQLStr += Util.dbchar("cmark_mail") + ",";
                    SQLStr += Util.dbchar(mail_syscode) + ",";//5
                    SQLStr += Util.dbnull(ReqVal.TryGet("cust_area")) + ",";
                    SQLStr += Util.dbnull(ReqVal.TryGet("cust_seq")) + ",";
                    SQLStr += Util.dbchar(mail_type_content1) + ",";
                    SQLStr += Util.dbchar(mail_type_content2) + ",";
                    SQLStr += Util.dbchar(mail_type_content3) + ",";//10
                    SQLStr += "GETDATE(),";
                    SQLStr += "'" + scode + "',";
                    SQLStr += "GETDATE(),";
                    SQLStr += "'" + scode + "',";
                    SQLStr += Util.dbnull(mail_open_date) + ",";//15
                    SQLStr += Util.dbnull(mail_end_date) + ",";
                    SQLStr += Util.dbchar(mail_mark_type2) + ",";
                    SQLStr += Util.dbchar(mail_spe_mark) + ")";
                    conn.ExecuteNonQuery(SQLStr);
                    //Sys.showLog(SQLStr);
                }
            }


            //都沒問題 
            conn.Commit();
            msg += "成功！";
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
        string SQLStr = "";
        DBHelper conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
        try
        {
            for (int i = 1; i <= Int32.Parse(ReqVal.TryGet("hmail_sql")); i++)
            {
                mail_del = ""; mail_mark_sqlno = ""; mail_mark_type2 = ""; mail_att_sql = "";
                mail_syscode = ""; mail_spe_mark = ""; mail_open_date = ""; mail_end_date = "";
                mail_type_content1 = ""; mail_type_content2 = ""; mail_type_content3 = "";

                mail_del = ReqVal.TryGet("mail_del_" + i);
                mail_mark_sqlno = ReqVal.TryGet("mail_mark_sqlno_" + i);
                mail_mark_type2 = ReqVal.TryGet("mail_mark_type2_" + i);
                mail_att_sql = ReqVal.TryGet("mail_att_sql_" + i);
                mail_syscode = ReqVal.TryGet("mail_syscode_" + i);
                mail_spe_mark = ReqVal.TryGet("mail_spe_mark_" + i);
                mail_open_date = ReqVal.TryGet("mail_open_date_" + i);
                mail_end_date = ReqVal.TryGet("mail_end_date_" + i);
                mail_type_content1 = ReqVal.TryGet("mail_type_content1_" + i);
                mail_type_content2 = ReqVal.TryGet("mail_type_content2_" + i);
                mail_type_content3 = ReqVal.TryGet("mail_type_content3_" + i);
                mail_upd_flag = ReqVal.TryGet("mail_upd_flag_" + i);
                
                if (mail_del == "Y")//有勾刪除
                {
                    string SQLDel = "";
                    if (mail_mark_sqlno != "")//有流水號表示為DB有資料
                    {
                        SQLDel = "DELETE FROM apcust_mark ";
                        SQLDel += "OUTPUT 'D', GETDATE(), " + Util.dbnull(scode) + "," + Util.dbnull(prgid) + ", DELETED.* INTO apcust_mark_log ";
                        SQLDel += "WHERE mark_sqlno = '" + mail_mark_sqlno + "'";
                    }
                    conn.ExecuteNonQuery(SQLDel);
                    //Sys.showLog(SQLDel);
                }
                else
                {
                    if (mail_mark_sqlno != "")//有流水號表示為修改
                    {
                        if (mail_upd_flag == "Y")//有更新註記才要update
                        {
                            SQLStr = "update apcust_mark set ";
                            SQLStr += "apcust_no = '" + Request["apcust_no"] + "',";
                            SQLStr += "att_sql = " + Util.dbnull(mail_att_sql) + ",";
                            SQLStr += "spe_mark = " + Util.dbchar(mail_spe_mark) + ",";
                            SQLStr += "syscode = " + Util.dbchar(mail_syscode) + ",";
                            SQLStr += "type_content1 = " + Util.dbchar(mail_type_content1) + ",";
                            SQLStr += "type_content2 = " + Util.dbchar(mail_type_content2) + ",";
                            SQLStr += "type_content3 = " + Util.dbchar(mail_type_content3) + ",";
                            SQLStr += "tran_date = GETDATE(),";
                            SQLStr += "tran_scode = " + Util.dbnull(scode) + ",";
                            SQLStr += "open_date = " + Util.dbnull(mail_open_date) + ",";
                            SQLStr += "end_date = " + Util.dbnull(mail_end_date);
                            SQLStr += " OUTPUT 'U', GETDATE(), " + Util.dbnull(scode) + "," + Util.dbnull(prgid) + ", DELETED.* INTO apcust_mark_log ";
                            SQLStr += " where mark_sqlno = '" + mail_mark_sqlno + "'";
                            conn.ExecuteNonQuery(SQLStr);
                            //Sys.showLog(SQLStr);
                        }
                    }
                    else
                    {
                        SQLStr = "INSERT INTO apcust_mark (apsqlno, apcust_no, att_sql, mark_type, syscode, cust_area, cust_seq, type_content1, type_content2, type_content3,";
                        SQLStr += "in_date,in_scode,tran_date,tran_scode,open_date, end_date,mark_type2,spe_mark) VALUES (";

                        SQLStr += Util.dbnull(ReqVal.TryGet("apsqlno")) + ",";
                        SQLStr += Util.dbchar(ReqVal.TryGet("apcust_no")) + ",";
                        SQLStr += Util.dbnull(mail_att_sql) + ",";
                        SQLStr += Util.dbchar("cmark_mail") + ",";
                        SQLStr += Util.dbchar(mail_syscode) + ",";//5
                        SQLStr += Util.dbnull(ReqVal.TryGet("cust_area")) + ",";
                        SQLStr += Util.dbnull(ReqVal.TryGet("cust_seq")) + ",";
                        SQLStr += Util.dbchar(mail_type_content1) + ",";
                        SQLStr += Util.dbchar(mail_type_content2) + ",";
                        SQLStr += Util.dbchar(mail_type_content3) + ",";//10
                        SQLStr += "GETDATE(),";
                        SQLStr += "'" + scode + "',";
                        SQLStr += "GETDATE(),";
                        SQLStr += "'" + scode + "',";
                        SQLStr += Util.dbnull(mail_open_date) + ",";//15
                        SQLStr += Util.dbnull(mail_end_date) + ",";
                        SQLStr += Util.dbchar(mail_mark_type2) + ",";
                        SQLStr += Util.dbchar(mail_spe_mark) + ")";
                        conn.ExecuteNonQuery(SQLStr);
                        //Sys.showLog(SQLStr);
                    }
                    //if (chkDuplicate(conn, mail_mark_sqlno, Request["apcust_no"], mail_att_sql, "cmark_report", mail_mark_type2, "", mail_syscode, "") == true)
                    //{ errmsg += "[報表備註] " + i.ToString() + ". 選項重覆\n";}
                }
            }

            //都沒問題 
            conn.Commit();
            //conn.RollBack();
            msg += "成功！";
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