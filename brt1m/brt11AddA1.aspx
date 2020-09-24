<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Register Src="~/commonForm/cust_form.ascx" TagPrefix="uc1" TagName="cust_form" %>
<%@ Register Src="~/commonForm/attent_form.ascx" TagPrefix="uc1" TagName="attent_form" %>
<%@ Register Src="~/commonForm/apcust_form.ascx" TagPrefix="uc1" TagName="apcust_form" %>
<%@ Register Src="~/commonForm/dmt/case_form.ascx" TagPrefix="uc1" TagName="case_form" %>
<%@ Register Src="~/commonForm/dmt_upload_Form.ascx" TagPrefix="uc1" TagName="dmt_upload_Form" %>
<%@ Register Src="~/commonForm/dmt/br_A1_form.ascx" TagPrefix="uc1" TagName="br_A1_form" %>

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
    protected string case_stat = "";

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");
        submitTask = (Request["submittask"] ?? "").Trim();
        ar_form = (Request["ar_form"] ?? "").Trim();
        prt_code = (Request["prt_code"] ?? "").Trim();
        case_stat = (Request["case_stat"] ?? "").Trim();
        
        Token myToken = new Token(HTProgCode);
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
        formFunction = "add";

        if (formFunction == "edit") {
            if ((HTProgRight & 8) > 0) {
                if (prgid == "brt51") {//客收確認
                    StrFormBtn += "<input type=button value ='資料確認無誤' class='cbutton' onclick='formModSubmit()'>\n";
                    StrFormBtn += "<input type=button value ='資料有誤退回營洽' class='cbutton' onclick='formModSubmit2()'>\n";
                } else {
                    StrFormBtn += "<input type=button value ='編修存檔' class='cbutton' onclick='formModSubmit()'>\n";
                }
            }

            StrFormBtn += "<input type=button value ='重　填' class='cbutton' onclick='this_init()'>\n";
        } else if (formFunction == "add") {
            if ((HTProgRight & 4) > 0) {
                StrFormBtn += "<input type=button value ='新增存檔' class='cbutton' onclick='formAddSubmit()'>\n";
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
        br_A1_form.Lock = Lock;
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
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/client_agtno.js")%>"></script><!--檢查輸入出名代理人是否與預設出名代理人相同-->
<!--include virtual="~\js\client_custwatch.js" --><!--檢查是否為雙邊代理查照對象-->
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
    <INPUT TYPE="text" id=add_arcase name=add_arcase value="">
    <INPUT TYPE="text" id=tfy_case_stat name=tfy_case_stat value="<%=case_stat%>">
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
                <uc1:br_A1_form runat="server" ID="br_A1_form" />
            </div>
            <div class="tabCont" id="#upload">
                <uc1:dmt_upload_Form runat="server" ID="dmt_upload_Form" />
            </div>
        </td>
    </tr>
    </table>
    <br />
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
    main.prgid = "<%#prgid%>";
    main.right = <%#HTProgRight%>;
    main.formFunction = "<%#formFunction%>";
    //main.ar_form = "<%#ar_form%>";
    //main.cust_area = "<%#ReqVal.TryGet("cust_area")%>";
    //main.cust_seq = "<%#ReqVal.TryGet("cust_seq")%>";
    //main.in_no = "<%#ReqVal.TryGet("in_no")%>";
    //main.in_no = "20191230001";
    jMain = {};

    function this_init() {
        //取得交辦資料
        $.ajax({
            type: "get",
            url: getRootPath() + "/ajax/_case_dmt.aspx?prgid="+main.prgid+"&right="+main.right+"&formfunction="+main.formFunction+"&submittask=" + $("#submittask").val() + 
                "&cust_area=<%#ReqVal.TryGet("cust_area")%>&cust_seq=<%#ReqVal.TryGet("cust_seq")%>&in_no=<%#ReqVal.TryGet("in_no")%>",
            async: false,
            cache: false,
            success: function (json) {
                if ($("#chkTest").prop("checked")) toastr.info("<a href='" + this.url + "' target='_new'>Debug(_case_dmt)！<BR><b><u>(點此顯示詳細訊息)</u></b></a>");
                jMain = $.parseJSON(json);
            },
            error: function (xhr) { 
                //$("#dialog").html(xhr.responseText);
                //$("#dialog").dialog({ width: 600 });
                toastr.error("<a href='" + this.url + "' target='_new'>案件資料載入失敗！<BR><b><u>(點此顯示詳細訊息)</u></b></a>"); }
        });

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

    function this_bind(){
        if(jMain.case_main.length==0){
            //無交辦資料則帶基本設定
            //客戶
            //$("#F_cust_area").val(jMain.case_main[0].cust_area);
            //$("#F_cust_seq").val(jMain.case_main[0].cust_seq);
            $("#F_cust_area").val(jMain.cust[0].cust_area);
            $("#F_cust_seq").val(jMain.cust[0].cust_seq);
            $("#btncust_seq").click();
            //聯絡人
            //$("#tfy_att_sql").val(jMain.case_main[0].att_sql);
            $("#tfy_att_sql").val(jMain.cust[0].att_sql);
            attent_form.getatt(jMain.cust[0].cust_area, jMain.cust[0].cust_seq, jMain.cust[0].att_sql);
            //申請人
            apcust_form.getapp(jMain.cust[0].apcust_no, "");
            //收費與接洽事項
            //　洽案營洽
            $("#F_tscode").val(jMain.br_in_scode);
            $("#F_tscode").val(jMain.br_in_scname);
            //　案件主檔請款註記
            $("#tfy_Ar_mark").val("N");
            $("#dfy_cust_date").val("");
            $("#dfy_pr_date").val(new Date().addDays(15).format("yyyy/M/d"));
            $("#nfy_tot_case").val("0");
            $("#nfy_oth_money").val("0");
            $("#tfz1_seq1").val("_");
            $("#showseq1").hide();
            //交辦內容
            //　類別種類
            $("#tfz1_class_typeI").prop("checked",true);
        }else{

        }
    }
    
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
                if(fDataLen($("#ap_cname1_"+tapnum).val(),44,"申請人名稱(中)")==""){
                    settab("#apcust");
                    $("#ap_cname1_"+tapnum).focus();
                    return false;
                }
            }
            if($("#ap_cname2_"+tapnum).val()!=""){
                if(fDataLen($("#ap_cname2_"+tapnum).val(),44,"申請人名稱(中)")==""){
                    settab("#apcust");
                    $("#ap_cname2_"+tapnum).focus();
                    return false;
                }
            }
            if($("#ap_ename1_"+tapnum).val()!=""){
                if(fDataLen($("#ap_ename1_"+tapnum).val(),100,"申請人名稱(英)")==""){
                    settab("#apcust");
                    $("#ap_ename1_"+tapnum).focus();
                    return false;
                }
            }
            if($("#ap_ename2_"+tapnum).val()!=""){
                if(fDataLen($("#ap_ename2_"+tapnum).val(),100,"申請人名稱(英)")==""){
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
            $("#tfy_Ar_mark"+q).focus();
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
    }

    alert(df_tagt.get_gagtno('C').name);
</script>
