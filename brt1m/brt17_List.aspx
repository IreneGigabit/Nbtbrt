﻿<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>

<script runat="server">
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;

    protected string SQL = "";
    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");

        TokenN myToken = new TokenN(HTProgCode);
        myToken.CheckMe(false, true);

        DataTable dt = new DataTable();
        using (DBHelper conn = new DBHelper(Conn.btbrt).Debug(false)) {
            SQL = "SELECT a.In_scode,a.In_no,a.case_no,a.Seq,a.Seq1,a.Service, a.Fees,a.oth_money, b.appl_name, b.class ";
			 SQL += ",a.Arcase, a.Ar_mark, isnull(a.discount,0) as discount, a.case_num,a.stat_code, a.cust_area, a.cust_seq ";
			 SQL += ",c.service AS p_service, c.fees AS p_fees, a.Discount_chk, d.cust_name,a.case_num,a.arcase_type,a.arcase_class ";
			 SQL += ",(SELECT rs_detail FROM code_br WHERE rs_code = a.arcase AND dept = 'T' AND cr = 'Y' AND no_code='N' and rs_type=a.arcase_type) AS case_name ";
			 SQL += ",(SELECT rs_class FROM code_br WHERE rs_code = a.arcase AND dept = 'T' AND cr = 'Y' AND no_code='N' and rs_type=a.arcase_type) AS Ar_form ";
			 SQL += ",(SELECT prt_code FROM code_br WHERE rs_code = a.arcase AND dept = 'T' AND cr = 'Y' AND no_code='N' and rs_type=a.arcase_type) AS prt_code ";
             SQL += ",''link_remark,''fseq,''urlasp,''case_num_txt,''todoicon,''sum_txt,''dis_txt,''nx_link ";
             SQL += ",0 T_Service,0 T_Fees,0 P_Service,0 P_Fees "; 
            SQL += "FROM case_dmt a ";
             SQL+=" INNER JOIN dmt_temp b ON a.in_scode = b.in_scode AND a.in_no = b.in_no and b.case_sqlno=0 ";
             SQL += "INNER JOIN VIEW_Cust d ON a.cust_seq = d.cust_seq AND a.cust_area = d.cust_area ";
             SQL += "LEFT OUTER JOIN case_fee c ON a.arcase = c.rs_code AND (c.dept = 'T') AND (c.country = 'T') AND (GETDATE() BETWEEN c.beg_date AND c.end_date) ";
             SQL += "WHERE a.cust_area = '" + Request["tfx_cust_area"] + "' ";
			 SQL += "AND a.stat_code LIKE 'N%' ";
            
            if (ReqVal.TryGet("stat_code") != "") {
                SQL += "AND a.stat_code ='" + Request["stat_code"] + "' ";
            }
            if (ReqVal.TryGet("tfx_cust_seq") != "") {
                SQL += "AND a.cust_seq ='" + Request["tfx_cust_seq"] + "' ";
            }
            if (ReqVal.TryGet("sfx_in_date") != "") {
                SQL += "AND a.in_date> ='" + Request["sfx_in_date"] + "' ";
            }
            if (ReqVal.TryGet("Efx_in_date") != "") {
                SQL += "AND a.in_date< ='" + Request["Efx_in_date"] + "' ";
            }
            if (ReqVal.TryGet("tscode") != "") {
                SQL += "AND a.in_scode ='" + Request["tscode"] + "' ";
            }
            if (ReqVal.TryGet("pfx_Arcase") != "") {
                SQL += "AND a.Arcase ='" + Request["pfx_Arcase"] + "' ";
            }
            SQL += "AND (a.mark='N' or a.mark is null)";
            ReqVal["qryOrder"] = ReqVal.TryGet("SetOrder", ReqVal.TryGet("qryOrder", ""));
            if (ReqVal.TryGet("qryOrder", "") != "") {
                SQL += " order by " + ReqVal.TryGet("qryOrder", "");
            } else {
                SQL += " order by a.in_no";
            }
            conn.DataTable(SQL, dt); 
            
            //處理分頁
            int nowPage = Convert.ToInt32(Request["GoPage"] ?? "1"); //第幾頁
            int PerPageSize = Convert.ToInt32(Request["PerPage"] ?? "10"); //每頁筆數
            Paging page = new Paging(nowPage, PerPageSize, string.Join(";", conn.exeSQL.ToArray()));
            page.GetPagedTable(dt);

            //分頁完再處理其他資料才不會虛耗資源
            for (int i = 0; i < page.pagedTable.Rows.Count; i++) {
                SQL = "Select remark from cust_code where cust_code='__' and code_type='" + page.pagedTable.Rows[i]["arcase_type"] + "'";
                object objResult = conn.ExecuteScalar(SQL);
                string link_remark = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();
                page.pagedTable.Rows[i]["link_remark"] = link_remark;//案性版本連結

                int T_Service = 0;//交辦服務費
                int T_Fees = 0;//交辦規費
                int P_Service = 0;//服務費收費標準
                int P_Fees = 0;//規費收費標準
                SQL = "select a.item_service as case_service,a.item_fees as case_fees, service*item_count as fee_service,fees*item_count AS fee_Fees ";
                SQL += "from caseitem_dmt a ";
                SQL += "inner join case_fee b on a.item_arcase=b.rs_code ";
                SQL += "where a.in_no='" + page.pagedTable.Rows[i].SafeRead("in_no", "") + "' ";
                SQL += "and b.dept='T' and b.country='T' and getdate() between b.beg_date and b.end_date";
                using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
                    if (dr.Read()) {
                        T_Service += dr.SafeRead("case_service", 0);
                        P_Service += dr.SafeRead("Fee_service", 0);
                        T_Fees += dr.SafeRead("Case_Fees", 0);
                        P_Fees += dr.SafeRead("Fee_Fees", 0);
                    }
                }
                SQL = "select a.oth_arcase,a.oth_money,b.service ";
                SQL += "from case_dmt a ";
                SQL += "inner join case_fee b on  a.oth_arcase=b.rs_code ";
                SQL += "where in_no='" + page.pagedTable.Rows[i].SafeRead("in_no", "") + "' ";
                SQL += "and b.dept='T' and b.country='T' and getdate() between b.beg_date and b.end_date";
                using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
                    if (dr.Read()) {
                        T_Service += dr.SafeRead("oth_money", 0);
                        P_Service += dr.SafeRead("service", 0);
                    }
                }
                page.pagedTable.Rows[i]["T_Service"] = T_Service;
                page.pagedTable.Rows[i]["T_Fees"] = T_Fees;
                page.pagedTable.Rows[i]["P_Service"] = P_Service;
                page.pagedTable.Rows[i]["P_Fees"] = P_Fees;

                page.pagedTable.Rows[i]["cust_name"] = page.pagedTable.Rows[i].SafeRead("cust_name", "").Left(20);
                page.pagedTable.Rows[i]["fseq"] = page.pagedTable.Rows[i].SafeRead("seq", "") + (page.pagedTable.Rows[i].SafeRead("seq1", "_") != "_" ? "-" + page.pagedTable.Rows[i].SafeRead("seq1", "") : "");
                page.pagedTable.Rows[i]["case_num_txt"] = page.pagedTable.Rows[i].SafeRead("stat_code", "") == "NX" ? "(" + page.pagedTable.Rows[i].SafeRead("stat_code", "") + ")" : "";
                page.pagedTable.Rows[i]["todoicon"] = GetTodoIcon(page.pagedTable.Rows[i]);
                page.pagedTable.Rows[i]["sum_txt"] = GetSum(page.pagedTable.Rows[i]);
                page.pagedTable.Rows[i]["dis_txt"] = GetDiscount(page.pagedTable.Rows[i]);

                string new_form = "";//連結的aspx
                SQL = "SELECT c.remark ";
                SQL += "FROM Cust_code c ";
                SQL += "inner join code_br b on b.rs_type=c.Code_type and b.rs_class=c.Cust_code ";
                //SQL += "WHERE c.form_name is not null ";
                SQL += "WHERE 1=1 ";
                SQL += "and b.rs_type='" + page.pagedTable.Rows[i]["arcase_type"] + "' ";
                SQL += "and b.rs_code='" + page.pagedTable.Rows[i]["arcase"] + "' ";
                using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
                    if (dr.Read()) {
                        new_form += dr.SafeRead("remark", "");
                    }
                }
                string ar_form = page.pagedTable.Rows[i].SafeRead("ar_form", "");//rs_class
                string prt_name = page.pagedTable.Rows[i].SafeRead("reportp", "");//列印程式
                bool FlagPrint = (prt_name != "" ? true : false);
                if (page.pagedTable.Rows[i].SafeRead("prt_code", "") == "D9Z" || page.pagedTable.Rows[i].SafeRead("prt_code", "") == "ZZ") {
                    //2014/4/29因有部份類別在洽案登錄為大類別，如C救濟案，但編修時值皆抓rs_class=C2，則會造成若要改C1下的案性，就會選不到，增加下列判斷重抓洽案登錄大類別
                    SQL = "select cust_code from cust_code where code_type='" + page.pagedTable.Rows[i]["arcase_type"] + "' and form_name is not null and cust_code='" + ar_form + "'";
                    using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
                        if (!dr.HasRows) {
                            dr.Close();
                            SQL = "select cust_code from cust_code where code_type='" + page.pagedTable.Rows[i]["arcase_type"] + "' and form_name is not null and cust_code like '" + ar_form.Left(1) + "%' ";
                            using (SqlDataReader dr1 = conn.ExecuteReader(SQL)) {
                                if (dr1.Read()) {
                                    page.pagedTable.Rows[i]["ar_form"] = dr1.SafeRead("cust_code", "");
                                }
                            }
                        }
                    }
                } else {
                    if (page.pagedTable.Rows[i].SafeRead("prt_code", "") == "D3"
                        || page.pagedTable.Rows[i].SafeRead("prt_code", "") == ""
                        || page.pagedTable.Rows[i].SafeRead("arcase", "") == "DE2"
                        || page.pagedTable.Rows[i].SafeRead("arcase", "") == "AD7"
                        )
                        FlagPrint = false;
                }
                string urlasp = "";//連結的url
                urlasp = Page.ResolveUrl("~/brt1m" + link_remark + "/Brt11Edit" + new_form + ".aspx?prgid=" + prgid);
                urlasp += "&in_scode=" + page.pagedTable.Rows[i]["in_scode"];
                urlasp += "&in_no=" + page.pagedTable.Rows[i]["in_no"];
                urlasp += "&add_arcase=" + page.pagedTable.Rows[i]["arcase"];
                urlasp += "&cust_area=" + page.pagedTable.Rows[i]["cust_area"];
                urlasp += "&cust_seq=" + page.pagedTable.Rows[i]["cust_seq"];
                urlasp += "&ar_form=" + page.pagedTable.Rows[i]["ar_form"];
                urlasp += "&new_form=" + new_form;
                urlasp += "&code_type=" + page.pagedTable.Rows[i]["arcase_type"];
                urlasp += "&homelist=" + Request["homelist"];
                urlasp += "&uploadtype=case";

                if (Sys.GetSession("scode") == page.pagedTable.Rows[i].SafeRead("in_scode", "") || (HTProgRight & 128) != 0)
                    urlasp += "&submittask=Edit";
                else
                    urlasp += "&submittask=Show";
                page.pagedTable.Rows[i]["urlasp"] = urlasp;
                page.pagedTable.Rows[i]["nx_link"] = GetNXLink(page.pagedTable.Rows[i], new_form);
            }
            var settings = new JsonSerializerSettings()
            {
                Formatting = Formatting.Indented,
                ContractResolver = new LowercaseContractResolver(),//key統一轉小寫
                Converters = new List<JsonConverter> { new DBNullCreationConverter(), new TrimCreationConverter() }//dbnull轉空字串且trim掉
            };
            Response.Write(JsonConvert.SerializeObject(page, settings).ToUnicode());
            Response.End();
        }
    }


    protected string GetTodoIcon(DataRow row) {
        string back_flag = row.SafeRead("back_flag","").Trim().ToUpper();
        string end_flag = row.SafeRead("end_flag","").Trim().ToUpper();
        if (back_flag == "Y" || end_flag == "Y")
            return "<img src='" + Page.ResolveUrl("~/images/todolist01.jpg") + "' align='absmiddle' border='0'>";

        return "";
    }

    protected string GetSum(DataRow row) {
        int Service = Convert.ToInt32(row.SafeRead("Service","0"));
        int fees = Convert.ToInt32(row.SafeRead("fees","0"));
        int oth_money = Convert.ToInt32(row.SafeRead("oth_money","0"));
            return (Service+fees+oth_money).ToString();
    }

    protected string GetDiscount(DataRow row) {
        decimal discount = Convert.ToDecimal(row.SafeRead("discount","0"));
        string discount_chk = row.SafeRead("Discount_chk","");
        string discount_remark = row.SafeRead("discount_remark","");
        string rtn = "";
        if (discount > 0) {
            rtn += discount + "%";
        }

        if (discount_chk == "Y" || discount_remark != "") {
            rtn += "(*)";
        }

        return rtn;
    }

    protected string GetNXLink(DataRow row, string new_form) {
        string stat_code = row.SafeRead("stat_code", "");
        if (stat_code == "NX")
            return "<a href='" + Page.ResolveUrl("~/Brt4m/Brt13ListA.aspx") +
                    "?in_scode=" + row.SafeRead("in_scode", "") +
                    "&in_no=" + row.SafeRead("in_no", "") +
                    "&ar_form=" + row.SafeRead("ar_form", "") +
                    "&homelist=" + Request["homelist"] +
                    "&new_form=" + new_form +
                    "&qs_dept=T' target='Eblank'><font color=red>說明</font></a>";
        return "";
    }
</script>
