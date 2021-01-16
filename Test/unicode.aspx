<%@ Page Language="C#" %>

<script runat="server">
    private void Page_Load(System.Object sender, System.EventArgs e) {
        //http://web08/nbtbrt/report/unicodeTester.aspx
        Response.CacheControl = "Private";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;
        Response.Clear();
        Response.AddHeader("Content-Disposition", "attachment; filename=\"new.txt\"");
        Response.ContentType = "text/plain";


        string xxx = "1234567890123456789012345678901234567890";
        string aaa = "TD DUERO TONELERÍA DE CALIDAD 及圖";
        string bbb = "TD DUERO TONELER&#205;A DE CALIDAD 及圖";
        string ccc = "TD DUERO TONELER&Iacute;A DE CALIDAD 及圖";

        Response.Write(HttpUtility.HtmlDecode(xxx) + Environment.NewLine);
        Response.Write(HttpUtility.HtmlDecode(aaa) + Environment.NewLine);
        Response.Write(HttpUtility.HtmlDecode(bbb) + Environment.NewLine);
        Response.Write(HttpUtility.HtmlDecode(ccc) + Environment.NewLine);
        Response.Write("==========================" + Environment.NewLine);
        Response.Write(PadLeftCHT(xxx, 35, '_') + Environment.NewLine);
        Response.Write(PadLeftCHT(aaa, 35, '_') + Environment.NewLine);
        Response.Write(PadLeftCHT(bbb, 35, '_') + Environment.NewLine);
        Response.Write(PadLeftCHT(ccc, 35, '_') + Environment.NewLine);
        Response.Write("==========================" + Environment.NewLine);
        Response.Write(PadRightCHT(xxx, 35, '_') + Environment.NewLine);
        Response.Write(PadRightCHT(aaa, 35, '_') + Environment.NewLine);
        Response.Write(PadRightCHT(bbb, 35, '_') + Environment.NewLine);
        Response.Write(PadRightCHT(ccc, 35, '_') + Environment.NewLine);
    }

    #region 截取字串,指定長度 +static string CutStr(this string str, int len)
    /// <summary>
    /// 截取字串,指定長度
    /// </summary>
    /// <param name="len">截取長度</param>
    /// <returns></returns>
    private string CutStr(string str, int len) {
        if (str == null || str.Length == 0 || len <= 0) {
            return string.Empty;
        }

        int orgLen = str.Length;

        int clen = 0;
        //計算要substr的長度
        while (clen < len && clen < orgLen) {
            //每遇到一個中文，則將目標長度減一。
            if ((int)str[clen] > 128) { len--; }
            clen++;
        }

        if (clen < orgLen) {
            return str.Substring(0, clen);
        } else {
            return str;
        }
    }
    #endregion
    
    #region 字串靠右對齊 +static string PadLeftCHT(this string str, int totalWidth, char paddingChar)
    /// <summary>
    /// 字串靠右對齊，以指定的字元在左側補足長度，超過則截字(中文算2碼)。
    /// </summary>
    /// <param name="totalWidth">長度</param>
    /// <param name="paddingChar">替代字元</param>
    /// <returns></returns>
    private string PadLeftCHT(string str, int totalWidth, char paddingChar) {
        string sResult = CutStr(str,totalWidth);
        int orgLen = Encoding.GetEncoding("big5").GetBytes(sResult).Length;

        if (totalWidth - orgLen > 0) {
            sResult = new string(paddingChar, totalWidth - orgLen) + sResult;
        }

        return sResult;
    }
    #endregion

    #region 字串靠左對齊 +static string PadRightCHT(this string str, int totalWidth, char paddingChar)
    /// <summary>
    /// 字串靠左對齊，以指定的字元在右側補足長度，超過則截字(中文算2碼)。
    /// </summary>
    /// <param name="totalWidth">長度</param>
    /// <param name="paddingChar">替代字元</param>
    /// <returns></returns>
    private string PadRightCHT(string str, int totalWidth, char paddingChar) {
        string sResult = CutStr(str, totalWidth);
        int orgLen = Encoding.GetEncoding("big5").GetBytes(sResult).Length;

        if (totalWidth - orgLen > 0) {
            sResult = sResult + new string(paddingChar, totalWidth - orgLen);
        }

        return sResult;
    }
	#endregion
</script>

