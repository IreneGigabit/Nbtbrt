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
    protected string cust_area = "";
    protected string cust_seq = "";
    
    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";
    protected string FormName = "";
    protected string DebugStr = "";
    
    protected string prgid = HttpContext.Current.Request["prgid"];
    protected string hrefq = "";
    protected string ctrl_open = "";
    //protected string apcust_no = HttpContext.Current.Request["apcust_no"];
    //protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    DBHelper conn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    DBHelper cnn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    protected bool HideC = true;
    
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
        apsqlno = Request["apsqlno"];
        submitTask = Request["submitTask"];
        
        if ((Request["cust_area"] ?? "") != "") cust_area = Request["cust_area"];
        if ((Request["cust_seq"] ?? "") != "") cust_seq = Request["cust_seq"]; ;

        if (cust_area == "" && cust_seq == "")
        {
            using (DBHelper conn = new DBHelper(Conn.brp(Sys.GetSession("seBranch"))).Debug(Request["chkTest"] == "TEST"))
            {
                string SQL = "select cust_area, cust_seq from custz where id_no = '" + Request["apcust_no"] + "'";
                SqlDataReader dr = conn.ExecuteReader(SQL);
                if (dr.Read())
                {
                    cust_area = dr["cust_area"].ToString();
                    cust_seq = dr["cust_seq"].ToString();
                }
            }
        }    
        
        
        if (submitTask == "A") HTProgCap = HTProgCap + "-<font color=blue>新增</font>";
        if (submitTask == "U") HTProgCap = HTProgCap + "-<font color=blue>維護</font>";
        if (submitTask == "Q") HTProgCap = HTProgCap + "-<font color=blue>查詢</font>";
        ctrl_open = Request["ctrl_open"];
        

        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        DebugStr = myToken.DebugStr;

        if (HTProgRight >= 0)
        {
            if (HTProgRight >= 256) HideC = false;
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
                StrSaveBtn = "<input type=\"button\" id=\"btnSave\" value =\"存　檔\" class=\"cbutton bsubmit\"  />";//****class增加bsubmit.存檔時會控制鎖定.防止連點
                StrResetBtn = "<input type=\"button\" id=\"btnReset\" value =\"重　填\" class=\"cbutton\" />";
                if (submitTask == "A")
                {
                    //StrFormBtnTop = "<a href=javascript:GoToSearch()>[申請人查詢]</a>";
                    //StrFormBtnTop += "<a href=http://web02/BRP/help/外國公司國籍標註表.pdf target=_blank>[外國公司國籍標註表]</a>";
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
    <input type="hidden" id="cust_area" name="cust_area" value="<%=cust_area%>" />
    <input type="hidden" id="cust_seq" name="cust_seq" value="<%=cust_seq%>" />
    <input TYPE="hidden" name="ap_modify" value="A"><!--申請人相關資料維護狀態-->
    <input type="hidden" name="tran_flag" id="tran_flag" value="<%=Request["tran_flag"]%>" />
    <input TYPE="hidden" name="databr_branch" id="databr_branch" value="<%=Request["databr_branch"]%>">
    <input TYPE="hidden" name="old_branch" id="old_branch" value="<%=Request["old_branch"]%>">
    <input TYPE="hidden" name="old_seq" value="<%=Request["old_seq"]%>">
    <input TYPE="hidden" name="old_seq1" value="<%=Request["old_seq1"]%>">
    <input TYPE="hidden" name="tablename" value="<%=Request["tablename"]%>">
    <input TYPE="hidden" name="country" value="<%=Request["country"]%>">
    <input TYPE="hidden" name="data_type" value="<%=Request["data_type"]%>">
    <input TYPE="hidden" name="qs_dept" value="<%=Request["qs_dept"]%>"><!--轉案用-->
    <input TYPE="hidden" name="save_conflict_rec" value="N"><!--利害衝突對象入檔用-->
    <table cellspacing="1" cellpadding="0" width="98%" border="0" align="center">
    <tr>
        <td class="text9" nowrap="nowrap">&nbsp;【cust13_Edit <%#HTProgCap%>】&nbsp;&nbsp;
            <span id="span_custNo" style="color:blue"><%= (cust_seq != "" && cust_seq != "0") ? "客戶編號 : " + cust_area + "-" + cust_seq : "" %> </span>
        </td>
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

        if ($("#submitTask").val() == "A")
        {
            if ($("#databr_branch").val() != "" && $("#tran_flag").val() == "B")//brta78確認轉案作業
            {
                loadData();
                cust13form.apclassChange();
            }
            else {
                $("#ap_cname1").val(<%= "'" + Request["ap_cname1"] + "'"%>);
                $("#ap_country").val("T");
                $("#span_custNo").hide();
            }
        }

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
            //隱藏權限C
            for (var i = 1; i < 8; i++)
            {
                $("#tr_" + i).hide(); 
            }
        }

        if ($("#submitTask").val() == "U" || $("#submitTask").val() == "Q") {
            //隱藏權限C，需要256權限開
            if ('<%=HideC%>' == "True") {
                for (var i = 1; i < 8; i++)
                {
                    $("#tr_" + i).hide(); 
                }
            }
        }


    });

    function this_init() {
        if (window.parent.tt !== undefined) {
            window.parent.tt.rows = "0%,100%";

            $("#ap_POA_tran_date").lock();
            $("#ap_POAa_tran_date").lock();

            var c = <%= "'" + ctrl_open + "'"%>;
            if (c == "Y") {
                //window.parent.tt.rows = "0%,100%";
                window.parent.tt.rows = "40%,60%";
            }
            
        }
        $("input.dateField").datepick();
    }

    function SetReadOnly() {
        $("#apclass, #ap_country, #apcust_no").lock();
        $("#ap_cname1, #ap_cname2, #ap_fcname, #ap_lcname").lock();
    }

    function AddProfile() {
        reg.action = "cust13_2Edit.aspx?prgid=cust13_1&apsqlno=<%=apsqlno%>&submitTask=A";
        reg.target="Etop";
        reg.submit();
    }

    function GoToSearch() {
        reg.action = "cust13_1.aspx?prgid=cust13_1&submitTask=U";
        //reg.target="Etop";
        //window.parent.tt.rows = "100%,0%";
        if(window.parent.tt === undefined){//沒有找到頁框
            reg.target="_self";
        }else{
            reg.target="Etop";
        }
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

    //[存檔]
    $("#btnSave").click(function (e) {

        if (cust13form.ChkApclass() == false) {
            return;
        }
        if (cust13form.ChkApcust_no() == false) {
            return;
        }
        if (cust13form.chkSaveData() == false) {
            return;
        }
        if (cust13form.chkCountry() == false) {
            return;
        } 

        if ($("#submitTask").val() == "A") {

            if (cust13form.ChkDataDouble() == false) {
                return;
            }
        }


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
                            var t = <%="'"+ submitTask + "'"%>;
                            if (t == "A") {//沒有List，所以重新Search
                                var arr = xhr.responseText.split(',');
                                window.parent.Etop.goSearch();
                                //window.parent.Etop.AddDone(arr[1]);//重新整理
                            }
                            else {
                                //window.parent.tt.rows="100%,0%";
                                window.parent.Etop.goSearch();//重新整理
                            }
                        }
                    }
                }
            });
        });

    });//btnSave End

    function loadData() {
        var con = "";
        if ($("#databr_branch").val() != "") {
            con = $("#databr_branch").val();
        }
        else {
            con = '<%=Sys.GetSession("seBranch")%>';
        }

        var psql = "select a.*, (select sc_name from sysctrl.dbo.scode where scode = a.in_scode) as scodename from apcust a where apsqlno = '<%=Request["apsqlno"]%>' and apcust_no= '<%=Request["apcust_no"]%>'";

        $.ajax({
            url: "../AJAX/JsonGetSqlData.aspx?SQL=" + psql + "&connbr=" + con,
            type: "POST",
            async: false,
            cache: false,
            data: $("#reg").serialize(),
            success: function (json) {
                var JSONdata = $.parseJSON(json);
                var item = JSONdata[0];
                //****form的資料綁定移到form裡,這樣不同的作業使用這個form時只要把json丟進去就好
                if (JSONdata.length > 0) {
                    cust13form.bind(item);
                }
                else {
                    window.parent.tt.rows = "100%, 0%";//cust45list & cust46list用
                }
                
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
