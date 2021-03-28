<%@Page Language="C#" CodePage="65001"%>
<%@Import Namespace = "System.Text"%>
<%@Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<script runat="server">
    protected string SQL = "";

    DBHelper connsys = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    private void Page_Unload(System.Object sender, System.EventArgs e) {
        if (connsys != null) connsys.Dispose();
    }

    private void Page_Load(Object sender, EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        connsys = new DBHelper(Conn.ODBCDSN).Debug(Request["chkTest"] == "TEST");

        if (Request["syscode"] != "" && Request["scode"] != "") {
            SQL = "SELECT a.scode,a.sc_name,a.sys_pwd,b.logingrp,b.dept ";
            SQL += "FROM scode a INNER JOIN sysctrl b ON a.scode = b.scode ";
            SQL += "where a.scode='" + Request["scode"] + "' AND b.Syscode ='" + Request["syscode"] + "'";
            string sys_password = "";
            using (SqlDataReader dr = connsys.ExecuteReader(SQL)) {
                if (dr.Read()) {
                    sys_password = dr.SafeRead("sys_pwd", "");
                }
            }

            string appath = "";
            SQL = "SELECT appath,ReMark from ap where syscode='" + Request["syscode"] + "' AND apcode='" + Request["prgid"] + "'";
            using (SqlDataReader dr = connsys.ExecuteReader(SQL)) {
                if (dr.Read()) {
                    appath = dr.SafeRead("appath", "") + dr.SafeRead("ReMark", "");
                }
            }

            //2009/9/19智產異動主管簽核，由Email登錄，增加參數qryar_mark=A智產,E代收代付 
            //2010/9/1指定代理人連結查詢，增加in_no,prgid
            //2013/10/28密碼改加密過修改傳sys_pwd
            Response.Redirect("checklogin.aspx?tfx_scode=" + Request["scode"] + "&sys_pwd=" + sys_password + "&toppage=0&syscode=" + Request["syscode"] + "&stat=Y&mail=" + Request["mail"] + "&appath=" + appath + "&qryar_mark=" + Request["qryar_mark"] + "&in_no=" + Request["in_no"] + "&prgid=" + Request["prgid"]);
        }
    }
</script>
