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

    protected string seq = "";
    protected string seq1 = "";
    protected string step_grade = "";
    protected string source = "";
    protected string uploadtype = "";
    protected string in_no = "";
    protected string attach_sqlno = "";
    protected string att_sqlno = "";
    protected string attach_flagtran = "";
    protected string tran_sqlno = "";

    protected void Page_Load(object sender, EventArgs e) {
        seq = (Request["seq"] ?? "").Trim();
        seq1 = (Request["seq1"] ?? "").Trim();
        step_grade = (Request["step_grade"] ?? "").Trim();
        source = (Request["source"] ?? "").Trim();
        uploadtype = (Request["uploadtype"] ?? "").Trim();//case:從接洽記錄上傳
        in_no = (Request["in_no"] ?? "").Trim();//接洽序號
        attach_sqlno = (Request["attach_sqlno"] ?? "").Trim();//dmt_attach.attach_sqlno
        att_sqlno = (Request["att_sqlno"] ?? "").Trim();//dmt_attach.att_sqlno相關流水號
        attach_flagtran = (Request["attach_flagtran"] ?? "").Trim();//dmt_attach.attach_flagtran 2014/12/13柳月增加，for異動作業增加文件上傳 Y:異動作業上傳 N:非異動作業上傳
        tran_sqlno = (Request["tran_sqlno"] ?? "").Trim();//dmt_attach.tran_sqlno 異動流水號

        if (uploadtype == "case") {//接洽上傳附件
            SQL = "select *,'' as doc_type_mark,'' as old_branch from dmt_attach ";
            SQL += "where in_no='" + in_no + "' and source='" + source + "' and attach_flag<>'D'";
            if (attach_flagtran != "") {
                if (attach_flagtran == "N")
                    SQL += " and (attach_flagtran is null or attach_flagtran='N') ";//非異動作業上傳
                else
                    SQL += " and attach_flagtran='" + attach_flagtran + "'";
            }
            if (tran_sqlno != "") {
                if (Convert.ToInt32(tran_sqlno) > 0) {
                    SQL += " and tran_sqlno=" + tran_sqlno;
                }
            }
            SQL += " order by attach_sqlno ";
        } else if (uploadtype == "brtran") {//爭救案上傳附件
            SQL = "select *,battach_sqlno as attach_sqlno,0 as step_grade,'' as attach_branch,'' as tran_scode,null as tran_date";
            SQL += ",'' as in_no,'' as case_no,'' as doc_type_mark,'' as old_branch,'' as attach_flagtran,0 as tran_sqlno,'' as apattach_sqlno ";
            SQL += " from bdmt_attach_temp ";
            SQL += " where seq = " + seq + " and seq1 = '" + seq1 + "' and source='" + source + "' and attach_flag<>'D' ";
            if (att_sqlno != "") {
                SQL += " and temp_sqlno='" + att_sqlno + "'";
            }
            SQL += " order by battach_sqlno ";
        } else {//附件檔
            SQL = "select *,(select mark1 from cust_code where code_type='Tdoc' and cust_code=dmt_attach.doc_type) as doc_type_mark,'' as old_branch ";
            SQL += " from dmt_attach ";
            SQL += " where seq = " + seq + " and seq1 = '" + seq1 + "' and source='" + source + "' and attach_flag<>'D' ";
            if (step_grade != "") {
                SQL += " and step_grade=" + step_grade;
            }
            if (attach_sqlno != "") {
                SQL += " and attach_sqlno=" + attach_sqlno;
            }
            if (att_sqlno != "") {
                SQL += " and att_sqlno=" + att_sqlno;
            }
            SQL += " order by attach_sqlno ";
        }
        DataTable dt = new DataTable();
        using (DBHelper conn = new DBHelper(Conn.btbrt).Debug(false)) {
            conn.DataTable(SQL, dt);
        }

        var settings = new JsonSerializerSettings()
        {
            Formatting = Formatting.Indented,
            ContractResolver = new LowercaseContractResolver(),//key統一轉小寫
            Converters = new List<JsonConverter> { new DBNullCreationConverter(), new TrimCreationConverter() }//dbnull轉空字串且trim掉
        };
        Response.Write(JsonConvert.SerializeObject(dt, settings).ToUnicode());
    }
</script>
