<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<script runat="server">
    protected string HTProgCap = "Syscode系統資料-入檔";//功能名稱
    protected string HTProgPrefix = "Syscode";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;

    protected string SQL = "";
    protected string msg = "";

    protected string submitTask = "";
    protected string task = "";
    protected string syscode = "";

    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected StringBuilder strOut = new StringBuilder();

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        submitTask = (Request["submittask"] ?? "");
        task = (Request["task"] ?? "");
        syscode = (Request["pfx_syscode"] ?? "");

        ReqVal = Util.GetRequestParam(Context,Request["chkTest"] == "TEST");

        TokenN myToken = new TokenN(HTProgCode);
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
                //conn.RollBack();

                if (Request["chkTest"] != "TEST") {
                    strOut.AppendLine("if (window.parent.parent.Etop.goSearch !== undefined) { ");
                    strOut.AppendLine(" window.parent.parent.Etop.goSearch();");
                    strOut.AppendLine("}else{");
                    strOut.AppendLine(" window.parent.document.getElementsByClassName('imgCls')[0].click();");
                    strOut.AppendLine("}");
                }
            }
            catch (Exception ex) {
                cnn.RollBack();
                string sqlno = Sys.errorLog(ex, cnn.exeSQL, prgid);
                msg = "入檔失敗\\n(" + sqlno + ")" + ex.Message.Replace("'", "\\'");
                strOut.AppendLine("alert('" + msg + "');");
                //throw new Exception(msg, ex);
            }
            finally {
                cnn.Dispose();
            }

            this.DataBind();
        }
    }

    private void doAdd(DBHelper cnn) {
        SQL = "Select * From SYScode Where syscode='" + syscode + "'";
        using (SqlDataReader dr = cnn.ExecuteReader(SQL)) {
            if(dr.HasRows){
                msg = "資料已存在!!請重新輸入!";
                strOut.AppendLine("alert('"+msg+"');");
                return;
            }
        }
        
        SQL = " INSERT into syscode ";
        SQL += "(syscode,sysnameC,sysnameE,sysserver,syspath,DataBranch,ClassCode";
        SQL += ",syssql,corp_user,main_user,sys_user,online_date,beg_date";
        SQL += ",end_date,sysremark,mark";
        SQL += ")VALUES(";
        SQL += " " + Util.dbnull(Request["pfx_syscode"]) + "";
        SQL += "," + Util.dbnull(Request["tfx_sysnameC"]) + "";
        SQL += "," + Util.dbnull(Request["tfx_sysnameE"]) + "";
        SQL += "," + Util.dbnull(Request["tfx_sysserver"]) + "";
        SQL += "," + Util.dbnull(Request["tfx_syspath"]) + "";
        SQL += "," + Util.dbnull(Request["tfx_DataBranch"]) + "";
        SQL += "," + Util.dbnull(Request["tfx_ClassCode"]) + "";
        SQL += "," + Util.dbnull(Request["tfx_syssql"]) + "";
        SQL += "," + Util.dbnull(Request["tfx_corp_user"]) + "";
        SQL += "," + Util.dbnull(Request["tfx_main_user"]) + "";
        SQL += "," + Util.dbnull(Request["tfx_sys_user"]) + "";
        SQL += "," + Util.dbnull(Request["dfx_online_date"]) + "";
        SQL += "," + Util.dbnull(Request["dfx_beg_date"]) + "";
        SQL += "," + Util.dbnull(Request["dfx_end_date"]) + "";
        SQL += "," + Util.dbnull(Request["tfx_sysremark"]) + "";
        SQL += "," + Util.dbnull(Request["tfx_mark"]) + "";
        SQL += ")";
        cnn.ExecuteNonQuery(SQL);
        
        msg = "新增完成！";
        strOut.AppendLine("alert('"+msg+"');");
        if (Request["chkTest"] != "TEST") strOut.AppendLine("window.parent.location.reload();");
    }

    private void doUpdate(DBHelper cnn) {
        SQL = " Update syscode set";
        SQL += " sysnameC = " + Util.dbnull(Request["tfx_sysnameC"]) + "";
        SQL += ",sysnameE = " + Util.dbnull(Request["tfx_sysnameE"]) + "";
        SQL += ",sysserver = " + Util.dbnull(Request["tfx_sysserver"]) + "";
        SQL += ",syspath = " + Util.dbnull(Request["tfx_syspath"]) + "";
        SQL += ",DataBranch = " + Util.dbnull(Request["tfx_DataBranch"]) + "";
        SQL += ",ClassCode = " + Util.dbnull(Request["tfx_ClassCode"]) + "";
        SQL += ",syssql = " + Util.dbnull(Request["tfx_syssql"]) + "";
        SQL += ",corp_user = " + Util.dbnull(Request["tfx_corp_user"]) + "";
        SQL += ",main_user = " + Util.dbnull(Request["tfx_main_user"]) + "";
        SQL += ",sys_user = " + Util.dbnull(Request["tfx_sys_user"]) + "";
        SQL += ",online_date = " + Util.dbnull(Request["dfx_online_date"]) + "";
        SQL += ",beg_date = " + Util.dbnull(Request["dfx_beg_date"]) + "";
        SQL += ",end_date = " + Util.dbnull(Request["dfx_end_date"]) + "";
        SQL += ",sysremark = " + Util.dbnull(Request["tfx_sysremark"]) + "";
        SQL += ",mark = " + Util.dbnull(Request["tfx_mark"]) + "";
        SQL += " where syscode='" + syscode + "'";
        cnn.ExecuteNonQuery(SQL);
        
        msg = "資料更新成功!!!";
        strOut.AppendLine("alert('" + msg + "');");
        if (Request["chkTest"] != "TEST") strOut.AppendLine("window.parent.location.reload();");
    }

    private void doDel(DBHelper cnn) {
        SQL = "DELETE FROM syscode WHERE syscode='" + syscode + "'";
        cnn.ExecuteNonQuery(SQL);
        
        msg = "資料刪除成功!!!";
        strOut.AppendLine("alert('" + msg + "');");
    }
</script>

<script language="javascript" type="text/javascript">
    <%Response.Write(strOut.ToString());%>
</script>
