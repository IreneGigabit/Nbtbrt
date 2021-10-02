<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Data"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>
<%@ Register Src="~/cust/impForm/cust17Form.ascx" TagPrefix="uc1" TagName="cust17Form" %>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>

<!DOCTYPE html>


<script runat="server">
    
    protected string HTProgCap = "發明/創作人資料";
    protected string HTProgPrefix = "cust17";
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    
    private int HTProgAcs = 1;
    private int HTProgRight = 0;

    protected string StrAddLink = "";
    protected string StrSaveBtn = "";
    protected string StrResetBtn = "";
    protected string submitTask = "";
    protected string antid = "";
    protected string antcname = "";
    protected string DebugStr = "";
    
    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";
    protected string FormName = "";
    protected string scode = "";
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
        antid = Request["ant_id"];
        antcname = Request["ant_name"];
        
        if (submitTask == "A") HTProgCap = HTProgCap + "-<font color=blue>新增</font>";
        if (submitTask == "U") HTProgCap = HTProgCap + "-<font color=blue>維護</font>";
        if (submitTask == "Q") HTProgCap = HTProgCap + "-<font color=blue>查詢</font>";

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

        if (((HTProgRight & 4) > 0 && (submitTask == "A")) || ((HTProgRight & 8) > 0 && (submitTask == "U")) ||
            ((HTProgRight & 8) > 0 && (submitTask == "A" || submitTask == "U" || submitTask == "C")) || (HTProgRight & 256) > 0)
        {
            if (submitTask == "Q") { }
            else
            {
                StrSaveBtn = "<input type=\"button\" id=\"btnSave\" value =\"存　檔\" class=\"cbutton bsubmit\"  />";//****class增加bsubmit.存檔時會控制鎖定.防止連點
                StrResetBtn = "<input type=\"button\" id=\"btnReset\" value =\"重　填\" class=\"cbutton\" />";
            }
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
    
    <form id="reg" name="reg" method="post" action="">
    <div>
    <input type="hidden" id="HTProgPrefix" name="HTProgPrefix" value="<%=HTProgPrefix%>" />
    <input type="hidden" id="HTProgCode" name="HTProgCode" value="<%=HTProgCode%>" />
    <input type="hidden" id="prgid" name="prgid" value="<%=prgid%>" />
    <input type="hidden" id="submitTask" name="submitTask" value="<%=submitTask%>" />

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
    
    <center>
    <table border="0" width="100%" cellspacing="0" cellpadding="0">
            <tr>
                <td width="100%" id="Cont" colspan="2" height="100%" valign="top">
                    <uc1:cust17Form runat="server" ID="cust17Form" />
                </td>
            </tr>
    </table>
    </center>
    </div>
         <%#DebugStr%>
    </form>
    <table border="0" width="100%" cellspacing="0" cellpadding="0">
    <tr>
        <td width="100%" align="center">
            <%#StrSaveBtn%>
            <%#StrResetBtn%>                    
        </td>
    </tr>
    </table>
    <div id="dialog"></div>
</body>
</html>

<script language="javascript" type="text/javascript">
    $(function () {
        this_init();
        loadData();

        if ($("#submitTask").val() == "Q") {
            cust17form.LockAll();
            $("#btn_cust_seqDetail").show();
        }

        if ($("#submitTask").val() == "A") {
            cust17form.addReadOnly(<%="'"+antid+"'"%>, <%="'"+antcname+"'"%>)
        }
    });

    function this_init() {
        if (window.parent.tt !== undefined) {
            window.parent.tt.rows = "0%,100%";
        }
    }

    //[重填]
    $("#btnReset").click(function (e) {
        reg.reset();
        this_init();
    });

    $(".dateField").blur(function (e) {
        ChkDate(this);
    });

    //[存檔]
    $("#btnSave").click(function (e) {

        if ($.trim($("#cust_seq").val()) != "") {
            cust17form.GetapcustData('SetName', 'cust_seq', 'N')
        }
        if ($.trim($("#apcust_no").val()) != "") {
            cust17form.GetapcustData('SetDetail', 'apcust_no', 'N')
        }

        if (cust17form.Chkant_id() == false) {
            return;
        }
        if (cust17form.chkSaveData() == false) {
            return;
        }
        if (cust17form.chkapcust_no() == false) {
            return;
        }
        if ($.trim($("#ant_id").val()) != "") {
            if (cust17form.Chkant_idDouble($("#submitTask").val(), $.trim($("#ant_id").val())) == false) {
                return;
            }
        }

        $("input:disabled, select:disabled").unlock();
        $(".bsubmit").lock(!$("#chkTest").prop("checked"));

        var formData = new FormData($('#reg')[0]);
        ajaxByForm("cust17_Update.aspx", formData)
        .complete(function (xhr, status) {
            $("#dialog").html(xhr.responseText);
            $("#dialog").dialog({
                title: '存檔訊息', modal: true, maxHeight: 500, width: 800, closeOnEscape: false
                , buttons: {
                    確定: function () {
                        $(this).dialog("close");
                    }
                }
                , close: function (event, ui) {
                    if (status == "success") {
                        if (!$("#chkTest").prop("checked")) {
                            window.parent.tt.rows = "100%,0%";
                        }
                    }
                }
            });
        });

    });//btnSave End

    function loadData() {
        var psql = "select *, " +
            "(select ap_cname1 from apcust where cust_seq <> 0 and cust_seq = b.cust_seq) as ap_cname1 " +
            "FROM inventor b WHERE antsqlno = '<%=Request["antsqlno"]%>' and ant_no = '<%=Request["ant_no"]%>'";
        $.ajax({
            url: "../AJAX/JsonGetSqlData.aspx?SQL=" + psql,
            type: "POST",
            async: false,
            cache: false,
            data: $("#reg").serialize(),
            success: function (json) {
                var JSONdata = $.parseJSON(json);
                cust17form.bind(JSONdata);

            },
            beforeSend: function (jqXHR, settings) {
                jqXHR.url = settings.url;
            },
            error: function (jqXHR, textStatus, errorThrown) {
                alert("\n資料擷取剖析錯誤 !\n" + jqXHR.url);
            }
        });

        if ($("#same_ap").prop("checked") == true) {
            $("#bapcustno").val("Y");
        }
    }

   


</script>
