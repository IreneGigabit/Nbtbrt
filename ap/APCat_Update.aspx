<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<script runat="server">
    protected string HTProgCap = "Menu資料-入檔";//功能名稱
    protected string HTProgPrefix = "APCat";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = HttpContext.Current.Request["prgid"] ?? "";//程式代碼
    protected int HTProgRight = 0;

    protected string SQL = "";
    protected string msg = "";

    protected string submitTask = "";
    protected string task = "";
    protected string syscode = "";
    protected string APcatID = "";

    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected StringBuilder strOut = new StringBuilder();

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        submitTask = (Request["submittask"] ?? "");
        task = (Request["task"] ?? "");
        syscode = (Request["pfx_syscode"] ?? "");
        APcatID = (Request["pfx_APcatID"] ?? "");

        ReqVal = Util.GetRequestParam(Context,Request["chkTest"] == "TEST");

        Token myToken = new Token(HTProgCode);
        HTProgRight = myToken.CheckMe();
        if (HTProgRight >= 0) {
            DBHelper cnn = new DBHelper(Conn.ODBCDSN).Debug(Request["chkTest"] == "TEST");
            try {
                if (task == "A") {//新增
                    doAdd(cnn);
                } else if (task == "U") {//修改
                    doUpdate(cnn);
                } else if (task == "D") {//刪除
                    doDel(cnn);
                }

                cnn.Commit();
                //cnn.RollBack();

                if (Request["chkTest"] != "TEST") strOut.AppendLine("window.parent.parent.Etop.goSearch();");
            }
            catch (Exception ex) {
                cnn.RollBack();
                string sqlno = Sys.errorLog(ex, cnn.exeSQL, prgid);
                msg = "入檔失敗\\n(" + sqlno + ")" + ex.Message.Replace("'", "\\'");
                strOut.AppendLine("alert('" + msg + "');");
            }
            finally {
                cnn.Dispose();
            }

            this.DataBind();
        }
    }

    private void doAdd(DBHelper cnn) {
        SQL = "Select * From APcat Where syscode='" + syscode + "' AND APcatID='" + APcatID + "'";
        using (SqlDataReader dr = cnn.ExecuteReader(SQL)) {
            if(dr.HasRows){
                msg = "資料已存在!!請重新輸入!";
                strOut.AppendLine("alert('"+msg+"');");

                throw new Exception(msg);
            }
        }

        SQL = " INSERT into APcat ";
        SQL += "(syscode,APcatID,apcatcname,apcatename,apseq";
        SQL += ")VALUES(";
        SQL += " " + Util.dbnull(Request["pfx_syscode"].ToBig5()) + "";
        SQL += "," + Util.dbnull(Request["pfx_APcatID"].ToBig5()) + "";
        SQL += "," + Util.dbnull(Request["tfx_APcatCName"].ToBig5()) + "";
        SQL += "," + Util.dbnull(Request["tfx_APcatEName"].ToBig5()) + "";
        SQL += "," + Util.dbnull(Request["nfx_APseq"].ToBig5()) + "";
        SQL += ")";
        cnn.ExecuteNonQuery(SQL);
        
        msg = "新增完成！";
        strOut.AppendLine("alert('"+msg+"');");
        if (Request["chkTest"] != "TEST") strOut.AppendLine("window.parent.location.reload();");
    }

    private void doUpdate(DBHelper cnn) {
        SQL = " Update APcat set";
        SQL += " apcatcname = " + Util.dbnull(Request["tfx_APcatCName"].ToBig5()) + "";
        SQL += ",apcatename = " + Util.dbnull(Request["tfx_APcatEName"].ToBig5()) + "";
        SQL += ",apseq = " + Util.dbnull(Request["nfx_APseq"].ToBig5()) + "";
        SQL += " where syscode='" + syscode + "' AND APcatID='" + APcatID + "'";
        cnn.ExecuteNonQuery(SQL);
        
        msg = "資料更新成功!!!";
        strOut.AppendLine("alert('" + msg + "');");
        if (Request["chkTest"] != "TEST") strOut.AppendLine("window.parent.location.reload();");
    }

    private void doDel(DBHelper cnn) {
        SQL = "DELETE FROM APcat WHERE syscode='" + syscode + "' AND APcatID='" + APcatID + "'";
        cnn.ExecuteNonQuery(SQL);
        
        msg = "資料刪除成功!!!";
        strOut.AppendLine("alert('" + msg + "');");
    }
</script>

<script language="javascript" type="text/javascript">
    <%Response.Write(strOut.ToString());%>
</script>
