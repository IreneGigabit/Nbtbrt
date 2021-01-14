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

    protected string prgid = "";
    protected string branch = "";
    protected string cgrs = "";
    protected string step_date = "";
    protected string sdate = "";
    protected string edate = "";
    protected string prtkind = "";
    protected string send_way = "";

    protected void Page_Load(object sender, EventArgs e) {
        prgid = (Request["prgid"] ?? "").ToLower();
        branch = Request["branch"] ?? "";
        cgrs = (Request["cgrs"] ?? "").ToUpper();
        step_date = Request["step_date"] ?? "";
        sdate = Request["sdate"] ?? "";
        edate = Request["edate"] ?? "";
        prtkind = Request["prtkind"] ?? "";
        send_way = (Request["send_way"] ?? "").ToUpper();

        DataTable rtn = new DataTable();
        using (DBHelper conn = new DBHelper(Conn.btbrt, false)) {
            //如果有修改此xml記得要一併修改brt8m\brt8mform\xmlFee1.asp
            if (cgrs == "CS") {
                SQL = "select min(rs_no) as minrs_no,max(rs_no) as maxrs_no from vcs_dmt";
                SQL += " where branch='" + branch + "'";
            } else if (cgrs == "GS") {
                SQL = "select min(rs_no) as minrs_no,max(rs_no) as maxrs_no from step_dmt";
                SQL += " where branch='" + branch + "'";
                SQL += " and cg='" + cgrs.Left(1) + "' and rs='" + cgrs.Right(1) + "'";
                SQL += " and rs_no = main_rs_no ";
                if (prtkind != "513") {//513=收入明細
                    SQL += " and left(rs_no,1)='G' ";
                    if (send_way != "") {
                        if (send_way == "M") {
                            SQL += " and (send_way<>'E' or send_way is null or send_way='M') ";
                        } else {
                            SQL += " and send_way='" + send_way + "'";
                        }
                    }
                }
            } else {
                SQL = "select min(rs_no) as minrs_no,max(rs_no) as maxrs_no from step_dmt";
                SQL += " where branch='" + branch + "'";
                SQL += " and cg='" + cgrs.Left(1) + "' and rs='" + cgrs.Right(1) + "'";
            }

            if (step_date != "") SQL += " and step_date='" + step_date + "'";
            if (sdate != "") SQL += " and step_date>='" + sdate + "'";
            if (edate != "") SQL += " and step_date<='" + edate + "'";

            conn.DataTable(SQL, rtn);
        }

        var settings = new JsonSerializerSettings()
        {
            Formatting = Formatting.Indented,
            ContractResolver = new LowercaseContractResolver(),//key統一轉小寫
            Converters = new List<JsonConverter> { new DBNullCreationConverter(), new TrimCreationConverter() }//dbnull轉空字串且trim掉
        };

        Response.Write(JsonConvert.SerializeObject(rtn, settings).ToUnicode());
    }
</script>
