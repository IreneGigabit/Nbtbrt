using System;
using System.Data;
using System.Data.SqlClient;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

/// <summary>  
/// </summary>  
public partial class Sys
{
    #region show_edb_file - 顯示英文invoice
    /// <summary>  
    /// 顯示英文invoice
    /// <param name="ar_no">請款單號</param>
    /// </summary>  
    public static string show_edb_file(DBHelper conn, string ar_no) {
        Sys sfile = new Sys();

        string rtn = "";
        string SQL = "select edb_file from artmain where ar_no='" + ar_no.Trim() + "' and edb_file is not null and edb_file<>'' ";
        string edb_file = conn.getString(SQL);

        if (edb_file != "") {
            rtn = "<IMG border=0 src=\"" + System.Web.VirtualPathUtility.ToAbsolute("~/images/annex.gif") + "\" onclick=\"window.open('" + sfile.gbrDbDir + "/" + edb_file + "')\" style='cursor:pointer'>";
        }
        return rtn;
    }
    #endregion

    #region show_edb_fileW - 顯示英文invoice Word原稿
    /// <summary>  
    /// 顯示英文invoice
    /// <param name="ar_no">請款單號</param>
    /// </summary>  
    public static string show_edb_fileW(DBHelper conn, string ar_no) {
        Sys sfile = new Sys();

        string rtn = "";
        string SQL = "select edb_fileW from artmain_e where ar_no='" + ar_no.Trim() + "' and edb_fileW is not null and edb_fileW<>'' ";
        string edb_fileW = conn.getString(SQL);

        if (edb_fileW != "") {
            rtn = "<IMG border=0 src=\"" + System.Web.VirtualPathUtility.ToAbsolute("~/images/annex.gif") + "\" onclick=\"window.open('" + sfile.gbrDbDir + "/" + edb_fileW + "')\" style='cursor:pointer'>";
        }
        return rtn;
    }
    #endregion
}
