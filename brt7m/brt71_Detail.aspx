<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Data"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>
<%@ Register Src="~/brt7m/brtform/brt71main_form.ascx" TagPrefix="uc1" TagName="brt71main_form" %>
<%@ Register Src="~/brt7m/brtform/brt71item_form.ascx" TagPrefix="uc1" TagName="brt71item_form" %>


<script runat="server">
    protected string HTProgCap = "國內案一般請款單明細";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = HttpContext.Current.Request["prgid"] ?? "";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";
    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";
    
    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected Dictionary<string, string> Lock = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    protected Dictionary<string, string> Hide = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);

    protected string SQL = "";
    protected object objResult = null;

    protected string modify = "";

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

        if (prgid == "") {
            prgid = "Brt71";
            HTProgCode = "Brt71";
        }

        modify = ReqVal.TryGet("submittask").ToUpper();
        
        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        HTProgCap = myToken.Title;
        DebugStr = myToken.DebugStr;
        if (HTProgRight >= 0) {
            PageLayout();
            ChildBind();
            this.DataBind();
        }
    }

    private void PageLayout() {
        StrFormBtn += "<input type=\"button\" value=\"開立請款單\" class=\"cbutton bsubmit\" onClick=\"formSaveSubmit()\">\n";
        StrFormBtn += "<input type=\"button\" value=\"重　填\" class=\"cbutton\" onClick=\"this_init()\">\n";
    }

    //將共用參數傳給子控制項
    private void ChildBind() {
        brt71main_form.HTProgRight = HTProgRight;
    }
</script>
<html xmlns="http://www.w3.org/1999/xhtml" >
<uc1:head_inc_form runat="server" ID="head_inc_form" />
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title><%=HTProgCap%></title>
</head>
<script language="javascript" type="text/javascript">
    var main = {};
    main.prgid = "<%#prgid%>";
    main.right = <%#HTProgRight%>;
    main.modify = "<%#modify%>";
    jMain={};
</script>

<body>
<form id="reg" name="reg" method="post">
    <INPUT TYPE="text" id="prgid" name="prgid" value="<%=prgid%>">
    <INPUT TYPE="text" id="modify" name=modify value="<%=modify%>">
    <input type=text id=cust_seq name=cust_seq>
    <input type=text id=apcust_no name=apcust_no>
    <input type=text id=apsqlno name=apsqlno>
    <input type=text id=tobject name=tobject>
    <input type=text id=rec_chk1 name=rec_chk1>
    <input type=text id=receipt name=receipt>
    <input type=text id=tar_mark name=tar_mark>
    <input type=text id=rec_mark name=rec_mark>

    <uc1:brt71main_form runat="server" ID="brt71main_form" />
    <uc1:brt71item_form runat="server" ID="brt71item_form" />

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
            window.parent.tt.rows = "100%,0%";
        }
        this_init();
    });

    function loadData() {
        //抓資料
        $.ajax({
            type: "post",
            url: "brt71_data.aspx?json=Y",
            data: {<%#ReqVal.ParseJson()%>},
            async: false,
            cache: false,
            success: function (json) {
                //if ($("#chkTest").length > 0) toastr.info("<a href='" + this.url + "' target='_new'>Debug(this_init)！<BR><b><u>(點此顯示詳細訊息)</u></b></a>");
                if (!isJson(json) || $("#chkTest").prop("checked")) {
                    $("#dialog").html("<a href='" + this.url + "' target='_new'>Debug！<u>(點此顯示詳細訊息)</u></a><hr>" + json);
                    $("#dialog").dialog({ title: 'Debug！', modal: true, maxHeight: 500, width: "90%" });
                    return false;
                }
                jMain = $.parseJSON(json);
            },
            error: function (xhr) {
                $("#dialog").html("<a href='" + this.url + "' target='_new'>請款資料載入失敗！<u>(點此顯示詳細訊息)</u></a><hr>" + xhr.responseText);
                $("#dialog").dialog({ title: '請款資料載入失敗！', modal: true, maxHeight: 500, width: "90%" });
            }
        });
    }

    function this_init() {
        loadData();

        //畫面準備
        brt71main_form.init();
        brt71item_form.init();
        //-----------------
        $("input.dateField").datepick();
        main.bind();//資料綁定
        $(".Lock").lock();
        $(".Hide").hide();
    }
    
    main.bind = function () {
        $("#cust_seq").val(jMain.ar_main.cust_seq);
        $("#apcust_no").val(jMain.ar_main.apcust_no);
        $("#apsqlno").val(jMain.ar_main.apsqlno);
        $("#tobject").val(jMain.ar_main.tobject);
        $("#rec_chk1").val(jMain.ar_main.rec_chk1);
        $("#receipt").val(jMain.ar_main.receipt);
        $("#tar_mark").val(jMain.ar_main.tar_mark);
        $("#Scode option[value='<%=ReqVal.TryGet("rec_scode", ReqVal.TryGet("scode"))%>']").prop("selected", true);

        if("<%=Request["tar_mark"]%>"==""&&"<%=Request["tar_mark"]%>"!="D") {
            $("#rec_mark").val("N");
        }else if("<%=Request["tar_mark"]%>"=="D") {
            $("#rec_mark").val("X");
        }

        brt71main_form.bind(jMain);
        brt71item_form.bind(jMain);

        if("<%=Request["company"]%>"!="") $("#company").val("<%=Request["company"]%>").triggerHandler("change");//收據種類
        if("<%=Request["rdate"]%>"!="") $("#rdate").val("<%=Request["rdate"]%>");//預定回收日
        if("<%=Request["pdate"]%>"!="") $("#pdate").val("<%=Request["pdate"]%>");//給付日期
        $("#acchk_date").val("<%=Request["acchk_date"]%>");//約定票期
        if("<%=Request["pre_money"]%>"=="") {//已預收未請款金額
            $("#pre_money").val("0");
        }else{
            $("#pre_money").val("<%=Request["pre_money"]%>");
        }
        $("#pre_money").triggerHandler("blur");

        brt71main_form.search_acc('R');
        brt71item_form.get_taxmoney();
        //2013/10/9增加抓取請款客戶主檔的專案付款條件
        get_custspay_flag();
    }

    //抓取客戶主檔的專案付款條件
    function get_custspay_flag(){
        var searchSql = "Select tspay_flag as spay_flag,tspay_mm as spay_mm from custz ";
        searchSql += " where cust_area='"+$("#cust_area").val()+"' and cust_seq='"+$("#tfx_cust_seq").val()+"'";
        $.ajax({
            type: "get",
            url: getRootPath() + "/ajax/JsonGetSqlData.aspx",
            data: { sql: searchSql },
            async: false,
            cache: false,
            success: function (json) {
                if (!isJson(json)) {
                    $("#dialog").html("<a href='" + this.url + "' target='_new'>Debug(get_custspay_flag)！<u>(點此顯示詳細訊息)</u></a><hr>" + json);
                    $("#dialog").dialog({ title: '抓取客戶主檔的專案付款條件有誤！', modal: true, maxHeight: 500, width: "90%" });
                    return false;
                }
                var JSONdata = $.parseJSON(json);
                if (JSONdata.length > 0) {
                    if(JSONdata[0].spay_flag=="Y"){
                        $("#cust_spay_flag").val("Y");
                        $("#cust_spay_mm").val(JSONdata[0].spay_mm);
                        if($("#cust_spay_mm").val()=="")$("#cust_spay_mm").val("10");//預設10個月
                    }else{
                        $("#cust_spay_flag").val("N");
                        $("#cust_spay_mm").val("0");
                    }
                }else{
                    alert("查無本筆請款客戶資料，請通知資訊部！");
                }
            },
            error: function (xhr) { 
                $("#dialog").html("<a href='" + this.url + "' target='_new'>抓取客戶主檔的專案付款條件有誤！<u>(點此顯示詳細訊息)</u></a><hr>"+xhr.responseText);
                $("#dialog").dialog({ title: '抓取客戶主檔的專案付款條件有誤！', modal: true, maxHeight: 500,width: "90%" });
            }
        });
    }

    //[開立請款單]
    function formSaveSubmit(){
        for (var curr = 1; curr <= CInt($("#curr").val()) ; curr++) {
            if($("#ar_money_"+curr).val()=="0"){
                alert("請款金額錯誤，請檢查開立金額！");
                return false;
            }
        }

        if(CDbl($("#unre_money").val())<0){
        alert("已預收金額超過合計請款金額，請重新輸入已預收金額！");
        return false;
        }

        if($("#company").val()==""){
            alert("請選擇收據種類！");
            return false;
        }

        if($("#tfx_cust_seq").val()==""){
            alert("請輸入帳款客戶！");
            return false;
        }

        if($("#Scode").val()==""){
            alert("請選擇收據營洽！");
            return false;
        }

        if($("#att_sql").val()==""){
            alert("請選擇聯絡人！");
            return false;
        }

        //2012/5/22修改必填，依對催帳會議決議
        if($("#rdate").val()==""){
            alert("請輸入預定回收日！");
            $("#rdate").focus();
            return false;
        }else{
            if ($("#rdate").val() != "" && !$.isDate($("#rdate").val())) {
                alert("預定回收日期格式錯誤(yyyy/mm/dd)或日期錯誤，請重新輸入預定回收日期！");
                return false;
            }
            //2013/10/9修改一般客戶不能超過開單日+3個月，客戶主檔有註記專案付款條件不能超過開單日+10個月
            var rdate =CDate($("#rdate").val());//預定回收日
            var stand_date =CDate($("#in_date").val()).addMonths(3);//開單日+3個月
            var over_date = CDate($("#in_date").val()).addMonths($("#cust_spay_mm").val());//開單日+付款條件月數
            if(rdate.getTime()> stand_date.getTime()){
                alert("發文日期或總發文日期不可小於系統日！");
                return false;
            }


	        stand_date=dateadd("m",3,reg.in_date.value)
		    over_date=dateadd("m",reg.cust_spay_mm.value,reg.in_date.value)
		    if cdate(reg.rdate.value) > cdate(stand_date) then
		        if reg.cust_spay_flag.value="Y" then
		            if cdate(reg.rdate.value) > cdate(over_date) then
		                msgbox "本請款客戶之「預定回收日」不能超過開單日期+" & reg.cust_spay_mm.value & "個月，請重新輸入「預定回收日」！"
		                reg.rdate.focus
		                exit function	             
                     end if
		        else
                     msgbox "本請款客戶之「預定回收日」不能超過開單日期+3個月，請重新輸入「預定回收日」！"
                     reg.rdate.focus
                     exit function
                end if
            end if	
        }

   if reg.ar_chk(1).checked then
                 if reg.pdate.value =empty and reg.acchk_date.value =empty then
                 msgbox "點選顯示請款備註，請輸入給付日期及約定票期！"
                 exit function
             end if
                 else
             if reg.pdate.value<>empty or reg.acchk_date.value<>empty then
                 reg.ar_chk(1).checked=true
                     end if	
                 end if
                 if reg.pdate.value <> empty and isdate(reg.pdate.value)=false then
                     msgbox "給付日期格式錯誤(yyyy/mm/dd)或日期錯誤，請重新輸入給付日期！"
                     exit function
                 end if
	
                 if reg.rdate.value <> empty and isdate(reg.rdate.value)=true then
                         if (reg.pdate.value <> empty and reg.pdate.value<>"") then
                         if (cdate(reg.rdate.value) < cdate(reg.pdate.value)) then
                         msgbox "預定回收日期不能早於給付日期，請重新輸入！"
                         exit function
                     end if
                 end if	
                 if (cdate(reg.rdate.value) < cdate(reg.in_date.value)) then
                             msgbox "預定回收日期不能早於開單日期，請重新輸入！"
                             reg.rdate.focus
                             exit function
                         end if				 
                     end if
                     if reg.acchk_date.value <> empty and isdate(reg.acchk_date.value)=false then
                                 msgbox "約定票期日期格式錯誤(yyyy/mm/dd)或日期錯誤，請重新輸入約定票期日期！"
                                 exit function
                             end if
                             if reg.acchk_date.value <> empty and isdate(reg.acchk_date.value)=true then
                                     if (reg.pdate.value <> empty and reg.pdate.value<>"") then
                                     if (cdate(reg.acchk_date.value) < cdate(reg.pdate.value)) then
                                     msgbox "約定票期不能早於給付日期，請重新輸入！"
                                     exit function
                                 end if
                             end if
                         end if
                         if reg.tax_money.value >2000 and reg.tax_chk(0).checked=false and reg.tax_chk(1).checked=false then
                                         msgbox "需代扣稅款：" & reg.tax_money.value & "，請選擇是否顯示代扣稅款！"
                                         exit function
                                     end if
                                     reg.ar_zip.disabled=false
                                     reg.ar_addr1.disabled=false
                                     reg.ar_addr2.disabled=false
                                     reg.action="Brt71Save.asp?modify=A&curr_no=<%=curr%>&scode="&reg.scode.value
	reg.submit

    }

    function postForm(url){
        $("input:disabled, select:disabled").unlock();
        $(".bsubmit").lock(!$("#chkTest").prop("checked"));

        var formData = new FormData($('#reg')[0]);
        ajaxByForm(url,formData)
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

