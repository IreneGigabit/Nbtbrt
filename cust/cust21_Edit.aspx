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
<%@ Register Src="~/commonForm/dmt_upload_Form.ascx" TagPrefix="uc1" TagName="dmt_upload_Form" %>
<%@ Register Src="~/cust/impForm/cust21Form.ascx" TagPrefix="uc1" TagName="cust21Form" %>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>

<!DOCTYPE html>

<script runat="server">

    protected string HTProgCap = "客戶契約書管理";
    private string HTProgCode = "cust21";
    protected string HTProgPrefix = "cust21";
    private int HTProgAcs = 1;
    private int HTProgRight = 0;

    protected string StrAddLink = "";
    protected string StrSaveBtn = "";
    protected string StrResetBtn = "";
    protected string submitTask = "";
    protected string apattach_sqlno = "";
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
        submitTask = Request["submitTask"];
        
        //if ((Request["cust_area"] ?? "") != "") cust_area = Request["cust_area"];
        if ((Request["cust_seq"] ?? "") != "") cust_seq = Request["cust_seq"]; ;
        if ((Request["apattach_sqlno"] ?? "") != "") apattach_sqlno = Request["apattach_sqlno"]; ;
            
            
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
    <input type="hidden" id="apattach_sqlno" name="apattach_sqlno" value="<%=apattach_sqlno%>" />
    <input type="hidden" id="cust_seq" name="cust_seq" value="<%=cust_seq%>" />
    <table cellspacing="1" cellpadding="0" width="98%" border="0" align="center">
    <tr>
        <td class="text9" nowrap="nowrap">&nbsp;【cust21_Edit <%#HTProgCap%>-<%=(Sys.GetSession("dept") == "P")?"專利":"商標"%>】&nbsp;&nbsp;
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
                    <uc1:cust21Form runat="server" ID="cust21Form" />
                </td>
            </tr>
    </table>
    </div>
         <br />
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


        cust21form.init();
        if ($("#submitTask").val() != "A") {
            loadData();
            cust21form.CanDelAttach();
        }


        if ($("#submitTask").val() == "A") {
            $("#ref_Add_button").click();
        }

        if ($("#submitTask").val() == "Q") {
            cust21form.Setcust211formReadOnly();
            cust21form.SetReadOnly();
            $("#btnattach, #btnattach_D").hide();
            $("#btnSave").hide();
            $("#btnReset").hide();
        }


        if ($("#submitTask").val() == "U") {
            if ($("#attach_name").val() != "" && $("#source_name").val() != "") {
                $("#btnattach").lock();
                $("#scust_seq_1").lock();
            }
        }
        $("input:radio[name=attach_flag]").lock();//狀態(使用中/停用)for A、U

        if ($("#submitTask").val() == "D") {
            //$("#ref_Add_button").hide();
            cust21form.Setcust211formReadOnly();
            cust21form.SetReadOnly();
            $("#btnattach, #btnattach_D").hide();
            $("input[name=attach_flag][value='E']").prop("checked", true);
            $("#span_stop_remark").show();
        }

    });

    function this_init() {
        if (window.parent.tt !== undefined) {
            if ($("#submitTask").val() == "A") {
                window.parent.tt.rows = "0%,100%";
                $("input[name=sign_flag][value='S']").prop('checked', true);
                $("input[name=attach_flag][value='U']").prop('checked', true);
                $("#attach_doc_type").val("A001");
                $("#attach_desc").val("總契約書");
            }
            else {
                window.parent.tt.rows = "30%,70%";
            }
        }
        $("input.dateField").datepick();
    }

    function GoToSearch() {
        reg.action = "cust21.aspx?prgid=cust21&submitTask=U";
        reg.target="Etop";
        //window.parent.tt.rows = "100%,0%";
        reg.submit();
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

        if (ChkSave() == false) {
            return false;
        }

        $("input:disabled, select:disabled").unlock();
        $(".bsubmit").lock(!$("#chkTest").prop("checked"));

        var formData = new FormData($('#reg')[0]);
        ajaxByForm("cust21_Update.aspx",formData)
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
                            window.parent.Etop.goSearch();

                        }
                    }
                }
            });
        });

    });//btnSave End

    function ChkSave() {
        if (chkNull("有效起間起日", $("#use_sdate"))) return false;
        if (chkNull("有效起間訖日", $("#use_edate"))) return false;
        if ($("#use_sdate").val() != "" && $.isDate($("#use_sdate").val()) == false) {
            alert("日期期間起始資料必須為日期型態!!");
            return false;
        }
        if ($("#use_edate").val() != "" && $.isDate($("#use_edate").val()) == false) {
            alert("日期期間終止資料必須為日期型態!!");
            return false;
        }
        if (chkSEDate($("#use_sdate").val(), $("#use_edate").val(), "日期範圍") == false) {
            return false;
        }

        //「有效期間」請管制迄日「起日+3年-1日」。若超過三年(1095天)，請提示：依據101年6月經營會報決議，總契約書簽約年限不宜超過三年。系統管制不予以存檔。
        var t = CDate($("#use_edate").val()).getTime() - CDate($("#use_sdate").val()).getTime();
        var days = parseInt(t / (1000 * 60 * 60 * 24));
        if (days > 1095) {
            alert("依據101年6月經營會報決議，總契約書簽約年限不宜超過三年");
            return false;
        }

        if (chkNull("單位部門", $("#dept"))) return false;
        if (chkNull("契約書編號公司別", $("#company"))) return false;
        if (chkNull("接洽人員", $("#sign_scode"))) return false;
        if (chkNull("檔案說明類型", $("#attach_doc_type"))) return false;
        if ($("#attach_name").val() == "") {
            alert("請上傳檔案!");
            return false;
        }

        var custsqlno = CInt($("#hatt_sql"));
        for (var i = 2; i <= custsqlno; i++) {
            if ($("scust_seq_" + i).val() != "" && $("refdel_flag_" + i).prop("checked") == false) {
                if ($("input[name=sign_flag][value='S']").prop("checked") == true) {
                    alert("若有多個客戶，契約書種類請勾選「多個客戶合併簽署」");
                    return false;
                }
            }
        }

        if ($("#scust_seq_1").val() == "") {
            alert("契約書簽署之客戶請最少輸入一筆 ");
            return false;
        }

    }


    function loadData() {
        //var psql = "Select replace(a.attach_path,'/brp/','/nbrp/') attach_path,a.*,";
        var psql = "Select a.*,";
        psql += "(select agent_na1 from agent where agent_no=a.agent_no and agent_no1=a.agent_no1) as agent_na, ";
        psql += "(select agcountry from agent where agent_no=a.agent_no and agent_no1=a.agent_no1) as agent_coun, ";
        psql += "(select sc_name from sysctrl.dbo.scode where scode=a.in_scode) as in_scodenm, ";
        psql += "(select sc_name from sysctrl.dbo.scode where scode=a.tran_scode) as tran_scodenm ";
        psql += "from apcust_attach a where a.apattach_sqlno='<%=apattach_sqlno%>'";


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
                if (JSONdata.length > 0) {
                    cust21form.bind(item);
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
