<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Data"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>
<%@ Register Src="~/commonForm/dmt_CR_Form.ascx" TagPrefix="uc1" TagName="dmt_CR_Form" %>
<%@ Register Src="~/commonForm/dmt_ctrl_Form.ascx" TagPrefix="uc1" TagName="dmt_ctrl_Form" %>



<script runat="server">
    protected string HTProgCap = "國內案客收確認作業";//HttpContext.Current.Request["prgname"];//功能名稱
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
    protected string json = "";

    protected string submitTask = "";
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

        json = ReqVal.TryGet("json").ToUpper();
        submitTask = ReqVal.TryGet("submittask").ToUpper();
        
        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        HTProgCap = myToken.Title.Replace("收文", "<font color=blue>收文</font>");
        DebugStr = myToken.DebugStr;
        if (HTProgRight >= 0) {
            if (json == "Y") QueryData();
            
            PageLayout();
            ChildBind();
            this.DataBind();
        }
    }

    private void PageLayout() {
        if ((HTProgRight & 8) > 0 || (HTProgRight & 16) > 0) {
            if (cgrs == "CR") StrFormBtnTop += "<a href=\"" + Page.ResolveUrl("~/brtam/brta4m.aspx") + "?prgid=brta4m&cgrs=" + cgrs + "\" target=\"Etop\">[列印]</a>";//***todo
            if (cgrs == "GR") StrFormBtnTop += "<a href=\"" + Page.ResolveUrl("~/brtam/brta4m.aspx") + "?prgid=brta41m&cgrs=" + cgrs + "\" target=\"Etop\">[列印]</a>";//***todo
            StrFormBtnTop += "<font style=\"cursor: pointer;color:darkblue\" onmouseover=\"this.style.color='red'\" onmouseout=\"this.style.color='darkblue'\" onclick=\"Help_Click()\">[說明]</font>";//***todo

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
        Dictionary<string, string> crmain = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
        crmain["seq"] = ReqVal.TryGet("seq");
        crmain["seq1"] = ReqVal.TryGet("seq1");
        crmain["in_scode"] = ReqVal.TryGet("in_scode");
        crmain["in_no"] = ReqVal.TryGet("in_no");
        crmain["code"] = ReqVal.TryGet("code");
        crmain["cust_area"] = ReqVal.TryGet("cust_area");
        crmain["cust_seq"] = ReqVal.TryGet("cust_seq");
        crmain["endflag51"] = ReqVal.TryGet("endflag51");
        crmain["end_date51"] = ReqVal.TryGet("end_date51");
        crmain["end_code51"] = ReqVal.TryGet("end_code51");
        crmain["end_type51"] = ReqVal.TryGet("end_type51");
        crmain["end_remark51"] = ReqVal.TryGet("end_remark51");
        crmain["seqend_flag"] = ReqVal.TryGet("seqend_flag");

        crmain["seq1"] = ReqVal.TryGet("seq1");
        crmain["step_date"] = DateTime.Today.ToShortDateString();
        crmain["cg"] = "C";
        crmain["rs"] = "R";
        crmain["cgrs"] = cgrs;
        crmain["send_cl"] = "1";
        crmain["act_code"] = "_";

        string spe_ctrl3 = "N";
        string send_way = "";
        SQL = "select a.*,b.mark as codemark,c.dmt_term1,c.dmt_term2 ";
	    SQL+="from case_dmt a inner join code_br b on b.dept='T' and b.cr='Y' and b.rs_type=a.arcase_type and b.rs_code=a.arcase ";
	    SQL+="inner join dmt_temp c on a.in_scode=c.in_scode and a.in_no=c.in_no ";
	    SQL+="where a.in_scode ='" +Request["in_scode"]+ "' and a.in_no = '" +Request["in_no"]+ "'";
        DataTable dt = new DataTable();
        conn.DataTable(SQL,dt);
        if (dt.Rows.Count > 0) {
            if (dt.Rows[0].SafeRead("seq", "") != "") {
                crmain["seq"] = dt.Rows[0].SafeRead("seq", "");
                crmain["seq1"] = dt.Rows[0].SafeRead("seq1", "");
                send_way = dt.Rows[0].SafeRead("send_way", "");//收文方式改由營洽登錄帶入值
                crmain["receipt_type"] = dt.Rows[0].SafeRead("receipt_type", "");
                crmain["receipt_title"] = dt.Rows[0].SafeRead("receipt_title", "B");//預設空白
            }
            //收文代碼
            crmain["codemark"] = dt.Rows[0].SafeRead("codemark", "");//收文代碼備註：B爭救案
            crmain["dmt_term1"] = dt.Rows[0].GetDateTimeString("dmt_term1", "yyyy/M/d");//專用期限起日check非創申案有期限者提醒需註記註冊費繳費狀態
            crmain["dmt_term2"] = dt.Rows[0].GetDateTimeString("dmt_term2", "yyyy/M/d");//專用期限迄日
            crmain["cust_date"] = dt.Rows[0].GetDateTimeString("cust_date", "yyyy/M/d");//客戶期限
            crmain["pr_date"] = dt.Rows[0].GetDateTimeString("pr_date", "yyyy/M/d");//承辦期限
            crmain["case_last_date"] = dt.Rows[0].GetDateTimeString("last_date", "yyyy/M/d");//營洽輸入法定期限

            SQL = " select rs_type,rs_class,rs_code,rs_detail,case_stat,case_stat_name,spe_ctrl ";
            SQL += "from vcode_act ";
            SQL += "where rs_code = '" + dt.Rows[0].SafeRead("arcase", "") + "' and act_code = '_' ";
            SQL += "and rs_type = '" + dt.Rows[0].SafeRead("arcase_type", "") + "'";
            SQL += "and cg = 'C' and rs = 'R'";
            using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
                if (dr.Read()) {
                    crmain["rs_type"] = dr.SafeRead("rs_type", "");
                    crmain["rs_class"] = dr.SafeRead("rs_class", "");
                    crmain["rs_code"] = dr.SafeRead("rs_code", "");
                    crmain["rs_detail"] = dr.SafeRead("rs_detail", "");
                    crmain["case_stat"] = dr.SafeRead("case_stat", "");
                    crmain["case_statnm"] = dr.SafeRead("case_stat_name", "");

                    if (dr.SafeRead("back_flag", "") == "Y") {
                        crmain["rs_detail"] = crmain["rs_detail"] + "(請復案)";
                    }
                    if (dr.SafeRead("end_flag", "") == "Y") {
                        crmain["rs_detail"] = crmain["rs_detail"] + "(請結案)";
                    }

                    string[] spe_ctrl = dr.SafeRead("spe_ctrl", "").Split(',');//抓取案性控制
                    if (spe_ctrl.Length >= 3) spe_ctrl3 = (spe_ctrl[2] == "" ? "N" : spe_ctrl[2]);//是否只為爭救案
                    if (spe_ctrl.Length >= 4 && send_way == "") send_way = spe_ctrl[3];//抓取案性控制之發文方式,(若營洽登錄沒值才帶入案性設定)
                }
            }
        }
        if (send_way == "") send_way = "M";//發文方式若無給M_親送
        crmain["spe_ctrl3"] = spe_ctrl3;
        crmain["send_way"] = send_way;
        
        //進度序號
        SQL = "select isnull(step_grade,0)+1 from dmt where seq = '" + crmain["seq"] + "' and seq1 = '" + crmain["seq1"] + "'";
        object objResult = conn.ExecuteScalar(SQL);
        int nstep_grade = (objResult == DBNull.Value || objResult == null) ? 1 : Convert.ToInt32(objResult);
        crmain["step_grade"] = nstep_grade.ToString();

        var settings = new JsonSerializerSettings()
        {
            Formatting = Formatting.None,
            ContractResolver = new LowercaseContractResolver(),//key統一轉小寫
            Converters = new List<JsonConverter> { new DBNullCreationConverter(), new TrimCreationConverter() }//dbnull轉空字串且trim掉
        };

        Response.Write(JsonConvert.SerializeObject(crmain, settings).ToUnicode() + "\n");
        Response.End();
    }

    /*
    private void QueryData() {
        Dictionary<string, string> crmain = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
        crmain["seq"] = ReqVal.TryGet("seq");
        crmain["seq1"] = ReqVal.TryGet("seq1");
        crmain["in_scode"] = ReqVal.TryGet("in_scode");
        crmain["in_no"] = ReqVal.TryGet("in_no");
        crmain["code"] = ReqVal.TryGet("code");
        crmain["cust_area"] = ReqVal.TryGet("cust_area");
        crmain["cust_seq"] = ReqVal.TryGet("cust_seq");
        crmain["endflag51"] = ReqVal.TryGet("endflag51");
        crmain["end_date51"] = ReqVal.TryGet("end_date51");
        crmain["end_code51"] = ReqVal.TryGet("end_code51");
        crmain["end_type51"] = ReqVal.TryGet("end_type51");
        crmain["end_remark51"] = ReqVal.TryGet("end_remark51");
        crmain["seqend_flag"] = ReqVal.TryGet("seqend_flag");

        DataTable stepDt = new DataTable();
        //只取得table結構.不抓資料for收文form
        SQL = "select *,''cgrs,'' case_stat,''case_statnm ";
        SQL += "from step_dmt where 1=0";
        conn.DataTable(SQL, stepDt);
        DataRow row = stepDt.NewRow();
        row["seq1"] = ReqVal.TryGet("seq1");
        row["step_date"] = DateTime.Today.ToShortDateString();
        row["cg"] = "C";
        row["rs"] = "R";
        row["cgrs"] = cgrs;
        row["send_cl"] = "1";
        row["act_code"] = "_";
        stepDt.Rows.Add(row);

        string spe_ctrl3 = "N";
        string send_way = "";

        SQL = "select a.*,b.mark as codemark,c.dmt_term1,c.dmt_term2 ";
        SQL += "from case_dmt a inner join code_br b on b.dept='T' and b.cr='Y' and b.rs_type=a.arcase_type and b.rs_code=a.arcase ";
        SQL += "inner join dmt_temp c on a.in_scode=c.in_scode and a.in_no=c.in_no ";
        SQL += "where a.in_scode ='" + Request["in_scode"] + "' and a.in_no = '" + Request["in_no"] + "'";
        DataTable dt = new DataTable();
        conn.DataTable(SQL, dt);
        if (dt.Rows.Count > 0) {
            if (dt.Rows[0].SafeRead("seq", "") != "") {
                crmain["seq"] = dt.Rows[0].SafeRead("seq", "");
                crmain["seq1"] = dt.Rows[0].SafeRead("seq1", "");
                send_way = dt.Rows[0].SafeRead("send_way", "");//收文方式改由營洽登錄帶入值
                stepDt.Rows[0]["receipt_type"] = dt.Rows[0].SafeRead("receipt_type", "");
                stepDt.Rows[0]["receipt_title"] = dt.Rows[0].SafeRead("receipt_title", "B");//預設空白
            }
            //收文代碼
            crmain["codemark"] = dt.Rows[0].SafeRead("codemark", "");//收文代碼備註：B爭救案
            crmain["dmt_term1"] = dt.Rows[0].GetDateTimeString("dmt_term1", "yyyy/M/d");//專用期限起日check非創申案有期限者提醒需註記註冊費繳費狀態
            crmain["dmt_term2"] = dt.Rows[0].GetDateTimeString("dmt_term2", "yyyy/M/d");//專用期限迄日
            crmain["cust_date"] = dt.Rows[0].GetDateTimeString("cust_date", "yyyy/M/d");//客戶期限
            crmain["pr_date"] = dt.Rows[0].GetDateTimeString("pr_date", "yyyy/M/d");//承辦期限
            crmain["case_last_date"] = dt.Rows[0].GetDateTimeString("last_date", "yyyy/M/d");//營洽輸入法定期限

            SQL = " select rs_type,rs_class,rs_code,rs_detail,case_stat,case_stat_name,spe_ctrl ";
            SQL += "from vcode_act ";
            SQL += "where rs_code = '" + dt.Rows[0].SafeRead("arcase", "") + "' and act_code = '_' ";
            SQL += "and rs_type = '" + dt.Rows[0].SafeRead("arcase_type", "") + "'";
            SQL += "and cg = 'C' and rs = 'R'";
            using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
                if (dr.Read()) {
                    stepDt.Rows[0]["rs_type"] = dr.SafeRead("rs_type", "");
                    stepDt.Rows[0]["rs_class"] = dr.SafeRead("rs_class", "");
                    stepDt.Rows[0]["rs_code"] = dr.SafeRead("rs_code", "");
                    stepDt.Rows[0]["rs_detail"] = dr.SafeRead("rs_detail", "");
                    stepDt.Rows[0]["case_stat"] = dr.SafeRead("case_stat", "");
                    stepDt.Rows[0]["case_statnm"] = dr.SafeRead("case_stat_name", "");

                    if (dr.SafeRead("back_flag", "") == "Y") {
                        stepDt.Rows[0]["rs_detail"] = row["rs_detail"] + "(請復案)";
                    }
                    if (dr.SafeRead("end_flag", "") == "Y") {
                        stepDt.Rows[0]["rs_detail"] = row["rs_detail"] + "(請結案)";
                    }

                    string[] spe_ctrl = dr.SafeRead("spe_ctrl", "").Split(',');//抓取案性控制
                    if (spe_ctrl.Length >= 3) spe_ctrl3 = (spe_ctrl[2] == "" ? "N" : spe_ctrl[2]);//是否只為爭救案
                    if (spe_ctrl.Length >= 4 && send_way == "") send_way = spe_ctrl[3];//抓取案性控制之發文方式,(若營洽登錄沒值才帶入案性設定)
                }
            }
        }
        if (send_way == "") send_way = "M";//發文方式若無給M_親送
        crmain["spe_ctrl3"] = spe_ctrl3;
        stepDt.Rows[0]["send_way"] = send_way;

        //進度序號
        SQL = "select isnull(step_grade,0)+1 from dmt where seq = '" + crmain["seq"] + "' and seq1 = '" + crmain["seq1"] + "'";
        object objResult = conn.ExecuteScalar(SQL);
        int nstep_grade = (objResult == DBNull.Value || objResult == null) ? 1 : Convert.ToInt32(objResult);
        stepDt.Rows[0]["step_grade"] = nstep_grade;

        var settings = new JsonSerializerSettings()
        {
            Formatting = Formatting.None,
            ContractResolver = new LowercaseContractResolver(),//key統一轉小寫
            Converters = new List<JsonConverter> { new DBNullCreationConverter(), new TrimCreationConverter() }//dbnull轉空字串且trim掉
        };

        Response.Write("{");
        Response.Write("\"cr_main\":" + JsonConvert.SerializeObject(crmain, settings).ToUnicode() + "\n");
        Response.Write(",\"step_dmt\":" + JsonConvert.SerializeObject(stepDt, settings).ToUnicode() + "\n");
        Response.Write("}");
        Response.End();
    }*/
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
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/jquery.datepick.min.js")%>"></script>
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
    <INPUT TYPE="text" id=submittask name=submittask value="<%=submitTask%>">
    <INPUT TYPE="text" id=prgid name=prgid value="<%=prgid%>">
    <input type="text" id=codemark name=codemark>
    <input type="text" id=dmt_term1 name=dmt_term1>
    <input type="text" id=dmt_term2 name=dmt_term2>
    <input type="text" id=endflag51 name=endflag51 value="<%=Request["endflag51"]%>">
    <input type="text" id=end_date51 name=end_date51 value="<%=Request["end_date51"]%>">
    <input type="text" id=end_code51 name=end_code51 value="<%=Request["end_code51"]%>">
    <input type="text" id=end_type51 name=end_type51 value="<%=Request["end_type51"]%>">
    <input type="text" id=end_remark51 name=end_remark51 value="<%=Request["end_remark51"]%>">
    <input type="text" id=seqend_flag name=seqend_flag value="<%=Request["seqend_flag"]%>"><!--結案註記-->
    <input type="text" id=case_last_date name=case_last_date><!--營洽輸入法定期限-->
    <input type="text" id=spe_ctrl3 name=spe_ctrl3><!--Y:案性需管制法定期限-->
    <input type="text" id=seq name=seq>
    <input type="text" id=seq1 name=seq1>
    <input type="text" id="cust_area" name="cust_area">
    <input type="text" id="cust_seq" name="cust_seq">
    <center>
         <uc1:dmt_CR_Form runat="server" ID="dmt_CR_Form" /><!--~/commonForm/dmt_CR_Form.ascx-->
         <uc1:dmt_ctrl_Form runat="server" ID="dmt_ctrl_Form" /><!--~/commonForm/dmt_ctrl_Form.ascx-->
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

    //關閉視窗
    $(".imgCls").click(function (e) {
        if (window.parent.tt !== undefined) {
            window.parent.tt.rows = "100%,0%";
        } else {
            window.close();
        }
    })

    function this_init() {
        //取得交辦資料
        $.ajax({
            type: "get",
            url: getRootPath() + "/ajax/_case_dmt.aspx?<%=Request.QueryString%>",
            async: false,
            cache: false,
            success: function (json) {
                //if ($("#chkTest").prop("checked")) toastr.info("<a href='" + this.url + "' target='_new'>Debug(_case_dmt)！<BR><b><u>(點此顯示詳細訊息)</u></b></a>");
                toastr.info("<a href='" + this.url + "' target='_new'>Debug(_case_dmt)！<BR><b><u>(點此顯示詳細訊息)</u></b></a>");
                jMain = $.parseJSON(json);
            },
            error: function (xhr) {
                $("#dialog").html("<a href='" + this.url + "' target='_new'>案件資料載入失敗！<u>(點此顯示詳細訊息)</u></a><hr>" + xhr.responseText);
                $("#dialog").dialog({ title: '案件資料載入失敗！', modal: true, maxHeight: 500, width: "90%" });
            }
        });

        //畫面準備
        cr_form.init();//收文form
        ctrl_form.init();//管制期限form

        //-----------------
        $("input.dateField").datepick();
        main.bind();//資料綁定
        $(".Lock").lock();
        $(".Hide").hide();
    }
    
    main.bind = function () {
        $("#codemark").val(jMain.case_main[0].codemark);
        $("#dmt_term1").val(jMain.case_main[0].dmt_term1);
        $("#dmt_term2").val(jMain.case_main[0].dmt_term2);
        $("#case_last_date").val(jMain.case_main[0].last_date);
        $("#seq").val(jMain.case_main[0].seq);
        $("#seq1").val(jMain.case_main[0].seq1);
        $("#spe_ctrl3").val(jMain.step_cr.spe_ctrl3);
        //cr_form
        $("#rs_type").val(jMain.step_cr.rs_type);//結構分類
        $("#rs_type").triggerHandler("change");
        $("#code").val(main.code);
        $("#in_no").val(jMain.case_main[0].in_no);
        $("#in_scode").val(jMain.case_main[0].in_scode);
        $("#change").val(main.change);
        $("#cust_area1").val(main.cust_area);
        $("#cust_seq1").val(main.cust_seq);
        $("#rs_no").val(jMain.step_cr.rs_no);
        $("#nstep_grade").val(jMain.step_cr.step_grade);
        $("#cgrs").val(jMain.step_cr.cgrs);
        $("#step_date").val(jMain.step_cr.step_date);
        $("#receive_no").val(jMain.step_cr.receive_no);
        $("#hrs_class,#rs_class").val(jMain.step_cr.rs_class);
        $("#rs_class").triggerHandler("change");
        $("#hrs_code,#rs_code").val(jMain.step_cr.rs_code);
        $("#rs_code").triggerHandler("change");
        $("#hact_code,#act_code").val(jMain.step_cr.act_code);
        $("#act_code").triggerHandler("change");
        $("#ocase_stat,#ncase_stat").val(jMain.step_cr.case_stat);
        $("#ncase_statnm").val(jMain.step_cr.case_statnm);
        $("#rs_detail").val(jMain.step_cr.rs_detail);
        $("#doc_detail").val(jMain.step_cr.doc_detail);
        $("#old_receipt_type,#receipt_type").val(jMain.case_main[0].receipt_type);
        $("#old_receipt_title,#receipt_title").val(jMain.case_main[0].receipt_title);
        $("#old_send_way,#send_way").val(jMain.case_main[0].send_way);
        $("#send_sel").val(jMain.step_cr.send_sel);
        if (main.submittask == "A") {
            $("input[name='opt_stat'][value='N']").prop("checked", true);//需交辦
            $("input[name='end_stat'][value='B61']").prop("checked", true);//送會計確認
        }
        $("input[name='opt_stat'][value='" + jMain.step_cr.opt_stat + "']").prop("checked", true);
        
        //顯示爭救案交辦欄位
        if ($("#codemark").val()=="B"){
            document.all.show_optstat.style.display=""
            //2013/11/5修改，爭救案性預設帶官收法定期限
            if(CInt($("#nstep_grade"))!=1){
                $("#btnqrygrlastdate").show();//顯示[查官收未銷法定期限按鈕]
                ctrl_form.Add_button.click();
                $("#ctrl_type_"+$("#ctrlnum").val()).val("A1");
                getgrlast_date();
            }
        }
        //顯示註冊費繳費狀態，當非創申案立新案
        if(main.submittask=="A"){
            if(CInt($("#nstep_grade").val())==1){
                if ($("#hrs_class").val()!="A1"){
                    $("#show_paytimes").show();
                }
            }else{
                if($("#seqend_flag").val()=="Y"){//2010/10/6修改為結案註記有勾選結案才顯示
                    $("#show_endstat").show();
                }else{
                    $("input[name='end_stat']").prop("checked",false);
                }
            }
        }

        if(main.submittask=="A"){
            if($("#hrs_code").val()=="FC11"||$("#hrs_code").val()=="FC21"||$("#hrs_code").val()=="FC6"||$("#hrs_code").val()=="FC7"||$("#hrs_code").val()=="FC8"||$("#hrs_code").val()=="FC5"
                ||$("#hrs_code").val()=="FCI"||$("#hrs_code").val()=="FCH"||$("#hrs_code").val()=="FT2"||$("#hrs_code").val()=="FL5"||$("#hrs_code").val()=="FL6"){
                cr_form.getdseq();//一案多件
            }
            if($("#hrs_code").val().Left(2)=="FD"){
                cr_form.getdseq1();//分割
            }
            cr_form.getCtrl();
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
                                if(CDate($("#case_last_date").val())!=CDate(ctrl_date)){
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
                        }
                        window.parent.Etop.location.href= getRootPath() +'/brt5m/brt51_list.aspx?prgid=brt51';
                    }
                }
            });
        });
    }
</script>

