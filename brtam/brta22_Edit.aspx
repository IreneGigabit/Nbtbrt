<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Data"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>
<%@ Register Src="~/commonForm/Brta21form.ascx" TagPrefix="uc1" TagName="Brta21form" %>
<%@ Register Src="~/commonForm/brt511form.ascx" TagPrefix="uc1" TagName="brt511form" %>
<%@ Register Src="~/commonForm/Brta212form.ascx" TagPrefix="uc1" TagName="brta212form" %>

<script runat="server">
    protected string HTProgCap = "國內案客戶收文作業";//HttpContext.Current.Request["prgname"];//功能名稱
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
    protected string cgrs = "";

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
        cgrs = ReqVal.TryGet("cgrs");

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
        if (submitTask == "Q" || submitTask == "D") {
            Lock["Qdisabled"] = "Lock";
            Lock["Qdisabled_opt"] = "Lock";
        }
        
        if (submitTask == "A") HTProgCap += "-<font color=blue>新增</font>";
        if (submitTask == "U") HTProgCap += "-<font color=blue>修改</font>";
        if (submitTask == "Q") HTProgCap += "-<font color=blue>查詢</font>";
        if (submitTask == "D") HTProgCap += "-<font color=blue>刪除</font>";
        
        if ((HTProgRight & 8) > 0 || (HTProgRight & 16) > 0) {
            if (cgrs == "CR") StrFormBtnTop += "<a href=\"" + Page.ResolveUrl("~/brtam/brta4m.aspx") + "?prgid=brta4m&cgrs=" + cgrs + "\" target=\"Etop\">[列印]</a>";
            if (cgrs == "GR") StrFormBtnTop += "<a href=\"" + Page.ResolveUrl("~/brtam/brta4m.aspx") + "?prgid=brta41m&cgrs=" + cgrs + "\" target=\"Etop\">[列印]</a>";
            StrFormBtnTop += "<a class=\"imgCls\" href=\"javascript:void(0);\" >[關閉視窗]</a>\n";
            StrFormBtnTop += "<font style=\"cursor: pointer;color:darkblue\" onmouseover=\"this.style.color='red'\" onmouseout=\"this.style.color='darkblue'\" onclick=\"Help_Click()\">[說明]</font>";
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
            add_cr["step_date"] = DateTime.Today.ToShortDateString();
            add_cr["mp_date"] = DateTime.Today.AddDays(-1).ToShortDateString();
            add_cr["send_cl"] = "1";
            add_cr["rs_type"] = Sys.getRsType();
        }

        if (submitTask == "U" || submitTask == "Q" || submitTask == "D") {
            SQL = "Select * From vstep_dmt Where RS_No = '" + Request["rs_no"] + "'";
            DataTable dtStepMgt = new DataTable();
            conn.DataTable(SQL, dtStepMgt);

            if (dtStepMgt.Rows.Count > 0) {
                DataRow dr = dtStepMgt.Rows[0];

                add_cr["rs_no"] = dr.SafeRead("rs_no", "");
                add_cr["branch"] = dr.SafeRead("branch", "");
                add_cr["seq"] = dr.SafeRead("seq", "");
                add_cr["seq1"] = dr.SafeRead("seq1", "");
                add_cr["fseq"] = Sys.formatSeq(add_cr["seq"], add_cr["seq1"], "", Sys.GetSession("seBranch"), Sys.GetSession("dept"));
                add_cr["step_grade"] = dr.SafeRead("step_grade", "");
                add_cr["nstep_grade"] = dr.SafeRead("step_grade", "");
                add_cr["cgrs"] = dr.SafeRead("cg", "") + dr.SafeRead("rs", "");
                add_cr["step_date"] = dr.GetDateTimeString("step_date", "yyyy/M/d");
                add_cr["mp_date"] = dr.GetDateTimeString("mp_date", "yyyy/M/d");
                add_cr["send_cl"] = dr.SafeRead("send_cl", "");
                add_cr["receive_no"] = dr.SafeRead("receive_no", "");
                add_cr["rs_type"] = Sys.getRsType();
                add_cr["rs_class"] = dr.SafeRead("rs_class", "");
                add_cr["rs_code"] = dr.SafeRead("rs_code", "");
                add_cr["act_code"] = dr.SafeRead("act_code", "");

                //取得結構分類、代碼、處理事項名稱
                SQL = "select code_name from cust_code where code_type='" + add_cr["rs_type"] + "' and cust_code='" + add_cr["rs_class"] + "'";
                objResult = conn.ExecuteScalar(SQL);
                add_cr["rs_class_name"] = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();
                SQL = "select rs_detail from code_br where rs_type='" + add_cr["rs_type"] + "' and rs_code='" + add_cr["rs_code"] + "' and cr='Y' ";
                objResult = conn.ExecuteScalar(SQL);
                add_cr["rs_code_name"] = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();
                SQL = "select code_name from cust_code where code_type='tact_code' and cust_code='" + add_cr["act_code"] + "'";
                objResult = conn.ExecuteScalar(SQL);
                add_cr["act_code_name"] = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();

                //取得案件狀態
                SQL = " select rs_type,rs_class,rs_code,act_code,case_stat,case_stat_name ";
                SQL += "from vcode_act ";
                SQL += "where rs_code = '" + add_cr["rs_code"] + "' ";
                SQL += "and act_code = '" + add_cr["act_code"] + "' ";
                SQL += "and rs_type = '" + add_cr["rs_type"] + "'";
                SQL += "and cg = 'C' and rs = 'R'";
                using (SqlDataReader dr0 = conn.ExecuteReader(SQL)) {
                    if (dr0.Read()) {
                        add_cr["case_stat"] = dr0.SafeRead("case_stat", "");
                        add_cr["case_statnm"] = dr0.SafeRead("case_stat_name", "");
                    }
                }
                add_cr["rs_detail"] = dr.SafeRead("rs_detail", "");
                add_cr["doc_detail"] = dr.SafeRead("doc_detail", "");
                add_cr["cs_rs_no"] = dr.SafeRead("cs_rs_no", "");

                add_cr["cs_detail"] = "";
                add_cr["send_way"] = dr.SafeRead("send_way", "");
                if (add_cr["cs_rs_no"] != "") {
                    SQL = "select rs_no,rs_detail from cs_dmt where rs_no='" + add_cr["cs_rs_no"] + "'";
                    add_cr["cs_detail"] = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();
                    SQL = "select rs_no,send_way from cs_dmt where rs_no='" + add_cr["cs_rs_no"] + "'";
                    add_cr["send_way"] = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();
                }
                add_cr["pr_scode"] = dr.SafeRead("pr_scode", "");
                add_cr["opt_stat"] = dr.SafeRead("opt_stat", "");
                add_cr["codemark"] = "";

                if (add_cr["opt_stat"] == "") {
                    SQL = "select mark from code_br where mark='B' and rs_type='" + add_cr["rs_type"] + "' and rs_class ='" + add_cr["rs_class"] + "'";
                    SQL += " and " + add_cr["cgrs"] + "='Y' and rs_code = '" + add_cr["rs_code"] + "'";
                    add_cr["codemark"] = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();
                } else {
                    add_cr["codemark"] = "B";
                }
                add_cr["send_sel"] = dr.SafeRead("send_sel", "");
                add_cr["case_no"] = dr.SafeRead("case_no", "");
                add_cr["cust_prod"] = dr.SafeRead("cust_prod", "");

                //取得in_no
                //2014/6/18因case_dmt.arcase_class為程式連結並非皆與rs_class相同，所以增加抓取rs_class，以便異動修改客收代碼判斷
                SQL = "select in_scode,in_no,arcase_type,arcase_class,arcase,change,receipt_type,receipt_title";
                SQL += ",(select rs_class from code_br where rs_type=a.arcase_type and rs_code=a.arcase) as case_rs_class";
                SQL += " from case_dmt a where case_no = '" + add_cr["case_no"] + "'";
                using (SqlDataReader dr0 = conn.ExecuteReader(SQL)) {
                    if (dr0.Read()) {
                        add_cr["in_scode"] = dr0.SafeRead("in_scode", "");
                        add_cr["in_no"] = dr0.SafeRead("in_no", "");
                        add_cr["arcase_type"] = dr0.SafeRead("arcase_type", "");
                        add_cr["arcase_class"] = dr0.SafeRead("arcase_class", "");
                        add_cr["case_rs_class"] = dr0.SafeRead("case_rs_class", "");
                        add_cr["arcase"] = dr0.SafeRead("arcase", "");
                        add_cr["change"] = dr0.SafeRead("change", "");
                        //20180712增加顯示收據種類
                        add_cr["receipt_type"] = dr0.SafeRead("receipt_type", "");
                        add_cr["receipt_title"] = dr0.SafeRead("receipt_title", "");
                    }
                }
            }
        }

        //管制資料
        DataTable dtCtrl = new DataTable();
        SQL = " select sqlno,ctrl_type,ctrl_remark,ctrl_date,null as resp_date,null as resp_grade from ctrl_dmt ";
        SQL += " where rs_no='" + Request["rs_no"] + "'";
        SQL += " union select sqlno,ctrl_type,ctrl_remark,ctrl_date,resp_date,resp_grade from resp_dmt ";
        SQL += " where rs_no='" + Request["rs_no"] + "'";
        SQL += " order by ctrl_date";
        conn.DataTable(SQL, dtCtrl);

        var settings = new JsonSerializerSettings()
        {
            Formatting = Formatting.Indented,
            ContractResolver = new LowercaseContractResolver(),//key統一轉小寫
            Converters = new List<JsonConverter> { new DBNullCreationConverter(), new TrimCreationConverter() }//dbnull轉空字串且trim掉
        };
        Response.Write("{");
        Response.Write("\"request\":" + JsonConvert.SerializeObject(ReqVal, settings).ToUnicode() + "\n");
        Response.Write(",\"add_cr\":" + JsonConvert.SerializeObject(add_cr, settings).ToUnicode() + "\n");//交辦官發預設值
        Response.Write(",\"cr_ctrl\":" + JsonConvert.SerializeObject(dtCtrl, settings).ToUnicode() + "\n");//管制資料
        Response.Write("}");
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
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/jquery.Snoopy.date.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/jquery.irene.form.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/client_chk.js")%>"></script>
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
    <INPUT TYPE="text" id=prgid name=prgid value="<%=prgid%>">
    <INPUT TYPE="text" id=submittask name=submittask value="<%=submitTask%>">
    <INPUT TYPE="text" id=ctrl_flg name=ctrl_flg value="N"><!--判斷有無預設期限管制 N:無,Y:有-->
    <INPUT TYPE="text" id=havectrl name=havectrl value="N"><!--判斷有預設期限管制，需至少輸入一筆資料 N:無,Y:有-->
    <input type="text" id=codemark name=codemark>
    <input type="text" id=oldopt_stat name=oldopt_stat>
    <input type="text" id=case_no name=case_no>
    <center>
        <uc1:Brta21form runat="server" ID="Brta21form" /><!--~/commonForm/brt21form.ascx-->
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
            url: "brta22_edit.aspx?json=Y&<%#Request.QueryString%>",
            //url: getRootPath() + "/ajax/_case_dmt.aspx?<%=Request.QueryString%>",
            async: false,
            cache: false,
            success: function (json) {
                //if ($("#chkTest").prop("checked")) toastr.info("<a href='" + this.url + "' target='_new'>Debug(_case_dmt)！<BR><b><u>(點此顯示詳細訊息)</u></b></a>");
                toastr.info("<a href='" + this.url + "' target='_new'>Debug！<BR><b><u>(點此顯示詳細訊息)</u></b></a>");
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
        $("#oldopt_stat").val(jMain.add_cr.oldopt_stat);
        $("#case_no").val(jMain.add_cr.case_no);

        brta21form.bind(jMain.add_cr);//主檔資料
        brt511form.bind(jMain.add_cr);//收文資料
        brta212form.bind(jMain.add_cr,jMain.cr_ctrl);//管制資料
        
        if (jMain.opt_stat == "Y") {
            $("input[name='opt_stat']").lock();
        }

        if (main.submittask == "A") {
            $("#ctrl_flg").val("N");
        }
        
        if(main.submittask=="U"||main.submittask=="Q"||main.submittask=="D"){
            if ($("#hrs_code").val() == "FC11" || $("#hrs_code").val() == "FC21" || $("#hrs_code").val() == "FC6" || $("#hrs_code").val() == "FC7" || $("#hrs_code").val() == "FC8" || $("#hrs_code").val() == "FC5"
                || $("#hrs_code").val() == "FCI" || $("#hrs_code").val() == "FCH" || $("#hrs_code").val() == "FT2" || $("#hrs_code").val() == "FL5" || $("#hrs_code").val() == "FL6") {
                brt511form.getdseq(jMain.add_cr);//一案多件
            }
            if ($("#hrs_code").val().Left(2) == "FD") {
                brt511form.getdseq1(jMain.add_cr);//分割
            }
            
            //顯示爭救案交辦欄位
            if ($("#codemark").val()=="B"){
                $("#show_optstat").show();
                if (jMain.opt_stat == "Y") {
                    $("#sp_optstat").show();
                }
            }
        }
    }

    function Help_Click(){
        window.open(getRootPath() + "/brtam/國內案發收文系統操作手冊.htm","","width=700, height=500, top=50, left=50, toolbar=no, menubar=no, location=no, directories=no, resizeable=no, status=no, scrollbars=yes");
    }

    //存檔
    function formAddSubmit(){
        if (main.submittask=="A"||main.submittask=="U"){
            if (chkNull("收文日期", reg.step_date)) return false;
            if (chkNull("案性代碼", reg.rs_code)) return false;
            if (chkNull("處理事項", reg.act_code)) return false;

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
        ajaxByForm("Brta22_Update.aspx",formData)
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

