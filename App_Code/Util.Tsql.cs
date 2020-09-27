using System;
using System.Collections.Generic;
using System.Web;

public static partial class Util
{
    #region 串接insert語法
    /// <summary>
    /// 串接insert語法
    /// </summary>
    public static string GetInsertSQL(string TableName, List<DBColumn> DBColumn) {
        string strCol = "", strValue = "";
        foreach (DBColumn col in DBColumn) {
            string value = HttpContext.Current.Request[col.RequestName];
            //有資料,或有給值
            if ((value != null && value != "") || (col.EmptyValue != null && col.EmptyValue != "") || col.ColType == ColType.Value) {
                //HttpContext.Current.Response.Write("**" + col.RequestName + "<BR>");
                if (DBColumn.IndexOf(col) != 0) {
                    strCol += ", ";//欄位
                    strValue += ", ";//資料
                }

                //串接欄位
                strCol += col.DBColName;

                //串接資料
                if (value == null && (col.EmptyValue != null && col.EmptyValue != "")) {
                    //沒有submit欄位但有指定空值
                    strValue += col.EmptyValue;
                }
                else {
                    switch (col.ColType) {
                        case ColType.Str:
                            strValue += "'" + value.Replace("'", "''") + "'";
                            break;
                        case ColType.PStr:
                        case ColType.Date:
                            if (value == null || value == "")
                                strValue += "null";
                            else
                                strValue += "'" + value.Replace("'", "''") + "'";
                            break;
                        case ColType.Number:
                            //HttpContext.Current.Response.Write(col.DBColName + "," + value + "<BR>");
                            if (value == null || value == "")
                                strValue += "null";
                            else
                                strValue += "" + value.Replace("'", "''") + "";
                            break;
                        case ColType.Value:
                            strValue += col.RequestName.Replace("'", "''");
                            break;
                        default:
                            strValue += "'" + value.Replace("'", "''") + "'";
                            break;
                    }
                }
            }
        }

        return string.Format("insert into {0}({1})values({2})", TableName, strCol, strValue);
    }
    #endregion
}


public class DBColumn
{
    public string DBColName { get; set; }
    public string RequestName { get; set; }
    public ColType ColType { get; set; }
    public string EmptyValue { get; set; }

    /// <summary>
    /// 無指定型態則為ColType.PStr
    /// </summary>
    /// <param name="dbColumnName">資料庫欄位名稱</param>
    /// <param name="requestName">畫面欄位名稱</param>
    public DBColumn(string dbColumnName, string requestName) {
        this.DBColName = dbColumnName;
        this.RequestName = requestName;
        this.ColType = ColType.PStr;
    }

    /// <param name="dbColumnName">資料庫欄位名稱</param>
    /// <param name="requestName">畫面欄位名稱/指定值</param>
    /// <param name="dbColumnType">指定欄位型態</param>
    public DBColumn(string dbColumnName, string requestName, ColType dbColumnType) {
        this.DBColName = dbColumnName;
        this.RequestName = requestName;
        this.ColType = dbColumnType;
    }

    /// <param name="dbColumnName">資料庫欄位名稱</param>
    /// <param name="requestName">畫面欄位名稱/指定值</param>
    /// <param name="dbColumnType">指定欄位型態</param>
    /// <param name="emptyValue">無request欄位時寫入指定值</param>
    public DBColumn(string dbColumnName, string requestName, ColType dbColumnType,string emptyValue) {
        this.DBColName = dbColumnName;
        this.RequestName = requestName;
        this.ColType = dbColumnType;
        this.EmptyValue = emptyValue;
    }
}

public enum ColType
{
    /// <summary>
    /// 無值時寫入null
    /// </summary>
    PStr,
    /// <summary>
    /// 無值時寫入''
    /// </summary>
    Str,
    /// <summary>
    /// 無值時寫入null
    /// </summary>
    Date,
    /// <summary>
    /// 無值時寫入null
    /// </summary>
    Number,
    /// <summary>
    /// 不使用畫面欄位,直接指定入值
    /// </summary>
    Value
}