using System;
using System.Data;
using System.Data.SqlClient;
using System.Collections.Generic;
using System.Linq;
using System.Web;

public partial class Sys
{
    #region AttCaseDmt 交辦發文檔
    public static DataTable GetVCustlist(DBHelper conn, string apcust_no, string cust_area, string cust_seq) {
        object objResult = null;
        DataTable dt = new DataTable();
        string SQL = "";

        SQL = "select *,''apclassnm,''ap_countrynm,''con_codenm,''rmark_codenm,''ref_seqnm,''magnm ";
        SQL += ",''pdis_typenm,''ppay_typenm,''tdis_typenm,''tpay_typenm ";
        SQL += "from vcustlist where 1=1 ";
        if (apcust_no != "") SQL += " and apcust_no='" + apcust_no + "'";
        if (cust_area != "") SQL += " and cust_area='" + cust_area + "'";
        if (cust_seq != "") SQL += " and cust_seq='" + cust_seq + "'";
        conn.DataTable(SQL, dt);

        for (int i = 0; i < dt.Rows.Count; i++) {
            switch (dt.Rows[i].SafeRead("apclass", "").Trim()) {
                case "AA": dt.Rows[i]["apclassnm"] = "本國公司機關無統編者"; break;
                case "AB": dt.Rows[i]["apclassnm"] = "公司與機關團體(大企業)"; break;
                case "AC": dt.Rows[i]["apclassnm"] = "公司與機關團體(小企業)"; break;
                case "B": dt.Rows[i]["apclassnm"] = "本國人(身份證)"; break;
                case "CA": dt.Rows[i]["apclassnm"] = "外國人(自動流水號)"; break;
                case "CB": dt.Rows[i]["apclassnm"] = "外國人(智慧財產局編碼)"; break;
                case "CT": dt.Rows[i]["apclassnm"] = "外國人(國外所申請人號)"; break;
            }

            SQL = "select coun_code,coun_c from country where coun_code='" + dt.Rows[i].SafeRead("ap_country", "") + "' and markb<>'X' order by coun_code ";
            using (DBHelper cnn = new DBHelper(Conn.Sysctrl).Debug(false)) {
                using (SqlDataReader dr = cnn.ExecuteReader(SQL)) {
                    if (dr.Read()) {
                        dt.Rows[i]["ap_countrynm"] = dr.SafeRead("coun_c", "").Trim();
                    }
                }
            }

            SQL = "select cust_code,code_name from cust_code where code_type='H' and cust_code='" + dt.Rows[i].SafeRead("con_code", "") + "' ";
            using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
                if (dr.Read()) {
                    dt.Rows[i]["con_codenm"] = dr.SafeRead("coun_c", "").Trim();
                }
            }

            switch (dt.Rows[i].SafeRead("rmark_code", "").Trim()) {
                case "E13": dt.Rows[i]["rmark_codenm"] = "撤案未付"; break;
                case "E20": dt.Rows[i]["rmark_codenm"] = "無力給付"; break;
                case "E21": dt.Rows[i]["rmark_codenm"] = "賴帳拒付"; break;
                case "E22": dt.Rows[i]["rmark_codenm"] = "倒閉"; break;
                case "E23": dt.Rows[i]["rmark_codenm"] = "無法聯絡"; break;
                case "Z90": dt.Rows[i]["rmark_codenm"] = "其他"; break;
            }

            if (dt.Rows[i].SafeRead("ref_seq", "").Trim() != "" && dt.Rows[i].SafeRead("ref_seq", "").Trim() != "0") {
                SQL = "select ap_cname1,ap_cname2 from apcust where cust_seq='" + dt.Rows[i].SafeRead("ref_seq", "") + "' ";
                using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
                    if (dr.Read()) {
                        dt.Rows[i]["ref_seqnm"] = dr.SafeRead("ap_cname1", "").Trim() + dr.SafeRead("ap_cname2", "").Trim();
                    }
                }
            }

            if (dt.Rows[i].SafeRead("mag", "").Trim() == "Y")
                dt.Rows[i]["magnm"] = "需要";
            else
                dt.Rows[i]["magnm"] = "不需要";

            SQL = "select code_name from cust_code where code_type='B' and cust_code='" + dt.Rows[i].SafeRead("pdis_type", "").Trim() + "'";
            objResult = conn.ExecuteScalar(SQL);
            dt.Rows[i]["pdis_typenm"] = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();

            SQL = "select code_name from cust_code where code_type='C' and cust_code='" + dt.Rows[i].SafeRead("ppay_type", "").Trim() + "'";
            objResult = conn.ExecuteScalar(SQL);
            dt.Rows[i]["ppay_typenm"] = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();

            SQL = "select code_name from cust_code where code_type='B' and cust_code='" + dt.Rows[i].SafeRead("tdis_type", "").Trim() + "'";
            objResult = conn.ExecuteScalar(SQL);
            dt.Rows[i]["tdis_typenm"] = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();

            SQL = "select code_name from cust_code where code_type='C' and cust_code='" + dt.Rows[i].SafeRead("tpay_type", "").Trim() + "'";
            objResult = conn.ExecuteScalar(SQL);
            dt.Rows[i]["tpay_typenm"] = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();

        }
        return dt;
    }
    #endregion
}
