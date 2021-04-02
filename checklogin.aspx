<%@Page Language="C#" CodePage="65001"%>
<%@Import Namespace = "System.Text"%>
<%@Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<script runat="server">

    protected string ScriptString = "";
    protected string exMsg = "";

    DBHelper conn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    private void Page_Unload(System.Object sender, System.EventArgs e) {
        if (conn != null) conn.Dispose();
    }

    private void Page_Load(Object sender, EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        conn = new DBHelper(Conn.ODBCDSN, false).Debug(false);

        StringBuilder sb = new StringBuilder();
        string strChk = CheckUser();
        //Response.Write("a=" + strChk+"<hr>");
        if (strChk.Length > 0) {
            sb.AppendLine("alert(\"" + strChk + "\");");
            //sb.AppendLine("top.location.href = \"login.aspx\";");
        } else if (exMsg.Length == 0) {
            //sb.AppendLine("alert(\"" + Request["tfx_scode"] + "\");");
            sb.AppendLine("top.location.href = \"Default.aspx\";");
        }

        ScriptString = sb.ToString();
        this.DataBind();
    }

    private string CheckUser()
    {
        string strRet = "";

        string syscode = Request["syscode"] ?? Sys.GetRootDir().Replace("/", "");//系統
        string Uid = Request["tfx_scode"] ?? "";//帳號
        string sys_pwd = Request["sys_pwd"] ?? "";//密碼
        string tfx_sys_password = Request["tfx_sys_password"] ?? "";//明碼
        Sys.errorLog(new Exception("tfx_scode(ref:" + HttpContext.Current.Request.UrlReferrer + ")"), Uid, "checklogin");
        if (tfx_sys_password != "") {
            sys_pwd = Util.GetHashValueMD5(tfx_sys_password.ToLower());//明碼轉md5
        }
        string SQL = "";
        try
        {
            if (Uid != "")
            {
                SQL = "SELECT a.*,b.*,c.logingrp,c.GrpName ";
                SQL += ",(SELECT DataBranch FROM SYScode WHERE syscode = b.syscode) AS DataBranch ";
                SQL += "  FROM scode a ";
                SQL += " INNER JOIN sysctrl b ON a.scode = b.scode ";
                SQL += " INNER JOIN logingrp AS c ON b.syscode = c.syscode AND b.logingrp = c.logingrp ";
                SQL += " where b.Syscode ='" + syscode + "' ";
                SQL += " AND a.scode='" + Uid + "' ";
                SQL += " AND a.sys_pwd ='" + sys_pwd + "' ";
                SQL += " AND GETDATE() BETWEEN isnull(a.beg_date,'1900/01/01') AND isnull(a.end_date,'2079/06/06') ";
                //Sys.errorLog(new Exception(Conn.ODBCDSN), SQL, "checklogin");
                //Response.Write("1="+SQL+"<hr>");
                SqlDataReader dr = conn.ExecuteReader(SQL);
                if (dr.Read())
                {
                    Session["Password"] = true;
                    Session["se_scode"] = dr["scode"].ToString();
                    Session["scode"] = dr["scode"].ToString();
                    Session["sc_name"] = dr["sc_name"].ToString();
                    Session["SeSysPwd"] = dr["sys_pwd"].ToString();
                    Session["SeBranch"] = dr["DataBranch"].ToString();
                    Session["Dept"] = dr["Dept"].ToString().ToLower();
                    Session["Syscode"] = Sys.Syscode;//.getAppSetting("syscode");// dr["Syscode"].ToString();//因有新舊資料問題,改用舊系統的syscode
                    Session["LoginGrp"] = dr["LoginGrp"].ToString();
                    Session["GrpName"] = dr["GrpName"].ToString();
                    dr.Close();

                    SQL = "select b.grpid,b.grplevel from scode_group a ";
                    SQL += "inner join grpid b on b.grpclass=a.grpclass and b.grpid=a.grpid ";
                    SQL += " and (substring(b.grpid,1,1)='" +Session["Dept"] +"' or substring(b.grpid,1,3)='000') ";
                    SQL += " where a.scode='" + Session["scode"] + "' and a.grpclass='" + Session["SeBranch"] + "' ";
                    //Response.Write("2=" + SQL+"<hr>");
                    DataTable dt = new DataTable();
                    conn.DataTable(SQL,dt);
                    for (int i = 0; i < dt.Rows.Count; i++) {
                        Session["se_grpid"] = dt.Rows[i].SafeRead("grpid", "");
                        Session["se_grplevel"] = dt.Rows[i].SafeRead("grplevel", "0");
                        if (Convert.ToInt32(dt.Rows[i].SafeRead("grplevel", "0")) < Convert.ToInt32(Sys.GetSession("se_grplevel"))) {
                            Session["se_grpid"] = dt.Rows[i].SafeRead("grpid", "");
                            Session["se_grplevel"] = dt.Rows[i].SafeRead("grplevel", "0");
                        }
                    }

                    SQL = "select branchname from branch_code where branch='" + Session["SeBranch"] + "'";
                    Session["SeBranchName"] = conn.ExecuteScalar(SQL) ?? "";

                    SQL = "UPDATE scode SET VisitCount = isnull(VisitCount,0)+1 " +
                        ", LastVisit = GETDATE() " +
                        "WHERE scode = '" + Session["scode"] + "'";
                    conn.ExecuteNonQuery(SQL);
                }
                else
                {
                    //Response.Write("3=帳號/密碼 不合！請重新登入！<hr>");
                    Session["Password"] = false;
                    strRet = "帳號/密碼 不合！請重新登入！";
                }
                if (!dr.IsClosed) dr.Close();
                SQL = "UPDATE sysctrl SET visit_date = GETDATE() WHERE scode = '" + Session["scode"] + "' AND syscode = '" + syscode + "' ";
                conn.ExecuteNonQuery(SQL);
            }
            else
            {
                //Response.Write("4=輸入錯誤 !<hr>");
                Session["Password"] = false;
                Session.Abandon();
                strRet = "輸入錯誤 !";
            }
        }
        catch (Exception ex)
        {
            //Response.Write("5=執行錯誤 !" + "<hr>");
            exMsg = conn.ConnString + "\n" + SQL;
            if (conn != null) Sys.errorLog(ex, conn.exeSQL, "checklogin");
            strRet = "執行錯誤 !" + ex.Message + "\\n\\n" + SQL;
            Session["Password"] = false;
            Session.Abandon();

            //throw new Exception(exMsg, ex);
        }

        return strRet;
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>登入</title>
<link href="./inc/setstyle.css" rel="stylesheet" type="text/css" />
<script language="javascript" type="text/javascript">
<%#ScriptString%>
</script>
</head>
<body>
<%#exMsg%>
</body>
</html>
