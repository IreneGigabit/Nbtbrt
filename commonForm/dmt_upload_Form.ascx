<%@ Control Language="C#" ClassName="dmt_upload_form" %>
<%@ Import Namespace = "System.Collections.Generic"%>

<script runat="server">
    protected string prgid = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string SQL = "";

    public Dictionary<string, string> Lock = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    public string uploadfield = "attach";

    protected string submitTask = "";
    protected string uploadtype = "";
    
    protected string epath = "doc/case";
    protected string uploadsource = "CASE";
    
    protected string branch = "";
    protected string case_no = "";
    protected string uploadfield = "brdmt";
    protected string doc_maxAttach_no = "";
    protected string doc_attach_cnt = "";
    
    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        submitTask = (Request["submittask"] ?? "").Trim();
        uploadtype = Request["uploadtype"] ?? "";
        if (uploadtype == "case") {//表示從接洽記錄上傳
            epath = "doc/case";
            uploadsource = "CASE";
        } else {
            
        }
        branch = Request["branch"] ?? "";
        case_no = Request["case_no"] ?? "";

        
        
        if (submitTask == "D" || submitTask == "Q" || submitTask == "R") {
	        Lock["Qup"] = "Lock";
        } else {
            Lock["Qup"] = "";
        }
        
        this.DataBind();
    }
</script>

<%=Sys.GetAscxPath(this)%>
<TABLE id='tabfile' border=0 class="bluetable" cellspacing=1 cellpadding=2 width="100%">
    <thead>
	    <TR>
		    <TD align=center colspan=5 class=lightbluetable1>
                <font color=white>區&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;所&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;上&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;傳&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;文&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;件</font>
                <input type="hidden" id="brdmt_maxAttach_no" name="brdmt_maxAttach_no" value=""><!--目前table裡最大值-->
                <input type="hidden" id="brdmt_attach_cnt" name="brdmt_attach_cnt" value=""><!--目前table裡有效筆數-->
                <input type="hidden" id="brdmt_filenum" name="brdmt_filenum" value="0">
                <input type="hidden" id="brdmt_path" name="brdmt_path" value="<%=epath%>">
                <input type="hidden" id="uploadfield" name="uploadfield" value="brdmt">
                <input type="hidden" id="maxattach_no" name="maxattach_no" value="0">
                <input type="hidden" id="attach_seq" name="attach_seq">
                <input type="hidden" id="attach_seq1" name="attach_seq1">
                <input type="hidden" id="attach_step_grade" name="attach_step_grade" value="0">
                <input type="hidden" id="attach_in_no" name="attach_in_no">
                <input type="hidden" id="attach_case_no" name="attach_case_no" value="<%=case_no%>">
                <input type="hidden" id="uploadsource" name="uploadsource" value="<%=uploadsource%>"><!--為了入dmt_attach.source的欄位-->
		    </TD>
	    </TR>
    </thead>
    <tfoot style="display:none">
		<TR>
			<TD class=lightbluetable align=center>
		        文件檔案<input type=text name='brdmt_filenum##' class="Lock" size=2 value='##'>.
			</TD>
			<TD class=sfont9 colspan="2" align="left">
                檔案名稱：<input type=text id='brdmt_name_##' name='brdmt_name_##' class="Lock" size=50 maxlength=50>
                <input type=button name='btnbrdmt_S_##' class='cbutton' value='檢視' onclick="brupload_form.PreviewAttach('##')">
                <input type='hidden' id='brdmt_size_##' name='brdmt_size_##'>
                <input type='hidden' id='brdmt_##' name='brdmt_##'>
                <input type='hidden' id='tstep_grade_##' name='tstep_grade_##'>
                <input type='hidden' id='attach_sqlno_##' name='attach_sqlno_##'>
                <input type='hidden' id='attach_flag_##' name='attach_flag_##'>
                <input type='hidden' id='source_name_##' name='source_name_##'>
                <input type='hidden' id='attach_no_##' name='attach_no_##' value='##'>
                <input type='hidden' id='old_brdmt_name_##' name='old_brdmt_name_##'>
                <br>檔案說明：<input type='hidden' id='doc_type_##' name='doc_type_##'>
                <input type=text id='brdmt_desc_##' name='brdmt_desc_##' class="Lock" size=50 maxlength=50 >
                <input type=checkbox name='brdmt_branch_##' class="Lock" value='B'><font color='blue'>交辦專案室</font>
                <input type='hidden' id='bropen_path_##' name='bropen_path_##'>
			</TD>
		</TR>
    </tfoot>
    <tbody></tbody>
</table>

<script language="javascript" type="text/javascript">
    var brupload_form = {};
    brupload_form.init = function () {
        $("#tabfile>tbody").empty();
        $.each(br_opt.brdmt_attach, function (i, item) {
            //增加一筆
            brupload_form.appendFile();
            //填資料
            var nRow = $("#brdmt_filenum").val();
            $("#brdmt_name_" + nRow).val(item.attach_name);
            $("#old_brdmt_name_" + nRow).val(item.attach_name);
            $("#brdmt_" + nRow).val(item.attach_path);
            $("#doc_type_" + nRow).val(item.doc_type);
            $("#brdmt_desc_" + nRow).val(item.attach_desc);
            $("#brdmt_size_" + nRow).val(item.attach_size);
            $("#attach_sqlno_" + nRow).val(item.attach_sqlno);
            $("#source_name_" + nRow).val(item.source_name);
            $("#attach_no_" + nRow).val(item.attach_no);
            $("#attach_flag_" + nRow).val("U");//維護時判斷是否要更名，即A表示新上傳的文件
            $("input[name='brdmt_branch_" + nRow + "'][value='" + item.attach_branch + "']").prop("checked", true);
            $("#bropen_path_" + nRow).val(item.preview_path);

            if (i == 0) {
                $("#attach_seq").val(item.seq);
                $("#attach_seq1").val(item.seq1);
                $("#attach_step_grade").val(item.step_grade);
                $("#attach_in_no").val(item.in_no);
                $("#attach_case_no").val(item.case_no);
            }
            $("#maxattach_no").val(item.attach_no);
        });
    }

    brupload_form.appendFile = function () {
        var nRow = parseInt($("#brdmt_filenum").val(), 10) + 1;//畫面顯示NO
        $("#maxattach_no").val(parseInt($("#maxattach_no").val(), 10) + 1);//table+畫面顯示 NO
        //複製樣板
        $("#tabfile>tfoot").each(function (i) {
            var strLine1 = $(this).html().replace(/##/g, nRow);
            $("#tabfile>tbody").append(strLine1);
        });
        $("#brdmt_filenum").val(nRow);
        $("#attach_no_" + nRow).val($("#maxattach_no").val());//dmt_attach.attach_no
    }

    brupload_form.PreviewAttach = function (nRow) {
        window.open($("#bropen_path_" + nRow).val());
    }
</script>
