<%@ Page Language="C#" CodePage="65001" AutoEventWireup="true"  %>
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
    protected string strConnB = "";

    protected string branch = "";
    protected string opt_sqlno = "";
    protected string cust_area = "";
    protected string cust_seq = "";
    protected string att_sql = "";
    protected string arcase_type = "";
    protected string case_no = "";


    //http://web08/nOpt/ajax/_OptData.aspx?branch=N&opt_sqlno=2453&_=1584086771124

    protected void Page_Load(object sender, EventArgs e) {
        strConnB = Conn.brp(Request["branch"]);

        branch = Request["branch"];
        opt_sqlno = Request["opt_sqlno"];

        DataTable dt_opt = GetBROpt(branch, opt_sqlno);//案件資料
        DataTable dt_cust = GetBRCust(cust_area, cust_seq);//客戶
        DataTable dt_attList = GetBRAtt(cust_area, cust_seq);//聯絡人清單
        DataTable dt_ap = GetBRAP(case_no);//申請人
        DataTable dt_casefee = GetCaseFees(arcase_type, opt_sqlno, case_no, branch);//交辦費用
        DataTable dt_arcase = GetArcase(arcase_type);//委辦案性
        DataTable dt_arcaseItem = GetArcaseItem();//其他費用案性
        DataTable dt_arcaseOther = GetArcaseOther(arcase_type);//轉帳費用案性
        DataTable dt_casegood = GetCaseGood(opt_sqlno, case_no, branch);//類別
        DataTable dt_tran = GetTran(opt_sqlno);//異動
        DataTable dt_tran_mod_client = GetTranModClient(case_no, opt_sqlno);//關係人
        DataTable dt_tran_mod_dmt = GetTranModDmt(case_no, opt_sqlno);
        DataTable dt_tran_mod_pul = GetTranModPul(case_no, opt_sqlno);
        DataTable dt_tran_mod_ap = GetTranModAp(case_no, opt_sqlno);
        DataTable dt_tran_mod_aprep = GetTranModAprep(case_no, opt_sqlno);
        DataTable dt_tran_mod_claim1 = GetTranModClaim1(case_no, opt_sqlno);
        DataTable dt_tran_mod_class = GetTranModClass(case_no, opt_sqlno);
        DataTable dt_brdmt_attach = GetBRDmtAttach(case_no);
        DataTable dt_opt_attach = GetOptAttach(opt_sqlno);

        var settings = new JsonSerializerSettings() {
            Formatting = Formatting.Indented,
            ContractResolver = new LowercaseContractResolver(),//key統一轉小寫
            Converters = new List<JsonConverter> { new DBNullCreationConverter(),new TrimCreationConverter() }//dbnull轉空字串且trim掉
        };

        Response.Write("{");
        Response.Write("\"opt\":" + JsonConvert.SerializeObject(dt_opt, settings).ToUnicode() + "\n");
        Response.Write(",\"cust\":" + JsonConvert.SerializeObject(dt_cust, settings).ToUnicode() + "\n");
        Response.Write(",\"att_list\":" + JsonConvert.SerializeObject(dt_attList, settings).ToUnicode() + "\n");
        Response.Write(",\"caseap\":" + JsonConvert.SerializeObject(dt_ap, settings).ToUnicode() + "\n");
        Response.Write(",\"casefee\":" + JsonConvert.SerializeObject(dt_casefee, settings).ToUnicode() + "\n");
        Response.Write(",\"arcase\":" + JsonConvert.SerializeObject(dt_arcase, settings).ToUnicode() + "\n");
        Response.Write(",\"arcase_item\":" + JsonConvert.SerializeObject(dt_arcaseItem, settings).ToUnicode() + "\n");
        Response.Write(",\"arcase_other\":" + JsonConvert.SerializeObject(dt_arcaseOther, settings).ToUnicode() + "\n");
        Response.Write(",\"casegood\":" + JsonConvert.SerializeObject(dt_casegood, settings).ToUnicode() + "\n");
        Response.Write(",\"tran\":" + JsonConvert.SerializeObject(dt_tran, settings).ToUnicode() + "\n");
        Response.Write(",\"tran_mod_client\":" + JsonConvert.SerializeObject(dt_tran_mod_client, settings).ToUnicode() + "\n");
        Response.Write(",\"tran_mod_dmt\":" + JsonConvert.SerializeObject(dt_tran_mod_dmt, settings).ToUnicode() + "\n");
        Response.Write(",\"tran_mod_pul\":" + JsonConvert.SerializeObject(dt_tran_mod_pul, settings).ToUnicode() + "\n");
        Response.Write(",\"tran_mod_ap\":" + JsonConvert.SerializeObject(dt_tran_mod_ap, settings).ToUnicode() + "\n");
        Response.Write(",\"tran_mod_aprep\":" + JsonConvert.SerializeObject(dt_tran_mod_aprep, settings).ToUnicode() + "\n");
        Response.Write(",\"tran_mod_claim1\":" + JsonConvert.SerializeObject(dt_tran_mod_claim1, settings).ToUnicode() + "\n");
        Response.Write(",\"tran_mod_class\":" + JsonConvert.SerializeObject(dt_tran_mod_class, settings).ToUnicode() + "\n");
        Response.Write(",\"brdmt_attach\":" + JsonConvert.SerializeObject(dt_brdmt_attach, settings).ToUnicode() + "\n");
        Response.Write(",\"opt_attach\":" + JsonConvert.SerializeObject(dt_opt_attach, settings).ToUnicode() + "\n");
        Response.Write("}");

        //Response.Write(JsonConvert.SerializeObject(rtnStr, Formatting.Indented, new DBNullCreationConverter()).ToUnicode());
    }

    private string showDRFile(string pBranch, string pFile) {
        //抓區所商標圖server主機名稱(iis)
        string uploadserver_name = Sys.webservername(pBranch);
        //SQL = "Select code_name,form_name from cust_code where code_type='OSerName' and cust_code='" + pBranch + "'";
        //DataTable dt = new DataTable();
        //
        //using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
        //    if (dr.Read()) {
        //        uploadserver_name = dr.SafeRead("form_name", "");
        //    }
        //    if (uploadserver_name == "") {
        //        if (Sys.Host == "web10") uploadserver_name = "web01";
        //        else if (Sys.Host == "web08") uploadserver_name = "web02";
        //        else uploadserver_name = Sys.Host;
        //    }
        //}

        string rtnStr = "";
        if (pFile.IndexOf("\\") > -1) {//絕對路徑
            string a = pFile.Replace("\\", "/").ToLower();//斜線改方向
            //擷取『/XT/』後(含)的字串
            rtnStr = "http://" + uploadserver_name + "/btbrt" + a.Substring(a.IndexOf("/" + branch + "t/", StringComparison.OrdinalIgnoreCase));
        } else {
            rtnStr = "http://" + uploadserver_name + pFile;
        }

        return rtnStr;
    }

    private string showBRDmtFile(string pBranch, string pFile, string tname) {
        string servername = Sys.webservername(pBranch);
        if (pFile.IndexOf(".") > -1) {//路徑包含檔案
            return "http://" + servername + pFile;
        } else {
            return "http://" + servername + pFile + "/" + tname;
        }
    }

    #region GetBROpt 案件資料
    private DataTable GetBROpt(string pBranch,string pOptSqlno) {
        using (DBHelper connopt = new DBHelper(Conn.optK, false)) {
            SQL = "Select *,''fseq,''drfile from vbr_opt where opt_sqlno='" + pOptSqlno + "' ";
            DataTable dt = new DataTable();
            connopt.DataTable(SQL, dt);
            if (dt.Rows.Count>0) {
                branch = dt.Rows[0].SafeRead("branch", "");
                opt_sqlno = dt.Rows[0].SafeRead("opt_sqlno", "");
                cust_area = dt.Rows[0].SafeRead("cust_area", "");
                cust_seq = dt.Rows[0].SafeRead("cust_seq", "");
                att_sql = dt.Rows[0].SafeRead("att_sql", "");
                arcase_type = dt.Rows[0].SafeRead("arcase_type", "");
                case_no = dt.Rows[0].SafeRead("case_no", "");

                dt.Rows[0]["fseq"] = Sys.formatSeq(dt.Rows[0].SafeRead("Bseq", ""), dt.Rows[0].SafeRead("Bseq1", ""), "", dt.Rows[0].SafeRead("Branch", ""), Sys.GetSession("dept"));
                dt.Rows[0]["drfile"] = showDRFile(pBranch,dt.Rows[0].SafeRead("draw_file", ""));
                dt.Rows[0]["send_dept"] = dt.Rows[0].SafeRead("send_dept", "B");
                
                if (dt.Rows[0].SafeRead("rs_type", "") == "") { dt.Rows[0]["rs_type"] = dt.Rows[0].SafeRead("arcase_type", ""); }
                if (dt.Rows[0].SafeRead("rs_code", "") == "") { dt.Rows[0]["rs_code"] = dt.Rows[0].SafeRead("arcase", ""); }
                if (dt.Rows[0].SafeRead("rs_class", "") == "") {
                    using (DBHelper connB = new DBHelper(strConnB, false)) {
                        SQL = "Select rs_class from code_br where rs_type='" + dt.Rows[0].SafeRead("rs_type", "") + "' and rs_code='" + dt.Rows[0].SafeRead("rs_code", "") + "' and cr='Y' ";
                        using (SqlDataReader dr = connB.ExecuteReader(SQL)) {
                            if (dr.Read()) {
                                dt.Rows[0]["rs_class"] = dr.SafeRead("rs_class", "").Trim();
                            }
                        }
                    }
                }
            }

            return dt;
        }
    }
    #endregion

    #region GetBRCust 案件客戶
    private DataTable GetBRCust(string pCustArea,string pCustSeq) {
        using (DBHelper connB = new DBHelper(strConnB, false)) {
            SQL = "Select *,''apclassnm,''ref_seqnm,''magnm ";
            SQL += "from vcustlist ";
            SQL += "where cust_area='" + pCustArea + "' and  cust_seq='" + pCustSeq + "' ";
            //Select * from vcustlist where cust_area='K' and cust_seq='6168'
            DataTable dt = new DataTable();
            connB.DataTable(SQL,dt);

            for (int i = 0; i < dt.Rows.Count; i++) {
                switch (dt.Rows[i].SafeRead("apclass", "").Trim()) {
                    case "AA": dt.Rows[i]["apclassnm"] = "本國公司機關無統編者"; break;
                    case "AB": dt.Rows[i]["apclassnm"] = "公司與機關團體(大企業)"; break;
                    case "AC": dt.Rows[i]["apclassnm"] = "公司與機關團體(小企業)"; break;
                    case "B": dt.Rows[i]["apclassnm"] = "本國人(身份證)"; break;
                    case "CA": dt.Rows[i]["apclassnm"] = "外國人(自動流水號)"; break;
                    case "CB": dt.Rows[i]["apclassnm"] = "外國人(智慧財產局編碼)"; break;
                    case "CT": dt.Rows[i]["apclassnm"] = "外國人(國外所申請人號)"; break;
                }

                if (dt.Rows[i].SafeRead("ref_seq", "").Trim() != "" && dt.Rows[i].SafeRead("ref_seq", "").Trim() != "0") {
                    SQL = "select ap_cname1,ap_cname2 from apcust where cust_seq='" + dt.Rows[i].SafeRead("ref_seq", "") + "' ";
                    using (SqlDataReader dr = connB.ExecuteReader(SQL)) {
                        if (dr.Read()) {
                            dt.Rows[i]["ref_seqnm"] = dr.SafeRead("ap_cname1", "").Trim() + dr.SafeRead("ap_cname2", "").Trim();
                        }
                    }
                }

                //配合區所顯示資料修改為下面寫法
                if (dt.Rows[i].SafeRead("mag", "").Trim() == "Y")
                    dt.Rows[i]["magnm"] = "需要";
                else
                    dt.Rows[i]["magnm"] = "不需要";
            }

            return dt;
        }
    }
    #endregion

    #region GetBRAtt 案件聯絡人
    private DataTable GetBRAtt(string pCustArea, string pCustSeq) {
        using (DBHelper connB = new DBHelper(strConnB, false)) {
            SQL = "Select *,''deptnm,''magnm ";
            SQL += "from custz_att ";
            SQL += "where cust_area='" + pCustArea + "' ";
            SQL += "and cust_seq='" + pCustSeq + "' ";
            DataTable dt = new DataTable();
            connB.DataTable(SQL, dt);

            for (int i = 0; i < dt.Rows.Count; i++) {
                if (dt.Rows[i].SafeRead("dept", "").Trim() == "T")
                    dt.Rows[i]["deptnm"] = "商標";
                else if (dt.Rows[i].SafeRead("dept", "").Trim() == "P")
                    dt.Rows[i]["deptnm"] = "專利";

                if (dt.Rows[i].SafeRead("att_mag", "").Trim() == "Y")
                    dt.Rows[i]["magnm"] = "需要";
                else
                    dt.Rows[i]["magnm"] = "不需要";
            }

            return dt;
        }
    }
    #endregion

    #region GetBRAP 案件申請人
    private DataTable GetBRAP(string pCaseNo) {
        using (DBHelper connB = new DBHelper(strConnB, false)) {
            SQL = "SELECT d.apsqlno,d.Server_flag,d.ap_cname1,d.ap_cname2,d.ap_ename1,d.ap_ename2 ";
            SQL += ",d.ap_fcname,d.ap_lcname,d.ap_fename,d.ap_lename ";
            SQL += ",d.ap_sql,d.ap_zip as dmt_ap_zip,d.ap_addr1 as dmt_ap_addr1,d.ap_addr2 as dmt_ap_addr2 ";
            SQL += ",d.ap_eaddr1 as dmt_ap_eaddr1,d.ap_eaddr2 as dmt_ap_eaddr2,d.ap_eaddr3 as dmt_ap_eaddr3,d.ap_eaddr4 as dmt_ap_eaddr4 ";
            SQL += ",a.apcust_no,a.Apclass,a.Ap_country,a.Ap_crep,a.Ap_erep,a.Ap_addr1,a.Ap_addr2 ";
            SQL += ",a.Ap_eaddr1,a.Ap_eaddr2,a.Ap_eaddr3,a.Ap_eaddr4 ";
            SQL += ",a.Apatt_zip,a.Apatt_addr1,a.Apatt_addr2,a.Apatt_tel0 ";
            SQL += ",a.Apatt_tel,a.Apatt_tel1,a.Apatt_fax,a.Ap_zip ";
            SQL += "From dmt_temp_ap as d ";
            SQL += "inner join apcust as a on d.apsqlno=a.apsqlno ";
            SQL += "inner join case_dmt as b on d.in_no=b.in_no ";
            SQL += "Where b.case_no = '" + pCaseNo + "' and d.case_sqlno=0 ";
            DataTable dt = new DataTable();
            connB.DataTable(SQL, dt);

            for (int i = 0; i < dt.Rows.Count; i++) {
                //因交辦案件申請人先前無中英文地址，當無申請人序號，則依申請人檔資料顯示
                //若申請人序號>=0，則以交辦案件申請人為準
                if (dt.Rows[i].SafeRead("ap_sql", "") == "") {
                    dt.Rows[i]["ap_sql"] = "0";
                } else {
                    dt.Rows[i]["ap_zip"] = dt.Rows[i].SafeRead("dmt_ap_zip", "");
                    dt.Rows[i]["ap_addr1"] = dt.Rows[i].SafeRead("dmt_ap_addr1", "");
                    dt.Rows[i]["ap_addr2"] = dt.Rows[i].SafeRead("dmt_ap_addr2", "");
                    dt.Rows[i]["ap_eaddr1"] = dt.Rows[i].SafeRead("dmt_ap_eaddr1", "");
                    dt.Rows[i]["ap_eaddr2"] = dt.Rows[i].SafeRead("dmt_ap_eaddr2", "");
                    dt.Rows[i]["ap_eaddr3"] = dt.Rows[i].SafeRead("dmt_ap_eaddr3", "");
                    dt.Rows[i]["ap_eaddr4"] = dt.Rows[i].SafeRead("dmt_ap_eaddr4", "");
                }
            }

            return dt;
        }
    }
    #endregion

    #region GetCaseFees 交辦費用
    private DataTable GetCaseFees(string pType, string pOptSqlno,string pCaseNo,string pBranch) {
        using (DBHelper connopt = new DBHelper(Conn.optK, false)) {
            SQL = "select a.item_sql,a.item_arcase,a.item_count,a.item_service,a.item_fees,b.prt_code,c.service,c.fees,c.others,c.oth_code,c.oth_code1 ";
            SQL += "from caseitem_opt a ";
            SQL += "inner join "+Sys.tdbname(pBranch)+".code_br b on  a.item_arcase=b.rs_code AND b.no_code='N' and b.rs_type='"+pType+"' ";
            SQL += "left outer join " + Sys.tdbname(pBranch) + ".case_fee c on c.dept='T' and c.country='T' and c.rs_code=a.item_arcase and getdate() between c.beg_date and c.end_date ";
            SQL += "where a.opt_sqlno='" + pOptSqlno + "' and a.Case_no= '" + pCaseNo + "' and a.Branch='" + pBranch + "' ";
            SQL += "order by a.item_sql";
            DataTable dt = new DataTable();
            connopt.DataTable(SQL, dt);

            return dt;
        }
    }
    #endregion

    #region GetArcase 委辦案性
    private DataTable GetArcase(string pType) {
        using (DBHelper connB = new DBHelper(strConnB, false)) {
            SQL = "SELECT rs_code,prt_code,rs_detail,remark ";
            SQL += "FROM code_br ";
            SQL += "WHERE  (mark = 'B' ) And cr= 'Y' and dept='T' And rs_type='" + pType + "' AND no_code='N' and getdate() >= beg_date ";
            SQL += "ORDER BY rs_code";
            DataTable dt = new DataTable();
            connB.DataTable(SQL, dt);

            return dt;
        }
    }
    #endregion

    #region GetArcaseItem 其他費用案性
    private DataTable GetArcaseItem() {
        using (DBHelper connB = new DBHelper(strConnB, false)) {
            SQL = "SELECT  rs_code, rs_detail ";
            SQL += "FROM code_br ";
            SQL += "WHERE rs_class = 'Z1' And cr= 'Y' and dept='T' AND no_code='N' and getdate() >= beg_date ";
            SQL += "ORDER BY rs_code";
            DataTable dt = new DataTable();
            connB.DataTable(SQL, dt);

            return dt;
        }
    }
    #endregion

    #region GetArcaseOther 轉帳費用案性
    private DataTable GetArcaseOther(string pType) {
        using (DBHelper connB = new DBHelper(strConnB, false)) {
            SQL = "SELECT rs_code,prt_code,rs_detail ";
            SQL += "FROM code_br ";
            SQL += "WHERE cr= 'Y' and dept='T' And rs_type='" + pType + "' AND no_code='N' and mark='M' ";
            SQL += "and getdate() >= beg_date and end_date is null ";
            SQL += "ORDER BY rs_code";
            DataTable dt = new DataTable();
            connB.DataTable(SQL, dt);

            return dt;
        }
    }
    #endregion

    #region GetCaseGood 類別
    private DataTable GetCaseGood(string pOptSqlno,string pCaseNo,string pBranch) {
        using (DBHelper connopt = new DBHelper(Conn.optK, false)) {
            SQL = "select * from  caseopt_good  where opt_sqlno='" + pOptSqlno + "' and case_no= '" + pCaseNo + "' and branch='" + pBranch + "'";
            DataTable dt = new DataTable();
            connopt.DataTable(SQL, dt);

            return dt;
        }
    }
    #endregion

    #region GetTran 異動
    private DataTable GetTran(string pOptSqlno) {
        using (DBHelper connopt = new DBHelper(Conn.optK, false)) {
            SQL = "select * from opt_tran where opt_sqlno='" + pOptSqlno + "'";
            DataTable dt = new DataTable();
            connopt.DataTable(SQL, dt);

            return dt;
        }
    }
    #endregion

    #region GetTranModClient 異動關係人
    private DataTable GetTranModClient(string pCaseNo,string pOptSqlno) {
        using (DBHelper connopt = new DBHelper(Conn.optK, false)) {
            SQL = "select * from opt_tranlist where case_no='" + pCaseNo + "' and opt_sqlno='" + pOptSqlno + "' and mod_field='mod_client'";
            DataTable dt = new DataTable();
            connopt.DataTable(SQL, dt);

            return dt;
        }
    }
    #endregion

    #region GetTranModDmt 
    private DataTable GetTranModDmt(string pCaseNo,string pOptSqlno) {
        using (DBHelper connopt = new DBHelper(Conn.optK, false)) {
            SQL = "select *,''mod_dmt_ncname1,''mod_dmt_ncname2,''mod_dmt_nename1,''mod_dmt_nename2 ";
            SQL += ",''mod_dmt_ncrep,''mod_dmt_nerep ";
            SQL += ",''mod_dmt_neaddr1,''mod_dmt_neaddr2,''mod_dmt_neaddr3,''mod_dmt_neaddr4 ";
            SQL += "from opt_tranlist where case_no='" + pCaseNo + "' and opt_sqlno='" + pOptSqlno + "' and mod_field='mod_dmt'";
            DataTable dt = new DataTable();
            connopt.DataTable(SQL, dt);

            for (int i = 0; i < dt.Rows.Count; i++) {
                dt.Rows[i]["mod_dmt_ncname1"] = showDRFile(dt.Rows[i].SafeRead("branch", ""), dt.Rows[i].SafeRead("ncname1", ""));
                dt.Rows[i]["mod_dmt_ncname2"] = showDRFile(dt.Rows[i].SafeRead("branch", ""), dt.Rows[i].SafeRead("ncname2", ""));
                dt.Rows[i]["mod_dmt_nename1"] = showDRFile(dt.Rows[i].SafeRead("branch", ""), dt.Rows[i].SafeRead("nename1", ""));
                dt.Rows[i]["mod_dmt_nename2"] = showDRFile(dt.Rows[i].SafeRead("branch", ""), dt.Rows[i].SafeRead("nename2", ""));
                dt.Rows[i]["mod_dmt_ncrep"] = showDRFile(dt.Rows[i].SafeRead("branch", ""), dt.Rows[i].SafeRead("ncrep", ""));
                dt.Rows[i]["mod_dmt_nerep"] = showDRFile(dt.Rows[i].SafeRead("branch", ""), dt.Rows[i].SafeRead("nerep", ""));
                dt.Rows[i]["mod_dmt_neaddr1"] = showDRFile(dt.Rows[i].SafeRead("branch", ""), dt.Rows[i].SafeRead("neaddr1", ""));
                dt.Rows[i]["mod_dmt_neaddr2"] = showDRFile(dt.Rows[i].SafeRead("branch", ""), dt.Rows[i].SafeRead("neaddr2", ""));
                dt.Rows[i]["mod_dmt_neaddr3"] = showDRFile(dt.Rows[i].SafeRead("branch", ""), dt.Rows[i].SafeRead("neaddr3", ""));
                dt.Rows[i]["mod_dmt_neaddr4"] = showDRFile(dt.Rows[i].SafeRead("branch", ""), dt.Rows[i].SafeRead("neaddr4", ""));
            }

            return dt;
        }
    }
    #endregion

    #region GetTranModPul
    private DataTable GetTranModPul(string pCaseNo, string pOptSqlno) {
        using (DBHelper connopt = new DBHelper(Conn.optK, false)) {
            SQL = "select * ";
            SQL += "from opt_tranlist where case_no='" + pCaseNo + "' and opt_sqlno='" + pOptSqlno + "' and mod_field='mod_pul'";
            DataTable dt = new DataTable();
            connopt.DataTable(SQL, dt);

            return dt;
        }
    }
    #endregion

    #region GetTranModAp
    private DataTable GetTranModAp(string pCaseNo, string pOptSqlno) {
        using (DBHelper connopt = new DBHelper(Conn.optK, false)) {
            SQL = "select * ";
            SQL += "from opt_tranlist where case_no='" + pCaseNo + "' and opt_sqlno='" + pOptSqlno + "' and mod_field='mod_ap'";
            DataTable dt = new DataTable();
            connopt.DataTable(SQL, dt);

            return dt;
        }
    }
    #endregion

    #region GetTranModAprep
    private DataTable GetTranModAprep(string pCaseNo, string pOptSqlno) {
        using (DBHelper connopt = new DBHelper(Conn.optK, false)) {
            SQL = "select * ";
            SQL += "from opt_tranlist where case_no='" + pCaseNo + "' and opt_sqlno='" + pOptSqlno + "' and mod_field='mod_aprep'";
            DataTable dt = new DataTable();
            connopt.DataTable(SQL, dt);

            return dt;
        }
    }
    #endregion

    #region GetTranModClaim1
    private DataTable GetTranModClaim1(string pCaseNo, string pOptSqlno) {
        using (DBHelper connopt = new DBHelper(Conn.optK, false)) {
            SQL = "select * ";
            SQL += "from opt_tranlist where case_no='" + pCaseNo + "' and opt_sqlno='" + pOptSqlno + "' and mod_field='mod_claim1'";
            DataTable dt = new DataTable();
            connopt.DataTable(SQL, dt);

            return dt;
        }
    }
    #endregion

    #region GetTranModClass
    private DataTable GetTranModClass(string pCaseNo, string pOptSqlno) {
        using (DBHelper connopt = new DBHelper(Conn.optK, false)) {
            SQL = "select *,''mod_class_ncname1,''mod_class_ncname2,''mod_class_nename1,''mod_class_nename2 ";
            SQL += ",''mod_class_ncrep,''mod_class_nerep ";
            SQL += ",''mod_class_neaddr1,''mod_class_neaddr2,''mod_class_neaddr3,''mod_class_neaddr4 ";
            SQL += "from opt_tranlist where case_no='" + pCaseNo + "' and opt_sqlno='" + pOptSqlno + "' and mod_field='mod_class'";
            DataTable dt = new DataTable();
            connopt.DataTable(SQL, dt);

            for (int i = 0; i < dt.Rows.Count; i++) {
                dt.Rows[i]["mod_class_ncname1"] = showDRFile(dt.Rows[i].SafeRead("branch", ""), dt.Rows[i].SafeRead("ncname1", ""));
                dt.Rows[i]["mod_class_ncname2"] = showDRFile(dt.Rows[i].SafeRead("branch", ""), dt.Rows[i].SafeRead("ncname2", ""));
                dt.Rows[i]["mod_class_nename1"] = showDRFile(dt.Rows[i].SafeRead("branch", ""), dt.Rows[i].SafeRead("nename1", ""));
                dt.Rows[i]["mod_class_nename2"] = showDRFile(dt.Rows[i].SafeRead("branch", ""), dt.Rows[i].SafeRead("nename2", ""));
                dt.Rows[i]["mod_class_ncrep"] = showDRFile(dt.Rows[i].SafeRead("branch", ""), dt.Rows[i].SafeRead("ncrep", ""));
                dt.Rows[i]["mod_class_nerep"] = showDRFile(dt.Rows[i].SafeRead("branch", ""), dt.Rows[i].SafeRead("nerep", ""));
                dt.Rows[i]["mod_class_neaddr1"] = showDRFile(dt.Rows[i].SafeRead("branch", ""), dt.Rows[i].SafeRead("neaddr1", ""));
                dt.Rows[i]["mod_class_neaddr2"] = showDRFile(dt.Rows[i].SafeRead("branch", ""), dt.Rows[i].SafeRead("neaddr2", ""));
                dt.Rows[i]["mod_class_neaddr3"] = showDRFile(dt.Rows[i].SafeRead("branch", ""), dt.Rows[i].SafeRead("neaddr3", ""));
                dt.Rows[i]["mod_class_neaddr4"] = showDRFile(dt.Rows[i].SafeRead("branch", ""), dt.Rows[i].SafeRead("neaddr4", ""));
            }

            return dt;
        }
    }
    #endregion

    #region GetBRDmtAttach
    private DataTable GetBRDmtAttach(string pCaseNo) {
        using (DBHelper connB = new DBHelper(strConnB, false)) {
            SQL = "select *,''preview_path ";
            SQL += "from dmt_attach ";
            SQL += "where case_no='" +pCaseNo+ "' and source='case' and attach_flag<>'D' and attach_branch='B' ";
            SQL += " order by attach_sqlno ";

            DataTable dt = new DataTable();
            connB.DataTable(SQL,dt);
            for (int i = 0; i < dt.Rows.Count; i++) {
                dt.Rows[i]["preview_path"] = showBRDmtFile(branch, dt.Rows[i].SafeRead("attach_path", ""), dt.Rows[i].SafeRead("attach_name", ""));
            }

            return dt;
        }
    }
    #endregion

    #region GetOptAttach
    private DataTable GetOptAttach(string pOptSqlno) {
        using (DBHelper connopt = new DBHelper(Conn.optK, false)) {
            SQL = "select * ";
            SQL += ",(Select sc_name from sysctrl.dbo.scode where scode=add_scode) as add_scodenm ";
            SQL += " from attach_opt ";
            SQL += " where opt_sqlno='" + opt_sqlno + "' and attach_flag<>'D' ";
            SQL += " order by opt_sqlno,attach_no ";

            DataTable dt = new DataTable();
            connopt.DataTable(SQL, dt);

            return dt;
        }
    }
    #endregion
</script>
