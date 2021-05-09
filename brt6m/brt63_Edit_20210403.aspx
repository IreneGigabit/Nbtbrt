﻿<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Data"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>
<%@ Register Src="~/commonForm/Brta21form.ascx" TagPrefix="uc1" TagName="Brta21form" %>
<%@ Register Src="~/commonForm/brta311form.ascx" TagPrefix="uc1" TagName="brta311form" %>
<%@ Register Src="~/commonForm/Brta212form.ascx" TagPrefix="uc1" TagName="Brta212form" %>
<%@ Register Src="~/commonForm/dmt_upload_Form.ascx" TagPrefix="uc1" TagName="dmt_upload_Form" %>

<script runat="server">
    protected string HTProgCap = HttpContext.Current.Request["prgname"];//功能名稱
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

    protected string submitTask = "";
    protected string json = "";
    protected string seq = "";
    protected string seq1 = "";
    protected string case_no = "";
    protected string in_scode = "";
    protected string in_no = "";
    protected string task = "";

    protected string se_grpid = "000", mSC_code = "", mSC_name = "", html_selectsign = "";
 
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
        case_no = ReqVal.TryGet("case_no");
        in_scode = ReqVal.TryGet("in_scode");
        in_no = ReqVal.TryGet("in_no");
        task = ReqVal.TryGet("task").Trim().ToLower();
        
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
        if (submitTask == "") submitTask = "A";
        if (prgid == "brt63") {
            HTProgCap = "國內案承辦<font color=blue>交辦發文</font>作業";
        } else if (prgid == "brta38") {
            HTProgCap = "國內案程序<font color=blue>官方發文</font>作業";
        }
        if (submitTask == "A") {
            if (ReqVal.TryGet("task") == "pr" || ReqVal.TryGet("task") == "prsave") {
                HTProgCap += "-<font color=blue>新增</font>";
            } else {
                HTProgCap += "-<font color=blue>不需發文</font>";
            }
        }
        if (submitTask == "U") HTProgCap += "-<font color=blue>確認</font>";
        if (submitTask == "Q") HTProgCap += "-<font color=blue>查詢</font>";
        if (submitTask == "D") HTProgCap += "-<font color=blue>刪除</font>";
        if (submitTask == "R") HTProgCap += "-<font color=blue>退回</font>";//20160901 增加[退回]功能(R)

        if ((submitTask == "U" || submitTask == "R") && prgid == "brta38") {//20160901 增加[退回]功能(R)
            Lock["PrLock"] = "Lock";
        }
        if (submitTask == "Q" || submitTask == "D" || submitTask == "R") {//20160901 增加[退回]功能(R)
            Lock["QLock"] = "Lock";
        }

        Lock["Lock38"] = Lock.TryGet("QLock");
        if (prgid == "brta38") {
            Lock["Lock38"] = "Lock";
        }

        StrFormBtnTop += "<a href=\"" + Page.ResolveUrl(Sys.getCase52Aspx("brt52", in_no, in_scode, "Edit")) + "\" target=\"Eblank\">[交辦維護作業]</a>\n";
        StrFormBtnTop += "<a class=\"imgCls\" href=\"javascript:void(0);\" >[關閉視窗]</a>\n";

        if ((HTProgRight & 4) > 0 || (HTProgRight & 8) > 0 || (HTProgRight & 16) > 0 || (HTProgRight & 64) > 0 || (HTProgRight & 128) > 0) {
            if (((HTProgRight & 8) > 0 && submitTask == "R") || ((HTProgRight & 64) > 0 && submitTask == "R")) {
                StrFormBtn += "<input type=button id='button1' value ='退　回' class='redbutton' onClick='formRejectSubmit()'>\n";
            }
            if (((HTProgRight & 4) > 0 && submitTask == "A") || ((HTProgRight & 8) > 0 && submitTask == "U") || ((HTProgRight & 64) > 0 && submitTask == "U")) {
                //20161212官發確認時增加電子申請書word檢查
                if (prgid == "brta38") {
                    StrFormBtn += "<input type=button id='button0' value='電子申請附件檢查' class='c1button' onClick='chkAttach()'>\n";
                }
                if (task == "pr") {
                    StrFormBtn += "<input type=button id='button1' value='交辦發文' class='cbutton bsubmit' onclick='formAddSubmit()'>\n";
                } else if (task == "prsave") {
                    StrFormBtn += "<input type=button id='button1' value='發文存檔' class='cbutton bsubmit' onclick='formAddSubmit()'>\n";
                } else if (task == "cancel") {
                    StrFormBtn += "<input type=button id='button1'value='不需發文' class='redbutton bsubmit' onclick='formAddSubmit()'>\n";
                } else {
                    StrFormBtn += "<input type=button id='button1' value='確　認' class='cbutton bsubmit' onclick='formAddSubmit()'>\n";
                }
            }
            StrFormBtn += "<input type=button value='重　填' class='cbutton' onclick='this_init()'>\n";
        }
        
        //正常簽核
        Sys.getGrpidMaster(Sys.GetSession("SeBranch"), ref se_grpid, ref mSC_code, ref mSC_name);
        //特殊簽核
        DataRow[] drx = Sys.getGrpidUp("N", "000").Select("grplevel=1");
        html_selectsign = drx.Option("{master_scode}", "{master_type}---{master_nm}", false);
    }

    //將共用參數傳給子控制項
    private void ChildBind() {
        Brta21form.Lock = new Dictionary<string, string>(Lock);
        Brta311form.Lock = new Dictionary<string, string>(Lock);
        Brta311form.HTProgRight = HTProgRight;
    }

    private void QueryData() {
        //預設值
        Dictionary<string, string> add_gs = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
        //交辦檔
        DataTable dtCaseMain = Sys.GetCaseDmtMain(conn, in_no);
        //案件主檔
        DataTable dtDmt = Sys.GetDmt(conn, seq, seq1);
        //交辦對應客收進度
        DataTable dtStepDmtCR = Sys.GetStepDmt(conn, seq, seq1, Request["case_no"]);
        //交辦官發檔
        DataTable dtAttCase = Sys.GetAttCaseDmt(conn, "", in_no);
        //檢查array.account.plus_temp.chk_type='Y'表會計已確認，只要有一筆 ="Y"就要有警語
        add_gs["chk_type"] = "";
        add_gs["chk_typestr"] = "";
        //if (dtAttCase.Rows.Count > 0) {
        //    using (DBHelper conni = new DBHelper(Conn.account).Debug(Request["chkTest"] == "TEST")) {
        //        SQL = "select case_no from plus_temp where branch='" + Session["seBranch"] + "' and dept='" + Session["dept"] + "'";
        //        SQL += " and rs_no='" + dtAttCase.Rows[0]["rs_no"] + "' and chk_type='Y'";
        //        using (SqlDataReader dr = conni.ExecuteReader(SQL)) {
        //            if (dr.HasRows) {
        //                add_gs["chk_type"] = "Y";
        //                while (dr.Read()) {
        //                    add_gs["chk_typestr"] += "," + dr.SafeRead("case_no", "");
        //                }
        //                add_gs["chk_typestr"] = "(會計已確認:" + add_gs["chk_typestr"].Substring(1) + ")";
        //            }
        //        }
        //    }
        //}
            
        //附件檔
        string where = "";
        if (ReqVal.TryGet("step_grade") != "") where += " and step_grade=" + ReqVal["step_grade"];
        if (ReqVal.TryGet("attach_sqlno") != "") where += " and attach_sqlno=" + ReqVal["attach_sqlno"];
        if (ReqVal.TryGet("att_sqlno") != "") where += " and att_sqlno=" + ReqVal["att_sqlno"];
        DataTable dtCaseAttach = Sys.GetDmtAttach(conn, seq, seq1, "cgrs", where);
        
        add_gs["cgrs"] = ReqVal.TryGet("cgrs");
        add_gs["fees"] = "0";
        add_gs["fees_stat"] = "N";
        //2011/2/18依2010/12/15李協理Email需求，結構分類：C4_行政訴訟預設發文對象為Q_智慧財產法院
        if (dtDmt.Rows[0].SafeRead("now_rsclass", "") == "C4") {
            add_gs["send_cl"] = "Q";
        } else {
            add_gs["send_cl"] = "1";
        }
        //add_gs["send_cl"] = "1";
        add_gs["send_cl1"] = "";
        add_gs["send_sel"] = "";
        add_gs["rs_type"] = dtCaseMain.Rows[0].SafeRead("arcase_type", "");
        add_gs["rs_class"] = dtCaseMain.Rows[0].SafeRead("ar_form", "");
        add_gs["rs_code"] = dtCaseMain.Rows[0].SafeRead("arcase", "");
        add_gs["contract_flag"] = dtCaseMain.Rows[0].SafeRead("contract_flag", "");
        add_gs["receipt_type"] = dtCaseMain.Rows[0].SafeRead("receipt_type", "");
        add_gs["receipt_title"] = dtCaseMain.Rows[0].SafeRead("receipt_title", "");
        add_gs["rectitle_name"] = dtCaseMain.Rows[0].SafeRead("rectitle_name", "");
        add_gs["send_way"] = dtCaseMain.Rows[0].SafeRead("send_way", "");

        //抓取客收進度for文件上傳&發文方式
        add_gs["case_step_grade"] = "";
        if(dtStepDmtCR.Rows.Count>0){
            add_gs["case_step_grade"]= dtStepDmtCR.Rows[0].SafeRead("case_step_grade", "");
            add_gs["send_way"]= dtStepDmtCR.Rows[0].SafeRead("send_way", "");
        }
		//若為電子送件,預設收據種類為電子收據
		if (add_gs["receipt_type"]==""){
			if (add_gs["send_way"]=="E")
				add_gs["receipt_type"]="E";
			else
				add_gs["receipt_type"]="P";
        }
		//若為電子送件,設定預設值
        if (add_gs["receipt_title"] == "") {
            if (add_gs["send_way"] == "E")
                add_gs["receipt_title"] = Sys.getDefaultTitle();
            else
                add_gs["receipt_title"] = "B";
        }
        add_gs["step_date"] = DateTime.Today.ToShortDateString();
        //總收發文日期
        //台北所總收發當天就會發文
        add_gs["mp_date"] = DateTime.Today.ToShortDateString();
        if (Sys.GetSession("seBranch") != "N") {
            switch (DateTime.Today.DayOfWeek) {
                case DayOfWeek.Friday: add_gs["mp_date"] = DateTime.Today.AddDays(3).ToShortDateString(); break;//星期五加三天
                case DayOfWeek.Saturday: add_gs["mp_date"] = DateTime.Today.AddDays(2).ToShortDateString(); break;//星期六加兩天
                default: add_gs["mp_date"] = DateTime.Today.AddDays(1).ToShortDateString(); break;//加一天
            }
        }

        //電子送件之總發文日皆為區所發文日，即當天
		if (add_gs["send_way"]=="E"){
            add_gs["mp_date"] = DateTime.Today.ToShortDateString();
        }

        var settings = new JsonSerializerSettings()
        {
            Formatting = Formatting.Indented,
            ContractResolver = new LowercaseContractResolver(),//key統一轉小寫
            Converters = new List<JsonConverter> { new DBNullCreationConverter(), new TrimCreationConverter() }//dbnull轉空字串且trim掉
        };
        Response.Write("{");
        Response.Write("\"request\":" + JsonConvert.SerializeObject(ReqVal, settings).ToUnicode() + "\n");
        Response.Write(",\"case_main\":" + JsonConvert.SerializeObject(dtCaseMain, settings).ToUnicode() + "\n");
        Response.Write(",\"dmt\":" + JsonConvert.SerializeObject(dtDmt, settings).ToUnicode() + "\n");//案件主檔
        Response.Write(",\"step_dmt_cr\":" + JsonConvert.SerializeObject(dtStepDmtCR, settings).ToUnicode() + "\n");//交辦對應客收進度
        Response.Write(",\"attcase_dmt\":" + JsonConvert.SerializeObject(dtAttCase, settings).ToUnicode() + "\n");//交辦官發檔
        Response.Write(",\"add_gs\":" + JsonConvert.SerializeObject(add_gs, settings).ToUnicode() + "\n");//交辦官發預設值
        Response.Write(",\"case_attach\":" + JsonConvert.SerializeObject(dtCaseAttach, settings).ToUnicode() + "\n");//附件檔
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
    main.task = "<%#ReqVal.TryGet("task")%>";
    jMain={};
</script>

<body>
<table cellspacing="1" cellpadding="0" width="98%" border="0">
    <tr>
        <td class="text9" nowrap="nowrap">&nbsp;【<%=HTProgCode%><%=HTProgCap%>】
		<img src="<%=Page.ResolveUrl("~/images/icon1.gif")%>" style="cursor:pointer" align="absmiddle" title="期限管制" WIDTH="20" HEIGHT="20" onclick="dmt_IMG_Click(1)">&nbsp;&nbsp;
		<img src="<%=Page.ResolveUrl("~/images/icon2.gif")%>" style="cursor:pointer" align="absmiddle" title="收發進度" WIDTH="25" HEIGHT="20" onclick="dmt_IMG_Click(2)">&nbsp;&nbsp;
		<img src="<%=Page.ResolveUrl("~/images/icon4.gif")%>" style="cursor:pointer" align="absmiddle" title="交辦內容" WIDTH="18" HEIGHT="18" onclick="dmt_IMG_Click(4)">&nbsp;&nbsp;
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
    <INPUT TYPE="text" id="submittask" name=submittask value="<%=submitTask%>">
    <INPUT TYPE="text" id="prgid" name="prgid" value="<%=prgid%>">
    <INPUT TYPE="text" id="prgid1" name="prgid1" value="<%=Request["prgid1"]%>">
    <INPUT TYPE="text" id="todo_sqlno" name="todo_sqlno" value="<%=Request["todo_sqlno"]%>"><!--承辦交辦發文或程序官發確認todo_dmt.sqlno-->
    <INPUT TYPE="text" id="in_scode" name="in_scode" value="<%=in_scode%>"><!--對應交辦case_dmt.in_scode-->
    <INPUT TYPE="text" id="in_no" name="in_no" value="<%=in_no%>"><!--對應交辦case_dmt.in_no-->
    <INPUT TYPE="text" id="case_no" name="case_no" value="<%=case_no%>"><!--對應交辦case_dmt.case_no-->
    <INPUT TYPE="text" id="att_sqlno" name="att_sqlno" value="<%=Request["att_sqlno"]%>"><!--對應交辦發文attcase_dmt.att_sqlno-->
    <INPUT TYPE="text" id="ctrl_flg" name="ctrl_flg" value="N"><!--判斷有無預設期限管制 N:無,Y:有-->
    <INPUT TYPE="text" id="havectrl" name="havectrl" value="N"><!--判斷有預設期限管制，需至少輸入一筆資料 N:無,Y:有-->
    <INPUT TYPE="text" id="task" name="task" value="<%=Request["task"]%>"><!--prsave:承辦發文維護,pr:承辦自行發文,cancel:不需發文,conf:確認-->
    <input type="text" id="edoc_type" name="edoc_type"><!--判斷要檢查的電子送件文件種類xx,改用申請書檢核-->
    <input type="text" id="report_name" name="report_name"><!--案性對應申請書名稱xx,改用上傳檔名-->
    <input type="text" id="contract_flag" name="contract_flag"><!--契約書後補註記N:無或已後補,Y:有-->

    <uc1:Brta21form runat="server" id="Brta21form" /><!--案件主檔欄位畫面，與收文共同-->
    <uc1:brta311form runat="server" ID="Brta311form" /><!--官發欄位畫面-->
    <%if (prgid=="brta38"){%>
        <uc1:Brta212form runat="server" ID="Brta212form" /><!--管制欄位畫面，與收文共同-->
    <%}%>
    <%if (prgid=="brta38"||(prgid=="brt63"&&(Request["task"]=="pr"||Request["task"]=="prsave"))||prgid=="brt36"){%>
        <uc1:dmt_upload_Form runat="server" ID="dmt_upload_Form" /><!--文件上傳畫面-->
    <%}%>
    <br />
    <input type="hidden" name="rsqlno" id="rsqlno">
    <table id=tabpr border=0 class="bluetable"  cellspacing=1 cellpadding=2 width="100%" >
	    <TR>
		    <TD align=center colspan=2 class=lightbluetable1><font color=white>承&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;辦&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;處&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;理&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;說&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;明</font></TD>
	    </TR>
	    <tr>
		    <td class="lightbluetable" align="right">承辦處理說明/<font color=red>不需發文說明</font>：</td>
		    <td class="whitetablebg" align="left">
			    <textarea name="job_remark" id="job_remark" rows="5" cols="70" class="<%#Lock.TryGet("PrLock")%>"></textarea>
		    </td>
	    </tr>
	    <%if(submitTask=="R"){%>
	        <TR>
		        <TD align=center colspan=2 class=lightbluetable1><font color=white>程&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;序&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;退&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;回&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;說&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;明</font></TD>
	        </TR>
	        <tr>
		        <td class="lightbluetable" align="right"><font color=red>程序退回說明</font>：</td>
		        <td class="whitetablebg" align="left">
			        <textarea name="approve_desc" id="approve_desc" rows="5" cols="70"></textarea>
		        </td>
	        </tr>
	    <%}%>
	    <tr id="tr_respdate" style="display:none">
		    <td class="lightbluetable" align="right">期限銷管：</td>
		    <td class="whitetablebg" align="left">	
			    <input type=button class="c1button" name="btnresp" id="btnresp" value ="進度查詢及銷管制">
		    </td>
	    </tr>
    </table>

    <div id="div_sign" style="display:none">
        <br>
        <table id="tabsign"border="0" width="70%" cellspacing="1" cellpadding="0" align="center" style="font-size: 9pt">
	        <TR>
		        <td width="14%"><input type=radio name="usesign" id="usesign1" onclick="toselect()" checked><strong>正常簽核:</strong></td>
		        <td><strong>上級主管:</strong><%=mSC_name%><input type=hidden name=Msign id=Msign value="<%=mSC_code%>"></td>
		        <td style="display:none"><strong>管制日期:</strong>
		        <input type=text name="signdate" id="signdate" size=10 readonly class="dateField">
		        </td>
	        </TR>
	        <TR>
		        <td ><input type=radio name="usesign" id="usesign2"><strong>特殊處理:</strong></td>
		        <td ><input type=radio name=Osign onclick="$('#usesign2').prop('checked',true)" >
			        <select name=selectsign id=selectsign>
				        <option value="" style="color:blue">請選擇主管</option>
				        <%#html_selectsign%>
			        </select>
		        </td>
		        <td><input type=radio name=Osign disabled onclick="$('#usesign2').prop('checked',true)">
		        <input type=text name=Nsign id=Nsign size=10 readonly>(薪號)
		        </td>
	        </TR>
        </table>
        <input type=hidden id="GrpID" name="GrpID" value="<%=se_grpid%>">
        <input type=hidden id=signid name=signid>
    </div>

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
            url: "brt63_edit.aspx?json=Y&<%#Request.QueryString%>",
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
        brta311form.init();
        if (typeof upload_form !== "undefined") upload_form.init();
        //-----------------
        $("input.dateField").datepick();
        main.bind();//資料綁定
        $(".Lock").lock();
        $(".Hide").hide();
    }
    
    main.bind = function () {
        if($("#submittask").val()=="A"){
            $("#cgrs").val(jMain.add_gs.cgrs).triggerHandler("change");
            $("#span_fseq").html(jMain.case_main[0].fseq);
            $("#oldseq,#grseq,#seq").val(jMain.dmt[0].seq);
            $("#oldseq1,#grseq1,#seq1").val(jMain.dmt[0].seq1);
            brta21form.btnseq();//[確定]
            $("#step_date").val(jMain.add_gs.step_date);
            $("#mp_date").val(jMain.add_gs.mp_date);
            $("#send_cl").val(jMain.add_gs.send_cl);
            $("#send_cl1").val(jMain.add_gs.send_cl1);
            $("#fees").val(jMain.add_gs.fees);
            $("#fees_stat").val(jMain.add_gs.fees_stat);
            $("#rs_type").val(jMain.add_gs.rs_type).triggerHandler("change");
            $("#case_arcase_class,#rs_class,#hrs_class").val(jMain.add_gs.rs_class);
            $("#rs_class").triggerHandler("change");
            $("#case_arcase,#rs_code,#hrs_code").val(jMain.add_gs.rs_code);
            $("#rs_code").triggerHandler("change");
            $("#send_way,#old_send_way").val(jMain.add_gs.send_way);
            $("#receipt_type").val(jMain.add_gs.receipt_type);
            $("#receipt_title").val(jMain.add_gs.receipt_title);
            $("#rectitle_name").val(jMain.add_gs.rectitle_name);

            brta311form.add_ar();
            $("#case_no_1").val(jMain.case_main[0].case_no);
            brta311form.getmoney(1);//依交辦單號抓取服務費、規費
            $("#remark").val(jMain.case_main[0].remark);
            $("#contract_flag").val(jMain.case_main[0].ncontract_flag);

            if(jMain.attcase_dmt.length>0) {
                $("#span_rs_no").html("發文序號："+jMain.attcase_dmt[0].rs_sqlno);
                $("#step_date").val(dateReviver(jMain.attcase_dmt[0].step_date,'yyyy/M/d'));
                $("#mp_date").val(dateReviver(jMain.attcase_dmt[0].mp_date,'yyyy/M/d'));
                $("#send_cl").val(jMain.attcase_dmt[0].send_cl);
                $("#send_cl1").val(jMain.attcase_dmt[0].send_cl1);
                $("#send_sel").val(jMain.attcase_dmt[0].send_sel);
                $("#pr_scode").val(jMain.attcase_dmt[0].pr_scode);
                $("#remark").val(jMain.attcase_dmt[0].remark);
                $("#act_code,#hact_code").val(jMain.attcase_dmt[0].act_code);
                $("#act_code").triggerHandler("change");
            }
            if((main.right&128)!=0||(main.right&256)!=0){
                $("input[name='rfees_stat'][value='"+jMain.add_gs.fees_stat+"']").prop("checked",true);
            }

            openread();	//控制特定欄位不能修改
            if(main.task=="pr"||main.task=="prsave"){
                upload_form.appendAttach(jMain.case_attach);//顯示上傳文件資料
            }else if(main.task=="cancel"){
                $("#tabgs").hide();//發文資料
                $("#tr_respdate").show();//期限銷管
            }
        }else{
            $("#remark").val(jMain.case_main[0].remark);
            $("#chk_typestr").html(jMain.add_gs.chk_typestr);
            if(jMain.attcase_dmt.length>0) {
                $("#span_rs_no").html("發文序號："+jMain.attcase_dmt[0].rs_sqlno);
                $("#act_code,#hact_code").val(jMain.attcase_dmt[0].act_code);
                $("#act_code").triggerHandler("change");
            }
        }

        if($("#submittask").val()=="U") {
            $("#span_rs_no").show();
        }
        if($("#submittask").val()!="Q"){
            if (jMain.case_main[0].ncontract_flag=="Y" && main.task=="pr"){
                $("#div_sign").show();
            }
        }
    }

    //存檔
    function formAddSubmit(){
        if($("#submittask").val()=="A"||$("#submittask").val()=="U"){
            //20161212增加word申請書附件檢查
            if (document.getElementById('task').value=="conf" && document.getElementById("send_way").value=="E"){
                //未檢查通過
                if (!document.getElementById('button0').disabled){
                    alert("請先執行電子申請附件檢查!!");
                    return false;
                }
            }
		
            if (document.getElementById('task').value==""){
                alert( "系統無法判斷存檔後的執行作業，請回系統首頁再重新進入本項作業，若仍無法處哩，請通知資訊部！");
                return false;
            }
            if (document.getElementById('task').value== "cancel"){	//不需發文
                if(chkNull("不需發文說明",document.getElementById('job_remark'))) return false;
                var ans = confirm("是否確定不需發文？");
                if (ans!=true){
                    return false;
                }
            }else{  //交辦發文 or發文確認
                if(document.getElementById('keyseq').value=="N"){
                    alert( "本所編號變動過，請按[確定]按鈕，重新抓取資料!!!");
                    return false;
                }
                if(chkNull("本所編號",document.getElementById('seq'))) return false;
                if(chkNull("本所編號副碼",document.getElementById('seq1'))) return false;
                if(chkNull("發文日期",document.getElementById('step_date'))) return false;
                if(chkNull("案性代碼",document.getElementById('rs_code'))) return false;
                if(chkNull("處理事項",document.getElementById('act_code'))) return false;
                if(chkNull("發文方式",document.getElementById('send_way'))) return false;//2012/12/12因應電子申請增加發文方式修改
                if (document.getElementById('send_way').value ==""){
                    alert("發文方式不可空白！");
                    return false;
                }
                if(document.getElementById('spe_ctrl').value == "E"){
                    if (document.getElementById('send_way').value !="E"){
                        alert("電子申請案性之發文方式必須為電子送件，請檢查！");
                        return false;
                    }
                }else if(document.getElementById('spe_ctrl_4').value != ""){
                    if (document.getElementById('spe_ctrl_4').value.indexOf(document.getElementById('send_way').value)==-1){
                        alert("此案性發文方式不可選擇["+$("#send_way option:selected" ).text()+"]，請檢查！\n若需修改，則請通知程序至國內案客戶收文作業修改後再發文。");
                        return false;
                    }
                    if (document.getElementById('send_way').value!=document.getElementById('old_send_way').value){
                        alert("若需修改發文方式，請通知程序至國內案客戶收文作業修改後再發文。");
                        return false;
                    }
                }else{
                    if (document.getElementById('send_way').value!="M"||document.getElementById('send_way').value!=document.getElementById('old_send_way').value){
                        alert("非電子申請案性之發文方式應為親送，若確定要修改發文方式，則請通知程序至國內案客戶收文作業修改後再發文！");
                        return false;
                    }
                }
                //20180525增加檢查發文日期/總發文日期不可小於系統日
                var sdate = CDate($('#step_date').val());
                var mdate = CDate($('#mp_date').val());
                if(sdate.getTime()< Today().getTime() || mdate.getTime()<Today().getTime()){
                    alert("發文日期或總發文日期不可小於系統日！");
                    return false;
                }


                //交辦發文檢查
                if (document.getElementById('task').value=="pr"){
                    //20161226 增加檢查非pdf檔不可勾選電子送件
                    //20161227 增加檢查須上傳電子申請書word檔
                    if (document.getElementById("send_way").value=="E"){
                        var fldname=reg.uploadfield.value;
                        var filenum=document.getElementById(fldname+"_filenum").value;
                        var hasWord=false;
                        for (p = 1; p <= filenum; p++) { 
                            var filename=document.getElementById(fldname+"_name_" + p).value.toLowerCase();
                            if (document.getElementById("doc_flag_" + p).checked==true) {
                                if (filename.substr(filename.length-4)!=".pdf"){
                                    alert("(文件"+p+")檔案類型為 "+filename.substr(filename.length-4)+" 不可勾選電子送件文件檔!");
                                    return false;
                                }
                            }else{
                                var names = filename.split(".");
                                if ((names[names.length-1]=="doc"||names[names.length-1]=="docx") && document.getElementById(fldname+"_desc_" + p).value.indexOf("申請書")>-1){
                                    hasWord=true;
                                }
                            }
                        }
                        if (!hasWord){
                            alert("請上傳電子申請書word檔，且檔案說明須含有「申請書」字樣!");
                            return false;
                        }
                    }
                    //若契約書尚未後補完成，則需轉區所主管簽核
                    if (document.getElementById('contract_flag').value=="Y"){
                        if (document.getElementsByName("usesign")[0].checked){
                            document.getElementById('signid').value = document.getElementById('Msign').value;
                        }else{
                            if (document.getElementsByName("Osign")[0].checked){
                                if (document.getElementById('selectsign').value == ""){
                                    alert("請選擇主管");
                                    document.getElementById('selectsign').focus();
                                    return false;
                                }
                                document.getElementById('signid').value = document.getElementById('selectsign').value;
                            }else{
                                if (document.getElementById('Nsign').value == ""){
                                    alert("薪號欄位不得為空白");
                                    document.getElementById('Nsign').focus();
                                    return false;
                                }
                                document.getElementById('signid').value = document.getElementById('Nsign').value;
                            }
                        }
                        if (document.getElementById('signid').value==""){
                            alert("本筆交辦為契約書後補，需經主管簽核，請選擇主管！");
                            return false;
                        }
                    }
                }
			
                //發文確認檢查
                if (document.getElementById('task').value=="conf"){
                    if (document.getElementById("send_way").value=="E"){
                        var fldname=reg.uploadfield.value;
                        var filenum=document.getElementById(fldname+"_filenum").value;
                        if (filenum=="0"){
                            alert("電子申請案性必須上傳電子送件文件，請上傳！");
                            return false;
                        }
                        var efilenum=0;	//電子送件文件
                        for (p = 1; p <= filenum; p++) { 
                            if (document.getElementById("doc_flag_" + p).checked==true) {
                                var filename=document.getElementById(fldname+"_name_" + p).value.toLowerCase();
                                if (filename.substr(filename.length-4)!=".pdf"){
                                    alert("勾選電子送件文件檔之附件，副檔名須為.pdf！(檔案"+p+")");
                                    return false;
                                }
                                efilenum += 1;
                            }
                        }
                        if (efilenum==0){
                            alert("上傳文件皆無電子送件文件檔，請檢查！");
                            return false;
                        }
                        //電子送件文件種類檢查(xx改用申請書檢核)
                        //if (document.getElementById("edoc_type").value!=""){
                        //    var edoc_type=document.getElementById("edoc_type").value.split(",");
                        //
                        //    for(j = 0; j < edoc_type.length; j++)
                        //    {
                        //        var ctype_flag=false;
                        //        for(p = 1; p <= filenum; p++)
                        //        {
                        //            if (document.getElementById("doc_flag_" + p).checked==true) {
                        //                if (edoc_type[j]==document.getElementById("doc_type_"+p).value){
                        //                    ctype_flag=true;
                        //                    break;
                        //                }
                        //            }
                        //        }
                        //        if (ctype_flag==false){
                        //            edoc_name=getdocname(edoc_type[j]);
                        //            alert("電子送件文件檔未上傳「" + edoc_name + "」或檔案種類未選擇「" + edoc_name + "」或未勾選「電子送件文件檔」，請檢查！");
                        //            return false;
                        //        }
                        //    }
                        //}
                    }
                    //非電子送件不可選擇電子收據
                    if (document.getElementById("send_way").value!="E"&&document.getElementById("send_way").value!="EA"){
                        if (document.getElementById("receipt_type").value=="E"){
                            alert("非電子送件不可選擇電子收據");
                            return false;
                        }
                    }
                }
                if (document.getElementById("cgrs").value=="GS"){
                    if(chkNull("發文對象",document.getElementById('send_cl'))) return false;
                    //if reg.rs_class.value<>"A1" and reg.rs_class.value<>"A0" then
                    if ($("#rs_class option:selected").attr("vref_code")!="A"){	//2012/12/24因應電子申請修改(不是新申請案要選擇官方號碼)
                        if(chkNull("官方號碼",document.getElementById('send_sel'))) return false;
                    }
                    if(chkNull("承辦",document.getElementById('pr_scode'))) return false;
				
                    if ((main.right & 128) != 0 || (main.right & 256) != 0) {
                        if($("input[name='rfees_stat']:checked").length==0){
                            alert("收費管制必須點選!!!");
                            return false;
                        }
                    }

                    //2006/6/13配合爭救案系統提醒發文方式
                    if (document.getElementById("hmarkb").value == "L"){
                        if (document.getElementsByName("opt_branch")[0].checked==true){
                            if (confirm("發文爭救案性確定自行發文，不需轉法律處發文？")!=true){
                                document.getElementsByName("opt_branch")[1].focus();
                                return false;
                            }
                        }
                    }
                    //不可同一筆官發重覆輸入同一case_no
                    for (j = 1; j <= document.getElementById('arnum').value; j++) {
                        var tcase_no1=$.trim(document.getElementById('case_no_'+j).value);
                        if (tcase_no1!=""){
                            for (k=1; k<= document.getElementById('arnum').value; k++) {
                                var tcase_no2=$.trim(document.getElementById('case_no_'+k).value);
                                if (tcase_no2!=""){
                                    if (j!=k){
                                        if (tcase_no1==tcase_no2){
                                            alert("同一筆官發不可重覆輸入同一筆交辦單號!!!");
                                            document.getElementById("case_no_"+j).focus();
                                            return false;
                                        }
                                    }
                                }
                            }
                        }
                        //若無交辦單號，本次支出大於0，不可存檔
                        var tgs_fees=document.getElementById('gs_fees_'+j).value;
                        if (tgs_fees!=""){
                            if (parseInt(tgs_fees,10)>0 && tcase_no1==""){
                                alert("若無交辦單號，本次支出不可大於零!!!");
                                document.getElementById("gs_fees_"+j).value=0;
                                return false;
                            }
                        }
                        //2008/1/14聖島四合一，檢查對應之交辦單之出名代理人要相同
                        if (j==1){
                            var tmp_agt_no=document.getElementById("case_agt_no_" + j).value;
                            //檢查交辦與發文出名代理人不一樣，顯示提示訊息
                            if (tmp_agt_no != ""){
                                if ($.trim(tmp_agt_no)!=$.trim(document.getElementById("rs_agt_no").value)){
                                    var answer=confirm("該交辦案件之出名代理人與發文出名代理人不同，是否確定要發文？(如需修改出名代理人請至交辦維護作業)");
                                    if (answer !=true){
                                        return false;
                                    }
                                }
                            }
                        }else{
                            var cur_agt_no=document.getElementById('case_agt_no_' + j).value;
                            if ($.trim(tmp_agt_no)!=$.trim(document.getElementById("mcur_agt_no"))){
                                alert("同一筆官發所對應交辦之出名代理人必須相同！");
                                return false;
                            }
                        }
                    }
				
                    brta311form.countfees();
                    if((main.right&128)!=0||(main.right&256)!=0){
                        if(document.getElementsByName("rfees_stat")[0].checked==true){//已交辦
                            if (CInt(document.getElementById("fees").value)!=CInt(document.getElementById("tot_fees").value)){
                                alert("交辦單本次規費支出合計("+CInt(document.getElementById("tot_fees").value)+")需等於官發規費支出("+CInt(document.getElementById("fees").value)+")!!!\n\n若交辦單本次規費支出合計須等於官發規費支出，請按確定!!!");
                                return false;
                            }
                        }
                    }else{
                        if (CInt(document.getElementById("fees").value)!=CInt(document.getElementById("tot_fees").value)){
                            alert("交辦單本次規費支出合計("+CInt(document.getElementById("tot_fees").value)+")需等於官發規費支出("+CInt(document.getElementById("fees").value)+")!!!\n\n若交辦單本次規費支出合計須等於官發規費支出，請按確定!!!");
                            return false;
                        }
                    }
                    //官發出名代理人依交辦案件為主
                    if (document.getElementById("arnum").value > 0){
                        if ($.trim(document.getElementById("case_agt_no_1").value) != "") {
                            document.getElementById("rs_agt_no").value=document.getElementById("case_agt_no_1").value;
                        }
                    }
                }
			
                //註冊費繳納期數與發文案性關聯性檢查
                switch (document.getElementById("rs_code").value) {
                    case "FF1":
                        document.getElementById("pay_date").value = document.getElementById("step_date").value;
                        if ($.trim(document.getElementById("pay_times").value) != "1") {
                            var ans = confirm("註冊費已繳期數與發文案性不符, 是否將註冊費已繳期數更正為『 第一期 』?");
                            if (ans != true) {
                                document.getElementById("rs_code").focus();
                                return false;
                            }else{
                                document.getElementById("pay_times").value = "1";
                                document.getElementById("hpay_times").value = "1";
                                document.getElementById("pay_date").value = document.getElementById("step_date").value;
                            }
                        }
                        break;
                    case "FF2":
                        document.getElementById("pay_date").value = document.getElementById("step_date").value;
                        if ($.trim(document.getElementById("pay_times").value) != "2") {
                            var ans = confirm("註冊費已繳期數與發文案性不符, 是否將註冊費已繳期數更正為『 第二期 』?");
                            if (ans != true) {
                                document.getElementById("rs_code").focus();
                                return false;
                            }else{
                                document.getElementById("pay_times").value = "2";
                                document.getElementById("hpay_times").value = "2";
                                document.getElementById("pay_date").value = document.getElementById("step_date").value;
                            }
                        }
                        break;
                    case "FF3":
                        document.getElementById("pay_date").value = document.getElementById("step_date").value;
                        if ($.trim(document.getElementById("pay_times").value) != "2") {
                            var ans = confirm("註冊費已繳期數與發文案性不符, 是否將註冊費已繳期數更正為『 第二期 』?");
                            if (ans != true) {
                                document.getElementById("rs_code").focus();
                                return false;
                            }else{
                                document.getElementById("pay_times").value = "2";
                                document.getElementById("hpay_times").value = "2";
                                document.getElementById("pay_date").value = document.getElementById("step_date").value;
                            }
                        }
                        break;
                    case "FF0":
                        document.getElementById("pay_date").value = document.getElementById("step_date").value;
                        if ($.trim(document.getElementById("pay_times").value) != "A") {
                            var ans = confirm("註冊費已繳期數與發文案性不符, 是否將註冊費已繳期數更正為『 全期 』?");
                            if (ans != true) {
                                document.getElementById("rs_code").focus();
                                return false;
                            }else{
                                document.getElementById("pay_times").value = "A";
                                document.getElementById("hpay_times").value = "A";
                                document.getElementById("pay_date").value = document.getElementById("step_date").value;
                            }
                        }
                        break;
                }
			
                if(document.getElementById("rs_code").value == "FC11" || document.getElementById("rs_code").value == "FC21" 
                || document.getElementById("rs_code").value == "FC5"  || document.getElementById("rs_code").value == "FC6" 
                || document.getElementById("rs_code").value == "FC7"  || document.getElementById("rs_code").value == "FC8" 
                || document.getElementById("rs_code").value == "FCH"  || document.getElementById("rs_code").value == "FCI"){
                    if (document.getElementById("tot_num").value == "0"){
                        alert("您所選的案性為一案多件, 但您發文件數僅一件, 請重新選取發文案性!!");
                        document.getElementById("rs_code").focus();
                        return false;
                    }
                }
                if (document.getElementById("rs_code").value.substr(0,2) == "FD"){
                    if (document.getElementById("tot_num").value == "0"){
                        alert("您所選的案性為分割, 但您分割案件件數為零, 請重新選取發文案性!!");
                        document.getElementById("rs_code").focus();
                        return false;
                    }
                }
                //變更案入檔時子本所編號檢查
                if(document.getElementById("rs_code").value == "FC11"  || document.getElementById("rs_code").value == "FC21" 
                || document.getElementById("hrs_code").value == "FC11" || document.getElementById("hrs_code").value == "FC21" 
                || document.getElementById("rs_code").value == "FC5"   || document.getElementById("rs_code").value == "FC6" 
                || document.getElementById("rs_code").value == "FC7"   || document.getElementById("rs_code").value == "FC8" 
                || document.getElementById("rs_code").value == "FCH"   || document.getElementById("rs_code").value == "FCI"){
                    // a.子本所編號確定是否都有按
                    // b.子本所編號不可重複 也不可與主要本所編號相同
                    var delcnt = 0;
                    for(i = 1; i < document.getElementById("tot_num").value; i++){
                        var dseq = $.trim(document.getElementById('dseq_'+i).value) + "" + $.trim(document.getElementById('dseq1A_'+i).value);
                        if (document.getElementById('dseqdel_'+i).value!="D"){
                            if (document.getElementById('keydseq_'+i).value != "Y"){
                                alert("共同變更之本所編號尚未確認, 請按確定按鈕!!");
                                document.getElementById('dseq_'+i).focus();
                                return false;
                            }
                            for(j = 1; j < document.getElementById("tot_num").value; j++){
                                if (i != j && document.getElementById('dseqdel_'+j).value != "D"){
                                    if ( $.trim(document.getElementById('dseq_'+i).value) == $.trim(document.getElementById('dseq_'+j).value)
                                    &&	$.trim(document.getElementById('dseq1A_'+i).value) == $.trim(document.getElementById('dseq1A_'+j).value) ){
                                        alert("共同變更之本所不可重覆, 請刪除重覆的資料!! 重覆之本所編號為 : " + dseq);
                                        document.getElementById('dseq_'+i).focus();
                                        return false;
                                    }
                                }
                            }
                            if ( $.trim(document.getElementById('dseq_'+i).value) == $.trim(document.getElementById('seq').value) 
                                && $.trim(document.getElementById('dseq1A_'+i).value) == $.trim(document.getElementById('seq1').value) ){
                                alert("共同變更之本所不可與主要本所編號相同!!");
                                document.getElementById('dseq_'+i).focus();
                                return false;
                            }
                        }else{
                            delcnt += 1;
                        }
                    }
                    if (document.getElementById('tot_num').value - delcnt > 49){
                        alert("總變更件數不可超過五十筆!!");
                        return false;
                    }
                }
                //分割案入檔時子本所編號檢查
                if (document.getElementById("rs_code").value.substr(0,2) == "FD"){
                    // 子本所編號不可重複 也不可與主要本所編號相同
                    var delcnt = 0;
                    for(i = 1; i < document.getElementById("tot_num").value; i++){
                        var dseq = $.trim(document.getElementById('dseq_'+i).value) + "" + $.trim(document.getElementById('dseq1A_'+i).value);
                        if (document.getElementById('dseqdel_'+i).value!="D"){
                            for(j = 1; j < document.getElementById("tot_num").value; j++){
                                if (i != j && document.getElementById('dseqdel_'+j).value != "D"){
                                    if ( $.trim(document.getElementById('dseq_'+i).value) == $.trim(document.getElementById('dseq_'+j).value)
                                    &&	$.trim(document.getElementById('dseq1A_'+i).value) == $.trim(document.getElementById('dseq1A_'+j).value) ){
                                        alert("分割案之本所不可重覆, 請刪除重覆的資料!! 重覆之本所編號為 : " + dseq);
                                        document.getElementById('dseq_'+i).focus();
                                        return false;
                                    }
                                }
                            }
                            if ( $.trim(document.getElementById('dseq_'+i).value) == $.trim(document.getElementById('seq').value) 
                                && $.trim(document.getElementById('dseq1A_'+i).value) == $.trim(document.getElementById('seq1').value) ){
                                alert("分割案子案之本所不可與主要本所編號相同!!");
                                document.getElementById('dseq_'+i).focus();
                                return false;
                            }
                        }else{
                            delcnt += 1;
                        }
                    }
                    if (document.getElementById('tot_num').value - delcnt > 30){
                        alert("總變更件數不可超過三十筆!!");
                        return false;
                    }
                }
            }	//判斷task的end if
		
            $("#reg :input").attr("disabled",false);
		
            //***todo
            //if ($("#submittask").val()=="U" and chk_type="Y" then%>
            //alert("<=rs_no%>進度會計已確認，若有修改「發文日期」、「應繳規費」、「交辦單號」，\n請通知會計更正帳款資料，謝謝 !!!");
            //end if%>
            if (document.getElementById('task').value == "pr" //自行發文
            ||  document.getElementById('task').value == "cancel" //不需發文
            ||  document.getElementById('task').value == "prsave"){//發文維護
                $("#submittask").val("A");
                postForm(getRootPath() + "/brt6m/Brt63_Update.aspx");
            }else if (document.getElementById('task').value == "conf"){//官發確認
                //為入官發進度，修改submittask=A
                $("#submittask").val("A");
                postForm(getRootPath() + "/brtam/Brta31_Update.aspx");
            }
        }
    }

    function formRejectSubmit(){
        var ans = confirm("是否確定退回!!!");
        if (ans == true){
            if(chkNull("退回說明",document.getElementById('approve_desc'))) return false;
            $("#submittask").val("R");
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

    function openread(){
        $("#btnQuery").hide();
        $("#seq,#seq1,#rs_class,#rs_code").lock();
        
        if((main.right&128)!=0||(main.right&256)!=0){
            $("input[name='rfees_stat']").lock();
        }
        $("#arAdd_button,#arres_button").lock();

        if(CInt($("#arnum").val())>0){
            $("#btncase_no_1").hide();
            $("#case_no_1,#gs_fees_1").lock();
        }else{
            if(CInt($("#fees")>0)){
                $("#arAdd_button,#arres_button").unlock();
            }
        }
    }

    //for不需發文之銷管期限
    $("#btnresp").click(function() {
        //***todo
        window.open(getRootPath() + "/brtam/brta21disEdit.aspx?prgid=<%=prgid%>&branch=<%=Session["seBranch"]%>&seq="+$("#seq").val()+"&seq1="+$("#seq1").val()+"&qtype=N&rsqlno="+$("#rsqlno").val()+"&step_grade="+$("#nstep_grade").val()+"&submitTask=A","","width=780 height=490 top=10 left=10 toolbar=no, menubar=no, location=no, directories=no resizeable=no status=no scrollbars=yes");
    });

    function toselect() {
        $("input[name=Osign]").prop("checked",false);
    }

    //20161212 檢查電子送件word檔【附送書件】vs文件上傳附件是否相符
    function chkAttach(){
        if (document.getElementById('task').value!="conf" || document.getElementById("send_way").value!="E"){
            return false;
        }
	
        jQuery.support.cors = true;
        $.ajax({ 
            url: getRootPath() + "/brt6m/Brt63checkWord.aspx",
            type: 'GET', 
            dataType : "text",//回傳的格式為text
            data: { 
                uploadfield: $("#uploadfield").val(),
                seq: $('#seq').val() ,
                seq1: $('#seq1').val() ,
                branch: "<%=Session["seBranch"]%>" ,
                att_sqlno: $("#att_sqlno").val(),
                source: "cgrs",
                debug: "n",
                seed: Math.random()
            }, 
            beforeSend: function(xhr) { 
                $('#msg').html("檢查中..");
            }, 
            error: function(xhr) { 
                $('#msg').html("<Font align=left color='red' size=3>檢查【附送書件】發生未知錯誤，請聯繫資訊人員!!</font>");
                alert('檢查【附送書件】發生錯誤!!'); 
            },
            success: function(response) {
                eval(response);
            }
        }); 
    }
</script>
