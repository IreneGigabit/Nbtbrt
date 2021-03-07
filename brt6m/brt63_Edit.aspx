<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Data"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>
<%@ Register Src="~/commonForm/Brta21form.ascx" TagPrefix="uc1" TagName="Brta21form" %>


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
            if (ReqVal.TryGet("taks") == "pr" || ReqVal.TryGet("taks") == "prsave") {
                HTProgCap += "-<font color=blue>新增</font>";
            } else {
                HTProgCap += "-<font color=blue>不需發文</font>";
            }
        }
        if (submitTask == "U") HTProgCap += "-<font color=blue>確認</font>";
        if (submitTask == "Q") HTProgCap += "-<font color=blue>查詢</font>";
        if (submitTask == "D") HTProgCap += "-<font color=blue>刪除</font>";
        if (submitTask == "R") HTProgCap += "-<font color=blue>退回</font>";//20160901 增加[退回]功能(R)

    if ((submitTask == "U" || submitTask == "R")&&prgid=="brta38") {//20160901 增加[退回]功能(R)
        Lock["PrLock"] = "Lock";
    }
    if (submitTask == "Q" || submitTask == "D" || submitTask == "D") {//20160901 增加[退回]功能(R)
        Lock["QLock"] = "Lock";
    }
        
        
        StrFormBtnTop += "<a href=\"" + Page.ResolveUrl(Sys.getCase52Aspx("brt52", in_no, in_scode, "Edit")) + "\" target=\"Eblank\">[交辦維護作業]</a>\n";
        StrFormBtnTop += "<a class=\"imgCls\" href=\"javascript:void(0);\" >[關閉視窗]</a>\n";

        if ((HTProgRight & 4) > 0 || (HTProgRight & 8) > 0 || (HTProgRight & 16) > 0 || (HTProgRight & 64) > 0 || (HTProgRight & 128) > 0) {
            if (((HTProgRight & 4) > 0 && submitTask == "A") || ((HTProgRight & 8) > 0 && submitTask == "U") || ((HTProgRight & 64) > 0 && submitTask == "U")) {
                //20161212官發確認時增加電子申請書word檢查
                if (prgid == "brta38") {
                    StrFormBtn += "<input type=button value ='電子申請附件檢查' class='c1button' onClick='chkAttach()'>\n";
                }
                StrFormBtn += "<input type=button value ='確　認' class='cbutton bsubmit' onclick='formAddSubmit()'>\n";
            }
            if (((HTProgRight & 8) > 0 && submitTask == "R") || ((HTProgRight & 64) > 0 && submitTask == "R")) {
                StrFormBtn += "<input type=button id='button1' value ='退　回' class='redbutton' onClick='formRejectSubmit()'>\n";
            }
            StrFormBtn += "<input type=button value ='重　填' class='cbutton' onclick='this_init()'>\n";
        }

        //正常簽核
        Sys.getGrpidMaster(Sys.GetSession("SeBranch"), ref se_grpid, ref mSC_code, ref mSC_name);
        //特殊簽核
        DataRow[] drx = Sys.getGrpidUp("N", "000").Select("grplevel=1");
        html_selectsign = drx.Option("{master_scode}", "{master_type}---{master_nm}", false);
    }

    //將共用參數傳給子控制項
    private void ChildBind() {
        Brta21form.Lock = Lock;
    }

    private void QueryData() {
        //交辦檔
        DataTable dtCaseMain = Sys.GetCaseDmtMain(conn, in_no);
        //案件主檔
        DataTable dtDmt = Sys.GetDmt(conn, seq, seq1);
        //交辦官發檔
        DataTable dtAttCase = Sys.GetAttCaseDmt(conn, "", in_no);

        //預設值
        Dictionary<string, string> add_gs = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
            add_gs["fees"] = "0";
            add_gs["fees_stat"] = "N";
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
            add_gs["rs_class"] = dtCaseMain.Rows[0].SafeRead("arcase_class", "");
            add_gs["rs_code"] = dtCaseMain.Rows[0].SafeRead("arcase", "");

        
        var settings = new JsonSerializerSettings() {
            Formatting = Formatting.Indented,
            ContractResolver = new LowercaseContractResolver(),//key統一轉小寫
            Converters = new List<JsonConverter> { new DBNullCreationConverter(), new TrimCreationConverter() }//dbnull轉空字串且trim掉
        };
        Response.Write("{");
        Response.Write("\"case_main\":" + JsonConvert.SerializeObject(dtCaseMain, settings).ToUnicode() + "\n");
        Response.Write(",\"dmt\":" + JsonConvert.SerializeObject(dtDmt, settings).ToUnicode() + "\n");//案件主檔
        Response.Write(",\"attcase_dmt\":" + JsonConvert.SerializeObject(dtAttCase, settings).ToUnicode() + "\n");//對應交辦發文檔
        Response.Write(",\"add_gs\":" + JsonConvert.SerializeObject(add_gs, settings).ToUnicode() + "\n");//交辦官發預設值
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
    main.code = "<%#ReqVal.TryGet("code")%>";//todo.sqlno
    main.change = "<%#ReqVal.TryGet("change")%>";//異動簽核狀態
    jMain={};
</script>

<body>
<table cellspacing="1" cellpadding="0" width="98%" border="0">
    <tr>
        <td class="text9" nowrap="nowrap">&nbsp;【<%=HTProgCode%><%=HTProgCap%>】
		<img src="<%=Page.ResolveUrl("~/images/icon1.gif")%>" style="cursor:pointer" align="absmiddle" title="期限管制" WIDTH="20" HEIGHT="20" onclick="dmt_IMG_Click(1)">&nbsp;&nbsp;
		<img src="<%=Page.ResolveUrl("~/images/icon2.gif")%>" style="cursor:pointer" align="absmiddle" title="收發進度" WIDTH="25" HEIGHT="20" onclick="dmt_IMG_Click(2)">&nbsp;&nbsp;
		<img src="<%=Page.ResolveUrl("~/images/icon4.gif")%>" style="cursor:pointer" align="absmiddle" title="交辦內容" WIDTH="18" HEIGHT="18" onclick="dmt_IMG_Click(4)">&nbsp;&nbsp;
		案件編號：<span id="span_fseq"></span>&nbsp;&nbsp;<span id="span_rs_no">發文序號：</span>
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

    <div id="div_sign">
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
        //-----------------
        $("input.dateField").datepick();
        main.bind();//資料綁定
        $(".Lock").lock();
        $(".Hide").hide();
    }
    
    main.bind = function () {
        $("#span_fseq").html(jMain.case_main[0].fseq);
        $("#oldseq,#grseq,#seq").val(jMain.dmt[0].seq);
        $("#oldseq1,#grseq1,#seq1").val(jMain.dmt[0].seq1);
        brta21form.btnseq();//[確定]

        if($("#submittask").val()=="A"){
            $("#step_date").val(jMain.step_gs.step_date);
            $("#mp_date").val(jMain.step_gs.mp_date);
            $("#send_cl").val(jMain.step_gs.send_cl);
            $("#send_cl1").val(jMain.step_gs.send_cl1);
            $("#rs_type").val(jMain.step_gs.rs_type).triggerHandler("change");
            $("#case_arcase_class").val(jMain.step_gs.rs_class);
            $("#case_arcase").val(jMain.step_gs.rs_code);

            openread();	//控制特定欄位不能修改
        }else{

        }
        if(jMain.attcase_dmt.length>0) {
            $("#span_rs_no").html("發文序號："+jMain.attcase_dmt[0].rs_sqlno);
            $("#remark").val(jMain.case_main[0].remark);
        }
        $("#contract_flag").val(jMain.case_main[0].ncontract_flag);

        //brta21form
        //getcase_no_data1()//***todo

        /*
        $("#oldseq,#grseq,#seq").val(jMain.dmt[0].seq);
        $("#oldseq1,#grseq1,#seq1").val(jMain.dmt[0].seq1);
        $("#s_mark").val(jMain.dmt[0].s_mark);
        $("#cust_prod").val(jMain.dmt[0].cust_prod);
        $("#in_date").val(dateReviver(jMain.dmt[0].in_date,'yyyy/M/d'));
        $("#step_grade").val(jMain.dmt[0].step_grade);
        $("#appl_name").val(jMain.dmt[0].appl_name);
        $("#arcase").val(jMain.dmt[0].arcasenm);
        $("#att_sql").val(jMain.dmt[0].att_sql);
        $("#cust_area").val(jMain.dmt[0].cust_area);
        $("#cust_seq").val(jMain.dmt[0].cust_seq);
        $("#cust_name").val(jMain.dmt[0].cust_name);
        $("#class_count").val(jMain.dmt[0].class_count);
        $("#class1").val(jMain.dmt[0].class.CutData(10));
        $("#apcust_no").val(jMain.dmt[0].ap_apcust_no);
        $("#ap_cname").val(jMain.dmt[0].ap_cname);
        $("#dmtap_cname").val(jMain.dmt[0].dmtap_cname);
        $("#now_arcasenm").val(jMain.dmt[0].now_arcasenm);
        $("#agt_no").val(jMain.dmt[0].agt_no);
        $("#scode").val(jMain.dmt[0].scodenm);
        $("#case_stat").val(jMain.dmt[0].now_statnm);
        $("#apply_date").val(dateReviver(jMain.dmt[0].apply_date,'yyyy/M/d'));
        $("#apply_no").val(jMain.dmt[0].apply_no);
        var ar_ref=jMain.dmt[0].ref_no1.split("-");
        if(ar_ref.count>=1) $("#ref_no1").val(ar_ref[0]);
        if(ar_ref.count>=2) $("#ref_no11").val(ar_ref[1]);
        $("#issue_date").val(dateReviver(jMain.dmt[0].issue_date,'yyyy/M/d'));
        $("#issue_no").val(jMain.dmt[0].issue_no);
        $("#mseq").val(jMain.dmt[0].mseq);
        $("#mseq1").val(jMain.dmt[0].mseq1);
        $("#open_date").val(dateReviver(jMain.dmt[0].open_date,'yyyy/M/d'));
        $("#rej_no").val(jMain.dmt[0].rej_no);
        $("#end_date").val(dateReviver(jMain.dmt[0].end_date,'yyyy/M/d'));
        $("#end_code").val(jMain.dmt[0].end_code);
        $("#end_name").val(jMain.dmt[0].end_codenm);
        $("#end_remark").val(jMain.dmt[0].end_remark);
        $("#term1").val(dateReviver(jMain.dmt[0].term1,'yyyy/M/d'));
        $("#term2").val(dateReviver(jMain.dmt[0].term2,'yyyy/M/d'));
        $("#renewal").val(jMain.dmt[0].renewal);
        $("#opay_times,#hpay_times,#pay_times").val(jMain.dmt[0].pay_times);
        $("#opay_date,#pay_date").val(dateReviver(jMain.dmt[0].pay_date,'yyyy/M/d'));
        $("#tran_seq_branch").val(jMain.dmt[0].tran_seq_branch);
        $("#tran_seq").val(jMain.dmt[0].tran_seq);
        $("#tran_seq1").val(jMain.dmt[0].tran_seq1);
        $("#tran_remark").val(jMain.dmt[0].tran_remark);
        */
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

    function openread(){
        $("#btnQuery").hide();
        $("#seq,#seq1,#rs_class,#rs_code").lock();
        
        if((main.right&128)!=0||(main.right&256)!=0){
            $("input[name='rfees_stat']").unlock();
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
</script>

