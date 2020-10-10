using System;
using System.Configuration;
using System.Web;
using System.Data.SqlClient;
using System.Collections.Generic;
using System.Net.Mail;
using System.Text;
using System.IO;
using System.Collections;
using System.Collections.Specialized;

//檔案上傳相關設定 & function
public partial class Sys
{
    /// <summary>
    /// 區所上傳檔案實體主機(fileServer)
    /// </summary>
    public string gbrFileServerName = "";

    /// <summary>
    /// 國外所上傳檔案實體主機(fileServer)
    /// </summary>
    public string gFileServerName = "";

    /// <summary>
    /// 區所檔案的實體路徑 ex.\\sinn11\NTE
    /// </summary>
    public string gbrDir = "";

    /// <summary>
    /// 國外所檔案的實體路徑 ex.\\sin31\FTE_File
    /// </summary>
    public string gDir = "";

    /// <summary>
    /// 區所檔案的虛擬路徑 ex./nbtbrt/NTE
    /// </summary>
    public string gbrWebDir = "";

    /// <summary>
    /// 國外所檔案的虛擬路徑 ex./fext/FTE_File
    /// </summary>
    public string gWebDir = "";

    /// <summary>
    /// 區所請款單的虛擬路徑 ex./nbtbrt/brdb_file
    /// </summary>
    public string gbrDbDir = "";

    /// <summary>
    /// 區所對催帳客函的虛擬路徑 ex./nbtbrt/custdb_file
    /// </summary>
    public string gcustDbDir = "";

    /// <summary>
    /// 取得server name設定
    /// </summary>
    public void getFileServer(string pbrBranch) {
        getFileServer(pbrBranch, "");
    }

    #region getFileServer - 取得server name設定
    /// <summary>
    /// 取得server name設定
    /// </summary>
    public void getFileServer(string pbrBranch, string prgid) {
        switch (Host) {
            case "web08"://開發環境
                gbrFileServerName = "web02";
                gFileServerName = "web02";
                break;
            case "web10"://測試環境
                gbrFileServerName = "web01";
                gFileServerName = "web01";
                break;
            default: //正式環境
                if (pbrBranch.ToUpper() == "N") gbrFileServerName = "sinn11";
                if (pbrBranch.ToUpper() == "C") gbrFileServerName = "sic11";
                if (pbrBranch.ToUpper() == "S") gbrFileServerName = "sis11";
                if (pbrBranch.ToUpper() == "K") gbrFileServerName = "sik11";
                gFileServerName = "web02";
                break;
        }

        gDir = @"\\" + gFileServerName + @"\FTE_file";

        if (prgid.Left(3).ToLower() == "brt") {
            gbrWebDir = "/nbtbrt/" + pbrBranch + "T";
            gbrDir = @"\\" + gbrFileServerName + @"\" + pbrBranch + "T";
            gWebDir = "";
        } else {
            gbrWebDir = "/nbtbrt/" + pbrBranch + "TE";
            gbrDir = @"\\" + gbrFileServerName + @"\" + pbrBranch + "TE";
            gWebDir = "/Fext/FTE_File";//國外所改.net時要改project name
        }
        gbrDbDir = "/nbtbrt/brdb_file";
        gcustDbDir = "/nbtbrt/custdb_file";
    }
    #endregion

    #region CreateFolder - 檢查目錄是否存在,若不存在則建立
    /// <summary>
    /// 檢查目錄是否存在,若不存在則建立
    /// </summary>
    /// <param name="strSite">虛擬路徑根目錄 ex./nbtbrt/NT</param>
    /// <param name="strFolder">虛擬路徑 ex.temp/N/3/23/55</param>
    public static void CreateFolder(string strSite, string strFolder) {
        string fullFolder = strSite + "/" + strFolder;
        if (!System.IO.Directory.Exists(HttpContext.Current.Server.MapPath(fullFolder))) {
            //新增資料夾
            System.IO.Directory.CreateDirectory(HttpContext.Current.Server.MapPath(fullFolder));
        }
    }
    #endregion

    #region RenameFile - 檔案重新命名
    /// <summary>
    /// 檔案重新命名
    /// </summary>
    /// <param name="srcFile">原始路徑(虛擬路徑)</param>
    /// <param name="dstFile">目的路徑(虛擬路徑)</param>
    /// <param name="backupFlag">檔案衝突時是否備份舊檔</param>
    /// <returns></returns>
    public static void RenameFile(string srcFile, string dstFile, bool backupFlag) {
        System.IO.FileInfo sFi = new System.IO.FileInfo(HttpContext.Current.Server.MapPath(srcFile));
        System.IO.FileInfo dFi = new System.IO.FileInfo(HttpContext.Current.Server.MapPath(dstFile));
        string backup_name = String.Format("{0}_{1}-{2}{3}"
                                            , Path.GetFileNameWithoutExtension(dFi.Name)
                                            , DateTime.Now.ToString("yyyyMMddHHmmss")
                                            , Sys.GetSession("scode")
                                            , dFi.Extension);
        if (HttpContext.Current.Request["chkTest"] != "TEST") {
            if (dFi.Exists && backupFlag) {
                dFi.MoveTo(dFi.DirectoryName + "\\" + backup_name);
            }
            sFi.CopyTo(dFi.FullName, true);
        } else {
            HttpContext.Current.Response.Write("來源=" + sFi.FullName + "<BR>");
            HttpContext.Current.Response.Write("目的=" + dFi.FullName + "<BR>");
            HttpContext.Current.Response.Write("衝突備份=" + dFi.DirectoryName + "\\" + backup_name + "<HR>");
        }
    }
    #endregion

    #region getBackupFile - 取得備份檔案名稱xx
    /// <summary>
    /// 取得備份檔案名稱xx
    /// </summary>
    /// <param name="strFile">原始檔名</param>
    /// <returns></returns>
    private static string getBackupFile(string strFile) {
        string tfile_back = "";
        int n = strFile.LastIndexOf(".");   //副檔名的起始位置
        tfile_back = strFile.Substring(0, n) + "_" + DateTime.Now.ToString("yyyyMMddhhmmss") + "-" + HttpContext.Current.Session["scode"] + strFile.Substring(n);
        return tfile_back;
    }
    #endregion

    #region updmt_attach_forcase - 交辦文件上傳存檔處理
    /// <summary>  
    /// 交辦文件上傳存檔處理
    /// </summary>  
    public static void updmt_attach_forcase(HttpContext context, DBHelper conn, string pprgid, string pin_no) {
        Dictionary<string, string> ColMap = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
        string SQL = "";
        string fld = context.Request["uploadfield"] ?? "";
        string uploadSource = context.Request["uploadSource"] ?? "";
        //string strpath1 = sfile.gbrWebDir + "/" + Request["attach_path"];

        //本次上傳筆數
        for (int k = 1; k <= Convert.ToInt32("0" + context.Request[fld + "_filenum"]); k++) {
            string attach_flag = (context.Request["attach_flag_" + k] ?? "").Trim().ToUpper();
            string attach_sqlno = (context.Request["attach_sqlno_" + k] ?? "").Trim();
            string attach_path = (context.Request[fld + "_" + k] ?? "").Trim();//上傳路徑
            string apattach_sqlno = (context.Request[fld + "_apattach_sqlno_" + k] ?? "").Trim();//總契約書流水號
            string attach_no = (context.Request[fld + "attach_no_" + k] ?? "").Trim();//序號
            string straa = (context.Request[fld + "_name_" + k] ?? "").Trim();//上傳檔名

            if (attach_flag == "A") {
                //當上傳路徑不為空的 and attach_sqlno為空的,才需要新增
                if (attach_path != "" && attach_sqlno == "") {
                    //更換檔名
                    string source_name = (context.Request[fld + "_name_" + k] ?? "").Trim();//原始檔名
                    string sExt = System.IO.Path.GetExtension(straa);//副檔名
                    string attach_name = "";//資料庫檔名
                    string newattach_path = "";//資料庫路徑
                    //2015/12/29修改，總契約書或委任書不需更換檔名
                    if (apattach_sqlno != "") {
                        attach_name = straa;
                        newattach_path = attach_path;
                    } else {
                        attach_name = pin_no + "-" + attach_no + sExt;//重新命名檔名
                        newattach_path = attach_path + "/" + attach_name;//存在資料庫路徑
                        Sys.RenameFile(attach_path + "/" + straa, attach_path + "/" + attach_name, false);
                    }

                    ColMap.Clear();
                    ColMap["Seq"] = Util.dbchar(context.Request["attach_seq"]);
                    ColMap["seq1"] = Util.dbchar(context.Request["attach_seq1"]);
                    ColMap["step_grade"] = Util.dbchar(context.Request["attach_step_grade"]);
                    ColMap["case_no"] = Util.dbchar(context.Request["attach_case_no"]);
                    ColMap["in_no"] = Util.dbchar(pin_no);
                    ColMap["source"] = Util.dbchar(uploadSource);
                    ColMap["in_date"] = "getdate()";
                    ColMap["in_scode"] = "'" + context.Session["scode"] + "'";
                    ColMap["attach_no"] = "'" + attach_no + "'";
                    ColMap["attach_path"] = "'" + Sys.Path2Btbrt(newattach_path) + "'";
                    ColMap["doc_type"] = Util.dbchar(context.Request["doc_type_" + k]);
                    ColMap["attach_desc"] = Util.dbchar(context.Request[fld + "_desc_" + k]);
                    ColMap["attach_name"] = Util.dbchar(attach_name);
                    ColMap["source_name"] = Util.dbchar(source_name);
                    ColMap["attach_size"] = Util.dbnull(context.Request[fld + "_size_" + k]);
                    ColMap["attach_flag"] = "'A'";
                    ColMap["Mark"] = "''";
                    ColMap["tran_date"] = "getdate()";
                    ColMap["tran_scode"] = "'" + context.Session["scode"] + "'";
                    ColMap["attach_branch"] = Util.dbnull(context.Request[fld + "_branch_" + k]);
                    ColMap["apattach_sqlno"] = Util.dbnull(context.Request[fld + "_apattach_sqlno_" + k]);

                    SQL = "insert into dmt_attach " + ColMap.GetInsertSQL();
                    conn.ExecuteNonQuery(SQL);
                }
            } else if (attach_flag == "U") {
                //當attach_sqlno <> empty時,表示db有值,必須刪除data(update attach_flag = 'D')
                if (attach_sqlno != "" && attach_path == "") {
                    Sys.insert_log_table(conn, "D", pprgid, "dmt_attach", "attach_sqlno;in_no", attach_sqlno + ";" + pin_no, "");
                    if (attach_sqlno != "") {
                        SQL = "update dmt_attach set attach_flag='D' ";
                        SQL += ",tran_date=getdate(),tran_scode='" + Sys.GetSession("scode") + "'";
                        SQL += " where attach_sqlno='" + attach_sqlno + "' and in_no='" + pin_no + "'";
                        conn.ExecuteNonQuery(SQL);
                    }
                } else {
                    Sys.insert_log_table(conn, "U", pprgid, "dmt_attach", "attach_sqlno;in_no", attach_sqlno + ";" + pin_no, "");
                    string source_name = (context.Request["source_name_" + k] ?? "").Trim();//原始檔名
                    string old_attach_name = (context.Request["old_" + fld + "_name_" + k] ?? "").Trim();//舊檔名
                    //更換檔名
                    string sExt = System.IO.Path.GetExtension(straa);//副檔名
                    string attach_name = straa;//資料庫檔名
                    string newattach_path = attach_path;//資料庫路徑

                    //2015/12/29修改，總契約書或委任書不需更換檔名
                    if (apattach_sqlno == "") {
                        if (straa != old_attach_name) {//畫面上傳檔名與原檔案名稱不一樣，表示上傳新檔案，所以要更名
                            attach_name = pin_no + "-" + attach_no + sExt;//重新命名檔名
                            newattach_path = attach_path + "/" + attach_name;//存在資料庫路徑
                            Sys.RenameFile(attach_path + "/" + straa, attach_path + "/" + attach_name, false);
                            source_name = straa;
                        }
                    }
                    SQL = "Update dmt_attach set Source=" + Util.dbchar(uploadSource);
                    SQL += ",attach_path=" + Util.dbchar(Sys.Path2Btbrt(newattach_path));
                    SQL += ",attach_desc=" + Util.dbchar(context.Request[fld + "_desc_" + k]);
                    SQL += ",attach_name=" + Util.dbchar(attach_name);
                    SQL += ",attach_size=" + Util.dbnull(context.Request[fld + "_size_" + k]);
                    SQL += ",source_name=" + Util.dbchar(source_name);
                    SQL += ",doc_type=" + Util.dbchar(context.Request["doc_type_" + k]);
                    SQL += ",attach_flag='U'";
                    SQL += ",attach_branch=" + Util.dbnull(context.Request[fld + "_branch_" + k]);
                    SQL += ",tran_date=getdate()";
                    SQL += ",tran_scode='" + context.Session["scode"] + "'";
                    SQL += ",case_no=" + Util.dbchar(context.Request["attach_case_no"]);
                    SQL += " Where attach_sqlno='" + attach_sqlno + "' and in_no='" + pin_no + "'";
                }
            } else if (attach_flag == "D") {
                Sys.insert_log_table(conn, "D", pprgid, "dmt_attach", "attach_sqlno", attach_sqlno, "");
                //當attach_sqlno <> empty時,表示db有值,必須刪除data(update attach_flag = 'D')
                if (attach_sqlno != "") {
                    SQL = "update dmt_attach set attach_flag='D' ";
                    SQL += ",tran_date=getdate(),tran_scode='" + Sys.GetSession("scode") + "'";
                    SQL += " where attach_sqlno='" + attach_sqlno + "' and in_no='" + pin_no + "'";
                    conn.ExecuteNonQuery(SQL);
                }
            }
        }
    }
    #endregion
}
