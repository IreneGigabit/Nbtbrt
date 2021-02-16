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
    #region showLog - 顯示除錯訊息
    /// <summary>  
    /// 顯示除錯訊息,有設定在web.config內DebugScode者才會顯示訊息
    /// </summary>  
    public static void showLog(string msg) {
        if (IsDebug()) {
            //if (HttpContext.Current.Request["chkTest"] == "TEST") {
                HttpContext.Current.Response.Write(msg + "<hr>");
            //}
        }
    }
    #endregion

    #region getTeamScode - 抓取組主管所屬營洽
    /// <summary>  
    /// 抓取組主管所屬營洽
    /// <para>回傳ex：'n428','ntest','n873','n1231','n1030','n1350'</para>
    /// </summary>  
    public static string getTeamScode(string branch, string scode) {
        using (DBHelper conn = new DBHelper(Conn.Sysctrl, false)) {
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

    #region getScodeGrpid - 抓指定人員所屬grpid及grplevel
    /// <summary>
    /// 抓指定人員所屬grpid及grplevel
    /// </summary>
    /// <param name="grpid">所屬grpid</param>
    /// <param name="grplevel">所屬grplevel</param>
    public static void getScodeGrpid(string grpClass, string scode, ref string grpid, ref string grplevel) {
        using (DBHelper cnn = new DBHelper(Conn.Sysctrl, false)) {
            string SQL = "SELECT scode_group.GrpID, GrpID.grplevel ";
            SQL += "FROM scode_group ";
            SQL += "INNER JOIN GrpID ON scode_group.GrpClass = GrpID.GrpClass AND scode_group.GrpID = GrpID.GrpID ";
            SQL += "WHERE scode_group.scode = '" + scode + "' and scode_group.grpclass ='" + grpClass + "' ";
            using (SqlDataReader dr = cnn.ExecuteReader(SQL)) {
                if (dr.Read()) {
                    grpid = dr.SafeRead("grpid","");
                    grplevel = dr.SafeRead("grplevel", "");
                    if (dr.SafeRead("grpid", "") == "T000x") {//專商經理會抓錯grpid,要寫死
                        grpid = "zzz";
                        grplevel = "0";
                    }
                }
            }
        }
    }
    #endregion

    #region getGrpidUp - 依grpid向上抓取組織
    /// <summary>
    /// 依grpid向上抓取組織
    /// </summary>
    /// <param name="grpId">空白=執委,zzz=專案室,其他=依行政組織</param>
    public static DataTable getGrpidUp(string grpClass, string grpId) {
        using (DBHelper cnn = new DBHelper(Conn.Sysctrl, false)) {
            string SQL = "";
            //專商經理&執委無法用upgrpid串
            if (grpId == "") {
                SQL = "SELECT '" + grpClass + "' GrpClass,'A000'GrpID,'執委會'GrpName,convert(smallint,-1) GrpLevel,'N' GrpType ";
                SQL += ",convert(char,null) work_type,''UpgrpID,a.scode Master_scode ";
                SQL += ",(select sc_name from scode where scode=a.scode)Master_nm,''Agent_scode,''agent_nm,'執委'master_type ";
                SQL += ",'Y'chkcode,0 Up_LEVEL,0 processed ";
                SQL += "from scode_roles a ";
                SQL += "WHERE a.syscode='" + Sys.GetSession("syscode") + "' ";
                SQL += "and a.dept = '" + Sys.GetSession("dept") + "' ";
                SQL += "AND a.roles ='chair' ";
            } else if (grpId == "zzz") {
                SQL = "SELECT '" + grpClass + "' GrpClass,'zzz'GrpID,'專案室'GrpName,convert(smallint,0) GrpLevel,'N' GrpType ";
                SQL += ",convert(char,null) work_type,'A000'UpgrpID,a.scode Master_scode ";
                SQL += ",(select sc_name from scode where scode=a.scode)Master_nm ";
                SQL += ",(select a.scode from scode_roles a where a.syscode='" + Sys.GetSession("syscode") + "' and a.dept='" + Sys.GetSession("dept") + "' and a.roles='chair')Agent_scode ";
                SQL += ",(select s.sc_name from scode_roles a inner join scode s on a.scode=s.scode where a.syscode='" + Sys.GetSession("syscode") + "' and a.dept='" + Sys.GetSession("dept") + "' and a.roles='chair')agent_nm ";
                SQL += ",'專商經理'master_type ";
                SQL += ",'Y'chkcode,0 Up_LEVEL,0 processed ";
                SQL += "from scode_roles a ";
                SQL += "WHERE a.syscode='" + Sys.GetSession("syscode") + "' ";
                SQL += "and a.dept = '" + Sys.GetSession("dept") + "' ";
                SQL += "AND a.roles ='manager' ";
            } else {
                SQL = "SELECT GrpClass,GrpID,GrpName,GrpLevel,GrpType ";
                SQL += ",work_type,UpgrpID,Master_scode ";
                SQL += ",(select sc_name from scode s where s.scode=Master_scode)Master_nm,''Agent_scode,''agent_nm,Remark master_type ";
                SQL += ",chkcode,0 Up_LEVEL,0 processed ";
                SQL += "FROM grpid ";
                SQL += "WHERE GrpClass='" + grpClass + "' and GrpID = '" + grpId + "' ";
            }
            DataTable dt = new DataTable();
            cnn.DataTable(SQL, dt);

            bool process = true;
            int Up_LEVEL = 0;
            while (process) {
                process = false;
                for (int i = 0; i < dt.Rows.Count; i++) {
                    if (Convert.ToInt32(dt.Rows[i]["processed"]) == 0) {
                        process = true;

                        dt.Rows[i]["processed"] = 1;

                        //遞迴向上找
                        Up_LEVEL = Convert.ToInt32(dt.Rows[i]["Up_LEVEL"]) + 1;

                        //專商經理&執委無法用upgrpid串,
                        DataTable dtCte = new DataTable();
                        if (dt.Rows[i]["UpgrpID"].ToString() == "A000") {
                            SQL = "SELECT '" + dt.Rows[i]["GrpClass"] + "' GrpClass,'A000'GrpID,'執委會'GrpName,convert(smallint,-1) GrpLevel,'N' GrpType ";
                            SQL += ",convert(char,null) work_type,''UpgrpID,a.scode Master_scode ";
                            SQL += ",(select sc_name from scode where scode=a.scode)Master_nm,''Agent_scode,''agent_nm,'執委'master_type ";
                            SQL += ",'Y'chkcode," + Up_LEVEL + " Up_LEVEL,0 processed ";
                            SQL += "from scode_roles a ";
                            SQL += "WHERE a.syscode='" + Sys.GetSession("syscode") + "' ";
                            SQL += "and a.dept = '" + Sys.GetSession("dept") + "' ";
                            SQL += "AND a.roles ='chair' ";
                        } else if (dt.Rows[i]["UpgrpID"].ToString() == "zzz") {
                            SQL = "SELECT '" + dt.Rows[i]["GrpClass"] + "' GrpClass,'zzz'GrpID,'專案室'GrpName,convert(smallint,0) GrpLevel,'N' GrpType ";
                            SQL += ",convert(char,null) work_type,'A000'UpgrpID,a.scode Master_scode ";
                            SQL += ",(select sc_name from scode where scode=a.scode)Master_nm ";
                            SQL += ",(select a.scode from scode_roles a where a.syscode='" + Sys.GetSession("syscode") + "' and a.dept='" + Sys.GetSession("dept") + "' and a.roles='chair')Agent_scode ";
                            SQL += ",(select s.sc_name from scode_roles a inner join scode s on a.scode=s.scode where a.syscode='" + Sys.GetSession("syscode") + "' and a.dept='" + Sys.GetSession("dept") + "' and a.roles='chair')agent_nm ";
                            SQL += ",'專商經理'master_type ";
                            SQL += ",'Y'chkcode," + Up_LEVEL + " Up_LEVEL,0 processed ";
                            SQL += "from scode_roles a ";
                            SQL += "WHERE a.syscode='" + Sys.GetSession("syscode") + "' ";
                            SQL += "and a.dept = '" + Sys.GetSession("dept") + "' ";
                            SQL += "AND a.roles ='manager' ";
                        } else  {
                            SQL = "SELECT e.GrpClass,e.GrpID,e.GrpName,e.GrpLevel,e.GrpType ";
                            SQL += ",e.work_type,e.UpgrpID,e.Master_scode ";
                            SQL += ",(select sc_name from scode s where s.scode=e.Master_scode)Master_nm,''Agent_scode,''agent_nm,e.Remark master_type ";
                            SQL += ",e.chkcode," + Up_LEVEL + " Up_LEVEL,0 processed ";
                            SQL += "FROM grpid e ";
                            SQL += "WHERE e.GrpClass='" + dt.Rows[i]["GrpClass"] + "' ";
                            SQL += "and e.GrpID = '" + dt.Rows[i]["UpgrpID"] + "' ";
                            SQL += "AND e.UpgrpID<>'" + dt.Rows[i]["GrpID"] + "' ";
                        }
                        cnn.DataTable(SQL, dtCte);
                        dt.Merge(dtCte);
                    }
                }
            }

            //濾掉chkcode空的或沒有Y的(虛擬組織),至少留第一層
            DataTable dtFilter=new DataTable();
            var rows = dt.AsEnumerable().Where(x => ((x.SafeRead("chkcode", "") != "" && x.SafeRead("chkcode", "").IndexOf("Y") > -1) || x.SafeRead("Up_LEVEL", "") == "0"));
            if (rows.Any()) dtFilter = rows.CopyToDataTable();

            return dtFilter;
        }
    }
    #endregion

    #region getGrpidDown - 依grpid向下抓取組織
    /// <summary>
    /// 依grpid向下抓取組織
    /// </summary>
    /// <param name="grpId">空白=執委,zzz=專案室,其他=依行政組織</param>
    public static DataTable getGrpidDown(string grpClass, string grpId) {
        using (DBHelper cnn = new DBHelper(Conn.Sysctrl, false)) {
            string SQL = "";
            //專商經理&執委無法用upgrpid串
            if (grpId == "") {
                SQL = "SELECT '" + grpClass + "' GrpClass,'A000'GrpID,'執委會'GrpName,convert(smallint,-1) GrpLevel,'N' GrpType ";
                SQL += ",convert(char,null) work_type,''UpgrpID,a.scode Master_scode ";
                SQL += ",(select sc_name from scode where scode=a.scode)Master_nm,''Agent_scode,''agent_nm,'執委'master_type ";
                SQL += ",'Y'chkcode,0 Up_LEVEL,0 processed ";
                SQL += "from scode_roles a ";
                SQL += "WHERE a.syscode='" + Sys.GetSession("syscode") + "' ";
                SQL += "and a.dept = '" + Sys.GetSession("dept") + "' ";
                SQL += "AND a.roles ='chair' ";
            } else if (grpId == "zzz") {
                SQL = "SELECT '" + grpClass + "' GrpClass,'zzz'GrpID,'專案室'GrpName,convert(smallint,0) GrpLevel,'N' GrpType ";
                SQL += ",convert(char,null) work_type,'A000'UpgrpID,a.scode Master_scode ";
                SQL += ",(select sc_name from scode where scode=a.scode)Master_nm ";
                SQL += ",(select a.scode from scode_roles a where a.syscode='" + Sys.GetSession("syscode") + "' and a.dept='" + Sys.GetSession("dept") + "' and a.roles='chair')Agent_scode ";
                SQL += ",(select s.sc_name from scode_roles a inner join scode s on a.scode=s.scode where a.syscode='" + Sys.GetSession("syscode") + "' and a.dept='" + Sys.GetSession("dept") + "' and a.roles='chair')agent_nm ";
                SQL += ",'專商經理'master_type ";
                SQL += ",'Y'chkcode,0 Up_LEVEL,0 processed ";
                SQL += "from scode_roles a ";
                SQL += "WHERE a.syscode='" + Sys.GetSession("syscode") + "' ";
                SQL += "and a.dept = '" + Sys.GetSession("dept") + "' ";
                SQL += "AND a.roles ='manager' ";
            } else {
                SQL = "SELECT GrpClass,GrpID,GrpName,GrpLevel,GrpType ";
                SQL += ",work_type,UpgrpID,Master_scode ";
                SQL += ",(select sc_name from scode s where s.scode=Master_scode)Master_nm,''Agent_scode,''agent_nm,Remark master_type ";
                SQL += ",chkcode,0 Up_LEVEL,0 processed ";
                SQL += "FROM grpid ";
                SQL += "WHERE GrpClass='" + grpClass + "' and GrpID = '" + grpId + "' ";
            }
            DataTable dt = new DataTable();
            cnn.DataTable(SQL, dt);

            bool process = true;
            int Up_LEVEL = 0;
            while (process) {
                process = false;
                for (int i = 0; i < dt.Rows.Count; i++) {
                    if (Convert.ToInt32(dt.Rows[i]["processed"]) == 0) {
                        process = true;

                        dt.Rows[i]["processed"] = 1;

                        //遞迴向下找
                        Up_LEVEL = Convert.ToInt32(dt.Rows[i]["Up_LEVEL"]) + 1;

                        DataTable dtCte = new DataTable();
                        if (dt.Rows[i]["GrpID"].ToString() == "A000") {
                            SQL = "SELECT '" + dt.Rows[i]["GrpClass"] + "' GrpClass,'zzz'GrpID,'專案室'GrpName,convert(smallint,0) GrpLevel,'N' GrpType ";
                            SQL += ",convert(char,null) work_type,'A000'UpgrpID,a.scode Master_scode ";
                            SQL += ",(select sc_name from scode where scode=a.scode)Master_nm ";
                            SQL += ",(select a.scode from scode_roles a where a.syscode='" + Sys.GetSession("syscode") + "' and a.dept='" + Sys.GetSession("dept") + "' and a.roles='chair')Agent_scode ";
                            SQL += ",(select s.sc_name from scode_roles a inner join scode s on a.scode=s.scode where a.syscode='" + Sys.GetSession("syscode") + "' and a.dept='" + Sys.GetSession("dept") + "' and a.roles='chair')agent_nm ";
                            SQL += ",'專商經理'master_type ";
                            SQL += ",'Y'chkcode," + Up_LEVEL + " Up_LEVEL,0 processed ";
                            SQL += "from scode_roles a ";
                            SQL += "WHERE a.syscode='" + Sys.GetSession("syscode") + "' ";
                            SQL += "and a.dept = '" + Sys.GetSession("dept") + "' ";
                            SQL += "AND a.roles ='manager' ";
                        } else {
                            SQL = "SELECT e.GrpClass,e.GrpID,e.GrpName,e.GrpLevel,e.GrpType ";
                            SQL += ",e.work_type,e.UpgrpID,e.Master_scode ";
                            SQL += ",(select sc_name from scode s where s.scode=e.Master_scode)Master_nm,''Agent_scode,''agent_nm,e.Remark master_type";
                            SQL += ",e.chkcode," + Up_LEVEL + " Up_LEVEL,0 processed ";
                            SQL += "FROM grpid e ";
                            SQL += "WHERE e.GrpClass='" + dt.Rows[i]["GrpClass"] + "' ";
                            SQL += "and e.UpgrpID = '" + dt.Rows[i]["GrpID"] + "' ";
                            SQL += "AND e.UpgrpID <> e.GrpID ";
                        }
                        cnn.DataTable(SQL, dtCte);
                        dt.Merge(dtCte);
                    }
                }
            }

            //濾掉chkcode空的或沒有Y的(虛擬組織),至少留第一層
            DataTable dtFilter = new DataTable();
            var rows = dt.AsEnumerable().Where(x => ((x.SafeRead("chkcode", "") != "" && x.SafeRead("chkcode", "").IndexOf("Y") > -1) || x.SafeRead("Up_LEVEL", "") == "0"));
            if (rows.Any()) dtFilter = rows.CopyToDataTable();

            return dtFilter;
        }
    }
    #endregion

    #region getSignMaster - 抓取直屬主管
    /// <summary>
    /// 抓取直屬主管,若主管為自己則再往上找
    /// </summary>
    public static string getSignMaster(string grpClass, string scode) {
        return getSignMaster(grpClass, scode, true);
    }
    /// <summary>
    /// 抓取直屬主管
    /// </summary>
    /// <param name="skip">若主管為scode是否再往上找</param>
    public static string getSignMaster(string grpClass, string scode, bool skip) {
        using (DBHelper cnn = new DBHelper(Conn.Sysctrl, false)) {
            string se_Grpid = "", se_Grplevel = "";
            getScodeGrpid(grpClass, scode, ref se_Grpid, ref se_Grplevel);

            //依grpid向上找主管,若主管為自己則再往上找,找到第一個則停止
            string mSC_code = "";
            DataTable dtList = getGrpidUp(grpClass, se_Grpid);
            for (int i = 0; i < dtList.Rows.Count; i++) {
                if (skip) {
                    if (dtList.Rows[i].SafeRead("master_scode", "") != scode && (dtList.Rows[i].SafeRead("chkcode", "") != "" || dtList.Rows[i].SafeRead("chkcode", "").IndexOf("Y") > -1)) {//chkcode空的或全N為虛擬組織,不需簽核
                        mSC_code = dtList.Rows[i].SafeRead("master_scode", "");
                        break;
                    }
                } else {
                    mSC_code = dtList.Rows[i].SafeRead("master_scode", "");
                    break;
                }
            }
            //string SQL = "select * from fn_grpidup('" + grpClass + "','" + se_Grpid + "') ";
            //using (SqlDataReader dr = cnn.ExecuteReader(SQL)) {
            //    while (dr.Read()) {
            //        if (skip) {
            //            if (dr.SafeRead("master_scode", "") != scode && (dr.SafeRead("chkcode", "") != "" || dr.SafeRead("chkcode", "").IndexOf("Y") > -1)) {//chkcode空的或全N為虛擬組織,不需簽核
            //                mSC_code = dr.SafeRead("master_scode", "");
            //                break;
            //            }
            //        } else {
            //            mSC_code = dr.SafeRead("master_scode", "");
            //            break;
            //        }
            //    }
            //}

            return mSC_code;
        }
    }
    #endregion

    #region getMasterList - 向上抓取所有階層
    /// <summary>
    /// 向上抓取所有階層
    /// </summary>
    public static DataTable getMasterList(string grpClass, string scode) {
        using (DBHelper cnn = new DBHelper(Conn.Sysctrl, false)) {
            string se_Grpid = "", se_Grplevel = "";
            getScodeGrpid(grpClass, scode, ref se_Grpid, ref se_Grplevel);

            return getGrpidUp(grpClass, se_Grpid);
        }
    }
    #endregion

    #region getSignList - 抓取特殊處理簽核主管清單
    /// <summary>
    /// 抓取特殊處理簽核主管清單
    /// </summary>
    public static DataTable getSignList(string se_branch, string se_grpid, string se_scode, string msc_scode, string pWhere) {
        using (DBHelper cnn = new DBHelper(Conn.Sysctrl, false)) {
            //string SQL = "SELECT a.master_scode, '商標主管' AS master_type, b.sc_name AS Master_nm, b.sscode, '1' AS sort FROM GrpID AS a INNER JOIN scode AS b ON a.master_scode = b.scode WHERE a.GrpID IN ('T100', 'TA100', 'TB100') AND a.grpclass='" + se_branch + "' AND a.master_scode NOT IN ('" + msc_scode + "','" + se_scode + "')";
            //SQL += " UNION";
            //SQL += " SELECT a.master_scode, '營洽主管' AS master_type, b.sc_name AS Master_nm, b.sscode, '2' AS sort FROM GrpID AS a INNER JOIN scode AS b ON a.master_scode = b.scode WHERE a.GrpID LIKE '" + se_grpid.Left(2) + "[1-9]%' AND a.grpclass='" + se_branch + "' AND a.master_scode NOT IN ('" + msc_scode + "','" + se_scode + "')";
            //SQL += " UNION";
            //SQL += " SELECT a.master_scode, '區所主管' AS master_type, b.sc_name AS Master_nm, b.sscode, '3' AS sort FROM GrpID AS a INNER JOIN scode AS b ON a.master_scode = b.scode WHERE a.Grpid = '000' AND a.grpclass = '" + se_branch + "'";
            //SQL += " ORDER BY sort, sscode";
            string SQL = "select z.*,b.sc_name agent_nm ";
            SQL += "from( ";
            SQL += "SELECT a.grpclass,a.GrpID,a.grpName,a.grplevel,a.grptype,a.work_type,a.upgrpid, '2' AS sort ";
            SQL += ",a.master_scode,(select sc_name from scode where scode=a.master_scode)Master_nm,''agent_scode,'營洽主管' AS master_type,a.chkcode ";
            SQL += "FROM GrpID AS a ";
            SQL += "WHERE (a.GrpID like('" + se_grpid.Left(2) + "[1-9]0')) ";
            SQL += "AND a.grpclass='" + se_branch + "' and (isnull(chkcode,'N') like '%Y%') ";
            SQL += "AND a.master_scode NOT IN ('" + msc_scode + "','" + se_scode + "') ";
            SQL += "UNION ";
            SQL += "SELECT a.grpclass,a.GrpID,a.grpName,a.grplevel,a.grptype,a.work_type,a.upgrpid, '1' AS sort ";
            SQL += ",a.master_scode,(select sc_name from scode where scode=a.master_scode)Master_nm,''agent_scode,'部門主管' AS master_type,a.chkcode ";
            SQL += "FROM GrpID AS a ";
            SQL += "WHERE a.grpclass='" + se_branch + "' and a.GrpID IN ('T000') ";
            SQL += "AND a.master_scode NOT IN ('" + msc_scode + "','" + se_scode + "') ";
            SQL += "UNION ";
            SQL += "SELECT a.grpclass,a.GrpID,a.grpName,a.grplevel,a.grptype,a.work_type,a.upgrpid, '3' AS sort ";
            SQL += ",a.master_scode,(select sc_name from scode where scode=a.master_scode)Master_nm,''agent_scode,'區所主管' AS master_type,a.chkcode ";
            SQL += "FROM GrpID AS a ";
            SQL += "WHERE a.Grpid = '000' AND a.grpclass = '" + se_branch + "' ";
            SQL += "UNION ";
            SQL += "SELECT 'N' GrpClass,'zzz'GrpID,'專案室'GrpName,convert(smallint,0) GrpLevel,'N' GrpType,convert(char,null) work_type,'A000'UpgrpID, '4' AS sort ";
            SQL += ",a.scode Master_scode,(select sc_name from scode where scode=a.scode)Master_nm ";
            SQL += ",(select a.scode from scode_roles a where a.syscode='" + Sys.GetSession("syscode") + "' and a.dept='" + Sys.GetSession("dept") + "' and a.roles='chair')Agent_scode,'專商經理'master_type ,'Y'chkcode ";
            SQL += "from scode_roles a ";
            SQL += "WHERE a.syscode='" + Sys.GetSession("syscode") + "' and a.dept = '" + Sys.GetSession("dept") + "' AND a.roles ='manager' ";
            SQL += "UNION ";
            SQL += "SELECT 'N' GrpClass,'A000'GrpID,'執委會'GrpName,convert(smallint,-1) GrpLevel,'N' GrpType,convert(char,null) work_type,''UpgrpID, '5' AS sort ";
            SQL += ",a.scode Master_scode,(select sc_name from scode where scode=a.scode)Master_nm,''Agent_scode,'執委'master_type,'Y'chkcode ";
            SQL += "from scode_roles a ";
            SQL += "WHERE a.syscode='" + Sys.GetSession("syscode") + "' and a.dept = '" + Sys.GetSession("dept") + "' AND a.roles ='chair' ";
            SQL += ")z ";
            SQL += "left join scode b on z.agent_scode=b.scode ";
            if (pWhere != "") SQL += "where " + pWhere;
            SQL += "ORDER BY sort ";

            DataTable dt = new DataTable();
            cnn.DataTable(SQL, dt);
            return dt;
        }
    }
    #endregion

    #region getRoleScode - 抓取指定scole_roles人員
    /// <summary>  
    /// 抓取scole_roles人員字串
    /// <para>回傳ex：n428;n873;n1350</para>
    /// </summary>  
    public static string getRoleScode(string pBranch, string pSysno, string pDept, string pRoles) {
        using (DBHelper cnn = new DBHelper(Conn.Sysctrl, false)) {
            DataTable dt = getScodeRole(pBranch, pSysno, pDept, pRoles);
            var list = dt.AsEnumerable().Select(r => r.Field<string>("scode")).ToArray();
            return string.Join(";", list);
        }
    }
    /// <summary>  
    /// 抓取scole_roles人員
    /// </summary>  
    public static DataTable getScodeRole(string pBranch, string pSysno, string pDept, string pRoles) {
        using (DBHelper cnn = new DBHelper(Conn.Sysctrl, false)) {
            string SQL = "select a.scode,b.sc_name,a.sort ";
            SQL += "from scode_roles a inner join scode b on a.scode=b.scode ";
            SQL += " where 1=1 ";
            if(pBranch!="") SQL += " and a.branch='" + pBranch + "' ";
            SQL += " and a.syscode='" + pSysno + "' ";
            SQL += " and a.dept='" + pDept + "' ";
            SQL += " and a.roles='" + pRoles + "' ";
            SQL += " and (b.end_date is null or b.end_date>='" + DateTime.Today.ToShortDateString() + "')";
            SQL += " order by a.sort ";
            DataTable dt = new DataTable();
            cnn.DataTable(SQL, dt);
            return dt;
        }
    }
    #endregion

    #region formatSeq - 組本所編號
    /// <summary>  
    /// 組本所編號,ex:NT-33333
    /// </summary>
    public static string formatSeq(string seq, string seq1, string country, string branch, string dept) {
        string lseq = (seq != "" ? branch + dept.ToUpper() + seq : "");
        lseq += (seq1 != "_" && seq1 != "" ? ("-" + seq1) : "");
        lseq += (country != "" ? (" " + country.ToUpper()) : "");
        return lseq;
    }
    #endregion

    #region formatSeq1 - 組本所編號
    /// <summary>  
    /// 組本所編號,ex:NT33333
    /// </summary>  
    public static string formatSeq1(string seq, string seq1, string country, string branch, string dept) {
        string lseq = (seq != "" ? branch + dept.ToUpper() + seq : "");
        lseq += (seq1 != "_" && seq1 != "" ? ("-" + seq1) : "");
        lseq += (country != "" ? (" " + country.ToUpper()) : "");
        return lseq;
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

    #region getCaseAspx - 國內案性對應的交辦畫面aspx
    /// <summary>  
    /// 國內案性對應的交辦畫面aspx
    /// </summary>  
    public static string getCaseDmtAspx(string rsType,string rsCode) {
        using (DBHelper conn = new DBHelper(Conn.btbrt, false)) {
            string SQL = "SELECT c.remark ";
            SQL += "FROM Cust_code c ";
            SQL += "inner join code_br b on b.rs_type=c.Code_type and b.rs_class=c.Cust_code ";
            //SQL += "WHERE c.form_name is not null ";
            SQL += "WHERE 1=1 ";
            SQL += "and b.rs_type='" + rsType + "' ";
            SQL += "and b.rs_code='" + rsCode + "' ";
            object objResult = conn.ExecuteScalar(SQL);
            return (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();
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
            string SQL = "SELECT rs_class,rs_code,prt_code,rs_detail,remark FROM code_br ";
            SQL += "WHERE cr= 'Y' and dept='T' AND no_code='N' ";
            if (rs_type != "") {
                SQL += "And rs_type='" + rs_type + "' ";
            } else {
                SQL += "And rs_type='" + getRsType() + "' ";
            }
            if (rs_class != "") {
                SQL += "And rs_class like '" + rs_class + "%' ";
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

    #region getEndCode - 結案代碼
    /// <summary>  
    /// 抓取結案代碼
    /// </summary>  
    public static DataTable getEndCode() {
        using (DBHelper conn = new DBHelper(Conn.btbrt, false)) {
            string SQL = "SELECT chrelno, chrelname ";
            SQL += ",(select code_name from cust_code where code_type='ENDCODE' and cust_code=chrelno) end_codenm ";
            SQL += "FROM relation where ChRelType = 'ENDCODE' ORDER BY sortfld";
            DataTable dt = new DataTable();
            conn.DataTable(SQL, dt);

            return dt;
        }
    }
    #endregion

    #region getEndType - 結案原因
    /// <summary>  
    /// 抓取結案原因
    /// </summary>  
    public static DataTable getEndType() {
        using (DBHelper conn = new DBHelper(Conn.btbrt, false)) {
            string SQL = "SELECT cust_code, code_name FROM cust_code where code_type = 'TEnd_type' ORDER BY sortfld";
            DataTable dt = new DataTable();
            conn.DataTable(SQL, dt);

            return dt;
        }
    }
    #endregion

    #region getTagNo - 抓取現行案件預設出名代理人
    /// <summary>  
    /// 抓取現行案件預設出名代理人
    /// <para>N:一般案件預設出名代理人。</para> 
    /// <para>C:涉外案件預設出名代理人</para> 
    /// </summary> 
    public static DataTable getTagNo(string mark) {
        using (DBHelper conn = new DBHelper(Conn.btbrt, false)) {
            string SQL = "select cust_code,form_name as agt_name,mark,remark ";
            SQL += ",(select agt_namefull from agt where agt_no=cust_code) as agt_namefull ";
            SQL += "from cust_code ";
            SQL += "where code_type='Tagt_no' and mark='" + mark + "' ";
            DataTable dt = new DataTable();
            conn.DataTable(SQL, dt);

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
            string d_agt_no1 = getTagNo("N").Rows[0].SafeRead("cust_code", "");

            string SQL = "SELECT agt_no,agt_name1,agt_name2,agt_name3,agt_namefull,treceipt,tend_date ";
            SQL += ",(select form_name from cust_code where code_type='company' and cust_code=agt.treceipt) as comp_name ";
            SQL += ",''agt_name,''strcomp_name,''selected,''end_flag ";
            SQL += "FROM agt ";
            SQL += "where branch like '%" + Sys.GetSession("dept") + "%' or branch is null or rtrim(branch) = '' ";
            SQL += "ORDER BY agt_no";

            DataTable dt = new DataTable();
            conn.DataTable(SQL, dt);
            for (int i = 0; i < dt.Rows.Count; i++) {
                dt.Rows[i]["agt_name"] = dt.Rows[i].SafeRead("agt_name1", "");
                if (dt.Rows[i].SafeRead("agt_name2", "") != "") {
                    dt.Rows[i]["agt_name"] = dt.Rows[i].SafeRead("agt_name", "") + "&" + dt.Rows[i].SafeRead("agt_name2", "");
                    if (dt.Rows[i].SafeRead("agt_name3", "") != "") {
                        dt.Rows[i]["agt_name"] = dt.Rows[i].SafeRead("agt_name", "") + "&" + dt.Rows[i].SafeRead("agt_name3", "");
                    }
                }
                if (dt.Rows[i].SafeRead("comp_name", "") != "") {
                    dt.Rows[i]["strcomp_name"] = "(" + dt.Rows[i].SafeRead("comp_name", "") + ")";
                }

                if (dt.Rows[i].SafeRead("agt_no", "") == d_agt_no1) {
                    dt.Rows[i]["selected"] = "selected";
                }

                if (dt.Rows[i].SafeRead("tend_date", "") != "") {
                    dt.Rows[i]["end_flag"] = "Y";
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
    /// <param name="pwh2">額外條件,ex:Mark='Y'</param>
    /// <param name="sortField">排序欄位,若未指定則為cust_code</param>
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

    #region getCaseDmtScode - 抓取交辦檔內的營洽(國內案)
    /// <summary>  
    /// 抓取案件主檔內的營洽(國內案)
    /// </summary>  
    public static DataTable getCaseDmtScode(string branch, string pwh) {
        string strConn = Conn.btbrt;
        if (branch == "") Conn.brp(branch);
        using (DBHelper conn = new DBHelper(strConn, false)) {
            string SQL = "select distinct a.in_scode,b.sc_name,b.end_date ";
            SQL += ",case when b.end_date<getdate() then '*' else '' end star ";
            SQL += ",case when b.end_date<getdate() then 'red' else '' end color ";
            SQL += "from case_dmt a ";
            SQL += "inner join sysctrl.dbo.scode b on a.in_scode=b.scode ";
            SQL += "where (a.mark='N' or a.mark is null) " + pwh;
            SQL += "order by a.in_scode ";

            DataTable dt = new DataTable();
            conn.DataTable(SQL, dt);

            return dt;
        }
    }
    #endregion

    #region getDmtScode - 抓取案件主檔內的營洽(國內案)
    /// <summary>  
    /// 抓取案件主檔內的營洽(國內案)
    /// </summary>  
    public static DataTable getDmtScode(string branch, string pwh) {
        string strConn = Conn.btbrt;
        if (branch == "") Conn.brp(branch);
        using (DBHelper conn = new DBHelper(strConn, false)) {
            string SQL = "select distinct a.scode,b.sc_name,b.end_date ";
            SQL += ",case when b.end_date<getdate() then '*' else '' end star ";
            SQL += ",case when b.end_date<getdate() then 'red' else '' end color ";
            SQL += "from dmt a ";
            SQL += "inner join sysctrl.dbo.scode b on a.scode=b.scode ";
            SQL += "where (a.end_date is null or a.end_date = '') " + pwh;
            SQL += "order by a.scode ";

            DataTable dt = new DataTable();
            conn.DataTable(SQL, dt);

            return dt;
        }
    }
    #endregion

    #region getExtScode - 抓取案件主檔內的營洽(出口案)
    /// <summary>  
    /// 抓取案件主檔內的營洽(出口案)
    /// </summary>  
    public static DataTable getExtScode(string branch, string pwh) {
        string strConn = Conn.btbrt;
        if (branch == "") Conn.brp(branch);
        using (DBHelper conn = new DBHelper(strConn, false)) {
            string SQL = "select distinct a.scode,b.sc_name,b.end_date ";
            SQL += ",case when b.end_date<getdate() then '*' else '' end star ";
            SQL += ",case when b.end_date<getdate() then 'red' else '' end color ";
            SQL += "from ext a ";
            SQL += "inner join sysctrl.dbo.scode b on a.scode=b.scode ";
            SQL += "where (a.end_date is null or a.end_date = '') " + pwh;
            SQL += "order by a.scode ";

            DataTable dt = new DataTable();
            conn.DataTable(SQL, dt);

            return dt;
        }
    }
    #endregion

    #region getBranchCode - 抓取指定單位代碼
    /// <summary>  
    /// 抓取指定單位代碼
    /// </summary>  
    public static DataTable getBranchCode() {
        using (DBHelper cnn = new DBHelper(Conn.Sysctrl, false)) {
            string SQL = "select branch,branchname from branch_code where mark='Y' and showcode='Y' order by sort ";
            DataTable dt = new DataTable();
            cnn.DataTable(SQL, dt);

            return dt;
        }
    }
    #endregion

    #region getCodeName - 抓取代碼資料或特定欄位資料(取第一欄第一列)
    /// <summary>  
    /// 抓取代碼資料或特定欄位資料(取第一欄第一列)
    /// </summary>  
    public static string getCodeName(DBHelper conn, string table, string column, string where) {
        string SQL = "select " + column + " from " + table + " " + where;
        object objResult = conn.ExecuteScalar(SQL);
        return (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();
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
    public static void insert_log_table(DBHelper conn, string ud_flag, string prgid, string table, string key_field, string key_value, string reason) {
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
        //SQL = "select x.name from( ";
        //SQL += "	SELECT b.name FROM sysobjects AS a, syscolumns AS b ";
        //SQL += "	WHERE a.id = b.id  AND a.name = '"+table+"' AND a.xtype='U' ";
        //SQL += ")x  inner join ( ";
        //SQL += "	SELECT b.name FROM sysobjects AS a, syscolumns AS b ";
        //SQL += "	WHERE a.id = b.id  AND a.name = '"+table+"_log' AND a.xtype='U' ";
        //SQL += ")y on x.name=y.name";
        //using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
        //    while (dr.Read()) {
        //        tfield_str += (tfield_str != "" ? "," : "") + dr["name"].ToString();
        //    }
        //}

        foreach (KeyValuePair<string, string> item in pKey) {
            wsql += string.Format(" and {0} ='{1}' ", item.Key, item.Value.Trim());
        }

        //依log檔的prgid欄位名稱判斷(prgid or ud_prgid)
        switch (table.ToLower()) {
            case "dmt":
            case "case_dmt":
            case "case_ext":
                usql = "insert into " + table + "_log(upd_flg,reason,log_date,log_scode," + tfield_str + ")";
                usql += " SELECT " + Util.dbchar(ud_flag) + "," + Util.dbchar(reason) + ",GETDATE()," + Util.dbnull(Sys.GetSession("scode")) + "," + tfield_str;
                usql += " FROM " + table;
                usql += " WHERE 1=1 ";
                usql += wsql;
                break;
            case "caseitem_dmt":
                usql = "insert into " + table + "_log(case_dmt_log_sqlno,log_date,log_scode," + tfield_str + ")";
                usql += " SELECT isnull((select max(sqlno) from case_dmt_log where 1=1 " + wsql + "),0) ";
                usql += ",GETDATE()," + Util.dbnull(Sys.GetSession("scode")) + "," + tfield_str;
                usql += " FROM " + table;
                usql += " WHERE 1=1 ";
                usql += wsql;
                break;
            case "dmt_temp":
                usql = "insert into " + table + "_log(case_dmt_log_sqlno,log_date,log_scode," + tfield_str + ")";
                usql += " SELECT isnull((select max(sqlno) from case_dmt_log where 1=1 " + wsql + "),0) ";
                usql += ",GETDATE()," + Util.dbnull(Sys.GetSession("scode")) + "," + tfield_str;
                usql += " FROM " + table;
                usql += " WHERE 1=1 ";
                usql += wsql;
                break;
            case "ndmt":
                usql = "insert into " + table + "_log(dmt_log_sqlno,log_date,log_scode," + tfield_str + ")";
                usql += " SELECT isnull((select max(sqlno) from dmt_log where 1=1 " + wsql + "),0) ";
                usql += ",GETDATE()," + Util.dbnull(Sys.GetSession("scode")) + "," + tfield_str;
                usql += " FROM " + table;
                usql += " WHERE 1=1 ";
                usql += wsql;
                break;
            case "ctrl_dmt":
            case "step_dmt":
                usql = "insert into " + table + "_log(ud_flg,tran_date,tran_scode," + tfield_str + ")";
                usql += " SELECT " + Util.dbnull(ud_flag) + ",GETDATE()," + Util.dbnull(Sys.GetSession("scode")) + "," + tfield_str;
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
