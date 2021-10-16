<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Data"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>
<%@ Register Src="~/commonForm/dmt_upload_Form.ascx" TagPrefix="uc1" TagName="dmt_upload_Form" %>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<script runat="server">
    protected string HTProgCap = "轉案文件上傳作業";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = HttpContext.Current.Request["prgid"] ?? "";//程式檔名前綴
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
    protected string country = "";
    protected string btnname = "";
    protected string btnwidth = "Hide";
    protected string uploadfield = "brt1b";
    protected string uploadsource = "";
    protected string att_sqlno = "";

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
        country = ReqVal.TryGet("country").ToUpper();

        myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        HTProgCap = myToken.Title;
        DebugStr = myToken.DebugStr;
        if (HTProgRight >= 0) {
            
            PageLayout();
            this.DataBind();
        }
    }

    private void PageLayout() {
        StrFormBtnTop += "<a class=\"imgCls\" href=\"javascript:void(0);\" >[關閉視窗]</a>\n";

        uploadsource = ReqVal.TryGet("source");
        att_sqlno = ReqVal.TryGet("att_sqlno");
        
        if (submitTask == "A") {
            btnname = "新增存檔";
            btnwidth = "";
            uploadsource = "tran";
            ReqVal["source"] = "tran";
        } else if (submitTask == "U") {
            btnname = "修改存檔";
            btnwidth = "";
        } else if (submitTask == "D") {
            btnname = "刪除存檔";
            btnwidth = "";
        }

        StrFormBtn += "<input type=button value ='" + btnname + "' class='cbutton bsubmit " + btnwidth + "' onclick='formSubmit()'>\n";


        dmt_upload_Form.uploadfield = uploadfield;
        dmt_upload_Form.uploadsource = uploadsource;
    }
</script>
<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title><%=HTProgCap%></title>
    <uc1:head_inc_form runat="server" ID="head_inc_form" />
</head>
<script language="javascript" type="text/javascript">
    var main = {};
    main.prgid = "<%#prgid%>";
    main.right = <%#HTProgRight%>;
    main.submittask = "<%#submitTask%>";
    main.seq = "<%#ReqVal.TryGet("seq")%>";
    main.seq1 = "<%#ReqVal.TryGet("seq1")%>";
    main.country = "<%#ReqVal.TryGet("country")%>";
    main.step_grade = "<%#ReqVal.TryGet("step_grade")%>";
    main.in_no = "<%#ReqVal.TryGet("in_no")%>";
    main.attach_sqlno = "<%#ReqVal.TryGet("attach_sqlno")%>";
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
	<input type="hidden" id="nstep_grade" name="nstep_grade" value="<%=Request["step_grade"]%>">
	<input type="hidden" id="dmt_in_date" name="dmt_in_date" >
	<input type="hidden" id="cgrs" name="cgrs"><!--因應電子申請增加-->	
	<input type="hidden" id="seq" name="seq" value="<%=Request["seq"]%>">
	<input type="hidden" id="seq1" name="seq1" value="<%=Request["seq1"]%>">
	<input type="hidden" id="country" name="country" value="<%=Request["country"]%>">
	<input type="hidden" id="step_grade" name="step_grade" value="<%=Request["step_grade"]%>">
		
	<%if (country==""){%>
        <uc1:dmt_upload_Form runat="server" ID="dmt_upload_Form" />
	<%}else{%>
		<!--include file="../brt5m/extform/upload_Form.asp"--><!--***todo出口案文件上傳欄位畫面-->
	<%}%>
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

<iframe id="ActFrame" name="ActFrame" src="about:blank" width="100%" height="300" style="display:none"></iframe>
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
            url: getRootPath() + "/ajax/_dmt_step_attach.aspx?<%=ReqVal.ParseQueryString()%>",
            async: false,
            cache: false,
            success: function (json) {
                if($("#chkTest").length>0) toastr.info("<a href='" + this.url + "' target='_new'>Debug(this_init)！<BR><b><u>(點此顯示詳細訊息)</u></b></a>");
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
        upload_form.bind(jMain.dmt_attach,false);//顯示上傳文件資料/是否顯示原始檔名
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
        ajaxByForm("Brt1b_attach_Update.aspx",formData)
        .complete(function( xhr, status ) {
            $("#dialog").html(xhr.responseText);
            $("#dialog").dialog({
                title: '存檔訊息',modal: true,maxHeight: 500,width: "90%",closeOnEscape: false
                ,buttons: {
                    確定: function() {
                        $(this).dialog("close");
                    }
                }
                ,close:function(event, ui){
                    if(status=="success"){
                        if(!$("#chkTest").prop("checked")){
                            $(".imgCls").click();
                        }
                    }
                }
            });
        });
    }
</script>

