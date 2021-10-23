<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "Newtonsoft.Json" %>
<%@ Import Namespace = "Newtonsoft.Json.Linq" %>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<script runat="server">
    protected string HTProgCap = "案性收費標準";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "Brt26";//HttpContext.Current.Request["prgid"] ?? "";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";
    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";
    
    protected string SQL = "";
    protected object objResult = null;

    protected string dmt_json = "", ext_json = "", coun_json = "";

    DBHelper conn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    DBHelper cnn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    private void Page_Unload(System.Object sender, System.EventArgs e) {
        if (conn != null) conn.Dispose();
        if (cnn != null) cnn.Dispose();
    }

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;
        
        conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
        cnn = new DBHelper(Conn.Sysctrl).Debug(Request["chkTest"] == "TEST");

        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        HTProgCap = myToken.Title;
        DebugStr = myToken.DebugStr;
        if (HTProgRight >= 0) {
            QueryDmtData();
            QueryExtData();
            QueryCountryData();
            PageLayout();
            this.DataBind();
        }
    }

    private void PageLayout() {
        if ((HTProgRight & 2) > 0) {
            StrFormBtn += "<input type=\"button\" id=\"btnSrch\" value=\"查　詢\" class=\"cbutton bsubmit\" />\n";
            StrFormBtn += "<input type=\"button\" id=\"btnRest\" value=\"重　填\" class=\"cbutton\" />\n";
        }

        string tdate = DateTime.Today.AddMonths(-2).ToShortDateString();
        SQL = "select count(*) as dcnt from case_fee ";
        SQL += "where tran_date between '" + tdate + "' and '" + DateTime.Today.ToShortDateString() + "' ";
        SQL += "and country = 'T' and dept = 'T' and end_date='2099/12/31'";
        objResult = conn.ExecuteScalar(SQL);
        int dcnt = (objResult == DBNull.Value || objResult == null) ? 0 : Convert.ToInt32(objResult);

        SQL = "select count(*) as ecnt from case_fee ";
        SQL += "where tran_date between '" + tdate + "' and '" + DateTime.Today.ToShortDateString() + "' ";
        SQL += "and country <> 'T' and dept = 'T' and end_date='2099/12/31'";
        objResult = conn.ExecuteScalar(SQL);
        int ecnt = (objResult == DBNull.Value || objResult == null) ? 0 : Convert.ToInt32(objResult);


        if (dcnt > 0 || ecnt > 0) {
            StrFormBtnTop += "<font color='black'>自" + tdate + "修訂收費標準:</font>";
            if (dcnt > 0) {
                StrFormBtnTop += "[<a href='" + HTProgPrefix + "_detail.aspx?prgid=" + prgid + "&branch=T'>國內案(" + dcnt + ")</a>]";
            }
            if (ecnt > 0) {
                StrFormBtnTop += "[<a href='" + HTProgPrefix + "_detail.aspx?prgid=" + prgid + "&branch=E'>出口案(" + ecnt + ")</a>]";
            }
        }
    }

    //國內案
    private void QueryDmtData() {
        string rs_type = Sys.getRsType();

        JArray jarr = new JArray();
        //根目錄
        var root = new JObject {
        { "id", "root0" }, 
        { "parent", "#" }, 
        { "text", "案性<font size=2 color=blue>(選取『案性』時，請先展開『案性種類』，再勾選『案性』)</font>"},
        {"li_attr", new JObject {{"class","no-checkbox"}} },
        {"state", new JObject {{"opened",true}} }
        };
        jarr.Add(root);

        DataTable dt = new DataTable();
        using (DBHelper conn = new DBHelper(Conn.btbrt, false)) {
            SQL = "select cust_code,code_name from cust_code ";
            SQL += " where code_type='" + rs_type + "' and cust_code in( ";
            SQL += "    select left(cust_code,1) from ncode_v where code_type='" + rs_type + "' ";
            SQL += " ) ";
            SQL += " order by cust_code ";
            conn.DataTable(SQL, dt);
            for (int i = 0; i < dt.Rows.Count; i++) {
                DataRow dr = dt.Rows[i];
                var jrow = new JObject {
                { "id", dr.SafeRead("cust_code","") }, 
                { "parent", "root0" }, 
                { "text", dr.SafeRead("code_name","") },
                 {"li_attr", new JObject {{"class","no-checkbox"}} },
               };
                jarr.Add(jrow);

                //子項
                DataTable dtDtl = new DataTable();
                SQL = "select * from ncode_v where code_type='" + rs_type + "' and cust_code like '" + dr.SafeRead("cust_code", "") + "%' order by cust_code  ";
                conn.DataTable(SQL, dtDtl);
                for (int j = 0; j < dtDtl.Rows.Count; j++) {
                    DataRow drDtl = dtDtl.Rows[j];
                    var jrowDtl = new JObject {
                    { "id", drDtl.SafeRead("cust_code","") }, 
                    { "parent", dr.SafeRead("cust_code","") }, 
                    { "text", drDtl.SafeRead("code_name","") },
                    { "icon", "jstree-file" }
                    };
                    jarr.Add(jrowDtl);
                }
            }
        }

        var settings = new JsonSerializerSettings()
        {
            Formatting = Formatting.None,
            ContractResolver = new LowercaseContractResolver(),//key統一轉小寫
            Converters = new List<JsonConverter> { new DBNullCreationConverter(), new TrimCreationConverter() }//dbnull轉空字串且trim掉
        };

        dmt_json = (JsonConvert.SerializeObject(jarr, settings).ToUnicode()).Replace("\\", "\\\\").Replace("\"", "\\\"");
    }

    //出口案
    private void QueryExtData() {
        //案性
        string rs_type = Sys.getRsTypeExt();

        JArray jarr = new JArray();
        //根目錄
        var root = new JObject {
        { "id", "root0" }, 
        { "parent", "#" }, 
        { "text", "案性<font size=2 color=blue>(選取『案性』時，請先展開『案性種類』，再勾選『案性』)</font>"},
        {"li_attr", new JObject {{"class","no-checkbox"}} },
        {"state", new JObject {{"opened",true} } }
        };
        jarr.Add(root);

        DataTable dt = new DataTable();
        using (DBHelper conn = new DBHelper(Conn.btbrt, false)) {
            SQL = "select cust_code,code_name from cust_code ";
            SQL += " where code_type='" + rs_type + "' and cust_code in( ";
            SQL += "    select left(cust_code,1) from nextcode_v where code_type='" + rs_type + "' ";
            SQL += " ) ";
            SQL += " order by cust_code ";
            conn.DataTable(SQL, dt);
            for (int i = 0; i < dt.Rows.Count; i++) {
                DataRow dr = dt.Rows[i];
                var jrow = new JObject {
                { "id", dr.SafeRead("cust_code","") }, 
                { "parent", "root0" }, 
                {"li_attr", new JObject {{"class","no-checkbox"}} },
                { "text", dr.SafeRead("code_name","") }
                };
                jarr.Add(jrow);

                //子項
                DataTable dtDtl = new DataTable();
                SQL = "select * from nextcode_v where code_type='" + rs_type + "' and cust_code like '" + dr.SafeRead("cust_code", "") + "%' order by cust_code  ";
                conn.DataTable(SQL, dtDtl);
                for (int j = 0; j < dtDtl.Rows.Count; j++) {
                    DataRow drDtl = dtDtl.Rows[j];
                    var jrowDtl = new JObject {
                    { "id", drDtl.SafeRead("cust_code","") }, 
                    { "parent", dr.SafeRead("cust_code","") }, 
                    { "text", drDtl.SafeRead("code_name","") },
                    { "icon", "jstree-file" }
                    };
                    jarr.Add(jrowDtl);
                }
            }

        }

        var settings = new JsonSerializerSettings()
        {
            Formatting = Formatting.None,
            ContractResolver = new LowercaseContractResolver(),//key統一轉小寫
            Converters = new List<JsonConverter> { new DBNullCreationConverter(), new TrimCreationConverter() }//dbnull轉空字串且trim掉
        };

        ext_json = (JsonConvert.SerializeObject(jarr, settings).ToUnicode()).Replace("\\", "\\\\").Replace("\"", "\\\"");
    }
    
    //國別
    private void QueryCountryData() {
        JArray jarr = new JArray();
        //根目錄
        var root = new JObject {
        { "id", "root0" }, 
        { "parent", "#" }, 
        { "text", "國家<font size=2 color=blue>(選取『國家』時，最多可勾選15個國家)</font>"},
        {"li_attr", new JObject {{"class","no-checkbox"}} },
        {"state", new JObject {{"opened",true} } }
        };
        jarr.Add(root);

        DataTable dt = new DataTable();
        using (DBHelper conn = new DBHelper(Conn.btbrt, false)) {
            SQL = "select distinct cl from case_coun where dept='T' order by cl ";
            conn.DataTable(SQL, dt);
            for (int i = 0; i < dt.Rows.Count; i++) {
                DataRow dr = dt.Rows[i];

                string cl_name = "";
                switch (dr.SafeRead("cl", "")) {
                    case "1": cl_name = "美洲"; break;
                    case "2": cl_name = "歐洲"; break;
                    case "3": cl_name = "亞洲"; break;
                    case "4": cl_name = "大洋洲"; break;
                    case "5": cl_name = "非洲"; break;
                    default: cl_name = "其他"; break;
                }

                var jrow = new JObject {
                { "id", dr.SafeRead("cl","") }, 
                { "parent", "root0" }, 
                {"li_attr", new JObject {{"class","no-checkbox"}} },
                { "text", cl_name }
                };
                jarr.Add(jrow);

                //子項
                DataTable dtDtl = new DataTable();
                SQL = "select country,coun_c,cl from case_coun where dept='T' and cl='" + dr.SafeRead("cl", "") + "' order by country ";
                conn.DataTable(SQL, dtDtl);
                for (int j = 0; j < dtDtl.Rows.Count; j++) {
                    DataRow drDtl = dtDtl.Rows[j];
                    var jrowDtl = new JObject {
                    { "id", drDtl.SafeRead("country","") }, 
                    { "parent", dr.SafeRead("cl","") }, 
                    { "text", drDtl.SafeRead("country","")+drDtl.SafeRead("coun_c","") },
                    { "icon", "jstree-file" }
                    };
                    jarr.Add(jrowDtl);
                }
            }
        }

        var settings = new JsonSerializerSettings()
        {
            Formatting = Formatting.None,
            ContractResolver = new LowercaseContractResolver(),//key統一轉小寫
            Converters = new List<JsonConverter> { new DBNullCreationConverter(), new TrimCreationConverter() }//dbnull轉空字串且trim掉
        };

        coun_json = (JsonConvert.SerializeObject(jarr, settings).ToUnicode()).Replace("\\", "\\\\").Replace("\"", "\\\"");
    }
</script>
<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title><%#HTProgCap%></title>
    <uc1:head_inc_form runat="server" ID="head_inc_form" />
    <link rel="stylesheet" type="text/css" href="<%=Page.ResolveUrl("~/js/lib/themes/default/style.min.css")%>" />
    <script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/jstree.min.js")%>"></script>
    <style type="text/css">
        .jstree-default .jstree-clicked,.jstree-default .jstree-clicked.jstree-disabled {
            background: #8bf;
        }
        .no-checkbox > a > i.jstree-checkbox {
            display:none;
        }
        .jstree li > a > .jstree-file {  display:none !important; }<!--取消子項的icon-->
    </style>
</head>

<body>
<table cellspacing="1" cellpadding="0" width="98%" border="0" align="center">
    <tr>
        <td class="text9" nowrap="nowrap">&nbsp;【<%#prgid%> <%#HTProgCap%>】</td>
        <td class="FormLink" valign="top" align="right" nowrap="nowrap">
            <%#StrFormBtnTop%>
        </td>
    </tr>
    <tr>
        <td colspan="2"><hr class="style-one"/></td>
    </tr>
</table>

<form id="reg" name="reg" method="post">
    <input type="hidden" id="prgid" name="prgid" value="<%=prgid%>">
    <input type="hidden" id="code" name="code"><!--案性-->
    <input type="hidden" id="coun" name="coun"><!--國別-->

    <div id="id-div-slide">
        <table border="0" class="bluetable" cellspacing="1" cellpadding="2" width="50%">
            <tr>
                  <td class=lightbluetable align=right>請選擇查詢之案件種類</td>
                  <td class=whitetablebg align=left>
                      <label><input type="radio" name="branch" value="T" checked>國內案</label>
                      <label><input type="radio" name="branch" value="E" >出口案</label>
                </td>
            </tr>
        </table>
        <br />
        <table id="tbl_T" border="0" class="bluetable" cellspacing="1" cellpadding="2" width="95%" style="display:none"><!--國內案-->
            <tr>
                <td class=whitetablebg align=left>
                    <div id="jstree_dmt_div_result"></div>
                </td>
            </tr>
            <tr>
                <td class=lightbluetable align=left>
                    <div id="jstree_dmt_div"></div>
                </td>
            </tr>
        </table>
        <br />
        <table id="tbl_E" border="0" class="bluetable" cellspacing="1" cellpadding="2" width="95%" style="display:none"><!--出口案-->
            <tr>
                <td class=whitetablebg align=left>
                    <div id="jstree_ext_div_result"></div>
                </td>
                <td class=whitetablebg align=left>
                    <div id="jstree_coun_div_result"></div>
                </td>
            </tr>
            <tr>
                <td class=lightbluetable align=left vAlign="top" width="30%">
                    <div id="jstree_ext_div"></div>
                </td>
                <td class=lightbluetable align=left vAlign="top" width="70%">
                    <div id="jstree_coun_div"></div>
                </td>
            </tr>
        </table>
  
        <div id="event_result"></div>

        <br>
        <%#DebugStr%>
        <table id="tabBtn" border="0" width="100%" cellspacing="0" cellpadding="0" align="center">
	        <tr><td width="100%" align="center">
			    <%#StrFormBtn%>
	        </td></tr>
        </table>
    </div>
</form>

<div align="left">
</div>
<br>

<div id="dialog"></div>

<iframe id="ActFrame" name="ActFrame" src="about:blank" width="100%" height="300" style="display:none"></iframe>
</body>
</html>


<script language="javascript" type="text/javascript">
    $(function () {
        this_init();
    });

    function this_init() {
        if (window.parent.tt !== undefined) {
            window.parent.tt.rows = "100%,0%";
        }

        $("input[name='branch']:checked").triggerHandler("click");
        $("input.dateField").datepick();
    }

    //[重填]
    $("#btnRest").click(function (e) {
        reg.reset();
        this_init();
    });

    //////////////////////////////////////////////////////
    $(".dateField").blur(function (e) {
        ChkDate(this);
    });

    //點選案件種類
    $("input[name='branch']").click(function (e) {
        $("#tbl_T,#tbl_E").hide();
        $("#tbl_" + $(this).val()).show();

        $("#code,#coun").val("");
        $("#jstree_dmt_div_result,#jstree_ext_div_result,#jstree_coun_div_result").html("<font color='blue'>已選擇: </font>");
        $("#jstree_dmt_div").jstree('destroy');
        $("#jstree_ext_div").jstree('destroy');
        $("#jstree_coun_div").jstree('destroy');
        if ($(this).val() == "T") {
            $("#coun").val("T");
            showTree("#jstree_dmt_div", "#code", "<%#dmt_json%>", -1);
        } else {
            showTree("#jstree_ext_div", "#code", "<%#ext_json%>", -1);
            showTree("#jstree_coun_div", "#coun", "<%#coun_json%>", 15);
        }
    });

    //[查詢]
    $("#btnSrch").click(function (e) {
        if ($("#code").val() == "") {
            alert("請務必選取「 案性 」，不得為空白！");
            return false;
        }

        if ($("input[name='branch']:checked").val() == "E") {
            if ($("#coun").val() == "") {
                alert("請務必選取「國家」！");
                return false;
            }
        }

        reg.action = "<%=HTProgPrefix%>_List.aspx";
        //reg.target = "Eblank";
        reg.submit();
    });

    function showTree(vDiv, vValInput, vData, vLimit) {
        $(vDiv)
        // create the instance
       .jstree({
           'plugins': ['checkbox'],
           "checkbox": {
               "three_state": false//父子節點不關聯
           },
           'core': {
               'expand_selected_onload': true,//載入完成後預設展開所有選中節點
               'data': $.parseJSON(vData)
           }
       })
        // listen for event
        .on('changed.jstree', function (e, data) {
            var r = [], v = [];
            var msg = "";
            for (var i = 0; i < data.selected.length; i++) {
                var node = data.instance.get_node(data.selected[i]);
                if (node.parent != "#" && node.parent != "root0") {
                    if (vLimit > -1 && r.length >= vLimit) {
                        $("#" + e.target.id).jstree("uncheck_node", data.selected[i]);
                        msg = "<font color='red'>不可超過" + vLimit + "個</font>";
                    } else {
                        v.push(node.id);
                        r.push(node.text);
                    }
                }
            }

            //$(vValInput).val($("#" + e.target.id).jstree("get_selected").toString());
            $(vValInput).val(v.join(','));
            $("#" + e.target.id + '_result').html('<font color="blue">已選擇: </font>' + r.join(', ') + msg);
        })
        .on("select_node.jstree", function (e, data) {
            data.instance.toggle_node(data.node);
        }).on("deselect_node.jstree", function (e, data) {
            data.instance.toggle_node(data.node);
        });
    }
</script>
