﻿<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Linq"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<script runat="server">
    protected string HTProgCap = "國內交辦案主管簽核作業";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string HTProgPrefix = "brt31";//程式檔名前綴
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";

    protected string SQL = "";
    
    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected Paging page = null;

    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";
    protected string FormName = "";
    
    protected string apcode = "";
    protected string qs_dept = "";
    
    protected string job_grpid = "";//原始簽核者的Grpid
    protected string job_grplevel = "";//原始簽核者的Grplevel

    protected string rdoYY = "";//簽准
    protected string rdoXX = "";//不准退回
    protected string rodYT = "";//轉上級簽核

    protected string txtSMaster = "", txtSMastercode="", selManager = "", txt_agentNm = "無", txt_agentNo = "", selPrScode = "", selAccScode = "";

    DBHelper cnn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    private void Page_Unload(System.Object sender, System.EventArgs e) {
        if (cnn != null) cnn.Dispose();
    }

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        cnn = new DBHelper(Conn.Sysctrl).Debug(Request["chkTest"] == "TEST");
        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");

        qs_dept=(Request["qs_dept"]??"").ToLower();

        Sys.getScodeGrpid(Sys.GetSession("seBranch"), Request["job_scode"], ref job_grpid, ref job_grplevel);
        
        if (qs_dept =="t"){
           HTProgCode="brt31";
           HTProgCap = "國內案主管簽核作業";
           apcode = "'Si04W02','brt31'";//改版後有新舊代碼
        }else{
            HTProgCode="ext34";
            HTProgCap = "出口案主管簽核作業";
            apcode = "'Si04W06','ext34'";//改版後有新舊代碼
        }
        
        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        HTProgCap = myToken.Title;
        DebugStr = myToken.DebugStr;
        if (HTProgRight >= 0) {
            PageLayout();
            QueryData();
            this.DataBind();
        }
    }

    private void PageLayout() {
        StrFormBtnTop += "<a href=" + HTProgPrefix + ".aspx?qs_dept=" + qs_dept + "&prgid=" + prgid + ">[回查詢]</a>";

        if (qs_dept == "t") {
            FormName = "備註:<br>\n";
			FormName += "1.案件編號前的「<img src=\""+Page.ResolveUrl("~/images/todolist01.jpg")+"\" style=\"cursor:pointer\" align=\"absmiddle\"  border=\"0\">」表示結案/復案。<br>\n";
			FormName += "2.契約書後補先行客收，主管簽核流程：組主管→部門主管→區所主管→程序客收。<br>\n";
			FormName += "3.折扣低於8折或低於7折且收費標準服務費<=5000，主管簽核流程：組主管→部門主管→區所主管→程序客收。<br>\n";
			FormName += "4.折扣低於7折且收費標準服務費>5000，主管簽核流程：組主管→部門主管→區所主管→商標經理→程序客收。<br>\n";
            FormName += "◎ 簽核:<br>\n";
            FormName += "「2」表組主管→部門主管→程序客收； <br>\n";
            FormName += "「1」表組主管→部門主管→區所主管→程序客收； <br>\n";
            FormName += "「0」表組主管→部門主管→區所主管→商標經理→程序收文；<br>\n";
        } else {
			FormName = "備註:<br>\n";
			FormName += "1.案性前的「<img src=\""+Page.ResolveUrl("~/images/todolist01.jpg")+"\" style=\"cursor:pointer\" align=\"absmiddle\"  border=\"0\">」表示無收費標準。<br>\n";
			FormName += "2.案件編號前的「<img src=\""+Page.ResolveUrl("~/images/todolist01.jpg")+"\" style=\"cursor:pointer\" align=\"absmiddle\"  border=\"0\">」表示結案/復案。<br>\n";
			FormName += "3.點選請款註記「<font color=red>D</font>」扣收入，可查詢該案件交辦扣收入明細資料，點選「<font color=\"#9966cc\">個</font>」可查詢<font color=red>個案明細</font>。<br>\n";
            FormName += "4.接洽序號前的「<img src=\"" + Page.ResolveUrl("~/images/back03.jpg") + "\">」表示會計認為本筆扣收入異常，「<img src=\"" + Page.ResolveUrl("~/images/ok.gif") + "\">」表示會計已完成<font color=red>扣收入</font>檢核，請點選該圖示查詢會計檢核說明後再簽核。<br>\n";
			FormName += "5.契約書後補先行客收，主管簽核流程：組主管→部門主管→區所主管→程序客收。<br>\n";
			FormName += "6.折扣低於8折，主管簽核流程：組主管→部門主管→區所主管→程序客收。<br>\n";
			FormName += "7.折扣低於7折，主管簽核流程：組主管→部門主管→區所主管→商標經理→程序客收。<br>\n";
            FormName += "◎ 簽核:<br>\n";
            FormName += "「2」表組主管→部門主管→程序客收； <br>\n";
            FormName += "「1」表組主管→部門主管→區所主管→程序客收； <br>\n";
            FormName += "「11」表組主管→部門主管→區所會計檢核→區所主管→程序客收； <br>\n";
            FormName += "「0」表組主管→部門主管→區所主管→商標經理→程序收文； <br>\n";
            FormName += "「01」表組主管→部門主管→區所會計檢核→區所主管→商標經理→程序收文； <br>\n";
        }

        DataTable MasterList = Sys.getMasterList(Sys.GetSession("seBranch"), Request["job_scode"], false);
        //MasterList.ShowTable();
        
        //轉上級人員
        if (job_grplevel == "") {//執委
            job_grplevel = "-1";
            txtSMaster = "";
            txtSMastercode = "";
        } else if (job_grplevel == "0") {//專商經理
            txtSMaster = "";
            txtSMastercode = "";
        } else if (job_grplevel == "1") {//區所主管
            txtSMaster = "專商經理:" + MasterList.Select("grplevel=0")[0]["master_nm"];
            txtSMastercode = MasterList.Select("grplevel=0")[0]["Master_scode"].ToString();
            txt_agentNo = MasterList.Select("grplevel=0")[0]["Agent_scode"].ToString();
            txt_agentNm = MasterList.Select("grplevel=0")[0]["agent_nm"].ToString();
        } else if (job_grplevel == "2") {//商標主管
            txtSMaster = "區所主管:" + MasterList.Select("grplevel=1")[0]["master_nm"];
            txtSMastercode = MasterList.Select("grplevel=1")[0]["Master_scode"].ToString();
        } else {//組主管
            txtSMaster = "商標主管:" + MasterList.Select("grplevel<" + job_grplevel, "up_level")[0]["master_nm"];
            txtSMastercode = MasterList.Select("grplevel<" + job_grplevel, "up_level")[0]["Master_scode"].ToString();
        }
        selManager = MasterList.Select("grplevel<=0", "up_level").CopyToDataTable().Option("{Master_scode}", "{master_type}--{Master_nm}", false);//只抓專案室以上(含)
        
        //程序人員
        DataTable dtPrScode = new DataTable();
        if (qs_dept == "t") {
            dtPrScode = Sys.GetGrpidScode(Sys.GetSession("seBranch"), "T210", "A");
        } else {
            dtPrScode = Sys.GetGrpidScode(Sys.GetSession("seBranch"), "T220", "A");
        }
        selPrScode = dtPrScode.Option("{scode}", "{sc_name}", "", false,"", "grptype=F");
        
        //會計人員
        DataTable dtAccScode = Sys.getScodeRole(Sys.GetSession("SeBranch"), Sys.GetSession("syscode"), Sys.GetSession("dept"), "account");
        selAccScode = dtAccScode.Option("{scode}", "{sc_name}", false);

        if (Convert.ToInt32(job_grplevel) <= 2) {//部門主管以上預設簽准
            rdoYY = "checked";
            if (Convert.ToInt32(job_grplevel) <= 0) {//專商經理以上不用轉上級
                rodYT = "disabled";
            }
        } else {
            rdoYY = "disabled";
            rodYT = "checked";
        }

    }
    
    private void QueryData() {
        DataTable dt = new DataTable();
        using (DBHelper conn = new DBHelper(Conn.btbrt).Debug(false)) {
            if (qs_dept == "t") {
                SQL = "SELECT b.in_no,B.In_scode,B.arcase_type,B.arcase_class, ''mark1, A.in_date as step_date, A.ctrl_date, C.appl_name, B.Service, B.Fees,B.oth_money, B.ar_mark, B.arcase";
                SQL += ",ISNULL(B.Discount, 0) AS discount, B.Service + B.Fees + B.oth_money AS allcost,b.seq,b.seq1,b.remark,''country,b.contract_flag,b.contract_remark,b.discount_remark ";
                SQL += ",A.job_scode, A.sqlno, A.in_no, D.Rs_detail as CArcase,D.rs_class as ar_form,D.prt_code,e.sc_name, B.Cust_area, B.Cust_seq,B.case_no,'N'upload_chk,b.back_flag,b.end_flag,b.case_date";
                SQL += ",(select code_name from cust_code where code_type='ar_mark' and cust_code=b.ar_mark) as ar_marknm ";
                SQL += ",''link_remark,''fseq,''urlasp,0 T_Service,0 T_Fees,0 P_Service,0 P_Fees ";
                SQL += ",''ctrl_rowspan,''upload_flag,''armark_flag,''armarkT_flag,''dis_flag,''disT_flag,''chk_stat,''accdchk_flag,''tran_remark1,''sign_level,''sign_levelnm ";
                SQL += "FROM Case_dmt B ";
                SQL += "INNER JOIN dmt_temp C ON B.In_no = C.in_no AND B.In_scode = C.in_scode And c.case_sqlno=0 ";
                SQL += "INNER JOIN todo_dmt A ON B.In_no = A.in_no and b.in_scode=A.case_in_scode ";
                SQL += "INNER JOIN code_br D ON B.Arcase = D.Rs_code and d.cr='Y' and dept='T' and rs_type=b.arcase_type ";
                SQL += "INNER JOIN sysctrl.dbo.scode e ON B.In_scode = e.scode ";
                SQL += "WHERE (A.job_status = 'NN') and syscode= '" + Session["syscode"] + "' and apcode in(" + apcode + ") ";
            } else {
                SQL = "SELECT b.in_no,B.In_scode,B.arcase_type,B.arcase_class,B.mark1, A.in_date as step_date, A.ctrl_date, C.appl_name, B.tot_Service as service, B.tot_Fees as fees, isnull(B.oth_money,0) as oth_money,B.ar_mark, B.arcase";
                SQL += ",ISNULL(B.Discount, 0) AS discount, B.tot_Service + B.tot_Fees + B.tot_tax + isnull(B.oth_money,0) AS allcost,b.seq,b.seq1,c.country,b.contract_flag,b.contract_remark,b.discount_remark ";
                SQL += ",A.job_scode, A.sqlno, A.in_no, D.Rs_detail as CArcase,D.rs_class as ar_form,D.prt_code,e.sc_name, B.Cust_area, B.Cust_seq,B.case_no,B.upload_chk,b.back_flag,b.end_flag,b.case_date,c.remark1 ";
                SQL += ",(select code_name from cust_code where code_type='ar_mark' and cust_code=b.ar_mark) as ar_marknm ";
                SQL += ",''link_remark,''fseq,''urlasp,0 T_Service,0 T_Fees,0 P_Service,0 P_Fees ";
                SQL += ",''ctrl_rowspan,''upload_flag,''armark_flag,''armarkT_flag,''dis_flag,''disT_flag,''chk_stat,''accdchk_flag,''tran_remark1,''sign_level,''sign_levelnm ";
                SQL += "FROM Case_ext B ";
                SQL += "INNER JOIN ext_temp C ON B.In_no = C.in_no AND B.In_scode = C.in_scode and c.case_sqlno=0 ";
                SQL += "INNER JOIN todo_ext A ON B.In_no = A.in_no and b.in_scode=A.case_in_scode ";
                SQL += "INNER JOIN code_ext D ON B.Arcase = D.Rs_code and d.cr_flag='Y' and d.rs_type=b.arcase_type ";
                SQL += "INNER JOIN sysctrl.dbo.scode e ON B.In_scode = e.scode ";
                SQL += "WHERE (A.job_status = 'NN') and syscode='" + Session["syscode"] + "' and apcode in(" + apcode + ") ";
            }

            if (ReqVal.TryGet("job_scode") != "") {
                SQL += " AND (A.job_scode = '" + Request["job_scode"] + "')";
            } else {
                SQL += " AND (A.job_scode = '" + Session["scode"] + "')";
            }

            if (ReqVal.TryGet("scode") != "*" && ReqVal.TryGet("scode") != "") {
                SQL += " and b.in_scode = '" + Request["scode"] + "'";
            }
            if (ReqVal.TryGet("dtype") == "1") {
                SQL += " and A.ctrl_date between '" + Request["Sdate"] + "' and '" + Request["Edate"] + "'";
            }
            if (ReqVal.TryGet("dtype") == "2") {
                SQL += " and A.in_date between '" + Request["Sdate"] + " 00:00:00' and '" + Request["Edate"] + " 23:59:59'";
            }

            ReqVal["qryOrder"] = ReqVal.TryGet("SetOrder", ReqVal.TryGet("qryOrder"));
            if (ReqVal.TryGet("qryOrder") != "") {
                SQL += " order by " + ReqVal.TryGet("qryOrder");
            } else {
                SQL += " order by step_date";
            }
            Sys.showLog(SQL);
            conn.DataTable(SQL, dt);

            //處理分頁
            int nowPage = Convert.ToInt32(Request["GoPage"] ?? "1"); //第幾頁
            int PerPageSize = Convert.ToInt32(Request["PerPage"] ?? "10"); //每頁筆數
            page = new Paging(nowPage, PerPageSize, SQL);
            page.GetPagedTable(dt);

            //分頁完再處理其他資料才不會虛耗資源
            for (int i = 0; i < page.pagedTable.Rows.Count; i++) {
                DataRow dr=page.pagedTable.Rows[i];
                
                int ctrl_rowspan = 1;
                if (qs_dept == "t") {
                    SQL = "Select remark from cust_code where cust_code='__' and code_type='" + dr["arcase_type"] + "'";
                    object objResult = conn.ExecuteScalar(SQL);
                    string link_remark = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();
                    dr["link_remark"] = link_remark;//案性版本連結

                    dr["chk_stat"] = "N";
                    dr["accdchk_flag"] = "N";

                    if (dr.SafeRead("ar_mark", "") == "D") {
                        string remark1 = dr["remark"].ToString();
                        ctrl_rowspan += 1;
                        if (remark1 == "") {
                            //抓取交辦內容
                            SQL = "select tran_remark1 from dmt_tran where in_no='" + dr["in_no"] + "'";
                            objResult = conn.ExecuteScalar(SQL);
                            remark1 = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();
                        }
                        dr["tran_remark1"] = remark1;//扣收入原因
                    }

                    if (dr.SafeRead("discount_remark", "") != "") {
                        ctrl_rowspan += 1;
                    }

                    //抓取收費標準
                    int T_Service = 0;//交辦服務費
                    int T_Fees = 0;//交辦規費
                    int P_Service = 0;//服務費收費標準
                    int P_Fees = 0;//規費收費標準
                    SQL = "select a.item_service as case_service,a.item_fees as case_fees, service*item_count as fee_service,fees*item_count AS fee_Fees ";
                    SQL += "from caseitem_dmt a ";
                    SQL += "inner join case_fee b on a.item_arcase=b.rs_code ";
                    SQL += "where a.in_no='" + dr.SafeRead("in_no", "") + "' ";
                    SQL += "and b.dept='T' and b.country='T' and '" + dr.GetDateTimeString("case_date", "yyyy/MM/dd HH:mm:ss") + "' between b.beg_date and b.end_date ";
                    using (SqlDataReader dr0 = conn.ExecuteReader(SQL)) {
                        if (dr0.Read()) {
                            T_Service += dr0.SafeRead("case_service", 0);
                            P_Service += dr0.SafeRead("Fee_service", 0);
                            T_Fees += dr0.SafeRead("Case_Fees", 0);
                            P_Fees += dr0.SafeRead("Fee_Fees", 0);
                        }
                    }
                    dr["T_Service"] = T_Service;
                    dr["T_Fees"] = T_Fees;
                    dr["P_Service"] = P_Service;
                    dr["P_Fees"] = P_Fees;
                    dr["fseq"] = Sys.formatSeq(dr.SafeRead("seq", ""), dr.SafeRead("seq1", ""), "", "", "");
                } else {

                }

                if (dr.SafeRead("contract_flag", "") == "") {
                    dr["contract_flag"] = "N";//契約書後補註記
                }

                //dr["urlasp"] = GetLink(dr);
                dr["urlasp"] = Sys.getCaseDmt11Aspx(prgid, dr.SafeRead("in_no", ""), dr.SafeRead("in_scode", ""), "Show");
                dr["ctrl_rowspan"] = ctrl_rowspan;

                //簽准層級grplevel=2部門主管→11會計→1區所主管→0商標經理
                string upload_flag = "N";//專案請核單upload_chk=Y需經商標經理簽准
                string armark_flag = "N";//扣收入ar_mark=D需經會計檢核
                string armarkT_flag = "N";//扣收入ar_mark=D且金額>=5000需經商標經理簽准
                string contract_flag = "N";//契約書後補contract_flag=Y需經區所主管簽准
                string dis_flag = "N";//折扣簽核dis_flag=Y低於8折或低於7折且服務費<=5000需經區所主管簽准
                string disT_flag = "N";//折扣簽核disT_flag=Y低於7折或國內案低於7折且服務費>5000需經商標經理簽准
                if (dr.SafeRead("upload_chk", "") == "Y") {//專案請核單upload_chk=Y需經商標經理簽准
                    upload_flag = "Y";//0
                }
                if (Convert.ToDecimal(dr["discount"]) > 20) {//折扣低於8折需經區所主管簽准
                    dis_flag = "Y";
                    if (Convert.ToDecimal(dr["discount"]) > 30 && Convert.ToDecimal(dr["P_Service"]) > 5000) {//折扣低於7折且服務費>5000需經商標經理簽准
                        disT_flag = "Y";
                    }
                }
                if (qs_dept=="e") {//出口案才有扣收入流程
                    if (dr.SafeRead("ar_mark", "") == "D") {//扣收入需經會計檢核
                        armark_flag = "Y";//11
                        if (Convert.ToDecimal(dr.SafeRead("fees", "")) > 5000) {//扣收入且規費>5000需經商標經理簽准
                            armarkT_flag = "Y";//0
                        }
                    }
                }
                if (dr.SafeRead("contract_flag", "") == "Y") {//契約書後補需經區所主管簽准
                    contract_flag = "Y";//1
                }
                
                dr["upload_flag"] = upload_flag;
                dr["armark_flag"] = armark_flag;
                dr["armarkT_flag"] = armarkT_flag;
                dr["dis_flag"] = dis_flag;
                dr["disT_flag"] = disT_flag;

                //計算簽核層級,並檢查簽准層級=交辦營洽則再往上一級
                string sign_level = "", sign_levelnm="";
                DataTable MasterList = Sys.getMasterList(Sys.GetSession("seBranch"), dr.SafeRead("in_scode", ""), false);
                if (upload_flag == "Y" || disT_flag == "Y" || armarkT_flag == "Y") {
                    sign_level = "0";//商標經理
                } else if (armarkT_flag == "Y") {
                    sign_level = "01";//商標經理(會計)
                } else if (contract_flag == "Y" || dis_flag == "Y") {
                    sign_level = "1";//區所主管
                    if (dr.SafeRead("in_scode", "") == MasterList.Select("grplevel=1")[0]["master_scode"]) {
                        sign_level = "0";//商標經理
                    }
                } else if (armark_flag == "Y") {
                    sign_level = "11";//區所主管(會計)
                    if (dr.SafeRead("in_scode", "") == MasterList.Select("grplevel=1")[0]["master_scode"]) {
                        sign_level = "0";//商標經理
                    }
                } else {
                    sign_level = "2";//部門主管
                    if (dr.SafeRead("in_scode", "") == MasterList.Select("grplevel=2")[0]["master_scode"]) {
                        sign_level = "1";//區所主管
                    }
                }
                switch (sign_level) {
                    case "2": sign_levelnm = "2"; break;
                    case "1": sign_levelnm = "1"; break;
                    case "11": sign_levelnm = "11"; break;
                    case "0": sign_levelnm = "0"; break;
                    case "01": sign_levelnm = "01"; break;
                }
                dr["sign_level"] = sign_level;
                dr["sign_levelnm"] = sign_levelnm;
            }

            dataRepeater.DataSource = page.pagedTable;
            dataRepeater.DataBind();
        }
    }

    //protected string GetLink(DataRow row) {
    //    string urlasp = "";//連結的url
    //    string new_form = Sys.getCaseDmtAspx(row.SafeRead("arcase_type", ""), row.SafeRead("arcase", ""));//連結的aspx
    //    urlasp = Page.ResolveUrl("~/brt1m" + row["link_remark"] + "/Brt11Edit" + new_form + ".aspx?prgid=" + prgid);
    //    urlasp += "&in_scode=" + row["in_scode"];
    //    urlasp += "&in_no=" + row["in_no"];
    //    urlasp += "&add_arcase=" + row["arcase"];
    //    urlasp += "&cust_area=" + row["cust_area"];
    //    urlasp += "&cust_seq=" + row["cust_seq"];
    //    urlasp += "&ar_form=" + row["ar_form"];
    //    urlasp += "&new_form=" + new_form;
    //    urlasp += "&code_type=" + row["arcase_type"];
    //    urlasp += "&homelist=" + Request["homelist"];
    //    urlasp += "&uploadtype=case";
    //    urlasp += "&submittask=Show";
    //    
    //    return urlasp;
    //}

    protected string GetArMark(RepeaterItem Container) {
        string rtn = "";
        if (Eval("ar_mark").ToString() == "D") {
            rtn += "<font class='txtlink' onclick=\"markdlist_from_onclick('" + Eval("seq") + "','" + Eval("seq1") + "','" + Eval("country") + "','" + Eval("case_no") + "')\" title='" + Eval("Ar_marknm") + "明細查詢'>" + Eval("Ar_mark") + "</font>\n";
            if (qs_dept == "e") {
                rtn += "<input type=button id='btnaccseq' value='個' class='c1button' style='cursor:pointer' title='個案明細查詢' onclick=\"accseq_from_onclick('" + Eval("seq") + "','" + Eval("seq1") + "','" + Eval("country") + "')\">\n";
            }
        } else {
            rtn += "<span title=" + Eval("Ar_marknm") + " style='cursor:pointer;color:red'>" + Eval("Ar_mark") + "</span>";
        }
        return rtn;
    }
    
    protected void rpt_ItemDataBound(object sender, RepeaterItemEventArgs e) {
        if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem) {
            HtmlGenericControl backIcon = (HtmlGenericControl)e.Item.FindControl("backIcon");
            HtmlGenericControl accdIcon = (HtmlGenericControl)e.Item.FindControl("accdIcon");
            HtmlTableRow armarkRow = (HtmlTableRow)e.Item.FindControl("armarkRow");
            HtmlTableRow discountRow = (HtmlTableRow)e.Item.FindControl("discountRow"); 
            DataRowView drv = e.Item.DataItem as DataRowView;
            if (drv != null) {
                if (drv.Row["chk_stat"].ToString() == "Y")
                    backIcon.Visible = true;
                else
                    backIcon.Visible = false;

                if (drv.Row["accdchk_flag"].ToString() == "Y")
                    accdIcon.Visible = true;
                else
                    accdIcon.Visible = false;

                if (drv.Row["ar_mark"].ToString() == "D")
                    armarkRow.Visible = true;
                else
                    armarkRow.Visible = false;

                if (drv.Row["discount_remark"].ToString() != "")
                    discountRow.Visible = true;
                else
                    discountRow.Visible = false;
            }
        }
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title><%=HTProgCap%></title>
    <uc1:head_inc_form runat="server" ID="head_inc_form" />
</head>

<body>
<table cellspacing="1" cellpadding="0" width="98%" border="0" align="center">
    <tr>
        <td class="text9" nowrap="nowrap">&nbsp;【<%=prgid%> <%=HTProgCap%>】</td>
        <td class="FormLink" valign="top" align="right" nowrap="nowrap">
            <%#StrFormBtnTop%>
        </td>
    </tr>
    <tr>
        <td colspan="2"><hr class="style-one"/></td>
    </tr>
</table>

<form style="margin:0;" id="regPage" name="regPage" method="post">
    <%#page.GetHiddenText("GoPage,PerPage,SetOrder,chktest")%>
    <div id="divPaging" style="display:<%#page.totRow==0?"none":""%>">
    <TABLE border=0 cellspacing=1 cellpadding=0 width="98%" align="center">
	    <tr>
		    <td colspan=2 align=center>
			    <font size="2" color="#3f8eba">
				    第<font color="red"><span id="NowPage"><%#page.nowPage%></span>/<span id="TotPage"><%#page.totPage%></span></font>頁
				    | 資料共<font color="red"><span id="TotRec"><%#page.totRow%></span></font>筆
				    | 跳至第
				    <select id="GoPage" name="GoPage" style="color:#FF0000"><%#page.GetPageList()%></select>
				    頁
				    <span id="PageUp" style="display:<%#page.nowPage>1?"":"none"%>">| <a href="javascript:void(0)" class="pgU" v1="<%#page.nowPage-1%>">上一頁</a></span>
				    <span id="PageDown" style="display:<%#page.nowPage<page.totPage?"":"none"%>">| <a href="javascript:void(0)" class="pgD" v1="<%#page.nowPage+1%>">下一頁</a></span>
				    | 每頁筆數:
				    <select id="PerPage" name="PerPage" style="color:#FF0000">
					    <option value="10" <%#page.perPage==10?"selected":""%>>10</option>
					    <option value="20" <%#page.perPage==20?"selected":""%>>20</option>
					    <option value="30" <%#page.perPage==30?"selected":""%>>30</option>
					    <option value="50" <%#page.perPage==50?"selected":""%>>50</option>
				    </select>
                    <input type="hidden" name="SetOrder" id="SetOrder" value="<%#ReqVal.TryGet("qryOrder")%>" />
			    </font><%#DebugStr%>
		    </td>
	    </tr>
    </TABLE>
    </div>
</form>

<div align="center" id="noData" style="display:<%#page.totRow==0?"":"none"%>">
	<font color="red">=== 目前無資料 ===</font>
</div>

<form style="margin:0;" id="reg" name="reg" method="post">
<asp:Repeater id="dataRepeater" runat="server" OnItemDataBound="rpt_ItemDataBound">
<HeaderTemplate>
    <input type=hidden id="GrpID" name="GrpID" value="<%=job_grpid%>"><!--原始簽核者的Grpid-->
    <input type=hidden id="grplevel" name="grplevel" value="<%=job_grplevel%>"><!--原始簽核者的層級-->
    <input type=hidden id="sign_level" name="sign_level" value=""><!--簽准層級-->
    <input type=hidden id="upload_flag" name="upload_flag" value="N"><!--專案請核單upload_chk=Y需經商標經理簽准-->
    <input type=hidden id="armark_flag" name="armark_flag" value="N"><!--扣收入ar_mark=D需經會計檢核-->
    <input type=hidden id="armarkT_flag" name="armarkT_flag" value="N"><!--扣收入ar_mark=D且金額>=5000需經商標經理簽准-->
    <input type=hidden id="contract_flag" name="contract_flag" value="N"><!--契約書後補contract_flag=Y需經區所主管簽准-->
    <input type=hidden id="dis_flag" name="dis_flag" value="N"><!--折扣簽核dis_flag=Y低於8折或低於7折且服務費<=5000需經區所主管簽准-->
    <input type=hidden id="disT_flag" name="disT_flag" value="N"><!--折扣簽核disT_flag=Y低於7折或國內案低於7折且服務費>5000需經商標經理簽准-->
    <input type=hidden id=row name=row value="<%#page.pagedTable.Rows.Count%>"> 

    <table style="display:<%#page.totRow==0?"none":""%>" border="0" class="bluetable" cellspacing="1" cellpadding="2" width="100%" align="center" id="dataList">
	    <thead>
            <Tr>
                <td align="center" class="lightbluetable" onclick="checkall()" style="cursor:pointer">全選</td>
	            <td align="center" class="lightbluetable">接洽序號</td>
	            <td align="center" class="lightbluetable">交辦單號</td>
	            <td align="center" class="lightbluetable">交辦日期</td>
	            <td align="center" class="lightbluetable">案件編號</td>
	            <td align="center" class="lightbluetable">國別</td>
	            <td align="center" class="lightbluetable">案件名稱</td>
	            <td align="center" class="lightbluetable">案性</td>
	            <td align="center" class="lightbluetable">服務費</td>
	            <td align="center" class="lightbluetable">規費</td>
	            <td align="center" class="lightbluetable">轉帳<br>費用</td>
	            <td align="center" class="lightbluetable">合計</td>
	            <td align="center" class="lightbluetable">折扣</td>
	            <td align="center" class="lightbluetable">請款<br>註記</td>
	            <td align="center" class="lightbluetable">簽核</td>
            </tr>
	    </thead>
	    <tbody>
</HeaderTemplate>
			<ItemTemplate>
 		        <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>">
		            <td align="center" rowspan=<%#Eval("ctrl_rowspan")%>>
                        <input type=checkbox id="C_<%#(Container.ItemIndex+1)%>" name="C_<%#(Container.ItemIndex+1)%>" value="Y" onclick="Chkupload('<%#(Container.ItemIndex+1)%>','<%#Eval("sign_level")%>')">
                		<input type=hidden id="code_<%#(Container.ItemIndex+1)%>" name="code_<%#(Container.ItemIndex+1)%>" value="<%#Eval("sqlno")%>">
		                <input type=hidden id="In_no_<%#(Container.ItemIndex+1)%>" name="In_no_<%#(Container.ItemIndex+1)%>" value="<%#Eval("In_no")%>">
		                <input type=hidden id="In_scode_<%#(Container.ItemIndex+1)%>" name="In_scode_<%#(Container.ItemIndex+1)%>" value="<%#Eval("In_scode")%>">
		                <input type=hidden id="Cust_area_<%#(Container.ItemIndex+1)%>" name="Cust_area_<%#(Container.ItemIndex+1)%>" value="<%#Eval("Cust_area")%>">
		                <input type=hidden id="Cust_seq_<%#(Container.ItemIndex+1)%>" name="Cust_seq_<%#(Container.ItemIndex+1)%>" value="<%#Eval("Cust_seq")%>">
		                <input type=hidden id="case_no_<%#(Container.ItemIndex+1)%>" name="case_no_<%#(Container.ItemIndex+1)%>" value="<%#Eval("case_no")%>">
		                <input type=hidden id="appl_name_<%#(Container.ItemIndex+1)%>" name="appl_name_<%#(Container.ItemIndex+1)%>" value="<%#Eval("appl_name")%>">
		                <input type=hidden id="case_arcase_<%#(Container.ItemIndex+1)%>" name="case_arcase_<%#(Container.ItemIndex+1)%>" value="<%#Eval("arcase")%>">
		                <input type=hidden id="case_name_<%#(Container.ItemIndex+1)%>" name="case_name_<%#(Container.ItemIndex+1)%>" value="<%#Eval("carcase")%>">
		                <input type=hidden id="upload_chk_<%#(Container.ItemIndex+1)%>" name="upload_chk_<%#(Container.ItemIndex+1)%>" value="<%#Eval("upload_flag")%>"><!--請核單上傳-->
		                <input type=hidden id="armark_flag_<%#(Container.ItemIndex+1)%>" name="armark_flag_<%#(Container.ItemIndex+1)%>" value="<%#Eval("armark_flag")%>"><!--扣收入註記-->
		                <input type=hidden id="armarkT_flag_<%#(Container.ItemIndex+1)%>" name="armarkT_flag_<%#(Container.ItemIndex+1)%>" value="<%#Eval("armarkT_flag")%>"><!--扣收入註記大於5000-->
		                <input type=hidden id="seq_<%#(Container.ItemIndex+1)%>" name="seq_<%#(Container.ItemIndex+1)%>" value="<%#Eval("seq")%>">
		                <input type=hidden id="seq1_<%#(Container.ItemIndex+1)%>" name="seq1_<%#(Container.ItemIndex+1)%>" value="<%#Eval("seq1")%>">
		                <input type=hidden id="country_<%#(Container.ItemIndex+1)%>" name="country_<%#(Container.ItemIndex+1)%>" value="<%#Eval("country")%>">
		                <input type=hidden id="fees_<%#(Container.ItemIndex+1)%>" name="fees_<%#(Container.ItemIndex+1)%>" value="<%#Eval("fees")%>"><!--規費-->
		                <input type=hidden id="contract_flag_<%#(Container.ItemIndex+1)%>" name="contract_flag_<%#(Container.ItemIndex+1)%>" value="<%#Eval("contract_flag")%>"><!--契約書後補註記-->
		                <input type=hidden id="dis_flag_<%#(Container.ItemIndex+1)%>" name="dis_flag_<%#(Container.ItemIndex+1)%>" value="<%#Eval("dis_flag")%>">
		                <input type=hidden id="disT_flag_<%#(Container.ItemIndex+1)%>" name="disT_flag_<%#(Container.ItemIndex+1)%>" value="<%#Eval("disT_flag")%>">
		            </td>
		            <td rowspan=<%#Eval("ctrl_rowspan")%> align="center"><!--接洽序號-->
                        <span id="backIcon" runat="server"><img src="<%=Page.ResolveUrl("~/images/back03.jpg")%>"></span>
                        <span id="accdIcon" runat="server"><img src="<%=Page.ResolveUrl("~/images/ok.gif")%>"style="cursor:pointer" onclick="accdchklist_from_onclick('<%#Eval("seq")%>','<%#Eval("seq1")%>','<%#Eval("country")%>','<%#Eval("case_no")%>')" title="會計檢核扣收入說明"></span>
				        <A href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("sc_name")%>-<%#Eval("in_no")%></A>
		            </td>
		            <td rowspan=<%#Eval("ctrl_rowspan")%> align="center"><!--交辦單號-->
                        <A href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("case_no")%>
                            <%#Eval("contract_flag").ToString()=="Y" ? "<br><font color=red>(契約書後補："+Eval("contract_remark")+")</font>":""%>
                        </A>
		            </td>
		            <td align="center"><!--交辦日期-->
                        <A href="<%#Page.ResolveUrl("~/Brt4m/brt13_ListA.aspx?prgid=" + prgid+"&in_scode="+Eval("in_scode")+"&in_no="+Eval("in_no")+"&qs_dept="+qs_dept)%>" target="Eblank">
                            <%#Eval("step_date", "{0: yyyy/MM/dd}")%>
                            <%#Eval("ctrl_date").ToString()!="" ? "<br><font size='2' color=red>("+Eval("ctrl_date")+")</font>":""%>
                        </A>
		            </td>
		            <td align="center"><!--案件編號-->
                        <A href="<%#Eval("urlasp")%>" target="Eblank">
                            <%#Eval("back_flag").ToString()=="Y"||Eval("end_flag").ToString()=="Y" ? "<img src=\""+Page.ResolveUrl("~/images/todolist01.jpg")+"\" style=\"cursor:pinter\" align=\"absmiddle\"  border=\"0\">":""%>
                            <%#Eval("fseq")%>
		                </A>
		            </td>
		            <td align="center"><A href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("country")%></A></td><!--國別-->
		            <td align="center"><A href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("appl_name")%></A></td><!--案件名稱-->
		            <td align="center"><A href="<%#Eval("urlasp")%>" target="Eblank"><!--案性-->
                        <%#Eval("mark1").ToString()=="N" ? "<img src=\""+Page.ResolveUrl("~/images/todolist01.jpg")+"\" style=\"cursor:pinter\" align=\"absmiddle\"  border=\"0\">":""%>
                        <%#Eval("CArcase")%>
		                </A>
		            </td>
		            <td align="center"><A href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("service")%></A></td><!--服務費-->
		            <td align="center"><A href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("fees")%></A></td><!--規費-->
		            <td align="center"><A href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("oth_money")%></A></td><!--轉帳費用-->
		            <td align="center"><A href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("allcost")%></TD><!--合計-->
		            <td align="center"><!--折扣-->
			            <A href="<%#Eval("urlasp")%>" target="Eblank">
                        <%#Convert.ToDecimal(Eval("discount"))>0 ? Eval("discount","{0:0.##}")+"%":""%>
		                </A>
                    </TD>
		            <td align="center"><%#GetArMark(Container)%></TD><!--請款註記-->
		            <td align="center"><A href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("sign_levelnm")%></A></TD><!--簽核-->
				</tr>
 		        <tr class='<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>' id="armarkRow" runat="server">
                    <td colspan=12>&nbsp;&nbsp;交辦說明：<A href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("tran_remark1")%></a></td>
                </tr>
  		        <tr class='<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>' id="discountRow" runat="server">
                    <td colspan=12>&nbsp;&nbsp;<font color=red>折扣理由：</font><A href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("discount_remark")%></a></td>
                </tr>
			</ItemTemplate>
<FooterTemplate>
	    </tbody>
    </table>
	<BR>
    <table style="display:<%#page.totRow==0?"none":""%>" border="0" width="100%" cellspacing="0" cellpadding="0">
		<tr class="FormName"><td><div align="left"><%#FormName%></div></td>
        </tr>
	</table>
	<br>

    <table style="display:<%#page.totRow==0?"none":""%>" border="0" width="90%" cellspacing="0" cellpadding="0" align="center">
		<TR>			
			<TD align=right>簽核狀態:</TD>
			<TD align=left>
					<input type=radio name="signid" value="YY" onclick=tosign() <%#rdoYY%>>簽准
					<input type=radio name="signid" value="XX" onclick=tosign() <%#rdoXX%>>不准退回
					<input type=radio name="signid" value="YT" onclick=tosign() <%#rodYT%>>轉上級簽核
					<input type=hidden name=signidnext id=signidnext>
					<input type=hidden name=status id=status>
			</TD>
			<TD align=right>
				<span style="" id="showsign1">
					程序人員：<select name="prscode" id="prscode"><%#selPrScode%></select>
				</span>
			</TD>
			<TD align=right>
				<span style="display:" id="showsign">
					<span id="spanMaster"><input type=radio name="upsign" value="sMaster"><%#txtSMaster%></span><input type=hidden value="<%=txtSMastercode%>" name="sMastercode" id="sMastercode">
                    <span id="spanManager"><input type=radio name="upsign" value="sManager"><select name="ma_scode" id="ma_scode"><%#selManager%></select></span>
                    <span id="spanAgent"><input type=radio name="upsign" value="sAgent">代理人:<%#txt_agentNm%><input type=hidden value="<%#txt_agentNo%>" name="sAgentcode" id="sAgentcode"><input type=hidden value="S" name=mark id=mark>	</span>
				</span>
			</TD>
			<TD align=right>
				<span style="display:" id="showsign2">
					會計人員：<select name="accscode" id="accscode"><%#selAccScode%></select>
				</span>
			</TD>
		</TR>
		<TR>
			<TD align=right>簽核說明:</TD>
			<TD align=left colspan=2><TEXTAREA name=signdetail id=signdetail ROWS=2 COLS=50></TEXTAREA></TD>
		</TR>
    </table>

    <table style="display:<%#page.totRow==0?"none":""%>" border="0" width="100%" cellspacing="0" cellpadding="0">
     <tr><td width="100%">     
       <p align="center">        
					<input type=hidden value="S" name=mark id=mark>	
            <input type=button value ="送出" class="cbutton bsubmit" onClick="formupdate()" id=btnsend name=btnsend>
            <input type=button value ="取消" class="cbutton" onClick="resetForm()" id=button4 name=button4>
     </td></tr>
    </table> 
</FooterTemplate>
</asp:Repeater>

    <%#DebugStr%>
</form>

<div id="dialog"></div>

</body>
</html>

<script language="javascript" type="text/javascript">
    $(function () {
        if (window.parent.tt !== undefined) {
            window.parent.tt.rows = "100%,0%";
        }

        $("input[name='signid']:checked").triggerHandler("click");
        $(".Lock").lock();
        $("input.dateField").datepick();
    });
    //執行查詢
    function goSearch() {
        $("#regPage").submit();
    };
    ///////////////////////////////////////////////////////////////
    //查案件扣收入交辦記錄 
    function markdlist_from_onclick(pseq,pseq1,pcountry,pcase_no){
        //***todo帳款
        var url = getRootPath() + "/brt3m/extform/markdlist_qry.aspx?prgid=<%=HTProgCode%>&seq=" + pseq +"&seq1=" + pseq1 + "&country=" + pcountry +"&case_no="+ pcase_no + "&qs_dept=<%=qs_dept%>";
        window.open(url,"mymarkdlistwin", "width=750px, height=550px, top=10, left=10, toolbar=no, menubar=no, location=no, directories=no, status=no,resizable=yes, scrollbars=yes");
    }
    //查案件扣收入會計檢核記錄
    function accdchklist_from_onclick(pseq,pseq1,pcountry,pcase_no){
        //***todo帳款
        var url = getRootPath() + "/brt3m/extform/accdchklist_qry.aspx?prgid=<%=HTProgCode%>&seq="+ pseq +"&seq1=" + pseq1 +  "&country=" + pcountry +"&case_no="+pcase_no + "&qs_dept=<%=qs_dept%>";
        window.open(url,"myaccdchklistwin", "width=750px, height=550px, top=10, left=10, toolbar=no, menubar=no, location=no, directories=no, status=no,resizable=yes, scrollbars=yes");
    }
    //個案明細表
    function accseq_from_onclick(pseq,pseq1,pcountry){
        var url = getRootPath() + "/brt4m/extform/accseqlist_qry.aspx?prgid=<%=HTProgCode%>&seq=" + pseq +"&seq1=" + pseq1 +  "&country=" + pcountry +"&closewin=Y";
        window.open(url,"myaccseqlistwin", "width=850px, height=550px, top=10, left=10, toolbar=no, menubar=no, location=no, directories=no, status=no,resizable=yes, scrollbars=yes");
    }

    //每筆交辦勾選時檢查簽核層級
    //tupload=請核單上傳、tarmark=扣收入註記、tcount=第幾筆、tfees=規費、tcontract=契約書後補註記、sign_level=簽核層級
    function Chkupload(tcount,sign_level) {
        var tupload=$("#upload_chk_"+tcount).val();
        var tarmark=$("#armark_flag_"+tcount).val();
        var tarmarkT=$("#armarkT_flag_"+tcount).val();
        var tcontract=$("#contract_flag_"+tcount).val();
        var dis=$("#dis_flag_"+tcount).val();
        var disT=$("#disT_flag_"+tcount).val();

        if ($("#sign_level").val()=="") {
            $("#sign_level").val(sign_level);
            $("#upload_flag").val(tupload);
            $("#armark_flag").val(tarmark);
            $("#armarkT_flag").val(tarmarkT);
            $("#contract_flag").val(tcontract);
            $("#dis_flag").val(dis);
            $("#disT_flag").val(disT);
        }

        if($("#C_"+tcount).prop("checked")==true){
            if($("#sign_level").val()!=sign_level){
                if($("#sign_level").val()=="0"){
                    alert("送簽流程(需經商標經理簽核)不相同無法同時送簽發信，請重新選取！");
                }else if($("#sign_level").val()=="01"||$("#sign_level").val()=="11"){
                    alert("送簽流程(需經會計檢核)不相同無法同時送簽發信，請重新選取！");
                }else if($("#sign_level").val()=="1"){
                    alert("送簽流程(需經一級主管簽核)不相同無法同時送簽發信，請重新選取！");
                }else{
                    alert("送簽流程不相同無法同時送簽發信，請重新選取⑴！");
                }
                $("#C_"+tcount).prop("checked",false);
                if ($("input[name^='C_']:checked").length == 0) $("#sign_level").val("");
                return false;
            }
        }

        if($("#upload_flag").val()+$("#armark_flag").val()+$("#armarkT_flag").val()+$("#contract_flag").val()+$("#dis_flag").val()+$("#disT_flag").val()
            !=tupload+tarmark+tarmarkT+tcontract+dis+disT){
            alert("送簽流程不相同無法同時送簽發信，請重新選取⑵！");
            $("#C_"+tcount).prop("checked",false);
            if ($("input[name^='C_']:checked").length == 0) $("#sign_level").val("");
            return false;
        }

        if ($("input[name^='C_']:checked").length == 0) $("#sign_level").val("");
    }

    //全選
    function checkall(){
        for (var j = 1; j <= CInt($("#row").val()) ; j++) {
            //沒有勾的觸發勾選
            if($("#C_"+j).prop("checked")==false){
                $("#C_"+j).click();
            }
        }
    }

    function tosign(){
        $("#spanManager").hide();
        if(CInt($("#grplevel").val())<=2){//部門主管以上簽核時可選特殊簽核
            $("#spanManager").show();
        }

        if ($("input[name=signid]:checked").val() == "YY") {//簽准
            $("#showsign").hide();//主管
            $("#showsign1").show();//程序人員
            $("#showsign2").hide();//會計人員
        }else if ($("input[name=signid]:checked").val() == "XX") {//不准退回
            $("#showsign").hide();//主管
            $("#showsign1").hide();//程序人員
            $("#showsign2").hide();//會計人員
        }else if ($("input[name=signid]:checked").val() == "YT") {//轉上級簽核
            $("#showsign1").hide();//程序人員
            if ($("#sign_level").val()=="01"||$("#sign_level").val()=="11"){//需經會計檢核
                $("#showsign").hide();//主管
                $("#showsign2").show();//會計人員
                $("input[name=upsign]").prop("checked",false);
            }else{
                $("#showsign").show();//主管
                $("#showsign2").hide();//會計人員
                $("input[name='upsign']:eq(0)").prop("checked", true);
                if($("#sign_level").val()=="0"||$("#sign_level").val()=="01"){//需簽至專商經理
                    if($("#grplevel").val()=="0"){//專商主管簽核時要改成特殊簽核
                        $("input[name='upsign']:eq(1)").prop("checked", true);
                    }
                }
                if($("#grplevel").val()=="0"){//專商主管簽核時要改成特殊簽核
                    $("input[name='upsign']:eq(1)").prop("checked", true);
                }
            }
        }
    }

    
    //*****簽准、轉上級單位:update  		
    //*****不准退回        :update2	
    function formupdate(){
        var url="";
        if($("input[name=signid][value='YY']").prop("checked")==true){
            var sign_levl=CInt($("#sign_level").val());
            if(sign_levl>=0)
                sign_levl=CInt($("#sign_level").val().Left(1));
            else
                sign_levl=CInt($("#sign_level").val().Left(2));
            var sign_flag=CInt($("#grplevel").val())>sign_levl;//判斷簽准層級夠不夠,true:不夠
            if (($("#upload_flag").val()== "Y" ||$("#disT_flag").val()== "Y")&&sign_flag){
                alert("需經區所主管簽核，請點選「轉上級簽核」並選擇簽核主管！");
                $("input[name='signid'][value='YT']").prop("checked", true).triggerHandler("click");
                return false;
            }
            if ($("#armark_flag").val()== "Y"&&sign_flag){
                alert("選取交辦案件依規定需經會計檢核，請點選「轉上級簽核」並選擇會計人員！");
                $("input[name='signid'][value='YT']").prop("checked", true).triggerHandler("click");
                return false;
            }
            if ($("#armarkT_flag").val()== "Y"&&sign_flag){
                alert("選取扣收入交辦案件依規定需經商標經理簽核，請點選「轉上級簽核」並選擇簽核主管！");
                $("input[name='signid'][value='YT']").prop("checked", true).triggerHandler("click");
                return false;
            }
            if ($("#contract_flag").val()== "Y"&&sign_flag){
                alert("選取契約書後補交辦案件依規定需經區所主管簽核，請點選「轉上級簽核」並選擇簽核主管！");
                $("input[name='signid'][value='YT']").prop("checked", true).triggerHandler("click");
                return false;
            }
            if ($("#dis_flag").val()== "Y"&sign_flag){
                alert("選取折扣低於8折交辦案件依規定需經區所主管簽核，請點選「轉上級簽核」並選擇簽核主管！");
                $("input[name='signid'][value='YT']").prop("checked", true).triggerHandler("click");
                return false;
            }
            if (sign_flag){
                alert("簽准層級不夠，請點選「轉上級簽核」並選擇簽核主管！");
                $("input[name='signid'][value='YT']").prop("checked", true).triggerHandler("click");
                return false;
            }
            $("#status").val("YY");
            $("#signidnext").val($("#prscode").val());//程序
            $("#mark").val("");//是否給代理人簽核
            reg.action = "<%#HTProgPrefix%>_Update.aspx?qs_dept=<%=qs_dept%>";
        }else if($("input[name=signid][value='XX']").prop("checked")==true){
            reg.action = "<%#HTProgPrefix%>_Update2.aspx?qs_dept=<%=qs_dept%>";
        }else if($("input[name=signid][value='YT']").prop("checked")==true){
            if($("input[name='upsign']:eq(0)").prop("checked")==true){
                $("#signidnext").val($("#sMastercode").val());//主管
                $("#mark").val("");//是否給代理人簽核
            }else if($("input[name='upsign']:eq(1)").prop("checked")==true){
                $("#signidnext").val($("#ma_scode").val());//特殊簽核
            }else if($("input[name='upsign']:eq(2)").prop("checked")==true){
                $("#signidnext").val($("#sAgentcode").val());//代理人
                $("#mark").val("S");//是否給代理人簽核
            }else{
                $("#signidnext").val($("#accscode").val());//會計人員
                $("#mark").val("");//是否給代理人簽核
            }
            $("#status").val("YT");
            reg.action = "<%#HTProgPrefix%>_Update.aspx?qs_dept=<%=qs_dept%>";
        }

        if ($("input[name^='C_']:checked").length==0){
            alert("尚未選定!!");
        }else{
            $(".bsubmit").lock(!$("#chkTest").prop("checked"));
            var form = $('#reg');
            var formData = new FormData(form[0]);
            $.ajax({
                url:form.attr('action'),
                type : "POST",
                data : formData,//form.serialize(),
                contentType: false,
                cache: false,
                processData: false,
                beforeSend:function(xhr){
                    $("#dialog").html("<div align='center'><h1>存檔中...</h1></div>");
                    $("#dialog").dialog({ title: '存檔訊息', modal: true,maxHeight: 500,width: 800,buttons:[] });
                },
                complete: function (xhr, status) {
                    $("#dialog").html(xhr.responseText);
                    $("#dialog").dialog({
                        title: '存檔訊息',modal: true,maxHeight: 500,width: 800,closeOnEscape: false
                        ,buttons: {
                            確定: function() {
                                $(this).dialog("close");
                            }
                        }
                        ,close:function(event, ui){
                            if(status=="success"){
                                //window.location.href="<%=HTProgPrefix%>.aspx?prgid=<%#prgid%>&qs_dept=<%=qs_dept%>"
                                if(!$("#chkTest").prop("checked")){
                                    goSearch();//重新整理
                                }
                            }
                        }
                    });
                }
            });
        }
    }
</script>