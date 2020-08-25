<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<script runat="server">
    protected string HTProgCap = "群組資料-入檔";//功能名稱
    protected string HTProgPrefix = "LoginGrp";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = HttpContext.Current.Request["prgid"] ?? "";//程式代碼
    protected int HTProgRight = 0;

    protected string SQL = "";
    protected string msg = "";

    protected string submitTask = "";
    protected string task = "";
    protected string syscode = "";
    protected string LoginGrp = "";

    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected StringBuilder strOut = new StringBuilder();

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        submitTask = (Request["submittask"] ?? "");
        task = (Request["task"] ?? "");
        syscode = (Request["pfx_syscode"] ?? "");
        LoginGrp = (Request["pfx_LoginGrp"] ?? "");

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
                } else if (task == "C") {//複製
                    doCopy(cnn);
                }

                cnn.Commit();
                //cnn.RollBack();

            }
            catch (Exception ex) {
                cnn.RollBack();
                string sqlno = Sys.errorLog(ex, cnn.exeSQL, prgid);
                msg = "入檔失敗\\n(" + sqlno + ")" + ex.Message.Replace("'", "\\'").Replace("\r\n","\\n");
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
        SQL = "Select * From logingrp Where syscode = '" +Request["pfx_Syscode"]+ "' And LoginGrp = '"+Request["pfx_LoginGrp"]+"'";
        using (SqlDataReader dr = cnn.ExecuteReader(SQL)) {
            if(dr.HasRows){
                msg = "「權限群組資料」重複!!請重新輸入!";
                strOut.AppendLine("alert('"+msg+"');");
                return;
            }
        }
        
        SQL = " INSERT into LoginGrp ";
        SQL += "(SYScode,LoginGrp,GrpName,GrpType,WorkType,HomeGif,remark,beg_date,end_date,tran_date,tran_scode";
        SQL += ")VALUES(";
        SQL += " " + Util.dbnull(Request["pfx_Syscode"].ToBig5()) + "";
        SQL += "," + Util.dbnull(Request["pfx_LoginGrp"].ToBig5()) + "";
        SQL += "," + Util.dbnull(Request["tfx_GrpName"].ToBig5()) + "";
        SQL += "," + Util.dbnull(Request["tfx_GrpType"].ToBig5()) + "";
        SQL += "," + Util.dbnull(Request["tfx_WorkType"].ToBig5()) + "";
        SQL += "," + Util.dbnull(Request["tfx_HomeGif"].ToBig5()) + "";
        SQL += "," + Util.dbnull(Request["tfx_remark"].ToBig5()) + "";
        SQL += "," + Util.dbnull(Request["dfx_beg_date"].ToBig5()) + "";
        SQL += "," + Util.dbnull(Request["dfx_end_date"].ToBig5()) + "";
        SQL += ",getdate()";
        SQL += ",'" + Session["scode"] + "'";
        SQL += ")";
        cnn.ExecuteNonQuery(SQL);

        msg = "新增完成！";
        strOut.AppendLine("alert('" + msg + "');");
        if (Request["chkTest"] != "TEST") strOut.AppendLine("window.parent.parent.Etop.goSearch();");
    }

    private void doUpdate(DBHelper cnn) {
        SQL = " Update LoginGrp set";
        SQL += " GrpName = " + Util.dbnull(Request["tfx_GrpName"].ToBig5()) + "";
        SQL += ",GrpType = " + Util.dbnull(Request["tfx_GrpType"].ToBig5()) + "";
        SQL += ",WorkType = " + Util.dbnull(Request["tfx_WorkType"].ToBig5()) + "";
        SQL += ",HomeGif = " + Util.dbnull(Request["tfx_HomeGif"].ToBig5()) + "";
        SQL += ",remark = " + Util.dbnull(Request["tfx_remark"].ToBig5()) + "";
        SQL += ",beg_date = " + Util.dbnull(Request["dfx_beg_date"].ToBig5()) + "";
        SQL += ",end_date = " + Util.dbnull(Request["dfx_end_date"].ToBig5()) + "";
        SQL += ",tran_date = getdate()";
        SQL += ",tran_scode = '" + Session["scode"] + "'";
        SQL += " where syscode='" + syscode + "' AND LoginGrp='" + LoginGrp + "'";
        cnn.ExecuteNonQuery(SQL);
        
        msg = "資料更新成功!!!";
        strOut.AppendLine("alert('" + msg + "');");
        if (Request["chkTest"] != "TEST") strOut.AppendLine("window.parent.parent.Etop.goSearch();");
    }

    private void doDel(DBHelper cnn) {
        SQL = "DELETE FROM LoginGrp WHERE syscode='" + syscode + "' AND LoginGrp='" + LoginGrp + "'";
        cnn.ExecuteNonQuery(SQL);
        
        msg = "資料刪除成功!!!";
        strOut.AppendLine("alert('" + msg + "');");
        if (Request["chkTest"] != "TEST") strOut.AppendLine("window.parent.parent.Etop.goSearch();");
    }

    private void doCopy(DBHelper cnn) {
        int copy_num = Convert.ToInt32("0" + Request["count"]);
        for (int i = 1; i <= copy_num; i++) {
            if (ReqVal.TryGet("chk_" + i) == "Y") {
                SQL = "DELETE FROM loginap WHERE syscode='" + Request["syscode"] + "' AND LoginGrp='" + Request["loginGrpData_" + i] + "'";
                cnn.ExecuteNonQuery(SQL);

                SQL = "insert into loginap (SYScode,LoginGrp,Apcode,Rights,beg_date,end_date,tran_date,tran_scode) ";
                SQL += "select SYScode,'" + Request["loginGrpData_" + i] + "',Apcode,Rights,beg_date,end_date,getdate(),'" + Session["scode"] + "' ";
                SQL += "from loginap where SYScode = '" + Request["syscode"] + "' and LoginGrp = '" + Request["tfx_source"] + "'";
                cnn.ExecuteNonQuery(SQL);
            }
        }
        msg = "複製完成!!!";
        strOut.AppendLine("alert('" + msg + "');");
        if (Request["chkTest"] != "TEST") strOut.AppendLine("window.parent.location.reload();");
    }
</script>

<script language="javascript" type="text/javascript">
    <%Response.Write(strOut.ToString());%>
</script>
