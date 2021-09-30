<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<script runat="server">
    protected string HTProgCap = "案件主檔資料查詢";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "brta21";//程式檔名前綴
    protected string HTProgCode =  HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼//brt51客收確認,brta24官收確認,brta78轉案確認
    protected int HTProgRight = 0;
    protected string DebugStr = "";
    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";
    protected string QueryString = "";
    protected string Title = "";

    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected Dictionary<string, string> Lock = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    protected string submitTask = "";
    protected string seq = "";
    protected string seq1 = "";
    protected string from_fld = "";
    protected string type = "";
    protected string branch = "";
    protected string dept = "";

    protected string html_agt_no = "", html_scode = "", html_country = "";
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

        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        //HTProgCap = myToken.Title;
        DebugStr = myToken.DebugStr;
        if (HTProgRight >= 0) {
            PageLayout();
            this.DataBind();
        }
    }

    private void PageLayout() {
        StrFormBtnTop += "<a class=\"imgInit\" href=\"javascript:this_init();void(0);\" >[重新整理]</a>\n";
        StrFormBtnTop += "<a class=\"imgCls\" href=\"javascript:void(0);\" >[關閉視窗]</a>\n";
        
        //代理人
        html_agt_no = Sys.getAgent().Option("{agt_no}", "{agt_no}_{agt_namefull}", "v1='{end_flag}'", true);
        //營洽
        html_scode = Sys.getDmtScode(branch, "").Option("{scode}", "{star}{scode}_{sc_name}", "style='color:{color}'", true);
        //註冊費繳納
        html_pay_times = Sys.getCustCode(Sys.GetSession("dept") + "PAY_TIMES", "", "sortfld").Option("{cust_code}", "{code_name}");
        //結案代碼
        html_end_code = Sys.getEndCode().Option("{cust_code}", "{code_name}", "v1='{code_name}'", true);
        //結案原因
        html_end_type = Sys.getEndType().Option("{cust_code}", "{code_name}");
        //國別
        html_country = Sys.getCountry().Option("{coun_code}", "{coun_code}-{coun_c}");
        //申請人種類
        html_apclass = Sys.getCustCode("apclass", "", "sortfld").Option("{cust_code}", "{code_name}");
    }
</script>
<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title><%=HTProgCap%></title>
<uc1:head_inc_form runat="server" ID="head_inc_form" />
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
            <span id="span_maxseq"></span>
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
	<input type="hidden" id="submittask" name="submittask" value="<%=submitTask%>">
	<input type="hidden" id="prgid" name="prgid" value="<%=prgid%>">

    <table cellspacing="1" cellpadding="0" width="98%" border="0">
    <tr>
        <td>
        <table border="0" cellspacing="0" cellpadding="0">
            <tr id="CTab">
                <td class="tab" href="#dmt">案件基本內容</td>
                <td class="tab" href="#ndmt">案件明細內容</td>
            </tr>
        </table>
        </td>
    </tr>
    <tr>
        <td>
            <div class="tabCont" id="#dmt">
                <input type="hidden" id="tfx_apcust_no" name="tfx_apcust_no">
		        <input type="hidden" id="tfx_apsqlno" name="tfx_apsqlno">
		        <input type="hidden" id="tfx_ap_cname" name="tfx_ap_cname">
		        <input type="hidden" id="tfx_ap_ename" name="tfx_ap_ename">	
	            <table border="0" class="bluetable" cellspacing="1" cellpadding="2" style="font-size: 9pt" width="100%">
		            <tr>
			            <td class="lightbluetable" width="15%" align="right">本所編號：</td>
			            <td class="whitetablebg" >
				            <input type="hidden" id="sendprgid" name="sendprgid" value="<%#prgid%>">
				            <input type="hidden" id="keyseq1" name="keyseq1" value="N">
                            <span id="spanbranch"><%#branch%><%#dept%></span>
                            <input type="text" id="tfx_seq" name="tfx_seq" size="<%#Sys.DmtSeq%>" readonly class="SEdit">-<input type="text" id="tfx_seq1" name="tfx_seq1" size="<%#Sys.DmtSeq1%>" readonly class="SEdit" >
			            </td>
			            <td class="lightbluetable" width="15%" align="right">立案案性：</td>
			            <td class="whitetablebg"   >
					        <input type="hidden" id="arcase_type" name="arcase_type" >
					        <input type="hidden" id="arcase_class" name="arcase_class" >
					        <input type="hidden" id="tfx_arcase" name="tfx_arcase" size="10">
					        <input type="text" id="tfx_arcasenm" name="tfx_arcasenm" size="20" readonly class="SEdit">
			            </td>
			            <td class="lightbluetable" width="15%" align="right">立案日期：</td>
			            <td class="whitetablebg" ><input type="text" id="tfx_in_date" name="tfx_in_date" size="10" readonly class="SEdit"></td>
		            </tr>
		            <tr>		
			            <td class="lightbluetable" align="right">正商標號：</td>
			            <td class="whitetablebg"><input type="text" id="tfx_tcn_ref" name="tfx_tcn_ref" size="7" class="Lock"></td>
			            <td class="lightbluetable" align="right">相關案號：</td>
			            <td class="whitetablebg" >
				            <input type="text" id="tfx_ref_no1" name="tfx_ref_no1" size="7" class="Lock">
				            <input type="text" id="tfx_ref_no2" name="tfx_ref_no2" size="7" class="Lock">
				            <input type="text" id="tfx_ref_no3" name="tfx_ref_no3" size="7" class="Lock">
			            </td>
			            <td class="lightbluetable" align="right">母案編號：</td>
			            <td class="whitetablebg" >
				            <input type="text" id="tfx_Mseq" name="tfx_Mseq" size="5" class="Lock">-<input type="text" id="tfx_Mseq1" name="tfx_Mseq1" size="1" class="Lock">
			            </td>
		            </tr>
		            <tr>		
			            <td class="lightbluetable"  align="right" rowspan=2>商標種類：</td>
			            <td class="whitetablebg" colspan=5>
				            <input type="hidden" id="tfx_s_mark" name="tfx_s_mark">
				            <input type="radio" name="s_mark" value="" class="Lock">商標
				            <input type="radio" name="s_mark"  value="S" class="Lock">92年修正前服務標章
				            <input type="radio" name="s_mark"  value="L" class="Lock">證明標章
				            <input type="radio" name="s_mark"  value="M" class="Lock">團體標章
				            <input type="radio" name="s_mark"  value="N" class="Lock">團體商標
			            </td>
		            </tr>
		            <tr >
			            <td class="whitetablebg" colspan=5>
				            <input type="hidden" id="tfx_s_mark2" name="tfx_s_mark2">
			               <input type="radio" name="s_mark2" value="A" class="Lock">平面
			               <input type="radio" name="s_mark2" value="B" class="Lock">立體
			               <input type="radio" name="s_mark2" value="C" class="Lock">聲音
			               <input type="radio" name="s_mark2" value="D" class="Lock">顏色
			               <input type="radio" name="s_mark2" value="E" class="Lock">全像圖
			               <input type="radio" name="s_mark2" value="F" class="Lock">動態
			               <input type="radio" name="s_mark2" value="H" class="Lock">位置
			               <input type="radio" name="s_mark2" value="I" class="Lock">氣味
			               <input type="radio" name="s_mark2" value="J" class="Lock">觸覺
			            </TD>
		            </tr>
		            <tr>
			            <td class="lightbluetable" align="right">商標名稱：</td>
			            <td class="whitetablebg" colspan=3>
				            <input type="text" id="tfx_appl_name" name="tfx_appl_name" size="60" MAXLENGTH="100" alt="商標名稱" class="Lock" onblur="fDataLen(this)">
			            </td>
			            <td class="lightbluetable" align="right">圖示：</td>
			            <td class="whitetablebg"><input type="text" id="tfx_dmt_draw" name="tfx_dmt_draw" size="1" class="Lock"></td>
		            </tr>
		            <tr>
			            <td class="lightbluetable" align="right">類別種類：</td>
			            <td class="whitetablebg" colspan=3>
				            <input type="hidden" id="tfx_class_type" name="tfx_class_type">
				            <input type="radio" name="class_type" value="int" class="Lock">國際分類
				            <input type="radio" name="class_type" value="old" class="Lock">舊類
			            </td>
			            <td class="lightbluetable" align="right">客戶卷號：</td>
			            <td class="whitetablebg" >
				            <input type="text" id="tfx_cust_prod" name="tfx_cust_prod" size="15" class="Lock">
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
				            <input type="text" id="tfx_cust_seq" name="tfx_cust_seq" size="5" class="Lock">&nbsp;
				            <input type="text" id="tfx_cust_name" name="tfx_cust_name" size="25" readonly class="SEdit">
				            <input type="hidden" id="ocust_seq" name="ocust_seq">
			            </td>
			            <td class="lightbluetable" align="right">顧問：</td>
			            <td class="whitetablebg"><input type="text" id="tfx_con_term" name="tfx_con_term" size="1" readonly class="SEdit"></td>
		            </tr>
  		            <tr>		
			            <td class="lightbluetable" align="right">聯絡序號：</td>
			            <td class="whitetablebg"><input type="text" id="tfx_att_sql" name="tfx_att_sql" size="3" class="Lock" onblur="getAtt()"></td>
			            <td class="lightbluetable" align="right">聯絡部門：</td>
			            <td class="whitetablebg"><input type="text" id="tfx_att_dept" name="tfx_att_dept" size="10" readonly class="SEdit"></td>
			            <td class="lightbluetable" align="right">聯 絡 人：</td>
			            <td class="whitetablebg"><input type="text" id="tfx_attention" name="tfx_attention" size="10" readonly class="SEdit"></td>
		            </tr>
		            <tr>		
			            <td class="lightbluetable"  align="right">代理人：</td>
			            <td class="whitetablebg"  colspan=3 >
				            <select id="tfx_agt_no" name="tfx_agt_no" class="Lock">
				            <%#html_agt_no%>
				            </select>
			            </td>
			            <td class="lightbluetable" align="right">營洽：</td>
			            <td class="whitetablebg" >
				            <select id="tfx_Scode" name="tfx_Scode" class="Lock">
					            <option value="" style="color:blue">全部</option> 
					            <option value="<%#Sys.GetSession("sebranch").ToLower()%><%#Sys.GetSession("dept").ToLower()%>">部門(開放客戶)</option>
					            <%#html_scode%>
				            </select>
			            </td>
		            </tr>
		            <tr>		
			            <td class="lightbluetable"  align="right">申請日期：</td>
			            <td class="whitetablebg" colspan=3><input type="text" id="tfx_apply_date" name="tfx_apply_date" size="10" class="dateField Lock"></td>
			            <td class="lightbluetable"  align="right">申 請 號：</td>
			            <td class="whitetablebg"><input type="text" id="tfx_apply_no" name="tfx_apply_no" size="20" onblur="chk_dmt_applyno(this,9)" class="Lock"></td>
		            </tr>
		            <tr>
			            <td class="lightbluetable"  align="right">註冊日期：</td>
			            <td class="whitetablebg" colspan=3><input type="text" id="tfx_issue_date" name="tfx_issue_date" size="10" class="dateField Lock"></td>
			            <td class="lightbluetable"  align="right">註 冊 號：</td>
			            <td class="whitetablebg"><input type="text" id="tfx_issue_no" name="tfx_issue_no" size="20" onblur="chk_dmt_issueno(this,8)" class="Lock"></td>
		            </tr>
		            <tr>
			            <td class="lightbluetable"  align="right">公告日期：</td>
			            <td class="whitetablebg"><input type="text" id="tfx_open_date" name="tfx_open_date" size="10" class="dateField Lock"></td>
			            <td class="lightbluetable"  align="right">核 駁 號：</td>
			            <td class="whitetablebg"><input type="text" id="tfx_rej_no" name="tfx_rej_no" size="20" onblur="chk_dmt_rejno(this,7)" class="Lock"></td>
			            <td class="lightbluetable" align="right">爭議條款：</td>
			            <td class="whitetablebg" ><input type="text" id="tfx_rej_item" name="tfx_rej_item" size="5" class="Lock"></td>
		            </tr>
		            <tr>
			            <td class="lightbluetable"  align="right">優先權日期：</td>
			            <td class="whitetablebg"><input type="text" id="tfx_prior_date" name="tfx_prior_date" size="10" class="dateField Lock"></td>
			            <td class="lightbluetable"  align="right">優先權申請案號：</td>
			            <td class="whitetablebg"><input type="text" id="tfx_prior_no" name="tfx_prior_no" size="20" class="Lock"></td>
			            <td class="lightbluetable" align="right">優先權申請國家：</td>
			            <td class="whitetablebg" >
	   			            <Select NAME=tfx_prior_country id=tfx_prior_country class="Lock"><%#html_country%></SELECT>
			            </td>
		            </tr>
		            <tr>
			            <td class="lightbluetable"  align="right">專用期限：</td>
			            <td class="whitetablebg"  colspan=3 >
				            <input type="text" id="tfx_term1" name="tfx_term1" size="10" class="dateField Lock">&nbsp;~&nbsp;
				            <input type="text" id="tfx_term2" name="tfx_term2" size="10" class="dateField Lock">
			            </TD>
			            <td class="lightbluetable"  align="right">延展次數：</td>
			            <td class="whitetablebg" ><input type="text" id="tfx_renewal" name="tfx_renewal" size="2" class="Lock"></td>
		            </tr>
		            <tr>
			            <td class="lightbluetable" align="right">註冊費繳納：</td>
			            <td class="whitetablebg" colspan=3 >
	   			            <Select NAME=tfx_pay_times id=tfx_pay_times class="Lock"><%#html_pay_times%></SELECT>
			            </td>
			            <td class="lightbluetable"  align="right">繳納日期：</td>
			            <td class="whitetablebg"><input type="text" id="tfx_pay_date" name="tfx_pay_date" size="10" class="dateField Lock"></td>
		            </tr>
		            <tr>
			            <td class="lightbluetable"  align="right">結案說明：</td>
			            <td class="whitetablebg" colspan=3><input type=hidden id="old_end_date" name="old_end_date" >
				            結案日期：<input type="hidden" id="tfx_end_date" name="tfx_end_date" size="10" class="dateField Lock">
			                <input type="text" id="tfx_end_name" name="tfx_end_name" size="20" readonly class="SEdit">
                            結案代碼：
				            <Select NAME="tfx_end_code" id="tfx_end_code" class="Lock" onchange="getEndCode()">
				                <%#html_end_code%>
			                </SELECT>
			                <br>結案原因：
                            <Select NAME="end_type" id="end_type" class="Lock" onchange="showend_remark()">
                                <%#html_end_type%>
			                </SELECT>
			                <span id="span_end_remark">
			                    <input type=text name="end_remark" id="end_remark" size=40 maxlength=100 class="Lock">
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
					        <input type="text" id="tfx_now_arcasenm" name="tfx_now_arcasenm" size="20" readonly class="SEdit">
                        </td>
			            <td class="lightbluetable"  align="right">案件狀態：</td>
			            <td class="whitetablebg" >
				            <input type="hidden" id="tfx_now_stat" name="tfx_now_stat">
				            <input type="text" id="tfx_now_statnm" name="tfx_now_statnm" size="20" readonly class="SEdit">
			            </td>
		            </tr>
	            </table>
            </div>
            <div class="tabCont" id="#ndmt">
                <input type="hidden" id="in_scode" name="in_scode" >
                <input type="hidden" id="in_no" name="in_no">
	                <table border="0" class="bluetable" cellspacing="1" cellpadding="2" style="font-size: 9pt" width="100%">
	                  <tr>
     	                <td class="lightbluetable" align="right">本所編號：</td>
		                <td class="whitetablebg"  colspan=3><%#branch%><%#dept%>
		                    <input type="text" id="Ifx_seq" name="Ifx_seq" size="<%#Sys.DmtSeq%>" readonly class="SEdit">-<input type="text" id="seq1" name="seq1" size="<%#Sys.DmtSeq1%>" readonly class="SEdit">
		                    <input type="hidden" id="tfx_branch" name="tfx_branch">
		                </td>
	                  </tr>
  	                  <tr>
	                    <td class="lightbluetable" align="right">商標圖樣(中文)：</td>
	                    <td class="whitetablebg" colspan=3><input TYPE="text" id="tfx_cappl_name" NAME="tfx_cappl_name" SIZE="50" maxlength="100" class="Lock"></td>		
	                  </tr>
  	                  <tr>
	                    <td class="lightbluetable" align="right" rowspan=3>商標圖樣(外文)：</td>
	                    <td class="whitetablebg" colspan=3>外文：<input TYPE="text" id="tfx_eappl_name" NAME="tfx_eappl_name" SIZE="50" maxlength="100" class="Lock"></td>
	                  </tr>
  	                  <tr>
	                    <td class="whitetablebg" colspan=3>中文字義：<input TYPE="text" id="tfx_eappl_name1" NAME="tfx_eappl_name1" SIZE="50" maxlength="100" class="Lock"></td>
	                  </tr>
  	                  <tr>
	                    <td class="whitetablebg">讀音：<input TYPE="text" id="tfx_eappl_name2" NAME="tfx_eappl_name2" SIZE="50" maxlength="100" class="Lock"></td>
	                    <td class="lightbluetable" align="right">語文別：</td>
	                    <td class="whitetablebg">
	   	                    <Select NAME=tfx_zname_type id=tfx_zname_type class="Lock"><%#html_country%></SELECT>
	                    </td>
	                  <tr>  
	                    <td class="lightbluetable" align="right">不單獨主張專用權：</td>
	                    <td class="whitetablebg" colspan=3><input TYPE="text" id="tfx_oappl_name" NAME="tfx_oappl_name" SIZE="30" maxlength="50" class="Lock"></td>
	                  </tr>
	                  <tr>
	                    <td class="lightbluetable" align="right">圖形說明：</td>
	                    <td class="whitetablebg" colspan=3><input TYPE="text" id="tfx_draw" NAME="tfx_draw" SIZE="50" maxlength="50" class="Lock"></td>
	                  </tr>
	                  <tr>
	                    <td class="lightbluetable" align="right">圖檔實際路徑：</td>
	                    <td class="whitetablebg" colspan=3>
                            <input TYPE="hidden" id="file" name="file">
                            <input TYPE="text" id="tfx_draw_file" NAME="tfx_draw_file" class="Lock" SIZE="50" maxlength="50" readonly>
                            <input type="button" class="cbutton" id="btnDisplay" name="btnDisplay" value="檢視" onclick="PreviewAttach_photo()" >
	                    </td>
	                  </tr>
	                  <tr>
	                    <td class="lightbluetable" align="right">記號說明：</td>
	                    <td class="whitetablebg" ><input TYPE="text" id="tfx_symbol" NAME="tfx_symbol" SIZE="30" maxlength="50" class="Lock"></td>
	                    <td class="lightbluetable" align="right">顏色：</td>
	                    <td class="whitetablebg" >
                        <select id="tfx_color" name="tfx_color" class="Lock">
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
		                <input type=hidden id=shownum name=shownum value=0> <!--進度筆數-->
		                <table id="tabshow" border="0" class="bluetable" cellspacing="1" cellpadding="2" style="font-size: 9pt" width="100%">
                            <thead>
			                <TR class=whitetablebg align=center>
				                <TD  class="whitetablebg" colspan=6 align=left>
				                    <input type=button value ="增加一筆展覽會優先權" class="cbutton Lock" id=show_Add_button name=show_Add_button onclick="add_show()">
				                    <input type=button value ="減少一筆展覽會優先權" class="cbutton Lock" id=show_Del_button name=show_Del_button onclick="del_show()">
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
		                                <input type=text size=10 maxlength=10 id='show_date_##' name='show_date_##' onblur="chk_showdate('##')" class="dateField Lock" />
		                            </td>
		                            <td class=whitetablebg align=center>
		                                <input type=text id='show_name_##' name='show_name_##' size=50 maxlength=100 class="Lock" />
		                            </td>
	                            </tr>
                            </script>
		                </table>
                    </td>
                    </tr>
	                  <tr>
	                  <td class="whitetablebg" colspan=5>
		                <input type=hidden id=classnum name=classnum value=0> <!--進度筆數-->
		                <table id="tabclass" border="0" class="bluetable" cellspacing="1" cellpadding="2" style="font-size: 9pt" width="100%">
                            <thead>
			                <TR class=whitetablebg align=center>
				                <TD  class="whitetablebg" colspan=6 align=left>
					                <input type=button value ="增加一筆類別" class="cbutton Lock" id=good_Add_button name=good_Add_button>
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
                                        <input type=hidden id='tfx_sqlno_##' name='tfx_sqlno_##'>
                                        <input type=text id='tfx_ctrlnum_##' name='tfx_ctrlnum_##' class=sedit readonly size=2 value='##'>
				                    </td>
				                    <td class="whitetablebg" align="center">
                                        <INPUT type="text" id=tfx_class_## name=tfx_class_## size=3 onchange="getClass()" class="Lock">
				                    </td>
				                    <td class="whitetablebg" align="center">
                                        <textarea style="height:100px" id=tfx_grp_code_## name=tfx_grp_code_## class="Lock"></textarea>
                                    </td>
				                    <td class="whitetablebg" align="center">
                                        <textarea style="height:100px;width:300px" id=tfx_goodname_## name=tfx_goodname_## class="Lock" onchange="good_name_count('##')"></textarea>
                                    </td>
				                    <td class="whitetablebg" align="center">
                                        <INPUT type="text" id=tfx_goodcount_## name=tfx_goodcount_## size=3 class=sedit value=0>
				                    </td>
				                    <td class="whitetablebg class_del" align="center">
                                        <input type=checkbox id='good_delchk_##' name='good_delchk_##' onclick="good_delchk('##')" class="Lock" value="Y">
				                    </td>
			                    </tr>
                            </script>
		                </table>
                    </td>
                    </tr>
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

<iframe id="ActFrame" name="ActFrame" src="about:blank" width="100%" height="300" style="display:none"></iframe>
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
                if (!isJson(json) || $("#chkTest").prop("checked")) {
                    $("#dialog").html("<a href='" + this.url + "' target='_new'>Debug！<u>(點此顯示詳細訊息)</u></a><hr>" + json);
                    $("#dialog").dialog({ title: 'Debug！', modal: true, maxHeight: 500, width: "90%" });
                    return false;
                }
                jMain = $.parseJSON(json);
            },
            error: function (xhr) {
                $("#dialog").html("<a href='" + this.url + "' target='_new'>案件資料載入失敗！<u>(點此顯示詳細訊息)</u></a><hr>" + xhr.responseText);
                $("#dialog").dialog({ title: '案件資料載入失敗！', modal: true, maxHeight: 500, width: "90%" });
            }
        });
        $("#btnseq1,#btngetseq").hide();

        //-----------------
        main.bind();//資料綁定
        $("input.dateField").datepick();
        $(".Lock").lock();
        $(".Hide").hide();
    }

    //資料綁定
    main.bind = function () {
        if (jMain.dmt.length != 0) {
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
            $("#ocust_seq").val(jMain.dmt[0].cust_seq);
            $("#tfx_Scode").val(jMain.dmt[0].scode);
            $("#tfx_cust_area").val(jMain.dmt[0].cust_area);
            $("#tfx_cust_seq").val(jMain.dmt[0].cust_seq);
            $("#tfx_cust_prod").val(jMain.dmt[0].cust_prod);
            $("#tfx_cust_name").val(jMain.dmt[0].cust_name);
            $("#tfx_con_term").val(jMain.dmt[0].con_termnm);
            $("#tfx_att_sql").val(jMain.dmt[0].att_sql);
            getAtt();
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

        //類別☑刪除
        if(main.submittask=="U"||main.submittask=="A"){
            $(".class_del").show();
        }else{
            $(".class_del").hide();
        }
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
</script>
