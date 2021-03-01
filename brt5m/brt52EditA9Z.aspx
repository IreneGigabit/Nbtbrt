<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Register Src="~/brt5m/brtform/brt52cust_form.ascx" TagPrefix="uc1" TagName="cust_form" %>
<%@ Register Src="~/brt5m/brtform/brt52attent_form.ascx" TagPrefix="uc1" TagName="attent_form" %>
<%@ Register Src="~/brt5m/brtform/brt52apcust_form.ascx" TagPrefix="uc1" TagName="apcust_form" %>
<%@ Register Src="~/brt5m/brtform/brt52dmt_case_form.ascx" TagPrefix="uc1" TagName="dmt_case_form" %>
<%@ Register Src="~/brt5m/brtform/brt52dmt_Form.ascx" TagPrefix="uc1" TagName="dmt_Form" %>
<%@ Register Src="~/commonForm/dmt_upload_Form.ascx" TagPrefix="uc1" TagName="dmt_upload_Form" %>
<%@ Register Src="~/brt5m/Brt52FormA9Z.ascx" TagPrefix="uc1" TagName="Brt52FormA9Z" %>


<script runat="server">
    protected string HTProgCap = HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "brt52";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";
    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";
    protected string formFunction = "";

    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected Dictionary<string, string> Lock = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    protected Dictionary<string, string> Hide = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    
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
        if ((HTProgRight & 8) > 0 || (HTProgRight & 16) > 0) {
            StrFormBtnTop += "<a href=\"" + Page.ResolveUrl("~/cust/cust11_mod.aspx") + "?cust_area=" + Request["cust_area"] + "&cust_seq=" + Request["cust_seq"] + "&hRight=4&attmodify=A&gs_dept=T\" target=\"Eblank\">[聯絡人新增]</a>\n";
            StrFormBtnTop += "<a href=\"" + Page.ResolveUrl("~/cust/cust13.aspx") + "\" target=\"Eblank\">[申請人新增]</a>\n";
            if ((Request["cust_seq"] ?? "") != "") {
                StrFormBtnTop += "<a href=\"" + Page.ResolveUrl("~/brt1m/brt1mFrame.aspx") + "?cust_area=" + Request["cust_area"] + "&cust_seq=" + Request["cust_seq"] + "\" target=\"Eblank\">[案件查詢]</a>\n";
            }
            if ((Request["homelist"] ?? "") != "homelist") {
                StrFormBtnTop += "<a class=\"imgCls\" href=\"javascript:void(0);\" >[關閉視窗]</a>\n";
            }
        }

        //申請人欄位畫面
        if (ar_form == "A6") {//變更
            apcustHolder.Controls.Add(LoadControl("~/brt5m/brtform/brt52apcust_FC_RE_form.ascx"));
            apcustHolder.Controls.Add(LoadControl("~/brt5m/brtform/brt52apcust_FC_RE1_form.ascx"));
        }

        if (formFunction == "Edit") {
            if ((HTProgRight & 8) > 0) {
                StrFormBtn += "<input type=button value ='編修交辦資料存檔' class='cbutton bsubmit' onclick='formModSubmit(1)'>\n";//formModSubmit(1)
                StrFormBtn += "<input type=button value ='編修交辦暨案件主檔資料存檔' class='c1button bsubmit' onclick='formModSubmit(2)'>\n";//formModSubmit(2)
            }
            StrFormBtn += "<input type=button value ='重　填' class='cbutton' onclick='this_init()'>\n";
        }
    }

    //將共用參數(鎖定/隱藏)傳給子控制項
    private void ChildBind() {
        if (prgid.ToLower() == "brt52") {//交辦維護
            Lock["brt52"] = "Lock";
            Hide["brt52"] = "Hide";
        }

        if ((ReqVal.TryGet("ar_code") == "N" || ReqVal.TryGet("ar_code") == "M" || ReqVal.TryGet("ar_code") == "X")
            && (ReqVal.TryGet("ar_service") == "0" && ReqVal.TryGet("ar_fees") == "0")
            && (ReqVal.TryGet("mark") == "N" || ReqVal.TryGet("mark") == "")) {
            Hide["apcust"] = "";
            Lock["apcustC"] = "";
            Lock["apcust"] = "";
        } else {
            Hide["apcust"] = "Hide";
            Lock["apcustC"] = "Lock";
            Lock["apcust"] = "Lock";
            if ((HTProgRight & 256) > 0) {//權限C才可改
                Lock["apcustC"] = "";
            }
        }

        //案件客戶
        cust_form.Lock = Lock;
        cust_form.Hide = Hide;
        //案件聯絡人
        attent_form.Lock = Lock;
        attent_form.Hide = Hide;
        //案件申請人
        apcust_form.Lock = Lock;
        apcust_form.Hide = Hide;
        //收費與接洽事項
        dmt_case_form.Lock = Lock;
        dmt_case_form.Hide = Hide;
        dmt_case_form.formFunction = formFunction;
        dmt_case_form.HTProgRight = HTProgRight;
        //案件內容
        dmt_Form.Lock = Lock;
        dmt_Form.Hide = Hide;
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
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/util_NumberConvert.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/jquery.Snoopy.date.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/jquery.irene.form.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/client_chk.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/client_chk_agtno.js")%>"></script><!--檢查輸入出名代理人是否與預設出名代理人相同-->
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/client_chk_doctype.js")%>"></script><!--檢查契約書種類與上傳文件-->
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/client_chk_custwatch.js")%>"></script><!--檢查是否為雙邊代理查照對象-->
<script type="text/javascript" src="<%=Page.ResolveUrl("~/brt1m/Oldcase_Data.js")%>"></script><!--新舊案控制-->
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
    oMain = {};
</script>

<body>
<table cellspacing="1" cellpadding="0" width="98%" border="0">
    <tr>
        <td class="text9" nowrap="nowrap">&nbsp;【<%=HTProgCode%><%=HTProgCap%>】</td>
        <td class="FormLink" valign="top" align="right" nowrap="nowrap">
            <%#StrFormBtnTop%>
        </td>
    </tr>
    <tr>
        <td colspan="2"><hr class="style-one"/></td>
    </tr>
    <tr>
        <td colspan="2">
            <font color=blue>接洽序號：<span id="t_in_no"></span> 本所編號：<span id="t_seq"></span> 交辦單號：<span id="t_case_no"></span></font> <span style="color:darkred"" id="t_ar_curr"></span>
        </td>
    </tr>
</table>
<br>
<form id="reg" name="reg" method="post">
	<input type="hidden" id="submittask" name="submittask" value="<%=submitTask%>">
	<input type="hidden" id="prgid" name="prgid" value="<%=prgid%>">
    <INPUT TYPE="hidden" id="ar_form" name="ar_form" value="<%=ar_form%>">
    <INPUT TYPE="hidden" id=prt_code name=prt_code value="<%=prt_code%>">
    <INPUT TYPE="hidden" id=new_form name=new_form value="<%=new_form%>">
    <INPUT TYPE="hidden" id=add_arcase name=add_arcase value="">
    <input type="hidden" id="draw_attach_file" name="draw_attach_file"><!--2013/11/25商標圖檔改虛擬路徑增加-->

    <table cellspacing="1" cellpadding="0" width="98%" border="0">
    <tr>
        <td>
        <table border="0" cellspacing="0" cellpadding="0">
            <tr id="CTab">
                <td class="tab" href="#cust">案件客戶</td>
                <td class="tab" href="#attent">案件聯絡人</td>
                <td class="tab" href="#apcust">案件申請人</td>
                <td class="tab" href="#case">收費與接洽事項</td>
                <td class="tab" href="#dmt">案件主檔</td>
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
                <!--include file="../brt5m/brtform/brt52cust_form.ascx"--><!--案件客戶-->
            </div>
            <div class="tabCont" id="#attent">
                <uc1:attent_form runat="server" ID="attent_form" />
                <!--include file="../brt5m/brtform/brt52attent_form.ascx"--><!--案件聯絡人-->
            </div>
            <div class="tabCont" id="#apcust">
                <uc1:apcust_form runat="server" ID="apcust_form" />
                <!--include file="../brt5m/brtform/brt52apcust_form.ascx"--><!--案件申請人-->
                <asp:PlaceHolder ID="apcustHolder" runat="server"></asp:PlaceHolder>
            </div>
            <div class="tabCont" id="#case">
                <uc1:dmt_case_form runat="server" id="dmt_case_form" />
                <!--include file="../brt5m/brtform/brt52dmt_case_form.ascx"--><!--收費與接洽事項-->
            </div>
            <div class="tabCont" id="#dmt">
                <uc1:dmt_Form runat="server" id="dmt_Form" />
                <!--include file="../brt5m/brtform/brt52dmt_Form.ascx"--><!--案件主檔-->
            </div>
            <div class="tabCont" id="#tran">
                <uc1:Brt52FormA9Z runat="server" ID="Brt52FormA9Z" />
                <!--include file="../brt5m/Brt52FormA9Z.ascx"--><!--交辦內容-->
            </div>
            <div class="tabCont" id="#upload">
                <uc1:dmt_upload_Form runat="server" ID="dmt_upload_Form" />
            </div>
        </td>
    </tr>
    </table>
    <br />
	<INPUT TYPE="hidden" id=in_scode name=in_scode>
	<INPUT TYPE="hidden" id=in_no name=in_no>
    <INPUT TYPE="hidden" id=in_date name=in_date>
    <INPUT TYPE="hidden" id=tfgp_seq NAME=tfgp_seq>
    <INPUT TYPE="hidden" id=tfgp_seq1 NAME=tfgp_seq1>

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
        if(main.ar_form=="A6"){//變更
            $("#CTab td.tab[href='#dmt']").after($("#CTab td.tab[href='#apcust']"));//[案件申請人]移到[案件主檔]後面
        }else{
            $("#CTab td.tab[href='#case']").before($("#CTab td.tab[href='#apcust']"));//[案件申請人]移到[收費與接洽事項]前面
        }
        //-----------------
        //取得交辦資料
        $.ajax({
            type: "get",
            url: getRootPath() + "/ajax/_case_dmt.aspx?prgid=" + main.prgid + "&right=" + main.right + "&formfunction=" + main.formFunction + "&submittask=" + $("#submittask").val() +
                "&cust_area=" + main.cust_area + "&cust_seq=" + main.cust_seq + "&in_no=" + main.in_no + "&code_type=" + main.code_type,
            async: false,
            cache: false,
            success: function (json) {
                if ($("#chkTest").prop("checked")) toastr.info("<a href='" + this.url + "' target='_new'>Debug(_case_dmt)！<BR><b><u>(點此顯示詳細訊息)</u></b></a>");
                jMain = $.parseJSON(json);
            },
            error: function (xhr) {
                $("#dialog").html("<a href='" + this.url + "' target='_new'>案件資料載入失敗！<u>(點此顯示詳細訊息)</u></a><hr>" + xhr.responseText);
                $("#dialog").dialog({ title: '案件資料載入失敗！', modal: true, maxHeight: 500, width: "90%" });
            }
        });
        //dmt_form.new_oldcase();

        //畫面準備
        cust_form.init();//案件客戶
        attent_form.init();//案件聯絡人
        apcust_form.init();//案件申請人
        case_form.init();//收費與接洽事項
        dmt_form.init();//案件主檔
        //br_form.init();//交辦內容
        upload_form.init();//文件上傳
        settab("#case");//收費與接洽事項

        //-----------------
        $("input.dateField").datepick();
        main.bind();//資料綁定
        //br_form.bind();//交辦內容資料綁定
        $(".Lock").lock();
        $(".Hide").hide();

        if($("#submittask").val()!="Edit"){//不是編輯模式全部鎖定
            $("select,textarea,input,button").lock();
        }
    }

    //存檔
    function formModSubmit(p){
        $("#Update_dmt").val("");
        if(p==2){
            if (!confirm("是否確定編修交辦暨案件主檔資料?"))
                return false;
            $("#Update_dmt").val("dmt");//判斷是否要更新案件主檔
        }

        $.maskStart();
        var saveflag=main.savechk();
        $.maskStop();

        if(!saveflag) return false;

        $("#submittask").val("Edit");

        //$("select,textarea,input,span").unlock();
        $("input:disabled, select:disabled").unlock();
        $(".bsubmit").lock(!$("#chkTest").prop("checked"));

        var formData = new FormData($('#reg')[0]);
        $.ajax({
            url:'<%=HTProgPrefix%>EditA9Z_Update.aspx',
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

        //reg.action = "<%=HTProgPrefix%>EditA9Z_Update.aspx";
        //if($("#chkTest").prop("checked"))
        //    reg.target = "ActFrame";
        //else
        //    reg.target = "_self";
        //reg.submit();
    }
</script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/brt1m/brtform/CaseForm/Descript.js")%>"></script><!--欄位說明-->
