<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<script runat="server">
    protected string HTProgCap = "程式資料-入檔";//功能名稱
    protected string HTProgPrefix = "AP";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = HttpContext.Current.Request["prgid"] ?? "";//程式代碼
    protected int HTProgRight = 0;

    protected string SQL = "";
    protected string msg = "";

    protected string submitTask = "";
    protected string task = "";
    protected string syscode = "";
    protected string APcode = "";

    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected StringBuilder strOut = new StringBuilder();

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        submitTask = (Request["submittask"] ?? "");
        task = (Request["task"] ?? "");
        syscode = (Request["pfx_syscode"] ?? "");
        APcode = (Request["pfx_APcode"] ?? "");

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
        SQL = " INSERT into AP ";
        SQL += "(syscode,APcode,APnameC,APnameE,APcat,APserver,APpath,ReMark";
        SQL += ",APorder,APGrpClass,end_level,beg_date,end_date,tran_date,tran_scode";
        SQL += ")VALUES(";
        SQL += " " + Util.dbnull(Request["pfx_syscode"].ToBig5()) + "";
        SQL += "," + Util.dbnull(Request["pfx_APcode"].ToBig5()) + "";
        SQL += "," + Util.dbnull(Request["tfx_APnameC"].ToBig5()) + "";
        SQL += "," + Util.dbnull(Request["tfx_APnameE"].ToBig5()) + "";
        SQL += "," + Util.dbnull(Request["tfx_APcat"].ToBig5()) + "";
        SQL += "," + Util.dbnull(Request["tfx_APserver"].ToBig5()) + "";
        SQL += "," + Util.dbnull(Request["tfx_APpath"].ToBig5()) + "";
        SQL += "," + Util.dbnull(Request["tfx_ReMark"].ToBig5()) + "";
        SQL += "," + Util.dbnull(Request["tfx_APorder"].ToBig5()) + "";
        SQL += "," + Util.dbnull(Request["tfx_APGrpClass"].ToBig5()) + "";
        SQL += "," + Util.dbnull(Request["nfx_end_level"].ToBig5()) + "";
        SQL += "," + Util.dbnull(Request["dfx_beg_date"].ToBig5()) + "";
        SQL += "," + Util.dbnull(Request["dfx_end_date"].ToBig5()) + "";
        SQL += ",getdate()";
        SQL += ",'" + Session["scode"] + "'";
        SQL += ")";
        cnn.ExecuteNonQuery(SQL);

        SQL = "Select * From LoginAp ";
        SQL += "Where syscode='" + Request["pfx_syscode"] + "' AND LoginGrp='" + Request["pfx_syscode"] + "admin' AND apcode='" + Request["pfx_APcode"] + "'";
        using (SqlDataReader dr = cnn.ExecuteReader(SQL)) {
            if (!dr.HasRows) {
                dr.Close();
                SQL = "insert into LoginAp (SYScode,LoginGrp,Apcode,Rights,beg_date,end_date,tran_date,tran_scode";
                SQL += ")values(";
                SQL += "'" + Request["pfx_syscode"] + "','" + Request["pfx_syscode"] + "admin','" + Request["pfx_APcode"] + "',1023";
                SQL += ",'" + DateTime.Today.ToShortDateString() + "','2079/6/6','" + DateTime.Today.ToShortDateString() + "','" + Session["scode"] + "')";
                cnn.ExecuteNonQuery(SQL);
            }
        }

        msg = "新增完成！";
        strOut.AppendLine("alert('" + msg + "');");
        if (Request["chkTest"] != "TEST") strOut.AppendLine("window.parent.parent.Etop.goSearch();");
        if (Request["chkTest"] != "TEST") strOut.AppendLine("window.parent.location.reload();");
    }

    private void doUpdate(DBHelper cnn) {
        SQL = " Update AP set";
        SQL += " APnameC = " + Util.dbnull(Request["tfx_APnameC"].ToBig5()) + "";
        SQL += ",APnameE = " + Util.dbnull(Request["tfx_APnameE"].ToBig5()) + "";
        SQL += ",APcat = " + Util.dbnull(Request["tfx_APcat"].ToBig5()) + "";
        SQL += ",APserver = " + Util.dbnull(Request["tfx_APserver"].ToBig5()) + "";
        SQL += ",APpath = " + Util.dbnull(Request["tfx_APpath"].ToBig5()) + "";
        SQL += ",ReMark = " + Util.dbnull(Request["tfx_ReMark"].ToBig5()) + "";
        SQL += ",APorder = " + Util.dbnull(Request["tfx_APorder"].ToBig5()) + "";
        SQL += ",APGrpClass = " + Util.dbnull(Request["tfx_APGrpClass"].ToBig5()) + "";
        SQL += ",end_level = " + Util.dbnull(Request["nfx_end_level"].ToBig5()) + "";
        SQL += ",beg_date = " + Util.dbnull(Request["dfx_beg_date"].ToBig5()) + "";
        SQL += ",end_date = " + Util.dbnull(Request["dfx_end_date"].ToBig5()) + "";
        SQL += ",tran_date = getdate()";
        SQL += ",tran_scode = '" + Session["scode"] + "'";
        SQL += " where syscode='" + syscode + "' AND APcode='" + APcode + "'";
        cnn.ExecuteNonQuery(SQL);
        
        msg = "資料更新成功!!!";
        strOut.AppendLine("alert('" + msg + "');");
        if (Request["chkTest"] != "TEST") strOut.AppendLine("window.parent.parent.Etop.goSearch();");
    }

    private void doDel(DBHelper cnn) {
        SQL = "DELETE FROM AP WHERE syscode='" + syscode + "' AND APcode='" + APcode + "'";
        cnn.ExecuteNonQuery(SQL);
        
        msg = "資料刪除成功!!!";
        strOut.AppendLine("alert('" + msg + "');");
        if (Request["chkTest"] != "TEST") strOut.AppendLine("window.parent.parent.Etop.goSearch();");
    }
</script>

<script language="javascript" type="text/javascript">
    <%Response.Write(strOut.ToString());%>
</script>
