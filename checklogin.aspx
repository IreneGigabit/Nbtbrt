<%@Page Language="C#" CodePage="65001"%>
<%@Import Namespace = "System.Text"%>
<%@Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<script runat="server">

    protected string ScriptString = "";
    protected string exMsg = "";
    protected string SQL = "";

    DBHelper connsys = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    private void Page_Unload(System.Object sender, System.EventArgs e) {
        if (connsys != null) connsys.Dispose();
    }

    private void Page_Load(Object sender, EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        connsys = new DBHelper(Conn.ODBCDSN, false).Debug(false);

        StringBuilder sb = new StringBuilder();
        string strChk = CheckUser();
        //Response.Write("a=" + strChk+"<hr>");
        if (strChk.Length > 0) {
            sb.AppendLine("console.log(\"" + strChk + "\");");
            sb.AppendLine("alert(\"" + strChk + "\");");
            sb.AppendLine("top.location.href = \"login.aspx\";");
        } else if (exMsg.Length == 0) {
            //sb.AppendLine("alert(\"" + Request["tfx_scode"] + "\");");
            sb.AppendLine("top.location.href = \"Default.aspx\";");
        }

        ScriptString = sb.ToString();
        this.DataBind();
    }

    private string CheckUser() {
        string strRet = "";

        string syscode = Request["syscode"] ?? Sys.GetRootDir().Replace("/", "");//系統
        string Uid = Request["tfx_scode"] ?? "";//帳號
        string sys_pwd = Request["sys_pwd"] ?? "";//密碼
        string tfx_sys_password = Request["tfx_sys_password"] ?? "";//明碼
        //Sys.errorLog(new Exception("tfx_scode(ref:" + HttpContext.Current.Request.UrlReferrer + ")"), Uid, "checklogin");
        if (tfx_sys_password != "") {
            sys_pwd = Util.GetHashValueMD5(tfx_sys_password.ToLower());//明碼轉md5
        }
        bool login_flag = false;
        try {
            if (Uid != "") {
                SQL = "SELECT * ,(SELECT DataBranch FROM SYScode WHERE syscode = b.syscode) AS DataBranch ";
                SQL += "  FROM scode a INNER JOIN sysctrl b ON a.scode = b.scode ";
                SQL += " where b.Syscode ='" + syscode + "' ";
                SQL += " AND a.scode='" + Uid + "' ";
                SQL += " AND a.sys_pwd ='" + sys_pwd + "' ";
                SQL += " AND GETDATE() BETWEEN isnull(a.beg_date,'1900/01/01') AND isnull(a.end_date,'2079/06/06') ";
                //Sys.errorLog(new Exception(Conn.ODBCDSN), SQL, "checklogin");
                //Response.Write("1="+SQL+"<hr>");
                SqlDataReader dr = connsys.ExecuteReader(SQL);
                if (dr.Read()) {
                    login_flag = true;
                    SetSession(dr, ref strRet);
                } else {
                    dr.Close();
                    login_flag = false;

                    //原本無此系統權限者代理
                    //1.檢查帳密是否正確
                    //2.檢查是否有系統權限代理設定
                    SQL = "SELECT a.*";
                    SQL += ", b.Syscode, b.agent_logingrp AS LoginGrp, 'T' AS Dept";
                    SQL += ", (SELECT DataBranch FROM SYScode WHERE syscode = '" + syscode + "') AS DataBranch";
                    SQL += " FROM scode AS a";
                    SQL += " INNER JOIN sysctrl_agent AS b ON b.agent_scode = a.scode";
                    SQL += " WHERE a.scode = '" + Uid + "'";
                    SQL += " AND b.syscode = '" + syscode + "'";
                    SQL += " AND b.beg_date + CONVERT(DATETIME, b.beg_time) < GETDATE()";
                    SQL += " AND b.end_date + CONVERT(DATETIME, b.end_time) > GETDATE()";
                    using (SqlDataReader dr1 = connsys.ExecuteReader(SQL)) {
                        if (dr1.Read()) {
                            login_flag = true;
                            SetSession(dr1, ref strRet);
                        }
                    }
                }

                if (login_flag == false) {
                    Session["Password"] = false;
                    strRet = "帳號/密碼 不合！請重新登入！";
                }
            } else {
                //Response.Write("4=輸入錯誤 !<hr>");
                Session["Password"] = false;
                Session.Abandon();
                strRet = "輸入錯誤 !";
            }
        }
        catch (Exception ex) {
            //Response.Write("5=執行錯誤 !" + "<hr>");
            exMsg = connsys.ConnString + "\n" + SQL;
            if (connsys != null) Sys.errorLog(ex, connsys.exeSQL, "checklogin");
            strRet = "執行錯誤 !" + ex.InnerException.Message + "\\n\\n" + SQL;
            Session["Password"] = false;
            Session.Abandon();
            throw;
            //throw new Exception(exMsg, ex);
        }

        return strRet;
    }

    private void SetSession(SqlDataReader dr, ref string strRet) {
        Session["Password"] = true;
        Session["se_scode"] = dr["scode"].ToString();
        Session["scode"] = dr["scode"].ToString();
        Session["sc_name"] = dr["sc_name"].ToString();
        Session["SeSysPwd"] = dr["sys_pwd"].ToString();
        Session["SeBranch"] = dr["DataBranch"].ToString();
        Session["Dept"] = dr["Dept"].ToString();
        Session["Syscode"] = Sys.Syscode;//.getAppSetting("syscode");// dr["Syscode"].ToString();//因有新舊資料問題,改用舊系統的syscode
        Session["LoginGrp"] = dr["LoginGrp"].ToString();
        if (!dr.IsClosed) dr.Close();
        
        //檢查是否有系統權限代理設定
        SQL = "SELECT agent_logingrp ";
        SQL += " FROM sysctrl_agent";
        SQL += " WHERE agent_scode = '" + Session["scode"] + "'";
        SQL += " AND syscode = '" + Session["Syscode"] + "'";
        SQL += " AND beg_date + CONVERT(DATETIME, beg_time) < GETDATE()";
        SQL += " AND end_date + CONVERT(DATETIME, end_time) > GETDATE()";
        string agent_logingrp = connsys.getString(SQL);
        if (agent_logingrp != "") {
            Session["LoginGrp"] = agent_logingrp;
        }

        SQL = "select b.grpid,b.grplevel from scode_group a ";
        SQL += "inner join grpid b on b.grpclass=a.grpclass and b.grpid=a.grpid ";
        SQL += " and (substring(b.grpid,1,1)='" + Session["Dept"] + "' or substring(b.grpid,1,3)='000') ";
        SQL += " where a.scode='" + Session["scode"] + "' and a.grpclass='" + Session["SeBranch"] + "' ";
        //Response.Write("2=" + SQL+"<hr>");
        DataTable dt = new DataTable();
        connsys.DataTable(SQL, dt);
        for (int i = 0; i < dt.Rows.Count; i++) {
            Session["se_grpid"] = dt.Rows[i].SafeRead("grpid", "");
            Session["se_grplevel"] = dt.Rows[i].SafeRead("grplevel", "0");
            if (Convert.ToInt32(dt.Rows[i].SafeRead("grplevel", "0")) < Convert.ToInt32(Sys.GetSession("se_grplevel"))) {
                Session["se_grpid"] = dt.Rows[i].SafeRead("grpid", "");
                Session["se_grplevel"] = dt.Rows[i].SafeRead("grplevel", "0");
            }
        }

        SQL = "select branchname from branch_code where branch='" + Session["SeBranch"] + "'";
        Session["SeBranchName"] = connsys.ExecuteScalar(SQL) ?? "";

        SQL = "UPDATE scode SET VisitCount = isnull(VisitCount,0)+1 " +
            ", LastVisit = GETDATE() " +
            "WHERE scode = '" + Session["scode"] + "'";
        connsys.ExecuteNonQuery(SQL);
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>登入</title>
<meta http-equiv="x-ua-compatible" content="IE=10">
<link href="./inc/setstyle.css" rel="stylesheet" type="text/css" />
<script language="javascript" type="text/javascript">
<%#ScriptString%>
</script>
</head>
<body>
<%#exMsg%>
</body>
</html>
