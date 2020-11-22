<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Register Src="~/commonForm/cust_form.ascx" TagPrefix="uc1" TagName="cust_form" %>
<%@ Register Src="~/commonForm/attent_form.ascx" TagPrefix="uc1" TagName="attent_form" %>
<%@ Register Src="~/commonForm/apcust_form.ascx" TagPrefix="uc1" TagName="apcust_form" %>
<%@ Register Src="~/commonForm/dmt/case_form.ascx" TagPrefix="uc1" TagName="case_form" %>
<%@ Register Src="~/commonForm/dmt/dmt_upload_Form.ascx" TagPrefix="uc1" TagName="dmt_upload_Form" %>
<%@ Register Src="~/brt1m/Brt11FormA11.ascx" TagPrefix="uc1" TagName="Brt11FormA11" %>

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
    protected string cust_area = "";
    protected string cust_seq = "";
    protected string in_no = "";
    protected string prt_code = "";
    protected string new_form = "";
    protected string case_stat = "";
    protected string code_type = "";
    protected string seq = "";
    protected string seq1 = "";

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");
        submitTask = (Request["submittask"] ?? "").Trim();
        ar_form = (Request["ar_form"] ?? "").Trim();
        cust_area = (Request["cust_area"] ?? "").Trim();
        cust_seq = (Request["cust_seq"] ?? "").Trim();
        in_no = (Request["in_no"] ?? "").Trim();
        prt_code = (Request["prt_code"] ?? "").Trim();
        new_form = (Request["new_form"] ?? "").Trim();
        case_stat = (Request["case_stat"] ?? "").Trim();
        code_type = (Request["code_type"] ?? "").Trim();
        seq = (Request["seq"] ?? "").Trim();
        seq1 = (Request["seq1"] ?? "").Trim();

        formFunction = (Request["formFunction"] ?? "").Trim();
        if (formFunction == "") {
            formFunction = "Edit";
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
        if ((HTProgRight & 8) > 0||(HTProgRight & 16) > 0) {
            StrFormBtnTop += "<a href=\"" + Page.ResolveUrl("~/cust/cust11_mod.aspx") + "?cust_area=" + Request["cust_area"] + "&cust_seq=" + Request["cust_seq"] + "&hRight=4&attmodify=A&gs_dept=T\" target=\"Brt11blank\">[聯絡人新增]</a>\n";
            StrFormBtnTop += "<a href=\"" + Page.ResolveUrl("~/cust/cust13.aspx") + "\" target=\"Brt11blank\">[申請人新增]</a>\n";
            if((Request["cust_seq"]??"")!=""){
                StrFormBtnTop += "<a href=\"" + Page.ResolveUrl("~/brt1m/brt1mFrame.aspx") + "?cust_area=" + Request["cust_area"] + "&cust_seq=" + Request["cust_seq"] + "\" target=\"Brt11blank\">[案件查詢]</a>\n";
            }
            if((Request["homelist"]??"")!="homelist"){
                StrFormBtnTop += "<a class=\"imgCls\" href=\"javascript:void(0);\" >[關閉視窗]</a>\n";
            }
        }

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
                StrFormBtn += "<input type=button value ='新增存檔' class='cbutton bsubmit' onclick='formModSubmit()'>\n";
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
<script language="javascript" type="text/javascript">
    var main = {};
    main.branch = "<%#Session["SeBranch"]%>";
    main.prgid = "<%#prgid%>";
    main.right = <%#HTProgRight%>;
    main.submittask = "<%#submitTask%>";
    main.formFunction = "<%#formFunction%>";
    main.ar_form = "<%#ar_form%>";
    main.cust_area = "<%#cust_area%>";
    main.cust_seq = "<%#cust_seq%>";
    main.in_no = "<%#in_no%>";
    main.code_type = "<%#code_type%>";
    main.seq = "<%#seq%>";
    main.seq1 = "<%#seq1%>";
    jMain = {};
</script>

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
    <INPUT TYPE="text" id="ar_form" name="ar_form" value="<%=ar_form%>">
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
                <uc1:Brt11FormA11 runat="server" ID="Brt11FormA11" />
                <!--include file="../brt1m/Brt11FormA11.ascx"--><!--交辦內容-->
            </div>
            <div class="tabCont" id="#upload">
                <uc1:dmt_upload_Form runat="server" ID="dmt_upload_Form" />
                <!--include file="../commonForm/dmt/dmt_upload_Form.ascx"--><!--文件上傳-->
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

<div id="dialog"></div>

<iframe id="ActFrame" name="ActFrame" src="about:blank" width="100%" height="500" style="display:none"></iframe>
</body>
</html>

<script language="javascript" type="text/javascript">
    $(function () {
        if (window.parent.tt !== undefined) {
            if($("#prgid").val()!="brt51"){
                window.parent.tt.rows = "*,2*";
            }else{
                window.parent.tt.rows = "0%,100%";
            }
        }

        this_init();
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

    function this_init() {
        //console.log("this_init");
        //-----------------
        //取得交辦資料
        $.ajax({
            type: "get",
            url: getRootPath() + "/ajax/_case_dmt.aspx?prgid=" + main.prgid + "&right=" + main.right + "&formfunction=" + main.formFunction + "&submittask=" + $("#submittask").val() +
                "&cust_area=" + main.cust_area + "&cust_seq=" + main.cust_seq + "&in_no=" + main.in_no + "&code_type=" + main.code_type,
            async: false,
            cache: false,
            success: function (json) {
                //if ($("#chkTest").prop("checked")) toastr.info("<a href='" + this.url + "' target='_new'>Debug(_case_dmt)！<BR><b><u>(點此顯示詳細訊息)</u></b></a>");
                toastr.info("<a href='" + this.url + "' target='_new'>Debug(_case_dmt)！<BR><b><u>(點此顯示詳細訊息)</u></b></a>");
                jMain = $.parseJSON(json);
            },
            error: function (xhr) {
                $("#dialog").html("<a href='" + this.url + "' target='_new'>案件資料載入失敗！<u>(點此顯示詳細訊息)</u></a><hr>" + xhr.responseText);
                $("#dialog").dialog({ title: '案件資料載入失敗！', modal: true, maxHeight: 500, width: "90%" });
            }
        });

        //畫面準備
        cust_form.init();//案件客戶
        attent_form.init();//案件聯絡人
        apcust_form.init();//案件申請人
        case_form.init();//收費與接洽事項
        //br_form.init();//交辦內容
        upload_form.init();//文件上傳
        settab("#case");//收費與接洽事項

        //-----------------
        main.bind();//資料綁定
        br_form.bind();//交辦內容資料綁定
        $("input.dateField").datepick();
        $(".Lock").lock();

        if($("#submittask").val()!="Edit"){//不是編輯模式全部鎖定
            $("select,textarea,input,span,button").lock();
        }
    }

    <!--xxinclude virtual="~\brt1m\A11_bind.js" --><!--資料綁定(main.bind)xx-->
    <!--xxinclude virtual="~\brt1m\A11_savechk.js" --><!--存檔檢查(main.savechk)xx-->
    
    //存檔
    function formModSubmit(){
        $.maskStart();
        var saveflag=main.savechk();
        $.maskStop();

        if(!saveflag) return false;

        $("#tfy_case_stat").val("NN");//新案
        $("#submittask").val("Edit");

        $("select,textarea,input,span").unlock();
        $(".bsubmit").lock(!$("#chkTest").prop("checked"));

        var formData = new FormData($('#reg')[0]);
        $.ajax({
            url:'<%=HTProgPrefix%>EditA11_Update.aspx',
            type : "POST",
            data : formData,
            contentType: false,
            cache: false,
            processData: false,
            beforeSend:function(xhr){
                $("#dialog").html("<div align='center'><h1>存檔中...</h1></div>");
                $("#dialog").dialog({ title: '存檔訊息', modal: true,maxHeight: 500,width: 800,buttons:[] });
            },
            //success: function (data, status, xhr) { main.onSuccess(data, status, xhr); },
            //error: function (xhr, status) { main.onError(xhr, status); },
            //complete: function (xhr, status) { main.onComplete(xhr, status); }
            complete: function (xhr, status) {
                $("#dialog").html(xhr.responseText);
                $("#dialog").dialog({
                    title: '存檔訊息',modal: true,maxHeight: 500,width: 800,closeOnEscape: false
                    ,buttons: {
                        確定: function() {
                            $(this).dialog("close");
                        }
                    }
                    ,close:function(event, ui){
                        if(status=="success"){
                            if(!$("#chkTest").prop("checked")){
                                window.parent.tt.rows="100%,0%";
                            }
                        }
                    }
                });
            }
        });

        //reg.action = "<%=HTProgPrefix%>EditA11_Update.aspx";
        //if($("#chkTest").prop("checked"))
        //    reg.target = "ActFrame";
        //else
        //    reg.target = "_self";
        //reg.submit();
    }
</script>
<script src="CaseForm/Descript.js"></script><!--欄位說明-->
