<%@ Control Language="C#" ClassName="nimp8512Form" %>
<%@ Import Namespace="System.Data" %>
<%@Import Namespace = "System.Text"%>
<%@Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.IO"%>
<%@ Import Namespace = "System.Linq"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Web.Script.Serialization"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>

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
    protected string tf_code = "";

    protected string prgid = HttpContext.Current.Request["prgid"];

    private void Page_Load(System.Object sender, System.EventArgs e)
    {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;
        submitTask = Request["submitTask"].ToString();

        if ((Request["tf_code"] ?? "") != "")
            tf_code = Request["tf_code"];
    }
</script>

<input type="hidden" id="tf_group_cnt" name="tf_group_cnt" value="0" />
<table id="tabcode2" name="tabcode2" style="display: " border="0" class="bluetable" cellspacing="1" cellpadding="2" width="100%">
    <thead>
        <tr class="whitetablebg" align="center">            
            <td colspan="9" align="right">
                <input type="button" value="增加一筆" class="cbutton" id="code_Add_button2" name="code_Add_button2" onclick="Add_setting2()">
                <input type="button" value="減少一筆" class="cbutton" id="code_Del_button2" name="code_Del_button2" onclick="Del_setting2()">
            </td>
        </tr>
        <tr align="center" class="lightbluetable3">
            <td></td>
            <td>主旨群組</td>
            <td>資料來源table</td>
            <td>資料來源field</td>
            <td>主旨欄位</td>   
            <td>主旨欄位類型</td>         
            <td>資料型態</td>
            <%--<td>必輸否</td>
            <td>預設否</td>--%>
            
            <td>刪除</td>
        </tr>
        <tr style="display: none">
            <td align="center" width="5%" style="color: red; font-weight: bold;">
                <input name="sortfld2_##" id="sortfld2_##" size="2" maxlength="5" class="SEdit" readonly="readonly">                
            </td>
            <td class="whitetablebg" align="center">
                <%--<input type="text" id="tf_name_use2_##" name="tf_name_use2_##" size="30" maxlength="100" />--%>
                <select id="group_select_##" name="group_select_##" size="1" onchange ="changeColumn(##)">
                    <option value="">請選擇</option>
                    <option value="0">代理人名稱及地址</option>
                    <option value="1">主旨一</option>
                    <option value="2">主旨二</option>                     
                </select>
            </td>
            <td class="whitetablebg" align="center">
                <select id="source_table2_##" name="source_table2_##" onchange ="changeTable(##)" >
                    <option value='' style='color:blue' selected>請選擇</option>                    
                </select>  
            </td>
            <td class="whitetablebg" align="center">
                <select id="source_field2_##" name="source_field2_##" onchange ="changefield(##)" >
                    <option value='' style='color:blue' selected>請選擇</option>                    
                </select>  
            </td>
            <td class="whitetablebg" align="center">
                <input type="text" id="tf_mod2_##" name="tf_mod2_##" size="50" maxlength="200" />
                <textarea type="text" name="tf_text_value_##" id="tf_text_value_##" style="width: 50%; height: 100px;"></textarea>
                <input type="hidden" id="tf_mark2_##" name="tf_mark2_##" value="" />
                <span id ="ctrl_show_##" name ="ctrl_show_##">
                    <br />
                    <input id="check_show_##" type="checkbox" name="check_show_##" checked="checked" />
                    若案件無資料，是否還顯示此項目
                </span>
                <%--<br />
                <select id="group_column" name="group_column" size="1">
                    <option value="">請選擇</option>
                    <option value="0">貴Ref.</option>
                    <option value="1">当Ref.</option>
                    <option value="2">出願人</option>
                    <option value="3">出願人Ref.</option>                    
                    <option value="4">出願番号</option>
                    <option value="5">出願日</option>
                    <option value="6">優先権主張</option>
                    <option value="7">審査請求</option>
                    <option value="8">応答期限</option>
                    <option value="9">書類名</option>
                    <option value="10">貴社管理番号</option>
                    <option value="11">弊所管理番号</option>
                    <option value="12">国名</option>
                    <option value="13">出願番号</option>
                    <option value="14">発明の名称</option>                    
                </select>--%>
            </td>
            <td class="whitetablebg" align="center">
                <select id="tf_subject_type_##" name="tf_subject_type_##" onchange ="" >
                    <option value='' style='color:blue' selected>請選擇</option>                    
                </select>  
            </td>
            <td class="whitetablebg" align="center">
                <select id="tf_datatype2_##" name="tf_datatype2_##" >
                    <option value='' style='color:blue' selected>請選擇</option>                    
                </select>  
            </td>
            <%--<td class="whitetablebg" align="center">
                <select id="ctrl_input2_##" name="ctrl_input2_##" >
                    <option value='' style='color:blue' selected>請選擇</option>
                    {{ctrl_input}}
                </select>  
            </td>
            <td class="whitetablebg" align="center">                
                <select id="tf_default2_##" name="tf_default2_##" >
                    <option value='' style='color:blue' selected>請選擇</option>
                    {{ctrl_default}}
                </select>  
            </td>--%>
            
            <td class="whitetablebg" align="center">                
                <input id="check_delete2_##" type="checkbox" name="check_delete2_##"/>
            </td>
        </tr>
    </thead>
    <tbody>
    </tbody>
</table>

  
<script type="text/javascript" language="javascript">


    var group_npno = 0;//

    $(function () {
        
        if ($("#submitTask").val() == "U" || $("#submitTask").val() == "D" || $("#submitTask").val() == "Q" || $("#submitTask").val() == "C") {
            //alert($("#submitTask").val());
            loadColumn2();
        }
    });

    //載入目前設定
    function loadColumn2() {
        var psql = "";
        psql = " select * from tf_codep_subject ";
        psql += " where tf_code='<%=tf_code%>'";
        psql += " order by tf_code,convert(int, sortfld)";

        $.ajax({
            url: "../AJAX/AjaxGetSqlDataMulti.aspx?SQL=" + psql,
            type: "POST",
            async: false,
            cache: false,
            data: $("#reg").serialize(),
            success: function (json) {
                var datanum = 0;

                var JSONdata = $.parseJSON(json);
                $.each(JSONdata, function (i, item) {
                    datanum++;
                    Add_setting2();
                    $("#sortfld2_" + datanum).val(parseInt(item.sortfld.substring(1)));
                    $("#group_select_" + datanum).val(item.sortfld[0]);

                    if (item.sortfld[0] == "0") {
                        $("#tf_text_value_" + datanum).show();
                        $("#tf_mod2_" + datanum).hide();
                        $("#tf_text_value_" + datanum).val(decodeStr(HtmlDecodeStr(item.tf_column)));
                    }
                    else {
                        $("#tf_text_value_" + datanum).hide();
                        $("#tf_mod2_" + datanum).show();
                        $("#tf_mod2_" + datanum).val(decodeStr(HtmlDecodeStr(item.tf_column)));
                    }
                    
                    if (item.source_field == "prior_date" || item.source_field == "ctrl_date" || item.source_field == "prior_no"){
                        $("#ctrl_show_" + datanum).show();
                        if (item.ctrl_show == "N")
                            $("#check_show_" + datanum)[0].checked = false;
                    }                        
                    else
                        $("#ctrl_show_" + datanum).hide();

                    $("#tf_datatype2_" + datanum).val(item.tf_datatype);
                    //$("#ctrl_input2_" + datanum).val(item.ctrl_input);
                    //$("#tf_default2_" + datanum).val(item.tf_default);
                    $("#source_table2_" + datanum).val(item.source_table);
                    $("#source_field2_" + datanum).val(item.source_field);
                    $("#tf_subject_type_" + datanum).val(item.tf_subject_type);
                });
            },
            beforeSend: function (jqXHR2, settings) {
                jqXHR2.url = settings.url;
            },
            error: function (jqXHR2, textStatus, errorThrown) {
                alert("\n資料擷取剖析錯誤 !\n" + jqXHR2.url);
            }
        });
    }

    //增加一筆
    function Add_setting2() {
        group_npno++;
        $("#tf_group_cnt").val(group_npno);

        var strLine1 = "<tr class=sfont9 id='tr_ctrl_att_a2_" + group_npno + "'>" + $("#tabcode2>thead tr").eq(2).html().replace(/##/g, group_npno) + "</tr>";
        $("#tabcode2>tbody").append(strLine1);
        
        $("#tf_text_value_" + group_npno).hide();
        
        //資料型態        
        var ajax_sql = gettf_datatype();
        get_ajax_selection(ajax_sql, "tf_datatype2_" + group_npno, 0);

        //必輸否
        //var strLine1 = $("select[name='ctrl_input2_" + group_npno + "']").html();
        //var html_ctrl_input = "<option value='N'>否</option><option value='Y'>是</option>";
        //strLine1 = strLine1.replace(/{{ctrl_input}}/g, html_ctrl_input);
        //$("select[name='ctrl_input2_" + group_npno + "']").html(strLine1);

        //預設否
        //strLine1 = $("select[name='tf_default2_" + group_npno + "']").html();
        //var html_tr_default = "<option value='N'>否</option><option value='Y'>是</option>";
        //strLine1 = strLine1.replace(/{{ctrl_default}}/g, html_tr_default);
        //$("select[name='tf_default2_" + group_npno + "']").html(strLine1);

        //資料來源table
        ajax_sql = getsource_table();
        get_ajax_selection(ajax_sql, "source_table2_" + group_npno, 0);

        //資料來源field
        ajax_sql = getsubject_source_field("");
        get_ajax_selection(ajax_sql, "source_field2_" + group_npno, 0);

        //主旨欄位類型
        ajax_sql = getsubject_type("");
        get_ajax_selection(ajax_sql, "tf_subject_type_" + group_npno, 0);

        $("#ctrl_show_" + group_npno).hide();

        // control delete checkbox
        //strLine1 = $('#check_delete2_' + group_npno)[0].outerHTML;
        //if ($("#submitTask").val() == "A") {
        //    //strLine1 = $("select[name='check_delete_" + group_npno + "']").html();                        
        //    strLine1 = strLine1.replace(/{{checked_flag2}}/g, "disabled='true'");
        //    //$("select[name='check_delete_" + group_npno + "']").html(strLine1);            
        //}
        //else
        //    strLine1 = strLine1.replace(/{{checked_flag2}}/g, "");

        //$('#check_delete2_' + group_npno)[0].outerHTML = strLine1;

        $("#sortfld2_" + group_npno).val(group_npno);
    }

    function Del_setting2() {
        /*
        $('tabcode>tr:last').remove();*/
        var gv = document.getElementById('tabcode2');
        if (gv) {
            var rowscount = gv.rows.length;
            if (rowscount > 3) {
                //gv.rows[rowscount - 1].remove();
                $('#tr_ctrl_att_a2_' + group_npno).remove();
                group_npno--;
                $("#tf_group_cnt").val(group_npno);
            }
        }
        
    }

    function changefield(index) {
        if ($("#source_field2_" + index).val() == "prior_date" || $("#source_field2_" + index).val() == "prior_no" || $("#source_field2_" + index).val() == "ctrl_date") {
            $("#ctrl_show_" + index).show();
        }
        else
            $("#ctrl_show_" + index).hide();

        $("#tf_mod2_" + index).val($("#source_field2_" + index).val());
        
        var psql = "";
        psql = " select cust_code, form_name, isnull(mark, '') as mark from cust_code where code_type='tf_subject_field' ";
        psql += " and Cust_code='" + $("#source_field2_" + index).val() + "'";
        
        $.ajax({
            url: "../AJAX/AjaxGetSqlDataMulti.aspx?SQL=" + psql,
            type: "POST",
            async: false,
            cache: false,
            data: $("#reg").serialize(),
            success: function (json) {
                var datanum = 0;

                var JSONdata = $.parseJSON(json);
                $.each(JSONdata, function (i, item) {
                    $("#tf_mod2_" + index).val(decodeStr(HtmlDecodeStr(item.form_name)));
                    $("#tf_mark2_" + index).val(decodeStr(HtmlDecodeStr(item.mark)));
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


    function changeColumn(index) {
        // change group, initial value
        $("#source_table2_" + index).val("");
        $("#source_field2_" + index).val("");
        $("#tf_text_value_" + index).val("");
        $("#tf_mod2_" + index).val("");

        var ajax_sql = getsubject_source_field("");
        get_ajax_selection(ajax_sql, "source_field2_" + index, 0);

        if ($("#group_select_" + index).val() == "0")
        {
            $("#tf_text_value_" + index).show();
            $("#tf_mod2_" + index).hide();
        }
        else {
            $("#tf_text_value_" + index).hide();
            $("#tf_mod2_" + index).show();
        }
    }

    function changeTable(index) {
        $("#ctrl_show_" + index).hide();
        $("#source_field2_" + index).val("");
        $("#tf_text_value_" + index).val("");
        $("#tf_mod2_" + index).val("");

        if ($("#source_table2_" + index).val() != "") {            
            //資料來源field
            var ajax_sql = getsubject_source_field($("#source_table2_" + index).val());
            get_ajax_selection(ajax_sql, "source_field2_" + index, 0);

        }
    }

</script>