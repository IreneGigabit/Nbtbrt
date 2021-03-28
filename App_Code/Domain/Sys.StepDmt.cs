using System;
using System.Data;
using System.Data.SqlClient;
using System.Collections.Generic;
using System.Linq;
using System.Web;

public partial class Sys
{
    #region GetStepDmt 進度檔
    public static DataTable GetStepDmt(DBHelper conn, string seq, string seq1) {
        DataTable dt = StepDmt(conn, seq, seq1, "");
        return dt;
    }

    public static DataTable GetStepDmt(DBHelper conn, string seq, string seq1, string case_no) {
        DataTable dt = StepDmt(conn, seq, seq1, "and case_no='" + case_no + "'");
        return dt;
    }

    public static DataTable StepDmt(DBHelper conn, string seq, string seq1, string where) {
        object objResult = null;
        DataTable dt = new DataTable();
        string SQL = "";

        SQL = "select * ";
        SQL += "from step_dmt where 1=1 ";
        if (seq != "") SQL += "and seq='" + seq + "'";
        if (seq1 != "") SQL += "and seq1='" + seq1 + "'";
        SQL += where;
        conn.DataTable(SQL, dt);

        for (int i = 0; i < dt.Rows.Count; i++) {
        }

        return dt;
    }
    #endregion
}
