using System;
using System.Collections.Generic;
using System.Web;
using System.Data.SqlClient;
using System.Text;
using System.Security.Cryptography;

/// <summary>
/// Token 的摘要描述
/// 如同asp的server.inc
/// </summary>
public class Token
{
    private string m_CnnStr;
    private string m_APcode;
    private string m_UID;
    private string m_UGrpID;
    private int m_Rights;

    public Token()
    {
        //
        // TODO: 在此加入建構函式的程式碼
        //
        m_CnnStr = "";
        m_APcode = "";
        m_UGrpID = "";
        m_Rights = 0;
    }

    public Token(string APcode, int Rights, string ConnectionString, string UGrpID)
    {
        m_CnnStr = ConnectionString;
        m_APcode = APcode;
        m_UGrpID = UGrpID;
        m_Rights = Rights;
    }

    public Token(string APcode, int Rights)
    {
        m_CnnStr = HttpContext.Current.Session["ODBCDSN"].ToString();
        m_APcode = APcode;
		m_UGrpID = HttpContext.Current.Session["LoginGrp"].ToString();
        m_Rights = Rights;
    }

    public string ConnectionString
    {
        get { return m_CnnStr; }
        set { m_CnnStr = value; }
    }

    public string APcode
    {
        get { return m_APcode; }
        set { m_APcode = value; }
    }

    public string UGrpID
    {
        get { return m_UGrpID; }
        set { m_UGrpID = value; }
    }

    public int Rights
    {
        get { return m_Rights; }
        set { m_Rights = value; }
    }

    public int CheckMe()
    {
        bool bPasswd = Convert.ToBoolean(HttpContext.Current.Session["pwd"]);
        return DoCheckIt(bPasswd, true);
    }

    public int CheckMe2()
    {
        bool bPasswd = Convert.ToBoolean(HttpContext.Current.Session["pwd"]);
        return DoCheckIt(bPasswd, false);
    }

    public int CheckMe(bool bPasswd)
    {
        return DoCheckIt(bPasswd, true);
    }

    public int CheckMe(string ConnectionString, string APcode, string UGrpID, int Rights, bool bPasswd)
    {
        m_CnnStr = ConnectionString;
        m_APcode = APcode;
        m_UGrpID = UGrpID;
        m_Rights = Rights;

        return DoCheckIt(bPasswd, true);
    }

    public int CheckMe(string ConnectionString, string APcode, string UGrpID, int Rights, bool bPasswd, bool bRef)
    {
        m_CnnStr = ConnectionString;
        m_APcode = APcode;
        m_UGrpID = UGrpID;
        m_Rights = Rights;

        return DoCheckIt(bPasswd, bRef);
    }

    private int DoCheckIt(bool bPasswd, bool bRef)
    {
        int AccsRights = -1;

        try
        {
            //檢查網頁參照
            string webRef = HttpContext.Current.Request.ServerVariables["HTTP_REFERER"]??"";
            string stmp = "";
            int n1 = 0;
            int n2 = 0;

            if (bRef)
            {
                n1 = webRef.IndexOf("//");
                if (n1 > 0)
                {
                    n1 = n1 + 2;
                    n2 = webRef.IndexOf("/", n1);
                    if (n2 > n1)
                    {
                        stmp = webRef.Substring(n1, n2 - n1);
                        if (stmp != HttpContext.Current.Request.ServerVariables["SERVER_NAME"])
                        {
                            HttpContext.Current.Session["pwd"] = false;
                            throw new System.Exception("頁面參照錯誤！");
                        }
                    }
                    else
                    {
                        HttpContext.Current.Session["pwd"] = false;
                        throw new System.Exception("頁面參照錯誤！");
                    }
                }
                else
                {
                    HttpContext.Current.Session["pwd"] = false;
                    throw new System.Exception("頁面參照錯誤！");
                }
            }

            if (bPasswd)
            {
                if (m_APcode.Length == 0 || m_UGrpID.Length == 0)
                {
                    AccsRights = m_Rights;
                    return AccsRights;
                }

                SqlConnection cn = new SqlConnection(m_CnnStr);
                SqlDataReader dr = null;
                string SQL = "SELECT Rights FROM LoginAP" +
                    " WHERE LoginGrp = '" + m_UGrpID + "'" +
                    " AND APcode = '" + m_APcode + "'" +
					" AND SYScode = '" + HttpContext.Current.Session["Syscode"].ToString() + "'" +
                    " AND GETDATE() BETWEEN beg_date AND end_date";
                //HttpContext.Current.Response.Write(SQL);
                //HttpContext.Current.Response.End();
                try
                {
                    SqlCommand cmd = new SqlCommand(SQL, cn);
                    cn.Open();
                    dr = cmd.ExecuteReader();
                    int myRights = 0;

                    if (dr.HasRows)
                    {
                        dr.Read();
                        AccsRights = Convert.ToInt32(dr["Rights"]);
                        myRights = ((AccsRights & 1) == 1) ? (AccsRights & m_Rights) : 0;
                        //HttpContext.Current.Response.Write(AccsRights + "/" + myRights);
                        //HttpContext.Current.Response.End();
                    }
                    dr.Close();
                    cn.Close();

                    if (myRights == 0) throw new System.Exception("該系統未授權 !");
                }
                catch (Exception ex)
                {
                    throw (ex);
                }
                finally
                {
                    if (dr != null) dr.Close();
                    if (cn != null) cn.Close();
                }
            }
            else
            {
                throw new System.Exception("系統停滯時間逾時，請重新登入 !");
            }
        }
        catch (Exception ex)
        {
            HttpContext.Current.Response.Write(PageRsponse(ex.Message));
            HttpContext.Current.Response.End();
        }

        return AccsRights;
    }

    private string PageRsponse(string strMsg)
    {
        string strOut = "";
        strOut = "<html><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\">" +
            "<script type=\"text/javascript\" language=\"javascript\">\nwindow.alert(\"" + strMsg + "\");\n" +
            "if (typeof (top.opener) == 'object') window.close();\n" +
			"else top.location.href=\"http://" + HttpContext.Current.Session["uploadserver"].ToString() + "/Fimp/default.asp\";\n</script></head><body></body></html>\n";
			//"else top.location.href=\"../default.aspx\";\n</script></head><body></body></html>\n";
		return strOut;
    }

    public static bool IsAdmin()
    {
        bool b = (HttpContext.Current.Session["scode"].ToString() == "admin" || HttpContext.Current.Session["LoginGrp"].ToString() == "AccountAdmin");
        return b;
    }

    public static string MD5Hash(string Str)
    {
        ASCIIEncoding AE = new ASCIIEncoding();
        Byte[] data = AE.GetBytes(Str);
        // This is one implementation of the abstract class MD5.
        MD5CryptoServiceProvider md5 = new MD5CryptoServiceProvider();
        Byte[] result = md5.ComputeHash(data);
        string hashStr = BitConverter.ToString(result);

        hashStr = hashStr.Replace("-", "");
        hashStr = hashStr.ToLower();

        return hashStr;
    }
}
