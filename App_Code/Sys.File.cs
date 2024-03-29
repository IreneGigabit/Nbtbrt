﻿using System;
using System.Configuration;
using System.Web;
using System.Data.SqlClient;
using System.Collections.Generic;
using System.Net.Mail;
using System.Text;
using System.IO;
using System.Collections;
using System.Collections.Specialized;
using System.Text.RegularExpressions;

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
    public string gbrDbDir = Sys.GetRootDir() + "/brdb_file";

    /// <summary>
    /// 區所對催帳客函的虛擬路徑 ex./nbtbrt/custdb_file
    /// </summary>
    public string gcustDbDir = Sys.GetRootDir() + "/custdb_file";

    /// <summary>
    /// 取得server name設定
    /// </summary>
    public void getFileServer(string pbrBranch) {
        getFileServer(pbrBranch, "");
    }

    #region scanpathT - 國內案掃描文件路徑(虛擬路徑)
    /// <summary>
    /// 國內案掃描文件路徑(虛擬路徑)
    /// </summary>
    public static string scanpathT {
        get {
            return Sys.GetRootDir() + "/scandoc/" + GetSession("seBranch") + GetSession("dept").ToUpper();
        }
    }
    #endregion

    #region scanpathTE - 出口案掃描文件路徑(虛擬路徑)
    /// <summary>
    /// 出口案掃描文件路徑(虛擬路徑)
    /// </summary>
    public static string scanpathTE {
        get {
            return Sys.GetRootDir() + "/scandoc/" + GetSession("seBranch") + GetSession("dept").ToUpper() + "E";
       }
    }
    #endregion

    #region formatScanPathNo - 掃瞄文件重新命名
    /// <summary>
    /// 掃瞄文件重新命名
    /// <para>命名規則branch+dept-seq(5)-seq1-step_grade(4)-attach_no(2).pdf</para>
    /// </summary>
    public static void formatScanPathNo(string pseq, string pseq1, string pstep_grade, string pattach_no, ref string scanpath, ref string scanfile) {
        //目錄 (ex:/nbtbrt/scandoc/NT/NT-641/)
        scanpath = Sys.scanpathT + "/" + GetSession("seBranch") + GetSession("Dept").ToUpper() + "-" + pseq.PadLeft(5, '0').Left(3) + "/";

        //檔名 (ex:NT-64150--0002-01.pdf)
        scanfile = GetSession("seBranch") + GetSession("Dept").ToUpper() + "-" + pseq.PadLeft(5, '0') + "-" + (pseq1 != "_" ? pseq1 : "");
        scanfile += "-" + pstep_grade.PadLeft(4, '0') + "-" + pattach_no.PadLeft(2, '0') + ".pdf";
    }
    #endregion

    #region formatScanPathNoExt - 出口案掃瞄文件重新命名規則
    public static void formatScanPathNoExt(string pseq, string pseq1, string pstep_grade, string pattach_no, ref string scanpath, ref string scanfile) {
        //目錄 (ex:/nbtbrt/scandoc/NTE/NTE-641/)
        scanpath = Sys.scanpathT + "/" + GetSession("seBranch") + GetSession("Dept").ToUpper() + "-" + pseq.PadLeft(5, '0').Left(3) + "/";

        //檔名 (ex:NTE-64150--0002-01.pdf)
        scanfile = GetSession("seBranch") + GetSession("Dept").ToUpper() + "E-" + pseq.PadLeft(5, '0') + "-" + (pseq1 != "_" ? pseq1 : "");
        scanfile += "-" + pstep_grade.PadLeft(4, '0') + "-" + pattach_no.PadLeft(2, '0') + ".pdf";
    }
    #endregion

    #region IPODir - 電子送件總管處檔案目錄
    /// <summary>
    /// 電子送件總管處檔案目錄
    /// </summary>
    public static string IPODir {
        get {
            return Sys.GetRootDir() + "/IPOSendT";//由iis虛擬目錄設定正式/測試路徑

            //if (Sys.Host.IndexOf("web") > -1 || Sys.Host.IndexOf("localhost") > -1) {
            //    return "/nbtbrt/IPOSendT/_商標電子送件區/web02";
            //} else {
            //    return "/nbtbrt/IPOSendT/_商標電子送件區";
            //}
        }
    }
    #endregion

    #region Path2Nbtbrt - 檔案路徑轉換(檢視＆複製檔案用)，brbrt→nbtbrt
    /// <summary>
    /// 檔案路徑轉換(檢視＆複製檔案用)，brbrt→nbtbrt
    /// </summary>
    public static string Path2Nbtbrt(string path) {
        //path = path.Replace("/", @"\");
        //path = path.Replace(@"\btbrt\", @"\nbtbrt\");
        path = path.Replace(@"\", @"/");
        path = path.Replace("/btbrt/", Sys.GetRootDir() + "/");
        path = Regex.Replace(path, "D:/Data/document/", Sys.GetRootDir() + "/", RegexOptions.IgnoreCase);
        return path;
    }
    #endregion

    #region Path2Btbrt - 檔案路徑轉換(寫入DB用)，nbtbrt→brbrt
    /// <summary>
    /// 檔案路徑轉換(寫入DB用)，nbtbrt→brbrt
    /// </summary>
    public static string Path2Btbrt(string path) {
        path = path.Replace(@"\", "/");
        path = path.Replace(Sys.GetRootDir() + "/", "/btbrt/");
        return path;
    }
    #endregion

    #region Path2Nbrp - 檔案路徑轉換(檢視＆複製檔案用)，brp→nbrp
    /// <summary>
    /// 檔案路徑轉換(檢視＆複製檔案用)，brp→nbrp
    /// </summary>
    public static string Path2Nbrp(string path) {
        //path = path.Replace("/", @"\");
        //path = path.Replace(@"\brp\", @"\nbrp\");
        path = path.Replace(@"\", @"/");
        path = path.Replace("/brp/", "/nbrp/");
        path = Regex.Replace(path, "D:/Data/document/", "/nbrp/", RegexOptions.IgnoreCase);
        return path;
    }
    #endregion

    #region Path2Brp - 檔案路徑轉換(寫入DB用)，nbrp→brp
    /// <summary>
    /// 檔案路徑轉換(寫入DB用)，nbrp→brp
    /// </summary>
    public static string Path2Brp(string path) {
        path = path.Replace(@"\nbrp\", @"/brp/");
        path = path.Replace(@"/nbrp/", @"/brp/");
        path = path.Replace(@"\", "/");
        return path;
    }
    #endregion

    #region Path2MG - 檔案路徑轉換(檢視總收發文檔案用)，/nbtbrt/ → /MG/
    /// <summary>
    /// 檔案路徑轉換(檢視總收發文檔案用)，/nbtbrt/ → /MG/
    /// </summary>
    public static string Path2MG(string path) {
        //path = path.Replace(Sys.GetRootDir() + "/", "/MG/");
        path = Regex.Replace(path, Sys.GetRootDir() + "/", "/MG/", RegexOptions.IgnoreCase);
        return path;
    }
    #endregion

    #region PathMG2Nbtbrt - 檔案路徑轉換(檢視總收發文檔案用,轉換為本機路徑)，/MG/ → /nbtbrt/
    /// <summary>
    /// 檔案路徑轉換(檢視總收發文檔案用,轉換為本機路徑)，/MG/ → /nbtbrt/
    /// </summary>
    public static string PathMG2Nbtbrt(string path) {
        //path = path.Replace("/MG/", Sys.GetRootDir() + "/");
        path = Regex.Replace(path, "/MG/", Sys.GetRootDir() + "/", RegexOptions.IgnoreCase);
        return path;
    }
    #endregion

    #region Path2Opt - 檔案路徑轉換(寫入DB用)，nopt→opt
    /// <summary>
    /// 檔案路徑轉換(寫入DB用)，nopt→opt
    /// </summary>
    public static string Path2Opt(string path) {
        path = path.Replace(@"\nopt\", @"/opt/");
        path = path.Replace(@"/nopt/", @"/opt/");
        path = path.Replace(@"\", "/");
        return path;
    }
    #endregion

    #region Path2Nopt - 檔案路徑轉換(檢視＆複製檔案用)，opt→nopt
    /// <summary>
    /// 檔案路徑轉換(檢視＆複製檔案用)，opt→nopt
    /// </summary>
    public static string Path2Nopt(string path) {
        path = path.Replace(@"\", @"/");
        path = path.Replace("/opt/", "/nopt/");
        return path;
    }
    #endregion

    #region getFileServer - 取得檔案上傳相關設定
    /// <summary>
    /// 取得檔案上傳相關設定
    /// </summary>
    public void getFileServer(string pbrBranch, string prgid) {
        switch (Host) {
            case "web08": case "localhost"://開發環境
                gbrFileServerName = "web08";
                gFileServerName = "web08";
                break;
            case "web10"://測試環境
                gbrFileServerName = "web10";
                gFileServerName = "web10";
                break;
            default: //正式環境
                if (pbrBranch.ToUpper() == "N") gbrFileServerName = "sinn11";
                if (pbrBranch.ToUpper() == "C") gbrFileServerName = "sic11";
                if (pbrBranch.ToUpper() == "S") gbrFileServerName = "sis11";
                if (pbrBranch.ToUpper() == "K") gbrFileServerName = "sik11";
                gFileServerName = "sin31";
                break;
        }

        gDir = @"\\" + gFileServerName + @"\FTE_file";

        if (prgid.Left(3).ToLower() == "brt") {
            gbrWebDir = Sys.GetRootDir() + "/" + pbrBranch + "T";
            gbrDir = @"\\" + gbrFileServerName + @"\" + pbrBranch + "T";
            gWebDir = "";
        } else {
            gbrWebDir = Sys.GetRootDir() + "/" + pbrBranch + "TE";
            gbrDir = @"\\" + gbrFileServerName + @"\" + pbrBranch + "TE";
            gWebDir = "/Fext/FTE_File";//國外所改.net時要改project name
        }
        gbrDbDir = Sys.GetRootDir() + "/brdb_file";
        gcustDbDir = Sys.GetRootDir() + "/custdb_file";
    }
    #endregion

    #region CreateFolder - 檢查目錄是否存在,若不存在則建立
    /// <summary>
    /// 檢查目錄是否存在,若不存在則建立
    /// </summary>
    /// <param name="strFolder">虛擬路徑 ex./nbtbrt/NT/temp/N/3/23/55</param>
    public static void CreateFolder(string strFolder) {
        if (!System.IO.Directory.Exists(HttpContext.Current.Server.MapPath(strFolder))) {
            //新增資料夾
            System.IO.Directory.CreateDirectory(HttpContext.Current.Server.MapPath(strFolder));
        }
    }
    #endregion

    #region CheckFile - 檢查檔案是否存在
    /// <summary>
    /// 檢查檔案是否存在
    /// </summary>
    /// <param name="strFath">虛擬路徑 ex./btbrt/Nt/doc/case/20111003015-6.doc</param>
    public static bool CheckFile(string strFath) {
        return File.Exists(HttpContext.Current.Server.MapPath(strFath));
    }
    #endregion

    #region RenameFile - 檔案重新命名
    /// <summary>
    /// 檔案重新命名(傳入虛擬路徑)
    /// </summary>
    /// <param name="srcFile">原始路徑(虛擬路徑)</param>
    /// <param name="dstFile">目的路徑(虛擬路徑)</param>
    /// <param name="backupFlag">檔案衝突時是否備份舊檔</param>
    public static void RenameFile(string srcFile, string dstFile, bool backupFlag) {
        System.IO.FileInfo sFi = new System.IO.FileInfo(HttpContext.Current.Server.MapPath(srcFile));
        System.IO.FileInfo dFi = new System.IO.FileInfo(HttpContext.Current.Server.MapPath(dstFile));
        string backup_name = String.Format("{0}_{1}-{2}{3}"
                                            , Path.GetFileNameWithoutExtension(dFi.Name)
                                            , DateTime.Now.ToString("yyyyMMddHHmmss")
                                            , Sys.GetSession("scode")
                                            , dFi.Extension);
        if (HttpContext.Current.Request["chkTest"] != "TEST") {
            //來源跟目的不同時才要搬,否則會出錯
            if (sFi.FullName.ToLower() != dFi.FullName.ToLower()) {
                if (dFi.Exists && backupFlag) {//檔案有衝突,備份原檔
                    dFi.CopyTo(dFi.DirectoryName + "\\" + backup_name,true);
                    sFi.CopyTo(dFi.FullName,true);
                    sFi.Delete();
                } else if (dFi.Exists && !backupFlag) {//檔案有衝突,直接覆蓋
                    dFi.Delete();
                    sFi.MoveTo(dFi.FullName);
                } else {
                    sFi.MoveTo(dFi.FullName);
                }
            }
        } else {
            HttpContext.Current.Response.Write("來源=" + sFi.FullName + "<BR>");
            HttpContext.Current.Response.Write("目的=" + dFi.FullName + "<BR>");
            if (sFi.FullName.ToLower() != dFi.FullName.ToLower()) {
                HttpContext.Current.Response.Write("衝突備份=" + dFi.DirectoryName + "\\" + backup_name + "<HR>");
            }
            //來源跟目的不同時才要搬,否則會出錯
            //測試模式不搬動.只複製檔案
            if (sFi.FullName.ToLower() != dFi.FullName.ToLower()) {
                if (dFi.Exists) {
                    dFi.CopyTo(dFi.DirectoryName + "\\" + backup_name, true);
                    sFi.CopyTo(dFi.FullName, true);
                } else {
                    sFi.CopyTo(dFi.FullName);
                }
            }
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
            string attach_no = (context.Request["attach_no_" + k] ?? "").Trim();//序號
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
                        Sys.RenameFile(attach_path + "/" + straa, attach_path + "/" + attach_name, true);
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
                            Sys.RenameFile(attach_path + "/" + straa, attach_path + "/" + attach_name, true);
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
                    conn.ExecuteNonQuery(SQL);
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
