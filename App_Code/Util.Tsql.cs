using System;
using System.Collections.Generic;
using System.Web;

public static partial class Util
{
    #region 串接insert語法
    /// <summary>
    /// 串接insert語法
    /// </summary>
    public static string GetInsertSQL(List<DBColumn> DBColumn) {
        string strCol = "", strValue = "";
        foreach (DBColumn col in DBColumn) {
            string value = HttpContext.Current.Request[col.RequestName];
            //if ((value != null && value != "") || (col.EmptyValue != null && col.EmptyValue != "") || col.ColType == ColType.Value) {
            //if ((value != null && value != "") || (!col.IsNullNoSave)) {
            if ((value != null && value != "") || (col.IsNullValue != null && col.IsNullValue != "") || !col.IsNullNoSave || col.ColType == ColType.Value) {
                //HttpContext.Current.Response.Write("**" + col.RequestName + "<BR>");
                if (strCol != "") {
                    strCol += ", ";//欄位
                    strValue += ", ";//資料
                }

                //串接欄位
                strCol += col.DBColName;

                //串接資料
                strValue += ParseValue(col);
            }
        }

        return string.Format("({0})values({1})", strCol, strValue);
    }
    #endregion

    #region 串接update語法
    /// <summary>
    /// 串接update語法
    /// </summary>
    public static string GetUpdateSQL(List<DBColumn> DBColumn) {
        string strSet = "";
        foreach (DBColumn col in DBColumn) {
            string value = HttpContext.Current.Request[col.RequestName];
            //if ((value != null && value != "") || (col.EmptyValue != null && col.EmptyValue != "") || col.ColType == ColType.Value) {
            if ((value != null && value != "") || (col.IsNullValue != null && col.IsNullValue != "") || !col.IsNullNoSave || col.ColType == ColType.Value) {
                //HttpContext.Current.Response.Write("**" + col.RequestName + "<BR>");
                if (strSet != "") {
                    strSet += ", ";
                }

                //串接欄位
                strSet += col.DBColName;

                //串接資料
                strSet += "=" + ParseValue(col);
            }
        }

        return strSet;
    }
    #endregion

    #region 依ColType型態轉值
    /// <summary>
    /// 依ColType型態轉值
    /// </summary>
    private static string ParseValue(DBColumn col) {
        string strRtn = "";
        string value = HttpContext.Current.Request[col.RequestName];

        if ((value == null || value == "") && (col.IsNullValue != null && col.IsNullValue != "")) {
            //沒有值,但有指定預設值
            strRtn = col.IsNullValue.ToBig5().Trim();
        } else {
            value = (value ?? "").Replace("'", "''").ToBig5().Trim();
            switch (col.ColType) {
                case ColType.Str:
                    strRtn = "'" + value + "'";
                    break;
                case ColType.Null:
                    if (value == null || value == "")
                        strRtn = "null";
                    else
                        strRtn = "'" + value + "'";
                    break;
                case ColType.Zero:
                    if (value == null || value == "")
                        strRtn = "0";
                    else
                        strRtn = "" + value + "";
                    break;
                case ColType.Value:
                    strRtn = "" + col.RequestName.ToBig5().Trim();
                    break;
                default:
                    strRtn = "'" + value + "'";
                    break;
            }
        }
        return strRtn;
    }
    #endregion
}


public class DBColumn
{
    public string DBColName { get; set; }
    public string RequestName { get; set; }
    public ColType ColType { get; set; }
    public string IsNullValue { get; set; }
    public bool IsNullNoSave { get; set; }

    /// <summary>
    /// 無指定型態則為ColType.Null
    /// </summary>
    /// <param name="dbColumnName">資料庫欄位名稱</param>
    /// <param name="requestName">畫面欄位名稱</param>
    public DBColumn(string dbColumnName, string requestName) {
        this.DBColName = dbColumnName;
        this.RequestName = requestName;
        this.ColType = ColType.Null;
        this.IsNullNoSave = false;
    }

    /// <param name="dbColumnName">資料庫欄位名稱</param>
    /// <param name="requestName">畫面欄位名稱/指定值</param>
    /// <param name="isNullNoSave">無值時不產生update/insert語法</param>
    public DBColumn(string dbColumnName, string requestName, bool isNullNoSave) {
        this.DBColName = dbColumnName;
        this.RequestName = requestName;
        this.ColType = ColType.Null;
        this.IsNullNoSave = isNullNoSave;
    }

    /// <param name="dbColumnName">資料庫欄位名稱</param>
    /// <param name="requestName">畫面欄位名稱/指定值</param>
    /// <param name="dbColumnType">指定欄位型態</param>
    public DBColumn(string dbColumnName, string requestName, ColType dbColumnType) {
        this.DBColName = dbColumnName;
        this.RequestName = requestName;
        this.ColType = dbColumnType;
        this.IsNullNoSave = false;
    }

    /// <param name="dbColumnName">資料庫欄位名稱</param>
    /// <param name="requestName">畫面欄位名稱/指定值</param>
    /// <param name="dbColumnType">指定欄位型態</param>
    /// <param name="isNullValue">無值時寫入指定值</param>
    public DBColumn(string dbColumnName, string requestName, ColType dbColumnType,string isNullValue) {
        this.DBColName = dbColumnName;
        this.RequestName = requestName;
        this.ColType = dbColumnType;
        this.IsNullNoSave = false;
        this.IsNullValue = isNullValue;
    }

    /// <param name="dbColumnName">資料庫欄位名稱</param>
    /// <param name="requestName">畫面欄位名稱/指定值</param>
    /// <param name="dbColumnType">指定欄位型態</param>
    /// <param name="isNullNoSave">無值時不產生update/insert語法</param>
    public DBColumn(string dbColumnName, string requestName, ColType dbColumnType, bool isNullNoSave) {
        this.DBColName = dbColumnName;
        this.RequestName = requestName;
        this.ColType = dbColumnType;
        this.IsNullNoSave = isNullNoSave;
    }
}

public enum ColType
{
    /// <summary>
    /// 無值時寫入null
    /// </summary>
    Null,
    /// <summary>
    /// 無值時寫入''
    /// </summary>
    Str,
    /// <summary>
    /// 無值時寫入0
    /// </summary>
    Zero,
    /// <summary>
    /// 不使用畫面欄位,直接指定入值
    /// </summary>
    Value
}
