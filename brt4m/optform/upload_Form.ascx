<%@ Control Language="C#" ClassName="opt_upload_form" %>

<script runat="server">
    protected string prgid = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string SQL = "";

    protected string branch = "";
    protected string opt_sqlno = "";
    protected string arcase = "";

    protected string uploadfield = "opt_file";
    protected string opt_source_type = "OPT";

    protected string doc_maxAttach_no = "";
    protected string doc_attach_cnt = "";
    protected string html_attach_doc = "";

    private void Page_Load(System.Object sender, System.EventArgs e) {
        branch = Request["branch"] ?? "";
        opt_sqlno = Request["opt_sqlno"] ?? "";
        arcase = Request["arcase"] ?? "";

        using (DBHelper connopt = new DBHelper(Conn.optK, false)) {
            SQL = "select cust_code,code_name,remark from cust_code ";
            SQL += "where code_type='Odoc_type' ";
            if (arcase != "") {
                SQL += "and (remark is null or remark like '%" + arcase + "%') ";
            }
            SQL += "order by sortfld";
            html_attach_doc = Util.Option(connopt, SQL, "{cust_code}", "{code_name}");
        }
        
        this.DataBind();
    }
</script>

<%=Sys.GetAscxPath(this)%>
<TABLE id='tabfileopt_file' border=0 class="bluetable" cellspacing=1 cellpadding=2 width="100%" style="display:none">
    <thead>
	    <TR>
		    <TD align=center colspan=5 class=lightbluetable1>
                <font color=white>承&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;辦&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;附&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;件&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;資&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;料</font>
	            <input type="hidden" id="<%=uploadfield%>_maxAttach_no" name="<%=uploadfield%>_maxAttach_no" value="<%=doc_maxAttach_no%>"><!--目前table裡最大值-->
	            <input type="hidden" id="<%=uploadfield%>_attach_cnt" name="<%=uploadfield%>_attach_cnt" value="<%=doc_attach_cnt%>">
	            <input type="hidden" id="<%=uploadfield%>_filenum" name="<%=uploadfield%>_filenum" value="0"><!--attach_no-->
	            <input type="hidden" id="<%=uploadfield%>_sqlnum" name="<%=uploadfield%>_sqlnum" value="0"><!--畫面NO顯示編號-->
	            <input type="hidden" id="opt_uploadfield" name="opt_uploadfield" value="<%#uploadfield%>">
	            <input type="hidden" id="opt_uploadsource" name="opt_uploadsource" value="<%=opt_source_type%>"><!--為了入區所opt.source的欄位-->
            </TD>
	    </TR>
	    <TR id="tr_upload_btn">
		    <TD class=whitetablebg align=right colspan=5>
			    <input type=button value="增加一筆附件" class="c1button BLock YZLock" id="<%=uploadfield%>_Add_button" name="<%=uploadfield%>_Add_button" onclick="upload_form.appendFile()">
			    <input type=button value="減少一筆附件" class="c1button BLock YZLock" id="<%=uploadfield%>_Del_button" name="<%=uploadfield%>_Del_button" onclick="upload_form.deleteFile()">
		    </TD>
	    </TR>
    </thead>
    <tfoot style="display:none">
		<TR id="tr_opt_attach_##">
			<TD class=lightbluetable align=center nowrap>
                附件<input type=text id='<%=uploadfield%>_sqlno_##' name='<%=uploadfield%>_sqlno_##' class="Lock" size=2 value='##'>.
			</TD>
			<TD class=sfont9 colspan="2" align="left">
	            附件名稱：<input type=text id='<%=uploadfield%>_name_##' name='<%=uploadfield%>_name_##' class="Lock" size=45 maxlength=50>
	            <input type=button id='btn<%=uploadfield%>_##' name='btn<%=uploadfield%>_##' class='cbutton BLock YZLock' value='上傳' onclick="upload_form.UploadOptAttach('##')">
	            <input type=button id='btn<%=uploadfield%>_D_##' name='btn<%=uploadfield%>_D_##' class='delbutton BLock YZLock' value='刪除' onclick="upload_form.DelOptAttach('##')">
	            <input type=button id='btn<%=uploadfield%>_S_##' name='btn<%=uploadfield%>_S_##' class='cbutton' value='檢視' onclick="upload_form.PreviewOptAttach('##')">
                <label style="color:blue"><INPUT id='<%=uploadfield%>_doc_flag_##' type=checkbox value=E name='<%=uploadfield%>_doc_flag_##'>電子送件檔</label>
	            <input type='hidden' id='<%=uploadfield%>_dbflag_##' name='<%=uploadfield%>_dbflag_##' value="A">
	            <input type='hidden' id='<%=uploadfield%>_attach_sqlno_##' name='<%=uploadfield%>_attach_sqlno_##'>
	            <input type='hidden' id='<%=uploadfield%>_size_##' name='<%=uploadfield%>_size_##'>
	            <input type='hidden' id='<%=uploadfield%>_##' name='<%=uploadfield%>_##'>
	            <input type='hidden' id='<%=uploadfield%>_attach_no_##' name='<%=uploadfield%>_attach_no_##' value='##'>
	            <input type='hidden' id='<%=uploadfield%>_path_##' name='<%=uploadfield%>_path_##' value=''>
	            <input type='hidden' id='<%=uploadfield%>_add_scode_##' name='<%=uploadfield%>_add_scode_##' value=''>
	            <input type='hidden' id='<%=uploadfield%>_source_name_##' name='<%=uploadfield%>_source_name_##' value=''><br>
	            文件種類：<Select id='<%=uploadfield%>_doc_type_##' name='<%=uploadfield%>_doc_type_##' Onchange="upload_form.getdesc('##')" class="BLock YZLock"><%=html_attach_doc%></Select>
	            附件說明：<input type=text id='<%=uploadfield%>_desc_##' name='<%=uploadfield%>_desc_##' class="BLock" size=50 maxlength=50 onblur="fChkDataLen(this,'附件說明')">
	            上傳日期：<input type=text id='<%=uploadfield%>_add_date_##' name='<%=uploadfield%>_add_date_##' class="Lock" size=10 maxlength=10 onblur="fChkDataLen(this,'上傳日期')">
	            <span id='span_<%=uploadfield%>_add_scodenm_##' style='display:none'>
                    <br>上傳人員：<input type=text id='<%=uploadfield%>_add_scodenm_##' name='<%=uploadfield%>_add_scodenm_##' class="Lock" size=10 maxlength=10 onblur="fChkDataLen(this,'上傳人員')">
	            </span>
			</TD>
			<TD class="sfont9 delcol" align=center>
                刪除:<input type=checkbox id='del_<%=uploadfield%>_##' name='del_<%=uploadfield%>_##' class="BLock">
            </td>
		</TR>
    </tfoot>
	<TBODY>
	</TBODY>
</table>

<script language="javascript" type="text/javascript">
    var upload_form = {};
    upload_form.init = function () {
        upload_form.getOptattach("<%=uploadfield%>");
        //電子送件才可勾選電子送件檔
        if ($("#tfy_send_way").val() != "E" && $("#tfy_send_way").val() != "EA") {
            $("input[name^='<%=uploadfield%>_doc_flag_']").prop("checked", false).prop("disabled", true);
        }

        $(".delcol").showFor($("#submittask").val() == "D");
    }

    upload_form.getOptattach = function (fld) {
        $("#" + fld + "_maxAttach_no").val(0);
        $("#" + fld + "_attach_cnt").val(0);
        $("#" + fld + "_filenum").val(0);
        $("#" + fld + "_sqlnum").val(0);
        $("#tabfileopt_file>tbody tr").remove();

        $("#" + fld + "_attach_cnt").val(br_opt.opt_attach.length);
        $("#tabfileopt_file>tbody").empty();
        $.each(br_opt.opt_attach, function (i, item) {
            //增加一筆
            upload_form.appendFile(fld);
            //填資料
            var nRow = $("#" + fld + "_filenum").val();
            $("#" + fld + "_attach_no_" + nRow).val(item.attach_no);
            $("#" + fld + "_attach_sqlno_" + nRow).val(item.attach_sqlno);
            $("#" + fld + "_name_" + nRow).val(item.attach_name);
            $("#" + fld + "_" + nRow).val(item.attach_path);
            $("#" + fld + "_desc_" + nRow).val(item.attach_desc);
            $("#" + fld + "_size_" + nRow).val(item.attach_size);
            $("#" + fld + "_path_" + nRow).val(item.attach_path);
            $("#" + fld + "_source_name_" + nRow).val(item.source_name);
            $("#" + fld + "_add_date_" + nRow).val(dateReviver(item.add_date, "yyyy/M/d"));
            $("#" + fld + "_add_scode_" + nRow).val(item.add_scode);
            $("#" + fld + "_add_scodenm_" + nRow).val(item.add_scodenm);
            $("#" + fld + "_doc_type_" + nRow).val(item.doc_type.trim());
            $("#btn" + fld + "_" + nRow).prop("disabled", true);

            $("input[name='" + fld + "_doc_flag_" + nRow + "'][value='" + item.doc_flag + "']").prop("checked", true);
            //$("input[name='brdmt_branch_" + nRow + "'][value='" + item.attach_branch + "']").prop("checked", true);
            $("#open_path_" + nRow).val(item.preview_path);

            if (item.add_scode != "<%#Session["scode"]%>" && "<%#Sys.IsAdmin()%>"!="True") {
                $("#btn" + fld + "_D_" + nRow).prop("disabled", true);
                $("#span_" + fld + "_add_scodenm_" + nRow).show();
                $("#" + fld + "_desc_" + nRow).lock();
                $("#" + fld + "_doc_type_" + nRow).lock();
            } else {
                $("#span_" + fld + "_add_scodenm_" + nRow).hide();
                if ($("#submittask").val() != "Q" && $("#submittask").val() != "B") {
                    $("#" + fld + "_desc_" + nRow).unlock();
                    $("#" + fld + "_doc_type_" + nRow).unlock();
                }
            }

            $("#" + fld + "_dbflag_" + nRow).val("U");//當讀取資料時,預設都是 U ,需要入DB(因為除了檔案之外,還可以修改說明之類,無法逐一判斷,故直接用sqlno修改所有欄位)
            $("#" + fld + "_filenum").val(nRow);
            $("#" + fld + "_maxAttach_no").val(Math.max($("#" + fld + "_maxAttach_no").val(), item.attach_no));
        });
    }

    upload_form.appendFile = function () {
        var fld = $("#opt_uploadfield").val();
        var tfilenum = parseInt($("#" + fld + "_filenum").val(), 10) + 1;//attach_no
        var tsqlnum = parseInt($("#" + fld + "_sqlnum").val(), 10) + 1;//畫面顯示NO
        $("#maxattach_no").val(parseInt($("#maxattach_no").val(), 10) + 1);//table+畫面顯示 NO
        //複製樣板
        $("#tabfileopt_file>tfoot").each(function (i) {
            var strLine1 = $(this).html().replace(/##/g, tfilenum);
            $("#tabfileopt_file>tbody").append(strLine1);
        });
        $("#" + fld + "_filenum").val(tfilenum);
        $("#" + fld + "_sqlnum").val(tsqlnum);
        $("#" + fld + "_attach_no_" + tfilenum).val($("#maxattach_no").val());//opt_attach.attach_no
    }

    upload_form.deleteFile = function () {
        var fld = $("#opt_uploadfield").val();
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

    upload_form.UploadOptAttach = function (nRow) {
        var fld = $("#opt_uploadfield").val();
        var popt_no = $("#opt_no").val().Left(4);
        var topt_no = $("#opt_no").val().substr(4);
        var tfolder = "attach" + "/" + popt_no + "/" + topt_no;
        var url = "../sub/upload_win_file.aspx?type=doc&draw_file=" + $("#" + fld + "_" + nRow).val() +
            "&folder_name=" + tfolder + "&form_name=" + fld + "_" + nRow + "&size_name=" + fld + "_size_" + nRow +
            "&file_name=" + fld + "_name_" + nRow +
            "&add_date=" + fld + "_add_date_" + nRow +
            "&add_scode=" + fld + "_add_scode_" + nRow +
            "&btnname=btn" + fld + "_" + nRow +
            "&source_name=" + fld + "_source_name_" + nRow +
            "&desc=" + fld + "_desc_" + nRow;
        window.open(url, "", "width=700 height=600 top=50 left=50 toolbar=no, menubar=no, location=no, directories=no resizeable=no status=no scrollbars=yes");
        //先判斷原本資料是否有attach_sqlno,若有表示修改,若沒有表示新增
        if ($("#" + fld + "_attach_sqlno_" + nRow).val() != "") {
            $("#" + fld + "_dbflag_" + nRow).val("U");
        } else {
            $("#" + fld + "_dbflag_" + nRow).val("A");
        }
    }

    upload_form.DelOptAttach = function (nRow) {
        var fld = $("#opt_uploadfield").val();
        var popt_no = $("#opt_no").val().Left(4);
        var topt_no = $("#opt_no").val().substr(4);
        var tfolder = "attach" + "/" + popt_no + "/" + topt_no;

        if ($("#" + fld + "_name_" + nRow).val() == "") {
            return false;
        }
        if (confirm("確定刪除上傳附件？")) {
            var url = "../sub/del_draw_file.aspx?type=doc&folder_name=" + tfolder + "&draw_file=" + $("#" + fld + "_" + nRow).val() +
                "&btnname=btn" + fld + "_" + nRow + "&form_name=" + fld + "_" + nRow;
            window.open(url, "myWindowOne1", "width=700 height=600 top=10 left=10 toolbar=no, menubar=no, location=no, directories=no resizeable=no status=no scrollbar=no");
            //window.open(url, "myWindowOne1", "width=1 height=1 top=1000 left=1000 toolbar=no, menubar=no, location=no, directories=no resizeable=no status=no scrollbar=no");
            $("#" + fld + "_doc_type" + nRow).val("");
            $("#" + fld + "_name_" + nRow).val("");
            $("#" + fld + "_desc_" + nRow).val("");
            $("#" + fld + "_" + nRow).val("");
            $("#" + fld + "_size_" + nRow).val("");
            $("#" + fld + "_path_" + nRow).val("");
            $("#" + fld + "_add_date_" + nRow).val("");
            $("#" + fld + "_add_scode_" + nRow).val("");
            $("#" + fld + "_source_name_" + nRow).val("");
            //$("#btn" + fld + "_" + nRow).prop("disabled", false);
            //當刪除時,修改DBflag = 'D'
            $("#" + fld + "_dbflag_" + nRow).val("D");
        } else {
            $("#" + fld + "_desc_" + nRow).focus();
        }
    }

    upload_form.PreviewOptAttach = function (nRow) {
        var fld = $("#opt_uploadfield").val();
        if ($("#" + fld + "_name_" + nRow).val() == "") {
            alert("請先上傳附件 !!");
            return false;
        }
        var popt_no = $("#opt_no").val().Left(4);
        var topt_no = $("#opt_no").val().substr(4);
        var tfolder = "attach" + "/" + popt_no + "/" + topt_no;
        var url = "../sub/display_file.aspx?type=doc&folder_name=" + tfolder + "&draw_file=" + $("#" + fld + "_" + nRow).val() + "&gs_date=" + ($("#GS_date").val() || "");
        window.open(url, "window", "width=700,height=600,toolbar=yes,menubar=yes,resizable=yes,scrollbars=yes,status=0,top=50,left=80");
	}

    upload_form.getdesc = function (nRow) {
        
    }
</script>
