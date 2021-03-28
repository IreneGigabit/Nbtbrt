using System;
using System.Web;
using System.Data.SqlClient;
using System.Text;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

/// <summary>
/// Token 的摘要描述
/// </summary>
public class TokenN
{
    public string ConnectionString { get; set; }
    public string SysCode { get; set; }//系統
    public string APcode { get; set; }//程式
    public string Title { get; set; }//程式名稱
    public string Title2 { get; set; }//程式名稱2

    public string UGrpID { get; set; }//群組
    public int Rights { get; set; }//取得的權限值
    private bool _Passworded { get; set; }//是否已登入
    //public int chkRight { get; set; }//要檢查的權限值

    //權限
    public bool Menu { get; set; }//選單
    public bool List { get; set; }//查詢
    public bool Add { get; set; }//新增 
    public bool Edit { get; set; }//修改
    public bool Del { get; set; }//刪除
    public bool Print { get; set; }//列印
    public bool A { get; set; }//保留A
    public bool B { get; set; }//保留B
    public bool C { get; set; }//保留C
    public bool Debug { get; set; }//有無除錯權限

    public string DebugStr {//☑測試
        get {
            if (this.APcode == "" || this.APcode == null) {//沒有prgid就用Sys.IsDebug判斷
                if (Sys.IsDebug()) {
                    return "<label id=\"labTest\"><input type=\"checkbox\" id=\"chkTest\" name=\"chkTest\" value=\"TEST\" />測試1</label>";
                }
            } else {
                if ((this.Rights & 512) > 0) {//有prgid就用權限值判斷
                    return "<label id=\"labTest\"><input type=\"checkbox\" id=\"chkTest\" name=\"chkTest\" value=\"TEST\" />測試</label>";
                }
            }
            return "";
        }
    }

    public TokenN()
        : this(
         Sys.Sysmenu//.getAppSetting("Sysmenu")//因menu的syscode不同.所以不能用syscode
        , ""
        , Sys.GetSession("LoginGrp")
        , Conn.ODBCDSN
        ) { }

    public TokenN(string APcode)
        : this(
         Sys.Sysmenu//.getAppSetting("Sysmenu")
        , APcode
        , Sys.GetSession("LoginGrp")
        , Conn.ODBCDSN
        ) { }

    public TokenN(string Syscode, string APcode)
        : this(
        Syscode, APcode
        , Sys.GetSession("LoginGrp")
        , Conn.ODBCDSN
        ) { }

    public TokenN(string Syscode, string APcode, string UGrpID, string ConnectionString) {
        this.SysCode = Syscode;
        this.APcode = APcode;
        this.UGrpID = UGrpID;
        this.ConnectionString = ConnectionString;
        this.Rights = 0;
        bool flag;
        this._Passworded = Boolean.TryParse(Sys.GetSession("Password"), out flag);
    }

    public int CheckMe() {
        return CheckMe(1, false, false);
    }

    public int CheckMe(bool chkRef) {
        return CheckMe(1, chkRef, false);
    }

    public int CheckMe(int chkRight) {
        return CheckMe(chkRight, true, false);
    }

    public int CheckMe(bool chkRef, bool rtnJson) {
        return CheckMe(1, chkRef, rtnJson);
    }

    public int CheckMe(int chkRight, bool rtnJson) {
        return CheckMe(chkRight, true, rtnJson);
    }

    public int CheckMe(int chkRight, bool chkRef, bool rtnJson) {
        try {
            this.Rights = 0;
            this.Menu = false;
            this.List = false;
            this.Add = false;
            this.Edit = false;
            this.Del = false;
            this.Print = false;
            this.A = false;
            this.B = false;
            this.C = false;
            this.Debug = false;

            //檢查網頁參照
            Uri webRef = HttpContext.Current.Request.UrlReferrer;//http://localhost/system/sys_main.html
            string stmp = "";
            //HttpContext.Current.Response.Write(this.SysCode + "<BR>");
            //HttpContext.Current.Response.Write(this.APcode + "<BR>");
            //HttpContext.Current.Response.Write(this.UGrpID + "<BR>");
            //HttpContext.Current.Response.Write(this.ConnectionString + "<BR>");
            //HttpContext.Current.Response.Write(this.Rights + "<BR>");
            //HttpContext.Current.Response.Write(this._Passworded + "<BR>");
            //HttpContext.Current.Response.Write(HttpContext.Current.Session["Password"] + "<BR>");

            if (chkRef) {
                if (webRef != null) {
                    stmp = webRef.Authority;
                    if (stmp.IndexOf(":") > -1) {
                        if (stmp != string.Format("{0}:{1}", HttpContext.Current.Request.Url.Host, HttpContext.Current.Request.Url.Port)) {//localhost:8011
                            //HttpContext.Current.Session["Password"] = false;
                            Sys.SetSession("Password", false);
                            throw new Exception("頁面參照錯誤！(0)");
                        }
                    } else {
                        if (stmp != HttpContext.Current.Request.Url.Authority) {//localhost
                            //HttpContext.Current.Session["Password"] = false;
                            Sys.SetSession("Password", false);
                            throw new Exception("頁面參照錯誤！(1)");
                        }
                    }
                } else {
                    //HttpContext.Current.Session["Password"] = false;
                    Sys.SetSession("Password", false);
                    throw new Exception("無頁面參照！");
                }
            }
            //HttpContext.Current.Response.Write(this.SysCode + "<BR>");
            //HttpContext.Current.Response.Write(this.APcode + "<BR>");
            //HttpContext.Current.Response.Write(this.UGrpID + "<BR>");
            //HttpContext.Current.Response.Write(this.ConnectionString + "<BR>");
            //HttpContext.Current.Response.Write(this.Rights + "<BR>");
            //HttpContext.Current.Response.Write(this._Passworded + "<BR>");
            //HttpContext.Current.Response.Write(HttpContext.Current.Session["Password"] + "<BR>");

            if (_Passworded) {
                bool myRights = false;
                SqlConnection cn = new SqlConnection(this.ConnectionString);
                SqlDataReader dr = null;
                string SQL = "SELECT Rights FROM LoginAP" +
                    " WHERE LoginGrp = '" + UGrpID + "'" +
                    " AND APcode = '" + APcode + "'" +
                    " AND SYScode = '" + SysCode + "'" +
                    " AND GETDATE() BETWEEN beg_date AND end_date";
                //HttpContext.Current.Response.Write(SQL);
                //HttpContext.Current.Response.End();
                try {
                    SqlCommand cmd = new SqlCommand(SQL, cn);
                    cn.Open();
                    dr = cmd.ExecuteReader();
                    if (dr.Read()) {
                        this.Rights = Convert.ToInt32(dr["Rights"]);
                        this.Menu = ((this.Rights & chkRight) == 1) ? true : false;
                        this.List = ((this.Rights & chkRight) == 2) ? true : false;
                        this.Add = ((this.Rights & chkRight) == 4) ? true : false;
                        this.Edit = ((this.Rights & chkRight) == 8) ? true : false;
                        this.Del = ((this.Rights & chkRight) == 16) ? true : false;
                        this.Print = ((this.Rights & chkRight) == 32) ? true : false;
                        this.A = ((this.Rights & chkRight) == 64) ? true : false;
                        this.B = ((this.Rights & chkRight) == 128) ? true : false;
                        this.C = ((this.Rights & chkRight) == 258) ? true : false;
                        this.Debug = ((this.Rights & chkRight) == 512) ? true : false;

                        myRights = ((this.Rights & chkRight) == 1) ? true : false;
                        //HttpContext.Current.Response.Write(this.Rights + "/" + chkRight);
                        //HttpContext.Current.Response.End();
                    }
                    dr.Close();

                    SQL = "SELECT APnameC FROM AP " +
                        " Where APcode = '" + APcode + "'" +
                        " AND SYScode = '" + SysCode + "'";
                    cmd.CommandText = SQL;
                    dr = cmd.ExecuteReader();
                    if (dr.Read()) {
                        this.Title = dr["APnameC"] + "";
                        this.Title2 = dr["APnameC"] + "&nbsp;管理";
                    }
                    dr.Close();
                    cn.Close();

                    if (!myRights) throw new Exception("該作業未授權 !");
                }
                catch (Exception ex) {
                    throw;
                }
                finally {
                    if (dr != null) dr.Close();
                    if (cn != null) cn.Close();
                }
            } else {
                //HttpContext.Current.Response.Write(this.SysCode + "<BR>");
                //HttpContext.Current.Response.Write(this.APcode + "<BR>");
                //HttpContext.Current.Response.Write(this.UGrpID + "<BR>");
                //HttpContext.Current.Response.Write(this.ConnectionString + "<BR>");
                //HttpContext.Current.Response.Write(this.Rights + "<BR>");
                //HttpContext.Current.Response.Write(this._Passworded + "<BR>");
                //HttpContext.Current.Response.Write(HttpContext.Current.Session["Password"] + "<BR>");
                //HttpContext.Current.Response.End();
                //HttpContext.Current.Response.Write(PageDirect(Sys.GetSession("Password") + "系統停滯時間逾時，請重新登入 !", false));
                //HttpContext.Current.Response.End();
                _Passworded = false;
                Sys.SetSession("Password", false);
                throw new Exception("系統停滯時間逾時，請重新登入(token)!");
            }
        }
        catch (Exception ex) {
            HttpContext.Current.Response.Write(PageDirect(ex.Message, rtnJson));
            HttpContext.Current.Response.End();
        }

        return this.Rights;
    }

    private string PageDirect(string strMsg, bool rtnJson) {
        if (rtnJson) {
            JObject obj = new JObject(
                             new JProperty("error", 000),
                             new JProperty("msg", strMsg)
                            );
            return JsonConvert.SerializeObject(obj, Formatting.Indented);
        }

        string url = "Default.aspx";
        if (!_Passworded) url = "Login.aspx";

        StringBuilder strOut = new StringBuilder();
        strOut.AppendLine("<html><head><meta http-equiv='Content-Type' content='text/html; charset=utf-8'>");
        strOut.AppendLine("<script type='text/javascript'>");
        strOut.AppendLine("alert('" + strMsg.Replace("'", "\\'") + "'); ");
        strOut.AppendLine("if (typeof(window.opener)!='undefined'){");
        strOut.AppendLine(" window.opener.top.location.href = '" + HttpContext.Current.Request.ApplicationPath + "/" + url + "'; ");
        strOut.AppendLine(" window.close();");
        strOut.AppendLine("}else{");
        strOut.AppendLine(" window.top.location.href = '" + HttpContext.Current.Request.ApplicationPath + "/" + url + "'; ");
        strOut.AppendLine("}");
        strOut.AppendLine("</script>");

        return strOut.ToString();
    }
}
