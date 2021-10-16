<%@ Page Language="C#" CodePage="65001"%>

<%@ Register Src="~/brt4m/optform/BR_formA.ascx" TagPrefix="uc1" TagName="BR_formA" %>
<%@ Register Src="~/brt4m/optform/BR_form.ascx" TagPrefix="uc1" TagName="BR_form" %>
<%@ Register Src="~/brt4m/optform/Back_form.ascx" TagPrefix="uc1" TagName="Back_form" %>
<%@ Register Src="~/brt4m/optform/PR_form.ascx" TagPrefix="uc1" TagName="PR_form" %>
<%@ Register Src="~/brt4m/optform/Send_form.ascx" TagPrefix="uc1" TagName="Send_form" %>
<%@ Register Src="~/brt4m/optform/upload_Form.ascx" TagPrefix="uc1" TagName="upload_Form" %>
<%@ Register Src="~/brt4m/optform/Qu_form.ascx" TagPrefix="uc1" TagName="Qu_form" %>
<%@ Register Src="~/brt4m/optform/AP_form.ascx" TagPrefix="uc1" TagName="AP_form" %>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<script runat="server">
    protected string HTProgCap = "";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "opt22";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = HttpContext.Current.Request["prgid"] ?? "";//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";
    protected string StrFormBtnTop = "";

    protected string submitTask = "";
    protected string branch = "";
    protected string opt_sqlno = "";
    protected string opt_no = "";
    protected string case_no = "";
    protected string stat_code = "";
    protected string mconf = "";

    protected string MLock = "true";//案件客戶,客件連絡人,申請人,收費與接洽事項,案件主檔的控制
    protected string QLock = "true";//收費與接洽事項的控制
    protected string QHide = "true";
    protected string PLock = "true";//交辦內容的控制
    protected string RLock = "true";//承辦內容_分案的控制
    protected string BLock = "true";//承辦內容_承辦的控制
    protected string CLock = "true";//承辦內容_承辦的控制
    protected string SLock = "true";//承辦內容_發文的控制
    protected string SELock = "true";//有權限才可修改
    protected string ALock = "true";//承辦內容_判行的控制
    protected string P1Lock = "true";//控制show圖檔
    protected string show_qu_form = "N";//控制顯示品質評分欄位
    protected string show_ap_form = "N";//控制顯示判行內容欄位
    protected string YYLock = "true";//已判行未發文&已發文,總管處未確認
    protected string YZLock = "true";//已發文,總管處已確認

    DBHelper connopt = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    private void Page_Unload(System.Object sender, System.EventArgs e) {
        if (connopt != null) connopt.Dispose();
    }

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        connopt = new DBHelper(Conn.optK).Debug(Request["chkTest"] == "TEST");

        submitTask = Request["submitTask"] ?? "";
        branch = Request["branch"] ?? "";
        opt_sqlno = Request["opt_sqlno"] ?? "";
        opt_no = Request["opt_no"] ?? "";
        case_no = Request["case_no"] ?? "";
        stat_code = Request["stat_code"] ?? "";
        mconf = Request["mconf"] ?? "";

        if (prgid == "opt22") {
            HTProgCap = "爭救案判行作業";
            SLock = "false";
            ALock = "false";
        } else if (prgid == "opt24") {
            HTProgCap = "已判行維護作業";
            if (stat_code == "YY") {//已判行,未發文
                YYLock = "false";
                YZLock = "false";
            }
            if (stat_code == "YS") {//已發文
                if (mconf == "N") YYLock = "false";
                YZLock = "false";
            }
        } else {
            HTProgCap = "爭救案內容查詢";
            submitTask = "Q";
        }

        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        HTProgCap = myToken.Title;
        DebugStr = myToken.DebugStr;
        if (HTProgRight >= 0) {
            PageLayout();
            this.DataBind();
        }
    }

    private void PageLayout() {
        if (submitTask != "Q") {
            if ((HTProgRight & 64) > 0 || (HTProgRight & 256) > 0) {
                SELock = "false";
            }
        }

        if ((Request["back_flag"] ?? "") == "Y") {
            StrFormBtnTop += "<a href=\"javascript:history.go(-1);void(0);\">[回上一頁]</a>";
        }
        StrFormBtnTop += "<a class=\"imgCls\" href=\"javascript:void(0);\" >[關閉視窗]</a>";

        //品質評分欄位要不要show的flag
        string SQL = "select ref_code from cust_code where code_type='T92' and cust_code='" + Request["arcase"] + "'";
        object objResult = connopt.ExecuteScalar(SQL);
        string ref_code = (objResult != DBNull.Value && objResult != null) ? objResult.ToString().Trim() : "";
        if (ref_code != "V")
            show_qu_form = "Y";
    }
</script>
<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title><%=HTProgCap%></title>
    <uc1:head_inc_form runat="server" ID="head_inc_form" />
</head>

<body>
<table cellspacing="1" cellpadding="0" width="98%" border="0">
    <tr>
        <td class="text9" nowrap="nowrap">&nbsp;【<%=prgid%> <%=HTProgCap%>】
            <span id="span_sopt_no" style="color:blue">案件編號：<span id="sopt_no"></span></span>
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
    <input type="hidden" id="case_no" name="case_no" value="<%=case_no%>">
	<input type="hidden" id="opt_sqlno" name="opt_sqlno" value="<%=opt_sqlno%>">
	<input type="hidden" id="submittask" name="submittask" value="<%=submitTask%>">
	<input type="hidden" id="prgid" name="prgid" value="<%=prgid%>">
	<input type="hidden" id="show_qu_form" name="show_qu_form">
	<input type="hidden" id="progid" name="progid">
    <input type="hidden" id="stat_code" name="stat_code" value="<%=stat_code%>">
	<input type="hidden" id="mconf" name="mconf" value="<%=mconf%>">

    <table cellspacing="1" cellpadding="0" width="98%" border="0">
    <tr>
        <td>
            <uc1:BR_formA runat="server" ID="BR_formA" />
            <!--include file="../brt4m/optform/BR_formA.ascx"--><!--工作資料-->
            <uc1:BR_form runat="server" ID="BR_form" />
            <!--include file="../brt4m/optform/BR_form.ascx"--><!--分案設定-->
            <uc1:PR_form runat="server" ID="PR_form" />
            <!--include file="../brt4m/optform/PR_form.ascx"--><!--承辦內容-->
            <uc1:Send_form runat="server" id="Send_form" />
            <!--include file="../brt4m/optform/Send_form.ascx"--><!--發文資料-->
            <uc1:upload_Form runat="server" ID="upload_Form" />
            <!--include file="../brt4m/optform/upload_form.ascx"--><!--承辦附件資料-->
            <uc1:Qu_form runat="server" ID="Qu_form" />
            <!--include file="../brt4m/optform/Qu_form.ascx"--><!--品質評分-->
            <uc1:AP_form runat="server" ID="AP_form" />
            <!--include file="../brt4m/optform/AP_form.ascx"--><!--判行資料-->
            <uc1:Back_form runat="server" ID="Back_form" />
            <!--include file="../brt4m/optform/Back_form.ascx"--><!--退回處理-->
        </td>
    </tr>
    </table>
    <br />
    <%#DebugStr%>
</form>

<table border="0" width="98%" cellspacing="0" cellpadding="0">
<tr id="tr_button1">
    <td width="100%" align="center">
        <input type=button value="電子申請附件檢查" class="c1button" id="btnchkAttach">
		<input type=button value="判行" class="cbutton" onClick="formSaveSubmit('U')" id="btnSaveSubmitU">
		<input type=button value="編修存檔" class="cbutton" onClick="formSaveSubmit('S')" id="btnSaveSubmitS">
		<input type=button value="退回承辦" class="redbutton" id="btnBack1Submit">
    </td>
</tr>
<tr id="tr_button2" style="display:none">
    <td align="center">
        <input type=button value="退回" class="redbutton" id="btnBackSubmit">
        <input type=button value="取消" class="c1button" id="btnResetSubmit">
    </td>
</tr>
</table>

<iframe id="ActFrame" name="ActFrame" src="about:blank" width="100%" height="300" style="display:none"></iframe>
</body>
</html>

<script language="javascript" type="text/javascript">
    $(function () {
        if (window.parent.tt !== undefined) {
            window.parent.tt.rows = "20%,80%";
        }
        this_init();
    });

    var br_opt = {};
    //初始化
    function this_init() {
        settab("#br");
        $("input.dateField").datepick();
        //欄位控制
        $("#tr_Popt_show1").show();
        $("#tr_opt_show").show();
        $("#tr_button1,#tr_button2").showFor($("#submittask").val()!="Q");//按鈕
        $("#tabreject,#tr_button2").hide();//退回視窗//退回視窗&按鈕

        //取得案件資料
        $.ajax({
            type: "get",
            url: getRootPath() + "/ajax/_OptData.aspx?branch=<%=branch%>&opt_sqlno=<%=opt_sqlno%>",
            async: false,
            cache: false,
            success: function (json) {
                if ($("#chkTest").length > 0) toastr.info("<a href='" + this.url + "' target='_new'>Debug(this_init)！<BR><b><u>(點此顯示詳細訊息)</u></b></a>");
                var JSONdata = $.parseJSON(json);
                if (JSONdata.length == 0) {
                    toastr.warning("無案件資料可載入！");
                    return false;
                }
                br_opt = JSONdata;
                if(br_opt.opt.length>0){
                    $("#sopt_no").html(br_opt.opt[0].opt_no);
                    $("#sseq").html(br_opt.opt[0].fseq);
                }
            },
            error: function () { toastr.error("<a href='" + this.url + "' target='_new'>案件資料載入失敗！<BR><b><u>(點此顯示詳細訊息)</u></b></a>"); }
        });

        $("#sopt_no").html(br_opt.opt[0].opt_no);
        br_formA.init();
        br_form.init();
        back_form.init();
        pr_form.init();
        send_form.init();
        upload_form.init();
        qu_form.init();
        ap_form.init();

        if($("#prgid").val()=="opt24" && ($("#stat_code").val()=="YY" || $("#stat_code").val()=="YS")){
            $("#btnSaveSubmitU,#btnBack1Submit,#btnchkAttach").hide();//判行/退回承辦
            $("#btnSaveSubmitS").show();//編修存檔
        }else{
            $("#btnSaveSubmitS").hide();//編修存檔
        }

        $(".Lock").lock();
        $(".MLock").lock(<%#MLock%>);
        $(".QLock").lock(<%#QLock%>);
        $(".QHide").hideFor(<%#QHide%>);
        $(".PLock").lock(<%#PLock%>);
        $(".RLock").lock(<%#RLock%>);
        $(".BLock").lock(<%#BLock%>);
        $(".CLock").lock(<%#CLock%>);
        $(".SLock").lock(<%#SLock%>);
        $(".SELock").lock(<%#SELock%>);
        $(".ALock").lock(<%#ALock%>);
        $(".P1Lock").lock(<%#P1Lock%>);
        $(".YYLock").lock(<%#YYLock%>);
        $(".YZLock").lock(<%#YZLock%>);
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

    //判行
    function formSaveSubmit(dowhat){
        if (dowhat == "U" && $("#send_way").val() == "E") {
            if ($("input[name='send_dept']:checked").val() != "B" || $("#send_cl").val() != "1") {
                alert("選擇「電子送件」時，發文單位須為「自行發文」且發文對象須為「智慧財產局」！");
            }
            //未檢查通過
            if (!document.getElementById('btnchkAttach').disabled) {
                alert("請先執行電子申請附件檢查!!");
                return false;
            }
        }

        $("#rs_agt_no").val($("#code_br_agt_no").val());

        if ($("#PRY_hour").val()==""||$("#PRY_hour").val()=="0"){
            if(!confirm("是否確定不輸入核准時數？？")) {
                $("#PRY_hour").focus();
                return false;
            }
        }

        if ($("#AP_hour").val()==""||$("#AP_hour").val()=="0"){
            if(!confirm("是否確定不輸入判行核稿時數？？")) {
                $("#AP_hour").focus();
                return false;
            }
        }

        $("select,textarea,input,span").unlock();
        $("#tr_button1 input:button").lock(!$("#chkTest").prop("checked"));
        reg.submittask.value = dowhat;
        reg.action = "<%=HTProgPrefix%>_Update.aspx";
        reg.target = "ActFrame";
        reg.submit();
    }

    //退回分案(1)
    $("#btnBack1Submit").click(function () {
        if (confirm("是否確定退回重新承辦？？")) {
            $("#tr_button1,#tabQu,#tabAP").hide();
            $("#tr_button2,#tabreject").show();
        }else{
            $("#tr_button1,#tabQu,#tabAP").show();
            $("#tr_button2,#tabreject").hide();
        }
    });

    //退回(2)
    $("#btnBackSubmit").click(function () {
        if ($("#Preject_reason").val() == "") {
            alert("請輸入退回原因！");
            $("#Preject_reason").focus();
            return false;
        }
        
        $("select,textarea,input,span").unlock();
        $("#btnBackSubmit,#btnResetSubmit").lock(!$("#chkTest").prop("checked"));
        reg.submittask.value = "B";
        reg.action = "<%=HTProgPrefix%>_Update.aspx";
        reg.target = "ActFrame";
        reg.submit();
    });

    //取消
    $("#btnResetSubmit").click(function () {
        $("#tr_button1,#tabQu,#tabAP").show();
        $("#tr_button2,#tabreject").hide();
        $("#tr_button1 input:button").unlock();
    });

    //電子申請附件檢查
    $("#btnchkAttach").click(function () {
        $(document).unbind();//檢查時會卡太久
        if ($("#send_way").val() != "E") {
            alert("非電子送件不需檢查!");
            return false;
        }

        $.ajax({
            url: "opt22checkWord.aspx?opt_sqlno=" + $('#opt_sqlno').val() + "&debug=Y",
            cache: false,
            type: 'GET',
            dataType: "script",//回傳的格式為script
            beforeSend: function (xhr) {
                $('#msg').html("檢查中..");
            },
            error: function (xhr) {
                $('#msg').html("<Font align=left color='red' size=3>檢查【附送書件】發生未知錯誤，請聯繫資訊人員!!</font>");
                alert('檢查【附送書件】發生錯誤!!');
            }
        });
    });
</script>
