using System;
using System.Data;
using System.Data.SqlClient;
using System.Collections.Generic;
using System.Linq;
using System.Web;

public partial class Sys
{
    #region GetDmt 案件主檔
    public static DataTable GetDmt(DBHelper conn, string seq, string seq1) {
        object objResult = null;
        DataTable dt = new DataTable();
        string SQL = "";
        SQL = "Select *,''scodenm,''s_marknm,''cust_name,'否'con_termnm,''ap_apcust_no,''dmtap_cname ";
        SQL += ",''arcasenm,''now_arcasenm,''now_rsclass,''now_statnm ";
        SQL += ",''rmarkcode,''rmark_codenm,''end_codenm ";
        SQL += "from dmt where seq='" + seq + "' and seq1='" + seq1 + "'";
        conn.DataTable(SQL, dt);

        for (int i = 0; i < dt.Rows.Count; i++) {
            DataRow dr = dt.Rows[i];

            //商標種類
            switch (dr.SafeRead("s_mark", "").Trim()) {
                case "S": dr["s_marknm"] = "服務"; break;
                case "L": dr["s_marknm"] = "證明"; break;
                case "M": dr["s_marknm"] = "團體標章"; break;
                case "N": dr["s_marknm"] = "團體商標"; break;
                case "K": dr["s_marknm"] = "產地證明標章"; break;
                default: dr["s_marknm"] = "商標"; break;
            }

            //營洽
            SQL = "select sc_name from sysctrl.dbo.scode where scode='" + dr["scode"] + "'";
            objResult = conn.ExecuteScalar(SQL);
            string sc_name = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();
            dr["scodenm"] = sc_name;

            //客戶
            SQL = "select b.ap_cname1,b.ap_cname2,a.con_term ";
            SQL += "from custz a inner join apcust b on a.cust_seq=b.cust_seq and a.cust_area = b.cust_area ";
            SQL += "where a.cust_area='" + dr["cust_area"] + "' and a.cust_seq='" + dr["cust_seq"] + "' ";
            using (SqlDataReader sdr = conn.ExecuteReader(SQL)) {
                if (sdr.Read()) {
                    dr["cust_name"] = sdr.SafeRead("ap_cname1", "").Trim() + sdr.SafeRead("ap_cname2", "").Trim();
                    if (sdr.SafeRead("con_term", "").Trim() != "") dr["con_termnm"] = "是";
                }
            }

            //申請人
            SQL = "select apcust_no from apcust where apsqlno='" + dr["apsqlno"] + "'";
            objResult = conn.ExecuteScalar(SQL);
            string apcust_no = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();
            dr["ap_apcust_no"] = apcust_no;
            SQL = "select apcust_no,ap_cname from dmt_ap where seq='" + seq + "' and seq1='" + seq1 + "'";
            using (SqlDataReader sdr = conn.ExecuteReader(SQL)) {
                int ap = 0;
                string dmtap_cname = "";
                while (sdr.Read()) {
                    ap++;
                    dmtap_cname += (dmtap_cname != "" ? " " : "") + ap + "." + sdr["apcust_no"] + sdr["ap_cname"];
                }
                dr["dmtap_cname"] = dmtap_cname;
            }

            //立案案性
            dr["arcasenm"] = getRsDetail(conn, "cr", dr.SafeRead("arcase_type", ""), dr.SafeRead("arcase", ""));

            //目前案性/狀態
            string lf = "cr";
            SQL = "select cg,rs from step_dmt where seq='" + seq + "' and seq1='" + seq1 + "' ";
            SQL += " and step_grade = '" + dr["now_grade"]+"'";
            using (SqlDataReader sdr = conn.ExecuteReader(SQL)) {
                if (sdr.Read()) {
                    lf = "" + sdr["cg"] + sdr["rs"];
                    if (lf.ToUpper() == "ZS") lf = "cr";
                }
            }
            SQL = "select rs_class,rs_detail from code_br where " + lf + "='Y' and dept='" + Sys.GetSession("dept") + "' ";
            SQL += " and rs_type = '" + dr["now_arcase_type"] + "' and rs_code='" + dr["now_arcase"] + "'";
            using (SqlDataReader sdr = conn.ExecuteReader(SQL)) {
                if (sdr.Read()) {
                    dr["now_arcasenm"] = sdr.SafeRead("rs_detail", "");
                    dr["now_rsclass"] = sdr.SafeRead("rs_class", "");
                }
            }
            dr["now_statnm"] = getCodeName(conn, "TCase_Stat", dr.SafeRead("now_stat", ""));

            //債信
            SQL = "select rmark_code from custz where cust_area='" + dr["cust_area"] + "' and cust_seq='" + dr["cust_seq"] + "'";
            objResult = conn.ExecuteScalar(SQL);
            string rmark_code = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();
            dr["rmarkcode"] = rmark_code;
            dr["rmark_codenm"] = getCodeName(conn, "rmark_code", rmark_code);

            //結案代碼
            dr["end_codenm"] = getCodeName(conn, "ENDCODE", dr.SafeRead("end_code", ""));
        }
        return dt;
    }
    #endregion
}
