<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>

<script runat="server">
    protected string HTProgCap = "國內案交辦單列印";// HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";

    protected string SQL = "";
    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");

        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        HTProgCap = myToken.Title;
        DebugStr = myToken.DebugStr;

        DataTable dt = new DataTable();
        using (DBHelper conn = new DBHelper(Conn.btbrt).Debug(false)) {
            SQL = "SELECT a.In_scode,a.In_no,a.in_date,a.case_no,a.Seq,a.Seq1,a.Service, a.Fees,a.oth_money, b.appl_name, b.class ";
            SQL += ",a.Arcase, a.Ar_mark, isnull(a.discount,0) as discount, a.case_num,a.stat_code, a.cust_area, a.cust_seq ";
            SQL += ",a.Service + a.Fees + a.oth_money AS aFee, a.Discount_chk, d.cust_name,a.case_num,a.arcase_type,a.arcase_class ";
            SQL += ",(SELECT rs_detail FROM code_br WHERE rs_code = a.arcase AND dept = 'T' AND cr = 'Y' AND no_code='N' and rs_type=a.arcase_type) AS case_name ";
            SQL += ",(SELECT rs_class FROM code_br WHERE rs_code = a.arcase AND dept = 'T' AND cr = 'Y' AND no_code='N' and rs_type=a.arcase_type) AS Ar_form ";
            SQL += ",(SELECT prt_code FROM code_br WHERE rs_code = a.arcase AND dept = 'T' AND cr = 'Y' AND no_code='N' and rs_type=a.arcase_type) AS prt_code ";
            SQL += ",(SELECT sc_name FROM sysctrl.dbo.scode where scode=a.in_scode) AS sc_name ";
            SQL += ",''link_remark,''fseq,''urlasp,''rptasp ";
            SQL += "FROM case_dmt a ";
            SQL += " INNER JOIN dmt_temp b ON a.in_scode = b.in_scode AND a.in_no = b.in_no and b.case_sqlno=0 ";
            SQL += "INNER JOIN VIEW_Cust d ON a.cust_seq = d.cust_seq AND a.cust_area = d.cust_area ";
            //SQL += "LEFT OUTER JOIN case_fee c ON a.arcase = c.rs_code AND (c.dept = 'T') AND (c.country = 'T') AND (GETDATE() BETWEEN c.beg_date AND c.end_date) ";
            SQL += "WHERE (a.mark='N' or a.mark is null) ";

            if (ReqVal.TryGet("pfx_Arcase") != "") {
                SQL += "AND a.Arcase like '" + Request["pfx_Arcase"] + "%' ";
            }
            if (ReqVal.TryGet("tfx_in_Scode") != "") {
                SQL += "AND a.in_Scode ='" + Request["tfx_in_Scode"] + "' ";
            }
            if (ReqVal.TryGet("tfx_stat_code") != "") {
                SQL += "AND a.stat_code ='" + Request["tfx_stat_code"] + "' ";
            }
            if (ReqVal.TryGet("sfx_in_no") != "") {
                SQL += "AND a.in_no>='" + Request["sfx_in_no"] + "' ";
            }
            if (ReqVal.TryGet("efx_in_no") != "") {
                SQL += "AND a.in_no<='" + Request["efx_in_no"] + "' ";
            }
            if (ReqVal.TryGet("sfx_case_no") != "") {
                SQL += "AND a.case_no>='" + Request["sfx_case_no"] + "' ";
            }
            if (ReqVal.TryGet("efx_case_no") != "") {
                SQL += "AND a.case_no<='" + Request["efx_case_no"] + "' ";
            }
            if (ReqVal.TryGet("sfx_in_date") != "") {
                SQL += "AND a.in_date>='" + Request["sfx_in_date"] + "' ";
            }
            if (ReqVal.TryGet("efx_in_date") != "") {
                SQL += "AND a.in_date<='" + Request["efx_in_date"] + "' ";
            }
            if (ReqVal.TryGet("sfx_case_date") != "") {
                SQL += "AND a.case_date> ='" + Request["sfx_case_date"] + "' ";
            }
            if (ReqVal.TryGet("efx_case_date") != "") {
                SQL += "AND a.case_date<='" + Request["efx_case_date"] + "' ";
            }

            ReqVal["qryOrder"] = ReqVal.TryGet("SetOrder", ReqVal.TryGet("qryOrder"));
            if (ReqVal.TryGet("qryOrder") != "") {
                SQL += " order by " + ReqVal.TryGet("qryOrder");
            }
            conn.DataTable(SQL, dt);

            //處理分頁
            int nowPage = Convert.ToInt32(Request["GoPage"] ?? "1"); //第幾頁
            int PerPageSize = Convert.ToInt32(Request["PerPage"] ?? "10"); //每頁筆數
            Paging page = new Paging(nowPage, PerPageSize, SQL);
            page.GetPagedTable(dt);

            //分頁完再處理其他資料才不會虛耗資源
            for (int i = 0; i < page.pagedTable.Rows.Count; i++) {
                DataRow dr = page.pagedTable.Rows[i];

                SQL = "Select remark from cust_code where cust_code='__' and code_type='" + dr["arcase_type"] + "'";
                object objResult = conn.ExecuteScalar(SQL);
                string link_remark = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();
                dr["link_remark"] = link_remark;//案性版本連結

                dr["cust_name"] = dr.SafeRead("cust_name", "").Left(20);
                dr["fseq"] = Sys.formatSeq(dr.SafeRead("seq", ""), dr.SafeRead("seq1", ""), "", "", "");

                string new_form = "";//連結的aspx
                SQL = "SELECT c.remark ";
                SQL += "FROM Cust_code c ";
                SQL += "inner join code_br b on b.rs_type=c.Code_type and b.rs_class=c.Cust_code ";
                //SQL += "WHERE c.form_name is not null ";
                SQL += "WHERE 1=1 ";
                SQL += "and b.rs_type='" + dr["arcase_type"] + "' ";
                SQL += "and b.rs_code='" + dr["arcase"] + "' ";
                using (SqlDataReader dr0 = conn.ExecuteReader(SQL)) {
                    if (dr0.Read()) {
                        new_form += dr0.SafeRead("remark", "");
                    }
                }
                string ar_form = dr.SafeRead("ar_form", "");//rs_class
                string prt_name = dr.SafeRead("reportp", "");//列印程式
                if (dr.SafeRead("prt_code", "") == "D9Z" || dr.SafeRead("prt_code", "") == "ZZ") {
                    //2014/4/29因有部份類別在洽案登錄為大類別，如C救濟案，但編修時值皆抓rs_class=C2，則會造成若要改C1下的案性，就會選不到，增加下列判斷重抓洽案登錄大類別
                    SQL = "select cust_code from cust_code where code_type='" + dr["arcase_type"] + "' and form_name is not null and cust_code='" + ar_form + "'";
                    using (SqlDataReader dr0 = conn.ExecuteReader(SQL)) {
                        if (!dr0.HasRows) {
                            dr0.Close();
                            SQL = "select cust_code from cust_code where code_type='" + dr["arcase_type"] + "' and form_name is not null and cust_code like '" + ar_form.Left(1) + "%' ";
                            using (SqlDataReader dr1 = conn.ExecuteReader(SQL)) {
                                if (dr1.Read()) {
                                    dr["ar_form"] = dr1.SafeRead("cust_code", "");
                                }
                            }
                        }
                    }
                }
                string urlasp = "";//連結的url
                //urlasp = Page.ResolveUrl("~/brt1m" + link_remark + "/Brt11Edit" + new_form + ".aspx?prgid=" + prgid);
                //urlasp += "&in_scode=" + dr["in_scode"];
                //urlasp += "&in_no=" + dr["in_no"];
                //urlasp += "&add_arcase=" + dr["arcase"];
                //urlasp += "&cust_area=" + dr["cust_area"];
                //urlasp += "&cust_seq=" + dr["cust_seq"];
                //urlasp += "&ar_form=" + dr["ar_form"];
                //urlasp += "&new_form=" + new_form;
                //urlasp += "&code_type=" + dr["arcase_type"];
                //urlasp += "&homelist=" + Request["homelist"];
                //urlasp += "&uploadtype=case";
                //urlasp += "&submittask=Show";
                urlasp = Sys.getCase11Aspx(prgid, dr.SafeRead("in_no", ""), dr.SafeRead("in_scode", ""), "Edit");
                dr["urlasp"] = urlasp;

                string rptasp = "";//列印的url
                rptasp = Page.ResolveUrl("~/Report" + link_remark + "/Brt16_Report.asp?prgid=" + prgid);
                rptasp += "&in_no=" + dr["in_no"];
                rptasp += "&add_arcase=" + dr["arcase"];
                dr["rptasp"] = rptasp;
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
</script>

