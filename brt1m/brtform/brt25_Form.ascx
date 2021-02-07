<%@ Control Language="C#" ClassName="brt25_Form" %>
<%@ Import Namespace = "System.Collections.Generic"%>

<script runat="server">
    //父控制項傳入的參數
    public Dictionary<string, string> Lock = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);

    protected string SQL = "";
    protected string prgid = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string submitTask = "";
    protected string epath = "";
    protected string uploadsource = "";
    public string uploadfield = "attach";//可從父項傳來,若父項未指定則為此值
    //public string seq = "";
    //public string seq1 = "";
    //public string step_grade = "";
    //public string in_no = "";
    //public string case_no = "";
    //public string erpt_code = "";
    //
    //protected string uploadtype = "";
    //protected string source = "";
    //protected string StrFormRemark = "";

    protected string html_upatt_doc = "";
    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        submitTask = (Request["submittask"] ?? "").Trim();
        prgid = prgid.ToLower();

        if (prgid.Left(2) == "ex") {
            epath = "doc/temp";
            uploadsource = "CASE";
        } else {
            epath = "doc/case";
            uploadsource = "CASE";
        }

        string pwhere = "";
        if (submitTask != "Q") pwhere += "and (mark is null or mark<>'B')";//維護時只顯示區所文件種類
        html_upatt_doc = Sys.getCustCode("TDOC", pwhere, "sortfld").Option("{cust_code}", "{code_name}", " v1='{mark1}'", true);

        PageLayout();
        this.DataBind();
    }

    private void PageLayout() {
    }
</script>

<%=Sys.GetAscxPath(this.AppRelativeVirtualPath)%>
<TABLE id=tab25form style="display:" border=0 class="bluetable"  cellspacing=1 cellpadding=2 width="100%">
	<TR id="tr_contract">
		<TD class=lightbluetable align=right>
			契約號碼：
		</TD>
		<TD class=whitetablebg>
			<input type="hidden" id=hcontract_no name=hcontract_no>
			<input type="hidden" id="contract_type" name="contract_type" value="2"><!--契約書種類-->
			<input type="hidden" id=contract_no_cnt name=contract_no_cnt value="4">
			<input type="hidden" id="ar_mark" name="ar_mark" value=""><!--請款註記-->
			<input type="hidden" id="acc_chk" name="acc_chk" value=""><!--契約書檢核註記-->
			<input type=radio name="rcontract_no" value="" class="<%#Lock.TryGet("Qdisabled")%>">
			<INPUT TYPE=text id=Contract_no NAME=Contract_no class="<%#Lock.TryGet("Qclass")%>" SIZE=10 MAXLENGTH=10 >
			<span id="span_rcontract_no">
				<input type=radio name="rcontract_no" value="A" class="<%#Lock.TryGet("Qdisabled")%>" >後續案無契約書
			</span>
			<input type=radio name="rcontract_no" value="C" class="<%#Lock.TryGet("Qdisabled")%>" >其他契約書無編號/特案簽報
			<input type=radio name="rcontract_no" value="M" class="<%#Lock.TryGet("Qdisabled")%>" >總契約書+客戶案件委辦書
			<br>
			交辦時尚缺文件說明：
			<input type=text id="contract_remark" name="contract_remark" size=50 maxlength=100 class="SEdit" readonly>
		</TD>
	</TR>
	<TR id="tr_attach">
		<TD class=lightbluetable align=right>契約書檔案：</TD>
		<TD class=whitetablebg>
            <input type="hidden" name="<%=uploadfield%>sqlnum" id="<%=uploadfield%>sqlnum" value="">
		    <span id="span_mcontract" style="display:none">
		        總契約書：
			    <input type="text" name=mcontract_no id=mcontract_no size=11 readonly class="SEdit">
			    <input type=button class="greenbutton" id="btn_contract" name="btn_contract" value="查詢總契約書">
			    <input type=button class="cbutton" id="btn_contractview" name="btn_contractview" value="檢視">
			    <input type="hidden" id=mcontract_path name=mcontract_path size=40 readonly class="SEdit">
                <br>
			</span>
            <span id="span_upload" style="display:none">
		        附件名稱：<INPUT type="text" id="<%=uploadfield%>_name" name="<%=uploadfield%>_name" size="30" class=SEdit readonly>
	            <input type=button id='btn<%=uploadfield%>_' name='btn<%=uploadfield%>_' class='cbutton <%#Lock.TryGet("CQdisabled")%>' value='上傳' onclick="brt25_form.UploadAttach('')">
	            <input type=button id='btn<%=uploadfield%>D' name='btn<%=uploadfield%>D' class='redbutton <%#Lock.TryGet("CQdisabled")%>' value='刪除' onclick="brt25_form.DelAttach('')">
	            <input type=button id='btn<%=uploadfield%>S' name='btn<%=uploadfield%>S' class='cbutton' value='檢視' onclick="brt25_form.PreviewAttach('')">		    
	            <br>
	        </span>
            附件種類：
	        <span id="span_<%=uploadfield%>_doc_type">
		        <select id="<%=uploadfield%>_doc_type" name="<%=uploadfield%>_doc_type" onchange="brt25_form.getdesc('')"><%=html_upatt_doc%></select>
		    </span>
		    <br>附件說明：
		    <INPUT type="text" id="<%=uploadfield%>_desc" name="<%=uploadfield%>_desc" size="50" maxlength=80 class="<%#Lock.TryGet("CQclass")%>">
		    <br>原始檔名：<INPUT type="text" id="<%=uploadfield%>_source_name" name="<%=uploadfield%>_source_name" size="30" class=SEdit readonly>
		    <input type="hidden" id="<%=uploadfield%>" name="<%=uploadfield%>" size="30"> <!--attach_path-->
		    <input type="hidden" id="<%=uploadfield%>_dbflag" name="<%=uploadfield%>_dbflag" size="2"><!--attach_flag-->
		    <input type="hidden" id="<%=uploadfield%>_max_attach_no" name="<%=uploadfield%>_max_attach_no" size="2"><!--attach_no-->
		    <input type="hidden" id="<%=uploadfield%>_path" name="<%=uploadfield%>_path" size="10" value="<%=epath%>">
		    <input type="hidden" id="<%=uploadfield%>_size" name="<%=uploadfield%>_size" size="10">
		    <input type="hidden" id="<%=uploadfield%>_in_scode" name="<%=uploadfield%>_in_scode" size="5">
		    <input type="hidden" id="<%=uploadfield%>_in_date" name="<%=uploadfield%>_in_date" size="10">
		    <input type="hidden" id="<%=uploadfield%>_apattach_sqlno" name="<%=uploadfield%>_apattach_sqlno" size="5">
		    <input type="hidden" id="uploadfield" name="uploadfield" value="<%=uploadfield%>">
            <input type="hidden" id="uploadsource" name="uploadsource" value="<%=uploadsource%>">
		</TD>
	</TR>
	<TR id="tr_attach_cust" style="display:none">
		<TD class=lightbluetable align=right>客戶案件委辦書檔案：</TD>
		<TD class=whitetablebg>
            <input type="text" name="<%=uploadfield%>sqlnum1" id="<%=uploadfield%>sqlnum1" value="">
		    附件名稱：<INPUT type="text" id="<%=uploadfield%>_name1" name="<%=uploadfield%>_name1" size="30" class=SEdit readonly>
	        <input type=button id='btn<%=uploadfield%>_1' name='btn<%=uploadfield%>_1' class='cbutton <%#Lock.TryGet("CQdisabled")%>' value='上傳' onclick="brt25_form.UploadAttach('1')">
	        <input type=button id='btn<%=uploadfield%>D1' name='btn<%=uploadfield%>D1' class='redbutton <%#Lock.TryGet("CQdisabled")%>' value='刪除' onclick="brt25_form.DelAttach('1')">
	        <input type=button id='btn<%=uploadfield%>S1' name='btn<%=uploadfield%>S1' class='cbutton' value='檢視' onclick="brt25_form.PreviewAttach('1')">
	        <br>
            附件種類：
	        <span id="span_<%=uploadfield%>_doc_type1">
		    <select id="<%=uploadfield%>_doc_type1" name="<%=uploadfield%>_doc_type1" onchange="brt25_form.getdesc('1')"><%=html_upatt_doc%></select>
		    </span>
		    <br>附件說明：
		    <INPUT type="text" id="<%=uploadfield%>_desc1" name="<%=uploadfield%>_desc1" size="50" maxlength=80 class="<%#Lock.TryGet("CQclass")%>">
		    <br>原始檔名：<INPUT type="text" id="<%=uploadfield%>_source_name1" name="<%=uploadfield%>_source_name1" size="30" class=SEdit readonly>
		    <input type="hidden" id="<%=uploadfield%>1" name="<%=uploadfield%>1" size="30"> <!--attach_path-->
		    <input type="hidden" id="<%=uploadfield%>_dbflag1" name="<%=uploadfield%>_dbflag1" size="2"><!--attach_flag-->
		    <input type="hidden" id="<%=uploadfield%>_max_attach_no1" name="<%=uploadfield%>_max_attach_no1" size="2"><!--attach_no-->
		    <input type="hidden" id="<%=uploadfield%>_path1" name="<%=uploadfield%>_path1" size="10" value="<%=epath%>">
		    <input type="hidden" id="<%=uploadfield%>_size1" name="<%=uploadfield%>_size1" size="10">
		    <input type="hidden" id="<%=uploadfield%>_in_scode1" name="<%=uploadfield%>_in_scode1" size="5">
		    <input type="hidden" id="<%=uploadfield%>_in_date1" name="<%=uploadfield%>_in_date1" size="10">
		    <input type="hidden" id="<%=uploadfield%>_apattach_sqlno1" name="<%=uploadfield%>_apattach_sqlno1" size="5">
		</TD>
	</TR>
</table>

<script language="javascript" type="text/javascript">
    var brt25_form = {};

    brt25_form.init = function () {
        if (main.submittask == "C" || main.submittask == "D") {
            $("#tr_contract,#tr_attach,#tr_attach_cust").hide();
        }
    }

    brt25_form.bind = function () {
        if (jMain[0].contract_type == "N") {
            $("input[name='rcontract_no'][value='']").prop("checked", true).triggerHandler("click");
        } else {
            $("input[name='rcontract_no'][value='" + jMain[0].contract_type + "']").prop("checked", true).triggerHandler("click");
        }
        if (jMain[0].contract_type == "M") {
            $("#mcontract_no").val(jMain[0].contract_no);
        } else if (jMain[0].contract_type == "N") {
            $("#Contract_no").val(jMain[0].contract_no);
        }
        $("#contract_remark").val(jMain[0].contract_remark);
        $("#ar_mark").val(jMain[0].ar_mark);
        $("#acc_chk").val(jMain[0].acc_chk);

        $("#mcontract_path").val(jMain[0].mattach_path);
    }

    //契約書點選控制
    $("input[name='rcontract_no']").click(function () {
        $("#hcontract_no,#contract_type").val($(this).val());
        if ($(this).val() == "") {
            $("#contract_type").val("N");
        }

        $("#span_mcontract,#span_upload,#tr_attach_cust").hide();
        if ($(this).val() == "M") {//總契約書
            //2016/9/19修改，因總契約書也要上傳客戶案件委辦書
            $("#span_mcontract,#tr_attach_cust").show();
        } else {
            $("#span_upload").show();
        }
    });

    //檔案說明
    brt25_form.getdesc = function (nRow) {
        var fld = $("#uploadfield").val();

        var dname = $("#" + fld + "_desc" + nRow).val().trim();
        if (dname != "") dname += "、";
        dname += $("#" + fld + "_doc_type" + nRow + " :selected").text();
        $("#" + fld + "_desc" + nRow).val(dname);
    }

    //查詢總契約書
    $("#btn_contract").click(function () {
        var pdept="T";
        if(main.prgid.Left(2)=="ex") pdept="TE";
        var url = getRootPath() + "/brt1m/POA_attachlist.aspx?prgid=<%=prgid%>&dept=" + pdept + "&kind=S&source=contract&cust_seq=" + $("#cust_seq").val() + "&upload_tabname=upload";
        window.open(url, "myWindowapN", "width=900 height=680 top=20 left=20 toolbar=no, menubar=no, location=no, directories=no resizeable=no status=no scrollbars=yes");
    });

    //檢視
    $("#btn_contractview").click(function () {
        if($("#mcontract_path").val()!=""){
            window.open($("#mcontract_path").val());
        }
    });

    //[上傳]
    brt25_form.UploadAttach = function (nRow) {
        var tfolder = $("#" + $("#uploadfield").val() + "_path" + nRow).val();
        var url = getRootPath() + "/sub/upload_win_file_new.aspx?type=doc" +
            "&attach_sqlno_name=" + $("#uploadfield").val() + "sqlnum" + nRow +
            "&folder_name=" + tfolder +
            "&file_name=" + $("#uploadfield").val() + "_name" + nRow +
            "&size_name=" + $("#uploadfield").val() + "_size" + nRow +
            "&dir_name=" + $("#uploadfield").val() + "" + nRow +
            "&attach_flag_name=" + $("#uploadfield").val() + "_dbflag" + nRow +
            "&prgid=<%=prgid%>" +
            "&btnname=btn" + $("#uploadfield").val() + "_" + nRow +
            "&filename_flag=source_name";
        window.open(url, "dmtupload", "width=700 height=600 top=50 left=50 toolbar=no, menubar=no, location=no, directories=no resizeable=no status=no scrollbars=yes");
    }

    //[刪除]
    brt25_form.DelAttach = function (nRow) {
        var fld = $("#uploadfield").val();

        if (document.getElementById(fld + "" + nRow).value == "") {
            alert("無檔案可刪除!!");
            return false;
        }
        var file = document.getElementById(fld + "" + nRow).value;
        var tname = document.getElementById(fld + "_name" + nRow).value;
        if (file.indexOf(".") > -1) {	//路徑包含檔案
            if (file.indexOf("/") > -1) {	//當檔名前的符號為/，將檔名前/改為\
                file = file.substr(0, file.lastIndexOf("/")) + "\\" + tname;
            }
        } else {
            file += "\\" + tname;
        }

        if (confirm("確定刪除上傳檔案？")) {
            $.ajax({
                url: getRootPath() + "/sub/del_draw_file_new.aspx?type=doc&draw_file=" + file,
                type: 'GET',
                dataType: "script",
                async: false,
                cache: false,
                success: function (data) {
                    document.getElementById(fld + "_name" + nRow).value = "";
                    document.getElementById(fld + "_source_name" + nRow).value = "";
                    document.getElementById(fld + "_desc" + nRow).value = "";
                    document.getElementById(fld + "" + nRow).value = "";
                    document.getElementById(fld + "_size" + nRow).value = "";
                    document.getElementById(fld + "_doc_type" + nRow).value = "";
                    document.getElementById("btn" + fld + "_" + nRow).disabled = false;
                    document.getElementById(fld + "_dbflag" + nRow).value = "D";
                },
                error: function (xhr) {
                    $("#dialog").html("<a href='" + this.url + "' target='_new'>刪除檔案失敗！<u>(點此顯示詳細訊息)</u></a><hr>" + xhr.responseText);
                    $("#dialog").dialog({ title: '刪除檔案失敗！', modal: true, maxHeight: 500, width: "90%" });
                }
            });

            //window.open(getRootPath() + "/sub/del_draw_file_new.aspx?type=doc&draw_file=" + file, "myWindowOneN", "width=10 height=10 top=1000 left=1000 toolbar=no, menubar=no, location=no, directories=no resizeable=no status=no scrollbar=no");
            //document.getElementById(fld + "_name" + nRow).value = "";
            //document.getElementById(fld + "_source_name" + nRow).value = "";
            //document.getElementById(fld + "_desc" + nRow).value = "";
            //document.getElementById(fld + "" + nRow).value = "";
            //document.getElementById(fld + "_size" + nRow).value = "";
            //document.getElementById(fld + "_doc_type" + nRow).value = "";
            //document.getElementById("btn" + fld + "_" + nRow).disabled = false;
            //document.getElementById(fld + "_dbflag" + nRow).value = "D";
        } else {
            document.getElementById(fld + "_desc" + nRow).focus();
            return false;
        }
    }

    //檢視
    brt25_form.PreviewAttach = function (nRow) {
        var fld = $("#uploadfield").val();
        if ($("#" + fld + "_name" + nRow).val() == "") {
            alert("請先上傳附件 !!");
            return false;
        }

        var file = document.getElementById(fld + "" + nRow).value;
        var tname = document.getElementById(fld + "_name" + nRow).value;
        if (file.indexOf(".") > -1) {	//路徑包含檔案
            if (file.indexOf("/") > -1) {	//當檔名前的符號為/，將檔名前/改為\
                file = file.substr(0, file.lastIndexOf("/")) + "\\" + tname;
            }
        } else {
            file += "\\" + tname;
        }

        window.open(file);
    }
</script>
