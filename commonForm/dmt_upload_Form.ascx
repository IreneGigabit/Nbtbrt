<%@ Control Language="C#" ClassName="dmt_upload_form" %>
<%@ Import Namespace = "System.Collections.Generic"%>

<script runat="server">
    //父控制項傳入的參數
    public Dictionary<string, string> Lock = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    public string uploadfield = "attach";
    public string seq = "";
    public string seq1 = "";
    public string step_grade = "";
    public string in_no = "";
    public string case_no = "";
    public string erpt_code = "";

    protected string submitTask = "";
    protected string prgid = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string SQL = "";
    protected string uploadtype = "";
    protected string source = "";
    protected string epath = "";
    protected string uploadsource = "";
    
    protected string html_doc = "";
    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        submitTask = (Request["submittask"] ?? "").Trim();
        uploadtype = Request["uploadtype"] ?? "";
        source = Request["source"] ?? "";
        
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
        if (erpt_code != "") pwhere += "and (remark is null or remark like '%" + erpt_code + "%'";
        html_doc = Funcs.getCustCode("TDOC", pwhere, "sortfld").Option("{cust_code}", "{cust_code}---{code_name}");

        this.DataBind();
    }
</script>

<%=Sys.GetAscxPath(this)%>
<input type="text" id="<%#uploadfield%>_maxAttach_no" name="<%#uploadfield%>_maxAttach_no" value=""><!--目前table裡最大值-->
<input type="text" id="<%#uploadfield%>_attach_cnt" name="<%#uploadfield%>_attach_cnt" value=""><!--目前table裡有效筆數-->
<input type="text" id="<%#uploadfield%>_filenum" name="<%#uploadfield%>_filenum" value="0">
<input type="text" id="<%#uploadfield%>_path" name="<%#uploadfield%>_path" value="<%=epath%>">
<input type="text" id="uploadfield" name="uploadfield" value="<%#uploadfield%>">
<input type="text" id="maxattach_no" name="maxattach_no" value="0">
<input type="text" id="attach_seq" name="attach_seq" value="<%#seq%>">
<input type="text" id="attach_seq1" name="attach_seq1" value="<%#seq1%>">
<input type="text" id="attach_step_grade" name="attach_step_grade" value="<%#step_grade%>">
<input type="text" id="attach_in_no" name="attach_in_no" value="<%#in_no%>">
<input type="text" id="attach_case_no" name="attach_case_no" value="<%#case_no%>">
<input type="text" id="uploadsource" name="uploadsource" value="<%=uploadsource%>"><!--為了入dmt_attach.source的欄位-->
<TABLE id='tabfile<%#uploadfield%>' border=0 class="bluetable" cellspacing=1 cellpadding=2 width="100%">
    <thead>
	    <TR>
		    <TD align=center colspan=5 class=lightbluetable1>
                <span id="uploadTitle" style="color:white">相&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;關&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;文&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;件&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;上&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;傳</span>
            </TD>
        </TR>
    </thead>
    <tfoot style="display:none">
		<TR>
			<TD class=lightbluetable align=center>
		        文件檔案<input type=text name='<%#uploadfield%>_filenum##' class="Lock" size=2 value='##'>.
			</TD>
			<TD class=sfont9 colspan="2" align="left">
                檔案名稱：<input type=text id='<%#uploadfield%>_name_##' name='<%#uploadfield%>_name_##' class="Lock" size=50 maxlength=50>
                <input type=button name='btn<%#uploadfield%>_##' class='cbutton <%=Lock.TryGet("Qup")%>' value='上傳' onclick="upload_form.UploadAttach('##')">
                <input type=button name='btn<%#uploadfield%>_D_##' class='cbutton <%=Lock.TryGet("Qup")%>' value='刪除' onclick="upload_form.DelAttach('##')">
                <input type=button name='btn<%#uploadfield%>_S_##' class='cbutton' value='檢視' onclick="upload_form.PreviewAttach('##')">
                <input type='hidden' id='<%#uploadfield%>_size_##' name='<%#uploadfield%>_size_##'>
                <input type='hidden' id='<%#uploadfield%>_##' name='<%#uploadfield%>_##'>
                <input type='hidden' id='tstep_grade_##' name='tstep_grade_##'>
                <input type='hidden' id='attach_sqlno_##' name='attach_sqlno_##'>
                <input type='hidden' id='attach_flag_##' name='attach_flag_##'>
                <BR>原始檔名：<input type='text' id='source_name_##' name='source_name_##' class="Lock" size=50>
                <input type='hidden' id='attach_no_##' name='attach_no_##' value='##'>
                <input type='hidden' id='old_<%#uploadfield%>_name_##' name='old_<%#uploadfield%>_name_##'>
                <input type='hidden' id='doc_type_mark_##' name='doc_type_mark_##'>
                <input type='hidden' id='attach_flagtran_##' name='attach_flagtran_##'><!--2014/12/13柳月for異動作業增加-->
                <input type='hidden' id='tran_sqlno_##' name='tran_sqlno_##'><!--2014/12/13柳月for異動作業增加-->
                <input type='hidden' id='<%#uploadfield%>_apattach_sqlno_##' name='<%#uploadfield%>_apattach_sqlno_##'><!--2015/12/25柳月for總契約書/委任書作業增加-->
                <input type='hidden' id='attach_old_branch_##' name='attach_old_branch_##'>
                <br>檔案說明：<select id='doc_type_##' name='doc_type_##' class="<%=Lock.TryGet("Qup")%>" onchange="getfiledoc_code('##')"><%#html_doc%></select>
                <input type=text id='<%#uploadfield%>_desc_##' name='<%#uploadfield%>_desc_##' class="<%=Lock.TryGet("Qup")%>" size=50 maxlength=60 onblur="fChkDataLen(this,'檔案說明')" >
                <input type=checkbox id='<%#uploadfield%>_branch_##' name='<%#uploadfield%>_branch_##' class="<%=Lock.TryGet("Qup")%>" value='B'><font color='blue'>交辦專案室</font>
                <input type=checkbox id='doc_flag_##' name='doc_flag_##' class="<%=Lock.TryGet("Qup")%>" value='E'><font color='blue'>電子送件文件檔(pdf)</font>
                <input type='hidden' id='bropen_path_##' name='bropen_path_##'>
			</TD>
		</TR>
    </tfoot>
    <tbody></tbody>
</table>

<script type="text/html" id="upload_btn">
    <TR>
		<TD class=whitetablebg align=center colspan=5>
			<input type=button value ="增加一筆" class="cbutton <%=Lock.TryGet("Qup")%>" id=file_Add_button name=file_Add_button onclick="upload_form.appendFile()">
			<input type=button value ="減少一筆" class="cbutton <%=Lock.TryGet("Qup")%>" id=file_Del_button name=file_Del_button onclick="upload_form.deleteFile()">
		</TD>
	</TR>
</script>

<script language="javascript" type="text/javascript">
    var upload_form = {};
    upload_form.prgid = "<%#prgid%>";
    upload_form.submittask = "<%#submitTask%>";
    upload_form.uploadtype = "<%#uploadtype%>";
    upload_form.init = function () {
        var fld = $("#uploadfield").val();

        if (upload_form.prgid == "brt81") {
            $("#uploadTitle").html("交&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;辦&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;相&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;關&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;文&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;件");
        } else {
            if (upload_form.prgid != "brt62" || (upload_form.prgid == "brt62" && upload_form.submittask == "A")) {
                $("#tabfile" + fld + ">thead").append($("#upload_btn").text());//增加按鈕
            }
        }

        $("#tabfile" + fld + ">tbody").empty();

        //從接洽記錄上傳
        if (upload_form.uploadtype == "case") {
            //非異動上傳作業
            $.each(main.brdmt_attach, function (i, item) {
                //增加一筆
                upload_form.appendFile();
                //填資料
                var nRow = $("#brdmt_filenum").val();
                $("#" + fld + "_name_" + nRow).val(item.attach_name);
                $("#old_" + fld + "_name_" + nRow).val(item.attach_name);
                $("#" + fld + "_" + nRow).val(item.attach_path);
                $("#doc_type_" + nRow).val(item.doc_type);
                $("#" + fld + "_desc_" + nRow).val(item.attach_desc);
                $("#" + fld + "_size_" + nRow).val(item.attach_size);
                $("#attach_sqlno_" + nRow).val(item.attach_sqlno);
                $("#source_name_" + nRow).val(item.source_name);
                $("#attach_no_" + nRow).val(item.attach_no);
                $("#attach_flag_" + nRow).val("U");//維護時判斷是否要更名，即A表示新上傳的文件
                $("#attach_flagtran_" + nRow).val(item.attach_flagtran);//異動作業上傳註記Y
                $("#tran_sqlno_" + nRow).val(item.tran_sqlno);//異動作業流水號
                $("#" + fld + "_apattach_sqlno_" + nRow).val(item.apattach_sqlno);//總契約書/委任書流水號
                $("#btn" + fld + "_" + nRow).prop("disabled",true);
                $("input[name='" + fld + "_branch_" + nRow + "'][value='" + item.attach_branch + "']").prop("checked", true);//交辦專案室
                $("#bropen_path_" + nRow).val(item.preview_path);
                if (upload_form.prgid == "brt81") {
                    if (item.attach_flagtran == "Y") {//判斷異動作業上傳，非異動作業上傳不能修改
                        if (maine.aspname == "brt81tran") {//異動作業
                            upload_form.readonly(nRow);
                        } else if (maine.aspname == "brt81show") {//異動維護作業
                            if ($("#tran_sqlno_" + nRow).val() != $("#sqlno1").val()) {//異動流水序號不同，不能修改
                                upload_form.readonly(nRow);
                            }
                        }
                    } else {
                        upload_form.readonly(nRow);
                    }
                }

                if (i == 0) {
                    $("#attach_seq").val(item.seq);
                    $("#attach_seq1").val(item.seq1);
                    $("#attach_step_grade").val(item.step_grade);
                    $("#attach_in_no").val(item.in_no);
                    $("#attach_case_no").val(item.case_no);
                }
                $("#maxattach_no").val(item.attach_no);
            });


            if (upload_form.prgid == "brt81") {
                //異動上傳作業
                $("#tabfile" + fld + ">tbody").append(
                "<TR><TD align=center colspan=5 class=lightbluetable1>"+
                "   <span style=\"color:white\">異&nbsp;&nbsp;&nbsp;動&nbsp;&nbsp;&nbsp;相&nbsp;&nbsp;&nbsp;關&nbsp;&nbsp;&nbsp;文&nbsp;&nbsp;&nbsp;件</span>" +
                "</TD></TR>");
            }
        } else {
            //案件附件
        }
    }

    //增加一筆
    upload_form.appendFile = function () {
        var fld = $("#uploadfield").val();

        if (upload_form.prgid == "brt62" && upload_form.submittask == "A") {//文件上傳作業
            if ($("#step_grade").val() == "0" && $("#" + fld + "_filenum").val() == "0") {
                var ans = confirm("對應進度0，是否確定將文件上傳至進度0？若不是進度0，請先點選「否」再點選「查詢」以重新選取對應進度後再上傳");
                if (ans == false) {
                    $("#btnquery").focus();
                    return false;
                }
            }
        }

        var nRow = parseInt($("#" + fld + "_filenum").val(), 10) + 1;//畫面顯示NO
        $("#maxattach_no").val(parseInt($("#maxattach_no").val(), 10) + 1);//table+畫面顯示 NO
        //複製樣板
        $("#tabfile" + fld + ">tfoot").each(function (i) {
            var strLine1 = $(this).html().replace(/##/g, nRow);
            $("#tabfile" + fld + ">tbody").append(strLine1);
        });
        $("#" + fld + "_filenum").val(nRow);
        $("#attach_no_" + nRow).val($("#maxattach_no").val());//dmt_attach.attach_no
    }

    upload_form.deleteFile = function () {
        var fld = $("#uploadfield").val();
        var tfilenum = parseInt($("#" + fld + "_filenum").val(), 10);//attach_no
        var tsqlnum = parseInt($("#" + fld + "_sqlnum").val(), 10);//畫面顯示NO

        if ($("#" + fld + "_name_" + tfilenum).val() == "") {
            $("#tr_opt_attach_" + tfilenum).remove();
            $("#" + fld + "_filenum").val(Math.max(0, tfilenum - 1));
            $("#" + fld + "_sqlnum").val(Math.max(0, tsqlnum - 1));
        } else {
            //檔案已存在要刪除
            //upload_form.DelOptAttach(tfilenum);
        }
    }

    //欄位鎖定
    upload_form.readonly = function (nRow) {
        $("#" + fld + "_desc_" + nRow).lock();
        $("#btn" + fld + "_" + nRow).hide();
        $("#btn" + fld + "_D_" + nRow).hide();
        $("#doc_type_" + nRow).lock();
        $("#"+fld+"_branch_" + nRow).lock();
    }

    //檢視
    upload_form.PreviewAttach = function (nRow) {
        var fld = $("#uploadfield").val();
        if ($("#" + fld + "_name_" + nRow).val() == "") {
            alert("請先上傳附件 !!");
            return false;
        }

        window.open($("#bropen_path_" + nRow).val());
    }
</script>
