<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Data"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>
<%@ Register Src="~/commonForm/brt511form.ascx" TagPrefix="uc1" TagName="brt511form" %>
<%@ Register Src="~/commonForm/Brta212form.ascx" TagPrefix="uc1" TagName="brta212form" %>


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
    main.code = "<%#ReqVal.TryGet("code")%>";
    main.in_no = "<%#ReqVal.TryGet("in_no")%>";
    main.in_scode = "<%#ReqVal.TryGet("in_scode")%>";
    main.cust_area = "<%#ReqVal.TryGet("cust_area")%>";
    main.cust_seq = "<%#ReqVal.TryGet("cust_seq")%>";
    main.endflag51 = "<%#ReqVal.TryGet("endflag51")%>";
    main.end_date51 = "<%#ReqVal.TryGet("end_date51")%>";
    main.end_code51 = "<%#ReqVal.TryGet("end_code51")%>";
    main.end_type51 = "<%#ReqVal.TryGet("end_type51")%>";
    main.end_remark51 = "<%#ReqVal.TryGet("end_remark51")%>";
    main.seqend_flag = "<%#ReqVal.TryGet("seqend_flag")%>";
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
    <input type="text" id=endflag51 name=endflag51>
    <input type="text" id=end_date51 name=end_date51>
    <input type="text" id=end_code51 name=end_code51>
    <input type="text" id=end_type51 name=end_type51>
    <input type="text" id=end_remark51 name=end_remark51>
    <input type="text" id=seqend_flag name=seqend_flag><!--結案註記-->
    <input type="text" id=case_last_date name=case_last_date><!--營洽輸入法定期限-->
    <input type="text" id=spe_ctrl3 name=spe_ctrl3><!--Y:案性需管制法定期限-->
    <input type="text" id=seq name=seq>
    <input type="text" id=seq1 name=seq1>
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
        $.ajax({
            url: "brt51_Edit.aspx?json=Y&<%=Request.QueryString%>",
            type: "get",
            async: false,
            cache: false,
            success: function (json) {
                //if ($("#chkTest").prop("checked")) 
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

        //-----------------
        $("input.dateField").datepick();
        main.bind();//資料綁定
        brt511form.bind();//資料綁定
        $(".Lock").lock();
        $(".Hide").hide();

        //顯示爭救案交辦欄位
        if ($("#codemark").val()=="B"){
            document.all.show_optstat.style.display=""
            //2013/11/5修改，爭救案性預設帶官收法定期限
            if(CInt($("#nstep_grade"))!=1){
                $("#btnqrygrlastdate").show();//顯示[查官收未銷法定期限按鈕]
                brta212form.Add_button.click();
                $("#ctrl_type_"+$("#ctrlnum").val()).val("A1");
            }
        }
        //顯示註冊費繳費狀態，當非創申案立新案
        if(main.submittask=="A"){
            if(CInt($("#nstep_grade"))==1){
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
    }
    
    main.bind = function () {
        $("#codemark").val(jMain.codemark);
        $("#dmt_term1").val(jMain.dmt_term1);
        $("#dmt_term2").val(jMain.dmt_term2);
        $("#endflag51").val(jMain.endflag51);
        $("#end_date51").val(jMain.end_date51);
        $("#end_code51").val(jMain.end_code51);
        $("#end_type51").val(jMain.end_type51);
        $("#end_remark51").val(jMain.end_remark51);
        $("#seqend_flag").val(jMain.seqend_flag);
        $("#case_last_date").val(jMain.last_date);
        $("#spe_ctrl3").val(jMain.spe_ctrl3);
        $("#seq").val(jMain.seq);
        $("#seq1").val(jMain.seq1);
        //brt511form
        $("#rs_type").val(jMain.rs_type);//結構分類
        $("#rs_type").triggerHandler("change");
        $("#code").val(jMain.code);
        $("#in_no").val(jMain.in_no);
        $("#in_scode").val(jMain.in_scode);
        $("#change").val(jMain.change);
        $("#cust_area1").val(jMain.cust_area);
        $("#cust_seq1").val(jMain.cust_seq);
        $("#rs_no").val(jMain.rs_no);
        $("#nstep_grade").val(jMain.step_grade);
        $("#cgrs").val(jMain.cgrs);
        $("#step_date").val(jMain.step_date);
        $("#receive_no").val(jMain.receive_no);
        $("#hrs_class,#rs_class").val(jMain.rs_class);
        $("#rs_class").triggerHandler("change");
        $("#hrs_code,#rs_code").val(jMain.rs_code);
        $("#rs_code").triggerHandler("change");
        $("#hact_code,#act_code").val(jMain.act_code);
        $("#act_code").triggerHandler("change");
        $("#ocase_stat,#ncase_stat").val(jMain.case_stat);
        $("#ncase_statnm").val(jMain.case_statnm);
        $("#rs_detail").val(jMain.rs_detail);
        $("#doc_detail").val(jMain.doc_detail);
        $("#old_receipt_type,#receipt_type").val(jMain.receipt_type);
        $("#old_receipt_title,#receipt_title").val(jMain.receipt_title);
        $("#old_send_way,#send_way").val(jMain.send_way);
        $("#send_sel").val(jMain.send_sel);
        if (main.submittask == "A") {
            $("input[name='opt_stat'][value='N']").prop("checked", true);//需交辦
            $("input[name='end_stat'][value='B61']").prop("checked", true);//送會計確認
        }
        $("input[name='opt_stat'][value='" + jMain.opt_stat + "']").prop("checked", true);
    }
    /*
    main.bind = function () {
        $("#codemark").val(jMain.cr_main.codemark);
        $("#dmt_term1").val(jMain.cr_main.dmt_term1);
        $("#dmt_term2").val(jMain.cr_main.dmt_term2);
        $("#endflag51").val(jMain.cr_main.endflag51);
        $("#end_date51").val(jMain.cr_main.end_date51);
        $("#end_code51").val(jMain.cr_main.end_code51);
        $("#end_type51").val(jMain.cr_main.end_type51);
        $("#end_remark51").val(jMain.cr_main.end_remark51);
        $("#seqend_flag").val(jMain.cr_main.seqend_flag);
        $("#case_last_date").val(jMain.cr_main.last_date);
        $("#spe_ctrl3").val(jMain.cr_main.spe_ctrl3);
        $("#seq").val(jMain.cr_main.seq);
        $("#seq1").val(jMain.cr_main.seq1);
        //brt511form
        $("#rs_type").val(jMain.step_dmt[0].rs_type);//結構分類
        $("#rs_type").triggerHandler("change");
        $("#code").val(jMain.cr_main.code);
        $("#in_no").val(jMain.cr_main.in_no);
        $("#in_scode").val(jMain.cr_main.in_scode);
        $("#change").val(jMain.cr_main.change);
        $("#cust_area1").val(jMain.cr_main.cust_area);
        $("#cust_seq1").val(jMain.cr_main.cust_seq);
        $("#rs_no").val(jMain.step_dmt[0].rs_no);
        $("#nstep_grade").val(jMain.step_dmt[0].step_grade);
        $("#cgrs").val(jMain.step_dmt[0].cgrs);
        $("#step_date").val(dateReviver(jMain.step_dmt[0].step_date,'yyyy/M/d'));
        $("#receive_no").val(jMain.step_dmt[0].receive_no);
        $("#hrs_class,#rs_class").val(jMain.step_dmt[0].rs_class);
        $("#rs_class").triggerHandler("change");
        $("#hrs_code,#rs_code").val(jMain.step_dmt[0].rs_code);
        $("#rs_code").triggerHandler("change");
        $("#hact_code,#act_code").val(jMain.step_dmt[0].act_code);
        $("#act_code").triggerHandler("change");
        $("#ocase_stat,#ncase_stat").val(jMain.step_dmt[0].case_stat);
        $("#ncase_statnm").val(jMain.step_dmt[0].case_statnm);
        $("#rs_detail").val(jMain.step_dmt[0].rs_detail);
        $("#doc_detail").val(jMain.step_dmt[0].doc_detail);
        $("#old_receipt_type,#receipt_type").val(jMain.step_dmt[0].receipt_type);
        $("#old_receipt_title,#receipt_title").val(jMain.step_dmt[0].receipt_title);
        $("#old_send_way,#send_way").val(jMain.step_dmt[0].send_way);
        $("#send_sel").val(jMain.step_dmt[0].send_sel);
        if (main.submittask == "A") {
            $("input[name='opt_stat'][value='N']").prop("checked", true);//需交辦
            $("input[name='end_stat'][value='B61']").prop("checked", true);//送會計確認
        }
        $("input[name='opt_stat'][value='" + jMain.step_dmt[0].opt_stat + "']").prop("checked", true);
    }*/

    //存檔
    function formModSubmit(){
        $.maskStart();
        var saveflag=main.savechk();
        $.maskStop();

        if(!saveflag) return false;

        $("#tfy_case_stat").val("NN");//新案
        $("#submittask").val("Edit");

        //$("select,textarea,input,span").unlock();
        $("input:disabled, select:disabled").unlock();
        $(".bsubmit").lock(!$("#chkTest").prop("checked"));

        var formData = new FormData($('#reg')[0]);
        ajaxByForm("<%=HTProgPrefix%>EditA9Z_Update.aspx",formData)
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
                            if (main.prgid == "brt51")
                                window.parent.tt.rows="0%,100%";
                            else
                                window.parent.tt.rows="100%,0%";
                        }

                        if (main.prgid == "brt51"){
                            window.parent.Eblank.location.href=getRootPath() +"/brt5m/Brt51_Edit.aspx?prgid=brt51&submittask=A&in_scode="+main.in_scode;
                        }
                    }
                }
            });
        });

        //reg.action = "<%=HTProgPrefix%>EditA11_Update.aspx";
        //if($("#chkTest").prop("checked"))
        //    reg.target = "ActFrame";
        //else
        //    reg.target = "_self";
        //reg.submit();
    }

    //退回營洽
    function formModSubmit2(){
        if ($("#back_remark").val()==""){
            alert("請輸入退回說明！");
            return false;
        }
        if(confirm("是否確定退回營洽!!!")){
            $("input:disabled, select:disabled").unlock();
            $(".bsubmit").lock(!$("#chkTest").prop("checked"));

            var formData = new FormData($('#reg')[0]);
            ajaxByForm(getRootPath() +"/brt5m/Brt51_Update3.aspx",formData)
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
    }

    function Help_Click(){
        window.open(getRootPath() + "/brtam/國內案發收文系統操作手冊.htm","","width=700, height=500, top=50, left=50, toolbar=no, menubar=no, location=no, directories=no, resizeable=no, status=no, scrollbars=yes");
    }
</script>

<script type="text/javascript" src="<%=Page.ResolveUrl("~/brt1m/brtform/CaseForm/Descript.js")%>"></script><!--欄位說明-->
