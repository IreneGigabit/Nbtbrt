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
    protected object objResult = null;

    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();

    Dictionary<string, string> step_data = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    //管制資料
    DataTable dtCtrl = new DataTable();
    //總管處官收電子公文檔
    DataTable dtMGAttach = new DataTable();
    //官收自行客戶報導文件
    DataTable dtGRAttach = new DataTable();
    //對應客收交辦
    DataTable dtCaseCR = new DataTable();
    //客收規費明細
    DataTable dtFees = new DataTable();

    DBHelper conn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    private void Page_Unload(System.Object sender, System.EventArgs e) {
        if (conn != null) conn.Dispose();
    }

    protected void Page_Load(object sender, EventArgs e) {
        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");

        conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
        if (ReqVal.TryGet("type") == "brtran") {
            conn = new DBHelper(Conn.brp(Request["branch"])).Debug(Request["chkTest"] == "TEST");
        }

        string rs_no = ReqVal.TryGet("rs_no");
        string rs_sqlno = ReqVal.TryGet("rs_sqlno");
        string seq = ReqVal.TryGet("seq");
        string seq1 = ReqVal.TryGet("seq1");

        SQL = "Select * From vstep_dmt Where 1=1";
        if (rs_no!="") SQL += "and RS_No = '" + rs_no + "'";
        if (rs_sqlno != "") SQL += "and rs_sqlno = '" + rs_sqlno + "'";
        DataTable dtStep = new DataTable();
        conn.DataTable(SQL, dtStep);

        if (dtStep.Rows.Count > 0) {
            DataRow dr = dtStep.Rows[0];

            step_data = dr.Table.Columns.Cast<DataColumn>()
            .ToDictionary(col => col.ColumnName, col => dr.SafeRead(col.ColumnName, ""));

            step_data["fseq"] = Sys.formatSeq(step_data["seq"], step_data["seq1"], "", Sys.GetSession("seBranch"), Sys.GetSession("dept"));
            step_data["nstep_grade"] = dr.SafeRead("step_grade", "");
            step_data["cgrs"] = dr.SafeRead("cg", "").ToUpper() + dr.SafeRead("rs", "").ToUpper();
            step_data["step_date"] = dr.GetDateTimeString("step_date", "yyyy/M/d");
            step_data["mp_date"] = dr.GetDateTimeString("mp_date", "yyyy/M/d");
            step_data["gov_date"] = dr.GetDateTimeString("gov_date", "yyyy/M/d");
            step_data["oact_code"] = dr.SafeRead("act_code", "");
            step_data["pmail_date"] = dr.GetDateTimeString("pmail_date", "yyyy/M/d");

            //取得結構分類、代碼、處理事項名稱
            SQL = "select code_name from cust_code where code_type='" + step_data["rs_type"] + "' and cust_code='" + step_data["rs_class"] + "'";
            objResult = conn.ExecuteScalar(SQL);
            step_data["rs_class_name"] = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();
            SQL = "select rs_detail from code_br where rs_type='" + step_data["rs_type"] + "' and rs_code='" + step_data["rs_code"] + "' and " + (step_data["cgrs"] == "ZS" ? "CR" : step_data["cgrs"]) + "='Y' ";
            objResult = conn.ExecuteScalar(SQL);
            step_data["rs_code_name"] = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();
            SQL = "select code_name from cust_code where code_type='tact_code' and cust_code='" + step_data["act_code"] + "'";
            objResult = conn.ExecuteScalar(SQL);
            step_data["act_code_name"] = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();

            //取得案件狀態
            SQL = " select rs_type,rs_class,rs_code,act_code,case_stat,case_stat_name ";
            SQL += "from vcode_act ";
            SQL += "where rs_code = '" + step_data["rs_code"] + "' ";
            SQL += "and act_code = '" + step_data["act_code"] + "' ";
            SQL += "and rs_type = '" + step_data["rs_type"] + "'";
            SQL += "and cg = '" + step_data["cg"] + "'";
            SQL += "and rs = '" + step_data["rs"] + "'";
            using (SqlDataReader dr0 = conn.ExecuteReader(SQL)) {
                if (dr0.Read()) {
                    step_data["ocase_stat"] = dr0.SafeRead("case_stat", "");
                    step_data["case_stat"] = dr0.SafeRead("case_stat", "");
                    step_data["case_statnm"] = dr0.SafeRead("case_stat_name", "");
                    step_data["ncase_stat"] = dr0.SafeRead("case_stat", "");
                    step_data["ncase_statnm"] = dr0.SafeRead("case_stat_name", "");
                }
            }

            step_data["cs_detail"] = "";
            if (step_data["cs_rs_no"] != "") {
                SQL = " select rs_no,rs_detail,send_way,print_date,mail_date,mail_scode,mwork_date";
                SQL += ",(select sc_name from sysctrl.dbo.scode where scode=mail_scode) as mail_scname ";
                SQL += "from cs_dmt ";
                SQL += "where rs_no = '" + step_data["cs_rs_no"] + "' ";
                using (SqlDataReader dr0 = conn.ExecuteReader(SQL)) {
                    if (dr0.Read()) {
                        step_data["cs_detail"] = dr0.SafeRead("rs_detail", "");
                        step_data["send_way"] = dr0.SafeRead("send_way", "");
                        step_data["print_date"] = dr0.SafeRead("print_date", "");
                        step_data["mail_date"] = dr0.GetDateTimeString("mail_date", "yyyy/M/d");
                        step_data["mail_scode"] = dr0.SafeRead("mail_scode", "");
                        step_data["mail_scname"] = dr0.SafeRead("mail_scname", "");
                        step_data["mwork_date"] = dr0.SafeRead("mwork_date", "");
                    }
                }
            }
            
            step_data["codemark"] = "";
            if (step_data["opt_stat"] == "") {
                SQL = "select mark from code_br where mark='B' and rs_type='" + step_data["rs_type"] + "' and rs_class ='" + step_data["rs_class"] + "'";
                SQL += " and " + (step_data["cgrs"] == "ZS" ? "CR" : step_data["cgrs"]) + "='Y' and rs_code = '" + step_data["rs_code"] + "'";
                step_data["codemark"] = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();
            } else {
                step_data["codemark"] = "B";
            }
        
            //取得發文出名代理人
            step_data["rs_agt_nonm"] = "";
            SQL = "select treceipt+'_'+agt_name from agt where agt_no='" + step_data["rs_agt_no"] + "'";
            objResult = conn.ExecuteScalar(SQL);
            step_data["rs_agt_nonm"] = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();

            //抓取官收營洽確認資料
            SQL = "select * from grconf_dmt where seq=" + step_data["seq"] + " and seq1='" + step_data["seq1"] + "' and step_grade=" + step_data["nstep_grade"];
            using (SqlDataReader dr0 = conn.ExecuteReader(SQL)) {
                if (dr0.Read()) {
                    step_data["cs_flag"] = dr0.SafeRead("cs_flag", "");
                    step_data["scs_detail"] = dr0.SafeRead("scs_detail", "");
                    step_data["cs_send_way"] = dr0.SafeRead("cs_send_way", "");
                    step_data["last_date"] = dr0.GetDateTimeString("last_date", "yyyy/M/d");
                    step_data["pstep_date"] = dr0.GetDateTimeString("pstep_date", "yyyy/M/d");
                    step_data["job_type"] = dr0.SafeRead("job_type", "");
                    step_data["job_case"] = dr0.SafeRead("job_case", "");
                    step_data["pre_date"] = dr0.GetDateTimeString("pre_date", "yyyy/M/d");
                    step_data["sales_remark"] = dr0.SafeRead("sales_remark", "");
                    step_data["cs_report"] = dr0.SafeRead("cs_report", "");
                    step_data["job_no"] = dr0.SafeRead("job_no", "");
                }
            }

            //抓取文件掃描資料
            //因電子收文有公文檔，所以掃描不一定放第一順位，改用order by抓第一筆掃描資料
            SQL = " select chk_page,attach_path,attach_desc from dmt_attach where seq=" + step_data["seq"] + " and seq1='" + step_data["seq1"] + "' and step_grade=" + step_data["nstep_grade"] + " and source='scan' and chk_status like 'Y%' order by attach_no ";
            using (SqlDataReader dr0 = conn.ExecuteReader(SQL)) {
                if (dr0.Read()) {
                    step_data["pr_scan"] = "Y";
                    step_data["pr_scan_page"] = dr0.SafeRead("chk_page", "");
                    step_data["pr_scan_path"] = Sys.Path2Nbtbrt(dr0.SafeRead("attach_path", ""));
                    step_data["pr_scan_remark"] = dr0.SafeRead("attach_desc", "");
                }
            }

            //取得總收發文收文內容
            step_data["mg_rs_detail"] = "";
            if (dr.SafeRead("mg_rs_sqlno", "") != "") {
                SQL = " select rs_detail from step_mgt_temp where mg_step_rs_sqlno='" + dr.SafeRead("mg_rs_sqlno", "") + "' ";
                using (SqlDataReader dr0 = conn.ExecuteReader(SQL)) {
                    if (dr0.Read()) {
                        step_data["mg_rs_detail"] = dr0.SafeRead("rs_detail", "");
                    }
                }
            }

            //取得官收時智慧局電子公文檔
            step_data["pdfsource"] = "GR";
            //2019/6/18修改，電子公文receive_way=R9其source=EGR，其餘皆為GR，路徑只有電子公文會不同須判斷，其餘都直接連到總管處顯示
            if (step_data["receive_way"] == "R9") {//R9_電子公文
                step_data["pdfsource"] = "EGR";
            }
            SQL = "select attach_path,attach_name,source,''view_path ";
            SQL += " from dmt_attach ";
            SQL += "where seq=" + step_data["seq"] + " and seq1='" + step_data["seq1"] + "' and step_grade=" + step_data["nstep_grade"];
            SQL += "  and source='" + step_data["pdfsource"] + "' and attach_flag<>'D' ";
            SQL += "order by attach_sqlno ";
            conn.DataTable(SQL, dtMGAttach);
            for (int i = 0; i < dtMGAttach.Rows.Count; i++) {
                DataRow dr0 = dtMGAttach.Rows[i];
                string attach_path = Sys.Path2Nbtbrt(dr0.SafeRead("attach_path", ""));
                string viewserver = "http://" + Sys.Host;

                //若區所主機找不到就找總所主機
                if (Sys.CheckFile(attach_path) == false) {
                    viewserver = "http://" + Sys.MG_IIS;
                    if (step_data["pdfsource"] == "EGR") {
                        attach_path = attach_path.Replace("/nbtbrt/", "/MG/");
                    }
                }
                dr0["attach_path"] = attach_path;
                dr0["view_path"] = viewserver + attach_path;
            }

            //取得官收確認自行客戶報導文件
            SQL = "select *,''view_path from dmt_attach where seq='" + seq + "' and seq1='" + seq1 + "' and step_grade=" + step_data["nstep_grade"] + " and source='grconf_cs' and attach_flag<>'D' order by attach_sqlno ";
            conn.DataTable(SQL, dtGRAttach);
            for (int i = 0; i < dtGRAttach.Rows.Count; i++) {
                DataRow dr0 = dtGRAttach.Rows[i];
                string attach_path = Sys.Path2Nbtbrt(dr0.SafeRead("attach_path", ""));
                string viewserver = "http://" + Sys.Host;

                dr0["attach_path"] = attach_path;
                dr0["view_path"] = viewserver + attach_path;
            }

            //取得本發時對應客收交辦
            DataTable dtStepCR = Sys.StepDmt(conn, step_data["seq"], step_data["seq1"], "and zs_rs_sqlno='" + dr.SafeRead("rs_sqlno", "") + "'");
            if (dtStepCR.Rows.Count > 0) {
                dtCaseCR = Sys.GetCaseDmtMain(conn, seq, seq1, dtStepCR.Rows[0].SafeRead("case_no", ""));
            }

            //抓取客收規費明細
            SQL = " select a.rs_no,a.case_no,a.fees,b.arcase,b.arcase_type,b.arcase_class,(b.fees+b.add_fees) as case_fees,b.change";
            SQL += ",b.gs_fees,(b.service+b.add_service) as service,b.ar_mark,b.gs_curr,c.agt_no";
            SQL += ",(select agt_name from agt where agt_no=c.agt_no) as agt_name";
            SQL += ",(select treceipt from agt where agt_no=c.agt_no) as receipt";
            SQL += ",(SELECT rs_detail FROM code_br WHERE rs_type=b.arcase_type and rs_code=b.arcase AND dept= 'T' AND gs='Y') as arcasenm";
            SQL += ",(select code_name from cust_code where code_type='AR_MARK' and cust_code = b.ar_mark) as ar_marknm";
            SQL += " from fees_dmt a,case_dmt b,dmt_temp c where rs_no='" + step_data["rs_no"] + "'";
            SQL += " and a.case_no = b.case_no and b.in_no=c.in_no and c.case_sqlno=0";
            SQL += " order by a.case_no";
            conn.DataTable(SQL, dtFees);

            //取得in_no
            SQL = "select in_scode,in_no,arcase_type,arcase_class,arcase,change,receipt_type,receipt_title";
            SQL += ",(select rs_class from code_br where rs_type=a.arcase_type and rs_code=a.arcase) as case_rs_class";
            SQL += " from case_dmt a where case_no = '" + step_data["case_no"] + "'";
            using (SqlDataReader dr0 = conn.ExecuteReader(SQL)) {
                if (dr0.Read()) {
                    step_data["in_scode"] = dr0.SafeRead("in_scode", "");
                    step_data["in_no"] = dr0.SafeRead("in_no", "");
                }
            }

            //管制資料
            SQL = " select sqlno,ctrl_type,ctrl_remark,ctrl_date,null as resp_date,null as resp_grade from ctrl_dmt ";
            SQL += " where rs_no='" + step_data["rs_no"] + "'";
            SQL += " union select sqlno,ctrl_type,ctrl_remark,ctrl_date,resp_date,resp_grade from resp_dmt ";
            SQL += " where rs_no='" + step_data["rs_no"] + "'";
            SQL += " order by ctrl_date";
            conn.DataTable(SQL, dtCtrl);
        }
        
        var settings = new JsonSerializerSettings()
        {
            Formatting = Formatting.Indented,
            ContractResolver = new LowercaseContractResolver(),//key統一轉小寫
            Converters = new List<JsonConverter> { new DBNullCreationConverter(), new TrimCreationConverter() }//dbnull轉空字串且trim掉
        };
        Response.Write("{");
        Response.Write("\"request\":" + JsonConvert.SerializeObject(ReqVal, settings).ToUnicode() + "\n");
        Response.Write(",\"step_data\":" + JsonConvert.SerializeObject(step_data, settings).ToUnicode() + "\n");//交辦官發預設值
        Response.Write(",\"mg_attach\":" + JsonConvert.SerializeObject(dtMGAttach, settings).ToUnicode() + "\n");//總管處官收電子公文檔
        Response.Write(",\"gr_attach\":" + JsonConvert.SerializeObject(dtGRAttach, settings).ToUnicode() + "\n");//官收確認自行客戶報導文件
        Response.Write(",\"cr_case\":" + JsonConvert.SerializeObject(dtCaseCR, settings).ToUnicode() + "\n");//本發時對應客收交辦
        Response.Write(",\"fees\":" + JsonConvert.SerializeObject(dtFees, settings).ToUnicode() + "\n");//規費明細
        Response.Write(",\"ctrl_data\":" + JsonConvert.SerializeObject(dtCtrl, settings).ToUnicode() + "\n");//管制資料
        Response.Write("}");
    }
</script>
