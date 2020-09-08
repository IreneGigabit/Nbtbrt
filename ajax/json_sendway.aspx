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

    protected string rs_type = "";
    protected string rs_code = "";

    protected void Page_Load(object sender, EventArgs e) {
        rs_type = Request["rs_type"] ?? Funcs.getRsType();
        rs_code = Request["rs_code"] ?? "";

        DataTable dt = new DataTable();
        using (DBHelper conn= new DBHelper(Conn.btbrt, false)) {
            SQL = "Select spe_ctrl ";
            SQL += " from vcode_act c ";
            SQL += " where rs_type='" + rs_type + "' ";
            SQL += " and rs_code='" + rs_code + "' and act_code='_' ";
            SQL += " and cg = 'C' and rs = 'R' ";
            object objResult = conn.ExecuteScalar(SQL);
            string spe_ctrl = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();
            string[] ctrl = spe_ctrl.Split(',');
            string strWhere = "M";
            if (ctrl.Length >= 4 && ctrl[3] == "E") {//如果設定電子送件,只能選電子送件
                strWhere = "E";
            } else {
                if (ctrl.Length >= 5) {
                    strWhere = ctrl[4];
                }
            }

            SQL = "select cust_code,code_name from cust_code ";
            SQL += "where code_type='GSEND_WAY' ";
            SQL += "and cust_code in('" + strWhere.Replace("|", "','") + "') ";
            SQL += "order by CHARINDEX(Cust_code,'" + strWhere + "') ";
            conn.DataTable(SQL, dt);
        }
        
        var settings = new JsonSerializerSettings() {
            Formatting = Formatting.Indented,
            ContractResolver = new LowercaseContractResolver(),//key統一轉小寫
                Converters = new List<JsonConverter> { new DBNullCreationConverter(), new TrimCreationConverter() }//dbnull轉空字串且trim掉
        };

        Response.Write(JsonConvert.SerializeObject(dt, settings).ToUnicode());
    }
</script>
