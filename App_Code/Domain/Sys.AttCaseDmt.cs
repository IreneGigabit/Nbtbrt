using System;
using System.Data;
using System.Data.SqlClient;
using System.Collections.Generic;
using System.Linq;
using System.Web;

public partial class Sys
{
    #region GetAttCaseDmt 交辦發文檔
    public static DataTable GetAttCaseDmt(DBHelper conn, string att_sqlno, string in_no) {
        object objResult = null;
        DataTable dt = new DataTable();
        string SQL = "";

        SQL = "select *,''rs_class_name,''rs_code_name,''act_code_name,''ncase_stat,''ncase_statnm,''rs_agt_nonm,''markb ";
        SQL += "from attcase_dmt where 1=1 ";
        if (att_sqlno != "") SQL += "and in_no='" + att_sqlno + "'";
        if (in_no != "") SQL += "and in_no='" + in_no + "'";
        conn.DataTable(SQL, dt);

        for (int i = 0; i < dt.Rows.Count; i++) {
            //取得結構分類、代碼、處理事項名稱
            SQL = "select code_name from cust_code where code_type='" + dt.Rows[i]["rs_type"] + "' and cust_code='" + dt.Rows[i]["rs_class"] + "'";
            objResult = conn.ExecuteScalar(SQL);
            dt.Rows[i]["rs_class_name"] = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();

            SQL = "select rs_detail from code_br where rs_type='" + dt.Rows[i]["rs_type"] + "' and rs_code='" + dt.Rows[i]["rs_code"] + "' and gs='Y' ";
            dt.Rows[i]["rs_class_name"] = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();

            SQL = "select code_name from cust_code where code_type='tact_code' and cust_code='" + dt.Rows[i]["act_code"] + "'";
            dt.Rows[i]["act_code_name"] = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();

            //取得案件狀態
            SQL = "select a.cust_code,a.code_name from cust_code a inner join vcode_act b on a.cust_code = b.case_stat ";
            SQL += " where a.code_type='tcase_stat'";
            SQL += "   and b.dept='" + Sys.GetSession("dept") + "' and b.cg='G' and b.rs='S'";
            SQL += "   and b.rs_class='" + dt.Rows[i]["rs_class"] + "'";
            SQL += "   and b.rs_code='" + dt.Rows[i]["rs_code"] + "'";
            SQL += "   and b.act_code='" + dt.Rows[i]["act_code"] + "'";
            using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
                if (dr.Read()) {
                    dt.Rows[i]["ncase_stat"] = dr.SafeRead("cust_code", "");
                    dt.Rows[i]["ncase_statnm"] = dr.SafeRead("code_name", "");
                }
            }

            //取得發文出名代理人
            SQL = "select treceipt,agt_name from agt where agt_no='" + dt.Rows[i]["rs_agt_no"] + "'";
            using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
                if (dr.Read()) {
                    dt.Rows[i]["rs_agt_nonm"] = dr.SafeRead("treceipt", "") + "_" + dr.SafeRead("agt_name", "");
                }
            }

            //取得案性mark
            SQL = "select mark from code_br where dept='T' and rs_type='" + dt.Rows[i]["rs_type"] + "' and rs_class='" + dt.Rows[i]["rs_class"] + "' and rs_code='" + dt.Rows[i]["rs_code"] + "' and gs='Y'";
            dt.Rows[i]["markb"] = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();
        }

        return dt;
    }
    #endregion


}
