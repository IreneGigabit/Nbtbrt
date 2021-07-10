<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>

<script runat="server">
    protected string HTProgCap = "爭救案法定期限資料維護";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "brt19";//程式檔名前綴
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

    protected string opt_sqlno = "";
    protected string case_no = "";
    
    DBHelper conn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    DBHelper optconn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    DBHelper cnn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    private void Page_Unload(System.Object sender, System.EventArgs e) {
        if (conn != null) conn.Dispose();
        if (optconn != null) optconn.Dispose();
        if (cnn != null) cnn.Dispose();
    }

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
        optconn = new DBHelper(Conn.optK).Debug(Request["chkTest"] == "TEST");
        cnn = new DBHelper(Conn.Sysctrl).Debug(Request["chkTest"] == "TEST");
        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");
        
        submitTask = (Request["submittask"] ?? "").Trim();
        json = (Request["json"] ?? "").Trim().ToUpper();
        opt_sqlno = (Request["opt_sqlno"] ?? "").Trim();
        case_no = (Request["case_no"] ?? "").Trim();
 
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

        if (submitTask == "A") HTProgCap += "-<font color=blue>新增</font>";
        if (submitTask == "U") HTProgCap += "-<font color=blue>修改</font>";
        if (submitTask == "Q") HTProgCap += "-<font color=blue>查詢</font>";
        if (submitTask == "D") HTProgCap += "-<font color=blue>刪除</font>";

        if ((HTProgRight & 4) > 0 || (HTProgRight & 8) > 0 || (HTProgRight & 16) > 0 || (HTProgRight & 64) > 0) {
            if (((HTProgRight & 4) > 0 && submitTask == "A") || ((HTProgRight & 8) > 0 && submitTask == "U") || ((HTProgRight & 64) > 0 && submitTask == "U")) {
                StrFormBtn += "<input type=button value ='存　檔' id='button1' class='cbutton bsubmit' onclick='formSaveSubmit()'>\n";
                StrFormBtn += "<input type=button value ='重　填' id='buttonr' class='cbutton bsubmit' onclick='this_init()'>\n";
            }
        }

        StrFormRemark = "";
    }

    //將共用參數傳給子控制項
    private void ChildBind() {
    }

    private void QueryData() {
        DataTable dt = new DataTable();
        SQL = "SELECT  a.opt_sqlno,a.Case_no,a.seq,a.seq1,RTRIM(ISNULL(b.ap_cname1, '')) + RTRIM(ISNULL(b.ap_cname2, '')) AS cust_name";
        SQL += " ,a.appl_name,a.Bmark,Branch,a.arcase_name,a.pr_scode_name,a.opt_in_date,a.gs_date,a.bstep_grade,a.in_scode,a.scode_name";
        SQL += " ,(select code_name from cust_code as c where code_type='Ostat_code' and a.Bstat_code=c.cust_code) as dowhat_name,Last_date";
        SQL += ",''fseq,''ctrl_sqlno,''ctrl_date,''from_rs_no,''from_step_grade";
        SQL += " FROM vbr_opt a ";
        SQL += " inner join " + Sys.tdbname(Sys.GetSession("seBranch")) + ".apcust as b on a.cust_area=b.cust_area and a.cust_seq=b.cust_seq";
        SQL += " where a.Bmark in ('N') and (a.case_no is not null) and opt_sqlno='" + opt_sqlno + "'";
        optconn.DataTable(SQL, dt);
        if (dt.Rows.Count > 0) {
            DataRow dr = dt.Rows[0];

            dr["fseq"] = Sys.formatSeq1(dr.SafeRead("seq", ""), dr.SafeRead("seq1", ""), "", "", "");

            //抓取對應客收進度之法定期限
            SQL = "select sqlno,ctrl_date,from_rs_no,from_step_grade from ctrl_dmt where seq=" + dr["seq"] + " and seq1='" + dr["seq1"] + "' and step_grade=" + dr["bstep_grade"] + " and ctrl_type='A1' ";
            using (SqlDataReader dr0 = conn.ExecuteReader(SQL)) {
                if (dr0.Read()) {
                    dr["ctrl_sqlno"] = dr0.SafeRead("sqlno", "");
                    dr["ctrl_date"] = dr0.GetDateTimeString("ctrl_date", "yyyy/M/d");
                    dr["from_rs_no"] = dr0.SafeRead("from_rs_no", "");
                    dr["from_step_grade"] = dr0.SafeRead("from_step_grade", "");
                }
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
        Response.Write(",\"vbr_opt\":" + JsonConvert.SerializeObject(dt, settings).ToUnicode() + "\n");
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
	<input type="hidden" id="prgid" name="prgid" value="<%=prgid%>">
	<input type="hidden" id="submittask" name="submittask" value="<%=submitTask%>">
	<input type="hidden" id="case_no" name="case_no" value="<%=case_no%>">
	<input type="hidden" id="opt_sqlno" name="opt_sqlno" value="<%=opt_sqlno%>">

    <INPUT TYPE="hidden" id=Branch name=Branch>
	<INPUT TYPE="hidden" id=Bseq name=Bseq>
	<INPUT TYPE="hidden" id=BSeq1 name=BSeq1>
	<INPUT TYPE="hidden" id=Bstep_grade name=Bstep_grade>
	<INPUT TYPE="hidden" id=cust_name name=cust_name>
	<INPUT TYPE="hidden" id=appl_name name=appl_name>
	<INPUT TYPE="hidden" id=arcase_name name=arcase_name>
	<INPUT TYPE="hidden" id=in_scode name=in_scode>
	<INPUT TYPE="hidden" id=scode_name name=scode_name>
	<INPUT TYPE="hidden" id=ctrl_sqlno name=ctrl_sqlno>
	<INPUT TYPE="hidden" id=ctrl_date name=ctrl_date>
	<INPUT TYPE="hidden" id=old_Last_date name=old_Last_date>
	<INPUT TYPE="hidden" id=from_rs_no name=from_rs_no>
	<INPUT TYPE="hidden" id=from_step_grade name=from_step_grade>
	<INPUT TYPE="hidden" id=from_flag name=from_flag value="N">

    <table border="0" class="bluetable" cellspacing="1" cellpadding="2" width="50%" align="center">
		<tr>
			<td class=lightbluetable align="right" width="20%"  nowrap>交辦單號：</td>
			<td class=whitetablebg><span id="span_case_no"><=Case_no></span></td>
		</tr>
		<tr>
			<td class=lightbluetable align="right"  nowrap>案件編號：</td>
			<td class=whitetablebg><span id="span_fseq"></span></td>
		</tr>
		<tr>
			<td class=lightbluetable align="right">客戶名稱：</td>
			<td class=whitetablebg nowrap><span id="span_cust_name"></span></td>
		</tr>
		<tr>
			<td class=lightbluetable align="right">案件名稱：</td>
			<td class=whitetablebg nowrap><span id="span_appl_name"></span></td>
		</tr>
		<tr>
			<td class=lightbluetable align="right">案　　性：</td>
			<td class=whitetablebg nowrap><span id="span_arcase_name"></span></td>
		</tr>
		<tr>
			<td class=lightbluetable align="right">法定期限：</td>
			<td class=whitetablebg nowrap>
				<input type="text" id="Last_date" name="Last_date" size="10" class="dateField">
				<font color=blue>(對應區所客收進度：<span id="span_bstep_grade"></span>，法定期限：<span id="span_ctrl_date"></span>)</font>
				<input id="btn_queryjob" type="button" class="c1button" value="查官收未銷法定期限" onclick="queryjob()">
			</td>
		</tr>
    </table>

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
        if(main.submittask=="A"){
            window.parent.tt.rows = "100%,*%";
        }else if(main.submittask=="U"||main.submittask=="Q"||main.submittask=="Q"){
            window.parent.tt.rows = "30%,70%";
        }

        //取得畫面資料
        $.ajax({
            type: "get",
            url: "brt19_Edit.aspx?json=Y&<%#Request.QueryString%>",
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
                $("#dialog").html("<a href='" + this.url + "' target='_new'>爭救案法定期限資料載入失敗！<u>(點此顯示詳細訊息)</u></a><hr>" + xhr.responseText);
                $("#dialog").dialog({ title: '爭救案法定期限資料載入失敗！', modal: true, maxHeight: 500, width: "90%" });
            }
        });

        //畫面準備

        ////-----------------
        main.bind();//資料綁定
        $("input.dateField").datepick();
        $(".Lock").lock();
    }
    
    main.bind = function () {
        $("#Branch").val(jMain.vbr_opt[0].branch);
        $("#Bseq").val(jMain.vbr_opt[0].seq);
        $("#BSeq1").val(jMain.vbr_opt[0].seq1);
        $("#Bstep_grade").val(jMain.vbr_opt[0].bstep_grade);
        $("#cust_name").val(jMain.vbr_opt[0].cust_name);
        $("#appl_name").val(jMain.vbr_opt[0].appl_name);
        $("#arcase_name").val(jMain.vbr_opt[0].arcase_name);
        $("#in_scode").val(jMain.vbr_opt[0].in_scode);
        $("#scode_name").val(jMain.vbr_opt[0].scode_name);
        $("#ctrl_sqlno").val(jMain.vbr_opt[0].ctrl_sqlno);
        $("#ctrl_date").val(jMain.vbr_opt[0].ctrl_date);
        $("#old_Last_date").val(dateReviver(jMain.vbr_opt[0].last_date,'yyyy/M/d'));
        $("#from_rs_no").val(jMain.vbr_opt[0].from_rs_no);
        $("#from_step_grade").val(jMain.vbr_opt[0].from_step_grade);

        $("#span_case_no").html(jMain.vbr_opt[0].case_no);
        $("#span_fseq").html(jMain.vbr_opt[0].fseq);
        $("#span_cust_name").html(jMain.vbr_opt[0].cust_name);
        $("#span_appl_name").html(jMain.vbr_opt[0].appl_name);
        $("#span_arcase_name").html(jMain.vbr_opt[0].arcase_name);
        $("#Last_date").val(dateReviver(jMain.vbr_opt[0].last_date,'yyyy/M/d'));
        $("#span_bstep_grade").html(jMain.vbr_opt[0].bstep_grade);
        $("#span_ctrl_date").html(jMain.vbr_opt[0].ctrl_date);


        if(CInt(jMain.vbr_opt[0].bstep_grade)>1){
            $("#btn_queryjob").show();
        }else{
            $("#btn_queryjob").hide();
        }
    };

    //存檔
    function formSaveSubmit(){
        //檢核對應客收進度之法定期限是否存在
        if($("#ctrl_date").val()==""){
            alert("無對應客收進度之法定期限或法定期限已銷管，請檢查！確定修改期限，請通知資訊部。");
            return false;
        }

        if (confirm("是否確定修改??") == false) {
            return false;
        }else{
            if($("#Last_date").val()==""){
                alert("請輸入欲修改之法定期限！！");
                $("#Last_date").focus();
                return false;
            }
            var answer = "若確定修改，將同步修改對應客收進度之法定期限，請確認??";
            if (confirm(answer) == false) {
                return false;
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
    }

    //查詢未銷管法定期限進度
    function queryjob(){
        if($("#Bseq").val()==""){
            alert("無案件編號，無法查詢!!");
            return false;
        }

        var url = getRootPath() + "/brt6m/brt62_steplist.aspx?prgid=<%=prgid%>&seq=" + $("#Bseq").val()+"&seq1=" + $("#BSeq1").val()+"&step_grade=" + $("#Bstep_grade").val()+"&ctrl_type=A1";
        window.open(url, "myWindowOneN", "width=700,height=480,toolbar=yes,menubar=yes,resizable=yes,scrollbars=yes,status=0,top=50,left=80");
    }

    function lockjob(){
        $("#Last_date").lock();
    }

    $(".dateField").blur(function (e) {
        ChkDate(this);
    });
</script>
