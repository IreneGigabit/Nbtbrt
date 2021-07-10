<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>
<%@ Register Src="~/brt1m/brtform//brt25_Form.ascx" TagPrefix="uc1" TagName="brt25_Form" %>


<script runat="server">
    protected string HTProgCap = "國內案契約書後補作業";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "brt25";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";
    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";
    protected string StrFormRemark = "";

    protected string SQL = "";
    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected Dictionary<string, string> Lock = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    protected string submitTask = "";
    protected string json = "";

    protected string uploadfield = "attach";

    protected string seq = "";
    protected string seq1 = "";
    protected string case_no = "";
    protected string todo_sqlno = "";
    protected string from_flag = "";
    protected string scode1 = "";
    protected string in_no = "";
    protected string in_scode = "";
    //
    //protected string fseq = "";
    //protected string cappl_name = "";
    //protected string step_grade = "";
    //protected string rs_detail = "";
    //protected string cust_area = "";
    //protected string cust_seq = "";
    //protected string ap_cname = "";
    //protected string apcust_name = "";

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");
        submitTask = (Request["submittask"] ?? "").Trim();
        json = (Request["json"] ?? "").Trim().ToUpper();
        seq = (Request["seq"] ?? "").Trim();
        seq1 = (Request["seq1"] ?? "").Trim();
        case_no = (Request["case_no"] ?? "").Trim();
        todo_sqlno = (Request["todo_sqlno"] ?? "").Trim();
        from_flag = (Request["from_flag"] ?? "").Trim();
        scode1 = (Request["scode1"] ?? "").Trim();
        in_no = (Request["in_no"] ?? "").Trim();
        in_scode = (Request["in_scode"] ?? "").Trim();
 
        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        HTProgCap = myToken.Title;
        DebugStr = myToken.DebugStr;
        if (HTProgRight >= 0) {
            if (json == "Y") {
                QueryData();
            } else {
                PageLayout();
                ChildBind();
            }
            this.DataBind();
        }
    }

    private void PageLayout() {
        StrFormBtnTop += "<a class=\"imgCls\" href=\"javascript:void(0);\" >[關閉視窗]</a>\n";
        if (submitTask=="A")
            HTProgCap+="-新增";
        else if (submitTask=="U")
            HTProgCap +="-修改";
      
        if (Sys.GetSession("dept")=="p")
            HTProgCap+="-專利";
        else if (Sys.GetSession("dept")=="t")
            HTProgCap +="-商標";

        if (submitTask != "Q") {
            if ((HTProgRight & 4) > 0 || (HTProgRight & 8) > 0) {
                StrFormBtn += "<input type=button value ='存　檔' id='button1' class='cbutton bsubmit' onclick='formAddSubmit()'>\n";
                StrFormBtn += "<input type=button value ='重　填' id='buttonr' class='cbutton bsubmit' onclick='this_init()'>\n";
            }

            if ((HTProgRight & 256) != 0) {
                StrFormRemark+="<br />權限C備註";
		        StrFormRemark+="<br />※此作業可查詢契約書後補之交辦，並提供補入契約書號碼及契約書上傳，若為總契約書則需對應總契約書檔，";
		        StrFormRemark+="<br />　完成後系統將銷管契約書後補期限並將此筆交辦寫入「會計契約書檢核作業」，同時會EMAIL通知會計。";
            }
        }
    }
    
    //將共用參數傳給子控制項
    private void ChildBind() {
        brt25_Form.Lock = new Dictionary<string, string>(Lock);
        brt25_Form.uploadfield = uploadfield;
    }

    private void QueryData() {
        string maintable = "", aptable = "", casetable = "", attachtable = "", step_table = "", apcust_name = "";
        if (prgid.Left(3) == "brt") {
            maintable = "dmt";
            aptable = "dmt_ap";
            casetable = "case_dmt";
            attachtable = "dmt_attach";
            step_table = "step_dmt";
        } else if (prgid.Left(3) == "ext") {
            maintable = "ext";
            aptable = "ext_apcust";
            casetable = "case_ext";
            attachtable = "caseattach_ext";
            step_table = "step_ext";
        }

        DataTable dt = new DataTable();
        using (DBHelper conn = new DBHelper(Conn.btbrt, false)) {
            SQL = "select scode as scode1,cust_area,cust_seq,appl_name as cappl_name ";
            if (prgid.Left(2) == "ex") {
                SQL += ",country";
            } else {
                SQL += ",'' as country";
            }
            SQL += ",(select sc_name from sysctrl.dbo.scode where scode=d.scode) as scode1nm";
            SQL += ",(select ap_cname1+isnull(ap_cname2,'') from apcust where cust_area=d.cust_area and cust_seq=d.cust_seq) as ap_cname";
            SQL += ",''fseq,''apcust_name,''step_grade,''rs_detail ";
            SQL += ",''contract_type,''contract_no,''contract_remark,''ar_mark,''acc_chk ";
            SQL += ",''mattach_path ";
            SQL += " from " + maintable + " d ";
            SQL += " where seq='" + seq + "' and seq1='" + seq1 + "' ";
            conn.DataTable(SQL, dt);

            if (dt.Rows.Count > 0) {
                //組本所編號
                dt.Rows[0]["fseq"] = Sys.formatSeq(seq, seq1, dt.Rows[0].SafeRead("country", ""), Sys.GetSession("seBranch"), "T" + ((prgid.ToLower().Left(2) == "ex") ? "E" : ""));
                //申請人
                apcust_name = "";
                if (prgid.ToLower().Left(2) == "ex") {
                    SQL = "select * from " + aptable + " where seq='" + seq + "' and seq1='" + seq1 + "' order by sqlno";
                    using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
                        while (dr.Read()) {
                            apcust_name += (apcust_name != "" ? "、" : "") + dr.SafeRead("apcust_no", "") + dr.SafeRead("ap_cname1", "") + dr.SafeRead("ap_cname2", "");
                        }
                    }
                } else {
                    SQL = "select * from " + aptable + " where seq='" + seq + "' and seq1='" + seq1 + "' order by dmt_ap_sqlno";
                    using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
                        while (dr.Read()) {
                            apcust_name += (apcust_name != "" ? "、" : "") + dr.SafeRead("apcust_no", "") + dr.SafeRead("ap_cname", "");
                        }
                    }
                }
                dt.Rows[0]["apcust_name"] = apcust_name;
            }

            //進度
            SQL = "select step_grade,rs_detail from " + step_table + " ";
            SQL += " where seq='" + seq + "' and seq1='" + seq1 + "' and cg='C' and rs='R' ";
            SQL += " and case_no='" + case_no + "' ";
            using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
                if (dr.Read()) {
                    dt.Rows[0]["step_grade"] = dr.SafeRead("step_grade", "");
                    dt.Rows[0]["rs_detail"] = dr.SafeRead("rs_detail", "");
                }
            }

            //抓取ar_mark,acc_chk為判斷後續流程是否至會計契約書檢核
            SQL = "select contract_type,contract_no,contract_remark,ar_mark,acc_chk ";
            SQL += " from " + casetable + " ";
            SQL += " where seq='" + seq + "' and seq1='" + seq1 + "' ";
            SQL += " and case_no='" + case_no + "' ";
            using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
                if (dr.Read()) {
                    dt.Rows[0]["contract_type"] = dr.SafeRead("contract_type", "");
                    dt.Rows[0]["contract_no"] = dr.SafeRead("contract_no", "");
                    dt.Rows[0]["contract_remark"] = dr.SafeRead("contract_remark", "");
                    dt.Rows[0]["ar_mark"] = dr.SafeRead("ar_mark", "");
                    dt.Rows[0]["acc_chk"] = dr.SafeRead("acc_chk", "");
                }
            }

            //抓取總契約書
            SQL = "select b.attach_path as mattach_path ";
            SQL += " from " + attachtable + " a ";
            SQL += " left join apcust_attach b on a.apattach_sqlno=b.apattach_sqlno ";
            if (prgid.Left(2) == "ex") {
                SQL += " where in_no='" + in_no + "' ";
            } else {
                SQL += " where seq='" + seq + "' and seq1='" + seq1 + "' ";
            }
            using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
                if (dr.Read()) {
                    dt.Rows[0]["mattach_path"] = Sys.Path2Nbtbrt(dr.SafeRead("mattach_path", ""));
                }
            }
        }
        var settings = new JsonSerializerSettings()
        {
            Formatting = Formatting.Indented,
            ContractResolver = new LowercaseContractResolver(),//key統一轉小寫
            Converters = new List<JsonConverter> { new DBNullCreationConverter(), new TrimCreationConverter() }//dbnull轉空字串且trim掉
        };
        Response.Write(JsonConvert.SerializeObject(dt, settings).ToUnicode());
        Response.End();
    }
</script>
<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title><%=HTProgCap%></title>
<link rel="stylesheet" type="text/css" href="<%=Page.ResolveUrl("~/inc/setstyle.css")%>" />
<link rel="stylesheet" type="text/css" href="<%=Page.ResolveUrl("~/js/lib/jquery.datepick.css")%>" />
<link rel="stylesheet" type="text/css" href="<%=Page.ResolveUrl("~/js/lib/toastr.css")%>" />
<link rel="stylesheet" type="text/css" href="<%=Page.ResolveUrl("~/js/lib/jquery-ui.min.css")%>" />
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/jquery-1.12.4.min.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/jquery-ui.min.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/jquery.datepick.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/jquery.datepick-zh-TW.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/toastr.min.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/util.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/client_chk.js")%>"></script>
</head>
<script language="javascript" type="text/javascript">
    var main = {};
    main.branch = "<%#Session["SeBranch"]%>";
    main.prgid = "<%#prgid%>";
    main.right = <%#HTProgRight%>;
    main.submittask = "<%#submitTask%>";
    jMain = {};
</script>

<body>
<table cellspacing="1" cellpadding="0" width="98%" border="0">
    <tr>
        <td class="text9" nowrap="nowrap">&nbsp;【<%=HTProgCode%><%=HTProgCap%>】
        </td>
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
    <table cellspacing="1" cellpadding="0" width="98%" border="0">
    <tr>
	    <td width="100%" valign="top">
	        ※本所編號：<span style="color:blue" id="span_fseq"></span>
	        &nbsp;&nbsp;&nbsp;※案件名稱：<span style="color:blue" id="span_cappl_name"></span>
	        <br>※交辦單號：<font color="blue"><span id="span_scode1"></span>-<%=case_no%></font>
	        &nbsp;&nbsp;&nbsp;※進度：<font color="blue"><span id="span_step_grade"></span>&nbsp;&nbsp;<span id="span_rs_detail"></span></font>
	        <br>※客戶：<font color="blue"><span id="span_cust_area"></span>-<span id="span_cust_seq"></span>&nbsp;<span id="span_ap_cname"></span></font>
	        <br>※申請人：<span style="color:blue" id="span_apcust_name"></span>
        </td>
    </tr>
    <tr>
        <td>
            <uc1:brt25_Form runat="server" ID="brt25_Form" />
        </td>
    </tr>
    </table>
	<input type="hidden" id="prgid" name="prgid" value="<%=prgid%>">
	<input type="hidden" id="submittask" name="submittask" value="<%=submitTask%>">
	<input type="hidden" id="seq" name="seq" value="<%=seq%>">
	<input type="hidden" id="seq1" name="seq1" value="<%=seq1%>">
	<input type="hidden" id="case_no" name="case_no" value="<%=case_no%>">
	<input type="hidden" id="step_grade" name="step_grade" value="">
	<input type="hidden" id="todo_sqlno" name="todo_sqlno" value="<%=todo_sqlno%>">
	<input type="hidden" id="from_flag" name="from_flag" value="<%=from_flag%>">
	<input type="hidden" id="scode1" name="scode1" value="<%=scode1%>">
	<input type="hidden" id="in_no" name="in_no" value="<%=in_no%>">
	<input type="hidden" id="in_scode" name="in_scode" value="<%=in_scode%>">
	<input type="hidden" id="fseq" name="fseq" value="">
	<input type="hidden" id="cappl_name" name="cappl_name" value="">
	<input type="hidden" id="cust_seq" name="cust_seq" value="">

    <%#DebugStr%>
    <table border="0" width="98%" cellspacing="0" cellpadding="0">
    <tr>
        <td width="100%" align="center">
            <%#StrFormBtn%>
        </td>
    </tr>
    </table>
</form>
<div align=left style="font-size:10pt;color:blue" class="haveData">
    <%#StrFormRemark%>
</div>


<div id="dialog"></div>

<iframe id="ActFrame" name="ActFrame" src="about:blank" width="100%" height="500" style="display:none"></iframe>
</body>
</html>

<script language="javascript" type="text/javascript">
    $(function () {
        if (window.parent.tt !== undefined) {
            window.parent.tt.rows = "100%,0%";
        }

        this_init();
    });

    function this_init() {
        if(main.submittask=="A"||main.submittask=="C"){
            window.parent.tt.rows = "0%,100%";
            if(main.submittask=="C"){
                $("#button1").val("取消後補送會計檢核");
                $("#buttonr").hide();
            }
        }else if(main.submittask=="U"||main.submittask=="Q"){
            window.parent.tt.rows = "30%,70%";
        }else if(main.submittask=="D"){
            window.parent.tt.rows = "30%,70%";
            $("#button1").val("契約書已上傳，不需後補");
            $("#buttonr").hide();
            $("select,textarea,input,span").lock();
            $(".bsubmit,#chkTest").unlock();
        }

        //console.log("this_init");
        //-----------------
        //取得契約書資料
        $.ajax({
            type: "get",
            url: "brt25_Edit.aspx?json=Y&<%#Request.QueryString%>",
            async: false,
            cache: false,
            success: function (json) {
                if (!isJson(json) || $("#chkTest").prop("checked")) {
                    $("#dialog").html("<a href='" + this.url + "' target='_new'>Debug！<u>(點此顯示詳細訊息)</u></a><hr>" + json);
                    $("#dialog").dialog({ title: 'Debug！', modal: true, maxHeight: 500, width: "90%" });
                    return false;
                }
                jMain = $.parseJSON(json);
            },
            error: function (xhr) {
                $("#dialog").html("<a href='" + this.url + "' target='_new'>後補契約書資料載入失敗！<u>(點此顯示詳細訊息)</u></a><hr>" + xhr.responseText);
                $("#dialog").dialog({ title: '後補契約書資料載入失敗！', modal: true, maxHeight: 500, width: "90%" });
            }
        });

        //畫面準備
        brt25_form.init();//契約書form

        ////-----------------
        main.bind();//資料綁定
        $("input.dateField").datepick();
        $(".Lock").lock();
    }
    
    main.bind = function () {
        $("#span_fseq").html(jMain[0].fseq);
        $("#fseq").val(jMain[0].fseq);
        $("#span_cappl_name").html(jMain[0].cappl_name);
        $("#span_scode1").html(jMain[0].scode1);
        $("#span_step_grade").html(jMain[0].step_grade);
        $("#span_rs_detail").html(jMain[0].rs_detail);
        $("#span_cust_area").html(jMain[0].cust_area);
        $("#span_cust_seq").html(jMain[0].cust_seq);
        $("#span_ap_cname").html(jMain[0].ap_cname);
        $("#span_apcust_name").html(jMain[0].apcust_name);
        $("#step_grade").val(jMain[0].step_grade);
        $("#cappl_name").val(jMain[0].cappl_name);
        $("#cust_seq").val(jMain[0].cust_seq);

        brt25_form.bind();//契約書form
    };

    //存檔
    function formAddSubmit(){
        if(main.submittask=="A"||main.submittask=="U"){
            var fld = $("#uploadfield").val();
            if($("input[name='rcontract_no']:checked").length==0){
                alert("契約種類必須選擇 !!");
                return false;
            }

            if($("input[name='rcontract_no']:checked").val()==""){
                if (chkNull("契約編號", reg.Contract_no)) return false;
                if( $("#"+fld + "_name").val()==""){
                    alert("附件必須上傳 !!");
                    return false;
                }
                $("#hcontract_no").val($("#Contract_no").val());
            }else if($("input[name='rcontract_no']:checked").val()=="M"){
                if( $("#mcontract_no").val()==""){
                    alert("總契約書必須上傳 !!");
                    return false;
                }
                if( $("#"+fld + "_name1").val()==""){
                    var ans="客戶案件委辦書本次未上傳，確定本筆交辦已上傳，請按「是」繼續存檔，要補上傳檔案，請按「否」回作業畫面。";
                    if(confirm(ans)==false){
                        return false;
                    }
                }
            }else{
                if( $("#"+fld + "_name").val()==""){
                    alert("附件必須上傳 !!");
                    return false;
                }
            }
        }

        $("select,textarea,input,span").unlock();
        $(".bsubmit").lock(!$("#chkTest").prop("checked"));

        var formData = new FormData($('#reg')[0]);
        $.ajax({
            url:'<%=HTProgPrefix%>_Update.aspx',
            type : "POST",
            data : formData,
            contentType: false,
            cache: false,
            processData: false,
            beforeSend:function(xhr){
                $("#dialog").html("<div align='center'><h1>存檔中...</h1></div>");
                $("#dialog").dialog({ title: '存檔訊息', modal: true,maxHeight: 500,width: 800,buttons:[] });
            },
            //success: function (data, status, xhr) { main.onSuccess(data, status, xhr); },
            //error: function (xhr, status) { main.onError(xhr, status); },
            complete: function (xhr, status) {
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
                                window.parent.Etop.goSearch();
                            }
                        }
                    }
                });
            }
        });

        //reg.action = "<%=HTProgPrefix%>_Update.aspx";
        //if($("#chkTest").prop("checked"))
        //    reg.target = "ActFrame";
        //else
        //    reg.target = "_self";
        //reg.submit();
    }
</script>
