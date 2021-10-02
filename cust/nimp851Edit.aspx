<%@ Page Language="C#" CodePage="65001" AutoEventWireup="true"  %>
<%@ Import Namespace="System.Data" %>
<%@Import Namespace = "System.Text"%>
<%@Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.IO"%>
<%@ Import Namespace = "System.Linq"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Web.Script.Serialization"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>
<%@ Register Src="~/cust/impForm/nimp851Form.ascx" TagPrefix="uc1" TagName="nimp851Form" %>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<script runat="server">
    protected string HTProgCap = "電文內容維護作業";
    private string HTProgCode = "nimp851";
    protected string HTProgPrefix = "nimp851";
    private int HTProgAcs = 1;
    private int HTProgRight = 0;
    
    protected string StrAddLink = "";
    protected string StrSaveBtn = "";
    protected string StrResetBtn = "";
    protected string isql = "";

    protected string StrCustCodeCtrl = "";

    protected string inputStyle = "";
    protected string trStyle = "";
    protected string btnStyle = "";
    protected string submitTask = "";

    protected string prgid = HttpContext.Current.Request["prgid"];
    protected string hrefq = "";
    protected string RS_Type = "";
    protected string rs_class = "";
    protected string rs_code = "";
    protected string act_code = "";
    protected string rs_detail = "";
    protected string lang_code = "";
	protected string tf_ag = "";
	protected string tf_rs = "";
    protected string chk_flag = "";
    protected string mark = "";
    protected string tf_code = "";
    protected string ext_flag = "";
    protected string agrs = "as";

    protected string se_grpclass = "FIMP";
    protected string scode = "";
    protected string ctrl_open = "";
    
    private void Page_Load(System.Object sender, System.EventArgs e)
    {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;
        submitTask = Request["submitTask"].ToString();
        scode = Session["scode"].ToString();
        
        if (submitTask == "A") HTProgCap = HTProgCap + "-<font color=blue>新增</font>";
        if (submitTask == "U") HTProgCap = HTProgCap + "-<font color=blue>維護</font>";
        if (submitTask == "Q") HTProgCap = HTProgCap + "-<font color=blue>查詢</font>";
        if ((Request["ctrl_open"] ?? "") != "")
            ctrl_open = Request["ctrl_open"];
        
        hrefq = "&prgid=" + prgid;
            
        if ((Request["qrytf_code"] ?? "") != "")
            hrefq += "&qrytf_code=" + Request["qrytf_code"].ToString().Trim();
        if ((Request["qrytf_name"] ?? "") != "")
            hrefq += "&qrytf_name=" + Request["qrytf_name"].ToString().Trim();
        if ((Request["qrytf_class"] ?? "") != "")
            hrefq += "&qrytf_class=" + Request["qrytf_class"].ToString().Trim();
        if ((Request["qrywork_team"] ?? "") != "")
            hrefq += "&qrywork_team=" + Request["qrywork_team"].ToString().Trim();
        if ((Request["qrywork_scode"] ?? "") != "")
            hrefq += "&qrywork_scode=" + Request["qrywork_scode"].ToString().Trim();
        if ((Request["qrytf_ag"] ?? "") != "")
            hrefq += "&qrytf_ag=" + Request["qrytf_ag"].ToString().Trim();
        if ((Request["qrytf_rs"] ?? "") != "")
            hrefq += "&qrytf_rs=" + Request["qrytf_rs"].ToString().Trim();
        if ((Request["qrybeg_date"] ?? "") != "")
            hrefq += "&qrybeg_date=" + Request["qrybeg_date"].ToString().Trim();
        if ((Request["qryend_date"] ?? "") != "")
            hrefq += "&qryend_date=" + Request["qryend_date"].ToString().Trim();

        if ((Request["tf_code"] ?? "") != "")
            tf_code = Request["tf_code"];

        if ((Request["lang_code"] ?? "") != "")
            lang_code = Request["lang_code"];
        
        String isql = "";
        
        if (submitTask == "A")
        {
            //lang_code = "E";	
            tf_ag = "A";    
            tf_rs = "S";
            isql = "select cust_code From cust_code where code_type='prs_type'";
            using (DBHelper conn = new DBHelper(Session["sifdbs"].ToString()).Debug(false))
            {
                RS_Type = (string)conn.ExecuteScalar(isql);
                //預設值
                if (string.IsNullOrEmpty(RS_Type))
                    RS_Type = "P94";
            }
            
            chk_flag = "N";
            mark = "NNNNN";
        }
        else
        {
            isql = "select a.*," ;
		    isql += "(select sc_name from sysctrl.dbo.scode where scode=a.pr_scode) as pr_scodenm," ;
		    isql += "(select sc_name from sysctrl.dbo.scode where scode=a.pr_scodej) as pr_scodejnm," ;
		    isql += "(select sc_name from sysctrl.dbo.scode where scode=a.supply_scode) as supply_scodenm," ;
		    isql += "(select sc_name from sysctrl.dbo.scode where scode=a.chk_scode) as chk_scodenm," ;
		    isql += "(select sc_name from sysctrl.dbo.scode where scode=a.chk_scodej) as chk_scodejnm" ;
		    isql += " from tfcode_imp a " ;
            isql += " where a.tf_code='" + tf_code + "'";
        }

        Token myToken = new Token(HTProgCode, HTProgAcs);
        HTProgRight = myToken.CheckMe2();
        
        //Response.Write(HTProgRight);
        
        if (HTProgRight >= 0)
        {
            QueryPageLayout();
            this.DataBind();
        }

    }

    private void QueryPageLayout()
    {
        if (((HTProgRight & 4) > 0 && (submitTask == "A")) || ((HTProgRight & 8) > 0 && (submitTask == "U")) || ((HTProgRight & 8) > 0 && (submitTask == "A" || submitTask == "U" || submitTask == "C")) || (HTProgRight & 256) > 0)
        {
            StrSaveBtn = "<input type=\"button\" id=\"btnSave\" value =\"存　檔\" class=\"cbutton\" onclick=\"Save()\" />";
            StrResetBtn = "<input type=\"button\" id=\"btnReset\" value =\"重　填\" class=\"cbutton\" />";   
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
    <form id="reg" name="reg" method="post" action="" >
    <div>
        <table border="0" cellspacing="1" cellpadding="0" width="85%" align="center">
            <tr>
                <td width="80%" class="text9" nowrap="nowrap">&nbsp;【<%=HTProgPrefix%>&nbsp;<%=HTProgCap%>】</td>
                <td align="right" width="20%">
                    <a href="nimp851_Query.aspx?a=a<%=hrefq%>&lang_code=<%=lang_code%>" target="Etop">[查詢]</a>
                    <a id="re_back" onclick="re_back()">
                        <font>[關閉視窗]</font>
                    </a>
                </td>
            </tr>
            <tr>
                <td valign="top" align="right" nowrap="nowrap" colspan="2">
                    <hr color="#000080" size="1" noshade>
                </td>
            </tr>
        </table>
        <input type="hidden" id="HTProgPrefix" name="HTProgPrefix" value="<%=HTProgPrefix%>" />
        <input type="hidden" id="HTProgCode" name="HTProgCode" value="<%=HTProgCode%>" />
        <input type="hidden" id="prgid" name="prgid" value="<%=prgid%>" />
        <input type="hidden" id="submitTask" name="submitTask" value="<%=Request["submitTask"].ToString()%>" />

        <input type="hidden" id="agrs" name="agrs" value="<%=agrs%>" />
        <input type="hidden" id="ext_flag" name="ext_flag" value="<%=ext_flag%>" />
        <input type="hidden" id="RS_Type" name="RS_Type" value="<%=RS_Type%>" />
        <input type="hidden" id="rs_class" name="rs_class" value="<%=rs_class%>" />
        <input type="hidden" id="rs_code" name="rs_code" value="<%=rs_code%>" />
        <input type="hidden" id="act_code" name="act_code" value="<%=act_code%>" />
        <input type="hidden" id="hidden_rs_detail" name="hidden_rs_detail" value="<%=rs_detail%>" />
        <input type="hidden" id="hidden_mark" name="hidden_mark" value="<%=mark%>" />
        <input type="hidden" id="htf_send_way" name="htf_send_way" value="" />
        <input type="hidden" id="htf_send_way1" name="htf_send_way1" value="" />
        <input type="hidden" id="htf_send_wayA5" name="htf_send_wayA5" value="" />

        <table border="0" width="100%" cellspacing="0" cellpadding="0">
            <tr>
                <td width="100%" id="Cont" colspan="2" height="100%" valign="top">
                    <uc1:nimp851Form runat="server" ID="nimp851Form" />
                </td>
            </tr>
        </table>
        <br />
        <table border="0" width="100%" cellspacing="0" cellpadding="0">
            <tr>
                <td width="100%" align="center">
                    <%#StrSaveBtn%>
                    <%#StrResetBtn%>                    
                </td>
            </tr>
        </table>
    </div>
    </form>
</body>
</html>

<script type="text/javascript" language="javascript">

    $(function () {
        //CKEDITOR.replace('tf_content', { height: 600, width: '100%', readOnly: false });
        //CKEDITOR.replace('tf_content2',{ height: 600, width: '100%', readOnly: false });

        $("#re_back").show();

        if ("<%#lang_code%>" != "J"){
            $("#tr_head").hide();
            $("#tr_subject_title").hide();
            $("#tr_subject").hide();            
        }

        if ($("#submitTask").val() == "A") {
            if ("<%=ctrl_open%>" != "Y") 
            window.parent.tt.rows = '0%,100%';
        }
        else {
            if ("<%=ctrl_open%>" != "Y") 
            window.parent.tt.rows = '20%,80%';
            
            $("#keychk_scode").val("Y");
            $("#keychk_scodej").val("Y");
            $("#keysupply_scode").val("Y");

            loadSetting();
            if ($("#submitTask").val() == "Q") {
                $("#btnSave,#btnReset").hide();
                $("#reg").find("input,button,textarea,select").attr("disabled", "disabled");                
            }
        }        
    });

    function re_back() {
        if ("<%=ctrl_open%>" != "Y") 
        window.parent.tt.rows = '100%,0%';
    };

    function Save() {
        if ($("#submitTask").val() == "C") $("#submitTask").val("A");
        if ($("#submitTask").val() == "A") {
            if (chkNull("電文代碼", $("#tf_code")[0])) return;
            if ($("#keytf_code").val() != "Y") {
                alert("入檔前，請先按電文代碼確定按鈕檢查代碼!!!");
                return;
            }
        }

        if (chkNull("電文名稱", $("#tf_name")[0])) return;
        if (chkNull("電文名稱", $("#tf_name")[0])) return;
        if (fChkDataLen($("#tf_name"), "電文名稱") < 0) return;
        if (fChkDataLen($("#chk_scode"), "判行人員(非日)") < 0) return;

        if (trim($("#chk_scode").val()) !="A" && trim($("#chk_scode").val()) != "B" && trim($("#chk_scode").val()) != "" && trim($("#keychk_scode").val()) != "Y" ) {
            alert("入檔前，請先按判行人員(非日)確定按鈕檢查資料!!!");
            $("#chk_scode").focus();
            return;
        }
	
        if (fChkDataLen($("#chk_scodej"), "判行人員(日)") < 0) return;

        if (trim($("#chk_scodej").val()) != "A" && trim($("#chk_scodej").val()) != "B" && trim($("#chk_scodej").val()) != "" && trim($("#keychk_scodej").val()) != "Y") {
            alert("入檔前，請先按判行人員(日)確定按鈕檢查資料!!!");
            $("#chk_scodej").focus();
            return;
        }

        if (fChkDataLen($("#rs_detail"), "發文內容") < 0) return;

        //發文方式
        var isgoing = true;
        var chktf_send_way = "N";
        $("#htf_send_way").val("");
        $("input:checkbox[name=Send_Way]").each(function () {
            if ($(this).prop("checked")) {
                chktf_send_way = "Y";
                $("#htf_send_way").val($("#htf_send_way").val() + $(this).val() + ";");
                if ($(this).val() == "A2") {
                    if (isgoing)
                        if (chkNull("LETTER發文方式", $("#tf_send_way1")[0])) isgoing = false;
                }

                if ($(this).val() == "A5") {
                    if (isgoing)
                        if (chkNull("平台發文方式", $("#tf_send_way_A5")[0])){
                            isgoing = false
                        }
                }
            }

        });

        if (!isgoing)
            return;

        $("#htf_send_way1").val($("#tf_send_way1").val());
        $("#htf_send_wayA5").val($("#tf_send_way_A5").val());

        if (chkNull("收發種類", $("#tf_ag")[0])) return;
        if (chkNull("收/發文", $("#tf_rs")[0])) return;
        if (chkNull("使用起始日期", $("#beg_date")[0])) return;

        if (trim($("#beg_date").val()) != "" && trim($("#end_date").val()) != ""){
            if ((Date.parse($("#beg_date").val())).valueOf() > (Date.parse($("#end_date").val())).valueOf()) {
                alert("使用起始日不可大於使用迄止日，請重新輸入!!!");
                $("#beg_date").focus();
                return false;
            }
        }
        if (chkNull("電文提供者", $("#supply_scode")[0])) return;
        if (fChkDataLen($("#supply_scode"), "電文提供者") < 0) return;
        if (trim($("#supply_scode").val()) != "" && $("#keysupply_scode").val() != "Y") {
            alert("入檔前，請先按電文提供者確定按鈕檢查資料!!!");
            $("#supply_scode").focus();
            return;
        }

        //處理欄位table檢查
        isgoing = true;
        var len = $('#tabcode > tbody  > tr').length;
        if (len > 0) {
            var count = 0;
            $('#tabcode > tbody  > tr').each(function () {
                count += 1;

                if (chkNull("欄位說明", $("#tf_name_use_" + count)[0])) isgoing = false;
                if (isgoing)
                    if (chkNull("資料型態", $("#tf_datatype_" + count)[0])) isgoing = false;
                if (isgoing)
                    if (chkNull("預設否", $("#tf_default_" + count)[0])) isgoing = false;

                var chkflag = $(this).find("input[name*='chk_flag']")[0];

                // 有勾選才做動作
                //if (chkflag.checked) {
                    
                //}

            });
        }

        if (!isgoing) return;
        
        //處理欄位table檢查
        isgoing = true;
        var len = $('#tabcode2 > tbody  > tr').length;
        if (len > 0) {
            var count = 0;
            $('#tabcode2 > tbody  > tr').each(function () {
                count += 1;

                if (chkNull("主旨群組", $("#group_select_" + count)[0])) isgoing = false;
                if (isgoing)
                    if (chkNull("欄位類型", $("#tf_subject_type_" + count)[0])) isgoing = false;
                if (isgoing)
                    if (chkNull("資料型態", $("#tf_datatype2_" + count)[0])) isgoing = false;
            });
        }

        if (!isgoing) return;

        //$("#tf_content").val(CKEDITOR.instances.tf_content.document.getBody().getText());
        //$("#tf_content2").val(CKEDITOR.instances.tf_content2.document.getBody().getText());

        //$("#tf_content").val(CKEDITOR.instances.tf_content.getData());
        //$("#tf_content2").val(CKEDITOR.instances.tf_content2.getData());

        if ($("#chk_flag").prop('checked'))
            $("#hchk_flag").val("Y");
        else
            $("#hchk_flag").val("N");

        reg.action = "nimp851_Update.aspx";
        reg.submit();
    };

    //載入目前設定
    function loadSetting() {
        var psql = "";
        psql = "select a.*, ";
        psql += " (select sc_name from sysctrl.dbo.scode where scode=a.pr_scode) as pr_scodenm,";
        psql += " (select sc_name from sysctrl.dbo.scode where scode=a.pr_scodej) as pr_scodejnm,";
        psql += " (select sc_name from sysctrl.dbo.scode where scode=a.supply_scode) as supply_scodenm,";
        psql += " (select sc_name from sysctrl.dbo.scode where scode=a.chk_scode) as chk_scodenm,";
        psql += " (select sc_name from sysctrl.dbo.scode where scode=a.chk_scodej) as chk_scodejnm";
        psql += " from tfcode_imp a ";
        psql += " where a.tf_code='<%=tf_code%>'";
        
        $.ajax({
            url: "../AJAX/AjaxGetSqlDataMulti.aspx?SQL=" + psql,
            type: "POST",
            async: false,
            cache: false,
            data: $("#reg").serialize(),
            success: function (json) {
                var JSONdata = $.parseJSON(json);
                $.each(JSONdata, function (i, item) {
                    //電文代碼
                    if ($("#submitTask").val() != "C") {
                        $("#tf_code").val(item.tf_code);
                    }
                    
                    //轉口案定稿
                    if (item.tfext_flag == "Y") {
                        $("#tfext_flag").prop('checked', true);
                        $("#ext_flag").val("Y");
                    }
                    //所屬資料來源
                    $("#tf_type").val(item.tf_type);
                    //電文名稱
                    $("#tf_name").val(item.tf_name);
                    //電文語文
                    $("#lang_code").val(item.lang_code);
                    //電文代碼種類
                    $("#tf_class").val(item.tf_class);
                    $("#tf_cnt").val(item.tf_cnt);
                    
                    //主旨group設定
                    if ($("#tf_group_cnt").val() == "0") {
                        if (item.tf_group_cnt == null)
                            $("#tf_group_cnt").val("0");
                        else
                            $("#tf_group_cnt").val(item.tf_group_cnt);
                    }
                    
                    //承辦人(非日)
                    $("#pr_team").val(item.pr_team);                    
                    var ajax_sql = gettf_work_Scode("<%=prgid%>", item.pr_team, "<%=scode%>", "<%=se_grpclass%>");
                    get_ajax_selection(ajax_sql, "pr_scode", true);
                    $("#pr_scode").val(item.pr_scode);

                    //判行人員(非日)
                    if (item.chk_flag == "Y")
                        $("#chk_flag").prop('checked', true);

                    $("#chk_scode").val(item.chk_scode);
                    $("#chk_scodenm").val(item.chk_scodenm);
                    /*  
                    pr_scodenm = rsi("pr_scodenm")                    
                    pr_scodejnm = rsi("pr_scodejnm")                    
                    */

                    //承辦人(日)
                    $("#pr_teamj").val(item.pr_teamj);

                    var pr_teamj = $("#pr_teamj option:selected").val();
                    ajax_sql = gettf_work_Scode("<%=prgid%>", item.pr_teamj, "<%=scode%>", "<%=se_grpclass%>");
                    get_ajax_selection(ajax_sql, "pr_scodej", true);
                    $("#pr_scodej").val(item.pr_scodej);

                    //判行人員(日)
                    $("#chk_scodej").val(item.chk_scodej);
                    $("#chk_scodejnm").val(item.chk_scodejnm);


                    $("#tf_content_head").val(decodeStr(HtmlDecodeStr(item.tf_content_head)));
                    //電文內容
                    $("#tf_content").val(decodeStr(HtmlDecodeStr(item.tf_content)));
                    //信函署名
                    $("#tf_sender1").val(item.tf_sender1);
                    $("#tf_sender2").val(item.tf_sender2);
                    //有無附件
                    $("#tf_havefile").val(item.tf_havefile);
                    //電文內尾內容
                    $("#tf_content2").val(decodeStr(HtmlDecodeStr(item.tf_content2)));
                    //收發種類
                    $("#tf_ag").val(item.tf_ag);
                    //收/發文
                    $("#tf_rs").val(item.tf_rs);
                    $("#RS_Type").val(item.rs_type);


                    <%--//結構分類
                    ajax_sql = get_rs_class($("#agrs").val(), '<%=prgid%>', $("#ext_flag").val(), $("#RS_Type").val());
                    get_ajax_selection(ajax_sql, "form_rs_class", false);

                    //案性代碼
                    ajax_sql = get_rs_code($("#agrs").val(), '<%=prgid%>', $("#ext_flag").val(), $("#RS_Type").val(), $("#submitTask").val());
                    //alert(ajax_sql);
                    get_ajax_selection(ajax_sql, "form_rs_code", false);

                    //承辦事項
                    ajax_sql = get_act_code($("#agrs").val(), '<%=prgid%>', $("#ext_flag").val(), $("#RS_Type").val(), $("#submitTask").val(), $("#rs_class").val(), $("#rs_code").val());
                    //alert(ajax_sql);
                    get_ajax_selection(ajax_sql, "form_act_code", false);--%>

                    
                    //結構分類
                    ajax_sql = get_rs_class($("#agrs").val(), '<%=prgid%>', item.tfext_flag, $("#RS_Type").val());
                    get_ajax_selection(ajax_sql, "form_rs_class", false);
                    $("#form_rs_class").val(item.rs_class);
                    //案性代碼
                    ajax_sql = get_rs_code_by_rs_class($("#agrs").val(), '<%=prgid%>', item.tfext_flag, $("#RS_Type").val(), $("#submitTask").val(), item.rs_class);                    
                    get_ajax_selection(ajax_sql, "form_rs_code", false);
                    $("#form_rs_code").val(item.rs_code);
                    //承辦事項
                    ajax_sql = get_act_code_by_rs_class_rs_code($("#agrs").val(), '<%=prgid%>', item.tfext_flag, $("#RS_Type").val(), $("#submitTask").val(), item.rs_class, item.rs_code);                    
                    get_ajax_selection(ajax_sql, "form_act_code", false);
                    $("#form_act_code").val(item.act_code);


                    //發文內容
                    $("#rs_detail").val(item.rs_detail);
                    //發文方式
                    $("input:checkbox[name=Send_Way]").each(function () {
                        var way = $(this).val();
                        var ischeck = item.send_way.indexOf(way);
                        if (ischeck >= 0) {
                            //$(this).checked = true;
                            $(this).prop('checked', true);
                        }
                    });
                    //LETTER
                    ajax_sql = gettf_letter();
                    get_ajax_selection(ajax_sql, "tf_send_way1", false);
                    $("#tf_send_way1").val(item.send_way1);
                    //平台
                    $("#tf_send_way_A5").val(item.send_way_A5);
                    //使用起始日期
                    $("#beg_date").val(dateReviver(item.beg_date, "yyyy/MM/dd"));
                    //使用結束日期
                    $("#end_date").val(dateReviver(item.end_date, "yyyy/MM/dd"));
                    //可由電文新增
                    $("#canadd").val(item.canadd);

                    //電文提供者
                    $("#supply_scode").val(item.supply_scode);
                    $("#supply_scodenm").val(item.supply_scodenm);
                    //修改註記
                    $("#upd_code").val(item.upd_code);
                    //使用群組
                    $("#use_grpid").val(item.use_grpid);
                    //備註說明
                    $("#tf_remark").val(item.tf_remark);
                    //備註
                    $("#mark").val(item.mark);
                    //承辦點數
                    $("#pr_point").val(item.pr_point);
                    //判行點數
                    $("#chk_point").val(item.chk_point);
                    //承辦統計分類
                    $("#qry_type1").val(item.qry_type1);

                    //使用的程式作業
                    $("#us_prgids").val(item.us_prgids);
                });
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