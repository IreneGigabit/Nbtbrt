using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

/// <summary>
/// 連線字串設定
/// </summary>
public static class Conn
{
    /// <summary>
    /// IIS主機名(大寫)
    /// </summary>
    private static string Host = HttpContext.Current.Request.ServerVariables["HTTP_HOST"].ToString().ToUpper();

	/// <summary>
	/// 案件管理系統
	/// </summary>
    public static string btbrt {
        get {
            switch (Host) {
                case "SINN05": return Sys.getConnString("prod_N_btbrtdb");//正式環境北
                case "SIC10": return Sys.getConnString("prod_C_btbrtdb");//正式環境中
                case "SIS10": return Sys.getConnString("prod_S_btbrtdb");//正式環境南
                case "SIK10": return Sys.getConnString("prod_K_btbrtdb");//正式環境雄
                case "WEB10": return Sys.getConnString("test_btbrtdb");//使用者測試環境
                default: return Sys.getConnString("dev_btbrtdb");//開發環境
            }
        }
	}

    /// <summary>
    /// Sysctrl
    /// </summary>
    public static string Sysctrl {
        get {
            switch (Host) {
                case "SINN05": return Sys.getConnString("prod_N_sysctrl");//正式環境北
                case "SIC10": return Sys.getConnString("prod_C_sysctrl");//正式環境中
                case "SIS10": return Sys.getConnString("prod_S_sysctrl");//正式環境南
                case "SIK10": return Sys.getConnString("prod_K_sysctrl");//正式環境雄
                case "WEB10": return Sys.getConnString("test_sysctrl");//使用者測試環境
                default: return Sys.getConnString("dev_sysctrl");//開發環境
            }
        }
    }

    /// <summary>
    /// ODBCDSN(for系統管理用，EX:權限，台北所指向總所sysctrl)
    /// </summary>
    public static string ODBCDSN {
        get {
            switch (Host) {
                case "SINN05": return Sys.getConnString("prod_mg_sysctrl");//正式環境北
                case "SIC10": return Sys.getConnString("prod_Csysctrl");//正式環境中
                case "SIS10": return Sys.getConnString("prod_Ssysctrl");//正式環境南
                case "SIK10": return Sys.getConnString("prod_Ksysctrl");//正式環境雄
                case "WEB10": return Sys.getConnString("test_mg_sysctrl");//使用者測試環境
                default: return Sys.getConnString("dev_mg_sysctrl");//開發環境
            }
        }
    }

    /// <summary>
    /// 雙邊代理查照
    /// </summary>
    public static string sidbs {
        get {
            switch (Host) {
                case "WEB08": return Sys.getConnString("dev_sidbs");//開發環境
                case "WEB10": return Sys.getConnString("test_sidbs");//使用者測試環境
                default: return Sys.getConnString("prod_sidbs");//正式環境
            }
        }
    }

}
