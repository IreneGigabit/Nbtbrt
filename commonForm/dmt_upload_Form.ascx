﻿<%@ Control Language="C#" ClassName="dmt_upload_form" %>
<%@ Import Namespace = "System.Collections.Generic"%>

<script runat="server">
    //父控制項傳入的參數
    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    public Dictionary<string, string> Lock = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    public Dictionary<string, string> Hide = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    public int HTProgRight = 0;

    public string uploadfield = "attach";
    public string uploadsource = "";

    protected string submitTask = "";
    protected string prgid = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string SQL = "";
    protected string uploadtype = "";
    protected string source = "";
    protected string epath = "";
    protected string StrFormRemark = "";
    
    protected string seq = "";
    protected string seq1 = "";
    //protected string step_grade = "";
    //protected string in_no = "";
    //protected string case_no = "";
    //protected string erpt_code = "";
    
    protected string html_doc = "";
    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");

        submitTask = (Request["submittask"] ?? "").Trim();
        uploadtype = (Request["uploadtype"] ?? "").ToLower();
        source = Request["source"] ?? "";
        prgid = prgid.ToLower();
        seq = ReqVal.TryGet("seq", ReqVal.TryGet("aseq"));
        seq1 = ReqVal.TryGet("seq1", ReqVal.TryGet("aseq1"));
        //step_grade = (Request["step_grade"] ?? "");
        //in_no = (Request["in_no"] ?? "");
        //case_no = (Request["case_no"] ?? "");
        
        if (uploadtype == "case") {//表示從接洽記錄上傳
            epath = "doc/case";
            uploadsource = "CASE";
        } else {
            var efseq=seq.PadLeft(5,'0');
	        epath="doc/"+seq1+"/"+efseq.Left(3)+"/"+efseq;
            if (source != "") uploadsource = source;
        }
            
        if (submitTask == "D" || submitTask == "Q" || submitTask == "R") {
	        Lock["Qup"] = "Lock";
        } else {
            Lock["Qup"] = "";
        }

        string pwhere = "";
        if (submitTask != "Q") pwhere += "and (mark is null or mark<>'B')";//維護時只顯示區所文件種類
        //if (erpt_code != "") pwhere += "and (remark is null or remark like '%" + erpt_code + "%'";
        html_doc = Sys.getCustCode("TDOC", pwhere, "sortfld").Option("{cust_code}", "{code_name}", " v1='{mark1}'", true);

        PageLayout();
        this.DataBind();
    }

    private void PageLayout() {
        //2010/7/26承辦交辦發文不需顯示 
        if (submitTask == "A" && prgid != "brt63") {
            StrFormRemark += "<div style='color:blue;'>\n";
            StrFormRemark += "<br>備註：\n";
            StrFormRemark += "<br>※檔案上傳之後，最後記得按下「新增存檔」！\n";
            if (uploadsource == "CASE") {
                StrFormRemark += "<br>※若文件檔案要交辦專案室，請勾選「交辦專案室」；若不需，請取消勾選，則專案室即不會看到本項文件檔案\n";
            }
            StrFormRemark += "<br>※僅有以<font color=red>電子送件</font>之[<font color=red>官發</font>]且勾選「電子送件文件檔」會將文件檔更新至商標電子送件區\n";
            StrFormRemark += "<br>※若文件檔案為電子送件所需文件，請勾選「電子送件文件檔」；若不需，請取消勾選\n";
            StrFormRemark += "</div>\n";
        } else {
            if (uploadsource == "CASE" && prgid != "brt81") {
                StrFormRemark += "<div style='color:blue;'>\n";
                StrFormRemark += "<br>備註：<br>\n";
                StrFormRemark += "<br>※若文件檔案要交辦專案室，請勾選「交辦專案室」；若不需，請取消勾選，則專案室即不會看到本項文件檔案\n";
                StrFormRemark += "</div>\n";
            }
        }
    }
</script>

<%=Sys.GetAscxPath(this.AppRelativeVirtualPath)%>
<input type="hidden" id="<%#uploadfield%>_maxAttach_no" name="<%#uploadfield%>_maxAttach_no" value=""><!--目前table裡最大值-->
<input type="hidden" id="<%#uploadfield%>_attach_cnt" name="<%#uploadfield%>_attach_cnt" value=""><!--目前table裡有效筆數-->
<input type="hidden" id="<%#uploadfield%>_filenum" name="<%#uploadfield%>_filenum" value="0"><!--畫面顯示NO-->
<input type="hidden" id="<%#uploadfield%>_path" name="<%#uploadfield%>_path" value="<%=epath%>"><!--存檔路徑-->
<input type="hidden" id="uploadfield" name="uploadfield" value="<%#uploadfield%>">
<input type="hidden" id="maxattach_no" name="maxattach_no" value="0"><!--table+畫面顯示NO-->
<input type="hidden" id="attach_seq" name="attach_seq">
<input type="hidden" id="attach_seq1" name="attach_seq1">
<input type="hidden" id="attach_step_grade" name="attach_step_grade">
<input type="hidden" id="attach_in_no" name="attach_in_no">
<input type="hidden" id="attach_case_no" name="attach_case_no">
<input type="hidden" id="uploadsource" name="uploadsource" value="<%=uploadsource%>"><!--為了入dmt_attach.source的欄位-->
<TABLE id='tabfile<%#uploadfield%>' border=0 class="bluetable" cellspacing=1 cellpadding=2 width="100%">
    <thead>
	    <TR>
		    <TD align=center colspan=5 class=lightbluetable1>
                <span id="uploadTitle" style="color:white">相&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;關&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;文&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;件&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;上&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;傳</span>
            </TD>
        </TR>
    </thead>
    <script type="text/html" id="upload_template"><!--文件上傳樣板-->
		<TR class="tr_brattach_##">
			<TD class=lightbluetable align=center>
		        文件檔案<input type=text id='<%#uploadfield%>_filenum##' name='<%#uploadfield%>_filenum##' class=sedit readonly size=2 value='##'>.
			</TD>
			<TD class=sfont9 colspan="2" align="left">
                檔案名稱：<input type=text id='<%#uploadfield%>_name_##' name='<%#uploadfield%>_name_##' class=sedit readonly size=50 maxlength=50>
                <input type=button id='btn<%#uploadfield%>_##' name='btn<%#uploadfield%>_##' class='cbutton <%=Lock.TryGet("Qup")%>' value='上傳' onclick="upload_form.UploadAttach('##')">
                <input type=button id='btn<%#uploadfield%>_D_##' name='btn<%#uploadfield%>_D_##' class='cbutton <%=Lock.TryGet("Qup")%>' value='刪除' onclick="upload_form.DelAttach('##')">
                <input type=button id='btn<%#uploadfield%>_S_##' name='btn<%#uploadfield%>_S_##' class='cbutton' value='檢視' onclick="upload_form.PreviewAttach('##')">
                <input type='hidden' id='<%#uploadfield%>_size_##' name='<%#uploadfield%>_size_##'>
                <input type='hidden' id='<%#uploadfield%>_##' name='<%#uploadfield%>_##'>
                <input type='hidden' id='tstep_grade_##' name='tstep_grade_##'>
                <input type='hidden' id='attach_sqlno_##' name='attach_sqlno_##'>
                <input type='hidden' id='attach_flag_##' name='attach_flag_##'>
                <span id="span_source_##"><BR>原始檔名：<input type='text' id='source_name_##' name='source_name_##' class=sedit readonly size=50></span>
                <input type='hidden' id='attach_no_##' name='attach_no_##' value='##'>
                <input type='hidden' id='old_<%#uploadfield%>_name_##' name='old_<%#uploadfield%>_name_##'>
                <input type='hidden' id='doc_type_mark_##' name='doc_type_mark_##'>
                <input type='hidden' id='attach_flagtran_##' name='attach_flagtran_##'><!--2014/12/13柳月for異動作業增加-->
                <input type='hidden' id='tran_sqlno_##' name='tran_sqlno_##' value='0'><!--2014/12/13柳月for異動作業增加-->
                <input type='hidden' id='<%#uploadfield%>_apattach_sqlno_##' name='<%#uploadfield%>_apattach_sqlno_##'><!--2015/12/25柳月for總契約書/委任書作業增加-->
                <input type='hidden' id='attach_old_branch_##' name='attach_old_branch_##'>
                <br>檔案說明：<select id='doc_type_##' name='doc_type_##' class="<%=Lock.TryGet("Qup")%>" onchange="upload_form.getfiledoc('##')"><%#html_doc%></select>
                <input type=text id='<%#uploadfield%>_desc_##' name='<%#uploadfield%>_desc_##' class="<%=Lock.TryGet("Qup")%>" size=50 maxlength=60 onblur="fChkDataLen(this,'檔案說明')" >
                <label id="span_branch_##" style="display:none"><br /><input type=checkbox id='<%#uploadfield%>_branch_##' name='<%#uploadfield%>_branch_##' class="<%=Lock.TryGet("Qup")%>" value='B'><font color='blue'>交辦專案室</font></label>
                <label id="span_edoc_##" style="display:none"><br /><input type=checkbox id='doc_flag_##' name='doc_flag_##' class="<%=Lock.TryGet("Qup")%>" value='E'><font color='blue'>電子送件文件檔(pdf)</font></label>
			</TD>
		</TR>
    </script>
    <tbody></tbody>
</table>

<%#StrFormRemark%>

<script type="text/html" id="upload_btn">
    <TR>
		<TD class=whitetablebg align=center colspan=5>
            <input type="button" value="多檔上傳" class="greenbutton <%=Lock.TryGet("Qup")%>" id="multi_upload_button" name="multi_upload_button" onclick="upload_form.mAppendFile()">
			<!--input type="button" value ="增加一筆" class="cbutton <%=Lock.TryGet("Qup")%>" id=file_Add_button name=file_Add_button onclick="upload_form.appendFile()"-->
			<input type="button" value ="減少一筆" class="cbutton <%=Lock.TryGet("Qup")%>" id=file_Del_button name=file_Del_button onclick="upload_form.deleteFile()">
		</TD>
	</TR>
</script>

<script language="javascript" type="text/javascript">
    var upload_form = {};
    upload_form.uploadtype = "<%#uploadtype%>";

    upload_form.init = function () {
        var fld = $("#uploadfield").val();

        upload_form.emptyFile();//清空附件清單

        if (main.prgid == "brt81") {
            $("#uploadTitle").html("交&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;辦&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;相&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;關&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;文&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;件");
        } else {
            if (main.prgid != "brt62" || (main.prgid == "brt62" && main.submittask == "A")) {
                $("#tabfile" + fld + ">thead").append($("#upload_btn").text());//增加按鈕
            }
        }
    }

    //附件資料append到畫面
    upload_form.bind = function (jData, showSourceName) {
        var fld = $("#uploadfield").val();

        $.each(jData, function (i, item) {
            upload_form.appendFile();//增加一筆
            var nRow = $("#" + fld + "_filenum").val();
            $("#" + fld + "_name_" + nRow).val(item.attach_name);
            $("#old_" + fld + "_name_" + nRow).val(item.attach_name);
            $("#" + fld + "_" + nRow).val(item.attach_path);
            $("#doc_type_" + nRow + " option[value='" + item.doc_type + "']").prop("selected", true);
            $("#" + fld + "_desc_" + nRow).val(item.attach_desc);
            $("#" + fld + "_size_" + nRow).val(item.attach_size);
            $("#attach_sqlno_" + nRow).val(item.attach_sqlno);
            $("#" + fld + "_apattach_sqlno_" + nRow).val(item.apattach_sqlno);//總契約書/委任書流水號
            $("#attach_flag_" + nRow).val("U");//維護時判斷是否要更名，即A表示新上傳的文件
            $("#btn" + fld + "_" + nRow).prop("disabled", true);
            $("input[name='" + fld + "_branch_" + nRow + "'][value='" + item.attach_branch + "']").prop("checked", true);//交辦專案室
            if (showSourceName == false) {
                $("#span_source_" + nRow).hide();
            } else {
                $("#source_name_" + nRow).val(item.source_name || "");
            }
            $("#attach_no_" + nRow).val(item.attach_no);
            $("#attach_flagtran_" + nRow).val(item.attach_flagtran);//異動作業上傳註記Y

            $("#doc_type_mark_").val(item.doc_type_mark);
            $("#tran_sqlno_" + nRow).val(item.tran_sqlno);//異動作業流水號
            $("#maxattach_no").val(Math.max(CInt(item.attach_no), CInt($("#maxattach_no").val())));

            $("input[name='doc_flag_" + nRow + "'][value='" + item.doc_flag + "']").prop("checked", true);//電子送件文件檔(pdf)
        });

        if (main.prgid == "brta38" || main.prgid == "brt63") {
            if (CInt($("#att_sqlno").val()) > 0) {
                $("#file_Del_button").hide();//官發確認
            }
        }
    }

    //[多檔上傳]
    upload_form.mAppendFile = function (nRow) {
        var fld = $("#uploadfield").val();

        if (main.prgid == "brt62" && main.submittask == "A") {//文件上傳作業
            if ($("#seq").val() == "" || $("#seq1").val() == "") {
                alert("請輸入案件編號!!");
                return false;
            }
            if ($("#step_grade").val() == "0" && $("#" + fld + "_filenum").val() == "0") {
                var ans = confirm("對應進度0，是否確定將文件上傳至進度0？若不是進度0，請先點選「否」再點選「查詢」以重新選取對應進度後再上傳");
                if (ans == false) {
                    $("#btnquery").focus();
                    return false;
                }
            }
        }

        var tfolder = $("#" + fld + "_path").val();//存檔路徑
        var nfilename = "";//"KT-" + $("#opt_no").val() + "-{{attach_no}}m";//新檔名格式

        var urlasp = getRootPath() + "/sub/multi_upload_file.aspx?type=doc";
        urlasp += "&attach_tablename=dmt_attach&filename_flag=source_name";
        urlasp += "&folder_name=" + tfolder + "&nfilename=" + nfilename;
        urlasp += "&syscode=&branch=&dept=&seq=&seq1=&step_grade=";//attachtemp的key值
        urlasp += "&apcode=&prgid=<%=prgid%>";//remark用
        var mm = window.open(urlasp, "mupload", "width=700 height=600 top=50 left=150 toolbar=no, menubar=no, location=no, directories=no resizeable=no status=yes scrollbars=yes");
        mm.focus();
        //$("#dialog").dialog({
        //    autoOpen: false, width: 700, height: 700,
        //    modal: true,
        //    open: function (ev, ui) {
        //        $('#myIframe').attr('src', urlasp);
        //    }
        //});
        //$('#dialog').dialog('open');
    }

    //多檔上傳後回傳資料顯示於畫面上
    function uploadSuccess(rvalue) {
        var fld = $("#uploadfield").val();
        if (rvalue.msg == "") {//沒有錯誤或警告
            upload_form.appendFile();
            //傳回:檔案名稱，虛擬完整路徑，原始檔名，檔案大小，attach_no
            var listno = $("#" + fld + "_filenum").val();
            var attach_no = rvalue.attach_no;
            if ((attach_no || "") == "") attach_no = CInt($("#maxattach_no").val()) + 1;
            $("#" + fld + "_maxAttach_no").val(attach_no);
            $("#" + fld + "_name_" + listno).val(rvalue.name);
            $("#" + fld + "_size_" + listno).val(rvalue.size);
            $("#" + fld + "_" + listno).val(rvalue.dir);
            $("#source_name_" + listno).val(rvalue.source);
            $("#" + fld + "_attach_no_" + listno).val(attach_no);
            $("#btn" + fld + "_" + listno).prop("disabled", true);

            //先判斷原本資料是否有attach_sqlno,若有表示修改,若沒有表示新增
            if ($("#attach_sqlno_" + listno).val() != "") {
                $("#attach_flag_" + listno).val("U");//修改
            } else {
                $("#attach_flag_" + listno).val("A");//新增
            }
        }
    }

    //清空附件清單
    upload_form.emptyFile = function () {
        var fld = $("#uploadfield").val();
        $("#tabfile" + fld + ">thead tr:gt(0)").remove();//清空按鈕
        $("#tabfile" + fld + ">tbody").empty();
        $("#" + fld + "_filenum").val("0");
    }

    //[增加一筆]
    upload_form.appendFile = function () {
        var fld = $("#uploadfield").val();

        //多檔上傳已觸發過
        //if (main.prgid == "brt62" && main.submittask == "A") {//文件上傳作業
        //    if ($("#seq").val() == "" || $("#seq1").val() == "") {
        //        alert("請輸入案件編號!!");
        //        return false;
        //    }
        //    if ($("#step_grade").val() == "0" && $("#" + fld + "_filenum").val() == "0") {
        //        var ans = confirm("對應進度0，是否確定將文件上傳至進度0？若不是進度0，請先點選「否」再點選「查詢」以重新選取對應進度後再上傳");
        //        if (ans == false) {
        //            $("#btnquery").focus();
        //            return false;
        //        }
        //    }
        //}

        var nRow = CInt($("#" + fld + "_filenum").val()) + 1;//畫面顯示NO
        $("#maxattach_no").val(CInt($("#maxattach_no").val()) + 1);//table+畫面顯示 NO

        //複製樣板
        var copyStr = $("#tabfile" + fld + ">#upload_template").text() || "";
        copyStr = copyStr.replace(/##/g, nRow);
        $("#tabfile" + fld + ">tbody").append(copyStr);
        $("#" + fld + "_filenum").val(nRow);
        $("#attach_no_" + nRow).val($("#maxattach_no").val());//dmt_attach.attach_no

        if ($("#prgid").val() == "brta38") {
            $("#span_source_" + nRow).show();//原始檔名
        }
        if ($("#uploadsource").val() == "CASE") {
            $("#span_branch_" + nRow).show();//交辦專案室
        } else {
            //不是發文畫面會出錯,增加判斷
            if ($("#cgrs").val() == "GS") {
                //if (document.getElementsByName("cgrs").length > 0 && document.getElementById("cgrs").value == "GS") {
                $("#span_edoc_" + nRow).show();//電子送件文件檔
                //}
            }
        }

        $("#attach_flagtran_" + nRow).val("N");
        if (upload_form.uploadtype == "case") {
            if ($("#prgid").val() == "brt18" || $("#prgid").val() == "brt63") {//承辦交辦專案室,2010/7/22修改承辦交辦發文作業prgid=brt63
                $("#" + fld + "_branch_" + nRow).prop("check", true);//□交辦專案室
            } else if ($("#prgid").val() == "brt18") {
                $("#attach_flagtran_" + nRow).val("Y");
            }
        } else {
            if ($("#prgid").val() == "brt63") {	//2012/12/24修改承辦交辦發文作業prgid=brt63
                if ($("#send_way").val() == "E") {
                    $("#doc_flag_" + nRow).prop("checked", true);//□電子送件文件檔(pdf)
                }
            }
        }
        $('#tr_brattach_' + nRow + ' .Lock').lock();
    }

    //[減少一筆]
    upload_form.deleteFile = function () {
        var fld = $("#uploadfield").val();
        var tfilenum = CInt($("#" + fld + "_filenum").val());//畫面顯示NO
        if (tfilenum > 0) {
            if ($("#" + fld + "_name_" + tfilenum).val() == "") {
                $(".tr_brattach_" + tfilenum).remove();
                $("#" + fld + "_filenum").val(Math.max(0, tfilenum - 1));
            } else {
                //檔案已存在要刪除
                if (upload_form.DelAttach(tfilenum) == true) {
                    //先不刪除,而是使用隱藏方式
                    $(".tr_brattach_" + tfilenum).hide();
                }
            }
        }
    }

    //form鎖定
    upload_form.uploadreadonly = function (pctrl) {
        var fld = $("#uploadfield").val();
        var treadonly = false;
        if (pctrl == "Y") {
            treadonly = true
            $("#multi_upload_button,#file_Del_button").hide();
        }
        for (var n = 1; n <= CInt($("#" + fld + "_filenum").val()) ; n++) {
            upload_form.uploadreadonly_one(n);
        }
    }

    //單行欄位鎖定
    upload_form.uploadreadonly_one = function (nRow) {
        var fld = $("#uploadfield").val();
        $("#" + fld + "_desc_" + nRow).lock();
        $("#btn" + fld + "_" + nRow).hide();
        $("#btn" + fld + "_D_" + nRow).hide();
        $("#doc_type_" + nRow).lock();
        $("#"+fld+"_branch_" + nRow).lock();
    }

    //[上傳]
    upload_form.UploadAttach = function (nRow) {
        var tfolder = $("#" + $("#uploadfield").val() + "_path").val();
        var url = getRootPath() + "/sub/upload_win_file_new.aspx?type=doc" +
            "&attach_sqlno_name=attach_sqlno_" + nRow +
            "&folder_name=" + tfolder +
            "&file_name=" + $("#uploadfield").val() + "_name_" + nRow +
            "&size_name=" + $("#uploadfield").val() + "_size_" + nRow +
            "&dir_name=" + $("#uploadfield").val() + "_" + nRow +
            "&source_name=source_name_" + nRow +
            "&attach_flag_name=attach_flag_" + nRow +
            "&prgid=<%=prgid%>" +
            "&btnname=btn" + $("#uploadfield").val() + "_" + nRow +
            "&filename_flag=source_name";
        window.open(url, "dmtupload", "width=700 height=600 top=50 left=50 toolbar=no, menubar=no, location=no, directories=no resizeable=no status=no scrollbars=yes");
    }

    //[刪除]
    upload_form.DelAttach = function (nRow) {
        var fld = $("#uploadfield").val();

        if (document.getElementById(fld + "_" + nRow).value == "") {
            alert("無檔案可刪除!!");
            return false;
        }
        var file = document.getElementById(fld + "_" + nRow).value;
        var tname = document.getElementById(fld + "_name_" + nRow).value;
        if (file.indexOf(".") > -1) {	//路徑包含檔案
            if (file.indexOf("/") > -1) {	//當檔名前的符號為/，將檔名前/改為\
                file = file.substr(0, file.lastIndexOf("/")) + "\\" + tname;
            }
        } else {
            file += "\\" + tname;
        }
        
        //2015/12/25for總契約書/委任書增加檢查(只取消連結不刪實體檔)
        if (document.getElementById(fld + "_apattach_sqlno_" + nRow).value != "") {
            if (confirm("確定取消" + document.getElementById(fld + "_desc_" + nRow).value + "連結？")) {
                document.getElementById(fld + "_apattach_sqlno_" + nRow).value = "";
                document.getElementById(fld + "_name_" + nRow).value = "";
                document.getElementById("source_name_" + nRow).value = "";
                document.getElementById(fld + "_desc_" + nRow).value = "";
                document.getElementById(fld + "_" + nRow).value = "";
                document.getElementById(fld + "_size_" + nRow).value = "";
                document.getElementById("doc_type_" + nRow).value = "";
                document.getElementById("btn" + fld + "_" + nRow).disabled = false;
                document.getElementById("attach_flag_" + nRow).value = "D";
            }
            return false;
        }

        if (confirm("確定刪除上傳檔案？")) {
            $.ajax({
                url: getRootPath() + "/sub/del_draw_file_new.aspx",
                data: { type: "doc", draw_file: file },
                type: 'post',//刪除要用post,參數帶中文檔名時才不會有問題
                dataType: "script",
                async: false,
                cache: false,
                success: function(data) {
                    document.getElementById(fld + "_name_" + nRow).value = "";
                    document.getElementById("source_name_" + nRow).value = "";
                    document.getElementById(fld + "_desc_" + nRow).value = "";
                    document.getElementById(fld + "_" + nRow).value = "";
                    document.getElementById(fld + "_size_" + nRow).value = "";
                    document.getElementById("doc_type_" + nRow).value = "";
                    document.getElementById("btn" + fld + "_" + nRow).disabled = false;
                    document.getElementById("attach_flag_" + nRow).value = "D";
                },
                error: function (xhr) { 
                    $("#dialog").html("<a href='" + this.url + "' target='_new'>刪除檔案失敗！<u>(點此顯示詳細訊息)</u></a><hr>"+xhr.responseText);
                    $("#dialog").dialog({ title: '刪除檔案失敗！', modal: true, maxHeight: 500,width: "90%" });
                }
            });
            
            //window.open(getRootPath() + "/sub/del_draw_file_new.aspx?type=doc&draw_file=" + file, "myWindowOneN", "width=10 height=10 top=1000 left=1000 toolbar=no, menubar=no, location=no, directories=no resizeable=no status=no scrollbar=no");
            //document.getElementById(fld + "_name_" + nRow).value = "";
            //document.getElementById("source_name_" + nRow).value = "";
            //document.getElementById(fld + "_desc_" + nRow).value = "";
            //document.getElementById(fld + "_" + nRow).value = "";
            //document.getElementById(fld + "_size_" + nRow).value = "";
            //document.getElementById("doc_type_" + nRow).value = "";
            //document.getElementById("btn" + fld + "_" + nRow).disabled = false;
            //document.getElementById("attach_flag_" + nRow).value = "D";
            
        } else {
            document.getElementById(fld + "_desc_" + nRow).focus();
            return false;
        }
    }

    //檢視
    upload_form.PreviewAttach = function (nRow) {
        var fld = $("#uploadfield").val();
        if ($("#" + fld + "_name_" + nRow).val() == "") {
            alert("請先上傳附件 !!");
            return false;
        }

        var file = document.getElementById(fld + "_" + nRow).value;
        var tname = document.getElementById(fld + "_name_" + nRow).value;
        if (file.indexOf(".") > -1) {	//路徑包含檔案
            if (file.indexOf("/") > -1) {	//當檔名前的符號為/，將檔名前/改為\
                file = file.substr(0, file.lastIndexOf("/")) + "\\" + tname;
            }
        } else {
            file += "\\" + tname;
        }

        window.open(file);
    }

    //檔案說明
    upload_form.getfiledoc = function (nRow) {
        var fld = $("#uploadfield").val();
        if ($("#doc_type_" + nRow).val() == "") {
            $("#doc_type_mark_" + nRow).val("");
            return false;
        }

        var dname = $("#" + fld + "_desc_" + nRow).val().trim();
        if (dname != "") dname += "、";
        dname += $("#doc_type_" + nRow + " :selected").text();
        $("#" + fld + "_desc_" + nRow).val(dname);

        //抓取文件種類之mark1說明，for電子送件copy時用原始檔名或更名
        $("#doc_type_mark_" + nRow).val($("#doc_type_" + nRow + " :selected").attr("v1"));
    }
</script>
