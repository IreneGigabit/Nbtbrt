<%@ Page Language="C#" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace = "System.Text"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.IO"%>
<%@ Import Namespace = "System.Linq"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Web.Script.Serialization"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>
<%@ Register Src="~/cust/impForm/cust13Form.ascx" TagPrefix="uc1" TagName="cust13Form" %>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>

<!DOCTYPE html>

<script runat="server">

    protected string HTProgCap = "申請人資料";
    private string HTProgCode = "cust13";
    protected string HTProgPrefix = "cust13";
    private int HTProgAcs = 1;
    private int HTProgRight = 0;

    protected string StrAddLink = "";
    protected string StrSaveBtn = "";
    protected string StrResetBtn = "";
    protected string submitTask = "";
    protected string apsqlno = "";
    
    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";
    protected string FormName = "";

    protected string prgid = HttpContext.Current.Request["prgid"];
    protected string hrefq = "";

    protected string scode = "";
    protected string ctrl_open = "";
    //protected string apcust_no = HttpContext.Current.Request["apcust_no"];
    //protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    DBHelper conn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    DBHelper cnn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    private void Page_Unload(System.Object sender, System.EventArgs e)
    {
        if (conn != null) conn.Dispose();
        if (cnn != null) cnn.Dispose();
    }

    private void Page_Load(System.Object sender, System.EventArgs e)
    {
        //ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;
        //scode = Session["scode"].ToString();
        apsqlno = Request["apsqlno"];
        
        submitTask = Request["submitTask"];
        if (submitTask == "A") HTProgCap = HTProgCap + "-<font color=blue>新增</font>";
        if (submitTask == "U") HTProgCap = HTProgCap + "-<font color=blue>維護</font>";
        if (submitTask == "Q") HTProgCap = HTProgCap + "-<font color=blue>查詢</font>";
        ctrl_open = Request["ctrl_open"];
        
        //Response.Write("HTProgCode :" + HTProgCode + "; ");
        //Response.Write("HTProgAcs : " + HTProgAcs + "; ");
        //Response.Write("HTProgRight : " + HTProgRight);
        //Response.Write("SubmitTask : " + submitTask + "; ");
        //return;

        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        

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
            //有固定的用法.class=imgCls會自動觸發關閉視窗
            StrFormBtnTop += "<a class=\"imgCls\" href=\"javascript:void(0);\" >[關閉視窗]</a>\n";
        }
        if ((HTProgRight & 2) > 0)
        {
            StrFormBtnTop += "<a href=javascript:GoToSearch()>[申請人查詢]</a>";
        }
        
        StrFormBtnTop += "<a href=http://web02/BRP/help/外國公司國籍標註表.pdf target=_blank>[外國公司國籍標註表]</a>";
        
        if (((HTProgRight & 4) > 0 && (submitTask == "A")) || ((HTProgRight & 8) > 0 && (submitTask == "U")) || 
            ((HTProgRight & 8) > 0 && (submitTask == "A" || submitTask == "U" || submitTask == "C")) || (HTProgRight & 256) > 0)
        {
            if (submitTask == "Q") { }
            else
            {
                //StrFormBtnTop += "<a href=javascript:AddProfile()>[申請人相關資料新增]</a>";
                StrSaveBtn = "<input type=\"button\" id=\"btnSave\" value =\"存　檔\" class=\"cbutton bsubmit\"  />";//****class增加bsubmit.存檔時會控制鎖定.防止連點
                StrResetBtn = "<input type=\"button\" id=\"btnReset\" value =\"重　填\" class=\"cbutton\" />";
                if (submitTask == "A")
                {
                    StrFormBtnTop = "<a href=\"cust13.aspx?prgid=cust13\">[申請人新增]</a>";
                    StrFormBtnTop += "<a href=http://web02/BRP/help/外國公司國籍標註表.pdf target=_blank>[外國公司國籍標註表]</a>";
                }
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
                    <uc1:cust13Form runat="server" ID="cust13Form" />
                </td>
            </tr>
    </table>
    </div>
    </form>
    <table border="0" width="100%" cellspacing="0" cellpadding="0">
    <tr>
        <td width="100%" align="center">
            <%#StrSaveBtn%>
            <%#StrResetBtn%>                    
        </td>
    </tr>
    </table>

</body>
</html>

<script language="javascript" type="text/javascript">
    $(function () {
        this_init();

        if ($("#submitTask").val() == "U" || $("#submitTask").val() == "Q") {
            loadData();
            SetReadOnly();
        }

        if ($("#submitTask").val() == "Q") {

            $("input[type=text]").each(function myfunction() {
                $(this).lock();
            })

            $("#CopyAddr").hide();
        }


        if ($("#submitTask").val() == "A") {
            $("#ap_country").val("T");
        }

        if ($("#submitTask").val() != "U") {
            //隱藏權限C
            for (var i = 1; i < 8; i++)
            {
                $("#tr_" + i).hide(); 
            }
        }


    });

    function this_init() {
        if (window.parent.tt !== undefined) {
            //window.parent.tt.rows = "100%,0%";

            $("#ap_POA_tran_date").lock();
            $("#ap_POAa_tran_date").lock();

            var c = <%= "'" + ctrl_open + "'"%>;
            if (c == "Y") {
                window.parent.tt.rows = "0%,100%";
            }
            
        }
        $("input.dateField").datepick();
    }

    function SetReadOnly() {
        $("#apclass").lock();
        $("#ap_country").lock();
        $("#apcust_no").lock();
        $("#ap_cname1").lock();
        $("#ap_cname2").lock();
        $("#ap_fcname").lock();
        $("#ap_lcname").lock();
        //$("#ap_lcname").attr("readonly", true);
    }

    function ChkApcustNO() {

        switch ($("#apclass").val()) {
            case "AB":
            case "AC":
            case "AD":
            case "AE":
                if (fChkDataLen2($("#apcust_no")[0], 8, "申請人編號") == "") {
                    return false;
                } ;
                break;

            case "B":
            case "CB":
                if (fChkDataLen2($("#apcust_no")[0], 10, "申請人編號") == "") {
                    return false;
                };
                break;

            case "CT":
                if (fChkDataLen2($("#apcust_no")[0], 6, "申請人編號") == "") {
                    return false;
                };
                break;
            default:
                break;
        }
    }

    function ChkCountry() {

        if ($("#apclass").val() == "B" && $("#ap_country").val() != "T") {
            alert("本國人不可選擇外國國籍!");
            return false;
        }

        if (($("#apclass").val() == "CA" || $("#apclass").val() == "CB" || $("#apclass").val() == "CT") &&
            $("#ap_country").val() == "T") {
            alert("外國人不可選擇中華民國國籍!");
            return false;
        }
    }



    function AddProfile() {
        reg.action = "cust13_2Edit.aspx?prgid=cust13_1&apsqlno=<%=apsqlno%>&submitTask=A";
        reg.target="Etop";
        reg.submit();
    }

    function GoToSearch() {
        reg.action = "cust13_1.aspx?prgid=cust13_1&submitTask=<%=submitTask%>";
        reg.target="Etop";
        //window.parent.tt.rows = "100%,0%";
        reg.submit();
    }

    //[重填]
    $("#btnReset").click(function (e) {
        reg.reset();
        this_init();
    });

    //////////////////////////////////////////////////////
    //$("#seq").blur(function (e) {
    //    chkNum1($(this),"本所編號");
    //});
    $(".dateField").blur(function (e) {
        ChkDate(this);
    });

    //點選日期種類
    $("input[name='kind_date']").click(function () {
        if ($(this).val() == "End_Date") {//結案日期
            //結案代碼：已結案
            $("input[name='qryend'][value='N']").prop("checked", true).triggerHandler("click");
        } else {
            //結案代碼：不指定
            $("input[name='qryend'][value='']").prop("checked", true).triggerHandler("click");
        }
    });

    //點選結案代碼
    $("input[name='qryend']").click(function () {
        $("#sp_endcode").hide();
        if ($(this).val() == "N") {//已結案
            $("#sp_endcode").show();
        }
    });

    //$("form#formID :input").each(function () {
    //    var input = $(this); // This is the jquery object of the input, do what you will
    //    if (input == "") { return false;}
    //});
    //[存檔]
    $("#btnSave").click(function (e) {

        if (ChkApcustNO() == false) {
            return;
        }
        if (ChkCountry() == false) {
            return;
        } 

        /*//****改用ajax,才不用處理update後導頁面
        reg.action = "cust13_Update.aspx";
        reg.submit();
        */

        $("input:disabled, select:disabled").unlock();
        $(".bsubmit").lock(!$("#chkTest").prop("checked"));

        var formData = new FormData($('#reg')[0]);
        ajaxByForm("cust13_Update.aspx",formData)
        .complete(function( xhr, status ) {
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
                            window.parent.Etop.goSearch();//重新整理
                        }
                    }
                }
            });
        });

    });

    /*//****ascx form使用的方function要放要form裡面,
    這樣不同的作業include form時才不用再寫一次同樣的function
    $("#CopyAddr").click(function (e) {
        $("#apatt_zip").val($("#ap_zip").val());
        $("#apatt_addr1").val($("#ap_addr1").val());
        $("#apatt_addr2").val($("#ap_addr2").val());
    });

    function apclass_onchange() {

        $("#apcust_no").show();
        if ($("#apclass").val() == "AA" || $("#apclass").val() == "CA") {
            $("#apcust_no").hide();
            $("#ap_cname1").focus();
        }
        if ($("#apclass").val() != "AA" || $("#apclass").val() != "CA") {
            $("#apcust_no").focus();
        }

        if ($("#apclass").val().substring(0, 1) == "B" || $("#apclass").val().substring(0, 1) == "C") {

            $("#ap_fcname").show();
            $("#ap_lcname").show();
            $("#ap_fename").show();
            $("#ap_lename").show();
        }
        else {

            $("#ap_fcname").hide();
            $("#ap_lcname").hide();
            $("#ap_fename").hide();
            $("#ap_lename").hide();
        }
    }
    */

    /*
    //****不需此function
    function CloseFrame() {
        window.parent.tt.rows = "100%,0%";
    }
    */

    function loadData() {
        var psql = "select * from apcust where apsqlno = '<%=Request["apsqlno"]%>' and apcust_no= '<%=Request["apcust_no"]%>'";

        $.ajax({
            url: "../AJAX/JsonGetSqlData.aspx?SQL=" + psql,
            type: "POST",
            async: false,
            cache: false,
            data: $("#reg").serialize(),
            success: function (json) {
                var JSONdata = $.parseJSON(json);
                var item = JSONdata[0];
                //****form的資料綁定移到form裡,這樣不同的作業使用這個form時只要把json丟進去就好
                cust13form.bind(item);
                /*
                //$.each(JSONdata, function (i, item) {
                    $("#apclass").val(item.apclass);
                    //$("#hapclass").val(item.apclass);
                    $("#ap_country").val(item.ap_country);
                    $("#ap_cname1").val(item.ap_cname1);
                    $("#ap_cname2").val(item.ap_cname2);
                    $("#ap_fcname").val(item.ap_fcname);
                    $("#ap_lcname").val(item.ap_lcname);
                    $("#ap_ename1").val(item.ap_ename1);
                    $("#ap_ename2").val(item.ap_ename2);
                    $("#ap_fename").val(item.ap_fename);
                    $("#ap_lename").val(item.ap_lename);
                    $("#ap_crep").val(item.ap_crep);
                    $("#ap_erep").val(item.ap_erep);
                    $("#ap_title").val(item.ap_title);
                    $("#ap_zip").val(item.ap_zip);
                    $("#ap_addr1").val(item.ap_addr1);
                    $("#ap_addr2").val(item.ap_addr2);
                    $("#ap_eaddr1").val(item.ap_eaddr1);
                    $("#ap_eaddr2").val(item.ap_eaddr2);
                    $("#ap_eaddr3").val(item.ap_eaddr3);
                    $("#ap_eaddr4").val(item.ap_eaddr4);
                    $("#apatt_zip").val(item.apatt_zip);
                    $("#apatt_addr1").val(item.apatt_addr1);
                    $("#apatt_addr2").val(item.apatt_addr2);
                    $("#apatt_tel0").val(item.apatt_tel0);
                    $("#apatt_tel").val(item.apatt_tel);
                    $("#apatt_tel1").val(item.apatt_tel1);
                    $("#apatt_fax").val(item.apatt_fax);
                    $("#apatt_email").val(item.apatt_email);
                    //權限C
                    $("#ap_code").val(item.ap_code);
                    //var d = new Date(item.in_date).format("yyyy/MM/dd hh:mm:ss");
                    //$("#in_date").val(d);
                    $("#in_date").val(dateReviver(item.in_date, "yyyy/MM/dd hh:mm:ss"));
                    $("#in_scode").val(item.in_scode);
                    $("#tran_date").val(dateReviver(item.tran_date, "yyyy/MM/dd hh:mm:ss"));
                    $("#tran_scode").val(item.tran_scode);
                    $("#dmp_seq").val(item.dmp_seq);
                    $("#exp_seq").val(item.exp_seq);
                    $("#dmt_seq").val(item.dmt_seq);
                    $("#ext_seq").val(item.ext_seq);
                    $("#mark").val(item.mark);
                */

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
