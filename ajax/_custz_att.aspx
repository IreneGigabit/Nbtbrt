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

    protected string cust_area = "";
    protected string cust_seq = "";
    protected string att_sql = "";
    protected string branch = "";
    protected string type = "";
    protected string all = "";

    DBHelper connbr = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    private void Page_Unload(System.Object sender, System.EventArgs e) {
        if (connbr != null) connbr.Dispose();
    }

    protected void Page_Load(object sender, EventArgs e) {
        cust_area = (Request["cust_area"] ?? "");
        cust_seq = (Request["cust_seq"] ?? "");
        att_sql = (Request["att_sql"] ?? "");
        branch = (Request["branch"] ?? "");
        type = (Request["type"] ?? "");
        all = (Request["all"] ?? "");

        connbr = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
        if (type == "brtran") {
            connbr = new DBHelper(Conn.brp(Request["branch"])).Debug(Request["chkTest"] == "TEST");
        }

        SQL = "select *,''magnm,''deptnm ";
        SQL += "from custz_att ";
        //2014/2/19依李協理2013/12/30Email修改，增加排除離職及職務移轉,只抓取狀態正常或空白
        SQL += "where (att_code like 'N%' or att_code='' or att_code is null) ";
        if (all != "Y") SQL += "and (dept='T' or dept is null) ";
        if (cust_area != "") SQL += "and cust_area='" + cust_area + "' ";
        if (cust_seq != "") SQL += "and cust_seq='" + cust_seq + "' ";
        if (att_sql != "") SQL += "and att_sql='" + att_sql + "' ";
        DataTable dt = new DataTable();
        connbr.DataTable(SQL, dt);

        for (int i = 0; i < dt.Rows.Count; i++) {
            if (dt.Rows[i].SafeRead("att_mag", "").Trim() == "Y")
                dt.Rows[i]["magnm"] = "需要";
            else
                dt.Rows[i]["magnm"] = "不需要";

            if (dt.Rows[i].SafeRead("dept", "").Trim() == "T")
                dt.Rows[i]["deptnm"] = "商標";
            else if (dt.Rows[i].SafeRead("dept", "").Trim() == "P")
                dt.Rows[i]["deptnm"] = "專利";
            else
                dt.Rows[i]["deptnm"] = "";
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
