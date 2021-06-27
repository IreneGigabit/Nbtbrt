using System;
using System.Collections.Generic;
using System.Web;
using System.Data;

/// <summary>
/// 查詢分頁
/// </summary>
public class Paging
{
    /// <summary>
    /// 執行SQL
    /// </summary>
    public string exeSQL { get; set; }

    /// <summary>
    /// 第幾頁
    /// </summary>
    public int nowPage { get; set; }

    /// <summary>
    /// 每頁筆數
    /// </summary>
    public int perPage { get; set; }

    /// <summary>
    /// 總筆數
    /// </summary>
    public int totRow { get; set; }

    /// <summary>
    /// 總頁數
    /// </summary>
    public int totPage { get; set; }

    public DataTable pagedTable { get; set; }

    public Paging(int GoPage, int PerPage) {
        nowPage = GoPage;
        perPage = PerPage;
        exeSQL = "";
    }

    public Paging(int GoPage, int PerPage,string ExeSQL) {
        nowPage = GoPage;
        perPage = PerPage;
        exeSQL = ExeSQL;
    }

    /// <summary>
    /// 取得分頁後的DataTable(使用T-SQL)
    /// </summary>
    public void GetPagedTable(DBHelper conn, string mainSQL) {
        /*如果筆數太大就要用sql分頁,語法:
        SELECT TOP 每頁筆數 * FROM (
            SELECT ROW_NUMBER() OVER (ORDER BY id) AS RowNumber,* FROM table1
        ) as A WHERE RowNumber > 每頁筆數*(第幾頁-1) 
        */
        //先算總筆數
        string SQL = "SELECT COUNT(*) AS cnt FROM ("+mainSQL+") as xx";
        object objResult = conn.ExecuteScalar(SQL);
        totRow = (objResult == DBNull.Value || objResult == null) ? 0 : Convert.ToInt32(objResult);

        totPage = Convert.ToInt32(Math.Ceiling((double)totRow / (double)perPage));//總頁數
        nowPage = Math.Min(nowPage, (int)totPage);
        
        //抓取分頁後資料
        string strFormat = " SELECT TOP {0} * ";
        strFormat += "FROM (  {2}  ) as xx ";
        strFormat += "WHERE RowNumber > {0}*({1}-1)  ";

        SQL = string.Format(strFormat, perPage, nowPage, mainSQL);
        exeSQL = SQL;
        
        pagedTable = new DataTable();
        conn.DataTable(SQL, pagedTable);
    }

    public void GetPagedTable(DataTable dataTable) {
        totRow = dataTable.Rows.Count;//總筆數
        totPage = Convert.ToInt32(Math.Ceiling((double)totRow / (double)perPage));//總頁數
        nowPage = Math.Min(nowPage, (int)totPage);

        DataTable newdt = dataTable.Copy();
        newdt.Clear();//copy dt的框架

        int rowbegin = (nowPage - 1) * perPage;
        int rowend = nowPage * perPage;
        //if (rowend > dataTable.Rows.Count) rowend = dataTable.Rows.Count;
        rowend = Math.Min(rowend, dataTable.Rows.Count);

        if (totRow == 0) {
            pagedTable = dataTable;
        }
        else {
            for (int i = rowbegin; i <= rowend - 1; i++) {
                DataRow newdr = newdt.NewRow();
                DataRow dr = dataTable.Rows[i];
                foreach (DataColumn column in dataTable.Columns) {
                    newdr[column.ColumnName] = dr[column.ColumnName];
                }
                newdt.Rows.Add(newdr);
            }
            pagedTable = newdt;
        }
    }

    /// <summary>
    /// 頁數清單
    /// </summary>
    public string GetPageList() {
        string rtn = "";
        for (int i = 1; i <= totPage; i++) {
            rtn += "<option value=\"" + i + "\" " + (nowPage == i ? "selected" : "") + ">" + i + "</option>\n";
        }
        return rtn;
    }

    /// <summary>
    /// 分頁submit隱藏欄位
    /// </summary>
    public string GetHiddenText(string exclud) {
        string rtn = "";
        string[] excludArray = exclud.Split(',');
        
        Dictionary<string, string> ReqVal = Util.GetRequestParam(HttpContext.Current);
        foreach (KeyValuePair<string, string> p in ReqVal) {
            var pos = Array.FindIndex(excludArray
                , x => string.Equals(x, p.Key, StringComparison.InvariantCultureIgnoreCase));
            if (pos == -1) {
                //rtn += string.Format(p.Key + ":<input type=\"text\" id=\"{0}\" name=\"{0}\" value=\"{1}\">\n", p.Key, p.Value);
                rtn += string.Format("<input type=\"hidden\" id=\"{0}\" name=\"{0}\" value=\"{1}\">\n", p.Key, p.Value);
            }
        }
        return rtn;
    }
}