﻿<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Data"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>
<%@ Register Src="~/commonForm/Brta21form.ascx" TagPrefix="uc1" TagName="Brta21form" %>
<%@ Register Src="~/commonForm/brta211form.ascx" TagPrefix="uc1" TagName="brta211form" %>
<%@ Register Src="~/commonForm/Brta212form.ascx" TagPrefix="uc1" TagName="Brta212form" %>

<script runat="server">
    protected string HTProgCap = HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = HttpContext.Current.Request["prgid"] ?? "";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";
    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";
    protected string FormName = "";
    
    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected Dictionary<string, string> Lock = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    protected Dictionary<string, string> Hide = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);

    protected string SQL = "";
    protected object objResult = null;

    protected string submitTask = "";
    protected string json = "";
    protected string seq = "";
    protected string seq1 = "";
    protected string cgrs = "";

    protected string emg_scode = "";
    protected string emg_agscode = "";

    DBHelper conn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    DBHelper cnn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    private void Page_Unload(System.Object sender, System.EventArgs e) {
        if (conn != null) conn.Dispose();
        if (cnn != null) cnn.Dispose();
    }

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;
        
        conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
        cnn = new DBHelper(Conn.Sysctrl).Debug(Request["chkTest"] == "TEST");
        
        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");
        submitTask = ReqVal.TryGet("submittask").ToUpper();
        
        json = (Request["json"] ?? "").Trim().ToUpper();
        seq = ReqVal.TryGet("seq");
        seq1 = ReqVal.TryGet("seq1");
        cgrs = ReqVal.TryGet("cgrs");
        
        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        HTProgCap = myToken.Title.Replace("官收", "<font color=blue>官方收文</font>");
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
        }

        if (submitTask == "A") HTProgCap += "-<font color=blue>新增</font>";
        if (submitTask == "U") HTProgCap += "-<font color=blue>修改</font>";
        if (submitTask == "Q") HTProgCap += "-<font color=blue>查詢</font>";
        if (submitTask == "D") HTProgCap += "-<font color=blue>刪除</font>";

        if (cgrs == "CR") StrFormBtnTop += "<a href=\"" + Page.ResolveUrl("~/brtam/brta4m.aspx") + "?prgid=brta4m&cgrs=" + cgrs + "\" target=\"Etop\">[列印]</a>\n";
        if (cgrs == "GR") StrFormBtnTop += "<a href=\"" + Page.ResolveUrl("~/brtam/brta41m.aspx") + "?prgid=brta41m&cgrs=" + cgrs + "\" target=\"Etop\">[列印]</a>\n";
        StrFormBtnTop += "<a class=\"imgCls\" href=\"javascript:void(0);\" >[關閉視窗]</a>\n";
        StrFormBtnTop += "<font style=\"cursor: pointer;color:darkblue\" onmouseover=\"this.style.color='red'\" onmouseout=\"this.style.color='darkblue'\" onclick=\"Help_Click()\">[說明]</font>\n";

        if (submitTask != "Q") {
            if ((HTProgRight & 4) > 0 || (HTProgRight & 8) > 0 || (HTProgRight & 16) > 0 || (HTProgRight & 64) > 0) {
                if (((HTProgRight & 4) > 0 && submitTask == "A") || ((HTProgRight & 8) > 0 && submitTask == "U") || ((HTProgRight & 64) > 0 && submitTask == "U")) {
                    StrFormBtn += "<input type=button id='button1' value='確　認' class='cbutton bsubmit' onClick='formAddSubmit()'>\n";
                    StrFormBtn += "<input type=button id='btnreject' value='退回總管處(收錯案件)' class='redbutton bsubmit' onClick='formReSubmit()'>\n";
                }
                if (((HTProgRight & 16) > 0 && submitTask == "D")) {
                    StrFormBtn += "<input type=button id='button1' value='刪　除' class='cbutton bsubmit' onClick='formDelSubmit()'>\n";
                }
                StrFormBtn += "<input type=button value='通知總收發修正資料' class='c1button bsubmit' onclick='tomgbutton_email()'>\n";
                StrFormBtn += "<input type=button value='重　填' class='cbutton' onclick='this_init()'>\n";
            }
        }

        emg_scode = Sys.getRoleScode(Sys.GetSession("seBranch"), Sys.GetSession("syscode"), Sys.GetSession("dept"), "mg_pror");//總管處程序人員-正本
        emg_agscode = Sys.getRoleScode(Sys.GetSession("seBranch"), Sys.GetSession("syscode"), Sys.GetSession("dept"), "mg_prorm");//總管處程序人員-副本
    }

    //將共用參數傳給子控制項
    private void ChildBind() {
        Brta21form.Lock = new Dictionary<string, string>(Lock);
        Brta211form.Lock = new Dictionary<string, string>(Lock);
        Brta212form.Lock = new Dictionary<string, string>(Lock);
    }

    private void QueryData() {
        Dictionary<string, string> add_gr = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase){
        {"smgt_temp_mark",""},{"from_flag",""},
        //Brta21form案件主檔
        {"new_seq",""}, {"branch",""},{"seq",""},{"seq1",""},{"fseq",""},
        //brta211form收文資料
        {"mg_step_grade",""},{"mg_rs_sqlno",""},{"rs_no",""},{"nstep_grade",""},{"cgrs",""},{"step_date",""},{"mp_date",""},
        {"send_cl",""},{"receive_no",""},{"receive_way",""},{"mg_rs_detail",""},{"pdfsource",""},{"rs_type",""},{"rs_class_name",""},
        {"rs_code_name",""},{"act_code_name",""},{"rs_class",""},{"rs_code",""},{"act_sqlno",""},{"act_code",""},
        {"ocase_stat",""},{"ncase_stat",""},{"ncase_statnm",""},{"rs_detail",""},{"doc_detail",""},
        {"pr_scan",""},{"pr_scan_page",""},{"pr_scan_remark",""},{"pr_scan_path",""},{"cs_flag",""},{"csd_flag",""},
        {"cs_rs_no",""},{"send_way",""},{"pr_scode",""},{"cs_remark_code",""},{"cs_remark",""},{"cs_detail",""},
        {"pmail_date",""},{"mail_date",""},{"mail_scode",""},{"mwork_date",""},{"mail_scname",""},{"print_date",""},
        //brta212管制資料
        {"ectrlnum",""}
        };

        //案件主檔
        DataTable dtDmt = Sys.GetDmt(conn, seq, seq1);
        if (dtDmt.Rows.Count > 0) add_gr["ectrlnum"] = dtDmt.Rows[0].SafeRead("ectrlnum","0");
        
        if (submitTask == "A") {
            add_gr["seq1"] = "_";
            add_gr["step_date"] = DateTime.Today.ToString("yyyy/M/d");
            switch (DateTime.Today.DayOfWeek) {
                case DayOfWeek.Saturday: add_gr["mp_date"] = DateTime.Today.AddDays(-1).ToShortDateString(); break;//星期六減一天
                case DayOfWeek.Sunday: add_gr["mp_date"] = DateTime.Today.AddDays(-2).ToShortDateString(); break;//星期日減二天
                case DayOfWeek.Monday: add_gr["mp_date"] = DateTime.Today.AddDays(-3).ToShortDateString(); break;//星期一減三天
                default: add_gr["mp_date"] = DateTime.Today.AddDays(-1).ToShortDateString(); break;//減一天
            }
            add_gr["send_cl"] = "1";
            add_gr["rs_type"] = Sys.getRsType();
        }

        if ((submitTask == "U" || submitTask == "Q" || submitTask == "D") || (submitTask == "A" && prgid == "brta24")) {
            SQL = "Select a.*,b.temp_rs_sqlno,b.mg_step_grade,b.mg_step_rs_sqlno,b.mg_step_date,b.send_cl,b.rs_type,b.rs_class,b.rs_code,b.act_code,b.rs_detail ";
            SQL += ",b.receive_no,b.receive_way,b.doc_detail,b.new_seq,b.from_flag,b.mark as smgt_temp_mark ";
            SQL += "From dmt a inner join step_mgt_temp b on a.seq=b.seq and a.seq1=b.seq1 ";
            SQL += " Where a.seq = '" + seq + "' and a.seq1='" + seq1 + "'";
            SQL += " and b.temp_rs_sqlno='" + Request["temp_rs_sqlno"] + "'";
            DataTable dtStepMgt = new DataTable();
            conn.DataTable(SQL, dtStepMgt);

            if (dtStepMgt.Rows.Count > 0) {
                DataRow dr = dtStepMgt.Rows[0];

                add_gr["new_seq"] = dr.SafeRead("new_seq", "");
                add_gr["branch"] = dr.SafeRead("cust_area", "");
                add_gr["seq"] = dr.SafeRead("seq", "");
                add_gr["seq1"] = dr.SafeRead("seq1", "");
                add_gr["fseq"] = Sys.formatSeq(add_gr["seq"], add_gr["seq1"], "", Sys.GetSession("seBranch"), Sys.GetSession("dept"));
                add_gr["nstep_grade"] = (dr.SafeRead("step_grade", 0) + 1).ToString();
                add_gr["cgrs"] = "GR";
                add_gr["step_date"] = DateTime.Today.ToString("yyyy/M/d");
                add_gr["mp_date"] = dr.GetDateTimeString("mg_step_date", "yyyy/M/d");
                add_gr["mg_step_grade"] = dr.SafeRead("mg_step_grade", "");
                add_gr["mg_rs_sqlno"] = dr.SafeRead("mg_step_rs_sqlno", "");
                add_gr["send_cl"] = dr.SafeRead("send_cl", "");
                add_gr["receive_no"] = dr.SafeRead("receive_no", "");
                add_gr["receive_way"] = dr.SafeRead("receive_way", "");
                add_gr["rs_type"] = Sys.getRsType();
                add_gr["from_flag"] = dr.SafeRead("from_flag", "");
                if (add_gr["from_flag"] == "C") {//電子收文預設代碼為申請商標延展通知
                    add_gr["rs_class"] = "A1";
                    add_gr["rs_code"] = "FA1";
                    add_gr["act_code"] = "P3";
                    add_gr["pr_scan"] = "N";//電子收文預設不要掃描
                } else {
                    add_gr["rs_class"] = dr.SafeRead("rs_class", "");
                    add_gr["rs_code"] = dr.SafeRead("rs_code", "");
                    if (dr.SafeRead("rs_code", "") == "AD8") {//2010/11/29因代碼不同，先不對應
                        add_gr["rs_code"] = "";
                    }
                    add_gr["act_code"] = dr.SafeRead("act_code", "");

                    if (add_gr["from_flag"] == "J") {
                        add_gr["pr_scan"] = "N";//2014/4/21電子公文預設不要掃描
                    } else {
                        add_gr["pr_scan"] = "Y";//預設要掃描
                        if (add_gr["receive_way"] == "RA") {
                            add_gr["pr_scan"] = "N";//2015/8/12來文方式Email預設不要掃描，for司法院Email通知
                        }
                    }
                }

                //取得結構分類、代碼、處理事項名稱
                SQL = "select code_name from cust_code where code_type='" + add_gr["rs_type"] + "' and cust_code='" + add_gr["rs_class"] + "'";
                objResult = conn.ExecuteScalar(SQL);
                add_gr["rs_class_name"] = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();
                SQL = "select rs_detail from code_br where rs_type='" + add_gr["rs_type"] + "' and rs_code='" + add_gr["rs_code"] + "' and gs='Y' ";
                objResult = conn.ExecuteScalar(SQL);
                add_gr["rs_code_name"] = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();
                SQL = "select code_name from cust_code where code_type='tact_code' and cust_code='" + add_gr["act_code"] + "'";
                objResult = conn.ExecuteScalar(SQL);
                add_gr["act_code_name"] = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();

                //取得案件狀態
                SQL = " select rs_type,rs_class,rs_code,act_code,case_stat,case_stat_name ";
                SQL += "from vcode_act ";
                SQL += "where rs_code = '" + add_gr["rs_code"] + "' and act_code = '" + add_gr["act_code"] + "' ";
                SQL += "and rs_type = '" + add_gr["rs_type"] + "'";
                SQL += "and cg = 'G' and rs = 'R'";
                using (SqlDataReader dr0 = conn.ExecuteReader(SQL)) {
                    if (dr0.Read()) {
                        add_gr["ocase_stat"] = dr0.SafeRead("case_stat", "");
                        add_gr["ncase_stat"] = dr0.SafeRead("case_stat", "");
                        add_gr["ncase_statnm"] = dr0.SafeRead("case_stat_name", "");
                    }
                }

                add_gr["mg_rs_detail"] = dr.SafeRead("rs_detail", "");
                add_gr["rs_detail"] = dr.SafeRead("rs_detail", "");
                add_gr["cs_detail"] = "";
                add_gr["doc_detail"] = dr.SafeRead("doc_detail", "");
                //預設發文方式為掛號
                add_gr["send_way"] = "2";
                //收檢發註冊證，先不比對註冊號，因總收發會等到公報轉入，所以先不校對
                add_gr["smgt_temp_mark"] = dr.SafeRead("smgt_temp_mark", "");

                //預設預定寄發日期為總收發文+7天
                if (add_gr["mp_date"] != "") {
                    add_gr["pmail_date"] = Util.str2Dateime(add_gr["mp_date"]).AddDays(7).ToShortDateString();
                }
            }

            add_gr["pdfsource"] = "GR";
            //2019/6/18修改，電子公文rsreive_way=R9其source=EGGR，其餘皆為GR，路徑只有電子公文會不同須判斷，其餘都直接連到總管處顯示
            if (add_gr["receive_way"] == "R9") {//R9_電子公文
                add_gr["pdfsource"] = "EGR";
            }
        }

        //2019/6/20因官收作業進入無案件編號  
        DataTable dtMGAttach = new DataTable();
        if (seq != "" && seq != "0") {
            SQL = "select attach_path,attach_name,source,''view_path from mgt_attach_temp where seq=" + seq + " and seq1='" + seq1 + "' and mg_step_rs_sqlno=" + add_gr["mg_rs_sqlno"] + " and source='" + add_gr["pdfsource"] + "' and attach_flag<>'D' order by attach_sqlno ";
            conn.DataTable(SQL, dtMGAttach);
            for (int i = 0; i < dtMGAttach.Rows.Count; i++) {
                DataRow dr = dtMGAttach.Rows[i];
                string attach_path = Sys.Path2Nbtbrt(dr.SafeRead("attach_path", ""));
                string viewserver = "http://" + Sys.Host;

                //若區所主機找不到就找總所主機
                if (Sys.CheckFile(attach_path) == false) {
                    viewserver = "http://" + Sys.MG_IIS;
                    if (add_gr["pdfsource"] == "EGR") {
                        attach_path = attach_path.Replace("/nbtbrt/", "/MG/");
                    }
                }
                dr["attach_path"] = attach_path;
                dr["view_path"] = viewserver + attach_path;
            }
        }

        //管制資料
        DataTable dtCtrl = new DataTable();
        if (prgid == "brta24" && add_gr["from_flag"] == "C") {//官收電子收文
            SQL = " select tctrl_sqlno as sqlno,ctrl_type,ctrl_remark,ctrl_date,null as resp_date,null as resp_grade ";
            SQL += " from ctrl_mgt_temp where temp_rs_sqlno=" + Request["temp_rs_sqlno"] + " and ctrl_type like 'A%' ";
            SQL += " union select null as sqlno,ctrl_type,ctrl_remark,ctrl_date,resp_date,mg_resp_step_grade as resp_grade ";
            SQL += " from resp_mgt_temp where temp_rs_sqlno=" + Request["temp_rs_sqlno"] + " and ctrl_type like 'A%' ";
        } else {
            SQL = " select sqlno,ctrl_type,ctrl_remark,ctrl_date,null as resp_date,null as resp_grade from ctrl_dmt ";
            SQL += " where rs_no='" + add_gr["rs_no"] + "'";
            SQL += " union select sqlno,ctrl_type,ctrl_remark,ctrl_date,resp_date,resp_grade from resp_dmt ";
            SQL += " where rs_no='" + add_gr["rs_no"] + "'";
            SQL += " order by ctrl_date";
        }
        conn.DataTable(SQL, dtCtrl);

        var settings = new JsonSerializerSettings()
        {
            Formatting = Formatting.Indented,
            ContractResolver = new LowercaseContractResolver(),//key統一轉小寫
            Converters = new List<JsonConverter> { new DBNullCreationConverter(), new TrimCreationConverter() }//dbnull轉空字串且trim掉
        };
        Response.Write("{");
        Response.Write("\"request\":" + JsonConvert.SerializeObject(ReqVal, settings).ToUnicode() + "\n");
        Response.Write(",\"add_gr\":" + JsonConvert.SerializeObject(add_gr, settings).ToUnicode() + "\n");//交辦官發預設值
        Response.Write(",\"mg_attach\":" + JsonConvert.SerializeObject(dtMGAttach, settings).ToUnicode() + "\n");//總管處官收文件
        Response.Write(",\"gr_ctrl\":" + JsonConvert.SerializeObject(dtCtrl, settings).ToUnicode() + "\n");//管制資料
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
		案件編號：<span id="span_fseq"></span>
        &nbsp;&nbsp;<span id="span_rs_no"></span>
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
    <INPUT TYPE="text" id="submittask" name=submittask value="<%=submitTask%>">
    <INPUT TYPE="text" id=ctrl_flg name=ctrl_flg value="N"><!--判斷有無預設期限管制 N:無,Y:有-->
    <INPUT TYPE="text" id=havectrl name=havectrl value="N"><!--判斷有預設期限管制，需至少輸入一筆資料 N:無,Y:有-->
    <INPUT TYPE="text" id=cansave name=cansave value="N"><!--判斷有核對案件主檔，N:資料不符無,Y:資料相符-->
    <input type="text" id=temp_rs_sqlno name=temp_rs_sqlno value="<%=Request["temp_rs_sqlno"]%>"><!--step_mgt_temp.temp_rs_sqlno-->
    <input type="text" id=emg_scode name=emg_scode value="<%=emg_scode%>"><!--Email通知總管處人員，正本收件者-->
    <input type="text" id=emg_agscode name=emg_agscode value="<%=emg_agscode%>"><!--Email通知總管處人員，副本收件者-->
    <input type="text" id=mg_end_date name=mg_end_date value="<%=Request["mg_end_date"]%>"><!--總收發之結案日期-->
    <input type="text" id=end_flag name=end_flag value="N"><!--總收發之待結案註記，N:無，Y:寫入總收發待結案處理-->
    <input type="text" id=smgt_temp_mark name=smgt_temp_mark><!--收檢發註冊證註記IS:檢發註冊證-->
    <INPUT TYPE="text" id=from_flag name=from_flag><!--step_mgt_temp.from_flag進度來源-->
    <center>
        <uc1:Brta21form runat="server" id="Brta21form" /><!--案件主檔欄位畫面，與收文共同-->
        <uc1:brta211form runat="server" id="Brta211form" /><!--官收欄位畫面-->
        <uc1:Brta212form runat="server" id="Brta212form" /><!--管制欄位畫面，與收文共同-->
     </center>

    <br>
    <table border=0 class="bluetable"  cellspacing=1 cellpadding=2 width="100%">
	    <tr>
            <td width="20%" class=lightbluetable3 align=right><font color=red>退回原因：</font></td>
            <td width="80%" class=whitetablebg><textarea rows=3 cols=60 name="reject_reason" id="reject_reason"></textarea></td>	
        </tr>
    </table> 

    <%#DebugStr%>
</form>

<table border="0" width="98%" cellspacing="0" cellpadding="0">
<tr>
    <td width="100%" align="center">
        <%#StrFormBtn%>
    </td>
</tr>
</table>
<br />
<table border="0" width="98%" cellspacing="0" cellpadding="0">
<tr class="FormName">
    <td><div align="left" style="color:blue"><%#FormName%></div></td>
</tr>
</table>

<div id="dialog"></div>

<iframe id="ActFrame" name="ActFrame" src="about:blank" width="100%" height="500" style="display:none"></iframe>
<div id="msg" style='text-align:left;height:100px'></div>
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
        settab("#grconf");

        //取得收文資料
        $.ajax({
            type: "get",
            url: "brta24_edit.aspx?json=Y&<%#Request.QueryString%>",
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
        brta211form.init();
        brta212form.init();
        //-----------------
        $("input.dateField").datepick();
        main.bind();//資料綁定

        if(main.submittask=="U"||main.submittask=="Q"||main.submittask=="D"||(main.submittask=="A" && main.prgid=="brta24")){
            $("#mp_date").lock();
            $("#send_way").unlock();
            if($("#from_flag").val()=="C"){
                $("#act_code").triggerHandler("change");
            }
        }

        $(".Lock").lock();
        $(".Hide").hide();
    }
    
    main.bind = function () {
        $("#smgt_temp_mark").val(jMain.add_gr.smgt_temp_mark);
        $("#from_flag").val(jMain.add_gr.from_flag);
        $("#span_fseq").html(jMain.add_gr.fseq);
        $("#span_rs_no").html("收文序號："+jMain.add_gr.rs_no).show();

        brta21form.bind(jMain.add_gr);//主檔資料
        brta211form.bind(jMain.add_gr,jMain.mg_attach);//收文資料
        brta212form.bind(jMain.add_gr,jMain.gr_ctrl);//管制資料
    }

    //存檔
    function formAddSubmit(){
        if(main.submittask=="A"||main.submittask=="U"){
            if($("#keyseq").val()=="N"){
                alert("本所編號變動過，請按[確定]按鈕，重新抓取資料!!!");
                return false;
            }

            if($("#new_seq").val()!=""){
                if($("input[name='domark']:checked").length==0){
                    alert("本案為被異議或被評定之官收，請選擇作業選項");
                    return false;
                }
            }

            if(chkNull("本所編號",$("#seq"))) return false;
            if(chkNull("本所編號副碼",$("#seq1"))) return false;
            if(chkNull("收文日期",$("#step_date"))) return false;
            if(chkNull("來文單位",$("#send_cl"))) return false;
            if(chkNull("案性代碼",$("#rs_code"))) return false;
            if(chkNull("處理事項",$("#act_code"))) return false;

            //2010/1/19增加檢查案件主檔營洽，因營洽需官收確認，若無營洽，todo_dmt.job_scode會空白造成營洽清單顯示不出來
            if($("#scode").val()==""){
                alert("本案件無營洽資料，無法執行後續營洽官收確認作業，煩請先補入案件主檔營洽再執行官收確認作業！");
                return false;
            }
            if($("input[name='csflg']:checked").length==0){
                alert("客戶報導必須點選!!!");
                return false;
            }

            if($("input[name='csflg']:checked").val()=="Y"){//客戶報導
                if(chkNull("發文方式",$("#send_way"))) return false;
                if(chkNull("預定寄發日期",$("#pmail_date"))) return false;
                var pmail_date = CDate($('#pmail_date').val());
                if (pmail_date.getTime() < Today().getTime()) {
                    if(main.submittask=="A"){
                        alert("預定寄發日期小於今天，請檢查並重新輸入！");
                        return false;
                    }else{
                        if(!confirm("預定寄發日期小於今天，是否確定存檔？")){
                            return false;
                        }
                    }
                }
            }

            //有制式客函，若不需報導或延期客發，需填寫原因
            if($("#cs_flag").val()=="Y"){
                if($("input[name='csflg']:checked").val()=="N"||$("#csd_flag").prop("checked")){
                    if(chkNull("原因",$("#cs_remark"))) return false;
                }
            }

            //2014/5/26增加提醒，電子公文檔需檢視
            if ($("#pdfchkflag").val()=="Y"){
                for (var p = 1; p <= CInt($("#pdfcnt").val()) ; p++) {
                    if($("#pdfviewflag_"+p).val()=="N"){
                        if ($("#pdfsource").val()=="EGR"){
                            alert("請開啟智慧局公文電子檔(第"+p+"個)，以便檢視公文內容及核對期限！");
                        }else{
                            alert("請開啟Email公文電子檔(第"+p+"個)，以便檢視公文內容！");
                        }	 
                        return false;

                    }
                }
            }
            //////////////////////////////////////////////////
            if($("input[name='job_type']:checked").length==0){
                alert("作業處理必須點選!!!");
                return false;
            }

            if($("input[name='job_type']:checked").val()=="case"){//接洽客戶後續案性
                if($("#job_case").val()==""){
                    alert("洽案登錄案性必須點選!!!");
                    $("#toadd").focus();
                    return false;
                }
                if(chkNull("預計處理日期",$("#pre_date"))) return false;
            }

            if($("input[name='cs_report']:checked").length==0){
                alert("自行客戶報導必須點選!!!");
                return false;
            }

            if($("input[name='cs_report']:checked").val()=="Y"){//自行客戶報導:是
                var fld=$("#uploadfield").val();
                if($("#"+fld+"_filenum").val()==""||$("#"+fld+"_filenum").val()=="0"){
                    alert("自行客戶報導需至少新增一筆上傳文件！");
                    return false;
                }else{
                    var filename_flag=false;
                    for (var pnum = 1; pnum <= CInt($("#"+fld+"_filenum").val()) ; pnum++) {
                        if($("#"+fld+"_filenum").val()!=""){
                            filename_flag=true;
                            break;
                        }
                    }

                    if (filename_flag=false){
                        alert("自行客戶報導需至少上傳一筆文件！")
                        return false;
                    }
                }
            }
        }
        postForm("Brta24Update.aspx?task=conf");
    }

    //退件處理
    function formReSubmit(){
        if(confirm("是否確定退回總管處!!!")){
            //退回時要Email通知總管處人員，所以要判斷有無收件者
            if ($("#emg_scode").val()==""||$("#emg_agscode").val()==""){
                alert("系統找不到Email通知總管處人員，無法發信，請通知系統維護人員！");
                return false;
            }
            if ($("#reject_reason").val()==""){
                alert("請輸入退回原因！！！");
                return false;
            }

            postForm("Brta24Update.aspx?task=back");
        }
    }

    //刪除
    function formDelSubmit(){
        if(confirm("是否確定刪除!!!")){
            postForm("Brta21Update.aspx");
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

    function Help_Click(){
        window.open(getRootPath() + "/brtam/國內案發收文系統操作手冊.htm","","width=700, height=500, top=50, left=50, toolbar=no, menubar=no, location=no, directories=no, resizeable=no, status=no, scrollbars=yes");
    }

    //資料有誤通知總收發修正
    function tomgbutton_email(){
        <%
        string strto = "";//收件者
        string strcc = "";//副本
        string strbcc = "";//密件副本
        string Sender = Sys.GetSession("scode");//寄件者
        if (Sys.Host == "web08") {
            strto = "";
            strcc = "m1583;";
            strbcc = "";
        } else if (Sys.Host == "web10") {
            strto = emg_scode + ";";
            strcc = emg_agscode + ";";
            strbcc = "";
        } else {
            strto = emg_scode + ";";
            strcc = emg_agscode + ";";
            strbcc = "";
        }
        %>
        var tsubject = "國內所商標網路系統－官收資料修正通知（區所編號：" + jMain.add_gr.fseq + "，總收發進度：" + jMain.add_gr.mg_step_grade + " ）";//主旨
        var strto = "<%=strto%>";//收件者
        var strcc = "<%=strcc%>";//副本
        var strbcc = "<%=strbcc%>";//密件副本
        
        var tbody = "致: 總管處 程序%0A%0A"
        tbody += "【通 知 日 期 】: " + (new Date()).format("yyyy/M/d");
        tbody += "%0A【區所編號】:" + jMain.add_gr.fseq + "，來文字號：" + jMain.add_gr.receive_no + "，收文日期："+jMain.add_gr.step_date+"，總收發日期："+jMain.add_gr.mp_date;
        tbody += "%0A【收文內容】:" + jMain.add_gr.rs_detail;
		tbody += "%0A 檢核資料有誤 ，煩請確認，如有資料修正，請更正後通知。";
        tbody += "%0A【檢核項目】";
        tbody += "%0A申請日期";
        tbody += "%0A申請號碼";
        tbody += "%0A註冊日期";
        tbody += "%0A註冊號碼";
        tbody += "%0A核駁號碼";
        tbody += "%0A官收代碼";
        tbody += "%0A法定期限";

        ActFrame.location.href = "mailto:" + strto + "?subject=" + tsubject + "&body=" + tbody + "&cc=" + strcc;//+"&bcc="+ strbcc;
    }
</script>

