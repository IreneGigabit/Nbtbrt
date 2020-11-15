using System;
using System.Collections.Generic;
using System.Web;
using System.Globalization;
using System.Text;
using System.Security.Cryptography;
using System.Collections.Specialized;

public static partial class Util
{
    #region GetTimeString - 轉成時間字串格式(yyyy/m/d hh:mm:ss)
    /// <summary>
    /// 轉成時間字串格式(yyyy/m/d hh:mm:ss)
    /// </summary>
    public static string GetTimeString(this DateTime datetime) {
        return datetime.ToString("yyyy/M/d HH:mm:ss");
    }
    #endregion

    #region GetDateString - 轉成時間字串格式(yyyy/m/d)
    /// <summary>
    /// 轉成時間字串格式(yyyy/m/d)
    /// </summary>
    public static string GetDateString(this DateTime datetime) {
        return datetime.ToString("yyyy/M/d");
    }
    #endregion

    #region ToLongTwDate - 轉成民國日期格式(民國yyy年mm月dd日)
    /// <summary>
    /// 轉成民國日期格式(民國yyy年mm月dd日)
    /// </summary>
    public static string ToLongTwDate(this DateTime datetime) {
        return datetime.ToLongTwDate(true);
    }
    /// <summary>
    /// 轉成民國日期格式(民國yyy年mm月dd日)
    /// </summary>
    public static string ToLongTwDate(this DateTime datetime, bool padZero) {
        TaiwanCalendar taiwanCalendar = new TaiwanCalendar();

        if (padZero) {
            return string.Format("民國{0}年{1}月{2}日",
                taiwanCalendar.GetYear(datetime).ToString().PadLeft(3, '0'),
                datetime.Month.ToString().PadLeft(2, '0'),
                datetime.Day.ToString().PadLeft(2, '0'));
        } else {
            return string.Format("民國{0}年{1}月{2}日",
                taiwanCalendar.GetYear(datetime).ToString(),
                datetime.Month.ToString(),
                datetime.Day.ToString());
        }
    }
    #endregion

    #region ToShortTwDate - 轉成民國日期格式(yyy/mm/dd)
    /// <summary>
    /// 轉成民國日期格式(yyy/mm/dd)
    /// </summary>
    public static string ToShortTwDate(this DateTime datetime) {
        return datetime.ToShortTwDate(true);
    }
    /// <summary>
    /// 轉成民國日期格式(yyy/mm/dd)
    /// </summary>
    public static string ToShortTwDate(this DateTime datetime, bool padZero) {
        TaiwanCalendar taiwanCalendar = new TaiwanCalendar();

        if (padZero) {
            return string.Format("{0}/{1}/{2}",
                taiwanCalendar.GetYear(datetime).ToString().PadLeft(3, '0'),
                datetime.Month.ToString().PadLeft(2, '0'),
                datetime.Day.ToString().PadLeft(2, '0'));
        } else {
            return string.Format("{0}/{1}/{2}",
                taiwanCalendar.GetYear(datetime).ToString(),
                datetime.Month.ToString(),
                datetime.Day.ToString());
        }
    }
    #endregion

    #region GetTwYear - 取得民國年
    /// <summary>
    /// 取得民國年
    /// </summary>
    public static int GetTwYear(this DateTime datetime) {
        TaiwanCalendar taiwanCalendar = new TaiwanCalendar();

        return taiwanCalendar.GetYear(datetime);
    }
    #endregion

    #region ToD9Date - 轉成西元年99/99/9999(月/日/年) 給informix SmallDateTime 使用
    /// <summary>
    /// 轉成西元年99/99/9999(月/日/年) 給informix SmallDateTime 使用
    /// </summary>
    public static string ToD9Date(this string dateString) {
        string RtnVal = "";
        DateTime dt = new DateTime();
        if (DateTime.TryParse(dateString, out dt)) {
            RtnVal = dt.ToString("MM/dd/yyyy");
        } else {
            RtnVal = "";
        }
        return RtnVal;
    }
    #endregion

    #region Left - 從左邊取N個字元，若ln為負數則是剩餘N個字元數 +static string Left(this string str, int ln)
    /// <summary>
    /// 從左邊取N個字元，若ln為負數0則是剩餘N個字元數
    /// </summary>
    public static string Left(this string str, int ln) {
        if (ln >= 0) {
            string sret = str.Substring(0, Math.Min(ln, str.Length));
            return sret;
        } else {
            string sret = str.Substring(0, str.Length + ln);
            return sret;
        }
    }
    #endregion

    #region Right - 從右邊取N個字元 +static string Right(this string str, int ln)
    /// <summary>
    /// 從右邊取N個字元
    /// </summary>
    public static string Right(this string str, int ln) {
        //string sret = s.Substring(str.Length - ln, ln);
        //return sret;
        ln = Math.Max(ln, 0);
        if (str.Length > ln) {
            return str.Substring(str.Length - ln, ln);
        } else {
            return str;
        }
    }
    #endregion

    #region Mid
    public static string Mid(this string s, int idx) {
        string sret = s.Substring(idx);
        return sret;
    }

    public static string Mid(this string s, int idx, int ln) {
        string sret = s.Substring(idx, ln);
        return sret;
    }
    #endregion

    #region CutData
    /// <summary>
    /// 擷取指定長度(byte數)
    /// </summary>
    public static string CutData(this string s, int n) {
        if (n <= 0) return "";
        else if (n > System.Text.Encoding.Default.GetBytes(s).Length) return s;
        else {
            int len = 0;
            string tStr2 = "";
            for (int i = 0; i < s.Length; i++) {
                string thisChar = s.Mid(i, 1);
                len += System.Text.Encoding.Default.GetBytes(thisChar).Length;

                if (len > n) {
                    tStr2 += "...";
                    break;
                }
                tStr2 += thisChar;
            }
            return tStr2;
        }
    }
    #endregion

    #region ToXmlUnicode - 將&#nnnn;轉成word用格式
    /// <summary>
    /// 將&amp;#nnnn;轉成word用格式
    /// </summary>
    public static string ToXmlUnicode(this string str) {
        return str.ToXmlUnicode(false);
    }
    /// <summary>
    /// 將&amp;#nnnn;轉成word用格式
    /// </summary>
    public static string ToXmlUnicode(this string str, bool isEng) {
        foreach (System.Text.RegularExpressions.Match m
            in System.Text.RegularExpressions.Regex.Matches(str, "&#(?<ncr>\\d+?);"))
            str = str.Replace(m.Value, char.ConvertFromUtf32(int.Parse(m.Groups["ncr"].Value)).ToString());
        str = HttpUtility.HtmlDecode(str);
        //str = str.Replace("&", "&amp;");
        //str = str.Replace("<", "&lt;");
        if (isEng) {//防止英文欄位只能半型
            str = str.Replace("’", "'");
            str = str.Replace("＆", "&");
        }
        //ret=str.Replace(">","&gt;");
        //ret=str.Replace("'","&apos;");
        //ret=str.Replace("""","&quot;");

        return str.Trim();
    }
    #endregion

    #region ToUnicode - 將字串內有&amp;#nnnn;格式字元轉成char字元 +static string ToUnicode(this string str)
    /// <summary>
    /// 將字串內有&amp;#nnnn;格式字元轉成char字元
    /// </summary>
    public static string ToUnicode(this string str) {
        //HttpUtility.HtmlDecode("中b文a字&amp;&copy;&Agrave;α-澱粉水解&#37238;之製造方法");
        foreach (System.Text.RegularExpressions.Match m
            in System.Text.RegularExpressions.Regex.Matches(str, "&#(?<ncr>\\d+?);"))
            str = str.Replace(m.Value, char.ConvertFromUtf32(int.Parse(m.Groups["ncr"].Value)).ToString());
        return str;
    }
    #endregion

    #region ToBig5 - 將難字轉成&#nnnn; +static string ToBig5(this string str)
    /// <summary>
    /// 將難字轉成&amp;#nnnn;
    /// </summary>
    public static string ToBig5(this string str) {
        StringBuilder sb = new StringBuilder();
        Encoding big5 = Encoding.GetEncoding("big5");
        Encoding utf32 = Encoding.UTF32;

        if (str == null) return str;

        //有包含用到第二輔助平面的unicode要特別處理
        if (str.Len() != str.Length) {
            for (int i = 0; i < str.Len(); i++) {
                string c = str.Substr(i, 1);

                //string cInBig5 = big5.GetString(Encoding.Convert(utf32, big5, utf32.GetBytes(c)));
                string cInBig5 = big5.GetString(big5.GetBytes(c.ToCharArray()));
                //HttpContext.Current.Response.Write("\r\n<HR>　　c　　　　　→" + c);
                //HttpContext.Current.Response.Write("\r\n<HR>　　cInBig5　　　　　→" + cInBig5);
                //if (c != "?" && cInBig5.IndexOf('?') > -1) {
                if (c != cInBig5) {
                    if (cInBig5 == "??") {//用到第二輔助平面的unicode
                        sb.AppendFormat("&#{0};", c.GetCharCode());
                    } else {
                        sb.AppendFormat("&#{0};", Convert.ToInt32(Convert.ToChar(c)));
                        //sb.Append(HttpUtility.HtmlEncode(c));
                    }
                } else {
                    sb.Append(c);
                }
            }
        } else {
            foreach (char c in str) {
                string cInBig5 = big5.GetString(big5.GetBytes(new char[] { c }));
                //if (c != '?' && cInBig5 == "?") {
                if (c.ToString() != cInBig5) {
                    sb.AppendFormat("&#{0};", Convert.ToInt32(c));
                    //sb.Append(HttpUtility.HtmlEncode(c.ToString()));
                } else {
                    sb.Append(c);
                }
            }
        }
        return sb.ToString();
    }
    #endregion

    #region  取得CharCode(支援罕字)
    /// <summary>
    /// 取得CharCode(支援罕字)
    /// </summary>
    public static int GetCharCode(this string character) {
        UTF32Encoding encoding = new UTF32Encoding();
        byte[] bytes = encoding.GetBytes(character.ToCharArray());
        return BitConverter.ToInt32(bytes, 0);
    }
    #endregion

    #region  "字串".Len();
    /// <summary>
    /// <para>取得字串的長度，會先換成 UTF32再計算，可以避免第二字面的字被拆成兩組字</para>
    /// <para>使用方法："字串".Len();</para>
    /// </summary>
    /// <param name="s">待處理的字串</param>
    /// <returns>字串的文字個數</returns>
    public static int Len(this string s) {
        return Encoding.UTF32.GetByteCount(s) / 4;
    }
    #endregion

    #region  "字串".Substr(int startIndex, int length);    用以取代 string.Substring
    /// <summary>
    /// <para>取得指定位置、長度的子字串，字串會先轉成 UTF-32</para>
    /// <para>使用方法："字串".Substr(起始位置, 擷取長度);</para>
    /// <para>如果 startIndex 大於字數，則傳回 ""  (空字串)</para>
    /// <para>如果 startIndex + length > 字數，則傳回由 startIndex 起之剩餘的字數</para>
    /// </summary>
    /// <param name="s">待處理的字串</param>
    /// <param name="startIndex">擷取的起始位置，不能大於字串長度</param>
    /// <param name="length">擷取的長度，與起始位置相加，不能大於字串長度</param>
    /// <returns>字串</returns>
    public static string Substr(this string s, int startIndex, int length) {
        byte[] byte32Array = Encoding.UTF32.GetBytes(s);
        startIndex *= 4;
        length *= 4;

        if (startIndex >= byte32Array.Length) return "";
        length = (startIndex + length) > byte32Array.Length ? byte32Array.Length - startIndex : length;
        return Encoding.UTF32.GetString(byte32Array, startIndex, length);
    }

    /// <summary>
    /// <para>取得指定位置起算的右方所有子字串，字串會先轉成 UTF-32</para>
    /// <para>使用方法："字串".Substr(起始位置);</para>
    /// <para>如果 startIndex 大於字數，則傳回 ""  (空字串)</para>
    /// </summary>
    /// <param name="s">待處理的字串</param>
    /// <param name="startIndex">擷取的起始位置，不能大於字串長度</param>
    /// <returns>字串</returns>
    public static string Substr(this string s, int startIndex) {
        return s.Substr(startIndex, s.Length);
        //return s.Substr(startIndex, Int32.MaxValue);
    }
    #endregion

    #region GetHashValueMD5 - 依據帶入的字串，產生MD5
    /// <summary>
    /// 依據帶入的字串，產生MD5
    /// </summary>
    public static string GetHashValueMD5(this String data) {
        MD5CryptoServiceProvider md5Hasher = new MD5CryptoServiceProvider();

        byte[] myData = md5Hasher.ComputeHash(System.Text.Encoding.ASCII.GetBytes(data));
        System.Text.StringBuilder sBuilder = new System.Text.StringBuilder();

        for (int i = 0; i < myData.Length; i++) {
            sBuilder.Append(myData[i].ToString("x2"));
        }

        return sBuilder.ToString();
    }
    #endregion

    #region GetRequestParam - 將Request參數轉至Dictionary
    /// <summary>  
    /// 將Request參數轉至Dictionary
    /// </summary>  
    public static Dictionary<string, string> GetRequestParam(HttpContext context) {
        return GetRequestParam(context, false);
    }

    public static Dictionary<string, string> GetRequestParam(HttpContext context, bool debug) {
        if (debug) {
            context.Response.Write(context.Request.RawUrl+"<HR>\n");
        }
        var dict = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
        NameValueCollection col = null;

        col = context.Request.Form;//post
        foreach (var key in col.Keys) {
            if (debug) {
                context.Response.Write(string.Format("{0}:{1}<br>\n", key, col[key.ToString()]));
            }
            //dict[key.ToString()] = col[key.ToString()].ToBig5().Trim();
            dict[key.ToString()] = col[key.ToString()].Trim();
        }

        col = context.Request.QueryString;//get,如果get跟post有同名參數.Request["xxx"]會抓到Get值
        foreach (var key in col.Keys) {
            if (debug) {
                context.Response.Write(string.Format("{0}:{1}<br>\n", key, col[key.ToString()]));
            }
            //dict[key.ToString()] = col[key.ToString()].ToBig5().Trim();
            dict[key.ToString()] = col[key.ToString()].Trim();
        }
        if (debug) context.Response.Write("<HR>\n");

        return dict;
    }

    /*
    public static Dictionary<string, string> GetRequestParam(HttpContext context, bool debug) {
        var dict = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
        NameValueCollection col = null;
        if (context.Request.RequestType == "GET") {
            col = context.Request.QueryString;
        } else {
            col = context.Request.Form;
        }

        foreach (var key in col.Keys) {
            if (debug) {
                context.Response.Write(string.Format("{0}:{1}<br>\n", key, col[key.ToString()]));
            }
            dict.Add(key.ToString(), col[key.ToString()].ToBig5().Trim());
        }
        if (debug) context.Response.Write("<HR>\n");

        return dict;
    }*/
    #endregion

    #region IsNumeric - 判斷是否為數值
    /// <summary>
    /// 判斷是否為數值
    /// </summary>
    public static bool IsNumeric(object Expresion) {
        bool isNum = true;
        double retNum = 0.0;

        isNum = Double.TryParse(Convert.ToString(Expresion), System.Globalization.NumberStyles.Any, System.Globalization.NumberFormatInfo.InvariantInfo, out retNum);

        return isNum;
    }
    #endregion

    #region dbnull - 寫入db用,若是空白則回傳null,否則回傳'xxxxx'
    /// <summary>
    /// 寫入db用,若是空白則回傳null,否則回傳'xxxxx'
    /// </summary>
    public static string dbnull(string iStr) {
        if (iStr == null || iStr == "") return "null";

        iStr = iStr.Replace("'", "''").Trim().ToBig5();
        return "'" + iStr + "'";
    }
    #endregion

    #region dbchar - 寫入db用,若是空白則回傳''
    /// <summary>
    /// 寫入db用,若是空白則回傳''
    /// </summary>
    public static string dbchar(string iStr) {
        if (iStr == null || iStr == "") return "''";

        iStr = iStr.Replace("'", "''").Trim().ToBig5();
        return "'" + iStr + "'";
    }
    #endregion

    #region dbzero - 寫入db用,若是空白則回傳0,否則回傳數值
    /// <summary>
    /// 寫入db用,若是空白則回傳0,否則回傳數值
    /// </summary>
    public static string dbzero(string iStr) {
        if (iStr == null || iStr == "") return "0";

        return iStr;
    }
    #endregion

    #region dbdate - 寫入db用,若是空白則回傳null,否則回傳'日期'
    /// <summary>
    /// 寫入db用,若是空白則回傳null,否則回傳'日期'
    /// </summary>
    public static string dbdate(string iStr, string format) {
        if (iStr == null || iStr == "") return "null";

        iStr = DateTime.ParseExact(iStr.Trim(), "yyyy/M/d tt hh:mm:ss", new System.Globalization.CultureInfo("zh-TW")).ToString(format);
        return "'" + iStr + "'";
    }
    #endregion

    #region parseDBDate - 將db讀出之日期(ex:2014/12/29 上午 12:00:00)轉成指定格式
    /// <summary>
    /// 將db讀出之日期(ex:2014/12/29 上午 12:00:00)轉成指定格式
    /// </summary>
    public static string parseDBDate(string iStr, string format) {
        if (iStr == null || iStr == "") return "";

        return DateTime.ParseExact(iStr.Trim(), "yyyy/M/d tt hh:mm:ss", new System.Globalization.CultureInfo("zh-TW")).ToString(format);
    }
    #endregion

    #region str2Dateime - 將字串日期(ex:2014/12/29)轉成DateTime
    /// <summary>
    /// 將字串日期(ex:2014/12/29)轉成DateTime
    /// </summary>
    public static DateTime str2Dateime(string iStr) {
        return DateTime.ParseExact(iStr.Trim(), "yyyy/M/d", new System.Globalization.CultureInfo("zh-TW"));
    }
    #endregion

    #region fRound - 四捨五入
    /// <summary>  
    /// 四捨五入
    /// </summary>  
    public static decimal fRound(decimal num, int decimals) {
        return Math.Round(num, decimals, MidpointRounding.AwayFromZero);
    }
    #endregion

    #region  "字串".IN(string[]);
    /// <summary>
    /// 類似T-SQL的IN，判斷字串是否符合陣列中的任何值(不分大小寫)。
    /// <para>使用方法："FCF".IN((new[] { "FC1", "FC10", "FC9", "FCA", "FCB", "FCF" })</para>
    /// </summary>
    public static bool IN(this string s, string[] array) {
        if (Array.FindIndex(array, t => t.Equals(s, StringComparison.InvariantCultureIgnoreCase)) > 0)//Array.Contains
            return true;
        else
            return false;
    }
    #endregion

    #region  "字串".IN(string);
    /// <summary>
    /// 類似T-SQL的IN，判斷字串是否符合清單中的任何值(不分大小寫)。
    /// <para>使用方法："FCF".IN("FC1,FC10,FC9,FCA,FCB,FCF")</para>
    /// </summary>
    public static bool IN(this string s, string arrStr) {
        if (Array.FindIndex(arrStr.Split(','), t => t.Equals(s, StringComparison.InvariantCultureIgnoreCase)) > 0)//Array.Contains
            return true;
        else
            return false;
    }
    #endregion
}
