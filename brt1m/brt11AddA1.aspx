<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Register Src="~/commonForm/cust_form.ascx" TagPrefix="uc1" TagName="cust_form" %>
<%@ Register Src="~/commonForm/attent_form.ascx" TagPrefix="uc1" TagName="attent_form" %>
<%@ Register Src="~/commonForm/apcust_form.ascx" TagPrefix="uc1" TagName="apcust_form" %>
<%@ Register Src="~/commonForm/dmt/FA1_form_remark1.ascx" TagPrefix="uc1" TagName="FA1_form_remark1" %>
<%@ Register Src="~/commonForm/dmt_upload_Form.ascx" TagPrefix="uc1" TagName="dmt_upload_Form" %>


<script runat="server">
    protected string HTProgCap = HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "brt11";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = HttpContext.Current.Request["prgid"] ?? "";//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";
    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";
    
    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    public Dictionary<string, string> Lock = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    protected string tfy_Arcase = "";

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");
        
        Token myToken = new Token(HTProgCode);
        HTProgRight = myToken.CheckMe();
        HTProgCap = myToken.Title;
        DebugStr = myToken.DebugStr;
        if (HTProgRight >= 0) {
            PageLayout();
            this.DataBind();
        }
    }

    private void PageLayout() {
        tfy_Arcase = Funcs.getCodeBr(Funcs.getRsType(), Request["Ar_form"], "A").Option("{rs_code}", "{rs_code}---{rs_detail}", "v1='{prt_code}' v2='{remark}'", false);
    }
</script>
<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title><%=HTProgCap%></title>
<link rel="stylesheet" type="text/css" href="<%=Page.ResolveUrl("~/inc/setstyle.css")%>" />
<link rel="stylesheet" type="text/css" href="<%=Page.ResolveUrl("~/js/lib/jquery.datepick.css")%>" />
<link rel="stylesheet" type="text/css" href="<%=Page.ResolveUrl("~/js/lib/toastr.css")%>" />
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/jquery-1.12.4.min.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/jquery.datepick.min.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/jquery.datepick-zh-TW.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/toastr.min.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/util.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/jquery.Snoopy.date.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/jquery.irene.form.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/client_chk.js")%>"></script>
</head>

<body>
<table cellspacing="1" cellpadding="0" width="98%" border="0">
    <tr>
        <td class="text9" nowrap="nowrap">&nbsp;【<%=HTProgCode%><%=HTProgCap%>】
        </td>
        <td class="FormLink" valign="top" align="right" nowrap="nowrap">
            <%#StrFormBtnTop%>
        </td>
    </tr>
    <tr>
        <td colspan="2"><hr class="style-one"/></td>
    </tr>
</table>
<br>
<form id="reg" name="reg" method="post">
	<input type="hidden" id="submittask" name="submittask">
	<input type="hidden" id="prgid" name="prgid" value="<%=prgid%>">

    <table cellspacing="1" cellpadding="0" width="98%" border="0">
    <tr>
        <td>
        <table border="0" cellspacing="0" cellpadding="0">
            <tr id="CTab">
                <td class="tab" href="#cust">案件客戶</td>
                <td class="tab" href="#attent">案件聯絡人</td>
                <td class="tab" href="#apcust">案件申請人</td>
                <td class="tab" href="#case">收費與接洽事項</td>
                <td class="tab" href="#tran">交辦內容</td>
                <td class="tab" href="#upload">文件上傳</td>
            </tr>
        </table>
        </td>
    </tr>
    <tr>
        <td>
            <div class="tabCont" id="#cust">
                <uc1:cust_form runat="server" ID="cust_form" />
                <!--include file="../commonForm/cust_form.ascx"--><!--案件客戶-->
            </div>
            <div class="tabCont" id="#attent">
                <uc1:attent_form runat="server" ID="attent_form" />
                <!--include file="../commonForm/attent_form.ascx"--><!--案件聯絡人-->
            </div>
            <div class="tabCont" id="#apcust">
                <uc1:apcust_form runat="server" ID="apcust_form" />
                <!--include file="../commonForm/apcust_form.ascx"--><!--案件申請人-->
            </div>
            <div class="tabCont" id="#case">
                <select NAME=tfy_Arcase id=tfy_Arcase onchange ="javascript:ToArcase('T',this.value ,'Z1')">
				    <option value="" class="blueopt">請選擇</option>
				    <%#tfy_Arcase%>
				</SELECT>
            </div>
            <div class="tabCont" id="#tran">
                <uc1:FA1_form_remark1 runat="server" ID="FA1_form_remark1" />
            </div>
            <div class="tabCont" id="#upload">
                <uc1:dmt_upload_Form runat="server" id="dmt_upload_Form" />
                <!--include file="../commonForm/dmt_upload_Form.ascx"--><!--文件上傳-->
            </div>
        </td>
    </tr>
    </table>
    <br />
    <%#DebugStr%>
</form>
<script type="text/html" id="tran_DE1">
    <li><strong>DE1</strong></li>
    <script>
        function init() {
            alert('DE1');
        }
    </script>
</script>
<script type="text/html" id="tran_DE2">
    <li><strong>DE2</strong></li>
    <script>
        function init() {
            alert('DE2');
        }
    </script>
</script>
<script type="text/html" id="tran_DI1">
    <li><strong>DI1</strong></li>
    <script>
        function init() {
            alert('DI1');
        }
    </script>
</script>

<table border="0" width="98%" cellspacing="0" cellpadding="0">
<tr id="tr_button1">
    <td width="100%" align="center">
       <%#StrFormBtn%>
    </td>
</tr>
<tr id="tr_button2" style="display:none">
    <td align="center">
        <input type=button value="退回" class="redbutton" id="btnBackSubmit">
        <input type=button value="取消" class="c1button" id="btnResetSubmit">
    </td>
</tr>
</table>

<iframe id="ActFrame" name="ActFrame" src="about:blank" width="100%" height="500" style="display:none"></iframe>
</body>
</html>

<script language="javascript" type="text/javascript">
    $(function () {
        if (window.parent.tt !== undefined) {
            window.parent.tt.rows = "100%,0%";
        }

        this_init();
    });

    var main = {};
    main.cust_area = "<%#ReqVal.TryGet("cust_area")%>";
    main.cust_seq = "<%#ReqVal.TryGet("cust_seq")%>";
    main.in_no = "<%#ReqVal.TryGet("in_no")%>";
    main.data = {};
    //main.in_no = "20191230001";
    //初始化
    function this_init() {
        settab("#case");
        $("input.dateField").datepick();

        //取得交辦資料
        $.ajax({
            type: "get",
            url: getRootPath() + "/ajax/_case_dmt.aspx?submittask=" + $("#submittask").val() + "&cust_area=" + main.cust_area + "&cust_seq=" + main.cust_seq + "&in_no=" + main.in_no,
            async: false,
            cache: false,
            success: function (json) {
                if ($("#chkTest").prop("checked")) toastr.info("<a href='" + this.url + "' target='_new'>Debug！<BR><b><u>(點此顯示詳細訊息)</u></b></a>");
                var JSONdata = $.parseJSON(json);
                if (JSONdata.length == 0) {
                    toastr.warning("無交辦資料可載入！");
                    return false;
                }
                main.data = JSONdata;
            },
            error: function () { toastr.error("<a href='" + this.url + "' target='_new'>案件資料載入失敗！<BR><b><u>(點此顯示詳細訊息)</u></b></a>"); }
        });

        if ($("#submittask").val() == "AddNext") {//複製
        } else {
            //客戶
            $("#F_cust_area").val(main.cust_area);
            $("#F_cust_seq").val(main.cust_seq);
            $("#btncust_seq").click();
            //cust_form.init();
            //聯絡人
            attent_form.getatt($("#tfy_cust_area").val(), $("#tfy_cust_seq").val(), $("#tfy_att_sql").val());
            //申請人//04322046
            apcust_form.getapp(main.data.apcust[0].apcust_no, "");
        }
        upload_form.init();

        $(".Lock").lock();
    }

    // 切換頁籤
    $("#CTab td.tab").click(function (e) {
        settab($(this).attr('href'));
    });
    function settab(k) {
        $("#CTab td.tab").removeClass("seltab").addClass("notab");
        $("#CTab td.tab[href='" + k + "']").addClass("seltab").removeClass("notab");
        $("div.tabCont").hide();
        $("div.tabCont[id='" + k + "']").show();
    }

    //關閉視窗
    $(".imgCls").click(function (e) {
        if (window.parent.tt !== undefined) {
            window.parent.tt.rows = "100%,0%";
        } else {
            window.close();
        }
    })

    function ToArcase(a, b, c) {
        var template = $('#tran_'+b).text();
        $("div.tabCont[id='#tran'").empty();
        $("div.tabCont[id='#tran'").append(template);
        init();
    }
</script>