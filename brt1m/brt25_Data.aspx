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
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected string submitTask = "";
    protected string SQL = "";

    protected string seq = "";
    protected string seq1 = "";
    protected string case_no = "";
    protected string todo_sqlno = "";
    protected string from_flag = "";
    protected string scode1 = "";
    protected string in_no = "";
    protected string in_scode = "";

    protected string fseq = "";
    protected string cappl_name = "";
    protected string step_grade = "";
    protected string rs_detail = "";
    protected string cust_area = "";
    protected string cust_seq = "";
    protected string ap_cname = "";
    protected string apcust_name = "";
    
    protected string maintable = "";
    protected string aptable = "";
    protected string casetable = "";
    protected string attachtable = "";
    protected string step_table = "";

    protected void Page_Load(object sender, EventArgs e) {
        submitTask = (Request["submittask"] ?? "").Trim();
        seq = (Request["seq"] ?? "").Trim();
        seq1 = (Request["seq1"] ?? "").Trim();
        case_no = (Request["case_no"] ?? "").Trim();
        todo_sqlno = (Request["todo_sqlno"] ?? "").Trim();
        from_flag = (Request["from_flag"] ?? "").Trim();
        scode1 = (Request["scode1"] ?? "").Trim();
        in_no = (Request["in_no"] ?? "").Trim();
        in_scode = (Request["in_scode"] ?? "").Trim();

        if (prgid.Left(3)=="brt"){
            maintable = "dmt";
            aptable = "dmt_ap";
            casetable = "case_dmt";
            attachtable = "dmt_attach";
            step_table = "step_dmt";
        }else if (prgid.Left(3)=="ext"){
            maintable = "ext";
            aptable = "ext_apcust";
            casetable = "case_ext";
            attachtable = "caseattach_ext";
            step_table = "step_ext";
        }
    
        var settings = new JsonSerializerSettings()
        {
            Formatting = Formatting.Indented,
            ContractResolver = new LowercaseContractResolver(),//key統一轉小寫
            Converters = new List<JsonConverter> { new DBNullCreationConverter(), new TrimCreationConverter() }//dbnull轉空字串且trim掉
        };
        
        //Response.Write("{");
        //Response.Write("\"main\":" + JsonConvert.SerializeObject(GetMain(), settings).ToUnicode() + "\n");
        //Response.Write(",\"case_contract\":" + JsonConvert.SerializeObject(GetCaseContract(), settings).ToUnicode() + "\n");//交辦內容
        //Response.Write(",\"apcust_attach\":" + JsonConvert.SerializeObject(GetApcustAttach(), settings).ToUnicode() + "\n");
        //Response.Write("}");

        Response.Write(JsonConvert.SerializeObject(GetMain(), settings).ToUnicode());
    }

    #region GetMain 交辦資料
    //private JObject GetMain() {
    //    JObject obj = new JObject();
    //    obj.Add("cust_area", JToken.FromObject(cust_area));
    //    obj.Add("cust_seq", JToken.FromObject(cust_seq));
    //    obj.Add("cust_seq", JToken.FromObject(cust_seq));
    //    return obj;
    //}

    private DataTable GetMain() {
        DataTable dt = new DataTable();
        using (DBHelper conn = new DBHelper(Conn.btbrt, false)) {
            SQL = "select scode as scode1,cust_area,cust_seq,appl_name as cappl_name ";
            if(prgid.Left(2)=="ex"){
                SQL += ",country";
            }else{
                SQL += ",'' as country";
            }
            SQL += ",(select sc_name from sysctrl.dbo.scode where scode=d.scode) as scode1nm";
            SQL += ",(select ap_cname1+isnull(ap_cname2,'') from apcust where cust_area=d.cust_area and cust_seq=d.cust_seq) as ap_cname";
            SQL += ",''fseq,''apcust_name,''step_grade,''rs_detail ";
            SQL += ",''contract_type,''contract_no,''contract_remark,''ar_mark,''acc_chk ";
            SQL += ",''mattach_path ";
            SQL += " from "+maintable+" d ";
            SQL += " where seq='" + seq + "' and seq1='" + seq1 + "' ";
            conn.DataTable(SQL, dt);

            if (dt.Rows.Count > 0) {
                //組本所編號
                dt.Rows[0]["fseq"]=Sys.formatSeq(seq, seq1, dt.Rows[0].SafeRead("country", ""), Sys.GetSession("seBranch"), "T" + ((prgid.ToLower().Left(2) == "ex") ? "E" : ""));
                //申請人
                apcust_name = "";
                if (prgid.ToLower().Left(2) == "ex") {
                    SQL = "select * from "+aptable+" where seq='" + seq + "' and seq1='" + seq1 + "' order by sqlno";
                    using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
                        while (dr.Read()) {
                            apcust_name += (apcust_name != "" ? "、" : "") + dr.SafeRead("apcust_no", "") + dr.SafeRead("ap_cname1", "") + dr.SafeRead("ap_cname2", "");
                        }
                    }
                } else {
                    SQL = "select * from "+aptable+" where seq='" + seq + "' and seq1='" + seq1 + "' order by dmt_ap_sqlno";
                    using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
                        while (dr.Read()) {
                            apcust_name += (apcust_name != "" ? "、" : "") + dr.SafeRead("apcust_no", "") + dr.SafeRead("ap_cname", "");
                        }
                    }
                }
                dt.Rows[0]["apcust_name"] = apcust_name;
            }

            //進度
            SQL = "select step_grade,rs_detail from "+step_table+" ";
            SQL += " where seq='" + seq + "' and seq1='" + seq1 + "' and cg='C' and rs='R' ";
            SQL += " and case_no='" + case_no + "' ";
            using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
                if (dr.Read()) {
                    dt.Rows[0]["step_grade"] = dr.SafeRead("step_grade", "");
                    dt.Rows[0]["rs_detail"] = dr.SafeRead("rs_detail", "");
                }
            }

            //抓取ar_mark,acc_chk為判斷後續流程是否至會計契約書檢核
            SQL = "select contract_type,contract_no,contract_remark,ar_mark,acc_chk ";
            SQL += " from " + casetable + " ";
            SQL += " where seq='" + seq + "' and seq1='" + seq1 + "' ";
            SQL += " and case_no='" + case_no + "' ";
            using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
                if (dr.Read()) {
                    dt.Rows[0]["contract_type"] = dr.SafeRead("contract_type", "");
                    dt.Rows[0]["contract_no"] = dr.SafeRead("contract_no", "");
                    dt.Rows[0]["contract_remark"] = dr.SafeRead("contract_remark", "");
                    dt.Rows[0]["ar_mark"] = dr.SafeRead("ar_mark", "");
                    dt.Rows[0]["acc_chk"] = dr.SafeRead("acc_chk", "");
                }
            }

            //抓取總契約書
            SQL = "select b.attach_path as mattach_path ";
            SQL += " from " + attachtable + " a ";
            SQL+=" left join apcust_attach b on a.apattach_sqlno=b.apattach_sqlno ";
              if(prgid.Left(2)=="ex"){
                SQL += " where in_no='" +in_no+ "' ";
            }else{
                SQL += " where seq='" + seq + "' and seq1='" + seq1 + "' ";
            }
            using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
                if (dr.Read()) {
                    dt.Rows[0]["mattach_path"] = Sys.Path2Nbtbrt(dr.SafeRead("mattach_path", ""));
                }
            }
        }
        return dt;
    }
    #endregion

    #region GetCaseContract 交辦契約書後補內容
    private DataTable GetCaseContract() {
        DataTable dt = new DataTable();
        using (DBHelper conn = new DBHelper(Conn.btbrt).Debug(false)) {
            //抓取ar_mark,acc_chk為判斷後續流程是否至會計契約書檢核
            SQL = "select contract_type,contract_no,contract_remark,ar_mark,acc_chk ";
            SQL += " from " + casetable + " ";
            SQL += " where seq='" + seq + "' and seq1='" + seq1 + "' ";
            SQL += " and case_no='" + case_no + "' ";
            conn.DataTable(SQL, dt);
        }
        return dt;
    }
    #endregion

    #region GetMContract 抓總契約書
    private DataTable GetMContract() {
        DataTable dt = new DataTable();
        using (DBHelper conn = new DBHelper(Conn.btbrt).Debug(false)) {
            SQL = "select b.attach_path as mattach_path ";
            SQL += " from " + attachtable + " a ";
            SQL += " left join apcust_attach b on a.apattach_sqlno=b.apattach_sqlno ";
            if (prgid.Left(2) == "ex") {
                SQL += " where in_no='" + in_no + "' ";
            } else {
                SQL += " where seq='" + seq + "' and seq1='" + seq1 + "' ";
            }
            conn.DataTable(SQL, dt);
        }
        return dt;
    }
    #endregion
</script>
