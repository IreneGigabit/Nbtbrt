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

    //protected string seq = "";
    //protected string seq1 = "";
    //protected string step_grade = "";
    //protected string source = "";
    //protected string in_no = "";
    //protected string attach_sqlno = "";
    //protected string att_sqlno = "";
    //protected string attach_flagtran = "";
    //protected string tran_sqlno = "";

    DataTable dtDmt = new DataTable();
    DataTable dtStepDmt = new DataTable();
    DataTable dtDmtAttach = new DataTable();
    Dictionary<string, string> ReqVal = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);

    DBHelper conn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    private void Page_Unload(System.Object sender, System.EventArgs e) {
        if (conn != null) conn.Dispose();
    }
    
    protected void Page_Load(object sender, EventArgs e) {
        conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");

        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");
        ReqVal["seq"] = (Request["seq"] ?? "").Trim();
        ReqVal["seq1"] = (Request["seq1"] ?? "").Trim();
        if (ReqVal["seq1"] == "") ReqVal["seq1"] = "_";
        ReqVal["step_grade"] = (Request["step_grade"] ?? "").Trim();
        if (ReqVal["step_grade"] == "") ReqVal["step_grade"] = "0";
        ReqVal["source"] = (Request["source"] ?? "").Trim();
        if (ReqVal["source"] == "tran") ReqVal["step_grade"] = "";//轉案沒有setep_grade
        ReqVal["in_no"] = (Request["in_no"] ?? "").Trim();//接洽序號
        ReqVal["attach_sqlno"] = (Request["attach_sqlno"] ?? "").Trim();//dmt_attach.attach_sqlno
        ReqVal["att_sqlno"] = (Request["att_sqlno"] ?? "").Trim();//dmt_attach.att_sqlno相關流水號
        ReqVal["attach_flagtran"] = (Request["attach_flagtran"] ?? "").Trim();//dmt_attach.attach_flagtran 2014/12/13柳月增加，for異動作業增加文件上傳 Y:異動作業上傳 N:非異動作業上傳
        ReqVal["tran_sqlno"] = (Request["tran_sqlno"] ?? "").Trim();//dmt_attach.tran_sqlno 異動流水號

        var settings = new JsonSerializerSettings()
        {
            Formatting = Formatting.Indented,
            ContractResolver = new LowercaseContractResolver(),//key統一轉小寫
            Converters = new List<JsonConverter> { new DBNullCreationConverter(), new TrimCreationConverter() }//dbnull轉空字串且trim掉
        };
        
        Response.Write("{");
        Response.Write("\"request\":" + JsonConvert.SerializeObject(ReqVal, settings).ToUnicode() + "\n");
        Response.Write(",\"dmt\":" + JsonConvert.SerializeObject(GetDmt(ref dtDmt), settings).ToUnicode() + "\n");
        Response.Write(",\"step_dmt\":" + JsonConvert.SerializeObject(GetStepDmt(ref dtStepDmt), settings).ToUnicode() + "\n");//交辦費用.案性
        Response.Write(",\"attach_cnt\":" + JsonConvert.SerializeObject(GetAttachNo(), settings).ToUnicode() + "\n");//交辦費用.案性
        Response.Write(",\"dmt_attach\":" + JsonConvert.SerializeObject(GetDmtAttach(ref dtDmtAttach), settings).ToUnicode() + "\n");//交辦費用.案性
        Response.Write("}");
    }

    #region GetDmt 交辦資料
    private DataTable GetDmt(ref DataTable dt) {
        SQL = "select in_date,appl_name from dmt where seq = '" + ReqVal["seq"] + "' and seq1='" + ReqVal["seq1"] + "'";
        conn.DataTable(SQL, dt);

        if (dt.Rows.Count > 0) {
        }
        
        return dt;
    }
    #endregion
    
    #region GetStepDmt 進度資料
    private DataTable GetStepDmt(ref DataTable dt) {
        SQL = "Select s.*,b.rs_detail as rs_code_name,''in_no,''cgrs_nm";
        SQL += ",(select code_name from cust_code where code_type='rpt_pr_t' and cust_code=b.classp) as report_name ";
        SQL += ",isnull((select max(Attach_No) from dmt_attach where seq = s.seq and seq1 = s.seq1 and step_grade=s.step_grade and attach_flag<>'D'),0) max_attach_no ";
        SQL += ",isnull((select count(*) from dmt_attach where seq = s.seq and seq1 = s.seq1 and step_grade=s.step_grade and attach_flag<>'D'),0) attach_cnt ";
        SQL += " from vstep_dmt as s ";
        SQL += " left outer join code_br b on b.rs_type=s.rs_type and b.rs_class=s.rs_class and b.rs_code=s.rs_code ";
        SQL += " Where s.seq='" + ReqVal["seq"] + "' and s.seq1='" + ReqVal["seq1"] + "' and s.step_grade='" + ReqVal["step_grade"] + "'";
        if (Request["seq"] == null || Request["seq1"] == null || Request["step_grade"] == null) {
            SQL += "and 1=0 ";
        }
        conn.DataTable(SQL, dt);

        if (dt.Rows.Count > 0) {
            for (int i = 0; i < dt.Rows.Count; i++) {
                //因客收才有對應交辦單
                DataRow dr = dt.Rows[i];
                if (dr.SafeRead("cg", "").ToUpper() == "C" && dr.SafeRead("rs", "").ToUpper() == "R") {
                    SQL = "select in_no from case_dmt where case_no='" + dr.SafeRead("case_no", "") + "'";
                    object objResult1 = conn.ExecuteScalar(SQL);
                    dt.Rows[i]["in_no"] = (objResult1 == DBNull.Value || objResult1 == null) ? "" : objResult1.ToString();
                }

                if (dr.SafeRead("cg", "").ToUpper() == "C") {
                    dt.Rows[i]["cgrs_nm"] = "客";
                } else if (dr.SafeRead("cg", "").ToUpper() == "G") {
                    dt.Rows[i]["cgrs_nm"] = "官";
                } else {
                    dt.Rows[i]["cgrs_nm"] = "本";
                }
                if (dr.SafeRead("rs", "").ToUpper() == "R" || dr.SafeRead("rs", "").ToUpper() == "Z") {
                    dt.Rows[i]["cgrs_nm"] += "收";
                } else {
                    dt.Rows[i]["cgrs_nm"] += "發";
                }
            }
        }

        return dt;
    }
    #endregion

    #region GetAttachNo 附件數
    private Dictionary<string, string> GetAttachNo() {
        Dictionary<string, string> cnt = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
        
        SQL = "select isnull(max(Attach_No),0) as max_attach_no,count(*) as attach_cnt ";
        SQL += " from dmt_attach ";
        SQL += " where seq = '" + ReqVal["seq"] + "' and seq1 = '" + ReqVal["seq1"] + "' ";
        SQL += " and step_grade='" + ReqVal["step_grade"] + "' and attach_flag<>'D' ";
        using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
            if (dr.Read()) {
                cnt["max_attach_no"] = dr.SafeRead("max_attach_no", "");
                cnt["attach_cnt"] = dr.SafeRead("attach_cnt", "");
            }
        }
        return cnt;
    }
    #endregion

    #region GetDmtAttach 進度附件
    private DataTable GetDmtAttach(ref DataTable dt) {
        string where = "";
        if (ReqVal["step_grade"] != "") where += " and step_grade=" + ReqVal["step_grade"];
        if (ReqVal["attach_sqlno"] != "") where += " and attach_sqlno=" + ReqVal["attach_sqlno"];
        if (ReqVal["att_sqlno"] != "") where += " and att_sqlno=" + ReqVal["att_sqlno"];

        dt = Sys.GetDmtAttach(conn, ReqVal["seq"], ReqVal["seq1"], ReqVal["source"], where);
        /*
        SQL = "select *,(select mark1 from cust_code where code_type='Tdoc' and cust_code=dmt_attach.doc_type) as doc_type_mark,'' as old_branch ";
        SQL += " from dmt_attach ";
        SQL += " where seq = '" + ReqVal["seq"] + "' and seq1 = '" + ReqVal["seq1"] + "' and source='" + ReqVal["source"] + "' and attach_flag<>'D' ";
        if (ReqVal["step_grade"] != "") {
            SQL += " and step_grade=" + ReqVal["step_grade"];
        }
        if (ReqVal["attach_sqlno"] != "") {
            SQL += " and attach_sqlno=" + ReqVal["attach_sqlno"];
        }
        if (ReqVal["att_sqlno"] != "") {
            SQL += " and att_sqlno=" + ReqVal["att_sqlno"];
        }
        SQL += " order by attach_sqlno ";
        conn.DataTable(SQL, dt);

        for (int i = 0; i < dt.Rows.Count; i++) {
            dt.Rows[i]["attach_path"] = Sys.Path2Nbtbrt(dt.Rows[i].SafeRead("attach_path", ""));
        }
        */
        return dt;
    }
    #endregion
</script>
