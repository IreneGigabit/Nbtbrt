using System;
using System.Data;
using System.Data.SqlClient;
using System.Collections.Generic;
using System.Linq;
using System.Web;

public partial class Sys
{
    #region GetCaseDmtMain 交辦檔
    public static DataTable GetCaseDmtMain(DBHelper conn, string in_no) {
        object objResult = null;
        DataTable dt = new DataTable();
        string SQL = "";

        SQL = "SELECT a.*,c.*,g.* ";
        SQL += ",(SELECT b.coun_c FROM sysctrl.dbo.country b WHERE b.coun_code = a.zname_type and b.markb<>'X') AS nzname ";
        SQL += ",(SELECT c.coun_code+c.coun_cname FROM sysctrl.dbo.ipo_country c WHERE c.ref_coun_code = a.prior_country ) AS ncountry ";
        SQL += ",a.mark temp_mark,c.mark case_mark, C.service + C.fees+ C.oth_money AS othsum,b.mark as codemark ";
        SQL += ",''s_marknm,''fseq,c.contract_flag ncontract_flag ";
        SQL += ",(select sc_name from sysctrl.dbo.scode where scode=c.in_scode) in_scodenm ";
        SQL += " FROM dmt_temp A ";
        SQL += " inner join case_dmt c on a.in_no = c.in_no and a.in_scode = c.in_scode ";
        SQL += " inner join code_br b on c.arcase_type=b.rs_type and c.arcase=b.rs_code and b.dept='T' and b.cr='Y' ";
        SQL += " left JOIN dmt_tran G ON C.in_scode = G.in_scode AND C.in_no = G.in_no ";
        SQL += " WHERE A.in_no ='" + in_no + "' and a.case_sqlno=0 ";
        conn.DataTable(SQL, dt);

        if (dt.Rows.Count > 0) {
            dt.Rows[0]["draw_file"] = Sys.Path2Nbtbrt(dt.Rows[0].SafeRead("draw_file", ""));

            dt.Rows[0]["fseq"] = Sys.formatSeq(dt.Rows[0].SafeRead("seq", ""), dt.Rows[0].SafeRead("seq1", ""), "", Sys.GetSession("SeBranch"), Sys.GetSession("dept"));
            if (dt.Rows[0].SafeRead("contract_flag_date", "") != "") {//若已有契約書後補完成日，則表契約書已後補
                dt.Rows[0]["ncontract_flag"] = "N";
            }

            if (dt.Rows[0].SafeRead("s_mark", "") == "S") {
                dt.Rows[0]["s_marknm"] = "服務";
            } else if (dt.Rows[0].SafeRead("s_mark", "") == "L") {
                dt.Rows[0]["s_marknm"] = "證明";
            } else if (dt.Rows[0].SafeRead("s_mark", "") == "M") {
                dt.Rows[0]["s_marknm"] = "團體標章";
            } else if (dt.Rows[0].SafeRead("s_mark", "") == "N") {
                dt.Rows[0]["s_marknm"] = "團體商標";
            } else if (dt.Rows[0].SafeRead("s_mark", "") == "K") {
                dt.Rows[0]["s_marknm"] = "產地證明標章";
            } else {
                dt.Rows[0]["s_marknm"] = "商標";
            }
        }

        return dt;
    }
    #endregion


}
