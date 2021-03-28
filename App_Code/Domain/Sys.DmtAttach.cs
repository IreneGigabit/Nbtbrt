using System;
using System.Data;
using System.Data.SqlClient;
using System.Collections.Generic;
using System.Linq;
using System.Web;

public partial class Sys
{
    #region GetDmtAttach 附件檔
    public static DataTable GetDmtAttach(DBHelper conn, string in_no) {
        string where = "";
        where += " and source='case' ";
        where += " and in_no ='" + in_no + "' ";
        DataTable dt = DmtAttach(conn, where);
        return dt;
    }

    public static DataTable GetDmtAttach(DBHelper conn, string seq, string seq1, string source, string where) {
        string pwhere = "";
        pwhere += " and seq ='" + seq + "' ";
        pwhere += " and seq1 ='" + seq1 + "' ";
        pwhere += " and source ='" + source + "' ";
        pwhere += where;

        //if step_grade<>empty then
        //    sql = sql & " and step_grade=" & step_grade
        //end if
        //if attach_sqlno <> empty then
        //    sql = sql & " and attach_sqlno=" & attach_sqlno
        //end if
        //if att_sqlno<>empty then
        //    sql = sql & " and att_sqlno=" & att_sqlno
        //end if

        DataTable dt = DmtAttach(conn, pwhere);
        return dt;
    }

    public static DataTable DmtAttach(DBHelper conn, string where) {
        object objResult = null;
        DataTable dt = new DataTable();
        string SQL = "";

        SQL = "select *,'' as old_branch ";
        SQL += ",(select mark1 from cust_code where code_type='Tdoc' and cust_code=dmt_attach.doc_type) as doc_type_mark ";
        SQL += "from dmt_attach where attach_flag<>'D' ";
        SQL += where;
        SQL += " order by attach_sqlno ";
        conn.DataTable(SQL, dt);

        for (int i = 0; i < dt.Rows.Count; i++) {
            DataRow dr = dt.Rows[i];
            dr["attach_path"] = Sys.Path2Nbtbrt(dr.SafeRead("attach_path", ""));
        }

        return dt;
    }
    #endregion
}
