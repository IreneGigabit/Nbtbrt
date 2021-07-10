using System;
using System.Configuration;
using System.Web;
using System.Data.SqlClient;
using System.Collections.Generic;
using System.Net.Mail;
using System.Text;
using System.IO;
using System.Collections;
using System.Collections.Specialized;
using System.Linq;

public partial class Sys
{
    /// <summary>
    /// IIS主機名(小寫)
    /// </summary>
    public static string Host = HttpContext.Current.Request.ServerVariables["HTTP_HOST"].ToString().ToLower().Split(':')[0];

    /// <summary>
    /// 國內案案號長度
    /// </summary>
    public static int DmtSeq = 5;
    public static int DmtSeq1 = 1;

    /// <summary>
    /// 出口案案號長度
    /// </summary>
    public static int ExtSeq = 5;
    public static int ExtSeq1 = 1;

    #region SIServer - 聖島人主機
    /// <summary>
    /// 聖島人主機
    /// </summary>
    public static string SIServer {
        get {
            //if (Host == "web10") return "web01";
            //if (Host == "web08") return "web02";
            switch (Host.Substring(0, 1)) {
                case "w":
                case "b":
                case "l": return Host;
                default: return "sin32";
            }
        }
    }
    #endregion

    #region MG_IIS - 總收發IIS主機
    /// <summary>
    /// 總收發IIS主機
    /// </summary>
    public static string MG_IIS {
        get {
            if (Host == "web10") return "web01";
            if (Host == "web08") return "web02";
            switch (Host.Substring(0, 1)) {
                case "w":
                case "b":
                case "l": return Host;
                default: return "sin32";
            }
        }
    }
    #endregion

    #region Opt_IIS - 爭救案IIS主機
    /// <summary>
    /// 爭救案IIS主機
    /// </summary>
    public static string Opt_IIS {
        get {
            if (Sys.Host.IndexOf("web") == -1)
                return "sik10";//正式環境
            else
                return Host;//開發環境
        }
    }
    #endregion

    #region Sysmenu - menu/權限使用的syscode
    /// <summary>
    /// menu/權限使用的syscode
    /// </summary>
    public static string Sysmenu {
        get {
            if (Host == "sinn05") return "nnbrt";//正式環境
            if (Host == "sic10") return "ncbrt";//正式環境
            if (Host == "sis10") return "nsbrt";//正式環境
            if (Host == "sik10") return "nkbrt";//正式環境
            return "nnbrt";//開發環境
        }
    }
    #endregion

    #region Syscode - db使用的syscode,ex:todo(為了要與舊資料一致)
    /// <summary>
    /// db使用的syscode,ex:流程(為了要與舊資料一致)
    /// </summary>
    public static string Syscode {
        get {
            if (Host == "sinn05") return "NTBRT";//正式環境
            if (Host == "sic10") return "CTBRT";//正式環境
            if (Host == "sis10") return "STBRT";//正式環境
            if (Host == "sik10") return "KTBRT";//正式環境
            return "NTBRT";//開發環境
        }
    }
    #endregion

    #region Project - Project名稱,ex:國內所商標網路作業系統
    /// <summary>
    /// Project名稱
    /// </summary>
    public static string Project {
        get {
            return "國內所商標網路作業系統";
        }
    }
    #endregion

    #region bName - 區所名稱,ex:台北所
    /// <summary>
    /// 區所名稱
    /// </summary>
    public static string bName(string pBranch) {
        string rtnStr = "";
        if (pBranch.ToUpper() == "N") rtnStr = "台北所";
        if (pBranch.ToUpper() == "C") rtnStr = "台中所";
        if (pBranch.ToUpper() == "S") rtnStr = "台南所";
        if (pBranch.ToUpper() == "K") rtnStr = "高雄所";
        return rtnStr;
    }
    #endregion

    #region tdbname - 區所案件資料庫名稱,ex:sinn05.sindbs.dbo
    /// <summary>
    /// 區所案件資料庫名稱,ex:sinn05.sindbs.dbo
    /// </summary>
    public static string tdbname(string pBranch) {
        string rtnStr = "";
        switch (Host) {
            case "sik10": //正式環境
                if (pBranch.ToUpper() == "N") rtnStr = "sinn05.sindbs.dbo";
                if (pBranch.ToUpper() == "C") rtnStr = "sic10.sicdbs.dbo";
                if (pBranch.ToUpper() == "S") rtnStr = "sis10.sisdbs.dbo";
                if (pBranch.ToUpper() == "K") rtnStr = "sik10.sikdbs.dbo";
                break;
            case "web10":
                rtnStr = "web10.sindbs.dbo";//測試環境
                break;
            default:
                rtnStr = "sindbs.dbo";//開發環境
                break;
        }
        return rtnStr;
    }
    #endregion

    ////////////////////////////////////////////////////////////////////////
    #region showLog - 顯示除錯訊息
    /// <summary>  
    /// 顯示除錯訊息,有設定在web.config內DebugScode者才會顯示訊息
    /// </summary>  
    public static void showLog(string msg) {
        if (IsDebug()) {
            //if (HttpContext.Current.Request["chkTest"] == "TEST") {
            HttpContext.Current.Response.Write(msg + "<hr>");
            //}
        }
    }
    /// <summary>  
    /// 顯示除錯訊息,有設定在web.config內DebugScode者才會顯示訊息
    /// </summary>  
    public static void showLog(int msg) {
        if (IsDebug()) {
            //if (HttpContext.Current.Request["chkTest"] == "TEST") {
            HttpContext.Current.Response.Write(msg + "<hr>");
            //}
        }
    }
    #endregion

    #region GetSession - 取得某個Session值
    /// <summary>  
    /// 取得某個Session值
    /// </summary>  
    /// <param name="strSessionName">Session對象名稱</param>  
    /// <returns>Session值</returns>  
    public static string GetSession(string strSessionName) {
        return (HttpContext.Current.Session[strSessionName] ?? "").ToString();
    }
    #endregion

    #region GetSessionID - 取得Session ID
    /// <summary>  
    /// 取得Session ID
    /// </summary>  
    /// <returns>Session值</returns>  
    public static string GetSessionID() {
        return HttpContext.Current.Session.SessionID;
    }
    #endregion

    #region SetSession - 設定Session值
    /// <summary>  
    /// 設定Session值
    /// </summary>  
    /// <returns>Session值</returns>  
    public static void SetSession(string strSessionName, object sessionValue) {
        HttpContext.Current.Session[strSessionName] = sessionValue;
    }
    #endregion

    #region GetRootDir - 取得應用程式在伺服器上虛擬應用程式根路徑ex:/nbtbrt
    /// <summary>  
    /// 取得應用程式在伺服器上虛擬應用程式根路徑ex:/nbtbrt
    /// </summary>  
    /// <returns>應用程式根路徑</returns>  
    public static string GetRootDir() {
        return HttpContext.Current.Request.ApplicationPath;
    }
    #endregion

    #region GetAscxPath - 取得ASCX在伺服器上的路徑
    /// <summary>  
    /// 取得ASCX在伺服器上的路徑
    /// </summary>  
    public static string GetAscxPath(string path) {
        if (IsDebug()) {
            return string.Format("<hr class='style-one'/>{0}<BR>", path);
        } else {
            return "";
        }
    }
    public static string GetAscxPath(System.Web.UI.Control control) {
        if (IsDebug()) {
            //return string.Format("\\{0}\\{1}.ascx<hr class='style-one'/>", dir, control.GetType().ToString().Replace("ASP.", ""))
            //	.Replace(HttpContext.Current.Server.MapPath("/"), "");
            if ((control.TemplateControl.ID ?? "") != "")
                return string.Format("<hr class='style-one'/>{0}/{1}.ascx<BR>", control.TemplateSourceDirectory, control.TemplateControl.ID);
            else
                return string.Format("<hr class='style-one'/>{0}/{1}.ascx<BR>", control.TemplateSourceDirectory, control.GetType().ToString().Replace("ASP.", ""));
        } else {
            return "";
        }
    }
    #endregion

    #region IsAdmin - 判斷是否為admin(id=admin或group like admin)
    /// <summary>  
    /// 判斷是否為admin(id=admin或group like admin)
    /// </summary>  
    public static bool IsAdmin() {
        bool b = (GetSession("scode").ToLower() == "admin" || GetSession("LoginGrp").ToLower().IndexOf("admin") > -1);
        return b;
    }
    #endregion

    #region IsDebug - 判斷是否為除錯人員(設定於web.config內DebugScode的人員)
    /// <summary>  
    /// 判斷是否為除錯人員(設定於web.config內DebugScode的人員)
    /// </summary>  
    public static bool IsDebug() {
        if (GetSession("scode").ToLower() == "") 
            return false;
        return (Sys.getAppSetting("DebugScode").ToLower().IndexOf(GetSession("scode").ToLower()) > -1);
    }
    #endregion

    #region getConnString - 取得於web.config內的connectionString值
    /// <summary>  
    /// 取得於web.config內的connectionString
    /// </summary>  
    public static string getConnString(string parameter) {
        return ConfigurationManager.ConnectionStrings[parameter] == null ? "" : ConfigurationManager.ConnectionStrings[parameter].ConnectionString;
    }
    #endregion

    #region getAppSetting - 取得於web.config內的appSettings值
    /// <summary>  
    /// 取得於web.config內的appSettings值
    /// </summary>  
    public static string getAppSetting(string parameter) {
        return ConfigurationManager.AppSettings[parameter] ?? "";
    }
    #endregion

    #region errorLog - 寫入錯誤記錄至error_log
    /// <summary>  
    /// 寫入錯誤記錄至error_log
    /// </summary>  
    public static string errorLog(Exception ex, string sqlStr, string prgID) {
        List<string> sqlList = new List<string>();
        sqlList.Add(sqlStr);
        return errorLog(ex, sqlList, prgID);
    }

    public static string errorLog(Exception ex, List<string> sqlList, string prgID) {
        using (SqlConnection cn = new SqlConnection(Conn.btbrt)) {
            cn.Open();
            string eSQL = "INSERT INTO error_log(log_date, log_uid, syscode, prgid, MsgStr, SQLstr, StackStr) VALUES (";
            eSQL = eSQL + "getdate(),";
            //eSQL = eSQL + "'" + (GetSession("scode") == "" ? GetSessionID() : GetSession("scode")) + "',";
            eSQL = eSQL + "'" + (GetSession("scode") == "" ? HttpContext.Current.Request.UserHostName : GetSession("scode")) + "',";
            eSQL = eSQL + "'" + (Sys.Sysmenu == "" ? GetRootDir().Replace("/", "") : Sys.Sysmenu) + "',";
            eSQL = eSQL + "'" + prgID + "',";
            eSQL = eSQL + "'" + (ex.InnerException != null ? ex.InnerException.Message : ex.Message).Replace("'", "''") + "',";
            //eSQL = eSQL + "'" + string.Join("\r\n-----\r\n", sqlList.ToArray()).Replace("'", "''") + "',";
            eSQL = eSQL + "'" + (sqlList.LastOrDefault() ?? "").Replace("'", "''") + "',";//只記錄最後一個sql
            eSQL = eSQL + "'" + (ex.StackTrace ?? "").Replace("'", "''") + "')";

            SqlCommand cmd = new SqlCommand(eSQL, cn);
            cmd.ExecuteNonQuery();

            //抓insert後的流水號
            eSQL = "SELECT SCOPE_IDENTITY() AS Current_Identity";
            cmd.CommandText = eSQL;
            string sqlno = (cmd.ExecuteScalar() ?? "").ToString();
            cmd.Dispose();

            return sqlno;
        }
    }
    #endregion

    #region DoSendMail - 發送郵件
    /// <summary>
    /// 發送郵件
    /// </summary>
    public static void DoSendMail(string Subject, string Msg, string SendFrom, List<string> SendTo, List<string> SendCC, List<string> SendBCC) {
        DoSendMail(Subject, Msg, SendFrom, SendTo, SendCC, SendBCC, new List<string[]>());
    }

    public static void DoSendMail(string Subject, string Msg, string SendFrom, List<string> SendTo, List<string> SendCC, List<string> SendBCC, List<string[]> SendAttach) {
        MailMessage MailMsg = new MailMessage();
        MailMsg.From = new MailAddress(SendFrom);//寄件者
        foreach (string to in SendTo)//收件者
        {
            if (!string.IsNullOrEmpty(to)) {
                MailMsg.To.Add(new MailAddress(to));
            }
        }
        foreach (string cc in SendCC)//副本
        {
            if (!string.IsNullOrEmpty(cc)) {
                MailMsg.CC.Add(new MailAddress(cc));
            }
        }
        foreach (string bcc in SendBCC)//密件副本
        {
            if (!string.IsNullOrEmpty(bcc)) {
                MailMsg.Bcc.Add(new MailAddress(bcc));
            }
        }
        foreach (string[] attach in SendAttach)//附件
        {
            if (!string.IsNullOrEmpty(attach[0])) {
                MemoryStream ms1 = new MemoryStream(File.ReadAllBytes(attach[0]));
                MailMsg.Attachments.Add(new Attachment(ms1, attach[1]));
            }
        }

        if (Sys.Host == "localhost" || Sys.Host == "web08" || Sys.Host == "web10") {
            Subject = "(" + Sys.Host + "測試)" + Subject;
        }

        MailMsg.Subject = Subject;//主旨
        MailMsg.SubjectEncoding = Encoding.UTF8;
        MailMsg.Body = Msg;//內文
        MailMsg.BodyEncoding = Encoding.UTF8;
        MailMsg.IsBodyHtml = true;//郵件格式為HTML

        SmtpClient client = new SmtpClient("sin30");
        try {
            //client.ServicePoint.MaxIdleTime = 2;//連線可閒置時間(毫秒)
            //client.ServicePoint.ConnectionLimit = 1;//允許最大連線數
            //client.Credentials = new System.Net.NetworkCredential("siiplo", "Jean212");
            client.Send(MailMsg);//發送郵件
        }
        catch {
            throw;
        }
        finally {
            client.ServicePoint.CloseConnectionGroup(client.ServicePoint.ConnectionName);//關閉SMTP連線
            //釋放每個附件，才不會Lock住
            if (MailMsg.Attachments != null && MailMsg.Attachments.Count > 0) {
                for (int i = 0; i < MailMsg.Attachments.Count; i++) {
                    MailMsg.Attachments[i].Dispose();
                }
            }
            MailMsg.Dispose();//釋放訊息
        }
    }
    #endregion
}
