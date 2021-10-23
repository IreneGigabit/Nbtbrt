<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Text"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.IO"%>
<%@ Import Namespace = "System.Linq"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Web.Script.Serialization"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>

<script runat="server">
    protected string SQL = "";

    Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    Dictionary<string, string> ColMap = new Dictionary<string, string>();

    DBHelper conn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    private void Page_Unload(System.Object sender, System.EventArgs e) {
        if (conn != null) conn.Dispose();
    }
    
    protected void Page_Load(object sender, EventArgs e) {
        conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");

        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");
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

        var settings = new JsonSerializerSettings()
        {
            Formatting = Formatting.Indented,
            ContractResolver = new LowercaseContractResolver(),//key統一轉小寫
            Converters = new List<JsonConverter> { new DBNullCreationConverter(), new TrimCreationConverter() }//dbnull轉空字串且trim掉
        };
        
        Response.Write("{");
        Response.Write("\"request\":" + JsonConvert.SerializeObject(ReqVal, settings).ToUnicode() + "\n");
        Response.Write(",\"ar_main\":" + JsonConvert.SerializeObject(GetArMain(), settings).ToUnicode() + "\n");
        Response.Write(",\"ar_item\":" + JsonConvert.SerializeObject(GetArItem(), settings).ToUnicode() + "\n");
        Response.Write(",\"att_list\":" + JsonConvert.SerializeObject(GetCustAtt(), settings).ToUnicode() + "\n");
        Response.Write("}");
    }
    
    #region GetArMain 表頭資料
    private Dictionary<string, string> GetArMain() {
        Dictionary<string, string> armain = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);

        armain["cust_seq"] = ReqVal.TryGet("cust_seq");
        armain["apsqlno"] = ReqVal.TryGet("apsqlno");
        armain["tobject"] = ReqVal.TryGet("tobject");
        armain["tdshow"] = ReqVal.TryGet("tdshow");
        armain["rec_scode"] = ReqVal.TryGet("rec_scode");
        armain["rec_chk1"] = ReqVal.TryGet("rec_chk1");
        armain["att_sql"] = ReqVal.TryGet("att_sql");
        armain["receipt"] = ReqVal.TryGet("receipt");//特定案性指定收據種類
        armain["tar_mark"] = ReqVal.TryGet("tar_mark");

        //客戶備註圖示
        armain["cust_remark"] =Sys.getCustRemark(conn, Sys.GetSession("seBranch"), armain["cust_seq"]);

        //抓取聯絡人
        if (armain["att_sql"] == "") {
            SQL = "select att_sql from custz_att where cust_area='" + Session["seBranch"] + "' and cust_seq=" + armain["cust_seq"];
            SQL += " and dept='" + Session["dept"] + "'";
            string att_sql = conn.getString(SQL);
            armain["att_sql"] = (att_sql == "" ? "1" : att_sql);
        }

        //抓取收據抬頭ID及名稱
        armain["ap_cname"] = "";
        SQL = "select apclass,apcust_no,ap_cname1,ap_cname2 from apcust where apsqlno=" + armain["apsqlno"];
        using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
            if (dr.Read()) {
                armain["apclass"] = dr.SafeRead("apclass", "");
                armain["apcust_no"] = dr.SafeRead("apcust_no", "");
                armain["ap_cname"] = dr.SafeRead("ap_cname1", "") + dr.SafeRead("ap_cname2", "");
            }
        }

        //抓取請款客戶名稱
        armain["cust_name"] = "";
        SQL = "select ap_cname1,ap_cname2 from apcust where cust_area ='" + Session["seBranch"] + "' and cust_seq=" + armain["cust_seq"];
        using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
            if (dr.Read()) {
                armain["cust_name"] = dr.SafeRead("ap_cname1", "") + dr.SafeRead("ap_cname2", "");
            }
        }

        //抓取收據公司
        armain["ar_company"] = "";
        armain["acc_name"] = "";
        if (armain["receipt"] != "") {
            SQL = "select acc_name from account.dbo.ar_code where code_type='ar_code' and ar_code='" + armain["receipt"] + "'";
            using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
                if (dr.Read()) {
                    armain["ar_company"] = armain["receipt"];
                    armain["acc_name"] = dr.SafeRead("acc_name", "");
                }
            }
        } else {
            SQL = "select ar_code,acc_name from account.dbo.ar_code where code_type='ar_company' and branch ='" + Session["seBranch"] + "' and dept='T'";
            using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
                if (dr.Read()) {
                    armain["ar_company"] = dr.SafeRead("ar_code", "");
                    armain["acc_name"] = dr.SafeRead("acc_name", "");
                }
            }
        }

        //抓取連絡人地址
        armain["att_zip"] = "";
        armain["ar_addr1"] = "";
        armain["ar_addr2"] = "";
        SQL = "select att_zip,att_addr1,att_addr2 from custz_att ";
        SQL += "where cust_area='" + Session["seBranch"] + "' and cust_seq=" + armain["cust_seq"] + " and att_sql = " + armain["att_sql"];
        using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
            if (dr.Read()) {
                armain["att_zip"] = dr.SafeRead("att_zip", "");
                armain["att_addr1"] = dr.SafeRead("att_addr1", "");
                armain["att_addr2"] = dr.SafeRead("att_addr2", "");
            }
        }
        if (ReqVal.TryGet("ar_zip") != "") armain["att_zip"] = ReqVal.TryGet("ar_zip");
        if (ReqVal.TryGet("ar_addr1") != "") armain["att_addr1"] = ReqVal.TryGet("ar_addr1");
        if (ReqVal.TryGet("ar_addr2") != "") armain["att_addr2"] = ReqVal.TryGet("ar_addr2");

        return armain;
    }
    #endregion

    #region GetArItem 明細資料
    private DataTable GetArItem() {
        DataTable dt = new DataTable();

        //SQL = "select ROW_NUMBER() OVER(PARTITION BY a.case_no ORDER BY a.case_no,item_sql ) AS curr ";
        SQL = "select DENSE_RANK() OVER( ORDER BY a.case_no) AS curr ";
        SQL += ",a.*,b.seq,b.seq1,b.appl_name,c.rs_detail as case_name,d.tot_service,d.tot_fees,d.tr_money,d.tot_case,d.ar_service,d.ar_fees,d.othcase_chk,d.mark ";
        SQL += ",(select sum(item_service) from account.dbo.artitem1 E where E.case_no=f.case_no and E.item_case=a.item_arcase) as par_service ";
        SQL += ",(select sum(item_fees) from account.dbo.artitem1 E where E.case_no=f.case_no and E.item_case=a.item_arcase) as par_fees ";
        SQL += ",f.ar_service as car_service,f.ar_fees as car_fees,f.contract_no,f.ar_mark ";
        SQL += ",'U'modify,''fseq,''strcontract_no,''strar_mark ";
        SQL += ",cast(0 as money) ar_service,cast(0 as money) oth_money,cast(0 as money) ar_fees,cast(0 as money) ar_money ";
        SQL += " from aritem_temp a ";
        SQL += "inner join case_dmt f on a.case_no = f.case_no ";
        SQL += "inner join dmt_temp b on f.in_no = b.in_no and f.in_scode = b.in_scode and b.case_sqlno=0";
        SQL += "left outer join code_br c ON a.item_arcase = c.Rs_code and c.cr='Y' and c.dept='T' and c.rs_type=f.arcase_type ";
        SQL += "inner join ar_temp  d on a.dept=d.dept and a.ar_scode=d.ar_scode and a.ar_date=d.ar_date and a.case_no=d.case_no ";
        SQL += " where a.dept='T' and a.ar_scode = '" + Session["scode"] + "' and a.ar_date = '" + DateTime.Today.ToShortDateString() + "' order by a.case_no";
        conn.DataTable(SQL, dt);

        for (int j = 0; j < dt.Rows.Count; j++) {
            DataRow dr = dt.Rows[j];

            dr["fseq"] = Sys.formatSeq(dr.SafeRead("seq", ""), dr.SafeRead("seq1", ""), (dr.SafeRead("country", "") == "T" ? "" : dr.SafeRead("country", "")), "", "");

            string strcontract_no = dr.SafeRead("contract_no", "");
            if (strcontract_no == "A") {
                strcontract_no = "後續案無契約書";
            } else if (strcontract_no == "B") {
                strcontract_no = "特案簽報";
            } else if (strcontract_no == "C") {
                strcontract_no = "其他契約書無編號";
            }
            if (strcontract_no == "") {
                strcontract_no = "<font color=red>無</font>";
            }
            dr["strcontract_no"] = strcontract_no;

            if (dr.SafeRead("ar_mark", "") != "N") {
                dr["strar_mark"] = "<font color=red>特殊</font>";
            }

            if (dr.SafeRead("case_name", "") == "") {
                dr["case_name"] = dr.SafeRead("item_remark", "");
            }

            decimal service = Convert.ToDecimal(dr.SafeRead("service", "0"));       //原服務費
            decimal fees = Convert.ToDecimal(dr.SafeRead("fees", "0"));             //原規費
            decimal tot_service = Convert.ToDecimal(dr.SafeRead("tot_service", "0")); //原總計服務費
            decimal tot_fees = Convert.ToDecimal(dr.SafeRead("tot_fees", "0"));    //原總計規費
            decimal oth_money = Convert.ToDecimal(dr.SafeRead("tr_money", "0"));   //原轉帳費用

            decimal tar_servicei = Convert.ToDecimal(dr.SafeRead("ar_servicei", "0"));//本次開立服務費
            decimal tar_feesi = Convert.ToDecimal(dr.SafeRead("ar_feesi", "0"));//本次開立規費
            decimal tar_service = Convert.ToDecimal(dr.SafeRead("ar_service", "0"));//本次開立總計服務費
            decimal tar_fees = Convert.ToDecimal(dr.SafeRead("ar_fees", "0"));//本次開立總計規費

            string othcase_chk = dr.SafeRead("othcase_chk", "");//是否顯示次委辦案性

            decimal par_service = Convert.ToDecimal(dr.SafeRead("par_service", "0"));//已請款服務費
            decimal par_fees = Convert.ToDecimal(dr.SafeRead("par_fees", "0"));//已請款規費
            decimal car_service = Convert.ToDecimal(dr.SafeRead("car_service", "0"));//已請款總計服務費
            decimal car_fees = Convert.ToDecimal(dr.SafeRead("car_fees", "0"));//已請款總計規費

            //decimal add_service = Convert.ToDecimal(dr.SafeRead("add_service", "0"));//追加服務費
            //decimal tot_case = Convert.ToDecimal(dr.SafeRead("tot_case", "0"));
            //decimal add_fees = Convert.ToDecimal(dr.SafeRead("add_fees", "0"));	    //追加規費
            //decimal tot_ar_service = tot_service + add_service - car_service;	    //可開立總計服務費
            //decimal tot_ar_fees = tot_fees + add_fees - car_fees;		            //可開立總計規費

            decimal ar_money = 0, sum_service = 0, sum_fees = 0, ar_service = 0, ar_fees = 0, pre_service = 0, pre_fees = 0;
            if (othcase_chk == "Y") {//其他案性要顯示(逐筆)
                ar_service = Convert.ToDecimal(dt.Compute("Sum(ar_servicei)", "case_no='" + dr.SafeRead("case_no", "") + "' and item_sql='" + dr.SafeRead("item_sql", "") + "'"));//本次開立金額
                ar_fees = Convert.ToDecimal(dt.Compute("Sum(ar_feesi)", "case_no='" + dr.SafeRead("case_no", "") + "' and item_sql='" + dr.SafeRead("item_sql", "") + "'"));//本次開立規費
            }
            if (othcase_chk == "N") {//其他案性不顯示(總計),歸在item_sql=0上
                if (dr.SafeRead("item_sql", "") == "0") {
                    ar_service = Convert.ToDecimal(dt.Compute("Sum(ar_servicei)", "case_no='" + dr.SafeRead("case_no", "") + "'"));//本次開立金額
                    ar_fees = Convert.ToDecimal(dt.Compute("Sum(ar_feesi)", "case_no='" + dr.SafeRead("case_no", "") + "'"));//本次開立規費
                }
            }
            dr["ar_service"] = ar_service;
            dr["ar_fees"] = ar_fees;
            dr["oth_money"] = oth_money;
            dr["ar_money"] = ar_service + ar_fees;
            /*
            if (othcase_chk == "Y") {//其他案性要顯示(逐筆)
                ar_money = tar_servicei + tar_feesi;		//本次開立金額 
                sum_service = sum_service + tar_servicei;	//請款單總計服務費
                sum_fees = sum_fees + tar_feesi;		//請款單總計規費
                ar_service = tar_servicei;					//本次請款服務費
                ar_fees = tar_feesi;					//本次請款規費
                pre_service = 0;							//剩餘已請款服務費
                pre_fees = 0;							//剩餘已請款規費
                if (ar_service < 0) {
                    ar_service = 0;
                    pre_service = par_service - service;
                }
                if (ar_fees < 0) {
                    ar_fees = 0;
                    pre_fees = par_fees - fees;
                }
            }
            if (othcase_chk == "N") {					//其他案性不顯示(總計)
                ar_money = tar_service + tar_fees;			//本次開立金額
                if (dr.SafeRead("item_sql", "") == "0") {
                    sum_service = sum_service + tar_service;	//請款單總計服務費
                    sum_fees = sum_fees + tar_fees;		//請款單總計規費
                }
                ar_service = tar_service;					//本次請款服務費
                ar_fees = tar_fees;						//本次請款規費
            }
            
            
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
                strar_mark = "S";
            }

            decimal ar_money = ar_service + ar_fees;// 可開立金額

            */
        }

        return dt;
    }
    #endregion
  
    
    #region GetCustAtt 聯絡人清單
    private DataTable GetCustAtt() {
        DataTable dt = new DataTable();
        string tcust_seq = ReqVal.TryGet("tfx_cust_seq");
        if (tcust_seq == "") ReqVal.TryGet("cust_seq");

        //抓取聯絡人
        SQL = "select att_sql,Attention from custz_att ";
        SQL += "where cust_area='" + Session["seBranch"] + "' and cust_seq=" + tcust_seq;
        SQL += " and (att_code like 'N%' or att_code='' or att_code is null) ";
        SQL += " and dept='" + Session["dept"] + "'";
        conn.DataTable(SQL, dt);

        return dt;
    }
    #endregion
</script>
