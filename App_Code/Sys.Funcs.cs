using System;
using System.Data;
using System.Data.SqlClient;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

/// <summary>  
/// 原Server_code.vbs
/// </summary>  
public partial class Sys
{
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
            SQL += "WHERE scode_group.scode = '" + scode + "' and scode_group.grpclass in('" + grpClass + "') ";
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

    #region getGrpidMaster - 抓指定單位主管
    /// <summary>
    /// 抓指定單位主管
    /// </summary>
    /// <param name="grpid">所屬grpid</param>
    /// <param name="master_scode">該單位主管</param>
    /// <param name="master_scname">譹單位主管名稱</param>
    public static void getGrpidMaster(string grpClass, string grpid, ref string master_scode,ref string master_scname) {
        using (DBHelper cnn = new DBHelper(Conn.Sysctrl, false)) {
            string SQL = "select grpid,master_scode,sc_name ";
            SQL += "from grpid g ";
            SQL += "inner join scode s on g.master_scode=s.scode ";
            SQL += "WHERE grpclass = '" + grpClass + "' and grpid='" + grpid + "' ";
            using (SqlDataReader dr = cnn.ExecuteReader(SQL)) {
                if (dr.Read()) {
                    master_scode = dr.SafeRead("master_scode", "");
                    master_scname = dr.SafeRead("sc_name", "");
                }
            }
        }
    }
    #endregion

    #region getGrpidUp - 依grpid向上抓取組織
    /// <summary>
    /// 依grpid向上抓取組織
    /// <param>回傳datatable.grplevel,3=組主管,2=部門主管,1=區所主管,0=專商經理,-1=執委</param>
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
    /// <param>回傳datatable.grplevel,3=組主管,2=部門主管,1=區所主管,0=專商經理,-1=執委</param>
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
        string lseq = (seq != "" ? branch.ToUpper() + dept.ToUpper() : "");
        lseq += (lseq != "" ? "-" : "") + seq;
        lseq += (lseq != "" && seq1.Trim() != "_" && seq1.Trim() != "" ? ("-" + seq1) : "");
        lseq += (country != "" ? (" " + country.ToUpper()) : "");
        return lseq;
    }
    #endregion

    #region formatSeq1 - 組本所編號
    /// <summary>  
    /// 組本所編號,ex:NT33333
    /// </summary>  
    public static string formatSeq1(string seq, string seq1, string country, string branch, string dept) {
        string lseq = (seq != "" ? branch.ToUpper() + dept.ToUpper() + seq : "");
        lseq += (seq1.Trim() != "_" && seq1.Trim() != "" ? ("-" + seq1) : "");
        lseq += (country != "" ? (" " + country.ToUpper()) : "");
        return lseq;
    }
    #endregion

    #region getZNo - 取流水號,並加1
    /// <summary>  
    /// 取流水號(cust_code.code_type='Z' and cust_code=??)
    /// </summary>  
    public static string getZNo(DBHelper conn, string cust_code) {
        string z_no = "";
        string SQL = "select isnull(sql,0)+1 from cust_code where code_type='Z' and cust_code='" + cust_code + "'";
        object objResult = conn.ExecuteScalar(SQL);
        z_no = (objResult == DBNull.Value || objResult == null) ? "1" : objResult.ToString();
        
        //流水號加一
        SQL = " update cust_code set sql = sql + 1 where code_type='Z' and cust_code='" + cust_code + "'";
        conn.ExecuteNonQuery(SQL);

        return z_no;
    }
    #endregion

    #region getRsNo - 取收發文序號
    /// <summary>  
    /// 取收發文序號
    /// <param name="cgrs">收發文種類,ex:CR</param>
    /// </summary>  
    public static string getRsNo(DBHelper conn, string cgrs) {
        string rs_no = cgrs.ToUpper() + getZNo(conn, GetSession("sebranch") + "T" + cgrs).PadLeft(8, '0');

        return rs_no;
    }
    #endregion

    #region getERsNo - 取收發文序號(依年度抓流水號)
    /// <summary>  
    /// 取收發文序號(依年度抓流水號)(year_num.num_type=??+年月)
    /// </summary>  
    /// <param name="cgrs">收發文種類,ex:CR</param>
    /// <param name="premark">收發文種類說明,ex:國內所本所發文</param>
    public static string getERsNo(DBHelper conn, string cgrs, string premark) {
        string z_no = "";
        string SQL = "select number from year_num where branch='" + GetSession("sebranch") + "' and dept='" + GetSession("dept") + "E' and num_type='" + cgrs + "' and num_yy = '" + DateTime.Today.Year + "'";
        DataTable dt = new DataTable();
        conn.DataTable(SQL, dt);
        if (dt.Rows.Count > 0) {
            z_no = cgrs.ToUpper() + DateTime.Today.Year.ToString().Right(2) + (Convert.ToInt32(dt.Rows[0].SafeRead("number", "0")) + 1).ToString().PadLeft(6, '0');

            //流水號加一
            SQL = "update year_num set number=number+1 where branch='" + GetSession("sebranch") + "' and dept='" + GetSession("dept") + "E' and num_type='" + cgrs + "' and num_yy = '" + DateTime.Today.Year + "' ";
            conn.ExecuteNonQuery(SQL);
        } else {
            z_no = cgrs.ToUpper() + DateTime.Today.Year.ToString().Right(2) + "000001";

            //新增流水號
            SQL = "insert into year_num(branch,dept,num_type,num_yy,number,remark) values";
            SQL += "('" + GetSession("sebranch") + "','" + GetSession("dept") + "E','" + cgrs + "','" + DateTime.Today.Year + "',1,'" + premark + "')";
            conn.ExecuteNonQuery(SQL);
        }

        return z_no;
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

    #region getRsDetail 取得案性說明
    private static string getRsDetail(DBHelper conn, string pCgrs, string pRsType, string pRsCode) {
        string SQL = "select rs_detail from code_br ";
        SQL += "where " + pCgrs + " = 'Y' ";
        SQL += " and dept = '" + Sys.GetSession("dept") + "' ";
        SQL += " and rs_code = '" + pRsCode + "' ";
        SQL += " and rs_type = '" + pRsType + "' ";
        object objResult = conn.ExecuteScalar(SQL);
        return (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();
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
    public static void getCaseDmtAspx(string rsType, string rsCode, out string ar_form, out string prt_code, out string classp, out string new_form) {
        //rsType=case_dmt.arcase_type
        //rsCode=case_dmt.arcase

        using (DBHelper conn = new DBHelper(Conn.btbrt, false)) {
            object objResult = null;
            string SQL = "";

            //目前版本
            string arcase_type = Sys.getRsType();

            //rs_class(ar_form)=結構分類
            SQL = "SELECT rs_class FROM code_br WHERE rs_code = '" + rsCode + "' AND dept = 'T' AND cr = 'Y' and rs_type='" + rsType + "' ";
            objResult = conn.ExecuteScalar(SQL);
            ar_form = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();

            //prt_code=交辦內容對應的form
            SQL = "SELECT prt_code FROM code_br WHERE rs_code = '" + rsCode + "' AND dept = 'T' AND cr = 'Y' and rs_type='" + rsType + "' ";
            objResult = conn.ExecuteScalar(SQL);
            prt_code = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();

            //classp=承辦交辦發文對應電子申請書.aspx
            SQL = "SELECT classp FROM code_br WHERE rs_code = '" + rsCode + "' AND dept = 'T' AND cr = 'Y' and rs_type='" + rsType + "' ";
            objResult = conn.ExecuteScalar(SQL);
            classp = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();

            //new_form=新版.net對應aspx入口
            SQL = "SELECT c.remark ";
            SQL += "FROM Cust_code c ";
            SQL += "inner join code_br b on b.rs_type=c.Code_type and b.rs_class=c.Cust_code ";
            SQL += "WHERE 1=1 ";
            SQL += "and b.rs_type='" + rsType + "' ";
            SQL += "and b.rs_code='" + rsCode + "' ";
            objResult = conn.ExecuteScalar(SQL);
            new_form = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();

            //案性版本連結
            SQL = "Select remark from cust_code where cust_code='__' and code_type='" + rsType + "'";
            objResult = conn.ExecuteScalar(SQL);
            string link_remark = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();

            //舊版對應到新版的form
            if (link_remark == "92") {
                ar_form = classp;

                SQL = "Select form_name as prt_code1 from cust_code  WHERE code_type='" + arcase_type + "' and cust_code='" + classp + "' ";
                objResult = conn.ExecuteScalar(SQL);
                prt_code = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();

                SQL = "SELECT c.remark ";
                SQL += "FROM Cust_code c ";
                SQL += "inner join code_br b on b.rs_type='" + rsType + "' and b.classp=c.cust_code ";
                SQL += "WHERE 1=1 ";
                SQL += "and b.rs_code='" + rsCode + "' AND b.dept = 'T' AND b.cr = 'Y' and c.code_type='" + arcase_type + "'";
                objResult = conn.ExecuteScalar(SQL);
                new_form = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();
            }

            //判斷有無大類別，如DE1_申請聽證的結構分類為B5，但洽案登錄時案性清單是以大類別的案性都抓(B爭議案)，重抓洽案登錄大類別
            SQL = "select cust_code from cust_code where code_type='" + arcase_type + "' and form_name is not null and cust_code='" + ar_form + "'";
            using (SqlDataReader dr0 = conn.ExecuteReader(SQL)) {
                if (!dr0.HasRows) {
                    dr0.Close();
                    SQL = "select cust_code from cust_code where code_type='" + arcase_type + "' and form_name is not null and cust_code like '" + ar_form.Left(1) + "%' ";
                    using (SqlDataReader dr1 = conn.ExecuteReader(SQL)) {
                        if (dr1.Read()) {
                            ar_form = dr1.SafeRead("cust_code", "");
                        }
                    }
                }
            }


        }
    }
    #endregion

    #region getCase11Aspx - 國內案營洽交辦畫面aspx
    /// <summary>  
    /// 國內案營洽交辦畫面aspx,內建參數如下
    /// <para>in_scode</para> 
    /// <para>in_no</para> 
    /// <para>case_no</para> 
    /// <para>seq</para> 
    /// <para>seq1</para> 
    /// <para>add_arcase</para> 
    /// <para>cust_area</para> 
    /// <para>cust_seq</para> 
    /// <para>ar_form</para> 
    /// <para>new_form</para> 
    /// <para>code_type</para> 
    /// <para>ar_code</para> 
    /// <para>mark</para> 
    /// <para>ar_service</para> 
    /// <para>ar_fees</para> 
    /// <para>ar_curr</para> 
    /// <para>step_grade</para> 
    /// <para>uploadtype=case</para> 
        /// </summary>  
    public static string getCase11Aspx(string prgid, string in_no, string in_scode, string submittask) {
        object objResult = null;
        string urlasp = "";//連結的url
        using (DBHelper conn = new DBHelper(Conn.btbrt, false)) {
            string SQL = "SELECT a.seq,a.seq1,a.in_scode, a.in_no,a.arcase_type,a.arcase_class, a.arcase ";
            SQL += ", a.cust_area, a.cust_seq,a.case_no,a.ar_service,a.ar_fees,a.ar_code,a.ar_curr,a.mark ";
            SQL += ",(SELECT rs_class FROM code_br WHERE rs_code = a.arcase AND dept = 'T' AND cr = 'Y' AND rs_type=a.arcase_type) AS Ar_form ";
            SQL += ",''step_grade ";
            SQL += " FROM case_dmt a ";
            SQL += "where in_no='" + in_no + "' ";
            if (in_scode != "") SQL += "and in_scode='" + in_scode + "' ";
            DataTable dt = new DataTable();
            conn.DataTable(SQL, dt);
            if (dt.Rows.Count > 0) {
                DataRow dr = dt.Rows[0];
                //string new_form = Sys.getCaseDmtAspx(dr.SafeRead("arcase_type", ""), dr.SafeRead("arcase", ""));//連結的aspx
                string ar_form, prt_code, classp, new_form;
                Sys.getCaseDmtAspx(dr.SafeRead("arcase_type", ""), dr.SafeRead("arcase", ""), out ar_form, out prt_code, out classp, out new_form);

                string link_remark = "";
                //SQL = "Select remark from cust_code where cust_code='__' and code_type='" + dr["arcase_type"] + "'";
                //objResult = conn.ExecuteScalar(SQL);
                //link_remark = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();//連結的版本

                //抓取對應客收進度
                SQL = "select step_grade from step_dmt where seq='" + dr["seq"] + "' and seq1='" + dr["seq1"] + "' and case_no='" + dr["case_no"] + "' and cg='C' and rs='R' ";
                objResult = conn.ExecuteScalar(SQL);
                string case_step_grade = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();//抓取對應客收進度

                urlasp = Sys.GetRootDir() + "/brt1m" + link_remark + "/Brt11Edit" + new_form + ".aspx";

                urlasp += "?in_scode=" + dr["in_scode"];
                urlasp += "&in_no=" + dr["in_no"];
                urlasp += "&case_no=" + dr["case_no"];
                urlasp += "&seq=" + dr["seq"];
                urlasp += "&seq1=" + dr["seq1"];
                urlasp += "&add_arcase=" + dr["arcase"];
                urlasp += "&cust_area=" + dr["cust_area"];
                urlasp += "&cust_seq=" + dr["cust_seq"];
                urlasp += "&ar_form=" + ar_form;// dr["ar_form"];
                urlasp += "&new_form=" + new_form;
                urlasp += "&code_type=" + Sys.getRsType();//dr["arcase_type"];
                urlasp += "&ar_code=" + dr["ar_code"];
                urlasp += "&mark=" + dr["mark"];
                urlasp += "&ar_service=" + dr["ar_service"];
                urlasp += "&ar_fees=" + dr["ar_fees"];
                urlasp += "&ar_curr=" + dr["ar_curr"];
                urlasp += "&step_grade=" + case_step_grade;
                urlasp += "&uploadtype=case";
                if (prgid != "") {
                    urlasp += "&prgid=" + prgid;
                }
                if (submittask != "") {
                    urlasp += "&submittask=" + submittask;
                }
            }

            return urlasp;
        }
    }
    #endregion

    #region getCase52Aspx - 國內案營洽交辦維護畫面aspx
    /// <summary>  
    /// 國內案營洽交辦維護畫面aspx
    /// </summary>  
    public static string getCase52Aspx(string prgid, string in_no, string in_scode, string submittask) {
        object objResult = null;
        string urlasp = "";//連結的url
        using (DBHelper conn = new DBHelper(Conn.btbrt, false)) {
            string SQL = "SELECT a.seq,a.seq1,a.in_scode,a.in_no,a.arcase_type,a.arcase_class, a.arcase ";
            SQL += ",a.cust_area,a.cust_seq,a.case_no,a.ar_service,a.ar_fees,a.ar_code,a.ar_curr,a.mark ";
            SQL += ",(SELECT rs_class FROM code_br WHERE rs_code = a.arcase AND dept = 'T' AND cr = 'Y' AND rs_type=a.arcase_type) AS Ar_form ";
            SQL += "FROM case_dmt a ";
            SQL += "where in_no='" + in_no + "' ";
            if (in_scode != "") SQL += "and in_scode='" + in_scode + "' ";
            DataTable dt = new DataTable();
            conn.DataTable(SQL, dt);
            if (dt.Rows.Count > 0) {
                DataRow dr = dt.Rows[0];
                //string new_form = Sys.getCaseDmtAspx(dr.SafeRead("arcase_type", ""), dr.SafeRead("arcase", ""));//連結的aspx
                string ar_form, prt_code, classp, new_form;
                Sys.getCaseDmtAspx(dr.SafeRead("arcase_type", ""), dr.SafeRead("arcase", ""), out ar_form, out prt_code, out classp, out new_form);

                string link_remark = "";
                //SQL = "Select remark from cust_code where cust_code='__' and code_type='" + dr["arcase_type"] + "'";
                //objResult = conn.ExecuteScalar(SQL);
                //link_remark = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();//連結的版本

                SQL = "select step_grade from step_dmt where seq='" + dr["seq"] + "' and seq1='" + dr["seq1"] + "' and case_no='" + dr["case_no"] + "' and cg='C' and rs='R' ";
                objResult = conn.ExecuteScalar(SQL);
                string case_step_grade = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();//抓取對應客收進度

                urlasp = Sys.GetRootDir() + "/brt5m" + link_remark + "/Brt52EDIT" + new_form + ".aspx";

                urlasp += "?in_scode=" + dr["in_scode"];
                urlasp += "&in_no=" + dr["in_no"];
                urlasp += "&case_no=" + dr["case_no"];
                urlasp += "&seq=" + dr["seq"];
                urlasp += "&seq1=" + dr["seq1"];
                urlasp += "&add_arcase=" + dr["arcase"];
                urlasp += "&cust_area=" + dr["cust_area"];
                urlasp += "&cust_seq=" + dr["cust_seq"];
                urlasp += "&ar_form=" + ar_form;// dr["ar_form"];
                urlasp += "&new_form=" + new_form;
                urlasp += "&code_type=" + Sys.getRsType(); //dr["arcase_type"];
                urlasp += "&ar_code=" + dr["ar_code"];
                urlasp += "&mark=" + dr["mark"];
                urlasp += "&ar_service=" + dr["ar_service"];
                urlasp += "&ar_fees=" + dr["ar_fees"];
                urlasp += "&ar_curr=" + dr["ar_curr"];
                urlasp += "&step_grade=" + case_step_grade;
                urlasp += "&uploadtype=case";
                if (prgid != "") {
                    urlasp += "&prgid=" + prgid;
                }
                if (submittask != "") {
                    urlasp += "&submittask=" + submittask;
                }
            }

            return urlasp;
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

    #region getCodeName 取得代碼名稱
    private static string getCodeName(DBHelper conn, string pCodeType, string pCustCode) {
        string SQL = "select code_name from cust_code ";
        SQL += "where code_type = '" + pCodeType + "' ";
        SQL += " and cust_code = '" + pCustCode + "' ";
        object objResult = conn.ExecuteScalar(SQL);
        return (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();
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

    #region getEndCode - 結案代碼
    /// <summary>  
    /// 抓取結案代碼
    /// </summary>  
    public static DataTable getEndCode() {
        using (DBHelper conn = new DBHelper(Conn.btbrt, false)) {
            string SQL = "select cust_code, code_name from cust_code where code_type='ENDCODE'";
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

    #region getCodeBrAgent - 抓取案性代理人
    /// <summary>  
    /// 抓取案性代理人
    /// </summary>  
    public static DataTable getCodeBrAgent(string rs_type,string rs_code,string cgrs,string submitTask) {
        using (DBHelper conn = new DBHelper(Conn.btbrt, false)) {
            //現行案件預設出名代理人
            string tagt_no = getTagNo("N").Rows[0].SafeRead("cust_code", "");

            string SQL = "select rs_class,mark,isnull(remark,'" + tagt_no + "') as rsagtno ";
            SQL += ",(select agt_name from agt where agt_no=isnull(code_br.remark,'" + tagt_no + "')) as rsagtnm ";
            SQL +=",(select treceipt from agt where agt_no=isnull(code_br.remark,'" + tagt_no + "')) as receipt ";
            SQL +=",(select agt_name from agt where agt_no='" + tagt_no + "') as pagt_name ";
            SQL +=",(select treceipt from agt where agt_no='" + tagt_no + "') as preceipt ";
            SQL +=" from code_br where dept='" + Sys.GetSession("dept") + "'";
            SQL +=" and " + cgrs + "='Y'";
            if (submitTask.ToUpper() == "A") {
                SQL += "and (end_date is null or end_date = '' or end_date > getdate()) ";
            }
            if (rs_code != "") {
                SQL += "And rs_code ='" + rs_code + "' ";
            }
            if (rs_type != "") {
                SQL += "And rs_type='" + rs_type + "' ";
            } else {
                SQL += "And rs_type='" + getRsType() + "' ";
            }
            SQL += " ORDER BY rs_class";
            
            DataTable dt = new DataTable();
            conn.DataTable(SQL, dt);
            for (int i = 0; i < dt.Rows.Count; i++) {
                if (dt.Rows[i].SafeRead("rsagtno", "") == "") {
                    dt.Rows[i]["rsagtno"] = tagt_no;
                    dt.Rows[i]["rsagtnm"] = dt.Rows[i].SafeRead("pagt_name", "");
                    dt.Rows[i]["receipt"] = dt.Rows[i].SafeRead("preceipt", "");
                }
            }
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

    #region getCustCode - 抓取cust_code
    /// <summary>  
    /// 抓取cust_code
    /// </summary>  
    /// <param name="pwh2">額外條件,ex:Mark='Y'</param>
    /// <param name="sortField">排序欄位,若未指定則為cust_code</param>
    public static DataTable getCustCode(DBHelper conn, string code_type, string pwh2, string sortField) {
        string SQL = "select * from cust_code where code_type='" + code_type + "' " + pwh2;
        if (sortField == "")
            SQL += " order by cust_code";
        else
            SQL += " order by " + sortField;
        DataTable dt = new DataTable();
        conn.DataTable(SQL, dt);

        return dt;
    }
    #endregion

    #region getBranchCode - 抓取指定單位代碼
    /// <summary>  
    /// 抓取指定單位代碼
    /// </summary>  
    public static DataTable getBranchCode() {
        using (DBHelper cnn = new DBHelper(Conn.Sysctrl, false)) {
            string SQL = "select branch,branchname,sort from branch_code where mark='Y' and showcode='Y' order by sort ";
            DataTable dt = new DataTable();
            cnn.DataTable(SQL, dt);

            return dt;
        }
    }
    #endregion

    #region getSetting - 取得管制日期顏色&天數設定
    public static string getSetting(string pDept, string pType, string pDate) {
        DateTime today = DateTime.Today;
        string Color = "black";

        if (pType == "1") {
            switch (pDept.ToUpper()) {
                //期限稽催列印規則設定 日管制日期超過2天的顯示紅色
                //管制日期 <= 2 日內顯示紅色
                case "T":
                    if (Util.str2Dateime(pDate) <= today.AddDays(2)) {
                        Color = "red";
                    }
                    break;
                case "P":
                    if (Util.str2Dateime(pDate) <= today.AddDays(2)) {
                        Color = "red";
                    }
                    break;
            }
        } else {
            switch (pDept.ToUpper()) {
                //期限稽催列印規則設定 日管制日期超過2天的顯示紅色
                //管制日期 <= 2 日內顯示紅色
                case "T":
                    if (Util.str2Dateime(pDate) >= today.AddDays(2)) {
                        Color = "red";
                    }
                    break;
                case "P":
                    if (Util.str2Dateime(pDate) >= today.AddDays(2)) {
                        Color = "red";
                    }
                    break;
            }
        }

        return Color;
    }
    #endregion

    //各種人員清單///////////////////////////////////////////////////////////
    #region getLoginGrpSales - 抓取LoginGrp內的營洽(LoginGrp.worktype='sales')
    /// <summary>  
    /// 抓取LoginGrp內的營洽(LoginGrp.worktype='sales')
    /// </summary>  
    public static DataTable getLoginGrpSales(string submitTask, string pwh) {
        using (DBHelper cnn = new DBHelper(Conn.Sysctrl, false)) {
            //string SQL = "SELECT distinct(scode)scode,sc_name,right('0000'+substring(scode,2,len(scode)),4) as a ";
            //SQL += " FROM vcust_scode ";
            //SQL += " WHERE dept='T' AND  Syscode = '" + Sys.GetSession("syscode") + "' and branch='" + Sys.GetSession("seBranch") + "'";
            //SQL += " and worktype='sales' order by a";
            //if (submitTask == "A") {
            //    SQL += "and (c.end_date is null or c.end_date>=getdate()) ";
            //}

            string SQL = "SELECT distinct a.scode, b.sc_name,b.sscode ";
            SQL += "FROM scode_group a ";
            SQL += "JOIN scode b ON a.scode=b.scode ";
            SQL += "JOIN grpid c ON a.grpclass=c.grpclass AND a.grpid=c.grpid ";
            SQL += "WHERE c.work_type='sales' ";
            SQL += "and c.grpclass='" + Sys.GetSession("sebranch") + "' and c.grpid not like '%x%' ";
            SQL += "and (substring(c.grpid,1,1)='T' or c.grpid='000') " + pwh;
            if (submitTask == "A") {
                SQL += "and (b.end_date is null or b.end_date >=getdate()) ";
            }
            SQL += "order by b.sscode,a.scode,b.sc_name";
            DataTable dt = new DataTable();
            cnn.DataTable(SQL, dt);

            return dt;
        }
    }
    #endregion

    #region getCaseDmtScode - 抓取交辦檔內的營洽(國內案)
    /// <summary>  
    /// 抓取交辦檔內的營洽(國內案)
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
            //string SQL = "select distinct a.scode,b.sc_name,b.end_date ";
            //SQL += ",case when b.end_date<getdate() then '*' else '' end star ";
            //SQL += ",case when b.end_date<getdate() then 'red' else '' end color ";
            //SQL += "from dmt a ";
            //SQL += "inner join sysctrl.dbo.scode b on a.scode=b.scode ";
            //SQL += "where (a.end_date is null or a.end_date = '') " + pwh;
            //SQL += "order by a.scode ";
            string SQL = "select distinct a.scode,b.end_date,b.sscode ";
            SQL += ",(case rtrim(a.scode) when 'nt' then '部門(開放客戶)' when 'ct' then '部門(開放客戶)' when 'st' then '部門(開放客戶)' when 'kt' then '部門(開放客戶)' ";
            SQL += "else isnull(b.sc_name,'') end) as sc_name ";
            SQL += ",case when b.end_date<getdate() then '*' else '' end star ";
            SQL += ",case when b.end_date<getdate() then 'red' else '' end color ";
            SQL += "from dmt a ";
            SQL += "inner join sysctrl.dbo.scode b on a.scode=b.scode  ";
            SQL += "where (a.end_date is null or a.end_date = '') " + pwh;
            SQL += "order by b.sscode,a.scode ";
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
            //string SQL = "select distinct a.scode,b.sc_name,b.end_date ";
            //SQL += ",case when b.end_date<getdate() then '*' else '' end star ";
            //SQL += ",case when b.end_date<getdate() then 'red' else '' end color ";
            //SQL += "from ext a ";
            //SQL += "inner join sysctrl.dbo.scode b on a.scode=b.scode ";
            //SQL += "where (a.end_date is null or a.end_date = '') " + pwh;
            //SQL += "order by a.scode ";
            string SQL = "select distinct a.scode,b.end_date,b.sscode ";
            SQL += ",(case rtrim(a.scode) when 'nt' then '部門(開放客戶)' when 'ct' then '部門(開放客戶)' when 'st' then '部門(開放客戶)' when 'kt' then '部門(開放客戶)' ";
            SQL += "else isnull(b.sc_name,'') end) as sc_name ";
            SQL += ",case when b.end_date<getdate() then '*' else '' end star ";
            SQL += ",case when b.end_date<getdate() then 'red' else '' end color ";
            SQL += "from ext a ";
            SQL += "inner join sysctrl.dbo.scode b on a.scode=b.scode  ";
            SQL += "where (a.end_date is null or a.end_date = '') " + pwh;
            SQL += "order by b.sscode,a.scode ";
            DataTable dt = new DataTable();
            conn.DataTable(SQL, dt);

            return dt;
        }
    }
    #endregion

    #region getPrScode - 抓取承辦人員
    /// <summary>  
    /// 抓取承辦人員
    /// </summary>  
    public static DataTable getPrScode() {
        using (DBHelper conn = new DBHelper(Conn.btbrt, false)) {
            string SQL = "select a.scode,b.sc_name,a.sort ";
            SQL += " from sysctrl.dbo.scode_roles a ";
            SQL += " inner join sysctrl.dbo.scode b on a.scode=b.scode ";
            SQL += " where a.dept = '" + Sys.GetSession("dept") + "' and syscode = '" + Sys.GetSession("syscode") + "' and prgid = 'brta21'";
            SQL += " and roles = 'process' and branch = '" + Sys.GetSession("seBranch") + "' ";
            SQL += " order by sort ";

            DataTable dt = new DataTable();
            conn.DataTable(SQL, dt);

            return dt;
        }
    }
    #endregion

    #region GetGrpidScode - 指定grpid人員(抓取scode_group)
    /// <summary>  
    /// 指定grpid人員
    /// </summary>  
    public static DataTable GetGrpidScode(string grpclass, string grpid, string submitTask) {
        using (DBHelper cnn = new DBHelper(Conn.Sysctrl, false)) {
            string SQL = "select a.*,b.sc_name ";
            SQL += "from scode_group a ";
            SQL += "inner join scode b on a.scode=b.scode ";
            SQL += "where a.grpclass='" + grpclass + "' and grpid='" + grpid + "' ";
            if (submitTask == "A") {
                SQL += "and (b.end_date is null or b.end_date>=getdate()) ";
            }
            DataTable dt = new DataTable();
            cnn.DataTable(SQL, dt);

            return dt;
        }
    }
    #endregion

    #region GetOptPrScode - 爭議組承辦人員，2013/12/25增加判斷scode.end_date,for分案
    /// <summary>  
    /// 爭議組承辦人員
    /// </summary>  
    public static DataTable GetOptPrScode(string submitTask) {
        using (DBHelper cnn = new DBHelper(Conn.Sysctrl, false)) {
            string SQL = "select c.scode,c.sc_name from grpid as a ";
            SQL += " inner join scode_group as b on a.grpclass=b.grpclass and a.grpid=b.grpid ";
            SQL += " inner join scode as c on b.scode=c.scode ";
            SQL += " where a.grpclass='B' and a.grpid='T100'";
            if (submitTask == "A") {
                SQL += "and (c.end_date is null or c.end_date>=getdate()) ";
            }
            DataTable dt = new DataTable();
            cnn.DataTable(SQL, dt);

            return dt;
        }
    }
    #endregion

    #region GetOptBJPrScode - 北京聖島承辦人員，2013/12/25增加判斷scode.end_date,for分案
    /// <summary>  
    /// 北京聖島承辦人員
    /// </summary>  
    public static DataTable GetOptBJPrScode(string submitTask) {
        using (DBHelper cnn = new DBHelper(Conn.Sysctrl, false)) {
            string SQL = "select c.scode,c.sc_name from scode_group as a ";
            SQL += " inner join scode as c on a.scode=c.scode ";
            if (submitTask == "A") {
                SQL += "and (c.end_date is null or c.end_date>=getdate()) ";
            }
            SQL += " where a.grpclass='BJ' and a.grpid='T100' ";
            DataTable dt = new DataTable();
            cnn.DataTable(SQL, dt);

            return dt;
        }
    }
    #endregion
    ////////////////////////////////////////////////////////////////////////

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
            case "step_dmt":
                tfield_str = tfield_str.Replace(",tran_date", "").Replace(",tran_scode", "");
                usql = "insert into " + table + "_log(ud_flg,tran_date,tran_scode," + tfield_str + ")";
                usql += " SELECT " + Util.dbnull(ud_flag) + ",GETDATE()," + Util.dbnull(Sys.GetSession("scode")) + "," + tfield_str;
                usql += " FROM " + table;
                usql += " WHERE 1=1 ";
                usql += wsql;
                break;
            case "ctrl_dmt":
                tfield_str = tfield_str.Replace(",tran_date", "").Replace(",tran_scode", "");
                usql = "insert into " + table + "_log(ud_flg,tran_date,tran_scode," + tfield_str + ")";
                usql += " SELECT " + Util.dbnull(ud_flag) + ",GETDATE()," + Util.dbnull(Sys.GetSession("scode")) + "," + tfield_str;
                usql += " FROM " + table;
                usql += " WHERE 1=1 ";
                usql += wsql;
                break;
            case "resp_dmt":
                tfield_str = tfield_str.Replace(",tran_date", "").Replace(",tran_scode", "");
                usql = "insert into " + table + "_log(ud_flg,resp_flg,tran_date,tran_scode," + tfield_str + ")";
                usql += " SELECT " + Util.dbnull(ud_flag.Left(1)) + ",'" + ud_flag.Right(1) + "',GETDATE()," + Util.dbnull(Sys.GetSession("scode")) + "," + tfield_str;
                usql += " FROM " + table;
                usql += " WHERE 1=1 ";
                usql += wsql;
                break;
            case "fees_dmt":
                usql = "insert into " + table + "_log(ud_flg,ud_date,ud_scode,prgid," + tfield_str + ")";
                usql += " SELECT " + Util.dbnull(ud_flag) + ",GETDATE()," + Util.dbnull(Sys.GetSession("scode")) + "," + Util.dbnull(prgid) + "," + tfield_str;
                usql += " FROM " + table;
                usql += " WHERE 1=1 ";
                usql += wsql;
                break;
            case "cs_dmt":
                usql = " insert into " + table + "_log(ud_flg,rs_no,branch,seq,seq1,cust_seq,att_sql,step_date,send_way";
                usql += ",rs_type,rs_class,rs_code,act_code,rs_detail,mark,tran_date,tran_scode";
                usql += ",print_date,mail_date,mail_scode,mwork_date)";
                usql += " select " + Util.dbnull(ud_flag) + ",rs_no,branch,seq,seq1,cust_seq,att_sql,step_date,send_way";
                usql += ",rs_type,rs_class,rs_code,act_code,rs_detail,mark,getdate()," + Util.dbnull(Sys.GetSession("scode"));
                usql += ",print_date,mail_date,mail_scode,mwork_date";
                usql += " from vcs_dmt";
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
