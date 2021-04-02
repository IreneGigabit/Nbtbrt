using System;
using System.Data;
using System.Data.SqlClient;
using System.Collections.Generic;
using System.Linq;
using System.Web;

public partial class Sys
{
    #region GetVDmtall 案件主檔基本資料
    public static DataTable GetVDmtall(DBHelper conn, string seq, string seq1) {
        object objResult = null;
        DataTable dt = new DataTable();
        string SQL = "";

        SQL = "select * from vdmtall where 1=1 ";
        if (seq != "") SQL += " and seq='" + seq + "'";
        if (seq1 != "") SQL += " and seq1='" + seq1 + "'";
        conn.DataTable(SQL, dt);

        for (int i = 0; i < dt.Rows.Count; i++) {
            DataRow dr = dt.Rows[i];
            if (dr.SafeRead("s_mark", "").Trim() == "") {
                dr["s_mark"] = "_";
            }

            //2008/11/26證明標章與團體標章，類別數=1
            if (dr.SafeRead("s_mark", "") == "L" || dr.SafeRead("s_mark", "") == "M") {
                dr["class_count"] = "1";
            }
        }
        return dt;
    }
    #endregion
}
