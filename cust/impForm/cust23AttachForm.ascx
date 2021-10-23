<%@ Control Language="C#" ClassName="custAttachForm" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace = "System.Text"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.IO"%>
<%@ Import Namespace = "System.Linq"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Web.Script.Serialization"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>

<script runat="server">
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    public Dictionary<string, string> Lock = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    protected string submitTask = "";
    protected string seBranch = "";
    public string uploadfield = "attach";
    public string uploadsource = "";
    protected int HTProgRight = 0;
    
    private void Page_Load(System.Object sender, System.EventArgs e)
    {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;
        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");
        submitTask = Request["submitTask"];
        seBranch = Sys.GetSession("seBranch");
                
        prgid = Request["prgid"].ToString();
    }
    
    
</script>




<input type="hidden" id="hattach_sql" name="hattach_sql" value=""><!--位於第幾位-->
<input type=hidden name=refnum value=0><!--進度筆數-->
<TABLE id="tabAttach" border="0" class="bluetable"  cellspacing="1" cellpadding="2" width="100%">
    <thead>
        <TR align=center class=lightbluetable>
		<TD style="width:5%">刪除</TD>
        <TD style="width:15%">附件名稱</TD>
        <TD class=lightbluetable align=center>種類<hr style="border:1px;"/>附件說明</TD>
        <TD style="width:10%">上傳人員/日期</TD>
	    </TR>
    </thead>
    <tbody></tbody>
	    <script type="text/html" id="attach_template"><!--設定樣板-->
        <tr class="whitetablebg" id="tr_attach_##">
		    <td class="whitetablebg" align="center" nowrap>
                <span id="attachno_##"></span>
                <input type="checkbox" id="attach_del_##" name="attach_del_##" value="Y">
				<INPUT type="hidden" size=1 id="attach_upd_flag_##" name="attach_upd_flag_##">
		    </td>
		    <td class="whitetablebg">
                檔案名稱：<br />
                <INPUT type="text" name="attach_name_##" id="attach_name_##" size="30" class=SEdit readonly>
                <INPUT type="hidden" id=o_attach_name_##>
                <input type='hidden' id='uploadfield' name='uploadfield' value="<%#uploadfield%>">
                <input type='hidden' id='<%#uploadfield%>' name='<%#uploadfield%>'>
                <input type="hidden" id="<%=uploadfield%>_max_attach_no" name="<%=uploadfield%>_max_attach_no" size="2"><!--max attach_no-->
                <input type='hidden' id='tstep_grade' name='tstep_grade'>
                <input type='hidden' id='attach_sqlno' name='attach_sqlno'>
                <input type='hidden' id='attach_flag_name' name='attach_flag_name'>
                <input type='hidden' id='dir_name' name='dir_name'>
                <span id="span_source"><BR>
                原始檔名：<br />
                <input type='text' id='<%#uploadfield%>_source_name_##' name='<%#uploadfield%>_source_name_##' class=SEdit readonly size=50></span>
                <INPUT type="hidden" id=o_attach_source_name_##>
                <input type='hidden' id='old_<%#uploadfield%>_name_##' name='old_<%#uploadfield%>_name_##'>
                <input type='hidden' id='doc_type_mark' name='doc_type_mark'>
                <INPUT type="hidden" id="attach_doc_type_##" name="attach_doc_type_##"><!--doc_type-->
                <INPUT type="hidden" id="attach_path_##" name="attach_path_##"><!--attach_path-->
                <input type='hidden' id='attach_flag_##' name='attach_flag_##' value="A"><!--attach_flag-->
                <input type='hidden' id='attach_no_##' name='attach_no_##' value='##'><!--attach_no-->
                <input type='hidden' id='<%#uploadfield%>_size_##' name='<%#uploadfield%>_size_##'><!--attach_size-->
                <input type='hidden' id='attach_flagtran' name='attach_flagtran'><!--2014/12/13柳月for異動作業增加-->
                <input type='hidden' id='tran_sqlno' name='tran_sqlno' value='0'><!--2014/12/13柳月for異動作業增加-->
                <input type='hidden' id='<%#uploadfield%>_apattach_sqlno_##' name='<%#uploadfield%>_apattach_sqlno_##'><!--2015/12/25柳月for總契約書/委任書作業增加-->
                <input type='hidden' id='attach_old_branch' name='attach_old_branch'>
                <input type=button id='btn<%#uploadfield%>_##' name='btn<%#uploadfield%>_##' class='cbutton' value='上傳' onclick="UploadAttach('##')">
                <input type=button id='btn<%#uploadfield%>_D_##' name='btn<%#uploadfield%>_D_##' class='cbutton' value='刪除' onclick="DelAttach('##')">
                <input type=button id='btn<%#uploadfield%>_S_##' name='btn<%#uploadfield%>_S_##' class='cbutton' value='檢視' onclick="PreviewAttach('##')">
		    </td>
		    <td class="whitetablebg" align=left>
				<input type="hidden" id="attach_mremark_value_##" name="attach_mremark_value_##">
				<INPUT type="hidden" id=o_attach_mremark_##>
                <span id="spanclass_##"></span>
				<hr style="border:1px; " />
				<textarea rows="4" cols="80" id="attach_desc_##" name="attach_desc_##" style="width:100%"></textarea>
				<textarea id="o_attach_desc_##" style="display:none"></textarea>
			</td>
			<td class="whitetablebg">
				<INPUT id="attach_in_date_##" class=SEdit readOnly size=10><BR>
				<INPUT id="attach_in_scode_##" class=SEdit readOnly size=10>
				<INPUT id="attach_in_scodenm_##" class=SEdit readOnly size=10>
			</td>
	    </tr>
        </script>
    <tfoot>
        <tr>
        <TD colspan=7 align=left class="whitetablebg">
			<input type=button value="增加附件項目" class="cbutton" id="ref_AddAttach_button" name="ref_AddAttach_button" />
	    </TD>
    </tr>
    </tfoot>
</TABLE>




<script language="javascript" type="text/javascript">
    //****每個form都有自已的別名
    var cust23attachform = {};
  
    //畫面初始化
    cust23attachform.init = function () {
        if ('<%=submitTask%>' == "Q") {
            //$("#ref_Add_button").hide();
        }

    }
    //資料綁定
    cust23attachform.bind = function (jData, HTProgRight) {
        $("#hattach_sql").val("0");
        $.each(jData, function (i, item) {
            cust23attachform.addAtt();//新增一筆
            var nRow = $("#hattach_sql").val();

            //$("#no_" + nRow).text(nRow + ". ");
            //$("#scust_seq_" + nRow).val(item.cust_seq); //$("input[name=oatt_title]").val(item.att_title);
            //$row = $(this);
            $("#attach_name_" + nRow).val(item.attach_name);
            $("#o_attach_name_" + nRow).val(item.attach_name);
            $("#attach_source_name_" + nRow).val(item.source_name);
            $("#o_attach_source_name_" + nRow).val(item.source_name);
            $("#attach_doc_type_" + nRow).val(item.doc_type);
            $("#attach_path_" + nRow).val(item.attach_path);
            $("#attach_flag_" + nRow).val(item.attach_flag);
            $("#attach_no_" + nRow).val(item.attach_no);
            $("#attach_size_" + nRow).val(item.attach_size);
            var rMremark = item.mremark;
            $("input[type=checkbox][name='attach_mremark_" + nRow + "']").each(function (z) {
                $(this).prop('checked', false);
                if (rMremark.indexOf("|" + $(this).val() + "|") > -1) $(this).prop('checked', true);
            })
            $("#attach_mremark_value_" + nRow).val(rMremark);
            $("#o_attach_mremark_" + nRow).val(rMremark);
            $("#attach_in_scode_" + nRow).val(item.in_scode);
            $("#attach_in_scodenm_" + nRow).val(item.in_scodenm);
            $("#attach_in_date_" + nRow).val(item.indate);
            $("#attach_apattach_sqlno_" + nRow).val(item.apattach_sqlno);
            $("#attach_desc_" + nRow).val(item.attach_desc);
            $("#o_attach_desc_" + nRow).val(item.attach_desc);
            $("#btnRow_" + nRow).prop("disabled", true);

            //上傳者或權限C才可修改,其餘鎖定
            if (("<%=(HTProgRight & 256)%>" == "0") && ("<%=Sys.GetSession("scode")%>" != item.in_scode)) {
                $("#tr_attach_" + nRow + " select").prop('disabled', true);
                $("#tr_attach_" + nRow + " input:checkbox,#tr_attach_" + nRow + " input:button").prop('disabled', true);
                $("#tr_attach_" + nRow + " input,#tr_attach_" + nRow + " textarea").addClass("sedit").prop('readOnly', true);
                $("#btnRowS_" + nRow).prop('disabled', false);
            }
            //新增模式要鎖定
            if ("<%=submitTask%>" == "A") lockTr("attach_", nRow);
        })
    }



    //[增加一筆]
    cust23attachform.addAtt = function () {
        if ($.trim($("#cust_seq").val()) == "") {
            alert("請輸入客戶編號，才可新增 !!!");
            return false;
        }

        var nRow = CInt($("#hattach_sql").val()) + 1;//畫面顯示NO
        //複製樣板
        var copyStr = $("#attach_template").text() || "";
        copyStr = copyStr.replace(/##/g, nRow);
        //$("#tbl_att>tbody").append(copyStr);
        //$("#tabAttach").append(copyStr);
        $("#tabAttach>tbody").append(copyStr);

        $("#attachno_" + nRow).text(nRow + ". ");
        $("#hattach_sql").val(nRow);

        $("#spanclass_"+nRow).getCheckbox({//種類
            url: getRootPath() + "/ajax/JsonGetSqlData.aspx",
            data: { sql: "Select cust_code,code_name from cust_code where code_type='cmark_text' order by cust_code" },
            objName: "attach_mremark_"+nRow,
            valueFormat: "{cust_code}",
            textFormat: "{code_name}&nbsp;",
            mod: 10
        });

    }

    $("#ref_AddAttach_button").click(function (e) {
        cust23attachform.addAtt();
    });

  


    cust23attachform.SetReadOnly = function () {
        $("input[type=checkbox][id^='attach_del_']").hide();
        $("input[type=button][name^='btnattach_']").hide();
        $("input[type=button][name^='btnattach_S_']").show();
        $("#ref_AddAttach_button").hide();
        $("input[type=checkbox][name^='attach_mremark_']").lock();
        $("textarea[id^='attach_desc_']").lock();

    }

    function getmax_attach_no() {
        var psql = "select isnull(max(Attach_No),0) as max_attach_no ";
        psql += "from apcust_attach ";
        psql += "where cust_area = '" + $("#cust_area").val() + "' and apsqlno = '" + $("#apsqlno").val() + "'"
        var maxno = 1;
        $.ajax({
            url: "../AJAX/JsonGetSqlData.aspx?SQL=" + psql,
            type: "POST",
            async: false,
            cache: false,
            data: $("#reg").serialize(),
            success: function (json) {
                var JSONdata = $.parseJSON(json);
                maxno = parseInt(JSONdata[0].max_attach_no) + 1;
                $("#<%=uploadfield%>_max_attach_no").val(maxno);
            },
            beforeSend: function (jqXHR, settings) {
                jqXHR.url = settings.url;
            },
            error: function (jqXHR, textStatus, errorThrown) {
                alert("\n資料擷取剖析錯誤 !\n" + jqXHR.url);
            }
        });
        return maxno;
    }
   
    //[上傳]
    function UploadAttach(pno) {
        if ($.trim($("#cust_seq").val()) == "") {
            alert("請輸入客戶編號，才可上傳附件!");
            return false;
        }
        //nfilename = reg.cust_area.value & "AP-" & apsqlno & "-" & max_attach_no
        //Custdb_file\N\016\016203\NAPR-019663-5.txt
        //var tfolder = $("#" + $("#uploadfield").val() + "_path").val();
        var apsqlno = padLeft($("#apsqlno").val(), 6, '0');
        var tfolder = $("#cust_area").val() + "/" + apsqlno.substring(0, 3) + "/" + apsqlno;
        var max_attach_no = getmax_attach_no();
        var subpno = CInt(pno) - 1;
        if (CInt(pno) > 1) {
            if ($("#attach_name_" + subpno).val() != "") {
                if (max_attach_no == $("#attach_no_"+subpno).val()) {
                    max_attach_no++;
                }
            }
        }
        


        var nfilename = $("#cust_area").val() + "APR-" + apsqlno + "-" + max_attach_no;

        var url = getRootPath() + "/sub/upload_win_file_new.aspx?type=custdb_file" +
              //"&branch=" + $.trim($("#cust_area").val()) +
              "&source_name=attach_source_name_" + pno +
              "&nfilename=" + nfilename +
              "&draw_file=" + nfilename +
              "&folder_name=" + tfolder +
              "&form_name=attach_path_" + pno +
              "&size_name=attach_size_" + pno +
              "&file_name=attach_name_" + pno +
              "&in_date=attach_in_date_" + pno +
              "&in_scode=attach_in_scode_" + pno +
              "&in_scodenm=attach_in_scodenm_" + pno +
              "&btnname=btnattach_" + pno +
              "&attach_no=attach_no_" + pno +//傳回max_attach_no用
              "&filename_flag=source_name2";
        window.open(url, "", "width=700 height=600 top=50 left=50 toolbar=no, menubar=no, location=no, directories=no resizeable=no status=no scrollbars=yes");


        $("#attach_no_" + pno).val(max_attach_no);
        $("#attach_in_scodenm_" + pno).val("<%=Sys.GetSession("sc_name")%>");

    }//[上傳]


    //[刪除]
    function DelAttach(pno) {
        var fld = $("#uploadfield").val();
        //if (document.getElementById(fld).value == "") {
        //    alert("無檔案可刪除!!");
        //    return false;
        //}
        if ($("#attach_path_" + pno).val() == "") {
            alert("無檔案可刪除!!");
            return false;
        }

        var file = $("#attach_path_" + pno).val();
        var tname = document.getElementById(fld + "_name_"+pno).value;
        if (file.indexOf(".") > -1) {	//路徑包含檔案
            if (file.indexOf("/") > -1) {	//當檔名前的符號為/，將檔名前/改為\
                file = file.substr(0, file.lastIndexOf("/")) + "\\" + tname;
            }
        } else {
            file += "\\" + tname;
        }

        //2015/12/25for總契約書/委任書增加檢查(只取消連結不刪實體檔)
        if (document.getElementById(fld + "_apattach_sqlno_"+pno).value != "") {
           <%-- if (confirm("確定取消" + document.getElementById(fld + "_desc_"+pno).value + "連結？")) {
                document.getElementById(fld + "_apattach_sqlno_"+pno).value = "";
                $("#attach_path_" + pno).val('');
                $("#btn<%=uploadfield%>_"+pno).unlock();
            }
            return false;--%>
        }

        if (confirm("確定刪除上傳檔案？")) {
            $.ajax({
                url: getRootPath() + "/sub/del_draw_file_new.aspx",
                data: { type: "doc", draw_file: file },
                type: 'post',//刪除要用post,參數帶中文檔名時才不會有問題
                dataType: "script",
                async: false,
                cache: false,
                success: function (data) {
                    $("#attach_path_" + pno).val('');
                    document.getElementById(fld + "_name_" + pno).value = "";
                    document.getElementById(fld + "_source_name_" + pno).value = "";
                    document.getElementById(fld + "_desc_" + pno).value = "";
                    document.getElementById(fld + "_size_" + pno).value = "";

                    document.getElementById("attach_flag_"+pno).value = "D";
                    $("#btn<%=uploadfield%>_"+pno).unlock();
                },
                error: function (xhr) {
                    $("#dialog").html("<a href='" + this.url + "' target='_new'>刪除檔案失敗！<u>(點此顯示詳細訊息)</u></a><hr>" + xhr.responseText);
                    $("#dialog").dialog({ title: '刪除檔案失敗！', modal: true, maxHeight: 500, width: "90%" });
                }
            });


        }
        else {
            return false;
        }
    }

    //檢視
    function PreviewAttach(pno) {
        var fld = $("#uploadfield").val();
        if ($("#" + fld + "_name_"+pno).val() == "") {
            alert("請先上傳附件 !!");
            return false;
        }

        //var file = document.getElementById(fld).value;
        //var tname = document.getElementById(fld + "_name_"+pno).value;
        //if (file.indexOf(".") > -1) {	//路徑包含檔案
        //    if (file.indexOf("/") > -1) {	//當檔名前的符號為/，將檔名前/改為\
        //        file = file.substr(0, file.lastIndexOf("/")) + "\\" + tname;
        //    }
        //} else {
        //    file += "\\" + tname;
        //}
        var file = "";
        if ('<%=Sys.GetSession("dept")%>' == "P") {
            file = Path2Nbrp($("#attach_path_" + pno).val());
        }
        else {
            file = Path2Nbtbrt($("#attach_path_" + pno).val());
        }

        window.open(file);
    }//檢視

</script>

