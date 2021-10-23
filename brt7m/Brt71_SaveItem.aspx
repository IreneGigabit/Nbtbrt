<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>

<script runat="server">
    protected string HTProgCap = "國內案一般請款單明細-請款案件選取入檔";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = HttpContext.Current.Request["prgid"] ?? "";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";

    protected string submitTask = "";
    protected string SQL = "";
    protected object objResult = null;

    Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    Dictionary<string, string> ColMap = new Dictionary<string, string>();

    DBHelper conn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    private void Page_Unload(System.Object sender, System.EventArgs e) {
        if (conn != null) conn.Dispose();
    }


    protected void Page_Load(object sender, EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");

        
        if (ReqVal.TryGet("task") == "D") {//
            DelItem();
        } else {
            AddItem();
        }
    }
    
    /// <summary>
    /// 刪除明細
    /// </summary>
    protected void DelItem() {
        string curr_no = ReqVal.TryGet("serial_no");
        string tcase_no = ReqVal.TryGet("case_no_" + curr_no);

        try {
            SQL = "delete from ar_temp where dept='T' and ar_scode ='" + Session["scode"] + "' and ar_date = '" + DateTime.Today.ToShortDateString() + "' and case_no='" + tcase_no + "'";
            SQL += ";delete from aritem_temp where dept='T' and ar_scode ='" + Session["scode"] + "' and ar_date='" + DateTime.Today.ToShortDateString() + "' and case_no='" + tcase_no + "'";
            conn.ExecuteNonQuery(SQL);
            conn.Commit();
        }
        catch (Exception ex) {
            conn.RollBack();
            Sys.errorLog(ex, conn.exeSQL, ReqVal.TryGet("prgid"));
            //strOut.AppendLine("<div align='center'><h1>資料更新失敗("+ex.Message+")</h1></div>");
            throw;
        }
    }

    /// <summary>
    /// 新增明細
    /// </summary>
    protected void AddItem() {
        ReqVal["cust_seq"] = ReqVal.TryGet("cust_seq");
        ReqVal["apsqlno"] = ReqVal.TryGet("apsqlno");
        ReqVal["tobject"] = ReqVal.TryGet("tobject");
        ReqVal["tdshow"] = ReqVal.TryGet("tdshow");
        ReqVal["rec_scode"] = ReqVal.TryGet("rec_scode");
        ReqVal["rec_chk1"] = ReqVal.TryGet("rec_chk1");
        ReqVal["att_sql"] = ReqVal.TryGet("att_sql");
        ReqVal["receipt"] = ReqVal.TryGet("receipt");//特定案性指定收據種類
        ReqVal["ar_chk"] = ReqVal.TryGet("ar_chk");//顯示/隱藏請款備註
        if (ReqVal["ar_chk"] == "") ReqVal["ar_chk"] = "N";
        ReqVal["acc_chk"] = ReqVal.TryGet("acc_chk");//顯示/隱藏電匯帳號
        if (ReqVal["acc_chk"] == "") ReqVal["acc_chk"] = "Y";
        
        try {
            //A=第一次選取請款案件，清空請款暫存檔
            if (ReqVal.TryGet("modify") == "A") {
                SQL = "delete from ar_temp where dept='T' and ar_scode='" + Session["scode"] + "' and ar_date='" + DateTime.Today.ToShortDateString() + "' ";
                SQL += ";delete from aritem_temp where dept='T' and ar_scode='" + Session["scode"] + "' and ar_date='" + DateTime.Today.ToShortDateString() + "' ";
                conn.ExecuteNonQuery(SQL);
                conn.Commit();
            }

            int curr = 0;//行號
            for (int i = 1; i <= Convert.ToInt32("0" + ReqVal.TryGet("row")); i++) {
                if (Request["T_" + i] == "Y") {//有勾才要寫入
                    curr++;

                    string sqlins1 = "", sqlins2 = "";
                    string inscode = ReqVal.TryGet("inscode_" + i);
                    string in_no = ReqVal.TryGet("inno_" + i);

                    SQL = "select a.in_scode,a.in_no,a.seq,a.seq1,a.case_no,a.arcase_type,a.arcase,a.service,a.fees ";
                    SQL += ",a.tot_case,isnull(a.add_service,0) as add_service,isnull(a.add_fees,0) as add_fees ";
                    SQL += ",isnull(a.ar_service,0) as ar_service,isnull(a.ar_fees,0) as ar_fees,isnull(a.oth_money,0) as oth_money,a.oth_code ";
                    SQL += ",a.contract_no,a.ar_mark,d.item_sql,d.item_arcase,d.item_service,d.item_fees,d.item_count,b.appl_name,b.class ";
                    SQL += "from case_dmt a ";
                    SQL += "inner join dmt_temp b on a.in_no=b.in_no and a.in_scode =b.in_scode and b.case_sqlno=0 ";
                    SQL += "left outer join caseitem_dmt d on a.in_scode=d.in_scode and a.in_no=d.in_no ";
                    SQL += " where a.in_no='" + in_no + "' and a.in_scode='" + inscode + "'";
                    DataTable dtItem = new DataTable();
                    conn.DataTable(SQL, dtItem);

                    decimal tar_money = 0;//可開立總計金額

                    conn.BeginTran();
                    for (int j = 0; j < dtItem.Rows.Count; j++) {
                        DataRow dr = dtItem.Rows[j];
                        string case_apsqlno = "", case_apcust_no = "";
                        SQL = "select apsqlno,apcust_no from dmt_temp_ap where in_no='" + in_no + "' and case_sqlno=0";
                        using (SqlDataReader dr0 = conn.ExecuteReader(SQL)) {
                            if (dr0.Read()) {
                                case_apsqlno = dr0.SafeRead("apsqlno", "");
                                case_apcust_no = dr0.SafeRead("apcust_no", "");
                            }
                        }

                        string item_arcase = dr.SafeRead("arcase", "");
                        if (dr.SafeRead("item_arcase", "") != "") {
                            item_arcase = dr.SafeRead("item_arcase", "");
                        }
                        decimal item_count = 0;
                        if (dr.SafeRead("item_count", "") != "") {
                            item_count = Convert.ToDecimal(dr.SafeRead("item_count", "0"));
                        }

                        decimal service = Convert.ToDecimal(dr.SafeRead("service", "0"));       //原總計交辦服務費
                        decimal fees = Convert.ToDecimal(dr.SafeRead("fees", "0"));             //原總計交辦規費
                        decimal oth_money = Convert.ToDecimal(dr.SafeRead("oth_money", "0"));   //原轉帳費用
                        decimal tot_service = service + oth_money;                              //原總計服務費
                        decimal tot_fees = fees;                                                //原總計規費
                        decimal tot_case = Convert.ToDecimal(dr.SafeRead("tot_case", "0"));
                        decimal add_service = Convert.ToDecimal(dr.SafeRead("add_service", "0"));//追加服務費
                        decimal add_fees = Convert.ToDecimal(dr.SafeRead("add_fees", "0"));	    //追加規費
                        decimal car_service = Convert.ToDecimal(dr.SafeRead("ar_service", "0"));//已請款服務費
                        decimal car_fees = Convert.ToDecimal(dr.SafeRead("ar_fees", "0"));	    //已請款規費
                        decimal tot_ar_service = tot_service + add_service - car_service;	    //可開立總計服務費
                        decimal tot_ar_fees = tot_fees + add_fees - car_fees;		            //可開立總計規費

                        decimal service0 = 0;
                        if (j == 0) {//主委辦案性
                            service0 = service + oth_money;
                            if (tot_case > 1) {//有次委辦案性
                                service0 = Convert.ToDecimal(dr.SafeRead("item_service", "0")) + oth_money;
                                fees = Convert.ToDecimal(dr.SafeRead("item_fees", "0"));
                            }
                            tar_money = tot_ar_service + tot_ar_fees;//可開立總計金額
                        } else {//次委辦案性
                            service0 = service;
                            if (tot_case > 1) {//有次委辦案性
                                service0 = Convert.ToDecimal(dr.SafeRead("item_service", "0"));
                                fees = Convert.ToDecimal(dr.SafeRead("item_fees", "0"));
                            }
                        }
                        decimal ar_service = service0;//可開立服務費
                        if (ar_service < 0) ar_service = 0;
                        decimal ar_fees = fees;//可開立規費	
                        if (ar_fees < 0) ar_fees = 0;

                        string othcase_chk = "Y";//顯示次委辦案性
                        if (car_service > 0 || car_fees > 0) {
                            othcase_chk = "N";//不顯示次委辦案性
                        }
                        string mark = "N";//請款種類
                        if (dr.SafeRead("ar_mark", "") != "N") {
                            mark = "S";
                        }

                        decimal ar_money = ar_service + ar_fees;// 可開立金額

                        sqlins1 = "insert into ar_temp ";
                        ColMap.Clear();
                        ColMap["dept"] = Util.dbchar("T");
                        ColMap["ar_scode"] = "'" + Session["scode"] + "'";
                        ColMap["ar_date"] = "'" + DateTime.Today.ToShortDateString() + "'";
                        ColMap["case_no"] = Util.dbchar(dr.SafeRead("case_no", ""));
                        ColMap["curr_no"] = curr.ToString();
                        ColMap["ar_type"] = Util.dbchar(ReqVal.TryGet("tobject"));
                        ColMap["rec_chk1"] = Util.dbchar(ReqVal.TryGet("rec_chk1"));
                        ColMap["cust_area"] = "'" + Session["seBranch"] + "'";
                        ColMap["cust_seq"] = Util.dbnull(ReqVal.TryGet("cust_seq"));
                        ColMap["apsqlno"] = Util.dbnull(case_apsqlno);
                        ColMap["apcust_no"] = Util.dbchar(case_apcust_no);
                        ColMap["in_scode"] = Util.dbchar(inscode);
                        ColMap["in_no"] = Util.dbchar(in_no);
                        ColMap["seq"] = Util.dbnull(dr.SafeRead("seq", ""));
                        ColMap["seq1"] = Util.dbchar(dr.SafeRead("seq1", ""));
                        ColMap["class"] = Util.dbchar(dr.SafeRead("class", ""));
                        ColMap["arcase"] = Util.dbchar(item_arcase);
                        ColMap["tot_service"] = Util.dbzero(tot_service.ToString());
                        ColMap["tot_fees"] = Util.dbzero(tot_fees.ToString());
                        ColMap["tr_money"] = Util.dbzero(oth_money.ToString());
                        ColMap["tr_dept"] = Util.dbchar(dr.SafeRead("tr_dept", ""));
                        ColMap["tot_case"] = Util.dbzero(dr.SafeRead("tot_case", ""));
                        ColMap["case_service"] = Util.dbzero(tot_ar_service.ToString());
                        ColMap["case_fees"] = Util.dbzero(tot_ar_fees.ToString());
                        ColMap["ar_service"] = Util.dbzero(tot_ar_service.ToString());
                        ColMap["ar_fees"] = Util.dbzero(tot_ar_fees.ToString());
                        ColMap["ar_money"] = Util.dbzero(tar_money.ToString());
                        if (j != 0) {//有次委辦案性才要寫入
                            ColMap["othcase_chk"] = Util.dbchar(othcase_chk);
                        }
                        ColMap["mark"] = Util.dbchar(mark);
                        sqlins1 += ColMap.GetInsertSQL();

                        sqlins2 += " insert into aritem_temp ";
                        ColMap.Clear();
                        ColMap["dept"] = Util.dbchar("T");
                        ColMap["ar_scode"] = "'" + Session["scode"] + "'";
                        ColMap["ar_date"] = "'" + DateTime.Today.ToShortDateString() + "'";
                        ColMap["case_no"] = Util.dbchar(dr.SafeRead("case_no", ""));
                        ColMap["item_sql"] = Util.dbzero(dr.SafeRead("item_sql", ""));
                        ColMap["in_scode"] = Util.dbchar(inscode);
                        ColMap["in_no"] = Util.dbchar(in_no);
                        ColMap["item_arcase"] = Util.dbchar(item_arcase);
                        ColMap["service"] = Util.dbzero(service0.ToString());
                        ColMap["fees"] = Util.dbzero(fees.ToString());
                        ColMap["ar_servicei"] = Util.dbzero(ar_service.ToString());
                        ColMap["ar_feesi"] = Util.dbchar(ar_fees.ToString());
                        ColMap["ar_moneyi"] = Util.dbzero(ar_money.ToString());
                        ColMap["item_count"] = Util.dbzero(item_count.ToString());
                        sqlins2 += ColMap.GetInsertSQL();
                    }
                    conn.ExecuteNonQuery(sqlins1);//主檔
                    conn.ExecuteNonQuery(sqlins2);//明細
                    conn.Commit();
                }
            }
        }
        catch (Exception ex) {
            conn.RollBack();
            Sys.errorLog(ex, conn.exeSQL, ReqVal.TryGet("prgid"));
            //strOut.AppendLine("<div align='center'><h1>資料更新失敗("+ex.Message+")</h1></div>");
            throw;
        }
    }
</script>
