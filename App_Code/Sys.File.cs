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
    /// 區所對催帳客函的虛擬路徑ex./nbtbrt/custdb_file
    /// </summary>
    public string gcustDbDir = "";

    /// <summary>
    /// 取得server name設定
    /// </summary>
    public void getFileServer(string pbrBranch) {
        getFileServer(pbrBranch, "");
    }

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

    /// <summary>
    /// 取得備份檔案名稱
    /// </summary>
    /// <param name="strFile">原始檔名</param>
    /// <returns></returns>
    public static string getBackupFile(string strFile) {
        string tfile_back = "";
        int n = strFile.LastIndexOf(".");   //副檔名的起始位置
        tfile_back = strFile.Substring(0, n) + "_" + DateTime.Now.ToString("yyyyMMddhhmmss") + "-" + HttpContext.Current.Session["scode"] + strFile.Substring(n);
        return tfile_back;
    }
}
