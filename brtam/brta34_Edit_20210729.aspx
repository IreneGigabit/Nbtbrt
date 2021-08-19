<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Data"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>
<%@ Register Src="~/commonForm/Brta21form.ascx" TagPrefix="uc1" TagName="Brta21form" %>
<%@ Register Src="~/commonForm/brta34form.ascx" TagPrefix="uc1" TagName="brta34form" %>
<%@ Register Src="~/commonForm/Brta212form.ascx" TagPrefix="uc1" TagName="Brta212form" %>
<%@ Register Src="~/commonForm/dmt_upload_Form.ascx" TagPrefix="uc1" TagName="dmt_upload_Form" %>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<script runat="server">
    protected string HTProgCap = "國內案本所發文作業";//HttpContext.Current.Request["prgname"];//功能名稱
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
    protected string case_no = "";
    protected string source = "";
    protected string emg_scode = "";//總管處程序人員-正本
    protected string emg_agscode = "";//總管處程序人員-副本
  
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
        seq = ReqVal.TryGet("seq", ReqVal.TryGet("aseq"));
        seq1 = ReqVal.TryGet("seq1", ReqVal.TryGet("aseq1"));
        case_no = ReqVal.TryGet("case_no");

        source = "cgrs";//上傳檔案的來源

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
        if (submitTask == "A") HTProgCap += "-<font color=blue>新增</font>";
        if (submitTask == "U") HTProgCap += "-<font color=blue>修改</font>";
        if (submitTask == "Q") HTProgCap += "-<font color=blue>查詢</font>";
        if (submitTask == "D") HTProgCap += "-<font color=blue>刪除</font>";
        
        if (submitTask == "Q" || submitTask == "D") {
            Lock["QLock"] = "Lock";
            Lock["Qdisabled"] = "Lock";
        }
        if (submitTask == "U") {
            Lock["Qdisabled"] = "Lock";
        }
        
        StrFormBtnTop += "<font style=\"cursor: pointer;color:darkblue\" onmouseover=\"this.style.color='red'\" onmouseout=\"this.style.color='darkblue'\" onclick=\"Help_Click()\">[說明]</font>";
        StrFormBtnTop += "<a class=\"imgCls\" href=\"javascript:void(0);\" >[關閉視窗]</a>";

        if ((HTProgRight & 4) > 0 || (HTProgRight & 8) > 0 || (HTProgRight & 16) > 0 || (HTProgRight & 64) > 0 || (HTProgRight & 128) > 0) {
            if (((HTProgRight & 4) > 0 && submitTask == "A") || ((HTProgRight & 8) > 0 && submitTask == "U") || ((HTProgRight & 64) > 0 && submitTask == "U")) {
                    StrFormBtn += "<input type=button id='button1' value='存　檔' class='cbutton bsubmit' onclick='formAddSubmit()'>\n";
            }
            if (((HTProgRight & 16) > 0 && submitTask == "D")) {
                    StrFormBtn += "<input type=button id='button1' value='刪　除' class='cbutton bsubmit' onclick='formDelSubmit()'>\n";
            }
            StrFormBtn += "<input type=button value='重　填' class='cbutton' onclick='this_init()'>\n";
        }

        emg_scode = Sys.getRoleScode("M", Sys.GetSession("syscode"), Sys.GetSession("dept"), "mg_pror");//總管處程序人員-正本
        emg_agscode = Sys.getRoleScode("M", Sys.GetSession("syscode"), Sys.GetSession("dept"), "mg_prorm");//總管處程序人員-副本
    }

    //將共用參數傳給子控制項
    private void ChildBind() {
        dmt_upload_Form.uploadsource = source;
        
        Brta21form.Lock = new Dictionary<string, string>(Lock);
        Brta34form.Lock = new Dictionary<string, string>(Lock);
        Brta212form.Lock = new Dictionary<string, string>(Lock);
        dmt_upload_Form.Lock = new Dictionary<string, string>(Lock);
    }

    private void QueryData() {
        Dictionary<string, string> add_zs = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);

        //案件主檔
        DataTable dtDmt = Sys.GetDmt(conn, seq, seq1);
        if (dtDmt.Rows.Count > 0) add_zs["ectrlnum"] = dtDmt.Rows[0].SafeRead("ectrlnum", "0");

        add_zs["cgrs"] = Request["cgrs"];
        if (submitTask == "A") {
            add_zs["case_no"] = Request["case_no"];
            add_zs["cr_rs_no"] = Request["cr_rs_no"];
            add_zs["rs_no"] = "";
            add_zs["seq"] = Request["seq"];
            add_zs["seq1"] = Request["seq1"];
            add_zs["fseq"] = Sys.formatSeq(add_zs["seq"], add_zs["seq1"], "", Sys.GetSession("seBranch"), Sys.GetSession("dept"));
            add_zs["fees"] = "0";
            add_zs["fees_stat"] = "N";
            add_zs["step_date"] = DateTime.Today.ToShortDateString();
            //總收發文日期
            //台北所總收發當天就會發文
            add_zs["mp_date"] = DateTime.Today.ToShortDateString();
            if (Sys.GetSession("seBranch") != "N") {
                switch (DateTime.Today.DayOfWeek) {
                    case DayOfWeek.Friday: add_zs["mp_date"] = DateTime.Today.AddDays(3).ToShortDateString(); break;//星期五加三天
                    case DayOfWeek.Saturday: add_zs["mp_date"] = DateTime.Today.AddDays(2).ToShortDateString(); break;//星期六加兩天
                    default: add_zs["mp_date"] = DateTime.Today.AddDays(1).ToShortDateString(); break;//加一天
                }
            }

            add_zs["rs_type"] = Sys.getRsType();
            add_zs["opt_branch"] = Sys.GetSession("seBranch");
            add_zs["receive_way"] = "R6";
            add_zs["send_cl"] = "A";

            //取得本筆客收進度代碼資料
            DataTable dtStepDmtCR = Sys.StepDmt(conn, "", "", "and rs_sqlno='" + Request["cr_rs_sqlno"] + "'");
            if (dtStepDmtCR.Rows.Count > 0) {
                DataRow dr = dtStepDmtCR.Rows[0];
                add_zs["rs_class"] = dr.SafeRead("rs_class", "");
                add_zs["rs_code"] = dr.SafeRead("rs_code", "");
                add_zs["act_code"] = dr.SafeRead("act_code", "");
            }
        }

        if (submitTask == "U" || submitTask == "Q" || submitTask == "D") {
            SQL = "SELECT * from vstep_dmt where rs_no='" + Request["rs_no"] + "'";
            DataTable dtAttCase = new DataTable();
            conn.DataTable(SQL, dtAttCase);
            if (dtAttCase.Rows.Count > 0) {
                DataRow dr = dtAttCase.Rows[0];
                add_zs["rs_no"] = dr.SafeRead("rs_no", "");
                add_zs["branch"] = dr.SafeRead("branch", "");
                add_zs["seq"] = dr.SafeRead("seq", "");
                add_zs["seq1"] = dr.SafeRead("seq1", "");
                add_zs["step_grade"] = dr.SafeRead("step_grade", "");
                add_zs["step_date"] = dr.GetDateTimeString("step_date", "yyyy/M/d");
                add_zs["mp_date"] = dr.GetDateTimeString("mp_date", "yyyy/M/d");
                add_zs["gov_date"] = dr.GetDateTimeString("gov_date", "yyyy/M/d");
                add_zs["send_cl"] = dr.SafeRead("send_cl", "");
                add_zs["send_cl1"] = dr.SafeRead("send_cl1", "");
                add_zs["send_sel"] = dr.SafeRead("send_sel", "");
                add_zs["send_way"] = dr.SafeRead("send_way", "");
                add_zs["receive_way"] = dr.SafeRead("receive_way", "");
                add_zs["rs_type"] = Sys.getRsType();
                add_zs["rs_class"] = dr.SafeRead("rs_class", "");
                add_zs["rs_code"] = dr.SafeRead("rs_code", "");
                add_zs["act_code"] = dr.SafeRead("act_code", "");

                //取得案件狀態
                SQL = " select rs_type,rs_class,rs_code,act_code,case_stat,case_stat_name ";
                SQL += "from vcode_act ";
                SQL += "where rs_code = '" + add_zs["rs_code"] + "' ";
                SQL += "and act_code = '" + add_zs["act_code"] + "' ";
                SQL += "and rs_type = '" + add_zs["rs_type"] + "'";
                SQL += "and cg = '" + dr.SafeRead("cg", "") + "' ";
                SQL += "and rs = '" + dr.SafeRead("rs", "") + "'";
                using (SqlDataReader dr0 = conn.ExecuteReader(SQL)) {
                    if (dr0.Read()) {
                        add_zs["ncase_stat"] = dr0.SafeRead("case_stat", "");
                        add_zs["ncase_statnm"] = dr0.SafeRead("case_stat_name", "");
                    }
                }

                add_zs["rs_detail"] = dr.SafeRead("rs_detail", "");
                add_zs["doc_detail"] = dr.SafeRead("doc_detail", "");
                add_zs["fees"] = dr.SafeRead("fees", "");
                add_zs["case_no"] = dr.SafeRead("case_no", "");
                add_zs["fees_stat"] = dr.SafeRead("fees_stat", "");
                add_zs["pr_scode"] = dr.SafeRead("pr_scode", "");
                add_zs["opt_branch"] = dr.SafeRead("opt_branch", "");
                add_zs["rs_agt_no"] = dr.SafeRead("rs_agt_no", "");

                add_zs["cr_rs_no"] = "";
                DataTable dtStepCR= Sys.StepDmt(conn, add_zs["seq"], add_zs["seq1"], "and zs_rs_sqlno='" + dr.SafeRead("rs_sqlno", "") + "'");
                if (dtStepCR.Rows.Count > 0) {
                    add_zs["case_no"] = dtStepCR.Rows[0].SafeRead("case_no", "");
                    add_zs["cr_rs_no"] = dtStepCR.Rows[0].SafeRead("rs_no", "");
                }
            }
        }

        //對應客收交辦
        DataTable dtCaseCR = Sys.GetCaseDmtMain(conn, seq, seq1, add_zs["case_no"]);

        //管制資料
        DataTable dtCtrl = new DataTable();
        //抓取客收進度之法定期限
		SQL = " select sqlno,ctrl_type,ctrl_remark,ctrl_date,null as resp_date,null as resp_grade from ctrl_dmt ";
        SQL += " where rs_no='" + add_zs["cr_rs_no"] + "' and ctrl_type='A1' ";
		SQL+= " union select sqlno,ctrl_type,ctrl_remark,ctrl_date,resp_date,resp_grade from resp_dmt ";
        SQL += " where rs_no='" + add_zs["cr_rs_no"] + "' and ctrl_type='A1' ";
        SQL += " order by ctrl_date";
        conn.DataTable(SQL, dtCtrl);

        //附件檔
        string where = "";
        if (ReqVal.TryGet("step_grade") != "") where += " and step_grade=" + ReqVal["step_grade"];
        if (ReqVal.TryGet("attach_sqlno") != "") where += " and attach_sqlno=" + ReqVal["attach_sqlno"];
        if (ReqVal.TryGet("att_sqlno") != "") where += " and att_sqlno=" + ReqVal["att_sqlno"];
        DataTable dtCaseAttach = Sys.GetDmtAttach(conn, seq, seq1, source, where);

        var settings = new JsonSerializerSettings()
        {
            Formatting = Formatting.Indented,
            ContractResolver = new LowercaseContractResolver(),//key統一轉小寫
            Converters = new List<JsonConverter> { new DBNullCreationConverter(), new TrimCreationConverter() }//dbnull轉空字串且trim掉
        };
        Response.Write("{");
        Response.Write("\"request\":" + JsonConvert.SerializeObject(ReqVal, settings).ToUnicode() + "\n");
        Response.Write(",\"add_zs\":" + JsonConvert.SerializeObject(add_zs, settings).ToUnicode() + "\n");//交辦本發預設值
        Response.Write(",\"cr_case\":" + JsonConvert.SerializeObject(dtCaseCR, settings).ToUnicode() + "\n");//對應客收交辦
        Response.Write(",\"zs_ctrl\":" + JsonConvert.SerializeObject(dtCtrl, settings).ToUnicode() + "\n");//管制資料
        Response.Write(",\"case_attach\":" + JsonConvert.SerializeObject(dtCaseAttach, settings).ToUnicode() + "\n");//附件檔
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
    main.task = "<%#ReqVal.TryGet("task")%>";
    main.cgrs = "<%#ReqVal.TryGet("cgrs")%>";
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
    <INPUT TYPE="text" id="prgid" name="prgid" value="<%=prgid%>">
    <INPUT TYPE="text" id="prgid1" name="prgid1" value="<%=Request["prgid1"]%>">
    <INPUT TYPE="text" id="submittask" name=submittask value="<%=submitTask%>">

    <input type="text" id="cr_rs_no" name="cr_rs_no" value="<%=Request["cr_rs_no"]%>">
    <input type="text" id="cr_rs_sqlno" name="cr_rs_sqlno" value="<%=Request["cr_rs_sqlno"]%>">
    <input type="text" id="cr_step_grade" name="cr_step_grade" value="<%=Request["cr_step_grade"]%>">
    <INPUT TYPE="text" id="ctrl_flg" name="ctrl_flg" value="Y"><!--判斷有無預設期限管制 N:無,Y:有,本發有客收之期限管制-->
    <INPUT TYPE="text" id="havectrl" name="havectrl" value="N"><!--判斷有預設期限管制，需至少輸入一筆資料 N:無,Y:有-->
    <INPUT TYPE="text" id="menu" name="menu" value="<%=Request["menu"]%>">
    <input type="text" id="emg_scode" name="emg_scode" value="<%=emg_scode%>"><!--Email通知總管處人員，正本收件者-->
    <input type="text" id="emg_agscode" name="emg_agscode" value="<%=emg_agscode%>"><!--Email通知總管處人員，副本收件者-->

    <uc1:Brta21form runat="server" id="Brta21form" /><!--案件主檔欄位畫面，與收文共同-->
    <uc1:brta34form runat="server" ID="Brta34form" /><!--本發欄位畫面-->
    <uc1:Brta212form runat="server" ID="Brta212form" /><!--管制欄位畫面，與收文共同-->
    <uc1:dmt_upload_Form runat="server" ID="dmt_upload_Form" /><!--文件上傳畫面-->
    <br />
    <%if (prgid=="brt63"&&Request["task"]=="cancel"){%>
	    <input type="text" name="rsqlno" id="rsqlno">
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
            url: "brta34_edit.aspx?json=Y&<%#Request.QueryString%>",
            //url: getRootPath() + "/ajax/_case_dmt.aspx?<%=Request.QueryString%>",
            async: false,
            cache: false,
            success: function (json) {
                toastr.info("<a href='" + this.url + "' target='_new'>Debug！<BR><b><u>(點此顯示詳細訊息)</u></b></a>");
                jMain = $.parseJSON(json);
            },
            error: function (xhr) {
                $("#dialog").html("<a href='" + this.url + "' target='_new'>案件資料載入失敗！<u>(點此顯示詳細訊息)</u></a><hr>" + xhr.responseText);
                $("#dialog").dialog({ title: '案件資料載入失敗！', modal: true, maxHeight: 500, width: "90%" });
            }
        });

        //畫面準備
        brta21form.init();
        brta34form.init();
        brta212form.init();
        upload_form.init();
        //-----------------
        $("input.dateField").datepick();
        main.bind();//資料綁定
        $(".Lock").lock();
        $(".Hide").hide();
    }
    
    main.bind = function () {
        brta21form.bind(jMain.add_zs);//主檔資料
        brta34form.bind(jMain.add_zs,jMain.cr_case);//發文資料/對應客收交辦
        brta212form.bind(jMain.add_zs,jMain.zs_ctrl);//管制資料
        upload_form.bind(jMain.case_attach);//顯示上傳文件資料

        if($("#submittask").val()=="A"){
            //主檔資料
            $("#btnseq").hide();//[確定]
            $("#btnQuery").hide();//[查詢本所編號]
            //期限管制資料之進度查詢及銷管制button名稱,增加及減少一筆不能執行
            $("#btndis").val("進度查詢");
            $("#Add_button,#res_button").hide();//[增加/減少一筆管制]
        }

        if($("#submittask").val()=="U"||$("#submittask").val()=="D"){
            $("#btndis").val("進度查詢");
        }
    }

    function Help_Click(){
        window.open(getRootPath() + "/brtam/國內案發收文系統操作手冊.htm","","width=700, height=500, top=50, left=50, toolbar=no, menubar=no, location=no, directories=no, resizeable=no, status=no, scrollbars=yes");
    }

    //存檔
    function formAddSubmit(){
        if($("#submittask").val()=="A"){
            //新增時要Email通知總管處人員，所以要判斷有無收件者
            if($("#emg_scode").val()==""||$("#emg_agscode").val()==""){
                alert("系統找不到Email通知總管處人員，無法發信，請通知系統維護人員！");
                return false;
            }
        }

        if($("#submittask").val()=="A"||$("#submittask").val()=="U"){
            if($('#keyseq').val()=="N"){
                alert( "本所編號變動過，請按[確定]按鈕，重新抓取資料!!!");
                return false;
            }
            if(chkNull("本所編號",$("#seq"))) return false;
            if(chkNull("本所編號副碼",$("#seq1"))) return false;
            if(chkNull("發文日期",$("#step_date"))) return false;
            if(chkNull("案性代碼",$("#rs_code"))) return false;
            if(chkNull("處理事項",$("#act_code"))) return false;

            if($('#cgrs').value=="ZS"){
                if(chkNull("來文機關",$("#send_cl"))) return false;
                if(chkNull("發文方式",$("#receive_way"))) return false;
            }

            //管制，有管制期限，至少需輸入一筆
            if($('#ctrl_flg').val()=="Y"){
                $("#havectrl").val("N");
                for (var n = 1; n <= CInt($("#ctrlnum").val()) ;n++) {
                    var ctrl_type= $("#ctrl_type_" + n).val();
                    var ctrl_date= $("#ctrl_date_" + n).val();
                    if (ctrl_type !=""&&ctrl_date!="") {
                        $("#havectrl").val("Y");
                        break;
                    }
                }
                if($("#havectrl").val()=="N"){
                    var ans = confirm("此進度有管制期限確定不輸入嗎???");
                    if(!ans){
                        return false;
                    }
                }
            }
		
            postForm(getRootPath() + "/brtam/Brta34_Update.aspx");
        }
    }

    function formDelSubmit(){
        var ans = confirm("是否確定刪除!!!");
        if (ans == true){
            $("#submittask").val("D");
            postForm(getRootPath() + "/brtam/Brta34_Update.aspx");
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
</script>

