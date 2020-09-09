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

    protected int right = 0;
    protected string prgid = "";
    protected string submitTask = "";
    protected string formfunction = "";
    protected string in_no = "";
    protected string cust_area = "";
    protected string cust_seq = "";

    protected string br_in_scode = "";//交辦單營洽
    
    protected void Page_Load(object sender, EventArgs e) {
        prgid = (Request["prgid"] ?? "").Trim().ToLower();
        right = Convert.ToInt32(Request["right"] ?? "0");
        submitTask = (Request["submitTask"] ?? "").Trim();
        formfunction = (Request["formfunction"] ?? "").Trim();
        in_no = (Request["in_no"] ?? "").Trim();
        cust_area = (Request["cust_area"] ?? "").Trim();
        cust_seq = (Request["cust_seq"] ?? "").Trim();

        var settings = new JsonSerializerSettings()
        {
            Formatting = Formatting.Indented,
            ContractResolver = new LowercaseContractResolver(),//key統一轉小寫
            Converters = new List<JsonConverter> { new DBNullCreationConverter(), new TrimCreationConverter() }//dbnull轉空字串且trim掉
        };
        
        Response.Write("{");
        Response.Write("\"main\":" + JsonConvert.SerializeObject(GetCase(), settings).ToUnicode() + "\n");
        Response.Write(",\"apcust\":" + JsonConvert.SerializeObject(GetAPCust(), settings).ToUnicode() + "\n");
        Response.Write(",\"salesList\":" + JsonConvert.SerializeObject(GetSales(), settings).ToUnicode() + "\n");
        Response.Write("}");

        //Response.Write(JsonConvert.SerializeObject(dt, settings).ToUnicode());
    }

    #region GetCase 交辦資料
    private DataTable GetCase() {
        DataTable dt = new DataTable();
        using (DBHelper conn = new DBHelper(Conn.btbrt).Debug(false)) {
            //Dictionary<string, string> paras = new Dictionary<string, string>();
            //paras.Add("nIn_no", in_no);
            //conn.Procedure("Pro_case2", paras, dt);

            SQL = "Pro_case2 '" + in_no + "'";
            conn.DataTable(SQL, dt);

            if (dt.Rows.Count > 0) {
                br_in_scode = dt.Rows[0].SafeRead("in_scode", "");
            }
            
            return dt;
        }
    }
    #endregion

    #region GetAPCust 申請人資料
    private DataTable GetAPCust() {
        DataTable dt = new DataTable();
        using (DBHelper conn = new DBHelper(Conn.btbrt).Debug(false)) {
            SQL = "SELECT * ";
            SQL += " FROM vcustlist ";
            SQL += "where cust_area='" + cust_area + "' ";
            SQL += "and cust_seq='" + cust_seq + "'";
            conn.DataTable(SQL, dt);
        }
        return dt;
    }
    #endregion

    #region GetSales 洽案營洽清單
    private DataTable GetSales() {
        DataTable dt = new DataTable();
        using (DBHelper cnn = new DBHelper(Conn.Sysctrl).Debug(false)) {
            if (formfunction == "edit") {
                if ((right & 64) != 0) {
                    SQL = "select distinct 'select'input_type,scode,sc_name,scode1  ";
                    SQL += "from vscode_roles ";
                    SQL += "where branch='" + Session["SeBranch"] + "' ";
                    SQL += "and dept='" + Session["Dept"] + "' ";
                    SQL += "and syscode='" + Session["Syscode"] + "' ";
                    SQL += "and roles='sales' ";
                    SQL += "order by scode1 ";
                } else {
                    SQL = "select 'text'input_type,scode,sc_name,sscode scode1 from scode where scode='" + br_in_scode + "'";
                }
            } else {
                if ((right & 64) != 0) {
                    SQL = "select distinct 'select'input_type,scode,sc_name,scode1  ";
                    SQL += "from vscode_roles ";
                    SQL += "where branch='" + Session["SeBranch"] + "' ";
                    SQL += "and dept='" + Session["Dept"] + "' ";
                    SQL += "and syscode='" + Session["Syscode"] + "' ";
                    SQL += "and roles='sales' ";
                    SQL += "and (end_date is null or end_date>convert(date,getDate())) ";
                    SQL += "order by scode1 ";
                } else {
                    SQL = "select 'text'input_type,scode,sc_name,sscode scode1 from scode where scode='" + Session["se_scode"] + "'";
                }
            }
            cnn.DataTable(SQL, dt);
        }
        return dt;
    }
    #endregion
</script>
