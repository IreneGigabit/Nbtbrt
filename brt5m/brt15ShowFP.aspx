<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Collections.Generic"%>

<script runat="server">
    protected string HTProgCap = HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "Brt15ShowFP";//程式檔名前綴
    protected string HTProgCode =  "brt15";//HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼//brt51客收確認,brta24官收確認,brta78轉案確認
    protected int HTProgRight = 0;
    protected string DebugStr = "";
    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";
    protected string QueryString = "";

    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected Dictionary<string, string> Lock = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    protected string submitTask = "";
    protected string seq = "";
    protected string seq1 = "";
    protected string from_fld = "";
    protected string type = "";
    protected string branch = "";
    protected string dept = "";
    protected string brtran_sqlno = "";//轉案流水號
    protected string old_brtran_sqlno = "";//原始單位轉案流水號
    protected string todo_sqlno = "";//轉案todo流水號
    protected string emg_scodelist = "";//Email通知總管處人員正本
    protected string emg_scodelist1 = "";//Email通知總管處人員副本
    protected string tran_seq_date = "";//原單位通知轉案日期

    protected string html_agt_no="",html_scode="",html_country = "", html_tran_seq_branch = "";
    protected string html_pay_times = "", html_end_code = "", html_end_type = "";
    protected string html_apclass = "";

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        QueryString = Request.ServerVariables["QUERY_STRING"];
        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");
        submitTask = (Request["submittask"] ?? "").Trim();
        seq = (Request["seq"] ?? "").Trim();
        seq1 = (Request["seq1"] ?? "").Trim();
        from_fld = (Request["from_fld"] ?? "").Trim();
        type = (Request["type"] ?? "").Trim();
        branch = Sys.GetSession("sebranch");
        if (type == "brtran") {
            branch = (Request["branch"] ?? "").Trim();
        }
        dept = Sys.GetSession("dept").ToUpper();
        brtran_sqlno = (Request["brtran_sqlno"] ?? "").Trim();
        old_brtran_sqlno = (Request["old_brtran_sqlno"] ?? "").Trim();
        todo_sqlno = (Request["todo_sqlno"] ?? "").Trim();
        tran_seq_date = (Request["tran_seq_date"] ?? "").Trim();

        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        HTProgCap = myToken.Title;
        DebugStr = myToken.DebugStr;
        if (HTProgRight >= 0) {
            PageLayout();
            this.DataBind();
        }
    }

    private void PageLayout() {
        if (submitTask == "A") {
            HTProgCap += "-<font color=blue>新增</font>";
        } else if (submitTask == "U") {
            HTProgCap += "-<font color=blue>修改</font>";
        } else if (submitTask == "Q") {
            if (prgid == "brt51") {
                HTProgCap += "-<font color=blue>確認與結案</font>";
            } else {
                HTProgCap += "-<font color=blue>查詢</font>";
            }
        }
        
        StrFormBtnTop += "<a class=\"imgCls\" href=\"javascript:void(0);\" >[關閉視窗]</a>\n";
        
        if ((HTProgRight & 4) > 0 && submitTask=="A" && prgid.IN("brta24,brta78")) {
            StrFormBtn += "<input type=button value='新　增' class='cbutton bsubmit' onclick=\"formSearchSubmit('Add')\">\n";
        }
        if ((HTProgRight & 8) > 0 && submitTask == "U") {
            StrFormBtn += "<input type=button value='修　改' class='cbutton bsubmit' onclick=\"formSearchSubmit('Update')\">\n";
            StrFormBtn += "<input type=button value='重　填' class='cbutton' onclick='this_init()'>\n";
        }
        if ((HTProgRight & 8) > 0 && submitTask == "Q" && prgid.IN("brt51")) {
            StrFormBtn += "<input type=button value='確認送結案處理' class='cbutton bsubmit' onclick=\"formSearchSubmit1('Update')\">\n";
            StrFormBtn += "<input type=button value='案號有誤退回' class='redbutton bsubmit' onclick=\"formSearchSubmit1('close')\">\n";
        }
        
        Lock["Qclass"] = "";
        Lock["Qclass51"] = "Lock";//prgid=brt51客收確認
        Lock["QclassRC"] = "Lock";//特定權限C才能修改
    
        //特定權限C才能修改結案資料
        if ((HTProgRight & 256) > 0 && submitTask=="U") {
            Lock["Qclass"] = "";
            Lock["Qclass51"] = "";
            Lock["QclassRC"] = "";
        }

        if (submitTask == "Q") {
            Lock["Qclass"] = "Lock";
            if (prgid == "brt51") {
                Lock["Qclass51"] = "";//prgid=brt51客收確認
            }
        }

        if (prgid == "brta78") {
            emg_scodelist = Sys.getRoleScode(Sys.GetSession("seBranch"), Sys.GetSession("syscode"), "T", "mg_prorm1");//總管處程序組主管
            emg_scodelist1 = Sys.getRoleScode(Sys.GetSession("seBranch"), Sys.GetSession("syscode"), "T", "mg_pror");//總管處程序組主管
        }

        //代理人
        html_agt_no = Sys.getAgent().Option("{agt_no}", "{agt_no}_{agt_namefull}", "v1='{end_flag}'", true);
        //營洽
        html_scode = Sys.getDmtScode(branch, "").Option("{scode}", "{star}{scode}_{sc_name}", "style='color:{color}'", true);
        //註冊費繳納
        html_pay_times = Sys.getCustCode(Sys.GetSession("dept") + "PAY_TIMES", "", "sortfld").Option("{cust_code}", "{code_name}");
        //結案代碼
        html_end_code = Sys.getEndCode().Option("{chrelno}", "{chrelname}", "v1='{end_codenm}'", true);
        //結案原因
        html_end_type = Sys.getEndType().Option("{cust_code}", "{code_name}");
        //國別
        html_country = Sys.getCountry().Option("{coun_code}", "{coun_code}-{coun_c}");
        //轉案單位
        html_tran_seq_branch = Sys.getBranchCode().Option("{branch}", "{branchname}");
        //申請人種類
        html_apclass = Sys.getCustCode("apclass", "", "sortfld").Option("{cust_code}", "{code_name}");
    }
</script>
<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta http-equiv="x-ua-compatible" content="IE=10">
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
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/util_NumberConvert.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/jquery.Snoopy.date.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/jquery.irene.form.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/client_chk.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/client_chk_custwatch.js")%>"></script><!--檢查是否為雙邊代理查照對象-->
</head>
<script language="javascript" type="text/javascript">
    var main = {};
    main.prgid = "<%#prgid%>";
    main.right = <%#HTProgRight%>;
    main.submittask = "<%#submitTask%>";
    main.seq = "<%#seq%>";
    main.seq1 = "<%#seq1%>";
    main.type="<%#type%>";
    main.branch="<%#branch%>";
    main.from_fld="<%#from_fld%>";
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
	<input type="text" id="submittask" name="submittask" value="<%=submitTask%>">
	<input type="text" id="prgid" name="prgid" value="<%=prgid%>">
    <input type="text" id="brtran_sqlno" name="brtran_sqlno" value="<%=brtran_sqlno%>"><!--轉案流水號-->
    <input type="text" id="old_brtran_sqlno" name="old_brtran_sqlno" value="<%=old_brtran_sqlno%>"><!--原始單位轉案流水號-->
    <input type="text" id="todo_sqlno" name="todo_sqlno" value="<%=todo_sqlno%>"><!--轉案todo流水號-->
    <input type="text" id="emg_scodelist" name="emg_scodelist" value="<%=emg_scodelist%>"><!--Email通知總管處人員正本-->
    <input type="text" id="emg_scodelist1" name="emg_scodelist1" value="<%=emg_scodelist1%>"><!--Email通知總管處人員副本-->
    <input type="text" id="emg_flag" name="emg_flag" value="N"><!--是否通知總管處,是Y否N-->
    <input type="text" id="tran_seq_date" name="tran_seq_date" value="<%=tran_seq_date%>"><!--原單位通知轉案日期-->

    <table cellspacing="1" cellpadding="0" width="98%" border="0">
    <tr>
        <td>
        <table border="0" cellspacing="0" cellpadding="0">
            <tr id="CTab">
                <td class="tab" href="#dmt">案件基本內容</td>
                <td class="tab" href="#ndmt">案件明細內容</td>
                <td class="tab" href="#apcust">案件申請人</td>
            </tr>
        </table>
        </td>
    </tr>
    <tr>
        <td>
            <div class="tabCont" id="#dmt">
                <input type="text" id="tfx_apcust_no" name="tfx_apcust_no">
		        <input type="text" id="tfx_apsqlno" name="tfx_apsqlno">
		        <input type="text" id="tfx_ap_cname" name="tfx_ap_cname">
		        <input type="text" id="tfx_ap_ename" name="tfx_ap_ename">	
	            <table border="0" class="bluetable" cellspacing="1" cellpadding="2" style="font-size: 9pt" width="100%">
		            <tr>
			            <td class="lightbluetable" width="15%" align="right">本所編號：</td>
			            <td class="whitetablebg" >
				            <input type="text" id="sendprgid" name="sendprgid" value="<%#prgid%>">
				            <input type="text" id="keyseq1" name="keyseq1" value="N">
                            <span id="spanbranch"><%#branch%><%#dept%></span>-
				            <input type="text" id="tfx_seq" name="tfx_seq" size="<%#Sys.DmtSeq%>" readonly class="SEdit">-
				            <input type="text" value="" id="tfx_seq1" name="tfx_seq1" size="<%#Sys.DmtSeq1%>" readonly class="SEdit" >
				            <input type=button class="c1button" id="btnseq1" name="btnseq1" value="確定">
				            <input type=button class="c1button" id="btngetseq" name="btngetseq" onclick="get_maxseq()" value="抓取案號">
			            </td>
			            <td class="lightbluetable" width="15%" align="right">立案案性：</td>
			            <td class="whitetablebg"   >
					        <input type="text" id="arcase_type" name="arcase_type" >
					        <input type="text" id="arcase_class" name="arcase_class" >
					        <input type="text" id="tfx_arcase" name="tfx_arcase" size="10">
					        <input type="text" id="tfx_arcasenm" name="tfx_arcasenm" size="20" readonly class="SEdit">
			            </td>
			            <td class="lightbluetable" width="15%" align="right">立案日期：</td>
			            <td class="whitetablebg" ><input type="text" id="tfx_in_date" name="tfx_in_date" size="10" readonly class="SEdit"></td>
		            </tr>
		            <tr>		
			            <td class="lightbluetable" align="right">正商標號：</td>
			            <td class="whitetablebg"><input type="text" id="tfx_tcn_ref" name="tfx_tcn_ref" size="7" <%=Lock["QClass"]%>></td>
			            <td class="lightbluetable" align="right">相關案號：</td>
			            <td class="whitetablebg" >
				            <input type="text" id="tfx_ref_no1" name="tfx_ref_no1" size="7" class="<%=Lock["QClass"]%>">
				            <input type="text" id="tfx_ref_no2" name="tfx_ref_no2" size="7" class="<%=Lock["QClass"]%>">
				            <input type="text" id="tfx_ref_no3" name="tfx_ref_no3" size="7" class="<%=Lock["QClass"]%>">
			            </td>
			            <td class="lightbluetable" align="right">母案編號：</td>
			            <td class="whitetablebg" >
				            <input type="text" id="tfx_Mseq" name="tfx_Mseq" size="5" class="<%=Lock["QClass"]%>">-
				            <input type="text" id="tfx_Mseq1" name="tfx_Mseq1" size="1" class="<%=Lock["QClass"]%>">
			            </td>
		            </tr>
		            <tr>		
			            <td class="lightbluetable"  align="right" rowspan=2>商標種類：</td>
			            <td class="whitetablebg" colspan=5>
				            <input type="text" id="tfx_s_mark" name="tfx_s_mark">
				            <input type="radio" name="s_mark" value="">商標
				            <input type="radio" name="s_mark"  value="S">92年修正前服務標章
				            <input type="radio" name="s_mark"  value="L">證明標章
				            <input type="radio" name="s_mark"  value="M">團體標章
				            <input type="radio" name="s_mark"  value="N">團體商標
			            </td>
		            </tr>
		            <tr >
			            <td class="whitetablebg" colspan=5>
				            <input type="text" id="tfx_s_mark2" name="tfx_s_mark2">
			               <input type="radio" name="s_mark2" value="A">平面
			               <input type="radio" name="s_mark2" value="B">立體
			               <input type="radio" name="s_mark2" value="C">聲音
			               <input type="radio" name="s_mark2" value="D">顏色
			               <input type="radio" name="s_mark2" value="E">全像圖
			               <input type="radio" name="s_mark2" value="F">動態
			               <input type="radio" name="s_mark2" value="H">位置
			               <input type="radio" name="s_mark2" value="I">氣味
			               <input type="radio" name="s_mark2" value="J">觸覺
			            </TD>
		            </tr>
		            <tr>
			            <td class="lightbluetable" align="right">商標名稱：</td>
			            <td class="whitetablebg" colspan=3>
				            <input type="text" id="tfx_appl_name" name="tfx_appl_name" size="60" MAXLENGTH="100" alt="商標名稱" class="<%=Lock["QClass"]%>" onblur="fDataLen(this)">
			            </td>
			            <td class="lightbluetable" align="right">圖示：</td>
			            <td class="whitetablebg"><input type="text" id="tfx_dmt_draw" name="tfx_dmt_draw" size="1" class="<%=Lock["QClass"]%>"></td>
		            </tr>
		            <tr>
			            <td class="lightbluetable" align="right">類別種類：</td>
			            <td class="whitetablebg" colspan=3>
				            <input type="text" id="tfx_class_type" name="tfx_class_type">
				            <input type="radio" name="class_type" value="int">國際分類
				            <input type="radio" name="class_type" value="old">舊類
			            </td>
			            <td class="lightbluetable" align="right">客戶卷號：</td>
			            <td class="whitetablebg" >
				            <input type="text" id="tfx_cust_prod" name="tfx_cust_prod" size="15" class="<%=Lock["QClass"]%>">
			            </td>
		            </tr>
		            <tr>
			            <td class="lightbluetable" align="right">類別：</td>
			            <td class="whitetablebg"   colspan=3>
				            <input type="text" id="tfx_class" name="tfx_class" size="60" readonly class="SEdit">
			            </td>
			            <td class="lightbluetable" align="right">類別數：</td>
			            <td class="whitetablebg">
				            共&nbsp;<input type="text" id="tfx_class_count" name="tfx_class_count" size="3" readonly class="SEdit">&nbsp;類
			            </td>
  	                </tr>
		            <tr>		
			            <td class="lightbluetable"  align="right">客戶：</td>
			            <td class="whitetablebg" colspan=3>
				            <input type="text" id="tfx_cust_area" name="tfx_cust_area" size="1" readonly class="SEdit">
				            <input type="text" id="tfx_cust_seq" name="tfx_cust_seq" size="5" class="<%=Lock["QclassRC"]%>">&nbsp;
				            <input type="text" id="tfx_cust_name" name="tfx_cust_name" size="25" readonly class="SEdit">
				            <input type="text" id="ocust_seq" name="ocust_seq">
			            </td>
			            <td class="lightbluetable" align="right">顧問：</td>
			            <td class="whitetablebg"><input type="text" id="tfx_con_term" name="tfx_con_term" size="1" readonly class="SEdit"></td>
		            </tr>
  		            <tr>		
			            <td class="lightbluetable" align="right">聯絡序號：</td>
			            <td class="whitetablebg"><input type="text" id="tfx_att_sql" name="tfx_att_sql" size="3" class="<%=Lock["QClass"]%>" onblur="getAtt()"></td>
			            <td class="lightbluetable" align="right">聯絡部門：</td>
			            <td class="whitetablebg"><input type="text" id="tfx_att_dept" name="tfx_att_dept" size="10" readonly class="SEdit"></td>
			            <td class="lightbluetable" align="right">聯 絡 人：</td>
			            <td class="whitetablebg"><input type="text" id="tfx_attention" name="tfx_attention" size="10" readonly class="SEdit"></td>
		            </tr>
		            <tr>		
			            <td class="lightbluetable"  align="right">代理人：</td>
			            <td class="whitetablebg"  colspan=3 >
				            <select id="tfx_agt_no" name="tfx_agt_no" class="<%=Lock["QClass"]%>">
				            <%#html_agt_no%>
				            </select>
			            </td>
			            <td class="lightbluetable" align="right">營洽：</td>
			            <td class="whitetablebg" >
				            <select id="tfx_Scode" name="tfx_Scode" class="<%=Lock["QClass"]%>">
					            <option value="" style="color:blue">全部</option> 
					            <option value="<%#Sys.GetSession("sebranch").ToLower()%><%#Sys.GetSession("dept").ToLower()%>">部門(開放客戶)</option>
					            <%#html_scode%>
				            </select>
			            </td>
		            </tr>
		            <tr>		
			            <td class="lightbluetable"  align="right">申請日期：</td>
			            <td class="whitetablebg" colspan=3><input type="text" id="tfx_apply_date" name="tfx_apply_date" size="10" class="dateField <%=Lock["QClass"]%>"></td>
			            <td class="lightbluetable"  align="right">申 請 號：</td>
			            <td class="whitetablebg"><input type="text" id="tfx_apply_no" name="tfx_apply_no" size="20" onblur="chk_dmt_applyno(this,9)" class="<%=Lock["QClass"]%>"></td>
		            </tr>
		            <tr>
			            <td class="lightbluetable"  align="right">註冊日期：</td>
			            <td class="whitetablebg" colspan=3><input type="text" id="tfx_issue_date" name="tfx_issue_date" size="10" class="dateField <%=Lock["QClass"]%>"></td>
			            <td class="lightbluetable"  align="right">註 冊 號：</td>
			            <td class="whitetablebg"><input type="text" id="tfx_issue_no" name="tfx_issue_no" size="20" onblur="chk_dmt_issueno(this,8)" class="<%=Lock["QClass"]%>"></td>
		            </tr>
		            <tr>
			            <td class="lightbluetable"  align="right">公告日期：</td>
			            <td class="whitetablebg"><input type="text" id="tfx_open_date" name="tfx_open_date" size="10" class="dateField <%=Lock["QClass"]%>"></td>
			            <td class="lightbluetable"  align="right">核 駁 號：</td>
			            <td class="whitetablebg"><input type="text" id="tfx_rej_no" name="tfx_rej_no" size="20" onblur="chk_dmt_rejno(this,7)" class="<%=Lock["QClass"]%>"></td>
			            <td class="lightbluetable" align="right">爭議條款：</td>
			            <td class="whitetablebg" ><input type="text" id="tfx_rej_item" name="tfx_rej_item" size="5" class="<%=Lock["QClass"]%>"></td>
		            </tr>
		            <tr>
			            <td class="lightbluetable"  align="right">優先權日期：</td>
			            <td class="whitetablebg"><input type="text" id="tfx_prior_date" name="tfx_prior_date" size="10" class="dateField <%=Lock["QClass"]%>"></td>
			            <td class="lightbluetable"  align="right">優先權申請案號：</td>
			            <td class="whitetablebg"><input type="text" id="tfx_prior_no" name="tfx_prior_no" size="20" class="<%=Lock["QClass"]%>"></td>
			            <td class="lightbluetable" align="right">優先權申請國家：</td>
			            <td class="whitetablebg" >
	   			            <Select NAME=tfx_prior_country id=tfx_prior_country class="<%=Lock["QClass"]%>"><%#html_country%></SELECT>
			            </td>
		            </tr>
		            <tr>
			            <td class="lightbluetable"  align="right">專用期限：</td>
			            <td class="whitetablebg"  colspan=3 >
				            <input type="text" id="tfx_term1" name="tfx_term1" size="10" class="dateField <%=Lock["QClass"]%>">&nbsp;~&nbsp;
				            <input type="text" id="tfx_term2" name="tfx_term2" size="10" class="dateField <%=Lock["QClass"]%>">
			            </TD>
			            <td class="lightbluetable"  align="right">延展次數：</td>
			            <td class="whitetablebg" ><input type="text" id="tfx_renewal" name="tfx_renewal" size="2" class="<%=Lock["QClass"]%>"></td>
		            </tr>
		            <tr>
			            <td class="lightbluetable" align="right">註冊費繳納：</td>
			            <td class="whitetablebg" colspan=3 >
	   			            <Select NAME=tfx_pay_times id=tfx_pay_times class="<%=Lock["QClass"]%>"><%#html_pay_times%></SELECT>
			            </td>
			            <td class="lightbluetable"  align="right">繳納日期：</td>
			            <td class="whitetablebg"><input type="text" id="tfx_pay_date" name="tfx_pay_date" size="10" class="dateField <%=Lock["QClass"]%>"></td>
		            </tr>
		            <tr>
			            <td class="lightbluetable"  align="right">結案說明：</td>
			            <td class="whitetablebg" colspan=3><input type=text id="old_end_date" name="old_end_date" >
				            結案日期：<input type="text" id="tfx_end_date" name="tfx_end_date" size="10" class="dateField <%=Lock["QclassRC"]%>">
			                <input type="text" id="tfx_end_name" name="tfx_end_name" size="20" readonly class="SEdit">
                            結案代碼：
				            <Select NAME="tfx_end_code" id="tfx_end_code" class="<%=Lock["Qclass51"]%>" onchange="getEndCode()">
				                <%#html_end_code%>
			                </SELECT>
			                <br>結案原因：
                            <Select NAME="end_type" id="end_type" class="<%=Lock["Qclass51"]%>" onchange="showend_remark()">
                                <%#html_end_type%>
			                </SELECT>
			                <span id="span_end_remark">
			                    <input type=text name="end_remark" id="end_remark" size=40 maxlength=100 class="<%=Lock["Qclass51"]%>">
			                </span>
			            </td>
			            <td class="lightbluetable"  align="right">備註：</td>
			            <td class="whitetablebg"><input type="text" id="tfx_mark" name="tfx_mark" size="1" readonly class="SEdit"></td>
		            </tr>
		            <tr>		
			            <td class="lightbluetable"  align="right">進度序號：</td>
			            <td class="whitetablebg" ><input type="text" id="tfx_step_grade" name="tfx_step_grade" size="5" readonly class="SEdit"></td>
			            <td class="lightbluetable"  align="right">目前案性：</td>
			            <td class="whitetablebg" >
					        <input type="text" id="tfx_now_grade" name="tfx_now_grade" size="2" readonly class="SEdit">
					        <input type="text" id="now_arcase_type" name="now_arcase_type">
					        <input type="text" id="now_arcase_class" name="now_arcase_class">
					        <input type="text" id="now_arcase_classnm" name="now_arcase_classnm">
					        <input type="text" id="tfx_now_arcase" name="tfx_now_arcase">
					        <input type="text" id="now_act_code" name="now_act_code">
					        <input type="text" id="now_act_codenm" name="now_act_codenm">
					        <input type="text" id="now_rs_detail" name="now_rs_detail">
					        <input type="text" id="tfx_now_arcasenm" name="tfx_now_arcasenm" size="20" readonly class="SEdit">
                        </td>
			            <td class="lightbluetable"  align="right">案件狀態：</td>
			            <td class="whitetablebg" >
				            <input type="text" id="tfx_now_stat" name="tfx_now_stat">
				            <input type="text" id="tfx_now_statnm" name="tfx_now_statnm" size="20" readonly class="SEdit">
			            </td>
		            </tr>
		            <tr>
		                <td class="lightbluetable"  align="right">轉案註記：</td>
			            <td class="whitetablebg" >
			                <input type="radio" name="tran_flag" value="A" disabled>轉出
			                <input type="radio" name="tran_flag" value="B" disabled>轉入
			            </td>
			            <td class="lightbluetable"  align="right">轉案單位案件編號：</td>
			            <td class="whitetablebg" >
					        <select id="tran_seq_branch" name="tran_seq_branch" disabled>
					        <%#html_tran_seq_branch%>
					        </select>
					        <input type="text" id="tran_seq" name="tran_seq" size=5 readonly class="SEdit">
					        <input type="text" id="tran_seq1" name="tran_seq1" size="3" readonly class="SEdit">
			            </td>
			            <td class="lightbluetable"  align="right">轉案說明：</td>
			            <td class="whitetablebg" >
				            <input type="text" id="tran_remark" name="tran_remark" size="20" readonly class="SEdit">
			            </td>
		            </tr>
		            <tr id="tr_datectrl" style="display:none">
	                   <td class="whitetablebg" colspan=6>
	                   <!--include file="../brtam/brtaform/brta212form.inc"--><!--管制欄位畫面-->
                       </td>
                    </tr>
                    <tr id="tr_upload" style="display:none">
	                   <td class="whitetablebg" colspan=6>
			            <!--include file="../brtam/brtaform/dmt_upload_form.asp"--><!--文件上傳畫面-->
		             </td>
                    </tr>	
	            </table>
            </div>
            <div class="tabCont" id="#ndmt">
                <input type="text" id="in_scode" name="in_scode" >
                <input type="text" id="in_no" name="in_no">
	                <table border="0" class="bluetable" cellspacing="1" cellpadding="2" style="font-size: 9pt" width="100%">
	                  <tr>
     	                <td class="lightbluetable" align="right">本所編號：</td>
		                <td class="whitetablebg"  colspan=3><%#branch%><%#dept%>-
		                    <input type="text" id="Ifx_seq" name="Ifx_seq" size="<%#Sys.DmtSeq%>" readonly class="SEdit">-
		                    <input type="text" id="seq1" name="seq1" size="<%#Sys.DmtSeq1%>" readonly class="SEdit">
		                    <input type="text" id="tfx_branch" name="tfx_branch">
		                </td>
	                  </tr>
  	                  <tr>
	                    <td class="lightbluetable" align="right">商標圖樣(中文)：</td>
	                    <td class="whitetablebg" colspan=3><input TYPE="text" id="tfx_cappl_name" NAME="tfx_cappl_name" SIZE="50" maxlength="100" class="<%=Lock["QClass"]%>"></td>		
	                  </tr>
  	                  <tr>
	                    <td class="lightbluetable" align="right" rowspan=3>商標圖樣(外文)：</td>
	                    <td class="whitetablebg" colspan=3>外文：<input TYPE="text" id="tfx_eappl_name" NAME="tfx_eappl_name" SIZE="50" maxlength="100" class="<%=Lock["QClass"]%>"></td>
	                  </tr>
  	                  <tr>
	                    <td class="whitetablebg" colspan=3>中文字義：<input TYPE="text" id="tfx_eappl_name1" NAME="tfx_eappl_name1" SIZE="50" maxlength="100" class="<%=Lock["QClass"]%>"></td>
	                  </tr>
  	                  <tr>
	                    <td class="whitetablebg">讀音：<input TYPE="text" id="tfx_eappl_name2" NAME="tfx_eappl_name2" SIZE="50" maxlength="100" class="<%=Lock["QClass"]%>"></td>
	                    <td class="lightbluetable" align="right">語文別：</td>
	                    <td class="whitetablebg">
	   	                    <Select NAME=tfx_zname_type id=tfx_zname_type class="<%=Lock["QClass"]%>"><%#html_country%></SELECT>
	                    </td>
	                  <tr>  
	                    <td class="lightbluetable" align="right">不單獨主張專用權：</td>
	                    <td class="whitetablebg" colspan=3><input TYPE="text" id="tfx_oappl_name" NAME="tfx_oappl_name" SIZE="30" maxlength="50" class="<%=Lock["QClass"]%>"></td>
	                  </tr>
	                  <tr>
	                    <td class="lightbluetable" align="right">圖形說明：</td>
	                    <td class="whitetablebg" colspan=3><input TYPE="text" id="tfx_draw" NAME="tfx_draw" SIZE="50" maxlength="50" class="<%=Lock["QClass"]%>"></td>
	                  </tr>
	                  <tr>
	                    <td class="lightbluetable" align="right">圖檔實際路徑：</td>
	                    <td class="whitetablebg" colspan=3>
                            <input TYPE="text" id="file" name="file">
                            <input TYPE="text" id="tfx_draw_file" NAME="tfx_draw_file" SIZE="50" maxlength="50" readonly>
			                <input type="button" class="cbutton <%=Lock["QClass"]%>" id="butUpload" name="butUpload" value="上傳" onclick="UploadAttach_photo()" >
                            <input type="button" class="cbutton" id="btnDisplay" name="btnDisplay" value="檢視" onclick="PreviewAttach_photo()" >
	                    </td>
	                  </tr>
	                  <tr>
	                    <td class="lightbluetable" align="right">記號說明：</td>
	                    <td class="whitetablebg" ><input TYPE="text" id="tfx_symbol" NAME="tfx_symbol" SIZE="30" maxlength="50" class="<%=Lock["QClass"]%>"></td>
	                    <td class="lightbluetable" align="right">顏色：</td>
	                    <td class="whitetablebg" >
                        <select id="tfx_color" name="tfx_color" class="<%=Lock["QClass"]%>">
			                <option value="" style="color:blue">請選擇
			                <option value="B">墨色
			                <option value="C">彩色
                        </select>
	                    </td>
	                  </tr>
	                  <tr>
			            <td class="lightbluetable" align="right">類別：</td>
			            <td class="whitetablebg"   colspan=5>
				            <input type="text" id="tfx_classB" name="tfx_classB" size="60" readonly class="SEdit">
				            &nbsp;&nbsp;共&nbsp;<input type="text" id="tfx_class_countB" name="tfx_class_countB" size="3" readonly class="SEdit">&nbsp;類
			            </td>
 	                  </tr>
 	                   <tr>
	                  <td class="whitetablebg" colspan=5>
		                <input type=text id=shownum name=shownum value=0> <!--進度筆數-->
		                <table id="tabshow" border="0" class="bluetable" cellspacing="1" cellpadding="2" style="font-size: 9pt" width="100%">
                            <thead>
			                <TR class=whitetablebg align=center>
				                <TD  class="whitetablebg" colspan=6 align=left>
				                    <input type=button value ="增加一筆展覽會優先權" class="cbutton <%=Lock["QClass"]%>" id=show_Add_button name=show_Add_button onclick="add_show()">
				                    <input type=button value ="減少一筆展覽會優先權" class="cbutton <%=Lock["QClass"]%>" id=show_Del_button name=show_Del_button onclick="del_show()">
				                </TD>
			                </TR>
			                <TR align=center class=lightbluetable>
				                <TD></TD><TD>展覽會優先權日</TD><TD>展覽會名稱</TD>
			                </TR>
                            </thead>
                            <tbody></tbody>
                            <script type="text/html" id="show_template"><!--展覽會優先權樣板-->
	                            <tr id=tr_show_##>
		                            <td class=whitetablebg align=center>
                                        <input type=text id='shownum_##' name='shownum_##' class=SEdit readonly size=2 value='##.'>
                                        <input type=hidden id='show_sqlno_##' name='show_sqlno_##'>
		                            </td>
		                            <td class=whitetablebg align=center>
		                                <input type=text size=10 maxlength=10 id='show_date_##' name='show_date_##' onblur="chk_showdate('##')" class="dateField <%=Lock["QClass"]%>" />
		                            </td>
		                            <td class=whitetablebg align=center>
		                                <input type=text id='show_name_##' name='show_name_##' size=50 maxlength=100 class="<%=Lock["QClass"]%>" />
		                            </td>
	                            </tr>
                            </script>
		                </table>
                    </td>
                    </tr>
	                  <tr>
	                  <td class="whitetablebg" colspan=5>
		                <input type=text id=classnum name=classnum value=0> <!--進度筆數-->
		                <table id="tabclass" border="0" class="bluetable" cellspacing="1" cellpadding="2" style="font-size: 9pt" width="100%">
                            <thead>
			                <TR class=whitetablebg align=center>
				                <TD  class="whitetablebg" colspan=6 align=left>
					                <input type=button value ="增加一筆類別" class="cbutton <%=Lock["QClass"]%>" id=good_Add_button name=good_Add_button>
				                </TD>
			                </TR>
			                <TR align=center class=lightbluetable>
				                <TD></TD><TD>類別</TD><TD width="50">群組代碼</TD><TD>商品名稱</TD><TD>商品數</TD><TD class="class_del">刪除</TD>
			                </TR>
                            </thead>
                            <tbody></tbody>
                            <script type="text/html" id="class_template"><!--類別樣板-->
		                        <tr class="tr_class_##">
				                    <td class="lightbluetable" align="center">
                                        <input type=text id='tfx_sqlno_##' name='tfx_sqlno_##'>
                                        <input type=text id='tfx_ctrlnum_##' name='tfx_ctrlnum_##' class=sedit readonly size=2 value='##'>
				                    </td>
				                    <td class="whitetablebg" align="center">
                                        <INPUT type="text" id=tfx_class_## name=tfx_class_## size=3 onchange="getClass()">
				                    </td>
				                    <td class="whitetablebg" align="center">
                                        <textarea style="height:100" id=tfx_grp_code_## name=tfx_grp_code_## class="<%=Lock["QClass"]%>"></textarea>
                                    </td>
				                    <td class="whitetablebg" align="center">
                                        <textarea style="height:100;width:300" id=tfx_goodname_## name=tfx_goodname_## class="<%=Lock["QClass"]%>" onchange="good_name_count('##')"></textarea>
                                    </td>
				                    <td class="whitetablebg" align="center">
                                        <INPUT type="text" id=tfx_goodcount_## name=tfx_goodcount_## size=3 class=sedit value=0>
				                    </td>
				                    <td class="whitetablebg class_del" align="center">
                                        <input type=checkbox id='good_delchk_##' name='good_delchk_##' onclick="good_delchk('##')" class="<%=Lock["QClass"]%>" value="Y">
				                    </td>
			                    </tr>
                            </script>
		                </table>
                    </td>
                    </tr>
                    </table>
            </div>
            <div class="tabCont" id="#apcust">
                <input type=text id=apnum name=apnum value=0><!--進度筆數-->
	            <table border="0" id=tabap class="bluetable" cellspacing="1" cellpadding="2" style="font-size: 9pt" width="100%">
                    <thead>
		                <TR>
			                <TD  class=whitetablebg colspan=4 align=right>
				                <input type=button value ="增加一筆申請人" class="cbutton" id=AP_Add_button name=AP_Add_button>
				                <input type=button value ="減少一筆申請人" class="cbutton" id=AP_Del_button name=AP_Del_button>
			                </TD>
		                </TR>
                    </thead>
                    <tbody></tbody>
                    <script type="text/html" id="apcust_template">
	                    <TR>
		                    <TD class=lightbluetable align=right>
			                    <input type=text id="apnum_##" name="apnum_##" value="##." class="Lock" size=2>申請人種類：
		                    </TD>
		                    <TD class=sfont9>
			                    <select id="apclass_##" name="apclass_##" class="Lock"><%#html_apclass%></select>
                                <input type="text" id="server_flag_##" name="server_flag_##" value="N">
		                    </TD>
		                    <TD class=lightbluetable align=right title="輸入編號並點選確定，即顯示申請人資料；若無資料，請直接輸入申請人資料。">
			                    <span id="span_apcust_no_##" style="cursor:pointer;color:blue">申請人編號<br>(統一編號/身份證字號)：</span>
		                    </TD>
		                    <TD class=sfont9>
			                    <input type=text id="apcust_no_##" name="apcust_no_##" size=11 maxlength=10 onblur="chkapcust_no(reg.apnum.value,'##','apcust_no_')">
		                        <input type='button' id='queryap_##' name='queryap_##' value='確定' onclick="getAP('##')" style='cursor:pointer;' title='輸入編號並點選確定，即顯示申請人資料；若無資料，請直接輸入申請人資料。'>
		                    </TD>
	                    </TR>
	                    <TR>
		                    <TD class=lightbluetable align=right>申請人國籍：</TD>
		                    <TD class=sfont9>
                                <select id="ap_country_##" name="ap_country_##" class="Lock"><%#html_country%></select>
		                    </TD>
		                    <TD class=lightbluetable align=right>排序：</TD>
		                    <TD class=sfont9>
			                    <input type=text id="ap_sort_##" name="ap_sort_##" size=2 maxlength=2>
		                    </TD>
	                    </TR>
	                    <TR>
		                    <TD class=lightbluetable align=right title="輸入關鍵字並點選申請人查詢，即顯示申請人資料清單。">申請人名稱(中)：</TD>
		                    <TD class=sfont9 colspan=3>
                                <input type=text id="ap_cname_##" name="ap_cname_##" SIZE=120 class="Lock">
		                        <input type=text id="apsqlno_##" name="apsqlno_##">
		                        <INPUT TYPE=text id="ap_cname1_##" name="ap_cname1_##" SIZE=40 MAXLENGTH=60 alt="申請人名稱(中)" onblur="fDataLen(this)"><br>
		                        <INPUT TYPE=text id="ap_cname2_##" name="ap_cname2_##" SIZE=40 MAXLENGTH=60 alt="申請人名稱(中)" onblur="fDataLen(this)">
		                    </TD>
	                    </TR>
	                    <TR>
		                    <TD class=lightbluetable align=right>申請人名稱(中)：</TD>
		                    <TD class=sfont9 colspan=3>
		                        姓：<INPUT TYPE=text id="ap_fcname_##" name="ap_fcname_##" SIZE=20 MAXLENGTH=60 class="Lock">
		                        名：<INPUT TYPE=text id="ap_lcname_##" name="ap_lcname_##" SIZE=20 MAXLENGTH=60 class="Lock">
		                    </TD>
	                    </TR>
	                    <TR id="trap_sql_##">
		                    <TD class=lightbluetable align=right>申請人序號：</TD>
		                    <TD class=sfont9 colspan=3>
		                        <INPUT TYPE=text id="ap_sql_##" name="ap_sql_##" SIZE=3 class="Lock">
		                    </TD>
	                    </TR>
	                    <TR>
		                    <TD class=lightbluetable align=right>
                                <input type=button class='cbutton' value='查詢' onclick="get_apnameaddr('##', '', '')">申請人名稱(英)：
		                    </TD>
		                    <TD class=sfont9 colspan=3>
                                <input type=text id="ap_ename_##" name="ap_ename_##" size=120 class="Lock">
		                        <INPUT TYPE=text id="ap_ename1_##" name="ap_ename1_##" SIZE=60 MAXLENGTH=100 alt="申請人名稱(英)" onblur="fDataLen(this)"><br>
		                        <INPUT TYPE=text id="ap_ename2_##" name="ap_ename2_##" SIZE=60 MAXLENGTH=100 alt="申請人名稱(英)" onblur="fDataLen(this)">
	                        </TD>
	                    </TR>
	                    <TR>
		                    <TD class=lightbluetable align=right>申請人名稱(英)：</TD>
		                    <TD class=sfont9 colspan=3>
		                        姓：<INPUT TYPE=text id="ap_fename_##" name="ap_fename_##" SIZE=20 MAXLENGTH=60 class="Lock">
		                        名：<INPUT TYPE=text id="ap_lename_##" name="ap_lename_##" SIZE=20 MAXLENGTH=60 class="Lock">
		                    </TD>
	                    </TR>
	                    <TR>
		                    <TD class=lightbluetable align=right>代表人名稱(中)：</TD>
		                    <TD class=sfont9 colspan=3>
		                        <INPUT TYPE=text id="ap_crep_##" name="ap_crep_##" SIZE=40 MAXLENGTH=40 class="Lock">
		                    </TD>
	                    </TR>
	                    <TR>
		                    <TD class=lightbluetable align=right>代表人名稱(英)：</TD>
		                    <TD class=sfont9 colspan=3>
		                        <INPUT TYPE=text id="ap_erep_##" name="ap_erep_##" SIZE=80 MAXLENGTH=80 class="Lock">
		                    </TD>
	                    </TR>
	                    <TR>
		                    <TD class=lightbluetable align=right>證照地址(中)：</TD>
		                    <TD class=sfont9 colspan=3>
		                        <INPUT TYPE=text id="ap_zip_##" name="ap_zip_##" SIZE=8 MAXLENGTH=8 class="Lock">
		                        <INPUT TYPE=text id="ap_addr1_##" name="ap_addr1_##" SIZE=103 MAXLENGTH=120 class="Lock"><br>
		                        <INPUT TYPE=text id="ap_addr2_##" name="ap_addr2_##" SIZE=103 MAXLENGTH=120 class="Lock">
		                    </TD>
	                    </TR>
	                    <TR>
		                    <TD class=lightbluetable align=right>證照地址(英)：</TD>
		                    <TD class=sfont9 colspan=3>
		                        <INPUT TYPE=text id="ap_eaddr1_##" name="ap_eaddr1_##" SIZE=103 MAXLENGTH=120 class="Lock"><br>
		                        <INPUT TYPE=text id="ap_eaddr2_##" name="ap_eaddr2_##" SIZE=103 MAXLENGTH=120 class="Lock"><br>
		                        <INPUT TYPE=text id="ap_eaddr3_##" name="ap_eaddr3_##" SIZE=103 MAXLENGTH=120 class="Lock"><br>
		                        <INPUT TYPE=text id="ap_eaddr4_##" name="ap_eaddr4_##" SIZE=103 MAXLENGTH=120 class="Lock">
		                    </TD>
	                    </TR>
                    </script>
	            </table>
            </div>
        </td>
    </tr>
    </table>
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

<iframe id="ActFrame" name="ActFrame" src="about:blank" width="100%" height="500" style="display:none"></iframe>
</body>
</html>

<script language="javascript" type="text/javascript">
    $(function () {
        if (window.parent.tt !== undefined) {
            if(main.prgid=="brta78"){
                window.parent.tt.rows = "0%,100%";
            }else{
                window.parent.tt.rows = "*,2*";
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
        settab("#dmt");
        //-----------------
        //取得案件資料
        $.ajax({
            type: "get",
            url: getRootPath() + "/ajax/_dmt.aspx?<%=QueryString%>",
            async: false,
            cache: false,
            success: function (json) {
                //if ($("#chkTest").prop("checked")) toastr.info("<a href='" + this.url + "' target='_new'>Debug(_dmt)！<BR><b><u>(點此顯示詳細訊息)</u></b></a>");
                toastr.info("<a href='" + this.url + "' target='_new'>Debug(_dmt)！<BR><b><u>(點此顯示詳細訊息)</u></b></a>");
                jMain = $.parseJSON(json);
            },
            error: function (xhr) {
                $("#dialog").html("<a href='" + this.url + "' target='_new'>案件資料載入失敗！<u>(點此顯示詳細訊息)</u></a><hr>" + xhr.responseText);
                $("#dialog").dialog({ title: '案件資料載入失敗！', modal: true, maxHeight: 500, width: "90%" });
            }
        });
        $("#btnseq1,#btngetseq").hide();
        if(main.prgid=="brta24") $("#btnseq1").show();//[確定]
        if(main.prgid=="brta78") $("#btngetseq").show();//[抓取案號]
        //類別☑刪除
        if(main.submittask=="U"||main.submittask=="A"){
            $(".class_del").show();
        }else{
            $(".class_del").hide();
        }
        //-----------------
        main.bind();//資料綁定
        $("input.dateField").datepick();
        $(".Lock").lock();
        $(".Hide").hide();
    }

    //資料綁定
    main.bind = function () {
        if (jMain.dmt.length != 0) {
            if(main.prgid=="brta24"){
                $("#tfx_seq").val(jMain.dmt[0].seq);
                $("#Ifx_seq").val(jMain.dmt[0].seq);
                $("#seq1").val("");
                $("#tfx_seq1").val("").unlock();
                $("#arcase_type").val("<%=Request["rs_type"]%>");
                $("#arcase_class").val("<%=Request["rs_class"]%>");
                $("#tfx_arcase").val("<%=Request["rs_code"]%>");
                $("#tfx_arcasenm").val(jMain.dmt[0].arcasenm);
            }else if(main.prgid=="brta78"){
            }else{
                $("#tfx_seq").val(jMain.dmt[0].seq);
                $("#Ifx_seq").val(jMain.dmt[0].seq);
                $("#tfx_seq1").val(jMain.dmt[0].seq1);
                $("#seq1").val(jMain.dmt[0].seq1);
                $("#arcase_type").val(jMain.dmt[0].arcase_type);
                $("#arcase_class").val(jMain.dmt[0].arcase_class);
                $("#tfx_arcase").val(jMain.dmt[0].arcase);
                $("#tfx_arcasenm").val(jMain.dmt[0].arcasenm);
                $("#tfx_in_date").val(dateReviver(jMain.dmt[0].in_date, "yyyy/M/d"));
                $("#tfx_Mseq").val(jMain.dmt[0].mseq);
                $("#tfx_Mseq1").val(jMain.dmt[0].mseq1);
                $("#tfx_step_grade").val(jMain.dmt[0].step_grade);
                $("#tfx_now_grade").val(jMain.dmt[0].now_grade);
                $("#tfx_now_arcase").val(jMain.dmt[0].now_arcase);
                $("#tfx_now_arcasenm").val(jMain.dmt[0].now_arcasenm);
                $("#tfx_now_stat").val(jMain.dmt[0].now_stat);
                $("#tfx_now_statnm").val(jMain.dmt[0].now_statnm);
                $("#tfx_cust_area").val(jMain.dmt[0].cust_area);
                $("#tfx_cust_seq").val(jMain.dmt[0].cust_seq);
                $("#ocust_seq").val(jMain.dmt[0].cust_seq);
                $("#tfx_cust_name").val(jMain.dmt[0].cust_name);
                $("#tfx_con_term").val(jMain.dmt[0].con_termnm);
                $("#tfx_att_sql").val(jMain.dmt[0].att_sql);
                getAtt();
                $("#tfx_Scode").val(jMain.dmt[0].scode);
                $("input[name='tran_flag'][value='" + jMain.dmt[0].tran_flag + "']").prop("checked", true);
                $("#tran_seq_branch").val(jMain.dmt[0].tran_seq_branch);
                $("#tran_seq").val(jMain.dmt[0].tran_seq);
                $("#tran_seq1").val(jMain.dmt[0].tran_seq1);
                $("#tran_remark").val(jMain.dmt[0].tran_remark);
            }
            $("#tfx_cust_prod").val(jMain.dmt[0].cust_prod);
            $("#tfx_tcn_ref").val(jMain.dmt[0].tcn_ref);
            $("#tfx_ref_no1").val(jMain.dmt[0].ref_no1);
            $("#tfx_ref_no2").val(jMain.dmt[0].ref_no2);
            $("#tfx_ref_no3").val(jMain.dmt[0].ref_no3);
            $("#tfx_s_mark").val(jMain.dmt[0].s_mark);
            $("input[name='s_mark'][value='" + jMain.dmt[0].s_mark + "']").prop("checked", true);
            $("#tfx_s_mark2").val(jMain.dmt[0].s_mark2);
            $("input[name='s_mark2'][value='" + jMain.dmt[0].s_mark2 + "']").prop("checked", true);
            $("#tfx_dmt_draw").val(jMain.dmt[0].dmt_draw);
            $("#tfx_class").val(jMain.dmt[0].class);
            $("#tfx_classB").val(jMain.dmt[0].class);
            $("#tfx_class_count").val("0");
            $("#tfx_class_countB").val("0");
            $("#tfx_class_type").val(jMain.dmt[0].class_type);
            $("input[name='class_type'][value='" + jMain.dmt[0].class_type + "']").prop("checked", true);
            $("#tfx_agt_no").val(jMain.dmt[0].agt_no);
            $("#tfx_apply_date").val(dateReviver(jMain.dmt[0].apply_date, "yyyy/M/d"));
            $("#tfx_apply_no").val(jMain.dmt[0].apply_no);
            $("#tfx_issue_date").val(dateReviver(jMain.dmt[0].issue_date, "yyyy/M/d"));
            $("#tfx_issue_no").val(jMain.dmt[0].issue_no);
            $("#tfx_open_date").val(dateReviver(jMain.dmt[0].open_date, "yyyy/M/d"));
            $("#tfx_rej_no").val(jMain.dmt[0].rej_no);
            $("#tfx_rej_item").val(jMain.dmt[0].rej_item);
            $("#tfx_prior_date").val(dateReviver(jMain.dmt[0].prior_date, "yyyy/M/d"));
            $("#tfx_prior_no").val(jMain.dmt[0].prior_no);
            $("#tfx_prior_country").val(jMain.dmt[0].prior_country);
            $("#tfx_term1").val(dateReviver(jMain.dmt[0].term1, "yyyy/M/d"));
            $("#tfx_term2").val(dateReviver(jMain.dmt[0].term2, "yyyy/M/d"));
            $("#tfx_renewal").val(jMain.dmt[0].renewal);
            $("#tfx_pay_times").val(jMain.dmt[0].pay_times);
            $("#tfx_pay_date").val(dateReviver(jMain.dmt[0].pay_date, "yyyy/M/d"));
            $("#old_end_date").val(dateReviver(jMain.dmt[0].end_date, "yyyy/M/d"));
            $("#tfx_end_date").val(dateReviver(jMain.dmt[0].end_date, "yyyy/M/d"));
            $("#tfx_end_code").val(jMain.dmt[0].end_code);
            $("#tfx_end_name").val(jMain.dmt[0].end_codenm);
            $("#end_type").val(jMain.dmt[0].end_type);
            $("#end_remark").val(jMain.dmt[0].end_remark);
            $("#tfx_appl_name").val(jMain.dmt[0].appl_name);
            $("#end_type").triggerHandler("change");
        }

        if (jMain.ndmt.length != 0) {
            $("#tfx_cappl_name").val(jMain.ndmt[0].cappl_name);
            $("#tfx_eappl_name").val(jMain.ndmt[0].eappl_name);
            $("#tfx_eappl_name1").val(jMain.ndmt[0].eappl_name1);
            $("#tfx_eappl_name2").val(jMain.ndmt[0].eappl_name2);
            $("#tfx_zname_type").val(jMain.ndmt[0].zname_type);
            $("#tfx_oappl_name").val(jMain.ndmt[0].oappl_name);
            $("#tfx_draw").val(jMain.ndmt[0].draw);
            $("#file").val(jMain.ndmt[0].draw_file);
            $("#tfx_draw_file").val(jMain.ndmt[0].draw_file);
            $("#tfx_symbol").val(jMain.ndmt[0].symbol);
            $("#tfx_color").val(jMain.ndmt[0].color);
        }

        if (jMain.dmt_good.length != 0) {
            $.each(jMain.dmt_good, function (ix, it) {
                $("#good_Add_button").click();//增加一筆類別
                $("#tfx_sqlno_" + (ix + 1)).val(it.sqlno);//流水號
                $("#tfx_class_" + (ix + 1)).val(it.class);//類別
                $("#tfx_grp_code_" + (ix + 1)).val(it.dmt_grp_code);//群組代碼
                $("#tfx_goodname_" + (ix + 1)).val(it.dmt_goodname);//商品名稱
                $("#tfx_goodcount_" + (ix + 1)).val(it.dmt_goodcount);//商品數
            });
        }

        if (jMain.dmt_show.length != 0) {
            $.each(jMain.dmt_show, function (ix, it) {
                $("#show_Add_button").click();//增加一筆展覽會優先權
                $("#show_sqlno_" + (ix + 1)).val(it.show_sqlno);//流水號
                $("#show_date_" + (ix + 1)).val(dateReviver(it.show_date, "yyyy/M/d"));//展覽會優先權日
                $("#show_name_" + (ix + 1)).val(it.show_name);//展覽會名稱
            });
        }

        if (jMain.dmt_ap.length != 0) {
            $.each(jMain.dmt_ap, function (ix, it) {
                if(ix==0){
                    $("#tfx_apcust_no").val(it.apcust_no);
                    if(main.prgid!="brta78"){
                        $("#tfx_apsqlno").val(it.apsqlno);
                    }
                    $("#tfx_ap_cname").val(it.ap_cname);
                    $("#tfx_ap_ename").val(it.ap_ename);
                }
                $("#AP_Add_button").click();//增加一筆申請人
                if(main.prgid=="brta78"){
                    $("#apsqlno_" + (ix + 1)).val("");
                }else{
                    $("#apsqlno_" + (ix + 1)).val(it.apsqlno);
                }

                $("#apcust_no_" + (ix + 1)).val(it.apcust_no);//申請人編號
                $("#ap_country_" + (ix + 1)).val(it.ap_country);//申請人國籍
                $("#ap_sort_" + (ix + 1)).val(it.ap_sort);//申請人排序
                $("#apclass_" + (ix + 1)).val(it.apclass);//申請人種類
                $("#ap_cname_" + (ix + 1)).val(it.ap_cname);//申請人名稱(中)
                $("#ap_ename_" + (ix + 1)).val(it.ap_ename);//申請人名稱(英)
                $("#ap_zip_" + (ix + 1)).val(it.ap_zip);//證照地址(中)
                $("#ap_addr1_" + (ix + 1)).val(it.ap_addr1);
                $("#ap_addr2_" + (ix + 1)).val(it.ap_addr2);
                $("#ap_eaddr1_" + (ix + 1)).val(it.ap_eaddr1);//證照地址(英)
                $("#ap_eaddr2_" + (ix + 1)).val(it.ap_eaddr2);
                $("#ap_eaddr3_" + (ix + 1)).val(it.ap_eaddr3);
                $("#ap_eaddr4_" + (ix + 1)).val(it.ap_eaddr4);
                $("#ap_crep_" + (ix + 1)).val(it.ap_crep);//代表人名稱(中)
                $("#ap_erep_" + (ix + 1)).val(it.ap_erep);//代表人名稱(英)
                $("#server_flag_" + (ix + 1)).val(it.server_flag);//應收送達人
                $("#ap_fcname_" + (ix + 1)).val(it.ap_fcname);//申請人名稱(中)姓
                $("#ap_lcname_" + (ix + 1)).val(it.ap_lcname);//申請人名稱(中)名
                $("#ap_fename_" + (ix + 1)).val(it.ap_fename);//申請人名稱(英)姓
                $("#ap_lename_" + (ix + 1)).val(it.ap_lename);//申請人名稱(英)名
                $("#ap_sql_" + (ix + 1)).val(it.ap_sql);//申請人序號
                if($("#ap_sql_" + (ix + 1)).val()==""){
                    $("#ap_sql_" + (ix + 1)).val("0");
                }
                if($("#ap_sql_" + (ix + 1)).val()=="0"){
                    //申請人序號空值不顯示
                    $("#trap_sql_"+ (ix + 1)).hide();
                    if($("#ap_addr1_" + (ix + 1)).val()==""){
                        $("#ap_zip_" + (ix + 1)).val(it.ap_ap_zip);//證照地址(中)
                        $("#ap_addr1_" + (ix + 1)).val(it.ap_ap_addr1);
                        $("#ap_addr2_" + (ix + 1)).val(it.ap_ap_addr2);
                        $("#ap_eaddr1_" + (ix + 1)).val(it.ap_ap_eaddr1);//證照地址(英)
                        $("#ap_eaddr2_" + (ix + 1)).val(it.ap_ap_eaddr2);
                        $("#ap_eaddr3_" + (ix + 1)).val(it.ap_ap_eaddr3);
                        $("#ap_eaddr4_" + (ix + 1)).val(it.ap_ap_eaddr4);
                    }
                }
            });
        }
    }

    //取得聯絡人資料
    function getAtt(){
        $("#tfx_att_dept,#tfx_attention").val("");
        $.ajax({
            type: "get",
            url: getRootPath() + "/ajax/_custz_att.aspx?all=Y"+
                "&cust_area=" + $("#tfx_cust_area").val() + 
                "&cust_seq=" + $("#tfx_cust_seq").val()+
                "&att_sql=" + $("#tfx_att_sql").val()+
                "&type=" + main.type+
                "&branch=" + main.branch,
            async: false,
            cache: false,
            success: function (json) {
                //toastr.info("<a href='" + this.url + "' target='_new'>Debug(getAtt)！<BR><b><u>(點此顯示詳細訊息)</u></b></a>");
                var att_list = $.parseJSON(json);
                if (att_list.length == 0) {
                    $("#tfx_att_sql").val("");
                    alert("無此聯絡序號，請重新輸入!!");
                    return false;
                }
                $("#tfx_att_dept").val(att_list[0].att_dept);
                $("#tfx_attention").val(att_list[0].attention);
            },
            error: function (xhr) { 
                $("#dialog").html("<a href='" + this.url + "' target='_new'>聯絡人資料載入失敗！<u>(點此顯示詳細訊息)</u></a><hr>"+xhr.responseText);
                $("#dialog").dialog({ title: '聯絡人資料載入失敗！', modal: true, maxHeight: 500, width: "90%" });
            }
        });
    }

    //代理人停用檢查
    $("#tfx_agt_no").blur(function (e) {
        if($("option:selected",$(this)).attr("v1")=="Y"){
            alert ("輸入之代理人已停用, 請重新輸入!!");
            $(this).focus();
        }
    })

    //商標種類
    $("input[name='s_mark']").click(function (e) {
        $("#tfx_s_mark").val($("input[name='s_mark']:checked").val()||"");
    });

    //商標種類2
    $("input[name='s_mark2']").click(function (e) {
        $("#tfx_s_mark2").val($("input[name='s_mark2']:checked").val()||"");
    });

    //類別種類
    $("input[name='class_type']").click(function (e) {
        $("#tfx_class_type").val($("input[name='class_type']:checked").val()||"");
    });

    //客戶
    $("#tfx_cust_seq").blur(function (e) {
        if($("#ocust_seq").val()!=$("#tfx_cust_seq").val()){
            $.ajax({
                type: "get",
                url: getRootPath() + "/ajax/_apcust.aspx?cust_area=" + $("#tfx_cust_area").val() + "&cust_seq=" + $("#tfx_cust_seq").val(),
                async: false,
                cache: false,
                success: function (json) {
                    //if ($("#chkTest").prop("checked")) toastr.info("<a href='" + this.url + "' target='_new'>Debug(_apcust交辦申請人)！<BR><b><u>(點此顯示詳細訊息)</u></b></a>");
                    var apcust_list = $.parseJSON(json);
                    if (apcust_list.length == 0) {
                        alert("無該客戶，請重新輸入或至[客戶新增]新增該客戶!!!");
                        $("#tfx_cust_seq").val($("#ocust_seq").val()).focus();
                        return false;
                    }

                    $("#tfx_cust_name").val(apcust_list[0].ap_cname1+apcust_list[0].ap_cname2);
                    $("#ocust_seq").val($("#tfx_cust_seq").val());
                },
                error: function (xhr) { 
                    $("#dialog").html("<a href='" + this.url + "' target='_new'>客戶資料載入失敗！<u>(點此顯示詳細訊息)</u></a><hr>"+xhr.responseText);
                    $("#dialog").dialog({ title: '客戶資料載入失敗！', modal: true, maxHeight: 500,width: "90%" });
                }
            });
        }
    });

    //重抓目前案件最大號
    function get_maxseq(){
        var searchSql ="";
        //抓取案件流水號
        if($("#tfx_seq1").val()=="Z"){
            searchSql = "select sql from cust_code where code_type='Z' and cust_code='"+main.branch+"TZ'";
        }else{
            searchSql = "select sql from cust_code where code_type='Z' and cust_code='"+main.branch+"T_'";
        }
        $.ajax({
            type: "get",
            url: getRootPath() + "/ajax/JsonGetSqlData.aspx",
            data: { sql: searchSql },
            async: false,
            cache: false,
            success: function (json) {
                var JSONdata = $.parseJSON(json);
                if (JSONdata.length > 0) {
                    if(CInt(JSONdata[0].sql)>0){
                        $("#tfx_seq").val(JSONdata[0].sql);
                    }
                }
            },
            error: function (xhr) { 
                $("#dialog").html("<a href='" + this.url + "' target='_new'>抓取案件最大編號有誤！<u>(點此顯示詳細訊息)</u></a><hr>"+xhr.responseText);
                $("#dialog").dialog({ title: '抓取案件最大編號有誤！', modal: true, maxHeight: 500,width: "90%" });
            }
        });
    }
    
    //檢查案件主檔是否有此筆案件
    function chkseqdata(){
        var rtnFlag=false;
        //檢查案件主檔
        var searchSql = "count(*) as cnt from dmt where seq= " +$("#tran_seq").val()+ " and seq1='" +$("#tran_seq1").val()+ "' and cg='G' and rs='S'";
        $.ajax({
            type: "get",
            url: getRootPath() + "/ajax/JsonGetSqlData.aspx",
            data: { sql: searchSql },
            async: false,
            cache: false,
            success: function (json) {
                var JSONdata = $.parseJSON(json);
                if (JSONdata.length > 0) {
                    if(CInt(JSONdata[0].cnt)>0){
                        rtnFlag=true;
                    }
                }
            },
            error: function (xhr) { 
                $("#dialog").html("<a href='" + this.url + "' target='_new'>檢查案件主檔有誤！<u>(點此顯示詳細訊息)</u></a><hr>"+xhr.responseText);
                $("#dialog").dialog({ title: '檢查案件主檔有誤！', modal: true, maxHeight: 500,width: "90%" });
            }
        });
        return rtnFlag;
    }
    
    //檢查是否需通知總管處
    function chkstepdata(){
        var searchSql ="";
        //檢查轉入案件是否有官發，有官發要通知總管處
        searchSql = "count(*) as cnt from step_dmt where seq= " +$("#tran_seq").val()+ " and seq1='" +$("#tran_seq1").val()+ "' and cg='G' and rs='S'";
        $.ajax({
            type: "get",
            url: getRootPath() + "/ajax/JsonGetSqlData.aspx?connbr="+$("#tran_seq_branch").val(),
            data: { sql: searchSql },
            async: false,
            cache: false,
            success: function (json) {
                var JSONdata = $.parseJSON(json);
                if (JSONdata.length > 0) {
                    if(CInt(JSONdata[0].cnt)>0){
                        $("#emg_flag").val("Y");
                    }
                }
            },
            error: function (xhr) { 
                $("#dialog").html("<a href='" + this.url + "' target='_new'>檢查轉入案件官發有誤！<u>(點此顯示詳細訊息)</u></a><hr>"+xhr.responseText);
                $("#dialog").dialog({ title: '檢查轉入案件官發有誤！', modal: true, maxHeight: 500,width: "90%" });
            }
        });
    }

    //結案代碼
    function getEndCode(){
        $("#tfx_end_name").val($('option:selected', $("#tfx_end_code")).attr('v1'));
    }

    //結案原因
    function showend_remark(){
        if($("#end_type").val()=="016"){
            $("#end_remark").val("");
            $("#span_end_remark").show();
        }else{
            if($("#end_type").val()!=""){
                $("#end_remark").val($('#end_type :selected').text());
            }
            $("#span_end_remark").hide();
        }
    }

    $("#tfx_seq1").blur(function (e) {
        $("#keyseq1").val("N");
        if(main.prgid=="brta24"){
            $("#btnseq1").unlock();
        }
    })

    //日期檢查
     $("input.dateField").blur(function (e) {
        if ($(this).val() != "" && !$.isDate($(this).val())) {
            alert("日期格式錯誤，請重新輸入!!! 日期格式:YYYY/MM/DD");
            //$(this).addClass("chkError");
            $(this).focus();
        } else {
            //$(this).removeClass("chkError");
        }
    });

    //[確定]
    $("#btnseq1").click(function (e) {
        var purl = getRootPath() + "/ajax/json_dmt.aspx?seq=" + $("#tfx_seq").val() + "&seq1=" + $("#tfx_seq1").val();
        $.ajax({
            type: "get",
            url: purl,
            async: false,
            cache: false,
            success: function (json) {
                var dmt_list = $.parseJSON(json);
                if (dmt_list.length > 0) {
                    alert($("#tfx_seq").val() + "-" +("#tfx_seq1").val()+ "已存在於案件主檔內，請重新輸入!!!");
                    $("#keyseq1").val("N");
                    $("#tfx_seq1").val("").focus();
                } else {
                    $("#seq1").val($("#tfx_seq1").val());
                    $("#keyseq1").val("Y");
                    if(main.prgid=="brta24") $("#btnseq1").lock();
                }
            },
            error: function (xhr) {
                $("#dialog").html("<a href='" + this.url + "' target='_new'>check案件主檔失敗！<u>(點此顯示詳細訊息)</u></a><hr>" + xhr.responseText);
                $("#dialog").dialog({ title: 'check案件主檔失敗！', modal: true, maxHeight: 500, width: "90%" });
            }
        });
    });


    //展覽優先權增加一筆
    function add_show() {
        var nRow = CInt($("#shownum").val()) + 1;
        //複製樣板
        var copyStr = $("#show_template").text() || "";
        copyStr = copyStr.replace(/##/g, nRow);
        $("#tabshow tbody").append(copyStr);
        $("#shownum").val(nRow);
        $(".dateField", $('#tr_show_' + nRow)).datepick();
    }

    //展覽優先權減少一筆
    function del_show() {
        var nRow = CInt($("#shownum").val());
        $('#tr_show_' + nRow).remove();
        $("#shownum").val(Math.max(0, nRow - 1));
    }

    //檢查展覽優先權日期
    function chk_showdate(pno) {
        ChkDate($("#show_date_" + pno)[0]);

        if ($("#show_date_" + pno).val() != "") {
            var sdate = CDate($("#show_date_" + pno).val());
            var today = Today();
            if (sdate.getTime() > today.getTime()) {
                alert("展覽優先權日期不可大於系統日期!!");
                $("#show_date_" + pno).focus();
            }
        }
    }
    //商標圖檔上傳
    function UploadAttach_photo() {
        var pfile_name = "tfx_draw_file";
        if ($("#tfx_seq").val() == "") {
            alert("無案件編號，請先檢查！");
            return false;
        }
        var fseq= padLeft($("#tfx_seq").val(), <%=Sys.DmtSeq%>, "0");
        var tfolder = fseq.Left(1) + "/" + fseq.substr(1, 2);
        var nfilename = "";
        if ($("#tfx_seq1").val()=="_" ||$("#tfx_seq1").val()==""){
            nfilename=$("#tfx_seq").val();
        }else{
            nfilename=$("#tfx_seq").val()+"-"+$("#tfx_seq1").val();
        }

        var url = getRootPath() + "/sub/upload_win_file_new.aspx?type=dmt_photo" +
            "&nfilename=" + nfilename +
            "&draw_file=" + ($("#" + pfile_name).val() || "") +
            "&folder_name="+tfolder +
            "&form_name=file" +
            "&file_name=" + pfile_name +
            "&prgid=brt" +
            "&btnname=" +
            "&filename_flag=source_name";
        window.open(url, "dmtupload", "width=700 height=600 top=50 left=50 toolbar=no, menubar=no, location=no, directories=no resizeable=no status=no scrollbars=yes");
    }
    
    //商標圖檔檢視
    function PreviewAttach_photo() {
        if ($("#file").val() == "") {
            alert("請先上傳圖檔 !!");
            return false;
        }

        var url = getRootPath() + "/sub/display_draw.aspx?draw_file=" + $("#file").val();
        //window.open(url, "window", "width=700,height=600,toolbar=yes,menubar=yes,resizable=yes,scrollbars=yes,status=0,top=50,left=80");
        window.open(url);
    }
////////////////////////////////////////////////////////////////////////////////
    //增加一筆類別
    $("#good_Add_button").click(function (e) {
        var nRow = CInt($("#classnum").val()) + 1;
        //複製樣板
        var copyStr = $("#class_template").text() || "";
        copyStr = copyStr.replace(/##/g, nRow);
        $("#tabclass tbody").append(copyStr);
        $("#classnum").val(nRow);
        $("#tfx_class_count").val(CInt($("#tfx_class_count").val()) + 1);
        $("#tfx_class_countB").val($("#tfx_class_count").val());
        $(".dateField", $('#tr_class_' + nRow)).datepick();
    });
    
    //刪除類別
    function good_delchk(nRow){
        if($("#good_delchk_"+nRow).prop("checked")==true){
            $("#tfx_class_count").val(CInt($("#tfx_class_count").val()) + 1);
        }else{
            $("#tfx_class_count").val(CInt($("#tfx_class_count").val()) - 1);
        }
        $("#tfx_class_countB").val($("#tfx_class_count").val());
        getClass();
    }

        //*****依商品名稱計算類別
    function good_name_count(nRow) {
        var MyString = $("#tfx_goodname_" + nRow).val().trim();
        MyString = MyString.replace(/;/gm, "；");
        MyString = MyString.replace(/,/gm, "，");

        if (MyString.Right(1) == "；" || MyString.Right(1) == "，" || MyString.Right(1) == "、") {
            MyString = MyString.substring(0, MyString.length - 1);
        }

        $("#tfx_goodcount_" + nRow).val("");
        if (MyString != "") {
            var myarray = MyString.split(/[；，、]/);
            $("#tfx_goodname_" + nRow).val(MyString);
            var aKind = myarray.length;//共幾類
            $("#tfx_goodcount_" + nRow).val(aKind);

            if (MyString.indexOf("及") > -1 || MyString.indexOf("或") > -1) {
                alert("【商品服務項目中包含有「及」、「或」等用語，請留意商品項目數。】");
            }
        }
    }

    //類別串接
    function getClass(){
        $("#tfx_class").val("");
        $("#tfx_classB").val("");
        var arrclass=[];
        for (var i = 1; i <= CInt($("#classnum").val()) ; i++) {
            if($("#good_delchk_"+i).prop("checked")==false){
               if ($("#tfx_class_" + i).val() != "") {
                    if (IsNumeric($("#tfx_class_" + i).val())) {
                        var x = padLeft($("#tfx_class_" + i).val(),3,"0");//補0
                        if ($("input[name='class_type']:checked").val() == "int") {
                            if(CInt(x)<1||CInt(x)>45){
                                alert("類別必須介於 001 ~ 045 之間");
                                $("#tfx_class_" + nRow).focus();
                            }
                        }
                        $("#tfx_class_" + i).val(x);
                        arrclass.push(x);
                    } else {
                        alert("商品類別請輸入數值!!!");
                        $("#tfx_class_" + i).val("");
                    }
                }
            }
        }

        $("#tfx_class,#tfx_classB").val(arrclass.join(','));
    }
////////////////////////////////////////////////////////////////////////////////
    //增加一筆申請人
    $("#AP_Add_button").click(function () { 
        var nRow = CInt($("#apnum").val()) + 1;
        //複製樣板
        var copyStr = $("#apcust_template").text()||"";
        copyStr = copyStr.replace(/##/g, nRow);

        $("#tabap>tbody").append("<tr id='tr_ap_" + nRow + "' class='sfont9'><td><table border='0' class='bluetable' cellspacing='1' cellpadding='2' width='100%'>" + copyStr + "</table></td></tr>");
        $("#tr_ap_" + nRow + " .Lock").lock();
        $("#apnum").val(nRow);
    });

    //減少一筆申請人
    $("#AP_Del_button").click(function () {
        var nRow = CInt($("#apnum").val());
        $('#tr_ap_'+nRow).remove();
        $("#apnum").val(Math.max(0, nRow - 1));
    });

    //申請人資料重抓
    function getAP(nRow) {
        $.ajax({
            type: "get",
            url: getRootPath() + "/ajax/_apcust.aspx?apcust_no=" + $("#apcust_no_"+nRow).val() ,
            async: false,
            cache: false,
            success: function (json) {
                if ($("#chkTest").prop("checked")) toastr.info("<a href='" + this.url + "' target='_new'>Debug(_apcust申請人資料重抓)！<BR><b><u>(點此顯示詳細訊息)</u></b></a>");
                var apcust_list = $.parseJSON(json);
                if (apcust_list.length == 0) {
                    alert("無該申請人編號!!!");
                    return false;
                }

                $.each(apcust_list, function (i, item) {
                    $("#apcust_no_" + nRow).val(item.apcust_no);
                    $("#apsqlno_" + nRow).val(item.apsqlno);
                    $("#apclass_" + nRow).val(item.apclass);
                    $("#ap_country_" + nRow).val(item.ap_country);
                    $("#ap_sort_" + nRow).val(item.ap_sort);
                    $("#ap_cname1_" + nRow).val(item.ap_cname1);
                    $("#ap_cname2_" + nRow).val(item.ap_cname2);
                    $("#ap_cname_" + nRow).val(item.ap_cname1 + item.ap_cname2);
                    $("#ap_ename1_" + nRow).val(item.ap_ename1);
                    $("#ap_ename2_" + nRow).val(item.ap_ename2);
                    $("#ap_ename_" + nRow).val(item.ap_ename1 + item.ap_ename2);
                    $("#ap_crep_" + nRow).val(item.ap_crep);
                    $("#ap_erep_" + nRow).val(item.ap_erep);
                    $("#ap_zip_" + nRow).val(item.ap_zip);
                    $("#ap_addr1_" + nRow).val(item.ap_addr1);
                    $("#ap_addr2_" + nRow).val(item.ap_addr2);
                    $("#ap_eaddr1_" + nRow).val(item.ap_eaddr1);
                    $("#ap_eaddr2_" + nRow).val(item.ap_eaddr2);
                    $("#ap_eaddr3_" + nRow).val(item.ap_eaddr3);
                    $("#ap_eaddr4_" + nRow).val(item.ap_eaddr4);
                    $("#ap_fcname_" + nRow).val(item.ap_fcname);
                    $("#ap_lcname_" + nRow).val(item.ap_lcname);
                    $("#ap_fename_" + nRow).val(item.ap_fename);
                    $("#ap_lename_" + nRow).val(item.ap_lename);

                    if(nRow==1){
                        $("#tfx_apcust_no").val(item.apcust_no);
                        $("#tfx_apsqlno").val(item.apsqlno);
                        $("#tfx_ap_cname").val(item.ap_cname);
                        $("#tfx_ap_ename").val(item.ap_ename);
                    }
                    $("#apatt_zip_" + nRow).val(item.apatt_zip);
                    $("#apatt_addr1_" + nRow).val(item.apatt_addr1);
                    $("#apatt_addr2_" + nRow).val(item.apatt_addr2);
                    $("#apatt_tel0_" + nRow).val(item.apatt_tel0);
                    $("#apatt_tel_" + nRow).val(item.apatt_tel);
                    $("#apatt_tel1_" + nRow).val(item.apatt_tel1);
                    $("#apatt_fax_" + nRow).val(item.apatt_fax);
                    if (item.Server_flag == "Y") {
                        $("#server_flag_" + nRow).val(item.Server_flag);
                    } else {
                        $("#server_flag_" + nRow).val("N");
                    }
                    $("#ap_sql_" + nRow).val("");
                })
            },
            error: function (xhr) { 
                $("#dialog").html("<a href='" + this.url + "' target='_new'>申請人資料載入失敗！<u>(點此顯示詳細訊息)</u></a><hr>"+xhr.responseText);
                $("#dialog").dialog({ title: '申請人資料載入失敗！', modal: true, maxHeight: 500,width: "90%" });
            }
        });
    }
    
    //檢查申請人重覆
    //papnum=筆數,pfld=檢查重覆的欄位名,ex:apcust_no_,dbmn_new_no_
    function chkapcust_no (papnum, nRow, pfld) {
        var objAp = {};
        for (var r = 1; r <= CInt(papnum) ; r++) {
            var lineAp = $("#" + pfld + "" + r).val();
            if (lineAp != "" && objAp[lineAp]) {
                alert("(" + r + ")申請人重覆，請重新輸入！！");
                $("#" + pfld + nRow).focus();
            } else {
                objAp[lineAp] = { flag: true, idx: r };
            }
        }
    }
    //抓取申請人多組英文名稱及地址(申請人英文名稱[查詢])
    //pTrId=申請人序號的tr前置名,pFld=欄位前置名
    function get_apnameaddr(nRow, pTrId, pFld) {
        var apsqlno = $("#" + pFld + "apsqlno_" + nRow).val();
        if (apsqlno == "") {
            alert("請先輸入統編或再點選統編後「確定」重新抓取申請人資料！");
            return false;
        }
        //***todo
        var url = getRootPath() + "/cust/cust13_2Qlist.aspx?prgid=Si04W01&apsqlno=" + apsqlno + "&pnum=" + nRow + "&trid=" + pTrId + "&fld=" + pFld;
        window.open(url, 'myWindowOneN',"width=650 height=420 top=40 left=80 toolbar=no, menubar=no, location=no, directories=no resizeable=no status=no scrollbars=yes");
    }
////////////////////////////////////////////////////////////////////////////////
    function formSearchSubmit(a){
        if (a=="Add"){//新增
            //2008/10/7官收立子案
            if(main.prgid=="brta24"){
                if($("#keyseq1").val()=="N"){
			       alert("本所編號變動過，請按[確定]按鈕，重新確定案件編號資料!!!");
			       return false;
			    }
            }
            //2010/9/3轉案新增判斷
            if(main.prgid=="brta78"){
                if($("#keyseq1").val()=="N"){
                    $("#btnseq1").click();
                }
                if (chkNull("客戶編號", reg.tfx_cust_seq)) return false;
                if(CInt($("#apnum").val())==0){
                    alert("本筆案件無申請人，請檢查！");
                    return false;
                }else{
                    for (var pno = 1; pno <= CInt($("#apnum").val()) ; pno++) {
                        var apsqlno=$("#apsqlno_"+pno).val();
                        if(apsqlno==""){
                            alert("申請人" + pno + "未點選[確定]按鈕，請按[確定]按鈕，確定申請人資料！！");
                            settab("#apcust");
                            return false;
                        }
                        if(pno==1){
                            $("#tfx_apsqlno").val(apsqlno);
                        }
                    }
                }
                //檢查案件主檔有無此案件編號
                if(chkseqdata()==true){
                   alert("案件主檔已有此案件編號，請按[抓取案號]重新抓取案件編號！");
                   return false;
                }
                //檢查是否需通知總管處及通知人員
                if(chkstepdata()==true){
                    if($("#emg_scodelist").val()==""||$("#emg_scodelist1").val()==""){
                       alert("系統找不到Email通知總管處人員，無法發信，請通知系統維護人員！");
                       return false;
                    }
                }
            }
        }
        if (a=="Update"){//修改
            //2014/4/22增加檢查是否為雙邊代理查照對象,案件名稱
            if (check_CustWatch("appl_name", $("#tfx_appl_name").val()) == true) {
                settab("#dmt");
                $("#tfx_appl_name").focus();
                return false;
            }

            for (var pno = 1; pno <= CInt($("#apnum").val()) ; pno++) {
                //2014/4/22增加檢查是否為雙邊代理查照對象,客戶名稱
                if (cust_name_chk($("#ap_cname_"+pno).val(), $("#ap_ename_"+pno).val())) {
                    settab("#apcust");
                    return false;
                }
                //2014/4/22增加檢查是否為雙邊代理查照對象,客戶代表人名稱
                if (aprep_name_chk($("#ap_crep_"+pno).val(), $("#ap_erep_"+pno).val())) {
                    settab("#apcust");
                    return false;
                }
            }
        }
	    //2008/9/17新增類別種類
        if($("#tfx_class_type").val()==""&&$("#tfx_s_mark").val()!="L"&&$("#tfx_s_mark").val()!="M"){
            alert("商標類別不為證明標章或團體標章時,類別種類必須輸入或請更正商標類別⑴!!");
            settab("#dmt");
            $("input[name=class_type]").eq(0).focus();
            return false;
        }
        if($("#classnum").val()=="0"&&$("#tfx_s_mark").val()!="L"&&$("#tfx_s_mark").val()!="M"){
            alert("商標類別不為證明標章或團體標章時,類別必須輸入或請更正商標類別⑵!!");
            return false;
        }
    
        for (var i = 1; i <= CInt($("#classnum").val()) ; i++) {
            if($("#good_delchk_"+i).prop("checked")==false){
                if($("#tfx_class_" + i).val() == "" && $("#tfx_s_mark").val()!="L"&&$("#tfx_s_mark").val()!="M"){
                    alert("商標類別不為證明標章或團體標章時,類別必須輸入或請更正商標類別⑶!!");
                    return false;
                }
                if ($("#tfx_class_" + i).val() != "") {
                    if (IsNumeric($("#tfx_class_" + i).val())) {
                        var x = padLeft($("#tfx_class_" + i).val(),3,"0");//補0
                        if ($("#tfx_class_type").val() == "int") {
                            if(CInt(x)<1||CInt(x)>45){
                                alert("類別必須介於 001 ~ 045 之間");
                                return false;
                            }
                        }
                    }
                }
            }
        }

        switch (a) {
            case 'Add':
                $("#submittask").val("A");
                break;
            case 'Update':
                $("#submittask").val("U");
                break;
            case 'Delete':
                $("#submittask").val("D");
                break;
        }

        if($("#submittask").val()=="D"){
            if (confirm("是否確定刪除!!!")==true){
                formPost("Brt15ShowFP_Update.aspx");
            }
        }else{
            $("input:disabled, select:disabled").unlock();
            $(".bsubmit").lock(!$("#chkTest").prop("checked"));
            formPost("Brt15ShowFP_Update.aspx");
        }

    }

    //確認結案
    function formSearchSubmit1(a){
        if (a=="Update"){//確認送結案處理
            if($("#end_type").val()==""){
                alert("確認結案請輸入結案原因！");
                $("#end_type").focus();
                return false;
            }

            $("#endflag51"+main.from_fld, opener.document).val("Y");
            $("#end_date51"+main.from_fld, opener.document).val($("#tfx_end_date").val());
            $("#end_code51"+main.from_fld, opener.document).val($("#tfx_end_code").val());
            $("#end_type51"+main.from_fld, opener.document).val($("#end_type").val());
            $("#end_remark51"+main.from_fld, opener.document).val($("#end_remark").val());
        }

        if (a=="close"){//案號有誤退回
            $("#endflag51"+main.from_fld, opener.document).val("N");
            $("#end_date51"+main.from_fld, opener.document).val("");
            $("#end_code51"+main.from_fld, opener.document).val("");
            $("#end_type51"+main.from_fld, opener.document).val("");
            $("#end_remark51"+main.from_fld, opener.document).val("");
        }
        $(".imgCls").click();
    }

    function formPost(pUrl){
        $("input:disabled, select:disabled").unlock();
        $(".bsubmit").lock(!$("#chkTest").prop("checked"));

        var formData = new FormData($('#reg')[0]);
        $.ajax({
            url:pUrl,
            type : "POST",
            data : formData,
            contentType: false,
            cache: false,
            processData: false,
            beforeSend:function(xhr){
                $("#dialog").html("<div align='center'><h1>存檔中...</h1></div>");
                $("#dialog").dialog({ title: '存檔訊息', modal: true,maxHeight: 500,width: 800,buttons:[] });
            },
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
                                window.parent.tt.rows="100%,0%";
                            }
                        }
                    }
                });
            }
        });
    }
</script>
