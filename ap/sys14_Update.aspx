<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<script runat="server">
    protected string HTProgCap = "使用者系統控制-入檔";//功能名稱
    protected string HTProgPrefix = "Sys14";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = HttpContext.Current.Request["prgid"] ?? "";//程式代碼
    protected int HTProgRight = 0;

    protected string SQL = "";
    protected string msg = "";

    protected string submitTask = "";
    protected string task = "";
    protected string sqlno = "";

    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected StringBuilder strOut = new StringBuilder();

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        submitTask = (Request["submittask"] ?? "");
        task = (Request["task"] ?? "");
        sqlno = (Request["sqlno"] ?? "");

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

            }
            catch (Exception ex) {
                cnn.RollBack();
                string errsqlno = Sys.errorLog(ex, cnn.exeSQL, prgid);
                msg = "入檔失敗\\n(" + errsqlno + ")" + ex.Message.Replace("'", "\\'");
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
        SQL = "Select * From scode Where scode = '" + Request["tfx_scode"] + "' ";
        using (SqlDataReader dr = cnn.ExecuteReader(SQL)) {
            if(!dr.HasRows){
                msg = "查無使用者薪號!";
                strOut.AppendLine("alert('"+msg+"');");
                return;
            }
        }

        SQL = " INSERT into sysctrl ";
        SQL += "(scode,branch,dept,sysdefault,syscode,logingrp,beg_date,end_date,tran_date,mark";
        SQL += ")VALUES(";
        SQL += " " + Util.dbnull(Request["tfx_scode"].ToBig5()) + "";
        SQL += "," + Util.dbnull(Request["tfx_branch"].ToBig5()) + "";
        SQL += "," + Util.dbnull(Request["tfx_dept"].ToBig5()) + "";
        SQL += "," + Util.dbnull(Request["tfx_sysdefault"].ToBig5()) + "";
        SQL += "," + Util.dbnull(Request["tfx_syscode"].ToBig5()) + "";
        SQL += "," + Util.dbnull(Request["tfx_logingrp"].ToBig5()) + "";
        SQL += "," + Util.dbnull(Request["dfx_beg_date"].ToBig5()) + "";
        SQL += "," + Util.dbnull(Request["dfx_end_date"].ToBig5()) + "";
        SQL += ",getdate()";
        SQL += "," + Util.dbnull(Request["tfx_mark"].ToBig5()) + "";
        SQL += ")";
        cnn.ExecuteNonQuery(SQL);
        
        msg = "新增完成！";
        strOut.AppendLine("alert('" + msg + "');");
        if (Request["chkTest"] != "TEST") {
            strOut.AppendLine("window.parent.location.reload();");
            strOut.AppendLine("window.parent.parent.Etop.goSearch();");
        }
    }

    private void doUpdate(DBHelper cnn) {
        SQL = " Update sysctrl set";
        SQL += " scode = " + Util.dbnull(Request["tfx_scode"].ToBig5()) + "";
        SQL += ",branch = " + Util.dbnull(Request["tfx_branch"].ToBig5()) + "";
        SQL += ",dept = " + Util.dbnull(Request["tfx_dept"].ToBig5()) + "";
        SQL += ",sysdefault = " + Util.dbnull(Request["tfx_sysdefault"].ToBig5()) + "";
        SQL += ",syscode = " + Util.dbnull(Request["tfx_syscode"].ToBig5()) + "";
        SQL += ",logingrp = " + Util.dbnull(Request["tfx_logingrp"].ToBig5()) + "";
        SQL += ",beg_date = " + Util.dbnull(Request["dfx_beg_date"].ToBig5()) + "";
        SQL += ",end_date = " + Util.dbnull(Request["dfx_end_date"].ToBig5()) + "";
        SQL += ",tran_date = getdate()";
        SQL += ",mark = " + Util.dbnull(Request["tfx_mark"].ToBig5()) + "";
        SQL += " where sqlno='" + sqlno + "'";
        cnn.ExecuteNonQuery(SQL);
          
        msg = "資料更新成功!!!";
        strOut.AppendLine("alert('" + msg + "');");
        if (Request["chkTest"] != "TEST") {
            strOut.AppendLine("window.parent.parent.tt.rows = \"100%,0%\";");
            strOut.AppendLine("window.parent.parent.Etop.goSearch();");
        }
    }

    private void doDel(DBHelper cnn) {
        SQL = "DELETE FROM sysctrl WHERE sqlno='" + sqlno + "'";
        cnn.ExecuteNonQuery(SQL);
        
        msg = "資料刪除成功!!!";
        strOut.AppendLine("alert('" + msg + "');");
        if (Request["chkTest"] != "TEST") {
            strOut.AppendLine("window.parent.parent.tt.rows = \"100%,0%\";");
            strOut.AppendLine("window.parent.parent.Etop.goSearch();");
        }
    }
</script>

<script language="javascript" type="text/javascript">
    <%Response.Write(strOut.ToString());%>
</script>
