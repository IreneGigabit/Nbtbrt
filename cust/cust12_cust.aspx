<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace = "System.Text"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.IO"%>
<%@ Import Namespace = "System.Linq"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Web.Script.Serialization"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>
<%@ Register Src="~/cust/impForm/cust11Form.ascx" TagPrefix="uc1" TagName="cust11Form" %>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<!DOCTYPE html>

<script runat="server">

    protected string HTProgCap = "客戶明細資料";
    private string HTProgCode = "cust12";
    protected string HTProgPrefix = "cust12";
    private int HTProgAcs = 1;
    private int HTProgRight = 0;

    protected string StrAddLink = "";
    protected string StrSaveBtn = "";
    protected string StrResetBtn = "";
    protected string submitTask = "";
    protected string DebugStr = "";
    protected string apsqlno = "";
    protected string cust_seq = "";
    protected string cust_area = "";
    protected string ap_cname1 = "";
    
    protected string StrFormBtnTop = "";
    //protected string StrFormBtn = "";
    protected string FormName = "";

    protected string prgid = HttpContext.Current.Request["prgid"];
    protected string hrefq = "";

    protected string ctrl_open = "";
    DBHelper conn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    DBHelper cnn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    private void Page_Unload(System.Object sender, System.EventArgs e)
    {
        if (conn != null) conn.Dispose();
        if (cnn != null) cnn.Dispose();
    }

    private void Page_Load(System.Object sender, System.EventArgs e)
    {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        submitTask = Request["submitTask"];
        cust_seq = Request["cust_seq"];
        cust_area = Request["cust_area"];
        ap_cname1 = Request["ap_cname1"];
        
        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        DebugStr = myToken.DebugStr;

        if (HTProgRight >= 0)
        {
            QueryPageLayout();
            this.DataBind();
        }
    }

    private void QueryPageLayout()
    {
        if ((HTProgRight & 2) > 0)
        {
            StrFormBtnTop += "<a class=\"imgCls\" href=\"javascript:void(0);\" >[關閉視窗]</a>\n";
        }
    }
    

</script>


<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <title></title>
        <uc1:head_inc_form runat="server" ID="head_inc_form" />
</head>
<body>
    <form id="form1" runat="server">
    <div>
    <input type="hidden" id="HTProgPrefix" name="HTProgPrefix" value="<%=HTProgPrefix%>" />
    <input type="hidden" id="HTProgCode" name="HTProgCode" value="<%=HTProgCode%>" />
    <input type="hidden" id="prgid" name="prgid" value="<%=prgid%>" />
    <input type="hidden" id="submitTask" name="submitTask" value="<%=submitTask%>" />
    <input type="hidden" id="apsqlno" name="apsqlno" value="<%=apsqlno%>" />
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

     <table border="0" width="100%" cellspacing="0" cellpadding="0">
            <tr>
                <td width="100%" id="Cont" colspan="2" height="100%" valign="top">
                    <uc1:cust11Form runat="server" ID="cust11Form" />
                </td>
            </tr>
    </table>
    
    </div>
    </form>
</body>
</html>

<script type="text/javascript">

    $(function () {
        this_init();
        loadData();
        $("#att_sql").lock();
        if ($("#submitTask").val() == "Q") {
            SetReadOnly();
            $("#tr_level").hide();
            $("#tr_distype").hide();
        }

        if ($("#submitTask").val() == "U") {
            $("#btnaddr").hide();
            $("#btnemail").hide();
        }


    });

    function this_init() {
        if (window.parent.tt !== undefined) {
            window.parent.tt.rows = "30%,70%";

        }
        $("input.dateField").datepick();
    }

    function SetReadOnly() {
        $("input,select,textarea").lock();
        $("input[type=button]").each(function () {
            $(this).hide();
        })
    }


    function loadData() {
        var psql = "select * FROM custz a left join apcust b ON a.cust_seq = b.cust_seq where a.cust_area = '<%=Request["cust_area"]%>' and a.cust_seq = '<%=Request["cust_seq"]%>'";

        $.ajax({
            url: "../AJAX/JsonGetSqlData.aspx?SQL=" + psql,
            type: "POST",
            async: false,
            cache: false,
            data: $("#reg").serialize(),
            success: function (json) {
                var JSONdata = $.parseJSON(json);
                var item = JSONdata[0];
                cust11form.bind(item);

            },
            beforeSend: function (jqXHR, settings) {
                jqXHR.url = settings.url;
            },
            error: function (jqXHR, textStatus, errorThrown) {
                alert("\n資料擷取剖析錯誤 !\n" + jqXHR.url);
            }
        });
    }



</script>
