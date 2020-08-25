<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<script runat="server">
    protected string HTProgCap = "編修權限群組-入檔";//功能名稱
    protected string HTProgPrefix = "EditRegSys";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = HttpContext.Current.Request["prgid"] ?? "";//程式代碼
    protected int HTProgRight = 0;

    protected string SQL = "";
    protected string msg = "";

    protected string submitTask = "";
    protected string syscode = "";
    protected string apcode = "";

    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected StringBuilder strOut = new StringBuilder();

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        submitTask = (Request["submittask"] ?? "");
        syscode = (Request["syscode"] ?? "");
        apcode = (Request["apcode"] ?? "");

        ReqVal = Util.GetRequestParam(Context,Request["chkTest"] == "TEST");

        Token myToken = new Token(HTProgCode);
        HTProgRight = myToken.CheckMe();
        if (HTProgRight >= 0) {
            DBHelper cnn = new DBHelper(Conn.ODBCDSN).Debug(Request["chkTest"] == "TEST");
            try {
                doUpdate(cnn);

                cnn.Commit();
                //cnn.RollBack();

                msg = "編修完成!!!";
            }
            catch (Exception ex) {
                cnn.RollBack();
                string sqlno = Sys.errorLog(ex, cnn.exeSQL, prgid);
                msg = "編修失敗\\n(" + sqlno + ")" + ex.Message.Replace("'", "\\'");
                //throw new Exception(msg, ex);
            }
            finally {
                cnn.Dispose();
            }

            strOut.AppendLine("alert('" + msg + "');");
            if (Request["chkTest"] != "TEST") strOut.AppendLine("window.parent.location.reload();");

            this.DataBind();
        }
    }

    private void doUpdate(DBHelper cnn) {
        SQL = "DELETE FROM LoginAP WHERE SYScode='" + syscode + "' AND Apcode = '" + apcode + "'";
        cnn.ExecuteNonQuery(SQL);
   
        SQL = "select D.LoginGrp from ap As C ";
		SQL += "LEFT JOIN LoginGrp As D ON D.SYScode = C.SYScode ";
        SQL += "Where C.SYScode = '" + syscode + "' And C.Apcode = '" + apcode + "'";
        using (SqlDataReader dr = cnn.ExecuteReader(SQL)) {
            SQL = "";
            while (dr.Read()) {
                string logingrp = dr.SafeRead("LoginGrp", "");
                int rights = 0;
                string rwid = "";
                string sBgn = "";
                string sEnd = "";

                for (int z = 0; z <= 9; z++) {
                    int pow = Convert.ToInt32(Math.Pow(2, z));
                    rwid = "chk_" + logingrp + "_" + pow.ToString().PadLeft(3, '0');
                    if (Request[rwid] != null) rights += int.Parse(Request[rwid]);
                    //Response.Write(logingrp + " 2的" + z + "次方=" + Math.Pow(2, z) + "," + rwid + "=" + rights + "<BR>");
                }
                if (rights > 0) {
                    rwid = "Bgn_" + logingrp;
                    if (string.IsNullOrEmpty(Request[rwid]))
                        sBgn = "1970/1/1";
                    else
                        sBgn = Request[rwid];

                    rwid = "End_" + logingrp;
                    if (string.IsNullOrEmpty(Request[rwid]))
                        sEnd = "2079/6/6";
                    else
                        sEnd = Request[rwid];

                    SQL += "INSERT INTO LoginAP (SYScode,LoginGrp, Apcode,Rights,beg_date,end_date,tran_date,Tran_scode";
                    SQL += ") VALUES ('" + syscode + "','" + logingrp + "','" + apcode + "'";
                    SQL += ",'" + rights + "','" + sBgn + "','" + sEnd + "',getdate(),'" + Session["scode"] + "');\n";
                }
            }
        }

        if (SQL.Length > 0) {
            cnn.ExecuteNonQuery(SQL);
        }
    }
</script>

<script language="javascript" type="text/javascript">
    <%Response.Write(strOut.ToString());%>
</script>
