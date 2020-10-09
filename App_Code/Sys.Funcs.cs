using System;
using System.Data;
using System.Data.SqlClient;
using System.Collections.Generic;
using System.Linq;
using System.Web;

/// <summary>  
/// 原Server_code.vbs
/// </summary>  
public partial class Sys
{
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

    #region getSignMaster - 抓取特殊處理簽核主管
    /// <summary>
    /// 抓取特殊處理簽核主管
    /// </summary>
    public static DataTable getSignMaster(string se_branch, string se_grpid, string se_scode, string msc_scode) {
        using (DBHelper cnn = new DBHelper(Conn.ODBCDSN, false)) {
            string SQL = "SELECT a.master_scode, '商標主管' AS master_type, b.sc_name AS master_scodenm, b.sscode, '1' AS sort FROM GrpID AS a INNER JOIN scode AS b ON a.master_scode = b.scode WHERE a.GrpID IN ('T100', 'TA100', 'TB100') AND a.grpclass='" + se_branch + "' AND a.master_scode NOT IN ('" + msc_scode + "')";
            SQL += " UNION";
            SQL += " SELECT a.master_scode, '營洽主管' AS master_type, b.sc_name AS master_scodenm, b.sscode, '2' AS sort FROM GrpID AS a INNER JOIN scode AS b ON a.master_scode = b.scode WHERE a.GrpID LIKE '" + se_grpid.Left(2) + "[1-9]%' AND a.grpclass='" + se_branch + "' AND a.master_scode NOT IN ('" + msc_scode + "','" + se_scode + "')";
            SQL += " UNION";
            SQL += " SELECT a.master_scode,  '區所主管' AS master_type, b.sc_name AS master_scodenm, b.sscode, '3' AS sort FROM GrpID AS a INNER JOIN scode AS b ON a.master_scode = b.scode WHERE a.Grpid = '000' AND a.grpclass = '" + se_branch + "'";
            SQL += " ORDER BY sort, sscode";
            DataTable dt = new DataTable();
            cnn.DataTable(SQL, dt);
            return dt;
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

    #region getRsTypeExt - 出口案目前交辦案性的版本
    /// <summary>  
    /// 出口案目前交辦案性的版本
    /// </summary>  
    public static string getRsTypeExt() {
        using (DBHelper conn = new DBHelper(Conn.btbrt, false)) {
            string SQL = "select cust_code from cust_code where code_type='ters_type'";
            object objResult = conn.ExecuteScalar(SQL);
            return (objResult == DBNull.Value || objResult == null) ? "TE95" : objResult.ToString();
        }
    }
    #endregion

    #region getDefaultTitle - 目前官發收據抬頭預設值
    /// <summary>  
    /// 目前官發收據抬頭預設值
    /// </summary>  
    public static string getDefaultTitle() {
        using (DBHelper conn = new DBHelper(Conn.btbrt, false)) {
            string SQL = "select cust_code from cust_code where code_type like '%rec_titleT%' and mark='Y' ";
            object objResult = conn.ExecuteScalar(SQL);
            return (objResult == DBNull.Value || objResult == null) ? "A" : objResult.ToString();//a:案件申請人
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
                SQL += "And rs_type='" + getRsType() + "' ";
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

    #region getCountry - 國籍
    /// <summary>  
    /// 抓取國籍
    /// </summary>  
    public static DataTable getCountry() {
        using (DBHelper cnn = new DBHelper(Conn.Sysctrl, false)) {
            string SQL = "select coun_code,coun_c from country where markb<>'X' or markb is null order by coun_code";
            DataTable dt = new DataTable();
            cnn.DataTable(SQL, dt);

            return dt;
        }
    }
    #endregion

    #region getAgent - 抓取代理人清單
    /// <summary>  
    /// 抓取代理人清單
    /// </summary>  
    public static DataTable getAgent() {
        using (DBHelper conn = new DBHelper(Conn.btbrt, false)) {
            //現行案件預設出名代理人
            string SQL="select cust_code from cust_code where code_type='Tagt_no' and mark='N'";
            object objResult = conn.ExecuteScalar(SQL);
            string d_agt_no1= (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString().Trim();

            SQL = "SELECT agt_no,agt_name1,agt_name2,agt_name3,agt_namefull,''selected ";
            SQL += "FROM agt ";
            SQL += "ORDER BY agt_no";

            DataTable dt = new DataTable();
            conn.DataTable(SQL, dt);
            for (int i = 0; i < dt.Rows.Count; i++) {
                if(dt.Rows[i].SafeRead("agt_no", "")==d_agt_no1){
                    dt.Rows[i]["selected"] ="selected";
                }
            }
            return dt;
        }
    }
    #endregion

    #region getCustCode - 抓取cust_code
    /// <summary>  
    /// 抓取cust_code
    /// </summary>  
    public static DataTable getCustCode(string code_type, string pwh2, string sortField) {
        using (DBHelper conn = new DBHelper(Conn.btbrt, false)) {
            string SQL = "select cust_code,code_name,form_name,ref_code,remark,mark,mark1 ";
            SQL += " from cust_code ";
            SQL += " where code_type='" + code_type + "' " + pwh2;
            if (sortField == "")
                SQL += " order by cust_code";
            else
                SQL += " order by " + sortField;
            DataTable dt = new DataTable();
            conn.DataTable(SQL, dt);

            return dt;
        }
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
    /// <param name="reason">log說明</param>
    public static void insert_log_table(DBHelper conn, string ud_flag, string prgid, string table, string key_field, string key_value,string reason) {
        Dictionary<string, string> pKey = new Dictionary<string, string>();

        if (key_field.IndexOf(";") != 0) {
            string[] arr_key_field = key_field.Split(';');
            string[] arr_key_value = key_value.Split(';');

            for (int i = 0; i < arr_key_field.Length; i++) {
                pKey.Add(arr_key_field[i], arr_key_value[i]);
            }
        }
        insert_log_table(conn, ud_flag, prgid, table, pKey, reason);
    }

    /// <summary>
    /// 寫入 Log 檔，適用於 log table 中有 ud_flag、ud_date、ud_scode、prgid 這些欄位者
    /// </summary>
    /// <param name="ud_flag">log_flag(U/D)</param>
    /// <param name="prgid">執行異動的prgid</param>
    /// <param name="table">執行異動的table,ex:要新增至 attach_opt_log 則傳入 attach_opt</param>
    /// <param name="pKey">key 值欄位名稱＆值</param>
    /// <param name="reason">log說明</param>
    public static void insert_log_table(DBHelper conn, string ud_flag, string prgid, string table, Dictionary<string, string> pKey, string reason) {
        string SQL = "";
        string usql = "";
        string wsql = "";
        string tfield_str = "";//column

        SQL = "SELECT b.name FROM sysobjects AS a, syscolumns AS b ";
        SQL += "WHERE a.id = b.id  AND a.name = " + Util.dbnull(table) + " AND a.xtype='U' ";
        SQL += "ORDER BY b.colid ";
        using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
            while (dr.Read()) {
                tfield_str += (tfield_str != "" ? "," : "") + dr["name"].ToString();
            }
        }

        ////table & log table都有的欄位才寫入
        //SQL = "SELECT b.name FROM sysobjects AS a, syscolumns AS b ";
        //SQL += "WHERE a.id = b.id  AND a.name = " + Util.dbnull(table) + " AND a.xtype='U' ";
        //SQL += "ORDER BY b.colid ";
        //DataTable dt = new DataTable();
        //conn.DataTable(SQL, dt);
        //for (int i = 0; i < dt.Rows.Count; i++) {
        //    SQL = "SELECT b.name FROM sysobjects AS a, syscolumns AS b ";
        //    SQL += "WHERE a.id = b.id  AND a.name = " + Util.dbnull(table) + " AND a.xtype='U' and b.name=" + Util.dbchar(dt.Rows[i]["name"].ToString()) + " ";
        //    SQL += "ORDER BY b.colid ";
        //    object objResult = conn.ExecuteScalar(SQL);
        //    if (!(objResult == DBNull.Value || objResult == null)) {
        //        tfield_str += (tfield_str != "" ? "," : "") + dt.Rows[i]["name"].ToString();
        //    }
        //}

        foreach (KeyValuePair<string, string> item in pKey) {
            wsql += string.Format(" and {0} ='{1}' ", item.Key, item.Value);
        }

        //依log檔的prgid欄位名稱判斷(prgid or ud_prgid)
        switch (table.ToLower()) {
            case "case_dmt":
                usql = "insert into " + table + "_log(upd_flg,reason,log_date,log_scode," + tfield_str + ")";
                usql += " SELECT " + Util.dbchar(ud_flag) + ","+Util.dbchar(reason)+",GETDATE()," + Util.dbnull(Sys.GetSession("scode")) + "," + tfield_str;
                usql += " FROM " + table;
                usql += " WHERE 1=1 ";
                usql += wsql;
                break;
            case "caseitem_dmt":
                usql = "insert into " + table + "_log(case_dmt_log_sqlno,log_date,log_scode," + tfield_str + ")";
                usql += " SELECT isnull((select max(sqlno) from case_dmt_log where 1=1 "+wsql+"),0) ";
                usql += ",GETDATE()," + Util.dbnull(Sys.GetSession("scode")) + "," + tfield_str;
                usql += " FROM " + table;
                usql += " WHERE 1=1 ";
                usql += wsql;
                break;
            case "dmt_temp":
                usql = "insert into " + table + "_log(case_dmt_log_sqlno,log_date,log_scode," + tfield_str + ")";
                usql += " SELECT isnull((select max(sqlno) from case_dmt_log where 1=1 "+wsql+"),0) ";
                usql += ",GETDATE()," + Util.dbnull(Sys.GetSession("scode")) + "," + tfield_str;
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


