using System;
using System.Data;
using System.Data.SqlClient;
using System.Collections.Generic;
using System.Linq;
using System.Web;

public partial class Sys
{
    #region GetDmtTemp 交辦暫存檔
    public static DataTable GetDmtTemp(DBHelper conn, string in_no) {
        string where = " and in_no ='" + in_no + "' ";
        DataTable dt = DmtTemp(conn, where);

        return dt;
    }

    //一案多件子案
    public static DataTable GetDmtTemp(DBHelper conn, string in_no, bool sub_flag) {
        string where = " and in_no ='" + in_no + "' ";
        if(sub_flag) where += " and case_sqlno<>0 ";
        DataTable dt = DmtTemp(conn, where);

        return dt;
    }

    public static DataTable DmtTemp(DBHelper conn, string where) {
        object objResult = null;
        DataTable dt = new DataTable();
        string SQL = "";

        SQL = "Select *,''s_marknm from dmt_temp where 1=1 " + where + " order by case_sqlno";
        conn.DataTable(SQL, dt);
        for (int i = 0; i < dt.Rows.Count; i++) {
            DataRow dr = dt.Rows[i];
            if (dr.SafeRead("s_mark", "") == "S") {
                dr["s_marknm"] = "服務";
            } else if (dr.SafeRead("s_mark", "") == "L") {
                dr["s_marknm"] = "證明";
            } else if (dr.SafeRead("s_mark", "") == "M") {
                dr["s_marknm"] = "團體標章";
            } else if (dr.SafeRead("s_mark", "") == "N") {
                dr["s_marknm"] = "團體商標";
            } else if (dr.SafeRead("s_mark", "") == "K") {
                dr["s_marknm"] = "產地證明標章";
            } else {
                dr["s_marknm"] = "商標";
            }
        }
        return dt;
    }
    #endregion
}
