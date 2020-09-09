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

    protected string country = "";
    protected string ar_form = "";
    protected string service_type = "";
    protected string ttype = "";
    protected string case_date = "";
    protected string submittask = "";
    protected string arcase = "";
    protected string mark = "";
    protected string prgid = "";

    protected void Page_Load(object sender, EventArgs e) {
        country = Request["country"]??"";
        ar_form = (Request["ar_form"]??"").ToUpper();
        service_type = Request["Service"] ?? "";
        ttype = (Request["type"] ?? "").ToLower();
        case_date = Request["case_date"] ?? "";
        submittask = Request["submittask"] ?? "";
        arcase = (Request["arcase"] ?? "").ToUpper();
        mark = Request["mark"] ?? "";
        prgid = (Request["prgid"] ?? "").ToLower();

        DataTable rtn = new DataTable();
        //如果有修改此xml記得要一併修改brt8m\brt8mform\xmlFee1.asp
        if (country == "" || country == "T") {
            rtn = GetFee_T();//國內案
        } else {
            rtn = GetFee_TE();//出口案
        }
        
        var settings = new JsonSerializerSettings() {
            Formatting = Formatting.Indented,
            ContractResolver = new LowercaseContractResolver(),//key統一轉小寫
                Converters = new List<JsonConverter> { new DBNullCreationConverter(), new TrimCreationConverter() }//dbnull轉空字串且trim掉
        };

        Response.Write(JsonConvert.SerializeObject(rtn, settings).ToUnicode());
    }

    protected DataTable GetFee_T() {
        string code_type = Sys.getRsType();
        DataTable dt = new DataTable();
        using (DBHelper conn = new DBHelper(Conn.btbrt, false)) {
            if (ttype == "arcase") {
                SQL = "select * from code_br ";
                SQL += "where rs_class='" + ar_form + "' ";
                if (ar_form == "Z1") {//附屬案性
                    SQL += " and rs_code like '" + arcase.Left(3) + "%' ";
                } else {
                    SQL += " and rs_code like '" + arcase + "%' ";
                }
                SQL += "and getdate() >= beg_date AND no_code='N' ";
                if (prgid != "brt51") {
                    SQL += "and (end_date is null or end_date = '' or end_date > getdate()) ";
                }
                SQL += "and rs_type='" + code_type + "' ";
                SQL += "and mark " + (mark == "" ? "is null" : "='" + mark + "'") + " ";
                conn.DataTable(SQL, dt);
            } else if (ttype == "fee") {
                SQL = "select * from case_fee ";
                SQL += "where dept='T' and country='" + country + "' and rs_code='" + arcase + "' ";
                SQL += "and (" + (case_date == "" ? "getdate()" : "'" + case_date + "'") + " between beg_date and end_date) ";
                conn.DataTable(SQL, dt);
            } else if (ttype == "spectrl") {
                SQL = "select a.rs_code,a.rs_detail,b.spe_ctrl,'N'spe_ctrl3 ";
                SQL += "from code_br a ";
                SQL += "inner join code_act b on a.sqlno=b.code_sqlno ";
                SQL += "where rs_class like '" + ar_form + "%' and rs_type='" + code_type + "' and cr='Y' ";
                SQL += "and getdate() >= a.beg_date and (a.end_date is null or a.end_date = '' or a.end_date > getdate()) ";
                SQL += "and b.cg='C' and b.rs='R' and a.rs_code='" + arcase + "'";
                conn.DataTable(SQL, dt);
                for (int i = 0; i < dt.Rows.Count; i++) {
                    string[] arr_spe_ctrl = (dt.Rows[i].SafeRead("spe_ctrl", "") + ",,").Split(',');
                    if (arr_spe_ctrl[2].Trim() != "") dt.Rows[i]["spe_ctrl3"] = arr_spe_ctrl[2];//管制法定期限案性
                }
            }
            return dt;
        }
    }

    protected DataTable GetFee_TE() {
        string code_type = Sys.getRsTypeExt();
        DataTable dt = new DataTable();
        using (DBHelper conn = new DBHelper(Conn.btbrt, false)) {
            if (ttype == "arcase") {
                SQL = "select rs_code,rs_detail,seq_type from code_ext ";
                SQL += "where  rs_class='" + ar_form + "' and rs_type='" + code_type + "' and cr_flag='Y' ";
                SQL += " and getdate() >= beg_date and (end_date is null or end_date = '' or end_date > getdate()) and (coun_detail='all' or coun_detail in ('" + country + "')) ";
                if (mark != "") {
                    SQL += " and left(rs_code,3)='" + arcase + "' and left(mark,1)='" + mark + "' ";
                } else {
                    SQL += " and (mark ='' or left(mark,1)<>'A') ";
                }
                conn.DataTable(SQL, dt);
            } else if (ttype == "fee") {
                SQL = "select * from case_fee ";
                SQL += "where dept='T' and country='" + country + "' and rs_code='" + arcase + "' ";
                SQL += "and getdate() between beg_date and end_date";
                conn.DataTable(SQL, dt);
            } else if (ttype == "spectrl") {
                SQL = "select a.rs_code,a.rs_detail,b.spe_ctrl,b.spe_ctrl1 ";
                SQL = ",'N'spe_ctrl2,'N'spe_ctrl3,'N'spe_ctrl4,'N'spe_ctrl6,'N'spe_ctrl7,'N'spe_ctrl8 ";
                SQL += "from code_ext a ";
                SQL += "inner join code_actext b on a.sqlno=b.code_sqlno ";
                SQL += "where rs_class='" + ar_form + "' and rs_type='" + code_type + "' and cr_flag='Y' ";
                SQL += " and getdate() >= a.beg_date and a.end_date is null and (coun_detail='all' or coun_detail in ('" + country + "'))";
                SQL += " and (a.mark ='' or a.mark is null) and and b.cg='C' and b.rs='R' and a.rs_code='" + arcase + "'";
                conn.DataTable(SQL, dt);
                for (int i = 0; i < dt.Rows.Count; i++) {
                    string[] arr_spe_ctrl = (dt.Rows[i].SafeRead("spe_ctrl", "") + ",,,,,,,").Split(',');
                    if (arr_spe_ctrl[1].Trim() != "") dt.Rows[i]["spe_ctrl2"] = arr_spe_ctrl[1];//權利異動案性
                    if (arr_spe_ctrl[2].Trim() != "") dt.Rows[i]["spe_ctrl3"] = arr_spe_ctrl[2];//分割案性
                    if (arr_spe_ctrl[3].Trim() != "") dt.Rows[i]["spe_ctrl4"] = arr_spe_ctrl[3];//一案多件
                    if (arr_spe_ctrl[5].Trim() != "") dt.Rows[i]["spe_ctrl6"] = arr_spe_ctrl[5];//已結案可允許不復案
                    if (arr_spe_ctrl[6].Trim() != "") dt.Rows[i]["spe_ctrl7"] = arr_spe_ctrl[6];//爭救案性
                    if (arr_spe_ctrl[7].Trim() != "") dt.Rows[i]["spe_ctrl8"] = arr_spe_ctrl[7];//可不用執行稽催管制維護
                }
            }
            return dt;
        }
    }
</script>
