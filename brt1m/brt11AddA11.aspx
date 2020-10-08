<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Register Src="~/commonForm/cust_form.ascx" TagPrefix="uc1" TagName="cust_form" %>
<%@ Register Src="~/commonForm/attent_form.ascx" TagPrefix="uc1" TagName="attent_form" %>
<%@ Register Src="~/commonForm/apcust_form.ascx" TagPrefix="uc1" TagName="apcust_form" %>
<%@ Register Src="~/commonForm/dmt/case_form.ascx" TagPrefix="uc1" TagName="case_form" %>
<%@ Register Src="~/commonForm/dmt/dmt_upload_Form.ascx" TagPrefix="uc1" TagName="dmt_upload_Form" %>
<%@ Register Src="~/brt1m/CaseForm/A11_form.ascx" TagPrefix="uc1" TagName="br_A11_form" %>

<script runat="server">
    protected string HTProgCap = HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "brt11";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";
    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";
    protected string formFunction = "";
    
    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected Dictionary<string, string> Lock = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    protected string submitTask = "";
    protected string ar_form = "";
    protected string prt_code = "";
    protected string new_form = "";
    protected string case_stat = "";
    protected string code_type = "";

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");
        submitTask = (Request["submittask"] ?? "").Trim();
        ar_form = (Request["ar_form"] ?? "").Trim();
        prt_code = (Request["prt_code"] ?? "").Trim();
        new_form = (Request["new_form"] ?? "").Trim();
        case_stat = (Request["case_stat"] ?? "").Trim();
        code_type = (Request["code_type"] ?? "").Trim();

        formFunction = (Request["formFunction"] ?? "").Trim();
        if (formFunction == "") {
            formFunction = "Add";
        }
        
        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        HTProgCap = myToken.Title;
        DebugStr = myToken.DebugStr;
        if (HTProgRight >= 0) {
            PageLayout();
            ChildBind();
            this.DataBind();
        }
    }

    private void PageLayout() {
        StrFormBtnTop += "<a href=\""+Page.ResolveUrl("~/cust/cust11_mod.aspx")+"?cust_area="+Request["cust_area"]+"&cust_seq="+Request["cust_seq"]+"&hRight=4&attmodify=A&gs_dept=T\" target=\"Brt11blank\">[聯絡人新增]</a>\n";
        StrFormBtnTop += "<a href=\""+Page.ResolveUrl("~/cust/cust13.aspx")+"\" target=\"Brt11blank\">[申請人新增]</a>\n";
        
        if (formFunction == "Edit") {
            if ((HTProgRight & 8) > 0) {
                if (prgid == "brt51") {//客收確認
                    StrFormBtn += "<input type=button value ='資料確認無誤' class='cbutton bsubmit' onclick='formModSubmit()'>\n";
                    StrFormBtn += "<input type=button value ='資料有誤退回營洽' class='cbutton bsubmit' onclick='formModSubmit2()'>\n";
                } else {
                    StrFormBtn += "<input type=button value ='編修存檔' class='cbutton bsubmit' onclick='formModSubmit()'>\n";
                }
            }

            StrFormBtn += "<input type=button value ='重　填' class='cbutton' onclick='this_init()'>\n";
        } else if (formFunction == "Add") {
            if ((HTProgRight & 4) > 0) {
                StrFormBtn += "<input type=button value ='新增存檔' class='cbutton bsubmit' onclick='formAddSubmit()'>\n";
                StrFormBtn += "<input type=button value ='重　填' class='cbutton' onclick='this_init()'>\n";
            }
        }
    }

    //將共用參數傳給子控制項
    private void ChildBind() {
        //案件客戶
        cust_form.Lock = Lock;
        //案件聯絡人
        attent_form.Lock = Lock;
        //案件申請人
        apcust_form.Lock = Lock;
        //收費與接洽事項
        case_form.formFunction = formFunction;
        case_form.HTProgRight = HTProgRight;
        //交辦內容
        br_A11_form.Lock = Lock;
    }
</script>
<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title><%=HTProgCap%></title>
<link rel="stylesheet" type="text/css" href="<%=Page.ResolveUrl("~/inc/setstyle.css")%>" />
<link rel="stylesheet" type="text/css" href="<%=Page.ResolveUrl("~/js/lib/jquery.datepick.css")%>" />
<link rel="stylesheet" type="text/css" href="<%=Page.ResolveUrl("~/js/lib/toastr.css")%>" />
<link rel="stylesheet" type="text/css" href="<%=Page.ResolveUrl("~/js/lib/jquery-ui.min.css")%>" />
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/jquery-1.12.4.min.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/jquery-ui.min.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/jquery.datepick.min.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/jquery.datepick-zh-TW.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/toastr.min.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/util.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/jquery.Snoopy.date.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/jquery.irene.form.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/client_chk.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/client_chk_agtno.js")%>"></script><!--檢查輸入出名代理人是否與預設出名代理人相同-->
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/client_chk_doctype.js")%>"></script><!--檢查契約書種類與上傳文件-->
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/client_chk_custwatch.js")%>"></script><!--檢查是否為雙邊代理查照對象-->
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
	<input type="text" id="submittask" name="submittask" value="<%=submitTask%>">
	<input type="text" id="prgid" name="prgid" value="<%=prgid%>">
    <INPUT TYPE="text" id="Ar_Form" name="Ar_Form" value="<%=ar_form%>">
    <INPUT TYPE="text" id=prt_code name=prt_code value="<%=prt_code%>">
    <INPUT TYPE="text" id=new_form name=new_form value="<%=new_form%>">
    <INPUT TYPE="text" id=add_arcase name=add_arcase value="">
    <INPUT TYPE="text" id=tfy_case_stat name=tfy_case_stat value="<%=case_stat%>"><!--案件狀態-->
    <input type="text" id="draw_attach_file" name="draw_attach_file"><!--2013/11/25商標圖檔改虛擬路徑增加-->

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
                <uc1:case_form runat="server" id="case_form" />
                <!--include file="../commonForm/dmt/case_form.ascx"--><!--收費與接洽事項-->
            </div>
            <div class="tabCont" id="#tran">
                <uc1:br_A11_form runat="server" ID="br_A11_form" />
            </div>
            <div class="tabCont" id="#upload">
                <uc1:dmt_upload_Form runat="server" ID="dmt_upload_Form" />
            </div>
        </td>
    </tr>
    </table>
    <br />
	<INPUT TYPE="text" id=in_scode name=in_scode>
	<INPUT TYPE="text" id=in_no name=in_no>
    <INPUT TYPE="text" id=in_date name=in_date size="8">

    <%#DebugStr%>
</form>

<table border="0" width="98%" cellspacing="0" cellpadding="0">
<tr>
    <td width="100%" align="center">
        <%#StrFormBtn%>
    </td>
</tr>
</table>

<div id="dialog">
    <!--iframe id="myIframe" src="about:blank" width="100%" height="97%" style="border:none""></iframe-->
</div>

<iframe id="ActFrame" name="ActFrame" src="about:blank" width="100%" height="500" style="display:none"></iframe>
</body>
</html>

<script language="javascript" type="text/javascript">
    $(function () {
        if (window.parent.tt !== undefined) {
            window.parent.tt.rows = "100%,0%";
        }

        this_init();//畫面準備&資料綁定
    });

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

    var main = {};
    main.branch = "<%#Session["SeBranch"]%>";
    main.prgid = "<%#prgid%>";
    main.right = <%#HTProgRight%>;
    main.formFunction = "<%#formFunction%>";
    //main.ar_form = "<%#ar_form%>";
    main.cust_area = "<%#ReqVal.TryGet("cust_area")%>";
    main.cust_seq = "<%#ReqVal.TryGet("cust_seq")%>";
    main.in_no = "<%#ReqVal.TryGet("in_no")%>";
    main.code_type = "<%#ReqVal.TryGet("code_type")%>";
    jMain = {};

    function this_init() {
        //畫面準備
        cust_form.init();//案件客戶
        attent_form.init();//案件聯絡人
        apcust_form.init();//案件申請人
        case_form.init();//收費與接洽事項
        upload_form.init();//文件上傳
        settab("#case");//收費與接洽事項

        //-----------------
        this_bind();//資料綁定
        $("input.dateField").datepick();
        $(".Lock").lock();
    }

    <!--#include virtual="~\brt1m\CaseForm\A11_bind.js" --><!--資料綁定-->
    
    //存檔檢查
    function formAddSubmit(){
        //2014/4/22增加檢查是否為雙邊代理查照對象,客戶名稱
        if (cust_name_chk($("#F_ap_cname1").val()+$("#F_ap_cname2").val(),$("#F_ap_ename1").val()+$("#F_ap_ename2").val())){
            settab("#cust");
            return false;
        }

        //2014/4/22增加檢查是否為雙邊代理查照對象,客戶代表人名稱
        if (aprep_name_chk($("#F_ap_crep").val(),$("#F_ap_erep").val())){
            settab("#cust");
            return false;
        }

        //聯絡人檢查
        if (IsEmpty($("#tfy_att_sql").val())){
            alert("聯絡人資料不得為空白！");
            settab("#attent");
            $("#tfy_att_sql").focus();
            return false;
        }

        //申請人檢查
        if ($("#apnum").val()=="0"){
            alert("請輸入申請人資料！");
            settab("#apcust");
            $("#AP_Add_button").focus();
            return false;
        }
        for(var tapnum=1;tapnum<=CInt($("#apnum").val());tapnum++){
            if(IsEmpty($("#apcust_no_"+tapnum).val())){
                alert("申請人編號不得為空白！");
                settab("#apcust");
                $("#apcust_no_"+tapnum).focus();
                return false;
            }
            $("#ap_cname_"+tapnum).val($("#ap_cname1_"+tapnum).val()+$("#ap_cname2_"+tapnum).val());
            $("#ap_ename_"+tapnum).val($("#ap_ename1_"+tapnum).val()+" "+$("#ap_ename2_"+tapnum).val());
            if($("#ap_cname1_"+tapnum).val()!=""){
                if(fDataLen($("#ap_cname1_"+tapnum))){
                    settab("#apcust");
                    $("#ap_cname1_"+tapnum).focus();
                    return false;
                }
            }
            if($("#ap_cname2_"+tapnum).val()!=""){
                if(fDataLen($("#ap_cname2_"+tapnum))){
                    settab("#apcust");
                    $("#ap_cname2_"+tapnum).focus();
                    return false;
                }
            }
            if($("#ap_ename1_"+tapnum).val()!=""){
                if(fDataLen($("#ap_ename1_"+tapnum))){
                    settab("#apcust");
                    $("#ap_ename1_"+tapnum).focus();
                    return false;
                }
            }
            if($("#ap_ename2_"+tapnum).val()!=""){
                if(fDataLen($("#ap_ename2_"+tapnum))){
                    settab("#apcust");
                    $("#ap_ename2_"+tapnum).focus();
                    return false;
                }
            }
            //2014/4/22增加檢查是否為雙邊代理查照對象
            if (cust_name_chk($("#ap_cname_"+tapnum).val(),$("#ap_ename_"+tapnum).val())){
                settab("#apcust");
                return false;
            }
            if (aprep_name_chk($("#ap_crep_"+tapnum).val(),$("#ap_erep_"+tapnum).val())){
                settab("#apcust");
                return false;
            }
        }
        //收費與接洽事項檢查
        if(IsEmpty($("#tfy_Arcase").val())){
            alert("客收/請款案性不得為空白！");
            settab("#case");
            $("#tfy_Arcase").focus();
            return false;
        }
        //次委辦案性與金額檢查
        for(var q=1;q<=CInt($("#TaCount").val());q++){
            //檢查沒選案性但有輸金額
            if(IsEmpty($("#nfyi_item_Arcase_" + q).val())){
                if(CInt($("#nfyi_Service_" + q).val())!=0){
                    alert(q+".其他費用服務費不為0，請輸入"+q+".其他費用之案性！");
                    settab("#case");
                    $("#nfyi_item_Arcase_"+q).focus();
                    return false;
                }

                if(CInt($("#nfyi_fees_" + q).val())!=0){
                    alert(q+".其他費用規費不為0，請輸入"+q+".其他費用之案性！");
                    settab("#case");
                    $("#nfyi_item_Arcase_"+q).focus();
                    return false;
                }
            }
        }

        if(IsEmpty($("#tfy_Ar_mark").val())){
            alert("請款註記不得為空白！");
            settab("#case");
            $("#tfy_Ar_mark").focus();
            return false;
        }

        if(IsEmpty($("#F_tscode").val())){
            alert("洽案營洽不得為空白！");
            settab("#case");
            $("#F_tscode").focus();
            return false;
        }

        //案源代碼檢查
        if(IsEmpty($("#tfy_source").val())){
            alert("案源代碼不得為空白！");
            settab("#case");
            $("#tfy_source").focus();
            return false;
        }

        //20160910 增加發文方式檢查
        if(IsEmpty($("#tfy_send_way").val())){
            alert("發文方式不得為空白！");
            settab("#case");
            $("#tfy_send_way").focus();
            return false;
        }

        //20180221 增加電子收據檢查
        //20180619 若規費不是0才要檢查
        if(CInt($("#nfy_fees").val())!=0){
            if(IsEmpty($("#tfy_receipt_type").val())){
                alert("收據種類不得為空白！");
                settab("#case");
                $("#tfy_receipt_type").focus();
                return false;
            }
            if(IsEmpty($("#tfy_receipt_title").val())){
                alert("收據抬頭不得為空白！");
                settab("#case");
                $("#tfy_receipt_title").focus();
                return false;
            }
        }

        //20180412 增加總契約書檢查
        if($("#Contract_no_Type_M").prop("checked")){
            if(IsEmpty($("#Mcontract_no").val())){
                alert("請選擇總契約書！");
                settab("#case");
                return false;
            }
        }

        var code3 = $("#tfy_Arcase").val().substr(2, 1).toUpperCase();//案性第3碼
        var prt_code = $("#tfy_Arcase option:selected").attr("v1");
        
        //***其他商標
        if (code3=="K"){
            var mark2=$("input[name='tfz1_s_mark2']:checked").val();
            if (mark2!="H"&&mark2!="I"&&mark2!="J") {
                alert("案性為『其他』時，商標種類只能選『位置、氣味、觸覺』其一");
                return false;
            }
        }

        //***證明標章之證明標的
        if (code3=="D"||code3=="E"||code3=="F"||code3=="G"){
            var pul=$("input[name='pul']:checked").val();
            if( pul == null){
                alert("請輸入標章證明標的及內容");
                settab("#tran");
                return false;
            }else{
                $("#tfz1_pul").val(pul);
            }
        }

        //****團體標章表彰之內容	
        if (code3=="9"||code3=="A"||code3=="B"||code3=="C"){
            if(IsEmpty($("#tf91_good_name").val())){
                alert("請輸入團體標章表彰之內容");
                settab("#tran");
                return false;
                $("#tf91_good_name").focus();
            }
        }

        //****優先權申請日檢查	
        if(!IsEmpty($("#pfz1_prior_date").val())&&!$.isDate($("#pfz1_prior_date").val())){
            alert("請檢查優先權申請日，日期格式是否正確!!");
            settab("#tran");
            return false;
            $("#pfz1_prior_date").focus();
        }

        //折扣請核單檢查2005/10/11雄商平淑提出與李經理確認修改如下
        //折扣率>=30檢查需附折扣請核單，為因應折扣率21~29仍需附折扣請款單，不控制>=30勾選材存檔，營洽勾選即存檔	
        //2005/11/22李經理指示折扣率>30需簽折扣請核單，服務費等於七折不用簽折扣請核單
        //2016/5/30修改，因折扣請核改為線上，所以不需檢復折扣請核單，判斷>20需填寫折扣理由
        if($("#nfy_Discount").val()!=""&&CInt($("#nfy_Discount").val())>20){
            if($("#tfy_discount_remark").val()==""){
                alert("折扣低於8折，應填寫折扣理由，請輸入！");
                settab("#case");
                $("#tfy_discount_remark").focus();
                return false;
            }
        }
        //轉帳費用檢查
        if($("#tfy_oth_arcase").val()!=""){
            if($("#nfy_oth_money").val()=="0"){
                alert("有轉帳費用，請輸入轉帳金額，如無轉帳金額，請將轉帳費用修改為”請選擇”!!");
                settab("#case");
                $("#nfy_oth_money").focus();
                return false;
            }
            if($("#tfy_oth_code").val()==""){
                alert("有轉帳費用，請輸入轉帳單位，如無轉帳單位，請將轉帳費用修改為”請選擇”!!");
                settab("#case");
                $("#tfy_oth_code").focus();
                return false;
            }
        }
        if(IsNumeric($("#nfy_oth_money").val())){
            if(CInt($("#nfy_oth_money").val())>0){
                if($("#tfy_oth_code").val()==""){
                    alert("有轉帳金額，請輸入轉帳單位!!");
                    settab("#case");
                    $("#tfy_oth_code").focus();
                    return false;
                }
            }else if(CInt($("#nfy_oth_money").val())<0){
                alert("轉帳費用不可為負數，請重新輸入!!");
                settab("#case");
                $("#nfy_oth_money").focus();
                return false;
            }
        }else{
            alert("轉帳費用不為數值，請重新輸入!!");
            settab("#case");
            $("#nfy_oth_money").focus();
            return false;
        }

        if($("#tfy_oth_code").val()!=""){
            if($("#nfy_oth_money").val()=="0"){
                alert("有轉帳單位，無轉帳金額，請檢查!!");
                settab("#case");
                $("#nfy_oth_money").focus();
                return false;
            }
        }

        //*******客戶期限與承辦期限控制
        if($("#dfy_cust_date").val()!=""){
            if ($.isDate($("#dfy_cust_date").val())&&$.isDate($("#dfy_pr_date").val())){
                if(Date.parse($("#dfy_cust_date").val())<Date.parse($("#dfy_pr_date").val())){
                    $("#dfy_pr_date").val($("#dfy_cust_date").val());
                }
            }else{
                if ($("#dfy_cust_date").val()!=""&&!$.isDate($("#dfy_cust_date").val())){
                    alert("客戶期限日期格式錯誤，請重新輸入!!");
                    settab("#case");
                    $("#dfy_cust_date").focus();
                    return false;
                }
                if ($("#dfy_pr_date").val()!=""&&!$.isDate($("#dfy_pr_date").val())){
                    alert("承辦期限日期格式錯誤，請重新輸入!!");
                    settab("#case");
                    $("#dfy_pr_date").focus();
                    return false;
                }
            }
        }

        //*****法定期限控制2011/9/26新增
        if($("#dfy_last_date").val()!=""){
            if (!$.isDate($("#dfy_last_date").val())){
                alert("法定期限日期格式錯誤，請重新輸入!!");
                settab("#case");
                $("#dfy_last_date").focus();
                return false;
            }
            if($("#tfy_case_stat").val()=="OO"||$("#spe_ctrl3").val()=="N"){
                var msg="提醒您！在此輸入法定期限，系統不會自動管制或檢核程序管制法定期限是否一致，是否確定輸入？";
                if(confirm(msg)){
                    alert("請自行通知程序於客收時加管此法定期限！");
                }else{
                    $("#dfy_last_date").val("");
                }
            }
        }

        //*****契約號碼控制
        var cont_type=$("input[name='Contract_no_Type']:checked").val();
        $("#tfy_contract_type").val(cont_type);
        if(cont_type=="A"||cont_type=="B"||cont_type=="C")//後續案無契約書/特案簽報/其他契約書無編號/特案簽報
            $("#tfy_Contract_no").val(cont_type);
        else if(cont_type=="M")//總契約書
            $("#tfy_Contract_no").val($("#Mcontract_no").val());
        else if(cont_type=="N"){//一般契約書
            if($("#tfy_Contract_no").val()!=""){
                if(!IsNumeric($("#tfy_Contract_no").val())){
                    alert("契約號碼請輸入數值!!");
                    settab("#case");
                    $("#tfy_Contract_no").focus();
                    return false;
                }
            }
        }

        //***契約書種類與對應文件種類檢查
        if($("#tfy_contract_flag").prop("checked")==false){
            if (check_doctype("T",$("#tfy_contract_type").val(),"B")==true){
                settab("#case");
                return false;
            }
        }else{
            if($("#tfy_contract_remark").val()==""){
                alert("契約書相關文件後補，需填寫尚缺文件說明！");
                settab("#case");
                $("#tfy_contract_remark").focus();
                return false;
            }
        }
        //***交辦內容
        //大陸案請款註記檢查.請款註記:大陸進口案
        if($("#tfz1_seq1").val()=="M"&&$("#tfy_Ar_mark").val()!="X"){
            alert("本案件為大陸案, 請款註記請設定為大陸進口案!!");
            settab("#case");
            $("#tfy_Ar_mark").focus(); 
            return false;
        }else if($("#tfz1_seq1").val()!="M"&&$("#tfy_Ar_mark").val()=="X"){
            alert("請款註記設定為大陸進口案，案件編號副碼請設定為M_大陸案 !!");
            settab("#tran");
            $("#tfz1_seq1").focus();
            return false;
        }
        //商標名稱檢查
        if($("#tfz1_Appl_name").val()==""){
            alert("需填寫商標名稱！");
            settab("#tran");
            $("#tfz1_Appl_name").focus();
            return false;
        }
        //2014/4/22增加檢查是否為雙邊代理查照對象,案件名稱
        if (check_CustWatch("appl_name",$("#tfz1_Appl_name").val())==true){
            settab("#tran");
            $("#tfz1_Appl_name").focus();
            return false;
        }
        //檢查備註,有選擇radio則須輸入內容
        var z = $('input[name=ttz1_RCode]:checked').val();
        if(z!== undefined&&$("#ttz1_"+z).val()==""){
            alert("請確認備註是否錯誤!");
            settab("#tran");
            return false;
        }
        //出名代理人檢查
        var apclass_flag="N";
        for (var capnum=1;capnum<=CInt($("#apnum").val());capnum++ ){
            if($("#apclass_" + capnum).val().Left(1)=="C"){
                //申請人為外國人則為涉外案
                apclass_flag="C";
            }
        }
        if(apclass_flag=="C"){
            //2015/10/21修改抓取cust_code.code_type=Tagt_no and mark=C及用function放置於sub/client_chk_agtno.vbs
            if (check_agtno("C",$("#tfz1_agt_no").val())==true){
                settab("#tran");
                $("#tfz1_agt_no").focus();
                return false;
            }
        }else{
            var pagt_no = $("#tfy_Arcase option:selected").attr("v2");//案性預設出名代理人
            if(pagt_no==""){
                //2015/10/21因應104年度出名代理人修改並改抓取cust_code.code_type=Tagt_no and mark=N預設出名代理人
                pagt_no=get_tagtno("N").no;
            }

            if($("#tfz1_agt_no").val().trim()!=pagt_no.trim()){
                if(!confirm("出名代理人與案性預設出名代理人不同，是否確定交辦？")){
                    settab("#tran");
                    $("#tfz1_agt_no").focus();
                    return false;
                }
            }
        }


        //*****商品類別檢查
        if($("#tabbr1").length>0){//有載入才要檢查
            var inputCount=0;
            for(var j=1;j<=CInt($("#num1").val());j++){
                if($("#good_name1_"+j).val()!=""&&$("#class1_"+j).val()==""){
                    //有輸入商品名稱,但沒輸入類別
                    alert("請輸入類別!");
                    settab("#tran");
                    $("#class1_"+j).focus();
                    return false;
                }

                if(br_form.checkclass(j)==false){//檢查類別範圍0~45
                    $("#class1_"+j).focus();
                    return false;
                }
                if($("#class1_"+j).val()!=""){
                    inputCount++;//實際有輸入才要+
                }
            }
            $("#ctrlcount1").val(inputCount==0?"":inputCount);

            if(CInt($("#tfz1_class_count").val())!=CInt($("#num1").val())){
                var answer="指定使用商品類別項目(共 "+CInt($("#tfz1_class_count").val())+" 類)與輸入指定使用商品(共 "+CInt($("#num1").val())+" 類)不符，\n是否確定指定使用商品共 "+CInt($("#num1").val())+" 類？";
                if(answer){
                    $("#tfz1_class_count").val($("#num1").val());
                }else{
                    settab("#tran");
                    $("#tfz1_class_count").focus();
                    return false;
                }
            }
        }

        if (code3=="9"||code3=="A"||code3=="B"||code3=="C"||code3=="D"||code3=="E"||code3=="F"||code3=="G"){
            $("#tfz1_class").val("");
            $("#tfz1_class_count").val("");
            $("input[name='tfz1_class_type']").prop("checked",false);
        }

        //檢查指定類別有無重覆
        var objClass = {};
        for (var r = 1; r <= CInt($("#num1").val()); r++) {
            var lineTa = $("#class1_" + r).val();
            if (lineTa != "" && objClass[lineTa]) {
                alert("商品類別重覆,請重新輸入!!!");
                $("#class1_" + r).focus();
                return false;
            } else {
                objClass[lineTa] = { flag: true, idx: r };
            }
        }

        //***表彰內容
        if($("#tf91_good_name").length>0) 
            $("#tfz1_good_name").val($("#tf91_good_name").val());
        //***證明內容
        if($("#tfd1_good_name").length>0) 
            $("#tfz1_good_name").val($("#tfd1_good_name").val());

        //****請款註記	
        if($("#tfz1_seq1").val()=="M"){
            $("#tfy_ar_code").val("M");
        }else if($("#nfy_service").val()==0&&$("#nfy_fees").val()==0&&$("#nfy_oth_money").val()==0&&$("#tfy_Ar_mark").val()=="N"){
            $("#tfy_ar_code").val("X");
        }else{
            $("#tfy_ar_code").val("N");
        }

        //****總計案性數
        var nfy_tot_case=0;
        if(!IsEmpty($("#tfy_Arcase").val())){
            nfy_tot_case+=1;
        }
        for (var r = 1; r <= CInt($("#TaCount").val()); r++) {
            if(!IsEmpty($("#nfyi_item_Arcase_"+r).val())){
                nfy_tot_case+=1;
            }
        }
        $("#nfy_tot_case").val(nfy_tot_case);

        //****當無收費標準時，把值清空
        if (reg.anfees.value == "N"){
            $("#nfy_Discount").val("");
            $("#tfy_dicount_remark").val("");//2016/5/30增加折扣理由
        }
        $("#tfy_case_stat").val("NN");//新案
        $("#submittask").val("A");

        $("select,textarea,input,span").unlock();
        $(".bsubmit").lock(!$("#chkTest").prop("checked"));

        var formData = new FormData($('#reg')[0]);
        $.ajax({
            url:'<%=HTProgPrefix%>AddA11_Update.aspx',
            type : "POST",
            data : formData,
            contentType: false,
            cache: false,
            processData: false,
            beforeSend:function(xhr){
                $("#dialog").html("<div align='center'><h1>存檔中...</h1></div>");
                $("#dialog").dialog({ title: '存檔訊息', modal: true,maxHeight: 500,width: 800 });
            },
            //success: function (data) { main.onSuccess(data); },
            //error: function (xhr, status, errMsg) { main.onError(xhr, status, errMsg); },
            complete: function (xhr,status) { main.onComplete(xhr,status); }
        });

        //reg.action = "<%=HTProgPrefix%>AddA11_Update.aspx";
        //if($("#chkTest").prop("checked"))
        //    reg.target = "ActFrame";
        //else
        //    reg.target = "_self";
        //reg.submit();
    }

    //main.onSuccess=function(data){
    //    $("#dialog").html(data);
    //    $("#dialog").dialog({ title: '存檔訊息', modal: true,maxHeight: 500,width: 800 });
    //}
    //
    //main.onError=function(xhr, status, errMsg){
    //    $("#dialog").html(xhr.responseText);
    //    $("#dialog").dialog({ title: '存檔訊息', modal: true,maxHeight: 500,width: 800 });
    //}

    main.onComplete=function(xhr, status, errMsg){
        $("#dialog").html(xhr.responseText);
        $("#dialog").dialog({ title: '存檔訊息', modal: true,maxHeight: 500,width: 800 });
    }

</script>
