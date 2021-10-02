<%@ Control Language="C#" ClassName="nimp851Form" %>
<%@ Import Namespace="System.Data" %>
<%@Import Namespace = "System.Text"%>
<%@Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.IO"%>
<%@ Import Namespace = "System.Linq"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Web.Script.Serialization"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>
<%@ Register Src="~/cust/impForm/nimp8511Form.ascx" TagPrefix="uc1" TagName="nimp8511Form" %>
<%@ Register Src="~/cust/impForm/nimp8512Form.ascx" TagPrefix="uc1" TagName="nimp8512Form" %>
<%--<%@ Register Src="~/cust/impForm/RS_Code_Form.ascx" TagPrefix="uc1" TagName="RS_Code_Form" %>--%>

<script runat="server">
   
    protected string StrAddLink = "";
    protected string StrSaveBtn = "";
    protected string StrResetBtn = "";
    protected string isql = "";

    protected string StrCustCodeCtrl = "";

    protected string inputStyle = "";
    protected string trStyle = "";
    protected string btnStyle = "";
    protected string submitTask = "";
    protected string plang_code = "";
    
    protected string prgid = HttpContext.Current.Request["prgid"];
    
    protected string se_grpclass = "FIMP";
    protected string scode = "";

    private void Page_Load(System.Object sender, System.EventArgs e)
    {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        if (Request["submitTask"] != null) submitTask = Request["submitTask"].ToString();
        prgid = Request["prgid"].ToString();

        if ((Request["lang_code"] ?? "") != "")
            plang_code = Request["lang_code"];
        
        //se_grpclass = Session["se_grpclass"].ToString();

        scode = Session["scode"].ToString();
    }

</script>

<table id ="table_form" name ="table_form" border="0" class="bluetable" cellspacing="1" cellpadding="2" style="font-size: 9pt" width="85%" align="center">
    <tr>
        <td class="lightbluetable" align="right">電文代碼：</td>
        <td class="whitetablebg">
            <input type="text" id ="tf_code" name="tf_code" size="10" maxlength="10" value="" onkeyup="Upper(this)" />
            <input type="button" value="確定" class="cbutton" id="tf_codebutton" name="tf_codebutton" width="">
            <input type="hidden" id ="keytf_code" name="keytf_code" value="N">
            <input type="checkbox" value="Y" id ="tfext_flag" name="tfext_flag" onclick="setext_rs_code()">轉口案定稿
            <input type="hidden" name="ext_flag" value="">
			<input type="hidden" name="agrs" value="AS">			
        </td>
        <td class="lightbluetable" align="right">電文代碼種類：</td>
        <td class="whitetablebg">
            <select id="tf_class" name="tf_class" size="1">
                <option value='' style='color: blue' selected="selected">請選擇</option>
            </select>
        </td>
        <td class="lightbluetable" align="right" nowrap>所屬資料來源：</td>
        <td class="whitetablebg">
            <select id="tf_type" name="tf_type" size="1">
                <option value='' style='color: blue' selected="selected">請選擇</option>
            </select>
        </td>
    </tr>
    <tr>
        <td class="lightbluetable" align="right">電文名稱：</td>
        <td class="whitetablebg" colspan="3">
            <input type="text" id ="tf_name" name="tf_name" size="66" maxlength="60" value="" />
        </td>
        <td class="lightbluetable" align="right" nowrap>電文語文：</td>
        <td class="whitetablebg">
            <select id="ddl_lang_code" name="ddl_lang_code" size="1">
                <option value='' style='color: blue' selected="selected">請選擇</option>
            </select>
        </td>
    </tr>
    <tr>
        <td class="lightbluetable" align="right">使用的程式作業：</td>
        <td class="whitetablebg" colspan="5">
            <input type="text" id ="us_prgids" name="us_prgids" size="160" maxlength="200" value="" /><br />
            *以 : 隔開，空白表示不限定
        </td>        
    </tr>
    <tr>
        <td class="lightbluetable" align="right">承辦人(非日)：</td>
        <td class="whitetablebg">
            <select id ="pr_team" name="pr_team" size="1">
                <option value='' style='color: blue' selected="selected">請選擇</option>
            </select>
            <span id="span_pr_scode">
                <select id="pr_scode" name="pr_scode" size="1">
                    <option value='' style='color: blue' selected="selected">請選擇</option>
                </select>
            </span>
        </td>
        <td class="lightbluetable" align="right" nowrap>
            <input type="hidden" id ="hchk_flag" name="hchk_flag" value="" />
            <input type="checkbox" id ="chk_flag" name="chk_flag" />
            判行人員(非日)：</td>
        <td class="whitetablebg" colspan="3">
            <input id ="chk_scode" name="chk_scode" size="5" maxlength="5" />
            (請輸入薪號，若為程序主承辦請輸入A，若為工程師組長請輸入B)
			<input type="button" value="確定" class="cbutton" id="chk_scodebutton" name="chk_scodebutton" onclick="supply_scode_onclick('chk_scode')" />
            <input type="hidden" id ="keychk_scode" name="keychk_scode" value="N" />
            <input id ="chk_scodenm" name="chk_scodenm" size="10" maxlength="10" readonly class="sedit" />
        </td>
    </tr>
    <tr>
        <td class="lightbluetable" align="right">承辦人(日)：</td>
        <td class="whitetablebg">
            <select id ="pr_teamj" name="pr_teamj" size="1">
                <option value='' style='color: blue' selected="selected">請選擇</option>
            </select>
            <span id="span_pr_scodej">
                <select id ="pr_scodej" name="pr_scodej" size="1">
                    <option value='' style='color: blue' selected="selected">請選擇</option>
                </select>
            </span>
        </td>
        <td class="lightbluetable" align="right" nowrap>判行人員(日)：</td>
        <td class="whitetablebg" colspan="3">
            <input id ="chk_scodej" name="chk_scodej" size="5" maxlength="5" />
            (請輸入薪號，若為程序主承辦請輸入A，若為工程師組長請輸入B)
			<input type="button" value="確定" class="cbutton" id="chk_scodejbutton" name="chk_scodejbutton" onclick="supply_scode_onclick('chk_scodej')" />
            <input type="hidden" id ="keychk_scodej" name="keychk_scodej" value="N">
            <input id ="chk_scodejnm" name="chk_scodejnm" size="10" maxlength="10" readonly class="sedit" />
        </td>
    </tr>    
    <tr id ="tr_head">
        <td class="lightbluetable" align="right" nowrap>電文開頭內容：</td>
        <td class="whitetablebg" colspan="5">
            <textarea type="text" name="tf_content_head" id="tf_content_head" style="width: 90%; height: 150px;"></textarea>
        </td>
    </tr>    
    <tr>
        <td class="lightbluetable" align="right" nowrap>電文內容：</td>
        <td class="whitetablebg" colspan="5">
            <textarea type="text" name="tf_content" id="tf_content" style="width: 90%; height: 150px;"></textarea>
        </td>
    </tr>
    <tr>
        <td class="lightbluetable" align="right" nowrap>信函署名：</td>
        <td class="whitetablebg">
            <select id ="tf_sender1" name="tf_sender1" size="1">
                <option value='' style='color: blue' selected="selected">請選擇</option>
            </select>
        </td>
        <td class="lightbluetable" align="right" nowrap>E-mail署名：</td>
        <td class="whitetablebg">
            <select id ="tf_sender2" name="tf_sender2" size="1">
                <option value='' style='color: blue' selected="selected">請選擇</option>
            </select>
        </td>
        <td class="lightbluetable" align="right" nowrap>有無附件：</td>
        <td class="whitetablebg">
            <select id ="tf_havefile" name="tf_havefile" size="1">
                <option value='' style='color: blue' selected="selected">請選擇</option>
            </select>
            【 Encl(s)，Attachment(s) 】
        </td>
    </tr>
    <tr>
        <td class="lightbluetable" align="right" nowrap>電文內尾內容：</td>
        <td class="whitetablebg" colspan="5">
            <textarea type="text" name="tf_content2" id="tf_content2" style="width: 90%; height: 150px;"> </textarea>
        </td>
    </tr>
    <tr>
        <td class="whitetablebg" colspan="6">
            <label id="lbl_var">信函變數設定</label>
        </td>
    </tr>
    <tr>
        <td class="whitetablebg" colspan="6">
            <uc1:nimp8511Form runat="server" ID="nimp8511Form" />
        </td>
    </tr>
    <tr id ="tr_subject_title">
        <td class="whitetablebg" colspan="6">
            <label id="lbl_group">主旨案件資料設定</label>
        </td>
    </tr>
    <tr id ="tr_subject">
        <td class="whitetablebg" colspan="6">
            <uc1:nimp8512Form runat="server" ID="nimp8512Form" />
        </td>
    </tr>
    <tr>
        <td class="lightbluetable" align="right">發文代碼：</td>
        <td class="whitetablebg" colspan="5">
            <%--<uc1:RS_Code_Form runat="server" ID="RS_Code_Form" />--%>
        </td>
    </tr>
    <tr>
        <td class="lightbluetable" align="right">發文內容：</td>
        <td class="whitetablebg" colspan="5">
            <input id ="rs_detail" name="rs_detail" size="80" maxlength="100" />
        </td>
    </tr>
    <tr>
        <td class="lightbluetable" align="right">發文方式：</td>
        <td class="whitetablebg" colspan="5">
            <div id="div_Send_Way">
            </div>           
        </td>
    </tr>
    <tr>
        <td class="lightbluetable" align="right">收發種類：</td>
        <td class="whitetablebg">
            <select id="tf_ag" name="tf_ag" size="1">
            </select>
        </td>
        <td class="lightbluetable" align="right">收/發文：</td>
        <td class="whitetablebg" colspan="3">
            <select id="tf_rs" name="tf_rs" size="1">
                <option value="">請選擇</option>
                <option value="R">R_收</option>
                <option value="S">S_發</option>
            </select>
        </td>
    </tr>
    <%--<tr>
        <td class="lightbluetable" align="right">對方號標題：</td>
        <td class="whitetablebg">
            <select id="your_title" name="your_title" size="1">
                <option value="">請選擇</option>
                <option value="0">Your Ref</option>
                <option value="1">貴Ref.</option>
            </select>
        </td>
        <td class="lightbluetable" align="right">本所編號標題：</td>
        <td class="whitetablebg" >
            <select id="fseq_title" name="fseq_title" size="1">
                <option value="">請選擇</option>
                <option value="0">Our Ref</option>
                <option value="1">当Ref.</option>
            </select>
        </td>
        <td class=lightbluetable align=right>申請人標題：</td>
		<td class=whitetablebg>
			<select id ="apcustnm_title" name="apcustnm_title" size=1>
				<option value="0">Apply</option>
				<option value="1">出願人</option>
			</select>
		</td>
    </tr>
    <tr>
        <td class="lightbluetable" align="right">申請號標題：</td>
        <td class="whitetablebg">
            <select id="apply_title" name="apply_title" size="1">
                <option value="">請選擇</option>
                <option value="0">Apply No</option>
                <option value="1">出願番号</option>
            </select>
        </td>
        <td class="lightbluetable" align="right">申請日標題：</td>
        <td class="whitetablebg" colspan="3">
            <select id="apply_date_title" name="apply_date_title" size="1">
                <option value="">請選擇</option>
                <option value="0">Apply Date</option>
                <option value="1">出願日</option>
            </select>
        </td>
    </tr>--%>
    <tr>
		<td class=lightbluetable align=right>使用起始日期：</td>
		<td class=whitetablebg>			
            <input type="text" id ="beg_date" name="beg_date" class="dateField" value="" size="10" />
		</td>
		<td class=lightbluetable align=right>使用結束日期：</td>
		<td class=whitetablebg>				
            <input type="text" id ="end_date" name="end_date" class="dateField" value="" size="10" />
		</td>
		<td class=lightbluetable align=right>可由電文新增：</td>
		<td class=whitetablebg>
			<select id ="canadd" name="canadd" size=1>
				<option value="N">否</option>
				<option value="Y">是</option>
			</select>
		</td>
	</tr>
    <tr>
        <td class="lightbluetable" align="right" nowrap>電文提供者：</td>
        <td class="whitetablebg" colspan="5">
            <input id ="supply_scode" name="supply_scode" size="5" maxlength="5" />
            (請輸入薪號)
			<input type="button" value="確定" class="cbutton" id="supply_scodebutton" name="supply_scodebutton"  onclick="supply_scode_onclick('supply_scode')" />
            <input type="hidden" id ="keysupply_scode" name="keysupply_scode" value="N">
            <input id ="supply_scodenm" name="supply_scodenm" size="10" maxlength="10" readonly class="sedit" />
        </td>
    </tr>
    <tr>
        <td class="lightbluetable" align="right">修改註記：</td>
        <td class="whitetablebg" colspan="5">
            <select id ="upd_code" name="upd_code" size="1">
                <option value="N" checked>使用者不能修改</option>
                <option value="Y">使用者可修改</option>
            </select>
        </td>
    </tr>
    <tr>
        <td class="lightbluetable" align="right">使用群組：</td>
        <td class="whitetablebg" colspan="5">
            <input type="text" id="use_grpid" name="use_grpid" size="80" maxlength="255" />
            (行政組織，用 ; 區隔)
        </td>
    </tr>
    <tr>
        <td class="lightbluetable" align="right">備註說明：</td>
        <td class="whitetablebg" colspan="5">
            <input type="text" id="tf_remark" name="tf_remark" size="80" maxlength="255" />
            (電文用途說明)
        </td>
    </tr>
    <tr>
        <td class="lightbluetable" align="right">備註：</td>
        <td class="whitetablebg" colspan="5">
            <input type="text" id="mark" name="mark" size="7" maxlength="5" />
            (第一碼"T"表有翻譯本)
        </td>
    </tr>
    <TR>
		<TD class=lightbluetable align=right>承辦點數：</TD>
		<TD class=whitetablebg >
			<input type="text" id ="pr_point" name="pr_point" size=5 maxlength=5 />
		</TD>
		<TD class=lightbluetable align=right>判行點數：</TD>
		<TD class=whitetablebg >
			<input type="text" id ="chk_point" name="chk_point" size=5 maxlength=5 />
		</TD>
		<TD class=lightbluetable align=right nowrap>承辦統計分類：</TD>
		<TD class=whitetablebg align=left >
			<Select id ="qry_type1" name="qry_type1">
				<option value='' style='color: blue' selected="selected">請選擇</option>
			</Select>
		</td>
	</TR>
</table>

<script type="text/javascript" language="javascript">
    function init_load() {
        $("#re_back").hide();
        
        $("#mark").val($("#hidden_mark").val());

        var ajax_sql = gettf_class(true, 'Y');
        get_ajax_selection(ajax_sql, "tf_class", 1);

        ajax_sql = gettf_type();
        get_ajax_selection(ajax_sql, "tf_type", 1);
        
        ajax_sql = getlang("<%=plang_code%>");
        get_ajax_selection(ajax_sql, "ddl_lang_code", 1);
        $("#ddl_lang_code").val("<%=plang_code%>");

        ajax_sql = gettf_work_Team("", "", "<%=se_grpclass%>");
        get_ajax_selection(ajax_sql, "pr_team", 0);

        ajax_sql = gettf_work_Team("", "", "<%=se_grpclass%>");
        get_ajax_selection(ajax_sql, "pr_teamj", 0);

        ajax_sql = gettf_sender1();
        get_ajax_selection(ajax_sql, "tf_sender1", 0);

        ajax_sql = gettf_sender2();
        get_ajax_selection(ajax_sql, "tf_sender2", 0);

        ajax_sql = gettf_havefile();
        get_ajax_selection(ajax_sql, "tf_havefile", 0);

        ajax_sql = gettf_send_way();
        send_way_ajax_checkbox(ajax_sql, "div_Send_Way", "Send_Way");

        ajax_sql = gettf_ag();
        get_ajax_selection(ajax_sql, "tf_ag", 0);

        var today = new Date();
        $("#beg_date").val(today.yyyymmdd());

        ajax_sql = get_type1("");
        get_ajax_selection(ajax_sql, "qry_type1", 0);

    }

    $(function () {
        init_load();
        $("input.dateField").datepick();

        $("#pr_team").on("change", function (e) {
            var pr_team = $("#pr_team option:selected").val();
            var ajax_sql = gettf_work_Scode("<%=prgid%>", pr_team, "<%=scode%>", "<%=se_grpclass%>");
            get_ajax_selection(ajax_sql, "pr_scode", 1);
        });

        $("#pr_teamj").on("change", function (e) {
            var pr_teamj = $("#pr_teamj option:selected").val();
            var ajax_sql = gettf_work_Scode("<%=prgid%>", pr_teamj, "<%=scode%>", "<%=se_grpclass%>");
            get_ajax_selection(ajax_sql, "pr_scodej", 1);
        });

        //檢查電文代碼
        $("#tf_codebutton").click(function (e) {
            $("#keytf_code").val("N");

            $.ajax({
                url: "nimp851List.aspx?qrytf_code=" + $("#tf_code").val(),
                type: "POST",
                async: false,
                cache: false,
                data: $("#reg").serialize(),
                success: function (json) {                    
                    var JSONdata = $.parseJSON(json);
                    //toastr.info("<a href='" + this.url + "?" + $("#reg").serialize() + "' target='_new'>Debug！<BR><b><u>(點此顯示詳細訊息)</u></b></a>");
                    
                    var totRow = parseInt(JSONdata.totRow, 10);
                    if (totRow > 0) {
                        alert("電文代碼已存在，請重新輸入!!!");
                    }
                    else {
                        $("#keytf_code").val("Y");
                    }
                },
                beforeSend: function (jqXHR, settings) {
                    jqXHR.url = settings.url;
                },
                error: function (jqXHR, textStatus, errorThrown) {
                    alert("\n資料擷取剖析錯誤 !\n" + jqXHR.url);
                }
            });
        });
        
    });

    // 處理發文方式的特殊化checkbox
    function send_way_ajax_checkbox(psql, pdiv, pname, pdynamic) {
        var checkboxBtn = "";
        var selectbox = "";
        $.ajax(
            {
                cache: false,
                async: false,
                type: "GET",
                url: "../AJAX/AjaxGetSqlDataMulti.aspx?SQL=" + psql,
                success: function (data) {
                    var JSONdata = $.parseJSON(data);
                    $.each(JSONdata, function (i, item) {
                        if (!pdynamic) {
                            checkboxBtn = '<input type="checkbox"  name="' + pname + '" value="' + item.vFld + '" /><label>' + item.dFld + '</label></input>';
                            var checkbox_Btn = $(checkboxBtn);
                            checkbox_Btn.appendTo('#' + pdiv + '');

                            if (item.vFld == "A2") {
                                selectbox = "<select id ='tf_send_way1' name='send_way1' size='1'><option value='' style='color: blue' selected='selected'>請選擇</option></select>";
                                var selectbox_Btn = $(selectbox);
                                selectbox_Btn.appendTo('#' + pdiv + '');
                            }

                            if (item.vFld == "A5") {
                                selectbox = "<select id ='tf_send_way_A5' name='send_way_A5' size='1'><option value='' style='color: blue' selected='selected'>請選擇</option></select>";
                                var selectbox_Btn = $(selectbox);
                                selectbox_Btn.appendTo('#' + pdiv + '');
                            }
                        }
                        else {
                            checkboxBtn += '<input type="checkbox"  name="' + pname + '" value="' + item.vFld + '" /><label>' + item.dFld + '</label></input>';
                        }
                    });
                }
            });

        var ajax_sql = gettf_letter();
        get_ajax_selection(ajax_sql, "tf_send_way1", 0);

        ajax_sql = gettf_platform();
        get_ajax_selection(ajax_sql, "tf_send_way_A5", 0);

        return checkboxBtn;
    }

    //檢查電文提供者
    function supply_scode_onclick(p1) {
        var msg = "";
        if (p1 == "chk_scode"){
            $("#keychk_scode").val("N");
            if (chkNull("判行人員", $("#chk_scode")[0])) return;
            msg = "判行人員";
        }
        else if (p1 == "chk_scodej"){
            $("#keychk_scodej").val("N");
            if (chkNull("判行人員", $("#chk_scodej")[0])) return;
            msg = "判行人員";
        }
        else if (p1 == "supply_scode") {
            $("#keysupply_scode").val("N");
            if (chkNull("電文提供者", $("#supply_scode")[0])) return;
            msg = "電文提供者";
        }

        var JSONdata = check_scode($("#" + p1).val());
        if (JSONdata == "") {
            alert("薪號不存在，請重新輸入!!!");
            $("#" + p1).focus();
            return;
        }
        else {
            $.each(JSONdata, function (i, item) {
                $("#" + p1 + "nm").val(item.sc_name);

                if (p1 == "chk_scode") {
                    $("#keychk_scode").val("Y");                    
                }
                else if (p1 == "chk_scodej") {
                    $("#keychk_scodej").val("Y");                    
                }
                else if (p1 == "supply_scode") {
                    $("#keysupply_scode").val("Y");                   
                }
            });
        }
    }

    function Upper(d) {
        d.value = d.value.toUpperCase();
    }

    function setext_rs_code() {
        if ($("#tfext_flag").prop("checked")) 
            $("#ext_flag").val("Y");        
        else
            $("#ext_flag").val("N");

        rs_class_first();
    }

    function rs_class_first() {
        if ($("#ext_flag").val() == "Y")
            $("#RS_Type").val("PE95");
        else
            $("#RS_Type").val("P94");

        //結構分類
        var ajax_sql = get_rs_class($("#agrs").val(), '<%=prgid%>', $("#ext_flag").val(), $("#RS_Type").val());
        get_ajax_selection(ajax_sql, "form_rs_class", 0);

        //案性代碼
        ajax_sql = get_rs_code($("#agrs").val(), '<%=prgid%>', $("#ext_flag").val(), $("#RS_Type").val(), $("#submitTask").val());
        //alert(ajax_sql);
        get_ajax_selection(ajax_sql, "form_rs_code", 0);

        //承辦事項
        ajax_sql = get_act_code($("#agrs").val(), '<%=prgid%>', $("#ext_flag").val(), $("#RS_Type").val(), $("#submitTask").val(), $("#rs_class").val(), $("#rs_code").val());
        //alert(ajax_sql);
        get_ajax_selection(ajax_sql, "form_act_code", 0);
    }

</script>