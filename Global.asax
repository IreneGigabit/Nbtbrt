<%@ Application Language="C#" %>
<%@Import Namespace = "System.Data"%>
<%@Import Namespace = "System.Data.SqlClient"%>

<script runat="server">
	void Application_Start(object sender, EventArgs e) {
		// 應用程式啟動時執行的程式碼
	}

	void Application_End(object sender, EventArgs e) {
		//  應用程式關閉時執行的程式碼
	}

	void Application_Error(object sender, EventArgs e) {
		// 發生未處理錯誤時執行的程式碼
		//Exception ex = Server.GetLastError();
		//server_code.exceptionLog(ex);//寫入LOG
	}

	void Session_Start(object sender, EventArgs e) {
		// 啟動新工作階段時執行的程式碼
		//案件系統
		switch (Request.ServerVariables["HTTP_HOST"].ToString().ToUpper()) {
			case "WEB10":
				Session["btbrtdb"] = System.Configuration.ConfigurationManager.ConnectionStrings["test_N_btbrtdb"].ToString();//使用者測試環境
                Session["sysctrl"] = System.Configuration.ConfigurationManager.ConnectionStrings["test_sysctrl"].ToString();
                Session["account"] = System.Configuration.ConfigurationManager.ConnectionStrings["test_account"].ToString();
				break;
			case "SINN05":
				Session["btbrtdb"] = System.Configuration.ConfigurationManager.ConnectionStrings["prod_N_btbrtdb"].ToString();//正式環境
                Session["sysctrl"] = System.Configuration.ConfigurationManager.ConnectionStrings["prod_sysctrl"].ToString();//台北所連到sin33
                Session["account"] = System.Configuration.ConfigurationManager.ConnectionStrings["prod_N_account"].ToString();
				break;
			case "SIC10":
				Session["btbrtdb"] = System.Configuration.ConfigurationManager.ConnectionStrings["prod_C_btbrtdb"].ToString();//正式環境
                Session["sysctrl"] = System.Configuration.ConfigurationManager.ConnectionStrings["prod_C_sysctrl"].ToString();
                Session["account"] = System.Configuration.ConfigurationManager.ConnectionStrings["prod_C_account"].ToString();
				break;
			case "SIS10":
				Session["btbrtdb"] = System.Configuration.ConfigurationManager.ConnectionStrings["prod_S_btbrtdb"].ToString();//正式環境
                Session["sysctrl"] = System.Configuration.ConfigurationManager.ConnectionStrings["prod_S_sysctrl"].ToString();
                Session["account"] = System.Configuration.ConfigurationManager.ConnectionStrings["prod_S_account"].ToString();
				break;
			case "SIK10":
				Session["btbrtdb"] = System.Configuration.ConfigurationManager.ConnectionStrings["prod_K_btbrtdb"].ToString();//正式環境
                Session["sysctrl"] = System.Configuration.ConfigurationManager.ConnectionStrings["prod_K_sysctrl"].ToString();
                Session["account"] = System.Configuration.ConfigurationManager.ConnectionStrings["prod_K_account"].ToString();
				break;
			default:
				Session["btbrtdb"] = System.Configuration.ConfigurationManager.ConnectionStrings["dev_btbrtdb"].ToString();//開發環境
                Session["sysctrl"] = System.Configuration.ConfigurationManager.ConnectionStrings["dev_sysctrl"].ToString();
                Session["account"] = System.Configuration.ConfigurationManager.ConnectionStrings["dev_account"].ToString();
				break;
		}

		Session["UserID"] = Session.SessionID.ToString();
	}

	void Session_End(object sender, EventArgs e) {
		// 工作階段結束時執行的程式碼。 
		// 注意: 只有在 Web.config 檔將 sessionstate 模式設定為 InProc 時，
		// 才會引發 Session_End 事件。如果將工作階段模式設定為 StateServer 
		// 或 SQLServer，就不會引發這個事件。
	}
</script>
