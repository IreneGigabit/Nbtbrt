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
public static class SHtml
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

	/// <summary>
	/// 產生Option字串
	/// </summary> 
	/// <param name="conn">DBHelper物件</param>
	/// <param name="sql">SQL語法</param>
	/// <param name="valueFormat">option的value格式用{}包住欄位,ex:{scode}</param>
	/// <param name="textFormat">option的文字格式用{}包住欄位,ex:{scode}_{sc_name}</param>
	/// <param name="showEmpty">空白選項的顯示字串</param>
	/// <returns></returns>
	public static string Option(DBHelper conn, string sql, string valueFormat, string textFormat, bool showEmpty) {
		return Option(conn, sql, valueFormat, textFormat, "", showEmpty);
	}

	/// <summary>
	/// 產生Option字串
	/// </summary> 
	/// <param name="conn">DBHelper物件</param>
	/// <param name="sql">SQL語法</param>
	/// <param name="valueFormat">option的value格式用{}包住欄位,ex:{scode}</param>
	/// <param name="textFormat">option的文字格式用{}包住欄位,ex:{scode}_{sc_name}</param>
	/// <param name="attrFormat">option的attribute格式用{}包住欄位,ex:value1='{scode1}'</param>
	/// <param name="showEmpty">空白選項的顯示字串</param>
	/// <returns></returns>
	public static string Option(DBHelper conn, string sql, string valueFormat, string textFormat, string attrFormat, bool showEmpty) {
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
				rtnStr += "<option value='" + val + "' " + attr + ">" + txt + "</option>\n";
			}
		}
		return rtnStr;
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

	/// <summary>
	/// 產生Option字串
	/// </summary> 
	/// <param name="valueFormat">option的value格式用{}包住欄位,ex:{scode}</param>
	/// <param name="textFormat">option的文字格式用{}包住欄位,ex:{scode}_{sc_name}</param>
	/// <param name="attrFormat">option的attribute格式用{}包住欄位,ex:value1='{scode1}'</param>
	/// <param name="showEmpty">空白選項的顯示字串</param>
	/// <returns></returns>
	public static string Option(this DataTable dt, string valueFormat, string textFormat, string attrFormat, bool showEmpty) {
		Regex rgx = new Regex("{([^{}]+)}", RegexOptions.IgnoreCase);
		string rtnStr = "";

		//處理空白選項
		if (showEmpty)
			rtnStr += "<option value='' style='color:blue' selected>請選擇</option>\n";

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

			rtnStr += string.Format("<label><input type='radio' id='{0}{1}' name='{0}' value='{1}' {3}>{2}</label>\n", objName, val, txt, attr);
		}
		return rtnStr;
	}
	#endregion
}
