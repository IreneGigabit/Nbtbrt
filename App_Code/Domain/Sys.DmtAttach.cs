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

        SQL = "select *,'' as old_branch,''view_path,''scan_flag,'Y' file_flag,''file_flagnm ";
        SQL += ",(select mark1 from cust_code where code_type='Tdoc' and cust_code=dmt_attach.doc_type) as doc_type_mark ";
        SQL += "from dmt_attach where attach_flag<>'D' ";
        SQL += where;
        SQL += " order by attach_sqlno ";
        conn.DataTable(SQL, dt);

        for (int i = 0; i < dt.Rows.Count; i++) {
            DataRow dr = dt.Rows[i];

            string viewserver = "http://" + Sys.Host;
            string attach_path = Sys.Path2Nbtbrt(dr.SafeRead("attach_path", ""));

            if (dr.SafeRead("source", "") == "scan") {//掃描
                dr["scan_flag"] = "Y";//尚未掃描
                if (Sys.CheckFile(attach_path) == false) {
                    dr["file_flag"] = "N";//檔案不存在
                    dr["scan_flag"] = "N";
                    dr["file_flagnm"] = "(尚未掃描)";
                }
            } else if (dr.SafeRead("source", "").ToUpper().IN("EGR,GR,EGS")) {//電子公文/電子收據
                //若區所主機找不到就找總所主機
                if (Sys.CheckFile(attach_path) == false) {
                    dr["file_flag"] = "N";//檔案不存在
                    viewserver = "http://" + Sys.MG_IIS;
                    attach_path = Sys.Path2MG(attach_path);
                }
            } else if (dr.SafeRead("source", "").ToUpper()=="OPT") {//爭救案上傳
                viewserver = "http://" + Sys.Opt_IIS;
                attach_path = attach_path.Replace(@"\opt\", @"\nopt\");
            }

            dr["attach_path"] = attach_path;
            dr["view_path"] = viewserver + attach_path;

        }

        return dt;
    }
    #endregion
}
