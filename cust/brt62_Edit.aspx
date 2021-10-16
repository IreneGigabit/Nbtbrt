<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Data"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>
<%@ Register Src="~/commonForm/dmt_upload_Form.ascx" TagPrefix="uc1" TagName="dmt_upload_Form" %>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<script runat="server">
    protected string HTProgCap = "內商文件上傳作業";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "brt62";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";
    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";
    protected string formFunction = "";
    TokenN myToken = null;
    
    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected Dictionary<string, string> Lock = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    protected Dictionary<string, string> Hide = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);

    protected string SQL = "";

    protected string submitTask = "";

    DBHelper conn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    private void Page_Unload(System.Object sender, System.EventArgs e) {
        if (conn != null) conn.Dispose();
    }

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");

        submitTask = ReqVal.TryGet("submittask").ToUpper();

        myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        HTProgCap = myToken.Title.Replace("收文", "<font color=blue>收文</font>");
        DebugStr = myToken.DebugStr;
        if (HTProgRight >= 0) {
            
            PageLayout();
            this.DataBind();
        }
    }

    private void PageLayout() {
        if (submitTask != "A") {
            if ((HTProgRight & 4) > 0) {
                StrFormBtnTop += "<a href=\"" + Page.ResolveUrl("~/brt6m/brt62_Edit.aspx") + "?prgid=" + prgid + "&submittask=A&seq=" + ReqVal.TryGet("seq") + "&seq1=" + ReqVal.TryGet("seq1") + "\" target=\"Eblank\">[新增附件]</a>";
            }
        }
        StrFormBtnTop += "<a href=\"" + Page.ResolveUrl("~/brt6m/brt62.aspx") + "?prgid="+prgid+"\" target=\"Etop\">[查詢畫面]</a>";
        StrFormBtnTop += "<a class=\"imgCls\" href=\"javascript:void(0);\" >[關閉視窗]</a>\n";
        
        string uploadfield = "", uploadsource="";
        if (submitTask == "A") {
            StrFormBtn += "<input type=button value ='新增存檔' class='cbutton bsubmit' onclick='formSubmit()'>\n";
            uploadfield = "brt62";
            uploadsource = "brt62";
        } else if (submitTask == "U") {
            StrFormBtn += "<input type=button value ='修改存檔' class='cbutton bsubmit' onclick='formSubmit()'>\n";
            uploadfield = ReqVal.TryGet("source");
            uploadsource = ReqVal.TryGet("source");
        } else if (submitTask == "D") {
            StrFormBtn += "<input type=button value ='刪除存檔' class='cbutton bsubmit' onclick='formSubmit()'>\n";
            uploadfield = ReqVal.TryGet("source");
            uploadsource = ReqVal.TryGet("source");
        }
        
        dmt_upload_Form.uploadfield = uploadfield;
        dmt_upload_Form.uploadsource = uploadsource;
    }
</script>
<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title><%=HTProgCap%></title>
    <uc1:head_inc_form runat="server" id="head_inc_form" />
</head>
<script language="javascript" type="text/javascript">
    var main = {};
    main.prgid = "<%#prgid%>";
    main.right = <%#HTProgRight%>;
    main.submittask = "<%#submitTask%>";
    main.branch = "<%#Sys.GetSession("seBranch")%>";
    main.dept = "<%#Sys.GetSession("dept").ToUpper()%>";
    main.in_no = "<%#ReqVal.TryGet("in_no")%>";
    main.step_grade = "<%#ReqVal.TryGet("step_grade")%>";
    main.seq = "<%#ReqVal.TryGet("seq")%>";
    main.seq1 = "<%#ReqVal.TryGet("seq1")%>";
    if(main.seq1=="") main.seq1="_";
    jMain={};
</script>

<body>
<table cellspacing="1" cellpadding="0" width="100%" border="0">
    <tr>
        <td class="text9" nowrap="nowrap">&nbsp;【<%=HTProgCode%><%=HTProgCap%>】</td>
        <td class="FormLink" valign="top" align="right" nowrap="nowrap">
            <%#StrFormBtnTop%>
        </td>
    </tr>
    <tr>
        <td colspan="2"><hr class="style-one"/></td>
    </tr>
</table>
<br>
<form id="reg" name="reg" method="post">
	<input type="hidden" id="prgid" name="prgid" value="<%=prgid%>">
	<input type="hidden" id="submittask" name="submittask" value="<%=submitTask%>">
	<input type="hidden" id="hrefq" name="hrefq" value="&<%=Request.QueryString%>">
	<input type="hidden" id="from_query" name="from_query" value="<%=Request["from_query"]%>">
	<input type="hidden" id="pcg" name="pcg">
	<input type="hidden" id="prs" name="prs">
	<input type="hidden" id="cgrs" name="cgrs"><!--因應電子申請增加-->	
	<input type="hidden" id="send_way" name="send_way"><!--因應電子申請增加，抓取該進度之發文方式-->	
	<input type="hidden" id="step_date" name="step_date"><!--因應電子申請增加，抓取該進度之發文日期-->
	<input type="hidden" id="rs_code_name" name="rs_code_name"><!--因應電子申請增加，抓取該進度之案性代碼名稱-->
	<input type="hidden" id="report_name" name="report_name"><!--因應電子申請增加，案性對應申請書名稱-->
	<input type="hidden" id="nstep_grade" name="nstep_grade" value="<%=Request["step_grade"]%>">
	<input type="hidden" id="dmt_in_date" name="dmt_in_date" >
		
	<table border="0" width="100%" cellspacing="0" cellpadding="0">
		<tr>
			<td class="text9"><font color=green>請先輸入本所編號：</font>
                <span class="branchdept"></span>-<input type="text" id="seq" name="seq" size=5 onblur="getSeq()">-<input type="text" id="seq1" name="seq1" onblur="getSeq()" size=3>
				&nbsp;&nbsp;
				<input type="text" id="appl_name" name="appl_name" size=50 class=sedit>
			</td>
		</tr>
		<tr>
			<td class="text9"><font color=green>對應進度：</font>
				<input type="text" id="step_grade" name="step_grade" size="<%=(Request["step_grade"]??"").Length%>" value="<%=Request["step_grade"]%>" readonly class="sedit">
				<input type="text" id="cgrs_nm" name="cgrs_nm" readonly class="sedit">
				<%if(submitTask=="A"){%>
					<input type='button' class='cbutton' name=btnquery id=btnquery value="查詢" onclick="queryjob()">
				<%}%>
			</td>
		</tr>
	</table>
	<br>

    <uc1:dmt_upload_Form runat="server" ID="dmt_upload_Form" />

    <%#DebugStr%>
</form>

<table border="0" width="98%" cellspacing="0" cellpadding="0">
<tr>
    <td width="100%" align="center">
        <%#StrFormBtn%>
    </td>
</tr>
</table>

<div id="dialog"></div>

<iframe id="ActFrame" name="ActFrame" src="about:blank" width="100%" height="500" style="display:none"></iframe>
</body>
</html>

<script language="javascript" type="text/javascript">
    $(function () {
        if (window.parent.tt !== undefined) {
            if($("#prgid").val()!="brt51"){
                window.parent.tt.rows = "*,2*";
            }else{
                window.parent.tt.rows = "0%,100%";
            }

            if($("#submittask").val()=="A"){
                window.parent.tt.rows = "0%,100%";
            }else{
                if($("#from_query").val()!="1"){
                    window.parent.tt.rows = "50%,50%";
                }
            }
        }

        this_init();
    });

    // 切換頁籤
    $("#CTab td.tab").click(function (e) {
        settab($(this).attr('href'));
    });
    function settab(k) {
        $("#CTab td.tab").removeClass("seltab").addClass("notab");
        $("#CTab td.tab[href='" + k + "']").addClass("seltab").removeClass("notab");
        $("div.tabCont").hide();
        $("div.tabCont[id='" + k + "']").show();
    }

    function this_init() {
        if($("#submittask").val()=="U"||$("#submittask").val()=="D"||$("#submittask").val()=="Q"){
            $("#seq,#seq1").lock();
        }

        //取得附件資料
        $.ajax({
            type: "get",
            url: getRootPath() + "/ajax/_dmt_step_attach.aspx?<%=Request.QueryString%>",
            async: false,
            cache: false,
            success: function (json) {
                if ($("#chkTest").length > 0) toastr.info("<a href='" + this.url + "' target='_new'>Debug(this_init)！<BR><b><u>(點此顯示詳細訊息)</u></b></a>");
                //window.open(this.url);
                jMain = $.parseJSON(json);
            },
            error: function (xhr) {
                $("#dialog").html("<a href='" + this.url + "' target='_new'>附件資料載入失敗！<u>(點此顯示詳細訊息)</u></a><hr>" + xhr.responseText);
                $("#dialog").dialog({ title: '附件資料載入失敗！', modal: true, maxHeight: 500, width: "90%" });
            }
        });

        //畫面準備
        upload_form.init();//文件上傳form

        //-----------------
        $("input.dateField").datepick();
        main.bind();//資料綁定
        $(".Lock").lock();
        $(".Hide").hide();
    }
    
    main.bind = function () {
        $(".branchdept").html(main.branch+main.dept);
        $("#seq").val(jMain.request.seq);
        $("#seq1").val(jMain.request.seq1);
        $("#step_grade").attr("size",jMain.request.step_grade.CodeLength());
        $("#nstep_grade,#step_grade").val(jMain.request.step_grade);

        if ($("#seq").val()==""||$("#seq1").val()==""){
            return false;
        }

        if(jMain.dmt.length>0){
            $("#appl_name").val(jMain.dmt[0].appl_name);
            $("#dmt_in_date").val(dateReviver(jMain.dmt[0].in_date,'yyyy/M/d'));
        }else{
            alert("該案件不存在 , 請重新輸入案件編號 !!");
            $("#appl_name").val("");
            $("#dmt_in_date").val("");
            $("#seq").val("").focus();
            return false;
        }

        if(jMain.step_dmt.length>0){
            $("#pcg").val(jMain.step_dmt[0].cg);
            $("#prs").val(jMain.step_dmt[0].rs);
            $("#cgrs").val(jMain.step_dmt[0].cg+jMain.step_dmt[0].rs);
            $("#send_way").val(jMain.step_dmt[0].send_way);
            $("#step_date").val(dateReviver(jMain.step_dmt[0].step_date,'yyyy/M/d'));
            $("#rs_code_name").val(jMain.step_dmt[0].rs_code_name);
            $("#report_name").val(jMain.step_dmt[0].report_name);
            $("#cgrs_nm").attr("size",jMain.step_dmt[0].cgrs_nm.CodeLength());
            $("#cgrs_nm").val(jMain.step_dmt[0].cgrs_nm);
        }
        //dmt_upload_form
        var fld = $("#uploadfield").val();
        var efseq=padLeft($("#seq").val(),<%#Sys.DmtSeq%>,'0');
        $("#"+fld+"_path").val("doc/"+$("#seq1").val()+"/"+efseq.Left(3)+"/"+efseq);
        if(jMain.step_dmt.length>0){
            $("#"+fld+"_maxAttach_no").val(jMain.attach_cnt.max_attach_no);
            $("#"+fld+"_attach_cnt").val(jMain.attach_cnt.attach_cnt);
        }else{
            $("#"+fld+"_maxAttach_no").val("0");
            $("#"+fld+"_attach_cnt").val("0");
        }
        $("#maxattach_no").val($("#"+fld+"_maxAttach_no").val());
        $("#attach_seq").val(jMain.request.seq);
        $("#attach_seq1").val(jMain.request.seq1);
        $("#attach_step_grade").val(jMain.request.step_grade);

        if(jMain.dmt_attach.length>0){
            $("#attach_in_no").val(jMain.dmt_attach[0].in_no);
            $("#attach_case_no").val(jMain.dmt_attach[0].case_no);
        }else{
            $("#attach_in_no").val("");
            $("#attach_case_no").val("");
        }

        //文件清單
        $("#tabfile" + fld + ">tbody").empty();
        upload_form.bind(jMain.dmt_attach);
        /*
        $.each(jMain.dmt_attach, function (i, item) {
            upload_form.appendFile();//增加一筆
            var nRow = $("#" + fld + "_filenum").val();
            $("#" + fld + "_name_" + nRow).val(item.attach_name);
            $("#old_" + fld + "_name_" + nRow).val(item.attach_name);
            $("#" + fld + "_" + nRow).val(item.attach_path);
            $("#doc_type_" + nRow).val(item.doc_type);
            $("#" + fld + "_desc_" + nRow).val(item.attach_desc);
            $("#" + fld + "_size_" + nRow).val(item.attach_size);
            $("#attach_sqlno_" + nRow).val(item.attach_sqlno);
            $("#" + fld + "_apattach_sqlno_" + nRow).val(item.apattach_sqlno);//總契約書/委任書流水號
            $("#attach_flag_" + nRow).val("U");//維護時判斷是否要更名，即A表示新上傳的文件
            $("#btn" + fld + "_" + nRow).prop("disabled", true);
            $("input[name='" + fld + "_branch_" + nRow + "'][value='" + item.attach_branch + "']").prop("checked", true);//交辦專案室
            $("#source_name_" + nRow).val(item.source_name);
            $("#attach_no_" + nRow).val(item.attach_no);
            $("#attach_flagtran_" + nRow).val(item.attach_flagtran);//異動作業上傳註記Y
            $("#tran_sqlno_" + nRow).val(item.tran_sqlno);//異動作業流水號
            $("#maxattach_no").val(Math.max(CInt(item.attach_no), CInt($("#maxattach_no").val())));
            $("input[name='doc_flag_" + nRow + "'][value='" + item.doc_flag + "']").prop("checked", true);//電子送件文件檔(pdf)
        });
        */
    }

    function getgrlast_date(){
        //抓取官收最小法定期限A1
        var searchSql="Select min(a.ctrl_date) as last_date,a.step_grade,a.rs_no ";
        searchSql+= " from ctrl_dmt a ";
        searchSql+= " inner join step_dmt b on a.rs_no=b.rs_no and b.cg='G' and b.rs='R' ";
        searchSql+= " where a.seq='"+$("#seq").val()+"' and a.seq1='"+$("#seq1").val()+ "' and a.ctrl_type='A1'";
        searchSql+= " group by a.step_grade,a.rs_no ";
        $.ajax({
            type: "get",
            url: getRootPath() + "/ajax/JsonGetSqlData.aspx",
            data: { sql: searchSql },
            async: false,
            cache: false,
            success: function (json) {
                var JSONdata = $.parseJSON(json);
                if (JSONdata.length > 0) {
                    var plast_date=dateReviver(JSONdata[0].last_date,'yyyy/M/d');
                    $("#ctrl_step_grade_"+$("#ctrlnum").val()).val(JSONdata[0].step_grade);
                    $("#ctrl_rs_no_"+$("#ctrlnum").val()).val(JSONdata[0].rs_no);
                    if(plast_date==""){
                        alert("無本筆案件編號：" +$("#seq").val()+ "-" +$("#seq1").val()+ "之官收法定期限資料，請檢查！");
                    }else{
                        $("#ctrl_date_"+$("#ctrlnum").val()).val(plast_date);
                        $("#ctrl_date_"+$("#ctrlnum")).lock();
                    }
                }else{
                    alert("本筆案件編號：" +$("#seq").val()+ "-"+$("#seq1").val()+ "無官收法定期限資料，請檢查！");
                }
            }
        });
    }


    //案件名稱讀取
    function getSeq(){
        if ($("#seq").val()==""||$("#seq1").val()==""){
            return false;
        }

        //取得附件資料
        $.ajax({
            type: "get",
            url: getRootPath() + "/ajax/_dmt_step_attach.aspx?seq="+$("#seq").val()+"&seq1="+$("#seq1").val()+"&step_grade="+$("#step_grade").val(),
            async: false,
            cache: false,
            success: function (json) {
                if ($("#chkTest").length > 0) toastr.info("<a href='" + this.url + "' target='_new'>Debug(getSeq)！<BR><b><u>(點此顯示詳細訊息)</u></b></a>");
                jMain = $.parseJSON(json);
            },
            error: function (xhr) {
                $("#dialog").html("<a href='" + this.url + "' target='_new'>案件資料載入失敗！<u>(點此顯示詳細訊息)</u></a><hr>" + xhr.responseText);
                $("#dialog").dialog({ title: '案件資料載入失敗！', modal: true, maxHeight: 500, width: "90%" });
            }
        });
        if(jMain.dmt.length>0){
            $("#appl_name").val(jMain.dmt[0].appl_name);
            $("#dmt_in_date").val(dateReviver(jMain.dmt[0].in_date,'yyyy/M/d'));
        }else{
            alert("該案件不存在 , 請重新輸入案件編號 !!");
            $("#appl_name").val("");
            $("#dmt_in_date").val("");
            $("#seq").val("").focus();
            return false;
        }

        var uploadfield=$("#uploadfield").val();
        var efseq=padLeft($("#seq").val(),5,'0');
        $("#"+uploadfield+"_path").val("doc/"+$("#seq1").val()+"/"+efseq.Left(3)+"/"+efseq);
        if(jMain.step_dmt.length>0){
            $("#"+uploadfield+"_maxAttach_no").val(jMain.attach_cnt.max_attach_no);
            $("#"+uploadfield+"_attach_cnt").val(jMain.attach_cnt.attach_cnt);
        }else{
            $("#"+uploadfield+"_maxAttach_no").val("0");
            $("#"+uploadfield+"_attach_cnt").val("0");
        }
        $("#maxattach_no").val($("#"+uploadfield+"_maxAttach_no").val());
    }

    //查詢對應進度
    function queryjob(){
        if($("#seq").val()==""){
            alert("請輸入案件編號!!");
            return false;
        }

        var url = getRootPath() + "/brt6m/brt62_steplist.aspx?prgid=<%=prgid%>&seq=" + $("#seq").val()+"&seq1=" + $("#seq1").val();
        window.open(url, "myWindowOneN", "width=700,height=480,toolbar=yes,menubar=yes,resizable=yes,scrollbars=yes,status=0,top=50,left=80");
    }

    //存檔
    function formSubmit(){
        var uploadfield=$("#uploadfield").val();

        if (main.submittask=="A"){
            if($("#"+uploadfield+"_filenum").val()=="0"){
                alert("請先新增附件!!");
                $("#multi_upload_button").focus();
                return false;
            }
        }

        if (main.submittask=="A"||main.submittask=="U"){
            for (var i = 1; i <= CInt($("#"+uploadfield+"_filenum").val()) ; i++) {
                if (chkNull("檔案說明", $("#"+uploadfield+"_desc_"+i))) return false;
                if($("#"+uploadfield+"_"+i).val()==""){
                    alert("請上傳文件!!");
                    $("#btn"+uploadfield+"_"+i).focus();
                    return false;
                }
                if($("#cgrs").val()=="GS"){
                    if($("#doc_flag_"+i).val()=="E"){
                        if($("#doc_type_mark_"+i).val()=="rpt_pr_t"){
                            if($("#report_name").val()==""){
                                alert("檔案為電子送件文件檔但無對應申請書，系統無法更新至商標電子送件區，請通知資訊部！");
                                return false;
                            }
                        }
                    }
                }
            }
        }

        if (main.submittask=="D"){
            for (var i = 1; i <= CInt($("#"+uploadfield+"_filenum").val()) ; i++) {
                if($("#"+uploadfield+"_"+i).val()!=""){
                    upload_form.DelAttach(i);
                }
            }
        }
	
        //$("select,textarea,input,span").unlock();
        $("input:disabled, select:disabled").unlock();
        $(".bsubmit").lock(!$("#chkTest").prop("checked"));

        var formData = new FormData($('#reg')[0]);
        ajaxByForm("Brt62_Update.aspx",formData)
        .complete(function( xhr, status ) {
            $("#dialog").html(xhr.responseText);
            $("#dialog").dialog({
                title: '存檔訊息',modal: true,maxHeight: 500,width: 800,closeOnEscape: false
                ,buttons: {
                    確定: function() {
                        $(this).dialog("close");
                    }
                }
                ,close:function(event, ui){
                    if(status=="success"){
                        if(!$("#chkTest").prop("checked")){
                            window.parent.tt.rows="100%,0%";
                            window.parent.Etop.goSearch();//重新整理
                        }
                    }
                }
            });
        });
    }
</script>

