<%@ Control Language="C#" ClassName="nimp8511Form" %>
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
        if (Request["submitTask"] != null) submitTask = Request["submitTask"].ToString();

        if ((Request["tf_code"] ?? "") != "")
            tf_code = Request["tf_code"];
    }

</script>

<input type="hidden" id="tf_cnt" name="tf_cnt" value="" />
<table id="tabcode" name="tabcode" style="display: " border="0" class="bluetable" cellspacing="1" cellpadding="2" width="100%">
    <thead>
        <tr id ="tr_control" class="whitetablebg" align="center">
            <td colspan="10" align="right">
                <input type="button" value="增加一筆" class="cbutton" id="code_Add_button" name="code_Add_button" onclick="Add_code_setting()">
                <input type="button" value="減少一筆" class="cbutton" id="code_Del_button" name="code_Del_button" onclick="Del_code_setting()">
            </td>
        </tr>
        <tr align="center" class="lightbluetable3">
            <td></td>
            <td>欄位</td>
            <td>欄位說明</td>
            <td id="ctrl_td1_title" >資料型態</td>
            <td id="ctrl_td2_title">必輸否</td>
            <td id="ctrl_td3_title">預設否</td>
            <td id="ctrl_td4_title">資料來源table</td>
            <td id="ctrl_td5_title">資料來源field</td>
            <td id="ctrl_td6_title">刪除</td>
            <td id="td_column_value_title">欄位內容</td>
        </tr>
        <tr style="display: none">
            <td align="center" width="5%" style="color: red; font-weight: bold;">
                <input name="sortfld_##" id="sortfld_##" size="2" maxlength="5" class="SEdit" readonly="readonly">
            </td>
            <td class="whitetablebg" align="center">
                <input type="text" id="tf_mod_##" name="tf_mod_##" size="10" maxlength="20" />
            </td>
            <td class="whitetablebg" align="center">
                <input type="text" id="tf_name_use_##" name="tf_name_use_##" size="30" maxlength="100" />
            </td>
            
            <td id="ctrl_td1" class="whitetablebg" align="center">
                <select id="tf_datatype_##" name="tf_datatype_##" >
                    <option value='' style='color:blue' selected>請選擇</option>                    
                </select>  
            </td>
            <td id="ctrl_td2" class="whitetablebg" align="center">
                <select id="ctrl_input_##" name="ctrl_input_##" >
                    <option value='' style='color:blue' selected>請選擇</option>
                    {{ctrl_input}}
                </select>  
            </td>
            <td id="ctrl_td3" class="whitetablebg" align="center">                
                <select id="tf_default_##" name="tf_default_##" >
                    <option value='' style='color:blue' selected>請選擇</option>
                    {{ctrl_default}}
                </select>  
            </td>
            <td id="ctrl_td4" class="whitetablebg" align="center">
                <select id="source_table_##" name="source_table_##" >
                    <option value='' style='color:blue' selected>請選擇</option>                    
                </select>  
            </td>
            <td id="ctrl_td5" class="whitetablebg" align="center">
                <select id="source_field_##" name="source_field_##" >
                    <option value='' style='color:blue' selected>請選擇</option>                    
                </select>  
            </td>
            <td id="ctrl_td6" class="whitetablebg" align="center">                
                <input id="check_delete_##" type="checkbox" name="check_delete_##"/>
            </td>
            
            <td id="td_column_value_##" class="whitetablebg" align="center">
                <input type="text" id="tf_column_value_##" name="tf_column_value_##" size="30" maxlength="100" />
            </td>
        </tr>
    </thead>
    <tbody>
    </tbody>
</table>

  
<script type="text/javascript" language="javascript">


    var ctrl_npno = 0;//

    $(function () {
        
        if ($("#submitTask").val() == "U" || $("#submitTask").val() == "D" || $("#submitTask").val() == "Q" || $("#submitTask").val() == "C") {
            //alert($("#submitTask").val());
            loadColumn();
        }

        if ($("#hy_imp_print").val() == "Y") //imp8b2.aspx
        {
            $("#tr_control").hide();
            $("td[id^='ctrl_td']").hide();            
        }
    });

    //載入目前設定
    function loadColumn() {
        var psql = "";
        psql = " select * from tf_codep ";
        psql += " where tf_code='<%=tf_code%>'";
        psql += " order by tf_code,sortfld";

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
                    Add_code_setting();
                    $("#sortfld_" + datanum).val(parseInt(item.sortfld));
                    $("#tf_mod_" + datanum).val(item.tf_mod);
                    $("#tf_name_use_" + datanum).val(item.tf_name_use);
                    $("#tf_datatype_" + datanum).val(item.tf_datatype);
                    $("#ctrl_input_" + datanum).val(item.ctrl_input);
                    $("#tf_default_" + datanum).val(item.tf_default);
                    $("#source_table_" + datanum).val(item.source_table);
                    $("#source_field_" + datanum).val(item.source_field);

                    $("#td_column_value_title,#td_column_value_" + datanum).hide();
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

    //載入目前設定
    function loadColumnbyCode(ptf_code) {        
        //清空數量
        ctrl_npno = 0;
        $('#tf_cnt').val(ctrl_npno);
        //只留下第一個TR
        $('#tabcode tbody tr').remove();

        var data_exist = false;
        var psql = "";
        psql = " select * from tf_codep ";
        psql += " where tf_code='" + ptf_code + "'";
        psql += " order by tf_code,sortfld";

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
                    Add_code_setting();
                    $("#sortfld_" + datanum).val(parseInt(item.sortfld));
                    $("#tf_mod_" + datanum).val(item.tf_mod);
                    $("#tf_name_use_" + datanum).val(item.tf_name_use);
                    $("#tf_datatype_" + datanum).val(item.tf_datatype);
                    $("#ctrl_input_" + datanum).val(item.ctrl_input);
                    $("#tf_default_" + datanum).val(item.tf_default);
                    $("#source_table_" + datanum).val(item.source_table);
                    $("#source_field_" + datanum).val(item.source_field);
                    
                    if ($("#hy_imp_print").val() == "Y") //imp8b2.aspx
                    {
                        $("#tabcode").lock();
                        $("#sortfld_" + datanum).lock();
                        $("#tf_mod_" + datanum).lock();
                        $("#tf_name_use_" + datanum).lock();
                        $("#tf_datatype_" + datanum).lock();
                        $("#ctrl_input_" + datanum).lock();
                        $("#tf_default_" + datanum).lock();
                        $("#source_table_" + datanum).lock();
                        $("#source_field_" + datanum).lock();
                    }

                    data_exist = true;
                });
            },
            beforeSend: function (jqXHR, settings) {
                jqXHR.url = settings.url;
            },
            error: function (jqXHR, textStatus, errorThrown) {
                alert("\n資料擷取剖析錯誤 !\n" + jqXHR.url);
            }
        });

        return data_exist;
    }

    //增加一筆
    function Add_code_setting() {
        ctrl_npno++;
        $("#tf_cnt").val(ctrl_npno);

        var strLine1 = "<tr class=sfont9 id='tr_ctrl_att_a_" + ctrl_npno + "'>" + $("#tabcode>thead tr").eq(2).html().replace(/##/g, ctrl_npno) + "</tr>";
        $("#tabcode>tbody").append(strLine1);
        
        //資料型態        
        var ajax_sql = gettf_datatype();
        get_ajax_selection(ajax_sql, "tf_datatype_" + ctrl_npno, 0);

        //必輸否
        var strLine1 = $("select[name='ctrl_input_" + ctrl_npno + "']").html();
        var html_ctrl_input = "<option value='N'>否</option><option value='Y'>是</option>";
        strLine1 = strLine1.replace(/{{ctrl_input}}/g, html_ctrl_input);
        $("select[name='ctrl_input_" + ctrl_npno + "']").html(strLine1);

        //預設否
        strLine1 = $("select[name='tf_default_" + ctrl_npno + "']").html();
        var html_tr_default = "<option value='N'>否</option><option value='Y'>是</option>";
        strLine1 = strLine1.replace(/{{ctrl_default}}/g, html_tr_default);
        $("select[name='tf_default_" + ctrl_npno + "']").html(strLine1);

        //資料來源table
        ajax_sql = getsource_table();
        get_ajax_selection(ajax_sql, "source_table_" + ctrl_npno, 0);

        //資料來源field
        ajax_sql = getsource_field();
        get_ajax_selection(ajax_sql, "source_field_" + ctrl_npno, 0);


        // control delete checkbox
        //strLine1 = $('#check_delete_' + ctrl_npno)[0].outerHTML;
        //if ($("#submitTask").val() == "A") {
        //    //strLine1 = $("select[name='check_delete_" + ctrl_npno + "']").html();                        
        //    strLine1 = strLine1.replace(/{{checked_flag}}/g, "disabled='true'");
        //    //$("select[name='check_delete_" + ctrl_npno + "']").html(strLine1);            
        //}
        //else
        //    strLine1 = strLine1.replace(/{{checked_flag}}/g, "");

        //$('#check_delete_' + ctrl_npno)[0].outerHTML = strLine1;

        $("#sortfld_" + ctrl_npno).val(ctrl_npno);

        if ($("#hy_imp_print").val() != "Y") //imp8b2.aspx
            $("#td_column_value_title,#td_column_value_" + ctrl_npno).hide();
    }

    function Del_code_setting() {
        /*
        $('tabcode>tr:last').remove();*/
        var gv = document.getElementById('tabcode');
        if (gv) {
            var rowscount = gv.rows.length;
            if (rowscount > 3) {
                //gv.rows[rowscount - 1].remove();
                $('#tr_ctrl_att_a_' + ctrl_npno).remove();
                ctrl_npno--;
                $("#tf_cnt").val(ctrl_npno);
            }
        }
        
    }

</script>