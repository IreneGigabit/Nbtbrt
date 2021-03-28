using System;
using System.Data;
using System.Data.SqlClient;
using System.Collections.Generic;
using System.Linq;
using System.Web;

public partial class Sys
{
    #region GetCaseDmt1 交辦明細檔
    public static DataTable GetCaseDmt1(DBHelper conn, string in_no) {
        string where = " and d.in_no ='" + in_no + "' ";
        DataTable dt = CaseDmt1(conn, where);

        return dt;
    }

    public static DataTable CaseDmt1(DBHelper conn, string where) {
        object objResult = null;
        DataTable dt = new DataTable();
        string SQL = "";

        SQL = "Select d.*,t.s_mark,''s_marknm from case_dmt1 d ";
        SQL += "left join dmt_temp t on d.in_no=t.in_no and d.case_sqlno=t.case_sqlno ";
        SQL += "where 1=1 ";
        SQL += where;
        conn.DataTable(SQL, dt);

        for (int i = 0; i < dt.Rows.Count; i++) {
            if (dt.Rows[i].SafeRead("s_mark", "") == "S") {
                dt.Rows[i]["s_marknm"] = "服務";
            } else if (dt.Rows[i].SafeRead("s_mark", "") == "L") {
                dt.Rows[i]["s_marknm"] = "證明";
            } else if (dt.Rows[i].SafeRead("s_mark", "") == "M") {
                dt.Rows[i]["s_marknm"] = "團體標章";
            } else if (dt.Rows[i].SafeRead("s_mark", "") == "N") {
                dt.Rows[i]["s_marknm"] = "團體商標";
            } else if (dt.Rows[i].SafeRead("s_mark", "") == "K") {
                dt.Rows[i]["s_marknm"] = "產地證明標章";
            } else {
                dt.Rows[i]["s_marknm"] = "商標";
            }
        }

        return dt;
    }
    #endregion
}
