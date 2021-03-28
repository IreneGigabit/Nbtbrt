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
    protected string attach_path = "";
    protected string attach_name = "";
    protected string msg = "";

    protected void Page_Load(object sender, EventArgs e) {
        attach_path = Request["attach_path"] ?? "";
        attach_name = Request["attach_name"] ?? "";
        msg = Request["msg"] ?? "";

        string[] arrAttach_name = attach_name.Split(',');
        string[] arrMsg = msg.Split(',');

        JArray obj = new JArray();
        for (int i = 0; i < arrMsg.Length; i++) {
            FileInfo fi = new FileInfo(Server.MapPath("~/" + attach_path + arrAttach_name[i]));
            if (fi.Exists) {
                obj.Add(new JObject(
                                new JProperty("fileexist", "Y"),
                                new JProperty("path", fi.FullName),
                                new JProperty("msg", "")
                            ));
            } else {
                if (arrMsg[i] == "官方發文規費明細") {
                    obj.Add(new JObject(
                                    new JProperty("fileexist", "N"),
                                    new JProperty("path", fi.FullName),
                                    new JProperty("msg", arrMsg[i] + "檔案尚未產生\n\n若確定列印發文期間內案件皆無規費，則忽略規費明細表未產生提示訊息")
                                ));
                } else {
                    obj.Add(new JObject(
                                    new JProperty("fileexist", "N"),
                                    new JProperty("path", fi.FullName),
                                    new JProperty("msg", arrMsg[i] + "檔案尚未產生")
                                ));
                }
            }
        }
       
        
        var settings = new JsonSerializerSettings() {
            Formatting = Formatting.Indented,
            ContractResolver = new LowercaseContractResolver(),//key統一轉小寫
                Converters = new List<JsonConverter> { new DBNullCreationConverter(), new TrimCreationConverter() }//dbnull轉空字串且trim掉
        };

        Response.Write(JsonConvert.SerializeObject(obj, settings).ToUnicode());
    }
</script>
