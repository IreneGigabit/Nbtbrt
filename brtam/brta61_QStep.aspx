<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Data"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>
<%@ Import Namespace = "System.Linq"%>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>
<%@ Register Src="~/commonForm/brta211form.ascx" TagPrefix="uc1" TagName="brta211form" %>
<%@ Register Src="~/commonForm/brt15form.ascx" TagPrefix="uc1" TagName="brt15form" %>
<%@ Register Src="~/commonForm/brt511form.ascx" TagPrefix="uc1" TagName="brt511form" %>
<%@ Register Src="~/commonForm/brta311form.ascx" TagPrefix="uc1" TagName="brta311form" %>
<%@ Register Src="~/commonForm/brta321form.ascx" TagPrefix="uc1" TagName="brta321form" %>
<%@ Register Src="~/commonForm/Brta212form.ascx" TagPrefix="uc1" TagName="Brta212form" %>
<%@ Register Src="~/commonForm/brta34form.ascx" TagPrefix="uc1" TagName="brta34form" %>

<script runat="server">
    protected string HTProgCap = "國內案件進度查詢作業";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = HttpContext.Current.Request["prgid"] ?? "";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";
    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";
    protected string FormName = "";
    
    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected Dictionary<string, string> Lock = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    protected Dictionary<string, string> Hide = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);

    protected string SQL = "";
    protected object objResult = null;

    protected string HTProgCap_subtitle = "";
    protected string submitTask = "";
    protected string json = "";
    protected string rs_no = "";
    protected string seq = "";
    protected string seq1 = "";
    protected string cgrs = "";
    protected string cg = "";
    protected string rs = "";

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

        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");
        submitTask = ReqVal.TryGet("submittask").ToUpper();

        conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
        if (ReqVal.TryGet("type") == "brtran") {
            conn = new DBHelper(Conn.brp(Request["branch"])).Debug(Request["chkTest"] == "TEST");
            HTProgCap_subtitle = "轉案單位案件資料";
        }
        cnn = new DBHelper(Conn.Sysctrl).Debug(Request["chkTest"] == "TEST");

        json = (Request["json"] ?? "").Trim().ToUpper();
        rs_no = ReqVal.TryGet("rs_no");
        seq = ReqVal.TryGet("seq");
        seq1 = ReqVal.TryGet("seq1");
        cgrs = ReqVal.TryGet("cgrs");
        cg = ReqVal.TryGet("cgrs").Left(1);
        rs = ReqVal.TryGet("cgrs").Right(1);

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
        if (submitTask == "Q" || submitTask == "D") {
            Lock["QLock"] = "Lock";
            Lock["Qdisabled"] = "Lock";
            Lock["Qdisabled_opt"] = "Lock";
        }

        if (submitTask == "A") HTProgCap += "-<font color=blue>新增</font>";
        if (submitTask == "U") HTProgCap += "-<font color=blue>修改</font>";
        if (submitTask == "Q") HTProgCap += "-<font color=blue>" + HTProgCap_subtitle + "查詢</font>";
        if (submitTask == "D") HTProgCap += "-<font color=blue>刪除</font>";

        StrFormBtnTop += "<a class=\"imgCls\" href=\"javascript:void(0);\" >[關閉視窗]</a>\n";

        if (submitTask != "Q") {
            if ((HTProgRight & 4) > 0 || (HTProgRight & 8) > 0 || (HTProgRight & 16) > 0 || (HTProgRight & 64) > 0) {
                if (((HTProgRight & 4) > 0 && submitTask == "A") || ((HTProgRight & 8) > 0 && submitTask == "U") || ((HTProgRight & 64) > 0 && submitTask == "U")) {
                    StrFormBtn += "<input type=button id='button1' value='存　檔' class='cbutton bsubmit' onClick='formAddSubmit()'>\n";
                }
                if (((HTProgRight & 16) > 0 && submitTask == "D")) {
                    StrFormBtn += "<input type=button id='button1' value='刪　除' class='cbutton bsubmit' onClick='formDelSubmit()'>\n";
                }
                StrFormBtn += "<input type=button value='重　填' class='cbutton' onclick='this_init()'>\n";
            }
        }
    }

    //將共用參數傳給子控制項
    private void ChildBind() {
        brta211form.Lock = new Dictionary<string, string>(Lock);//官收欄位畫面
        brt15form.Lock = new Dictionary<string, string>(Lock);//後續交辦紀錄欄位畫面
        brt511form.Lock = new Dictionary<string, string>(Lock);//客收欄位畫面
        brta311form.Lock = new Dictionary<string, string>(Lock);//官發欄位畫面
        brta321form.Lock = new Dictionary<string, string>(Lock);//客發欄位畫面
        brta34form.Lock = new Dictionary<string, string>(Lock);//本發欄位畫面
        Brta212form.Lock = new Dictionary<string, string>(Lock);//管制欄位畫面
    }
</script>
<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title><%=HTProgCap%></title>
    <uc1:head_inc_form runat="server" ID="head_inc_form" />
</head>
<script language="javascript" type="text/javascript">
    var main = {};
    main.prgid = "<%#prgid%>";
    main.right = <%#HTProgRight%>;
    main.submittask = "<%#submitTask%>";
    jMain={};
</script>

<body>
<table cellspacing="1" cellpadding="0" width="98%" border="0">
    <tr>
        <td class="text9" nowrap="nowrap">&nbsp;【<%=HTProgCode%><%=HTProgCap%>】
		案件編號：<span id="span_fseq"></span>
        &nbsp;&nbsp;<span id="span_rs_no"><font color=blue><%=(rs=="R"?"收文":"發文")%></font>序號：<%=rs_no%></span>
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
    <INPUT TYPE="hidden" id="prgid" name="prgid" value="<%=prgid%>">
    <INPUT TYPE="hidden" id="submittask" name=submittask value="<%=submitTask%>">
    <INPUT TYPE="hidden" id="seq" name=seq value="<%=seq%>">
    <INPUT TYPE="hidden" id="seq1" name=seq1 value="<%=seq1%>">
    <div style="width:98%;text-align:center">
        <%if(cgrs=="GR"){%>
            <uc1:brta211form runat="server" ID="brta211form" /><!--官收欄位畫面-->
            <uc1:brt15form runat="server" ID="brt15form" /><!--後續交辦紀錄欄位畫面--> 
        <%}else if(cgrs=="CR"){%>
            <uc1:brt511form runat="server" ID="brt511form" /><!--客收欄位畫面-->
        <%}else if(cgrs=="GS"){%>
            <uc1:brta311form runat="server" ID="brta311form" /><!--官發欄位畫面-->
        <%}else if(cgrs=="CS"){%>
            <uc1:brta321form runat="server" ID="brta321form" /><!--客發欄位畫面-->
        <%}else if(cgrs=="ZS"){%>
            <uc1:brta34form runat="server" ID="brta34form" /><!--本發欄位畫面-->
        <%}%>
        <uc1:Brta212form runat="server" ID="Brta212form" /><!--管制欄位畫面-->
     </div>

    <br>
    <%#DebugStr%>
</form>

<table border="0" width="98%" cellspacing="0" cellpadding="0">
<tr>
    <td width="100%" align="center">
        <%#StrFormBtn%>
    </td>
</tr>
</table>
<br />
<table border="0" width="98%" cellspacing="0" cellpadding="0">
<tr class="FormName"><td><div align="left" style="color:blue"><%#FormName%></div></td></tr>
</table>

<div id="dialog"></div>

<iframe id="ActFrame" name="ActFrame" src="about:blank" width="100%" height="300" style="display:none"></iframe>
</body>
</html>

<script language="javascript" type="text/javascript">
    $(function () {
        if (window.parent.tt !== undefined) {
            window.parent.tt.rows = "0%,100%";
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

    function this_init() {
        //取得收文資料
        $.ajax({
            type: "get",
            url: getRootPath() + "/ajax/_vstep_dmt.aspx?<%#Request.QueryString%>",
            async: false,
            cache: false,
            success: function (json) {
                toastr.info("<a href='" + this.url + "' target='_new'>Debug！<BR><b><u>(點此顯示詳細訊息)</u></b></a>");
                jMain = $.parseJSON(json);
            },
            error: function (xhr) {
                $("#dialog").html("<a href='" + this.url + "' target='_new'>案件資料載入失敗！<u>(點此顯示詳細訊息)</u></a><hr>" + xhr.responseText);
                $("#dialog").dialog({ title: '案件資料載入失敗！', modal: true, maxHeight: 500, width: "90%" });
            }
        });

        //畫面準備
        if (typeof brta211form !== "undefined") brta211form.init();//官收欄位綁定
        if (typeof brt15form !== "undefined") brt15form.init();//後續交辦紀錄/自行客戶報導欄位綁定
        if (typeof brt511form !== "undefined") brt511form.init();//客收欄位綁定
        if (typeof brta311form !== "undefined") brta311form.init();//官發資料/交辦明細欄位綁定
        if (typeof brta321form !== "undefined") brta321form.init();//客發欄位綁定
        if (typeof brta34form !== "undefined") brta34form.init();//本發文資料/對應客收交辦
        brta212form.init();
        //-----------------
        $("input.dateField").datepick();
        main.bind();//資料綁定


        $(".Lock").lock();
        $(".Hide").hide();
    }
    
    main.bind = function () {
        $("#span_fseq").html(jMain.step_data.fseq);

        if (typeof brta211form !== "undefined") brta211form.bind(jMain.step_data,jMain.mg_attach);//官收欄位綁定
        if (typeof brt15form !== "undefined") brt15form.bind(jMain.step_data,jMain.gr_attach);//後續交辦紀錄/自行客戶報導欄位綁定
        if (typeof brt511form !== "undefined") brt511form.bind(jMain.step_data);//客收欄位綁定
        if (typeof brta311form !== "undefined") brta311form.bind(jMain.step_data,jMain.fees);//官發資料/交辦明細欄位綁定
        if (typeof brta321form !== "undefined") brta321form.bind(jMain.step_data);//客發欄位綁定
        if (typeof brta34form !== "undefined") brta34form.bind(jMain.step_data,jMain.cr_case);//本發文資料/對應客收交辦
        brta212form.bind(jMain.step_data,jMain.ctrl_data);//管制資料

        if($("#cgrs").val()=="CR"){
            if(jMain.step_data.opt_stat!=""){
                $("#show_optstat,#sp_optstat").show();//爭救案交辦
            }
        }

        if($("#cgrs").val()=="GR"){
            $("#tr_csmail_date").show();//客函寄出日期
        }
    }
</script>

