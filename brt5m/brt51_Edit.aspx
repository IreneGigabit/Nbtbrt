<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Data"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>
<%@ Register Src="~/commonForm/brt511form.ascx" TagPrefix="uc1" TagName="brt511form" %>
<%@ Register Src="~/commonForm/Brta212form.ascx" TagPrefix="uc1" TagName="brta212form" %>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>




<script runat="server">
    protected string HTProgCap = "國內案客收確認作業-畫面2";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "brt51";//程式檔名前綴
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

    protected string submitTask = "";
    protected string json = "";
    protected string cgrs = "CR";
    //protected string code = "";//todo.sqlno
    //protected string in_scode = "";
    //protected string in_no = "";
    //protected string cust_area = "";
    //protected string cust_seq = "";
    //protected string endflag51 = "";
    //protected string end_date51 = "";
    //protected string end_code51 = "";
    //protected string end_type51 = "";
    //protected string end_remark51 = "";
    //protected string seqend_flag = "";

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

        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        HTProgCap = myToken.Title.Replace("收文", "<font color=blue>收文</font>");
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
        if ((HTProgRight & 8) > 0 || (HTProgRight & 16) > 0) {
            if (cgrs == "CR") StrFormBtnTop += "<a href=\"" + Page.ResolveUrl("~/brtam/brta4m.aspx") + "?prgid=brta4m&cgrs=" + cgrs + "\" target=\"Etop\">[列印]</a>";
            if (cgrs == "GR") StrFormBtnTop += "<a href=\"" + Page.ResolveUrl("~/brtam/brta4m.aspx") + "?prgid=brta41m&cgrs=" + cgrs + "\" target=\"Etop\">[列印]</a>";
            StrFormBtnTop += "<font style=\"cursor: pointer;color:darkblue\" onmouseover=\"this.style.color='red'\" onmouseout=\"this.style.color='darkblue'\" onclick=\"Help_Click()\">[說明]</font>";

            if (submitTask == "A" || (Request["closewin"] ?? "") == "Y") {
                StrFormBtnTop += "<a class=\"imgCls\" href=\"javascript:void(0);\" >[關閉視窗]</a>\n";
            }
        }

        if (submitTask != "Q") {
            if ((HTProgRight & 4) > 0 || (HTProgRight & 8) > 0 || (HTProgRight & 16) > 0 || (HTProgRight & 64) > 0) {
                if (((HTProgRight & 4) > 0 && submitTask == "A") || ((HTProgRight & 8) > 0 && submitTask == "U") || ((HTProgRight & 64) > 0 && submitTask == "U")) {
                    StrFormBtn += "<input type=button value ='存　檔' class='cbutton bsubmit' onclick='formAddSubmit()'>\n";
                }
                if (((HTProgRight & 16) > 0 && submitTask == "D")) {
                    StrFormBtn += "<input type=button value ='刪　除' class='cbutton bsubmit' onclick='formDelSubmit()'>\n";
                }
                StrFormBtn += "<input type=button value ='重　填' class='cbutton' onclick='this_init()'>\n";
            }
        }
    }

    //將共用參數傳給子控制項
    private void ChildBind() {
    }
    
    private void QueryData() {
        Dictionary<string, string> add_cr = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
        if (submitTask == "A") {
            add_cr["code"] = Request["code"];
            add_cr["in_no"] = Request["in_no"];
            add_cr["in_scode"] = Request["in_scode"];
            add_cr["cust_area"] = Request["cust_area"];
            add_cr["cust_seq"] = Request["cust_seq"];
            add_cr["endflag51"] = Request["endflag51"];
            add_cr["end_date51"] = Request["end_date51"];
            add_cr["end_code51"] = Request["end_code51"];
            add_cr["end_type51"] = Request["end_type51"];
            add_cr["end_remark51"] = Request["end_remark51"];
            add_cr["seqend_flag"] = Request["seqend_flag"];

            add_cr["cgrs"] = "CR";
            add_cr["seq1"] = "_";
            add_cr["step_date"] = DateTime.Today.ToShortDateString();
            add_cr["send_cl"] = "1";
            add_cr["step_grade"] = "1";
            
            //交辦檔
            DataTable dtCaseMain = Sys.GetCaseDmtMain(conn, Request["in_no"]);
            if (dtCaseMain.Rows.Count > 0) {
                DataRow dr = dtCaseMain.Rows[0];
                add_cr["seq"] = dr.SafeRead("seq", "");
                add_cr["seq1"] = dr.SafeRead("seq1", "");
                //進度序號
                SQL = "select isnull(step_grade,0)+1 from dmt where seq = '" + add_cr["seq"] + "' and seq1 = '" + add_cr["seq1"] + "'";
                object objResult = conn.ExecuteScalar(SQL);
                string nstep_grade = (objResult == DBNull.Value || objResult == null) ? "1" : objResult.ToString();
                add_cr["step_grade"] = nstep_grade;
                
                //收文代碼
 		        add_cr["rs_code"]  = dr.SafeRead("arcase","");
		        add_cr["codemark"]  = dr.SafeRead("codemark","");//收文代碼備註：B爭救案
		        add_cr["dmt_term1"]  = dr.GetDateTimeString("dmt_term1","yyyy/M/d");//專用期限起日check非創申案有期限者提醒需註記註冊費繳費狀態
		        add_cr["dmt_term2"]  = dr.GetDateTimeString("dmt_term2","yyyy/M/d");//專用期限迄日
                add_cr["act_code"] = "_";
               
                SQL = " select rs_type,rs_class,rs_code,rs_detail,case_stat,case_stat_name,spe_ctrl ";
                SQL += "from vcode_act ";
                SQL += "where rs_code = '" + dr.SafeRead("arcase", "") + "' and act_code = '_' ";
                SQL += "and rs_type = '" + dr.SafeRead("arcase_type", "") + "'";
                SQL += "and cg = 'C' and rs = 'R'";
                add_cr["spe_ctrl3"] = "N";//Y:案性需管制法定期限
                using (SqlDataReader dr0 = conn.ExecuteReader(SQL)) {
                    if (dr0.Read()) {
                        add_cr["rs_type"] = dr0.SafeRead("rs_type", "");
                        add_cr["rs_class"] = dr0.SafeRead("rs_class", "");
                        add_cr["rs_detail"] = dr0.SafeRead("rs_detail", "");
                        add_cr["case_stat"] = dr0.SafeRead("case_stat", "");
                        add_cr["case_statnm"] = dr0.SafeRead("case_stat_name", "");

                        if (dr0.SafeRead("back_flag", "") == "Y") {
                            add_cr["rs_detail"] += "(請復案)";
                        }
                        if (dr0.SafeRead("end_flag", "") == "Y") {
                            add_cr["rs_detail"] += "(請結案)";
                        }

                        string[] spe_ctrl = dr0.SafeRead("spe_ctrl", "").Split(',');//抓取案性控制
                        if (spe_ctrl.Length >= 3) add_cr["spe_ctrl3"] = (spe_ctrl[2] == "" ? "N" : spe_ctrl[2]);//Y:案性需管制法定期限
                    }
                }
                //20160910 收文方式改由營洽登錄帶入值
                add_cr["send_way"] = dr.SafeRead("send_way", "");
                //客戶期限
                add_cr["cust_date"] = dr.GetDateTimeString("cust_date", "yyyy/M/d");
                //承辦期限
                add_cr["pr_date"] = dr.GetDateTimeString("pr_date", "yyyy/M/d");
                //營洽輸入法定期限
                add_cr["case_last_date"] = dr.GetDateTimeString("last_date", "yyyy/M/d");
            }

        }
        
        var settings = new JsonSerializerSettings()
        {
            Formatting = Formatting.Indented,
            ContractResolver = new LowercaseContractResolver(),//key統一轉小寫
            Converters = new List<JsonConverter> { new DBNullCreationConverter(), new TrimCreationConverter() }//dbnull轉空字串且trim掉
        };
        Response.Write("{");
        Response.Write("\"request\":" + JsonConvert.SerializeObject(ReqVal, settings).ToUnicode() + "\n");
        Response.Write(",\"add_cr\":" + JsonConvert.SerializeObject(add_cr, settings).ToUnicode() + "\n");//交辦客收預設值
        Response.Write("}");
        Response.End();
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
    main.in_no = "<%#ReqVal.TryGet("in_no")%>";
    main.in_scode = "<%#ReqVal.TryGet("in_scode")%>";
    main.cust_area = "<%#ReqVal.TryGet("cust_area")%>";
    main.cust_seq = "<%#ReqVal.TryGet("cust_seq")%>";
    main.code = "<%#ReqVal.TryGet("code")%>";//todo.sqlno
    main.change = "<%#ReqVal.TryGet("change")%>";//異動簽核狀態
    jMain={};
</script>

<body>
<table cellspacing="1" cellpadding="0" width="98%" border="0">
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
    <INPUT TYPE="hidden" id=submittask name=submittask value="<%=submitTask%>">
    <INPUT TYPE="hidden" id=prgid name=prgid value="<%=prgid%>">
    <input type="hidden" id=codemark name=codemark>
    <input type="hidden" id=dmt_term1 name=dmt_term1>
    <input type="hidden" id=dmt_term2 name=dmt_term2>
    <input type="hidden" id=endflag51 name=endflag51 value="<%=Request["endflag51"]%>">
    <input type="hidden" id=end_date51 name=end_date51 value="<%=Request["end_date51"]%>">
    <input type="hidden" id=end_code51 name=end_code51 value="<%=Request["end_code51"]%>">
    <input type="hidden" id=end_type51 name=end_type51 value="<%=Request["end_type51"]%>">
    <input type="hidden" id=end_remark51 name=end_remark51 value="<%=Request["end_remark51"]%>">
    <input type="hidden" id=seqend_flag name=seqend_flag value="<%=Request["seqend_flag"]%>"><!--結案註記-->
    <input type="hidden" id=case_last_date name=case_last_date><!--營洽輸入法定期限-->
    <input type="hidden" id=spe_ctrl3 name=spe_ctrl3><!--Y:案性需管制法定期限-->
    <input type="hidden" id=seq name=seq>
    <input type="hidden" id=seq1 name=seq1>
    <input type="hidden" id="cust_area" name="cust_area">
    <input type="hidden" id="cust_seq" name="cust_seq">
    <center>
         <uc1:brt511form runat="server" ID="brt511form" /><!--~/commonForm/brt511form.ascx-->
         <uc1:brta212form runat="server" ID="brta212form" /><!--~/commonForm/brta212form.ascx-->
     </center>

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
            url: "brt51_edit.aspx?json=Y&<%#Request.QueryString%>",
            //url: getRootPath() + "/ajax/_case_dmt.aspx?<%=Request.QueryString%>",
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
        brt511form.init();//收文form
        brta212form.init();//管制期限form
        //-----------------
        $("input.dateField").datepick();
        main.bind();//資料綁定
        $(".Lock").lock();
        $(".Hide").hide();
    }
    
    main.bind = function () {
        $("#codemark").val(jMain.add_cr.codemark);
        $("#dmt_term1").val(jMain.add_cr.dmt_term1);
        $("#dmt_term2").val(jMain.add_cr.dmt_term2);
        $("#case_last_date").val(jMain.add_cr.last_date);
        $("#seq").val(jMain.add_cr.seq);
        $("#seq1").val(jMain.add_cr.seq1);
        $("#spe_ctrl3").val(jMain.add_cr.spe_ctrl3);
        $("#cust_area").val(jMain.add_cr.cust_area);
        $("#cust_seq").val(jMain.add_cr.cust_seq);

        brt511form.bind(jMain.add_cr);//收文資料
        brta212form.bind(jMain.add_cr,null);//管制資料
        
        if (main.submittask == "A") {
            if ($("#hrs_code").val() == "FC11" || $("#hrs_code").val() == "FC21" || $("#hrs_code").val() == "FC6" || $("#hrs_code").val() == "FC7" || $("#hrs_code").val() == "FC8" || $("#hrs_code").val() == "FC5"
                || $("#hrs_code").val() == "FCI" || $("#hrs_code").val() == "FCH" || $("#hrs_code").val() == "FT2" || $("#hrs_code").val() == "FL5" || $("#hrs_code").val() == "FL6") {
                brt511form.getdseq(jMain.add_cr);//一案多件
            }
            if ($("#hrs_code").val().Left(2) == "FD") {
                brt511form.getdseq1(jMain.add_cr);//分割
            }
            brt511form.getCtrl(jMain.add_cr);//產生預設期限
        }

        //顯示爭救案交辦欄位
        if ($("#codemark").val()=="B"){
            $("#show_optstat").show();
            //2013/11/5修改，爭救案性預設帶官收法定期限
            if(CInt($("#nstep_grade"))!=1){
                $("#btnqrygrlastdate").show();//顯示[查官收未銷法定期限按鈕]
                brta212form.add_ctrl(false);
                $("#ctrl_type_"+$("#ctrlnum").val()).val("A1");
                getgrlast_date();//抓取官收最小法定期限A1
            }
        }
  
        //顯示註冊費繳費狀態，當非創申案立新案
        if (main.submittask == "A") {
            if (CInt($("#nstep_grade").val()) == 1) {
                if ($("#hrs_class").val() != "A1") {
                    $("#show_paytimes").show();
                }
            } else {
                if ($("#seqend_flag").val() == "Y") {//2010/10/6修改為結案註記有勾選結案才顯示
                    $("#show_endstat").show();
                } else {
                    $("input[name='end_stat']").prop("checked", false);
                }
            }
        }
    }

    function Help_Click(){
        window.open(getRootPath() + "/brtam/國內案發收文系統操作手冊.htm","","width=700, height=500, top=50, left=50, toolbar=no, menubar=no, location=no, directories=no, resizeable=no, status=no, scrollbars=yes");
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

    //存檔
    function formAddSubmit(){
        if (main.submittask=="A"||main.submittask=="U"){
            if (chkNull("收文日期", reg.step_date)) return false;
            if (chkNull("案性代碼", reg.rs_code)) return false;
            if (chkNull("處理事項", reg.act_code)) return false;

            for (var n = 1; n <= CInt($("#ctrlnum").val()) ;n++) {
                var ctrl_type= $("#ctrl_type_" + n).val();
                var ctrl_date= $("#ctrl_date_" + n).val();
                if(ctrl_date==""){
                    alert("請輸入管制日期！！");
                    $("#ctrl_date_" + n).focus();
                    return false;
                }
            }

            //check交辦爭救案需管制一筆法定期限,2011/9/27檢查新立案且要管制法定期限案性，程序輸入期限需與營洽相同
            if(($("#codemark").val()=="B"&&$("input[name='opt_stat']:eq(0)").prop("checked") == true)
                ||($("#nstep_grade").val()=="1"&&$("#spe_ctrl3").val()=="Y")){
                var ctrl_flag="N";
                for (var n = 1; n <= CInt($("#ctrlnum").val()) ;n++) {
                    var ctrl_type= $("#ctrl_type_" + n).val();
                    var ctrl_date= $("#ctrl_date_" + n).val();
                    if(ctrl_type=="A1"){
                        ctrl_flag="Y";
                        if(ctrl_date==""){
                            alert("請輸入管制日期！！");
                            $("#ctrl_date_" + n).focus();
                            return false;
                        }else{
                            if($("#nstep_grade").val()=="1"&&$("#spe_ctrl3").val()=="Y"){
                                if(CDate($("#case_last_date").val()).getTime()!=CDate(ctrl_date).getTime()){
                                    alert("輸入法定期限("+ctrl_date + ")與營洽輸入法定期限(" + $("#case_last_date").val() + ")不同，請檢查！若確定營洽輸入有誤，煩請返回前一編修作業述明原因並退回營洽修改。");
                                    $("#ctrl_date_" + n).focus();
                                    return false;
                                }
                            }
                        }
                        break;
                    }
                }

                if(ctrl_flag=="N"){
                    if($("#codemark").val()=="B"){
                        alert("交辦爭救案需管制一筆法定期限，請增加一筆管制！");
                    }else{
                        alert("交辦此案性需管制一筆法定期限，請增加一筆管制！");
                    }
                    return false;
                }
            }

            //check非創申案立新案且有輸入專用期限者，提醒程序要輸入註冊費繳納狀態
            if (main.submittask=="A"){
                if($("#nstep_grade").val()=="1"&&$("#hrs_class").val()!="A1"){
                    if($("#dmt_term1").val()!=""&&$("#dmt_term2").val()!=""){
                        if($("#pay_times").val()==""){
                            var answer=confirm("註冊費繳納狀態未輸入，確定存檔?(註：一案多件子案件系統不會一併修改，如需修改請至案件主檔維護)");
                            if(answer==false){
                                $("#pay_times").focus();
                                return false;
                            }
                        }
                    }
                }

                if($("#pr_scode").val()==""){
                    alert("案件需至承辦執行後續作業，請選擇承辦人員！");
                    $("#pr_scode").focus();
                    return false;
                }
            }
            
            //檢查交辦結案需管制結案期限或結案完成期限
            if($("#seqend_flag").val()=="Y"){//2010/10/6修改為結案註記有勾選結案才檢查
                var ctrl_flag="N";
                for (var n = 1; n <= CInt($("#ctrlnum").val()) ;n++) {
                    var ctrl_type= $("#ctrl_type_" + n).val();
                    var ctrl_date= $("#ctrl_date_" + n).val();
                    if (($("input[name='end_stat']:eq(0)").prop("checked") == true&&ctrl_type=="B61")//送會計確認
                        ||($("input[name='end_stat']:eq(1)").prop("checked") == true&&ctrl_type=="B6")//待結案處理
                        ) {
                        ctrl_flag="Y";
                        if(ctrl_date==""){
                            alert("請輸入管制日期！！");
                            $("#ctrl_date_" + n).focus();
                            return false;
                        }
                        break;
                    }
                }

                if(ctrl_flag=="N"){
                    alert("交辦結案需管制一筆結案期限，送會計確認請增加一筆結案完成期限管制、待結案處理請增加一筆結案期限管制！");
                    return false;
                }
            }
        }

        //20160923 增加檢查發文方式
        if($("#send_way").val()==""){
            alert("請選擇發文方式！");
            return false;
        }
        if($("#send_way").val()!=$("#old_send_way").val()){
            var answer=confirm("您選擇的發文方式與營洽交辦不同，確定存檔?");
            if(answer==false){
                $("#send_way").focus();
                return false;
            }
        }
	
        //$("select,textarea,input,span").unlock();
        $("input:disabled, select:disabled").unlock();
        $(".bsubmit").lock(!$("#chkTest").prop("checked"));

        var formData = new FormData($('#reg')[0]);
        ajaxByForm("Brt51_Update1.aspx",formData)
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
                            window.parent.Etop.location.href= getRootPath() +'/brt5m/brt51_list.aspx?prgid=brt51';
                        }
                    }
                }
            });
        });
    }
</script>

