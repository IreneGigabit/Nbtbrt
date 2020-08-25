using System;
using System.Data;
using System.Data.SqlClient;
using System.Collections.Generic;
using System.Linq;

/// <summary>  
/// 原Server_code.vbs
/// </summary>  
public class Funcs {
    #region formatSeq - 組本所編號
    /// <summary>  
    /// 組本所編號
    /// </summary>  
    public static string formatSeq(string seq, string seq1, string country, string branch, string dept) {
        string lseq = branch + dept + "-" + seq;
        lseq += (seq1 != "_" && seq1 != "" ? ("-" + seq1) : "");
        lseq += (country != "" ? (" " + country.ToUpper()) : "");
        return lseq;
    }
    #endregion

    #region getScode - 抓取組主管所屬營洽
    /// <summary>  
    /// 抓取組主管所屬營洽
    /// <para>回傳ex：n428','ntest','n873','n1231','n1030','n1350</para>
    /// </summary>  
    public static string getScode(string branch, string scode) {
        using (DBHelper conn = new DBHelper(Conn.ODBCDSN, false)) {
            string SQL = "select a.grpid,a.scode,b.upgrpid From scode_group a ";
            SQL += "inner join grpid b on a.grpclass=b.grpclass and a.grpid=b.grpid ";
            SQL += "where a.grpclass='" + branch + "' ";
            SQL += "and b.master_scode='" + scode + "'";
            DataTable dt = new DataTable();
            conn.DataTable(SQL, dt);
            var list = dt.AsEnumerable().Select(r => r.Field<string>("scode")).ToArray();
            return "'" + string.Join("','", list) + "'";
        }
    }
    #endregion

    #region getRsType - 國內案目前交辦案性的版本
    /// <summary>  
    /// 國內案目前交辦案性的版本
    /// </summary>  
    public static string getRsType() {
        using (DBHelper conn = new DBHelper(Conn.btbrt, false)) {
            string SQL = "select cust_code from cust_code where code_type='trs_type' ";
            object objResult = conn.ExecuteScalar(SQL);
            return (objResult == DBNull.Value || objResult == null) ? "T92" : objResult.ToString();
        }
    }
    #endregion

    #region getExtRsType - 出口案目前交辦案性的版本
    /// <summary>  
    /// 出口案目前交辦案性的版本
    /// </summary>  
    public static string getExtRsType() {
        using (DBHelper conn = new DBHelper(Conn.btbrt, false)) {
            string SQL = "select cust_code from cust_code where code_type='ters_type'";
            object objResult = conn.ExecuteScalar(SQL);
            return (objResult == DBNull.Value || objResult == null) ? "TE95" : objResult.ToString();
        }
    }
    #endregion

    #region getCodeBr - 國內案交辦案性
    /// <summary>  
    /// 國內案交辦案性
    /// </summary>  
    public static DataTable getCodeBr(string rs_type, string rs_class, string submitTask) {
        using (DBHelper conn = new DBHelper(Conn.btbrt, false)) {
            string SQL = "SELECT rs_code,prt_code,rs_detail,remark FROM code_br ";
            SQL += "WHERE rs_class like '" + rs_class + "%' And  cr= 'Y' and dept='T' AND no_code='N' ";
            if (rs_type != "") {
                SQL += "And rs_type='" + rs_type + "' ";
            } else {
                SQL += "And rs_type='" + Funcs.getRsType() + "' ";
            }
            if (submitTask.ToUpper() == "A") {
                SQL += "and (end_date is null or end_date = '' or end_date > getdate()) ";
            }
            SQL += "ORDER BY rs_code";
            DataTable dt = new DataTable();
            conn.DataTable(SQL, dt);

            return dt;
        }
    }
    #endregion

    #region getcountry - 國籍
    /// <summary>  
    /// 抓取國籍
    /// </summary>  
    public static DataTable getcountry() {
        using (DBHelper cnn = new DBHelper(Conn.Sysctrl, false)) {
            string SQL = "select coun_code,coun_c from country where markb<>'X' or markb is null order by coun_code";
            DataTable dt = new DataTable();
			cnn.DataTable(SQL, dt);

            return dt;
        }
    }
    #endregion

    #region getcust_code_mul - 抓取cust_code
    /// <summary>  
    /// 抓取抓取區所cust_code
    /// </summary>  
    public static DataTable getcust_code_mul(string code_type, string pwh2, string sortField) {
        using (DBHelper connB = new DBHelper(Conn.btbrt, false)) {
            string SQL = "select cust_code,code_name from cust_code ";
            SQL += " where code_type='" + code_type + "' " + pwh2;
            if (sortField == "")
                SQL += " order by cust_code";
            else
                SQL += " order by " + sortField;
            DataTable dt = new DataTable();
            connB.DataTable(SQL, dt);

            return dt;
        }
    }
    #endregion

    ///////////////////////////////////////
    #region getdoc_type - 抓取上傳附件種類
    /// <summary>  
    /// 抓取上傳附件種類
    /// </summary>  
    public static DataTable getdoc_type(string arcase) {
        using (DBHelper conn = new DBHelper(Conn.btbrt, false)) {
            string SQL = "select cust_code,code_name,remark from cust_code ";
            SQL += "where code_type='Odoc_type' ";
            if (arcase != "") {
                SQL += "and (remark is null or remark like '%" + arcase + "%') ";
            }
            SQL += "order by sortfld";
            DataTable dt = new DataTable();
            conn.DataTable(SQL, dt);

            return dt;
        }
    }
    #endregion

    #region getdoc_typeE - 抓取上傳附件種類(出口案)
    /// <summary>  
    /// 抓取上傳附件種類
    /// </summary>  
    public static DataTable getdoc_typeE() {
        using (DBHelper conn = new DBHelper(Conn.btbrt, false)) {
            string SQL = "select cust_code,code_name,remark from cust_code where code_type='Odoc_type' and ref_code is null order by sortfld";
            DataTable dt = new DataTable();
            conn.DataTable(SQL, dt);

            return dt;
        }
    }
    #endregion

    #region getcust_code_sys - 抓取sysctrl cust_code
    /// <summary>  
    /// 抓取sysctrl cust_code
    /// </summary>  
    public static DataTable getcust_code_sys(string code_type, string pwh2, string sortField) {
        using (DBHelper cnn = new DBHelper(Conn.Sysctrl, false)) {
            string SQL = "select cust_code,code_name from cust_code ";
            SQL += " where code_type='" + code_type + "' " + pwh2;
            if (sortField == "")
                SQL += " order by cust_code";
            else
                SQL += " order by " + sortField;
            DataTable dt = new DataTable();
            cnn.DataTable(SQL, dt);

            return dt;
        }
    }
    #endregion

    #region GetRoleScode - 抓取系統角色人員
    /// <summary>  
    /// 抓取系統角色人員，psyscode=系統代碼NTBRT，pdept=部門T，proles=角色mg_pror=程序mg_prorm=主管
    /// </summary>  
    public static string GetRoleScode(string pSyscode, string pDept, string pRoles) {
        string mgprscode = "";
        using (DBHelper cnn = new DBHelper(Conn.Sysctrl, false)) {
            string SQL = "select a.scode from scode_roles a inner join scode b on a.scode=b.scode ";
            SQL += " where a.syscode='" + pSyscode + "' and a.dept='" + pDept + "' and a.roles='" + pRoles + "' ";
            SQL += " and (b.end_date is null or b.end_date>='" + DateTime.Today.ToShortDateString() + "')";
            SQL += " order by a.sort ";
            using (SqlDataReader dr = cnn.ExecuteReader(SQL)) {
                while (dr.Read()) {
                    mgprscode += (mgprscode != "" ? ";" : "") + dr.SafeRead("scode", "");
                }
            }
        }
        return mgprscode;
    }
    #endregion

    #region insert_log_table
    /// <summary>
    /// 寫入 Log 檔，適用於 log table 中有 ud_flag、ud_date、ud_scode、prgid 這些欄位者
    /// </summary>
    /// <param name="ud_flag">log_flag(U/D)</param>
    /// <param name="prgid">執行異動的prgid</param>
    /// <param name="table">執行異動的table,ex:要新增至 attach_opt_log 則傳入 attach_opt</param>
    /// <param name="pKey_field">key值欄位名稱,用;分隔</param>
    /// <param name="pKey_value">key值欄位值,用;分隔</param>
    public static void insert_log_table(DBHelper conn, string ud_flag, string prgid, string table, string key_field, string key_value) {
        Dictionary<string, string> pKey = new Dictionary<string, string>();

        if (key_field.IndexOf(";") != 0) {
            string[] arr_key_field = key_field.Split(';');
            string[] arr_key_value = key_value.Split(';');

            for (int i = 0; i < arr_key_field.Length; i++) {
                pKey.Add(arr_key_field[i], arr_key_value[i]);
            }
        }
        insert_log_table(conn, ud_flag, prgid, table, pKey);
    }

    /// <summary>
    /// 寫入 Log 檔，適用於 log table 中有 ud_flag、ud_date、ud_scode、prgid 這些欄位者
    /// </summary>
    /// <param name="ud_flag">log_flag(U/D)</param>
    /// <param name="prgid">執行異動的prgid</param>
    /// <param name="table">執行異動的table,ex:要新增至 attach_opt_log 則傳入 attach_opt</param>
    /// <param name="pKey">key 值欄位名稱&值</param>
    public static void insert_log_table(DBHelper conn, string ud_flag, string prgid, string table, Dictionary<string, string> pKey) {
        string SQL = "";
        string usql = "";
        string wsql = "";
        string tfield_str = "";

        SQL = "SELECT b.name FROM sysobjects AS a, syscolumns AS b ";
        SQL += "WHERE a.id = b.id  AND a.name = " + Util.dbnull(table) + " AND a.xtype='U' ";
        SQL += "ORDER BY b.colid ";
        using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
            while (dr.Read()) {
                tfield_str += (tfield_str != "" ? "," : "") + dr["name"].ToString();
            }
        }

        foreach (KeyValuePair<string, string> item in pKey) {
            wsql += string.Format(" and {0} ='{1}' ", item.Key, item.Value);
        }

        //依log檔的prgid欄位名稱判斷(prgid or ud_prgid)
        switch (table.ToLower()) {
			case "case_opt":
			case "opt_detail":
			case "caseitem_opt":
			case "caseopt_good":
			case "opt_tran":
			case "opt_tranlist":
			case "caseopt_ap":
				usql = "insert into " + table + "_log(ud_date,ud_scode," + tfield_str + ")";
                usql += " SELECT GETDATE()," + Util.dbnull(Sys.GetSession("scode")) + "," + tfield_str;
                usql += " FROM " + table;
                usql += " WHERE 1=1 ";
                usql += wsql;
                break;
            case "step_ext":
				usql = "insert into " + table + "_log(ud_flag,log_date,log_scode,prgid," + tfield_str + ")";
                usql += " SELECT " + Util.dbnull(ud_flag) + ",GETDATE()," + Util.dbnull(Sys.GetSession("scode")) + "," + Util.dbnull(prgid) + "," + tfield_str;
                usql += " FROM " + table;
                usql += " WHERE 1=1 ";
                usql += wsql;
                break;
            default:
                usql = "insert into " + table + "_log(ud_flag,ud_date,ud_scode,prgid," + tfield_str + ")";
                usql += " SELECT " + Util.dbnull(ud_flag) + ",GETDATE()," + Util.dbnull(Sys.GetSession("scode")) + "," + Util.dbnull(prgid) + "," + tfield_str;
                usql += " FROM " + table;
                usql += " WHERE 1=1 ";
                usql += wsql;
                break;
        }
        conn.ExecuteNonQuery(usql);
    }

    #endregion

}


