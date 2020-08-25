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
}