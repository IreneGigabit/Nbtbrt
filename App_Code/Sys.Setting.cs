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
    public static string Host = HttpContext.Current.Request.ServerVariables["HTTP_HOST"].ToString().ToLower();

    /// <summary>
    /// 聖島人主機
    /// </summary>
    public static string SIServer {
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

    /// <summary>
    /// menu/權限使用的syscode
    /// </summary>
    public static string Sysmenu {
        get {
            if (Host == "sinn05") return "nntbrt";//正式環境
            if (Host == "sic10") return "nctbrt";//正式環境
            if (Host == "sis10") return "nstbrt";//正式環境
            if (Host == "sik10") return "nktbrt";//正式環境
            return "nntbrt";//開發環境
        }
    }

    /// <summary>
    /// 程式使用的syscode(ex:流程,要與舊資料一致)
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

    /// <summary>
    /// Project名稱
    /// </summary>
    public static string Project {
        get {
            return "國內所商標網路作業系統";
        }
    }

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

    /// <summary>
    /// 電子送件總管處檔案目錄
    /// </summary>
    public static string IPODir {
        get {
            if (Sys.Host.IndexOf("web") > -1) {
                return "/nbtbrt/IPOSend/_商標電子送件區/web02";
            } else {
                return "/nbtbrt/IPOSend/_商標電子送件區";
            }
        }
    }

    /// <summary>
    /// 檔案路徑轉換(檢視&複製檔案用)，brbrt→nbtbrt
    /// </summary>
    public static string Path2Nbtbrt(string path) {
        path = path.Replace("/", @"\");
        path = path.Replace(@"\btbrt\", @"\nbtbrt\");
        return path;
    }

    /// <summary>
    /// 檔案路徑轉換(寫入DB用)，nbtbrt→brbrt
    /// </summary>
    public static string Path2Btbrt(string path) {
        path = path.Replace(@"\nbtbrt\", @"\btbrt\");
        path = path.Replace(@"/nbtbrt/", @"\btbrt\");
        return path;
    }

    ////////////////////////////////////////////////////////////////////////
    /// <summary>  
    /// 取得某個Session值  
    /// </summary>  
    /// <param name="strSessionName">Session對象名稱</param>  
    /// <returns>Session值</returns>  
    public static string GetSession(string strSessionName) {
        return (HttpContext.Current.Session[strSessionName] ?? "").ToString();
    }

    /// <summary>  
    /// 取得Session ID
    /// </summary>  
    /// <returns>Session值</returns>  
    public static string GetSessionID() {
        return HttpContext.Current.Session.SessionID;
    }

    /// <summary>  
    /// 設定Session值
    /// </summary>  
    /// <returns>Session值</returns>  
    public static void SetSession(string strSessionName, object sessionValue) {
        HttpContext.Current.Session[strSessionName] = sessionValue;
    }

    /// <summary>  
    /// 取得應用程式在伺服器上虛擬應用程式根路徑ex:/nbtbrt
    /// </summary>  
    /// <returns>應用程式根路徑</returns>  
    public static string GetRootDir() {
        return HttpContext.Current.Request.ApplicationPath;
    }

    /// <summary>  
    /// 取得ASCX在伺服器上的路徑
    /// </summary>  
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

    public static bool IsAdmin() {
        bool b = (GetSession("scode").ToLower() == "admin" || GetSession("LoginGrp").ToLower().IndexOf("admin") > -1);
        return b;
    }

    public static bool IsDebug() {
        bool b = (Sys.getAppSetting("DebugScode").ToLower().IndexOf(GetSession("scode").ToLower()) > -1);
        return b;
    }

    public static string getConnString(string parameter) {
        return ConfigurationManager.ConnectionStrings[parameter].ConnectionString ?? "";
    }

    public static string getAppSetting(string parameter) {
        return ConfigurationManager.AppSettings[parameter] ?? "";
    }

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
            //eSQL = eSQL + "'" + (Sys.getAppSetting("Sysmenu") == "" ? GetRootDir().Replace("/", "") : Sys.getAppSetting("Sysmenu")) + "',";
            eSQL = eSQL + "'" + (Sys.Sysmenu == "" ? GetRootDir().Replace("/", "") : Sys.Sysmenu) + "',";
            eSQL = eSQL + "'" + prgID + "',";
            eSQL = eSQL + "'" + ex.Message.Replace("'", "''") + "',";
            //eSQL = eSQL + "'" + string.Join("\r\n-----\r\n", sqlList.ToArray()).Replace("'", "''") + "',";
            eSQL = eSQL + "'" + sqlList.Last().Replace("'", "''") + "',";//只記錄最後一個sql
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

        MailMsg.Subject = Subject;//主旨
        MailMsg.SubjectEncoding = Encoding.UTF8;
        MailMsg.Body = Msg;//內文
        MailMsg.BodyEncoding = Encoding.UTF8;
        MailMsg.IsBodyHtml = true;//郵件格式為HTML

        //SmtpClient client = new SmtpClient("192.192.10.30");
        //SmtpClient client = new SmtpClient("sin22.saint-island.com.tw");
        //SmtpClient client = new SmtpClient("sin30.saint-island.com.tw");
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
}
