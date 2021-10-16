<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Data"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>
<%@ Register Src="~/commonForm/Brta21form.ascx" TagPrefix="uc1" TagName="Brta21form" %>
<%@ Register Src="~/commonForm/brta311form.ascx" TagPrefix="uc1" TagName="brta311form" %>
<%@ Register Src="~/commonForm/Brta212form.ascx" TagPrefix="uc1" TagName="Brta212form" %>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<script runat="server">
    protected string HTProgCap = "國內案官方發文作業";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = HttpContext.Current.Request["prgid"] ?? "";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";
    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";
    protected string formFunction = "";
    
    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected Dictionary<string, string> Lock = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    protected Dictionary<string, string> Hide = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);

    protected string SQL = "";
    protected object objResult = null;

    protected string submitTask = "";
    protected string json = "";
    protected string seq = "";
    protected string seq1 = "";
    protected string cgrs = "";
    protected string prgid1 = "";

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
        json = (Request["json"] ?? "").Trim().ToUpper();
        seq = ReqVal.TryGet("seq");
        seq1 = ReqVal.TryGet("seq1");
        cgrs = ReqVal.TryGet("cgrs").ToUpper();
        prgid1 = ReqVal.TryGet("prgid1").ToLower();
        
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
        if (submitTask == "") submitTask = "A";
        if (submitTask == "A") HTProgCap += "-<font color=blue>新增</font>";
        if (submitTask == "U") HTProgCap += "-<font color=blue>修改</font>";
        if (submitTask == "Q") HTProgCap += "-<font color=blue>查詢</font>";
        if (submitTask == "D") HTProgCap += "-<font color=blue>刪除</font>";

        if (submitTask == "Q" || submitTask == "D") {
            Lock["QLock"] = "Lock";
        }
        
        if (prgid1 != "brta81") {
            if (cgrs == "CS") StrFormBtnTop += "<a href=\"" + Page.ResolveUrl("~/brtam/brta5m.aspx") + "?prgid=brta5m&cgrs=" + cgrs + "\" target=\"Etop\">[列印]</a>";
            if (cgrs == "GS") StrFormBtnTop += "<a href=\"" + Page.ResolveUrl("~/brtam/brta5m.aspx") + "?prgid=brta51m&cgrs=" + cgrs + "\" target=\"Etop\">[列印]</a>";
        } else {
            StrFormBtnTop += "<a href=\"" + Page.ResolveUrl("~/brtam/brta81List.aspx") + "?prgid=brta81\" target=\"Etop\">[回官方發文回條確認清單]</a>";
        }
        StrFormBtnTop += "<a class=\"imgCls\" href=\"javascript:void(0);\" >[關閉視窗]</a>";
        StrFormBtnTop += "<font style=\"cursor: pointer;color:darkblue\" onmouseover=\"this.style.color='red'\" onmouseout=\"this.style.color='darkblue'\" onclick=\"Help_Click()\">[說明]</font>";

        if ((HTProgRight & 4) > 0 || (HTProgRight & 8) > 0 || (HTProgRight & 16) > 0 || (HTProgRight & 64) > 0 || (HTProgRight & 128) > 0) {
            if (((HTProgRight & 4) > 0 && submitTask == "A") || ((HTProgRight & 8) > 0 && submitTask == "U") || ((HTProgRight & 64) > 0 && submitTask == "U")) {
                StrFormBtn += "<input type=button id='button1' value='存　檔' class='cbutton bsubmit' onclick='formAddSubmit()'>\n";
            }
            if (((HTProgRight & 16) > 0 && submitTask == "D")) {
                StrFormBtn += "<input type=button id='button1' value='刪　除' class='cbutton bsubmit' onclick='formDelSubmit()'>\n";
            }
            StrFormBtn += "<input type=button value='重　填' class='cbutton' onclick='this_init()'>\n";
        }
    }

    //將共用參數傳給子控制項
    private void ChildBind() {
        Brta21form.Lock = new Dictionary<string, string>(Lock);
        Brta311form.Lock = new Dictionary<string, string>(Lock);
        Brta212form.Lock = new Dictionary<string, string>(Lock);
        Brta311form.HTProgRight = HTProgRight;
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
    main.prgid1 = "<%#prgid1%>";
    main.right = <%#HTProgRight%>;
    main.submittask = "<%#submitTask%>";
    main.in_no = "<%#ReqVal.TryGet("in_no")%>";
    main.in_scode = "<%#ReqVal.TryGet("in_scode")%>";
    main.task = "<%#ReqVal.TryGet("task")%>";
    jMain={};
</script>

<body>
<table cellspacing="1" cellpadding="0" width="98%" border="0">
    <tr>
        <td class="text9" nowrap="nowrap">&nbsp;【<%=HTProgCode%><%=HTProgCap%>】
		<img src="<%=Page.ResolveUrl("~/images/icon1.gif")%>" style="cursor:pointer" align="absmiddle" title="期限管制" WIDTH="20" HEIGHT="20" onclick="dmt_IMG_Click(1)">&nbsp;
		<img src="<%=Page.ResolveUrl("~/images/icon2.gif")%>" style="cursor:pointer" align="absmiddle" title="收發進度" WIDTH="25" HEIGHT="20" onclick="dmt_IMG_Click(2)">&nbsp;
		<img src="<%=Page.ResolveUrl("~/images/icon4.gif")%>" style="cursor:pointer" align="absmiddle" title="交辦內容" WIDTH="18" HEIGHT="18" onclick="dmt_IMG_Click(4)">&nbsp;
		案件編號：<span id="span_fseq"></span>&nbsp;&nbsp;<span id="span_rs_no" style="display:none">發文序號：</span>
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
    <INPUT TYPE="hidden" id="prgid" name="prgid" value="<%=prgid%>">
    <INPUT TYPE="hidden" id="prgid1" name="prgid1" value="<%=prgid1%>">
    <INPUT TYPE="hidden" id="submittask" name=submittask value="<%=submitTask%>">
    <%if(prgid1=="brta81"){%>
	    <INPUT TYPE="hidden" id=opt_sqlno name=opt_sqlno>
	    <INPUT TYPE="hidden" id=Send_dept name=Send_dept>
    <%}%>
    <INPUT TYPE="hidden" id="ctrl_flg" name="ctrl_flg" value="N"><!--判斷有無預設期限管制 N:無,Y:有-->
    <INPUT TYPE="hidden" id="havectrl" name="havectrl" value="N"><!--判斷有預設期限管制，需至少輸入一筆資料 N:無,Y:有-->
    <INPUT TYPE="hidden" id=rs_sqlno name=rs_sqlno><!--進度流水號，for官發收入資料寫入智產系統用-->

    <uc1:Brta21form runat="server" id="Brta21form" /><!--案件主檔欄位畫面，與收文共同-->
    <uc1:brta311form runat="server" ID="Brta311form" /><!--官發欄位畫面-->
    <uc1:Brta212form runat="server" ID="Brta212form" /><!--管制欄位畫面，與收文共同-->
    <br />

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
            window.parent.tt.rows = "0%,100%";
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
        //取得交辦資料
        $.ajax({
            type: "get",
            //url: "brta31_edit.aspx?json=Y&<%#Request.QueryString%>",
            url: getRootPath() + "/ajax/_vstep_dmt.aspx?<%#Request.QueryString%>",
            async: false,
            cache: false,
            success: function (json) {
                if ($("#chkTest").length > 0) toastr.info("<a href='" + this.url + "' target='_new'>Debug(this_init)！<BR><b><u>(點此顯示詳細訊息)</u></b></a>");
                jMain = $.parseJSON(json);
            },
            error: function (xhr) {
                $("#dialog").html("<a href='" + this.url + "' target='_new'>案件資料載入失敗！<u>(點此顯示詳細訊息)</u></a><hr>" + xhr.responseText);
                $("#dialog").dialog({ title: '案件資料載入失敗！', modal: true, maxHeight: 500, width: "90%" });
            }
        });

        //畫面準備
        brta21form.init();
        brta311form.init();
        brta212form.init();
        //-----------------
        $("input.dateField").datepick();
        main.bind();//資料綁定
        $(".Lock").lock();
        $(".Hide").hide();
    }
    
    main.bind = function () {
        brta21form.bind(jMain.step_data);//主檔資料
        brta311form.bind(jMain.step_data,jMain.fees);//發文資料/交辦明細
        brta212form.bind(jMain.step_data,jMain.ctrl_data);//管制資料

        if(main.prgid1!="brta81"){
            if(main.submittask=="A"){
                $("#send_sel option[value='1']").prop("selected", true);//官方號碼:申請號
                brta212form.add_ctrl(false);//增加一筆管制
                $("#ctrl_type_1").val("A1");//管制種類:法定期限
                brta212form.add_ctrl(false);//增加一筆管制
                $("#ctrl_type_2").val("B1");//管制種類:自管期限
            }else{
                openread("N");	//控制特定欄位不能修改
                if(main.submittask=="U" && (main.prgid=="brta31"||main.prgid=="brta2m")){//官發維護
                    if((main.right&256)==0){
                        $("#receipt_type,#receipt_title").lock();
                    }else{//權限C才可修改
                        $("#receipt_type,#receipt_title").unlock();
                    }
                }
            }
        }

        if(main.prgid1=="brta81"){
            if(jMain.step_data.case_no!=""){
                $("#case_no_1").val(jMain.step_data.case_no);
                brta311form.getmoney(1);//依交辦單號抓取服務費、規費
            }
            if ((main.right & 128) != 0 || (main.right & 256) != 0) {
                $("input[name='rfees_stat'][value='" + jMain.step_data.fees_stat + "']").prop("checked", true);
            }
            openread("B");
            $("#button1").val("確　認");
        }

        $("#span_fseq").html(jMain.step_data.fseq);
        $("#opt_sqlno").val(jMain.step_data.opt_sqlno);
        $("#Send_dept").html(jMain.step_data.send_dept);
        $("#rs_sqlno").val(jMain.step_data.rs_sqlno);
    }

    //存檔
    function formAddSubmit(){
        if($("#submittask").val()=="A"||$("#submittask").val()=="U"){
            if($("#keyseq").val()=="N"){
                alert("本所編號變動過，請按[確定]按鈕，重新抓取資料!!!");
                return false;
            }

            if(chkNull("本所編號",$("#seq"))) return false;
            if(chkNull("本所編號副碼",$("#seq1"))) return false;
            if(chkNull("發文日期",$("#step_date"))) return false;
            if(chkNull("案性代碼",$("#rs_code"))) return false;
            if(chkNull("處理事項",$("#act_code"))) return false;
            if(chkNull("發文方式",$("#send_way"))) return false;

            if($("#spe_ctrl").val()=="E"){
                if($("#send_way").val()!="E"){
                    alert("電子申請案性之發文方式必須為電子送件，請檢查！");
                    return false;
                }
            }else if($("#spe_ctrl_4").val() != ""){
                if ($("#spe_ctrl_4").val().indexOf($("#send_way").val())==-1){
                    alert("此案性發文方式不可選擇["+$("#send_way option:selected" ).text()+"]，請檢查！\n若需修改，則請通知程序至國內案客戶收文作業修改後再發文。");
                    return false;
                }
                if ($("#send_way").val()!=$("#old_send_way").val()){
                    alert("若需修改發文方式，請通知程序至國內案客戶收文作業修改後再發文。");
                    return false;
                }
            }else{
                if ($("#send_way").val()!="M"||$("#send_way").val()!=$("#old_send_way").val()){
                    alert("非電子申請案性之發文方式應為親送，若確定要修改發文方式，則請通知程序至國內案客戶收文作業修改後再發文！");
                    return false;
                }
            }

            //20180525增加檢查發文日期如有異動要增加提醒
            if($("#send_way").val()=="E"){
                if( CDate($('#step_date').val()).getTime() !=  CDate($('#old_step_date').val()).getTime()){
                    alert("有修改發文日期，請通知資訊部處理電子送件檔案！");
                }
            }

            if($("#submittask").val()=="U"){
                if ($("#case_change").val()=="C"&&$("#rs_code").val()!=$("#case_arcase").val()){
                    if ($("#rs_class").val()!=$("#case_arcase_class").val()){
                        alert("發文結構分類與對應交辦結構分類不同，請重新輸入！");
                        return false;
                    }
                    if ($("#rs_code").val()!=$("#case_arcase").val()){
                        alert("發文案性代碼與對應交辦案性代碼不同，請重新輸入！");
                        return false;
                    }
                }
            }

            if ($("#cgrs").val()=="GS"){
                if(chkNull("發文對象",$("#send_cl"))) return false;
                if ($("#rs_class option:selected").attr("vref_code")!="A"){	//2012/12/24因應電子申請修改(不是新申請案要選擇官方號碼)
                    if(chkNull("官方號碼",$("#send_sel"))) return false;
                }
                //2006/7/11爭救案由專案室發文可不列入內商承辦統計，一般官發作業才需控制要輸入承辦
                if(main.prgid1!="brta81"){//正常的官發作業
                    if(chkNull("承辦",$("#pr_scode"))) return false;
                }
                if ((main.right & 128) != 0 || (main.right & 256) != 0) {
                    if($("input[name='rfees_stat']:checked").length==0){
                        alert("收費管制必須點選!!!");
                        return false;
                    }
                }

                //2006/6/13配合爭救案系統提醒發文方式
                if ($("#hmarkb").val()=="L"){
                    if ($("input[name='opt_branch']:eq(0)").prop("checked") == true) {
                        if (confirm("發文爭救案性確定自行發文，不需轉法律處發文？")!=true){
                            $("input[name='opt_branch']:eq(0)").focus();
                            return false;
                        }
                    }
                }
                //不可同一筆官發重覆輸入同一case_no
                for (j = 1; j <= CInt($("#arnum").val()); j++) {
                    var tcase_no1=$.trim($('#case_no_'+j).val());
                    if (tcase_no1!=""){
                        for (k=1; k<=  CInt($("#arnum").val()); k++) {
                            var tcase_no2=$.trim($('#case_no_'+k).val());
                            if (tcase_no2!=""){
                                if (j!=k){
                                    if (tcase_no1==tcase_no2){
                                        alert("同一筆官發不可重覆輸入同一筆交辦單號!!!");
                                        $("#case_no_"+j).focus();
                                        return false;
                                    }
                                }
                            }
                        }
                    }
                    //若無交辦單號，本次支出大於0，不可存檔
                    var tgs_fees=$('#gs_fees_'+j).val();
                    if (tgs_fees!=""){
                        if (CInt(tgs_fees)>0 && tcase_no1==""){
                            alert("若無交辦單號，本次支出不可大於零!!!");
                            $("#gs_fees_"+j).val(0);
                            return false;
                        }
                    }
                    //2008/1/14聖島四合一，檢查對應之交辦單之出名代理人要相同
                    if (j==1){
                        var tmp_agt_no=$("#case_agt_no_" + j).val();
                        //檢查交辦與發文出名代理人不一樣，顯示提示訊息
                        if (tmp_agt_no != ""){
                            if ($.trim(tmp_agt_no)!=$.trim($("#rs_agt_no").val())){
                                var answer=confirm("該交辦案件之出名代理人與發文出名代理人不同，是否確定要發文？(如需修改出名代理人請至交辦維護作業)");
                                if (answer !=true){
                                    return false;
                                }
                            }
                        }
                    }else{
                        var cur_agt_no=$("#case_agt_no_" + j).val();
                        if ($.trim(tmp_agt_no)!=$.trim(cur_agt_no)){
                            alert("同一筆官發所對應交辦之出名代理人必須相同！");
                            return false;
                        }
                    }
                }
				
                brta311form.countfees();
                if((main.right&128)!=0||(main.right&256)!=0){
                    if($("input[name='rfees_stat']:eq(0)").prop("checked")==true){//已交辦
                        if (CInt($("#fees").val())!=CInt($("#tot_fees").val())){
                            alert("交辦單本次規費支出合計("+CInt($("#tot_fees").val())+")需等於官發規費支出("+CInt($("#fees").val())+")!!!\n\n若交辦單本次規費支出合計須等於官發規費支出，請按確定!!!");
                            return false;
                        }
                    }
                }else{
                    if (CInt($("#fees").val())!=CInt($("#tot_fees").val())){
                        alert("交辦單本次規費支出合計("+CInt($("#tot_fees").val())+")需等於官發規費支出("+CInt($("#fees").val())+")!!!\n\n若交辦單本次規費支出合計須等於官發規費支出，請按確定!!!");
                        return false;
                    }
                }
                //官發出名代理人依交辦案件為主
                if (CInt($("#arnum").val()) > 0){
                    if ($.trim($("#case_agt_no_1").val()) != "") {
                        $("#rs_agt_no").val($("#case_agt_no_1").val());
                    }
                }
            }
			
            //管制，有管制期限，至少需輸入一筆
            if ($("#ctrl_flg").val()=="Y"){
                $("#havectrl").val("N");
                for (var n = 1; n <= CInt($("#ctrlnum").val()) ;n++) {
                    var ctrl_type= $("#ctrl_type_" + n).val();
                    var ctrl_date= $("#ctrl_date_" + n).val();
                    if(ctrl_type!=""&&ctrl_date!=""){
                        $("#havectrl").val("Y");
                        break;
                    }
                }
                if ($("#havectrl").val()=="N"){
                    var answer="此進度代碼有管制期限確定不輸入嗎???";
                    if(!confirm(answer)){
                        return false;
                    }
                }
            }

            //註冊費繳納期數與發文案性關聯性檢查
            switch ($("#rs_code").val()) {
                case "FF1":
                    if ($.trim($("#pay_times").val()) != "1") {
                        var ans = confirm("註冊費已繳期數與發文案性不符, 是否將註冊費已繳期數更正為『 第一期 』?");
                        if (ans != true) {
                            $("#rs_code").focus();
                            return false;
                        }else{
                            $("#pay_times").val( "1");
                            $("#hpay_times").val("1");
                            $("#pay_date").val($("#step_date").val());
                        }
                    }
                    break;
                case "FF2":
                    if ($.trim($("#pay_times").val()) != "2") {
                        var ans = confirm("註冊費已繳期數與發文案性不符, 是否將註冊費已繳期數更正為『 第二期 』?");
                        if (ans != true) {
                            $("#rs_code").focus();
                            return false;
                        }else{
                            $("#pay_times").val( "2");
                            $("#hpay_times").val("2");
                            $("#pay_date").val($("#step_date").val());
                        }
                    }
                    break;
                case "FF3":
                    if ($.trim($("#pay_times").val()) != "2") {
                        var ans = confirm("註冊費已繳期數與發文案性不符, 是否將註冊費已繳期數更正為『 第二期 』?");
                        if (ans != true) {
                            $("#rs_code").focus();
                            return false;
                        }else{
                            $("#pay_times").val( "2");
                            $("#hpay_times").val("2");
                            $("#pay_date").val($("#step_date").val());
                        }
                    }
                    break;
                case "FF0":
                    if ($.trim($("#pay_times").val()) != "A") {
                        var ans = confirm("註冊費已繳期數與發文案性不符, 是否將註冊費已繳期數更正為『 全期 』?");
                        if (ans != true) {
                            $("#rs_code").focus();
                            return false;
                        }else{
                            $("#pay_times").val( "A");
                            $("#hpay_times").val("A");
                            $("#pay_date").val($("#step_date").val());
                        }
                    }
                    break;
            }
			
            if($("#rs_code").val() == "FC11" || $("#rs_code").val() == "FC21" 
            || $("#rs_code").val() == "FC5"  || $("#rs_code").val() == "FC6" 
            || $("#rs_code").val() == "FC7"  || $("#rs_code").val() == "FC8" 
            || $("#rs_code").val() == "FCH"  || $("#rs_code").val() == "FCI"){
                if ($("#tot_num").val() == "0"){
                    alert("您所選的案性為一案多件, 但您發文件數僅一件, 請重新選取發文案性!!");
                    $("#rs_code").focus();
                    return false;
                }
            }
            if ($("#rs_code").val().substr(0,2) == "FD"){
                if ($("#tot_num").val() == "0"){
                    alert("您所選的案性為分割, 但您分割案件件數為零, 請重新選取發文案性!!");
                    $("#rs_code").focus();
                    return false;
                }
            }
            //變更案入檔時子本所編號檢查
            if($("#rs_code").val() == "FC11"  || $("#rs_code").val() == "FC21" 
            || $("#hrs_code").val() == "FC11" || $("#hrs_code").val() == "FC21" 
            || $("#rs_code").val() == "FC5"   || $("#rs_code").val() == "FC6" 
            || $("#rs_code").val() == "FC7"   || $("#rs_code").val() == "FC8" 
            || $("#rs_code").val() == "FCH"   || $("#rs_code").val() == "FCI"){
                // a.子本所編號確定是否都有按
                // b.子本所編號不可重複 也不可與主要本所編號相同
                var delcnt = 0;
                for(i = 1; i < CInt($("#tot_num").val()); i++){
                    var dseq = $.trim($('#dseq_'+i).val()) + "" + $.trim($('#dseq1A_'+i).val());
                    if ($('#keydseq_'+i).val()!="D"){
                        if ($('#keydseq_'+i).val() != "Y"){
                            alert("共同變更之本所編號尚未確認, 請按確定按鈕!!");
                            $('#dseq_'+i).focus();
                            return false;
                        }
                        for(j = 1; j < CInt($("#tot_num").val()); j++){
                            if (i != j && $('#dseqdel_'+j).val() != "D"){
                                if ( $.trim($('#dseq_'+i).val()) == $.trim($('#dseq_'+j).val())
                                &&	$.trim($('#dseq1A_'+i).val()) == $.trim($('#dseq1A_'+j).val()) ){
                                    alert("共同變更之本所不可重覆, 請刪除重覆的資料!! 重覆之本所編號為 : " + dseq);
                                    $('#dseq_'+i).focus();
                                    return false;
                                }
                            }
                        }
                        if ( $.trim($('#dseq_'+i).val()) == $.trim($('#seq').val()) 
                            && $.trim($('#dseq1A_'+i).val()) == $.trim($('#seq1').val()) ){
                            alert("共同變更之本所不可與主要本所編號相同!!");
                            $('#dseq_'+i).focus();
                            return false;
                        }
                    }else{
                        delcnt += 1;
                    }
                }
                if (CInt($("#tot_num").val()) - delcnt > 49){
                    alert("總變更件數不可超過五十筆!!");
                    return false;
                }
            }

            //分割案入檔時子本所編號檢查
            if ($("#rs_code").val().substr(0,2) == "FD"){
                // 子本所編號不可重複 也不可與主要本所編號相同
                var delcnt = 0;
                for(i = 1; i < CInt($("#tot_num").val()); i++){
                    var dseq = $.trim($('#dseq_'+i).val()) + "" + $.trim($('#dseq1A_'+i).val());
                    if ($('#keydseq_'+i).val()!="D"){
                        for(j = 1; j < CInt($("#tot_num").val()); j++){
                            if (i != j && $('#dseqdel_'+j).val() != "D"){
                                if ( $.trim($('#dseq_'+i).val()) == $.trim($('#dseq_'+j).val())
                                &&	$.trim($('#dseq1A_'+i).val()) == $.trim($('#dseq1A_'+j).val()) ){
                                    alert("分割案之本所不可重覆, 請刪除重覆的資料!! 重覆之本所編號為 : " + dseq);
                                    $('#dseq_'+i).focus();
                                    return false;
                                }
                            }
                        }
                        if ( $.trim($('#dseq_'+i).val()) == $.trim($('#seq').val()) 
                            && $.trim($('#dseq1A_'+i).val()) == $.trim($('#seq1').val()) ){
                            alert("分割案子案之本所不可與主要本所編號相同!!");
                            $('#dseq_'+i).focus();
                            return false;
                        }
                    }else{
                        delcnt += 1;
                    }
                }
                if (CInt($('#tot_num').val()) - delcnt > 30){
                    alert("總變更件數不可超過三十筆!!");
                    return false;
                }
            }

            //非電子送件不可選擇電子收據
            if ($("#send_way").val()!="E"&&$("#send_way").val()!="EA"){
                if ($("#receipt_type").val()=="E"){
                    alert("非電子送件不可選擇電子收據");
                    return false;
                }
            }

            //2019/5/17李協理提出
            //20210412增加延展案發文檢查.不可小於最小法定期限-半年
            if($("#rs_code").val() == "FR1"){
                if($("#a_last_date").val()!=""){
                    var ldate = CDate($('#a_last_date').val()).addMonths(-6);//最小法定期限-半年
                    var sdate = CDate($('#step_date').val());//發文日期
                    if(sdate.getTime()< ldate.getTime()){
                        if ($('#task').val()=="pr"){//交辦發文時只提醒
                            if(!confirm("延展案發文日期不可早於最小法定期限減半年！\n是否確認交辦發文?")){
                                return false;
                            }
                        }else if ($('#task').val()=="conf"){//發文確認時擋住
                            alert("延展案發文日期不可早於最小法定期限減半年！");
                            return false;
                        }
                    }
                }
            }
		
            if(main.submittask=="U" &$("#span_chk_type").html()!=""){
                alert($("#rs_no").val()+"進度會計已確認，若有修改「發文日期」、「應繳規費」、「交辦單號」、「發文案性」，\n請通知會計更正帳款資料，謝謝 !!!")
            }
            
            postForm(getRootPath() + "/brtam/Brta31_Update.aspx");
        }
    }

    function formDelSubmit(){
        var ans = confirm("是否確定刪除!!!");
        if (ans == true){
            $("#submittask").val("D");
            postForm(getRootPath() + "/brtam/Brta31_Update.aspx");
        }
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

    function openread(pchk){
        $("#btnQuery").hide();
        $("#seq,#seq1,#rs_class,#rs_code").lock();
        
        if(pchk=="B"){//爭救案
            $("#step_date,#mp_date,#send_cl,#send_cl1,#send_sel").lock();
            $("#rs_class,#rs_code,#act_code,#rs_detail").lock();
        }else{
            $("#rs_class,#rs_code").lock();
            if(main.submittask=="U" && (main.prgid=="brta31"||main.prgid=="brta2m")){
                //2012/12/24因應電子申請A0與創設申請A1可互相修改案性，所以有異動案性時要開放結構分類及案性代碼
                if($("#case_change").val()=="C"&&$("#rs_code").val()!=$("#case_arcase").val()){
                    $("#rs_class,#rs_code").unlock();
                }
            }
        }

        if((main.right&128)!=0||(main.right&256)!=0){
            $("input[name='rfees_stat']").lock();
        }
        $("#arAdd_button,#arres_button").lock();
        
        if(jMain.step_data.case_no!=""){
            $("#btncase_no_1").hide();
            $("#case_no_1,#gs_fees_1").lock();
        }else{
            if(CInt($("#fees").val())>0){
                $("#arAdd_button,#arres_button").unlock();
            }
        }
    }

    function Help_Click(){
        window.open(getRootPath() + "/brtam/國內案發收文系統操作手冊.htm","","width=700, height=500, top=50, left=50, toolbar=no, menubar=no, location=no, directories=no, resizeable=no, status=no, scrollbars=yes");
    }
</script>

