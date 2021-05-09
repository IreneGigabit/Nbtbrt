using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Data.SqlClient;
using System.Data;
using System.Text.RegularExpressions;

/// <summary>
/// 產生html碼
/// </summary>
public static partial class Util
{
    #region 產生Option字串 +static string Option(DBHelper)
    /// <summary>
    /// 產生Option字串(內建「請選擇」)
    /// </summary> 
    /// <param name="conn">DBHelper物件</param>
    /// <param name="sql">SQL語法</param>
    /// <param name="valueFormat">option的value格式用{}包住欄位,ex:{scode}</param>
    /// <param name="textFormat">option的文字格式用{}包住欄位,ex:{scode}_{sc_name}</param>
    /// <returns></returns>
    public static string Option(DBHelper conn, string sql, string valueFormat, string textFormat) {
        return Option(conn, sql, valueFormat, textFormat, "", true);
    }
    public static string Option(DBHelper conn, string sql, string valueFormat, string textFormat, string setValue) {
        return Option(conn, sql, valueFormat, textFormat, "", true, setValue);
    }

    /// <summary>
    /// 產生Option字串
    /// </summary> 
    /// <param name="conn">DBHelper物件</param>
    /// <param name="sql">SQL語法</param>
    /// <param name="valueFormat">option的value格式用{}包住欄位,ex:{scode}</param>
    /// <param name="textFormat">option的文字格式用{}包住欄位,ex:{scode}_{sc_name}</param>
    /// <param name="showEmpty">顯示「請選擇」</param>
    /// <returns></returns>
    public static string Option(DBHelper conn, string sql, string valueFormat, string textFormat, bool showEmpty) {
        return Option(conn, sql, valueFormat, textFormat, "", showEmpty);
    }
    public static string Option(DBHelper conn, string sql, string valueFormat, string textFormat, bool showEmpty, string setValue) {
        return Option(conn, sql, valueFormat, textFormat, "", showEmpty, setValue);
    }

    /// <summary>
    /// 產生Option字串
    /// </summary> 
    /// <param name="conn">DBHelper物件</param>
    /// <param name="sql">SQL語法</param>
    /// <param name="valueFormat">option的value格式用{}包住欄位,ex:{scode}</param>
    /// <param name="textFormat">option的文字格式用{}包住欄位,ex:{scode}_{sc_name}</param>
    /// <param name="attrFormat">option的attribute格式用{}包住欄位,ex:value1='{scode1}'</param>
    /// <param name="showEmpty">顯示「請選擇」</param>
    /// <returns></returns>
    public static string Option(DBHelper conn, string sql, string valueFormat, string textFormat, string attrFormat, bool showEmpty) {
        return Option(conn, sql, valueFormat, textFormat, attrFormat, showEmpty, "");
    }

    /// <summary>
    /// 產生Option字串
    /// </summary> 
    /// <param name="conn">DBHelper物件</param>
    /// <param name="sql">SQL語法</param>
    /// <param name="valueFormat">option的value格式用{}包住欄位,ex:{scode}</param>
    /// <param name="textFormat">option的文字格式用{}包住欄位,ex:{scode}_{sc_name}</param>
    /// <param name="attrFormat">option的attribute格式用{}包住欄位,ex:value1='{scode1}'</param>
    /// <param name="showEmpty">顯示「請選擇」</param>
    /// <param name="setValue">預設值</param>
    /// <returns></returns>
    public static string Option(DBHelper conn, string sql, string valueFormat, string textFormat, string attrFormat, bool showEmpty, string setValue) {
        return Option(conn, sql, valueFormat, textFormat, attrFormat, showEmpty, setValue, "");
        /*
         Regex rgx = new Regex("{([^{}]+)}", RegexOptions.IgnoreCase);
         string rtnStr = "";

         //處理空白選項
         if (showEmpty)
             rtnStr += "<option value='' style='color:blue' selected>請選擇</option>\n";

         using (SqlDataReader dr = conn.ExecuteReader(sql)) {
             while (dr.Read()) {
                 //處理value
                 string val = valueFormat;
                 foreach (Match match in rgx.Matches(valueFormat)) {
                     val = val.Replace(match.Value, dr.SafeRead(match.Result("$1"), ""));
                 }

                 //處理text
                 string txt = textFormat;
                 foreach (Match match in rgx.Matches(textFormat)) {
                     txt = txt.Replace(match.Value, dr.SafeRead(match.Result("$1"), ""));
                 }

                 //處理attribute
                 string attr = attrFormat;
                 foreach (Match match in rgx.Matches(attrFormat)) {
                     attr = attr.Replace(match.Value, dr.SafeRead(match.Result("$1"), ""));
                 }

                 if (string.Compare(val, setValue, true) == 0)
                     rtnStr += "<option value='" + val + "' selected " + attr + ">" + txt + "</option>\n";
                 else
                     rtnStr += "<option value='" + val + "' " + attr + ">" + txt + "</option>\n";
             }
         }
         return rtnStr;
         */
    }

    /// <summary>
    /// 產生Option字串
    /// </summary> 
    /// <param name="valueFormat">option的value格式用{}包住欄位,ex:{scode}</param>
    /// <param name="textFormat">option的文字格式用{}包住欄位,ex:{scode}_{sc_name}</param>
    /// <param name="attrFormat">option的attribute格式用{}包住欄位,ex:value1='{scode1}'</param>
    /// <param name="showEmpty">顯示「請選擇」</param>
    /// <param name="setValue">預設值</param>
    /// <param name="selectedCond">預設欄位條件,ex:scode=n1262</param>
    /// <returns></returns>
    public static string Option(DBHelper conn, string sql, string valueFormat, string textFormat, string attrFormat, bool showEmpty, string setValue, string selectedCondition) {
        DataTable dt = new DataTable();
        conn.DataTable(sql, dt);
        return Option(dt.Select(), valueFormat, textFormat, attrFormat, showEmpty, setValue, selectedCondition);
    }
    #endregion

    #region 產生Option字串 +static string Option(DataTable)
    /// <summary>
    /// 產生Option字串(內建「請選擇」)
    /// </summary> 
    /// <param name="valueFormat">option的value格式用{}包住欄位,ex:{scode}</param>
    /// <param name="textFormat">option的文字格式用{}包住欄位,ex:{scode}_{sc_name}</param>
    /// <returns></returns>
    public static string Option(this DataTable dt, string valueFormat, string textFormat) {
        return Option(dt, valueFormat, textFormat, "", true);
    }
    public static string Option(this DataTable dt, string valueFormat, string textFormat, string setValue) {
        return Option(dt, valueFormat, textFormat, "", true, setValue);
    }

    /// <summary>
    /// 產生Option字串
    /// </summary> 
    /// <param name="valueFormat">option的value格式用{}包住欄位,ex:{scode}</param>
    /// <param name="textFormat">option的文字格式用{}包住欄位,ex:{scode}_{sc_name}</param>
    /// <param name="showEmpty">空白選項的顯示字串</param>
    /// <returns></returns>
    public static string Option(this DataTable dt, string valueFormat, string textFormat, bool showEmpty) {
        return Option(dt, valueFormat, textFormat, "", showEmpty);
    }
    public static string Option(this DataTable dt, string valueFormat, string textFormat, bool showEmpty, string setValue) {
        return Option(dt, valueFormat, textFormat, "", showEmpty, setValue);
    }

    /// <summary>
    /// 產生Option字串
    /// </summary> 
    /// <param name="valueFormat">option的value格式用{}包住欄位,ex:{scode}</param>
    /// <param name="textFormat">option的文字格式用{}包住欄位,ex:{scode}_{sc_name}</param>
    /// <param name="attrFormat">option的attribute格式用{}包住欄位,ex:value1='{scode1}'</param>
    /// <param name="showEmpty">空白選項的顯示字串</param>
    /// <returns></returns>
    public static string Option(this DataTable dt, string valueFormat, string textFormat, string attrFormat, bool showEmpty) {
        return Option(dt, valueFormat, textFormat, attrFormat, showEmpty, "");
    }
    /// <summary>
    /// 產生Option字串
    /// </summary> 
    /// <param name="conn">DBHelper物件</param>
    /// <param name="sql">SQL語法</param>
    /// <param name="valueFormat">option的value格式用{}包住欄位,ex:{scode}</param>
    /// <param name="textFormat">option的文字格式用{}包住欄位,ex:{scode}_{sc_name}</param>
    /// <param name="attrFormat">option的attribute格式用{}包住欄位,ex:value1='{scode1}'</param>
    /// <param name="showEmpty">顯示「請選擇」</param>
    /// <param name="setValue">預設值</param>
    /// <returns></returns>
    public static string Option(this DataTable dt, string valueFormat, string textFormat, string attrFormat, bool showEmpty, string setValue) {
        return Option(dt, valueFormat, textFormat, attrFormat, showEmpty, setValue, "");
    }
    /// <summary>
    /// 產生Option字串
    /// </summary> 
    /// <param name="valueFormat">option的value格式用{}包住欄位,ex:{scode}</param>
    /// <param name="textFormat">option的文字格式用{}包住欄位,ex:{scode}_{sc_name}</param>
    /// <param name="attrFormat">option的attribute格式用{}包住欄位,ex:value1='{scode1}'</param>
    /// <param name="showEmpty">空白選項的顯示字串</param>
    /// <param name="setValue">預設值</param>
    /// <param name="selectedCond">預設欄位條件,ex:scode=n1262</param>
    /// <returns></returns>
    public static string Option(this DataTable dt, string valueFormat, string textFormat, string attrFormat, bool showEmpty, string setValue, string selectedCondition) {
        return Option(dt.Select(), valueFormat, textFormat, attrFormat, showEmpty, setValue, selectedCondition);
        /*
        Regex rgx = new Regex("{([^{}]+)}", RegexOptions.IgnoreCase);
        string rtnStr = "";

        //處理空白選項
        if (showEmpty)
            rtnStr += "<option value='' style='color:blue'>請選擇</option>\n";

        for (int r = 0; r < dt.Rows.Count; r++) {
            //處理預設欄位條件
            string selected = "";
            if (selectedCondition != "") {
                string[] column = selectedCondition.Split('=');
                if (dt.Columns.Contains(column[0]) && dt.Rows[r][column[0]].ToString() == column[1]) {
                    selected = " selected";
                }
            }

            //處理value
            string val = valueFormat;
            foreach (Match match in rgx.Matches(valueFormat)) {
                val = val.Replace(match.Value, dt.Rows[r][match.Result("$1")].ToString());
            }

            //處理text
            string txt = textFormat;
            foreach (Match match in rgx.Matches(textFormat)) {
                txt = txt.Replace(match.Value, dt.Rows[r][match.Result("$1")].ToString());
            }

            //處理attribute
            string attr = attrFormat;
            foreach (Match match in rgx.Matches(attrFormat)) {
                attr = attr.Replace(match.Value, dt.Rows[r][match.Result("$1")].ToString());
            }

            if (selectedCondition != "")
                rtnStr += "<option value='" + val + "' " + attr + "" + selected + ">" + txt + "</option>\n";
            else if (string.Compare(val, setValue, true) == 0)
                rtnStr += "<option value='" + val + "' selected " + attr + ">" + txt + "</option>\n";
            else
                rtnStr += "<option value='" + val + "' " + attr + ">" + txt + "</option>\n";

        }
        return rtnStr;*/
    }
    #endregion

    #region 產生Option字串 +static string Option(DataRow)
    /// <summary>
    /// 產生Option字串(內建「請選擇」)
    /// </summary> 
    /// <param name="valueFormat">option的value格式用{}包住欄位,ex:{scode}</param>
    /// <param name="textFormat">option的文字格式用{}包住欄位,ex:{scode}_{sc_name}</param>
    /// <returns></returns>
    public static string Option(this DataRow[] dr, string valueFormat, string textFormat) {
        return Option(dr, valueFormat, textFormat, "", true);
    }
    public static string Option(this DataRow[] dr, string valueFormat, string textFormat, string setValue) {
        return Option(dr, valueFormat, textFormat, "", true, setValue);
    }

    /// <summary>
    /// 產生Option字串
    /// </summary> 
    /// <param name="valueFormat">option的value格式用{}包住欄位,ex:{scode}</param>
    /// <param name="textFormat">option的文字格式用{}包住欄位,ex:{scode}_{sc_name}</param>
    /// <param name="showEmpty">空白選項的顯示字串</param>
    /// <returns></returns>
    public static string Option(this DataRow[] dr, string valueFormat, string textFormat, bool showEmpty) {
        return Option(dr, valueFormat, textFormat, "", showEmpty);
    }
    public static string Option(this DataRow[] dr, string valueFormat, string textFormat, bool showEmpty, string setValue) {
        return Option(dr, valueFormat, textFormat, "", showEmpty, setValue);
    }

    /// <summary>
    /// 產生Option字串
    /// </summary> 
    /// <param name="valueFormat">option的value格式用{}包住欄位,ex:{scode}</param>
    /// <param name="textFormat">option的文字格式用{}包住欄位,ex:{scode}_{sc_name}</param>
    /// <param name="attrFormat">option的attribute格式用{}包住欄位,ex:value1='{scode1}'</param>
    /// <param name="showEmpty">空白選項的顯示字串</param>
    /// <returns></returns>
    public static string Option(this DataRow[] dr, string valueFormat, string textFormat, string attrFormat, bool showEmpty) {
        return Option(dr, valueFormat, textFormat, attrFormat, showEmpty, "");
    }
    /// <summary>
    /// 產生Option字串
    /// </summary> 
    /// <param name="conn">DBHelper物件</param>
    /// <param name="sql">SQL語法</param>
    /// <param name="valueFormat">option的value格式用{}包住欄位,ex:{scode}</param>
    /// <param name="textFormat">option的文字格式用{}包住欄位,ex:{scode}_{sc_name}</param>
    /// <param name="attrFormat">option的attribute格式用{}包住欄位,ex:value1='{scode1}'</param>
    /// <param name="showEmpty">顯示「請選擇」</param>
    /// <param name="setValue">預設值</param>
    /// <returns></returns>
    public static string Option(this DataRow[] dr, string valueFormat, string textFormat, string attrFormat, bool showEmpty, string setValue) {
        return Option(dr, valueFormat, textFormat, attrFormat, showEmpty, setValue, "");
    }
    /// <summary>
    /// 產生Option字串
    /// </summary> 
    /// <param name="valueFormat">option的value格式用{}包住欄位,ex:{scode}</param>
    /// <param name="textFormat">option的文字格式用{}包住欄位,ex:{scode}_{sc_name}</param>
    /// <param name="attrFormat">option的attribute格式用{}包住欄位,ex:value1='{scode1}'</param>
    /// <param name="showEmpty">空白選項的顯示字串</param>
    /// <param name="setValue">預設值</param>
    /// <param name="selectedCond">預設欄位條件,ex:scode=n1262</param>
    /// <returns></returns>
    public static string Option(this DataRow[] dr, string valueFormat, string textFormat, string attrFormat, bool showEmpty, string setValue, string selectedCondition) {
        Regex rgx = new Regex("{([^{}]+)}", RegexOptions.IgnoreCase);
        string rtnStr = "";

        //處理空白選項
        if (showEmpty)
            rtnStr += "<option value='' style='color:blue' selected>請選擇</option>\n";

        for (int r = 0; r < dr.Length; r++) {
            //處理預設欄位條件
            string selected = "";
            if (selectedCondition != "") {
                string[] column = selectedCondition.Split('=');
                if (dr[r].Table.Columns.Contains(column[0]) && dr[r][column[0]].ToString() == column[1]) {
                    selected = " selected";
                }
            }

            //處理value
            string val = valueFormat;
            foreach (Match match in rgx.Matches(valueFormat)) {
                val = val.Replace(match.Value, dr[r][match.Result("$1")].ToString());
            }

            //處理text
            string txt = textFormat;
            foreach (Match match in rgx.Matches(textFormat)) {
                txt = txt.Replace(match.Value, dr[r][match.Result("$1")].ToString());
            }

            //處理attribute
            string attr = attrFormat;
            foreach (Match match in rgx.Matches(attrFormat)) {
                attr = attr.Replace(match.Value, dr[r][match.Result("$1")].ToString());
            }

            if (selectedCondition != "")
                rtnStr += "<option value='" + val + "' " + attr + "" + selected + ">" + txt + "</option>\n";
            else if (string.Compare(val, setValue, true) == 0)
                rtnStr += "<option value='" + val + "' selected " + attr + ">" + txt + "</option>\n";
            else
                rtnStr += "<option value='" + val + "' " + attr + ">" + txt + "</option>\n";

        }
        return rtnStr;
    }
    #endregion

    #region 產生Radio字串 +static string Radio(DBHelper)
    /// <summary>
    /// 產生Radio字串
    /// </summary> 
    /// <param name="conn">DBHelper物件</param>
    /// <param name="sql">SQL語法</param>
    /// <param name="objName">radio的欄位名稱</param>
    /// <param name="valueFormat">radio的value格式用{}包住欄位,ex:{scode}</param>
    /// <param name="textFormat">radio的文字格式用{}包住欄位,ex:{scode}_{sc_name}</param>
    /// <returns></returns>
    public static string Radio(DBHelper conn, string sql, string objName, string valueFormat, string textFormat) {
        return Radio(conn, sql, objName, valueFormat, textFormat, "");
    }

    /// <summary>
    /// 產生Radio字串
    /// </summary> 
    /// <param name="conn">DBHelper物件</param>
    /// <param name="sql">SQL語法</param>
    /// <param name="objName">radio的欄位名稱</param>
    /// <param name="valueFormat">radio的value格式用{}包住欄位,ex:{scode}</param>
    /// <param name="textFormat">radio的文字格式用{}包住欄位,ex:{scode}_{sc_name}</param>
    /// <param name="attrFormat">option的attribute格式用{}包住欄位,ex:value1='{scode1}'</param>
    /// <returns></returns>
    public static string Radio(DBHelper conn, string sql, string objName, string valueFormat, string textFormat, string attrFormat) {
        Regex rgx = new Regex("{([^{}]+)}", RegexOptions.IgnoreCase);
        string rtnStr = "";

        using (SqlDataReader dr = conn.ExecuteReader(sql)) {
            while (dr.Read()) {
                //處理value
                string val = valueFormat;
                foreach (Match match in rgx.Matches(valueFormat)) {
                    val = val.Replace(match.Value, dr.SafeRead(match.Result("$1"), ""));
                }

                //處理text
                string txt = textFormat;
                foreach (Match match in rgx.Matches(textFormat)) {
                    txt = txt.Replace(match.Value, dr.SafeRead(match.Result("$1"), ""));
                }

                //處理attribute
                string attr = attrFormat;
                foreach (Match match in rgx.Matches(attrFormat)) {
                    attr = attr.Replace(match.Value, dr.SafeRead(match.Result("$1"), ""));
                }

                rtnStr += string.Format("<label><input type='radio' id='{0}{1}' name='{0}' value='{1}' {3}>{2}</label>\n", objName, val, txt, attr);
            }
        }
        return rtnStr;
    }
    #endregion

    #region 產生Radio字串 +static string Radio(DataTable)
    /// <summary>
    /// 產生Radio字串
    /// </summary> 
    /// <param name="objName">radio的欄位名稱</param>
    /// <param name="valueFormat">radio的value格式用{}包住欄位,ex:{scode}</param>
    /// <param name="textFormat">radio的文字格式用{}包住欄位,ex:{scode}_{sc_name}</param>
    /// <returns></returns>
    public static string Radio(this DataTable dt, string objName, string valueFormat, string textFormat) {
        return Radio(dt, objName, valueFormat, textFormat, "");
    }

    /// <summary>
    /// 產生Radio字串
    /// </summary> 
    /// <param name="objName">radio的欄位名稱</param>
    /// <param name="valueFormat">radio的value格式用{}包住欄位,ex:{scode}</param>
    /// <param name="textFormat">radio的文字格式用{}包住欄位,ex:{scode}_{sc_name}</param>
    /// <param name="attrFormat">option的attribute格式用{}包住欄位,ex:value1='{scode1}'</param>
    /// <returns></returns>
    public static string Radio(this DataTable dt, string objName, string valueFormat, string textFormat, string attrFormat) {
        return Radio(dt, objName, valueFormat, textFormat, attrFormat, 0);
    }

    /// <summary>
    /// 產生Radio字串
    /// </summary> 
    /// <param name="objName">radio的欄位名稱</param>
    /// <param name="valueFormat">radio的value格式用{}包住欄位,ex:{scode}</param>
    /// <param name="textFormat">radio的文字格式用{}包住欄位,ex:{scode}_{sc_name}</param>
    /// <param name="attrFormat">option的attribute格式用{}包住欄位,ex:value1='{scode1}'</param>
    /// <param name="brCount">每幾個換行,若為0則不換行</param>
    /// <returns></returns>
    public static string Radio(this DataTable dt, string objName, string valueFormat, string textFormat, string attrFormat, int brCount) {
        Regex rgx = new Regex("{([^{}]+)}", RegexOptions.IgnoreCase);
        string rtnStr = "";

        for (int r = 0; r < dt.Rows.Count; r++) {
            //處理value
            string val = valueFormat;
            foreach (Match match in rgx.Matches(valueFormat)) {
                val = val.Replace(match.Value, dt.Rows[r][match.Result("$1")].ToString());
            }

            //處理text
            string txt = textFormat;
            foreach (Match match in rgx.Matches(textFormat)) {
                txt = txt.Replace(match.Value, dt.Rows[r][match.Result("$1")].ToString());
            }

            //處理attribute
            string attr = attrFormat;
            foreach (Match match in rgx.Matches(attrFormat)) {
                attr = attr.Replace(match.Value, dt.Rows[r][match.Result("$1")].ToString());
            }

            //處理換行
            string br = "";
            if (brCount > 0) {
                if ((r + 1) % brCount == 0) {
                    br = "<BR>";
                }
            }

            rtnStr += string.Format("<label><input type='radio' id='{0}{1}' name='{0}' value='{1}' {3}>{2}</label>{4}\n", objName, val, txt, attr, br);
        }
        return rtnStr;
    }
    #endregion
}
