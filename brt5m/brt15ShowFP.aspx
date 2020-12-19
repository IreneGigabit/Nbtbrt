<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Collections.Generic"%>

<script runat="server">
    protected string HTProgCap = HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "brt15";//程式檔名前綴
    protected string HTProgCode =  "brt15";//HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
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

    protected string html_agt_no="",html_scode="",html_prior_country = "", html_tran_seq_branch = "";
    protected string html_pay_times = "", html_end_code = "", html_end_type = "";

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
        
        Lock["Qclass"] = "";
        Lock["Qclass51"] = "Lock";//prgid=Brt51客收確認
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
                Lock["Qclass51"] = "";//prgid=Brt51客收確認
            }
        }

        if (prgid == "brta78") {
            emg_scodelist = Sys.getRoleScode(Sys.GetSession("syscode"), "T", "mg_prorm1");//總管處程序組主管
            emg_scodelist1 = Sys.getRoleScode(Sys.GetSession("syscode"), "T", "mg_pror");//總管處程序組主管
        }

        //代理人
        html_agt_no = Sys.getAgent().Option("{agt_no}", "{agt_no}_{agt_namefull}");
        //營洽
        html_scode = Sys.getDmtScode(branch, "").Option("{scode}", "{star}{scode}_{sc_name}", "style='color:{color}'", true);
        //註冊費繳納
        html_pay_times = Sys.getCustCode(Sys.GetSession("dept") + "PAY_TIMES", "", "sortfld").Option("{cust_code}", "{code_name}");
        //結案代碼
        html_end_code = Sys.getEndCode().Option("{chrelno}", "{chrelname}");
        //結案原因
        html_end_type = Sys.getEndType().Option("{cust_code}", "{code_name}");
        //國別
        html_prior_country = Sys.getCountry().Option("{coun_code}", "{coun_code}-{coun_c}");
        //轉案單位
        html_tran_seq_branch = Sys.getBranchCode().Option("{branch}", "{branchname}");
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
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/jquery.datepick.min.js")%>"></script>
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
	            <table border="0" class="bluetable" cellspacing="1" cellpadding="2" style="font-size: 9pt" width="100%">
		            <tr>		
			            <td class="lightbluetable" width="15%" align="right">本所編號：</td>
			            <td class="whitetablebg" >
				            <input type="text" id="sendprgid" name="sendprgid" value="<%#prgid%>">
				            <input type="text" id="keyseq1" name="keyseq1" value="N">
                            <span id="spanbranch"><%#branch%><%#dept%></span>
				            <input type="text" id="tfx_seq" name="tfx_seq" size="<%#Sys.DmtSeq%>" readonly class="SEdit">
				            <input type="text" value="" id="tfx_seq1" name="tfx_seq1" size="<%#Sys.DmtSeq1%>" readonly class="SEdit" >
				            <input type=button class="c1button" id="btnseq1" name="btnseq1" value="確定">
				            <input type=button class="c1button" id="btngetseq" name="btngetseq" onclick="vbscript:get_maxseq" value="抓取案號">
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
				            <input type="radio" name="s_mark" value="" onclick="vbscript:s_mark_onclick">商標
				            <input type="radio" name="s_mark"  value="S" onclick="vbscript:s_mark_onclick">92年修正前服務標章
				            <input type="radio" name="s_mark"  value="L" onclick="vbscript:s_mark_onclick">證明標章
				            <input type="radio" name="s_mark"  value="M" onclick="vbscript:s_mark_onclick">團體標章
				            <input type="radio" name="s_mark"  value="N" onclick="vbscript:s_mark_onclick">團體商標
			            </td>
		            </tr>
		            <tr >
			            <td class="whitetablebg" colspan=5>
				            <input type="text" id="tfx_s_mark2" name="tfx_s_mark2">
			               <input type="radio" name="s_mark2" value="A" onclick="vbscript:s_mark2_onclick">平面
			               <input type="radio" name="s_mark2" value="B" onclick="vbscript:s_mark2_onclick">立體
			               <input type="radio" name="s_mark2" value="C" onclick="vbscript:s_mark2_onclick">聲音
			               <input type="radio" name="s_mark2" value="D" onclick="vbscript:s_mark2_onclick">顏色
			               <input type="radio" name="s_mark2" value="E" onclick="vbscript:s_mark2_onclick">全像圖
			               <input type="radio" name="s_mark2" value="F" onclick="vbscript:s_mark2_onclick">動態
			               <input type="radio" name="s_mark2" value="H" onclick="vbscript:s_mark2_onclick">位置
			               <input type="radio" name="s_mark2" value="I" onclick="vbscript:s_mark2_onclick">氣味
			               <input type="radio" name="s_mark2" value="J" onclick="vbscript:s_mark2_onclick">觸覺
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
				            <input type="radio" name="class_type" value="int" onclick="vbscript:class_type_onclick">國際分類
				            <input type="radio" name="class_type" value="old" onclick="vbscript:class_type_onclick">舊類
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
		            <input type="text" id="tfx_apcust_no" name="tfx_apcust_no">
		            <input type="text" id="tfx_apsqlno" name="tfx_apsqlno">
		            <input type="text" id="tfx_ap_cname" name="tfx_ap_cname">
		            <input type="text" id="tfx_ap_ename" name="tfx_ap_ename">	
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
				            <select id="tfx_agt_no" name="tfx_agt_no" class="<%=Lock["QClass"]%>" onblur="vbscript:getAgt">
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
			            <td class="whitetablebg"><input type="text" id="tfx_apply_no" name="tfx_apply_no" size="20" class="<%=Lock["QClass"]%>"></td>
		            </tr>
			            <td class="lightbluetable"  align="right">註冊日期：</td>
			            <td class="whitetablebg" colspan=3><input type="text" id="tfx_issue_date" name="tfx_issue_date" size="10" class="dateField <%=Lock["QClass"]%>"></td>
			            <td class="lightbluetable"  align="right">註 冊 號：</td>
			            <td class="whitetablebg"><input type="text" id="tfx_issue_no" name="tfx_issue_no" size="20" class="<%=Lock["QClass"]%>"></td>
		            </tr>
		            <tr>			
			            <td class="lightbluetable"  align="right">公告日期：</td>
			            <td class="whitetablebg"><input type="text" id="tfx_open_date" name="tfx_open_date" size="10" class="dateField <%=Lock["QClass"]%>"></td>
			            <td class="lightbluetable"  align="right">核 駁 號：</td>
			            <td class="whitetablebg"><input type="text" id="tfx_rej_no" name="tfx_rej_no" size="20" class="<%=Lock["QClass"]%>"></td>
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
	   			            <Select NAME=tfx_prior_country id=tfx_prior_country class="<%=Lock["QClass"]%>"><%#html_prior_country%></SELECT>
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
				            <Select NAME="tfx_end_code" id="tfx_end_code" class="<%=Lock["Qclass51"]%>" onchange="vbscript:getEndCode">
				            <%#html_end_code%>
			                </SELECT>
			                <br>結案原因：
                            <Select NAME="end_type" id="end_type" class="<%=Lock["Qclass51"]%>" onchange="vbscript:showend_remark">
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
					            <input type="hidden" id="now_arcase_type" name="now_arcase_type">
					            <input type="hidden" id="now_arcase_class" name="now_arcase_class">
					            <input type="hidden" id="now_arcase_classnm" name="now_arcase_classnm">
					            <input type="hidden" id="tfx_now_arcase" name="tfx_now_arcase">
					            <input type="hidden" id="now_act_code" name="now_act_code">
					            <input type="hidden" id="now_act_codenm" name="now_act_codenm">
					            <input type="hidden" id="now_rs_detail" name="now_rs_detail">
					            <input type="text" id="tfx_now_arcasenm" name="tfx_now_arcasenm" size="20" readonly class="SEdit"></td>
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
            </div>
            <div class="tabCont" id="#apcust">
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

    //關閉視窗
    $(".imgCls").click(function (e) {
        if (window.parent.tt !== undefined) {
            window.parent.tt.rows = "100%,0%";
        } else {
            window.close();
        }
    })

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
                $("#seq1").val(jMain.dmt[0]);
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
        }
    }

    //取得聯絡人資料
    function getAtt(){
        $("#tfx_att_dept,#tfx_attention").val("");
        $.ajax({
            type: "get",
            url: getRootPath() + "/ajax/_custz_att.aspx"+
                "?cust_area=" + $("#tfx_cust_area").val() + 
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

    //存檔
    function formModSubmit(){
        $.maskStart();
        var saveflag=main.savechk();
        $.maskStop();

        if(!saveflag) return false;

        $("#submittask").val("Edit");

        //$("select,textarea,input,span").unlock();
        $("input:disabled, select:disabled").unlock();
        $(".bsubmit").lock(!$("#chkTest").prop("checked"));

        var formData = new FormData($('#reg')[0]);
        $.ajax({
            url:'<%=HTProgPrefix%>EditA9Z_Update.aspx',
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
            //complete: function (xhr, status) { main.onComplete(xhr, status); }
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

        //reg.action = "<%=HTProgPrefix%>EditA9Z_Update.aspx";
        //if($("#chkTest").prop("checked"))
        //    reg.target = "ActFrame";
        //else
        //    reg.target = "_self";
        //reg.submit();
    }
</script>
